<%
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	//	if (SecMgr.checkAccess(session.getId(),"0")) {
%>
<html>   
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
function openwin(val)
{
    var opciones="toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=1002,height=250,top=120,left=default";
	window.open(val,"cargosconfig",opciones);
}
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">document.title="Cargo Edición - "+document.title;</script>
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

<table align="center" width="98%" cellpadding="0" cellspacing="0" style='border-right:1.5pt solid #e6e4e4; border-left:1.5pt solid #e6e4e4; border-bottom:1.5pt solid #FFFFFF; border-top:1.5pt solid #FFFFFF;'>
<tr>
	<td width="100%"><div name="pagerror" id="pagerror" class="FieldError" style="visibility:hidden; display:none;">&nbsp;</div>
<!--*************************************************************************************************************-->
<!--STYLE UP-->

<div id="dhtmlgoodies_tabView1">

<!--CARGO TAB0-->
<div class="dhtmlgoodies_aTab">
<form name="formCargo" method="post"><input type="hidden" name="screen" value="0">
<table id="tbl_cargo" width="100%" cellpadding="0" border="0" cellspacing="0" align="center">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TCargo" align="left" width="100%" onClick="javascript:verocultar(panel0)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TCargo');" onMouseout="bcolor('#8f9ba9','TCargo');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Cargo</td>
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
							<td>&nbsp;Nombre Corto</td>
							<td>&nbsp;<input type="text" name="nombre" size="51" value=""></td>
							<td>&nbsp;C&oacute;digo</td>
							<td>&nbsp;<input type="text" name="codigo" size="15" value=""></td>						                  			
						</tr>					
						<tr class="TextRow02">
							<td width="15%">&nbsp;Denominaci&oacute;n</td>
							<td width="40%">&nbsp;<input type="text" name="denominacion" size="51" value="">&nbsp;<input type="button" name="btncedula" value="..."></td>							
							<td width="20%">&nbsp;Gasto Representaci&oacute;n</td>
							<td width="25%">&nbsp;<input type="text" name="representacion" size="25" value=""></td>
						</tr>					
						<tr class="TextRow01">
							<td>&nbsp;Salario Base</td>
							<td>&nbsp;<input type="text" name="salario" size="25" value=""></td>							
							<td>&nbsp;Monto Gatos Rep.</td>
							<td>&nbsp;<input type="text" name="gasto" size="25" value=""></td>
						</tr>
						<tr class="TextRow02">
							<td>&nbsp;Tipo de Puesto</td>
							<td>&nbsp;<input type="text" name="codePuesto" size="5" value=""><input type="text" name="puesto" size="42" value="">
							          <input type="button" name="btnpuesto" value="..."></td>							
							<td>&nbsp;D&iacute;as de Vacaciones</td>
							<td>&nbsp;<input type="text" name="vacaciones" size="25" value=""></td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Tipo de Uniforme</td>
							<td colspan="3">&nbsp;<input type="text" name="codeUniforme" size="5" value=""><input type="text" name="uniforme" size="42" value="">
							          <input type="button" name="btnuniforme" value="..."></td>							
						</tr>
						<tr class="TextRow02">
							<td>&nbsp;Resumen</td>
							<td colspan="3">&nbsp;<input type="text" name="resumen" size="88" value=""></td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Descripci&oacute;n</td>
							<td colspan="3">&nbsp;<input type="text" name="descripcion" size="88" value=""></td>
						</tr>								
						<tr class="TextRow02">
							<td>&nbsp;Habilidades</td>
							<td colspan="3">&nbsp;<input type="text" name="habilidades" size="88" value=""></td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Desctreza</td>
							<td colspan="3">&nbsp;<input type="text" name="destreza" size="88" value=""></td>
						</tr>
						<tr class="TextRow02">
							<td>&nbsp;Licencia</td>
							<td colspan="3">&nbsp;<input type="text" name="licencia" size="88" value=""></td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;Condiciones</td>
							<td colspan="3">&nbsp;<input type="text" name="condiciones" size="88" value=""></td>
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
					<td id="TSupervision" align="left" width="100%" onClick="javascript:verocultar(panel1)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TSupervision');" onMouseout="bcolor('#8f9ba9','TSupervision');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Supervisi&oacute;n</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>				
				<tr>
					<td>
					<div id="panel1" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
						    <tr class="TextRow01">
								<td width="15%">&nbsp;Brindada</td>
								<td width="85%">&nbsp;<input type="text" name="brindada" size="88"></td>	
							</tr>
							<tr class="TextRow02">
								<td width="15%">&nbsp;Recibida</td>
								<td width="85%">&nbsp;<input type="text" name="recibida" size="88"></td>
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

