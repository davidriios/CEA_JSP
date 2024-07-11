<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
Reporte  fac70605_r.rdf
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

String noSecuencia = request.getParameter("noSecuencia");
String pacId = request.getParameter("pacId");
String factId = request.getParameter("factId");
String compId = (String) session.getAttribute("_companyId");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");


sbSql.append("select p.nombre_paciente nombre, p.residencia_direccion, p.telefono, p.fecha_nacimiento || '' || p.codigo id_pte2,p.pac_id, p.id_paciente cedula, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, to_char(p.f_nac,'dd/mm/yyyy') fecha_nac_corregida, p.codigo, nvl(r.nombre,' ') responsable from vw_adm_paciente p, (select pac_id, max(admision) admision from tbl_adm_responsable where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and estado='A' group by pac_id) ma, tbl_adm_responsable r where p.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and p.pac_id = ma.pac_id(+) and ma.pac_id = r.pac_id(+) and ma.admision = r.admision(+) and r.estado(+)='A'");

	CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());
		
	sbSql = new StringBuffer();
		
		sbSql.append("select z.doc, z.cod_factura, z.doc_type, z.documento, to_char(fecha,'dd/mm/yyyy') fecha, z.descripcion, z.admision, nvl(z.facturado, 0) facturado, nvl(z.pago_app_fact, 0) pago_app_fact, nvl(z.debito, 0) debito, nvl(z.credito, 0) credito, nvl(z.saldo, 0) saldo from (");
		
		
		sbSql.append(" select 'O' doc, f.codigo cod_factura, 1 doc_type, f.admi_secuencia, f.codigo documento, f.fecha, 'FACTURA' || ' ' || decode(a.conta_cred,'R','(CRED)','C','(CONT)') descripcion, f.admi_secuencia admision, f.grang_total facturado, 0 pago_app_fact, 0 debito, 0 credito, 0 saldo from tbl_fac_factura f, tbl_adm_admision a where f.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and f.pac_id = a.pac_id(+) and f.admi_secuencia = a.secuencia(+) and f.facturar_a = 'P' and f.fecha >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and f.fecha <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy')  and f.estatus <> 'A'  and f.compania = a.compania(+) and f.compania = ");
	sbSql.append(compId);
	
		
		sbSql.append(" union ");
		sbSql.append("select 'O' doc, f.codigo cod_factura, 2 doc_type, f.admi_secuencia, pa.codigo documento,  pa.fecha, 'PAGO' descripcion, 0 admision, 0 facturado, pa.monto pago_app_fact, 0 debito, 0 credito, 0 saldo from tbl_fac_factura f, (select a.pac_id, a.recibo codigo, a.fecha, sum(b.monto)monto, b.admi_secuencia, a.compania ctp_compania from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where trunc (a.fecha) >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and trunc (a.fecha) <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') and b.cod_rem is null and (a.anio = b.tran_anio(+) and a.compania = b.compania(+) and a.codigo = b.codigo_transaccion(+)) and a.rec_status <> 'I' group by  a.pac_id, a.recibo, a.fecha, b.admi_secuencia, a.compania) pa where f.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and f.fecha >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and f.fecha <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') and f.compania = ");
	sbSql.append(compId);
	sbSql.append(" and f.facturar_a = 'P' and f.estatus <> 'A' and f.pac_id = pa.pac_id  and f.admi_secuencia = pa.admi_secuencia and f.compania = pa.ctp_compania ");
	sbSql.append(" union ");
	sbSql.append("select   'O' doc, f.codigo cod_factura, 3 doc_type, f.admi_secuencia, to_char(ca.referencia) documento, ca.fecha_creacion fecha, decode(ca.recibo,null,decode(ca.explicacion,null,'NO TIENE DESCRIPCION',ca.explicacion),ca.explicacion||'-Rec.#'||ca.recibo) descripcion, 0 admision, 0 facturado, 0 pago_app_fact, ca.ajuste_debito debito, ca.ajuste_credito credito, 0 saldo from tbl_fac_factura f, (select   pac_id, fecha_creacion, factura, recibo,nota_ajuste referencia, explicacion, compania cia_enc, sum(decode (lado_mov, 'D', monto,0)) ajuste_debito, sum(decode(lado_mov, 'C', monto,0)) ajuste_credito from vw_con_adjustment_gral where tipo_ajuste not in (select xx.codigo from tbl_fac_tipo_ajuste xx where xx.compania = compania and xx.group_type in ('E')) and trunc(fecha_creacion) >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and trunc(fecha_creacion) <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') group by pac_id, fecha_creacion, factura, recibo, nota_ajuste, explicacion, compania order by nota_ajuste ) ca where f.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and f.fecha >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and f.fecha <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') and f.compania = ");
	sbSql.append(compId);
	sbSql.append(" and f.facturar_a = 'P' and f.estatus <> 'A' and f.compania = ca.cia_enc and f.codigo = ca.factura");
	sbSql.append(" union ");
	sbSql.append("select 'R' doc, '0' cod_factura, 4 doc_type, 999999 admi_secuencia, to_char(a.codigo) documento, a.fecha_creacion fecha, decode(a.documento, 'F', 'REMANENTE DE FACTURA '||a.numero_factura,'R','PAGO A REMANENTE NO.'||a.numero_factura) descripcion, 0 admision, 0 facturado, nvl(b.monto, 0) pago_app_fact, nvl(a.db_rem, 0) debito, nvl(a.cr_rem, 0) credito, (nvl(a.monto_total, 0)-nvl(b.monto, 0)) saldo from (select 'F' documento, r.numero_factura, r.admi_codigo_paciente, r.admi_fecha_nacimiento, to_char(r.codigo) codigo, r.fecha_creacion, r.monto_total, decode (tipo, '2', monto_total) db_rem, decode (tipo, '7', monto_total) cr_rem, r.compania, to_char(r.codigo) codigo_remanente, r.pac_id from tbl_fac_remanente r where r.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and r.compania = ");
	sbSql.append(compId);
	sbSql.append(" and r.facturar_a = 'P' and r.fecha_creacion >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and trunc (r.fecha_creacion) <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') union select 'R' recibo, to_char (b.cod_rem), a.codigo_paciente, a.fecha_nacimiento, a.recibo, a.fecha, 0, 0, b.monto, a.compania, to_char(b.cod_rem) codigo_remanente, a.pac_id from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and a.fecha >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and a.fecha <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') and b.cod_rem is not null and a.compania = b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion and a.rec_status <> 'I' ) a, (select   a.pac_id, a.compania, b.cod_rem, sum(b.monto) monto from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and a.fecha >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and a.fecha <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') and b.cod_rem is not null and a.compania = b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion and a.rec_status <> 'I' group by a.pac_id, a.compania, b.cod_rem ) b where a.compania = b.compania(+) and a.pac_id = b.pac_id(+) and a.codigo_remanente = b.cod_rem(+)");
	sbSql.append(") z order by z.admi_secuencia, z.doc, z.doc_type, to_date(z.fecha,'dd/mm/yyyy'), lpad(z.cod_factura,12)");

		al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();

