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
<script language="javascript">document.title="Solicitud Crédito Edición - "+document.title;</script>
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

<div id="dhtmlgoodies_tabView1">
<!--GENERALES TAB0-->

<div class="dhtmlgoodies_aTab">
<form name="formGenerales" method="post"><input type="hidden" name="screen" value="0">
<table id="tbl_generales" width="100%" cellpadding="0" border="0" cellspacing="0" align="center">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TPaciente" align="left" width="100%" onClick="javascript:verocultar(panel0)"style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TPaciente');" onMouseout="bcolor('#8f9ba9','TPaciente');">
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
							<td width="18%">&nbsp;ID</td>
							<td width="30%">&nbsp;<input type="text" name="id1" size="20" value=""><input type="text" name="id2" size="5" value=""></td>							
							<td width="20%">&nbsp;C&eacute;dula</td>
							<td width="32%">&nbsp;<input type="text" name="cedula1" size="3" value=""><input type="text" name="cedula2" size="3" value=""><input type="text" name="cedula3" size="3" value=""><input type="text" name="cedula4" size="3" value="">&nbsp;<input type="checkbox" name="ced"></td>
						</tr>	
						<tr>
						    <td colspan="">
							</td>
						<tr>					
						<tr class="TextRow02">
							<td>&nbsp;Primer Nombre</td>
							<td>&nbsp;<input type="text" name="nombre1" size="38" value=""></td>							
							<td>&nbsp;C&oacute;nyugue</td>
							<td>&nbsp;<input type="text" name="conyugue" size="42" value=""></td>
						</tr>					
						<tr class="TextRow01">
							<td>&nbsp;Segundo Nombre</td>
							<td>&nbsp;<input type="text" name="nombre2" size="38" value=""></td>							
							<td>&nbsp;Passaporte</td>
							<td>&nbsp;<input type="text" name="pasaporte" size="25" value=""></td>
						</tr>
						<tr class="TextRow02">
							<td>&nbsp;Primer Apellido</td>
							<td>&nbsp;<input type="text" name="apellido1" size="38" value=""></td>
							<td>&nbsp;Sexo</td>
							<td>&nbsp;<select name="sexo"><option value="0">Masculino</option><option value="1">Femenino</option></select></td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Segundo Apellido</td>
							<td>&nbsp;<input type="text" name="apellido2" size="38" value=""></td>
							<td>&nbsp;Cr&eacute;dito L&iacute;mite</td>
							<td>&nbsp;<input type="text" name="credito" size="25" value=""></td>
						</tr>						
						<tr class="TextRow02">
							<td>&nbsp;Tel&eacute;efono Residencia</td>
							<td>&nbsp;<input type="text" name="residencia_Tel" size="38" value=""></td>
							<td>&nbsp;Salario Mensual</td>
							<td>&nbsp;<input type="text" name="salario_Mes" size="25" value=""></td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Direcci&oacute;n Postal</td>
							<td>&nbsp;<input type="text" name="postal" size="38" value=""></td>
							<td>&nbsp;Otros Ingresos</td>
							<td>&nbsp;<input type="text" name="otros_Ingreso" size="25" value=""></td>
						</tr>
						<tr class="TextRow02">
							<td>&nbsp;Lugar de trabajo</td>
							<td>&nbsp;<input type="text" name="lugar_Trabajo" size="38" value=""></td>
							<td>&nbsp;Fuente Otros Ingresos</td>
							<td>&nbsp;<input type="text" name="fuente_Ingreso" size="43" value=""></td>							
						</tr>
						<tr class="TextRow02">
							<td>&nbsp;Ingreso del C&oacute;nyugue</td>
							<td>&nbsp;<input type="text" name="conyugue_Ingreso" size="38" value=""></td>
							<td>&nbsp;Ocupaci&oacute;n</td>
							<td>&nbsp;<input type="text" name="ocupacion" size="43" value=""></td>							
						</tr>
						<tr class="TextRow02">
							<td>&nbsp;Direcci&oacute;n Residencial</td>
							<td>&nbsp;<input type="text" name="dir_Residencia" size="38" value=""></td>
							<td>&nbsp;Direcci&oacute;n de Trabajo</td>
							<td>&nbsp;<input type="text" name="dir_Trabajo" size="43" value=""></td>							
						</tr>
						<tr class="TextRow02">
							<td>&nbsp;Tiempo Laborado</td>
							<td>&nbsp;<input type="text" name="years" size="10" value="">&nbsp;A&ntilde;os&nbsp;
							          <input type="text" name="month" size="10" value="">&nbsp;Meses</td>
							<td>&nbsp;Telef&oacute;no del Trabajo</td>
							<td>&nbsp;<input type="text" name="tel_Trabajo" size="43" value=""></td>							
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
					<td id="TSolicitud" align="left" width="100%" onClick="javascript:verocultar(panel1)"style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TSolicitud');" onMouseout="bcolor('#8f9ba9','TSolicitud');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Solicitud</td>
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
								<td width="12%">&nbsp;&nbsp;No.</td>
								<td width="25%">&nbsp;<input type="text" name="no" size="20" value=""></td>	
								<td width="10%">&nbsp;&nbsp;Fecha</td>
								<td width="23%">&nbsp;<input type="text" name="fecha" size="20" value=""></td>
								<td width="10%">&nbsp;Estado</td>
								<td width="23%">&nbsp;<select name="status"><option value="0">Activo</option><option value="1">Inactivo</option></select></td>								
							</tr>
							<tr class="TextRow02">
								<td>&nbsp;Observaciones</td>
								<td colspan="3">&nbsp;<textarea name="observaciones" rows="6" cols="38">NA</textarea></td>								
							    <td colspan="2">&nbsp;Garant&iacute;as&nbsp;<input type="button" name="garantias" value="..." onClick=""></td>
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
					<td id="TCodeudor" align="left" width="100%" onClick="javascript:verocultar(panel2)"style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TCodeudor');" onMouseout="bcolor('#8f9ba9','TCodeudor');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Datos del Codeudor</td>
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
								<td>&nbsp;Nombre Completo</td>
								<td colspan="3">&nbsp;<input type="text" name="nombre3" size="48" value=""></td>									
							</tr>							
							<tr class="TextRow02">
							    <td width="15%">&nbsp;Identificaci&oacute;n</td>
								<td width="35%">&nbsp;<input type="text" name="id3" size="30" value=""></td>																
							    <td width="20%">&nbsp;A&ntilde;os Laborados</td>
								<td width="30%">&nbsp;<input type="text" name="year2" size="5" value="">&nbsp;&nbsp;Meses&nbsp;&nbsp;
								          <input type="text" name="month" size="5" value=""></td>								
							</tr>
							<tr class="TextRow01">
							    <td>&nbsp;Sexo</td>
								<td>&nbsp;<select name="sexo2"><option value="0">Masculino</option>
								          <option value="1">Femenino</option></select></td>
								<td>&nbsp;Ingreso Mensual</td>
								<td>&nbsp;<input type="text" name="ingreso_Mes" size="25" value=""></td>		  
							</tr>
							<tr class="TextRow02">
							    <td>&nbsp;Direcci&oacute;n</td>
								<td>&nbsp;<input type="text" name="dir_Residencia2" size="48" value=""></td>
								<td>&nbsp;Otros Ingresos</td>
								<td>&nbsp;<input type="text" name="otros_Ingreso" size="25" value=""></td>		  
							</tr>
							<tr class="TextRow01">
							    <td>&nbsp;Tel&eacute;fono</td>
								<td>&nbsp;<input type="text" name="tel_Residencia2" size="48" value=""></td>
								<td>&nbsp;Fuente Otros Ingresos</td>
								<td>&nbsp;<input type="text" name="fuente_Ingreso"  size="40" value=""></td>		  
							</tr>
							<tr class="TextRow02">
							    <td>&nbsp;Direcci&oacute;n Postal</td>
								<td colspan="3">&nbsp;<input type="text" name="dir_Postal2" size="48" value=""></td>
							</tr>
							<tr  class="TextRow01">
								<td>&nbsp;Lugar de Trabajo</td>
								<td colspan="3">&nbsp;<input type="text" name="lugar_Trabajo" size="48" value=""></td>		  
							</tr>
							<tr class="TextRow02">
								<td>&nbsp;Ocupaci&oacute;n</td>
								<td colspan="3">&nbsp;<input type="text" name="ocupacion2" size="48" value=""></td>		  
							</tr>
							<tr class="TextRow01">
								<td>&nbsp;Direcci&oacute;n Trabajo</td>
								<td colspan="3">&nbsp;<input type="text" name="dir_Trabajo2" size="48" value=""></td>		  
							</tr>
							<tr class="TextRow02">
								<td>&nbsp;Tel&eacute;fono Trabajo</td>
								<td colspan="3">&nbsp;<input type="text" name="tel_Trabajo2" size="30" value="">&nbsp;&nbsp;Ext.
								          <input type="text" name="extension" size="6" value=""></td>		  
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
</div>


