<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbCol = new StringBuffer();
StringBuffer sbTable = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
CommonDataObject pCdo = new CommonDataObject();
String mode = (request.getParameter("mode") == null)?"add":request.getParameter("mode");
String fp = (request.getParameter("fp") == null)?"":request.getParameter("fp");
String estado = (request.getParameter("estado") == null)?"":request.getParameter("estado");
String pacId = (request.getParameter("pacId") == null)?"":request.getParameter("pacId");
String noAdmision = (request.getParameter("noAdmision") == null)?"":request.getParameter("noAdmision");
String cds = (request.getParameter("cds") == null)?"":request.getParameter("cds");
String profiles = CmnMgr.vector2numSqlInClause(UserDet.getUserProfile());
String consetimiento="";
try { consetimiento = java.util.ResourceBundle.getBundle("issi").getString("consetimiento"); } catch(Exception e) { consetimiento = "1"; }

if (pacId.trim().equals("") || noAdmision.trim().equals("") || noAdmision.equals("0")) throw new Exception("La Cuenta del Paciente no es válida. Por favor intente nuevamente!");
if (fp.equalsIgnoreCase("external")) {
	sbSql = new StringBuffer();
	sbSql.append("select estado, cds from tbl_adm_atencion_cu where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and secuencia = ");
	sbSql.append(noAdmision);
	pCdo = SQLMgr.getData(sbSql.toString());
	if (pCdo == null) pCdo = new CommonDataObject();
	estado = pCdo.getColValue("estado");
	cds = pCdo.getColValue("cds");
}

sbSql.append("select count(*) from tbl_sec_profiles a, tbl_sec_module b where a.profile_id in (");
sbSql.append(CmnMgr.vector2numSqlInClause(UserDet.getUserProfile()));
sbSql.append(") and a.module_id = b.id and a.module_id = 11");
if (!UserDet.getUserProfile().contains("0") && CmnMgr.getCount(sbSql.toString()) == 0) throw new Exception("Usted no tiene el Perfil para accesar al Expediente. Por favor consulte con su administrador!");

