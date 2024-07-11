<%@ page trimDirectiveWhitespaces="true"%> 
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="page" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="page" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="page" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%@ include file="../../../common/pdf_header.jsp"%>
<%
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTS = new ArrayList();
ArrayList alTST = new ArrayList();
ArrayList alTHAB = new ArrayList();
ArrayList alCDST = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlFilter = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String noSecuencia = request.getParameter("noSecuencia");
String pacId = request.getParameter("pacId");
String tipoTransaccion = request.getParameter("tipoTransaccion");
String fg = request.getParameter("fg");

com.google.gson.Gson gson = new com.google.gson.Gson();
com.google.gson.JsonObject json = new com.google.gson.JsonObject();

json.addProperty("date", System.currentTimeMillis());

if (pacId == null) pacId = "";
if (noSecuencia == null) noSecuencia = "";

if (pacId.trim().equals("")) pacId = request.getParameter("pac_id") == null ? "" : request.getParameter("pac_id");
if (noSecuencia.trim().equals("")) noSecuencia = request.getParameter("no_adm") == null ? "" : request.getParameter("no_adm");

if (pacId.trim().equals("") || noSecuencia.trim().equals("")) {
   response.setContentType("application/json");
   response.setStatus(500);
   json.addProperty("error", true);
   json.addProperty("msg", "Los parámetros 'pacId o pac_id y noSecuencia o no_adm' no están definidos.");
   
   out.print(gson.toJson(json));
   
   ConMgr = null;
   SQLMgr.setConnection(ConMgr);
   
   return;
}

boolean shortFormat = false;
sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(-1,'FAC_SHORT_CARGODEV_FORCED'),'N') as short_format, nvl(get_sec_comp_param(-1,'FAC_SHORT_CARGODEV_PREPRINTED'),'N') as preprinted from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
if (p != null && p.getColValue("short_format") != null) shortFormat = (p.getColValue("short_format").equalsIgnoreCase("S") || p.getColValue("short_format").equalsIgnoreCase("Y"));
if (shortFormat) {

	StringBuffer sbUrl = new StringBuffer();
	sbUrl.append("../facturacion/print_dcargo_dev.jsp?");
	sbUrl.append(request.getQueryString());
	if (p != null && p.getColValue("preprinted") != null && (p.getColValue("preprinted").equalsIgnoreCase("S") || p.getColValue("preprinted").equalsIgnoreCase("Y"))) sbUrl.append("&preprinted");
	response.sendRedirect(sbUrl.toString());
	return;

}

String fechaHoraCreacion = request.getParameter("fechaHoraCreacion");
boolean isCurrTrx = (request.getParameter("printOF") != null && request.getParameter("printOF").equalsIgnoreCase("S"));
String codigo = request.getParameter("codigo");
if (tipoTransaccion == null) tipoTransaccion = "";

String compReplica = "", compFar = "";
try {compFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar");}catch(Exception e){compFar = "";}
try {compReplica = java.util.ResourceBundle.getBundle("farmacia").getString("compReplica");}catch(Exception e){compReplica="";}

String compania = "1"; //(String) session.getAttribute("_companyId");
if(compFar.trim().equals((String) session.getAttribute("_companyId")))compania=compReplica;
String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}
String empresa = request.getParameter("empresa")==null?"":request.getParameter("empresa");
String prioridad = request.getParameter("prioridad")==null?"":request.getParameter("prioridad");
String detallado = request.getParameter("detallado")==null?"N":request.getParameter("detallado");
String tipoServ = request.getParameter("tipoServ");
String fDesde = request.getParameter("fDesde");
String fHasta = request.getParameter("fHasta");
String articulo = request.getParameter("articulo");
String fp = request.getParameter("fp");
String facCodigo = request.getParameter("facCodigo");
String trx = request.getParameter("trx");
String cdsFilter = request.getParameter("cdsFilter");
String citasSopAdm =  "N"; //request.getParameter("citasSopAdm");
String dblPrint = "N";

if (appendFilter == null) appendFilter = "";
if (tipoServ == null) tipoServ = "";
if (fg == null) fg = "";
if (fDesde == null) fDesde = "";
if (fHasta == null) fHasta = "";
if (fHasta == null) fHasta = "";
if (articulo == null) articulo = "";
if (fp == null) fp = "";
if (facCodigo == null) facCodigo = "";
if (trx == null) trx = "";
if (cdsFilter == null) cdsFilter = "";
if (citasSopAdm == null) citasSopAdm = "";

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdoQry = new CommonDataObject();
cdoQry = SQLMgr.getData("select query, nvl(get_sec_comp_param(-1, 'COMPANIA_PLAN_MEDICO'), '1') compania_plan_medico from tbl_gen_query where id = 2 and refer_to = 'COMP'");
Compania _comp = (Compania) sbb.getSingleRowBean(ConMgr.getConnection(),cdoQry.getColValue("query").replace("@@compania", compania),Compania.class);

sbSql = new StringBuffer();
sbSql.append("select p.nombre_paciente as nombre, a.secuencia admision, a.codigo_paciente, to_char(p.f_nac,'dd/mm/yyyy') as fecha_nacimiento, nvl(to_char(p.f_nac,'dd/mm/yyyy'),' ') as f_nac, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'), ' ') as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula as cedula, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as desc_categoria, c.descripcion as area_desc, a.medico, t.descripcion as dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado,p.pac_id, p.residencia_direccion, (case when a.adm_type = 'I' then to_char((coalesce(trunc(a.fecha_egreso),trunc(sysdate))-trunc(a.fecha_ingreso))) else 'N/A' end) as dias_hospitalizado, d.primer_nombre||' '||d.segundo_nombre||' '||d.primer_apellido||' '||d.segundo_apellido||' '||d.apellido_de_casada as nombre_medico, getFacturaAseg(a.secuencia, a.pac_id,");
if (!empresa.trim().equals(""))sbSql.append(empresa);  
else sbSql.append("a.aseguradora");
sbSql.append(",");
if (!prioridad.trim().equals("")){sbSql.append(prioridad);}
else sbSql.append("null");
 sbSql.append(" ) as no_factura, getAseguradora(a.secuencia, a.pac_id,");
 if (!empresa.trim().equals(""))sbSql.append(empresa);  
