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

StringBuffer sbSql = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String code = request.getParameter("code");
String condTitle = request.getParameter("cond_title");
if (condTitle == null) condTitle = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";

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
String subTitle = !desc.equals("")?desc:"RESUMEN DE EDUCACIÓN DEL PACIENTE";
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

Hashtable iFormas = new Hashtable();
iFormas.put("O","Oral");
iFormas.put("D","Demostración");
iFormas.put("H","Documentación");
iFormas.put("A","Audiovisual");
iFormas.put("T","Taller");

Hashtable iQuienRecibe = new Hashtable();
iQuienRecibe.put("P","Paciente");
iQuienRecibe.put("F","Familiar");

Hashtable iEval = new Hashtable();
iEval.put("1", "No se pudo realizar/entender");
iEval.put("2", "Necesita reforzamiento y/o práctica");
iEval.put("3", "Realiza / Verbaliza comprende");

Hashtable iInsIng = new Hashtable();
iInsIng.put("1", "Funcionamiento y uso del llamado de enfermera");
iInsIng.put("2", "Derechos y deberes");
iInsIng.put("3", "Resaltar importancia de no tener objetos de valor consigo durante la hospitalización");
iInsIng.put("4", "Visitas, rutinas, restricciones y normas de la unidad");
iInsIng.put("5", "Importancia del respeto de las normas de bioseguridad");
iInsIng.put("6", "Prevención de caídas");
iInsIng.put("7", "Evaluación , reevaluación y Manejo del dolor");
iInsIng.put("8", "Seguridad y uso efectivo de la tecnología médica(alarmas, ruidos, equipos)");
iInsIng.put("9", "Restricciones de Medicamentos usados en casa");
iInsIng.put("10", "Estándar de Seguridad, Identificación del Paciente y lavado de manos");

Hashtable iInsGenerales = new Hashtable();
iInsGenerales.put("1","Funcionamiento y uso del llamado de enfermera");
iInsGenerales.put("2","Derechos y Responsabilidades");
iInsGenerales.put("3","importancia de no tener objetos de valor consigo durante la hospitalización");
iInsGenerales.put("4","Visitas, rutina,restricciones y normas de la unidad");
iInsGenerales.put("5","importancia del respeto de las normas de bioseguridad");
iInsGenerales.put("6","Estandares de seguridad Identificación, lavado mano, restricción de medicamentos usados en casa");
iInsGenerales.put("7","*INSTRUCCIONES DE MEDICAMENTOS");
iInsGenerales.put("8","* EVALUACIÓN REEVALUACIÓN Y MANEJO DEL DOLOR (ESCALAS, INTERVENCIONES)");
iInsGenerales.put("9","* PREVENCIÓN DE CAÍDA");
iInsGenerales.put("10","* SEGURIDAD Y USO EFECTIVO DE LA TECNOLOGÍA MÉDICA(Alarmas,ruidos equipos)");
iInsGenerales.put("11","* TRATAMIENTO");
iInsGenerales.put("12","* PLAN DE SALIDA");

CommonDataObject cdoIns = new CommonDataObject();
Hashtable iInsIngSe = new Hashtable();
String tipoSumario = "AD";

cdo = SQLMgr.getData("select (select diagnostico from tbl_adm_diagnostico_x_admision where pac_id = adm.pac_id and admision = adm.secuencia and tipo = 'I' and orden_diag = 1) codigo_diag, (select (select nvl(observacion, nombre) from tbl_cds_diagnostico where codigo = a.diagnostico ) from tbl_adm_diagnostico_x_admision a where pac_id = adm.pac_id and admision = adm.secuencia and tipo = 'I' and orden_diag = 1)  desc_diag,(select count(*) count_neo from tbl_sal_sumario_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_sumario = 'NEO') as count_neo from tbl_adm_admision adm where adm.pac_id = "+pacId+" and adm.secuencia = "+noAdmision);

if (cdo==null) {
  cdo = new CommonDataObject();
  cdo.addColValue("count_neo","0");
}

int countNeo = Integer.parseInt(cdo.getColValue("count_neo", "0"));

