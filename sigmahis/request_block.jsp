<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<%
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
%>
<html>
<head>
<title>ERROR</title>
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

	if (window.history.length >= 1)
	{
		document.getElementById('mSession').style.display = '';
	}
	else
	{
		document.getElementById('mWindow').style.display = '';
	}
}

function closeSession()
{
	window.location = '<%=request.getContextPath()%>/logout.jsp';
}

</script>
</head>
<body topmargin="0" leftmargin="0" onLoad="javascript:doAction()">
<div id="cSession" style="display:none">
<%
if (exception != null && !exception.getMessage().contains("fuera del sistema"))
{
%>
<%@ include file="/common/menu_base.jsp"%>
<%
}
%>
</div>
<jsp:include page="/common/title.jsp" flush="true">
	<jsp:param name="title" value="ERROR"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table width="99%" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr>
    <td><table width="100%" border="0" align="center" class="TableBorder">
				<tr>
					<td class="TextHeader" valign="bottom">Mensaje</td>
				</tr>
        <tr height="150" align="center" class="TextRow01">
          <td background="<%=request.getContextPath()%>/images/issi_big.gif" style="vertical-align:middle; background-position:right; background-repeat:no-repeat">
<%
String linkAction = "";
if(request.getParameter("url")!=null) linkAction = request.getParameter("url");
%>
						<pre>La p&aacute;gina que est&aacute; intentando actualizar fue modificada por otro usuario!</pre>
						<label id="mSession" style="display:none">
            Por favor haga <a href="javascript:document.location='<%=linkAction%>';" class="Link00">click aqu&iacute;</a> e intente nuevamente con datos actualizados.<br>
						</label>
						<label id="mWindow" style="display:none">
            <br>
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
