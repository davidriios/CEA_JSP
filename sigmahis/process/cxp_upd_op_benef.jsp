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
String anio = request.getParameter("anio");
String op = request.getParameter("op");

if (request.getMethod().equalsIgnoreCase("GET")) {

	sbSql.append("select nvl(beneficiario2,' ') as beneficiario2 from tbl_cxp_orden_de_pago where anio = ");
	sbSql.append(anio);
	sbSql.append(" and num_orden_pago = ");
	sbSql.append(op);
	sbSql.append(" and cod_compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'CXP - '+document.title;
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("op",op)%>
		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel>Nuevo Beneficiario</cellbytelabel></td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td colspan="2"><%=fb.textBox("beneficiario2",cdo.getColValue("beneficiario2"),true,false,false,100,100,"Text10",null,null)%></td>
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
	CommonDataObject cdo = new CommonDataObject();
	cdo.setTableName("tbl_cxp_orden_de_pago");
	cdo.setWhereClause("anio = "+anio+" and num_orden_pago = "+op+" and cod_compania = "+session.getAttribute("_companyId"));
	cdo.setAction("U");
	cdo.addColValue("beneficiario2",request.getParameter("beneficiario2"));

	if (baction.equalsIgnoreCase("Cambiar")) {

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		SQLMgr.save(cdo,new java.util.ArrayList(),true,true,true,true);
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