if ( countNeo > 0 ) {
    tipoSumario = "NEO";

    iInsIngSe.put("0", "Lactancia materna");
    iInsIngSe.put("1", "Complemento (tipo formula)");
    iInsIngSe.put("2", "Forma de preparación");
    iInsIngSe.put("3", "Posición de la madre y bebe");
    iInsIngSe.put("4", "Baño del bebe");
    iInsIngSe.put("5", "Forma de sacar los gases");
    iInsIngSe.put("6", "Cuidados del cordón umbilical");
    iInsIngSe.put("7", "Higiene de genitales");
    iInsIngSe.put("8", "Cuidados de circuncisión");
    
} else  {

   iInsIngSe.put("0", "Equipos especiales");
   iInsIngSe.put("1", "Cuidados post operatorios");
   iInsIngSe.put("2", "Curación de heridas");
   iInsIngSe.put("3", "Signos y síntomas de infección");
   iInsIngSe.put("4", "Terapia respiratoria");
   iInsIngSe.put("5", "Fisioterapia");
   iInsIngSe.put("6", "Glicemia capilar");
   iInsIngSe.put("7", "Dieta especial");
   iInsIngSe.put("8", "Prevención de caídas");
   iInsIngSe.put("9", "Manejo del dolor");
   iInsIngSe.put("10", "Medicamentos");
   iInsIngSe.put("11", "Otros");
}

cdoIns = SQLMgr.getData("select acciones from tbl_sal_sumario_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_sumario = '"+tipoSumario+"'");

if (cdoIns == null) {
 cdoIns = new CommonDataObject();
 cdoIns.addColValue("acciones"," ");
}

Properties pse = SQLMgr.getDataProperties("select sumario from tbl_sal_sumario_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_sumario = '"+tipoSumario+"'");
if (pse == null) pse = new Properties();

Hashtable iOtros = new Hashtable();
iOtros.put("1", "OTROS TEMAS");
iOtros.put("2", "PEDIATRIA");

Hashtable iSop = new Hashtable();
iSop.put("1", "SALÓN DE OPERACIONES");
iSop.put("2", "Pre operatoria");
iSop.put("3", "Consentimientos");
iSop.put("4", "Prevencion de Caídas");
iSop.put("5", "Pausa de seguridad");
iSop.put("5", "Preparación");
iSop.put("6", "Medicamentos");
iSop.put("7", "Otros");
iSop.put("8", "Post Operatoria");
iSop.put("9", "Àrea de recobro");
iSop.put("10", "Evaluación");
iSop.put("11", "Manejo del dolor");
iSop.put("12", "Prevencion de Caídas");
iSop.put("13", "Otro");

//Partos
iSop.put("14", "PARTOS");
iSop.put("15", "Norma de la sala");
iSop.put("16", "Monitoreo");
iSop.put("17", "Prevencion de Caídas");
iSop.put("18", "Labor y parto");
iSop.put("19", "Consentimientos");
iSop.put("20", "Dolor y analgesia");
iSop.put("21", "Respiración");
iSop.put("22", "Relajación");
iSop.put("23", "Lactancia");

// Nutricion
Hashtable iNutricion = new Hashtable();
/*iNutricion.put("1", "Entrega Volante Educativa Tipo De Dieta escogida para paciente");
iNutricion.put("2", "Entrega Volante Educativa Interacción Droga/Alimento");
iNutricion.put("3", "Educación Tipo de Dieta de Preparación Fuera de Hospital");
iNutricion.put("4", "Rechazo De Dieta Hospitalaria-Paciente: Por dieta según la cultura del paciente");*/
    
