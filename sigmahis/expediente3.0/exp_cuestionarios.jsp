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
<jsp:useBean id="cuestionario" scope="page" class="issi.expediente.CuestionarioMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
cuestionario.setConnection(ConMgr);

Properties prop = new Properties();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String compania = (String) session.getAttribute("_companyId");
String formularios = request.getParameter("formularios");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";

if (fg == null) fg = "AD";
if (from == null) from = "";
if (formularios == null) formularios = "";
java.util.Vector vFormularios = CmnMgr.str2vector(formularios);

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	
	prop = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = '"+fg+"'");
	if (prop == null){
		if(!viewMode) modeSec="add";
        prop = new Properties();
	}
	else{
		if(!viewMode) modeSec= "view"; 
	}
    
    System.out.println("-----------------------------------------------------------");
    System.out.println(prop);
    System.out.println("-----------------------------------------------------------");
    
    cdo = SQLMgr.getData("select (select diagnostico from tbl_adm_diagnostico_x_admision where pac_id = adm.pac_id and admision = adm.secuencia and tipo = 'I' and orden_diag = 1 and rownum = 1) codigo_diag, (select (select nvl(observacion, nombre) from tbl_cds_diagnostico where codigo = a.diagnostico ) from tbl_adm_diagnostico_x_admision a where pac_id = adm.pac_id and admision = adm.secuencia and tipo = 'I' and orden_diag = 1 and rownum = 1)  desc_diag,(select edad_mes end from vw_adm_paciente where pac_id = adm.pac_id) as edad_mes,(select edad from vw_adm_paciente where pac_id = adm.pac_id) as edad,(select sexo from vw_adm_paciente where pac_id = adm.pac_id) as sexo, get_sec_comp_param("+compania+", 'SAL_PED_EDAD') as edad_ped from tbl_adm_admision adm where adm.pac_id = "+pacId+" and adm.secuencia = "+noAdmision);
    
    if (cdo == null) {
        cdo = new CommonDataObject();
        cdo.addColValue("codigo_diag","NA");
        cdo.addColValue("desc_diag","NA");
        cdo.addColValue("edad","0");
        cdo.addColValue("edad_mes","0");
        cdo.addColValue("edad_ped","0");
    }
    int edad = Integer.parseInt(cdo.getColValue("edad"));
    int edadMes = Integer.parseInt(cdo.getColValue("edad_mes"));
    int edadPed = Integer.parseInt(cdo.getColValue("edad_ped","0"));
    ArrayList alC = new ArrayList();

    if (edad > 0 && edad < 4) {
      edadMes = edad * 12 + edadMes;
    } else if (edad >= 4) {
       edadMes = 0;
    }

    if (fg.trim().equalsIgnoreCase("PE")) {
        if (edadMes >=37 && edadMes <= 47) edadMes = 36;
        
        if (edadMes >= 0 && edadMes <= 36 && edad < 4) {
          alC = SQLMgr.getDataList("select codigo, mes, descripcion, grupo from tbl_sal_eval_creci_desarrollo where estado = 'A' and anio is null and mes = "+edadMes+" order by grupo");
        } else if (edad >=4 && edad <= 11) {
          alC = SQLMgr.getDataList("select codigo, mes, descripcion, grupo from tbl_sal_eval_creci_desarrollo where estado = 'A' and mes is null and anio = "+edad+" order by grupo"); 
        }
    }else {
        if (edad <= 19) {
          alC = SQLMgr.getDataList("select codigo, mes, descripcion, grupo from tbl_sal_eval_creci_desarrollo where estado = 'A' and mes is null and anio = "+edad+" order by grupo");
        }
    }
    
    if (modeSec.equalsIgnoreCase("view")) viewMode = true;
    if (mode.equalsIgnoreCase("view")) viewMode = true;
%>

<!DOCTYPE html>
<html lang="es"> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
var noNewHeight = true;
function doAction(){} 
$(document).ready(function(){
  $("#alergia0, #alergia7, input:checkbox[name*='alergia']").click(function(c){
    var thisName = $(this).attr("name");
	var thisObj = $(this);
	if (thisName=="alergia0"){ 
	  if (thisObj.is(":checked")) {
	    $("input[name^='alergia'], input:checkbox[name*='alergia']").not(thisObj).attr({
		  checked:false, disabled:true
		});
		$("#otros8").addClass("FormDataObjectDisabled").val("").attr({readonly:true})
	  }else {
	    $("input:hidden[name*='alergia']").val("");
	    $("input[id^='_alergia'], input:checkbox[name*='alergia']").attr('disabled',false);
	  }
	}else if (thisName=="alergia7"||thisName=="_alergia7Dsp"){
	  if (thisObj.is(":checked")) {
	    $("#otros8").removeClass("FormDataObjectDisabled").attr({readonly:false})
	  }else $("#otros8").addClass("FormDataObjectDisabled").val("").attr({readonly:true})
	}
  });  
  
  $("input[name='aislamiento']").click(function(){
    var $self = $(this);
    if ($self.is(":checked")) {
        if ($self.val() == 'N') {
            $(".aislamiento_det").prop({checked:false});
        }
    }
  });
  
  $(".aislamiento_det").click(function(e){
    var aislamiento = $("input[name='aislamiento']:checked").val();
    if (aislamiento && aislamiento == 'S') {
    } else {
      e.preventDefault();
      e.stopPropagation();
      return false;
    }
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
    
  //movimiento
  $('input[name^="dificultad_movimiento"]').on('click', function(event) {
        var that = $(this);
        var movimiento = $("input[name='movimiento']:checked").val();
        
        if (!movimiento || movimiento == 'N') {
          event.preventDefault();
          event.stopPropagation();
          return false;
        } else {
          if (that.is(":checked")){
            if (that.val() == 'OT') $("#observacion0").prop("readOnly", false)
          } else $("#observacion0").prop("readOnly", true).val("")
        }
    });
    
    $("input[name='movimiento']").click(function(){
      if (this.checked && this.value == 'N') {
         $('input[name^="dificultad_movimiento"]').prop("checked", false)
         $("#observacion0").prop("readOnly", true).val("")
      }
    });
    
    //necesidad
    $('input[name^="necesidad_especial"]').on('click', function(event) {
        var that = $(this);
        var necesidad = $("input[name='necesidad']:checked").val();
        
        if (!necesidad || necesidad == 'N') {
          event.preventDefault();
          event.stopPropagation();
          return false;
        } else {
          if (that.is(":checked")){
            if (that.val() == 'OT') $("#observacion1").prop("readOnly", false)
          } else $("#observacion1").prop("readOnly", true).val("")
        }
    });
    
    $("input[name='necesidad']").click(function(){
      if (this.checked && this.value == 'N') {
         $('input[name^="necesidad_especial"]').prop("checked", false)
         $("#observacion1").prop("readOnly", true).val("")
      }
    });
    
    //voluntades anticipadas 
    $('input[name^="no_no"]').on('click', function(event) {
        var that = $(this);
        var voluntad = $("input[name='voluntades_anticipadas']:checked").val();
        
        if (!voluntad || voluntad == 'N') {
          event.preventDefault();
          event.stopPropagation();
          return false;
        }
    });
    
    $("input[name='voluntades_anticipadas']").click(function(){
      if (this.checked && this.value == 'N') {
         $('input[name^="no_no"]').prop("checked", false)
      }
    });
    
    // Historia Gineco Obstetricia
    $("input[name='evolucion_embarazos']").click(function(){
      if (this.checked && this.value == 'N') {
         $('input[name^="embarazos_anteriores"], input[name^="partos_anteriores"], input[name^="malformaciones_congenitas"]').prop("checked", false)
         $("#observacion21").prop("readOnly", true).val("")
      }
    });
    $('input[name^="embarazos_anteriores"], input[name^="partos_anteriores"], input[name^="malformaciones_congenitas"]').click(function(event) {
      var evemb = $("input[name='evolucion_embarazos']:checked").val();
      if (!evemb || evemb == 'N') {
          $("#observacion21").prop("readOnly", true).val("")
          event.preventDefault();
          event.stopPropagation();
          return false;
      }
    });
    
    
    
    
    //Alcohol
    $('input[name="frecuencia_alcohol"]').on('click', function(event) {
        var that = $(this);
        var alcohol = $("input[name='ingiere_alcohol']:checked").val();
        
        if (!alcohol || alcohol == 'N') {
          event.preventDefault();
          event.stopPropagation();
          return false;
        } else {
          if (that.is(":checked")){
            if (that.val() == 'OT') $("#observacion7").prop("readOnly", false)
            else $("#observacion7").prop("readOnly", true).val("")
          } else $("#observacion7").prop("readOnly", true).val("")
        }
    });
    
    $("input[name='ingiere_alcohol']").click(function(){
      if (this.checked && this.value == 'N') {
         $('input[name^="frecuencia_alcohol"]').prop("checked", false)
         $("#observacion7").prop("readOnly", true).val("")
      }
    });
  
  //controlar
  var $obj;
  <%if(fg.trim().equalsIgnoreCase("C1")){%>
     $obj = $("input.peso");
  <%} else {%>
     $obj = $("input[name^='cribado_nutricional']");
  <%}%>
  var totSi = 0;
  $obj.click(function(){
    
    var selected = $obj.map(function(){
       if(this.checked &&this.value == 'S') return this.value;
    }).get();
       
    if (selected.length >= 2) {
      $("#nutricionista").prop("readOnly", false)
      $("#hora").prop("readOnly", false)
      $("#resethora").prop("disabled", false)
      $("#validar_nutricionista").val("Y");
    } // PE: 3 EM: 4
    else if ($("input:checked[name='nutricion_enteral'][value='S']").length || $("input:checked[name='problema_comunicacion'][value='S']").length || $("input:checked[name='unidad_cuidado'][value='S']").length || $("input:checked[name*='cribado_nutricional<%=fg.equalsIgnoreCase("PE")?"3":"4"%>'][value='E']").length || $("input:checked[name*='cribado_nutricional<%=fg.equalsIgnoreCase("PE")?"3":"4"%>'][value='D']").length|| $("input:checked[name*='cribado_nutricional<%=fg.equalsIgnoreCase("PE")?"4":"20"%>'][value='S']").length) {
      $("#nutricionista").prop("readOnly", false)
      $("#hora").prop("readOnly", false)
      $("#resethora").prop("disabled", false)
      $("#validar_nutricionista").val("Y");
    }    
    else {
      $("#nutricionista").prop("readOnly", true).val("")
      $("#hora").prop("readOnly", true).val("")
      $("#via").val("")
      $("#resethora").prop("disabled", true)
      $("#validar_nutricionista").val("");
    }
  });
  
  //sangrado transvaginal
  $("input[name='evaluacion_obstetrica2']").click(function(c){
    if ($(this).val() == 'S') {
      $("#cantidad").prop("readOnly", false)
      $("#color").prop("readOnly", false)
    } else {
      $("#cantidad").prop("readOnly", true).val("")
      $("#color").prop("readOnly", true).val("")
    }
  });
  
  //valoracion
  $("input[name='valoracion_quir'], input[name='explicacion_consentimiento'], input[name='protesis_dental'], input[name='lentes_contacto']").on('click', function(event) {
        var that = $(this);
        var valoracion = $("input[name='valoracion']:checked").val();
                
        if (!valoracion || valoracion == 'N') {
          event.preventDefault();
          event.stopPropagation();
          return false;
        }
    });
    
    $("input[name='valoracion']").click(function(c){
      if (this.value == 'S') {
        $("#ultima_comida").prop("readOnly", false)
        $("#observacion15").prop("readOnly", false)
        $("#resetultima_comida").prop("disabled", false)
      } else {
        $("#ultima_comida").prop("readOnly", true).val("")
        $("#observacion15").prop("readOnly", true).val("")
        $("#resetultima_comida").prop("disabled", true)
        $("input[name='valoracion_quir'], input[name='explicacion_consentimiento'], input[name='protesis_dental'], input[name='lentes_contacto']").prop("checked", false)
      }
    });
  
  
  
  // reloading alerts
  if (typeof parent.reloadAlerts === 'function') parent.reloadAlerts();
  else if (typeof parent.parent.reloadAlerts === 'function') parent.parent.reloadAlerts();
  
});

function showError(message) {
  <%=from.trim().equalsIgnoreCase("salida_pop")?"parent.":""%>parent.CBMSG.error(message);
}

/**
* el: dom element
*/
function scrollToElem(el) {
    if (el) {
        if (!el.scrollIntoView) {
          $('html, body').animate({
            scrollTop: parseInt($(el).offset().top, 10)
          }, 500);
        }
        else el.scrollIntoView();
    }
}

function canSubmit() {
  <%if(fg.trim().equalsIgnoreCase("C1")){%>
    if (!$("#fecha_ingreso").val() || !$("#hora_ingreso").val() ) {
        showError('Por favor indicar la fecha y hora de ingreso!');
        return false;
    } else if ( $("input[name='procedente']:checked").length < 1 || $("input[name='paciente_llego']:checked").length < 1 || $("input[name*='acompaniado_por']:checked").length < 1){
        showError('Por favor llenar todos los campos para: INGRESO DE PACIENTE');
        scrollToElem($("input[name='procedente']").get(0))
        return false;
    } else if ( $("input[name='aislamiento']:checked").length < 1 || ($("input[name='aislamiento'][value='S']:checked").length && $("input[name*='aislamiento_det']:checked").length < 1 )) {
        showError('Por favor llenar todos los campos para: EVALUACIÓN INICIAL DE LAS ENFERMEDADES TRANSMISIBLES');
        scrollToElem($("input[name*='aislamiento_det']").get(0))
        return false;
    } else if ( $("input[name='banio_higiene']:checked").length < 1 || $("input[name='vestir_desvestir_ali']:checked").length < 1 || $("input[name='movilidad_deambulacion']:checked").length < 1 || $("input[name='movimiento']:checked").length < 1 || $("input[name='necesidad']:checked").length < 1) {
        showError('Por favor llenar todos los campos para: VALORACION FUNCIONAL');
        scrollToElem($("input[name='banio_higiene']").get(0))
        return false; 
    } else if ( $("input[name='movimiento'][value='S']:checked").length && $("input[name*='dificultad_movimiento']:checked").length < 1){
        showError('Por favor llenar todos los campos para: VALORACION FUNCIONAL');
        scrollToElem($("input[name='banio_higiene']").get(0))
        return false;
    } else if ($("input[name='religion']:checked").length < 1 || $("input[name='creencia']:checked").length < 1 || $("input[name='servicio_religioso']:checked").length < 1 || $("input[name='voluntades_anticipadas']:checked").length < 1) {
        showError('Por favor llenar todos los campos para: VALORACION CREENCIAS / CULTURA / ESPIRITUAL');
        scrollToElem($("input[name='religion']").get(0))
        return false;
    } else if($("input[name='voluntades_anticipadas'][value='S']:checked").length && $("input[name*='no_no']:checked").length < 1){
        showError('Por favor llenar todos los campos para: VALORACION CREENCIAS / CULTURA / ESPIRITUAL');
        scrollToElem($("input[name='religion']").get(0))
        return false;
    } else if ( $("input[name='realiza_ejercicio']:checked").length < 1 || $("input[name='ingiere_alcohol']:checked").length < 1 || $("input[name='fumador']:checked").length < 1 || $("input[name='fumador_frecuencia']:checked").length < 1 || $("input[name='drogadicto']:checked").length < 1 || $("input[name='estado_salud']:checked").length < 1 ) {
        showError('Por favor llenar todos los campos para: EVALUACION SOCIAL Y ACTIVIDADES');
        scrollToElem($("input[name='realiza_ejercicio']").get(0))
        return false;
    } else if ($("input[name='vive_con']:checked").length < 1 || $("input[name='situacion_laboral']:checked").length < 1 || $("input[name='residencia_actual']:checked").length < 1 || $("input[name='aspecto_economico']:checked").length < 1 || $("input[name*='se_observa']:checked").length < 1 || $("input[name*='tiene_a_cargo']:checked").length < 1 ) {
        showError('Por favor llenar todos los campos para: VALORACION PSICOSOCIAL Y ECONOMICA');
        scrollToElem($("input[name='vive_con']").get(0))
        return false;
    } else if ($("input[name='valoracion']:checked").length < 1){
        showError('Por Indicar: VALORACION PARA PACIENTE QUIRURGICO (SOP y Hemodinámica)');
        scrollToElem($("input[name='valoracion']").get(0))
        return false;
    } else if ( $("input[name='valoracion'][value='S']:checked").length && ( $("input[name='valoracion_quir']:checked").length < 1 || $("input[name='explicacion_consentimiento']:checked").length < 1 || $("input[name='protesis_dental']:checked").length < 1 || $("input[name='lentes_contacto']:checked").length < 1 || !$("#ultima_comida").val() || !$.trim($("#observacion15").val())  ) ){
        showError('Por favor llenar todos los campos para: VALORACION PARA PACIENTE QUIRURGICO (SOP y Hemodinámica)');
        scrollToElem($("input[name='vive_con']").get(0))
        return false;
    } else if ($("input[name*='datos_obetenidos_de']:checked").length < 1 || $("input[name='medicos_enterados']:checked").length < 1) {
        showError('Por favor llenar todos los campos para: DATOS OBTENIDOS DE');
        scrollToElem($("input[name*='datos_obetenidos_de']").get(0))
        return false;
    } 
    <%if (!CmnMgr.vectorContains(vFormularios,"3") && !CmnMgr.vectorContains(vFormularios,"4")){%>
    else if($(".peso:checked").length < 8) { // via
        showError('Por favor llenar todos los campos de: NUTRICION: CRIBADO NUTRICIONAL (No Aplica a Pediatría ni Obstetricia)');
        scrollToElem($(".peso").get(0))
        return false;
    }
    <%}%>
    
  <%} else if (fg.trim().equalsIgnoreCase("PE")){%>
    if ($("input[name='historia_nacimiento']:checked").length < 1 || $("input[name='cuidado_especial']:checked").length < 1 || !$.trim($("#apgar").val())  || !$.trim($("#peso_al_nacer").val()) ) {
        showError('Por favor llenar todos los campos para: HISTORIA DEL NACIMIENTO');
        scrollToElem($("input[name='historia_nacimiento']").get(0))
        return false;
    } else if ($("input[name*='cribado_nutricional']:checked").length < 1){
        showError('Por favor llenar todos los campos para: NUTRICION: CRIBADO NUTRICIONAL');
        scrollToElem($("input[name*='cribado_nutricional']").get(0))
        return false;
    }
  <%} else if (fg.trim().equalsIgnoreCase("EM")){%>
    
    if ($("input[name='evolucion_embarazos']:checked").length < 1 || ( $("input[name='evolucion_embarazos'][value='S']:checked").length && ( $("input[name='embarazos_anteriores']:checked").length < 1 || $("input[name='partos_anteriores']:checked").length < 1 || $("input[name='malformaciones_congenitas']:checked").length < 1))) {
        showError('Por favor llenar todos los campos para: HISTORIA GINECO- OBSTETRICA');
        scrollToElem($("input[name='evolucion_embarazos']").get(0))
        return false;
    } else if ( !$.trim($("#grava").val()) || !$.trim($("#aborto").val()) || !$.trim($("#para").val()) || !$.trim($("#cesarea").val()) || !$.trim($("#menarquia").val()) || !$.trim($("#tipaje_y_rh").val()) || $("input[name='control_prenatal']:checked").length < 1) {
        showError('Por favor llenar todos los campos para: ANTECEDENTES GINECO OBSTETRICOS');
        scrollToElem($("input[name='grava']").get(0))
        return false;
    } else if ( $("input[name*='evaluacion_obstetrica']:checked").length < 1 || !$.trim($("#actividad_uterina").val()) || !$.trim($("#dilatacion").val()) || !$.trim($("#borramiento").val()) || !$.trim($("#plano").val()) || $("input[name*='abdomen']").length < 1 ) {
        showError('Por favor llenar todos los campos para: EVALUACIÓN OBSTETRICA');
        scrollToElem($("input[name*='evaluacion_obstetrica']").get(0))
        return false;
    } else if ($("input[name*='cribado_nutricional']:checked").length < 1){ 
        showError('Por favor llenar todos los campos para: NUTRICION: CRIBADO NUTRICIONAL');
        scrollToElem($("input[name*='cribado_nutricional']").get(0));
        return false;
    }
    
  <%}%>
    
   if( $("#validar_nutricionista").val() && (!$.trim($("#nutricionista").val()) || !$("#hora").val() || !$("#via").val()) ) {
        showError('Por favor llenar todos los campos de: NUTRICION: CRIBADO NUTRICIONAL (No Aplica a Pediatría ni Obstetricia)');
        scrollToElem($("#validar_nutricionista").get(0))
        return false;
    }
  
  var proceed = true;
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    if ( $self.is(":checked") && !$.trim($("#observacion"+i).val())) {
      <%=from.trim().equalsIgnoreCase("salida_pop")?"parent.":""%>parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
      proceed = false;
      $self.focus();
      debug($self)
      return false;  
    }else  {proceed = true;}
  });
  if (proceed) setGenAlerta();
  //var genAlerta = $("#gen_alerta").val();
  <%//if(!fg.trim().equalsIgnoreCase("PE")){%>
  //if (genAlerta === 'Y' && (!$.trim($("#nutricionista").val()) || !$("#hora").val() || !$("#via").val()) ) {
    //<%=from.trim().equalsIgnoreCase("salida_pop")?"parent.":""%>parent.CBMSG.error("Por favor llenar: Nombre nutricionista, Hora y Vía de comunicacion!");
    //proceed = false;
  //}
  <%//}%>
  return proceed;
}

