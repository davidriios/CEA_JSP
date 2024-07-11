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

// sbFilter.append(" and exists (select null from tbl_adm_admision a where pac_id = z.pac_id and secuencia = z.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = a.pac_id and secuencia = "); sbFilter.append(admision); sbFilter.append("))");

sbSql = new StringBuffer();
sbSql.append(" SELECT distinct a.fechaHoja, nvl(a.PANISIS,0)PANISIS, nvl(b.PANIDIA,0) PANIDIA, nvl(c.PANIMED,0) PANIMED, nvl(d.PAS,0) PAS, nvl(e.PAD,0) PAD, nvl(f.PAM,0) PAM FROM ");
sbSql.append(" (select to_char(a.obx_date,'dd-mm-yyyy hh:mm:ss am') as fechaHoja, a.obx_measure_result AS PANISIS ");
sbSql.append(" from tbl_int_measurement_validated a where a.pac_id = "+pacId+" and obx_measure = 'PANI SIS' ");
sbSql.append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "); sbSql.append(noAdmision); sbSql.append("))");
sbSql.append(" and trunc(obx_date) = to_date('"+fechaEval+"','yyyy-mm-dd') and status='P') a");
     sbSql.append("  LEFT JOIN ");
sbSql.append(" (select to_char(a.obx_date,'dd-mm-yyyy hh:mm:ss am') as fechaHoja, a.obx_measure_result AS PANIDIA ");
sbSql.append(" from tbl_int_measurement_validated a where a.pac_id = "+pacId+" and obx_measure = 'PANI DIA' ");
sbSql.append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "); sbSql.append(noAdmision); sbSql.append("))");
sbSql.append(" and trunc(obx_date) = to_date('"+fechaEval+"','yyyy-mm-dd') and status='P') b");
	 sbSql.append(" ON a.fechaHoja = b.fechaHoja");
	 sbSql.append("  LEFT JOIN");
sbSql.append(" (select to_char(a.obx_date,'dd-mm-yyyy hh:mm:ss am') as fechaHoja, a.obx_measure_result AS PANIMED ");
sbSql.append(" from tbl_int_measurement_validated a where a.pac_id = "+pacId+" and obx_measure = 'PANI MED' ");
sbSql.append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "); sbSql.append(noAdmision); sbSql.append("))");
sbSql.append(" and trunc(obx_date) = to_date('"+fechaEval+"','yyyy-mm-dd') and status='P') c");
sbSql.append("	ON a.fechaHoja = c.fechaHoja");
sbSql.append("	LEFT JOIN ");
sbSql.append(" (select to_char(a.obx_date,'dd-mm-yyyy hh:mm:ss am') as fechaHoja, a.obx_measure_result AS PAS ");
sbSql.append(" from tbl_int_measurement_validated a where a.pac_id = "+pacId+" and obx_measure = 'P/AS' ");
sbSql.append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "); sbSql.append(noAdmision); sbSql.append("))");
sbSql.append(" and trunc(obx_date) = to_date('"+fechaEval+"','yyyy-mm-dd') and status='P') d");
sbSql.append(" ON a.fechaHoja = d.fechaHoja");
sbSql.append("	LEFT JOIN ");
sbSql.append(" (select to_char(a.obx_date,'dd-mm-yyyy hh:mm:ss am') as fechaHoja, a.obx_measure_result AS PAD ");
sbSql.append(" from tbl_int_measurement_validated a where a.pac_id = "+pacId+" and obx_measure = 'P/AD' ");
sbSql.append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "); sbSql.append(noAdmision); sbSql.append("))");
sbSql.append(" and trunc(obx_date) = to_date('"+fechaEval+"','yyyy-mm-dd') and status='P') e");
sbSql.append(" ON a.fechaHoja = e.fechaHoja");
sbSql.append("	LEFT JOIN ");
sbSql.append(" (select to_char(a.obx_date,'dd-mm-yyyy hh:mm:ss am') as fechaHoja, a.obx_measure_result AS PAM ");
sbSql.append(" from tbl_int_measurement_validated a where a.pac_id = "+pacId+" and obx_measure = 'PAM' ");
sbSql.append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and secuencia = a.admision and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "); sbSql.append(noAdmision); sbSql.append("))");
sbSql.append(" and trunc(obx_date) = to_date('"+fechaEval+"','yyyy-mm-dd') and status='P') f");
sbSql.append(" ON a.fechaHoja = f.fechaHoja");

System.out.println(sbSql.toString());

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
	String[] serieLabel = {"PANISIS","PANIDIA","PANIMED","PAS","PAD","PAM"};
	double[] lower = {0, 0, 0, 0, 0, 0};
	double[] upper = {200, 200, 200, 200, 200, 200};
	Color[] color = {Color.RED, Color.BLUE, Color.GREEN, Color.BLACK, Color.MAGENTA, Color.ORANGE};
	boolean[] displaySeriesAxis = {true, true, true, true, true, true};
	boolean created = false; 
	
	try {
		created = chart.createChart(ConMgr.getConnection(), sbSql.toString(), domainLabel, serieLabel, lower, upper, color, displaySeriesAxis);
		chart.generateImage(java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/_"+pacId+chart.toString()+".png",1300,600);
	} catch(Exception up) {}
	
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
				<h4><i class="icon-reorder"></i>Resultados de Monitores (Presi&oacute;n Arterial)</h4>
				
				<div class="toolbar no-padding">
					<div class="btn-group">
						<span class="btn btn-xs widget-collapse" id="resultado-monitores-pa"><i class="icon-angle-up"></i></span>
						<span class="btn btn-xs widget-refresh refresh-it" data-url="../datawidgets/presion_arterial.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>" data-container="#resultados-monitores-pa-container" data-expander="#resultado-monitores-pa" data-type="full" data-chart="pa"><i class="icon-refresh"></i></span>
					</div>
				</div>
			</div>
						
			<div class="widget-content no-padding">
			<div class="input-group input-group-md">	
							<span class="datepicker" data-date-format="yyyy-MM-dd"><input  size="15" data-provide="datepicker" value='<%=fechaEval%>' name="fechaEval-pa" id="fechaEval-pa" type="date"></input></span>							
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