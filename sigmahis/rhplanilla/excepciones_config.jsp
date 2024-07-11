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
<script language="javascript">document.title="Excepciones Horario Edición - "+document.title;</script>
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
				<tr class="TextRow01" >
					<td width="15%">&nbsp;Sec.</td>
					<td width="20%">&nbsp;<input type="text" name="sec" size="10" value=""></td>
					<td width="10%">&nbsp;D&iacute;a</td>
					<td width="20%">&nbsp;<select name="dia"><option> 1 </option><option> 2 </option><option> 3 </option><option> 4 </option>
					                      <option> 5 </option><option> 6 </option><option> 7 </option></select></td>
					<td width="15%">&nbsp;Hrs. Trabajadas</td>
					<td width="20%">&nbsp;<input type="text" name="horasTrab" size="21" value=""></td>
				</tr>							
				<tr class="TextRow02" >
					<td>&nbsp;Entrada</td>
					<td>&nbsp;<input type="text" name="entrada" size="21" value=""></td>
					<td>&nbsp;Desde</td>
					<td>&nbsp;<input type="text" name="desde1" size="21" value=""></td>
					<td>&nbsp;Hasta</td>
					<td>&nbsp;<input type="text" name="hasta1" size="21" value=""></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;Marcar Comida?</td>
					<td>&nbsp;<input type="checkbox" name="comida">&nbsp;&nbsp;<input type="text" name="hrs" size="3">&nbsp;Hrs
							  <input type="text" name="min" size="3" value="">&nbsp;Min</td>
					<td>&nbsp;Salida</td>
					<td>&nbsp;<input type="text" name="salida1" size="21" value=""></td>
					<td>&nbsp;Entrada</td>
					<td>&nbsp;<input type="text" name="entrada1" size="21" value=""></td>
				</tr>
				<tr class="TextRow02" >
					<td>&nbsp;Salida</td>
					<td>&nbsp;<input type="text" name="salida" size="21" value=""></td>
					<td>&nbsp;Desde</td>
					<td>&nbsp;<input type="text" name="desde2" size="21" value=""></td>
					<td>&nbsp;Hasta</td>
					<td>&nbsp;<input type="text" name="hasta2" size="21" value=""></td>
				</tr>								
				<tr>
					<td colspan="6" align="right"><input type="button" name="cancel" value="Cancelar" onClick="javascript:window.close()">&nbsp;<input type="button" name="save" value="Guardar" onClick="javascript:window.close()"></td>
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