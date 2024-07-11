<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.File"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.HL7"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLCreator"%>
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
ADM60096
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
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String fp = request.getParameter("fp");
String popWinFunction = "abrir_ventana1";

if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (!mode.equalsIgnoreCase("add") && !mode.equalsIgnoreCase("edit")) viewMode = true;
if (fp == null) fp = "";
if (fp.equalsIgnoreCase("admision")) popWinFunction = "abrir_ventana3";

if (request.getMethod().equalsIgnoreCase("GET"))
{

		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.secuencia, a.nombre as custNombre, b.nacionalidad as custNacional, c.nombre as custEmpresa, a.num_empleado as custNoEmpleado, a.ocupacion as custOcupacion FROM tbl_adm_custodio a, tbl_sec_pais b, tbl_adm_empresa c WHERE a.nacionalidad=b.codigo(+) and a.cod_empresa=c.codigo(+) and a.pac_id="+pacId;
		al = SQLMgr.getDataList(sql);


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Mantenimiento de Paciente - '+document.title;
function doAction(){}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("pacId",pacId)%>
		<tr>
			<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel id="1">Custodio</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel30">
			<td>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel id="2">No.Empleado</cellbytelabel></td>
					<td width="25%"><cellbytelabel id="3">Nombre</cellbytelabel></td>
					<td width="20%"><cellbytelabel id="4">Empresa</cellbytelabel></td>
					<td width="20%"><cellbytelabel id="5">Ocupaci&oacute;n</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="6">Nacionalidad</cellbytelabel></td>
					<td width="10%"><%=fb.button("agregar","+",true,viewMode,null,null,"onClick=\"javascript:add()\"")%></td>
				</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo2 = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo2.getColValue("custNoEmpleado")%><%=cdo2.getColValue("secuencia")%></td>
					<td><%=cdo2.getColValue("custNombre")%></td>
					<td><%=cdo2.getColValue("custEmpresa")%></td>
					<td><%=cdo2.getColValue("custOcupacion")%></td>
					<td><%=cdo2.getColValue("custNacional")%></td>
					<td align="center">
<%
	if (!viewMode)
	{
%>
						<a href="javascript:edit(<%=cdo2.getColValue("secuencia")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="7">Editar</cellbytelabel></a>
<%
	}
%>
					</td>
				</tr>
<%
}
%>
				</table>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}
%>
