<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iIncob" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vIncob" scope="session" class="java.util.Vector"/>
<jsp:useBean id="cdoParam" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
==========================================================================================
fg = FP  --> FACTURAS PAGADAS
fg = AI  --> ASIGNACION A INCOBRABLES
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
System.out.println("vIncob="+vIncob.size());
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
String lista = request.getParameter("lista");
String tipo_ajuste = request.getParameter("tipo_ajuste");
String facturar_a = request.getParameter("facturar_a");
String aType = request.getParameter("aType");
String aValue = request.getParameter("aValue");

int iconHeight = 20;
int iconWidth = 20;

if (fp == null) fp = "";
if (fg == null) fg = "FP";

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

	String nombre = request.getParameter("nombre");
	String dob = request.getParameter("dob");
	String pacCode = request.getParameter("pacCode");
	String admision = request.getParameter("admision");
	String iFechaIng = request.getParameter("iFechaIng");
	String fFechaIng = request.getParameter("fFechaIng");
	String aseguradora = request.getParameter("aseguradora");
	String aseguradoraDesc = request.getParameter("aseguradoraDesc");
	String factura = request.getParameter("factura");
	String iFecha = request.getParameter("iFecha");
	String fFecha = request.getParameter("fFecha");
	String saldo = request.getParameter("saldo");
	String fact_con_saldo = request.getParameter("fact_con_saldo");
	String fact_con_lista = request.getParameter("fact_con_lista");
	String categoria = request.getParameter("categoria");
	String rechazadas =  request.getParameter("rechazadas");
	if (nombre == null) nombre = "";
	if (dob == null) dob = "";
	if (pacCode == null) pacCode = "";
	if (admision == null) admision = "";
	if (iFechaIng == null) iFechaIng = "";
	if (fFechaIng == null) fFechaIng = "";
	if (aseguradora == null) aseguradora = "";
	if (aseguradoraDesc == null) aseguradoraDesc = "";
	if (factura == null) factura = "";
	if (iFecha == null) iFecha = "";
	if (fFecha == null) fFecha = "";
	if (saldo == null) saldo = "";
	if (fact_con_saldo == null) fact_con_saldo = "S";
	if (fact_con_lista == null) fact_con_lista = "N";
	if (categoria == null) categoria = "";
	if (tipo_ajuste == null) tipo_ajuste = "";
	if (facturar_a == null) facturar_a = "E";
	if (rechazadas == null) rechazadas = "";
	sbFilter.append(" and z.facturar_a <> 'O' ");

	if (!nombre.trim().equals("") || !dob.trim().equals("")) {
		sbFilter.append(" and exists (select null from vw_adm_paciente where pac_id = z.pac_id");
		if (!nombre.trim().equals("")) { sbFilter.append(" and nombre_paciente like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
		if (!dob.trim().equals("")) { sbFilter.append(" and trunc(f_nac) = to_date('"); sbFilter.append(dob); sbFilter.append("','dd/mm/yyyy')"); }
		sbFilter.append(")");
	}
	if (!pacCode.trim().equals("")) { sbFilter.append(" and z.pac_id = "); sbFilter.append(pacCode); }
	if (!admision.trim().equals("")) { sbFilter.append(" and z.admi_secuencia = "); sbFilter.append(admision); }
	if (!fFechaIng.trim().equals("") || !iFechaIng.trim().equals("")) {
		sbFilter.append(" and exists (select null from tbl_adm_admision where pac_id = z.pac_id");
		if (!fFechaIng.trim().equals("")) { sbFilter.append(" and fecha_ingreso <= to_date('"); sbFilter.append(fFechaIng); sbFilter.append("','dd/mm/yyyy')"); }
		if (!iFechaIng.trim().equals("")) { sbFilter.append(" and fecha_ingreso >= to_date('"); sbFilter.append(iFechaIng); sbFilter.append("','dd/mm/yyyy')"); }
		sbFilter.append(")");
	}
	if (!aseguradora.trim().equals("")) { sbFilter.append(" and z.cod_empresa = "); sbFilter.append(aseguradora); }
	if (!factura.trim().equals("")) { sbFilter.append(" and z.codigo = '"); sbFilter.append(factura.toUpperCase()); sbFilter.append("'"); }
	if (!fFecha.trim().equals("")) { sbFilter.append(" and z.fecha <= to_date('"); sbFilter.append(fFecha); sbFilter.append("','dd/mm/yyyy')"); }
	if (!iFecha.trim().equals("")) { sbFilter.append(" and z.fecha >= to_date('"); sbFilter.append(iFecha); sbFilter.append("','dd/mm/yyyy')"); }
	if (fact_con_lista.trim().equals("S")) { sbFilter.append(" and exists (select null from tbl_cxc_cuentasm x where x.factura = z.codigo and x.compania = z.compania and status not in ('I', 'R'))"); }
	else if (fact_con_lista.trim().equals("N")) { sbFilter.append(" and not exists (select null from tbl_cxc_cuentasm x where x.factura = z.codigo and x.compania = z.compania and status not in ('I', 'R'))"); }
	if (!categoria.trim().equals("")) { sbFilter.append(" and z.categoria_admi = "); sbFilter.append(categoria); sbFilter.append(""); }
	if (!facturar_a.trim().equals("")) { sbFilter.append(" and z.facturar_a = '"); sbFilter.append(facturar_a); sbFilter.append("'"); }

	 cdoParam = SQLMgr.getData("  select nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'CXC_VALIDA_REG_LISTA'),'N') validaLista from dual ");
	 if (cdoParam == null) cdoParam = new CommonDataObject();

		if(cdoParam.getColValue("validaLista","N").trim().equals("N")){if(request.getParameter("fact_con_lista")==null)fact_con_lista = "";}


	if (request.getParameter("nombre") != null) {

		sbSql.append("select zz.compania, zz.codigo, zz.facturar_a, zz.admi_secuencia as admision, to_char(zz.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, zz.admi_codigo_paciente as codigo_paciente, to_char(zz.fecha,'dd/mm/yyyy') as fecha, zz.estatus as estado, zz.cod_empresa as empresa, zz.pac_id, zz.grang_total, zz.anio as cobrador");
		sbSql.append(", (select nombre_paciente from vw_adm_paciente where pac_id = zz.pac_id) as nombre_paciente");
		sbSql.append(", (select to_char(fecha_ingreso,'dd/mm/yyyy') from tbl_adm_admision where pac_id = zz.pac_id and secuencia = zz.admi_secuencia) as fecha_ingreso");
		sbSql.append(", (select z.categoria from tbl_adm_admision z where z.pac_id = zz.pac_id and z.secuencia = zz.admi_secuencia) as categoria");
		sbSql.append(", (select (select descripcion from tbl_adm_categoria_admision where codigo = z.categoria) from tbl_adm_admision z where z.pac_id = zz.pac_id and z.secuencia = zz.admi_secuencia) as descCategoria");
		sbSql.append(", (select nombre from tbl_adm_empresa where codigo = zz.cod_empresa) as descEmpresa");
		sbSql.append(", /*nvl((SELECT TO_CHAR (MAX (z.fecha), 'dd/mm/yyyy') FROM tbl_cja_transaccion_pago z WHERE exists (select y.fac_codigo, sum(monto) from tbl_cja_distribuir_pago y where y.fac_codigo = zz.codigo AND y.compania = zz.compania AND (y.codigo_transaccion = z.codigo AND y.tran_anio = z.anio) group by y.fac_codigo having sum(monto)>0) AND z.rec_status = 'A'),' ')*/ decode(sum(nvl(zz.pagos,0)),0,'' ,fn_cja_f_Ultimo_pago (zz.compania,zz.codigo)) as ultimo_pago");
		sbSql.append(", sum(zz.monto_neto + zz.ajustes - zz.pagos) - sum(zz.copago) as saldo");
		sbSql.append(", sum(case when zz.tipo = 'C' and (select tipo_cds from tbl_cds_centro_servicio where codigo = zz.centro_servicio) <> 'T' then (zz.monto_neto + zz.ajustes - zz.pagos) else 0 end) as saldo_clinica");
		sbSql.append(", sum(case when zz.tipo = 'C' and (select tipo_cds from tbl_cds_centro_servicio where codigo = zz.centro_servicio) = 'T' then (zz.monto_neto + zz.ajustes - zz.pagos) else 0 end) as saldo_terceros");
		sbSql.append(", sum(case when zz.tipo = 'H' then (zz.monto_neto + zz.ajustes - zz.pagos) else 0 end) as saldo_medicos");
		sbSql.append(", sum(case when zz.tipo = 'E' then (zz.monto_neto + zz.ajustes - zz.pagos) else 0 end) as saldo_empresas");

		if(cdoParam.getColValue("validaLista","N").trim().equals("S")){
		sbSql.append(", nvl(decode(decode(nvl((select count(*) from tbl_cxc_det_cuentasm z, tbl_cxc_cuentasm y where  z.factura = zz.codigo and z.compania = zz.compania and z.compania = y.compania and z.anio = y.anio and z.lista = y.lista and z.factura = y.factura and y.estado not in ('R', 'I')),0),0,nvl((select count(*) from tbl_cxc_det_cuentasm z where z.factura = zz.codigo and z.compania = zz.compania),0),1),0,'N','S'),'N') as rebajado");


		sbSql.append(", (select nvl((join(cursor(select distinct z.anio||' - '||z.lista from tbl_cxc_det_cuentasm z, tbl_cxc_cuentasm y where z.compania = y.compania and z.anio = y.anio and z.lista = y.lista and z.factura = y.factura and y.estado <> 'R' and y.status not in ('R', 'I') and z.factura = zz.codigo and z.compania = zz.compania),';')),' ') from dual) as noLista");
		}
		else
		{
			sbSql.append(",'N' rebajado,'' as noLista");
		}

		sbSql.append(",(select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = zz.pac_id) as f_nac ");
		sbSql.append(" from (");

			sbSql.append("select z.compania, z.codigo, z.facturar_a, z.admi_secuencia, z.admi_fecha_nacimiento, z.admi_codigo_paciente, z.fecha, z.estatus, z.cod_empresa, z.pac_id, z.grang_total, z.anio, y.tipo, y.med_empresa, y.medico, y.centro_servicio, sum(y.monto + nvl(y.descuento,0) + nvl(y.descuento2,0)) as monto_bruto, sum(nvl(y.descuento,0) + nvl(y.descuento2,0)) as monto_desc, sum(y.monto) as monto_neto");
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
			sbSql.append(" end,0) as pagos, nvl(sum(getcopagodet(z.compania, z.codigo, NVL (TO_CHAR (y.med_empresa), y.medico), (select cds.descripcion from tbl_cds_centro_servicio cds where codigo = y.centro_servicio and compania_unorg = y.compania), z.pac_id, z.admi_secuencia, null)), 0) copago");
			sbSql.append(" from tbl_fac_factura z, tbl_fac_detalle_factura y");
			sbSql.append(" where z.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and z.estatus <> 'A' and y.imprimir_sino='S' and z.compania = y.compania and z.codigo = y.fac_codigo and (y.tipo_cobertura <> 'CI' or y.tipo_cobertura is null)");
			sbSql.append(sbFilter);
			sbSql.append(" group by z.compania, z.codigo, z.facturar_a, z.admi_secuencia, z.admi_fecha_nacimiento, z.admi_codigo_paciente, z.fecha, z.estatus, z.cod_empresa, z.pac_id, z.grang_total, z.anio, y.tipo, y.med_empresa, y.medico, y.centro_servicio");

			sbSql.append(" union all ");

			sbSql.append("select z.compania, z.codigo, z.facturar_a, z.admi_secuencia, z.admi_fecha_nacimiento, z.admi_codigo_paciente, z.fecha, z.estatus, z.cod_empresa, z.pac_id, z.grang_total, z.anio, y.tipo, y.empresa, y.medico, y.centro, 0 as monto_bruto, 0 as monto_desc, 0 as monto_neto");
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
			sbSql.append(" end,0) as pagos, 0 copago");
			sbSql.append(" from tbl_fac_factura z, vw_con_adjustment_gral y");
			sbSql.append(" where z.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and z.estatus <> 'A' and z.compania = y.compania and z.codigo = y.factura and not exists (select null from tbl_fac_detalle_factura where compania = z.compania and fac_codigo = z.codigo and med_empresa||'-'||medico||'-'||centro_servicio = y.empresa||'-'||y.medico||'-'||y.centro and imprimir_sino = 'S')");
			sbSql.append(sbFilter);
			sbSql.append(" group by z.compania, z.codigo, z.facturar_a, z.admi_secuencia, z.admi_fecha_nacimiento, z.admi_codigo_paciente, z.fecha, z.estatus, z.cod_empresa, z.pac_id, z.grang_total, z.anio, y.tipo, y.empresa, y.medico, y.centro");

		sbSql.append(") zz /* where rownum <=10000 */  group by zz.compania, zz.codigo, zz.facturar_a, zz.admi_secuencia, zz.admi_fecha_nacimiento, zz.admi_codigo_paciente, zz.fecha, zz.estatus, zz.cod_empresa, zz.pac_id, zz.grang_total, zz.anio/*, zz.copago*/");

		if(rechazadas.trim().equals("S")) sbSql.append(" having sum(zz.monto_neto + zz.ajustes - zz.pagos) - sum(zz.copago) =  (zz.grang_total+sum(nvl(zz.ajustes,0)) )");
		else {
			if (fact_con_saldo.trim().equals("S")) {
			sbSql.append(" having sum(zz.monto_neto + zz.ajustes - zz.pagos) - sum(zz.copago) > 0 and sum(zz.monto_neto + zz.ajustes - zz.pagos) - sum(zz.copago) < 		(decode(zz.grang_total,0,(sum(zz.monto_neto + zz.ajustes - zz.pagos) - sum(zz.copago))+1,zz.grang_total))  ");//"
			}
			if (!saldo.trim().equals("")) {

				if (!fact_con_saldo.trim().equals("S")) sbSql.append(" having ");
				else sbSql.append(" and ");

				sbSql.append("sum(zz.monto_neto + zz.ajustes - zz.pagos) < ");//"
				sbSql.append(saldo);
			}
		}

		sbSql.append(" order by 2");
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");

	}

	//calculate total for selected items
	double sSaldo = 0, sSaldoClinica = 0, sSaldoTerceros = 0, sSaldoMedicos = 0, sSaldoEmpresas = 0;
	for (java.util.Enumeration e = iIncob.keys(); e.hasMoreElements();) {
		CommonDataObject cdo = (CommonDataObject) iIncob.get(e.nextElement());
		sSaldo += Double.parseDouble(cdo.getColValue("saldo"));
		sSaldoClinica += Double.parseDouble(cdo.getColValue("saldo_clinica"));
		sSaldoTerceros += Double.parseDouble(cdo.getColValue("saldo_terceros"));
		sSaldoMedicos += Double.parseDouble(cdo.getColValue("saldo_medicos"));
		sSaldoEmpresas += Double.parseDouble(cdo.getColValue("saldo_empresas"));
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
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();calcTotal();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,500);}
function printEC(factId,pacId){abrir_ventana1('../facturacion/print_estado_cargo_det.jsp?factId='+factId+'&pacId='+pacId);}
function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=ajuste_lote');}
function calcTotal(){
	var tSaldo=<%=sSaldo%>,tClinica=<%=sSaldoClinica%>,tTerceros=<%=sSaldoTerceros%>,tMedicos=<%=sSaldoMedicos%>,tEmpresas=<%=sSaldoEmpresas%>;
	for(i=0;i<<%=al.size()%>;i++){
		if(eval('document.form0.rebajar'+i)&&eval('document.form0.rebajar'+i).checked){
			tSaldo+=parseFloat(eval('document.form0.saldo'+i).value);
			tClinica+=parseFloat(eval('document.form0.saldo_clinica'+i).value);
			tTerceros+=parseFloat(eval('document.form0.saldo_terceros'+i).value);
			tMedicos+=parseFloat(eval('document.form0.saldo_medicos'+i).value);
			tEmpresas+=parseFloat(eval('document.form0.saldo_empresas'+i).value);
		}
	}
	document.form0.tSaldo.value=(tSaldo).toFixed(2);
	document.form0.tClinica.value=(tClinica).toFixed(2);
	document.form0.tTerceros.value=(tTerceros).toFixed(2);
	document.form0.tMedicos.value=(tMedicos).toFixed(2);
	document.form0.tEmpresas.value=(tEmpresas).toFixed(2);
}

function isValidAll(){
	var size = document.form0.size.value;
	for(i=0;i<size;i++){
		if(eval('document.form0.rebajado'+i).value=='S'){
			var lista=eval('document.form0.noLista'+i).value;
			if(lista.trim()!=''){
				if(eval('document.form0.rebajar'+i)) eval('document.form0.rebajar'+i).checked=false;
			}
		}
	}
	calcTotal();
}

function isValid(k,listed){
	var x=0;
	if(eval('document.form0.rebajar'+k).checked){
	<% if (fg.equalsIgnoreCase("FIS")) { %>
		/*var saldo=parseFloat(eval('document.form0.saldo'+k).value);
		var montoLimite=parseFloat(eval('document.search00.saldo').value);
		if(isNaN(montoLimite))alert('Valor del monto (SALDO MENOR A) no es válido!');
		else{
			if(saldo!=0&&saldo<montoLimite)eval('document.form0.rebajar'+k).checked=true;
			else{
				alert('El Saldo de la factura no aplica para el monto indroducido (SALDO MENOR A). Verifique!!!');
				eval('document.form0.rebajar'+k).checked=false;
				x++;
			}
		}*/
	<% } %>
	}
	if(listed=='S'){
		var lista=eval('document.form0.noLista'+k).value;
		if(lista.trim()!=''){
			alert('La Factura seleccionada ya fue rebajada en la Lista #'+lista);
			eval('document.form0.rebajar'+k).checked=false;
		}
	}
	if(x==0)calcTotal();
}
function printFactura(factura){abrir_ventana1('../facturacion/print_factura.jsp?factura='+factura+'&compania=<%=session.getAttribute("_companyId")%>');}
function showDetail(factura){showPopWin('../common/factura_detalle.jsp?factura='+factura,winWidth*.75,winHeight*.65,null,null,'');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CXC - FACTURAS PAGADAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("lista",lista)%>
<%=fb.hidden("tipo_ajuste",tipo_ajuste)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("aType",aType)%>
<%=fb.hidden("aValue",aValue)%>
		<tr class="TextFilter">
			<td>
				Categor&iacute;a Admisi&oacute;n:
				<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"S")%>
				Facturas <%=fb.select("fact_con_lista","S=CON LISTA,N=SIN LISTA",fact_con_lista,false,false,0,"Text10",null,"","","S")%><%=fb.select("facturar_a","E=DE EMPRESA,P=DE PACIENTE",	facturar_a,false,false,0,"Text10",null,"","","")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				Nombre:
				<%=fb.textBox("nombre",nombre,false,false,false,30)%>
				F.Nac.:
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="dob"/>
				<jsp:param name="valueOfTBox1" value=""/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
				C&oacute;d.Pac.:
				<%=fb.intBox("pacCode",pacCode,false,false,false,5)%>
				Adm.:
				<%=fb.intBox("admision",admision,false,false,false,5)%>
				F.Ing.
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="iFechaIng"/>
				<jsp:param name="valueOfTBox1" value="<%=iFechaIng%>"/>
				<jsp:param name="nameOfTBox2" value="fFechaIng"/>
				<jsp:param name="valueOfTBox2" value="<%=fFechaIng%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				Aseguradora
				<%=fb.intBox("aseguradora",aseguradora,false,false,false,5,"Text10",null,null)%>
				<%=fb.textBox("aseguradoraDesc","",false,false,true,30,"Text10",null,null)%>
				<%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
				Factura #:
				<%=fb.textBox("factura",factura,false,false,false,10)%>
				Fecha
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="iFecha"/>
				<jsp:param name="valueOfTBox1" value="<%=iFecha%>"/>
				<jsp:param name="nameOfTBox2" value="fFecha"/>
				<jsp:param name="valueOfTBox2" value="<%=fFecha%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter SpacingText">
			<td>
				<% if (fg.trim().equalsIgnoreCase("FIS")) { %>
				<!--SOLO FACTURAS CON SALDO?<%//=fb.select("fact_con_saldo","N=No,S=Si",fact_con_saldo,false,false,0,null,null,null)%>-->
				SALDO MENOR A:
				<%=fb.decBox("saldo",saldo,false,false,false,10,"Text10",null,null)%>
				<authtype type='60'>Facturas Sin Pago: <%=fb.checkbox("rechazadas","S",(rechazadas.equalsIgnoreCase("S")),false,null,null,"","CUENTAS RECHAZADAS POR LA ASEGURADORA")%></authtype>
				<%=fb.submit("go","Ir")%>
				NO. LISTA: <label class="RedText"><%=lista%></label>
				A&Ntilde;O: <label class="RedText"><%=anio%></label>

				<% } else { %>
				<%=fb.submit("go","Ir")%>
				NO. LISTA: <label class="RedText"><%=lista%></label>
				<% } %>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+nxtVal)%>
