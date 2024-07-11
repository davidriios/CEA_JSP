<%// @ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
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
dHeader.addElement("12"); 
dHeader.addElement("8");
dHeader.addElement("10"); 
dHeader.addElement("10");
dHeader.addElement("12"); 
dHeader.addElement("8");
dHeader.addElement("10"); 
dHeader.addElement("10");
dHeader.addElement("10");
dHeader.addElement("10");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();

String showHeader = request.getParameter("showHeader");
if (showHeader == null) showHeader = "Y";
if (showHeader.equals("Y")){
    pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
} else {
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(desc,1,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
}

al = SQLMgr.getDataList("select observacion, diag, diag_desc, presentacion, dilatacion,borramiento, estacion, variedad_posicion, decode(membranas,'R','ROTAS','I','INTEGRAS') membranas, decode(liquido,'C','CLARO','MECONIAL') liquido, USUARIO_CREACion, to_char(FECHA_CREACion,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREACion, USUARIO_MODIFicacion, to_char(FECHA_MODIFicacion,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIFicacion, tiempo_ruptura from tbl_sal_eval_obstetrica_parto where pac_id = "+pacId+" and admision = "+noAdmision+(!code.trim().equals("0")?" and codigo = "+code:"")+" order by codigo desc");

for (int i = 0; i < al.size();  i++) {
    cdo = (CommonDataObject) al.get(i);
    if (i > 0) {
        pc.addCols(" ",1,dHeader.size());
        pc.addCols("************************************************************************************************************",1,dHeader.size());
        pc.addCols(" ",1,dHeader.size());
    }
    
    pc.setFont(10,1);
    pc.addBorderCols("Fecha creación:   "+cdo.getColValue("fecha_creacion"," "),0,5);
    pc.addBorderCols("Creado por:   "+cdo.getColValue("usuario_creacion"," "),0,5);
   
    pc.setFont(10,1);
    pc.addBorderCols("Presentación:",0,1);
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("presentacion"),0,1);
    
    pc.setFont(10,1);
    pc.addBorderCols("Dilatación:",0,1);
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("dilatacion"),0,1);
    
    pc.setFont(10,1);
    pc.addBorderCols("Borramiento:",0,1);
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("Borramiento"),0,1);
    
    pc.setFont(10,1);
    pc.addBorderCols("Estación:",0,1);
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("estacion"),0,1);
    pc.addBorderCols(" ", 0, 2);
    
    pc.setFont(10,1);
    pc.addBorderCols("Variedad de Posición:", 0, 2);
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("variedad_posicion"),0,dHeader.size() - 2);
    
    pc.setFont(10,1);
    pc.addBorderCols("Membranas:", 0, 2);
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("membranas"),0,2);
    
    pc.setFont(10,1);
    pc.addBorderCols("Tiempo de Ruptura:", 0, 1);
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("tiempo_ruptura"),0,1);
    
    pc.setFont(10,1);
    pc.addBorderCols("Líquido:", 0, 1);
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("liquido"),0,3);
    
    /*pc.setFont(10,1);
    pc.addBorderCols("Diagnóstico:", 0, 2);
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("diag_desc"),0,dHeader.size() - 2);*/
    
    pc.setFont(10,1);
    pc.addBorderCols("Plan de Manejo:", 0, 2);
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("observacion"),0,dHeader.size() - 2);
}

pc.addTable();
if(isUnifiedExp){
pc.close();
response.sendRedirect(redirectFile);}
%>