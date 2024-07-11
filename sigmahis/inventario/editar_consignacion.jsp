<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
CommonDataObject cdo = new CommonDataObject();
if (mode == null) mode = "edit";

if (request.getMethod().equalsIgnoreCase("GET")) {
		if (id == null) throw new Exception("Articulo no es válido. Por favor intente nuevamente!");

		sbSql.append("select a.cod_articulo, a.descripcion, nvl(a.consignacion_sino,'N') as isAppropiation from tbl_inv_articulo a where a.cod_articulo = ");
		sbSql.append(id);
		sbSql.append(" order by a.cod_articulo, a.descripcion");
		cdo = SQLMgr.getData(sbSql.toString());
		//if (cdo != null && !cdo.getColValue("isAppropiation").equalsIgnoreCase("S")) throw new Exception("Sólo para Artículos tipo Consignación!!");
		 
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EDITAR CONSIGNACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<% fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST); %>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader02">
			<td width="15%" align="right">C&oacute;digo:&nbsp;</td>
			<td width="20%"><%=cdo.getColValue("cod_articulo")%></td>
			<td width="15%" align="right">Descripci&oacute;n:&nbsp;</td>
			<td width="50%"><%=cdo.getColValue("descripcion")%></td>
		</tr>
		<tr class="TextHeader01">
			<td align="right">Consignaci&oacute;n:&nbsp;</td>
			<td colspan="3"><%=fb.checkbox("isAppropiation","S",(cdo.getColValue("isAppropiation") != null && cdo.getColValue("isAppropiation").equalsIgnoreCase("S")),false,null,null,null)%></td>
		</tr>
		<tr class="TextHeader01">
			<td align="right">Justificacion</td>
			<td colspan="3"><%=fb.textarea("comments","",true,false,false,80,5,2000,null,"","")%></td>
		</tr><!---->
		<tr class="TextRow02">
			<td colspan="4" align="center"><font class="RedTextBold">Esta actualizaci&oacute;n cambia el tipo de art&iacute;culo a <%=(cdo.getColValue("isAppropiation").equalsIgnoreCase("S")?"NO":"SI")%> CONSIGNACION,</br>por lo que puede afectar el hist&oacute;rico de movimiento del art&iacute;culo y los informes relacionados!!</font></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="center">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
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
} else {

  cdo = new CommonDataObject();
  cdo.setTableName("tbl_inv_articulo");
	if (request.getParameter("isAppropiation") == null) cdo.addColValue("consignacion_sino","N");
	else cdo.addColValue("consignacion_sino",request.getParameter("isAppropiation"));
  cdo.setWhereClause("cod_articulo = "+id);
  
  cdo.addColValue("cambio_consig",request.getParameter("comments"));

	if (mode.equalsIgnoreCase("edit")) {
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.update(cdo);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.close();
<% } else throw new Exception(SQLMgr.getErrMsg()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>