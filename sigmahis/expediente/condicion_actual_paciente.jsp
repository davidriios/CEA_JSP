<%@ page import="issi.admin.CommonDataObject"%>
<%
issi.admin.ConnectionMgr ConMgr = new issi.admin.ConnectionMgr();
issi.admin.SQLMgr SQLMgr = new issi.admin.SQLMgr();
String pacId=request.getParameter("pacId")==null?"":request.getParameter("pacId");
String noAdmision=request.getParameter("noAdmision")==null?"":request.getParameter("noAdmision");
String fp=request.getParameter("fp")==null?"":request.getParameter("fp");
SQLMgr.setConnection(ConMgr);
java.util.ArrayList al = SQLMgr.getDataList("select r.seccion_desc, r.documento_id, r.tipo, r.documento_id||'|'||r.seccion_id as doc_sec_id, seccion_tabla, seccion_columnas, seccion_where_clause, ultimos_n_registros, ultimos_x_registros, seccion_order_by from tbl_sal_secciones_resumen r where r.estado = 'A' order by orden");
%>
<!DOCTYPE html>
<html>
<head>
<script>
	$(function() {
	$(".cData").each(function(i){
		var $cDataObj = $(this);
		var _i = $cDataObj.data("i");
		var $cData = $cDataObj.text();
		var cDataArr = $cData.split("~");
		var cLabels = [];
		var cData = [];
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
					 gContainer: $("#chartT-"+_i).get(0),
					 data: cData,
					 labels: cLabels,
					 gTitle: "TEMPERATURA",
					 dTitle: "Temp."
					});
				}else $("#chartT-"+_i).css({width:0,height:0});
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
						 gContainer: $("#chartP-"+_i).get(0),
						 data: cData,
						 labels: cLabels,
						 gTitle: "PULSO",
						 dTitle: "Pulso"
						});
					}else $("#chartP-"+_i).css({width:0,height:0});
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
						 gContainer: $("#chartR-"+_i).get(0),
						 data: cData,
						 labels: cLabels,
						 gTitle: "RESPIRACION",
						 dTitle: "Resp."
						});
					}else $("#chartR-"+_i).css({width:0,height:0});
			 }
			 else if (cDataArr[c].indexOf("PA-")>-1){
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
						 gContainer: $("#chartPA-"+_i).get(0),
						 data: cData,
						 labels: cLabels,
						 gTitle: "PRESION ARTERIAL",
						 gType: "PA",
						 dTitle: "PA"
						});
					}else $("#chartPA-"+_i).css({width:0,height:0})
			 }
			 else if (cDataArr[c].indexOf("SO-")>-1){
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
						 gContainer: $("#chartSO-"+_i).get(0),
						 data: cData,
						 labels: cLabels,
						 gTitle: "SATURACION OXIGENO",
						 dTitle: "SO2"
						});
					}else $("#chartSO-"+_i).css({width:0,height:0});
			 }

		}
	});


	$(".remote").each(function(i){
		 var $obj = $(this);
		 var _i = $obj.data("i");
		 var remotePath=$obj.data("remotepath");
		 var horario=$obj.data("horario");

		 remotePath = remotePath.replace("@@HORARIO",horario).replace("@@PACID", <%=pacId%>).replace("@@ADMISION", <%=noAdmision%>);

		 $.ajax({
			url: remotePath,
			cache: false,
			dataType: "html"
		}).done(function(data){
			if ($.trim(data).indexOf("image_not_found")>-1) $("#remote-container-"+_i).remove();
			else $obj.attr("src",$.trim(data));
		}).fail(function(jqXHR, textStatus){
			alert("La request has fallido: " + textStatus);
		});
	});

	//toggle
	$(".section").click(function(){
		 var $obj = $(this);
		 var _i = $obj.data("i");
		 var tipo = $obj.data("tipo");
		 var remote = $obj.data("remote");
		 var content;

		 if (tipo=="P") content = $("#plain-text-"+_i);
		 else if (tipo=="C" && remote == false) content = $("#chart-container-"+_i);
		 else if (remote==true) content = $("#remote-container-"+_i)

		 if (content.length)content.toggle();
	});

	//show more data
	$(".show-more").click(function(){
		 var i = $(this).data("i");
		 var ptContainer = $("#plain-text-"+i);
		 var docSecId = $(this).data("docsec");
		 var _docSecId = docSecId.split("|");

		 data = $.trim(ajaxHandlerNoXtra("../common/serve_dyn_content.jsp?serveTo=ESTADO_ACTUAL_PAC","tipo=P&documento="+_docSecId[0]+"&section="+_docSecId[1]+"&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>"));

		 if (data){
				var datas = (data.toString()).split(/<br\s*\/\>/);
			$(ptContainer).find('li').remove();
			for (i=0;i< datas.length; i++){
			var li = $('<li></li>').html(datas[i]);
			ptContainer.append(li);
			}
		 }
	});
 });