<%=fb.hidden("previousVal",""+preVal)%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("lista",lista)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("pacCode",pacCode)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("factura",factura)%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("iFecha",iFecha)%>
<%=fb.hidden("fFecha",fFecha)%>
<%=fb.hidden("iFechaIng",iFechaIng)%>
<%=fb.hidden("fFechaIng",fFechaIng)%>
<%=fb.hidden("saldo",saldo)%>
<%=fb.hidden("sSaldo",""+sSaldo)%>
<%=fb.hidden("sSaldoClinica",""+sSaldoClinica)%>
<%=fb.hidden("sSaldoTerceros",""+sSaldoTerceros)%>
<%=fb.hidden("sSaldoMedicos",""+sSaldoMedicos)%>
<%=fb.hidden("sSaldoEmpresas",""+sSaldoEmpresas)%>
<%=fb.hidden("fact_con_saldo",""+fact_con_saldo)%>
<%=fb.hidden("categoria",""+categoria)%>
<%=fb.hidden("fact_con_lista",""+fact_con_lista)%>
<%=fb.hidden("tipo_ajuste",tipo_ajuste)%>
<%=fb.hidden("facturar_a",facturar_a)%>
<%=fb.hidden("rechazadas",rechazadas)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("aType",aType)%>
<%=fb.hidden("aValue",aValue)%>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" border="0" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td align="right" colspan="4">
				<%=fb.submit("save","Agregar",true,false)%>
				<%=fb.submit("saveContinue","Agregar y Continuar",true,false)%>
			</td>
		</tr>
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%"><%=rowCount%> Registro(s) Mostrado(s)</td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(recsPerPage == al.size()/*!(rowCount <= nxtVal)*/)?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1" id="list">
		<tr class="TextHeader" align="center">
			<td width="22%">Nombre</td>
			<td width="6%">F.Nac.</td>
			<td width="4%">C&oacute;d.Pac.</td>
			<td width="4%">Adm.</td>
			<td width="8%">Categor&iacute;a</td>
			<td width="6%">F.Ing.</td>
			<td width="20%">Aseg.</td>
			<td width="6%">Factura</td>
			<td width="4%">Fecha</td>
			<td width="4%">Monto</td>
			<td width="4%">Saldo</td>
			<td width="6%">Ult.Pago</td>
			<td width="6%">Lista</td>
			<td width="3%">Incob.<br><%=fb.checkbox("_chkAll","S",false,false,"","","onClick=\"javascript:jqCheckAll('"+fb.getFormName()+"', 'rebajar', this, false); isValidAll();\"","")%></td>
			<td width="3%">&nbsp;</td>
			<td width="3%">&nbsp;</td>
		</tr>
