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
<jsp:useBean id="SumarioEgMed" scope="page" class="issi.expediente.SumarioEgresoMedicoNeoMgr" />
<jsp:useBean id="iProcInTra" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProcInTra" scope="session" class="java.util.Vector" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SumarioEgMed.setConnection(ConMgr);

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
String tab = request.getParameter("tab");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";

if (fg == null) fg = "SEMN"; // Sumario Egreso Médico Neonatología

if (tab == null) tab = "0";

ArrayList al = new ArrayList();

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String active0 = "", active1 = "", active2 = "", active3 = "", active4 = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{	
	prop = SQLMgr.getDataProperties("select sumario from tbl_sal_sumario_egreso_med where pac_id="+pacId+" and admision="+noAdmision+" and tipo_sumario = '"+fg+"'");
	if (prop == null){
		if(!viewMode) modeSec="add";
        prop = new Properties();
	}
	else{
		if(!viewMode) modeSec= "edit"; 
	}
    
    if(change == null) {
        iProcInTra.clear();
        vProcInTra.clear();
        
        sql="select  a.codigo,a.procedimiento,decode(h.observacion , null , h.descripcion,h.observacion)descProc from tbl_sal_sumario_egres_med_proc a,tbl_cds_procedimiento h where  a.procedimiento = h.codigo and a.pac_id = "+pacId+" and admision = "+noAdmision+" order by a.codigo desc ";
        al = SQLMgr.getDataList(sql);
        
        for (int i=0; i<al.size(); i++) {
            CommonDataObject cdo1 = (CommonDataObject) al.get(i);
            cdo1.setKey(i);
            cdo1.setAction("U");

            try{
              iProcInTra.put(cdo1.getKey(),cdo1);
              vProcInTra.addElement(cdo1.getColValue("procedimiento"));
            }
            catch(Exception e)
            {
              System.err.println(e.getMessage());
            }
        }
    }
    
    if (tab.equals("0")) active0 = "active";
    else if (tab.equals("1")) active1 = "active";
    else if (tab.equals("2")) active2 = "active";
    else if (tab.equals("3")) active3 = "active";
    else if (tab.equals("4")) active4 = "active";
    
    if (prop.getProperty("diagnostico_ingreso") != null && !prop.getProperty("diagnostico_ingreso").equals("")) {
    }
    else {
        cdo = SQLMgr.getData("select nvl(b.observacion,b.nombre) nombre from tbl_cds_diagnostico b, tbl_adm_diagnostico_x_admision a where a.pac_id = "+pacId+" and a.admision = "+noAdmision+" and a.tipo = 'I' and a.orden_diag = 1 and b.codigo = a.diagnostico");
        
        if (cdo == null) cdo = new CommonDataObject();
        prop.setProperty("diagnostico_ingreso", cdo.getColValue("nombre"));
    }
%>
<!DOCTYPE html>
<html lang="en"> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
function doAction(){
<%if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("2")){%>showProcList();
<%}%>
}

function printExp(){abrir_ventana("../expediente3.0/print_sumario_egreso_medico_neo.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>");}

// protocolo_cesarea
function showProcList(){abrir_ventana1('../common/check_procedimiento.jsp?fp=sumario_egreso_med_neo&modeSec=<%=modeSec%>&mode=<%=mode%>&seccion=<%=seccion%>&pac_id=<%=pacId%>&admision=<%=noAdmision%>&tab=<%=tab%>&desc=<%=desc%>&exp=3&fg=<%=fg%>');}
 
