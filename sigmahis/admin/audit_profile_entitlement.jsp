<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.UserDetail"%>
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String id = request.getParameter("id");
String code = request.getParameter("code");
String descrip = request.getParameter("descrip");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String audUser = request.getParameter("audUser");
String audAction = request.getParameter("audAction");

if (id == null || id.trim().equals("")) throw new Exception("El Perfil no es válido. Por favor intente nuevamente!");
if (code == null ) code = "";
if (descrip == null ) descrip = "";
if (fDate == null ) fDate = "";
if (tDate == null ) tDate = "";
if (audUser == null ) audUser = "";
if (audAction == null ) audAction = "";

if (request.getMethod().equalsIgnoreCase("GET")) {
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
	sbSql.append("select profile_name from tbl_sec_profiles where profile_id = ").append(id);
	CommonDataObject pCdo = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'AUD_SCHEMA'),'-') as schemaData from dual");
	CommonDataObject p = SQLMgr.getData(sbSql.toString());
	if (p.getColValue("schemaData").equals("-")) throw new Exception("El parámetro de auditoría [AUD_SCHEMA] no se encuentra definido!");
	String[] audschema = p.getColValue("schemaData").split(",");

	if (audAction.equalsIgnoreCase("INS")) {
		sbFilter.append(" and aud_action = 'INS'");
	} else if (audAction.equalsIgnoreCase("UPD")) {
		sbFilter.append(" and aud_action = 'UPD' and ( codigo <> nvl(p_codigo,-999) )");
	} else if (audAction.equalsIgnoreCase("DEL")) {
		sbFilter.append(" and aud_action = 'DEL'");
	} else {
		sbFilter.append(" and ( codigo <> nvl(p_codigo,-999)/**/ or aud_action in ('INS','DEL') )");
	}
	if (!fDate.trim().equals("")) { sbFilter.append(" and trunc(aud_timestamp) >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!tDate.trim().equals("")) { sbFilter.append(" and trunc(aud_timestamp) <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }

	sbSql = new StringBuffer();
	sbSql.append("select z.profile_id, z.codigo, nvl(z.p_codigo,z.codigo) as p_codigo");
	sbSql.append(", to_char(z.aud_timestamp,'dd/mm/yyyy hh24:mi:ss') as aud_date, z.aud_webuser_ip as aud_user, z.aud_action");
	sbSql.append(", (select entitlement_desc from tbl_sec_entitlements where entitlement_code = z.codigo) as descripcion");
	sbSql.append(", (select entitlement_desc from tbl_sec_entitlements where entitlement_code = nvl(z.p_codigo,z.codigo)) as p_descripcion");
	sbSql.append(" from (");

	for (int i=0; i<audschema.length; i++) {
		if (i>0) sbSql.append(" union all ");
		sbSql.append("select profile_id, entitlement_code as codigo, aud_timestamp, aud_webuser_ip, aud_action");
		sbSql.append(", lag(entitlement_code) over (partition by profile_id, entitlement_code order by profile_id, entitlement_code, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_codigo");
		sbSql.append(" from ");
		sbSql.append(audschema[i].replaceAll("@@","."));
		sbSql.append("sec_profile_entitlements a where profile_id = ");
		sbSql.append(id);
		if (!audUser.trim().equals("")) { sbSql.append(" and upper(aud_webuser_ip) like '%"); sbSql.append(audUser); sbSql.append("%'"); }
		if (!code.trim().equals("")) { sbSql.append(" and entitlement_code = '").append(code).append("'"); }
		if (!descrip.trim().equals("")) {	sbSql.append(" and exists (select null from tbl_sec_entitlements where entitlement_code = a.entitlement_code and upper(entitlement_desc) like '%").append(descrip.toUpperCase()).append("%')"); }
	}

	sbSql.append(") z");
	if (sbFilter.length() != 0) sbSql.append(sbFilter.replace(0,4," where"));
	sbSql.append(" order by profile_id, codigo, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)");

	if (request.getParameter("audUser") != null) {
		StringBuffer sbTmp = new StringBuffer();
		sbTmp.append("select * from (select rownum as rn, a.* from (").append(sbSql).append(") a) where rn between ").append(previousVal).append(" and ").append(nextVal);
		al = SQLMgr.getDataList(sbTmp.toString());
		sbTmp = new StringBuffer();
		sbTmp.append("select count(*) from (").append(sbSql).append(")");
		rowCount = CmnMgr.getCount(sbTmp.toString());
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Auditoría de Entitlement del Perfil - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(resetHeight){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
<style type="text/css">
<!--
.txt-size::before {font-size: 20px !important;}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">

<table align="center" width="100%" cellpadding="1" cellspacing="1">
<tr class="TextHeader">
	<td align="center"><label class="Text14Bold">PERFIL :</label> <label class="Text14Bold SpacingText LimeText">[ <%=id%> ] <%=pCdo.getColValue("profile_name")%></label></td>
</tr>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("id",id)%>
<tr class="TextFilter">
	<td>
		<cellbytelabel>C&oacute;digo</cellbytelabel>
		<%=fb.textBox("code",code,false,false,false,12,12,null,null,null)%>
		<cellbytelabel>Entitlement</cellbytelabel>
		<%=fb.textBox("descrip",descrip,false,false,false,20,100,null,null,null)%>
		<cellbytelabel>Aud. Fecha</cellbytelabel>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2"/>
		<jsp:param name="nameOfTBox1" value="fDate"/>
		<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
		<jsp:param name="nameOfTBox2" value="tDate"/>
		<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
		<jsp:param name="clearOption" value="true"/>
		</jsp:include>
		<cellbytelabel>Aud. Usuario</cellbytelabel>
		<%=fb.textBox("audUser",audUser,false,false,false,20,100,null,null,null)%>
		<cellbytelabel>Aud. Acci&oacute;n</cellbytelabel>
		<%=fb.select("audAction","INS=REGISTRADO,UPD=MODIFICADO,DEL=ELIMINADO",audAction,false,false,0,"",null,null,null,"T")%>
		<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd()%>
<!--<tr>
	<td align="right">&nbsp;</td>
</tr>-->
<tr>
	<td>
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
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("audUser",audUser)%>
<%=fb.hidden("audAction",audAction)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("descrip",descrip)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("audUser",audUser)%>
<%=fb.hidden("audAction",audAction)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("descrip",descrip)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td>

<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="2%">&nbsp;</td>
					<td width="23%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="8%"><cellbytelabel>Aud. Fecha</cellbytelabel></td>
					<td width="17%"><cellbytelabel>Aud. Usuario</cellbytelabel></td>
				</tr>
<% if (request.getParameter("audUser") == null) { %>
				<tr class="TextRow01 RedText" align="center"><td colspan="5">I N T R O D U Z C A &nbsp;&nbsp;&nbsp; P A R A M E T R O S &nbsp;&nbsp;&nbsp; D E &nbsp;&nbsp;&nbsp; B U S Q U E D A</td></tr>
<% } else if (al.size() == 0) { %>
				<tr class="TextRow01 RedText" align="center"><td colspan="5">B U S Q U E D A &nbsp;&nbsp;&nbsp; S I N &nbsp;&nbsp;&nbsp; R E S U L T A D O S</td></tr>
<% } %>
<%
String g = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!g.equalsIgnoreCase(cdo.getColValue("codigo"))) {
%>
				<tr class="TextHeader01"><td colspan="5" align="center"><label class="Text14Bold SpacingText">ENTITLEMENT --> <%=cdo.getColValue("descripcion")%></label></td></tr>
<% } %>
				<tr class="TextRow00<%=(!cdo.getColValue("aud_action").equalsIgnoreCase("UPD")?" RedTextBold":"")%>">
					<td align="center" rowspan="2" class="TextRow01 Text10Bold">
					<% if (cdo.getColValue("aud_action").equalsIgnoreCase("INS")) { %>
						<span class="span-circled span-circled-20 span-circled-green" data-content="+" style="--txt-size:20px"></span>
					<% } else if (cdo.getColValue("aud_action").equalsIgnoreCase("UPD")) { %>
						<span class="span-circled span-circled-20 span-circled-yellow" data-content="*" style="--txt-size:24px"></span>
					<% } else if (cdo.getColValue("aud_action").equalsIgnoreCase("DEL")) { %>
						<span class="span-circled span-circled-20 span-circled-red" data-content="-" style="--txt-size:24px"></span>
					<% } %>
					</td>
					<td align="center"><%=cdo.getColValue("p_codigo")%></td>
					<td><%=cdo.getColValue("p_descripcion")%></td>
					<td align="center" rowspan="2" class="TextRow01 Text10Bold"><%=cdo.getColValue("aud_date")%></td>
					<td align="center" rowspan="2" class="TextRow01 Text10Bold"><%=cdo.getColValue("aud_user")%></td>
				</tr>
				<tr class="TextRow01 RedTextBold">
					<td align="center"><%=(cdo.getColValue("p_codigo").equals(cdo.getColValue("codigo")))?"":cdo.getColValue("codigo")%></td>
					<td><%=(cdo.getColValue("p_descripcion").equals(cdo.getColValue("descripcion")))?"":cdo.getColValue("descripcion")%></td>
				</tr>
<%
	g = cdo.getColValue("codigo");
}
%>
				</table>
</div>
</div>

	</td>
</tr>
<tr>
	<td>
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
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("audUser",audUser)%>
<%=fb.hidden("audAction",audAction)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("descrip",descrip)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("audUser",audUser)%>
<%=fb.hidden("audAction",audAction)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("descrip",descrip)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>

	</td>
</tr>
</table>
</body>
</html>
<% } %>