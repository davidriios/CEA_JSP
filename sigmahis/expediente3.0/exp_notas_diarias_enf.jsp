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
<jsp:useBean id="NDEMgr" scope="page" class="issi.expediente.NotasDiariasEnfermeriaMgr" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
NDEMgr.setConnection(ConMgr);

Properties prop = new Properties();
ArrayList al = new ArrayList();

boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (fg == null) fg = "NDE";
if (id == null) id = "0";
if (from == null) from = "";

if ( desc == null ) desc = "";
if (modeSec.equalsIgnoreCase("view")||modeSec.equalsIgnoreCase("edit")) viewMode = true;
if (mode.equalsIgnoreCase("view")||mode.equalsIgnoreCase("edit")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

CommonDataObject cdo = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	al = SQLMgr.getDataPropertiesList("select nota from tbl_sal_notas_diarias_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"' order by id desc ");
	prop = SQLMgr.getDataProperties("select nota from tbl_sal_notas_diarias_enf where id="+id+" and tipo_nota = '"+fg+"'");
	if (prop == null){
		prop = new Properties();
		prop.setProperty("fecha",""+cDateTime.substring(0,10));
		prop.setProperty("hora",""+cDateTime.substring(11));
	}
	else {
      modeSec = "edit";
      //if (from.trim().equalsIgnoreCase("salida_pop"))
        //cdo = SQLMgr.getData(" select condicion from tbl_sal_notas_diarias_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"' and id = "+id);
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
document.title = 'Notas de Diarias de Enfermeria - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}
function setEvaluacion(code){window.location = '../expediente3.0/exp_notas_diarias_enf.jsp?modeSec=view&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&id='+code;}
function add(){window.location = '../expediente3.0/exp_notas_diarias_enf.jsp?modeSec=add&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&id=0&from=<%=from%>';}
function checkedFecha(){var x =0;var msg ='Seleccione ';if (eval('document.form0.fecha').value == ''){x++;msg +=' fecha '}if (eval('document.form0.hora').value == ''){x++;msg += ' , Hora';}if (x>0){ alert(msg);return false;}else return true;}

function canSubmit() {
  var proceed = true;
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    if ( $self.is(":checked") && !$.trim($("#observacion"+i).val())) {
      parent.parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
      proceed = false;
      $self.focus();
      return false;
    }else  {proceed = true;}
  });

  <%//if(from.trim().equalsIgnoreCase("salida_pop")){%>
    /*if ( ! $("#condicion").val() ) {
      //parent.parent.CBMSG.error("Las siguientes pantallas dependen de la condición del paciente. Por favor selecciona!!");
      //proceed = false;
    }*/
  <%//}%>

  //if (proceed) setGenAlerta();
  return proceed;
}

$(function(){
    $(".otras_evaluaciones").click(function(e){
      var that = $(this);
      var i = that.data('index');
      var otraEval =  $("input[name='otra_evaluacion']:checked").val();
      if (!otraEval || otraEval == "N") {
        e.preventDefault();
        e.stopPropagation();
        return false;
      } else {
        if (that.is(":checked")) {
            $("#obs_otras_evaluaciones"+i).prop("readOnly", false)
        } else {
            $("#obs_otras_evaluaciones"+i).val("").prop("readOnly", true)
        }
      }
    });

    $(".sondas").click(function(e){
      var that = $(this);
      var i = that.data('index');
      var sonda =  $("input[name='sonda']:checked").val();
      if (!sonda || sonda == "N") {
        e.preventDefault();
        e.stopPropagation();
        return false;
      } else {
        if (that.is(":checked")){
          if (that.val() == 'OT') $("#observacion8").prop("readOnly", false)

        } else $("#observacion8").prop("readOnly", true).val("")
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

    $('input[name="cardiaco_irregular_debil"]').on('click', function(event) {
        var that = $(this);
        var cardiaco = $("input[name='cardiaco']:checked").val();

        if (!cardiaco || cardiaco == 0) {
          event.preventDefault();
            event.stopPropagation();
            return false;
        }
    });

    $("input[name='cardiaco']").click(function(){
      if (this.checked && this.value == 0) $('input[name="cardiaco_irregular_debil"]').prop("checked", false)
    })

    $('input[name*="herida"]').on('click', function(event) {
        var that = $(this);
        var piel = $("input[name='piel']:checked").val();

        if (!piel || (piel == 'I' || piel == 'U')) {
          event.preventDefault();
          event.stopPropagation();
          return false;
        }
    });

});

function shouldTypeRadio(check, textareaIndex) {
  if (check == true) $("#observacion"+textareaIndex).prop("readOnly", false)
  else $("#observacion"+textareaIndex).val("").prop("readOnly", true)
}

function removeHeridas() {
  $('input[name*="herida"]').prop("checked", false)
}
function removeOtrasEval() {
 $('.otras_evaluaciones').prop("checked", false)
 $('textarea[name*="obs_otras_evaluaciones"]').val("").prop("readOnly",true)
}
function removeSondas() {
 $('.sondas').prop("checked", false)
 $('textarea[name="observacion8"]').val("").prop("readOnly",true)
}

function imprimir(){
    var condicionTitle = $("#condicion").selText();
    abrir_ventana('../expediente3.0/print_notas_diarias_enf.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&code=<%=id%>&fg=<%=fg%>&desc=<%=desc%>&cond_title='+condicionTitle);
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
<body class="body-forminside" onLoad="javascript:doAction()">

<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
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
<%=fb.hidden("from",from)%>
<%=fb.hidden("should_type_radio_tmp", "")%>

<div class="headerform2">
	<table cellspacing="0" class="table pull-right table-striped table-custom-2">
	<tr>
		<td align="right">
		<%if(!mode.trim().equals("view")){%>
		<button type="button" class="btn btn-inverse btn-sm" onclick="add()"><i class="fa fa-plus fa-printico"></i> <b>Agregar Evaluaci&oacute;n</b></button>
		<%}%>
		&nbsp;
		<%if(!id.trim().equals("") && !id.trim().equals("0")){%>
		<button type="button" class="btn btn-inverse btn-sm" onclick="imprimir()"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
		<%}%>
	</tr>
	<tr><th class="bg-headtabla">LISTADO DE RESULTADOS</th></tr>
	</table>

	<div class="table-wrapper">
		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<thead>
		<tr class="bg-headtabla2">
			<th style="vertical-align: middle !important;">C&oacute;digo</th>
			<th style="vertical-align: middle !important;">Fecha</th>
			<th style="vertical-align: middle !important;">Hora</th>
		</tr>
		</thead>
		<tbody>
		<%for (int i=1; i<=al.size(); i++){
		Properties prop1 = (Properties) al.get(i-1);
		%>
		<%=fb.hidden("id"+i,prop1.getProperty("id"))%>
		<tr onClick="javascript:setEvaluacion(<%=prop1.getProperty("id")%>)" class="pointer">
			<td><%=prop1.getProperty("id")%></td>
			<td><%=prop1.getProperty("fecha")%></td>
			<td><%=prop1.getProperty("hora")%></td>
		</tr>
		<%}%>
		</tbody>
		</table>
	</div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered">
<tbody>
<tr>
	<th colspan="11" class="bg-headtabla">NOTAS DIARIAS</th>
</tr>
<tr>
	<td align="right"><cellbytelabel id="4">Fecha</cellbytelabel>&nbsp;</td>
	<td colspan="5" class="controls form-inline">
		<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1"/>
		<jsp:param name="format" value="dd/mm/yyyy"/>
		<jsp:param name="nameOfTBox1" value="<%="fecha"%>" />
		<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
		<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
		</jsp:include>
	</td>
	<td align="right"><cellbytelabel id="5">Hora</cellbytelabel></td>
	<td colspan="4" class="controls form-inline">
		<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1"/>
		<jsp:param name="format" value="hh12:mi am"/>
		<jsp:param name="nameOfTBox1" value="<%="hora"%>" />
		<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")%>" />
		<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
		</jsp:include>
	</td>
</tr>

<% if (fg.trim().equalsIgnoreCase("NDNO")) { %>

<tr>
	<td align="right"  rowspan="2"><strong><cellbytelabel id="7">Se Recibe R. Nac.</cellbytelabel>:</strong></td>
	<td align="right"><cellbytelabel id="8">Bacinete</cellbytelabel></td>
	<td align="center"><%=fb.radio("llegada","BA",(prop.getProperty("llegada").equalsIgnoreCase("BA")),viewMode,false, null, null, null, null, null, "llegadaBA")%></td>
	<td align="right"><cellbytelabel id="9">Fototerapia</cellbytelabel></td>
	<td  align="center"><%=fb.radio("llegada","FO",(prop.getProperty("llegada").equalsIgnoreCase("FO")),viewMode,false, null, null, null, null, null, "llegadaFO")%></td>
	<td align="right"><cellbytelabel id="10">O2</cellbytelabel></td>
	<td align="center"><%=fb.radio("llegada","O2",(prop.getProperty("llegada").equalsIgnoreCase("O2")),viewMode,false, null, null, null, null, null, "llegadaO2")%></td>
	<td colspan="4"></td>
</tr>
<tr>
	<td align="center"><cellbytelabel id="11">Incubadora</cellbytelabel></td>
	<td align="right"><cellbytelabel id="12">Abierto</cellbytelabel></td>
	<td align="center"><%=fb.radio("llegada2","ABI",(prop.getProperty("llegada2").equalsIgnoreCase("ABI")),viewMode,false, null, null, null, null, null, "llegada2ABI")%></td>
	<td align="right"><cellbytelabel id="13">Cerrado</cellbytelabel></td>
	<td align="center"><%=fb.radio("llegada2","CER",(prop.getProperty("llegada2").equalsIgnoreCase("CER")),viewMode,false, null, null, null, null, null, "llegada2CER")%></td>
	<td colspan="5"></td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="14">Respiraci&oacute;n</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
	<td align="center"><%=fb.radio("respiracion","NOR",(prop.getProperty("respiracion").equalsIgnoreCase("NOR")),viewMode,false, null, null, null, null, null, "respiracionNOR")%></td>
	<td align="right"><cellbytelabel id="16">Frecuencia</cellbytelabel></td>
	<td align="center"><%=fb.radio("respiracion","FRE",(prop.getProperty("respiracion").equalsIgnoreCase("FRE")),viewMode,false, null, null, null, null, null, "respiracionFRE")%></td>
	<td width="8%" align="right"><cellbytelabel id="17">Quejido</cellbytelabel></td>
	<td width="4%"  align="center" ><%=fb.radio("respiracion","QUE",(prop.getProperty("respiracion").equalsIgnoreCase("QUE")),viewMode,false, null, null, null, null, null, "respiracionQUE")%></td>
	<td width="8%" align="right"><cellbytelabel id="18">Tiraje</cellbytelabel></td>
	<td width="5%"  align="center"><%=fb.radio("respiracion","TIR",(prop.getProperty("respiracion").equalsIgnoreCase("TIR")),viewMode,false, null, null, null, null, null, "respiracionTIR")%></td>
	<td align="right"><cellbytelabel id="19">Aleteo</cellbytelabel></td>
	<td width="16%"  align="center" ><%=fb.radio("respiracion","ALE",(prop.getProperty("respiracion").equalsIgnoreCase("ALE")),viewMode,false, null, null, null, null, null, "respiracionALE")%></td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="20">Llanto</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="21">Fuerte</cellbytelabel></td>
	<td align="center"><%=fb.radio("llanto","FU",(prop.getProperty("llanto").equalsIgnoreCase("FU")),viewMode,false, null, null, null, null, null, "llantoFU")%></td>
	<td align="right"><cellbytelabel id="22">D&eacute;bil</cellbytelabel></td>
	<td align="center"><%=fb.radio("llanto","DE",(prop.getProperty("llanto").equalsIgnoreCase("DE")),viewMode,false, null, null, null, null, null, "llantoDE")%></td>
	<td width="8%" align="right" >&nbsp;</td>
	<td width="4%"  align="center" >&nbsp;</td>
	<td width="8%" align="right" >&nbsp;</td>
	<td width="5%"  align="center" >&nbsp;</td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="23">Sist. Nervioso</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="24">Activo</cellbytelabel></td>
	<td align="center"><%=fb.radio("actividad","AC",(prop.getProperty("actividad").equalsIgnoreCase("AC")),viewMode,false, null, null, null, null, null, "actividadAC")%></td>
	<td align="right"><cellbytelabel id="25">Hipoactivo</cellbytelabel></td>
	<td align="center"><%=fb.radio("actividad","HI",(prop.getProperty("actividad").equalsIgnoreCase("HI")),viewMode,false, null, null, null, null, null, "actividadHI")%></td>
	<td align="right"><cellbytelabel id="26">Hipot&oacute;nico</cellbytelabel></td>
	<td align="center"><%=fb.radio("actividad","HIP",(prop.getProperty("actividad").equalsIgnoreCase("HIP")),viewMode,false, null, null, null, null, null, "actividadHIP")%></td>
	<td align="right"><cellbytelabel id="27">Temblores</cellbytelabel></td>
	<td align="center"><%=fb.radio("actividad","TEM",(prop.getProperty("actividad").equalsIgnoreCase("TEM")),viewMode,false, null, null, null, null, null, "actividadTEM")%></td>
	<td align="right"><cellbytelabel id="28">Convulsiones</cellbytelabel></td>
	<td align="center"><%=fb.radio("actividad","CON",(prop.getProperty("actividad").equalsIgnoreCase("CON")),viewMode,false, null, null, null, null, null, "actividadCON")%></td>
</tr>
<tr>
	<td align="right"  rowspan="3"><strong><cellbytelabel id="29">Piel</cellbytelabel></strong></td>
	<td align="right"  rowspan="3"><cellbytelabel id="30">Rosada</cellbytelabel></td>
	<td align="center" rowspan="3"><%=fb.radio("piel","AC",(prop.getProperty("piel").equalsIgnoreCase("AC")),viewMode,false, null, null, null, null, null, "pielAC")%></td>
	<td width="8%" align="right" rowspan="3"><cellbytelabel id="31">P&aacute;lida</cellbytelabel></td>
	<td width="9%"  align="center" rowspan="3"><%=fb.radio("piel","PAL",(prop.getProperty("piel").equalsIgnoreCase("PAL")),viewMode,false, null, null, null, null, null, "pielPAL")%></td>
	<td width="8%" align="right"  rowspan="3"><cellbytelabel id="32">Cianosis</cellbytelabel></td>
	<td width="4%"  align="center" rowspan="3"><%=fb.radio("piel","CIA",(prop.getProperty("piel").equalsIgnoreCase("CIA")),viewMode,false, null, null, null, null, null, "pielCIA")%></td>
	<td align="right" rowspan="3"></td>
	<td align="center" rowspan="3"><cellbytelabel id="33">Ictericia</cellbytelabel></td>
	<td align="right"><cellbytelabel id="34">Leve</cellbytelabel></td>
	<td align="center"><%=fb.radio("piel2","LE",(prop.getProperty("piel2").equalsIgnoreCase("LE")),viewMode,false, null, null, null, null, null, "piel2LE")%></td>
</tr>
<tr>
	<td align="right"><cellbytelabel id="35">Moderada</cellbytelabel></td>
	<td align="center"><%=fb.radio("piel2","MO",(prop.getProperty("piel2").equalsIgnoreCase("MO")),viewMode,false, null, null, null, null, null, "piel2MO")%></td>
</tr>
<tr>
	<td align="right"><cellbytelabel id="36">Severa</cellbytelabel></td>
	<td align="center"><%=fb.radio("piel2","SE",(prop.getProperty("piel2").equalsIgnoreCase("SE")),viewMode,false, null, null, null, null, null, "piel2SE")%></td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="37">Temperatura</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="38">Normotermico</cellbytelabel></td>
	<td align="center"><%=fb.radio("temperatura","NO",(prop.getProperty("temperatura").equalsIgnoreCase("NO")),viewMode,false, null, null, null, null, null, "temperaturaNO")%></td>
	<td align="right"><cellbytelabel id="39">Hipotermico</cellbytelabel></td>
	<td align="center"><%=fb.radio("temperatura","HI",(prop.getProperty("temperatura").equalsIgnoreCase("HI")),viewMode,false, null, null, null, null, null, "temperaturaHI")%></td>
	<td align="right"></td>
	<td align="center">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="center">&nbsp;</td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="40">Succi&oacute;n</cellbytelabel></strong> </td>
	<td align="right"><cellbytelabel id="41">Buena</cellbytelabel></td>
	<td align="center"><%=fb.radio("succion","B",(prop.getProperty("succion").equalsIgnoreCase("B")),viewMode,false, null, null, null, null, null, "succionB")%></td>
	<td align="right"><cellbytelabel id="42">Malo</cellbytelabel></td>
	<td align="center"><%=fb.radio("succion","M",(prop.getProperty("succion").equalsIgnoreCase("M")),viewMode,false, null, null, null, null, null, "succionM")%></td>
	<td width="8%" align="right" >&nbsp;</td>
	<td width="4%"  align="center" >&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="center">&nbsp;</td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="43">Higiene</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="44">General</cellbytelabel></td>
	<td align="center"><%=fb.radio("bano","G",(prop.getProperty("bano").equalsIgnoreCase("G")),viewMode,false, null, null, null, null, null, "banoG")%></td>
	<td align="right"><cellbytelabel id="45">Parcial</cellbytelabel></td>
	<td align="center"><%=fb.radio("bano","P",(prop.getProperty("bano").equalsIgnoreCase("P")),viewMode,false, null, null, null, null, null, "banoP")%></td>
	<td align="right">&nbsp;</td>
	<td align="center">&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="center">&nbsp;</td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="46">Profilaxis</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
	<td align="center"><%=fb.radio("profilaxis","S",(prop.getProperty("profilaxis").equalsIgnoreCase("S")),viewMode,false, null, null, null, null, null, "profilaxisS")%></td>
	<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
	<td align="center"><%=fb.radio("profilaxis","N",(prop.getProperty("profilaxis").equalsIgnoreCase("N")),viewMode,false, null, null, null, null, null, "profilaxisN")%></td>
	<td width="8%" align="right"  >&nbsp;</td>
	<td width="4%"  align="center" >&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="center">&nbsp;</td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="49">Ombligo</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
	<td align="center"><%=fb.radio("Ombligo","NOR",(prop.getProperty("Ombligo").equalsIgnoreCase("NOR")),viewMode,false, null, null, null, null, null, "OmbligoNOR")%></td>
	<td align="right"><cellbytelabel id="50">Secreci&oacute;n</cellbytelabel></td>
	<td align="center"><%=fb.radio("Ombligo","SEC",(prop.getProperty("Ombligo").equalsIgnoreCase("SEC")),viewMode,false, null, null, null, null, null, "OmbligoSEC")%></td>
	<td width="8%" align="right"><cellbytelabel id="51">Enrojecimiento</cellbytelabel></td>
	<td width="4%"  align="center"><%=fb.radio("Ombligo","ENR",(prop.getProperty("Ombligo").equalsIgnoreCase("ENR")),viewMode,false, null, null, null, null, null, "OmbligoENR")%></td>
	<td align="right"><cellbytelabel id="52">Hemorragia</cellbytelabel></td>
	<td align="center"><%=fb.radio("Ombligo","HEM",(prop.getProperty("Ombligo").equalsIgnoreCase("HEM")),viewMode,false, null, null, null, null, null, "OmbligoHEM")%></td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="53">Orin&oacute;</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
	<td align="center"><%=fb.radio("orino","S",(prop.getProperty("orino").equalsIgnoreCase("S")),viewMode,false, null, null, null, null, null, "orinoS")%></td>
	<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
	<td align="center"><%=fb.radio("orino","N",(prop.getProperty("orino").equalsIgnoreCase("N")),viewMode,false, null, null, null, null, null, "orinoN")%></td>
	<td width="8%" align="right"  >&nbsp;</td>
	<td width="4%"  align="center" >&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="center">&nbsp;</td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="54">Heces</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
	<td align="center"><%=fb.radio("heces","SI",(prop.getProperty("heces").equalsIgnoreCase("SI")),viewMode,false, null, null, null, null, null, "hecesSI")%></td>
	<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
	<td align="center"><%=fb.radio("heces","NO",(prop.getProperty("heces").equalsIgnoreCase("NO")),viewMode,false, null, null, null, null, null, "hecesNO")%></td>
	<td width="8%" align="right"  >&nbsp;</td>
	<td width="4%"  align="center" >&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="center">&nbsp;</td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="55">Vomit&oacute;</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
	<td align="center"><%=fb.radio("vomito","S",(prop.getProperty("vomito").equalsIgnoreCase("S")),viewMode,false, null, null, null, null, null, "vomitoS")%></td>
	<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
	<td align="center"><%=fb.radio("vomito","N",(prop.getProperty("vomito").equalsIgnoreCase("N")),viewMode,false, null, null, null, null, null, "vomitoN")%></td>
	<td width="8%" align="right"  >&nbsp;</td>
	<td width="4%"  align="center" >&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="center">&nbsp;</td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="56">Meconio</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
	<td align="center"><%=fb.radio("meconio","S",(prop.getProperty("meconio").equalsIgnoreCase("S")),viewMode,false, null, null, null, null, null, "meconioS")%></td>
	<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
	<td align="center"><%=fb.radio("meconio","N",(prop.getProperty("meconio").equalsIgnoreCase("N")),viewMode,false, null, null, null, null, null, "meconioN")%></td>
	<td width="8%" align="right"  >&nbsp;</td>
	<td width="4%"  align="center" >&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="center">&nbsp;</td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="57">Abdomen</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
	<td align="center"><%=fb.radio("abdomen","NOR",(prop.getProperty("abdomen").equalsIgnoreCase("NOR")),viewMode,false, null, null, null, null, null, "abdomenNOR")%></td>
	<td align="right"><cellbytelabel id="58">Distendido</cellbytelabel></td>
	<td align="center"><%=fb.radio("abdomen","DIS",(prop.getProperty("abdomen").equalsIgnoreCase("DIS")),viewMode,false, null, null, null, null, null, "abdomenDIS")%></td>
	<td width="8%" align="right"  >&nbsp;</td>
	<td width="4%"  align="center" >&nbsp;</td>
	<td align="right">&nbsp;</td>
	<td align="center">&nbsp;</td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="59">Relaci&oacute;n Madre-Hijo</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="60">Aceptaci&oacute;n</cellbytelabel></td>
	<td align="center"><%=fb.radio("apego","S",(prop.getProperty("apego").equalsIgnoreCase("S")),viewMode,false, null, null, null, null, null, "apegoS")%></td>
	<td width="8%" align="right"><cellbytelabel id="61">Inseguridad</cellbytelabel></td>
	<td width="9%"  align="center" ><%=fb.radio("apego","INS",(prop.getProperty("apego").equalsIgnoreCase("INS")),viewMode,false, null, null, null, null, null, "apegoINS")%></td>
	<td align="right"><cellbytelabel id="62">Rechazo</cellbytelabel></td>
	<td align="center"><%=fb.radio("apego","N",(prop.getProperty("apego").equalsIgnoreCase("N")),viewMode,false, null, null, null, null, null, "apegoN")%></td>
	<td align="right"></td>
	<td align="center"></td>
	<td align="right" colspan="2">&nbsp;</td>
</tr>
<tr>
	<td align="right"  rowspan="4"><strong><cellbytelabel id="63">Alimentaci&oacute;n</cellbytelabel></strong></td>
	<td align="right"  rowspan="4"><cellbytelabel id="64">Pecho exclusivo</cellbytelabel></td>
	<td align="center" rowspan="4"><%=fb.radio("alimentacion","PE",(prop.getProperty("alimentacion").equalsIgnoreCase("PE")),viewMode,false, null, null, null, null, null, "alimentacionPE")%></td>
	<td align="right"  rowspan="4"><cellbytelabel id="65">F&oacute;rmula</cellbytelabel></td>
	<td align="center" rowspan="4"><%=fb.radio("alimentacion","FO",(prop.getProperty("alimentacion").equalsIgnoreCase("FO")),viewMode,false, null, null, null, null, null, "alimentacionFO")%></td>
	<td width="8%" align="right"  rowspan="4" ><cellbytelabel id="66">Sonda</cellbytelabel></td>
	<td width="4%"  align="center" rowspan="4"><%=fb.radio("alimentacion","SON",(prop.getProperty("alimentacion").equalsIgnoreCase("SON")),viewMode,false, null, null, null, null, null, "alimentacionSON")%></td>
	<td width="8%" align="right"  rowspan="4" ></td>
	<td width="5%"  align="center" rowspan="4"><cellbytelabel id="67">Aceptaci&oacute;n</cellbytelabel></td>
	<td align="right"><cellbytelabel id="41">Buena</cellbytelabel></td>
	<td align="center"><%=fb.radio("alimentacionPor","SI",(prop.getProperty("alimentacionPor").equalsIgnoreCase("SI")),viewMode,false, null, null, null, null, null, "alimentacionPorSI")%></td>
</tr>
<tr>
	<td align="right"><cellbytelabel id="62">Rechazo</cellbytelabel></td>
	<td align="center"><%=fb.radio("alimentacionPor","EP",(prop.getProperty("alimentacionPor").equalsIgnoreCase("EP")),viewMode,false, null, null, null, null, null, "alimentacionPorEP")%></td>
</tr>
<tr>
	<td align="right"><cellbytelabel id="68">Regurgitaci&oacute;n</cellbytelabel></td>
	<td align="center"><%=fb.radio("alimentacionPor","OT",(prop.getProperty("alimentacionPor").equalsIgnoreCase("OT")),viewMode,false, null, null, null, null, null, "alimentacionPorOT")%></td>
</tr>
<tr>
	<td align="right"><cellbytelabel id="55">Vomit&oacute;</cellbytelabel></td>
	<td align="center"><%=fb.radio("alimentacionPor","VOM",(prop.getProperty("alimentacionPor").equalsIgnoreCase("VOM")),viewMode,false, null, null, null, null, null, "alimentacionPorVOM")%></td>
</tr>
<!--
<tr>
	<td align="right"><strong><cellbytelabel id="69">Circunscisi&oacute;n</cellbytelabel></strong></td>
	<td align="right"><cellbytelabel id="47">S&iacute;</cellbytelabel></td>
	<td align="center"><%=fb.radio("circunscision","S",(prop.getProperty("circunscision").equalsIgnoreCase("S")),viewMode,false, null, null, null, null, null, "circunscisionS")%></td>
	<td align="right"><cellbytelabel id="48">No</cellbytelabel></td>
	<td align="center"><%=fb.radio("circunscision","N",(prop.getProperty("circunscision").equalsIgnoreCase("N")),viewMode,false, null, null, null, null, null, "circunscisionN")%></td>
	<td align="right"></td>
	<td align="center"></td>
	<td align="right" colspan="6">&nbsp;</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel id="70">Destrostix</cellbytelabel></strong></td>
	<td colspan="10"><%=fb.textBox("dextroxtis",prop.getProperty("dextroxtis"),false,false,viewMode,60,"Text10",null,null)%></td>
</tr>
-->

<% } else { %>

	<%//=fb.checkbox("herida0","0",prop.getProperty("herida0")!=null&&prop.getProperty("herida0").equals("0"),viewMode,null,null,"","")%>
	<%//=fb.checkbox("herida3","OT",prop.getProperty("herida3")!=null&&prop.getProperty("herida3").equals("OT"),viewMode,"observacion",null,"",""," data-index=4 data-message='Por favor indique las heridas'")%>
<tr>
	<td align="right"><strong><cellbytelabel>Estado de Conciencia</cellbytelabel></strong></td>
	<td colspan="5">
	<label class="pointer">Alerta&nbsp;<%=fb.checkbox("estado_conciencia0","0",(prop.getProperty("estado_conciencia0")!=null && prop.getProperty("estado_conciencia0").equalsIgnoreCase("0")),viewMode,null,null,"","")%></label>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<label class="pointer">Conciente&nbsp;<%=fb.checkbox("estado_conciencia1","1",(prop.getProperty("estado_conciencia1")!=null && prop.getProperty("estado_conciencia1").equalsIgnoreCase("1")),viewMode,null,null,"","")%></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<label class="pointer">Orientado&nbsp;<%=fb.checkbox("estado_conciencia2","2",(prop.getProperty("estado_conciencia2")!=null && prop.getProperty("estado_conciencia2").equalsIgnoreCase("2")),viewMode,null,null,"","")%></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<label class="pointer">Otros&nbsp;<%=fb.checkbox("estado_conciencia3","OT",prop.getProperty("estado_conciencia3")!=null&&prop.getProperty("estado_conciencia3").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=0 data-message='Por favor indique los otros Estados de Conciencia'")%></label>
	</td>
	<td colspan="5">
	<%=fb.textarea("observacion0",prop.getProperty("observacion0"),false,false,(viewMode||prop.getProperty("observacion0").equals("")),0,1,2000,"form-control input-sm","",null)%>
	</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel>Respiración</cellbytelabel></strong></td>
	<td colspan="5">
	<label class="pointer">Eupneica&nbsp;<%=fb.radio("respiracion","0",(prop.getProperty("respiracion")!=null && prop.getProperty("respiracion").equalsIgnoreCase("0")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 1)'",null,null,"respiracion0")%></label>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<label class="pointer">Taquipnea&nbsp;<%=fb.radio("respiracion","1",(prop.getProperty("respiracion")!=null && prop.getProperty("respiracion").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 1)'",null,null,"respiracion1")%></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<label class="pointer">Apnea&nbsp;<%=fb.radio("respiracion","2",(prop.getProperty("respiracion")!=null && prop.getProperty("respiracion").equalsIgnoreCase("2")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 1)'",null,null,"respiracion2")%></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<label class="pointer">Otro&nbsp;<%=fb.radio("respiracion","OT",prop.getProperty("respiracion")!=null&&prop.getProperty("respiracion").equalsIgnoreCase("OT"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(true, 1)'",""," data-index=1 data-message='Por favor indique la Respiración'","respiracionOT")%></label>
	</td>
	<td colspan="5">
	<%=fb.textarea("observacion1",prop.getProperty("observacion1"),false,false,(viewMode||prop.getProperty("observacion1").equals("")),0,1,2000,"form-control input-sm","",null)%>
	</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel>Cardiaco</cellbytelabel></strong></td>
	<td colspan="10">
		<label class="pointer">Pulso Regular&nbsp;<%=fb.radio("cardiaco","0",(prop.getProperty("cardiaco")!=null && prop.getProperty("cardiaco").equalsIgnoreCase("0")),viewMode,false,null,null,null,null,null,"cardiaco0")%></label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">Irregular&nbsp;<%=fb.radio("cardiaco","1",(prop.getProperty("cardiaco")!=null && prop.getProperty("cardiaco").equalsIgnoreCase("1")),viewMode,false,null,null,null,null,null,"cardiaco1")%></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">Débil&nbsp;<%=fb.checkbox("cardiaco_irregular_debil","2",(prop.getProperty("cardiaco_irregular_debil")!=null && prop.getProperty("cardiaco_irregular_debil").equalsIgnoreCase("2")),viewMode,null,null,null,null)%></label>
	</td>
</tr>
<tr>
	<td align="right"><strong><cellbytelabel>Abdomen</cellbytelabel></strong></td>
	<td colspan="5">
		<label class="pointer">Suave&nbsp;<%=fb.checkbox("abdomen0","0",(prop.getProperty("abdomen0")!=null && prop.getProperty("abdomen0").equalsIgnoreCase("0")),viewMode,null,null,"","")%></label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">Distendido&nbsp;<%=fb.checkbox("abdomen1","1",(prop.getProperty("abdomen1")!=null && prop.getProperty("abdomen1").equalsIgnoreCase("1")),viewMode,null,null,"","")%></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">Timpanico&nbsp;<%=fb.checkbox("abdomen2","2",(prop.getProperty("abdomen2")!=null && prop.getProperty("abdomen2").equalsIgnoreCase("2")),viewMode,null,null,"","")%></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">Otro&nbsp;<%=fb.checkbox("abdomen3","OT",prop.getProperty("abdomen3")!=null&&prop.getProperty("abdomen3").equalsIgnoreCase("OT"),viewMode,"observacion should-type",null,"",""," data-index=2 data-message='Por favor indique La nota para el Abdomen'")%></label>
	</td>
	<td colspan="5">
	<%=fb.textarea("observacion2",prop.getProperty("observacion2"),false,false,(viewMode||prop.getProperty("observacion2").equals("")),0,1,2000,"form-control input-sm","",null)%>
	</td>
</tr>
<tr>
	<td align="right" rowspan="2"><b>Piel:</b>&nbsp;</td>
	<td colspan="5">
		<label class="pointer"><%=fb.radio("piel","I",prop.getProperty("piel")!=null&&prop.getProperty("piel").equals("I"),viewMode,false, null, null, "onClick='shouldTypeRadio(false, 3); removeHeridas()'",null,null,"pielI")%>&nbsp;Integra</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.radio("piel","U",prop.getProperty("piel")!=null&&prop.getProperty("piel").equalsIgnoreCase("U"),viewMode,false,"observacion","","onClick='shouldTypeRadio(true, 3);  removeHeridas()'",""," data-index=3 data-message='Por favor indique Las úlceras'","pielU")%>&nbsp;&Uacute;lcera</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<%=fb.radio("piel","HQ",prop.getProperty("piel")!=null&&prop.getProperty("piel").equals("HQ"),viewMode,false,null,null,null,null,null,"pielHQ")%>&nbsp;Herida quirúrgica</label>
	</td>
	<td colspan="5">
		<%=fb.textarea("observacion3",prop.getProperty("observacion3"),false,false,(viewMode||prop.getProperty("observacion3").equals("")),0,1,2000,"form-control input-sm","",null)%>
	</td>
</tr>
<tr>
	<td colspan="5">
		<label class="pointer"><%=fb.checkbox("herida0","0",prop.getProperty("herida0")!=null&&prop.getProperty("herida0").equals("0"),viewMode,null,null,"","")%>&nbsp;&Aacute;rea</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.checkbox("herida1","1",prop.getProperty("herida1")!=null&&prop.getProperty("herida1").equals("1"),viewMode,null,null,"","")%>&nbsp;Apósitos</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.checkbox("herida2","2",prop.getProperty("herida2")!=null&&prop.getProperty("herida2").equals("2"),viewMode,null,null,"","")%>&nbsp;Drenajes</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.checkbox("herida3","OT",prop.getProperty("herida3")!=null&&prop.getProperty("herida3").equals("OT"),viewMode,"observacion should-type",null,"",""," data-index=4 data-message='Por favor indique las heridas'")%>&nbsp;Otros</label>
	</td>
	<td colspan="5">
		<%=fb.textarea("observacion4",prop.getProperty("observacion4"),false,false,(viewMode||prop.getProperty("observacion4").equals("")),0,1,2000,"form-control input-sm","",null)%>
	</td>
</tr>
<tr>
	<td align="right"><b>Edema:</b>&nbsp;</td>
	<td colspan="5">
		<label class="pointer"><%=fb.radio("edema","N",prop.getProperty("edema")!=null&&prop.getProperty("edema").equals("N"),viewMode,false, null, null, "onClick='shouldTypeRadio(false, 5)'",null,null,"edemaN")%>&nbsp;NO</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("edema","S",prop.getProperty("edema")!=null&&prop.getProperty("edema").equalsIgnoreCase("S"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(true, 5)'",""," data-index=5 data-message='Por favor indique Las Edemas'","edemaS")%>&nbsp;SI</label>
	</td>
	<td colspan="5">
		<%=fb.textarea("observacion5",prop.getProperty("observacion5"),false,false,(viewMode||prop.getProperty("observacion5").equals("")),0,1,2000,"form-control input-sm","",null)%>
	</td>
</tr>
<tr>
	<td align="right"><b>Diuresis:</b>&nbsp;</td>
	<td colspan="5">
		<label class="pointer"><%=fb.radio("diuresis","0",prop.getProperty("diuresis")!=null&&prop.getProperty("diuresis").equals("0"),viewMode,false,null,null,"onClick='shouldTypeRadio(false,6)'",null,null,"diuresis0")%>&nbsp;Espontánea</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.radio("diuresis","1",prop.getProperty("diuresis")!=null&&prop.getProperty("diuresis").equals("1"),viewMode,false,null,null,"onClick='shouldTypeRadio(false,6)'",null,null,"diuresis1")%>&nbsp;Sonda Foley</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.radio("diuresis","OT",prop.getProperty("diuresis")!=null&&prop.getProperty("diuresis").equalsIgnoreCase("OT"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(true,6)'",""," data-index=6 data-message='Por favor indique El Diuresis'","diuresisOT")%>&nbsp;Otros</label>
	</td>
	<td colspan="5">
		<%=fb.textarea("observacion6",prop.getProperty("observacion6"),false,false,(viewMode||prop.getProperty("observacion6").equals("")),0,1,2000,"form-control input-sm","",null)%>
	</td>
</tr>
<tr>
	<td align="right"><b>Evacuación:</b>&nbsp;</td>
	<td colspan="10">
		<label class="pointer"><%=fb.radio("evacuacion","0",prop.getProperty("evacuacion")!=null&&prop.getProperty("evacuacion").equals("0"),viewMode,false,null,null,null,null,null,"evacuacion0")%>&nbsp;Normal</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.radio("evacuacion","1",prop.getProperty("evacuacion")!=null&&prop.getProperty("evacuacion").equals("1"),viewMode,false,null,null,null,null,null,"evacuacion1")%>&nbsp;Constipado</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.radio("evacuacion","2",prop.getProperty("evacuacion")!=null&&prop.getProperty("evacuacion").equals("2"),viewMode,false,null,null,null,null,null,"evacuacion2")%>&nbsp;Diarrea</label>
	</td>
</tr>
<tr class="bg-headtabla2">
	<th colspan="11">OTRA EVALUACIÓN&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<label class="pointer"><%=fb.radio("otra_evaluacion","N",prop.getProperty("otra_evaluacion")!=null&&prop.getProperty("otra_evaluacion").equals("N"),viewMode,false, null,null,"onClick='removeOtrasEval()'",null,null,"otra_evaluacionN")%>&nbsp;NO</label>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("otra_evaluacion","S",prop.getProperty("otra_evaluacion")!=null&&prop.getProperty("otra_evaluacion").equalsIgnoreCase("S"),viewMode,false,"",null,"","","","otra_evaluacionS")%>&nbsp;SI</label></th>
</tr>
<tr>
	<td align="right"></td>
	<td colspan="10" class="controls form-inline">
		<label class="pointer">
		<%=fb.checkbox("otras_evaluaciones0","0",prop.getProperty("otras_evaluaciones0")!=null&&prop.getProperty("otras_evaluaciones0").equals("0"),viewMode,"otras_evaluaciones",null,"",null," data-index=0")%>
		&nbsp;<b>Mamas</b></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%=fb.textarea("obs_otras_evaluaciones0",prop.getProperty("obs_otras_evaluaciones0"),false,false, true,0,1,"form-control input-sm","width:50%",null)%>
	</td>
</tr>
<tr>
	<td align="right"></td>
	<td colspan="10" class="controls form-inline">
		<label class="pointer">
		<%=fb.checkbox("otras_evaluaciones1","1",prop.getProperty("otras_evaluaciones1")!=null&&prop.getProperty("otras_evaluaciones1").equals("1"),viewMode,"otras_evaluaciones",null,"",null," data-index=1")%>
		&nbsp;<b>Utero</b></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%=fb.textarea("obs_otras_evaluaciones1",prop.getProperty("obs_otras_evaluaciones1"),false,false, true,0,1,"form-control input-sm","width:50%",null)%>
	</td>
</tr>
<tr>
	<td align="right"></td>
	<td colspan="10" class="controls form-inline">
		<label class="pointer">
		<%=fb.checkbox("otras_evaluaciones2","2",prop.getProperty("otras_evaluaciones2")!=null&&prop.getProperty("otras_evaluaciones2").equals("2"),viewMode,"otras_evaluaciones",null,"",null," data-index=2")%>
		&nbsp;<b>Loquios</b></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%=fb.textarea("obs_otras_evaluaciones2",prop.getProperty("obs_otras_evaluaciones2"),false,false, true,0,1,"form-control input-sm","width:50%",null)%>
	</td>
</tr>
<tr>
	<td align="right"></td>
	<td colspan="10" class="controls form-inline">
		<label class="pointer">
		<%=fb.checkbox("otras_evaluaciones3","3",prop.getProperty("otras_evaluaciones3")!=null&&prop.getProperty("otras_evaluaciones3").equals("3"),viewMode,"otras_evaluaciones",null,"",null," data-index=3")%>
		&nbsp;<b>Sangrado</b></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%=fb.textarea("obs_otras_evaluaciones3",prop.getProperty("obs_otras_evaluaciones3"),false,false, true,0,1,"form-control input-sm","width:50%",null)%>
	</td>
</tr>
<tr>
	<td align="right"></td>
	<td colspan="10" class="controls form-inline">
		<label class="pointer">
		<%=fb.checkbox("otras_evaluaciones4","4",prop.getProperty("otras_evaluaciones4")!=null&&prop.getProperty("otras_evaluaciones4").equals("4"),viewMode,"otras_evaluaciones",null,"",null," data-index=4")%>
		&nbsp;<b>Otros</b></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%=fb.textarea("obs_otras_evaluaciones4",prop.getProperty("obs_otras_evaluaciones4"),false,false, true,0,1,"form-control input-sm","width:50%",null)%>
	</td>
</tr>
<tr>
	<td align="right"><b>Deambulación:</b>&nbsp;</td>
	<td colspan="5">
		<label class="pointer"><%=fb.radio("deambulacion","0",prop.getProperty("deambulacion")!=null&&prop.getProperty("deambulacion").equals("0"),viewMode,false,null,null,"onClick='shouldTypeRadio(false,7)'",null,null,"deambulacion0")%>&nbsp;Independiente</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.radio("deambulacion","1",prop.getProperty("deambulacion")!=null&&prop.getProperty("deambulacion").equals("1"),viewMode,false,null,null,"onClick='shouldTypeRadio(false,7)'",null,null,"deambulacion1")%>&nbsp;Solo en cama</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.radio("deambulacion","2",prop.getProperty("deambulacion")!=null&&prop.getProperty("deambulacion").equals("2"),viewMode,false,null,null,"onClick='shouldTypeRadio(false,7)'",null,null,"deambulacion2")%>&nbsp;Asistida</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.radio("deambulacion","OT",prop.getProperty("deambulacion")!=null&&prop.getProperty("deambulacion").equalsIgnoreCase("OT"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(true,7)'",""," data-index=7 data-message='Por favor indique La Deambulación'","deambulacionOT")%>&nbsp;Otros</label>
	</td>
	<td colspan="5">
		<%=fb.textarea("observacion7",prop.getProperty("observacion7"),false,false,(viewMode||prop.getProperty("observacion7").equals("")),0,1,2000,"form-control input-sm","",null)%>
	</td>
</tr>
<tr class="bg-headtabla2">
	<th colspan="11">Sondas / Cateteres&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<label class="pointer"><%=fb.radio("sonda","N",prop.getProperty("sonda")!=null&&prop.getProperty("sonda").equals("N"),viewMode,false,null,null,"onClick='removeSondas()'",null,null,"sondaN")%>&nbsp;NO</label>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("sonda","S",prop.getProperty("sonda")!=null&&prop.getProperty("sonda").equalsIgnoreCase("S"),viewMode,false,"",null,"","","","sondaS")%>&nbsp;SI</label></th>
</tr>
<tr>
	<td colspan="6">
		<label class="pointer"><%=fb.checkbox("sondas0","0",prop.getProperty("sondas0")!=null&&prop.getProperty("sondas0").equals("0"),viewMode,"sondas",null,"")%>&nbsp;Periferico</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.checkbox("sondas1","1",prop.getProperty("sondas1")!=null&&prop.getProperty("sondas1").equals("1"),viewMode,"sondas",null,"")%>&nbsp;Cateter Epidural</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.checkbox("sondas2","2",prop.getProperty("sondas2")!=null&&prop.getProperty("sondas2").equals("2"),viewMode,"sondas",null,"")%>&nbsp;Nasoenteral</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.checkbox("sondas3","3",prop.getProperty("sondas3")!=null&&prop.getProperty("sondas3").equals("3"),viewMode,"sondas",null,"")%>&nbsp;Venoso Central</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer"><%=fb.checkbox("sondas4","OT",prop.getProperty("sondas4")!=null&&prop.getProperty("sondas4").equalsIgnoreCase("OT"),viewMode,"sondas",null,"",""," data-index=8 data-message='Por favor indique Sondas / Cateteres'")%>&nbsp;Otros</label>
	</td>
	<td colspan="5">
		<%=fb.textarea("observacion8",prop.getProperty("observacion8"),false,false,(viewMode||prop.getProperty("observacion8").equals("")),0,1,2000,"form-control input-sm","",null)%>
	</td>
</tr>
<%//if(from.trim().equalsIgnoreCase("salida_pop")){%>
<!--
<tr>
	<td colspan="11">
		<b>Seleccionar el Plan de Cuidado</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%//=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_sal_soapier_condicion where estatus = 'A'","condicion",prop.getProperty("condicion"),false,viewMode,0,"",null,"",null,"S")%>
	</td>
</tr>
-->
<%//}%>

<% } %>
</tbody>
</table>
<%//if(!fg.trim().equalsIgnoreCase("NDNO")&&from.trim().equalsIgnoreCase("salida_pop")&&cdo.getColValue("condicion")!=null&&!cdo.getColValue("condicion").equals("")){%>
<script>
	//parent.setCondUrl(134, "<%//=cdo.getColValue("condicion")%>", $("#condicion").selText());
</script>
<%//}%>

<%
fb.appendJsValidation("\n\tif (!checkedFecha()) error++;\n");
fb.appendJsValidation("if(error>0)doAction();");
%>
<div class="footerform">
<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
	<td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
	<%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>
	<button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
</tr>
</table>
</div>
<%=fb.formEnd(true)%>
</div>
</div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	prop = new Properties();

	prop.setProperty("pac_id",request.getParameter("pacId"));
	prop.setProperty("admision",request.getParameter("noAdmision"));
	prop.setProperty("tipo_nota",request.getParameter("fg"));
	prop.setProperty("id",request.getParameter("id"));

	prop.setProperty("fecha",request.getParameter("fecha"));
	prop.setProperty("hora",request.getParameter("hora"));
    prop.setProperty("usuario_creacion", UserDet.getUserName());

    if (request.getParameter("condicion") != null && !request.getParameter("condicion").equals(""))
        prop.setProperty("condicion", request.getParameter("condicion"));
    else prop.setProperty("condicion", "");

    if (fg.trim().equalsIgnoreCase("NDNO")) {
        prop.setProperty("llegada",request.getParameter("llegada"));
        prop.setProperty("llegada2",request.getParameter("llegada2"));
        prop.setProperty("respiracion",request.getParameter("respiracion"));
        prop.setProperty("llanto",request.getParameter("llanto"));
        prop.setProperty("actividad",request.getParameter("actividad"));
        prop.setProperty("piel",request.getParameter("piel"));
        prop.setProperty("piel2",request.getParameter("piel2"));
        prop.setProperty("temperatura",request.getParameter("temperatura"));
        prop.setProperty("succion",request.getParameter("succion"));

        prop.setProperty("bano",request.getParameter("bano"));
        prop.setProperty("profilaxis",request.getParameter("profilaxis"));

        prop.setProperty("Ombligo",request.getParameter("Ombligo"));
        prop.setProperty("orino",request.getParameter("orino"));
        prop.setProperty("heces",request.getParameter("heces"));
        prop.setProperty("vomito",request.getParameter("vomito"));
        prop.setProperty("meconio",request.getParameter("meconio"));
        prop.setProperty("abdomen",request.getParameter("abdomen"));
        prop.setProperty("apego",request.getParameter("apego"));
        prop.setProperty("alimentacion",request.getParameter("alimentacion"));
        prop.setProperty("alimentacionPor",request.getParameter("alimentacionPor"));
        //  prop.setProperty("circunscision",request.getParameter("circunscision"));
        //  prop.setProperty("dextroxtis",request.getParameter("dextroxtis"));


	} else if(fg.trim().equalsIgnoreCase("NDE")) {

       if (request.getParameter("respiracion") != null) prop.setProperty("respiracion",request.getParameter("respiracion"));
       if (request.getParameter("cardiaco") != null) prop.setProperty("cardiaco",request.getParameter("cardiaco"));
       if (request.getParameter("cardiaco_irregular_debil") != null) prop.setProperty("cardiaco_irregular_debil",request.getParameter("cardiaco_irregular_debil"));
       if (request.getParameter("piel") != null) prop.setProperty("piel",request.getParameter("piel"));
       if (request.getParameter("edema") != null) prop.setProperty("edema",request.getParameter("edema"));
       if (request.getParameter("diuresis") != null) prop.setProperty("diuresis",request.getParameter("diuresis"));
       if (request.getParameter("evacuacion") != null) prop.setProperty("evacuacion",request.getParameter("evacuacion"));
       if (request.getParameter("otra_evaluacion") != null) prop.setProperty("otra_evaluacion",request.getParameter("otra_evaluacion"));
       if (request.getParameter("deambulacion") != null) prop.setProperty("deambulacion",request.getParameter("deambulacion"));
       if (request.getParameter("sonda") != null) {
          prop.setProperty("sonda",request.getParameter("sonda"));
       }

       for (int i = 0; i < 11; i++) {

         if (request.getParameter("estado_conciencia"+i) != null) prop.setProperty("estado_conciencia"+i,request.getParameter("estado_conciencia"+i));
         if (request.getParameter("observacion"+i) != null) prop.setProperty("observacion"+i,request.getParameter("observacion"+i));
        if (request.getParameter("abdomen"+i) != null) prop.setProperty("abdomen"+i,request.getParameter("abdomen"+i));
         if (request.getParameter("piel") != null && request.getParameter("piel").equalsIgnoreCase("HQ") && request.getParameter("herida"+i) != null) {
           prop.setProperty("herida"+i,request.getParameter("herida"+i));
         }
         if (request.getParameter("otra_evaluacion") != null && request.getParameter("otra_evaluacion").equalsIgnoreCase("S") && request.getParameter("otras_evaluaciones"+i) != null) {
           prop.setProperty("otras_evaluaciones"+i,request.getParameter("otras_evaluaciones"+i));
           prop.setProperty("obs_otras_evaluaciones"+i,request.getParameter("obs_otras_evaluaciones"+i));
         }
         if (request.getParameter("sondas"+i) != null) prop.setProperty("sondas"+i,request.getParameter("sondas"+i));

       }
    }

	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add"))
		{
		 	NDEMgr.add(prop);
			id = NDEMgr.getPkColValue("id");
		}
		else NDEMgr.update(prop);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (NDEMgr.getErrCode().equals("1"))
{
%>
	alert('<%=NDEMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
<%
	}
	else
	{
%>
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
} else throw new Exception(NDEMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&desc=<%=desc%>&from=<%=from%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>