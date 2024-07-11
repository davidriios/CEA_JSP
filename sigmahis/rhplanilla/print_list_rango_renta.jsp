<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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

CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();
String compania = (String) session.getAttribute("_companyId");
String userName = UserDet.getUserName();
StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
if(appendFilter == null)appendFilter="";

sql.append("select id,rango_inicial as inicia, rango_final as fin, porcentaje, rango_inicial_real as real, cargo_fijo as fijo,decode(tipo,'S','SALARIO','G','GASTO DE REP.')descTipo,decode(status,'A','ACTIVO','I','INACTIVO')descStatus from tbl_pla_rango_renta where id >0  ");
sql.append(appendFilter);

sql.append(" order by tipo desc, rango_inicial asc");
al = SQLMgr.getDataList(sql.toString());

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
	float height = 72 * 14f;//1008
	boolean isLandscape = false;
	float leftRightMargin = 5.0f;
	float topMargin = 9.5f;
	float bottomMargin = 1.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = "TABLA DE RANGO DE RENTAS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".15");
	dHeader.addElement(".17");
	dHeader.addElement(".17");
	dHeader.addElement(".17");
	dHeader.addElement(".17");
	dHeader.addElement(".17");
		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
		pc.addBorderCols("APLICAR A",1,1);
		pc.addBorderCols("RANGO INICIAL",1,1);
		pc.addBorderCols("RANGO FINAL",1,1);
		pc.addBorderCols("CARGO FIJO",1,1);
		pc.addBorderCols("PORCENTAJE EXCEDE",1,1);
		pc.addBorderCols("ESTADO",1,1);		
		pc.setTableHeader(2);
		
		for ( int j = 0; j<al.size(); j++ ){
			cdo = (CommonDataObject) al.get(j);
			
			pc.addCols(""+cdo.getColValue("descTipo"),0,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("inicia")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("fin")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("fijo")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("porcentaje")),2,1);
			pc.addCols(""+cdo.getColValue("descStatus"),1,1);
			 
		   if ((j % 50 == 0) || ((j + 1) == al.size())) pc.flushTableBody(true);
			
		}//for j
		
		if ( al.size() == 0 ){
	    pc.setFont(8,1);
	    pc.addCols("****** NO EXISTEN REGISTROS! ******",1,dHeader.size());
	    pc.addCols(" ",0,dHeader.size());
		}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>
