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
900071	AGREGAR TIPO DE ALQUILER
900072	MODIFICAR TIPO DE ALQUILER
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900071") || SecMgr.checkAccess(session.getId(),"900072"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
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
		if (id == null) throw new Exception("El Tipo de Alquiler no es v�lido. Por favor intente nuevamente!");

		sql = "SELECT cod_tipo_alq as codigo, descripcion FROM tbl_cxc_tipo_alquiler WHERE cod_tipo_alq="+id+" and compania="+(String) session.getAttribute("_companyId");
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
document.title="Tipo Alquiler Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipo Alquiler Edici�n - "+document.title;
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
				<td width="15%">C&oacute;digo</td>
				<td width="85%"><%=id%></td>				
			</tr>							
			<tr class="TextRow01">
				<td>Nombre</td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,false,45)%></td>
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
  id = request.getParameter("id");
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_cxc_tipo_alquiler");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));   
  
  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());  
  if (mode.equalsIgnoreCase("add"))
  {    
	cdo.addColValue("usuario_creacion",UserDet.getUserEmpId()); 
    cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")); 
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
    cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
 	cdo.setAutoIncCol("cod_tipo_alq");
	cdo.addPkColValue("cod_tipo_alq","");
	SQLMgr.insert(cdo);
	id = SQLMgr.getPkColValue("cod_tipo_alq");	
  }
  else
  {
    cdo.addColValue("usuario_modificacion",UserDet.getUserEmpId()); 
    cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")); 
    cdo.setWhereClause("cod_tipo_alq="+request.getParameter("id")+" and compania="+(String) session.getAttribute("_companyId"));
	
	SQLMgr.update(cdo);
  }
  ConMgr.clearAppCtx(null);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/tiposalquileres_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/tiposalquileres_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/tiposalquileres_list.jsp';
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