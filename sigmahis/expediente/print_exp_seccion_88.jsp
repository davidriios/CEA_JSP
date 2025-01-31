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
Reporte sal10030   fg=NE
Reporte sal10030b  fg=null or blank
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo, cdoPacData, cdoTitle = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String appendFilter0 = request.getParameter("appendFilter0");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fechaReporte = request.getParameter("fecha");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (fp == null) fp = "TD";
if (desc == null) desc = "";

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
sql = "select a.diagnostico , a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'S' order by a.orden_diag";

al = SQLMgr.getDataList(sql);

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String title = "EXPEDIENTE";
	String subtitle = desc;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

	Vector dHeader = new Vector();
		dHeader.addElement("7");
		dHeader.addElement("35");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
    pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
		
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(7,1, Color.white);
		pc.addBorderCols("C�digo",1,1, Color.gray);
		pc.addBorderCols("Nombre",1,1, Color.gray);
		pc.addBorderCols("Prioridad",1,1, Color.gray);
		pc.addBorderCols("Registrado por",1,1, Color.gray);
		pc.addBorderCols("F. Creaci�n",1,1, Color.gray);
		pc.addBorderCols("Modificado por",1,1, Color.gray);
		pc.addBorderCols("F. Modif.",1,1, Color.gray);

		pc.setTableHeader(2);

		//second row
		pc.setVAlignment(0);

		if(al.size()<1){
			pc.addCols("No se ha encontrado registros!",1,dHeader.size());
		}
		else{

			for(int i = 0; i<al.size(); i++){

				cdo = (CommonDataObject)al.get(i);

				pc.setFont(7,0);
				pc.addCols(cdo.getColValue("diagnostico"),0,1);
				pc.addCols(cdo.getColValue("diagnosticoDesc"),0,1);
				pc.addCols(cdo.getColValue("orden_diag"),1,1);
				pc.addCols(cdo.getColValue("usuario_creacion"),1,1);
				pc.addCols(cdo.getColValue("fecha_creacion"),0,1);
				pc.addCols(cdo.getColValue("usuario_modificacion"),1,1);
				pc.addCols(cdo.getColValue("fecha_modificacion"),0,1);

			}//end for

		}//end else
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}
//}//GET
%>