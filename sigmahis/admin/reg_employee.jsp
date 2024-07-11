<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
==================================================================================
100015	VER LISTA DE EMPLEADOS
100016	IMPRIMIR LISTA DE EMPLEADOS
100017	AGREGAR EMPLEADO
100018	MODIFICAR EMPLEADO
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100017") || SecMgr.checkAccess(session.getId(),"100018"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("code","");
		cdo.addColValue("joinDate",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		cdo.addColValue("other2","NA");
	}
	else
	{
		if (id == null) throw new Exception("El Empleado no es válido. Por favor intente nuevamente!");

		sql = "select emp_code code, emp_name name, emp_age age, emp_tele phone, emp_tadd currentAddress, emp_padd permanentAddress, emp_deprt departmentId, emp_default_profile profileId, emp_psal lastSalary, emp_present_sal currentSalary, to_char(emp_jdate,'dd/mm/yyyy') joinDate, emp_status status, company_id compId, other1, other2 from tbl_sec_employees where emp_id="+id;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Administración - '+document.title;

function checkCode(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_sec_employees','emp_code=\''+obj.value+'\'','<%=cdo.getColValue("code")%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CREAR EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("compId",cdo.getColValue("compId"))%>
<%=fb.hidden("other1",cdo.getColValue("other1"))%>
<%=fb.hidden("other2",cdo.getColValue("other2"))%>
<%fb.appendJsValidation("if(checkCode(document.form1.code))error++;");%>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("code",cdo.getColValue("code"),true,false,false,30,null,null,"onBlur=\"javascript:checkCode(this)\"")%></td>
			<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("name",cdo.getColValue("name"),true,false,false,40)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Edad</td>
			<td><%=fb.intBox("age",cdo.getColValue("age"))%></td>
			<td align="right"><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
			<td><%=fb.textBox("phone",cdo.getColValue("phone"))%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Direcci&oacute;n Actual</cellbytelabel></td>
			<td><%=fb.textarea("currentAddress",cdo.getColValue("currentAddress"),true,false,false,30,2)%></td>
			<td align="right"><cellbytelabel>Direcci&oacute;n Permanente</cellbytelabel></td>
			<td><%=fb.textarea("permanentAddress",cdo.getColValue("permanentAddress"),false,false,false,30,2)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Departamento</cellbytelabel></td>
			<td><%=fb.select(ConMgr.getConnection(),"select id, code||' - '||name from tbl_sec_department where status='A' order by name","departmentId",cdo.getColValue("departmentId"))%></td>
			<td align="right"><cellbytelabel>Designaci&oacute;n</cellbytelabel></td>
			<td><%=fb.select(ConMgr.getConnection(),"select profile_id, profile_name from tbl_sec_profiles where profile_id!=0 order by profile_name","profileId",cdo.getColValue("profileId"))%></td>
		</tr>
		<!--<tr class="TextRow01">
			<td align="right">&nbsp;</td>
			<td>&nbsp;</td>
			<td align="right">Compa&ntilde;&iacute;a</td>
			<td><%//=fb.select(ConMgr.getConnection(),"select 0 company_id, '- NO APLICA -' com_legal_name from dual union select company_id, com_legal_name from tbl_sec_company order by com_legal_name","compId",cdo.getColValue("compId"))%></td>
		</tr>-->
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Sueldo Anterior</cellbytelabel></td>
			<td><%=fb.decBox("lastSalary",cdo.getColValue("lastSalary"))%></td>
			<td align="right"><cellbytelabel>Sueldo Actual</cellbytelabel></td>
			<td><%=fb.decBox("currentSalary",cdo.getColValue("currentSalary"))%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Fecha Inicio</cellbytelabel></td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="joinDate" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("joinDate")%>" />
				</jsp:include>
			</td>
			<td align="right"><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("status","A=Activo,I=Inactivo",cdo.getColValue("status"))%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_sec_employees");
	cdo.addColValue("emp_code",request.getParameter("code"));
	cdo.addColValue("emp_name",request.getParameter("name"));
	cdo.addColValue("emp_age",request.getParameter("age"));
	cdo.addColValue("emp_tele",request.getParameter("phone"));
	cdo.addColValue("emp_tadd",request.getParameter("currentAddress"));
	cdo.addColValue("emp_padd",request.getParameter("permanentAddress"));
	cdo.addColValue("emp_deprt",request.getParameter("departmentId"));
	cdo.addColValue("emp_default_profile",request.getParameter("profileId"));
	cdo.addColValue("emp_psal",request.getParameter("lastSalary"));
	cdo.addColValue("emp_present_sal",request.getParameter("currentSalary"));
	cdo.addColValue("emp_jdate",request.getParameter("joinDate"));
	cdo.addColValue("emp_status",request.getParameter("status"));
	cdo.addColValue("company_id",request.getParameter("compId"));
	cdo.addColValue("other1",request.getParameter("other1"));
	cdo.addColValue("other2",request.getParameter("other2"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("emp_id",request.getParameter("id"));
		cdo.setAutoIncCol("emp_id");

		SQLMgr.insert(cdo);
	}
	else
	{
    cdo.setWhereClause("emp_id="+request.getParameter("id"));

		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/list_employee.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/list_employee.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/list_employee.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>