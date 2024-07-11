<%
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	//	if (SecMgr.checkAccess(session.getId(),"0")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function openwin(val)
{
    var opciones="toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=1002,height=250,top=5,left=default";
	window.open(val,"newwindow",opciones);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<script language="javascript">document.title="Tipo de Servicios - "+document.title;</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACI&Oacute;N - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr>
		<td colspan="4" align="right"><a href="javascript:openwin('tiposervicio_config.jsp');" ><font class="Link00">[ Registrar Nuevo Tipo de Servicio ]&nbsp;</font></a></td>
	</tr>	
	<tr class="TextFilter">
		<td width="13%">&nbsp;C&oacute;digo</td>
		<td width="17%"><input type="text" name="codigo" size="20">&nbsp;<input type="button" name="btncod" value="Ir"></td>
		<td width="9%">&nbsp;Descripci&oacute;n</td>
		<td width="26%"><input type="text" name="nombre" size="35">&nbsp;<input type="button" name="btnnom" value="Ir"></td>
	</tr>
</table>
<br/>	
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><font class="Link00">&nbsp;[ Imprimir Lista ]&nbsp;</font></td>
	</tr>	
</table>	
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr class="TextPager">
		<form name="frmBack01">
		<td width="10%" align="left"  class="TableTopBorder">
			<input type="hidden" name="nextVal" 			value="<%//=nxtVal-recsPerPage%>">
			<input type="hidden" name="previousVal" 		value="<%//=preVal-recsPerPage%>">
			<input type="hidden" name="searchQuery" 		value="sQ">
			<%
			//if(preVal!=1)
			//{
			%>
			<input type="submit" name="previous" value="<<-">
			<%
			//}
			%>
		</td>
		</form>
		<td width="40%" align="left"  class="TableTopBorder"><cellbytelabel>Total registers</cellbytelabel>&nbsp;000<%//=rowCount%></td>
		<td width="40%" align="right" class="TableTopBorder"><cellbytelabel>Registers from</cellbytelabel> 00<%//=pVal%> to 000<%//=nVal%></td>
		<form name="frmFwrd01">
		<td width="10%" align="right" class="TableTopBorder">
			<input type="hidden" name="nextVal" 		value="<%//=nxtVal+recsPerPage%>">
			<input type="hidden" name="previousVal" 	value="<%//=preVal+recsPerPage%>">
			<input type="hidden" name="searchQuery" 	value="sQ">
			<%
			//if(!(rowCount<=nxtVal))
			//{
			%>
			<input type="submit" name="next" value="->>">
			<%
			//}
			%>
		</td>
		</form>	
	</tr>
</table>		

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader">
	    <td width="10%">&nbsp;</td>
		<td width="25%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="55%">&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
		<td width="10%">&nbsp;</td>
	</tr>
	<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver','TextRow01')" onMouseOut="setoutc(this,'TextRow01')">
		<td align="center">1</td>
		<td>&nbsp;XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX </td>
		<td>&nbsp;<a href="javascript:openwin('tiposervicio_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>			
	</tr>							
	<tr class="TextRow02" onMouseOver="setoverc(this,'TextRowOver','TextRow01')" onMouseOut="setoutc(this,'TextRow01')">
		<td align="center">2</td>
		<td>&nbsp;XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;<a href="javascript:openwin('tiposervicio_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>		
	</tr>							
	<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver','TextRow01')" onMouseOut="setoutc(this,'TextRow01')">
		<td align="center">3</td>
		<td>&nbsp;XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;<a href="javascript:openwin('tiposervicio_config.jsp')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></td>		
	</tr>							
</table>		

<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr class="TextPager">
		<form name="frmBack02">
		<td width="10%" align="left"  class="TableBottomBorder">
			<input type="hidden" name="nextVal" 			value="<%//=nxtVal-recsPerPage%>">
			<input type="hidden" name="previousVal" 		value="<%//=preVal-recsPerPage%>">
			<input type="hidden" name="searchQuery" 		value="sQ">
			<%
			//if(preVal!=1)
			//{
			%>
			<input type="submit" name="previous" value="<<-">
			<%
			//}
			%>
		</td>	
		</form>
		<td width="40%" align="left"  class="TableBottomBorder">&nbsp;</td>
		<td width="40%" align="right" class="TableBottomBorder">&nbsp;</td>
		<form name="frmFwrd02">
		<td width="10%" align="right" class="TableBottomBorder">
			<input type="hidden" name="nextVal" 		value="<%//=nxtVal+recsPerPage%>">
			<input type="hidden" name="previousVal" 	value="<%//=preVal+recsPerPage%>">
			<input type="hidden" name="searchQuery" 	value="sQ">
			<%
			//if(!(rowCount<=nxtVal))
			//{
			%>
			<input type="submit" name="next" value="->>">
			<%
			//}
			%>
		</td>
		</form>	
	</tr>
</table>


<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
//} else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
//} else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>