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
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDiag" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiag" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDieta" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDieta" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCuidado" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCuidado" scope="session" class="java.util.Vector" />
<jsp:useBean id="PSEMgr" scope="session" class="issi.expediente.PlanSalidaExtraMgr" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
PSEMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
Properties prop = new Properties();
Properties prop2 = new Properties();
Properties prop3 = new Properties();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String noIndicacion = request.getParameter("no_indicacion")==null? "" : request.getParameter("no_indicacion");
String noDosis = request.getParameter("no_dosis")==null? "" : request.getParameter("no_dosis");
String noFrecuencia = request.getParameter("no_frecuencia")==null? "" : request.getParameter("no_frecuencia");
String noDuracion = request.getParameter("no_duracion")==null? "" : request.getParameter("no_duracion");
String codigo = request.getParameter("codigo");
String restrictNutri = request.getParameter("restrict_nutri");
String restrictNutriObs = request.getParameter("restrict_nutri_obs");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (cds == null) cds = "";
if (codigo == null) codigo = "";
if (restrictNutri == null) restrictNutri = "";
if (restrictNutriObs == null) restrictNutriObs = "";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String active0 = "", active1 = "", active2 = "", active3 = "",active4 = "",active5 = "", active6 = "", active7 = "", active8 = "", active9 = "";

CommonDataObject pacData = SQLMgr.getData("select to_char(fecha_nacimiento,'dd/mm/yyyy') fn, codigo from tbl_adm_paciente where pac_id = "+pacId);
if (pacData == null) pacData = new CommonDataObject();

CommonDataObject cdoN = SQLMgr.getData("select (select codigo from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'R' and rownum = 1) codigo_r, (select codigo from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'O' and rownum = 1) codigo_o, (select codigo from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and fecha_creacion = (select max(fecha_creacion) from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+") and tipo = 'I' and rownum = 1) codigo_i from dual");
if (cdoN == null) cdoN = new CommonDataObject();

String tab = request.getParameter("tab");
String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String key = "";
if (tab == null) tab = "0";

if (tab.equals("0")) active0 = "active";
else if (tab.equals("1")) active1 = "active";
else if (tab.equals("2")) active2 = "active";
else if (tab.equals("3")) active3 = "active";
else if (tab.equals("4")) active4 = "active";
else if (tab.equals("5")) active5 = "active";
else if (tab.equals("6")) active6 = "active";
else if (tab.equals("7")) active7 = "active";
else if (tab.equals("8")) active8 = "active";
else if (tab.equals("9")) active9 = "active";

