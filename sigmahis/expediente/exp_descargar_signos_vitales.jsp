<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.SignoPacienteTmp"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="SPMgr" scope="page" class="issi.expediente.SignoPacienteMgr"/>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SPMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alU = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

String sql = "";
String mode = request.getParameter("mode");
String action = request.getParameter("action") == null?"":request.getParameter("action");

String tempSaved = request.getParameter("tempSaved") == null?"":request.getParameter("tempSaved");
String serialNumber = request.getParameter("serialNumber") == null?"":request.getParameter("serialNumber");
String deviceId = request.getParameter("deviceId") == null?"":request.getParameter("deviceId");
boolean viewMode = false;

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view"))viewMode = true;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (tempSaved.trim().equals("Y")){

	al = SQLMgr.getDataList("select c.id, c.pac_id, c.admision,c.reading,nvl(c.bmi,' ') bmi,c.clinicianid ,to_char(c.reading_date,'dd/mm/yyyy hh12:mi:ss am') fecha,nvl(c.diastolic,0) diastolic,nvl(c.height,' ') height,nvl(c.hr,' ') hr,nvl(c.map,' ') map,nvl(c.o2sat,' ') o2sat,nvl(c.pain,0) pain,nvl(c.patientid,' ') patientid,nvl(c.pulse,' ') pulse,nvl(c.respiration,' ') respiration,nvl(c.systolic,0) systolic,nvl(c.temperature,' ') temperature,nvl(c.weight,' ') weight,nvl(c.serialnumber,' ') serialnumber,nvl(c.device_json,' ') device_json, nvl(c.device_id,'0') deviceId, nvl(p.nombre_paciente,'PACIENTE NO ESTA EN SISTEMA') as nombre_paciente, decode(c.pac_id,0,'N','Y') as can_be_sent_to_exp, p.codigo as cod_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento from tbl_int_connex c, vw_adm_paciente p where c.serialnumber = '"+serialNumber+"' and c.device_id = '"+deviceId+"' and c.pac_id = p.pac_id(+) and not exists (select null from tbl_sal_detalle_signo z where pac_id = c.pac_id and admision = c.admision and c.reading_date = fecha_signo and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A'))  order by c.pac_id, c.admision");

	mode = "edit";

}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){}
	else{}
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script src="../js/jsviews.js"></script>
<script src="../js/noty/packaged/jquery.noty.packaged.min.js"></script>
<script>
document.title = 'Descaga Signos Vitales - '+document.title;

function showNoty(msg, _type)
{
	var n = noty({
	 text: msg
	 ,type: _type ? _type : 'info'
	 ,killer: true
	 ,timeout:3000
 });
}

