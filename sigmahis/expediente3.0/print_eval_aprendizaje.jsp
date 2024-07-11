<%@ page errorPage="../error.jsp" %>
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
String codigo = request.getParameter("codigo");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
cdoUsr.addColValue("usuario",userName);

if(desc == null) desc = "";
if (codigo == null) codigo = "0";
if (fp == null) fp = "";

prop = SQLMgr.getDataProperties("select evaluaciones from tbl_sal_eval_aprendizaje where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+codigo);

if (prop == null) prop = new Properties();

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
dHeader.addElement("2");
dHeader.addElement("18");
dHeader.addElement("2");
dHeader.addElement("18");
dHeader.addElement("2");
dHeader.addElement("18");
dHeader.addElement("2");
dHeader.addElement("18");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
pc.setTableHeader(1);

if(prop == null){
   pc.addCols(".:: No Se Ha Encontrado Registros! ::.",1,dHeader.size());
}else{
                 
    pc.setFont(9,0);
    
    cdo = SQLMgr.getData("select to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi am') fc, to_char(fecha_modificacion, 'dd/mm/yyyy hh12:mi:ss am') fm, usuario_creacion, usuario_modificacion from tbl_sal_eval_aprendizaje where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+codigo);
    
    if (cdo == null) cdo = new CommonDataObject();
 
    pc.setFont(9,0);

    pc.addCols("Fecha: ",0,1);
    pc.addCols(cdo.getColValue("fc"),0,3);
    pc.addCols("Usuario: ",2,3);
    pc.addCols(cdo.getColValue("usuario_creacion"),0,3);
    
    if (!"".equals(prop.getProperty("fecha_modificacion"))) { 
      pc.addBorderCols("Modif.: ",0,1,0.1f,0.0f,0.0f,0.0f);
      pc.addBorderCols(cdo.getColValue("fm"),0,3,0.1f,0.0f,0.0f,0.0f);
      pc.addBorderCols("Por: ",2,3,0.1f,0.0f,0.0f,0.0f);
      pc.addBorderCols(cdo.getColValue("usuario_modificacion"),0,3,0.1f,0.0f,0.0f,0.0f);
    }
    
    pc.addCols(" ",1,dHeader.size());
    
    if (fg.trim().equals("")){
    
    pc.setFont(9,1);
	pc.addCols("Relación:",0,2);
    
    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("relacion").equalsIgnoreCase("pa"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Paciente",0,1);
    
    pc.addImageCols( (prop.getProperty("relacion").equalsIgnoreCase("fa"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Familia",0,1);
    
    pc.addImageCols( (prop.getProperty("relacion").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Otros",0,3);
    
    if (prop.getProperty("relacion").equalsIgnoreCase("ot")){
        pc.addCols("Específique:",0,2);
        pc.addCols(prop.getProperty("observacion0"),0,dHeader.size() - 2);
    } else if (prop.getProperty("relacion").equalsIgnoreCase("pa") || prop.getProperty("relacion").equalsIgnoreCase("fa")) {
        pc.addCols("Nombre del Aprendiz:",0,2);
        pc.addCols(prop.getProperty("observacion7"),0,dHeader.size() - 2);
    }
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    
    pc.setFont(9,1);
	pc.addCols("Nivel Educativo / alfabetización:",0,2);
    
    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("nivel_educativo").equalsIgnoreCase("pr"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Primarios",0,1);
    
    pc.addImageCols( (prop.getProperty("nivel_educativo").equalsIgnoreCase("se"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Secundaria",0,1);
    
    pc.addImageCols( (prop.getProperty("nivel_educativo").equalsIgnoreCase("un"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Universitario",0,1);
    
    pc.addImageCols( (prop.getProperty("nivel_educativo").equalsIgnoreCase("lees"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Solo lee y escribe",0,1);
    
    pc.addCols(" ",0,2);
    
    pc.addImageCols( (prop.getProperty("nivel_educativo").equalsIgnoreCase("an"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Analfabeto",0,1);
    
    pc.addImageCols( (prop.getProperty("nivel_educativo").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Otros",0,1);
    pc.addCols(prop.getProperty("observacion1"),0,4);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    
    pc.setFont(9,1);
	pc.addCols("¿Tiene el aprendiz primario Alguna barrera o limitación para el aprendizaje?:",0,6);
    
    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("barrera0").equalsIgnoreCase("nt"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("No Tiene",0,1);
    pc.addImageCols( (prop.getProperty("barrera1").equalsIgnoreCase("lec"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Lectura",0,1);
    
    pc.addCols("",1,dHeader.size());
    
    pc.addCols(" ",0,2);
    
    pc.addImageCols( (prop.getProperty("barrera3").equalsIgnoreCase("vis"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Visual",0,1);
    
    pc.addImageCols( (prop.getProperty("barrera4").equalsIgnoreCase("aud"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Auditiva",0,1);
    
    pc.addImageCols( (prop.getProperty("barrera5").equalsIgnoreCase("fis"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Física",0,1);
    
    pc.addImageCols( (prop.getProperty("barrera6").equalsIgnoreCase("emo"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Emocional",0,1);
    
    pc.addCols("",1,dHeader.size());
    
    pc.addCols(" ",0,2);
    
    pc.addImageCols( (prop.getProperty("barrera7").equalsIgnoreCase("cul"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Cultural",0,1);
    
    pc.addImageCols( (prop.getProperty("barrera8").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Otros",0,1);
    pc.addCols(prop.getProperty("observacion2"),0,4);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    
    pc.setFont(9,1);
	pc.addCols("¿Cuál es el idioma de preferencia del aprendiz para las instrucciones de salud?:",0,4);
    
    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("idioma").equalsIgnoreCase("es"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Español",0,1);
    
    pc.addImageCols( (prop.getProperty("idioma").equalsIgnoreCase("en"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Inglés",0,1);
    
    pc.addImageCols( (prop.getProperty("idioma").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Otros",0,1);
    
    pc.addCols("Específique:",0,2);
    pc.addCols(prop.getProperty("observacion3"),0,dHeader.size()-2);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    
    pc.setFont(9,1);
	pc.addCols("¿Se requiere intérprete?",0,2);
    
    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("interprete").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("NO",0,1);
    
    pc.addImageCols( (prop.getProperty("interprete").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("SI",0,1);
    
    pc.addCols(prop.getProperty("observacion5"),0,dHeader.size()-6);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    
    pc.setFont(9,1);
	pc.addCols("Disposición para el aprendizaje:",0,2);
    
    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("disposicion_aprendizaje").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("SI",0,1);
    
    pc.addImageCols( (prop.getProperty("disposicion_aprendizaje").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("NO",0,1);
    
    pc.addCols(prop.getProperty("observacion6"),0,dHeader.size()-6);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    
    pc.setFont(9,1);
	pc.addCols("¿Cómo quiere el aprendiz primario conocer los nuevos conceptos?:",0,6);
    
    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("manera_aprender").equalsIgnoreCase("es"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Escuchar",0,1);
    
    pc.addImageCols( (prop.getProperty("manera_aprender").equalsIgnoreCase("le"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Leer",0,1);
    
    pc.addCols("",1,dHeader.size());
    
    pc.addCols(" ",0,2);
    
    pc.addImageCols( (prop.getProperty("manera_aprender").equalsIgnoreCase("de"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Demostración",0,1);
    
    pc.addImageCols( (prop.getProperty("manera_aprender").equalsIgnoreCase("ta"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Taller",0,1);
    
    pc.addImageCols( (prop.getProperty("manera_aprender").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Otro",0,3);
    
    pc.addCols("Específique: ",0,2);
    pc.addCols(prop.getProperty("observacion4"),0,dHeader.size()-2);
    } else{
        pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
    
    pc.setFont(9,1);
	pc.addCols("¿Tiene el aprendiz primario Alguna barrera o limitación para el aprendizaje?:",0,6);
    
    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("barrera0").equalsIgnoreCase("nt"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("No Tiene",0,1);
    pc.addImageCols( (prop.getProperty("barrera1").equalsIgnoreCase("lec"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Lectura",0,1);
    
    pc.addCols("",1,dHeader.size());
    
    pc.addCols(" ",0,2);
    
    pc.addImageCols( (prop.getProperty("barrera3").equalsIgnoreCase("vis"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Visual",0,1);
    
    pc.addImageCols( (prop.getProperty("barrera4").equalsIgnoreCase("aud"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Auditiva",0,1);
    
    pc.addImageCols( (prop.getProperty("barrera5").equalsIgnoreCase("fis"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Física",0,1);
    
    pc.addImageCols( (prop.getProperty("barrera6").equalsIgnoreCase("emo"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Emocional",0,1);
    
    pc.addCols("",1,dHeader.size());
    
    pc.addCols(" ",0,2);
    
    pc.addImageCols( (prop.getProperty("barrera7").equalsIgnoreCase("cul"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Cultural",0,1);
    
    pc.addImageCols( (prop.getProperty("barrera8").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Otros",0,1);
    pc.addCols(prop.getProperty("observacion2"),0,4);
    }

}//else

pc.addTable();
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>