function setGenAlerta() {
  debug("ENtrando...")
  $("#gen_alerta").val("");
  var $obj;
  <%if(fg.trim().equalsIgnoreCase("C1")){%>
     $obj = $("input:checked.peso[value='S']");
  <%} else if (fg.trim().equalsIgnoreCase("EM")||fg.trim().equalsIgnoreCase("PE")) {%>
     $obj = $("input:checked[type='radio'][name^='cribado_nutricional'][value='S']");
  <%}%>
  if ($obj){
      var selected = $obj.map(function(){
        return this.value;
      }).get();
      if (selected.length >= 2) {
        $("#gen_alerta").val("Y");
        debug("Generar alerta si son mas de 2 si")
      } else if ($("input:checked[name='nutricion_enteral'][value='S']").length || $("input:checked[name='problema_comunicacion'][value='S']").length || $("input:checked[name='unidad_cuidado'][value='S']").length || $("input:checked[name='perdida_peso_15'][value='S']").length || $("input:checked[name='mayor_80'][value='S']").length || $("input:checked[name*='cribado_nutricional<%=fg.equalsIgnoreCase("PE")?"3":"4"%>'][value='E']").length || $("input:checked[name*='cribado_nutricional<%=fg.equalsIgnoreCase("PE")?"3":"4"%>'][value='D']").length|| $("input:checked[name*='cribado_nutricional<%=fg.equalsIgnoreCase("PE")?"4":"20"%>'][value='S']").length<%if(fg.equalsIgnoreCase("PE")){%> || $("input:checked[name*='cribado_nutricional4'][value='S']").length || $("input:checked[name*='cribado_nutricional5'][value='S']").length || $("input:checked[name*='cribado_nutricional6'][value='S']").length || $("input:checked[name*='cribado_nutricional7'][value='S']").length<%}%>) {
        $("#gen_alerta").val("Y");
        debug("Generar alerta si otros")
      }
  }
}



function shouldTypeRadio(check, textareaIndex) {
  if (check == true) $("#observacion"+textareaIndex).prop("readOnly", false)
  else $("#observacion"+textareaIndex).val("").prop("readOnly", true)
}

function printExp(){
    abrir_ventana("../expediente3.0/print_cuestionarios.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>");
}
</script>
<style>
  .text-center{text-align:center !important;}
