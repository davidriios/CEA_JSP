<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String pacienteId = request.getParameter("pacienteId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");

if (pacienteId == null) pacienteId = "";
if (noAdmision == null) noAdmision = "";
if (pacienteId.trim().equals("") || noAdmision.trim().equals("")) throw new Exception("La cuenta es inválida. Por favor intente nuevamente!");

String cdsDet = "N";
try { cdsDet = java.util.ResourceBundle.getBundle("issi").getString("cdsDet"); } catch(Exception e) { cdsDet = "N"; }

boolean chkOMFar = false;
boolean chkOMFarBM = false;
boolean chkSOPChg = false;
boolean chkReqLIS = false;
boolean chkReqRIS = false;
boolean chkReqIU = false;//inv. sol. insumos; sol. y dev. usos; y sol. dev.
sbSql.append("select nvl(get_sec_comp_param(-1,'FAC_CHK_OM_FAR'),'Y') as chk_om_far, nvl(get_sec_comp_param(-1,'FAC_CHK_OM_FARBM'),'Y') as chk_om_far_bm, nvl(get_sec_comp_param(-1,'FAC_CHK_SOP_CHARGES'),'Y') as chk_sop_chg, nvl(get_sec_comp_param(-1,'FAC_CHK_REQ_LIS'),'N') as chk_req_lis, nvl(get_sec_comp_param(-1,'FAC_CHK_REQ_RIS'),'N') as chk_req_ris, nvl(get_sec_comp_param(-1,'INV_CHK_REQ_IU'),'N') as chk_req_iu from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
if (p != null){
	if (p.getColValue("chk_om_far") != null) chkOMFar = (p.getColValue("chk_om_far").equalsIgnoreCase("S") || p.getColValue("chk_om_far").equalsIgnoreCase("Y"));
	if (p.getColValue("chk_om_far_bm") != null) chkOMFarBM = (p.getColValue("chk_om_far_bm").equalsIgnoreCase("S") || p.getColValue("chk_om_far_bm").equalsIgnoreCase("Y"));
	if (p.getColValue("chk_sop_chg") != null) chkSOPChg = (p.getColValue("chk_sop_chg").equalsIgnoreCase("S") || p.getColValue("chk_sop_chg").equalsIgnoreCase("Y"));
	if (p.getColValue("chk_req_lis") != null) chkReqLIS = (p.getColValue("chk_req_lis").equalsIgnoreCase("S") || p.getColValue("chk_req_lis").equalsIgnoreCase("Y"));
	if (p.getColValue("chk_req_ris") != null) chkReqRIS = (p.getColValue("chk_req_ris").equalsIgnoreCase("S") || p.getColValue("chk_req_ris").equalsIgnoreCase("Y"));
	if (p.getColValue("chk_req_iu") != null) chkReqIU = ("SY".contains(p.getColValue("chk_req_iu").toUpperCase()));
}

int rOMFA = 0, rOMFD = 0,rOMFABM = 0, rOMFDBM = 0,rOMDEV = 0, rDev = -1, rOM = -1, rSOPChg = 0, rReqLIS = 0, rReqRIS = 0, rReqI = 0, rReqU = 0, rReqD = 0;//-1=required,0=optional
sbSql = new StringBuffer();
//Devoluciones mayores que cargos
sbSql.append("select 'DEV' as rec_type, count(*) as n_recs from (");
	sbSql.append("select y.compania, y.pac_id, y.fac_secuencia, y.centro_servicio, y.tipo_cargo, y.med_codigo, y.empre_codigo, y.procedimiento, y.otros_cargos, y.cds_producto, y.habitacion, y.art_familia, y.art_clase, y.inv_articulo, y.cod_uso, nvl(sum(decode(y.tipo_transaccion,'D',-y.cantidad,y.cantidad) * y.monto),0) as total, nvl(sum(decode(y.tipo_transaccion,'D',-y.cantidad,y.cantidad)),0) as cantidad, coalesce(y.procedimiento,''||y.otros_cargos,''||y.cds_producto,y.habitacion,''||y.cod_uso,y.art_familia||'-'||y.art_clase||'-'||y.inv_articulo,y.med_codigo,''||y.empre_codigo) as producto from (");
		sbSql.append("select z.compania, z.pac_id, z.fac_secuencia, z.tipo_transaccion, z.fac_codigo, z.tipo_cargo, z.procedimiento, z.otros_cargos, z.cds_producto, z.habitacion, z.art_familia, z.art_clase, z.inv_articulo, z.cod_uso, z.cantidad, z.monto + nvl(z.recargo,0) as monto, decode('");
		sbSql.append(cdsDet);
		sbSql.append("','S',z.centro_servicio,(select distinct centro_servicio from tbl_fac_transaccion where compania = z.compania and pac_id = z.pac_id and admi_secuencia = z.fac_secuencia and tipo_transaccion = z.tipo_transaccion and codigo = z.fac_codigo)) as centro_servicio, case when z.procedimiento is null and z.otros_cargos is null and z.cds_producto is null and z.habitacion is null and z.art_familia is null and z.art_clase is null and z.inv_articulo is null and z.cod_uso is null then (select med_codigo from tbl_fac_transaccion where compania = z.compania and pac_id = z.pac_id and admi_secuencia = z.fac_secuencia and tipo_transaccion = z.tipo_transaccion and codigo = z.fac_codigo) else null end as med_codigo, case when z.procedimiento is null and z.otros_cargos is null and z.cds_producto is null and z.habitacion is null and z.art_familia is null and z.art_clase is null and z.inv_articulo is null and z.cod_uso is null then (select empre_codigo from tbl_fac_transaccion where compania = z.compania and pac_id = z.pac_id and admi_secuencia = z.fac_secuencia and tipo_transaccion = z.tipo_transaccion and codigo = z.fac_codigo) else null end as empre_codigo from tbl_fac_detalle_transaccion z where z.pac_id = ");
		sbSql.append(pacienteId);
		sbSql.append(" and z.fac_secuencia = ");
		sbSql.append(noAdmision);
	sbSql.append(") y group by y.compania, y.pac_id, y.fac_secuencia, y.centro_servicio, y.tipo_cargo, y.procedimiento, y.otros_cargos, y.cds_producto, y.habitacion, y.art_familia, y.art_clase, y.inv_articulo, y.cod_uso, y.med_codigo, y.empre_codigo having nvl(sum(decode(y.tipo_transaccion,'D',-y.cantidad,y.cantidad)),0) < 0");
sbSql.append(")");
//OM x ejecutar
sbSql.append(" union all select 'OM' as rec_type, count(*) as n_recs from tbl_sal_detalle_orden_med z where pac_id = ");
sbSql.append(pacienteId);
sbSql.append(" and adm_corte = ");
sbSql.append(noAdmision);
sbSql.append(" and ((z.omitir_orden = 'N' and z.estado_orden = 'A') or (z.ejecutado = 'N' and z.estado_orden = 'S'))");
if (chkOMFar) {

	rOMFA = -1;//set -1 to be validated
	rOMFD = -1;//set -1 to be validated
	rOMDEV  = -1;//set -1 to be validated
	//Medicamentos Farmacia
	sbSql.append(" union all select 'OMFA' as rec_type, count(*) as n_recs from tbl_sal_detalle_orden_med z where z.omitir_orden = 'N' and z.tipo_orden in (2,13,14) and (trunc(z.fecha_inicio) <= trunc(sysdate) or (z.estado_orden = 'S' and trunc(z.fecha_suspencion) >= trunc(sysdate)))");
	sbSql.append(" and not exists (select null from tbl_int_orden_farmacia where pac_id = z.pac_id and adm_cargo = z.adm_corte and tipo_orden = z.tipo_orden and orden_med = z.orden_med and codigo = z.codigo)");//x aprobar
	sbSql.append(" and pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and adm_corte = ");
	sbSql.append(noAdmision); 
	sbSql.append(" union all select 'OMFD' as rec_type, count(*) as n_recs from tbl_sal_detalle_orden_med z where z.omitir_orden = 'N' and z.tipo_orden in (2,13,14) and (trunc(z.fecha_inicio) <= trunc(sysdate) or (z.estado_orden = 'S' and trunc(z.fecha_suspencion) >= trunc(sysdate)))");
	sbSql.append(" and exists (select null from tbl_int_orden_farmacia where pac_id = z.pac_id and adm_cargo = z.adm_corte and tipo_orden = z.tipo_orden and orden_med = z.orden_med and codigo = z.codigo and other1 = 1 and ( (fg = 'ME' and estado in ('P'))))");//x despachar
	sbSql.append(" and pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and adm_corte = ");
	sbSql.append(noAdmision); 
	//Devolución Medicamentos Farmacia (para Banco Medicamento se hace por medio de la devolución de cargos)
	sbSql.append(" union all select 'OMDEV' as rec_type, count(*) as n_recs from tbl_int_dev_farmacia z where z.estado ='D' and fecha_cargo_dev is null and z.no_cargo is  null and z.other1 = 1 "  );
	sbSql.append(" and pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and adm_cargo = ");
	sbSql.append(noAdmision); 
	
}
if (chkOMFarBM) {

	rOMFABM = -1;//set -1 to be validated
	rOMFDBM = -1;//set -1 to be validated
	//Medicamentos BM
	sbSql.append(" union all select 'OMFABM' as rec_type, count(*) as n_recs from tbl_sal_detalle_orden_med z where z.omitir_orden = 'N' and z.tipo_orden in (2,13,14) and (trunc(z.fecha_inicio) <= trunc(sysdate) or (z.estado_orden = 'S' and trunc(z.fecha_suspencion) >= trunc(sysdate)))");
	sbSql.append(" and not exists (select null from tbl_int_orden_farmacia where pac_id = z.pac_id and adm_cargo= z.adm_corte and tipo_orden = z.tipo_orden and orden_med = z.orden_med and codigo = z.codigo)");//x aprobar
	sbSql.append(" and pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and z.adm_corte = ");
	sbSql.append(noAdmision);
	sbSql.append(" and z.id_articulo is not null");
	sbSql.append(" union all select 'OMFDBM' as rec_type, count(*) as n_recs from tbl_sal_detalle_orden_med z where z.omitir_orden = 'N' and z.tipo_orden in (2,13,14) and (trunc(z.fecha_inicio) <= trunc(sysdate) or (z.estado_orden = 'S' and trunc(z.fecha_suspencion) >= trunc(sysdate)))");
	sbSql.append(" and exists (select null from tbl_int_orden_farmacia where pac_id = z.pac_id and adm_cargo = z.adm_corte and tipo_orden = z.tipo_orden and orden_med = z.orden_med and codigo = z.codigo and other1 = 1 and ( fg = 'BM' and estado in ('P','A')  ))");//x despachar
	sbSql.append(" and pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and adm_corte = ");
	sbSql.append(noAdmision); 

}
if (chkSOPChg) {

	rSOPChg = -1;//set -1 to be validated
	//Cargos SOP sin Cita
	sbSql.append(" union all select 'CHGSOP' as rec_type, count(*) as n_recs from (");
		sbSql.append("select y.compania, y.pac_id, y.fac_secuencia, y.centro_servicio, y.tipo_cargo, y.med_codigo, y.empre_codigo, y.procedimiento, y.otros_cargos, y.cds_producto, y.habitacion, y.art_familia, y.art_clase, y.inv_articulo, y.cod_uso, nvl(sum(decode(y.tipo_transaccion,'D',-y.cantidad,y.cantidad) * y.monto),0) as total, nvl(sum(decode(y.tipo_transaccion,'D',-y.cantidad,y.cantidad)),0) as cantidad, coalesce(y.procedimiento,''||y.otros_cargos,''||y.cds_producto,y.habitacion,''||y.cod_uso,y.art_familia||'-'||y.art_clase||'-'||y.inv_articulo,y.med_codigo,''||y.empre_codigo) as producto from (");
			sbSql.append("select z.compania, z.pac_id, z.fac_secuencia, z.tipo_transaccion, z.fac_codigo, z.tipo_cargo, z.procedimiento, z.otros_cargos, z.cds_producto, z.habitacion, z.art_familia, z.art_clase, z.inv_articulo, z.cod_uso, z.cantidad, z.monto + nvl(z.recargo,0) as monto, decode('");
			sbSql.append(cdsDet);
			sbSql.append("','S',z.centro_servicio,(select distinct centro_servicio from tbl_fac_transaccion where compania = z.compania and pac_id = z.pac_id and admi_secuencia = z.fac_secuencia and tipo_transaccion = z.tipo_transaccion and codigo = z.fac_codigo)) as centro_servicio, case when z.procedimiento is null and z.otros_cargos is null and z.cds_producto is null and z.habitacion is null and z.art_familia is null and z.art_clase is null and z.inv_articulo is null and z.cod_uso is null then (select med_codigo from tbl_fac_transaccion where compania = z.compania and pac_id = z.pac_id and admi_secuencia = z.fac_secuencia and tipo_transaccion = z.tipo_transaccion and codigo = z.fac_codigo) else null end as med_codigo, case when z.procedimiento is null and z.otros_cargos is null and z.cds_producto is null and z.habitacion is null and z.art_familia is null and z.art_clase is null and z.inv_articulo is null and z.cod_uso is null then (select empre_codigo from tbl_fac_transaccion where compania = z.compania and pac_id = z.pac_id and admi_secuencia = z.fac_secuencia and tipo_transaccion = z.tipo_transaccion and codigo = z.fac_codigo) else null end as empre_codigo from tbl_fac_detalle_transaccion z where z.pac_id = ");
			sbSql.append(pacienteId);
			sbSql.append(" and z.fac_secuencia = ");
			sbSql.append(noAdmision);
			if (cdsDet.equalsIgnoreCase("S")) sbSql.append(" and ( exists (select null from tbl_cds_centro_servicio where flag_cds = 'SOP' and codigo = z.centro_servicio) or exists (select null from tbl_cds_centro_servicio a where a.codigo = z.centro_servicio and exists (select null from tbl_cds_centro_servicio where flag_cds = 'SOP' and codigo = a.reporta_a)) )");
			else sbSql.append(" and ( exists (select null from tbl_cds_centro_servicio a where flag_cds = 'SOP' and exists (select null from tbl_fac_transaccion where compania = z.compania and pac_id = z.pac_id and admi_secuencia = z.fac_secuencia and tipo_transaccion = z.tipo_transaccion and codigo = z.fac_codigo and centro_servicio = a.codigo)) or exists (select null from tbl_cds_centro_servicio a where exists (select null from tbl_fac_transaccion where compania = z.compania and pac_id = z.pac_id and admi_secuencia = z.fac_secuencia and tipo_transaccion = z.tipo_transaccion and codigo = z.fac_codigo and centro_servicio = a.codigo) and exists (select null from tbl_cds_centro_servicio where flag_cds = 'SOP' and codigo = a.reporta_a)) )");
		sbSql.append(") y group by y.compania, y.pac_id, y.fac_secuencia, y.centro_servicio, y.tipo_cargo, y.procedimiento, y.otros_cargos, y.cds_producto, y.habitacion, y.art_familia, y.art_clase, y.inv_articulo, y.cod_uso, y.med_codigo, y.empre_codigo having nvl(sum(decode(y.tipo_transaccion,'D',-y.cantidad,y.cantidad)),0) > 0 and not exists (select null from tbl_cdc_cita where pac_id = y.pac_id and admision = y.fac_secuencia and estado_cita in ('R','E')) and exists (select null from tbl_cds_centro_servicio where flag_cds in ('SOP','HEM','ENDO') and codigo = y.centro_servicio)");//R=Reservada, E=Realizada
	sbSql.append(")");

}
if (chkReqLIS) {

	rReqLIS = -1;//set -1 to be validated
	//Solicitud LIS
	sbSql.append(" union all select 'REQLIS' as rec_type, count(*) as n_recs from tbl_cds_detalle_solicitud z where (z.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz = 'LIS')) and z.estado in ('S') and z.estudio_dev = 'N' and z.estudio_realizado = 'N' and z.pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and z.csxp_admi_secuencia = ");
	sbSql.append(noAdmision);

}
if (chkReqRIS) {

	rReqRIS = -1;//set -1 to be validated
	//Solicitud RIS
	sbSql.append(" union all select 'REQRIS' as rec_type, count(*) as n_recs from tbl_cds_detalle_solicitud z where (z.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz = 'RIS')) and z.estado in ('S') and z.estudio_dev = 'N' and z.estudio_realizado = 'N' and z.expediente = 'S' and z.pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and z.csxp_admi_secuencia = ");
	sbSql.append(noAdmision);

}
if (chkReqIU) {

	rReqI = -1;//set -1 to be validated
	rReqU = -1;//set -1 to be validated
	rReqD = -1;//set -1 to be validated
	//Inv. Solicitud Insumos
	sbSql.append(" union all select 'REQINSUMO' as rec_type, count(*) as n_recs from tbl_inv_solicitud_pac z where z.estado = 'P' and z.pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and z.adm_secuencia = ");
	sbSql.append(noAdmision);
	//Inv. Solicitud y Devoluciones Usos
	sbSql.append(" union all select 'REQDEVUSO' as rec_type, count(*) as n_recs from tbl_sal_cargos_usos z where z.estado = 'P' and z.tipo in ('C','D') and z.sop = 'N' and z.pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and z.adm_secuencia = ");
	sbSql.append(noAdmision);
	//Inv. Solicitud Devolución
	sbSql.append(" union all select 'REQDEV' as rec_type, count(*) as n_recs from tbl_inv_devolucion_pac z where z.estado = 'T' and z.pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and z.adm_secuencia = ");
	sbSql.append(noAdmision);

}

al = SQLMgr.getDataList(sbSql);

for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	if (cdo.getColValue("rec_type").equalsIgnoreCase("OMFA")) rOMFA = Integer.parseInt(cdo.getColValue("n_recs"));//OM Farmacia x Aprobar
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("OMFD")) rOMFD = Integer.parseInt(cdo.getColValue("n_recs"));//OM Farmacia x Despachar
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("DEV")) rDev = Integer.parseInt(cdo.getColValue("n_recs"));//Devoluciones mayores que cargos
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("OM")) rOM = Integer.parseInt(cdo.getColValue("n_recs"));//OM x ejecutar
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("CHGSOP")) rSOPChg = Integer.parseInt(cdo.getColValue("n_recs"));//Cargos SOP sin Cita
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("OMFABM")) rOMFABM = Integer.parseInt(cdo.getColValue("n_recs"));//OM Farmacia BM x Aprobar
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("OMFDBM")) rOMFDBM = Integer.parseInt(cdo.getColValue("n_recs"));//OM Farmacia BM x Despachar
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("OMDEV")) rOMDEV = Integer.parseInt(cdo.getColValue("n_recs"));//OM Farmacia Devoluciones
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("REQLIS")) rReqLIS = Integer.parseInt(cdo.getColValue("n_recs"));//Solicitud LIS
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("REQRIS")) rReqRIS = Integer.parseInt(cdo.getColValue("n_recs"));//Solicitud RIS
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("REQINSUMO")) rReqI = Integer.parseInt(cdo.getColValue("n_recs"));//Solicitud Insumos Exp.
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("REQDEVUSO")) rReqU = Integer.parseInt(cdo.getColValue("n_recs"));//Solicitud y Devoluciones Usos Exp.
	else if (cdo.getColValue("rec_type").equalsIgnoreCase("REQDEV")) rReqD = Integer.parseInt(cdo.getColValue("n_recs"));//Solicitud Devolución Exp.
}
if (rOMFA == 0 && rOMFD == 0 && rDev == 0 && rSOPChg == 0 && rOMFABM == 0 && rOMFDBM == 0 && rOMDEV == 0 && rReqLIS == 0 && rReqRIS == 0 && rReqI == 0 && rReqU == 0 && rReqD == 0) {//OM is not been validated at this moment, to validate add " && rOM == 0"
%>
<jsp:forward page="../facturacion/reg_analisis_fact2.jsp">
<jsp:param name="mode" value="${param.mode}"/>
<jsp:param name="pacienteId" value="${param.pacienteId}"/>
<jsp:param name="noAdmision" value="${param.noAdmision}"/>
<jsp:param name="fg" value="${param.fg}"/>
<jsp:param name="verified" value="ok"/>
</jsp:forward>
<% } %>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURAS"></jsp:param>
</jsp:include>
<table align="center" width="50%" cellpadding="5" cellspacing="1" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td class="TextInfo">
				La Cuenta #${param.pacienteId}-${param.noAdmision} no puede ser facturada debido a lo siguiente:
				<ul>
				<% if (rOMFA != 0) { %><li>Ordenes de Farmacia por aprobar: <%=rOMFA%></li><% } %>
				<% if (rOMFD != 0) { %><li>Ordenes de Farmacia por despachar: <%=rOMFD%></li><% } %>
				<% if (rOMFABM != 0) { %><li>Ordenes de BANCO por aprobar: <%=rOMFABM%></li><% } %>
				<% if (rOMFDBM != 0) { %><li>Ordenes de BANCO por despachar: <%=rOMFDBM%></li><% } %>
				<% if (rOMDEV != 0) { %><li>Solicitudes de Devoluciones de Farmacia por Confirmar: <%=rOMDEV%></li><% } %>
				<% if (rDev != 0) { %><li>Devoluciones mayores a Cargos: <%=rDev%></li><% } %>
				<% if (rOM != 0) { %><!--<li>Ordenes Médica pendientes: <%=rOM%></li>--><% } %>
				<% if (rSOPChg != 0) { %><li>Cargos a SOP en Admisi&oacute;n sin Cita Asociada: <%=rSOPChg%></li><% } %>
				<% if (rReqLIS != 0) { %><li>Solicitudes de Laboratorio pendientes: <%=rReqLIS%></li><% } %>
				<% if (rReqRIS != 0) { %><li>Solicitudes de Imagenolog&iacute;a pendientes: <%=rReqRIS%></li><% } %>
				<% if (rReqI != 0) { %><li>Solicitudes de Insumos pendientes: <%=rReqI%></li><% } %>
				<% if (rReqU != 0) { %><li>Solicitudes y Devoluciones de Usos pendientes: <%=rReqU%></li><% } %>
				<% if (rReqD != 0) { %><li>Solicitudes de Devoluci&oacute;n pendientes: <%=rReqD%></li><% } %>
				</ul>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>