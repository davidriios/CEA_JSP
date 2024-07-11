<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();

String userName = UserDet.getUserName();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbSql2 = new StringBuffer();

String refId = request.getParameter("refId");
String compId = (String) session.getAttribute("_companyId");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String referTo = request.getParameter("referTo");
String refType = request.getParameter("refType");
String pacId = request.getParameter("pacId");
String admision = request.getParameter("adm");
String fg = request.getParameter("fg");
String saldo_inicial = "0";
if(fg==null)fg="";
if(admision==null)admision="";

CommonDataObject cdoQry = new CommonDataObject();
cdoQry = SQLMgr.getData("select query, getsaldoinicialec("+(String) session.getAttribute("_companyId")+", "+refType+", '"+refId+"', '"+fDate+"') saldo_inicial, nvl(get_sec_comp_param(-1, 'ESTADO_CTA_CXC_NUEVO_FORMATO'), 'N') ESTADO_CTA_CXC_NUEVO_FORMATO , nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'FAC_ESTADO_CTA_VER_MOROSIDAD'), 'N') verMorosidad from tbl_gen_query where id = 0 and refer_to = '"+referTo+"'");
saldo_inicial = cdoQry.getColValue("saldo_inicial");
System.out.println("query......=\n"+cdoQry.getColValue("query"));

sbSql = new StringBuffer();
sbSql.append("select a.compania, a.codigo, a.refer_to, a.nombre, to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento, a.ruc, a.dv, decode(a.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = a.codigo), a.codigo) num_empleado ");
if(fg.trim().equals("PAC")||referTo.trim().equals("PAC"))sbSql.append(",direccion,telefono,responsable ");
sbSql.append(" from (");
	sbSql.append(cdoQry.getColValue("query").replace("@@compania", (String) session.getAttribute("_companyId")));
sbSql.append(") a where nvl(compania,");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(") = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.codigo = '");
sbSql.append(refId);
sbSql.append("' order by nombre ");
CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());


