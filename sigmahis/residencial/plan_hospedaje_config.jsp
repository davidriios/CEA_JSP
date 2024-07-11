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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
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
		if (id == null) throw new Exception("El Plan de hospedaje no es v�lido. Por favor intente nuevamente!");

sql = "select codigo, descripcion, estado, usuario_creacion, usuario_modificacion, fecha_creacion, fecha_modificacion from tbl_res_planes where codigo="+id;
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
document.title="Residencial Planes de hospedaje - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Residencial Planes de hospedaje "+document.title;
<%}%>

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RESIDENCIAL - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%System.out.println("*********************************El valor de mode es:"+request.getParameter("mode"));%>
			<tr>	
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>			
			<tr class="TextRow01" >
				<td width="20%">&nbsp;C&oacute;digo</td>
				<td width="80"><%=id%>										
			<%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
			</td>
		<%//}%>
			</tr>							
			<tr class="TextRow01" >
				<td>&nbsp;Descripcion</td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,45)%></td>
			</tr>			
			<tr class="TextRow01">
				<td>&nbsp;Estado</td>
				<td> <%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%></td>
			</tr>
							
			<tr class="TextRow02">
					<td align="right" colspan="2">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
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
   String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	 String baction = request.getParameter("baction");
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_res_planes");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("estado",request.getParameter("estado"));
 
  if (mode.equalsIgnoreCase("add"))
  {
		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");
    cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_creacion","sysdate");
    SQLMgr.insert(cdo);
		id = SQLMgr.getPkColValue("codigo");	
  }
  else
  {
   cdo.setWhereClause("codigo="+request.getParameter("id"));
   cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
   cdo.addColValue("fecha_modificacion","sysdate");
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/residencial/plan_hopedaje_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/residencial/plan_hopedaje_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/residencial/plan_hopedaje_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))																					
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>