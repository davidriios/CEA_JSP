<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.chart.TimeSeriesChart"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%

SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String dateFrom = request.getParameter("date_from");
String dateTo = request.getParameter("date_to");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
StringBuffer sb = new StringBuffer();
String company = (String) session.getAttribute("_companyId");

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (dateFrom == null) dateFrom = cDateTime;
if (dateTo == null) dateTo = cDateTime;

String dateCol = "to_date(to_char(fecha_signo,'dd/mm/yyyy')||' '||to_char(hora,'hh12:mi am'),'dd/mm/yyyy hh12:mi am')";

sb.append("select * from(");

sb.append(" select 'T-'||join(cursor(select to_char("+dateCol+",'DD/MM/YY HH24:MI')||'@@'||resultado from tbl_sal_detalle_signo z where exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and signo_vital in (get_sec_comp_param(");
sb.append(company);
sb.append(", 'SAL_REANIMACION_CARDIO_T') ) and pac_id = ");
sb.append(pacId);
sb.append(" and secuencia = ");
sb.append(noAdmision);
sb.append(" and ");
sb.append(dateCol);
sb.append(" between to_date('");
sb.append(dateFrom);
sb.append("','dd/mm/yyyy hh12:mi am') and to_date('");
sb.append(dateTo);
sb.append("','dd/mm/yyyy hh12:mi am') order by fecha_creacion ),',') as col_val from dual ");

sb.append(" union all select 'P-'||join(cursor(select to_char("+dateCol+",'DD/MM/YY HH24:MI')||'@@'||resultado from tbl_sal_detalle_signo z where exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and signo_vital in (get_sec_comp_param(");
sb.append(company);
sb.append(", 'SAL_REANIMACION_CARDIO_FC') ) and pac_id = ");
sb.append(pacId);
sb.append(" and secuencia = ");
sb.append(noAdmision);
sb.append(" and ");
sb.append(dateCol);
sb.append(" between to_date('");
sb.append(dateFrom);
sb.append("','dd/mm/yyyy hh12:mi am') and to_date('");
sb.append(dateTo);
sb.append("','dd/mm/yyyy hh12:mi am') order by fecha_creacion ),',') as col_val from dual ");

sb.append(" union all select 'R-'||join(cursor(select to_char("+dateCol+",'DD/MM/YY HH24:MI')||'@@'||resultado from tbl_sal_detalle_signo z where exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and signo_vital in (get_sec_comp_param(");
sb.append(company);
sb.append(", 'SAL_REANIMACION_CARDIO_FR') ) and pac_id = ");
sb.append(pacId);
sb.append(" and secuencia = ");
sb.append(noAdmision);
sb.append(" and ");
sb.append(dateCol);
sb.append(" between to_date('");
sb.append(dateFrom);
sb.append("','dd/mm/yyyy hh12:mi am') and to_date('");
sb.append(dateTo);
sb.append("','dd/mm/yyyy hh12:mi am') order by fecha_creacion ),',') as col_val from dual ");
// PAS/PAD 120/80
sb.append(" union all select 'PAS-'||join(cursor(select to_char("+dateCol+",'DD/MM/YY HH24:MI')||'@@'||decode(instr(resultado,'/'),0,resultado,substr(resultado,0,instr(resultado,'/') - 1)) from tbl_sal_detalle_signo z where exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and ( signo_vital in (get_sec_comp_param (");
sb.append(company);
sb.append(", 'SAL_REANIMACION_CARDIO_PA_S')) or (signo_vital in (get_sec_comp_param(");
sb.append(company);
sb.append(", 'SAL_REANIMACION_CARDIO_PA_D')) and instr(resultado,'/') > 0) ) and pac_id = ");
sb.append(pacId);
sb.append(" and secuencia = ");
sb.append(noAdmision);
sb.append(" and ");
sb.append(dateCol);
sb.append(" between to_date('");
sb.append(dateFrom);
sb.append("','dd/mm/yyyy hh12:mi am') and to_date('");
sb.append(dateTo);
sb.append("','dd/mm/yyyy hh12:mi am') order by fecha_creacion ),',') as col_val from dual ");

sb.append(" union all select 'PAD-'||join(cursor(select to_char("+dateCol+",'DD/MM/YY HH24:MI')||'@@'||decode(instr(resultado,'/'),0,resultado,substr(resultado,instr(resultado,'/') + 1)) from tbl_sal_detalle_signo z where exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and ( signo_vital in (get_sec_comp_param(");
sb.append(company);
sb.append(", 'SAL_REANIMACION_CARDIO_PA_D')) or (signo_vital in (get_sec_comp_param (");
sb.append(company);
sb.append(", 'SAL_REANIMACION_CARDIO_PA_S')) and instr(resultado,'/') > 0) ) and pac_id = ");
sb.append(pacId);
sb.append(" and secuencia = ");
sb.append(noAdmision);
sb.append(" and ");
sb.append(dateCol);
sb.append(" between to_date('");
sb.append(dateFrom);
sb.append("','dd/mm/yyyy hh12:mi am') and to_date('");
sb.append(dateTo);
sb.append("','dd/mm/yyyy hh12:mi am') order by fecha_creacion ),',') as col_val from dual ");

