<%//@ page errorPage="../error.jsp"%>
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
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

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

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";

if (fg == null) fg = "AD";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	
	prop = SQLMgr.getDataProperties("select plan from tbl_sal_plan_egreso_ingreso where pac_id="+pacId+" and admision="+noAdmision);
	if (prop == null){
		if(!viewMode) modeSec="add";
        prop = new Properties();
	}
	else{
		if(!viewMode) modeSec= "edit"; 
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
<script>
var noNewHeight = true;
function doAction(){}
function printExp(){abrir_ventana("../expediente3.0/print_plan_egreso_desde_ingreso.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>");}
 
$(document).ready(function(){
    // control dificultad
    $("input[name^='dificultades_egresos']").click(function(e){
        var dificultad = $("input[name='dificultad_egreso']:checked").val();
        if (dificultad && dificultad == 'S') {} else {
          e.preventDefault();
          e.stopPropagation();
          this.checked = false
          return false;
        }
    });
    $("input[name='dificultad_egreso']").click(function(){
      if (this.value == 'N') {
        $("input[name^='dificultades_egresos']").prop("checked", false);
        $("#observacion0").val("").prop("readOnly", true)
      }
    });
    
    // control diagnostico
    $("input[name^='conocer_diags']").click(function(e){
        var diagnostico = $("input[name='conocer_diag']:checked").val();
        if (diagnostico && diagnostico == 'N') {} else {
          e.preventDefault();
          e.stopPropagation();
          this.checked = false
          return false;
        }
    });
    $("input[name='conocer_diag']").click(function(){
      if (this.value == 'S') {
        $("input[name^='conocer_diags']").prop("checked", false);
      }
    });
    
    // control medicamento_en_casa
    $("input[name^='_medicamentos_en_casa']").click(function(e){
        var medicamento = $("input[name='medicamento_en_casa']:checked").val();
        if (medicamento && medicamento == 'S') {} else {
          e.preventDefault();
          e.stopPropagation();
          this.checked = false
          return false;
        }
    });
    $("input[name='medicamento_en_casa']").click(function(){
      if (this.value == 'N') {
        $("input[name^='_medicamentos_en_casa']").prop("checked", false);
      }
    });
    
    // control educacion_paciente
    $("input[name^='educaciones_paciente']").click(function(e){
        var educacion = $("input[name='educacion_paciente']:checked").val();
        if (educacion && educacion == 'S') {} else {
          e.preventDefault();
          e.stopPropagation();
          this.checked = false
          return false;
        }
    });
    $("input[name='educacion_paciente']").click(function(){
      if (this.value == 'N') {
        $("input[name^='educaciones_paciente']").prop("checked", false);
        $("#observacion1").val("").prop("readOnly", true)
      }
    });
    
    // medicamentos
    $("input[name^='medicamentos']").click(function(e){
        var medicamento = $("input[name='medicamento']:checked").val();
        if (medicamento && medicamento == 'S') {} else {
          e.preventDefault();
          e.stopPropagation();
          this.checked = false
          return false;
        }
    });
    $("input[name='medicamento']").click(function(){
      if (this.value == 'N') {
        $("input[name^='medicamentos']").prop("checked", false);
        $("#observacion2").val("").prop("readOnly", true)
      }
    });
    
    // instrucciones de ingreso
    $("input[name^='insts_egr']").click(function(e){
        var instr = $("input[name='inst_egr']:checked").val();
        if (instr && instr == 'S') {} else {
          e.preventDefault();
          e.stopPropagation();
          this.checked = false
          return false;
        }
    });
    $("input[name='inst_egr']").click(function(){
      if (this.value == 'N') {
        $("input[name^='insts_egr']").prop("checked", false);
        $(".observacion-inst-egr").val("").prop("readOnly", true)
      }
    });
    
    // Tratamientos
    $("input[name^='tratamientos']").click(function(e){
        var tratamiento = $("input[name='tratamiento']:checked").val();
        if (tratamiento && tratamiento == 'S') {} else {
          e.preventDefault();
          e.stopPropagation();
          this.checked = false
          return false;
        }
    });
    $("input[name='tratamiento']").click(function(){
      if (this.value == 'N') {
        $("input[name^='tratamientos']").prop("checked", false);
        $(".observacion-tratamiento").val("").prop("readOnly", true)
        $("#observacion10").val("").prop("readOnly", true)
      } else {
        $("#observacion10").val("").prop("readOnly", false)
      }
    });
    
    // Pacientes de alto riesgo
    $("input[name^='altos_riesgos']").click(function(e){
        var riesgo = $("input[name='alto_riesgo']:checked").val();
        if (riesgo && riesgo == 'S') {} else {
          e.preventDefault();
          e.stopPropagation();
          this.checked = false
          return false;
        }
    });
    $("input[name='alto_riesgo']").click(function(){
      if (this.value == 'N') {
        $("input[name^='altos_riesgos']").prop("checked", false);
        $(".observacion-riesgo").val("").prop("readOnly", true)
      }
    });
    
    // Instrucciones al ingreso
    $("input[name^='insts_ing']").click(function(e){
        var inst = $("input[name='inst_ing']:checked").val();
        if (inst && inst == 'S') {} else {
          e.preventDefault();
          e.stopPropagation();
          this.checked = false
          return false;
        }
    });
    $("input[name='inst_ing']").click(function(){
      if (this.checked === false) {
        $("input[name^='insts_ing']").prop("checked", false);
        $("#observacion14").val("").prop("readOnly", true)
      } else {
        $("input[name^='insts_ing']").not($("#insts_ing10")).prop("checked", true);
        $("#observacion14").val("").prop("readOnly", true)
      }
    });
    
    //permite usar los textareas
    $(".should-type").click(function(){
      var that = $(this);
      var i = that.data('index');
      if (that.is(":checked")) {
        $("#observacion"+i).prop("readOnly", false)
      } else {
        $("#observacion"+i).val("").prop("readOnly", true)
      }
    });

});

function canSubmit() {
  var proceed = true;
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    if ( $self.is(":checked") && !$.trim($("#observacion"+i).val())) {
      parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
      proceed = false;
      $self.focus();
      return false;  
    }else  {proceed = true;}
  });
  
  var instIng = $("input[name='inst_ing']:checked").val();
  if (!instIng && instIng !== 'S') {
    parent.CBMSG.error("Por favor marcar las Instrucciones al ingreso");
    proceed = false;
  }
 
  if (proceed) {
    setAcciones();
    return proceed;
  }
}

