<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormularioTest"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String root = request.getParameter("root");
//String status = request.getParameter("status");
String id = request.getParameter("id");
String displayLabel = request.getParameter("displayLabel");
//String path = request.getParameter("path");

if (root == null) root = "";
//if (status == null) status = "";
if (id == null) id = "";
if (displayLabel == null) displayLabel = "";
//if (path == null) path = "";
if (!root.equals("")) appendFilter += " where root_id="+root+"";
/*if (!status.equals(""))
{
	if (appendFilter.trim().equals("")) appendFilter += " where";
	else appendFilter += " and";
	appendFilter += " status='"+status+"'";
}*/
if (!id.equals(""))
{
	if (appendFilter.trim().equals("")) appendFilter += " where";
	else appendFilter += " and";
	appendFilter += " id like '"+id.toUpperCase()+"%'";
}
if (!displayLabel.equals(""))
{
	if (appendFilter.trim().equals("")) appendFilter += " where";
	else appendFilter += " and";
	appendFilter += " upper(titulo_frm) like '%"+displayLabel.toUpperCase()+"%'";
}
/*if (!path.equals(""))
{
	if (appendFilter.trim().equals("")) appendFilter += " where";
	else appendFilter += " and";
	appendFilter += " upper(path) like '%"+path.toUpperCase()+"%'";
}*/

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

	sql = "select id, titulo_frm as displayLabel, display_order as displayOrder, nvl(desc_terapia,'NA') as description,  parent_id as parentId, level_frm as frmLevel, root_id as root from tbl_frm_terapias_test"+appendFilter+" order by Get_Frm_Code(id), id";
	al = sbb.getBeanList(ConMgr.getConnection(),sql,FormularioTest.class);
	rowCount = CmnMgr.getCount("select count(*) from tbl_frm_terapias_test"+appendFilter+"");

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

function add(parentId, root)
{
	abrir_ventana('../admin/reg_forms.jsp?parentId='+parentId+"&root="+root);
}

function edit(id)
{
	abrir_ventana('../admin/reg_forms.jsp?mode=edit&id='+id);
}

function printList()
{
	abrir_ventana('../admin/print_list_frm.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
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
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - MENU"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;<authtype type='3'><a href="javascript:add(0,0)" class="Link00">[ <cellbytelabel>Registrar Nuevo Formulario</cellbytelabel> ]</a></authtype></td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="2">
				<cellbytelabel>Formulario Principal</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select root_id, titulo_frm, Get_Frm_Code(id) from tbl_frm_terapias_test where parent_id=0 order by 2","root",root,"T")%>
		
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="50%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("id","",false,false,false,10)%>
			</td>
			<td width="50%">
				<cellbytelabel>T&iacute;tulo</cellbytelabel>
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
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
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
<%//=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
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
<%//=fb.hidden("status",status)%>
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
<%=fb.hidden("root",root).replaceAll(" id=\"root\"","")%>
<%//=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
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
<%//=fb.hidden("status",status)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("displayLabel",displayLabel)%>
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
			<td width="40%"><cellbytelabel>Formulario</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Orden</cellbytelabel></td>
			<td width="22%">&nbsp;</td>
            <td width="22%">&nbsp;</td>

		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	FormularioTest frm = (FormularioTest) al.get(i);
	
		//System.out.println("*****************Get Root = "+root+"*************************************");
	
	int lvl = Integer.parseInt(frm.getFrmLevel());
	String color = "";
	if (lvl == 1) color = "TextRow01";
	else if (lvl == 2) color = "TextRow02";
	else if (lvl == 3) color = "TextRow03";
	
	String indent = "";
	for (int ind=1; ind<lvl; ind++) indent += "&nbsp;&nbsp;&nbsp;";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%=frm.getId()%></td>
			<td align="center"><%=lvl%></td>
			<td><%=indent+frm.getDisplayLabel()%></td>
         	<td align="center"><%=frm.getDisplayOrder()%></td>   
			<td align="center"><authtype type='3'>
<%
if (lvl != 3)
{
%> 			<!--getRoot()-->
			<a href="javascript:add(<%=frm.getId()%>,<%=frm.getRoot()%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Agregar</cellbytelabel></a>
<%
}
%>
			</authtype></td>
			<td align="center"><authtype type='4'><a href="javascript:edit(<%=frm.getId()%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype>
			</td>
		</tr>
<%
	//System.out.println("*******************getRoot = "+frm.getRoot()+"***********************************");
}
%>
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
<%//=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
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
<%//=fb.hidden("status",status)%>
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
<%=fb.hidden("root",root).replaceAll(" id=\"root\"","")%>
<%//=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
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
<%//=fb.hidden("status",status)%>
<%//=fb.hidden("id",id)%>
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