Hashtable iNeo = new Hashtable();
iNeo.put("1", "Norma");
iNeo.put("2", "Identificación");
iNeo.put("3", "Cuidado de transición");
iNeo.put("4", "Apego madre -hijo");
iNeo.put("5", "Lactancia materna:posturas y tecnicas");
iNeo.put("6", "Recolección de leche materna y su manejo");
iNeo.put("7", "Uso de ordeñadores");
iNeo.put("8", "Higiene y baño del recien nacido");
iNeo.put("9", "Vigilancia del recien nacido: cambios importantes. (ictericia, aspecto del meconio diuresis, cuidado del ombligo,color, piel)");
iNeo.put("10","NUTRICIÓN: (específique)");
iNeo.put("11","TERAPIA RESPIRATORIA: (específique)");
iNeo.put("12","TÉCNICA DE REHABILITACIÓN: (específique)");
iNeo.put("13","TEMAS MÉDICOS");
iNeo.put("14","ORIENTACIÓN MÉDICA A LA ADMISIÓN");
iNeo.put("15","PROCEDIMIENTOS MÉDICOS");
iNeo.put("16","COMPLICACIONES");
iNeo.put("17","PRUEBAS COMPLEMENTARIAS");
iNeo.put("18","CONSENTIMIENTOS");
iNeo.put("19","INSTRUCCIONES DE MEDICAMENTOS (posibles efectos adversos, reacciones de hipersensibilidad)");
iNeo.put("20","ORIENTACIÓN MÉDICA AL EGRESO (Sumario de Egreso,Carenotes, signos de alarma)");

Vector tblMain = new Vector();
tblMain.addElement("2");
tblMain.addElement("2");
tblMain.addElement("2");
tblMain.addElement("51");
tblMain.addElement("11");
tblMain.addElement("11");
tblMain.addElement("11");
tblMain.addElement("10");

pc.setNoColumnFixWidth(tblMain);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblMain.size());
pc.setTableHeader(1);

sbSql.append("select resumen from tbl_sal_resumen_edu where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and admision = ");
sbSql.append(noAdmision);
if (code != null && !code.trim().equals("")) {
	sbSql.append(" and codigo = ");
	sbSql.append(code);
}
sbSql.append("order by fecha_creacion");
ArrayList al = SQLMgr.getDataPropertiesList(sbSql.toString());
int domIndex = 0;