else sbSql.append("a.aseguradora");
sbSql.append(" ) as aseguradora, getNumPoliza(a.secuencia, a.pac_id, a.aseguradora, e.prioridad) as num_poliza, nvl(e.num_aprobacion, 0) as num_aprobacion, getDiagnostico(a.secuencia, a.pac_id) as diagnostico, nvl(trunc(months_between(sysdate, p.f_nac) / 12), 0) as edad, nvl(get_adm_doblecobertura_msg(a.pac_id,a.secuencia),' ') as doble_msg");
sbSql.append(", nvl((select sum(decode(z.centro_servicio,0,decode(z.tipo_transaccion,'H',coalesce(z.difpaq_cantidad,z.cantidad),-coalesce(z.difpaq_cantidad,z.cantidad))) * (z.monto + nvl(z.recargo,0))) from tbl_fac_detalle_transaccion z where z.compania = a.compania and z.pac_id = a.pac_id and z.fac_secuencia = a.secuencia and (nvl(z.ref_type,'-') <> 'PAQ' or nvl(z.difpaq_cantidad,0) > 0)),0) as honorarios");
sbSql.append(", nvl((select sum(decode(z.centro_servicio,0,0,decode(z.tipo_transaccion,'C',coalesce(z.difpaq_cantidad,z.cantidad),-coalesce(z.difpaq_cantidad,z.cantidad))) * (z.monto + nvl(z.recargo,0))) from tbl_fac_detalle_transaccion z where z.compania = a.compania and z.pac_id = a.pac_id and z.fac_secuencia = a.secuencia and (nvl(z.ref_type,'-') <> 'PAQ' or nvl(z.difpaq_cantidad,0) > 0)),0) + nvl((select z.precio_paq from tbl_adm_clasif_x_plan_conv z where paquete = 'S' and exists (select null from tbl_fac_detalle_transaccion where ref_type = 'PAQ' and pac_id = a.pac_id and fac_secuencia = a.secuencia and compania = a.compania and ref_id = z.cod_reg) and exists (select null from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.secuencia and prioridad = 1 and estado = 'A' and empresa = z.empresa and convenio = z.convenio and plan = z.plan and categoria_admi = z.categoria_admi and tipo_admi = z.tipo_admi and clasif_admi = z.clasif_admi)),0) as cargos");
sbSql.append(", nvl((select sum(monto) from tbl_cja_detalle_pago z where compania = a.compania and admi_secuencia = a.secuencia and exists (select null from tbl_cja_transaccion_pago where compania = z.compania and anio = z.tran_anio and codigo = z.codigo_transaccion and pac_id = a.pac_id and rec_status = 'A' and tipo_cliente = 'P')),0) as pagos_pac");
sbSql.append(", nvl((select sum(monto) from tbl_cja_detalle_pago z where compania = a.compania and exists (select null from tbl_cja_transaccion_pago where compania = z.compania and anio = z.tran_anio and codigo = z.codigo_transaccion and rec_status = 'A' and tipo_cliente = 'E') and exists (select null from tbl_fac_factura where compania = z.compania and codigo = z.fac_codigo and pac_id = a.pac_id and admi_secuencia = a.secuencia)),0) as pagos_emp");
sbSql.append(", nvl(decode(/*(select count(*) from tbl_fac_factura where compania = a.compania and pac_id = a.pac_id and admi_secuencia = a.secuencia)*/0,0,get_sec_comp_param(a.compania,'FAC_SHOW_BALANCE')),'N') as show_balance,nvl((select nombre from tbl_adm_responsable where pac_id=a.pac_id and admision=a.secuencia and estado='A'),' ')responsable,a.adm_type as admType,decode(a.adm_type,'I',getCargosHab(a.compania,a.secuencia,a.pac_id),0) as cargosHab, a.observ_adm as info_importante,p.e_mail ");

if (citasSopAdm.equals("S") || citasSopAdm.equals("Y")){
sbSql.append(" ,(select join( cursor(select sh.descripcion||' ** '||to_char(c.fecha_cita,'DD-MM-YYYY')||'/'||to_char(c.hora_cita,'hh12:mi am')||' ('||NVL (c.observacion, nvl((select (select SUBSTR (nvl(observacion, descripcion), 1, 20) from tbl_cds_procedimiento where codigo = z.procedimiento)  FROM tbl_cdc_cita_procedimiento z WHERE z.cod_cita = c.codigo  and z.fecha_cita = c.fecha_registro  AND codigo = (SELECT min(codigo) FROM tbl_cdc_cita_procedimiento  WHERE  cod_cita = c.codigo  AND fecha_cita = c.fecha_registro)), 'NO DEFINIDO'))||')' from tbl_sal_habitacion sh, tbl_cdc_cita c where sh.compania = ");
sbSql.append(compania);

sbSql.append(" and sh.codigo=c.habitacion AND sh.quirofano =2 and c.estado_cita not in ('C','T') and c.pac_id = "); 
sbSql.append(pacId);
sbSql.append(" and c.admision = ");
sbSql.append(noSecuencia);
sbSql.append(" and xtra1='ASOCIAR' order by c.habitacion, sh.codigo, to_date(to_char(c.fecha_cita,'dd/mm/yyyy'),'dd/mm/yyyy'), to_char(c.hora_cita,'HH24:MI'), to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)),'dd/mm/yyyy'),'dd/mm/yyyy'), to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)),'HH24:MI') ), ' // ') citas_asociadas from dual) citas_asociadas");
}

