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
String code = request.getParameter("code");
String condTitle = request.getParameter("cond_title");
String fp = request.getParameter("fp");

if (condTitle == null) condTitle = "";
if (fp == null) fp = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
prop = SQLMgr.getDataProperties("select nota from tbl_sal_notas_diarias_enf where id = "+code+" and tipo_nota = '"+fg+"'");

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
String subTitle = !desc.equals("")?desc:"NOTAS DIARIAS DE ENFERMERIA";
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

Vector tblMain = new Vector();
tblMain.addElement("10"); 
tblMain.addElement("10");
tblMain.addElement("2");
tblMain.addElement("18");
tblMain.addElement("2");
tblMain.addElement("18");
tblMain.addElement("2");
tblMain.addElement("18");
tblMain.addElement("2");
tblMain.addElement("18");

boolean isFragment = fp.trim().equalsIgnoreCase("exp_kardex");

pc.setNoColumnFixWidth(tblMain);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblMain.size());
pc.setTableHeader(1);

pc.setFont(9,0);
pc.addBorderCols("Fecha: ",0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(prop.getProperty("fecha"),0,3,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols("Usuario: ",1,2,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(prop.getProperty("usuario_creacion"),0,2,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols("",0,4,0.1f,0.0f,0.0f,0.0f);
pc.addCols(" ",1,tblMain.size());

if (!isFragment){
if (fg.trim().equalsIgnoreCase("NDNO")){
pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Se Recibe R. Nac.: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("llegada").equalsIgnoreCase("ba"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Bacinete",0,1);

pc.addImageCols( (prop.getProperty("llegada").equalsIgnoreCase("fo"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Fototerapia",0,1);

pc.addImageCols( (prop.getProperty("llegada").equalsIgnoreCase("o2"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("O2",0,3);

pc.addCols("",1,tblMain.size());
pc.setFont(9,0);
pc.addCols("",0,2);
pc.addCols("Incubadora:",1,2);

pc.addImageCols( (prop.getProperty("llegada2").equalsIgnoreCase("abi"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Abierto",0,1);

pc.addImageCols( (prop.getProperty("llegada2").equalsIgnoreCase("cer"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Cerrado",0,3);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Respiración: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("respiracion").equalsIgnoreCase("nor"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Normal",0,1);

pc.addImageCols( (prop.getProperty("respiracion").equalsIgnoreCase("fre"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Frecuencia",0,1);

pc.addImageCols( (prop.getProperty("respiracion").equalsIgnoreCase("que"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Quejido",0,1);

pc.addImageCols( (prop.getProperty("respiracion").equalsIgnoreCase("tir"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Tiraje",0,1);

pc.addCols("",1,tblMain.size());
pc.addCols(" ",0,2);
pc.addImageCols( (prop.getProperty("respiracion").equalsIgnoreCase("ale"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Aleteo",0,7);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Llanto: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("llanto").equalsIgnoreCase("fu"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Fuerte",0,1);

pc.addImageCols( (prop.getProperty("llanto").equalsIgnoreCase("de"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Débil",0,5);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Sist. Nervioso: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("actividad").equalsIgnoreCase("ac"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Activo",0,1);

pc.addImageCols( (prop.getProperty("actividad").equalsIgnoreCase("hi"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Hipoactivo",0,1);

pc.addImageCols( (prop.getProperty("actividad").equalsIgnoreCase("hip"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Hipotónico",0,1);

pc.addImageCols( (prop.getProperty("actividad").equalsIgnoreCase("tem"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Temblores",0,1);

pc.addCols("",1,tblMain.size());
pc.addCols(" ",0,2);
pc.addImageCols( (prop.getProperty("actividad").equalsIgnoreCase("con"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Convulsiones",0,7);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Piel: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("piel").equalsIgnoreCase("ac"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Rosada",0,1);

pc.addImageCols( (prop.getProperty("piel").equalsIgnoreCase("pal"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Pálida",0,1);

pc.addImageCols( (prop.getProperty("piel").equalsIgnoreCase("cia"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Cianosis",0,3);

pc.addCols("",0,tblMain.size());
pc.addCols("Ictericia:",1,2);

pc.addImageCols( (prop.getProperty("piel2").equalsIgnoreCase("le"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Leve",0,1);

pc.addImageCols( (prop.getProperty("piel2").equalsIgnoreCase("mo"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Moderada",0,1);

pc.addImageCols( (prop.getProperty("piel2").equalsIgnoreCase("se"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Severa",0,3);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Temperatura: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("temperatura").equalsIgnoreCase("no"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Normotermico",0,1);

pc.addImageCols( (prop.getProperty("temperatura").equalsIgnoreCase("hi"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Hipotermico",0,5);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Succión: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("succion").equalsIgnoreCase("b"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Buena",0,1);

pc.addImageCols( (prop.getProperty("succion").equalsIgnoreCase("m"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Malo",0,5);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Higiene: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("bano").equalsIgnoreCase("g"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("General",0,1);

pc.addImageCols( (prop.getProperty("bano").equalsIgnoreCase("p"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Parcial",0,5);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Profilaxis: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("profilaxis").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("SI",0,1);

pc.addImageCols( (prop.getProperty("profilaxis").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("NO",0,5);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Ombligo: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("Ombligo").equalsIgnoreCase("nor"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Normal",0,1);

pc.addImageCols( (prop.getProperty("Ombligo").equalsIgnoreCase("sec"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Secreción",0,1);

pc.addImageCols( (prop.getProperty("Ombligo").equalsIgnoreCase("enr"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Enrojecimiento",0,1);

pc.addImageCols( (prop.getProperty("Ombligo").equalsIgnoreCase("hem"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Hemorragia",0,1);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Orinó: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("orino").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("SI",0,1);

pc.addImageCols( (prop.getProperty("orino").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("NO",0,5);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Heces: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("heces").equalsIgnoreCase("si"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("SI",0,1);

pc.addImageCols( (prop.getProperty("heces").equalsIgnoreCase("no"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("NO",0,5);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Vomitó: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("vomito").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("SI",0,1);

pc.addImageCols( (prop.getProperty("vomito").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("NO",0,5);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Meconio: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("meconio").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("SI",0,1);

pc.addImageCols( (prop.getProperty("meconio").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("NO",0,5);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Abdomen: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("abdomen").equalsIgnoreCase("nor"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Normal",0,1);

pc.addImageCols( (prop.getProperty("abdomen").equalsIgnoreCase("dis"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Distendido",0,5);


pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Relación Madre-Hijo: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("apego").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Aceptación",0,1);

pc.addImageCols( (prop.getProperty("apego").equalsIgnoreCase("ins"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Inseguridad",0,1);

pc.addImageCols( (prop.getProperty("apego").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Rechazo",0,3);

pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);

pc.setFont(9,1,Color.gray);
pc.addCols("Alimentación: ",0,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("alimentacion").equalsIgnoreCase("pe"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Pecho exclusivo",0,1);

pc.addImageCols( (prop.getProperty("alimentacion").equalsIgnoreCase("fo"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Fórmula",0,1);

pc.addImageCols( (prop.getProperty("alimentacion").equalsIgnoreCase("son"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Sonda",0,3);

pc.addCols("",1,tblMain.size());

pc.addCols("",0,2);
pc.setFont(9,1);
pc.addCols("Aceptación:",1,2);

pc.setFont(9,0);
pc.addImageCols( (prop.getProperty("alimentacionPor").equalsIgnoreCase("si"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Buena",0,1);

pc.addImageCols( (prop.getProperty("alimentacionPor").equalsIgnoreCase("ep"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Rechazo",0,1);

pc.addImageCols( (prop.getProperty("alimentacionPor").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Regurgitación",0,1);

pc.addCols("",0,4);
pc.addImageCols( (prop.getProperty("alimentacionPor").equalsIgnoreCase("vom"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
pc.addCols("Vomitó",0,5);

} else {

    pc.setFont(9,1,Color.gray);
    pc.addCols("Estado de Conciencia: ",0,2);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("estado_conciencia0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Alerta",0,1);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("estado_conciencia1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Conciente",0,1);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("estado_conciencia2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Orientado",0,1);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("estado_conciencia3").equalsIgnoreCase("OT"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Otros",0,1);
    
    pc.addCols("Específique:",0,2);
    pc.addCols(prop.getProperty("observacion0"),0,tblMain.size() - 2);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("Respiración: ",0,2);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("respiracion").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Eupneica",0,1);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("respiracion").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Taquipnea",0,1);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("respiracion").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Apnea",0,1);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("respiracion").equalsIgnoreCase("OT"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Otro",0,1);
    
    pc.addCols("Específique:",0,2);
    pc.addCols(prop.getProperty("observacion1"),0,tblMain.size() - 2);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("Cardiaco: ",0,2);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("cardiaco").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Pulso Regular",0,1);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("cardiaco").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Irregular",0,1);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("cardiaco_irregular_debil").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Débil",0,3);
    
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("Abdomen: ",0,2);

    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("abdomen0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Suave",0,1);
    
    pc.addImageCols( (prop.getProperty("abdomen1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Distendido",0,1);
    
    pc.addImageCols( (prop.getProperty("abdomen2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Timpanico",0,1);
    
    pc.addImageCols( (prop.getProperty("abdomen3").equalsIgnoreCase("OT"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Otro",0,1);
    
    pc.addCols("Específique:",0,2);
    pc.addCols(prop.getProperty("observacion2"),0,tblMain.size() - 2);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("Piel: ",0,2);

    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("piel").equalsIgnoreCase("I"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Integra",0,1);
    
    pc.addImageCols( (prop.getProperty("piel").equalsIgnoreCase("U"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Úlcera",0,1);
    
    pc.addCols(prop.getProperty("observacion3"),0,4);
    
    pc.addCols("",0,2);
    pc.addImageCols( (prop.getProperty("piel").equalsIgnoreCase("hq"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Herida quirúrgica",0,1);
    
    pc.addImageCols( (prop.getProperty("herida0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Área",0,1);
    
    pc.addImageCols( (prop.getProperty("herida1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Apósitos",0,1);
    
    pc.addImageCols( (prop.getProperty("herida2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Drenajes",0,1);
    
    pc.addCols("",0,2);
    pc.addImageCols( (prop.getProperty("herida3").equalsIgnoreCase("OT"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Otros",0,1);
    
    pc.addCols(prop.getProperty("observacion4"),0,6);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("Edema: ",0,2);

    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("edema").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("NO",0,1);
    
    pc.addImageCols( (prop.getProperty("edema").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("SI",0,1);
    
    pc.addCols(prop.getProperty("observacion5"),0,4);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("Diuresis: ",0,2);

    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("diuresis").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Espontánea",0,1);
    
    pc.addImageCols( (prop.getProperty("diuresis").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Sonda Foley",0,1);
    
    pc.addImageCols( (prop.getProperty("diuresis").equalsIgnoreCase("OT"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Otros",0,3);
    
    pc.addCols("Específique",0,2);
    pc.addCols(prop.getProperty("observacion6"),0,8);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("Evacuación: ",0,2);

    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("evacuacion").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Normal",0,1);
    
    pc.addImageCols( (prop.getProperty("evacuacion").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Constipado",0,1);
    
    pc.addImageCols( (prop.getProperty("evacuacion").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Diarrea",0,3);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("OTRA EVALUACIÓN: ",0,2);

    pc.setFont(9,1);
    
    pc.addImageCols( (prop.getProperty("otra_evaluacion").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("NO",0,1);
    
    pc.addImageCols( (prop.getProperty("otra_evaluacion").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("SI",0,5);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.addCols(" ",0,2);
    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("otras_evaluaciones0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Mamas",0,1);
    pc.addCols(prop.getProperty("obs_otras_evaluaciones0"),0,6);
    
    pc.addCols(" ",0,2);
    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("otras_evaluaciones1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Utero",0,1);
    pc.addCols(prop.getProperty("obs_otras_evaluaciones1"),0,6);
    
    pc.addCols(" ",0,2);
    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("otras_evaluaciones2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Loquios",0,1);
    pc.addCols(prop.getProperty("obs_otras_evaluaciones2"),0,6);
    
    pc.addCols(" ",0,2);
    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("otras_evaluaciones3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Sangrado",0,1);
    pc.addCols(prop.getProperty("obs_otras_evaluaciones3"),0,6);
    
    pc.addCols(" ",0,2);
    pc.setFont(9,0);
    pc.addImageCols( (prop.getProperty("otras_evaluaciones4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Otros",0,1);
    pc.addCols(prop.getProperty("obs_otras_evaluaciones4"),0,6);

    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("Deambulación: ",0,2);

    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("deambulacion").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Independiente",0,1);
    
    pc.addImageCols( (prop.getProperty("deambulacion").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Solo en cama",0,1);
    
    pc.addImageCols( (prop.getProperty("deambulacion").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Asistida",0,1);
    
    pc.addImageCols( (prop.getProperty("deambulacion").equalsIgnoreCase("OT"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("Otros",0,1);
    
    pc.addCols("Específique", 0, 2);
    pc.addCols(prop.getProperty("observacion7"), 0, tblMain.size() - 2);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("Sondas / Cateteres: ",0,2);

    pc.setFont(9,1);
    pc.addImageCols( (prop.getProperty("sonda").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("NO",0,1);
    
    pc.addImageCols( (prop.getProperty("sonda").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("SI",0,5);
    
    pc.addCols(" ",0,2);
    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("sondas0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Periférico",0,1);
    
    pc.addImageCols( (prop.getProperty("sondas1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Epidural",0,1);
    
    pc.addImageCols( (prop.getProperty("sondas2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Nasoenteral",0,1);
    
    pc.addImageCols( (prop.getProperty("sondas3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Venoso Central",0,1);
    
    pc.addCols(" ",0,2);
    pc.addImageCols( (prop.getProperty("sondas4").equalsIgnoreCase("OT"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Otros",0,1);
    
    pc.addCols(prop.getProperty("observacion8"), 0,6);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1);
    pc.addCols("EL PLAN SELECCIONADO: ", 0,3);
    pc.addCols(condTitle, 0,tblMain.size()-3);

}
} else {

  pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1,Color.gray);
    pc.addCols("Sondas / Cateteres: ",0,2);

    pc.setFont(9,1);
    pc.addImageCols( (prop.getProperty("sonda").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("NO",0,1);
    
    pc.addImageCols( (prop.getProperty("sonda").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
    pc.addCols("SI",0,5);
    
    pc.addCols(" ",0,2);
    pc.setFont(9,0);
    
    pc.addImageCols( (prop.getProperty("sondas0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Periférico",0,1);
    
    pc.addImageCols( (prop.getProperty("sondas1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Epidural",0,1);
    
    pc.addImageCols( (prop.getProperty("sondas2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Nasoenteral",0,1);
    
    pc.addImageCols( (prop.getProperty("sondas3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Venoso Central",0,1);
    
    pc.addCols(" ",0,2);
    pc.addImageCols( (prop.getProperty("sondas4").equalsIgnoreCase("OT"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
    pc.addCols("Otros",0,1);
    
    pc.addCols(prop.getProperty("observacion8"), 0,6);
    
    pc.addCols("____________________________________________________________________________________________________________________________________",1,tblMain.size(),15f);
    
    pc.setFont(9,1);
    pc.addCols("EL PLAN SELECCIONADO: ", 0,3);
    pc.addCols(condTitle, 0,tblMain.size()-3);
}

pc.addTable();
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>