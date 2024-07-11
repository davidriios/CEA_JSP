<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	CommonDataObject tCdo = new CommonDataObject();
	tCdo.addColValue("total_cargo","0");
	tCdo.addColValue("total_factura","0");
	tCdo.addColValue("total_descuento","0");
	tCdo.addColValue("total_ajuste","0");
	tCdo.addColValue("total_perdiem","0");
	tCdo.addColValue("total_cargo_f","0");
	tCdo.addColValue("total_factura_f","0");
	tCdo.addColValue("total_descuento_f","0");
	tCdo.addColValue("total_ajuste_f","0");
	tCdo.addColValue("total_perdiem_f","0");
	tCdo.addColValue("total_cargo_a","0");
	tCdo.addColValue("total_factura_a","0");
	tCdo.addColValue("total_descuento_a","0");
	tCdo.addColValue("total_ajuste_a","0");
	tCdo.addColValue("total_perdiem_a","0");
	String nombre = request.getParameter("nombre");
	String pacId = request.getParameter("pacId");
	String admision = request.getParameter("admision");
	String fDate = request.getParameter("fDate");
	String tDate = request.getParameter("tDate");
	if (nombre == null) nombre = "";
	if (pacId == null) pacId = "";
	if (admision == null) admision = "";
	if (fDate == null) fDate = "";
	if (tDate == null) tDate = "";

	if (!nombre.trim().equals("")){
		sbFilter.append(" and exists (select null from tbl_adm_paciente where pac_id = z.pac_id and upper(primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' DE '||apellido_de_casada))) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%')");
	}
	if (!pacId.trim().equals("")) { sbFilter.append(" and z.pac_id like '%"); sbFilter.append(pacId); sbFilter.append("%'"); }
	if (!admision.trim().equals("")) { sbFilter.append(" and z.admi_secuencia like '%"); sbFilter.append(admision); sbFilter.append("%'"); }

	if (request.getParameter("nombre") != null) {

		sbSql = new StringBuffer();
		sbSql.append("select 0 as group_by, z.fecha as order_by, z.pac_id, z.admi_secuencia as admision, to_char(z.fecha,'dd/mm/yyyy') as fecha, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' DE '||apellido_de_casada)) from tbl_adm_paciente where pac_id = z.pac_id) as nombre, nvl((select sum(decode(tipo_transaccion,'D',-cantidad,cantidad) * (monto + nvl(recargo,0))) from tbl_fac_detalle_transaccion where pac_id = z.pac_id and fac_secuencia = z.admi_secuencia),0) as monto_cargo, sum(z.grang_total) as monto_factura, sum(z.monto_descuento) as monto_descuento, nvl(sum(nvl((select sum(decode(lado_mov,'D',monto,-monto)) from vw_con_adjustment_gral a where compania = z.compania and factura = z.codigo and not exists (select null from tbl_fac_tipo_ajuste where compania = z.compania and group_type in ('E') and codigo = a.tipo_ajuste)),0)),0) as monto_ajuste");
		//sbSql.append(", nvl(sum(nvl((select sum(a.monto - a.monto_cubierto) from tbl_fac_limit_det a where exists (select null from tbl_fac_limit where id = a.id and pac_id = z.pac_id and admision = z.admi_secuencia and factura = z.codigo and compania = z.compania)),0)),0) as monto_perdiem");
		sbSql.append(", nvl(sum(nvl((select monto from tbl_fac_detalle_factura where fac_codigo = z.codigo and compania = z.compania and imprimir_sino = 'N'),0)),0) as monto_perdiem");
		sbSql.append(" from tbl_fac_factura z where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		if (!fDate.trim().equals("")) { sbSql.append(" and z.fecha >= to_date('"); sbSql.append(fDate); sbSql.append("','dd/mm/yyyy')"); }
		if (!tDate.trim().equals("")) { sbSql.append(" and z.fecha <= to_date('"); sbSql.append(tDate); sbSql.append("','dd/mm/yyyy')"); }
		sbSql.append(" and facturar_a <> 'O'");
		sbSql.append(" and exists (select * from tbl_fac_factura a where a.pac_id = z.pac_id and a.admi_secuencia = z.admi_secuencia and facturar_a <> 'O' and exists (select null from tbl_fac_detalle_factura where compania = a.compania and fac_codigo = a.codigo and imprimir_sino = 'N'))");
		sbSql.append(" and exists (select null from tbl_fac_detalle_factura where compania = z.compania and fac_codigo = z.codigo and imprimir_sino = 'N')");
		sbSql.append(" group by z.pac_id, z.admi_secuencia, z.fecha");

		sbSql.append(" union all select 1 as group_by, z.fecha as order_by, z.pac_id, z.admi_secuencia as admision, to_char(z.fecha,'dd/mm/yyyy') as fecha, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' DE '||apellido_de_casada)) from tbl_adm_paciente where pac_id = z.pac_id) as nombre, -nvl((select sum(decode(tipo_transaccion,'D',-cantidad,cantidad) * (monto + nvl(recargo,0))) from tbl_fac_detalle_transaccion where pac_id = z.pac_id and fac_secuencia = z.admi_secuencia),0) as monto_cargo, -sum(z.grang_total) as monto_factura, -sum(z.monto_descuento) as monto_descuento, -nvl(sum(nvl((select sum(decode(lado_mov,'D',monto,-monto)) from vw_con_adjustment_gral a where compania = z.compania and factura = z.codigo and not exists (select null from tbl_fac_tipo_ajuste where compania = z.compania and group_type in ('E') and codigo = a.tipo_ajuste)),0)),0) as monto_ajuste");
		//sbSql.append(", -nvl(sum(nvl((select sum(a.monto - a.monto_cubierto) from tbl_fac_limit_det a where exists (select null from tbl_fac_limit where id = a.id and pac_id = z.pac_id and admision = z.admi_secuencia and factura = z.codigo and compania = z.compania)),0)),0) as monto_perdiem");
		sbSql.append(", -nvl(sum(nvl((select monto from tbl_fac_detalle_factura where fac_codigo = z.codigo and compania = z.compania and imprimir_sino = 'N'),0)),0) as monto_perdiem");
		sbSql.append(" from tbl_fac_factura z where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		if (!fDate.trim().equals("")) { sbSql.append(" and z.fecha_anulacion >= to_date('"); sbSql.append(fDate); sbSql.append("','dd/mm/yyyy')"); }
		if (!tDate.trim().equals("")) { sbSql.append(" and z.fecha_anulacion <= to_date('"); sbSql.append(tDate); sbSql.append("','dd/mm/yyyy')"); }
		sbSql.append(" and facturar_a <> 'O' and estatus = 'A'");
		sbSql.append(" and exists (select * from tbl_fac_factura a where a.pac_id = z.pac_id and a.admi_secuencia = z.admi_secuencia and facturar_a <> 'O' and estatus = 'A' and exists (select null from tbl_fac_detalle_factura where compania = a.compania and fac_codigo = a.codigo and imprimir_sino = 'N'))");
		sbSql.append(" and exists (select null from tbl_fac_detalle_factura where compania = z.compania and fac_codigo = z.codigo and imprimir_sino = 'N')");
		sbSql.append(" group by z.pac_id, z.admi_secuencia, z.fecha");

		sbSql.append(" order by 1, 2, 6");

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		tCdo = SQLMgr.getData("select count(*) as count, nvl(sum(monto_cargo),0) as total_cargo, nvl(sum(monto_factura),0) as total_factura, nvl(sum(monto_descuento),0) as total_descuento, nvl(sum(monto_ajuste),0) as total_ajuste, nvl(sum(monto_perdiem),0) as total_perdiem, nvl(sum(decode(group_by,0,monto_cargo,0)),0) as total_cargo_f, nvl(sum(decode(group_by,0,monto_factura,0)),0) as total_factura_f, nvl(sum(decode(group_by,0,monto_descuento,0)),0) as total_descuento_f, nvl(sum(decode(group_by,0,monto_ajuste,0)),0) as total_ajuste_f, nvl(sum(decode(group_by,0,monto_perdiem,0)),0) as total_perdiem_f, nvl(sum(decode(group_by,1,monto_cargo,0)),0) as total_cargo_a, nvl(sum(decode(group_by,1,monto_factura,0)),0) as total_factura_a, nvl(sum(decode(group_by,1,monto_descuento,0)),0) as total_descuento_a, nvl(sum(decode(group_by,1,monto_ajuste,0)),0) as total_ajuste_a, nvl(sum(decode(group_by,1,monto_perdiem,0)),0) as total_perdiem_a from ("+sbSql+")");
		if (tCdo != null) rowCount = Integer.parseInt(tCdo.getColValue("count"));

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
<script language="javascript">
document.title = 'Facturacion - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,350);}
function printList(){abrir_ventana('../cellbyteWV/report_container.jsp?reportName=facturacion/perdiem.rptdesign&filter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&fDate=<%=fDate%>&tDate=<%=tDate%>&pCtrlHeader=true');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION - PERDIEM"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td>
				<cellbytelabel>Paciente</cellbytelabel>
				<%=fb.textBox("nombre",nombre,false,false,false,30)%>
				<cellbytelabel>Pac. ID</cellbytelabel>
				<%=fb.intBox("pacId",pacId,false,false,false,10)%>
				<cellbytelabel>Admisi&oacute;n</cellbytelabel>
				<%=fb.intBox("admision",admision,false,false,false,8)%>
				<cellbytelabel>Fecha</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="fDate"/>
				<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
				<jsp:param name="nameOfTBox2" value="tDate"/>
				<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
</tr>
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
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
		<tr class="TextHeader" align="center">
			<td width="26%"><cellbytelabel>Paciente</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Pac. ID</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Admisi&oacute;n</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Monto Cargos</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Monto Fact.</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Descuentos</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Ajustes</cellbytelabel></td>
			<td width="8%"><cellbytelabel>PERDIEM</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
String groupBy = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!groupBy.equals(cdo.getColValue("group_by"))) {
%>
		<tr class="TextHeader01">
			<td colspan="10" align="center"><%=(cdo.getColValue("group_by").equals("0"))?"F A C T U R A D A S":"A N U L A D A S"%></td>
		</tr>
<%
	}
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("nombre")%></td>
			<td align="center"><%=cdo.getColValue("pac_id")%></td>
			<td align="center"><%=cdo.getColValue("admision")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cargo"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_factura"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_descuento"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_ajuste"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_perdiem"))%></td>
			<td>&nbsp;</td>
		</tr>
<% 
	groupBy = cdo.getColValue("group_by");
}
%>
<%=fb.formEnd()%>
		<tr class="TextHeader" align="right">
			<td colspan="4">T O T A L E S &nbsp; F A C T U R A D A S</td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_cargo_f"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_factura_f"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_descuento_f"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_ajuste_f"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_perdiem_f"))%></td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextHeader" align="right">
			<td colspan="4">T O T A L E S &nbsp; A N U L A D A S</td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_cargo_a"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_factura_a"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_descuento_a"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_ajuste_a"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_perdiem_a"))%></td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextHeader" align="right">
			<td colspan="4">T O T A L E S &nbsp; F I N A L E S</td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_cargo"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_factura"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_descuento"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_ajuste"))%></td>
			<td><%=CmnMgr.getFormattedDecimal(tCdo.getColValue("total_perdiem"))%></td>
			<td>&nbsp;</td>
		</tr>
		</table>
</div>
</div>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
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
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
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
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("fDate",fDate)%>
<%=fb.hidden("tDate",tDate)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<% } %>