sbSql.append("select nvl(a.grang_total,0)grang_total, nvl(a.pago_app_fact, 0) pago_app_fact, nvl(a.ajuste_debito, 0) + nvl(b.db_rem, 0) debito, nvl(a.ajuste_credito, 0) + nvl(b.cr_rem, 0) credito, nvl((a.grang_total - a.pago_app_fact + nvl(a.ajuste_debito,0) + nvl(b.db_rem, 0) - (nvl(a.ajuste_credito, 0) + nvl(b.cr_rem, 0))),0) saldo from (select sum(f.grang_total) grang_total, sum(pa.monto) pago_app_fact, sum(ca.ajuste_debito) ajuste_debito, sum(ca.ajuste_credito) ajuste_credito from tbl_fac_factura f, (select a.pac_id, nvl(sum(nvl(b.monto, 0)),0) monto, b.admi_secuencia, a.compania ctp_compania from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.fecha >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and a.fecha<= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') and b.cod_rem is null and (a.anio = b.tran_anio(+) and a.compania = b.compania(+) and a.codigo = b.codigo_transaccion(+))  and a.rec_status <> 'I' group by a.pac_id, b.admi_secuencia, a.compania ) pa, (select f.pac_id, aj.factura, aj.compania cia_enc, sum (decode (aj.lado_mov, 'D', aj.monto)) ajuste_debito, sum (decode (aj.lado_mov, 'C', aj.monto)) ajuste_credito from vw_con_adjustment_gral aj, tbl_fac_factura f where f.codigo =aj.factura and f.compania =aj.compania and aj.tipo_ajuste not in ( select xx.codigo from tbl_fac_tipo_ajuste xx where xx.compania = compania and xx.group_type in('E')) and trunc(aj.fecha_creacion) >= to_date('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and trunc (aj.fecha_creacion) <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') group by f.pac_id, aj.factura, aj.compania) ca where f.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and f.fecha >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and f.fecha <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') and f.compania = ");
	sbSql.append(compId);
	sbSql.append(" and f.facturar_a = 'P' and f.estatus <> 'A' and f.pac_id = pa.pac_id(+) and f.compania = pa.ctp_compania(+) and f.admi_secuencia = pa.admi_secuencia(+) and f.pac_id = ca.pac_id(+) and f.compania = ca.cia_enc(+) and f.codigo = ca.factura(+)) a, (select sum(db_rem) db_rem, sum(cr_rem) cr_rem from ( select sum(decode (tipo, '2', monto_total)) db_rem, sum(decode (tipo, '7', monto_total)) cr_rem from tbl_fac_remanente r where r.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and r.compania =");
	sbSql.append(compId);
	sbSql.append(" and r.facturar_a = 'P' and trunc(r.fecha_creacion) >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and trunc (r.fecha_creacion) <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') union all  select 0, b.monto from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and trunc(a.fecha) >= to_date ('");
	sbSql.append(fDate);
	sbSql.append("', 'dd/mm/yyyy') and trunc(a.fecha) <= to_date ('");
	sbSql.append(tDate);
	sbSql.append("', 'dd/mm/yyyy') and b.cod_rem is not null and a.compania =b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion and a.rec_status <> 'I' )) b");

		CommonDataObject cdoTotal = SQLMgr.getData(sbSql.toString());
	
	sbSql = new StringBuffer();

	sbSql.append("select a.codigo, to_char(a.fecha,'dd/mm/yyyy') fecha, a.descripcion, nvl(b.debito_rem, 0) debito, nvl(b.credito_rem, 0) credito, (nvl(b.debito_rem, 0)-nvl(b.credito_rem, 0)) saldo, a.cod_ajuste from (select distinct a.nota_ajuste codigo, a.compania, tp.pac_id, 'Aj:#'||a.nota_ajuste||'-'||'Ref:'||a.referencia cod_ajuste, a.fecha,case when a.tipo_ajuste in (select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,a.compania) and param_name='COD_AJ_DEV_PAC'),',') from dual))then 'Chk. NO.:'||a.referencia||' por Devoluci¾n de dinero ' else  ta.descripcion  end||' Recibo.#'||a.recibo descripcion from vw_con_adjustment_gral a, tbl_fac_tipo_ajuste ta,tbl_cja_transaccion_pago tp where a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and a.tipo_ajuste = ta.codigo(+) and a.compania = ta.compania and a.recibo = tp.recibo and a.compania =tp.compania and tp.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and  a.tipo_doc = 'R' and a.recibo is not null) a, (select tp.pac_id, a.nota_ajuste codigo, a.compania, sum(decode(a.lado_mov, 'D',a.monto)) debito_rem, sum(decode(a.lado_mov, 'C',a.monto)) credito_rem from vw_con_adjustment_gral a,tbl_cja_transaccion_pago tp where a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and a.recibo = tp.recibo and a.compania =tp.compania and tp.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.tipo_doc = 'R' and a.recibo is not null group by tp.pac_id, a.nota_ajuste, a.compania ) b where a.codigo = b.codigo and a.compania = b.compania and a.pac_id = b.pac_id and (nvl(b.debito_rem, 0) - nvl(b.credito_rem, 0)) != 0 order by a.fecha");
		al2 = SQLMgr.getDataList(sbSql.toString());

		sbSql2.append("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito, nvl(sum(saldo), 0) saldo from (");
		sbSql2.append(sbSql.toString());
		sbSql2.append(")");
		CommonDataObject cdoTotalR = SQLMgr.getData(sbSql2.toString());
		
		sbSql = new StringBuffer();

		sbSql.append(" select nvl(x.cs_cant_fac, 0) cs_cant_fac, nvl(x.cs_cant_ajustes, 0) cs_cant_ajustes, nvl(x.cf_cant_rec_x_pag, 0) cf_cant_rec_x_pag, nvl(x.cs_cant_ref_ajuste_rec, 0) cs_cant_ref_ajuste_rec, nvl(x.cs_cant_rem, 0) cs_cant_rem, nvl(z.cf_pagado, 0) cf_pagado, nvl(z.cs_sum_db_recibo, 0) cs_sum_db_recibo, nvl(z.cf_tajcr_res_rec, 0) cf_tajcr_res_rec, nvl(z.cf_gran_total_aplic, 0) cf_gran_total_aplic, nvl(z.cf_credito_total, 0) cf_credito_total from (select nvl(e.cs_cant_fac, 0) cs_cant_fac, nvl(a.cs_cant_ajustes, 0) cs_cant_ajustes, nvl(b.cf_cant_rec_x_pag, 0) cf_cant_rec_x_pag, nvl(c.cs_cant_ref_ajuste_rec, 0) cs_cant_ref_ajuste_rec, nvl(d.cs_cant_rem, 0) cs_cant_rem from (select count(codigo) cs_cant_fac from tbl_fac_factura f where f.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and f.fecha >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and f.fecha <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') and f.compania = ");
	sbSql.append(compId);
	sbSql.append(" and f.facturar_a = 'P' and f.estatus <> 'A') e, (select count(distinct a.nota_ajuste) cs_cant_ajustes from  vw_con_adjustment_gral a,tbl_fac_factura b where a.factura = b.codigo and a.compania = b.compania and b.facturar_a ='P' and a.tipo_ajuste not in (select xx.codigo from tbl_fac_tipo_ajuste xx where xx.compania =a.compania and xx.group_type in('E') ) and trunc(a.fecha_creacion) >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and trunc(a.fecha_creacion) <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') and a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.compania = ");
	sbSql.append(compId);
	sbSql.append(") a, (select distinct count(b.recibo) cf_cant_rec_x_pag from tbl_cja_transaccion_pago b where b.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and b.compania = ");
	sbSql.append(compId);
	sbSql.append("  and b.rec_status <> 'I' ) b, (select count(distinct na.nota_ajuste) cs_cant_ref_ajuste_rec from vw_con_adjustment_gral na where na.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and na.compania = ");
	sbSql.append(compId);
	sbSql.append(" and na.tipo_doc = 'R' and na.recibo is not null) c, (select count(codigo) cs_cant_rem from (select   'F' documento, r.numero_factura, r.admi_codigo_paciente, r.admi_fecha_nacimiento, to_char(r.codigo) codigo, to_char (r.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, r.monto_total, decode (tipo, '2', monto_total) db_rem, decode (tipo, '7', monto_total) cr_rem, r.compania from tbl_fac_remanente r where r.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and r.compania = ");
	sbSql.append(compId);
	sbSql.append(" and r.facturar_a = 'P' and r.fecha_creacion >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and trunc (r.fecha_creacion) <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') union select   'R' recibo, to_char (b.cod_rem), a.codigo_paciente, a.fecha_nacimiento, a.recibo codigo, to_char (a.fecha, 'dd/mm/yyyy') fecha, 0, 0, b.monto, a.compania from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.compania = ");
	sbSql.append(compId);
	sbSql.append(" and a.fecha >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and a.fecha <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') and b.cod_rem is not null and a.compania = b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion and a.rec_status <> 'I' )) d) x, (select nvl(a.cf_pagado, 0) cf_pagado, nvl(b.cs_sum_db_recibo, 0) cs_sum_db_recibo, nvl(b.cf_tajcr_res_rec, 0) cf_tajcr_res_rec, nvl(c.cf_gran_total_aplic, 0) cf_gran_total_aplic, (nvl(a.cf_pagado, 0) - nvl(b.cs_sum_db_recibo, 0) - nvl(c.cf_gran_total_aplic, 0) + nvl(b.cf_tajcr_res_rec, 0)) cf_credito_total from ( select sum(nvl(tp.pago_total,0)) cf_pagado from tbl_cja_transaccion_pago tp where tp.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and tp.compania = ");
	sbSql.append(compId);
	sbSql.append(" and tp.rec_status <> 'I') a, (select nvl(sum(decode(na.lado_mov, 'D', na.monto)),0) cs_sum_db_recibo, nvl(sum(decode(na.lado_mov,'C',decode(na.referencia,99,0,-na.monto))),0) cf_tajcr_res_rec from vw_con_adjustment_gral na,tbl_fac_tipo_ajuste y,tbl_cja_transaccion_pago ctp where na.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and na.compania = ");
	sbSql.append(compId);
	sbSql.append(" and ctp.recibo =na.recibo and ctp.compania = na.compania and ctp.pac_id = na.pac_id and ctp.rec_status <> 'I' and na.tipo_doc = 'R' and na.recibo is not null and na.tipo_ajuste = y.codigo and na.compania = y.compania and y.group_type in ('H','D') and na.factura is null ) b,( select nvl(sum(nvl(pa.monto,0)),0)  cf_gran_total_aplic from ( select sum(b.monto) monto from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b ,tbl_fac_factura f where f.fecha>= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and f.fecha <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') and (a.anio = b.tran_anio(+) and a.compania = b.compania(+) and a.codigo = b.codigo_transaccion(+)) and f.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and f.compania =");
	sbSql.append(compId);
	sbSql.append(" and b.cod_rem is null and rec_status <> 'I'  and f.facturar_a= 'P' and f.estatus <> 'A' and f.pac_id= a.pac_id and f.compania = a.compania and f.admi_secuencia= b.admi_secuencia union select sum(b.monto) monto from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.fecha >= to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy') and a.fecha <= to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy') and (a.anio = b.tran_anio(+) and a.compania = b.compania(+) and a.codigo = b.codigo_transaccion(+)) and a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.compania =");
	sbSql.append(compId);
	sbSql.append(" and b.cod_rem is not null and a.rec_status <> 'I' ) pa ) c ) z");

		CommonDataObject cdoTotalRGP = SQLMgr.getData(sbSql.toString());



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
	String title = "RESUMEN DE FACTURAS DEL PACIENTE";
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
				
				pc.addBorderCols("Paciente:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("nombre"), 0, 4, 0.0f, 0.0f, 0.0f, 0.0f);
				
				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("Id Pte:", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("pac_id"), 0, 3, 0.0f, 0.0f, 0.0f, 0.0f);

				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("Dirección:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("residencia_direccion"), 0, 4, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("Cédula:", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.setFont(headerFontSize, 0);
				pc.addBorderCols(cdoHeader.getColValue("cedula"), 0, 3, 0.0f, 0.0f, 0.0f, 0.0f);

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
				
				pc.setFont(headerFontSize, 1);
				pc.addBorderCols("# Documento", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Fecha", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("Descripción", 1, 2, 0.5f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols("# Adm.", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
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

	for (int i=0; i<al.size(); i++)
	{
		
		if (i == 0) pc.setTableHeader(4);
		pc.setFont(contentFontSize,0);
		
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(!cdo.getColValue("cod_factura").equals(cfa) && i!=0)
		{
			
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
						
		}
		/*if(!cdo.getColValue("cod_factura").equals(cfa)&& !cdo.getColValue("doc_type").equals("2"))
		{
			_monto = Double.parseDouble(cdo.getColValue("facturado"));
			_pagos = Double.parseDouble(cdo.getColValue("pago_app_fact"));
			_debit = Double.parseDouble(cdo.getColValue("debito"));
			_credit = Double.parseDouble(cdo.getColValue("credito"));
			//monto += Double.parseDouble(cdo.getColValue("facturado"));
		}*/
		/*if(cdo.getColValue("doc_type").equals("2"))
		{
			//monto += Double.parseDouble(cdo.getColValue("facturado"));
			pagos += Double.parseDouble(cdo.getColValue("pago_app_fact"));
			//debit += Double.parseDouble(cdo.getColValue("debito"));
			//credit += Double.parseDouble(cdo.getColValue("credito"));
		}*/
	
		if(cdo.getColValue("doc_type").equals("1")){
			pc.resetFont();
			pc.setFont(contentFontSize, 0);
		} else if(cdo.getColValue("doc_type").equals("2")){
			pc.resetFont();
			pc.setFont(contentFontSize, 0, Color.BLUE);
		} else if(cdo.getColValue("doc_type").equals("3")){
			pc.resetFont();
			pc.setFont(contentFontSize, 0, Color.RED);
		} else if(cdo.getColValue("doc_type").equals("4")){
			pc.resetFont();
			pc.setFont(contentFontSize, 0, Color.GREEN);
		}
		

		

		if(cdo.getColValue("doc_type").equals("1"))
		{
				pc.addBorderCols(cdo.getColValue("documento"), 1, 1, 0.0f, 0.5f, 0.5f, 0.0f);
				pc.addBorderCols(cdo.getColValue("fecha"), 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(cdo.getColValue("descripcion"), 0, 2, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("admision").equals("0"))?"":cdo.getColValue("admision"), 1, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("facturado").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("facturado")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("pago_app_fact").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("pago_app_fact")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("debito").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("debito")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("credito").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("credito")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("saldo").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")), 2, 1, 0.0f, 0.5f, 0.0f, 0.5f);
		} else {
				pc.addBorderCols(cdo.getColValue("documento"), 1, 1, 0.0f, 0.0f, 0.5f, 0.0f);
				pc.addBorderCols(cdo.getColValue("fecha"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols(cdo.getColValue("descripcion"), 0, 2, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("admision").equals("0"))?"":cdo.getColValue("admision"), 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("facturado").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("facturado")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("pago_app_fact").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("pago_app_fact")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("debito").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("debito")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("credito").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("credito")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols((cdo.getColValue("saldo").equals("0"))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")), 2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
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
			
			saldo = (_monto + _debit - _pagos - _credit);
				pc.addBorderCols("  ", 2, 9, 0.0f, 0.0f, 0.5f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo), 2, 1, 0.0f, 0.0f, 0.0f, 0.5f);

			
			pc.setFont(contentFontSize, 1);

				pc.addBorderCols("TOTALES EN FACTURAS", 2, 5, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("grang_total")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("pago_app_fact")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("debito")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("credito")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("saldo")), 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);

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


				pc.addBorderCols("TOTALES", 2, 7, 0.0f, 0.5f, 0.0f, 0.0f);
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
				pc.setFont(contentFontSize, 0, Color.GREEN);
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
				pc.addBorderCols("(*) Pagos contra Pre-Factura", 0, 5, 0.0f, 0.0f, 0.0f, 0.0f);
				pc.addBorderCols("", 0, 5, 0.5f, 0.0f, 0.5f, 0.5f);
/**/
				pc.resetFont();
				pc.setFont(contentFontSize, 0, Color.BLACK);
				pc.addBorderCols("", 2, 10, 0.0f, 0.0f, 0.0f, 0.0f);

	
	
	}





	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>