sbSql = new StringBuffer();
sbSql.append("select count(*) from tbl_adm_atencion_cu where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noAdmision);
if (CmnMgr.getCount(sbSql.toString()) == 0) throw new Exception("El Paciente no tiene registro de atención. Por favor consulte con su Administrador!");

sbSql = new StringBuffer();
sbSql.append("select z.exp_id, to_char(nvl(z.f_nac, z.fecha_nacimiento),'dd/mm/yyyy') as dob, decode(z.provincia,null,' ',z.provincia) as provincia, nvl(z.sigla,' ') as sigla, decode(z.tomo,null,' ',z.tomo) as tomo, decode(z.asiento,null,' ',z.asiento) as asiento, nvl(z.d_cedula,' ') as dCedula, nvl(z.pasaporte,' ') as pasaporte, z.nombre_paciente as nombrePaciente, get_age(z.f_nac,(select nvl(fecha_ingreso,fecha_creacion) from tbl_adm_admision where pac_id = z.pac_id and secuencia = ");
sbSql.append(noAdmision);
sbSql.append("),null) as edad, get_age(z.f_nac,(select nvl(fecha_ingreso,fecha_creacion) from tbl_adm_admision where pac_id = z.pac_id and secuencia = ");
sbSql.append(noAdmision);
sbSql.append("),'mm') as edad_mes, z.sexo, (select (select '['||codigo||'] '||descripcion from tbl_cds_centro_servicio where codigo = y.cds) from tbl_adm_atencion_cu y where pac_id = z.pac_id and secuencia = ");
sbSql.append(noAdmision);
sbSql.append(") as cds, (select (select '['||codigo||'] '||descripcion from tbl_adm_categoria_admision where codigo = y.categoria) from tbl_adm_admision y where pac_id = z.pac_id and secuencia = ");
sbSql.append(noAdmision);
sbSql.append(") as categoria, nvl((SELECT tipo_sangre FROM tbl_bds_tipo_sangre where to_char(sangre_id) = z.tipo_sangre), nvl(z.tipo_sangre,'N/A')) tipo_sangre from vw_adm_paciente z where z.pac_id = ");
sbSql.append(pacId);
pCdo = SQLMgr.getData(sbSql.toString());
if (pCdo == null) pCdo = new CommonDataObject();

sbCol.append("nvl(z.nombre_corto,z.descripcion) as seccion, nvl(replace(z.path,'/expediente/','/expediente3.0/')||decode(instr(z.path,'?'),0,'?',null,'','&'),' ') as path, z.codigo, z.descripcion, '0' editable, 'view' as actionMode");
sbTable.append("tbl_sal_expediente_secciones z");
if (UserDet.getUserProfile().contains("0")) {

	sbCol.append(", '");
	sbCol.append((estado.equalsIgnoreCase("F"))?"view":mode);
	sbCol.append("' as actionMode, ");
	sbCol.append((mode.equalsIgnoreCase("view"))?"0":"1");
	sbCol.append(" as editable");

} else {

	sbCol.append(", decode(y.editable,1,decode(z.status,'A','");
	sbCol.append((estado.equalsIgnoreCase("F"))?"view":mode);
	sbCol.append("','I','view'),'view') as actionMode, decode(z.status,'A',");
	sbCol.append((mode.equalsIgnoreCase("view"))?"0":"y.editable");
	sbCol.append(",'I',0) as editable");

	sbTable.append(", (select secc_id, max(editable) as editable from tbl_sal_exp_secc_profile where profile_id in (");
	sbTable.append(profiles);
	sbTable.append(") group by secc_id) y");

	sbFilter.append(" and z.status = 'A' and z.codigo = y.secc_id and exists (select null from tbl_sal_exp_secc_centro a where cod_sec = z.codigo and exists (select null from tbl_adm_atencion_cu where cds = a.centro_servicio and pac_id = ");
	sbFilter.append(pacId);
	sbFilter.append(" and secuencia = ");
	sbFilter.append(noAdmision);
	sbFilter.append("))");

}

sbFilter.append(" and (z.sexo = '");
sbFilter.append(pCdo.getColValue("sexo","A"));
sbFilter.append("' or z.sexo = 'A')");

sbFilter.append(" and ");
sbFilter.append(pCdo.getColValue("edad","0"));
sbFilter.append(" between z.edad_from and z.edad_to ");

sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CHK_ANT_ALERGIA'),'N') as chk_ant_alergia, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'ANT_ALERGIA_ID'),5) as ant_alergia_id, get_sec_comp_param(-1,'CONSENTIMIENTO') as consentimiento from dual");
CommonDataObject cdoX = SQLMgr.getData(sbSql.toString());
if (!cdoX.getColValue("consentimiento"," ").trim().equals("")) consetimiento = cdoX.getColValue("consentimiento");

session.setAttribute("__wTitle",(fp.equalsIgnoreCase("history"))?"Expediente Histórico Cellbyte":"Expediente Cellbyte");

String reloadAlertBarTimer = "1";
try{reloadAlertBarTimer = java.util.ResourceBundle.getBundle("issi").getString("exp.reloadAlertBarTimer");}catch(Exception e){reloadAlertBarTimer = "1";}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<link rel="stylesheet" type="text/css" href="../css/dhtmlxTabbar_v51_std/codebase/skins/material/dhtmlxtabbar.css">
<script  src="../css/dhtmlxTabbar_v51_std/codebase/dhtmlxtabbar.js"></script>
<link rel="stylesheet" href="../css/slideBootMenu/css/BootSideMenu.css">
<script  src="../css/slideBootMenu/js/BootSideMenu.js"></script>

<script>


var tabbar;
var tabArray = new Array();

$(document).ready(function(){
	$('.dropdown-submenu a.test').on("click", function(e){
		$(this).next('ul').toggle();
		e.stopPropagation();
		e.preventDefault();
	});

		$("#alert-bell").dblclick(function(){
			 reloadAlerts();
		})

		//init
		reloadAlerts();
});
function checkAntAler(secId){
<% if (!estado.equalsIgnoreCase("F") && (cdoX.getColValue("chk_ant_alergia","N").equalsIgnoreCase("Y") || cdoX.getColValue("chk_ant_alergia","N").equalsIgnoreCase("S"))) { %>
	if(secId==<%=cdoX.getColValue("ant_alergia_id","5")%>){
		var c=getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_alergia_paciente','pac_id = <%=pacId%> and admision = <%=noAdmision%>','');
		if(!parseInt(c,10)){
				parent.CBMSG.warning("El paciente no tiene Antecedentes Alérgicos registrados. Por politicas del Hospital es necesario registrar Antecedentes Alérgicos antes de Solicitar MEDICAMENTOS !!!");
		return false;
		}
	}
<% } %>

<% if (!estado.equalsIgnoreCase("F")) { %>
	if(secId==75){
		var x= getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b',' a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.codigo=b.orden_med and b.pac_id = <%=pacId%> and b.secuencia = <%=noAdmision%> and b.forma_solicitud=\'T\' and nvl(b.validada,\'N\') =\'N\' and ((b.omitir_orden=\'N\' and b.estado_orden=\'A\') or (b.ejecutado=\'N\' and b.estado_orden=\'S\' )) ','');

	if(parseInt(x,10)){
				parent.CBMSG.warning("El paciente tiene ordenes medicas telefonicas pendiente por refrendar. Por politicas del Hospital es necesario que refrende las ordenes antes de darle salida!!!");
		return false;
		}
	}
<% } %>

	return true;
}
function validateTab(toPage){
retVal=-1;
for(var i=0;i<tabArray.length;i++)
{
//alert(toPage+"            "+tabArray[i]);
if(toPage==tabArray[i]) retVal=i; } return retVal;
}
function navBar(toPage,secDesc){
var tabWidth=secDesc.length * 7;
if(toPage==""){
tabbar = new dhtmlXTabBar({
		parent:         "a_tabbar",
		close_button:   true
	});
}else{
tabExist=validateTab(toPage);
//alert(tabExist);

if(tabExist>=0){
if(tabbar.cells("nav"+tabExist)==null || tabbar.cells("nav"+tabExist)==undefined){ tabArray[tabExist]="Closed"; navBar(toPage,secDesc);}else tabbar.tabs("nav"+tabExist).setActive();
}else{
tabbar.addTab("nav"+(tabArray.length), secDesc);
tabbar.tabs("nav"+(tabArray.length)).attachURL(toPage+'&_viewMode=<%=mode%>');
tabbar.tabs("nav"+(tabArray.length)).setActive();
tabbar.attachEvent("onSelect", function(id) {
		if (tabbar.cells(id)._frame);
		//alert(id);
		//alert(tabbar.cells(id)._frame.contentWindow.location);
		return true;
});
tabbar.attachEvent("onTabClose", function(id) {
		if (tabbar.cells(id)._frame);
		tabArray[parseInt(id.substring(3))]="Closed"; //alert(id);
		//alert(tabbar.cells(id)._frame.contentWindow.location);
		return true;
});
tabArray[tabArray.length]=toPage;}
}
}
function doAction()
{
navBar("","");
<%if(fp.equalsIgnoreCase("secciones_guardadas")){%>
<%
String _path = request.getParameter("path") == null ? "" : request.getParameter("path");
String _secDesc = request.getParameter("sectionDesc") == null ? "" : request.getParameter("sectionDesc");
String _seccion = request.getParameter("section") == null ? "0" : request.getParameter("section");
String _mode = request.getParameter("mode") == null ? "view" : request.getParameter("mode");
_path = _path.replaceAll("/expediente/", "/expediente3.0/");
%>
doRedirect('<%=_secDesc%>', '<%=_seccion%>', '<%=_mode%>', 0, '<%=_path%>&');
<%}%>
}

