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
String fechaCreacion = request.getParameter("fecha_creacion");
String usuarioCreacion = request.getParameter("usuario_creacion");

if (fg == null) fg = "SAD";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
if(code == null) code = "0";
if(fechaCreacion == null) fechaCreacion = "";
if(usuarioCreacion == null) usuarioCreacion = "";

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
boolean isLandscape = fg.trim().equalsIgnoreCase("AMBU");
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

Properties prop = SQLMgr.getDataProperties("select params from tbl_sal_ronda_multi_disci_uci where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+code);

if (prop == null) prop = new Properties();

Vector tblMain = new Vector();
tblMain.addElement("25");
tblMain.addElement("25");
tblMain.addElement("25");
tblMain.addElement("25");

pc.setNoColumnFixWidth(tblMain);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblMain.size());
pc.setTableHeader(1);

pc.setFont(9,1);

pc.addCols("Creado el: "+prop.getProperty("fecha_creacion"),0,2);
pc.addCols("Creado por: "+prop.getProperty("usuario_creacion"),0,2);

pc.addCols(" ",0,tblMain.size());
pc.setVAlignment(1);
pc.addBorderCols("NEURO:",1,1);
pc.setFont(9,0);

String params = "";

pc.setVAlignment(0);
if (prop.getProperty("params_0").equals("0")) params += "[ X ] Sedación\n";
else  params += "[    ] Sedación\n";
if (prop.getProperty("params_1").equals("1")) params += "[ X ] Manejo del dolor\n";
else params += "[    ] Manejo del dolor\n";
if (prop.getProperty("params_2").equals("2")) params += "[ X ] N/A\n";
else params +="[    ] N/A\n";

pc.addBorderCols(params,0,1);

pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("CARDIOVASCULAR (HEMODINAMICA)",1,1);
pc.setFont(9,0);

params = "Ritmo cardiaco pam: "+prop.getProperty("observacion_0")+"   mm hg\n\n";

pc.setVAlignment(0);
if (prop.getProperty("params_3").equals("3")) params += "[ X ] Vasopresor\n";
else params += "[    ] Vasopresor\n";
if (prop.getProperty("params_4").equals("4")) params += "[ X ] Antihipertensivo\n";
else  params += "[    ] Antihipertensivo\n";
if (prop.getProperty("params_5").equals("5")) params += "[ X ] N/A\n";
else params += "[    ] N/A\n";

pc.addBorderCols(params,0,1);

pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("VENTILADOR(PROGRESION, DESTETE)",1,1);
pc.setFont(9,0);

params = "";

if (prop.getProperty("params_6").equals("6")) params += "[ X ] Ventilador\n";
else  params += "[    ] Ventilador\n";
if (prop.getProperty("params_7").equals("7")) params += "[ X ] Terapia Respiratoria\n";
else  params += "[    ] Terapia Respiratoria\n";
if (prop.getProperty("params_8").equals("8")) params += "[ X ] Extubación\n";
else  params += "[    ] Extubación\n";
if (prop.getProperty("params_9").equals("9")) params += "[ X ] Cerrar Sedación\n";
else  params += "[    ] Cerrar Sedación\n";
if (prop.getProperty("params_10").equals("10")) params += "[ X ] N/A\n";
else  params += "[    ] N/A\n";

pc.addBorderCols(params,0,1);

pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("PROFILAXIS TVP",1,1);
pc.setFont(9,0);

params = "";

pc.setVAlignment(0);
if (prop.getProperty("params_11").equals("11")) params += "[ X ] Mecánico\n";
else params += "[    ] Mecánico\n";
if (prop.getProperty("params_12").equals("12")) params += "[ X ] Medicamentoso\n";
else params += "[    ] Medicamentoso\n";
if (prop.getProperty("params_13").equals("13")) params += "[ X ] N/A\n";
else params += "[    ] N/A\n";

pc.addBorderCols(params,0,1);

pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("INFECCIONES",1,1);
pc.setFont(9,0);

params = "";

pc.setVAlignment(0);
if (prop.getProperty("params_14").equals("14")) params += "[ X ] Leucocitos\n";
else params += "[    ] Leucocitos\n";
if (prop.getProperty("params_15").equals("15")) params += "[ X ] Cultivos\n";
else params += "[    ] Cultivos\n";
if (prop.getProperty("params_16").equals("16")) params += "[ X ] Biomarcadores\n";
else params += "[    ] Biomarcadores\n";
if (prop.getProperty("params_17").equals("17")) params += "[ X ] Aislamiento\n";
else params += "[    ] Aislamiento\n";

