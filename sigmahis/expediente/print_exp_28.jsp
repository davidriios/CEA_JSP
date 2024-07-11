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
Reporte
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

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fecha2 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String date = CmnMgr.getCurrentDate("hh12:mi:ss am");
String change = request.getParameter("change");
String observacion = request.getParameter("observacion");
String cda = request.getParameter("cda");
String cds = request.getParameter("cds");
String type = request.getParameter("type");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

if (appendFilter == null) appendFilter = "";

cdo1 = SQLMgr.getPacData(pacId, noAdmision);

  sql = "SELECT a.almacen, b.descripcion||' - '||a.almacen as almacen_desc, to_char(p.fecha_documento, 'dd/mm/yyyy') fecha, to_char(p.fecha_documento, 'hh12:mi') hora, T.ART_FAMILIA, T.ART_CLASE, T.COD_ARTICULO, T.CANTIDAD, t.descripcion, p.observaciones FROM tbl_sec_cds_almacen a, tbl_inv_almacen b, TBL_INV_D_SOL_PAC T, tbl_inv_solicitud_pac p where p.compania = t.compania and p.solicitud_no = t.solicitud_no and p.anio = t.anio and p.codigo_almacen = b.codigo_almacen and a.almacen = b.codigo_almacen and p.pac_id = "+pacId+" and p.adm_secuencia = "+noAdmision;

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "Solicitar Insumos";
	String subtitle = "";
	String xtraSubtitle = "";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".12");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".30");
		dHeader.addElement(".28");
		dHeader.addElement(".15");
		dHeader.addElement(".20");
		
CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdo1.addColValue("is_landscape",""+isLandscape);
    }


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, permission, passRequired, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdo1, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha2, dHeader.size());

		//second row
	//pc.useTable("main");
		pc.setFont(7, 1);
		pc.addBorderCols("FECHA",0);
		pc.addBorderCols("HORA",1);
		pc.addBorderCols("FAMILIA",1);
		pc.addBorderCols("CLASE",1);
		pc.addBorderCols("ARTICULO",1);
		pc.addBorderCols("DESCRIPCION",1);
		pc.addBorderCols("CANTIDAD",1);
		pc.addBorderCols("OBSERVACION",1);
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.addCols(cdo.getColValue("fecha"),0,1);
		pc.addCols(cdo.getColValue("hora"),0,1);
		pc.addCols(cdo.getColValue("ART_FAMILIA"),1,1);
		pc.addCols(cdo.getColValue("ART_CLASE"),0,1);
		pc.addCols(cdo.getColValue("COD_ARTICULO"),0,1);
		pc.addCols(cdo.getColValue("descripcion"),1,1);
		pc.addCols(cdo.getColValue("cantidad"),0,1);
		pc.addCols(cdo.getColValue("observaciones"),0,1);
		


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>