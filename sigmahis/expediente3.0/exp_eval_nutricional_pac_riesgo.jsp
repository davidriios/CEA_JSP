<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.Properties"%>
<%@ page import="java.util.Vector" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="EvalNutriMgr" scope="page" class="issi.expediente.EvaluacionNutricionalRiesgoMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
EvalNutriMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
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
String companyId = (String) session.getAttribute("_companyId");
String estado = request.getParameter("estado");

if (code == null) code = "0";
if (fg == null) fg = "SAD";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String sexo = "";
String formulario = "";
int edad = 0;
if (estado == null) estado = "";

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (!code.trim().equals("0")) {
			prop = SQLMgr.getDataProperties("select params from tbl_sal_eval_nutri_riesgo where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+code+" and tipo = '"+fg+"'");

			if (prop == null) {
				prop = new Properties();
			} else {
				if(!viewMode) modeSec = "edit";
				sexo = prop.getProperty("sexo");
				formulario = prop.getProperty("formulario");
				edad = Integer.parseInt(prop.getProperty("edad") != null && !"".equals(prop.getProperty("edad"))?prop.getProperty("edad"):"0");
			}

		} else {
				// > 49 riesgo de caida
				// < 16 riesgo de caida
				sbSql = new StringBuffer();
				sbSql.append("select edad, nvl(get_sec_comp_param("+companyId+", 'SAL_PED_EDAD'), 0) edad_ped, d.sexo, trim(replace(get_weight_height(ad.pac_id, ad.secuencia,'W'),'|','')) peso, trim(replace(get_weight_height(ad.pac_id, ad.secuencia,'H'),'|','')) altura, (select formulario from tbl_sal_nota_eval_enf_urg where pac_id = ad.pac_id and admision = ad.secuencia and id > 0 and rownum = 1) formulario from tbl_adm_admision ad, vw_adm_paciente d where d.pac_id = ad.pac_id and ad.pac_id = ");
				sbSql.append(pacId);
				sbSql.append("and ad.secuencia = ");
				sbSql.append(noAdmision);

				cdo = SQLMgr.getData(sbSql.toString());
				if (cdo == null) cdo = new CommonDataObject();

				sexo = cdo.getColValue("sexo"," ");
				formulario = cdo.getColValue("formulario"," ");
				edad = Integer.parseInt(cdo.getColValue("edad","0") != null && !"".equals(cdo.getColValue("edad","0"))?cdo.getColValue("edad","0"):"0");

				prop = new Properties();
				prop.setProperty("fecha",cDateTime.substring(0,10));
		}

		ArrayList alH = SQLMgr.getDataList("select codigo, to_char(fecha_creacion, 'dd/mm/yyyy') fc, to_char(fecha_creacion, 'hh12:mi am') hc, usuario_creacion, decode(status,'A', 'ACTIVO', 'I', 'INVALIDO') as status_dsp from tbl_sal_eval_nutri_riesgo where pac_id="+pacId+" and admision="+noAdmision+" and tipo = '"+fg+"' order by 1 desc");

		Vector vFormularios = CmnMgr.str2vector(formulario);

		boolean allow = CmnMgr.getCount("select count(*) from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = 'C1'") > 0;
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
<%if(!allow){%>
		parent.parent.CBMSG.warning("Por favor llene primero la pantalla EVALUACION II");
<%}%>

	$("#imprimir").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_eval_nutricional_pac_riesgo.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&codigo=<%=code%>&formulario=<%=formulario%>");
	});

	// ver nutrición
	$("#btn_nutricion").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente/print_exp_seccion_37.jsp?seccion=37&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=O/M NUTRICION&fp=exp_kardex&idOrden=&tipoOrden=3");
	});

	// ver antecedentes personales
	$("#btn_ant_personales").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente/print_exp_seccion_2.jsp?seccion=2&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=ANTECEDENTES PERSONALES&fp=exp_kardex");
	});
	// ver antecedentes familiares
	$("#btn_ant_familiares").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente/print_exp_seccion_7.jsp?seccion=7&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=ANTECEDENTES FAMILIARES&fp=exp_kardex");
	});

	$("#btn_eval_1,#btn_eval_2,#btn_eval_3").click(function(e){
		e.preventDefault();
		if(this.id == 'btn_eval_3' || this.id == 'btn_eval_2')
				abrir_ventana("../expediente3.0/print_exp_seccion_108.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=NEEU&seccion=108&desc=EVALUACION INICIAL I DE ENFERMERIA&fp=nutricional_riesgo_alergia");
		else abrir_ventana("../expediente3.0/print_exp_seccion_108.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=NEEU&seccion=108&desc=EVALUACION INICIAL I DE ENFERMERIA&fp=nutricional_riesgo");
	});

	// cribado
	$("#btn_cribado_1").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_cuestionarios.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=C1&seccion=123&desc=EVALUACION II&fp=nutricional_riesgo&formulario=<%=formulario%>");
	});
	$("#btn_cribado_em").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_cuestionarios.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=EM&seccion=128&desc=EVALUACION II EMBARAZADA&fp=nutricional_riesgo&formulario=<%=formulario%>");
	});
	$("#btn_cribado_ped").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_cuestionarios.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=PE&seccion=127&desc=EVALUACION II PEDIATRICO&fp=nutricional_riesgo&formulario=<%=formulario%>");
	});

	// ver antecedentes neonatales
	$("#btn_ant_neonatales").click(function(e){
		e.preventDefault();
		abrir_ventana('../expediente3.0/print_exp_seccion_9.jsp?pacId=<%=pacId%>&seccion=9&noAdmision=<%=noAdmision%>&desc=ANTECEDENTE NEONATAL / PEDIATRICO&fp=nutricional_riesgo');
	});

	// ver antecedentes
	$("#btn_ant_alergicos, #btn_ant_alergicos2").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_exp_seccion_11.jsp?seccion=11&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=ANTECEDENTES ALERGICOS&fg=exp_kardex");
	});

	// ver om medicamentos
	$("#btn_inhaloterapia").click(function(e){
		e.preventDefault();

		abrir_ventana("../expediente3.0/exp_print_conciliacion.jsp?seccion=27&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=ANTECEDENTES MEDICAMENTOS&fg=&fp=exp_nutricional&id=0&tipoOrden=2");
	});

	// ver om laboratorios
	$("#btn_laboratorios").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente/print_list_ordenmedica.jsp?seccion=76&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=&fg=&fp=exp_nutricional&id=0&tipoOrden=1");
	});

	// G.E.T
	$("#btn_get").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_exp_seccion_108.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=NEEU&seccion=108&desc=EVALUACION INICIAL I DE ENFERMERIA&fp=nutricional_riesgo_alergia_get");
	});

	// VALORACION Funcional
	$("#btn_funcional").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_cuestionarios.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=C1&seccion=123&desc=EVALUACION II&fp=nutricional_riesgo_funcional");
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

		// calcular indice Masa Corporal
		computeIMC();
		$("#talla, #peso").blur(function(){
				computeIMC();
		});

		$("#perdida_peso").change(function(){
			 if (this.value != -1) $("#perdida_peso_puntaje").val(this.value);
			 else $("#perdida_peso_puntaje").val("");

			 computeTotal();
		});

		$("input[name='param_enf']").click(function(){
			 if (this.value != 0) $("#param_enf_puntaje").val(this.value);
			 else $("#param_enf_puntaje").val("");

			 computeTotal();
		});

		// compute total adulto mayor
		$("input[name='pregunta_1'], input[name='pregunta_2'], input[name='pregunta_3'], input[name='pregunta_4'], input[name='pregunta_5'], input[name='pregunta_6'], input[name='pregunta_7'], input[name='pregunta_8'], input[name='pregunta_9'], input[name='pregunta_10'], input[name='pregunta_11'], input[name='pregunta_13'], input[name='pregunta_14'], input[name='pregunta_15'], input[name='pregunta_16'], input[name='pregunta_17'], input[name='pregunta_18']").not('.not-allowing').click(function(){
				var self = $(this);
				var i = self.data('index');
				$("#resulta_"+i).val(this.value);
				computeTotalADM();
		});

		$(".pregunta_12").click(function(){
				var sel = $("input.pregunta_12:checked[value='Y']").length;
				if (sel == 2) $("#resulta_12").val('0.5');
				else if (sel == 3) $("#resulta_12").val('1.0');
				else if (sel < 2) $("#resulta_12").val('0');

				computeTotalADM();
		});

		//
		$("input[name*='resulta_']").prop("readOnly", true);
		ctrlEvaluacion(false);

});
function computeEvalTotal(){
		var total = 0.0;
		var totalCribaje = parseFloat($("#total_cribaje").val() || 0);
		var totalGlobal = 0.0;
		for (var i = 7; i<=18; i++) {
			 var obj = $("input[name='resulta_"+i+"']");
			 if(!obj.hasClass("cribaje")) {
				 total += parseFloat(obj.val() || 0);
			 }
		}
		totalGlobal = total + totalCribaje;
		$("#total_eval").val(total.toFixed(2));
		$("#total_global").val(totalGlobal.toFixed(2));

		if(totalGlobal >=17 && totalGlobal <= 23.5)$("#total_global_dsp").val("RIESGO DE MALNUTRICION");
		else if(totalGlobal < 17)$("#total_global_dsp").val("MALNUTRICION");
}

