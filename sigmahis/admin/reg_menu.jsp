<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.Menu"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="MenuMgr" scope="page" class="issi.admin.MenuMgr"/>
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
MenuMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
Menu menu = new Menu();
String sql = "";
String mode = request.getParameter("mode");
String parentId = request.getParameter("parentId");
String root = request.getParameter("root");
String id = request.getParameter("id");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		if (parentId == null) throw new Exception("El Menu Padre no es válido. Por favor intente nuevamente!");
		if (root == null) throw new Exception("El Menu Raiz no es válido. Por favor intente nuevamente!");

		if (parentId.equals("0"))
			sql = "select nvl(max(display_order),0) + 1 as displayOrder, "+parentId+" as parentId, 1 as menuLevel, "+root+" as root, nvl(max(get_menu_tree(parent_id,0)),' ') as parentLabel from tbl_sec_menu where parent_id="+parentId;
		else
			sql = "select nvl((select max(display_order) from tbl_sec_menu where parent_id="+parentId+"),0) + 1 as displayOrder, "+parentId+" as parentId, (menu_level + 1) as menuLevel, "+root+" as root, nvl(get_menu_tree(id,0),' ') as parentLabel from tbl_sec_menu where id="+parentId;
		menu = (Menu) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Menu.class);
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Menu no es válido. Por favor intente nuevamente!");

		sql = "select id, display_label as displayLabel, display_order as displayOrder, nvl(description,' ') as description, nvl(path,' ') as path, parent_id as parentId, status, menu_level as menuLevel, root, nvl(get_menu_tree(parent_id,0),' ') as parentLabel from tbl_sec_menu where id="+id;
		menu = (Menu) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Menu.class);
		parentId = menu.getParentId();
		root = menu.getRoot();

	}
%>

<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<script language="javascript">
document.title = 'Administración - Menu'+document.title;

function checkLabel(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_sec_menu','parent_id=<%=menu.getParentId()%> and display_label=\''+obj.value+'\'','<%=menu.getDisplayLabel()%>');
}

function showMenuList()
{
	abrir_ventana1('../common/search_menu.jsp?fp=menu&id=<%=id%>');
}

function doAction()
{
}
$(document).ready(function(){$(".htmlEditor").cleditor({controls:"bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | outdent indent | alignleft center alignright justify | undo redo | rule image table | cut copy paste pastetext | source"});});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MENU"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("parentId",parentId)%>
<%=fb.hidden("root",root)%>
<%=fb.hidden("id",id)%>
<%fb.appendJsValidation("if(checkLabel(document.form1.displayLabel))error++;");%>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
<%
if (!parentId.equals("0"))
{
%>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Menu Padre</cellbytelabel></td>
			<td colspan="3">
				<label id="parentLabel" style=" vertical-align:middle"><%=menu.getParentLabel()%></label>
				<%=fb.button("btnParent","...",true,false,null,"vertical-align:middle","onClick=\"javascript:showMenuList()\"")%>
			</td>
		</tr>
<%
}
%>
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel>Nivel</cellbytelabel></td>
			<td width="35%"><%=fb.intBox("menuLevel",menu.getMenuLevel(),true,false,true,2)%></td>
			<td width="15%" align="right"><cellbytelabel>Orden</cellbytelabel></td>
			<td width="35%"><%=fb.intBox("displayOrder",menu.getDisplayOrder(),true,false,false,2)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Menu</cellbytelabel></td>
			<td><%=fb.textBox("displayLabel",menu.getDisplayLabel(),true,false,false,50,null,null,"onBlur=\"javascript:checkLabel(this)\"")%></td>
			<td align="right"><cellbytelabel>Direcci&oacute;n</cellbytelabel></td>
			<td><%=fb.textBox("path",menu.getPath().trim(),false,false,false,50)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td><%=fb.textarea("description",menu.getDescription().trim(),false,false,false,40,5,"htmlEditor",null,null)%></td>
			<td align="right"><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("status","A=Activo,I=Inactivo",menu.getStatus(),false,false,false,0,null,null,null)%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
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
	menu = new Menu();

	menu.setId(id);
	menu.setParentId(parentId);
	menu.setRoot(root);
	menu.setMenuLevel(request.getParameter("menuLevel"));
	menu.setDisplayOrder(request.getParameter("displayOrder"));
	menu.setDisplayLabel(request.getParameter("displayLabel"));
	menu.setPath(request.getParameter("path"));
	menu.setDescription(request.getParameter("description"));
	menu.setStatus(request.getParameter("status"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		MenuMgr.add(menu);
		id = MenuMgr.getPkColValue("menuId");
	}
	else MenuMgr.update(menu);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (MenuMgr.getErrCode().equals("1"))
{
%>
	alert('<%=MenuMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/list_menu.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/list_menu.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/list_menu.jsp';
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
} else throw new Exception(MenuMgr.getErrException());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?parentId=<%=parentId%>&root=<%=root%>';
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