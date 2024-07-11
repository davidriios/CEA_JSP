<%@ page isErrorPage="true"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<%
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
%>
<html>
<head>
<title>INTERNAL ERROR</title>
<%@ include file="/common/nocache.jsp"%>
<%@ include file="/common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	if (window.opener || (parent.window.frames.length > 0 && parent.window.frames[0].name != 'MenuItems') || parent.window.frames['content'])
	{
		//document.getElementById('cWindow').style.display = '';
	}
	else
	{
		document.getElementById('cSession').style.display = '';
		document.getElementById('sFooter').style.display = '';
	}

	if (window.history.length > 1)
	{
		document.getElementById('mSession').style.display = '';
	}
	else
	{
		document.getElementById('mWindow').style.display = '';
	}
	if(!top.window.frames['content'])newHeight();
}

function closeSession()
{
	window.location = '<%=request.getContextPath()%>/logout.jsp';
}
</script>
</head>
<body topmargin="0" leftmargin="0" onLoad="javascript:doAction()">
<div id="cSession" style="display:none">
<%@ include file="/common/menu_base.jsp"%>
</div>
<jsp:include page="/common/title.jsp" flush="true">
	<jsp:param name="title" value="ERROR 500: ERROR INTERNO"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table width="99%" border="0" cellspacing="0" cellpadding="0" align="center">
	<tr>
		<td><table width="100%" border="0" align="center" class="TableBorder">
				<tr>
					<td class="TextHeader" valign="bottom">Mensaje</td>
				</tr>
				<tr height="150" align="center" class="TextRow01">
					<td><%=CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")%></br>
<%
if (exception != null)
{
	if (request.getRemoteAddr().equalsIgnoreCase("127.0.0.1"))
	{
%>
						<pre><%exception.printStackTrace(new java.io.PrintWriter(out));%></pre>
<%
	}
	else
	{
%>
						<%= exception.getMessage() %>
<%
	}
}
%>
						Hay un problema interno del servidor.<br>
						<label id="mSession" style="display:none">
						Por favor haga <a href="javascript:history.go(-1)" class="Link00">click aqu&iacute;</a> e intente nuevamente o consulte con su administrador.<br>
						</label>
						<label id="mWindow" style="display:none">
						Consulte con su administrador.<br>
						</label>
						Gracias.
					</td>
				</tr>
			</table></td>
	</tr>
</table>
<div id="sFooter" style="display:none">
<%@ include file="/common/footer.jsp"%>
</div>
</body>
</html>