function computeCribajeTotal(){
		var total = 0.0;
		for (var i = 1; i<=6; i++) {
			 var obj = $("input[name='resulta_"+i+"']");
			 if(obj.hasClass("cribaje")) {
				 total += parseFloat(obj.val() || 0);
			 }
		}
		$("#total_cribaje").val(total.toFixed(2));
		if(total >= 12) {
				$("#total_cribaje_dsp").val("NO NECESITA CONTINUAR LA EVALUACION");
				ctrlEvaluacion(false);
		}
		else if(total <= 11) {
				$("#total_cribaje_dsp").val("POSIBLE MALNUTRICION CONTINUAR LA EVALUACION");
				ctrlEvaluacion(true);
		}
}

function ctrlEvaluacion(isAllowing) {
		var doWhat = isAllowing ? "allowing":"not-allowing";
		for (var i = 7; i<=18; i++) {
			 if (!isAllowing) {
				 $("input[name='pregunta_"+i+"']").prop({checked:false,disabled:true});
				 $("input[name='resulta_"+i+"']").val("");
				 if (i == 18) {

				 }
			 } else {
				 $("input[name='pregunta_"+i+"']").prop("disabled", false);
			 }
		}
}

function computeTotalADM(){
		var total = 0.0;
		$("input[name*='resulta_']").each(function(){
				total += parseFloat($(this).val()||0);
		});
		computeCribajeTotal();
		computeEvalTotal();
}

function computeTotal() {
		var imcParamPuntaje = $("#imc_param_puntaje").val() || '0';
		var perdidaPesoPuntaje = $("#perdida_peso_puntaje").val() || '0';
		var paramEnfPePuntaje = $("#param_enf_puntaje").val() || '0';
		var total = parseFloat(imcParamPuntaje) + parseFloat(perdidaPesoPuntaje) + parseFloat(paramEnfPePuntaje);
		var riesgoNutricionalDsp = "RIESGO BAJO";
		if (total == 1.0) riesgoNutricionalDsp = "RIESGO MEDIO";
		else if (total >= 2.0) riesgoNutricionalDsp = "RIESGO ALTO";
		$("#total_param").val(total);
		$("#riesgo_nutricional_dsp").val(riesgoNutricionalDsp);
}