function doRedirect(secDesc,seccion,mode,editable,path,docId){
	if(secDesc=='0'){document.getElementById('iExpSection').src='';secDesc='';}
	if(checkAntAler(seccion)){
		if(docId==undefined||docId==null||docId.trim()=='')docId=0;
		$("#ExpSectionTitle").html(secDesc);
		var xtraQS="desc="+secDesc+"&pacId=<%=pacId%>&seccion="+seccion+"&noAdmision=<%=noAdmision%>&mode="+mode+"&cds=<%=cds%>&defaultAction="+editable+"&docId="+docId+"&estado=<%=estado%>&sexo=<%=pCdo.getColValue("sexo","N/A")%>&exp=3";
		if(seccion!=null&&seccion!=''&&path!=null&&path!=''){
			toPage=path+xtraQS;
			//alert(toPage);
			navBar(toPage,secDesc);
			var $iExpSection = $("#iExpSection")
						//$iExpSection.attr('height', $(window).height() - 150)
			//$iExpSection.get(0).src=toPage;
			executeDB('<%=request.getContextPath()%>','call sp_sec_user_log_exp(<%=UserDet.getUserId()%>,<%=pacId%>,<%=noAdmision%>,'+seccion+',null,\'<%=session.getId()%>\',\'<%=request.getRemoteAddr()%>\',\''+secDesc+'\',\''+path+'\')')
		}
	}
}
function setPatientInfo(formName,iframeName)
{
	if(iframeName==undefined||iframeName==null)
	{
		document.forms[formName].dob.value=document.paciente.fechaNacimiento.value;
		document.forms[formName].codPac.value=document.paciente.codigoPaciente.value;
	}
	else
	{
		tabbar.tabs(tabbar.getActiveTab()).getFrame().contentWindow.document.forms[formName].dob.value=document.paciente.fechaNacimiento.value;
		tabbar.tabs(tabbar.getActiveTab()).getFrame().contentWindow.document.forms[formName].codPac.value = document.paciente.codigoPaciente.value;
		//window.frames[iframeName].document.forms[formName].dob.value=document.paciente.fechaNacimiento.value;
		//window.frames[iframeName].document.forms[formName].codPac.value=document.paciente.codigoPaciente.value;
	}
}
//May be i should implement something reusable
function showHelp(){
	$('div#imageContainer').css("text-align","center").dialog({
		modal: true,
		height: 'auto',
		width: 'auto',
		maxWidth: 800,
		maxHeight: 500,
		position: ['center', 'center'],
		title: 'Valores Normales de Signos Vitales',
		resizable: false,
		show: {
			effect: "blind",
			duration: 1000
		},
		hide: {
			effect: "explode",
			duration: 1000
		}
		,closeText: ""
	});
}
function logout(){window.opener.top.window.location='<%=request.getContextPath()%>/logout.jsp';}
function preferences(){window.opener.top.abrir_ventana('<%=request.getContextPath()%>/admin/user_preferences.jsp');}
function alertView(typeAlert){
//showPopWin('../common/ialert.jsp?displayArea=expediente&fp=expediente&pacId=<%=pacId%>&admision=<%=noAdmision%>&doSimpleBlinking=1&typeAlert='+typeAlert, winWidth*.45,winHeight*.45,null,null,'');
//window.opener.top.abrir_ventana('<%=request.getContextPath()%>/common/ialert.jsp?displayArea=expediente&fp=expediente&pacId=<%=pacId%>&admision=<%=noAdmision%>&typeAlert='+typeAlert);
}


function showInterv(url, opts) {
	 return loadModal(url, opts);
}

function hideModal() {
	 $('#modal').modal('hide')
}

