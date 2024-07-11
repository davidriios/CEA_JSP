<%// @ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="cdoUsr" scope="page" class="issi.admin.CommonDataObject" />
<%@ include file="../common/pdf_header.jsp"%>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

Properties prop = new Properties();
CommonDataObject cdo, cdoPacData  = new CommonDataObject();

String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if(fp == null) fp = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"' and id > 0");
if(prop == null) prop = new Properties();

String fecha = cDateTime;
String year=fecha.substring(6, 10);
String mon=fecha.substring(3, 5);
String month = null;
String day=fecha.substring(0, 2);
String cTime = fecha.substring(11, 22);
String cDate = fecha.substring(0,11);
String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
float height = 72 * 14f;//792
boolean isLandscape = false;
float leftRightMargin = 5.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subTitle = "REPORTE DE PROBLEMAS IDENTIFICADOS EN EL PACIENTE";
String xtraSubtitle = "";
	
boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 5;
float cHeight = 90.0f;

CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");

if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
}
if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
}
	
PdfCreator pc = null;
boolean isUnifiedExp = false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
  
if(pc == null){
    pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
    isUnifiedExp = true;
}

Vector dHeader = new Vector();
dHeader.addElement("10"); 
dHeader.addElement("10");
dHeader.addElement("2");
dHeader.addElement("18");
dHeader.addElement("2");
dHeader.addElement("18");
dHeader.addElement("2");
dHeader.addElement("18");
dHeader.addElement("2");
dHeader.addElement("18");

Vector tblGPCA = new Vector();
tblGPCA.addElement("8"); //g
tblGPCA.addElement("17");
tblGPCA.addElement("8"); //p
tblGPCA.addElement("17");
tblGPCA.addElement("8"); //c
tblGPCA.addElement("17");
tblGPCA.addElement("8"); //a
tblGPCA.addElement("17");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
pc.setTableHeader(1);

cdo = SQLMgr.getData("select p.sexo, p.edad, p.edad_mes, nvl(get_sec_comp_param("+compania+", 'SAL_PED_EDAD'), 0) edad_ped, nvl(get_sec_comp_param("+compania+", 'SAL_ADO_EDAD'), 0) edad_ado, nvl(get_sec_comp_param("+compania+", 'SAL_TERCERA_EDAD'), 0) edad_3ra, (select e.formulario from tbl_sal_nota_eval_enf_urg e where e.pac_id = p.pac_id and e.admision = "+noAdmision+" and nota is not null and e.id > 0 and rownum = 1) formulario, (select usuario_creacion from tbl_sal_nota_eval_enf_urg where pac_id = p.pac_id and admision = "+noAdmision+" and id > 0 and tipo_nota = '"+fg+"') as usuario_creacion from vw_adm_paciente p where p.pac_id = "+pacId);
if (cdo == null) cdo = new CommonDataObject();

if (cdo == null) {
    cdo = new CommonDataObject();
    cdo.addColValue("codigo_diag","NA");
    cdo.addColValue("desc_diag","NA");
    cdo.addColValue("edad","0");
}
int edad = Integer.parseInt(cdo.getColValue("edad"));
int edadMes = Integer.parseInt(cdo.getColValue("edad_mes"));

if (edad > 0 && edad < 4) {
  edadMes = edad * 12 + edadMes;
} else if (edad >= 4) {
   edadMes = 0;
}

String formulario = cdo.getColValue("formulario", "-1");
String output = "";
    
pc.setFont(10,1);
pc.addCols("EVALUACIÓN INICIAL I",0,dHeader.size(),15f,Color.gray);
pc.addCols(" ",1,dHeader.size(),7f);

