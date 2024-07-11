<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.admin.Properties"%>
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

CommonDataObject cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String desc = request.getParameter("desc");
String code = request.getParameter("code");

if (code == null) code = "0";
if (fg == null) fg = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

Properties prop = new Properties();

prop = SQLMgr.getDataProperties("select sumario from tbl_sal_sumario_egreso_med where pac_id="+pacId+" and admision="+noAdmision+" and tipo_sumario = '"+fg+"'");

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String year = fecha.substring(6, 10);
String month = fecha.substring(3, 5);
String day = fecha.substring(0, 2);

String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

if (month.equals("01")) month = "january";
else if (month.equals("02")) month = "february";
else if (month.equals("03")) month = "march";
else if (month.equals("04")) month = "april";
else if (month.equals("05")) month = "may";
else if (month.equals("06")) month = "june";
else if (month.equals("07")) month = "july";
else if (month.equals("08")) month = "august";
else if (month.equals("09")) month = "september";
else if (month.equals("10")) month = "october";
else if (month.equals("11")) month = "november";
else month = "december";

String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
String statusPath = "";
String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

float width = 72 * 8.5f;//612
float height = 72 * 11f;//792
boolean isLandscape = false;
float leftRightMargin = 9.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subtitle = desc;
String xtraSubtitle = "";
boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 8;
float cHeight = 12.0f;

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
    isUnifiedExp=true;
}

Vector dHeader = new Vector();
dHeader.addElement(".25");
dHeader.addElement(".25");
dHeader.addElement(".25");
dHeader.addElement(".25");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

pc.setFont(12, 1);

if (prop == null) prop = new Properties();

pc.addCols("Creado el: "+prop.getProperty("fecha_creacion"), 0, 2);
pc.addCols("Creado por: "+prop.getProperty("usuario_creacion"), 0, 2);
pc.addCols("Modificado el: "+prop.getProperty("fecha_modificacion"), 0, 2);
pc.addCols("Modificado por: "+prop.getProperty("usuario_modificacion"), 0, 2);
pc.addCols(" ", 0, dHeader.size());

pc.setTableHeader(4);

pc.setFont(10, 1);
pc.addCols("DATOS GENERALES", 0, dHeader.size(),Color.lightGray);

pc.setFont(10, 0);
pc.addBorderCols("Fecha Egreso:   "+prop.getProperty("fecha_egreso"), 0, 2);
pc.addBorderCols("Días de hospitalización:   "+prop.getProperty("dias_hospitalizados"), 0, 2);
pc.addBorderCols("Diagnóstico de ingreso:   "+prop.getProperty("diagnostico_ingreso"), 0, dHeader.size());


pc.addCols(" ", 0, dHeader.size());

pc.setFont(10, 1);
pc.addCols("  ANTECEDENTES RELEVANTES DURANTE EL NACIMIENTO DEL RECIEN NACIDO", 0, dHeader.size(),Color.lightGray);

String tipoNac = "";
if (prop.getProperty("tipo_nacimiento").equalsIgnoreCase("P")) tipoNac = "[ x ] PARTO      [   ] CESÁREA";
else if (prop.getProperty("tipo_nacimiento").equalsIgnoreCase("C")) tipoNac = "[   ] PARTO      [ x ] CESÁREA";
else tipoNac = "[   ] PARTO      [   ] CESÁREA";

pc.setFont(10, 0);
pc.addBorderCols("Tipo nacimiento:   "+tipoNac, 0, 2);
pc.addBorderCols("Motivos de la Cesárea:   "+prop.getProperty("motivos_cesarea"), 0, 2);
pc.addBorderCols("Datos en el momento de nacer:               PESO: "+prop.getProperty("peso")+" g               TALLA: "+prop.getProperty("talla")+" cm               APGAR: "+prop.getProperty("apgar"), 0, dHeader.size());
pc.addBorderCols("Otros datos en el momento de nacer:   "+prop.getProperty("otros_datos_nacer"), 0, dHeader.size());

pc.addCols(" ", 0, dHeader.size());
pc.setFont(10, 1);
pc.addCols("LABORATORIOS RELEVANTES", 0, dHeader.size(),Color.lightGray);

pc.setFont(10, 0);
pc.addBorderCols("Tipaje sanguíneo y Rh de la madre:   "+prop.getProperty("tipaje_madre"), 0, 2);
pc.addBorderCols("Tipaje sanguíneo y Rh del neonato:   "+prop.getProperty("tipaje_neonato"), 0, 2);

String medInmuRec = "";
if (prop.getProperty("medicamentos_recibidos").equalsIgnoreCase("S")) medInmuRec = "  [ x ] SI      [   ] NO";
else if (prop.getProperty("medicamentos_recibidos").equalsIgnoreCase("N")) medInmuRec = "  [   ] SI      [ x ] NO";
else  medInmuRec = "  [   ] SI      [   ] NO";

