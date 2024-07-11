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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
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
String code = request.getParameter("code");

ArrayList al = new ArrayList();

if (fg == null) fg = "";
if (fp == null) fp = "";
if (code == null) code = "0";

if(desc == null) desc = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

prop = SQLMgr.getDataProperties("select protocolo from tbl_sal_protocolo_cesarea where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+code);

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
float leftRightMargin = 15.0f;
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

cdo = SQLMgr.getData("select codigo, usuario_creacion, usuario_modificacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fc, to_char(fecha_creacion,'hh12:mi:ss am') hc, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fm, to_char(fecha_modificacion,'hh12:mi:ss am') hm from tbl_sal_protocolo_cesarea where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+code);

if (cdo == null) {
    cdo = new CommonDataObject();
}

pc.setNoColumnFixWidth(dHeader);
pc.createTable();
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

pc.setFont(10,1);
pc.addCols("Fecha creación: "+cdo.getColValue("fc"," "),0,5);
pc.addCols("Creado por: "+cdo.getColValue("usuario_creacion"," "),0,5);
pc.addCols("Fecha modificación: "+cdo.getColValue("fm"," "),0,5);
pc.addCols("Modificaco por: "+cdo.getColValue("usuario_modificacion"," "),0,5);

pc.addCols(" ", 0, dHeader.size());
pc.addCols("PERSONALES PARTICIPANTES", 0, dHeader.size(),Color.lightGray);

pc.setFont(9,1);
pc.addBorderCols("Cirujano",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("cirujano_nombre"),0,4);
pc.setFont(9,1);
pc.addBorderCols("Anestesiólogo",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("anestesiologo_nombre"," "),0,4);

pc.setFont(9,1);
pc.addBorderCols("Intrumentador",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("instrumentador_nombre"),0,4);
pc.setFont(9,1);
pc.addBorderCols("Circulador",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("circulador_nombre"," "),0,4);

pc.setFont(9,1);
pc.addBorderCols("Pediatra",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("pediatra_nombre"),0,9);

sql="select  a.codigo, a.emp_id, nvl(a.nombre_emp, (select h.primer_nombre || ' ' || h.primer_apellido from tbl_pla_empleado h where a.emp_id = h.emp_id and rownum = 1) ) nombre_emp from tbl_sal_asistentes_proto_cesar a where a.cod_protocolo = "+code+" and a.pac_id = "+pacId+" and admision = "+noAdmision+" order by a.codigo desc ";
al = SQLMgr.getDataList(sql);

pc.setFont(9,1);
pc.addBorderCols(" *** ASISTENTES ***", 1, dHeader.size());
pc.addBorderCols("CODIGO", 0, 1);
pc.addBorderCols("NOMBRE", 0, dHeader.size() - 1);
pc.setFont(9,0);

for (int i = 0; i < al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    pc.addBorderCols(cdo.getColValue("emp_id"), 0, 1);
    pc.addBorderCols(cdo.getColValue("nombre_emp"), 0, dHeader.size() - 1);
}

pc.setFont(9,1);
pc.addCols(" ", 0, dHeader.size());
pc.addCols("DIAGNOSTICOS PRE-OPERATORIO", 0, dHeader.size(),Color.lightGray);

sql = "select  a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiagPre ,a.observacion from tbl_sal_diag_protocolo_cesarea  a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PR' and a.cod_informe = "+code+" and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by a.codigo desc";
al = SQLMgr.getDataList(sql);

pc.addBorderCols("CÓDIGO",0,1);
pc.addBorderCols("DESCRIPCIÓN",0,6);
pc.addBorderCols("OBSERVACIÓN",0,3);

pc.setFont(9,0);
for (int i = 0; i < al.size(); i++) {
    cdo = (CommonDataObject) al.get(i);
    pc.addBorderCols(cdo.getColValue("diagnostico"),0,1);
    pc.addBorderCols(cdo.getColValue("descDiagPre"),0,6);
    pc.addBorderCols(cdo.getColValue("observacion"),0,3);
}

pc.setFont(9,1);
pc.addCols(" ", 0, dHeader.size());
pc.addCols("DIAGNOSTICOS POST-OPERATORIO", 0, dHeader.size(),Color.lightGray);

sql = "select a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiagPost,a.observacion from tbl_sal_diag_protocolo_cesarea  a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PO' and a.cod_informe = "+code+" and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by a.codigo desc";
al = SQLMgr.getDataList(sql);

pc.addBorderCols("CÓDIGO",0,1);
pc.addBorderCols("DESCRIPCIÓN",0,6);
pc.addBorderCols("OBSERVACIÓN",0,3);

pc.setFont(9,0);
for (int i = 0; i < al.size(); i++) {
    cdo = (CommonDataObject) al.get(i);
    pc.addBorderCols(cdo.getColValue("diagnostico"),0,1);
    pc.addBorderCols(cdo.getColValue("descDiagPost"),0,6);
    pc.addBorderCols(cdo.getColValue("observacion"),0,3);
}

pc.setFont(9,1);
pc.addCols(" ", 0, dHeader.size());
pc.addCols("PROCEDIMIENTO / OPERACIÓN", 0, dHeader.size(),Color.lightGray);

sql = "select  a.codigo,a.procedimiento,decode(h.observacion , null , h.descripcion,h.observacion)descProc from tbl_sal_proc_protocolo_cesarea a,tbl_cds_procedimiento h where  a.procedimiento = h.codigo and a.cod_protocolo = "+code+" and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by a.codigo desc ";
al = SQLMgr.getDataList(sql);

pc.addBorderCols("CÓDIGO",0,1);
pc.addBorderCols("PROCEDIMIENTO",0,9);

pc.setFont(9,0);
for (int i = 0; i < al.size(); i++) {
    cdo = (CommonDataObject) al.get(i);
    pc.addBorderCols(cdo.getColValue("procedimiento"),0,1);
    pc.addBorderCols(cdo.getColValue("descProc"),0,9);
}


pc.setFont(9,1);
pc.addCols(" ", 0, dHeader.size());
pc.addCols("GENERALES", 0, dHeader.size(),Color.lightGray);

pc.setFont(9,1);
pc.addBorderCols("Cirugía:",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("fecha_cirugia"),0,2);

pc.setFont(9,1);
pc.addBorderCols("Inicia:",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("fecha_inicio"),0,2);

pc.setFont(9,1);
pc.addBorderCols("Termina:",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("fecha_fin"),0,3);

pc.setFont(9,1);
pc.addCols("HALLAZGO", 0, dHeader.size());

pc.addBorderCols("F.Nac.:",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("hora_nacimiento"),0,2);

pc.setFont(9,1);
pc.addBorderCols("Sexo:",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("sexo"),0,1);

pc.setFont(9,1);
pc.addBorderCols("APGAR:",0,1);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("apgar"),0,1);

pc.setFont(9,1);
pc.addBorderCols("APGAR 5 minutos:",0,2);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("apgar_cinco"),0,1);

