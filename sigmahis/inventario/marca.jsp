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

String sql="";
String mode = request.getParameter("mode");
String id = request.getParameter("id");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("La Marca de Articulos no es válido. Por favor intente nuevamente!");

		sql="select marca_id, codigo, descripcion, estado from tbl_inv_marca where marca_id = " + id;
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Marcas - "+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - FAMILIA DE ARTICULOS"></jsp:param>
</jsp:include>
<table width="99%" cellpadding="5" cellspacing="0" border="0" align="center">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="2" align="left">&nbsp;Marca de Articulos</td>
		</tr>
		<tr class="TextRow01">
			<td width="19%">&nbsp;C&oacute;digo</td>
			<td width="81%"><%=fb.textBox("codigo",cdo.getColValue("codigo"),true,false,false,10,20)%></td>
		</tr>
		<tr class="TextRow01">
			<td>&nbsp;Descripci&oacute;n</td>
			<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,100,200)%></td>
		</tr>
		<tr class="TextRow01">
			<td>&nbsp;Estado</td>
			<td><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"), false, false, 0)%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="2" align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
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

	cdo.setTableName("tbl_inv_marca");
	cdo.addColValue("codigo",request.getParameter("codigo"));
	cdo.addColValue("descripcion",request.getParameter("descripcion"));
	cdo.addColValue("estado",request.getParameter("estado"));

	cdo.setCreateXML(true);
	cdo.setFileName("marca"+session.getAttribute("_companyId")+".xml");
	cdo.setOptValueColumn("marca_id");
	cdo.setOptLabelColumn("marca_id||' - '||descripcion");
	cdo.setKeyColumn("marca_id");
	cdo.setXmlWhereClause("compania = "+session.getAttribute("_companyId"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if (mode.equalsIgnoreCase("add")) {
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.setAutoIncCol("marca_id");
		SQLMgr.insert(cdo);
	} else {
		cdo.setWhereClause("marca_id = "+request.getParameter("id"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/marca_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/marca_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/marca_list.jsp';
<%
	}
%>

	window.close();
<%
} else throw new Exception(SQLMgr.getErrException());
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