sbSql.append(" from vw_adm_paciente p, tbl_adm_admision a, tbl_cds_centro_servicio c, tbl_adm_tipo_admision_cia t, tbl_adm_medico d, (select pac_id, admision, min(prioridad) as prioridad, decode(min(prioridad),1, min(num_aprobacion),0) as num_aprobacion from tbl_adm_beneficios_x_admision where estado = 'A' ");

if (!empresa.trim().equals("")){
  sbSql.append(" and empresa = ");
  sbSql.append(empresa);
  sbSql.append(" and prioridad = ");
  sbSql.append(prioridad);
}

sbSql.append(" group by pac_id, admision) e where a.pac_id = p.pac_id and a.compania = ");
sbSql.append(compania);
sbSql.append(" and c.codigo = a.centro_servicio and t.categoria = a.categoria and t.codigo = a.tipo_admision and a.medico = d.codigo and a.secuencia = e.admision(+) and a.pac_id = e.pac_id(+) and a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.secuencia = ");
sbSql.append(noSecuencia);
CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());
if (cdoHeader == null) cdoHeader = new CommonDataObject();

sbSqlFilter.append(" /*FILTERING*/ ");
if(!tipoServ.equals("")){sbSqlFilter.append(" and xx.tipo_cargo = '");sbSqlFilter.append(tipoServ);sbSqlFilter.append("'");}
if(!fDesde.equals("")){sbSqlFilter.append(" and trunc(xx.fecha_cargo) >= to_date('");sbSqlFilter.append(fDesde);sbSqlFilter.append("', 'dd/mm/yyyy')");}
if(!fHasta.equals("")){sbSqlFilter.append(" and trunc(xx.fecha_cargo) <= to_date('");sbSqlFilter.append(fHasta);sbSqlFilter.append("', 'dd/mm/yyyy')");}
if(!articulo.equals("")){sbSqlFilter.append(" and xx.descripcion like '%");sbSqlFilter.append(articulo);sbSqlFilter.append("%'");}
if(!facCodigo.equals("")){sbSqlFilter.append(" and xx.fac_codigo like '%");sbSqlFilter.append(facCodigo);sbSqlFilter.append("%'");}

sbSqlFilter.append(" /*FILTERING*/ ");

sbSql = new StringBuffer();
sbSql.append("select xx.* from ( select ");
if(cdsDet.trim().equals("S"))sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio");
sbSql.append(", case when b.ref_type = 'FAR' and b.tipo_transaccion = 'C' and (select ft.other3 from tbl_fac_trx ft,tbl_int_orden_farmacia f where ft.doc_id= f.doc_id and f.id= b.ref_id and f.pac_id=b.pac_id and f.admision=b.fac_secuencia) is not null then (select ft.other3 from tbl_fac_trx ft,tbl_int_orden_farmacia f where ft.doc_id= f.doc_id and f.id= b.ref_id and f.pac_id=b.pac_id and f.admision=b.fac_secuencia) when b.ref_type = 'FAR' and b.tipo_transaccion = 'D' and (select ft.other3 from tbl_fac_trx ft,tbl_int_dev_farmacia f where ft.doc_id= f.doc_id and f.id= b.ref_id and f.pac_id=b.pac_id and f.admision=b.fac_secuencia) is not null then (select ft.other3 from tbl_fac_trx ft,tbl_int_dev_farmacia f where ft.doc_id= f.doc_id and f.id= b.ref_id and f.pac_id=b.pac_id and f.admision=b.fac_secuencia) else (select get_cds_solicitud_seqtrx_lis(a.pac_id,a.admi_secuencia,a.num_solicitud,");
if(cdsDet.trim().equals("S"))sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio ");
sbSql.append(") from dual)||' '||nvl((select decode(ref_order_no,null,' ',ref_order_no||' ') from interfaz_nexus where fecha_nacimiento = a.admi_fecha_nacimiento and codigo_paciente = a.admi_codigo_paciente and secuencia = a.admi_secuencia and solicitud = a.num_solicitud and centro_servicio = a.centro_servicio and rownum = 1),' ')||nvl(a.no_documento,a.seq_trx) end as fac_codigo, a.med_codigo, a.empre_codigo, b.secuencia, b.tipo_transaccion, b.fecha_cargo, to_char(b.fecha_cargo,'dd/mm/yyyy') as fecha_cargos, to_char(b.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, b.usuario_creacion, coalesce(b.difpaq_cantidad,b.cantidad) as cantidad, (b.monto+nvl(b.recargo,0)) as monto, nvl(b.habitacion,' ') as habitacion, nvl(b.servicio_hab,0) as servicio_hab, nvl(b.cds_producto,0) as cds_producto, nvl(b.cod_uso,0) as cod_uso, nvl(b.centro_costo,0) as centro_costo, nvl(b.costo_art,0) as costo_art, nvl(b.procedimiento,' ') as procedimiento, nvl(b.otros_cargos,0) as otros_cargos, b.tipo_cargo, nvl(b.cod_paq_x_cds,0) as cod_paq_x_cds, nvl(b.recargo,0) as recargo, nvl(b.cod_prod_far,' ') as cod_prod_far, nvl(b.pedido_far,0) as pedido_far, decode(b.tipo_transaccion,'C',nvl(b.descripcion,' '),'D',decode(b.tipo_cargo,get_sec_comp_param("+compania+",'COD_TIPO_SERV_HON'),coalesce((select '['||codigo||'] '||nombre from tbl_adm_empresa where codigo = a.empre_codigo),(select '['||nvl(reg_medico,codigo)||'] '||primer_apellido||' '||segundo_apellido||' '||apellido_de_casada||', '||primer_nombre||' '||segundo_nombre from tbl_adm_medico where codigo = a.med_codigo)),nvl(b.descripcion,' ')),'H',coalesce((select '['||codigo||'] '||nombre from tbl_adm_empresa where codigo = a.empre_codigo),(select '['||nvl(reg_medico,codigo)||'] '||primer_apellido||' '||segundo_apellido||' '||apellido_de_casada||', '||primer_nombre||' '||segundo_nombre from tbl_adm_medico where codigo = a.med_codigo)),nvl(b.descripcion,' ')) as descripcion, coalesce(b.procedimiento,b.habitacion,''||b.cds_producto,''||b.cod_uso,''||b.otros_cargos,''||b.cod_paq_x_cds,decode(b.art_familia||b.art_clase||b.inv_articulo,null,'',b.art_familia||'-'||b.art_clase||'-'||b.inv_articulo),' ') as trabajo, (select descripcion from tbl_cds_centro_servicio where codigo=");
if(cdsDet.trim().equals("S"))sbSql.append(" b.centro_servicio");
else sbSql.append(" a.centro_servicio ");
sbSql.append(") as centro_servicio_desc, decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad)) as cantidad_total, decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad)) * (b.monto + nvl(b.recargo,0)) as monto_total from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.admi_secuencia=");
sbSql.append(noSecuencia);
sbSql.append(" and a.compania=");
sbSql.append(compania);
if(!cdsFilter.equals("")){
if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
else sbSql.append(" and a.centro_servicio = ");
sbSql.append(cdsFilter);
}
if (isCurrTrx) {

	if (trx.trim().equals("")) {

		sbSql.append(" and a.codigo =");
		sbSql.append(codigo);
		sbSql.append(" and a.tipo_transaccion = '");
		sbSql.append(tipoTransaccion);
		sbSql.append("'");

	} else {

		sbSql.append(" and nvl(a.no_documento,a.seq_trx) = '");
		sbSql.append(trx);
		sbSql.append("'");

	}

}
if (fg.trim().equals("FAR")){sbSql.append(" and  b.ref_type in('FARINSUMOS','FAR','ME')");}
else if (!isCurrTrx) sbSql.append(" and (nvl(b.ref_type,'-') <> 'PAQ' or nvl(b.difpaq_cantidad,0) > 0)");
sbSql.append(" and a.codigo=b.fac_codigo and a.pac_id=b.pac_id and a.admi_secuencia=b.fac_secuencia and a.compania=b.compania and a.tipo_transaccion=b.tipo_transaccion ) xx where 1 = 1 ");
sbSql.append(sbSqlFilter.toString());
sbSql.append(" order by 1, 7, 6, 2, 5 ");

