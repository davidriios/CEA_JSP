<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<%
SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) {
	response.sendRedirect(request.getContextPath()+"/index.jsp");
	return;
}
%>
<html>
<head>
<%@ include file="/common/nocache.jsp"%>
<%@ include file="/common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="70%" cellpadding="5" cellspacing="1" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td class="TextInfo"><h1>Ya existe una SESION ACTIVA de otro usuario en este ordenador.<br>Por favor CIERRE TODAS LAS VENTANAS DEL SISTEMA, abra una nueva ventana e intente entrar nuevamente con su nombre de usuario y clave!!!</h1></td>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>