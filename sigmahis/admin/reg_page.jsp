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
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("profile_name","");
	}
	else
	{
		if (id == null) throw new Exception("La Página no es válida. Por favor intente nuevamente!");

		sql = "select id, name, qs, status, nvl(comments,' ') comments from tbl_sec_pages where id="+id;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<script language="javascript">
document.title = 'Agregar / Modificar Paginas - '+document.title;

function checkName(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_sec_profiles','profile_name=\''+obj.value+'\'','<%=cdo.getColValue("profile_name")%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - PERFIL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%fb.appendJsValidation("if(checkName(document.form1.name))error++;");%>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("name",cdo.getColValue("name"),true,false,false,40,100,null,null,"onBlur=\"javascript:checkName(this)\"")%></td>
			<td width="15%" align="right"><cellbytelabel>Query String</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("qs",cdo.getColValue("qs"),false,false,false,40,100)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("status","A=Activo,I=Inactivo",cdo.getColValue("status"))%></td>
			<td align="right"><cellbytelabel>Comentarios</cellbytelabel></td>
			<td><%=fb.textarea("comments",cdo.getColValue("comments"),false,false,false,40,5,200)%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="4">&nbsp;</td>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_sec_pages");
	cdo.addColValue("name",request.getParameter("name"));
	cdo.addColValue("qs",request.getParameter("qs"));
	cdo.addColValue("status",request.getParameter("status"));
	cdo.addColValue("comments",request.getParameter("comments"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.setAutoIncCol("id");

		cdo.addPkColValue("id","");
		SQLMgr.insert(cdo);
		id = SQLMgr.getPkColValue("id");
	}
	else
	{
		cdo.setWhereClause("id="+id);

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/list_page.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/list_page.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/list_page.jsp';
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