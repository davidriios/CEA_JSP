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
<script language="javascript">document.title="Tipo Cobranza Edición - "+document.title;</script>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>		
		<td colspan="2" align="right"><a href="javascript:window.close();"><font class="Link01Bold"><cellbytelabel>Cerrar Ventana</cellbytelabel></font></a>&nbsp;&nbsp;&nbsp;</td>
	</tr>
	<tr>
		<td width="50%" align="left" background="../images/bgTitle.jpg" height="25"><font class="TextModuleName">&nbsp;&nbsp;&nbsp;<cellbytelabel>CXC - MANTENIMIENTO</cellbytelabel></font></td>
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

<form name="formGenerales" method="post"><input type="hidden" name="screen" value="0">
<table id="tbl_generales" width="100%" cellpadding="0" border="0" cellspacing="0" align="center">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TPrincipal" align="left" width="100%" onClick="javascript:verocultar(panel0)"style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TPrincipal');" onMouseout="bcolor('#8f9ba9','TPrincipal');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;<cellbytelabel>Analista/Cobrador</cellbytelabel></td>
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
							<td width="15%">&nbsp;&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td> 
							<td width="35%">&nbsp;<input type="text" name="codigo" size="20" value="" readonly=""></td>
							<td width="15%">&nbsp;&nbsp;<cellbytelabel>Tipo</cellbytelabel></td> 
							<td width="35%">&nbsp;<select name="tipo"><option value="0">Empleado</option><option value="1"><cellbytelabel>Empresa</cellbytelabel></option></select></td>														
						</tr>					
						<tr class="TextRow02">
							<td>&nbsp;&nbsp;<cellbytelabel>Encargado</cellbytelabel></td>
							<td>&nbsp;<input type="text" name="encargado" size="50" value="">&nbsp;
							          <input type="button" name="btnencargado" value="..."></td>
							<td>&nbsp;&nbsp;<cellbytelabel>C&eacute;dula</cellbytelabel></td>
							<td>&nbsp;<input type="text" name="cedula" size="20" value=""></td>						
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
					<td id="TTipos" align="left" width="100%" onClick="javascript:verocultar(panel1)"style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TTipos');" onMouseout="bcolor('#8f9ba9','TTipos');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;<cellbytelabel>Tipos de Cobros por Cobrador</cellbytelabel></td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>				
				<tr>
					<td>
					<div id="panel1" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="TextRow02">
		                       <td colspan="5" align="right"><input type="button" name="btnaddtipo" value="Agregar" onClick="javascript:openwin('tipo_cobro_config.jsp');"></td>
	                        </tr>
							<tr class="TextRow01">
							    <td width="5%">&nbsp;</td>
								<td width="15%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
								<td width="30%">&nbsp;<cellbytelabel>Tipo Cobro</cellbytelabel></td>	
								<td width="40%">&nbsp;<cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
								<td width="10%">&nbsp;</td>								
							</tr>
							<tr class="TextRow02">
								<td align="center">1</td>
								<td>&nbsp;<cellbytelabel>COD01</cellbytelabel></td>
								<td>&nbsp;<cellbytelabel>ARREGLO DE PAGO</cellbytelabel></td>								
							    <td>&nbsp;<cellbytelabel>NA</cellbytelabel></td>
								<td><a href="javascript:openwin('tipo_cobro_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">
								<td align="center">2</td>
								<td>&nbsp;<cellbytelabel>COD02</cellbytelabel></td>
								<td>&nbsp;<cellbytelabel>LETRAS</cellbytelabel></td>								
							    <td>&nbsp;<cellbytelabel>NA</cellbytelabel></td>
								<td><a href="javascript:openwin('tipo_cobro_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">
								<td align="center">3</td>
								<td>&nbsp;<cellbytelabel>COD03</cellbytelabel></td>
								<td>&nbsp;<cellbytelabel>CHAMPUS</cellbytelabel></td>								
							    <td>&nbsp;<cellbytelabel>NA</cellbytelabel></td>
								<td><a href="javascript:openwin('tipo_cobro_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
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