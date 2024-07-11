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
String compania = request.getParameter("compania");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
if (actType == null) actType = "";
if (compania == null || compania.trim().equals("")) throw new Exception("Compañía no definida!");
if (fechaIni == null || fechaIni.trim().equals("") || fechaFin == null || fechaFin.trim().equals("")) throw new Exception("Rango de Fecha no definido!");

if (actType.equalsIgnoreCase("55")) actDesc = "GENERAR LIBRO DE INGRESO";
else if (actType.equalsIgnoreCase("56")) actDesc = "ANULAR LIBRO DE INGRESO";

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'MAYOR GENERAL - '+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CAMBIAR CLIENTE"></jsp:param>
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
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("fechaIni",fechaIni)%>
<%=fb.hidden("fechaFin",fechaFin)%>
		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel>¿Est&aacute; seguro de <%=actDesc%> desde <%=fechaIni%> hasta <%=fechaFin%>?</td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td colspan="2">
				<%=fb.submit("save","Guardar",true,false,null,"","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
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
	if (actType.equalsIgnoreCase("55")) sbSql.append("{ call sp_con_generar_libro_ingreso(?,?,?,?) }");
	else if (actType.equalsIgnoreCase("56")) sbSql.append("{ call sp_con_anular_libro_ingreso(?,?,?) }");

	param.setSql(sbSql.toString());
	param.addInStringStmtParam(1,compania);
	param.addInStringStmtParam(2,IBIZEscapeChars.forSingleQuots(fechaIni.trim()));
	param.addInStringStmtParam(3,IBIZEscapeChars.forSingleQuots(fechaFin.trim()));
	if (actType.equalsIgnoreCase("55")) param.addInStringStmtParam(4,IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));

	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"compania="+compania+"&fechaIni="+fechaIni+"&fechaFin="+fechaFin);
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