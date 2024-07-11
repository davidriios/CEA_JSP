<%//@ page errorPage="../error.jsp" %>
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
<%@ include file="../common/pdf_header.jsp"%>

<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo, cdoPacData = new CommonDataObject();
String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String codigo = request.getParameter("codigo");
String compania = (String) session.getAttribute("_companyId");

if (fg == null) fg = "";
if (codigo == null) codigo = "0";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

Properties prop = SQLMgr.getDataProperties("select antecedentes from tbl_sal_ant_perinatales where pac_id="+pacId+" and admision = "+noAdmision);
if (prop == null) prop = new Properties();
	
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

float width = 82 * 8.5f;//612 
float height = 62 * 14f;//792
boolean isLandscape = false;
float leftRightMargin = 35.0f;
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
    cdoPacData.addColValue("is_landscape",""+isLandscape);
}
	
PdfCreator pc = null;
boolean isUnifiedExp = false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){
    pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
    isUnifiedExp=true;
}

Vector dHeader = new Vector();
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".10");
		
pc.setNoColumnFixWidth(dHeader);
pc.createTable();

pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
pc.setVAlignment(0);

pc.setFont(9, 1);
pc.addCols("Creado por:", 0, 1);
pc.addCols(prop.getProperty("usuario_creacion"), 0, 1);

pc.addCols("Creado el:", 2, 1);
pc.addCols(prop.getProperty("fecha_creacion"), 0, 2);

pc.addCols("Modif. por:", 0, 1);
pc.addCols(prop.getProperty("usuario_modificacion"), 0, 1);

pc.addCols("Modif. el:", 2, 1);
pc.addCols(prop.getProperty("fecha_modificacion"), 0, 2);

pc.addCols(" ", 0, dHeader.size());

pc.setFont(8, 1);
pc.addCols("DATOS MATERNOS DEL PACIENTE PEDIÁTRICO", 0, dHeader.size());

pc.setFont(8, 0);
pc.addCols("G-Grava:", 0, 1);
pc.addCols(prop.getProperty("observacion11"), 0, 1);
pc.addCols("P-Para:", 0, 1);
pc.addCols(prop.getProperty("observacion12"), 0, 1);
pc.addCols("C-Cesarea:", 0, 1);
pc.addCols(prop.getProperty("observacion13"), 0, 1);
pc.addCols("A-Aborto:", 0, 1);
pc.addCols(prop.getProperty("observacion14"), 0, 1);
pc.addCols("", 0, 2);

pc.addCols(" ", 0, dHeader.size());
pc.setFont(8, 1);
pc.addCols("DATOS DEL NACIMIENTO DEL PACIENTE PEDIATRICO", 0, dHeader.size());
pc.setFont(8, 0);

if (prop.getProperty("parto")!=null&&prop.getProperty("parto").equalsIgnoreCase("PV")) {
  pc.addBorderCols("Parto Vaginal: ", 0, 1);
  pc.addBorderCols(prop.getProperty("observacion0"), 0, dHeader.size()-1);
} else if (prop.getProperty("parto")!=null&&prop.getProperty("parto").equalsIgnoreCase("PC")) {
  pc.addBorderCols("Parto Cesárea: ", 0, 1);
  pc.addBorderCols(prop.getProperty("observacion1"), 0, dHeader.size()-1);
}

pc.addBorderCols("Edad Gestacional al nacer (semanas):", 0, 3);
pc.addBorderCols(prop.getProperty("observacion21"), 0, dHeader.size() - 3);

pc.addBorderCols("Peso al nacer:", 0, 2);
pc.addBorderCols(prop.getProperty("observacion2"), 0, dHeader.size() - 2);
pc.addBorderCols("Tall al nacer:", 0, 2);
pc.addBorderCols(prop.getProperty("observacion3"), 0, dHeader.size() - 2);
pc.addBorderCols("Perímetro cefálico:", 0, 2);
pc.addBorderCols(prop.getProperty("observacion4"), 0, dHeader.size() - 2);
pc.addBorderCols("Perímetro torácico:", 0, 2);
pc.addBorderCols(prop.getProperty("observacion5"), 0, dHeader.size() - 2);
pc.addBorderCols("Condición al nacer:", 0, 2);
pc.addBorderCols(prop.getProperty("observacion6"), 0, dHeader.size() - 2);

