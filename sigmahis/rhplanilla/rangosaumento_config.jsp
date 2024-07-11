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
		if (id == null) throw new Exception("Rangos de Aumento de por CC no es válido. Por favor intente nuevamente!");

		sql = "select anio, rango_inicial as inicial, rango_final as final, monto, compania, fecha_creacion, usuario_creacion, fecha_mod, usuario_mod from tbl_pla_cc_rango_aumentos";
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
document.title="Rangos de Aumentos por CC - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Rangos de Aumentos por CC - Editar - "+document.title;
<%}%>

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - RANGOS DE AUMENTOS POR CC"></jsp:param>
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
			<TR class="TextHeader">
				<td colspan="2">&nbsp;Tabla de Rangos de Aumentos por CC</td>
			</TR>
			<tr class="TextRow01">
				<td width="20%">&nbsp;Año</td>
				<td width="80%"><%=fb.intBox("anio",cdo.getColValue("anio"),false,false,false,15,4)%> 	</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="2">&nbsp;Años de Antiguedad</td>
			</tr>
			<tr>
				<td colspan="2">
					<table width="100%">
						<tr class="TextRow01">
							<td width="20%">&nbsp;De</td>
							<td width="30%"><%=fb.intBox("inicial",cdo.getColValue("inicial"),false,false,false,10,2)%></td>
							<td width="10%">&nbsp;A</td>
							<td width="40%"><%=fb.intBox("final",cdo.getColValue("final"),false,false,false,10,2)%></td>
						</tr>
					</table>
				</td>
			</tr>	
			<tr class="TextRow01">
				<td>&nbsp;Cantidad a Aumentar</td>
				<td><%=fb.decBox("monto",cdo.getColValue("monto"),false,false,false,10,7)%></td>
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

  cdo.setTableName("tbl_pla_cc_rango_aumentos");
  cdo.addColValue("rango_inicial",request.getParameter("inicial"));   
  cdo.addColValue("rango_final",request.getParameter("final"));
  cdo.addColValue("monto",request.getParameter("monto"));
  cdo.addColValue("fecha_mod",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("usuario_mod",(String) session.getAttribute("_userName"));
    
  if (mode.equalsIgnoreCase("add"))
  {   
  	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
 	cdo.setAutoIncCol("anio");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and rango_inicial="+request.getParameter("inicial"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/rango_aumento_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/rango_aumento_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/rango_aumento_list.jsp';
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