<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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

SQLMgr.setConnection(ConMgr);

StringBuffer sbSql;
String docTypeDesc = "";
String docType = request.getParameter("docType");
String docKey1 = request.getParameter("docKey1");
String docKey2 = request.getParameter("docKey2");
String docKey3 = request.getParameter("docKey3");
String docKey4 = request.getParameter("docKey4");
String docKey5 = request.getParameter("docKey5");
boolean isValidKey = true;
boolean hideSubmit = false;

if (docType == null) throw new Exception("El Tipo de Documento no es válido. Por favor intente nuevamente!");
else if (docType.equalsIgnoreCase("REC"))
{
	docTypeDesc = "RECIBO";
	//codigo||compania||anio
	if (docKey1 == null || docKey2 == null || docKey3 == null) isValidKey = false;
	else
	{
		sbSql = new StringBuffer();
		sbSql.append("select rec_impreso from tbl_cja_transaccion_pago where codigo = ");
		sbSql.append(docKey1);
		sbSql.append(" and compania = ");
		sbSql.append(docKey2);
		sbSql.append(" and anio = ");
		sbSql.append(docKey3);
		CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
		if (cdo.getColValue("rec_impreso").equalsIgnoreCase("S")) hideSubmit = true;
	}
}
else docTypeDesc = docType;

if (!isValidKey) throw new Exception("El Documento no es válido. Por favor intente nuevamente!");

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
<%=fb.hidden("docType",docType)%>
<%=fb.hidden("docKey1",docKey1)%>
<%=fb.hidden("docKey2",docKey2)%>
<%=fb.hidden("docKey3",docKey3)%>
<%=fb.hidden("docKey4",docKey4)%>
<%=fb.hidden("docKey5",docKey5)%>
<%fb.appendJsValidation("if(!confirm('¿Está correcta la impresión de "+docTypeDesc+"?'))error++;");%>
<tr class="TextRow02">
	<td align="right" class="TableBorder">
		<%=(hideSubmit)?"":fb.submit("save","Impreso Correctamente",true,false,null,null,null)%>
		<%=fb.button("close","Cerrar",false,false,null,null,"onClick=\"javascript:parent.window.close();\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//get
else
{
	if (docType.equalsIgnoreCase("REC"))
	{
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_cja_transaccion_pago");
		cdo.setWhereClause("codigo = "+docKey1+" and compania = "+docKey2+" and anio = "+docKey3);
		cdo.addColValue("rec_impreso","S");
		SQLMgr.update(cdo);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.window.opener.location.reload(true);
	parent.window.close();
<% } else throw new Exception(SQLMgr.getErrException()); %>
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}//post
%>