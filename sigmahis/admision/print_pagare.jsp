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
sql = " select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) nombrePaciente, decode(p.tipo_id_paciente, 'P',p.pasaporte,p.provincia||'-' ||p.sigla||'-' ||p.tomo||'-' ||p.asiento) cedula, getHabitacion("+compania+","+pacId+","+noAdmision+") as habitacion, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(sysdate,'Day dd \"de\" Month \"de\" yyyy','nls_date_language=spanish') as lat_date from tbl_adm_paciente p, tbl_adm_admision a Where p.pac_id="+pacId+" and p.pac_id = a.pac_id and a.secuencia = "+noAdmision;

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
	String subTitle = "PAGARÉ Nº ____________________";
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
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");


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
		pc.addCols("\n", 1, dHeader.size());
		pc.setFont(10, 0);
		
		pc.addCols("", 1, 1);
		pc.addCols("Importe B/.________________________",0,4);
		pc.addCols(cdo.getColValue("lat_date"),2,4);
		pc.addCols("", 1, 1);
		
		pc.setFont(10, 1);
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("CONDICIONES", 1, dHeader.size());
		pc.setFont(10, 0);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("", 1, 1);
		pc.addCols("_____________________ (__________)  plazos ________________________________ de \n\nB/._______________________________________     (B/._____________________________)",3,8);
		pc.addCols("", 1, 1);
		pc.addCols("\n", 1, dHeader.size());

		
		
		pc.addCols("", 1, 1);
		pc.addCols("Nosotros,",0,1);
		pc.addBorderCols("  ",0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("Cédula Nº",0,1);
		pc.addBorderCols("  ",0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("", 1, 1);
		
		pc.addCols("", 1, 1);
		pc.addCols(" ",0,1);
		pc.addBorderCols("  ",0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("Cédula Nº",0,1);
		pc.addBorderCols("  ",0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("", 1, 1);
		
		pc.addCols("", 1, 1);
		pc.addCols(" ",0,1);
		pc.addBorderCols("  ",0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("Cédula Nº",0,1);
		pc.addBorderCols("  ",0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("", 1, 1);
		
		pc.addCols("", 1, 1);
		pc.addCols("\nMayores de edad y residentes en _________________________________________________________________________________________________________________________________________________________________________________________",0, 8,50.0f);
		pc.addCols("", 1, 1);
		
		pc.addCols("", 1, 1);
		pc.addCols("respectivamente, nos comprometemos a pagar, mancomunada  y solidariamente  al "+_comp.getNombre()+",  sujeto a las  condiciones  arriba  descritas  y más adelante estipuladas, el importe de _________________________________________________________ (B/._____________) valor  recibido  con interés a razón de _____________________ por ciento mensual (_______%), efectivo  el primer  plazo el día ______ de _____________________ de ______________.",3,8);
		pc.addCols("", 1, 1);
		
		
		pc.addCols("", 1, 1);
		pc.addCols("\n\nAsimismo convenimos en pagar saldo deudor, intereses, multas y cualquier otro cargo que sea impuesto por el "+_comp.getNombre()+", cuando seamos requeridos por ellos.",3,8);
		pc.addCols("", 1, 1);
		
		pc.addCols("", 1, 1);
		pc.addCols("\n\nQueda convenido que la falta de pago de las cuotas establecidas en este documento, determinará el vencimiento del plazo de toda la deuda y dará derecho al "+_comp.getNombre()+" a exigir su pago inmediato. De procederse judicialmente, declaro que renuncio a la presentación, al pago de este documento, al protesto, al aviso que ha sido desatendido, a cualquier requerimiento futuro  en caso de mora, al domicilio y a los trámites  del juicio Ejecutivo y convengo en pagar gastos judiciales en caso de cobros por esta vía.",3,8);
		pc.addCols("", 1, 1);
		
		pc.addCols("", 1, 1);
		pc.addCols("\n\nComo constancia de reconocimiento y aceptación firmamos hoy _______________ de ___________________, de ___________ Deudor ______________________________________  Cédula Nº_______________________",3,8);
		pc.addCols("", 1, 1);
		
		
		pc.setFont(10, 1);
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("", 1, 1);
		pc.addCols("CODEUDORES:", 0, dHeader.size()-1);
		pc.setFont(10, 0);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("", 1, 1);
		pc.addCols("1.",0,1);
		pc.addBorderCols("  ",0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("Cédula Nº",0,1);
		pc.addBorderCols("  ",0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("", 1, 1);
		
		pc.addCols("", 1, 1);
		pc.addCols("2.",0,1);
		pc.addBorderCols("  ",0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("Cédula Nº",0,1);
		pc.addBorderCols("  ",0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("", 1, 1);
		
		pc.addCols("", 1, 1);
		pc.addCols("3.",0,1);
		pc.addBorderCols("  ",0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("Cédula Nº",0,1);
		pc.addBorderCols("  ",0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("", 1, 1);
		
		pc.setFont(10, 1);
		pc.addCols("", 1, 1);
		pc.addCols("\nORIGINAL: AL Deudor cuando cancele su deuda.", 0, dHeader.size()-1);
		
		
		
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>