<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
<jsp:useBean id="EVALAPRENDIZAJE" scope="page" class="issi.expediente.NotaEvaluacionAprendizajeMgr" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
EVALAPRENDIZAJE.setConnection(ConMgr);

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode") ==null ?"add":request.getParameter("mode");
String modeSec = request.getParameter("modeSec") ==null ?"add":request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg") == null ? "" : request.getParameter("fg");
String desc = request.getParameter("desc");
String codigo = request.getParameter("codigo") == null ? "" : request.getParameter("codigo");
String key = "";
int escLastLineNo = 0;
CommonDataObject cdo = new CommonDataObject();
Properties prop = new Properties();
ArrayList al = new ArrayList();
String from = request.getParameter("from");

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (from == null) from = "";

if (request.getMethod().equalsIgnoreCase("GET")){
    if(desc==null){
      desc = "EVALUACIONES DE APRENDIZAJE";
    }
    if (!codigo.trim().equals("")) {
      prop = SQLMgr.getDataProperties("select evaluaciones from tbl_sal_eval_aprendizaje where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+codigo);
      
      if(!viewMode)modeSec= "edit";
    } 
    
    al = SQLMgr.getDataList("select codigo, usuario_creacion, to_char(fecha_creacion,'dd/mm/yyyy') fecha, to_char(fecha_creacion,'hh12:mi am') hora from tbl_sal_eval_aprendizaje where pac_id="+pacId+" and admision="+noAdmision+" order by fecha_creacion desc");
%>

<!DOCTYPE html>
<html lang="en">   
<head>
<meta charset="utf-8">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
var noNewHeight = true;
function add(){
    window.location = "../expediente3.0/exp_eval_aprendizaje.jsp?desc=<%=desc%>&pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&mode=add&modeSec=add&fg=<%=fg%>";
}
function imprimirExp() {
 abrir_ventana('../expediente3.0/print_eval_aprendizaje.jsp?desc=<%=desc%>&pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&codigo=<%=codigo%>');
}

function verEscala(codigo){
    window.location = '../expediente3.0/exp_eval_aprendizaje.jsp?&modeSec=edit&mode=edit&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codigo='+codigo
}

function canSubmit() {
	
  if ( $("input:radio[name^='relacion']:checked").length < 1 ) {
	showError('Por favor seleccionar una Relación!');
	scrollToElem($("input[name^='relacion']").get(0))
	return false;
  }
  else if ( $("input:radio[name^='nivel_educativo']:checked").length < 1 ) {
	showError('Por favor seleccionar el Nivel Educativo / alfabetización!');
	scrollToElem($("input[name^='nivel_educativo']").get(0))
	return false;
  }
  else if ( $("input:checkbox[name^='barrera']:checked").length < 1 ) {
	showError('Por favor indicar si tiene el aprendiz primario Alguna barrera o limitación para el aprendizaje!');
	scrollToElem($("input:checkbox[name^='barrera']").get(0))
	return false;
  }
  else if ( $("input:radio[name^='idioma']:checked").length < 1 ) {
	showError('Por favor indicar cuál es el idioma de preferencia del aprendiz para las instrucciones de salud!');
	scrollToElem($("input:radio[name^='idioma']").get(0))
	return false;
  }
  else if ( $("input:radio[name^='interprete']:checked").length < 1 ) {
	showError('Por favor indicar si se requiere intérprete!');
	scrollToElem($("input:radio[name^='interprete']").get(0))
	return false;
  }
  else if ( $("input:radio[name^='manera_aprender']:checked").length < 1 ) {
	showError('Por favor indicar cómo quiere el aprendiz primario conocer los nuevos conceptos!');
	scrollToElem($("input:radio[name^='manera_aprender']").get(0))
	return false;
  }
	
  var proceed = true;
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    if ( $self.is(":checked") && !$.trim($("#observacion"+i).val())) {
      showMessage(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
      proceed = false;
      $self.focus();
      return false;  
    }else  {proceed = true;}
  });
  return proceed;
}

function showMessage(msg) {
  parent.CBMSG.error(msg);
}

$(function(){
 checkViewMode();
 
 // aprendiz
 $("input[name='relacion']").click(function(c){
   if (this.checked) {
    if (this.value == 'PA') {
        var pName = $("#primerNombre", parent.document).val() + " " + $("#primerApellido", parent.document).val();
        $("#observacion7").prop("readOnly", true).val(pName);
    }
    else $("#observacion7").val("").prop("readOnly", false);
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
    
    // barreras
    $("input.barreras").click(function(){
        if(this.value == 'NT') {
            if (this.checked) {
                $("input.barreras").not($(this)).prop({
                    checked: false,
                    disabled: true
                });
                $("#observacion2").prop('readOnly', true).val('')
            } else {
               $("input.barreras").prop('disabled', false);
               $("#observacion2").prop('readOnly', false)
            }
        }
    });
    
});

function shouldTypeRadio(check, textareaIndex) {
  if (check == true) $("#observacion"+textareaIndex).prop("readOnly", false)
  else $("#observacion"+textareaIndex).val("").prop("readOnly", true)
}

function showError(message) {
  <%=from.trim().equalsIgnoreCase("salida_pop")?"parent.":""%>parent.CBMSG.error(message);
}
function scrollToElem(el) {
    $('html, body').animate({
        scrollTop: parseInt($(el).offset().top, 10)
    }, 500);
}
function verHistorial() {
  $("#hist_container").toggle();
}
</script>
</head>
<body class="body-form">
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
        <%=fb.hidden("codigo",codigo)%>
        
        <div class="headerform">
            <table class="table table-small-font table-bordered table-striped table-custom-2">
                <tr class="text-right">
                    <td>
                    <% if (!mode.trim().equals("view")){ %>
                    <button onclick="add()" type="button" class="btn btn-inverse btn-sm">
                        <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
                    </button>
                    <%}%>
                    
                    <%if(!codigo.trim().equals("")){%>
                    <%=fb.button("imprimir","Imprimir",false,false,null,null,"onclick='imprimirExp()'")%>
                    <%}%>
					
					<%if(al.size() > 0){%>
					  <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
						<i class="fa fa-eye fa-printico"></i> <b>Historial</b>
					  </button>
					<%}%>
                </tr>
            </table>
            
            <div class="table-wrapper" id="hist_container" style="display:none">
                <table cellspacing="0" class="table table-small-font table-bordered table-striped" style="margin-bottom:0px !important;">
                    <thead>
						<tr><th colspan="7" class="bg-headtabla"><cellbytelabel>LISTADO DE EVALUACIONES DEL APRENDIZAJE</cellbytelabel></th>
                        <tr class="bg-headtabla2" >
                            <th style="vertical-align: middle !important;">C&oacute;digo</th>
                            <th style="vertical-align: middle !important;">Fecha</th>
                            <th style="vertical-align: middle !important;">Hora</th>
                            <th style="vertical-align: middle !important;">Usuario</th>
                       </tr>
                    </thead>
                    <tbody>
                      <% for (int i = 0; i < al.size(); i++){
                        cdo = (CommonDataObject) al.get(i);%>
                        <tr style="cursor:pointer " onClick="javascript:verEscala(<%=cdo.getColValue("codigo")%>,'view')">
                            <td><%=cdo.getColValue("codigo")%></td>
                            <td><%=cdo.getColValue("fecha")%></td>
                            <td><%=cdo.getColValue("hora")%></td>
                            <td><%=cdo.getColValue("usuario_creacion")%></td>
                        </tr>
                      <%}%>
                    </tbody>
                </table>
            </div>
        </div>
        
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">

        <tr>
            <td colspan="4" class="controls form-inline">
              Fecha &nbsp;
              <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1"/>
                    <jsp:param name="dformat" value="dd/mm/yy"/>
                    <jsp:param name="tformat" value="hh:mm TT"/>
                    <jsp:param name="nameOfTBox1" value="fecha_creacion" />
                    <jsp:param name="valueOfTBox1" value="<%=!"".equals(prop.getProperty("fecha_creacion")) ? prop.getProperty("fecha_creacion") : cDateTime%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    <jsp:param name="jqui" value="y"/>
                </jsp:include>
            </td>
        </tr> 

          <tr>
            <td><strong>Relaci&oacute;n</strong></td>
            <td class="controls form-inline">
                <label class="pointer"><%=fb.radio("relacion","PA",prop.getProperty("relacion")!=null&&prop.getProperty("relacion").equals("PA"),viewMode,false,"observacion","","onclick='shouldTypeRadio(true,7);shouldTypeRadio(false,0)'",""," data-index=7 data-message='Por favor indicar el nombre del aprendiz!'")%>&nbsp;Paciente</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("relacion","FA",prop.getProperty("relacion")!=null&&prop.getProperty("relacion").equals("FA"),viewMode,false,"observacion","","onclick='shouldTypeRadio(true,7);shouldTypeRadio(false,0)'",""," data-index=7 data-message='Por favor indicar el nombre del aprendiz!'")%>&nbsp;Familia</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("relacion","OT",prop.getProperty("relacion")!=null&&prop.getProperty("relacion").equals("OT"),viewMode,false,"observacion","","onclick='shouldTypeRadio(true,0)'",""," data-index=0 data-message='Por favor indicar las otras relaciones!'")%>&nbsp;Otro</label>
            </td>
            <td>Observaci&oacute;n
            <%=fb.textarea("observacion0",prop.getProperty("observacion0"),false,false,(viewMode||prop.getProperty("observacion0").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
          </tr>
          
          <tr>
            <td width="20%">Nombre del Aprendiz</td>
            <td width="40%">
                <%=fb.textBox("observacion7", prop.getProperty("observacion7"),false,false,(viewMode||prop.getProperty("observacion7").equals("")),100,"form-control input-sm",null,null)%>
            </td>
            <td width="40%">&nbsp;</td>
          </tr>
          
          <tr>
            <td><strong>Nivel Educativo / alfabetizaci&oacute;n</strong></td>
            <td class="controls form-inline">
                <label class="pointer"><%=fb.radio("nivel_educativo","PR",prop.getProperty("nivel_educativo")!=null&&prop.getProperty("nivel_educativo").equals("PR"),viewMode,false,null,null,"onClick='shouldTypeRadio(false, 1)'")%>&nbsp;Primarios</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("nivel_educativo","SE",prop.getProperty("nivel_educativo")!=null&&prop.getProperty("nivel_educativo").equals("SE"),viewMode,false,null,null,"onClick='shouldTypeRadio(false, 1)'")%>&nbsp;Secundaria</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("nivel_educativo","UN",prop.getProperty("nivel_educativo")!=null&&prop.getProperty("nivel_educativo").equals("UN"),viewMode,false,null,null,"onClick='shouldTypeRadio(false, 1)'")%>&nbsp;Universitario</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("nivel_educativo","LEES",prop.getProperty("nivel_educativo")!=null&&prop.getProperty("nivel_educativo").equals("LEES"),viewMode,false,null,null,"onClick='shouldTypeRadio(false, 1)'")%>&nbsp;Solo lee y escribe</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("nivel_educativo","AN",prop.getProperty("nivel_educativo")!=null&&prop.getProperty("nivel_educativo").equals("AN"),viewMode,false,null,null,"onClick='shouldTypeRadio(false, 1)'")%>&nbsp;Analfabeto</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("nivel_educativo","OT",prop.getProperty("nivel_educativo")!=null&&prop.getProperty("nivel_educativo").equals("OT"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(true, 1)'",""," data-index=1 data-message='Por favor indicar los otros niveles educativos!'")%>&nbsp;Otro</label>
            </td>
            <td>Observaci&oacute;n
            <%=fb.textarea("observacion1",prop.getProperty("observacion1"),false,false,(viewMode||prop.getProperty("observacion1").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
          </tr>
          
          <tr>
            <td><b>¿Tiene el aprendiz primario Alguna barrera o limitación para el aprendizaje?</b></td>
            <td class="controls form-inline">
              <label class="pointer"><%=fb.checkbox("barrera0","NT",prop.getProperty("barrera0")!=null&&prop.getProperty("barrera0").equals("NT"),viewMode,"barreras",null,"","")%>&nbsp;No Tiene</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.checkbox("barrera1","LEC",prop.getProperty("barrera1")!=null&&prop.getProperty("barrera1").equals("LEC"),viewMode,"barreras",null,"","")%>&nbsp;Lectura</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.checkbox("barrera3","VIS",prop.getProperty("barrera3")!=null&&prop.getProperty("barrera3").equals("VIS"),viewMode,"barreras",null,"","")%>&nbsp;Visual</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.checkbox("barrera4","AUD",prop.getProperty("barrera4")!=null&&prop.getProperty("barrera4").equals("AUD"),viewMode,"barreras",null,"","")%>&nbsp;Auditiva</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.checkbox("barrera5","FIS",prop.getProperty("barrera5")!=null&&prop.getProperty("barrera5").equals("FIS"),viewMode,"barreras",null,"","")%>&nbsp;F&iacute;sica</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.checkbox("barrera6","EMO",prop.getProperty("barrera6")!=null&&prop.getProperty("barrera6").equals("EMO"),viewMode,"barreras",null,"","")%>&nbsp;Emocional</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.checkbox("barrera7","CUL",prop.getProperty("barrera7")!=null&&prop.getProperty("barrera7").equals("CUL"),viewMode,"barreras",null,"","")%>&nbsp;Cultural</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.checkbox("barrera8","OT",prop.getProperty("barrera8")!=null&&prop.getProperty("barrera8").equals("OT"),viewMode,"observacion should-type barreras",null,"",""," data-index=2 data-message='Por favor indicar las otras barreras o limitaciones para el aprendizaje!'")%>&nbsp;Otro</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </td>
            <td>Observaci&oacute;n
            <%=fb.textarea("observacion2",prop.getProperty("observacion2"),false,false,(viewMode||prop.getProperty("observacion2").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
          </tr>
          
          <tr>
            <td><b>¿Cuál es el idioma de preferencia del aprendiz para las instrucciones de salud?</b></td>
            <td>
              <label class="pointer"><%=fb.radio("idioma","ES",prop.getProperty("idioma")!=null&&prop.getProperty("idioma").equals("ES"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,3)'")%>&nbsp;Espa&ntilde;ol</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("idioma","EN",prop.getProperty("idioma")!=null&&prop.getProperty("idioma").equals("EN"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,3)'")%>&nbsp;Ingl&eacute;s</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("idioma","OT",prop.getProperty("idioma")!=null&&prop.getProperty("idioma").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,3)'",""," data-index=3 data-message='Por favor indicar las otras preferencias del aprendiz para las instrucciones de salud!'")%>&nbsp;Otro</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </td>
            <td>Observaci&oacute;n
            <%=fb.textarea("observacion3",prop.getProperty("observacion3"),false,false,(viewMode||prop.getProperty("observacion3").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
          </tr>
          
          <tr>
            <td><b>¿Se requiere int&eacute;rprete?</b></td>
            <td>
              <label class="pointer"><%=fb.radio("interprete","N",prop.getProperty("interprete")!=null&&prop.getProperty("interprete").equals("N"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,5)'")%>&nbsp;NO</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("interprete","S",prop.getProperty("interprete")!=null&&prop.getProperty("interprete").equals("S"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,5)'",""," data-index=5 data-message='Por favor se requiere ingresar informaciones cuando no se requiere intérprete!'")%>&nbsp;SI</label>
            </td>
            <td>
              <%=fb.textarea("observacion5",prop.getProperty("observacion5"),false,false,(viewMode||prop.getProperty("observacion5").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
          </tr>
          
          <tr>
            <td><b>Disposici&oacute;n para el aprendizaje</b></td>
            <td>
              <label class="pointer"><%=fb.radio("disposicion_aprendizaje","S",prop.getProperty("disposicion_aprendizaje")!=null&&prop.getProperty("disposicion_aprendizaje").equals("S"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,6)'")%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("disposicion_aprendizaje","N",prop.getProperty("disposicion_aprendizaje")!=null&&prop.getProperty("disposicion_aprendizaje").equals("N"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,6)'",""," data-index=6 data-message='Por favor se requiere ingresar informaciones cuando no hay disposición para el aprendizaje!'")%>&nbsp;NO</label>
            </td>
            <td>
              <%=fb.textarea("observacion6",prop.getProperty("observacion6"),false,false,(viewMode||prop.getProperty("observacion6").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
          </tr>

          <tr>
            <td><b>¿Cómo quiere el aprendiz primario conocer los nuevos conceptos?</b></td>
            <td>
                <label class="pointer"><%=fb.radio("manera_aprender","ES",prop.getProperty("manera_aprender")!=null&&prop.getProperty("manera_aprender").equals("ES"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,4)'")%>&nbsp;Escuchar</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("manera_aprender","LE",prop.getProperty("manera_aprender")!=null&&prop.getProperty("manera_aprender").equals("LE"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,4)'")%>&nbsp;Leer</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("manera_aprender","DE",prop.getProperty("manera_aprender")!=null&&prop.getProperty("manera_aprender").equals("DE"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,4)'")%>&nbsp;Demostraci&oacute;n</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("manera_aprender","TA",prop.getProperty("manera_aprender")!=null&&prop.getProperty("manera_aprender").equals("TA"),viewMode,false,null,null,"onclick='shouldTypeRadio(false,4)'")%>&nbsp;Taller</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("manera_aprender","OT",prop.getProperty("manera_aprender")!=null&&prop.getProperty("manera_aprender").equals("OT"),viewMode,false,"observacion",null,"onclick='shouldTypeRadio(true,4)'",""," data-index=4 data-message='Por favor indicar si requiere conocer los nuevos conceptos!'")%>&nbsp;Otro</label>
            </td>
            <td>Observaci&oacute;n
            <%=fb.textarea("observacion4",prop.getProperty("observacion4"),false,false,(viewMode||prop.getProperty("observacion4").equals("")),0,1,2000,"form-control input-sm","",null)%>
            </td>
          </tr>
        <table>
        
        <div class="footerform">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
            <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                    
                <%=fb.submit("save","Guardar",viewMode,false,"",null,"")%>
                
                <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
            </tr>
            </table> 
        </div>

        <%=fb.formEnd(true)%>
        </div>
    </div>
</body>
</html>
<%} else  {

    String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	prop = new Properties();

	prop.setProperty("pac_id",request.getParameter("pacId"));
	prop.setProperty("admision",request.getParameter("noAdmision"));
	prop.setProperty("nombre_aprendiz",request.getParameter("nombre_aprendiz"));
	prop.setProperty("fecha_creacion", request.getParameter("fecha_creacion").replaceAll("\\.",""));
	prop.setProperty("usuario_creacion", (String) session.getAttribute("_userName"));
	
	if (modeSec.trim().equalsIgnoreCase("edit")) {
      prop.setProperty("codigo",request.getParameter("codigo"));
	} else {
     cdo = SQLMgr.getData("select nvl(max(codigo),0)+1 as next_id from tbl_sal_eval_aprendizaje");
     
     prop.setProperty("codigo",cdo.getColValue("next_id"));
	}
    
    if (request.getParameter("relacion")!=null) prop.setProperty("relacion",request.getParameter("relacion"));
    if (request.getParameter("nivel_educativo")!=null) prop.setProperty("nivel_educativo",request.getParameter("nivel_educativo"));
    if (request.getParameter("idioma")!=null) prop.setProperty("idioma",request.getParameter("idioma"));
    if (request.getParameter("interprete")!=null) prop.setProperty("interprete",request.getParameter("interprete"));
    if (request.getParameter("disposicion_aprendizaje")!=null) prop.setProperty("disposicion_aprendizaje",request.getParameter("disposicion_aprendizaje"));
    if (request.getParameter("manera_aprender")!=null) prop.setProperty("manera_aprender",request.getParameter("manera_aprender"));
    
    for (int o = 0; o < 17; o++ ){
      if (request.getParameter("barrera"+o)!=null) {
        prop.setProperty("barrera"+o, request.getParameter("barrera"+o));
      }
      if(request.getParameter("observacion"+o)!=null && !request.getParameter("observacion"+o).trim().equals(""))prop.setProperty("observacion"+o, request.getParameter("observacion"+o));
    }
    
    if (modeSec.trim().equalsIgnoreCase("edit")) {
      prop.setProperty("usuario_modificacion", (String) session.getAttribute("_userName"));
      prop.setProperty("fecha_modificacion", cDateTime);
    }
        
    if (baction.equalsIgnoreCase("Guardar")){
      ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
      if (modeSec.equalsIgnoreCase("add")) EVALAPRENDIZAJE.add(prop);
          else EVALAPRENDIZAJE.update(prop);
      ConMgr.clearAppCtx(null);
    }
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (EVALAPRENDIZAJE.getErrCode().equals("1"))
{
%>
	alert('<%=EVALAPRENDIZAJE.getErrMsg()%>');
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
} else throw new Exception(EVALAPRENDIZAJE.getErrException());
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&codigo=<%=codigo%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%    
}
%>