<!--REFERENCIA TAB1-->
<div class="dhtmlgoodies_aTab">
<form name="formReferencia" method="post"><input type="hidden" name="screen" value="1">
<table id="tbl_referencia" width="100%" cellpadding="0" cellspacing="0" border="0" align="center">
	<tr class="TextRow01">
		<td	align="leg" colspan="2">&nbsp;C&Oacute;DIGO COD. 150107</td>
		<td align="center" colspan="2">&nbsp;NOMBRE DIEGO TORRES</td>
		<td align="right" colspan="2">&nbsp;SOLICITUD 1501</td>
	</tr>
	<tr>
  	    <td width="18%">&nbsp;</td>
		<td width="17%">&nbsp;</td>
		<td width="15%">&nbsp;</td>
		<td width="15%">&nbsp;</td>
		<td width="17%">&nbsp;</td>
		<td width="18%">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="6">
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TReferencia" align="left" width="100%" onClick="javascript:verocultar(panel3)"style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TReferencia');" onMouseout="bcolor('#8f9ba9','TReferencia');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Referencias</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>	
					    <div id="panel3" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">	
							<tr class="TextRow02">
		                       <td colspan="8" align="right"><input type="button" name="btnaddref" value="Agregar" onClick="javascript:openwin('referencia_config.jsp');"></td>
	                        </tr>
							<tr class="TextRow01">
								<td width="5%">&nbsp;No.</td>
								<td width="10%">&nbsp;Tipo</td>
								<td width="25%">&nbsp;Nombre</td>
								<td width="10%">&nbsp;Tel&eacute;fono</td>
								<td width="20%">&nbsp;Direcci&oacute;n</td>
								<td width="10%">&nbsp;E-Mail</td>
								<td width="10%">&nbsp;Fax</td>
								<td width="10%">&nbsp;</td>
							</tr>
							<tr class="TextRow02">								
							    <td align="center">1</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXX</td>
								<td>&nbsp;XXXXXXXX</td>
								<td>&nbsp;<a href="javascript:openwin('referencia_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">								
							    <td align="center">2</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXX</td>
								<td>&nbsp;XXXXXXXX</td>
								<td>&nbsp;<a href="javascript:openwin('referencia_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">								
							    <td align="center">3</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXX</td>
								<td>&nbsp;XXXXXXXX</td>
								<td>&nbsp;<a href="javascript:openwin('referencia_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>							
						 </table>
					     </div>
		            </td>
	            </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="6" align="right"><input type="button" name="cancel" value="Cancelar" onClick="javascript:window.close()">&nbsp;&nbsp;<input type="button" name="save" value="Guardar" onClick="javascript:window.close()">&nbsp;</td>
	</tr>		
	<tr class="TextRow01">
	    <td colspan="3" align="left">&nbsp;CREADO: RODOLFO PÉREZ - 23-06-2007 - 07:00 AM</td> 
	    <td colspan="3" align="right">MODIFICADO: RODOLFO PÉREZ - 23-06-2007 - 07:00 AM&nbsp;</td>
    </tr>
</table>
<%@ include file="../common/footer.jsp"%>		
</form>
</div>

</div>
<script type="text/javascript">
initTabs('dhtmlgoodies_tabView1',Array('Solicitud','Referencias'),0,'100%','');
</script>

	
<!--STYLE DW-->
<!--*************************************************************************************************************-->
	</td>
</tr>		
</table>
</body>
</html>