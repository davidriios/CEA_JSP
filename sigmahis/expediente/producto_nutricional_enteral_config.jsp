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
String grupo=request.getParameter("grupo");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";
if (tipo == null) tipo = "";
if (grupo == null) grupo = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("La pregunta pre-operatoria no es válida. Por favor intente nuevamente!");

sql = "select codigo, descripcion, estado, orden, status, presentacion, presentacion_desc, unidad_entrega, alerta from tbl_sal_productos_nutricional where codigo="+id;
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
document.title="Producto Nutricional Enteral - Agregar- "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Producto Nutricional Enteral - Edición - "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO - PRODUCTOS NUTRICIONALES ENTERALES"></jsp:param>
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
				<td width="15%">&nbsp;<cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
				<td width="85%">&nbsp;<%=id%></td>
			
			</tr>							
			<tr class="TextRow01" >
				<td>&nbsp;<cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,150,500)%></td>
			</tr>
            
            <tr class="TextRow01" >
				<td>&nbsp;<cellbytelabel id="2">Estado Producto</cellbytelabel></td>
				<td>
                    <%=fb.select("status","LIQUIDA=LIQUIDA,POLVO=POLVO,ENVASE=ENVASE,SOBRE=SOBRE",cdo.getColValue("grupo",grupo))%>
                </td>
			</tr>
            
            <tr class="TextRow01" >
				<td>&nbsp;<cellbytelabel id="2">Presentaci&oacute;n</cellbytelabel></td>
				<td>
                    <%=fb.intBox("presentacion",cdo.getColValue("presentacion"),true,false,false,10,5)%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <%=fb.textBox("presentacion_desc",cdo.getColValue("presentacion_desc"),true,false,false,30,30)%>
                </td>
			</tr>
            
            <tr class="TextRow01" >
				<td>&nbsp;<cellbytelabel id="2">Unidad Entrega</cellbytelabel></td>
				<td>
                    <%=fb.textBox("unidad_entrega",cdo.getColValue("unidad_entrega"),false,false,false,30,30)%>
                </td>
			</tr>
            
            <tr class="TextRow01" >
				<td>&nbsp;<cellbytelabel id="2">Alerta</cellbytelabel></td>
				<td>
                    <%=fb.textBox("alerta",cdo.getColValue("alerta"),false,false,false,30,30)%>
                </td>
			</tr>
			
			<tr class="TextRow01">
			  <td>&nbsp;<cellbytelabel id="3">No. Orden</cellbytelabel></td>
			  <td><%=fb.textBox("orden",cdo.getColValue("orden"),true,false,false,5)%></td>
			</tr>
			<tr class="TextRow01"> 
			   <td>&nbsp;<cellbytelabel id="4">Estado</cellbytelabel></td>
			   <td colspan="2"><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%></td>
			</tr>
            <tr class="TextRow02">
                <td align="right" colspan="2">
                    <cellbytelabel id="5">Opciones de Guardar</cellbytelabel>: 
                    <%=fb.radio("saveOption","N")%><cellbytelabel id="6">Crear Otro</cellbytelabel> 
                    <%=fb.radio("saveOption","O")%><cellbytelabel id="7">Mantener Abierto</cellbytelabel> 
                    <%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="8">Cerrar</cellbytelabel> 
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
  cdo.setTableName("tbl_sal_productos_nutricional");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("status",request.getParameter("status")); 
  cdo.addColValue("estado",request.getParameter("estado")); 
  cdo.addColValue("orden",request.getParameter("orden")); 
  cdo.addColValue("presentacion",request.getParameter("presentacion")); 
  cdo.addColValue("presentacion_desc",request.getParameter("presentacion_desc")); 
  cdo.addColValue("unidad_entrega",request.getParameter("unidad_entrega")); 
  cdo.addColValue("alerta",request.getParameter("alerta")); 
 
  if (mode.equalsIgnoreCase("add")){
        cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");
		SQLMgr.insert(cdo);
		id = SQLMgr.getPkColValue("codigo");
  }
  else{
    cdo.setWhereClause("codigo = "+request.getParameter("id"));
	SQLMgr.update(cdo);
  }
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/producto_nutricional_enteral_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/producto_nutricional_enteral_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/producto_nutricional_enteral_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&tipo=<%=tipo%>&grupo=<%=grupo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>