function loadModal(url, _opts) {
 var _options = _opts || {};
 var screwTheUser = _options.screwTheUser ? _options.screwTheUser : false;
 var title = _options.title ? _options.title : 'Intervenciones';

 var options = {show: true}
 if (screwTheUser && screwTheUser == true) {
	 $("#btn-close").hide(0);
	 options['backdrop'] = 'static';
 }

 $('#modal-content')
	 .load(url, function(response, status, xhr){
		 if (status == 'error') {
			 alert(xhr.status + " " + xhr.statusText)
		 }
		 else {
				$('#modal').on('shown.bs.modal', function(e){
				 $(e.target).find("#loadingmsg").remove();
				}).modal(options);
		 }
 });
 $("#myModalLabel").html(title);
}

function interval(func, wait, times){
		var interv = function(w, t){
				return function(){
						if(typeof t === "undefined" || t-- > 0){
								setTimeout(interv, w);
								try{
										func.call(null);
								}
								catch(e){
										t = 0;
										throw e.toString();
								}
						}
				};
		}(wait, times);

		setTimeout(interv, wait);
};

interval(function(){reloadAlerts();}, (parseInt("<%=reloadAlertBarTimer%>",10) * 60 * 1000) , 30);

function reloadAlerts() {
	var a = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sec_alert z',"z.pac_id = <%=pacId%> and nvl(z.admision,<%=noAdmision%>) = <%=noAdmision%> and status = 'A' and exists (select null from tbl_sec_alert_type where id = z.alert_type) ",'');
	var d = [];
	if (parseInt(a,10) > 0) {
		d = splitRows(getDBData('<%=request.getContextPath()%>',"'('||(select count(*) from tbl_sec_alert where pac_id =<%=pacId%> and status = 'A' and alert_type = z.id)||') '||description as descripcion, (select join(cursor(select message from tbl_sec_alert where pac_id= <%=pacId%> and nvl(admision, <%=noAdmision%>) = <%=noAdmision%> and status = 'A' and alert_type = z.id),';') from dual) as mensaje",'tbl_sec_alert_type z'," status = 'A' and exists (select null from tbl_sec_alert where pac_id = <%=pacId%> and nvl(admision,<%=noAdmision%>) = <%=noAdmision%> and status = 'A' and alert_type = z.id) order by z.description",''));
	}

	if (d.length) {
		var det = "";
		for (var i = 0; i < d.length; i++) {
			var data = d[i].split('|');
			var text = data[0] || '';
			var title = data[1] || '';
			det += '<li title="'+title+'"><a href="#"><i class="fa fa-exclamation-circle fa-18 fa-white"></i>' + text + '</a></li>';
		}
		$("#alert-bell").html(a);
		$("#alert-detail").html(det);
	} else {
		 $("#alert-detail").html("");
		 $("#alert-bell").html(a);
	}
}

function printClinicalHistory(opt) {
	switch (opt) {
		case 1 : abrir_ventana('../expediente3.0/print_hist_clinica_general.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&sexo=<%=pCdo.getColValue("sexo")%>&edad=<%=pCdo.getColValue("edad")%>&edad_mes=<%=pCdo.getColValue("edad_mes")%>&cds=<%=cds%>');break;
		case 2 : abrir_ventana('../expediente3.0/print_hist_clinica_pediatria.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&sexo=<%=pCdo.getColValue("sexo")%>&edad=<%=pCdo.getColValue("edad")%>&edad_mes=<%=pCdo.getColValue("edad_mes")%>&cds=<%=cds%>');break;
		case 3 : abrir_ventana('../expediente3.0/print_hist_clinica_obstetrica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&sexo=<%=pCdo.getColValue("sexo")%>&edad=<%=pCdo.getColValue("edad")%>&edad_mes=<%=pCdo.getColValue("edad_mes")%>&cds=<%=cds%>');break;
		case 4 : abrir_ventana('../expediente3.0/print_hist_clinica_preoperatioria.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&sexo=<%=pCdo.getColValue("sexo")%>&edad=<%=pCdo.getColValue("edad")%>&edad_mes=<%=pCdo.getColValue("edad_mes")%>&cds=<%=cds%>');break;
		//case 5 : abrir_ventana('../expediente3.0/print_hist_clinica_neonato.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&sexo=<%=pCdo.getColValue("sexo")%>&edad=<%=pCdo.getColValue("edad")%>&edad_mes=<%=pCdo.getColValue("edad_mes")%>&cds=<%=cds%>');break;
		case 5 : abrir_ventana('../expediente3.0/print_historia_clinica_neonatal.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&sexo=<%=pCdo.getColValue("sexo")%>&edad=<%=pCdo.getColValue("edad")%>&edad_mes=<%=pCdo.getColValue("edad_mes")%>&cds=<%=cds%>&codigo=1');break;
		default:
		break;

	}
}

$(function(){
		$("#abbrev-launcher").click(function(){
				abrir_ventana('../expediente3.0/list_abreviaturas.jsp');
		});
});
</script>
<style>
.dropdown-submenu {
	position: relative;
}
.dropdown-submenu .dropdown-menu {
	top: 0;
	left: 100%;
	margin-top: -1px;
}
#contentForm {
	height: 400px;
	width: 100%;
}
</style>
<style>
.modal-wide .modal-dialog {
	width: 80%;
}
#popupContainer{z-index:99999 !important;}
</style>
</head>
<body onLoad="javascript:doAction();">

<div class="modal modal-wide" id="modal">
	<div class="modal-dialog" role="document">
		<div class="modal-content">
			<div class="modal-header">
				<button id="btn-close" type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
				<h4 class="modal-title" id="myModalLabel">Intervenciones</h4>
			</div>
			<div class="modal-body" id="modal-content"></div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