pc.addBorderCols("APGAR:", 0, 1);
pc.addBorderCols(prop.getProperty("observacion7"), 1, 1);
pc.addBorderCols("Detallar:", 1, 1);
pc.addBorderCols(prop.getProperty("observacion8"), 0, dHeader.size() - 3);

pc.addCols("", 0, dHeader.size());

pc.setFont(8, 1);
pc.addCols("REANIMADO", 0, dHeader.size());
pc.setFont(8, 0);

pc.addBorderCols(prop.getProperty("reanimado").equals("0") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("No require", 0, dHeader.size() - 1);
pc.addBorderCols(prop.getProperty("reanimado").equals("1") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("Máscara simple", 0, dHeader.size() - 1);
pc.addBorderCols(prop.getProperty("reanimado").equals("2") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("Máscara de Presión Positiva", 0, dHeader.size() - 1);
pc.addBorderCols(prop.getProperty("reanimado").equals("3") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("Intubación endotraqueal", 0, dHeader.size() - 1);
pc.addBorderCols(prop.getProperty("reanimado").equals("4") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("CPAP", 0, dHeader.size() - 1);

pc.addBorderCols(prop.getProperty("reanimado").equals("OT") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("Otros", 0, 1);
pc.addBorderCols(prop.getProperty("observacion9"), 0, dHeader.size() - 2);

if (prop.getProperty("complicaion")!=null&&prop.getProperty("complicaion").equalsIgnoreCase("0")) {
  pc.setFont(8, 1);
  pc.addCols(" ", 0, dHeader.size());
  pc.addCols("Complicaciones al nacer:", 0, 2);  
  pc.addCols("NINGUNA", 0, dHeader.size()-2);
  
} else if (prop.getProperty("complicaion")!=null&&prop.getProperty("complicaion").equalsIgnoreCase("1")) {
  pc.setFont(8, 1);
  pc.addCols(" ", 0, dHeader.size());
  pc.addCols("Complicaciones al nacer:", 0, 2);  
  pc.addCols("SI", 1, 1);
  pc.addCols(prop.getProperty("observacion10"), 0, dHeader.size() - 3);
}


pc.addCols(" ", 0, dHeader.size());
pc.setFont(8, 1);
pc.addCols("DATOS DEL DESARROLLO DEL PACIENTE PEDIATRICO", 0, dHeader.size());
pc.setFont(8, 0);

pc.addBorderCols("Sostén Cefálico (meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion15"), 0, dHeader.size() - 2);

pc.addBorderCols("Primer Diente (meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion16"), 0, dHeader.size() - 2);

pc.addBorderCols("Se sentó (meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion17"), 0, dHeader.size() - 2);

pc.addBorderCols("Primeras Palabras (meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion18"), 0, dHeader.size() - 2);

pc.addBorderCols("Caminó (meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion19"), 0, dHeader.size() - 2);

pc.addBorderCols("Control de esfínteres(meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion20"), 0, dHeader.size() - 2);

pc.addCols(" ", 0, dHeader.size());
pc.setFont(8, 1);
pc.addCols("ALIMENTACIÓN", 0, dHeader.size());
pc.setFont(8, 0);

if (prop.getProperty("pecho")!=null&&prop.getProperty("pecho").equalsIgnoreCase("0")) {
  pc.setFont(8, 1);
  pc.addBorderCols("PECHO", 0, dHeader.size());
  
} else if (prop.getProperty("pecho")!=null&&prop.getProperty("pecho").equalsIgnoreCase("1")) {
  pc.setFont(8, 1);
  pc.addBorderCols("PECHO + FORMULA", 0, dHeader.size());
}


pc.setFont(8, 1);
pc.addBorderCols("Diestas suaves:", 0, 2);
pc.setFont(8, 0);
pc.addBorderCols(prop.getProperty("observacion22"), 0, dHeader.size() - 2);

pc.setFont(8, 1);
pc.addBorderCols("Dieta actual:", 0, 2);
pc.setFont(8, 0);
pc.addBorderCols(prop.getProperty("observacion23"), 0, dHeader.size() - 2);

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);
}
%>
