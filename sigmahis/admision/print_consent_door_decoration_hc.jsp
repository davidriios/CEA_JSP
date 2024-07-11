<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header_consentimiento.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

String compania = (String) session.getAttribute("_companyId");

//--------------Query para obtener datos del Paciente ----------------------------------------//
sql = " select nombre_paciente nombrePaciente, decode(p.tipo_id_paciente, 'P',p.pasaporte,p.provincia||'-' ||p.sigla||'-' ||p.tomo||'-' ||p.asiento) cedula, getHabitacion("+compania+","+pacId+","+noAdmision+") as habitacion, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(sysdate,'Day dd \"de\" Month \"de\" yyyy','nls_date_language=spanish') as lat_date from vw_adm_paciente p, tbl_adm_admision a Where p.pac_id="+pacId+" and p.pac_id = a.pac_id and a.secuencia = "+noAdmision;

cdo = SQLMgr.getData(sql);
//al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72* 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 50.0f;//30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = " ADMISI�N";
	String subTitle = "FORMULARIO DE AUTORIZACI�N PARA DECORACI�N DE HABITACIONES";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	
	//------------------------------------------------------------------------------------

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}


//control imgae

		Vector tblImg = new Vector();
		tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();

		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),50.0f,1);
		pc.addTable();

		Vector dHeader = new Vector();
		dHeader.addElement("0.05");
		dHeader.addElement("0.15");
		dHeader.addElement("0.10");
		dHeader.addElement("0.10");
		dHeader.addElement("0.10");
		dHeader.addElement("0.10");
		dHeader.addElement("0.10");
		dHeader.addElement("0.10");
		dHeader.addElement("0.10");
		dHeader.addElement("0.10");


		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		pc.setFont(10, 1);

		pc.addCols(title, 1, dHeader.size(),15.2f);
		pc.addCols(subTitle, 1, dHeader.size());
		pc.addCols("", 1, dHeader.size(), 10.2f);

        pc.setVAlignment(0);
		
		pc.addCols("\n", 1, dHeader.size());
		pc.setFont(10, 0);
		
		pc.addCols("David, "+cdo.getColValue("lat_date")+"\n\n\n\nYo, "+cdo.getColValue("nombrePaciente")+" Solicito  autorizaci�n para decorar,  a mi costo, la habitaci�n  que me ha sido asignada para mi estad�a  en el hospital.\n\nDeclaro que  he le�do  las disposiciones  y pol�ticas  del hospital  en  relaci�n  a la forma  en que debe  ser realizadas  tales decoraciones.\n\nMe comprometo  a cumplir con todos los requisitos y limitaciones en que se han informado. Acepto la responsabilidad por cualquier da�o causado a las instalaciones o al mobiliario del hospital  con motivo  de la  colocaci�n  o retiro  de los materiales y objetos de decoraci�n.\n\n\n\nHabitaci�n n�       "+cdo.getColValue("habitacion")+"         Firma: ________________________________________\n\nAprobado por: ____________________________________",3, dHeader.size());
		
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>