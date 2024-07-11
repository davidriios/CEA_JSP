<%
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	//	if (SecMgr.checkAccess(session.getId(),"0")) {
%>
<html>   
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
function openwin(val)
{
    var opciones="toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=1002,height=350,top=120,left=default";
	window.open(val,"newwindow",opciones);
}
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">document.title="Solicitud Beneficio Edición - "+document.title;</script>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>		
		<td colspan="2" align="right"><a href="javascript:window.close();"><font class="Link01Bold">Cerrar Ventana</font></a>&nbsp;&nbsp;&nbsp;</td>
	</tr>
	<tr>
		<td width="50%" align="left" background="../images/bgTitle.jpg" height="25"><font class="TextModuleName">&nbsp;&nbsp;&nbsp;ADMISI&Oacute;N - MANTENIMIENTO</font></td>
		<td width="50%" align="right" background="../images/bgTitle.jpg" height="25"><font class="TextModuleName"><%=((String) session.getAttribute("compName"))%></font>&nbsp;&nbsp;&nbsp;</td>
	</tr>		
	<tr>
	    <td colspan="2">&nbsp;</td>
	</tr>
</table>

<table align="center" width="98%" cellpadding="0" cellspacing="0" style='border-right:1.5pt solid #e6e4e4; border-left:1.5pt solid #e6e4e4; border-bottom:1.5pt solid #FFFFFF; border-top:1.5pt solid #FFFFFF;'>
<tr>
	<td width="100%"><div name="pagerror" id="pagerror" class="FieldError" style="visibility:hidden; display:none;">&nbsp;</div>
<!--*************************************************************************************************************-->
<!--STYLE UP-->

