<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.chart.TimeSeriesChart"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alBal = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fechaEval = request.getParameter("fecha");
String desc = request.getParameter("desc");
String horario = request.getParameter("horario");
String from = request.getParameter("from");
String to = request.getParameter("to");

if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (fechaEval == null) fechaEval = "";
if (desc == null) desc = "";
if (horario == null) horario = "";
if (from == null) from = "";
if (to == null) to = "";

if (pacId.trim().equals("") || noAdmision.trim().equals("")) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
CommonDataObject cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

CommonDataObject cdoDateTime = SQLMgr.getData("select to_char(sysdate,'hh24') as hora_actual, to_char(sysdate + (6 / 24),'dd/mm/yyyy hh12:mi:ss am') as fecha_hora_actual, to_char(sysdate + (6 / 24) - 1,'dd/mm/yyyy hh12:mi:ss am') as fecha_hora_menos_24 from dual");

StringBuffer sbSubtitle = new StringBuffer();
if (horario.equalsIgnoreCase("todos")) {

  sbSubtitle.append("TODOS");
  if (!from.trim().equals("") && !to.trim().equals("")) {

    sbSubtitle = new StringBuffer();
    sbSubtitle.append("DEL ");
    sbSubtitle.append(from);
    sbSubtitle.append(" AL ");
    sbSubtitle.append(to);

    sbFilter.append(" and trunc(a.fecha) between to_date('");
    sbFilter.append(from);
    sbFilter.append("','dd/mm/yyyy') and to_date('");
    sbFilter.append(to);
    sbFilter.append("','dd/mm/yyyy')");

  }

} else if (horario.equalsIgnoreCase("_24h")) {

  sbSubtitle.append("ULTIMAS 24 HORAS (");
  sbSubtitle.append(cdoDateTime.getColValue("fecha_hora_menos_24"));
  sbSubtitle.append(" - ");
  sbSubtitle.append(cdoDateTime.getColValue("fecha_hora_actual"));
  sbSubtitle.append(")");

  sbFilter.append(" and to_date(to_char(a.fecha,'dd/mm/yyyy')||' '||to_char(a.hora,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') between to_date('");
  sbFilter.append(cdoDateTime.getColValue("fecha_hora_menos_24"));
  sbFilter.append("','dd/mm/yyyy hh12:mi:ss am') and to_date('");
  sbFilter.append(cdoDateTime.getColValue("fecha_hora_actual"));
  sbFilter.append("','dd/mm/yyyy hh12:mi:ss am')");

} else if (horario.equalsIgnoreCase("turnoActual")) {

  sbSubtitle.append("TURNO ACTUAL (");

  sbFilter.append(" and trunc(a.fecha) = trunc(sysdate)");
  int hh24 = Integer.parseInt(cdoDateTime.getColValue("hora_actual"));
  if (hh24 >= 7 && hh24 < 15) {
    sbSubtitle.append("7am - 3pm");
    sbFilter.append(" and a.hora between to_date('07:00:00','hh24:mi:ss') and to_date('14:59:59','hh24:mi:ss')");
  } else if (hh24 >= 15 && hh24 < 23) {
    sbSubtitle.append("3pm - 11pm");
    sbFilter.append(" and a.hora between to_date('15:00:00','hh24:mi:ss') and to_date('22:59:59','hh24:mi:ss')");
  } else if (hh24 >= 23 && hh24 < 7) {
    sbSubtitle.append("11pm - 7am");
    sbFilter.append(" and a.hora between to_date('23:00:00','hh24:mi:ss') and to_date('06:59:59','hh24:mi:ss')");
  }

  sbSubtitle.append(")");

} else if (!fechaEval.trim().equals("")) {

  sbSubtitle.append("EVALUACION DEL ");
  sbSubtitle.append(fechaEval);

  sbFilter.append(" and trunc(a.fecha) = to_date('");
  sbFilter.append(fechaEval);
  sbFilter.append("','dd/mm/yyyy')");
}

sbSql = new StringBuffer();
sbSql.append("select to_char(a.fecha,'dd-mm-yyyy')||to_char(a.hora,' hh12:mi:ss am') as fecha_hora, sum(decode(b.tipo_liquido,'I',a.cantidad,'E',-a.cantidad,0)) as cantidad from tbl_sal_detalle_balance a, tbl_sal_via_admin b where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.adm_secuencia = ");
sbSql.append(noAdmision);
sbSql.append(sbFilter);
sbSql.append(" and a.via_administracion = b.codigo group by a.fecha, a.hora order by to_date(to_char(a.fecha,'dd-mm-yyyy')||to_char(a.hora,' hh12:mi:ss am'),'dd-mm-yyyy hh12:mi:ss am')");
al = SQLMgr.getDataList(sbSql);
double bal = 0.00;
for (int i=0; i<al.size(); i++) {
	cdo = (CommonDataObject) al.get(i);
	bal += new Double(cdo.getColValue("cantidad")).doubleValue();
	alBal.add(""+bal);
}

