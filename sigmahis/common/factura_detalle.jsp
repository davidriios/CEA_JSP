<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ArrayList"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="CmnMgr" scope="session" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="session" class="issi.admin.SQLMgr"/>
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

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String factura = request.getParameter("factura");
if (factura == null) factura = "";
if (factura.trim().equals("")) throw new Exception("La Factura no es válida. Por favor intente nuevamente!");

sbSql.append("select z.codigo as factura, z.admi_secuencia as admision, (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = z.pac_id) as dob, z.admi_codigo_paciente as pacCode, to_char(z.fecha,'dd/mm/yyyy') as fecha, z.grang_total as monto, nvl((select nombre_paciente from vw_adm_paciente where pac_id = z.pac_id),z.nombre_cliente) as nombre, (select to_char(fecha_ingreso,'dd/mm/yyyy') from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.admi_secuencia) as fIngreso, (select (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) from tbl_adm_admision a where a.pac_id = z.pac_id and a.secuencia = z.admi_secuencia) as categoria, (select nombre from tbl_adm_empresa where codigo = z.cod_empresa) as aseguradora, (select to_char(max(a.fecha),'dd/mm/yyyy') from tbl_cja_transaccion_pago a where a.rec_status <> 'I' and exists (select null from tbl_cja_detalle_pago where fac_codigo = z.codigo and codigo_transaccion = a.codigo and compania = a.compania and tran_anio = a.anio)) as fPago from tbl_fac_factura z where z.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and z.codigo = '");
sbSql.append(factura);
sbSql.append("'");
CommonDataObject fact = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select zz.*, (zz.monto_neto + zz.ajustes - zz.pagos) as saldo, (select tipo_cds from tbl_cds_centro_servicio where codigo = zz.centro_servicio) as tipo_cds, getCodDetECF(zz.codigo,zz.tipo,zz.centro_servicio,zz.facturar_a,zz.medico,zz.med_empresa,zz.compania) as codigo_cs, nvl(getDescDetECF(zz.codigo,zz.tipo,zz.centro_servicio,zz.facturar_a,zz.medico,zz.med_empresa,zz.compania),zz.descripcion) as descripcion_cs from (");

	sbSql.append("select z.compania, z.codigo, z.facturar_a, z.admi_secuencia,z.admi_codigo_paciente, z.fecha, z.cod_empresa, z.pac_id, z.grang_total, y.tipo, y.med_empresa, y.medico, y.centro_servicio, sum(y.monto + nvl(y.descuento,0) + nvl(y.descuento2,0)) as monto_bruto, sum(nvl(y.descuento,0) + nvl(y.descuento2,0)) as monto_desc, sum(y.monto) as monto_neto");
	sbSql.append(", nvl(case");
		sbSql.append(" when y.medico is not null then (select sum(decode(a.lado_mov,'D',a.monto,-a.monto)) from vw_con_adjustment_gral a where a.compania = z.compania and a.factura = z.codigo and a.medico = y.medico)");
		sbSql.append(" when y.med_empresa is not null then (select sum(decode(a.lado_mov,'D',a.monto,-a.monto)) from vw_con_adjustment_gral a where a.compania = z.compania and a.factura = z.codigo and a.empresa = y.med_empresa)");
		sbSql.append(" when y.centro_servicio is not null then (select sum(decode(a.lado_mov,'D',a.monto,-a.monto)) from vw_con_adjustment_gral a where a.compania = z.compania and a.factura = z.codigo and a.centro = y.centro_servicio)");
		sbSql.append(" else (select sum(decode(a.lado_mov,'D',a.monto,-a.monto)) from vw_con_adjustment_gral a where a.compania = z.compania and a.factura = z.codigo and a.medico is null and a.empresa is null and a.centro is null)");
	sbSql.append(" end,0) as ajustes");
	sbSql.append(", nvl(case");
		sbSql.append(" when y.medico is not null then (select sum(nvl(a.monto,0)) from tbl_cja_distribuir_pago a where a.fac_codigo = z.codigo and a.compania = z.compania and a.med_codigo = y.medico and (a.tipo_cobertura not in ('P','CO') or a.tipo_cobertura is null) and exists (select null from tbl_cja_transaccion_pago where codigo = a.codigo_transaccion and compania = a.compania and anio = a.tran_anio and rec_status <> 'I') and exists (select null from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.tran_anio and codigo_transaccion = a.codigo_transaccion and cod_rem is null))");
		sbSql.append(" when y.med_empresa is not null then (select sum(nvl(a.monto,0)) from tbl_cja_distribuir_pago a where a.fac_codigo = z.codigo and a.compania = z.compania and a.empre_codigo = y.med_empresa and (a.tipo_cobertura not in ('P','CO') or a.tipo_cobertura is null) and exists (select null from tbl_cja_transaccion_pago where codigo = a.codigo_transaccion and compania = a.compania and anio = a.tran_anio and rec_status <> 'I') and exists (select null from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.tran_anio and codigo_transaccion = a.codigo_transaccion and cod_rem is null))");
		sbSql.append(" when y.centro_servicio is not null then (select sum(nvl(a.monto,0)) from tbl_cja_distribuir_pago a where a.fac_codigo = z.codigo and a.compania = z.compania and a.centro_servicio = y.centro_servicio and (a.tipo_cobertura not in ('P','CO') or a.tipo_cobertura is null) and exists (select null from tbl_cja_transaccion_pago where codigo = a.codigo_transaccion and compania = a.compania and anio = a.tran_anio and rec_status <> 'I') and exists (select null from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.tran_anio and codigo_transaccion = a.codigo_transaccion and cod_rem is null))");
		sbSql.append(" else (select sum(nvl(a.monto,0)) from tbl_cja_distribuir_pago a where a.fac_codigo = z.codigo and a.compania = z.compania and a.med_codigo is null and a.empre_codigo is null and a.centro_servicio is null and (a.tipo_cobertura not in ('P','CO') or a.tipo_cobertura is null) and exists (select null from tbl_cja_transaccion_pago where codigo = a.codigo_transaccion and compania = a.compania and anio = a.tran_anio and rec_status <> 'I') and exists (select null from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.tran_anio and codigo_transaccion = a.codigo_transaccion and cod_rem is null))");
	sbSql.append(" end,0) as pagos,y.descripcion");
	sbSql.append(" from tbl_fac_factura z, tbl_fac_detalle_factura y");
	sbSql.append(" where z.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.codigo = '");
	sbSql.append(factura);
	sbSql.append("' and z.estatus <> 'A' and z.compania = y.compania and z.codigo = y.fac_codigo and (y.tipo_cobertura <> 'CI' or y.tipo_cobertura is null)");
	sbSql.append(" group by z.compania, z.codigo, z.facturar_a, z.admi_secuencia,z.admi_codigo_paciente, z.fecha, z.cod_empresa, z.pac_id, z.grang_total, y.tipo, y.med_empresa, y.medico, y.centro_servicio,y.descripcion");

	sbSql.append(" union all ");

	sbSql.append("select z.compania, z.codigo, z.facturar_a, z.admi_secuencia,z.admi_codigo_paciente, z.fecha, z.cod_empresa, z.pac_id, z.grang_total, y.tipo, y.empresa, y.medico, y.centro, 0 as monto_bruto, 0 as monto_desc, 0 as monto_neto");
	sbSql.append(", nvl(case");
		sbSql.append(" when y.medico is not null then (select sum(decode(a.lado_mov,'D',a.monto,-a.monto)) from vw_con_adjustment_gral a where a.compania = z.compania and a.factura = z.codigo and a.medico = y.medico)");
		sbSql.append(" when y.empresa is not null then (select sum(decode(a.lado_mov,'D',a.monto,-a.monto)) from vw_con_adjustment_gral a where a.compania = z.compania and a.factura = z.codigo and a.empresa = y.empresa)");
		sbSql.append(" when y.centro is not null then (select sum(decode(a.lado_mov,'D',a.monto,-a.monto)) from vw_con_adjustment_gral a where a.compania = z.compania and a.factura = z.codigo and a.centro = y.centro)");
		sbSql.append(" else (select sum(decode(a.lado_mov,'D',a.monto,-a.monto)) from vw_con_adjustment_gral a where a.compania = z.compania and a.factura = z.codigo and a.medico is null and a.empresa is null and a.centro is null)");
	sbSql.append(" end,0) as ajustes");
	sbSql.append(", nvl(case");
		sbSql.append(" when y.medico is not null then (select sum(nvl(a.monto,0)) from tbl_cja_distribuir_pago a where a.fac_codigo = z.codigo and a.compania = z.compania and a.med_codigo = y.medico and (a.tipo_cobertura not in ('P','CO') or a.tipo_cobertura is null) and exists (select null from tbl_cja_transaccion_pago where codigo = a.codigo_transaccion and compania = a.compania and anio = a.tran_anio and rec_status <> 'I') and exists (select null from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.tran_anio and codigo_transaccion = a.codigo_transaccion and cod_rem is null))");
		sbSql.append(" when y.empresa is not null then (select sum(nvl(a.monto,0)) from tbl_cja_distribuir_pago a where a.fac_codigo = z.codigo and a.compania = z.compania and a.empre_codigo = y.empresa and (a.tipo_cobertura not in ('P','CO') or a.tipo_cobertura is null) and exists (select null from tbl_cja_transaccion_pago where codigo = a.codigo_transaccion and compania = a.compania and anio = a.tran_anio and rec_status <> 'I') and exists (select null from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.tran_anio and codigo_transaccion = a.codigo_transaccion and cod_rem is null))");
		sbSql.append(" when y.centro is not null then (select sum(nvl(a.monto,0)) from tbl_cja_distribuir_pago a where a.fac_codigo = z.codigo and a.compania = z.compania and a.centro_servicio = y.centro and (a.tipo_cobertura not in ('P','CO') or a.tipo_cobertura is null) and exists (select null from tbl_cja_transaccion_pago where codigo = a.codigo_transaccion and compania = a.compania and anio = a.tran_anio and rec_status <> 'I') and exists (select null from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.tran_anio and codigo_transaccion = a.codigo_transaccion and cod_rem is null))");
		sbSql.append(" else (select sum(nvl(a.monto,0)) from tbl_cja_distribuir_pago a where a.fac_codigo = z.codigo and a.compania = z.compania and a.med_codigo is null and a.empre_codigo is null and a.centro_servicio is null and (a.tipo_cobertura not in ('P','CO') or a.tipo_cobertura is null) and exists (select null from tbl_cja_transaccion_pago where codigo = a.codigo_transaccion and compania = a.compania and anio = a.tran_anio and rec_status <> 'I') and exists (select null from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.tran_anio and codigo_transaccion = a.codigo_transaccion and cod_rem is null))");
	sbSql.append(" end,0) as pagos,''");
	sbSql.append(" from tbl_fac_factura z, vw_con_adjustment_gral y");
	sbSql.append(" where z.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and z.codigo = '");
	sbSql.append(factura);
	sbSql.append("' and z.estatus <> 'A' and z.compania = y.compania and z.codigo = y.factura and not exists (select null from tbl_fac_detalle_factura where compania = z.compania and fac_codigo = z.codigo and med_empresa||'-'||medico||'-'||centro_servicio = y.empresa||'-'||y.medico||'-'||y.centro)");
	sbSql.append(" group by z.compania, z.codigo, z.facturar_a, z.admi_secuencia,z.admi_codigo_paciente, z.fecha, z.estatus, z.cod_empresa, z.pac_id, z.grang_total, z.anio, y.tipo, y.empresa, y.medico, y.centro");

sbSql.append(") zz order by lpad(getCodDetECF(zz.codigo,zz.tipo,zz.centro_servicio,zz.facturar_a,zz.medico,zz.med_empresa,zz.compania),5,'0')");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Detalle Factura x Centro - '+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("factura",factura)%>
		<tr>
			<td colspan="7" align="right" class="TableBorder">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader02">
					<td width="25%">Factura <label class="YellowText Text14">#<%=fact.getColValue("factura")%></label></td>
					<td width="25%" align="right">Fecha: <label class="YellowText"><%=fact.getColValue("fecha")%></label></td>
					<td>&nbsp;</td>
					<td colspan="2" align="center">Monto: <label class="YellowText"><%=fact.getColValue("monto")%></label></td>
					<td colspan="2" align="center">Ultimo Pago: <label class="YellowText"><%=fact.getColValue("fPago")%></label></td>
				</tr>
				<tr class="TextHeader02" align="center">
					<td colspan="2">Nombre</td>
					<td width="10%">Fecha Nac.</td>
					<td width="10%">C&oacute;d.</td>
					<td width="10%">Admisi&oacute;n</td>
					<td width="10%">Categor&iacute;a</td>
					<td width="10%">Fecha Ing.</td>
				</tr>
				<tr class="TextHeader02 YellowTextBold" align="center">
					<td colspan="2" align="left"><%=fact.getColValue("nombre")%></td>
					<td><%=fact.getColValue("dob")%></td>
					<td><%=fact.getColValue("pacCode")%></td>
					<td><%=fact.getColValue("admision")%></td>
					<td><%=fact.getColValue("categoria")%></td>
					<td><%=fact.getColValue("fIngreso")%></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="10%">C&oacute;digo</td>
			<td width="40%">Descripci&oacute;n</td>
			<td width="10%">Monto</td>
			<td width="10%">Descuento</td>
			<td width="10%">Ajustes</td>
			<td width="10%">Pagos</td>
			<td width="10%">Saldo</td>
		</tr>
<%
double saldo = 0;
double tMonto = 0, tDescuento = 0, tAjuste = 0, tPago = 0, tSaldo = 0;
double tClinica = 0, tTerceros = 0, tHonorarios = 0, tEmpresas = 0;
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	saldo = Double.parseDouble(cdo.getColValue("saldo"));
	tMonto += Double.parseDouble(cdo.getColValue("monto_bruto"));
	tDescuento += Double.parseDouble(cdo.getColValue("monto_desc"));
	tAjuste += Double.parseDouble(cdo.getColValue("ajustes"));
	tPago += Double.parseDouble(cdo.getColValue("pagos"));
	tSaldo += saldo;
	if (cdo.getColValue("tipo").equalsIgnoreCase("C") && cdo.getColValue("tipo_cds").equalsIgnoreCase("T")) tTerceros += saldo;
	else if (cdo.getColValue("tipo").equalsIgnoreCase("C") && !cdo.getColValue("tipo_cds").equalsIgnoreCase("T")) tClinica += saldo;
	else if (cdo.getColValue("tipo").equalsIgnoreCase("H")) tHonorarios += saldo;
	else if (cdo.getColValue("tipo").equalsIgnoreCase("E")) tEmpresas += saldo;
%>
		<tr class="<%=color%>">
			<td><%=cdo.getColValue("codigo_cs")%></td>
			<td><%=cdo.getColValue("descripcion_cs")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_bruto"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_desc"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajustes"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagos"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(saldo)%></td>
		</tr>
<% } %>
		<tr class="TextHeader">
			<td colspan="2" align="right">TOTAL</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(tMonto)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(tDescuento)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(tAjuste)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(tPago)%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(tSaldo)%></td>
		</tr>
		<tr class="TextHeader02">
			<td colspan="4">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader02" align="center">
					<td width="25%">Cl&iacute;nica</td>
					<td width="25%">Terceros</td>
					<td width="25%">M&eacute;dicos</td>
					<td width="25%">Empresas</td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><%=CmnMgr.getFormattedDecimal(tClinica)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tTerceros)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tHonorarios)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tEmpresas)%></td>
				</tr>
				</table>
			</td>
			<td colspan="3" align="center"><%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%></td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<% } %>