<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.Properties"%>
<%@ page import="issi.expediente.PlanCuidado"%>
<%@ page import="issi.expediente.PlanCuidadoDet"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="PCMgr" scope="page" class="issi.expediente.PlanCuidadoMgr" />
<jsp:useBean id="iDetTemp" scope="session" class="java.util.Hashtable" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
PCMgr.setConnection(ConMgr);

Properties prop = new Properties();
ArrayList al = new ArrayList();
ArrayList alDiags = new ArrayList();

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String condicion = request.getParameter("condicion");
String condTitle = request.getParameter("cond_title");
String cds = request.getParameter("cds");
String from = request.getParameter("from");
String diagnostico = request.getParameter("diagnostico");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String armarChecksTemp = request.getParameter("armar_checks_temp");
String plansTemp = request.getParameter("plans_temp");
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String userName = (String) session.getAttribute("_userName");

boolean displayDet = request.getParameter("armado_final") != null;

if (armarChecksTemp == null) armarChecksTemp = "";
if (plansTemp == null) plansTemp = "";
if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (fg == null) fg = "NDE";
if (fp == null) fp = "";
if (id == null) id = "0";
if (condicion == null) condicion = "";
if (condTitle == null) condTitle = "";
if (from == null) from = "";
if (diagnostico == null) diagnostico = "";

if (desc == null ) desc = "";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if(request.getParameter("armado") != null) {
    iDetTemp.clear();
}

boolean saved = !id.trim().equals("") && !id.trim().equals("0");
PlanCuidado plan = new PlanCuidado();

CommonDataObject cdo = new CommonDataObject();
boolean showContinue = false;
boolean ended = false;

// TODO:: remove
//userName = "vocampo";

