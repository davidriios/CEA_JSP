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
String fp = request.getParameter("fp");
String code = request.getParameter("code");

ArrayList al = new ArrayList();

if (fg == null) fg = "";
if (fp == null) fp = "";
if (code == null) code = "0";

if(desc == null) desc = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

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

if (desc.trim().equals("")) desc = "CRITERIOS DE LA VALORIZACIÓN DEL SULFATO DE MAGNESIO";

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
String subtitle = desc;
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

if(pc==null){
    pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
    isUnifiedExp=true;
}

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

al = SQLMgr.getDataList("select codigo, usuario_creacion, usuario_modificacion, to_char(fecha_modificacion, 'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, cefalea, fosfenos, tinitus, espigastralgia, decode(estado_conciencia,'D','DESPIERTO','S','SEDADO','O','ORIENTADO','Z','OTROS') estado_conciencia, decode(reflejos_rot,'S','SI','N','NO') reflejos_rot, observacion,  p_a, tmp as temp, f_c, f_r, f_c_f, orina from tbl_sal_val_criterios_sulfa_mg where pac_id = "+pacId+" and admision = "+noAdmision+(!code.equals("0")?" and codigo = "+code:"")+" order by codigo desc");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

for (int i = 0; i < al.size(); i++) {
    cdo = (CommonDataObject) al.get(i);
    
    if (i>0) {
        pc.addCols(" ",1,dHeader.size());
        pc.addCols(" *** ",1,dHeader.size());
        pc.addCols(" ",1,dHeader.size());
    }
    
    pc.setFont(10,1);
    pc.addCols("Fecha creación: "+cdo.getColValue("fecha_creacion"," "),0,5);
    pc.addCols("Creado por: "+cdo.getColValue("usuario_creacion"," "),0,5);
    pc.addCols("Fecha modificación: "+cdo.getColValue("fecha_modificacion"," "),0,5);
    pc.addCols("Modificaco por: "+cdo.getColValue("usuario_modificacion"," "),0,5);
    
    pc.setFont(9,1);
    pc.addBorderCols("P/A:",0,1);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("p_a"),0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols("F.C:   "+cdo.getColValue("f_c"," "),0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols("F.R:   "+cdo.getColValue("f_r"," "),0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols("Temp.",0,1);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("temp"),0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols("F.C.F",0,1);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("f_c_f"),0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols("Orina",0,1);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("orina"),0,1);
    
    
    pc.setFont(9,1);
    pc.addBorderCols("Cefalea:",0,1);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("cefalea"),0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols("Fosfenos:",0,1);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("fosfenos"),0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols("Tinitus:",0,1);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("tinitus"),0,1);
        
    pc.setFont(9,1);
    pc.addBorderCols("Reflejos ROT:",0,2);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("reflejos_rot"),0,1);
    pc.addBorderCols("",0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols("Espigastralgia:",0,2);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("espigastralgia"),0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols("Estado Conciencia:",0,2);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("estado_conciencia"),0,4);
    pc.addBorderCols("",0,1);
    
    pc.setFont(9,1);
    pc.addBorderCols("Observación",0,1);
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("observacion"),0,9);
    
}

pc.addTable();
if(isUnifiedExp){
pc.close();
response.sendRedirect(redirectFile);}
%>