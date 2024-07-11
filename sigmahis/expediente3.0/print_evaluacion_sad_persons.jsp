<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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

StringBuffer sbSql = new StringBuffer();
sbSql.append("select a.codigo, a.descripcion, decode(b.cod_eval,null,'I','U') as action, b.valor, b.observacion from tbl_sal_sad_persons a, tbl_sal_escala_sad_persons b where a.estado = 'A' and a.tipo = '"+fg+"' and a.codigo = b.cod_eval(+) and b.pac_id(+) = ");
sbSql.append(pacId);
sbSql.append(" and b.admision(+) = ");
sbSql.append(noAdmision);
sbSql.append(" and b.codigo(+) = ");
sbSql.append(code);
sbSql.append(" order by a.codigo");
ArrayList al = SQLMgr.getDataList(sbSql.toString());

Vector tblMain = new Vector();
if(fg.trim().equalsIgnoreCase("AMBU")){
 tblMain.addElement("60");
} else {
    tblMain.addElement("94");
}
tblMain.addElement("03");
tblMain.addElement("03");

if(fg.trim().equalsIgnoreCase("AMBU")){
 tblMain.addElement("34");
}

pc.setNoColumnFixWidth(tblMain);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblMain.size());
pc.setTableHeader(1);

if(fg.trim().equalsIgnoreCase("AMBU")){
    CommonDataObject cdoA = SQLMgr.getData("select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, paramedico, destino, medico_acompanante, tipo_ambulancia, proveedor, medico_verificador, (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = medico_verificador and estado = 'A' and rownum = 1) medico_verificador_nombre, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fc, usuario_creacion from tbl_sal_calidad_ambulancia where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'AMBU' and codigo = "+code);
    if (cdoA == null) cdoA = new CommonDataObject();
    
    pc.setFont(9, 1);
    
    pc.addCols("Creado el: "+cdoA.getColValue("fc"," ")+"            por: "+cdoA.getColValue("usuario_creacion"," "),0,tblMain.size());
    
    pc.addCols(" ", 0, tblMain.size());
    pc.addCols("Fecha Traslado: "+cdoA.getColValue("fecha"," "),0,2);
    pc.addCols("Paramédico: "+cdoA.getColValue("paramedico"," "),0,2);
    pc.addCols("Destino: "+cdoA.getColValue("destino"," "),0,2);
    pc.addCols("Médico que acompaña al traslado: "+cdoA.getColValue("medico_acompanante"," "),0,2);
    pc.addCols("Tipo Ambulancia: "+cdoA.getColValue("tipo_ambulancia"," "),0,2);
    pc.addCols("Proveedor: "+cdoA.getColValue("proveedor"," "),0,2);
    
    pc.addCols("Verificado por Médico ER: [ "+cdoA.getColValue("medico_verificador"," ")+" ]   "+cdoA.getColValue("medico_verificador_nombre"," "),0,tblMain.size());
    
    pc.addCols(" ", 0, tblMain.size());
} else {
    pc.setFont(9, 1);
    pc.addCols("Creado el: "+fechaCreacion+"            por: "+usuarioCreacion,0,tblMain.size());
    pc.addCols(" ",0,tblMain.size());
}

String descripcion = "SINTOMAS";
if(fg.trim().equalsIgnoreCase("AMBU")) descripcion = "PARAMETROS";

pc.setFont(9, 1);
pc.addBorderCols(descripcion,0,1);
pc.addBorderCols("SI",1,1);
pc.addBorderCols("NO",1,1);

if(fg.trim().equalsIgnoreCase("AMBU")){
    pc.addBorderCols("OBSERVACION",1,1);   
}
int tot = 0;
pc.setFont(9, 0);
for (int i = 0; i<al.size(); i++){
  cdo = (CommonDataObject) al.get(i);
  pc.addBorderCols(cdo.getColValue("descripcion"),0,1);
  
  pc.addImageCols( (cdo.getColValue("valor") != null && cdo.getColValue("valor").equals("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",1,1);
  
  pc.addImageCols( (cdo.getColValue("valor") != null && cdo.getColValue("valor").equals("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",1,1);
  
  if(fg.trim().equalsIgnoreCase("AMBU")){
    pc.addBorderCols(cdo.getColValue("observacion"),0,1);
    }
     
    if (cdo.getColValue("valor") != null && cdo.getColValue("valor").equals("1")) tot++;
  
}
if(fg.trim().equalsIgnoreCase("SAD")){
  pc.setFont(9, 1);
  pc.addCols("Puntuación: "+tot,0,tblMain.size());
  
  if (tot <= 2) pc.addCols("Alta medica al domicilio con seguimiento ambulatorio",0,tblMain.size());
  else if (tot > 2 && tot <= 4) pc.addCols("Segumiento ambulatorio intensivo, considerar ingreso",0,tblMain.size());
  else if (tot > 4 && tot <= 6) pc.addCols("Recomendado ingreso sobre todo si hay ausencia de apoyo social",0,tblMain.size());
  else if (tot > 6 && tot <= 10) pc.addCols("Ingreso obligatorio incluso en contra de su voluntad",0,tblMain.size());
  
}

pc.addTable();
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>