<% if (al.size() == 0) { %>
		<tr>
			<td colspan="15" class="TextRow01 SpacingText" align="center"><font color="#FF0000">
				<% if (request.getParameter("codigo") == null) { %>
				INTRODUZCA PARAMETROS PARA BUSQUEDA
				<% } else { %>
				NO HAY REGISTROS ENCONTRADOS
				<% } %>
			</font></td>
		</tr>
<% } %>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
		<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
		<%=fb.hidden("codigo_paciente"+i,cdo.getColValue("codigo_paciente"))%>
		<%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
		<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
		<%=fb.hidden("grang_total"+i,cdo.getColValue("grang_total"))%>
		<%=fb.hidden("cobrador"+i,cdo.getColValue("cobrador"))%>
		<%=fb.hidden("nombre_paciente"+i,cdo.getColValue("nombre_paciente"))%>
		<%=fb.hidden("fecha_ingreso"+i,cdo.getColValue("fecha_ingreso"))%>
		<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
		<%=fb.hidden("descCategoria"+i,cdo.getColValue("descCategoria"))%>
		<%=fb.hidden("descEmpresa"+i,cdo.getColValue("descEmpresa"))%>
		<%=fb.hidden("ultimo_pago"+i,cdo.getColValue("ultimo_pago"))%>
		<%=fb.hidden("saldo"+i,cdo.getColValue("saldo"))%>
		<%=fb.hidden("saldo_clinica"+i,cdo.getColValue("saldo_clinica"))%>
		<%=fb.hidden("saldo_terceros"+i,cdo.getColValue("saldo_terceros"))%>
		<%=fb.hidden("saldo_medicos"+i,cdo.getColValue("saldo_medicos"))%>
		<%=fb.hidden("saldo_empresas"+i,cdo.getColValue("saldo_empresas"))%>
		<%=fb.hidden("rebajado"+i,cdo.getColValue("rebajado"))%>
		<%=fb.hidden("noLista"+i,cdo.getColValue("noLista"))%>
		<%=fb.hidden("f_nac"+i,cdo.getColValue("f_nac"))%>
		<tr class="TextRow04" align="center">
			<td align="left"><%=cdo.getColValue("nombre_paciente")%></td>
			<td><%=cdo.getColValue("f_nac")%></td>
			<td><%=cdo.getColValue("pac_id")%></td>
			<td><%=cdo.getColValue("admision")%></td>
			<td><%=cdo.getColValue("descCategoria")%></td>
			<td><%=cdo.getColValue("fecha_ingreso")%></td>
			<td align="left"><%=cdo.getColValue("descEmpresa")%></td>
			<td><a href="javascript:showDetail('<%=cdo.getColValue("codigo")%>');" class="Link00"><%=cdo.getColValue("codigo")%></a></td>
			<td><%=cdo.getColValue("fecha")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo"))%></td>
			<td align="right"><%=cdo.getColValue("ultimo_pago")%></td>
			<td align="right"><%=cdo.getColValue("noLista")%></td>
			<td><%=(vIncob.contains(cdo.getColValue("codigo")))?"Elegido":fb.checkbox("rebajar"+i,"S",false,false,"","","onClick=javascript:isValid("+i+",'"+cdo.getColValue("rebajado")+"')","")%><%//=""%></td>
			<td><authtype type='50'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onClick="javascript:printFactura('<%=cdo.getColValue("codigo")%>')"></authtype></td>
			<td><authtype type='51'><a href="javascript:printEC('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("pac_id")%>')" class="Link00">EC</a></authtype></td>
		</tr>
