<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.Menu"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String root = request.getParameter("root");
String status = request.getParameter("status");
String id = request.getParameter("id");
String displayLabel = request.getParameter("displayLabel");
String path = request.getParameter("path");

if (root == null) root = "";
if (status == null) status = "";
if (id == null) id = "";
if (displayLabel == null) displayLabel = "";
if (path == null) path = "";

if (!root.equals("")) { sbFilter.append(" and root = "); sbFilter.append(root); }
if (!status.equals("")) { sbFilter.append(" and status = '"); sbFilter.append(status); sbFilter.append("'"); }
if (!id.equals("")) { sbFilter.append(" and id like '"); sbFilter.append(id.toUpperCase()); sbFilter.append("%'"); }
if (!displayLabel.equals("")) { sbFilter.append(" and upper(display_label) like '%"); sbFilter.append(displayLabel.toUpperCase()); sbFilter.append("%'"); }
if (!path.equals("")) { sbFilter.append(" and upper(path) like '%"); sbFilter.append(path.toUpperCase()); sbFilter.append("%'"); }

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (request.getParameter("root") != null) {
		sbSql.append("select id, display_label as displayLabel, display_order as displayOrder, nvl(description,'NA') as description, nvl(path,'NA') as path, parent_id as parentId, status, menu_level as menuLevel, root, join(cursor(select display_label from tbl_sec_menu start with id = z.parent_id connect by prior parent_id = id order by level desc),' > ') as parentLabel from tbl_sec_menu z");
		if (sbFilter.length() != 0) sbSql.append(sbFilter.replace(0,4," where"));
		sbSql.append(" order by Get_Menu_Code(id), id");
		System.out.println("SQL = "+sbSql);
		al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Menu.class);

		sbSql = new StringBuffer();
		sbSql.append("select count(*) from tbl_sec_menu z");
		sbSql.append(sbFilter);
		rowCount = CmnMgr.getCount(sbSql.toString());
	}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);
	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Administración de Menu - '+document.title;
function add(parentId, root){abrir_ventana('../admin/reg_menu.jsp?parentId='+parentId+"&root="+root);}
function edit(id){abrir_ventana('../admin/reg_menu.jsp?mode=edit&id='+id);}
function printList(){abrir_ventana('../admin/print_list_menu.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - MENU"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;<!--<authtype type='3'><a href="javascript:add(0,0)" class="Link00">[ <cellbytelabel>Registrar Nuevo Menu</cellbytelabel> ]</a></authtype>--></td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td>
				<cellbytelabel>Menu Principal</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select root, display_label, Get_Menu_Code(id) from tbl_sec_menu where parent_id=0 order by 2","root",root,"T")%>
				Estado
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,"T")%>
			</td>
			<td>
				<cellbytelabel>Direcci&oacute;n</cellbytelabel>
				<%=fb.textBox("path","",false,false,false,40)%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="50%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("id","",false,false,false,10)%>
			</td>
			<td width="50%">
				<cellbytelabel>Menu</cellbytelabel>
				<%=fb.textBox("displayLabel","",false,false,false,40)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("root",root)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("path",path)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("displayLabel",displayLabel)%>
			<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><!--Registros desde <%=pVal%> hasta <%=nVal%>--></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("root",root)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("path",path)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("displayLabel",displayLabel)%>
			<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="6%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Nivel</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Menu</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Direcci&oacute;n</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Orden</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
		</tr>
<%
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
	for (int ind=1; ind<lvl; ind++) indent += "&nbsp;&nbsp;&nbsp;";
	String hintClass = "";
	if (menu.getParentLabel() != null && !menu.getParentLabel().trim().equals("")) hintClass = "hint hint--right";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%=menu.getId()%></td>
			<td align="center"><%=lvl%></td>
			<td><div class="<%=hintClass%>" data-hint="<%=menu.getParentLabel()%>"><%=indent+menu.getDisplayLabel()%></div></td>
			<td><%=(menu.getPath().equalsIgnoreCase("NA"))?"":"<a href=\""+menu.getPath()+"\" class=\"Link02\" onMouseOver=\"setoverc(this,'Link01')\" onMouseOut=\"setoutc(this,'Link02')\">"+menu.getPath()+"</a>"%></td>
			<td align="center"><%=menu.getDisplayOrder()%></td>
			<td align="center"><%=(menu.getStatus().equalsIgnoreCase("A"))?"Activo":"Inactivo"%></td>
			<td align="center"><authtype type='3'>
<%
if (lvl != 6 && menu.getPath().equalsIgnoreCase("NA") && menu.getStatus().equalsIgnoreCase("A"))
{
%>
			<!---<a href="javascript:add(<%=menu.getId()%>,<%=menu.getRoot()%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Agregar</cellbytelabel></a>-->
<%
}
%>
			</authtype></td>
			<td align="center"><authtype type='4'><a href="javascript:edit(<%=menu.getId()%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype>
			</td>
		</tr>
<%
}
%>
		</table>
</div>
</div>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("root",root)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("path",path)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("displayLabel",displayLabel)%>
			<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><!--Registros desde <%=pVal%> hasta <%=nVal%>--></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("root",root)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("path",path)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("displayLabel",displayLabel)%>
			<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
