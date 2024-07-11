<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String appendFilter = request.getParameter("appendFilter")==null?"":request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

String sql = "SELECT id, nombre, nombre_corto, almacen, (select descripcion from tbl_inv_almacen where codigo_almacen = almacen and compania = company_id) as almacen_desc, archivo, qty_filas , status, decode(status,'A','Activo','I','Inactivo') as status_desc from tbl_inv_pdt_archivo where company_id = "+compania+appendFilter;

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "INVENTARIO";
	String subtitle = "LISTADO DE ARCHIVOS PDT CARGADOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".07");
	dHeader.addElement(".33");
	dHeader.addElement(".16");
	dHeader.addElement(".27");
	dHeader.addElement(".10");
	dHeader.addElement(".07");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setFont(fontSize,1);
	pc.addBorderCols("CODIGO",0,1);
	pc.addBorderCols("NOMBRE",0,1);
	pc.addBorderCols("NOMBRE CORTO",0,1);
	pc.addBorderCols("ALMACÉN",0,1);
	pc.addBorderCols("QTY FILAS",1,1);
	pc.addBorderCols("ESTADO",1,1);
	pc.setTableHeader(2);
	
	pc.setFont(fontSize,0);
	pc.setVAlignment(0);

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.addCols(cdo.getColValue("id"),0,1);
		pc.addCols(cdo.getColValue("nombre")+" - "+cdo.getColValue("archivo"),0,1);
		pc.addCols(cdo.getColValue("nombre_corto"),0,1);
		pc.addCols("["+cdo.getColValue("almacen")+"] "+cdo.getColValue("almacen_desc"),0,1);
		pc.addCols(cdo.getColValue("qty_filas"),1,1);
		pc.addCols(cdo.getColValue("status_desc"),1,1);
	}
	
	pc.setFont(fontSize,1);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>