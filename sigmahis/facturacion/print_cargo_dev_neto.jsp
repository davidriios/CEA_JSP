<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%@ include file="../common/pdf_header.jsp"%>
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
ArrayList alTS = new ArrayList();
ArrayList alTST = new ArrayList();
ArrayList alCDST = new ArrayList();
ArrayList alPlan = new ArrayList();
ArrayList alPlanMed = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlFilter = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String noSecuencia = request.getParameter("noSecuencia");
String pacId = request.getParameter("pacId");
String tipoServ = request.getParameter("tipoServ");
String fDesde = request.getParameter("fDesde");
String fHasta = request.getParameter("fHasta");
String articulo = request.getParameter("articulo");
String fp = request.getParameter("fp");
String factura = request.getParameter("factura");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String listId = request.getParameter("listId");
String cdsFilter = request.getParameter("cdsFilter");
String  cdsDet= "N";
String categoria = request.getParameter("categoria");
String categoria_desc = request.getParameter("categoria_desc");
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}

boolean shortFormat = false;
sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(-1,'FAC_SHORT_CARGODEV_FORCED'),'N') as short_format, nvl(get_sec_comp_param(-1,'FAC_SHORT_CARGODEV_PREPRINTED'),'N') as preprinted, nvl(get_sec_comp_param(-1,'FAC_SHOW_CONVENIO_PLAN'),'N') as show_convenio_plan, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'COD_TIPO_SERV_HON'),'-') as ts_hon from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
if (p != null) {
	if (p.getColValue("short_format") != null) shortFormat = (p.getColValue("short_format").equalsIgnoreCase("S") || p.getColValue("short_format").equalsIgnoreCase("Y"));
	if (p.getColValue("ts_hon") != null && p.getColValue("ts_hon").equals("-")) throw new Exception("El parámetro de Tipo de Servicio Honorario [COD_TIPO_SERV_HON] no está definido!");
}
if (shortFormat) {

	StringBuffer sbUrl = new StringBuffer();
	sbUrl.append("../facturacion/print_dcargo_dev.jsp?net&");
	sbUrl.append(request.getQueryString());
	if (p != null && p.getColValue("preprinted") != null && (p.getColValue("preprinted").equalsIgnoreCase("S") || p.getColValue("preprinted").equalsIgnoreCase("Y"))) sbUrl.append("&preprinted");
	response.sendRedirect(sbUrl.toString());
	return;
}

if (p.getColValue("show_convenio_plan").equalsIgnoreCase("S") || p.getColValue("show_convenio_plan").equalsIgnoreCase("Y")) {
	sbSql = new StringBuffer();
	sbSql.append("select prioridad, (select nombre from tbl_adm_convenio where empresa = z.empresa and secuencia = z.convenio) as convenio, (select nombre from tbl_adm_plan_convenio where empresa = z.empresa and convenio = z.convenio and secuencia = z.plan) as convenio_plan from tbl_adm_beneficios_x_admision z where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and admision = ");
	sbSql.append(noSecuencia);
	sbSql.append(" and nvl(estado,'A') = 'A' order by prioridad");
	alPlan = SQLMgr.getDataList(sbSql.toString());
}

String empresa = request.getParameter("empresa")==null?"":request.getParameter("empresa");
String prioridad = request.getParameter("prioridad")==null?"":request.getParameter("prioridad");
String detallado = request.getParameter("detallado")==null?"N":request.getParameter("detallado");
String yearList = request.getParameter("yearList");
String mesList = request.getParameter("mesList");
if (yearList == null) yearList = "0";
if (mesList == null) mesList = "";

if (appendFilter == null) appendFilter = "";
if (tipoServ == null) tipoServ = "";
if (fDesde == null) fDesde = "";
if (fHasta == null) fHasta = "";
if (articulo == null) articulo = "";
if (fp == null) fp = "";
if (factura == null) factura = "";
if (listId == null) listId = "";
if (cdsFilter == null) cdsFilter = "";
if (categoria == null) categoria = "";
if (categoria_desc == null) categoria_desc = "";
if(!tipoServ.equals("")){sbSqlFilter.append(" and z.tipo_cargo = ");sbSqlFilter.append(tipoServ);}
if(!fDesde.equals("")){sbSqlFilter.append(" and z.fecha_cargo >= to_date('");sbSqlFilter.append(fDesde);sbSqlFilter.append("', 'dd/mm/yyyy')");}
if(!fHasta.equals("")){sbSqlFilter.append(" and z.fecha_cargo <= to_date('");sbSqlFilter.append(fHasta);sbSqlFilter.append("', 'dd/mm/yyyy')");}
if(!articulo.equals("")){sbSqlFilter.append(" and upper(z.descripcion) like '%");sbSqlFilter.append(articulo.toUpperCase());sbSqlFilter.append("%'");}

sbSql = new StringBuffer();
sbSql.append("select p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, a.secuencia admision, a.codigo_paciente, to_char(p.f_nac,'dd/mm/yyyy') as fecha_nacimiento, nvl(to_char(p.f_nac,'dd/mm/yyyy'),' ') as f_nac, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'), ' ') as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula as cedula, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as desc_categoria, c.descripcion as area_desc, a.medico, t.descripcion as dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado, p.pac_id, p.residencia_direccion, (case when a.adm_type = 'I' then to_char((coalesce(trunc(a.fecha_egreso),trunc(sysdate))-trunc(a.fecha_ingreso))) else 'N/A' end) as dias_hospitalizado, d.primer_nombre||' '||d.segundo_nombre||' '||d.primer_apellido||' '||d.segundo_apellido||' '||d.apellido_de_casada as nombre_medico, getFacturaAseg(a.secuencia, a.pac_id,");
if (!empresa.trim().equals(""))sbSql.append(empresa);
else sbSql.append("a.aseguradora");
sbSql.append(",");
if (!prioridad.trim().equals("")){sbSql.append(prioridad);}
else sbSql.append("null");
 sbSql.append(" ) as no_factura, getAseguradora(a.secuencia, a.pac_id, ");
