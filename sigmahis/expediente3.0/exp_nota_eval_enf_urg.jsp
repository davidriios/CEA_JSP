<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Properties"%>
<%@ page import="java.util.Vector" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iAntMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="NEEUMgr" scope="page" class="issi.expediente.NotaEvaluacionEnfermeraUrgenciaMgr" />
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
NEEUMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
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
String fp = request.getParameter("fp");
String key = "";
String descLabel ="NOTAS DE EVALUACION DE ENFERMERA DE URGENCIA";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String onlyRiesgo = request.getParameter("only_riesgo") == null ? "" : request.getParameter("only_riesgo");
String companyId = (String) session.getAttribute("_companyId");
String estado = request.getParameter("estado");
String recuperar = request.getParameter("recuperar");
String xtraSections = request.getParameter("xtraSections");

if (modeSec == null || modeSec.trim().equalsIgnoreCase("")) modeSec = "add";
if (mode == null || mode.trim().equalsIgnoreCase("")) mode = "add";

if (estado == null) estado = "";
if (fg == null) fg = "NEEU";
if (from == null) from = "";
if (fp == null) fp = "";
if (recuperar == null) recuperar = "";
if (xtraSections == null) xtraSections = "";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if(fg.trim().equalsIgnoreCase("NEEU")) descLabel += " - URGENCIA"; 

int totNota = 0;
String formulario = "";

int prevAdm = Integer.parseInt(noAdmision) - 1;
String historiaActual = "";

int totPrevAdm = 0;
if (!modeSec.trim().equalsIgnoreCase("view")){
    totPrevAdm = CmnMgr.getCount("select count(*) from tbl_adm_admision where pac_id = "+pacId+" and fecha_ingreso between add_months(trunc(sysdate,'mm'),-1) and last_day(sysdate) /*and categoria in (2,3)*/ and secuencia = "+prevAdm);
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
    
    if (!recuperar.equals("") && recuperar.trim().equalsIgnoreCase("Y"))
        prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+prevAdm+" and tipo_nota = upper('"+fg+"')");
    else prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = upper('"+fg+"')");
    
    System.out.println("::::::::::::::::::::::::: prop = "+prop);
	
    if (prop == null)
	{
	 	prop = new Properties();
		prop.setProperty("fecha",cDateTime.substring(0,10));
		prop.setProperty("hora",cDateTime.substring(11));
		if(!viewMode) {
			mode="add";
			modeSec="add";
		}
		
        
        if (onlyRiesgo.equals("")) {
          totNota = CmnMgr.getCount("select count(*) from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = upper('"+fg+"')");
        }
	}
	else
	{
        if(!viewMode) {
			mode = "edit"; 
			modeSec= "edit"; 
		}
        historiaActual = prop.getProperty("historiaActual");
        
        viewMode = true;
        
        System.out.print("----------------------------------------------------- historiaActual ="+historiaActual);
	}
    
    sql = "select p.sexo, p.edad, nvl(get_sec_comp_param("+companyId+", 'SAL_PED_EDAD'), 0) edad_ped, nvl(get_sec_comp_param("+companyId+", 'SAL_ADO_EDAD'), 0) edad_ado, nvl(get_sec_comp_param("+companyId+", 'SAL_TERCERA_EDAD'), 0) edad_3ra, (select e.formulario from tbl_sal_nota_eval_enf_urg e where e.pac_id = p.pac_id and e.admision = "+noAdmision+" and rownum = 1) formulario , (select to_char(e.fecha_recup,'dd/mm/yyyy') fecha_recup from tbl_sal_nota_eval_enf_urg e where e.pac_id = p.pac_id and e.admision = "+noAdmision+" and rownum = 1) fecha_recup, (select usuario_recup from tbl_sal_nota_eval_enf_urg e where e.pac_id = p.pac_id and e.admision = "+noAdmision+" and rownum = 1) usuario_recup from vw_adm_paciente p where p.pac_id = "+pacId;
    
    cdo = SQLMgr.getData(sql);
    
    formulario = cdo.getColValue("formulario", "-1");
    
    boolean viewModRiesgo = viewMode;
    if (!viewMode && onlyRiesgo.equals("1")) {
        viewModRiesgo = false;
        if (!formulario.equals("") && !formulario.equals("-1")) {
          if (!viewMode) {
            modeSec = "edit";
            mode = "edit";
          }
        }
    }
    
    if (request.getParameter("force_edit") != null){
        viewMode = false;
    }
    
    String msg = "";
    if (!viewMode && totNota > 0 && onlyRiesgo.equals("")) {
        viewMode = true;
        msg = "No es posible registrar Evaluación Inicial I porque ya existe Evaluación Inicial II";
    }
%>
<!DOCTYPE html>
<html lang="en"> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
var noNewHeight = true;
<%if(fg.trim().equalsIgnoreCase("NEEU")){%>
document.title = 'Notas de Evaluaci&oacute;n de Enfermera de Urgencia - '+document.title;
<%}%>
function doAction(){<%if (cdo.getColValue("sexo"," ").equalsIgnoreCase("F") && onlyRiesgo.equals("") ) {%> getHistoriaobs();<%}%>}
function getRadio(obj,opt){var rad_val = obj.value;if(rad_val == 'O'){eval('document.form0.otros'+opt).readOnly=false;eval('document.form0.otros'+opt).className='FormDataObjectEnabled';}else{eval('document.form0.otros'+opt).value = '';eval('document.form0.otros'+opt).readOnly=true;eval('document.form0.otros'+opt).className='FormDataObjectDisabled';}}
/*
*@param obj : Nombre del checkbox sin el índice 
*@param qty : Cantidad de checkbox
*@param otros : Nombre del textarea sin el índice
*@param check : El checkbox con el nombre Otros
*/
function ctrlOtros(obj,qty,otros,check){
  for ( i = 0; i<qty; i++ ){ 
  
  if ( obj == "alergia" ){
        if ( $('#'+obj+'0').is(":checked") ){

           if ( $('#'+obj+(i+1)).length ){
               $('#'+obj+(i+1)).attr("checked",false);
               $('#'+obj+(i+1)).attr("disabled",true);
               $("#otros"+otros).attr("readonly",true).addClass("FormDataObjectDisabled").val("");
               debug("no way");
            }
            
	    }else{
            $('#'+obj+(i+1)).attr("disabled",false);
            $('#otros'+otros).removeClass("FormDataObjectDisabled").attr("readonly",false);
            
            /*if ( $('#'+obj+check).is(":checked") ) {
             $('#otros'+otros).removeClass("FormDataObjectDisabled").attr("readonly",false);
              break;
            }else{
              $('#otros'+otros).addClass("FormDataObjectDisabled").attr("readonly",true).val("");
            }*/
        } 
	}else{
	    if ( $('#'+obj+check).is(":checked") ) {
		   $('#otros'+otros).removeClass("FormDataObjectDisabled").attr("readonly",false);
		   break;
		}else{
		   $('#otros'+otros).addClass("FormDataObjectDisabled").attr("readonly",true).val("");
		}
	}
   }//for
}
 
function getHistoriaobs(){  
var sexo = $("#sexo", parent.document).val();
if( eval('document.form0.historiaobs')[0].checked == true && sexo=='M'){eval('document.form0.historiaobs')[0].checked = false;top.CBMSG.warning('No es posible que un hombre quede embarazado. Revise el sexo Del Paciente.!');}

    if( eval('document.form0.historiaobs') && eval('document.form0.historiaobs')[0].checked == true && sexo=='F'){
		eval('document.form0.fum').readOnly=false;
		eval('document.form0.fum').className='form-control input-sm FormDataObjectEnabled';
		eval('document.form0.fup').readOnly=false;
		eval('document.form0.fup').className='form-control input-sm FormDataObjectEnabled';
		eval('document.form0.gin').readOnly=false;
		eval('document.form0.gin').className='form-control input-sm FormDataObjectEnabled';
		
		eval('document.form0.g').readOnly=false;
		eval('document.form0.g').className='form-control input-sm FormDataObjectEnabled';
		eval('document.form0.p').readOnly=false;
		eval('document.form0.p').className='form-control input-sm FormDataObjectEnabled';
		eval('document.form0.c').readOnly=false;
		eval('document.form0.c').className='form-control input-sm FormDataObjectEnabled';
		eval('document.form0.a').readOnly=false;
		eval('document.form0.a').className='form-control input-sm FormDataObjectEnabled';
		/*document.form0.g.value = '';
		document.form0.p.value = '';
		document.form0.c.value = '';
		document.form0.a.value = '';
		
		eval('document.form0.g').readOnly=true;
		eval('document.form0.p').readOnly=true;
		eval('document.form0.c').readOnly=true;
		eval('document.form0.a').readOnly=true;
		
		eval('document.form0.g').className='FormDataObjectDisabled';
		eval('document.form0.p').className='FormDataObjectDisabled';
		eval('document.form0.c').className='FormDataObjectDisabled';
		eval('document.form0.a').className='FormDataObjectDisabled';*/
		
		eval('document.form0.ctrl')[0].disabled=false;
		eval('document.form0.ctrl')[0].checked=true;
		eval('document.form0.ctrl')[1].disabled=false;
		
	}//if
	else
	if( eval('document.form0.historiaobs') && eval('document.form0.historiaobs')[1].checked == true  ){
		/*eval('document.form0.g').readOnly=false;
		eval('document.form0.p').readOnly=false;
		eval('document.form0.c').readOnly=false;
		eval('document.form0.a').readOnly=false;
		
		eval('document.form0.g').className='FormDataObjectEnabled';
		eval('document.form0.p').className='FormDataObjectEnabled';
		eval('document.form0.c').className='FormDataObjectEnabled';
		eval('document.form0.a').className='FormDataObjectEnabled';*/
		document.form0.g.value = '';
		document.form0.p.value = '';
		document.form0.c.value = '';
		document.form0.a.value = '';
		
		eval('document.form0.g').readOnly=true;
		eval('document.form0.p').readOnly=true;
		eval('document.form0.c').readOnly=true;
		eval('document.form0.a').readOnly=true;
		
		eval('document.form0.g').className='form-control input-sm FormDataObjectDisabled';
		eval('document.form0.p').className='form-control input-sm FormDataObjectDisabled';
		eval('document.form0.c').className='form-control input-sm FormDataObjectDisabled';
		eval('document.form0.a').className='form-control input-sm FormDataObjectDisabled';
		
		document.form0.fum.value = '';
		document.form0.fup.value = '';
		document.form0.gin.value = '';
		eval('document.form0.fum').readOnly=true;
		eval('document.form0.fum').className='form-control input-sm FormDataObjectDisabled';
		eval('document.form0.fup').readOnly=true;
		eval('document.form0.fup').className='form-control input-sm FormDataObjectDisabled';
		eval('document.form0.gin').readOnly=true;
		eval('document.form0.gin').className='form-control input-sm FormDataObjectDisabled';
		
		eval('document.form0.ctrl')[0].checked=false;
		eval('document.form0.ctrl')[0].disabled=true;
		eval('document.form0.ctrl')[1].checked=false;
		eval('document.form0.ctrl')[1].disabled=true;
		
	}
	
}

