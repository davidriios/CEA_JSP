<%//@ page errorPage="../error.jsp"%>
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
String horario = request.getParameter("horario")==null?"":request.getParameter("horario");
String from = request.getParameter("from")==null?"":request.getParameter("from");
String _to = request.getParameter("to")==null?"":request.getParameter("to");
String fechaEval = request.getParameter("fechaEval")==null?"":request.getParameter("fechaEval");
String serveToRemote = request.getParameter("remoto") == null?"":request.getParameter("remoto");

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



if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	
	System.out.println("::::::::::::::::::::::::::::::::\nfechaEval="+fechaEval+"\n"+sbSql.toString());

	String image = "../images/image_not_found.jpg";
	if (created) image = "../pdfdocs/_"+pacId+chart.toString()+".png";
	
	if ( serveToRemote.trim().equals("Y") ){
		out.print(image);
	}else{
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Hoja Diabética - '+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="GRAFICA DE HOJA DIABETICA"></jsp:param>
  <jsp:param name="displayCompany" value="n"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td align="center"><img src="<%=image%>" ></td>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}
}//GET
%>