sbSql.append(empresa.trim().equals("")?"a.aseguradora":empresa);
sbSql.append(") as aseguradora, getNumPoliza(a.secuencia, a.pac_id, a.aseguradora, e.prioridad) as num_poliza, nvl(e.num_aprobacion, 0) as num_aprobacion, getDiagnostico(a.secuencia, a.pac_id) as diagnostico, nvl(trunc(months_between(sysdate, p.f_nac) / 12), 0) as edad,nvl(get_adm_doblecobertura_msg(a.pac_id,a.secuencia),' ') as doble_msg");
sbSql.append(", nvl((select sum(decode(z.centro_servicio,0,decode(z.tipo_transaccion,'H',coalesce(z.difpaq_cantidad,z.cantidad),-coalesce(z.difpaq_cantidad,z.cantidad))) * (z.monto + nvl(z.recargo,0))) from tbl_fac_detalle_transaccion z where z.compania = a.compania and z.pac_id = a.pac_id and z.fac_secuencia = a.secuencia and (nvl(z.ref_type,'-') <> 'PAQ' or nvl(z.difpaq_cantidad,0) > 0)");
sbSql.append(sbSqlFilter.toString());
sbSql.append("),0) as honorarios");
sbSql.append(", nvl((select sum(decode(z.centro_servicio,0,0,decode(z.tipo_transaccion,'C',coalesce(z.difpaq_cantidad,z.cantidad),-coalesce(z.difpaq_cantidad,z.cantidad))) * (z.monto + nvl(z.recargo,0))) from tbl_fac_detalle_transaccion z where z.compania = a.compania and z.pac_id = a.pac_id and z.fac_secuencia = a.secuencia and (nvl(z.ref_type,'-') <> 'PAQ' or nvl(z.difpaq_cantidad,0) > 0)");
sbSql.append(sbSqlFilter.toString());
sbSql.append("),0) + nvl((select z.precio_paq from tbl_adm_clasif_x_plan_conv z where paquete = 'S' and exists (select null from tbl_fac_detalle_transaccion where ref_type = 'PAQ' and pac_id = a.pac_id and fac_secuencia = a.secuencia and compania = a.compania and ref_id = z.cod_reg) and exists (select null from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.secuencia and prioridad = 1 and estado = 'A' and empresa = z.empresa and convenio = z.convenio and plan = z.plan and categoria_admi = z.categoria_admi and tipo_admi = z.tipo_admi and clasif_admi = z.clasif_admi)),0) as cargos");
sbSql.append(", nvl((select sum(monto) from tbl_cja_detalle_pago z where compania = a.compania and admi_secuencia = a.secuencia and exists (select null from tbl_cja_transaccion_pago where compania = z.compania and anio = z.tran_anio and codigo = z.codigo_transaccion and pac_id = a.pac_id and rec_status = 'A')),0) as pagos");
sbSql.append(", nvl(decode((select count(*) from tbl_fac_factura where compania = a.compania and pac_id = a.pac_id and admi_secuencia = a.secuencia),0,get_sec_comp_param(a.compania,'FAC_SHOW_BALANCE')),'N') as show_balance,nvl((select nombre from tbl_adm_responsable where pac_id=a.pac_id and admision=a.secuencia and estado='A'),' ')responsable, a.observ_adm as info_importante, p.e_mail, nvl((select 'S' from tbl_pm_cliente pp where pp.pac_id = a.pac_id), 'N') paciente_plan_medico");
sbSql.append(" from vw_adm_paciente p, tbl_adm_admision a, tbl_cds_centro_servicio c, tbl_adm_tipo_admision_cia t, tbl_adm_medico d, (select pac_id, admision, min(prioridad) as prioridad, decode(min(prioridad),1, min(num_aprobacion),0) as num_aprobacion from tbl_adm_beneficios_x_admision where estado = 'A' ");

if (!empresa.trim().equals("")){
	sbSql.append(" and empresa = ");
	sbSql.append(empresa);
	sbSql.append(" and prioridad = ");
	sbSql.append(prioridad);
}
sbSql.append(" group by pac_id, admision) e where a.pac_id=p.pac_id and a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and c.codigo=a.centro_servicio and t.categoria=a.categoria and t.codigo=a.tipo_admision and a.medico=d.codigo and a.secuencia=e.admision(+) and a.pac_id=e.pac_id(+) and a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.secuencia=");
sbSql.append(noSecuencia);
CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSqlFilter = new StringBuffer();
if(!tipoServ.equals("")){sbSqlFilter.append(" and b.tipo_cargo = ");sbSqlFilter.append(tipoServ);}
if(!fDesde.equals("")){sbSqlFilter.append(" and b.fecha_cargo >= to_date('");sbSqlFilter.append(fDesde);sbSqlFilter.append("', 'dd/mm/yyyy')");}
if(!fHasta.equals("")){sbSqlFilter.append(" and b.fecha_cargo <= to_date('");sbSqlFilter.append(fHasta);sbSqlFilter.append("', 'dd/mm/yyyy')");}
if(!articulo.equals("")){sbSqlFilter.append(" and upper(b.descripcion) like '%");sbSqlFilter.append(articulo.toUpperCase());sbSqlFilter.append("%'");}

sbSql.append("select z.*, decode (z.tipo_transaccion, 'C', nvl (z.descripcion, ' '), 'D', decode (z.tipo_cargo,'");
sbSql.append(p.getColValue("ts_hon"));
sbSql.append("', coalesce ((select   '[' || codigo || '] ' || nombre from tbl_adm_empresa where codigo = z.empre_codigo),(select '['|| nvl(reg_medico,codigo)|| '] '|| primer_apellido|| ' '|| segundo_apellido|| ' '|| apellido_de_casada|| ', '|| primer_nombre || ' '|| segundo_nombre from   tbl_adm_medico where   codigo = z.med_codigo)), nvl (z.descripcion, ' ') ), 'H', coalesce ((select '[' || codigo || '] ' || nombre from tbl_adm_empresa where codigo = z.empre_codigo),(select '['|| nvl(reg_medico,codigo)|| '] '|| primer_apellido|| ' '|| segundo_apellido|| ' '|| apellido_de_casada|| ', '|| primer_nombre || ' '|| segundo_nombre from tbl_adm_medico where   codigo = z.med_codigo)), nvl (z.descripcion, ' ')) as descripcion from (");

sbSql.append("select c.descripcion centro_servicio_desc, (case when x.cant_hon > 0 and x.cant_hon > x.cant_dev then 'H' when x.cant_cargo > 0 and x.cant_cargo > x.cant_dev then 'C' else 'D' end) tipo_transaccion, x.centro_servicio, x.tipo_cargo, x.med_codigo, x.empre_codigo, x.descripcion, (x.monto + nvl (x.recargo, 0)) as monto, x.cantidad cantidad_total, x.cantidad * (x.monto + nvl (x.recargo, 0)) monto_total, coalesce (x.procedimiento, x.habitacion, '' || x.cds_producto, '' || x.cod_uso, '' || x.otros_cargos, '' || x.cod_paq_x_cds, decode (x.articulo, null, '', x.articulo), ' ') as trabajo, x.fecha_cargo as fecha_cargos, f_cargo");
sbSql.append(", decode((select count(*) from tbl_adm_gastos_no_cubiertos a where exists (select null from tbl_adm_beneficios_x_admision where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and admision = ");
sbSql.append(noSecuencia);
sbSql.append(" and prioridad = 1 and nvl(estado,'A') = 'A' and empresa = a.cod_empresa and convenio = a.cod_convenio) and tipo_servicio = x.tipo_cargo and ((procedimiento = x.procedimiento and compania is null) or (art_familia||'-'||art_clase||'-'||inv_articulo = x.articulo) or cod_uso = x.cod_uso or otros_cargos = x.otros_cargos or cds_producto = x.cds_producto or habitacion = x.habitacion and compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(")),0,0,1) as gnc");
sbSql.append(" from (");