<!--TAREAS Y NATURALEZA TAB1-->
<div class="dhtmlgoodies_aTab">
<form name="formTareas" method="post"><input type="hidden" name="screen" value="1">
<table id="tbl_Tareas" width="100%" cellpadding="0" cellspacing="0" border="0" align="center">
	<tr class="TextRow01">
  	    <td colspan="4" align="center">&nbsp;Cargo&nbsp;<input type="text" name="cargo1" size="5" value="" readonly=""><input type="text" name="cargo2" size="60" value="" readonly=""></td>		
	</tr>
	<tr>
		<td colspan="6">
		    <table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TTareas" align="left" width="100%" onClick="javascript:verocultar(panel2)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TTareas');" onMouseout="bcolor('#8f9ba9','TTareas');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Tareas</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>
				<tr>
				    <td>	
					 	<div id="panel2" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="TextRow02">
								<td colspan="4" align="right"><input type="button" name="addtareas" value="Agregar" onClick="javascript:openwin('tarea_config.jsp')">&nbsp;</td>
							</tr>
							<tr class="TextRow01">								
							    <td width="10%">&nbsp;</td>
								<td width="15%">&nbsp;C&oacute;digo</td>
								<td width="65%">&nbsp;Descripci&oacute;n</td>
								<td width="10%">&nbsp;</td>								
							</tr> 
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('tarea_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('tarea_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('tarea_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>							
						</table>
					    </div>
		            </td>
	            </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="6">
		    <table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TNaturaleza" align="left" width="100%" onClick="javascript:verocultar(panel3)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TNaturaleza');" onMouseout="bcolor('#8f9ba9','TNaturaleza');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Naturaleza de las Tareas</td>
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
								<td colspan="4" align="right"><input type="button" name="addnaturaleza" value="Agregar" onClick="javascript:openwin('naturaleza_config.jsp')">&nbsp;</td>
							</tr>
							<tr class="TextRow01">								
							    <td width="10%">&nbsp;</td>
								<td width="15%">&nbsp;C&oacute;digo</td>
								<td width="65%">&nbsp;Descripci&oacute;n</td>
								<td width="10%">&nbsp;</td>								
							</tr> 
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('naturaleza_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('naturaleza_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('naturaleza_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>							
						</table>
					    </div>
		            </td>
	            </tr>
			</table>
		</td>
	</tr>	
</table>
<%@ include file="../common/footer.jsp"%>		
</form>
</div>

<!--EDUCACIÓN TAB2-->
<div class="dhtmlgoodies_aTab">
<form name="formEducacion" method="post"><input type="hidden" name="screen" value="2">
<table id="tbl_educacion" width="100%" cellpadding="0" cellspacing="0" border="0" align="center">
	<tr class="TextRow01">
  	    <td colspan="4" align="center">&nbsp;Cargo&nbsp;<input type="text" name="cargo1" size="5" value="" readonly=""><input type="text" name="cargo2" size="60" value="" readonly=""></td>		
	</tr>	
	<tr>
		<td colspan="6">
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TEducacion1" align="left" width="100%" onClick="javascript:verocultar(panel4)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TEducacion1');" onMouseout="bcolor('#8f9ba9','TEducacion1');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Educaci&oacute;n Formal Necesaria</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>	
					    <div id="panel4" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">	
							<tr class="TextRow02">
								<td colspan="4" align="right"><input type="button" name="addeducacion" value="Agregar" onClick="javascript:openwin('educacion_config.jsp')">&nbsp;</td>
							</tr>
							<tr class="TextRow01">								
							    <td width="10%">&nbsp;</td>
								<td width="15%">&nbsp;C&oacute;digo</td>
								<td width="65%">&nbsp;Descripci&oacute;n</td>
								<td width="10%">&nbsp;</td>								
							</tr> 
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('educacion_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('educacion_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('educacion_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>	
						 </table>
					     </div>
		            </td>
	            </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="6">
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TEducacion2" align="left" width="100%" onClick="javascript:verocultar(panel5)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TEducacion2');" onMouseout="bcolor('#8f9ba9','TEducacion2');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Educaci&oacute;n No Formal Necesaria</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>	
					    <div id="panel5" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">	
							<tr class="TextRow02">
								<td colspan="4" align="right"><input type="button" name="addeducacion" value="Agregar" onClick="javascript:openwin('educacion_config.jsp')">&nbsp;</td>
							</tr>
							<tr class="TextRow01">								
							    <td width="10%">&nbsp;</td>
								<td width="15%">&nbsp;C&oacute;digo</td>
								<td width="65%">&nbsp;Descripci&oacute;n</td>
								<td width="10%">&nbsp;</td>								
							</tr> 
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('educacion_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('educacion_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('educacion_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>	
						 </table>
					     </div>
		            </td>
	            </tr>
			</table>
		</td>
	</tr>
</table>		
<%@ include file="../common/footer.jsp"%>
</form>
</div>

<!--EXPERIENCIA TAB3-->
<div class="dhtmlgoodies_aTab">
<form name="formExperiencias" method="post"><input type="hidden" name="screen" value="3">
<table id="tbl_experiencias" width="100%" cellpadding="0" cellspacing="0" border="0" align="center">
	<tr class="TextRow01">
  	    <td colspan="4" align="center">&nbsp;Cargo&nbsp;<input type="text" name="cargo1" size="5" value="" readonly=""><input type="text" name="cargo2" size="60" value="" readonly=""></td>		
	</tr>
	<tr>
		<td colspan="6">
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TExperiencias1" align="left" width="100%" onClick="javascript:verocultar(panel6)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TExperiencias1');" onMouseout="bcolor('#8f9ba9','TExperiencias1');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Experiencia Laboral Previa</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>	
					    <div id="panel6" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">	
							<tr class="TextRow02">
								<td colspan="4" align="right"><input type="button" name="addexperiencia" value="Agregar" onClick="javascript:openwin('experiencia_config.jsp')">&nbsp;</td>
							</tr>
							<tr class="TextRow01">								
							    <td width="10%">&nbsp;</td>
								<td width="15%">&nbsp;C&oacute;digo</td>
								<td width="65%">&nbsp;Descripci&oacute;n</td>
								<td width="10%">&nbsp;</td>								
							</tr> 
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('experiencia_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('experiencia_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('experiencia_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>	
						 </table>
					     </div>
		            </td>
	            </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="6">
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TExperiencias2" align="left" width="100%" onClick="javascript:verocultar(panel7)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TExperiencias2');" onMouseout="bcolor('#8f9ba9','TExperiencias2');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Certificados Necesarios</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>	
					    <div id="panel7" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">	
							<tr class="TextRow02">
								<td colspan="4" align="right"><input type="button" name="addcertificado" value="Agregar" onClick="javascript:openwin('certificado_config.jsp')">&nbsp;</td>
							</tr>
							<tr class="TextRow01">								
							    <td width="10%">&nbsp;</td>
								<td width="15%">&nbsp;C&oacute;digo</td>
								<td width="65%">&nbsp;Descripci&oacute;n</td>
								<td width="10%">&nbsp;</td>								
							</tr> 
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('certificado_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('certificado_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('certificado_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>	
						 </table>
					     </div>
		            </td>
	            </tr>
			</table>
		</td>
	</tr>	
</table>
<%@ include file="../common/footer.jsp"%>		
</form>
</div>

<!--CONOCIMIENTOS TAB4-->
<div class="dhtmlgoodies_aTab">
<form name="formConocimientos" method="post"><input type="hidden" name="screen" value="4">
<table id="tbl_conocimientos" width="100%" cellpadding="0" cellspacing="0" border="0" align="center">
	<tr class="TextRow01">
  	    <td colspan="4" align="center">&nbsp;Cargo&nbsp;<input type="text" name="cargo1" size="5" value="" readonly=""><input type="text" name="cargo2" size="60" value="" readonly=""></td>		
	</tr>	
    <tr>
		<td colspan="6">
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TConocimientos" align="left" width="100%" onClick="javascript:verocultar(panel8)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TConocimientos');" onMouseout="bcolor('#8f9ba9','TConocimientos');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Conocimientos</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>	
					    <div id="panel8" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">	
							<tr class="TextRow02">
								<td colspan="4" align="right"><input type="button" name="addconocimiento" value="Agregar" onClick="javascript:openwin('conocimiento_config.jsp')">&nbsp;</td>
							</tr>
							<tr class="TextRow01">								
							    <td width="10%">&nbsp;</td>
								<td width="15%">&nbsp;C&oacute;digo</td>
								<td width="65%">&nbsp;Descripci&oacute;n</td>
								<td width="10%">&nbsp;</td>								
							</tr> 
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('conocimiento_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('conocimiento_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('conocimiento_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>	
						 </table>
					     </div>
		            </td>
	            </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="6">
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TRequisitos" align="left" width="100%" onClick="javascript:verocultar(panel9)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TRequisitos');" onMouseout="bcolor('#8f9ba9','TRequisitos');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Otros Requisitos</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>	
					    <div id="panel9" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">	
							<tr class="TextRow02">
								<td colspan="4" align="right"><input type="button" name="addrequisito" value="Agregar" onClick="javascript:openwin('requisito_config.jsp')">&nbsp;</td>
							</tr>
							<tr class="TextRow01">								
							    <td width="10%">&nbsp;</td>
								<td width="15%">&nbsp;C&oacute;digo</td>
								<td width="65%">&nbsp;Descripci&oacute;n</td>
								<td width="10%">&nbsp;</td>								
							</tr> 
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('requisito_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('requisito_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>

								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('requisito_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>	
						 </table>
					     </div>
		            </td>
	            </tr>
			</table>
		</td>
	</tr>	
</table>
<%@ include file="../common/footer.jsp"%>		
</form>
</div>

<!--ASPECTOS CUANTITATIVOS TAB5-->
<div class="dhtmlgoodies_aTab">
<form name="formAspectos" method="post"><input type="hidden" name="screen" value="3">
<table id="tbl_aspectos" width="100%" cellpadding="0" cellspacing="0" border="0" align="center">
	<tr class="TextRow01">
  	    <td colspan="4" align="center">&nbsp;Cargo&nbsp;<input type="text" name="cargo1" size="5" value="" readonly=""><input type="text" name="cargo2" size="60" value="" readonly=""></td>		
	</tr>	
	 <tr>
		<td colspan="6">
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TAspectos" align="left" width="100%" onClick="javascript:verocultar(panel10)" style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TAspectos');" onMouseout="bcolor('#8f9ba9','TAspectos');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;Aspectos Cuantitativos</td>
								<td width="2%" align="right">&nbsp;<font style="text-decoration:none; cursor:pointer;">[+]</font>&nbsp;</td>
							</tr>
						</table>		
					</td>
				</tr>	
				<tr>
					<td>	
					    <div id="panel10" style="display:inline;">
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">	
							<tr class="TextRow02">
								<td colspan="5" align="right"><input type="button" name="addaspecto" value="Agregar" onClick="javascript:openwin('aspecto_config.jsp')">&nbsp;</td>
							</tr>
							<tr class="TextRow01">								
							    <td width="10%">&nbsp;</td>
								<td width="15%">&nbsp;C&oacute;digo</td>
								<td width="45%">&nbsp;Descripci&oacute;n</td>
								<td width="20%">&nbsp;Valor</td>
								<td width="10%">&nbsp;</td>								
							</tr> 
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('aspecto_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow01">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('aspecto_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>
							<tr class="TextRow02">								
							    <td>XXXX</td>
								<td>XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
								<td>XXXXXXXXXX XXXXXXXXXX</td>
								<td><a href="javascript:openwin('aspecto_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
							</tr>	
						 </table>
					     </div>
		            </td>
	            </tr>
			</table>
		</td>
	</tr>	
</table>		
<%@ include file="../common/footer.jsp"%>
</form>
</div>

</div>
<script type="text/javascript">
initTabs('dhtmlgoodies_tabView1',Array('Cargo','Tareas','Educación','Experiencias','Conocimientos','Aspectos'),0,'100%','');
</script>

	
<!--STYLE DW-->
<!--*************************************************************************************************************-->
	</td>
</tr>		
</table>
</body>
</html>