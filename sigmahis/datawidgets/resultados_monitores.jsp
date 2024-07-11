<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.chart.TimeSeriesChart"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fechaEval = request.getParameter("fechaEval")==null?"":request.getParameter("fechaEval");
String serveToRemote = request.getParameter("remoto") == null?"":request.getParameter("remoto");

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (fechaEval.equals("")) fechaEval = CmnMgr.getCurrentDate("yyyy-mm-dd");

sbSql = new StringBuffer();
sbSql.append(" SELECT distinct a.fechaHoja, nvl(a.FRECUENCIACARDIACA,0)FRECUENCIACARDIACA, nvl(b.SATURACIONDEOXIGENO,0) SATURACIONDEOXIGENO, nvl(c.TEMPERATURA,0) TEMPERATURA, nvl(d.FRECUENCIARESPIRATORIA,0) FRECUENCIARESPIRATORIA FROM ");
sbSql.append(" (select to_char(a.obx_date,'dd-mm-yyyy hh:mm:ss am') as fechaHoja, a.obx_measure_result AS FRECUENCIACARDIACA ");
sbSql.append(" from tbl_int_measurement_validated a where a.pac_id = "+pacId+" and obx_measure in('FRECUENCIACARDIACA','FC') ");
sbSql.append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "); sbSql.append(noAdmision); sbSql.append("))");
sbSql.append(" and trunc(obx_date) = to_date('"+fechaEval+"','yyyy-mm-dd') and status='P') a");
     sbSql.append("  LEFT JOIN ");
sbSql.append(" (select to_char(a.obx_date,'dd-mm-yyyy hh:mm:ss am') as fechaHoja, a.obx_measure_result AS SATURACIONDEOXIGENO ");
sbSql.append(" from tbl_int_measurement_validated a where a.pac_id = "+pacId+" and obx_measure in('SATURACIONDEOXIGENO','SO2') ");
sbSql.append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "); sbSql.append(noAdmision); sbSql.append("))");
sbSql.append(" and trunc(obx_date) = to_date('"+fechaEval+"','yyyy-mm-dd') and status='P') b");
	 sbSql.append(" ON a.fechaHoja = b.fechaHoja");
	 sbSql.append("  LEFT JOIN");
sbSql.append(" (select to_char(a.obx_date,'dd-mm-yyyy hh:mm:ss am') as fechaHoja, a.obx_measure_result AS TEMPERATURA ");
sbSql.append(" from tbl_int_measurement_validated a where a.pac_id = "+pacId+" and obx_measure in('TEMPERATURA','TEMPERATURA 2') ");
sbSql.append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "); sbSql.append(noAdmision); sbSql.append("))");
sbSql.append(" and trunc(obx_date) = to_date('"+fechaEval+"','yyyy-mm-dd') and status='P') c");
sbSql.append("	ON a.fechaHoja = c.fechaHoja");
sbSql.append("	LEFT JOIN ");
sbSql.append(" (select to_char(a.obx_date,'dd-mm-yyyy hh:mm:ss am') as fechaHoja, a.obx_measure_result AS FRECUENCIARESPIRATORIA ");
sbSql.append(" from tbl_int_measurement_validated a where a.pac_id = "+pacId+" and obx_measure in('FRECUENCIARESPIRATORIA','FR') ");
sbSql.append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "); sbSql.append(noAdmision); sbSql.append("))");
sbSql.append(" and trunc(obx_date) = to_date('"+fechaEval+"','yyyy-mm-dd') and status='P') d");
sbSql.append(" ON a.fechaHoja = d.fechaHoja");


if (request.getMethod().equalsIgnoreCase("GET"))
{
	TimeSeriesChart chart = new TimeSeriesChart("dd-MM-yyyy hh:mm:ss a");
	chart.setLabelDateFormat("hh:mm:ss a");
	chart.setDomainDateTickUnit("SECOND");
	chart.setVerticalDomainAxisLabel(true);
	chart.setDisplayItemValue(false);
	chart.setDimension(10.0);
	chart.setTitle(fechaEval);

	String domainLabel = "Hora (hh:mm:ss a)";
	String[] serieLabel = {"FC","SO2","TEMP.","FR"};
	//String[] serieLabel = {"Glicemia","Inulina"};
	double[] lower = {0, 0, 0, 0};
	//double[] lower = {0, 0};
	double[] upper = {500, 50, 50, 50};
	//double[] upper = {500, 50};
	Color[] color = {Color.RED, Color.BLUE, Color.GREEN, Color.BLACK};
	//Color[] color = {Color.RED, Color.BLUE};
	boolean[] displaySeriesAxis = {true, true, true, true};
	//boolean[] displaySeriesAxis = {true, true};
	boolean created = chart.createChart(ConMgr.getConnection(), sbSql.toString(), domainLabel, serieLabel, lower, upper, color, displaySeriesAxis);
	chart.generateImage(java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/_"+pacId+chart.toString()+".png",1000,600);
	
	System.out.println("::::::::::::::::::::::::::::::::\nfechaEval="+fechaEval+"\n"+sbSql.toString());

	String image = "../images/image_not_found.jpg";
	if (created) image = "../pdfdocs/_"+pacId+chart.toString()+".png";
	
	if ( serveToRemote.trim().equals("Y") ){
		out.print(image);
	}else{
%>
<div class="row">
	<!--=== Static Table ===-->
	<div class="col-md-12">
		<div class="widget box widget-closed">
			<div class="widget-header">
				<h4><i class="icon-reorder"></i>Resultados de Monitores (Signos Vitales)</h4>
				
				<div class="toolbar no-padding">
					<div class="btn-group">
						<span class="btn btn-xs widget-collapse" id="resultado-monitores"><i class="icon-angle-up"></i></span>
						<span class="btn btn-xs widget-refresh refresh-it" data-url="../datawidgets/resultados_monitores.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>" data-container="#resultados-monitores-container" data-expander="#resultado-monitores" data-type="full" data-chart="sv"><i class="icon-refresh"></i></span>
					</div>
				</div>
			</div>
						
			<div class="widget-content no-padding">
			<div class="input-group input-group-md">		
							<span class="datepicker" data-date-format="yyyy-MM-dd"><input  size="15" data-provide="datepicker" value='<%=fechaEval%>' name="fechaEval-sv" id="fechaEval-sv" type="date"></input></span>							
				</div>
				<div><image src="<%=image%>"></div>
			</div>
			
		</div>
	</div>
</div>	
<%
}
}//GET
%>