pc.addBorderCols(params,0,1);

params = "";

pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("NUTRICION Y PROFILAXIS GASTRICOS",1,1);
pc.setFont(9,0);

pc.setVAlignment(0);
if (prop.getProperty("params_18").equals("18")) params += "[ X ] Dieta vía oral\n";
else params += "[    ] Dieta vía oral\n";
if (prop.getProperty("params_19").equals("19")) params += "[ X ] NTP\n";
else params += "[    ] NTP\n";
if (prop.getProperty("params_20").equals("20")) params += "[ X ] NE x Tubo\n";
else params += "[    ] NE x Tubo\n";
if (prop.getProperty("params_21").equals("21")) params += "[ X ] NPO (Check Insulina)\n";
else params += "[    ] NPO (Check Insulina)\n";
if (prop.getProperty("params_22").equals("22")) params += "[ X ] Profilaxis Anti Ulcera\n";
else params += "[    ] Profilaxis Anti Ulcera\n";

pc.addBorderCols(params,0,1);

params = "";

pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("MOVILIZACION",1,1);
pc.setFont(9,0);

if (prop.getProperty("params_23").equals("23")) params += "[ X ] Fuera de cama\n";
else params += "[    ] Fuera de cama\n";
if (prop.getProperty("params_24").equals("24")) params += "[ X ] En cama\n";
else params += "[    ] En cama\n";
if (prop.getProperty("params_25").equals("25")) params += "[ X ] Reposo ambulatorio\n";
else params += "[    ] Reposo ambulatorio\n";

params +="\nPIEL (REQUIERE TRATAMIENTO):    ";

if (prop.getProperty("params_26").equals("26")) params += "[ X ] SI     [   ]NO";
else if (prop.getProperty("params_26").equals("27")) params += "[   ]SI     [ X ]NO";
else params +="[   ]SI     [   ]NO";

pc.setVAlignment(0);
pc.addBorderCols(params,0,1);

params = "";

pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("RENAL / FLUIDO (BALANCE HIDRICO)",1,1);
pc.setFont(9,0);

if (prop.getProperty("params_27").equals("27")) params += "[ X ] Positivo: "+prop.getProperty("observacion_1")+"\n";
else params += "[    ] Positivo\n";
if (prop.getProperty("params_28").equals("28")) params += "[ X ] Neutro: "+prop.getProperty("observacion_2")+"\n";
else params += "[    ] Neutro\n";
if (prop.getProperty("params_29").equals("29")) params += "[ X ] Negativo: "+prop.getProperty("observacion_3")+"\n";
else params += "[    ] Negativo\n";

pc.setVAlignment(0);
pc.addBorderCols(params,0,1);


params = "";
pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("CONTROL DE GLICEMIA",1,1);
pc.setFont(9,0);

if (prop.getProperty("params_30").equals("30")) params += "[ X ] SI";
else params += "\n[    ] SI";
if (prop.getProperty("params_31").equals("31")) params += "\n[ X ] Infusion Insulina";
else params += "\n[    ] Infusion Insulina";
if (prop.getProperty("params_32").equals("32")) params += "\n[ X ] N/A";
else params += "\n[    ] N/A";

pc.setVAlignment(0);
pc.addBorderCols(params,0,1);

pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("HEMATOLOGIA",1,1);
pc.setFont(9,0);

params = "Requiere Hb: "+prop.getProperty("observacion_4");
params += "\nRequiere Plaquetas: "+prop.getProperty("observacion_5");

if (prop.getProperty("params_33").equals("33")) params += "\n\n[ X ] Hemoderivados";
else params += "\n\n[    ] Hemoderivados";
if (prop.getProperty("params_34").equals("34")) params += "\n[ X ] N/A";
else params += "\n[    ] N/A";

pc.setVAlignment(0);
pc.addBorderCols(params,0,1);


params = "";
pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("MEDICAMENTOS",1,1);
pc.setFont(9,0);

if (prop.getProperty("params_36").equals("36")) params += "[ X ] Nuevos Medicamentos";
else params += "\n[    ] Nuevos Medicamentos";
if (prop.getProperty("params_37").equals("37")) params += "\n[ X ] Cambio de Antibiotico";
else params += "\n[    ] Cambio de Antibiotico";
if (prop.getProperty("params_35").equals("35")) params += "\n[ X ] Descontinuados";
else params += "\n[    ] Descontinuados";
if (prop.getProperty("params_38").equals("38")) params += "\n[ X ] N/A";
else params += "\n[    ] N/A";