sb.append(")");

CommonDataObject cdoXtra = SQLMgr.getData("select join(cursor(select observacion from tbl_sal_detalle_orden_med where pac_id = "+pacId+" and secuencia = "+noAdmision+" and tipo_orden = 3 and tipo_dieta in (get_sec_comp_param("+company+", 'SAL_DIETA_LACTANCIA'))),' *** ') as lactancia, join(cursor(select observacion from tbl_sal_detalle_orden_med where pac_id = "+pacId+" and secuencia = "+noAdmision+" and tipo_orden = 3 and tipo_dieta in (get_sec_comp_param("+company+", 'SAL_DIETA_FORMULA_BEBE'))),' *** ') as formula_bb from dual");

if (cdoXtra == null) cdoXtra = new CommonDataObject();
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script  src="../js/ChartNew.js"></script>
<script>
		$(function() {
	$(".cData").each(function(i){
		var $cDataObj = $(this);
		var $cData = $cDataObj.text();
		var cDataArr = $cData.split("~");
		var cLabels = [];
		var cData = [];
				var cLabelsPA = [];
				var cDataS = [];
				var cDataD = [];

		for (c=0;c<cDataArr.length;c++){

			 if (cDataArr[c].indexOf("T-")>-1){
					var tData = cDataArr[c].split(",");
				for (d=0;d<tData.length;d++){
				var innerTdata = tData[d].split("@@");
				cLabels.push(innerTdata[0]);
				cData.push(innerTdata[1]);
				}

				//Temperatura
				if (cData[0]){
					drawChart({
					 gContainer: $("#chartT").get(0),
					 data: cData,
					 labels: cLabels,
					 gTitle: "TEMPERATURA",
					 dTitle: "Temp."
					});
				}else $("#chartT").css({width:0,height:0});
			 }
			 else if (cDataArr[c].indexOf("P-")>-1){
				var tData = cDataArr[c].split(",");
					cLabels = []; cData = [];
					for (d=0;d<tData.length;d++){
					var innerTdata = tData[d].split("@@");
					cLabels.push(innerTdata[0]);
					cData.push(innerTdata[1]);
					}

					//Pulso
					if (cData[0]){
						drawChart({
						 gContainer: $("#chartP").get(0),
						 data: cData,
						 labels: cLabels,
						 gTitle: "PULSO",
						 dTitle: "Pulso"
						});
					}else $("#chartP").css({width:0,height:0});
			 }
			 else if (cDataArr[c].indexOf("R-")>-1){
				var tData = cDataArr[c].split(",");
					cLabels = []; cData = [];
					for (d=0;d<tData.length;d++){
					var innerTdata = tData[d].split("@@");
					cLabels.push(innerTdata[0]);
					cData.push(innerTdata[1]);
					}

					//Respiración
					if (cData[0]){
						drawChart({
						 gContainer: $("#chartR").get(0),
						 data: cData,
						 labels: cLabels,
						 gTitle: "RESPIRACION",
						 dTitle: "Resp."
						});
					}else $("#chartR").css({width:0,height:0});
			 }
			 else if (cDataArr[c].indexOf("PAS-")>-1){
				var tData = cDataArr[c].split(",");
					cLabels = []; cDataS = [];
					for (d=0;d<tData.length;d++){
					var innerTdata = tData[d].split("@@");
					cLabelsPA.push(innerTdata[0]);
					cDataS.push(innerTdata[1]);
					}
			 }
					 else if (cDataArr[c].indexOf("PAD-")>-1){
				var tData = cDataArr[c].split(",");
					cLabels = []; cDataD = [];
					for (d=0;d<tData.length;d++){
					var innerTdata = tData[d].split("@@");
					cDataD.push(innerTdata[1]);
					}

					//Respiración
									if (cData[0]){
						drawChart({
						 gContainer: $("#chartPA").get(0),
						 data: [cDataS, cDataD],
						 labels: cLabelsPA,
						 gTitle: "PRESION ARTERIAL",
						 gType: "PASD",
						 dTitle: "PA"
						});
					}else $("#chartPA").css({width:0,height:0})
			 }

		}
	});


		// btn generar grafica
		$("#gen_chart").click(function(){
				var dateFrom = $("#date_from").val();
				var dateTo = $("#date_to").val();
				if (dateFrom && dateTo) window.location = '../expediente3.0/chart_signos_vitales.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&date_from='+dateFrom+'&date_to='+dateTo;
		});


 });