</div><!-- /.modal -->



<!-- Inicio Barra de Navegacion -->
<div id="custom-bootstrap-menu" class="navbar navbar-default custom-navbar navbar-fixed-top" style="border:3px;" role="navigation">
<div class="container-fluid">

	<div class="navbar-header">
	<img alt="CellByte" style="max-width:120px; margin-top: 5px;" src="../css/bootstrap/img/logo_white.png">
	<!-- NO REMOVER - TOGGLE PARA MOVILES -->
	<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-menubuilder"><span class="sr-only">Abrir Men&uacute;</span><i class="fa fa-bars fa-toggle fa-white"></i></button>
	</div>

<!--comienza el menu interno-->
<div class="collapse navbar-collapse navbar-menubuilder">
<ul class="nav navbar-nav navbar-right">

<li class="dropdown" id="abbrev-launcher">
		<a href="#!" class="dropdown-toggle">
		<i class="fa-18 fa fa-list-alt" aria-hidden="true"></i>
		Abreviaturas</a>
</li>

<!--Reportes Historiales-->
<li class="dropdown">
	<a class="dropdown-toggle" data-toggle="dropdown" href="#"><i class="fa fa-print fa-18 fa-white"></i>Historias Cl&iacute;nicas<span class="caret"></span></a>
	<ul class="dropdown-menu">
		<li><a href="javascript:printClinicalHistory(1);"><i class="fa fa-print fa-18 fa-white"></i>General</a></li>
		<li><a href="javascript:printClinicalHistory(2);"><i class="fa fa-print fa-18 fa-white"></i>Pediatr&iacute;a</a></li>
		<li><a href="javascript:printClinicalHistory(3);"><i class="fa fa-print fa-18 fa-white"></i>Obst&eacute;trica</a></li>
		<li><a href="javascript:printClinicalHistory(4);"><i class="fa fa-print fa-18 fa-white"></i>Preoperatoria</a></li>
		<li><a href="javascript:printClinicalHistory(5);"><i class="fa fa-print fa-18 fa-white"></i>Neonato</a></li>
	</ul>
</li>


<!-- Inicio Menu Orden Medica -->
<%
sbSql = new StringBuffer();
sbSql.append("select ");
sbSql.append(sbCol);
sbSql.append(" from ");
sbSql.append(sbTable);
sbSql.append(" where z.grupo_exp = 'OM' and z.status = 'A' ");
sbSql.append(sbFilter);

if (!UserDet.getUserProfile().contains("0") && !profiles.trim().equals("")) {
	sbSql.append(" and codigo in (");
	sbSql.append(" select secc_code from tbl_sal_exp_docs_secc where doc_id in (");
	sbSql.append(" select doc_id from tbl_sal_exp_docs_profile where profile_id IN (");
	sbSql.append(profiles);
	sbSql.append(")");
	sbSql.append(")");
	sbSql.append(")");
}

sbSql.append(" order by 1");
al = SQLMgr.getDataList(sbSql.toString());
if (al.size() > 0) {
%>
	<li class="dropdown">
	<a class="dropdown-toggle" data-toggle="dropdown" href="#"><i class="fa fa-heartbeat fa-18 fa-white"></i>Ordenes M&eacute;dicas<span class="caret"></span></a>
	<ul class="dropdown-menu">
<%
for (int i = 0; i < al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
%>
	<li><a href="javascript:doRedirect('<%=cdo.getColValue("descripcion")%>',<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("actionMode")%>',<%=cdo.getColValue("editable")%>,'<%=cdo.getColValue("path")%>')"><span class="fa fa-<%=(cdo.getColValue("editable").equals("0"))?"eye":"edit"%> fa-18 fa-white" aria-hidden="true"></span><%=cdo.getColValue("seccion")%></a></li>
<% } %>
	</ul>
	</li>
<% } %>
<!-- Fin Menu Orden Medica -->


<!-- Inicio Menu Antecedentes -->
<%
sbSql = new StringBuffer();
sbSql.append("select ");
sbSql.append(sbCol);
sbSql.append(" from ");
sbSql.append(sbTable);
sbSql.append(" where z.grupo_exp = 'UC' and z.status = 'A' ");
sbSql.append(sbFilter);
if (!UserDet.getUserProfile().contains("0") && !profiles.trim().equals("")) {
	sbSql.append(" and codigo in (");
	sbSql.append(" select secc_code from tbl_sal_exp_docs_secc where doc_id in (");
	sbSql.append(" select doc_id from tbl_sal_exp_docs_profile where profile_id IN (");
	sbSql.append(profiles);
	sbSql.append(")");
	sbSql.append(")");
	sbSql.append(")");
}
sbSql.append(" order by 1");
al = SQLMgr.getDataList(sbSql.toString());
if (al.size() > 0) {
%>
	<li class="dropdown">
	<a class="dropdown-toggle" data-toggle="dropdown" href="#"><i class="fa fa-book fa-18 fa-white"></i>Uso constante<span class="caret"></span></a>
	<ul class="dropdown-menu">
<%
for (int i = 0; i < al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
%>
	<li><a href="javascript:doRedirect('<%=cdo.getColValue("descripcion")%>',<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("actionMode")%>',<%=cdo.getColValue("editable")%>,'<%=cdo.getColValue("path")%>')"><span class="fa fa-<%=(cdo.getColValue("editable").equals("0"))?"eye":"edit"%> fa-18 fa-white" aria-hidden="true"></span><%=cdo.getColValue("seccion")%></a></li>
<% } %>
	</ul>
	</li>
<% } %>
<!-- Fin Menu Antecedentes -->