if (request.getMethod().equalsIgnoreCase("GET")) 
{
    if (!id.trim().equals("") && !id.trim().equals("0")) {
        cdo = SQLMgr.getData("select id, regexp_replace(cod_condicion, '^,+|,+$|,+(,\\w)','\\1') cod_condicion, nvl(cod_diag,' ') as cod_diag, usuario_creacion, fecha_reevaluacion, fecha_resolucion from tbl_sal_plan_cuidado where pac_id = "+pacId+" and admision = "+noAdmision+" and id = "+id);
    } else {
        if(request.getParameter("force_agregar") == null) cdo = SQLMgr.getData("select id, regexp_replace(cod_condicion, '^,+|,+$|,+(,\\w)','\\1') cod_condicion, nvl(cod_diag,' ') as cod_diag, usuario_creacion, usuario_creacion, fecha_reevaluacion, fecha_resolucion from tbl_sal_plan_cuidado where pac_id = "+pacId+" and admision = "+noAdmision+" and id = (  select max(id) from tbl_sal_plan_cuidado where pac_id = "+pacId+" and admision = "+noAdmision+" )  ");
    }
    
    if (cdo == null) cdo = new CommonDataObject();
        
    if(!cdo.getColValue("id"," ").trim().equals("") && !cdo.getColValue("id"," ").trim().equals("0")  && !cdo.getColValue("cod_diag"," ").trim().equals("") ) {
        id = cdo.getColValue("id");
        saved = true;
        displayDet = true;
    }
    
    sbSql.append("select d.codigo, d.codigo_condicion, d.descripcion, c.descripcion as plann from tbl_sal_soapier_diagnosticos d, tbl_sal_soapier_condicion c where c.codigo = d.codigo_condicion");
    
    if (fp.trim().equalsIgnoreCase("buscar")){
        if (!condicion.trim().equals("")) {
            sbSql.append(" and d.codigo_condicion in( ");
						sbSql.append(condicion);
						sbSql.append(")");
        }
        
        if (!diagnostico.trim().equals("")) {
            sbSql.append(" and upper(d.descripcion) like upper('%");
						sbSql.append(diagnostico);
						sbSql.append("%')");
        }
				if (request.getParameter("diagnostico") == null && !armarChecksTemp.trim().equals("")) {
					sbSql.append(" and d.codigo in (");
					sbSql.append(armarChecksTemp);
					sbSql.append(")");  
				}
				
				sbSql.append(" and d.estado = 'A' ");
				
    } else {
        if (id.trim().equals("0")){
            if (!plansTemp.trim().equals("")) {
                condicion = plansTemp;
                sbSql.append(" and d.codigo_condicion in (");
								sbSql.append(plansTemp);
								sbSql.append(")");
            }
           
            if (!armarChecksTemp.trim().equals("")) {
							sbSql.append(" and d.codigo in (");
							sbSql.append(armarChecksTemp);
							sbSql.append(")");  
						}
						
						sbSql.append(" and d.estado = 'A' ");
						
        } else {
            sbSql.append(" and d.codigo_condicion in (");
						sbSql.append(cdo.getColValue("cod_condicion"));
						sbSql.append(")");
            if (cdo.getColValue("cod_diag") != null && !cdo.getColValue("cod_diag").trim().equals("")) {
							sbSql.append(" and d.codigo in (");
							sbSql.append(cdo.getColValue("cod_diag"));
							sbSql.append(")");
						} else sbSql = new StringBuffer();
             
            condicion = cdo.getColValue("cod_condicion");
            plansTemp = cdo.getColValue("cod_condicion");
            armarChecksTemp = cdo.getColValue("cod_diag");
        }       
    }

    if (sbSql.length() != 0) {
			sbSql.append(" order by 1");
			if ((!id.trim().equals("") && !id.trim().equals("0")) || fp.trim().equalsIgnoreCase("buscar") || request.getParameter("armado") != null || request.getParameter("armado_final") != null) alDiags = SQLMgr.getDataList(sbSql.toString());
		}
   
    al = SQLMgr.getDataList("select distinct a.id, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, to_char(a.fecha_reevaluacion, 'dd/mm/yyyy hh12:mi:ss am') fecha_reevaluacion, to_char(a.fecha_resolucion,'dd/mm/yyyy hh12:mi:ss am') fecha_resolucion, (select join( cursor(select descripcion from tbl_sal_soapier_diagnosticos where codigo in (select column_value  from table( select split((select cod_diag from tbl_sal_plan_cuidado where pac_id = "+pacId+" and admision = "+noAdmision+" and id = a.id),',') from dual )) "+(!id.equals("") && !id.equals("0") ? "" : " and estado = 'A' " )+"),'<br>') from dual) as diag, regexp_replace(a.cod_condicion, '^,+|,+$|,+(,\\w)','\\1') cod_condicion, a.cod_diag from tbl_sal_plan_cuidado a where a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by a.id desc");

    sbSql = new StringBuffer();
		sbSql.append("select distinct a.usuario_creacion usuarioCreacion, a.usuario_modificacion usuarioModificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion, to_char(a.fecha_reevaluacion,'dd/mm/yyyy hh12:mi:ss am') as fechaReval, to_char(a.fecha_resolucion,'dd/mm/yyyy hh12:mi:ss am') fechaResol from tbl_sal_plan_cuidado a where a.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and a.admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" and a.id = ");
		sbSql.append(id);
    
    plan = (PlanCuidado) sbb.getSingleRowBean(ConMgr.getConnection(), sbSql.toString(), PlanCuidado.class);
        
	if (plan == null){
		plan = new PlanCuidado();
        plan.setFechaCreacion(cDateTime);
	}
	else {
        
        if (!cdo.getColValue("fecha_reevaluacion"," ").trim().equals("") && !cdo.getColValue("fecha_resolucion"," ").trim().equals("")){
            modeSec = "view";
            viewMode = true;
            ended = true;
        } else modeSec = "edit";
    }
            
    if (fp.trim().equalsIgnoreCase("continuar")) {
        viewMode = false;
        modeSec = "add";
        showContinue = false;
    } else {
        
        if (cdo.getColValue("fecha_reevaluacion"," ").trim().equals("") || cdo.getColValue("fecha_resolucion"," ").trim().equals("")){
           viewMode = true;
           showContinue = true;
           
           if (cdo.getColValue("usuario_creacion"," ").trim().equals(userName)) {
                showContinue = false;
                viewMode = false;
            }
        } else {
            showContinue = false;
            viewMode = true;
        }        
    }
    
    if (request.getParameter("force_agregar") != null) viewMode = false;    
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
document.title = 'Plan de Cuidado - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}
function setEvaluacion(code, fReeval, fResol, condicion, diagnosticos){
  <%if(!showContinue){%>  
  /*var allIds = $("input[name*='all_ids']").map(function(){
    return parseInt(this.value);
  }).get();
  var maxCode = Math.max.apply(Math, allIds);
  var modeSec = "view";
  var mode = "<%=mode%>";
  if (!fResol && parseInt(code) === maxCode) {
    var modeSec = "edit";
    var mode = "edit";
  }
  window.location = '../expediente3.0/exp_plan_decuidado.jsp?modeSec='+modeSec+'&mode='+mode+'&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&condicion=<%=condicion%>&noAdmision=<%=noAdmision%>&from=<%=from%>&id='+code;*/
  <%}%>
  $("#printing_code").val(code);
  $("#printing_diags").val(diagnosticos);
  $("#printing_cond").val(condicion);
}
function add(){
    var totEval = $("input[type='checkbox'][name*='EVAL_INT_']").length;
    var totResol = $("input[type='checkbox'][name*='RESOL_INT_']").length;
    var totCheckedEval = $("input:checked[type='checkbox'][name*='EVAL_INT_']").length;
    var totCheckedResol = $("input:checked[type='checkbox'][name*='RESOL_INT_']").length;
    if (totEval == totCheckedEval && totResol == totCheckedResol && !$("#tmp_no_new_eval").val()){
        window.location = '../expediente3.0/exp_plan_decuidado.jsp?modeSec=add&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&condicion=<%=condicion%>&id=0&from=<%=from%>&force_agregar=Y';
    } else {
      $("#tmp_no_new_eval").val("Y");
      showError('No puede agregar un nuevo plan sin haber completado las reevaluaciones y resoluciones del último plan. Esto Cierra el plan activo!');
    }
    
}
function checkedFecha(){var x =0;var msg ='Seleccione ';if (eval('document.form0.fecha').value == ''){x++;msg +=' fecha '}if (eval('document.form0.hora').value == ''){x++;msg += ' , Hora';}if (x>0){ alert(msg);return false;}else return true;}

function showError(msg) {
 <%=from.trim().equalsIgnoreCase("salida_pop")?"parent.":""%>parent.CBMSG.error(msg);
}

function canSubmit() {
  var proceed = true;
  <%if(!saved){%>
  if ($(".observacion").length < 1) {
    proceed = false;
    showError('No hay nada seleccionado!');
    return false;
  }
  <%}%>
  $(".observacion, .observacion_ejec").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var diag = $self.data('diag');
    var message = $self.data('message');
    var texta = $self.hasClass("observacion_ejec") ? $("#observacion_ejec"+i) : $("#observacion"+i+diag) ;
    
    if ( $self.is(":checked") && !$.trim(texta.val()) ) {
      showError(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
      proceed = false;
      $self.focus();
      return false;  
    }else  {proceed = true;}
  });
  
  var params = ['MOT', 'MET', 'NEC', 'INT'];
  $("input[class*='has_params_']").not('input.has_params_TTT').not('input.has_params_RRR').each(function(){
    var self = $(this);
    var val = parseInt(self.val());
    var tipo = self.data('tipo-desc');
    var diag = self.data('diag-desc');
    if (val < 1) {
      showError('Por favor agregar "'+tipo+'" para el diagnóstico: "'+diag+'"');
      proceed = false;
      return false;
    }
  });
  
  //setting fecha eval/ resol
  setFechaEvalFechaResolv();
 
  return proceed;
}

function setFechaEvalFechaResolv() {
    var totFechaEval = $("input.no_fecha_eval").length;
    var totFechaResol = $("input.no_fecha_resol").length;
    var totCheckedFechaEval = $("input.no_fecha_eval:checked").length;
    var totCheckedFechaResol = $("input.no_fecha_resol:checked").length;
    if (totFechaEval){
        if (totFechaEval == totCheckedFechaEval){
            $("#real_fecha_eval").val("Y");
        }
    } else {
        if (totFechaResol && totFechaResol == totCheckedFechaResol){
            $("#real_fecha_resol").val("Y");
            $("#should_be_closed").val("Y");
        }
    }
}

$(function(){
    $('[data-toggle="tooltip"]').tooltip();
    
    $(".otras_evaluaciones").click(function(e){
        var that = $(this);
        var i = that.data('index');
        var obs = $("#obs_otras_evaluaciones"+i);
        if (!that.is(":checked")) {
         obs.prop("readOnly", true).val("");
        } else  {
          obs.prop("readOnly", false)
        }
    });
    
    $(".observacion, .observacion_ejec").click(function(e){
        var that = $(this);
        var i = that.data('index');
        var diag = that.data('diag');
        var obs = that.hasClass("observacion_ejec") ? $("#observacion_ejec"+i) : $("#observacion"+i+diag)
        if (!that.is(":checked")) {
         obs.prop("readOnly", true).val("");
        } else  {
          obs.prop("readOnly", false)
        }
    });
    
    //Set title
    <%if(!condTitle.trim().equals("")){%>
    $("#ExpSectionTitle", parent.<%=from.trim().equalsIgnoreCase("salida_pop")?"parent.":""%>document).text("PLAN - <%=condTitle%>");
    <%}%>
    
    // toggle details
    $(".header_diag").click(function(){
      var self = $(this);
      var idDiag = self.data('header-diag');
      $("#det_diag"+idDiag).toggle();
    });
    
    // show work in progress
    <%if(request.getParameter("armado_final") == null){%>
    var params = ['MET','NEC','MOT', 'INT'];
    $(".header_diag").each(function(){
      var self = $(this);
      var diag = self.data('header-diag');
      // || $(params[i]+"_"+diag+"_OT:checked").length
      for (var i = 0; i<params.length; i++) {
        if ($("input:checked[name*='"+params[i]+"_"+diag+"_']").length) $("#diag-header"+diag).css({color:'red'});
      }
    });
    <%}%>
    
    <%if(request.getParameter("armar_checks_temp") != null && !request.getParameter("armar_checks_temp").trim().equals("")){%>
      var armarChecksTemp = "<%=request.getParameter("armar_checks_temp")%>".split(",");
      var plansTemp = "<%=request.getParameter("plans_temp")%>".split(",");
    <%}%>
    
    $(".armar").click(function(){
        var self = $(this);
        var tipo = self.data('tipo');
        var codDiag = self.data('cod-dia');
        var rearmar = self.data('rearmar');
        
        if ( tipo != 'TTT' && tipo != 'RRR') {
            abrir_ventana('../expediente3.0/exp_soapier_params.jsp?modeSec=&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&condicion=<%=condicion%>&noAdmision=<%=noAdmision%>&id=0&fp=&from=<%=from%>&armar_checks_temp=<%=armarChecksTemp%>&plans_temp=<%=plansTemp%>&armado=Y&force_agregar=Y&tipo='+tipo+'&cod_diag='+codDiag+(rearmar&&rearmar=='1'?"&rearmar=Y":""));
        }
    });
    
    $(".cant-change").click(function(e){
        e.preventDefault();
        return false;
    });
    
    <%if(showContinue){%>
    $("input[type='checkbox'][name*='EVAL_INT_']").click(function(){
        var self = $(this);
        if (this.checked) {
            self.addClass("no_fecha_eval");
        } else {
            self.removeClass("no_fecha_eval");
        }
    });
    <%}%>
    
    <%if(request.getParameter("pre_armado")!=null){%>
        alert('“Diagnóstico seleccionado,ha sido armado satisfactoriamente, recuerde Guardar Diagnósticos”');
    <%}%>
    
    //otras intervenciones
    $(".otras_int").click(function(){
        var self = $(this);
        var diag = self.data('cod-dia');
        
        abrir_ventana1('../expediente3.0/exp_otras_intervenciones_soapier_list.jsp?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&fg=<%=fg%>&desc=<%=desc%>&condicion=<%=condicion%>&id=<%=id%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&armar_checks_temp=<%=armarChecksTemp%>&plans_temp=<%=plansTemp%>&from=<%=from%>&diag='+diag);
    });
    
    // otras reevaluaciones
    $(".btn_add_otras_reeval").click(function(){
        var self = $(this);
        var diag = self.data('cod-dia');
        var $tmpl = $("#container-otras-reval-"+diag);
        
        var data = "<tr><td colspan='2'>";
        data += "<textarea class='form-control input-sm mas-reeval-content-"+diag+"'></textarea>";
        data += "</td></tr>";
               
        $tmpl.after(data);
        
        $("#btn-save-container-otras-reval-"+diag).show(0);
        $('*[data-diag="'+diag+'"]').prop("disabled", false);
    });
    
    $(".save-mas-reeval").click(function(){
        var self = $(this);
        var diag = self.data('diag');
        self.prop("disabled", true);
        var totExe = 0, totError = 0;
        $(".mas-reeval-content-"+diag).not(".saved").each(function(){
            var self = $(this);
            if ($.trim(this.value)) {
				var exe = false;
                var exe = executeDB('<%=request.getContextPath()%>',"insert into tbl_sal_otras_reeval (codigo, pac_id, admision, cod_plan, cod_diag, fecha_creacion, usuario_creacion, reevaluacion) values ((select nvl(max(codigo), 0) + 1 from tbl_sal_otras_reeval where pac_id = <%=pacId%> and admision = <%=noAdmision%>), <%=pacId%>, <%=noAdmision%>, <%=id%>, "+diag+", sysdate, '<%=(String)session.getAttribute("_userName")%>', '"+this.value+"')");
                
                if (exe) {
                    self.prop("readOnly", true).addClass("saved");
                    totExe++;
                }
                else totError++;
            }
        });
        
        if (totExe > 0 && !totError) {
            parent.CBMSG.alert('Reevaluaciones han sido guardados satisfactoriamente.');
        }
        
        if (totError > 0 && !totExe) {
            parent.CBMSG.error('Error al guardar las reevaluaciones.');
        }
    });
        
});

function continuar(){
  var allIds = $("input[name*='all_ids']").map(function(){
    return parseInt(this.value);
  }).get();
  var code = Math.max.apply(Math, allIds);
  if (code) {
    window.location = '../expediente3.0/exp_plan_decuidado.jsp?modeSec=view&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&condicion=<%=condicion%>&noAdmision=<%=noAdmision%>&id='+code+'&fp=continuar&from=<%=from%>&armar_checks_temp=<%=armarChecksTemp%>&plans_temp=<%=plansTemp%>';
  }
}

function imprimir(n){
    var code = $("#printing_code").val() || '<%=id%>';
    var diags = $("#printing_diags").val() || '<%=armarChecksTemp%>';
    var cond = $("#printing_cond").val() || '<%=condicion%>';
	var url='../expediente3.0/print_plan_de_cuidado.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&cond_title=<%=condTitle%>';
	
    if(n==1) url +=' (TODOS)&condicion='+cond+'&diags='+diags+'&code='+code;
    abrir_ventana(url);
}
function imprimirHistorial(){abrir_ventana('../expediente3.0/print_plan_de_cuidado_res.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%> (HISTORIAL)&cond_title=<%=condTitle%>');}

function buscar() {
  var plan = $("#plan").val();
  var diagnostico = $.trim($("#diagnostico").val());
  
  window.location = '../expediente3.0/exp_plan_decuidado.jsp?modeSec=view&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&condicion='+plan+'&noAdmision=<%=noAdmision%>&id=0&fp=buscar&from=<%=from%>&diagnostico='+diagnostico+'&armar_checks_temp=<%=armarChecksTemp%>&plans_temp=<%=plansTemp%>&force_agregar=Y';
}

function armar(opt) {
  if (!opt){
      var armarCheck = [];
      var plans = [];
      $("input:checked[name*='armar_check_']").each(function(){
        var self = $(this);
        plans.push(self.data('plan'));
        armarCheck.push(self.val());
      });
            
      <%if(!armarChecksTemp.trim().equals("")){%>
      armarCheck = armarCheck.concat("<%=armarChecksTemp%>".split(","));
      <%}%>
      <%if(!plansTemp.trim().equals("")){%>
      plans = plans.concat("<%=plansTemp%>".split(",")); 
      <%}%>
      console.log(armarCheck, plans);            
      if (armarCheck.length > 0) {
        window.location = '../expediente3.0/exp_plan_decuidado.jsp?modeSec=&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&condicion='+plans.join()+'&noAdmision=<%=noAdmision%>&id=0&fp=buscar&from=<%=from%>&plans_temp='+plans.join()+"&armar_checks_temp="+armarCheck.join()+'&force_agregar=Y&pre_armado=Y';
      }
      
  } else {
    window.location = '../expediente3.0/exp_plan_decuidado.jsp?modeSec=&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&condicion=&noAdmision=<%=noAdmision%>&id=0&fp=&from=<%=from%>&armar_checks_temp=<%=armarChecksTemp%>&plans_temp=<%=plansTemp%>&armado=Y&force_agregar=Y';
  }
}
function verHistorial() {
  $("#hist_container").toggle();
}

function agregarDiag() {
    abrir_ventana1('../expediente3.0/exp_mas_diag_decuidado.jsp?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&fg=<%=fg%>&desc=<%=desc%>&condicion=<%=condicion%>&id=<%=id%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&armar_checks_temp=<%=armarChecksTemp%>&plans_temp=<%=plansTemp%>&from=<%=from%>');
}

function removeOI(codigo, diag) {
    var exe = executeDB('<%=request.getContextPath()%>',"delete from tbl_sal_otras_interv where codigo = "+codigo+" and cod_diag = "+diag+" and pac_id = <%=pacId%> and admision = <%=noAdmision%>");
    
    if (exe) {
        $("#oi-"+diag+"-"+codigo).remove();
    } else {
        parent.CBMSG.error("La otra inverveción no se ha podigo eliminar.");
    }
}

function removeOR(codigo, diag) {
    var exe = executeDB('<%=request.getContextPath()%>',"delete from tbl_sal_otras_reeval where codigo = "+codigo+" and cod_diag = "+diag+" and pac_id = <%=pacId%> and admision = <%=noAdmision%>");
    
    if (exe) {
        $("#or-"+diag+"-"+codigo).remove();
    } else {
        parent.CBMSG.error("La otra reevaluación no se ha podigo eliminar.");
    }
}
</script>
<style>
.tooltip-inner {
    min-width: 100px;
    max-width: 100%; 
}
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
<%=fb.hidden("id",id)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("condicion",condicion)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("cond_title", condTitle)%>
<%=fb.hidden("fp", fp)%>
<%=fb.hidden("armar_checks_temp", armarChecksTemp)%>
<%=fb.hidden("plans_temp", plansTemp)%>
<%=fb.hidden("tmp_no_new_eval", "")%>
<%=fb.hidden("real_fecha_eval", "")%>
<%=fb.hidden("real_fecha_resol", "")%>
<%=fb.hidden("should_be_closed", "")%>
<%=fb.hidden("printing_code", "")%>
<%=fb.hidden("printing_diags", "")%>
<%=fb.hidden("printing_cond", "")%>

<div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-2">
    <%//if (condicion.trim().equals("")){%>
        <!--<tr align="left" class="tbg-error"><td><b>*** El Paciente no tiene una condición registrada!</b></td></tr> -->
    <%//}%>
    <tr>
        <td align="right">
        <%if(!mode.trim().equalsIgnoreCase("view")){%>
            <%if(saved && showContinue){%>
                <button type="button" class="btn btn-inverse btn-sm" onclick="continuar()">
                    <i class="fa fa-arrow-circle-right fa-printico"></i> <b>Continuar</b>
                </button>
            <%}%>
            <%if(!showContinue){%>
            <%if(!ended){%>
                <button type="button" class="btn btn-inverse btn-sm" onclick="agregarDiag()">
                    <i class="fa fa-plus fa-printico"></i> <b>Diagn&oacute;sticos</b>
                </button>
            <%}%>
            <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
                <i class="fa fa-plus fa-printico"></i> <b>Agregar Plan</b>
            </button>
            <%}%>
        <%}%>
        
        <%if(!id.trim().equals("") && !id.trim().equals("0")){%>
            &nbsp;
            <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir(1)"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
        <%}%>
        
        <%if(al.size() > 0){%>
          <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir(0)"><i class="fa fa-print fa-printico"></i> <b>Todos</b></button>
          <button type="button" class="btn btn-inverse btn-sm" onclick="imprimirHistorial()"><i class="fa fa-print fa-printico"></i> <b>Historial</b></button>
          <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
            <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
          </button>
        <%}%>
        
    </tr>
    </table>
    
    <div class="table-wrapper" id="hist_container" style="display:none">
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
        <thead>
            <tr class="bg-headtabla2">
            <th style="vertical-align: middle !important;">C&oacute;digo</th>
            <th style="vertical-align: middle !important;">Fecha Inicio</th>
            <th style="vertical-align: middle !important;">Usuario</th>
            <th style="vertical-align: middle !important;">Fecha Reevaluaci&oacute;n</th>
            <th style="vertical-align: middle !important;">Fecha Resoluci&oacute;n</th>
        </thead>
        <tbody>
        <%for (int i=1; i<=al.size(); i++){
            CommonDataObject cdo1 = (CommonDataObject) al.get(i-1);
        %>
		<%=fb.hidden("id"+i,cdo1.getColValue("id"))%>
		<tr onClick="javascript:setEvaluacion(<%=cdo1.getColValue("id")%>,'<%=cdo1.getColValue("fecha_reevaluacion")%>','<%=cdo1.getColValue("fecha_resolucion")%>','<%=cdo1.getColValue("cod_condicion")%>','<%=cdo1.getColValue("cod_diag")%>')" class="pointer" data-toggle="tooltip" data-html="true" data-placement="bottom" title="<%=cdo1.getColValue("diag")%>" >
            <td><%=cdo1.getColValue("id")%></td>
            <td><%=cdo1.getColValue("fecha_creacion")%></td>
            <td><%=cdo1.getColValue("usuario_creacion")%>/<%=cdo1.getColValue("usuario_modificacion")%></td>
            <td><%=cdo1.getColValue("fecha_reevaluacion")%></td>
            <td><%=cdo1.getColValue("fecha_resolucion")%></td>
		</tr>
        <input type="hidden" name="all_ids<%=i%>" id="all_ids<%=i%>" value="<%=cdo1.getColValue("id")%>">
        <%}%>
        </tbody>
        </table>
    </div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered">
     <tbody>
     <tr>
        <th colspan="2" class="bg-headtabla">PLAN</th>
     </tr>
    </tbody>
    
    <tbody>
    <tr>
        <td class="controls form-inline">
        <cellbytelabel id="4">Fecha</cellbytelabel>&nbsp;
        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1"/>
            <jsp:param name="format" value="dd/mm/yyyy"/>
            <jsp:param name="nameOfTBox1" value="fecha" />
            <jsp:param name="valueOfTBox1" value="<%=plan.getFechaCreacion().substring(0,10)%>" />
            <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
            </jsp:include>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <cellbytelabel id="5">Hora</cellbytelabel>
       
        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1"/>
            <jsp:param name="format" value="hh12:mi:ss am"/>
            <jsp:param name="nameOfTBox1" value="<%="hora"%>" />
            <jsp:param name="valueOfTBox1" value="<%=plan.getFechaCreacion().substring(11)%>" />
            <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
            </jsp:include>
            <%if(request.getParameter("armado") == null && request.getParameter("rearmar") == null && !saved){%>
            <span class="pull-right">Plan:
            <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_sal_soapier_condicion where estatus = 'A'","plan","",false,false,0,"",null,"",null,"S")%>
            Diagn&oacute;stico:
            <%=fb.textBox("diagnostico","",false,false,false,0,"form-control input-sm",null,null)%>
            <button type="button" class="btn btn-inverse btn-sm" onclick="buscar()">IR</button>
            <%}%>
            
            </span>
            </td>
    </tr>
    </tbody>
    
        <%          
          Vector vChecks = CmnMgr.str2vector(request.getParameter("armar_checks_temp")!=null?request.getParameter("armar_checks_temp"):"");  
          int realSize = 0;
          
          if (saved && fp.trim().equals("continuar")){
            iDetTemp.clear();
          }
          
          for (int diag = 0; diag<alDiags.size(); diag++) {
            CommonDataObject cdoDiag = (CommonDataObject) alDiags.get(diag);
        %>
        <tr id="header-diag-<%=cdoDiag.getColValue("codigo")%>" class="pointer<%=!fp.trim().equalsIgnoreCase("buscar")?" header_diag":""%>" data-header-diag="<%=cdoDiag.getColValue("codigo")%>">
          <td colspan="2">
            <span id="diag-header<%=cdoDiag.getColValue("codigo")%>">
                <%if(fp.trim().equalsIgnoreCase("buscar")){
                String value = cdoDiag.getColValue("codigo");
                %>
                <%=fb.checkbox("armar_check_"+diag,value,CmnMgr.vectorContains(vChecks,value),false,null,null,"",cdoDiag.getColValue("codigo")," data-plan="+cdoDiag.getColValue("codigo_condicion")+" data-check="+cdoDiag.getColValue("codigo"))%>
                <%}%>
                <%=cdoDiag.getColValue("descripcion")%>&nbsp;<b>(<%=cdoDiag.getColValue("plann")%>)</b>
            </span>
          </td>
        </tr>
        
        <!-- det -->
        <tr style="<%=!displayDet?"display:none":""%>" class = "det_diag" id="det_diag<%=cdoDiag.getColValue("codigo")%>">
        <td colspan="2">
        <table class="table table-small-font table-bordered">
        <tr>
        <%
        if (condicion.trim().equals("")) condicion = plansTemp;
        if (plansTemp.trim().equals("")) condicion = "0";
        
        if (!id.trim().equals("") && !id.trim().equals("0")) {
            condicion = cdo.getColValue("cod_condicion");
        }
        
        ArrayList alD = new ArrayList();
        
        if(request.getParameter("armado") != null || request.getParameter("armado_final") != null || (!id.equals("")||!id.equals("0"))) {
          String sqlD = "select distinct orden, decode(tipo,'MET','META MEDIBLE','NEC','NECESIDADES ALTERADAS','INT', 'INTERVENCIONES','MOT','MOTIVOS / CAUSAS') tipo_desc, tipo from tbl_sal_soapier_cond_detalle where codigo_condicion in("+condicion+") and cod_diag = "+cdoDiag.getColValue("codigo");
          
          if (id.trim().equals("") || id.trim().equals("0")) {
            sqlD += " and status = 'A' ";
          }
          
          sqlD += " union select 100, 'REEVALUACIÓN ','TTT' from dual union select 100, 'RESOLUCION ','RRR' from dual order by  1 ";
          
          alD = SQLMgr.getDataList(sqlD);
        }
        
        for (int h = 0; h<alD.size(); h++) {
            CommonDataObject cdo1 = (CommonDataObject) alD.get(h);%>

              <td style="vertical-align:top !important"><!-- detalle -->
                 <table cellspacing="0" class="table table-bordered">
                   <td> 
                       <% 
                        String sqlDet = "";
                        
                        if (!id.trim().equals("") && !id.trim().equals("0")) {
                         sqlDet = "select a.codigo, a.descripcion, a.status, a.codigo_condicion, a.cod_diag, a.tipo, b.observ_otro, b.observ_reeval, b.observ_resol, to_char(c.fecha_reevaluacion,'dd/mm/yyyy hh12:mi:ss am') fecha_reeval, to_char(c.fecha_resolucion,'dd/mm/yyyy hh12:mi:ss am') fecha_resol , (select join( cursor ( select distinct cod_param from tbl_sal_plan_cuidado_det aa where aa.cod_diag = b.cod_diag and aa.tipo = b.tipo and pac_id = b.pac_id and admision = b.admision and cod_plan = b.cod_plan  )  , ',') from dual) as tmp_diag from tbl_sal_soapier_cond_detalle a, tbl_sal_plan_cuidado_det b, tbl_sal_plan_cuidado c where c.id = b.cod_plan and b.pac_id = c.pac_id and b.admision = c.admision and a.codigo_condicion in ("+condicion+") and a.tipo = '"+cdo1.getColValue("tipo")+"' and a.cod_diag = "+cdoDiag.getColValue("codigo")+" /*and a.status = 'A'*/ and b.tipo = a.tipo and b.cod_diag = a.cod_diag and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and a.codigo = b.cod_param and b.cod_plan = "+id;
                         
                        } else{
                            sqlDet = "select a.codigo, a.descripcion, a.status, a.codigo_condicion, a.cod_diag, a.tipo from tbl_sal_soapier_cond_detalle a where a.codigo_condicion in ("+condicion+") and a.tipo = '"+cdo1.getColValue("tipo")+"' and a.cod_diag = "+cdoDiag.getColValue("codigo")+" and a.status = 'A'";
                            
                            String tmpKey = cdo1.getColValue("tipo")+"_"+cdoDiag.getColValue("codigo")+"_"+pacId+"_"+noAdmision;
                                                        
                            if (iDetTemp.get(tmpKey) != null && !"".equals(iDetTemp.get(tmpKey))) {
                                sqlDet += " and a.codigo in("+iDetTemp.get(tmpKey)+")";
                            } else {
                                // this is stupid, but who else but Victor?
                                sqlDet += " and a.codigo = -1 ";
                            }
                        }
                        
                        sqlDet += " order by 1";
                        
                        ArrayList alDet = SQLMgr.getDataList(sqlDet);
                        
                       %>
                       <input type="hidden" class="has_params_<%=cdo1.getColValue("tipo"," ").trim()%>" value="<%=alDet.size()%>" data-tipo-desc="<%=cdo1.getColValue("tipo_desc")%>" data-diag-desc="<%=cdoDiag.getColValue("descripcion")%>">
                       <span class="bg-headtabla2"><%=cdo1.getColValue("tipo_desc")%></span>
                       
                       <%if((!saved||fp.trim().equals("continuar")) && !(cdo1.getColValue("tipo"," ").trim().equalsIgnoreCase("TTT") || cdo1.getColValue("tipo"," ").trim().equalsIgnoreCase("RRR") ) ){%> 
                        <button class="armar" type="button" data-tipo="<%=cdo1.getColValue("tipo")%>" data-cod-dia="<%=cdoDiag.getColValue("codigo")%>"<%=fp.trim().equals("continuar")?" data-rearmar=1":""%>><i class="fa fa-ellipsis-h"></i></button>
                       <%}%>
                       
                       <%if (alDet.size() == 0 && (cdo1.getColValue("tipo"," ").equalsIgnoreCase("TTT")||cdo1.getColValue("tipo"," ").equalsIgnoreCase("RRR"))) { 
                         CommonDataObject cdoF = SQLMgr.getData("select a.observ_reeval, a.observ_resol, to_char(b.fecha_reevaluacion,'dd/mm/yyyy hh12:mi:ss am') fecha_reevaluacion, to_char(b.fecha_resolucion,'dd/mm/yyyy hh12:mi:ss am') fecha_resolucion from tbl_sal_plan_cuidado b, tbl_sal_plan_cuidado_det a where a.pac_id = b.pac_id and a.admision = b.admision and a.cod_plan = b.id and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" and b.id = "+id+" and a.cod_diag = "+cdoDiag.getColValue("codigo"));
                         
                         if (cdoF == null) cdoF = new CommonDataObject();
                         
                         if (fp.trim().equalsIgnoreCase("continuar")) {
                            cdoF.addColValue("observ_reeval","");
                         }
                       
                       %>
                      <table cellspacing="0" class="table table-small-font table-bordered">
                        <%
                          String _tipo = cdo1.getColValue("tipo"," ").equalsIgnoreCase("TTT")?"EVAL":"RESOL";
                          String codEjecInt = _tipo+"_INT_"+cdoDiag.getColValue("codigo");
                          String xtraAttrEjec = " data-index='"+codEjecInt+"' data-diag='"+cdoDiag.getColValue("codigo")+"' data-message='Por favor indicar las"+(_tipo.equals("EVAL")?" REEVALUACIONES":" RESOLUCIONES")+"!'";
                          
                          %>
                            <tr>
                                <td>
                                   <%if (_tipo.equals("EVAL")){%>
                                     <%=fb.hidden("fecha_eval_"+cdoDiag.getColValue("codigo"),cdoF.getColValue("fecha_reevaluacion"," "))%>
                                     <%=fb.checkbox(codEjecInt,""+codEjecInt,!cdoF.getColValue("observ_reeval"," ").trim().equals(""),!saved||viewMode,!cdoF.getColValue("observ_reeval"," ").trim().equals("")?"cant-change":"observacion_ejec no_fecha_eval",null,"","", xtraAttrEjec)%>
                                     
                                   <%if(!cdoF.getColValue("observ_reeval"," ").trim().equals("")){%>
                                    <%=fb.hidden("can_be_resolved_"+cdoDiag.getColValue("codigo"), "Y")%>
                                   <%}%>
                                   <%} else {%>
                                     <%=fb.hidden("fecha_resol_"+cdoDiag.getColValue("codigo"),cdoF.getColValue("fecha_resolucion"," "))%>
                                     <%=fb.checkbox(codEjecInt,""+codEjecInt,(!cdoF.getColValue("fecha_resolucion"," ").trim().equals("")||!cdoF.getColValue("observ_resol"," ").trim().equals("")),!saved||viewMode||cdoF.getColValue("observ_reeval"," ").trim().equals(""),!cdoF.getColValue("observ_resol"," ").trim().equals("")?"cant-change":"observacion_ejec-remove  no_fecha_resol",null,"","", xtraAttrEjec)%>
                                   <%}%>
                                   
                                   
                                </td>
                                <td>
                                    <%if (_tipo.equals("EVAL")){%>
                                      <%=fb.textBox("observacion_ejec"+codEjecInt,cdoF.getColValue("observ_reeval"),false,false,(viewMode||cdoF.getColValue("observ_reeval"," ").trim().equals("")),0,"form-control input-sm",null,null)%>
                                      <%} else {%>
                                        
                                        <%//=fb.textBox("observacion_ejec"+codEjecInt,cdoF.getColValue("observ_resol","N/A"),false,false,(viewMode||cdoF.getColValue("observ_resol","N/A").trim().equals("")),0,"form-control input-sm",null,null)%>
                                        
                                        <input type="hidden" name="observacion_ejec<%=codEjecInt%>" id="observacion_ejec<%=codEjecInt%>" value="<%=cdoF.getColValue("observ_resol","N/A")%>">
                                    <%}%>
                                </td>
                            </tr>
                            <!--
                            <tr>
                                <td>
                                   <%//=fb.checkbox("ejec_ot_"+_tipo,"OT",prop.getProperty("ejec_ot")!=null&&prop.getProperty("ejec_ot").equals("OT"),viewMode,null,null,"","")%>
                                </td>
                                <td>
                                  <%//=fb.textBox("observacion_ejec_ot_"+_tipo,prop.getProperty("observacion_ejec_ot"),false,false,(viewMode||prop.getProperty("observacion_ejec_ot").equals("")),0,"form-control input-sm",null,null)%>
                                </td>
                            </tr>
                            -->
                            <%if(_tipo.equalsIgnoreCase("EVAL")){%>
                                <%if(!viewMode && !cdoF.getColValue("observ_reeval"," ").trim().equals("")){%>
                                <tr>
                                    <td colspan="2">
                                        <button class="btn_add_otras_reeval" type="button" data-tipo="<%=cdo1.getColValue("tipo")%>" data-cod-dia="<%=cdoDiag.getColValue("codigo")%>" title="Agregar otras intervenciones">+Reevaluaciones</button>
                                    </td>
                                </tr>
                                <%}%>
                                
                                <tr id="container-otras-reval-<%=cdoDiag.getColValue("codigo")%>"><td colspan="2"></td></tr>
                                
                                <tr id="btn-save-container-otras-reval-<%=cdoDiag.getColValue("codigo")%>" style="display:none">
                                    <td colspan="2">
                                        <button data-diag="<%=cdoDiag.getColValue("codigo")%>" type="button" class="btn btn-inverse btn-sm save-mas-reeval"><i class="fa fa-floppy-o fa-lg"></i></button>
                                    </td>
                                </tr>
                                
                                <%
                                    ArrayList alR = SQLMgr.getDataList("select codigo, reevaluacion from tbl_sal_otras_reeval where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_diag = "+cdoDiag.getColValue("codigo")+" and cod_plan = "+id);
                                    
                                    for (int r = 0; r < alR.size(); r++) {
                                        CommonDataObject cdoR = (CommonDataObject) alR.get(r);
                                    %>
                                        <tr id="or-<%=cdoDiag.getColValue("codigo")%>-<%=cdoR.getColValue("codigo")%>">
                                            <td colspan="2">
                                                <%=cdoR.getColValue("reevaluacion")%>
                                                <%if(!viewMode){%>
                                                &nbsp;<a href="#!" style="color:red" onclick="removeOR('<%=cdoR.getColValue("codigo")%>','<%=cdoDiag.getColValue("codigo")%>')"><b>X</b></a>
                                                <%}%>
                                            </td>
                                        </tr>
                                <%
                                    } // for r
                                %>
                            <%}%>
                        
                   
                       
                        
                      </table>
                    <%
                      }else {
                    %>
                    <table cellspacing="0" class="table table-small-font table-bordered">
                    <% for (int d = 0; d < alDet.size(); d++){
                    CommonDataObject cdoD = (CommonDataObject) alDet.get(d);
                    String tipo = cdoD.getColValue("tipo");
                    String cDiag = cdoD.getColValue("cod_diag");
                    String domName = tipo+"_"+cDiag+"_"+cdoD.getColValue("codigo");
                    String otrosDomName = tipo+"_"+cDiag+"_OT";
                    String xtraAttr = " data-index='"+tipo+"' data-diag='"+cDiag+"' data-message='Por favor indique OTROS para: "+cdo1.getColValue("tipo_desc")+"'";
                    
                    if (cdo!=null && cdoD.getColValue("tmp_diag") != null)iDetTemp.put(tipo+"_"+cDiag+"_"+pacId+"_"+noAdmision, cdoD.getColValue("tmp_diag"));
                    
                    %>
                    <%=fb.hidden("codigo"+realSize, cdoD.getColValue("codigo"))%>
                    <%=fb.hidden("tipo"+realSize, tipo)%>
                    <%=fb.hidden("cod_diag"+realSize, cDiag)%>
                        <tr>
                            <td>
                                <label class="pointer">
                                   <%=fb.checkbox(domName,cdoD.getColValue("codigo"),request.getParameter("armado_final")!=null||(!id.equals("")||!id.equals("0")),viewMode, "cant-change",null,"","")%>
                                    <%=cdoD.getColValue("descripcion")%>
                                </label>
                            </td>
                        </tr>
                        
                        <%if(d+1 == alDet.size()){%>
                            <tr>
                                <td>
                                    <label class="pointer"><%=fb.checkbox(otrosDomName,"OT",!cdoD.getColValue("observ_otro"," ").trim().equals(""),viewMode,(saved&&!cdoD.getColValue("observ_otro"," ").trim().equals("")?"cant-change":" observacion"),null,"","",xtraAttr)%>&nbsp;Otros</label>
                                    <%=fb.textarea("observacion"+tipo+cDiag,cdoD.getColValue("observ_otro"),false,false,(viewMode||prop.getProperty("observacion"+tipo+cDiag).equals("")),0,1,0,"form-control input-sm","",null)%>
                                </td>
                            </tr>
                        <%}%>
                    <%
                    realSize++;
                    }
                    %>
                    </table>
                    <%}%>
                    
                    <%
                    if(cdo1.getColValue("tipo"," ").equalsIgnoreCase("INT")){
                        ArrayList alOI = SQLMgr.getDataList("select b.codigo, a.descripcion from tbl_sal_otras_interv_params a, tbl_sal_otras_interv b where a.codigo = b.cod_param and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.cod_plan = "+id+" and cod_diag = "+cdoDiag.getColValue("codigo")+" order by b.codigo");
                    %>
                      <%if (!id.equals("0")){%>
                      <span class="bg-headtabla">OTRAS INTERVENCIONES</span>
                      <%}%>
                      
                      <%if (!id.equals("0")&&!mode.equalsIgnoreCase("view")) {%>
                        <%if(!viewMode){%>
                        <button class="otras_int" type="button" data-tipo="<%=cdo1.getColValue("tipo")%>" data-cod-dia="<%=cdoDiag.getColValue("codigo")%>" title="Agregar otras intervenciones"><i class="fa fa-ellipsis-h"></i></button>
                        <%}%>
                       <%}%>
                       
                      
                      <table cellspacing="0" class="table table-small-font table-bordered">
                        <%
                        for(int oi = 0; oi <alOI.size(); oi++){
                            CommonDataObject cdoOI = (CommonDataObject)alOI.get(oi);
                        %>
                            <tr id="oi-<%=cdoDiag.getColValue("codigo")%>-<%=cdoOI.getColValue("codigo")%>">
                                <td>
                                    <%=cdoOI.getColValue("descripcion")%>
                                    <%if(!viewMode){%>
                                    &nbsp;<a href="#!" style="color:red" onclick="removeOI('<%=cdoOI.getColValue("codigo")%>','<%=cdoDiag.getColValue("codigo")%>')"><b>X</b></a>
                                    <%}%>
                                </td>
                            </tr>
                        <%        
                        }// for oi
                        %>
                      </table>
                    <%}%>
                      
                      
                      
                      
                      
                   </td> 
                 </table>
              </td> <!-- / detalle -->
              
              <% if( h > 0 && h%alD.size() == 0){ %>
                </tr><tr>
              <%}%>
        
        <%
        } // for headers
        %>
        </table>
        </td>
        </tr>
        <!-- /det -->
        <%
        int colspan = alD.size();        
          } // for d
        %>
        
       
  </table>  

<%
fb.appendJsValidation("\n\tif (!checkedFecha()) error++;\n");
fb.appendJsValidation("if(error>0)doAction();");
%>
		<div class="footerform">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td>
            <%=fb.hidden("saveOption","O")%>
            <%if(fp.trim().equalsIgnoreCase("buscar")){%>
                <button type="button" class="btn btn-sm btn-inverse" onClick="armar()">Armar diagnósticos</button>
                <button id="terminar-armar" type="button" class="btn btn-sm btn-inverse"<%=request.getParameter("armar_checks_temp")!=null&&request.getParameter("armar_checks_temp").trim().equals("")?" disabled":""%> onClick="armar(1)">Guardar diagnósticos</button>
            <%}%>
            
            <%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>
            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
        </tr>
    </table> </div>
<%=fb.hidden("realSize", ""+realSize)%>
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

    int realSize = Integer.parseInt(request.getParameter("realSize")==null?"0":request.getParameter("realSize"));
    
    id = request.getParameter("id");
    
    plan = new PlanCuidado();

	plan.setPacId(request.getParameter("pacId"));
	plan.setAdmision(request.getParameter("noAdmision"));
	plan.setCodCondicion(request.getParameter("condicion"));
	plan.setCodDiag(request.getParameter("armar_checks_temp"));
    
    if (!id.trim().equals("") && !id.trim().equals("0")){
        plan.setUsuarioModificacion(userName);
        plan.setId(id);
        
        if (request.getParameter("real_fecha_eval")!=null&&!request.getParameter("real_fecha_eval").trim().equals(""))
            plan.setFechaReeval(cDateTime);
        
        if (request.getParameter("real_fecha_resol")!=null&&!request.getParameter("real_fecha_resol").trim().equals(""))
            plan.setFechaResol(cDateTime);        
    } else {
        plan.setUsuarioCreacion(userName);
        plan.setFechaCreacion(request.getParameter("fecha")+" "+request.getParameter("hora"));
    }
    
    if (fp.trim().equalsIgnoreCase("continuar")) {
        plan.setUsuarioCreacion(userName);
        plan.setFechaCreacion(request.getParameter("fecha")+" "+request.getParameter("hora"));
    }
    
    if (request.getParameter("ejec_ot") != null) {
        //if (request.getParameter("observacion_ejec_ot") != null && !request.getParameter("observacion_ejec_ot").trim().equals("")) plan.setObservOtro(request.getParameter("observacion_ejec_ot"));
    }
    
    int totRe = 0, totRes = 0;
    for (int i = 0; i < realSize; i++) {
       String tipo = request.getParameter("tipo"+i);
       String codigo = request.getParameter("codigo"+i);
       String codDiag = request.getParameter("cod_diag"+i);
       String domName = tipo+"_"+codDiag+"_"+codigo;
       String otrosDomName = tipo+"_"+codDiag+"_OT";
       
       if (request.getParameter(domName) != null){
       
       PlanCuidadoDet pcd = new PlanCuidadoDet();
       
       pcd.setTipo(tipo);
       pcd.setCodDiag(codDiag);
       pcd.setCodParam(request.getParameter(domName));
       
       if (request.getParameter(otrosDomName) != null && !request.getParameter(otrosDomName).equals("")) {
            if (request.getParameter("observacion"+tipo+codDiag)!=null && !request.getParameter("observacion"+tipo+codDiag).trim().equals("")) {
               pcd.setObservOtro(request.getParameter("observacion"+tipo+codDiag));
            }           
       }
       if (!id.trim().equals("") && !id.trim().equals("0")){
           if (request.getParameter("EVAL_INT_"+codDiag) != null) {
             if (request.getParameter("observacion_ejecEVAL_INT_"+codDiag)!=null && !request.getParameter("observacion_ejecEVAL_INT_"+codDiag).trim().equals("")){
                pcd.setObservReeval(request.getParameter("observacion_ejecEVAL_INT_"+codDiag));   
                totRe++;
             }
           }
           
           if (request.getParameter("can_be_resolved_"+codDiag) != null && request.getParameter("can_be_resolved_"+codDiag).equals("Y") && request.getParameter("RESOL_INT_"+codDiag) != null) {
                        
             if (request.getParameter("observacion_ejecRESOL_INT_"+codDiag)!=null && !request.getParameter("observacion_ejecRESOL_INT_"+codDiag).trim().equals("")){
                pcd.setObservResol(request.getParameter("observacion_ejecRESOL_INT_"+codDiag));   
                totRes++;
                System.out.println("........................................... ====================================================================================================================== here??");
             }
           }
       }
       
       plan.addDetalles(pcd);
       }
       
    } // for
    
    if (totRe == realSize) {
       // plan.setFechaReeval(cDateTime);
    }
    
    if (totRes == realSize) {
        // plan.setFechaResol(cDateTime);
    }
    
        
	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES, "fg="+fg+",fp="+fp+",modeSec="+modeSec+",mode="+mode);
		if (modeSec.equalsIgnoreCase("add")){
		 	PCMgr.add(plan);
			id = PCMgr.getPkColValue("id");
		} else PCMgr.update(plan);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (PCMgr.getErrCode().equals("1"))
{
%>
	alert('Han sido guardados satisfactoriamente sus diagnósticos');
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
} else throw new Exception(PCMgr.getErrMsg());
%>
}

function addMode(){
    <%if (fp.trim().equalsIgnoreCase("continuar")){%>
        editMode();
    <%} else {%>
        window.location = '<%=request.getContextPath()+request.getServletPath()%>';
    <%}%>
}

function editMode(){
    window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=<%=request.getParameter("should_be_closed")!=null&&!request.getParameter("should_be_closed").equals("")?"view":"edit"%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&desc=<%=desc%>&condicion=<%=condicion%>&from=<%=from%>&cond_title=<%=condTitle%>&armar_checks_temp=<%=armarChecksTemp%>&plans_temp=<%=plansTemp%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>