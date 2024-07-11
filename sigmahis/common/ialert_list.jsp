<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
ArrayList al = new ArrayList();
String alertType = request.getParameter("alertType");
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");

if (alertType == null) alertType = "";

sbSql = new StringBuffer();
sbSql.append("select name from tbl_sec_alert_type where id=");
sbSql.append(alertType);
CommonDataObject cdo = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select a.message, nvl((select display_name from tbl_sec_alert_table where table_name=a.name),a.name) as groupby from tbl_sec_alert a where a.alert_type=");
sbSql.append(alertType);
sbSql.append(" and a.status='A' and a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and nvl(a.admision,");
sbSql.append(admision);
sbSql.append(")=");
sbSql.append(admision);
sbSql.append(" order by 2");
al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<title><cellbytelabel>Listado de Alertas</cellbytelabel></title>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){}
</script>
</head>
<body onLoad="javascript:doAction()">
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td class="TextHeader"><%=cdo.getColValue("name")%></td>
		</tr>
<%
String groupBy = "";
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!groupBy.equalsIgnoreCase(cdo.getColValue("groupby")))
	{
%>
		<tr class="TextHeader01">
			<td><%=cdo.getColValue("groupby")%></td>
		</tr>
<%
	}
%>
		<tr class="<%=color%>">
			<td><%=cdo.getColValue("message")%></td>
		</tr>
<%
	groupBy = cdo.getColValue("groupby");
}
%>
		</table>
	</td>
</tr>
</table>
</body>
</html>