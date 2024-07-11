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
String tipo=request.getParameter("tipo");

boolean viewMode=false;
if (mode == null) mode = "add";
if(mode.trim().equals("view"))viewMode=true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("Mantener Tipos de Comprobantes no es válido. Por favor intente nuevamente!");
		sql = "SELECT a.codigo_comprob as codigo, a.descripcion, a.cod_modulo modulo,estado,usado_por,a.group_type,a.nombre_corto,tipo from tbl_con_clases_comprob a where a.codigo_comprob="+id+" and tipo ='"+tipo+"'";
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
document.title="Mantener Tipos de Comprobantes - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Mantener Tipos de Comprobantes - Edición - "+document.title;
<%}%>
function addModulo(){ abrir_ventana1('tipocomprobante_modulos_list.jsp?id=1');}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENER TIPOS DE COMPROBANTES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
				<td width="20%">C&oacute;digo</td>
				<td width="80%"><%=id%></td>
			
			</tr>	
			<tr class="TextRow01" >
				<td>Tipo</td>
				<td><%=fb.select("tipo","C=CONTABILIDAD,P=PLANILLA",cdo.getColValue("tipo"),false,(viewMode||!mode.trim().equals("add")),0,"Text10",null,"")%></td>
			</tr>						
			<tr class="TextRow01" >
				<td>Descripcion</td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,viewMode,56,100)%></td>
			</tr>
			<tr class="TextRow01" >
				<td>Nombre Corto</td>
				<td><%=fb.textBox("nombre_corto",cdo.getColValue("nombre_corto"),true,false,viewMode,56,50)%></td>
			</tr>
			<tr class="TextRow01" >
				<td>Estado</td>
				<td><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"),false,viewMode,0,"Text10",null,"")%></td>
			</tr>
			<tr class="TextRow01" >
				<td>Grupo</td>
				<td><%=fb.select(ConMgr.getConnection(), "select id, descripcion,id||' - '||descripcion from tbl_con_group_comprob where estado ='A' ", "group_type", cdo.getColValue("group_type"),false,false,0)%></td>
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
  
  cdo.setTableName("tbl_con_clases_comprob");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  if (request.getParameter("moduloCode") != null)
  cdo.addColValue("cod_modulo",request.getParameter("moduloCode"));
  
  cdo.addColValue("estado",request.getParameter("estado"));
  cdo.addColValue("group_type",request.getParameter("group_type"));
  cdo.addColValue("nombre_corto",request.getParameter("nombre_corto"));
  
  if (mode.equalsIgnoreCase("add"))
  {
  	cdo.addColValue("tipo",request.getParameter("tipo"));
	cdo.addColValue("usado_por","U");
    cdo.setAutoIncCol("codigo_comprob");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("codigo_comprob="+request.getParameter("id")+" and tipo='"+tipo+"'");
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/tipos_comprobantes_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/tipos_comprobantes_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/tipos_comprobantes_list.jsp';
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