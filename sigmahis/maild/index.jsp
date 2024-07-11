<%@ page import="java.util.ResourceBundle" %>
<%
String smtphost = "No existe";
String smtpuser = "No existe";
String smtpfrom = "No existe";
String smtpuseAuth = "No existe";
String smtpport = "No existe";
String time_interval = "No existe";

try { smtphost = ResourceBundle.getBundle("issi_mail").getString("smtphost"); } catch (Exception ex) { }
try { smtpuser = ResourceBundle.getBundle("issi_mail").getString("smtpuser"); } catch (Exception ex) { }
try { smtpfrom = ResourceBundle.getBundle("issi_mail").getString("smtpfrom"); } catch (Exception ex) { }
try { smtpuseAuth = ResourceBundle.getBundle("issi_mail").getString("smtpuseAuth"); } catch (Exception ex) { }
try { smtpport = ResourceBundle.getBundle("issi_mail").getString("smtpport"); } catch (Exception ex) { }
try { time_interval = ResourceBundle.getBundle("issi_mail").getString("time_interval"); } catch (Exception ex) { }
%>
<html>
<head>
<script>
</script>
</head>
<body>
<table cellpadding="0" cellspacing="0" width="100%" border="1">
<tr>
	<th width="15%">Par&aacute;metro</th>
	<th>Valor</th>
</tr>
<tr>
	<td>smtphost</th>
	<td><%=smtphost%></th>
</tr>
<tr>
	<td>smtpuser</th>
	<td><%=smtpuser%></th>
</tr>
<tr>
	<td>smtpfrom</th>
	<td><%=smtpfrom%></th>
</tr>
<tr>
	<td>smtpuseAuth</th>
	<td><%=smtpuseAuth%></th>
</tr>
<tr>
	<td>smtpport</th>
	<td><%=smtpport%></th>
</tr>
<tr>
	<td>time_interval</th>
	<td><%=time_interval%></th>
</tr>
</table>
</body>
</html>