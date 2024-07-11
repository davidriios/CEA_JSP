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
sql = " select nombre_paciente nombrePaciente, decode(p.tipo_id_paciente, 'P',p.pasaporte,p.provincia||'-' ||p.sigla||'-' ||p.tomo||'-' ||p.asiento) cedula, getHabitacion("+compania+","+pacId+","+noAdmision+") as habitacion, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(sysdate,'Day dd \"de\" Month \"de\" yyyy','nls_date_language=spanish') as lat_date ,(select primer_nombre ||' '||primer_apellido from tbl_adm_medico where codigo = a.medico) as nombremedico, pa.nacionalidad, p.residencia_direccion from vw_adm_paciente p, tbl_adm_admision a, tbl_sec_pais pa Where p.pac_id="+pacId+" and p.pac_id = a.pac_id and pa.codigo(+) = p.nacionalidad and a.secuencia = "+noAdmision;

cdo = SQLMgr.getData(sql);
//al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	 String fecha2 = CmnMgr.getCurrentDate("dd/mm/yyyy");
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
	String subTitle = "CONSENTIMIENTO PARA OPERACIÓN, ADMINISTRACION  DE ANESTESIA Y OTROS PROCEDIMIENTOS";
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
		dHeader.addElement("0.23");
		dHeader.addElement("0.08");
		dHeader.addElement("0.12");
		dHeader.addElement("0.10");
		dHeader.addElement("0.07");
		dHeader.addElement("0.05");
		dHeader.addElement("0.10");
		dHeader.addElement("0.05");
		dHeader.addElement("0.10");
		dHeader.addElement("0.10");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		pc.setFont(10, 1);

		pc.addCols(title, 1, dHeader.size(),15.2f);
		pc.addCols(subTitle, 1, dHeader.size());
		pc.addCols(xtraSubtitle, 1, dHeader.size());
		pc.addCols("", 1, dHeader.size(), 10.2f);

        pc.setVAlignment(0);
		
		pc.addCols("\n", 1, dHeader.size());
		pc.setFont(10, 0);
	
		pc.addBorderCols("Fecha: "+fecha2, 3, 2, 0.5f,0.0f,0.0f,0.0f);
		pc.addCols("",0, 4);
		pc.addCols("Hora: ______A.M.    ______P.M. ",2, 4);
		
		pc.addCols("\n", 1, dHeader.size());

		pc.setFont(9, 0);
		pc.addCols("1. Por este medio autorizo expresamente  al Dr.__________________________ y a cualquiera que él asigne como asociados y/o ",3, dHeader.size());
		
		pc.addCols(" asistentes,  para  practicar a",3,1);
		pc.addBorderCols(cdo.getColValue("nombrePaciente"),3, 8,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",0, 1,0.5f,0.0f,0.0f,0.0f);

		pc.addCols("el siguiente  examen y/o tratamiento y/o operación (naturaleza del procedimiento (s) a seguir",3,dHeader.size());
		
		pc.addBorderCols("\n",0, dHeader.size(),0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("\n",0, dHeader.size(),0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("\n",0, dHeader.size(),0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("\n",0, dHeader.size(),0.5f,0.0f,0.0f,0.0f);
		
		pc.addCols(" y, si surgiera  en el curso  de la operaciones y/o exámenes y/o tratamientos, o posterior a ellos, cualquier condición, complicación que -\"a su juicio\"- requiera  intervención, procedimientos o tratamientos  diferentes a los antes  asignados,  solicito y autorizo expresamente a dicho facultativo, sus asistentes y/o asociados  hacer  lo que estime  más conveniente.",3, dHeader.size());
		
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("2.	La naturaleza y propósito de la operación, posibles métodos alternativos de tratamiento, los riesgos involucrados y la posibilidad de complicaciones, me han sido plenamente explicados. Acepto que ninguna garantía se me ha dado de los resultados que se puedan obtener.",3, dHeader.size());
		
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("3.	Doy mi consentimiento para la administración de anestésicos por los anestesiólogos designados por el facultativo  arriba mencionado  con la excepción de",3, dHeader.size());
		
		pc.addBorderCols("(\"Ninguno\" o nombre de la anestesia)",1,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
		
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("4.	Doy mi consentimiento para la disposición de tejidos, partes o miembro que podrán ser desechados por autoridades  de HOSPITAL CHIRIQUI, S.A. o del Patólogo del mismo.",3, dHeader.size());
		
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("5.	Autorizo la administración de sangre o sus derivativos, tal como sea conveniente según el buen juicio del cirujano que atiende el caso, sus asistentes y/o asociados. Entiendo que las transfusiones de sangre y/o derivados, no siempre dan los resultados con los éxitos deseados y que existe la posibilidad de efectos adversos.",3, dHeader.size());
		
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("6.	Las autorizaciones y facultades antes consignadas las hago extensivas a la ADMINISTRACIÓN DEL HOSPITAL CHIRIQUI, S.A.",3, dHeader.size());
		
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("En caso de cirugía Laparoscópica he sido ampliamente informado sobre el procedimiento de la misma. De no ser posible acepto el procedimiento convencional  indicado.\n\nCertifico que he leído y entiendo completamente el consentimiento para examen y/o tratamiento y/o operación arriba  mencionados, que las explicaciones anotadas me fueron dadas, que todos los espacios en blanco o declaraciones que requieran inserción o ser completados fueron llenados, y que los párrafos no aplicables, de existir fueron totalmente  eliminados antes de mi firma.",3, dHeader.size());
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("\n", 1, dHeader.size());
		
		
		pc.addCols(" ",1,4);
		pc.addCols(" ",1,2);
		pc.addCols(cdo.getColValue("nombrePaciente"),1,4);
		
		pc.addBorderCols("TESTIGO",1,4,0.0f,0.5f,0.0f,0.0f);
		pc.addCols(" ",1,2);
		pc.addBorderCols("NOMBRE DEL PACIENTE",1,4,0.0f,0.5f,0.0f,0.0f);
		
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("Cuando el paciente  no pueda firmar o si es menor de edad, complementar  lo siguiente: _____________________________ El Paciente es menor de edad, tiene _____años, o no puede firmar por_____________________________________________",3, dHeader.size());
		
		
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("",1,4);
		pc.addCols(" ",1,2);
		pc.addBorderCols("FIRMA DEL PADRE O PERSONA AUTORIZADA PARA FIRMAR EN NOMBRE DEL PACIENTE",2,4,0.0f,0.5f,0.0f,0.0f);
		
		
		


	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>