<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
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
String tipoCliente = request.getParameter("tipoCliente");
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body>
<table width="100%" height="100%" cellpadding="5" cellspacing="0" align="center">
<%fb = new FormBean("formPrinted",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<tr class="TextRow02">
	<td align="right" class="TableBorder">
		<%=fb.button("print_fact","Registrar Pago",false,false,null,null,"onClick=\"javascript:parent.printFact('"+tipoCliente+"');\"")%>
		<%=fb.button("close","Cerrar",false,false,null,null,"onClick=\"javascript:parent.window.close();\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//get
%>