$(function(){

	 var tempSaved = "<%=tempSaved%>";
	 var deviceData = getDeviceData("GetDevices");

	 var xTmpp = deviceData;

	 var pos = xTmpp.toLowerCase().indexOf("internal error");
	 if (pos) deviceData = null;

	 deviceData = $.parseJSON(deviceData);

	 if (!deviceData){

		$(".device-status-box").removeClass("device-connected").addClass("device-disconnected");
		$("#not-connected-hint").addClass("hint hint--top").attr("data-hint","Doble clic para re-detectar");

		$("#get_device").dblclick(function(){
			window.location.reload(true);
		});

	 }else {
		params = 'deviceId='+deviceId;

			$(".device-status-box").removeClass("device-disconnected").addClass("device-connected");

		var deviceTmpl = $.templates("#deviceTmpl");
		var html = deviceTmpl.render(deviceData);
		var deviceId = deviceData[0].deviceid;
		var serialNumber = deviceData[0].serialnumber;

		$("#device-descrip").html(html);

		if (deviceId){

		//Erasing
		$("#get-erase").click(function(){
			 var _erase;
			 try{
				 _erase = getDeviceData("EraseCycleData",params);
			 window.location = "../expediente/exp_descargar_signos_vitales.jsp?action=del";
			 }catch(e){
				 alert("Error al tratar de borrar los datos del Dispositivo!");
			 }
		});

			//Reading data
		$("#get_readings").click(function(){

			 if (!tempSaved){
				 var _saveToTmp;
				 $.views.converters({
					pacId: function(value) {
						return parseInt(value.substr(0,10),10);
					},
					noAdmision: function(value) {
						return parseInt(value.substr(10),10);
					},
					fecha: function(value) {
						return value.replace(/T/,' ');
					},
					getPacData: function(value) {
						return "";
						//getDBData('<%=request.getContextPath()%>',"nombre_paciente||', '||p.id_paciente",' vw_adm_paciente p',"p.pac_id = "+parseInt(value.substr(0,10),10), '');
					}
				});

				 var $form = $("<form id='form0' method='POST' action='<%=request.getContextPath()+request.getServletPath()%>'>");
				 $form.append("<input type='hidden' name='device_json' id='device_json' value='"+JSON.stringify(deviceData)+"'/><input type='hidden' name='serialNumber' id='serialNumber' value='"+serialNumber+"'/><input type='hidden' name='deviceId' id='deviceId' value='"+deviceId+"'/></form>");

				 var data = {"readings" : $.parseJSON(getDeviceData("GetReadings",params))};

				 if (data.readings){
					 var _readingsHtml = $("#readingTmpl").render(data);

					 $form.append(_readingsHtml);

					 $("#readingContainer").html($form);

					 _saveToTmp = "Y";

				 }else{
					 showNoty('No hay data para bajar!','error');
				 }

				 if (_saveToTmp == "Y"){

					$.ajax({
						type: "POST",
						url: "../expediente/exp_descargar_signos_vitales.jsp",
						data: $("#form0").serialize()
					})
					.done(function( msg ) {
					showNoty("Datos analizados satifactoriamente!");
					window.location = "../expediente/exp_descargar_signos_vitales.jsp?tempSaved=Y&serialNumber="+serialNumber+"&deviceId="+deviceId;
					}).fail(function(jqXHR) {
					showNoty("["+jqXHR.status +"] "+ jqXHR.statusText);
					});


				 }


			 }
		});

		$("#readingContainer").on("click", ".check", function(){
			var $thisCheck = $(this);
			var ind = $thisCheck.val();
			if ($thisCheck.is(":checked")){
				var pacId = $("#pacId"+ind).val();
				var noAdmision = $("#noAdmision"+ind).val();

				var d = getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision a',"a.estado not in('N','P') and a.pac_id = "+pacId+" and a.secuencia = "+noAdmision, '');

				if (d == 0) {
					 $thisCheck.prop("checked",false);
					 showNoty('Paciente no existe en CellByte!','error');
				}
			}
		});

		//Creating mouse over/out
		$("#readingContainer")
		.on("mouseover", ".ooo", function(e){
		 e.stopImmediatePropagation();
		 $(this).addClass("TextRowOver");
		})
		.on("mouseout", ".ooo", function(e){
		 e.stopImmediatePropagation();
		 $(this).removeClass("TextRowOver");
		});


		//Uploading data to cellbyte
		$("#get-save").click(function(){

			var cnt = 0;

			jQuery($( "input[name^='can_be_sent_to']" )).each(function(){
			 if($(this).val() == "Y") cnt++;
			});

		 if(cnt) {
			$("#form0").submit();
		 }else {
			showNoty('Por favor seleccione por lo menos una toma!','error')
		 }
		});


		//Uploading data to cellbyte
		$(".associate").click(function(e){
		e.stopImmediatePropagation();
		var _this = $(this);
		var i = _this.data("i");
		var p = $("#pacId"+i).val();
		abrir_ventana("../common/search_paciente.jsp?fp=CONNEX&index="+i);
		});

	} // devideid
	} //else

});

