<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
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
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();
ArrayList al2 = new ArrayList();

String sql = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String docId = "";
String fp = request.getParameter("fp");
String cds = request.getParameter("cds");
String estado = request.getParameter("estado");
String catId = request.getParameter("catId");
String tab = request.getParameter("tab");
if (tab == null) tab = "0";
String consetimiento="";
try {consetimiento =java.util.ResourceBundle.getBundle("issi").getString("consetimiento");}catch(Exception e){ consetimiento = "1";}

//usadas para el proceso de Expediente > Consultas > Secciones Guardadas
String section = request.getParameter("section");
String sectionDesc = request.getParameter("sectionDesc");
String path = request.getParameter("path");

if (!UserDet.getUserProfile().contains("0") && CmnMgr.getCount("select count(*) from tbl_sec_profiles a, tbl_sec_module b where a.profile_id in ("+CmnMgr.vector2numSqlInClause(UserDet.getUserProfile())+") and a.module_id=b.id and a.module_id=11")==0) throw new Exception("Usted no tiene el Perfil para accesar al Expediente. Por favor consulte con su administrador!");

if (mode == null) mode = "add";
if (fp == null) fp = "";
if (cds == null) cds = "";
if (estado == null) estado = "";

if (fp.equalsIgnoreCase("paciente"))
{
	if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
	if (noAdmision == null) noAdmision = "0";
}
else if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (CmnMgr.getCount("select count(*) from tbl_adm_atencion_cu where pac_id="+pacId+((noAdmision != null && !noAdmision.trim().equals("") && !noAdmision.trim().equals("0"))?" and secuencia="+noAdmision:""))==0) throw new Exception("El Paciente no tiene registro de atención. Por favor consulte con su Administrador!");

String profiles = CmnMgr.vector2numSqlInClause(UserDet.getUserProfile());

sql = "select a.id as OptValueColumn, '['||lpad(a.id,2,'0')||'] '||a.name as OptLabelColumn, (select min(display_order) from tbl_sal_exp_docs_profile where doc_id=a.id"+((!UserDet.getUserProfile().contains("0") && !profiles.trim().equals(""))?" and profile_id in ("+profiles+")":"")+") as OptTitleColumn from tbl_sal_exp_docs a where a.id in (select doc_id from tbl_sal_exp_docs_cds where cds_code in (select cds from tbl_adm_atencion_cu where pac_id="+pacId+((noAdmision != null && !noAdmision.trim().equals("") && !noAdmision.trim().equals("0"))?" and secuencia="+noAdmision:"")+")) and a.status='A' order by 3, a.name";
System.out.println("SQL DOC: "+sql);
al = sbb.getBeanList(ConMgr.getConnection(),sql,CommonDataObject.class);

if (al.size() == 0) throw new Exception("Los Documentos del Expediente no están definidos. Por favor consulte con su Administrador!");
docId = ((CommonDataObject) al.get(0)).getOptValueColumn();

  sql = "SELECT codigo, descripcion FROM tbl_sal_expediente_secciones ";
  al2 = SQLMgr.getDataList(sql);
  for (int i=0; i<al2.size(); i++)
  {
		cdo = (CommonDataObject) al2.get(i);
    	//cdo.setKey(i);
     try
    {
      iExpSecciones.put(cdo.getColValue("codigo"),cdo);
    }
    catch(Exception e)
    {
      System.err.println(e.getMessage());
    }
  }
  
String doSimpleBlinking = "1"; // "0" para usar el blinking tradicional  
String reloadAlertBarTimer = "1"; //1 minute, will be converted to milliseconds
try{reloadAlertBarTimer = java.util.ResourceBundle.getBundle("issi").getString("exp.reloadAlertBarTimer");}catch(Exception e){reloadAlertBarTimer = "1";}
try{doSimpleBlinking = java.util.ResourceBundle.getBundle("issi").getString("exp.doSimpleBlinking");}catch(Exception e){doSimpleBlinking = "1";}

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>

<link rel="stylesheet" type="text/css" href="../css/dhtmlxtabbar.css">
<script  src="../js/dhtmlxcommon.js"></script>
<script  src="../js/dhtmlxtabbar.js"></script>

