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
	window.open(val,"newwindow1",opciones);
}
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">document.title="Comisión por Tipo Analista Edición - "+document.title;</script>
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
					<td id="TTipo" align="left" width="100%" onClick="javascript:verocultar(panel0)"style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TTipo');" onMouseout="bcolor('#8f9ba9','TTipo');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;<cellbytelabel>Tipo de Analista</cellbytelabel></td>
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
							<td width="12%">&nbsp;&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td> 
							<td width="38%">&nbsp;<input type="text" name="codigo" size="20" value="" readonly=""></td>
							<td width="13%">&nbsp;&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel></td> 
							<td width="37%">&nbsp;<input type="text" name="descripcion" size="45" value="">&nbsp;<input type="button" name="btndesc" value="..."></td>														
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
					<td id="TComision" align="left" width="100%" onClick="javascript:verocultar(panel1)"style=" background-color:#8f9ba9;" onMouseover="bcolor('#5c7188','TComision');" onMouseout="bcolor('#8f9ba9','TComision');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="98%">&nbsp;<cellbytelabel>Comsiones</cellbytelabel></td>
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
		                       <td colspan="7" align="right"><input type="button" name="btnaddtipo" value="Agregar" onClick="javascript:openwin('comision_config.jsp');"></td>
	                        </tr>
							<tr class="TextRow01">
							    <td width="5%">&nbsp;</td>
								<td width="15%">&nbsp;<cellbytelabel>Sec</cellbytelabel>.</td>
								<td width="15%">&nbsp;<cellbytelabel>Rango Inicial</cellbytelabel></td>
								<td width="15%">&nbsp;<cellbytelabel>Rango Final</cellbytelabel></td>
								<td width="25%">&nbsp;<cellbytelabel>Tipo Valor</cellbytelabel></td>	
								<td width="15%">&nbsp;<cellbytelabel>Comsi&oacute;n</cellbytelabel></td>
								<td width="10%">&nbsp;</td>								
							</tr>
							<tr class="TextRow02">
								<td align="center">1</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>								
							    <td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td><a href="javascript:openwin('comision_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></td>
							</tr>
							<tr class="TextRow01">
								<td align="center">2</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>								
							    <td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td><a href="javascript:openwin('comision_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></td>
							</tr>
							<tr class="TextRow02">
								<td align="center">3</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>								
							    <td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
								<td>&nbsp;XXXXXXXXXX</td>
								<td><a href="javascript:openwin('comision_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>
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