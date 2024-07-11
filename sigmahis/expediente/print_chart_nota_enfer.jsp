<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%//@ page import="issi.admin.FormBean"%>
<%@ page import="issi.chart.TimeSeriesChart"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdoPacData = new CommonDataObject();
String sql = "", sqlTitle = "";
String appendFilter = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String horario = request.getParameter("horario");
String from = request.getParameter("from");
String to = request.getParameter("to");
String desc = request.getParameter("desc");

CommonDataObject cdoDateTime = new CommonDataObject();

String compareDate = "";

int s_7am = 7, s_3pm = 15, s_11pm = 23;

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String hoy = fecha.substring(0,10);

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

String getSysDateTime = "select to_char(sysdate, 'hh24') hora_actual, to_char(sysdate, 'dd/mm/yyyy') fecha_actual, to_char(sysdate, 'dd/mm/yyyy hh12:mi:ss am') fecha_hora_actual, to_char(sysdate - 1, 'dd/mm/yyyy hh12:mi:ss am') fecha_hora_menos_24 from dual";

cdoDateTime = SQLMgr.getData(getSysDateTime);

if(desc == null) desc = "";

//::::::::::::::::::::::::::::: TODOS ::::::::::::::::::::::::::::::::::::::::::::::::://
if(horario.trim().equalsIgnoreCase("todos")){

if(!from.trim().equals("") && !to.trim().equals("")){
     compareDate = "and to_date( to_char( a.fecha,'dd/mm/yyyy')) between to_date('"+from+"','dd/mm/yyyy') and to_date('"+to+"','dd/mm/yyyy')";
	}
}

//:::::::::::::::::::::::::: ULTIMAS 24 HORAS :::::::::::::::::::::::::::::::::::://
if(horario.trim().equalsIgnoreCase("_24h")){
	 compareDate = "and to_date(to_char(a.fecha,'dd/mm/yyyy')|| ' ' ||to_char(a.hora,'hh12:mi:ss am'), 'dd/mm/yyyy hh12:mi:ss am') between to_date('"+cdoDateTime.getColValue("fecha_hora_menos_24")+"','dd/mm/yyyy hh12:mi:ss am') and to_date('"+cdoDateTime.getColValue("fecha_hora_actual")+"','dd/mm/yyyy hh12:mi:ss am')";
}

if(horario.trim().equalsIgnoreCase("turnoActual") && hoy.equals(cdoDateTime.getColValue("fecha_actual")) ){
	  compareDate = "and fecha=to_date('"+cdoDateTime.getColValue("fecha_actual")+"','dd/mm/yyyy') and a.hora between (case when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('07:00 am', 'hh12:mi am') and to_date('03:00 pm', 'hh12:mi am') then to_date('07:00 am', 'hh12:mi am') when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('03:00 pm', 'hh12:mi am') and to_date('11:00 pm', 'hh12:mi am') then to_date('03:00 pm', 'hh12:mi am') else to_date('11:00 pm', 'hh12:mi am') end) and (case when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('07:00 am', 'hh12:mi am') and to_date('03:00 pm', 'hh12:mi am') then to_date('03:00 pm', 'hh12:mi am') when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('03:00 pm', 'hh12:mi am') and to_date('11:00 pm', 'hh12:mi am') then to_date('11:00 pm', 'hh12:mi am') else to_date('07:00 am', 'hh12:mi am') end)";
}


/*System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
System.out.println(compareDate);
System.out.println(hoy+" ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
*/




/** /
	sql = "select to_char(fecha,'dd-MON-yyyy')||to_char(hora_r,' hh12:mi:ss') as fecha_nota, temperatura, pulso, respiracion, decode(instr(p_arterial,'/'),0,null,substr(p_arterial,1,instr(p_arterial,'/') - 1)) as sistolic, decode(instr(p_arterial,'/'),0,null,substr(p_arterial,instr(p_arterial,'/') + 1)) as diastolic from tbl_sal_resultado_nota where pac_id="+pacId+" and secuencia="+noAdmision+"";
	al = SQLMgr.getDataList(sql);

	CommonDataObject cdo;
	ArrayList period=new ArrayList();
	ArrayList temp=new ArrayList();
	ArrayList pulso=new ArrayList();
	ArrayList respiracion=new ArrayList();
	ArrayList sistolic=new ArrayList();
	ArrayList diastolic=new ArrayList();
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		period.add(cdo.getColValue("fecha_nota"));
		temp.add(cdo.getColValue("temperatura"));
		pulso.add(cdo.getColValue("pulso"));
		respiracion.add(cdo.getColValue("respiracion"));
		sistolic.add(cdo.getColValue("sistolic"));
		diastolic.add(cdo.getColValue("diastolic"));
	}
/ **/


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
	String subTitle = desc;//+cdoTitle.getColValue("descripcion");
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

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

