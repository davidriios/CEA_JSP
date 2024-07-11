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
<script language="javascript">document.title="Contrato Alquiler Edición - "+document.title;</script>
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
					<td colspan="4" align="left">&nbsp;<cellbytelabel>Generales del Inmueble M&eacute;dico</cellbytelabel></td>
				</tr>				
				<tr class="TextRow01">
					<td width="15%">&nbsp;&nbsp;<cellbytelabel>C&oacute;d. Inmueble</cellbytelabel></td> 
					<td width="35%">&nbsp;<input type="text" name="codInmueble" size="30" value="" readonly=""></td>
					<td width="15%">&nbsp;&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel></td> 
					<td width="35%">&nbsp;<input type="text" name="descripcion" size="48"></td>														
				</tr>											
				<tr class="TextRow02">
					<td>&nbsp;&nbsp;<cellbytelabel>Otorgado a</cellbytelabel>:</td>
					<td>&nbsp;<select name="otorgado"><option value="0"><cellbytelabel>M&eacute;dico</cellbytelabel></option><option value="1"><cellbytelabel>Empresa</cellbytelabel></option></select></td>																	
					<td>&nbsp;&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td>&nbsp;<input type="text" name="codigo" size="30" value=""></td>
				</tr>
				<tr class="TextRow01">							
					<td>&nbsp;&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
					<td>&nbsp;<input type="text" name="nombre" size="45" value="">
							  <input type="button" name="btnnom" value="..."></td>
					<td>&nbsp;&nbsp;<cellbytelabel>Contacto</cellbytelabel></td>
					<td>&nbsp;<input type="text" name="contacto" size="48" value=""></td>						
				</tr>
				<tr class="TextRow02">							
					<td>&nbsp;&nbsp;<cellbytelabel>Fecha Inicio</cellbytelabel></td>
					<td>&nbsp;<input type="text" name="fechaIni" size="30" value=""></td>
					<td>&nbsp;&nbsp;<cellbytelabel>Fecha Final</cellbytelabel></td>
					<td>&nbsp;<input type="text" name="fechaIni" size="30" value=""></td>						
				</tr>
				<tr class="TextRow01">							
					<td>&nbsp;&nbsp;<cellbytelabel>Hora Entrada</cellbytelabel></td>
					<td>&nbsp;<input type="text" name="entrada" size="30" value=""></td>
					<td>&nbsp;&nbsp;<cellbytelabel>Hora Salida</cellbytelabel></td>
					<td>&nbsp;<input type="text" name="salida" size="30" value=""></td>						
				</tr>
				<tr class="TextRow01">							
					<td>&nbsp;&nbsp;<cellbytelabel>Monto Mensual</cellbytelabel></td>
					<td>&nbsp;<input type="text" name="monto" size="30" value=""></td>
					<td>&nbsp;&nbsp;H&aacute;<cellbytelabel>bito de Pago</cellbytelabel></td>
					<td>&nbsp;<input type="text" name="habito1" size="5" value=""><input type="text" name="habito2" size="36" value="">&nbsp;<input type="button" name="btnhabito" value="..."></td>						
				</tr>
				<tr class="TextRow02">							
					<td>&nbsp;&nbsp;<cellbytelabel>Comentario</cellbytelabel></td>
					<td>&nbsp;<textarea name="comentario" rows="6" cols="37"><cellbytelabel>NA</cellbytelabel></textarea></td>
					<td>&nbsp;&nbsp;<cellbytelabel>Estado</cellbytelabel></td>
					<td>&nbsp;<select name="estado"><option value="0"><cellbytelabel>Activo</cellbytelabel></option><option value="1"><cellbytelabel>Inactivo</cellbytelabel></option></select></td>						
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