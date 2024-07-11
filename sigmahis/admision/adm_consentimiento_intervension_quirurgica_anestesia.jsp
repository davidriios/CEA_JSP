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
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId());
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

//--------------Query para obtener datos del Paciente ----------------------------------------//
sql = " select nombre_paciente nombrePaciente, decode(p.tipo_id_paciente, 'P',p.pasaporte,p.provincia||'-' ||p.sigla||'-' ||p.tomo||'-' ||p.asiento) cedula, getHabitacion("+compania+","+pacId+","+noAdmision+") as habitacion, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(sysdate,'Day dd \"de\" Month \"de\" yyyy','nls_date_language=spanish') as lat_date ,(select primer_nombre ||' '||primer_apellido from tbl_adm_medico where codigo = a.medico) as nombremedico, pa.nacionalidad, p.residencia_direccion, to_char(sysdate,'month','nls_date_language=spanish') as mes, edad from vw_adm_paciente p, tbl_adm_admision a, tbl_sec_pais pa Where p.pac_id="+pacId+" and p.pac_id = a.pac_id and pa.codigo(+) = p.nacionalidad and a.secuencia = "+noAdmision;

cdo = SQLMgr.getData(sql);
if (cdo == null) cdo = new CommonDataObject();

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
String title = " CONSENTIMIENTO INFORMADO";
String subTitle = "INTERVENCIÓN QUIRURGICA";
String xtraSubtitle = "";

boolean displayPageNo = false;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 12;
float cHeight = 90.0f;
	
PdfCreator pc = null;
boolean isUnifiedExp = false;
pc = (PdfCreator) session.getAttribute("printConsentUnico");
if(pc == null){ 
  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
  isUnifiedExp = true;
}

Vector tblImg = new Vector();
tblImg.addElement("1");
pc.setNoColumnFixWidth(tblImg);
pc.createTable();

pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),50.0f,1);
pc.addTable();

Vector dHeader = new Vector();
dHeader.addElement("0.08");
dHeader.addElement("0.23");
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

pc.setFont(9, 1);
pc.addCols(title, 1, dHeader.size());
pc.addCols(subTitle, 1, dHeader.size());
pc.addCols(xtraSubtitle, 1, dHeader.size());
pc.addCols("", 1, dHeader.size());

pc.setVAlignment(1);

pc.setFont(8, 0);
pc.addCols("Panamá, República de Panamá a los días "+day+" del mes de "+cdo.getColValue("mes"," ")+" del "+year+". Quien suscribe, "+cdo.getColValue("nombrePaciente"," ")+", portador(a) de la cedula de identidad personal numero "+cdo.getColValue("cedula"," ")+" de "+cdo.getColValue("edad"," ")+" años de edad, por este medio autorizo al Cuerpo Médico de este Hospital para que se practique la siguiente operación o procedimiento quinirgico (o cualquier otra intervención que considere indicada).\nIndividualizarla:",3, dHeader.size());
pc.addBorderCols("\n",1, dHeader.size(),0.5f,0.0f,0.0f,0.0f);

pc.addCols("", 1, dHeader.size(), 10.2f);
pc.addCols("Consiento también, a que se me realicen el tratamiento que consideren convenientes Antes de proceder a firmar éste documento asegúrese de:", 3, dHeader.size());

pc.addCols("      1.",0,1);
pc.addCols("Haber sido informado por su médico sobre su diagnóstico, pronóstico y alternativas de tratamiento, así como los posibles riesgos y complicaciones que pudieran presentarse durante y posteriormente a la intervención que se les practicará.",3, dHeader.size()-1);
pc.addCols("      2.",0,1);
pc.addCols("Si le quedan dudas sobre el punlo anterior o no comprende el contenido de éste documento PREGUNTE a su(s) médico(s).",3, dHeader.size()-1);
pc.addCols("      3.",0,1);
pc.addCols("Si aun así le quedan dudas o preguntas no contestadas a satisfacción. NO FIRME ESTE CONSENTIMIENTO.",3, dHeader.size()-1);

pc.setFont(9, 1);
pc.addCols("CONSENTIMIENTO PARA PROCEDIMIENTOS QUIRÚRGICOS", 1, dHeader.size());

pc.setFont(8, 0);
pc.addCols("      1.",0,1);
pc.addCols("Reconozco que durante el curso de mi operación, cuidado post-operatorio, tratamiento médico, anestesia, analgesia u otro procedimiento existen condiciones imprevistas que pueden necesitar procedimientos diferentes o adicionales a los que hayan sido descritos en el presente documento, por esta razón autorizo a mi(s) médico(s) y a sus asistentes o deslgnados, a reallzar dicho procedimiento(s) que sea(n) necesario(s) en el buen ejercicio profesional de los mlsmos. La autorización que doy se extiende al tratamiento de todas las condiciones que requieren tratamiento inmediato y que surian como imprevistos durante o después del procedimiento o cirugia.",3, dHeader.size()-1);

pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addCols("      2.",0,1);
pc.addCols("He sido informado(a) que existen riesgos significativos que pudieran surgir en el curso de la opêración y en el post-operatorio tales como las reacciones alérgicas, coágulos en las venas y pulmones, pérdida de sangre, infecciones y paro cardiaco, que pueden llevarme a la muerte, incapacidad parcial o permanente y de suscitaise deben ser atendidos.",3, dHeader.size()-1);

pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addCols("      3.",0,1);
pc.addCols("Reconozco que en los casos en donde son necesarias incisiones y/o suturas pueden ocurrir infecciones, dolor en la herida, formación de hernias (debilidad o abombamiento) y que estas complicaciones puedan requerir tratamientos o procedimientos futuros.",3, dHeader.size()-1);

pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addCols("      4.",0,1);
pc.addCols("Reconozco que en la lista de riegos y complicaciones de este documento pueden no estar incluidos todos los riegos posibles o conocidos de la cirugia o procedimiento que se me planifica realizar, pero que la misma expone las complicaciones más comunes o severas. Reconozco que en el futuro pueden emerger complicaciones no mencionadas en este documento.",3, dHeader.size()-1);

pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addCols("      5.",0,1);
pc.setFont(9, 1);
pc.addCols("Reconozco que mi(s) médico(s) me ha(n) señalado los beneficios razonables esperados pero no me ha(n) dado garantía ni seguridad del resultado que puede obtenerse de la cirugía o procedimiento ni en la cura de mi condición.",3, dHeader.size()-1);

pc.setFont(8, 0);
pc.addCols("      6.",0,1);
pc.addCols("Autorizo a mi médico(s), para que según los procedimientos usuales dispongan de los teiidos o partes de los mismos que me sean removidos quirúrgicamente.",3, dHeader.size()-1);

pc.addCols("", 1, dHeader.size(), 10.2f);
pc.setFont(9, 1);
pc.addCols("7.    ENTIENDO QUE CUALQUIER ASPECTOS DE ESTE DOCUMENTO QUE YO NO COMPRENDA ME DEBE SER EXPLICADO CON MAYORES DETALLES PREGUNTÁNDOLE A MI(S) MÉDICO(S).", 1, dHeader.size());
pc.addCols("", 1, dHeader.size(), 10.2f);

pc.setFont(8, 0);
pc.addCols("      8.",0,1);
pc.addCols("Certifico que mi(s) médico me ha(n) dado la oportunidad de hacer preguntas y me ha(n) informado del carácter y naturaleza del (los) procedimiento(s) médico quirurgico(s) propueslo(s), de los beneficios que obtendrfa de los mismos, incluyendo las consecuencias de la ausencia de tratamiento. Me ha(n) informado también de las posibles complicaciones, riesgos conocidos y de las formas alternas de tralamiento.",3, dHeader.size()-1);
pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addCols("      9.",0,1);
pc.addCols("Certifico que tengo la suficiente información para dar éste consentimiento y que mi(s) médico(s) me ha(n) preguntado si quiero una información más detallada, pero estoy satisfecho(a) con las explicaciones que me ha(n) dado y no necesito más información.",3, dHeader.size()-1);
pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addCols("Declaro: Que he leído/comprendido la información precedente, que he sido informado por él médico de los riesgos del procedimiento, que me ha explicado las posibles alternativas y que sé que, en cualquier momento, puedo revõcar mi consentimiento sin dar explicación alguna.\nEstoy satisfecho con la información recibida, he podido formular toda clase de preguntas que he crefdo conveniente y me ha aclarado todas las dudas planteadas.", 3, dHeader.size());
pc.addCols("", 1, dHeader.size(), 10.2f);
pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addBorderCols("Nombre del Paciente o quien Represente",0, 4,0.0f,0.5f,0.0f,0.0f);
pc.addCols(" ",0, 1);
pc.addBorderCols("Firma del Paciente o quien Representa",0, 5,0.0f,0.5f,0.0f,0.0f);
pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addCols("Cédula:", 0, 1);
pc.addBorderCols(" ",0, 1,0.5f,0.0f,0.0f,0.0f);
pc.addCols("", 1, dHeader.size()-2, 10.2f);

pc.addCols("Teléfono:", 0, 1);
pc.addBorderCols(" ",0, 1,0.5f,0.0f,0.0f,0.0f);
pc.addCols("", 1, dHeader.size()-2, 10.2f);

pc.addCols("Dirección:", 0, 1);
pc.addBorderCols(" ",0, 1,0.5f,0.0f,0.0f,0.0f);
pc.addCols("", 1, dHeader.size()-2, 10.2f);

pc.addCols("", 1, dHeader.size(), 10.2f);
pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addBorderCols("Médico intervencionista",0, 4,0.0f,0.5f,0.0f,0.0f);
pc.addCols(" ",0, 1);
pc.addBorderCols("Fifma del médico intervencionista",0, 5,0.0f,0.5f,0.0f,0.0f);
pc.addCols("", 1, dHeader.size(), 10.2f);

pc.setFont(8, 1);
pc.addCols("Nota: En caso de menores de edad, discapacitados, la autorización debe firmada por sus padres y en defecto porsus representantes.", 0, dHeader.size());

pc.addTable();
if(isUnifiedExp){
  pc.close();
  response.sendRedirect(redirectFile);
}  
%>