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
900067	AGREGAR UBICACIÓN DEL ALQUILER
900068	MODIFICAR UBICACIÓN DEL ALQUILER
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900067") || SecMgr.checkAccess(session.getId(),"900068"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
		if (id == null) throw new Exception("La Ubicación no es válida. Por favor intente nuevamente!");

		sql = "SELECT ubicacion, nombre FROM tbl_cxc_ubicaciones WHERE ubicacion="+id;
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
document.title="Area Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Area Edición - "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
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
			<tr class="TextRow01">
				<td width="15%">Ubicaci&oacute;n</td>
				<td width="85%"><%=id%></td>				
			</tr>							
			<tr class="TextRow01">
				<td>Nombre</td>
				<td><%=fb.textBox("nombre",cdo.getColValue("nombre"),false,false,false,45)%></td>
			</tr>
			<tr>
				<td colspan="2">
					<jsp:include page="../common/bitacora.jsp" flush="true">
					<jsp:param name="audTable" value="tbl_cxc_ubicaciones"></jsp:param>
					<jsp:param name="audFilter" value="<%="ubicacion="+id%>"></jsp:param>
					</jsp:include>
				</td>
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
  cdo = new CommonDataObject();
  
   
  cdo.setTableName("tbl_cxc_ubicaciones");
  cdo.addColValue("nombre",request.getParameter("nombre")); 
    
  if (mode.equalsIgnoreCase("add"))
  {
    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 	cdo.setAutoIncCol("ubicacion");
	cdo.addPkColValue("codigo","");
	SQLMgr.insert(cdo);
	id = SQLMgr.getPkColValue("codigo");
	ConMgr.clearAppCtx(null);
  }
  else
  {
    cdo.setWhereClause("ubicacion="+request.getParameter("id"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/ubicacionalquileres_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/ubicacionalquileres_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/ubicacionalquileres_list.jsp';
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