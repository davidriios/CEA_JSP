<%@ page errorPage="../error.jsp"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);

String msg = request.getParameter("msg");
if (msg == null) msg = "";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Name Page "+document.title;

function doAction()
{
<%
//if (!msg.equals(""))
//{
%>
//	alert('<%=msg%>');
<%
//}
%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100%" align="center" background="../images/bgTitle.jpg" height="25"><font class="TextModuleName">MODULE NAME</font></td>
	</tr>	
	<tr>
		<td>&nbsp;</td>
	</tr>	
</table>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100%">
			<table align="center" width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td align="left" width="20%">&nbsp;</td>
					<td align="left" width="18%">&nbsp;</td>
					<td align="left" width="42%">&nbsp;</td>
					<td align="left" width="20%">&nbsp;</td>
				</tr>
				<tr><td colspan="4">&nbsp;</td></tr>		
				<tr><td colspan="4">&nbsp;</td></tr>		
				<tr><td colspan="4">&nbsp;</td></tr>		
			</table>		
		</td>
	</tr>		
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
