<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================

================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("La Analista / Cobranza no es válido. Por favor intente nuevamente!");

sql = "";
		cdo = SQLMgr.getData(sql);
	}



%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Analista / Cobranza - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Analista /Cobranza- Edición - "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR COBRAR - MANTENIMIENTO - ANALISTA / COBRANZA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<tr>	
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>			
			<tr class="TextRow01" >
				<td width="15%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width="85%">&nbsp;<%=id%></td>
			
			</tr>							
			<tr class="TextRow01" >
				<td>&nbsp;<cellbytelabel>Tipo</cellbytelabel></td>
				<td><%=fb.select("tipo","E=EMPLEADO,M=EMPRESA",cdo.getColValue("tipo"))%></td>
			</tr>
			
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Empleado</cellbytelabel></td>
				<td><%=fb.intBox("code1",cdo.getColValue("code1"),false,false,false,2)%><%=fb.intBox("code2",cdo.getColValue("code2"),false,false,false,2)%><%=fb.intBox("code3",cdo.getColValue("code3"),false,false,false,3)%><%=fb.intBox("code4",cdo.getColValue("code4"),false,false,false,3)%><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,false,30)%>
				<%=fb.button("btnempleado","IR",true,false,null,null,"onClick=\"javascript:agregar();\"")%>
				</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Empresa</cellbytelabel></td>
				<td><%=fb.intBox("codecia",cdo.getColValue("codecia"),false,false,false,5)%><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,false,53)%><%=fb.button("btnempleado","IR",true,false,null,null,"onClick=\"javascript:CIA();\"")%>
			</tr>	
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Encargado</cellbytelabel></td>
				<td><%=fb.textBox("encargado",cdo.getColValue("encargado"),false,false,false,64)%></td>
			</tr>					
			<tr class="TextRow02">
				<td colspan="2" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>		
		</td>
	</tr>
</table>		

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET 
else
{
  cdo = new CommonDataObject();

  
  if (mode.equalsIgnoreCase("add"))
  {

 

	SQLMgr.insert(cdo);
  }
  else
  {
   

	SQLMgr.update(cdo);
  }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/analista_cobranza_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/analista_cobranza_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/analista_cobranza_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>