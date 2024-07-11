<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="vCta" scope="session" class="java.util.Vector"/>
<%
/**
===============================================================================
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String anio = request.getParameter("anio");
String tipoInv = request.getParameter("tipoInv");
String unidad = request.getParameter("unidad");
String consec = request.getParameter("consec");

sbSql = new StringBuffer();
sbSql.append("select a.anio, a.tipo_inv, a.compania, a.codigo_ue, a.consec, a.descripcion, decode(a.categoria,1,'GENERADOR DE INGRESOS',2,'APOYO OPERATIVO',3,'APOYO ADMINISTRATIVO') as categoria, a.cantidad, decode(a.prioridad,1,'URGENTE',2,'MUY NECESARIO',3,'NECESARIO') as prioridad, a.codigo_proveedor, (select nombre_proveedor from tbl_com_proveedor where compania = a.compania and cod_provedor = a.codigo_proveedor) as descProveedor, a.origen, (select descripcion from tbl_sec_unidad_ejec where codigo = a.codigo_ue and compania = a.compania) as descUnidad, (select descripcion from tbl_con_tipo_inversion where tipo_inv = a.tipo_inv and compania = a.compania) as tipo_inv_desc from tbl_con_inversion_anual a where a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.anio = ");
sbSql.append(anio);
sbSql.append(" and a.codigo_ue = ");
sbSql.append(unidad);
sbSql.append(" and a.consec = ");
sbSql.append(consec);
CommonDataObject cdoAnual = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select to_number(a.mes) as mes, a.cantidad_presupuestada, a.aprobado, nvl(a.cantidad,0) as cantidad, a.ejecutado, a.extraordinario, nvl(a.anioant_ejecutado,0) as anioant_ejec, a.aprobado - (nvl(a.ejecutado,0) + nvl(a.extraordinario,0) + nvl(a.anioant_ejecutado,0)) as disponible from tbl_con_inversion_mensual a where a.tipo_inv = ");
sbSql.append(tipoInv);
sbSql.append(" and a.anio = ");
sbSql.append(anio);
sbSql.append(" and a.consec = ");
sbSql.append(consec);
sbSql.append(" and a.codigo_ue = ");
sbSql.append(unidad);
sbSql.append(" and a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" order by 1");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="99%" align="center" cellpadding="5" cellspacing="0">
<tr>
	<td height="5"></td>
</tr>
<tr>
	<td class="TableBorder">
		<table align="center" cellpadding="1" cellspacing="1">
		<tr class="TextHeader02">
			<td colspan="5"><cellbytelabel>Unidad Administrativa</cellbytelabel>:</br>&nbsp;&nbsp;<%="["+cdoAnual.getColValue("codigo_ue")+"] "+cdoAnual.getColValue("descUnidad")%></td>
			<td>A&ntilde;o:</br>&nbsp;&nbsp;<%=cdoAnual.getColValue("anio")%></td>
			<td colspan="2"><cellbytelabel>Prioridad</cellbytelabel>:</br>&nbsp;&nbsp;<%=cdoAnual.getColValue("prioridad")%></td>
		</tr>
		<tr class="TextHeader02">
			<td><cellbytelabel>Tipo Inversi&oacute;n</cellbytelabel>:</br>&nbsp;&nbsp;<%=cdoAnual.getColValue("tipo_inv_desc")%></td>
			<td colspan="5"><cellbytelabel>Descripci&oacute;n</cellbytelabel>:</br>&nbsp;&nbsp;<%=cdoAnual.getColValue("descripcion")%></td>
			<td colspan="2"><cellbytelabel>Categor&iacute;a</cellbytelabel>:</br>&nbsp;&nbsp;<%=cdoAnual.getColValue("categoria")%></td>
		</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("anio",anio)%>
		<tr class="TextHeader" align="center">
			<td width="17%"><cellbytelabel>Mes</cellbytelabel></td>
			<td width="9%"><cellbytelabel>Cant. Presup</cellbytelabel>.</td>
			<td width="13%"><cellbytelabel>Presup. Aprobado</cellbytelabel></td>
			<td width="9%"><cellbytelabel>Cant. Ejec</cellbytelabel>.</td>
			<td width="13%"><cellbytelabel>Presup. A&ntilde;o Actual</cellbytelabel></td>
			<td width="13%"><cellbytelabel>Presup. Extraordinario</cellbytelabel></td>
			<td width="13%"><cellbytelabel>Presup. A&ntilde;o Anterior</cellbytelabel></td>
			<td width="13%"><cellbytelabel>Disponible</cellbytelabel></td>
				</tr>
<%
int cantEjec = 0;
double presApro = 0.0, presAnioActual = 0.0, presExtr = 0.0, presAnioAnt = 0.0, disp = 0.0;

for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
%>
		<tr class="TextRow01" align="right">
			<td align="center"><%=fb.select("mesDesde"+i,"1=ENERO,2=FEBRERO,3=MARZO,4=ABRIL,5=MAYO,6=JUNIO,7=JULIO,8=AGOSTO,9=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",cdo.getColValue("mes"),false,true,0,null,null,null,"","")%></td>
			<td><%=cdo.getColValue("cantidad_presupuestada")%></td>
			<td><%=CmnMgr.getFormattedDecimal(cdo.getColValue("aprobado"))%></td>
			<td><%=cdo.getColValue("cantidad")%></td>
			<td><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ejecutado"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(cdo.getColValue("extraordinario"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(cdo.getColValue("anioant_ejec"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(cdo.getColValue("disponible"))%></td>
		</tr>
<%
presApro += Double.parseDouble(cdo.getColValue("aprobado"));
cantEjec += Double.parseDouble(cdo.getColValue("cantidad"));
presAnioActual += Double.parseDouble(cdo.getColValue("ejecutado"));
presExtr += Double.parseDouble(cdo.getColValue("extraordinario"));
presAnioAnt += Double.parseDouble(cdo.getColValue("anioant_ejec"));
disp += Double.parseDouble(cdo.getColValue("disponible"));
}
%>
<%=fb.formEnd(true)%>
		<tr class="TextHeader" align="right">
			<td colspan="2"><cellbytelabel>Totales</cellbytelabel> ----></td>
			<td><%=CmnMgr.getFormattedDecimal(presApro)%></td>
			<td><%=cantEjec%></td>
			<td><%=CmnMgr.getFormattedDecimal(presAnioActual)%></td>
			<td><%=CmnMgr.getFormattedDecimal(presExtr)%></td>
			<td><%=CmnMgr.getFormattedDecimal(presAnioAnt)%></td>
			<td><%=CmnMgr.getFormattedDecimal(disp)%></td>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
%>