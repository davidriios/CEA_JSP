<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<%
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
%>
<html>
<head>
<title>PAGE UNDER CONSTRUCTION</title>
<%@ include file="/common/nocache.jsp"%>
<%@ include file="/common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	if (window.opener || (parent.window.frames.length > 0 && parent.window.frames[0].name != 'MenuItems'))
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
	newHeight();
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
	<jsp:param name="title" value="PAGINA EN CONSTRUCCION"></jsp:param>
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
						Esta p&aacute;gina est&aacute; en construci&oacute;n. Una vez este lista, usted podr&aacute; tener acceso a esta.<br>
						<label id="mSession" style="display:none">
						Por favor haga <a href="javascript:history.go(-1)" class="Link00">click aqu&iacute;</a> para regresar o consulte con su administrador.<br>
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
