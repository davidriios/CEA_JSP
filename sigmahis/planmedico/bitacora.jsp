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
String aud_value_filter = request.getParameter("aud_value_filter");
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

<tr id="panel<%=panelId%>">
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%">&nbsp;</td>
			<td width="15%"><cellbytelabel id="2">Fecha y Hora</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="3">Usuario</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="4">Direcci&oacute;n IP</cellbytelabel></td>
			<%if(audTable.equalsIgnoreCase("PM_SOLICITUD_CONTRATO")){%>
			<td width="10%"><cellbytelabel id="5">Estado</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="6">Cuota</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="7">Fecha Inicio Plan</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="8">En transici&oacute;n</cellbytelabel></td>
			<%}%>
		</tr>
<%
sbSql.append("select ");
if (!audCreatedUser.trim().equals("")){
  sbSql.append(audCreatedUser);
  sbSql.append(" as aud_user, ");
}else{
  sbSql.append(" decode(aud_webuser_ip,null,substr(aud_dbuser_ip,1,instr(aud_dbuser_ip,':') - 1),substr(aud_webuser_ip,1,instr(aud_webuser_ip,':') - 1)) as aud_user, ");
}

sbSql.append(" decode(aud_webuser_ip,null,substr(aud_dbuser_ip,instr(aud_dbuser_ip,':') + 1),substr(aud_webuser_ip,instr(aud_webuser_ip,':') + 1)||decode(substr(aud_webuser_ip,instr(aud_webuser_ip,':') + 1),'127.0.0.1',' ('||substr(aud_dbuser_ip,instr(aud_dbuser_ip,':') + 1)||')')) as aud_ip, 	to_char(aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_datetime");
if(audTable.equalsIgnoreCase("PM_SOLICITUD_CONTRATO")){
	sbSql.append(", estado, cuota_mensual, to_char(fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, en_transicion, decode(estado, 'A', 'APROBADO', 'P', 'PENDIENTE', 'F', 'FINALIZADO') estado_desc");
}
sbSql.append(" from ");
sbSql.append(schemaName);
sbSql.append(audTable);
sbSql.append(" where aud_action = 'INS' and ");
sbSql.append(audFilter);
sbSql.append("=");
sbSql.append(aud_value_filter);
System.out.println("audAl.size()="+audAl.size());
if(!schemaName.trim().equals("-1")) audAl = SQLMgr.getDataList(sbSql.toString());
if (audAl.size() > 0) {

	CommonDataObject audCdo = (CommonDataObject) audAl.get(0);
%>
		<tr class="<%=panelDetailClass%>" align="center">
			<td align="right"><cellbytelabel id="5">Creaci&oacute;n</cellbytelabel></td>
			<td><%=audCdo.getColValue("aud_datetime")%></td>
			<td><%=audCdo.getColValue("aud_user")%></td>
			<td><%=audCdo.getColValue("aud_ip")%></td>
			<%if(audTable.equalsIgnoreCase("PM_SOLICITUD_CONTRATO")){%>
			<td><%=audCdo.getColValue("estado_desc")%></td>
			<td><%=audCdo.getColValue("cuota_mensual")%></td>
			<td><%=audCdo.getColValue("fecha_ini_plan")%></td>
			<td><%=audCdo.getColValue("en_transicion")%></td>
			<%}%>
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
sbSql.append("select * from (select decode(aud_webuser_ip,null,substr(aud_dbuser_ip,1,instr(aud_dbuser_ip,':') - 1),substr(aud_webuser_ip,1,instr(aud_webuser_ip,':') - 1)) as aud_user, decode(aud_webuser_ip,null,substr(aud_dbuser_ip,instr(aud_dbuser_ip,':') + 1),substr(aud_webuser_ip,instr(aud_webuser_ip,':') + 1)||decode(substr(aud_webuser_ip,instr(aud_webuser_ip,':') + 1),'127.0.0.1',' ('||substr(aud_dbuser_ip,instr(aud_dbuser_ip,':') + 1)||')')) as aud_ip, to_char(aud_timestamp,'dd/mm/yyyy hh12:mi:ss am') as aud_datetime");

if(audTable.equalsIgnoreCase("PM_SOLICITUD_CONTRATO")){
	sbSql.append(", estado, cuota_mensual, to_char(fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, en_transicion, decode(estado, 'A', 'APROBADO', 'P', 'PENDIENTE', 'F', 'FINALIZADO') estado_desc");
}
sbSql.append(" from ");
sbSql.append(schemaName);
sbSql.append(audTable);
sbSql.append(" where aud_action = 'UPD' and ");
sbSql.append(audFilter);
sbSql.append("=");
sbSql.append(aud_value_filter);
sbSql.append(" order by aud_timestamp asc)");
if(!schemaName.trim().equals("-1"))audAl = SQLMgr.getDataList(sbSql.toString());
if (audAl.size() > 0) {
for(int i= 0;i<audAl.size();i++){
	CommonDataObject audCdo = (CommonDataObject) audAl.get(i);
%>
		<tr class="<%=panelDetailClass%>" align="center">
			<td align="right"><cellbytelabel>Modificaci&oacute;n</cellbytelabel></td>
			<td><%=audCdo.getColValue("aud_datetime")%></td>
			<td><%=audCdo.getColValue("aud_user")%></td>
			<td><%=audCdo.getColValue("aud_ip")%></td>
			<%if(audTable.equalsIgnoreCase("PM_SOLICITUD_CONTRATO")){%>
			<td><%=audCdo.getColValue("estado_desc")%></td>
			<td><%=audCdo.getColValue("cuota_mensual")%></td>
			<td><%=audCdo.getColValue("fecha_ini_plan")%></td>
			<td><%=audCdo.getColValue("en_transicion")%></td>
			<%}%>
		</tr>
<%} 
} else { %>
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
