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
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")) id = "0";
	else
	{
		if (id == null) throw new Exception("El Código del Tipo de Parámetro no es válido. Por favor intente nuevamente!");
		sql = "select code, description, status from tbl_sal_tipo_parametro where code='"+id+"'";
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Mantenimiento de Tipo de Parámetros "+document.title;
function checkCode(obj){if(hasDBData('<%=request.getContextPath()%>','(select * from tbl_sal_tipo_parametro where code!=\'<%=id%>\')','code=\''+obj.value+'\'','')){alert('El Código de Tipo de Parámetro ya existe!');obj.select();return false;}else if(getDBData('<%=request.getContextPath()%>','code','tbl_sal_tipo_parametro','code=\'<%=id%>\'','')!=obj.value&&hasDBData('<%=request.getContextPath()%>','tbl_sal_parametro','tipo=\''+obj.value+'\'','')){alert('No se permite cambiar el Tipo de Parámetro, ya está referenciado en los Parámetros!');obj.select();return false;}return true;}
function checkDesc(obj){if(hasDBData('<%=request.getContextPath()%>','(select * from tbl_sal_tipo_parametro where code!=\'<%=id%>\')','description=\''+obj.value+'\'','')){alert('La Descripción de Tipo de Parámetro ya existe!');obj.select();return false;}return true;}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - TIPO DE PARAMETROS"></jsp:param>
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
<%fb.appendJsValidation("if(!checkCode(document.form1.code))error++;if(!checkDesc(document.form1.description))error++;");%>
		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01" >
			<td width="22%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="78%"><%=fb.textBox("code",cdo.getColValue("code"),true,false,false,5,3,null,null,"onChange=\"javascript:checkCode(this)\"")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td><%=fb.textBox("description",cdo.getColValue("description"),true,false,false,75,100,null,null,"onChange=\"javascript:checkDesc(this)\"")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="3">Estado</cellbytelabel></td>
			<td><%=fb.select("status","A=ACTIVO,I=INACTIVO",cdo.getColValue("status"),false,viewMode,0,"Text10",null,null,"","")%></td>
		</tr>
		<tr class="TextRow02">
			<td align="right" colspan="2">
				<cellbytelabel id="4">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N")%><cellbytelabel id="5">Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O")%><cellbytelabel id="6">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="7">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false)%>
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
	cdo.setTableName("tbl_sal_tipo_parametro");
	cdo.addColValue("code",request.getParameter("code"));
	cdo.addColValue("description",request.getParameter("description"));
	cdo.addColValue("status",request.getParameter("status"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		//cdo.setAutoIncCol("code");
		//cdo.addPkColValue("code","");
		SQLMgr.insert(cdo);
		//id = SQLMgr.getPkColValue("code");
	}
	else if (mode.equalsIgnoreCase("edit"))
	{
		cdo.setWhereClause("code='"+id+"'");
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/tipo_parametro_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/tipo_parametro_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/tipo_parametro_list.jsp';
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