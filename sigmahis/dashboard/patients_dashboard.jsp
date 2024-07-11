<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoIO = new CommonDataObject();

String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String estado = request.getParameter("estado");

if (estado == null) estado = "";
if (pacId == null) pacId = "0";
if (admision == null) admision = "0";

if (request.getMethod().equalsIgnoreCase("GET")) {
	StringBuffer sbSql = new StringBuffer();
	sbSql.append("select trunc(sysdate) as today from dual");
	cdoIO = SQLMgr.getData(sbSql.toString());
	if (cdoIO == null) {
		cdoIO = new CommonDataObject();
		cdoIO.addColValue("today","");
	}
	
	CommonDataObject cdoP = (CommonDataObject) SQLMgr.getPacData(pacId, admision,",get_weight_height("+pacId+","+admision+",null) as weight_height, avatar",null,null);
	
	if (cdoP == null) cdoP = new CommonDataObject();
	
	
%>
<!DOCTYPE html>
<html lang="en">
<head>
<script  src="../js/ChartNew.js"></script>
<jsp:include page="common/dash_header.jsp" />
<script>
function doAction(){}

$(function(){
    $('#sidebar').css('width', '');
    $('#sidebar > #divider').css('margin-left', '');
    $('#content').css('margin-left', '');

    // Toggle class
    $('#container').addClass('sidebar-closed');
});

function formatAnnotateLabel(v1,v2,v3){
    var _suffix = "";
	if (v1=="Temp." ) _suffix = "°C";
	return '('+v2+' , '+v3+_suffix+')';
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
</head>
<body onLoad="javascript:doAction();">

	<!-- Header -->
	<header class="header navbar navbar-fixed-top" role="banner">
		<!-- Top Navigation Bar -->
		<div class="container">

			<!-- Only visible on smartphones, menu toggle -->
			<ul class="nav navbar-nav">
				<li class="nav-toggle"><a href="javascript:void(0);" title=""><i class="icon-reorder"></i></a></li>
			</ul>

			<!-- Logo -->
			<a class="navbar-brand">
			<img src="assets/img/logo.png" alt="logo" />
				<strong>CELLBYTE</strong>
			</a>
			<!-- /logo -->

			<!-- Sidebar Toggler -->
			<a href="#" class="toggle-sidebar bs-tooltip" data-placement="bottom" data-original-title="Toggle navigation">
				<i class="icon-reorder"></i>
			</a>
			<!-- /Sidebar Toggler -->

			<!-- Top Left Menu -->
			<ul class="nav navbar-nav navbar-left hidden-xs hidden-sm">

				 <li>
					<a href="#" class="dropdown-toggle row-bg-toggle">
						<i class="icon-resize-vertical"></i> 
						<%=cdoP.getColValue("nombre_paciente")%>
			(<%=cdoP.getColValue("identificacion")%>&nbsp;|&nbsp;<%=cdoP.getColValue("f_nac")%>&nbsp;|&nbsp;<%=cdoP.getColValue("edad")%>&nbsp;|&nbsp;Sexo:<%=cdoP.getColValue("sexo")%>&nbsp;<%=cdoP.getColValue("weight_height")%>&nbsp;|&nbsp;PID:<%=pacId%>-<%=admision%>)
					</a>
				</li>
			</ul>
			<!-- /Top Left Menu -->

			<!-- Top Right Menu -->
			<ul class="nav navbar-nav navbar-right">

				<!-- Notifications -->
				<!-- .row .row-bg Toggler 
				<li>
					<a href="#" class="dropdown-toggle row-bg-toggle">
						<i class="icon-resize-vertical"></i>
					</a>
				</li>
				<!-- User Company Dropdown -->
				<!--<li class="dropdown user">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown">
						<!--<img alt="" src="assets/img/avatar1_small.jpg" />
						<i class="icon-star-empty"></i>
						<span class="username">Company</span>
						<i class="icon-caret-down small"></i>
					</a>
					<ul class="dropdown-menu">
						<li><a href="pages_user_profile.html"><i class="icon-user"></i> Company Selected</a></li>
					</ul>
				</li>-->
				<!-- /user company dropdown -->
				<!-- User Login Dropdown -->
				<li class="dropdown user">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown">
						<i class="icon-male"></i>
						<span class="username"><%=session.getAttribute("_userCompleteName")%></span>
						<i class="icon-caret-down small"></i>
					</a>
					<ul class="dropdown-menu">
						<!--<li><a href="pages_user_profile.html"><i class="icon-user"></i> Company</a></li>
						<li class="divider"></li>-->
						<!--<li><a href="../logout.jsp"><i class="icon-key"></i> Log Out</a></li>-->
					</ul>
				</li>
				<!-- /user login dropdown -->
			</ul>
			<!-- /Top Right Menu -->
		</div>
		<!-- /top navigation bar -->

		
	</header> <!-- /.header -->

	<div id="container">
		<div id="sidebar" class="sidebar-fixed">
			<div id="sidebar-content">

				<!--=== Navigation ===-->
				<ul id="nav">
					<li class="current">
						<a href="quirofano_dashboard.jsp">
							<i class="icon-dashboard"></i>
							Dashboard Expediente
						</a>
					</li>
					<!--<li>
						<a href="javascript:void(0);">
							<span class="icon-stack">
							<i class="icon-check-empty icon-stack-base"></i>
							<i class="icon-user-md"></i>
							</span>
							SOP 
						</a>
					</li>	
					<li>
						<a href="javascript:void(0);">
							<span class="icon-stack">
							<i class="icon-check-empty icon-stack-base"></i>
							<i class="icon-h-sign"></i>
							</span>
							SALAS
						</a>
					</li>-->					
					
				</ul>
				
				

			</div>
			<div id="divider" class="resizeable"></div>
		</div>
		<!-- /Sidebar -->
		
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li>
							<i class="icon-home"></i>
							<a href="#">Dashboard</a>
						</li>
				</ul>
					
					<ul class="crumb-buttons">
						<li class="datepicker" data-date-format="mm/dd/yyyy"><a href="#">
							<i class="icon-calendar"></i>
							<span><input class="input-sm" data-provide="datepicker" value='<%=cdoIO.getColValue("today")%>' disabled></input></span>
							<!--<i class="icon-angle-down"></i>-->
						</a></li>
					</ul>
				</div>
				<!-- /Breadcrumbs line -->
				

				<!--=== Page Content ===-->
				<div class="row" style="margin-top: 10px">					
					<div class="col-md-12" id="pgc-container">
						<jsp:include page="../datawidgets/progreso_clinico.jsp" flush="true">
						  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
						  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
						</jsp:include>
					</div>
				</div>
				
				<div class="row">
					<div class="col-md-6" id="om-container">
						<jsp:include page="../datawidgets/ordenes_medicas.jsp" flush="true">
						  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
						  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
						</jsp:include>
					</div>
					
					<div class="col-md-6" id="resultados-monitores-pa-container">
						<jsp:include page="../datawidgets/presion_arterial.jsp" flush="true">
						  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
						  <jsp:param name="noAdmision" value="<%=admision%>"></jsp:param>
						</jsp:include>
					</div>
				</div>
				
				<div class="row">
					<div class="col-md-6" id="soapier-container">
						<jsp:include page="../datawidgets/nota_sopier_enfermera.jsp" flush="true">
						  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
						  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
						</jsp:include>
					</div>
					
					<div class="col-md-6" id="resultados-monitores-container">
						<jsp:include page="../datawidgets/resultados_monitores.jsp" flush="true">
						  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
						  <jsp:param name="noAdmision" value="<%=admision%>"></jsp:param>
						</jsp:include>
					</div>
				</div>
				
				
				<div class="row">
				 			
                <jsp:include page="../datawidgets/cond_actual_paciente.jsp?seccionId=-1&colSpanClass=col-md-3" flush="true">
                  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
                </jsp:include>
                
                <jsp:include page="../datawidgets/cond_actual_paciente.jsp?seccionId=1&colSpanClass=col-md-3" flush="true">
                  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
                </jsp:include>
                
                <jsp:include page="../datawidgets/cond_actual_paciente.jsp?seccionId=89" flush="true">
                  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
                </jsp:include>
                
                <jsp:include page="../datawidgets/cond_actual_paciente.jsp?seccionId=46" flush="true">
                  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
                </jsp:include>
                
                <jsp:include page="../datawidgets/cond_actual_paciente.jsp?seccionId=31" flush="true">
                  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
                </jsp:include>
                
                <jsp:include page="../datawidgets/cond_actual_paciente.jsp?seccionId=32" flush="true">
                  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
                </jsp:include>
                
                <jsp:include page="../datawidgets/cond_actual_paciente.jsp?seccionId=61" flush="true">
                  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
                </jsp:include>
                <jsp:include page="../datawidgets/cond_actual_paciente.jsp?seccionId=34" flush="true">
                  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
                </jsp:include>
                
                <jsp:include page="../datawidgets/cond_actual_paciente.jsp?seccionId=76" flush="true">
                  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
                </jsp:include>
                
                <jsp:include page="../datawidgets/cond_actual_paciente.jsp?seccionId=77&colSpanClass=col-md-12" flush="true">
                  <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                  <jsp:param name="admision" value="<%=admision%>"></jsp:param>
                </jsp:include>
           </div>	
				
				<!-- /Page Content -->
			</div>
			<!-- /.container -->

		</div>
	</div>
	
	<script>
	$(function(){
    $(document).on('click', '.refresh-it', function(e){
        var $self = $(this);
        var $loader = $self.children('.icon-refresh');
        var url = $self.data('url');
        var expander = $self.data('expander');
        var $container = $($self.data("container"));
        var $expander = $self.prev();
        
        var _i = $self.data("i");
        var remote = $self.data("remote");
        var remotePath = $self.data("remotepath");
        var horario = $self.data("horario");
        var seccionId = $self.data("seccionid");
        var type = $self.data("type");
        var chart = $self.data("chart");
		var fechaEval = $('#fechaEval-'+chart).val();
				
        if(remotePath) remotePath = remotePath.replace("@@HORARIO",horario).replace("@@PACID", <%=pacId%>).replace("@@ADMISION", <%=admision%>);
		
		if (fechaEval) url = url+'&fechaEval='+fechaEval

        $loader.addClass("icon-spin");
  
        if (url) {
          $.ajax({
            url: remote == 'remote' ? remotePath : url,
            method: 'GET',
          })
          .done(function(response){
            $loader.removeClass("icon-spin");
			            
            if (remote == 'remote') {
              if ($.trim(response).indexOf("image_not_found") >-1 ) $("#remote-container-"+seccionId+"-"+_i).hide();
              else $("#remote-"+seccionId+"-"+_i).attr("src", $.trim(response));
            } else {
				if (type == 'full') {
					$container.html($.trim(response));
				} else {
					$container.html($($.trim(response)).html());
				};
            }
			
			$(expander).click()
          })
          .fail(function(error){
              console.log("error = ", error);
          })
        } else $loader.removeClass("icon-spin");
        

    });
	});
	</script>
	
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
		   } else if (cDataArr[c].indexOf("SO-")>-1){
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
						 gTitle: "SATURACION OXIGENO (%)",
						 dTitle: "SO2"
						});
					}else $("#chartSO-"+_i).css({width:0,height:0});
			 }
		   
		}
	});
	
	$(".remote").each(function(i){
	   var $obj = $(this);
	   var _i = $obj.data("i");
	   var remotePath = $obj.data("remotepath");
	   var horario = $obj.data("horario");
	   var seccionId = $obj.data("seccionid");

	   remotePath = remotePath.replace("@@HORARIO",horario).replace("@@PACID", <%=pacId%>).replace("@@ADMISION", <%=admision%>);
	   	   
	   $.ajax({
			url: remotePath,
			cache: false,
			dataType: "html"
		}).done(function(data){
			if ($.trim(data).indexOf("image_not_found")>-1) $("#remote-container-"+seccionId+"-"+_i).hide();
			else $obj.attr("src", $.trim(data));
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
	   var docSecId = $(this).data("docsec");
	   var _docSecId = docSecId.split("@@");
	   var doc = _docSecId[0];
	   var sec = _docSecId[1];
	   var ptContainer = $("#plain-text-"+sec+"-"+i);
	   
     $.ajax({
        url: "../common/serve_dyn_content.jsp?serveTo=ESTADO_ACTUAL_PAC&tipo=P&documento="+doc+"&section="+sec+"&pacId=<%=pacId%>&noAdmision=<%=admision%>",
        method: 'GET',
     })
    .done(function(response){
      console.log(response)
    })
    .fail(function(error){
        console.log("error = ", error);
    }) 
    
    return
	   
	   data = $.trim(ajaxHandlerNoXtra("../common/serve_dyn_content.jsp?serveTo=ESTADO_ACTUAL_PAC","tipo=P&documento="+_docSecId[0]+"&section="+_docSecId[1]+"&pacId=<%=pacId%>&noAdmision=<%=admision%>"));
	   
	   console.log(data)
	   console.log(ptContainer)
	   
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
	  bezierCurve : true, 
	  responsive : true, 
	  maintainAspectRatio : true
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

</body>
</html>
<%}%>