<% if (!fp.equalsIgnoreCase("history")) { %>

<!-- Inicio Menu Alertas -->
<%
sbSql = new StringBuffer();
sbSql.append("select count(*) as nRecs from tbl_sec_alert z where z.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and nvl(z.admision, ");
sbSql.append(noAdmision);
sbSql.append(") = ");
sbSql.append(noAdmision);
sbSql.append("  and status = 'A' and exists (select null from tbl_sec_alert_type where id = z.alert_type)");
CommonDataObject c = SQLMgr.getData(sbSql.toString());
if (c == null) c = new CommonDataObject();

sbSql = new StringBuffer();
sbSql.append("select '('||(select count(*) from tbl_sec_alert where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and nvl(admision, ");
sbSql.append(noAdmision);
sbSql.append(") = ");
sbSql.append(noAdmision);
sbSql.append(" and status = 'A' and alert_type = z.id)||') '||description as descripcion,z.id,(select join(cursor(select message from tbl_sec_alert where pac_id=");
sbSql.append(pacId);
sbSql.append(" and nvl(admision, ");
sbSql.append(noAdmision);
sbSql.append(") = ");
sbSql.append(noAdmision);
sbSql.append(" and status = 'A' and alert_type = z.id),';') from dual) as mensaje from tbl_sec_alert_type z where status = 'A' and exists (select null from tbl_sec_alert where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and nvl(admision, ");
sbSql.append(noAdmision);
sbSql.append(") = ");
sbSql.append(noAdmision);
sbSql.append(" and status = 'A' and alert_type = z.id) order by z.description");
al = SQLMgr.getDataList(sbSql.toString());
//if (al.size() > 0) {
%>
	<li class="dropdown">
	<a class="dropdown-toggle" data-toggle="dropdown" href="#"><i class="fa fa-bell fa-18 fa-white"></i>Alertas<span class="badge badge-notify" id="alert-bell"><%=c.getColValue("nRecs","")%></span><span class="caret"></span></a>
	<ul class="dropdown-menu" id="alert-detail">

	<%
for (int i = 0; i < al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
%>
	<li title="<%=cdo.getColValue("mensaje")%>"><a href="#"><i class="fa fa-user fa-18 fa-white"></i><%=cdo.getColValue("descripcion")%></a></li>

<% } %>
	</ul>
	</li>
<!-- Fin Menu Alertas -->

<!-- Inicio Menu Perfil Usuario -->
	<li class="dropdown">
	<a class="dropdown-toggle" data-toggle="dropdown" href="#"><i class="fa fa-user fa-18 fa-white"></i><%=(session.getAttribute("_userName") != null)?session.getAttribute("_userName"):""%><span class="caret"></span></a>
	<ul class="dropdown-menu">
	<li><a href="javascript:preferences();"><i class="fa fa-user fa-18 fa-white"></i>Preferencias</a></li>
	<!--<li><a href="#"><i class="fa fa-inbox fa-18 fa-white"></i>Mensajes</a></li>
	<li><a href="#"><i class="fa fa-gears fa-18 fa-white"></i>Ajustes</a></li>-->
	<li><a href="javascript:logout();"><i class="fa fa-sign-out fa-18 fa-white"></i>Cerrar Sesi&oacute;n</a></li>
	</ul>
	</li>
<!-- Fin Menu Perfil Usuario -->

<% } %>

</ul>
</div>
</div>


<!-- Barra y menu Descripcion Paciente -->
<div class="secondbar"><div>

<div class="panel panel-default-user">
<div class="panel-heading-user-nav">
	<h4 class="panel-title-user"><a data-toggle="collapse" href="#collapse1" class="user" title="Ver Informaci&oacute;n del Paciente"><i class="fa fa-street-view fa-18"></i>[<%=pCdo.getColValue("exp_id")%>-<%=noAdmision%>] <%=pCdo.getColValue("nombrePaciente")%> | <%=pCdo.getColValue("tipo_sangre")%> | <%=pCdo.getColValue("dob")%> | <%=pCdo.getColValue("sexo")%> | <%=pCdo.getColValue("edad")%> A&ntilde;os &nbsp; : : &nbsp; <%=pCdo.getColValue("cds")%> &nbsp; : : &nbsp; <%=pCdo.getColValue("categoria")%></a></h4>