sbSql.append("select ");
if(cdsDet.trim().equals("S"))sbSql.append(" b.centro_servicio, ");
else sbSql.append(" a.centro_servicio, ");
sbSql.append(" b.tipo_cargo, decode(b.centro_servicio,get_sec_comp_param(a.compania,'CDS_HON'),a.med_codigo,null) as med_codigo, a.empre_codigo, b.descripcion, b.monto, nvl(b.recargo, 0) recargo, b.procedimiento, b.habitacion, b.cds_producto, b.cod_uso, b.otros_cargos, b.cod_paq_x_cds, b.art_familia || '-' || b.art_clase || '-' || b.inv_articulo articulo, sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),0)) cant_dev, sum(decode(b.tipo_transaccion,'H',coalesce(b.difpaq_cantidad,b.cantidad),0)) cant_hon, sum(decode(b.tipo_transaccion,'C',coalesce(b.difpaq_cantidad,b.cantidad),0)) cant_cargo, (sum(decode(b.tipo_transaccion,'H',coalesce(b.difpaq_cantidad,b.cantidad),0)) + sum(decode(b.tipo_transaccion,'C',coalesce(b.difpaq_cantidad,b.cantidad),0))+sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),0))) cantidad,to_char(b.fecha_cargo,'dd/mm/yyyy') fecha_cargo,b.fecha_cargo f_cargo from   tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.admi_secuencia=");
sbSql.append(noSecuencia);
sbSql.append(" and a.compania=");
sbSql.append(session.getAttribute("_companyId"));
if(!cdsFilter.equals("")){
if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
else sbSql.append(" and a.centro_servicio = ");
sbSql.append(cdsFilter);
}
sbSql.append(sbSqlFilter.toString());
sbSql.append(" and a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.compania = b.compania and a.tipo_transaccion = b.tipo_transaccion and (nvl(b.ref_type,'-') <> 'PAQ' or nvl(b.difpaq_cantidad,0) > 0) group by ");
if(cdsDet.trim().equals("S"))sbSql.append(" b.centro_servicio, ");
else sbSql.append(" a.centro_servicio, ");
sbSql.append(" b.tipo_cargo, decode(b.centro_servicio,get_sec_comp_param(a.compania,'CDS_HON'),a.med_codigo,null), a.empre_codigo, b.descripcion, b.monto, nvl(b.recargo, 0), b.procedimiento, b.habitacion, b.cds_producto, b.cod_uso, b.otros_cargos, b.cod_paq_x_cds, b.art_familia || '-' || b.art_clase || '-' || b.inv_articulo ,b.fecha_cargo");

sbSql.append(") x, tbl_cds_centro_servicio c where x.centro_servicio = c.codigo and x.cantidad != 0");

sbSql.append(") z order by 3, 2,13 asc");

al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select ");
if(cdsDet.trim().equals("S"))sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio");
sbSql.append(", b.tipo_cargo, decode(b.centro_servicio,get_sec_comp_param(a.compania,'CDS_HON'),a.med_codigo,null) as med_codigo, a.empre_codigo, b.descripcion, b.monto, nvl(b.recargo,0), b.procedimiento, b.habitacion, b.cds_producto, b.cod_uso, b.otros_cargos, b.cod_paq_x_cds, b.art_familia||'-'||b.art_clase||'-'||b.inv_articulo, coalesce(b.procedimiento,b.habitacion,''||b.cds_producto,''||b.cod_uso,''||b.otros_cargos,''||b.cod_paq_x_cds,decode(b.art_familia||b.art_clase||b.inv_articulo,null,'',b.art_familia||'-'||b.art_clase||'-'||b.inv_articulo),' ') as trabajo, sum(decode(b.tipo_transaccion,'D',-(b.cantidad - nvl(b.difpaq_cantidad,0)),(b.cantidad - nvl(b.difpaq_cantidad,0)))) as cantidad, (select descripcion from tbl_cds_centro_servicio where codigo = ");
if(cdsDet.trim().equals("S"))sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio");
sbSql.append(") as cds, b.ref_id, nvl((select nombre||' - '||id from tbl_fac_cotizacion where id = b.ref_id),' ') as paq_name, nvl((select z.precio_paq from tbl_adm_clasif_x_plan_conv z where paquete = 'S' and z.cod_reg = b.ref_id and exists (select null from tbl_adm_beneficios_x_admision where pac_id = b.pac_id and admision = b.fac_secuencia and prioridad = 1 and estado = 'A' and empresa = z.empresa and convenio = z.convenio and plan = z.plan and categoria_admi = z.categoria_admi and tipo_admi = z.tipo_admi and clasif_admi = z.clasif_admi)),0) as paq_price from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where b.ref_type = 'PAQ' and b.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and b.fac_secuencia = ");
sbSql.append(noSecuencia);
sbSql.append(" and b.compania = ");
sbSql.append(session.getAttribute("_companyId"));
if(!cdsFilter.equals("")){
if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
else sbSql.append(" and a.centro_servicio = ");
sbSql.append(cdsFilter);
}
sbSql.append(" and a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.compania = b.compania and a.tipo_transaccion = b.tipo_transaccion group by ");
if(cdsDet.trim().equals("S"))sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio");
sbSql.append(", b.tipo_cargo, decode(b.centro_servicio,get_sec_comp_param(a.compania,'CDS_HON'),a.med_codigo,null), a.empre_codigo, b.descripcion, b.monto, nvl(b.recargo,0), b.procedimiento, b.habitacion, b.cds_producto, b.cod_uso, b.otros_cargos, b.cod_paq_x_cds, b.art_familia, b.art_clase, b.inv_articulo, b.ref_id, b.pac_id, b.fac_secuencia having sum(decode(b.tipo_transaccion,'D',-(b.cantidad - nvl(b.difpaq_cantidad,0)),(b.cantidad - nvl(b.difpaq_cantidad,0)))) <> 0 order by 18,1");
ArrayList alPaq = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select ");
if(cdsDet.trim().equals("S"))sbSql.append(" b.centro_servicio, ");
else sbSql.append(" a.centro_servicio, ");
sbSql.append(" b.tipo_cargo, sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad)) * (b.monto + nvl(b.recargo,0))) as monto, (select descripcion from tbl_cds_tipo_servicio where codigo=b.tipo_cargo) as descripcion from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.admi_secuencia=");
sbSql.append(noSecuencia);
if(!cdsFilter.equals("")){
if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
else sbSql.append(" and a.centro_servicio = ");
sbSql.append(cdsFilter);
}
sbSql.append(" and a.codigo=b.fac_codigo and a.pac_id=b.pac_id and a.admi_secuencia=b.fac_secuencia and a.tipo_transaccion=b.tipo_transaccion and (nvl(b.ref_type,'-') <> 'PAQ' or nvl(b.difpaq_cantidad,0) > 0) group by ");
if(cdsDet.trim().equals("S"))sbSql.append(" b.centro_servicio, ");
else sbSql.append(" a.centro_servicio, ");
sbSql.append(" b.tipo_cargo order by 1,4");
alTS = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select ");
if (cdsDet.equalsIgnoreCase("S")) sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio");
sbSql.append(", sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad)) * (b.monto + nvl(b.recargo,0))) as monto, (select descripcion from tbl_cds_centro_servicio where codigo = ");
if (cdsDet.equalsIgnoreCase("S")) sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio");
sbSql.append(") as descripcion from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.admi_secuencia = ");
sbSql.append(noSecuencia);
if(!cdsFilter.equals("")){
if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
else sbSql.append(" and a.centro_servicio = ");
sbSql.append(cdsFilter);
}
sbSql.append(sbSqlFilter.toString());
sbSql.append(" and a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.tipo_transaccion = b.tipo_transaccion and (nvl(b.ref_type,'-') <> 'PAQ' or nvl(b.difpaq_cantidad,0) > 0) group by ");
if (cdsDet.equalsIgnoreCase("S")) sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio");
sbSql.append(" order by 1,3");
alCDST = SQLMgr.getDataList(sbSql.toString());