if (prop.getProperty("neurologico0").equalsIgnoreCase("a")) output = "Normal";
else {
  if (prop.getProperty("neurologico1").equalsIgnoreCase("l")) output = "Letárgico";
  if (prop.getProperty("neurologico2").equalsIgnoreCase("c")) output += ", Confuso";
  if (prop.getProperty("neurologico3").equalsIgnoreCase("i")) output += ", Inconsciente";
  if (prop.getProperty("neurologico4").equalsIgnoreCase("d")) output += ", Desorientado";
  if (prop.getProperty("neurologico5").equalsIgnoreCase("co")) output += ", Convulsiones";
  if (prop.getProperty("neurologico6").equalsIgnoreCase("p")) output += ", Parálisis";
  if (prop.getProperty("neurologico7").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Neurológico: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("neurologico7").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros1"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("cardiovascular0").equalsIgnoreCase("n")) output = "Normal";
else {
  if (prop.getProperty("cardiovascular1").equalsIgnoreCase("t")) output = "Tarquicadia";
  if (prop.getProperty("cardiovascular2").equalsIgnoreCase("b")) output += ", Bradicardia";
  if (prop.getProperty("cardiovascular3").equalsIgnoreCase("p")) output += ", Palpitación";
  if (prop.getProperty("cardiovascular4").equalsIgnoreCase("d")) output += ", Dolor en el Pecho";
  if (prop.getProperty("cardiovascular5").equalsIgnoreCase("m")) output += ", Marcapaso";
  if (prop.getProperty("cardiovascular6").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Cardiovascular: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("cardiovascular6").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros2"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("respiracion0").equalsIgnoreCase("n")) output = "Normal";
else {
  if (prop.getProperty("respiracion1").equalsIgnoreCase("t")) output = "Tos";
  if (prop.getProperty("respiracion2").equalsIgnoreCase("a")) output += ", Aleteo Nasal";
  if (prop.getProperty("respiracion3").equalsIgnoreCase("d")) output += ", Disnea";
  if (prop.getProperty("respiracion4").equalsIgnoreCase("ap")) output += ", Apnea";
  if (prop.getProperty("respiracion5").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Estado Respiratorio: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("respiracion5").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros3"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("get4").equalsIgnoreCase("no")) output = "Normal";
else {
  if (prop.getProperty("get1").equalsIgnoreCase("v")) output = "Vómito";
  if (prop.getProperty("get2").equalsIgnoreCase("u")) output += ", Úlceras";
  if (prop.getProperty("get3").equalsIgnoreCase("d")) output += ", Dolor abdominal";
  if (prop.getProperty("get4").equalsIgnoreCase("n")) output += ", Náusea";
  if (prop.getProperty("get5").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("G.E.T Gastro-intestinal: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("get5").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros4"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("esquel0").equalsIgnoreCase("n")) output = "Normal";
else {
  if (prop.getProperty("esquel1").equalsIgnoreCase("g")) output = "Golpe";
  if (prop.getProperty("esquel2").equalsIgnoreCase("t")) output += ", Trauma";
  if (prop.getProperty("esquel3").equalsIgnoreCase("a")) output += ", Adorcimiento en extremidades";
  if (prop.getProperty("esquel4").equalsIgnoreCase("e")) output += ", Edemas en extremidades";
  if (prop.getProperty("esquel5").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Musculo-esqueletico: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("esquel5").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros5"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("piel11").equalsIgnoreCase("n")) output = "Normal";
else {
  if (prop.getProperty("piel1").equalsIgnoreCase("m")) output = "Moteado";
  if (prop.getProperty("piel2").equalsIgnoreCase("c")) output += ", Cianosis";
  if (prop.getProperty("piel3").equalsIgnoreCase("d")) output += ", Diaforesis";
  if (prop.getProperty("piel4").equalsIgnoreCase("h")) output += ", Herida";
  if (prop.getProperty("piel5").equalsIgnoreCase("he")) output += ", Hematoma";
  if (prop.getProperty("piel6").equalsIgnoreCase("i")) output += ", Ictericia";
  if (prop.getProperty("piel7").equalsIgnoreCase("u")) output += ", Úlceras";
  if (prop.getProperty("piel8").equalsIgnoreCase("q")) output += ", Quemaduras";
  if (prop.getProperty("piel9").equalsIgnoreCase("er")) output += ", Eritema";
  if (prop.getProperty("piel10").equalsIgnoreCase("ex")) output += ", Exantema";
  if (prop.getProperty("piel11").equalsIgnoreCase("p")) output += ", Pálido";
  if (prop.getProperty("piel12").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Tegumentos (Piel): ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("piel12").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros6"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("psico4").equalsIgnoreCase("n")) output = "Normal";
else {
  if (prop.getProperty("psico0").equalsIgnoreCase("a")) output = "Ansioso";
  if (prop.getProperty("psico1").equalsIgnoreCase("d")) output += ", Deprimido";
  if (prop.getProperty("psico2").equalsIgnoreCase("h")) output += ", Hostil";
  if (prop.getProperty("psico3").equalsIgnoreCase("ag")) output += ", Agresivo";
  if (prop.getProperty("psico5").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Estado Psicológico: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("psico5").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros7"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("alergia0").equalsIgnoreCase("n")) output = "Niega";
else {
  if (prop.getProperty("alergia1").equalsIgnoreCase("a")) output = "Alimentos";
  if (prop.getProperty("alergia2").equalsIgnoreCase("ai")) output += ", Aines";
  if (prop.getProperty("alergia4").equalsIgnoreCase("m")) output += ", Medicamentos";
  if (prop.getProperty("alergia5").equalsIgnoreCase("y")) output += ", Yodo";
  if (prop.getProperty("alergia6").equalsIgnoreCase("s")) output += ", Sulfa";
  if (prop.getProperty("alergia7").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Alergia: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("alergia7").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros8"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("antpat0").equalsIgnoreCase("n")) output = "Sin Antecedentes Patologicos";
else {
  if (prop.getProperty("antpat1").equalsIgnoreCase("h")) output = "Hipertensión Arterial";
  if (prop.getProperty("antpat2").equalsIgnoreCase("d")) output += ", Diabetes";
  if (prop.getProperty("antpat3").equalsIgnoreCase("pr")) output += ", Problemas Renales";
  if (prop.getProperty("antpat4").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Antecedentes Patológicos Personales: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("antpat4").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros9"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("antfam0").equalsIgnoreCase("n")) output = "Sin Antecedentes Familiares";
else {
  if (prop.getProperty("antfam1").equalsIgnoreCase("h")) output = "Hipertensión Arterial";
  if (prop.getProperty("antfam2").equalsIgnoreCase("d")) output += ", Diabetes:::";
  if (prop.getProperty("antfam3").equalsIgnoreCase("pr")) output += ", Problemas Renales";
  if (prop.getProperty("antfam4").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Antecedentes Patológicos Familiares: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("antfam4").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros16"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}


output = "";
if (prop.getProperty("anthosp").equalsIgnoreCase("S"))  output = "SI";

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Antecedentes de Hospitalización: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  pc.addCols("Comentarios: ",2,2);
  pc.addCols(prop.getProperty("otros12"),0,8);
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("antcir").equalsIgnoreCase("S"))  output = "SI";

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Antecedentes de Cirugías Previas: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  pc.addCols("Comentarios: ",2,2);
  pc.addCols(prop.getProperty("otros13"),0,8);

  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("patron_suenio0").equalsIgnoreCase("n")) output = "Normal";
else {
  if (prop.getProperty("patron_suenio1").equalsIgnoreCase("i")) output = "Insomnio";
  if (prop.getProperty("patron_suenio2").equalsIgnoreCase("in")) output += ", Sueño Interrumpido";
  if (prop.getProperty("patron_suenio3").equalsIgnoreCase("ra")) output += ", Requiere Ayuda (" + prop.getProperty("otros14") +")";
  if (prop.getProperty("patron_suenio4").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Patrón del Sueño: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("patron_suenio4").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros15"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("nutricional0").equalsIgnoreCase("c")) output = "Normal";
else {
  if (prop.getProperty("nutricional1").equalsIgnoreCase("t")) output = "Nutrición enteral";
  if (prop.getProperty("nutricional2").equalsIgnoreCase("g")) output += ", Bajo peso";
  if (prop.getProperty("nutricional3").equalsIgnoreCase("ca")) output += ", Sobre peso";
  if (prop.getProperty("nutricional4").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Nutricional: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("nutricional4").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros10"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("genito0").equalsIgnoreCase("n")) output = "Normal";
else {
  if (prop.getProperty("genito1").equalsIgnoreCase("d")) output = "Disuria";
  if (prop.getProperty("genito2").equalsIgnoreCase("ol")) output += ", Oliguria";
  if (prop.getProperty("genito3").equalsIgnoreCase("p")) output += ", Poliuria";
  if (prop.getProperty("genito4").equalsIgnoreCase("h")) output += ", Hematuria";
  if (prop.getProperty("genito5").equalsIgnoreCase("i")) output += ", Incontinencia";
  if (prop.getProperty("genito6").equalsIgnoreCase("ru")) output += ", Retención Urinaria";
  if (prop.getProperty("genito7").equalsIgnoreCase("do")) output += ", Dolor";
  if (prop.getProperty("genito8").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Genito-Urinario: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("genito8").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros17"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("patron_eliminacion0").equalsIgnoreCase("n")) output = "Normal";
else {
  if (prop.getProperty("patron_eliminacion1").equalsIgnoreCase("c")) output = "Estreñimiento";
  if (prop.getProperty("patron_eliminacion2").equalsIgnoreCase("d")) output += ", Diarrea";
  if (prop.getProperty("patron_eliminacion3").equalsIgnoreCase("m")) output += ", Melena";
  if (prop.getProperty("patron_eliminacion4").equalsIgnoreCase("o")) output += ", Otros";
}

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Patrón de Eliminación: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  if (prop.getProperty("patron_eliminacion4").equalsIgnoreCase("o")){
     pc.addCols("Comentarios: ",2,2);
     pc.addCols(prop.getProperty("otros11"),0,8);
  }
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

output = "";
if (prop.getProperty("transf").equalsIgnoreCase("S"))  output = "Transfusiones de Componentes Sanguineos";
if (prop.getProperty("reac").equalsIgnoreCase("S"))  output += ", Reacción Adversa";

if (!output.equals("")) {
  pc.setFont(9,1);
  pc.addCols("Historial Transfusional: ",0,2);
  pc.setFont(9, 0);
  pc.addCols(output, 0, dHeader.size() - 2);
  
  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
}

if (cdo.getColValue("sexo"," ").equalsIgnoreCase("F") && !prop.getProperty("lactancia").equalsIgnoreCase("N") ) {
    
    output = "";
    if (prop.getProperty("lactancia").equalsIgnoreCase("S"))  output = "Lactando";

    if (!output.equals("")) {
      pc.setFont(9,1);
      pc.addCols("Historia Obstétrica:",0,2);
      pc.setFont(9, 0);
      pc.addCols(output, 0, dHeader.size() - 2);
      
      pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    }
}

if (prop.getProperty("historiaActual")!=null && !"".equals("")) {
    pc.setFont(9,1,Color.gray);
    pc.addCols("Historia Actual:",0,2);
    pc.setFont(9,0);
    pc.addCols(prop.getProperty("historiaActual"),0,8);
}

Vector vFormularios = CmnMgr.str2vector(formulario);

if (!CmnMgr.vectorContains(vFormularios,"15")) {
    Hashtable iRiesgo = new Hashtable();
    iRiesgo.put("0","Paciente con Enfermedad Crónica");
    iRiesgo.put("1","Paciente de Cuidado Crítico");
    iRiesgo.put("2","Paciente cuyo sistema inmunológico se encuentra afectado (Inmunosuprimido)");
    iRiesgo.put("3","Embarazada (evaluación especifica de obstetricia, cribado)");
    iRiesgo.put("4","Pediátrico (evaluación especifica crecimiento y desarrollo, dolor, caída, cribado y Plan de cuidado)");
    iRiesgo.put("5","Adolescentes (evaluación especifica del adolescente)");
    iRiesgo.put("6","Adulto Mayor (75 años en adelante) (evaluación especifica Escala)");     
    iRiesgo.put("7","Discapacidad física(evaluación especifica Escala)");
    iRiesgo.put("8","Pacientes en fase terminal (evaluación especifica Escala)");
    iRiesgo.put("9","Pacientes con dolor intenso o crónico");
    iRiesgo.put("10","Paciente en quimioterapia o radioterapia");
    iRiesgo.put("11","Pacientes con enfermedades infecciosas o contagiosas");
    iRiesgo.put("12","Sospecha Pacientes con trastornos emocionales o psiquiátricos");
    iRiesgo.put("13","Pacientes con presunta dependencia de las drogas y/o alcohol");
    iRiesgo.put("14","Sospecha Victima de abuso y abandono");
    iRiesgo.put("15","Ninguno");

    pc.addCols(" ",0,dHeader.size());
    pc.setFont(9,1,Color.white);
    pc.addCols("Evaluación de Riesgo y/o Vulnerabilidad",0,dHeader.size(),15f,Color.gray);
    pc.addCols(" ",0,dHeader.size());

    pc.setFont(9,1,Color.gray);
                    
    for (int r = 0; r < iRiesgo.size(); r++){
        if (  CmnMgr.vectorContains(vFormularios, ""+r) ) {
          pc.addCols("",0,2);
          pc.setFont(9,0);
          
          pc.addImageCols( (CmnMgr.vectorContains(vFormularios,""+r))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
          pc.addCols(" "+iRiesgo.get(""+r),0,7);
        }
    }
}

pc.addCols(" ",1,dHeader.size());
pc.setFont(10,1);
pc.addCols("EVALUACIÓN INICIAL II",0,dHeader.size(),15f,Color.gray);
pc.addCols(" ",1,dHeader.size());

prop = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo_cuestionario = 'C1'");
if (prop == null) prop = new Properties();

if (prop.getProperty("aislamiento").equalsIgnoreCase("s")){
    pc.setFont(10,1);
    pc.addCols("EVALUACIÓN INICIAL DE LAS ENFERMEDADES TRANSMISIBLES",0,dHeader.size());

    output = "";
    
    if (prop.getProperty("aislamiento_det1").equalsIgnoreCase("1")) output = "Paciente con Aislamiento de Contacto\n";
    if (prop.getProperty("aislamiento_det3").equalsIgnoreCase("3")) output += "Paciente Con Aislamiento de Gotas\n";
    if (prop.getProperty("aislamiento_det5").equalsIgnoreCase("5")) output += "Paciente con Aislamiento Respiratorio (Gotitas)\n";
    if (prop.getProperty("aislamiento_det0").equalsIgnoreCase("0")) output += "Orientación al paciente y familiar\n";
    if (prop.getProperty("aislamiento_det2").equalsIgnoreCase("2")) output += "Coordinación con la enfermera de nosocomial\n";
    if (prop.getProperty("aislamiento_det4").equalsIgnoreCase("4")) output += "Colocación del equipo de protección\n";
    if (prop.getProperty("aislamiento_det6").equalsIgnoreCase("6")) output += "Otros";
    
    if (!output.equals("")) {
       pc.setFont(9, 0);
       pc.addCols(output, 0, dHeader.size());
      
       if (prop.getProperty("aislamiento_det6").equalsIgnoreCase("o")){
          pc.addCols("Comentarios: ",2,2);
          pc.addCols(prop.getProperty("observacion27"),0,8);
       }
      
       pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    }
}

if(cdo.getColValue("sexo","M").equalsIgnoreCase("M") && edad > 12){
    String nuts = "";

    if (prop.getProperty("perdido_peso").equalsIgnoreCase("s")) nuts += "Pérdida de Peso en los últimos tres (3) meses\n";
    if (prop.getProperty("disminucion").equalsIgnoreCase("s")) nuts += "Disminución de la ingesta en la última semana\n";
    if (prop.getProperty("diabetes").equalsIgnoreCase("s")) nuts += "Tiene alguno de estos Diagnósticos: Diabetes, EPOC, Nefrópata (hemodiálisis), Enfermedad Oncológico, Fractura de Cadera, Cirrosis hepática\n";
    
    if (prop.getProperty("unidad_cuidado").equalsIgnoreCase("s")) nuts += "Paciente se encuentra en la Unidad de Cuidados Intensivos\n";
    if (prop.getProperty("nutricion_enteral").equalsIgnoreCase("s")) nuts += "Paciente se encuentra con nutrición enteral\n";
    
    if (prop.getProperty("problema_comunicacion").equalsIgnoreCase("s")) nuts += "Paciente con problemas de comunicación\n";
    if (prop.getProperty("perdida_peso_15").equalsIgnoreCase("s")) nuts += "Que haya perdido >15% en los últimos meses\n";
       
    if (prop.getProperty("mayor_80").equalsIgnoreCase("s")) nuts += "Que el paciente >80 años deberán, comunicarse con la nutricionista para una evaluación completa, vía mensaje de texto\n";
    
    if (!nuts.equals("")) {
       pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    
       pc.setFont(10,1);
       pc.addCols(" ",0,dHeader.size());
       pc.addCols("NUTRICION: CRIBADO NUTRICIONAL (No Aplica a Pediatría ni Obstetricia)",0,dHeader.size());
    
       pc.setFont(10, 0);
       pc.addCols(nuts,0,dHeader.size());

      pc.setFont(12,1);
      pc.addCols(" ",0,dHeader.size());
      pc.addCols("Observaciones de alerta a presentar:\n1. En caso de 2 o más alteraciones resulten en (SI)\n2. Si el Paciente se encuentra con nutrición enteral\n3. Si el Paciente con problemas de comunicación\n4. si es paciente de Cuidados Intensivos que mande alerta\n5. Que haya perdido >15% en los últimos meses\n6. Que el paciente >80 años deberán, comunicarse con la nutricionista para una evaluación completa, vía mensaje de texto",0,dHeader.size());
      pc.addCols(" ",0,dHeader.size());
    }
    
    pc.setFont(10,1,Color.gray);
    pc.addCols("Nutricionista Enterada:",0,2);
    
    pc.setFont(10,0);
    
    String via = "";
    if (""+prop.getProperty("via")!=null){
      if (prop.getProperty("via").equalsIgnoreCase("c")) via = "Correo";
      else if (prop.getProperty("via").equalsIgnoreCase("t")) via = "Teléfono";
      else if (prop.getProperty("via").equalsIgnoreCase("p")) via = "Personal";
      else if (prop.getProperty("via").equalsIgnoreCase("s")) via = "SMS";
    }

    pc.addCols(prop.getProperty("nutricionista"),0,2);
    pc.addCols(" Hora: "+prop.getProperty("hora"),0,3);
    pc.addCols(" Vía Comunicación: "+via,0,3);
} 
else if(cdo.getColValue("sexo","F").equalsIgnoreCase("F") && edad > 12){
    Properties propE = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = 'EM'");
    String nuts = "";
    if(propE == null) propE = new Properties();

    if(propE.getProperty("cribado_nutricional1").equalsIgnoreCase("s")) nuts += "Ha disminuido la ingesta en las últimas dos semanas\n";
    if(propE.getProperty("cribado_nutricional2").equalsIgnoreCase("s")) nuts += "Padece de Diabetes Gestacional\n";
    if(propE.getProperty("cribado_nutricional3").equalsIgnoreCase("s")) nuts += "Toma tres o más tragos de licor por día\n";
    if(propE.getProperty("cribado_nutricional4").equalsIgnoreCase("a")) nuts += "Adecuado\n";
    if(propE.getProperty("cribado_nutricional4").equalsIgnoreCase("e")) nuts += "Excesivo\n";
    if(propE.getProperty("cribado_nutricional4").equalsIgnoreCase("d")) nuts += "Deficiente\n";
    
    if (!nuts.equals("")) {
      pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
      pc.setFont(10,1);
      pc.addCols("NUTRICION: CRIBADO NUTRICIONAL",0,dHeader.size());
      pc.setFont(10,0);
    
      pc.addCols(nuts,0,dHeader.size());
      pc.addCols(" ",0,dHeader.size());
    }

    String via = "";
    if (""+propE.getProperty("via")!=null){
      if (propE.getProperty("via").equalsIgnoreCase("c")) via = "Correo";
      else if (propE.getProperty("via").equalsIgnoreCase("t")) via = "Teléfono";
      else if (propE.getProperty("via").equalsIgnoreCase("p")) via = "Personal";
      else if (propE.getProperty("via").equalsIgnoreCase("s")) via = "SMS";
    }
    
    if (!"".equals(propE.getProperty("nutricionista"))) {
      pc.addCols("Nombre de Nutricionista Enterada:",0,2);
      pc.addCols(propE.getProperty("nutricionista")+"          Hora: "+propE.getProperty("hora")+"          Via de comunicación: "+via,0,8);
    }
    
    propE = null;
}
else if (edad < 12) {
    Properties propP = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = 'PE'");
    
    if(propP == null) propP = new Properties();
    String nuts = "";
    
    if (propP.getProperty("cribado_nutricional0").equalsIgnoreCase("s")) nuts += "Ha disminuido la ingesta en las últimas dos semanas\n";
    if (propP.getProperty("cribado_nutricional1").equalsIgnoreCase("s")) nuts += "Diagnostico Medico: Gastroenteritis, Vómitos, Nauseas\n";
    if (propP.getProperty("cribado_nutricional2").equalsIgnoreCase("s")) nuts += "Perdida de peso en las ultimas dos semanas\n";
    if (propP.getProperty("cribado_nutricional3").equalsIgnoreCase("a")) nuts += "Adecuado\n";
    if (propP.getProperty("cribado_nutricional3").equalsIgnoreCase("e")) nuts += "Excesivo\n";
    if (propP.getProperty("cribado_nutricional3").equalsIgnoreCase("d")) nuts += "Deficiente\n";
    if (propP.getProperty("cribado_nutricional4").equalsIgnoreCase("d")) nuts += "Paciente se encuentra con nutrición enteral\n";

    if (!nuts.equals("")) {
      pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
      pc.setFont(10,1);
      pc.addCols("NUTRICION: CRIBADO NUTRICIONAL",0,dHeader.size());
      pc.setFont(10,0);
    
      pc.addCols(nuts,0,dHeader.size());
      pc.addCols(" ",0,dHeader.size());
    }
    
    propP = null;
}


if (!prop.getProperty("banio_higiene").equalsIgnoreCase("na") || !prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("na") || !prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("na") || prop.getProperty("movimiento").equalsIgnoreCase("s") || prop.getProperty("necesidad").equalsIgnoreCase("s")) 
{
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    pc.setFont(10,1);
    pc.addCols(" ",0,dHeader.size());
    pc.addCols("VALORACION FUNCIONAL",0,dHeader.size(),Color.lightGray);
    pc.setFont(10,0);
    
    if (!prop.getProperty("banio_higiene").equalsIgnoreCase("na")){
        pc.addCols("Baño / higiene",0,4);
        pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
        pc.addCols("Ayuda parcial",0,1);
        
        pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
        pc.addCols("Ayuda total",0,1);
        
        pc.addCols(" ",0,2);
    }
    
    if (!prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("na")){
        pc.addCols("Vestirse / desvestirse / alimentación",0,4);
        
        pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
        pc.addCols("Ayuda parcial",0,1);
            
        pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
        pc.addCols("Ayuda total",0,1);
            
        pc.addCols(" ",0,2);
    }
    
    if (!prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("na")) {
        pc.addCols("Movilidad deambulación",0,4);
        
        pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
        pc.addCols("Ayuda parcial",0,1);
        
        pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
        pc.addCols("Ayuda total",0,1);
            
        pc.addCols(" ",0,2);
    }

    if (prop.getProperty("movimiento").equalsIgnoreCase("s")) {
        String movs = "";
        
        pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
                
        if (prop.getProperty("dificultad_movimiento0").equalsIgnoreCase("0")) movs += ", Moverse";
        if (prop.getProperty("dificultad_movimiento1").equalsIgnoreCase("1")) movs += ", Caminar";
        if (prop.getProperty("dificultad_movimiento2").equalsIgnoreCase("2")) movs += ", Levantarse";
        if (prop.getProperty("dificultad_movimiento3").equalsIgnoreCase("3")) movs += ", Sentarse";
        if (prop.getProperty("dificultad_movimiento4").equalsIgnoreCase("4")) movs += ", Pérdida Funcional";
        if (prop.getProperty("dificultad_movimiento5").equalsIgnoreCase("5")) movs += ", Prótesis";
        if (prop.getProperty("dificultad_movimiento6").equalsIgnoreCase("6")) movs += ", Paresias/plejia";
        if (prop.getProperty("dificultad_movimiento7").equalsIgnoreCase("7")) movs += ", Amputaciones";
        if (prop.getProperty("dificultad_movimiento8").equalsIgnoreCase("8")) movs += ", Otros";

        pc.addCols("Alguna Dificultad Funcional? : ",0,2);
        pc.addCols(movs,0,dHeader.size() - 2);
        
        if (prop.getProperty("dificultad_movimiento8").equalsIgnoreCase("o")){
           pc.addCols("Comentarios: ",2,2);
           pc.addCols(prop.getProperty("observacion0"),0,8);
        }
                
    }
    
    if (prop.getProperty("necesidad").equalsIgnoreCase("s")) {
        String necs = "";
        
        pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
                        
        if (prop.getProperty("necesidad_especial0").equalsIgnoreCase("0")) necs += ", Ciego";
        if (prop.getProperty("necesidad_especial1").equalsIgnoreCase("1")) necs += ", Sordo";
        if (prop.getProperty("necesidad_especial2").equalsIgnoreCase("2")) necs += ", Mudo";
        if (prop.getProperty("necesidad_especial3").equalsIgnoreCase("3")) necs += ", Otro";

        pc.addCols("Alguna necesidad especial? : ",0,2);
        pc.addCols(necs,0,dHeader.size() - 2);
        
        if (prop.getProperty("necesidad_especial3").equalsIgnoreCase("o")){
           pc.addCols("Comentarios: ",2,2);
           pc.addCols(prop.getProperty("observacion1"),0,8);
        }
        
        
    }
}

if (!prop.getProperty("religion").equals("") || prop.getProperty("creencia").equalsIgnoreCase("s") || prop.getProperty("servicio_religioso").equalsIgnoreCase("s") || prop.getProperty("voluntades_anticipadas").equalsIgnoreCase("s")) {
    pc.setFont(10,1);
    pc.addCols(" ",0,dHeader.size());
    pc.addCols("VALORACION CREENCIAS / CULTURA / ESPIRITUAL",0,dHeader.size());
    
    pc.setFont(10,0);
    
    if (!prop.getProperty("religion").equals("")) {
        String relg = "";
        pc.addCols("", 0, 2);
                
        if (prop.getProperty("religion").equalsIgnoreCase("0")) relg = "Católico";
        else if (prop.getProperty("religion").equalsIgnoreCase("1")) relg = "Judío";
        else if (prop.getProperty("religion").equalsIgnoreCase("2")) relg = "Árabe";
        else if (prop.getProperty("religion").equalsIgnoreCase("3")) relg = "Musulmán";
        else if (prop.getProperty("religion").equalsIgnoreCase("4")) relg = "Ninguno";
        else if (prop.getProperty("religion").equalsIgnoreCase("ot")) relg = "Otros: " + prop.getProperty("observacion2");
        
        pc.addCols(relg, 0, dHeader.size() - 2);
        
    }
    
    if(prop.getProperty("creencia").equalsIgnoreCase("s")){
        pc.addCols(" ",1,dHeader.size(),15f);
        
        pc.addCols("Alguna Creencia religiosa o cultural que le gustaría que tuviéramos en cuenta en su hospitalización:", 0, dHeader.size());
        pc.addCols(prop.getProperty("observacion3"),0,dHeader.size());
    }
    
    if (prop.getProperty("servicio_religioso").equalsIgnoreCase("s")) {
        pc.addCols(" ",1,dHeader.size(),15f);
        
        pc.addCols("Servicios Religiosos Solicitados:", 0, dHeader.size());
        pc.addCols(prop.getProperty("observacion4"),0,dHeader.size());
    }
    
    if (prop.getProperty("voluntades_anticipadas").equalsIgnoreCase("s")) {
        pc.addCols(" ",0,dHeader.size());
        pc.addCols("Voluntades Anticipadas:", 0, 2);
        
        String vol = "";
        
        if (prop.getProperty("no_no0").equalsIgnoreCase("0")) vol += ", No reanimación cardiopulmonar (NO RCP)";
        if (prop.getProperty("no_no1").equalsIgnoreCase("1")) vol += ", Donante de Órgano";
        if (prop.getProperty("no_no2").equalsIgnoreCase("2")) vol += ", No Transfusiones de sangre";
        if (prop.getProperty("no_no3").equalsIgnoreCase("ot")) vol += ", Otras";
        
        pc.addCols(vol, 0, dHeader.size() - 2);
        
        if (prop.getProperty("no_no3").equalsIgnoreCase("ot")) {
          pc.addCols("Comentarios: ",2,2);
          pc.addCols(prop.getProperty("observacion5"), 0, dHeader.size()-2);
        }
    }
}

if (prop.getProperty("frecuencia_alcohol").equalsIgnoreCase("1") || prop.getProperty("fumador").equalsIgnoreCase("s") || prop.getProperty("fumador_frecuencia").equalsIgnoreCase("s") || prop.getProperty("drogadicto").equalsIgnoreCase("s") || prop.getProperty("estado_salud").equalsIgnoreCase("ot") ) {
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
    pc.setFont(10,1);
    pc.addCols("EVALUACION SOCIAL Y ACTIVIDADES",0,dHeader.size(),Color.lightGray);
    
    pc.setFont(10,0);
    
    if (prop.getProperty("frecuencia_alcohol").equalsIgnoreCase("1")) {
        pc.addCols("Ingiere Alcohol:", 0, 2);
        pc.addCols("A diario", 0, dHeader.size() - 2);
    }
    
    if (prop.getProperty("fumador").equalsIgnoreCase("s")) {
        pc.addCols(" ",1,dHeader.size());
        pc.addCols("Ha sido usted consumidor de tabaco:  "+prop.getProperty("observacion8"), 0, dHeader.size());
    }
    
    if (prop.getProperty("fumador_frecuencia").equalsIgnoreCase("s")) {
        pc.addCols(" ",1,dHeader.size());
        pc.addCols("Ha fumado en los últimos 12 meses  "+prop.getProperty("observacion9")+" cigarrillos por día", 0, dHeader.size());
    }
    
    if (prop.getProperty("drogadicto").equalsIgnoreCase("s")) {
        pc.addCols(" ",1,dHeader.size());
        pc.addCols("Consume drogas: "+prop.getProperty("observacion10"), 0, dHeader.size());
    }
    
    if (prop.getProperty("estado_salud").equalsIgnoreCase("ot")) {
        pc.addCols(" ",1,dHeader.size());
        pc.addCols("Estado de Salud: "+prop.getProperty("observacion11"),0,dHeader.size());
    }
}

if (prop.getProperty("vive_con").equalsIgnoreCase("s") || prop.getProperty("vive_con").equalsIgnoreCase("ot") || prop.getProperty("se_observa0").equalsIgnoreCase("ca") || prop.getProperty("se_observa1").equalsIgnoreCase("pi") || prop.getProperty("se_observa2").equalsIgnoreCase("pf") || prop.getProperty("tiene_a_cargo2").equalsIgnoreCase("2") || !prop.getProperty("residencia_actual").equals("") || prop.getProperty("aspecto_economico").equalsIgnoreCase("1")) {
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
    pc.setFont(10,1);
    pc.addCols("VALORACION PSICOSOCIAL Y ECONOMICA",0,dHeader.size(),Color.lightGray);
    
    pc.setFont(10,0);
    
    if (prop.getProperty("vive_con").equalsIgnoreCase("s")) {
        pc.addCols(" ",1,dHeader.size());
        pc.addCols("Vive solo",0,dHeader.size());
    }
    
    if (prop.getProperty("vive_con").equalsIgnoreCase("ot")) {
        pc.addCols(" ",1,dHeader.size());
        pc.addCols("Vive con: "+prop.getProperty("observacion12"),0,dHeader.size());
    }
    
    if (prop.getProperty("se_observa0").equalsIgnoreCase("ca") || prop.getProperty("se_observa1").equalsIgnoreCase("pi") || prop.getProperty("se_observa2").equalsIgnoreCase("pf")) {
        pc.addCols(" ",1,dHeader.size());
        
        String barreras = "";
        
        pc.addCols("Se observa barreras: ", 0, 2);
        
        if(prop.getProperty("se_observa0").equalsIgnoreCase("ca")) barreras += ", Carencia afectiva";
        if(prop.getProperty("se_observa1").equalsIgnoreCase("pi")) barreras += ", Problemas de Integración";
        if(prop.getProperty("se_observa2").equalsIgnoreCase("pf")) barreras += ", Problemas Familiares";
        
        pc.addCols(barreras, 0, dHeader.size() - 2);
    }
    
    if (prop.getProperty("tiene_a_cargo2").equalsIgnoreCase("2")) {
        pc.addCols(" ",0,dHeader.size());
        pc.addCols("Cuenta con apoyo de : Otros",0,dHeader.size());
    }
    
    if (!prop.getProperty("residencia_actual").equals("")) {
        pc.addCols(" ",0,dHeader.size());
        pc.addCols("Vivienda:",0,2);
        
        pc.addImageCols( (prop.getProperty("residencia_actual").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
        pc.addCols("Adecuada a necesidades",0,1);
        
        pc.addImageCols( (prop.getProperty("residencia_actual").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
        pc.addCols("Innadecuada",0,1);
        
        pc.addImageCols( (prop.getProperty("residencia_actual").equalsIgnoreCase("ho"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
        pc.addCols("Barreras",0,1);
        
        pc.addImageCols( (prop.getProperty("residencia_actual").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
        pc.addCols("Otros",0,1);
        
        pc.addCols("Específique:",0,2);
        pc.addCols(prop.getProperty("observacion13"),0,dHeader.size()-2);
    }
    
    if (prop.getProperty("aspecto_economico").equalsIgnoreCase("1")) {
        pc.addCols(" ",0,dHeader.size());
        pc.addCols("Aspecto Económico: Se detecta dificultades:",0, dHeader.size());
        pc.addCols(prop.getProperty("observacion14"),0,dHeader.size());
    }
}

sql = "select a.descripcion as descripcion from tbl_sal_eval_discapacidades a, tbl_sal_eval_discapa_det b where a.codigo=b.cod_eval and b.pac_id = "+pacId+" and b.secuencia = "+noAdmision+" and fecha_up = (select max(bb.fecha_up) from tbl_sal_eval_discapa_det bb where bb.pac_id = b.pac_id and bb.secuencia = b.secuencia  )  and b.seleccionar = 'S' order by a.codigo";
ArrayList al = SQLMgr.getDataList(sql);

if (al.size() > 0) {
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    pc.setFont(10,1);
    pc.addCols("EVALUACIÓN INICIAL II - DISCAPACIDAD",0,dHeader.size(),Color.lightGray);
    pc.setFont(10,0);
    
    for (int i = 0; i < al.size(); i++) {
        cdo = (CommonDataObject) al.get(i);
        
        pc.addCols("", 0, 2);
        pc.addImageCols(ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png",10,0);
        pc.addCols(cdo.getColValue("descripcion"),0,dHeader.size()-3);
    }
}
sql = "select a.descripcion as descripcion from tbl_sal_eval_geronte a, tbl_sal_eval_gerontes_det b where a.codigo=b.cod_eval and b.pac_id = "+pacId+" and b.secuencia = "+noAdmision+" and fecha_up = (select max(bb.fecha_up) from tbl_sal_eval_gerontes_det bb where bb.pac_id = b.pac_id and bb.secuencia = b.secuencia  ) and b.seleccionar = 'S' order by a.codigo";
al = SQLMgr.getDataList(sql);

if (CmnMgr.vectorContains(vFormularios,"6") && al.size() > 0) {
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    pc.setFont(10,1);
    pc.addCols("EVALUACIÓN INICIAL II - GERONTE",0,dHeader.size(),Color.lightGray);
    pc.setFont(10,0);
    
    for (int i = 0; i < al.size(); i++) {
        cdo = (CommonDataObject) al.get(i);
        
        pc.addCols("", 0, 2);
        pc.addImageCols(ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png",10,0);
        pc.addCols(cdo.getColValue("descripcion"),0,dHeader.size()-3);
    }
}

prop = SQLMgr.getDataProperties("select evaluaciones from tbl_sal_eval_aprendizaje where pac_id = "+pacId+" and admision = "+noAdmision+" and fecha_creacion = (select max(fecha_creacion) from tbl_sal_eval_aprendizaje where pac_id = "+pacId+" and admision = "+noAdmision+")");
if (prop == null) prop = new Properties();

if ((prop.getProperty("barrera0") != null && !prop.getProperty("barrera0").equalsIgnoreCase("nt")) || (prop.getProperty("idioma") != null || prop.getProperty("interprete").equalsIgnoreCase("s")) ) {
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    pc.setFont(10,1);
    pc.addCols("EVALUACIÓN DEL APRENDIZAJE",0,dHeader.size(),Color.lightGray);
      
    String lim = "";
    
    if (prop.getProperty("barrera1").equalsIgnoreCase("lec")) lim += ", Lectura";
    if (prop.getProperty("barrera3").equalsIgnoreCase("vis")) lim += ", Visual";
    if (prop.getProperty("barrera4").equalsIgnoreCase("aud")) lim += ", Auditiva";
    if (prop.getProperty("barrera5").equalsIgnoreCase("fis")) lim += ", Física";
    if (prop.getProperty("barrera6").equalsIgnoreCase("emo")) lim += ", Emocional";
    if (prop.getProperty("barrera7").equalsIgnoreCase("cul")) lim += ", Cultural";
    if (prop.getProperty("barrera8").equalsIgnoreCase("ot")) lim += ", Otras";
    
    if (!lim.equals("")) {
       pc.setFont(10, 1);
       pc.addCols("Barreras o limitaciones para el aprendizaje:", 0, 4);
       pc.setFont(9, 0);
       pc.addCols(lim, 0, dHeader.size() - 4);
       
       if (prop.getProperty("barrera8").equalsIgnoreCase("ot")) {
          pc.addCols("Comentarios:",2,2);
          pc.addCols(prop.getProperty("observacion2"), 0, dHeader.size() - 2);
       }
    }

    if (prop.getProperty("idioma")!=null) {
        
        String idioma = "";
        
        if (prop.getProperty("idioma").equalsIgnoreCase("es")) idioma = "Español";
        else if (prop.getProperty("idioma").equalsIgnoreCase("en")) idioma = "Inglés";
        else if (prop.getProperty("idioma").equalsIgnoreCase("ot")) idioma = "Otros: " + prop.getProperty("observacion3");
        
        if (!idioma.equals("")) {
            pc.setFont(10, 1);
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Idioma de preferencia del aprendiz: ",0,4);
            pc.setFont(9,0);
            
            pc.addCols(idioma,0,6);
        }
    }
    
    if (prop.getProperty("interprete").equalsIgnoreCase("s")) {
        pc.addCols("",0,dHeader.size());
        pc.addCols("Requiere intérprete: "+prop.getProperty("observacion5"),0,dHeader.size());
    }
    
    if (prop.getProperty("disposicion_aprendizaje").equalsIgnoreCase("n")) {
        pc.addCols("",0,dHeader.size());
        pc.addCols("Disposición para el aprendizaje: "+prop.getProperty("observacion6"),0,dHeader.size());
    }
}

prop = SQLMgr.getDataProperties("select plan from tbl_sal_plan_egreso_ingreso where pac_id="+pacId+" and admision="+noAdmision);
if (prop == null) prop = new Properties();

if ((prop.getProperty("disposicion0").equalsIgnoreCase("n") || prop.getProperty("disposicion1").equalsIgnoreCase("n") || prop.getProperty("disposicion2").equalsIgnoreCase("n")) || prop.getProperty("dificultad_egreso").equalsIgnoreCase("s") || prop.getProperty("conocer_diag").equalsIgnoreCase("n")) {
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    pc.setFont(10,1);
    pc.addCols("PLAN DE EGRESO DESDE EL INGRESO",0,dHeader.size(),Color.lightGray);    
    
    if (prop.getProperty("disposicion0").equalsIgnoreCase("n")){
        pc.setFont(9,1);
        pc.addCols("Cuenta con familiar para su cuidado?:   NO",0,dHeader.size());
        pc.addCols("",1,dHeader.size());
    }
    if (prop.getProperty("disposicion1").equalsIgnoreCase("n")){
        pc.setFont(9,1);
        pc.addCols("Hogar preparado para su salida?:   NO",0,dHeader.size());
        pc.addCols("",1,dHeader.size());
    }
    if (prop.getProperty("disposicion2").equalsIgnoreCase("n")){
        pc.setFont(9,1);
        pc.addCols("Cuenta con medio de transporte para la salida?:   NO",0,dHeader.size());
        pc.addCols("",1,dHeader.size());
    }
    
    if (prop.getProperty("dificultad_egreso").equalsIgnoreCase("s")) {    
        pc.addCols(" ",1,dHeader.size());
        
        String difIng = "";
        
        if (prop.getProperty("dificultades_egresos0").equalsIgnoreCase("0")) difIng += ", Transporte al hogar";
        if (prop.getProperty("dificultades_egresos1").equalsIgnoreCase("1")) difIng += ", Uso de escaleras";
        if (prop.getProperty("dificultades_egresos2").equalsIgnoreCase("2")) difIng += ", Ambulancia";
        if (prop.getProperty("dificultades_egresos3").equalsIgnoreCase("3")) difIng += ", Distancia";
        if (prop.getProperty("dificultades_egresos4").equalsIgnoreCase("ot")) difIng += ", Otros";
        
        if (!difIng.equals("")) {
            pc.setFont(9,1);
            pc.addCols("El paciente tiene alguna dificultad Para su egreso? :",0, 4);
            
            pc.setFont(9,0);
            pc.addCols(difIng, 0, dHeader.size() - 4);
            
            if (prop.getProperty("dificultades_egresos4").equalsIgnoreCase("ot")) {
              pc.addCols("Comentarios:",2,2);
              pc.addCols(prop.getProperty("observacion0"), 0, dHeader.size() - 2);
           }
        }
    }
    
    if (prop.getProperty("conocer_diag").equalsIgnoreCase("n")) {
        pc.addCols(" ",1,dHeader.size());
        
        pc.setFont(9,1);
        pc.addCols("El Paciente conoce su Diagnóstico/Pronóstico/Tratamiento",0,dHeader.size());
        
        pc.setFont(9,0);
        pc.addCols("",0,2);
        
        pc.addImageCols( (prop.getProperty("conocer_diags0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("Educación al paciente y familiar acerca de su diagnóstico",0,1);
        
        pc.addImageCols( (prop.getProperty("conocer_diags1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("Educación al paciente y familiar acerca de su Tratamiento",0,5);
    }
}

if (prop.getProperty("educacion_paciente").equalsIgnoreCase("s") || prop.getProperty("inst_egr").equalsIgnoreCase("s") || prop.getProperty("tratamiento").equalsIgnoreCase("s") || prop.getProperty("alto_riesgo").equalsIgnoreCase("s")){
    
    pc.addCols(" ",0,dHeader.size());
    pc.setFont(9,1,Color.white);
    pc.addCols("PLAN DE SALIDA",0,dHeader.size(),Color.gray);
        
    if (prop.getProperty("educacion_paciente").equalsIgnoreCase("s")){    

        pc.setFont(9,1,Color.gray);
        pc.addCols("Educación para el paciente, familia y/o Acompañante:",0,4);

        pc.setFont(9,0);

        pc.addImageCols( (prop.getProperty("educaciones_paciente0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("Folleto de Ingreso",0,1);

        pc.addImageCols( (prop.getProperty("educaciones_paciente1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("Folleto de Egreso",0,1);

        pc.addImageCols( (prop.getProperty("educaciones_paciente2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("Care Notes",0,3);

        pc.addCols(" ",0,2);
        pc.addImageCols( (prop.getProperty("educaciones_paciente3").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("Otros",0,1);
        pc.addCols(prop.getProperty("observacion1"),0,6);
    }
    
    if (prop.getProperty("inst_egr").equalsIgnoreCase("s")) {
        pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);

        pc.addCols(" ",0,dHeader.size());
        pc.setFont(9,1,Color.white);
        pc.addCols("Instrucciones de egreso",0,dHeader.size(),Color.gray);
        
        pc.setFont(9,0);
        
        if (prop.getProperty("insts_egr0") != null && !"".equals(prop.getProperty("insts_egr0"))) {
            pc.addCols("Técnicas de Rehabilitación",0,2);
            pc.addImageCols( (prop.getProperty("insts_egr0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion3"),0,7);
        }
        
        if (prop.getProperty("insts_egr1") != null && !"".equals(prop.getProperty("insts_egr1"))){
            pc.addCols("Dispositivos de Rehabilitación",0,2);
            pc.addImageCols( (prop.getProperty("insts_egr1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion4"),0,7);
        }
        
        if (prop.getProperty("insts_egr2") != null && !"".equals(prop.getProperty("insts_egr2"))){
            pc.addCols("Dietas",0,2);
            pc.addImageCols( (prop.getProperty("insts_egr2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion5"),0,7);
        }
        
        if (prop.getProperty("insts_egr3") != null && !"".equals(prop.getProperty("insts_egr3"))){
            pc.addCols("Otras",0,2);
            pc.addImageCols( (prop.getProperty("insts_egr3").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion6"),0,7);
        }
    }
    
    if (prop.getProperty("tratamiento").equalsIgnoreCase("s")) {
        pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
        pc.addCols(" ",0,dHeader.size());
        pc.setFont(9,1,Color.white);
        pc.addCols("Tratamientos",0,dHeader.size(),Color.gray);
        
        pc.setFont(9,0);
       
        if (!"".equals(prop.getProperty("tratamientos0"))){
            pc.addCols("Equipos especiales",0,2);
            pc.addImageCols( (prop.getProperty("tratamientos0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion7"),0,7);
        }
        
        if (!"".equals(prop.getProperty("tratamientos1"))){
        pc.addCols("Cuidados Post-Operatorios",0,2);
        pc.addImageCols( (prop.getProperty("tratamientos1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols(prop.getProperty("observacion8"),0,7);
        }
        
        if (!"".equals(prop.getProperty("tratamientos2"))){
        pc.addCols("Curación de heridas",0,2);
        pc.addImageCols( (prop.getProperty("tratamientos2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("",0,7);
        }
        
        if (!"".equals(prop.getProperty("tratamientos3"))){
        pc.addCols("Terapia respiratoria",0,2);
        pc.addImageCols( (prop.getProperty("tratamientos3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("",0,7);
        }
        
        if (!"".equals(prop.getProperty("tratamientos4"))){
        pc.addCols("Glicemia capilar",0,2);
        pc.addImageCols( (prop.getProperty("tratamientos4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("",0,7);
        }
        
        if (!"".equals(prop.getProperty("tratamientos5"))){
        pc.addCols("Fisioterapia",0,2);
        pc.addImageCols( (prop.getProperty("tratamientos5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("",0,7);
        }
        
        if (!"".equals(prop.getProperty("tratamientos6"))){
        pc.addCols("Otros",0,2);
        pc.addImageCols( (prop.getProperty("tratamientos6").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols(prop.getProperty("observacion9"),0,7);
        }        
    }
    
    if (prop.getProperty("alto_riesgo").equalsIgnoreCase("s")) {
        pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
        pc.addCols(" ",0,dHeader.size());
        pc.setFont(9,1,Color.white);
        pc.addCols("Pacientes de alto riesgo, considerar",0,dHeader.size(),Color.gray);
        
        pc.setFont(9,0);
        
        if (!"".equals(prop.getProperty("altos_riesgos0"))){
        pc.addCols("Equipo multidisciplinario previa salida",0,2);
        pc.addImageCols( (prop.getProperty("altos_riesgos0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("",0,7);
        }
        
        if (!"".equals(prop.getProperty("altos_riesgos1"))){    
            pc.addCols("Comunicación directa con médico de cabecera, previa salida",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
        }    
        
        if (!"".equals(prop.getProperty("altos_riesgos2"))){    
            pc.addCols("Cita con médico tratante antes de los 7 días de salida",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
        }
        
        if (!"".equals(prop.getProperty("altos_riesgos3"))){    
            pc.addCols("Contacto directo con acompañante para salida",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
        }    
        
        if (!"".equals(prop.getProperty("altos_riesgos4"))){    
            pc.addCols("Dieta especial",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion11"),0,7);
        }
            
        if (!"".equals(prop.getProperty("altos_riesgos0"))){    
            pc.addCols("Restricciones",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion12"),0,7);
        }
            
        if (!"".equals(prop.getProperty("altos_riesgos6"))){
            pc.addCols("Otros",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos6").equalsIgnoreCase("6"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion13"),0,7);
        }
            
    }
}

SecMgr.setConnection(null);
CmnMgr.setConnection(null);
SQLMgr.setConnection(null);

prop = null;

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);
}
%>