function drawChart(options){
	var ctx = options.gContainer.getContext("2d");
	var _options = {
		//multiGraph : true,
		canvasBorders : true,
		canvasBordersWidth : 1,
		canvasBordersColor : "black",
		graphTitle : options.gTitle,
		legend : true,
		inGraphDataShow : true,
		annotateDisplay : true,
		graphTitleFontSize: 18,
		annotateDisplay : true,
		annotateClassName: 'tooltip',
		annotateLabel : "<\%=formatAnnotateLabel(v1,v2,v3)%>",
		scaleShowLabels: true,
		scaleLabel:"<\%=value%>",
		bezierCurve : true
	};
	var _data = {
		labels: options.labels,
		datasets: [
			{
				fillColor: "rgba(220,220,220,0.2)",
				strokeColor: "rgba(220,220,220,1)",
				pointColor: "rgba(220,220,220,1)",
				pointStrokeColor: "#fff",
				pointHighlightFill: "#fff",
				pointHighlightStroke: "rgba(220,220,220,1)",
				data: options.data,
				title: options.dTitle
			}
		]
	};

	if (options.gType=="PASD"){
			var sys = [];
			var dias = [];
		_data.datasets = [];

				_data.datasets.push(
			{fillColor: "rgba(100,100,100,0.2)",
			strokeColor: "rgba(100,100,100,1)",
			pointColor: "rgba(100,100,100,1)",
			data: options.data[1],title: "Dias."}
		);

		_data.datasets.push(
			{fillColor: "rgba(220,220,220,0.2)",
			strokeColor: "rgba(220,220,220,1)",
			pointColor: "rgba(220,220,220,1)",
			data: options.data[0],title: "Sys."}
		);
	}

	var chart = new Chart(ctx).Line(_data, _options);
}

function formatAnnotateLabel(v1,v2,v3){
		var _suffix = "";
	if (v1=="Temp." ) _suffix = "°C";
		alert('('+v2+' , '+v3+_suffix+')')
	return '('+v2+' , '+v3+_suffix+')';
}
</script>

<style>
.tooltip{
	position: absolute;
	z-index: 9999;
	left: -9999px;
	word-wrap: break-word;
	max-width: 350px;
	padding: 0 0.2em;
	color: #fff;
	background: #333;
	border: 1px solid #aaa;
	border-radius: 4px 4px 4px 4px;
	box-shadow: 1px 2px 4px rgba(0,0,0,0.2), 0 0px 10px rgba(0,0,0,0.05) inset;
	}
</style>
</head>
<body class="body-form" style="padding-top:0px">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

		<table width="100%" class="table table-small-font table-bordered table-striped">
				<tr class="bg-headtabla">
					 <th>GR&Aacute;FICAS SIGNOS VITALES</th>
				</tr>
				<tr>
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="2"/>
										<jsp:param name="clearOption" value="true"/>
										<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
										<jsp:param name="nameOfTBox1" value="date_from"/>
										<jsp:param name="valueOfTBox1" value="<%=dateFrom%>"/>
										<jsp:param name="nameOfTBox2" value="date_to"/>
										<jsp:param name="valueOfTBox2" value="<%=dateTo%>"/>
								</jsp:include>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

								<button type="button" class="btn btn-inverse btn-sm" id="gen_chart">
										<i class="fa fa-chart fa-lg"></i> <cellbytelabel>Generar</cellbytelabel>
								</button>

						</td>
				</tr>

				<%
						ArrayList alD = SQLMgr.getDataList(sb.toString());
						String res = "";
						for (int d=0;d<alD.size();d++){
								CommonDataObject cdoD = (CommonDataObject) alD.get(d);
								res += cdoD.getColValue("col_val")+"~";
						}
				%>
				<span class="qry" id="qry" style="display:none"><%=sb.toString()%></span>
				<span class="cData" id="cData" style="display:none"><%=res%></span>
				<tr>
						<td>
								<table border="1" width="100%" id="chart-container" class="chart-container">
								<tr>
										<td align="center"><canvas id="chartT" width="650" height="350" style=""></canvas></td>
										<td align="center"><canvas id="chartP" width="650" height="350" style=""></canvas></td>
								</tr>
								<tr>
										<td align="center"><canvas id="chartR" width="650" height="350" style=""></canvas></td>
										<td align="center"><canvas id="chartPA" width="650" height="350" style=""></canvas></td>
								</tr>
								</table>
						</td>
				</tr>

				<tr>
						<td><b>LACTANCIA MATERNA:</b>&nbsp;&nbsp;<%=cdoXtra.getColValue("lactancia"," ")%></td>
				</tr>
				<tr>
						<td><b>FORMULA DE BEBE:</b>&nbsp;&nbsp;<%=cdoXtra.getColValue("formula_bb"," ")%></td>
				</tr>






		</table>

</div>
</div>
</body>