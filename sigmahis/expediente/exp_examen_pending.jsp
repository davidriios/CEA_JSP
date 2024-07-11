<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="ELMgr" scope="page" class="issi.expediente.ExamenesLabMgr" />
<%
/**
==================================================================================
sal310150
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ELMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
boolean viewMode = false;
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fp = request.getParameter("fp");

if (mode == null) mode = "add";

if (mode.equalsIgnoreCase("view")) viewMode = true;
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (fp == null) fp = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (fp.trim().equalsIgnoreCase("laboratorio")) appendFilter = " and exists (select null from tbl_cds_centro_servicio where codigo = a.centro_servicio and interfaz = 'LIS' and estado in ('A','I'))";	
	else if (fp.trim().equalsIgnoreCase("imagenologia")) appendFilter = " and exists (select null from tbl_cds_centro_servicio where codigo = a.centro_servicio and interfaz = 'RIS' and estado in ('A','I'))";
	
	sql = "select a.codigo, a.usuario, a.seleccionado, nvl(a.descripcion,' ') as descripcion, a.fecha_nacimiento, a.codigo_paciente, a.admision, a.pac_id, a.centro_servicio, (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) as cdsDesc from tbl_sal_ficha_procedimiento a, tbl_adm_admision z where a.pac_id = "+pacId+" and z.adm_root = "+noAdmision+" and z.pac_id = a.pac_id and z.secuencia = a.admision "+appendFilter;
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Orden Incompleta - '+document.title;

function doAction()
{
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ORDEN INCOMPLETA"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td colspan="4" align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),fb.POST);%>
<%=fb.formStart()%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("size",""+al.size())%>
		<tr class="TextHeader" align="center">
			<td width="3%">&nbsp;</td>
			<td width="25%"><cellbytelabel id="1">Centro</cellbytelabel></td>
			<td width="42%"><cellbytelabel id="2">Descripci&oacute;n del Estudio</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="3">Solicitado Por</cellbytelabel></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("centro_servicio"+i,cdo.getColValue("centro_servicio"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
		
		<tr class="<%=color%>" align="center">
			<td><%=fb.checkbox("seleccionado"+i,"S",(cdo.getColValue("seleccionado").equalsIgnoreCase("S")),viewMode,null,null,"")%></td>
			<td align="left"><%=cdo.getColValue("cdsDesc")%></td>
			<td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td><%=cdo.getColValue("usuario")%></td>
		</tr>
<%
}
if (al.size() == 0)
{

%>
		<tr class="TextRow01" align="center">
			<td colspan="4"><cellbytelabel id="4">No existe orden medica incompleta</cellbytelabel>!</td>
		</tr>
<%
}
%>
		<tr>
			<td colspan="4" align="right">
				<%=fb.submit("save","Cancelar Orden Incompleta",true,(al.size() == 0 || viewMode),null,null,null)%>
				<%=fb.button("close","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
			</td>
		</tr>
<%=fb.formEnd()%>
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
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
	   if (request.getParameter("seleccionado"+i) != null)
	   {	
			DetalleOrdenMed dom = new DetalleOrdenMed();
	
			dom.setPacId(pacId);
			//dom.setSecuencia(noAdmision);
			dom.setSecuencia(request.getParameter("admision"+i));
			dom.setProcedimiento(request.getParameter("codigo"+i));
			dom.setDescripcion(request.getParameter("descripcion"+i));
			dom.setCentroServicio(request.getParameter("centro_servicio"+i));
	
			al.add(dom);
		}
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ELMgr.cancelPendingProcedures(al);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (ELMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ELMgr.getErrMsg()%>');
<%
	for (int i=0; i<size; i++)
	{
%>
	<%=(fp.trim().equalsIgnoreCase("imagenologia"))?"if(window.opener.document.form001.xCds.value=="+request.getParameter("centro_servicio"+i)+")":""%>
	{
		<%if (request.getParameter("seleccionado"+i) != null){%>
		if(eval('window.opener.frames[\'iExaLab\'].document.getElementById(\'proc<%=request.getParameter("codigo"+i)%>\')'))eval('window.opener.frames[\'iExaLab\'].document.getElementById(\'proc<%=request.getParameter("codigo"+i)%>\')').checked=false;
		if(eval('window.opener.frames[\'iExaLab\'].document.getElementById(\'obser<%=request.getParameter("codigo"+i)%>\')'))eval('window.opener.frames[\'iExaLab\'].document.getElementById(\'obser<%=request.getParameter("codigo"+i)%>\')').value='';
		<%}%>
	}
<%
	}
%>
	window.opener.window.location.reload(true);
	window.location='../expediente/exp_examen_pending.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>';
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