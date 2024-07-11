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
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String audUser = request.getParameter("audUser");
String audAction = request.getParameter("audAction");

if (id == null || id.trim().equals("")) throw new Exception("El Usuario no es válido. Por favor intente nuevamente!");
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

	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'AUD_SCHEMA'),'-') as schemaData from dual");
	CommonDataObject p = SQLMgr.getData(sbSql.toString());
	if (p.getColValue("schemaData").equals("-")) throw new Exception("El parámetro de auditoría [AUD_SCHEMA] no se encuentra definido!");
	String[] audschema = p.getColValue("schemaData").split(",");

	if (audAction.equalsIgnoreCase("INS")) {
		sbFilter.append(" and aud_action = 'INS'");
	} else if (audAction.equalsIgnoreCase("UPD")) {
		sbFilter.append(" and aud_action = 'UPD' and ( user_status <> nvl(p_user_status,'-') or user_type <> nvl(p_user_type,-999) or ref_code <> nvl(p_ref_code,'---') or name <> nvl(p_name,'---') or default_profile <> nvl(p_default_profile,-999) or department_id <> nvl(p_department_id,-999) or block_status <> nvl(p_block_status,'-') or default_compania <> nvl(p_default_compania,-999) or timeout <> nvl(p_timeout,-999) )");
	} else if (audAction.equalsIgnoreCase("STS")) {
		sbFilter.append(" and aud_action = 'UPD' and user_status <> p_user_status");
	} else if (audAction.equalsIgnoreCase("TYPE")) {
		sbFilter.append(" and aud_action = 'UPD' and user_type <> p_user_type");
	} else if (audAction.equalsIgnoreCase("REF")) {
		sbFilter.append(" and aud_action = 'UPD' and ref_code <> p_ref_code");
	} else if (audAction.equalsIgnoreCase("NAME")) {
		sbFilter.append(" and aud_action = 'UPD' and name <> p_name");
	} else if (audAction.equalsIgnoreCase("PROF")) {
		sbFilter.append(" and aud_action = 'UPD' and default_profile <> p_default_profile");
	} else if (audAction.equalsIgnoreCase("DPTO")) {
		sbFilter.append(" and aud_action = 'UPD' and department_id <> p_department_id");
	} else if (audAction.equalsIgnoreCase("BLK")) {
		sbFilter.append(" and aud_action = 'UPD' and block_status <> p_block_status");
	} else if (audAction.equalsIgnoreCase("CIA")) {
		sbFilter.append(" and aud_action = 'UPD' and default_compania <> p_default_compania");
	} else if (audAction.equalsIgnoreCase("TOUT")) {
		sbFilter.append(" and aud_action = 'UPD' and timeout <> p_timeout");
	} else {
		sbFilter.append(" and ( user_status <> nvl(p_user_status,'-') or user_type <> nvl(p_user_type,-999) or ref_code <> nvl(p_ref_code,'---') or name <> nvl(p_name,'---') or default_profile <> nvl(p_default_profile,-999) or department_id <> nvl(p_department_id,-999) or block_status <> nvl(p_block_status,'-') or default_compania <> nvl(p_default_compania,-999) or timeout <> nvl(p_timeout,-999)/* or aud_action in ('INS','DEL')*/ )");
	}
	if (!fDate.trim().equals("")) { sbFilter.append(" and trunc(aud_timestamp) >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!tDate.trim().equals("")) { sbFilter.append(" and trunc(aud_timestamp) <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }

	sbSql = new StringBuffer();
	sbSql.append("select z.user_id, z.user_name, z.user_status, z.user_type, z.ref_code, z.name, z.default_profile, z.department_id, z.block_status, z.default_compania, z.timeout, decode(z.user_status,'A','ACTIVO','I','INACTIVO',z.user_status) as estado, decode(z.block_status,'N','NO','Y','SI',z.block_status) as block, nvl(z.p_user_status,z.user_status) as p_user_status, nvl(z.p_user_type,z.user_type) as p_user_type, nvl(z.p_ref_code,z.ref_code) as p_ref_code, nvl(z.p_name,z.name) as p_name, nvl(z.p_default_profile,z.default_profile) as p_default_profile, nvl(z.p_department_id,z.department_id) as p_department_id, nvl(z.p_block_status,z.block_status) as p_block_status, nvl(z.p_default_compania,z.default_compania) as p_default_compania, nvl(z.p_timeout,z.timeout) as p_timeout, decode(nvl(z.p_user_status,z.user_status),'A','ACTIVO','I','INACTIVO',nvl(z.p_user_status,z.user_status)) as p_estado, decode(nvl(z.p_block_status,z.block_status),'N','NO','Y','SI',nvl(z.p_block_status,z.block_status)) as p_block");
	sbSql.append(", to_char(z.aud_timestamp,'dd/mm/yyyy hh24:mi:ss') as aud_date, z.aud_webuser_ip as aud_user, z.aud_action");
	sbSql.append(", nvl((select description from tbl_sec_user_type where id = z.user_type),' ') as utype");
	sbSql.append(", (select profile_name from tbl_sec_profiles where profile_id = z.default_profile) as profile");
	sbSql.append(", (select name from tbl_sec_department where id = z.department_id) as department");
	sbSql.append(", (select nombre from tbl_sec_compania where codigo = z.default_compania) as compania");
	sbSql.append(", nvl((select description from tbl_sec_user_type where id = nvl(z.p_user_type,z.user_type)),' ') as p_utype");
	sbSql.append(", (select profile_name from tbl_sec_profiles where profile_id = nvl(z.p_default_profile,z.default_profile)) as p_profile");
	sbSql.append(", (select name from tbl_sec_department where id = nvl(z.p_department_id,z.department_id)) as p_department");
	sbSql.append(", (select nombre from tbl_sec_compania where codigo = nvl(z.p_default_compania,z.default_compania)) as p_compania");
	sbSql.append(", -1 as codigo, -1 as p_codigo, -1 as descripcion, -1 as p_descripcion, -1 as habitacion, -1 as p_habitacion, -1 as cds, -1 as p_cds, -1 as idoneidad, -1 as p_idoneidad, -1 as registro, -1 as p_registro, -1 as folio, -1 as p_folio");
	sbSql.append(" from (");

	for (int i=0; i<audschema.length; i++) {
		if (i>0) sbSql.append(" union all ");
		sbSql.append("select user_id, user_name, user_status, nvl(user_type,-1) as user_type, (case when (select ref_type from tbl_sec_user_type where id = a.user_type) = 'E' then (select num_empleado from tbl_pla_empleado where to_char(emp_id) = a.ref_code) else a.ref_code end) as ref_code, name, default_profile, department as department_id, block_status, default_compania, nvl(other1,0) as timeout, aud_timestamp, aud_webuser_ip, aud_action");
		sbSql.append(", lag(user_status) over (partition by user_id order by user_id, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_user_status");
		sbSql.append(", lag(nvl(user_type,-1)) over (partition by user_id order by user_id, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_user_type");
		sbSql.append(", lag((case when (select ref_type from tbl_sec_user_type where id = a.user_type) = 'E' then (select num_empleado from tbl_pla_empleado where to_char(emp_id) = a.ref_code) else a.ref_code end)) over (partition by user_id order by user_id, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_ref_code");
		sbSql.append(", lag(name) over (partition by user_id order by user_id, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_name");
		sbSql.append(", lag(default_profile) over (partition by user_id order by user_id, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_default_profile");
		sbSql.append(", lag(department) over (partition by user_id order by user_id, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_department_id");
		sbSql.append(", lag(block_status) over (partition by user_id order by user_id, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_block_status");
		sbSql.append(", lag(default_compania) over (partition by user_id order by user_id, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_default_compania");
		sbSql.append(", lag(nvl(other1,0)) over (partition by user_id order by user_id, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)) as p_timeout");
		sbSql.append(" from ");
		sbSql.append(audschema[i].replaceAll("@@","."));
		sbSql.append("sec_users a where user_id = ");
		sbSql.append(id);
		if (!audUser.trim().equals("")) { sbSql.append(" and upper(aud_webuser_ip) like '%"); sbSql.append(audUser); sbSql.append("%'"); }
	}

	sbSql.append(") z");
	if (sbFilter.length() != 0) sbSql.append(sbFilter.replace(0,4," where"));
	sbSql.append(" order by user_name, aud_timestamp, decode(aud_action,'INS',1,'UPD',2,3)");

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
document.title = 'Auditoría de Usuario - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
<style type="text/css">
<!--
.txt-size::before {font-size: 20px !important;}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="99.9%" cellpadding="1" cellspacing="0" id="_tblMain">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("id",id)%>
<tr class="TextFilter">
	<td>
		<cellbytelabel>Aud. Fecha</cellbytelabel>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2"/>
		<jsp:param name="nameOfTBox1" value="fDate"/>
		<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
		<jsp:param name="nameOfTBox2" value="tDate"/>
		<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
		<jsp:param name="clearOption" value="true"/>
		</jsp:include>
		Aud. Usuario
		<%=fb.textBox("audUser",audUser,false,false,false,20,100,null,null,null)%>
		Aud. Acci&oacute;n
		<%=fb.select("audAction","INS=REGISTRADO,UPD=MODIFICADO",audAction,false,false,0,"",null,null,null,"T")%>
		<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd()%>
<!--<tr>
	<td align="right">&nbsp;</td>
</tr>-->
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
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("audUser",audUser)%>
<%=fb.hidden("audAction",audAction)%>
<%=fb.hidden("id",id)%>
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
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="2%">&nbsp;</td>
					<td width="10%"><cellbytelabel>Tipo Usuario</cellbytelabel></td>
					<td width="12%"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="6%"><cellbytelabel>Referencia</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Departamento</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Perfil Designado</cellbytelabel></td>
					<td width="12%"><cellbytelabel>Compa&ntilde;&iacute;a Designada</cellbytelabel></td>
					<td width="4%"><cellbytelabel>T. Exp.</cellbytelabel></td>
					<td width="5%"><cellbytelabel>Estado</cellbytelabel></td>
					<td width="4%"><cellbytelabel>Bloquea</cellbytelabel></td>
					<td width="8%"><cellbytelabel>Aud. Fecha</cellbytelabel></td>
					<td width="17%"><cellbytelabel>Aud. Usuario</cellbytelabel></td>
				</tr>
<% if (request.getParameter("audUser") == null) { %>
				<tr class="TextRow01 RedText" align="center"><td colspan="12">I N T R O D U Z C A &nbsp;&nbsp;&nbsp; P A R A M E T R O S &nbsp;&nbsp;&nbsp; D E &nbsp;&nbsp;&nbsp; B U S Q U E D A</td></tr>
<% } else if (al.size() == 0) { %>
				<tr class="TextRow01 RedText" align="center"><td colspan="12">B U S Q U E D A &nbsp;&nbsp;&nbsp; S I N &nbsp;&nbsp;&nbsp; R E S U L T A D O S</td></tr>
<% } %>
<%
//String g = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	/*if (!g.equalsIgnoreCase(cdo.getColValue("user_name"))) {
%>
				<tr class="TextHeader01"><td colspan="12" align="center"><label class="Text14Bold SpacingText">USUARIO --> <%=cdo.getColValue("user_name")%></label></td></tr>
<% }*/ %>
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
					<td align="center"><%=cdo.getColValue("p_utype")%></td>
					<td><%=cdo.getColValue("p_name")%></td>
					<td><%=cdo.getColValue("p_ref_code")%></td>
					<td align="center"><%=cdo.getColValue("p_department")%></td>
					<td align="center"><%=cdo.getColValue("p_profile")%></td>
					<td align="center"><%=cdo.getColValue("p_compania")%></td>
					<td align="center"><%=cdo.getColValue("p_timeout")%></td>
					<td align="center"><%=cdo.getColValue("p_estado")%></td>
					<td align="center"><%=cdo.getColValue("p_block")%></td>
					<td align="center" rowspan="2" class="TextRow01 Text10Bold"><%=cdo.getColValue("aud_date")%></td>
					<td align="center" rowspan="2" class="TextRow01 Text10Bold"><%=cdo.getColValue("aud_user")%></td>
				</tr>
				<tr class="TextRow01 RedTextBold">
					<td align="center"><%=(cdo.getColValue("p_utype").equals(cdo.getColValue("utype")))?"":cdo.getColValue("utype")%></td>
					<td><%=(cdo.getColValue("p_name").equals(cdo.getColValue("name")))?"":cdo.getColValue("name")%></td>
					<td><%=(cdo.getColValue("p_ref_code").equals(cdo.getColValue("ref_code")))?"":cdo.getColValue("ref_code")%></td>
					<td align="center"><%=(cdo.getColValue("p_department").equals(cdo.getColValue("department")))?"":cdo.getColValue("department")%></td>
					<td align="center"><%=(cdo.getColValue("p_profile").equals(cdo.getColValue("profile")))?"":cdo.getColValue("profile")%></td>
					<td align="center"><%=(cdo.getColValue("p_compania").equals(cdo.getColValue("compania")))?"":cdo.getColValue("compania")%></td>
					<td align="center"><%=(cdo.getColValue("p_timeout").equals(cdo.getColValue("timeout")))?"":cdo.getColValue("timeout")%></td>
					<td align="center"><%=(cdo.getColValue("p_estado").equals(cdo.getColValue("estado")))?"":cdo.getColValue("estado")%></td>
					<td align="center"><%=(cdo.getColValue("p_block").equals(cdo.getColValue("block")))?"":cdo.getColValue("block")%></td>
				</tr>
<%
	//g = cdo.getColValue("user_name");
}
%>
				</table>
</div>
</div>
			</td>
		</tr>
		</table>
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
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("audUser",audUser)%>
<%=fb.hidden("audAction",audAction)%>
<%=fb.hidden("id",id)%>
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
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<% } %>