al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select ");
if(cdsDet.trim().equals("S"))sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio");
sbSql.append(", b.tipo_cargo, decode(b.centro_servicio,get_sec_comp_param(a.compania,'CDS_HON'),a.med_codigo,null) as med_codigo, a.empre_codigo, b.descripcion, b.monto, nvl(b.recargo,0), b.procedimiento, b.habitacion, b.cds_producto, b.cod_uso, b.otros_cargos, b.cod_paq_x_cds, b.art_familia||'-'||b.art_clase||'-'||b.inv_articulo, coalesce(b.procedimiento,b.habitacion,''||b.cds_producto,''||b.cod_uso,''||b.otros_cargos,''||b.cod_paq_x_cds,decode(b.art_familia||b.art_clase||b.inv_articulo,null,'',b.art_familia||'-'||b.art_clase||'-'||b.inv_articulo),' ') as trabajo, /*sum*/(decode(b.tipo_transaccion,'D',-(b.cantidad - nvl(b.difpaq_cantidad,0)),(b.cantidad - nvl(b.difpaq_cantidad,0)))) as cantidad, (select descripcion from tbl_cds_centro_servicio where codigo = ");
if(cdsDet.trim().equals("S"))sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio");
sbSql.append(") as cds, b.ref_id, nvl((select nombre||' - '||id from tbl_fac_cotizacion where id = b.ref_id),' ') as paq_name, nvl((select z.precio_paq from tbl_adm_clasif_x_plan_conv z where paquete = 'S' and z.cod_reg = b.ref_id and exists (select null from tbl_adm_beneficios_x_admision where pac_id = b.pac_id and admision = b.fac_secuencia and prioridad = 1 and estado = 'A' and empresa = z.empresa and convenio = z.convenio and plan = z.plan and categoria_admi = z.categoria_admi and tipo_admi = z.tipo_admi and clasif_admi = z.clasif_admi)),0) as paq_price");
sbSql.append(", b.fecha_cargo, to_char(b.fecha_cargo,'dd/mm/yyyy') as fecha_cargos, to_char(b.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, b.usuario_creacion, nvl(a.no_documento,a.seq_trx) as fac_codigo");//21
sbSql.append(" from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where b.ref_type = 'PAQ' and b.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and b.fac_secuencia = ");
sbSql.append(noSecuencia);
sbSql.append(" and b.compania = ");
sbSql.append(compania);
if(!cdsFilter.equals("")){
if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
else sbSql.append(" and a.centro_servicio = ");
sbSql.append(cdsFilter);
}
sbSql.append(" and a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.compania = b.compania and a.tipo_transaccion = b.tipo_transaccion");
/*sbSql.append(" group by ");
if(cdsDet.trim().equals("S"))sbSql.append("b.centro_servicio");
else sbSql.append("a.centro_servicio");
sbSql.append(", b.tipo_cargo, decode(b.centro_servicio,get_sec_comp_param(a.compania,'CDS_HON'),a.med_codigo,null), a.empre_codigo, b.descripcion, b.monto, nvl(b.recargo,0), b.procedimiento, b.habitacion, b.cds_producto, b.cod_uso, b.otros_cargos, b.cod_paq_x_cds, b.art_familia, b.art_clase, b.inv_articulo, b.ref_id, b.pac_id, b.fac_secuencia having sum(decode(b.tipo_transaccion,'D',-(b.cantidad - nvl(b.difpaq_cantidad,0)),(b.cantidad - nvl(b.difpaq_cantidad,0)))) <> 0");*/
sbSql.append(" order by 18,1,21,25");//ref_id, centro_servicio, fecha_cargo, seq_trx
ArrayList alPaq = new ArrayList();
if (!isCurrTrx) alPaq = SQLMgr.getDataList(sbSql.toString());

