<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
CommonDataObject cdoPacData = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String pacName = request.getParameter("pacName");
String fDate = request.getParameter("fDate");
String interval = request.getParameter("interval");
String intervalCol = request.getParameter("intervalCol");
String userName = UserDet.getUserName();

if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (pacName == null) pacName = "";
if (fDate == null) fDate = "";
if (interval == null) interval = "60";
if (intervalCol == null) intervalCol = "0";

sbSql.append("select to_char(trunc(sysdate) + n / decode(");
sbSql.append(interval);
sbSql.append(",60,24,48),'HH24:MI') as hhmi from (");
	sbSql.append("select (level - 1) as n");
if (intervalCol.equals("-1")) {
	sbSql.append(", substr(getDateDifRound(sysdate,");
	sbSql.append(interval);
	sbSql.append(",'T'),1,2) as hh, substr(getDateDifRound(sysdate,");
	sbSql.append(interval);
	sbSql.append(",'T'),4,5) as mi");
}
	sbSql.append(" from dual connect by (level - 1) < decode(");
	sbSql.append(interval);
	sbSql.append(",60,24,48)");
sbSql.append(")");
if (intervalCol.equals("-1")) sbSql.append(" where (((hh * 2) + decode(mi,'00',0,1) - 23) >= 0 and n between ((hh * 2) + decode(mi,'00',0,1) - 23) and ((hh * 2) + decode(mi,'00',0,1))) or (((hh * 2) + decode(mi,'00',0,1) - 23) < 0 and n between 0 and 23)");
else if (intervalCol.equals("1")) sbSql.append(" where n between 0 and 23");
else if (intervalCol.equals("2")) sbSql.append(" where n between 24 and 47");
StringBuffer sbInterval = new StringBuffer();
ArrayList alPivot = SQLMgr.getDataList(sbSql);
for (int j = 0; j < alPivot.size(); j++) {
	CommonDataObject cdoPivot = (CommonDataObject) alPivot.get(j);
	if (j > 0) sbInterval.append(",");
	sbInterval.append("'");
	sbInterval.append(cdoPivot.getColValue("hhmi"));
	sbInterval.append("'");
}

if (pacId.trim().equals("") || admision.trim().equals("")) throw new Exception("La cuenta ["+pacId+"-"+admision+"] no es válida. Por favor intente nuevamente!");
cdoPacData = SQLMgr.getPacData(pacId,admision);
if (cdoPacData == null) cdoPacData = new CommonDataObject();

if (!pacId.trim().equals("")) { sbFilter.append(" and a.pac_id = "); sbFilter.append(pacId); }
if (!admision.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_admision z where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = z.pac_id and secuencia = "); sbFilter.append(admision); sbFilter.append("))"); }
if (!fDate.trim().equals("")) { sbFilter.append(" and trunc(a.obx_date) = to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }

sbSql = new StringBuffer();
sbSql.append("select * from (");//query to get the closest positive diff to the given interval

	sbSql.append("select a.pac_id, a.admision, nvl((select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id),'- SIN CUENTA -') as paciente, a.cds, a.room, a.bed, a.obx_measure, a.obx_measure_desc, a.obx_measure_result as result, trunc(a.obx_date) as obxdate, to_char(trunc(a.obx_date),'dd/mm/yyyy') as obxdate_dsp, a.obxtime, (select descripcion from tbl_cds_centro_servicio where codigo = a.cds) as cds_desc");
	sbSql.append(", row_number() over(partition by a.pac_id, a.admision, a.cds, a.room, a.bed, a.obx_measure, trunc(a.obx_date), a.obxtime order by abs(getDateDifRound(a.obx_date,");
	sbSql.append(interval);
	sbSql.append(",'D'))/*--- min diff ---*/, getDateDifRound(a.obx_date,");
	sbSql.append(interval);
	sbSql.append(",'D') desc/*--- the closest positive min diff ---*/) as priority");
	sbSql.append(", (select display_order from tbl_int_measure where code = a.obx_measure) as obx_measure_order");
	sbSql.append(" from tbl_int_measurement_validated a");
	sbSql.append(" where a.status = 'P' and a.measurement_type = 'VS' and abs(getDateDifRound(a.obx_date,");
	sbSql.append(interval);
	sbSql.append(",'D')) < (");
	sbSql.append(interval);
	sbSql.append(" / 2) * 60/*--- to exclude rounding time to next day ---*/");
	sbSql.append(sbFilter);

sbSql.append(") where priority = 1/* order by pac_id, admision, obx_measure_order, obx_measure, obxdate, obxtime*/");

StringBuffer sbSqlFinal = new StringBuffer();
sbSqlFinal.append("select * from (");
sbSqlFinal.append(sbSql);
sbSqlFinal.append(") pivot ( max(result) for obxtime in (");
sbSqlFinal.append(sbInterval);
sbSqlFinal.append(") ) order by pac_id, admision, obxdate, obx_measure_order, obx_measure");
al = SQLMgr.getDataList(sbSqlFinal.toString());

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
float height = 72 * 14f;//1008
boolean isLandscape = true;
float leftRightMargin = 9.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE - RESULTADO DE MONITORES";
String subtitle = pacName;
String xtraSubtitle = fDate;
boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 8;
float cHeight = 12.0f;
PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

Vector dHeader = new Vector();
	dHeader.addElement(".16");//.1432
	dHeader.addElement(".035");//.035
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");
	dHeader.addElement(".035");

//table header
pc.setNoColumnFixWidth(dHeader);
pc.createTable();
	//first row
	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	//second row
	pc.setFont(7, 1);
	pc.addBorderCols("Código",1);
	for (int j = 0; j < alPivot.size(); j++) {
		CommonDataObject cdo = (CommonDataObject) alPivot.get(j);
		pc.addBorderCols(cdo.getColValue("hhmi"),1);
	}
pc.setTableHeader(2);//create de table header (3 rows) and add header to the table

//table body
pc.setVAlignment(0);
for (int i = 0; i < al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	pc.setFont(7, 0);
	pc.addCols(cdo.getColValue("obx_measure_desc"),0,1);
	for (int j = 0; j < alPivot.size(); j++) {
		CommonDataObject cdoPivot = (CommonDataObject) alPivot.get(j);
		pc.addCols(cdo.getColValue("'"+cdoPivot.getColValue("hhmi")+"'"),1,1);
	}

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
}
if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());

pc.addTable();
pc.close();
response.sendRedirect(redirectFile);
%>