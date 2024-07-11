<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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
String codigo = request.getParameter("codigo");
String formulario = request.getParameter("formulario");
String codBarrera = request.getParameter("cod_barrera");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
cdoUsr.addColValue("usuario",userName);

if(desc == null) desc = "";
if(fg == null) fg = "";
if (codigo == null) codigo = "0";
if (formulario == null) formulario = "";
if (codBarrera == null) codBarrera = "0";

prop = SQLMgr.getDataProperties("select params from tbl_sal_eval_nutri_riesgo where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+codigo+" and tipo = '"+fg+"'");

if (prop == null) prop = new Properties();

ArrayList al = new ArrayList();

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
String subTitle = !desc.equals("")?desc:"PLAN DE ATENCION (KARDEX)";
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

PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");

if(pc==null){  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);isUnifiedExp=true;}

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

pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
pc.setTableHeader(1);

prop = SQLMgr.getDataProperties("select kardex from tbl_sal_plan_atencion_kardex where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+codigo);

cdo = SQLMgr.getData("select to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, to_char(fecha_modificacion, 'dd/mm/yyyy hh24:mi') fm, usuario_creacion, usuario_modificacion from tbl_sal_plan_atencion_kardex where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+codigo);

if (cdo == null) cdo = new CommonDataObject();
if (prop == null) prop = new Properties();

pc.setFont(9,0);

pc.addCols("Creado el: ",0,1);
pc.addCols(cdo.getColValue("fc"),0,3);
pc.addCols(" Por el usuario: ",2,3);
pc.addCols(cdo.getColValue("usuario_creacion"),0,3);

pc.addCols(" ",1,dHeader.size());

pc.addCols("Diagnóstico Actual: "+prop.getProperty("diag_actual"),0,dHeader.size());
pc.addCols("Fecha de Traslado y Servicio: "+prop.getProperty("fecha_traslado"),0,dHeader.size());

pc.addCols(" ",1,dHeader.size());

pc.setFont(9,1);
pc.addCols("ANTECEDENTES ALERGICOS",0,dHeader.size());

al = SQLMgr.getDataList("select a.descripcion as descripcion, a.codigo as codigoalergia, to_char(b.fecha,'dd/mm/yyyy hh12:mi:ss am') as fecha, b.usuario_creacion, b.meses as meses, b.observacion as observacion, b.edad as edad, nvl(b.codigo,0) as cod, b.aplicar as aplicar from TBL_SAL_TIPO_ALERGIA a, TBL_SAL_ALERGIA_PACIENTE b where a.codigo=b.tipo_alergia and b.pac_id = "+pacId+" and nvl(b.admision,"+noAdmision+") = "+noAdmision);

pc.addBorderCols("Tipo de Alergia",1 ,2);
pc.addBorderCols("Edad",1 ,1);
pc.addBorderCols("Meses",1 ,1);
pc.addBorderCols("Observación",1 ,3);
pc.addBorderCols("Fecha",1 ,2);
pc.addBorderCols("Usuario",1 ,1);

pc.setFont(9,0);
for(int i = 0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    pc.addCols(cdo.getColValue("descripcion"),0,2,15.2f);
    pc.addCols(cdo.getColValue("edad"),1,1,15.2f);
    pc.addCols(cdo.getColValue("meses"),1,1,15.2f);
    pc.addCols(cdo.getColValue("observacion"),0,3);
    pc.addCols(cdo.getColValue("fecha"),1,2);
    pc.addCols(cdo.getColValue("usuario_creacion"),1,1);
}

Properties prop1 = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = 'NEEU'");

pc.addCols(" ",0,dHeader.size());

String alergias = "";

if (prop1.getProperty("alergia0").equalsIgnoreCase("n")) alergias = "[ X ] Niega     ";
else alergias = "[   ] Niega     ";
if (prop1.getProperty("alergia1").equalsIgnoreCase("a")) alergias += "[ X ] Alimentos     ";
else  alergias += "[   ] Alimentos     ";
if (prop1.getProperty("alergia2").equalsIgnoreCase("ai")) alergias += "[ X ] Aines     ";
else  alergias += "[   ] Aines     ";
if (prop1.getProperty("alergia3").equalsIgnoreCase("at")) alergias += "[ X ] Antibióticos     ";
else  alergias += "[ X ] Antibióticos     ";
if (prop1.getProperty("alergia4").equalsIgnoreCase("m")) alergias += "[ X ] Medicamentos     ";
else  alergias += "[   ] Medicamentos     ";
if (prop1.getProperty("alergia5").equalsIgnoreCase("y")) alergias += "[ X ] YODO     ";
else  alergias += "[   ] YODO     ";
if (prop1.getProperty("alergia6").equalsIgnoreCase("s")) alergias += "[ X ] Sulfa     ";
else  alergias += "[   ] Sulfa     ";
if (prop1.getProperty("alergia7").equalsIgnoreCase("o")) alergias += "[ X ] Otros";
else  alergias += "[  ] Otros";

pc.addCols("Alergias:    "+alergias,0,dHeader.size());
if( prop1.getProperty("alergia7").equalsIgnoreCase("o")&&!prop1.getProperty("alergia0").equalsIgnoreCase("n")){
    pc.addCols("Comentarios: "+prop1.getProperty("otros8"),0,dHeader.size());
}

if (prop.getProperty("alergia0").equalsIgnoreCase("0")) alergias = "[ X ] Niega     ";
else alergias = "[   ] Niega     ";
if (prop.getProperty("alergia1").equalsIgnoreCase("1")) alergias += "[ X ] Alimentos     ";
else  alergias += "[   ] Alimentos     ";
if (prop.getProperty("alergia2").equalsIgnoreCase("2")) alergias += "[ X ] Medicamentos     ";
else  alergias += "[   ] Medicamentos";

alergias += "      (Especifique): "+prop.getProperty("observacion0");

pc.addCols("Alergias (KARDEX):    "+alergias,0,dHeader.size());

pc.addCols(" ",0,dHeader.size());

String barrerasB = "";
Properties propB = SQLMgr.getDataProperties("select evaluaciones from tbl_sal_eval_aprendizaje where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+codBarrera);
if (propB == null) propB = new Properties();

if (propB.getProperty("barrera0").equalsIgnoreCase("nt")) barrerasB = "[ X ] No tiene     ";
else barrerasB = "[    ] No tiene     ";
if (propB.getProperty("barrera1").equalsIgnoreCase("lec")) barrerasB += "[ X ] Lectura     ";
else barrerasB += "[    ] Lectura     ";
if (propB.getProperty("barrera3").equalsIgnoreCase("vis")) barrerasB += "[ X ] Visual     ";
else barrerasB += "[    ] Visual     ";
if (propB.getProperty("barrera4").equalsIgnoreCase("aud")) barrerasB += "[ X ] Auditiva     ";
else barrerasB += "[    ] Auditiva     ";
if (propB.getProperty("barrera5").equalsIgnoreCase("fis")) barrerasB += "[ X ] Física     ";
else barrerasB += "[    ] Física     ";
if (propB.getProperty("barrera6").equalsIgnoreCase("emo")) barrerasB += "[ X ] Emocional     ";
else barrerasB += "[    ] Emocional     ";
if (propB.getProperty("barrera7").equalsIgnoreCase("cul")) barrerasB += "[ X ] Cultural";
else barrerasB += "[    ] Cultural";

barrerasB += "\n                ";
if (propB.getProperty("barrera8").equalsIgnoreCase("ot")) barrerasB += "[ X ] Otras: "+propB.getProperty("observacion2");
else barrerasB += "[    ] Otras:";

pc.addCols("Barreras: "+barrerasB,0,dHeader.size());


String barreras = "";
if (prop.getProperty("barreras0").equalsIgnoreCase("0")) barreras = "[ X ] Emocionales     ";
else barreras = "[   ] Emocionales     ";
if (prop.getProperty("barreras1").equalsIgnoreCase("1")) barreras += "[ X ] Culturales     ";
else barreras += "[   ] Culturales     ";
if (prop.getProperty("barreras2").equalsIgnoreCase("2")) barreras += "[ X ] Idioma     ";
else barreras += "[   ] Idioma     ";
if (prop.getProperty("barreras3").equalsIgnoreCase("OT")) barreras += "[ X ] Otras     ";
else barreras += "[   ] Otras";
pc.addCols("Barreras (KARDEX):    "+barreras,0,dHeader.size());
pc.addCols("(Especifique):    "+prop.getProperty("observacion1"),0,dHeader.size());

pc.addCols(" ",0,dHeader.size());

String vul = "";
if(prop1.getProperty("riesgo_vulnerabilidad").equals("0")) vul = "[ X ] Paciente con Enfermedad Crónica";
else vul = "[    ] Paciente con Enfermedad Crónica";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("15")) vul += "\n[ X ] Paciente de Cuidado Crítico";
else vul += "\n[    ] Paciente de Cuidado Crítico";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("1")) vul += "\n[ X ] Paciente cuyo sistema inmunológico se encuentra afectado (Inmunosuprimido)";
else vul += "\n[    ] Paciente cuyo sistema inmunológico se encuentra afectado (Inmunosuprimido)";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("2")) vul += "\n[ X ] Embarazada (evaluación especifica de obstetricia, cribado)";
else vul += "\n[    ] Embarazada (evaluación especifica de obstetricia, cribado)";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("3")) vul += "\n[ X ] Pediátrico (evaluación especifica crecimiento y desarrollo, dolor, caída, cribado y Plan de cuidado)";
else vul += "\n[    ] Pediátrico (evaluación especifica crecimiento y desarrollo, dolor, caída, cribado y Plan de cuidado)";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("4")) vul += "\n[ X ] Adolescentes (evaluación especifica del adolescente)";
else vul += "\n[    ] Adolescentes (evaluación especifica del adolescente)";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("5")) vul += "\n[ X ] Adulto Mayor (75 años en adelante) (evaluación especifica Escala)";
else vul += "\n[    ] Adulto Mayor (75 años en adelante) (evaluación especifica Escala)";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("6")) vul += "\n[ X ] Discapacidad física(evaluación especifica Escala)";
else vul += "\n[    ] Discapacidad física(evaluación especifica Escala)";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("7")) vul += "\n[ X ] Pacientes en fase terminal (evaluación especifica Escala)";
else vul += "\n[    ] Pacientes en fase terminal (evaluación especifica Escala)";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("8")) vul += "\n[ X ] Pacientes con dolor intenso o crónico";
else vul += "\n[    ] Pacientes con dolor intenso o crónico";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("9")) vul += "\n[ X ] Paciente en quimioterapia o radioterapia";
else vul += "\n[    ] Paciente en quimioterapia o radioterapia";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("10")) vul += "\n[ X ] Pacientes con enfermedades infecciosas o contagiosas";
else vul += "\n[    ] Pacientes con enfermedades infecciosas o contagiosas";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("11")) vul += "\n[ X ] Sospecha Pacientes con trastornos emocionales o psiquiátricos";
else vul += "\n[    ] Sospecha Pacientes con trastornos emocionales o psiquiátricos";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("12")) vul += "\n[ X ] Pacientes con presunta dependencia de las drogas y/o alcohol";
else vul += "\n[    ] Pacientes con presunta dependencia de las drogas y/o alcohol";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("13")) vul += "\n[ X ] Sospecha Victima de abuso y abandono";
else vul += "\n[    ] Sospecha Victima de abuso y abandono";

