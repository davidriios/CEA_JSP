<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="EvalDiagSalMgr" scope="page" class="issi.expediente.EvaluacionDiagSalidaMgr" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDiag" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiag" scope="session" class="java.util.Vector" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
EvalDiagSalMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();
boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String codigo = request.getParameter("codigo");
String fechaCreacionDiag = request.getParameter("fecha_creacion_diag");
String horaCreacionDiag = request.getParameter("hora_creacion_diag");
String active0 = "", active1 = "", active2 = "", active3 = "";
Properties prop1 = new Properties();
Properties prop2 = new Properties();

if (codigo == null) codigo = "0";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (mode.trim().equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String tab = request.getParameter("tab");
String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String key = "";
String from = request.getParameter("from") == null ? "": request.getParameter("from");

if (tab == null) tab = "0";

if (tab.equals("0")) active0 = "active";
else if (tab.equals("1")) active1 = "active";
else if (tab.equals("2")) active2 = "active";
else if (tab.equals("3")) active3 = "active";

if (fechaCreacionDiag == null) fechaCreacionDiag = cDateTime.substring(0, 11);
if (horaCreacionDiag == null) horaCreacionDiag = CmnMgr.getCurrentDate("hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
sql="select sexo from tbl_adm_paciente where pac_id = "+pacId;
cdo1 = SQLMgr.getData(sql);
if(cdo1 == null){
    cdo1 =  new CommonDataObject();
    //if (!viewMode) modeSec = "add";
}
//else if (!viewMode) modeSec = "edit";

boolean outterData = false;

prop1 = SQLMgr.getDataProperties("select evaluacion from tbl_sal_eval_diag_salida where tipo = 'VIH' and pac_id = "+pacId+"and admision = "+noAdmision+(!codigo.equals("0")?" and codigo = "+codigo:""));
prop2 = SQLMgr.getDataProperties("select evaluacion from tbl_sal_eval_diag_salida where tipo = 'OTH' and pac_id = "+pacId+"and admision = "+noAdmision+(!codigo.equals("0")?" and codigo = "+codigo:""));

if (prop1 == null) {
  prop1 = new Properties();
  prop1.setProperty("action", "I");
} else prop1.setProperty("action", "U");

if (prop2 == null) {
  prop2 = new Properties();
  prop2.setProperty("action", "I");
} else prop2.setProperty("action", "U");

if(change == null)
{
	iDiag.clear();
	vDiag.clear();
	// DIAGNOSTICOS DE SALIDA.
	sql = "select a.diagnostico, a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'S' order by a.orden_diag";
  al = SQLMgr.getDataList(sql);
  
  if (al.size() == 0 ){
     al = SQLMgr.getDataList("select sd.cod_diag_sal as diagnostico, 'S' tipo, sd.usuario_creacion, to_char(sd.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, to_char(sd.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion, 1 orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from  tbl_sal_adm_salida_datos sd, tbl_cds_diagnostico b  where sd.cod_diag_sal=b.codigo and sd.pac_id = "+pacId+" and sd.secuencia = "+noAdmision);
     outterData = true;
  }
  
  for (int i=0; i<al.size(); i++)
  {
	 cdo = (CommonDataObject) al.get(i);
  	 cdo.setKey(i);
	 if(outterData)cdo.setAction("I");
	 else cdo.setAction("U");
    try
    {
      iDiag.put(cdo.getKey(),cdo);
      vDiag.addElement(cdo.getColValue("diagnostico")+"-S");
    }
    catch(Exception e)
    {
      System.err.println(e.getMessage());
    }
  }
}//change

if (!viewMode && al.size() > 0 ) mode = "edit";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
document.title = 'EXPEDIENTE-DIAGNOSTICOS DE SALIDA '+document.title;
var noNewHeight = true;
function doAction(){<%if(!from.equals("salida_pop")){%><%}%><%if (request.getParameter("type") != null){%> showDiagnosticoList();<%}%>}
function imprimir(){abrir_ventana1('../expediente/print_datos_salida.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');}
function showDiagnosticoList(){ 
var f = $("#fecha_creacion_diag").val() || '<%=fechaCreacionDiag%>';
var t = $("#hora_creacion_diag").val() || '<%=horaCreacionDiag%>';
abrir_ventana1('../common/check_diagnostico.jsp?seccion=<%=seccion%>&fp=pSalida&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&from=<%=from%>&exp=3&tab=<%=tab%>&fecha_creacion_diag='+f+'&hora_creacion_diag='+t);}
function printExp(){abrir_ventana("../expediente3.0/print_exp_seccion_88.jsp?seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>");}
function canSubmit() {
  var proceed = true;
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    if ( $self.is(":checked") && !$.trim($("#observacion"+i).val())) {
      <%=from.trim().equalsIgnoreCase("salida_pop")?"parent.":""%>parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
      proceed = false;
      $self.focus();
      return false;  
    }else  {proceed = true;}
  });
  return proceed;
}

