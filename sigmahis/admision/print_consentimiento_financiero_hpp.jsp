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

<!-- Desarrollado por: José A. Acevedo C.      -->
<!-- Reporte: "Informe de Pacientes Fallecidos"-->
<!-- Reporte: ADM3087                          -->
<!-- Clínica Hospital San Fernando             -->
<!-- Fecha: 25/02/2010                         -->

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
String pac_id = request.getParameter("pac_id");

String compania = (String) session.getAttribute("_companyId");

//--------------Query para obtener datos de Pacientes Fallecidos----------------------------------------//
sql = " select nombre_paciente nombrePaciente, decode(tipo_id_paciente, 'P',pasaporte,provincia||'-' ||sigla||'-' ||tomo||'-' ||asiento) cedula from vw_adm_paciente Where pac_id="+pac_id;

cdo = SQLMgr.getData(sql);
//al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";

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

	float width = 52* 8.5f;//612 
	float height = 43 * 14f;//792
	boolean isLandscape = false;
	float leftRightMargin = 50.0f;//30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONSENTIMIENTO FINANCIERO";
	String subTitle = "ADMISIÓN";
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	
	//------------------------------------------------------------------------------------

      
PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


//control imgae
		
		Vector tblImg = new Vector();
		tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();
		
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),90.0f,1);
		pc.addTable();
		
		Vector dHeader = new Vector();
		dHeader.addElement("6"); 
		dHeader.addElement("40");
		dHeader.addElement("45");
		dHeader.addElement("26");
		
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
			
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);
		
		pc.setFont(10, 1);
		
		pc.addCols(title, 1, dHeader.size(),15.2f);
		pc.addCols(subTitle, 1, dHeader.size());
		pc.addCols("", 1, dHeader.size(), 10.2f);

		pc.setFont(8, 0);
        pc.setVAlignment(0);
		
		pc.addCols("1.", 0, 1);
		pc.addCols("Reconocemos que el hecho de ser admitido en cualquier forma en el Hospital Punta Pacífica o en cualquiera de sus entidades afiliadas, par recibir tratamiento, procedimientos médicos o quirúrgicos, generarán gastos que se reflejarán y se nos comunicarán en un estado de cuenta, el cual desde este momento nos comprometemos a cubrir en su totalidad.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("2.", 0, 1);
		pc.addCols("Nos comprometemos a que en este caso de utilizar un seguro de hospitalización, cualquier suma que éste seguro no cubra, será pagada por nosotros una ves nos sea notificada, por parte del Hospital Punta Pacífica o por la Compañía de Seguros, la suma adeudada.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("3.", 0, 1);
		pc.addCols("Nos comprometemos a hacer todos los abonos al estado de cuenta que nos solicite el Hospital Punta Pacífica, durante la estadía de EL PACIENTE en sus instalaciones.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("4.", 0, 1);
		pc.addCols("Reconocemos, que al expedirse el estado de cuenta puede que el mismo no incluya la totalidad de los cargos y honorarios médicos generados a la fecha de corte, ya sea porque los mismos no han sido procesados o presentados por los médicos o proveedores.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("5.", 0, 1);
		pc.addCols("En caso de no estar en capacidad par cubrir los gastos ocasionados durante la hospitalización, expresamente autorizamos al Hospital Punta Pacífica a trasladar al PACIENTE a una institución pública de salud.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("6.", 0, 1);
		pc.addCols("De requerir traslado a otra institución por cualquier motivo, cancelaremos el saldo del estado d cuenta antes del traslado.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("7.", 0, 1);
		pc.addCols("Por este medio autorizamos expresamente y de manera irrevocable al Hospital Punta Pacífica, sus representantes, funcionarios o agentes a solicitar información e investigar nuestro historial de crédito en cualquier agencia de información de datos y de referencias crediticias, en cualquier momento y cuantas veces lo requiera, sin solicitarnos autorización cada vez que lo haga.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("8.", 0, 1);
		pc.addCols("Autorizamos al Hospital Punta Pacífica a proporcionar nuestro historial de crédito a cualquier agente económico y agencia de información de datos y de referencias crediticias (APC) según su criterio.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("9.", 0, 1);
		pc.addCols("Reconocemos que el Hospital Punta Pacífica, sus representantes, funcionarios o agentes no serán responsables por errores en los datos existentes en nuestro historial de crédito ni por posibles daños y perjuicios que lo contenido en el mismo pueda ocasionar.", 3, 3);
		pc.addCols("\n", 1, dHeader.size(),30.2f);
		
		pc.addCols("10.", 0, 1);
		pc.addCols("Autorizamos al Hospital Punta Pacífica a suministrar a la Compañía de Seguros correspondientes, toda a información médica u otra información relacionada a mi Historial Médico requerido para el análisis de cualquier reclamación para el pago por los servicios brindados. Esta autorización se extiende a la autorización para reproducir fotocopias a petición de la Compañía de Seguros correspondientes.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols("11.", 0, 1);
		pc.addCols("Por este medo reconozco que he recibido el documento de los Derechos y Responsabilidades del Paciente. Entiendo que existe personal profesional disponible para explicar este documento.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
				
		pc.setVAlignment(2);		
				
		pc.addCols("Aceptamos todos los términos y condiciones que constan en el presente documento:\n\n", 0, dHeader.size());
		pc.addCols("Nombre Completo del Paciente", 0, 2, 15.2f);
		pc.addBorderCols(cdo.getColValue("nombrePaciente"), 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20f);
		//pc.addCols(" ", 0, 1);
		
		
		pc.addCols("Firma del Paciente", 0, 2, 15.2f);
		pc.addBorderCols("", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols("Cédula ", 0, 2, 15.2f);
		pc.addBorderCols(cdo.getColValue("cedula"), 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addBorderCols("Nombre Completo de la Persona Responsable (entiéndase como persona responsable los esposos, padre, madre o tutor)\n\n", 0, dHeader.size(), 0.0f, 0.0f, 0.0f, 0.0f, 40.2f);
		
		pc.addCols("Firma de la persona responsable", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols("Cédula", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols(" ", 1, dHeader.size(),10.2f);
		
		pc.addCols("Firma de ruego (se hará únicamente cuando la persona no pueda firmar y le pida a alguien que lo haga por ella)",0, dHeader.size());
		

        pc.addCols("Nombre completo del Firmante", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		
		pc.addCols("Firma", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols("Cédula ", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);


		//Testigo 1
		pc.addCols("Nombre completo del Testigo 1", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);
		
		pc.addCols("Firma del Testigo 1", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols("Cédula ", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		
		pc.addCols("\n", 1, dHeader.size(),200.2f);
		
		
		
		//Testigo 2
		pc.addCols("Nombre completo del Testigo 2", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);
		
		pc.addCols("Firma del Testigo 2", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols("Cédula ", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		//Huella digital
		pc.addCols("Huella digital del paciente", 0, dHeader.size(), 40.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.5f, 0.5f, 0.5f,60.2f);
		pc.addCols(" ", 0, 2);
	
		pc.addCols("En este caso de paciente inconsciente o incapaz de tomar decisiones al momento de admisión firmarán dos testigos el presente documento (Si viene acompañado uno de los testigos debe ser el acompañante)\n\n", 0, dHeader.size(), 30.2f);
	   	   
	   	//Testigo 1
		pc.addCols("Nombre completo del Testigo 1", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);
		
		pc.addCols("Firma del Testigo 1", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols("Cédula ", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
	   
	   	pc.addCols(" ", 0, dHeader.size(),20.0f);
		
	   //Testigo 2
	   	pc.addCols("Nombre completo del Testigo 2", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);
		
		pc.addCols("Firma del Testigo 2", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols("Cédula ", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		//Para el uso del hospital
		pc.addCols("Para el HOSPITAL PUNTA PACÍFICA\n\n", 0, dHeader.size(), 30.2f);
		
		pc.addCols("Nombre completo del Funcionario", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);
		
		pc.addCols("Firma del Funcionario", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols("Cédula del Funcionario", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols("\n\n\nFiador Solidario: \n\n\nPor este medio me comprometo irrevocablemente ante el Hospital Punta Pacífica a quien éste designe, a pagar solidariamente la obligación contraída mediante este documento en el caso que no sea pagada por el Paciente o el Responsable del Paciente.", 0, dHeader.size());
		
		pc.addCols("Nombre completo", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);
		
		pc.addCols("Firma del Fiador Solidario", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols("Cédula o Pasaporte del Fiador", 0, 2, 15.2f);
		pc.addBorderCols(" \n\n\n\n\n\n", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
		
		pc.addCols("Fecha: ", 0, 2);
		pc.addBorderCols("Panamá, "+cDateTime, 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 30.2f);
		pc.addCols(" ", 0, 1, 15.2f);
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>