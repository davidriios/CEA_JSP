<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import="issi.admin.Menu"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="session" class="issi.admin.CommonMgr"/>
<%
SecMgr.setConnection(ConMgr);
//CmnMgr.setConnection(ConMgr);
boolean logout = false;
if (!SecMgr.checkLogin(session.getId())) logout = true;
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
StringBuffer sbSql = new StringBuffer();
ArrayList al = new ArrayList();

Menu menu = new Menu();
String cm = request.getParameter("cm");
String lm = "0";
StringBuffer menuTree = new StringBuffer();
StringBuffer menuTreeLink = new StringBuffer();
String pid = "0";
String id = "0";

String tooltipMenu = "n";
try { tooltipMenu = java.util.ResourceBundle.getBundle("issi").getString("tooltip.menu"); } catch(Exception e) {}
if (tooltipMenu == null || tooltipMenu.trim().equals("")) tooltipMenu = "n";
boolean showTooltip = (tooltipMenu.equalsIgnoreCase("y"))?true:false;

if (cm == null) {
	if (session.getAttribute("_menuId") == null) cm = "0";
	else cm = (String) session.getAttribute("_menuId");
}

if (cm.indexOf("|") >= 0) {
	pid = cm.substring(0,cm.indexOf("|")).trim();
	id = cm.substring(cm.indexOf("|") + 1).trim();
} else {
	pid = cm;
	id = cm;
}

if (!pid.equals("0") && !id.equals("0")) {
	sbSql.append("select get_menu_tree(").append(id).append(",1) as displayLabel, parent_id as parentId from tbl_sec_menu x where id = ").append(pid);
	menu = (Menu) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Menu.class);
	lm = menu.getParentId();
	StringTokenizer stMenu = new StringTokenizer(menu.getDisplayLabel(), ">");
	int ct = 0;
	int ctTotal = stMenu.countTokens();
	while (stMenu.hasMoreTokens()) {
		StringTokenizer stLink = new StringTokenizer(stMenu.nextToken().trim(), "|");
		String linkId = stLink.nextToken().trim();
		String link = stLink.nextToken().trim();
		ct++;
		menuTree.append(link);
		if ((ct < ctTotal && id.equals(pid)) || (ct < (ctTotal - 1) && !id.equals(pid))) menuTreeLink.append("<a href=\"javascript:setFrameSrc(\\\'MenuItems\\\',\\\'").append(request.getContextPath()).append("/common/menuitems.jsp?cm=").append(linkId).append("\\\');\" class=\"MenuUserDetailsBold\">").append(link).append("</a>");
		else menuTreeLink.append(link);
		if (ct < ctTotal) {
			menuTree.append(" > ");
			menuTreeLink.append(" > ");
		}
	}
	if (menuTreeLink != null && menuTreeLink.lastIndexOf(">") >= 0 && !id.equals(pid)) menuTreeLink = new StringBuffer(menuTreeLink.substring(0,menuTreeLink.lastIndexOf(">")).trim());
	session.setAttribute("_menuTree",menuTree);
}

session.setAttribute("_menuId",cm);

