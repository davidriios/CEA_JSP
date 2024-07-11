<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
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

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
int rowCount = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	
	sql = "select CODIGO, resumen, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIF, to_char(FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF from TBL_SAL_RESUMEN_CLINICO where pac_id="+pacId+" and admision="+noAdmision;
	cdo = SQLMgr.getData(sql);

	if (cdo == null)
	{
		if (!viewMode) modeSec = "add";
		cdo = new CommonDataObject();

		cdo.addColValue("CODIGO","1");
		cdo.addColValue("USUARIO_CREAC",(String) session.getAttribute("_userName"));
		cdo.addColValue("FECHA_CREAC",cDateTime);
		cdo.addColValue("USUARIO_MODIF",(String) session.getAttribute("_userName"));
		cdo.addColValue("FECHA_MODIF",cDateTime);
	}
	else if (!viewMode) modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'EXPEDIENTE - RESUMEN CLINICO - '+document.title;
function doAction(){newHeight();}
function imprimirExp(){abrir_ventana('../expediente/print_exp_seccion_45.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1" >
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("usuario_creac",cdo.getColValue("USUARIO_CREAC"))%>
<%=fb.hidden("fecha_creac",cdo.getColValue("FECHA_CREAC"))%>
<%=fb.hidden("usuario_modific",cdo.getColValue("USUARIO_MODIF"))%>
<%=fb.hidden("fecha_modific",cdo.getColValue("FECHA_MODIF")) %>
<%=fb.hidden("codigo",cdo.getColValue("CODIGO"))%>
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02">
			<td align="right">&nbsp;<a href="javascript:imprimirExp()" class="Link00">[<cellbytelabel id="1">Imprimir</cellbytelabel>]</a></td>
		</tr>
		<tr class="TextRow01">
			<td>
				<cellbytelabel id="2">Resumen Cl&iacute;nico</cellbytelabel>:
				<%=fb.textarea("resumen",cdo.getColValue("resumen"),true,false,viewMode,60,6,2000,"","width:100%","")%>
			</td>
		</tr>
		<tr class="TextRow02" align="right">
			<td>
				<cellbytelabel id="3">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="4">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="5">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%fb.appendJsValidation("if(error>0)doAction();");%>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	cdo = new CommonDataObject();

	cdo.setTableName("tbl_sal_resumen_clinico");
	cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision="+request.getParameter("noAdmision"));
	
	cdo.addColValue("resumen",request.getParameter("resumen"));
	cdo.addColValue("USUARIO_CREAC",request.getParameter("usuario_creac"));
	cdo.addColValue("FECHA_CREAC",request.getParameter("fecha_creac"));
	cdo.addColValue("USUARIO_MODIF",request.getParameter("usuario_modific"));
	cdo.addColValue("FECHA_MODIF",request.getParameter("fecha_modific"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
	{
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("ADMISION",request.getParameter("noAdmision"));
		cdo.addColValue("CODIGO",request.getParameter("codigo"));
		
		SQLMgr.insert(cdo);
	}
	else
	{
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision="+request.getParameter("noAdmision"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
	parent.doRedirect(0);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