if(prop1.getProperty("riesgo_vulnerabilidad").equals("14")) vul += "\n[ X ] Ninguno";
else vul += "\n[    ] Ninguno";

pc.setFont(9,1);
pc.addCols("Evaluación de Riesgo y/o Vulnerabilidad",0,dHeader.size());
pc.setFont(9,0);

pc.addCols(vul,0,dHeader.size());
pc.addCols(" ",0,dHeader.size());

String pv = "";
if (prop.getProperty("paciente_vulnerable").equals("0")) pv = "[ X ] SI      [   ] NO";
else if (prop.getProperty("paciente_vulnerable").equals("1")) pv = "[   ] SI      [ X ] NO";
pv += "\n\n(Especifique): "+prop.getProperty("observacion2");
pc.addCols("Paciente Vulnerable (KARDEX): "+pv,0,dHeader.size());
pc.addCols(" ",0,dHeader.size());

pc.setFont(9,1);
pc.addCols("AISLAMIENTO",0,dHeader.size());
pc.setFont(9,0);

String aislamientos = "";

prop1 = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = 'C1'");
if (prop.getProperty("aislamiento").equalsIgnoreCase("s")) {

    if (prop1.getProperty("aislamiento_det1").equalsIgnoreCase("1")) aislamientos = "[ X ] Paciente con Aislamiento de Contacto";
    else  aislamientos = "[   ] Paciente con Aislamiento de Contacto";

    if (prop1.getProperty("aislamiento_det3").equalsIgnoreCase("3")) aislamientos += "      [ X ] Paciente Con Aislamiento de Gotas";
    else  aislamientos += "      [   ] Paciente Con Aislamiento de Gotas";

    if (prop1.getProperty("aislamiento_det5").equalsIgnoreCase("5")) aislamientos += "      [ X ] Paciente con Aislamiento Respiratorio (Gotitas)";
    else  aislamientos += "      [   ] Paciente con Aislamiento Respiratorio (Gotitas)";

    if (prop1.getProperty("aislamiento_det0").equalsIgnoreCase("0")) aislamientos += "\n\n[ X ] Orientación al paciente y familiar";
    else  aislamientos += "\n\n[   ] Orientación al paciente y familiar";

    if (prop1.getProperty("aislamiento_det2").equalsIgnoreCase("2")) aislamientos += "      [ X ] Coordinación con la enfermera de nosocomial";
    else  aislamientos += "      [   ] Coordinación con la enfermera de nosocomial";

    if (prop1.getProperty("aislamiento_det4").equalsIgnoreCase("4")) aislamientos += "      [ X ] Colocación del equipo de protección";
    else  aislamientos += "      [   ] Colocación del equipo de protección";

    pc.addCols(aislamientos,0,dHeader.size());

} else {
    pc.addCols(">>",0,dHeader.size());
    pc.addCols(">>",0,dHeader.size());
}

if (prop.getProperty("aislamiento0").equalsIgnoreCase("0")) aislamientos = "[ X ] Ninguno     ";
else  aislamientos = "[   ] Ninguno     ";
if (prop.getProperty("aislamiento1").equalsIgnoreCase("1")) aislamientos += "[ X ] Contacto     ";
else  aislamientos += "[   ] Contacto     ";
if (prop.getProperty("aislamiento2").equalsIgnoreCase("2")) aislamientos += "[ X ] Gotas     ";
else  aislamientos += "[   ] Gotas     ";
if (prop.getProperty("aislamiento3").equalsIgnoreCase("3")) aislamientos += "[ X ] Respiratorio";
else  aislamientos += "[   ] Respiratorio";

pc.addCols(" ",0,dHeader.size());
pc.addCols("AISLAMIENTO (KARDEX):  "+aislamientos,0,dHeader.size());

pc.addCols(" ",0,dHeader.size());
pc.addCols("Riesgo de caída: "+(prop.getProperty("riesgo_caida").equals("0")?"BAJO":"ALTO"),0,dHeader.size());
pc.addCols("Riesgo de úlcera: "+(prop.getProperty("riesgo_ulcera").equals("0")?"BAJO":"ALTO"),0,dHeader.size());

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("PLAN DE ENFERMERÍA",0,dHeader.size());

pc.addBorderCols("AUTO CUIDADO (Higiene,alimentación, movilidad)",0,5);
pc.addBorderCols("ESTADO DE PIEL",0,5);

String paramsPlanEnf = "";
pc.setFont(9,0);

if(prop.getProperty("auto_cuidado0").equals("0")) paramsPlanEnf = "[ X ] No requiere ayuda";
else paramsPlanEnf = "[   ] No requiere ayuda";

if(prop.getProperty("auto_cuidado1").equals("1")) paramsPlanEnf += "\n\n[ X ] Ayuda Parcial";
else paramsPlanEnf += "\n\n[   ] Ayuda Parcial";

if(prop.getProperty("auto_cuidado2").equals("2")) paramsPlanEnf += "\n\n[ X ] Ayuda Total";
else paramsPlanEnf += "\n\n[   ] Ayuda Total";

if(prop.getProperty("auto_cuidado3").equals("3")) paramsPlanEnf += "\n\n[ X ] Otros:  "+prop.getProperty("observacion3");
else paramsPlanEnf += "\n\n[   ] Otros";

pc.addBorderCols(paramsPlanEnf,0,5);

paramsPlanEnf = "";
if(prop.getProperty("estado_piel0").equals("0")) paramsPlanEnf = "[ X ] Evaluación diaria";
else paramsPlanEnf = "[   ] Evaluación diaria";

if(prop.getProperty("estado_piel1").equals("1")) paramsPlanEnf += "\n\n[ X ] Valoración de puntos de presión y uso de dispositivos";
else paramsPlanEnf += "\n\n[   ] Valoración de puntos de presión y uso de dispositivos";

if(prop.getProperty("estado_piel2").equals("2")) paramsPlanEnf += "\n\n[ X ] Control de humedad";
else paramsPlanEnf += "\n\n[   ] Control de humedad";

if(prop.getProperty("estado_piel3").equals("3")) paramsPlanEnf += "\n\n[ X ] Cambio de Posición cada: "+prop.getProperty("observacion4");
else paramsPlanEnf += "\n\n[   ] Cambio de Posición cada: ";

if(prop.getProperty("estado_piel4").equals("4")) paramsPlanEnf += "\n\n[ X ] Otros: "+prop.getProperty("observacion5");
else paramsPlanEnf += "\n\n[   ] Otros: ";

pc.addBorderCols(paramsPlanEnf,0,5);

pc.setFont(9,1);
pc.addBorderCols("ESPIRITUAL / CREENCIAS / CULTURA",0,5);
pc.addBorderCols("EDUCACIÓN / APRENDIZAJE",0,5);

pc.setFont(9,0);

if(prop.getProperty("espiritual0").equals("0")) paramsPlanEnf = "[ X ] Ayuda espiritual(pastor, sacerdote)";
else paramsPlanEnf = "[   ] Ayuda espiritual(pastor, sacerdote)";

if(prop.getProperty("espiritual1").equals("1")) paramsPlanEnf += "\n\n[ X ] Servicio religioso";
else paramsPlanEnf += "\n\n[   ] Servicio religioso";

if(prop.getProperty("espiritual2").equals("2")) paramsPlanEnf += "\n\n[ X ] Otros:  "+prop.getProperty("observacion6");
else paramsPlanEnf += "\n\n[   ] Otros:  ";

pc.addBorderCols(paramsPlanEnf,0,5);

paramsPlanEnf = "";
if(prop.getProperty("aprendizaje0").equals("0")) paramsPlanEnf = "[ X ] Prevención de caídas";
else paramsPlanEnf = "[   ] Prevención de caídas";

if(prop.getProperty("aprendizaje1").equals("1")) paramsPlanEnf += "\n\n[ X ] Tips de seguridad";
else paramsPlanEnf += "\n\n[   ] Tips de seguridad";

if(prop.getProperty("aprendizaje2").equals("2")) paramsPlanEnf += "\n\n[ X ] Manejo del dolor";
else paramsPlanEnf += "\n\n[   ] Manejo del dolor";

if(prop.getProperty("aprendizaje3").equals("3")) paramsPlanEnf += "\n\n[ X ] Medidas de Aislamiento";
else paramsPlanEnf += "\n\n[   ] Medidas de Aislamiento";

if(prop.getProperty("aprendizaje4").equals("4")) paramsPlanEnf += "\n\n[ X ] Otros:  "+prop.getProperty("observacion7");
else paramsPlanEnf += "\n\n[   ] Otros";

pc.addBorderCols(paramsPlanEnf,0,5);

pc.setFont(9,1);
pc.addBorderCols("CUIDADOS DE ENFERMERÍA",0,5);
pc.addBorderCols("SOCIAL / ECONOMICA",0,5);

pc.setFont(9,0);
if(prop.getProperty("cuidados_enf_0").equals("0")) paramsPlanEnf = "[ X ] Gastrostomía";
else paramsPlanEnf = "[   ] Gastrostomía";

if(prop.getProperty("cuidados_enf_1").equals("1")) paramsPlanEnf += "\n\n[ X ] Traqueotomía";
else paramsPlanEnf += "\n\n[   ] Traqueotomía";

if(prop.getProperty("cuidados_enf_2").equals("2")) paramsPlanEnf += "\n\n[ X ] Ileostomía";
else paramsPlanEnf += "\n\n[   ] Ileostomía";

if(prop.getProperty("cuidados_enf_3").equals("3")) paramsPlanEnf += "\n\n[ X ] Catéter Venoso Central";
else paramsPlanEnf += "\n\n[   ] Catéter Venoso Central";