$(function(){
  $(".observacion").click(function(){
    var self = $(this);
    var i = self.data('index');
    if (self.attr('type') == 'radio') {   
        if (self.is(":checked") && self.val() == '27') {
          $("#pVal").val('27');
          $("#observacion"+i).prop("readOnly", false)
          $("#resetobservacion"+i).prop("disabled", false);
        } else {
           i = $("#pVal").val()
           $("#observacion"+i).prop("readOnly", true).val("");
           $("#resetobservacion"+i).prop("disabled", true);
        }
    } else {
       if ( self.is(":checked") ) {
         $("#observacion"+i).prop("readOnly", false)
       } else $("#observacion"+i).prop("readOnly", true).val("")
    }
  });
  
  $("a[href='#enfermedad_notificable']").click(function(e){
    container = $("#enfermedad_notificable_container");
    url = "../expediente3.0/exp_enfermedad_notificable.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=S&seccion=<%=seccion%>&desc=<%=desc%>";
    if (!container.attr('src')) container.attr('src', url);
  });
  
});

function showLugares() {
  abrir_ventana('../common/search_ubicacion_geo.jsp?fp=datos_salida');
}
function isValidPriorityOLD(){
	var diagSize=parseInt(document.form0.diagSize.value,10);
	var hasFirst=false;
	if(diagSize==1){
		i=0;
		if(eval('document.form0.action'+i).value!='D'&&eval('document.form0.ordenDiag'+i).value==1)hasFirst=true;
	}else{
		for(i=0;i<diagSize-1;i++){
			if(eval('document.form0.action'+i).value!='D'){
				if(eval('document.form0.ordenDiag'+i).value==1)hasFirst=true;
				for(j=i+1;j<diagSize;j++){
					if(eval('document.form0.action'+i).value!='D'){
						if(eval('document.form0.ordenDiag'+j).value==1)hasFirst=true;
						if(eval('document.form0.ordenDiag'+i).value==eval('document.form0.ordenDiag'+j).value){
							alert('No se permiten diagnósticos con la misma prioridad!');
							eval('document.form0.ordenDiag'+j).value='';
							return false;
						}
					}
				}
			}
		}
	}
	if(diagSize==0){alert('Agregar por lo menos un diagnóstico!');return false;}
	else if(!hasFirst){alert('Las prioridades de los diagnósticos deben iniciar con 1!');return false;}
	return true;
}

