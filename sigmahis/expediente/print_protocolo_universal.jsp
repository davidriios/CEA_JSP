<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.Properties"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
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
CommonDataObject cdo, cdoPacData = new CommonDataObject();

String sql = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = (request.getParameter("desc")==null?"":request.getParameter("desc"));
String fg = request.getParameter("fg");
String id = request.getParameter("id");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

Properties prop = new Properties();

if (fg==null) fg = "PUSP";
if (id==null)id="0";
if ((pacId==null || pacId.equals("")) || (noAdmision==null || noAdmision.equals(""))) throw new Exception("No podemos identificar el paciente, por favor contacte un administrador!");

sql = "SELECT protocolo FROM tbl_sal_protocolo_universal WHERE pac_id="+pacId+" AND admision ="+noAdmision;
if (!id.equals("0")) sql += " and id = "+id;
sql += " order by id desc";
al = SQLMgr.getDataPropertiesList(sql);

Hashtable iTitle = new Hashtable();
iTitle.put("1","Estudios por Imagenes");
iTitle.put("2","Examenes de Laboratorio");
iTitle.put("3","Historia Clínica");
iTitle.put("4","Antibiótico Profilaxis");
iTitle.put("5","Alergias");
iTitle.put("6","Consentimiento Quirúrgico firmado por el médico y paciente");
iTitle.put("7","Consentimiento de Anestesia firmado por el médico y paciente");
iTitle.put("8","Consentimiento de Hemoderivados firmado");
iTitle.put("9","Presentación del Personal Quirúrgico");
iTitle.put("10","Marcación del Sitio Quirúrgico por el Médico con sus iniciales");
iTitle.put("11","Confirmación de Equipos especiales y/o Implantes por la Enfermera de Quiráfano");

Hashtable iFooter = new Hashtable();
iFooter.put("1","Cirujano y Asistentes");
iFooter.put("2","Anestesiologo y asistente");
iFooter.put("3","Instrumentista/circulador,otros");

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String year=fecha.substring(6, 10);
String mon=fecha.substring(3, 5);
String month = null;
String day=fecha.substring(0, 2);
String cTime = fecha.substring(11, 22);
String cDate = fecha.substring(0,11);
String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

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
String title = "EXPEDIENTE";
String subTitle = desc;
String xtraSubtitle = "";

boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 12;
float cHeight = 90.0f;

CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

PdfCreator pc = null;
boolean isUnifiedExp = false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

Vector tblMain = new Vector();
tblMain.addElement("20");
tblMain.addElement("20");
tblMain.addElement("20");
tblMain.addElement("20");
tblMain.addElement("20");

Vector tblFooter = new Vector();
tblFooter.addElement("0.05");
tblFooter.addElement("0.60");
tblFooter.addElement("0.05");
tblFooter.addElement("0.05");
tblFooter.addElement("0.05");
tblFooter.addElement("0.05");
tblFooter.addElement("0.05");
tblFooter.addElement("0.05");

pc.setNoColumnFixWidth(tblMain);
pc.createTable();

pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblMain.size());
pc.setTableHeader(1);