if(prop.getProperty("cuidados_enf_4").equals("4")) paramsPlanEnf += "\n\n[ X ] Otros:  "+prop.getProperty("observacion8");
else paramsPlanEnf += "\n\n[   ] Otros: ";

pc.addBorderCols(paramsPlanEnf,0,5);

paramsPlanEnf = "";
if(prop.getProperty("social_econo_0").equals("0")) paramsPlanEnf += "[ X ] Evaluación por Personal de Atención al Cliente";
else paramsPlanEnf += "[   ] Evaluación por Personal de Atención al Cliente";
if(prop.getProperty("social_econo_1").equals("1")) paramsPlanEnf += "\n\n[ X ] Otros:  "+prop.getProperty("observacion9");
else paramsPlanEnf += "[   ] Otros: ";

pc.addBorderCols(paramsPlanEnf,0,5);

pc.setFont(9,1);
pc.addBorderCols("EVALUACIÓN POR:",0,5);
pc.addBorderCols("PLANIFICACIÓN TEMPRANA DEL EGRESO",0,5);

pc.setFont(9,0);
paramsPlanEnf = "";
if(prop.getProperty("evaluado_por_0").equals("0")) paramsPlanEnf += "[ X ] Nutricionista";
else paramsPlanEnf += "[   ] Nutricionista";

if(prop.getProperty("evaluado_por_1").equals("1")) paramsPlanEnf += "\n\n[ X ] Nosocomial";
else paramsPlanEnf += "\n\n[   ] Nosocomial";

if(prop.getProperty("evaluado_por_2").equals("2")) paramsPlanEnf += "\n\n[ X ] Médico Hospitalista";
else paramsPlanEnf += "\n\n[   ] Médico Hospitalista";

if(prop.getProperty("evaluado_por_3").equals("3")) paramsPlanEnf += "\n\n[ X ]  T. respiratoria ";
else paramsPlanEnf += "\n\n[   ]  T. respiratoria";

if(prop.getProperty("evaluado_por_4").equals("4")) paramsPlanEnf += "\n\n[ X ]  Otros: "+prop.getProperty("observacion10");
else paramsPlanEnf += "\n\n[   ]  Otros: ";

pc.addBorderCols(paramsPlanEnf,0,5);

paramsPlanEnf = "";
if(prop.getProperty("planificacion_0").equals("0")) paramsPlanEnf = "[ X ]  Educación";
else paramsPlanEnf += "[   ]  Educación";

if(prop.getProperty("planificacion_1").equals("1")) paramsPlanEnf += "\n\n[ X ]  Transporte";
else paramsPlanEnf += "\n\n[   ]  Transporte";

if(prop.getProperty("planificacion_2").equals("2")) paramsPlanEnf += "\n\n[ X ]  Médico Hospitalista ";
else paramsPlanEnf += "\n\n[   ]  Médico Hospitalista";

if(prop.getProperty("planificacion_3").equals("3")) paramsPlanEnf += "\n\n[ X ]  Personas de apoyo en casa";
else paramsPlanEnf += "\n\n[   ]  Personas de apoyo en casa";

if(prop.getProperty("planificacion_4").equals("4")) paramsPlanEnf += "\n\n[ X ]  Otros:  "+prop.getProperty("observacion11");
else paramsPlanEnf += "\n\n[   ]  Otros: ";

pc.addBorderCols(paramsPlanEnf,0,5);

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("PLAN MÉDICO",0,dHeader.size());

pc.addCols("",0,dHeader.size());
pc.addBorderCols("DIETA",0,dHeader.size());

StringBuffer sbSql = new StringBuffer();

sbSql.append("select cod_paciente, fec_nacimiento, secuencia,tipo_orden tipoOrden, orden_med ordenMed, codigo, nombre, to_char(fecha_inicio,'dd/mm/yyyy hh12:mi am')fechaInicio, nvl(to_char(fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin,  observacion, ejecutado, centro_servicio, usuario_creacion, fecha_creacion, usuario_modificacion, fecha_modificacion,tipo_dieta tipoDieta,  cod_tipo_dieta codTipoDieta, tipo_tubo tipoTubo, fecha_orden, omitir_orden, pac_id, fecha_suspencion, obser_suspencion, (select descripcion from tbl_sal_desc_estado_ord where estado=estado_orden) as estado_orden, (select d.descripcion from TBL_CDS_TIPO_DIETA d where d.codigo = tipo_dieta) as dieta from tbl_sal_detalle_orden_med where tipo_orden = 3 and pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" order by fecha_inicio desc");

al = SQLMgr.getDataList(sbSql.toString());

pc.setFont(9,1);
pc.addBorderCols("Desde",1,1);
pc.addBorderCols("Hasta",1,1);
pc.addBorderCols("Usuario",1,1);
pc.addBorderCols("Dieta",1,3);
pc.addBorderCols("Descripción",1,3);
pc.addBorderCols("Tubo",1,1);

String tubo = "";
for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);

    pc.setFont(7, 0);
    pc.addCols(cdo.getColValue("fechaInicio"),1,1);
    pc.addCols(cdo.getColValue("fechaFin"),1,1);
    pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
    pc.addCols(cdo.getColValue("dieta"),0,3);
    pc.addCols(cdo.getColValue("observacion").replace(",",", "),0,3);

    if ( cdo.getColValue("tipoTubo").equalsIgnoreCase("G") ) tubo = "GOTEO";
    else if ( cdo.getColValue("tipoTubo").equalsIgnoreCase("N") ) tubo = "BOLO";
    else tubo = "";

    pc.addCols(tubo,1,1);

    pc.addBorderCols("",1,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
    pc.addCols("",1,dHeader.size(),3f);

} //for

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addBorderCols("OM NUTRICION PARENTERAL ADULTO",0,dHeader.size());

Vector tbl1 = new Vector();
tbl1.addElement("16.7");
tbl1.addElement("16.7");
tbl1.addElement("16.7");
tbl1.addElement("16.7");
tbl1.addElement("16.7");
tbl1.addElement("16.7");

pc.setNoColumnFixWidth(tbl1);
pc.createTable("tbl1");
pc.setFont(9,0);

al = SQLMgr.getDataPropertiesList("select evaluacion from tbl_sal_nutricion_parenteral where pac_id="+pacId+" and admision="+noAdmision+"and tipo = 'EA' order by id desc ");

for(int p = 0; p<al.size(); p++){
    Properties prop2 = (Properties) al.get(p);

    pc.setFont(10,1);
    pc.addCols("No.: "+(1+p),0,dHeader.size());

    pc.setFont(10,1, Color.white);
    pc.addCols("DATOS GENERALES",0,dHeader.size(), Color.gray);

    pc.setFont(7,0);
    pc.addBorderCols("Fecha "+prop2.getProperty("fecha"),0,3);
    pc.addBorderCols("Hora de Inicio "+prop2.getProperty("hora_inicio"),0,3);

    /* pc.addBorderCols(prop2.getProperty("peso")+ " (Kg)",1,1);
     pc.addBorderCols("   X       "+prop2.getProperty("volumen")+" (ml/por/dia)",1,1);
     pc.addBorderCols("   =       "+prop2.getProperty("volumen_dia")+"       (ml/por/dia)",1,1);
     pc.addBorderCols("   24 Hrs = "+    prop2.getProperty("volumen_total")+"      (ml/hrs)",1,1);
     pc.addCols("",1,1);

     pc.addBorderCols("Peso",1,1);
     pc.addBorderCols("Volumen de Líquido NPT",1,1);
     pc.addBorderCols("Volumen total por dia",1,1);
     pc.addBorderCols("Volumen total en 24 horas",1,1);
     pc.addCols("",1,1);
     pc.addCols(" ",0,dHeader.size(),5.2f);*/

     pc.setFont(10,1, Color.white);
     pc.addCols("MACRONUTRIENTES",0,dHeader.size(), Color.gray);

     pc.setFont(7,0);
     pc.addBorderCols("Aminoácidos:",0,1);
     pc.addBorderCols(prop2.getProperty("macro1")+"            %",0,1);
     pc.addBorderCols("Volumen:",0,1);
     pc.addBorderCols(prop2.getProperty("macroVol1")+"            ml24Hr. o G/kg.",0,1);
     pc.addBorderCols(prop2.getProperty("cantidad1"),0,1);
     pc.addCols("",0,1);

     pc.addBorderCols("D/A:",0,1);
     pc.addBorderCols(prop2.getProperty("macro2")+"            %",0,1);
     pc.addBorderCols("Volumen:",0,1);
     pc.addBorderCols(prop2.getProperty("macroVol2")+"            ml24Hr. o G/kg.",0,1);
     pc.addBorderCols(prop2.getProperty("cantidad2"),0,1);
     pc.addCols("",0,1);

     pc.addBorderCols("Lípidos:",0,1);
     pc.addBorderCols(prop2.getProperty("macro3")+"            %",0,1);
     pc.addBorderCols("Volumen:",0,1);
     pc.addBorderCols(prop2.getProperty("macroVol3")+"            ml24Hr. o G/kg.",0,1);
     pc.addBorderCols(prop2.getProperty("cantidad3"),0,1);
     pc.addCols("",0,1);

     pc.addBorderCols("Lípidos:",0,1);
     pc.addBorderCols(prop2.getProperty("macro4")+"            %",0,1);
     pc.addBorderCols("Volumen:",0,1);
     pc.addBorderCols(prop2.getProperty("macroVol4")+"            ml24Hr. o G/kg.",0,1);
     pc.addBorderCols(prop2.getProperty("cantidad4"),0,1);
     pc.addCols("",0,1);

     pc.addBorderCols("Lípidos:",0,1);
     pc.addBorderCols(prop2.getProperty("macro5")+"            %",0,1);
     pc.addBorderCols("Volumen:",0,1);
     pc.addBorderCols(prop2.getProperty("macroVol5")+"            ml24Hr. o G/kg.",0,1);
     pc.addBorderCols(prop2.getProperty("cantidad5"),0,1);
     pc.addCols("",0,1);

     pc.setFont(10,1, Color.white);
     pc.addCols("ELECTROLITOS(POR DIA)",0,dHeader.size(), Color.gray);
     pc.setFont(7,0);

     pc.addCols("NaCi 4mEq/ml",0,1);
     pc.addCols(prop2.getProperty("electro1"),0,1);
     pc.addCols("mEq/dia",0,1);
     pc.addCols("Elementos Trazos",0,1);
     pc.addCols(prop2.getProperty("electro2"),0,1);
     pc.addCols("ml/24hr",0,1);

     pc.addCols("Acetato de Sodio 2mEq/ml",0,1);
     pc.addCols(prop2.getProperty("electro3"),0,1);
     pc.addCols("mEq/dia",0,1);
     pc.addCols("Heparina",0,1);
     pc.addCols(prop2.getProperty("electro4"),0,1);
     pc.addCols("U/dia",0,1);

     pc.addCols("Acetato de Potasio 2mEq/ml",0,1);
     pc.addCols(prop2.getProperty("electro5"),0,1);
     pc.addCols("mEq/dia",0,1);
     pc.addCols("Insulina",0,1);
     pc.addCols(prop2.getProperty("electro6"),0,1);
     pc.addCols("U/dia",0,1);

     pc.addCols("KCI 2mEq/ml",0,1);
     pc.addCols(prop2.getProperty("electro5"),0,1);
     pc.addCols("mEq/dia",0,1);
     pc.addCols("Multivitaminas I.V",0,1);
     pc.addCols(prop2.getProperty("electro8"),0,1);
     pc.addCols("ml/24Hr",0,1);

     pc.addCols("KPO4, 4.4mEq/ml",0,1);
     pc.addCols(prop2.getProperty("electro9"),0,1);
     pc.addCols("mEq/dia",0,1);
     pc.addCols("",0,1);
     pc.addCols(prop2.getProperty("electro10"),0,2);

     pc.addCols("CaGlu. 0.465mEq/ml",0,1);
     pc.addCols(prop2.getProperty("electro11"),0,1);
     pc.addCols("ml",0,1);
     pc.addCols("",0,1);
     pc.addCols(prop2.getProperty("electro12"),0,2);

     pc.addCols("MgSO4 0.81mEq/ml",0,1);
     pc.addCols(prop2.getProperty("electro13"),0,1);
     pc.addCols("mEq/dia",0,1);
     pc.addCols(prop2.getProperty("electro14"),0,1);
     pc.addCols("ml",0,1);
     pc.addCols(prop2.getProperty("electro15"),0,1);

     pc.addCols("Vol. de Infusión",0,1);
     pc.addCols(prop2.getProperty("infusion"),0,1);
     pc.addCols("cc/hr.",0,1);
     pc.addCols("Vol. Total de la Sol",0,1);
     pc.addCols(prop2.getProperty("solucion"),0,1);
     pc.addCols("",0,1);

     pc.addCols("Via de Administración",0,1);
     pc.addCols(prop2.getProperty("via"),0,1);
     pc.addCols("cc/hr.",0,1);
     pc.addCols("",0,3);

     pc.addCols("",0,dHeader.size(),7.2f);
     pc.setFont(9,1);
     pc.addCols("Observaciones para la Farmacia",0,dHeader.size());
     pc.setFont(7,0);
     pc.addCols(prop2.getProperty("observacion"),0,dHeader.size());

     pc.addCols(" ",0,dHeader.size(),10.2f);
}

