<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

String user = request.getParameter("user");
if (user == null) user = "";
if (user.trim().equals("")) throw new Exception("El Usuario no es válido. Por favor consulte con su Administrador!");

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Desconectar Usuario - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("user",user)%>
		<tr class="TextHeader" align="center">
			<td>Desconectar Usuario</td>
		</tr>
		<tr class="TextRow01">
			<td align="center">¿Est&aacute; seguro de remover/desconectar al usuario [<%=user%>]?</td>
		</tr>
		<tr class="TextHeader" align="center">
			<td align="center">
				<%=fb.submit("logout","Desconectar",true,false,"Text10",null,null)%>
				<%=fb.button("cancel","Cancelar",false,false,"Text10",null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
} else {
	javax.servlet.http.HttpSession userSession = SecMgr.getAppUsers(user);
	String sessionId = userSession.getId();
	SecMgr.logout(userSession,false,true);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
alert('El Usuario [<%=user%>] ha sido desconectado del Sistema satisfactoriamente!');parent.window.location.reload(true);}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>