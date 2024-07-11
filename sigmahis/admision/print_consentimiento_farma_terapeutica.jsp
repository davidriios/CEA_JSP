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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

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
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

String compania = (String) session.getAttribute("_companyId");

String categoria       = request.getParameter("categoria");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");

//--------------Query para obtener datos del Paciente----------------------------------------//
sql = " select nombre_paciente nombrePaciente, decode(tipo_id_paciente, 'P',pasaporte,provincia||'-' ||sigla||'-' ||tomo||'-' ||asiento) cedula from vw_adm_paciente Where pac_id="+pacId;
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

	float width = 72 * 8.5f;//612 
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISIÓN";
	String subTitle = "COMITÉ DE FARMACIA Y TERAPÉUTICA (008)";
	String xtraSubtitle = "DISPOSICIÓN PARA LOS MEDICAMENTOS QUE TRAIGAN LOS PACIENTES";
	
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
		
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),90.0f,1);
		
		pc.addTable();

	Vector dHeader = new Vector();
		dHeader.addElement(".01");
		dHeader.addElement(".10"); 
		dHeader.addElement(".05"); 
		dHeader.addElement(".10");
		//dHeader.addElement(".30");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);

     pc.setFont(10, 1);
	 
	 pc.setVAlignment(0);
	
		
		pc.addCols(" ", 1, dHeader.size());
		pc.addCols(title, 1, dHeader.size(),20.2f);
		pc.addCols(subTitle, 1, dHeader.size());
	    pc.addCols(xtraSubtitle, 1, dHeader.size());
		 
		pc.addCols(" ", 1, dHeader.size(), 25.2f); 
		pc.setFont(10, 0);

		pc.addCols("1. ", 0, 1);
		pc.addCols("Para garantizar la seguridad, el seguimiento farmacólogo y la calidad "+
	"de los medicamentos dispensados a los pacientes que ingresen al Hospital "+_comp.getNombre()+
	" ,no se le permitirá a los mismos que traigan sus propios medicamentos.", 3, 3);
		pc.addCols(" ", 0, dHeader.size(), 8.2f);
		
		pc.addCols("2. ", 0, 1);
		pc.addCols("La única excepción a esta disposición será de algún paciente que ingrese de manera urgente "+
	"y está recibiendo algún medicamento indispensable y que a juicio de su médico tratante no pueda"+
	" suspender su tratamiento y que el mismo no esté disponible en el país, o en el inventario "+
	"de la Farmacia en ese momento; sólo entonces será aceptado, por la Dirección Médica "+
	"y el Médico Tratante, que traiga su médico el cual será entregado a la Farmacia Hospitalaria "+
	"quien tramitará la entrega del mismo luego de su acondicionamiento, "+
	"facturando solamente el manejo y tramite del mismo. Esto será solamente hasta que "+
	"la Farmacia Hospitalaria logre obtener el (los)  medicamento (s) en mención.", 3, 3);
	pc.addCols(" ", 0, dHeader.size(), 8.2f);
		
		pc.addCols("3. ", 0, 1);
		pc.addCols("El punto anterior será valido solamente hasta que la Farmacia Hospitalaria "+
	"logre obtener el (los) medicamento (s) en mención.", 3, 3);
	pc.addCols(" ", 0, dHeader.size(), 8.2f);
	
		pc.setFont(10,1);
		pc.addCols("4. ", 0, 1);
		pc.addCols("La responsabilidad exclusiva del resultado del tratamiento terapéutico de los medicamentos "+
	"en estas condiciones será del médico tratante.", 3, 3);
	pc.addCols(" ", 0, dHeader.size(), 8.2f);
	
	pc.setFont(10,0);
	pc.addCols("5. ", 0, 1);
		pc.addCols("Es conveniente también aclarar que cuando un paciente es admitido para hospitalización "+
	"y se de inicio al cumplimiento de las órdenes médicas, los medicamentos generados por "+
	"las mismas empezaran a ser facturados a la cuenta del (la) paciente.", 3, 3);
	pc.addCols(" ", 0, dHeader.size(), 8.2f);
	
	pc.addCols("Confirmamos que hemos leído, comprendido y aceptado todos los términos y condiciones que constan que el presente documento:",0,dHeader.size());
		
		 pc.setVAlignment(2);
		
	    pc.addCols("Nombre Completo del Paciente: ", 0, 2, 15.2f);
        pc.addBorderCols(cdo.getColValue("nombrePaciente"), 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);
		
	    pc.addCols("Firma del Paciente: ", 0, 2, 20.2f);
	    pc.addBorderCols("", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
		//pc.addCols(" ", 0, 1);
		
	    pc.addCols( "Cédula: ", 0, 2, 15.2f);
		pc.addBorderCols(cdo.getColValue("cedula"), 0,2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
		//pc.addCols(" ", 0, 1, 15.2f);
		
		

	    pc.addCols("Nombre Completo de la Persona Responsable (entiéndase como persona responsable los esposos, padre, madre o tutor):", 0, dHeader.size(), 40.2f);

	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>