<%// @ page errorPage="../error.jsp"%>
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
<jsp:useBean id="RECANESMgr" scope="page" class="issi.expediente.RecuperacionAnestesiaSOPMgr" />
<%

SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
RECANESMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String desc = request.getParameter("desc");
String change = request.getParameter("change");
String code = request.getParameter("code");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = (String) session.getAttribute("_userName");

String active0 = "", active1 = "", active2 = "";

if(code == null)code = "0";
if (fg == null) fg = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (tab == null) tab = "0";

if (request.getMethod().equalsIgnoreCase("GET")) {
ArrayList al2 = new ArrayList();

if (tab.equals("0")) active0 = "active";
else if (tab.equals("1")) active1 = "active";
else if (tab.equals("2")) active2 = "active";

Properties prop = new Properties();
prop = SQLMgr.getDataProperties("select params from tbl_sal_recup_anes_sop where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+code);
if (prop == null) prop = new Properties();

al2 = SQLMgr.getDataPropertiesList("select params from tbl_sal_recup_anes_sop where pac_id = "+pacId+" and admision = "+noAdmision+" order by codigo desc");

String idCirugia = request.getParameter("id_cirugia");
if (idCirugia == null) idCirugia = "0";

ArrayList alMed = SQLMgr.getDataList("select codigo, to_char(hora_registro,'dd/mm/yyyy hh12:mi:ss am') hora_registro, upper(medicamento)medicamento, 'U' action from tbl_sal_recup_anes_sop_med where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" order by codigo");

ArrayList alTra = SQLMgr.getDataList("select codigo, to_char(hora_registro,'dd/mm/yyyy hh12:mi:ss am') hora_registro, upper(tratamiento)tratamiento, 'U' action from tbl_sal_recup_anes_sop_tra where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" order by codigo");

ArrayList alNEF = SQLMgr.getDataList("select codigo, to_char(hora_registro,'dd/mm/yyyy hh12:mi:ss am') hora_registro, upper(nota)nota, 'U' action from tbl_sal_recup_anes_sop_nef where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" order by codigo");

if (prop!=null&&prop.getProperty("hora_salida")!=null&&!prop.getProperty("hora_salida").equals("")) viewMode = true;

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
function doAction() {}
function verHistorial() {
  $("#hist_container").toggle();
}
function setProtocolo(code, horaSalida){
    var modeSec = horaSalida?'view':'edit';
    window.location = '../expediente3.0/exp_recuperacion_anes_sop.jsp?modeSec='+modeSec+'&seccion=<%=seccion%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&code='+code;
}
function add(){
    window.location = '../expediente3.0/exp_recuperacion_anes_sop.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=0&desc=<%=desc%>';
}

//hist_cli_pre_ope
function procedimientoList(){
    abrir_ventana1('../expediente/listado_procedimiento.jsp?fp=recuperacion_anes_sop');
}

function showAnesList(opt){
    var fg = '';
    if (opt == 1) fg = '&fg=ANES';
    else if (opt == 2) fg = '&fg=CIR';
    abrir_ventana1('../common/search_medico.jsp?fp=recuperacion_anes_sop'+fg);
}

function showEmpleadoList(fg){
    var obj = {
        'CIR': 'circulador',
        'ENF': 'enfermera',
        'ASIS': 'asistente',
        'ENFREC': 'recup_enfer',
        'ENFREL': 'relev_enfer',
    };
    $("input[name*='"+obj[fg]+"']").val("");
    abrir_ventana1('../common/search_empleado.jsp?fp=recuperacion_anes_sop&fg='+fg);
}

function doSubmit () {
  var totalhe = totalmin15 = totalmin30 = totalmin60 = totalmin90 = totalmin120 =  totalhs = 0;
  $(".escala-type").each(function(){
    var self = $(this);
    var type = self.data("type");
   
    if (type == 'he') {
     var val = self.val() || '0';
     totalhe = totalhe + parseInt(val, 10);
    } 
    if (type == 'min15') {
      var val = self.val() || '0';
      totalmin15 = totalmin15 + parseInt(val, 10);
    }
    if (type == 'min30') {
      var val = self.val() || '0';
      totalmin30 = totalmin30 + parseInt(val, 10);
    }
    if (type == 'min60') {
      var val = self.val() || '0';
      totalmin60 = totalmin60 + parseInt(val, 10);
    }
    if (type == 'min90') {
      var val = self.val() || '0';
      totalmin90 = totalmin90 + parseInt(val, 10);
    }
    if (type == 'min120') {
      var val = self.val() || '0';
      totalmin120 = totalmin120 + parseInt(val, 10);
    }
    if (type == 'hs') {
      var val = self.val() || '0';
      totalhs = totalhs + parseInt(val, 10);
    }
  });
  $("#totalhe").val(totalhe)
  $("#totalmin15").val(totalmin15)
  $("#totalmin30").val(totalmin30)
  $("#totalmin60").val(totalmin60)
  $("#totalmin90").val(totalmin90)
  $("#totalmin120").val(totalmin120)
  $("#totalhs").val(totalhs)

  __submitForm(document.getElementById("form1"), 'Guardar')
}

function permitirEgreso() {
    var totalAldrete = parseInt($("#total_aldrete").val()||'0');
    if ($("#hora_salida").val()) {
        return totalAldrete >= 9;
    } else {
        return true;
    }
}

function imprimirEspecimen () {
 var totalAldrete = $("#totalhs").val();
 abrir_ventana1("../expediente3.0/exp_print_recuperacion_anes_sop.jsp?seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>");
}

$(function(){
    $("input[type='checkbox'][name*='anestesia']").click(function(){
        if (this.checked) $("#"+this.name+"_desc").prop("readOnly", false);
        else $("#"+this.name+"_desc").prop("readOnly", true).val("");
    });
    
    var index1 = 0;
    var index2 = 0;
    var index3 = 0;
    $("#btn_med").click(function(){
        index1 = index1 + 1 + <%=alMed.size()%>;
        var $tplMed = $("#tpl-med");
        var tplMedStr = $tplMed.html().toString();
        tplMedStr = tplMedStr.replace(/@@index/g, index1);
        $tplMed.after('<tr>'+tplMedStr+'</tr>');
        
        $("#total_med").val(index1);
    });
    
    $("#btn_tra").click(function(){
        index2 = index2 + 1 + <%=alTra.size()%>;
        var $tplMed = $("#tpl-tra");
        var tplMedStr = $tplMed.html().toString();
        tplMedStr = tplMedStr.replace(/@@index/g, index2);
        $tplMed.after('<tr>'+tplMedStr+'</tr>');
        
        $("#total_tra").val(index2);
    });
    
    $("#btn_nef").click(function(){
        index3 = index3 + 1 + <%=alNEF.size()%>;
        var $tplMed = $("#tpl-nef");
        var tplMedStr = $tplMed.html().toString();
        tplMedStr = tplMedStr.replace(/@@index/g, index3);
        $tplMed.after('<tr>'+tplMedStr+'</tr>');
        
        $("#total_nef").val(index3);
    });
    
    // reloading alerts
  if (typeof parent.reloadAlerts === 'function') parent.reloadAlerts();
  else if (typeof parent.parent.reloadAlerts === 'function') parent.parent.reloadAlerts();
  
  $("input:radio[name='egresado_a']").click(function(e){
    var horaEgreso = $("#hora_salida").val();
    if (!horaEgreso) {
        e.preventDefault();
        return false;
    }
  });
  
  //
  $(".cod-header").each(function(){
    var codHeader = $(this).val();
    var $select = $("select[class*='escala-x-header-"+codHeader+"-']");
    $select.change(function(){
        var self = $(this);
        var tipo = self.data('type');
        debug(tipo)
        var $not2besel = $select.not(self);
        $select.not(self).each(function(){
          var that = $(this);
          var _tipo = that.data('type')
          if(_tipo==tipo)this.value = ''
        })
    });
  });
  
});
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

    <div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-2">
        <tr>
            <td class="controls form-inline">
                <button type="button" class="btn btn-inverse btn-sm" onclick="imprimirEspecimen()">
                    <i class="fa fa-print fa-printico"></i> <b>Imprimir</b>
                </button>
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
    
    <div class="table-wrapper" id="hist_container" style="display:none">
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
            <tr class="bg-headtabla2">
                <td><cellbytelabel>C&oacute;digo</cellbytelabel></td>
                <td><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
                <td><cellbytelabel>Usuario Creaci&oacute;n</cellbytelabel></td>
                <td><cellbytelabel>Hora Entreda</cellbytelabel></td>
                <td><cellbytelabel>Hora Salida</cellbytelabel></td>
            </tr>
            <% for (int i=1; i<=al2.size(); i++) {
                Properties cdo2 = (Properties) al2.get(i-1);
            %>
			<tr class="pointer" onClick="javascript:setProtocolo('<%=cdo2.getProperty("codigo")%>')">
                <td><%=cdo2.getProperty("codigo")%></td>
                <td><%=cdo2.getProperty("fecha_creacion")%></td>
                <td><%=cdo2.getProperty("usuario_creacion")%>/<%=cdo2.getProperty("usuario_modificacion")%></td>
                <td><%=cdo2.getProperty("hora_entrada")%></td>
                <td><%=cdo2.getProperty("hora_salida")%></td>
			</tr>
            <%}%>
        </table>
    </div>
</div>

<ul class="nav nav-tabs" role="tablist">
    <li role="presentation" class="<%=active0%>">
        <a href="#generales" aria-controls="generales" role="tab" data-toggle="tab"><b>Datos Generales</b></a>
    </li>
    <%if (!modeSec.equalsIgnoreCase("add")){%>
    <li role="presentation" class="<%=active1%>">
        <a href="#test_de_recuperacion" aria-controls="test_de_recuperacion" role="tab" data-toggle="tab"><b>Test de Recuperaci&oacute;n de Anestesia - Sedacion</b></a>
    </li>
    <%}%>
</ul>

    <!-- Tab panes -->
    <div class="tab-content">
  
        <!-- Generales -->
        <div role="tabpanel" class="tab-pane <%=active0%>" id="generales">
            <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
            <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
            <%fb.appendJsValidation("if(!permitirEgreso()){error++;CBMSG.error('El total de Aldrete es menor a 9. Por ende, no puede dale egreso al paciente!')}");%>
            <%=fb.formStart(true)%>
            <%=fb.hidden("baction","")%>
            <%=fb.hidden("mode",mode)%>
            <%=fb.hidden("modeSec",modeSec)%>
            <%=fb.hidden("seccion",seccion)%>
            <%=fb.hidden("pacId",pacId)%>
            <%=fb.hidden("noAdmision",noAdmision)%>
            <%=fb.hidden("desc",desc)%>
            <%=fb.hidden("code",code)%>
            <%=fb.hidden("tab", "0")%>
            
            <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                <tr>
                  <td class="controls form-inline">
                    <b>Operaci&oacute;n:</b>
                    <%=fb.hidden("procedimiento",prop.getProperty("cod_proc"))%>
                    <%=fb.textBox("desc_proc", prop.getProperty("desc_proc"),false,false,true,150,"form-control input-sm","",null)%>
                    <%=fb.button("oper","...",true,viewMode,null,null,"onClick=\"javascript:procedimientoList()\"","seleccionar Operación")%>
                  </td>
                </tr>
                
                <tr>
                  <td class="controls form-inline">
                    <b>Anestesia:</b>
                    &nbsp;
                    <label class="pointer">
                    <%=fb.checkbox("anestesia0","ET",prop.getProperty("anestesia0").equalsIgnoreCase("ET"),viewMode,null,null,"")%>&nbsp;ET</label>
                    &nbsp;<%=fb.textBox("anestesia0_desc",prop.getProperty("anestesia0_desc"),false,false,true,10,"form-control input-sm","",null)%>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer">
                    <%=fb.checkbox("anestesia1","BM",prop.getProperty("anestesia1").equalsIgnoreCase("BM"),viewMode,null,null,"")%>&nbsp;BM</label>
                    &nbsp;<%=fb.textBox("anestesia1_desc",prop.getProperty("anestesia0_desc"),false,false,true,10,"form-control input-sm","",null)%>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer">
                    <%=fb.checkbox("anestesia2","REGIONAL",prop.getProperty("anestesia2").equalsIgnoreCase("REGIONAL"),viewMode,null,null,"")%>&nbsp;REGIONAL</label>
                    &nbsp;<%=fb.textBox("anestesia2_desc",prop.getProperty("anestesia0_desc"),false,false,true,10,"form-control input-sm","",null)%>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer">
                    <%=fb.checkbox("anestesia3","SEDACION",prop.getProperty("anestesia3").equalsIgnoreCase("SEDACION"),viewMode,null,null,"")%>&nbsp;SEDACION</label>
                    &nbsp;<%=fb.textBox("anestesia3_desc",prop.getProperty("anestesia0_desc"),false,false,true,10,"form-control input-sm","",null)%>
                  </td>
                </tr>
                
                <tr>
                    <td class="controls form-inline">
                    <b>Anestesi&oacute;logo:</b>&nbsp;
                    <%=fb.hidden("anestesiologo",prop.getProperty("anestesiologo"))%>
                    <%=fb.textBox("anestesiologoNombre",prop.getProperty("anestesiologoNombre"),true,false,viewMode,30,0,"form-control input-sm","","")%>
                    <%=fb.button("btnAnes","...",true,viewMode,null,null,"onClick=\"javascript:showAnesList(1)\"","Anestesiologo")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <b>Enfermera de Anestesia:</b>&nbsp;
                    <%=fb.hidden("enfermera_anes", prop.getProperty("enfermera_anes"))%>
                    <%=fb.textBox("enfermera_nombre_anes",prop.getProperty("enfermera_nombre_anes"),false,false,viewMode,45,0,"form-control input-sm","","")%>
                    <%=fb.button("btn_enfermera_anes","...",true,viewMode,null,null,"onClick=showEmpleadoList('ENF')","")%>
                    </td>
                </tr>
                
                <tr>
                    <td class="controls form-inline">
                    <b>Cirujano:</b>&nbsp;
                    <%=fb.hidden("cirujano",prop.getProperty("cirujano"))%>
                    <%=fb.textBox("cirujanoNombre",prop.getProperty("cirujanoNombre"),true,false,viewMode,30,0,"form-control input-sm","","")%>
                    <%=fb.button("btnCir","...",true,viewMode,null,null,"onClick=\"javascript:showAnesList(2)\"","Cirujano")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <b>Asistente:</b>&nbsp;
                    <%=fb.hidden("asistente", prop.getProperty("asistente"))%>
                    <%=fb.textBox("asistente_nombre",prop.getProperty("asistente_nombre"),false,false,viewMode,45,0,"form-control input-sm","","")%>
                    <%=fb.button("asistente_bnt","...",true,viewMode,null,null,"onClick=showEmpleadoList('ASIS')","")%>
                    </td>
                </tr>
                
                <tr>
                    <td class="controls form-inline">
                    <b>Enfermera de recuperaci&oacute;n:</b>&nbsp;
                    <%=fb.hidden("recup_enfer",prop.getProperty("recup_enfer"))%>
                    <%=fb.textBox("recup_enfer_nombre",prop.getProperty("recup_enfer_nombre"),true,false,viewMode,30,0,"form-control input-sm","","")%>
                    <%=fb.button("btnEnfRec","...",true,viewMode,null,null,"onClick=showEmpleadoList('ENFREC')","Enfermera de Recuperación")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    
                    <b><cellbytelabel id="15">Hora Entrada</cellbytelabel></b>:&nbsp;
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="hora_entrada" />
                    <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora_entrada")%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                    </jsp:include>
                    
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    
                    <b><cellbytelabel id="15">Hora Salida</cellbytelabel></b>:&nbsp;
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="hora_salida" />
                    <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora_salida")%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                    </jsp:include>
                    
                    
                    </td>
                </tr>
                
                <tr>
                    <td class="controls form-inline">
                    <b>Egresado a:</b>&nbsp;
                    <label class="pointer"><%=fb.radio("egresado_a","C",prop.getProperty("egresado_a")!=null&&prop.getProperty("egresado_a").equalsIgnoreCase("C"),viewMode,false,null,null,"")%>&nbsp;<b>Casa</b></label>&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("egresado_a","H",prop.getProperty("egresado_a")!=null&&prop.getProperty("egresado_a").equalsIgnoreCase("H"),viewMode,false,null,null,"")%>&nbsp;<b>Hospital</b></label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    
                    <b>Enfermera que releva:</b>&nbsp;
                    <%=fb.hidden("relev_enfer",prop.getProperty("relev_enfer"))%>
                    <%=fb.textBox("relev_enfer_nombre",prop.getProperty("relev_enfer_nombre"),false,false,viewMode,60,0,"form-control input-sm","","")%>
                    <%=fb.button("btnCir","...",true,viewMode,null,null,"onClick=showEmpleadoList('ENFREL')","Enfermera relevante")%>
                    </td>
                </tr>
                    
            </table>
            <div class="footerform">
                <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                    <tr>
                    <td>
                        <%=fb.hidden("saveOption","O")%>        
                        <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                    </td>
                    </tr>
                </table>   
            </div>
            <%=fb.hidden("fecha_creacion", prop.getProperty("fecha_creacion")!=null&&!prop.getProperty("fecha_creacion").equals("")?prop.getProperty("fecha_creacion"):cDateTime )%>
            <%=fb.hidden("usuario_creacion", prop.getProperty("usuario_creacion")!=null&&!prop.getProperty("usuario_creacion").equals("")?prop.getProperty("usuario_creacion"):userName )%>
            <%=fb.formEnd(true)%>
        </div> <!-- Generales -->
        
        <!-- Test de Recuperación -->
        <div role="tabpanel" class="tab-pane <%=active1%>" id="test_de_recuperacion">
            <%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
            <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
            <%=fb.formStart(true)%>
            <%=fb.hidden("baction","")%>
            <%=fb.hidden("mode",mode)%>
            <%=fb.hidden("modeSec",modeSec)%>
            <%=fb.hidden("seccion",seccion)%>
            <%=fb.hidden("pacId",pacId)%>
            <%=fb.hidden("noAdmision",noAdmision)%>
            <%=fb.hidden("desc",desc)%>
            <%=fb.hidden("code",code)%>
            <%=fb.hidden("tab", "1")%>
            <%=fb.hidden("gen_alerta", "")%>
            
            <table cellspacing="0" class="table table-small-font table-bordered table-striped" width="100%">
            
            <tr class="bg-headtabla2" align="center" width="100%">
                <td colspan="2">TEST DE RECUPERACION DE ANESTESIA - SEDACION (SCORE DEL ALDRETE)</td>
            </tr>
            <%
            int tHe=0, tM15=0, tM30=0, tM60=0, tM90=0, tM120=0, tHs=0, totalTest = 0;
            ArrayList alH = SQLMgr.getDataList("select codigo, descripcion from tbl_sal_recuperacion_anestesia order by orden");
            
            String divDesc = "30";
            String divDet = "10";
            
            for (int h = 0; h < alH.size(); h++){
                CommonDataObject cdoH = (CommonDataObject) alH.get(h);
                
                sql = "select a.codigo, a.descripcion, a.escala,  b.minutos, b.escala_he as escalahe, b.escala_min15 as escalamin15, b.escala_min30 as escalamin30, b.escala_min60 as escalamin60, b.escala_min90 as escalamin90, b.escala_min120 as escalamin120, b.escala_hs as escalahs, (select join( cursor(select escala||'='||escala from tbl_sal_detalle_recuperacion where recup_anestesia = a.recup_anestesia and escala = a.escala order by codigo),',') from dual) escalas, a.recup_anestesia, decode(b.cod_recup_anes,null,'I','U') action from tbl_sal_detalle_recuperacion a, (select cod_recup_anes, codigo_det_recup, cod_det_recup_anes, minutos, escala_he, escala_min15, escala_min30, escala_min60, escala_min90, escala_min120, escala_hs from tbl_sal_recup_anes_sop_test where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" order by 2) b where a.codigo = b.codigo_det_recup(+) and a.recup_anestesia = b.cod_det_recup_anes(+) and a.recup_anestesia = "+cdoH.getColValue("codigo")+" order by a.codigo";
            %> 
            <input type="hidden" class="cod-header" value="<%=cdoH.getColValue("codigo")%>">          
            <tr>
                <td>[<%=cdoH.getColValue("codigo")%>]&nbsp;<%=cdoH.getColValue("descripcion")%></td>
                <td style="vertical-align:middle !important;">
                <table cellspacing="0" class="table table-small-font table-bordered table-striped" width="100%" style="margin-bottom:0">
                <%
                ArrayList alD = SQLMgr.getDataList(sql);
                for (int d = 0; d < alD.size(); d++) {
                    CommonDataObject cdoD = (CommonDataObject) alD.get(d);
                    
                    tHe  += Integer.parseInt(cdoD.getColValue("escalaHe","0"));
                    tM15 += Integer.parseInt(cdoD.getColValue("escalaMin15","0"));
                    tM30 += Integer.parseInt(cdoD.getColValue("escalaMin30","0"));
                    tM60 += Integer.parseInt(cdoD.getColValue("escalaMin60","0"));
                    tM90 += Integer.parseInt(cdoD.getColValue("escalaMin90","0"));
                    tM120 += Integer.parseInt(cdoD.getColValue("escalaMin120","0"));
                    tHs  += Integer.parseInt(cdoD.getColValue("escalaHs","0"));
                %>
                    
                    <%if(d == 0){%>
                    <tr align="center" class="bg-headtabla">
                        <td width="<%=divDesc%>%"></td>
                        <td width="<%=divDet%>%"><cellbytelabel id="10">HE</cellbytelabel></td>
                        <td width="<%=divDet%>%">15</td>
                        <td width="<%=divDet%>%">30</td>
                        <td width="<%=divDet%>%">60</td>
                        <td width="<%=divDet%>%">90</td>
                        <td width="<%=divDet%>%">120</td>
                        <td width="<%=divDet%>%"><cellbytelabel id="11">HS</cellbytelabel></td>
                    </tr>
                    <%}%>
                    <tr align="center">
                        <td align="left"><%=cdoD.getColValue("descripcion")%></td>
                        <td>                            
                            <%=fb.select("he"+totalTest,cdoD.getColValue("escalas"),cdoD.getColValue("escalaHe"),false,false,false,0,"form-controls input-sm escala-type escala-x-header-"+cdoH.getColValue("codigo")+"-he","width:50px","","","S"," data-type='he'")%>
                        </td>
                        <td>
                            <%=fb.select("min15"+totalTest,cdoD.getColValue("escalas"),cdoD.getColValue("escalamin15"),false,false,false,0,"form-controls input-sm escala-type escala-x-header-"+cdoH.getColValue("codigo")+"-min15","width:50px","","","S"," data-type='min15'")%>
                        </td>
                        <td>                            
                            <%=fb.select("min30"+totalTest,cdoD.getColValue("escalas"),cdoD.getColValue("escalamin30"),false,false,false,0,"form-controls input-sm escala-type escala-x-header-"+cdoH.getColValue("codigo")+"-min30","width:50px","","","S"," data-type='min30'")%>
                        </td>
                        <td>
                            <%=fb.select("min60"+totalTest,cdoD.getColValue("escalas"),cdoD.getColValue("escalamin60"),false,false,false,0,"form-controls input-sm escala-type escala-x-header-min60-"+cdoH.getColValue("codigo"),"width:50px","","","S"," data-type='min60'")%>
                        </td>
                        <td>
                            <%=fb.select("min90"+totalTest,cdoD.getColValue("escalas"),cdoD.getColValue("escalamin90"),false,false,false,0,"form-controls input-sm escala-type escala-type escala-x-header-"+cdoH.getColValue("codigo")+"-min90","width:50px","","","S"," data-type='min90'")%>
                        </td>
                        <td>
                            <%=fb.select("min120"+totalTest,cdoD.getColValue("escalas"),cdoD.getColValue("escalamin120"),false,false,false,0,"form-controls input-sm escala-type escala-type escala-x-header-"+cdoH.getColValue("codigo")+"-min120","width:50px","","","S"," data-type='min120'")%>
                        </td>
                        <td>
                            <%=fb.select("hs"+totalTest,cdoD.getColValue("escalas"),cdoD.getColValue("escalaHs"),false,false,false,0,"form-controls input-sm escala-type escala-type escala-x-header-"+cdoH.getColValue("codigo")+"-hs","width:50px","","","S"," data-type='hs'")%>
                        </td>
                    </tr>
                    <%=fb.hidden("codigo_det_recup"+totalTest, cdoD.getColValue("codigo"))%>
                    <%=fb.hidden("cod_det_recup_anes"+totalTest, cdoD.getColValue("recup_anestesia"))%>
                    <%=fb.hidden("action"+totalTest, cdoD.getColValue("action"))%>
                <%
                    totalTest++;
                } // ald

                if (h+1 == alH.size()) {%>
                    <tr style="font-weight:bold">
                        <td align="right"><cellbytelabel id="14">Total</cellbytelabel>:</td>
                        <td><%=fb.intBox("totalhe",""+tHe+"", false, false, true, 2, "form-control input-sm total-aldrete", "", "")%></td>
                        <td><%=fb.intBox("totalmin15",""+tM15+"", false, false, true, 2, "form-control input-sm total-aldrete", "", "")%></td>
                        <td><%=fb.intBox("totalmin30",""+tM30+"", false, false, true, 2, "form-control input-sm total-aldrete", "", "")%></td>
                        <td><%=fb.intBox("totalmin60",""+tM60+"", false, false, true, 2, "form-control input-sm total-aldrete", "", "")%></td>
                        <td><%=fb.intBox("totalmin90",""+tM90+"", false, false, true, 2, "form-control input-sm total-aldrete", "", "")%></td>
                        <td><%=fb.intBox("totalmin120",""+tM120+"", false, false, true, 2, "form-control input-sm total-aldrete", "", "")%></td>
                        <td><%=fb.intBox("totalhs",""+tHs+"", false, false, true, 2, "form-control input-sm total-aldrete", "", "")%></td>
                    </tr>
                <%=fb.hidden("total_aldrete", ""+(tHe+tM15+tM30+tM60+tM90+tM120+tHs))%>
                <%
                }    
                %>
                </table>
                </td>
            </tr>
            <%
            }
            %>
            
            <tr class="bg-headtabla2" align="center" width="100%">
                <td colspan="2">SIGNOS VITALES</td>
            </tr>

            <tr>
                <td>&nbsp;</td>
                <%
                ArrayList alD = SQLMgr.getDataList("select a.codigo, a.nombre, b.escalahe, b.escalamin15, b.escalamin30, b.escalamin60, b.escalamin90, b.escalamin120, b.escalahs, decode(b.cod_recup_anes,null,'I','U') action from tbl_sal_recup_anes_sop_signos a, (select b.escala_he as escalahe, b.escala_min15 as escalamin15, b.escala_min30 as escalamin30, b.escala_min60 as escalamin60, b.escala_min90 as escalamin90, b.escala_min120 as escalamin120, b.escala_hs as escalahs, cod_recup_anes, b.cod_signos from tbl_sal_recup_anes_sop_sv b where b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.cod_recup_anes = "+code+") b where a.estado = 'A' and a.codigo = b.cod_signos(+) order by a.orden");
                %>
                <td>
                <table cellspacing="0" class="table table-small-font table-bordered table-striped" width="100%" style="margin-bottom:0">
                <%
                int totalSV = 0;
                for (int d = 0; d < alD.size(); d++) {
                    CommonDataObject cdoD = (CommonDataObject) alD.get(d);
                if(d == 0){%>
                    <tr align="center" class="bg-headtabla">
                        <td width="<%=divDesc%>%"></td>
                        <td width="<%=divDet%>%"><cellbytelabel id="10">HE</cellbytelabel></td>
                        <td width="<%=divDet%>%">15</td>
                        <td width="<%=divDet%>%">30</td>
                        <td width="<%=divDet%>%">60</td>
                        <td width="<%=divDet%>%">90</td>
                        <td width="<%=divDet%>%">120</td>
                        <td width="<%=divDet%>%"><cellbytelabel id="11">HS</cellbytelabel></td>
                    </tr>
                <%}%>
                    <tr>
                        <td><%=cdoD.getColValue("nombre")%></td>
                        <td><%=fb.textBox("sv_he"+totalSV,cdoD.getColValue("escalaHe"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='sv_he'")%></td>
                        <td><%=fb.textBox("sv_min15"+totalSV,cdoD.getColValue("escalaMin15"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='sv_min15'")%></td>
                        <td><%=fb.textBox("sv_min30"+totalSV,cdoD.getColValue("escalaMin30"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='sv_min30'")%></td>
                        <td><%=fb.textBox("sv_min60"+totalSV,cdoD.getColValue("escalaMin60"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='sv_min60'")%></td>
                        <td><%=fb.textBox("sv_min90"+totalSV,cdoD.getColValue("escalaMin90"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='sv_min90'")%></td>
                        <td><%=fb.textBox("sv_min120"+totalSV,cdoD.getColValue("escalaMin120"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='sv_min120'")%></td>
                        <td><%=fb.textBox("sv_hs"+totalSV,cdoD.getColValue("escalaHs"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='sv_hs'")%></td>
                    </tr>
                <%=fb.hidden("cod_signos"+totalSV, cdoD.getColValue("codigo"))%>
                <%=fb.hidden("sv_action"+totalSV, cdoD.getColValue("action"))%>
                <%
                totalSV++;
                } // for
                %>
                </table>                
                </td>
            </tr>
            
            <tr class="bg-headtabla2" align="center" width="100%">
                <td colspan="2">FLUJOS PARENTERALES - DRENAJES</td>
            </tr>
            
            <tr>
                <td>&nbsp;</td>
                <%
                ArrayList alD1 = SQLMgr.getDataList("select a.codigo, a.nombre, b.escalahe, b.escalamin15, b.escalamin30, b.escalamin60, b.escalamin90, b.escalamin120, b.escalahs, decode(b.cod_recup_anes,null,'I','U') action from tbl_sal_recup_anes_sop_fluidos a, (select b.escala_he as escalahe, b.escala_min15 as escalamin15, b.escala_min30 as escalamin30, b.escala_min60 as escalamin60, b.escala_min90 as escalamin90, b.escala_min120 as escalamin120, b.escala_hs as escalahs, cod_recup_anes, b.cod_fluidos from tbl_sal_recup_anes_sop_fp b where b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.cod_recup_anes = "+code+") b where a.estado = 'A' and a.codigo = b.cod_fluidos(+) order by a.orden");
                %>
                <td>
                <table cellspacing="0" class="table table-small-font table-bordered table-striped" width="100%" style="margin-bottom:0">
                <%
                int totalFP = 0;
                for (int d = 0; d < alD1.size(); d++) {
                    CommonDataObject cdoD = (CommonDataObject) alD1.get(d);
                if(d == 0){%>
                    <tr align="center" class="bg-headtabla">
                        <td width="<%=divDesc%>%"></td>
                        <td width="<%=divDet%>%"><cellbytelabel id="10">HE</cellbytelabel></td>
                        <td width="<%=divDet%>%">15</td>
                        <td width="<%=divDet%>%">30</td>
                        <td width="<%=divDet%>%">60</td>
                        <td width="<%=divDet%>%">90</td>
                        <td width="<%=divDet%>%">120</td>
                        <td width="<%=divDet%>%"><cellbytelabel id="11">HS</cellbytelabel></td>
                    </tr>
                <%}%>
                    <tr>
                        <td><%=cdoD.getColValue("nombre")%></td>
                        <td><%=fb.textBox("fp_he"+totalFP,cdoD.getColValue("escalaHe"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='fp_he'")%></td>
                        <td><%=fb.textBox("fp_min15"+totalFP,cdoD.getColValue("escalaMin15"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='fp_min15'")%></td>
                        <td><%=fb.textBox("fp_min30"+totalFP,cdoD.getColValue("escalaMin30"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='fp_min30'")%></td>
                        <td><%=fb.textBox("fp_min60"+totalFP,cdoD.getColValue("escalaMin60"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='fp_min60'")%></td>
                        <td><%=fb.textBox("fp_min90"+totalFP,cdoD.getColValue("escalaMin90"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='fp_min90'")%></td>
                        <td><%=fb.textBox("fp_min120"+totalFP,cdoD.getColValue("escalaMin120"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='fp_min120'")%></td>
                        <td><%=fb.textBox("fp_hs"+totalFP,cdoD.getColValue("escalaHs"),false,false,viewMode,1,15,"form-control input-sm",null,"", null, false, " data-type='fp_hs'")%></td>
                    </tr>
                <%=fb.hidden("cod_fluidos"+totalFP, cdoD.getColValue("codigo"))%>
                <%=fb.hidden("fp_action"+totalFP, cdoD.getColValue("action"))%>
                <%
                totalFP++;
                } // for
                %>
                </table>                
                </td>
            </tr>

            <%=fb.hidden("total_med", ""+alMed.size())%>
            <tr class="bg-headtabla2" align="center">
                <td colspan="2">MEDICAMENTOS
                <span class="pull-right" style="text-align:right !important">
                    <button type="button" class="btn btn-inverse btn-sm" id="btn_med"<%=viewMode?" disabled":""%>>
                        <i class="fa fa-plus"></i>
                    </button>
                </span>
                </td>
            </tr>
            <tr class="bg-headtabla2">
                <td>Hora</td>
                <td>Medicamentos</td>
            </tr>
            
            <tr style="display:none" id="tpl-med">
                <input type="hidden" name="med_action@@index" value="I">
                <td class="controls form-inline">
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="hora_registro_med@@index" />
                    <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                    </jsp:include>
                </td>
                <td>
                    <input type="text" name="medicamentos@@index" maxlength="200" class="form-control input-sm">
                </td>
            </tr>
            
            <%
            for (int i = 1; i<=alMed.size();i++) {
                cdo = (CommonDataObject) alMed.get(i-1);
            %>
                <%=fb.hidden("med_action"+i, cdo.getColValue("action"))%>
                <%=fb.hidden("codigo_med"+i, cdo.getColValue("codigo"))%>
                <tr>
                    <td class="controls form-inline">
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="<%="hora_registro_med"+i%>" />
                    <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_registro")%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                    </jsp:include>
                </td>
                <td>
                    <%=fb.textBox("medicamentos"+i, cdo.getColValue("medicamento"),false,false,true,150,"form-control input-sm","",null)%>
                </td>
                </tr>
            <%    
            }
            %>
            
            <%=fb.hidden("total_tra", ""+alTra.size())%>
            <tr class="bg-headtabla2" align="center">
                <td colspan="2">TRATAMIENTOS
                <span class="pull-right" style="text-align:right !important">
                    <button type="button" class="btn btn-inverse btn-sm" id="btn_tra"<%=viewMode?" disabled":""%>>
                        <i class="fa fa-plus"></i>
                    </button>
                </span>
                </td>
            </tr>
            <tr class="bg-headtabla2">
                <td>Hora</td>
                <td>Tratamientos</td>
            </tr>
            
            <tr style="display:none" id="tpl-tra">
                <input type="hidden" name="tra_action@@index" value="I">
                <td class="controls form-inline">
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="hora_registro_tra@@index" />
                    <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                    </jsp:include>
                </td>
                <td>
                    <input type="text" name="tratamientos@@index" maxlength="200" class="form-control input-sm">
                </td>
            </tr>
            
            <%
            for (int i = 1; i<=alTra.size();i++) {
                cdo = (CommonDataObject) alTra.get(i-1);
            %>
                <%=fb.hidden("tra_action"+i, cdo.getColValue("action"))%>
                <%=fb.hidden("codigo_tra"+i, cdo.getColValue("codigo"))%>
                <tr>
                    <td class="controls form-inline">
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="<%="hora_registro_tra"+i%>" />
                    <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_registro")%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                    </jsp:include>
                </td>
                <td>
                    <%=fb.textBox("tratamientos"+i, cdo.getColValue("tratamiento"),false,false,true,150,"form-control input-sm","",null)%>
                </td>
                </tr>
            <%    
            }
            %>
            
            <%=fb.hidden("total_nef", ""+alNEF.size())%>
            <tr class="bg-headtabla2" align="center">
                <td colspan="2">NOTAS DE ENFERMERA DE RECOBRO
                <span class="pull-right" style="text-align:right !important">
                    <button type="button" class="btn btn-inverse btn-sm" id="btn_nef"<%=viewMode?" disabled":""%>>
                        <i class="fa fa-plus"></i>
                    </button>
                </span>
                </td>
            </tr>
            <tr class="bg-headtabla2">
                <td>Hora</td>
                <td>Nota</td>
            </tr>
            
            <tr style="display:none" id="tpl-nef">
                <input type="hidden" name="nef_action@@index" value="I">
                <td class="controls form-inline">
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="hora_registro_nef@@index" />
                    <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                    </jsp:include>
                </td>
                <td>
                    <input type="text" name="notas@@index" maxlength="200" class="form-control input-sm">
                </td>
            </tr>
            
            <%
            for (int i = 1; i<=alNEF.size();i++) {
                cdo = (CommonDataObject) alNEF.get(i-1);
            %>
                <%=fb.hidden("nef_action"+i, cdo.getColValue("action"))%>
                <%=fb.hidden("codigo_nef"+i, cdo.getColValue("codigo"))%>
                <tr>
                    <td class="controls form-inline">
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="<%="hora_registro_nef"+i%>" />
                    <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_registro")%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                    </jsp:include>
                </td>
                <td>
                    <%=fb.textBox("notas"+i, cdo.getColValue("nota"),false,false,true,150,"form-control input-sm","",null)%>
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
                        <%=fb.hidden("saveOption","O")%>        
                        <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick='doSubmit()'")%>
                    </td>
                    </tr>
                </table>   
            </div>
            <%=fb.hidden("total_test", ""+totalTest)%>
            <%=fb.hidden("total_sv", ""+totalSV)%>
            <%=fb.hidden("total_fp", ""+totalFP)%>
            <%=fb.formEnd(true)%>
        </div> <!-- Test de Recuperación -->
    </div> <!-- Tab panes -->
</div>
</div>
</body>
</html>
<%
} else {

    String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
    String errorCode = "", errorMsg = "";

	if (tab.equals("0")) {
        Properties prop = new Properties();
        prop.setProperty("procedimiento", request.getParameter("procedimiento"));
        prop.setProperty("desc_proc", request.getParameter("desc_proc"));
        
        for (int i = 0; i<4; i++) {
           prop.setProperty("anestesia"+i, request.getParameter("anestesia"+i));
           prop.setProperty("anestesia"+i+"_desc", request.getParameter("anestesia"+i+"_desc"));
        }
        prop.setProperty("anestesiologo", request.getParameter("anestesiologo"));
        prop.setProperty("anestesiologoNombre", request.getParameter("anestesiologoNombre"));
        prop.setProperty("enfermera_anes", request.getParameter("enfermera_anes"));
        prop.setProperty("enfermera_nombre_anes", request.getParameter("enfermera_nombre_anes"));
        prop.setProperty("cirujano", request.getParameter("cirujano"));
        prop.setProperty("cirujanoNombre", request.getParameter("cirujanoNombre"));
        prop.setProperty("asistente", request.getParameter("asistente"));
        prop.setProperty("asistente_nombre", request.getParameter("asistente_nombre"));
        prop.setProperty("recup_enfer", request.getParameter("recup_enfer"));
        prop.setProperty("recup_enfer_nombre", request.getParameter("recup_enfer_nombre"));
        prop.setProperty("gen_alerta", request.getParameter("gen_alerta"));
        
        if(!request.getParameter("hora_entrada").trim().equals(""))
            prop.setProperty("hora_entrada", request.getParameter("hora_entrada"));
        if(!request.getParameter("hora_salida").trim().equals("")) {
            prop.setProperty("hora_salida", request.getParameter("hora_salida"));
            prop.setProperty("egresado_a", request.getParameter("egresado_a"));
        }
            
        prop.setProperty("relev_enfer", request.getParameter("relev_enfer"));
        prop.setProperty("relev_enfer_nombre", request.getParameter("relev_enfer_nombre"));
        
        if (!modeSec.equalsIgnoreCase("add")) {
            prop.setProperty("fecha_modificacion", cDateTime);
            prop.setProperty("usuario_modificacion", userName);
            prop.setProperty("codigo", code);
        }
        
        prop.setProperty("pac_id", pacId);
        prop.setProperty("admision", noAdmision);
        prop.setProperty("fecha_creacion", request.getParameter("fecha_creacion"));
        prop.setProperty("usuario_creacion", request.getParameter("usuario_creacion"));
        
        if (baction.equalsIgnoreCase("Guardar")) {
            ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
            if (modeSec.equalsIgnoreCase("add")) {
                RECANESMgr.add(prop);
                code = RECANESMgr.getPkColValue("codigo");
            } else {
                RECANESMgr.update(prop);
            }
            ConMgr.clearAppCtx(null);
        }
        
        errorCode = RECANESMgr.getErrCode();
        errorMsg = RECANESMgr.getErrMsg();
    } // tab0
    
    else if (tab.equals("1")) {
        
        int size = Integer.parseInt(request.getParameter("total_test"));
        al.clear();
        
        for (int i = 0; i < size; i++) {
            cdo = new CommonDataObject();
            
            cdo.setTableName("tbl_sal_recup_anes_sop_test");
            
            if (request.getParameter("action"+i) != null && request.getParameter("action"+i).equalsIgnoreCase("I")) {
                cdo.setAction("I");
                cdo.addColValue("pac_id", pacId);
                cdo.addColValue("admision", noAdmision);
                cdo.addColValue("cod_recup_anes", code);
                cdo.addColValue("cod_recup_anes", code);
                cdo.addColValue("cod_det_recup_anes", request.getParameter("cod_det_recup_anes"+i));
                cdo.addColValue("codigo_det_recup", request.getParameter("codigo_det_recup"+i));
            } else {
                cdo.setAction("U");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" and codigo_det_recup = "+request.getParameter("codigo_det_recup"+i)+" and cod_det_recup_anes = "+request.getParameter("cod_det_recup_anes"+i));
            }
            
            cdo.addColValue("escala_he", request.getParameter("he"+i));
            cdo.addColValue("escala_min15", request.getParameter("min15"+i));
            cdo.addColValue("escala_min30", request.getParameter("min30"+i));
            cdo.addColValue("escala_min60", request.getParameter("min60"+i));
            cdo.addColValue("escala_min90", request.getParameter("min90"+i));
            cdo.addColValue("escala_min120", request.getParameter("min120"+i));
            cdo.addColValue("escala_hs", request.getParameter("hs"+i));
            
            al.add(cdo);
        } // for i
        
        if (al.size() == 0) {
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_recup_anes_sop_test");
            cdo.setAction("I");
            cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code);
            
            al.add(cdo);
        }
        
        // signos vitales
        ArrayList al1 = new ArrayList();
        int size1 = Integer.parseInt(request.getParameter("total_sv"));
        
        for (int i = 0; i < size1; i++) {
            cdo = new CommonDataObject();
            
            cdo.setTableName("tbl_sal_recup_anes_sop_sv");
            
            if (request.getParameter("sv_action"+i) != null && request.getParameter("sv_action"+i).equalsIgnoreCase("I")) {
                cdo.setAction("I");
                cdo.addColValue("pac_id", pacId);
                cdo.addColValue("admision", noAdmision);
                cdo.addColValue("cod_recup_anes", code);
                cdo.addColValue("cod_signos", request.getParameter("cod_signos"+i));
            } else {
                cdo.setAction("U");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" and cod_signos = "+request.getParameter("cod_signos"+i));
            }
            
            cdo.addColValue("escala_he", request.getParameter("sv_he"+i));
            cdo.addColValue("escala_min15", request.getParameter("sv_min15"+i));
            cdo.addColValue("escala_min30", request.getParameter("sv_min30"+i));
            cdo.addColValue("escala_min60", request.getParameter("sv_min60"+i));
            cdo.addColValue("escala_min90", request.getParameter("sv_min90"+i));
            cdo.addColValue("escala_min120", request.getParameter("sv_min120"+i));
            cdo.addColValue("escala_hs", request.getParameter("sv_hs"+i));
            
            al1.add(cdo);
        } // for i
        
        if (al.size() == 0) {
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_recup_anes_sop_test");
            cdo.setAction("I");
            cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code);
            
            al.add(cdo);
        }
        
        if (al1.size() == 0) {
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_recup_anes_sop_sv");
            cdo.setAction("I");
            cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code);
            
            al1.add(cdo);
        }
        
        // Fluidos parenterales
        ArrayList al2 = new ArrayList();
        int size2 = Integer.parseInt(request.getParameter("total_fp"));
        
        for (int i = 0; i < size2; i++) {
            cdo = new CommonDataObject();
            
            cdo.setTableName("tbl_sal_recup_anes_sop_fp");
            
            if (request.getParameter("fp_action"+i) != null && request.getParameter("fp_action"+i).equalsIgnoreCase("I")) {
                cdo.setAction("I");
                cdo.addColValue("pac_id", pacId);
                cdo.addColValue("admision", noAdmision);
                cdo.addColValue("cod_recup_anes", code);
                cdo.addColValue("cod_fluidos", request.getParameter("cod_fluidos"+i));
            } else {
                cdo.setAction("U");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" and cod_fluidos = "+request.getParameter("cod_fluidos"+i));
            }
            
            cdo.addColValue("escala_he", request.getParameter("fp_he"+i));
            cdo.addColValue("escala_min15", request.getParameter("fp_min15"+i));
            cdo.addColValue("escala_min30", request.getParameter("fp_min30"+i));
            cdo.addColValue("escala_min60", request.getParameter("fp_min60"+i));
            cdo.addColValue("escala_min90", request.getParameter("fp_min90"+i));
            cdo.addColValue("escala_min120", request.getParameter("fp_min120"+i));
            cdo.addColValue("escala_hs", request.getParameter("fp_hs"+i));
            
            al2.add(cdo);
        } // for i
        
        // medicamentos
        // Fluidos parenterales
        ArrayList al3 = new ArrayList();
        int size3 = Integer.parseInt(request.getParameter("total_med"));
        
        for (int i = 1; i <= size3; i++) {
            cdo = new CommonDataObject();
            
            cdo.setTableName("tbl_sal_recup_anes_sop_med");
            
            if (request.getParameter("med_action"+i) != null && request.getParameter("med_action"+i).equalsIgnoreCase("I")) {
                cdo.setAction("I");
                cdo.addColValue("pac_id", pacId);
                cdo.addColValue("admision", noAdmision);
                cdo.addColValue("cod_recup_anes", code);
                cdo.setAutoIncCol("codigo");
                cdo.setAutoIncWhereClause("pac_id = "+pacId+" and admision = "+noAdmision);
            } else {
                cdo.setAction("U");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" and codigo = "+request.getParameter("codigo_med"+i));
            }
            
            cdo.addColValue("hora_registro", request.getParameter("hora_registro_med"+i));
            cdo.addColValue("medicamento", request.getParameter("medicamentos"+i));
            
            al3.add(cdo);
        } // for i
        
        // TRATAMIENTOS
        ArrayList al4 = new ArrayList();
        int size4 = Integer.parseInt(request.getParameter("total_tra"));
        
        for (int i = 1; i <= size4; i++) {
            cdo = new CommonDataObject();
            
            cdo.setTableName("tbl_sal_recup_anes_sop_tra");
            
            if (request.getParameter("tra_action"+i) != null && request.getParameter("tra_action"+i).equalsIgnoreCase("I")) {
                cdo.setAction("I");
                cdo.addColValue("pac_id", pacId);
                cdo.addColValue("admision", noAdmision);
                cdo.addColValue("cod_recup_anes", code);
                cdo.setAutoIncCol("codigo");
                cdo.setAutoIncWhereClause("pac_id = "+pacId+" and admision = "+noAdmision);
            } else {
                cdo.setAction("U");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" and codigo = "+request.getParameter("codigo_tra"+i));
            }
            
            cdo.addColValue("hora_registro", request.getParameter("hora_registro_tra"+i));
            cdo.addColValue("tratamiento", request.getParameter("tratamientos"+i));
            
            al4.add(cdo);
        } // for i
        
        // Notas ENFERMERA de RECOBRO
        ArrayList al5 = new ArrayList();
        int size5 = Integer.parseInt(request.getParameter("total_nef"));
        
        for (int i = 1; i <= size5; i++) {
            cdo = new CommonDataObject();
            
            cdo.setTableName("tbl_sal_recup_anes_sop_nef");
            
            if (request.getParameter("nef_action"+i) != null && request.getParameter("nef_action"+i).equalsIgnoreCase("I")) {
                cdo.setAction("I");
                cdo.addColValue("pac_id", pacId);
                cdo.addColValue("admision", noAdmision);
                cdo.addColValue("cod_recup_anes", code);
                cdo.setAutoIncCol("codigo");
                cdo.setAutoIncWhereClause("pac_id = "+pacId+" and admision = "+noAdmision);
            } else {
                cdo.setAction("U");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" and codigo = "+request.getParameter("codigo_nef"+i));
            }
            
            cdo.addColValue("hora_registro", request.getParameter("hora_registro_nef"+i));
            cdo.addColValue("nota", request.getParameter("notas"+i));
            
            al4.add(cdo);
        } // for i
        
        
        if (al.size() == 0) {
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_recup_anes_sop_test");
            cdo.setAction("I");
            cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code);
            
            al.add(cdo);
        }
        
        if (al1.size() == 0) {
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_recup_anes_sop_sv");
            cdo.setAction("I");
            cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code);
            
            al1.add(cdo);
        }
        
        if (al2.size() == 0) {
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_recup_anes_sop_fp");
            cdo.setAction("I");
            cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code);
            
            al2.add(cdo);
        }
        
        if (al3.size() == 0) {
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_recup_anes_sop_med");
            cdo.setAction("I");
            cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code);
            al3.add(cdo);
        }
        
        if (al4.size() == 0) {
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_recup_anes_sop_tra");
            cdo.setAction("I");
            cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code);
            al4.add(cdo);
        }
        
        if (al5.size() == 0) {
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_recup_anes_sop_nef");
            cdo.setAction("I");
            cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code);
            al5.add(cdo);
        }

        if (baction.equalsIgnoreCase("Guardar")) {
            ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
            SQLMgr.saveList(al, true);
            
            if(!tab.equalsIgnoreCase("0") && request.getParameter("total_aldrete")!=null&&!request.getParameter("total_aldrete").equals("")) SQLMgr.execute("call sp_sal_gen_alerta_aldrete("+pacId+","+noAdmision+","+code+","+request.getParameter("total_aldrete")+")");
            
            SQLMgr.saveList(al1, true);
            SQLMgr.saveList(al2, true);
            SQLMgr.saveList(al3, true);
            SQLMgr.saveList(al4, true);
            SQLMgr.saveList(al5, true);
            ConMgr.clearAppCtx(null);
        }
       
        errorCode = SQLMgr.getErrCode();
        errorMsg = SQLMgr.getErrMsg();
    } // tab 1
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

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