pc.setVAlignment(0);
pc.addBorderCols(params,0,1);

params = "";
pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("LINEAS / TUBOS PUEDE DESCONTINUAR",1,1);
pc.setFont(9,0);

if (prop.getProperty("params_39").equals("39")) params += "[ X ] CV C";
else params += "\n[    ] CV C";
if (prop.getProperty("params_40").equals("40")) params += "\n[ X ] Sonda Foley";
else params += "\n[    ] Sonda Foley";
if (prop.getProperty("params_41").equals("41")) params += "\n[ X ] Otros: "+prop.getProperty("observacion_6");
else params += "\n[    ] Otros";

pc.setVAlignment(0);
pc.addBorderCols(params,0,1);

params = "";
pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("CODIGO",1,1);
pc.setFont(9,0);

if (prop.getProperty("params_42").equals("42")) params += "\n[ X ] RCP";
else params += "\n[    ] RCP";

if (prop.getProperty("params_43").equals("43")) params += "       [ X ] SI     [    ] NO";
else if (prop.getProperty("params_43").equals("44")) params += "       [    ] SI     [ X ] NO";
else params += "       [    ] SI     [    ] NO";


pc.setVAlignment(0);
pc.addBorderCols(params,0,1);

params = "";
pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("QUE HACER",1,1);
pc.setFont(9,0);

if (prop.getProperty("params_44").equals("45")) params += "[ X ] PROCEDIMIENTO";
else params += "[    ] PROCEDIMIENTO";
if (prop.getProperty("params_45").equals("46")) params += "\n[ X ] INTERCONSULTA";
else params += "\n[    ] INTERCONSULTA";
if (prop.getProperty("params_46").equals("47")) params += "\n[ X ] LABORATORIO";
else params += "\n[    ] LABORATORIO";
if (prop.getProperty("params_47").equals("48")) params += "\n[ X ] RX DE TORAX";
else params += "\n[    ] RX DE TORAX";
if (prop.getProperty("params_48").equals("49")) params += "\n[ X ] OTRO: "+prop.getProperty("observacion_7");
else params += "\n[    ] OTRO";

pc.setVAlignment(0);
pc.addBorderCols(params,0,1);

params = "";
pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("TIENE CRITERIO PARA SALIDA O TRASLADO",1,1);
pc.setFont(9,0);

if (prop.getProperty("params_49").equals("50")) params += "[ X ] SI     [    ] NO"; 
else if (prop.getProperty("params_49").equals("51")) params += "[    ] SI     [ X ] NO"; 
else params += "[    ] SI     [    ] NO"; 

pc.setVAlignment(0);
pc.addBorderCols(params,0,1);

params = "";
pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("LA FAMILIA VISITA AL PACIENTE",1,1);
pc.setFont(9,0);

if (prop.getProperty("params_50").equals("52")) params += "[ X ] SI     [    ] NO"; 
else if (prop.getProperty("params_50").equals("56")) params += "[    ] SI     [ X ] NO"; 
else params += "[    ] SI     [    ] NO"; 

pc.setVAlignment(0);
pc.addBorderCols(params,0,1);

params = "";
pc.setVAlignment(1);
pc.setFont(9,1);
pc.addBorderCols("OTRO ASUNTO QUE ATENDER (SALIDA)",1,1);
pc.setFont(9,0);

if (prop.getProperty("params_51").equals("53")) params += "[ X ] Social"; 
else params += "[    ] Social"; 

if (prop.getProperty("params_52").equals("54")) params += "\n[ X ] Emocional"; 
else params += "\n[    ] Emocional"; 

if (prop.getProperty("params_53").equals("55")) params += "\n[ X ] N/A"; 
else params += "\n[    ] N/A"; 

pc.addBorderCols(params,0,1);

params = "MEDICO:  "+prop.getProperty("medico_nombre");
params += "\n\nENFERMERA:  "+prop.getProperty("enfermera_nombre");
params += "\n\nTERAPISTA RESPIRATORIA:  "+prop.getProperty("terapista_nombre");
params += "\n\nFARMACIA:  "+prop.getProperty("farmacia_nombre");
params += "\n\nNUTRICION:  "+prop.getProperty("nutricion_nombre");
params += "\n\nSUPERVISOR / JEFA:  "+prop.getProperty("supervisor_nombre");
pc.addBorderCols(params,0,2);


pc.addTable();
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>