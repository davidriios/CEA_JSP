<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
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

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title='Editar Análisis Manual - '+document.title;
</script>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextRow02">
			<td>&nbsp;</td>
		</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
		<tr class="TextHeader">
			<td align="center"><cellbytelabel>Indique la raz&oacute;n para editar el an&aacute;lisis</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td align="center"><%=fb.textarea("comentario","",true,false,false,80,5,2000)%></td>
		</tr>
		<tr class="TextRow02">
			<td align="right">
				<%=fb.submit("save","Guardar",true,false,null,"","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {

	String baction = request.getParameter("baction");

	if (baction.equalsIgnoreCase("Guardar")) {
		session.setAttribute("__facAnalysisComment",request.getParameter("comentario"));
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){parent.window.location.reload(true);parent.hidePopWin(false);}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>
