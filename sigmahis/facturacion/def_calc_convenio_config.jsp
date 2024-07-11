
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
200017	VER LISTA DE TIPOS DE AJUSTES
200019	AGREGAR TIPO DE AJUSTE
200020	MODIFICAR TIPO DE AJUSTE
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200019") || SecMgr.checkAccess(session.getId(),"200020"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
		if (id == null) throw new Exception("El Tipo Ajuste no es válido. Por favor intente nuevamente!");

		sql="select codigo as code, descripcion, program_unit, comentario, comentario2, estado, comentario3  from tbl_adm_calculo_beneficio where codigo="+id;
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
document.title="Tipo Ajuste - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipo Ajuste - Edición - "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="TIPO AJUSTE"></jsp:param>
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
				<tr class="TextHeader">
					<td colspan="2" align="left"><cellbytelabel><cellbytelabel>Tipo Ajuste</cellbytelabel></cellbytelabel></td>
				</tr>	
				<tr class="TextRow01">
					<td width="17%" align="right"><cellbytelabel><cellbytelabel>C&oacute;digo</cellbytelabel></cellbytelabel>&nbsp;</td>
					<td width="83%"><%=id%></td>
				</tr>							
				<tr class="TextRow01">
					<td align="right"><cellbytelabel><cellbytelabel>Descripci&oacute;n</cellbytelabel></cellbytelabel>&nbsp;</td>
					<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,60)%></td>
				</tr>					
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Program Unit</cellbytelabel></td>
					<td>
					 <%=fb.textarea("program_unit",cdo.getColValue("program_unit"),false,false,false,70,7,"text10","","")%>
					</td>
				</tr>					
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Comentarios del Programador</cellbytelabel></td>
					<td>
			          <%=fb.textarea("comentario",cdo.getColValue("comentario"),false,false,false,70,7,"text10","","")%>
					</td>
				</tr>
					<tr class="TextRow01">
					<td align="right"><cellbytelabel>Comentarios para los Usuarios</cellbytelabel></td>
					<td>
			          <%=fb.textarea("comentario2",cdo.getColValue("comentario2"),false,false,false,70,7,"text10","","")%>
					</td>
				
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Estado</cellbytelabel></td>
					<td>
					  <%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"))%>
					  </td>
				</tr>
					<tr class="TextRow01">
					<td align="right"><cellbytelabel>Otros Comentarios</cellbytelabel></td>
					<td>
			          <%=fb.textarea("comentario3",cdo.getColValue("comentario3"),false,false,false,70,7,"text10","","")%>
					</td>
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

  cdo.setTableName("tbl_adm_calculo_beneficio");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  if( request.getParameter("program_unit") != null) cdo.addColValue("program_unit",request.getParameter("program_unit")); 
  if( request.getParameter("comentario") != null) cdo.addColValue("comentario",request.getParameter("comentario")); 
  if( request.getParameter("comentario2") != null) cdo.addColValue("comentario2",request.getParameter("comentario2")); 
  cdo.addColValue("estado",request.getParameter("estado")); 
  if( request.getParameter("comentario3") != null) cdo.addColValue("comentario3",request.getParameter("comentario3"));
  
  if (mode.equalsIgnoreCase("add"))
  {
	cdo.setAutoIncCol("codigo");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("codigo="+request.getParameter("id"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/def_calc_convenio_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/def_calc_convenio_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/def_calc_convenio_list.jsp';
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
