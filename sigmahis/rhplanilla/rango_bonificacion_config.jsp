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
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String r_ini = request.getParameter("r_ini");
String r_fin = request.getParameter("r_fin");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	}
	else
	{
		if (r_ini == null && r_fin == null) throw new Exception("Rangos de Bonificación por Jubilaci&oacute;n o Pensión no válidos. Por favor intente nuevamente!");

		sql = "select compania, rango_inicial as inicial, rango_final as final, bonificacion from tbl_pla_rango_bonif_jub where compania = "+(String) session.getAttribute("_companyId")+" and rango_inicial = "+r_ini +" and rango_final = "+r_fin;
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Rango de Bonificación por Jubilación o Pensión - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Rango de Bonificación por Jubilación o Pensión - Editar - "+document.title;
<%}%>

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RANGO DE BONIFICACIÓN POR JUBILACIÓN O PENSIÓN"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
		
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>	
			<TR class="TextHeader">
				<TD colspan="2">&nbsp;Tabla de Rangos de Bonificaci&oacute;n por Jubilaci&oacute;n o Pensi&oacute;n
				</TD>
			</TR>
			<tr class="TextRow01">
				<td width="15%">Desde</td>
				<td width="85%"><%=fb.intBox("inicial",cdo.getColValue("inicial"),false,false,false,15)%> 	</td>
			</tr>
			<tr class="TextRow01">
				<td>Hasta</td>
				<td><%=fb.intBox("final",cdo.getColValue("final"),false,false,false,15)%></td>
			</tr>		
			<tr class="TextRow01">
				<td>&nbsp;Bonificaci&oacute;n</td>
				<td><%=fb.decBox("bonificacion",cdo.getColValue("bonificacion"),false,false,false,10)%></td>
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

  cdo.setTableName("tbl_pla_rango_bonif_jub");
  cdo.addColValue("rango_inicial",request.getParameter("inicial"));
  cdo.addColValue("rango_final",request.getParameter("final"));
  cdo.addColValue("bonificacion",request.getParameter("bonificacion"));   
  
    
  if (mode.equalsIgnoreCase("add"))
  {   
  	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		SQLMgr.insert(cdo);
  }
  else
  {
   	cdo.setWhereClause("compania = "+(String) session.getAttribute("_companyId")+" and rango_inicial = "+request.getParameter("inicial")+" and rango_final = "+request.getParameter("final"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/rango_bonificacion_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/rango_bonificacion_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/rango_bonificacion_list.jsp';
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