String value = "";
for (int i = 0; i<al.size(); i++) {
	prop = (Properties) al.get(i);
	
	if (i!=0){
		pc.flushTableBody(true);
		pc.addNewPage();
	}
	
	pc.setFont(10, 1);
	if (i!=0){
		pc.addCols(" ",0 ,tblMain.size());
	}
	
	pc.addCols("# "+prop.getProperty("id"),0 ,tblMain.size());
	pc.addCols("Fecha: "+prop.getProperty("fecha_creacion"),0 ,2);
	pc.addCols("Usuario: "+prop.getProperty("usuario_creacion"),0 ,3);
	pc.addCols(" ",0 ,tblMain.size());
	
	pc.addCols("SECCION I: VERIFICACION DEL PROCEDIMIENTO QUIRURGICO",0 ,tblMain.size());
	pc.addCols("",0 ,tblMain.size());
	
	pc.setFont(10, 0);
	
	pc.addBorderCols("LUGAR DE PROCEDENCIA DEL PACIENTE",0 ,4);
	if (prop.getProperty("admitido").equalsIgnoreCase("AA")) value = "Admision Adulto";
	else if (prop.getProperty("admitido").equalsIgnoreCase("SH")) value = "Sala de Hospital";
	else if (prop.getProperty("admitido").equalsIgnoreCase("CU")) value = "Cuarto de Urgencia";
	else if (prop.getProperty("admitido").equalsIgnoreCase("AM")) value = "Admision Ambulatoria";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("1. ¿Se Confirmó verbalmente el nombre del paciente?",0 ,4);
	if (prop.getProperty("aplicar1").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar1").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar1").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("2. ¿Se Confirmó verbalmente la cédula o pasaporte del paciente?",0 ,4);
	if (prop.getProperty("aplicar2").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar2").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar2").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("3. ¿Paciente tiene colocada su pulsera de identificación?",0 ,4);
	if (prop.getProperty("aplicar3").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar3").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar3").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("4. ¿Pulsera de identificación coincide con datos del paciente?",0 ,4);
	if (prop.getProperty("aplicar4").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar4").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar4").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);	
	
	pc.setFont(8, 1);
	pc.addCols("",0 ,tblMain.size());
	pc.addCols("VERIFICACION DE LA DISPONIBILIDAD DE LA DOCUMENTACION REQUERIDA",0 ,tblMain.size());
	pc.addCols("",0 ,tblMain.size());
	pc.setFont(10, 0);
	
	value = "";
	pc.addBorderCols("5. La historia clinica",0 ,4);
	if (prop.getProperty("aplicar5").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar5").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar5").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("6. La evaluación Pre-anestésica",0 ,4);
	if (prop.getProperty("aplicar6").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar6").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar6").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("7. Consentimiento Informado de Sedación y Anestesia,firmado por paciente y médico.",0 ,4);
	if (prop.getProperty("aplicar7").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar7").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar7").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("8. Consentimiento Informado Quirúrgico, firmado por paciente y médico.",0 ,4);
	if (prop.getProperty("aplicar8").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar8").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar8").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("9. Autorizaciones de las compañías de seguro",0 ,4);
	if (prop.getProperty("aplicar9").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar9").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar9").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("10. Exámenes de laboratorio del paciente correcto",0 ,4);
	if (prop.getProperty("aplicar10").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar10").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar10").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "MRI:    ";
	pc.addBorderCols("11. Exámenes de Imagenes del paciente correcto",0 ,tblMain.size());
	if (prop.getProperty("aplicar12").equalsIgnoreCase("S")) value += "SI";
	else if (prop.getProperty("aplicar12").equalsIgnoreCase("N")) value += "NO";
	else if (prop.getProperty("aplicar12").equalsIgnoreCase("NA")) value += "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "R-X:    ";
	if (prop.getProperty("aplicar13").equalsIgnoreCase("S")) value += "SI";
	else if (prop.getProperty("aplicar13").equalsIgnoreCase("N")) value += "NO";
	else if (prop.getProperty("aplicar13").equalsIgnoreCase("NA")) value += "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "USG:    ";
	if (prop.getProperty("aplicar14").equalsIgnoreCase("S")) value += "SI";
	else if (prop.getProperty("aplicar14").equalsIgnoreCase("N")) value += "NO";
	else if (prop.getProperty("aplicar14").equalsIgnoreCase("NA")) value += "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "CAT:    ";
	if (prop.getProperty("aplicar15").equalsIgnoreCase("S")) value += "SI";
	else if (prop.getProperty("aplicar15").equalsIgnoreCase("N")) value += "NO";
	else if (prop.getProperty("aplicar15").equalsIgnoreCase("NA")) value += "N/A";
	pc.addBorderCols(value,0 ,2);
	
	value = "";
	pc.addBorderCols("12. Cruce de Sangre",0 ,4);
	if (prop.getProperty("aplicar16").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar16").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar16").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("13. Cualquier tipo de producto sanguíneo",0 ,4);
	if (prop.getProperty("aplicar17").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar17").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar17").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("14. Implantes",0 ,4);
	if (prop.getProperty("aplicar18").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar18").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar18").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	value = "";
	pc.addBorderCols("15. Dispositivos o equipo especial",0 ,4);
	if (prop.getProperty("aplicar19").equalsIgnoreCase("S")) value = "SI";
	else if (prop.getProperty("aplicar19").equalsIgnoreCase("N")) value = "NO";
	else if (prop.getProperty("aplicar19").equalsIgnoreCase("NA")) value = "N/A";
	pc.addBorderCols(value,0 ,1);
	
	pc.addBorderCols("16. Medicamentos Suministrados",0 ,2);
	pc.addBorderCols(prop.getProperty("medicamentos"),0 ,3);
	
	pc.setFont(10, 1);
	pc.addCols(" ",0 ,tblMain.size());
	pc.addCols("SECCION II: MARCADO DEL SITIO DE LA INTERVENCIÓN",0 ,tblMain.size());
	pc.addCols("",0 ,tblMain.size());
	pc.setFont(10, 0);
	
	pc.addBorderCols("17. Diagnostico", 0, 1);
	pc.addBorderCols(prop.getProperty("codDiag")+" - "+prop.getProperty("descDiag"),0 ,4);
	
	pc.addBorderCols("18. Área de la Cirugía", 0, 1);
	pc.addBorderCols(prop.getProperty("areaCirugia"),0 ,4);
	
	pc.addBorderCols("Fecha de Marcación", 0, 1);
	pc.addBorderCols(prop.getProperty("fecha"), 0, 2);
	pc.addBorderCols("Hora de Marcación", 0, 1);
	pc.addBorderCols(prop.getProperty("hora"), 0, 1);
	
	pc.setFont(10, 1);
	pc.addCols(" ",0 ,tblMain.size());
	pc.addCols("SECCION III: EJECUCIÓN DE LA PAUSA QUIRÚRGICA",0 ,tblMain.size());
	pc.addCols("",0 ,tblMain.size());
	pc.setFont(10, 0);
	
	pc.addBorderCols("Alergias",0 ,1);
	pc.addBorderCols(prop.getProperty("alergias"),0 ,4);
	
	pc.addBorderCols("Procedimiento Quirúrgico Planificado", 0, 1);
	pc.addBorderCols(prop.getProperty("codProc")+" - "+prop.getProperty("descProc"),0 ,4);
	
	pc.addBorderCols("Sitio del Procedimiento Quirúrgico",0 ,1);
	pc.addBorderCols(prop.getProperty("sitioProc"),0 ,4);
	
	pc.addBorderCols("Médico Responsable", 0, 1);
	pc.addBorderCols(prop.getProperty("reg_medico")+" - "+prop.getProperty("nombre_medico"),0 ,4);
	
	pc.addBorderCols("Anestesiólogo", 0, 1);
	pc.addBorderCols(prop.getProperty("reg_anestesiologo")+" - "+prop.getProperty("nombre_anestesiologo"),0 ,4);
	
	pc.addBorderCols("Pediatra", 0, 1);
	pc.addBorderCols(prop.getProperty("reg_pediatra")+" - "+prop.getProperty("nombre_pediatra"),0 ,4);
	
	pc.addBorderCols("Instrumentista", 0, 1);
	pc.addBorderCols(prop.getProperty("instrumentista")+" - "+prop.getProperty("nombre_instrumentista"),0 ,4);
	
	pc.addBorderCols("Circuldor", 0, 1);
	pc.addBorderCols(prop.getProperty("circulador")+" - "+prop.getProperty("nombre_circulador"),0 ,4);
	
	pc.addBorderCols("Asistente Quirúrgico", 0, 1);
	pc.addBorderCols(prop.getProperty("asistente_quirurgico")+" - "+prop.getProperty("nombre_asistente"),0 ,4);
	
	pc.addBorderCols("Personal Adicional", 0, 1);
	pc.addBorderCols(prop.getProperty("p_adicional"),0 ,4);
	
	value = "NO";
	pc.addBorderCols("¿ Ha Sido ejecutada la re-evaluación inmediata antes de la inducción anestésica?", 0, 4);
	if (prop.getProperty("aplicar20").equalsIgnoreCase("S")) value = "SI";
	pc.addBorderCols(value,0 ,1);
	
	pc.addBorderCols("Fecha de Ejecución", 0, 1);
	pc.addBorderCols(prop.getProperty("fechaPausa"), 0, 2);
	pc.addBorderCols("Hora de Ejecución", 0, 1);
	pc.addBorderCols(prop.getProperty("horaPausa"), 0, 1);	
	
	
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);
}
%>