pc.setFont(10, 0);
pc.addBorderCols("Medicamentos recibidos:   "+medInmuRec, 0, 2);
pc.addBorderCols("Detallar:   "+prop.getProperty("medicamentos_recibidos_detalle"), 0, 2);

medInmuRec = "";
if (prop.getProperty("inmunizaciones_recibidas").equalsIgnoreCase("S")) medInmuRec = "[ x ] SI      [   ] NO";
else if (prop.getProperty("inmunizaciones_recibidas").equalsIgnoreCase("N")) medInmuRec = "[   ] SI      [ x ] NO";
else medInmuRec = "[   ] SI      [   ] NO";

pc.setFont(10, 0);
pc.addBorderCols("Inmunizaciones recibidas:   "+medInmuRec, 0, 2);
pc.addBorderCols("Detallar:   "+prop.getProperty("inmunizaciones_recibidas_detalle"), 0, 2);

pc.addBorderCols("Evolución médica:   "+prop.getProperty("evolucion_medica"), 0, dHeader.size());
pc.addBorderCols("Diagnóstico de egreso:   "+prop.getProperty("diag_ingreso_desc"), 0, dHeader.size());

pc.addCols(" ", 0, dHeader.size());
pc.setFont(10, 1);
pc.addCols("CONDICIÓN DEL PACIENTE A SU EGRESO", 0, dHeader.size(),Color.lightGray);

String cond = "";
if (prop.getProperty("condicion_egreso").equalsIgnoreCase("SA")) cond = "[ x ] SANO      [  ] RECUPERADO      [  ] CONVALECIENTE      [  ] DEFUNCIÓN";
else if (prop.getProperty("condicion_egreso").equalsIgnoreCase("RE")) cond = "[   ] SANO      [ x ] RECUPERADO      [  ] CONVALECIENTE      [  ] DEFUNCIÓN";
else if (prop.getProperty("condicion_egreso").equalsIgnoreCase("CO")) cond = "[   ] SANO      [   ] RECUPERADO      [ x ] CONVALECIENTE      [  ] DEFUNCIÓN";
else if (prop.getProperty("condicion_egreso").equalsIgnoreCase("DE")) cond = "[   ] SANO      [   ] RECUPERADO      [   ] CONVALECIENTE      [ x ] DEFUNCIÓN";
else  cond = "[   ] SANO      [  ] RECUPERADO      [  ] CONVALECIENTE      [  ] DEFUNCIÓN";

pc.setFont(10, 0);
pc.addBorderCols(cond, 0, dHeader.size());
pc.addBorderCols("Causas defunción:   "+prop.getProperty("causas_defuncion"), 0, dHeader.size());

pc.addCols(" ", 0, dHeader.size());
pc.setFont(10, 1);
pc.addCols("APLICA SI EL NEONATO NO TIENE DEFUNCION", 0, dHeader.size(),Color.lightGray);

String febril = "";
if (prop.getProperty("febril").equalsIgnoreCase("S")) febril = "   [ x ] FEBRIL      [   ] AFEBRIL";
else if (prop.getProperty("febril").equalsIgnoreCase("N")) febril = "   [   ] FEBRIL      [ x ] AFEBRIL";
else febril = "   [   ] FEBRIL      [   ] AFEBRIL";

pc.setFont(10, 0);
pc.addBorderCols("Peso:   "+prop.getProperty("peso_muerto")+" g               "+febril, 0, dHeader.size());

String equiposEsp = "";
if (prop.getProperty("uso_equipos_esp").equalsIgnoreCase("S")) equiposEsp = "   [ x ] SI      [   ] NO";
else if (prop.getProperty("uso_equipos_esp").equalsIgnoreCase("N")) equiposEsp = "   [   ] SI      [ x ] NO";
else equiposEsp = "   [   ] SI      [   ] NO";

pc.setFont(10, 0);
pc.addBorderCols("Uso de equipos especiales:   "+equiposEsp, 0, dHeader.size()-2);
pc.addBorderCols("Detallar:   "+prop.getProperty("equipos_esp"), 0, dHeader.size()-2);

pc.addCols(" ", 0, dHeader.size());
pc.setFont(10, 1);
pc.addCols("CITA MEDICA DE SEGUIMIENTO", 0, dHeader.size(),Color.lightGray);

pc.setFont(10, 0);
pc.addBorderCols("Doctor:   "+prop.getProperty("doctor_nombre"), 0,2);
pc.addBorderCols("Pediatra/Neonatólogo:   "+prop.getProperty("pediatra_neo"), 0,2);

pc.addBorderCols("Fecha Cita:   "+prop.getProperty("fecha_cita"), 0,2);
pc.addBorderCols("Teléfono de contacto:   "+prop.getProperty("telefono_contacto"), 0,2);

String tel = prop.getProperty("telefono_contacto_seg")!=null&&!prop.getProperty("telefono_contacto_seg").equals("") ? prop.getProperty("telefono_contacto_seg") : "                 ";