function setAcciones() {
  var acciones = $("input:checked[type='checkbox'][name^='instrucciones']").map(function(){
    return this.value;
  }).get().join();
  $("#acciones").val(acciones);
}
</script>
<style>
  .text-center{text-align:center !important;}
  .ui-widget {
    font-size: 0.9em;
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
		<%=fb.hidden("desc",desc)%>
		<%=fb.hidden("acciones","")%>
        
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
                
                  <tr>
                    <td colspan="4" class="controls form-inline">
                      Fecha &nbsp;
                      <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                          <jsp:param name="noOfDateTBox" value="1"/>
                          <jsp:param name="dformat" value="dd/mm/yy"/>
                          <jsp:param name="tformat" value="hh:mm tt"/>
                          <jsp:param name="nameOfTBox1" value="fecha_creacion" />
                          <jsp:param name="valueOfTBox1" value="<%=!"".equals(prop.getProperty("fecha_creacion")) ? prop.getProperty("fecha_creacion") : cDateTime%>" />
                          <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                          <jsp:param name="jqui" value="y"/>
                      </jsp:include>
                    </td>
                </tr> 

                
                <tr class="bg-headtabla2">
                    <td colspan="4">EVALUACIÓN AL INGRESO DEL PACIENTE</td>
                </tr>
                <tr>
                    <td colspan="4"><b>Disposiciones Generales para el Egreso</b></td>
                </tr>
                
                <tr>
                    <td colspan="4" class="controls form-inline">
                      Cuenta con familiar para su cuidado:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("disposicion0","S",prop.getProperty("disposicion0")!=null&&prop.getProperty("disposicion0").equals("S"),viewMode,false)%>&nbsp;&nbsp;SI</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("disposicion0","N",prop.getProperty("disposicion0")!=null&&prop.getProperty("disposicion0").equals("N"),viewMode,false)%>&nbsp;&nbsp;NO</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4" class="controls form-inline">
                      Hogar preparado para su salida:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("disposicion1","S",prop.getProperty("disposicion1")!=null&&prop.getProperty("disposicion1").equals("S"),viewMode,false)%>&nbsp;&nbsp;SI</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("disposicion1","N",prop.getProperty("disposicion1")!=null&&prop.getProperty("disposicion1").equals("N"),viewMode,false)%>&nbsp;&nbsp;NO</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4" class="controls form-inline">
                      Cuenta con medio de transporte para la salida:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("disposicion2","S",prop.getProperty("disposicion2")!=null&&prop.getProperty("disposicion2").equals("S"),viewMode,false)%>&nbsp;&nbsp;SI</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("disposicion2","N",prop.getProperty("disposicion2")!=null&&prop.getProperty("disposicion2").equals("N"),viewMode,false)%>&nbsp;&nbsp;NO</label>
                    </td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <td colspan="4" class="controls form-inline">
                      <b>El paciente tiene alguna dificultad Para su egreso:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("dificultad_egreso","S",prop.getProperty("dificultad_egreso")!=null&&prop.getProperty("dificultad_egreso").equals("S"),viewMode,false)%>&nbsp;&nbsp;<b>SI</b></label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("dificultad_egreso","N",prop.getProperty("dificultad_egreso")!=null&&prop.getProperty("dificultad_egreso").equals("N"),viewMode,false)%>&nbsp;&nbsp;<b>NO</b></label>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">
                      <label class="pointer"><%=fb.checkbox("dificultades_egresos0","0",prop.getProperty("dificultades_egresos0")!=null&&prop.getProperty("dificultades_egresos0").equals("0"),viewMode,null,null,"","")%>&nbsp;Transporte al hogar</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("dificultades_egresos1","1",prop.getProperty("dificultades_egresos1")!=null&&prop.getProperty("dificultades_egresos1").equals("1"),viewMode,null,null,"","")%>&nbsp;Uso de escaleras</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("dificultades_egresos2","2",prop.getProperty("dificultades_egresos2")!=null&&prop.getProperty("dificultades_egresos2").equals("2"),viewMode,null,null,"","")%>&nbsp;Ambulancia</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("dificultades_egresos3","3",prop.getProperty("dificultades_egresos3")!=null&&prop.getProperty("dificultades_egresos3").equals("3"),viewMode,null,null,"","")%>&nbsp;Distancia</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("dificultades_egresos4","OT",prop.getProperty("dificultades_egresos4")!=null&&prop.getProperty("dificultades_egresos4").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=0 data-message='Por favor indique alguna dificultad Para su egreso!'")%>&nbsp;Otro</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion0",prop.getProperty("observacion0"),false,false,(viewMode||prop.getProperty("observacion0").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <td colspan="4" class="controls form-inline">
                      <b>El Paciente conoce su Diagnóstico/Pronóstico/Tratamiento:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("conocer_diag","S",prop.getProperty("conocer_diag")!=null&&prop.getProperty("conocer_diag").equals("S"),viewMode,false)%>&nbsp;&nbsp;<b>SI</b></label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("conocer_diag","N",prop.getProperty("conocer_diag")!=null&&prop.getProperty("conocer_diag").equals("N"),viewMode,false)%>&nbsp;&nbsp;<b>NO</b></label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                      <label class="pointer"><%=fb.checkbox("conocer_diags0","0",prop.getProperty("conocer_diags0")!=null&&prop.getProperty("conocer_diags0").equals("0"),viewMode,null,null,"","")%>&nbsp;Educación al paciente y familiar acerca de su diagn&oacute;stico</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("conocer_diags1","1",prop.getProperty("conocer_diags1")!=null&&prop.getProperty("conocer_diags1").equals("1"),viewMode,null,null,"","")%>&nbsp;Educación al paciente y familiar acerca de su Tratamiento</label>
                    </td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <td colspan="4" class="controls form-inline">
                      <b>Toma el Paciente Medicamentos en Casa:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("medicamento_en_casa","S",prop.getProperty("medicamento_en_casa")!=null&&prop.getProperty("medicamento_en_casa").equals("S"),viewMode,false)%>&nbsp;&nbsp;<b>SI</b></label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("medicamento_en_casa","N",prop.getProperty("medicamento_en_casa")!=null&&prop.getProperty("medicamento_en_casa").equals("N"),viewMode,false)%>&nbsp;&nbsp;<b>NO</b></label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                      <label class="pointer"><%=fb.checkbox("_medicamentos_en_casa0","0",prop.getProperty("_medicamentos_en_casa0")!=null&&prop.getProperty("_medicamentos_en_casa0").equals("0"),viewMode,null,null,"","")%>&nbsp;Lista de Medicamentos de admisión, conciliación de medicamentos</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("_medicamentos_en_casa1","1",prop.getProperty("_medicamentos_en_casa1")!=null&&prop.getProperty("_medicamentos_en_casa1").equals("1"),viewMode,null,null,"","")%>&nbsp;Educación al paciente y familiar acerca de medicamentos</label>
                    </td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <td colspan="4">PLAN DE SALIDA</td>
                </tr>
                <tr class="bg-headtabla2">
                    <td colspan="4" class="controls form-inline">
                      <b>Educación para el paciente, familia y/o Acompañante:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("educacion_paciente","S",prop.getProperty("educacion_paciente")!=null&&prop.getProperty("educacion_paciente").equals("S"),viewMode,false)%>&nbsp;&nbsp;<b>SI</b></label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("educacion_paciente","N",prop.getProperty("educacion_paciente")!=null&&prop.getProperty("educacion_paciente").equals("N"),viewMode,false)%>&nbsp;&nbsp;<b>NO</b></label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                      <label class="pointer"><%=fb.checkbox("educaciones_paciente0","0",prop.getProperty("educaciones_paciente0")!=null&&prop.getProperty("educaciones_paciente0").equals("0"),viewMode,null,null,"","")%>&nbsp;Folleto de Ingreso</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("educaciones_paciente1","1",prop.getProperty("educaciones_paciente1")!=null&&prop.getProperty("educaciones_paciente1").equals("1"),viewMode,null,null,"","")%>&nbsp;Folleto de Egreso</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("educaciones_paciente2","2",prop.getProperty("educaciones_paciente2")!=null&&prop.getProperty("educaciones_paciente2").equals("2"),viewMode,null,null,"","")%>&nbsp;Care Notes</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                    <label class="pointer"><%=fb.checkbox("educaciones_paciente3","OT",prop.getProperty("educaciones_paciente3")!=null&&prop.getProperty("educaciones_paciente3").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=1 data-message='Por favor indique la Educación para el paciente, familia y/o Acompañante!'")%>&nbsp;Otro</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion1",prop.getProperty("observacion1"),false,false,(viewMode||prop.getProperty("observacion1").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <td colspan="4" class="controls form-inline">
                      <b>Medicamentos:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("medicamento","S",prop.getProperty("medicamento")!=null&&prop.getProperty("medicamento").equals("S"),viewMode,false)%>&nbsp;&nbsp;<b>SI</b></label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("medicamento","N",prop.getProperty("educacion_paciente")!=null&&prop.getProperty("medicamento").equals("N"),viewMode,false)%>&nbsp;&nbsp;<b>NO</b></label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                      <label class="pointer"><%=fb.checkbox("medicamentos0","0",prop.getProperty("medicamentos0")!=null&&prop.getProperty("medicamentos0").equals("0"),viewMode,null,null,"","")%>&nbsp;Lista de Medicamentos</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("medicamentos1","1",prop.getProperty("medicamentos1")!=null&&prop.getProperty("medicamentos1").equals("1"),viewMode,null,null,"","")%>&nbsp;Conciliación de Medicamentos</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("medicamentos2","2",prop.getProperty("medicamentos2")!=null&&prop.getProperty("medicamentos2").equals("2"),viewMode,null,null,"","")%>&nbsp;Recetas</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                    <label class="pointer"><%=fb.checkbox("medicamentos3","OT",prop.getProperty("medicamentos3")!=null&&prop.getProperty("medicamentos3").equals("OT"),viewMode,"observacion  should-type",null,"",""," data-index=2 data-message='Por favor indique los medicamentos'")%>&nbsp;Otro</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion2",prop.getProperty("observacion2"),false,false,(viewMode||prop.getProperty("observacion2").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <td colspan="4" class="controls form-inline">
                      <b>Instrucciones de egreso:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("inst_egr","S",prop.getProperty("inst_egr")!=null&&prop.getProperty("inst_egr").equals("S"),viewMode,false)%>&nbsp;&nbsp;<b>SI</b></label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("inst_egr","N",prop.getProperty("inst_egr")!=null&&prop.getProperty("inst_egr").equals("N"),viewMode,false)%>&nbsp;&nbsp;<b>NO</b></label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("insts_egr0","0",prop.getProperty("insts_egr0")!=null&&prop.getProperty("insts_egr0").equals("0"),viewMode,"observacion should-type",null,"",""," data-index=3 data-message='Por favor indique las Técnicas de Rehabilitación'")%>&nbsp;Técnicas de Rehabilitación</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion3",prop.getProperty("observacion3"),false,false,(viewMode||prop.getProperty("observacion3").equals("")),0,1,2000,"form-control input-sm observacion-inst-egr","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("insts_egr1","1",prop.getProperty("insts_egr1")!=null&&prop.getProperty("insts_egr1").equals("1"),viewMode,"observacion  should-type",null,"",""," data-index=4 data-message='Por favor indique los Dispositivos de Rehabilitación'")%>&nbsp;Dispositivos de Rehabilitación</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion4",prop.getProperty("observacion4"),false,false,(viewMode||prop.getProperty("observacion4").equals("")),0,1,2000,"form-control input-sm observacion-inst-egr","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("insts_egr2","2",prop.getProperty("insts_egr2")!=null&&prop.getProperty("insts_egr2").equals("2"),viewMode,"observacion should-type",null,"",""," data-index=5 data-message='Por favor indique las Dietas'")%>&nbsp;Dietas</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion5",prop.getProperty("observacion5"),false,false,(viewMode||prop.getProperty("observacion5").equals("")),0,1,2000,"form-control input-sm observacion-inst-egr","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("insts_egr3","OT",prop.getProperty("insts_egr3")!=null&&prop.getProperty("insts_egr3").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=6")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion6",prop.getProperty("observacion6"),false,false,(viewMode||prop.getProperty("observacion6").equals("")),0,1,2000,"form-control input-sm observacion-inst-egr","",null)%>
                    </td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <td colspan="4" class="controls form-inline">
                      <b>Tratamientos:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("tratamiento","S",prop.getProperty("tratamiento")!=null&&prop.getProperty("tratamiento").equals("S"),viewMode,false)%>&nbsp;&nbsp;<b>SI</b></label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("tratamiento","N",prop.getProperty("tratamiento")!=null&&prop.getProperty("tratamiento").equals("N"),viewMode,false)%>&nbsp;&nbsp;<b>NO</b></label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("tratamientos0","0",prop.getProperty("tratamientos0")!=null&&prop.getProperty("tratamientos0").equals("0"),viewMode,"observacion should-type",null,"",""," data-index=7 data-message='Por favor indique los Equipos especiales!'")%>&nbsp;Equipos especiales</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion7",prop.getProperty("observacion7"),false,false,(viewMode||prop.getProperty("observacion7").equals("")),0,1,2000,"form-control input-sm observacion-tratamiento","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("tratamientos1","1",prop.getProperty("tratamientos1")!=null&&prop.getProperty("tratamientos1").equals("1"),viewMode,"observacion should-type",null,"",""," data-index=8 data-message='Por favor indique los Cuidados Post-Operatorios!'")%>&nbsp;Cuidados Post-Operatorios</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion8",prop.getProperty("observacion8"),false,false,(viewMode||prop.getProperty("observacion8").equals("")),0,1,2000,"form-control input-sm observacion-tratamiento","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("tratamientos2","2",prop.getProperty("tratamientos2")!=null&&prop.getProperty("tratamientos2").equals("2"),viewMode,"",null,"","","")%>&nbsp;Curación de heridas</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("tratamientos3","3",prop.getProperty("tratamientos3")!=null&&prop.getProperty("tratamientos3").equals("3"),viewMode,"",null,"","","")%>&nbsp;Terapia respiratoria</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("tratamientos4","4",prop.getProperty("tratamientos4")!=null&&prop.getProperty("tratamientos4").equals("4"),viewMode,"",null,"","","")%>&nbsp;Glicemia capilar</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("tratamientos5","5",prop.getProperty("tratamientos5")!=null&&prop.getProperty("tratamientos5").equals("5"),viewMode,"",null,"","","")%>&nbsp;Fisioterapia</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("tratamientos6","OT",prop.getProperty("tratamientos6")!=null&&prop.getProperty("tratamientos6").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=9")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion9",prop.getProperty("observacion9"),false,false,(viewMode||prop.getProperty("observacion9").equals("")),0,1,2000,"form-control input-sm observacion-tratamiento","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4">
                        <b>Otros</b>&nbsp;&nbsp;<%=fb.textarea("observacion10",prop.getProperty("observacion10"),false,false,(viewMode||prop.getProperty("observacion10").equals("")),0,1,2000,"form-control input-sm observacion-inst-egr","",null)%>
                    </td>
                </tr>
                
                <tr class="bg-headtabla2">
                    <td colspan="4" class="controls form-inline">
                      <b>Pacientes de alto riesgo, considerar:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.radio("alto_riesgo","S",prop.getProperty("alto_riesgo")!=null&&prop.getProperty("alto_riesgo").equals("S"),viewMode,false)%>&nbsp;&nbsp;<b>SI</b></label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                     <label class="pointer"><%=fb.radio("alto_riesgo","N",prop.getProperty("alto_riesgo")!=null&&prop.getProperty("alto_riesgo").equals("N"),viewMode,false)%>&nbsp;&nbsp;<b>NO</b></label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("altos_riesgos0","0",prop.getProperty("altos_riesgos0")!=null&&prop.getProperty("altos_riesgos0").equals("0"),viewMode,"",null,"","","")%>&nbsp;Equipo multidisciplinario previa salida</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("altos_riesgos1","1",prop.getProperty("altos_riesgos1")!=null&&prop.getProperty("altos_riesgos1").equals("1"),viewMode,"",null,"","","")%>&nbsp;Comunicación directa con médico de cabecera, previa salida</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("altos_riesgos2","2",prop.getProperty("altos_riesgos2")!=null&&prop.getProperty("altos_riesgos2").equals("2"),viewMode,"",null,"","","")%>&nbsp;Cita con médico tratante antes de los 7 días de salida</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("altos_riesgos3","3",prop.getProperty("altos_riesgos3")!=null&&prop.getProperty("altos_riesgos3").equals("3"),viewMode,"",null,"","","")%>&nbsp;Contacto directo con acompañante para salida</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("altos_riesgos4","4",prop.getProperty("altos_riesgos4")!=null&&prop.getProperty("altos_riesgos4").equals("4"),viewMode,"observacion should-type",null,"",""," data-index=11 data-message='Por favor indique la Dieta especial!'")%>&nbsp;Dieta especial</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion11",prop.getProperty("observacion11"),false,false,(viewMode||prop.getProperty("observacion11").equals("")),0,1,2000,"form-control input-sm observacion-riesgo","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("altos_riesgos5","5",prop.getProperty("altos_riesgos5")!=null&&prop.getProperty("altos_riesgos5").equals("5"),viewMode,"observacion should-type",null,"",""," data-index=12 data-message='Por favor indique las Restricciones!'")%>&nbsp;Restricciones</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion12",prop.getProperty("observacion12"),false,false,(viewMode||prop.getProperty("observacion12").equals("")),0,1,2000,"form-control input-sm observacion-riesgo","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("altos_riesgos6","6",prop.getProperty("altos_riesgos6")!=null&&prop.getProperty("altos_riesgos6").equals("6"),viewMode,"observacion should-type",null,"",""," data-index=13")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion13",prop.getProperty("observacion13"),false,false,(viewMode||prop.getProperty("observacion13").equals("")),0,1,2000,"form-control input-sm observacion-riesgo","",null)%>
                    </td>
                </tr>

                <tr class="bg-headtabla2">
                    <td colspan="4" class="controls form-inline">
                      <b>Instrucciones al ingreso:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      <label class="pointer"><%=fb.checkbox("inst_ing","S",prop.getProperty("inst_ing")!=null&&prop.getProperty("inst_ing").equals("S"),viewMode,"",null,"","","")%>&nbsp;&nbsp;<b>SI</b></label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("insts_ing0","0",prop.getProperty("insts_ing0")!=null&&prop.getProperty("insts_ing0").equals("0"),viewMode,"",null,"","","")%>&nbsp;Funcionamiento y uso del llamado de enfermera</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("insts_ing1","1",prop.getProperty("insts_ing1")!=null&&prop.getProperty("insts_ing1").equals("1"),viewMode,"",null,"","","")%>&nbsp;Derechos y deberes</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("insts_ing2","2",prop.getProperty("insts_ing2")!=null&&prop.getProperty("insts_ing2").equals("2"),viewMode,"",null,"","","")%>&nbsp;Resaltar importancia de no tener objetos de valor consigo durante la hospitalización</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("insts_ing3","3",prop.getProperty("insts_ing3")!=null&&prop.getProperty("insts_ing3").equals("3"),viewMode,"",null,"","","")%>&nbsp;Visitas, rutinas, restricciones y normas de la unidad</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("insts_ing4","4",prop.getProperty("insts_ing4")!=null&&prop.getProperty("insts_ing4").equals("4"),viewMode,"",null,"","","")%>&nbsp;Importancia del respeto de las normas de bioseguridad</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("insts_ing5","5",prop.getProperty("insts_ing5")!=null&&prop.getProperty("insts_ing5").equals("5"),viewMode,"",null,"","","")%>&nbsp;Prevención de caídas</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("insts_ing6","6",prop.getProperty("insts_ing6")!=null&&prop.getProperty("insts_ing6").equals("6"),viewMode,"",null,"","","")%>&nbsp;Evaluación , reevaluación y Manejo del dolor</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("insts_ing7","7",prop.getProperty("insts_ing7")!=null&&prop.getProperty("insts_ing7").equals("7"),viewMode,"",null,"","","")%>&nbsp;Seguridad y uso efectivo de la tecnología médica(alarmas, ruidos, equipos)</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("insts_ing8","8",prop.getProperty("insts_ing8")!=null&&prop.getProperty("insts_ing8").equals("8"),viewMode,"",null,"","","")%>&nbsp;Restricciones de Medicamentos usados en casa</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <label class="pointer"><%=fb.checkbox("insts_ing9","9",prop.getProperty("insts_ing9")!=null&&prop.getProperty("insts_ing9").equals("9"),viewMode,"",null,"","","")%>&nbsp;Estándar de Seguridad, Identificación del Paciente y lavado de manos</label>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("insts_ing10","OT",prop.getProperty("insts_ing10")!=null&&prop.getProperty("insts_ing10").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=14")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                      <%=fb.textarea("observacion14",prop.getProperty("observacion14"),false,false,(viewMode||prop.getProperty("observacion14").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="4">
                         <b>Observaciones:</b>&nbsp;&nbsp;&nbsp;<%=fb.textarea("observacion15",prop.getProperty("observacion15"),false,false,viewMode,0,0,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
 

        </tbody>
        </table>

    <div class="footerform">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
            <%=fb.submit("save","Guardar",viewMode,false,"",null,"")%>
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
    prop.setProperty("tipo_sumario",request.getParameter("fg"));
    prop.setProperty("usuario_creacion", (String) session.getAttribute("_userName"));
    prop.setProperty("fecha_creacion", request.getParameter("fecha_creacion"));
    
    if (modeSec.equalsIgnoreCase("edit")) {
        prop.setProperty("usuario_modificacion", (String) session.getAttribute("_userName"));
        prop.setProperty("fecha_modificacion", cDateTime);
    }
    
    if (request.getParameter("dificultad_egreso") != null ) prop.setProperty("dificultad_egreso", request.getParameter("dificultad_egreso"));
    if (request.getParameter("conocer_diag") != null ) prop.setProperty("conocer_diag", request.getParameter("conocer_diag"));
    if (request.getParameter("medicamento_en_casa") != null ) prop.setProperty("medicamento_en_casa", request.getParameter("medicamento_en_casa"));
    if (request.getParameter("educacion_paciente") != null ) prop.setProperty("educacion_paciente", request.getParameter("educacion_paciente"));
    if (request.getParameter("medicamento") != null ) prop.setProperty("medicamento", request.getParameter("medicamento"));
    if (request.getParameter("inst_egr") != null ) prop.setProperty("inst_egr", request.getParameter("inst_egr"));
    if (request.getParameter("tratamiento") != null ) prop.setProperty("tratamiento", request.getParameter("tratamiento"));
    if (request.getParameter("alto_riesgo") != null ) prop.setProperty("alto_riesgo", request.getParameter("alto_riesgo"));
    if (request.getParameter("inst_ing") != null ) prop.setProperty("inst_ing", request.getParameter("inst_ing"));

	for (int o = 0; o<17; o++) {
      if (request.getParameter("disposicion"+o) != null) prop.setProperty("disposicion"+o, request.getParameter("disposicion"+o));
      if (request.getParameter("observacion"+o) != null && !request.getParameter("observacion"+o).trim().equals("")) prop.setProperty("observacion"+o, request.getParameter("observacion"+o));
      
      if (request.getParameter("dificultad_egreso") != null && request.getParameter("dificultad_egreso").equals("S")) {
        if (request.getParameter("dificultades_egresos"+o) != null) prop.setProperty("dificultades_egresos"+o, request.getParameter("dificultades_egresos"+o));
      }
      
      if (request.getParameter("conocer_diag") != null && request.getParameter("conocer_diag").equals("N")) {
        if (request.getParameter("conocer_diags"+o) != null) prop.setProperty("conocer_diags"+o, request.getParameter("conocer_diags"+o));
      }
      
      if (request.getParameter("medicamento_en_casa") != null && request.getParameter("medicamento_en_casa").equals("S")) {
        if (request.getParameter("_medicamentos_en_casa"+o) != null) prop.setProperty("_medicamentos_en_casa"+o, request.getParameter("_medicamentos_en_casa"+o));
      }
      
      if (request.getParameter("educacion_paciente") != null && request.getParameter("educacion_paciente").equals("S")) {
        if (request.getParameter("educaciones_paciente"+o) != null) prop.setProperty("educaciones_paciente"+o, request.getParameter("educaciones_paciente"+o));
      }
      
      if (request.getParameter("medicamento") != null && request.getParameter("medicamento").equals("S")) {
        if (request.getParameter("medicamentos"+o) != null) prop.setProperty("medicamentos"+o, request.getParameter("medicamentos"+o));
      }
       
      if (request.getParameter("inst_egr") != null && request.getParameter("inst_egr").equals("S")) {
        if (request.getParameter("insts_egr"+o) != null) prop.setProperty("insts_egr"+o, request.getParameter("insts_egr"+o));
      }
      
      if (request.getParameter("tratamiento") != null && request.getParameter("tratamiento").equals("S")) {
        if (request.getParameter("tratamientos"+o) != null) prop.setProperty("tratamientos"+o, request.getParameter("tratamientos"+o));
      }
      
      if (request.getParameter("alto_riesgo") != null && request.getParameter("alto_riesgo").equals("S")) {
        if (request.getParameter("altos_riesgos"+o) != null) prop.setProperty("altos_riesgos"+o, request.getParameter("altos_riesgos"+o));
      }
      
      if (request.getParameter("inst_ing") != null && request.getParameter("inst_ing").equals("S")) {
        if (request.getParameter("insts_ing"+o) != null) prop.setProperty("insts_ing"+o, request.getParameter("insts_ing"+o));
      }
    }
      CommonDataObject param = new CommonDataObject();
			param.setTableName("tbl_sal_plan_egreso_ingreso");
			
			if (modeSec.equalsIgnoreCase("add")) {
				param.setSql("insert into tbl_sal_plan_egreso_ingreso (pac_id, admision, plan, usuario_creacion, fecha_creacion) values (?, ?, ?, ?, sysdate)");
				param.addInNumberStmtParam(1,request.getParameter("pacId")); 
				param.addInNumberStmtParam(2,request.getParameter("noAdmision")); 
				param.addInBinaryStmtParam(3,prop);
				param.addInStringStmtParam(4, (String) session.getAttribute("_userName"));
				
			} else {       
				param.setSql("update tbl_sal_plan_egreso_ingreso set plan = ?, usuario_modificacion = ?, fecha_modificacion = sysdate where pac_id = ? and admision = ?");
				param.addInBinaryStmtParam(1,prop);
				param.addInStringStmtParam(2,(String)session.getAttribute("_userName"));
				param.addInNumberStmtParam(3,request.getParameter("pacId")); 
				param.addInNumberStmtParam(4,request.getParameter("noAdmision")); 
			}

    if (baction.equalsIgnoreCase("Guardar")){
      ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
      SQLMgr.executePrepared(param);
      ConMgr.clearAppCtx(null);
	 }
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
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
} else throw new Exception(SQLMgr.getErrException());
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>