//formatAnnotateLabel(v1,v2,v3)
function drawChart(options){
	var ctx = options.gContainer.getContext("2d");
	var _options = {
		//multiGraph : true,
		canvasBorders : true,
		canvasBordersWidth : 3,
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

	if (options.gType=="PA"){
			var sys = [];
			var dias = [];
		_data.datasets = [];
		for (p=0;p<options.data.length;p++){
				if (options.data[p]){
			var pa = options.data[p].split("/");
			sys.push(pa[0]);
			dias.push(pa[1]);
			}
		}
		_data.datasets.push(
			{fillColor: "rgba(220,220,220,0.2)",
			strokeColor: "rgba(220,220,220,1)",
			pointColor: "rgba(220,220,220,1)",
			data: sys,title: "Sys."}
		);
		_data.datasets.push(
			{fillColor: "rgba(100,100,100,0.2)",
			strokeColor: "rgba(100,100,100,1)",
			pointColor: "rgba(100,100,100,1)",
			data: dias,title: "Dias."}
		);
	}

	var chart = new Chart(ctx).Line(_data, _options);
}
</script>
<style>
#content{
	float:left;
	text-align:left;
	overflow: scroll;
	height:100%;
	width: 100%;
	margin:0 auto;
	position: relative;
}

#tabs{
border: red solid 1px;
float:left;
display:none;
text-align:left;
}