$(document).ready(function(){
  <%if(!msg.equals("")){%>showError("<%=msg%>");<%}%>
  $("input:checkbox[name*='alergia']").not($("#alergia0")).click(function(c){
    var that = $(this);
    var niega = $("#alergia0").is(":checked")
    if (niega) {
      c.preventDefault();
      c.stopPropagation();
      return false;
    } else {
      $("#otros8").prop("readOnly", false);
    }
  });
    
  $("#alergia0").click(function(){
    if ($(this).is(":checked")) {
      $("input:checkbox[name*='alergia']").not($("#alergia0")).prop("checked", false)
      $("#otros8").prop("readOnly", true).val("");
    }
  });
  
  // reloading alerts
  if (typeof parent.reloadAlerts === 'function') parent.reloadAlerts();
  else if (typeof parent.parent.reloadAlerts === 'function') parent.parent.reloadAlerts();
  
  if( $("input:checked[name*='riesgo_vulnerabilidad']").length > 0 ) $("#btn_riesgo").prop("disabled", false);
  
  $("input[name*='riesgo_vulnerabilidad']").click(function(e){
    var $self = $(this)
    if($self.val()) $("#btn_riesgo").prop("disabled", false);
    
    if ($self.is(":checked") && $self.val() == '15') {
        $(".riesgo_vulnerabilidad").not($self).prop({checked: false, disabled: true});
    } else {
        $(".riesgo_vulnerabilidad:not(cant-be-checked)").prop({disabled: false});
    }
    
  });
  
  /**/
     $("input:checked[name*='riesgo_vulnerabilidad']").map(function(e) {
        var $self = $(this)
        if ($self.is(":checked") && $self.val() == '15') {
          $(".riesgo_vulnerabilidad").not($self).prop({checked: false, disabled: true});
          e.preventDefault();
          e.stopPropagation();
          return false;
        }
     });
  /**/
  
  // cant be-checked
  $(".cant-be-checked").click(function(e){
      e.preventDefault();
      e.stopPropagation();
      return false;
  });
  
  //recuperar
  <%if(!recuperar.equals("") && recuperar.trim().equalsIgnoreCase("Y")){%>
    $("#baction").val("Guardar");
    $("#form0").submit();
  <%}%>
  
  // force reloadAccordions
  <%if(request.getParameter("force_reload") != null && request.getParameter("force_reload").trim().equals("Y")){%>
    var formulario = $("input:checked[name*='riesgo_vulnerabilidad']").map(function() {return this.value;}).get().join(',');
    _reloadAccordions(formulario);
  <%}%>
   
});