<!--GENERALES TAB0-->
<form name="formGenerales" method="post"><input type="hidden" name="screen" value="0">
<table id="tbl_proceso" width="100%" cellpadding="0" border="0" cellspacing="0" align="center">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TPaciente" align="left" width="100%" onClick="javascript:verocultar(panel0)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TPaciente');" onMouseout="bcolor('#8f9ba9','TPaciente');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%" >&nbsp;Datos del Paciente</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>	
					<div id="panel0" style="visibility:visible;">
					<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">									
						<tr class="TextRow01">
							<td width="20%">&nbsp;Admisi&oacute;n</td>
							<td width="30%">&nbsp;<input type="text" name="admision1" size="10" value=""><input type="text" name="admision2" size="5" value=""><input type="text" name="admision3" size="5" value="">&nbsp;<input type="button" name="btnadmision" value="..."></td>
							<td width="20%">&nbsp;No. Solicitud</td>
							<td width="30%">&nbsp;<input type="text" name="noSolicitud" size="30" value=""></td>					  							
							
						</tr>	
						<tr class="TextRow02">
						   <td>&nbsp;C&eacute;dula/Pasaporte</td>
						   <td>&nbsp;<input type="text" name="cedula1" size="29" value=""></td>
						   <td>&nbsp;Fecha</td>
						   <td>&nbsp;<input type="text" name="fecha" size="30" value=""></td>
						<tr>					
						<tr class="TextRow01">
							<td>&nbsp;Categor&iacute;a</td>
							<td>&nbsp;<input type="text" name="categoria" size="40" value=""></td>
							<td>&nbsp;Estatus</td>
							<td>&nbsp;<select name="estatus"><option value="0">Activo</option><option value="1">Inactivo</option></select></td>														
						</tr>					
						<tr class="TextRow02">
							<td>&nbsp;D&iacute;as Aprobado(Hospitalizaci&oacute;n)</td>
							<td>&nbsp;<input type="text" name="dia_Aprobado" size="29" value=""></td>							
							<td>&nbsp;Observaci&oacute;n</td>
							<td>&nbsp;<textarea name="observacion" rows="6" cols="30">NA</textarea></td>							
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Aseguradora</td>
							<td>&nbsp;<input type="text" name="aseguradora" size="37" value="">&nbsp;<input type="button" name="btnasegu" value="..."></td>
							<td>&nbsp;P&oacute;liza</td>
							<td>&nbsp;<input type="text" name="poliza" size="30" value=""></td>
						</tr>
						<tr class="TextRow02">
							<td>&nbsp;Due&ntilde;o</td>
							<td>&nbsp;<input type="text" name="dueno" size="37" value=""></td>
							<td>&nbsp;Certificado</td>
							<td>&nbsp;<input type="text" name="certificado" size="30" value=""></td>
						</tr>						
						<tr class="TextRow01">
							<td>&nbsp;Copago</td>
							<td>&nbsp;<input type="text" name="copago1" size="29" value="">&nbsp;<select name="copago2"><option></option></select></td>
							<td>&nbsp;Por</td>
							<td>&nbsp;<select name="evento"><option>Evento</option></select>&nbsp;&nbsp;D&iacute;as&nbsp;
									  <input type="text" name="dias" size="10" value=""></td>
						</tr>												
					</table>
					</div>
					</td>
				</tr>
			</table>
		</td>
	 </tr>
	 <tr>
		<td>					
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TDiagnostico" align="left" width="100%" onClick="javascript:verocultar(panel1)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TDiagnostico');" onMouseout="bcolor('#8f9ba9','TDiagnostico');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Diagnósticos y Procedimientos</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>
					<div id="panel1" style="display:none;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="TextRow01">
								<td width="10%">&nbsp;No.</td>
								<td width="20%">&nbsp;Tipo de Detalle</td>
								<td width="35%">&nbsp;C&oacute;digo de Diagn&oacute;stico</td>
								<td width="35%">&nbsp;C&oacute;digo de Procedimiento</td>
							</tr>
							<tr class="TextRow02">
								<td>&nbsp;<input type="text" name="no" size="9" value=""></td>
								<td>&nbsp;<select name="tipo_Detalle"><option>Seleccionar...</option></select></td>								
								<td>&nbsp;<input type="text" name="diagnostico" size="6" value=""><input type="text" name="diagnostico" size="35" value="">
										  <input type="button" name="btndiagnos" value="..."></td>
								<td>&nbsp;<input type="text" name="procedimiento" size="6" value=""><input type="text" name="procedimiento" size="35" value="">
										  <input type="button" name="btnproce" value="..."></td>		  
							</tr>
							<tr class="TextRow01">
								<td>&nbsp;<input type="text" name="no" size="9" value=""></td>
								<td>&nbsp;<select name="tipo_Detalle"><option>Seleccionar...</option></select></td>								
								<td>&nbsp;<input type="text" name="diagnostico" size="6" value=""><input type="text" name="diagnostico" size="35" value="">
										  <input type="button" name="btndiagnos" value="..."></td>
								<td>&nbsp;<input type="text" name="procedimiento" size="6" value=""><input type="text" name="procedimiento" size="35" value="">
										  <input type="button" name="btnproce" value="..."></td>		  
							</tr>
							<tr class="TextRow02">
								<td>&nbsp;<input type="text" name="no" size="9" value=""></td>
								<td>&nbsp;<select name="tipo_Detalle"><option>Seleccionar...</option></select></td>								
								<td>&nbsp;<input type="text" name="diagnostico" size="6" value=""><input type="text" name="diagnostico" size="35" value="">
										  <input type="button" name="btndiagnos" value="..."></td>
								<td>&nbsp;<input type="text" name="procedimiento" size="6" value=""><input type="text" name="procedimiento" size="35" value="">
										  <input type="button" name="btnproce" value="..."></td>		  
							</tr>
						</table>						
					</div>
					</td>
				</tr>					
			</table>
		</td>
	 </tr>
	 <tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TCobertura" align="left" width="100%" onClick="javascript:verocultar(panel2)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TCobertura');" onMouseout="bcolor('#8f9ba9','TCobertura');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Datos del Cobertura</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>			
				<tr>
					<td>
					<div id="panel2" style="display:none;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="TextRow01">								
								<td width="16%">&nbsp;Clasificaci&oacute;n Serv.</td>
								<td width="13%">&nbsp;L&iacute;mite M&aacute;x. %-$</td>
								<td width="9%">&nbsp;Deducible</td>
								<td width="16%">&nbsp;Empresa %-$</td>
								<td width="20%">&nbsp;Paciente %-Dif.</td>
								<td width="16%">&nbsp;Tipo de Habitaci&oacute;n</td>
								<td width="10%">&nbsp;Precio</td>									
							</tr>							
							<tr class="TextRow02">
								<td>&nbsp;<input type="text" name="servicios1" size="2" value=""><input type="text" name="servicios2" size="8" value=""><input type="button" name="btnservicios" value="..."></td>
								<td>&nbsp;<input type="text" name="limite_Max1" size="8" value=""><select name="limite_Max2"><option></option></select></td>																
								<td>&nbsp;<input type="text" name="deducible" size="7" value=""></td>
								<td>&nbsp;<input type="text" name="empresa" size="13" value=""><select name="empresa2"><option></option></select>&nbsp;
								<td>&nbsp;<input type="text" name="paciente" size="18" value="">&nbsp;<input type="button" name="btnpaciente" value="..."><input type="checkbox"></td>
								<td>&nbsp;<input type="text" name="tipo_Habitacion" size="15" value="">&nbsp;<input type="button" name="tipo_Habitacion2" value="..."></td>								
								<td>&nbsp;<input type="text" name="precio" size="8" value=""></td> 
							</tr>
							<tr class="TextRow01">
								<td>&nbsp;<input type="text" name="servicios1" size="2" value=""><input type="text" name="servicios2" size="8" value=""><input type="button" name="btnservicios" value="..."></td>
								<td>&nbsp;<input type="text" name="limite_Max1" size="8" value=""><select name="limite_Max2"><option></option></select></td>																
								<td>&nbsp;<input type="text" name="deducible" size="7" value=""></td>
								<td>&nbsp;<input type="text" name="empresa" size="13" value=""><select name="empresa2"><option></option></select>&nbsp;
								<td>&nbsp;<input type="text" name="paciente" size="18" value="">&nbsp;<input type="button" name="btnpaciente" value="..."><input type="checkbox"></td>
								<td>&nbsp;<input type="text" name="tipo_Habitacion" size="15" value="">&nbsp;<input type="button" name="tipo_Habitacion2" value="..."></td>								
								<td>&nbsp;<input type="text" name="precio" size="8" value=""></td>		  
							</tr>
							<tr class="TextRow02">
								<td>&nbsp;<input type="text" name="servicios1" size="2" value=""><input type="text" name="servicios2" size="8" value=""><input type="button" name="btnservicios" value="..."></td>
								<td>&nbsp;<input type="text" name="limite_Max1" size="8" value=""><select name="limite_Max2"><option></option></select></td>																
								<td>&nbsp;<input type="text" name="deducible" size="7" value=""></td>
								<td>&nbsp;<input type="text" name="empresa" size="13" value=""><select name="empresa2"><option></option></select>&nbsp;
								<td>&nbsp;<input type="text" name="paciente" size="18" value="">&nbsp;<input type="button" name="btnpaciente" value="..."><input type="checkbox"></td>
								<td>&nbsp;<input type="text" name="tipo_Habitacion" size="15" value="">&nbsp;<input type="button" name="tipo_Habitacion2" value="..."></td>								
								<td>&nbsp;<input type="text" name="precio" size="8" value=""></td>		  
							</tr>
						</table>						
					</div>
					</td>
				</tr>	
			</table>
		 </td>
	 </tr>	 						
	 <tr>
	  	 <td align="right"><input type="button" name="cancel" value="Cancelar" onClick="javascript:window.close()">&nbsp;&nbsp;<input type="button" name="save" value="Guardar" onClick="javascript:window.close()"></td>
	 </tr>
</table>
<%@ include file="../common/footer.jsp"%>	
</form>

<!--STYLE DW-->
<!--*************************************************************************************************************-->
	</td>
</tr>		
</table>
</body>
</html>