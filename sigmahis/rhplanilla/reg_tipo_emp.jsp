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
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800011") || SecMgr.checkAccess(session.getId(),"800012"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Tipo de Empleado no es válido. Por favor intente nuevamente!");

		sql = "select codigo, descripcion, horas_tiempoext, nvl(minutos_contar,0) minutos_contar, nvl(minimo_minutos,0) minimo_minutos, nvl(dias_enfermedad,0) dias_enfermedad from tbl_pla_tipo_empleado where codigo="+id;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Recursos Humanos - '+document.title;

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CREAR TIPO DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<!--
		<tr class="TextRow01">
			<td width="15%" align="right">C&oacute;digo</td>
			<td width="*" colspan="3"><%//=fb.textBox("codigo",cdo.getColValue("codigo"),true,false,false,30,null,null,"")%></td>
		</tr>
		-->
		<tr class="TextRow01">
			<td width="15%" align="right">Descripci&oacute;n</td>
			<td colspan="3"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,40,null,null,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right">D&iacute;as de Enfermedad</td>
			<td width="35%"><%=fb.intBox("dias_enf",cdo.getColValue("dias_enfermedad"),false,false,false,30,null,null,"")%></td>
			<td width="17%" align="right">Horas Extras Permitidas</td>
			<td width="33%"><%=fb.intBox("horas_text",cdo.getColValue("horas_tiempoext"),true,false,false,40,null,null,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right">Minutos a Contar</td>
			<td width="35%"><%=fb.intBox("min_cont",cdo.getColValue("minutos_contar"),false,false,false,30,null,null,"")%></td>
			<td width="17%" align="right">Tiempo M&iacute;nimo(Mtos.)</td>
			<td width="33%"><%=fb.intBox("minimos_min",cdo.getColValue("minimo_minutos"),false,false,false,40,null,null,"")%></td>
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

	cdo.setTableName("tbl_pla_tipo_empleado");
	cdo.addColValue("descripcion",request.getParameter("descripcion"));
	cdo.addColValue("dias_enfermedad",request.getParameter("dias_enf"));
	cdo.addColValue("horas_tiempoext",request.getParameter("horas_text"));
	cdo.addColValue("minutos_contar",request.getParameter("min_cont"));
	cdo.addColValue("minimo_minutos",request.getParameter("minimos_min"));
	
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("codigo",request.getParameter("id"));
		cdo.setAutoIncCol("codigo");

		SQLMgr.insert(cdo);
	}
	else
	{
    cdo.setWhereClause("codigo="+request.getParameter("id"));

		SQLMgr.update(cdo);
	}
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/tipoempleado_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/tipoempleado_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/tipoempleado_list.jsp';
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