sbSql = new StringBuffer();
sbSql.append("select b.tipo_cargo, sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad)) * (b.monto + nvl(b.recargo,0))) as monto, (select descripcion from tbl_cds_tipo_servicio where codigo=b.tipo_cargo) as descripcion from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.admi_secuencia=");
sbSql.append(noSecuencia);
if(!cdsFilter.equals("")){
if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
else sbSql.append(" and a.centro_servicio = ");
sbSql.append(cdsFilter);
}
sbSql.append(sbSqlFilter.toString());
sbSql.append(" and a.codigo=b.fac_codigo and a.pac_id=b.pac_id and a.admi_secuencia=b.fac_secuencia and a.tipo_transaccion=b.tipo_transaccion and (nvl(b.ref_type,'-') <> 'PAQ' or nvl(b.difpaq_cantidad,0) > 0) group by b.tipo_cargo order by 1,3");
alTST = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select b.descripcion, sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad)) * (b.monto + nvl(b.recargo,0))) as monto, sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad))) as cantidad_total from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.admi_secuencia = ");
sbSql.append(noSecuencia);
sbSql.append(sbSqlFilter.toString());
if(!cdsFilter.equals("")){
if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
else sbSql.append(" and a.centro_servicio = ");
sbSql.append(cdsFilter);
}
sbSql.append(" and a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.tipo_transaccion = b.tipo_transaccion and b.tipo_cargo = '01' and (nvl(b.ref_type,'-') <> 'PAQ' or nvl(b.difpaq_cantidad,0) > 0) group by b.descripcion order by 1,2");
ArrayList alTHAB = SQLMgr.getDataList(sbSql.toString());


