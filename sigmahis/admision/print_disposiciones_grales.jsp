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
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

String compania = (String) session.getAttribute("_companyId");

//--------------Query para obtener datos del Paciente ----------------------------------------//
sql = " select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) nombrePaciente, decode(p.tipo_id_paciente, 'P',p.pasaporte,p.provincia||'-' ||p.sigla||'-' ||p.tomo||'-' ||p.asiento) cedula, getHabitacion("+compania+","+pacId+","+noAdmision+") as habitacion, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso from tbl_adm_paciente p, tbl_adm_admision a Where p.pac_id="+pacId+" and p.pac_id = a.pac_id and a.secuencia = "+noAdmision;

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
	String title = " ADMISIÓN";
	String subTitle = "DISPOSICIONES GENERALES";
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;

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
		
		pc.setFont(10, 0);
		
		pc.addCols("1.",0,1);
		pc.addCols("EL HORARIO DE VISITAS ESTABLECIDO ES HASTA LAS 9:00PM, SOLICITAMOS A LOS FAMILIARES RESPETAR ESTE HORARIO POR CONSIDERACION Y BIENESTAR DE LOS DEMAS PACIENTES HOSPITALIZADOS.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("2.",0,1);
		pc.addCols("AGRADECEMOS EVITAR LA VISITA DE BEBES O NIÑOS PEQUEÑOS A LAS HABITACIONES COMPARTIDAS QUE PUEDAN PERTURBAR LA TRANQUILIDAD Y EL REPOSO DE LOS DEMAS PACIENTES.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("3.",0,1);
		pc.addCols("ES INDISPENSABLE QUE LOS VISITANTES MANTENGAN EL SILENCIO Y EL ORDEN EN LOS PASILLOS Y HABITACIONES. LOS FAMILIARES DEBERAN ESPERAR EN LA SALA DE ESPERA CORRESPONDIENTES.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("4.",0,1);
		pc.addCols("NO SE PERMITE INGERIR ALIMENTOS EN LOS PASILLOS, AREAS COMUNES O SALA DE ESPERA. FAVOR DIRIGIRSE A LA CAFETERIA.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("5.",0,1);
		pc.addCols("FUMAR ES NOCIVO PARA LA SALUD. POR LO QUE NOS ESFORZAMOS PARA EVITAR QUE LAS PERSONAS NO FUMEN DENTRO DE NUESTRAS INSTALACIONES.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("6.",0,1);
		pc.addCols("EL HOSPITAL NO SE HACE RESPONSABLE POR LOS ARTICULOS DE VALOR QUE PERMANEZCAN EN LA HABITACION.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("7.",0,1);
		pc.addCols("NO ESTA PERMITIDO EL USO DE ADHESIVOS O CLAVOS EN DECORACIONES DE PAREDES O PUERTAS.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("8.",0,1);
		pc.addCols("CUALQUIER DAÑO A LA INFRAESTRUCTURA DE LA HABITACION OCASIONADA POR LA COLOCACION DE ARREGLOS DECORATIVOS O USO INDEBIDO DE LOS BIENES, SERA RESPONSABILIDAD DEL PACIENTE.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("9.",0,1);
		pc.addCols("NO ESTA PERMITIDO INGRESAR A LAS HABITACIONES APARATOS ELECTRODOMESTICOS O MOBILIARIOS.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("10.",0,1);
		pc.addCols("TODO EL MOBILIARIO, ROPA Y ARTICULOS QUE SE LE ENTREGA EN LA HABITACION ES REVISADO E INVENTARIADO DIARIAMENTE. POR LO QUE CUALQUIER PERDIDA O DAÑO A LOS MISMOS SERA ASUMIDO POR EL PACIENTE.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("11.",0,1);
		pc.addCols("TODAS NUESTRAS INSTALACIONES TIENEN AIRE ACONDICIONADO PERMANENTE, AGRADECEMOS MANTENER LAS VENTANAS CERRADAS A FIN DE EVITAR EL ESCAPE DE ENERGIA Y LA ENTRADA DE INSECTOS, POLVO O ROEDORES A LA HABITACION.",3, 9);
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("FIRMA DEL PACIENTE: ____________________________",0, dHeader.size());
		pc.addCols("HAB. No.: "+cdo.getColValue("habitacion"),0, dHeader.size());
		pc.addCols("FECHA INGRESO: "+cdo.getColValue("fecha_ingreso"),0, dHeader.size());

	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>