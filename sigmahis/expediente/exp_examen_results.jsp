<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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
boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String codigo = request.getParameter("codigo");
String cod_solicitud = request.getParameter("cod_solicitud");
String fp = request.getParameter("fp");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (pacId == null || noAdmision == null || codigo == null || cod_solicitud == null) throw new Exception("La Solicitud no es válida. Por favor intente nuevamente!");
if (fp == null) fp = "imagenologia";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (fp.trim().equalsIgnoreCase("laboratorio"))
	{
		sql = "select z.solicitud, z.detalle_solic, z.admi_secuencia, z.admi_pac_fec_nac, z.admi_pac_codigo, z.secuencia, z.resultado, nvl(z.unidad_medida,' ') as unidad_medida, decode(is_varchar_valid_number(z.resultado),null,z.resultado,to_char(to_number(z.resultado),'999,999.99')||decode(z.unidad_medida,null,'',' '||z.unidad_medida)) as resultado_display, decode(z.valor_referencia_min,null,' ',z.valor_referencia_min) as valor_referencia_min, decode(z.valor_referencia_max,null,' ',z.valor_referencia_max) as valor_referencia_max, z.pac_id, coalesce(y.descripcion,z.observacion,' ') as observacion from tbl_cds_estructura_resultado z, tbl_cds_prueba y where z.pac_id="+pacId+" and z.admi_secuencia="+noAdmision+" and z.solicitud="+cod_solicitud+" and z.detalle_solic="+codigo+" and z.estado='A' and z.observacion=y.codigo_alfa(+)";
		al = SQLMgr.getDataList(sql);
	}
	else if (fp.trim().equalsIgnoreCase("imagenologia"))
	{
		sql = "select adenda as resultado from tbl_cds_resultado_adenda where pac_id="+pacId+" and admi_secuencia="+noAdmision+" and solicitud="+cod_solicitud+" and detalle_solic="+codigo+" and estado='A' and rownum=1 order by secuencia desc";
		al = SQLMgr.getDataList(sql);
		if (al.size() == 0)
		{
			sql = "select resultado from tbl_cds_estructura_resultado where pac_id="+pacId+" and admi_secuencia="+noAdmision+" and solicitud="+cod_solicitud+" and detalle_solic="+codigo+" and estado='A'";
			al = SQLMgr.getDataList(sql);
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Resultados del Estudio - '+document.title;

function doAction()
{
	document.getElementById('label_cpt').innerHTML=parent.window.document.form0.cpt.value;
	document.getElementById('label_cpt_desc').innerHTML=parent.window.document.form0.cpt_desc.value;
	if(document.getElementById('label_cds'))document.getElementById('label_cds').innerHTML=parent.window.document.form0.cds.value;
	if(document.getElementById('label_cds_desc'))document.getElementById('label_cds_desc').innerHTML=parent.window.document.form0.cds_desc.value;
	newHeight();
}

function printResult()
{
abrir_ventana2('../expediente/print_exp_examen_results.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codigo=<%=codigo%>&cod_solicitud=<%=cod_solicitud%>&fp=<%=fp%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" cellpadding="1" cellspacing="1">
<%
if (fp.trim().equalsIgnoreCase("imagenologia"))
{
%>
<tr class="TextHeader02">
	<td colspan="4" align="center">[<label id="label_cds"></label>] <label id="label_cds_desc"></label></td>
</tr>
<%
}
%>
<tr class="TextHeader01">
	<td colspan="3">[<label id="label_cpt"></label>] <label id="label_cpt_desc"></label></td>
	<td width="10%" align="right">
<%
if (al.size() != 0)
{
%>
	<a href="javascript:printResult()" class="Link03">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a>
<%
}
%>
</td>
</tr>
<%
if (fp.trim().equalsIgnoreCase("laboratorio"))
{
%>
<tr class="TextHeader" align="center">
	<td width="50%"><cellbytelabel id="2">Prueba</cellbytelabel></td>
	<td width="30%"><cellbytelabel id="3">Resultado (Unidades)</cellbytelabel></td>
	<td colspan="2"><cellbytelabel id="4">Valor Referencia</cellbytelabel></td>
</tr>
<%
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
%>
<tr class="<%=color%>">
	<td><%=cdo.getColValue("observacion")%></td>
	<td><%=cdo.getColValue("resultado_display")%></td>
	<td width="10%"><%=cdo.getColValue("valor_referencia_min")%></td>
	<td><%=cdo.getColValue("valor_referencia_max")%></td>
</tr>
<%
	}
}
else if (fp.trim().equalsIgnoreCase("imagenologia"))
{
%>
<tr class="TextHeader" align="center">
	<td colspan="4"><cellbytelabel id="5">Resultado</cellbytelabel></td>
</tr>
<%
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
%>
<tr class="<%=color%>">
	<td colspan="4"><%=cdo.getColValue("resultado")%></td>
</tr>
<%
	}
}
if (al.size() == 0)
{
%>
<tr class="TextRow01" align="center">
	<td colspan="4"><cellbytelabel id="6">No hay resultados para el estudio seleccionado</cellbytelabel>!</td>
</tr>
<%
}
%>
</table>
</body>
</html>
<%
}//GET
%>
