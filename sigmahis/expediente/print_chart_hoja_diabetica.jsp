<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.chart.TimeSeriesChart"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
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
String noAdmision = request.getParameter("noAdmision");
String horario = request.getParameter("horario");
String from = request.getParameter("from")==null?"":request.getParameter("from");
String _to = request.getParameter("to")==null?"":request.getParameter("to");
String desc = request.getParameter("desc");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String year = fecha.substring(6, 10);
String month = fecha.substring(3, 5);
String day = fecha.substring(0, 2);
String fechaEval = request.getParameter("fechaEval")==null?"":request.getParameter("fechaEval");

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (!fechaEval.trim().equals("")) {
  sbFilter.append(" and trunc(a.fecha_hoja) = to_date('");
  sbFilter.append(fechaEval);
  sbFilter.append("','dd/mm/yyyy')");
}else{
	if(horario.trim().equalsIgnoreCase("todos") && !from.trim().equals("") && !_to.trim().equals("")){
		sbFilter.append("and trunc(a.fecha_hoja) between to_date('");
		sbFilter.append(from);
		sbFilter.append("','dd/mm/yyyy') and to_date('");
		sbFilter.append(_to);
		sbFilter.append("','dd/mm/yyyy')");
	}else
	if(horario.trim().equalsIgnoreCase("_24h")){
		 sbFilter.append(" and trunc(a.fecha_hoja) between trunc(sysdate-1) and trunc(sysdate) ");
	}else
	if( horario.trim().equalsIgnoreCase("turnoActual") ){
	  sbFilter.append(" and a.fecha_hoja=trunc(sysdate) and to_date(to_char(a.hora,'hh12:mi am'),'hh12:mi am') between (case when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('07:00 am', 'hh12:mi am') and to_date('03:00 pm', 'hh12:mi am') then to_date('07:00 am', 'hh12:mi am') when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('03:00 pm', 'hh12:mi am') and to_date('11:00 pm', 'hh12:mi am') then to_date('03:00 pm', 'hh12:mi am') else to_date('11:00 pm', 'hh12:mi am') end) and (case when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('07:00 am', 'hh12:mi am') and to_date('03:00 pm', 'hh12:mi am') then to_date('03:00 pm', 'hh12:mi am') when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('03:00 pm', 'hh12:mi am') and to_date('11:00 pm', 'hh12:mi am') then to_date('11:00 pm', 'hh12:mi am') else to_date('07:00 am', 'hh12:mi am') end) ");
	}
}	

sbSql.append(" select to_char(a.fecha_hoja,'dd-mm-yyyy')||to_char(a.hora,' hh12:mi:ss am') as fechaHoja, a.glucosa, a.insulina from tbl_sal_detalle_diabetica a where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(sbFilter.toString());
sbSql.append(" order by a.fecha_hoja desc ");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

	String userName = UserDet.getUserName();
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
	String subTitle = desc;
	String xtraSubtitle = !fechaEval.equals("")?"(Evaluación: "+fechaEval+")":"";
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

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement("100");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();

	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);

	TimeSeriesChart chart = new TimeSeriesChart("dd-MM-yyyy hh:mm:ss a");
	chart.setLabelDateFormat("dd-MM-yy");
	chart.setDomainDateTickUnit("DAY");
	chart.setVerticalDomainAxisLabel(true);
	chart.setDisplayItemValue(false);
	chart.setDimension(10.0);
	chart.setTitle("Hoja Diabética");

	String domainLabel = "Fecha (dd-mm-aa)";
	String[] serieLabel = {"Glicemia", "Insulina"};
	double[] lower = {0, 0};
	double[] upper = {500, 50};
	Color[] color = {Color.RED, Color.BLUE};
	boolean[] displaySeriesAxis = {true, true};
	boolean created = chart.createChart(ConMgr.getConnection(), sbSql.toString(), domainLabel, serieLabel, lower, upper, color, displaySeriesAxis);
	chart.generateImage(java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/_"+pacId+chart.toString()+".png",900,600);
	
	//System.out.println("::::::::::::::::::::::::::::::::\n"+sbSql.toString());

	String image = ResourceBundle.getBundle("path").getString("images")+"/image_not_found.jpg";

	if (created) image =  ResourceBundle.getBundle("path").getString("pdfdocs")+"/_"+pacId+chart.toString()+".png";
    pc.addImageCols(image,500,1);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>