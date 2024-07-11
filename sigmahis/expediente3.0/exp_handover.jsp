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
<jsp:useBean id="THMgr" scope="page" class="issi.expediente.TrasladoHandover" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
THMgr.setConnection(ConMgr);

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
String cds = request.getParameter("cds");
String estado = request.getParameter("estado");
String key="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String compania = (String) session.getAttribute("_companyId");

if (estado == null) estado = "";
if (code == null) code = "0";
if (cds == null) cds = "-9";
if (fg == null) fg = "SAD";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

CommonDataObject cdoSV = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (!code.trim().equals("0")) {
			prop = SQLMgr.getDataProperties("select params from tbl_sal_traslado_handover where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+code);

			if (prop == null) {
				prop = new Properties();
			} else {
				if(!viewMode) modeSec = "edit";
			}

		} else {
				cdo = SQLMgr.getData("select (select codigo||' - '||descripcion from tbl_cds_centro_servicio where codigo = "+cds+") centro_servicio,(select nvl(join(cursor(select (select descripcion from tbl_sal_tipo_alergia where codigo = z.tipo_alergia)||' ('||nvl(z.observacion,'  ')||')' from (select distinct a.tipo_alergia, join(cursor(select observacion from tbl_sal_alergia_paciente where pac_id = a.pac_id and aplicar = 'S' and tipo_alergia = a.tipo_alergia and observacion is not null order by admision),', ') as observacion from tbl_sal_alergia_paciente a where a.pac_id = "+pacId+" and a.admision="+noAdmision+" and a.aplicar = 'S'  and exists(select null from tbl_sal_tipo_alergia where codigo=a.tipo_alergia and es_alergia='S'  )) z),'; '),'') alergias from dual ) as antAlergia , (select join(cursor(select  a.diagnostico ||' - '|| coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id ="+pacId+" and tipo = 'I' order by a.orden_diag  ),'; ') from dual) as diag,nvl(( select total from tbl_sal_escalas x where pac_id = "+pacId+" and admision = "+noAdmision+" and id = (select max(id) from tbl_sal_escalas where pac_id = "+pacId+" and admision = "+noAdmision+"  and tipo ='DO' )  and tipo ='DO' ),0) as caidaAdulto,nvl(( select total from tbl_sal_escalas x where pac_id = "+pacId+" and admision = "+noAdmision+" and id = (select max(id) from tbl_sal_escalas where pac_id = "+pacId+" and admision = "+noAdmision+"  and tipo ='MAC' )  and tipo ='MAC' ),0) as caidaNinos  from dual ");

				if (cdo == null) cdo = new CommonDataObject();

				prop.setProperty("fecha_traslado", cDateTime);
				prop.setProperty("persona_que_reporta", UserDet.getName());
				prop.setProperty("cds_persona_que_reporta", cdo.getColValue("centro_servicio"," "));
		prop.setProperty("observacion7-1", cdo.getColValue("diag"," "));

		if(!cdo.getColValue("caidaNinos","0").trim().equals("0"))if(Integer.parseInt(cdo.getColValue("caidaNinos"))> 3 )prop.setProperty("riesgo_caida","0");
			if(!cdo.getColValue("caidaAdulto","0").trim().equals("0"))if(Integer.parseInt(cdo.getColValue("caidaAdulto"))> 5 )prop.setProperty("riesgo_caida","0");


				sbSql.append("select c.dolor, c.escala, (select decode(instr(b.resultado,'/'),0,b.resultado,substr(b.resultado,0,instr(b.resultado,'/') - 1)) from tbl_sal_detalle_signo b, tbl_sal_signo_vital a where b.pac_id = ");
				sbSql.append(pacId);
				sbSql.append(" and b.secuencia = ");
				sbSql.append(noAdmision);
				sbSql.append(" and a.codigo = b.signo_vital and ( b.signo_vital in (get_sec_comp_param(");
				sbSql.append(compania);
				sbSql.append(",'SAL_REANIMACION_CARDIO_PA_S')) or (b.signo_vital in (get_sec_comp_param(");
				sbSql.append(compania);
				sbSql.append(",'SAL_REANIMACION_CARDIO_PA_D')) and instr(b.resultado,'/') > 0) ) and b.pac_id = c.pac_id and b.secuencia = c.secuencia and b.fecha_signo = c.fecha and b.hora = c.hora)||'/'||(select decode(instr(b.resultado,'/'),0,b.resultado,substr(b.resultado,instr(b.resultado,'/') + 1)) from tbl_sal_detalle_signo b, tbl_sal_signo_vital a where b.pac_id = ");
				sbSql.append(pacId);
				sbSql.append(" and b.secuencia = ");
				sbSql.append(noAdmision);
				sbSql.append(" and a.codigo = b.signo_vital and ( b.signo_vital in (get_sec_comp_param(");
				sbSql.append(compania);
				sbSql.append(",'SAL_REANIMACION_CARDIO_PA_D')) or (b.signo_vital in (get_sec_comp_param (");
				sbSql.append(compania);
				sbSql.append(", 'SAL_REANIMACION_CARDIO_PA_S')) and instr(b.resultado,'/') > 0) ) and b.pac_id = c.pac_id and b.secuencia = c.secuencia and b.fecha_signo = c.fecha and b.hora = c.hora) presion_arterial");

				sbSql.append(",(select b.resultado from tbl_sal_detalle_signo b, tbl_sal_signo_vital a where b.pac_id = ");
				sbSql.append(pacId);
				sbSql.append(" and b.secuencia = ");
				sbSql.append(noAdmision);
				sbSql.append(" and a.codigo = b.signo_vital and a.codigo = get_sec_comp_param(");
				sbSql.append(compania);
				sbSql.append(",'SAL_REANIMACION_CARDIO_FC') and b.pac_id = c.pac_id and b.secuencia = c.secuencia and b.fecha_signo = c.fecha and b.hora = c.hora) frecuencia_cardica");

				sbSql.append(",(select b.resultado from tbl_sal_detalle_signo b, tbl_sal_signo_vital a where b.pac_id = ");
				sbSql.append(pacId);
				sbSql.append(" and b.secuencia = ");
				sbSql.append(noAdmision);
				sbSql.append(" and a.codigo = b.signo_vital and a.codigo = get_sec_comp_param(");
				sbSql.append(compania);
				sbSql.append(",'SAL_REANIMACION_CARDIO_T') and b.pac_id = c.pac_id and b.secuencia = c.secuencia and b.fecha_signo = c.fecha and b.hora = c.hora) temperatura");

				sbSql.append(",(select b.resultado from tbl_sal_detalle_signo b, tbl_sal_signo_vital a where b.pac_id = ");
				sbSql.append(pacId);
				sbSql.append(" and b.secuencia = ");
				sbSql.append(noAdmision);
				sbSql.append(" and a.codigo = b.signo_vital and a.codigo = get_sec_comp_param(");
				sbSql.append(compania);
				sbSql.append(",'SAL_REANIMACION_CARDIO_FR') and b.pac_id = c.pac_id and b.secuencia = c.secuencia and b.fecha_signo = c.fecha and b.hora = c.hora) respiracion");

				sbSql.append(" from tbl_sal_signo_paciente c where c.pac_id = ");
				sbSql.append(pacId);
				sbSql.append(" and c.secuencia = ");
				sbSql.append(noAdmision);
				sbSql.append(" and c.status = 'A' and c.fecha_creacion = ( select max(fecha_creacion) from tbl_sal_signo_paciente where pac_id = ");
				sbSql.append(pacId);
				sbSql.append(" and secuencia = ");
				sbSql.append(noAdmision);
				sbSql.append(" and status = 'A')");

				cdoSV = SQLMgr.getData(sbSql.toString());

				if (cdoSV == null) cdoSV = new CommonDataObject();
		Properties propAl = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = 'NEEU' and rownum=1 ");
		if (propAl != null) {

			if(propAl.getProperty("alergia0").equalsIgnoreCase("N")&&cdo.getColValue("antAlergia").trim().equals("")){prop.setProperty("alergia","1");}
			else
			{
				String alergia="";

				if(propAl.getProperty("alergia1").equalsIgnoreCase("A")){if(!alergia.trim().equals(""))alergia += ", ";alergia += "ALIMENTOS";}
				if(propAl.getProperty("alergia2").equalsIgnoreCase("AI")){if(!alergia.trim().equals(""))alergia += ", ";alergia += "AINES";}
				if(propAl.getProperty("alergia3").equalsIgnoreCase("AT")){if(!alergia.trim().equals(""))alergia += ", ";alergia += "ANTIBIOTICOS";}
				if(propAl.getProperty("alergia4").equalsIgnoreCase("M")){if(!alergia.trim().equals(""))alergia += ", "; alergia += "MEDICAMENTOS";}
				if(propAl.getProperty("alergia5").equalsIgnoreCase("Y")){if(!alergia.trim().equals(""))alergia += ", "; alergia += "YODO";}
				if(propAl.getProperty("alergia6").equalsIgnoreCase("S")){if(!alergia.trim().equals(""))alergia += ", "; alergia += "SULFA";}
				if(propAl.getProperty("alergia7").equalsIgnoreCase("O")){if(!alergia.trim().equals(""))alergia += ", "; alergia += "OTROS - "+propAl.getProperty("otros8");}

				if(!cdo.getColValue("antAlergia").trim().equals(""))alergia += " - Antecedentes --> "+cdo.getColValue("antAlergia");

				if(!alergia.trim().equals("")){prop.setProperty("alergia","0");prop.setProperty("observacion5",alergia);}
				else prop.setProperty("alergia","1");
			}
			if(propAl.getProperty("antpat0").equalsIgnoreCase("N")){prop.setProperty("historia_medica_relevante","1");}
						else
						{
							String ant="";

							if(propAl.getProperty("antpat1").equalsIgnoreCase("H")){if(!ant.trim().equals(""))ant += ", ";ant += "Hipertensión Arterial";}
							if(propAl.getProperty("antpat2").equalsIgnoreCase("D")){if(!ant.trim().equals(""))ant += ", "; ant += "Diabetes";}
							if(propAl.getProperty("antpat3").equalsIgnoreCase("PR")){if(!ant.trim().equals(""))ant += ", "; ant += "Problemas Renales";}
							if(propAl.getProperty("antpat4").equalsIgnoreCase("O")){if(!ant.trim().equals(""))ant += ", "; ant += "Otros - "+prop.getProperty("otros9");}
							if(!ant.trim().equals("")){prop.setProperty("historia_medica_relevante","0");prop.setProperty("observacion8",ant);}
							else prop.setProperty("historia_medica_relevante","1");
						}
		}
		propAl = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = 'C1' and rownum=1 ");
		 if (propAl != null)
		 {

			if(propAl.getProperty("aislamiento").equalsIgnoreCase("N")){prop.setProperty("aislamiento","1");}
			else
			{
				String aislamiento="";

if(propAl.getProperty("aislamiento_det0").equalsIgnoreCase("0")){ if(!aislamiento.trim().equals(""))aislamiento += ", ";aislamiento += "Orientación al paciente y familiar";}
if(propAl.getProperty("aislamiento_det1").equalsIgnoreCase("1")){ if(!aislamiento.trim().equals(""))aislamiento += ", ";aislamiento += "Paciente con Aislamiento de Contacto";}
if(propAl.getProperty("aislamiento_det2").equalsIgnoreCase("2")){ if(!aislamiento.trim().equals(""))aislamiento += ", ";aislamiento += "Coordinación con la enfermera de nosocomial";}
if(propAl.getProperty("aislamiento_det3").equalsIgnoreCase("3")){ if(!aislamiento.trim().equals(""))aislamiento += ", ";aislamiento += "Paciente Con Aislamiento de Gotas";}
if(propAl.getProperty("aislamiento_det4").equalsIgnoreCase("4")){ if(!aislamiento.trim().equals(""))aislamiento += ", ";aislamiento += "Colocación del equipo de protección";}
if(propAl.getProperty("aislamiento_det5").equalsIgnoreCase("5")){ if(!aislamiento.trim().equals(""))aislamiento += ", ";aislamiento += "Paciente con Aislamiento Respiratorio (Gotitas)";}
if(propAl.getProperty("aislamiento_det6").equalsIgnoreCase("6")){ if(!aislamiento.trim().equals(""))aislamiento += ", ";aislamiento += "Otros aislamientos - "+propAl.getProperty("observacion27") ;}
				if(!aislamiento.trim().equals("")){prop.setProperty("aislamiento","0");prop.setProperty("observacion6",aislamiento);}
				else prop.setProperty("aislamiento","1");
			}


		 }

		 }

		ArrayList alH = SQLMgr.getDataList("select codigo, to_char(fecha_creacion, 'dd/mm/yyyy') fc, to_char(fecha_creacion, 'hh12:mi am') hc, usuario_creacion from tbl_sal_traslado_handover where pac_id="+pacId+" and admision="+noAdmision+" order by 1 desc");

		session.setAttribute("_prop", prop);
		session.setAttribute("_SQLMgr", SQLMgr);

	 boolean isComplete = prop != null && !"".equals(prop.getProperty("persona_que_recibe_nombre"));

	 if (!isComplete && !modeSec.equalsIgnoreCase("add")) {
			// prop.setProperty("persona_que_recibe_nombre", UserDet.getName());
	 }

	 if (estado.equalsIgnoreCase("F")) isComplete = true;

	 System.out.println(":::::::::::::::::::::::::::::::::::::::::: isComplete = "+isComplete);

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
		var reporte = $("#reporte_transferencia").val() || '0';
		abrir_ventana("../expediente3.0/print_exp_handover.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>&reporte="+reporte);
	});

	//
	$("#ss").click(function(){$(".ss").toggle()});
	$("#ba").click(function(){$(".ba").toggle()});
	$("#ae").click(function(){$(".ae").toggle()});
	$("#rr").click(function(){$(".rr").toggle()});

	//
	$(".should-type").click(function(){
			var that = $(this);
			_shouldType(that);
	});

	$("input[name='motivo']").click(function(){
		var self = $(this);
		var i = self.data('index');
		$(".observ-motivo").val("").prop("readOnly", true);
		$("#observacion"+i).prop("readOnly", false);
	});

	// ver antecedentes alergicos
	$("#btn_ant_alergicos").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_exp_seccion_11.jsp?seccion=11&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=ANTECEDENTES ALERGICOS&fg=handover");
	});
	$("#btn_eval_1").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_exp_seccion_108.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=NEEU&seccion=108&desc=EVALUACION INICIAL I DE ENFERMERIA&fp=handover");
	});

	// ver aislamiento
	$("#btn_aislamiento").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_cuestionarios.jsp?seccion=123&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=EVALUACION II&fp=handover&fg=C1");
	});

	// ver diagnosticos de ingreso
	$("#btn_diag_ing").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente/print_exp_seccion_89.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=89&desc=DIAGNOSTICOS DE INGRESO&fp=handover");
	});

	// load listas
	$("input[name='reporte_transferencia']").click(function(){
		$.get('../expediente3.0/exp_handover_lista.jsp?lista='+this.value+'&modeSec=<%=modeSec%>')
		 .done(function(data){
				var d = $.trim(data);
				$("#lista_container").empty().html(d);
				$("#totLista").val($(d).filter("#tot_lista").val());
				$(".should-type").click(function(){
					var that = $(this);
					_shouldType(that);
				});
		 })
	});

	// reloading alerts
	if (typeof parent.reloadAlerts === 'function') parent.reloadAlerts();
	else if (typeof parent.parent.reloadAlerts === 'function') parent.parent.reloadAlerts();

	// get medico
	if (!$("#medico").val()) $("#medico").val($("#medico", parent.window.document).val());
	if (!$("#medico_nombre").val()) $("#medico_nombre").val($("#nombreMedico", parent.window.document).val());


});