sbSql = new StringBuffer();
sbSql.append("select z.doc, z.cod_factura, z.doc_type, z.documento, to_char(fecha,'dd/mm/yyyy') fecha, z.descripcion, z.admision, nvl(z.facturado, 0) facturado, nvl(z.pago_app_fact, 0) pago_app_fact, nvl(z.debito, 0) debito, nvl(z.credito, 0) credito, nvl(z.saldo, 0) saldo, z.f_factura from (");

	sbSql.append("select 'A' doc, null cod_factura, 0 doc_type, 0 admi_secuencia, null documento, null fecha, null descripcion, null admision, 0 facturado, 0 pago_app_fact, 0 debito, 0 credito, getsaldoinicialec(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(", ");
	sbSql.append(refType);
	sbSql.append(", '");
	sbSql.append(refId);
	sbSql.append("', '");
	sbSql.append(fDate);
	sbSql.append("') saldo, null as anio, null as f_factura, null is_fact, null as fact_anio, null as fact_no, null as doc_date from dual");

	sbSql.append(" union all ");

	sbSql.append("select 'O' doc, f.codigo cod_factura, 1 doc_type, f.admi_secuencia, f.codigo documento, f.fecha, 'FACTURA' || decode(admi_secuencia,0,' S/I') || (case when f.facturar_a = 'E' then ' '||(select nombre_paciente from vw_adm_paciente where pac_id=f.pac_id) || ' [ ' || f.pac_id ||'-' || f.admi_secuencia || ' ]' else decode(f.cod_otro_cliente,'");
	sbSql.append(refId.toUpperCase());
	sbSql.append("','',' - '||nvl(f.nombre_cliente,(select nombre_paciente from vw_adm_paciente where pac_id=f.pac_id))) end)  as  descripcion, f.admi_secuencia admision, f.grang_total facturado, 0 pago_app_fact, 0 debito, 0 credito, 0 saldo, f.f_anio as anio, f.fecha as f_factura, 1 as is_fact, f.f_anio as fact_anio, f.numero_factura as fact_no, f.fecha as doc_date from tbl_fac_factura f  where ((f.cod_otro_cliente = '");
	sbSql.append(refId);
	sbSql.append("' and f.cliente_otros=");
	sbSql.append(refType);
	sbSql.append(") or  exists ( select null from tbl_adm_responsable r where r.estado ='A' and r.ref_id='");
	sbSql.append(refId.toUpperCase());
	sbSql.append("' and r.ref_type=");
	sbSql.append(refType);
	sbSql.append(" and r.pac_id=f.pac_id and r.admision=f.admi_secuencia and f.facturar_a='P' )) ");
	sbSql.append(" and f.fecha >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and f.fecha <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy')  and f.estatus <> 'A'  and f.compania = ");
	sbSql.append(compId);
    if(!admision.trim().equals("")){sbSql.append(" and f.admi_secuencia="); sbSql.append(admision); }
	//if(referTo.trim().equals("PAC")) sbSql.append("  and f.facturar_a = 'P'");
	sbSql.append(" union all ");

	sbSql.append("select 'O' doc, f.codigo cod_factura, 2 doc_type, f.admi_secuencia, pa.codigo documento,  pa.fecha, 'PAGO' descripcion, 0 admision, 0 facturado, pa.monto pago_app_fact, 0 debito, 0 credito, 0 saldo, pa.anio, f.fecha as f_factura, 0 as is_fact, f.f_anio as fact_anio, f.numero_factura as fact_no, pa.fecha as doc_date from tbl_fac_factura f, (select a.ref_id, a.ref_type, a.recibo codigo, a.fecha, b.fac_codigo, sum(b.monto) monto, b.admi_secuencia, a.compania ctp_compania, a.anio from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.fecha >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and a.fecha <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') and b.cod_rem is null and (a.anio = b.tran_anio(+) and a.compania = b.compania(+) and a.codigo = b.codigo_transaccion(+)) and a.rec_status <> 'I' group by  a.ref_id,a.ref_type,a.recibo, a.fecha, b.fac_codigo, b.admi_secuencia, a.compania, a.anio) pa where (f.cod_otro_cliente = '");
	sbSql.append(refId);
	sbSql.append("' and f.compania = ");
	sbSql.append(compId);
	sbSql.append("  and f.cliente_otros='");
	sbSql.append(refType);
	sbSql.append("' or  exists ( select null from tbl_adm_responsable r where r.estado ='A' and r.ref_id='");
	sbSql.append(refId.toUpperCase());
	sbSql.append("' and r.ref_type=");
	sbSql.append(refType);
	if(!admision.trim().equals("")){sbSql.append(" and f.admi_secuencia="); sbSql.append(admision); }
	sbSql.append(" and r.pac_id=f.pac_id and r.admision=f.admi_secuencia and f.facturar_a='P' )) and f.estatus <> 'A' /* and f.cod_otro_cliente = pa.ref_id and f.cliente_otros = pa.ref_type*/ and f.compania = pa.ctp_compania and f.codigo = pa.fac_codigo ");

	sbSql.append(" union all ");

	sbSql.append("select 'O' doc, pa.referencia cod_factura, 4 doc_type, null admi_secuencia, pa.trans_anio||' - '||pa.trans_id||' ( '||pa.id||' )' as documento,pa.fecha_doc as fecha,'DETALLE COMP. AUX.' descripcion, 0 admision, 0 facturado, 0 pago_app_fact, nvl(sum(decode(pa.lado, 'DB',pa.monto,0)),0) debito, nvl(sum(decode(pa.lado, 'CR',pa.monto,0)),0) credito, 0 saldo, to_number(to_char(pa.fecha_doc,'yyyy')) as anio, (select fecha from tbl_fac_factura where codigo = pa.referencia and compania = pa.compania) as f_factura, 0 as is_fact, (select f_anio from tbl_fac_factura where codigo = pa.referencia and compania = pa.compania) as fact_anio, (select numero_factura from tbl_fac_factura where codigo = pa.referencia and compania = pa.compania) as fact_no, pa.fecha_doc as doc_date from tbl_con_registros_auxiliar pa where  pa.estado = 'A' and exists (select null from tbl_con_encab_comprob z where z.consecutivo = pa.trans_id and z.ea_ano = pa.trans_anio and z.compania =pa.compania and z.status = 'AP' and z.estado = 'A') and pa.fecha_doc >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and pa.fecha_doc <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') and pa.ref_type=1 and pa.ref_id = '");
	sbSql.append(refId);
	sbSql.append("' and pa.compania = ");
	sbSql.append(compId);
	sbSql.append("  and pa.subref_type='");
	sbSql.append(refType);
	sbSql.append("' group by pa.ref_id, pa.subref_type,pa.trans_anio||' - '||pa.trans_id||' ( '||pa.id||' )', pa.fecha_doc, pa.referencia, pa.compania");

	sbSql.append(" union all ");

	sbSql.append("select 'O' doc, f.codigo cod_factura, 3 doc_type, f.admi_secuencia, to_char(ca.referencia) documento, ca.fecha_creacion fecha, /*decode(ca.recibo,null,decode(ca.explicacion,null,'NO TIENE DESCRIPCION',ca.explicacion),ca.explicacion||'-Rec.#'||ca.recibo)*/ 'AJUSTE' descripcion, 0 admision, 0 facturado, 0 pago_app_fact, ca.ajuste_debito debito, ca.ajuste_credito credito, 0 saldo, to_number(to_char(ca.fecha_creacion,'yyyy')) as anio, f.fecha as f_fecha, 0 as is_fact, f.f_anio as fact_anio, f.numero_factura as fact_no, ca.fecha_creacion as doc_date from tbl_fac_factura f, (select  fecha_aprob_idx as fecha_creacion, factura, recibo,nota_ajuste referencia, explicacion, compania cia_enc, sum(decode (lado_mov, 'D', monto,0)) ajuste_debito, sum(decode(lado_mov, 'C', monto,0)) ajuste_credito,ref_id,ref_type from vw_con_adjustment_gral where tipo_ajuste not in (select xx.codigo from tbl_fac_tipo_ajuste xx where xx.compania = compania and xx.group_type in ('E')) and trunc(fecha_aprob_idx) >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and trunc(fecha_aprob_idx) <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') group by ref_id,ref_type, fecha_aprob_idx, factura, recibo, nota_ajuste, explicacion, compania  union all select  doc_date, (select other3 from tbl_fac_trx t where ft.reference_id = t.doc_id), null ,doc_id referencia, observations, company_id cia_enc, sum(decode (doc_type, 'NDB', net_amount,0)) ajuste_debito, sum(decode(doc_type, 'NCR', net_amount,0)) ajuste_credito,client_id,client_ref_id from tbl_fac_trx ft where  doc_type in ('NDB', 'NCR') and status = 'O' and trunc(doc_date) >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and trunc(doc_date) <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') group by client_id,client_ref_id, doc_date,reference_id,doc_id,observations,company_id order by 1 ) ca where ((f.cod_otro_cliente = '");
	sbSql.append(refId);
	sbSql.append("'  and f.cliente_otros='");
	sbSql.append(refType);
	sbSql.append("') or  exists ( select null from tbl_adm_responsable r where r.estado ='A' and r.ref_id='");
	sbSql.append(refId.toUpperCase());
	sbSql.append("' and r.ref_type=");
	sbSql.append(refType);
	sbSql.append(" and r.pac_id=f.pac_id and r.admision=f.admi_secuencia and f.facturar_a='P' )) and f.compania = ");
	sbSql.append(compId);
	if(!admision.trim().equals("")){sbSql.append(" and f.admi_secuencia="); sbSql.append(admision); }
	sbSql.append("  and f.estatus <> 'A' and f.compania = ca.cia_enc and f.codigo = ca.factura");

	/*
	sbSql.append(" union all ");

	sbSql.append("select 'R' doc, '0' cod_factura, 4 doc_type, 999999 admi_secuencia, to_char(a.codigo) documento, a.fecha_creacion fecha, decode(a.documento, 'F', 'REMANENTE DE FACTURA '||a.numero_factura,'R','PAGO A REMANENTE NO.'||a.numero_factura) descripcion, 0 admision, 0 facturado, nvl(b.monto, 0) pago_app_fact, nvl(a.db_rem, 0) debito, nvl(a.cr_rem, 0) credito, (nvl(a.monto_total, 0)-nvl(b.monto, 0)) saldo, to_number(to_char(a.fecha_creacion,'yyyy')) as anio from (select 'F' documento, r.numero_factura, r.admi_codigo_paciente, r.admi_fecha_nacimiento, to_char(r.codigo) codigo, r.fecha_creacion, r.monto_total, decode (tipo, '2', monto_total) db_rem, decode (tipo, '7', monto_total) cr_rem, r.compania, to_char(r.codigo) codigo_remanente, r.pac_id from tbl_fac_remanente r where r.ref_id = '");
	sbSql.append(refId);
	sbSql.append("' and r.compania = ");
	sbSql.append(compId);
	sbSql.append(" and a.ref_type = '");
	sbSql.append(refType);
	sbSql.append("'  and r.fecha_creacion >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and trunc (r.fecha_creacion) <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') union select 'R' recibo, to_char (b.cod_rem), a.codigo_paciente, a.fecha_nacimiento, a.recibo, a.fecha, 0, 0, b.monto, a.compania, to_char(b.cod_rem) codigo_remanente, a.ref_id,a.ref_type from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.ref_id = '");
	sbSql.append(refId);
	sbSql.append("' and a.ref_type = '");
	sbSql.append(refType);
	sbSql.append("' and a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and a.fecha >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and a.fecha <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') and b.cod_rem is not null and a.compania = b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion and a.rec_status <> 'I' ) a, (select   a.ref_id,a.ref_type, a.compania, b.cod_rem, sum(b.monto) monto from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.ref_id = '");
	sbSql.append(refId);
	sbSql.append("' and a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and a.ref_type = '");
	sbSql.append(refType);
	sbSql.append("' and a.fecha >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and a.fecha <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') and b.cod_rem is not null and a.compania = b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion and a.rec_status <> 'I' group by a.ref_id,a.ref_type, a.compania, b.cod_rem ) b where a.compania = b.compania(+) and a.ref_id = b.ref_id(+) and a.ref_type = b.ref_type(+)  and a.codigo_remanente = b.cod_rem(+)");*/

//sbSql.append(") z order by /* z.admi_secuencia, z.doc, z.f_factura, lpad(z.cod_factura,12), z.doc_type, z.fecha */  1,2 ,3,z.f_factura, lpad(z.cod_factura,12), z.fecha ");
sbSql.append(") z order by doc, fact_anio, fact_no, doc_type");

al = SQLMgr.getDataList(sbSql.toString());
StringBuffer sbSqlT = new StringBuffer();
System.out.println(" --------------------SQL   DE TOTALES --------------");
/*
sbSql.append("select nvl(a.grang_total,0)grang_total, nvl(a.pago_app_fact, 0) pago_app_fact, nvl(a.ajuste_debito, 0) + nvl(b.db_rem, 0) debito, nvl(a.ajuste_credito, 0) + nvl(b.cr_rem, 0) credito, nvl((a.grang_total - nvl(a.pago_app_fact, 0) + nvl(a.ajuste_debito,0) + nvl(b.db_rem, 0) - (nvl(a.ajuste_credito, 0) + nvl(b.cr_rem, 0))),0) saldo from (select sum(f.grang_total) grang_total, sum(pa.monto) pago_app_fact, sum(ca.ajuste_debito) ajuste_debito, sum(ca.ajuste_credito) ajuste_credito from tbl_fac_factura f, (select a.ref_id,a.ref_type, nvl(sum(nvl(b.monto, 0)),0) monto, b.fac_codigo, a.compania ctp_compania");
if(referTo.trim().equals("PAC"))sbSql.append(",b.admi_secuencia");
sbSql.append(" from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.fecha >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and a.fecha<= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(" and a.ref_id = '");
	sbSql.append(refId);
	sbSql.append("' and a.ref_type=");
	sbSql.append(refType);
	sbSql.append(" and b.cod_rem is null and (a.anio = b.tran_anio(+) and a.compania = b.compania(+) and a.codigo = b.codigo_transaccion(+))  and a.rec_status <> 'I' group by a.ref_id,a.ref_type, b.fac_codigo, a.compania");
	if(referTo.trim().equals("PAC"))sbSql.append(",b.admi_secuencia");

	sbSql.append(" ) pa, (select f.cod_otro_cliente ref_id,f.cliente_otros ref_type, aj.factura, aj.compania cia_enc, sum (decode (aj.lado_mov, 'D', aj.monto)) ajuste_debito, sum (decode (aj.lado_mov, 'C', aj.monto)) ajuste_credito from vw_con_adjustment_gral aj, tbl_fac_factura f where f.codigo =aj.factura and f.compania =aj.compania and aj.tipo_ajuste not in ( select xx.codigo from tbl_fac_tipo_ajuste xx where xx.compania = compania and xx.group_type in('E')) and trunc(aj.fecha_aprob_idx) >= to_date('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and trunc (aj.fecha_aprob_idx) <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') group by f.cliente_otros, f.cod_otro_cliente, aj.factura, aj.compania");

	sbSql.append(" union all  ");
    sbSql.append(" select f.cod_otro_cliente ref_id,f.cliente_otros ref_type, f.codigo factura, aj.company_id cia_enc, sum (decode (aj.doc_type, 'NDB', aj.net_amount)) ajuste_debito, sum (decode (aj.doc_type, 'NCR', aj.net_amount)) ajuste_credito from tbl_fac_trx aj, tbl_fac_factura f where f.codigo = (select x.other3 from tbl_fac_trx x where x.doc_id = aj.reference_id) and f.compania =aj.company_id and trunc(aj.doc_date) >= to_date('");
    sbSql.append(fDate);
    sbSql.append("', 'dd/mm/yyyy') and trunc (aj.doc_date) <= to_date ('");
    sbSql.append(tDate);
    sbSql.append("', 'dd/mm/yyyy') and aj.doc_type in ('NDB', 'NCR') and aj.status = 'O' group by f.cliente_otros, f.cod_otro_cliente, f.codigo, aj.company_id");

	sbSql.append(" ) ca where f.cod_otro_cliente = '");
	sbSql.append(refId);
	sbSql.append("' and f.cliente_otros=");
	sbSql.append(refType);
	sbSql.append(" and f.fecha >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and f.fecha <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') and f.compania = ");
	sbSql.append(compId);
	sbSql.append(" and f.estatus <> 'A' and f.cod_otro_cliente = pa.ref_id(+) and f.cliente_otros = pa.ref_type(+) and f.compania = pa.ctp_compania(+)");
	if(referTo.trim().equals("PAC"))sbSql.append(" and f.admi_secuencia = pa.admi_secuencia(+) and f.facturar_a ='P' ");
	else  sbSql.append(" and f.codigo = pa.fac_codigo(+) ");
	 sbSql.append(" and f.cod_otro_cliente = ca.ref_id(+) and f.cliente_otros = ca.ref_type(+) and f.compania = ca.cia_enc(+) and f.codigo = ca.factura(+)) a, (select sum(db_rem) db_rem, sum(cr_rem) cr_rem from (select 0 db_rem, b.monto cr_rem from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.ref_id ='");
	sbSql.append(refId);
	sbSql.append("' and a.ref_type =");
	sbSql.append(refType);
	sbSql.append(" and a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and trunc(a.fecha) >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and trunc(a.fecha) <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') and b.cod_rem is not null and a.compania =b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion and a.rec_status <> 'I' )) b");
	*/

	sbSqlT.append("/*  TOTALES ============================================ */ select sum(facturado) facturado, sum(pago_app_fact) pago_app_fact, sum(debito) debito, sum(credito) credito, sum(facturado) - sum(pago_app_fact) + sum(debito) - sum(credito) saldo from (");
	sbSqlT.append(sbSql.toString());
	sbSqlT.append(")");
		CommonDataObject cdoTotal = SQLMgr.getData(sbSqlT.toString());

	sbSql = new StringBuffer();

	sbSql.append("select a.codigo, to_char(a.fecha,'dd/mm/yyyy') fecha, a.descripcion, nvl(b.debito_rem, 0) debito, nvl(b.credito_rem, 0) credito, (nvl(b.debito_rem, 0)-nvl(b.credito_rem, 0)) saldo, a.cod_ajuste from (select distinct a.nota_ajuste codigo, a.compania, tp.ref_id,tp.ref_type, 'Aj:#'||a.nota_ajuste||'-'||'Ref:'||a.referencia cod_ajuste, a.fecha,case when a.tipo_ajuste in (select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,a.compania) and param_name='COD_AJ_DEV_PAC'),',') from dual))then 'Chk. NO.:'||a.referencia||' por Devolución de dinero ' else  ta.descripcion  end||' Recibo.#'||a.recibo descripcion from vw_con_adjustment_gral a, tbl_fac_tipo_ajuste ta,tbl_cja_transaccion_pago tp where a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and a.tipo_ajuste = ta.codigo(+) and a.compania = ta.compania and a.recibo = tp.recibo and a.compania =tp.compania and tp.ref_id = '");
	sbSql.append(refId);
	sbSql.append("' and tp.ref_type =");
	sbSql.append(refType);
	sbSql.append(" and  a.tipo_doc = 'R' and a.recibo is not null) a, (select tp.ref_id,tp.ref_type, a.nota_ajuste codigo, a.compania, sum(decode(a.lado_mov, 'D',a.monto)) debito_rem, sum(decode(a.lado_mov, 'C',a.monto)) credito_rem from vw_con_adjustment_gral a,tbl_cja_transaccion_pago tp where a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and a.recibo = tp.recibo and a.compania =tp.compania and tp.ref_id ='");
	sbSql.append(refId);
	sbSql.append("' and tp.ref_type =");
	sbSql.append(refType);
	sbSql.append(" and a.tipo_doc = 'R' and a.recibo is not null group by tp.ref_id,tp.ref_type, a.nota_ajuste, a.compania ) b where a.codigo = b.codigo and a.compania = b.compania and a.ref_id = b.ref_id and a.ref_type = b.ref_type and (nvl(b.debito_rem, 0) - nvl(b.credito_rem, 0)) != 0 order by a.fecha");
	al2 = SQLMgr.getDataList(sbSql.toString());

	sbSql2.append("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito, nvl(sum(saldo), 0) saldo from (");
	sbSql2.append(sbSql.toString());
	sbSql2.append(")");
	CommonDataObject cdoTotalR = SQLMgr.getData(sbSql2.toString());

	sbSql = new StringBuffer();
	sbSql.append("select nvl(x.cs_cant_fac,0) cs_cant_fac, nvl(x.cs_cant_ajustes,0) cs_cant_ajustes, nvl(x.cf_cant_rec_x_pag,0) cf_cant_rec_x_pag, nvl(x.cs_cant_ref_ajuste_rec,0) cs_cant_ref_ajuste_rec, nvl(x.cs_cant_rem,0) cs_cant_rem, nvl(z.cf_pagado,0) cf_pagado, nvl(z.cs_sum_db_recibo,0) cs_sum_db_recibo, nvl(z.cf_tajcr_res_rec,0) cf_tajcr_res_rec, nvl(z.cf_gran_total_aplic,0) cf_gran_total_aplic, nvl(z.cf_credito_total,0) cf_credito_total,nvl(x.cf_cant_reg_aux,0) as cs_cant_aux  from (");

		sbSql.append("select nvl(e.cs_cant_fac,0) cs_cant_fac, nvl(a.cs_cant_ajustes,0) cs_cant_ajustes, nvl(b.cf_cant_rec_x_pag,0) cf_cant_rec_x_pag, nvl(c.cs_cant_ref_ajuste_rec,0) cs_cant_ref_ajuste_rec, nvl(d.cs_cant_rem,0) cs_cant_rem, nvl(aux.cf_cant_reg_aux,0) as cf_cant_reg_aux from (");
			sbSql.append("select count(codigo) cs_cant_fac from tbl_fac_factura f where ((f.cod_otro_cliente = '");
			sbSql.append(refId);
			sbSql.append("' and f.cliente_otros = ");
			sbSql.append(refType);
			sbSql.append(") or exists (select null from tbl_adm_responsable r where r.estado = 'A' and r.ref_id = '");
			sbSql.append(refId.toUpperCase());
			sbSql.append("' and r.ref_type = ");
			sbSql.append(refType);
			sbSql.append(" and r.pac_id = f.pac_id and r.admision = f.admi_secuencia and f.facturar_a = 'P'))");
			if (!admision.trim().equals("")) { sbSql.append(" and f.admi_secuencia = "); sbSql.append(admision); }
			sbSql.append(" and f.fecha >= to_date('");
			sbSql.append(fDate);
			sbSql.append("','dd/mm/yyyy') and f.fecha <= to_date('");
			sbSql.append(tDate);
			sbSql.append("','dd/mm/yyyy') and f.compania = ");
			sbSql.append(compId);
			sbSql.append(" and f.estatus <> 'A'");
		sbSql.append(") e, (");
			sbSql.append("select sum(cs_cant_ajustes) cs_cant_ajustes from (");
				sbSql.append("select count(distinct a.nota_ajuste) cs_cant_ajustes from vw_con_adjustment_gral a, tbl_fac_factura b where a.factura = b.codigo and a.compania = b.compania and a.tipo_ajuste not in (select xx.codigo from tbl_fac_tipo_ajuste xx where xx.compania = a.compania and xx.group_type in ('E'))");
				//if(!admision.trim().equals("")){sbSql.append(" and b.admi_secuencia = "); sbSql.append(admision); }
				sbSql.append(" and a.fecha_aprob_idx >= to_date('");
				sbSql.append(fDate);
				sbSql.append("','dd/mm/yyyy') and a.fecha_aprob_idx <= to_date('");
				sbSql.append(tDate);
				sbSql.append("','dd/mm/yyyy') and ((a.ref_id = '");
				sbSql.append(refId);
				sbSql.append("' and a.ref_type = ");
				sbSql.append(refType);
				sbSql.append(") or exists (select null from tbl_adm_responsable r where r.estado = 'A' and r.ref_id= '");
				sbSql.append(refId.toUpperCase());
				sbSql.append("' and r.ref_type = ");
				sbSql.append(refType);
				sbSql.append(" and r.pac_id = b.pac_id and r.admision = b.admi_secuencia and b.facturar_a = 'P'))");
				sbSql.append(" and a.compania = ");
				sbSql.append(compId);
				sbSql.append(" union all ");
				sbSql.append("select count(distinct aj.doc_id) cs_cant_ajustes from tbl_fac_trx aj, tbl_fac_factura f where exists (select null from tbl_fac_trx x where x.doc_id = aj.reference_id and x.other3 = f.codigo) and f.compania = aj.company_id and trunc(aj.doc_date) >= to_date('");
				sbSql.append(fDate);
				sbSql.append("','dd/mm/yyyy') and trunc(aj.doc_date) <= to_date('");
				sbSql.append(tDate);
				sbSql.append("','dd/mm/yyyy') and aj.doc_type in ('NDB','NCR') and aj.status = 'O' and f.cod_otro_cliente = '");
				sbSql.append(refId);
				sbSql.append("' and f.cliente_otros = ");
				sbSql.append(refType);
				sbSql.append(" and f.compania = ");
				sbSql.append(compId);
			sbSql.append(")");
		sbSql.append(") a, (");
			sbSql.append("select distinct count(b.recibo) cf_cant_rec_x_pag from tbl_cja_transaccion_pago b where b.ref_id = '");
			sbSql.append(refId);
			sbSql.append("' and b.ref_type = ");
			sbSql.append(refType);
			sbSql.append(" and b.compania = ");
			sbSql.append(compId);
			sbSql.append(" and b.rec_status <> 'I' and b.fecha >= to_date('");
			sbSql.append(fDate);
			sbSql.append("','dd/mm/yyyy') and b.fecha <= to_date('");
			sbSql.append(tDate);
			sbSql.append("','dd/mm/yyyy')");
		sbSql.append(") b, (");
			sbSql.append("select count(a.id) cf_cant_reg_aux from tbl_con_registros_auxiliar a where a.estado = 'A' and exists (select null from tbl_con_encab_comprob z where z.consecutivo = a.trans_id and z.ea_ano = a.trans_anio and z.compania = a.compania and z.status = 'AP' and z.estado = 'A') and a.fecha_doc >= to_date('");
			sbSql.append(fDate);
			sbSql.append("','dd/mm/yyyy') and a.fecha_doc <= to_date('");
			sbSql.append(tDate);
			sbSql.append("','dd/mm/yyyy') and a.ref_id = '");
			sbSql.append(refId);
			sbSql.append("' and a.subref_type = ");
			sbSql.append(refType);
			sbSql.append(" and a.compania = ");
			sbSql.append(compId);
			sbSql.append(" and a.ref_type = 1");
		sbSql.append(") aux, (");
			sbSql.append("select count(distinct na.nota_ajuste) cs_cant_ref_ajuste_rec from vw_con_adjustment_gral na where na.ref_id = '");
			sbSql.append(refId);
			sbSql.append("' and na.ref_type = ");
			sbSql.append(refType);
			sbSql.append(" and na.compania = ");
			sbSql.append(compId);
			sbSql.append(" and na.fecha_aprob_idx >= to_date('");
			sbSql.append(fDate);
			sbSql.append("','dd/mm/yyyy') and na.fecha_aprob_idx <= to_date ('");
			sbSql.append(tDate);
			sbSql.append("','dd/mm/yyyy') and na.tipo_doc = 'R' and na.recibo is not null");
		sbSql.append(") c, (");
			sbSql.append("select count(codigo) cs_cant_rem from (select 'R' documento, to_char(b.cod_rem) numero_factura, a.codigo_paciente admi_codigo_paciente, a.fecha_nacimiento admi_fecha_nacimiento, a.recibo codigo, to_char(a.fecha,'dd/mm/yyyy') fecha_creacion, 0 as monto_total, 0 db_rem, b.monto cr_rem, a.compania from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.ref_id = '");
			sbSql.append(refId);
			sbSql.append("' and a.ref_type = ");
			sbSql.append(refType);
			sbSql.append(" and a.compania = ");
			sbSql.append(compId);
			sbSql.append(" and a.fecha >= to_date('");
			sbSql.append(fDate);
			sbSql.append("','dd/mm/yyyy') and a.fecha <= to_date('");
			sbSql.append(tDate);
			sbSql.append("','dd/mm/yyyy') and b.cod_rem is not null and a.compania = b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion and a.rec_status <> 'I')");
		sbSql.append(") d");

	sbSql.append(") x, (");

		sbSql.append("select nvl(a.cf_pagado,0) cf_pagado, nvl(b.cs_sum_db_recibo,0) cs_sum_db_recibo, nvl(b.cf_tajcr_res_rec,0) cf_tajcr_res_rec, nvl(c.cf_gran_total_aplic,0) cf_gran_total_aplic, (nvl(a.cf_pagado,0) - nvl(b.cs_sum_db_recibo,0) - nvl(c.cf_gran_total_aplic,0) + nvl(b.cf_tajcr_res_rec,0)) cf_credito_total from (");
			sbSql.append("select sum(cf_pagado) as cf_pagado from (");
				sbSql.append("select sum(nvl(tp.pago_total,0)) cf_pagado from tbl_cja_transaccion_pago tp where tp.ref_id = '");
				sbSql.append(refId);
				sbSql.append("' and tp.ref_type = ");
				sbSql.append(refType);
				sbSql.append(" and tp.compania = ");
				sbSql.append(compId);
				sbSql.append(" and tp.rec_status <> 'I' and tp.fecha >= to_date('");
				sbSql.append(fDate);
				sbSql.append("','dd/mm/yyyy') and tp.fecha <= to_date('");
				sbSql.append(tDate);
				sbSql.append("','dd/mm/yyyy') ");
				sbSql.append(" union all ");
				sbSql.append("select sum(b.monto) monto from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b, tbl_fac_factura f where a.fecha >= to_date('");
				sbSql.append(fDate);
				sbSql.append("','dd/mm/yyyy') and a.fecha <= to_date('");
				sbSql.append(tDate);
				sbSql.append("','dd/mm/yyyy') and (a.anio = b.tran_anio and a.compania = b.compania and a.codigo = b.codigo_transaccion) and f.cod_otro_cliente = '");
				sbSql.append(refId);
				sbSql.append("' and f.cliente_otros = ");
				sbSql.append(refType);
				sbSql.append(" and (f.codigo = b.fac_codigo) and f.facturar_a = 'P' and a.rec_status <> 'I' and f.estatus <> 'A' and a.compania = ");
				sbSql.append(compId);
				sbSql.append(" and f.compania= a.compania and exists (select null from tbl_adm_responsable r where r.estado = 'A' and r.ref_id = a.ref_id and r.ref_type = a.ref_type and r.pac_id = f.pac_id and r.admision = f.admi_secuencia)");
			sbSql.append(")");
		sbSql.append(") a, (");
			sbSql.append("select nvl(sum(decode(na.lado_mov,'D',na.monto)),0) cs_sum_db_recibo, nvl(sum(decode(na.lado_mov,'C',na.monto)),0) cf_tajcr_res_rec from vw_con_adjustment_gral na, tbl_fac_tipo_ajuste y, tbl_cja_transaccion_pago ctp where na.ref_id = '");
			sbSql.append(refId);
			sbSql.append("' and na.ref_type = ");
			sbSql.append(refType);
			sbSql.append(" and na.compania = ");
			sbSql.append(compId);
			sbSql.append(" and na.fecha_aprob_idx >= to_date('");
			sbSql.append(fDate);
			sbSql.append("','dd/mm/yyyy') and na.fecha_aprob_idx <= to_date('");
			sbSql.append(tDate);
			sbSql.append("','dd/mm/yyyy') and ctp.recibo = na.recibo and ctp.compania = na.compania and /*ctp.pac_id = na.pac_id*/ ctp.ref_id = na.ref_id and ctp.ref_type = na.ref_type and ctp.rec_status <> 'I' and na.tipo_doc = 'R' and na.recibo is not null and na.tipo_ajuste = y.codigo and na.compania = y.compania and y.group_type in ('H','D') and na.factura is null and na.tipo_ajuste not in (select column_value from table(select split((select get_sec_comp_param(na.compania,'CJA_TP_AJ_REC') from dual),',') from dual  ))");
		sbSql.append(") b,(");
			sbSql.append("/*cf_gran_total_aplic **********************================================== ****/ select nvl(sum(nvl(pa.monto,0)),0) cf_gran_total_aplic from (");
				/*sbSql.append("select nvl(sum(b.monto),0) monto from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b, tbl_fac_factura f where a.fecha >= to_date('");
				sbSql.append(fDate);
				sbSql.append("','dd/mm/yyyy') and a.fecha <= to_date('");
				sbSql.append(tDate);
				sbSql.append("','dd/mm/yyyy') and (a.anio = b.tran_anio and a.compania = b.compania and a.codigo = b.codigo_transaccion)");
				sbSql.append(" and (a.ref_id = '");
				sbSql.append(refId);
				sbSql.append("' and a.ref_type = ");
				sbSql.append(refType);
				sbSql.append(") and a.compania = ");
				sbSql.append(compId);
				sbSql.append(" and b.cod_rem is null and rec_status <> 'I' and f.estatus <> 'A' and f.compania = a.compania and b.fac_codigo = f.codigo and not exists (select 1 from tbl_adm_responsable r where r.estado = 'A'  and r.ref_id = a.ref_id and r.ref_type = a.ref_type) and nvl(b.fac_codigo,'-') <> '-'");
				sbSql.append(" union all ");*/
				sbSql.append("select nvl(sum(b.monto),0) monto from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.fecha >= to_date('");
				sbSql.append(fDate);
				sbSql.append("','dd/mm/yyyy') and a.fecha <= to_date('");
				sbSql.append(tDate);
				sbSql.append("','dd/mm/yyyy') and (a.anio = b.tran_anio and a.compania = b.compania and a.codigo = b.codigo_transaccion)");
				sbSql.append(" and (a.ref_id = '");
				sbSql.append(refId);
				sbSql.append("' and a.ref_type = ");
				sbSql.append(refType);
				sbSql.append(") and a.compania = ");
				sbSql.append(compId);
				sbSql.append(" and b.cod_rem is null and rec_status <> 'I' and b.fac_codigo is not null /*and nvl(b.fac_codigo,'-') = '-' */ ");
				sbSql.append(" union all ");
				sbSql.append("select nvl(sum(b.monto),0) monto from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b ,tbl_fac_factura f where a.fecha >= to_date('");
				sbSql.append(fDate);
				sbSql.append("','dd/mm/yyyy') and a.fecha <= to_date('");
				sbSql.append(tDate);
				sbSql.append("','dd/mm/yyyy') and (a.anio = b.tran_anio and a.compania = b.compania and a.codigo = b.codigo_transaccion)");
				sbSql.append(" and f.cod_otro_cliente = '");
				sbSql.append(refId);
				sbSql.append("' and f.cliente_otros = ");
				sbSql.append(refType);
				sbSql.append(" and exists (select null from tbl_adm_responsable r where r.estado = 'A' and r.ref_id = a.ref_id and r.ref_type = a.ref_type and r.pac_id = f.pac_id and r.admision = f.admi_secuencia) and a.compania = ");
				sbSql.append(compId);
				sbSql.append(" and b.cod_rem is null and rec_status <> 'I' and f.estatus <> 'A' and f.compania = a.compania");
				sbSql.append(" and b.fac_codigo = f.codigo");
			sbSql.append(") pa");
		sbSql.append(") c");
	sbSql.append(") z");
	CommonDataObject cdoTotalRGP = SQLMgr.getData(sbSql.toString());
	
	
		
		
String factApliParam = request.getParameter("factApliParam");
String mostrarFactura = request.getParameter("pMostrarFactura");
String pMes = request.getParameter("pMes");
String pAnio = request.getParameter("pAnio");

if(factApliParam==null)factApliParam="T";
if(mostrarFactura==null)mostrarFactura="T";
if(pMes==null)pMes="";
if(pAnio==null)pAnio="";
pMes  = tDate.substring(3,5);
pAnio = tDate.substring(6);
  
//var tipoClteOtros = params["tipoClteOtrosParam"].value;
//var exRefType = params["exRefTypeParam"].value;
//var exSubRefType = params["exSubRefTypeParam"].value; 
//var pMes = params["pMes"].value;
//var pAnio = params["pAnio"].value;

sbSql = new StringBuffer();
sbSql.append(" select ");
//sbSql.append(" m.tipo_cta, decode(m.tipo_cta,'M','MEDICO','A','ASEGURADORA','J' ,'JUBILADO','P','PARTICULAR','N','JUNTA DIRECTIVA','E','EMPLEADO','O','OTROS CLIENTES','X','DETALLE AUX.') as desc_tipo_cta");
//sbSql.append(" ,case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then decode(m.tipo_cta,'A',to_char(m.aseguradora),'J',to_char(m.aseguradora),'P','PARTICULAR') else decode(m.tipo_cta, 'A', to_char(m.aseguradora), m.cedula) end as aseguradora");
//sbSql.append(", case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then   decode(m.tipo_cta,'A',e.nombre,'J',e.nombre,'P','PARTICULAR') else  decode(m.tipo_cta, 'A', e.nombre, m.nombre || '-' || m.cedula) end    desc_empresa ");
//sbSql.append(",case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then  decode(m.tipo_cta,'A',e.nombre,'J',e.nombre,'P','PARTICULAR') else   nvl(e.nombre,  'PAGO NO APLICADO')  end as nombre_aseguradora,");
sbSql.append("  nvl(sum(nvl(m.scorriente,0)),0) scorriente, nvl(sum(nvl(m.s30,0)),0) s30, nvl(sum(nvl(m.s60,0)),0) s60, nvl(sum(nvl(m.s90,0)),0) s90, nvl(sum(nvl(m.s120,0)),0) s120, nvl(sum(nvl(m.s150,0)),0) s150, nvl(sum(nvl(m.scorriente,0) + nvl(m.s30,0) + nvl(m.s60,0) + nvl(m.s90,0) + nvl(m.s120,0) + nvl(m.s150,0)),0) saldo_actual from tbl_cxc_morosidades_mes m, tbl_adm_empresa e, tbl_fac_factura f where  m.aseguradora = e.codigo(+) and m.cia = f.compania(+) and m.factura = f.codigo(+)");
sbSql.append(" and m.fg IN ('AUX','MOR', 'RNA','CAR') and m.cia = ");
sbSql.append(compId);

if(factApliParam.equals("N")){
sbSql.append(" and not exists (select z.fac_codigo, nvl(sum(z.monto),0) from tbl_cja_detalle_pago z, tbl_cja_transaccion_pago y where z.codigo_transaccion = y.codigo and z.compania = y.compania and z.tran_anio = y.anio and y.rec_status = 'A' and z.fac_codigo = m.factura and z.compania = m.cia group by z.fac_codigo having nvl(sum(z.monto),0) > 0)");
} else if(factApliParam.equals("S")){
sbSql.append(" and exists (select z.fac_codigo, nvl(sum(z.monto),0) from tbl_cja_detalle_pago z, tbl_cja_transaccion_pago y where z.codigo_transaccion = y.codigo and z.compania = y.compania and z.tran_anio = y.anio and y.rec_status = 'A' and z.fac_codigo = m.factura and z.compania = m.cia group by z.fac_codigo having nvl(sum(z.monto),0) > 0)");
}
/*
if (tipo_cta.trim().equals("O")) {
sbSql.append(" and m.tipo_cta in('X','");
sbSql.append(tipo_cta);
sbSql.append("')");
}else {
	if (tipo_cta.trim().equals("A"))
	sbSql.append(" and m.tipo_cta in('A','J')");
	else if (tipo_cta.trim().equals("P"))
	sbSql.append(" and m.tipo_cta in('P','X')");
	else if (tipo_cta.trim().equals("J"))
	sbSql.append(" and m.tipo_cta = 'J'");
	else if (!tipo_cta.trim().equals("ALL")){
		sbSql.append(" and f.facturar_a = '");
		sbSql.append(tipo_cta);
		sbSql.append("'");
	}
}*/
/*if (!categoria.trim().equals("ALL")){
sbSql.append(" and nvl(m.categoria,-1) = ");
sbSql.append(categoria);
}*/
/*if (!aseguradora.trim().equals("ALL")){
sbSql.append(" and m.aseguradora = ");
sbSql.append(aseguradora);
}*/

if (mostrarFactura.trim().equals("E")){
	sbSql.append(" and exists (select null from tbl_fac_factura f where m.factura = f.codigo and m.cia=f.compania and (nvl(f.enviado, 'N') = 'S' or f.facturar_a = 'P' or (f.facturar_a in ('E', 'P') and nvl(substr(f.comentario, 1, 3), 'NA') = 'S/I')))");
} else if (mostrarFactura.trim().equals("N")){
	sbSql.append(" and exists (select null from tbl_fac_factura f where m.factura = f.codigo and m.cia=f.compania and nvl(f.enviado, 'N') = 'N' and f.facturar_a != 'P' and nvl(substr(f.comentario, 1, 3), 'NA') != 'S/I')");
}

sbSql.append(" and m.mes = ");
sbSql.append(pMes); 
sbSql.append(" and m.anio = ");
sbSql.append(pAnio);         
 
  if (!refId.trim().equals("ALL") ){
sbSql.append(" and m.ref_id = '");
sbSql.append(refId);
sbSql.append("'");
}/**/
if (!refType.trim().equals("ALL")) {
sbSql.append(" and m.ref_type =");
sbSql.append(refType);
}
/*if (!subRefType.trim().equals("ALL")) {
sbSql.append(" and m.ref_id in (select to_char(codigo) from tbl_cxc_cliente_particular where compania =");
sbSql.append(compania);
sbSql.append(" and cliente_alquiler != 'S' and tipo_cliente=");
sbSql.append(subRefType);
sbSql.append(")");
}*//*
if (exRefType != null && !exRefType.equals("ALL")) {
	sbSql.append(" and (m.ref_type not in (");
	sbSql.append(exRefType);
	if(tipoClteOtros!=null && !tipoClteOtros.equals("")){
	sbSql.append(", ");
	sbSql.append(tipoClteOtros);
	}
	sbSql.append(")");
	if (exSubRefType!=null && !exSubRefType.equals("ALL")) {
		sbSql.append(" or (m.ref_type = ");
		sbSql.append(tipoClteOtros);
		sbSql.append(" and not exists (select null from tbl_cxc_cliente_particular cp where to_char (cp.codigo) = m.ref_id and tipo_cliente = ");
		sbSql.append(exSubRefType);
		sbSql.append("))");		
	}
	sbSql.append(")");
}*/
//sbSql.append(" group by m.tipo_cta,decode(m.tipo_cta,'M','MEDICO','A','ASEGURADORA','J' ,'JUBILADO','P','PARTICULAR','N','JUNTA DIRECTIVA','E','EMPLEADO','O','OTROS CLIENTES','X','DETALLE AUX.'),case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then decode(m.tipo_cta,'A',to_char(m.aseguradora),'J',to_char(m.aseguradora),'P','PARTICULAR') else decode(m.tipo_cta, 'A', to_char(m.aseguradora), m.cedula) end  , case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then   decode(m.tipo_cta,'A',e.nombre,'J',e.nombre,'P','PARTICULAR') else  decode(m.tipo_cta, 'A', e.nombre, m.nombre || '-' || m.cedula) end  , case when get_sec_comp_param(m.cia, 'CXC_MOR_RES_PART')= 'Y'then  decode(m.tipo_cta,'A',e.nombre,'J',e.nombre,'P','PARTICULAR') else   nvl(e.nombre,  'PAGO NO APLICADO')  end");

CommonDataObject cdoCxc = SQLMgr.getData(sbSql.toString());
if(cdoCxc == null ){cdoCxc =new CommonDataObject();
cdoCxc.addColValue("scorriente","0");
cdoCxc.addColValue("s30","0");
cdoCxc.addColValue("s60","0");
cdoCxc.addColValue("s90","0");
cdoCxc.addColValue("s120","0");
cdoCxc.addColValue("s150","0");
cdoCxc.addColValue("saldo_actual","0");
cdoCxc.addColValue("existe","N");
}else cdoCxc.addColValue("existe","S");
cdoCxc.addColValue("descTitulo",CmnMgr.getFormattedDate(tDate,"MONTH yyyy","spanish"));



if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	//String title = "RESUMEN DE FACTURAS";
	String title = "ESTADO DE CUENTA";
	String subtitle = "DESDE  "+fDate+"    HASTA   "+tDate;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);



	Vector dHeader=new Vector();
		dHeader.addElement(".12");
		dHeader.addElement(".08");
		dHeader.addElement(".16");
		dHeader.addElement(".16");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".11");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(headerFontSize,1);

				pc.addBorderCols(" ", 0, dHeader.size(), 0.0f, 0.5f, 0.0f, 0.0f);

				pc.addBorderCols("Cliente:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("nombre"), 0, 4, 0.0f, 0.0f, 0.0f, 0.0f);

				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("Id Clte:", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("codigo"), 0, 3, 0.0f, 0.0f, 0.0f, 0.0f);

			if(fg.trim().equals("PAC")||referTo.trim().equals("PAC")){
				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("Dirección:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("direccion"), 0, 4, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("Cédula:", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("ruc"), 0, 3, 0.0f, 0.0f, 0.0f, 0.0f);

				pc.setFont(headerFontSize, 1);
				pc.addCols("Teléfono:", 0, 1);
				pc.setFont(headerFontSize, 0);
				pc.addCols(cdoHeader.getColValue("telefono"), 0, 1);
				pc.setFont(headerFontSize, 1);
				pc.addCols("Responsable:", 0, 1);
				pc.setFont(headerFontSize, 0);
				pc.addCols(cdoHeader.getColValue("responsable"), 0, 3);
				pc.setFont(headerFontSize, 1);
				pc.addCols(" ", 2, 2);
				pc.setFont(headerFontSize, 0);
				pc.addCols(" ", 0, 2);
				}
				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("# Documento", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Fecha", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Descripción", 1, 2, 0.5f, 0.5f, 0.0f, 0.0f);
				if(fg.trim().equals("PAC")||referTo.trim().equals("PAC"))pc.addBorderCols("# Adm.", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				else pc.addBorderCols(" ", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Facturado", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Pago Apli. a Fact.", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Débitos", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Créditos", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Saldo", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);

	//pc.setTableHeader(2);//create de table header

	//table body
	double pago_x_adm = 0.00;
	double pago_total = 0.00;

	double monto = 0.00;
	double debit = 0.00;
	double pagos = 0.00;
	double credit = 0.00;
	double descuentos = 0.00;
	double saldo = 0.00;
	boolean delPacDet = true;
	double _monto = 0.00, _debit = 0.00, _credit = 0.00, _pagos = 0.00;
	String cfa ="";
	boolean pinsi = false;
	float _top = 0.0f, _bottom = 0.00f;
	for (int i=0; i<al.size(); i++)
	{

		if (i == 0) pc.setTableHeader(4);
		pc.setFont(contentFontSize,0);

		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(!cdo.getColValue("cod_factura").equals(cfa) && i!=0 && !pinsi/**/)
		{

			_top = 0.5f;
			saldo = (_monto + _debit - _pagos - _credit);

				pc.addBorderCols("", 2, 9, 0.0f, 0.0f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo), 2, 1, 0.0f, 0.0f, 0.0f, 0.5f);

			saldo = 0;
			monto = 0;
			pagos = 0;
			debit = 0;
			credit = 0;
			_monto =0;
			_pagos = 0;_debit = 0;
			_credit = 0;

		} else _top = 0.0f;


		if(cdo.getColValue("doc_type").equals("1")){
			pc.resetFont();
			pc.setFont(contentFontSize, 0);
		} else if(cdo.getColValue("doc_type").equals("2")){
			pc.resetFont();
			pc.setFont(contentFontSize, 1, Color.BLUE);
		} else if(cdo.getColValue("doc_type").equals("3")){
			pc.resetFont();
			pc.setFont(contentFontSize, 1, Color.RED);
		} else if(cdo.getColValue("doc_type").equals("4")){
			pc.resetFont();
			pc.setFont(contentFontSize, 1, Color.MAGENTA);
		}




		if(cdo.getColValue("doc_type").equals("0"))
		{
				pc.addBorderCols("SALDO INICIAL", 2, 9, 0.0f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols((cdo.getColValue("saldo").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")), 2, 1, 0.0f, 0.5f, 0.0f, 0.5f);
				pinsi = true;
		} else if(cdo.getColValue("doc_type").equals("1"))
		{
				pc.addBorderCols(cdo.getColValue("documento"), 1, 1, 0.0f, _top, 0.5f, 0.0f);
				pc.addBorderCols(cdo.getColValue("fecha"), 0, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols(cdo.getColValue("descripcion"), 0, 2, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("admision") == null ||cdo.getColValue("admision").equals("0"))?"":cdo.getColValue("admision"), 1, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("facturado").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("facturado")), 2, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("pago_app_fact").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("pago_app_fact")), 2, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("debito").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("debito")), 2, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("credito").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("credito")), 2, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("saldo").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")), 2, 1, 0.0f, _top, 0.0f, 0.5f);
				pinsi = false;
		} else {
				pc.addBorderCols(cdo.getColValue("documento"), 1, 1, 0.0f, _top, 0.5f, 0.0f);
				pc.addBorderCols(cdo.getColValue("fecha"), 0, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols(cdo.getColValue("descripcion") +((cdo.getColValue("doc_type").equals("4"))?"":" Fac. ")+cdo.getColValue("cod_factura"), 0, 2, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("admision").equals("0"))?"":cdo.getColValue("admision"), 1, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("facturado").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("facturado")), 2, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("pago_app_fact").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("pago_app_fact")), 2, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("debito").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("debito")), 2, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("credito").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("credito")), 2, 1, 0.0f, _top, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("saldo").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")), 2, 1, 0.0f, _top, 0.0f, 0.5f);
				pinsi = false;
		}
		cfa = cdo.getColValue("cod_factura");
		_monto += Double.parseDouble(cdo.getColValue("facturado"));
		_pagos += Double.parseDouble(cdo.getColValue("pago_app_fact"));
		_debit += Double.parseDouble(cdo.getColValue("debito"));
		_credit += Double.parseDouble(cdo.getColValue("credito"));

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			//pc.addBorderCols("", 0, dHeader.size(), 0.0f, 0.0f, 0.0f, 0.0f);
			//pc.addBorderCols("", 0, dHeader.size(), 0.0f, 0.0f, 0.0f, 0.0f);

			saldo = (_monto + _debit - _pagos - _credit);// + Double.parseDouble(saldo_inicial);
				pc.addBorderCols("  ", 2, 9, 0.5f, 0.0f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo), 2, 1, 0.5f, 0.0f, 0.0f, 0.5f);


			pc.setFont(contentFontSize, 1,Color.red);
			
			if(cdoQry.getColValue("ESTADO_CTA_CXC_NUEVO_FORMATO").equals("N")){

				pc.addBorderCols("TOTALES EN FACTURAS", 2, 5, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("facturado")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("pago_app_fact")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("debito")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("credito")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(Double.parseDouble(cdoTotal.getColValue("saldo")) + Double.parseDouble(saldo_inicial)), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
			pc.setFont(contentFontSize, 1);
			}
				pc.addBorderCols("", 0, dHeader.size(), 0.0f, 0.0f, 0.0f, 0.0f);

				pc.addBorderCols("", 0, dHeader.size(), 0.0f, 0.0f, 0.0f, 0.0f);

				pc.addBorderCols("", 0, dHeader.size(), 0.0f, 0.0f, 0.0f, 0.0f);

				pc.addBorderCols("", 0, dHeader.size(), 0.0f, 0.0f, 0.0f, 0.0f);

				pc.addBorderCols("Movimientos por Ajuste a Recibos:", 0, dHeader.size(), 0.5f, 0.5f, 0.0f, 0.0f);



			pc.resetFont();
			pc.setFont(contentFontSize, 0, Color.RED);
			for(int l=0;l<al2.size();l++){
				CommonDataObject cdoR = (CommonDataObject) al2.get(l);

					pc.addBorderCols(cdoR.getColValue("cod_ajuste"), 0, 2, 0.0f, 0.0f, 0.0f, 0.0f);
					pc.addBorderCols(cdoR.getColValue("fecha"), 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);
					pc.addBorderCols(cdoR.getColValue("descripcion"), 0, 4, 0.0f, 0.0f, 0.0f, 0.0f);
					pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoR.getColValue("debito")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
					pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoR.getColValue("credito")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
					pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoR.getColValue("saldo")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);

			}

			pc.setFont(contentFontSize, 1);


				pc.addBorderCols("TOTALES DE AJUSTES A RECIBOS", 2, 7, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotalR.getColValue("debito")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotalR.getColValue("credito")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotalR.getColValue("saldo")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);

				pc.addBorderCols(" ", 2, 10, 0.0f, 0.0f, 0.0f, 0.0f);



				pc.addBorderCols("", 2, 5, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols("Resumen General de Pagos:", 1, 5, 0.0f, 0.5f, 0.5f, 0.5f);

				pc.addBorderCols("Facturas", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(" = ", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(cdoTotalRGP.getColValue("cs_cant_fac"),2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols("", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols("Gran Total Pagado :", 0, 2, 0.0f, 0.0f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotalRGP.getColValue("cf_pagado")), 2, 3, 0.0f, 0.0f, 0.0f, 0.5f);

				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.RED);
				pc.addBorderCols("Ajustes Fact.", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(" = ", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(cdoTotalRGP.getColValue("cs_cant_ajustes"), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols("", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.BLACK);
				pc.addBorderCols("- Ajustes DB Recibos :", 0, 2, 0.0f, 0.0f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotalRGP.getColValue("cs_sum_db_recibo")), 2, 3, 0.0f, 0.0f, 0.0f, 0.5f);

				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.BLUE);
				pc.addBorderCols("Recibos", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(" = ", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(cdoTotalRGP.getColValue("cf_cant_rec_x_pag"), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.BLACK);
				pc.addBorderCols("", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols("- Total Aplicado :", 0, 2, 0.0f, 0.0f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotalRGP.getColValue("cf_gran_total_aplic")), 2, 3, 0.0f, 0.0f, 0.0f, 0.5f);

				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.RED);
				pc.addBorderCols("Ajuste Rec.", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(" = ", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(cdoTotalRGP.getColValue("cs_cant_ref_ajuste_rec"), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.RED);
				pc.addBorderCols("", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols("+ Ajustes CR Recibos :", 0, 2, 0.0f, 0.0f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotalRGP.getColValue("cf_tajcr_res_rec")), 2, 3, 0.0f, 0.0f, 0.0f, 0.5f);

				pc.resetFont();
				pc.setFont(contentFontSize, 1, Color.MAGENTA);
				pc.addBorderCols("Remanentes", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(" = ", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(cdoTotalRGP.getColValue("cs_cant_rem"), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.BLACK);
				pc.addBorderCols("", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols("= Crédito Total en Recibos", 0, 2, 0.0f, 0.0f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotalRGP.getColValue("cf_credito_total")), 2, 3, 0.0f, 0.5f, 0.0f, 0.5f);

				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.BLUE);
				pc.addBorderCols("Registros de Auxiliar", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(" = ", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(cdoTotalRGP.getColValue("cs_cant_aux"), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.BLACK);
				pc.addBorderCols(" ", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols("  ", 0, 2, 0.0f, 0.0f, 0.5f, 0.0f);
				pc.addBorderCols("   "/*CmnMgr.getFormattedDecimal(cdoTotalRGP.getColValue("cf_credito_total"))*/, 2, 3, 0.0f, 0.5f, 0.0f, 0.5f);


				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.BLUE);
				pc.addBorderCols(" ", 0, 5, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols("", 0, 5, 0.5f, 0.0f, 0.5f, 0.5f);

				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.BLACK);
				pc.addBorderCols("", 2, 10, 0.0f, 0.0f, 0.0f, 0.0f);
				

				pc.addBorderCols(" ", 2, 10, 0.0f, 0.0f, 0.0f, 0.0f);
				
				if(cdoQry.getColValue("ESTADO_CTA_CXC_NUEVO_FORMATO").equals("S")){

				pc.setNoColumn(7);
				pc.createTable("total",false,0,0.0f,width-(2*leftRightMargin));
				pc.addBorderCols("SALDO FINAL DE CUENTA", 1, 7, 0.0f, 0.5f, 0.5f, 0.5f);

				pc.addBorderCols("SALDO INICIAL", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("FACTURAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("PAGOS APLI. FACT.", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("DEBITO", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("CREDITO", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("PAGOS NO APLI.", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("TOTAL E.C.", 1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
				
				pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo_inicial),2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("facturado")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("pago_app_fact")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("debito")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("credito")), 2, 1, 0.5f, 0.5f, 0.5f, 0.5f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotalRGP.getColValue("cf_credito_total")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				Double saldo_final = Double.parseDouble(saldo_inicial)+Double.parseDouble(cdoTotal.getColValue("facturado"))-Double.parseDouble(cdoTotal.getColValue("pago_app_fact"))+Double.parseDouble(cdoTotal.getColValue("debito"))-Double.parseDouble(cdoTotal.getColValue("credito"))-Double.parseDouble(cdoTotalRGP.getColValue("cf_credito_total"));		
				pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo_final), 2, 1, 0.5f, 0.5f, 0.5f, 0.5f);
				pc.useTable("main");
				pc.addTableToCols("total",0,dHeader.size());
				}
				
	pc.addBorderCols(" ", 2, 10, 0.0f, 0.0f, 0.0f, 0.0f);
				
				if(cdoQry.getColValue("verMorosidad").equals("S")){

				pc.setNoColumn(7);
				pc.createTable("totalMor",false,0,0.0f,width-(2*leftRightMargin));
				pc.addBorderCols("MOROSIDAD HASTA "+cdoCxc.getColValue("descTitulo"), 1, 7, 0.0f, 0.5f, 0.5f, 0.5f);
				if(!cdoCxc.getColValue("existe").equals("N")){
				pc.addBorderCols("CORRIENTE", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("A 30 DIAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("A 60 DIAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("A 90 DIAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("A 120 DIAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("A 150 DIAS", 1, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols("TOTAL", 1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
				
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("scorriente")),2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("s30")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("s60")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("s90")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("s120")), 2, 1, 0.5f, 0.5f, 0.5f, 0.5f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("s150")), 2, 1, 0.5f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoCxc.getColValue("saldo_actual")), 2, 1, 0.5f, 0.5f, 0.5f, 0.5f);
				}else {pc.addBorderCols("NO EXISTE REGISTROS DE MOROSIDAD GENERADA PARA "+cdoCxc.getColValue("descTitulo"), 1, 7, 0.5f, 0.5f, 0.5f, 0.5f);}
				
				pc.useTable("main");
				pc.addTableToCols("totalMor",0,dHeader.size());
				}
				
				
	}

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>