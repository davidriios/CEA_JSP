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

sql =  "select a.codigo, a.descripcion, d.valor, d.observacion, decode(d.cod_monitoreo, null, 'I', 'U') action from tbl_sal_monitoreo_params a, tbl_sal_monitoreo_fetal_det d where a.estado = 'A' and a.codigo = d.cod_param and d.pac_id = "+pacId+" and d.admision = "+noAdmision+" and d.cod_monitoreo = "+code+" order by a.orden";

al = SQLMgr.getDataList(sql);

CommonDataObject cdoH = SQLMgr.getData("select a.codigo, to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, usuario_creacion, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.semana_gestacion, a.medico_obstetra, m.primer_nombre||' '||primer_apellido medico_obstetra_nombre, a.p_a, a.fc_fb, a.observacion from tbl_sal_monitoreo_fetal a, tbl_adm_medico m where pac_id = "+pacId+" and admision = "+noAdmision+" and a.medico_obstetra = m.codigo and a.codigo = "+code);

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
dHeader.addElement(".50");
dHeader.addElement(".05");
dHeader.addElement(".05");
dHeader.addElement(".40");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

pc.setFont(12, 1);

pc.addCols("Fecha: "+cdoH.getColValue("fc"," "), 0, 2);
pc.addCols("Creado por: "+cdoH.getColValue("usuario_creacion"," "), 0, 2);

pc.addCols(" ", 0, dHeader.size());
pc.setFont(11, 1);

pc.addBorderCols("Fecha nacimiento: "+cdoH.getColValue("fecha_nacimiento"," "), 0, dHeader.size());
pc.addBorderCols("Semana gestación: "+cdoH.getColValue("semana_gestacion"," "), 0, dHeader.size());
pc.addBorderCols("Médico Obstreta: ["+cdoH.getColValue("medico_obstetra"," ")+"] "+cdoH.getColValue("medico_obstetra_nombre"," "), 0, dHeader.size());
pc.addBorderCols("P/A: "+cdoH.getColValue("p_a"," ")+"                                  FCF: "+cdoH.getColValue("fc_fb"," "), 0, dHeader.size());

pc.addCols(" ", 0, dHeader.size());

pc.setFont(10, 1);
pc.addBorderCols("Parámetro", 0, 1,Color.lightGray);
pc.addBorderCols("SI", 1, 1,Color.lightGray);
pc.addBorderCols("NO", 1, 1,Color.lightGray);
pc.addBorderCols("    Observación", 0, 1,Color.lightGray);

pc.setFont(10, 0);

for (int i = 0; i < al.size(); i++) {
    CommonDataObject cdo = (CommonDataObject) al.get(i);
    String valorSi = cdo.getColValue("valor", " ").trim().equalsIgnoreCase("S") ? "[  X  ]" : "[      ]";
    String valorNo = cdo.getColValue("valor", " ").trim().equalsIgnoreCase("N") ? "[  X  ]" : "[      ]";
    pc.addCols(cdo.getColValue("descripcion", " "), 0, 1);
    pc.addCols(valorSi, 1, 1);
    pc.addCols(valorNo, 1, 1);
    pc.addCols("    "+cdo.getColValue("observacion", " "), 0, 1);
}

pc.setFont(11, 1);
pc.addCols(" ", 0, dHeader.size());
pc.addCols("Observación:", 0, dHeader.size());
pc.setFont(10, 0);
pc.addCols(cdoH.getColValue("observacion", " "), 0, dHeader.size());


pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);
}
%>