</style>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">    
    <div class="table-responsive" data-pattern="priority-columns">
		<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
		<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
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
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("desc",desc)%>
		<%=fb.hidden("acciones","")%>
		<%=fb.hidden("codigo_diag", cdo.getColValue("codigo_diag"))%>
		<%=fb.hidden("desc_diag", cdo.getColValue("desc_diag"))%>
		<%=fb.hidden("gen_alerta", "")%>
		<%=fb.hidden("from", from)%>
		<%=fb.hidden("formularios", formularios)%>
		<%=fb.hidden("validar_nutricionista", "")%>
        
        <div class="headerform">
        <table cellspacing="0" class="table pull-right table-striped table-custom-1">
            <tr>
                <td>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="printExp()"><i class="material-icons fa-printico">print</i> <b>Imprimir</b></button>
                </td>
            </tr>
        </table>
        </div>

        <table class="table table-small-font table-bordered table-striped">
            <tbody>
            
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                
                <%if(fg.trim().equals("PE") || fg.trim().equals("EM")){%>
                    <tr>
                        <td colspan="4" class="controls form-inline">
                          Fecha &nbsp;
                          <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                              <jsp:param name="noOfDateTBox" value="1"/>
                              <jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
                              <jsp:param name="nameOfTBox1" value="fecha_creacion" />
                              <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_creacion")!=null && !"".equals(prop.getProperty("fecha_creacion"))?prop.getProperty("fecha_creacion"): cDateTime%>" />
                              <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                          </jsp:include>
                        </td>
                    </tr> 
                <%}%>
                
                <%if(fg.trim().equals("C1")){%>
                   <tr class="bg-headtabla2">
                    <th colspan="4">INGRESO DE PACIENTE</th>
                    </tr>
                
                    <tr>
                        <td colspan="4" class="controls form-inline">
                          Fecha Ingreso&nbsp;
                        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1"/>
                            <jsp:param name="format" value="dd/mm/yyyy"/>
                            <jsp:param name="nameOfTBox1" value="fecha_ingreso" />
                            <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_ingreso")!=null?prop.getProperty("fecha_ingreso"):""%>" />
                            <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                        </jsp:include>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        Hora Ingreso&nbsp;
                        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1"/>
                            <jsp:param name="format" value="hh12:mi:ss am"/>
                            <jsp:param name="nameOfTBox1" value="hora_ingreso" />
                            <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora_ingreso")!=null?prop.getProperty("hora_ingreso"):""%>" />
                            <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                        </jsp:include>
                        </td>
                    </tr> 
                    
                    <tr>
                      <td colspan="2">
                        Procedente:&nbsp;&nbsp;<label class="pointer"><%=fb.radio("procedente","A",prop.getProperty("procedente")!=null&&prop.getProperty("procedente").equals("A"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,18)'")%>&nbsp;Admisi&oacute;n</label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.radio("procedente","E",prop.getProperty("procedente")!=null&&prop.getProperty("procedente").equals("E"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,18)'")%>&nbsp;Emergencia</label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.radio("procedente","OT",prop.getProperty("procedente")!=null&&prop.getProperty("procedente").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,18)'",""," data-index=18 data-message='Por favor indique de donde procede el paciente.'")%>&nbsp;Otro</label>
                       </td>
                       <td colspan="2">
                         <%=fb.textarea("observacion18",prop.getProperty("observacion18"),false,false,(viewMode||prop.getProperty("observacion18").equals("")),0,1,2000,"form-control input-sm","",null)%>
                       </td>
                    </tr>
                    
                    <tr>
                      <td colspan="4">
                        Diagnóstico de Ingreso:&nbsp;&nbsp;[<%=prop.getProperty("codigo_diag")==null||prop.getProperty("codigo_diag").equals("")?cdo.getColValue("codigo_diag"):prop.getProperty("codigo_diag")%>]&nbsp;<%=prop.getProperty("desc_diag")==null||prop.getProperty("desc_diag").equals("")?cdo.getColValue("desc_diag"):prop.getProperty("desc_diag")%>
                      </td>
                    </tr>
                    
                    <tr>
                      <td colspan="2">
                        Paciente llegó:&nbsp;&nbsp;<label class="pointer"><%=fb.radio("paciente_llego","0",prop.getProperty("paciente_llego")!=null&&prop.getProperty("paciente_llego").equals("0"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,20)'")%>&nbsp;Caminando</label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.radio("paciente_llego","1",prop.getProperty("paciente_llego")!=null&&prop.getProperty("paciente_llego").equals("1"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,20)'")%>&nbsp;Silla de Rueda</label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.radio("paciente_llego","2",prop.getProperty("paciente_llego")!=null&&prop.getProperty("paciente_llego").equals("2"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,20)'")%>&nbsp;Camilla</label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.radio("paciente_llego","OT",prop.getProperty("paciente_llego")!=null&&prop.getProperty("paciente_llego").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,20)'",""," data-index=20 data-message='Por favor indique como llegó el paciente.'")%>&nbsp;Otros</label>
                       </td>
                       <td colspan="2">
                         <%=fb.textarea("observacion20",prop.getProperty("observacion20"),false,false,(viewMode||prop.getProperty("observacion20").equals("")),0,1,2000,"form-control input-sm","",null)%>
                       </td>
                    </tr>
                    
                    <tr>
                      <td colspan="2">
                        Acompañado por:&nbsp;&nbsp;<label class="pointer"><%=fb.checkbox("acompaniado_por0","0",prop.getProperty("acompaniado_por0")!=null&&prop.getProperty("acompaniado_por0").equals("0"),viewMode,null,null,"","")%>&nbsp;Familiar</label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.checkbox("acompaniado_por1","1",prop.getProperty("acompaniado_por1")!=null&&prop.getProperty("acompaniado_por1").equals("1"),viewMode,null,null,"","")%>&nbsp;Amigo</label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.checkbox("acompaniado_por2","2",prop.getProperty("acompaniado_por2")!=null&&prop.getProperty("acompaniado_por2").equals("2"),viewMode,null,null,"","")%>&nbsp;Escolta</label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.checkbox("acompaniado_por3","3",prop.getProperty("acompaniado_por3")!=null&&prop.getProperty("acompaniado_por3").equals("3"),viewMode,null,null,"","")%>&nbsp;Médico</label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.checkbox("acompaniado_por4","4",prop.getProperty("acompaniado_por4")!=null&&prop.getProperty("acompaniado_por4").equals("4"),viewMode,null,null,"","")%>&nbsp;Enfermera</label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.checkbox("acompaniado_por5","5",prop.getProperty("acompaniado_por5")!=null&&prop.getProperty("acompaniado_por5").equals("5"),viewMode,"observacion should-type",null,"",""," data-index=19 data-message='Por favor indique con quien viene acompañado el paciente.'")%>&nbsp;Otros</label>
                       </td>
                       <td colspan="2">
                         <%=fb.textarea("observacion19",prop.getProperty("observacion19"),false,false,(viewMode||prop.getProperty("observacion19").equals("")),0,1,2000,"form-control input-sm","",null)%>
                       </td>
                    </tr>
                <%}%>
                
                <%if(fg.trim().equals("C1")){%>
                
                <tr class="bg-headtabla2">
                    <th colspan="4">EVALUACI&Oacute;N INICIAL DE LAS ENFERMEDADES TRANSMISIBLES</th>
                </tr>
                
                <tr>
                    <td colspan="4"><label class="pointer"><%=fb.radio("aislamiento","S",prop.getProperty("aislamiento")!=null&&prop.getProperty("aislamiento").equals("S"),viewMode,false)%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("aislamiento","N",prop.getProperty("aislamiento")!=null&&prop.getProperty("aislamiento").equals("N"),viewMode,false)%>&nbsp;NO</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.checkbox("aislamiento_det1","1",prop.getProperty("aislamiento_det1")!=null&&prop.getProperty("aislamiento_det1").equals("1"),viewMode,"aislamiento_det",null,"")%>&nbsp;Paciente con Aislamiento de Contacto</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.checkbox("aislamiento_det3","3",prop.getProperty("aislamiento_det3")!=null&&prop.getProperty("aislamiento_det3").equals("3"),viewMode,"aislamiento_det",null,"")%>&nbsp;Paciente Con Aislamiento de Gotas</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.checkbox("aislamiento_det5","5",prop.getProperty("aislamiento_det5")!=null&&prop.getProperty("aislamiento_det5").equals("5"),viewMode,"aislamiento_det",null,"")%>&nbsp;Paciente con Aislamiento Respiratorio (Gotitas)</label><br>
                    
                  
                    <label class="pointer"><%=fb.checkbox("aislamiento_det0","0",prop.getProperty("aislamiento_det0")!=null&&prop.getProperty("aislamiento_det0").equals("0"),viewMode,"aislamiento_det",null,"")%>&nbsp;Orientación al paciente y familiar</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.checkbox("aislamiento_det2","2",prop.getProperty("aislamiento_det2")!=null&&prop.getProperty("aislamiento_det2").equals("2"),viewMode,"aislamiento_det",null,"")%>&nbsp;Coordinación con la enfermera de nosocomial</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.checkbox("aislamiento_det4","4",prop.getProperty("aislamiento_det4")!=null&&prop.getProperty("aislamiento_det4").equals("4"),viewMode,"aislamiento_det",null,"")%>&nbsp;Colocación del equipo de protección</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.checkbox("aislamiento_det6","6",prop.getProperty("aislamiento_det6")!=null&&prop.getProperty("aislamiento_det6").equals("6"),viewMode,"aislamiento_det observacion should-type",null,"",""," data-index=27 data-message='Por favor indique los otros aislamientos'")%>&nbsp;Otros</label>
                    
                    <br>
                    <%=fb.textarea("observacion27",prop.getProperty("observacion27"),false,false,(viewMode||prop.getProperty("observacion27").equals("")),0,1,0,"form-control input-sm","",null)%>
                    
                    </td>
                </tr>
                
                <%
                if (!CmnMgr.vectorContains(vFormularios,"3") && !CmnMgr.vectorContains(vFormularios,"4")){%>
                <tr class="bg-headtabla2">
                    <th colspan="4">NUTRICION: CRIBADO NUTRICIONAL (No Aplica a Pediatría ni Obstetricia)</th>
                </tr>
                
                <tr>
                    <td colspan="2">P&eacute;rdida de Peso en los &uacute;ltimos tres (3) meses?</td>
                    <td colspan="2"><label class="pointer"><%=fb.radio("perdido_peso","S",prop.getProperty("perdido_peso")!=null&&prop.getProperty("perdido_peso").equals("S"),viewMode,false,"peso",null,"")%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("perdido_peso","N",prop.getProperty("perdido_peso")!=null&&prop.getProperty("perdido_peso").equals("N"),viewMode,false,"peso",null,"")%>&nbsp;NO</label>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">Disminución de la ingesta en la &uacute;ltima semana?</td>
                    <td colspan="2"><label class="pointer"><%=fb.radio("disminucion","S",prop.getProperty("disminucion")!=null&&prop.getProperty("disminucion").equals("S"),viewMode,false,"peso",null,"")%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("disminucion","N",prop.getProperty("disminucion")!=null&&prop.getProperty("disminucion").equals("N"),viewMode,false,"peso",null,"")%>&nbsp;NO</label>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">Tiene alguno de estos Diagnósticos: Diabetes, EPOC, Nefrópata (hemodiálisis), Enfermedad Oncológico, Fractura de Cadera, Cirrosis hepática)</td>
                    <td colspan="2"><label class="pointer"><%=fb.radio("diabetes","S",prop.getProperty("diabetes")!=null&&prop.getProperty("diabetes").equals("S"),viewMode,false,"peso",null,"")%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("diabetes","N",prop.getProperty("diabetes")!=null&&prop.getProperty("diabetes").equals("N"),viewMode,false,"peso",null,"")%>&nbsp;NO</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">Paciente se encuentra en la Unidad de Cuidados Intensivos</td>
                    <td colspan="2"><label class="pointer"><%=fb.radio("unidad_cuidado","S",prop.getProperty("unidad_cuidado")!=null&&prop.getProperty("unidad_cuidado").equals("S"),viewMode,false,"peso",null,"")%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("unidad_cuidado","N",prop.getProperty("unidad_cuidado")!=null&&prop.getProperty("unidad_cuidado").equals("N"),viewMode,false,"peso",null,"")%>&nbsp;NO</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">Paciente se encuentra con nutrición enteral</td>
                    <td colspan="2"><label class="pointer"><%=fb.radio("nutricion_enteral","S",prop.getProperty("nutricion_enteral")!=null&&prop.getProperty("nutricion_enteral").equals("S"),viewMode,false,"peso",null,"")%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("nutricion_enteral","N",prop.getProperty("nutricion_enteral")!=null&&prop.getProperty("nutricion_enteral").equals("N"),viewMode,false,"peso",null,"")%>&nbsp;NO</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">Paciente con problemas de comunicación o Inconsciente</td>
                    <td colspan="2"><label class="pointer"><%=fb.radio("problema_comunicacion","S",prop.getProperty("problema_comunicacion")!=null&&prop.getProperty("problema_comunicacion").equals("S"),viewMode,false,"peso",null,"")%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("problema_comunicacion","N",prop.getProperty("problema_comunicacion")!=null&&prop.getProperty("problema_comunicacion").equals("N"),viewMode,false,"peso",null,"")%>&nbsp;NO</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">Que haya perdido >15% en los &uacute;ltimos meses</td>
                    <td colspan="2"><label class="pointer"><%=fb.radio("perdida_peso_15","S",prop.getProperty("perdida_peso_15")!=null&&prop.getProperty("perdida_peso_15").equals("S"),viewMode,false,"peso",null,"")%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("perdida_peso_15","N",prop.getProperty("perdida_peso_15")!=null&&prop.getProperty("perdida_peso_15").equals("N"),viewMode,false,"peso",null,"")%>&nbsp;NO</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">Que el paciente >80 a&ntilde;os deberán, comunicarse con la nutricionista para una evaluaci&oacute;n completa, v&iacute;a mensaje de texto</td>
                    <td colspan="2"><label class="pointer"><%=fb.radio("mayor_80","S",prop.getProperty("mayor_80")!=null&&prop.getProperty("mayor_80").equals("S"),viewMode,false,"peso",null,"")%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("mayor_80","N",prop.getProperty("mayor_80")!=null&&prop.getProperty("mayor_80").equals("N"),viewMode,false,"peso",null,"")%>&nbsp;NO</label>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4">
                    <b>Observaciones de alerta a presentar:</b><br>
                    1. En caso de 2 o más alteraciones resulten en (SI)<br>
                    2. Si el Paciente se encuentra con nutrición enteral<br>
                    3. Si el Paciente con problemas de comunicación<br>
                    4. si es paciente de Cuidados Intensivos que mande alerta<br>
                    5. Que haya perdido >15% en los últimos meses<br>
                    6. Que el paciente >80 años deberán, comunicarse con la nutricionista para una evaluación completa, vía mensaje de texto<br>
                    </td>
                </tr>
                <tr>
                    <td colspan="4" class="controls form-inline">Nombre de Nutricionista Enterada:&nbsp;<%=fb.textBox("nutricionista", prop.getProperty("nutricionista"),false,false,(viewMode||prop.getProperty("nutricionista").equals("")),30,"form-control input-sm",null,null)%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hora&nbsp;
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                        <jsp:param name="noOfDateTBox" value="1"/>
                        <jsp:param name="format" value="hh12:mi:ss am"/>
                        <jsp:param name="nameOfTBox1" value="hora" />
                        <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")!=null?prop.getProperty("hora"):""%>" />
                        <jsp:param name="readonly" value="<%=(viewMode||prop.getProperty("hora").equals(""))?"y":"n"%>"/>
                    </jsp:include>
                    <span id="via_container">
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    Via de comunicación&nbsp;
                    <%=fb.select("via","C=Correo,T=Teléfono,P=Personal,S=SMS",prop.getProperty("via"),false,viewMode,0,"form-control input-sm",null,"",null,"S")%></span>
                    </td>
                </tr>
                <%}%>

                <tr class="bg-headtabla2">
                    <th colspan="4">VALORACION FUNCIONAL</th>
                </tr>
                <tr>
                    <th>Autonomía para la vida diaria</th>
                    <th class="text-center">No requiere ayuda</th>
                    <th class="text-center">Ayuda parcial</th>
                    <th class="text-center">Ayuda total</th>
                </tr>
                
                <tr>
                    <td>Baño / higiene</td>
                    <td class="text-center"><%=fb.radio("banio_higiene","NA",prop.getProperty("banio_higiene")!=null&&prop.getProperty("banio_higiene").equals("NA"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("banio_higiene","AP",prop.getProperty("banio_higiene")!=null&&prop.getProperty("banio_higiene").equals("AP"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("banio_higiene","AT",prop.getProperty("banio_higiene")!=null&&prop.getProperty("banio_higiene").equals("AT"),viewMode,false)%></td>
                </tr>
                <tr>
                    <td>Vestirse / desvestirse / alimentación</td>
                    <td class="text-center"><%=fb.radio("vestir_desvestir_ali","NA",prop.getProperty("vestir_desvestir_ali")!=null&&prop.getProperty("vestir_desvestir_ali").equals("NA"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("vestir_desvestir_ali","AP",prop.getProperty("vestir_desvestir_ali")!=null&&prop.getProperty("vestir_desvestir_ali").equals("AP"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("vestir_desvestir_ali","AT",prop.getProperty("vestir_desvestir_ali")!=null&&prop.getProperty("vestir_desvestir_ali").equals("AT"),viewMode,false)%></td>
                </tr>
                <tr>
                    <td>Movilidad deambulación</td>
                    <td class="text-center"><%=fb.radio("movilidad_deambulacion","NA",prop.getProperty("movilidad_deambulacion")!=null&&prop.getProperty("movilidad_deambulacion").equals("NA"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("movilidad_deambulacion","AP",prop.getProperty("movilidad_deambulacion")!=null&&prop.getProperty("movilidad_deambulacion").equals("AP"),viewMode,false)%></td>
                    <td class="text-center"><%=fb.radio("movilidad_deambulacion","AT",prop.getProperty("movilidad_deambulacion")!=null&&prop.getProperty("movilidad_deambulacion").equals("AT"),viewMode,false)%></td>
                </tr>
                
                <tr>
                  <td>
                  Alguna Dificultad Funcional&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.radio("movimiento","S",prop.getProperty("movimiento")!=null&&prop.getProperty("movimiento").equals("S"),viewMode,false)%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("movimiento","N",prop.getProperty("movimiento")!=null&&prop.getProperty("movimiento").equals("N"),viewMode,false)%>&nbsp;NO</label>
                  </td>
                </tr>
                
                <tr>
                    <td colspan="2">
                      <label class="pointer"><%=fb.checkbox("dificultad_movimiento0","0",prop.getProperty("dificultad_movimiento0")!=null&&prop.getProperty("dificultad_movimiento0").equals("0"),viewMode,null,null,"","")%>&nbsp;Moverse</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("dificultad_movimiento1","1",prop.getProperty("dificultad_movimiento1")!=null&&prop.getProperty("dificultad_movimiento1").equals("1"),viewMode,null,null,"","")%>&nbsp;Caminar</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("dificultad_movimiento2","2",prop.getProperty("dificultad_movimiento2")!=null&&prop.getProperty("dificultad_movimiento2").equals("2"),viewMode,null,null,"","")%>&nbsp;Levantarse</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("dificultad_movimiento3","3",prop.getProperty("dificultad_movimiento3")!=null&&prop.getProperty("dificultad_movimiento3").equals("3"),viewMode,null,null,"","")%>&nbsp;Sentarse</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("dificultad_movimiento4","4",prop.getProperty("dificultad_movimiento4")!=null&&prop.getProperty("dificultad_movimiento4").equals("4"),viewMode,null,null,"","")%>&nbsp;Pérdida Funcional</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("dificultad_movimiento5","5",prop.getProperty("dificultad_movimiento5")!=null&&prop.getProperty("dificultad_movimiento5").equals("5"),viewMode,null,null,"","")%>&nbsp;Prótesis</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("dificultad_movimiento6","6",prop.getProperty("dificultad_movimiento6")!=null&&prop.getProperty("dificultad_movimiento6").equals("6"),viewMode,null,null,"","")%>&nbsp;Paresias/plejia</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("dificultad_movimiento7","7",prop.getProperty("dificultad_movimiento7")!=null&&prop.getProperty("dificultad_movimiento7").equals("7"),viewMode,null,null,"","")%>&nbsp;Amputaciones</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("dificultad_movimiento8","OT",prop.getProperty("dificultad_movimiento8")!=null&&prop.getProperty("dificultad_movimiento8").equals("OT"),viewMode,"observacion",null,"",""," data-index=0")%>&nbsp;Otro</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion0",prop.getProperty("observacion0"),false,false,(viewMode||prop.getProperty("observacion0").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">Alguna necesidad especial:&nbsp;
                    
                    <label class="pointer"><%=fb.radio("necesidad","S",prop.getProperty("necesidad")!=null&&prop.getProperty("necesidad").equals("S"),viewMode,false)%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("necesidad","N",prop.getProperty("necesidad")!=null&&prop.getProperty("necesidad").equals("N"),viewMode,false)%>&nbsp;NO</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    
                      <label class="pointer"><%=fb.checkbox("necesidad_especial0","0",prop.getProperty("necesidad_especial0")!=null&&prop.getProperty("necesidad_especial0").equals("0"),viewMode,null,null,"","")%>&nbsp;Ciego</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("necesidad_especial1","1",prop.getProperty("necesidad_especial1")!=null&&prop.getProperty("necesidad_especial1").equals("1"),viewMode,null,null,"","")%>&nbsp;Sordo</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("necesidad_especial2","2",prop.getProperty("necesidad_especial2")!=null&&prop.getProperty("necesidad_especial2").equals("2"),viewMode,null,null,"","")%>&nbsp;Mudo</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("necesidad_especial3","OT",prop.getProperty("necesidad_especial3")!=null&&prop.getProperty("necesidad_especial3").equals("OT"),viewMode,"observacion",null,"",""," data-index=1")%>&nbsp;Otro</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion1",prop.getProperty("observacion1"),false,false,(viewMode||prop.getProperty("observacion1").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                  <td colspan="4"><b>Observación: En caso de detectar alguna alteración funcional o necesidad especial, se deberá comunicar al médico inmediatamente para una evaluación más completa</b></td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <th colspan="4">VALORACION CREENCIAS / CULTURA / ESPIRITUAL</th>
                </tr>
                
                <tr>
                    <td colspan="2">
                    <label class="pointer"><%=fb.radio("religion","0",prop.getProperty("religion")!=null&&prop.getProperty("religion").equals("0"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,2)'")%>&nbsp;Católico</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("religion","1",prop.getProperty("religion")!=null&&prop.getProperty("religion").equals("1"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,2)'")%>&nbsp;Judío</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("religion","2",prop.getProperty("religion")!=null&&prop.getProperty("religion").equals("2"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,2)'")%>&nbsp;Árabe</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("religion","3",prop.getProperty("religion")!=null&&prop.getProperty("religion").equals("3"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,2)'")%>&nbsp;Musulmán</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("religion","4",prop.getProperty("religion")!=null&&prop.getProperty("religion").equals("4"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,2)'")%>&nbsp;Ninguno</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("religion","OT",prop.getProperty("religion")!=null&&prop.getProperty("religion").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,2)'",""," data-index=2")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion2",prop.getProperty("observacion2"),false,false,(viewMode||prop.getProperty("observacion2").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">
                    Tiene alguna Creencia religiosa o cultural que le gustaría que tuviéramos en cuenta en su hospitalización:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("creencia","S",prop.getProperty("creencia")!=null&&prop.getProperty("creencia").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,3)'",""," data-index=3 data-message='Por favor indique la creencia!'")%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("creencia","N",prop.getProperty("creencia")!=null&&prop.getProperty("creencia").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,3)'")%>&nbsp;NO</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion3",prop.getProperty("observacion3"),false,false,(viewMode||prop.getProperty("observacion3").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>

                <tr>
                    <td colspan="2">
                    Solicita Servicios Religiosos:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("servicio_religioso","S",prop.getProperty("servicio_religioso")!=null&&prop.getProperty("servicio_religioso").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,4)'",""," data-index=4 data-message='Por favor indique los servicios religiosos!'")%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("servicio_religioso","N",prop.getProperty("servicio_religioso")!=null&&prop.getProperty("servicio_religioso").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,4)'")%>&nbsp;NO</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion4",prop.getProperty("observacion4"),false,false,(viewMode||prop.getProperty("observacion4").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr> 
                <tr>
                    <td colspan="2">
                    Voluntades Anticipadas:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("voluntades_anticipadas","S",prop.getProperty("voluntades_anticipadas")!=null&&prop.getProperty("voluntades_anticipadas").equals("S"),viewMode,false,"",null,"","","")%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("voluntades_anticipadas","N",prop.getProperty("voluntades_anticipadas")!=null&&prop.getProperty("voluntades_anticipadas").equals("N"),viewMode,false,"",null,"",null,"")%>&nbsp;NO</label>
                    </td>
                    <td colspan="2">
                     <%//=fb.textarea("observacion25",prop.getProperty("observacion25"),false,false,(viewMode||prop.getProperty("observacion25").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr> 

                <tr>
                    <td colspan="2">
                      <label class="pointer"><%=fb.checkbox("no_no0","0",prop.getProperty("no_no0")!=null&&prop.getProperty("no_no0").equals("0"),viewMode,null,null,"","")%>&nbsp;No reanimaci&oacute;n cardiopulmonar (NO RCP)</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("no_no1","1",prop.getProperty("no_no1")!=null&&prop.getProperty("no_no1").equals("1"),viewMode,null,null,"","")%>&nbsp;Donante de Órgano</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("no_no2","2",prop.getProperty("no_no2")!=null&&prop.getProperty("no_no2").equals("2"),viewMode,null,null,"","")%>&nbsp;No Transfusiones de sangre</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("no_no3","OT",prop.getProperty("no_no3")!=null&&prop.getProperty("no_no3").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=5 data-message='Por favor indicar las otras voluntades anticipadas!'")%>&nbsp;Otro</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion5",prop.getProperty("observacion5"),false,false,(viewMode||prop.getProperty("observacion5").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr class="bg-headtabla2">
                    <th colspan="4">EVALUACION SOCIAL Y ACTIVIDADES</th>
                </tr>
                
                <tr>
                    <td colspan="2">
                    <%if( prop.getProperty("realiza_ejercicio")!=null && !prop.getProperty("realiza_ejercicio").equals("S") ) prop.setProperty("realiza_ejercicio","N");%>
                    Realiza ejercicios:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("realiza_ejercicio","S",prop.getProperty("realiza_ejercicio")!=null&&prop.getProperty("realiza_ejercicio").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,6)'",""," data-index=6 data-message='Por favor indique los ejercicios!'")%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("realiza_ejercicio","N",prop.getProperty("realiza_ejercicio")!=null&&prop.getProperty("realiza_ejercicio").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,6)'")%>&nbsp;NO</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion6",prop.getProperty("observacion6"),false,false,(viewMode||prop.getProperty("observacion6").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">
                    <%if( prop.getProperty("ingiere_alcohol")!=null && !prop.getProperty("ingiere_alcohol").equals("S") ) prop.setProperty("ingiere_alcohol","N");%>
                    Ingiere Alcohol:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("ingiere_alcohol","S",prop.getProperty("ingiere_alcohol")!=null&&prop.getProperty("ingiere_alcohol").equals("S"),viewMode,false)%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("ingiere_alcohol","N",prop.getProperty("ingiere_alcohol")!=null&&prop.getProperty("ingiere_alcohol").equals("N"),viewMode,false)%>&nbsp;NO</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("frecuencia_alcohol","0",prop.getProperty("frecuencia_alcohol")!=null&&prop.getProperty("frecuencia_alcohol").equals("0"),viewMode,false)%>&nbsp;Esporádico</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("frecuencia_alcohol","1",prop.getProperty("frecuencia_alcohol")!=null&&prop.getProperty("frecuencia_alcohol").equals("1"),viewMode,false)%>&nbsp;a diario</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("frecuencia_alcohol","2",prop.getProperty("frecuencia_alcohol")!=null&&prop.getProperty("frecuencia_alcohol").equals("2"),viewMode,false)%>&nbsp;Fin de semana</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("frecuencia_alcohol","OT",prop.getProperty("frecuencia_alcohol")!=null&&prop.getProperty("frecuencia_alcohol").equals("OT"),viewMode,false,"observacion",null,"",""," data-index=7")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion7",prop.getProperty("observacion7"),false,false,(viewMode||prop.getProperty("observacion7").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                 <tr>
                    <td colspan="2">
                    <%if( prop.getProperty("fumador")!=null && !prop.getProperty("fumador").equals("S") ) prop.setProperty("fumador","N");%>
                    Ha sido usted consumidor de Tabaco:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("fumador","S",prop.getProperty("fumador")!=null&&prop.getProperty("fumador").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,8)'",""," data-index=8 data-message='Por favor indique las informaciones sobre tu tabaquismo!'")%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("fumador","N",prop.getProperty("fumador")!=null&&prop.getProperty("fumador").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,8)'")%>&nbsp;NO</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion8",prop.getProperty("observacion8"),false,false,(viewMode||prop.getProperty("observacion8").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4" class="controls form-inline">
                    <%if( prop.getProperty("fumador_frecuencia")!=null && !prop.getProperty("fumador_frecuencia").equals("S") ) prop.setProperty("fumador_frecuencia","N");%>
                    Ha fumado en los últimos 12 meses:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("fumador_frecuencia","S",prop.getProperty("fumador_frecuencia")!=null&&prop.getProperty("fumador_frecuencia").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,9)'",""," data-index=9 data-message='Por favor indique cuantos cigarrillos por día!'")%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("fumador_frecuencia","N",prop.getProperty("fumador_frecuencia")!=null&&prop.getProperty("fumador_frecuencia").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,9)'")%>&nbsp;NO</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Especifique cuantos cigarrillos por día) 
                      <%=fb.textBox("observacion9",prop.getProperty("observacion9"),false,false,(viewMode||prop.getProperty("observacion9").equals("")),0,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">
                    <%if( prop.getProperty("drogadicto")!=null && !prop.getProperty("drogadicto").equals("S") ) prop.setProperty("drogadicto","N");%>
                    Consume Drogas:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("drogadicto","S",prop.getProperty("drogadicto")!=null&&prop.getProperty("drogadicto").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,10)'",""," data-index=10 data-message='Por favor indique las drogas!'")%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("drogadicto","N",prop.getProperty("drogadicto")!=null&&prop.getProperty("drogadicto").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,10)'")%>&nbsp;NO</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion10",prop.getProperty("observacion10"),false,false,(viewMode||prop.getProperty("observacion10").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">
                    Estado de Salud:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("estado_salud","N",prop.getProperty("estado_salud")!=null&&prop.getProperty("estado_salud").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,11)'")%>&nbsp;Normal</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("estado_salud","R",prop.getProperty("estado_salud")!=null&&prop.getProperty("estado_salud").equals("R"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,11)'")%>&nbsp;Regular</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("estado_salud","OT",prop.getProperty("estado_salud")!=null&&prop.getProperty("estado_salud").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,11)'",""," data-index=11 data-message='Por favor indique su estado de salud!'")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion11",prop.getProperty("observacion11"),false,false,(viewMode||prop.getProperty("observacion11").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <th colspan="4">VALORACION PSICOSOCIAL Y ECONOMICA</th>
                </tr>
                
                <tr>
                    <td colspan="2">
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("vive_con","S",prop.getProperty("vive_con")!=null&&prop.getProperty("vive_con").equals("S"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,12)'")%>&nbsp;Vive Solo</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("vive_con","F",prop.getProperty("vive_con")!=null&&prop.getProperty("vive_con").equals("F"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,12)'")%>&nbsp;Familia</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("vive_con","OT",prop.getProperty("vive_con")!=null&&prop.getProperty("vive_con").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,12)'",""," data-index=12 data-message='Por favor indique con quien vive!'")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion12",prop.getProperty("observacion12"),false,false,(viewMode||prop.getProperty("observacion12").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4">Se observa barreras:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.checkbox("se_observa0","CA",prop.getProperty("se_observa0")!=null&&prop.getProperty("se_observa0").equals("CA"),viewMode)%>&nbsp;Carencia afectiva</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.checkbox("se_observa1","PI",prop.getProperty("se_observa1")!=null&&prop.getProperty("se_observa1").equals("PI"),viewMode)%>&nbsp;Problemas de Integración</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.checkbox("se_observa2","PF",prop.getProperty("se_observa2")!=null&&prop.getProperty("se_observa2").equals("PF"),viewMode)%>&nbsp;Problemas Familiares</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.checkbox("se_observa3","N",prop.getProperty("se_observa3")!=null&&prop.getProperty("se_observa3").equals("N"),viewMode)%>&nbsp;Ninguna</label>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4">Cuenta con apoyo:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.checkbox("tiene_a_cargo0","0",prop.getProperty("tiene_a_cargo0")!=null&&prop.getProperty("tiene_a_cargo0").equals("0"), viewMode,null,null,"","")%>&nbsp;Familiar</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("tiene_a_cargo1","1",prop.getProperty("tiene_a_cargo1")!=null&&prop.getProperty("tiene_a_cargo1").equals("1"),viewMode,null,null,"","")%>&nbsp;Amigos</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("tiene_a_cargo2","2",prop.getProperty("tiene_a_cargo2")!=null&&prop.getProperty("tiene_a_cargo2").equals("2"),viewMode,null,null,"","")%>&nbsp;Otros</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("tiene_a_cargo3","3",prop.getProperty("tiene_a_cargo3")!=null&&prop.getProperty("tiene_a_cargo3").equals("3"),viewMode,null,null,"","")%>&nbsp;Ninguna</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4" class="controls form-inline">Situación Laboral:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("situacion_laboral","0",prop.getProperty("situacion_laboral")!=null&&prop.getProperty("situacion_laboral").equals("0"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,26)'")%>&nbsp;Jubilado</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("situacion_laboral","1",prop.getProperty("situacion_laboral")!=null&&prop.getProperty("situacion_laboral").equals("1"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,26)'")%>&nbsp;Desempleo</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("situacion_laboral","2",prop.getProperty("situacion_laboral")!=null&&prop.getProperty("situacion_laboral").equals("2"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,26)'")%>&nbsp;Ama de casa</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("situacion_laboral","3",prop.getProperty("situacion_laboral")!=null&&prop.getProperty("situacion_laboral").equals("3"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,26)'")%>&nbsp;Pensionado</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("situacion_laboral","4",prop.getProperty("situacion_laboral")!=null&&prop.getProperty("situacion_laboral").equals("4"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,26)'")%>&nbsp;Labora</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("situacion_laboral","OT",prop.getProperty("situacion_laboral")!=null&&prop.getProperty("situacion_laboral").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,26)'",""," data-index=26 data-message='Por favor indique las otras situaciones laborales!'")%>&nbsp;Otras</label>
                    <%=fb.textarea("observacion26",prop.getProperty("observacion26"),false,false,(viewMode||prop.getProperty("observacion26").equals("")),0,1,0,"form-control input-sm","width:40%",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">Vivienda:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("residencia_actual","C",prop.getProperty("residencia_actual")!=null&&prop.getProperty("residencia_actual").equals("C"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,13)'")%>&nbsp;Adecuada a necesidades</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("residencia_actual","AP",prop.getProperty("residencia_actual")!=null&&prop.getProperty("residencia_actual").equals("AP"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,13)'")%>&nbsp;Innadecuada</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("residencia_actual","HO",prop.getProperty("residencia_actual")!=null&&prop.getProperty("residencia_actual").equals("HO"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,13)'")%>&nbsp;Barreras</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("residencia_actual","OT",prop.getProperty("residencia_actual")!=null&&prop.getProperty("residencia_actual").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,13)'",""," data-index=13 data-message='Por favor indique su residencia actual!'")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion13",prop.getProperty("observacion13"),false,false,(viewMode||prop.getProperty("observacion13").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">Aspecto Econ&oacute;mico: Se detecta dificultades
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("aspecto_economico","0",prop.getProperty("aspecto_economico")!=null&&prop.getProperty("aspecto_economico").equals("0"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,14)'")%>&nbsp;NO</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("aspecto_economico","1",prop.getProperty("aspecto_economico")!=null&&prop.getProperty("aspecto_economico").equals("1"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,14)'",""," data-index=14 data-message='Por favor indique la condición económica en la residencia!'")%>&nbsp;SI</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion14",prop.getProperty("observacion14"),false,false,(viewMode||prop.getProperty("observacion14").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                 <tr class="bg-headtabla2">
                    <th colspan="4">
                        VALORACION PARA PACIENTE QUIRURGICO (SOP y Hemodinámica)
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer">
                        <%=fb.radio("valoracion","N",prop.getProperty("valoracion")!=null&&prop.getProperty("valoracion").equals("N"),viewMode,false)%>&nbsp;NO</label>
                        &nbsp;&nbsp;&nbsp;
                        <label class="pointer">
                        <%=fb.radio("valoracion","S",prop.getProperty("valoracion")!=null&&prop.getProperty("valoracion").equals("S"),viewMode,false)%>&nbsp;SI</label>
                    </th>
                </tr>
                
                <tr>
                    <td colspan="4">Le explicaron la cirugía que le van a realizar:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("valoracion_quir","NA",prop.getProperty("valoracion_quir")!=null&&prop.getProperty("valoracion_quir").equals("NA"),viewMode,false)%>&nbsp;No Aplica</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("valoracion_quir","S",prop.getProperty("valoracion_quir")!=null&&prop.getProperty("valoracion_quir").equals("S"),viewMode,false)%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("valoracion_quir","N",prop.getProperty("valoracion_quir")!=null&&prop.getProperty("valoracion_quir").equals("N"),viewMode,false)%>&nbsp;NO</label>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4">Le explicaron el consentimiento informado, riesgo beneficio:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("explicacion_consentimiento","S",prop.getProperty("explicacion_consentimiento")!=null&&prop.getProperty("explicacion_consentimiento").equals("S"),viewMode,false)%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("explicacion_consentimiento","N",prop.getProperty("explicacion_consentimiento")!=null&&prop.getProperty("explicacion_consentimiento").equals("N"),viewMode,false)%>&nbsp;NO</label>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4">Tiene Prótesis Dental:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("protesis_dental","S",prop.getProperty("protesis_dental")!=null&&prop.getProperty("protesis_dental").equals("S"),viewMode,false)%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("protesis_dental","N",prop.getProperty("protesis_dental")!=null&&prop.getProperty("protesis_dental").equals("N"),viewMode,false)%>&nbsp;NO</label>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4">Lentes de Contactos:
                    &nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("lentes_contacto","S",prop.getProperty("lentes_contacto")!=null&&prop.getProperty("lentes_contacto").equals("S"),viewMode,false)%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("lentes_contacto","N",prop.getProperty("lentes_contacto")!=null&&prop.getProperty("lentes_contacto").equals("N"),viewMode,false)%>&nbsp;NO</label>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4" class="controls form-inline">Cuando fue la última vez que ingirió alimento:
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="ultima_comida" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("ultima_comida")!=null?prop.getProperty("ultima_comida"):""%>" />
				<jsp:param name="readonly" value="<%=(viewMode||prop.getProperty("ultima_comida").equals(""))?"y":"n"%>"/>
				</jsp:include>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4"><b>Observaci&oacute;n:</b>
                    <%=fb.textarea("observacion15",prop.getProperty("observacion15"),false,false,(viewMode||prop.getProperty("observacion15").equals("")),0,0,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <th colspan="4">DATOS OBTENIDOS DE:</th>
                </tr>
                
                <tr>
                    <td colspan="2"><label class="pointer"><%=fb.checkbox("datos_obetenidos_de0","P",prop.getProperty("datos_obetenidos_de0")!=null&&prop.getProperty("datos_obetenidos_de0").equals("P"),viewMode,null,null,"")%>&nbsp;Paciente</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.checkbox("datos_obetenidos_de1","F",prop.getProperty("datos_obetenidos_de1")!=null&&prop.getProperty("datos_obetenidos_de1").equals("F"),viewMode,null,null,"")%>&nbsp;Familiar</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.checkbox("datos_obetenidos_de2","A",prop.getProperty("datos_obetenidos_de2")!=null&&prop.getProperty("datos_obetenidos_de2").equals("A"),viewMode,null,null,"")%>&nbsp;Amigo</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.checkbox("datos_obetenidos_de3","H",prop.getProperty("datos_obetenidos_de3")!=null&&prop.getProperty("datos_obetenidos_de3").equals("H"),viewMode,null,null,"")%>&nbsp;Historia Cl&iacute;nica</label>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.checkbox("datos_obetenidos_de4","OT",prop.getProperty("datos_obetenidos_de4")!=null&&prop.getProperty("datos_obetenidos_de4").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=16 data-message='Por favor indique de donde sacaron los datos!'")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion16",prop.getProperty("observacion16"),false,false,(viewMode||prop.getProperty("observacion16").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">MEDICOS ENTERADOS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("medicos_enterados","S",prop.getProperty("medicos_enterados")!=null&&prop.getProperty("medicos_enterados").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,17)'",""," data-index=17 data-message='Por favor indique si los médicos están enterados!'")%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("medicos_enterados","OT",prop.getProperty("medicos_enterados")!=null&&prop.getProperty("medicos_enterados").equals("OT"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,17)'")%>&nbsp;NO</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion17",prop.getProperty("observacion17"),false,false,(viewMode||prop.getProperty("observacion17").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                
                
        <%} else if (fg.equalsIgnoreCase("PE")) {%>
          <%//@ include file="../expediente3.0/exp_eval_creci_desarrollo.jsp" %>
          <tr class="bg-headtabla2">
            <th colspan="4">HISTORIA DEL NACIMIENTO</th>
         </tr>
         
         <tr>
            <td colspan="4" class="controls form-inline"><label class="pointer"><%=fb.radio("historia_nacimiento","PN",prop.getProperty("historia_nacimiento")!=null&&prop.getProperty("historia_nacimiento").equals("PN"),viewMode,false)%>&nbsp;Parto Natural</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("historia_nacimiento","C",prop.getProperty("historia_nacimiento")!=null&&prop.getProperty("historia_nacimiento").equals("C"),viewMode,false)%>&nbsp;Cesárea</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            Apgar&nbsp;<%=fb.textBox("apgar", prop.getProperty("apgar"),false,false,viewMode,10,"form-control input-sm",null,null)%>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            Peso al Nacer&nbsp;<%=fb.textBox("peso_al_nacer", prop.getProperty("peso_al_nacer"),false,false,viewMode,10,"form-control input-sm",null,null)%>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cuidado_especial","JM",prop.getProperty("cuidado_especial")!=null&&prop.getProperty("cuidado_especial").equals("JM"),viewMode,false)%>&nbsp;Sale junto a su madre</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cuidado_especial","CE",prop.getProperty("cuidado_especial")!=null&&prop.getProperty("cuidado_especial").equals("CE"),viewMode,false)%>&nbsp;Cuidados Especiales</label>
            </td>
        </tr>
        <tr>
         <td colspan="4">
            <%=fb.textarea("observacion0",prop.getProperty("observacion0"),false,false,viewMode,0,0,2000,"form-control input-sm","",null)%>
         </td>
        </tr>
        
        <tr class="bg-headtabla2">
            <th colspan="4">NUTRICION: CRIBADO NUTRICIONAL</th>
         </tr>
         
         <tr>
            <td colspan="4" class="controls form-inline">
            Ha disminuido la ingesta en las &uacute;ltimas dos semanas:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional0","S",prop.getProperty("cribado_nutricional0")!=null&&prop.getProperty("cribado_nutricional0").equals("S"),viewMode,false)%>&nbsp;SI</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional0","N",prop.getProperty("cribado_nutricional0")!=null&&prop.getProperty("cribado_nutricional0").equals("N"),viewMode,false)%>&nbsp;NO</label>
            </td>
        </tr>
        <tr>
            <td colspan="4" class="controls form-inline">
            Diagnostico Medico: Gastroenteritis, Vómitos, Nauseas:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional1","S",prop.getProperty("cribado_nutricional1")!=null&&prop.getProperty("cribado_nutricional1").equals("S"),viewMode,false)%>&nbsp;SI</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional1","N",prop.getProperty("cribado_nutricional1")!=null&&prop.getProperty("cribado_nutricional1").equals("N"),viewMode,false)%>&nbsp;NO</label>
            </td>
        </tr>
        <tr>
            <td colspan="4" class="controls form-inline">
            Perdida de peso en las ultimas dos semanas:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional2","S",prop.getProperty("cribado_nutricional2")!=null&&prop.getProperty("cribado_nutricional2").equals("S"),viewMode,false)%>&nbsp;SI</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional2","N",prop.getProperty("cribado_nutricional2")!=null&&prop.getProperty("cribado_nutricional2").equals("N"),viewMode,false)%>&nbsp;NO</label>
            </td>
        </tr>
        <tr>
            <td colspan="4" class="controls form-inline">
            Progreso de control de crecimiento y desarrollo:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional3","A",prop.getProperty("cribado_nutricional3")!=null&&prop.getProperty("cribado_nutricional3").equals("A"),viewMode,false)%>&nbsp;Adecuado</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional3","E",prop.getProperty("cribado_nutricional3")!=null&&prop.getProperty("cribado_nutricional3").equals("E"),viewMode,false)%>&nbsp;Excesivo</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional3","D",prop.getProperty("cribado_nutricional3")!=null&&prop.getProperty("cribado_nutricional3").equals("D"),viewMode,false)%>&nbsp;Deficiente</label>
            </td>
        </tr>
         <tr>
            <td colspan="4" class="controls form-inline">
            Paciente se encuentra con nutrición enteral:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional4","S",prop.getProperty("cribado_nutricional4")!=null&&prop.getProperty("cribado_nutricional4").equals("S"),viewMode,false)%>&nbsp;SI</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional4","N",prop.getProperty("cribado_nutricional4")!=null&&prop.getProperty("cribado_nutricional4").equals("N"),viewMode,false)%>&nbsp;NO</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="4" class="controls form-inline">
            Paciente en estado inconsciente:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional5","S",prop.getProperty("cribado_nutricional5")!=null&&prop.getProperty("cribado_nutricional5").equals("S"),viewMode,false)%>&nbsp;SI</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional5","N",prop.getProperty("cribado_nutricional5")!=null&&prop.getProperty("cribado_nutricional5").equals("N"),viewMode,false)%>&nbsp;NO</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="4" class="controls form-inline">
            Paciente en cuidados intensivos:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional6","S",prop.getProperty("cribado_nutricional6")!=null&&prop.getProperty("cribado_nutricional6").equals("S"),viewMode,false)%>&nbsp;SI</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional6","N",prop.getProperty("cribado_nutricional6")!=null&&prop.getProperty("cribado_nutricional6").equals("N"),viewMode,false)%>&nbsp;NO</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="4" class="controls form-inline">
            P&eacute;rdida de peso >10% en un mes, comunicarse con la nutricionista para una evaluaci&oacute;n completa v&iacute;a mensaje de texto:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional7","S",prop.getProperty("cribado_nutricional7")!=null&&prop.getProperty("cribado_nutricional7").equals("S"),viewMode,false)%>&nbsp;SI</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional7","N",prop.getProperty("cribado_nutricional7")!=null&&prop.getProperty("cribado_nutricional7").equals("N"),viewMode,false)%>&nbsp;NO</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="4" class="controls form-inline">Nombre de Nutricionista Enterada:&nbsp;<%=fb.textBox("nutricionista", prop.getProperty("nutricionista"),false,false,(viewMode||prop.getProperty("nutricionista").equals("")),30,"form-control input-sm",null,null)%>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hora&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1"/>
                <jsp:param name="format" value="hh12:mi:ss am"/>
                <jsp:param name="nameOfTBox1" value="hora" />
                <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")!=null?prop.getProperty("hora"):""%>" />
                <jsp:param name="readonly" value="<%=(viewMode||prop.getProperty("hora").equals(""))?"y":"n"%>"/>
            </jsp:include>
            <span id="via_container">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            Via de comunicación&nbsp;
            <%=fb.select("via","C=Correo,T=Teléfono,P=Personal,S=SMS",prop.getProperty("via"),false,viewMode,0,"form-control input-sm",null,"",null,"S")%></span>
            </td>
        </tr>
        
        <%@ include file="../expediente3.0/exp_eval_creci_desarrollo.jsp" %>
        
        <%} else {%>
        
          <tr class="bg-headtabla2">
            <th colspan="4">HISTORIA GINECO- OBSTETRICA</th>
          </tr>
          
           <tr>
                <td colspan="4">EVOLUCION DE EMBARAZOS – PARTOS – PUERPERIOS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("evolucion_embarazos","N",prop.getProperty("evolucion_embarazos")!=null&&prop.getProperty("evolucion_embarazos").equals("N"),viewMode,false)%>&nbsp;NO</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evolucion_embarazos","S",prop.getProperty("evolucion_embarazos")!=null&&prop.getProperty("evolucion_embarazos").equals("S"),viewMode,false)%>&nbsp;SI</label>
               </td> 
           </tr>
           
           <tr>
                <td colspan="4">Embarazos Anteriores&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("embarazos_anteriores","N",prop.getProperty("embarazos_anteriores")!=null&&prop.getProperty("embarazos_anteriores").equals("N"),viewMode,false)%>&nbsp;Normal(es)</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("embarazos_anteriores","C",prop.getProperty("embarazos_anteriores")!=null&&prop.getProperty("embarazos_anteriores").equals("C"),viewMode,false)%>&nbsp;Complicado(s)</label>
               </td> 
           </tr>
           
           <tr>
                <td colspan="4">Partos Anteriores&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("partos_anteriores","N",prop.getProperty("partos_anteriores")!=null&&prop.getProperty("partos_anteriores").equals("N"),viewMode,false)%>&nbsp;Normal(es)</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("partos_anteriores","C",prop.getProperty("partos_anteriores")!=null&&prop.getProperty("partos_anteriores").equals("C"),viewMode,false)%>&nbsp;Complicado(s)</label>
               </td> 
           </tr>
           
           <tr>
                <td colspan="2">Malformaciones Congénitas&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("malformaciones_congenitas","N",prop.getProperty("malformaciones_congenitas")!=null&&prop.getProperty("malformaciones_congenitas").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,21)'")%>&nbsp;NO</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("malformaciones_congenitas","S",prop.getProperty("malformaciones_congenitas")!=null&&prop.getProperty("malformaciones_congenitas").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,21)'",""," data-index=21 data-message='Por favor indique las Malformaciones Congénitas.'")%>&nbsp;SI</label>
               </td> 
               <td colspan="2">
                 <%=fb.textarea("observacion21",prop.getProperty("observacion21"),false,false,(viewMode||prop.getProperty("observacion21").equals("")),0,1,2000,"form-control input-sm","",null)%>
               </td>
           </tr>
           
           <tr>
            <th colspan="4">ANTECEDENTES GINECO OBSTETRICOS</th>
           </tr>
           
           <tr>
            <td colspan="4" class="controls form-inline">
                GRAVA:&nbsp;&nbsp;<%=fb.textBox("grava", prop.getProperty("grava"),false,false,viewMode,10,"form-control input-sm",null,null)%>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                PARA:&nbsp;&nbsp;<%=fb.textBox("para", prop.getProperty("para"),false,false,viewMode,10,"form-control input-sm",null,null)%>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                CESAREA:&nbsp;&nbsp;<%=fb.textBox("cesarea", prop.getProperty("cesarea"),false,false,viewMode,10,"form-control input-sm",null,null)%>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                ABORTO:&nbsp;&nbsp;<%=fb.textBox("aborto", prop.getProperty("aborto"),false,false,viewMode,10,"form-control input-sm",null,null)%>
            </td>
           </tr>
           <tr>
            <td colspan="4" class="controls form-inline">
                Fecha de Ultima menstruación&nbsp;
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1"/>
                    <jsp:param name="format" value="dd/mm/yyyy"/>
                    <jsp:param name="nameOfTBox1" value="fecha_ultima_menstruacion" />
                    <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_ultima_menstruacion")!=null?prop.getProperty("fecha_ultima_menstruacion"):""%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                </jsp:include>
                &nbsp;&nbsp;
                Fecha Probable de Parto&nbsp;
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1"/>
                    <jsp:param name="format" value="dd/mm/yyyy"/>
                    <jsp:param name="nameOfTBox1" value="fecha_probable_parto" />
                    <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_probable_parto")!=null?prop.getProperty("fecha_probable_parto"):""%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                </jsp:include>
                &nbsp;&nbsp;
                Menarquia:&nbsp;&nbsp;<%=fb.textBox("menarquia", prop.getProperty("menarquia"),false,false,viewMode,4,"form-control input-sm",null,null)%>
                &nbsp;&nbsp;
                Tipaje y RH:&nbsp;&nbsp;<%=fb.textBox("tipaje_y_rh", prop.getProperty("tipaje_y_rh"),false,false,viewMode,4,"form-control input-sm",null,null)%>
            </td>
           </tr>
           
            <tr>
                <td colspan="4">Control Prenatal&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("control_prenatal","S",prop.getProperty("control_prenatal")!=null&&prop.getProperty("control_prenatal").equals("S"),viewMode,false)%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("control_prenatal","N",prop.getProperty("control_prenatal")!=null&&prop.getProperty("control_prenatal").equals("N"),viewMode,false)%>&nbsp;NO</label>
               </td> 
           </tr>
           
           <tr class="bg-headtabla2">
            <th colspan="4">EVALUACIÓN OBSTETRICA</th>
           </tr>
           
           <tr>
                <td colspan="4">Mamas:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("evaluacion_obstetrica0","BL",prop.getProperty("evaluacion_obstetrica0")!=null&&prop.getProperty("evaluacion_obstetrica0").equals("BL"),viewMode,false)%>&nbsp;Blandas</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica0","TU",prop.getProperty("evaluacion_obstetrica0")!=null&&prop.getProperty("evaluacion_obstetrica0").equals("TU"),viewMode,false)%>&nbsp;Turgentes</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica0","DU",prop.getProperty("evaluacion_obstetrica0")!=null&&prop.getProperty("evaluacion_obstetrica0").equals("DU"),viewMode,false)%>&nbsp;Duras</label>
               </td> 
           </tr>
           <tr>
                <td colspan="4" class="controls form-inline">Movimientos Fetales:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("evaluacion_obstetrica1","S",prop.getProperty("evaluacion_obstetrica1")!=null&&prop.getProperty("evaluacion_obstetrica1").equals("S"),viewMode,false)%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica1","N",prop.getProperty("evaluacion_obstetrica1")!=null&&prop.getProperty("evaluacion_obstetrica1").equals("N"),viewMode,false)%>&nbsp;NO</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                FCF&nbsp;<%=fb.textBox("fcf", prop.getProperty("fcf"),false,false,viewMode,10,"form-control input-sm",null,null)%>
               </td> 
           </tr>
           <tr>
                <td colspan="4" class="controls form-inline">Actividad Uterina:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <%=fb.textBox("actividad_uterina", prop.getProperty("actividad_uterina"),false,false,viewMode,30,"form-control input-sm",null,null)%>
               </td> 
           </tr>
           
           <tr>
                <td colspan="4" class="controls form-inline">Sangrado transvaginal:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("evaluacion_obstetrica2","S",prop.getProperty("evaluacion_obstetrica2")!=null&&prop.getProperty("evaluacion_obstetrica2").equals("S"),viewMode,false)%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica2","N",prop.getProperty("evaluacion_obstetrica2")!=null&&prop.getProperty("evaluacion_obstetrica2").equals("N"),viewMode,false)%>&nbsp;NO</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                Color&nbsp;<%=fb.textBox("color", prop.getProperty("color"),false,false,(viewMode||prop.getProperty("color").equals("")),10,"form-control input-sm",null,null)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                Cantidad&nbsp;<%=fb.textBox("cantidad", prop.getProperty("cantidad"),false,false,(viewMode||prop.getProperty("cantidad").equals("")),10,"form-control input-sm",null,null)%>
               </td> 
           </tr>
           
           <tr>
                <td colspan="4" class="controls form-inline">
                  Dilatación&nbsp;<%=fb.textBox("dilatacion", prop.getProperty("dilatacion"),false,false,viewMode,10,"form-control input-sm",null,null)%>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  Borramiento&nbsp;<%=fb.textBox("borramiento", prop.getProperty("borramiento"),false,false,viewMode,10,"form-control input-sm",null,null)%>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  Plano&nbsp;<%=fb.textBox("plano", prop.getProperty("plano"),false,false,viewMode,10,"form-control input-sm",null,null)%>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
               </td> 
           </tr>
           
           <tr>
                <td colspan="4">Membranas:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("evaluacion_obstetrica3","I",prop.getProperty("evaluacion_obstetrica3")!=null&&prop.getProperty("evaluacion_obstetrica3").equals("I"),viewMode,false)%>&nbsp;Integras</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica3","R",prop.getProperty("evaluacion_obstetrica3")!=null&&prop.getProperty("evaluacion_obstetrica3").equals("R"),viewMode,false)%>&nbsp;Rotas</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica3","H",prop.getProperty("evaluacion_obstetrica3")!=null&&prop.getProperty("evaluacion_obstetrica3").equals("H"),viewMode,false)%>&nbsp;Horas</label>
               </td> 
           </tr>
           
           <tr>
                <td colspan="4">Presentación:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("evaluacion_obstetrica4","C",prop.getProperty("evaluacion_obstetrica4")!=null&&prop.getProperty("evaluacion_obstetrica4").equals("C"),viewMode,false)%>&nbsp;Cefálica</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica4","P",prop.getProperty("evaluacion_obstetrica4")!=null&&prop.getProperty("evaluacion_obstetrica4").equals("P"),viewMode,false)%>&nbsp;Pélvica</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica4","T",prop.getProperty("evaluacion_obstetrica4")!=null&&prop.getProperty("evaluacion_obstetrica4").equals("T"),viewMode,false)%>&nbsp;Transversa</label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica4","X",prop.getProperty("evaluacion_obstetrica4")!=null&&prop.getProperty("evaluacion_obstetrica4").equals("X"),viewMode,false)%>&nbsp;N/A</label>
               </td> 
           </tr>
           
           <tr>
                <td colspan="4">Consistencia Líquido Amniótico:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("evaluacion_obstetrica5","F",prop.getProperty("evaluacion_obstetrica5")!=null&&prop.getProperty("evaluacion_obstetrica5").equals("F"),viewMode,false)%>&nbsp;Fluido</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica5","E",prop.getProperty("evaluacion_obstetrica5")!=null&&prop.getProperty("evaluacion_obstetrica5").equals("E"),viewMode,false)%>&nbsp;Espeso</label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica5","X",prop.getProperty("evaluacion_obstetrica5")!=null&&prop.getProperty("evaluacion_obstetrica5").equals("X"),viewMode,false)%>&nbsp;N/A</label>
               </td> 
           </tr>
           
           <tr>
              <td colspan="2">
                Secreciones:&nbsp;&nbsp;<label class="pointer"><%=fb.radio("evaluacion_obstetrica6","N",prop.getProperty("evaluacion_obstetrica6")!=null&&prop.getProperty("evaluacion_obstetrica6").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,22)'")%>&nbsp;NO</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica6","OT",prop.getProperty("evaluacion_obstetrica6")!=null&&prop.getProperty("evaluacion_obstetrica6").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,22)'",""," data-index=22 data-message='Por favor indique las secreciones.'")%>&nbsp;SI</label>
               </td>
               <td colspan="2">
                 <%=fb.textarea("observacion22",prop.getProperty("observacion22"),false,false,(viewMode||prop.getProperty("observacion22").equals("")),0,1,2000,"form-control input-sm","",null)%>
               </td>
            </tr>
            
             <tr>
                <td colspan="4" class="controls form-inline">
                  Abdomen:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.checkbox("abdomen0","0",prop.getProperty("abdomen0")!=null&&prop.getProperty("abdomen0").equals("0"),viewMode,null,null,"","")%>&nbsp;Blando</label>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.checkbox("abdomen1","1",prop.getProperty("abdomen1")!=null&&prop.getProperty("abdomen1").equals("1"),viewMode,null,null,"","")%>&nbsp;Distendido</label>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.checkbox("abdomen2","2",prop.getProperty("abdomen2")!=null&&prop.getProperty("abdomen2").equals("2"),viewMode,null,null,"","")%>&nbsp;Doloroso</label>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.checkbox("abdomen3","3",prop.getProperty("abdomen3")!=null&&prop.getProperty("abdomen3").equals("3"),viewMode,null,null,"","")%>&nbsp;Gravídico</label>

                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  Altura Uterina&nbsp;<%=fb.textBox("altura_ulterina", prop.getProperty("altura_ulterina"),false,false,viewMode,10,"form-control input-sm",null,null)%>
               </td> 
           </tr>
           
           <tr>
              <td colspan="2">
                Edema:&nbsp;&nbsp;<label class="pointer"><%=fb.radio("evaluacion_obstetrica7","N",prop.getProperty("evaluacion_obstetrica7")!=null&&prop.getProperty("evaluacion_obstetrica7").equals("N"),viewMode,false, null,null, "onclick='shouldTypeRadio(false,23)'")%>&nbsp;NO</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica7","S",prop.getProperty("evaluacion_obstetrica7")!=null&&prop.getProperty("evaluacion_obstetrica7").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,23)'",""," data-index=23 data-message='Por favor indique las edemas.'")%>&nbsp;SI</label>
               </td>
               <td colspan="2">
                 <%=fb.textarea("observacion23",prop.getProperty("observacion23"),false,false,(viewMode||prop.getProperty("observacion23").equals("")),0,1,2000,"form-control input-sm","",null)%>
               </td>
            </tr>
            
            <tr>
              <td colspan="2">
                Varices:&nbsp;&nbsp;<label class="pointer"><%=fb.radio("evaluacion_obstetrica8","N",prop.getProperty("evaluacion_obstetrica8")!=null&&prop.getProperty("evaluacion_obstetrica8").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,24)'")%>&nbsp;NO</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("evaluacion_obstetrica8","S",prop.getProperty("evaluacion_obstetrica8")!=null&&prop.getProperty("evaluacion_obstetrica8").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,24)'",""," data-index=24 data-message='Por favor indique las varices.'")%>&nbsp;SI</label>
               </td>
               <td colspan="2">
                 <%=fb.textarea("observacion24",prop.getProperty("observacion24"),false,false,(viewMode||prop.getProperty("observacion24").equals("")),0,1,2000,"form-control input-sm","",null)%>
               </td>
            </tr>
            
         <tr class="bg-headtabla2">
            <th colspan="4">NUTRICION: CRIBADO NUTRICIONAL</th>
         </tr>

         <tr>
            <td colspan="4" class="controls form-inline">
            Ha disminuido la ingesta en las &uacute;ltimas dos semanas:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional1","S",prop.getProperty("cribado_nutricional0")!=null&&prop.getProperty("cribado_nutricional1").equals("S"),viewMode,false)%>&nbsp;SI</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional1","N",prop.getProperty("cribado_nutricional1")!=null&&prop.getProperty("cribado_nutricional1").equals("N"),viewMode,false)%>&nbsp;NO</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="4" class="controls form-inline">
            Padece de Diabetes Gestacional:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional2","S",prop.getProperty("cribado_nutricional2")!=null&&prop.getProperty("cribado_nutricional2").equals("S"),viewMode,false)%>&nbsp;SI</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional2","N",prop.getProperty("cribado_nutricional2")!=null&&prop.getProperty("cribado_nutricional2").equals("N"),viewMode,false)%>&nbsp;NO</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="4" class="controls form-inline">
            Toma tres o m&aacute;s tragos de licor por d&iacute;a:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional3","S",prop.getProperty("cribado_nutricional3")!=null&&prop.getProperty("cribado_nutricional3").equals("S"),viewMode,false)%>&nbsp;SI</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional3","N",prop.getProperty("cribado_nutricional3")!=null&&prop.getProperty("cribado_nutricional3").equals("N"),viewMode,false)%>&nbsp;NO</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="4" class="controls form-inline">
            Progreso de control de crecimiento y desarrollo:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional4","A",prop.getProperty("cribado_nutricional4")!=null&&prop.getProperty("cribado_nutricional4").equals("A"),viewMode,false)%>&nbsp;Adecuado</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional4","E",prop.getProperty("cribado_nutricional4")!=null&&prop.getProperty("cribado_nutricional4").equals("E"),viewMode,false)%>&nbsp;Excesivo</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("cribado_nutricional4","D",prop.getProperty("cribado_nutricional4")!=null&&prop.getProperty("cribado_nutricional4").equals("D"),viewMode,false)%>&nbsp;Deficiente</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="4" class="controls form-inline">Nombre de Nutricionista Enterada:&nbsp;<%=fb.textBox("nutricionista", prop.getProperty("nutricionista"),false,false,(viewMode||prop.getProperty("nutricionista").equals("")),30,"form-control input-sm",null,null)%>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hora&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1"/>
                <jsp:param name="format" value="hh12:mi:ss am"/>
                <jsp:param name="nameOfTBox1" value="hora" />
                <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")!=null?prop.getProperty("hora"):""%>" />
                <jsp:param name="readonly" value="<%=(viewMode||prop.getProperty("hora").equals(""))?"y":"n"%>"/>
            </jsp:include>
            <span id="via_container">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            Via de comunicación&nbsp;
            <%=fb.select("via","C=Correo,T=Teléfono,P=Personal,S=SMS",prop.getProperty("via"),false,viewMode,0,"form-control input-sm",null,"",null,"S")%></span>
            </td>
        </tr>

           
        <%}%>

        </tbody>
        </table>

    <div class="footerform">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
            <%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>
            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
        </tr>
    </table> </div> 
<%=fb.formEnd(true)%>
 
 </div>
 </div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	prop = new Properties();
    
    prop.setProperty("pac_id",request.getParameter("pacId"));
	prop.setProperty("admision",request.getParameter("noAdmision"));
	prop.setProperty("tipo_cuestionario",request.getParameter("fg"));
    prop.setProperty("usuario_creacion", (String) session.getAttribute("_userName"));
    
    if(fg.trim().equals("PE") || fg.trim().equals("EM")){
        prop.setProperty("fecha_creacion", request.getParameter("fecha_creacion"));
    } else prop.setProperty("fecha_creacion", cDateTime);
    
    if (request.getParameter("paciente_llego") != null) prop.setProperty("paciente_llego", request.getParameter("paciente_llego"));
    if (request.getParameter("fecha_ingreso") != null && !request.getParameter("fecha_ingreso").equals("")) prop.setProperty("fecha_ingreso", request.getParameter("fecha_ingreso"));
    if (request.getParameter("hora_ingreso") != null && !request.getParameter("hora_ingreso").equals("")) prop.setProperty("hora_ingreso", request.getParameter("hora_ingreso"));
    if (request.getParameter("codigo_diag") != null && !request.getParameter("codigo_diag").equals("")) prop.setProperty("codigo_diag", request.getParameter("codigo_diag"));
    if (request.getParameter("desc_diag") != null && !request.getParameter("desc_diag").equals("")) prop.setProperty("desc_diag", request.getParameter("desc_diag"));
    if (request.getParameter("procedente") != null) prop.setProperty("procedente", request.getParameter("procedente"));
    if (request.getParameter("gen_alerta") != null && !request.getParameter("gen_alerta").trim().equals("")) prop.setProperty("gen_alerta", request.getParameter("gen_alerta"));
    if (request.getParameter("religion") != null) prop.setProperty("religion", request.getParameter("religion"));
    
    if (request.getParameter("nutricionista") != null) prop.setProperty("nutricionista", request.getParameter("nutricionista"));
    if (request.getParameter("hora") != null) prop.setProperty("hora", request.getParameter("hora"));
    if (request.getParameter("via") != null) prop.setProperty("via", request.getParameter("via"));
    
    if (fg.trim().equalsIgnoreCase("PE")) {
        
        if(request.getParameter("historia_nacimiento") != null) prop.setProperty("historia_nacimiento",request.getParameter("historia_nacimiento"));
        if (request.getParameter("apgar").trim() != null && !request.getParameter("apgar").trim().equals("")) prop.setProperty("apgar", request.getParameter("apgar"));
        if (request.getParameter("peso_al_nacer").trim() != null && !request.getParameter("peso_al_nacer").trim().equals("")) prop.setProperty("peso_al_nacer", request.getParameter("peso_al_nacer"));
        if(request.getParameter("cuidado_especial") != null) prop.setProperty("cuidado_especial",request.getParameter("cuidado_especial"));

    } else if (fg.trim().equalsIgnoreCase("C1")){
        if (request.getParameter("aislamiento") != null) prop.setProperty("aislamiento", request.getParameter("aislamiento"));
        if (request.getParameter("perdido_peso") != null) prop.setProperty("perdido_peso", request.getParameter("perdido_peso"));
        if (request.getParameter("disminucion") != null) prop.setProperty("disminucion", request.getParameter("disminucion"));
        if (request.getParameter("diabetes") != null) prop.setProperty("diabetes", request.getParameter("diabetes"));
        if (request.getParameter("unidad_cuidado") != null) prop.setProperty("unidad_cuidado", request.getParameter("unidad_cuidado"));
        if (request.getParameter("nutricion_enteral") != null) prop.setProperty("nutricion_enteral", request.getParameter("nutricion_enteral"));
        if (request.getParameter("problema_comunicacion") != null) prop.setProperty("problema_comunicacion", request.getParameter("problema_comunicacion"));
        
        if (request.getParameter("movimiento") != null) prop.setProperty("movimiento", request.getParameter("movimiento"));
        if (request.getParameter("necesidad") != null) prop.setProperty("necesidad", request.getParameter("necesidad"));
        if (request.getParameter("creencia") != null) prop.setProperty("creencia", request.getParameter("creencia"));
        if (request.getParameter("servicio_religioso") != null) prop.setProperty("servicio_religioso", request.getParameter("servicio_religioso"));
        if (request.getParameter("voluntades_anticipadas") != null) prop.setProperty("voluntades_anticipadas", request.getParameter("voluntades_anticipadas"));
        if (request.getParameter("realiza_ejercicio") != null) prop.setProperty("realiza_ejercicio", request.getParameter("realiza_ejercicio"));
        if (request.getParameter("ingiere_alcohol") != null) prop.setProperty("ingiere_alcohol", request.getParameter("ingiere_alcohol"));
        if (request.getParameter("ingiere_alcohol") != null && request.getParameter("ingiere_alcohol").equals("S")) prop.setProperty("frecuencia_alcohol", request.getParameter("frecuencia_alcohol"));
        if (request.getParameter("fumador") != null) prop.setProperty("fumador", request.getParameter("fumador"));
        if (request.getParameter("fumador") != null && request.getParameter("fumador").equals("S")) {
           prop.setProperty("fumador_frecuencia", request.getParameter("fumador_frecuencia"));
           if(request.getParameter("cantidad_cigarillo") != null && !request.getParameter("cantidad_cigarillo").trim().equals(""))prop.setProperty("cantidad_cigarillo", request.getParameter("cantidad_cigarillo"));
        }
        if (request.getParameter("drogadicto") != null) prop.setProperty("drogadicto", request.getParameter("drogadicto"));
        if (request.getParameter("estado_salud") != null) prop.setProperty("estado_salud", request.getParameter("estado_salud"));
        if (request.getParameter("vive_con") != null) prop.setProperty("vive_con", request.getParameter("vive_con"));
        
        if (request.getParameter("situacion_laboral") != null) prop.setProperty("situacion_laboral", request.getParameter("situacion_laboral"));
        if (request.getParameter("residencia_actual") != null) prop.setProperty("residencia_actual", request.getParameter("residencia_actual"));
        if (request.getParameter("aspecto_economico") != null) prop.setProperty("aspecto_economico", request.getParameter("aspecto_economico"));
        
        if (request.getParameter("valoracion") != null) prop.setProperty("valoracion", request.getParameter("valoracion"));
        if (request.getParameter("valoracion_quir") != null) prop.setProperty("valoracion_quir", request.getParameter("valoracion_quir"));
        if (request.getParameter("explicacion_consentimiento") != null) prop.setProperty("explicacion_consentimiento", request.getParameter("explicacion_consentimiento"));
        if (request.getParameter("protesis_dental") != null) prop.setProperty("protesis_dental", request.getParameter("protesis_dental"));
        if (request.getParameter("lentes_contacto") != null) prop.setProperty("lentes_contacto", request.getParameter("lentes_contacto"));
        if (request.getParameter("ultima_comida") != null) prop.setProperty("ultima_comida", request.getParameter("ultima_comida"));
        
        if (request.getParameter("medicos_enterados") != null) prop.setProperty("medicos_enterados", request.getParameter("medicos_enterados"));
        if (request.getParameter("vestir_desvestir_ali") != null) prop.setProperty("vestir_desvestir_ali", request.getParameter("vestir_desvestir_ali"));
        if (request.getParameter("banio_higiene") != null) prop.setProperty("banio_higiene", request.getParameter("banio_higiene"));
        if (request.getParameter("movilidad_deambulacion") != null) prop.setProperty("movilidad_deambulacion", request.getParameter("movilidad_deambulacion"));
        if (request.getParameter("perdida_peso_15") != null) prop.setProperty("perdida_peso_15", request.getParameter("perdida_peso_15"));
        if (request.getParameter("mayor_80") != null) prop.setProperty("mayor_80", request.getParameter("mayor_80"));
    }
    else if (fg.trim().equalsIgnoreCase("EM")) {
      if (request.getParameter("evolucion_embarazos") != null) prop.setProperty("evolucion_embarazos", request.getParameter("evolucion_embarazos"));
      if (request.getParameter("embarazos_anteriores") != null) prop.setProperty("embarazos_anteriores", request.getParameter("embarazos_anteriores"));
      if (request.getParameter("partos_anteriores") != null) prop.setProperty("partos_anteriores", request.getParameter("partos_anteriores"));
      if (request.getParameter("malformaciones_congenitas") != null) prop.setProperty("malformaciones_congenitas", request.getParameter("malformaciones_congenitas"));
      if (request.getParameter("grava") != null && !request.getParameter("grava").trim().equals("")) prop.setProperty("grava", request.getParameter("grava"));
      if (request.getParameter("para") != null && !request.getParameter("para").trim().equals("")) prop.setProperty("para", request.getParameter("para"));
      if (request.getParameter("aborto") != null && !request.getParameter("aborto").trim().equals("")) prop.setProperty("aborto", request.getParameter("aborto"));
      if (request.getParameter("cesarea") != null && !request.getParameter("cesarea").trim().equals("")) prop.setProperty("cesarea", request.getParameter("cesarea"));
      if (request.getParameter("fecha_ultima_menstruacion") != null && !request.getParameter("fecha_ultima_menstruacion").trim().equals("")) prop.setProperty("fecha_ultima_menstruacion", request.getParameter("fecha_ultima_menstruacion"));
      if (request.getParameter("fecha_probable_parto") != null && !request.getParameter("fecha_probable_parto").trim().equals("")) prop.setProperty("fecha_probable_parto", request.getParameter("fecha_probable_parto"));
      if (request.getParameter("menarquia") != null && !request.getParameter("menarquia").trim().equals("")) prop.setProperty("menarquia", request.getParameter("menarquia"));
      if (request.getParameter("tipaje_y_rh") != null && !request.getParameter("tipaje_y_rh").trim().equals("")) prop.setProperty("tipaje_y_rh", request.getParameter("tipaje_y_rh"));
      if (request.getParameter("control_prenatal") != null && !request.getParameter("control_prenatal").trim().equals("")) prop.setProperty("control_prenatal", request.getParameter("control_prenatal"));
      if (request.getParameter("fcf") != null && !request.getParameter("fcf").trim().equals("")) prop.setProperty("fcf", request.getParameter("fcf"));
      if (request.getParameter("actividad_uterina") != null && !request.getParameter("actividad_uterina").trim().equals("")) prop.setProperty("actividad_uterina", request.getParameter("actividad_uterina"));
      if (request.getParameter("color") != null && !request.getParameter("color").trim().equals("")) prop.setProperty("color", request.getParameter("color"));
      if (request.getParameter("cantidad") != null && !request.getParameter("cantidad").trim().equals("")) prop.setProperty("cantidad", request.getParameter("cantidad"));
      if (request.getParameter("dilatacion") != null && !request.getParameter("dilatacion").trim().equals("")) prop.setProperty("dilatacion", request.getParameter("dilatacion"));
      if (request.getParameter("borramiento") != null && !request.getParameter("borramiento").trim().equals("")) prop.setProperty("borramiento", request.getParameter("borramiento"));
      if (request.getParameter("plano") != null && !request.getParameter("plano").trim().equals("")) prop.setProperty("plano", request.getParameter("plano"));
      if (request.getParameter("altura_ulterina") != null && !request.getParameter("altura_ulterina").trim().equals("")) prop.setProperty("altura_ulterina", request.getParameter("altura_ulterina"));
    
    }
    
    for ( int o = 0; o<30; o++ ){
     
      if(request.getParameter("acompaniado_por"+o) != null) prop.setProperty("acompaniado_por"+o,request.getParameter("acompaniado_por"+o));
      if (request.getParameter("observacion"+o) != null && !request.getParameter("observacion"+o).trim().equals("")) prop.setProperty("observacion"+o, request.getParameter("observacion"+o));
      
      if (fg.trim().equalsIgnoreCase("C1")) {
          if (request.getParameter("dificultad_movimiento"+o)!=null) prop.setProperty("dificultad_movimiento"+o, request.getParameter("dificultad_movimiento"+o));
          if (request.getParameter("necesidad_especial"+o)!=null) prop.setProperty("necesidad_especial"+o, request.getParameter("necesidad_especial"+o));
          if (request.getParameter("no_no"+o)!=null) prop.setProperty("no_no"+o, request.getParameter("no_no"+o));
          if (request.getParameter("tiene_a_cargo"+o)!=null) prop.setProperty("tiene_a_cargo"+o, request.getParameter("tiene_a_cargo"+o));
          
          if (request.getParameter("aislamiento_det"+o) != null) prop.setProperty("aislamiento_det"+o, request.getParameter("aislamiento_det"+o));
          if (request.getParameter("se_observa"+o) != null) prop.setProperty("se_observa"+o, request.getParameter("se_observa"+o));
          if (request.getParameter("datos_obetenidos_de"+o) != null) prop.setProperty("datos_obetenidos_de"+o, request.getParameter("datos_obetenidos_de"+o));
      } 
      else if (fg.trim().equalsIgnoreCase("PE")) {
        if(request.getParameter("cribado_nutricional"+o) != null) prop.setProperty("cribado_nutricional"+o,request.getParameter("cribado_nutricional"+o));
        if(request.getParameter("evaluacion_crecimiento"+o) != null) prop.setProperty("evaluacion_crecimiento"+o,request.getParameter("evaluacion_crecimiento"+o));
      } 
      else if (fg.trim().equalsIgnoreCase("EM")) {
        if (request.getParameter("evaluacion_obstetrica"+o) != null ) prop.setProperty("evaluacion_obstetrica"+o,request.getParameter("evaluacion_obstetrica"+o));
        if (request.getParameter("abdomen"+o) != null ) prop.setProperty("abdomen"+o,request.getParameter("abdomen"+o));
        if(request.getParameter("cribado_nutricional"+o) != null) prop.setProperty("cribado_nutricional"+o,request.getParameter("cribado_nutricional"+o));
      }
    }

	if (modeSec.trim().equalsIgnoreCase("edit")) {
      prop.setProperty("usuario_modificacion", (String) session.getAttribute("_userName"));
    }
	if (baction.equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) cuestionario.add(prop);
		else cuestionario.update(prop);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (cuestionario.getErrCode().equals("1"))
{
%>
	alert('<%=cuestionario.getErrMsg()%>');
<%

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(cuestionario.getErrException());
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&from=<%=from%>&formularios=<%=formularios%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST

SecMgr.setConnection(null);
CmnMgr.setConnection(null);
SQLMgr.setConnection(null);
cuestionario.setConnection(null);

prop = null;
%>