function getDeviceData(action, params){
	 var _params = params ? params : null;
	 return ajaxHandlerNoXtra("<%=request.getContextPath()%>/connex?action="+action,params,'GET');
}

function getDeviceDataold(action, deviceId){
	 var _deviceId = deviceId ? deviceId : "";
	 var res;

	 $.get("<%=request.getContextPath()%>/connex",{'action':action,'deviceId':_deviceId})
	.done(function( msg ) {
		res = "e"
	})
	.fail(function(r, m) {
		showNoty("["+r.status+"] Error interno. Por favor contacte un administrador",'error')
	});
	return res;
}

function testGetDevices(){
	return [{"deviceid":"USB_00000002","date":"2014-09-27T16:07:17","firmware":"1.71.02","heightdisplayunit":"UNITS_INCHES","location":"","modelname":"PMP","modelnumber":"VSM 6000 Series","nibpdisplayunit":"NIBP_MMHG","serialnumber":"103000684212","tempdisplayunit":"DEG_F","weightdisplayunit":"UNITS_LBS"}];
}


function testGetReadings(){
	return [{
	"reading": "1",
	"bmi": null,
	"clinicianid": "1234",
	"date": "2014-09-25T17:08:37",
	"diastolic": "98.43",
	"height": "1.90",
	"hr": "109",
	"map": "113.05",
	"o2sat": "80",
	"pain": null,
	"patientid": "0000000249001",
	"pulse": "110",
	"respiration": "60",
	"systolic": "142.3",
	"temperature": "36",
	"weight": "60lb"
	},
	{
	"reading": "4",
	"bmi": null,
	"clinicianid": "1234",
	"date": "2014-09-25T17:30:33",
	"diastolic": "94.43",
	"height": "1.90",
	"hr": "107",
	"map": "120.05",
	"o2sat": "70",
	"pain": null,
	"patientid": "0000000249001",
	"pulse": "112",
	"respiration": "70",
	"systolic": "140.3",
	"temperature": "37",
	"weight": "60lb"
	},
	{
	"reading": "2",
	"bmi": null,
	"clinicianid": "4567",
	"date": "2014-09-25T17:13:02",
	"diastolic": "41.53",
	"height": "1.78",
	"hr": "111",
	"map": "69.92",
	"o2sat": "67",
	"pain": null,
	"patientid": "0000000138007",
	"pulse": "56",
	"respiration": "90",
	"systolic": "120.72",
	"temperature": "38",
	"weight": "45lb"
	},
	{
	"reading": "3",
	"bmi": null,
	"clinicianid": "4758",
	"date": "2014-09-01T15:10:05",
	"diastolic": "45.53",
	"height": "1.76",
	"hr": "111",
	"map": "65.03",
	"o2sat": "67",
	"pain": null,
	"patientid": "0000000000000",
	"pulse": "56",
	"respiration": "90",
	"systolic": "132.72",
	"temperature": "35",
	"weight": "40lb"
	}];
}

</script>

