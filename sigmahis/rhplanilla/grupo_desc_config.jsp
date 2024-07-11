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
800051	AGREGAR GRUPOS DE DESCUENTOS
800052	MODIFICAR GRUPOS DE DESCUENTOS
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800051") || SecMgr.checkAccess(session.getId(),"800052"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
		cdo.addColValue("code","0");
	}
	else
	{
		if (id == null) throw new Exception("El Grupo de Descuento no es válido. Por favor intente nuevamente!");

		sql = "Select cod_grupo as code, nombre, porcentaje, prioridad, descuento_dic as descuento, fecha_creacion, usuario_creacion, fecha_mod, usuario_mod, generar_cheque as emitir from tbl_pla_grupo_descuento where cod_grupo="+id;
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
document.title="Grupo de Descuento- Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Grupo de Descuento- Edición - "+document.title;
<%}%>

function valkey( char,obj ) 
{
var cad=obj.value;
if ( char >= 48 && char <= 57 )
{ } 
else 
{ if ( char == 46 ) 
  { 
  if(cad.indexOf(".")>=0) {window.event.keyCode = 0 ;}
  }
  else
  { window.event.keyCode = 0 ; } 
  return true ;
}
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="GRUPO DE DESCUENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",cdo.getColValue("code"))%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>			
			<tr class="TextRow01" >
				<td width="15%">&nbsp;C&oacute;digo</td>
				<td width="85%">&nbsp;<%=cdo.getColValue("code")%></td>
			
			</tr>							
			<tr class="TextRow01" >
				<td>&nbsp;Nombre</td>
				<td><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,50,30)%></td>
			</tr>		
			<tr class="TextRow01">
				<td>&nbsp;%Salario</td>
				<td><%=fb.decBox("porcentaje",cdo.getColValue("porcentaje"),true,false,false,15,4.2,null,null,"onKeyPress=\"javascript:valkey(window.event.keyCode,this)\"")%> </td>
			</tr>			
			<tr class="TextRow01">
				<td>&nbsp;Prioridad</td>
				<td><%=fb.intBox("prioridad",cdo.getColValue("prioridad"),true,false,false,15,2)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Desc. Dic</td>
				<td><%=fb.select("descuento","S=SI,N=NO", cdo.getColValue("descuento"))%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Emitir Cheque</td>
				<td><%=fb.select("emitir","S=SI,N=NO",cdo.getColValue("emitir"))%></td>
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

  cdo.setTableName("tbl_pla_grupo_descuento");
  cdo.addColValue("nombre", request.getParameter("nombre")); 
  cdo.addColValue("porcentaje", request.getParameter("porcentaje"));
  cdo.addColValue("descuento_dic", request.getParameter("descuento"));
  cdo.addColValue("fecha_mod",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("usuario_mod", (String) session.getAttribute("_userName"));
  cdo.addColValue("generar_cheque",request.getParameter("emitir"));
  cdo.addColValue("prioridad",request.getParameter("prioridad"));
  if (mode.equalsIgnoreCase("add"))
  {
   	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.setAutoIncCol("cod_grupo");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("cod_grupo="+request.getParameter("code"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/grupo_desc_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/grupo_desc_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/grupo_desc_list.jsp';
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