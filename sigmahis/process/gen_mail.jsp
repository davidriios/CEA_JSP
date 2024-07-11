<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
String actDesc = "";
String actType = request.getParameter("actType");

if (actType == null) actType = "";
if (actType.equalsIgnoreCase("50")) actDesc = "GENERAR CORREO PLAN MEDICO - MOROSOS";
else if (actType.equalsIgnoreCase("51")) actDesc = "GENERAR CORREO PLAN MEDICO - RECORDATORIO";
else if (actType.equalsIgnoreCase("53")) actDesc = "GENERAR CORREO PLAN MEDICO - VACUNACION 3ERA EDAD";

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'PROCESO - '+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="<%=actDesc%>"></jsp:param>
</jsp:include>
<table align="center" width="80%" cellpadding="5" cellspacing="1" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("actType",actType)%>
		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel>¿Est&aacute; seguro de <%=actDesc%>?</td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td colspan="2">
				<%=fb.submit("save","Generar",true,false,null,"","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",false,false,null,"","onClick=\"javascript:parent.hidePopWin(false)\"")%>
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

	CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	String rParam = null;//parámetro que devuelve el procedimiento almacenado

	sbSql = new StringBuffer();
	if (actType.equalsIgnoreCase("50")) sbSql.append("{ call sp_pm_morosos_email() }");
	else if (actType.equalsIgnoreCase("51")) sbSql.append("{ call sp_pm_cobrorecuerdo_email() }");
	else if (actType.equalsIgnoreCase("53")) sbSql.append("{ call sp_pm_vacuna3eredad_email() }");

	param.setSql(sbSql.toString());

	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"actType="+actType);
	param = SQLMgr.executeCallable(param);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
alert('<%=SQLMgr.getErrMsg()%>');
<% } else throw new Exception(SQLMgr.getErrException()); %>
parent.window.location.reload(true);
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>