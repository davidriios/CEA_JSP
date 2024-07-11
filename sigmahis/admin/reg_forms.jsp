<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormularioTest"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="FormularioTestMgr" scope="page" class="issi.admin.FormularioTestMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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
FormularioTestMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
FormularioTest frm = new FormularioTest();
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
		if (parentId == null) throw new Exception("El Formulario Padre no es válido. Por favor intente nuevamente!");
		if (root == null) throw new Exception("El Formulario Raiz no es válido. Por favor intente nuevamente!");

		if (parentId.equals("0"))
			sql = "select nvl(max(display_order),0) + 1 as displayOrder, "+parentId+" as parentId, 1 as frmLevel, "+root+" as root_id, nvl(max(get_frm_tree(parent_id,0)),' ') as parentLabel from tbl_frm_terapias_test where parent_id="+parentId;
		else
			sql = "select nvl((select max(display_order) from tbl_frm_terapias_test where parent_id="+parentId+"),0) + 1 as displayOrder, "+parentId+" as parentId, (level_frm + 1) as frmLevel, "+root+" as root, nvl(get_frm_tree(id,0),' ') as parentLabel from tbl_frm_terapias_test where id="+parentId;
		frm = (FormularioTest) sbb.getSingleRowBean(ConMgr.getConnection(),sql,FormularioTest.class);
		id = "0";

	}
	else
	{
	if (id == null) throw new Exception("El Formulario no es válido. Por favor intente nuevamente!");

		sql = "select id, titulo_frm as displayLabel, display_order as displayOrder, nvl(desc_terapia,' ') as description, parent_id as parentId, level_frm as frmLevel, root_id as root, nvl(get_frm_tree(parent_id,0),' ') as parentLabel from tbl_frm_terapias_test where id="+id;

		frm = (FormularioTest) sbb.getSingleRowBean(ConMgr.getConnection(),sql,FormularioTest.class);
		parentId = frm.getParentId();
		root = frm.getRoot();
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
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_frm_terapias_test','parent_id=<%=frm.getParentId()%> and titulo_frm=\''+obj.value+'\'','<%=frm.getDisplayLabel()%>');
}

function showMenuList()
{
	abrir_ventana1('../common/search_frm.jsp?fp=frm&id=<%=id%>');
}

function doAction()
{
}
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
			<td align="right"><cellbytelabel>Formulario Padre</cellbytelabel></td>
			<td colspan="3">
				<label id="parentLabel" style=" vertical-align:middle"><%=frm.getParentLabel()%></label>
				<%=fb.button("btnParent","...",true,false,null,"vertical-align:middle","onClick=\"javascript:showMenuList()\"")%>
			</td>
		</tr>
<%
}
%>
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel>Nivel</cellbytelabel></td>
			<td width="35%"><%=fb.intBox("frmLevel",frm.getFrmLevel(),true,false,true,2)%></td>
			<td width="15%" align="right"><cellbytelabel>Orden</cellbytelabel></td>
			<td width="35%"><%=fb.intBox("displayOrder",frm.getDisplayOrder(),true,false,false,2)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Formulario</cellbytelabel></td>
			<td><%=fb.textBox("displayLabel",frm.getDisplayLabel(),true,false,false,50,null,null,"onBlur=\"javascript:checkLabel(this)\"")%></td>
			<td align="right">&nbsp;</td>
			<td><%//=fb.textBox("path",menu.getPath().trim(),false,false,false,50)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td><%=fb.textarea("description",frm.getDescription().trim(),false,false,false,40,5)%></td>
			<td align="right">&nbsp;</td>
			<td><%//=fb.select("status","A=Activo,I=Inactivo",menu.getStatus())%></td>
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
	frm = new FormularioTest();

	frm.setId(id);
	frm.setParentId(parentId);
	frm.setRoot(root);
	frm.setFrmLevel(request.getParameter("frmLevel"));
	frm.setDisplayOrder(request.getParameter("displayOrder"));
	frm.setDisplayLabel(request.getParameter("displayLabel"));
	//frm.setPath(request.getParameter("path"));
	frm.setDescription(request.getParameter("description"));
	//frm.setStatus(request.getParameter("status"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		FormularioTestMgr.add(frm);
		id = FormularioTestMgr.getPkColValue("frmId");
	}
	else FormularioTestMgr.update(frm);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (FormularioTestMgr.getErrCode().equals("1"))
{
%>
	alert('<%=FormularioTestMgr.getErrMsg()%>');
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
	window.opener.location = '<%=request.getContextPath()%>/admin/list_forms_test.jsp';
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
} else throw new Exception(FormularioTestMgr.getErrMsg());
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