function verHistorial() {$("#hist_container").toggle();}
function medicoList(){
	abrir_ventana1('../common/search_medico.jsp?fp=handover');
}

function _shouldType(that) {
		var i = that.data('index');
		if (that.is(":checked")) {
				$("#observacion"+i).prop("readOnly", false);
				$("#observacion_lista_"+i).prop("readOnly", false);
		} else {
				$("#observacion"+i).val("").prop("readOnly", true);
				$("#observacion_lista_"+i).val("").prop("readOnly", true);
		}
}

function empleadoList(opt){
		if (opt == 1)
				abrir_ventana1('../common/search_empleado.jsp?fp=handover&fg=quien_recibe_handover&index=');
		else
				abrir_ventana1('../common/search_empleado.jsp?fp=handover&fg=quien_reporta_handover&index=');
}

function cdsList(option) {
 var fg = option == 1 ? 'reporta' : 'recibe';
 abrir_ventana1('../common/search_centro_servicio.jsp?fp=handover&fg='+fg);
}

function setCurrent(code){
		window.location = '../expediente3.0/exp_handover.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&cds=<%=cds%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&code='+code;
}
function add(){window.location = '../expediente3.0/exp_handover.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&cds=<%=cds%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>';}

function shouldTypeRadio(check, textareaIndex) {
	if (check == true) $("#observacion"+textareaIndex).prop("readOnly", false)
	else $("#observacion"+textareaIndex).val("").prop("readOnly", true)
}

