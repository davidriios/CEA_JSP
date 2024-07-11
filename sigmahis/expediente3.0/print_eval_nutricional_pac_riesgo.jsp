<%//@ page errorPage="../error.jsp" %>
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

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
cdoUsr.addColValue("usuario",userName);

if(desc == null) desc = "";
if(fg == null) fg = "";
if (codigo == null) codigo = "0";
if (formulario == null) formulario = "";

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
float leftRightMargin = 20.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subTitle = !desc.equals("")?desc:"EVALUACION DEL APRENDIZAJE";
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
   
cdo = SQLMgr.getData("select to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, to_char(fecha_modificacion, 'dd/mm/yyyy hh24:mi') fm, usuario_creacion, usuario_modificacion, status from tbl_sal_eval_nutri_riesgo where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+codigo+" and tipo = '"+fg+"'");

if (cdo == null) cdo = new CommonDataObject();

if (cdo.getColValue("status","A").equalsIgnoreCase("I")) {
	pc.setFont(10,0,Color.red);
	pc.addCols("INACTIVO",0,dHeader.size());
}

pc.setFont(9,0);
pc.addCols("Creado el: ",0,1);
pc.addCols(cdo.getColValue("fc"),0,3);
pc.addCols(" Por el usuario: ",2,3);
pc.addCols(cdo.getColValue("usuario_creacion"),0,3);

pc.addCols(" ",1,dHeader.size());

pc.addCols("Fecha:",0,1);
pc.addCols(prop.getProperty("fecha"),0,1);
pc.addCols("Talla: ",2,1);
pc.addCols(prop.getProperty("talla")+" m",0,1);
pc.addCols("Peso: ",2,1);
pc.addCols(prop.getProperty("peso")+" kg",0,1);
pc.addCols("IMC: ",2,1);
pc.addCols(prop.getProperty("imc"),0,1);
pc.addCols("Peso Ajustado: "+prop.getProperty("peso_ajustado"),0,2);

if (fg.trim().equalsIgnoreCase("LAC")){
    pc.addCols("",1,dHeader.size());

    pc.addCols("Peso/Edad:",0,1);
    pc.addCols(prop.getProperty("peso_edad"),0,1);
    pc.addCols("Peso/Talla: ",2,1);
    pc.addCols(prop.getProperty("peso_talla"),0,1);
    pc.addCols("Talla/Edad: ",2,1);
    pc.addCols(prop.getProperty("talla_edad"),0,1);
    pc.addCols(" ",2,4);
}

StringBuffer sbSql = new StringBuffer();

sbSql.append("select cod_paciente, fec_nacimiento, secuencia,tipo_orden tipoOrden, orden_med ordenMed, codigo, nombre, to_char(fecha_inicio,'dd/mm/yyyy hh12:mi am')fechaInicio, nvl(to_char(fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin,  observacion, ejecutado, centro_servicio, usuario_creacion, fecha_creacion, usuario_modificacion, fecha_modificacion,tipo_dieta tipoDieta,  cod_tipo_dieta codTipoDieta, tipo_tubo tipoTubo, fecha_orden, omitir_orden, pac_id, fecha_suspencion, obser_suspencion, (select descripcion from tbl_sal_desc_estado_ord where estado=estado_orden) as estado_orden, (select d.descripcion from TBL_CDS_TIPO_DIETA d where d.codigo = tipo_dieta) as dieta from tbl_sal_detalle_orden_med where tipo_orden = 3 and pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" order by fecha_inicio desc");

al = SQLMgr.getDataList(sbSql.toString());

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("TERAPIA NUTRICIONAL ORDENADA",0,dHeader.size());
pc.setFont(9,0);

if(fg.trim().equalsIgnoreCase("uci")){
    String nutricion = "";
    if (prop.getProperty("estres").equalsIgnoreCase("0")) nutricion = "[ X ] Sin estrés      [   ] Estrés moderado      [   ] Estrés severo";
    else if (prop.getProperty("estres").equalsIgnoreCase("1")) nutricion = "[   ] Sin estrés      [ X ] Estrés moderado      [   ] Estrés severo";
    else if (prop.getProperty("estres").equalsIgnoreCase("2")) nutricion = "[   ] Sin estrés      [   ] Estrés moderado      [ X ] Estrés severo";
    else nutricion = "[   ] Sin estrés      [   ] Estrés moderado      [   ] Estrés severo";
    pc.addCols(nutricion,0,dHeader.size());
    pc.addCols("",0,dHeader.size());
}    

pc.setFont(9,1);
pc.addBorderCols("Desde",1,1);
pc.addBorderCols("Hasta",1,1);
pc.addBorderCols("Usuario",1,1);
pc.addBorderCols("Dieta",1,3);
pc.addBorderCols("Descripción",1,3);
pc.addBorderCols("Tubo",1,1);

String tubo = "";
for (int i=0; i<al.size(); i++){
    CommonDataObject cdoT = (CommonDataObject) al.get(i);
    
    pc.setFont(7, 0);
    pc.addCols(cdoT.getColValue("fechaInicio"),1,1);
    pc.addCols(cdoT.getColValue("fechaFin"),1,1);
    pc.addCols(cdoT.getColValue("usuario_creacion"),0,1);
    pc.addCols(cdoT.getColValue("dieta"),0,3); 
    pc.addCols(cdoT.getColValue("observacion").replace(",",", "),0,3);
    
    if ( cdoT.getColValue("tipoTubo"," ").equalsIgnoreCase("G") ) tubo = "GOTEO";
    else if ( cdoT.getColValue("tipoTubo"," ").equalsIgnoreCase("N") ) tubo = "BOLO";
    else tubo = "";
		
    pc.addCols(tubo,1,1);
    
    pc.addBorderCols("",1,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
    pc.addCols("",1,dHeader.size(),3f);
		
} //for

pc.addCols(" ",1,dHeader.size());

if(fg.trim().equalsIgnoreCase("uci")){
pc.setFont(9, 1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("VALORACION DEL RIESGO NUTRICIONAL ACTUAL",0,dHeader.size(),Color.lightGray);
} else {
pc.setFont(9, 1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("VALORACION GLOBAL SUBJETIVA",0,dHeader.size());
}

pc.setFont(9, 0);

Properties prop1 = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = 'NEEU' /*and id > 0*/");

if (prop1 == null) prop1 = new Properties();
    
String nutricional = "Nutricional:  ";
if (prop1.getProperty("nutricional0").equalsIgnoreCase("c")) nutricional += "[ X ] Normal";
else nutricional += "[   ] Normal";
if (prop1.getProperty("nutricional1").equalsIgnoreCase("t")) nutricional += "      [ X ] Nutrición enteral";
else  nutricional += "     [   ] Nutrición enteral";
if (prop1.getProperty("nutricional2").equalsIgnoreCase("g")) nutricional += "      [ X ] Bajo peso";
else  nutricional += "      [   ] Bajo peso";
if (prop1.getProperty("nutricional3").equalsIgnoreCase("ca")) nutricional += "      [ X ] Sobre peso";
else  nutricional += "      [   ] Sobre peso";
if (prop1.getProperty("nutricional4").equalsIgnoreCase("o")) nutricional += "      [ X ] Otro: "+prop1.getProperty("otros10");
else  nutricional += "      [   ] Otro";

pc.setFont(9, 0);
pc.addCols(nutricional,0,dHeader.size());

pc.setFont(9, 1);
pc.addCols("ANTECEDENTES PERSONALES",0,dHeader.size(),Color.lightGray);

al = SQLMgr.getDataList("SELECT a.codigo AS cod_antecedente, a.descripcion, nvl(b.valor,' ') AS valor, nvl(b.observacion,' ') as observacion from TBL_SAL_DIAGNOSTICO_PERSONAL a, TBL_SAL_ANTECEDENTE_PERSONAL b where a.CODIGO=b.ANTECEDENTE AND b.PAC_ID = "+pacId);

pc.addBorderCols("DIAGNOSTICO",1,5);
pc.addBorderCols("OBSERVACION",1,5);

pc.setFont(9, 0);
for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    pc.addCols(cdo.getColValue("descripcion"),0,5);
    pc.addCols(cdo.getColValue("observacion"),0,5);
}

pc.addCols(" ",1,dHeader.size());
pc.setFont(9, 1);
pc.addCols("ANTECEDENTES FAMILIARES",0,dHeader.size(),Color.lightGray);

al = SQLMgr.getDataList("SELECT a.codigo AS cod_antecedente, a.descripcion, nvl(b.valor,' ') AS valor, nvl(b.observacion,' ') as observacion from TBL_SAL_DIAGNOSTICO_FAMILIAR a, TBL_SAL_ANTECEDENTE_FAMILIAR b where a.CODIGO=b.ANTECEDENTE AND b.PAC_ID = "+pacId);

pc.addBorderCols("DIAGNOSTICO",1,5);
pc.addBorderCols("OBSERVACION",1,5);

pc.setFont(9, 0);

for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    pc.addCols(cdo.getColValue("descripcion"),0,5);
    pc.addCols(cdo.getColValue("observacion"),0,5);
}

String antecedentes = "";
if(prop.getProperty("ant_personales_0").equalsIgnoreCase("0")) antecedentes += "[ X ] Diabetes";
else  antecedentes += "[   ] Diabetes";
if(prop.getProperty("ant_personales_1").equalsIgnoreCase("1")) antecedentes += "       [ X ] Hipertensión Arterial";
else  antecedentes += "       [   ] Hipertensión Arterial";
if(prop.getProperty("ant_personales_2").equalsIgnoreCase("2")) antecedentes += "       [ X ] Dislipidemia";
else  antecedentes += "       [   ] Dislipidemia";
if(prop.getProperty("ant_personales_3").equalsIgnoreCase("3")) antecedentes += "       [ X ] Cardiopatía";
else  antecedentes += "       [   ] Cardiopatía";
if(prop.getProperty("ant_personales_4").equalsIgnoreCase("4")) antecedentes += "       [ X ] Nefropatía";
else  antecedentes += "       [   ] Nefropatía";
if(prop.getProperty("ant_personales_5").equalsIgnoreCase("5")) antecedentes += "       [ X ] Depresión";
else  antecedentes += "       [   ] Depresión";
if(prop.getProperty("ant_personales_6").equalsIgnoreCase("OT")) antecedentes += "\n\n[ X ] Otro: "+prop.getProperty("observacion1");
else  antecedentes += "\n\n[   ] Otro";

pc.addCols(" ",0,dHeader.size());
pc.addCols(antecedentes,0,dHeader.size());

if (formulario.equals("3")){
    prop1 = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = 'PE'");
    
    if (prop1 == null) prop1 = new Properties();
    
    pc.setFont(9, 1);
    pc.addCols("",0,dHeader.size());
    pc.addCols("NUTRICION: CRIBADO NUTRICIONAL",0,dHeader.size());
    pc.setFont(9, 0);
    
    pc.addBorderCols("Ha disminuido la ingesta en las últimas dos semanas:",0,8);
    if (prop1.getProperty("cribado_nutricional0").equalsIgnoreCase("s"))
        pc.addBorderCols("[ X ] SI       [   ] NO",0,2);
    else if (prop1.getProperty("cribado_nutricional0").equalsIgnoreCase("N"))
        pc.addBorderCols("[   ] SI       [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI      [    ] NO",0,2);
        
    pc.addBorderCols("Diagnostico Medico: Gastroenteritis, Vómitos, Nauseas:",0,8);
    if (prop1.getProperty("cribado_nutricional1").equalsIgnoreCase("s"))
        pc.addBorderCols("[ X ] SI       [   ] NO",0,2);
    else if (prop1.getProperty("cribado_nutricional1").equalsIgnoreCase("N"))
        pc.addBorderCols("[   ] SI       [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI      [    ] NO",0,2);
    
    pc.addBorderCols("Perdida de peso en las ultimas dos semanas:",0,8);
    if (prop1.getProperty("cribado_nutricional2").equalsIgnoreCase("s"))
        pc.addBorderCols("[ X ] SI       [   ] NO",0,2);
    else if (prop1.getProperty("cribado_nutricional2").equalsIgnoreCase("N"))
        pc.addBorderCols("[   ] SI       [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI      [    ] NO",0,2);
        
    pc.addBorderCols("Progreso de control de crecimiento y desarrollo:",0,5);
    if (prop1.getProperty("cribado_nutricional3").equalsIgnoreCase("a"))
        pc.addBorderCols("[ X ] Adecuado       [   ] Excesivo       [   ] Deficiente",0,5);
    else if (prop1.getProperty("cribado_nutricional3").equalsIgnoreCase("e"))
        pc.addBorderCols("[   ] Adecuado       [ X ] Excesivo       [   ] Deficiente",0,5);
    else if (prop1.getProperty("cribado_nutricional3").equalsIgnoreCase("d"))
        pc.addBorderCols("[   ] Adecuado       [   ] Excesivo       [ X ] Deficiente",0,5);
    else pc.addBorderCols("[   ] Adecuado       [   ] Excesivo       [   ] Deficiente",0,5);
    
    pc.addBorderCols("Paciente se encuentra con nutrición enteral:",0,8);
    if (prop1.getProperty("cribado_nutricional4").equalsIgnoreCase("s"))
        pc.addBorderCols("[ X ] SI       [   ] NO",0,2);
    else if (prop1.getProperty("cribado_nutricional4").equalsIgnoreCase("N"))
        pc.addBorderCols("[   ] SI       [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI      [    ] NO",0,2);
        
        
}else if(formulario.equals("2")){
    prop1 = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = 'EM'");
    
    if (prop1 == null) prop1 = new Properties();

    pc.setFont(9, 1);
    pc.addCols("",0,dHeader.size());
    pc.addCols("NUTRICION: CRIBADO NUTRICIONAL",0,dHeader.size());
    pc.setFont(9, 0);
    
    String cribado = "";
    if (prop1.getProperty("cribado_nutricional1").equalsIgnoreCase("s")) cribado += "[ X ]  Ha disminuido la ingesta en las últimas dos semanas";
    else cribado += "[   ]  Ha disminuido la ingesta en las últimas dos semanas";
    if (prop1.getProperty("cribado_nutricional2").equalsIgnoreCase("s")) cribado += "\n\n[ X ]  Padece de Diabetes Gestacional";
    else cribado += "\n\n[   ]  Padece de Diabetes Gestacional";
    if (prop1.getProperty("cribado_nutricional3").equalsIgnoreCase("s")) cribado += "\n\n[ X ]  Toma tres o más tragos de licor por día";
    else cribado += "\n\n[   ]  Toma tres o más tragos de licor por día";
    
    cribado += "\n\nProgreso de control de crecimiento y desarrollo         ";
    if (prop1.getProperty("cribado_nutricional4").equalsIgnoreCase("a")) 
        cribado += "[ X ] Adecuado   [   ] Excesivo   [   ] Deficiente";
    else if (prop1.getProperty("cribado_nutricional4").equalsIgnoreCase("e"))
        cribado += "[   ] Adecuado   [ X ] Excesivo   [   ] Deficiente"; 
    else if (prop1.getProperty("cribado_nutricional4").equalsIgnoreCase("d"))
        cribado += "[   ] Adecuado   [   ] Excesivo   [ X ] Deficiente";    
    else cribado += "[   ] Adecuado   [   ] Excesivo   [   ] Deficiente";

    String via = "";
    if (""+prop1.getProperty("via")!=null){
      if (prop1.getProperty("via").equalsIgnoreCase("c")) via = "Correo";
      else if (prop1.getProperty("via").equalsIgnoreCase("t")) via = "Teléfono";
      else if (prop1.getProperty("via").equalsIgnoreCase("p")) via = "Personal";
      else if (prop1.getProperty("via").equalsIgnoreCase("s")) via = "SMS";
    }

    cribado += "\n\nNombre de Nutricionista Enterada: "+prop1.getProperty("nutricionista");
    cribado += "\nHora: "+prop1.getProperty("hora");
    cribado += "\nVia de comunicación: "+via;
            
    pc.addCols(cribado,0,dHeader.size());
    
} else {
    prop1 = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = 'C1'");
    if (prop1 == null) prop1 = new Properties();
    
    pc.setFont(9, 1);
    pc.addCols("",0,dHeader.size());
    pc.addCols("NUTRICION: CRIBADO NUTRICIONAL (No Aplica a Pediatría ni Obstetricia)",0,dHeader.size());
    
    pc.setFont(9, 0);
    
    pc.addBorderCols("Pérdida de Peso en los últimos tres (3) meses?",0,8);
    if (prop1.getProperty("perdido_peso").equalsIgnoreCase("s"))
        pc.addBorderCols("[ X ] SI       [   ] NO",0,2);
    else if (prop1.getProperty("perdido_peso").equalsIgnoreCase("N"))
        pc.addBorderCols("[   ] SI       [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI      [    ] NO",0,2);
        
    pc.addBorderCols("Disminución de la ingesta en la última semana?",0,8);
    if (prop1.getProperty("disminucion").equalsIgnoreCase("s"))
        pc.addBorderCols("[ X ] SI       [   ] NO",0,2);
    else if (prop1.getProperty("disminucion").equalsIgnoreCase("N"))
        pc.addBorderCols("[   ] SI       [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI      [    ] NO",0,2);
    
    pc.addBorderCols("Tiene alguno de estos Diagnósticos: Diabetes, EPOC, Nefrópata (hemodiálisis), Enfermedad Oncológico, Fractura de Cadera, Cirrosis hepática",0,8);
    if (prop1.getProperty("diabetes").equalsIgnoreCase("s"))
        pc.addBorderCols("[ X ] SI       [   ] NO",0,2);
    else if (prop1.getProperty("diabetes").equalsIgnoreCase("N"))
        pc.addBorderCols("[   ] SI       [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI      [    ] NO",0,2);
        
    pc.addBorderCols("Paciente se encuentra en la Unidad de Cuidados Intensivos",0,8);
    if (prop1.getProperty("unidad_cuidado").equalsIgnoreCase("s"))
        pc.addBorderCols("[ X ] SI       [   ] NO",0,2);
    else if (prop1.getProperty("unidad_cuidado").equalsIgnoreCase("N"))
        pc.addBorderCols("[   ] SI       [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI      [    ] NO",0,2);
    
    pc.addBorderCols("Paciente se encuentra con nutrición enteral",0,8);
    if (prop1.getProperty("nutricion_enteral").equalsIgnoreCase("s"))
        pc.addBorderCols("[ X ] SI       [   ] NO",0,2);
    else if (prop1.getProperty("nutricion_enteral").equalsIgnoreCase("N"))
        pc.addBorderCols("[   ] SI       [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI      [    ] NO",0,2);
    
    pc.addBorderCols("Paciente con problemas de comunicación",0,8);
    if (prop1.getProperty("problema_comunicacion").equalsIgnoreCase("s"))
        pc.addBorderCols("[ X ] SI       [   ] NO",0,2);
    else if (prop1.getProperty("problema_comunicacion").equalsIgnoreCase("N"))
        pc.addBorderCols("[   ] SI       [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI      [    ] NO",0,2);
        
    String via = "";
    if (""+prop1.getProperty("via")!=null){
      if (prop1.getProperty("via").equalsIgnoreCase("c")) via = "Correo";
      else if (prop1.getProperty("via").equalsIgnoreCase("t")) via = "Teléfono";
      else if (prop1.getProperty("via").equalsIgnoreCase("p")) via = "Personal";
      else if (prop1.getProperty("via").equalsIgnoreCase("s")) via = "SMS";
    }
   
    pc.addCols("Nombre de Nutricionista Enterada: "+prop1.getProperty("nutricionista")+"\nHora: "+prop1.getProperty("hora")+"\nVia de comunicación: "+via,0,dHeader.size());      
}
    
if(fg.trim().equalsIgnoreCase("uci")){

    pc.setFont(9, 1);
    pc.addCols(" ",0,dHeader.size());
    pc.addBorderCols("Parámetros de Evaluación",0,6);
    pc.addBorderCols("Valor",0,2);
    pc.addBorderCols("Puntaje",0,2);
    
    pc.setFont(9, 0);
    
    pc.addBorderCols("I.M.C:",0,6);
    pc.addBorderCols(prop.getProperty("imc_param"),0,2);
    pc.addBorderCols(prop.getProperty("imc_param_puntaje"),0,2);
    
    String perdPeso = "";
    if ("0".equals(prop.getProperty("perdida_peso"))) perdPeso = "SIN PÉRDIDA";
    else if ("1".equals(prop.getProperty("perdida_peso"))) perdPeso = "ÚLTIMOS 6 MESES O NO SABE";
    else if ("2".equals(prop.getProperty("perdida_peso"))) perdPeso = "ÚLTIMAS 2 SEMANAS";
    
    pc.addBorderCols("Pérdida de Peso:",0,6);
    pc.addBorderCols(perdPeso,0,2);
    pc.addBorderCols(prop.getProperty("perdida_peso_puntaje"),0,2);
    
    pc.addBorderCols("Enfermedad aguda, sin alimentación o probabilidad de poca o ninguna alimentación por más de 5 días. Agregar 2 puntos",0,6);
    if (prop.getProperty("param_enf").equals("2"))
        pc.addBorderCols("[ X ] SI     [   ] NO",0,2);
    else if (prop.getProperty("param_enf").equals("0"))
        pc.addBorderCols("[   ] SI     [ X ] NO",0,2);
    else pc.addBorderCols("[   ] SI     [   ] NO",0,2);
        
    pc.addBorderCols(prop.getProperty("param_enf_puntaje"),0,2);
    
    pc.addBorderCols("Total:",0,8);
    pc.addBorderCols(prop.getProperty("total_param"),0,2);
    
    pc.addBorderCols("RIESGO NUTRICIONAL:",0,8);
    pc.addBorderCols(prop.getProperty("riesgo_nutricional_dsp"),0,2);
 
} else if(fg.trim().equalsIgnoreCase("ad")){ 
  pc.addCols(" ",0,dHeader.size());
  
  String params = "";
  if (prop.getProperty("cambio_ingesta_ad").equalsIgnoreCase("0")) params = "[ X ] Ninguno     [    ] Sólidos incompletos          [    ] Líquidos hipocalóricos o pocos sólidos               [    ] Ayuno o muy pocos líquidos";
  else if (prop.getProperty("cambio_ingesta_ad").equalsIgnoreCase("1")) params = "[   ] Ninguno     [ X ] Sólidos incompletos          [    ] Líquidos hipocalóricos o pocos sólidos               [    ] Ayuno o muy pocos líquidos";
  else if (prop.getProperty("cambio_ingesta_ad").equalsIgnoreCase("2")) params = "[   ] Ninguno     [   ] Sólidos incompletos          [ X ] Líquidos hipocalóricos o pocos sólidos               [    ] Ayuno o muy pocos líquidos";
  else if (prop.getProperty("cambio_ingesta_ad").equalsIgnoreCase("3")) params = "[   ] Ninguno     [   ] Sólidos incompletos          [    ] Líquidos hipocalóricos o pocos sólidos               [ X ] Ayuno o muy pocos líquidos";
  else params = "[   ] Ninguno     [   ] Sólidos incompletos          [    ] Líquidos hipocalóricos o pocos sólidos               [    ] Ayuno o muy pocos líquidos";
  pc.addBorderCols("CAMBIOS DE INGESTA",0,2);
  pc.addBorderCols(params,0,8);

  if (prop.getProperty("sintomas_gastro_ad").equalsIgnoreCase("0")) params = "[ X ] Ninguno     [    ] Nauseas o estreñimiento          [    ] Dolor abdominal, Diarrea o vomito";
  else if (prop.getProperty("sintomas_gastro_ad").equalsIgnoreCase("1")) params = "[    ] Ninguno     [ X ] Nauseas o estreñimiento          [    ] Dolor abdominal, Diarrea o vomito";
  else if (prop.getProperty("sintomas_gastro_ad").equalsIgnoreCase("2")) params = "[   ] Ninguno     [    ] Nauseas o estreñimiento          [ X ] Dolor abdominal, Diarrea o vomito";
  else  params = "[   ] Ninguno     [    ] Nauseas o estreñimiento          [    ] Dolor abdominal, Diarrea o vomito";
  pc.addBorderCols("SINTOMAS GASTROINTESTINALES",0,2);
  pc.addBorderCols(params,0,8);
  
  if (prop.getProperty("capacidad_funcional_ad").equalsIgnoreCase("0")) params = "[ X ] Normal     [    ] Masticación o depresión          [    ] Disfagia          [    ] Paciente encamado";
  else if (prop.getProperty("capacidad_funcional_ad").equalsIgnoreCase("1")) params = "[   ] Normal     [ X ] Masticación o depresión          [    ] Disfagia          [    ] Paciente encamado";
  else if (prop.getProperty("capacidad_funcional_ad").equalsIgnoreCase("2")) params = "[   ] Normal     [    ] Masticación o depresión          [ X ] Disfagia          [    ] Paciente encamado";
  else if (prop.getProperty("capacidad_funcional_ad").equalsIgnoreCase("3")) params = "[   ] Normal     [    ] Masticación o depresión          [   ] Disfagia          [ X ] Paciente encamado";
  else  params = "[    ] Normal     [    ] Masticación o depresión          [    ] Disfagia          [    ] Paciente encamado";
  pc.addBorderCols("CAPACIDAD FUNCIONAL",0,2);
  pc.addBorderCols(params,0,8);
  
  if (prop.getProperty("examen_fisico_ad").equalsIgnoreCase("0")) params = "[ X ] Normal     [    ] Pérdida de Grasa subcutánea leve          [    ] Pérdida de Masa Muscular leve          [    ] Pérdida de Grasa subcutánea moderada          [    ] Pérdida de Masa Muscular moderada          [    ] Lesiones mucosas, ulceras          [    ] Edema moderado a grave          [    ] Ascitis";
  else if (prop.getProperty("examen_fisico_ad").equalsIgnoreCase("1")) params = "[   ] Normal     [ X ] Pérdida de Grasa subcutánea leve          [    ] Pérdida de Masa Muscular leve          [    ] Pérdida de Grasa subcutánea moderada          [    ] Pérdida de Masa Muscular moderada          [    ] Lesiones mucosas, ulceras          [    ] Edema moderado a grave          [    ] Ascitis";
  else if (prop.getProperty("examen_fisico_ad").equalsIgnoreCase("2")) params = "[   ] Normal     [    ] Pérdida de Grasa subcutánea leve          [ X ] Pérdida de Masa Muscular leve          [    ] Pérdida de Grasa subcutánea moderada          [    ] Pérdida de Masa Muscular moderada          [    ] Lesiones mucosas, ulceras          [    ] Edema moderado a grave          [    ] Ascitis";
  else if (prop.getProperty("examen_fisico_ad").equalsIgnoreCase("3")) params = "[   ] Normal     [    ] Pérdida de Grasa subcutánea leve          [   ] Pérdida de Masa Muscular leve          [ X ] Pérdida de Grasa subcutánea moderada          [    ] Pérdida de Masa Muscular moderada          [    ] Lesiones mucosas, ulceras          [    ] Edema moderado a grave          [    ] Ascitis";
  else if (prop.getProperty("examen_fisico_ad").equalsIgnoreCase("4")) params = "[   ] Normal     [    ] Pérdida de Grasa subcutánea leve          [   ] Pérdida de Masa Muscular leve          [   ] Pérdida de Grasa subcutánea moderada          [ X ] Pérdida de Masa Muscular moderada          [    ] Lesiones mucosas, ulceras          [    ] Edema moderado a grave          [    ] Ascitis";
  else if (prop.getProperty("examen_fisico_ad").equalsIgnoreCase("5")) params = "[   ] Normal     [    ] Pérdida de Grasa subcutánea leve          [   ] Pérdida de Masa Muscular leve          [   ] Pérdida de Grasa subcutánea moderada          [   ] Pérdida de Masa Muscular moderada          [ X ] Lesiones mucosas, ulceras          [    ] Edema moderado a grave          [    ] Ascitis";
  else if (prop.getProperty("examen_fisico_ad").equalsIgnoreCase("6")) params = "[   ] Normal     [    ] Pérdida de Grasa subcutánea leve          [   ] Pérdida de Masa Muscular leve          [   ] Pérdida de Grasa subcutánea moderada          [   ] Pérdida de Masa Muscular moderada          [   ] Lesiones mucosas, ulceras          [ X ] Edema moderado a grave          [    ] Ascitis";
  else if (prop.getProperty("examen_fisico_ad").equalsIgnoreCase("7")) params = "[   ] Normal     [    ] Pérdida de Grasa subcutánea leve          [   ] Pérdida de Masa Muscular leve          [   ] Pérdida de Grasa subcutánea moderada          [   ] Pérdida de Masa Muscular moderada          [   ] Lesiones mucosas, ulceras          [   ] Edema moderado a grave          [ X ] Ascitis";
  else  params = "[   ] Normal     [    ] Pérdida de Grasa subcutánea leve          [    ] Pérdida de Masa Muscular leve          [    ] Pérdida de Grasa subcutánea moderada          [    ] Pérdida de Masa Muscular moderada          [    ] Lesiones mucosas, ulceras          [    ] Edema moderado a grave          [    ] Ascitis";
  pc.addBorderCols("EXAMEN FISICO",0,2);
  pc.addBorderCols(params,0,8);
  
  if (prop.getProperty("riesgo_nutricional_ad").equalsIgnoreCase("A")) params = "[ X ] BIEN NUTRIDO     [    ] MALNUTRIDO MODERADO O SOSPECHA DE MALNUTRICION          [    ] SEVERAMENTE MALNUTRIDO";
  else if (prop.getProperty("riesgo_nutricional_ad").equalsIgnoreCase("B")) params = "[   ] BIEN NUTRIDO     [ X ] MALNUTRIDO MODERADO O SOSPECHA DE MALNUTRICION          [    ] SEVERAMENTE MALNUTRIDO";
  else if (prop.getProperty("riesgo_nutricional_ad").equalsIgnoreCase("C")) params = "[   ] BIEN NUTRIDO     [   ] MALNUTRIDO MODERADO O SOSPECHA DE MALNUTRICION          [ X ] SEVERAMENTE MALNUTRIDO";
  else params = "[   ] BIEN NUTRIDO     [   ] MALNUTRIDO MODERADO O SOSPECHA DE MALNUTRICION          [   ] SEVERAMENTE MALNUTRIDO";
  pc.addBorderCols("RIESGO NUTRICIONAL",0,2);
  pc.addBorderCols(params,0,8);
  
} else if(fg.trim().equalsIgnoreCase("pe")){

    pc.addCols(" ",0,dHeader.size());
    String params = "";
    
    pc.addBorderCols("Apetito",0,4);
    if (prop.getProperty("apetito_pe").equalsIgnoreCase("0")) params = "[ X ] Buen apetito     [    ] Disminución del apetito\n\n[    ] Pobre apetito               [    ] Incapaz de comer por vía oral";
    else if (prop.getProperty("apetito_pe").equalsIgnoreCase("1")) params = "[    ] Buen apetito     [ X ] Disminución del apetito\n\n[    ] Pobre apetito               [    ] Incapaz de comer por vía oral";
    else if (prop.getProperty("apetito_pe").equalsIgnoreCase("2")) params = "[    ] Buen apetito     [    ] Disminución del apetito\n\n[ X ] Pobre apetito               [    ] Incapaz de comer por vía oral";
    else if (prop.getProperty("apetito_pe").equalsIgnoreCase("3")) params = "[    ] Buen apetito     [    ] Disminución del apetito\n\n[    ] Pobre apetito               [ X ] Incapaz de comer por vía oral";
    else params = "[   ] Buen apetito     [    ] Disminución del apetito\n\n[    ] Pobre apetito               [    ] Incapaz de comer por vía oral";
    pc.addBorderCols(params,0,8);
    
    pc.addBorderCols("Síntomas Gastrointestinales",0,4);
    if (prop.getProperty("sintomas_gastro_pe").equalsIgnoreCase("0")) params = "[ X ] Sin síntomas     [    ] Estreñimiento     [    ] Vomito o diarrea leve a moderada (1-3v/día)               [    ] Vomito severo y/o diarrea severa (>3v/día)";
    else if (prop.getProperty("sintomas_gastro_pe").equalsIgnoreCase("1")) params = "[   ] Sin síntomas     [ X ] Estreñimiento     [    ] Vomito o diarrea leve a moderada (1-3v/día)               [    ] Vomito severo y/o diarrea severa (>3v/día)";
    else if (prop.getProperty("sintomas_gastro_pe").equalsIgnoreCase("2")) params = "[   ] Sin síntomas     [    ] Estreñimiento     [ X ] Vomito o diarrea leve a moderada (1-3v/día)               [    ] Vomito severo y/o diarrea severa (>3v/día)";
    else if (prop.getProperty("sintomas_gastro_pe").equalsIgnoreCase("3")) params = "[   ] Sin síntomas     [    ] Estreñimiento     [    ] Vomito o diarrea leve a moderada (1-3v/día)               [ X ] Vomito severo y/o diarrea severa (>3v/día)";
    else params = "[   ] Sin síntomas     [    ] Estreñimiento     [    ] Vomito o diarrea leve a moderada (1-3v/día)               [    ] Vomito severo y/o diarrea severa (>3v/día)";
    pc.addBorderCols(params,0,8);
    
    pc.addBorderCols("Capacidad Funcional",0,4);
    if (prop.getProperty("capacidad_funcional_pe").equalsIgnoreCase("0")) params = "[ X ] Sin dificultades para tragar     [    ] Con dificultad para tragar";
    else if (prop.getProperty("capacidad_funcional_pe").equalsIgnoreCase("1")) params = "[   ] Sin dificultades para tragar     [ X ] Con dificultad para tragar";
    else params = "[    ] Sin dificultades para tragar     [    ] Con dificultad para tragar";
    pc.addBorderCols(params,0,8);
    
    if (prop.getProperty("riesgo_nutricional_pe").equalsIgnoreCase("A")) params = "[ X ] BIEN NUTRIDO     [    ] MALNUTRIDO MODERADO O SOSPECHA DE MALNUTRICION          [    ] SEVERAMENTE MALNUTRIDO";
    else if (prop.getProperty("riesgo_nutricional_pe").equalsIgnoreCase("B")) params = "[   ] BIEN NUTRIDO     [ X ] MALNUTRIDO MODERADO O SOSPECHA DE MALNUTRICION          [    ] SEVERAMENTE MALNUTRIDO";
    else if (prop.getProperty("riesgo_nutricional_pe").equalsIgnoreCase("C")) params = "[   ] BIEN NUTRIDO     [   ] MALNUTRIDO MODERADO O SOSPECHA DE MALNUTRICION          [ X ] SEVERAMENTE MALNUTRIDO";
    else params = "[   ] BIEN NUTRIDO     [   ] MALNUTRIDO MODERADO O SOSPECHA DE MALNUTRICION          [   ] SEVERAMENTE MALNUTRIDO";
    pc.addBorderCols("RIESGO NUTRICIONAL",0,2);
    pc.addBorderCols(params,0,8);
    
    pc.addCols(" ",0,dHeader.size());
    pc.setFont(9,1);
    pc.addCols("ANTECEDENTES NEONATALES",0,dHeader.size());
    pc.setFont(9,0);
    
    ArrayList alAN = SQLMgr.getDataList("select distinct a.codigo, a.descripcion, b.cod_paciente, to_char(b.fec_nacimiento,'dd/mm/yyyy') as fecha, nvl(b.cod_medida,' ') as medida, b.cod_neonatal as code, nvl(b.valor_alfanumerico,'') as valor, b.valor_numero as valornum, b.observacion, b.pac_id,b.usuario_creacion,to_char(b.fecha_creacion,'dd/mm/yyyy')fecha_creacion from tbl_sal_factor_neonatal a, tbl_sal_antecedente_neonatal b where a.codigo = b.cod_neonatal and b.pac_id = "+pacId);
    
    pc.addBorderCols("Descripción",1 ,5);
    pc.addBorderCols("Valor",1 ,2);
    pc.addBorderCols("Observación",1 ,3);
    for(int i = 0; i<alAN.size(); i++){
        cdo = (CommonDataObject) alAN.get(i);
        pc.addCols(cdo.getColValue("descripcion"),0,5);
		pc.addCols(cdo.getColValue("valorNum"),1,2);
		pc.addCols(cdo.getColValue("observacion"),0,3);
    }
    
    pc.addCols(" ",0,dHeader.size());
    
    String lactancia = "";
    if (prop.getProperty("lactancia").equalsIgnoreCase("0")) lactancia = "[ X ] Materna     [   ] Formula    [   ] Ambas";
    else if (prop.getProperty("lactancia").equalsIgnoreCase("1")) lactancia = "[   ] Materna     [ X ] Formula    [   ] Ambas";
    else if (prop.getProperty("lactancia").equalsIgnoreCase("2")) lactancia = "[   ] Materna     [   ] Formula    [ X ] Ambas";
    else lactancia = "[   ] Materna     [   ] Formula    [   ] Ambas";
    pc.addCols("Lactancia: "+lactancia,0,dHeader.size());
    pc.addCols("Alimentación Complementaria:  "+prop.getProperty("alimentacion_complementaria"),0,dHeader.size());
}


if(fg.trim().equalsIgnoreCase("uci")||fg.trim().equalsIgnoreCase("ad")){

    if(fg.trim().equalsIgnoreCase("uci")){
        pc.addCols(" ",0,dHeader.size());
        pc.addCols("Diagnóstico Nutricional:",0,4);
        
        if(prop.getProperty("diag_nutricional").equalsIgnoreCase("0")) pc.addCols("[ X ]  Desnutrición    [   ] Bajo peso    [   ] Normal    [   ] Sobrepeso    [   ] Obesidad    [   ] Obesidad Mórbida",0,6);
        else if(prop.getProperty("diag_nutricional").equalsIgnoreCase("1")) pc.addCols("[   ]  Desnutrición    [ X ] Bajo peso    [   ] Normal    [   ] Sobrepeso    [   ] Obesidad    [   ] Obesidad Mórbida",0,6);
        else if(prop.getProperty("diag_nutricional").equalsIgnoreCase("2")) pc.addCols("[   ]  Desnutrición    [   ] Bajo peso    [ X ] Normal    [   ] Sobrepeso    [   ] Obesidad    [   ] Obesidad Mórbida",0,6);
        else if(prop.getProperty("diag_nutricional").equalsIgnoreCase("3")) pc.addCols("[   ]  Desnutrición    [   ] Bajo peso    [   ] Normal    [ X ] Sobrepeso    [   ] Obesidad    [   ] Obesidad Mórbida",0,6);
        else if(prop.getProperty("diag_nutricional").equalsIgnoreCase("4")) pc.addCols("[   ]  Desnutrición    [   ] Bajo peso    [   ] Normal    [   ] Sobrepeso    [ X ] Obesidad    [   ] Obesidad Mórbida",0,6);
        else if(prop.getProperty("diag_nutricional").equalsIgnoreCase("5")) pc.addCols("[   ]  Desnutrición    [   ] Bajo peso    [   ] Normal    [   ] Sobrepeso    [   ] Obesidad    [ X ] Obesidad Mórbida",0,6);
        else  pc.addCols("[   ]  Desnutrición    [   ] Bajo peso    [   ] Normal    [   ] Sobrepeso    [   ] Obesidad    [   ] Obesidad Mórbida",0,6);
    }

    pc.addCols(" ",0,dHeader.size());
    pc.addCols("Interacción Fármaco-Nutriente:  "+prop.getProperty("interaccion_far_nutri"),0,dHeader.size());
}

if(fg.trim().equalsIgnoreCase("ADM")){
    pc.addCols(" ",0,dHeader.size());
    pc.setFont(9,1);
    pc.addBorderCols("CRIBAJE",0,dHeader.size());
    pc.setFont(9, 0);
    
    pc.addBorderCols("1. Ha perdido el apetito? Ha comido menos por falta de apetito, problemas digestivos, dificultad para masticar o deglutir en los últimos 3 meses?",0,6);
    if(prop.getProperty("pregunta_1").equals("0")) pc.addBorderCols("[ X ] Anorexia grave    [   ] Anorexia moderada     [   ] Sin anorexia",0,4);
    else if(prop.getProperty("pregunta_1").equals("1")) pc.addBorderCols("[    ] Anorexia grave    [ X ] Anorexia moderada     [   ] Sin anorexia",0,4);
    else if(prop.getProperty("pregunta_1").equals("2")) pc.addBorderCols("[    ] Anorexia grave    [   ] Anorexia moderada     [ X ] Sin anorexia",0,4);
    else pc.addBorderCols("[   ] Anorexia grave    [   ] Anorexia moderada     [   ] Sin anorexia",0,4);
    
    pc.addBorderCols("2. Perdidad reciente de peso (<3 meses)?",0,6);
    if(prop.getProperty("pregunta_2").equals("0")) pc.addBorderCols("[ X ] pédida de peso > kg (6.6 lb)\n\n[   ] no lo sabe\n\n[   ] pédida de peso entre 1 a 3 kg (2.2 a 6.6 lb)\n\n[  ] no ha habido pédida de peso",0,4);
    if(prop.getProperty("pregunta_2").equals("1")) pc.addBorderCols("[   ] pédida de peso > kg (6.6 lb)\n\n[ X ] no lo sabe\n\n[   ] pédida de peso entre 1 a 3 kg (2.2 a 6.6 lb)\n\n[  ] no ha habido pédida de peso",0,4);
    if(prop.getProperty("pregunta_2").equals("2")) pc.addBorderCols("[   ] pédida de peso > kg (6.6 lb)\n\n[   ] no lo sabe\n\n[ X ] pédida de peso entre 1 a 3 kg (2.2 a 6.6 lb)\n\n[   ] no ha habido pédida de peso",0,4);
    if(prop.getProperty("pregunta_2").equals("3")) pc.addBorderCols("[   ] pédida de peso > kg (6.6 lb)\n\n[   ] no lo sabe\n\n[   ] pédida de peso entre 1 a 3 kg (2.2 a 6.6 lb)\n\n[ X ] no ha habido pédida de peso",0,4);
    else pc.addBorderCols("[   ] pédida de peso > kg (6.6 lb)\n\n[   ] no lo sabe\n\n[   ] pédida de peso entre 1 a 3 kg (2.2 a 6.6 lb)\n\n[   ] no ha habido pédida de peso",0,4);
    
    pc.addBorderCols("3. Movilidad",0,6);
    if(prop.getProperty("pregunta_3").equals("0")) pc.addBorderCols("[ X ] de la cama al sillón   [   ] autonomía en el interior    [   ] sale del domicilio",0,4);
    else if(prop.getProperty("pregunta_3").equals("1")) pc.addBorderCols("[   ] de la cama al sillón   [ X ] autonomía en el interior    [   ] sale del domicilio",0,4);
    else if(prop.getProperty("pregunta_3").equals("2")) pc.addBorderCols("[   ] de la cama al sillón   [   ] autonomía en el interior    [ X ] sale del domicilio",0,4);
    else pc.addBorderCols("[   ] de la cama al sillón   [   ] autonomía en el interior    [   ] sale del domicilio",0,4);
    
    pc.addBorderCols("4. Ha tenido una enfermedad aguda o situación de estrés psicológico en los últimos 3 meses?",0,6);
    if(prop.getProperty("pregunta_4").equals("0")) pc.addBorderCols("[ X ] SI      [   ] NO",0,4);
    else if(prop.getProperty("pregunta_4").equals("1")) pc.addBorderCols("[   ] SI     [ X ] NO",0,4);
    else pc.addBorderCols("[   ] SI     [   ] NO",0,4);
    
    pc.addBorderCols("5. Problemas Neurológicos",0,6);
    if(prop.getProperty("pregunta_5").equals("0")) pc.addBorderCols("[ X ] demencia o depresión grave      [   ] demencia o depresión moderada      [   ] sin problemas neurológicos",0,4);
    else if(prop.getProperty("pregunta_5").equals("1")) pc.addBorderCols("[   ] demencia o depresión grave      [ X ] demencia o depresión moderada      [   ] sin problemas neurológicos",0,4);
    else if(prop.getProperty("pregunta_5").equals("2")) pc.addBorderCols("[   ] demencia o depresión grave      [   ] demencia o depresión moderada      [ X ] sin problemas neurológicos",0,4);
    else pc.addBorderCols("[   ] demencia o depresión grave      [   ] demencia o depresión moderada      [   ] sin problemas neurológicos",0,4);
    
    pc.setFont(9,1);
    pc.addBorderCols("6. Índice de Masa Corporal\n\nEvaluación de Cribaje\nTotal de Puntos Obtenidos: "+prop.getProperty("total_cribaje")+"  ("+prop.getProperty("total_cribaje_dsp")+")",0,6);
    
    pc.setFont(9,0);
    if(prop.getProperty("pregunta_6").equals("0")) pc.addBorderCols("[ X ] < 19      [   ] 19 <= IMC < 21      [   ] 21 <= IMC < 23\n[   ] >= 23",0,4);
    else if(prop.getProperty("pregunta_6").equals("1")) pc.addBorderCols("[   ] < 19      [ X ] 19 <= IMC < 21      [   ] 21 <= IMC < 23\n[   ] >= 23",0,4);
    else if(prop.getProperty("pregunta_6").equals("2")) pc.addBorderCols("[   ] < 19      [   ] 19 <= IMC < 21      [ X ] 21 <= IMC < 23\n[   ] >= 23",0,4);
    else if(prop.getProperty("pregunta_6").equals("3")) pc.addBorderCols("[   ] < 19      [   ] 19 <= IMC < 21      [   ] 21 <= IMC < 23\n[ X ] >= 23",0,4);
    else pc.addBorderCols("[   ] < 19      [   ] 19 <= IMC < 21      [   ] 21 <= IMC < 23\n[   ] >= 23",0,4); 
    
    
    pc.addCols(" ",0,dHeader.size());
    pc.setFont(9,1);
    pc.addBorderCols("EVALUACION",0,dHeader.size());
    pc.setFont(9, 0);
    
    pc.addBorderCols("7. El paciente vive independiente en su domicilio?",0,6);
    if(prop.getProperty("pregunta_7").equals("1")) pc.addBorderCols("[ X ] SI      [   ] NO",0,4);
    else if(prop.getProperty("pregunta_7").equals("0")) pc.addBorderCols("[   ] SI     [ X ] NO",0,4);
    else pc.addBorderCols("[   ] SI     [   ] NO",0,4); 
    
    pc.addBorderCols("8. Toma más de 3 medicamentos al día?",0,6);
    if(prop.getProperty("pregunta_8").equals("0")) pc.addBorderCols("[ X ] SI      [   ] NO",0,4);
    else if(prop.getProperty("pregunta_8").equals("1")) pc.addBorderCols("[   ] SI     [ X ] NO",0,4);
    else pc.addBorderCols("[   ] SI     [   ] NO",0,4);   
    
    pc.addBorderCols("9. Ulceras o lesiones cutáneas?",0,6);
    if(prop.getProperty("pregunta_9").equals("0")) pc.addBorderCols("[ X ] SI      [   ] NO",0,4);
    else if(prop.getProperty("pregunta_9").equals("1")) pc.addBorderCols("[   ] SI     [ X ] NO",0,4);
    else pc.addBorderCols("[   ] SI     [   ] NO",0,4);   
    
    pc.addBorderCols("10. Cuantas comidas completas toma al día?",0,6);
    if(prop.getProperty("pregunta_10").equals("0")) pc.addBorderCols("[ X ] 1 comida      [   ] 2 comidas    [   ] 3 comidas",0,4);
    else if(prop.getProperty("pregunta_10").equals("1")) pc.addBorderCols("[   ] 1 comida      [ X ] 2 comidas    [   ] 3 comidas",0,4);
    else if(prop.getProperty("pregunta_10").equals("2")) pc.addBorderCols("[   ] 1 comida      [   ] 2 comidas    [ X ] 3 comidas",0,4);
    else pc.addBorderCols("[   ] 1 comida      [   ] 2 comidas    [   ] 3 comidas",0,4);

    pc.addBorderCols("11. Consume frutas o verduras al menos 2 veces por día? ",0,6);
    if(prop.getProperty("pregunta_11").equals("1")) pc.addBorderCols("[ X ] SI      [   ] NO",0,4);
    else if(prop.getProperty("pregunta_11").equals("0")) pc.addBorderCols("[   ] SI     [ X ] NO",0,4);
    else pc.addBorderCols("[   ] SI     [   ] NO",0,4);

    pc.addBorderCols("12. Consume el paciente",0,6);
    
    String consume = "Productos lácteos por lo menos una vez al día?        ";

    if(prop.getProperty("pregunta_12_1").equals("Y")) consume += "[ X ] SI      [   ] NO";
    else if(prop.getProperty("pregunta_12_1").equals("N")) consume += "[   ] SI      [ X ] NO";
    else consume += "[   ] SI      [   ] NO";
    
    consume += "\n\nHuevos o legumbres 1 o 2 veces por semana?        ";
    
    if(prop.getProperty("pregunta_12_2").equals("Y")) consume += "[ X ] SI      [   ] NO";
    else if(prop.getProperty("pregunta_12_2").equals("N")) consume += "[   ] SI      [ X ] NO";
    else consume += "[   ] SI      [   ] NO";
    
    consume += "\n\nCarne, pescado o aves, diariamente?        ";
    
    if(prop.getProperty("pregunta_12_3").equals("Y")) consume += "[ X ] SI      [   ] NO";
    else if(prop.getProperty("pregunta_12_3").equals("N")) consume += "[   ] SI      [ X ] NO";
    else consume += "[   ] SI      [   ] NO";
    
    pc.addBorderCols(consume,0,4);
    
    pc.addBorderCols("13. Cuantos vasos de agua u otros láquidos toma al día (agua, zumo, café, té, leche, vino, cerveza...)?",0,6);
    if (prop.getProperty("pregunta_13").equals("0")) pc.addBorderCols("[ X ] menos de 3 vasos   [   ] de 3 a 5 vasos    [   ] más de 5",0,4);
    else if (prop.getProperty("pregunta_13").equals("0.5")) pc.addBorderCols("[   ] menos de 3 vasos   [ X ] de 3 a 5 vasos    [   ] más de 5",0,4);
    else if (prop.getProperty("pregunta_13").equals("1.0")) pc.addBorderCols("[   ] menos de 3 vasos   [   ] de 3 a 5 vasos    [ X ] más de 5",0,4);
    else pc.addBorderCols("[   ] menos de 3 vasos   [   ] de 3 a 5 vasos    [   ] más de 5",0,4);
    
    pc.addBorderCols("14. Forma de alimentarse",0,6);
    if (prop.getProperty("pregunta_14").equals("0")) pc.addBorderCols("[ X ] necesita ayuda   [   ] se alimenta solo con dificultad    [   ] se alimenta solo sin dificultad",0,4);
    else if (prop.getProperty("pregunta_14").equals("1")) pc.addBorderCols("[   ] necesita ayuda   [ X ] se alimenta solo con dificultad\n[   ] se alimenta solo sin dificultad",0,4);
    else if (prop.getProperty("pregunta_14").equals("2")) pc.addBorderCols("[   ] necesita ayuda   [   ] se alimenta solo con dificultad\n[ X ] se alimenta solo sin dificultad",0,4);
    else pc.addBorderCols("[   ] necesita ayuda   [   ] se alimenta solo con dificultad\n[ X ] se alimenta solo sin dificultad",0,4); 
    
    pc.addBorderCols("15. Se considera el paciente que está bien nutrido?",0,6);
    if (prop.getProperty("pregunta_15").equals("0")) pc.addBorderCols("[ X ] malnutrición grave   [   ] no lo sabe o malnutrición moderada    [   ]   sin problemas de nutrición",0,4);
    else if (prop.getProperty("pregunta_15").equals("1")) pc.addBorderCols("[   ] malnutrición grave   [ X ] no lo sabe o malnutrición moderada    [   ]   sin problemas de nutrición",0,4);
    else if (prop.getProperty("pregunta_15").equals("2")) pc.addBorderCols("[   ] malnutrición grave   [   ] no lo sabe o malnutrición moderada    [ X ]   sin problemas de nutrición",0,4);
    else pc.addBorderCols("[   ] malnutrición grave   [   ] no lo sabe o malnutrición moderada    [   ]   sin problemas de nutrición",0,4); 
    
    pc.addBorderCols("16. En comparación con otras personas de su edad, como encuentra el paciente su estado de salud?",0,6);
    if (prop.getProperty("pregunta_16").equals("0")) pc.addBorderCols("[ X ] peor    [   ] no lo sabe    [   ]   igual    [   ]   peor",0,4);
    else if (prop.getProperty("pregunta_16").equals("0.5")) pc.addBorderCols("[   ] peor    [ X ] no lo sabe    [   ]   igual    [   ]   peor",0,4);
    else if (prop.getProperty("pregunta_16").equals("1")) pc.addBorderCols("[   ] peor    [   ] no lo sabe    [ X ]   igual    [   ]   peor",0,4);
    else if (prop.getProperty("pregunta_16").equals("2")) pc.addBorderCols("[   ] peor    [   ] no lo sabe    [   ]   igual    [ X ]   peor",0,4);
    else pc.addBorderCols("[   ] peor    [   ] no lo sabe    [   ]   igual    [   ]   peor",0,4); 
    
    pc.addBorderCols("17. Circunferencia braquial (CB en cm)",0,6);
    if (prop.getProperty("pregunta_17").equals("0.0")) pc.addBorderCols("[ X ] CB < 21    [   ] 21 <= CB <= 22     [   ] CB > 22",0,4);
    else if (prop.getProperty("pregunta_17").equals("0.5")) pc.addBorderCols("[   ] CB < 21    [ X ] 21 <= CB <= 22     [   ] CB > 22",0,4);
    else if (prop.getProperty("pregunta_17").equals("1")) pc.addBorderCols("[   ] CB < 21    [   ] 21 <= CB <= 22     [ X ] CB > 22",0,4);
    else pc.addBorderCols("[   ] CB < 21     [   ] 21 <= CB <= 22     [   ] CB > 22",0,4);
    
    String resulta18 = "";
    pc.addBorderCols("18. Circunferencia de la pantorrilla (CP en cm)",0,6);
    if (prop.getProperty("resulta_18").equals("0")) resulta18 = "[ X ] CP < 31    [   ] CP >= 31";
    else if (prop.getProperty("resulta_18").equals("1")) resulta18 = "[   ] CP < 31    [ X ] CP >= 31";
    else resulta18 = "[   ] CP < 31    [   ] CP >= 31";
    
    resulta18 += "\n\nEvaluación: "+prop.getProperty("total_eval")+"\nEvaluación Global: "+prop.getProperty("total_global")+"    ("+prop.getProperty("total_global_dsp")+")";
    
    pc.setFont(9,1);
    pc.addBorderCols(resulta18,0,4);
    
} // adm


// Antecedentes alergicos

pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1);
pc.addCols("ANTECEDENTES ALERGICOS",0,dHeader.size());
pc.setFont(9,0);

al = SQLMgr.getDataList("select a.descripcion as descripcion, a.codigo as codigoalergia, to_char(b.fecha,'dd/mm/yyyy hh12:mi:ss am') as fecha, b.usuario_creacion, b.meses as meses, b.observacion as observacion, b.edad as edad, nvl(b.codigo,0) as cod, b.aplicar as aplicar from TBL_SAL_TIPO_ALERGIA a, TBL_SAL_ALERGIA_PACIENTE b where  a.codigo=b.tipo_alergia and b.pac_id = "+pacId+" and nvl(b.admision,"+noAdmision+") = "+noAdmision+" ORDER BY b.fecha desc");

Vector tbl1 = new Vector();
tbl1.addElement(".20"); 
tbl1.addElement(".10");
tbl1.addElement(".06");
tbl1.addElement(".29");
tbl1.addElement(".12");
tbl1.addElement(".10");

pc.setNoColumnFixWidth(tbl1);
pc.createTable("tbl1");

pc.addBorderCols("Tipo de Alergia",1 ,1);
pc.addBorderCols("Edad",1 ,1);
pc.addBorderCols("Meses",1 ,1);
pc.addBorderCols("Observación",1 ,1);
pc.addBorderCols("Fecha",1 ,1);
pc.addBorderCols("Usuario",1 ,1);

for(int i = 0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);

    pc.setFont(7, 0);
    pc.addBorderCols(cdo.getColValue("descripcion"),0,1,15.2f);
    pc.addBorderCols(cdo.getColValue("edad"),1,1,15.2f);
    pc.addBorderCols(cdo.getColValue("meses"),1,1,15.2f);
    pc.addBorderCols(cdo.getColValue("observacion"),0,1);
    pc.addBorderCols(cdo.getColValue("fecha"),1,1);
    pc.addBorderCols(cdo.getColValue("usuario_creacion"),1,1);
}

pc.useTable("main");
pc.addTableToCols("tbl1",0,dHeader.size());

prop1 = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = 'NEEU' /*and id > 0*/");

if (prop1 == null) prop1 = new Properties();

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

pc.setFont(9,0);
pc.addCols("Alergias:    "+alergias,0,dHeader.size());
if( prop1.getProperty("alergia7").equalsIgnoreCase("o")&&!prop1.getProperty("alergia0").equalsIgnoreCase("n")){
    pc.addCols("Comentarios: "+prop1.getProperty("otros8"),0,dHeader.size());
}

// medicamentos
sbSql = new StringBuffer();
sbSql.append("select a.secuencia as secuenciaCorte, a.usuario_creacion, to_char(a.fecha_inicio,'dd/mm/yyyy')||decode(a.prioridad,'O','',' '||to_char(a.fecha_creacion,'hh12:mi:ss am'))as fecha_inicio, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, decode(a.tipo_orden,3,x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre),7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, tipo_orden, a.codigo, a.orden_med, a.usuario_creacion uc, a.usuario_modificacion um, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') as fecha_fin, nvl(a.cod_salida,0) as cod_salida,a.tipo_ordenvarios,a.subtipo_ordenvarios, nvl(y.desc1, ' ') desc1, nvl(y.desc2, ' ') desc2,nvl(a.ejecutado_usuario,'')ejecutado_usuario ");

sbSql.append(" , (select uu.name from tbl_sec_users uu where uu.user_name = a.usuario_creacion) as complete_name ");

sbSql.append(" from tbl_sal_detalle_orden_med a, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo=c.cod_tipo_dieta(+) union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, (select t.codigo, t.descripcion desc1, st.codigo sub_tipo_codigo, st.descripcion desc2, st.cod_tipo_ordenvarios from tbl_cds_ordenmedica_varios t, tbl_cds_om_varios_subtipo st where st.cod_tipo_ordenvarios = t.codigo) y, tbl_sal_orden_salida d, tbl_adm_admision z where z.pac_id=a.pac_id and z.secuencia=a.secuencia and z.pac_id=");
sbSql.append(pacId);
sbSql.append(" and z.adm_root = ");
sbSql.append(noAdmision);
sbSql.append(" and a.tipo_orden = 2 ");
sbSql.append(" and a.tipo_dieta||'-'||a.cod_tipo_dieta=x.codigo(+) and a.cod_salida=d.codigo(+) and y.codigo(+) = a.tipo_ordenvarios and y.sub_tipo_codigo(+) = a.subtipo_ordenvarios order by a.fecha_creacion desc");

al = SQLMgr.getDataList(sbSql.toString());

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("OM MEDICAMENTOS",0,dHeader.size());

Vector tbl2 = new Vector();
tbl2.addElement(".18");
tbl2.addElement(".14");
tbl2.addElement(".11");
tbl2.addElement(".20");
tbl2.addElement(".25");
tbl2.addElement(".12");

pc.setNoColumnFixWidth(tbl2);
pc.createTable("tbl2");

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
pc.addTableToCols("tbl2",0,dHeader.size());


// laboratorios
sbSql = new StringBuffer();
sbSql.append("select a.secuencia as secuenciaCorte, a.usuario_creacion, to_char(a.fecha_inicio,'dd/mm/yyyy')||decode(a.prioridad,'O','',' '||to_char(a.fecha_creacion,'hh12:mi:ss am'))as fecha_inicio, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, decode(a.tipo_orden,3,x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre),7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, tipo_orden, a.codigo, a.orden_med, a.usuario_creacion uc, a.usuario_modificacion um, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') as fecha_fin, nvl(a.cod_salida,0) as cod_salida,a.tipo_ordenvarios,a.subtipo_ordenvarios, nvl(y.desc1, ' ') desc1, nvl(y.desc2, ' ') desc2,nvl(a.ejecutado_usuario,'')ejecutado_usuario ");

sbSql.append(" , (select uu.name from tbl_sec_users uu where uu.user_name = a.usuario_creacion) as complete_name ");

sbSql.append(" from tbl_sal_detalle_orden_med a, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo=c.cod_tipo_dieta(+) union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, (select t.codigo, t.descripcion desc1, st.codigo sub_tipo_codigo, st.descripcion desc2, st.cod_tipo_ordenvarios from tbl_cds_ordenmedica_varios t, tbl_cds_om_varios_subtipo st where st.cod_tipo_ordenvarios = t.codigo) y, tbl_sal_orden_salida d, tbl_adm_admision z where z.pac_id=a.pac_id and z.secuencia=a.secuencia and z.pac_id=");
sbSql.append(pacId);
sbSql.append(" and z.adm_root = ");
sbSql.append(noAdmision);
sbSql.append(" and a.tipo_orden = 1 ");
sbSql.append(" and a.tipo_dieta||'-'||a.cod_tipo_dieta=x.codigo(+) and a.cod_salida=d.codigo(+) and y.codigo(+) = a.tipo_ordenvarios and y.sub_tipo_codigo(+) = a.subtipo_ordenvarios order by a.fecha_creacion desc");

al = SQLMgr.getDataList(sbSql.toString());

pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("OM LABORATORIOS",0,dHeader.size());

Vector tbl3 = new Vector();
tbl3.addElement(".18");
tbl3.addElement(".14");
tbl3.addElement(".11");
tbl3.addElement(".20");
tbl3.addElement(".25");
tbl3.addElement(".12");

pc.setNoColumnFixWidth(tbl3);
pc.createTable("tbl3");

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
pc.addTableToCols("tbl3",0,dHeader.size());

























pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());
pc.addCols("PLAN DE ACCION",0,dHeader.size());
pc.setFont(9,0);

