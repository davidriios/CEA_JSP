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
<jsp:useBean id="RUCIMgr" scope="page" class="issi.expediente.RondaUciMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
RUCIMgr.setConnection(ConMgr);

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

if (code == null) code = "0";
if (fg == null) fg = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (!code.equals("0")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String sexo = "";
String formulario = "";
int edad = 0;

if (request.getMethod().equalsIgnoreCase("GET")) {
	
	if (!code.trim().equals("0")) {
      prop = SQLMgr.getDataProperties("select params from tbl_sal_ronda_multi_disci_uci where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+code);
      
      if (prop == null) {
        prop = new Properties();
      } else {
        if(!viewMode) modeSec = "edit";
        sexo = prop.getProperty("sexo");
        formulario = prop.getProperty("formulario");
        edad = Integer.parseInt(prop.getProperty("edad") != null && !"".equals(prop.getProperty("edad"))?prop.getProperty("edad"):"0"); 
      }
      
    } else {
        prop = new Properties();
        prop.setProperty("fecha",cDateTime.substring(0,10));
    }
    
    ArrayList alH = SQLMgr.getDataList("select codigo, to_char(fecha_creacion, 'dd/mm/yyyy') fc, to_char(fecha_creacion, 'hh12:mi am') hc, usuario_creacion from tbl_sal_ronda_multi_disci_uci where pac_id="+pacId+" and admision="+noAdmision+" order by 1 desc");
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
<script>
var noNewHeight = true;
$(function(){

  $("#imprimir").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente3.0/print_ronda_equipo_multi_disciplinario.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>&formulario=<%=formulario%>");
  });
  
  $(".should-type").click(function(){
      var that = $(this);
      var i = that.data('index');
      if (that.is(":checked")) {
        $("#observacion_"+i).prop("readOnly", false)
      } else {
        $("#observacion_"+i).val("").prop("readOnly", true)
      }
    });
});

function canSubmit() {
  var proceed = true;
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    if ( $self.is(":checked") && !$.trim($("#observacion_"+i).val())) {
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
    window.location = '../expediente3.0/exp_ronda_equipo_multi_disciplinario.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&code='+code;
}
function add(){window.location = '../expediente3.0/exp_ronda_equipo_multi_disciplinario.jsp?modeSec=add&mode=add&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>';}

function verHistorial() {
  $("#hist_container").toggle();
}

function medicoList(){
	abrir_ventana1('../common/search_medico.jsp?fp=ronda_uci&especialidad=');
}

function empleadoList(opt){
    if (opt == 1) abrir_ventana1('../common/search_empleado.jsp?fp=ronda_uci&fg=enfermera');
    else if (opt == 2) abrir_ventana1('../common/search_empleado.jsp?fp=ronda_uci&fg=terapista');
    else if (opt == 3) abrir_ventana1('../common/search_empleado.jsp?fp=ronda_uci&fg=farmacia');
    else if (opt == 4) abrir_ventana1('../common/search_empleado.jsp?fp=ronda_uci&fg=nutricion');
    else if (opt == 5) abrir_ventana1('../common/search_empleado.jsp?fp=ronda_uci&fg=supervisor');
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

    <div class="headerform">
        <table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
            <tr>
                <td>
                    <%=fb.button("imprimir","Imprimir",false,false,null,null,"")%>
                    
                      <button type="button" class="btn btn-inverse btn-sm" onclick="add()"<%=(mode.equalsIgnoreCase("view")) ?" disabled":""%>>
                        <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
                      </button>
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
                <tr onclick="javascript:setEscala('<%=cdoH.getColValue("codigo")%>')" class="pointer">
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
    <tr>
        <td width="25%" align="right">NEURO</td>
        <td width="25%">
            <label class="pointer">
                <%=fb.checkbox("params_0","0",(prop.getProperty("params_0").equalsIgnoreCase("0")),viewMode,"","","","")%>&nbsp;Sedación
            </label><br>
            <label class="pointer">
                <%=fb.checkbox("params_1","1",(prop.getProperty("params_1").equalsIgnoreCase("1")),viewMode,"","","","")%>&nbsp; Manejo del dolor
            </label><br>
            <label class="pointer">
                <%=fb.checkbox("params_2","2",(prop.getProperty("params_2").equalsIgnoreCase("2")),viewMode,"","","","")%>&nbsp; N/A
            </label>
        </td>
        <td width="25%" align="right">CARDIOVASCULAR (HEMODINAMICA)</td>
        <td width="25%" class="controls form-inline">
            Ritmo cardiaco pam
            <%=fb.textBox("observacion_0",prop.getProperty("observacion_0"),false,false,viewMode,60,"form-control input-sm","width:100px",null)%>&nbsp;mm hg<br>
            <label class="pointer">
                <%=fb.checkbox("params_3","3",(prop.getProperty("params_3").equalsIgnoreCase("3")),viewMode,"","","","")%>&nbsp;Vasopresor
            </label><br>
            <label class="pointer">
                <%=fb.checkbox("params_4","4",(prop.getProperty("params_4").equalsIgnoreCase("4")),viewMode,"","","","")%>&nbsp;Antihipertensivo
            </label><br>
            <label class="pointer">
                <%=fb.checkbox("params_5","5",(prop.getProperty("params_5").equalsIgnoreCase("5")),viewMode,"","","","")%>&nbsp;N/A
            </label>
        </td>
    </tr>
    
    <tr>
        <td align="right">VENTILADOR(PROGRESION, DESTETE)</td>
        <td>
            <label class="pointer">
                <%=fb.checkbox("params_6","6",(prop.getProperty("params_6").equals("6")),viewMode,"","","","")%>&nbsp;Ventilador
            </label><br>
            <label class="pointer">
                <%=fb.checkbox("params_7","7",(prop.getProperty("params_7").equals("7")),viewMode,"","","","")%>&nbsp;Terapia Respiratoria
            </label><br>
            <label class="pointer">
                <%=fb.checkbox("params_8","8",(prop.getProperty("params_8").equals("8")),viewMode,"","","","")%>&nbsp;Extubación
            </label><br>
            <label class="pointer">
                <%=fb.checkbox("params_9","9",(prop.getProperty("params_9").equals("9")),viewMode,"","","","")%>&nbsp;Cerrar Sedación
            </label><br>
            <label class="pointer">
                <%=fb.checkbox("params_10","10",(prop.getProperty("params_10").equals("10")),viewMode,"","","","")%>&nbsp;N/A
            </label>
        </td>
        <td align="right">PROFILAXIS TVP</td>
        <td>
            <label class="pointer">
                <%=fb.checkbox("params_11","11",(prop.getProperty("params_11").equals("11")),viewMode,"","","","")%>&nbsp;Mecánico</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_12","12",(prop.getProperty("params_12").equals("12")),viewMode,"","","","")%>&nbsp;Medicamentoso</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_13","13",(prop.getProperty("params_13").equals("13")),viewMode,"","","","")%>&nbsp;N/A</label>
        </td>
    </tr>
    
    <tr>
        <td align="right">INFECCIONES</td>
        <td>
            <label class="pointer">
                <%=fb.checkbox("params_14","14",(prop.getProperty("params_14").equals("14")),viewMode,"","","","")%>&nbsp;Leucocitos</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_15","15",(prop.getProperty("params_15").equals("15")),viewMode,"","","","")%>&nbsp;Cultivos</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_16","16",(prop.getProperty("params_16").equals("16")),viewMode,"","","","")%>&nbsp;Biomarcadores</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_17","17",(prop.getProperty("params_17").equals("17")),viewMode,"","","","")%>&nbsp;Aislamiento</label>
        </td>
        <td align="right">NUTRICION Y PROFILAXIS GASTRICOS</td>
        <td>
            <label class="pointer">
                <%=fb.checkbox("params_18","18",(prop.getProperty("params_18").equals("18")),viewMode,"","","","")%>&nbsp;Dieta vía oral</label><br>
             <label class="pointer">
                <%=fb.checkbox("params_19","19",(prop.getProperty("params_19").equals("19")),viewMode,"","","","")%>&nbsp;NTP</label><br>
             <label class="pointer">
                <%=fb.checkbox("params_20","20",(prop.getProperty("params_20").equals("20")),viewMode,"","","","")%>&nbsp;NE x Tubo</label><br>
             <label class="pointer">
                <%=fb.checkbox("params_21","21",(prop.getProperty("params_21").equals("21")),viewMode,"","","","")%>&nbsp;NPO (Check Insulina)</label><br>
             <label class="pointer">
                <%=fb.checkbox("params_22","22",(prop.getProperty("params_22").equals("22")),viewMode,"","","","")%>&nbsp;Profilaxis Anti Ulcera</label>
        </td>
    </tr>
    
    <tr>
        <td align="right">MOVILIZACION</td>
        <td>
            <label class="pointer">
                <%=fb.checkbox("params_23","23",(prop.getProperty("params_23").equals("23")),viewMode,"","","","")%>&nbsp;Fuera de cama</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_24","24",(prop.getProperty("params_24").equals("24")),viewMode,"","","","")%>&nbsp;En cama</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_25","25",(prop.getProperty("params_25").equals("25")),viewMode,"","","","")%>&nbsp;Reposo ambulatorio</label><br>
                <b>PIEL (REQUIERE TRATAMIENTO):</b><br>
                <label class="pointer">SI&nbsp;<%=fb.radio("params_26","26",(prop.getProperty("params_26")!=null && prop.getProperty("params_26").equals("26")),viewMode,false,"", null,"","","")%></label>&nbsp;&nbsp;
                <label class="pointer">NO&nbsp;<%=fb.radio("params_26","27",(prop.getProperty("params_2")!=null && prop.getProperty("params_26").equals("27")),viewMode,false,"", null,"","","")%></label>
        </td>
        <td align="right">RENAL / FLUIDO (BALANCE HIDRICO)</td>
        <td class="controls form-inline">
            <label class="pointer">
            <%=fb.checkbox("params_27","27",(prop.getProperty("params_27").equals("27")),viewMode,"observacion should-type",null,"",""," data-index=1 data-message='Por favor indicar datos para RENAL / FLUIDO (BALANCE HIDRICO): Positivo'")%>&nbsp;Positivo</label>&nbsp;&nbsp;<%=fb.textBox("observacion_1", prop.getProperty("observacion_1"),false,false,viewMode||prop.getProperty("observacion_1").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%><br>
            <label class="pointer">
            <%=fb.checkbox("params_28","28",(prop.getProperty("params_28").equals("28")),viewMode,"observacion should-type",null,"",""," data-index=2 data-message='Por favor indicar datos para RENAL / FLUIDO (BALANCE HIDRICO): Neutro'")%>&nbsp;Neutro</label>&nbsp;&nbsp;<%=fb.textBox("observacion_2", prop.getProperty("observacion_2"),false,false,viewMode||prop.getProperty("observacion_2").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%><br>
            <label class="pointer">
            <%=fb.checkbox("params_29","29",(prop.getProperty("params_29").equals("29")),viewMode,"observacion should-type",null,"",""," data-index=3 data-message='Por favor indicar datos para RENAL / FLUIDO (BALANCE HIDRICO): Negativo'")%>&nbsp;Negativo</label>&nbsp;&nbsp;<%=fb.textBox("observacion_3", prop.getProperty("observacion_3"),false,false,viewMode||prop.getProperty("observacion_3").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
            
        </td>
    </tr>
    
    <tr>
        <td align="right">CONTROL DE GLICEMIA</td>
        <td>
            <label class="pointer">
                <%=fb.checkbox("params_30","30",(prop.getProperty("params_30").equals("30")),viewMode,"","","","")%>&nbsp;SI</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_31","31",(prop.getProperty("params_31").equals("31")),viewMode,"","","","")%>&nbsp;Infusion Insulina</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_32","32",(prop.getProperty("params_32").equals("32")),viewMode,"","","","")%>&nbsp;N/A</label>
        </td>
        <td align="right">HEMATOLOGIA</td>
        <td class="controls form-inline">
            <b>Requiere Hb:</b>
            <%=fb.textBox("observacion_4",prop.getProperty("observacion_4"),false,false,viewMode,30,"form-control input-sm","width:100px",null)%><br>
            <b>Requiere Plaquetas:</b>
            <%=fb.textBox("observacion_5",prop.getProperty("observacion_5"),false,false,viewMode,30,"form-control input-sm","width:100px",null)%><br>
            <label class="pointer">
                <%=fb.checkbox("params_33","33",(prop.getProperty("params_33").equals("33")),viewMode,"","","","")%>&nbsp;Hemoderivados</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_34","34",(prop.getProperty("params_34").equals("34")),viewMode,"","","","")%>&nbsp;N/A</label>
        </td>
    </tr>
    
    <tr>
        <td align="right">MEDICAMENTOS</td>
        <td>
            <label class="pointer">
                <%=fb.checkbox("params_36","36",(prop.getProperty("params_36").equals("36")),viewMode,"","","","")%>&nbsp;Nuevos Medicamentos</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_37","37",(prop.getProperty("params_37").equals("37")),viewMode,"","","","")%>&nbsp;Cambio de Antibiotico</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_35","35",(prop.getProperty("params_35").equals("35")),viewMode,"","","","")%>&nbsp;Descontinuados</label><br>   
            <label class="pointer">
                <%=fb.checkbox("params_38","38",(prop.getProperty("params_38").equals("38")),viewMode,"","","","")%>&nbsp;N/A</label>
        </td>
        <td align="right">LINEAS / TUBOS PUEDE DESCONTINUAR</td>
        <td>
            <label class="pointer">
                <%=fb.checkbox("params_39","39",(prop.getProperty("params_39").equals("39")),viewMode,"","","","")%>&nbsp;CV C</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_40","40",(prop.getProperty("params_40").equals("40")),viewMode,"","","","")%>&nbsp;Sonda Foley</label><br>
            <label class="pointer">
            <%=fb.checkbox("params_41","41",(prop.getProperty("params_41").equals("41")),viewMode,"observacion should-type",null,"",""," data-index=6 data-message='Por favor indicar datos las otras LINEAS / TUBOS'")%>&nbsp;Otros</label>&nbsp;&nbsp;<%=fb.textBox("observacion_6", prop.getProperty("observacion_6"),false,false,viewMode||prop.getProperty("observacion_6").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>    
            
        </td>
    </tr>
    
    <tr>
        <td align="right">CODIGO</td>
        <td class="controls form-inline">
            <label class="pointer">
                <%=fb.checkbox("params_42","42",(prop.getProperty("params_42").equals("42")),viewMode,"","","","")%>&nbsp;RCP</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer">SI&nbsp;<%=fb.radio("params_43","43",(prop.getProperty("params_43")!=null && prop.getProperty("params_43").equals("43")),viewMode,false,"", null,"","","")%></label>&nbsp;&nbsp;
                <label class="pointer">NO&nbsp;<%=fb.radio("params_43","44",(prop.getProperty("params_43")!=null && prop.getProperty("params_43").equals("44")),viewMode,false,"", null,"","","")%></label>
        </td>
        <td align="right">QUE HACER</td>
        <td>
            <label class="pointer">
                <%=fb.checkbox("params_44","45",(prop.getProperty("params_44").equals("45")),viewMode,"","","","")%>&nbsp;PROCEDIMIENTO</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_45","46",(prop.getProperty("params_45").equals("46")),viewMode,"","","","")%>&nbsp;INTERCONSULTA</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_46","47",(prop.getProperty("params_46").equals("47")),viewMode,"","","","")%>&nbsp;LABORATORIO</label><br>
            <label class="pointer">
                <%=fb.checkbox("params_47","48",(prop.getProperty("params_47").equals("48")),viewMode,"","","","")%>&nbsp;RX DE TORAX</label><br>
            <label class="pointer">
            <%=fb.checkbox("params_48","49",(prop.getProperty("params_48").equals("49")),viewMode,"observacion should-type",null,"",""," data-index=7 data-message='Por favor indicar las otras cosas QUE HACER!'")%>&nbsp;OTRO</label>&nbsp;&nbsp;<%=fb.textBox("observacion_7", prop.getProperty("observacion_7"),false,false,viewMode||prop.getProperty("observacion_7").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>       
        </td>
    </tr>
    
    <tr>
        <td align="right">TIENE CRITERIO PARA SALIDA O TRASLADO</td>
        <td>
            <label class="pointer">SI&nbsp;<%=fb.radio("params_49","50",(prop.getProperty("params_49")!=null && prop.getProperty("params_49").equals("50")),viewMode,false,"", null,"","","")%></label>&nbsp;&nbsp;
            <label class="pointer">NO&nbsp;<%=fb.radio("params_49","51",(prop.getProperty("params_49")!=null && prop.getProperty("params_49").equals("51")),viewMode,false,"", null,"","","")%></label>
        </td>
        <td align="right">LA FAMILIA VISITA AL PACIENTE</td>
        <td> 
            <label class="pointer">SI&nbsp;<%=fb.radio("params_50","52",(prop.getProperty("params_50")!=null && prop.getProperty("params_50").equals("52")),viewMode,false,"", null,"","","")%></label>&nbsp;&nbsp;
            <label class="pointer">NO&nbsp;<%=fb.radio("params_50","56",(prop.getProperty("params_50")!=null && prop.getProperty("params_50").equals("56")),viewMode,false,"", null,"","","")%></label>
        </td>
    </tr>
    
    <tr>
        <td align="right">OTRO ASUNTO QUE ATENDER (SALIDA)</td>
        <td>
            <label class="pointer">
                <%=fb.checkbox("params_51","53",(prop.getProperty("params_51").equals("53")),viewMode,"","","","")%>&nbsp;Social</label></br>
            <label class="pointer">
                <%=fb.checkbox("params_52","54",(prop.getProperty("params_52").equals("54")),viewMode,"","","","")%>&nbsp;Emocional</label></br>
            <label class="pointer">
                <%=fb.checkbox("params_53","55",(prop.getProperty("params_53").equals("55")),viewMode,"","","","")%>&nbsp;N/A</label></br>
        </td>
        <td colspan="2" class="controls form-inline">
            MEDICO:&nbsp;
            <%=fb.hidden("medico", prop.getProperty("medico"))%>
            <%=fb.textBox("medico_nombre",prop.getProperty("medico_nombre"),false,false,true,30,"form-control input-sm","display:inline; width:300px",null)%>
            <%=fb.button("btn_medico","...",true,viewMode,null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%><br>
            ENFERMERA:&nbsp;
            <%=fb.hidden("enfermera", prop.getProperty("enfermera"))%>
            <%=fb.textBox("enfermera_nombre",prop.getProperty("enfermera_nombre"),false,false,true,30,"form-control input-sm","display:inline; width:300px",null)%>
            <%=fb.button("btn_medico","...",true,viewMode,null,null,"onClick=\"javascript:empleadoList(1)\"","seleccionar enfermera")%><br>
            TERAPISTA RESPIRATORIA:&nbsp;
            <%=fb.hidden("terapista", prop.getProperty("terapista"))%>
            <%=fb.textBox("terapista_nombre",prop.getProperty("terapista_nombre"),false,false,true,30,"form-control input-sm","display:inline; width:300px",null)%>
            <%=fb.button("btn_medico","...",true,viewMode,null,null,"onClick=\"javascript:empleadoList(2)\"","seleccionar terapista")%><br>
            FARMACIA:&nbsp;
            <%=fb.hidden("farmacia", prop.getProperty("farmacia"))%>
            <%=fb.textBox("farmacia_nombre",prop.getProperty("farmacia_nombre"),false,false,true,30,"form-control input-sm","display:inline; width:300px",null)%>
            <%=fb.button("btn_medico","...",true,viewMode,null,null,"onClick=\"javascript:empleadoList(3)\"","seleccionar farmacista")%><br>
            NUTRICION:&nbsp;
            <%=fb.hidden("nutricion", prop.getProperty("nutricion"))%>
            <%=fb.textBox("nutricion_nombre",prop.getProperty("nutricion_nombre"),false,false,true,30,"form-control input-sm","display:inline; width:300px",null)%>
            <%=fb.button("btn_medico","...",true,viewMode,null,null,"onClick=\"javascript:empleadoList(4)\"","seleccionar farmacista")%><br>
            SUPERVISOR / JEFA:&nbsp;
            <%=fb.hidden("supervisor", prop.getProperty("supervisor"))%>
            <%=fb.textBox("supervisor_nombre",prop.getProperty("supervisor_nombre"),false,false,true,30,"form-control input-sm","display:inline; width:300px",null)%>
            <%=fb.button("btn_medico","...",true,viewMode,null,null,"onClick=\"javascript:empleadoList(5)\"","seleccionar farmacista")%>
        </td>
    </tr>


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
    prop.setProperty("usuario_creacion", UserDet.getUserName());
    prop.setProperty("fecha_creacion", cDateTime);
    prop.setProperty("usuario_modificacion", UserDet.getUserName());
    prop.setProperty("fecha_modificacion", cDateTime);
    prop.setProperty("medico", request.getParameter("medico"));
    prop.setProperty("medico_nombre", request.getParameter("medico_nombre"));
    prop.setProperty("enfermera", request.getParameter("enfermera"));
    prop.setProperty("enfermera_nombre", request.getParameter("enfermera_nombre"));
    prop.setProperty("terapista_nombre", request.getParameter("terapista_nombre"));
    prop.setProperty("terapista", request.getParameter("terapista"));
    prop.setProperty("farmacia_nombre", request.getParameter("farmacia_nombre"));
    prop.setProperty("farmacia", request.getParameter("farmacia"));
    prop.setProperty("nutricion_nombre", request.getParameter("nutricion_nombre"));
    prop.setProperty("nutricion", request.getParameter("nutricion"));
    prop.setProperty("supervisor_nombre", request.getParameter("supervisor_nombre"));
    prop.setProperty("supervisor", request.getParameter("supervisor"));
         
    for (int i = 0; i < 60; i++) {
        if(request.getParameter("params_"+i)!=null) prop.setProperty("params_"+i, request.getParameter("params_"+i));
        if(request.getParameter("observacion_"+i)!=null) prop.setProperty("observacion_"+i, request.getParameter("observacion_"+i));
    }
    
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add")){
        RUCIMgr.add(prop);
        code = RUCIMgr.getPkColValue("codigo");
    }
    else RUCIMgr.update(prop);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow(){
<% if (RUCIMgr.getErrCode().equals("1")) { %>
	alert('<%=RUCIMgr.getErrMsg()%>');
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
} else throw new Exception(RUCIMgr.getErrMsg());
%>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>';}
</script>
</head>
<body onLoad="closeWindow()"></body>
</html>
<% } %>