function isValidPriority(){
	var priorities = $("input[name*='ordenDiag']")
		.not(".deleting")
		.map(function(){return this.value}).get();
	
	if(!priorities.length) return true;
		
	if (hasDuplicate(priorities)) {
		alert('No se permiten diagnósticos con la misma prioridad!');
		return false;
	}
	
	if (!priorities.includes("1")) {
		alert('Las prioridades de los diagnósticos deben iniciar con 1!');
		return false;
	}
	
	return true;
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
<body class="body-form"onLoad="javascript:doAction()">
<div class="row">    
<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-1">
    <tr>
        <td>
            <%=fb.button("imprimir","imprimir",false,false,null,null,"onClick=\"javascript:printExp()\"")%>
        </td>
    </tr>
</table>
</div>

<ul class="nav nav-tabs" role="tablist" id="app-tabs">
    <li role="presentation" class="<%=active0%>">
        <a href="#datos_de_salida" aria-controls="datos_de_salida" role="tab" data-toggle="tab"><b>Datos de salida</b></a>
    </li>
    <%if (!mode.equalsIgnoreCase("add")) {%>
       <!--
       <li role="presentation" class="<%=active1%>">
         <a href="#evaluacion_vih" aria-controls="evaluacion_vih" role="tab" data-toggle="tab"><b>Evaluaci&oacute;n VIH</b></a>
       </li>
       <li role="presentation" class="<%=active2%>">
         <a href="#evaluacion_otras" aria-controls="evaluacion_otras" role="tab" data-toggle="tab"><b>Evaluaci&oacute;n Otras</b></a>
       </li>
       -->
       <li role="presentation" class="<%=active3%>">
         <a href="#enfermedad_notificable" aria-controls="enfermedad_notificable" role="tab" data-toggle="tab"><b>Enfermedad Notificable</b></a>
       </li>
    <%}%>
</ul>
<div class="tab-content">
    <div role="tabpanel" class="tab-pane <%=active0%>" id="datos_de_salida">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar' && document."+fb.getFormName()+".baction.value!='Siguiente')return true;");%>
<%fb.appendJsValidation("if(document.form0.baction.value=='Guardar'&&!isValidPriority())error++;");%>
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
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("pVal","")%>
<table cellspacing="0" class="table table-small-font table-bordered">
    <%
       CommonDataObject cdoD = new CommonDataObject();
       if (request.getParameter("fecha_creacion_diag") == null && request.getParameter("hora_creacion_diag") == null) {
          cdoD = SQLMgr.getData("select to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha_creacion_diag, to_char(a.fecha_creacion, 'hh12:mi:ss am') as hora_creacion_diag from tbl_adm_diagnostico_x_admision a where a.admision="+noAdmision+" and a.pac_id="+pacId+" and a.tipo = 'S' order by a.orden_diag");
          if (cdoD == null) cdoD = new CommonDataObject();
       }
     %>
    <tr class="bg-headtabla2">
         <td class="controls form-inline" colspan="4">
            Fecha:&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="fecha_creacion_diag" />
            <jsp:param name="format" value="dd/mm/yyyy" />
            <jsp:param name="readonly" value="<%=viewMode ? "y" : ""%>" />
            <jsp:param name="valueOfTBox1" value="<%=cdoD.getColValue("fecha_creacion_diag",  fechaCreacionDiag)%>" />
            </jsp:include>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            Hora::&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="hora_creacion_diag" />
            <jsp:param name="format" value="hh12:mi:ss am" />
            <jsp:param name="readonly" value="<%=viewMode ? "y" : ""%>" />
            <jsp:param name="valueOfTBox1" value="<%=cdoD.getColValue("hora_creacion_diag",  horaCreacionDiag)%>" />
            </jsp:include>
          </td>
    </tr>
    <tr class="bg-headtabla" align="center">
      <td width="15%"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
      <td width="65%"><cellbytelabel id="4">Nombre</cellbytelabel></td>
      <td width="10%"><cellbytelabel id="5">Prioridad</cellbytelabel></td>
      <td width="5%"><%=fb.submit("addDiagnostico","+",false,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"","Agregar Diagnósticos")%></td>
    </tr>
	<%
	al.clear();
	al = CmnMgr.reverseRecords(iDiag);
	for (int i=0; i<iDiag.size(); i++){
		key = al.get(i).toString();
		cdo = (CommonDataObject) iDiag.get(key);
    %>
    <%=fb.hidden("remove"+i,"")%>
    <%=fb.hidden("diagnostico"+i,cdo.getColValue("diagnostico"))%>
    <%=fb.hidden("diagnosticoDesc"+i,cdo.getColValue("diagnosticoDesc"))%>
    <%=fb.hidden("usuarioCreacion"+i,cdo.getColValue("usuario_creacion"))%>
    <%=fb.hidden("fechaCreacion"+i,cdo.getColValue("fecha_creacion"))%>
    <%=fb.hidden("usuarioModificacion"+i,cdo.getColValue("usuario_modificacion"))%>
    <%=fb.hidden("fechaModificacion"+i,cdo.getColValue("fecha_modificacion"))%>
    <%=fb.hidden("action"+i,cdo.getAction())%>
    <%=fb.hidden("key"+i,cdo.getKey())%>
    <%if(cdo.getAction().equalsIgnoreCase("D")){%>
        <%//=fb.hidden("ordenDiag"+i,cdo.getColValue("orden_diag"))%>
		<input class="deleting" type="hidden" name="ordenDiag<%=i%>" id="ordenDiag<%=i%>" value="<%=cdo.getColValue("orden_diag")%>">
    <%}else{%>
        <tr>
           <td><%=cdo.getColValue("diagnostico")%></td>
           <td><%=cdo.getColValue("diagnosticoDesc")%></td>
           <td align="center"><%=fb.intBox("ordenDiag"+i,cdo.getColValue("orden_diag"),true,false,viewMode,2, "form-control input-sm", null, null)%></td>
           <td align="center"><%=fb.submit("rem"+i,"x",true,viewMode,null,null,"onClick=\"removeItem('"+fb.getFormName()+"',"+i+"); __submitForm(this.form, 'X')\"","Eliminar Diagnóstico")%></td>
        </tr>
    <%}%>
    <%}%>
    </table>
    
    <div class="footerform" style="bottom:-11px !important">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
              <td>
                <%if(!from.equalsIgnoreCase("salida_pop")){%>
                <cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
                <%}else{%>
                  <%=fb.submit("save","Siguiente",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value); parent.openNextAccordionPanel('"+fb.getFormName()+"');\"")%>
                  <%=fb.hidden("saveOption","O")%>
                <%}%>
              </td>
            </tr>
        </table>
    </div>
    <%=fb.formEnd(true)%>    
    </div>

    <div role="tabpanel" class="tab-pane <%=active1%>" id="evaluacion_vih">
      <%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
      <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar' && document."+fb.getFormName()+".baction.value!='Siguiente')return true;");%>
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
      <%=fb.hidden("diagSize",""+iDiag.size())%>
      <%=fb.hidden("desc",desc)%>
      <%=fb.hidden("from",from)%>
      <%=fb.hidden("tab","1")%>
      <%=fb.hidden("action", prop1.getProperty("action"))%>
      <%=fb.hidden("codigo", prop1.getProperty("codigo"))%>
        <table cellspacing="0" class="table table-small-font table-bordered">
            <tr class="bg-headtabla">
              <th colspan="3">Evaluación Epidemiológica VIH</th>
            </tr>
            
            <tr class="bg-headtabla2">
              <td>Motivo de solicitud</td>
              <td>Factores de Riesgo</td>
              <td>Orientaci&oacute;n Sexual</td>
            </tr>
            
            <tbody>
            <tr>
              <td>
                <label class="pointer">
                  Embarazo 1pba&nbsp;<%=fb.checkbox("eval0","0",(viewMode || prop1.getProperty("eval0") != null && prop1.getProperty("eval0").equals("0")),(viewMode || cdo1.getColValue("sexo")!= null && !cdo1.getColValue("sexo").equalsIgnoreCase("F")),null,null,"","")%>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer">
                  Solicitud del paciente&nbsp;<%=fb.checkbox("eval1","1",(viewMode || prop1.getProperty("eval1") != null && prop1.getProperty("eval1").equals("1")),viewMode,null,null,"","")%>
                </label>
              </td>
              <td>
                <label class="pointer">
                  Exposición ocupacional &nbsp;<%=fb.checkbox("eval2","2",(viewMode || prop1.getProperty("eval2") != null && prop1.getProperty("eval2").equals("2")),viewMode,null,null,"","")%>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer">
                  VP&nbsp;<%=fb.checkbox("eval3","3",(viewMode || prop1.getProperty("eval3") != null && prop1.getProperty("eval3").equals("3")),viewMode,null,null,"","")%>
                </label>
              </td>
              <td>
                <label class="pointer">
                  Heterosexual&nbsp;<%=fb.checkbox("eval20","20",(viewMode || prop1.getProperty("eval20") != null && prop1.getProperty("eval20").equals("20")),viewMode,null,null,"","")%>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer">
                  Bisexual&nbsp;<%=fb.checkbox("eval21","21",(viewMode || prop1.getProperty("eval21") != null && prop1.getProperty("eval21").equals("21")),viewMode,null,null,"","")%>
                </label>
                <br>
                <b>Homosexual:</b><br>
                <label class="pointer">
                  Persona Gay&nbsp;<%=fb.checkbox("eval22","22",(viewMode || prop1.getProperty("eval22") != null && prop1.getProperty("eval22").equals("22")),viewMode,null,null,"","")%>
                </label>
                <label class="pointer">
                  Persona Trans&nbsp;<%=fb.checkbox("eval23","23",(viewMode || prop1.getProperty("eval23") != null && prop1.getProperty("eval23").equals("23")),viewMode,null,null,"","")%>
                </label>
              </td>
            </tr>
            </tbody>
            
            <tbody>
            <tr>
              <td>
                <label class="pointer">
                  Embarazo 2pba&nbsp;<%=fb.checkbox("eval4","4",(viewMode || prop1.getProperty("eval4") != null && prop1.getProperty("eval4").equals("4")),(viewMode || cdo1.getColValue("sexo")!= null && !cdo1.getColValue("sexo").equalsIgnoreCase("F")),null,null,"","")%>
                  </label>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <label class="pointer">
                  Investigaciones judiciales y medicina legal &nbsp;<%=fb.checkbox("eval5","5",(viewMode || prop1.getProperty("eval5") != null && prop1.getProperty("eval5").equals("5")),viewMode,null,null,"","")%>
                </label>
             </td>
             <td>
               <label class="pointer">
                  Pre-Operativo PPL&nbsp;<%=fb.checkbox("eval6","6",(viewMode || prop1.getProperty("eval6") != null && prop1.getProperty("eval6").equals("6")),viewMode,null,null,"","")%>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer">
                  TS&nbsp;<%=fb.checkbox("eval7","7",(viewMode || prop1.getProperty("eval7") != null && prop1.getProperty("eval7").equals("7")),viewMode,null,null,"","")%>
                </label>
             </td>
             <td>&nbsp;</td>
            </tr> 
            </tbody> 
            
            <tbody>
            <tr>
              <td>
                <label class="pointer">
                  Donantes&nbsp;<%=fb.checkbox("eval8","8",(viewMode || prop1.getProperty("eval8") != null && prop1.getProperty("eval8").equals("8")),viewMode,null,null,"","")%>
                  </label>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <label class="pointer">
                  ITS&nbsp;<%=fb.checkbox("eval9","9",(viewMode || prop1.getProperty("eval9") != null && prop1.getProperty("eval9").equals("9")),viewMode,null,null,"","")%>
                </label>
             </td>
             <td>
               <label class="pointer">
                  Transfusion&nbsp;<%=fb.checkbox("eval10","10",(viewMode || prop1.getProperty("eval10") != null && prop1.getProperty("eval10").equals("10")),viewMode,null,null,"","")%>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer">
                  UDI&nbsp;<%=fb.checkbox("eval39","39",(viewMode || prop1.getProperty("eval39") != null && prop1.getProperty("eval39").equals("39")),viewMode,null,null,"","")%>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer">
                  UOD&nbsp;<%=fb.checkbox("eval11","11",(viewMode || prop1.getProperty("eval11") != null && prop1.getProperty("eval11").equals("11")),viewMode,null,null,"","")%>
                </label>
             </td>
             <td>&nbsp;</td>
            </tr>  
            </tbody>  
            
            <tbody>
            <tr>
              <td>
                <label class="pointer">
                  Matrimonio&nbsp;<%=fb.checkbox("eval12","12",(viewMode || prop1.getProperty("eval12") != null && prop1.getProperty("eval12").equals("12")),viewMode,null,null,"","")%>
                  </label>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <label class="pointer">
                  TB&nbsp;<%=fb.checkbox("eval13","13",(viewMode || prop1.getProperty("eval13") != null && prop1.getProperty("eval13").equals("13")),viewMode,null,null,"","")%>
                </label>
             </td>
             <td>
               <label class="pointer">
                  CT de ITS&nbsp;<%=fb.checkbox("eval14","14",(viewMode || prop1.getProperty("eval14") != null && prop1.getProperty("eval14").equals("14")),viewMode,null,null,"","")%>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer">
                  No preservativo&nbsp;<%=fb.checkbox("eval15","15",(viewMode || prop1.getProperty("eval15") != null && prop1.getProperty("eval15").equals("15")),viewMode,null,null,"","")%>
                </label>
             </td>
             <td>&nbsp;</td>
            </tr>   
            </tbody>   
            
            <tbody>
            <tr>
              <td class="controls form-inline">
                <label class="pointer">
                  CT de VIH&nbsp;<%=fb.checkbox("eval16","16",(viewMode || prop1.getProperty("eval16") != null && prop1.getProperty("eval16").equals("16")),viewMode,null,null,"","")%>
                  </label>
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  <label class="pointer">
                  Otros&nbsp;<%=fb.checkbox("eval17","17",prop1.getProperty("eval17")!=null&&prop1.getProperty("eval17").equals("17"),viewMode,"observacion",null,"",""," data-index=17")%>
                  <%=fb.textarea("observacion17",prop1.getProperty("observacion17"),false,false,(viewMode || prop1.getProperty("eval17").equals("") ),0,1,0,"form-control input-sm","",null)%>
                </label>
             </td>
             <td class="controls form-inline">
               <label class="pointer">
                  Exposición perinatal&nbsp;<%=fb.checkbox("eval18","18",(viewMode || prop1.getProperty("eval18") != null && prop1.getProperty("eval18").equals("18")),viewMode,null,null,"","")%>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer">
                   Desconocido&nbsp;<%=fb.checkbox("eval40","40",(viewMode || prop1.getProperty("eval40") != null && prop1.getProperty("eval40").equals("40")),viewMode,null,null,"","")%>
                </label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer">
                  Otros&nbsp;<%=fb.checkbox("eval19","19",prop1.getProperty("eval19")!=null&&prop1.getProperty("eval19").equals("19"),viewMode,"observacion",null,"",""," data-index=19")%>
                  <%=fb.textarea("observacion19",prop1.getProperty("observacion19"),false,false,(viewMode || prop1.getProperty("eval17").equals("") ),0,1,0,"form-control input-sm","",null)%>
                </label>
             </td>
             <td>&nbsp;</td>
            </tr> 
            </tbody> 
            
        </table>
        
        <div class="footerform" style="bottom:-11px !important">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
              <td>
                <%if(!from.equalsIgnoreCase("salida_pop")){%>
                <cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
                <%}else{%>
                  <%=fb.submit("save","Siguiente",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value); parent.openNextAccordionPanel('"+fb.getFormName()+"');\"")%>
                  <%=fb.hidden("saveOption","O")%>
                <%}%>
              </td>
            </tr>
        </table>
    </div>
    
    <%=fb.formEnd(true)%>
    </div>
    
    <div role="tabpanel" class="tab-pane <%=active2%>" id="evaluacion_otras">
      <%fb = new FormBean2("form2",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
      <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar' && document."+fb.getFormName()+".baction.value!='Siguiente')return true;");%>
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
      <%=fb.hidden("diagSize",""+iDiag.size())%>
      <%=fb.hidden("desc",desc)%>
      <%=fb.hidden("from",from)%>
      <%=fb.hidden("tab","2")%>
      <%=fb.hidden("action", prop2.getProperty("action"))%>
      <%=fb.hidden("codigo", prop2.getProperty("codigo"))%>
        <table cellspacing="0" class="table table-small-font table-bordered">
          <tr class="bg-headtabla">
            <th>Información Clínico Epidemiológica del Paciente</th>
          </tr>
          
          <tbody>
          <tr>
            <td class="controls form-inline">
              Diagnóstico:&nbsp;<%=fb.textarea("eval24",prop2.getProperty("eval24"),false,false,(viewMode),0,2,0,"form-control input-sm","width:80%",null)%>
            </td>
          </tr>
          </tbody>
          
          <tbody>
          <tr>
            <td>
              <b>Condición.-</b>&nbsp;&nbsp;
              <label class="pointer"><%=fb.radio("eval25","25",prop2.getProperty("eval25")!=null&&prop2.getProperty("eval25").equals("25"),viewMode,false, "observacion", null, null)%>&nbsp;Ambulatorio</label>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <label class="pointer"><%=fb.radio("eval25","26",prop2.getProperty("eval25")!=null&&prop2.getProperty("eval25").equals("26"),viewMode,false, "observacion", null, null)%>&nbsp;Hospitalizado</label>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <label class="pointer">
                <%=fb.radio("eval25","27",prop2.getProperty("eval25")!=null&&prop2.getProperty("eval25").equals("27"),viewMode,false,"observacion",null,"",""," data-index=27 data-message='Por favor ingrese la fecha de defunción!'")%>
                &nbsp;Fallecido
              </label>
            </td>
          </tr>
          </tbody>
          
          <tbody>
            <tr>
              <td class="controls form-inline">
                Inicio de síntomas:&nbsp;
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="eval26" />
                <jsp:param name="valueOfTBox1" value="<%=prop2.getProperty("eval26")%>" />
                </jsp:include>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                Hospitalización::&nbsp;
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="eval28" />
                <jsp:param name="valueOfTBox1" value="<%=prop2.getProperty("eval28")%>" />
                </jsp:include>
              </td>
            </tr>
          </tbody>
          
          <tbody>
            <tr>
              <td class="controls form-inline">
                Defunción:&nbsp;
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="observacion27" />
                <jsp:param name="valueOfTBox1" value="<%=prop2.getProperty("observacion27")%>" />
                <jsp:param name="readonly" value="<%=viewMode || prop2.getProperty("observacion27").equals("")?"y":"n"%>" />
                </jsp:include>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                Toma de muestras:&nbsp;
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="eval29" />
                <jsp:param name="valueOfTBox1" value="<%=prop2.getProperty("eval29")%>" />
                </jsp:include>
              </td>
            </tr>
          </tbody>
          
          <tbody>
          <tr>
            <td>
              <b>Tipo de caso</b>&nbsp;&nbsp;
              <label class="pointer"><%=fb.radio("eval30","30",prop2.getProperty("eval30")!=null&&prop2.getProperty("eval30").equals("30"),viewMode,false)%>&nbsp;Sospechoso</label>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <label class="pointer"><%=fb.radio("eval30","31",prop2.getProperty("eval30")!=null&&prop2.getProperty("eval30").equals("31"),viewMode,false)%>&nbsp;Probable</label>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <label class="pointer">
                <%=fb.radio("eval30","32",prop2.getProperty("eval30")!=null&&prop2.getProperty("eval30").equals("32"),viewMode,false,"",null,"",""," data-index=30 data-message='Disparará cuando 1 será igual a 2'")%>
                &nbsp;Confirmado
              </label>
            </td>
          </tr>
          </tbody>
          
          <tbody>
          <tr>
            <td>
              <b>Criterio de caso confirmado.- </b>&nbsp;&nbsp;
              <label class="pointer"><%=fb.radio("eval31","31",prop2.getProperty("eval31")!=null&&prop2.getProperty("eval31").equals("31"),viewMode,false)%>&nbsp;Clínico</label>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <label class="pointer"><%=fb.radio("eval31","32",prop2.getProperty("eval31")!=null&&prop2.getProperty("eval31").equals("32"),viewMode,false)%>&nbsp;Laboratorio</label>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <label class="pointer">
                <%=fb.radio("eval31","33",prop2.getProperty("eval31")!=null&&prop2.getProperty("eval31").equals("33"),viewMode,false,"",null,"",""," data-index=31 data-message='Disparará cuando 1 será igual a 2'")%>
                &nbsp;Nexo
              </label>
            </td>
          </tr>
          </tbody>
          
          <tr><td class="bg-headtabla">Lugar donde se presumen el contagio</td></tr>
          <tr>
             <td class="controls form-inline">
               <%=fb.hidden("eval32", "")%>
               Provincia:&nbsp;
               <%=fb.textBox("eval33", prop2.getProperty("eval33"),false,false,true,50,0,"form-control input-sm",null,null)%>
               &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
               Distrito:&nbsp;
               <%=fb.hidden("eval34", "")%>
               <%=fb.textBox("eval35", prop2.getProperty("eval35"),false,false,true,50,0,"form-control input-sm",null,null)%>
               <%=fb.button("lugar_contagio","...",true,viewMode,null,null,"onClick=\"javascript:showLugares()\"","seleccionar medico")%>
             </td>
          </tr>
          <tr>
             <td class="controls form-inline">
               <%=fb.hidden("eval36", "")%>
               Corregimiento:&nbsp;
               <%=fb.textBox("eval37", prop2.getProperty("eval37"),false,false,true,50,0,"form-control input-sm",null,null)%>
               &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
               Especifique el lugar:&nbsp;

               <%=fb.textarea("eval38", prop2.getProperty("eval38"),true,false,viewMode,0,0,"form-control input-sm","width:30%",null)%>
             </td>
          </tr>
          
        </table>
        
        <div class="footerform" style="bottom:-11px !important">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
              <td>
                <%if(!from.equalsIgnoreCase("salida_pop")){%>
                <cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
                <%}else{%>
                  <%=fb.submit("save","Siguiente",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value); parent.openNextAccordionPanel('"+fb.getFormName()+"');\"")%>
                  <%=fb.hidden("saveOption","O")%>
                <%}%>
              </td>
            </tr>
        </table>
    </div>
     <%=fb.formEnd(true)%>
    </div>
    
    <div role="tabpanel" class="tab-pane <%=active3%>" id="enfermedad_notificable">
      <iframe src="" width="100%" height="430" frameborder="0" scrolling="yes" marginheight="0" marginwidth="0" id="enfermedad_notificable_container"></iframe>
    </div>