Vector dHeader = new Vector();
dHeader.addElement("50");


		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

   //Cambié de mi a mm, debido a que en la clase chart/TimeSeriesChart
  //usan mi eso hace que al cambiarle el al formato oracle, manda
  //java.lang.IllegalArgumentException: Illegal pattern character 'i'

	TimeSeriesChart chart = new TimeSeriesChart("dd-MM-yyyy hh:mm:ss");
	chart.setLabelDateFormat("dd-MM-yy");// hh:mi:ss a
	chart.setDomainDateTickUnit("DAY");
	chart.setVerticalDomainAxisLabel(true);
	chart.setDisplayItemValue(false);
	chart.setDimension(10.0);
	chart.setTitle("SIGNOS VITALES");

	//chart.createChart(ConMgr.getConnection(),"select to_date(to_char(fecha,'dd-mm-yyyy')||to_char(hora_r,' hh24:mi:ss'),'dd-mm-yyyy hh24:mi:ss') as fecha_nota, to_number(temperatura) as temperatura, to_numer(pulso) as pulso from tbl_sal_resultado_nota where pac_id="+pacId+" and secuencia="+noAdmision+"","Fecha","Temperatura (ºC)");

	String domainLabel = "Fecha (dd-mm-aa)";
	String[] serieLabel = {"Temperatura (°C)", "Pulso", "Respiración", " ", "Presión Arterial (mmHg)"};
	double[] lower = {30, 0, 0, 0, 0};
	double[] upper = {43, 300, 50, 300, 300};
	Color[] color = {Color.RED, Color.BLUE, Color.GREEN, Color.BLACK, Color.BLACK};
	boolean[] displaySeriesAxis = {true, true, true, false, true};
	boolean created = chart.createChart(ConMgr.getConnection(), "select to_char(a.fecha,'dd-mm-yyyy')||to_char(a.hora_r,' hh24:mi:ss') as fecha_nota, a.temperatura, a.pulso, a.respiracion, decode(instr(a.p_arterial,'/'),0,null,substr(a.p_arterial,1,instr(a.p_arterial,'/') - 1)) as sistolic, decode(instr(a.p_arterial,'/'),0,null,substr(a.p_arterial,instr(a.p_arterial,'/') + 1)) as diastolic from tbl_sal_resultado_nota a where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and a.estado='A' "+compareDate+" order by a.fecha_nota, a.hora, a.fecha, a.hora_r", domainLabel, serieLabel, lower, upper, color, displaySeriesAxis);

/** /
	chart.createChart("Fecha",period,"Temperatura (ºC)",temp,java.awt.Color.BLACK);
	chart.addChartSerie("Pulso",pulso,30,43,java.awt.Color.RED);
	chart.addChartSerie("Respiración",respiracion,0,20,java.awt.Color.BLUE);
	chart.addChartSerie(" ",sistolic,0,300,java.awt.Color.GREEN,false);
	chart.addChartSerie("Presión Arterial (mmHg)",diastolic,0,300,java.awt.Color.GREEN);
/ **/

	chart.generateImage(java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/_"+pacId+chart.toString()+".png",960,600);

	String filename = ResourceBundle.getBundle("path").getString("images")+"/image_not_found.jpg";
	//if (al.size() > 0) filename = "../pdfdocs/_"+pacId+chart.toString()+".png";
	if (created) filename =  ResourceBundle.getBundle("path").getString("pdfdocs")+"/_"+pacId+chart.toString()+".png";
    pc.addImageCols(filename,500,1);
	//pc.addBorderCols("Here",1,dHeader.size(),600);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>