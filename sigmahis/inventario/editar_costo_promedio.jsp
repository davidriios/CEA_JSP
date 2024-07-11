<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String id = request.getParameter("id");
ArrayList al = new ArrayList();
if (mode == null) mode = "edit";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (id == null) throw new Exception("Articulo no es válido. Por favor intente nuevamente!");

		sbSql.append("select distinct a.cod_articulo, a.descripcion, b.precio from tbl_inv_articulo a, tbl_inv_inventario b where a.cod_articulo = b.cod_articulo and a.compania = b.compania and a.cod_articulo = ");
		sbSql.append(id);
		sbSql.append(" order by a.cod_articulo, a.descripcion");
		al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario - '+document.title;
function verCosto(){
	var precio = document.form1.precio.value;
	if(precio=='') {
		alert('Introduzca precio!');
		return false;
	} else return true;

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EDITAR COSTO PROMEDIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
		<tr>
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr class="TextHeader01">
			<td align="right">Costo Promedio:&nbsp;</td>
			<td colspan="2">&nbsp;
			<%=fb.decBox("precio","",false,false,false,10,"11.10")%>
			</td>
		</tr>
		<tr class="TextHeader02">
			<td align="center">C&oacute;digo</td>
			<td>Descripci&oacute;n</td>
			<td align="center">Precio</td>
		</tr>
		<%
		for(int i = 0; i<al.size(); i++){
			cdo = (CommonDataObject) al.get(i);
		%>

		<tr class="TextRow02">
			<td align="center"><%=cdo.getColValue("cod_articulo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%></td>
		</tr>
		<%}%>
		<tr class="TextRow02">
			<td colspan="4" align="center"><font class="RedTextBold">Esta actualizaci&oacute;n reemplaza Costo promedio y Costo por almac&eacute;n</font></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="center">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
<%fb.appendJsValidation("if(!verCosto()) error++;");%>
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
	sbSql = new StringBuffer();
	sbSql.append("call sp_inv_costo_promedio(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", ");
	sbSql.append(request.getParameter("id"));
	sbSql.append(", ");
	sbSql.append(request.getParameter("precio"));
	sbSql.append(", '");
	sbSql.append((String) session.getAttribute("_userName"));
	sbSql.append("')");

	if (mode.equalsIgnoreCase("edit"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.execute(sbSql.toString());
		ConMgr.clearAppCtx(null);
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