if (UserDet != null) {
	sbSql = new StringBuffer();
	if (UserDet.getUserProfile().contains("0")) sbSql.append("select id, display_label as displayLabel, display_order as displayOrder, nvl(description,' ') as description, nvl(path,decode((select count(*) from tbl_sec_menu where status = 'A' and parent_id = x.id),0,'N','Y')) as path, parent_id as parentId from tbl_sec_menu x where status = 'A' and parent_id = ").append(pid).append(" order by display_order, id");
	else if (UserDet.getUserProfile().size() > 0) sbSql.append("select distinct x.id, x.display_label as displayLabel, x.display_order as displayOrder, nvl(x.description,' ') as description, nvl(x.path,decode((select count(*) from tbl_sec_menu a, tbl_sec_profile_menu b where a.id = b.menu_id and a.status = 'A' and a.parent_id = x.id and b.profile_id in (").append(CmnMgr.vector2numSqlInClause(UserDet.getUserProfile())).append(")/* and exists (select null from tbl_sec_profiles where profile_id = b.profile_id and profile_status = 'A')*/),0,'N','Y')) as path, x.parent_id as parentId from tbl_sec_menu x, tbl_sec_profile_menu y where x.id = y.menu_id and x.status = 'A' and x.parent_id = ").append(pid).append(" and y.profile_id in (").append(CmnMgr.vector2numSqlInClause(UserDet.getUserProfile())).append(")/* and exists (select null from tbl_sec_profiles where profile_id = y.profile_id and profile_status = 'A')*/ order by display_order, id");
	System.out.println("SQL=\n"+sbSql);
	if (sbSql.length() > 0) al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Menu.class);
} else {
	session.setAttribute("_menuTree","");
	session.setAttribute("_menuTreeLocation","");
	menuTreeLink = new StringBuffer();
}
%>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<style>

li{
list-style:none;
	padding-top:10px;
	padding-bottom:10px;}

