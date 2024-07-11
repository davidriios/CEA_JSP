<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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

ArrayList al = new ArrayList();

CommonDataObject cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String desc = request.getParameter("desc");
String code = request.getParameter("code");

if (code == null) code = "0";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

sql =  "select a.codigo, a.descripcion, b.observacion, b.valor, decode(b.cod_param,null,'I','U') action, b.cod_param from tbl_sal_ant_med_importantes a, tbl_sal_proc_cir_ambu_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.cod_header(+) = "+code+" order by a.orden";

al = SQLMgr.getDataList(sql);

CommonDataObject cdoH = SQLMgr.getData("select to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion, a.usuario_creacion, a.cod_diag, nvl(d.observacion,nombre) diag_desc, a.cod_procedimiento, nvl(c.observacion,nombre) procedimiento_desc, a.alergico, a.alergias_desc, a.voluntario, a.voluntad_desc, a.vulnerable, a.vulnerabilidad vulnerabilidades, a.vulnerabilidad_desc, a.presion_arterial, a.peso from tbl_sal_proc_cir_ambu a, tbl_cds_diagnostico d, tbl_cds_procedimiento c where a.cod_diag = d.codigo(+) and a.cod_procedimiento = c.codigo(+) and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" and a.codigo = "+code);

if (cdoH == null) cdoH = new CommonDataObject();

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String year = fecha.substring(6, 10);
String month = fecha.substring(3, 5);
String day = fecha.substring(0, 2);

String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

if (month.equals("01")) month = "january";
else if (month.equals("02")) month = "february";
else if (month.equals("03")) month = "march";
else if (month.equals("04")) month = "april";
else if (month.equals("05")) month = "may";
else if (month.equals("06")) month = "june";
else if (month.equals("07")) month = "july";
else if (month.equals("08")) month = "august";
else if (month.equals("09")) month = "september";
else if (month.equals("10")) month = "october";
else if (month.equals("11")) month = "november";
else month = "december";

String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
String statusPath = "";
String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

float width = 72 * 8.5f;//612
float height = 72 * 11f;//792
boolean isLandscape = false;
float leftRightMargin = 9.0f;
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
int fontSize = 8;
float cHeight = 12.0f;

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
if(pc == null){
    pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
    isUnifiedExp=true;
}

Vector dHeader = new Vector();
dHeader.addElement(".20");
dHeader.addElement(".35");
dHeader.addElement(".05");
dHeader.addElement(".05");
dHeader.addElement(".35");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

pc.setFont(12, 1);

pc.addCols("Fecha: "+cdoH.getColValue("fecha_creacion"," "), 0, 2);
pc.addCols("Creado por: "+cdoH.getColValue("usuario_creacion"," "), 0, 3);

pc.addCols(" ", 0, dHeader.size());

pc.setFont(11, 1);
pc.addBorderCols("Diagnóstico:", 0,1);
pc.setFont(11, 0);
pc.addBorderCols(cdoH.getColValue("diag_desc"," "), 0, dHeader.size()-1);
pc.setFont(11, 1);
pc.addBorderCols("Procedimiento:", 0, 1);
pc.setFont(11, 0);
pc.addBorderCols(cdoH.getColValue("procedimiento_desc"," "), 0, dHeader.size()-1);

String alergias = "";
if (cdoH.getColValue("alergico"," ").equalsIgnoreCase("S")) alergias = "[ x ] SI         [   ] NO"; 
else if (cdoH.getColValue("alergico"," ").equalsIgnoreCase("N")) alergias = "[    ] SI         [ x ] NO";
else alergias = "[    ] SI         [    ] NO";

pc.setFont(11, 1);
pc.addBorderCols("Alergias:", 0, 1);
pc.setFont(11, 0);
pc.addBorderCols(alergias, 0, dHeader.size()-1);

pc.setFont(11, 1);
pc.addBorderCols("Alergico a:", 0, 1);
pc.setFont(11, 0);
pc.addBorderCols(cdoH.getColValue("alergias_desc"), 0, dHeader.size()-1);

String voluntad = "";
if (cdoH.getColValue("voluntario"," ").equalsIgnoreCase("S")) voluntad = "[ x ] SI         [   ] NO"; 
else if (cdoH.getColValue("voluntario"," ").equalsIgnoreCase("N")) voluntad = "[    ] SI         [ x ] NO";
else voluntad = "[    ] SI         [    ] NO";

pc.setFont(11, 1);
pc.addBorderCols("Voluntades Anticipadas:", 0, 1);
pc.setFont(11, 0);
pc.addBorderCols(voluntad, 0, dHeader.size()-1);

pc.setFont(11, 1);
pc.addBorderCols("Voluntades:", 0, 1);
pc.setFont(11, 0);
pc.addBorderCols(cdoH.getColValue("voluntad_desc"), 0, dHeader.size()-1);

String vulnerable = "";
if (cdoH.getColValue("vulnerable"," ").equalsIgnoreCase("S")) vulnerable = "[ x ] SI         [   ] NO"; 
else if (cdoH.getColValue("vulnerable"," ").equalsIgnoreCase("N")) vulnerable = "[    ] SI         [ x ] NO";
else vulnerable = "[    ] SI         [    ] NO";

pc.setFont(11, 1);
pc.addBorderCols("Paciente Vulnerable:", 0, 1);
pc.setFont(11, 0);
pc.addBorderCols(vulnerable, 0, dHeader.size()-1);


String vulnerabilidades = "";
if (cdoH.getColValue("vulnerabilidades"," ").equalsIgnoreCase("P")) vulnerabilidades = "[ x ] PEDIAT.         [    ] GERIAT.         [    ] PSIQUIAT.         [    ] GINEC.         [    ] ABUSO.         [    ] OTRO."; 
else if (cdoH.getColValue("vulnerabilidades"," ").equalsIgnoreCase("G")) vulnerabilidades = "[    ] PEDIAT.         [ x ] GERIAT.         [    ] PSIQUIAT.         [    ] GINEC.         [    ] ABUSO.\n[    ] OTRO.";
else if (cdoH.getColValue("vulnerabilidades"," ").equalsIgnoreCase("Q")) vulnerabilidades = "[    ] PEDIAT.         [   ] GERIAT.         [ x ] PSIQUIAT.         [   ] GINEC.         [   ] ABUSO.\n[    ] OTRO."; 
else if (cdoH.getColValue("vulnerabilidades"," ").equalsIgnoreCase("J")) vulnerabilidades = "[    ] PEDIAT.         [   ] GERIAT.         [   ] PSIQUIAT.         [ x ] GINEC.         [   ] ABUSO.\n[    ] OTRO."; 
else if (cdoH.getColValue("vulnerabilidades"," ").equalsIgnoreCase("A")) vulnerabilidades = "[    ] PEDIAT.         [   ] GERIAT.         [   ] PSIQUIAT.         [   ] GINEC.         [ x ] ABUSO.\n[    ] OTRO."; 
else if (cdoH.getColValue("vulnerabilidades"," ").equalsIgnoreCase("O")) vulnerabilidades = "[    ] PEDIAT.         [   ] GERIAT.         [   ] PSIQUIAT.         [   ] GINEC.         [   ] ABUSO.\n[ x ] OTRO."; 

pc.setFont(11, 1);
pc.addBorderCols("Vulnerabilidades:", 0, 1);
pc.setFont(11, 0);
pc.addBorderCols(vulnerabilidades, 0, dHeader.size()-1);

pc.setFont(11, 1);
pc.addBorderCols("Otras Vulnerabilidades:", 0, 1);
pc.setFont(11, 0);
pc.addBorderCols(cdoH.getColValue("vulnerabilidad_desc"), 0, dHeader.size()-1);

pc.setFont(11, 1);
pc.addBorderCols("Presión Arterial:", 0, 1);
pc.setFont(11, 0);
pc.addBorderCols(cdoH.getColValue("presion_arterial"), 0, 1);

pc.setFont(11, 1);
pc.addBorderCols("Peso (kg):", 0, 2);
pc.setFont(11, 0);
pc.addBorderCols(cdoH.getColValue("peso"), 0, 1);

pc.addCols(" ", 0, dHeader.size());

pc.setFont(10, 1);
pc.addBorderCols("ANTECEDENTES MEDICOS IMPORTANTES", 0, 2,Color.lightGray);
pc.addBorderCols("SI", 1, 1,Color.lightGray);
pc.addBorderCols("NO", 1, 1,Color.lightGray);
pc.addBorderCols("    Observación", 0, 1,Color.lightGray);

pc.setFont(10, 0);

for (int i = 0; i < al.size(); i++) {
    CommonDataObject cdo = (CommonDataObject) al.get(i);
    String valorSi = cdo.getColValue("valor", " ").trim().equalsIgnoreCase("S") ? "X" : "";
    String valorNo = cdo.getColValue("valor", " ").trim().equalsIgnoreCase("N") ? "X" : "";
    pc.addBorderCols(cdo.getColValue("descripcion", " "), 0, 2);
    pc.addBorderCols(valorSi, 1, 1);
    pc.addBorderCols(valorNo, 1, 1);
    pc.addBorderCols("    "+cdo.getColValue("observacion", " "), 0, 1);
}

pc.addCols(" ", 0, dHeader.size());
pc.setFont(10, 1);
pc.addBorderCols("ORDENES", 0, dHeader.size(),Color.lightGray);

pc.setFont(10, 0);

al = SQLMgr.getDataList("select nota, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion_dsp from tbl_sal_proc_cir_ambu_notas where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_header = "+code+" order by fecha_creacion desc");

for (int i = 0; i < al.size(); i++) {
    CommonDataObject cdo = (CommonDataObject) al.get(i);
    pc.addBorderCols(cdo.getColValue("nota", " "), 0, dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);
}
%>