<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.UserDetail"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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

SQLMgr.setConnection(ConMgr);
java.util.ArrayList al = new java.util.ArrayList();
StringBuffer sbSql = new StringBuffer();
String id = request.getParameter("id");
if (id == null) throw new Exception("El Usuario no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET")) {

	sbSql.append("select user_name, name from tbl_sec_users where user_id = ").append(id);
	CommonDataObject uCdo = SQLMgr.getData(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Auditoría de Usuario - '+document.title;
var xHeight=0;
var tLoaded=[true,false,false,false,false,false,false,false,false,false,false];
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){
	resetFrameHeight(document.getElementById('_iDet0'),xHeight,200);
	resetFrameHeight(document.getElementById('_iDet1'),xHeight,200);
	resetFrameHeight(document.getElementById('_iDet2'),xHeight,200);
	resetFrameHeight(document.getElementById('_iDet3'),xHeight,200);
	resetFrameHeight(document.getElementById('_iDet4'),xHeight,200);
	resetFrameHeight(document.getElementById('_iDet5'),xHeight,200);
	resetFrameHeight(document.getElementById('_iDet6'),xHeight,200);
	resetFrameHeight(document.getElementById('_iDet7'),xHeight,200);
	resetFrameHeight(document.getElementById('_iDet8'),xHeight,200);
	resetFrameHeight(document.getElementById('_iDet9'),xHeight,200);
	resetFrameHeight(document.getElementById('_iDet10'),xHeight,200);
}
//load after clicking the tab, because when load at once, it doesnt resize correctly
function loadSrc(tab){console.log('load tab='+tab);
	if(tab==1){
		if(!tLoaded[tab])window.frames['_iDet'+tab].location='../admin/aud_user_profile.jsp?id=<%=id%>';
	}else if(tab==2){
		if(!tLoaded[tab])window.frames['_iDet'+tab].location='../admin/aud_user_cds.jsp?id=<%=id%>';
	}else if(tab==3){
		if(!tLoaded[tab])window.frames['_iDet'+tab].location='../admin/aud_user_ua.jsp?id=<%=id%>';
	}else if(tab==4){
		if(!tLoaded[tab])window.frames['_iDet'+tab].location='../admin/aud_user_wh.jsp?id=<%=id%>&whType=UA';
	}else if(tab==5){
		if(!tLoaded[tab])window.frames['_iDet'+tab].location='../admin/aud_user_wh.jsp?id=<%=id%>&whType=CDS';
	}else if(tab==6){
		if(!tLoaded[tab])window.frames['_iDet'+tab].location='../admin/aud_user_cia.jsp?id=<%=id%>';
	}else if(tab==7){
		if(!tLoaded[tab])window.frames['_iDet'+tab].location='../admin/aud_user_wh.jsp?id=<%=id%>&whType=INV';
	}else if(tab==8){
		if(!tLoaded[tab])window.frames['_iDet'+tab].location='../admin/aud_user_grupo_pla.jsp?id=<%=id%>';
	}else if(tab==9){
		if(!tLoaded[tab])window.frames['_iDet'+tab].location='../admin/aud_user_room.jsp?id=<%=id%>';
	}else if(tab==10){
		if(!tLoaded[tab])window.frames['_iDet'+tab].location='../admin/aud_user_idoneidad_pla.jsp?id=<%=id%>';
	}else{
		document.getElementById('_iDet'+tab).src='../admin/aud_user.jsp?id=<%=id%>';
	}
}
</script>
<style type="text/css">
<!--
.txt-size::before {font-size: 20px !important;}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - AUDITORIA DE USUARIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">
			<td width="15%" align="right"><label class="Text14Bold SpacingText"><cellbytelabel>USUARIO</cellbytelabel></label></td>
			<td width="25%"><label class="Text14Bold SpacingText LimeText"><%=uCdo.getColValue("user_name")%></label></td>
			<td width="15%" align="right"><label class="Text14Bold SpacingText"><cellbytelabel>NOMBRE</cellbytelabel></label></td>
			<td width="45%"><label class="Text14Bold SpacingText LimeText"><%=uCdo.getColValue("name")%></label></td>
		</tr>
		<tr>
			<td colspan="4">

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">



<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet0" id="_iDet0" frameborder="0" align="center" width="100%" height="0" scrolling="no" src="../admin/aud_user.jsp?id=<%=id%>"></iframe><!---->
<!-- TAB0 DIV END HERE-->
</div>



<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet1" id="_iDet1" frameborder="0" align="center" width="100%" height="0" scrolling="yes"></iframe><!-- src="../admin/aud_user_profile.jsp?id=<%=id%>"-->
<!-- TAB1 DIV END HERE-->
</div>



<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet2" id="_iDet2" frameborder="0" align="center" width="100%" height="0" scrolling="yes"></iframe><!-- src="../admin/aud_user_cds.jsp?id=<%=id%>"-->
<!-- TAB2 DIV END HERE-->
</div>



<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet3" id="_iDet3" frameborder="0" align="center" width="100%" height="0" scrolling="yes"></iframe><!-- src="../admin/aud_user_ua.jsp?id=<%=id%>"-->
<!-- TAB3 DIV END HERE-->
</div>



<!-- TAB4 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet4" id="_iDet4" frameborder="0" align="center" width="100%" height="0" scrolling="yes"></iframe><!-- src="../admin/aud_user_wh.jsp?id=<%=id%>&whType=UA"-->
<!-- TAB4 DIV END HERE-->
</div>



<!-- TAB5 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet5" id="_iDet5" frameborder="0" align="center" width="100%" height="0" scrolling="yes"></iframe><!-- src="../admin/aud_user_wh.jsp?id=<%=id%>&whType=CDS"-->
<!-- TAB5 DIV END HERE-->
</div>



<!-- TAB6 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet6" id="_iDet6" frameborder="0" align="center" width="100%" height="0" scrolling="yes"></iframe><!-- src="../admin/aud_user_cia.jsp?id=<%=id%>"-->
<!-- TAB6 DIV END HERE-->
</div>



<!-- TAB7 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet7" id="_iDet7" frameborder="0" align="center" width="100%" height="0" scrolling="yes"></iframe><!-- src="../admin/aud_user_wh.jsp?id=<%=id%>&whType=INV"-->
<!-- TAB7 DIV END HERE-->
</div>



<!-- TAB8 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet8" id="_iDet8" frameborder="0" align="center" width="100%" height="0" scrolling="yes"></iframe><!-- src="../admin/aud_user_grupo_pla.jsp?id=<%=id%>"-->
<!-- TAB8 DIV END HERE-->
</div>



<!-- TAB9 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet9" id="_iDet9" frameborder="0" align="center" width="100%" height="0" scrolling="yes"></iframe><!-- src="../admin/aud_user_room.jsp?id=<%=id%>"-->
<!-- TAB9 DIV END HERE-->
</div>



<!-- TAB10 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<iframe name="_iDet10" id="_iDet10" frameborder="0" align="center" width="100%" height="0" scrolling="yes"></iframe><!-- src="../admin/aud_user_idoneidad_pla.jsp?id=<%=id%>"-->
<!-- TAB10 DIV END HERE-->
</div>



<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
initTabs('dhtmlgoodies_tabView1',Array('Usuario','Perfiles','Centros de Servicios','Unidades Administrativas','Almacenes UA','Almacenes CDS','Compañías','Almacenes - Inventario','Grupo Trabajo Planilla','Quirofanos','Idoneidad'),0,'100%','',null,null,['1=loadSrc(1)','2=loadSrc(2)','3=loadSrc(3)','4=loadSrc(4)','5=loadSrc(5)','6=loadSrc(6)','7=loadSrc(7)','8=loadSrc(8)','9=loadSrc(9)','10=loadSrc(10)'],[]);
</script>

			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="Text10">
		<span class="span-circled span-circled-20 span-circled-green" data-content="+" style="--txt-size:20px"></span>REGISTRADO
		<span class="span-circled span-circled-20 span-circled-yellow" data-content="*" style="--txt-size:24px"></span>MODIFICADO
		<span class="span-circled span-circled-20 span-circled-red" data-content="-" style="--txt-size:24px"></span>ELIMINADO<!---->
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>