<style>

	.box-container{
		float: left;
	background-color: #fff;
	margin: 0.5%;
	width: 8.01%;
	position: relative;
	min-width: 120px;
	}

	.box-img-container{
		display: table-cell;
	text-align: center;
	border-radius: 0;
	box-shadow: none;
	color: #626262;
	cursor: pointer;
	width: 100%;
	background-repeat: no-repeat;
	background-position: center center;
	background-size: 40% auto;
	height: 113px;
	position: relative;
	vertical-align: middle;
	margin: auto;
	}

	.device-status-box{
		position: absolute;
	left: 0;
	top: 0;
	bottom: 0;
	width: 32px;
	height: 32px;
	}
	.device-connected{
		background:url('../images/usb_connected.png') no-repeat -20px;
	}
	.device-disconnected{
		background:url('../images/usb_disconnected.png') no-repeat -20px;
	}
	.device-descrip{
		 position:absolute; left:0; right:0; bottom:0; height:19px; font-size:10px;overflow:hidden; width:100%;white-space: nowrap;text-overflow: ellipsis; font-weight:bold;display: inline-block;
	}

	#device-info{}

	.step{
		position: absolute;
	right: 0;
	top: 0;
	bottom: 0;
	color: #CEC810;
	font-weight:bold;
	font-size:1.8em;
	}
	.tmp-alert{width:24px; height:24px;}
	.tmp-alert-good{background: url(../images/good.png) no-repeat center;background-size: 16px 16px;}
	.tmp-alert-bad{background: url(../images/bad.png) no-repeat center;background-size: 24px 24px;}
	.hint{display:block;}
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DESCARGA SIGNOS VITALES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0" >

	 <tr>
		 <td class="TableBorder">

			<div id="container" style="margin-top:5px; background-color: #e6e6e6; text-align:center">

				<script id="deviceTmpl" type="text/x-jsrender">
				{{:deviceid}}
			</script>

			<div class="box-container">
				<div class="device-status-box"></div>

				<div id="device-info" style="display:table;width:100%;">
					<div id="get_device" class="box-img-container">
						<span id="not-connected-hint">
							<img src="../images/connex_monitor.png" style="max-height: 65px;"/>
						</span>
					</div>

					<div class="device-descrip" id="device-descrip"></div>
				</div>

						<div class="step" id="step">1</div>

			</div>

			<div class="box-container">
				<div id="" style="display:table;width:100%;">
					<div id="get_readings" class="box-img-container">
						<span class="hint hint--bottom" data-hint="Ver datos del dispositivo">
							<img src="../images/device_data_list.png" style="max-height: 65px;"/>
						</span>
					</div>
				</div>
				<div class="step" id="step">2</div>
			</div>

			<div class="box-container">
				<div id="" style="display:table;width:100%;">
					<div id="get-save" class="box-img-container">
						<span class="hint hint--bottom" data-hint="Agregar datos al sistema">
							<img src="../images/download_device_data.png" style="height: 65px;"/>
						</span>
					</div>
				</div>
				<div class="step" id="step">3</div>
			</div>

			<!--<div class="box-container">
				<div id="" style="display:table;width:100%;">
					<div id="get-erase" class="box-img-container">
						<span class="hint hint--bottom" data-hint="Borrar datos del dispositivo">
							 <img src="../images/erase_device_data.png" style="height: 65px;"/>
						</span>
					</div>
				</div>
			</div>-->

			<div style="clear:both"></div>
			</div>

	 </td>
	 </tr>

	 <%if(al.size()>0){%>
	 <tr>

		<td class="TableBorder" colspan="3">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

			<form id='form0' method='POST' action='<%=request.getContextPath()+request.getServletPath()%>'>
			<input type="hidden" name="size" id="size" value="<%=al.size()%>">
			<input type="hidden" name="tempSaved" id="tempSaved" value="<%=tempSaved%>">
			<input type="hidden" name="serialNumber" id="serialNumber" value="<%=serialNumber%>">
			<input type="hidden" name="deviceId" id="deviceId" value="<%=deviceId%>">
			<%
			String group = "";
			for(int i=1; i<=al.size(); i++){
				 cdo = (CommonDataObject)al.get(i-1);
				 String color = i%2==0?"TextRow02":"TextRow01";
				 String _xtraClass = "";
				 String tmpAlert = "tmp-alert tmp-alert-good";
				 if (cdo.getColValue("can_be_sent_to_exp").equals("N")){
						 tmpAlert = "tmp-alert tmp-alert-bad";
					 _xtraClass = "class='associate pointer hint hint--left' data-hint='Por favor asociar un paciente' data-i='"+i+"'";
				 }
			%>

					<input type="hidden" name="pacId<%=i%>" id="pacId<%=i%>" value="<%=cdo.getColValue("pac_id")%>">
					<input type="hidden" name="noAdmision<%=i%>" id="noAdmision<%=i%>" value="<%=cdo.getColValue("admision")%>">
					<input type="hidden" name="fecha<%=i%>" id="fecha<%=i%>" value="<%=cdo.getColValue("fecha")%>">
					<input type="hidden" name="categoria<%=i%>" id="categoria<%=i%>" value="3">
					<input type="hidden" name="pain<%=i%>" id="pain<%=i%>" value="<%=cdo.getColValue("pain")%>">
					<input type="hidden" name="reading<%=i%>" id="reading<%=i%>" value="<%=cdo.getColValue("reading")%>">
					<input type="hidden" name="bmi<%=i%>" id="bmi<%=i%>" value="<%=cdo.getColValue("bmi")%>">
					<input type="hidden" name="diastolic<%=i%>" id="diastolic<%=i%>" value="<%=cdo.getColValue("diastolic")%>">
					<input type="hidden" name="systolic<%=i%>" id="systolic<%=i%>" value="<%=cdo.getColValue("systolic")%>">
					<input type="hidden" name="patientid<%=i%>" id="patientid<%=i%>" value="<%=cdo.getColValue("patientid")%>">
					<input type="hidden" name="map<%=i%>" id="map<%=i%>" value="<%=cdo.getColValue("map")%>">
					<input type="hidden" name="hr<%=i%>" id="hr<%=i%>" value="<%=cdo.getColValue("hr")%>">
					<input type="hidden" name="clinicianid<%=i%>" id="clinicianid<%=i%>" value="<%=cdo.getColValue("clinicianid")%>">
					<input type="hidden" name="fecha_nacimiento<%=i%>" id="fecha_nacimiento<%=i%>" value="<%=cdo.getColValue("fecha_nacimiento")%>">
					<input type="hidden" name="cod_paciente<%=i%>" id="cod_paciente<%=i%>" value="<%=cdo.getColValue("cod_paciente")%>">
					<input type="hidden" name="can_be_sent_to_exp<%=i%>" id="can_be_sent_to_exp<%=i%>" value="<%=cdo.getColValue("can_be_sent_to_exp")%>">
					<input type="hidden" name="upt_tmp<%=i%>" id="upt_tmp<%=i%>" value="">

				<%if(!group.equals(cdo.getColValue("pac_id") + "-" + cdo.getColValue("admision"))){%>
					<tr class="TextHeader">
						<td colspan="15">Paciente: [<span id="pacIdLbl<%=i%>"><%=cdo.getColValue("pac_id")%></span>-<span id="noAdmisionLbl<%=i%>"><%=cdo.getColValue("admision")%></span>]&nbsp;<span id="pacNameLbl<%=i%>"><%=cdo.getColValue("nombre_paciente")%></span></td>
					</tr>
				<%}%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>Temp.</td>
					<td><input type="text" name="temperature<%=i%>" value="<%=cdo.getColValue("temperature")%>" readonly="readonly" style="width:40px"></td>
					<td>Pulso</td>
					<td> <input type="text" name="pulse<%=i%>" value="<%=cdo.getColValue("pulse")%>" readonly="readonly" style="width:40px">  </td>
					<td>P/A</td>
					<td> <input type="text" name="blood_pressure<%=i%>" value="<%=cdo.getColValue("systolic")%>/<%=cdo.getColValue("diastolic")%>" readonly="readonly" style="width:100px">  </td>

					<td>SatO2</td>
					<td><input type="text" name="o2sat<%=i%>" value="<%=cdo.getColValue("o2sat")%>" readonly="readonly" style="width:50px"></td>

					<td>Resp.</td>
					<td> <input type="text" name="respiration<%=i%>" value="<%=cdo.getColValue("respiration")%>" readonly="readonly" style="width:50px"></td>

					<td>Alto</td>
					<td><input type="text" name="height<%=i%>" value="<%=cdo.getColValue("height")%>" readonly="readonly" style="width:50px"></td>

					<td>Peso</td>
					<td><input type="text" name="weight<%=i%>" value="<%=cdo.getColValue("weight")%>" readonly="readonly" style="width:50px"></td>

					<td align="center" <%=_xtraClass%>>
						<div class="<%=tmpAlert%>"></div>
					</td>

				</tr>
			<%
			group = cdo.getColValue("pac_id") + "-" + cdo.getColValue("admision");
			}%>


			</table>

		</td>
	</tr>
	<%}%>



	<tr>

		<td class="TableBorder" colspan="3">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

			<tr><td id="readingContainer"></td></tr>

			<script id="readingTmpl" type="text/x-jsrender">
				<table width="100%">
					{{for readings tmpl="#readingTmplContainer" /}}

					<tr class="TextRow02">
						 <td colspan="15" align="right">
						 &nbsp;
					 </td>
					 </tr>
				 </table>
			</script>
			<script id="readingTmplContainer" type="text/x-jsrender">

					<input type="hidden" name="size" id="size" value="{{:#parent.data.length}}">
					<input type="hidden" name="pacId{{:#index + 1}}" id="pacId{{:#index + 1}}" value="{{pacId:patientid}}">
					<input type="hidden" name="noAdmision{{:#index + 1}}" id="noAdmision{{:#index + 1}}" value="{{noAdmision:patientid}}">
					<input type="hidden" name="fecha{{:#index + 1}}" id="fecha{{:#index + 1}}" value="{{fecha:date}}">
					<input type="hidden" name="categoria{{:#index + 1}}" id="categoria{{:#index + 1}}" value="3">

					<input type="hidden" name="pain{{:#index + 1}}" id="pain{{:#index + 1}}" value="{{>(pain || '0' )}}">
					<input type="hidden" name="reading{{:#index + 1}}" id="reading{{:#index + 1}}" value="{{>reading}}">
					<input type="hidden" name="bmi{{:#index + 1}}" id="bmi{{:#index + 1}}" value="{{>(bmi || '0' )}}">
					<input type="hidden" name="diastolic{{:#index + 1}}" id="diastolic{{:#index + 1}}" value="{{>(diastolic || ' ' )}}">
					<input type="hidden" name="systolic{{:#index + 1}}" id="systolic{{:#index + 1}}" value="{{>(systolic || ' ' )}}">
					<input type="hidden" name="patientid{{:#index + 1}}" id="patientid{{:#index + 1}}" value="{{>(patientid || '0')}}">
					<input type="hidden" name="o2sat{{:#index + 1}}" id="o2sat{{:#index + 1}}" value="{{>(o2sat || ' ')}}">
					<input type="hidden" name="map{{:#index + 1}}" id="map{{:#index + 1}}" value="{{>(map || ' ')}}">
					<input type="hidden" name="pulse{{:#index + 1}}" id="pulse{{:#index + 1}}" value="{{>(pulse || ' ')}}">
					<input type="hidden" name="respiration{{:#index + 1}}" id="respiration{{:#index + 1}}" value="{{>(respiration || ' ')}}">
					<input type="hidden" name="temperature{{:#index + 1}}" id="temperature{{:#index + 1}}" value="{{>(temperature || ' ')}}">
					<input type="hidden" name="weight{{:#index + 1}}" id="weight{{:#index + 1}}" value="{{>(weight || ' ')}}">
					<input type="hidden" name="height{{:#index + 1}}" id="height{{:#index + 1}}" value="{{>(height || ' ')}}">
					<input type="hidden" name="hr{{:#index + 1}}" id="hr{{:#index + 1}}" value="{{>(hr || ' ')}}">
					<input type="hidden" name="clinicianid{{:#index + 1}}" id="clinicianid{{:#index + 1}}" value="{{>(clinicianid || ' ')}}">
					<tr class="TextHeader">
					<td colspan="15">Paciente: [{{pacId:patientid}}-{{noAdmision:patientid}}] - {{getPacData:patientid}}</td>
					</tr>
				<tr class="ooo">
					<td>Temp.</td>
					<td> <input type="text" name="temperature{{:#index + 1}}" value="{{>(temperature || ' ' )}}" readonly="readonly" style="width:40px"></td>
					<td>Pulso</td>
					<td> <input type="text" name="pulse{{:#index + 1}}" value="{{>(pulse || ' ')}}" readonly="readonly" style="width:40px">  </td>
					<td>P/A</td>
					<td> <input type="text" name="blood_pressure{{:#index + 1}}" value="{{>(systolic || ' ')}}/{{>(diastolic ||' ')}}" readonly="readonly" style="width:100px">  </td>

					<td>SatO2</td>
					<td> <input type="text" name="o2sat{{:#index + 1}}" value="{{>(o2sat || ' ')}}" readonly="readonly" style="width:50px"></td>

					<td>Resp.</td>
					<td> <input type="text" name="respiration{{:#index + 1}}" value="{{>(respiration || ' ')}}" readonly="readonly" style="width:50px"></td>

					<td>Alto</td>
					<td> <input type="text" name="height{{:#index + 1}}" value="{{>(height || ' ')}}" readonly="readonly" style="width:50px"></td>

					<td>Peso</td>
					<td> <input type="text" name="weight{{:#index + 1}}" value="{{>(weight || ' ')}}" readonly="readonly" style="width:50px"></td>

					<td> <input type="checkbox" name="check{{:#index + 1}}" id="check{{:#index + 1}}" value="{{:#index + 1}}" class="check"> </td>

				</tr>
			</script>


			</table>

		</td>
	</tr>

