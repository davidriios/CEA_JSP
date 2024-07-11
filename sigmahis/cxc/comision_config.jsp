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
<script language="javascript">document.title="Comisión Edición - "+document.title;</script>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2" align="right"><a href="javascript:window.close();"><font class="Link01Bold">Cerrar Ventana</font></a>&nbsp;&nbsp;&nbsp;</td>
	</tr>
	<tr>
		<td width="50%" align="left" background="../images/bgTitle.jpg" height="25"><font class="TextModuleName">&nbsp;&nbsp;&nbsp;<cellbytelabel>CXC - MANTENIMIENTO</cellbytelabel></font></td>
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
					<td colspan="4" align="left">&nbsp;<cellbytelabel>Comisi&oacute;n</cellbytelabel></td>
				</tr>				
				<tr class="TextRow01" >
					<td width="15%">&nbsp;<cellbytelabel>Sec</cellbytelabel>.</td>
					<td width="35%"><input type="text" name="sec" size="30" value=""></td>
					<td width="15%">&nbsp;<cellbytelabel>Comsi&oacute;n</cellbytelabel></td>
					<td width="35%"><input type="text" name="comision" size="30" value=""></td>									    
				</tr>							
				<tr class="TextRow02" >
					<td>&nbsp;<cellbytelabel>Rango Inicial</cellbytelabel></td>
					<td><input type="text" name="rangoIni" size="30" value=""></td>
					<td>&nbsp;<cellbytelabel>Rango Final</cellbytelabel></td>
					<td><input type="text" name="rangoFin" size="30" value=""></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel>Tipo Valor</cellbytelabel></td>
					<td colspan="3"><select name="tipo"><option value="0"><cellbytelabel>Tipo Valor</cellbytelabel></option></select></td>
				</tr>																					
				<tr>
					<td colspan="4" align="right"><input type="button" name="cancel" value="Cancelar" onClick="javascript:window.close()">&nbsp;<input type="button" name="save" value="Guardar" onClick="javascript:window.close()"></td>
				</tr>	

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>		
		</td>
	</tr>
	<tr>
	    <td>&nbsp;</td> 
	    <td class="TextRow01" align="right"><!--CREADO POR : NESBY DE LEON - 21-06-2007 - 07:00 Am&nbsp;--></td>
		<td>&nbsp;</td>
    </tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
//} else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
//} else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>