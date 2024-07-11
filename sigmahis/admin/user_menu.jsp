
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Menu"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String sql = "";
String id = request.getParameter("id");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (id == null) throw new Exception("El Usuario no es válido. Por favor intente nuevamente!");

	sql = "select user_id as userId, user_name as userName from tbl_sec_users where user_id="+id;
	Menu user = (Menu) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Menu.class);

	sql = "select a.id, a.display_label as displayLabel, a.parent_id as parentId, a.menu_level as menuLevel, lpad(a.root,10,'0') as root, nvl(b.user_id,0) as userId from tbl_sec_menu a, (select * from tbl_sec_user_menu where user_id="+id+") b where a.id=b.menu_id(+) and a.status='A' and a.display_label!='MENU' order by Get_Menu_Code(a.id), a.id";
	al = sbb.getBeanList(ConMgr.getConnection(),sql,Menu.class);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Menu del Usuario - '+document.title;

function checkAll(root)
{
	showDetail(root);
	var size = document.form1.size.value;

	for (i=0; i<size; i++)
	{
		if (eval('document.form1.r'+root+i))
		{
			var menuId = eval('document.form1.menuId'+i).value;
			eval('document.form1.menuId'+i).checked = eval('document.form1.root'+root).checked;
		}
	}
}

function showDetail(k)
{
	var obj=document.getElementById('block'+k);
	if(obj.style.display=='')obj.style.display='none';
	else obj.style.display='';
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - MENU DEL USUARIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("size",""+al.size())%>
		<tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="3" align="center"><cellbytelabel>Menu disponible para el Usuario</cellbytelabel>: <b><%=user.getUserName()%></b></td>
		</tr>
<%
String root = "";
for (int i=0; i<al.size(); i++)
{
	Menu menu = (Menu) al.get(i);

	int lvl = Integer.parseInt(menu.getMenuLevel());
	String color = "";
	if (lvl == 1) color = "TextRow01";
	else if (lvl == 2) color = "TextRow02";
	else if (lvl == 3) color = "TextRow03";
	else if (lvl == 4) color = "TextRow04";
	else if (lvl == 5) color = "TextRow05";
	else if (lvl == 6) color = "TextRow06";
	else if (lvl == 7) color = "TextRow07";
	else if (lvl == 8) color = "TextRow10";

	String indent = "";
	for (int ind=1; ind<lvl; ind++) indent += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

	if (!menu.getRoot().equals(root))
	{
		if (i != 0)
		{
%>
				</table>
			</td>
		</tr>
<%
		}
%>
		<tr class="TextHeader">
			<td width="2%" align="center"><%=fb.checkbox("root"+menu.getRoot(),menu.getRoot(),false,false,null,null,"onClick=\"javascript:checkAll('"+menu.getRoot()+"')\"")%></td>
			<td colspan="2" onClick="javascript:showDetail('<%=menu.getRoot()%>')" style="cursor:pointer"><b><%=menu.getDisplayLabel()%></b> <img src="../images/dwn.gif" alt="Mostrar Sub-Menues"></td>
		</tr>
		<tr id="block<%=menu.getRoot()%>" style="display:none">
			<td colspan="3">
				<table width="100%" cellpadding="1" cellspacing="1">
<%
	}
%>
				<%=fb.hidden("r"+menu.getRoot()+i,id)%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td width="3%" align="right">&nbsp;</td>
					<td colspan="2"><label for="menuId<%=i%>"><%=indent%><%=fb.checkbox("menuId"+i,menu.getId(),(!menu.getUserProfile().contains("0")),false)%> <%=menu.getDisplayLabel()%></label></td>
				</tr>
<%
	root = menu.getRoot();
}
%>
				</table>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="3" align="right">
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
}//GET
else
{
	int size = Integer.parseInt(request.getParameter("size"));

	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_sec_user_menu");
		cdo.addColValue("user_id",id);
		cdo.setWhereClause("user_id="+id);

		if (request.getParameter("menuId"+i) != null)
		{
			cdo.addColValue("menu_id",request.getParameter("menuId"+i));

			al.add(cdo);
		}
	}

	SQLMgr.insertList(al);
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
//	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/list_user.jsp"))
//	{
%>
//	window.opener.location = '<%//=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/list_user.jsp")%>';
<%
//	}
//	else
//	{
%>
//	window.opener.location = '<%//=request.getContextPath()%>/admin/list_user.jsp';
<%
//	}
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