pc.useTable("main");
pc.addTableToCols("tbl1",0,dHeader.size());

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addBorderCols("OM NUTRICION PARENTERAL NEONATAL Y PEDIATRICO",0,dHeader.size());

Vector tbl2 = new Vector();
tbl2.addElement("20");
tbl2.addElement("20");
tbl2.addElement("20");
tbl2.addElement("20");
tbl2.addElement("20");

pc.setNoColumnFixWidth(tbl2);
pc.createTable("tbl2");
pc.setFont(9,0);

al = SQLMgr.getDataPropertiesList("select evaluacion from tbl_sal_nutricion_parenteral where pac_id="+pacId+" and admision="+noAdmision+"and tipo = 'EN' order by id desc ");

for(int i = 0; i<al.size(); i++){

        Properties prop2 = (Properties) al.get(i);

        pc.setFont(10,1);
        pc.addCols("No.: "+(1+i),0,dHeader.size());

        pc.setFont(10,1, Color.white);
        pc.addCols("DATOS GENERALES",0,dHeader.size(), Color.gray);

        pc.setFont(7,0);
        pc.addBorderCols("Fecha "+prop2.getProperty("fecha"),0,2);
        pc.addBorderCols("Hora inicio "+prop2.getProperty("hora_inicio")+"     ml/Hrs",0,2);
        pc.addCols(" ",0,1);

         pc.addBorderCols(prop2.getProperty("peso")+ " (Kg)",1,1);
         pc.addBorderCols("   X       "+prop2.getProperty("volumen")+" (ml/por/dia)",1,1);
         pc.addBorderCols("   =       "+prop2.getProperty("volumen_dia")+"       (ml/por/dia)",1,1);
         pc.addBorderCols("   24 Hrs = "+    prop2.getProperty("volumen_total")+"      (ml/hrs)",1,1);
         pc.addCols("",1,1);

         pc.addBorderCols("Peso",1,1);
         pc.addBorderCols("Volumen de Líquido NPT",1,1);
         pc.addBorderCols("Volumen total por día",1,1);
         pc.addBorderCols("Volumen total en 24 horas",1,1);
         pc.addCols("",1,1);
         pc.addCols(" ",0,dHeader.size(),5.2f);

         pc.setFont(10,1, Color.white);
         pc.addCols("MACRONUTRIENTES",0,dHeader.size(), Color.gray);

         pc.setFont(7,0);
         pc.addBorderCols("Aminoácidos:        "+prop2.getProperty("macro1")+" Gms/Kg/Día",0,1);
         pc.addBorderCols("Tipo de A.A(%):        "+prop2.getProperty("macro2")+" Gms/Kg/Día",0,1);
         pc.addBorderCols("Volumen:        "+prop2.getProperty("macro3")+" ml/24Hr.",0,1);
         pc.addBorderCols("GM N:        "+prop2.getProperty("macro4")+" ml/24Hr.",0,1);
         pc.addCols("",0,1);

         pc.addBorderCols("Aminoácidos Especiales:        "+prop2.getProperty("macro5")+" Gms/Kg/Día.",0,2);
         pc.addBorderCols("Volumen:        "+prop2.getProperty("macro6")+" ml/24Hr.",0,1);
         pc.addCols("",0,2);
         pc.addCols("(REQUIERE APROBACION DEL SERVICIO DE SOPORTE NUTRICIONAL)",0, dHeader.size(),Color.green);
         pc.addBorderCols("Dextrosa:       "+prop2.getProperty("macro7")+" % final.",0,2);
         pc.addCols("",0,1);
         pc.addBorderCols("Volumen:       "+prop2.getProperty("macro8")+" ml/24Hr.",0,1);
         pc.addCols("",0,1);

         pc.addBorderCols("Kcal:       "+prop2.getProperty("macro9")+" % final.",0,1);
         pc.addBorderCols("Lípidos 10%  20%      "+prop2.getProperty("macro10")+" Gm/Kg/Día",0,1);
         pc.addBorderCols(prop2.getProperty("macro11"),0,1);
         pc.addBorderCols("Volumen:       "+prop2.getProperty("macro12")+" ml/24Hr.",0,1);
         pc.addBorderCols("Kcal:       "+prop2.getProperty("macro13"),0,1);
         pc.addCols(" ",0,dHeader.size(),5.2f);

         pc.setFont(10,1, Color.white);
         pc.addCols("ELECTROLITOS(POR DIA)",0,dHeader.size(), Color.gray);

         pc.setFont(7,0);
         pc.addBorderCols("NaCl:       ",0,1);
         pc.addBorderCols(prop2.getProperty("electro1"),0,1);
         pc.addBorderCols(" mEq/kg",0,1);
         pc.addBorderCols(prop2.getProperty("electro2"),0,1);
         pc.addBorderCols(" mEq/dia",0,1);

         pc.addBorderCols("Insulina(Reg)",0,1);
         pc.addBorderCols(prop2.getProperty("electro6"),0,1);
         pc.addBorderCols("U/dia",0,1);
         pc.addCols("",0,2);

         pc.addBorderCols("Acetato Na:       ",0,1);
         pc.addBorderCols(prop2.getProperty("electro4"),0,1);
         pc.addBorderCols(" mEq/kg",0,1);
         pc.addBorderCols(prop2.getProperty("electro5"),0,1);
         pc.addBorderCols(" mEq/dia",0,1);

         pc.addBorderCols("Gluconato de Calcio",0,1);
         pc.addBorderCols(prop2.getProperty("electro3"),0,1);
         pc.addBorderCols(" ml/kg",0,1);
         pc.addCols("",0,2);

         pc.addBorderCols("Fosfato Na:       ",0,1);
         pc.addBorderCols(prop2.getProperty("electro7"),0,1);
         pc.addBorderCols(" mEq/kg",0,1);
         pc.addBorderCols(prop2.getProperty("electro8"),0,1);
         pc.addBorderCols(" mEq/dia",0,1);

         pc.addBorderCols("Heparina",0,1);
         pc.addBorderCols(prop2.getProperty("electro9"),0,1);
         pc.addBorderCols("U/dia",0,1);
         pc.addCols("",0,2);

         pc.addBorderCols("KCL:       ",0,1);
         pc.addBorderCols(prop2.getProperty("electro10"),0,1);
         pc.addBorderCols(" mEq/kg",0,1);
         pc.addBorderCols(prop2.getProperty("electro11"),0,1);
         pc.addBorderCols(" mEq/dia",0,1);

         pc.addBorderCols("Acetato K",0,1);
         pc.addBorderCols(prop2.getProperty("electro13"),0,1);
         pc.addBorderCols(" mEq/kg",0,1);
         pc.addBorderCols(prop2.getProperty("electro14"),0,1);
         pc.addBorderCols(" mEq/dia",0,1);

         pc.addBorderCols("Fosfato K",0,1);
         pc.addBorderCols(prop2.getProperty("electro15"),0,1);
         pc.addBorderCols(" mEq/kg",0,1);
         pc.addBorderCols(prop2.getProperty("electro16"),0,1);
         pc.addBorderCols(" mEq/dia",0,1);

         pc.addBorderCols("MgSO",0,1);
         pc.addBorderCols(prop2.getProperty("electro17"),0,1);
         pc.addBorderCols(" mEq/kg",0,1);
         pc.addBorderCols(prop2.getProperty("electro18"),0,1);
         pc.addBorderCols(" mEq/dia",0,1);

         pc.addBorderCols("Elementos Trazas:",0,1);
         pc.addBorderCols(prop2.getProperty("electro19"),0,1);
         pc.addBorderCols("ml/24Hrs",0,1);
         pc.addBorderCols("Zn Adicional:",0,1);
         pc.addBorderCols(prop2.getProperty("electro21")+ "        (mcg/dia)",0,1);

         pc.addBorderCols("ultivitaminas Pediátricas: ",0,1);

         String ulvit1="",ulvit2="",ulvit3="";

         if(prop2.getProperty("electro20").equals("S")) ulvit1 = "1.5 ml si es menor de 1 kg";
         if(prop2.getProperty("electro22").equals("S")) ulvit2 = "3.25 ml si es menor de 1 - 3 kg";
         if(prop2.getProperty("electro23").equals("S")) ulvit3 = "5 ml si es menor de 3 kg";

         pc.addBorderCols(ulvit1,0,1);
         pc.addBorderCols(ulvit2,0,1);
         pc.addBorderCols(ulvit3,0,1);
         pc.addBorderCols("",0,1);

         pc.addCols(" ",0,dHeader.size(),5.2f);
         pc.addCols("Otros:",0,dHeader.size());
         pc.addBorderCols(prop2.getProperty("electro12"),0,dHeader.size());

         pc.addCols(" ",0,dHeader.size(),10.2f);
}

