<%//@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="cdoB" scope="page" class="issi.admin.CommonDataObject" />
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
CommonDataObject cdo = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String banco = request.getParameter("banco");
String cuenta = request.getParameter("cuenta");
String anio = request.getParameter("anio");


if (appendFilter == null) appendFilter = "";

	sql = "SELECT cpto_anio anio, fecha_mes as mes, nvl(saldo_inicial,0) as saldo_inicial, nvl(tot_debito,0) as debitos, nvl(tot_credito,0) as creditos, nvl(tot_deposito,0) as depositos, nvl(tot_girado,0) as girado, nvl(saldo_libro,0) as saldo, nvl(saldo_banco,0) as banco, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fcreacion FROM tbl_con_detalle_cuenta WHERE cuenta_banco='"+cuenta+"' and cod_banco='"+banco+"' and cpto_anio = "+anio+" and compania="+(String) session.getAttribute("_companyId")+" order by cpto_anio desc, fecha_mes desc";
	al = SQLMgr.getDataList(sql);

   	sql = "select '['||cod_banco||'] -'||nombre nombreBanco from tbl_con_banco where compania = "+session.getAttribute("_companyId")+" and cod_banco="+banco;
   	cdoB = SQLMgr.getData(sql);

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
	String subtitle = "CONCILIACION BANCARIA - SALDOS POR MES";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();

	dHeader.addElement(".05");
	dHeader.addElement(".04");
	dHeader.addElement(".13");
	dHeader.addElement(".13");
	dHeader.addElement(".13");
	dHeader.addElement(".13");
	dHeader.addElement(".13");
	dHeader.addElement(".13");
	dHeader.addElement(".13");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(8, 1);
		pc.addCols("Banco : "+cdoB.getColValue("nombreBanco"),0,dHeader.size());
		pc.addCols("Cuenta Bancaria : "+cuenta,0,dHeader.size());

		//second row
		pc.addBorderCols("AÑO",1,1);
		pc.addBorderCols("MES",1,1);
		pc.addBorderCols("SALDO INICIAL",2,1);
		pc.addBorderCols("DEBITOS",2,1);
		pc.addBorderCols("CREDITOS",2,1);
		pc.addBorderCols("DEPOSITOS",2,1);
		pc.addBorderCols("CK.GIRADOS",2,1);
		pc.addBorderCols("SALDO LIBRO",2,1);
		pc.addBorderCols("SALDO BANCO",1,1);

		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table


	//table body
	pc.setVAlignment(0);
	pc.setFont(8, 0);
	String bank = "";
	String cta = "";

	for (int i=0; i<al.size(); i++)
	{
		 cdo = (CommonDataObject) al.get(i);

		pc.addCols(" "+cdo.getColValue("anio"),1,1);
		pc.addCols(" "+cdo.getColValue("mes"),1,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial")), 2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("debitos")), 2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("creditos")), 2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("depositos")), 2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("girado")), 2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")), 2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("banco")), 2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.addCols(" ",0,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