for (int j = 0; j < al.size(); j++) {
	prop = (Properties) al.get(j);
	domIndex = iInsIng.size() + 1;

pc.setFont(9,0);
pc.addBorderCols("Fecha: ",0,3,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(prop.getProperty("fecha_creacion"),0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols("Usuario: ",1,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(prop.getProperty("usuario_creacion"),0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols("",0,2,0.1f,0.0f,0.0f,0.0f);
pc.addCols(" ",1,tblMain.size());

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1);
pc.addBorderCols("Evaluación al Ingreso",1,3, Color.lightGray);
pc.addBorderCols("TEMAS EDUCATIVOS",1,1,Color.lightGray);
pc.addBorderCols("EDUCACIÓN DEL PACIENTE",1,4, Color.lightGray);

pc.addBorderCols("E",1,1, Color.lightGray);
pc.addBorderCols("R",1,1, Color.lightGray);
pc.addBorderCols("C",1,1, Color.lightGray);
pc.addBorderCols("E = Necesita que se le enseñe No domina el tema\nR = Necesita reforzamiento, lo domina parcialmente\nC = Se siente cómodo con el tema, lo entiende y domina",0,1,Color.lightGray);
pc.addBorderCols("Fecha",1,1, Color.lightGray);
pc.addBorderCols("Forma",1,1, Color.lightGray);
pc.addBorderCols("Inicial a quién orienta",1,1, Color.lightGray);
pc.addBorderCols("Evaluación",1,1, Color.lightGray);

boolean showAll = false;
if (showAll || (prop.getProperty("acompaniado_por1") != null && !prop.getProperty("acompaniado_por1").trim().equals(""))) {
pc.addBorderCols("",0,3);
pc.addBorderCols("*INSTRUCCIONES AL INGRESO",0,1);
pc.addBorderCols("",0,4);

pc.setFont(9,0);
	for (int i = 1; i <= iInsIng.size(); i++) {
    pc.addImageCols( (prop.getProperty("acompaniado_por"+i) != null && prop.getProperty("acompaniado_por"+i).equalsIgnoreCase("E"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    pc.addImageCols( (prop.getProperty("acompaniado_por"+i) != null && prop.getProperty("acompaniado_por"+i).equalsIgnoreCase("R"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    pc.addImageCols( (prop.getProperty("acompaniado_por"+i) != null && prop.getProperty("acompaniado_por"+i).equalsIgnoreCase("C"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    
    pc.addBorderCols(""+iInsIng.get(""+i),0,1);
    
    if(i != 1){
      pc.addBorderCols("",0,4);
    } else {
      pc.addBorderCols(prop.getProperty("fecha0_"+i),1,1);
      pc.addBorderCols((String) iFormas.get(prop.getProperty("forma0_"+i)),1,1);
      pc.addBorderCols((String) iQuienRecibe.get(prop.getProperty("quien_recibe0_"+i)),1,1);
      pc.addBorderCols((String) iEval.get(prop.getProperty("evaluacion0_"+i)),1,1);
    }
	}

	pc.addCols(" ",0, tblMain.size());
}



pc.setFont(9,1);
pc.addBorderCols("",0,3);
pc.addBorderCols("*INSTRUCCIONES GENERALES",0,1);
pc.addBorderCols("",0,4);

pc.setFont(9,0);
boolean showTitle = false;
for (int i = 1; i <= iInsGenerales.size(); i++) { 
	domIndex++;
    
	if (showAll || (prop.getProperty("acompaniado_por"+domIndex) != null && !prop.getProperty("acompaniado_por"+domIndex).trim().equals(""))) {
    showTitle = true;
    pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("E"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("R"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("C"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    
    String generalesDesc = "";
    if (iInsGenerales.get(i+"")!=null && !(""+iInsGenerales.get(i+"")).equals("")) generalesDesc = ""+iInsGenerales.get(i+"");
    
    String formas = "", quienRecibe = "", evaluacion = "";
    if (iFormas.get(prop.getProperty("forma0_"+domIndex)) != null && !(""+iFormas.get(prop.getProperty("forma0_"+domIndex))).equals("") ) formas = ""+iFormas.get(prop.getProperty("forma0_"+domIndex));
    
    if (iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex)) != null && !(""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex))).equals("") ) quienRecibe = ""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex));
    
    if (iEval.get(prop.getProperty("evaluacion0_"+domIndex)) != null && !(""+iEval.get(prop.getProperty("evaluacion0_"+domIndex))).equals("") ) evaluacion = ""+iEval.get(prop.getProperty("evaluacion0_"+domIndex));
    
    if (i<8) {
       pc.addBorderCols(i+".  "+generalesDesc,0,1);
    } else {
       pc.setFont(9,1);
       pc.addBorderCols(generalesDesc,0,1);
       pc.setFont(9,0);
    }
    
    pc.addBorderCols(prop.getProperty("fecha0_"+domIndex),1,1);
    pc.addBorderCols(formas,1,1);
    pc.addBorderCols(quienRecibe,1,1);
    pc.addBorderCols(evaluacion,1,1);
	}
}

if (showTitle) pc.addCols(" ",0, tblMain.size());
else pc.deleteRows(-1);




if (showAll || (prop.getProperty("acompaniado_por"+(domIndex + 1)) != null && !prop.getProperty("acompaniado_por"+(domIndex + 1)).trim().equals(""))) {
pc.setFont(9,1);
pc.addBorderCols("",0,3);
pc.addBorderCols("*INSTRUCCIONES AL EGRESO (S.E)",0,1);
pc.addBorderCols("",0,4);

pc.setFont(9,0);
	for (int i = 0; i < iInsIngSe.size(); i++) { 
    domIndex++;
	if (showAll || (pse.getProperty("instrucciones"+i) != null && !pse.getProperty("instrucciones"+i).trim().equals("")) || (prop.getProperty("observacion"+domIndex) != null && !prop.getProperty("observacion"+domIndex).trim().equals(""))) {
    pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("E"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("R"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("C"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    
    pc.addBorderCols(""+iInsIngSe.get(""+i)+"\n\n"+prop.getProperty("observacion"+domIndex),0,1);
    
    if(i != 0){
      pc.addBorderCols("",0,4);
    } else {
  
			String formas = "", quienRecibe = "", evaluacion = "";
			if (iFormas.get(prop.getProperty("forma0_"+domIndex)) != null && !(""+iFormas.get(prop.getProperty("forma0_"+domIndex))).equals("") ) formas = ""+iFormas.get(prop.getProperty("forma0_"+domIndex));
			
			if (iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex)) != null && !(""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex))).equals("") ) quienRecibe = ""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex));
			
			if (iEval.get(prop.getProperty("evaluacion0_"+domIndex)) != null && !(""+iEval.get(prop.getProperty("evaluacion0_"+domIndex))).equals("") ) evaluacion = ""+iEval.get(prop.getProperty("evaluacion0_"+domIndex));
			
			pc.addBorderCols(prop.getProperty("fecha0_"+domIndex),1,1);
			pc.addBorderCols(formas,1,1);
			pc.addBorderCols(quienRecibe,1,1);
			pc.addBorderCols(evaluacion,1,1);
    }
	}
  }
} else {
	domIndex += iInsIngSe.size();
}

for (int i = 1; i <= iOtros.size(); i++) { 
    domIndex++;

	if (showAll || (prop.getProperty("acompaniado_por"+domIndex) != null && !prop.getProperty("acompaniado_por"+domIndex).trim().equals(""))) {
    pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("E"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("R"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("C"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols(""+iOtros.get(""+i)+"\n\n"+prop.getProperty("observacion"+domIndex),0,1);
    
    String formas = "", quienRecibe = "", evaluacion = "";
    if (iFormas.get(prop.getProperty("forma0_"+domIndex)) != null && !(""+iFormas.get(prop.getProperty("forma0_"+domIndex))).equals("") ) formas = ""+iFormas.get(prop.getProperty("forma0_"+domIndex));
    
    if (iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex)) != null && !(""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex))).equals("") ) quienRecibe = ""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex));
    
    if (iEval.get(prop.getProperty("evaluacion0_"+domIndex)) != null && !(""+iEval.get(prop.getProperty("evaluacion0_"+domIndex))).equals("") ) evaluacion = ""+iEval.get(prop.getProperty("evaluacion0_"+domIndex));
    
    pc.addBorderCols(prop.getProperty("fecha0_"+domIndex),1,1);
    pc.addBorderCols(formas,1,1);
    pc.addBorderCols(quienRecibe,1,1);
    pc.addBorderCols(evaluacion,1,1);
	}
}

boolean printed = false;
int nRecs = 0;
for (int i = 1; i <= iSop.size(); i++) { 
    domIndex++;
    String sopDesc = iSop.get(""+i) !=null?iSop.get(""+i).toString().trim():"";

    if (sopDesc.equalsIgnoreCase("SALÓN DE OPERACIONES")||sopDesc.equalsIgnoreCase("Pre operatoria")||sopDesc.equalsIgnoreCase("Post Operatoria")||sopDesc.equalsIgnoreCase("PARTOS")){
				if (i != 1 && !showTitle && printed) { pc.deleteRows(-1); }
				if (!sopDesc.equalsIgnoreCase("SALÓN DE OPERACIONES")) {
					printed = true;
					if (sopDesc.equalsIgnoreCase("PARTOS")) {
						if (nRecs == 0) { pc.deleteRows(-1); }
						nRecs = 0;
					}
				}
				showTitle = false;
				pc.setFont(9,1);
        pc.addCols("",0,3);
        pc.addCols(sopDesc,0,1);
        pc.addCols("",0,4);
    } else {
        pc.setFont(9,0);
			if (showAll || (prop.getProperty("acompaniado_por"+domIndex) != null && !prop.getProperty("acompaniado_por"+domIndex).trim().equals("")) || (prop.getProperty("observacion"+domIndex) != null && !prop.getProperty("observacion"+domIndex).trim().equals(""))) {
				showTitle = true;
				nRecs++;
        pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("E"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
        pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("R"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
        pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("C"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
        
        pc.addBorderCols(sopDesc+((prop.getProperty("observacion"+domIndex) != null && !prop.getProperty("observacion"+domIndex).trim().equals(""))?"\n\n"+prop.getProperty("observacion"+domIndex):""),0,1);
				
        String formas = "", quienRecibe = "", evaluacion = "";
        if (iFormas.get(prop.getProperty("forma0_"+domIndex)) != null && !(""+iFormas.get(prop.getProperty("forma0_"+domIndex))).equals("") ) formas = ""+iFormas.get(prop.getProperty("forma0_"+domIndex));
        
        if (iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex)) != null && !(""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex))).equals("") ) quienRecibe = ""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex));
        
        if (iEval.get(prop.getProperty("evaluacion0_"+domIndex)) != null && !(""+iEval.get(prop.getProperty("evaluacion0_"+domIndex))).equals("") ) evaluacion = ""+iEval.get(prop.getProperty("evaluacion0_"+domIndex));
        
        pc.addBorderCols(prop.getProperty("fecha0_"+domIndex),1,1);
        pc.addBorderCols(formas,1,1);
        pc.addBorderCols(quienRecibe,1,1);
        pc.addBorderCols(evaluacion,1,1);
      }
			if(i == iSop.size()){
				domIndex++;
				if (showAll || (prop.getProperty("observacion"+domIndex) != null && !prop.getProperty("observacion"+domIndex).trim().equals(""))) {
					showTitle = true;
					nRecs++;
          pc.addCols("Otro: ",0,3);
          pc.addCols(prop.getProperty("observacion"+domIndex),0,1);
          pc.addBorderCols(prop.getProperty("fecha0_"+domIndex),1,1);
          
          String formas = "", quienRecibe = "", evaluacion = "";
					if (iFormas.get(prop.getProperty("forma0_"+domIndex)) != null && !(""+iFormas.get(prop.getProperty("forma0_"+domIndex))).equals("") ) formas = ""+iFormas.get(prop.getProperty("forma0_"+domIndex));
        
          if (iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex)) != null && !(""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex))).equals("") ) quienRecibe = ""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex));
        
          if (iEval.get(prop.getProperty("evaluacion0_"+domIndex)) != null && !(""+iEval.get(prop.getProperty("evaluacion0_"+domIndex))).equals("") ) evaluacion = ""+iEval.get(prop.getProperty("evaluacion0_"+domIndex));
        
          pc.addBorderCols(formas,1,1);
          pc.addBorderCols(quienRecibe,1,1);
          pc.addBorderCols(evaluacion,1,1);
        }
      } 
    }
}
if (nRecs == 0) { pc.deleteRows(-1); }
else pc.addCols(" ",0, tblMain.size());