function shouldTypeRadioList(check, textareaIndex) {
	if (check == true) $("#observacion_lista_"+textareaIndex).prop("readOnly", false)
	else $("#observacion_lista_"+textareaIndex).val("").prop("readOnly", true)
}

function showError(message) {
	parent.parent.CBMSG.error(message);
}

function scrollToElem(el) {
		$('html, body').animate({
				scrollTop: parseInt($(el).offset().top, 10)
		}, 500);
}

function canSubmit() {
	var proceed = true;
	$(".observacion, .observacion_lista").each(function() {
		var $self = $(this);
		var i = $self.data('index');
		var message = $self.data('message');
		var lista = $self.attr('id') == 'seleccionado_'+i ? '_lista_' : '';
		var obs = $("#observacion"+lista+i);

		if ( $self.is(":checked") && !$.trim(obs.val())) {
			showError(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
			proceed = false;
			obs.focus();
			return false;
		}else  {proceed = true;}
	});

	if ( $("input[name^='motivo']:checked").length < 1 ) {
		showError('Por favor seleccionar el motivo en el grupo SITUACION S/S!');
		scrollToElem($("input[name='medico']").get(0))
		return false;
	}
	else if ($("input[name^='reporte_transferencia']:checked").length < 1 || $("input[name^='seleccionado_']:checked").length < 1) {
		showError('Por favor seleccionar el Reporte de Tranferencia y su Verificación en el grupo ANTECEDENTES B/A!');
		scrollToElem($("input[name^='observacion7']").get(0))
		return false;
	}
	else if ( $("input[name^='condicion_actual']:checked").length < 1 ) {
			showError('Por favor seleccionar por lo menos una condición actual en el grupo EVALUACION A/E!');
			scrollToElem($("input[name^='condicion_actual']").get(0))
			return false;
	} else if ($("input[name^='req_pers_']:checked").length < 1) {
		showError('Por favor seleccionar por lo menos un Requerimiento de Personal en el grupo RECOMENDACION R/R!');
		scrollToElem($("input[name^='req_pers_']").get(0))
		return false;
	} else if ($("input[name^='req_equipos_']:checked").length < 1) {
		showError('Por favor seleccionar por lo menos un Requerimiento de Equipos en el grupo RECOMENDACION R/R!');
		scrollToElem($("input[name^='req_equipos_']").get(0))
		return false;
	}

	return proceed;
}

function genAlerta() {
		var reporta = $.trim($("#persona_que_reporta").val());
		var recibe = $.trim($("#persona_que_recibe_nombre").val());
		var isComplete = <%=isComplete%>;
		if (!isComplete){
				if (reporta && !recibe) $("#gen_alerta").val("Y");
				else if (recibe) $("#gen_alerta").val("N");
		} else $("#gen_alerta").val("N");

		return true;
}

function consultar() {
	abrir_ventana1('../expediente3.0/exp_handover_list.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&cds=<%=cds%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>');
}
function recibir(fp) {
	top.showPopWin('../expediente3.0/exp_handover_rec.jsp?modeSec=edit&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&cds=<%=cds%>&noAdmision=<%=noAdmision%>&code=<%=code%>&fg=<%=fg%>&fp='+fp,winWidth*.85,winHeight*.75,null,null,'');
}
$(document).ready(function(){
	$("input:checkbox[name*='req_equipos_']").not($("#req_equipos_0")).click(function(c){
		var that = $(this);
		var niega = $("#req_equipos_0").is(":checked")
		if (niega) {
			c.preventDefault();
			c.stopPropagation();
		$("#observacion11").prop("readOnly", true);
			return false;
		} else {
		 var $self = $(this)
		 if ($self.is(":checked") && $self.val() == '4')
		 {
				$("#observacion11").prop("readOnly", false);
		 }
		}/**/
	});
		//observacion11
	$("#req_equipos_0").click(function(){
		if ($(this).is(":checked")) {
			$("input:checkbox[name*='req_equipos_']").not($("#req_equipos_0")).prop("checked", false)
			$("#observacion11").prop("readOnly", true).val("");
		}
	});
	// cant be-checked
	$(".cant-be-checked").click(function(e){
			e.preventDefault();
			e.stopPropagation();
			return false;
	});/**/
});
</script>
<style>
		<%if(modeSec.equalsIgnoreCase("add")){%>
		.ss,.ba,.ae,.rr{display:none}
		<%}%>
</style>
</head>
<body class="body-form">
<div class="row">

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%if(!viewMode){%>
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%}%>
<%fb.appendJsValidation("if(!genAlerta()) { error++; }");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("code", code)%>
<%=fb.hidden("estado", estado)%>
<%=fb.hidden("totLista", prop.getProperty("totLista"))%>
<%=fb.hidden("gen_alerta", "")%>

		<div class="headerform">
				<table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
						<tr>
								<td>
											<%if(!code.equalsIgnoreCase("0")){%>
											<button type="button" class="btn btn-inverse btn-sm" onclick="recibir('REC')">
												<i class="fa fa-list"></i> <b>Recibir</b>
											</button>
											<button type="button" class="btn btn-inverse btn-sm" onclick="recibir('REC2')">
												<i class="fa fa-list"></i> <b>Reenvío Servicios de Apoyo</b>
											</button><%}%>
											<button type="button" class="btn btn-inverse btn-sm" onclick="consultar()">
												<i class="fa fa-list"></i> <b>Consultar</b>
											</button>
											<%=fb.button("imprimir","Imprimir",false,false,null,null,"")%>
											<%if(!mode.equalsIgnoreCase("view")){%>
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
						for (int p = 1; p <= alH.size(); p++){
								CommonDataObject cdoH = (CommonDataObject)alH.get(p-1);
						%>
						<tbody>
								<tr onclick="javascript:setCurrent('<%=cdoH.getColValue("codigo")%>')" class="pointer">
										<td><%=cdoH.getColValue("codigo")%></td>
										<td><%=cdoH.getColValue("fc")%></td>
										<td><%=cdoH.getColValue("hc")%></td>
										<td><%=cdoH.getColValue("usuario_creacion")%></td>
								</tr>
						</tbody>
						<% }%>
				</table>
		</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<tr class="pointer" id="ss">
				<td style="background-color: brown !important"><b>SITUACION S/S</b></td>
		</tr>
		<tr class="ss">
				<td class="controls form-inline">
						<b>Fecha:</b>
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_traslado" />
								<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
								<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_traslado")%>" />
								<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
						</jsp:include>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<b>M&eacute;dico:</b>
						<%=fb.textBox("medico", prop.getProperty("medico"),false,false,true,30,"form-control input-sm","display:inline; width:80px",null)%>
						<%=fb.textBox("medico_nombre", prop.getProperty("medico_nombre"),false,false,true,30,"form-control input-sm","display:inline; width:250px",null)%>
						<%=fb.button("btn_medico","...",true,viewMode,null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
				</td>
		</tr>

		<tr class="ss">
				<td class="controls form-inline">
						<b>Persona que reporta:</b>&nbsp;<%=fb.textBox("persona_que_reporta", prop.getProperty("persona_que_reporta"),false,false,true,30,"form-control input-sm","display:inline; width:250px",null)%>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<b>&Aacute;rea:</b>&nbsp;<%=fb.textBox("cds_persona_que_reporta", prop.getProperty("cds_persona_que_reporta"),false,false,true,30,"form-control input-sm","display:inline; width:250px",null)%>
						<%=fb.button("btn_cds_reporta","...",true,viewMode,null,null,"onClick=\"javascript:cdsList(1)\"","seleccionar centros")%>
				</td>
		</tr>
		<%if(!modeSec.trim().equals("xxx")){%>
		<tr class="ss">
				<td class="controls form-inline">
						<b>Persona que recibe el reporte:</b>&nbsp;<%=fb.textBox("persona_que_recibe_nombre", prop.getProperty("persona_que_recibe_nombre"),false,false,true,30,"form-control input-sm","display:inline; width:250px",null)%>
						<%=fb.hidden("persona_que_recibe","")%>
						<%=fb.button("btn_quien_recibe","...",true,false,null,null,"onClick=\"javascript:empleadoList(1)\"","seleccionar empleados")%>

						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<b>&Aacute;rea:</b>&nbsp;<%=fb.textBox("centro_servicio_recibe_desc", prop.getProperty("centro_servicio_recibe_desc"),false,false,true,30,"form-control input-sm","display:inline; width:250px",null)%>
						<%=fb.hidden("centro_servicio_recibe","")%>
						<%=fb.button("btn_cds_recibe","...",true,isComplete?viewMode:isComplete,null,null,"onClick=\"javascript:cdsList(2)\"","seleccionar centros")%>
				</td>
		</tr>
		<%}%>
		<tr class="ss">
				<td class="controls form-inline">
						<b>MOTIVOS</b><br>

						<label class="pointer"><%=fb.radio("motivo","0",(prop.getProperty("motivo")!=null && prop.getProperty("motivo").equalsIgnoreCase("0")),viewMode,false,"observacion_null", null,"",""," data-index=0 data-message='Por favor indique el motivo seleccionado!'")%>&nbsp;Para Preparación por Cirugía y/o Procedimiento</label>
						&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion0", prop.getProperty("observacion0"),false,false,viewMode||prop.getProperty("observacion0").equals(""),30,"form-control input-sm observ-motivo","display:inline; width:300px",null)%><br>

						<label class="pointer"><%=fb.radio("motivo","1",(prop.getProperty("motivo")!=null && prop.getProperty("motivo").equalsIgnoreCase("1")),viewMode,false,"observacion_null", null,"",""," data-index=1 data-message='Por favor indique el motivo seleccionado!'")%>&nbsp;Para Cirugía y/o Procedimiento</label>
						&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion1", prop.getProperty("observacion1"),false,false,viewMode||prop.getProperty("observacion1").equals(""),30,"form-control input-sm observ-motivo","display:inline; width:300px",null)%><br>

						<!--<label class="pointer"><%//=fb.radio("motivo","2",(prop.getProperty("motivo")!=null && prop.getProperty("motivo").equalsIgnoreCase("2")),viewMode,false,"observacion_null", null,"",""," data-index=2 data-message='Por favor indique el motivo seleccionado!'")%>&nbsp;Para Procedimiento</label>
						&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion2", prop.getProperty("observacion2"),false,false,viewMode||prop.getProperty("observacion2").equals(""),30,"form-control input-sm observ-motivo","display:inline; width:300px",null)%><br>-->

						<label class="pointer"><%=fb.radio("motivo","3",(prop.getProperty("motivo")!=null && prop.getProperty("motivo").equalsIgnoreCase("3")),viewMode,false,"observacion_null", null,"",""," data-index=13 data-message='Por favor indique el motivo seleccionado!'")%>&nbsp;Para Recuperación de anestesia</label>
						&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion13", prop.getProperty("observacion13"),false,false,viewMode||prop.getProperty("observacion13").equals(""),30,"form-control input-sm observ-motivo","display:inline; width:300px",null)%><br>

						<label class="pointer"><%=fb.radio("motivo","4",(prop.getProperty("motivo")!=null && prop.getProperty("motivo").equalsIgnoreCase("4")),viewMode,false,"", null,"",""," data-index=14 data-message='Por favor indique el motivo seleccionado!'")%>&nbsp;Traslado y/o movimiento a otro servicio</label>
						&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion14", prop.getProperty("observacion14"),false,false,viewMode||prop.getProperty("observacion14").equals(""),30,"form-control input-sm observ-motivo","display:inline; width:300px",null)%><br>

						<label class="pointer"><%=fb.radio("motivo","5",(prop.getProperty("motivo")!=null && prop.getProperty("motivo").equalsIgnoreCase("5")),viewMode,false,"", null,"",""," data-index=15 data-message='Por favor indique el motivo seleccionado!'")%>&nbsp;Traslado a otra Institución</label>&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion15", prop.getProperty("observacion15"),false,false,viewMode||prop.getProperty("observacion15").equals(""),30,"form-control input-sm observ-motivo","display:inline; width:300px",null)%><br>

						<label class="pointer"><%=fb.radio("motivo","6",(prop.getProperty("motivo")!=null && prop.getProperty("motivo").equalsIgnoreCase("6")),viewMode,false,"observacion_null", null,"",""," data-index=3 data-message='Por favor indique el motivo seleccionado!'")%>&nbsp;Para examen Radiología</label>
						&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion3", prop.getProperty("observacion3"),false,false,viewMode||prop.getProperty("observacion3").equals(""),30,"form-control input-sm observ-motivo","display:inline; width:300px",null)%><br>

						<label class="pointer"><%=fb.radio("motivo","7",(prop.getProperty("motivo")!=null && prop.getProperty("motivo").equalsIgnoreCase("7")),viewMode,false,"observacion_null", null,"",""," data-index=4 data-message='Por favor indique el motivo seleccionado!'")%>&nbsp;Otros (Diálisis, Fisioterapia)</label>
						&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion4", prop.getProperty("observacion4"),false,false,viewMode||prop.getProperty("observacion4").equals(""),30,"form-control input-sm observ-motivo","display:inline; width:300px",null)%><br>
				</td>
		</tr>

		<tr class="ss bg-headtabla2">
				<td>OBSERVACIONES IMPORTANTES</td>
		</tr>

		<tr class="ss">
				<td class="controls form-inline">
						<b>1. Alergias:</b>&nbsp;
						<!--<button type="button" id="btn_ant_alergicos" class="btn btn-inverse btn-sm">
							 <i class="fa fa-eye fa-lg"></i> Antecendes Al&eacute;gicos
						</button>
						<button type="button" id="btn_eval_1" class="btn btn-inverse btn-sm">
								<i class="fa fa-eye fa-lg"></i> Evaluaci&oacute;n I
						</button>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-->

						<label class="pointer"><%=fb.radio("alergia","0",(prop.getProperty("alergia")!=null && prop.getProperty("alergia").equalsIgnoreCase("0")),viewMode,false,"observacion", null,"onClick='shouldTypeRadio(true, 5)'",""," data-index=5 data-message='Por favor indique las alergias!'")%>&nbsp;SI</label>
						&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.radio("alergia","1",(prop.getProperty("alergia")!=null && prop.getProperty("alergia").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 5)'","","")%>&nbsp;NO</label>

						&nbsp;&nbsp;&nbsp;&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion5", prop.getProperty("observacion5"),false,false,viewMode||prop.getProperty("observacion5").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>

				</td>
		</tr>

		<tr class="ss">
				<td class="controls form-inline">
						<b>2. Aislamiento:</b>&nbsp;
						<!--<button type="button" id="btn_aislamiento" class="btn btn-inverse btn-sm">
								<i class="fa fa-eye fa-lg"></i> Aislamientos
						</button>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-->

				<label class="pointer"><%=fb.radio("aislamiento","0",(prop.getProperty("aislamiento")!=null && prop.getProperty("aislamiento").equalsIgnoreCase("0")),viewMode,false,"observacion", null,"onClick='shouldTypeRadio(true, 6)'",""," data-index=6 data-message='Por favor indique los aislamientos!'")%>&nbsp;SI</label>
				&nbsp;&nbsp;&nbsp;
				<label class="pointer"><%=fb.radio("aislamiento","1",(prop.getProperty("aislamiento")!=null && prop.getProperty("aislamiento").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 6)'","","")%>&nbsp;NO</label>

				&nbsp;&nbsp;&nbsp;&nbsp;
				(especifique):&nbsp;<%=fb.textBox("observacion6", prop.getProperty("observacion6"),false,false,viewMode||prop.getProperty("observacion6").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%><br>
				</td>
		</tr>

		<tr class="ss">
				<td class="controls form-inline">
						<b>2. Otros:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.textBox("observacion7", prop.getProperty("observacion7"),false,false,viewMode,30,"form-control input-sm","display:inline; width:300px",null)%><br>
				</td>
		</tr>

		<tr class="pointer" id="ba">
				<td style="background-color: #4286f4 !important"><b>ANTECEDENTES B/A</b></td>
		</tr>

		<tr class="ba">
				<td class="controls form-inline">
						<b>DIAGNÓSTICO DE INGRESO:</b>&nbsp;&nbsp;
<%=fb.textBox("observacion7-1", prop.getProperty("observacion7-1"),true,false,false,30,"form-control input-sm","display:inline; width:300px",null)%>
						<!-- <button type="button" id="btn_diag_ing" class="btn btn-inverse btn-sm">
							 <i class="fa fa-eye fa-lg"></i> Diagn&oacute;stico de ingreso
						</button>-->
				</td>
		</tr>

		<tr class="ba">
				<td class="controls form-inline">
						<b>HISTORIA MÉDICA RELEVANTE:</b>&nbsp;&nbsp;&nbsp;&nbsp;

						<label class="pointer"><%=fb.radio("historia_medica_relevante","0",(prop.getProperty("historia_medica_relevante")!=null && prop.getProperty("historia_medica_relevante").equalsIgnoreCase("0")),viewMode,false,"observacion", null,"onClick='shouldTypeRadio(true, 8)'",""," data-index=8 data-message='Por favor indique las historias médicas relevantes!'")%>&nbsp;SI</label>
						&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.radio("historia_medica_relevante","1",(prop.getProperty("historia_medica_relevante")!=null && prop.getProperty("historia_medica_relevante").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 8)'","","")%>&nbsp;NO</label>

						&nbsp;&nbsp;&nbsp;&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion8", prop.getProperty("observacion8"),false,false,viewMode||prop.getProperty("observacion8").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
				</td>
		</tr>

		<tr class="ba">
				<td class="controls form-inline">
						<b>REPORTE DE TRANSFERENCIA</b><br>
						<label class="pointer"><%=fb.radio("reporte_transferencia","1",(prop.getProperty("reporte_transferencia")!=null && prop.getProperty("reporte_transferencia").equalsIgnoreCase("1")),viewMode,false,"", null,"",""," data-lista=5")%>&nbsp;Verificación para el Salón de Operaciones y/o procedimiento</label><br>
						<label class="pointer"><%=fb.radio("reporte_transferencia","2",(prop.getProperty("reporte_transferencia")!=null && prop.getProperty("reporte_transferencia").equalsIgnoreCase("2")),viewMode,false,"", null,"",""," data-lista=5")%>&nbsp;Verificación para Radiología</label><br>
						<label class="pointer"><%=fb.radio("reporte_transferencia","3",(prop.getProperty("reporte_transferencia")!=null && prop.getProperty("reporte_transferencia").equalsIgnoreCase("3")),viewMode,false,"", null,"",""," data-lista=5")%>&nbsp;Verificación para el traslado de un área a otra. REPORTE DE TRANSFERENCIA (SI APLICA)
						</label><br>
						<label class="pointer"><%=fb.radio("reporte_transferencia","4",(prop.getProperty("reporte_transferencia")!=null && prop.getProperty("reporte_transferencia").equalsIgnoreCase("4")),viewMode,false,"", null,"",""," data-lista=5")%>&nbsp;Verificación para pausa de seguridad (ver formulario pausa de seguridad)
						</label><br>
				</td>
		</tr>

		<tr class="ba">
				<td id="lista_container">
						<%if(prop.getProperty("reporte_transferencia") != null && !"".equals(prop.getProperty("reporte_transferencia"))){%>
						<jsp:include page="../expediente3.0/exp_handover_lista.jsp" flush="true">
								<jsp:param name="modeSec" value="<%=modeSec%>"/>
								<jsp:param name="lista" value="<%=prop.getProperty("reporte_transferencia")%>"/>
						</jsp:include>
						<%}%>
				</td>
		</tr>

		<tr class="pointer" id="ae">
				<td style="background-color: #345b0b !important"><b>EVALUACION A/E</b></td>
		</tr>

		<tr class="ae">
				<td>
						<b>CONDICIÓN ACTUAL</b><br>
						<label class="pointer">Estable&nbsp;<%=fb.radio("condicion_actual","0",(prop.getProperty("condicion_actual")!=null && prop.getProperty("condicion_actual").equalsIgnoreCase("0")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 10)'",""," data-index=10")%></label>
						&nbsp;&nbsp;
						<label class="pointer">Crítica&nbsp;<%=fb.radio("condicion_actual","1",(prop.getProperty("condicion_actual")!=null && prop.getProperty("condicion_actual").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 10)'",""," data-index=10")%></label>
						&nbsp;&nbsp;
						<label class="pointer">Otro&nbsp;<%=fb.radio("condicion_actual","3",(prop.getProperty("condicion_actual")!=null && prop.getProperty("condicion_actual").equalsIgnoreCase("3")),viewMode,false,"observacion", null,"onClick='shouldTypeRadio(true, 10)'",""," data-index=10 data-message='Por favor indique las otras condiciones actuales!'")%></label>

						&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion10", prop.getProperty("observacion10"),false,false,viewMode||prop.getProperty("observacion10").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
						<br><br>

						<%
						if (code.trim().equals("0")){
								prop.setProperty("escala", cdoSV.getColValue("escala"," "));
								prop.setProperty("presion_arterial", cdoSV.getColValue("presion_arterial"," "));
								prop.setProperty("frecuencia_cardica", cdoSV.getColValue("frecuencia_cardica"," "));
								prop.setProperty("temperatura", cdoSV.getColValue("temperatura"," "));
								prop.setProperty("respiracion", cdoSV.getColValue("respiracion"," "));
						}
						%>

						<b>EVALUACIONES IMPORTANTES</b><br>
						<b>Dolor:</b>
						<%=fb.textBox("escala", prop.getProperty("escala"),false,false,viewMode,30,"form-control input-sm","display:inline; width:50px",null)%>
						&nbsp;&nbsp;&nbsp;&nbsp;
						Presi&oacute;n Arterial:
						<%=fb.textBox("presion_arterial", prop.getProperty("presion_arterial"),false,false,viewMode,30,"form-control input-sm","display:inline; width:100px",null)%> &nbsp;&nbsp;&nbsp;&nbsp;
						Frecuencia cardiaca:
						<%=fb.textBox("frecuencia_cardica", prop.getProperty("frecuencia_cardica"),false,false,viewMode,30,"form-control input-sm","display:inline; width:100px",null)%>&nbsp;&nbsp;&nbsp;&nbsp;
						Temperatura:
						<%=fb.textBox("temperatura", prop.getProperty("temperatura"),false,false,viewMode,30,"form-control input-sm","display:inline; width:100px",null)%> &nbsp;&nbsp;&nbsp;&nbsp;
						Respiración:
						<%=fb.textBox("respiracion", prop.getProperty("respiracion"),false,false,viewMode,30,"form-control input-sm","display:inline; width:100px",null)%>

						<br><br>
						<b>Riesgo de Ca&iacute;da:</b>
						&nbsp;
						<label class="pointer">Alto&nbsp;<%=fb.radio("riesgo_caida","0",(prop.getProperty("riesgo_caida")!=null && prop.getProperty("riesgo_caida").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
						&nbsp;&nbsp;
						<label class="pointer">Bajo&nbsp;<%=fb.radio("riesgo_caida","1",(prop.getProperty("riesgo_caida")!=null && prop.getProperty("riesgo_caida").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label><br>

						<label class="pointer">
						Otros Registros Importantes ( si se require)
						<%=fb.checkbox("otros_reg_importantes","0",(prop.getProperty("otros_reg_importantes").equals("0")),viewMode,"should-type observacion",null,"",""," data-index=9 data-message='Por favor indicar los otros registros importantes!'")%>
						</label>
						&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion9", prop.getProperty("observacion9"),false,false,viewMode||prop.getProperty("observacion9").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>

				</td>
		</tr>

		<tr class="pointer" id="rr">
				<td style="background-color: #c47b7b !important"><b>RECOMENDACION R/R</b></td>
		</tr>

		<tr class="rr">
				<td>
						<b>REQUERIMIENTO DE PERSONAL:</b>
						<br>
						<label class="pointer"><%=fb.checkbox("req_pers_0","0",prop.getProperty("req_pers_0").equals("0"),viewMode,"",null,"","","")%>&nbsp;Enfermera</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("req_pers_1","1",prop.getProperty("req_pers_1").equals("1"),viewMode,"",null,"","","")%>&nbsp;Médico</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("req_pers_2","2",prop.getProperty("req_pers_2").equals("2"),viewMode,"",null,"","","")%>&nbsp;Anestesiólogo</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("req_pers_3","3",prop.getProperty("req_pers_3").equals("3"),viewMode,"",null,"","","")%>&nbsp;Técnico</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("req_pers_4","4",(prop.getProperty("req_pers_4").equals("4")||(prop.getProperty("req_pers_0").equals("")&&prop.getProperty("req_pers_1").equals("")&&prop.getProperty("req_pers_2").equals("")&&prop.getProperty("req_pers_3").equals(""))),viewMode,"",null,"","","")%>&nbsp;Escolta</label><br><br>

						<b>DE EQUIPOS:</b>
						<br>
						<label class="pointer"><%=fb.checkbox("req_equipos_0","0",prop.getProperty("req_equipos_0").equals("0"),viewMode,"",null,"","","")%>&nbsp;NINGUNO</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("req_equipos_1","1",prop.getProperty("req_equipos_1").equals("1"),viewMode,"",null,"","","")%>&nbsp;Oxigeno</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("req_equipos_2","2",prop.getProperty("req_equipos_2").equals("2"),viewMode,"",null,"","","")%>&nbsp;Monitor de transporte</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("req_equipos_3","3",prop.getProperty("req_equipos_3").equals("3"),viewMode,"",null,"","","")%>&nbsp;Ambulancia</label>&nbsp;&nbsp;&nbsp;
						<label class="pointer"><%=fb.checkbox("req_equipos_4","4",prop.getProperty("req_equipos_4").equals("4"),viewMode,"should-type observacion",null,"",""," data-index=11 data-message='Por favor indicar los otros equipos requeridos!'")%>&nbsp;Otro</label>
						&nbsp;&nbsp;&nbsp;&nbsp;
						(especifique):&nbsp;<%=fb.textBox("observacion11", prop.getProperty("observacion11"),false,false,viewMode||prop.getProperty("observacion11").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
						<br><br>
						<b>RECOMENDACIONES (si se requiere):</b>&nbsp;
						<%=fb.textarea("observacion12",prop.getProperty("observacion12"),false,false,viewMode,0,1,0,"form-control input-sm","width:100%","")%>
				</td>
		</tr>

</table>

<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr>
			 <td>
						Opciones de Guardar:
						<label><%=fb.radio("saveOption","O",true,isComplete?viewMode:isComplete,false,null,null,null)%> Mantener Abierto</label>
						<label><%=fb.radio("saveOption","C",false,isComplete?viewMode:isComplete,false,null,null,null)%> Cerrar</label>
						<%=fb.submit("save","Guardar",true,isComplete?viewMode:isComplete,"",null,"")%>
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
		prop.setProperty("usuario_creacion", UserDet.getUserName());
		prop.setProperty("fecha_creacion", cDateTime);
		prop.setProperty("usuario_modificacion", UserDet.getUserName());
		prop.setProperty("fecha_modificacion", cDateTime);

		prop.setProperty("fecha_traslado", request.getParameter("fecha_traslado"));
		prop.setProperty("medico", request.getParameter("medico"));
		prop.setProperty("medico_nombre", request.getParameter("medico_nombre"));
		prop.setProperty("persona_que_reporta", request.getParameter("persona_que_reporta"));
		prop.setProperty("cds_persona_que_reporta", request.getParameter("cds_persona_que_reporta"));
		
		if(request.getParameter("persona_que_recibe_nombre") != null)prop.setProperty("persona_que_recibe_nombre", request.getParameter("persona_que_recibe_nombre"));
		if(request.getParameter("persona_que_recibe") != null)prop.setProperty("persona_que_recibe", request.getParameter("persona_que_recibe"));
		if(request.getParameter("centro_servicio_recibe_desc") != null)prop.setProperty("centro_servicio_recibe_desc", request.getParameter("centro_servicio_recibe_desc"));
		if(request.getParameter("centro_servicio_recibe") != null)prop.setProperty("centro_servicio_recibe", request.getParameter("centro_servicio_recibe"));
		
		prop.setProperty("motivo", request.getParameter("motivo"));
		prop.setProperty("alergia", request.getParameter("alergia"));
		prop.setProperty("aislamiento", request.getParameter("aislamiento"));
		prop.setProperty("historia_medica_relevante", request.getParameter("historia_medica_relevante"));
		prop.setProperty("reporte_transferencia", request.getParameter("reporte_transferencia"));
		prop.setProperty("totLista", request.getParameter("totLista"));
		prop.setProperty("riesgo_caida", request.getParameter("riesgo_caida"));
		prop.setProperty("otros_reg_importantes", request.getParameter("otros_reg_importantes"));
		prop.setProperty("condicion_actual", request.getParameter("condicion_actual")); 
		prop.setProperty("escala", request.getParameter("escala"));
		prop.setProperty("presion_arterial", request.getParameter("presion_arterial"));
		prop.setProperty("frecuencia_cardica", request.getParameter("frecuencia_cardica"));
		prop.setProperty("temperatura", request.getParameter("temperatura"));
		prop.setProperty("respiracion", request.getParameter("respiracion"));
		if(request.getParameter("gen_alerta")!=null && !request.getParameter("gen_alerta").trim().equals("")) prop.setProperty("gen_alerta", request.getParameter("gen_alerta"));

		for (int i = 0; i < 20; i++) {
				if (request.getParameter("observacion"+i) != null && !request.getParameter("observacion"+i).trim().equals("")) prop.setProperty("observacion"+i, request.getParameter("observacion"+i));
				if (request.getParameter("req_equipos_"+i) != null && !request.getParameter("req_equipos_"+i).trim().equals("")) prop.setProperty("req_equipos_"+i, request.getParameter("req_equipos_"+i));
				if (request.getParameter("req_pers_"+i) != null && !request.getParameter("req_pers_"+i).trim().equals("")) prop.setProperty("req_pers_"+i, request.getParameter("req_pers_"+i));
		}

		int totLista = request.getParameter("totLista")!=null&&!request.getParameter("totLista").trim().equals("") ? Integer.parseInt(request.getParameter("totLista")) : 0;

		for (int i = 0; i < totLista; i++) {
				if (request.getParameter("seleccionado_"+i) != null) prop.setProperty("seleccionado_"+i, request.getParameter("seleccionado_"+i));
				if (request.getParameter("observacion_lista_"+i) != null && !request.getParameter("observacion_lista_"+i).trim().equals("")) prop.setProperty("observacion_lista_"+i, request.getParameter("observacion_lista_"+i));
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
		{
				THMgr.add(prop);
				code = THMgr.getPkColValue("codigo");
		}
		else THMgr.update(prop);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow(){
<% if (THMgr.getErrCode().equals("1")) { %>
	alert('<%=THMgr.getErrMsg()%>');
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
} else throw new Exception(THMgr.getErrMsg());
%>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>&cds=<%=cds%>';}
</script>
</head>
<body onLoad="closeWindow()"></body>
</html>
<%
session.removeAttribute("_prop");
session.removeAttribute("_SQLMgr");
} %>
