<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
ArrayList al = new ArrayList();
//String alertType = request.getParameter("alertType");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

CommonDataObject cdo = new CommonDataObject();

//if (alertType == null) alertType = "";


if ( pacId == null ) throw new Exception ("El identificador del Paciente no es válido!");
if ( noAdmision == null ) throw new Exception ("El número de la admisión no es válida!");

sbSql = new StringBuffer();

sbSql.append("select a.message, nvl((select display_name from tbl_sec_alert_table where table_name=a.name),a.name) as groupby from tbl_sec_alert a where a.alert_type = 7 ");
sbSql.append(" and a.status = 'A' and nvl(a.admision,");
sbSql.append(noAdmision);
sbSql.append(")=");
sbSql.append(noAdmision);
sbSql.append(" and pac_id = ");
sbSql.append(pacId);
sbSql.append(" order by 2");
al = SQLMgr.getDataList(sbSql.toString());

%>
<html>
<head>
<title>Listado de Mensajes</title>
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
<%

String msg0 = "", msg1 = "", msg2 = "", msg3= "";


for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01"; 
	
	msg0 = cdo.getColValue("message").split(":")[0];
	msg1 = cdo.getColValue("message").split(":")[1];
	msg2 = msg1.split("<br/>")[0];
	msg3 = msg1.split("<br/>")[1];
	%>

<tr>
			<td class="TextHeader" colspan="2"><%=(i+1)%></td>
		</tr>
		<tr class="<%=color%>">
			<td width="20%"><cellbytelabel id="1">Medicamento</cellbytelabel>: </td><td width="80%"><%=msg0%></td>
		</tr>
		<tr class="<%=(color.equals("TextRow02")?"TextRow02":"TextRow01")%>">
		<td width="20%"><cellbytelabel id="2">Acciones</cellbytelabel>: </td><td width="80%"><%=msg2%></td>
		</tr>
		<tr class="<%=(color.equals("TextRow02")?"TextRow02":"TextRow01")%>">
		<td width="20%"><cellbytelabel id="3">Interacciones</cellbytelabel>: </td><td width="80%"><%=msg3%></td>
		</tr>
		
<%
}
%>
		</table>
	</td>
</tr>
</table>
</body>
</html>