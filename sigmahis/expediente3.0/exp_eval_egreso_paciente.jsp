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
<jsp:useBean id="SumarioEgEnf" scope="page" class="issi.expediente.SumarioEgresoEnfermeriaMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SumarioEgEnf.setConnection(ConMgr);

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
	
	prop = SQLMgr.getDataProperties("select sumario from tbl_sal_sumario_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_sumario = '"+fg+"'");
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
function printExp(){abrir_ventana("../expediente3.0/print_exp_eval_egreso_paciente.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>");}
 
$(document).ready(function(){
   // salida
   $("input[name='relevo_responsabilidad']").click(function(e){
     var salida = $("input[name='salida']:checked").val();
     if (!salida || salida == 'A') {
        e.preventDefault();
        e.stopPropagation();
        this.checked = false
        return false;
     }
   });
   $("input[name='salida']").click(function(c){
    $("input[name='relevo_responsabilidad']").prop("checked", false)
   });
   
    //condicion piel
    $("input[name^='condicion_piel']").not($("#condicion_piel0")).click(function(e){
      var integra = $("input[name='condicion_piel0']:checked").val();
      if (integra || integra === 'IN') {
        e.preventDefault();
        e.stopPropagation();
        this.checked = false
        return false;
      }
    });
    $("input[name='condicion_piel0']").click(function(e){
       $("input[name^='condicion_piel']").not($(this)).prop("checked", false);
       $("#observacion1").prop("readOnly", true).val("");
    });
    
    //Fecha cita
    $("#sumario_plan_cuidado5").click(function(c) {
     if (this.checked) {
       $("#fecha").prop("readOnly", false)
       $("#resetfecha").prop("disabled", false)
     } else {
       $("#fecha").prop("readOnly", true).val("")
       $("#resetfecha").prop("disabled", true)
     }
    });
    
    //tamizajes
    $("input[name='auditivo'],input[name='metabolico']").click(function(c){
      /*if (this.name == 'auditivo') {
        if(this.value == 'N') $("#observacion25").prop("readOnly", false);
        else $("#observacion25").prop("readOnly", true).val("");
      } else if (this.name == 'metabolico') {
        if(this.value == 'N') $("#observacion26").prop("readOnly", false);
        else $("#observacion26").prop("readOnly", true).val("");
      }*/
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
  
  if ($("#fecha").length && $("#sumario_plan_cuidado5").is(":checked") && !$.trim($("#fecha").val())) {
    parent.CBMSG.error('Por favor insertar la Fecha Cita!');
    proceed = false;
  }
  
  if ($("#observacion25").length && $("input[name='auditivo']:checked").val() == 'N' && !$.trim($("#observacion25").val()) ) {
    parent.CBMSG.error('Por favor insertar la información para el tamizaje: Auditivo');
    proceed = false;
  }
  
  if ($("#observacion26").length && $("input[name='metabolico']:checked").val() == 'N' && !$.trim($("#observacion26").val()) ) {
    parent.CBMSG.error('Por favor insertar la información para el tamizaje: Metabólico');
    proceed = false;
  }
  
  if (proceed) setAcciones();
  return proceed;
}

function setAcciones() {
  var acciones = $("input:checked[type='checkbox'][name^='instrucciones']").map(function(){
    return this.value;
  }).get().join();
  $("#acciones").val(acciones);
}

function shouldTypeRadio(check, textareaIndex) {
  if (check == true) $("#observacion"+textareaIndex).prop("readOnly", false)
  else $("#observacion"+textareaIndex).val("").prop("readOnly", true)
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
                    <td colspan="2">
                       <label class="pointer">Salida Autorizada:&nbsp;<%=fb.radio("salida","A",prop.getProperty("salida")!=null&&prop.getProperty("salida").equals("A"),viewMode,false)%></label>
                    </td>
                    <td colspan="2" class="controls form-inline">
                      <label class="pointer">Salida Voluntaria:&nbsp;<%=fb.radio("salida","V",prop.getProperty("salida")!=null&&prop.getProperty("salida").equals("V"),viewMode,false)%></label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      Relevo de Responsabilidades:&nbsp;
                      <label class="pointer">&nbsp;<%=fb.radio("relevo_responsabilidad","S",prop.getProperty("relevo_responsabilidad")!=null&&prop.getProperty("relevo_responsabilidad").equals("S"),viewMode,false)%>SI&nbsp;</label>
                      &nbsp;&nbsp;&nbsp;
                      <label class="pointer">&nbsp;<%=fb.radio("relevo_responsabilidad","N",prop.getProperty("relevo_responsabilidad")!=null&&prop.getProperty("relevo_responsabilidad").equals("N"),viewMode,false)%>NO&nbsp;</label>
                    </td>
                </tr>
                
                <tr>
                    <td>Condición del paciente al egreso</td>
                    <td><label class="pointer"><%=fb.radio("condicion_paciente","R",prop.getProperty("condicion_paciente")!=null&&prop.getProperty("condicion_paciente").equals("R"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,0)'")%>&nbsp;Recuperado</label></td>
                    <td><label class="pointer"><%=fb.radio("condicion_paciente","C",prop.getProperty("condicion_paciente")!=null&&prop.getProperty("condicion_paciente").equals("C"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,0)'")%>&nbsp;Convaleciente</label></td>
                    <td>
                    <label class="pointer"><%=fb.radio("condicion_paciente","OT",prop.getProperty("condicion_paciente")!=null&&prop.getProperty("condicion_paciente").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,0)'",""," data-index=0")%>&nbsp;Otros</label>
                    <%=fb.textarea("observacion0",prop.getProperty("observacion0"),false,false,(viewMode||prop.getProperty("observacion0").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <%if(!fg.trim().equals("NEO")){%>
                
                <tr class="bg-headtabla2">
                    <td colspan="4">Necesidades Personales</td>
                </tr>
                
                <tr>
                    <th colspan="2"></th>
                    <th colspan="2" class="text-center">Plan de Accion</th>
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
                    <td>Vestirse desvestirse alimentación</td>
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
                    <td>Condición de la piel:</td>
                    <td colspan="2">
                      <label class="pointer"><%=fb.checkbox("condicion_piel0","IN",prop.getProperty("condicion_piel0")!=null&&prop.getProperty("condicion_piel0").equals("IN"),viewMode,null,null,"","")%>&nbsp;Integra</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("condicion_piel1","UL",prop.getProperty("condicion_piel1")!=null&&prop.getProperty("condicion_piel1").equals("UL"),viewMode,null,null,"","")%>&nbsp;Ulcera</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("condicion_piel2","HQ",prop.getProperty("condicion_piel2")!=null&&prop.getProperty("condicion_piel2").equals("HQ"),viewMode,null,null,"","")%>&nbsp;Herida Quirúrgica</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("condicion_piel3","OT",prop.getProperty("condicion_piel3")!=null&&prop.getProperty("condicion_piel3").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=1")%>&nbsp;Otro</label>
                    </td>
                    <td>
                      <%=fb.textarea("observacion1",prop.getProperty("observacion1"),false,false,(viewMode||prop.getProperty("observacion1").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td>Condición mental:</td>
                    <td colspan="2">
                      <label class="pointer"><%=fb.checkbox("condicion_mental0","AL",prop.getProperty("condicion_mental0")!=null&&prop.getProperty("condicion_mental0").equals("AL"),viewMode,null,null,"","")%>&nbsp;Alerta</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("condicion_mental1","OR",prop.getProperty("condicion_mental1")!=null&&prop.getProperty("condicion_mental1").equals("OR"),viewMode,null,null,"","")%>&nbsp;Orientado</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("condicion_mental2","CO",prop.getProperty("condicion_mental2")!=null&&prop.getProperty("condicion_mental2").equals("CO"),viewMode,null,null,"","")%>&nbsp;Confuso</label>
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                      
                      <label class="pointer"><%=fb.checkbox("condicion_mental3","OT",prop.getProperty("condicion_mental3")!=null&&prop.getProperty("condicion_mental3").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=2")%>&nbsp;Otro</label>
                    </td>
                    <td>
                      <%=fb.textarea("observacion2",prop.getProperty("observacion2"),false,false,(viewMode||prop.getProperty("observacion2").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <%}%>
                <tr>
                    <td>Signos Vitales:</td>
                    <td colspan="3" class="controls form-inline">
                      Temperatura:&nbsp;<%=fb.textBox("signos_vitales0", prop.getProperty("signos_vitales0"),false,false,viewMode,5,"form-control input-sm",null,null)%>
                      &nbsp;&nbsp;&nbsp;&nbsp;
                      
                      Pulso:&nbsp;<%=fb.textBox("signos_vitales1", prop.getProperty("signos_vitales1"),false,false,viewMode,5,"form-control input-sm",null,null)%>
                      
                      &nbsp;&nbsp;&nbsp;&nbsp;
                      
                      Respiración:&nbsp;<%=fb.textBox("signos_vitales2", prop.getProperty("signos_vitales2"),false,false,viewMode,5,"form-control input-sm",null,null)%>
                      
                      &nbsp;&nbsp;&nbsp;&nbsp;
                      
                      Presión Arterial:&nbsp;<%=fb.textBox("signos_vitales3", prop.getProperty("signos_vitales3"),false,false,viewMode,5,"form-control input-sm",null,null)%>
                      &nbsp;&nbsp;&nbsp;&nbsp;
                      
                      SO2:&nbsp;<%=fb.textBox("signos_vitales4", prop.getProperty("signos_vitales4"),false,false,viewMode,5,"form-control input-sm",null,null)%>
                      &nbsp;&nbsp;&nbsp;&nbsp;
                      
                      Dolor:&nbsp;<%=fb.textBox("signos_vitales5", prop.getProperty("signos_vitales5"),false,false,viewMode,5,"form-control input-sm",null,null)%>
                    </td>
                </tr>
                
                <%if(fg.trim().equalsIgnoreCase("NEO")){%>
                    <tr><td class="bg-headtabla2" colspan="4">Tamizajes</td></tr>
                    
                    <tr>
                        <td colspan="2">Auditivo</td>
                        <td colspan="2" class="controls form-inline">
                            <label class="pointer">&nbsp;<%=fb.radio("auditivo","S",prop.getProperty("auditivo")!=null&&prop.getProperty("auditivo").equals("S"),viewMode,false)%>&nbsp;SI&nbsp;</label>
                          &nbsp;&nbsp;&nbsp;
                          <label class="pointer">&nbsp;<%=fb.radio("auditivo","N",prop.getProperty("auditivo")!=null&&prop.getProperty("auditivo").equals("N"),viewMode,false)%>&nbsp;NO&nbsp;</label>
                           <%=fb.textarea("observacion25",prop.getProperty("observacion25"),false,false,(viewMode),0,1,0,"form-control input-sm","width:80%",null)%>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">Metab&oacute;lico</td>
                        <td colspan="2" class="controls form-inline">
                            <label class="pointer">&nbsp;<%=fb.radio("metabolico","S",prop.getProperty("metabolico")!=null&&prop.getProperty("metabolico").equals("S"),viewMode,false)%>&nbsp;SI&nbsp;</label>
                          &nbsp;&nbsp;&nbsp;
                          <label class="pointer">&nbsp;<%=fb.radio("metabolico","N",prop.getProperty("metabolico")!=null&&prop.getProperty("metabolico").equals("N"),viewMode,false)%>&nbsp;NO&nbsp;</label>
                           <%=fb.textarea("observacion26",prop.getProperty("observacion26"),false,false,(viewMode),0,1,0,"form-control input-sm","width:80%",null)%>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">Card&iacute;aco</td>
                        <td colspan="2" class="controls form-inline">
                            <label class="pointer">&nbsp;<%=fb.radio("cardiaco","S",prop.getProperty("cardiaco")!=null&&prop.getProperty("cardiaco").equals("S"),viewMode,false)%>&nbsp;SI&nbsp;</label>
                          &nbsp;&nbsp;&nbsp;
                          <label class="pointer">&nbsp;<%=fb.radio("cardiaco","N",prop.getProperty("cardiaco")!=null&&prop.getProperty("cardiaco").equals("N"),viewMode,false)%>&nbsp;NO&nbsp;</label>
                          <%=fb.textarea("observacion27",prop.getProperty("observacion27"),false,false,(viewMode),0,1,0,"form-control input-sm","width:80%",null)%>
                        </td>
                    </tr>
                <%}%>
                
                <%if(!fg.trim().equalsIgnoreCase("NEO")){%>
                <tr><td class="bg-headtabla2" colspan="4">Instrucciones al Egreso</td></tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones0","0",prop.getProperty("instrucciones0")!=null&&prop.getProperty("instrucciones0").equals("0"),viewMode,"observacion should-type",null,"","", " data-index=3 data-message='Por favor indique los Equipos especiales!'")%>
                        &nbsp;Equipos especiales</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion3",prop.getProperty("observacion3"),false,false,(viewMode||prop.getProperty("observacion3").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones1","1",prop.getProperty("instrucciones1")!=null&&prop.getProperty("instrucciones1").equals("1"),viewMode,"observacion should-type",null,"","", " data-index=4 data-message='Por favor indique los Cuidados post operatorios!'")%>&nbsp;Cuidados post operatorios</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion4",prop.getProperty("observacion4"),false,false,(viewMode||prop.getProperty("observacion4").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones2","2",prop.getProperty("instrucciones2")!=null&&prop.getProperty("instrucciones2").equals("2"),viewMode,"observacion should-type",null,"","", " data-index=5 data-message='Por favor indique las Curaciones de heridas!'")%>&nbsp;Curación de heridas </label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion5",prop.getProperty("observacion5"),false,false,(viewMode||prop.getProperty("observacion5").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones3","3",prop.getProperty("instrucciones3")!=null&&prop.getProperty("instrucciones3").equals("3"),viewMode,"observacion should-type",null,"","", " data-index=6 data-message='Por favor indique los signos y síntomas de infección!'")%>&nbsp;Signos y síntomas de infección</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion6",prop.getProperty("observacion6"),false,false,(viewMode||prop.getProperty("observacion6").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones4","4",prop.getProperty("instrucciones4")!=null&&prop.getProperty("instrucciones4").equals("4"),viewMode,"observacion should-type",null,"","", " data-index=7 data-message='Por favor indique las Terapias respiratorias!'")%>&nbsp;Terapia respiratoria </label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion7",prop.getProperty("observacion7"),false,false,(viewMode||prop.getProperty("observacion7").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones5","5",prop.getProperty("instrucciones5")!=null&&prop.getProperty("instrucciones5").equals("5"),viewMode,"observacion should-type",null,"","", " data-index=8 data-message='Por favor indique las Fisioterapias!'")%>&nbsp;Fisioterapia </label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion8",prop.getProperty("observacion8"),false,false,(viewMode||prop.getProperty("observacion8").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones6","6",prop.getProperty("instrucciones6")!=null&&prop.getProperty("instrucciones6").equals("6"),viewMode,"observacion should-type",null,"","", " data-index=9 data-message='Por favor indique las Glicemias capilares!'")%>&nbsp;Glicemia capilar</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion9",prop.getProperty("observacion9"),false,false,(viewMode||prop.getProperty("observacion9").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones7","7",prop.getProperty("instrucciones7")!=null&&prop.getProperty("instrucciones7").equals("7"),viewMode,"observacion should-type",null,"","", " data-index=10 data-message='Por favor indique las Dietas especiales!'")%>&nbsp;Dieta especial</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion10",prop.getProperty("observacion10"),false,false,(viewMode||prop.getProperty("observacion10").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones8","8",prop.getProperty("instrucciones8")!=null&&prop.getProperty("instrucciones8").equals("8"),viewMode,"observacion should-type",null,"","", " data-index=11 data-message='Por favor indique las Prevenciones de caídas!'")%>&nbsp;Prevención de caídas</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion11",prop.getProperty("observacion11"),false,false,(viewMode||prop.getProperty("observacion11").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones9","9",prop.getProperty("instrucciones9")!=null&&prop.getProperty("instrucciones9").equals("9"),viewMode,"observacion should-type",null,"","", " data-index=12 data-message='Por favor indique los Manejos del dolor!'")%>&nbsp;Manejo del dolor </label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion12",prop.getProperty("observacion12"),false,false,(viewMode||prop.getProperty("observacion12").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones10","10",prop.getProperty("instrucciones10")!=null&&prop.getProperty("instrucciones10").equals("10"),viewMode,"observacion should-type",null,"","", " data-index=13 data-message='Por favor indique los medicamentos!'")%>&nbsp;Medicamentos</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion13",prop.getProperty("observacion13"),false,false,(viewMode||prop.getProperty("observacion13").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones11","11",prop.getProperty("instrucciones11")!=null&&prop.getProperty("instrucciones11").equals("11"),viewMode,"observacion should-type",null,"",""," data-index=14")%>&nbsp;Otros</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion14",prop.getProperty("observacion14"),false,false,(viewMode||prop.getProperty("observacion14").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
        <%} else {%>
                <tr><td class="bg-headtabla2" colspan="4">Instrucciones al Egreso</td></tr>
                
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones0","0",prop.getProperty("instrucciones0")!=null&&prop.getProperty("instrucciones0").equals("0"),viewMode,"observacion should-type",null,"","", " data-index=3 data-message='Por favor indique Para Lactancia materna!'")%>&nbsp;Lactancia materna</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion3",prop.getProperty("observacion3"),false,false,(viewMode||prop.getProperty("observacion3").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones1","1",prop.getProperty("instrucciones1")!=null&&prop.getProperty("instrucciones1").equals("1"),viewMode,"observacion should-type",null,"","", " data-index=4 data-message='Por favor indique los Complementos!'")%>&nbsp;Complemento (tipo formula)</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion4",prop.getProperty("observacion4"),false,false,(viewMode||prop.getProperty("observacion4").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones2","2",prop.getProperty("instrucciones2")!=null&&prop.getProperty("instrucciones2").equals("2"),viewMode,"observacion should-type",null,"","", " data-index=5 data-message='Por favor indique la Forma de preparación!'")%>&nbsp;Forma de preparación</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion5",prop.getProperty("observacion5"),false,false,(viewMode||prop.getProperty("observacion5").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones3","3",prop.getProperty("instrucciones3")!=null&&prop.getProperty("instrucciones3").equals("3"),viewMode,"observacion should-type",null,"","", " data-index=6 data-message='Por favor indique la Posición de la madre y bebe!'")%>&nbsp;Posición de la madre y bebe</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion6",prop.getProperty("observacion6"),false,false,(viewMode||prop.getProperty("observacion6").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones4","4",prop.getProperty("instrucciones4")!=null&&prop.getProperty("instrucciones4").equals("4"),viewMode,"observacion should-type",null,"","", " data-index=7 data-message='Por favor ingresar información para: Baño del bebe!'")%>&nbsp;Baño del bebe</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion7",prop.getProperty("observacion7"),false,false,(viewMode||prop.getProperty("observacion7").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones5","5",prop.getProperty("instrucciones5")!=null&&prop.getProperty("instrucciones5").equals("5"),viewMode,"observacion should-type",null,"","", " data-index=8 data-message='Por favor indique la Forma de sacar los gases'")%>&nbsp;Forma de sacar los gases </label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion8",prop.getProperty("observacion8"),false,false,(viewMode||prop.getProperty("observacion8").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones6","6",prop.getProperty("instrucciones6")!=null&&prop.getProperty("instrucciones6").equals("6"),viewMode,"observacion should-type",null,"","", " data-index=9 data-message='Por favor indique los Cuidados del cordón umbilical!'")%>&nbsp;Cuidados del cordón umbilical</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion9",prop.getProperty("observacion9"),false,false,(viewMode||prop.getProperty("observacion9").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones7","7",prop.getProperty("instrucciones7")!=null&&prop.getProperty("instrucciones7").equals("7"),viewMode,"observacion should-type",null,"","", " data-index=10 data-message='Por favor indique el Higiene de genitales!'")%>&nbsp;Higiene de genitales</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion10",prop.getProperty("observacion10"),false,false,(viewMode||prop.getProperty("observacion10").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <label class="pointer"><%=fb.checkbox("instrucciones8","8",prop.getProperty("instrucciones8")!=null&&prop.getProperty("instrucciones8").equals("8"),viewMode,"observacion should-type",null,"","", " data-index=11 data-message='Por favor indique los Cuidados de circuncisión!'")%>&nbsp;Cuidados de circuncisión</label>
                    </td>
                    <td colspan="2">
                       <%=fb.textarea("observacion11",prop.getProperty("observacion11"),false,false,(viewMode||prop.getProperty("observacion11").equals("")),0,1,2000,"form-control input-sm","",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td colspan="2">Comprendi&oacute; las instrucciones ofrecidas</td>
                    <td colspan="2" class="controls form-inline">
                        <label class="pointer">&nbsp;<%=fb.radio("comprendio_instrucciones","S",prop.getProperty("comprendio_instrucciones")!=null&&prop.getProperty("comprendio_instrucciones").equals("S"),viewMode,false)%>SI&nbsp;</label>
                      &nbsp;&nbsp;&nbsp;
                      <label class="pointer">&nbsp;<%=fb.radio("comprendio_instrucciones","N",prop.getProperty("comprendio_instrucciones")!=null&&prop.getProperty("comprendio_instrucciones").equals("N"),viewMode,false)%>NO&nbsp;</label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">Observaciones</td>
                    <td colspan="2">
                       <%=fb.textarea("observacion24",prop.getProperty("observacion24"),false,false,viewMode,0,1,2000,"form-control input-sm","width:100%",null)%>
                    </td>
                </tr>

        <%}%>
        
        
        <%if (fg.trim().equalsIgnoreCase("NEO")) {%>
        <tr><td class="bg-headtabla2" colspan="4">Evaluación de Enfermería para neonatos con salida:</td></tr>
        
        <tr>
            <td colspan="2">
                <label class="pointer"><%=fb.checkbox("eval_neo0","0",prop.getProperty("eval_neo0")!=null&&prop.getProperty("eval_neo0").equals("0"),viewMode,"observacion should-type",null,"","", " data-index=15 data-message='Por favor indicar las Condiciones Generales'")%>&nbsp;Condición General</label>
            </td>
            <td colspan="2">
            <%=fb.textarea("observacion15",prop.getProperty("observacion15"),false,false,(viewMode||prop.getProperty("observacion15").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
        </tr>
        
        <tr>
            <td colspan="2">
                <label class="pointer"><%=fb.checkbox("eval_neo1","1",prop.getProperty("eval_neo1")!=null&&prop.getProperty("eval_neo1").equals("1"),viewMode,"observacion should-type",null,"","", " data-index=16 data-message='Por favor indicar las Condiciones para Activo'")%>&nbsp;Activo</label>
            </td>
            <td colspan="2">
            <%=fb.textarea("observacion16",prop.getProperty("observacion16"),false,false,(viewMode||prop.getProperty("observacion16").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <label class="pointer"><%=fb.checkbox("eval_neo2","2",prop.getProperty("eval_neo2")!=null&&prop.getProperty("eval_neo2").equals("2"),viewMode,"observacion should-type",null,"","", " data-index=17 data-message='Por favor indicar las Condiciones para Llanto fuerte'")%>&nbsp;Llanto fuerte</label>
            </td>
            <td colspan="2">
            <%=fb.textarea("observacion17",prop.getProperty("observacion17"),false,false,(viewMode||prop.getProperty("observacion17").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
        </tr>
        
        <tr>
            <td colspan="2">
                <label class="pointer"><%=fb.checkbox("eval_neo3","3",prop.getProperty("eval_neo3")!=null&&prop.getProperty("eval_neo3").equals("3"),viewMode,"observacion should-type",null,"","", " data-index=18 data-message='Por favor indicar las Condiciones para Condición de la piel'")%>&nbsp;Condición de la piel</label>
            </td>
            <td colspan="2">
            <%=fb.textarea("observacion18",prop.getProperty("observacion18"),false,false,(viewMode||prop.getProperty("observacion18").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
        </tr>
        
        <tr>
            <td colspan="2">
                <label class="pointer"><%=fb.checkbox("eval_neo4","4",prop.getProperty("eval_neo4")!=null&&prop.getProperty("eval_neo4").equals("4"),viewMode,"observacion should-type",null,"","", " data-index=19 data-message='Por favor indicar las Condiciones para Color de la piel'")%>&nbsp;Color de la piel</label>
            </td>
            <td colspan="2">
            <%=fb.textarea("observacion19",prop.getProperty("observacion19"),false,false,(viewMode||prop.getProperty("observacion19").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
        </tr>
        
        <tr>
            <td colspan="2">
                <label class="pointer"><%=fb.checkbox("eval_neo5","5",prop.getProperty("eval_neo5")!=null&&prop.getProperty("eval_neo5").equals("5"),viewMode,"observacion should-type",null,"","", " data-index=20 data-message='Por favor indicar las Condiciones para Area del pañal!'")%>&nbsp;Area del pañal</label>
            </td>
            <td colspan="2">
            <%=fb.textarea("observacion20",prop.getProperty("observacion20"),false,false,(viewMode||prop.getProperty("observacion20").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
        </tr>
        <%}%>
        
         <tr><td class="bg-headtabla2" colspan="4">Sumario del plan de Cuidado</td></tr>
         
         <tr>
            <td colspan="4">
                <label class="pointer"><%=fb.checkbox("sumario_plan_cuidado0","0",prop.getProperty("sumario_plan_cuidado0")!=null&&prop.getProperty("sumario_plan_cuidado0").equals("0"),viewMode,null,null,"","")%>&nbsp;Entrega de pertenencias</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  
              <label class="pointer">&nbsp;<%=fb.radio("entrega_pertenencia","S",prop.getProperty("entrega_pertenencia")!=null&&prop.getProperty("entrega_pertenencia").equals("S"),viewMode,false)%>SI&nbsp;</label>
              &nbsp;&nbsp;&nbsp;
              <label class="pointer">&nbsp;<%=fb.radio("entrega_pertenencia","N",prop.getProperty("entrega_pertenencia")!=null&&prop.getProperty("entrega_pertenencia").equals("N"),viewMode,false)%>NO&nbsp;</label>
              &nbsp;&nbsp;&nbsp;
              <label class="pointer">&nbsp;<%=fb.radio("entrega_pertenencia","NA",prop.getProperty("entrega_pertenencia")!=null&&prop.getProperty("entrega_pertenencia").equals("NA"),viewMode,false)%>NO APLICA&nbsp;</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="4">
                <label class="pointer"><%=fb.checkbox("sumario_plan_cuidado1","1",prop.getProperty("sumario_plan_cuidado1")!=null&&prop.getProperty("sumario_plan_cuidado1").equals("1"),viewMode,null,null,"","")%>&nbsp;Entrega de recetas y educación acerca de medicamentos</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="4">
                <label class="pointer"><%=fb.checkbox("sumario_plan_cuidado3","3",prop.getProperty("sumario_plan_cuidado3")!=null&&prop.getProperty("sumario_plan_cuidado3").equals("3"),viewMode,null,null,"","")%>&nbsp;Médico entrega el Egreso médico de medicamentos</label>
            </td>
        </tr>
        
        <tr>
            <td colspan="2">
                <label class="pointer"><%=fb.checkbox("sumario_plan_cuidado4","4",prop.getProperty("sumario_plan_cuidado4")!=null&&prop.getProperty("sumario_plan_cuidado4").equals("4"),viewMode,"observacion should-type",null,"","", " data-index=23 data-message='Por favor indicar el nombre del Doctor!'")%>&nbsp;Cita dada en la clínica del Dr.</label>
            </td>
            <td colspan="2">
            <%=fb.textBox("observacion23", prop.getProperty("observacion23"),false,false,(viewMode||prop.getProperty("observacion23").equals("")),100,"form-control input-sm",null,null)%>
            </td>
        </tr>
        
        <%if(fg.trim().equalsIgnoreCase("NEO")){%>
          <tr>
            <td colspan="4" class="controls form-inline">
                <label class="pointer"><%=fb.checkbox("sumario_plan_cuidado5","5",prop.getProperty("sumario_plan_cuidado5")!=null&&prop.getProperty("sumario_plan_cuidado5").equals("5"),viewMode,null,null,"","")%>&nbsp;Fecha Cita</label>
                
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")!=null?prop.getProperty("fecha"):""%>" />
				<jsp:param name="readonly" value="<%=(viewMode||prop.getProperty("fecha").equals(""))?"y":"n"%>"/>
				</jsp:include>
            </td>
          </tr>
          <tr>
            <td colspan="4">
                <label class="pointer"><%=fb.checkbox("sumario_plan_cuidado6","6",prop.getProperty("sumario_plan_cuidado6")!=null&&prop.getProperty("sumario_plan_cuidado6").equals("6"),viewMode,null,null,"","")%>&nbsp;Entrega de panfletos</label>
            </td>
          </tr>
        <%}%>
        
        <tr>
            <td colspan="4">
                <label class="pointer"><%=fb.checkbox("sumario_plan_cuidado7","7",prop.getProperty("sumario_plan_cuidado7")!=null&&prop.getProperty("sumario_plan_cuidado7").equals("7"),viewMode,null,null,"","")%>&nbsp;Requiere ambulancia / equipos especiales</label>
            </td>
          </tr>
        
       <tr>
            <td colspan="2">
                <label class="pointer"><%=fb.checkbox("sumario_plan_cuidado8","8",prop.getProperty("sumario_plan_cuidado8")!=null&&prop.getProperty("sumario_plan_cuidado8").equals("8"),viewMode,"observacion should-type",null,"",null," data-index=21 data-message='Por favor indicar las Instrucciones adicionales!'")%>&nbsp;Instrucciones adicionales</label>
            </td>
            <td colspan="2">
            <%=fb.textarea("observacion21",prop.getProperty("observacion21"),false,false,(viewMode||prop.getProperty("observacion21").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
        </tr>
         
          <tr>
            <td colspan="2">Observaciones</td>
            <td colspan="2">
            <%=fb.textarea("observacion22",prop.getProperty("observacion22"),false,false,viewMode,0,0,2000,"form-control input-sm","",null)%>
            </td>
          </tr>
          
          <%
            String recomendaciones = "";
            if (prop.getProperty("observacion28")==null || "".equals(prop.getProperty("observacion28"))) {
                ArrayList alE = SQLMgr.getDataPropertiesList("select resumen from tbl_sal_resumen_edu where pac_id = "+pacId+" and admision = "+noAdmision);
                for (int j = 0; j < alE.size(); j++) {
                    Properties propE = (Properties) alE.get(j);
                    recomendaciones += propE.getProperty("observacion75") != null && !"".equals(propE.getProperty("observacion75")) ? propE.getProperty("observacion75") +"\n" : "";
                    System.out.println(":::::::::::::::::::::::::::::: al = "+propE.getProperty("observacion75"));
                }
            } else recomendaciones = prop.getProperty("observacion28");
          %>

          <tr>
            <td colspan="2">Recomendaciones para su dieta (si aplica)</td>
            <td colspan="2">
            <%=fb.textarea("observacion28",recomendaciones,false,false,true,0,0,2000,"form-control input-sm","",null)%>
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

	if(request.getParameter("salida") != null)prop.setProperty("salida", request.getParameter("salida"));
	if(request.getParameter("salida") != null && request.getParameter("salida").equals("V") && request.getParameter("relevo_responsabilidad") != null) prop.setProperty("relevo_responsabilidad", request.getParameter("relevo_responsabilidad"));
	if(request.getParameter("condicion_paciente") != null)prop.setProperty("condicion_paciente", request.getParameter("condicion_paciente"));
	if(request.getParameter("banio_higiene") != null)prop.setProperty("banio_higiene", request.getParameter("banio_higiene"));
	if(request.getParameter("vestir_desvestir_ali") != null)prop.setProperty("vestir_desvestir_ali", request.getParameter("vestir_desvestir_ali"));
	if(request.getParameter("movilidad_deambulacion") != null)prop.setProperty("movilidad_deambulacion", request.getParameter("movilidad_deambulacion"));
	if(request.getParameter("comprendio_instrucciones") != null)prop.setProperty("comprendio_instrucciones", request.getParameter("comprendio_instrucciones"));
	if(request.getParameter("entrega_pertenencia") != null)prop.setProperty("entrega_pertenencia", request.getParameter("entrega_pertenencia"));
	if(request.getParameter("cita_con_medico") != null && !request.getParameter("cita_con_medico").trim().equals(""))prop.setProperty("cita_con_medico", request.getParameter("cita_con_medico"));
	if(request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals(""))prop.setProperty("fecha", request.getParameter("fecha"));
	if(request.getParameter("acciones") != null)prop.setProperty("acciones", request.getParameter("acciones"));
    
    if (request.getParameter("auditivo") != null) prop.setProperty("auditivo", request.getParameter("auditivo"));
    if (request.getParameter("metabolico") != null) prop.setProperty("metabolico", request.getParameter("metabolico"));
    if (request.getParameter("cardiaco") != null) prop.setProperty("cardiaco", request.getParameter("cardiaco"));
	
	for ( int o = 0; o<30; o++ ){
      if (request.getParameter("observacion"+o)!=null && !request.getParameter("observacion"+o).trim().equals("")) prop.setProperty("observacion"+o, request.getParameter("observacion"+o));
      if (request.getParameter("condicion_piel"+o)!=null) prop.setProperty("condicion_piel"+o, request.getParameter("condicion_piel"+o));
      if (request.getParameter("condicion_mental"+o)!=null) prop.setProperty("condicion_mental"+o, request.getParameter("condicion_mental"+o));
      if (request.getParameter("signos_vitales"+o)!=null) prop.setProperty("signos_vitales"+o, request.getParameter("signos_vitales"+o));
      if (request.getParameter("instrucciones"+o)!=null) prop.setProperty("instrucciones"+o, request.getParameter("instrucciones"+o));
      if (request.getParameter("eval_neo"+o)!=null) prop.setProperty("eval_neo"+o, request.getParameter("eval_neo"+o));
      if (request.getParameter("sumario_plan_cuidado"+o)!=null) prop.setProperty("sumario_plan_cuidado"+o, request.getParameter("sumario_plan_cuidado"+o));
      
      if(request.getParameter("observacion"+o) != null && !request.getParameter("observacion"+o).trim().equals(""))System.out.println("observacion"+o+" -------------------------------------------------- "+request.getParameter("observacion"+o));
	}

	if (modeSec.trim().equalsIgnoreCase("edit")) {
        prop.setProperty("usuario_modificacion", (String) session.getAttribute("_userName"));
        prop.setProperty("fecha_modificacion", cDateTime);
    } else {
        prop.setProperty("usuario_creacion", (String) session.getAttribute("_userName"));
        prop.setProperty("fecha_creacion", cDateTime);
    }
	if (baction.equalsIgnoreCase("Guardar")){
        System.out.println("........................................................................................");
        System.out.println(prop);
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        if (modeSec.equalsIgnoreCase("add")) SumarioEgEnf.add(prop);
        else SumarioEgEnf.update(prop);
        ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SumarioEgEnf.getErrCode().equals("1"))
{
%>
	alert('<%=SumarioEgEnf.getErrMsg()%>');
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
} else throw new Exception(SumarioEgEnf.getErrException());
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