<% } %>
		</table>
</div>
</div>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader02 SpacingText">
			<td colspan="4">Montos de la Lista</td>
			<td width="60%" align="right" rowspan="3">TOTAL DE LA LISTA: <%=fb.decBox("tSaldo","0",false,false,true,15,12.2,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01" align="right">
			<td width="10%">Cl&iacute;nica:</td>
			<td width="10%"><%=fb.decBox("tClinica","0",false,false,true,15,12.2,"Text10",null,null)%></td>
			<td width="10%">Terceros:</td>
			<td width="10%"><%=fb.decBox("tTerceros","0",false,false,true,15,12.2,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01" align="right">
			<td>M&eacute;dicos:</td>
			<td><%=fb.decBox("tMedicos","0",false,false,true,15,12.2,"Text10",null,null)%></td>
			<td>Empresas:</td>
			<td><%=fb.decBox("tEmpresas","0",false,false,true,15,12.2,"Text10",null,null)%></td>
		</tr>
		</table>
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><%=rowCount%> Registro(s) Mostrado(s)</td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(recsPerPage == al.size()/*!(rowCount <= nxtVal)*/)?fb.submit("nextB","->>"):""%></td>
		</tr>
		<tr class="TextPager">
			<td align="right" colspan="4">
				<%=fb.submit("save2","Agregar",true,false)%>
				<%=fb.submit("saveContinue2","Agregar y Continuar",true,false)%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {

	int size = Integer.parseInt(request.getParameter("size"));
	al = new ArrayList();

	for (int i=0; i<size; i++) {

		if (request.getParameter("rebajar"+i) != null) {

			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("codigo",request.getParameter("codigo"+i));
			cdo.addColValue("admision",request.getParameter("admision"+i));
			cdo.addColValue("fecha_nacimiento",request.getParameter("fecha_nacimiento"+i));
			cdo.addColValue("f_nac",request.getParameter("f_nac"+i));
			cdo.addColValue("codigo_paciente",request.getParameter("codigo_paciente"+i));
			cdo.addColValue("fecha",request.getParameter("fecha"+i));
			cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("empresa",request.getParameter("empresa"+i));
			cdo.addColValue("pac_id",request.getParameter("pac_id"+i));
			cdo.addColValue("grang_total",request.getParameter("grang_total"+i));
			cdo.addColValue("cobrador",request.getParameter("cobrador"+i));
			cdo.addColValue("rebajar","S");
			cdo.addColValue("nombre_paciente",request.getParameter("nombre_paciente"+i));
			cdo.addColValue("fecha_ingreso",request.getParameter("fecha_ingreso"+i));
			cdo.addColValue("categoria",request.getParameter("categoria"+i));
			cdo.addColValue("descCategoria",request.getParameter("descCategoria"+i));
			cdo.addColValue("descEmpresa",request.getParameter("descEmpresa"+i));
			cdo.addColValue("ultimo_pago",request.getParameter("ultimo_pago"+i));
			cdo.addColValue("saldo",request.getParameter("saldo"+i));
			cdo.addColValue("ajustar",request.getParameter("saldo"+i));
			cdo.addColValue("saldo_clinica",request.getParameter("saldo_clinica"+i));
			cdo.addColValue("saldo_terceros",request.getParameter("saldo_terceros"+i));
			cdo.addColValue("saldo_medicos",request.getParameter("saldo_medicos"+i));
			cdo.addColValue("saldo_empresas",request.getParameter("saldo_empresas"+i));
			cdo.addColValue("rebajado",request.getParameter("rebajado"+i));
			cdo.addColValue("noLista",request.getParameter("noLista"+i));
			cdo.addColValue("id","0");
			if(cdo.getColValue("saldo_clinica")!=null && !cdo.getColValue("saldo_clinica").equals("") && Double.parseDouble(cdo.getColValue("saldo_clinica")) > 0) cdo.addColValue("tipo", "C");
			if(cdo.getColValue("saldo_terceros")!=null && !cdo.getColValue("saldo_terceros").equals("") && Double.parseDouble(cdo.getColValue("saldo_terceros")) > 0) cdo.addColValue("tipo", "CT");
			if(cdo.getColValue("saldo_medicos")!=null && !cdo.getColValue("saldo_medicos").equals("") && Double.parseDouble(cdo.getColValue("saldo_clinica")) > 0) cdo.addColValue("tipo", "H");
			if(cdo.getColValue("saldo_empresas")!=null && !cdo.getColValue("saldo_empresas").equals("") && Double.parseDouble(cdo.getColValue("saldo_empresas")) > 0) cdo.addColValue("tipo", "A");

			cdo.setKey(iIncob.size()+1);

			try {
				iIncob.put(cdo.getKey(),cdo);
				vIncob.addElement(request.getParameter("codigo"+i));
			} catch(Exception e) {
				System.out.println("Unable to add item!");
			}

		}//checked

	}//loop

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null) {
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&mode="+mode+"&anio="+anio+"&lista="+lista+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&nombre="+request.getParameter("nombre")+"&dob="+request.getParameter("dob")+"&pacCode="+request.getParameter("pacCode")+"&admision="+request.getParameter("admision")+"&iFechaIng="+request.getParameter("iFechaIng")+"&fFechaIng="+request.getParameter("fFechaIng")+"&factura="+request.getParameter("factura")+"&iFecha="+request.getParameter("iFecha")+"&fFecha="+request.getParameter("fFecha")+"&saldo="+request.getParameter("saldo")+"&fact_con_saldo="+request.getParameter("fact_con_saldo")+"&categoria="+request.getParameter("categoria")+"&fact_con_lista="+request.getParameter("fact_con_lista")+"&tipo_ajuste="+request.getParameter("tipo_ajuste")+"&facturar_a="+request.getParameter("facturar_a")+"&aseguradora="+request.getParameter("aseguradora")+"&aseguradoraDesc="+request.getParameter("aseguradoraDesc")+"&rechazadas="+request.getParameter("rechazadas")+"&aType="+aType+"&aValue="+aValue);
		return;

	} else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null) {

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&mode="+mode+"&anio="+anio+"&lista="+lista+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&nombre="+request.getParameter("nombre")+"&dob="+request.getParameter("dob")+"&pacCode="+request.getParameter("pacCode")+"&admision="+request.getParameter("admision")+"&iFechaIng="+request.getParameter("iFechaIng")+"&fFechaIng="+request.getParameter("fFechaIng")+"&factura="+request.getParameter("factura")+"&iFecha="+request.getParameter("iFecha")+"&fFecha="+request.getParameter("fFecha")+"&saldo="+request.getParameter("saldo")+"&fact_con_saldo="+request.getParameter("fact_con_saldo")+"&categoria="+request.getParameter("categoria")+"&fact_con_lista="+request.getParameter("fact_con_lista")+"&tipo_ajuste="+request.getParameter("tipo_ajuste")+"&facturar_a="+request.getParameter("facturar_a")+"&aseguradora="+request.getParameter("aseguradora")+"&aseguradoraDesc="+request.getParameter("aseguradoraDesc")+"&rechazadas="+request.getParameter("rechazadas")+"&aType="+aType+"&aValue="+aValue);
		return;

	} else if (request.getParameter("saveContinue") != null) {

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&mode="+mode+"&anio="+anio+"&lista="+lista+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&nombre="+request.getParameter("nombre")+"&dob="+request.getParameter("dob")+"&pacCode="+request.getParameter("pacCode")+"&admision="+request.getParameter("admision")+"&iFechaIng="+request.getParameter("iFechaIng")+"&fFechaIng="+request.getParameter("fFechaIng")+"&factura="+request.getParameter("factura")+"&iFecha="+request.getParameter("iFecha")+"&fFecha="+request.getParameter("fFecha")+"&saldo="+request.getParameter("saldo")+"&fact_con_saldo="+request.getParameter("fact_con_saldo")+"&categoria="+request.getParameter("categoria")+"&fact_con_lista="+request.getParameter("fact_con_lista")+"&tipo_ajuste="+request.getParameter("tipo_ajuste")+"&facturar_a="+request.getParameter("facturar_a")+"&aseguradora="+request.getParameter("aseguradora")+"&aseguradoraDesc="+request.getParameter("aseguradoraDesc")+"&rechazadas="+request.getParameter("rechazadas")+"&aType="+aType+"&aValue="+aValue);
		return;

	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){<% if (fp.equalsIgnoreCase("incob")) { %>window.opener.location='../cxc/list_fact_incob_x_saldo.jsp?fg=<%=fg%>&mode=<%=mode%>&anio=<%=anio%>&lista=<%=lista%>&change=1&tipo_ajuste=<%=request.getParameter("tipo_ajuste")%>&aType=<%=aType%>&aValue=<%=aValue%>';<% } %>window.close();}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<% } %>