/*=============================================*/
/*  P   L   A   N       M   E   D   I   C   O  */
/*=============================================*/
if(cdoHeader.getColValue("paciente_plan_medico").equals("S")){
sbSql = new StringBuffer();

sbSql.append("select a.porc, to_char(fecha_desde, 'dd/mm/yyyy') fecha_desde, to_char(fecha_hasta, 'dd/mm/yyyy') fecha_hasta, monto, monto*(a.porc/100) monto_total, porc ||'% Despues de' || decode(porc, 20, 'l 6to día', 30, ' 12 días', 50, ' 30 días') || (case when porc in (20, 30) then ' [ '|| to_char(fecha_desde, 'dd/mm/yyyy') || ' - ' || to_char(fecha_hasta, 'dd/mm/yyyy') ||']' else ' [ '||to_char(fecha_desde, 'dd/mm/yyyy') || ' en adelante ]' end) descripcion from (select a.porc, fecha_ingreso, a.fecha_desde, a.fecha_hasta, sum(case when b.fecha_cargo between a.fecha_desde and a.fecha_hasta then monto else 0 end) monto from (select 20 porc, fecha_ingreso, fecha_ingreso + 6 fecha_desde, fecha_ingreso + 11 fecha_hasta from tbl_adm_admision where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noSecuencia);
sbSql.append(" union select 30 porc, fecha_ingreso, fecha_ingreso + 12 fecha_desde, fecha_ingreso + 29 fecha_hasta from tbl_adm_admision where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noSecuencia);
sbSql.append(" union select 50 porc, fecha_ingreso, fecha_ingreso + 30 fecha_desde, fecha_ingreso + (365*5) fecha_hasta from tbl_adm_admision where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noSecuencia);
sbSql.append(") a, ( SELECT b.fecha_cargo, SUM (DECODE (b.tipo_transaccion, 'D', -COALESCE (b.difpaq_cantidad, b.cantidad), COALESCE (b.difpaq_cantidad, b.cantidad)) * (b.monto + NVL (b.recargo, 0))) AS monto FROM tbl_fac_transaccion a, tbl_fac_detalle_transaccion b WHERE a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" AND a.admi_secuencia = ");
sbSql.append(noSecuencia);
sbSql.append(sbSqlFilter.toString());
sbSql.append(" AND a.codigo = b.fac_codigo AND a.pac_id = b.pac_id AND a.admi_secuencia = b.fac_secuencia AND a.tipo_transaccion = b.tipo_transaccion and b.centro_servicio != 0 AND (NVL (b.ref_type, '-') <> 'PAQ' OR NVL (b.difpaq_cantidad, 0) > 0) GROUP BY b.fecha_cargo) b where b.fecha_cargo between a.fecha_desde and a.fecha_hasta group by a.porc, fecha_ingreso, a.fecha_desde, a.fecha_hasta) a order by a.porc");
alPlanMed = SQLMgr.getDataList(sbSql.toString());
System.out.println("query pm............................."+sbSql.toString());
}
/*=============================================*/
/**/
/**/

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);


	if((fp.equals("lista_envio")||fp.equals("lista_envio_aseg")) && !yearList.equals("0")) year = yearList;

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";


	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";
	if(!mesList.equals("")) month = mesList;

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	String subFolderName = "archivos";
	if(fp.equals("lista_envio")||fp.equals("lista_envio_aseg")){
		if(fp.equals("lista_envio"))directory = ResourceBundle.getBundle("path").getString("docs.files_axa")+"/";
		else if(fp.equals("lista_envio_aseg"))directory = ResourceBundle.getBundle("path").getString("docs.files_aseg")+"/";
		folderName=categoria_desc;
		if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	} else  if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "DETALLE DE CARGOS";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	if(fp.equals("lista_envio")) fileName=factura+"_CAR.pdf";
	else if(fp.equals("lista_envio_aseg")) fileName=pacId+noSecuencia+"_AUDI.pdf";
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+(fp.equals("lista_envio")?"":"")+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".04");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".13");
		dHeader.addElement(".10");
		dHeader.addElement(".06");
		dHeader.addElement(".07");
		dHeader.addElement(".09");
	float tsSize = (width - (leftRightMargin * 2)) * 0.83f;//0.83 = 1 - (first col + last col); //507.96f;
	Vector dTs = new Vector();
		dTs.addElement(".01");
		dTs.addElement(".33");
		dTs.addElement(".15");
		dTs.addElement(".01");
		dTs.addElement(".01");
		dTs.addElement(".33");
		dTs.addElement(".15");
		dTs.addElement(".01");
	float resSize = 416.16f;
	Vector dRes = new Vector();
		dRes.addElement(".25");
		dRes.addElement(".25");
		dRes.addElement(".25");
		dRes.addElement(".25");

		Vector dPM = new Vector();
		dPM.addElement(".50");
		dPM.addElement(".25");
		dPM.addElement(".25");

		Vector dTh = new Vector();
		dTh.addElement(".01");
		dTh.addElement(".33");
		dTh.addElement(".05");
		dTh.addElement(".10");
		dTh.addElement(".01");
		dTh.addElement(".01");
		dTh.addElement(".33");
		dTh.addElement(".05");
		dTh.addElement(".10");
		dTh.addElement(".01");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		pc.addBorderCols("Nombre:",0,2,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoHeader.getColValue("nombre"),0,5,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("PID - Admision:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoHeader.getColValue("pac_id")+"-"+(cdoHeader.getColValue("admision"))+" "+" "+" "+" Fecha Nac.: "+cdoHeader.getColValue("fecha_nacimiento"),0,4,0.0f,0.5f,0.0f,0.0f);

		pc.addCols("Cédula:",0,2);
		pc.addCols(cdoHeader.getColValue("cedula")+" "+" "+" "+" Sexo: "+cdoHeader.getColValue("sexo")+" "+" "+" "+" Edad: "+cdoHeader.getColValue("edad"),0,5);
		pc.addCols("Factura No.:",0,1);
		pc.addCols(cdoHeader.getColValue("no_factura"),0,4);

		pc.addCols("Pasaporte:",0,2);
		pc.addCols(cdoHeader.getColValue("pasaporte"),0,5);
		pc.addCols("Categoría:",0,1);
		pc.addCols(cdoHeader.getColValue("desc_categoria"),0,4);

		pc.addCols("Dirección Residencial:",0,2);
		pc.addCols(cdoHeader.getColValue("residencia_direccion"),0,5);
		pc.addCols("Aseguradora:",0,1);
		pc.addCols(cdoHeader.getColValue("aseguradora"),0,4);

		pc.addCols("Fecha Ingreso:",0,2);
		pc.addCols(cdoHeader.getColValue("fecha_ingreso"),0,5);
		pc.addCols("Poliza #.:",0,1);
		pc.addCols(cdoHeader.getColValue("num_poliza"),0,4);

		pc.addCols("Fecha Egreso:",0,2);
		pc.addCols(cdoHeader.getColValue("fecha_egreso"),0,5);
		pc.addCols("Num. Aprob.:",0,1);
		pc.addCols(cdoHeader.getColValue("num_aprobacion"),0,4);

		pc.addCols("Días Hospitalizados:",0,2);
		pc.addCols(cdoHeader.getColValue("dias_hospitalizado"),0,5);
		pc.addCols("ICD9:",0,1);
		pc.addCols(cdoHeader.getColValue("diagnostico"),0,4);

		pc.addCols("Médico:",0,2);
		pc.addCols(cdoHeader.getColValue("nombre_medico"),0,5);
		pc.addCols("Area Admite:",0,1);
		pc.addCols(cdoHeader.getColValue("area_desc"),0,4);

				pc.addCols("Inf. Importante:",0,2);
		pc.addCols(cdoHeader.getColValue("info_importante"),0,5);
		pc.addCols("Correo:",0,1);
		pc.addCols(cdoHeader.getColValue("e_mail"),0,4);

				pc.addCols(" ",0,12);

	if (cdoHeader.getColValue("show_balance").equalsIgnoreCase("S")) {

		pc.setNoColumnFixWidth(dRes);
		pc.createTable("res",false,0,0.0f,resSize);
			pc.addCols(". : :   C U E N T A   P E N D I E N T E   P O R   F A C T U R A R   : : .",1,dRes.size());

			pc.addBorderCols("CARGOS",1,1);
			pc.addBorderCols("HONORARIOS",1,1);
			pc.addBorderCols("PAGOS",1,1);
			pc.addBorderCols("SALDO",1,1);

			double saldo = 0.0;
			saldo += Double.parseDouble(cdoHeader.getColValue("cargos"));
			saldo += Double.parseDouble(cdoHeader.getColValue("honorarios"));
			saldo -= Double.parseDouble(cdoHeader.getColValue("pagos"));
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("cargos")),2,1);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("honorarios")),2,1);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("pagos")),2,1);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo),2,1);

		pc.useTable("main");
		pc.addCols(" ",0,2);
		pc.addTableToCols("res",1,dHeader.size() - 4);
		pc.addCols(" ",0,2);

	}

		pc.setFont(headerFontSize,1);
		pc.addCols("Responsable:",0,2);
		pc.addCols(""+cdoHeader.getColValue("responsable"),0,4);
		pc.setFont(headerFontSize,1,Color.blue);
		pc.addCols(cdoHeader.getColValue("doble_msg"),1,6);

	if (alPlan.size() > 0) {

		pc.setFont(headerFontSize,1);
		pc.setNoColumnFixWidth(dRes);
		pc.createTable("plan",false,0,0.0f,resSize);
			pc.addBorderCols("CONVENIO",1,2);
			pc.addBorderCols("PLAN",1,2);
		for (int i=0; i<alPlan.size(); i++) {
			CommonDataObject cdo = (CommonDataObject) alPlan.get(i);
			pc.addCols(cdo.getColValue("convenio"),0,2);
			pc.addCols(cdo.getColValue("convenio_plan"),0,2);
		}

		pc.useTable("main");
		pc.addCols(" ",0,2);
		pc.addTableToCols("plan",1,dHeader.size() - 4);
		pc.addCols(" ",0,2);

	}

	if (alPlanMed.size() > 0) {

		pc.setFont(headerFontSize,1);
		pc.setNoColumnFixWidth(dPM);
		pc.createTable("plan_medico",false,0,0.0f,resSize);
			pc.addBorderCols("",1,1,0.5f,0.5f,0.0f,0.0f);
			pc.addBorderCols("MONTO CARGOS",1,1,0.5f,0.5f,0.0f,0.0f);
			pc.addBorderCols("MONTO A PAGAR",1,1,0.5f,0.5f,0.0f,0.0f);
			double monto_pm = 0.00, monto_total = 0.00;
		for (int i=0; i<alPlanMed.size(); i++) {
			CommonDataObject cdo = (CommonDataObject) alPlanMed.get(i);
			pc.setFont(contentFontSize,0);
			pc.addCols(cdo.getColValue("descripcion") ,0,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total")),2,1);
			monto_pm += Double.parseDouble(cdo.getColValue("monto"));
			monto_total += Double.parseDouble(cdo.getColValue("monto_total"));
		}
		pc.setFont(headerFontSize,1);
			pc.addBorderCols(" ",0,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(monto_pm),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(monto_total),2,1,0.0f,0.5f,0.0f,0.0f);
	}

	pc.useTable("main");

		pc.setFont(headerFontSize,1);
		pc.addBorderCols("Trn./Cargo",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Tipo",1);
		pc.addBorderCols("Serv.",1);
		pc.addBorderCols("Usuario",1);
		pc.addBorderCols("Código",1);
		pc.addBorderCols("Descripción del Cargo",1,3);
		pc.addBorderCols("Cant.",1);
		pc.addBorderCols("Precio",1);
		pc.addBorderCols("Total",1);
	//pc.setTableHeader(10);//create de table header

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable("paquete",false,0,leftRightMargin * 2);
		pc.setFont(groupFontSize,1);
		pc.addBorderCols(". : :   P A Q U E T E   : : .",1,dHeader.size());

	double total = 0.00;
	String groupBy = "";
	for (int i=0; i<alPaq.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) alPaq.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("ref_id"))) {

			pc.setFont(groupFontSize,1);
			pc.addCols(cdo.getColValue("paq_name"),0,dHeader.size() - 1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("paq_price","0")),2,1);
			total += Double.parseDouble(cdo.getColValue("paq_price","0"));

		}

		pc.setFont(contentFontSize,0);
		pc.addCols(cdo.getColValue("cds"),0,4);
		pc.addCols(cdo.getColValue("tipo_cargo"),1,1);
		pc.addCols(cdo.getColValue("trabajo"),0,1);
		pc.addCols(cdo.getColValue("descripcion"),0,3);
		pc.addCols(cdo.getColValue("cantidad"),2,1);
		pc.addCols(" ",2,1);
		pc.addCols(" ",2,1);
		groupBy = cdo.getColValue("ref_id");
	}
	pc.useTable("main");
	if (alPaq.size() > 0) {
		pc.addTableToCols("paquete",1,dHeader.size(),0.0f,null,null,0.5f,0.5f,0.5f,0.5f);
		pc.addCols(" ",1,dHeader.size());
	}

	//table body
	groupBy = "";
	String groupTitle = "";
	double cdsTotal = 0.00;
	int cdsQtyTotal = 0;
	int qtyTotal = 0;
	boolean delPacDet = true;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("centro_servicio")) && detallado.equals("N") )
		{
			if (i != 0)
			{
				pc.setFont(groupFontSize,1);
				pc.addBorderCols("TOTAL DE "+groupTitle,0,9,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(""+cdsQtyTotal,2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols("",2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdsTotal),2,1,0.0f,0.5f,0.0f,0.0f);
				cdsTotal = 0.00;
				cdsQtyTotal = 0;

				pc.setNoColumnFixWidth(dTs);
				pc.createTable("ts",false,0,0.0f,tsSize);
					pc.addBorderCols("TOTALES POR TIPO DE SERVICIOS",0,dTs.size(),0.5f,0.0f,0.0f,0.0f);

					pc.setFont(groupFontSize-1,0);
					int tsCounter = 0;
					for (int j=0; j<alTS.size(); j++)
					{
						CommonDataObject cdoTS = (CommonDataObject) alTS.get(j);
						if (cdoTS.getColValue("centro_servicio").equalsIgnoreCase(groupBy))
						{
							pc.addCols(" ",0,1);
							pc.addCols(cdoTS.getColValue("descripcion"),0,1);
							pc.addCols(CmnMgr.getFormattedDecimal(cdoTS.getColValue("monto")),2,1);
							pc.addCols(" ",0,1);
							tsCounter++;
						}
					}
					if ((tsCounter % 2) == 1) pc.addCols(" ",0,4);
					pc.addBorderCols("",0,dTs.size(),0.0f,0.5f,0.0f,0.0f);

				pc.setFont(groupFontSize,1);
				pc.useTable("main");
				pc.addCols(" ",0,1);
				pc.addTableToCols("ts",1,10);
				pc.addCols(" ",0,1);

				pc.flushTableBody(true);
				//delete previous cds
				pc.deleteRows(-1);
				//set current cds as header
				pc.setFont(groupFontSize,1);
				pc.addBorderCols(cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("centro_servicio")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
				if (delPacDet)//done only once after printing the first header
				{
					pc.deleteRows(2,8 + ((cdoHeader.getColValue("show_balance").equalsIgnoreCase("S"))?1:0));//delete patient details for next pages, leave only patient name
					delPacDet = false;
				}
				pc.setTableHeader(4);//reset header size and cds
			}
			pc.setFont(groupFontSize,1);
			pc.addBorderCols(cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("centro_servicio")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
			if (i == 0) pc.setTableHeader(12 + ((cdoHeader.getColValue("show_balance").equalsIgnoreCase("S"))?1:0));//set first header with cds
		}//diff cds

		pc.setFont(contentFontSize,cdo.getColValue("gnc").equals("0")?0:1);
		pc.setVAlignment(0);
		pc.addCols("",2,1);
		pc.addCols(cdo.getColValue("fecha_cargos"),1,1);
		pc.addCols(cdo.getColValue("tipo_transaccion"),1,1);
		pc.addCols(cdo.getColValue("tipo_cargo"),1,1);
		pc.addCols("",0,1);
		pc.addCols(cdo.getColValue("trabajo"),0,1);
		pc.addCols(cdo.getColValue("descripcion"),0,3);
		pc.addCols(cdo.getColValue("cantidad_total"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total")),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("centro_servicio");
		groupTitle = cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("centro_servicio")+" ]";
		cdsTotal += Double.parseDouble(cdo.getColValue("monto_total"));
		cdsQtyTotal += Integer.parseInt(cdo.getColValue("cantidad_total"));
		total += Double.parseDouble(cdo.getColValue("monto_total"));
		qtyTotal += Integer.parseInt(cdo.getColValue("cantidad_total"));
	}

	if (al.size() == 0 && alPaq.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {

		if( detallado.equals("N"))	{
			pc.setFont(groupFontSize,1);
			pc.addBorderCols("TOTAL DE "+groupTitle,0,9,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(""+cdsQtyTotal,2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols("",2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdsTotal),2,1,0.0f,0.5f,0.0f,0.0f);

			pc.setNoColumnFixWidth(dTs);
			pc.createTable("ts",false,0,0.0f,tsSize);
				pc.addBorderCols("TOTALES POR TIPO DE SERVICIOS",0,dTs.size(),0.5f,0.0f,0.0f,0.0f);

				pc.setFont(groupFontSize-1,0);
				int tsCounter = 0;
				for (int j=0; j<alTS.size(); j++)
				{
					CommonDataObject cdoTS = (CommonDataObject) alTS.get(j);
					if (cdoTS.getColValue("centro_servicio").equalsIgnoreCase(groupBy))
					{
						pc.addCols(" ",0,1);
						pc.addCols(cdoTS.getColValue("descripcion"),0,1);
						pc.addCols(CmnMgr.getFormattedDecimal(cdoTS.getColValue("monto")),2,1);
						pc.addCols(" ",0,1);
						tsCounter++;
					}
				}
				if ((tsCounter % 2) == 1) pc.addCols(" ",0,4);
				pc.addBorderCols("",0,dTs.size(),0.0f,0.5f,0.0f,0.0f);

			pc.setFont(groupFontSize,1);
			pc.useTable("main");
			pc.addCols(" ",0,1);
			pc.addTableToCols("ts",1,10);
			pc.addCols(" ",0,1);
		}

		//pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());

		pc.addCols(" ",0,dHeader.size());

		pc.addCols(" ",0,dHeader.size());

		pc.setFont(groupFontSize,1);
		pc.setNoColumnFixWidth(dTs);
		pc.createTable("cds",false,0,0.0f,tsSize);
			pc.addBorderCols("POR CENTROS DE SERVICIO:",0,dTs.size(),0.5f,0.0f,0.0f,0.0f);

			pc.setFont(groupFontSize-1,0);
			for (int j=0; j<alCDST.size(); j++) {
				CommonDataObject cds = (CommonDataObject) alCDST.get(j);
				pc.addCols(" ",0,1);
				pc.addCols(cds.getColValue("centro_servicio")+" - "+cds.getColValue("descripcion"),0,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cds.getColValue("monto")),2,1);
				pc.addCols(" ",0,1);
			}
			if ((alCDST.size() % 2) == 1) pc.addCols(" ",0,4);
			pc.addBorderCols("",0,dTs.size(),0.0f,0.5f,0.0f,0.0f);

		pc.setFont(groupFontSize,1);
		pc.setNoColumnFixWidth(dTs);
		pc.createTable("ts",false,0,0.0f,tsSize);
			pc.addBorderCols("POR TIPOS DE SERVICIO:",0,dTs.size(),0.5f,0.0f,0.0f,0.0f);

			pc.setFont(groupFontSize-1,0);
			for (int j=0; j<alTST.size(); j++) {
				CommonDataObject cdoTS = (CommonDataObject) alTST.get(j);
				pc.addCols(" ",0,1);
				pc.addCols(cdoTS.getColValue("tipo_cargo")+" - "+cdoTS.getColValue("descripcion"),0,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdoTS.getColValue("monto")),2,1);
				pc.addCols(" ",0,1);
			}
			if ((alTST.size() % 2) == 1) pc.addCols(" ",0,4);
			pc.addBorderCols("",0,dTs.size(),0.0f,0.5f,0.0f,0.0f);

				int totXhab = 0;
				double totMontoHab = 0.0;
				pc.setFont(groupFontSize,1);
				pc.setNoColumnFixWidth(dTh);
				pc.createTable("hab",false,0,0.0f,tsSize);
						pc.addBorderCols("POR TIPOS DE HABITACION:",0,dTh.size(),0.5f,0.0f,0.0f,0.0f);

						pc.setFont(groupFontSize-1,0);
						for (int j=0; j<alTHAB.size(); j++) {
								CommonDataObject cdoTh = (CommonDataObject) alTHAB.get(j);
								pc.addCols(" ",0,1);
								pc.addCols(cdoTh.getColValue("descripcion"),0,1);
								pc.addCols(cdoTh.getColValue("cantidad_total"),1,1);
								pc.addCols(CmnMgr.getFormattedDecimal(cdoTh.getColValue("monto")),2,1);
								pc.addCols(" ",0,1);

								totXhab += Integer.parseInt(cdoTh.getColValue("cantidad_total","0"));
								totMontoHab += Double.parseDouble(cdoTh.getColValue("monto", "0.0"));
						}
						if ((alTHAB.size() % 2) == 1) pc.addCols(" ",0,5);
						if (alTHAB.size() > 0) {
							pc.setFont(groupFontSize,1);
							pc.addCols("",0,1);
							pc.addCols("TOTAL",0,1);
							pc.addCols(""+totXhab,1,1);
							pc.addCols(""+totMontoHab,2,1);
							pc.addCols(" ",0,1);
							if ((alTHAB.size() % 2) == 1) pc.addCols(" ",0,5);
						}

						pc.addBorderCols("",0,dTh.size(),0.0f,0.5f,0.0f,0.0f);

		pc.setFont(groupFontSize,1);
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable("resumen",false,0,leftRightMargin * 2);
			pc.setFont(groupFontSize,1);
			pc.addBorderCols(". : :   R E S U M E N   : : .",1,dHeader.size());

			pc.setFont(groupFontSize + 1,1);
			pc.addCols("GRAN TOTAL DE CARGOS",0,9);
			pc.addCols(""+qtyTotal,2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(total),2,2);

			pc.addCols(" ",0,1);
			pc.addTableToCols("cds",1,dHeader.size() - 2);
			pc.addCols(" ",0,1);

			pc.addCols(" ",0,1);
			pc.addTableToCols("ts",1,dHeader.size() - 2);
			pc.addCols(" ",0,1);

						pc.addCols(" ",0,1);
						pc.addTableToCols("hab",1,dHeader.size() - 2);
						pc.addCols(" ",0,1);

		/*==========================================*/
		/*  P   L   A   N     M   E   D   I   C   O */
		/*==========================================*/
		if(cdoHeader.getColValue("paciente_plan_medico").equals("S") && alPlanMed.size()>0){
			pc.addCols(" ",0,dHeader.size());

		pc.createTable("resumen_pm",false,0,leftRightMargin * 2);
			pc.setFont(groupFontSize,1);
			pc.addBorderCols(". : :   R E S U M E N   P L A N   M E D I C O: : .",1,dHeader.size());

			pc.setFont(groupFontSize + 1,1);
			pc.addCols("TOTAL DE CARGOS POR ABONO",1,dHeader.size());

			pc.addCols(" ",0,1);
			pc.addTableToCols("plan_medico",1,dHeader.size() - 2);
			pc.addCols(" ",0,1);

		}
		/*==========================================*/


		pc.useTable("main");
		pc.flushTableBody(true);
		//delete previous cds
		pc.deleteRows(-1);
		//set current cds as header
		pc.addCols(" ",1,dHeader.size());

		pc.addTableToCols("resumen",1,dHeader.size(),0.0f,null,null,0.5f,0.5f,0.5f,0.5f);

		pc.addCols("Nota: 'Sr. paciente, este SALDO es al momento de su facturación, En caso de CARGOS ADICIONALES a esta fecha, le será notificado oportunamente'", 0,dHeader.size());

		if(cdoHeader.getColValue("paciente_plan_medico").equals("S") && alPlanMed.size()>0){
			pc.flushTableBody(true);
			pc.useTable("main");

			pc.addNewPage();
			pc.addCols(" ", 0, dHeader.size());
			pc.addTableToCols("resumen_pm",1,dHeader.size(),0.0f,null,null,0.5f,0.5f,0.5f,0.5f);
		}

	}
	pc.flushTableBody(true);
	pc.close();
	//response.sendRedirect(redirectFile);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function closeWindow(){window.close();}
function filtrarImpresion(tipoServ, fDesde, fHasta, articulo){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?noSecuencia=<%=noSecuencia%>&pacId=<%=pacId%>&tipoServ='+tipoServ+'&fDesde='+fDesde+'&fHasta='+fHasta+'&articulo='+articulo;
}
function buscar(){
var tipo_servicio = document.formPrinted.tipo_servicio.value;
var fDesde = document.formPrinted.fDesde.value;
var fHasta = document.formPrinted.fHasta.value;
var articulo = document.formPrinted.articulo.value;
var cdsFilter = document.formPrinted.cdsFilter.value;
window.location = '<%=request.getContextPath()+request.getServletPath()%>?noSecuencia=<%=noSecuencia%>&pacId=<%=pacId%>&tipoServ='+tipo_servicio+'&fDesde='+fDesde+'&fHasta='+fHasta+'&articulo='+articulo+'&cdsFilter='+cdsFilter;
}
</script>
</head>
<body>
<%if(!fp.equals("lista_envio")&& !fp.equals("lista_envio_aseg") ){%>
<table width="100%" height="100%" cellpadding="5" cellspacing="0" align="center">
<%fb = new FormBean("formPrinted",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<tr class="TextRow02">
	<td align="center" class="TableBorder">
		Tipo de Servicio:
		<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_cds_tipo_servicio where compania = " + (String) session.getAttribute("_companyId"), "tipo_servicio", tipoServ, false, false, 0, "text10", "", "", "Tipo de Servicio", "T")%>
		Fecha de Cargo:
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2" />
		<jsp:param name="nameOfTBox1" value="fDesde" />
		<jsp:param name="valueOfTBox1" value="<%=fDesde%>" />
		<jsp:param name="nameOfTBox2" value="fHasta" />
		<jsp:param name="valueOfTBox2" value="<%=fHasta%>" />
		<jsp:param name="fieldClass" value="Text10" />
		<jsp:param name="buttonClass" value="Text10" />
		</jsp:include>
		Art&iacute;culo:
		<%=fb.textBox("articulo",articulo,false,false,false,20)%>
		<%=fb.button("_filtrar","Filtrar",false,false,null,null,"onClick=\"javascript:buscar();\"")%>
		<%=fb.button("close","Cerrar",false,false,null,null,"onClick=\"javascript:window.close();\"")%>
	</td>
</tr>
<tr class="TextRow02">
	<td align="center" class="TableBorder">
	Centro de Servicio:
	<%sbSql = new StringBuffer();
	sbSql.append("select codigo, descripcion from tbl_cds_centro_servicio c where compania_unorg = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and exists ( select null from  ");
	if(cdsDet.trim().equals("S"))
	{
		sbSql.append(" tbl_fac_detalle_transaccion ");
			sbSql.append(" where  pac_id =  ");
			sbSql.append(pacId);
			sbSql.append(" and fac_secuencia = ");
			sbSql.append(noSecuencia);
			sbSql.append(" and centro_servicio = c.codigo and compania = c.compania_unorg ) ");
	}
	else
	{
		sbSql.append(" tbl_fac_transaccion  ");
		sbSql.append(" where  pac_id =  ");
		sbSql.append(pacId);
		sbSql.append(" and admi_secuencia = ");
		sbSql.append(noSecuencia);
		sbSql.append(" and centro_servicio = c.codigo and compania = c.compania_unorg ) ");
	}


	%>
	<%=fb.select(ConMgr.getConnection(),sbSql.toString() , "cdsFilter", cdsFilter, false, false, 0, "text10", "width:300px", "", "Tipo de Servicio", "T")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<div class="dhtmlgoodies_aTab">
<iframe name="cargos_net" id="cargos_net" frameborder="0" align="center" width="100%" height="550" scrolling="no" src="<%=redirectFile%>"></iframe>
</div>
<%}%>
</body>
</html>
<%
}//GET
%>