</div>
<div id="collapse1" class="panel-user-inside collapse">
	<div id="accordion" role="tablist" aria-multiselectable="true">
		<div class="panel panel-default-user">
			<a data-toggle="collapse" class="test" data-parent="#accordion" href="#seccion1" aria-expanded="false" aria-controls="collapseExample">
			<div class="panel-heading-user" role="tab" id="headingOne">
			<h4 class="panel-title-user"><i class="fa fa-folder fa-18-user"></i><i class="fa fa-folder-open fa-18-user"></i>Detalle del Paciente</h4>
			</div>
			</a>
			<div id="seccion1" class="panel-collapse collapse form-group table-responsive" role="tabpanel" data-pattern="priority-columns">
			<jsp:include page="../common/paciente.jsp" flush="true">
			<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
			<jsp:param name="fp" value="expediente"></jsp:param>
			<jsp:param name="mode" value="view"></jsp:param>
			<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
			</jsp:include>
			</div>
		</div>
		<div class="panel panel-default-user">
			<a data-toggle="collapse" class="test" data-parent="#accordion" href="#seccion0" aria-expanded="false" aria-controls="collapseExample">
			<div class="panel-heading-user" role="tab" id="headingOne">
			<h4 class="panel-title-user"><i class="fa fa-folder fa-18-user"></i><i class="fa fa-folder-open fa-18-user"></i>Admisiones Anteriores</h4>
			</div>
			</a>
			<div id="seccion0" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne"><iframe id="iExpHistory" name="iExpHistory" width="100%" scrolling="yes" frameborder="0" src="../expediente/expediente_history.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&exp=3"></iframe></div>
		</div>
		<div class="panel panel-default-user">
			<a data-toggle="collapse" class="test" data-parent="#accordion" href="#seccion2" aria-expanded="false" aria-controls="collapseExample">
			<div class="panel-heading-user" role="tab" id="headingOne">
			<h4 class="panel-title-user"><i class="fa fa-folder fa-18-user"></i><i class="fa fa-folder-open fa-18-user"></i>Urgencia y Conyugue</h4>
			</div>
			</a>
			<div id="seccion2" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne"><iframe id="ifUrgencia" name="ifUrgencia" width="100%" height="250px" scrolling="yes" frameborder="0" src="../expediente/urgencia_y_conyugue.jsp?mode=<%=mode%>&pacId=<%=pacId%>&fp=<%=fp%>&exp=3"></iframe></div>
		</div>
		<div class="panel panel-default-user">
			<a data-toggle="collapse" class="test" data-parent="#accordion" href="#seccion3" aria-expanded="false" aria-controls="collapseExample">
			<div class="panel-heading-user" role="tab" id="headingOne">
			<h4 class="panel-title-user"><i class="fa fa-folder fa-18-user"></i><i class="fa fa-folder-open fa-18-user"></i>Custodio</h4>
			</div>
			</a>
			<div id="seccion3" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne"><iframe id="ifCustodio" name="ifCustodio" width="100%" height="250px" scrolling="yes" frameborder="0" src="../expediente/custodio.jsp?mode=<%=mode%>&pacId=<%=pacId%>&fp=<%=fp%>&exp=3"></iframe></div>
		</div>
		<div class="panel panel-default-user">
			<a data-toggle="collapse" class="test" data-parent="#accordion" href="#seccion4" aria-expanded="false" aria-controls="collapseExample">
			<div class="panel-heading-user" role="tab" id="headingOne">
			<h4 class="panel-title-user"><i class="fa fa-folder fa-18-user"></i><i class="fa fa-folder-open fa-18-user"></i>Educaci&oacute;n Paciente</h4>
			</div>
			</a>
			<div id="seccion4" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne"><iframe id="ifEducPac" name="ifEducPac" width="100%" height="250px" scrolling="yes" frameborder="0" src="../expediente3.0/exp_educacion_paciente.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&exp=3"></iframe></div>
		</div>
		<div class="panel panel-default-user">
			<a data-toggle="collapse" class="test" data-parent="#accordion" href="#seccion5" aria-expanded="false" aria-controls="collapseExample">
			<div class="panel-heading-user" role="tab" id="headingOne">
			<h4 class="panel-title-user"><i class="fa fa-folder fa-18-user"></i><i class="fa fa-folder-open fa-18-user"></i>Observ. Administrativas</h4>
			</div>
			</a>
			<div id="seccion5" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne"><iframe id="ifObservAdmin" name="ifObservAdmin" width="100%" height="250px" scrolling="yes" frameborder="0" src="../expediente/exp_obser_admin.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&fg=EXP&exp=3"></iframe></div>
		</div>
		<div class="panel panel-default-user">
			<a data-toggle="collapse" class="test" data-parent="#accordion" href="#seccion6" aria-expanded="false" aria-controls="collapseExample">
			<div class="panel-heading-user" role="tab" id="headingOne">
			<h4 class="panel-title-user"><i class="fa fa-folder fa-18-user"></i><i class="fa fa-folder-open fa-18-user"></i>Consentimiento</h4>
			</div>
			</a>
			<div id="seccion6" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne"><iframe id="ifConcentimiento" name="ifConcentimiento" width="100%"  height="250px" scrolling="yes" frameborder="0" src="../expediente3.0/sel_consentimiento.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&exp=3&consetimiento=1"></iframe></div>
		</div>
		<div class="panel panel-default-user">
			<a data-toggle="collapse" class="test" data-parent="#accordion" href="#seccion7" aria-expanded="false" aria-controls="collapseExample">
			<div class="panel-heading-user" role="tab" id="headingOne">
			<h4 class="panel-title-user"><i class="fa fa-folder fa-18-user"></i><i class="fa fa-folder-open fa-18-user"></i>Imagenes Escaneadas</h4>
			</div>
			</a>
			<div id="seccion7" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne"><iframe id="ifImagenEscan" name="ifImagenEscan" height="250px" width="100%" scrolling="yes" frameborder="0" src="../admision/frame_doc_admision.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&expStatus=<%=estado%>&exp=3"></iframe></div>
		</div>
	</div>