sbSqlFilter = new StringBuffer();
sbSqlFilter.append(" /*FILTERING RES*/ ");
if(!tipoServ.equals("")){sbSqlFilter.append(" and b.tipo_cargo = '");sbSqlFilter.append(tipoServ);sbSqlFilter.append("'");}
if(!fDesde.equals("")){sbSqlFilter.append(" and trunc(b.fecha_cargo) >= to_date('");sbSqlFilter.append(fDesde);sbSqlFilter.append("', 'dd/mm/yyyy')");}
if(!fHasta.equals("")){sbSqlFilter.append(" and trunc(b.fecha_cargo) <= to_date('");sbSqlFilter.append(fHasta);sbSqlFilter.append("', 'dd/mm/yyyy')");}
if(!articulo.equals("")){sbSqlFilter.append(" and b.descripcion like '%");sbSqlFilter.append(articulo);sbSqlFilter.append("%'");}
if(!facCodigo.equals("")){sbSqlFilter.append(" and nvl((select decode(ref_order_no,null,' ',ref_order_no||' ') from interfaz_nexus where fecha_nacimiento = a.admi_fecha_nacimiento and codigo_paciente = a.admi_codigo_paciente and secuencia = a.admi_secuencia and solicitud = a.codigo and detalle_solicitud = b.secuencia and centro_servicio = a.centro_servicio),' ')||nvl(a.no_documento,a.seq_trx) like '%");sbSqlFilter.append(facCodigo);sbSqlFilter.append("%'");}

sbSqlFilter.append(" /*FILTERING RES*/ ");

sbSql = new StringBuffer();
sbSql.append("select ");
if(cdsDet.trim().equals("S"))sbSql.append(" b.centro_servicio, ");
else sbSql.append(" a.centro_servicio, ");
sbSql.append(" b.tipo_cargo, sum(decode(b.tipo_transaccion,'C',b.cantidad*(b.monto+nvl(b.recargo,0)),'D',-1*b.cantidad*(b.monto+nvl(b.recargo,0)),'H',b.cantidad *(b.monto+nvl(b.recargo,0)))) as monto, (select descripcion from tbl_cds_tipo_servicio where codigo=b.tipo_cargo) as descripcion from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.admi_secuencia=");
sbSql.append(noSecuencia);
sbSql.append(sbSqlFilter.toString());
if(!cdsFilter.equals("")){
if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
else sbSql.append(" and a.centro_servicio = ");
sbSql.append(cdsFilter);
}
if (isCurrTrx) {

	if (trx.trim().equals("")) {

		sbSql.append(" and a.codigo =");
		sbSql.append(codigo);
		sbSql.append(" and a.tipo_transaccion = '");
		sbSql.append(tipoTransaccion);
		sbSql.append("'");

	} else {

		sbSql.append(" and nvl(a.no_documento,a.seq_trx) = '");
		sbSql.append(trx);
		sbSql.append("'");

	}

}
if (fg.trim().equals("FAR")){sbSql.append(" and  b.ref_type in('FAR','ME')");}
sbSql.append(" and a.codigo=b.fac_codigo and a.pac_id=b.pac_id and a.admi_secuencia=b.fac_secuencia and a.tipo_transaccion=b.tipo_transaccion and nvl(b.ref_type,'-') <> 'PAQ' group by ");
if(cdsDet.trim().equals("S"))sbSql.append(" b.centro_servicio, ");
else sbSql.append(" a.centro_servicio, ");
sbSql.append(" b.tipo_cargo order by 1,4");
alTS = SQLMgr.getDataList(sbSql.toString());

