<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String module = request.getParameter("module");
String process = request.getParameter("process");
String name = request.getParameter("name");

if (appendFilter == null) appendFilter = "";
if (module == null) module = "";
if (process == null) process = "";
if (name == null) name = "";
if (!module.trim().equals("")) appendFilter += " and a.module_id="+module;
if (!process.trim().equals("")) appendFilter += " and a.process_id="+process;
if (!name.trim().equals("")) appendFilter += " and upper(a.name) like '%"+name.toUpperCase()+"%'";

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

	if (request.getParameter("module") != null)
	{
		sql = "select a.process_id, a.module_id, a.name, b.name as module_name, (select count(*) from tbl_sec_profile_entitlements where entitlement_code like '%'||lpad(a.process_id,4,'0')||'00') as nProfiles, (select count(*) from tbl_sec_page_entitlement where entitlement_code like '%'||lpad(a.process_id,4,'0')||'00') as nPages from tbl_sec_process a, tbl_sec_module b where a.module_id=b.id"+appendFilter+" order by b.name, a.name";
		al = SQLMgr.getDataList("select * from (select rownum as rn, z.* from ("+sql+") z) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_sec_process a, tbl_sec_module b where a.module_id=b.id"+appendFilter+"");
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
document.title = 'Administración de Proceso- '+document.title;
function add(){abrir_ventana('../admin/reg_entitlement.jsp');}
function edit(id){abrir_ventana('../admin/reg_entitlement.jsp?mode=edit&id='+id);}
function viewReferences(id,refer){abrir_ventana('../admin/vw_entitlement_references.jsp?id='+id+'&refer='+refer);}
function printList(){abrir_ventana('../admin/print_list_entitlements.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - PROCESO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Proceso</cellbytelabel> ]</a></authtype></td>
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
			<td width="40%">
				<cellbytelabel>M&oacute;dulo</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select id, to_char(id,'09')||' - '||name from tbl_sec_module where status='A' order by name","module",module,false,false,0,null,null,null,null,"T")%>
			</td>
			<td width="20%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.intBox("process","",false,false,false,5)%>
			</td>
			<td width="40%">
				<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("name","",false,false,false,40)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype><!--<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>--></authtype></td>
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
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("module",module)%>
<%=fb.hidden("process",process)%>
<%=fb.hidden("name",name)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("module",module)%>
<%=fb.hidden("process",process)%>
<%=fb.hidden("name",name)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
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

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td rowspan="2" width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td rowspan="2" width="50%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td rowspan="2" width="10%">&nbsp;</td>
			<td colspan="2"><cellbytelabel>Asignados A</cellbytelabel></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel># Perfiles</cellbytelabel></td>
			<td width="10%"><cellbytelabel># P&aacute;ginas</cellbytelabel></td>
		</tr>
<% if (al.size() == 0) { %>
		<tr>
			<td colspan="5" class="TextRow01" align="center"><font color="#FF0000">
				<% if (request.getParameter("module") == null) { %>
				<cellbytelabel>I N T R O D U Z C A</cellbytelabel> &nbsp; <cellbytelabel>P A R A M E T R O S</cellbytelabel> &nbsp; <cellbytelabel>P A R A</cellbytelabel> &nbsp; <cellbytelabel>B U S Q U E D A</cellbytelabel>
				<% } else { %>
				<cellbytelabel>N O</cellbytelabel> &nbsp; <cellbytelabel>H A Y</cellbytelabel> &nbsp; <cellbytelabel>R E G I S T R O S</cellbytelabel> &nbsp; <cellbytelabel>E N C O N T R A D O S</cellbytelabel>
				<% } %>
			</font></td>
		</tr>
<% } %>
<%
String mod = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!mod.equalsIgnoreCase(cdo.getColValue("module_name")))
	{
%>
		<tr class="TextHeader01">
			<td colspan="5">[ <%=cdo.getColValue("module_id")%> ] <%=cdo.getColValue("module_name")%></td>
		</tr>
<%
	}
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("process_id")%></td>
			<td><%=cdo.getColValue("name")%></td>
			<td align="center">&nbsp;<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("process_id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype></td>
			<td align="center">&nbsp;<authtype type='50'><a href="javascript:viewReferences(<%=cdo.getColValue("process_id")%>,'profile')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("nProfiles")%></a></authtype></td>
			<td align="center">&nbsp;<authtype type='51'><a href="javascript:viewReferences(<%=cdo.getColValue("process_id")%>,'page')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("nPages")%></a></authtype></td>
		</tr>
<%
	mod = cdo.getColValue("module_name");
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
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("module",module)%>
<%=fb.hidden("process",process)%>
<%=fb.hidden("name",name)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("module",module)%>
<%=fb.hidden("process",process)%>
<%=fb.hidden("name",name)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
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