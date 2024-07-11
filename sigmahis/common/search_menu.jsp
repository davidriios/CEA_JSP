<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.Menu"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="MenuMgr" scope="page" class="issi.admin.MenuMgr" />
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String id = request.getParameter("id");
String root = request.getParameter("root");
String status = request.getParameter("status");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (id == null)  throw new Exception("El Menu no es válido. Por favor intente nuevamente!");
if (root == null)
	if (id.equals("0")) root = "";
	else root = ((Menu) sbb.getSingleRowBean(ConMgr.getConnection(),"select root from tbl_sec_menu where id="+id+"",Menu.class)).getRoot();
if (status == null) status = "";
if (!root.equals("")) appendFilter += " and a.root="+root+"";
if (!status.equals("")) appendFilter += " and a.status='"+status+"'";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

	String xid = request.getParameter("xid");
	String displayLabel = request.getParameter("displayLabel");
	String path = request.getParameter("path");
	if (xid == null) xid = "";
	if (displayLabel == null) displayLabel = "";
	if (path == null) path = "";
	if (!xid.equals("")) appendFilter += " and a.id like '"+xid.toUpperCase()+"%'";
	if (!displayLabel.equals("")) appendFilter += " and upper(a.display_label) like '%"+displayLabel.toUpperCase()+"%'";
	if (!path.equals("")) appendFilter += " and upper(a.path) like '%"+path.toUpperCase()+"%'";

	if (fp.equalsIgnoreCase("menu"))
	{
		sql = "select a.id, a.display_label as displayLabel, a.display_order as displayOrder, nvl(a.description,'NA') as description, nvl(a.path,'NA') as path, a.parent_id as parentId, a.status, a.menu_level as menuLevel, a.root, get_menu_tree(a.id,0) as parentLabel from tbl_sec_menu a, (select * from tbl_sec_menu where get_menu_code(id) like get_menu_code("+id+")"+((id.equals("0"))?"":"||'%'")+") b where a.id=b.id(+) and b.id is null"+appendFilter+" order by Get_Menu_Code(a.id), a.id";
		//System.out.println("\n\n"+sql+"\n\n");
		al = sbb.getBeanList(ConMgr.getConnection(),sql,Menu.class);
		rowCount = CmnMgr.getCount("select count(*) from tbl_sec_menu a, (select * from tbl_sec_menu where get_menu_code(id) like get_menu_code("+id+")"+((id.equals("0"))?"":"||'%'")+") b where a.id=b.id(+) and b.id is null"+appendFilter+"");
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

function setMenu(k)
{
<%
	if (fp.equalsIgnoreCase("menu"))
	{
%>
	window.opener.document.form1.parentId.value = eval('document.menu.id'+k).value;
	window.opener.document.getElementById('parentLabel').innerHTML = eval('document.menu.displayLabel'+k).value;
	window.opener.document.form1.root.value = eval('document.menu.root'+k).value;
	window.opener.document.form1.menuLevel.value = eval('document.menu.menuLevel'+k).value;
<%
	}
%>
	window.close();
}

function getMain(formX)
{
	formX.root.value = document.search00.root.value;
	formX.status.value = document.search00.status.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE MENU PADRE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">

<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("id",id)%>
			<td colspan="2">
				<cellbytelabel>Menu Principal</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select root, display_label, Get_Menu_Code(id) from tbl_sec_menu where parent_id=0 order by 2","root",root,"T")%>
				<cellbytelabel>Estado</cellbytelabel>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,"T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="50%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>				
				<%=fb.textBox("xid","",false,false,false,10)%>
			</td>
			<td width="50%">
				Menu
				<%=fb.textBox("displayLabel","",false,false,false,40)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
<td class="TableLeftBorder TableTopBorder TableRightBorder">
	<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("root",root).replaceAll(" id=\"root\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><!--Registros desde <%=pVal%> hasta <%=nVal%>--></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("root",root).replaceAll(" id=\"root\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="6%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Nivel</cellbytelabel></td>
			<td width="37%"><cellbytelabel>Menu</cellbytelabel></td>
			<td width="37%"><cellbytelabel>Direcci&oacute;n</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Orden</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
		</tr>
<%fb = new FormBean("menu",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
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
%>
		<%=fb.hidden("id"+i,menu.getId())%>
		<%=fb.hidden("displayLabel"+i,menu.getParentLabel())%>
		<%=fb.hidden("root"+i,menu.getRoot())%>
		<%=fb.hidden("menuLevel"+i,""+(lvl + 1))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setMenu(<%=i%>)" style="cursor:pointer">
			<td align="right"><%=menu.getId()%></td>
			<td align="center"><%=lvl%></td>
			<td><%=indent+menu.getDisplayLabel()%></td>
			<td><%=(menu.getPath().equalsIgnoreCase("NA"))?"":menu.getPath()%></td>
			<td align="center"><%=menu.getDisplayOrder()%></td>
			<td align="center"><%=(menu.getStatus().equalsIgnoreCase("A"))?"Activo":"Inactivo"%></td>
		</tr>
<%
}
%>
<%=fb.formEnd()%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("root",root).replaceAll(" id=\"root\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><!--Registros desde <%=pVal%> hasta <%=nVal%>--></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("root",root).replaceAll(" id=\"root\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>