if (request.getMethod().equalsIgnoreCase("GET")) {

if(change == null)
{
iMed.clear(); //MEDICAMENTOS
iDiag.clear();
vDiag.clear();
iDieta.clear();
vDieta.clear();
iCuidado.clear();
vCuidado.clear();

		sql = "select a.diagnostico, a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'S' order by a.orden_diag";
			al = SQLMgr.getDataList(sql);
			for (int i=0; i<al.size(); i++)
			{
		cdo = (CommonDataObject) al.get(i);
				cdo.setKey(i);
		cdo.setAction("U");

				try
				{
					iDiag.put(cdo.getKey(),cdo);
					vDiag.addElement(cdo.getColValue("diagnostico"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
	sql= "select a.codigo, a.tipo_dieta ,a.subtipo_dieta, a.observacion, b.descripcion descSubTipo,b.observacion obserSubDieta,c.descripcion descDieta, a.restrict_nutri, a.restrict_nutri_obs from tbl_sal_salida_dieta a,tbl_cds_subtipo_dieta b,tbl_cds_tipo_dieta c where a.tipo_dieta = b.cod_tipo_dieta and a.subtipo_dieta = b.codigo and b.cod_tipo_dieta = c.codigo and a.pac_id = "+pacId+" and a.admision = "+noAdmision;

	al = SQLMgr.getDataList(sql);
			for (int i=0; i<al.size(); i++)
			{
		cdo = (CommonDataObject) al.get(i);
				cdo.setKey(i);
		cdo.setAction("U");

				try
				{
					iDieta.put(cdo.getKey(),cdo);
					vDieta.addElement(cdo.getColValue("tipo_dieta") +"-"+cdo.getColValue("subtipo_dieta"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		sql= " select a.codigo, a.pac_id, a.admision, a.guia_id, decode(a.guia_id,-1,a.guia_desc,b.nombre) as descGuia, a.observacion from tbl_sal_salida_cuidado a, tbl_sal_guia b where a.guia_id = b.id(+) and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" and a.status = 'A' order by a.codigo";

		al = SQLMgr.getDataList(sql);
			for (int i=0; i<al.size(); i++)
			{
		cdo = (CommonDataObject) al.get(i);
				cdo.setKey(i);
		cdo.setAction("U");

				try
				{
					iCuidado.put(cdo.getKey(),cdo);
					vCuidado.addElement(cdo.getColValue("guia_id"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
}//change

prop = SQLMgr.getDataProperties("select xtra from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'R' and codigo = "+cdoN.getColValue("codigo_r","0"));
if (prop == null){
		if(!viewMode) modeSec="add";
		prop = new Properties();
		prop.setProperty("codigo", "0");
		prop.setProperty("action", "I");
} else prop.setProperty("action", "U");

prop2 = SQLMgr.getDataProperties("select xtra from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'O' and codigo = "+cdoN.getColValue("codigo_o","0"));
if (prop2 == null){
		if(!viewMode) modeSec="add";
		prop2 = new Properties();
		prop2.setProperty("codigo", "0");
		prop2.setProperty("action", "I");
}else prop2.setProperty("action", "U");

prop3 = SQLMgr.getDataProperties("select xtra from tbl_sal_plan_salida_extra where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'I' and codigo = "+cdoN.getColValue("codigo_i","0"));
if (prop3 == null){
		if(!viewMode) modeSec="add";
		prop3 = new Properties();
		prop3.setProperty("codigo", "0");
		prop3.setProperty("action", "I");
}else prop3.setProperty("action", "U");
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
document.title = 'EXPEDIENTE-PLAN DE SALIDA '+document.title;
var noNewHeight = true;
function doAction(){<%if (request.getParameter("type") != null){if (tab.equals("1")){%>showDiagnosticoList();<%} else if (tab.equals("3")){%>showDietaList();<%} else if (tab.equals("4")){%>showCuidadoList();<%}}%>}
function showDiagnosticoList(){ abrir_ventana1('../common/check_diagnostico.jsp?fp=planSalida&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&desc=<%=desc%>&seccion=<%=seccion%>&exp=3');}
function showDietaList(){
		var restrictNutri = $("#restrict_nutri", $("#form3")).val();
		var restrictNutriObs = $("#restrict_nutri_obs", $("#form3")).val();
		abrir_ventana1('../common/check_dieta.jsp?fp=pSalida&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&desc=<%=desc%>&seccion=<%=seccion%>&exp=3&restrict_nutri='+restrictNutri+'&restrict_nutri_obs='+restrictNutriObs);
}
function showCuidadoList(){abrir_ventana1('../common/check_cuidado.jsp?fp=pSalida&mode=<%=mode%>&modeSec=<%=modeSec%>&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&desc=<%=desc%>&seccion=<%=seccion%>&exp=3');}
function imprimir(){
abrir_ventana1('../expediente3.0/print_datos_salida.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&codigo=<%=codigo%>');
}
function isAvalidNoRec(){
	var isValid = true;
	var recObj = [];
	var totMed = parseInt("<%=iMed.size()%>",10);
	for (i=0; i<totMed; i++){
		 if ($("#no_receta"+i).val())recObj.push($("#no_receta"+i).val());
	 if ( $("#no_receta"+i).val() && !isInteger($("#no_receta"+i).val()) ) {
		isValid = false;
		$("#no_receta"+i).select();
		break;
	 }else if ( parseInt($("#no_receta"+i).val()) < 1){isValid = false; break;}
	}
	//debug(recObj);
	recObj = removeDups(recObj);
	//debug(recObj);
	if (recObj[recObj.length-1] > recObj.length){isValid=false;}
	return isValid;
}

function alreadyPrintedAll(){
	 /*var t = parseInt("<%=iMed.size()%>");
	 var rObj = [];
	 var halt = false;
	 var d = 0;
	 for (r = 0; r<t; r++){
	 if ( $("#action"+r).val() == "I"){
		 rObj.push( $("#no_receta"+r).val() );
		 //debug("NO RECETA = R = "+r+" --- "+$("#no_receta"+r).val());
	 }
	 }
	 rObj = removeDups(rObj);
	 if (rObj.length > 0){
		 d = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_recetas','pac_id=<%=pacId%> and admision=<%=noAdmision%> and id_recetas in('+rObj+') and status = \'P\' ','');
	 if (d > 0) {alert("Perdona, pero usted está tratando de insertar un medicamento en una receta ya impresa!"); halt=true;$("#no_receta"+r).select();}
	 else halt = false;
	 }else{halt = false;}
	 return halt;*/
	 return false;
}

function alreadyPrinted(ind, dontSubmit){
	var noReceta = $("#no_receta"+ind).val();
	var action = $("#action"+ind).val();
	var d, proceed = true;
	if (!isInteger(noReceta)) {proceed = false; return false;}
	else{
		//d = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_recetas','pac_id=<%=pacId%> and admision=<%=noAdmision%> and id_recetas = '+noReceta+' and status = \'P\' ','') || 0;
		d = 0;

		if (dontSubmit && d > 0) {
			$("#no_receta"+ind).val("");
			alert("La receta "+noReceta+" ya fue impreso!");
		proceed = false;
		}
		else {
			if (d>0 && "I" != action){
			alert("Usted está tratando de eliminar un medicamento ya impreso en una receta!");
			proceed = false;
			}else{
				if(!dontSubmit) {
			 removeItem('form2',ind); proceed = true;
			 }
			}
		}
	}
	if (!dontSubmit && proceed===true) $("#form2").submit();
}

function printRecetas(){
	 abrir_ventana("../expediente/exp_gen_recetas.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&exp=3");
}

function canSubmit() {
	var proceed = true;
	$(".observacion").each(function() {
		var $self = $(this);
		var i = $self.data('index');
		var message = $self.data('message');
		if ( $self.is(":checked") && !$.trim($("#xtra_observ"+i).val())) {
			parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
			proceed = false;
			$self.focus();
			return false;
		}else  {proceed = true;}
	});
	return proceed;
}

function toggle(i, val) {
	if (val == '1' || val == '3' || val == '8' || val == '10' || val == '12' || val == '29' || val == '33') {
		$("#xtra_observ"+i).prop("readOnly", false)
	} else  {
		$("#xtra_observ"+i).prop("readOnly", true).val("")
	}
}

function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=plan_salida&exp=3');}



$(function(){
	 $(".defuncion").click(function(e){
		var self = $(this);
		$(".no-defuncion").each(function(){
				if (self.val() == '6'){
						if (this.type == 'radio') {
								this.checked = false;
								this.disabled = true;
						}
				} else {
						this.disabled = false;
				}
				if(this.type == 'textarea') {
						this.readOnly = true;
						this.value = "";
				}
		});
	 });

	 $("input[type='radio'][name='restrict_nutri']").click(function(){
		 if (this.value == 'S') $("textarea#restrict_nutri_obs").prop('readOnly', false);
		 else $("textarea#restrict_nutri_obs").prop('readOnly', true).val("");
	 });
});
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform">
		<table cellspacing="0" class="table pull-right table-striped table-custom-1">
				<tr>
						<td class="controls form-inline">
								<%=fb.button("imprimir","imprimir",false,(codigo.equals("0")),"btn btn-inverse btn-sm",null,"onClick=\"javascript:imprimir()\"")%>
						</td>
				</tr>
		</table>
</div>

 <ul class="nav nav-tabs" role="tablist">
		<li role="presentation" class="<%=active0%>">
				<a href="#datos_generales" aria-controls="datos_generales" role="tab" data-toggle="tab"><b>Motivos de ingreso</b></a>
		</li>
		<li role="presentation" class="<%=active1%>">
				<a href="#diagnosticos_de_salida" aria-controls="diagnosticos_de_salida" role="tab" data-toggle="tab"><b>Diagnosticos De Salida</b></a>
		</li>

		<li role="presentation" class="<%=active8%>">
				<a href="#evolucion_medica" aria-controls="evolucion_medica" role="tab" data-toggle="tab"><b>Evoluci&oacute;n m&eacute;dica</b></a>
		</li>


		<li role="presentation" class="<%=active2%>">
				<a href="#medicamentos" aria-controls="medicamentos" role="tab" data-toggle="tab"><b>Medicamentos</b></a>
		</li>
		<li role="presentation" class="<%=active3%>">
				<a href="#dietas" aria-controls="dietas" role="tab" data-toggle="tab"><b>Dietas</b></a>
		</li>
		<li role="presentation" class="<%=active4%>">
				<a href="#cuidados" aria-controls="cuidados" role="tab" data-toggle="tab"><b>Cuidados</b></a>
		</li>
		<li role="presentation" class="<%=active5%>">
				<a href="#relevantes" aria-controls="relevantes" role="tab" data-toggle="tab"><b>Relevantes</b></a>
		</li>
		<li role="presentation" class="<%=active6%>">
				<a href="#condicion" aria-controls="condicion" role="tab" data-toggle="tab"><b>Condici&oacute;n</b></a>
		</li>
		<li role="presentation" class="<%=active7%>">
				<a href="#citas" aria-controls="citas" role="tab" data-toggle="tab"><b>Citas</b></a>
		</li>
		<li role="presentation" class="<%=active9%>">
				<a href="#documentos" aria-controls="documentos" role="tab" data-toggle="tab"><b>Documentos</b></a>
		</li>
</ul>

<div class="tab-content">
<div role="tabpanel" class="tab-pane <%=active0%>" id="datos_generales">
		 <table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<tr>
						<td>
								<iframe id="i_motivo_ingreso" style="width:100%; height: 400px; border:none" src="../expediente3.0/exp_enfermedad_actual.jsp?desc=ENFERMEDAD%20ACTUAL&pacId=<%=pacId%>&seccion=1&noAdmision=<%=noAdmision%>&mode=view&cds=<%=cds%>&fg=plan_salida"></iframe>
						</td>
				</tr>
		 </table>
</div>

<div role="tabpanel" class="tab-pane <%=active1%>" id="diagnosticos_de_salida">
<%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Continuar')return true;");%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("mSize",""+iMed.size())%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("dSize",""+iDieta.size())%>
<%=fb.hidden("cSize",""+iCuidado.size())%>
<%=fb.hidden("cds",""+cds)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("no_indicacion",noIndicacion)%>
<%=fb.hidden("no_dosis",noDosis)%>
<%=fb.hidden("no_frecuencia",noFrecuencia)%>
<%=fb.hidden("no_duracion",noDuracion)%>
<%=fb.hidden("restrict_nutri_obs",restrictNutriObs)%>
<%=fb.hidden("restrict_nutri",restrictNutri)%>
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
	<tr class="bg-headtabla">
				<td width="15%"><cellbytelabel id="10">C&oacute;digo</cellbytelabel></td>
				<td width="65%"><cellbytelabel id="11">Nombre</cellbytelabel></td>
				<td width="10%"><cellbytelabel id="12">Prioridad</cellbytelabel></td>
				<td width="5%" align="center"><%=fb.submit("addDiagnostico","+",false,viewMode,"btn btn-primary btn-sm",null,"onClick=\"javascript:__submitForm(this.form, this.value)\"","Agregar Diagnósticos")%></td>
		</tr>
<%
al.clear();
al = CmnMgr.reverseRecords(iDiag);
for (int i=0; i<iDiag.size(); i++)
{
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
			 <%=fb.hidden("ordenDiag"+i,cdo.getColValue("ordenDiag"))%>
			<%}else{%>
						<tr>
							<td><%=cdo.getColValue("diagnostico")%></td>
							<td><%=cdo.getColValue("diagnosticoDesc")%></td>
							<td align="center"><%=fb.intBox("ordenDiag"+i,cdo.getColValue("orden_diag"),true,false,viewMode,2,"form-control input-sm", null,null)%></td>
							<td align="center"><%=fb.submit("rem"+i,"x",true,viewMode,"btn btn-danger btn-sm",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+"); __submitForm(this.form, this.value)\"","Eliminar Diagnóstico")%></td>
						</tr>
<%			}
}
%>
						</table>

						<div class="footerform" style="bottom:-11px !important">
				<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
						<tr>
								<td>
								<%=fb.hidden("saveOption","O")%>
								<%=fb.submit("save","Continuar",true,viewMode,"btn btn-inverse btn-sm|fa fa-arrow-right fa-lg",null,"")%>
								<button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
						</tr>
				</table>
		 </div>

	<%=fb.formEnd(true)%>
</div>

<div role="tabpanel" class="tab-pane <%=active8%>" id="evolucion_medica">
		 <table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<tr>
						<td>
								<iframe id="i_motivo_ingreso" style="width:100%; height: 400px; border:none" src="../expediente3.0/exp_progreso_clinico.jsp?desc=EVOLUCION%20CLINICA&pacId=<%=pacId%>&seccion=46&noAdmision=<%=noAdmision%>&mode=<%=mode%>&cds=<%=cds%>&fg=plan_salida&code=-1"></iframe>
						</td>
				</tr>
		 </table>
</div>

<div role="tabpanel" class="tab-pane <%=active2%>" id="medicamentos">
		 <iframe id="i_medicamentos" style="width:100%; height: 400px; border:none" src="../expediente/exp_orden_medicamentos_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=A&exp=3&fp=plan_salida&mode=<%=mode%>"></iframe>
</div>

<div role="tabpanel" class="tab-pane <%=active3%>" id="dietas">
		 <%fb = new FormBean2("form3",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
		 <%=fb.formStart(true)%>
		 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Continuar')return true;");%>
		 <%=fb.hidden("baction","")%>
		 <%=fb.hidden("mode",mode)%>
		 <%=fb.hidden("modeSec",modeSec)%>
		 <%=fb.hidden("seccion",seccion)%>
		 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
		 <%=fb.hidden("dob","")%>
		 <%=fb.hidden("codPac","")%>
		 <%=fb.hidden("pacId",pacId)%>
		 <%=fb.hidden("noAdmision",noAdmision)%>
		 <%=fb.hidden("tab","3")%>
		 <%=fb.hidden("mSize",""+iMed.size())%>
		 <%=fb.hidden("diagSize",""+iDiag.size())%>
		 <%=fb.hidden("dSize",""+iDieta.size())%>
		 <%=fb.hidden("cSize",""+iCuidado.size())%>
		 <%=fb.hidden("cds",""+cds)%>
		 <%=fb.hidden("desc",desc)%>
		 <%=fb.hidden("no_indicacion",noIndicacion)%>
		 <%=fb.hidden("no_dosis",noDosis)%>
		 <%=fb.hidden("no_frecuencia",noFrecuencia)%>
		 <%=fb.hidden("no_duracion",noDuracion)%>
		 <table cellspacing="0" class="table table-small-font table-bordered table-striped">
						<tr class="bg-headtabla" align="center">
							<td width="25%"><cellbytelabel id="10">C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel id="18">Dieta</cellbytelabel></td>
							<td width="45%"><cellbytelabel id="19">Observaci&oacute;n</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addDieta","+",false,viewMode,"btn btn-primary btn-sm",null,"onClick=\"javascript:__submitForm(this.form, this.value)\"","Agregar Dieta")%></td>
						</tr>
<%
al.clear();
al = CmnMgr.reverseRecords(iDieta);
for (int i=0; i<iDieta.size(); i++)
{
		key = al.get(i).toString();
		cdo = (CommonDataObject) iDieta.get(key);
			String color = "TextRow01";
		if (i % 2 == 0) color = "TextRow02";

				if(restrictNutri.trim().equals(""))
						restrictNutri = cdo.getColValue("restrict_nutri"," ");
				if(restrictNutriObs.trim().equals(""))
						restrictNutriObs = cdo.getColValue("restrict_nutri_obs"," ");
%>
						 <%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("tipo_dieta"+i,cdo.getColValue("tipo_dieta"))%>
						<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
						<%=fb.hidden("subtipo_dieta"+i,cdo.getColValue("subtipo_dieta"))%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
		 <%if(cdo.getAction().equalsIgnoreCase("D")){%>
		 <%=fb.hidden("descDieta"+i,cdo.getColValue("descDieta"))%>
		 <%=fb.hidden("descSubTipo"+i,cdo.getColValue("descSubTipo"))%>
		 <%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
		 <%}else{%>
			<tr class="<%=color%>">
							<td valign="middle"><%=fb.textBox("descDieta"+i,cdo.getColValue("descDieta"),true,false,true,25,"form-control input-sm",null,null)%></td>
							<td><%=fb.textBox("descSubTipo"+i,cdo.getColValue("descSubTipo"),true,false,true,25,"form-control input-sm",null,null)%></td>
							<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,40,1,2000,"form-control input-sm","width:100%","")%></td>
							<td align="center"><%=fb.submit("rem"+i,"x",true,viewMode,"btn btn-danger btn-sm",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+");__submitForm(this.form, this.value)\"","Eliminar Dieta")%></td>
						</tr>
		<%}}%>

						<tr class="bg-headtabla">
								<td colspan="4">
										Restricci&oacute;n nutricional&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										<label class="pointer"><%=fb.radio("restrict_nutri","S",restrictNutri!=null&&restrictNutri.equalsIgnoreCase("S"),viewMode,false,"",null,"","","")%>&nbsp;SI</label>
										&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										<label class="pointer"><%=fb.radio("restrict_nutri","N",restrictNutri!=null&&restrictNutri.equalsIgnoreCase("N"),viewMode,false,"",null,"","","")%>&nbsp;NO</label>
								</td>
						</tr>

						<tr>
								<td colspan="4">
										<%=fb.textarea("restrict_nutri_obs",restrictNutriObs,false,false,viewMode || restrictNutriObs.trim().equals(""),0,1,2000,"form-control input-sm","width:100%",null)%>
								</td>
						</tr>


						</table>
					<div class="footerform" style="bottom:-11px !important">
				<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
						<tr>
								<td>
								<%=fb.hidden("saveOption","O")%>
								<%=fb.submit("save","Continuar",true,viewMode,"btn btn-inverse btn-sm|fa fa-arrow-right fa-lg",null,"")%>
								<button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
						</tr>
				</table>
		 </div>
		<%=fb.formEnd(true)%>
</div>

<div role="tabpanel" class="tab-pane <%=active4%>" id="cuidados">
 <%fb = new FormBean2("form4",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
 <%=fb.formStart(true)%>
 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Continuar')return true;");%>
 <%=fb.hidden("baction","")%>
 <%=fb.hidden("mode",mode)%>
 <%=fb.hidden("modeSec",modeSec)%>
 <%=fb.hidden("seccion",seccion)%>
 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
 <%=fb.hidden("dob","")%>
 <%=fb.hidden("codPac","")%>
 <%=fb.hidden("pacId",pacId)%>
 <%=fb.hidden("noAdmision",noAdmision)%>
 <%=fb.hidden("tab","4")%>
 <%=fb.hidden("mSize",""+iMed.size())%>
 <%=fb.hidden("diagSize",""+iDiag.size())%>
 <%=fb.hidden("dSize",""+iDieta.size())%>
 <%=fb.hidden("cSize",""+iCuidado.size())%>
 <%=fb.hidden("cds",""+cds)%>
 <%=fb.hidden("desc",desc)%>
 <%=fb.hidden("no_indicacion",noIndicacion)%>
 <%=fb.hidden("no_dosis",noDosis)%>
 <%=fb.hidden("no_frecuencia",noFrecuencia)%>
 <%=fb.hidden("no_duracion",noDuracion)%>
<%=fb.hidden("restrict_nutri_obs",restrictNutriObs)%>
<%=fb.hidden("restrict_nutri",restrictNutri)%>
	<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<tr class="bg-headtabla" align="center">
					<td width="10%"><cellbytelabel id="10">C&oacute;digo</cellbytelabel></td>
					<td width="40%"><cellbytelabel id="20">Guia</cellbytelabel></td>
					<td width="45%"><cellbytelabel id="19">Observaci&oacute;n</cellbytelabel></td>
					<td width="5%"><%=fb.submit("addCuidado","+",false,viewMode,"btn btn-primary btn-sm",null,"onClick=\"javascript:__submitForm(this.form, this.value)\"","Agregar Cuidado")%></td>
				</tr>
<%
al.clear();
al = CmnMgr.reverseRecords(iCuidado);
for (int i=0; i<iCuidado.size(); i++)
{
		key = al.get(i).toString();
		cdo = (CommonDataObject) iCuidado.get(key);

		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("action"+i,cdo.getAction())%>
			<%=fb.hidden("key"+i,cdo.getKey())%>
			<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
			<%if(cdo.getAction().equalsIgnoreCase("D")){%>
			<%=fb.hidden("guia_id"+i,cdo.getColValue("guia_id"))%>
			<%=fb.hidden("descGuia"+i,cdo.getColValue("descGuia"))%>
			<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
			<%}else{%>
						<tr class="<%=color%>">
							<td valign="middle"><%=fb.textBox("guia_id"+i,cdo.getColValue("guia_id"),true,false,true,5,"form-control input-sm",null,null)%></td>
							<td align="center"><%=fb.textBox("descGuia"+i,cdo.getColValue("descGuia"),true,false,(!cdo.getColValue("guia_id").equals("-1")),50,"form-control input-sm",null,null)%></td>
				 <td align="center"><%=fb.textBox("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,50,2000,"form-control input-sm",null,null)%></td>
							<td align="center"><%=fb.submit("rem"+i,"x",true,viewMode,"btn btn-danger btn-sm",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+");__submitForm(this.form, this.value)\"","Eliminar Cuidado")%></td>
						</tr>
<%}}%>
 </table>
<div class="footerform" style="bottom:-11px !important">
				<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
						<tr>
								<td>
								<%=fb.hidden("saveOption","O")%>
								<%=fb.submit("save","Continuar",true,viewMode,"btn btn-inverse btn-sm|fa fa-arrow-right fa-lg",null,"")%>
								<button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
						</tr>
				</table>
		 </div>
<%=fb.formEnd(true)%>
</div>

<div role="tabpanel" class="tab-pane <%=active5%>" id="relevantes">
<%fb = new FormBean2("form5",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
 <%=fb.formStart(true)%>
 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Continuar')return true;");%>
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
 <%=fb.hidden("tab","5")%>
 <%=fb.hidden("mSize",""+iMed.size())%>
 <%=fb.hidden("diagSize",""+iDiag.size())%>
 <%=fb.hidden("dSize",""+iDieta.size())%>
 <%=fb.hidden("cSize",""+iCuidado.size())%>
 <%=fb.hidden("cds",""+cds)%>
 <%=fb.hidden("desc",desc)%>
 <%=fb.hidden("no_indicacion",noIndicacion)%>
 <%=fb.hidden("no_dosis",noDosis)%>
 <%=fb.hidden("no_frecuencia",noFrecuencia)%>
 <%=fb.hidden("no_duracion",noDuracion)%>
<%=fb.hidden("restrict_nutri_obs",restrictNutriObs)%>
<%=fb.hidden("restrict_nutri",restrictNutri)%>
 <%=fb.hidden("tipo","R")%>
 <%=fb.hidden("action", prop.getProperty("action"))%>
 <%=fb.hidden("codigo", prop.getProperty("codigo"))%>
 <%=fb.hidden("pVal", "")%>
 <table cellspacing="0" class="table table-small-font table-bordered table-striped">
	 <tr>
		 <td class="controls form-inline" width="30%">
		 Laboratorios Relevantes:&nbsp;&nbsp;&nbsp;&nbsp;
			 <label class="pointer"><%=fb.radio("extra0","0",prop.getProperty("extra0")!=null&&prop.getProperty("extra0").equals("0"),viewMode,false,"",null,"",""," onclick='toggle(0, 0)'")%>&nbsp;NO</label>
			 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			 <label class="pointer"><%=fb.radio("extra0","1", prop.getProperty("extra0")!=null&&prop.getProperty("extra0").equals("1"),viewMode,false,"observacion",null," onclick='toggle(0, 1)'",null," data-index=0 data-message='Por favor indicar los Laboratorios Relevantes!'")%>

			 &nbsp;SI</label>
		 </td>
		 <td width="70%" class="controls form-inline">
		 <b>Cuáles?</b>
			 <%=fb.textarea("xtra_observ0",prop.getProperty("xtra_observ0"),false,false,viewMode || prop.getProperty("xtra_observ0").equals(""),0,1,2000,"form-control input-sm","width:100%",null)%>
		 </td>
	 </tr>

	 <tr>
		 <td class="controls form-inline" width="30%">
		 Pruebas de gabinete:&nbsp;&nbsp;&nbsp;&nbsp;
			 <label class="pointer"><%=fb.radio("extra32","32",prop.getProperty("extra32")!=null&&prop.getProperty("extra32").equals("32"),viewMode,false,"",null,"",""," onclick='toggle(32, 32)'")%>&nbsp;NO</label>
			 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			 <label class="pointer"><%=fb.radio("extra32","33", prop.getProperty("extra32")!=null&&prop.getProperty("extra32").equals("33"),viewMode,false,"observacion",null," onclick='toggle(32, 33)'",null," data-index=32 data-message='Por favor indicar las Pruebas de gabinete!'")%>

			 &nbsp;SI</label>
		 </td>
		 <td width="70%" class="controls form-inline">
		 <b>Cuáles?</b>
			 <%=fb.textarea("xtra_observ32",prop.getProperty("xtra_observ32"),false,false,viewMode || prop.getProperty("xtra_observ32").equals(""),0,1,2000,"form-control input-sm","width:100%",null)%>
		 </td>
	 </tr>

	 <tr>
		 <td class="controls form-inline" width="40%">
		 Procedimientos Especiales Intrahospitalarios:&nbsp;&nbsp;&nbsp;&nbsp;
			 <label class="pointer"><%=fb.radio("extra1","2",prop.getProperty("extra1")!=null&&prop.getProperty("extra1").equals("2"),viewMode,false,"",null,"",""," onclick='toggle(1, 2)'")%>&nbsp;NO</label>
			 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			 <label class="pointer">

			 <%=fb.radio("extra1","3", prop.getProperty("extra1")!=null&&prop.getProperty("extra1").equals("3"),viewMode,false,"observacion",null," onclick='toggle(1, 3)'",null," data-index=1 data-message='Por favor indicar losProcedimientos Especiales Intrahospitalarios!'")%>

			 &nbsp;SI</label>
		 </td>
		 <td width="60%" class="controls form-inline">
		 <b>Cuáles?</b>
			 <%=fb.textarea("xtra_observ1",prop.getProperty("xtra_observ1"),false,false,viewMode || prop.getProperty("xtra_observ1").equals(""),0,1,2000,"form-control input-sm","width:100%",null)%>
		 </td>
	 </tr>

	 <tr class="bg-headtabla">
				<td colspan="2">ANTECEDENTE ALERGIAS</td>
	 </tr>

	 <tr>
				<td colspan="2">
						<iframe id="i_ant_alergicos" style="width:100%; height: 400px; border:none" src="../expediente3.0/exp_ant_alergico.jsp?desc=ANTECEDENTE%20ALERGICOS%20-%20AA&pacId=<%=pacId%>&seccion=11&noAdmision=<%=noAdmision%>&mode=view&cds=<%=cds%>&fg=plan_salida"></iframe>
				</td>
	 </tr>

 </table>

<div class="footerform" style="bottom:-11px !important">
				<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
						<tr>
								<td>
								<%=fb.hidden("saveOption","O")%>
								<%=fb.submit("save","Continuar",true,viewMode,"btn btn-inverse btn-sm|fa fa-arrow-right fa-lg",null,"")%>
								<button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
						</tr>
				</table>
		 </div>
<%=fb.formEnd(true)%>
</div>

<div role="tabpanel" class="tab-pane <%=active6%>" id="condicion">
<%fb = new FormBean2("form6",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
 <%=fb.formStart(true)%>
 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Continuar')return true;");%>
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
 <%=fb.hidden("tab","6")%>
 <%=fb.hidden("mSize",""+iMed.size())%>
 <%=fb.hidden("diagSize",""+iDiag.size())%>
 <%=fb.hidden("dSize",""+iDieta.size())%>
 <%=fb.hidden("cSize",""+iCuidado.size())%>
 <%=fb.hidden("cds",""+cds)%>
 <%=fb.hidden("desc",desc)%>
 <%=fb.hidden("no_indicacion",noIndicacion)%>
 <%=fb.hidden("no_dosis",noDosis)%>
 <%=fb.hidden("no_frecuencia",noFrecuencia)%>
 <%=fb.hidden("no_duracion",noDuracion)%>
<%=fb.hidden("restrict_nutri_obs",restrictNutriObs)%>
<%=fb.hidden("restrict_nutri",restrictNutri)%>
 <%=fb.hidden("tipo","O")%>
 <%=fb.hidden("action", prop2.getProperty("action"))%>
 <%=fb.hidden("codigo", prop2.getProperty("codigo"))%>
 <%=fb.hidden("pVal", "")%>

 <table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<tr>
		 <td class="controls form-inline" colspan="2">
			 <label class="pointer"><%=fb.radio("extra2","4",prop2.getProperty("extra2")!=null&&prop2.getProperty("extra2").equals("4"),viewMode,false,"defuncion",null,"","","")%>&nbsp;Recuperado</label>
			 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			 <label class="pointer"><%=fb.radio("extra2","5",prop2.getProperty("extra2")!=null&&prop2.getProperty("extra2").equals("5"),viewMode,false,"defuncion",null,"","","")%>&nbsp;Convaleciente</label>
			 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			 <label class="pointer"><%=fb.radio("extra2","6",prop2.getProperty("extra2")!=null&&prop2.getProperty("extra2").equals("6"),viewMode,false,"defuncion",null,"","","")%>&nbsp;Defunción</label>
		 </td>
		</tr>
		<tr>
			<td class="controls form-inline">
				<b>Uso equipo especial</b>&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("extra3","7", prop2.getProperty("extra3")!=null&&prop2.getProperty("extra3").equals("7"),viewMode,false,"no-defuncion",null,"onclick='toggle(3, 7)'",null,"")%>&nbsp;NO</label>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<label class="pointer"><%=fb.radio("extra3","8", prop2.getProperty("extra3")!=null&&prop2.getProperty("extra3").equals("8"),viewMode,false,"observacion no-defuncion",null,"onclick='toggle(3, 8)'",null," data-index=3 data-message='Por favor indicar los Equipos Especiales!'")%>&nbsp;SI</label>
			</td>
			<td width="70%" class="controls form-inline">
			<b>Cuáles?</b>
				<%=fb.textarea("xtra_observ3",prop2.getProperty("xtra_observ3"),false,false,viewMode || prop2.getProperty("xtra_observ0").equals(""),0,1,2000,"form-control input-sm no-defuncion","width:100%",null)%>
			</td>
		</tr>

		<tr>
			<td class="controls form-inline" colspan="2">
				<label class="pointer"><b>Febril</b>&nbsp;&nbsp;&nbsp;<%=fb.radio("extra12","30", prop2.getProperty("extra12")!=null&&prop2.getProperty("extra12").equals("30"),viewMode,false,"no-defuncion",null,"",null,"")%></label>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<label class="pointer"><b>Afebril</b>&nbsp;&nbsp;&nbsp;<%=fb.radio("extra12","31", prop2.getProperty("extra12")!=null&&prop2.getProperty("extra12").equals("31"),viewMode,false,"no-defuncion",null,"",null,"")%></label>
			</td>
		</tr>

		<!--<tr>
			<td class="controls form-inline" colspan="2">
				<b>Evoluci&oacute;n M&eacute;dica:</b>&nbsp;
				<%=fb.textarea("xtra_observ30",prop2.getProperty("xtra_observ30"),false,false,viewMode,0,1,2000,"form-control input-sm no-defuncion","width:100%",null)%>
			</td>
		</tr>-->

		<tr class="bg-headtabla">
			<td class="controls form-inline" colspan="2">
				SIGNOS VITALES
			</td>
		</tr>

		<tr>
			<td class="controls form-inline" colspan="2">
				<iframe id="i_signos_vitales" style="width:100%; height: 400px; border:none" src="../expediente3.0/exp_triage.jsp?desc=SIGNOS%20VITALES&pacId=<%=pacId%>&seccion=77&noAdmision=<%=noAdmision%>&mode=<%=mode%>&modeSec=<%=modeSec%>&cds=<%=cds%>&fg=SV&fecha_nacimiento=<%=pacData.getColValue("fn")%>&codigo_paciente=<%=pacData.getColValue("codigo")%>&from=plan_salida"></iframe>
			</td>
		</tr>


 </table>
<div class="footerform" style="bottom:-11px !important">
				<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
						<tr>
								<td>
								<%=fb.hidden("saveOption","O")%>
								<%=fb.submit("save","Continuar",true,viewMode,"btn btn-inverse btn-sm|fa fa-arrow-right fa-lg",null,"")%>
								<button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
						</tr>
				</table>
		 </div>
<%=fb.formEnd(true)%>
</div>

<div role="tabpanel" class="tab-pane <%=active7%>" id="citas">
<%fb = new FormBean2("form7",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
 <%=fb.formStart(true)%>
 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Continuar')return true;");%>
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
 <%=fb.hidden("tab","7")%>
 <%=fb.hidden("mSize",""+iMed.size())%>
 <%=fb.hidden("diagSize",""+iDiag.size())%>
 <%=fb.hidden("dSize",""+iDieta.size())%>
 <%=fb.hidden("cSize",""+iCuidado.size())%>
 <%=fb.hidden("cds",""+cds)%>
 <%=fb.hidden("desc",desc)%>
 <%=fb.hidden("no_indicacion",noIndicacion)%>
 <%=fb.hidden("no_dosis",noDosis)%>
 <%=fb.hidden("no_frecuencia",noFrecuencia)%>
 <%=fb.hidden("no_duracion",noDuracion)%>
<%=fb.hidden("restrict_nutri_obs",restrictNutriObs)%>
<%=fb.hidden("restrict_nutri",restrictNutri)%>
 <%=fb.hidden("tipo","I")%>
 <%=fb.hidden("action", prop3.getProperty("action"))%>
 <%=fb.hidden("codigo", prop3.getProperty("codigo"))%>
 <%=fb.hidden("pVal", "")%>
 <table cellspacing="0" class="table table-small-font table-bordered table-striped">
	 <tr>
		 <td class="controls form-inline"> Fecha:
			 <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="extra4" />
				<jsp:param name="valueOfTBox1" value="<%=prop3.getProperty("extra4")%>" />
				</jsp:include>
		 </td>
	 </tr>
	 <tr>
		 <td class="controls form-inline">
			 Tel&eacute;lefono
			 <%=fb.textBox("extra5",prop3.getProperty("extra5"),false,false,viewMode,25,20,"form-control input-sm", "width:60%", null)%>
		 </td>
	 </tr>
	 <tr>
		 <td class="controls form-inline">
		 Especialista:&nbsp;
				<%=fb.textBox("extra6",prop3.getProperty("extra6"),true,false,true,5,"form-control input-sm",null,null)%>
				<%=fb.textBox("extra7",prop3.getProperty("extra7"),true,false,true,50,"form-control input-sm",null,null)%>
				<%=fb.button("medico","...",true,viewMode,"btn btn-sm btn-primary",null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
		</td>
	 </tr>

	 <tr>
			<td class="controls form-inline">
				<b>Se educa al paciente por parte del médico tratante</b>&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("extra9","9", prop3.getProperty("extra9")!=null&&prop3.getProperty("extra9").equals("9"),viewMode,false,"",null,"onclick='toggle(4, 9)'",null,"")%>&nbsp;NO</label>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<label class="pointer"><%=fb.radio("extra9","10", prop3.getProperty("extra9")!=null&&prop3.getProperty("extra9").equals("10"),viewMode,false,"observacion",null,"onclick='toggle(4, 10)'",null," data-index=4 data-message='Por favor indicar quien realizò la educaciòn!'")%>&nbsp;SI</label>
			 &nbsp;&nbsp;&nbsp;&nbsp;
			<b>¿Quién realiza educación?</b>
				<%=fb.textarea("xtra_observ4",prop3.getProperty("xtra_observ4"),false,false,viewMode || prop3.getProperty("xtra_observ0").equals(""),0,1,0,"form-control input-sm","width:40%",null)%>
			</td>
		</tr>

	 <tr>
			<td class="controls form-inline">
				<b>¿Se entregan Notas de Cuidado?</b>&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("extra10","11", prop3.getProperty("extra10")!=null&&prop3.getProperty("extra10").equals("11"),viewMode,false,"",null,"onclick='toggle(5, 11)'",null,"")%>&nbsp;SI</label>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<label class="pointer"><%=fb.radio("extra10","12", prop3.getProperty("extra10")!=null&&prop3.getProperty("extra10").equals("12"),viewMode,false,"observacion",null,"onclick='toggle(5, 12)'",null," data-index=5 data-message='Por favor indicar Las razones de no entregar las Care Notes!'")%>&nbsp;NO</label>
			 &nbsp;&nbsp;&nbsp;&nbsp;
			<b>razón</b>
				<%=fb.textarea("xtra_observ5",prop3.getProperty("xtra_observ5"),false,false,viewMode || prop3.getProperty("xtra_observ0").equals(""),0,1,0,"form-control input-sm","width:40%",null)%>
			</td>
		</tr>

	 <tr>
			<td class="controls form-inline">
				<b>Material Educativo </b>&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("extra11","13", prop3.getProperty("extra11")!=null&&prop3.getProperty("extra11").equals("13"),viewMode,false,"",null,"",null,"")%>&nbsp;Verbal</label>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<label class="pointer"><%=fb.radio("extra11","14", prop3.getProperty("extra11")!=null&&prop3.getProperty("extra11").equals("14"),viewMode,false,"",null,"",null,"")%>&nbsp;Escrito</label>
			</td>
		</tr>

		<tr>
			<td class="controls form-inline">
				<b>¿Paciente Comprendi&oacute; la Educaci&oacute;n?</b>&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("extra28","28", prop3.getProperty("extra28")!=null&&prop3.getProperty("extra28").equals("28"),viewMode,false,"",null,"onclick='toggle(28, 28)'",null,"")%>&nbsp;SI</label>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<label class="pointer"><%=fb.radio("extra28","29", prop3.getProperty("extra28")!=null&&prop3.getProperty("extra28").equals("29"),viewMode,false,"observacion",null,"onclick='toggle(28, 29)'",null," data-index=28 data-message='Por favor indicar Las razones de no comprender la educación!'")%>&nbsp;NO</label>
			 &nbsp;&nbsp;&nbsp;&nbsp;
			<b>razón</b>
				<%=fb.textarea("xtra_observ28",prop3.getProperty("xtra_observ28"),false,false,viewMode || prop3.getProperty("xtra_observ28").equals(""),0,1,0,"form-control input-sm","width:40%",null)%>
			</td>
		</tr>



 </table>
<div class="footerform" style="bottom:-11px !important">
				<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
						<tr>
								<td>
								<%=fb.hidden("saveOption","O")%>
								<%=fb.submit("save","Continuar",true,viewMode,"btn btn-inverse btn-sm|fa fa-arrow-right fa-lg",null,"")%>
								<button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
						</tr>
				</table>
		 </div>
<%=fb.formEnd(true)%>
</div>

<!-- Documentos -->
<div role="tabpanel" class="tab-pane <%=active9%>" id="documentos">

	 <table width="100%" cellpadding="1" cellspacing="1" >
				<tr>
						<td>
								<iframe id="doc_esc" name="doc_esc" width="100%" height="300px" scrolling="yes" frameborder="0" src="../expediente3.0/exp_documentos.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&exp=3&expStatus=<%=request.getParameter("estado")!=null?request.getParameter("estado"):""%>&area_revision=SL&docs_for=plan_salida&docId=48"></iframe>
						</td>
				</tr>
		</table>

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
	String itemRemoved = "";
	
	String errCode = "";
	String errMsg = "";

	if(tab.equals("0")) //
	{
			cdo = new CommonDataObject();
			cdo.setTableName("tbl_adm_admision");
			cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia ="+request.getParameter("noAdmision"));
			cdo.addColValue("usuario_modifica",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modifica",cDateTime);
			cdo.addColValue("contacto",request.getParameter("contacto"));
			cdo.addColValue("parentezco_contacto",request.getParameter("parentezco"));
			cdo.addColValue("telefono_contacto",request.getParameter("telefono"));

			if (baction.equalsIgnoreCase("Guardar"))
			{
				ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
				SQLMgr.update(cdo);
				ConMgr.clearAppCtx(null);
			}
	}
		else if (tab.equals("1")) //DIAGNOSTICOS
		{
		int size = 0;
		if (request.getParameter("diagSize") != null) size = Integer.parseInt(request.getParameter("diagSize"));
	iDiag.clear();
		vDiag.clear();
	al.clear();
		for (int i=0; i<size; i++)
		{
		CommonDataObject cdo2 = new CommonDataObject();
		cdo2.setTableName("tbl_adm_diagnostico_x_admision");
		cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and tipo ='S' and diagnostico='"+request.getParameter("diagnostico"+i)+"'");
		cdo2.addColValue("pac_id",request.getParameter("pacId"));
		cdo2.addColValue("paciente",request.getParameter("codPac"));
		cdo2.addColValue("fecha_nacimiento", request.getParameter("dob"));
		cdo2.addColValue("admision",request.getParameter("noAdmision"));
		cdo2.addColValue("diagnostico",request.getParameter("diagnostico"+i));
		cdo2.addColValue("diagnosticoDesc",request.getParameter("diagnosticoDesc"+i));
		cdo2.addColValue("orden_diag",request.getParameter("ordenDiag"+i));
		cdo2.addColValue("tipo","S");
		cdo2.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"+i));
		cdo2.addColValue("fecha_creacion",request.getParameter("fechaCreacion"+i));
		cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo2.addColValue("fecha_modificacion",cDateTime);
		cdo2.setAction(request.getParameter("action"+i).trim()==null||request.getParameter("action"+i).trim().equals("")?"I":request.getParameter("action"+i));
		cdo2.setKey(i);
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cdo2.getKey();
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
			else cdo2.setAction("D");
		}

		if (!cdo2.getAction().equalsIgnoreCase("X"))
		{
			System.out.println(":::::::::::::::::::::::::::::::::: A = "+cdo2.getAction()+" -- "+request.getParameter("action"+i)+" "+(request.getParameter("action"+i).trim()==null||request.getParameter("action"+i).trim().equals("")));
			try
			{
				iDiag.put(cdo2.getKey(),cdo2);
				if(!cdo2.getAction().trim().equals("D"))vDiag.add(cdo2.getColValue("diagnostico"));
				al.add(cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}
		if (!itemRemoved.equals(""))
		{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc);
			return;
		}
	if (baction.equalsIgnoreCase("Continuar"))
	{
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
		
		 errCode = SQLMgr.getErrCode();
		 errMsg = SQLMgr.getErrMsg();
		
		if(errCode.equals("1")) tab = "3";
	}
	}
	else if(tab.equals("2")) //
		{
			int size = 0;
			al.clear();
			iMed.clear();
			if (request.getParameter("mSize") != null) size = Integer.parseInt(request.getParameter("mSize"));

			for (int i=0; i<size; i++)
			{
					CommonDataObject cdo2 = new CommonDataObject();
					cdo2.setTableName("tbl_sal_salida_medicamento");
					cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and secuencia="+request.getParameter("secuencia"+i));
					cdo2.addColValue("pac_id",request.getParameter("pacId"));
					cdo2.addColValue("admision",request.getParameter("noAdmision"));
					cdo2.addColValue("no_receta",request.getParameter("no_receta"+i));
					cdo2.addColValue("tot_imp",request.getParameter("tot_imp"+i));
					cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
					cdo2.addColValue("fecha_modificacion",cDateTime);

				if (request.getParameter("secuencia"+i)==null || ( request.getParameter("secuencia"+i).trim().equals("0")||request.getParameter("secuencia"+i).trim().equals("")))
				{
					cdo2.setAutoIncCol("secuencia");
					cdo2.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
					cdo2.addColValue("fecha_creacion",cDateTime);
					cdo2.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
				}else cdo2.addColValue("secuencia",request.getParameter("secuencia"+i));

					cdo2.addColValue("medicamento",request.getParameter("medicamento"+i));
					cdo2.addColValue("indicacion",request.getParameter("indicacion"+i).trim().equals("")?"N/A":request.getParameter("indicacion"+i));
					cdo2.addColValue("dosis",request.getParameter("dosis"+i).trim().equals("")?"N/A":request.getParameter("dosis"+i));
					cdo2.addColValue("frecuencia",request.getParameter("frecuencia"+i).trim().equals("")?"N/A":request.getParameter("frecuencia"+i));
					cdo2.addColValue("duracion",request.getParameter("duracion"+i).trim().equals("")?"N/A":request.getParameter("duracion"+i));
					cdo2.setAction(request.getParameter("action"+i));
						cdo2.setKey(i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cdo2.getKey();
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
			else cdo2.setAction("D");
		}

		if (!cdo2.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iMed.put(cdo2.getKey(),cdo2);
				al.add(cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//for
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_indicacion="+noIndicacion+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion);
				return;
		}
		if(baction.equals("+"))//Agregar
		{
			CommonDataObject cdo2 = new CommonDataObject();

			cdo2.addColValue("secuencia","0");
			cdo2.addColValue("tot_imp","0");
			cdo2.setAction("I");
			cdo2.setKey(iMed.size()+1);

			try
			{
				iMed.put(cdo2.getKey(),cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_indicacion="+noIndicacion+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion);
			return;
		}

				if (baction.equalsIgnoreCase("Guardar"))
				{
					if (al.size() == 0)
					{
						CommonDataObject cdo3 = new CommonDataObject();

						cdo3.setTableName("tbl_sal_salida_medicamento");
						cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
						cdo3.setAction("I");
						al.add(cdo3);
					}

					ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
					SQLMgr.saveList(al,true);
					ConMgr.clearAppCtx(null);
				}
			}
			else if(tab.equals("3")) //
			{
			 int size = 0;
		if (request.getParameter("dSize") != null) size = Integer.parseInt(request.getParameter("dSize"));

	iDieta.clear();
	vDieta.clear();
	al.clear();
		for (int i=0; i<size; i++)
		{
		 CommonDataObject cdo2 = new CommonDataObject();

		cdo2.setTableName("tbl_sal_salida_dieta");

		if (request.getParameter("codigo"+i) != null && request.getParameter("codigo"+i).equals("0"))
			cdo2.setAutoIncCol("codigo");
		else {
			cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and tipo_dieta="+request.getParameter("tipo_dieta"+i)+" and subtipo_dieta="+request.getParameter("subtipo_dieta"+i)+" and codigo = "+request.getParameter("codigo"+i));
			cdo2.addColValue("codigo", request.getParameter("codigo"+i));
		}

		cdo2.addColValue("pac_id",request.getParameter("pacId"));
		cdo2.addColValue("admision",request.getParameter("noAdmision"));

			if (request.getParameter("restrict_nutri") != null) {
				cdo2.addColValue("restrict_nutri", request.getParameter("restrict_nutri"));
				cdo2.addColValue("restrict_nutri_obs", request.getParameter("restrict_nutri_obs"));
			}

		cdo2.addColValue("tipo_dieta",request.getParameter("tipo_dieta"+i));
		cdo2.addColValue("descDieta",request.getParameter("descDieta"+i));
		cdo2.addColValue("subtipo_dieta",request.getParameter("subtipo_dieta"+i));
		cdo2.addColValue("descSubTipo",request.getParameter("descSubTipo"+i));
		cdo2.addColValue("observacion",request.getParameter("observacion"+i));
			cdo2.addColValue("code",request.getParameter("tipo_dieta"+i)+"-"+ request.getParameter("subtipo_dieta"+i));
		cdo2.setAction(request.getParameter("action"+i).trim()==null||request.getParameter("action"+i).trim().equals("")?"I":request.getParameter("action"+i));
		cdo2.setKey(i);
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
		itemRemoved = cdo2.getKey();
		if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
		else cdo2.setAction("D");
		}

			if (!cdo2.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iDieta.put(cdo2.getKey(),cdo2);
				al.add(cdo2);
				if(!cdo2.getAction().trim().equals("D"))vDieta.add(cdo2.getColValue("code"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		}

		if (!itemRemoved.equals(""))
		{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&type=3&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion);
			return;
		}
	if (baction.equalsIgnoreCase("Continuar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo3 = new CommonDataObject();

			cdo3.setTableName("tbl_sal_salida_dieta");
			cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
			cdo3.setAction("I");
			al.add(cdo3);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
		
		errCode = SQLMgr.getErrCode();
		 errMsg = SQLMgr.getErrMsg();
		
		if(errCode.equals("1")) tab = "4";
	}
	}
else if(tab.equals("4")) //
{
	int size = 0;
		if (request.getParameter("cSize") != null) size = Integer.parseInt(request.getParameter("cSize"));
	iCuidado.clear();
	vCuidado.clear();
	al.clear();
		for (int i=0; i<size; i++)
		{
		 CommonDataObject cdo2 = new CommonDataObject();

		cdo2.setTableName("tbl_sal_salida_cuidado");

		cdo2.addColValue("pac_id",request.getParameter("pacId"));
		cdo2.addColValue("admision",request.getParameter("noAdmision"));
		cdo2.addColValue("observacion",request.getParameter("observacion"+i));
		cdo2.addColValue("guia_id",request.getParameter("guia_id"+i));
		cdo2.addColValue("descGuia",request.getParameter("descGuia"+i));
		cdo2.setAction(request.getParameter("action"+i).trim()==null||request.getParameter("action"+i).trim().equals("")?"I":request.getParameter("action"+i));
		cdo2.addColValue("codigo",request.getParameter("codigo"+i));
		cdo2.addColValue("guia_desc",request.getParameter("descGuia"+i));
		cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo2.addColValue("fecha_modificacion","sysdate");
		if (cdo2.getAction().equalsIgnoreCase("I")) {
			cdo2.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo2.addColValue("fecha_creacion","sysdate");
		}
		cdo2.setKey(i);
		if (request.getParameter("codigo"+i) != null && request.getParameter("codigo"+i).equals("0"))
			cdo2.setAutoIncCol("codigo");
		else {
			cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and guia_id="+request.getParameter("guia_id"+i)+" and codigo = "+request.getParameter("codigo"+i));
			cdo2.addColValue("codigo", request.getParameter("codigo"+i));
		}

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = cdo2.getKey();
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");//if it is not in DB then remove it
			else cdo2.setAction("D");
		}

		if (!cdo2.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iCuidado.put(cdo2.getKey(),cdo2);
				if(!cdo2.getAction().trim().equals("D"))vCuidado.add(cdo2.getColValue("guia_id"));
				al.add(cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		}

		if (!itemRemoved.equals(""))
		{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			CommonDataObject tmp = new CommonDataObject();
			tmp.addColValue("codigo","0");
			tmp.addColValue("guia_id","-1");
			tmp.addColValue("descGuia","CUIDADO");

			int cuidadoLastLineNo = iCuidado.size() + 1;
			if (cuidadoLastLineNo < 10) key = "00"+cuidadoLastLineNo;
			else if (cuidadoLastLineNo < 100) key = "0"+cuidadoLastLineNo;
			else key = ""+cuidadoLastLineNo;
			tmp.addColValue("key",key);

			try {
				iCuidado.put(key, tmp);
				vCuidado.add(tmp.getColValue("guia_id"));
			} catch(Exception e) {
				System.err.println(e.getMessage());
			}
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&modeSec="+modeSec+"&mode="+mode+"&pacId="+pacId+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion);
			return;
		}
		if (baction.equalsIgnoreCase("Continuar"))
		{
			if (al.size() == 0)
			{
				CommonDataObject cdo3 = new CommonDataObject();

				cdo3.setTableName("tbl_sal_salida_cuidado");
				cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
				cdo3.setAction("I");
				al.add(cdo3);
			}

			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
			
			errCode = SQLMgr.getErrCode();
			errMsg = SQLMgr.getErrMsg();
			
			if(errCode.equals("1")) tab = "5";
		}
	} else if (tab.equals("5") || tab.equals("6") || tab.equals("7")) {

			prop = new Properties();
			prop.setProperty("pac_id", pacId);
			prop.setProperty("admision", noAdmision);
			prop.setProperty("tipo", request.getParameter("tipo"));

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

			for (int i = 0; i<40; i++) {
				if (request.getParameter("extra"+i) != null && !request.getParameter("extra"+i).trim().equals("")) prop.setProperty("extra"+i, request.getParameter("extra"+i));
				if (request.getParameter("xtra_observ"+i) != null && !request.getParameter("xtra_observ"+i).trim().equals("")) prop.setProperty("xtra_observ"+i, request.getParameter("xtra_observ"+i));
			}

		 if (baction.equalsIgnoreCase("Continuar") || baction.equalsIgnoreCase("Guardar")){
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			if (request.getParameter("action") != null && request.getParameter("action").trim().equals("U")) {
				PSEMgr.update(prop);
			}
			else {
				PSEMgr.add(prop);
				codigo = PSEMgr.getPkColValue("codigo");
			}
			ConMgr.clearAppCtx(null);
			
			errCode = PSEMgr.getErrCode();
			errMsg = PSEMgr.getErrMsg();
			
			if (errCode.equals("1")) {
				if (tab.equals("5")) tab = "6";
				else if (tab.equals("6")) tab = "7";
				else if (tab.equals("7")) tab = "9";
			}
			
		}

	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
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
} else throw new Exception(errMsg);
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&cds=<%=cds%>&noAdmision=<%=noAdmision%>&tab=<%=tab%>&desc=<%=desc%>&no_indicacion=<%=noIndicacion%>&no_dosis=<%=noDosis%>&no_frecuencia=<%=noFrecuencia%>&no_duracion=<%=noDuracion%>&codigo=<%=codigo%>&restrict_nutri<%=restrictNutri%>&restrict_nutri_obs=<%=restrictNutriObs%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
