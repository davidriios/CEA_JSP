<%@ page errorPage="../error.jsp"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="javax.servlet.http.HttpSession"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.UserDetail"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.ConnectionMgr"%>
<%@ page import="issi.admin.SecurityMgr"%>
<jsp:useBean id="_appUsers" scope="application" class="java.util.Hashtable"/>
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

StringBuffer sbSql = new StringBuffer();
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss aa");
long currentTime = System.currentTimeMillis();
String id = request.getParameter("id");
String user = request.getParameter("user");
String u = request.getParameter("u");//update session silence mode
if (id == null) id = "";
if (user == null) user = "";
if (id.trim().equals("") || user.trim().equals("")) throw new Exception("El Usuario no es válido. Por favor consulte con su Administrador!");

if (request.getMethod().equalsIgnoreCase("GET")) {

	long creationTime = 0, lastAccessedTime = 0, maxInactiveTime = 0;
	HttpSession ses = (HttpSession) _appUsers.get(user);
	try { creationTime = ses.getCreationTime(); } catch (Exception ex) { creationTime = 0; }
	try { lastAccessedTime = ses.getLastAccessedTime(); } catch (Exception ex) { lastAccessedTime = 0; }
	try { maxInactiveTime = ses.getMaxInactiveInterval() * 1000; } catch (Exception ex) { maxInactiveTime = 0; }
	UserDetail ud = null;
	try { ud = (UserDetail) ses.getAttribute("UserDet"); } catch(Exception ex) { ud = new UserDetail(); }
	ConnectionMgr uConMgr = null;
	try { uConMgr = (ConnectionMgr) ses.getAttribute("ConMgr"); } catch(Exception ex) { }

	sbSql.append("select join(cursor(select sid from v$session where username = 'CELLBYTE' and client_identifier = '");
	sbSql.append(user);
	sbSql.append(":");
	sbSql.append(ud.getClientIP());
	sbSql.append("' order by sid),', ') as sids from dual");
	CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Detalles del Usuario - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td align="right"><img src="../images/reload.gif" height="20" width="20" onClick="javascript:window.location.reload(true);" style="cursor:pointer" alt="Refrescar pantalla!"></td>
</tr>
</table>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("user",user)%>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextRow01">
			<td width="15%">Usuario</td>
			<td width="35%"><%=user%></td>
			<td width="15%">Direcci&oacute;n IP</td>
			<td width="35%"><%=(ud.getClientIP() == null)?"":ud.getClientIP()%></td>
		</tr>
		<tr class="TextRow01">
			<td>Nombre</td>
			<td><%=(ud.getName() == null)?"":ud.getName()%></td>
			<td>Departamento</td>
			<td><%=(ud.getDepartmentName() == null)?"":ud.getDepartmentName()%></td>
		</tr>
		<tr class="TextRow01">
			<td>Fecha Acceso</td>
			<td><%=(maxInactiveTime == 1000)?"":sdf.format(new java.util.Date(creationTime))%></td>
			<td>Ultimo Acceso</td>
			<td><%=(maxInactiveTime == 1000)?"":sdf.format(new java.util.Date(lastAccessedTime))%></td>
		</tr>
		<tr class="TextRow01">
			<td>PID</td>
			<td><%=(cdo.getColValue("sids") == null)?"":cdo.getColValue("sids")%></td>
			<td>Transacci&oacute;n en Proceso</td>
			<td><%=(uConMgr.isTransactionStarted())?"SI":"NO"%></td>
		</tr>
		<tr class="TextRow01">
			<td>Ultima Conexi&oacute;n Desde</td>
			<td><%=(uConMgr.getLastAccessedPage() == null)?"":uConMgr.getLastAccessedPage()%></td>
			<td>Ultimo Error de Conexi&oacute;n</td>
			<td><%=(uConMgr.getLastError() == null)?"":uConMgr.getLastError()%></td>
		</tr>
		<tr>
			<td colspan="4" align="center">
				<%
				if(!ses.getId().equals(session.getId())){
				%>
				<authtype type='50'><%=fb.submit("disconnectUser","DESCONECTAR",true,false,"Text10","width:150","onClick=\"javascript:setBAction(this.form.name,this.value)\"")%></authtype>
				<% } %>
				<authtype type='51'><%=fb.submit("resetSession","ACTUALIZAR SESION",true,false,"Text10","width:150","onClick=\"javascript:setBAction(this.form.name,this.value)\"")%></authtype>
				<%=fb.button("cancel","CANCELAR",false,false,"Text10","width:150","onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {

	String baction = request.getParameter("baction");
	if (baction == null) baction = "";
	StringBuffer sbMsg = new StringBuffer();

	if (baction.equalsIgnoreCase("DESCONECTAR")) {

		HttpSession userSession = (HttpSession) _appUsers.get(user);
		String sessionId = userSession.getId();
		SecMgr.logout(userSession,false,true);
		sbMsg.append("El Usuario [");
		sbMsg.append(user);
		sbMsg.append("] ha sido desconectado del Sistema satisfactoriamente!");
		_appUsers.remove(user);
		

	} else if (baction.equalsIgnoreCase("ACTUALIZAR SESION") || u != null) {

		HttpSession userSession = (HttpSession) _appUsers.get(user);
		SecurityMgr userSecMgr = null;
		try {
			userSecMgr = (SecurityMgr) userSession.getAttribute("SecMgr");
			if (session.getAttribute("_userName").equals(userSession.getAttribute("_userName"))) userSession.setAttribute("__ResetBy__",session.getAttribute("_userName")+" (SELF)");
			else userSession.setAttribute("__ResetBy__",session.getAttribute("_userName"));
			userSecMgr.resetUserSession(userSession,id);
			userSession.setAttribute("SecMgr",userSecMgr);
		} catch (Exception e) {
			throw new Exception("Ocurrió un error al intentar actualizar la sesión del usuario!");
		} finally {
			userSession = null;
			userSecMgr = null;
		}
		sbMsg.append("La Sesión del Usuario [");
		sbMsg.append(user);
		sbMsg.append("] ha sido actualizada satisfactoriamente!");

	}
%>
<% if (u == null) { %>
<html>
<head>
<script language="javascript">
function closeWindow(){alert('<%=sbMsg%>');parent.window.location.reload(true);}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>
<% } %>