</div>
</div>

</div><br>
</div>
<!-- Fin Barra y menu Descripcion Paciente -->

</div>
<!-- Fin Barra de Navegacion -->
<!-- Inicio Menu Expedientes -->
<!--Test -->
<style type="text/css">
				.slideMenuExp {
						background-color: #f7f7f7 !important;
				}
		</style>
<div id="slideMenuExp">
		<div class="user">
				<p align="center">DOCUMENTOS</p></br>
		</div>


<%
sbSql = new StringBuffer();
sbSql.append("select x.doc_id, (select name from tbl_sal_exp_docs where id = x.doc_id) as documento, (select min(display_order) from tbl_sal_exp_docs_profile where doc_id = x.doc_id");
if (!UserDet.getUserProfile().contains("0") && !profiles.trim().equals("")) { sbSql.append(" and profile_id in ("); sbSql.append(profiles); sbSql.append(")"); }
sbSql.append(") as doc_order, x.display_order as sec_order, ");
sbSql.append(sbCol);
sbSql.append(" from ");
sbSql.append(sbTable);
sbSql.append(", tbl_sal_exp_docs_secc x");
sbSql.append(" where z.codigo = x.secc_code and z.status = 'A' /* and (z.grupo_exp is null or z.grupo_exp not in ('UC','OM'))*/");
sbSql.append(sbFilter);

if (!UserDet.getUserProfile().contains("0") && !profiles.trim().equals("")) {
	sbSql.append(" and x.doc_id in (");

	sbSql.append(" select doc_id from tbl_sal_exp_docs_profile where profile_id IN (");
	sbSql.append(profiles);
	sbSql.append(")");
	sbSql.append(")");
}

sbSql.append(" and exists (select null from tbl_sal_exp_docs where status = 'A' and id = x.doc_id) and exists (select null from tbl_sal_exp_docs_cds a where doc_id = x.doc_id and exists (select null from tbl_adm_atencion_cu where cds = a.cds_code and pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noAdmision);
sbSql.append("))");
sbSql.append(" order by 3,2,4,5");
al = SQLMgr.getDataList(sbSql.toString());
if (al.size() > 0) {
%>

<%
String groupBy = "";
for (int i = 0; i < al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	if (!groupBy.equalsIgnoreCase(cdo.getColValue("documento"))) {
		if (i != 0) {
%>
		</div>
		</div>

<% } %>
		<div class="list-group">
		<a href="#item-<%=cdo.getColValue("doc_id")%>" class="list-group-item" data-toggle="collapse">[<%=cdo.getColValue("doc_id")%>] <%=cdo.getColValue("documento")%><span class="caret"></span></a>
		<div class="list-group collapse" id="item-<%=cdo.getColValue("doc_id")%>">
<% } %>
			<a class="list-group-item" href="javascript:doRedirect('<%=cdo.getColValue("descripcion")%>',<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("actionMode")%>',<%=cdo.getColValue("editable")%>,'<%=cdo.getColValue("path")%>','<%=cdo.getColValue("doc_id")%>')"><span class="fa fa-<%=(cdo.getColValue("editable").equals("0"))?"eye":"edit"%> fa-18 fa-white" aria-hidden="true"></span><%=cdo.getColValue("seccion")%></a>
<%
	groupBy = cdo.getColValue("documento");
}
%>

	</div>
	</div>

<% } %>
</div>

<script type="text/javascript">
		$(document).ready(function () {
				$('#slideMenuExp').BootSideMenu({
						side: "left",
			pushBody:false,
			width:'30%'
				});
		});
</script>
<!-- Fin Menu Expedientes -->




<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("estadoAtencion",estado)%>
<%=fb.hidden("app_user_id", UserDet.getUserId())%>
<!-- INICIO contenido del sitio aqui-->
<div class="bodycontenido">
<!-- INICIO contenido del sitio aqui-->


<!-- INICIO Titulo del contenido para variable del icono leer infov3.txt-->
<!--<div class="page-title"><h4 style="margin-top: 0px;"><span id="ExpSectionTitle" aria-hidden="true"></span></h4></div>-->
<!-- FIN Titulo del Contenido-->

<div id="imageContainer" style="display:none"><img src="../images/signos_vitales_ayuda.png" alt="Valores Normales de Signos Vitales" title="Valores Normales de Signos Vitales"/></div>
<!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->
<!--INICIO de una fila de elementos-->
<div id="contentForm" class="container-fluid"><div id="a_tabbar" style="width:100%; height:600px;"></div>
<!--<iframe id="iExpSection" name="iExpSection" width="100%" scrolling="yes" frameborder="0" src=""></iframe>--></div>
<!-- FIN contenido del sitio aqui-->

</div>
<%=fb.formEnd(true)%>


<footer class="footer">
<div class="container-fluid">
<p class="text-muted pull-left"><i class="fa fa-registered fa-footer "></i> <i class="fa fa-copyright fa-footer "></i> TODOS LOS DERECHOS RESERVADOS 2016 | CELLBYTE.CO, Hospital Management System.</p>
</div>
</footer>
</body>
</html>