pc.setFont(9,1);
pc.addBorderCols("Peso: "+prop.getProperty("peso")+"     kg",0,1);

pc.setFont(9,1);
pc.addBorderCols("Presentación:",0,2);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("presentacion"),0,4);

pc.setFont(9,1);
pc.addBorderCols("Edad Gestacional:",0,2);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("edad_gestacional"),0,1);

pc.setFont(9,1);
pc.addCols(" ", 0, dHeader.size());
pc.addCols("PROTOCOLO OPERATORIO", 0, dHeader.size(),Color.lightGray);

pc.setFont(9,1);
pc.addBorderCols("Tipo de insición en la piel:",0,2);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("tipo_insicion_piel"),0,8);

pc.setFont(9,1);
pc.addBorderCols("Tipo de insición en útero:",0,2);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("tipo_insicion_utero"),0,8);

String membrana = "";

if (prop.getProperty("membrana").equalsIgnoreCase("I")) membrana += "[ X ] Íntegras           [  ] Rotas";
else if (prop.getProperty("membrana").equalsIgnoreCase("R")) membrana += "[   ] Íntegras           [ X ] Rotas          ("+prop.getProperty("tiempo_ruptura")+"    horas)";
else membrana += "[   ] Íntegras           [   ] Rotas";

pc.setFont(9,1);
pc.addBorderCols("Membranas:",0,2);
pc.setFont(9,0);
pc.addBorderCols(membrana,0,8);

pc.setFont(9,1);
pc.addBorderCols("Liquido amniótico:",0,2);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("liquido_amniotico"),0,8);

pc.setFont(9,1);
pc.addBorderCols("Placenta:",0,2);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("placenta"),0,8);

pc.setFont(9,1);
pc.addCols(" ", 0, dHeader.size());
pc.addCols("OTRAS INFORMACIONES", 0, dHeader.size(),Color.lightGray);

pc.setFont(9,1);
pc.addBorderCols("Drenajes:",0,2);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("drenajes"),0,8);

pc.setFont(9,1);
pc.addBorderCols("Complicaciones peri operatorias:",0,2);
pc.setFont(9,0);
pc.addBorderCols(prop.getProperty("complicaciones_peri_op"),0,8);

String muestra = "";

if (prop.getProperty("muestras_histopato").equalsIgnoreCase("N")) muestra += "[ X ] NO           [  ] SI";
else if (prop.getProperty("muestras_histopato").equalsIgnoreCase("S")) muestra += "[   ] NO           [ X ] SI          ("+prop.getProperty("total_muestras")+"    muestras)";
else muestra += "[   ] NO           [   ] SI";

pc.setFont(9,1);
pc.addBorderCols("Número de muestras histopatológicas:",0,4);
pc.setFont(9,0);
pc.addBorderCols(muestra,0,6);

pc.addTable();
if(isUnifiedExp){
pc.close();
response.sendRedirect(redirectFile);}
%>