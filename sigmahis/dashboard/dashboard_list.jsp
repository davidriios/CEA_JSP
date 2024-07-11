<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
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

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Dashboards - '+document.title;
function showDashboard(opt){
	if(opt==1)abrir_ventana('../dashboard/uso_cama_dashboard.jsp');
	else if(opt==2)abrir_ventana('../dashboard/quirofano_dashboard.jsp');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DASHBOARD"></jsp:param>
</jsp:include>
<table align="center" width="70%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;<!--<a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo</cellbytelabel> ]</a>--></td>
</tr>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="70%"><cellbytelabel>Dashboard</cellbytelabel></td>
			<td width="30%">&nbsp;</td>
		</tr>
		<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
			<td>Uso de Cama</td>
			<td align="center"><a href="javascript:showDashboard(1)" class="Link02Bold"><cellbytelabel>Mostrar</cellbytelabel></a></td>
		</tr>
		<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
			<td>Uso de Quir&oacute;fanos</td>
			<td align="center"><a href="javascript:showDashboard(2)" class="Link02Bold"><cellbytelabel>Mostrar</cellbytelabel></a></td>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>