sbSql = new StringBuffer();
sbSql.append("select nvl(decode(sign(cantidad),1,'+'||cantidad,''||cantidad),0) as cantidad, nvl(maxIn,0) as maxIn, nvl(minIn,0) as minIn, nvl(maxOut,0) as maxOut, nvl(minOut,0) as minOut, diffIn, diffOut from (");
	sbSql.append("select sum(decode(b.tipo_liquido,'I',a.cantidad,'E',-a.cantidad,0)) as cantidad, max(decode(b.tipo_liquido,'I',a.cantidad,null)) as maxIn, min(decode(b.tipo_liquido,'I',a.cantidad,null)) as minIn, max(decode(b.tipo_liquido,'E',a.cantidad,null)) as maxOut, min(decode(b.tipo_liquido,'E',a.cantidad,null)) as minOut, trunc(nvl(max(decode(b.tipo_liquido,'I',a.fecha)),sysdate)) - trunc(nvl(min(decode(b.tipo_liquido,'I',a.fecha)),sysdate)) as diffIn, trunc(nvl(max(decode(b.tipo_liquido,'E',a.fecha)),sysdate)) - trunc(nvl(min(decode(b.tipo_liquido,'E',a.fecha)),sysdate)) as diffOut from tbl_sal_detalle_balance a, tbl_sal_via_admin b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.adm_secuencia = ");
	sbSql.append(noAdmision);
	sbSql.append(sbFilter);
	sbSql.append(" and a.via_administracion = b.codigo");
sbSql.append(")");
cdo = SQLMgr.getData(sbSql);

TimeSeriesChart chart = new TimeSeriesChart("dd-MM-yyyy hh:mm:ss a");
chart.setLabelDateFormat("dd-MM-yy hh:mm a");
chart.setDomainDateTickUnit("HOUR");
chart.setVerticalDomainAxisLabel(true);
chart.setDisplayItemValue(false);
chart.setDimension(10.0);
chart.setTitle("Balance Hidrico");
double maxIn = 10000;
double maxOut = 10000;

String domainLabel = "Fecha (dd-mm-aa hh:mi)";
if (cdo != null) {
	chart.setSubtitle("Balance = "+cdo.getColValue("cantidad")+"\n\n"+("Valores en cc ( CENTIMETROS CUBICOS)"));

	if (Double.parseDouble(cdo.getColValue("maxIn")) != 0) maxIn = Double.parseDouble(cdo.getColValue("maxIn"));
	if (Double.parseDouble(cdo.getColValue("maxOut")) != 0) maxOut = Double.parseDouble(cdo.getColValue("maxOut"));

	if (Integer.parseInt(cdo.getColValue("diffIn")) > 1 || Integer.parseInt(cdo.getColValue("diffOut")) > 1) {
		domainLabel = "Fecha (dd-mm-aaaa)";
		chart.setLabelDateFormat("dd-MM-yyyy");
		chart.setDomainDateTickUnit("DAY");
	}
}

String[] serieLabel = {"Líquido Administrado", "Líquido Eliminado"};
double[] lower = {0, 0};
double[] upper = {maxIn, maxOut};
Color[] color = {Color.BLUE, Color.RED};
boolean[] displaySeriesAxis = {true, true};
sbSql = new StringBuffer();
sbSql.append("select to_char(a.fecha,'dd-mm-yyyy')||to_char(a.hora,' hh12:mi:ss am') as fecha, decode(b.tipo_liquido,'I',a.cantidad,null) as icantidad, decode(b.tipo_liquido,'E',a.cantidad,null) as ecantidad from tbl_sal_detalle_balance a, tbl_sal_via_admin b where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.adm_secuencia = ");
sbSql.append(noAdmision);
sbSql.append(sbFilter);
sbSql.append(" and a.via_administracion = b.codigo order by to_date(to_char(a.fecha,'dd-mm-yyyy')||to_char(a.hora,' hh12:mi:ss am'),'dd-mm-yyyy hh12:mi:ss am')");
boolean created = chart.createChart(ConMgr.getConnection(), sbSql.toString(), domainLabel, serieLabel, lower, upper, color, displaySeriesAxis);

if (alBal != null && alBal.size() > 0) chart.addChartSerie("Balance ", alBal, -1 * maxOut, maxIn, Color.BLACK, true);
chart.generateImage(java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/_"+pacId+chart.toString()+".png",980,600);

String chartName = ResourceBundle.getBundle("path").getString("images")+"/image_not_found.jpg";
if (created) chartName =  ResourceBundle.getBundle("path").getString("pdfdocs")+"/_"+pacId+chart.toString()+".png";

if (request.getMethod().equalsIgnoreCase("GET")) {

  String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
  String year = fecha.substring(6, 10);
  String month = fecha.substring(3, 5);
  String day = fecha.substring(0, 2);

  String servletPath = request.getServletPath();
  String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
  String xtraSubtitle = sbSubtitle.toString();
  boolean displayPageNo = true;
  float pageNoFontSize = 0.0f;//between 7 and 10
  String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
  String pageNoPoxX = null;//L=Left, R=Right
  String pageNoPosY = null;//T=Top, B=Bottom
  float cHeight = 11.0f;
  
      CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
    }


  PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumn(1);
	pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, 1);

	pc.setTableHeader(1);

		pc.addImageCols(chartName,550,1);

  pc.addTable();
  pc.close();
  response.sendRedirect(redirectFile);

}//GET
%>