pc.useTable("main");
pc.addTableToCols("tbl2",0,dHeader.size());

pc.setFont(9,1);
pc.addBorderCols("DIETAS (KARDEX)",0,dHeader.size());

pc.setFont(9,0);
String dietasKardex = "";
if (prop.getProperty("dietas_0").equals("0")) dietasKardex = "[ X ] NADA POR BOCA";
else  dietasKardex = "[  ] NADA POR BOCA";

if (prop.getProperty("dietas_1").equals("1")) dietasKardex += "\n\n[ X ] CORRIENTE";
else  dietasKardex += "\n\n[  ] CORRIENTE";

if (prop.getProperty("dietas_2").equals("2")) dietasKardex += "\n\n[ X ] BLANDA";
else  dietasKardex += "\n\n[  ] BLANDA";

if (prop.getProperty("dietas_3").equals("3")) dietasKardex += "\n\n[ X ] LÍQUIDA";
else  dietasKardex += "\n\n[  ] LÍQUIDA";

if (prop.getProperty("dietas_4").equals("4")) dietasKardex += "\n\n[ X ] KOSHER";
else  dietasKardex += "\n\n[  ] KOSHER";

if (prop.getProperty("dietas_5").equals("5")) dietasKardex += "\n\n[ X ] PARA DIABÉTICO";
else  dietasKardex += "\n\n[  ] PARA DIABÉTICO";


if (prop.getProperty("dietas_6").equals("6")) dietasKardex += "\n\n[ X ] NUTRICION PARENTERAL";
else  dietasKardex += "\n\n[  ] NUTRICION PARENTERAL";

pc.addBorderCols(dietasKardex,0,dHeader.size());

pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1);

String inhalo = "";
if ( prop.getProperty("inhaloterapia").equals("0")) inhalo = "[ X ] SI      [   ] NO";
else if ( prop.getProperty("inhaloterapia").equals("1")) inhalo = "[   ] SI      [ X ] NO";
else inhalo = "[   ] SI      [   ] NO";

inhalo += "        Cada: "+prop.getProperty("observacion12");
pc.addBorderCols("INHALOTERAPIA:   "+inhalo,0,dHeader.size());

sbSql = new StringBuffer();
sbSql.append("select a.codigo as codigo, a.descripcion , c.observacion , c.nombre as nombre, to_char(c.fecha_inicio,'dd/mm/yyyy') as fecha, to_char(c.fecha_orden,'hh12:mi:ss am') as hora, c.estado_orden as estado,(select descripcion from tbl_sal_desc_estado_ord where estado=c.estado_orden) as estadodesc, c.prioridad as prioridad,(select  primer_nombre || ' ' ||segundo_nombre || ' ' || decode(apellido_de_casada, null, primer_apellido|| ' ' || segundo_apellido,primer_apellido||' '|| apellido_de_casada) as nombre_medico from tbl_adm_medico where codigo=rs.medico ) as nombre_medico,to_char(c.fecha_modificacion,'hh12:mi') as fecha_modificacion,to_char(omitir_fecha,'dd/mm/yyyy')omitir_fecha,to_char(c.fecha_fin,'dd/mm/yyyy hh12:mi:ss am')fecha_fin from tbl_sal_tratamiento a, tbl_sal_detalle_orden_med c, tbl_sal_orden_medica rs where c.tipo_orden='4' and rs.secuencia=c.secuencia and c.pac_id=rs.pac_id and c.cod_tratamiento=a.codigo and rs.codigo=c.orden_med and rs.pac_id=");
sbSql.append(pacId);
sbSql.append(" and rs.secuencia=");
sbSql.append(noAdmision);
sbSql.append(" and upper(a.descripcion) like '%INHALOTERAPIA%' ");
al = SQLMgr.getDataList(sbSql.toString());

Vector tbl3 = new Vector();
tbl3.addElement(".09");
tbl3.addElement(".08");
tbl3.addElement(".30");
tbl3.addElement(".20");
tbl3.addElement(".20");
tbl3.addElement(".35");

pc.setNoColumnFixWidth(tbl3);
pc.createTable("tbl3");

pc.addBorderCols("FECHA",1);
pc.addBorderCols("HORA",1);
pc.addBorderCols("DIAGNOSTICO/TRATAMIENTO",1);
pc.addBorderCols("MEDICO SOLICITANTE",1);
pc.addBorderCols("FECHA HASTA/ OMISION",1);
pc.addBorderCols("OBSERVACION",1);
pc.setFont(9,0);

for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    pc.addCols(cdo.getColValue("fecha"),0,1);
    pc.addCols(cdo.getColValue("fecha_modificacion"),1,1);
    pc.addCols(cdo.getColValue("descripcion"),0,1);
    pc.addCols(cdo.getColValue("nombre_medico"),0,1);
    pc.addCols(""+cdo.getColValue("fecha_fin")+"/"+cdo.getColValue("omitir_fecha"),0,1);
    pc.addCols(cdo.getColValue("observacion"),0,1);
}

pc.useTable("main");
pc.addTableToCols("tbl3",0,dHeader.size());

pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1);

String cateter = "";
if ( prop.getProperty("cateter").equals("0")) cateter = "[ X ] SI      [   ] NO";
else if ( prop.getProperty("cateter").equals("1")) cateter = "[   ] SI      [ X ] NO";
else cateter = "[   ] SI      [   ] NO";

pc.addBorderCols("CATETER:   "+cateter,0,dHeader.size());

pc.setFont(9,1);
pc.addBorderCols("SONDAS / CATETERES",0,dHeader.size());
pc.setFont(9,0);

String sondas = "";

if (prop.getProperty("sonda").equalsIgnoreCase("n")) {
    pc.addBorderCols(">>",0,dHeader.size());
    pc.addBorderCols(">>",0,dHeader.size());
} else {
    String codeNota = request.getParameter("code_nota") == null ? "0" : request.getParameter("code_nota");
    Properties prop2 = SQLMgr.getDataProperties("select nota from tbl_sal_notas_diarias_enf where id = "+codeNota+" and tipo_nota = 'NDE'");

    if (prop2 == null) prop2 = new Properties();

    if (prop2.getProperty("sondas0").equals("0")) sondas = "[ X ] Periférico";
    else sondas = "[  ] Periférico";

    if (prop2.getProperty("sondas1").equals("1")) sondas += "\n\n[ X ] Epidural";
    else sondas += "\n\n[  ] Epidural";

    if (prop2.getProperty("sondas2").equals("2")) sondas += "\n\n[ X ] Nasoenteral";
    else sondas += "\n\n[  ] Nasoenteral";

    if (prop2.getProperty("sondas3").equals("3")) sondas += "\n\n[ X ] Venoso Central";
    else sondas += "\n\n[  ] Venoso Central";

    if (prop2.getProperty("sondas4").equals("OT")) sondas += "\n\n[ X ] Otros: "+prop.getProperty("observacion8");
    else sondas += "\n\n[  ] Otros: ";

    pc.addCols(sondas,0,dHeader.size());
}
String sondasKardex = "";
pc.addCols("",0,dHeader.size());
pc.addBorderCols("Sondas / Cateteres (KARDEX)",0,dHeader.size());

if(prop.getProperty("cateter_0").equals("0")) sondasKardex = "[ X ] SELLO VENOSO";
else sondasKardex = "[   ] SELLO VENOSO";

if(prop.getProperty("cateter_1").equals("1")) sondasKardex += "\n\n[ X ] CATETER VENOSO CENTRAL CVC";
else sondasKardex += "\n\n[   ] CATETER VENOSO CENTRAL CVC";

if(prop.getProperty("cateter_2").equals("2")) sondasKardex += "\n\n[ X ] CEPIDURAL";
else sondasKardex += "\n\n[   ] EPIDURAL";

if(prop.getProperty("cateter_3").equals("3")) sondasKardex += "\n\n[ X ] VENOCLISIS (Especifique):    "+prop.getProperty("observacion13");
else sondasKardex += "\n\n[   ] VENOCLISIS (Especifique): ";

pc.addCols(sondasKardex,0,dHeader.size());

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addBorderCols("SIGNOS VITALES     Cada:  "+prop.getProperty("observacion14"),0,3);
pc.addBorderCols("CURACIONES",0,3);
pc.addBorderCols("GLICEMIA",0,4);

pc.setFont(9,0);
String dolorGlasgow = "";
if(prop.getProperty("dolor").equalsIgnoreCase("0")) dolorGlasgow = "DOLOR:   [ X ] SI     [    ] NO";
else if(prop.getProperty("dolor").equalsIgnoreCase("1")) dolorGlasgow = "DOLOR:   [   ] SI     [ X ] NO";
else dolorGlasgow = "DOLOR:   [    ] SI     [    ] NO";

if(prop.getProperty("glasgow").equalsIgnoreCase("0")) dolorGlasgow += "\n\nGLASGOW:   [ X ] SI     [    ] NO";
else if(prop.getProperty("glasgow").equalsIgnoreCase("1")) dolorGlasgow += "\n\nGLASGOW:   [   ] SI     [ X ] NO";
else dolorGlasgow += "\n\nGLASGOW:   [    ] SI     [    ] NO";

pc.addBorderCols(dolorGlasgow,0,3);

String curaciones = "";
if (prop.getProperty("curaciones").equals("0")) curaciones = "[ X ] SI     [    ] NO";
else if (prop.getProperty("curaciones").equals("1")) curaciones = "[   ] SI     [ X ] NO";

curaciones += "        Cada:  "+prop.getProperty("observacion15");
pc.addBorderCols(curaciones,0,3);

String glicemia = "";
if (prop.getProperty("glicemia").equals("0")) glicemia = "[ X ] SI     [    ] NO";
else if (prop.getProperty("glicemia").equals("1")) glicemia = "[   ] SI     [ X ] NO";

