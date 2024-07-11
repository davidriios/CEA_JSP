<%
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	//	if (SecMgr.checkAccess(session.getId(),"0")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">document.title="Experiencia Laboral Edición - "+document.title;</script>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2" align="right"><a href="javascript:window.close();"><font class="Link01Bold">Cerrar Ventana</font></a>&nbsp;&nbsp;&nbsp;</td>
	</tr>
	<tr>
		<td width="50%" align="left" background="../images/bgTitle.jpg" height="25"><font class="TextModuleName">&nbsp;&nbsp;&nbsp;RECURSOS HUMANOS - MANTENIMIENTO</font></td>
		<td width="50%" align="right" background="../images/bgTitle.jpg" height="25"><font class="TextModuleName"><%=((String) session.getAttribute("compName"))%></font>&nbsp;&nbsp;&nbsp;</td>
	</tr>		
	<tr>
	    <td colspan="2">&nbsp;</td>
	</tr>
</table>

<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td width="99%" class="TableBorder">
<!--*************************************************************************************************************-->
<!--STYLE UP-->	

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="4" align="left">&nbsp;Experiencia Laboral Previa</td>
				</tr>	
				<tr class="TextRow01" >
					<td>&nbsp;C&oacute;digo</td>
					<td>&nbsp;<input type="text" name="codigo" size="30" value=""></td>
				</tr>							
				<tr class="TextRow02" >
					<td>&nbsp;Descripci&oacute;n</td>
					<td>&nbsp;<input type="text" name="nombre" size="65" value=""></td>
				</tr>							
				<tr>
					<td colspan="4" align="right"><input type="button" name="cancel" value="Cancelar" onClick="javascript:window.close()">&nbsp;<input type="button" name="save" value="Guardar" onClick="javascript:window.close()"></td>
				</tr>	

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>		
		</td>
	</tr>
</table>		


<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
//} else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
//} else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>