<style>
.fmc-box{width:24px; height:24px;}
.check{background:url('../images/checkbox-checked.png') no-repeat; background-size: 24px 24px;}
.uncheck{background:url('../images/checkbox-unchecked.png') no-repeat; background-size: 24px 24px;}
</style>

<script>

var tabbar;
var tabArray = new Array();


document.title="Expediente - "+document.title;

function doRedirect(secDesc,seccion,mode,editable,path){   
    pacId=<%=pacId%>;
	noAdmision=<%=noAdmision%>;
	cds='<%=cds%>';
	docId = ((typeof document.form1.docId)!="undefined"?document.form1.docId.value:"<%=docId%>");
	var xtraQS = "desc="+secDesc+"&pacId="+pacId+"&seccion="+seccion+"&noAdmision="+noAdmision+"&mode="+mode+"&cds="+cds+"&defaultAction="+editable+"&docId="+docId;
	if (seccion != null && seccion!="" && path!=null && path != ""){
		toPage = path+xtraQS;
		//I don't realy like the blank tab
		try{
		   navBar(toPage,secDesc);
		   $("#curSection").val(seccion);
		   
			var c = getDBData('<%=request.getContextPath()%>','count(id)','tbl_far_check_logs'," trunc(fecha_creacion) = trunc(sysdate) and seccion = "+seccion+" and exists (select null from tbl_sal_expediente_secciones where validar_farmacia = 'S'  and codigo = "+seccion+") ",'');
			
			if (parseInt(c,10)) {
			  $(".fmc-box").removeClass("uncheck").addClass("check").show(0)
			}else {
			  $(".fmc-box").removeClass("check").addClass("uncheck").hide(0)
			}
		
		
		}catch(e){debug("ERROR doRedirect :: "+e.message);}
    }
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
tabbar = new dhtmlXTabBar("a_tabbar", "top"); tabbar.setSkin('modern');
tabbar.setImagePath("../js/imgs/"); tabbar.setHrefMode("iframes");
tabbar.enableTabCloseButton(true);
tabbar.enableAutoReSize();
tabbar.enableScroll(true);
}else{
tabExist=validateTab(toPage);
//alert(tabExist);

if(tabExist>=0){
if(tabbar.cells("nav"+tabExist)==null || tabbar.cells("nav"+tabExist)==undefined){ tabArray[tabExist]="Closed"; navBar(toPage,secDesc);}else tabbar.setTabActive("nav"+tabExist);
}else{
tabbar.addTab("nav"+(tabArray.length), secDesc, tabWidth+"px");
tabbar.setContentHref("nav"+(tabArray.length), toPage+'&_viewMode=<%=mode%>');
tabbar.setTabActive("nav"+(tabArray.length));
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
<%if(doSimpleBlinking.trim().equals("1")){%>reloadAlerts()<%}%>
<%if(fp.trim().equals("secciones_guardadas")){%>document.getElementById("iSecciones").contentWindow.setOnTheFly();<%}%>
}

function refreshSecciones(docId)
{
	setFrameSrc('iSecciones','../expediente/expediente_secciones.jsp?mode=<%=mode%>&docId='+docId+'&estado=<%=estado%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>');
}

function refreshAdmision(noAdmision)
{
	//setFrameSrc('iExpHistory','../expediente/expediente_history.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision='+noAdmision);
	if(noAdmision.trim()!='')
<%
if (fp.equalsIgnoreCase("paciente"))
{
%>
	window.location='../expediente/expediente_config.jsp?mode=view&pacId=<%=pacId%>&noAdmision='+noAdmision+'&fp=paciente';
<%
}
else
{
%>
	//abrir_ventana1('../expediente/expediente_config.jsp?mode=view&pacId=<%=pacId%>&noAdmision='+noAdmision+'&fp=history');
	openWin('../expediente/expediente_config.jsp?mode=view&pacId=<%=pacId%>&noAdmision='+noAdmision+'&fp=history','expediente_config_history',getPopUpOptions(true,true,true,true));
<%
}
%>
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
		tabbar.tabWindow(tabbar.getActiveTab()).document.forms[formName].dob.value=document.paciente.fechaNacimiento.value;
		tabbar.tabWindow(tabbar.getActiveTab()).document.forms[formName].codPac.value = document.paciente.codigoPaciente.value;
		//window.frames[iframeName].document.forms[formName].dob.value=document.paciente.fechaNacimiento.value;
		//window.frames[iframeName].document.forms[formName].codPac.value=document.paciente.codigoPaciente.value;
	}
}

