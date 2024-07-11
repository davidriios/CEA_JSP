<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="RESCARDMgr" scope="page" class="issi.expediente.ResureccionCardiovascularMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
RESCARDMgr.setConnection(ConMgr);

ArrayList alMed = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
Properties prop = new Properties();

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String code = request.getParameter("code");
String key="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (code == null) code = "0";
if (fg == null) fg = "AD";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (!code.trim().equals("0")) {
			prop = SQLMgr.getDataProperties("select params from tbl_sal_resureccion_cardio where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+code+" and tipo = '"+fg+"'");

			if (prop == null) {
				prop = new Properties();
				prop.setProperty("fecha",cDateTime);
			} else {
				if(!viewMode) modeSec = "edit";
			}
		}  else {
			prop = new Properties();
			prop.setProperty("fecha",cDateTime);
		}

		alMed = SQLMgr.getDataList("select codigo, descripcion from tbl_sal_med_resucitacion where estado = 'A' order by 1");

		CommonDataObject pacData = SQLMgr.getData("select to_char(fecha_nacimiento,'dd/mm/yyyy') fn, codigo from tbl_adm_paciente where pac_id = "+pacId);

		ArrayList al = SQLMgr.getDataList("select codigo, to_char(fecha_creacion, 'dd/mm/yyyy') fc, to_char(fecha_creacion, 'hh12:mi am') hc, usuario_creacion from tbl_sal_resureccion_cardio where pac_id="+pacId+" and admision="+noAdmision+" and tipo = '"+fg+"' order by 1 desc");
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
<script>
var noNewHeight = true;
$(function(){

	$("#imprimir").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_resureccion_cardiovascular.jsp?fg=<%=fg%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codigo=<%=code%>");
	});

	$(".should-type").click(function(){
			var that = $(this);
			var i = that.data('index');
			if (that.is(":checked")) {
				$("#observacion"+i).prop("readOnly", false)
			} else {
				$("#observacion"+i).val("").prop("readOnly", true)
			}
	});

	$("input[name='params_7']").click(function(e){
		if (this.value == '1') {
			$(".desfibrilacion").each(function(){
				if (this.type == 'text') {
					this.value = '';
					this.readOnly = false;
				} else {
					this.disabled = false;
				}
			});
		} else {
			$(".desfibrilacion").each(function(){
				if (this.type == 'text') {
					this.value = '';
					this.readOnly = true;
				} else {
					this.checked = false;
					this.disabled = true;
				}
			});
		}
	});

	$('.desfibrilacion').on('click', function(event) {
				var that = $(this);
				var desfibrilacion = $("input[name='params_7']:checked").val();

				if (!desfibrilacion || desfibrilacion == '0') {
					event.preventDefault();
					event.stopPropagation();
					return false;
				}
		});

		//medicamentos

		$(".ctrl-medicamentos").click(function(){
				var i = $(this).data("index");
				if (this.checked) {
					$("#fecha_med_"+i).prop("readOnly",false);
					$("#resetfecha_med_"+i).prop("disabled",false);
					$(".det-medicamentos"+i).prop("readOnly",false);
					$(".signos"+i).prop("readOnly",false);
				} else {
					$("#fecha_med_"+i).prop("readOnly",true).val("");
					$("#resetfecha_med_"+i).prop("disabled",true);
					$(".det-medicamentos"+i).prop("readOnly",true).val("");
					$(".signos"+i).prop("readOnly", true).val("");
				}
		});

		// info tubo
		$("#params_4_1").click(function(){
			if (this.checked) $(".tubo").prop("readOnly", false);
			else $(".tubo").prop("readOnly", true).val("");
		});

});

function add(){window.location = '../expediente3.0/exp_resureccion_cardiovascular.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>';}

function setParams (code){
		window.location = '../expediente3.0/exp_resureccion_cardiovascular.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&code='+code;
}

function verHistorial() {
	$("#hist_container").toggle();
}
function canSubmit() {
	var proceed = true;
	$(".observacion").each(function() {
		var $self = $(this);
		var i = $self.data('index');
		var message = $self.data('message');
		if ( $self.is(":checked") && !$.trim($("#observacion"+i).val())) {
			parent.parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
			proceed = false;
			$self.focus();
			return false;
		}else  {proceed = true;}
	});
	return proceed;
}

