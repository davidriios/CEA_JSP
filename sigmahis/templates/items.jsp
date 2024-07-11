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
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<script language="javascript">document.title="Name Page "+document.title;</script>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="50%" align="left" background="../images/bgTitle.jpg" height="25"><font class="TextModuleName">&nbsp;&nbsp;&nbsp;MODULE NAME</font></td>
		<td width="50%" align="right" background="../images/bgTitle.jpg" height="25"><font class="TextModuleName">COMPANY NAME</font>&nbsp;&nbsp;&nbsp;</td>
	</tr>		
	<tr><td colspan="2">&nbsp;</td></tr>
</table>

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr>
		<td colspan="4" align="right"><font class="Link00">&nbsp;[Add New Process]&nbsp;</font></td>
	</tr>	
	<tr class="TextFilter">
		<td width="25%">&nbsp;Filter A&nbsp;<input type="text" name="txt" size="15"><input type="button" name="btn" value="Ir"></td>
		<td width="25%">&nbsp;Filter B&nbsp;<input type="text" name="txt" size="15"><input type="button" name="btn" value="Ir"></td>
		<td width="25%">&nbsp;Filter C&nbsp;<select name="slc" ><option value="0" selected>Option 1</option><option value="1">Option B</option></select><input type="button" name="btn" value="Ir"></td>
		<td width="25%">&nbsp;From&nbsp;<input type="text" name="txt" size="5"><input type="button" name="btn" value="..."> &nbsp;To&nbsp;<input type="text" name="txt" size="5"><input type="button" name="btn" value="...">&nbsp;<input type="button" name="btn" value="Ir"></td>
	</tr>
</table>
<br/>	
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="4" align="right"><font class="Link00">&nbsp;[Print This Report]&nbsp;</font></td>
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
		<td width="40%" align="left" class="TableTopBorder">Total registers&nbsp;000<%//=rowCount%></td>
		<td width="40%" align="right" class="TableTopBorder">Registers from 00<%//=pVal%> to 000<%//=nVal%></td>
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
		<td align="left" width="25%">&nbsp;Columm A</td>
		<td align="left" width="25%">&nbsp;Columm B</td>
		<td align="left" width="25%">&nbsp;Columm C</td>
		<td align="left" width="25%">&nbsp;Columm D</td>
	</tr>
	<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver','TextRow01')" onMouseOut="setoutc(this,'TextRow01')">
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
	</tr>							
	<tr class="TextRow02" onMouseOver="setoverc(this,'TextRowOver','TextRow02')" onMouseOut="setoutc(this,'TextRow02')">
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
	</tr>							
	<tr class="TextRow01" onMouseOver="setoverc(this,'TextRowOver','TextRow01')" onMouseOut="setoutc(this,'TextRow01')">
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
		<td>&nbsp;XXXXXXXXXX XXXXXXXXXX</td>
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
		<td width="40%" align="left" class="TableBottomBorder">&nbsp;</td>
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