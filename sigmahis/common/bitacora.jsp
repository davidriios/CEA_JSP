<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
SQLMgr.setConnection(ConMgr);

ArrayList audAl = new ArrayList();
String audCollapsed = request.getParameter("audCollapsed");
String displayPlus = "";
String displayMinus = "";
String displayPanel = "";
String audTable = request.getParameter("audTable");
String audFilter = request.getParameter("audFilter");
StringBuffer sbSql = new StringBuffer();
String panelId = request.getParameter("panelId");
String panelTitleClass = request.getParameter("panelTitleClass");
String panelHeaderClass = request.getParameter("panelHeaderClass");
String panelDetailClass = request.getParameter("panelDetailClass");
String audCreatedUser = request.getParameter("audCreatedUser");
String schemaName = (session != null)?(String) session.getAttribute("_aud_schema_prefix"):null;
if (audCreatedUser == null) audCreatedUser = "";
if (schemaName == null) throw new Exception("El Esquema no es válido. Por favor intente nuevamente!");

if (audCollapsed == null) audCollapsed = "y";
if (audCollapsed.equalsIgnoreCase("y")) {

	displayPlus = "''";
	displayMinus = "none";
	displayPanel = "none";

} else {

	displayPlus = "none";
	displayMinus = "''";
	displayPanel = "''";

}
if (audTable == null || audTable.trim().equals("") || audTable.length() < 4) throw new Exception("La Tabla no es válida. Por favor intente nuevamente!");
else audTable = audTable.substring(4);
if (audFilter == null || audFilter.trim().equals("")) throw new Exception("El Filtro no es válido. Por favor intente nuevamente!");
if (panelId == null || panelId.trim().equals("")) panelId = "Audit";
if (panelTitleClass == null || panelTitleClass.trim().equals("")) panelTitleClass = "TextPanel";
if (panelHeaderClass == null || panelHeaderClass.trim().equals("")) panelHeaderClass = "TextHeader";
if (panelDetailClass == null || panelDetailClass.trim().equals("")) panelDetailClass = "TextRow01";
%>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td onClick="javascript:showHide('<%=panelId%>')" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="<%=panelTitleClass%>" height="25">
			<td width="95%">&nbsp;<cellbytelabel id="1">Bit&aacute;cora</cellbytelabel></td>
			<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus<%=panelId%>" style="display:<%=displayPlus%>">+</label><label id="minus<%=panelId%>" style="display:<%=displayMinus%>">-</label></font>]&nbsp;</td>
		</tr>
		</table>
	</td>
</tr>
<tr id="panel<%=panelId%>" style="display:<%=displayPanel%>">
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="<%=panelHeaderClass%>" align="center">
			<td width="20%">&nbsp;</td>
			<td width="25%"><cellbytelabel id="2">Fecha y Hora</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="3">Usuario</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="4">Direcci&oacute;n IP</cellbytelabel></td>
		</tr>
<%
sbSql.append("select ");
if (!audCreatedUser.trim().equals("")){
  sbSql.append(audCreatedUser);
  sbSql.append(" as aud_user, ");
}else{
  sbSql.append(" decode(aud_webuser_ip,null,substr(aud_dbuser_ip,1,instr(aud_dbuser_ip,':') - 1),substr(aud_webuser_ip,1,instr(aud_webuser_ip,':') - 1)) as aud_user, ");
}

sbSql.append(" decode(aud_webuser_ip,null,substr(aud_dbuser_ip,instr(aud_dbuser_ip,':') + 1),substr(aud_webuser_ip,instr(aud_webuser_ip,':') + 1)||decode(substr(aud_webuser_ip,instr(aud_webuser_ip,':') + 1),'127.0.0.1',' ('||substr(aud_dbuser_ip,instr(aud_dbuser_ip,':') + 1)||')')) as aud_ip, to_char(aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_datetime from ");
sbSql.append(schemaName);
sbSql.append(audTable);
sbSql.append(" where aud_action = 'INS' and ");
sbSql.append(audFilter);
if(!schemaName.trim().equals("-1"))audAl = SQLMgr.getDataList(sbSql.toString());
if (audAl.size() > 0) {

	CommonDataObject audCdo = (CommonDataObject) audAl.get(0);
%>
		<tr class="<%=panelDetailClass%>" align="center">
			<td align="right"><cellbytelabel id="5">Creaci&oacute;n</cellbytelabel></td>
			<td><%=audCdo.getColValue("aud_datetime")%></td>
			<td><%=audCdo.getColValue("aud_user")%></td>
			<td><%=audCdo.getColValue("aud_ip")%></td>
		</tr>
<% } else { %>
		<tr class="<%=panelDetailClass%>" align="center">
			<td align="right"><cellbytelabel id="5">Creaci&oacute;n</cellbytelabel></td>
			<td>---</td>
			<td>---</td>
			<td>---</td>
		</tr>
<%
}

sbSql = new StringBuffer();
sbSql.append("select * from (select decode(aud_webuser_ip,null,substr(aud_dbuser_ip,1,instr(aud_dbuser_ip,':') - 1),substr(aud_webuser_ip,1,instr(aud_webuser_ip,':') - 1)) as aud_user, decode(aud_webuser_ip,null,substr(aud_dbuser_ip,instr(aud_dbuser_ip,':') + 1),substr(aud_webuser_ip,instr(aud_webuser_ip,':') + 1)||decode(substr(aud_webuser_ip,instr(aud_webuser_ip,':') + 1),'127.0.0.1',' ('||substr(aud_dbuser_ip,instr(aud_dbuser_ip,':') + 1)||')')) as aud_ip, to_char(aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_datetime from ");
sbSql.append(schemaName);
sbSql.append(audTable);
sbSql.append(" where aud_action = 'UPD' and ");
sbSql.append(audFilter);
sbSql.append(" order by aud_timestamp desc) where rownum = 1");
if(!schemaName.trim().equals("-1"))audAl = SQLMgr.getDataList(sbSql.toString());
if (audAl.size() > 0) {

	CommonDataObject audCdo = (CommonDataObject) audAl.get(0);
%>
		<tr class="<%=panelDetailClass%>" align="center">
			<td align="right"><cellbytelabel>&Uacute;ltima Modificaci&oacute;n</cellbytelabel></td>
			<td><%=audCdo.getColValue("aud_datetime")%></td>
			<td><%=audCdo.getColValue("aud_user")%></td>
			<td><%=audCdo.getColValue("aud_ip")%></td>
		</tr>
<% } else { %>
		<tr class="<%=panelDetailClass%>" align="center">
			<td align="right"><cellbytelabel>&Uacute;ltima Modificaci&oacute;n</cellbytelabel></td>
			<td>---</td>
			<td>---</td>
			<td>---</td>
		</tr>
<% } %>
		</table>
	</td>
</tr>
</table>
