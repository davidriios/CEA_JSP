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
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String codigo = request.getParameter("codigo");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
cdoUsr.addColValue("usuario",userName);

if(desc == null) desc = "";
if (codigo == null) codigo = "0";

prop = SQLMgr.getDataProperties("select params from tbl_sal_resureccion_cardio where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+codigo+" and tipo = '"+fg+"'");

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
   
cdo = SQLMgr.getData("select to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, to_char(fecha_modificacion, 'dd/mm/yyyy hh24:mi') fm, usuario_creacion, usuario_modificacion from tbl_sal_resureccion_cardio where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+codigo+" and tipo = '"+fg+"'");

if (cdo == null) cdo = new CommonDataObject();

pc.setFont(9,0);

pc.addCols("Fecha: ",0,1);
pc.addCols(cdo.getColValue("fc"),0,3);
pc.addCols("Usuario: ",2,3);
pc.addCols(cdo.getColValue("usuario_creacion"),0,3);

pc.addBorderCols("Lugar del Evento: "+prop.getProperty("lugar_evento"),0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);

pc.addCols(" ",1,dHeader.size());

pc.setFont(9,1);
pc.addBorderCols("HORA",1,1);
pc.addBorderCols("RECONOCIMIENTO DEL EVENTO",0,5);
pc.addBorderCols("PARÁMETROS",0,4);

pc.setFont(9,0);

pc.addBorderCols(prop.getProperty("fecha_0"),1,1);
pc.addBorderCols("¿SE IDENFICÓ EL EVENTO?",0,5);
if(prop.getProperty("params_0").equals("1"))
    pc.addBorderCols("[ X ] SI                [   ] NO",0,4);
else if(prop.getProperty("params_0").equals("0")) pc.addBorderCols("[    ] SI       [ X ] NO",0,4);
else pc.addBorderCols("[    ] SI       [    ] NO",0,4);

pc.addBorderCols(prop.getProperty("fecha_1"),1,1);
pc.addBorderCols("¿ESTABA EL PACIENTE CONCIENTE CUANDO SE LLAMÓ AL CÓDIGO?",0,5);
if(prop.getProperty("params_1").equals("1"))
    pc.addBorderCols("[ X ] SI                [   ] NO",0,4);
else if(prop.getProperty("params_1").equals("0")) pc.addBorderCols("[    ] SI       [ X ] NO",0,4);
else pc.addBorderCols("[    ] SI       [    ] NO",0,4);

pc.addBorderCols(prop.getProperty("fecha_2"),1,1);
pc.addBorderCols("¿SE ACTIVÓ EL EQUIPO DEL CÓDIGO?",0,5);
if(prop.getProperty("params_2").equals("1"))
    pc.addBorderCols("[ X ] SI                [   ] NO",0,4);
else if(prop.getProperty("params_1").equals("0")) pc.addBorderCols("[    ] SI       [ X ] NO",0,4);   
else pc.addBorderCols("[    ] SI       [    ] NO",0,4);

String param3 = "";
if(prop.getProperty("params_3_0").equals("0")) param3 += "[ X ] Espontánea";
else  param3 += "[   ] Espontánea";
if(prop.getProperty("params_3_1").equals("1")) param3 += "     [ X ] Apnea";
else  param3 += "     [   ] Apnea";
if(prop.getProperty("params_3_2").equals("2")) param3 += "     [ X ] Asistida";
else  param3 += "     [   ] Asistida";
if(prop.getProperty("params_3_3").equalsIgnoreCase("OT")) param3 += "     [ X ] Otras\n\n"+prop.getProperty("observacion0");
else  param3 += "     [   ] Otras";

pc.addBorderCols(prop.getProperty("fecha_3"),1,1);
pc.addBorderCols("¿CÓMO ESTABA LA VÍA AÉREA ANTES DEL EVENTO?",0,5);
pc.addBorderCols(param3,0,4);

String param4 = "";
if(prop.getProperty("params_4_0").equals("0")) param4 += "[ X ] Ambú";
else  param4 += "[   ] Ambú";
if(prop.getProperty("params_4_1").equals("1")) param4 += "     [ X ] Tubo ET";
else  param4 += "     [   ] Tubo ET";
if(prop.getProperty("params_4_2").equals("2")) param4 += "     [ X ] Traqueostomía";
else  param4 += "     [   ] Traqueostomía";
if(prop.getProperty("params_4_3").equalsIgnoreCase("OT")) param4 += "     [ X ] Otras\n\n"+prop.getProperty("observacion1");
else  param4 += "     [   ] Otras";

pc.addBorderCols(prop.getProperty("fecha_4"),1,1);
pc.addBorderCols("TIPO DE VENTILACIÓN",0,5);
pc.addBorderCols(param4,0,4);

pc.addBorderCols(prop.getProperty("fecha_5"),1,1);
pc.addBorderCols("INFORMACIÓN DE ENTUBACIÓN ENDOTRAQUEAL",0,5);
pc.addBorderCols("# de Tubo: "+prop.getProperty("observacion2"," ")+"\nColocado por: "+prop.getProperty("observacion3"," "),0,4);

pc.addBorderCols(prop.getProperty("fecha_2"),1,1);
pc.addBorderCols("INICIO DE COMPRESIONES",0,5);
if(prop.getProperty("params_6").equals("1"))
    pc.addBorderCols("[ X ] SI                [   ] NO\n\n"+prop.getProperty("observacion4"),0,4);
else if(prop.getProperty("params_6").equals("0")) pc.addBorderCols("[    ] SI       [ X ] NO",0,4);   
else pc.addBorderCols("[    ] SI       [    ] NO",0,4);

String desfri = "", ritmoCard = "";
if(prop.getProperty("params_8").equals("0")) desfri += "[ X ] Monofásica     [   ] Bifásica";
else if(prop.getProperty("params_8").equals("1")) desfri += "[   ] Monofásica     [ X ] Bifásica";
else  desfri += "[   ] Monofásica     [   ] Bifásica";

if(prop.getProperty("params_9_0").equals("0")) ritmoCard += "[ X ] VF";
else  ritmoCard += "[   ] VF";
if(prop.getProperty("params_9_1").equals("1")) ritmoCard += "     [ X ] VT";
else  ritmoCard += "     [   ] VT";
if(prop.getProperty("params_9_2").equals("2")) ritmoCard += "     [ X ] Bradicardia";
else  ritmoCard += "     [   ] Bradicardia";
ritmoCard += "\n\nOtro: "+prop.getProperty("observacion5");

pc.addBorderCols(prop.getProperty("fecha_7"),1,1);
pc.addBorderCols("¿SE APLICÓ DESFIBRILACIÓN AL PACIENTE?",0,5);
if(prop.getProperty("params_7").equals("1"))
    pc.addBorderCols("[ X ] SI                [   ] NO\n\nTipo de desfibrilación:  "+desfri+"\n\nRitmo cardíaco:  "+ritmoCard,0,4);
else if(prop.getProperty("params_7").equals("0")) pc.addBorderCols("[    ] SI       [ X ] NO",0,4);   
else pc.addBorderCols("[    ] SI       [    ] NO",0,4);

pc.addCols(" ",0,dHeader.size());

ArrayList alMed = SQLMgr.getDataList("select codigo, descripcion from tbl_sal_med_resucitacion where estado = 'A' order by 1");

pc.setFont(9,1);
pc.addCols("MEDICAMENTOS ADMINISTRADOS",0,dHeader.size());

pc.addBorderCols("Medicamentos Vía - Dosis",0,3);
pc.addBorderCols("Hora",1,1);
pc.addBorderCols("FR",1,1);
pc.addBorderCols("FC",1,1);
pc.addBorderCols("PA",1,1);
pc.addBorderCols("SPO2",1,1);
pc.addBorderCols("Observación",2,2);

pc.setFont(9,0);
for (int m = 0; m < alMed.size(); m++){
    CommonDataObject cdoM = (CommonDataObject) alMed.get(m);
    
    pc.addBorderCols(cdoM.getColValue("descripcion"),0,3);
    pc.addBorderCols(prop.getProperty("fecha_med_"+m),1,1);
    pc.addBorderCols(prop.getProperty("fr_"+m),1,1);
    pc.addBorderCols(prop.getProperty("fc_"+m),1,1);
    pc.addBorderCols(prop.getProperty("pa_"+m),1,1);
    pc.addBorderCols(prop.getProperty("spo2_"+m),1,1);
    pc.addBorderCols(prop.getProperty("obs_medicamentos"+m),2,2);
}







pc.addTable();
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>