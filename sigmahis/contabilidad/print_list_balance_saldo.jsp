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
ArrayList alE = new ArrayList();
CommonDataObject cdoE = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String mesF = request.getParameter("mesF");
String cta1 = request.getParameter("cta1");
String fp = request.getParameter("fp");


if(cta1==null)   cta1 = "";
if(anio==null)   anio = "";
if(mes==null)    mes = "";


if (appendFilter == null) appendFilter = "";

if (cta1 != "") 
{
	appendFilter += " and d.num_cuenta like '"+cta1+"%'";
}
if (anio != "") 
{
	appendFilter += " and d.ea_ano  = "+anio;
}
if (mes!= "") 
{
	appendFilter += " and d.mes  = "+mes;
}
sql = "select d.num_cuenta cuenta, d.descripcion nombre_de_cuenta, d.lado_movim movimiento, d.recibe_mov recibe, nvl(d.balance,0) saldo, nvl(d.balance,0) balance from vw_con_catalogo_gral_bal d where d.compania = "+(String) session.getAttribute("_companyId")+ appendFilter +" order by d.num_cuenta";

	al = SQLMgr.getDataList(sql);
		


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
	String subtitle = "BALANCE DE SALDOS DE CUENTAS FINANCIERAS";
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
			dHeader.addElement(".15");
			dHeader.addElement(".29");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".12");
			dHeader.addElement(".12");
			dHeader.addElement(".12");
		

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(7, 1);
			
		//	pc.addCols(""+cdoSI.getColValue("fecha"),1,dHeader.size());
			
			pc.addCols("CUENTA",1,1);
			pc.addCols("NOMBRE DE CUENTA",0,1);
			pc.addCols("LADO",1,1);
			pc.addCols("RECIBE MOV.",1,1);
			pc.addCols("SALDO ACTUAL",2,1);
			pc.addCols("BALANCE",2,1);
			pc.addCols("DIFERENCIA",2,1);
			
			
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "";
	String detMov = "";
	double saldo = 0.00;
	double totdb = 0.00;
	double totcr = 0.00;
	int con=0, sw=0;
	
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
			
				pc.setFont(7, 0);
				saldo = 0.00;		   
				pc.addCols("  "+cdo.getColValue("cuenta"),0,1);
				pc.addCols("  "+cdo.getColValue("nombre_de_cuenta"),0,1);
				pc.addCols("  "+cdo.getColValue("movimiento"),1,1);
				pc.addCols("  "+cdo.getColValue("recibe"),1,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("balance")),2,1);
				
				if(cdo.getColValue("recibe").trim().equals("N"))
				saldo = Double.parseDouble(cdo.getColValue("saldo")) - Double.parseDouble(cdo.getColValue("balance")) ;
				
				pc.addCols(" "+CmnMgr.getFormattedDecimal(saldo),2,1);
			
				
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		
	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else 
	{
	pc.addCols(" ",2,3);
	pc.addCols(" ",2,2);
	pc.addCols(" ",2,1);
	pc.addCols(" ",2,1);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>