$(document).ready(function(){
    $('iframe').iFrameResize({
        log: false
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
    
    $("input:radio[name*='tipo_nacimiento']").click(function(){
        if (this.value == 'C') $("#motivos_cesarea").prop("readOnly", false);
        else $("#motivos_cesarea").prop("readOnly", true).val("");
    });
    
    $("input:radio[name*='medicamentos_recibidos']").click(function(){
        if (this.value == 'S') $("#medicamentos_recibidos_detalle").prop("readOnly", false);
        else $("#medicamentos_recibidos_detalle").prop("readOnly", true).val("");
    });
    $("input:radio[name*='inmunizaciones_recibidas']").click(function(){
        if (this.value == 'S') $("#inmunizaciones_recibidas_detalle").prop("readOnly", false);
        else $("#inmunizaciones_recibidas_detalle").prop("readOnly", true).val("");
    });
    
    $("input:radio[name*='condicion_egreso']").click(function(){
        if (this.value == 'DE') {
            //$(".defuncion_control").hide(0);
            $("#causas_defuncion").prop("readOnly", false);
            $(".no_aplica_muerto:radio").prop({checked: false, disabled: true});
            $("input.no_aplica_muerto[type='text']").prop({readOnly: true}).val("");
            
            $("#fecha_cita").prop("readOnly", true).val("");
            $("#resetfecha_cita").prop("disabled", true);
        }
        else {
            //$(".defuncion_control").show(0);
            $("#causas_defuncion").prop("readOnly", true).val("");
            $("#resetfecha_cita").prop("disabled", false)
            
            $(".no_aplica_muerto:radio").prop({disabled: false});
            $("input.no_aplica_muerto[type='text']").not(".special").prop({readOnly: false});
            $("#fecha_cita").prop("readOnly", false).val("");
            $("#resetfecha_cita").prop("disabled", false);
        }
    });
    
    $("input:radio[name*='uso_equipos_esp']").click(function(){
        if (this.value == 'S') $("#equipos_esp").prop("readOnly", false);
        else $("#equipos_esp").prop("readOnly", true).val("");
    });
    
});

function canSubmit() {
  var proceed = true;
  if ($("input:radio[name*='tipo_nacimiento'][value='C']:checked").length && !$.trim($("#motivos_cesarea").val()) ) {
    proceed = false;
    parent.CBMSG.error("Por favor indique los motivos de la cesárea!");
  }
  else if ($("input:radio[name*='medicamentos_recibidos'][value='S']:checked").length && !$.trim($("#medicamentos_recibidos_detalle").val()) ) {
    proceed = false;
    parent.CBMSG.error("Por favor indique los medicamentos recibidos!");
  }
  else if ($("input:radio[name*='inmunizaciones_recibidas'][value='S']:checked").length && !$.trim($("#inmunizaciones_recibidas_detalle").val()) ) {
    proceed = false;
    parent.CBMSG.error("Por favor indique las inmunizaciones recibidas!");
  }
  else if ($("input:radio[name*='condicion_egreso'][value='DE']:checked").length && !$.trim($("#causas_defuncion").val()) ) {
    proceed = false;
    parent.CBMSG.error("Por favor indique las causas de defunción!");
  }
  else if ($("input:radio[name*='uso_equipos_esp'][value='S']:checked").length && !$.trim($("#equipos_esp").val()) ) {
    proceed = false;
    parent.CBMSG.error("Por favor indique los equipos especiales!");
  }
 
  return proceed;
}

function shouldTypeRadio(check, textareaIndex) {
  if (check == true) $("#observacion"+textareaIndex).prop("readOnly", false)
  else $("#observacion"+textareaIndex).val("").prop("readOnly", true)
}

function addDx(){
    abrir_ventana1('../common/search_diagnostico.jsp?fp=sumario_egreso_med_neo&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
}

// protocolo_cesarea
function showMedicoList(fg){
    abrir_ventana1('../common/search_medico.jsp?fp=sumario_egreso_med_neo&fg='+fg);
}

function getTotHospDay(){
    var fEgreso = $("#fecha_egreso").val();
    if (fEgreso) {
        fEgreso = fEgreso.substr(0,10);
        var diffDays = getDBData('<%=request.getContextPath()%>',"to_date('"+fEgreso+"','dd/mm/yyyy')  - fecha_ingreso",'tbl_adm_admision','pac_id = <%=pacId%> and secuencia = <%=noAdmision%>','');
        if (diffDays) $("#dias_hospitalizados").val(""+diffDays);   
    }
}
</script>
<style>
  .text-center{text-align:center !important;}
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

        <div class="headerform">
        <table cellspacing="0" class="table pull-right table-striped table-custom-1">
            <tr>
                <td>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="printExp()"><i class="material-icons fa-printico">print</i> <b>Imprimir</b></button>
                </td>
            </tr>
        </table>
        </div>
        
        <ul class="nav nav-tabs" role="tablist">
            <li role="presentation" class="<%=active0%>">
                <a href="#generales" aria-controls="generales" role="tab" data-toggle="tab"><b>Datos Generales</b></a>
            </li>
            <%if (!modeSec.equalsIgnoreCase("add")){%>
           
            <li role="presentation" class="<%=active1%>">
                <a href="#otros_laboratorios" aria-controls="otros_laboratorios" role="tab" data-toggle="tab"><b>Otros Laboratorios</b></a>
            </li>
            <li role="presentation" class="<%=active2%>">
                <a href="#procedimientos" aria-controls="procedimientos" role="tab" data-toggle="tab"><b>Procedimientos especiales intrahospitalarios</b></a>
            </li>
            <li role="presentation" class="<%=active3%>">
                <a href="#medicamentos" aria-controls="medicamentos" role="tab" data-toggle="tab"><b>Medicamentos al egreso</b></a>
            </li>
            <li role="presentation" class="<%=active4%>">
                <a href="#documentos" aria-controls="documentos" role="tab" data-toggle="tab"><b>Documentos</b></a>
            </li>
            <%}%>
        </ul>
        
        <!-- Tab panes -->
        <div class="tab-content">
  
            <!-- Generales -->
            <div role="tabpanel" class="tab-pane <%=active0%>" id="generales">
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
                <%=fb.hidden("tab",tab)%>
                
                <table class="table table-small-font table-bordered table-striped">
                    <tbody><tr><td></td></tr></tbody>
                    
                    <tr>
                        <td class="controls form-inline">
                            <b>Fecha Egreso:</b>&nbsp;
                            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1"/>
                            <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                            <jsp:param name="nameOfTBox1" value="fecha_egreso" />
                            <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_egreso")!=null?prop.getProperty("fecha_egreso"):""%>" />
                            <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                            <jsp:param name="jsEvent" value="getTotHospDay()"/>
                            </jsp:include>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <b>D&iacute;as de hospitalizaci&oacute;n:</b>
                            <%=fb.textBox("dias_hospitalizados", prop.getProperty("dias_hospitalizados"),false,false,true,5,"form-control input-sm",null,null)%>
                            
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <b>Diagn&oacute;stico de ingreso:</b>
                            <%=fb.textBox("diagnostico_ingreso", prop.getProperty("diagnostico_ingreso"),false,false,true,40,"form-control input-sm",null,null)%>
                            
                        </td>
                    </tr>                    
                    
                    <tr class="bg-headtabla">
                        <td>ANTECEDENTES RELEVANTES DURANTE EL NACIMIENTO DEL RECIEN NACIDO</td>
                    </tr>
                    
                    <tr>
                        <td class="controls form-inline">
                            <b>Tipo nacimiento:</b>&nbsp;&nbsp;&nbsp;&nbsp;
                            <label class="pointer"><%=fb.radio("tipo_nacimiento","P",prop.getProperty("tipo_nacimiento")!=null&&prop.getProperty("tipo_nacimiento").equalsIgnoreCase("P"),false,false,"",null,null,null,"",null)%>
                            &nbsp;Parto
                            </label>
                            &nbsp;
                            <label class="pointer"><%=fb.radio("tipo_nacimiento","C",prop.getProperty("tipo_nacimiento")!=null&&prop.getProperty("tipo_nacimiento").equalsIgnoreCase("C"),false,false,"",null,null,null,"",null)%>
                            &nbsp;Ces&aacute;rea
                            </label>
                            
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <b>Motivos de la Ces&aacute;rea:</b>
                            <%=fb.textBox("motivos_cesarea", prop.getProperty("motivos_cesarea"),false,false,true,100,"form-control input-sm",null,null)%>
                            
                        </td>
                    </tr>
                    
                    <tr>
                        <td class="controls form-inline">
                            <b>Datos en el momento de nacer:</b>&nbsp;&nbsp;&nbsp;&nbsp;
                            
                            <b>Peso (gramos):</b>
                            <%=fb.textBox("peso", prop.getProperty("peso"),false,false,viewMode,7,"form-control input-sm",null,null)%>
                            
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            
                            <b>Talla (cm):</b>
                            <%=fb.textBox("talla", prop.getProperty("talla"),false,false,viewMode,7,"form-control input-sm",null,null)%>
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            
                            <b>APGAR:</b>
                            <%=fb.textBox("apgar", prop.getProperty("apgar"),false,false,viewMode,7,"form-control input-sm",null,null)%>
                            &nbsp;&nbsp;&nbsp;&nbsp;
                            
                            <b>Otros:</b>
                            <%=fb.textBox("otros_datos_nacer", prop.getProperty("otros_datos_nacer"),false,false,viewMode,40,"form-control input-sm",null,null)%>
                            
                        </td>
                    </tr>
                    
                    <tr class="bg-headtabla">
                        <td>LABORATORIOS RELEVANTES</td>
                    </tr>
                        
                    <tr>
                        <td class="controls form-inline">
                            <b>Tipaje sangu&iacute;neo y Rh de la madre:</b>&nbsp;&nbsp;&nbsp;&nbsp;
                            
                            <%=fb.select(ConMgr.getConnection(),"select ' ', '-SELECCIONE-' from dual union all select tipo_sangre, tipo_sangre from tbl_bds_tipo_sangre order by 1","tipaje_madre", prop.getProperty("tipaje_madre"), false, viewMode,0,"form-control input-sm",null,null)%>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <b>Tipaje sangu&iacute;neo y Rh del neonato:</b>
                            &nbsp;&nbsp;&nbsp;&nbsp;                                
                            <%=fb.select(ConMgr.getConnection(),"select ' ', '-SELECCIONE-' from dual union all select tipo_sangre, tipo_sangre from tbl_bds_tipo_sangre order by 1","tipaje_neonato", prop.getProperty("tipaje_neonato"), false, viewMode,0,"form-control input-sm",null,null)%>
                        </td>
                    </tr>
                    
                    <tr>
                        <td class="controls form-inline">
                            <b>Medicamentos recibidos:</b>&nbsp;&nbsp;&nbsp;&nbsp;
                            <label class="pointer"><%=fb.radio("medicamentos_recibidos","S",prop.getProperty("medicamentos_recibidos")!=null&&prop.getProperty("medicamentos_recibidos").equalsIgnoreCase("S"),false,false,"",null,null,null,"",null)%>
                            &nbsp;SI
                            </label>
                            &nbsp;
                            <label class="pointer"><%=fb.radio("medicamentos_recibidos","N",prop.getProperty("medicamentos_recibidos")!=null&&prop.getProperty("medicamentos_recibidos").equalsIgnoreCase("N"),false,false,"",null,null,null,"",null)%>
                            &nbsp;NO
                            </label>
                            
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <b>Detallar:</b>
                            <%=fb.textBox("medicamentos_recibidos_detalle", prop.getProperty("medicamentos_recibidos_detalle"),false,false,true,100,"form-control input-sm",null,null)%>
                        </td>
                    </tr> 
                    
                    <tr>
                        <td class="controls form-inline">
                            <b>Inmunizaciones recibidas:</b>&nbsp;&nbsp;&nbsp;&nbsp;
                            <label class="pointer"><%=fb.radio("inmunizaciones_recibidas","S",prop.getProperty("inmunizaciones_recibidas")!=null&&prop.getProperty("inmunizaciones_recibidas").equalsIgnoreCase("S"),false,false,"",null,null,null,"",null)%>
                            &nbsp;SI
                            </label>
                            &nbsp;
                            <label class="pointer"><%=fb.radio("inmunizaciones_recibidas","N",prop.getProperty("inmunizaciones_recibidas")!=null&&prop.getProperty("inmunizaciones_recibidas").equalsIgnoreCase("N"),false,false,"",null,null,null,"",null)%>
                            &nbsp;NO
                            </label>
                            
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <b>Detallar:</b>
                            <%=fb.textBox("inmunizaciones_recibidas_detalle", prop.getProperty("inmunizaciones_recibidas_detalle"),false,false,true,100,"form-control input-sm",null,null)%>
                        </td>
                    </tr>
                    
                    <tr>
                        <td class="controls form-inline">
                            <b>Evoluci&oacute;n m&eacute;dica:</b>&nbsp;&nbsp;&nbsp;&nbsp;
                            
                            <%=fb.textBox("evolucion_medica", prop.getProperty("evolucion_medica"),false,false,viewMode,100,"form-control input-sm",null,null)%>
                        </td>
                    </tr>
                    
                    <tr>
                        <td class="controls form-inline">
                            <b>Diagn&oacute;stico de egreso:</b>&nbsp;&nbsp;&nbsp;&nbsp;
                            
                            <%=fb.textBox("diag_ingreso",prop.getProperty("diag_ingreso"),false,false,true,10,"form-control input-sm",null,"")%>
                            <%=fb.textBox("diag_ingreso_desc",prop.getProperty("diag_ingreso_desc"),false,false,true,100,"form-control input-sm",null,"")%>
                            <%=fb.button("btn_dx","...",true,viewMode,null,null,"onClick=\"javascript:addDx()\"")%>
                        </td>
                    </tr>
                    
                    <tr class="bg-headtabla">
                        <td>CONDICI&Oacute;N DEL PACIENTE A SU EGRESO</td>
                    </tr>
                    
                    <tr>
                        <td class="controls form-inline">
                            <label class="pointer"><%=fb.radio("condicion_egreso","SA",prop.getProperty("condicion_egreso")!=null&&prop.getProperty("condicion_egreso").equalsIgnoreCase("SA"),false,false,"",null,null,null,"",null)%>
                            &nbsp;Sano
                            </label>
                            &nbsp;
                            <label class="pointer"><%=fb.radio("condicion_egreso","RE",prop.getProperty("condicion_egreso")!=null&&prop.getProperty("condicion_egreso").equalsIgnoreCase("RE"),false,false,"",null,null,null,"",null)%>
                            &nbsp;Recuperado
                            </label>
                            &nbsp;
                            <label class="pointer"><%=fb.radio("condicion_egreso","CO",prop.getProperty("condicion_egreso")!=null&&prop.getProperty("condicion_egreso").equalsIgnoreCase("CO"),false,false,"",null,null,null,"",null)%>
                            &nbsp;Convaleciente
                            </label>
                            &nbsp;
                            <label class="pointer"><%=fb.radio("condicion_egreso","DE",prop.getProperty("condicion_egreso")!=null&&prop.getProperty("condicion_egreso").equalsIgnoreCase("DE"),false,false,"",null,null,null,"",null)%>
                            &nbsp;Defunci&oacute;n
                            </label>
                            
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <b>Causas:</b>
                            <%=fb.textBox("causas_defuncion", prop.getProperty("causas_defuncion"),false,false,true,100,"form-control input-sm",null,null)%>
                        </td>
                    </tr> 
                    
                    <tr class="bg-headtabla">
                        <td>APLICA SI EL NEONATO NO TIENE DEFUNCION</td>
                    </tr>
                    
                    <tr class="defuncion_control">
                        <td class="controls form-inline">
                            <b>Peso (gramos):</b>
                            <%=fb.textBox("peso_muerto", prop.getProperty("peso_muerto"),false,false,viewMode,7,"form-control input-sm no_aplica_muerto",null,null)%>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;                            
                            <label class="pointer"><%=fb.radio("febril","S",prop.getProperty("febril")!=null&&prop.getProperty("febril").equalsIgnoreCase("S"),false,false,"no_aplica_muerto",null,null,null,"",null)%>
                            &nbsp;Febril
                            </label>
                            &nbsp;
                            <label class="pointer"><%=fb.radio("febril","N",prop.getProperty("febril")!=null&&prop.getProperty("febril").equalsIgnoreCase("N"),false,false,"no_aplica_muerto",null,null,null,"",null)%>
                            &nbsp;Afebril
                            </label>
                            
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
                            
                            <b>Uso de equipos especiales:</b>                           
                            <label class="pointer"><%=fb.radio("uso_equipos_esp","S",prop.getProperty("uso_equipos_esp")!=null&&prop.getProperty("uso_equipos_esp").equalsIgnoreCase("S"),false,false,"no_aplica_muerto",null,null,null,"",null)%>
                            &nbsp;SI
                            </label>
                            &nbsp;
                            <label class="pointer"><%=fb.radio("uso_equipos_esp","N",prop.getProperty("uso_equipos_esp")!=null&&prop.getProperty("uso_equipos_esp").equalsIgnoreCase("N"),false,false,"no_aplica_muerto",null,null,null,"",null)%>
                            &nbsp;NO
                            </label>
                            
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <b>Detallar:</b>
                            <%=fb.textBox("equipos_esp", prop.getProperty("equipos_esp"),false,false,true,60,"form-control input-sm no_aplica_muerto special",null,null)%>
                            
                        </td>
                    </tr>
                    
                    <tr class="bg-headtabla2 defuncion_control">
                        <td>&nbsp;&nbsp;&nbsp;CITA MEDICA DE SEGUIMIENTO</td>
                    </tr>
                    <tr class="defuncion_control">
                        <td class="controls form-inline">
                            <b>Doctor:</b>&nbsp;&nbsp;&nbsp;&nbsp;
                            <%=fb.textBox("doctor_nombre",prop.getProperty("doctor_nombre"),false,false,true,100,"form-control input-sm no_aplica_muerto",null,"")%>
                            <%=fb.button("btn_doc","...",true,viewMode,null,null,"onClick=showMedicoList(1)")%>
                        </td>
                    </tr> 
                    <tr class="defuncion_control">
                        <td class="controls form-inline">
                            <b>Pediatra/Neonat&oacute;logo:</b>&nbsp;&nbsp;&nbsp;&nbsp;
                            <%=fb.textBox("pediatra_neo",prop.getProperty("pediatra_neo"),false,false,true,100,"form-control input-sm no_aplica_muerto",null,"")%>
                            <%=fb.button("btn_ped","...",true,viewMode,null,null,"onClick=onClick=showMedicoList(2)")%>
                        </td>
                    </tr> 
                    <tr class="defuncion_control">
                        <td class="controls form-inline">
                            <b>Fecha de la cita:</b>&nbsp;&nbsp;&nbsp;&nbsp;
                            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1"/>
                            <jsp:param name="format" value="dd/mm/yyyy"/>
                            <jsp:param name="nameOfTBox1" value="fecha_cita" />
                            <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_cita")!=null?prop.getProperty("fecha_cita"):""%>" />
                            <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                            </jsp:include>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <b>Tel&eacute;fono de contacto:</b>&nbsp;
                            <%=fb.textBox("telefono_contacto", prop.getProperty("telefono_contacto"),false,false,viewMode,10,"form-control input-sm no_aplica_muerto",null,null)%>
                        </td>
                    </tr>
                    
                    <tr class="defuncion_control">
                        <td class="controls form-inline">
                            <b><em>Para el seguimiento o en caso de emergencia, favor contactar de inmediato al tel&eacute;fono</em>:</b>&nbsp;
                            <%=fb.textBox("telefono_contacto_seg", prop.getProperty("telefono_contacto_seg"),false,false,viewMode,10,"form-control input-sm no_aplica_muerto",null,null)%>
                            <b><em> o acudir al hospital m&aacute;s cercano si se presentan s&iacute;tomas como</em>:</b><br>
                            
                            <ul style="font-weight:bold; font-style:italic">
                                <li>Dificultad respiratoria</li>
                                <li>V&oacute;mitos persistentes</li>
                                <li>Llanto persistente inexplicable</li>
                                <li>Cambio de coloraci&oacute;n de la cara</li>
                                <li>Fiebre de inicio s&uacute;bito</li>
                            </ul>
                            
                        </td>
                    </tr> 
                    
                    <tr class="defuncion_control">
                        <td class="controls form-inline">
                            <b>Se educa a la persona responsable del paciente?</b>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <label class="pointer"><%=fb.radio("responsable_educado","S",prop.getProperty("responsable_educado")!=null&&prop.getProperty("responsable_educado").equalsIgnoreCase("S"),false,false,"no_aplica_muerto",null,null,null,"",null)%>
                            &nbsp;SI
                            </label>
                            &nbsp;
                            <label class="pointer"><%=fb.radio("responsable_educado","N",prop.getProperty("responsable_educado")!=null&&prop.getProperty("responsable_educado").equalsIgnoreCase("N"),false,false,"no_aplica_muerto",null,null,null,"",null)%>
                            &nbsp;NO
                            </label>
                        </td>
                    </tr>
                    
                    <tr class="defuncion_control">
                        <td class="controls form-inline">
                            <b>Se dan las recomendaciones generales junto con la entrega de las notas de cuidado (carenotes)?</b>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <label class="pointer"><%=fb.radio("recomendaciones","S",prop.getProperty("recomendaciones")!=null&&prop.getProperty("recomendaciones").equalsIgnoreCase("S"),false,false,"no_aplica_muerto",null,null,null,"",null)%>
                            &nbsp;SI
                            </label>
                            &nbsp;
                            <label class="pointer"><%=fb.radio("recomendaciones","N",prop.getProperty("recomendaciones")!=null&&prop.getProperty("recomendaciones").equalsIgnoreCase("N"),false,false,"no_aplica_muerto",null,null,null,"",null)%>
                            &nbsp;NO
                            </label>
                        </td>
                    </tr>
                    
                    
                    
                    
                    
                    
                    
                    
                    
                </table>
                
                <div class="footerform">
                    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                        <tr>
                            <td>
                                <%=fb.hidden("saveOption", "O")%>
                                <%=fb.submit("save","Guardar",viewMode,false,"",null,"")%>
                                <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
                            </td>
                        </tr>
                    </table> 
                </div>
                
                <%=fb.hidden("fecha_creacion", prop.getProperty("fecha_creacion")!=null&&!prop.getProperty("fecha_creacion").equals("")?prop.getProperty("fecha_creacion"):cDateTime)%>
                <%=fb.hidden("usuario_creacion", prop.getProperty("usuario_creacion")!=null&&!prop.getProperty("usuario_creacion").equals("")?prop.getProperty("usuario_creacion"):((String) session.getAttribute("_userName")))%>
                <%=fb.formEnd(true)%>
            </div>
            <!-- Generales -->
            
            <div role="tabpanel" class="tab-pane <%=active1%>" id="otros_laboratorios">
            <%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
            <%=fb.formStart(true)%>
            <%=fb.hidden("baction","")%>
            <%=fb.hidden("mode",mode)%>
            <%=fb.hidden("modeSec",modeSec)%>
            <%=fb.hidden("seccion",seccion)%>
            <%=fb.hidden("pacId",pacId)%>
            <%=fb.hidden("noAdmision",noAdmision)%>
            <%=fb.hidden("desc",desc)%>
            <%=fb.hidden("fg",fg)%>
            <%=fb.hidden("tab","1")%>
            
            <%
            ArrayList alN = SQLMgr.getDataList("select nota, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion_dsp from tbl_sal_sumario_eg_med_res_lab where pac_id = "+pacId+" and admision = "+noAdmision+" order by fecha_creacion desc");
            %>
            
            <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                <tr class="bg-headtabla2">
                    <td colspan="2">&nbsp;</td>
                </tr>
                <%if(!mode.equalsIgnoreCase("view")){%>
                    <tr>
                        <td colspan="2">
                            <b>Resultado:</b>&nbsp;
                            <%=fb.textarea("nota","",false,false,false,50,1,2000,"form-control input-sm","width='100%'",null)%>
                        </td>
                    </tr>
                    <%=fb.hidden("action","I")%>
                <%}%>
                
                <%for(int i = 0; i < alN.size(); i++){
                    cdo = (CommonDataObject) alN.get(i);
                %>
                    <tr>
                        <td><b><%=cdo.getColValue("fecha_creacion_dsp")%></b></td>
                        <td>
                            <%=fb.textarea("nota"+i,cdo.getColValue("nota"),false,false,true,50,1,2000,"form-control input-sm","width='100%'",null)%>
                        </td>
                    </tr>
                <%}%>
            </table>

        <div class="footerform">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
               <td>
                    <%=fb.hidden("saveOption","O")%>
                    <%=fb.submit("save","Guardar",true,mode.equalsIgnoreCase("view"),"",null,"")%>
                    <%=fb.button("cancel","Cancelar",false,false,null,null,"onclick=\"parent.doRedirect(0)\"")%>
                </td>
            </tr>
            </table>   
        </div>
        <%=fb.formEnd(true)%>
        </div>
        
        <!-- Procedimientos -->
    <div role="tabpanel" class="tab-pane <%=active2%>" id="procedimientos">
    
        <%fb = new FormBean2("form2",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
         <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
         <%=fb.formStart(true)%>
         <%=fb.hidden("baction","")%>
         <%=fb.hidden("mode",mode)%>
         <%=fb.hidden("modeSec",modeSec)%>
         <%=fb.hidden("seccion",seccion)%>
         <%=fb.hidden("pacId",pacId)%>
         <%=fb.hidden("noAdmision",noAdmision)%>
         <%=fb.hidden("tab","2")%>
         <%=fb.hidden("procSize",""+iProcInTra.size())%>
         <%=fb.hidden("desc",desc)%>
         <%=fb.hidden("fg",fg)%>
         <table cellspacing="0" class="table table-small-font table-bordered">
        <tr class="bg-headtabla2">
            <td width="05%"><cellbytelabel id="4">C&oacute;digo</cellbytelabel></td>
            <td width="90%"><cellbytelabel id="15">Procedimiento</cellbytelabel></td>
            <td width="05%" align="center"><%=fb.submit("addProc","+",false,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"","Agregar Procedimientos")%></td>
        </tr>
        <%
        al = CmnMgr.reverseRecords(iProcInTra);
        for (int i=0; i<iProcInTra.size(); i++)
        {
          key = al.get(i).toString();
          CommonDataObject cdo1 = (CommonDataObject) iProcInTra.get(key);
        %>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("codigo"+i,""+cdo1.getColValue("codigo"))%>
			<%=fb.hidden("code"+i,""+cdo1.getColValue("code"))%>
			<%=fb.hidden("action"+i,cdo1.getAction())%>
			<%=fb.hidden("key"+i,cdo1.getKey())%>
			<%if(cdo1.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("procedimiento"+i,cdo1.getColValue("procedimiento"))%>
			 <%=fb.hidden("descProc"+i,cdo1.getColValue("descProc"))%>
			<%}else{%>
            <tr class="TextRow01">
            <td><%=fb.textBox("procedimiento"+i,cdo1.getColValue("procedimiento"),true,false,true,10,"form-control input-sm","","")%></td>
            <td><%=fb.textBox("descProc"+i,cdo1.getColValue("descProc"),false,false,true,70,"form-control input-sm","","")%></td>
            <td align="center"><%=fb.submit("rem"+i,"x",true,viewMode,null,null,"onClick=\"javascript:removeItem(this.form.name,"+i+");__submitForm(this.form, this.name)\"","Eliminar.")%></td>
            </tr>
            <%	}}%>
            
            </table>
            
            <div class="footerform" style="bottom:-11px !important">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
                <td>
                    <%=fb.hidden("saveOption", "O")%>
                    <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
               </td>
            </tr>
        </table>   
    </div>
    <%=fb.formEnd(true)%>

    </div>
    
    <div role="tabpanel" class="tab-pane <%=active3%>" id="medicamentos">
            <%fb = new FormBean2("form3",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
            <%=fb.formStart(true)%>
            <%=fb.hidden("baction","")%>
            <%=fb.hidden("mode",mode)%>
            <%=fb.hidden("modeSec",modeSec)%>
            <%=fb.hidden("seccion",seccion)%>
            <%=fb.hidden("pacId",pacId)%>
            <%=fb.hidden("noAdmision",noAdmision)%>
            <%=fb.hidden("desc",desc)%>
            <%=fb.hidden("fg",fg)%>
            <%=fb.hidden("tab","3")%>
            
            <%
            ArrayList alM = SQLMgr.getDataList("select nota, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion_dsp from tbl_sal_sumario_eg_med_medica where pac_id = "+pacId+" and admision = "+noAdmision+" order by fecha_creacion desc");
            %>
            
            <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                <tr class="bg-headtabla2">
                    <td colspan="2">&nbsp;</td>
                </tr>
                <%if(!mode.equalsIgnoreCase("view")){%>
                    <tr>
                        <td colspan="2">
                            <b>Medicamento:</b>&nbsp;
                            <%=fb.textarea("nota","",false,false,false,50,1,2000,"form-control input-sm","width='100%'",null)%>
                        </td>
                    </tr>
                    <%=fb.hidden("action","I")%>
                <%}%>
                
                <%for(int i = 0; i < alM.size(); i++){
                    cdo = (CommonDataObject) alM.get(i);
                %>
                    <tr>
                        <td><b><%=cdo.getColValue("fecha_creacion_dsp")%></b></td>
                        <td>
                            <%=fb.textarea("nota"+i,cdo.getColValue("nota"),false,false,true,50,1,2000,"form-control input-sm","width='100%'",null)%>
                        </td>
                    </tr>
                <%}%>
            </table>

        <div class="footerform">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
               <td>
                    <%=fb.hidden("saveOption","O")%>
                    <%=fb.submit("save","Guardar",true,mode.equalsIgnoreCase("view"),"",null,"")%>
                    <%=fb.button("cancel","Cancelar",false,false,null,null,"onclick=\"parent.doRedirect(0)\"")%>
                </td>
            </tr>
            </table>   
        </div>
        <%=fb.formEnd(true)%>
        </div>
        
        
        <!-- Documentos -->
        <div role="tabpanel" class="tab-pane <%=active4%>" id="documentos">
        
           <table width="100%" cellpadding="1" cellspacing="1" >
                <tr>
                    <td>
                        <iframe id="doc_esc" name="doc_esc" width="100%" scrolling="yes" frameborder="0" src="../expediente3.0/exp_documentos.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&exp=3&expStatus=<%=request.getParameter("estado")!=null?request.getParameter("estado"):""%>&area_revision=SL&docs_for=sumario_egreso_med_neo&docId=44"></iframe>
                    </td>
                </tr>
            </table>

        </div>
        
        </div> <!-- Tab panes -->
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
    
    String errorCode = "", errorMsg = "";
    
    if (tab.trim().equals("0")){
        prop = new Properties();
    
        prop.setProperty("pac_id",request.getParameter("pacId"));
        prop.setProperty("admision",request.getParameter("noAdmision"));
        prop.setProperty("tipo_sumario",request.getParameter("fg"));
        prop.setProperty("usuario_modificacion", (String) session.getAttribute("_userName"));
        prop.setProperty("fecha_modificacion", cDateTime);
        prop.setProperty("usuario_creacion", request.getParameter("usuario_creacion"));
        prop.setProperty("fecha_creacion", request.getParameter("fecha_creacion"));
        prop.setProperty("fecha_egreso", request.getParameter("fecha_egreso"));
        prop.setProperty("dias_hospitalizados", request.getParameter("dias_hospitalizados"));
        prop.setProperty("diagnostico_ingreso", request.getParameter("diagnostico_ingreso"));
        prop.setProperty("tipo_nacimiento", request.getParameter("tipo_nacimiento"));
        prop.setProperty("motivos_cesarea", request.getParameter("motivos_cesarea"));
        prop.setProperty("peso", request.getParameter("peso"));
        prop.setProperty("talla", request.getParameter("talla"));
        prop.setProperty("apgar", request.getParameter("apgar"));
        prop.setProperty("otros_datos_nacer", request.getParameter("otros_datos_nacer"));
        prop.setProperty("tipaje_madre", request.getParameter("tipaje_madre"));
        prop.setProperty("tipaje_neonato", request.getParameter("tipaje_neonato"));
        prop.setProperty("medicamentos_recibidos", request.getParameter("medicamentos_recibidos"));
        prop.setProperty("medicamentos_recibidos_detalle", request.getParameter("medicamentos_recibidos_detalle"));
        prop.setProperty("inmunizaciones_recibidas", request.getParameter("inmunizaciones_recibidas"));
        prop.setProperty("inmunizaciones_recibidas_detalle", request.getParameter("inmunizaciones_recibidas_detalle"));
        prop.setProperty("evolucion_medica", request.getParameter("evolucion_medica"));
        prop.setProperty("diag_ingreso", request.getParameter("diag_ingreso"));
        prop.setProperty("diag_ingreso_desc", request.getParameter("diag_ingreso_desc"));
        prop.setProperty("condicion_egreso", request.getParameter("condicion_egreso"));
        prop.setProperty("causas_defuncion", request.getParameter("causas_defuncion"));
        
        if (request.getParameter("condicion_egreso") != null && !request.getParameter("condicion_egreso").equals("DE")){
            prop.setProperty("peso_muerto", request.getParameter("peso_muerto"));
            prop.setProperty("febril", request.getParameter("febril"));
            prop.setProperty("uso_equipos_esp", request.getParameter("uso_equipos_esp"));
            prop.setProperty("equipos_esp", request.getParameter("equipos_esp"));
            prop.setProperty("doctor_nombre", request.getParameter("doctor_nombre"));
            prop.setProperty("pediatra_neo", request.getParameter("pediatra_neo"));
            prop.setProperty("fecha_cita", request.getParameter("fecha_cita"));
            prop.setProperty("telefono_contacto", request.getParameter("telefono_contacto"));
            prop.setProperty("telefono_contacto_seg", request.getParameter("telefono_contacto_seg"));
            prop.setProperty("responsable_educado", request.getParameter("responsable_educado"));
            prop.setProperty("recomendaciones", request.getParameter("recomendaciones"));
        }
            
        if (baction.equalsIgnoreCase("Guardar")){
            ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
            if (modeSec.equalsIgnoreCase("add")) SumarioEgMed.add(prop);
            else SumarioEgMed.update(prop);
            ConMgr.clearAppCtx(null);
        }
        
        errorCode = SumarioEgMed.getErrCode();
        errorMsg = SumarioEgMed.getErrMsg();
        
    } // tab 0 
    else if (tab.trim().equals("1")) {
        
        cdo = new CommonDataObject();
        cdo.setTableName("tbl_sal_sumario_eg_med_res_lab");
        cdo.addColValue("nota", request.getParameter("nota"));
        
        if (request.getParameter("action") != null && request.getParameter("action").equalsIgnoreCase("I")) {
            cdo.addColValue("pac_id", pacId);
            cdo.addColValue("admision", noAdmision);
            cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
            cdo.addColValue("fecha_creacion", cDateTime);
            cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
            cdo.addColValue("fecha_modificacion", cDateTime);
            
            ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
            SQLMgr.insert(cdo);
            ConMgr.clearAppCtx(null);
            
        } else {
            cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision"));
            cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
            cdo.addColValue("fecha_modificacion", cDateTime);
            
            ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
            SQLMgr.update(cdo);
            ConMgr.clearAppCtx(null);
        }
        
        errorCode = SQLMgr.getErrCode();
        errorMsg = SQLMgr.getErrMsg();
    } 
    
    else if (tab.equals("2")) //Procedimientos.
    {
        int size = 0;
		if (request.getParameter("procSize") != null) size = Integer.parseInt(request.getParameter("procSize"));
		String itemRemoved = "",removedItem ="";
		al.clear();
		vProcInTra.clear();
		iProcInTra.clear();
        
		for (int i=0; i<size; i++){
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_sumario_egres_med_proc");
            cdo.setWhereClause("codigo = "+request.getParameter("codigo"+i)+" and pac_id = "+pacId+" and admision = "+noAdmision);

            if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals("")) {
                cdo.setAutoIncCol("codigo");
                cdo.setAutoIncWhereClause("pac_id = "+pacId+" and admision = "+noAdmision);
            }
            cdo.addColValue("codigo",request.getParameter("codigo"+i));
            cdo.addColValue("procedimiento",request.getParameter("procedimiento"+i));
            cdo.addColValue("descProc",request.getParameter("descProc"+i));
            cdo.addColValue("pac_id", pacId);
            cdo.addColValue("admision", noAdmision);

            cdo.setAction(request.getParameter("action"+i));
            cdo.setKey(i);
            if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {
                itemRemoved = cdo.getKey();
                if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");
                else cdo.setAction("D");
            }
			
            if (!cdo.getAction().equalsIgnoreCase("X")) {
                try
                {
                    iProcInTra.put(cdo.getKey(),cdo);
                    if(!cdo.getAction().trim().equals("D")) vProcInTra.add(cdo.getColValue("procedimiento"));
                    al.add(cdo);
                }
                catch(Exception e)
                {
                    System.err.println(e.getMessage());
                }
            }
		}
		if(!itemRemoved.equals("")) {
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&fg="+fg+"&desc="+desc);
            return;
		}
		if(baction.equals("+"))//Agregar
		{
            response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=2&tab=2&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&fg="+fg+"&desc="+desc);
            return;
		}
		if (baction.equalsIgnoreCase("Guardar")){
			if (al.size() == 0) {
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_sumario_egres_med_proc");
				cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision);
				cdo.setAction("I");
				al.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
            
            errorCode = SQLMgr.getErrCode();
            errorMsg = SQLMgr.getErrMsg();
		}   
	}
    
    else if (tab.trim().equals("3")) {
        
        cdo = new CommonDataObject();
        cdo.setTableName("tbl_sal_sumario_eg_med_medica");
        cdo.addColValue("nota", request.getParameter("nota"));
        
        if (request.getParameter("action") != null && request.getParameter("action").equalsIgnoreCase("I")) {
            cdo.addColValue("pac_id", pacId);
            cdo.addColValue("admision", noAdmision);
            cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
            cdo.addColValue("fecha_creacion", cDateTime);
            cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
            cdo.addColValue("fecha_modificacion", cDateTime);
            
            ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
            SQLMgr.insert(cdo);
            ConMgr.clearAppCtx(null);
            
        } else {
            cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision"));
            cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
            cdo.addColValue("fecha_modificacion", cDateTime);
            
            ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
            SQLMgr.update(cdo);
            ConMgr.clearAppCtx(null);
        }
        
        errorCode = SQLMgr.getErrCode();
        errorMsg = SQLMgr.getErrMsg();
    } 
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (errorCode.equals("1"))
{
%>
	alert('<%=errorMsg%>');
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
} else throw new Exception(errorMsg);
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&tab=<%=tab%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>