function computeIMC() {
		var talla = $("#talla").val() || '0';
		var peso = $("#peso").val() || '0';
		var sexo = $("#sexo").val().toLowerCase();
		var indiceMasaCorporal = 0;
		var pesoIdealConstant = 24; //(sexo == 'm' ? 21.5 : 23.0);
		talla = parseFloat(talla);
		peso = parseFloat(peso);
		var pesoIdeal = talla * talla * pesoIdealConstant;
		var pesoAjustado = (peso - pesoIdeal) * 0.25 + pesoIdeal;
		var imcPuntaje;

		if (talla > 0) {
			indiceMasaCorporal = peso / (talla*talla);
		}

		if (indiceMasaCorporal >= 18.5 && indiceMasaCorporal <= 20) imcPuntaje = 1;
		else if (indiceMasaCorporal > 20) imcPuntaje = 0;
		else if (indiceMasaCorporal < 18.5) imcPuntaje = 2;

		if (talla && peso) {
				$("#imc, #imc_param").val(indiceMasaCorporal.toFixed(2));
				$("#peso_ajustado").val(pesoAjustado.toFixed(2));
				$("#imc_param_puntaje").val(imcPuntaje);
		}
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

function setEscala(code){
		window.location = '../expediente3.0/exp_eval_nutricional_pac_riesgo.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&estado=<%=estado%>&code='+code;
}
function add(){window.location = '../expediente3.0/exp_eval_nutricional_pac_riesgo.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>&estado=<%=estado%>';}

function verHistorial() {
	$("#hist_container").toggle();
}

function doSubmit(form, value) {
	if (value == 'Inactivar') {
		if ( confirm('Por favor confirmar que quieres inabilitar La Evaluacion Nutricional # <%=code%>') ) __submitForm(form, value);
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
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("code", code)%>
<%=fb.hidden("formulario", formulario)%>
<%=fb.hidden("sexo", cdo!=null&&cdo.getColValue("sexo") != null?cdo.getColValue("sexo"):prop.getProperty("sexo"))%>
<%=fb.hidden("estado", estado)%>

		<div class="headerform">
				<table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
						<tr>
								<td>
										<%=fb.button("imprimir","Imprimir",false,(code.equals("0")),"btn btn-inverse btn-sm",null,"")%>

										<%if(!mode.trim().equals("view")){%>
											<button type="button" class="btn btn-inverse btn-sm" onclick="add()"<%=!allow?" disabled":""%>>
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
								<th style="vertical-align: middle !important;"></th>
						</thead>
						<%
						for (int p = 1; p <= alH.size(); p++){
								CommonDataObject cdoH = (CommonDataObject)alH.get(p-1);
						%>
						<tbody>
								<tr onclick="javascript:setEscala('<%=cdoH.getColValue("codigo")%>')" class="pointer">
										<td><%=cdoH.getColValue("codigo")%></td>
										<td><%=cdoH.getColValue("fc")%></td>
										<td><%=cdoH.getColValue("hc")%></td>
										<td><%=cdoH.getColValue("usuario_creacion")%></td>
										<td><span style="font-weight:bold"><%=cdoH.getColValue("status_dsp")%></span></td>
								</tr>
						</tbody>
						<% }%>
				</table>
		</div>


<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<tr>
			<td class="controls form-inline">
				<b>Fecha:</b>
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
						<jsp:param name="nameOfTBox1" value="fecha" />
						<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
				</jsp:include>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<b>Talla:</b>
				<%=fb.textBox("talla", cdo!=null&&cdo.getColValue("altura") != null?cdo.getColValue("altura"):prop.getProperty("talla"),true,false,false,60,"form-control input-sm","width:100px",null)%>&nbsp;m
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<b>Peso:</b>
				<%=fb.textBox("peso", cdo!=null&&cdo.getColValue("peso") != null?cdo.getColValue("peso"):prop.getProperty("peso"),true,false,false,60,"form-control input-sm","width:100px",null)%>&nbsp;kg
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<b>IMC:</b>
				<%=fb.textBox("imc", cdo!=null&&cdo.getColValue("imc") != null?cdo.getColValue("imc"):prop.getProperty("imc"),true,false,false,60,"form-control input-sm","width:100px",null)%>

				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<b>Peso Ajustado: PI+ 0.4 (PA- PI):</b>
				<%=fb.textBox("peso_ajustado", cdo!=null&&cdo.getColValue("peso_ajustado") != null?cdo.getColValue("peso_ajustado"):prop.getProperty("peso_ajustado"),true,false,false,60,"form-control input-sm","width:100px",null)%>
			</td>
		</tr>

		<%if(fg.trim().equalsIgnoreCase("LAC")){%>
		<tr>
			<td class="controls form-inline">
				<b>Peso/Edad:</b>
				<%=fb.textBox("peso_edad", prop.getProperty("peso_edad"),true,false,viewMode,60,"form-control input-sm","width:100px",null)%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<b>Peso/Talla:</b>
				<%=fb.textBox("peso_talla", prop.getProperty("peso_talla"),true,false,viewMode,60,"form-control input-sm","width:100px",null)%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<b>Talla/Edad:</b>
				<%=fb.textBox("talla_edad", prop.getProperty("talla_edad"),true,false,viewMode,60,"form-control input-sm","width:100px",null)%>
			</td>
		</tr>
		<%}%>

		<tr>
				<td class="controls form-inline">
						<b>Terapia Nutricional Ordenada:</b>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<button type="button" id="btn_nutricion" class="btn btn-inverse btn-sm">
							 <i class="fa fa-eye fa-lg"></i> Nutrici&oacute;n
						</button>
						<%if(fg.trim().equalsIgnoreCase("uci")){%>
						<!--<button type="button" id="btn_ant_alergicos" class="btn btn-inverse btn-sm">
							 <i class="fa fa-eye fa-lg"></i> Antecendes Al&eacute;gicos
						</button>
						<button type="button" id="btn_eval_2" class="btn btn-inverse btn-sm">
								<i class="fa fa-eye fa-lg"></i> Evaluaci&oacute;n I
						</button>-->
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">Sin estr&eacute;s&nbsp;<%=fb.radio("estres","0",(prop.getProperty("estres")!=null && prop.getProperty("estres").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">Estr&eacute;s Moderado&nbsp;<%=fb.radio("estres","1",(prop.getProperty("estres")!=null && prop.getProperty("estres").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">Estr&eacute;s Severo&nbsp;<%=fb.radio("estres","2",(prop.getProperty("estres")!=null && prop.getProperty("estres").equalsIgnoreCase("2")),viewMode,false,"", null,"","","")%></label>
						<%}%>
				</td>
		</tr>

		<%if(fg.trim().equalsIgnoreCase("uci")||fg.trim().equalsIgnoreCase("pe")||fg.trim().equalsIgnoreCase("lac")||fg.trim().equalsIgnoreCase("AD")){%>
		<tr>
			<td class="controls form-inline">
				<b>Antecedentes:</b>&nbsp;&nbsp;

				<button type="button" id="btn_ant_personales" class="btn btn-inverse btn-sm">
					 <i class="fa fa-eye fa-lg"></i> Antecedentes Personales
				</button>
				<button type="button" id="btn_ant_familiares" class="btn btn-inverse btn-sm">
					 <i class="fa fa-eye fa-lg"></i> Antecedentes Familiares
				</button>
				<br>

				<%if(!fg.trim().equalsIgnoreCase("lac")){%>
				<label for="ant_personales_0" class="pointer">Diabetes</label>
				<%=fb.checkbox("ant_personales_0","0",(prop.getProperty("ant_personales_0").equalsIgnoreCase("0")),viewMode,"","","","")%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<label for="ant_personales_1" class="pointer">Hipertensi&oacute;n Arterial</label>
				<%=fb.checkbox("ant_personales_1","1",(prop.getProperty("ant_personales_1").equalsIgnoreCase("1")),viewMode,"","","","")%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<label for="ant_personales_2" class="pointer">Dislipidemia</label>
				<%=fb.checkbox("ant_personales_2","2",(prop.getProperty("ant_personales_2").equalsIgnoreCase("2")),viewMode,"","","","")%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<label for="ant_personales_3" class="pointer">Cardiopat&iacute;a</label>
				<%=fb.checkbox("ant_personales_3","3",(prop.getProperty("ant_personales_3").equalsIgnoreCase("3")),viewMode,"","","","")%>

				<br>
				<label for="ant_personales_4" class="pointer">Nefropat&iacute;a</label>
				<%=fb.checkbox("ant_personales_4","4",(prop.getProperty("ant_personales_4").equalsIgnoreCase("4")),viewMode,"","","","")%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<label for="ant_personales_5" class="pointer">Depresi&oacute;n</label>
				<%=fb.checkbox("ant_personales_5","5",(prop.getProperty("ant_personales_5").equalsIgnoreCase("5")),viewMode,"","","","")%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<label for="ant_personales_6" class="pointer">Otros</label>
				<%=fb.checkbox("ant_personales_6","OT",(prop.getProperty("ant_personales_6").equalsIgnoreCase("OT")),viewMode,"observacion should-type",null,"",""," data-index=1 data-message='Por favor indique los otros antecedentes personales'")%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				(Especifique):
				<%=fb.textBox("observacion1", prop.getProperty("observacion1"),false,false,viewMode||prop.getProperty("observacion1").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
				<%}%>
			</td>
		</tr>
		<%}%>

		<tr>
				<td>
						<%if(fg.trim().equalsIgnoreCase("uci")){%>
								<b>VALORACION DEL RIESGO NUTRICIONAL ACTUAL:</b>
						<%} else if(fg.trim().equalsIgnoreCase("pe")||fg.trim().equalsIgnoreCase("ad")||fg.trim().equalsIgnoreCase("lac")){%>
								<b>VALORACION GLOBAL SUBJETIVA:</b>
						<%}%>

						<button type="button" id="btn_eval_1" class="btn btn-inverse btn-sm">
								<i class="fa fa-eye fa-lg"></i> Evaluaci&oacute;n I
						</button>
						&nbsp;&nbsp;&nbsp;

						<%
						if (CmnMgr.vectorContains(vFormularios, "4")){%>
								<button type="button" id="btn_cribado_ped" class="btn btn-inverse btn-sm">
										<i class="fa fa-eye fa-lg"></i> Cribado Nutricional
								</button>
						<%} else if(CmnMgr.vectorContains(vFormularios,"3")){%>
								<button type="button" id="btn_cribado_em" class="btn btn-inverse btn-sm">
										<i class="fa fa-eye fa-lg"></i> Cribado Nutricional
								</button>
						<%} else {%>
								<button type="button" id="btn_cribado_1" class="btn btn-inverse btn-sm">
										<i class="fa fa-eye fa-lg"></i> Cribado Nutricional
								</button>
						<%}%>
				</td>
		</tr>

		<%if(fg.trim().equalsIgnoreCase("uci")){%>
		<tr>
				<td>
						<table cellspacing="0" class="table table-small-font table-bordered table-striped">
								<tr class="bg-headtabla2">
										<td>Par&aacute;metro de Evaluaci&oacute;n</td>
										<td>Valor</td>
										<td>Puntaje</td>
								</tr>
								<tr>
										<td><b>I.M.C:</b> <em>>20=0; 18.5 – 20= 1; <18.5= 2</em></td>
										<td>
												<%=fb.textBox("imc_param", cdo!=null&&cdo.getColValue("imc") != null?cdo.getColValue("imc"):prop.getProperty("imc_param"),false,false,true,60,"form-control input-sm","width:100px",null)%>
										</td>
										<td>
												<%=fb.textBox("imc_param_puntaje", prop.getProperty("imc_param_puntaje"),false,false,true,60,"form-control input-sm","width:100px",null)%>
										</td>
								</tr>
								<tr>
										<td>
												<b>P&eacute;rdida de Peso:</b>
												<br><em>Sin p&eacute;rdida = 0; &Uacute;ltimos 6 meses o no sabe = 1; &Uacute;ltimas 2 semanas = 2</em>
										</td>
										<td>
												<%=fb.select("perdida_peso","-1=- SELECCIONE -,0=SIN PÉRDIDA,1=ÚLTIMOS 6 MESES O NO SABE,2=ÚLTIMAS 2 SEMANAS",prop.getProperty("perdida_peso"),false,viewMode,0,"form-control input-sm","","")%>
										</td>
										<td>
												<%=fb.textBox("perdida_peso_puntaje", prop.getProperty("perdida_peso_puntaje"),false,false,viewMode,60,"form-control input-sm","width:100px",null)%>
										</td>
								</tr>
								<tr>
										<td>
												<b>Enfermedad aguda, sin alimentación o probabilidad de poca<br>o ninguna alimentación por m&aacute;s de 5 días. Agregar 2 puntos</b>
										</td>
										<td>
												<label class="pointer">SI&nbsp;<%=fb.radio("param_enf","2",(prop.getProperty("param_enf")!=null && prop.getProperty("param_enf").equalsIgnoreCase("2")),viewMode,false,"", null,"")%></label>
												&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
												<label class="pointer">NO&nbsp;<%=fb.radio("param_enf","0",(prop.getProperty("param_enf")!=null && prop.getProperty("param_enf").equalsIgnoreCase("0")),viewMode,false,"", null,"")%></label>
										</td>
										<td>
												<%=fb.textBox("param_enf_puntaje", prop.getProperty("param_enf_puntaje"),false,false,viewMode,60,"form-control input-sm","width:100px",null)%>
										</td>
								</tr>
								<tr>
										<td>
												<b>Total</b>
										</td>
										<td colspan="2">
												<%=fb.textBox("total_param", prop.getProperty("total_param"),false,false,true,60,"form-control input-sm","width:100px",null)%>
										</td>
								</tr>
								<tr>
										<td>
												<b>RIESGO NUTRICIONAL</b>
										</td>
										<td colspan="2">
												<%=fb.textBox("riesgo_nutricional_dsp", prop.getProperty("riesgo_nutricional_dsp"),false,false,true,60,"form-control input-sm","width:200px",null)%>
										</td>
								</tr>
						</table>
				</td>
		</tr>
		<%}%>

		<%if(fg.trim().equalsIgnoreCase("AD")){%>
				<tr>
						<td>
								<table cellspacing="0" class="table table-small-font table-bordered table-striped">
										<tr>
												<td><b>CAMBIOS DE INGESTA</b></td>
												<td>
														<label class="pointer">Ninguno&nbsp;<%=fb.radio("cambio_ingesta_ad","0",(prop.getProperty("cambio_ingesta_ad")!=null && prop.getProperty("cambio_ingesta_ad").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Sólidos incompletos&nbsp;<%=fb.radio("cambio_ingesta_ad","1",(prop.getProperty("cambio_ingesta_ad")!=null && prop.getProperty("cambio_ingesta_ad").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Líquidos hipocalóricos o pocos sólidos&nbsp;<%=fb.radio("cambio_ingesta_ad","2",(prop.getProperty("cambio_ingesta_ad")!=null && prop.getProperty("cambio_ingesta_ad").equalsIgnoreCase("2")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Ayuno o muy pocos líquidos &nbsp;<%=fb.radio("cambio_ingesta_ad","3",(prop.getProperty("cambio_ingesta_ad")!=null && prop.getProperty("cambio_ingesta_ad").equalsIgnoreCase("3")),viewMode,false,"", null,"","","")%></label>
												</td>
										</tr>
										<tr>
												<td><b>SINTOMAS GASTROINTESTINALES</b></td>
												<td>
														<button type="button" id="btn_get" class="btn btn-inverse btn-sm">
																<i class="fa fa-eye fa-lg"></i> G.E.T
														</button>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Ninguno&nbsp;<%=fb.radio("sintomas_gastro_ad","0",(prop.getProperty("sintomas_gastro_ad")!=null && prop.getProperty("sintomas_gastro_ad").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Nauseas o estreñimiento&nbsp;<%=fb.radio("sintomas_gastro_ad","1",(prop.getProperty("sintomas_gastro_ad")!=null && prop.getProperty("sintomas_gastro_ad").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Dolor abdominal, Diarrea o vomito&nbsp;<%=fb.radio("sintomas_gastro_ad","2",(prop.getProperty("sintomas_gastro_ad")!=null && prop.getProperty("sintomas_gastro_ad").equalsIgnoreCase("2")),viewMode,false,"", null,"","","")%></label>
												</td>
										</tr>
										<tr>
												<td><b>CAPACIDAD FUNCIONAL</b></td>
												<td>
														<button type="button" id="btn_funcional" class="btn btn-inverse btn-sm">
																<i class="fa fa-eye fa-lg"></i> Funcional
														</button>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

														<label class="pointer">Normal&nbsp;<%=fb.radio("capacidad_funcional_ad","0",(prop.getProperty("capacidad_funcional_ad")!=null && prop.getProperty("capacidad_funcional_ad").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Masticación o depresión&nbsp;<%=fb.radio("capacidad_funcional_ad","1",(prop.getProperty("capacidad_funcional_ad")!=null && prop.getProperty("capacidad_funcional_ad").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Disfagia&nbsp;<%=fb.radio("capacidad_funcional_ad","2",(prop.getProperty("capacidad_funcional_ad")!=null && prop.getProperty("capacidad_funcional_ad").equalsIgnoreCase("2")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Paciente encamado&nbsp;<%=fb.radio("capacidad_funcional_ad","3",(prop.getProperty("capacidad_funcional_ad")!=null && prop.getProperty("capacidad_funcional_ad").equalsIgnoreCase("3")),viewMode,false,"", null,"","","")%></label>
												</td>
										</tr>


										<tr>
												<td><b>EXAMEN FISICO</b></td>
												<td>
														<label class="pointer">Normal&nbsp;<%=fb.radio("examen_fisico_ad","0",(prop.getProperty("examen_fisico_ad")!=null && prop.getProperty("examen_fisico_ad").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Pérdida de Grasa subcutánea leve&nbsp;<%=fb.radio("examen_fisico_ad","1",(prop.getProperty("examen_fisico_ad")!=null && prop.getProperty("examen_fisico_ad").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Pérdida de Masa Muscular leve&nbsp;<%=fb.radio("examen_fisico_ad","2",(prop.getProperty("examen_fisico_ad")!=null && prop.getProperty("examen_fisico_ad").equalsIgnoreCase("2")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Pérdida de Grasa subcutánea moderada&nbsp;<%=fb.radio("examen_fisico_ad","3",(prop.getProperty("examen_fisico_ad")!=null && prop.getProperty("examen_fisico_ad").equalsIgnoreCase("3")),viewMode,false,"", null,"","","")%></label><br>

														<label class="pointer">Pérdida de Masa Muscular moderada&nbsp;<%=fb.radio("examen_fisico_ad","4",(prop.getProperty("examen_fisico_ad")!=null && prop.getProperty("examen_fisico_ad").equalsIgnoreCase("4")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

														<label class="pointer">Lesiones mucosas, ulceras&nbsp;<%=fb.radio("examen_fisico_ad","5",(prop.getProperty("examen_fisico_ad")!=null && prop.getProperty("examen_fisico_ad").equalsIgnoreCase("5")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

														<label class="pointer">Edema moderado a grave&nbsp;<%=fb.radio("examen_fisico_ad","6",(prop.getProperty("examen_fisico_ad")!=null && prop.getProperty("examen_fisico_ad").equalsIgnoreCase("6")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

														<label class="pointer">Ascitis&nbsp;<%=fb.radio("examen_fisico_ad","7",(prop.getProperty("examen_fisico_ad")!=null && prop.getProperty("examen_fisico_ad").equalsIgnoreCase("7")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

												</td>
										</tr>


										 <tr>
												<td><b>RIESGO NUTRICIONAL</b></td>
												<td>
														<label class="pointer">BIEN NUTRIDO&nbsp;<%=fb.radio("riesgo_nutricional_ad","A",(prop.getProperty("riesgo_nutricional_ad")!=null && prop.getProperty("riesgo_nutricional_ad").equalsIgnoreCase("A")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">MALNUTRIDO MODERADO O SOSPECHA DE MALNUTRICION&nbsp;<%=fb.radio("riesgo_nutricional_ad","B",(prop.getProperty("riesgo_nutricional_ad")!=null && prop.getProperty("riesgo_nutricional_ad").equalsIgnoreCase("B")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">SEVERAMENTE MALNUTRIDO&nbsp;<%=fb.radio("riesgo_nutricional_ad","C",(prop.getProperty("riesgo_nutricional_ad")!=null && prop.getProperty("riesgo_nutricional_ad").equalsIgnoreCase("C")),viewMode,false,"", null,"","","")%></label>
												</td>
										</tr>
								</table>
						</td>
				</tr>
		<%}%>


		<%if(fg.trim().equalsIgnoreCase("PE")){%>
				<tr>
						<td>
								<table cellspacing="0" class="table table-small-font table-bordered table-striped">
										<tr>
												<td><b>Apetito</b></td>
												<td>
														<label class="pointer">Buen apetito&nbsp;<%=fb.radio("apetito_pe","0",(prop.getProperty("apetito_pe")!=null && prop.getProperty("apetito_pe").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Disminuci&oacute;n del apetito&nbsp;<%=fb.radio("apetito_pe","1",(prop.getProperty("apetito_pe")!=null && prop.getProperty("apetito_pe").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Pobre apetito&nbsp;<%=fb.radio("apetito_pe","2",(prop.getProperty("apetito_pe")!=null && prop.getProperty("apetito_pe").equalsIgnoreCase("2")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Incapaz de comer por v&iacute;a oral &nbsp;<%=fb.radio("apetito_pe","3",(prop.getProperty("apetito_pe")!=null && prop.getProperty("apetito_pe").equalsIgnoreCase("3")),viewMode,false,"", null,"","","")%></label>
												</td>
										</tr>

										<tr>
												<td><b>S&iacute;ntomas Gastrointestinales</b></td>
												<td>
														<label class="pointer">Sin s&iacute;ntomas&nbsp;<%=fb.radio("sintomas_gastro_pe","0",(prop.getProperty("sintomas_gastro_pe")!=null && prop.getProperty("sintomas_gastro_pe").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Estre&ntilde;imiento&nbsp;<%=fb.radio("sintomas_gastro_pe","1",(prop.getProperty("sintomas_gastro_pe")!=null && prop.getProperty("sintomas_gastro_pe").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Vomito o diarrea leve a moderada (1-3v/d&iacute;a)&nbsp;<%=fb.radio("sintomas_gastro_pe","2",(prop.getProperty("sintomas_gastro_pe")!=null && prop.getProperty("sintomas_gastro_pe").equalsIgnoreCase("2")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Vomito severo y/o diarrea severa (>3v/d&iacute;a)&nbsp;<%=fb.radio("sintomas_gastro_pe","3",(prop.getProperty("sintomas_gastro_pe")!=null && prop.getProperty("sintomas_gastro_pe").equalsIgnoreCase("3")),viewMode,false,"", null,"","","")%></label>
												</td>
										</tr>

										<tr>
												<td><b>Capacidad Funcional</b></td>
												<td>
														<label class="pointer">Sin dificultades para tragar&nbsp;<%=fb.radio("capacidad_funcional_pe","0",(prop.getProperty("capacidad_funcional_pe")!=null && prop.getProperty("capacidad_funcional_pe").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">Con dificultad para tragar&nbsp;<%=fb.radio("capacidad_funcional_pe","1",(prop.getProperty("capacidad_funcional_pe")!=null && prop.getProperty("capacidad_funcional_pe").equalsIgnoreCase("1")),viewMode,false,"", null,"","","")%></label>
												</td>
										</tr>

										<tr>
												<td><b>RIESGO NUTRICIONAL</b></td>
												<td>
														<label class="pointer">BIEN NUTRIDO&nbsp;<%=fb.radio("riesgo_nutricional_pe","A",(prop.getProperty("riesgo_nutricional_pe")!=null && prop.getProperty("riesgo_nutricional_pe").equalsIgnoreCase("A")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">MALNUTRIDO MODERADO O SOSPECHA DE MALNUTRICION&nbsp;<%=fb.radio("riesgo_nutricional_pe","B",(prop.getProperty("riesgo_nutricional_pe")!=null && prop.getProperty("riesgo_nutricional_pe").equalsIgnoreCase("B")),viewMode,false,"", null,"","","")%></label>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<label class="pointer">SEVERAMENTE MALNUTRIDO&nbsp;<%=fb.radio("riesgo_nutricional_pe","C",(prop.getProperty("riesgo_nutricional_pe")!=null && prop.getProperty("riesgo_nutricional_pe").equalsIgnoreCase("C")),viewMode,false,"", null,"","","")%></label>
												</td>
										</tr>

								</table>
						</td>
				</tr>
		<%}%>

		<%if(fg.trim().equalsIgnoreCase("UCI")||fg.trim().equalsIgnoreCase("AD")||fg.trim().equalsIgnoreCase("PE")||fg.trim().equalsIgnoreCase("LAC")){%>
		<tr>
				<td>
						<b>Diagn&oacute;stico Nutricional:</b>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">Desnutrici&oacute;n&nbsp;<%=fb.radio("diag_nutricional","0",(prop.getProperty("diag_nutricional")!=null && prop.getProperty("diag_nutricional").equalsIgnoreCase("0")),viewMode,false,"", null,"")%></label>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">Bajo peso&nbsp;<%=fb.radio("diag_nutricional","1",(prop.getProperty("diag_nutricional")!=null && prop.getProperty("diag_nutricional").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">Normal&nbsp;<%=fb.radio("diag_nutricional","2",(prop.getProperty("diag_nutricional")!=null && prop.getProperty("diag_nutricional").equalsIgnoreCase("2")),viewMode,false,"", null,"")%></label>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">Sobrepeso&nbsp;<%=fb.radio("diag_nutricional","3",(prop.getProperty("diag_nutricional")!=null && prop.getProperty("diag_nutricional").equalsIgnoreCase("3")),viewMode,false,"", null,"")%></label>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">Obesidad&nbsp;<%=fb.radio("diag_nutricional","4",(prop.getProperty("diag_nutricional")!=null && prop.getProperty("diag_nutricional").equalsIgnoreCase("4")),viewMode,false,"", null,"")%></label>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">Obesidad M&oacute;rbida&nbsp;<%=fb.radio("diag_nutricional","5",(prop.getProperty("diag_nutricional")!=null && prop.getProperty("diag_nutricional").equalsIgnoreCase("5")),viewMode,false,"", null,"")%></label>
				</td>
		</tr>
		<%}%>

		<%if(fg.trim().equalsIgnoreCase("pe")||fg.trim().equalsIgnoreCase("lac")){%>
				<tr>
						<td>
								<b>Patr&oacute;n Usual de Alimentaci&oacute;n:</b>&nbsp;&nbsp;&nbsp;
								<button type="button" id="btn_ant_neonatales" class="btn btn-inverse btn-sm">
										<i class="fa fa-eye fa-lg"></i> Antecedentes Neonatales
								</button>
								&nbsp;&nbsp;&nbsp;&nbsp;
						</td>
				</tr>

				<tr>
						<td>
								<b>Lactancia:</b>&nbsp;&nbsp;&nbsp;
								<label class="pointer">Materna&nbsp;<%=fb.radio("lactancia","0",(prop.getProperty("lactancia")!=null && prop.getProperty("lactancia").equalsIgnoreCase("0")),viewMode,false,"", null,"")%></label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer">Formula&nbsp;<%=fb.radio("lactancia","1",(prop.getProperty("lactancia")!=null && prop.getProperty("lactancia").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer">Ambas&nbsp;<%=fb.radio("lactancia","2",(prop.getProperty("lactancia")!=null && prop.getProperty("lactancia").equalsIgnoreCase("2")),viewMode,false,"", null,"")%></label>
						</td>
				</tr>
				<tr>
						<td class="controls form-inline">
								<b>Alimentaci&oacute;n Complementaria:</b>
								<%=fb.textBox("alimentacion_complementaria", prop.getProperty("alimentacion_complementaria"),false,false,viewMode,60,"form-control input-sm","width:800px",null)%><br>

								<button type="button" id="btn_ant_alergicos2" class="btn btn-inverse btn-sm">
										<i class="fa fa-eye fa-lg"></i> Antecendes Al&eacute;gicos
								</button>
								<button type="button" id="btn_eval_3" class="btn btn-inverse btn-sm">
										<i class="fa fa-eye fa-lg"></i> Evaluaci&oacute;n I
								</button>

								<button type="button" id="btn_inhaloterapia" class="btn btn-inverse btn-sm">
									 <i class="fa fa-eye fa-lg"></i> Medicamentos
								</button>
								<button type="button" id="btn_laboratorios" class="btn btn-inverse btn-sm">
									 <i class="fa fa-eye fa-lg"></i> O/M Laboratorios
								</button>
						</td>
				</tr>
		<%}%>

		<%if(fg.trim().equalsIgnoreCase("uci")||fg.trim().equalsIgnoreCase("ad")){%>
		<tr>
				<td class="controls form-inline">
						<button type="button" id="btn_ant_alergicos2" class="btn btn-inverse btn-sm">
								<i class="fa fa-eye fa-lg"></i> Antecendes Al&eacute;gicos
						</button>
						<button type="button" id="btn_eval_3" class="btn btn-inverse btn-sm">
								<i class="fa fa-eye fa-lg"></i> Evaluaci&oacute;n I
						</button>

						<button type="button" id="btn_inhaloterapia" class="btn btn-inverse btn-sm">
							 <i class="fa fa-eye fa-lg"></i> Medicamentos
						</button>
						<button type="button" id="btn_laboratorios" class="btn btn-inverse btn-sm">
							 <i class="fa fa-eye fa-lg"></i> O/M Laboratorios
						</button><br><br>
						<b>Interacci&oacute;n F&aacute;rmaco-Nutriente:</b>
						<%=fb.textBox("interaccion_far_nutri", prop.getProperty("interaccion_far_nutri"),false,false,viewMode,60,"form-control input-sm","width:600px",null)%>
				</td>
		</tr>
		<%}%>

		<%if(fg.trim().equalsIgnoreCase("ADM")){%>
		<tr>
				<td>
				<%@ include file="../expediente3.0/exp_eval_nutricional_pac_riesgo_adulto_mayor.jsp"%>
				</td>
		</tr>
		<%}%>

		<tr class="bg-headtabla" id="plan-de-accion">
				<td class="controls form-inline">
						PLAN DE ACCION
				</td>
		</tr>

		<tr>
				<td>
						<b>SI</b>&nbsp;&nbsp;&nbsp;<em>(Al marcar indica Si)</em><br>
						<label class="pointer">
						<%=fb.checkbox("plan_accion0","0",(prop.getProperty("plan_accion0").equalsIgnoreCase("0")),viewMode,"","","","")%>
						Paciente no est&aacute; en alto riesgo nutricional en estos momentos.
						</label>
				</td>
		</tr>
		<tr>
				<td class="controls form-inline">
						<label class="pointer">
						<%=fb.checkbox("plan_accion1","1",(prop.getProperty("plan_accion1").equalsIgnoreCase("1")),viewMode,"","","","")%>
						 Paciente en riesgo nutricional:
						</label>
						<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">
						<%=fb.checkbox("plan_accion2","2",(prop.getProperty("plan_accion2").equalsIgnoreCase("2")),viewMode,"","","","")%>
							Se notifica al médico de cabecera
						</label>
						<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">
						<%=fb.checkbox("plan_accion3","3",(prop.getProperty("plan_accion3").equalsIgnoreCase("3")),viewMode,"","","","")%>
							Se vigila cada&nbsp;
						</label>
						<%=fb.textBox("frecuencia_vigilencia", prop.getProperty("frecuencia_vigilencia"),false,false,viewMode,60,"form-control input-sm","width:50px",null)%>&nbsp;d&iacute;as

						<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">
						<%=fb.checkbox("plan_accion4","4",(prop.getProperty("plan_accion4").equalsIgnoreCase("4")),viewMode,"","","","")%>
							 Se realiza control de ingestión. <em>(Técnica de enfermería llena formulario y se deja en la habitación del paciente)</em>
						</label>

						<br>
						<label class="pointer">
						<%=fb.checkbox("plan_accion5","5",(prop.getProperty("plan_accion5").equalsIgnoreCase("5")),viewMode,"","","","")%>
							Se visitó al paciente para obtener preferencias alimentarias y meriendas
						</label>

						<br>
						<label class="pointer">
						<%=fb.checkbox("plan_accion6","6",(prop.getProperty("plan_accion6").equalsIgnoreCase("6")),viewMode,"","","","")%>
							 Paciente / familiar/ persona que cuida, familiarizado con las modificaciones dietéticas.
						</label>

						<br>
						<label class="pointer">
						<%=fb.checkbox("plan_accion10","10",(prop.getProperty("plan_accion10").equalsIgnoreCase("10")),viewMode,"","","","")%>
							 Se entrega volante educativa sobre dieta actual
						</label>

						<%=fb.textBox("plan_dieta", prop.getProperty("plan_dieta"),false,false,viewMode,60,"form-control input-sm","width:200px",null)%>

						<br>
						<label class="pointer">
						<%=fb.checkbox("plan_accion7","7",(prop.getProperty("plan_accion7").equalsIgnoreCase("7")),viewMode,"","","","")%>Se entrega volante educativa sobre Diabetes
						</label>

						<%//if(fg.trim().equalsIgnoreCase("UCI")||fg.trim().equalsIgnoreCase("ad")){%>
						<br>
						<label class="pointer">
						<%=fb.checkbox("plan_accion8","8",(prop.getProperty("plan_accion8").equalsIgnoreCase("8")),viewMode,"","","","")%>Se entrega volante educativa sobre Interacción medicamento alimento (Warfarina)
						</label>

						<br>
						<b>Paciente Cirugía Bariátrica:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">SI&nbsp;<%=fb.radio("cirugia_bariatrica","1",(prop.getProperty("cirugia_bariatrica")!=null && prop.getProperty("cirugia_bariatrica").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<label class="pointer">NO&nbsp;<%=fb.radio("cirugia_bariatrica","0",(prop.getProperty("cirugia_bariatrica")!=null && prop.getProperty("cirugia_bariatrica").equalsIgnoreCase("0")),viewMode,false,"", null,"")%></label>

						<br>
						<label class="pointer">
						<%=fb.checkbox("plan_accion9","9",(prop.getProperty("plan_accion9").equalsIgnoreCase("9")),viewMode,"","","","")%>Se entrega recomendaciones generales de cirugía Bariátrica.
						</label>
						<%//}%>
				</td>
		</tr>

		<tr>
				<td class="controls form-inline">
						<b>Observaciones:</b>
						<%=fb.textarea("observacion2",prop.getProperty("observacion2"),false,false,viewMode,0,1,0,"form-control input-sm","width:100%","")%>
				</td>
		</tr>



</table>
<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr>
			 <td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,allow?viewMode:true,"btn btn-primary btn-sm",null,"")%>
				
				<%if(!code.equals("0") && prop != null && prop.getProperty("status") != null && !prop.getProperty("status").equalsIgnoreCase("I")){%>
				<%=fb.button("inactivar","Inactivar",true,estado.equalsIgnoreCase("F"),"btn btn-sm btn-danger",null,"onClick='doSubmit(this.form, this.value)'")%>
				<%}%>
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
	
	String errCode = "1";
	String errMsg = "";
	String errException = "";
	
	if (baction.equalsIgnoreCase("Inactivar")) {
		CommonDataObject param = new CommonDataObject();
		
		prop = SQLMgr.getDataProperties("select params from tbl_sal_eval_nutri_riesgo where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+code+" and tipo = '"+fg+"'");
		prop.setProperty("status","I");
		prop.setProperty("status_dsp","INACTIVO");
		
		param.setSql("update tbl_sal_eval_nutri_riesgo set params = ?, usuario_modificacion = ?, fecha_modificacion = sysdate, status = ? where pac_id = ? and admision = ? and codigo = ? and tipo = ?");
		param.addInBinaryStmtParam(1, prop);
		param.addInStringStmtParam(2, (String)session.getAttribute("_userName"));
		param.addInStringStmtParam(3, "I");
		param.addInNumberStmtParam(4, request.getParameter("pacId")); 
		param.addInNumberStmtParam(5, request.getParameter("noAdmision")); 
		param.addInNumberStmtParam(6, code); 
		param.addInStringStmtParam(7, request.getParameter("fg"));
		
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"inactivar=Y&modeSec="+modeSec+"&fg="+fg+"&pacId="+pacId+"&noAdmision="+noAdmision+"&seccion="+seccion);
		SQLMgr.executePrepared(param);
			errCode = SQLMgr.getErrCode();
			errMsg = SQLMgr.getErrMsg();
			errException = SQLMgr.getErrException();
		ConMgr.clearAppCtx(null);

	} else {

		prop = new Properties();
		
		prop.setProperty("status","A");
		prop.setProperty("status_dsp","ACTIVO");
		prop.setProperty("pac_id",request.getParameter("pacId"));
		prop.setProperty("admision",request.getParameter("noAdmision"));
		prop.setProperty("codigo",request.getParameter("code"));
		prop.setProperty("tipo",request.getParameter("fg"));
		prop.setProperty("usuario_creacion", UserDet.getUserName());
		prop.setProperty("fecha_creacion", cDateTime);
		prop.setProperty("usuario_modificacion", UserDet.getUserName());
		prop.setProperty("fecha_modificacion", cDateTime);

		prop.setProperty("fecha", request.getParameter("fecha"));
		prop.setProperty("talla", request.getParameter("talla"));
		prop.setProperty("peso", request.getParameter("peso"));
		prop.setProperty("imc", request.getParameter("imc"));
		prop.setProperty("sexo", request.getParameter("sexo"));
		prop.setProperty("peso_ajustado", request.getParameter("peso_ajustado"));
		prop.setProperty("formulario", request.getParameter("formulario"));
		prop.setProperty("plan_dieta", request.getParameter("plan_dieta"));
		prop.setProperty("frecuencia_vigilencia", request.getParameter("frecuencia_vigilencia"));
		prop.setProperty("cirugia_bariatrica", request.getParameter("cirugia_bariatrica"));

		if(fg.trim().equalsIgnoreCase("LAC")){
			prop.setProperty("peso_edad", request.getParameter("peso_edad"));
			prop.setProperty("peso_talla", request.getParameter("peso_talla"));
			prop.setProperty("talla_edad", request.getParameter("talla_edad"));
		}

		if(fg.trim().equalsIgnoreCase("uci")){
			prop.setProperty("estres", request.getParameter("estres"));
			prop.setProperty("imc_param", request.getParameter("imc_param"));
			prop.setProperty("imc_param_puntaje", request.getParameter("imc_param_puntaje"));
			prop.setProperty("perdida_peso", request.getParameter("perdida_peso"));
			prop.setProperty("perdida_peso_puntaje", request.getParameter("perdida_peso_puntaje"));
			prop.setProperty("param_enf", request.getParameter("param_enf"));
			prop.setProperty("param_enf_puntaje", request.getParameter("param_enf_puntaje"));
			prop.setProperty("total_param", request.getParameter("total_param"));
			prop.setProperty("riesgo_nutricional_dsp", request.getParameter("riesgo_nutricional_dsp"));
			prop.setProperty("diag_nutricional", request.getParameter("diag_nutricional"));
			prop.setProperty("interaccion_far_nutri", request.getParameter("interaccion_far_nutri"));
		} else if(fg.trim().equalsIgnoreCase("pe")||fg.trim().equalsIgnoreCase("lac")){
			prop.setProperty("apetito_pe", request.getParameter("apetito_pe"));
			prop.setProperty("sintomas_gastro_pe", request.getParameter("sintomas_gastro_pe"));
			prop.setProperty("capacidad_funcional_pe", request.getParameter("capacidad_funcional_pe"));
			prop.setProperty("riesgo_nutricional_pe", request.getParameter("riesgo_nutricional_pe"));
			prop.setProperty("lactancia", request.getParameter("lactancia"));
			prop.setProperty("alimentacion_complementaria", request.getParameter("alimentacion_complementaria"));

		} else if(fg.trim().equalsIgnoreCase("ad")){
			prop.setProperty("cambio_ingesta_ad", request.getParameter("cambio_ingesta_ad"));
			prop.setProperty("sintomas_gastro_ad", request.getParameter("sintomas_gastro_ad"));
			prop.setProperty("capacidad_funcional_ad", request.getParameter("capacidad_funcional_ad"));
			prop.setProperty("examen_fisico_ad", request.getParameter("examen_fisico_ad"));
			prop.setProperty("riesgo_nutricional_ad", request.getParameter("riesgo_nutricional_ad"));
			prop.setProperty("interaccion_far_nutri", request.getParameter("interaccion_far_nutri"));

		} else if(fg.trim().equalsIgnoreCase("adm")){

			prop.setProperty("total_cribaje", request.getParameter("total_cribaje"));
			prop.setProperty("total_cribaje_dsp", request.getParameter("total_cribaje_dsp"));
			prop.setProperty("total_eval", request.getParameter("total_eval"));
			prop.setProperty("total_global", request.getParameter("total_global"));
			prop.setProperty("total_global_dsp", request.getParameter("total_global_dsp"));

			for (int i = 1; i < 20; i++) {
				if(request.getParameter("resulta_"+i)!=null) prop.setProperty("resulta_"+i, request.getParameter("resulta_"+i));
				if(request.getParameter("pregunta_"+i)!=null) prop.setProperty("pregunta_"+i, request.getParameter("pregunta_"+i));
				if(request.getParameter("pregunta_12_"+i)!=null) prop.setProperty("pregunta_12_"+i, request.getParameter("pregunta_12_"+i));
			}
		}

		for (int i = 0; i < 20; i++) {
			if(request.getParameter("ant_personales_"+i)!=null) prop.setProperty("ant_personales_"+i, request.getParameter("ant_personales_"+i));
			if(request.getParameter("plan_accion"+i)!=null) prop.setProperty("plan_accion"+i, request.getParameter("plan_accion"+i));

			if(request.getParameter("observacion"+i)!=null) prop.setProperty("observacion"+i, request.getParameter("observacion"+i));
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add"))
			{
				EvalNutriMgr.add(prop);
				code = EvalNutriMgr.getPkColValue("codigo");
			}
			else EvalNutriMgr.update(prop);
			
			errCode = EvalNutriMgr.getErrCode();
			errMsg = EvalNutriMgr.getErrMsg();
			errException = EvalNutriMgr.getErrException();
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow(){
<% if (errCode.equals("1")) { %>
	alert('<%=errMsg%>');
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
} else throw new Exception(errException);
%>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>';}
</script>
</head>
<body onLoad="closeWindow()"></body>
</html>
<% } %>
