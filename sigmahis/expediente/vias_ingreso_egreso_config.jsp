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
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");

if (mode == null) mode = "add";
boolean viewMode = false;
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")) id = "0";
	else
	{
		if (id == null) throw new Exception("La Vía de Administración no es válida. Por favor intente nuevamente!");

		sql = "select codigo, descripcion, tipo_liquido,status from tbl_sal_via_admin where codigo="+id;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title='Vía de Adminstración - "+document.title;
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO - VIA DE ADMINISTRACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01" >
			<td width="20%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="80"><%=id%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,viewMode,50,100)%></td>
		</tr>
			<tr class="TextRow01">
			<td><cellbytelabel id="3">Tipo</cellbytelabel></td>
			<td><%=fb.select("tipo_liquido","I=INGRESO,E=EGRESO,M=MEDICAMENTO,D=DIABETICA",cdo.getColValue("tipo_liquido"),false,viewMode,0)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="4">Estatus</cellbytelabel></td>
			<td><%=fb.select("status","A=Activo,I=Inactivo",cdo.getColValue("status"),false,viewMode,0)%></td>
		</tr>
		<tr class="TextRow02">
			<td align="right" colspan="2">
				<cellbytelabel id="5">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="6">Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
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
	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_sal_via_admin");
	cdo.addColValue("descripcion",request.getParameter("descripcion"));
	cdo.addColValue("tipo_liquido",request.getParameter("tipo_liquido"));
	cdo.addColValue("status",request.getParameter("status"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");
		SQLMgr.insert(cdo);
		id = SQLMgr.getPkColValue("codigo");
	}
	else
	{
		cdo.setWhereClause("codigo="+request.getParameter("id"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/vias_ingreso_egreso_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/vias_ingreso_egreso_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/vias_ingreso_egreso_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>