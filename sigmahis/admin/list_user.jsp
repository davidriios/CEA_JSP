<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.UserDetail"%>
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

boolean isFpEnabled = CmnMgr.isValidFpType("USR");
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
String appendFilter = "";

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

	String userType = request.getParameter("userType");
	String user = request.getParameter("user");
	String name = request.getParameter("name");
	String id = request.getParameter("id");
	String refCode = request.getParameter("refCode");
	String department = request.getParameter("department");
	String profile = request.getParameter("profile");
	String status = request.getParameter("status");
	String fDate = request.getParameter("fDate");
	String tDate = request.getParameter("tDate");
	String allRoles = request.getParameter("all_roles");

	if (userType == null) userType = "";
	if (user == null) user = "";
	if (name == null) name = "";
	if (refCode == null) refCode = "";
	if (department == null) department = "";
	if (profile == null) profile = "";
	if (status == null) status = "";
	if (tDate == null) tDate = "";
	if (fDate == null) fDate = "";
	if (allRoles == null) allRoles = "";

	if (id == null) id = "";
	if (userType.trim().equals("-1")) appendFilter += " and x.user_type is null";
	else if (!userType.trim().equals("")) appendFilter += " and x.user_type in ("+CmnMgr.vector2strSqlInClause(CmnMgr.str2vector(userType,"\\|"))+")";
	if (!user.trim().equals("")) appendFilter += " and upper(x.user_name) like '"+user.toUpperCase()+"%'";
	if (!name.trim().equals("")) appendFilter += " and upper(x.name) like '%"+name.toUpperCase()+"%'";
	if (!id.trim().equals("")) appendFilter += " and user_id ="+id;
	//if (!refCode.trim().equals("")) appendFilter += " and upper(decode(a.user_type,1,(select num_empleado from tbl_pla_empleado where emp_id=a.ref_code),a.ref_code)) like '"+refCode.toUpperCase()+"%'";
	if (!refCode.trim().equals("")) appendFilter += " and upper(x.ref_code_display) like '"+refCode.toUpperCase()+"%'";
	if (department.trim().equals("-1")) appendFilter += " and x.department is null";
	else if (!department.trim().equals("")) appendFilter += " and x.department="+department+"";
	if (!profile.trim().equals("")) appendFilter += " and x.default_profile="+profile+"";
	if (!status.trim().equals("")) appendFilter += " and upper(x.user_status)='"+status.toUpperCase()+"'";

	if (!fDate.trim().equals("")) appendFilter += " and trunc(x.fecha_creacion) >= to_date('"+fDate+"', 'dd/mm/yyyy')";
	if (!tDate.trim().equals("")) appendFilter += " and trunc(x.fecha_creacion) <= to_date('"+tDate+"', 'dd/mm/yyyy')";
	if (request.getParameter("userType") != null) {
	sbSql.append("select * from (select a.user_id, a.user_name, a.user_status,NVL(A.BLOCK_STATUS,'N') block_status, decode(a.user_type,null,' ',a.user_type) as user_type, a.name, a.ref_code, (case when (select ref_type from tbl_sec_user_type where id=a.user_type)='E' then (select num_empleado from tbl_pla_empleado where to_char(emp_id)=a.ref_code) else a.ref_code end) as ref_code_display, a.default_profile, a.department, (select name from tbl_sec_users where user_id=a.user_report_to) as report_to, nvl((select code||' - '||description from tbl_sec_user_type where id=a.user_type),' ') as user_type_desc ");

		if (allRoles.equalsIgnoreCase("Y")){
			sbSql.append(" , (select join(cursor( select p.profile_name from tbl_sec_profiles p, tbl_sec_user_profile up where p.profile_id = up.profile_id and up.user_id = a.user_id order by 1),', ') from dual) as profile_name ");
		}else{
			sbSql.append(" , (select profile_name from tbl_sec_profiles where profile_id=a.default_profile) as profile_name ");
		}

		sbSql.append(", nvl((select name from tbl_sec_department where id=a.department),' ') as department_name, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_crea, a.fecha_creacion");
	if (isFpEnabled) sbSql.append(", (select count(*) from tbl_bio_fingerprint where owner_id = a.user_id and capture_type = 'USR') as hasFP");

	 sbSql.append(" from tbl_sec_users a where a.default_profile!=0) x where default_profile!=0");

	sbSql.append(appendFilter.toString());
	sbSql.append(" order by x.user_type");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
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
<script>
document.title = 'Administración de Usuarios - '+document.title;
function add(){	abrir_ventana('../admin/reg_user.jsp');}
function edit(id){abrir_ventana('../admin/reg_user.jsp?mode=edit&id='+id);}
function printList(){
var allRoles = document.getElementById("all_roles").checked ? "Y" : "";
abrir_ventana('../admin/print_list_user.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&all_roles='+allRoles);}
function setFP(id){abrir_ventana('../biometric/capture_fingerprint.jsp?fp=user_list&type=USR&owner='+id);}

function toggleStatus(id, userName, status){
	showPopWin('../common/run_process.jsp?fp=TOGGLESTATUS&actType='+status+'&docType=TOGGLESTATUS&docId=TOGGLESTATUS&docNo='+id+'&user_name='+userName,winWidth*.75,winHeight*.50,null,null,'');
}
function viewAud(id){abrir_ventana('../admin/audit_user.jsp?id='+id);}
function userInfoOnly(id){
	abrir_ventana('../admin/reg_user.jsp?mode=edit&userInfoOnly=Y&id='+id);
}
</script>
<style type="text/css">
<!--
.dicon{display:inline-block;width:36px !important;}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - USUARIOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Usuario</cellbytelabel> ]</a></authtype></td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td>
				<cellbytelabel>Tipo Usuario</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select ''||id, code||' - '||description, ''||id from tbl_sec_user_type where status='A' union all select '-1', '- SIN ASIGNAR -', '-1' from dual union all select '1|2|6|7', '- TODOS LOS EMPLEADOS -', '1|2|6|7' from dual order by 2","userType",userType,false,false,0,"Text10","width:130px",null,null,"T")%>

			<cellbytelabel>Usuario</cellbytelabel><cellbytelabel>Id</cellbytelabel>
				<%=fb.textBox("id","",false,false,false,10,10,"Text10",null,null)%>
				<cellbytelabel>Usuario</cellbytelabel>
				<%=fb.textBox("user","",false,false,false,15,"Text10",null,null)%>

				<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("name","",false,false,false,25,"Text10",null,null)%>
						<cellbytelabel>Fecha Crea</cellbytelabel>.
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fDate"/>
				<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
				<jsp:param name="nameOfTBox2" value="tDate"/>
				<jsp:param name="valueOfTBox2" value="<%=fDate%>"/>
				</jsp:include>
								&nbsp;&nbsp;&nbsp;<label class="pointer">
								 <%=fb.checkbox("all_roles","Y", (allRoles.equalsIgnoreCase("Y")) ,false,null,null,"","Mostrar todos los perfiles.")%>Mostrar todos los perfiles?
								 </label>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				<cellbytelabel>Perfil Designado</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select profile_id, profile_name from tbl_sec_profiles where profile_id!=0 order by profile_name","profile",profile,false,false,0,"Text10","width:130px",null,null,"T")%>

				<cellbytelabel>Departamento</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select id, code||' - '||name from tbl_sec_department where status='A' union select -1, '- SIN ASIGNAR -' from dual order by 2","department",department,false,false,0,"Text10","width:130px",null,null,"T")%>

				<cellbytelabel>Referencia</cellbytelabel>
				<%=fb.textBox("refCode","",false,false,false,15,"Text10",null,null)%>

				<cellbytelabel>Estado</cellbytelabel>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>&nbsp;&nbsp;&nbsp;&nbsp;
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
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
<%=fb.hidden("userType",userType)%>
<%=fb.hidden("user",user)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("refCode",refCode)%>
<%=fb.hidden("department",department)%>
<%=fb.hidden("profile",profile)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("all_roles",allRoles)%>
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
<%=fb.hidden("userType",userType)%>
<%=fb.hidden("user",user)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("refCode",refCode)%>
<%=fb.hidden("department",department)%>
<%=fb.hidden("profile",profile)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("all_roles",allRoles)%>
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

		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="11%"><cellbytelabel>Tipo Usuario</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Usuario</cellbytelabel></td>
			<td width="20%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="9%"><cellbytelabel>Referencia</cellbytelabel></td>
			<td width="12%"><cellbytelabel>Departamento</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Perfil Designado</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Fecha Crea</cellbytelabel>.</td>
			<td width="15%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String image = "../images/fingerprint-gray.png";
	if (isFpEnabled && !cdo.getColValue("hasFP").equals("0")) image = "../images/fingerprint-green.png";
	String imgLock = "../images/lock_green.png";
	String stsLock = "N";
	if (cdo.getColValue("block_status").equalsIgnoreCase("N")) { imgLock = "../images/lock_red.png"; stsLock = "Y"; }
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("user_type_desc")%></td>
			<td><%=cdo.getColValue("user_name")%></td>
			<td><%=cdo.getColValue("name")%></td>
			<td><%=cdo.getColValue("ref_code_display")%></td>
			<td><%=cdo.getColValue("department_name")%></td>
			<td><%=cdo.getColValue("profile_name")%></td>
			<td align="center"><%=(cdo.getColValue("user_status").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"%></td>
			<td align="center"><%=cdo.getColValue("fecha_crea")%></td>
			<td align="center">
				<% if (isFpEnabled) { %><div class="dicon"><authtype type='50'><img src="<%=image%>" style="cursor:pointer" onClick="javascript:setFP(<%=cdo.getColValue("user_id")%>)" border="0" width="24" height="24" title="Huella Digital"></authtype>&nbsp;</div><% } %>
				<div class="dicon"><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("user_id")%>)"><img src="../images/pencil.png" border="0" width="32" height="32" title="Editar Usuario"></a></authtype>&nbsp;</div>
				<div class="dicon"><authtype type='51'><a href="javascript:toggleStatus(<%=cdo.getColValue("user_id")%>,'<%=cdo.getColValue("user_name")%>','<%=stsLock%>');"><img src="<%=imgLock%>" border="0" width="32" height="32" title="Cambiar Estado de Bloqueo"></a></authtype>&nbsp;</div>
				<!--<div class="dicon"><authtype type='51'><a href="javascript:userInfoOnly(<%=cdo.getColValue("user_id")%>);"><img src="../images/info.png" border="0" width="32" height="32" title="User Info"></a></authtype>&nbsp;</div>-->
				<div class="dicon"><authtype type='52'><a href="javascript:viewAud(<%=cdo.getColValue("user_id")%>);"><img src="../images/audit.png" border="0" width="32" height="32" title="Ver Auditoría"></a></authtype>&nbsp;</div>
			</td>
			</tr>
<%
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
<%=fb.hidden("userType",userType)%>
<%=fb.hidden("user",user)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("refCode",refCode)%>
<%=fb.hidden("department",department)%>
<%=fb.hidden("profile",profile)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("all_roles",allRoles)%>
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
<%=fb.hidden("userType",userType)%>
<%=fb.hidden("user",user)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("refCode",refCode)%>
<%=fb.hidden("department",department)%>
<%=fb.hidden("profile",profile)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
<%=fb.hidden("all_roles",allRoles)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}
%>