if (prop.getProperty("plan_accion0").equals("0")) pc.addCols("[ X ] Paciente no está en alto riesgo nutricional en estos momentos",0,dHeader.size());
else pc.addCols("[    ] Paciente no está en alto riesgo nutricional en estos momentos",0,dHeader.size());

if (prop.getProperty("plan_accion1").equals("1")) pc.addCols("[ X ] Paciente en riesgo nutricional",0,dHeader.size());
else pc.addCols("[    ] Paciente en riesgo nutricional",0,dHeader.size());

if (prop.getProperty("plan_accion2").equals("2")) pc.addCols("     [ X ] Se notifica al médico de cabecera",0,dHeader.size());
else pc.addCols("     [    ] Se notifica al médico de cabecera",0,dHeader.size());

if (prop.getProperty("plan_accion3").equals("3")) pc.addCols("     [ X ] Se vigila cada:  "+prop.getProperty("frecuencia_vigilencia", " ")+" días",0,dHeader.size());
else pc.addCols("     [    ] Se vigila cada:  ",0,dHeader.size());

if (prop.getProperty("plan_accion4").equals("4")) pc.addCols("     [ X ] Se realiza control de ingestión. (Técnica de enfermería llena formulario y se deja en la habitación del paciente)",0,dHeader.size());
else pc.addCols("     [    ] Se realiza control de ingestión. (Técnica de enfermería llena formulario y se deja en la habitación del paciente)",0,dHeader.size());