if (isCurrTrx) {

	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(-1,'FAC_CHARGE_DEV_DBL_PRINT'),'N') as dblprint from dual");
	CommonDataObject cdoParam = SQLMgr.getData(sbSql.toString());
	if (cdoParam != null) dblPrint = cdoParam.getColValue("dblprint");

} else {

	sbSql = new StringBuffer();
	sbSql.append("select ");
	if (cdsDet.equalsIgnoreCase("S")) sbSql.append("b.centro_servicio");
	else sbSql.append("a.centro_servicio");
	sbSql.append(", sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad)) *(b.monto + nvl(b.recargo,0))) as monto, (select descripcion from tbl_cds_centro_servicio where codigo = ");
	if (cdsDet.equalsIgnoreCase("S")) sbSql.append("b.centro_servicio");
	else sbSql.append("a.centro_servicio");
	sbSql.append(") as descripcion from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.admi_secuencia = ");
	sbSql.append(noSecuencia);
	sbSql.append(sbSqlFilter.toString());
	if(!cdsFilter.equals("")){
	if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
	else sbSql.append(" and a.centro_servicio = ");
	sbSql.append(cdsFilter);
	}
	if (fg.equalsIgnoreCase("FAR")) sbSql.append(" and b.ref_type in ('FAR','ME')");
	sbSql.append(" and a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.tipo_transaccion = b.tipo_transaccion and (nvl(b.ref_type,'-') <> 'PAQ' or nvl(b.difpaq_cantidad,0) > 0) group by ");
	if (cdsDet.equalsIgnoreCase("S")) sbSql.append("b.centro_servicio");
	else sbSql.append("a.centro_servicio");
	sbSql.append(" order by 1,3");
	alCDST = SQLMgr.getDataList(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select b.tipo_cargo, sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad)) * (b.monto + nvl(b.recargo,0))) as monto, (select descripcion from tbl_cds_tipo_servicio where codigo = b.tipo_cargo) as descripcion from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.admi_secuencia = ");
	sbSql.append(noSecuencia);
	sbSql.append(sbSqlFilter.toString());
	if(!cdsFilter.equals("")){
	if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
	else sbSql.append(" and a.centro_servicio = ");
	sbSql.append(cdsFilter);
	}
	if (fg.equalsIgnoreCase("FAR")) sbSql.append(" and b.ref_type in ('FAR','ME')");
	sbSql.append(" and a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.tipo_transaccion = b.tipo_transaccion and (nvl(b.ref_type,'-') <> 'PAQ' or nvl(b.difpaq_cantidad,0) > 0) group by b.tipo_cargo order by 1,3");
	alTST = SQLMgr.getDataList(sbSql.toString());
    
    sbSql = new StringBuffer();
	sbSql.append("select b.descripcion, sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad)) *(b.monto + nvl(b.recargo,0))) as monto, sum(decode(b.tipo_transaccion,'D',-coalesce(b.difpaq_cantidad,b.cantidad),coalesce(b.difpaq_cantidad,b.cantidad))) as cantidad_total from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.admi_secuencia = ");
	sbSql.append(noSecuencia);
	sbSql.append(sbSqlFilter.toString());
	if(!cdsFilter.equals("")){
	if(cdsDet.trim().equals("S"))sbSql.append(" and b.centro_servicio = ");
	else sbSql.append(" and a.centro_servicio = ");
	sbSql.append(cdsFilter);
	}
	if (fg.equalsIgnoreCase("FAR")) sbSql.append(" and b.ref_type in ('FAR','ME')");
	sbSql.append(" and a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.tipo_transaccion = b.tipo_transaccion and b.tipo_cargo = '01' and (nvl(b.ref_type,'-') <> 'PAQ' or nvl(b.difpaq_cantidad,0) > 0) group by b.descripcion order by 1,2");
	alTHAB = SQLMgr.getDataList(sbSql.toString());

}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+System.currentTimeMillis()+".pdf";

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

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = request.getContextPath()+"/pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

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
	String subtitle = (request.getParameter("cp") == null)?"":">    >    >    C  O  P  I  A    <    <    <";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float ctblHeight = 0.0f;//current table height
	//float stblHeight = ((height - (topMargin + bottomMargin)) / 2);//subtable height
	float stblHeight = ((height - (2 * (topMargin + bottomMargin))) / 2);//subtable height

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".037");
		dHeader.addElement(".04");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".13");
		dHeader.addElement(".153");
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
		dRes.addElement(".20");
		dRes.addElement(".20");
		dRes.addElement(".20");
		dRes.addElement(".20");
		dRes.addElement(".20");
        
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

	String mTbl = "main";
	//table header
	if (isCurrTrx && !dblPrint.equalsIgnoreCase("N")) {
	
		mTbl = "trx";
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

	}

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable(mTbl);
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "3rd party sys", fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		pc.addBorderCols("Nombre:",0,2,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoHeader.getColValue("nombre"),0,5,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Cod. Paciente:",0,1,0.0f,0.5f,0.0f,0.0f);
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
		
		if(cdoHeader.getColValue("admType"," ").trim().equals("I")){
		pc.addCols("Total Habitaciones Cargadas:",0,3);
		pc.addCols(cdoHeader.getColValue("cargosHab"),0,4);
		pc.addCols(" ",0,1);
		pc.addCols(" ",0,4);}
		
		pc.addCols("Médico:",0,2);
		pc.addCols(cdoHeader.getColValue("nombre_medico"),0,5);
		pc.addCols("Area Admite:",0,1);
		pc.addCols(cdoHeader.getColValue("area_desc"),0,4);
        
        pc.addCols("Inf. Importante:",0,2);
		pc.addCols(cdoHeader.getColValue("info_importante"),0,5);
		pc.addCols("Correo:",0,1);
		pc.addCols(cdoHeader.getColValue("e_mail"),0,4);
        
        if (citasSopAdm.equals("S") || citasSopAdm.equals("Y")){
        pc.addCols("Citas Asociadas:",0,2);
		pc.addCols(cdoHeader.getColValue("citas_asociadas",""),0,10);
        }
        pc.addCols(" ",0,12);
        

	if (!isCurrTrx && cdoHeader.getColValue("show_balance"," ").equalsIgnoreCase("S")) {

		pc.setNoColumnFixWidth(dRes);
		pc.createTable("res",false,0,0.0f,resSize);
			pc.addCols(". : :     C U E N T A     P E N D I E N T E     : : .",1,dRes.size());

			pc.addBorderCols("CARGOS",1,1);
			pc.addBorderCols("HONORARIOS",1,1);
			pc.addBorderCols("PAGOS PACIENTE",1,1);
			pc.addBorderCols("PAGOS EMPRESA",1,1);
			pc.addBorderCols("SALDO",1,1);

			double saldo = 0.0;
			saldo += Double.parseDouble(cdoHeader.getColValue("cargos"));
			saldo += Double.parseDouble(cdoHeader.getColValue("honorarios"));
			saldo -= Double.parseDouble(cdoHeader.getColValue("pagos_pac")) + Double.parseDouble(cdoHeader.getColValue("pagos_emp"));
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("cargos")),2,1);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("honorarios")),2,1);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("pagos_pac")),2,1);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("pagos_emp")),2,1);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo),2,1);

		pc.useTable(mTbl);
		pc.addCols(" ",0,2);
		pc.addTableToCols("res",1,dHeader.size() - 4);
		pc.addCols(" ",0,2);

	}

		pc.setFont(headerFontSize,1);
		pc.addCols("Responsable:",0,2);
		pc.addCols(""+cdoHeader.getColValue("responsable"),0,4);
		pc.setFont(headerFontSize,1,Color.blue);
		pc.addCols(cdoHeader.getColValue("doble_msg"),1,6);

		pc.setFont(headerFontSize,1);
		pc.addBorderCols("Trn./Cargo",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("F. Trx.",1);
		pc.addBorderCols("Tipo",1);
		pc.addBorderCols("Serv.",1);
		pc.addBorderCols("Usuario",1);
		pc.addBorderCols("Código",1);
		pc.addBorderCols("Descripción del Cargo",1,2);
		pc.addBorderCols("Cant.",1);
		pc.addBorderCols("Precio",1);
		pc.addBorderCols("Total",1);
	//pc.setTableHeader(11 + ((!isCurrTrx && cdoHeader.getColValue("show_balance").equalsIgnoreCase("S"))?1:0));//create de table header
		if (isCurrTrx){if(cdoHeader.getColValue("admType").trim().equals("I"))pc.setTableHeader(12);else pc.setTableHeader(11);}

		double total = 0.00;
	  String groupBy = "";
	if (!isCurrTrx) {

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable("paquete",false,0,leftRightMargin * 2);
			pc.setFont(groupFontSize,1);
			pc.addBorderCols(". : :   P A Q U E T E   : : .",1,dHeader.size());

		for (int i=0; i<alPaq.size(); i++) {
		  CommonDataObject cdo = (CommonDataObject) alPaq.get(i);

			if (!groupBy.equalsIgnoreCase(cdo.getColValue("ref_id"))) {

				pc.setFont(groupFontSize,1);
				pc.addCols(cdo.getColValue("paq_name"),0,dHeader.size() - 1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("paq_price","0")),2,1);
				total += Double.parseDouble(cdo.getColValue("paq_price","0"));

			}

			pc.setFont(contentFontSize,0);
			//pc.addCols(cdo.getColValue("fac_codigo"),2,1);
			pc.addCols(cdo.getColValue("cds"),0,4);
			pc.addCols(cdo.getColValue("tipo_cargo"),1,1);
			pc.addCols(" ",0,1);
			pc.addCols(cdo.getColValue("trabajo"),0,1);
			pc.addCols(cdo.getColValue("descripcion"),0,2);
			pc.addCols(cdo.getColValue("cantidad"),2,1);
			pc.addCols(" ",2,1);
			pc.addCols(" ",2,1);
			groupBy = cdo.getColValue("ref_id");
    }

		pc.useTable(mTbl);
		if (alPaq.size() > 0) {
			pc.addTableToCols("paquete",1,dHeader.size(),0.0f,null,null,0.5f,0.5f,0.5f,0.5f);
			pc.addCols(" ",1,dHeader.size());
		}
	}

	//table body
	groupBy = "";
	String groupTitle = "";
	double cdsTotal = 0.00;
	int cdsQtyTotal = 0;
	int qtyTotal = 0,xtraCol =0;
	boolean delPacDet = true;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!isCurrTrx && !groupBy.equalsIgnoreCase(cdo.getColValue("centro_servicio")) && detallado.equals("N") )
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
				pc.useTable(mTbl);
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
					xtraCol =0;					
					if(!isCurrTrx && cdoHeader.getColValue("show_balance").equalsIgnoreCase("S"))xtraCol = xtraCol+1;
					if(cdoHeader.getColValue("admType").trim().equals("I"))xtraCol = xtraCol+1;
								
					pc.deleteRows(2,8 +xtraCol);//delete patient details for next pages, leave only patient name
					delPacDet = false;
				}
				pc.setTableHeader(4);//reset header size and cds
			}
			pc.setFont(groupFontSize,1);
			pc.addBorderCols(cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("centro_servicio")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
			
			xtraCol =0;					
			if(!isCurrTrx && cdoHeader.getColValue("show_balance").equalsIgnoreCase("S"))xtraCol = xtraCol+1;
			if(cdoHeader.getColValue("admType").trim().equals("I"))xtraCol = xtraCol+1;
			
			if (i == 0) pc.setTableHeader(12 +xtraCol );//set first header with cds
		}//diff cds

	if (isCurrTrx && !dblPrint.equalsIgnoreCase("N")) {

		pc.useTable("trx");
		ctblHeight = pc.getTableHeight();

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable("tmp");

	}

		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("fac_codigo"),2,1);
		pc.addCols(cdo.getColValue("fecha_cargos"),1,1);
		pc.addCols(cdo.getColValue("fecha_creacion"),1,1);
		pc.addCols(cdo.getColValue("tipo_transaccion"),1,1);
		pc.addCols(cdo.getColValue("tipo_cargo"),1,1);
		pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
		pc.addCols(cdo.getColValue("trabajo"),0,1);
		pc.addCols(cdo.getColValue("descripcion"),0,2);
		pc.addCols(cdo.getColValue("cantidad_total"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total")),2,1);

		if (isCurrTrx && !dblPrint.equalsIgnoreCase("N")) {

			if ((ctblHeight + pc.getTableHeight() + groupFontSize + 4) < stblHeight) {//trx + tmp + last total line < half of available height

				pc.useTable("trx");
					pc.addTableToCols("tmp",1,dHeader.size());

			} else {

				pc.useTable("main");
					pc.addTableToCols("trx",1,dHeader.size(),stblHeight);
					pc.setFont(bottomMargin - 4,0);
					//pc.addCols(" ",1,dHeader.size(),bottomMargin,null,0.1f,0.0f,0.0f,0.0f,null);
					pc.addCols(" ",1,dHeader.size(),bottomMargin);
					pc.setFont(topMargin - 4,0);
					pc.addCols(" ",1,dHeader.size(),topMargin);
					pc.setFont(contentFontSize,0);
					pc.addTableToCols("trx",1,dHeader.size(),stblHeight);
				pc.flushTableBody(true);
				
				pc.useTable("trx");
				pc.flushTableBody();
					pc.addTableToCols("tmp",1,dHeader.size());

			}

		} else {

			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		}
		
		groupBy = cdo.getColValue("centro_servicio");
		groupTitle = cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("centro_servicio")+" ]";
		cdsTotal += Double.parseDouble(cdo.getColValue("monto_total"));
		cdsQtyTotal += Integer.parseInt(cdo.getColValue("cantidad_total"));
		total += Double.parseDouble(cdo.getColValue("monto_total"));
		qtyTotal += Integer.parseInt(cdo.getColValue("cantidad_total"));
	}

	if (al.size() == 0 && alPaq.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {

		if (isCurrTrx) {

			pc.setFont(groupFontSize,1);
			pc.addCols("TOTAL DE CARGOS:",2,dHeader.size() - 2);
			pc.addCols(CmnMgr.getFormattedDecimal(total),2,2);

		} else {
			
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
				pc.useTable(mTbl);
				pc.addCols(" ",0,1);
				pc.addTableToCols("ts",1,10);
				pc.addCols(" ",0,1);

				//pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
			}

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

			pc.useTable(mTbl);
			pc.flushTableBody(true);
			//delete previous cds
			pc.deleteRows(-1);
			//set current cds as header
			pc.addCols(" ",1,dHeader.size());

			pc.addTableToCols("resumen",1,dHeader.size(),0.0f,null,null,0.5f,0.5f,0.5f,0.5f);

			pc.addCols("Nota: 'Sr. paciente, este SALDO es al momento de su facturación, En caso de CARGOS ADICIONALES a esta fecha, le será notificado oportunamente'", 0,dHeader.size());

		}//is not current transaction

	}
	
	if (isCurrTrx && !dblPrint.equalsIgnoreCase("N")) {

		pc.useTable("main");
			pc.addTableToCols("trx",1,dHeader.size(),stblHeight);
			pc.setFont(bottomMargin - 4,0);
			//pc.addCols(" ",1,dHeader.size(),bottomMargin,null,0.1f,0.0f,0.0f,0.0f,null);
			pc.addCols(" ",1,dHeader.size(),bottomMargin);
			pc.setFont(topMargin - 4,0);
			pc.addCols(" ",1,dHeader.size(),topMargin);
			pc.setFont(contentFontSize,0);
			pc.addTableToCols("trx",1,dHeader.size(),stblHeight);

	}
	
	pc.flushTableBody(true);
	pc.close();
	
	if (isCurrTrx) response.sendRedirect(redirectFile);
	else {
	
    if (al.size() == 0 && alPaq.size() == 0) {
    
         response.setContentType("application/json");
         response.setStatus(500);
         json.addProperty("error", true);
         json.addProperty("msg", "No existen registros para paciente: "+pacId+"-"+noSecuencia);
         
         out.print(gson.toJson(json));
         
         ConMgr = null;
         SQLMgr.setConnection(ConMgr);
         
         return;
    }

    java.io.File file = new java.io.File(directory+folderName+"/"+year+"/"+month+"/"+fileName);
    
    int length = (int) file.length();
    java.io.BufferedInputStream reader = new java.io.BufferedInputStream(new java.io.FileInputStream(file));
    byte[] bytes = new byte[length];
    reader.read(bytes, 0, length);
    reader.close();
    
    String  base64EncodedData = org.apache.commons.codec.binary.Base64.encodeBase64String(bytes);
   
    response.setContentType("application/json");
    
	  json.addProperty("error", false);
	  json.addProperty("pid_adm", pacId+"-"+noSecuencia);
	  json.addProperty("patient_name", cdoHeader.getColValue("nombre"," "));
	  json.addProperty("patient_dob", cdoHeader.getColValue("f_nac"," "));
	  json.addProperty("patient_sex", cdoHeader.getColValue("sexo"," "));
	  json.addProperty("using", "Apache Commons Codec Binary Base64");
	  json.addProperty("pdf_base64_str", base64EncodedData);
	  
	  /* Test decode base64 string to pdf stream
	  final java.io.File dwldsPath = new java.io.File(directory+folderName+"/"+year+"/"+month+"/test-"+System.currentTimeMillis()+".pdf");
    byte[] pdfAsBytes = org.apache.commons.codec.binary.Base64.decodeBase64(base64EncodedData);
    java.io.FileOutputStream os;
    os = new java.io.FileOutputStream(dwldsPath, false);
    os.write(pdfAsBytes);
    os.flush();
    os.close();
    */
       
    out.print(gson.toJson(json));
   
    ConMgr = null;
    SQLMgr.setConnection(ConMgr);
	}//is not current trx
}//GET
%>