glicemia += "        Cada:  "+prop.getProperty("observacion16");
pc.addBorderCols(glicemia,0,4);

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("OM ESQUEMA INSULINA",0,dHeader.size());

al = SQLMgr.getDataList("select id, to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fechaOrden,codigo,escala,valor,insulina from tbl_sal_esquema_insulina where  pac_id = "+pacId+" and admision = "+noAdmision+" order by fecha desc");

String groupByid = "";
for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    if ( !groupByid.trim().equals(cdo.getColValue("id")) ){

        if ( i!= 0 ){
            pc.addCols(" ",0,dHeader.size());
        }

        pc.setFont(9, 1,Color.white);
        pc.addBorderCols("FECHA: "+cdo.getColValue("fechaOrden"),0,5,Color.gray);
        pc.addBorderCols("INSULINA: "+cdo.getColValue("insulina"),0,5,Color.gray);

        pc.setFont(9, 1);
        pc.addBorderCols("ESCALA",1,5);
        pc.addBorderCols("VALOR",1,5);
    }
    pc.setFont(9,0);
    pc.addCols("["+cdo.getColValue("codigo")+"] "+cdo.getColValue("escala"),0,5);
    pc.addCols(cdo.getColValue("valor"),0,5);
    groupByid = cdo.getColValue("id");
}

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
if (prop.getProperty("balance_hidrico").equals("0")) pc.addCols("BALANCE HIDRICO:         [ X ] SI     [   ] NO",0,dHeader.size());
else if (prop.getProperty("balance_hidrico").equals("1")) pc.addCols("BALANCE HIDRICO:         [   ] SI     [ X ] NO",0,dHeader.size());
else pc.addCols("BALANCE HIDRICO:         [   ] SI     [   ] NO",0,dHeader.size());

al = SQLMgr.getDataList("SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi am') as hora, a.via_administracion, b.descripcion, a.fluido, nvl(a.cantidad,0) as cantidad, b.tipo_liquido, bb.usuario_creacion||'/'||bb.usuario_modificacion usuario FROM tbl_sal_detalle_balance a, tbl_sal_via_admin b, tbl_sal_balance_hidrico bb WHERE a.via_administracion = b.codigo AND b.tipo_liquido IN ('E','I','M') AND a.pac_id = "+pacId+" AND a.adm_secuencia = "+noAdmision+" and bb.codigo = (select max(codigo) from tbl_sal_balance_hidrico where pac_id = bb.pac_id and secuencia = bb.secuencia) and bb.fecha = a.fecha and bb.codigo = a.cod_balance and bb.secuencia = a.adm_secuencia and bb.pac_id = a.pac_id   group by to_char(a.fecha,'dd/mm/yyyy'), to_char(a.hora,'hh12:mi am'), a.via_administracion, b.descripcion, a.fluido, a.cantidad, b.tipo_liquido, bb.usuario_creacion||'/'||bb.usuario_modificacion order by 7 desc, to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') desc, to_date(to_char(a.hora,'hh12:mi am'),'hh12:mi am') ");

Vector tbl4 = new Vector();
tbl4.addElement(".07");
tbl4.addElement(".06");
tbl4.addElement(".15");
tbl4.addElement(".18");
tbl4.addElement(".31");
tbl4.addElement(".13");
tbl4.addElement(".10");

pc.setNoColumnFixWidth(tbl4);
pc.createTable("tbl4");

pc.addBorderCols("FECHA",1);
pc.addBorderCols("HORA",1);
pc.addBorderCols("USUARIO",1);
pc.addBorderCols("VIA ADMINISTRACION",1);
pc.addBorderCols("DESCRIPCION",1);
pc.addBorderCols("FLUIDO",1);
pc.addBorderCols("CANTIDAD",1);

pc.addBorderCols("Liquidos Administrados",0,tbl4.size(),0.0f,0.10f,0.0f,0.0f);
String tipoLiqui = "";
double totalAdminis = 0;
double totalElimini = 0;
double totalBalance = 0;

for (int i=0; i<al.size(); i++) {
    cdo = (CommonDataObject) al.get(i);

    if (cdo.getColValue("tipo_Liquido").equalsIgnoreCase("I")) totalAdminis += Double.parseDouble(cdo.getColValue("Cantidad"));
    else totalElimini += Double.parseDouble(cdo.getColValue("Cantidad"));

    if ( (!tipoLiqui.equals(cdo.getColValue("Tipo_Liquido")) && i != 0) || (cdo.getColValue("Tipo_Liquido").equalsIgnoreCase("E") && i == 0) ) {

        pc.setFont(8, 0);
        pc.addCols("Total Administrados",2,6);
        pc.addCols(CmnMgr.getFormattedDecimal(totalAdminis),2,1);

        pc.addBorderCols("Liquidos Eliminados",0,dHeader.size(),0.0f,0.10f,0.0f,0.0f);

    }

    pc.addBorderCols(cdo.getColValue("fecha"),1,1,0.0f,0.0f,0.0f,0.0f);
    pc.addBorderCols(cdo.getColValue("hora"),1,1,0.0f,0.0f,0.0f,0.0f);
    pc.addBorderCols(cdo.getColValue("usuario"),1,1,0.0f,0.0f,0.0f,0.0f);
    pc.addBorderCols(cdo.getColValue("via_administracion"),1,1,0.0f,0.0f,0.0f,0.0f);
    pc.addBorderCols(cdo.getColValue("Descripcion"),0,1,0.0f,0.0f,0.0f,0.0f);
    pc.addBorderCols(cdo.getColValue("Fluido"),1,1,0.0f,0.0f,0.0f,0.0f);
    pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("Cantidad")),2,1,0.0f,0.0f,0.0f,0.0f);

	tipoLiqui = cdo.getColValue("tipo_Liquido");
}
	totalBalance = totalAdminis - totalElimini ;

if (al.size() != 0) {

    if (tipoLiqui.equalsIgnoreCase("I")) {

        pc.setFont(8, 0);
        pc.addCols("Total Administrados",2,6);
        pc.addCols(""+totalAdminis,1,1);

    }

    pc.setFont(8, 0);
    pc.addCols("Total Eliminados",2,6);
    pc.addCols(CmnMgr.getFormattedDecimal(totalElimini),2,1);
    pc.addCols("B A L A N C E",2,6);
    pc.addCols(CmnMgr.getFormattedDecimal(totalBalance),2,1);

}

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
if (prop.getProperty("tratamientos").equals("0")) pc.addCols("TRATAMIENTOS:         [ X ] SI     [   ] NO",0,dHeader.size());
else if (prop.getProperty("tratamientos").equals("1")) pc.addCols("TRATAMIENTOS:         [   ] SI     [ X ] NO",0,dHeader.size());
else pc.addCols("TRATAMIENTOS:         [   ] SI     [   ] NO",0,dHeader.size());

pc.useTable("main");
pc.addTableToCols("tbl4",0,dHeader.size());

sbSql = new StringBuffer();

sbSql.append("select a.codigo as codigo, a.descripcion , c.observacion , c.nombre as nombre, to_char(c.fecha_inicio,'dd/mm/yyyy') as fecha, to_char(c.fecha_orden,'hh12:mi:ss am') as hora, c.estado_orden as estado,(select descripcion from tbl_sal_desc_estado_ord where estado=c.estado_orden)  as estadodesc, c.prioridad as prioridad,(select  primer_nombre || ' ' ||segundo_nombre || ' ' || decode(apellido_de_casada, null, primer_apellido|| ' ' || segundo_apellido,primer_apellido||' '|| apellido_de_casada) as nombre_medico from tbl_adm_medico where codigo=rs.medico ) as nombre_medico,to_char(c.fecha_modificacion,'hh12:mi') as fecha_modificacion,to_char(omitir_fecha,'dd/mm/yyyy')omitir_fecha,to_char(c.fecha_fin,'dd/mm/yyyy hh12:mi:ss am')fecha_fin from tbl_sal_tratamiento a, tbl_sal_detalle_orden_med c, tbl_sal_orden_medica rs where c.tipo_orden='4' and rs.secuencia=c.secuencia and c.pac_id=rs.pac_id and c.cod_tratamiento=a.codigo and rs.codigo=c.orden_med and rs.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and rs.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and upper(a.descripcion) not in ('INHALOTERAPIA') order by c.fecha_creacion asc ");

al = SQLMgr.getDataList(sbSql.toString());

Vector tbl5 = new Vector();
tbl5.addElement(".09");
tbl5.addElement(".08");
tbl5.addElement(".30");
tbl5.addElement(".20");
tbl5.addElement(".20");
tbl5.addElement(".35");

pc.setNoColumnFixWidth(tbl5);
pc.createTable("tbl5");

pc.addBorderCols("FECHA",1);
pc.addBorderCols("HORA",1);
pc.addBorderCols("DIAGNOSTICO/TRATAMIENTO",1);
pc.addBorderCols("MEDICO SOLICITANTE",1);
pc.addBorderCols("FECHA HASTA/ OMISION",1);
pc.addBorderCols("OBSERVACION",1);

pc.setFont(9,0);
for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    pc.addCols(cdo.getColValue("fecha"),0,1);
    pc.addCols(cdo.getColValue("fecha_modificacion"),1,1);
    pc.addCols(cdo.getColValue("descripcion"),0,1);
    pc.addCols(cdo.getColValue("nombre_medico"),0,1);
    pc.addCols(""+cdo.getColValue("fecha_fin")+"/"+cdo.getColValue("omitir_fecha"),0,1);
    pc.addCols(cdo.getColValue("observacion"),0,1);
}

pc.useTable("main");
pc.addTableToCols("tbl5",0,dHeader.size());

sbSql = new StringBuffer();
sbSql.append("select a.secuencia as secuenciaCorte, a.usuario_creacion, to_char(a.fecha_inicio,'dd/mm/yyyy')||decode(a.prioridad,'O','',' '||to_char(a.fecha_creacion,'hh12:mi:ss am'))as fecha_inicio, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, decode(a.tipo_orden,3,x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre),7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, tipo_orden, a.codigo, a.orden_med, a.usuario_creacion uc, a.usuario_modificacion um, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') as fecha_fin, nvl(a.cod_salida,0) as cod_salida,a.tipo_ordenvarios,a.subtipo_ordenvarios, nvl(y.desc1, ' ') desc1, nvl(y.desc2, ' ') desc2,nvl(a.ejecutado_usuario,'')ejecutado_usuario ");