pc.setFont(10, 3);
pc.addBorderCols("Para el seguimiento o en caso de emergencia, favor contactar de inmediato al teléfono: "+tel+" o acudir al hospital más cercano si se presentan sítomas como:\n\n * Dificultad respiratoria\n * Vómitos persistentes\n * Llanto persistente inexplicable\n * Cambio de coloración de la cara\n * Fiebre de inicio súbito", 0, dHeader.size());

String edu = "";
if (prop.getProperty("responsable_educado").equalsIgnoreCase("S")) edu = "   [ x ] SI      [   ] NO";
else if (prop.getProperty("responsable_educado").equalsIgnoreCase("N")) edu = "   [   ] SI      [ x ] NO";
else edu = "   [   ] SI      [   ] NO";

pc.setFont(10, 0);
pc.addBorderCols("Se educa a la persona responsable del paciente?:   "+edu, 0, dHeader.size());

edu = "";
if (prop.getProperty("recomendaciones").equalsIgnoreCase("S")) edu = "   [ x ] SI      [   ] NO";
else if (prop.getProperty("recomendaciones").equalsIgnoreCase("N")) edu = "   [   ] SI      [ x ] NO";
else edu = "   [   ] SI      [   ] NO";

pc.addBorderCols("Se dan las recomendaciones generales junto con la entrega de las notas de cuidado (carenotes)?:   "+edu, 0, dHeader.size());

pc.addCols(" ", 0, dHeader.size());

// otros laboratorios
pc.setFont(10, 1);
pc.addCols("OTROS LABORATORIOS", 0, dHeader.size(),Color.lightGray);

al = SQLMgr.getDataList("select nota, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion_dsp from tbl_sal_sumario_eg_med_res_lab where pac_id = "+pacId+" and admision = "+noAdmision+" order by fecha_creacion desc");

pc.addBorderCols("FECHA",0,1);
pc.addBorderCols("RESULTADO",0,3);
pc.setFont(10, 0);

for (int i = 0; i<al.size(); i++) {
    CommonDataObject cdo = (CommonDataObject) al.get(i);
    pc.addBorderCols(cdo.getColValue("fecha_creacion_dsp"),0,1);
    pc.addBorderCols(cdo.getColValue("nota"),0,3);
}

if (al.size() == 0){
    for (int t = 0; t<=4; t++) {
        pc.addBorderCols(" ",0,dHeader.size());
    }
}


// procedimientos
pc.addCols(" ", 0, dHeader.size());
pc.setFont(10, 1);
pc.addCols("PROCEDIMIENTOS ESPECIALES INTRAHOSPITALARIOS", 0, dHeader.size(),Color.lightGray);

al = SQLMgr.getDataList("select  a.codigo,a.procedimiento,decode(h.observacion , null , h.descripcion,h.observacion)descProc from tbl_sal_sumario_egres_med_proc a,tbl_cds_procedimiento h where  a.procedimiento = h.codigo and a.pac_id = "+pacId+" and admision = "+noAdmision+" order by a.codigo desc ");

pc.addBorderCols("CÓDIGO",0,1);
pc.addBorderCols("DESCRIPCIÓN",0,3);

pc.setFont(10, 0);
for (int i = 0; i<al.size(); i++) {
    CommonDataObject cdo = (CommonDataObject) al.get(i);
    pc.addBorderCols(cdo.getColValue("procedimiento"),0,1);
    pc.addBorderCols(cdo.getColValue("descProc"),0,3);
}

if (al.size() == 0){
    for (int t = 0; t<=4; t++) {
        pc.addBorderCols(" ",0,dHeader.size());
    }
}

// medicamentos al egreso
pc.addCols(" ", 0, dHeader.size());
pc.setFont(10, 1);
pc.addCols("MEDICAMENTOS AL EGRESO", 0, dHeader.size(),Color.lightGray);

al = SQLMgr.getDataList("select nota, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion_dsp from tbl_sal_sumario_eg_med_medica where pac_id = "+pacId+" and admision = "+noAdmision+" order by fecha_creacion desc");

pc.addBorderCols("FECHA",0,1);
pc.addBorderCols("MEDICAMENTO",0,3);
pc.setFont(10, 0);

for (int i = 0; i<al.size(); i++) {
    CommonDataObject cdo = (CommonDataObject) al.get(i);
    pc.addBorderCols(cdo.getColValue("fecha_creacion_dsp"),0,1);
    pc.addBorderCols(cdo.getColValue("nota"),0,3);
}

if (al.size() == 0){
    for (int t = 0; t<=4; t++) {
        pc.addBorderCols(" ",0,dHeader.size());
    }
}

pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());

pc.addCols("", 0, 1);
pc.addCols("", 1, 2);
pc.addCols("Fecha y hora del egreso:", 0, 1);

pc.addBorderCols("Firma del Médico", 0, 1, 0f,0.5f,0f,0f);
pc.addBorderCols("Firma de la persona responsable", 1, 2, 0f,0.5f,0f,0f);
pc.addCols(prop.getProperty("fecha_egreso"), 0, 1);

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);
}
%>