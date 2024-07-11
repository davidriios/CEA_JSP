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
<script language="javascript">document.title="Porcentajes Edición - "+document.title;</script>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2" align="right"><a href="javascript:window.close();"><font class="Link01Bold"><cellbytelabel>Cerrar Ventana</cellbytelabel></font></a>&nbsp;&nbsp;&nbsp;</td>
	</tr>
	<tr>
		<td width="50%" align="left" background="../images/bgTitle.jpg" height="25"><font class="TextModuleName">&nbsp;&nbsp;&nbsp;<cellbytelabel>FACTURACI&Oacute;N - MANTENIMIENTO</cellbytelabel></font></td>
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
					<td colspan="4" align="left">&nbsp;<cellbytelabel>Porcentajes</cellbytelabel></td>
				</tr>	
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel>Centro de Servicio</cellbytelabel></td>
					<td colspan="3">&nbsp;<input type="text" name="codigo1" size="5" value="">
					          <input type="text" name="centroServ" size="45" value="">
							  <input type="button" name="btnserv" value="..."></td>
				</tr>							
				<tr class="TextRow02" >
					<td>&nbsp;<cellbytelabel>Tipo de Servicio</cellbytelabel></td>
					<td colspan="3">&nbsp;<input type="text" name="codigo2" size="5" value="">
					          <input type="text" name="tipoServ" size="45" value="">
							  <input type="button" name="btntipo" value="..."></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel>Categor&iacute;a</cellbytelabel></td>
					<td colspan="3">&nbsp;<input type="text" name="codigo3" size="5" value="">
					          <input type="text" name="categoria" size="45" value="">
							  <input type="button" name="btncateg" value="..."></td>
				</tr>
				<tr class="TextRow02" >
					<td width="18%">&nbsp;<cellbytelabel>Tipo Valor</cellbytelabel></td>
					<td width="42%">&nbsp;<select name="tipo"><option value="0">Porcentaje</option></select></td>
					<td width="10%">&nbsp;<cellbytelabel>Valor</cellbytelabel></td>
					<td width="30%">&nbsp;<input type="text" name="valor" size="30" value=""></td>
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