</div> 
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
	
    if (tab.equals("0")){
    
    String itemRemoved = "";
    int size = 0;
    if (request.getParameter("diagSize") != null) size = Integer.parseInt(request.getParameter("diagSize"));
	al.clear();
	iDiag.clear();
    for (int i=0; i<size; i++){
        CommonDataObject cdo2 = new CommonDataObject();
		cdo2.setTableName("tbl_adm_diagnostico_x_admision");
		cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and tipo ='S' and diagnostico ='"+request.getParameter("diagnostico"+i)+"'");
		cdo2.addColValue("pac_id",request.getParameter("pacId"));
		cdo2.addColValue("paciente",request.getParameter("codPac"));
		cdo2.addColValue("fecha_nacimiento", request.getParameter("dob"));
		cdo2.addColValue("admision",request.getParameter("noAdmision"));
		cdo2.addColValue("diagnostico",request.getParameter("diagnostico"+i));
		cdo2.addColValue("diagnosticoDesc",request.getParameter("diagnosticoDesc"+i));
		cdo2.addColValue("orden_diag",request.getParameter("ordenDiag"+i));
		cdo2.addColValue("tipo","S");
		cdo2.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"+i));
		cdo2.addColValue("fecha_creacion", request.getParameter("fecha_creacion_diag")+" "+request.getParameter("hora_creacion_diag"));
		cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo2.addColValue("fecha_modificacion",cDateTime);
		cdo2.setKey(i);
  		cdo2.setAction(request.getParameter("action"+i));
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
			itemRemoved = cdo2.getColValue("diagnostico")+"-S";
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");
			else cdo2.setAction("D");
		}	
		if (!cdo2.getAction().equalsIgnoreCase("X")){
            try{
              al.add(cdo2);
              iDiag.put(cdo2.getKey(),cdo2);
            }
            catch(Exception e){
              System.err.println(e.getMessage());
            }
		}
    }
    if (!itemRemoved.equals(""))
    {
	  vDiag.remove(itemRemoved);
	  response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc+"&from="+from+"&exp=3&tab="+tab);
      return;
    }
    if (baction != null && baction.equals("+"))
    {
      response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&desc="+desc+"&from="+from+"&exp=3&tab="+tab+"&fecha_creacion_diag="+request.getParameter("fecha_creacion_diag")+"&hora_creacion_diag="+request.getParameter("hora_creacion_diag"));
      return;
    }
	if (baction.equalsIgnoreCase("Guardar") || baction.equalsIgnoreCase("Siguiente")){
		if (al.size() == 0)
		{
			CommonDataObject cdo3 = new CommonDataObject();
			cdo3.setTableName("tbl_adm_diagnostico_x_admision");
			cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and tipo ='S'");
			cdo3.setAction("I");
			al.add(cdo3);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
    } 
    else if (tab.equals("1") || tab.equals("2")) {
      Properties prop = new Properties();
      prop.setProperty("pac_id", pacId);
      prop.setProperty("admision", noAdmision);
      
      if(tab.equals("1"))prop.setProperty("tipo", "VIH");
      else prop.setProperty("tipo", "OTH");
      if (request.getParameter("action") != null && request.getParameter("action").trim().equals("U")) {
         prop.setProperty("usuario_modificacion", (String) session.getAttribute("_userName"));
         prop.setProperty("fecha_modificacion", cDateTime);
         prop.setProperty("codigo", request.getParameter("codigo"));
      } else  {
         prop.setProperty("usuario_creacion", (String) session.getAttribute("_userName"));
         prop.setProperty("usuario_modificacion", (String) session.getAttribute("_userName"));
         prop.setProperty("fecha_modificacion", cDateTime);
         prop.setProperty("fecha_creacion", cDateTime);
      }
      
      for (int i = 0; i<45; i++) {
        if (request.getParameter("eval"+i) != null && !request.getParameter("eval"+i).trim().equals("")) prop.setProperty("eval"+i, request.getParameter("eval"+i));
        if (request.getParameter("observacion"+i) != null && !request.getParameter("observacion"+i).trim().equals("")) prop.setProperty("observacion"+i, request.getParameter("observacion"+i));
        
        //System.out.println(".................................................... "+prop2.getProperty("eval27"));
        System.out.println("....................................................observacion"+i+" >> "+request.getParameter("observacion"+i));
      }
      
      if (baction.equalsIgnoreCase("Guardar") || baction.equalsIgnoreCase("Siguiente")){
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        if (request.getParameter("action") != null && request.getParameter("action").trim().equals("U")) {
          EvalDiagSalMgr.update(prop);
        }
        else {
          EvalDiagSalMgr.add(prop);
          codigo = EvalDiagSalMgr.getPkColValue("codigo");
        }
        ConMgr.clearAppCtx(null);
      }
      
    }
%>
<html>
<head>
<script>
function closeWindow()
{
<%
String errCode = tab.equals("0") ? SQLMgr.getErrCode() : EvalDiagSalMgr.getErrCode();
String errMsg = tab.equals("0") ? SQLMgr.getErrMsg() : EvalDiagSalMgr.getErrMsg();

if (errCode.equals("1"))
{
%>
	<%if(from.equals("")){%>alert('<%=errMsg%>');<%}%>
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&from=<%=from%>&exp=3&tab=<%=tab%>&codigo=<%=codigo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST

iDiag = null;
vDiag = null;

SecMgr.setConnection(null);
CmnMgr.setConnection(null);
SQLMgr.setConnection(null);
EvalDiagSalMgr.setConnection(null);

prop1 = null;
prop2 = null;

System.out.println("............................................... <> ............................................");
%>
