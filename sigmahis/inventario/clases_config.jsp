
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
<jsp:useBean id="_companyId" scope="session" class="java.lang.String"/>
<%
/**
==================================================================================
200013	VER LISTA DE CLASES
200015	AGREGAR CLASE
200016	MODIFICAR CLASE
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200015") || SecMgr.checkAccess(session.getId(),"200016"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
//CommonDataObject cdo= new CommonDataObject();
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		classCode = "0";
		cdo.addColValue("code","0");
	}
	else
	{
		if (familyCode == null || classCode == null) throw new Exception("La Clase por Articulos no es válido. Por favor intente nuevamente!");

		sql = "select a.compania, a.cod_flia as codes, a.cod_clase as code, a.descripcion as name, b.cod_flia as codi,b.nombre as nombre, nvl(a.incremento_venta,'N') as incremento_venta, a.porc_incremento from tbl_inv_clase_articulo a, tbl_inv_familia_articulo b where a.compania=b.compania and a.cod_flia=b.cod_flia and a.cod_flia="+familyCode+" and a.cod_clase="+classCode+" and a.compania = "+(String) session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
	}

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Clase por Articulos - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Clase por Articulos - Edición - "+document.title;
<%}%>
</script>
<script>
function family()
{
	abrir_ventana1('../inventario/list_family.jsp');
}

$(document).ready(function(){
	$("#save").click(function(e){
		if ($("#incremento_venta").is(":checked") && !$("#porc_incremento").val()){
			CBMSG.error("Por favor indique el porcentaje de incremento!");
			return false;
		}
		else $("#form1").submit();
	});
	
	$("#porc_incremento").click(function(e){
	  $(this).select();
	});
});
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLASE POR ARTICULOS"></jsp:param>
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
				<tr class="TextRow01" >
					<td width="17%">&nbsp;Familia</td>
					<td width="83%">&nbsp;<%=fb.textBox("codes",cdo.getColValue("codes"),false,false,true,10)%>
					<%=fb.textBox("nombre",cdo.getColValue("nombre"),false,false,true,35)%>
					<%
					if (mode.equalsIgnoreCase("add"))
					{
					%>
					<%=fb.button("fami","...",true,false,null,null,"onClick=\"javascript:family();\"")%>
					<%
					}
					%>
					</td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;Clase</td>
					<td>&nbsp;<%=fb.textBox("code",cdo.getColValue("code"),false,false,true,10)%>
					<%=fb.textBox("name",cdo.getColValue("name"),true,false,false,35)%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;Incremento en Precio de Venta&nbsp;</td>
					<td><%=fb.checkbox("incremento_venta","S",(cdo.getColValue("incremento_venta") != null && cdo.getColValue("incremento_venta").equalsIgnoreCase("S")),false)%>Porcentaje<%=fb.decBox("porc_incremento",cdo.getColValue("porc_incremento"),false,false,false,3,3)%></td>
				</tr>
				<%--<tr>
					<td colspan="2">
						<table width="100%" cellpadding="0" cellspacing="1">
							<tr class="TextRow01">
								<td colspan="4">&nbsp;Vida &Uacute;til estimada para esta clase de art&iacute;culos....</td>
							</tr>
							<tr class="TextRow01">
								<td align="right" width="17%">&nbsp;M&iacute;nima</td>
								<td width="33%"><%//=fb.intBox("min",cdo.getColValue("min"),false,false,true,15)%>&nbsp;a&ntilde;os</td>
								<td align="right" width="15%">&nbsp;M&aacute;xima</td>
								<td width="35%"><%//=fb.intBox("max",cdo.getColValue("max"),false,false,true,15)%>&nbsp;a&ntilde;os </td>
							</tr>
						</table>
					</td>
				</tr>--%>
				<tr class="TextRow02">
					<td colspan="2" align="right"> <%=fb.button("save","Guardar",true,false)%>
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

    cdo.setTableName("tbl_inv_clase_articulo");
	cdo.addColValue("descripcion",request.getParameter("name"));
	if (request.getParameter("incremento_venta") == null) cdo.addColValue("incremento_venta","N");
	else cdo.addColValue("incremento_venta",request.getParameter("incremento_venta"));
	cdo.addColValue("porc_incremento",request.getParameter("porc_incremento"));

	cdo.setCreateXML(true);
	cdo.setFileName("itemClass.xml");
	cdo.setOptValueColumn("cod_clase");
	cdo.setOptLabelColumn("cod_clase||' - '||descripcion");
	cdo.setKeyColumn("compania||'-'||cod_flia");
	cdo.setXmlWhereClause("");
	cdo.setXmlOrderBy("descripcion, cod_clase");
	

  if (mode.equalsIgnoreCase("add"))
  {
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("cod_flia",request.getParameter("codes"));
		cdo.setAutoIncCol("cod_clase");
		cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_flia="+request.getParameter("codes"));

		SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_flia="+request.getParameter("codes")+" and cod_clase="+request.getParameter("code"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/clases_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/clases_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/clases_list.jsp';
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
