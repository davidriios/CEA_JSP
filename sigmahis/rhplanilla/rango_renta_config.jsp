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
boolean viewMode=false;

if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode=true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";		
	}
	else
	{
		//if (id == null) throw new Exception("El Rango de Renta no es válido. Por favor intente nuevamente!");

		sql = "select rango_inicial as inicial, rango_final as final, porcentaje as excede, cargo_fijo as fijo,status,tipo from tbl_pla_rango_renta where id="+id;
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
document.title="Rango de Renta - Agregar "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Rango de Renta - Editar "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="PLANILLA - RANGO DE RENTA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>	
			<tr class="TextHeader">
				<td colspan="2">&nbsp;Tabla de Rangos de Renta</td>
			</tr>	
			<tr class="TextRow01">
				<td width="15%">Id</td>
				<td width="85%"><%=fb.textBox("id",id,false,false,true,15)%></td>				
			</tr>	
			<tr class="TextRow01">
				<td width="15%">Rango Inicial</td>
				<td width="85%"><%=fb.decBox("inicial",cdo.getColValue("inicial"),true,false,viewMode,15)%></td>				
			</tr>							
			<tr class="TextRow01">
				<td>Ranngo Final</td>
				<td><%=fb.decPlusZeroBox("final",cdo.getColValue("final"),true,false,viewMode,15)%></td>
			</tr>	
			<tr class="TextRow01">
				<td>Cargo Fijo</td>
				<td><%=fb.decBox("fijo",cdo.getColValue("fijo"),true,false,viewMode,15)%></td>
			</tr>
			<tr class="TextRow01">
				<td>Porcentaje Excede </td>
				<td><%=fb.decPlusZeroBox("excede",cdo.getColValue("excede"),true,false,viewMode,15)%></td>
			</tr>		
			<tr class="TextRow01">
				<td>Estado</td>
				<td><%=fb.select("status","A=ACTIVO,I=INACTIVO",cdo.getColValue("status"),false,viewMode,0,"Text10",null,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td>Tipo</td>
				<td><%=fb.select("tipo","S=SALARIOS,G=GASTOS DE REP.",cdo.getColValue("tipo"),false,viewMode,0,"Text10",null,null,null,"")%></td>
			</tr>
					
			<tr class="TextRow02">
				<td colspan="2" align="right"> <%=fb.submit("save","Guardar",true,viewMode)%>
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

  cdo.setTableName("TBL_PLA_RANGO_RENTA");
  cdo.addColValue("rango_inicial",request.getParameter("inicial"));   
  cdo.addColValue("rango_final",request.getParameter("final"));
  cdo.addColValue("cargo_fijo",request.getParameter("fijo"));
  cdo.addColValue("porcentaje",request.getParameter("excede"));
  cdo.addColValue("status",request.getParameter("status"));
  cdo.addColValue("tipo",request.getParameter("tipo"));
  cdo.addColValue("id",request.getParameter("id"));
  cdo.addColValue("rango_inicial_real",request.getParameter("inicial")); 

  if (mode.equalsIgnoreCase("add"))
  {   
	cdo.setAutoIncCol("id");
	
	SQLMgr.insert(cdo);
  }
  else
  {
  	cdo.setWhereClause("id="+request.getParameter("id"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/rango_renta_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/rango_renta_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/rango_renta_list.jsp';
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