sbSql.append(" , (select uu.name from tbl_sec_users uu where uu.user_name = a.usuario_creacion) as complete_name ");

sbSql.append(" from tbl_sal_detalle_orden_med a, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo=c.cod_tipo_dieta(+) union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, (select t.codigo, t.descripcion desc1, st.codigo sub_tipo_codigo, st.descripcion desc2, st.cod_tipo_ordenvarios from tbl_cds_ordenmedica_varios t, tbl_cds_om_varios_subtipo st where st.cod_tipo_ordenvarios = t.codigo) y, tbl_sal_orden_salida d, tbl_adm_admision z where z.pac_id=a.pac_id and z.secuencia=a.secuencia and z.pac_id=");
sbSql.append(pacId);
sbSql.append(" and z.adm_root = ");
sbSql.append(noAdmision);
sbSql.append(" and a.tipo_orden = 8 ");
sbSql.append(" /*and a.omitir_orden='N' and a.estado_orden<>'O' */ and a.tipo_dieta||'-'||a.cod_tipo_dieta=x.codigo(+) and a.cod_salida=d.codigo(+) and y.codigo(+) = a.tipo_ordenvarios and y.sub_tipo_codigo(+) = a.subtipo_ordenvarios order by a.fecha_creacion desc");

al = SQLMgr.getDataList(sbSql.toString());

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("INDICACIONES GENERALES",0,dHeader.size());
pc.addCols("OM VARIAS",0,dHeader.size());

Vector tbl6 = new Vector();
tbl6.addElement(".18");
tbl6.addElement(".14");
tbl6.addElement(".11");
tbl6.addElement(".20");
tbl6.addElement(".25");
tbl6.addElement(".12");

pc.setNoColumnFixWidth(tbl6);
pc.createTable("tbl6");

pc.addBorderCols("Fecha",1,1);
pc.addBorderCols("Usuario", 1,1);
pc.addBorderCols("Orden Varios",1,1);
pc.addBorderCols("Sub Orden Varios",1,1);
pc.addBorderCols("Descripción",1,1);
pc.addBorderCols("Estado",1,1);

pc.setFont(9,0);
for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    pc.addCols(cdo.getColValue("fecha_inicio"),0,1);
    pc.addCols(cdo.getColValue("complete_name"),0,1);
    pc.addCols(cdo.getColValue("desc1"),0,1);
    pc.addCols(cdo.getColValue("desc2"),0,1);
	pc.addCols(cdo.getColValue("nombre"),0,1);
	pc.addCols(cdo.getColValue("estado_orden"),1,1);
}

pc.useTable("main");
pc.addTableToCols("tbl6",0,dHeader.size());

pc.setFont(9, 1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("OM VARIAS (KARDEX)",0,dHeader.size());
pc.setFont(9, 0);
if (prop.getProperty("om_varias_0").equals("0")) pc.addCols("[ X ] Otros:     "+prop.getProperty("observacion17"),0,dHeader.size());
else pc.addCols("[   ] Otros: ",0,dHeader.size());

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("EXÁMEN Y/O PRUEBAS",0,dHeader.size());
pc.addCols("OM IMAGENOLOGIA",0,dHeader.size());

al = SQLMgr.getDataList("select to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fechaSolicitud, t.descripcion as tipoOrden, decode(a.tipo_orden,3,'DIETA - '||x.nombre||' '||decode(a.nombre,null,' ',' - '||a.nombre), 1, a.nombre||decode(a.prioridad,'H',' --> HOY '||to_char(a.fecha_orden,'dd-mm-yyyy'),'U',' - HOY URGENTE '||to_char(a.fecha_orden,'dd-mm-yyyy'),'M',' --> MAÑANA '||to_char(a.fecha_orden,'dd-mm-yyyy'),'O',' --> '||to_char(a.fecha_orden,'dd-mm-yyyy')), 7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, tipo_orden, decode(a.tipo_orden,2,a.codigo_orden_med,a.orden_med) as orden_med, a.estado_orden, o.medico, m.primer_nombre||' '||m.primer_apellido as nombre_medico, p.nombre_paciente, a.pac_id||'-'||a.secuencia pid, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden_desc,decode(a.estado_orden,'O',(select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden)||': '||to_char(a.omitir_fecha,'dd/mm/yyyy hh12:mi am') ||' POR: '||a.omitir_usuario||' - '||(select (select comentario_cancela from tbl_cds_detalle_solicitud where orden_med=a.orden_med and tipo_orden=a.tipo_orden and orden_sec = a.codigo and pac_id =a.pac_id and csxp_admi_secuencia=z.adm_root ) from dual),'') as comentario_ord, a.fecha_creacion,a.orden_med no_ord from tbl_sal_detalle_orden_med a, tbl_sal_orden_medica o,tbl_sal_tipo_orden_med t, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo=c.cod_tipo_dieta union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, tbl_sal_orden_salida d, tbl_adm_admision z, tbl_adm_medico m, vw_adm_paciente p where z.pac_id=a.pac_id and z.secuencia=a.secuencia and a.tipo_orden=t.codigo(+) and a.tipo_dieta||'-'||a.cod_tipo_dieta=x.codigo(+) and a.cod_salida=d.codigo(+) and a.orden_med = o.codigo and a.secuencia = o.secuencia and a.pac_id = o.pac_id and o.medico = m.codigo and p.pac_id = a.pac_id and ((a.omitir_orden='N' and a.estado_orden='A') or (a.ejecutado='N' and a.estado_orden='S')) and a.tipo_orden = 1 and a.pac_id = "+pacId+" and z.adm_root = "+noAdmision+" and a.centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz = 'RIS') order by a.fecha_creacion, a.pac_id, z.adm_root, a.orden_med");

String groupBy = "";
pc.setFont(9, 1);

pc.addBorderCols("Médico",0,2);
pc.addBorderCols("Orden",0,4);
pc.addBorderCols("Ejecutado",0,1);
pc.addBorderCols("F.Solicitud",0,2);
pc.addBorderCols("Estado",0,1);

pc.setFont(9, 0);
for (int i = 0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);

    pc.addBorderCols(cdo.getColValue("nombre_medico"),0,2);
    pc.addBorderCols(cdo.getColValue("nombre"),0,4);
    pc.addBorderCols(cdo.getColValue("ejecutado"),0,1);
    pc.addBorderCols(cdo.getColValue("fechaSolicitud"),0,2);
    pc.addBorderCols(cdo.getColValue("estado_orden_desc"),0,1);
}

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("INTERCONSULTAS",0,dHeader.size());

al = SQLMgr.getDataList("select to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha_real, to_char(a.fecha_creacion,'hh12:mi am') as hora, b.primer_nombre||decode(b.segundo_nombre,'','',' '||b.segundo_nombre)||' '||b.primer_apellido|| decode(b.segundo_apellido, null,'',' '||b.segundo_apellido)||decode(b.sexo,'F', decode(b.apellido_de_casada,'','',' '||b.apellido_de_casada)) as nombre_medico, a.observacion as observacion, nvl(a.cod_especialidad,' ') as cod_especialidad, esp.descripcion as desesp from tbl_sal_interconsultor a, tbl_adm_medico b, tbl_adm_especialidad_medica esp Where a.medico=b.codigo(+) and esp.codigo(+)=a.cod_especialidad and a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" order by a.fecha_creacion desc");

pc.addBorderCols("FECHA",1,1);
pc.addBorderCols("HORA",1,1);
pc.addBorderCols("MEDICO SOLICITADO",0,2);
pc.addBorderCols("ESPECIALIDAD",0,3);
pc.addBorderCols("OBSERVACION",0,3);

pc.setFont(9,0);

for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);

    pc.setFont(7, 0);
    pc.addBorderCols(cdo.getColValue("fecha_real"),1,1);
    pc.addBorderCols(cdo.getColValue("hora"),1,1);
    pc.addBorderCols(cdo.getColValue("nombre_medico"),0,2);
    pc.addBorderCols(cdo.getColValue("desesp"),0,3);
    pc.addBorderCols(cdo.getColValue("observacion"),0,3);
}

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("SONDA /CATETERES",0,dHeader.size());

al = SQLMgr.getDataList("SELECT a.codigo as codigoInfeccion, a.descripcion as descripcion, b.codigo as codigo, b.infec_pac as infecPac, to_char(b.fecha_inf,'dd/mm/yyyy') as fechaInf, to_char(b.fecha_ini,'dd/mm/yyyy') as fechaIni, to_char(b.fecha_cambio,'dd/mm/yyyy') as fechaCambio, to_char(b.fecha_retiro,'dd/mm/yyyy') as fechaRetiro, b.observacion as observacion, to_char(b.fecha_cultivo,'dd/mm/yyyy') as fechaCultivo, b.total_dias as totalDias,  (select c.usuario_creacion||'/'||c.usuario_modificacion from TBL_SAL_INFECCION_PACIENTE c where b.secuencia = c.secuencia and b.fec_nacimiento = c.fec_nacimiento and b.cod_paciente = c.cod_paciente and b.fecha_inf = c.fecha_registro ) usuario FROM TBL_SAL_INFECCION a, TBL_SAL_DETALLE_INFECCION b where a.codigo=b.codigo and b.pac_id = "+pacId+" and b.secuencia = "+noAdmision);

Vector tbl7 = new Vector();
tbl7.addElement(".25");
tbl7.addElement(".09");
tbl7.addElement(".09");
tbl7.addElement(".09");
tbl7.addElement(".09");
tbl7.addElement(".09");
tbl7.addElement(".20");
tbl7.addElement(".10");

pc.setNoColumnFixWidth(tbl7);
pc.createTable("tbl7");

pc.addBorderCols("PROCEDIMIENTO",0,1);
pc.addBorderCols("F. INICIO",1,1);
pc.addBorderCols("F. CAMBIO",1,1);
pc.addBorderCols("F. CULTIVO",1,1);
pc.addBorderCols("F. RETIRO",1,1);
pc.addBorderCols("T.DIAS",1,1);
pc.addBorderCols("OBSERVACION",0,1);
pc.addBorderCols("USUARIO",1,1);

pc.setFont(9,0);

