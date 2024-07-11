<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr"	scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr"	scope="session" class="issi.admin.SecurityMgr"	/>
<jsp:useBean id="UserDet"	scope="session" class="issi.admin.UserDetail"	/>
<jsp:useBean id="CmnMgr"	scope="page"	class="issi.admin.CommonMgr"	/>
<jsp:useBean id="SQLMgr"	scope="page"	class="issi.admin.SQLMgr"		/>
<jsp:useBean id="fb"		scope="page"	class="issi.admin.FormBean"		/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>  
<html>
<head>
<%@ include file="../common/nocache.jsp"		%>
<%@ include file="../common/header_param.jsp"	%>
<script language="javascript"></script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%fb = new FormBean("frmProcedureDetail",request.getContextPath()+request.getServletPath());%>
<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">		
<%=fb.formStart()%>		
<tr>
	<td>&nbsp;<cellbytelabel>Especialidad</cellbytelabel></td>
	<td>&nbsp;<cellbytelabel>Procedimiento</cellbytelabel></td>
	<td align="right">&nbsp;<%=fb.submit("btnadd", "Agregar", true, false, "", "", "")%></td>
</tr>
<tr>
	<td class="BlueContent">&nbsp;<%=fb.hidden("proc", "")%><%=fb.textBox("proc", "", false, true, false, 50)%>&nbsp;<%=fb.button("btnproc", "...", false, false, "", "", "")%></td>
	<td class="BlueContent">&nbsp;<%=fb.hidden("proc", "")%><%=fb.textBox("proc", "", false, true, false, 50)%>&nbsp;<%=fb.button("btnproc", "...", false, false, "", "", "")%></td>
	<td class="BlueContent" align="right">&nbsp;<%=fb.hidden("proc", "")%><%=fb.submit("btndel", "Eliminar", true, false, "", "", "")%></td>
</tr>	
<tr>
	<td class="BlueContent">&nbsp;<%=fb.hidden("proc", "")%><%=fb.textBox("proc", "", false, true, false, 50)%>&nbsp;<%=fb.button("btnproc", "...", false, false, "", "", "")%></td>
	<td class="BlueContent">&nbsp;<%=fb.hidden("proc", "")%><%=fb.textBox("proc", "", false, true, false, 50)%>&nbsp;<%=fb.button("btnproc", "...", false, false, "", "", "")%></td>
	<td class="BlueContent" align="right">&nbsp;<%=fb.hidden("proc", "")%><%=fb.submit("btndel", "Eliminar", true, false, "", "", "")%></td>
</tr>	
<tr>
	<td class="BlueContent">&nbsp;<%=fb.hidden("proc", "")%><%=fb.textBox("proc", "", false, true, false, 50)%>&nbsp;<%=fb.button("btnproc", "...", false, false, "", "", "")%></td>
	<td class="BlueContent">&nbsp;<%=fb.hidden("proc", "")%><%=fb.textBox("proc", "", false, true, false, 50)%>&nbsp;<%=fb.button("btnproc", "...", false, false, "", "", "")%></td>
	<td class="BlueContent" align="right">&nbsp;<%=fb.submit("btndel", "Eliminar", true, false, "", "", "")%></td>
</tr>	
<tr>
	<td width="50%" class="BlueContent">&nbsp;</td>
	<td width="40%" class="BlueContent">&nbsp;</td>
	<td width="10%" class="BlueContent">&nbsp;</td>
</tr>
<%=fb.formEnd()%>		
</table>	
</body>
</html>
<%
}
%>