if (prop.getProperty("plan_accion5").equals("5")) pc.addCols("[ X ] Se visitó al paciente para obtener preferencias alimentarias y meriendas",0,dHeader.size());
else pc.addCols("[    ] Se visitó al paciente para obtener preferencias alimentarias y meriendas",0,dHeader.size());

if (prop.getProperty("plan_accion6").equals("6")) pc.addCols("[ X ] Paciente / familiar/ persona que cuida, familiarizado con las modificaciones dietéticas.",0,dHeader.size());
else pc.addCols("[    ] Paciente / familiar/ persona que cuida, familiarizado con las modificaciones dietéticas.",0,dHeader.size());

if (prop.getProperty("plan_accion10").equals("10")) pc.addCols("[ X ] Se entrega volante educativa sobre dieta actual",0,dHeader.size());
else pc.addCols("[    ] Se entrega volante educativa sobre dieta actual",0,dHeader.size());

if (prop.getProperty("plan_accion7").equals("7")) pc.addCols("[ X ] Se entrega volante educativa sobre Diabetes",0,dHeader.size());
else pc.addCols("[    ] Se entrega volante educativa sobre Diabetes",0,dHeader.size());

if(fg.trim().equalsIgnoreCase("UCI")||fg.trim().equalsIgnoreCase("adm")){
    if (prop.getProperty("plan_accion8").equals("8")) pc.addCols("[ X ] Se entrega volante educativa sobre Interacción medicamento alimento (Warfarina)",0,dHeader.size());
    else pc.addCols("[    ] Se entrega volante educativa sobre Interacción medicamento alimento (Warfarina)",0,dHeader.size());
    
    if(prop.getProperty("cirugia_bariatrica").equalsIgnoreCase("1")) pc.addCols("Paciente Cirugía Bariátrica:     [ X ] SI    [   ] NO",0,dHeader.size());
    else if(prop.getProperty("cirugia_bariatrica").equalsIgnoreCase("0")) pc.addCols("Paciente Cirugía Bariátrica:     [   ] SI    [ X ] NO",0,dHeader.size());
    else pc.addCols("Paciente Cirugía Bariátrica:     [   ] SI    [   ] NO",0,dHeader.size());
    
    if (prop.getProperty("plan_accion9").equals("9")) pc.addCols("[ X ] Se entrega recomendaciones generales de cirugía Bariátrica.",0,dHeader.size());
    else pc.addCols("[    ] Se entrega recomendaciones generales de cirugía Bariátrica.",0,dHeader.size());
}

pc.addCols(" ",0,dHeader.size());
pc.addCols("Observaciones: "+prop.getProperty("observacion2"),0,dHeader.size());



pc.addTable();
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>