<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header_consentimiento.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String compania = (String) session.getAttribute("_companyId");
String lng = request.getParameter("lng");
String nombreCompania = _comp.getNombre();
String sql = "";

CommonDataObject cdo = new CommonDataObject();

cdo = SQLMgr.getData(" select nombre_paciente nombrePaciente, decode(p.tipo_id_paciente, 'P',p.pasaporte,p.provincia||'-' ||p.sigla||'-' ||p.tomo||'-' ||p.asiento) cedula, getHabitacion("+compania+","+pacId+","+noAdmision+") as habitacion, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(sysdate,'Day dd \"de\" Month \"de\" yyyy','nls_date_language=spanish') as lat_date ,(select primer_nombre ||' '||primer_apellido from tbl_adm_medico where codigo = a.medico) as nombremedico from vw_adm_paciente p, tbl_adm_admision a Where p.pac_id="+pacId+" and p.pac_id = a.pac_id and a.secuencia = "+noAdmision);

if ( cdo == null ) cdo = new CommonDataObject();

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	float leftRightMargin = 45.0f; //9.0f
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subTitle = "DISPOSICIÓN PARA LOS MEDICAMENTOS E INSUMOS QUE TRAIGAN LOS PACIENTES";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 90.0f;

    //PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

	Vector tblImg = new Vector();
	tblImg.addElement(".20");
	tblImg.addElement(".60");
	tblImg.addElement(".20");

	Vector dHeader = new Vector();
	dHeader.addElement(".20");
	dHeader.addElement(".50");
	dHeader.addElement(".30");

	Vector dCenterFooter = new Vector();
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".15");
	dCenterFooter.addElement(".12");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".12");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".02");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".02");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();

	pc.setNoColumnFixWidth(tblImg);
	pc.createTable("tblImg",false,0,0.0f,522f);
	   pc.addCols(" ",0,1);
	   pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
	   pc.addCols(" ",0,1);
	pc.useTable("main");
	pc.addTableToCols("tblImg",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

	pc.setFont(12, 1);
	pc.addCols(" ", 1, dHeader.size());
	pc.addCols(title, 1, dHeader.size(),20.2f);
	pc.addCols(subTitle, 1, dHeader.size());

	pc.setNoColumnFixWidth(dCenterFooter);
	pc.createTable("dCenterFooter",false,0,0.0f,522f);

	pc.addCols(" ",0,dCenterFooter.size());
	pc.setFont(11,0);
	pc.addCols("1.	El suministro  y aplicación de medicamentos hospitalarios es facultad del"+nombreCompania+", por lo que no se permitirá que el paciente o  persona  responsable ingrese estos insumos  al hospital.\n\n2.	La excepción a esta disposición será si el paciente ingresa de manera urgente y esté recibiendo algún medicamento indispensable, que a juicio de su médico tratante no pueda suspender su tratamiento y que el mismo no esté disponible en el país, o en el inventario de la Farmacia; solo entonces será aceptado, por la Dirección Administrativa  y el Médico Tratante, el cual será entregado a la Dirección de Enfermería, quien tramitará la aplicación del mismo luego de su acondicionamiento, facturando solamente el manejo y trámite del mismo.\n\n3.	El ingreso de estos insumos será válido solamente hasta que la Farmacia Hospitalaria logre obtener el (los) medicamento (s) en mención.\n\n4.	La responsabilidad exclusiva del resultado del tratamiento terapéutico de los medicamentos en estas condiciones será del médico tratante.\n\n5.	Es conveniente aclarar, que cuando un paciente es admitido para hospitalización y se da inicio al cumplimiento de las órdenes médicas, los medicamentos y otros insumos sugeridos por las mismas, empezaran a ser facturados a la cuenta del (la) paciente.",3,dCenterFooter.size());

	pc.addCols(" ",0,dCenterFooter.size());
	pc.addCols("",0,dCenterFooter.size());
	pc.addCols(" ",0,dCenterFooter.size());
	
	pc.addCols("Confirmamos que hemos leído, comprendido y aceptado todos los términos y condiciones que constan en el presente documento:",3,dCenterFooter.size());
	pc.addCols(" ",0,dCenterFooter.size());
	
	pc.addCols("Nombre Completo del Paciente:",0,3);
	pc.addBorderCols(cdo.getColValue("nombrePaciente"),3,5, 0.5f, 0.0f, 0.0f, 0.0f);
	pc.addCols("",4,4);
	
	pc.addCols("Firma del Paciente:",0,3);
	pc.addBorderCols("",3,5, 0.5f, 0.0f, 0.0f, 0.0f);
	pc.addCols("",4,4);
	
	pc.addCols("Cédula:",0,3);
	pc.addBorderCols(cdo.getColValue("cedula"),3,5, 0.5f, 0.0f, 0.0f, 0.0f);
	pc.addCols("",4,4);	
	
	
	pc.addCols(" ",0,dCenterFooter.size());
	pc.addCols(" ",0,dCenterFooter.size());
	pc.addCols("Nombre de la Persona Responsable (entiéndase como persona responsable los esposos, padre, madre o tutor):",3,dCenterFooter.size()); 
	pc.addBorderCols(" ",3,dCenterFooter.size(), 0.5f, 0.0f, 0.0f, 0.0f); 

	pc.useTable("main");
	pc.addTableToCols("dCenterFooter",1,dCenterFooter.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);


	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}
//}
%>