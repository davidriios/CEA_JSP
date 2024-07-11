<%/*
Require to declare CommonMgr and set the session connection from the page that is calling the header page
*/%>
<%--
<jsp:useBean id="_userName" scope="session" class="java.lang.String" />
<table cellpadding="0" cellspacing="0" width="100%" bgcolor="#5b5b5b">
	<tr>
		<td width="40%"><img src="<%//=request.getContextPath()%>/images/logo.jpg" alt="" border="0" width="100%" height="88"/></td>
		<td width="10%"><img src="<%//=request.getContextPath()%>/images/jabes.gif" alt="" border="0" width="100%" height="88"/></td>
		<td width="50%" align="right" valign="top">
			<table cellpadding="0" cellspacing="0" width="100%" bgcolor="#FFFFFF" height="63">
				<tr>
					<td width="35%" align="right" class="TextUserDetailsLabel">Fecha Hora&nbsp;</td>
					<td width="65%" class="TextUserDetailsValue">&nbsp;<%//=CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")%></td>
				</tr>
				<tr>
					<td align="right" class="TextUserDetailsLabel">Usuario&nbsp;</td>
					<td class="TextUserDetailsValue">&nbsp;<%//=(_userName != null)?_userName:""%></td>
				</tr>
				<tr>
					<td align="right" class="TextUserDetailsLabel">Sistema&nbsp;</td>
					<td class="TextUserDetailsValue">&nbsp;[Inicio]&nbsp;&nbsp;[<a href="<%//=request.getContextPath()%>/logout.jsp" class="TextUserDetailsValue">Cerrar Sesi&oacute;n</a>]&nbsp;&nbsp;[Soporte]</td>
				</tr>	
			</table>
		</td>
	</tr>
</table>		 
--%>