function shouldTypeRadio(check, textareaIndex) {
	if (check == true) $("#observacion"+textareaIndex).prop("readOnly", false)
	else $("#observacion"+textareaIndex).val("").prop("readOnly", true)
}

function setSV(i) {
	if ($("#params_med_"+i).is(":checked")) {
		var url = encodeURI('../expediente3.0/exp_triage.jsp?modeSec=add&mode=<%=mode%>&fg=SV&seccion=77&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=agregar&desc=SIGNO VITALES&from=resureccion&index='+i+'&fecha_nacimiento=<%=pacData.getColValue("fn")%>&codigo_paciente=<%=pacData.getColValue("codigo")%>');
		abrir_ventana(url);
	}
}
</script>
</head>
<body class="body-form">
<div class="row">

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("code", code)%>
<%=fb.hidden("medSize", ""+alMed.size())%>

		<div class="headerform">
				<table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
						<tr>
								<td>
										<%=fb.button("imprimir","Imprimir",false,(code.equals("0")),null,null,"")%>
										<%if(!mode.trim().equals("view")){%>
											<button type="button" class="btn btn-inverse btn-sm" onclick="add()">
												<i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
											</button>
										<%}%>
											<button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
												<i class="fa fa-eye fa-printico"></i> <b>Historial</b>
											</button>
								</td>
						</tr>
				</table>
		</div>

		<div class="table-wrapper" id="hist_container" style="display:none">
				<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<thead>
						<tr class="bg-headtabla2">
						<th style="vertical-align: middle !important;">C&oacute;digo</th>
						<th style="vertical-align: middle !important;">Fecha</th>
						<th style="vertical-align: middle !important;">Hora</th>
						<th style="vertical-align: middle !important;">Usuario</th>
						</thead>
						<%
						for (int p = 1; p <= al.size(); p++){
								cdo = (CommonDataObject)al.get(p-1);
						%>
						<tbody>
								<tr onclick="javascript:setParams('<%=cdo.getColValue("codigo")%>')" class="pointer">
										<td><%=cdo.getColValue("codigo")%></td>
										<td><%=cdo.getColValue("fc")%></td>
										<td><%=cdo.getColValue("hc")%></td>
										<td><%=cdo.getColValue("usuario_creacion")%></td>
								</tr>
						</tbody>
						<% }%>
				</table>
		 </div>

		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<tr>
					<td class="controls form-inline">
						<b>Fecha:</b>&nbsp;
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
								<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
								<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
						</jsp:include>
					</td>
					<td class="controls form-inline" colspan="2">
					<b>Lugar del Evento:</b>&nbsp;
					<%=fb.textBox("lugar_evento", prop.getProperty("lugar_evento"),true,false,viewMode,60,"form-control input-sm","",null)%>
					</td>

				</tr>

				<tr class="bg-headtabla">
						<td>HORA</td>
						<td>RECONOCIMIENTO DEL EVENTO</td>
						<td>PAR&Aacute;METROS</td>
				</tr>
				<tr>
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="fecha_0" />
										<jsp:param name="format" value="hh12:mi:ss am" />
										<jsp:param name="valueOfTBox1" value="<%=code.equals("0")?cDateTime.substring(10,22):prop.getProperty("fecha_0")%>" />
										<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
								</jsp:include>
						</td>
						<td>¿SE IDENFICÓ EL EVENTO?</td>
						<td>
								<label class="pointer">SI&nbsp;<%=fb.radio("params_0","1",(prop.getProperty("params_0")!=null && prop.getProperty("params_0").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
								&nbsp;&nbsp;
								<label class="pointer">NO&nbsp;<%=fb.radio("params_0","0",(prop.getProperty("params_0")!=null && prop.getProperty("params_0").equalsIgnoreCase("0")),viewMode,false,"", null,"")%></label>
						</td>
				</tr>

				<tr>
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="fecha_1" />
										<jsp:param name="format" value="hh12:mi:ss am" />
										<jsp:param name="valueOfTBox1" value="<%=code.equals("0")?cDateTime.substring(10,22):prop.getProperty("fecha_1")%>" />
										<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
								</jsp:include>
						</td>
						<td>¿ESTABA EL PACIENTE CONCIENTE CUANDO SE LLAM&Oacute; AL C&Oacute;DIGO?</td>
						<td>
								<label class="pointer">SI&nbsp;<%=fb.radio("params_1","1",(prop.getProperty("params_1")!=null && prop.getProperty("params_1").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
								&nbsp;&nbsp;
								<label class="pointer">NO&nbsp;<%=fb.radio("params_1","0",(prop.getProperty("params_1")!=null && prop.getProperty("params_1").equalsIgnoreCase("0")),viewMode,false,"", null,"")%></label>
						</td>
				</tr>

				<tr>
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="fecha_2" />
										<jsp:param name="format" value="hh12:mi:ss am" />
										<jsp:param name="valueOfTBox1" value="<%=code.equals("0")?cDateTime.substring(10,22):prop.getProperty("fecha_2")%>" />
										<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
								</jsp:include>
						</td>
						<td>¿SE ACTIVÓ EL EQUIPO DEL CÓDIGO?</td>
						<td>
								<label class="pointer">SI&nbsp;<%=fb.radio("params_2","1",(prop.getProperty("params_2")!=null && prop.getProperty("params_2").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
								&nbsp;&nbsp;
								<label class="pointer">NO&nbsp;<%=fb.radio("params_2","0",(prop.getProperty("params_2")!=null && prop.getProperty("params_2").equalsIgnoreCase("0")),viewMode,false,"", null,"")%></label>
						</td>
				</tr>

				<tr>
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="fecha_3" />
										<jsp:param name="format" value="hh12:mi:ss am" />
										<jsp:param name="valueOfTBox1" value="<%=code.equals("0")?cDateTime.substring(10,22):prop.getProperty("fecha_3")%>" />
										<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
								</jsp:include>
						</td>
						<td>
								¿C&Oacute;MO ESTABA LA VÍA AÉREA ANTES DEL EVENTO?
						</td>
						<td>
								<label for="params_3_0" class="pointer">Espont&aacute;nea</label>
								<%=fb.checkbox("params_3_0","0",(prop.getProperty("params_3_0").equalsIgnoreCase("0")),viewMode,"","","","")%>
								&nbsp;&nbsp;&nbsp;&nbsp;
								<label for="params_3_1" class="pointer">Apnea</label>
								<%=fb.checkbox("params_3_1","1",(prop.getProperty("params_3_1").equalsIgnoreCase("1")),viewMode,"","","","")%>
								&nbsp;&nbsp;&nbsp;&nbsp;
								<label for="params_3_2" class="pointer">Asistida</label>
								<%=fb.checkbox("params_3_2","2",(prop.getProperty("params_3_2").equalsIgnoreCase("2")),viewMode,"","","","")%><br>
								<label for="params_3_3" class="pointer">Otras</label>
								<%=fb.checkbox("params_3_3","OT",(prop.getProperty("params_3_3").equalsIgnoreCase("OT")),viewMode,"observacion should-type",null,"",""," data-index=0 data-message='Por favor indique las otras vía aéreas!'")%>
								<%=fb.textBox("observacion0", prop.getProperty("observacion0"),false,false,viewMode||prop.getProperty("observacion0").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
						</td>
				</tr>

				<tr>
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="fecha_4" />
										<jsp:param name="format" value="hh12:mi:ss am" />
										<jsp:param name="valueOfTBox1" value="<%=code.equals("0")?cDateTime.substring(10,22):prop.getProperty("fecha_4")%>" />
										<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
								</jsp:include>
						</td>
						<td>
								TIPO DE VENTILACI&Oacute;N
						</td>
						<td>
								<label for="params_4_0" class="pointer">Amb&uacute;</label>
								<%=fb.checkbox("params_4_0","0",(prop.getProperty("params_4_0").equalsIgnoreCase("0")),viewMode,"","","","")%>
								&nbsp;&nbsp;&nbsp;&nbsp;
								<label for="params_4_1" class="pointer">Tubo ET</label>
								<%=fb.checkbox("params_4_1","1",(prop.getProperty("params_4_1").equalsIgnoreCase("1")),viewMode,"","","","")%>
								&nbsp;&nbsp;&nbsp;&nbsp;
								<label for="params_4_2" class="pointer">Traqueostom&iacute;a</label>
								<%=fb.checkbox("params_4_2","2",(prop.getProperty("params_4_2").equalsIgnoreCase("2")),viewMode,"","","","")%><br>
								<label for="params_4_3" class="pointer">Otras</label>
								<%=fb.checkbox("params_4_3","OT",(prop.getProperty("params_4_3").equalsIgnoreCase("OT")),viewMode,"observacion should-type",null,"",""," data-index=1 data-message='Por favor indique los otros tipos de ventilación!'")%>
								<%=fb.textBox("observacion1", prop.getProperty("observacion1"),false,false,viewMode||prop.getProperty("observacion1").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
						</td>
				</tr>

				<tr>
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="format" value="hh12:mi:ss am" />
										<jsp:param name="nameOfTBox1" value="fecha_5" />
										<jsp:param name="valueOfTBox1" value="<%=code.equals("0")?cDateTime.substring(10,22):prop.getProperty("fecha_5")%>" />
										<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
								</jsp:include>
						</td>
						<td>
								INFORMACI&Oacute;N DE ENTUBACI&Oacute;N ENDOTRAQUEAL
						</td>
						<td>
								# de Tubo:&nbsp;<%=fb.textBox("observacion2", prop.getProperty("observacion2"),false,false,viewMode||prop.getProperty("observacion2").equals(""),30,"form-control input-sm tubo","display:inline; width:100px",null)%><br>
								<b>Colocado por</b>
								<%=fb.textBox("observacion3", prop.getProperty("observacion3"),false,false,viewMode||prop.getProperty("observacion3").equals(""),30,"form-control input-sm tubo","display:inline; width:300px",null)%>
						</td>
				</tr>

				<tr>
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="format" value="hh12:mi:ss am" />
										<jsp:param name="nameOfTBox1" value="fecha_6" />
										<jsp:param name="valueOfTBox1" value="<%=code.equals("0")?cDateTime.substring(10,22):prop.getProperty("fecha_6")%>" />
										<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
								</jsp:include>
						</td>
						<td>INICIO DE COMPRESIONES</td>
						<td>
								<label class="pointer">SI&nbsp;<%=fb.radio("params_6","1",(prop.getProperty("params_6")!=null && prop.getProperty("params_6").equalsIgnoreCase("1")),viewMode,false,"observacion", null,"onClick='shouldTypeRadio(true, 4)'",""," data-index=4 data-message='Por favor indique el inicio de compresiones!'")%></label>
								&nbsp;&nbsp;
								<label class="pointer">NO&nbsp;<%=fb.radio("params_6","0",(prop.getProperty("params_6")!=null && prop.getProperty("params_6").equalsIgnoreCase("0")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 4)'")%></label><br>
								<%=fb.textBox("observacion4", prop.getProperty("observacion4"),false,false,viewMode||prop.getProperty("observacion4").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
						</td>
				</tr>

				<tr>
						<td class="controls form-inline">
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="format" value="hh12:mi:ss am" />
										<jsp:param name="nameOfTBox1" value="fecha_7" />
										<jsp:param name="valueOfTBox1" value="<%=code.equals("0")?cDateTime.substring(10,22):prop.getProperty("fecha_7")%>" />
										<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
								</jsp:include>
						</td>
						<td>¿SE APLIC&Oacute; DESFIBRILACI&Oacute;N AL PACIENTE?</td>
						<td>
								<label class="pointer">SI&nbsp;<%=fb.radio("params_7","1",(prop.getProperty("params_7")!=null && prop.getProperty("params_7").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
								&nbsp;&nbsp;
								<label class="pointer">NO&nbsp;<%=fb.radio("params_7","0",(prop.getProperty("params_7")!=null && prop.getProperty("params_7").equalsIgnoreCase("0")),viewMode,false,"", null,"")%></label><br>
								<b>Tipo de desfibrilaci&oacute;n:</b>&nbsp;
								<label class="pointer">
								<%=fb.radio("params_8","0",(prop.getProperty("params_8")!=null && prop.getProperty("params_8").equalsIgnoreCase("0")),viewMode,false,"desfibrilacion", null,"","","")%>Monof&aacute;sica</label>
								&nbsp;&nbsp;&nbsp;
								<label class="pointer">
								<%=fb.radio("params_8","1",(prop.getProperty("params_8")!=null && prop.getProperty("params_8").equalsIgnoreCase("1")),viewMode,false,"desfibrilacion", null,"","","")%>Bif&aacute;sica</label>
								<br>
								<b>Ritmo card&iacute;aco:</b>&nbsp;
								<label class="pointer">VF&nbsp;<%=fb.checkbox("params_9_0","0",(prop.getProperty("params_9_0").equalsIgnoreCase("0")),viewMode,"desfibrilacion","","","")%></label>
								&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer">VT&nbsp;<%=fb.checkbox("params_9_1","1",(prop.getProperty("params_9_1").equalsIgnoreCase("1")),viewMode,"desfibrilacion","","","")%></label>
								&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer">Bradicardia&nbsp;<%=fb.checkbox("params_9_2","2",(prop.getProperty("params_9_2").equalsIgnoreCase("2")),viewMode,"desfibrilacion","","","")%></label><br>
								<b>Otro:</b>&nbsp;<%=fb.textBox("observacion5", prop.getProperty("observacion5"),false,false,viewMode||prop.getProperty("observacion5").equals(""),30,"form-control input-sm desfibrilacion","display:inline; width:300px",null)%>
						</td>
				</tr>
		</table>

		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<tr class = "bg-headtabla">
					<td colspan="9">MEDICAMENTOS ADMINISTRADOS</td>
				</tr>
				<tr class="bg-headtabla2">
						<td></td>
						<td>Medicamentos V&iacute;a - Dosis</td>
						<td>Hora</td>
						<td>S.Vitales</td>
						<td>FR</td>
						<td>FC</td>
						<td>PA</td>
						<td>SPO2</td>
						<td>Observaci&oacute;n</td>
			 </tr>

				<% for (int m = 0; m < alMed.size(); m++){
						CommonDataObject cdoM = (CommonDataObject) alMed.get(m);
				%>
					 <tr>
								<td>
										<%=fb.checkbox("params_med_"+m, cdoM.getColValue("codigo") ,(prop.getProperty("params_med_"+m).equalsIgnoreCase(cdoM.getColValue("codigo"))),viewMode,"ctrl-medicamentos",null,"",""," data-index="+m)%>
								</td>
								<td>
										<label for="params_med_<%=m%>" class="pointer"><%=cdoM.getColValue("descripcion")%></label>
								</td>
								<td class="controls form-inline">
										<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="1" />
												<jsp:param name="clearOption" value="true" />
												<jsp:param name="format" value="hh12:mi:ss am" />
												<jsp:param name="nameOfTBox1" value="<%="fecha_med_"+m%>" />
												<jsp:param name="valueOfTBox1" value="<%=code.equals("0")?cDateTime.substring(10,22):prop.getProperty("fecha_med_"+m)%>" />
												<jsp:param name="readonly" value="y" />
										</jsp:include>
								</td>
								<td>
									<button type="button"  class="btn btn-inverse btn-sm" onclick="setSV(<%=m%>)"<%=viewMode?" disabled":""%>><i class="fa fa-pencil fa-lg"></i> Traer</button>
								</td>
								<td>
										<%=fb.textBox("fr_"+m, prop.getProperty("fr_"+m),false,false,viewMode||prop.getProperty("fr_"+m).equals(""),30,"form-control input-sm signos"+m,"display:inline; width:90px",null)%>
								</td>
								<td>
										<%=fb.textBox("fc_"+m, prop.getProperty("fc_"+m),false,false,viewMode||prop.getProperty("fc_"+m).equals(""),30,"form-control input-sm signos"+m,"display:inline; width:90px",null)%>
								</td>
								<td>
										<%=fb.textBox("pa_"+m, prop.getProperty("pa_"+m),false,false,viewMode||prop.getProperty("pa_"+m).equals(""),30,"form-control input-sm signos"+m,"display:inline; width:90px",null)%>
								</td>
								<td>
										<%=fb.textBox("spo2_"+m, prop.getProperty("spo2_"+m),false,false,viewMode||prop.getProperty("spo2_"+m).equals(""),30,"form-control input-sm  signos"+m,"display:inline; width:90px",null)%>
								</td>
								<td>
										<%=fb.textarea("obs_medicamentos"+m,prop.getProperty("obs_medicamentos"+m),false,false, viewMode||prop.getProperty("obs_medicamentos"+m).equals(""),0,1,"form-control input-sm det-medicamentos"+m,"width:100%",null)%>
								</td>
					 </tr>
				<%
				}

				%>

		</table>

		<div class="footerform">
				<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
				<tr>
					 <td>
								Opciones de Guardar:
								<label><%=fb.radio("saveOption","O",true,viewMode,false,null,null,null)%> Mantener Abierto</label>
								<label><%=fb.radio("saveOption","C",false,viewMode,false,null,null,null)%> Cerrar</label>
								<%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
								<%=fb.button("cancel","Cancelar",false,false,null,null,"onclick=\"parent.doRedirect(0)\"")%>
						</td>
				</tr>
				</table>
		</div>

<%=fb.formEnd(true)%>
</div>
</div>
</body>
</html>
<%
} else {
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");

		prop = new Properties();

		prop.setProperty("pac_id",request.getParameter("pacId"));
	prop.setProperty("admision",request.getParameter("noAdmision"));
	prop.setProperty("codigo",request.getParameter("code"));
	prop.setProperty("tipo",request.getParameter("fg"));
		prop.setProperty("usuario_creacion", UserDet.getUserName());
		prop.setProperty("fecha_creacion", request.getParameter("fecha"));
		prop.setProperty("usuario_modificacion", UserDet.getUserName());
		prop.setProperty("fecha_modificacion", cDateTime);

		prop.setProperty("fecha", request.getParameter("fecha"));
		prop.setProperty("lugar_evento", request.getParameter("lugar_evento"));

		for (int i = 0; i < 10; i++) {
				if(request.getParameter("fecha_"+i)!=null) prop.setProperty("fecha_"+i, request.getParameter("fecha_"+i));
				if(request.getParameter("params_"+i)!=null) prop.setProperty("params_"+i, request.getParameter("params_"+i));
				if(request.getParameter("params_3_"+i)!=null) prop.setProperty("params_3_"+i, request.getParameter("params_3_"+i));
				if(request.getParameter("params_4_"+i)!=null) prop.setProperty("params_4_"+i, request.getParameter("params_4_"+i));
				if(request.getParameter("params_9_"+i)!=null) prop.setProperty("params_9_"+i, request.getParameter("params_9_"+i));

				if(request.getParameter("observacion"+i)!=null) prop.setProperty("observacion"+i, request.getParameter("observacion"+i));
		}

		int medSize = Integer.parseInt(request.getParameter("medSize"));
		for (int m = 0; m < medSize; m++) {

				if(request.getParameter("params_med_"+m)!=null) {
						prop.setProperty("params_med_"+m, request.getParameter("params_med_"+m));
						prop.setProperty("fecha_med_"+m, request.getParameter("fecha_med_"+m));
						prop.setProperty("fr_"+m, request.getParameter("fr_"+m));
						prop.setProperty("fc_"+m, request.getParameter("fc_"+m));
						prop.setProperty("pa_"+m, request.getParameter("pa_"+m));
						prop.setProperty("spo2_"+m, request.getParameter("spo2_"+m));
						prop.setProperty("obs_medicamentos"+m, request.getParameter("obs_medicamentos"+m));
				}
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
		{
				RESCARDMgr.add(prop);
				code = RESCARDMgr.getPkColValue("codigo");
		}
		else RESCARDMgr.update(prop);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (RESCARDMgr.getErrCode().equals("1")) { %>
	alert('<%=RESCARDMgr.getErrMsg()%>');
<%
	if (saveOption.equalsIgnoreCase("N")) {
%>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(RESCARDMgr.getErrMsg());
%>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>';}
</script>
</head>
<body onLoad="closeWindow()"></body>
</html>
<% } %>