.button, .button:visited {
	background: #222 ;
	display: inline-block;
	padding: 5px 10px 4px;
	color: #fff;
	text-decoration: none;
	-moz-border-radius: 0px;
	-webkit-border-radius: 0px;
	-moz-box-shadow: 0 1px 3px rgba(0,0,0,0.6);
	-webkit-box-shadow: 0 1px 3px rgba(0,0,0,0.6);
	text-shadow: 0 -1px 1px rgba(0,0,0,0.25);
	border-bottom: 1px solid rgba(0,0,0,0.25);
	position: relative;
	cursor: pointer
}

	.button:hover							{ background-color: #111; color: #fff; }
	.button:active							{ top: 1px; }
	.small.button, .small.button:visited 			{ font-size: 11px}
	.button, .button:visited,
	.medium.button, .medium.button:visited 		{ font-size: 13px;
													font-weight: bold;
													line-height: 1;
													text-shadow: 0 -1px 1px rgba(0,0,0,0.25);
													}

	.large.button, .large.button:visited 			{ font-size: 14px;
														padding: 8px 14px 9px; }

	.super.button, .super.button:visited 			{ font-size: 34px;
														padding: 8px 14px 9px; }

	.pink.button, .magenta.button:visited		{ background-color: #e22092; }
	.pink.button:hover							{ background-color: #c81e82; }
	.green.button, .green.button:visited		{ background-color: #6EBD48; }
	.green.button:hover						    { background-color: #749a02; }
	.green_ligth.button, .green.button:visited		{ background-color: #67A848; }
	.green_ligth.button:hover						    { background-color: #67A848; }
	.red.button, .red.button:visited			{ background-color: #e62727; }
	.red.button:hover							{ background-color: #cf2525; }
	.orange.button, .orange.button:visited		{ background-color: #ff5c00; }
	.orange.button:hover						{ background-color: #d45500; }
	.blue.button, .blue.button:visited		    { background-color: #336699; }
	.blue.button:hover							{ background-color: #2575cf; }
	.yellow.button, .yellow.button:visited		{ background-color: #ffb515; }
	.yellow.button:hover						{ background-color: #fc9200; }
	.grey.button, .grey.button:visited		{ background-color: #808080; }
		.grey.button:hover						{ background-color: #808080; }

		</style>


<script language="JavaScript1.2">
var speed,currentpos=curpos1=0,alt=1,curpos2=-1;
function initialize(){if(window.parent.scrollspeed!=undefined&&window.parent.scrollspeed!=null&&window.parent.scrollspeed!=0){speed=window.parent.scrollspeed;scrollwindow();}}
function scrollwindow(){temp=(document.all)?document.body.scrollTop:window.pageXOffset;alt=(alt==0)?1:0;if(alt==0){curpos1=temp;}else{curpos2=temp;}window.scrollBy(speed,0);}
setInterval("initialize()",10);
function handle(delta){if(delta<0){window.scrollBy(-10,0);}else{window.scrollBy(10,0);}}
function wheel(event){var delta=0;if(!event)event=window.event;if(event.wheelDelta){delta=event.wheelDelta/120;if(window.opera)delta=-delta;}else if(event.detail){delta=-event.detail/3;}if(delta){handle(delta);}}
if(window.addEventListener){window.addEventListener('DOMMouseScroll',wheel,false);}window.onmousewheel=document.onmousewheel=wheel;
function goMenuUrl(id,url){var frameObject=parent.document.getElementById("content");frameObject.src='common/menuRedirect.jsp?id='+id+'&url='+encodeURIComponent(url);setTimeout('parent.resetContentHeight()',100);/*window.parent.location='../common/menuRedirect.jsp?id='+id+'&url='+encodeURIComponent(url);*/}
function goMenu(cm){window.location='../common/menuitems.jsp?cm='+cm;}
function getLM(){return <%=lm%>;}
function setMenuTree(){if(window.parent.document.getElementById('menuTree')){var menuTree=window.parent.document.getElementById('menuTree');menuTree.innerHTML='<%=menuTreeLink%>';}}
setMenuTree();
function doAction(){<%=(logout)?"alert('Su sesión ha expirado.\\nSi desea continuar, por favor introduzca su Usuario/Contraseña nuevamente!');window.parent.location='../logout.jsp';":""%>}
<% if (showTooltip) { %>$(document).ready(function(){jqTooltip(top.document,null,true,0,top.objHeight('_tblMainHeader'));});<% } %>
</script>
<body style="background-color: transparent; white-space:nowrap;" onLoad="javascript:doAction()">
<%
for (int i=0; i<al.size(); i++) {
	menu = (Menu) al.get(i);
	String hintClass = "";
	if (showTooltip) if (!menu.getDescription().trim().equals("")) hintClass = " _jqHint";
	if (menu.getPath().equalsIgnoreCase("Y")) {
%>
<a href="javascript:goMenu(<%=menu.getId()%>)" class="small button blue MenuItems<%=hintClass%>" hintMsgId="menu<%=i%>" onMouseOver="setoverc(this,'small button red MenuItemsOver')" onMouseOut="setoutc(this,'MenuItems')"><img src="<%=request.getContextPath()%>/images/hasMoreOn.gif" border="0" alt="More Menu Items" height="12" width="12" align="absmiddle"/><%=menu.getDisplayLabel()%></a>
<% } else if (menu.getPath().equalsIgnoreCase("N")) { %>
<label class="small button blue MenuItems<%=hintClass%>" hintMsgId="menu<%=i%>" onMouseOver="setoverc(this,'small button blue MenuItemsOver')" onMouseOut="setoutc(this,'MenuItems')"><img src="<%=request.getContextPath()%>/images/hasMoreOff.gif" border="0" alt="No Menu Items" height="12" width="12" align="absmiddle"/><%=menu.getDisplayLabel()%></label>
<% } else { %>
<a href="javascript:goMenuUrl(<%=menu.getId()%>,'<%=menu.getPath()%>')" class="small button blue MenuItems<%=hintClass%>" hintMsgId="menu<%=i%>" onMouseOver="setoverc(this,'small button red MenuItemsOver')" onMouseOut="setoutc(this,'MenuItems')"><img src="<%=request.getContextPath()%>/images/blank.gif" border="0" alt="Menu Items" height="12" width="1" align="absmiddle"/><%=menu.getDisplayLabel()%></a>
<% } %>
<% if (showTooltip) { %><span id="menu<%=i%>" class="_jqHintMsg"><%=menu.getDescription()%></span><% } %>
<% if (i + 1 != al.size()) { %>
<!--&nbsp;|&nbsp;-->
<%
	}
}
%>
</body>
</html>
