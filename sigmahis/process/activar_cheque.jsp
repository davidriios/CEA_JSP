<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
String banco = request.getParameter("banco");
String cuenta = request.getParameter("cuenta");
String noCheque = request.getParameter("noCheque");


if (request.getMethod().equalsIgnoreCase("GET")) {
 
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'CXP - '+document.title;
function addProv(nombre)
{
   abrir_ventana1('../common/search_proveedor.jsp?fp=csop&nombre='+nombre);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="Cambiar Beneficiario"></jsp:param>
</jsp:include>
<table align="center" width="80%" cellpadding="5" cellspacing="1" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("banco",banco)%>
<%=fb.hidden("cuenta",cuenta)%>
<%=fb.hidden("noCheque",""+noCheque)%> 

		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel>CAMBIAR ESTADO DE CHEQUE A [ ACTIVO ]</cellbytelabel></td>
		</tr>
		 
		<tr class="TextHeader01" align="center">
			<td colspan="2"><%=fb.submit("save","Cambiar",true,false,null,"","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
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

	String baction = request.getParameter("baction");
	
	sbSql.append("call sp_cxp_activar_cheque(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", '");
	sbSql.append(banco);
	sbSql.append("', '");
	sbSql.append(cuenta);
	sbSql.append("', '");
	sbSql.append(noCheque);
	sbSql.append("', '"); 
	sbSql.append((String) session.getAttribute("_userName")); 
	sbSql.append("')"); 
	
	
	if (baction.equalsIgnoreCase("Cambiar")) {

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		SQLMgr.execute(sbSql.toString());
		ConMgr.clearAppCtx(null);

	}
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