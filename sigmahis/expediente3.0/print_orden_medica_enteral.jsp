<%//@ page errorPage="../error.jsp" %>
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
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
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
String id = request.getParameter("id");
String compania = (String) session.getAttribute("_companyId");

if (fg == null) fg = "";
if (id == null) id = "0";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

sql = "select b.codigo, a.descripcion, a.status, a.presentacion, a.presentacion_desc, a.unidad_entrega, nvl(b.volumen_total, 0*20) volumen_total, round(nvl(cifra_obtenidad,  nvl(b.volumen_total, 0*20)/a.presentacion),2) as cifra_obtenida, ceil(nvl(cifra_obtenidad,  nvl(b.volumen_total, 0*20)/a.presentacion)) as cifra_redondeada, a.alerta, b.observacion, to_char(b.fecha_creacion, 'dd/mm/yyy hh12:mi:ss am') fecha_creacion, to_char(b.fecha_modificacion, 'dd/mm/yyy hh12:mi:ss am') fecha_modificacion, b.usuario_creacion, b.usuario_modificacion,case when ceil(nvl(b.cifra_obtenidad, nvl(b.volumen_total, 0)/a.presentacion)) > 4.22 and a.alerta is not null then a.alerta else ceil(nvl(b.cifra_obtenidad,  nvl(b.volumen_total, 0)/a.presentacion))||' '||a.unidad_entrega end cantidad_a_entregar, b.volumen_total/20 cant from tbl_sal_productos_nutricional a, tbl_sal_om_nutricional_enteral b where a.estado = 'A' and a.codigo = b.producto and b.pac_id = "+pacId+" and b.admision = "+noAdmision;

if (!id.equals("0")) {
    sql += " and b.codigo = "+id;
} else {
    sql += " order by b.codigo desc";
}

al = SQLMgr.getDataList(sql);
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
dHeader.addElement(".25");
dHeader.addElement(".25");
dHeader.addElement(".25");
dHeader.addElement(".25");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();

String showHeader = request.getParameter("showHeader");
if (showHeader == null) showHeader = "Y";
if (showHeader.equals("Y")){
    pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
} else {
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(desc,1,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
}

for (int i = 0; i<al.size(); i++) {
    cdo = (CommonDataObject) al.get(i);
    
    pc.setFont(10, 1);
    if (i > 0) pc.addCols(" ",0,dHeader.size());
    pc.addCols("COD.: "+cdo.getColValue("codigo","0"),0,dHeader.size(),Color.lightGray);
    
    pc.addBorderCols("F.Creación:    "+cdo.getColValue("fecha_creacion"," "),0,2);
    pc.addBorderCols("U.Creación:    "+cdo.getColValue("usuario_creacion"," "),0,2);
    pc.addBorderCols("F.Modificación:    "+cdo.getColValue("fecha_modificacion"," "),0,2);
    pc.addBorderCols("U.Modificación:    "+cdo.getColValue("usuario_modificacion"," "),0,2);
    
    pc.addCols("",0,dHeader.size(),Color.lightGray);
    
    pc.setFont(10, 1);
    pc.addBorderCols("Producto:",0,1);
    pc.setFont(10, 0);
    pc.addBorderCols(cdo.getColValue("descripcion"," "),0,dHeader.size() - 1);
    
    pc.setFont(10, 1);
    pc.addBorderCols("Indicación Médico Cant. 5x1: (c.c. o ml):",0,1);
    pc.setFont(10, 0);
    pc.addBorderCols(cdo.getColValue("cant"," "),0,dHeader.size() - 1);
    
    pc.setFont(10, 1);
    pc.addBorderCols("Volumen Total:",0,1);
    pc.setFont(10, 0);
    pc.addBorderCols(cdo.getColValue("volumen_total"," "),0,dHeader.size() - 1);
    
    pc.setFont(10, 1);
    pc.addBorderCols("Presentación:",0,1);
    pc.setFont(10, 0);
    pc.addBorderCols(cdo.getColValue("presentacion"," ")+" "+cdo.getColValue("presentacion_desc", " ").toLowerCase(),0,dHeader.size() - 1);
    
    pc.setFont(10, 1);
    pc.addBorderCols("Estado:",0,1);
    pc.setFont(10, 0);
    pc.addBorderCols(cdo.getColValue("status"," "),0,dHeader.size() - 1);
    
    pc.setFont(10, 1);
    pc.addBorderCols("Cantidad a Entregar:",0,1);
    if (Double.parseDouble(cdo.getColValue("cifra_redondeada","0")) > 4.22 && !cdo.getColValue("alerta"," ").trim().equals("")) {
        pc.setFont(10, 1,Color.red);
        pc.addBorderCols(cdo.getColValue("alerta"," "),0,dHeader.size() - 1);
    } else {
        pc.setFont(10, 0);
        pc.addBorderCols(cdo.getColValue("cifra_redondeada"," ")+" "+cdo.getColValue("unidad_entrega"," "),0,dHeader.size() - 1);
    }
    
    pc.setFont(10, 1);
    pc.addBorderCols("Cifra Obtenida:",0,1);
    pc.setFont(10, 0);
    pc.addBorderCols(cdo.getColValue("cifra_obtenida"," "),0,dHeader.size() - 1);
    
    pc.setFont(10, 1);
    pc.addBorderCols("Cifra redondeada:",0,1);
    pc.setFont(10, 0);
    pc.addBorderCols(cdo.getColValue("cifra_redondeada"," "),0,dHeader.size() - 1);
    
    pc.setFont(10, 1);
    pc.addBorderCols("Observación:",0,1);
    pc.setFont(10, 0);
    pc.addBorderCols(cdo.getColValue("observacion"," "),0,dHeader.size() - 1);
}

pc.setVAlignment(0);

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>
