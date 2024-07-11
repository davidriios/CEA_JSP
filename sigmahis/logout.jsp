<%@ page errorPage="error.jsp"%>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<%
issi.admin.ISSILogger.setSession(session);
issi.admin.ConnectionMgr ConMgr=(issi.admin.ConnectionMgr) session.getAttribute("ConMgr");
if (ConMgr != null && ConMgr.getActiveConnectionStatus())
{
	SecMgr.setConnection(ConMgr);
	SecMgr.logout(session);
	ConMgr.close();
	try { session.removeAttribute("ConMgr"); } catch (Exception ex) { /* SESSION INVALIDATED */ }
}
String exit = request.getParameter("exit");


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="/common/header_param_min.jsp"%>
<script language="javascript">
function closeWin()
{
<%/*
if (exit == null)
{
%>

	var msg = 'Usted ha salido del Sistema!';
	try
	{
		window.location = '<%=request.getContextPath()%>/index.jsp?msg='+msg;
	}
	catch(err)
	{
		window.location = '<%=request.getContextPath()%>/index.jsp?msg='+msg;
	}
<%
}
else
{*/
%>
let getUrl = window.location;
let baseUrl = getUrl .protocol + "//" + getUrl.host + "/" + getUrl.pathname.split('/')[1];
location.replace(baseUrl);
<%
//}
%>
}
</script>
</head>
<body onLoad="javascript:closeWin()"<%// onUnload="javascript:closeChildWin();"%>>
</body>
</html>
