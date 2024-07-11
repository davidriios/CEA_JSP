<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String module = request.getParameter("module");
String status = request.getParameter("status");
String profileName = request.getParameter("profile_name");
String profileDesc = request.getParameter("profile_desc");

if (module == null) module = "";
if (status == null) status = "";
if (profileName == null) profileName = "";
if (profileDesc == null) profileDesc = "";

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
	if (!module.trim().equals("")) sbFilter.append(" and a.module_id = ").append(module);
	if (!status.trim().equals("")) sbFilter.append(" and a.profile_status = '").append(status).append("'");
	if (!profileName.trim().equals("")) sbFilter.append(" and upper(a.profile_name) like '%").append(profileName.toUpperCase()).append("%'");
	if (!profileDesc.trim().equals("")) sbFilter.append(" and upper(a.profile_desc) like '%").append(profileDesc.toUpperCase()).append("%'");

	sbSql.append("select a.profile_id, a.profile_desc, a.profile_name, a.profile_status as status, a.module_id, b.name as module_name, (select count(*) from tbl_sec_user_profile where profile_id = a.profile_id) as nUsers from tbl_sec_profiles a, tbl_sec_module b where a.profile_id != 0 and a.module_id = b.id").append(sbFilter).append(" order by b.name, a.profile_name");
	StringBuffer sbTmp = new StringBuffer();
	sbTmp.append("select * from (select rownum as rn, a.* from (").append(sbSql).append(") a) where rn between ").append(previousVal).append(" and ").append(nextVal);
	al = SQLMgr.getDataList(sbTmp.toString());
	sbTmp = new StringBuffer();
	sbTmp.append("select count(*) from tbl_sec_profiles a, tbl_sec_module b where a.profile_id != 0 and a.module_id = b.id").append(sbFilter);
	rowCount = CmnMgr.getCount(sbTmp.toString());

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
document.title = 'Administración de Perfil - '+document.title;

function add(){abrir_ventana('../admin/reg_profile.jsp');}
function edit(id){abrir_ventana('../admin/reg_profile.jsp?mode=edit&id='+id);}
function assignAccessRights(id){abrir_ventana('../admin/access_rights.jsp?id='+id+'&module=<%=module%>');}
function viewAccessRights(id){abrir_ventana('../admin/vw_access_rights.jsp?id='+id);}
function printList(){abrir_ventana('../admin/print_list_profile.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
function printDetList(id,name){abrir_ventana("../cellbyteWV/report_container.jsp?reportName=admin/rpt_access_rights.rptdesign&pProfileId="+id+"&pProfileName="+name+"&pCtrlHeader=true");}
function viewUsers(id){abrir_ventana('../admin/vw_user_profile.jsp?id='+id);}
function viewAud(id){abrir_ventana('../admin/audit_profile_entitlement.jsp?id='+id);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - PERFIL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Perfil</cellbytelabel> ]</a></authtype></td>
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
					<cellbytelabel>M&oacute;dulo</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(),"select lpad(id,2,'0')id, name, id from tbl_sec_module where status='A' order by name","module",module,"T")%>
					<cellbytelabel>Estado</cellbytelabel>
					<%=fb.select("status","A=Activo,I=Inactivo",status,"T")%>
				</td>
			</tr>
			<tr class="TextFilter">
				<td width="50%"><cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("profile_name",profileName,false,false,false,40)%>
				</td>
				<td width="50%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("profile_desc",profileDesc,false,false,false,40)%>
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
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("profile_name",profileName)%>
				<%=fb.hidden("profile_desc",profileDesc)%>

				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("profile_name",profileName)%>
				<%=fb.hidden("profile_desc",profileDesc)%>
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
			<td width="27%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="27%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="7%"><cellbytelabel># Usuarios</cellbytelabel></td>
			<td width="8%">&nbsp;</td>
			<td width="24%" colspan="4"><cellbytelabel>Derechos de Accesos</cellbytelabel></td>
		</tr>
<%
String moduleName = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!moduleName.equalsIgnoreCase(cdo.getColValue("module_name")))
	{
%>
		<tr class="TextHeader01">
			<td colspan="9">M O D U L O :&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("module_name")%></td>
		</tr>
<%
	}
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("profile_name")%></td>
			<td><%=cdo.getColValue("profile_desc")%></td>
			<td align="center"><%=(cdo.getColValue("status").equalsIgnoreCase("A"))?"Activo":"Inactivo"%></td>
			<td align="center">&nbsp;<a href="javascript:viewUsers(<%=cdo.getColValue("profile_id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("nUsers")%></a></td>
			<td align="center">&nbsp;<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("profile_id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype></td>
			<td align="center">&nbsp;<authtype type='50'>
			<a href="javascript:assignAccessRights(<%=cdo.getColValue("profile_id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Asignar</a></authtype></td>
			<td align="center">&nbsp;<authtype type='51'><a href="javascript:viewAccessRights(<%=cdo.getColValue("profile_id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></authtype></td>
			<td align="center">&nbsp;<authtype type='52'><a href="javascript:printDetList(<%=cdo.getColValue("profile_id")%>,'<%=cdo.getColValue("profile_name")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Imprimir Det.</cellbytelabel></a></authtype></td>
			<td align="center">&nbsp;<authtype type='53'><a href="javascript:viewAud(<%=cdo.getColValue("profile_id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Auditor&iacute;a</cellbytelabel></a></authtype></td>
		</tr>
<%
	moduleName = cdo.getColValue("module_name");
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
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("profile_name",profileName)%>
				<%=fb.hidden("profile_desc",profileDesc)%>
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
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("profile_name",profileName)%>
				<%=fb.hidden("profile_desc",profileDesc)%>
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