function ctrlTriage(){
    var catId = <%=catId%>;
	if (catId == '3' ){
	    return true;
	}
	else
	alert("El triage solo es válido cuando la admisión es ambulatoria!");
	return false;
}

function searchSec(){
	var seccion = document.form1.txt_seccion.value;

	//Después de una búsqueda, el docId siempre es 24 (
	//el primer elemento del select), eso causa que las
	//búsquedas siguientes filtren por 24por
	//por ende es preferible cargar esta variable del DOM.

	var docId = ((typeof document.form1.docId)!="undefined"?document.form1.docId.value:24);
	window.frames['iSecciones'].location = '../expediente/expediente_secciones.jsp?mode=<%=mode%>&docId='+docId+'&estado=<%=estado%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&sec='+seccion;

	//alert("theBra!n............."+docId);
}

function getUrgenciaValues(){
window.frames['ifUrgencia'].location = '../expediente/urgencia_y_conyugue.jsp?mode=<%=mode%>&pacId=<%=pacId%>&fp=<%=fp%>';
}
function getEducPacValues(){
window.frames['ifEducPac'].location = '../expediente/exp_educacion_paciente.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>';
}
function getObservAdmin(){
window.frames['ifObservAdmin'].location = '../expediente/exp_obser_admin.jsp?mode=view&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&fg=EXP';
}
function getConsentimiento(){
<%if(consetimiento.trim().equals("0")){%>window.frames['ifConcentimiento'].location = '../common/sel_consentimiento_hpp.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>';<%}else{%>window.frames['ifConcentimiento'].location = '../common/sel_consentimiento.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>';<%}%>
 
}
function getImagenEscan(){
window.frames['ifImagenEscan'].location = '../admision/frame_doc_admision.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&expStatus=<%=estado%>';
}

// the no overriding of closeWin()
// Si tiene paginas pestañas / formularios abiertos
// Le recordamos al user antes de cerrar la ventana

var warning = true;

function overrideCloseWin(){
    if ( tabbar != undefined && tabbar.getActiveTab() != null ){
	 var estado = getDBData('<%=request.getContextPath()%>','estado','tbl_adm_atencion_cu','pac_id=<%=pacId%> and secuencia=<%=noAdmision%>','');
		if(estado != 'F')
		{
           if (confirm("Tiene Formularios abiertos y no queremos que pierda sus cambios!,\nQuiere usted continuar con esa acción?")){
			 warning = false;
		     closeWin();
		 	}else{return false;}
		}else return closeWin();
    }else{
	  return closeWin();
	}
}

window.onbeforeunload = function() {
  if (warning && tabbar != undefined && tabbar.getActiveTab() != null ) {
  <%if(SecMgr.checkLogin(session.getId())){%>
  	var estado = getDBData('<%=request.getContextPath()%>','estado','tbl_adm_atencion_cu','pac_id=<%=pacId%> and secuencia=<%=noAdmision%>','');
		if(estado != 'F' )
		{
    		return "Tiene Formularios abiertos y no queremos que pierda sus cambios!,\nQuiere usted continuar con esa acción?";
		}
	<%}%>
  }
}

function reloadAlerts(){
  var _timer = parseInt("<%=reloadAlertBarTimer%>",10) * 60 * 1000;
  $.ajax({
	 url: '../common/ialert.jsp?fp=expediente&pacId=<%=pacId%>&displayArea=expediente&facturadoA=&admision=<%=noAdmision%>&doSimpleBlinking=<%=doSimpleBlinking%>',
	 cache: false,
	 dataType: "html"
  }).done(function(data){
		$("#alerContainer").html("");
		$("#alerContainer").html(data);
  }).fail(function(jqXHR, textStatus){
	debug("La request has fallido: " + textStatus);
  });
  setTimeout('reloadAlerts()',_timer);
}