</table>



</body>
</html>
<%
}
else
{
		int size = Integer.parseInt(request.getParameter("size"));

		StringBuffer sb = new StringBuffer();
	al.clear();
	alU.clear();

	if (tempSaved.trim().equals("")){

		 System.out.println("::::::::::::::::::::::::::::::::::: POSTING TMP :::::::::::::::::::::::::::::::::: = "+tempSaved);

		 for (int s = 1; s<=size; s++){

			SignoPacienteTmp spaT = new SignoPacienteTmp();
			spaT.setAdmision(request.getParameter("noAdmision"+s));
			spaT.setPacId(request.getParameter("pacId"+s));
			spaT.setReading(request.getParameter("reading"+s));
			spaT.setBmi(request.getParameter("bmi"+s));
			spaT.setClinicianId(request.getParameter("clinicianid"+s));
			spaT.setReadingDate(request.getParameter("fecha"+s));
			spaT.setDiastolic(request.getParameter("diastolic"+s));
			spaT.setSystolic(request.getParameter("systolic"+s));
			spaT.setHeight(request.getParameter("height"+s));
			spaT.setHr(request.getParameter("hr"+s));
			spaT.setMap(request.getParameter("map"+s));
			spaT.setO2sat(request.getParameter("o2sat"+s));
			spaT.setPain(request.getParameter("pain"+s));
			spaT.setPatientId(request.getParameter("patientid"+s));
			spaT.setPulse(request.getParameter("pulse"+s));
			spaT.setRespiration(request.getParameter("respiration"+s));
			spaT.setTemperature(request.getParameter("temperature"+s));
			spaT.setWeight(request.getParameter("weight"+s));
			spaT.setSerialNumber(request.getParameter("serialNumber"));
			spaT.setDeviceJson(request.getParameter("device_json"));
			spaT.setDeviceId(request.getParameter("deviceId"));
			spaT.setFechaCreacion(cDateTime);
			spaT.setUsuarioCreacion((String) session.getAttribute("_userName"));

			al.add(spaT);
		 }

		 SPMgr.addConnexTmp(al);

	}else{

		System.out.println("::::::::::::::::::::::::::::::::::: POSTING TO EXP :::::::::::::::::::::::::::::::::: = "+tempSaved);

		 for (int s = 1; s<=size; s++){
		 if (request.getParameter("can_be_sent_to_exp"+s) != null && request.getParameter("can_be_sent_to_exp"+s).equals("Y") ){
			 sb = new StringBuffer();
			 sb.append("1@@");
			 sb.append(request.getParameter("temperature"+s));
			 sb.append("|2@@");
			 sb.append(request.getParameter("pulse"+s));
			 sb.append("|3@@");
			 sb.append(request.getParameter("respiration"+s));
			 sb.append("|4@@");
			 sb.append(request.getParameter("blood_pressure"+s));
			 sb.append("|7@@");
			 sb.append(request.getParameter("height"+s));
			 sb.append("|8@@");
			 sb.append(request.getParameter("weight"+s));
			 sb.append("|9@@");
			 sb.append(request.getParameter("o2sat"+s));

			SignoPaciente spa = new SignoPaciente();

			spa.setSecuencia(request.getParameter("noAdmision"+s));
			spa.setPacId(request.getParameter("pacId"+s));
			spa.setFecha(request.getParameter("fecha"+s));
			spa.setTipoSigno("PO");
			spa.setPersonal("E");
			spa.setTipoPersona("T");
			spa.setUsuarioCreacion((String) session.getAttribute("_userName"));
			spa.setUsuarioModif((String) session.getAttribute("_userName"));
			spa.setFechaCreacion(cDateTime);
			spa.setFechaModif(cDateTime);
			spa.setCategoria(request.getParameter("categoria"+s));
			spa.setObservacion("CONNEX");
			spa.setHora(request.getParameter("fecha"+s));
			spa.setHoraRegistro(request.getParameter("horaRegistro"));

			spa.setCodPaciente(request.getParameter("cod_paciente"+s));
			spa.setFecNacimiento(request.getParameter("fecha_nacimiento"+s));

			DetalleSignoPaciente spc = new DetalleSignoPaciente();
			spc.setResultado(sb.toString());
			spc.setSecuencia(request.getParameter("noAdmision"+s));
			spc.setPacId(request.getParameter("pacId"+s));
			spc.setTipoPersona("T");

			System.out.println("::::::::::::::::::::::::::::::::::: resultado = "+spc.getResultado());

			spc.setHora(request.getParameter("fecha"+s));
			spc.setFechaSigno(request.getParameter("fecha"+s));
			spc.setUsuarioCreacion((String) session.getAttribute("_userName"));
			spc.setFechaCreacion(cDateTime);
			spc.setUsuarioModificacion((String) session.getAttribute("_userName"));
			spc.setObservaciones("CONNEX");
			spc.setCodPaciente(request.getParameter("cod_paciente"+s));
			spc.setFechaNacimiento(request.getParameter("fecha_nacimiento"+s));

			spc.setTipoSigno("PO");
			spc.setCodigo("1");

			spa.addConnexDetalleSignoPaciente(spc);

			al.add(spa);


			//updating tmp table
			SignoPacienteTmp spaT = new SignoPacienteTmp();
				spaT.setAdmision(request.getParameter("noAdmision"+s));
				spaT.setPacId(request.getParameter("pacId"+s));
				spaT.setReading(request.getParameter("reading"+s));
				spaT.setPatientId(request.getParameter("patientid"+s));
				spaT.setReadingDate(request.getParameter("fecha"+s));
			spaT.setSerialNumber(request.getParameter("serialNumber"));
				spaT.setDeviceId(request.getParameter("deviceId"));

			if(request.getParameter("upt_tmp"+s)!=null && request.getParameter("upt_tmp"+s).equals("Y")) alU.add(spaT);
		 }
		 }//for

		 SPMgr.addConnex(al, alU);
	 }

	 //SPMgr.setErrCode("1");
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SPMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SPMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?tempSaved=Y&serialNumber=<%=serialNumber%>&deviceId=<%=deviceId%>';
<%
}else throw new Exception(SPMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>