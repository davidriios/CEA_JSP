<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoSI = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String fp = request.getParameter("fp");
String pMovimiento = request.getParameter("pMovimiento"); 


if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if(pMovimiento==null) pMovimiento="";

if (appendFilter == null) appendFilter = "";
if (fp == null) appendFilter = " and cg.recibe_mov = 'S'";
else appendFilter = " AND (((nvl(cg.ult_mes,0) >= '"+mes+"' AND cg.ult_anio >= "+anio+") OR cg.recibe_mov = 'S') OR (nvl(cg.ult_anio ,0) > "+anio+" AND cg.ult_anio is not null)) ";
if (pMovimiento.trim().equals("S")){
  appendFilter += " and (NVL(mm.monto_i,0) != 0 or  NVL(mm.monto_db,0) <> 0 or  NVL(mm.monto_cr,0) != 0)";
}

if(!fechaini.equals("")) appendFilter += " and trunc(fecha_documento) >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
if(!fechafin.equals("")) appendFilter += " and trunc(fecha_documento) <= to_date('"+fechafin+"', 'dd/mm/yyyy')";

sql= "select cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6 cuenta, cg.descripcion, NVL(mm.monto_i,0) saldo_inicial, NVL(mm.monto_db,0) debito, NVL(mm.monto_cr,0) credito,  NVL(mm.monto_i,0) + NVL(mm.monto_db,0) - NVL(mm.monto_cr,0)  saldo FROM TBL_CON_MOV_MENSUAL_CTA mm, TBL_CON_CATALOGO_GRAL cg, TBL_CON_PLAN_CUENTAS pc WHERE mm.cat_cta1 = pc.cta1 AND mm.cat_cta2 = pc.cta2 AND mm.cat_cta3 = pc.cta3 AND mm.cat_cta4 = pc.cta4 AND mm.cat_cta5 = pc.cta5 AND mm.cat_cta6 = pc.cta6 AND mm.ea_ano = pc.ano AND cg.cta1 = pc.cta1 AND cg.cta2 = pc.cta2 AND cg.cta3 = pc.cta3 AND cg.cta4 = pc.cta4 AND cg.cta5 = pc.cta5 AND cg.cta6 = pc.cta6 AND mm.ea_ano = "+anio+" AND mm.mes = '"+mes+"' AND pc.compania = " + (String) session.getAttribute("_companyId") + appendFilter +" AND mm.pc_compania = pc.compania AND cg.compania = pc.compania ORDER BY cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6";

	al = SQLMgr.getDataList(sql);
	if(!mes.trim().equals("13"))cdoSI = SQLMgr.getData("select 'AL ' || to_char(last_day(to_date('"+mes+"/"+anio+"', 'mm/yyyy')), 'dd') || ' DE ' || to_char(to_date('"+mes+"','mm'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH') || ' DE "+anio+"' fecha from dual");
	else cdoSI = SQLMgr.getData("select 'MES CIERRE  "+anio+"' fecha from dual");


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;

	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONTABILIDAD";
	String subtitle = "LIBRO MAYOR";
	String xtraSubtitle = ""+cdoSI.getColValue("fecha");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".15");
			dHeader.addElement(".35");
			dHeader.addElement(".13");
			dHeader.addElement(".12");
			dHeader.addElement(".12");
			dHeader.addElement(".13");


PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(8, 1);

			pc.addBorderCols("CUENTA",1);
			pc.addBorderCols("DESCRIPCION",0);
			pc.addBorderCols("SALDO INICIAL",2);
			pc.addBorderCols("DEBITO",2);
			pc.addBorderCols("CREDITO",2);
			pc.addBorderCols("SALDO",2);


	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "";
	double saldo = 0.00;
	double totalDb = 0.00;
	double totalCr = 0.00;



	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		saldo += Double.parseDouble(cdo.getColValue("debito"));
		saldo -= Double.parseDouble(cdo.getColValue("credito"));
		totalDb += Double.parseDouble(cdo.getColValue("debito"));
		totalCr += Double.parseDouble(cdo.getColValue("credito"));

			pc.addCols(" "+cdo.getColValue("cuenta"),0,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("debito")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("credito")),2,1);
			if(Double.parseDouble(cdo.getColValue("saldo")) < 0) pc.addCols(" ("+CmnMgr.getFormattedDecimal((Double.parseDouble(cdo.getColValue("saldo"))*-1))+")",2,1);
			else pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),2,1);


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
	pc.addCols(" Total  ",2,3);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalDb),2,1,0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totalCr),2,1,0.5f,0.0f,0.0f,0.0f);
	//pc.addBorderCols(cdo.getColValue("descType"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addCols(" ",2,1);

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>