.ui-tabs-vertical { width: 100%; }
.ui-tabs-vertical .ui-tabs-nav { padding: .2em .1em .2em .2em; float: left; width:20% }
.ui-tabs-vertical .ui-tabs-nav li { clear: left; width: 100%; border-bottom-width: 1px !important; border-right-width: 0 !important; margin: 0 -1px .2em 0; }
.ui-tabs-vertical .ui-tabs-nav li a { display:block; }
.ui-tabs-vertical .ui-tabs-nav li.ui-tabs-active { padding-bottom: 0; padding-right: .1em; border-right-width: 1px; border-right-width: 1px; }
.ui-tabs-vertical .ui-tabs-panel { padding: 1em; float: left; border: blue 2px solid; text-align:left; width:80%}
</style>
<body>
<div id="content" style="">


	<%
		for (int i = 1; i<=al.size();i++){
			CommonDataObject cdo = (CommonDataObject)al.get(i-1);
			StringBuffer sbSql=new StringBuffer();

			String dateField = "",_where=(cdo.getColValue("seccion_where_clause")).replaceAll("@@PACID",pacId).replaceAll("@@ADMISION",noAdmision), xtraWhere = "";
			String[] limit={};


			if ((cdo.getColValue("seccion_where_clause")).contains("DATE_FIELD")){
				limit = (cdo.getColValue("ultimos_x_registros")).split(" ");
				String limitType = limit[1];
				dateField = _where.substring( _where.lastIndexOf("-")+1,_where.length() );
				//_where = _where.replaceAll("@@DATE_FIELD-"+dateField," and "+dateField);
				_where = _where.replaceAll("@@DATE_FIELD-"+dateField," ");

				if (limitType.equalsIgnoreCase("d")){
					 _where += " and trunc("+dateField+")>=sysdate-"+limit[0];
				}else {
					 String _interval = limitType.equalsIgnoreCase("m")?"minute":"hour";
					 _where += " and "+dateField+" >= sysdate-(interval '"+limit[0]+"' "+_interval+")";
				}
			}

			if (cdo.getColValue("ultimos_n_registros")!=null&&!cdo.getColValue("ultimos_n_registros").trim().equals("")){
				_where += " and rownum <= nvl("+cdo.getColValue("ultimos_n_registros")+",0)";
			}else if (cdo.getColValue("ultimos_x_registros")!=null&&!cdo.getColValue("ultimos_x_registros").trim().equals("")){}

			if (!cdo.getColValue("seccion_columnas").contains("READY")){
			System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: NO READY");
			System.out.println(cdo.getColValue("seccion_columnas").replaceAll("@@PACID",pacId).replaceAll("@@ADMISION",noAdmision));
			sbSql.append("select ");
			sbSql.append(cdo.getColValue("seccion_columnas").replaceAll("@@PACID",pacId).replaceAll("@@ADMISION",noAdmision));
			sbSql.append(" from ");
			sbSql.append(cdo.getColValue("seccion_tabla"));
			sbSql.append(" where ");

			sbSql.append(_where);
			if (cdo.getColValue("seccion_order_by")!=null && !cdo.getColValue("seccion_order_by").trim().equals(""))
				sbSql.append(" order by "+cdo.getColValue("seccion_order_by"));
			}else{
			sbSql = new StringBuffer();
				sbSql.append("select * from(");
			sbSql.append(cdo.getColValue("seccion_columnas").replaceAll("READY@@","").replaceAll("@@PACID",pacId).replaceAll("@@ADMISION",noAdmision).replaceAll("@@XTRA_WHERE"," and "+_where));
			sbSql.append(" ) ");
			}

			try{
			java.util.ArrayList alD = new java.util.ArrayList();
			if (!cdo.getColValue("seccion_columnas").equalsIgnoreCase("remote"))
				 alD= SQLMgr.getDataList(sbSql.toString());
			String res = "";
			for (int d=0;d<alD.size();d++){
			CommonDataObject cdoD = (CommonDataObject) alD.get(d);

				String showMore = "";
			if(cdo.getColValue("tipo").equals("P")){
				 if ( (d+1) == alD.size() ) showMore = " <span class='Link00Bold pointer show-more' id='show-more-"+i+"' data-i='"+i+"' data-docsec='"+cdo.getColValue("doc_sec_id")+"'>[+]</span>";
				 res += "<li>"+cdoD.getColValue("col_val")+showMore+"</li>";
			}else{
				 res += cdoD.getColValue("col_val")+"~";
			}
			}


		%>
		<strong class="section pointer" data-i="<%=i%>" data-tipo="<%=cdo.getColValue("tipo")%>" data-remote="<%=cdo.getColValue("seccion_columnas").equalsIgnoreCase("remote")%>"><span style="background:url(../images/eap_info.png) no-repeat 0 0 / 24px 24px; float:left; width:24px; height:24px;margin-top:1px"></span><%=cdo.getColValue("seccion_desc")%></strong><br />
		<%if(cdo.getColValue("tipo").equals("P")){%>
			<ul id="plain-text-<%=i%>" class="plain-text"><%=res%></ul>
		<%}else if(cdo.getColValue("seccion_columnas").equalsIgnoreCase("remote")){%>
			<div style="text-align:center" id="remote-container-<%=i%>">
			<img src="" class="remote" id="remote-<%=i%>" alt="<%=cdo.getColValue("seccion_desc")%>" title="<%=cdo.getColValue("seccion_desc")%>" data-i="<%=i%>" data-remotepath="<%=cdo.getColValue("seccion_where_clause")%>" data-horario="<%=cdo.getColValue("ultimos_x_registros")%>"/>
			</div>
		<%}else{%>
		<span class="cData" id="cData<%=i%>" data-i="<%=i%>" style="display:none"><%=res%></span>
		<table border="1" width="100%" id="chart-container-<%=i%>" class="chart-container">
			<tr>
				<td align="center"><canvas id="chartT-<%=i%>" width="600" height="300" style=""></canvas></td>
				<td align="center"><canvas id="chartP-<%=i%>" width="600" height="300" style=""></canvas></td>
			</tr>
			<tr>
				<td align="center"><canvas id="chartR-<%=i%>" width="600" height="300" style=""></canvas></td>
				<td align="center"><canvas id="chartPA-<%=i%>" width="600" height="300" style=""></canvas></td>
			</tr>
			<tr>
				<td align="center" colspan="2"><canvas id="chartSO-<%=i%>" width="1200" height="300" style=""></canvas></td>
			</tr>
		</table>
		<%}%>
<%
}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::: Error while "+e);e.printStackTrace();}
}%>
</div>
</body>
</html>