// nutricion
pc.setFont(9,1);
pc.addCols("",0,3);
pc.addCols("NUTRICIÓN",0,1);
pc.addCols("",0,4);
pc.setFont(9,0);

printed = true;//neo header printed
nRecs = 0;
showTitle = false;
for (int i = 1; i <= iNutricion.size(); i++) { 
    domIndex++;
    String neoDesc = iNutricion.get(""+i) !=null?iNutricion.get(""+i).toString().trim():"";
    
    if (neoDesc.equalsIgnoreCase("TEMAS MÉDICOS")) {
			if (i != 1 && !showTitle) { pc.deleteRows(-1); }
			nRecs = 0;
			showTitle = false;

			pc.setFont(9,1);
			pc.addCols("",0,3);
			pc.addBorderCols(neoDesc,0,1);
			pc.addCols("",0,4);
		} else {
			if (showAll || (prop.getProperty("acompaniado_por"+domIndex) != null && !prop.getProperty("acompaniado_por"+domIndex).trim().equals(""))) {
				showTitle = true;
				if (!neoDesc.contains("NUTRICIÓN") && !neoDesc.contains("TERAPIA RESPIRATORIA") && !neoDesc.contains("TÉCNICA DE REHABILITACIÓN")) nRecs++;
        pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("E"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
        pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("R"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
        pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("C"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);

				if(neoDesc.contains("específique")) neoDesc += "\n\n"+prop.getProperty("observacion"+domIndex);
				if(neoDesc.contains("NUTRICIÓN") || neoDesc.contains("TERAPIA RESPIRATORIA") || neoDesc.contains("TÉCNICA DE REHABILITACIÓN")){
					if (printed && nRecs == 0) { pc.deleteRows(-1); printed = false; }
					pc.setFont(9,1);
					pc.addBorderCols(neoDesc,0,1);
				} else {
					pc.setFont(9,0);
					pc.addBorderCols(neoDesc,0,1);
				}
				String formas = "", quienRecibe = "", evaluacion = "";
				if (iFormas.get(prop.getProperty("forma0_"+domIndex)) != null && !(""+iFormas.get(prop.getProperty("forma0_"+domIndex))).equals("") ) formas = ""+iFormas.get(prop.getProperty("forma0_"+domIndex));
				
				if (iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex)) != null && !(""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex))).equals("") ) quienRecibe = ""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex));
				
				if (iEval.get(prop.getProperty("evaluacion0_"+domIndex)) != null && !(""+iEval.get(prop.getProperty("evaluacion0_"+domIndex))).equals("") ) evaluacion = ""+iEval.get(prop.getProperty("evaluacion0_"+domIndex));
				
				pc.addBorderCols(prop.getProperty("fecha0_"+domIndex),1,1);
				pc.addBorderCols(formas,1,1);
				pc.addBorderCols(quienRecibe,1,1);
				pc.addBorderCols(evaluacion,1,1);
			}
		}
}
if (!showTitle) pc.deleteRows(-1);



