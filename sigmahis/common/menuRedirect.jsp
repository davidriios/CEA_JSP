<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.Menu" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<%
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String url = request.getParameter("url");
String pid = (String) session.getAttribute("_menuId");
String id = request.getParameter("id");

if (url == null) throw new Exception("Destino no válido. Por favor intente nuevamente!");
if (id == null) id = "0";
if (pid == null) pid = "0";
if (!id.equals("0"))
{
	Menu menu = (Menu) sbb.getSingleRowBean(ConMgr.getConnection(),"select get_menu_tree("+id+",0) as displayLabel, parent_id as parentId from tbl_sec_menu x where id="+id,Menu.class);
	if (pid.indexOf("|") >= 0) pid = pid.substring(0,pid.indexOf("|"));
	session.setAttribute("_menuId",pid+"|"+id);
	session.setAttribute("_menuTree",menu.getDisplayLabel());
	session.setAttribute("_menuTreeLocation",menu.getDisplayLabel());
}

response.sendRedirect(url);
%>