function doSubmit(formName) {
 var proceed = true;
 
 if (proceed){
    setBAction(formName,'Guardar');
    var alergias = [];
    $("input[name^='alergia']").each(function(){
      var self = $(this);
      if (this.checked && this.name != "alergia0") {
        alergias.push($('label[for="'+this.id+'"]').text())
      }
    });
    $("#__alergias__").val(alergias.join());
    
    // alertas riesgos / vulnerabilidad
    var riesgos = [];
    $("input[type='checkbox'].riesgo_vulnerabilidad").not('.cant-be-checked').each(function(){
        var self = $(this);
        if (self.is(':checked') && self.val() != '15') {
            riesgos.push(self.next('label').text());
        }
    });
    $("#__riesgos__").val(riesgos.join());
    
    $("#"+formName).submit();
 }
}

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
  
  if (!$("#fecha").val() || !$("#hora").val() ) {
   showError('Por favor indicar la fecha y hora!');
   return false;
  } else {
    if ( $("input[name^='neurologico']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Neurológico!');
      scrollToElem($("input[name^='neurologico']").get(0))
      return false;
    } 
    else if ( $("input[name^='cardiovascular']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Cardiovascular!');
      scrollToElem($("input[name^='cardiovascular']").get(0))
      return false;
    } 
    else if ( $("input[name^='respiracion']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Estado Respiratorio!');
      scrollToElem($("input[name^='respiracion']").get(0))
      return false;
    } 
    else if ( $("input[name^='get']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo G.E.T Gastro-intestinal!');
      scrollToElem($("input[name^='get']").get(0))
      return false;
    } 
    else if ( $("input[name^='esquel']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Músculo-Esqueletico!');
      scrollToElem($("input[name^='esquel']").get(0))
      return false;
    } 
    else if ( $("input[name^='piel']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Tegumentos (Piel)!');
      scrollToElem($("input[name^='piel']").get(0))
      return false;
    } 
    else if ( $("input[name^='psico']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Psicológico!');
      scrollToElem($("input[name^='psico']").get(0))
      return false;
    } 
    else if ( $("input[name^='alergia']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Alergias!');
      scrollToElem($("input[name^='alergia']").get(0))
      return false;
    } 
    else if ( $("input[name^='antpat']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Antecedentes Patológicos Personales!');
      scrollToElem($("input[name^='antpat']").get(0))
      return false;
    } 
    else if ( $("input[name^='antfam']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Antecedentes Patológicos Familiares!');
      scrollToElem($("input[name^='antfam']").get(0))
      return false;
    } 
    else if ( $("input[name^='anthosp']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Antecedentes de Hospitalización!');
      scrollToElem($("input[name^='anthosp']").get(0))
      return false;
    } 
    else if ( $("input[name^='antcir']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Antecedentes de Cirugías Previas!');
       scrollToElem($("input[name^='antcir']").get(0))
      return false;
    } 
    else if ( $("input[name*='suenio']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Patrón del Sueño!');
      scrollToElem($("input[name*='suenio']").get(0))
      return false;
    } 
    else if ( $("input[name^='nutricional']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Nutricional!');
      scrollToElem($("input[name^='nutricional']").get(0))
      return false;
    }  
    else if ( $("input[name^='genito']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Genito-Urinario!');
      scrollToElem($("input[name^='genito']").get(0))
      return false;
    } 
    else if ( $("input[name^='patron_eliminacion']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Patrón de Eliminación!');
      scrollToElem($("input[name^='patron_eliminacion']").get(0))
      return false;
    } 
    else if ( $("input[name^='inmuni']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Inmunizaciones!');
      scrollToElem($("input[name^='inmuni']").get(0))
      return false;
    } 
    else if ( $("input[name^='transf']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Historial Transfusional!');
      scrollToElem($("input[name^='transf']").get(0))
      return false;
    } 
    else if ( $("input[name^='reac']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Reacción Adversa!');
      scrollToElem($("input[name^='reac']").get(0))
      return false;
    } 
    <%if (cdo.getColValue("sexo"," ").equalsIgnoreCase("F")) {%>
    else if ( $("input[name^='historiaobs']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Historia Obstétrica!');
      scrollToElem($("input[name^='historiaobs']").get(0))
      return false;
    } 
    <%}%>
    else if ( $("input[name^='area']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Área Designada!');
      scrollToElem($("input[name^='area']").get(0))
      return false;
    } 
    <%if (cdo.getColValue("sexo"," ").equalsIgnoreCase("F")) {%>
    else if ( $("input[name^='lactancia']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Esta usted lactando actualmente!');
      scrollToElem($("input[name^='lactancia']").get(0))
      return false;
    }
    <%}%>
    else if ( $("input[name^='riesgo_vulnerabilidad']:checked").length < 1 ) {
      showError('Por favor seleccionar por lo menos una opción en el grupo Historia Evaluación de Riesgo y/o Vulnerabilidad!');
      scrollToElem($("input[name^='riesgo_vulnerabilidad']").get(0))
      return false;
    }
    
  var formularios = $("input:checked[name*='riesgo_vulnerabilidad']").map(function() {return this.value;}).get().join(',');
  $("#formularios").val(formularios);  
  
  var proceed = true;
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    if ( $self.is(":checked") && !$.trim($("#otros"+i).val())) {
      <%=from.trim().equalsIgnoreCase("salida_pop")?"parent.":""%>parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
      proceed = false;
      $self.focus();
      return false;  
    }else  {proceed = true;}
  });
  return proceed;
  }
}

function _reloadAccordions(_formulario) {
  var formulario = _formulario || "<%=formulario%>";
  console.log(window.reloadAccordions)
  if (typeof parent.reloadAccordions === 'function') parent.reloadAccordions(formulario);
  else if (typeof parent.parent.reloadAccordions === 'function') parent.parent.reloadAccordions(formulario);
  else if (window.reloadAccordions === 'function') window.reloadAccordions(formulario);
}

function confirmarRiesgo () {
 var formulario = $("input:checked[name*='riesgo_vulnerabilidad']").map(function() {return this.value;}).get().join(',');
 var $that = $("#btn_riesgo");
 var executed = false;
 $that.prop('disabled', true);
 
 var riesgos = [];
 $("input[type='checkbox'].riesgo_vulnerabilidad").not('.cant-be-checked').each(function(){
	var self = $(this);
	if (self.is(':checked') && self.val() != '15') {
		riesgos.push(self.next('label').text());
	}
 }); 
 
 <%if(modeSec.equals("edit") || mode.equals("edit")){%>
    executed = executeDB('<%=request.getContextPath()%>',"update tbl_sal_nota_eval_enf_urg set formulario = '"+formulario+"', observ_alergias_riesgo = '"+riesgos.join()+"' where pac_id=<%=pacId%> and admision=<%=noAdmision%> and tipo_nota = '<%=fg%>'",'');
 <%} else if(modeSec.equals("add") || mode.equals("add")) {%>
  //executed = executeDB('<%=request.getContextPath()%>',"insert into tbl_sal_nota_eval_enf_urg (pac_id, admision, formulario, tipo_nota) values (<%=pacId%>, <%=noAdmision%>, '"+formulario+"', '<%=fg%>')",'');
 <%}%>

 if (executed) {
	 _reloadAccordions(formulario);
	 
	 if (typeof parent.reloadAlerts === 'function') parent.reloadAlerts();
	 else if (typeof parent.parent.reloadAlerts === 'function') parent.parent.reloadAlerts();
	 
	 $that.prop('disabled', false);
 }
 else {
	 showError("Error tratando de confirmir el riesgo / vulnerabilidad");
	$that.prop('disabled', false);
 }
}

function saveNotasCambio(btn) {
  parent.parent.loadModal('../expediente3.0/exp_notas_de_cambio.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&estado=<%=estado%>', {title:'Notas de Cambio'});
}

function shouldTypeRadio(check, textareaIndex) {
  if (check == true) $("#otros"+textareaIndex).prop("readOnly", false)
  else $("#otros"+textareaIndex).val("").prop("readOnly", true)
}

function __recuperar() {
<%
if (!viewMode){
Properties prop1 = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+prevAdm+" and tipo_nota = upper('"+fg+"')");
if (prop1 == null) {
  prop1 = new Properties();
}
if (prop1.getProperty("historiaActual") != null && !"".equals(prop1.getProperty("historiaActual"))) {
if (totPrevAdm > 0) {
%>  
  
var c = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_nota_eval_enf_urg',"pac_id = <%=pacId%> and admision = <%=noAdmision%> and fecha_recup is not null and usuario_recup is not null and tipo_nota = upper('<%=fg%>')",'');
  
  if (c != 0) parent.CBMSG.error("Ya hubó una recuperación para esa admisión!");
  else window.location = '../expediente3.0/exp_nota_eval_enf_urg.jsp?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&only_riesgo=<%=onlyRiesgo%>&fp=<%=fp%>&estado=<%=estado%>&formulario=<%=formulario%>&recuperar=Y&xtraSections=<%=xtraSections%>';
<%}} else {%>
  parent.CBMSG.error("La nota no está llena para la admisión: #<%=prevAdm%>");
<%}}%>  
}

function tempEdit(){
    window.location = '../expediente3.0/exp_nota_eval_enf_urg.jsp?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&force_edit=Y&fp=<%=fp%>&estado=<%=estado%>&formulario=<%=formulario%>';
}

function printExp(type){
    var formularios = $("#formulario").val();
    if(!type)
        abrir_ventana("../expediente3.0/print_exp_seccion_108.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&formularios="+formularios);
    else
        abrir_ventana("../expediente3.0/print_nota_eval_enf_urg.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&formularios="+formularios);
}
</script>
<style>
table {
  width: 100%;
  border-collapse: collapse;
}

td, th {
  padding: .25em;
  border: 1px solid black;
}

tbody:nth-child(odd) {
  background: #CCC;
}

</style>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">    
    <div class="table-responsive" data-pattern="priority-columns">
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("modeSec",modeSec)%>
		<%=fb.hidden("seccion",seccion)%>
		<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
		<%=fb.hidden("dob","")%>
		<%=fb.hidden("codPac","")%>
		<%=fb.hidden("pacId",pacId)%>
		<%=fb.hidden("noAdmision",noAdmision)%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("desc",desc)%>
		<%=fb.hidden("from",from)%>
		<%=fb.hidden("only_riesgo",onlyRiesgo)%>
		<%=fb.hidden("estado",estado)%>
		<%=fb.hidden("formulario",formulario)%>
		<%=fb.hidden("recuperar",recuperar)%>
        <%if(recuperar.equals("")){%>
            <%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
        <%}%>
		<%=fb.hidden("__alergias__","")%>
		<%=fb.hidden("__riesgos__","")%>
		<%=fb.hidden("formularios","")%>
		<%=fb.hidden("xtraSections",xtraSections)%>
        
        <%if(onlyRiesgo.equals("")){%>
        <div class="headerform">
        <table cellspacing="0" class="table pull-right table-striped table-custom-1">
            <tr>
                <td>
                    <button type="button" class="btn btn-inverse btn-sm" onClick="__recuperar()"  <%=!viewMode && totPrevAdm > 0 ? "":" disabled"%>><b>Recuperar</b></button>
                    
                    <%if(!estado.trim().equalsIgnoreCase("F") && viewMode){%>
                        <button id="notas-cambio" type="button" class="btn btn-inverse btn-sm" onClick="saveNotasCambio()"><b>Notas de Cambio</b></button>
                    <%}%>
                    <%if(!modeSec.trim().equalsIgnoreCase("add")){%>
                      <button type="button" class="btn btn-inverse btn-sm" onClick="_reloadAccordions()"><i class="fa fa-refresh fa-printico"></i> <b>Recargar</b></button>
                    <%}%>
                    <button type="button" class="btn btn-inverse btn-sm" onClick="printExp()"><i class="material-icons fa-printico">print</i> <b>Imprimir</b></button>
                    
                    <button type="button" class="btn btn-inverse btn-sm" onClick="printExp(1)"><i class="material-icons fa-printico">print</i> <b>Resumido</b></button>
                    <authtype type="50">
                        <%if(viewMode && !estado.trim().equalsIgnoreCase("F")){%>
                        <button type="button" class="btn btn-inverse btn-sm" onClick="tempEdit()"><i class="fa fa-edit"></i> <b>Modificar</b></button>
                        <%}%>
                    </authtype>
                </td>
            </tr>
        </table>
        </div>
        
        <table cellspacing="0" class="table table-bordered">
        <tr>
			<td><cellbytelabel id="2">Fecha</cellbytelabel>&nbsp;</td>
			<td class="controls form-inline">
			<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equalsIgnoreCase("edit"))?"y":"n"%>"/>
				</jsp:include></td>
			<td><cellbytelabel id="3">Hora</cellbytelabel></td>
			<td class="controls form-inline">
			   <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equalsIgnoreCase("edit"))?"y":"n"%>"/>
				</jsp:include>
                
                <span class="pull-right">
                    <b><cellbytelabel>Fecha Recup</cellbytelabel>:</b>&nbsp;<%=cdo.getColValue("fecha_recup")%>
                </span>
			</td>
		</tr>
        </table>
        <%}%>
        
		<%if(fg.trim().equalsIgnoreCase("NEEU")){%>
		
        <table class="table table-small-font table-bordered">
        <%if(onlyRiesgo.equals("")){%>
        <tbody>
			  <tr>
				<td align="right" rowspan="3"><cellbytelabel id="4">Neurol&oacute;gico</cellbytelabel>:</td>
				<td align="right"><label for="neurologico0" class="pointer"><cellbytelabel id="5">Normal</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("neurologico0","A",(prop.getProperty("neurologico0").equalsIgnoreCase("A")),viewMode,null,null,"","")%></td>
				<td align="right"><label for="neurologico1" class="pointer"><cellbytelabel id="6">Let&aacute;rgico</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("neurologico1","L",(prop.getProperty("neurologico1").equalsIgnoreCase("L")),viewMode,null,null,"","")%></td>
				<td align="right"><label for="neurologico2" class="pointer"><cellbytelabel id="7">Confuso</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("neurologico2","C",(prop.getProperty("neurologico2").equalsIgnoreCase("C")),viewMode,null,null,"","")%></td>
				<td align="right"><label for="neurologico3" class="pointer"><cellbytelabel id="8">Inconsciente</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("neurologico3","I",(prop.getProperty("neurologico3").equalsIgnoreCase("I")),viewMode,null,null,"","")%></td>
			  </tr>
				
			  <tr>
				<td align="right"><label for="neurologico4" class="pointer"><cellbytelabel id="9">Desorientado</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("neurologico4","D",(prop.getProperty("neurologico4").equalsIgnoreCase("D")),viewMode,null,null,"","")%></td>
				<td align="right"><label for="neurologico5" class="pointer"><cellbytelabel id="10">Convulsiones</cellbytelabel></label></td>
				<td  align="center"><%=fb.checkbox("neurologico5","CO",(prop.getProperty("neurologico5").equalsIgnoreCase("CO")),viewMode,null,null,"","")%></td>
				<td align="right"><label for="neurologico6" class="pointer"><cellbytelabel id="11">Par&aacute;lisis</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("neurologico6","P",(prop.getProperty("neurologico6").equalsIgnoreCase("P")),viewMode,null,null,"","")%></td>
				<td align="right"><label for="neurologico7" class="pointer"><cellbytelabel id="12">Otros</cellbytelabel></label></td>
				<td align="center">         
                    <%=fb.checkbox("neurologico7","O",prop.getProperty("neurologico7")!=null&&prop.getProperty("neurologico7").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('neurologico',8,1,7)\"",""," data-index=1 data-message='Por favor indique los otros Neurológicos!'")%>
                </td>
			 </tr>
			 <tr>
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="7"><%=fb.textarea("otros1",prop.getProperty("otros1"),false,false,(viewMode==false&&prop.getProperty("neurologico7").equalsIgnoreCase("O")?false:true),75,1,2000,(viewMode==false&&prop.getProperty("neurologico7").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%></td>
			 </tr>
             </tbody>
			 <tbody>
			 <tr>
				<td rowspan="2" align="right"><cellbytelabel id="14">Cardiovascular</cellbytelabel>:</td>
				<td align="right"><label class="pointer" for="cardiovascular0"><cellbytelabel id="15">Normal</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("cardiovascular0","N",(prop.getProperty("cardiovascular0").equalsIgnoreCase("N")),viewMode,null,null,"","")%></td>
				<td align="right"><label class="pointer" for="cardiovascular1"><cellbytelabel id="16">Tarquicadia</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("cardiovascular1","T",(prop.getProperty("cardiovascular1").equalsIgnoreCase("T")),viewMode,null,null,"","")%></td>
				<td align="right"><label class="pointer" for="cardiovascular2"><cellbytelabel id="17">Bradicardia</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("cardiovascular2","B",(prop.getProperty("cardiovascular2").equalsIgnoreCase("B")),viewMode,null,null,"","")%></td>
				<td align="right"><label class="pointer" for="cardiovascular3"><cellbytelabel id="18">Palpitaci&oacute;n</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("cardiovascular3","P",(prop.getProperty("cardiovascular3").equalsIgnoreCase("P")),viewMode,null,null,"","")%></td>
		     </tr>
			 
			 <tr>
				<td align="right"><label class="pointer" for="cardiovascular4"><cellbytelabel id="19">Dolor en el Pecho</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("cardiovascular4","D",(prop.getProperty("cardiovascular4").equalsIgnoreCase("D")),viewMode,null,null,"","")%></td>
				<td align="right"><label class="pointer" for="cardiovascular5"><cellbytelabel id="20">Marcapaso</cellbytelabel></label></td>
				<td  align="center"><%=fb.checkbox("cardiovascular5","M",(prop.getProperty("cardiovascular5").equalsIgnoreCase("M")),viewMode,null,null,"","")%></td>
				<td align="right"><label class="pointer" for="cardiovascular6"><cellbytelabel id="12">Otros</cellbytelabel></label></td>
				<td  align="center">
                    <%=fb.checkbox("cardiovascular6","O",prop.getProperty("cardiovascular6")!=null&&prop.getProperty("cardiovascular6").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('cardiovascular',7,2,6)\"",""," data-index=2 data-message='Por favor indique los otros Cardiovasculares!'")%>
                </td>
				<td colspan="2"><%=fb.textarea("otros2",prop.getProperty("otros2"),false,false,(viewMode==false&&prop.getProperty("cardiovascular6").equalsIgnoreCase("O")?false:true),30,1,2000,(viewMode==false&&prop.getProperty("cardiovascular6").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%></td>
		     </tr>
             </tbody>
			 <tbody>
			 <tr>
				<td rowspan="2" align="right"><cellbytelabel id="21">Estado Respiratorio</cellbytelabel>:</td>
				<td align="right"><label class="pointer" for="respiracion0"><cellbytelabel id="15">Normal</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("respiracion0","N",(prop.getProperty("respiracion0").equalsIgnoreCase("N")),viewMode,null,null,"","")%></td>
				<td align="right"><label class="pointer" for="respiracion1"><cellbytelabel id="22">Tos</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("respiracion1","T",(prop.getProperty("respiracion1").equalsIgnoreCase("T")),viewMode,null,null,"","")%></td>
				<td align="right"><label class="pointer" for="respiracion2"><cellbytelabel id="23">Aleteo Nasal</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("respiracion2","A",(prop.getProperty("respiracion2").equalsIgnoreCase("A")),viewMode,null,null,"","")%></td>
				<td align="right"><label class="pointer" for="respiracion3"><cellbytelabel id="24">Disnea</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("respiracion3","D",(prop.getProperty("respiracion3").equalsIgnoreCase("D")),viewMode,null,null,"","")%></td>
		     </tr>
			 
			 <tr>
				<td align="right"><label class="pointer" for="respiracion4"><cellbytelabel id="25">Apnea</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("respiracion4","AP",(prop.getProperty("respiracion4").equalsIgnoreCase("AP")),viewMode,null,null,"","")%></td>
				<td align="right"><label class="pointer" for="respiracion5"><cellbytelabel id="12">Otros</cellbytelabel></label></td>
				<td align="center">
                
                <%=fb.checkbox("respiracion5","O",prop.getProperty("respiracion5")!=null&&prop.getProperty("respiracion5").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('respiracion',6,3,5)\"",""," data-index=3 data-message='Por favor indique los otros Estados Respiratorios!'")%>
                </td>
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="3"><%=fb.textarea("otros3",prop.getProperty("otros3"),false,false,(viewMode==false&&prop.getProperty("respiracion5").equalsIgnoreCase("O")?false:true),35,1,2000,(viewMode==false&&prop.getProperty("respiracion5").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%></td>
		     </tr>
			 </tbody>
             <tbody>
			 <tr>
			   <td align="right" rowspan="2"><cellbytelabel id="26">G.E.T Gastro-intestinal</cellbytelabel>:</td>
			   <td align="right">
                <label for="get4" class="pointer"><cellbytelabel id="15">Normal</cellbytelabel></label>
               </td>
			   <td align="center"><%=fb.checkbox("get4","NO",(prop.getProperty("get4").equalsIgnoreCase("NO")),viewMode,null,null,"","")%></td>
			   <td align="right"><label for="get1" class="pointer"><cellbytelabel id="28">V&oacute;mito</cellbytelabel></label></td>
			   <td align="center"><%=fb.checkbox("get1","V",(prop.getProperty("get1").equalsIgnoreCase("V")),viewMode,null,null,"","")%></td>
			   <td align="right"><label for="get2" class="pointer"><cellbytelabel id="29">&Uacute;lceras</cellbytelabel></label></td>
			   <td align="center"><%=fb.checkbox("get2","U",(prop.getProperty("get2").equalsIgnoreCase("U")),viewMode,null,null,"","")%></td>
			   <td align="right"><label for="get3" class="pointer"><cellbytelabel id="30">Dolor abdominal</cellbytelabel></label></td>
			   <td align="center"><%=fb.checkbox("get3","D",(prop.getProperty("get3").equalsIgnoreCase("D")),viewMode,null,null,"","")%></td>
	         </tr>
			 
			 <tr>
			   <td align="right"><label for="get0" class="pointer"><cellbytelabel id="27">N&aacute;usea</cellbytelabel></label></td>
			   <td align="center"><%=fb.checkbox("get0","N",(prop.getProperty("get0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
			   <td align="right"><label for="get5" class="pointer"><cellbytelabel id="12">Otros</cellbytelabel></label>:</td>
			   <td align="center">
                  <%=fb.checkbox("get5","O",prop.getProperty("get5")!=null&&prop.getProperty("get5").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('get',6,4,5)\"",""," data-index=4 data-message='Por favor indique los otros G.E.T Gastro-intestinales!'")%>
               </td>
			   <td  align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="3"><%=fb.textarea("otros4",prop.getProperty("otros4"),false,false,(viewMode==false&&prop.getProperty("get5").equalsIgnoreCase("O")?false:true),35,1,2000,(viewMode==false&&prop.getProperty("get5").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%></td>
	         </tr>
			 </tbody>
             <tbody>
			 <tr>
			   <td rowspan="3" align="right"><cellbytelabel id="31">M&uacute;sculo-Esqueletico</cellbytelabel>:</td>
			   <td align="right"><label for="esquel0" class="pointer"><cellbytelabel id="15">Normal</cellbytelabel></label></td>
               <td align="center"><%=fb.checkbox("esquel0","N",(prop.getProperty("esquel0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
			   <td  align="right"><label for="esquel1" class="pointer"><cellbytelabel id="32">Golpe</cellbytelabel></label></td>
               <td align="center"><%=fb.checkbox("esquel1","G",(prop.getProperty("esquel1").equalsIgnoreCase("G")),viewMode,null,null,"")%></td>
			   <td  align="right"><label for="esquel2" class="pointer"><cellbytelabel id="33">Trauma</cellbytelabel></label></td>
               <td align="center"><%=fb.checkbox("esquel2","T",(prop.getProperty("esquel2").equalsIgnoreCase("T")),viewMode,null,null,"")%></td>
			   <td align="right"><label for="esquel3" class="pointer"><cellbytelabel id="34">Adormecimiento en extremidades</cellbytelabel></label></td>
			   <td colspan="4"><%=fb.checkbox("esquel3","A",(prop.getProperty("esquel3").equalsIgnoreCase("A")),viewMode,null,null,"")%></td>
			   <tr> 
			   
			  <tr>
			    <td align="right"><label for="esquel4" class="pointer"><cellbytelabel id="35">Edemas en extremidades</cellbytelabel></label></td>
				<td  align="center"><%=fb.checkbox("esquel4","E",(prop.getProperty("esquel4").equalsIgnoreCase("E")),viewMode,null,null,"")%></td>
				<td align="right"><label for="esquel5" class="pointer"><cellbytelabel id="12">Otros</cellbytelabel></label></td>
				<td align="center">
                    <%=fb.checkbox("esquel5","O",prop.getProperty("esquel5")!=null&&prop.getProperty("esquel5").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('esquel',6,5,5)\"",""," data-index=5 data-message='Por favor indique los otros Músculo-Esqueleticos!'")%>
                </td>
				<td colspan="5"><%=fb.textarea("otros5",prop.getProperty("otros5"),false,false,(viewMode==false&&prop.getProperty("esquel5").equalsIgnoreCase("O")?false:true),50,1,2000,(viewMode==false&&prop.getProperty("esquel5").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%></td>
	         </tr>
             </tbody>
			 
             <tbody>
			 <tr>
				<td rowspan="4" align="right"><cellbytelabel id="36">Tegumentos (Piel</cellbytelabel>):</td>
				<td align="right">
                    <label for="piel11" class="pointer"><cellbytelabel id="15">Normal</cellbytelabel></label>
                </td>
				<td align="center">
                <%=fb.checkbox("piel11","N",(prop.getProperty("piel11").equalsIgnoreCase("N")),viewMode,null,null,"")%>
                </td>
				<td align="right"><label for="piel1" class="pointer"><cellbytelabel id="38">Moteado</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("piel1","M",(prop.getProperty("piel1").equalsIgnoreCase("M")),viewMode,null,null,"")%></td>
				<td align="right"><label for="piel2" class="pointer"><cellbytelabel id="39">Cianosis</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("piel2","C",(prop.getProperty("piel2").equalsIgnoreCase("C")),viewMode,null,null,"")%></td>
				<td align="right"><label for="piel3" class="pointer"><cellbytelabel id="40">Diaforesis</cellbytelabel></cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel3","D",(prop.getProperty("piel3").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
		     </tr>
			 
			 <tr>
				<td align="right"><label for="piel4" class="pointer"><cellbytelabel id="41">Herida</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("piel4","H",(prop.getProperty("piel4").equalsIgnoreCase("H")),viewMode,null,null,"")%></td>	    
				<td align="right"><label for="piel5" class="pointer"><cellbytelabel id="42">Hematoma</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("piel5","HE",(prop.getProperty("piel5").equalsIgnoreCase("HE")),viewMode,null,null,"")%></td>
				<td align="right"><label for="piel6" class="pointer"><cellbytelabel id="43">Ictericia</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("piel6","I",(prop.getProperty("piel6").equalsIgnoreCase("I")),viewMode,null,null,"")%></td>
				<td align="right"><label for="piel7" class="pointer"><cellbytelabel id="29">&Uacute;lceras</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("piel7","U",(prop.getProperty("piel7").equalsIgnoreCase("U")),viewMode,null,null,"")%></td>
		     </tr>
			 
			 <tr>
				<td align="right"><label for="piel8" class="pointer"><cellbytelabel id="44">Quemaduras</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("piel8","Q",(prop.getProperty("piel8").equalsIgnoreCase("Q")),viewMode,null,null,"")%></td>	    
				<td align="right"><label for="piel9" class="pointer"><cellbytelabel id="45">Eritema</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("piel9","ER",(prop.getProperty("piel9").equalsIgnoreCase("ER")),viewMode,null,null,"")%></td>
				<td align="right"><label for="piel10" class="pointer"><cellbytelabel id="46">Exantema</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("piel10","EX",(prop.getProperty("piel10").equalsIgnoreCase("EX")),viewMode,null,null,"")%></td>
				<td align="right"><label for="piel0" class="pointer"><cellbytelabel id="37">P&aacute;lido</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("piel0","P",(prop.getProperty("piel0").equalsIgnoreCase("P")),viewMode,null,null,"")%></td>
			 </tr>
				
			<tr>
				<td align="right"><label for="piel12" class="pointer"><cellbytelabel id="12">Otros</cellbytelabel></</label></td>
				<td align="center">                    
                    <%=fb.checkbox("piel12","O",prop.getProperty("piel12")!=null&&prop.getProperty("piel12").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('piel',13,6,12)\"",""," data-index=6 data-message='Por favor indique los otros Tegumentos!'")%>
                </td>
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="5"><%=fb.textarea("otros6",prop.getProperty("otros6"),false,false,(viewMode==false&&prop.getProperty("piel12").equalsIgnoreCase("O")?false:true),55,1,2000,(viewMode==false&&prop.getProperty("piel12").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%></td>
		     </tr>
             </tbody>
			 
             <tbody>
			 <tr>
				<td align="right" rowspan="2"><cellbytelabel id="47">Psicol&oacute;gico</cellbytelabel>:</td>
				<td align="right"><label for="psico0" class="pointer"><cellbytelabel id="48">Ansioso</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("psico0","A",(prop.getProperty("psico0").equalsIgnoreCase("A")),viewMode,null,null,"")%></td>
				<td align="right"><label for="psico1" class="pointer"><cellbytelabel id="49">Deprimido</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("psico1","D",(prop.getProperty("psico1").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
				<td align="right"><label for="psico2" class="pointer"><cellbytelabel id="50">Hostil</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("psico2","H",(prop.getProperty("psico2").equalsIgnoreCase("H")),viewMode,null,null,"")%></td>
				<td align="right"><label for="psico3" class="pointer"><cellbytelabel id="51">Agresivo</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("psico3","AG",(prop.getProperty("psico3").equalsIgnoreCase("AG")),viewMode,null,null,"")%></td>
		     </tr>
			 
			 <tr>
				<td align="right"><label for="psico4" class="pointer"><cellbytelabel id="15">Normal</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("psico4","N",(prop.getProperty("psico4").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
				<td align="right"><label for="psico5" class="pointer"><cellbytelabel id="12">Otros</cellbytelabel></label></td>
				<td align="center">
                    <%=fb.checkbox("psico5","O",prop.getProperty("psico5")!=null&&prop.getProperty("psico5").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('psico',6,7,5)\"",""," data-index=7 data-message='Por favor indique los otros Psicológicos!'")%>
                </td>
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel></td>
				<td colspan="3">
                    <%=fb.textarea("otros7",prop.getProperty("otros7"),false,false,(viewMode==false&&prop.getProperty("psico5").equalsIgnoreCase("O")?false:true),33,1,2000,(viewMode==false&&prop.getProperty("psico5").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%>
                </td>
		     </tr>
			 </tbody>
             <tbody>
			 <tr>
				<td rowspan="3" align="right"><cellbytelabel id="52">Alergias</cellbytelabel>:</td>
				<td align="right"><label for="alergia0" class="pointer">Niega</label></td>
				<td align="center"><%=fb.checkbox("alergia0","N",(prop.getProperty("alergia0").equalsIgnoreCase("N")),viewMode,"","","","")%></td>
				<td align="right"><label for="alergia1" class="pointer">Alimentos</label></td>
				<td align="center"><%=fb.checkbox("alergia1","A",(prop.getProperty("alergia1").equalsIgnoreCase("A")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),viewMode,"","","","")%></td>
				<td align="right"><label for="alergia2" class="pointer">AINES</label></td>
				<td align="center"><%=fb.checkbox("alergia2","AI",(prop.getProperty("alergia2").equalsIgnoreCase("AI")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),viewMode,"","","","")%></td>
				<td align="right"><label for="alergia3" class="pointer">Antibi&oacute;ticos</label></td>
				<td align="center"><%=fb.checkbox("alergia3","AT",(prop.getProperty("alergia3").equalsIgnoreCase("AT")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),viewMode,"","","","")%></td>
		     </tr>
			 
			 <tr>
				<td align="right"><label for="alergia4" class="pointer">Medicamentos</label></td>
				<td align="center"><%=fb.checkbox("alergia4","M",(prop.getProperty("alergia4").equalsIgnoreCase("M")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),viewMode,"","","","")%></td>	    
				<td align="right"><label for="alergia5" class="pointer">YODO</label></td>
				<td align="center"><%=fb.checkbox("alergia5","Y",(prop.getProperty("alergia5").equalsIgnoreCase("Y")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),viewMode,"","","","")%></td>
				<td align="right"><label for="alergia6" class="pointer">Sulfa</label></td>
				<td align="center"><%=fb.checkbox("alergia6","S",(prop.getProperty("alergia6").equalsIgnoreCase("S")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),viewMode,"","","","")%></td>
				<td align="right"><label for="alergia7" class="pointer">Otros</label></td>
				<td align="center">                    
                    <%=fb.checkbox("alergia7","O",prop.getProperty("alergia7")!=null&&prop.getProperty("alergia7").equals("O"),viewMode,"observacion",null,"",""," data-index=8 data-message='Por favor indique las otras Alergias!'")%>
                </td>
		     </tr>
			 
			 <tr>
				<td  align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="7"><%=fb.textarea("otros8",prop.getProperty("otros8"),false,false,viewMode||prop.getProperty("otros8").equals(""),53,1,2000,((viewMode==false&&prop.getProperty("alergia7").equalsIgnoreCase("O")&&!prop.getProperty("alergia0").equalsIgnoreCase("N"))?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%></td>
		    </tr>
			</tbody>
            <tbody>
			<tr>
				<td align="right" rowspan="4"><cellbytelabel id="60">Antecedentes Patol&oacute;gicos Personales</cellbytelabel>:</td>
				<td align="right"><label for="antpat0" class="pointer"><cellbytelabel id="61">Sin Antecedentes Patol&oacute;gicos</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("antpat0","N",(prop.getProperty("antpat0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
				<td align="right"><label for="antpat1" class="pointer"><cellbytelabel id="62">Hipertensi&oacute;n Arterial</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("antpat1","H",(prop.getProperty("antpat1").equalsIgnoreCase("H")),viewMode,null,null,"")%></td>
				<td align="right"><label for="antpat2" class="pointer"><cellbytelabel id="63">Diabetes</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("antpat2","D",(prop.getProperty("antpat2").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
				<td align="right"><label for="antpat3" class="pointer"><cellbytelabel id="64">Problemas Renales</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("antpat3","PR",(prop.getProperty("antpat3").equalsIgnoreCase("PR")),viewMode,null,null,"")%></td>
			</tr>
			
			<tr>	
				<td align="center"><label for="antpat4" class="pointer"><cellbytelabel id="12">Otros</cellbytelabel></label></td>
				<td align="center">                    
                    <%=fb.checkbox("antpat4","O",prop.getProperty("antpat4")!=null&&prop.getProperty("antpat4").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('antpat',5,9,4)\"",""," data-index=9 data-message='Por favor indique los otros Antecedentes Patológicos Personales!'")%>
                </td>
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="5"><%=fb.textarea("otros9",prop.getProperty("otros9"),false,false,(viewMode==false&&prop.getProperty("antpat4").equalsIgnoreCase("O")?false:true),57,1,2000,(viewMode==false&&prop.getProperty("antpat4").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%></td>
		   </tr>
       </tbody>
       
       <tbody>
			<tr>
				<td align="right" rowspan="4"><cellbytelabel id="60">Antecedentes Patol&oacute;gicos Familiares</cellbytelabel>:</td>
				<td align="right"><label for="antfam0" class="pointer"><cellbytelabel id="61">Sin Antecedentes Patol&oacute;gicos</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("antfam0","N",(prop.getProperty("antfam0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
				<td align="right"><label for="antfam1" class="pointer"><cellbytelabel id="62">Hipertensi&oacute;n Arterial</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("antfam1","H",(prop.getProperty("antfam1").equalsIgnoreCase("H")),viewMode,null,null,"")%></td>
				<td align="right"><label for="antfamt2" class="pointer"><cellbytelabel id="63">Diabetes</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("antfamt2","D",(prop.getProperty("antfamt2").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
				<td align="right"><label for="antfam3" class="pointer"><cellbytelabel id="64">Problemas Renales</cellbytelabel></label></td>
				<td align="center"><%=fb.checkbox("antfam3","PR",(prop.getProperty("antfam3").equalsIgnoreCase("PR")),viewMode,null,null,"")%></td>
			</tr>
			
			<tr>	
				<td align="center"><label for="antfam4" class="pointer"><cellbytelabel id="12">Otros</cellbytelabel></label></td>
				<td align="center">                    
                    <%=fb.checkbox("antfam4","O",prop.getProperty("antfam4")!=null&&prop.getProperty("antfam4").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('antfam',5,16,4)\"",""," data-index=16 data-message='Por favor indique los otros Antecedentes Patológicos Familiares!'")%>
                </td>
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="5"><%=fb.textarea("otros16",prop.getProperty("otros16"),false,false,(viewMode==false&&prop.getProperty("antfam4").equalsIgnoreCase("O")?false:true),57,1,2000,(viewMode==false&&prop.getProperty("antfam4").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%></td>
		   </tr>
       </tbody>
       
       <tbody>
       <tr>	
            <td align="right"><cellbytelabel id="12">Antecedentes de Hospitalización </cellbytelabel></td>
            <td align="right"><label for="anthosp1" class="pointer">SI</label></td>
            <td align="center"><%=fb.radio("anthosp","S",(prop.getProperty("anthosp").equalsIgnoreCase("S")),viewMode,false,null,null,null,null,null,"anthosp1")%></td>
            <td align="right"><label for="anthosp2" class="pointer">NO</label></td>
            <td align="center"><%=fb.radio("anthosp","N",(prop.getProperty("anthosp").equalsIgnoreCase("N")),viewMode,false,null,null,null,null,null,"anthosp2")%></td>
            
            <td align="right"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
            <td colspan="3"><%=fb.textarea("otros12",prop.getProperty("otros12"),false,false,viewMode,57,1,2000,"form-control input-sm","width:100%",null)%></td>
       </tr>
       </tbody>
       <tbody>
       <tr>	
            <td align="right"><cellbytelabel id="12">Antecedentes de Cirug&iacute;as Previas</cellbytelabel></td>
            <td align="right"><label for="antcir1" class="pointer">SI</label></td>
            <td align="center"><%=fb.radio("antcir","S",(prop.getProperty("antcir").equalsIgnoreCase("S")),viewMode,false,null,null,null,null,null,"antcir1")%></td>
            <td align="right"><label for="antcir2" class="pointer">NO</label></td>
            <td align="center"><%=fb.radio("antcir","N",(prop.getProperty("antcir").equalsIgnoreCase("N")),viewMode,false,null,null,null,null,null,"antcir2")%></td>
            
            <td align="right"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
            <td colspan="3"><%=fb.textarea("otros13",prop.getProperty("otros13"),false,false,viewMode,57,1,2000,"form-control input-sm","width:100%",null)%></td>
       </tr>
       </tbody>
       
       <tbody>
       <tr>	
            <td align="right" rowspan="2"><cellbytelabel id="12">Patr&oacute;n del Sue&ntilde;o</cellbytelabel></td>
            <td align="right"><label for="patron_suenio0" class="pointer">Normal</label></td>
            <td align="center"><%=fb.checkbox("patron_suenio0","N",(prop.getProperty("patron_suenio0").equalsIgnoreCase("N")),(viewMode),"","","","")%></td>
            <td align="right"><label for="patron_suenio1" class="pointer">Insomnio</label></td>
            <td align="center"><%=fb.checkbox("patron_suenio1","I",(prop.getProperty("patron_suenio1").equalsIgnoreCase("I")),(viewMode),"","","","")%></td>
            
            <td align="right" colspan="3"><label for="patron_suenio2" class="pointer"><cellbytelabel id="13">Sueño Interrumpido</cellbytelabel></label></td>
            <td align="center"><%=fb.checkbox("patron_suenio2","IN",(prop.getProperty("patron_suenio2").equalsIgnoreCase("IN")),(viewMode),"","","","")%></td>
       </tr>
       <tr>
         <td align="right"><label for="patron_suenio3" class="pointer"><cellbytelabel id="13">Requiere Ayuda</cellbytelabel></label></td>
         <td align="center">
            <%=fb.checkbox("patron_suenio3","RA",(prop.getProperty("patron_suenio3").equalsIgnoreCase("RA")),viewMode,"observacion",null,"onClick=\"ctrlOtros('patron_suenio',5,14,3)\"",""," data-index=14 data-message='Por favor indique las ayudas que necesita el paciente!'")%>
         </td>
         <td>Espec&iacute;fique:&nbsp;<%=fb.textarea("otros14",prop.getProperty("otros14"),false,false,(viewMode||prop.getProperty("otros14").equals("")),57,1,2000,"form-control input-sm","width:100%",null)%></td>
         <td align="right"><label for="patron_suenio4" class="pointer"><cellbytelabel id="13">Otros</cellbytelabel></label></td>
         <td align="center">            
            <%=fb.checkbox("patron_suenio4","O",prop.getProperty("patron_suenio4")!=null&&prop.getProperty("patron_suenio4").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('patron_suenio',5,15,4)\"",""," data-index=15 data-message='Por favor indique los otros Patrones de Sueños!'")%>
         </td>
         <td colspan="3"><%=fb.textarea("otros15",prop.getProperty("otros15"),false,false,(viewMode||prop.getProperty("otros15").equals("")),57,1,2000,"form-control input-sm","width:100%",null)%></td>
       </tr>
	   </tbody>
       
       <tbody>
       <tr>
			<td align="right" rowspan="2"><cellbytelabel id="66">Nutricional</cellbytelabel>:</td>
			<td align="right"><label for="nutricional0" class="pointer">Normal</label></td>
			<td align="center"><%=fb.checkbox("nutricional0","C",(prop.getProperty("nutricional0").equalsIgnoreCase("C")),viewMode,null,null,"")%></td>
			<td align="right" colspan="2"><label for="nutricional1" class="pointer"><cellbytelabel id="67">Nutrici&oacute;n enteral</cellbytelabel></label></td>
			<td  align="center"><%=fb.checkbox("nutricional1","T",(prop.getProperty("nutricional1").equalsIgnoreCase("T")),viewMode,null,null,"")%></td>
			<td align="right"><label for="nutricional2" class="pointer"><cellbytelabel id="68">Bajo peso</cellbytelabel></label></td>
			<td  align="center"><%=fb.checkbox("nutricional2","G",(prop.getProperty("nutricional2").equalsIgnoreCase("G")),viewMode,null,null,"")%></td>
		</tr>
		<tr>
            <td align="right"><label for="nutricional3" class="pointer"><cellbytelabel id="69">Sobre peso</cellbytelabel></label></td>
			<td  align="center"><%=fb.checkbox("nutricional3","CA",(prop.getProperty("nutricional3").equalsIgnoreCase("CA")),viewMode,null,null,"")%></td>
			<td align="center"><label for="nutricional4" class="pointer"><cellbytelabel id="12">Otros</cellbytelabel></label></td>
			<td align="center">                
                <%=fb.checkbox("nutricional4","O",(prop.getProperty("patron_suenio3").equalsIgnoreCase("O")),viewMode,"observacion",null,"onClick=\"ctrlOtros('nutricional',5,10,4)\"",""," data-index=10 data-message='Por favor indique los otros valores nutricionales!'")%>
            </td>
			<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
			<td colspan="4"><%=fb.textarea("otros10",prop.getProperty("otros10"),false,false,viewMode,57,1,2000,"form-control input-sm","width:100%",null)%></td>
	   </tr>
        </tbody>
       
       <tbody>
	   <tr>
		<td rowspan="3" align="right"><cellbytelabel id="70">Genito-Urinario</cellbytelabel></td>
		<td align="right"><label for="genito0" class="pointer"><cellbytelabel id="15">Normal</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("genito0","N",(prop.getProperty("genito0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
		<td align="right"><label for="genito1" class="pointer"><cellbytelabel id="71">Disuria</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("genito1","D",(prop.getProperty("genito1").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
		<td align="right"><label for="genito2" class="pointer"><cellbytelabel id="72">Oliguria</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("genito2","OL",(prop.getProperty("genito2").equalsIgnoreCase("OL")),viewMode,null,null,"")%></td>
		<td align="right"><label for="genito3" class="pointer"><cellbytelabel id="73">Poliuria</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("genito3","P",(prop.getProperty("genito3").equalsIgnoreCase("P")),viewMode,null,null,"")%></td>
	</tr>
	<tr>
		<td align="right"><label for="genito4" class="pointer"><cellbytelabel id="74">Hematuria</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("genito4","H",(prop.getProperty("genito4").equalsIgnoreCase("H")),viewMode,null,null,"")%></td>
		<td align="right"><label for="genito5" class="pointer"><cellbytelabel id="75">Incontinencia</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("genito5","I",(prop.getProperty("genito5").equalsIgnoreCase("I")),viewMode,null,null,"")%></td>
		<td align="right"><label for="genito6" class="pointer"><cellbytelabel id="76">Retenci&oacute;n Urinaria</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("genito6","RU",(prop.getProperty("genito6").equalsIgnoreCase("RU")),viewMode,null,null,"")%></td>
		<td align="right"><label for="genito7" class="pointer"><cellbytelabel id="77">Dolor</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("genito7","DO",(prop.getProperty("genito7").equalsIgnoreCase("DO")),viewMode,null,null,"")%></td>
	</tr>
	<tr>
		<td align="right"><label for="genito8" class="pointer"><cellbytelabel id="78">Otros</cellbytelabel></label></td>
		<td align="center">
            <%=fb.checkbox("genito8","O",prop.getProperty("genito8")!=null&&prop.getProperty("genito8").equals("O"),viewMode,"observacion",null,"onClick=\"ctrlOtros('genito',9,17,8)\"",""," data-index=17 data-message='Por favor indique los otros parámetros Genito-Urinarios!'")%>
        </td>
        <td align="center">Espec&iacute;cifique</td>
		<td colspan="5">
            <%=fb.textarea("otros17",prop.getProperty("otros17"),false,false,(viewMode==false&&prop.getProperty("genito8").equalsIgnoreCase("O")?false:true),57,1,2000,(viewMode==false&&prop.getProperty("genito8").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%>
        </td>
	</tr>
	</tbody>
    <tbody>
	<tr align="right">
		<td rowspan="2"><cellbytelabel id="79">Patr&oacute;n de Eliminaci&oacute;n</cellbytelabel></td>
		<td align="right"><label for="patron_eliminacion0" class="pointer"><cellbytelabel id="15">Normal</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("patron_eliminacion0","N",(prop.getProperty("patron_eliminacion0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
		<td align="right"><label for="patron_eliminacion1" class="pointer"><cellbytelabel id="80">Estre&ntilde;imiento</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("patron_eliminacion1","C",(prop.getProperty("patron_eliminacion1").equalsIgnoreCase("C")),viewMode,null,null,"")%></td>
		<td align="right"><label for="patron_eliminacion2" class="pointer"><cellbytelabel id="81">Diarrea</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("patron_eliminacion2","D",(prop.getProperty("patron_eliminacion2").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
		<td align="right"><label for="patron_eliminacion3" class="pointer"><cellbytelabel id="82">Melena</cellbytelabel></label></td>
		<td align="center"><%=fb.checkbox("patron_eliminacion3","m",(prop.getProperty("patron_eliminacion3").equalsIgnoreCase("m")),viewMode,null,null,"")%></td>
	</tr>
	<tr>	
		<td align="right"><label for="patron_eliminacion4" class="pointer"><cellbytelabel id="12">Otros</cellbytelabel></label></td>
		<td align="center">            
            <%=fb.checkbox("patron_eliminacion4","O",(prop.getProperty("patron_eliminacion4").equalsIgnoreCase("O")),viewMode,"observacion",null,"onClick=\"ctrlOtros('patron_eliminacion',5,11,4)\"",""," data-index=11 data-message='Por favor indique los otros patrones de eliminación!'")%>
        </td>
		<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
		<td colspan="5"><%=fb.textarea("otros11",prop.getProperty("otros11"),false,false,(viewMode==false&&prop.getProperty("patron_eliminacion4").equalsIgnoreCase("O")?false:true),57,1,2000,(viewMode==false&&prop.getProperty("patron_eliminacion4").equalsIgnoreCase("O")?"form-control input-sm FormDataObjectEnabled":"form-control input-sm FormDataObjectDisabled"),"width:100%",null)%></td>
	</tr>
	</tbody> 
    <tbody>
	<tr>
	   <td><cellbytelabel id="83">Inmunizaciones</cellbytelabel></td>
	   <td align="center"><label for="inmuni1" class="pointer"><cellbytelabel id="84">Completo</cellbytelabel></label></td>
       <td align="center">
       <%=fb.radio("inmuni","C",(prop.getProperty("inmuni").equalsIgnoreCase("C")),viewMode,false,null,null,null,null,null,"inmuni1")%>
       </td>
	   <td align="center"><label for="inmuni2" class="pointer"><cellbytelabel id="85">Incompleto</cellbytelabel></label></td>
       <td align="center">
        <%=fb.radio("inmuni","I",(prop.getProperty("inmuni").equalsIgnoreCase("I")),viewMode,false,null,null,null,null,null,"inmuni2")%>
      </td>
	   <td colspan="4">&nbsp;</td>
	</tr>
	</tbody>
    <tbody>
	<tr><td colspan="9">&nbsp;</td></tr>
	<tr class="TextHeader"><td colspan="9"><cellbytelabel id="86">Historial Transfusional</cellbytelabel></td></tr>
	<tr>
	   <td colspan="4"><cellbytelabel id="87">Transfusi&oacute;n de Componentes Sanguineos</cellbytelabel>:</td>
	   <td align="right"><cellbytelabel id="88">SI</cellbytelabel></td><td><%=fb.radio("transf","S",(prop.getProperty("transf").equalsIgnoreCase("S")),viewMode,false)%></td>
	   <td align="right"><cellbytelabel id="89">NO</cellbytelabel></td><td><%=fb.radio("transf","N",(prop.getProperty("transf").equalsIgnoreCase("N")),viewMode,false)%></td>
	   <td>&nbsp;</td>
    </tr>
    </tbody>
    <tbody>
	<tr>
	   <td colspan="4">Reacci&oacute;n Adversa</td>
	   <td align="right"><cellbytelabel id="88">SI</cellbytelabel></td><td><%=fb.radio("reac","S",(prop.getProperty("reac").equalsIgnoreCase("S")),viewMode,false)%></td>
	   <td align="right"><cellbytelabel id="89">NO</cellbytelabel></td><td><%=fb.radio("reac","N",(prop.getProperty("reac").equalsIgnoreCase("N")),viewMode,false)%></td>
	   <td>&nbsp;</td>
	</tr>
	</tbody>
    <tbody>
    
<%if (cdo.getColValue("sexo"," ").equalsIgnoreCase("F") ) {%>    
<tr class="TextHeader">
  <td colspan="3"><cellbytelabel id="90">Historia Obst&eacute;tric</cellbytelabel>a</td>
  <td colspan="6" align="center"><cellbytelabel id="91">Esta embarazada</cellbytelabel>?</td>
</tr>

<tr>
  <td rowspan="5">&nbsp;</td>
  <td align="center" colspan="4">
<cellbytelabel id="88">SI</cellbytelabel>&nbsp;&nbsp;<%=fb.radio("historiaobs","S",(prop.getProperty("historiaobs").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:getHistoriaobs()\"")%></td>
  <td align="center" colspan="4">
<cellbytelabel id="89">NO</cellbytelabel>&nbsp;&nbsp;<%=fb.radio("historiaobs","N",(prop.getProperty("historiaobs").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:getHistoriaobs()\"")%></td>	
</tr> 

<tr>
	   <td  align="right"><cellbytelabel id="92">Fecha de &Uacute;ltima Menstruaci&oacute;n</cellbytelabel>&nbsp;&nbsp;</td>
	   <td colspan="4"><%=fb.textarea("fum",prop.getProperty("fum"),false,false,true,25,1,60,"form-control input-sm FormDataObjectDisabled","width:100%",null)%></td> 
	   
		<td colspan="4" align="center" rowspan="4" class="controls form-inline">
		<cellbytelabel id="93">G</cellbytelabel>&nbsp;<%=fb.intBox("g",prop.getProperty("g"),false,false,true,1,1,"form-control input-sm","","")%>&nbsp;
		<cellbytelabel id="94">P</cellbytelabel>&nbsp;<%=fb.intBox("p",prop.getProperty("p"),false,false,true,1,1,"form-control input-sm ","","")%>&nbsp;
		<cellbytelabel id="95">C</cellbytelabel>&nbsp;<%=fb.intBox("c",prop.getProperty("c"),false,false,true,1,1,"form-control input-sm ","","")%>&nbsp;
		<cellbytelabel id="96">A</cellbytelabel>&nbsp;<%=fb.intBox("a",prop.getProperty("a"),false,false,true,1,1,"form-control input-sm ","","")%>
	   </td>
	</tr>
	
	<tr>
	   <td  align="right"><cellbytelabel id="97">Fecha Probable de Parto</cellbytelabel>&nbsp;&nbsp;</td>
	   <td colspan="4"><%=fb.textarea("fup",prop.getProperty("fup"),false,false,true,25,1,60,"form-control input-sm FormDataObjectDisabled","width:100%",null)%></td>
	</tr>
	 <tr>
	   <td  align="right"><cellbytelabel id="98">Control Prenatal</cellbytelabel></td>
	   <td align="right"><cellbytelabel id="88">SI</cellbytelabel>&nbsp;</td>
	   <td><%=fb.radio("ctrl","S",(prop.getProperty("ctrl").equalsIgnoreCase("S")),viewMode,false)%></td>
	   <td align="right"><cellbytelabel id="89">NO</cellbytelabel>&nbsp;</td>
	   <td><%=fb.radio("ctrl","N",(prop.getProperty("ctrl").equalsIgnoreCase("N")),viewMode,false)%></td>
	</tr>
	<tr>
	   <td  align="right"><cellbytelabel id="99">Ginec&oacute;logo</cellbytelabel>&nbsp;</td>
	   <td colspan="4"><%=fb.textarea("gin",prop.getProperty("gin"),false,false,true,25,2,60,"form-control input-sm","width:100%",null)%></td>
	</tr>
	</tbody>
    <%}%>
    
    <tbody>
	<tr>
		<td align="right" rowspan="3"><cellbytelabel id="100">&Aacute;rea Designada</cellbytelabel>:</td>
		<td align="right"><cellbytelabel id="101">Consultorio Adulto</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","CA",(prop.getProperty("area").equalsIgnoreCase("CA")),viewMode,false,null,null,"onclick='shouldTypeRadio(false,18)'")%></td>
		<td align="right"><cellbytelabel id="102">Consultorio Pediatria</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","CP",(prop.getProperty("area").equalsIgnoreCase("CP")),viewMode,false,null,null,"onclick='shouldTypeRadio(false,18)'")%></td>
		<td align="right"><cellbytelabel id="103">Observaci&oacute;n</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","OA",(prop.getProperty("area").equalsIgnoreCase("OA")),viewMode,false,null,null,"onclick='shouldTypeRadio(false,18)'")%></td>
		<td align="right"><cellbytelabel id="104">Hospitalizado</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","OP",(prop.getProperty("area").equalsIgnoreCase("OP")),viewMode,false,null,null,"onclick='shouldTypeRadio(false,18)'")%></td>
	</tr>
	
	<tr>
		<td align="right"><cellbytelabel id="105">Curaciones</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","C",(prop.getProperty("area").equalsIgnoreCase("C")),viewMode,false,null,null,"onclick='shouldTypeRadio(false,18)'")%></td>	    
		<td align="right"><cellbytelabel id="106">Ortopedia</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","OR",(prop.getProperty("area").equalsIgnoreCase("OR")),viewMode,false,null,null,"onclick='shouldTypeRadio(false,18)'")%></td>
		<td align="right"><cellbytelabel id="107">Ginecolog&iacute;a</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","G",(prop.getProperty("area").equalsIgnoreCase("G")),viewMode,false,null,null,"onclick='shouldTypeRadio(false,18)'")%></td>
		<td align="right"><cellbytelabel id="108">Reanimaci&oacute;n</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","R",(prop.getProperty("area").equalsIgnoreCase("R")),viewMode,false,null,null,"onclick='shouldTypeRadio(false,18)'")%></td>
	</tr>
    
    <tr>
        <td align="right"><cellbytelabel>Otros</cellbytelabel></td>
        <td align="center">
          <%=fb.radio("area","OT",(prop.getProperty("area").equalsIgnoreCase("OT")),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,18)'",""," data-index=18 data-message='Por favor indique las otras áreas designadas.'")%>  
        </td>
        <td colspan="6">
            <%=fb.textarea("otros18",prop.getProperty("otros18"),false,false,viewMode||prop.getProperty("otros18").equals(""),78,1,2000,"form-control input-s","width:100%",null)%>
        </td>
    </tr>
    
	</tbody>
    
    <%if (cdo.getColValue("sexo"," ").equalsIgnoreCase("F") ) {%>
    <tbody>
	<tr>
	   <td colspan="4"><cellbytelabel id="109">Esta usted lactando actualmente</cellbytelabel></td>
	   <td><cellbytelabel id="88">SI</cellbytelabel></td><td><%=fb.radio("lactancia","S",(prop.getProperty("lactancia").equalsIgnoreCase("S")),viewMode,false)%></td>
	   <td><cellbytelabel id="89">NO</cellbytelabel></td><td><%=fb.radio("lactancia","N",(prop.getProperty("lactancia").equalsIgnoreCase("N")),viewMode,false)%></td>
	   <td>&nbsp;</td>
	</tr>
	<tr><td colspan="9">&nbsp;</td>
	</tr>
	</tbody>
    <%}%>
    
    <tbody>
	<tr>
	   <td colspan="2"><cellbytelabel id="110">Historia Actual</cellbytelabel></td>
	   <td colspan="7">
	     <%=fb.textarea("historiaActual",prop.getProperty("historiaActual"),true,false,viewMode,78,2,2000,"form-control input-s","width:100%",null)%>
	  </td>
	</tr>
    </tbody>
    <%}%>
    
    <%
      Vector vFormularios = CmnMgr.str2vector(formulario);
      viewModRiesgo = viewMode;
      if (!estado.trim().equalsIgnoreCase("F") && onlyRiesgo.equals("1")) {
        viewModRiesgo = false;
      }
      
      int edad = Integer.parseInt(cdo.getColValue("edad","0"));
      int edadPed = Integer.parseInt(cdo.getColValue("edad_ped","0"));
      int edad3ra = Integer.parseInt(cdo.getColValue("edad_3ra","0"));
      String[] edadAdo = (cdo.getColValue("edad_ado","0")).split(",");
      int adoFrom = 0, adoTo = 0;
      try {
        adoFrom = Integer.parseInt(edadAdo[0]);
        adoTo = Integer.parseInt(edadAdo[1]);
      } catch(Exception e) {}

      //Hashtable iRiesgo = new Hashtable();
	  java.util.LinkedHashMap<String, String> iRiesgo = new java.util.LinkedHashMap<String, String>();
      iRiesgo.put("0","Paciente con Enfermedad Crónica");
      iRiesgo.put("1","Paciente de Cuidado Crítico");
      iRiesgo.put("2","Paciente cuyo sistema inmunológico se encuentra afectado (Inmunosuprimido)");
      iRiesgo.put("3","Embarazada (evaluación especifica de obstetricia, cribado)");
      iRiesgo.put("4","Pediátrico (evaluación especifica crecimiento y desarrollo, dolor, caída, cribado y Plan de cuidado)");
      iRiesgo.put("5","Adolescentes (evaluación especifica del adolescente)");
      iRiesgo.put("6","Adulto Mayor (75 años en adelante) (evaluación especifica Escala)");     
      iRiesgo.put("7","Discapacidad física(evaluación especifica Escala)");
      iRiesgo.put("8","Pacientes en fase terminal (evaluación especifica Escala)");
      iRiesgo.put("9","Pacientes con dolor intenso o crónico");
      iRiesgo.put("10","Paciente en quimioterapia o radioterapia");
      iRiesgo.put("11","Pacientes con enfermedades infecciosas o contagiosas");
      iRiesgo.put("12","Sospecha Pacientes con trastornos emocionales o psiquiátricos");
      iRiesgo.put("13","Pacientes con presunta dependencia de las drogas y/o alcohol");
      iRiesgo.put("14","Sospecha Victima de abuso y abandono");
      iRiesgo.put("16","Paciente con Perdida en el Embarazo");
      iRiesgo.put("15","Ninguno");
    %>
    <tbody>
	<tr id="eval_riesgo_vulnerabilidad">
        <th colspan="9" class="bg-headtabla2">Evaluación de Riesgo y/o Vulnerabilidad</th>
	</tr>
    
    <%
    boolean blockEmb = false, blockPed = false, blockAdo = false, block3ra = false; 
	for (java.util.Map.Entry<String, String> r : iRiesgo.entrySet()) { 
        
        if (onlyRiesgo.trim().equals("")) {
            blockEmb = r.getKey().equals("3") && cdo.getColValue("sexo").equalsIgnoreCase("M");
            blockPed = r.getKey().equals("4") && edad > edadPed;
            blockAdo = r.getKey().equals("5") && edad >= adoFrom && edad >= adoTo;
            block3ra = r.getKey().equals("6") && edad <= edad3ra;
        }
    %>
        <tr>
            <td colspan="9">
                <%=fb.checkbox("riesgo_vulnerabilidad"+r.getKey(),r.getKey(),(/*prop.getProperty("riesgo_vulnerabilidad"+r).equals(""+r)||*/CmnMgr.vectorContains(vFormularios,r.getKey())),viewModRiesgo,(blockEmb||blockPed||blockAdo||block3ra)?"cant-be-checked riesgo_vulnerabilidad":"riesgo_vulnerabilidad",null,"","")%>
                &nbsp;&nbsp;<label class="pointer" for="riesgo_vulnerabilidad<%=r.getKey()%>"><%=r.getValue()%></label> 
            </td>
        </tr>
    <%}%>
	</tbody>
    
    <%if(onlyRiesgo.equals("1") && !fp.trim().equals("kardex")){%>
    <tr>
        <td colspan="9" align="right">
          <button id="btn_riesgo" type="button" class="btn btn-inverse btn-sm" onClick="confirmarRiesgo()">Confirmar</button>
        </td>
	</tr>
    <%}%>
    
    
    
	</table>
    <%}%>
<%fb.appendJsValidation("if(error>0)doAction();");%>
<%if(onlyRiesgo.equals("")){%>
<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
    <td>
        <button type="button" class="btn btn-inverse btn-sm" onClick="doSubmit('<%=fb.getFormName()%>')" name="save" id="save"<%=viewMode?" disabled":""%>><i class="material-icons fa-printico">done</i> <b>Guardar</b></button>
    </td>
    </tr>
    </table> </div> 
    <%}%>
    
    <%=fb.hidden("saveOption","O")%>
<%=fb.formEnd(true)%>
 
 </div>
 </div>

</body>
</html>
<%
System.out.println("::::::::::::::::::::: TOP "+prop.getProperty("neurologico1"));
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	prop = new Properties();
        
    if (recuperar.equals("")){
		prop.setProperty("pac_id",request.getParameter("pacId"));
		prop.setProperty("admision",request.getParameter("noAdmision"));
		prop.setProperty("tipo_nota",request.getParameter("fg"));
		prop.setProperty("anthosp",request.getParameter("anthosp"));
		prop.setProperty("antcir",request.getParameter("antcir"));
	
		for ( int o = 0; o<25; o++ ){
			if ( request.getParameter("neurologico"+o) != null || request.getParameter("otros"+o) != null || request.getParameter("cardiovascular"+o) != null || request.getParameter("respiracion"+o) != null || request.getParameter("get"+o) != null || request.getParameter("esquel"+o) != null || request.getParameter("piel"+o) != null || request.getParameter("psico"+o) != null || request.getParameter("alergia"+o) != null || request.getParameter("antpat"+o) != null || request.getParameter("nutricional"+o) != null || request.getParameter("genito"+o) != null || request.getParameter("patron_eliminacion"+o) != null|| request.getParameter("patron_suenio"+o) != null){
			
			   prop.setProperty("neurologico"+o,request.getParameter("neurologico"+o));
			   prop.setProperty("cardiovascular"+o,request.getParameter("cardiovascular"+o));
			   prop.setProperty("respiracion"+o,request.getParameter("respiracion"+o));
			   prop.setProperty("get"+o,request.getParameter("get"+o));
			   prop.setProperty("esquel"+o,request.getParameter("esquel"+o));
			   prop.setProperty("piel"+o,request.getParameter("piel"+o));
			   prop.setProperty("psico"+o,request.getParameter("psico"+o));
			  
			   if((request.getParameter("alergia"+o) != null && !request.getParameter("alergia"+o).trim().equalsIgnoreCase("")))prop.setProperty("alergia"+o,request.getParameter("alergia"+o));
			   else if((request.getParameter("_alergia"+o+"Dsp") != null && !request.getParameter("_alergia"+o+"Dsp").trim().equalsIgnoreCase("")))prop.setProperty("alergia"+o,request.getParameter("_alergia"+o+"Dsp"));
			   
			   prop.setProperty("antpat"+o,request.getParameter("antpat"+o));
			   prop.setProperty("antfam"+o,request.getParameter("antfam"+o));
			   prop.setProperty("nutricional"+o,request.getParameter("nutricional"+o));
			   prop.setProperty("genito"+o,request.getParameter("genito"+o));
			   prop.setProperty("patron_eliminacion"+o,request.getParameter("patron_eliminacion"+o));
			   prop.setProperty("patron_suenio"+o,request.getParameter("patron_suenio"+o));
			   
			   prop.setProperty("otros"+o,request.getParameter("otros"+o));
			   
			   if(request.getParameter("riesgo_vulnerabilidad"+o) != null && request.getParameter("_riesgo_vulnerabilidad"+o+"Dsp") == null) prop.setProperty("riesgo_vulnerabilidad"+o,request.getParameter("riesgo_vulnerabilidad"+o));
			   //_riesgo_vulnerabilidad3Dsp _riesgo_vulnerabilidad3Dsp
			   System.out.println(":::::::::::::::::::::::::: RIESGO = "+prop.getProperty("riesgo_vulnerabilidad"+o));
			   
			}
		}
    
		// alergias alertas
		if(request.getParameter("__alergias__") != null && !request.getParameter("__alergias__").trim().equalsIgnoreCase("")) {
		  if (request.getParameter("otros8") != null && !request.getParameter("otros8").trim().equalsIgnoreCase("")){
			prop.setProperty("observacion_alergias",request.getParameter("__alergias__")+" *** "+request.getParameter("otros8"));
		  }
		  else {
			prop.setProperty("observacion_alergias", request.getParameter("__alergias__"));
		  } 
		} else {
			// prop.setProperty("observacion_alergias","");
		}
		
		// riesgos alertas
		if(request.getParameter("__riesgos__") != null && !request.getParameter("__riesgos__").trim().equalsIgnoreCase("")) {
			prop.setProperty("observ_alergias_riesgo", request.getParameter("__riesgos__"));
		} else {
			// prop.setProperty("observ_alergias_riesgo","");
		}

		prop.setProperty("area",request.getParameter("area"));
		prop.setProperty("historiaobs",request.getParameter("historiaobs"));
		prop.setProperty("fum",request.getParameter("fum"));
		prop.setProperty("fup",request.getParameter("fup"));
		prop.setProperty("ctrl",request.getParameter("ctrl"));
		prop.setProperty("gin",request.getParameter("gin"));
		prop.setProperty("g",request.getParameter("g"));
		prop.setProperty("p",request.getParameter("p"));
		prop.setProperty("c",request.getParameter("c"));
		prop.setProperty("a",request.getParameter("a"));
		prop.setProperty("genito",request.getParameter("genito"));
		prop.setProperty("lactancia",request.getParameter("lactancia"));
		prop.setProperty("inmuni",request.getParameter("inmuni"));
		prop.setProperty("transf",request.getParameter("transf"));
		prop.setProperty("reac",request.getParameter("reac"));
		
		prop.setProperty("fecha",request.getParameter("fecha"));
		prop.setProperty("hora",request.getParameter("hora"));
		
		prop.setProperty("historiaActual",request.getParameter("historiaActual"));
		prop.setProperty("riesgo_vulnerabilidad",request.getParameter("formularios"));
    }
    
	String errCode = "1";
	String errMsg = "";
	String errException = "";
	boolean doIt = true;
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	
	if (baction.equalsIgnoreCase("Guardar")) {
		if (request.getParameter("recuperar") != null && request.getParameter("recuperar").trim().equalsIgnoreCase("Y")) {
			ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"recuperar="+recuperar+"&modeSec="+modeSec+"&fp="+fp+"&fg="+fg+"&pacId="+pacId+"&noAdmision="+noAdmision+"&seccion="+seccion);
			
			NEEUMgr.recuperar(pacId,noAdmision,prevAdm, CmnMgr.str2vector(xtraSections), (String)session.getAttribute("_userName"));
			errCode = NEEUMgr.getErrCode();
			errMsg = NEEUMgr.getErrMsg();
			errException = NEEUMgr.getErrException();
		} else {
			ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"modeSec="+modeSec+"&fp="+fp+"&fg="+fg+"&pacId="+pacId+"&noAdmision="+noAdmision+"&seccion="+seccion);
			
			CommonDataObject param = new CommonDataObject();
			param.setTableName("tbl_sal_nota_eval_enf_urg");
			if (modeSec.equalsIgnoreCase("add")) {
				
				if ( CmnMgr.getCount("select count(*) from tbl_sal_nota_eval_enf_urg where pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and tipo_nota = upper('"+fg+"')") > 0 ) {
					SQLMgr.setErrCode("0");
					SQLMgr.setErrMsg("Ya existe un registro para esa admisión!");
					SQLMgr.setErrException("Ya existe un registro para esa admisión!");
					
					doIt = false;
				} else {
					param.setSql("insert into tbl_sal_nota_eval_enf_urg (pac_id, admision, tipo_nota, observacion_alergias, nota, formulario, usuario_creacion, fecha_creacion, usuario_modificacion, fecha_modificacion, observ_alergias_riesgo, id) values (?, ?, ?, ?, ?, ?, ?, sysdate, ?, sysdate, ?, (select nvl(max(id),0)+1 from tbl_sal_nota_eval_enf_urg) )");
					param.addInNumberStmtParam(1,request.getParameter("pacId")); 
					param.addInNumberStmtParam(2,request.getParameter("noAdmision")); 
					param.addInStringStmtParam(3,request.getParameter("fg")); 
					param.addInStringStmtParam(4,prop.getProperty("observacion_alergias"));
					param.addInBinaryStmtParam(5,prop);
					param.addInStringStmtParam(6,request.getParameter("formularios"));
					param.addInStringStmtParam(7,(String)session.getAttribute("_userName"));
					param.addInStringStmtParam(8,(String)session.getAttribute("_userName"));
					param.addInStringStmtParam(9,prop.getProperty("observ_alergias_riesgo"));
				}
			} else {
				param.setSql("update tbl_sal_nota_eval_enf_urg set nota = ?, observacion_alergias = ?, formulario = ?, usuario_modificacion = ?, fecha_modificacion = sysdate, observ_alergias_riesgo = ? where pac_id = ? and admision = ? and tipo_nota = ?");
				param.addInBinaryStmtParam(1,prop);
				param.addInStringStmtParam(2,prop.getProperty("observacion_alergias"));
				param.addInStringStmtParam(3,request.getParameter("formularios"));
				param.addInStringStmtParam(4,(String)session.getAttribute("_userName"));
				param.addInStringStmtParam(5,prop.getProperty("observ_alergias_riesgo"));
				param.addInNumberStmtParam(6,request.getParameter("pacId")); 
				param.addInNumberStmtParam(7,request.getParameter("noAdmision")); 
				param.addInStringStmtParam(8,request.getParameter("fg")); 
			}
			if(doIt) SQLMgr.executePrepared(param);
			errCode = SQLMgr.getErrCode();
			errMsg = SQLMgr.getErrMsg();
			errException = SQLMgr.getErrException();
		}
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (errCode.equalsIgnoreCase("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}

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
} else throw new Exception(errException);
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&only_riesgo=<%=onlyRiesgo%>&fp=<%=fp%>&estado=<%=estado%>&formulario=<%=formulario%>&xtraSections=<%=xtraSections%><%=request.getParameter("recuperar") != null && request.getParameter("recuperar").trim().equalsIgnoreCase("Y")?"&force_reload=Y":""%>';}
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
NEEUMgr.setConnection(null);
prop = null;
System.out.println(ConMgr);
%>