for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);

    pc.addBorderCols(""+cdo.getColValue("descripcion"),0,1,0.5f,0.0f,0.5f,0.0f);
    pc.addBorderCols(""+cdo.getColValue("fechaIni"),1,1,0.5f,0.0f,0.5f,0.0f);
    pc.addBorderCols(""+cdo.getColValue("fechaCambio"),1,1,0.5f,0.0f,0.5f,0.0f);
    pc.addBorderCols(""+cdo.getColValue("fechaCultivo"),1,1,0.5f,0.0f,0.5f,0.0f);
    pc.addBorderCols(""+cdo.getColValue("fechaRetiro"),1,1,0.5f,0.0f,0.5f,0.0f);
    pc.addBorderCols(""+cdo.getColValue("totalDias"),1,1,0.5f,0.0f,0.5f,0.0f);
    pc.addBorderCols(""+cdo.getColValue("observacion"),0,1,0.5f,0.0f,0.5f,0.5f);
    pc.addBorderCols(""+(!cdo.getColValue("usuario").equals("/")?cdo.getColValue("usuario"):""),1,1,0.5f,0.0f,0.5f,0.5f);
}

pc.useTable("main");
pc.addTableToCols("tbl7",0,dHeader.size());

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("MEDICAMENTOS /TRATAMIENTOS DOSIS",0,dHeader.size());

sbSql = new StringBuffer();

sbSql.append("select cod_paciente, fec_nacimiento, secuencia,tipo_orden tipoOrden, orden_med ordenMed, codigo, nombre, to_char(fecha_inicio,'dd/mm/yyyy hh12:mi am')fechaInicio, nvl(to_char(fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin,  observacion, ejecutado, centro_servicio, usuario_creacion, fecha_creacion, usuario_modificacion, fecha_modificacion,tipo_dieta tipoDieta,  cod_tipo_dieta codTipoDieta, tipo_tubo tipoTubo, fecha_orden, omitir_orden, pac_id, fecha_suspencion, obser_suspencion, (select descripcion from tbl_sal_desc_estado_ord where estado=estado_orden) as estado_orden, (select d.descripcion from TBL_CDS_TIPO_DIETA d where d.codigo = tipo_dieta) as dieta from tbl_sal_detalle_orden_med where tipo_orden = 2 and pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" order by fecha_inicio desc");

al = SQLMgr.getDataList(sbSql.toString());

pc.setFont(9,1);
pc.addBorderCols("Desde",1,1);
pc.addBorderCols("Hasta",1,1);
pc.addBorderCols("Usuario",1,1);
pc.addBorderCols("Dieta",1,3);
pc.addBorderCols("Descripción",1,3);
pc.addBorderCols("Tubo",1,1);

tubo = "";
for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);

    pc.setFont(7, 0);
    pc.addCols(cdo.getColValue("fechaInicio"),1,1);
    pc.addCols(cdo.getColValue("fechaFin"),1,1);
    pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
    pc.addCols(cdo.getColValue("dieta"),0,3);
    pc.addCols(cdo.getColValue("observacion").replace(",",", "),0,3);

    if ( cdo.getColValue("tipoTubo").equalsIgnoreCase("G") ) tubo = "GOTEO";
    else if ( cdo.getColValue("tipoTubo").equalsIgnoreCase("N") ) tubo = "BOLO";
    else tubo = "";

    pc.addCols(tubo,1,1);

    pc.addBorderCols("",1,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
    pc.addCols("",1,dHeader.size(),3f);

} //for


al = SQLMgr.getDataList("select CODIGO, DESCRIPCION, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy') as FECHA_CREA, USUARIO_MODIF, to_char(FECHA_CREAC,'hh12:mi:ss am') as hora_creac, EKG from TBL_SAL_PROCEDIMIENTO_PACIENTE where pac_id="+pacId+" and secuencia="+noAdmision+" order by FECHA_CREAC DESC");

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("PROCEDIMIENTOS/CIRUGÍAS",0,dHeader.size());

pc.addBorderCols("FECHA",1,1);
pc.addBorderCols("HORA",1,1);
pc.addBorderCols("DESCRIPCION",0,6);
pc.addBorderCols("MEDICO SOLICITANTE",0,2);

pc.setFont(9,0);

for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);

    pc.addCols(cdo.getColValue("FECHA_CREA"),1,1);
    pc.addCols(cdo.getColValue("hora_creac"),1,1);
    pc.addCols(cdo.getColValue("DESCRIPCION"),0,6);
    pc.addCols(cdo.getColValue("nombre_medico"),1,2);
}

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("VALORES CRITICOS",0,dHeader.size());

al = SQLMgr.getDataList("select to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fc, b.descripcion, a.valor, a.observacion, c.descripcion as cds, medico_enterado, quien_recibe, quien_reporta, (select  primer_nombre|| ' '|| primer_apellido from tbl_adm_medico where codigo = medico_enterado and rownum = 1) medico_enterado_nombre, nvl((select nombre_empleado from vw_pla_empleado where to_char(emp_id) = quien_recibe and rownum = 1),(select  primer_nombre|| ' '|| primer_apellido from tbl_adm_medico where codigo = quien_recibe and rownum = 1 )) quien_recibe_nombre, (select nombre_empleado from vw_pla_empleado where to_char(emp_id) = quien_reporta and rownum = 1) quien_reporta_nombre from tbl_sal_val_criticos a, tbl_sal_cds_val_criticos b, tbl_cds_centro_servicio c where a.codigo_valor = b.codigo and a.compania = "+compania+" and b.cds = c.codigo and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by a.fecha_creacion");

Vector tbl8 = new Vector();
tbl8.addElement("15");
tbl8.addElement("37");
tbl8.addElement("15");
tbl8.addElement("33");

String gCds = "";
pc.setNoColumnFixWidth(tbl8);
pc.createTable("tbl8");

for(int i = 0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);

    if (!gCds.equals(cdo.getColValue("cds"))){
       pc.setFont(9, 1);
       pc.addCols(cdo.getColValue("cds"),0,tbl8.size());

       pc.addBorderCols("FECHA",1 ,1);
       pc.addBorderCols("PRUEBA",0 ,1);
       pc.addBorderCols("VALOR CRÍTICO",1 ,1);
       pc.addBorderCols("OBSERVACIÓN",0 ,1);
    }

    pc.setFont(9, 0);
    pc.addCols(cdo.getColValue("fc"),1 ,1);
    pc.addCols(cdo.getColValue("descripcion"),0 ,1);
    pc.addCols(cdo.getColValue("valor"),1 ,1);
    pc.addCols(cdo.getColValue("observacion"),0 ,1);

    pc.setFont(9, 1);
    pc.addCols("RECIBE, TRANSCRIBE, LEE Y CONFIRMA:",0,2);
    pc.setFont(9, 0);
    pc.addCols("["+cdo.getColValue("quien_recibe", UserDet.getRefCode())+"] "+cdo.getColValue("quien_recibe_nombre", UserDet.getName()),0,2);

    pc.setFont(9, 1);
    pc.addCols("QUIEN REPORTA:",0,2);
    pc.setFont(9, 0);
    pc.addCols("["+cdo.getColValue("quien_reporta")+"] "+cdo.getColValue("quien_reporta_nombre"),0,2);

    pc.setFont(9, 1);
    pc.addCols("MÉDICO ENTERADO:",0,2);
    pc.setFont(9, 0);
    pc.addCols("["+cdo.getColValue("medico_enterado")+"] "+cdo.getColValue("medico_enterado_nombre"),0,2);

    pc.addCols(" ",1,tbl8.size());

    gCds = cdo.getColValue("cds");
}

pc.useTable("main");
pc.addTableToCols("tbl8",0,dHeader.size());


sbSql = new StringBuffer();
sbSql.append("select a.secuencia as secuenciaCorte, a.usuario_creacion, to_char(a.fecha_inicio,'dd/mm/yyyy')||decode(a.prioridad,'O','',' '||to_char(a.fecha_creacion,'hh12:mi:ss am'))as fecha_inicio, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, decode(a.tipo_orden,3,x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre),7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, tipo_orden, a.codigo, a.orden_med, a.usuario_creacion uc, a.usuario_modificacion um, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') as fecha_fin, nvl(a.cod_salida,0) as cod_salida,a.tipo_ordenvarios,a.subtipo_ordenvarios, nvl(y.desc1, ' ') desc1, nvl(y.desc2, ' ') desc2,nvl(a.ejecutado_usuario,'')ejecutado_usuario ");

sbSql.append(" , (select uu.name from tbl_sec_users uu where uu.user_name = a.usuario_creacion) as complete_name ");

sbSql.append(" from tbl_sal_detalle_orden_med a, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo=c.cod_tipo_dieta(+) union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, (select t.codigo, t.descripcion desc1, st.codigo sub_tipo_codigo, st.descripcion desc2, st.cod_tipo_ordenvarios from tbl_cds_ordenmedica_varios t, tbl_cds_om_varios_subtipo st where st.cod_tipo_ordenvarios = t.codigo) y, tbl_sal_orden_salida d, tbl_adm_admision z where z.pac_id=a.pac_id and z.secuencia=a.secuencia and z.pac_id=");
sbSql.append(pacId);
sbSql.append(" and z.adm_root = ");
sbSql.append(noAdmision);
sbSql.append(" and a.tipo_orden = 1 and a.ejecutado = 'S' ");
sbSql.append(" /*and a.omitir_orden='N' and a.estado_orden<>'O' */ and a.tipo_dieta||'-'||a.cod_tipo_dieta=x.codigo(+) and a.cod_salida=d.codigo(+) and y.codigo(+) = a.tipo_ordenvarios and y.sub_tipo_codigo(+) = a.subtipo_ordenvarios order by a.fecha_creacion desc");

al = SQLMgr.getDataList(sbSql.toString());

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("LABORATORIOS / IMAGENOLOGIA EJECUTADOS",0,dHeader.size());

Vector tbl9 = new Vector();
tbl9.addElement(".18");
tbl9.addElement(".14");
tbl9.addElement(".11");
tbl9.addElement(".20");
tbl9.addElement(".25");
tbl9.addElement(".12");

pc.setNoColumnFixWidth(tbl9);
pc.createTable("tbl9");

pc.addBorderCols("Fecha",1,1);
pc.addBorderCols("Usuario", 1,1);
pc.addBorderCols("Orden Varios",1,1);
pc.addBorderCols("Sub Orden Varios",1,1);
pc.addBorderCols("Descripción",1,1);
pc.addBorderCols("Estado",1,1);

pc.setFont(9,0);
for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    pc.addCols(cdo.getColValue("fecha_inicio"),0,1);
    pc.addCols(cdo.getColValue("complete_name"),0,1);
    pc.addCols(cdo.getColValue("desc1"),0,1);
    pc.addCols(cdo.getColValue("desc2"),0,1);
	pc.addCols(cdo.getColValue("nombre"),0,1);
	pc.addCols(cdo.getColValue("estado_orden"),1,1);
}

pc.useTable("main");
pc.addTableToCols("tbl9",0,dHeader.size());


pc.addTable();
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>