// neonatologia
pc.setFont(9,1);
pc.addCols("",0,3);
pc.addCols("NEONATOLOGÍA",0,1);
pc.addCols("",0,4);
pc.setFont(9,0);

printed = true;//neo header printed
nRecs = 0;
showTitle = false;
for (int i = 1; i <= iNeo.size(); i++) { 
    domIndex++;
    String neoDesc = iNeo.get(""+i) !=null?iNeo.get(""+i).toString().trim():"";
    
    if (neoDesc.equalsIgnoreCase("TEMAS MÉDICOS")) {
			if (i != 1 && !showTitle) { pc.deleteRows(-1); }
			nRecs = 0;
			showTitle = false;

			pc.setFont(9,1);
			pc.addCols("",0,3);
			pc.addBorderCols(neoDesc,0,1);
			pc.addCols("",0,4);
		} else {
			if (showAll || (prop.getProperty("acompaniado_por"+domIndex) != null && !prop.getProperty("acompaniado_por"+domIndex).trim().equals(""))) {
				showTitle = true;
				if (!neoDesc.contains("NUTRICIÓN") && !neoDesc.contains("TERAPIA RESPIRATORIA") && !neoDesc.contains("TÉCNICA DE REHABILITACIÓN")) nRecs++;
        pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("E"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
        pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("R"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
        pc.addImageCols( (prop.getProperty("acompaniado_por"+domIndex) != null && prop.getProperty("acompaniado_por"+domIndex).equalsIgnoreCase("C"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);

				if(neoDesc.contains("específique")) neoDesc += "\n\n"+prop.getProperty("observacion"+domIndex);
				if(neoDesc.contains("NUTRICIÓN") || neoDesc.contains("TERAPIA RESPIRATORIA") || neoDesc.contains("TÉCNICA DE REHABILITACIÓN")){
					if (printed && nRecs == 0) { pc.deleteRows(-1); printed = false; }
					pc.setFont(9,1);
					pc.addBorderCols(neoDesc,0,1);
				} else {
					pc.setFont(9,0);
					pc.addBorderCols(neoDesc,0,1);
				}
				String formas = "", quienRecibe = "", evaluacion = "";
				if (iFormas.get(prop.getProperty("forma0_"+domIndex)) != null && !(""+iFormas.get(prop.getProperty("forma0_"+domIndex))).equals("") ) formas = ""+iFormas.get(prop.getProperty("forma0_"+domIndex));
				
				if (iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex)) != null && !(""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex))).equals("") ) quienRecibe = ""+iQuienRecibe.get(prop.getProperty("quien_recibe0_"+domIndex));
				
				if (iEval.get(prop.getProperty("evaluacion0_"+domIndex)) != null && !(""+iEval.get(prop.getProperty("evaluacion0_"+domIndex))).equals("") ) evaluacion = ""+iEval.get(prop.getProperty("evaluacion0_"+domIndex));
				
				pc.addBorderCols(prop.getProperty("fecha0_"+domIndex),1,1);
				pc.addBorderCols(formas,1,1);
				pc.addBorderCols(quienRecibe,1,1);
				pc.addBorderCols(evaluacion,1,1);
			}
		}
}
if (!showTitle) pc.deleteRows(-1);

	pc.flushTableBody(true);
	pc.addNewPage();
}
System.out.println(".................................... domIndex = "+domIndex);
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>