$(document).ready(function(){
   $("#alerContainer").dblclick(function(){reloadAlerts();});

	$(document).on("dblclick",".dhx_tab_element_active",function(c){
		if ( tabbar ){
		  tabbar.tabWindow(tabbar.getActiveTab()).location.reload();
		}
	 });
});


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

function showValidationHistory(){
	var section = $("#curSection").val();
	debug(section);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center"  width="100%" cellpadding="5" cellspacing="0">

		<tr>
			<td class="TableBorder">

				<table width="100%" cellpadding="1" cellspacing="0">


<%
if (!fp.equalsIgnoreCase("history"))
{
%>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
				<tr>
					<td colspan="2" align="center" onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%" align="center">&nbsp;<cellbytelabel id="1">A D M I S I O N E S</cellbytelabel> &nbsp; <cellbytelabel id="2">A N T E R I O R E S</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0" class="TextHeader">
					<td colspan="2"><iframe id="iExpHistory" name="iExpHistory" width="100%" height="65" scrolling="yes" frameborder="0" src="../expediente/expediente_history.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>"></iframe></td>
				</tr>
<%=fb.formEnd(true)%>
<%
}
%>

<jsp:include page="../common/paciente.jsp" flush="true">
	<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
	<jsp:param name="fp" value="expediente"></jsp:param>
	<jsp:param name="mode" value="view"></jsp:param>
	<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
</jsp:include>
<!-- .................BEGIN.................. -->
<tr class="<%=doSimpleBlinking.trim().equals("0")?"TextRowWhite":""%>">
	<td colspan="2" width="100%">
	    <table width="100%">
		<tr>
		<td width="97%" id="alerContainer">
		<jsp:include page="../common/ialert.jsp" flush="true">
			<jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
			<jsp:param name="fp" value="expediente"></jsp:param>
			<jsp:param name="displayArea" value="expediente"></jsp:param>
			<jsp:param name="admision" value="<%=noAdmision%>"></jsp:param>
			<jsp:param name="doSimpleBlinking" value="<%=doSimpleBlinking%>"></jsp:param>
		</jsp:include>
		</td>
		<td style="cursor:pointer;" width="3%" align="center" id="farm-check">
			<div style="display:none" class="fmc-box" onClick="javascript:showValidationHistory()"><div/>
		</td>
		</tr>
		</table>
	</td>
</tr>
<!-- .................END.................. -->
</td></tr></table>
<tr><td>


<div id="imageContainer" style="display:none">
<img src="../images/signos_vitales_ayuda.png" alt="Valores Normales de Signos Vitales" title="Valores Normales de Signos Vitales" />
</div>
<div id="dhtmlgoodies_tabView1">
			<!--GENERALES TAB0-->
			<div class="dhtmlgoodies_aTab">

<table width="100%" cellpadding="1" cellspacing="0">

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("estadoAtencion",estado)%>
<%=fb.hidden("section",section)%>
<%=fb.hidden("sectionDesc",sectionDesc)%>
<%=fb.hidden("path",path)%>
<%=fb.hidden("curSection","")%>
				<tr >
					<td width="29%" class="TableBorder TextRow01" valign="top">
						<table width="100%" cellpadding="1" cellspacing="0" align="center">
						<tr colspan="2" align="center" class="TextHeader" align="center">
							<td colspan="2"><cellbytelabel id="3">E X P E D I E N T E S</cellbytelabel></td>
						</tr>
						<tr class="TextRow01" align="center">
							<td colspan="2"><%=(noAdmision.equals("0"))?"":fb.select("docId",al,docId,false,(fp.equals("history")),0,"Text10","width:100%","onChange=\"javascript:refreshSecciones(this.value)\"")%></td>
						</tr>
						<tr class="TextRowYell">
							<td><cellbytelabel id="4">S E C C I O N E S</cellbytelabel></td>
							<td align="right"><%=fb.textBox("txt_seccion","",false,false,false,25,"Text10","","")%>
							<%=fb.button("btnIr","Ir",true,false,"Text10",null,"onClick=\"javascript:searchSec()\"")%></td>
						</tr>
						</table>
						<table width="100%" cellpadding="1" cellspacing="0" align="center">
						<tr>
							<td valign="top">
<%
if (!noAdmision.equals("0"))
{
%>
							<iframe id="iSecciones" name="iSecciones" width="100%" height="330" scrolling="yes" frameborder="0" src="../expediente/expediente_secciones.jsp?mode=<%=mode%>&docId=<%=docId%>&estado=<%=estado%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&section=<%=section%>&sectionDesc=<%=sectionDesc%>&path=<%=path%>&fp=<%=fp%>"></iframe>
<%
}
%>
							</td>
						</tr>
						</table>
					</td>
					<td width="71%" class="TableBorder" valign="top" id="container">
					<div id="a_tabbar" style="width:100%; height:390px;"></div>
	<!--<iframe id="iDetalle" name="iDetalle" width="100%" height="360" scrolling="no" frameborder="0" src="../expediente/expediente_redirect.jsp"></iframe>-->
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2" align="right">
					<%//=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:closeWin()\"")%>
					<%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:overrideCloseWin()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

				</table>
			</div>
			<%--URGENCIA Y CONYUGUE--%>
			<div class="dhtmlgoodies_aTab">
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextRow02">
					<td colspan="2"><cellbytelabel id="5">URGENCIA Y CONYUGUE</cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">
					<iframe id="ifUrgencia" name="ifUrgencia" width="100%" height="330" scrolling="yes" frameborder="0" src="../expediente/urgencia_y_conyugue.jsp?mode=<%=mode%>&pacId=<%=pacId%>&fp=<%=fp%>"></iframe>
				</td>
				</tr>
				</table>
			</div>
			<%--CUSTODIO--%>
			<div class="dhtmlgoodies_aTab">
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextRow02">
					<td colspan="2"><cellbytelabel id="6">Custodio</cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">
					<iframe id="ifCustodio" name="ifCustodio" width="100%" height="330" scrolling="yes" frameborder="0" src="../expediente/custodio.jsp?mode=<%=mode%>&pacId=<%=pacId%>&fp=<%=fp%>"></iframe>
				</td>
				</tr>
				</table>
			</div>
			<div class="dhtmlgoodies_aTab">
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextRow02">
					<td colspan="2"><cellbytelabel id="7">Educaci&oacute;n Paciente (Carenotes)</cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">
					<iframe id="ifEducPac" name="ifEducPac" width="100%" height="330" scrolling="yes" frameborder="0" src="../expediente/exp_educacion_paciente.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>"></iframe>
				</td>
				</tr>
				</table>
			</div>
			<div class="dhtmlgoodies_aTab">
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextRow02">
					<td colspan="2"><cellbytelabel id="8">Observaciones Administrativas</cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">
					<iframe id="ifObservAdmin" name="ifObservAdmin" width="100%" height="330" scrolling="yes" frameborder="0" src="../expediente/exp_obser_admin.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&fg=EXP"></iframe>
				</td>
				</tr>
				</table>
			</div>
			<div class="dhtmlgoodies_aTab">
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextRow02">
					<td colspan="2"><cellbytelabel id="9">Consentimiento</cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">
					<iframe id="ifConcentimiento" name="ifConcentimiento" width="100%" height="330px" scrolling="yes" frameborder="0" src="../common/sel_consentimiento<%=(consetimiento.trim().equals("0"))? "_hpp":""%>.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>"></iframe>
				</td>
				</tr>
				</table>
			</div>
			<div class="dhtmlgoodies_aTab">
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextRow02">
					<td colspan="2"><cellbytelabel id="10">Asociar Imagenes Escaneadas</cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">
					<iframe id="ifImagenEscan" name="ifImagenEscan" width="100%" height="330" scrolling="yes" frameborder="0" src="../admision/frame_doc_admision.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&expStatus=<%=estado%>"></iframe>
				</td>
				</tr>
				</table>
			</div>
			</div>
<script type="text/javascript">
<%
String tabLabel = "'Expediente', 'Urgencia y Conyugue','Custodio','Educacion Paciente','Observ. Administrativas','Consentimiento','Asociar Imagenes Escaneadas'";
String tabFunctions = "'1=getUrgenciaValues()', '2=null','3=getEducPacValues()','4=getObservAdmin()','5=getConsentimiento()','6=getImagenEscan()'";
String tabInactivo = "";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,Array(<%=tabFunctions%>),[<%=tabInactivo%>]);
//initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,Array(<%=tabFunctions%>));
</script>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
%>