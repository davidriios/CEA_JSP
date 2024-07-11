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
F L A G   D E S C R I P C I O N                     R E P O R T E
													cja70001t.rdf
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al 		= new ArrayList();
ArrayList al2 	= new ArrayList();
ArrayList al3		= new ArrayList();
CommonDataObject cdoResp = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String  sql="";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String caja = request.getParameter("caja");
String turno = request.getParameter("turno");
String compania = request.getParameter("compania");
String fecha_ini = request.getParameter("fechaini");
String descCaja = request.getParameter("descCaja");
String descCajera = request.getParameter("descCajera");
String sqlResp = "";
String fg = request.getParameter("fg");
String fecha_fin = request.getParameter("fecha_fin");

if (appendFilter == null) appendFilter = "";
if (caja == null) caja = "";
if (turno == null) turno = "";
if (fg == null) fg = "";
if (fecha_fin == null) fecha_fin = "";
if (descCajera == null) descCajera = "";

if (!turno.equals(""))
{
		sqlResp = "select  decode(tc.cod_supervisor_cierra, null, 'Abierto por: '||ca.nombre, 'Abierto por: '||ca.nombre||' /  Cerrado por: '||cc.nombre) responsable  from tbl_cja_turnos tc, tbl_cja_cajera ca, tbl_cja_cajera cc  where tc.cod_supervisor_abre = ca.cod_cajera(+) and tc.compania = ca.compania(+) and tc.cod_supervisor_cierra = cc.cod_cajera(+) and tc.compania = cc.compania(+) and tc.codigo = "+turno+" and tc.compania ="+compania;
		cdoResp = SQLMgr.getData(sqlResp.toString());
}
sbSql.append(" select distinct /* paciente credito*/ ctp.recibo as reciboscr,to_char(ctp.fecha ,'dd/mm/yyyy') as fecha, t.descripcion||' - '||t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4 desc_tipo_clte, ctp.ref_id as codigo,0  secuencia, nvl((ctp.pago_total/*cdp.monto*/),0) pagos, nvl(decode(ctp.tipo_cliente,'O',(select sum(fcc.total) from tbl_fac_cargo_cliente fcc ,tbl_cja_detalle_pago cdp where fcc.compania = cdp.compania and fcc. num_factura= cdp.fac_codigo and fcc.tipo_transaccion = 'C'  and ctp.codigo = cdp.codigo_transaccion and ctp.compania = cdp.compania and ctp.anio = cdp.tran_anio       ),/*(select grang_total from tbl_fac_factura where compania = ctp.compania and codigo= cdp.fac_codigo and facturar_a = ctp.tipo_cliente)*/ 0),0) as monto, decode(ctp.tipo_cliente ,'P','C','E','E','O','B')  tipo,decode(ctp.tipo_cliente ,'P','CR','E','CR','O','OT') cc,ctp.compania ctp_cod,ctp.anio ctpanio,ctp.codigo ctpcodigo,'0' fac_codigo , decode(ctp.tipo_cliente ,'P',(select nombre_paciente from vw_adm_paciente where pac_id =ctp.pac_id),'E',(select nombre from tbl_adm_empresa where codigo = ctp.codigo_empresa),'O',decode(ctp.nombre_adicional,null,decode(ctp.nombre,null,(select fcc.cliente from tbl_fac_cargo_cliente fcc  ,tbl_cja_detalle_pago cdp  where fcc.compania = ctp.compania and fcc.num_factura= cdp.fac_codigo and fcc.tipo_transaccion = 'C'   and ctp.codigo = cdp.codigo_transaccion and ctp.compania = cdp.compania and ctp.anio = cdp.tran_anio    ),ctp.nombre),ctp.nombre_adicional)) as nombre ,'' as estado, '' rec_reemplazo, ctp.descripcion concepto from tbl_cja_transaccion_pago ctp, tbl_fac_tipo_cliente t,tbl_cja_turnos_x_cajas ct where ctp.compania = ");
 sbSql.append(compania);
 sbSql.append(" and ct.compania = ctp.compania  and ct.cod_turno = ctp.turno and ct.cod_caja = ctp.caja ");


if(fg.trim().equals("CONT"))
{
if(!fecha_ini.trim().equals("")){sbSql.append(" and trunc(ct.fecha_creacion) >= to_date('");
sbSql.append(fecha_ini);
sbSql.append("','dd/mm/yyyy')");
}
if(!fecha_fin.trim().equals("")){sbSql.append(" and trunc(ct.fecha_creacion) <= to_date('");
sbSql.append(fecha_fin);
sbSql.append("','dd/mm/yyyy')");
}
}
if (!caja.equals(""))
{
sbSql.append(" and ctp.caja = ");
sbSql.append(caja);
}
sbSql.append(" and t.codigo= ctp.ref_type  and t.compania=ctp.compania and nvl(ctp.cliente_alq,'N') <> 'S' and ( (ctp.rec_status ='A' and nvl(ctp.anulada,'N') ='N' ");
if (!turno.equals(""))
{
sbSql.append(" and ctp.turno = ");
sbSql.append(turno);
}
sbSql.append(" ) or (ctp.rec_status ='I' and ctp.turno_anulacion<>ctp.turno ");
if (!turno.equals(""))
{
sbSql.append(" and ctp.turno =");
sbSql.append(turno);
}
sbSql.append(" )) and  /*-para no mostrar reemplazos por recibo-*/ exists (select 'x' from tbl_cja_trans_forma_pagos cfp  where  ctp.codigo = cfp.tran_codigo  AND ctp.compania = cfp.compania AND ctp.anio = cfp.tran_anio  AND cfp.fp_codigo <> 0) and ctp.tipo_cliente in ('P','E','O')  and ctp.anio >= to_number(to_char(to_date('");
sbSql.append(fecha_ini);
sbSql.append("','dd/mm/yyyy'), 'yyyy')) ");

sbSql.append( "  union all select /*recibos anulados*/ distinct ctp.recibo,to_char(ctp.fecha_anulacion,'dd/mm/yyyy') as fecha, '' ,'0',ctp.anio,nvl(ctp.pago_total,0)  pagos, nvl(ctp.pago_total,0),'F','AN',ctp.compania ctpcompania,ctp.anio ctpanio,ctp.codigo ctpcodigo,'0',/*'RECIBO ANULADO'*/ ctp.nombre_adicional nombre,'' as estado, to_char(nvl(join(cursor( select c.rec_no  from tbl_cja_transaccion_pago c, tbl_cja_trans_forma_pagos f where c.anio = f.tran_anio  and c.codigo = f.tran_codigo and c.compania = f.compania  and fp_codigo=0  and c.compania =ctp.compania and f.no_referencia = to_char(ctp.rec_no)  ) ) ,''))  rec_reemplazo, ctp.descripcion concepto  from tbl_cja_transaccion_pago ctp ,tbl_cja_turnos_x_cajas ct where ctp.compania = ");
 sbSql.append(compania);
 sbSql.append(" and ct.compania = ctp.compania  and ct.cod_turno = ctp.turno and ct.cod_caja = ctp.caja ");
if(fg.trim().equals("CONT"))
{
if(!fecha_ini.trim().equals("")){sbSql.append(" and trunc(ct.fecha_creacion) >= to_date('");
sbSql.append(fecha_ini);
sbSql.append("','dd/mm/yyyy')");
}
if(!fecha_fin.trim().equals("")){sbSql.append(" and trunc(ct.fecha_creacion) <= to_date('");
sbSql.append(fecha_fin);
sbSql.append("','dd/mm/yyyy')");
}
}
if(!caja.trim().equals("")){
sbSql.append(" and ctp.caja= ");
sbSql.append(caja);
}
sbSql.append(" and ( ctp.rec_status='I' or nvl(ctp.anulada,'N') ='S') ");
if (!turno.equals(""))
{
sbSql.append(" and ( ctp.turno_anulacion = ");
sbSql.append(turno);
sbSql.append(" )");
}
sbSql.append( "union select distinct  /* cheques devueltos*/ ctp.recibo recibos_aj, to_char(fna.fecha,'dd/mm/yyyy') as fecha ,'',  to_char(ctp.codigo_paciente)   cod_pac_aj,ctp.anio,sum(cdis.monto) montoc_aj,0,'H','CD',0,0,0,cdp.fac_codigo  fact_aj,a.primer_nombre||' '||nvl(a.apellido_de_casada,a.primer_apellido||' '||a.segundo_apellido)as nombre,'CR' as estad, '' rec_reemplazo,  '' concepto  from tbl_cja_distribuir_pago cdis, tbl_cja_transaccion_pago ctp,tbl_cja_detalle_pago cdp,vw_con_adjustment_gral fna,tbl_fac_factura f,tbl_adm_paciente a,tbl_fac_tipo_ajuste ta where ctp.compania =  ");
sbSql.append(compania);
sbSql.append(" and nvl(ctp.cliente_alq,'N') <> 'S' and ctp.rec_status <> 'I' and fna.tipo_ajuste = ta.codigo and fna.compania = ta.compania and ta.group_type in('F') and fna.lado_mov='D' ");
if (!turno.equals(""))
{
sbSql.append("and  ctp.turno =  ");
sbSql.append(turno);
}
if (!caja.equals(""))
{
sbSql.append(" and ctp.caja = ");
sbSql.append(caja);
}
sbSql.append(" and ctp.anio >= to_number(to_char(to_date('");

sbSql.append(fecha_ini);
sbSql.append("','dd/mm/yyyy'),'yyyy')) and cdis.compania = cdp.compania and cdis.tran_anio = cdp.tran_anio and cdis.codigo_transaccion = cdp.codigo_transaccion and cdis.secuencia_pago = cdp.secuencia_pago and cdis.centro_servicio = fna.centro and ctp.compania = cdp.compania(+) and ctp.anio = cdp.tran_anio(+) and  ctp.codigo = cdp.codigo_transaccion(+) and fna.factura = cdp.fac_codigo and fna.compania = cdp.compania  and a.pac_id = ctp.pac_id and f.codigo = cdp.fac_codigo and f.compania = cdp.compania and f.pac_id=a.pac_id and f.admi_secuencia = cdp.admi_secuencia");
if(!fecha_ini.trim().equals("")){sbSql.append(" and trunc(fna.fecha) >= to_date('");
sbSql.append(fecha_ini);
sbSql.append("','dd/mm/yyyy')");
}

if(fg.trim().equals("CONT"))
{
if(!fecha_fin.trim().equals("")){sbSql.append(" and trunc(fna.fecha) <= to_date('");
sbSql.append(fecha_fin);
sbSql.append("','dd/mm/yyyy')");
}
}

sbSql.append(" group by ctp.recibo, to_char(fna.fecha,'dd/mm/yyyy') ,to_char(ctp.codigo_paciente)  ,ctp.compania ,ctp.anio,ctp.codigo,	cdp.fac_codigo,a.primer_nombre||' '||nvl(a.apellido_de_casada,a.primer_apellido||' '||a.segundo_apellido), 'CR','H','CD'");


sbSql.append( " union  select   /* alquiler */ ct.recibo recibo_alq,to_char(ct.fecha,'dd/mm/yyyy') fecha_alq,'', '0',0,nvl(ct.pago_total,0)pago_tot_alq,  nvl(sum(nvl(cd.desc_pronto_pago,0)),0),'G' tipo ,'AL' det,ct.num_contrato contrato_alq,0, ct.caja caja_alq,ct.ref_id num_cliente_alq,/* ct.codigo||'-'|| ct.anio tran_alq,*/ decode(fc.cliente,null,ct.nombre,fc.cliente) cliente_alq ,'' as estado, '' rec_reemplazo, '' concepto from tbl_fac_cargo_cliente fc, tbl_cja_transaccion_pago ct, tbl_cja_detalle_pago cd ,tbl_cja_turnos_x_cajas ctc where nvl( ct.cliente_alq,'N') = 'S'  and ct.tipo_cliente = 'O' and ct.compania =  ");
sbSql.append(compania);
 sbSql.append(" and ctc.compania = ct.compania  and ctc.cod_turno = ct.turno and ctc.cod_caja = ct.caja ");
if (!caja.equals(""))
{
sbSql.append(" and ct.caja = ");
sbSql.append(caja);
}
if (!turno.equals(""))
{
sbSql.append(" and ct.turno = ");
sbSql.append(turno);
}
if(fg.trim().equals("CONT"))
{
if(!fecha_ini.trim().equals("")){sbSql.append(" and trunc(ctc.fecha_creacion) >= to_date('");
sbSql.append(fecha_ini);
sbSql.append("','dd/mm/yyyy')");
}
if(!fecha_fin.trim().equals("")){sbSql.append(" and trunc(ctc.fecha_creacion) <= to_date('");
sbSql.append(fecha_fin);
sbSql.append("','dd/mm/yyyy')");
}
}


sbSql.append(" and fc.compania(+) = cd.compania and fc.num_factura(+) = cd.fac_codigo and ct.anio = cd.tran_anio(+) and ct.codigo = cd.codigo_transaccion(+) and ct.compania = cd.compania(+) and ct.rec_status <> 'I' ");
sbSql.append("  and  EXISTS  (SELECT 'x'  FROM tbl_cja_trans_forma_pagos cfp WHERE     cfp.tran_codigo = ct.codigo AND cfp.compania = ct.compania AND cfp.tran_anio = ct.anio AND cfp.fp_codigo <> 0) ");
sbSql.append(" group by  ct.recibo,to_char(ct.fecha,'dd/mm/yyyy'),  decode(fc.cliente,null,ct.nombre,fc.cliente) , ct.usuario_creacion ,ct.codigo||'-'|| ct.anio,ct.num_contrato ,   ct.ref_id, ct.caja, nvl(ct.pago_total,0),'','G','AL' order by 8,3,1");
al = SQLMgr.getDataList(sbSql.toString());



sql="select /***centros***/ 'DCC' as tipo, ctp.recibo recibos, nvl(sum(decode(ft.tipo_transaccion,'C', ( (fdt.monto+nvl(fdt.recargo,0))*fdt.cantidad))),0) - nvl(sum(decode(ft.tipo_transaccion,'D', ( (fdt.monto+nvl(fdt.recargo,0))*fdt.cantidad))),0) suma_cargos, de.descuento,0 itbm,ft.centro_servicio,ft.centro_servicio cod_centro,'' as cod_medico, 'C' tiposs,fdt.tipo_cargo as tipo_c_d,cd.descripcion,'' as cuentas,'' as descripcion_cta, ts.descripcion as tipo_servicio_cat,p.primer_nombre||' '||p.segundo_nombre||' '||p.primer_apellido||' '||p.segundo_apellido||' '||p.apellido_de_casada as  nombre_cliente,substr(e.nombre,1,20) as aseguradora,0 pagoTotal from tbl_cja_transaccion_pago ctp,tbl_cja_detalle_pago cdp,tbl_cja_distribuir_pago cdis,tbl_fac_transaccion ft,tbl_fac_detalle_transaccion fdt,tbl_adm_admision cc,tbl_cds_centro_servicio cd,tbl_cds_tipo_servicio ts,tbl_adm_paciente p,tbl_adm_empresa e,tbl_adm_admision ad,(select nvl(sum(fec.monto_clinica),0) as descuento,fec.admi_secuencia,fec.centro_servicio,fec.tipo_cargo, fec.pac_id from tbl_fac_estado_cargos fec where  fec.centro_servicio <> 0 group by fec.admi_secuencia,fec.centro_servicio,fec.tipo_cargo, fec.pac_id )de where ctp.compania ="+compania+" and ctp.tipo_cliente<>'E'and cdp.compania = ctp.compania and cdp.tran_anio = ctp.anio and cdp.codigo_transaccion = ctp.codigo and cc.secuencia = cdp.admi_secuencia and cc.pac_id = ctp.pac_id and cdis.compania = cdp.compania and cdis.tran_anio = cdp.tran_anio and cdis.codigo_transaccion = cdp.codigo_transaccion and cdis.secuencia_pago = cdp.secuencia_pago and ft.centro_servicio = cdis.centro_servicio and ft.centro_servicio<>0 and nvl(cdis.monto ,0)<> 0 /*and cc.conta_cred = 'C'*/ and fdt.compania = ft.compania and fdt.fac_codigo = ft.codigo and fdt.fac_secuencia = ft.admi_secuencia and fdt.pac_id =  ft.pac_id and fdt.tipo_transaccion = ft.tipo_transaccion and ft.admi_secuencia = cc.secuencia and ft.pac_id = cc.pac_id and ctp.turno="+turno+" and ctp.caja  = "+caja+" and cd.codigo=ft.centro_servicio and ts.codigo=fdt.tipo_cargo and ctp.pac_id = p.pac_id and de.admi_secuencia = cdp.admi_secuencia and de.pac_id = ctp.pac_id and de.centro_servicio = ft.centro_servicio and de.tipo_cargo= fdt.tipo_cargo and ctp.pac_id = ad.pac_id and ctp.pac_id = ad.pac_id and cdp.admi_secuencia = ad.secuencia and e.codigo = ad.aseguradora and ctp.rec_status <> 'I' group by 'DCC',ft.centro_servicio,fdt.tipo_cargo,ctp.recibo,'C',cd.descripcion,ts.descripcion ,p.primer_nombre||' '||p.segundo_nombre||' '||p.primer_apellido||' '||p.segundo_apellido||' '||p.apellido_de_casada ,de.descuento,0,'','' ,'',e.nombre";
sql += " union select /***medico***/ 'DCC' as tipo, ctp.recibo recibos, nvl(sum(decode(ft.tipo_transaccion,'H', ( (fdt.monto+nvl(fdt.recargo,0))*fdt.cantidad))),0) - nvl(sum(decode(ft.tipo_transaccion,'D', ( (fdt.monto+nvl(fdt.recargo,0))*fdt.cantidad))),0) suma_cargos, de.descuento,0,ft.centro_servicio,0,ft.med_codigo,'M',fdt.tipo_cargo as tipo_c_d,'HONORARIOS' as descripcion,'' as cuentas, '' as descripcion_cta, ts.descripcion as  tipo_servicio_cat, m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.segundo_apellido||' '||m.apellido_de_casada as nombre_cliente,' ',0 pagoTotal from tbl_cja_transaccion_pago ctp,tbl_cja_detalle_pago cdp,tbl_cja_distribuir_pago cdis,tbl_fac_transaccion ft,tbl_fac_detalle_transaccion fdt,tbl_adm_admision cc,tbl_adm_medico m,tbl_cds_tipo_servicio ts,(select nvl(sum(fec.monto_clinica),0) as descuento,fec.admi_secuencia,fec.centro_servicio,fec.tipo_cargo,fec.med_codigo, fec.pac_id from tbl_fac_estado_cargos fec group by fec.pac_id,fec.admi_secuencia ,fec.centro_servicio ,fec.tipo_cargo,fec.med_codigo) de where ctp.compania ="+compania+" and ctp.tipo_cliente<>'E' and cdp.compania = ctp.compania and cdp.tran_anio = ctp.anio and cdp.codigo_transaccion = ctp.codigo and cc.secuencia = cdp.admi_secuencia and cc.pac_id = ctp.pac_id and cdis.compania = cdp.compania and cdis.tran_anio = cdp.tran_anio and cdis.codigo_transaccion = cdp.codigo_transaccion and cdis.secuencia_pago = cdp.secuencia_pago and ft.med_codigo = cdis.med_codigo and ft.centro_servicio=0 and nvl(cdis.monto ,0)<> 0 /* and cc.conta_cred = 'C'*/ and fdt.compania = ft.compania and fdt.fac_codigo = ft.codigo and fdt.fac_secuencia = ft.admi_secuencia and fdt.pac_id = ft.pac_id and fdt.tipo_transaccion = ft.tipo_transaccion and ft.admi_secuencia = cc.secuencia and ft.pac_id = cc.pac_id and ft.med_codigo = m.codigo(+) and fdt.tipo_cargo = ts.codigo(+) and ctp.turno="+turno+" and ctp.caja  = "+caja+" and de.admi_secuencia = cdp.admi_secuencia and de.pac_id = ctp.pac_id and de.centro_servicio = ft.centro_servicio and de.tipo_cargo  = fdt.tipo_cargo and de.med_codigo = ft.med_codigo and ctp.rec_status <> 'I' group by ft.centro_servicio,fdt.tipo_cargo,ctp.recibo,ft.med_codigo,'M',fdt.tipo_cargo, m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.segundo_apellido||' '||m.apellido_de_casada,ts.descripcion ,'','',de.descuento,'DCC', 'HONORARIOS',0,0,''";
sql += " union select 'DCC' as tipo,ctp.recibo recibos, nvl(sum(decode(ft.tipo_transaccion,'H',( (fdt.monto+nvl(fdt.recargo,0))*fdt.cantidad))),0) - nvl(sum(decode(ft.tipo_transaccion,'D', ( (fdt.monto+nvl(fdt.recargo,0))*fdt.cantidad))),0) suma_cargos,de.descuento,0,ft.centro_servicio,ft.empre_codigo,'' as cod_medico,'E',fdt.tipo_cargo as tipo_c_d, '' as descripcion, '' as cuentas, '' as descripcion_cta,ts.descripcion as tipo_servicio_cat, e.nombre,'',0 pagoTotal from tbl_cja_transaccion_pago ctp, tbl_cja_detalle_pago cdp,tbl_cja_distribuir_pago cdis, tbl_fac_transaccion ft,tbl_fac_detalle_transaccion fdt,tbl_adm_admision cc,tbl_adm_empresa e,tbl_cds_tipo_servicio ts, (select nvl(sum(fec.monto_clinica),0) as descuento,fec.admi_secuencia,fec.centro_servicio,fec.tipo_cargo,fec.empre_codigo, fec.pac_id from tbl_fac_estado_cargos fec group by fec.pac_id ,fec.admi_secuencia,fec.centro_servicio,fec.tipo_cargo,fec.empre_codigo) de where ctp.compania ="+compania+" and ctp.tipo_cliente<>'E' and cdp.compania = ctp.compania and cdp.tran_anio = ctp.anio and cdp.codigo_transaccion = ctp.codigo and cc.secuencia = cdp.admi_secuencia and cc.pac_id = ctp.pac_id and cdis.compania = cdp.compania and cdis.tran_anio = cdp.tran_anio and cdis.codigo_transaccion = cdp.codigo_transaccion and cdis.secuencia_pago = cdp.secuencia_pago and ft.empre_codigo = cdis.empre_codigo and ft.centro_servicio=0 /*and cc.conta_cred = 'C'*/ and fdt.compania = ft.compania and fdt.fac_codigo = ft.codigo and fdt.fac_secuencia = ft.admi_secuencia and fdt.pac_id =  ft.pac_id and fdt.tipo_transaccion = ft.tipo_transaccion and ft.admi_secuencia = cc.secuencia and ft.pac_id = cc.pac_id and ft.empre_codigo = e.codigo(+) and fdt.tipo_cargo = ts.codigo(+) and ctp.turno="+turno+" and ctp.caja  = "+caja+" and de.admi_secuencia = cdp.admi_secuencia and de.pac_id = ctp.pac_id and de.centro_servicio = ft.centro_servicio and de.tipo_cargo = fdt.tipo_cargo and de.empre_codigo = ft.empre_codigo and ctp.rec_status <> 'I' group by  'DCC',ft.centro_servicio, fdt.tipo_cargo, ctp.recibo,ft.empre_codigo,'E',e.nombre, ts.descripcion ,'',de.descuento,'','','',''";
sql +=" union select 'DPO' as tipo,'' as cliente, sum(fd.monto*nvl(fd.cantidad,0)) as total, sum(nvl(fd.descuento,0)) tot_des, sum(nvl(fe.itbm,0)) itbm, foc.codigo as codigo, 0, '' as cod_medico,'O' as tiposs,to_char(nvl(fe.tipo_descuento,0)) as tipo_c_d,foc.descripcion descripcion, fcta.cta1||'-'||fcta.cta2||'-'||fcta.cta3||'-'||fcta.cta4||'-'||fcta.cta5||'-'||fcta.cta6 cuentas,'DESC' descripcion_cta,cg.descripcion as tipo_servicio_cat, td.descripcion as nombre_cliente,'' ,ctp.pago_total pagoTotal from tbl_cja_transaccion_pago ctp,tbl_cja_detalle_pago cdp,tbl_fac_cargo_cliente fe,tbl_fac_detc_cliente fd, tbl_fac_otros_cargos foc,tbl_fac_otros_x_cuenta fcta, tbl_con_catalogo_gral cg,tbl_fac_tipo_descuento td,tbl_fac_factura f where ctp.tipo_cliente = 'O' and ctp.compania ="+compania+" and ctp.caja = "+caja+" and ctp.turno="+turno+" and fd.tipo_detalle ='O' and (fe.cliente_alq <> 'S' or fe.cliente_alq is null) and f.codigo = cdp.fac_codigo and f.compania = cdp.compania and fd.compania = fe.compania and fd.compania = foc.compania and fd.anio = fe.anio and fd.cargo = fe.codigo and fd.tipo_transaccion = fe.tipo_transaccion and fd.cod_otro = foc.codigo and foc.codigo_tipo = fcta.codigo and foc.activo_inactivo = 'A' and foc.compania  = fcta.compania and cdp.compania = ctp.compania and cdp.tran_anio = ctp.anio and cdp.codigo_transaccion = ctp.codigo and cdp.fac_codigo = fe.num_factura and cdp.compania = fe.compania and fe.tipo_descuento = td.codigo(+) and fe.compania= td.compania(+) and fcta.cta1 = cg.cta1 and fcta.cta2 = cg.cta2 and fcta.cta3=cg.cta3 and fcta.cta4=cg.cta4 and fcta.cta5=cg.cta5 and fcta.cta6=cg.cta6 and fcta.compania = cg.compania and ctp.rec_status <> 'I' group by fcta.cta1,fcta.cta2,fcta.cta3,fcta.cta4,fcta.cta5,fcta.cta6, 'DESC',foc.codigo,foc.descripcion,nvl(fe.tipo_descuento,0),cg.descripcion ,td.descripcion ,'DPO','','',ctp.pago_total ";
sql += " union select /*informacion capturada los almacenes*/ 'DPO' as tipo, fe.cliente, sum((nvl(fd.monto,0)*nvl(fd.cantidad,0))+nvl(fd.monto_recargo,0))total, sum(nvl(fd.descuento,0)) tot_des,sum(nvl(fe.itbm,0))itbm,0,0,'' as cod_medico, 'DPO' as tiposs, to_char(nvl(fe.tipo_descuento,0)) as tipo_c_d, '' as descripcion, d.cta1||'-'||d.cta2||'-'||d.cta3||'-'||d.cta4||'-'||d.cta5||'-'||d.cta6  as cuenta,'DESC' descripcion_cta, cg.descripcion as catalogo_desc,td.descripcion as desc_tipo,fd.tipo_servicio,ctp.pago_total pagoTotal from tbl_cja_transaccion_pago ctp, tbl_fac_cargo_cliente fe, tbl_fac_detc_cliente fd,tbl_con_catalogo_gral cg,tbl_fac_tipo_descuento td,tbl_inv_almacen al,tbl_con_accdef d,tbl_cja_detalle_pago cdp ,tbl_fac_factura f  where ctp.tipo_cliente = 'O' and ctp.compania ="+compania+" and ctp.caja = "+caja+" and ctp.turno = "+turno+" and fd.tipo_detalle = 'I' and cdp.codigo_transaccion = ctp.codigo and cdp.tran_anio = ctp.anio and cdp.compania = ctp.compania and f.codigo = cdp.fac_codigo and f.compania = cdp.compania and fe.codigo = f.codigo_cargo and fe.tipo_transaccion = f.tipo_cargo and fe.anio = f.anio_cargo and fe.compania = f.compania  and fd.compania = fe.compania and fd.anio = fe.anio and fd.cargo = fe.codigo and fd.tipo_transaccion = fe.tipo_transaccion and fd.tipo_transaccion = 'C' and fe.tipo_descuento =td.codigo(+) and fe.compania = td.compania(+) and cg.cta1||'-'||cg.cta2||'-'||cg.cta3||'-'||cg.cta4||'-'||cg.cta5||'-'||cg.cta6=  d.cta1||'-'||d.cta2||'-'||d.cta3||'-'||d.cta4||'-'||d.cta5||'-'||d.cta6 and cg.compania =d.compania and fd.inv_almacen = al.codigo_almacen and fd.compania = al.compania and al.mapping_type ='T' and d.compania = al.compania  and d.service_type = fd.tipo_servicio and d.cds = -1 and d.ref_table ='TBL_INV_ALMACEN' and d.ref_pk = al.codigo_almacen and d.def_type ='R' and d.acctype_id = 4  and ctp.rec_status <> 'I' group by  0, cliente, d.cta1||'-'||d.cta2||'-'||d.cta3||'-'||d.cta4||'-'||d.cta5||'-'||d.cta6,  'DESC', fe.tipo_descuento,cg.descripcion,td.descripcion,'DPO','','',fd.tipo_servicio  ,ctp.pago_total  ";
sql += " union  select /*informacion capturada los almacenes*/ 'DPO' as tipo, fe.cliente, sum((nvl(fd.monto,0)*nvl(fd.cantidad,0))+nvl(fd.monto_recargo,0))total, sum(nvl(fd.descuento,0)) tot_des,sum(nvl(fe.itbm,0))itbm,0,0,'' as cod_medico, 'DPO' as tiposs, to_char(nvl(fe.tipo_descuento,0)) as tipo_c_d, '' as descripcion, d.cta1||'-'||d.cta2||'-'||d.cta3||'-'||d.cta4||'-'||d.cta5||'-'||d.cta6  as cuenta,'DESC' descripcion_cta, cg.descripcion as catalogo_desc,td.descripcion as desc_tipo,'',ctp.pago_total pagoTotal from tbl_cja_transaccion_pago ctp, tbl_fac_cargo_cliente fe, tbl_fac_detc_cliente fd,tbl_con_catalogo_gral cg,tbl_fac_tipo_descuento td,tbl_inv_almacen al,tbl_fac_tipo_cliente d ,tbl_cja_detalle_pago cdp ,tbl_fac_factura f where ctp.tipo_cliente = 'O' and ctp.compania = "+compania+" and ctp.caja = "+caja+" and ctp.turno = "+turno+" and fd.tipo_detalle = 'I'and cdp.codigo_transaccion = ctp.codigo and cdp.tran_anio = ctp.anio and cdp.compania = ctp.compania and f.codigo = cdp.fac_codigo and f.compania = cdp.compania and fe.codigo = f.codigo_cargo and fe.tipo_transaccion = f.tipo_cargo  and fe.anio = f.anio_cargo and fe.compania = f.compania and fd.compania = fe.compania and fd.anio = fe.anio and fd.cargo = fe.codigo and fd.tipo_transaccion = fe.tipo_transaccion and fd.tipo_transaccion = 'C' and fe.tipo_descuento =td.codigo(+) and fe.compania = td.compania(+) and cg.cta1||'-'||cg.cta2||'-'||cg.cta3||'-'||cg.cta4||'-'||cg.cta5||'-'||cg.cta6=  d.cta1||'-'||d.cta2||'-'||d.cta3||'-'||d.cta4||'-'||d.cta5||'-'||d.cta6  and cg.compania =d.compania  and fd.inv_almacen = al.codigo_almacen and fd.compania = al.compania and al.mapping_type ='C' /*and d.compania = al.compania*/ and d.compania = ctp.compania   and d.codigo = ctp.ref_type and ctp.rec_status <> 'I' group by  0, cliente, d.cta1||'-'||d.cta2||'-'||d.cta3||'-'||d.cta4||'-'||d.cta5||'-'||d.cta6,  'DESC', fe.tipo_descuento,cg.descripcion,td.descripcion,'DPO','','','',ctp.pago_total order by 1,12,6,2 asc " ;
//al2 = SQLMgr.getDataList(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam")+".pdf";

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
	int groupFontSize = 7;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "DETALLE DE PAGO EN CAJA";
	String subtitle = (!turno.equals(""))?"TURNO:   "+turno+"  DEL   "+fecha_ini:" DEL    "+fecha_ini+"    AL   "+fecha_fin;
	String xtraSubtitle = "";
	if (!turno.equals("")) xtraSubtitle = cdoResp.getColValue("responsable");
	else if(!descCajera.trim().equals("")) xtraSubtitle ="CAJER@:  "+descCajera;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".08");
		dHeader.addElement(".13");
		dHeader.addElement(".15");
		dHeader.addElement(".12");
		dHeader.addElement(".12");
		dHeader.addElement(".10");
		dHeader.addElement(".20");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	//pc.addBorderCols("",1);
	 pc.setTableHeader(1);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double monto_total = 0.00;
	double descuento    =0,  sub_total           =0,  distribuido         =0;
	double total_x_cargo  =0,  total_desc_x_cargo  =0,  total_neto_x_cargo  =0;
	double total_x_tipo   =0,  total_desc_x_tipo   =0,  total_neto_x_tipo   =0;
	double total_x_centro =0,  total_desc_x_centro  =0,  total_neto_x_centro =0;
	double total_x_cuenta =0,  total_desc_x_cuenta =0,  total_neto_x_cuenta =0;
	double neto=0,totalPagado =0.00;
	String tipo = "";
	String descripcion = "",centro = "", tipo_servicio="",cuentas="" ;
	int alquiler = 0;
	int recibos_al =0;

	for (int i=0; i<al.size(); i++)
	{
			CommonDataObject cdo1 = (CommonDataObject) al.get(i);

			if(!tipo.equals(cdo1.getColValue("tipo")+"-"+cdo1.getColValue("cc")+"-"+cdo1.getColValue("desc_tipo_clte")))
			{
				if(!tipo.trim().equals(""))
				{
					pc.setFont(groupFontSize, 1,Color.blue);
					pc.addCols("SUB-TOTAL . . . . . .",2,6);
					pc.addCols(""+CmnMgr.getFormattedDecimal(sub_total),2,1);

					if(alquiler > 0)
					{
						pc.addCols(""+CmnMgr.getFormattedDecimal(descuento),2,1);
						pc.addCols("Cantidad de Recibo de Alquileres --------------------------------->",2,5);
						pc.addCols(""+recibos_al,2,3);
						alquiler=0;
					}
					else pc.addCols(""+CmnMgr.getFormattedDecimal(distribuido),2,1);
					sub_total = 0.00;
					distribuido = 0.00;
					pc.setFont(groupFontSize, 0);
				}

			pc.setFont(groupFontSize, 1);
			if(cdo1.getColValue("tipo").trim().equals("A")&& cdo1.getColValue("cc").trim().equals("AP"))
			{
				pc.addCols("RECIBOS CON SALDO POR APLICAR",0,dHeader.size());
			}
			else if(cdo1.getColValue("tipo").trim().equals("B")&& cdo1.getColValue("cc").trim().equals("OT"))
			{
				pc.addCols("PAGOS A CARGOS OTROS",0,5);
				pc.addCols(cdo1.getColValue("desc_tipo_clte"),2,3);
			}
			else if((cdo1.getColValue("tipo").trim().equals("C") || cdo1.getColValue("tipo").trim().equals("E"))&& cdo1.getColValue("cc").trim().equals("CR"))
			{
				pc.addCols("PAGOS DE "+(cdo1.getColValue("tipo").trim().equals("E")?" EMPRESA ":" PACIENTE ")+" A ADMISIONES",0,5);
				pc.addCols(cdo1.getColValue("desc_tipo_clte"),2,3);
			}
			else if(cdo1.getColValue("tipo").trim().equals("D")&& cdo1.getColValue("cc").trim().equals("CO"))
			{
				pc.addCols("Pagos a admisiones Contado (Paciente)",0,5);
				pc.addCols(cdo1.getColValue("desc_tipo_cliente"),2,3);
				pc.addCols(" ",0,7);
				pc.addCols("Distribuido",2,1);
			}
			else if(cdo1.getColValue("tipo").trim().equals("F")&& cdo1.getColValue("cc").trim().equals("AN"))
			{
			pc.addCols("RECIBOS ANULADOS",0,dHeader.size());
			}
			else if(cdo1.getColValue("tipo").trim().equals("G")&& cdo1.getColValue("cc").trim().equals("AL"))
			{
				alquiler ++;
				pc.addCols("Detalle de Pagos a Cuentas de alquiler",0,dHeader.size());
			}
			else if(cdo1.getColValue("tipo").trim().equals("H")&& cdo1.getColValue("cc").trim().equals("CD"))
				pc.addCols("Cheques  Devueltos",0,dHeader.size());


			if(cdo1.getColValue("tipo").trim().equals("G")&& cdo1.getColValue("cc").trim().equals("AL") && alquiler==1)
				{
					pc.addCols("Recibo",0,1);
					pc.addCols("Fecha",0,1);
					pc.addCols("# Cliente",0,1);
					pc.addCols("Nombre Cliente",0,2);
					pc.addCols("Contrato",0,1);
					pc.addCols("Pago Total ",2,1);
					pc.addCols("Desc. PP",2,1);
				}
				else if(cdo1.getColValue("tipo").trim().equals("H")&& cdo1.getColValue("cc").trim().equals("CD"))//cheque devuelto
				{
					pc.addCols("Recibo",0,1);
					pc.addCols("Fecha Ajuste",0,1);
					pc.addCols("Nombre Cliente",0,4);
					pc.addCols("Monto de Pago",2,1);
					pc.addCols("Factura",2,1);
				} else if(cdo1.getColValue("tipo").trim().equals("F")&& cdo1.getColValue("cc").trim().equals("AN"))
				{
					pc.addBorderCols("Recibo No.",0,1);
					pc.addBorderCols("Fecha",0,1);
					pc.addBorderCols("Nombre Cliente",0,4);
					pc.addBorderCols("Monto",2,1);
					pc.addBorderCols("Recibo Reemplazo",1,1);
				}
				else
				{
					pc.addBorderCols("Recibo No.",1,1);
					pc.addBorderCols("Fecha",0,1);
					pc.addBorderCols("Nombre",0,2);
					pc.addBorderCols("Concepto Pago",0,2);
					pc.addBorderCols("Monto",1,1);
					pc.addBorderCols("",1,1);
				}
			}

							pc.setFont(groupFontSize, 0);
							if(!cdo1.getColValue("tipo").trim().equals("G") && !cdo1.getColValue("cc").trim().equals("AL"))
							{

							pc.addCols(" "+cdo1.getColValue("reciboscr"), 1,1);
							pc.addCols(" "+cdo1.getColValue("fecha"), 0,1);
							//pc.addCols(" "+cdo1.getColValue("fac_codigo"), 0,1);
							pc.addCols(" "+cdo1.getColValue("nombre"), 0,2);
							pc.addCols(" "+cdo1.getColValue("concepto"), 0,2);
							pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("pagos")), 2,1);

							if(cdo1.getColValue("tipo").trim().equals("B") && cdo1.getColValue("cc").trim().equals("OT") ){
								pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("monto")), 2,1);
								distribuido += Double.parseDouble(cdo1.getColValue("monto"));
							}
							else if(cdo1.getColValue("tipo").trim().equals("C")&& cdo1.getColValue("cc").trim().equals("CR"))
							{
								pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("monto")), 2,1);
								distribuido += Double.parseDouble(cdo1.getColValue("monto"));
							}
							else if(cdo1.getColValue("tipo").trim().equals("H")&& cdo1.getColValue("cc").trim().equals("CD"))//cheque devuelto
								pc.addCols(" "+cdo1.getColValue("fac_codigo"), 0,1);
							else if(cdo1.getColValue("tipo").trim().equals("F")&& cdo1.getColValue("cc").trim().equals("AN"))
								pc.addCols(" "+cdo1.getColValue("rec_reemplazo"), 0,1);
							else pc.addCols("", 2,1);

									sub_total   +=  Double.parseDouble(cdo1.getColValue("pagos"));
									if(!cdo1.getColValue("tipo").trim().equals("F")&&!cdo1.getColValue("cc").trim().equals("AN"))
									{
										monto_total +=  Double.parseDouble(cdo1.getColValue("pagos"));
									}
							}
							else
							{
									pc.addCols(""+cdo1.getColValue("reciboscr"),0,1);
									pc.addCols(""+cdo1.getColValue("fecha"),0,1);
									pc.addCols(""+cdo1.getColValue("fac_codigo"),0,1);
									pc.addCols(""+cdo1.getColValue("nombre"),0,2);
									pc.addCols(""+cdo1.getColValue("ctp_cod"),0,1);
									pc.addCols(""+cdo1.getColValue("pagos"),2,1);
									pc.addCols(""+cdo1.getColValue("monto"),2,1);

								monto_total +=  Double.parseDouble(cdo1.getColValue("pagos"));
								sub_total   +=  Double.parseDouble(cdo1.getColValue("pagos"));
								descuento   +=  Double.parseDouble(cdo1.getColValue("monto"));
								recibos_al ++;
							}
							tipo = cdo1.getColValue("tipo")+"-"+cdo1.getColValue("cc")+"-"+cdo1.getColValue("desc_tipo_clte");

	}

	pc.setFont(groupFontSize, 1,Color.blue);
	if (al.size() == 0 && al2.size()==0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		if (al.size() != 0) //pc.addCols("No existen registros",1,dHeader.size());
		{

			pc.addCols("SUB-TOTAL . . . . . .",2,6);
			pc.addCols(""+CmnMgr.getFormattedDecimal(sub_total),2,1);

			if(tipo.trim().equals("C-CR"))
				pc.addCols(""+CmnMgr.getFormattedDecimal(distribuido),2,1);
			else
			{//pc.addCols(" ",2,1);
				if(alquiler > 0)
				{
					pc.addCols(""+CmnMgr.getFormattedDecimal(descuento),2,1);
					pc.addCols("Cantidad de Recibo de Alquileres . . . . . . . . . . . . . . . . . . . . . . . ",2,5);
					pc.addCols(""+recibos_al,2,3);
					alquiler=0;
				}
				else pc.addCols("",2,1);
				sub_total = 0.00;
			}
			pc.setFont(groupFontSize, 1,Color.black);
			pc.addCols("",0,dHeader.size());
			pc.addCols("",0,dHeader.size());
			pc.addBorderCols("GRAN TOTAL RECAUDADO EN CAJA . . . . . . . . .",2,6,Color.lightGray);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(monto_total),1,2,Color.lightGray);
			pc.addCols("",0,dHeader.size());
			pc.addCols("",0,dHeader.size());
			pc.addCols("",0,dHeader.size());
			pc.setFont(groupFontSize, 0);
		}

		tipo = "";

		/*for (int x=0; x<al2.size(); x++)
			{
			CommonDataObject cdo1 = (CommonDataObject) al2.get(x);

		//if(!tipo.equals(cdo1.getColValue("tipo")))
		//{
			if(!tipo.trim().equals(""))
			{
				if(tipo.trim().equals("DCC"))//Credito
				{
					if(!tipo_servicio.trim().equals(cdo1.getColValue("centro_servicio")+"-"+cdo1.getColValue("tipo_c_d")))//tipo servicio x cds
					{
							pc.setFont(groupFontSize, 1,Color.blue);
							pc.addCols("Total x Cargo . . . . . . . . . . . . . . . . . . . :",2,4);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_x_cargo),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_desc_x_cargo),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_neto_x_cargo),2,1);
							pc.addCols("",2,1);
							total_x_cargo =0.00;
							total_desc_x_cargo =0.00;
							total_neto_x_cargo =0.00;

					}
					if(!centro.trim().equals(cdo1.getColValue("centro_servicio")))//if(!centro.trim().equals(""))
					{
							pc.addCols("Total x Centro . . . . . . . . . . . . . . . . . . . :",2,4);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_x_centro),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_desc_x_centro),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_neto_x_centro),2,1);
							pc.addCols("",2,1);

							total_x_centro =0.00;
							total_desc_x_centro =0.00;
							total_neto_x_centro =0.00;
					}
				}
				else if(tipo.trim().equals("DPO"))// pagos otros
				{
					if(!cuentas.trim().equals("")&& !cuentas.trim().equals(cdo1.getColValue("cuentas")))
					{
							pc.setFont(groupFontSize, 1,Color.blue);
							pc.addCols("Total x Cuenta . . . . . . . . . . . . . . . . . . . :",2,3);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_x_cuenta),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_desc_x_cuenta),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_neto_x_cuenta),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(totalPagado),2,1);

							pc.addCols("",2,1);

							total_x_cuenta =0.00;
							total_desc_x_cuenta =0.00;
							total_neto_x_cuenta =0.00;
							totalPagado =0.00;
							neto =0.00;

					 }
				}

			}

			if(!tipo.equals(cdo1.getColValue("tipo")))
			{


				if(!tipo.trim().equals(""))
				{
					pc.setFont(groupFontSize, 1,Color.blue);
					if(cdo1.getColValue("tipo").trim().equals("DPO"))
					pc.addCols("total final det. contado . . . . . . . . . . . . . . . . . . . :",2,4);
					else pc.addCols("Total final otros . . . . . . . . . . . . . . . . . . . :",2,4);
					pc.addCols(""+CmnMgr.getFormattedDecimal(total_x_tipo),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(total_desc_x_tipo),2,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(total_neto_x_tipo),2,1);
					pc.addCols("",2,1);
					total_x_tipo      = 0.00;
					total_desc_x_tipo = 0.00;
					total_neto_x_tipo = 0.00;
					neto = 0.00;
					pc.setFont(groupFontSize, 0);
				}

				if(cdo1.getColValue("tipo").trim().equals("DCC"))//DETALLE DE PAGOS A ADMISIONES CONTADO
				{	pc.setFont(groupFontSize, 0,Color.blue);pc.addBorderCols("DETALLE DE PAGOS A ADMISIONES",0,4); pc.setFont(groupFontSize, 0);}
				else{pc.addBorderCols("DETALLE DE PAGOS A OTROS CARGOS",0,3);}

					pc.addBorderCols("MONTO",2,1);
					pc.addBorderCols("DESCUENTO",2,1);
					pc.addBorderCols("NETO",2,1);
					if(cdo1.getColValue("tipo").trim().equals("DCC"))//DETALLE DE PAGOS A ADMISIONES CONTADO
					pc.addBorderCols("ASEG. ",0,1);
					else {pc.addBorderCols("M. PAGADO ",0,1); pc.addBorderCols("TIPO DESCUENTO ",0,1);}
			}//if tipo


			if(cdo1.getColValue("tipo").trim().equals("DCC"))
			{
				pc.setFont(groupFontSize, 0,Color.blue);
				if(!centro.trim().equals(cdo1.getColValue("centro_servicio")))
				{

					pc.addCols(""+cdo1.getColValue("centro_servicio"),0,1,Color.lightGray);
					pc.addCols(""+cdo1.getColValue("descripcion"),0,7,Color.lightGray);
				}

				if(!tipo_servicio.trim().equals(cdo1.getColValue("centro_servicio")+"-"+cdo1.getColValue("tipo_c_d")))
				{
					//pc.addCols(" ",0,1);
					pc.addCols(""+cdo1.getColValue("tipo_servicio_cat"),0,8);
				}//tipo_c_d


					neto=Double.parseDouble(cdo1.getColValue("suma_cargos"))-Double.parseDouble(cdo1.getColValue("descuento"));
					pc.setFont(groupFontSize, 0);
					pc.addCols(" "+cdo1.getColValue("recibos"), 1,1);
					pc.addCols(" "+cdo1.getColValue("nombre_cliente"), 0,3);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("suma_cargos")), 2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("descuento")), 2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(neto), 2,1);
					pc.addCols(" "+cdo1.getColValue("aseguradora"), 0,1);



					total_x_centro       +=  Double.parseDouble(cdo1.getColValue("suma_cargos"));
					total_desc_x_centro  +=  Double.parseDouble(cdo1.getColValue("descuento"));
					total_neto_x_centro  +=  neto;

					total_x_cargo        +=  Double.parseDouble(cdo1.getColValue("suma_cargos"));
					total_desc_x_cargo   +=  Double.parseDouble(cdo1.getColValue("descuento"));
					total_neto_x_cargo   +=  neto;

					total_x_tipo         +=  Double.parseDouble(cdo1.getColValue("suma_cargos"));
					total_desc_x_tipo    +=  Double.parseDouble(cdo1.getColValue("descuento"));
					total_neto_x_tipo    +=  neto;

					sub_total += total_neto_x_tipo;
			}//fin if tipo = DCC
			else if(cdo1.getColValue("tipo").trim().equals("DPO"))
			{
				pc.setFont(groupFontSize, 0,Color.blue);
				if(!cuentas.trim().equals(cdo1.getColValue("cuentas")))
				{
						pc.addCols(""+cdo1.getColValue("cuentas"),0,2);
						pc.addCols(""+cdo1.getColValue("tipo_servicio_cat"),0,4);
						pc.addCols(" ",0,2);
				}

					neto=Double.parseDouble(cdo1.getColValue("suma_cargos"))-Double.parseDouble(cdo1.getColValue("descuento"));
					pc.setFont(groupFontSize, 0);
					pc.addCols(" "+cdo1.getColValue("descripcion"), 0,3);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("suma_cargos")), 2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("descuento")), 2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(neto), 2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("pagoTotal")), 2,1);
					pc.addCols(" "+cdo1.getColValue("nombre_cliente"), 0,1);//nombre descuento
					//monto_total +=  Double.parseDouble(cdo1.getColValue("pagos"));
					total_x_cuenta        +=  Double.parseDouble(cdo1.getColValue("suma_cargos"));
					total_desc_x_cuenta   +=  Double.parseDouble(cdo1.getColValue("descuento"));
					total_neto_x_cuenta   +=  neto;

					total_x_tipo          +=  Double.parseDouble(cdo1.getColValue("suma_cargos"));
					total_desc_x_tipo     +=  Double.parseDouble(cdo1.getColValue("descuento"));
					total_neto_x_tipo     += neto;
					totalPagado           += Double.parseDouble(cdo1.getColValue("pagoTotal"));

			}
			tipo = cdo1.getColValue("tipo");
			tipo_servicio=cdo1.getColValue("centro_servicio")+"-"+cdo1.getColValue("tipo_c_d");
			centro=cdo1.getColValue("centro_servicio");
			cuentas=cdo1.getColValue("cuentas");

		}//end for
   */ //end for

				if(tipo.trim().equals("DCC"))//Credito
				{
					//tipo servicio x cds
						if(!tipo_servicio.trim().equals(""))
						{
							pc.setFont(groupFontSize, 1,Color.blue);
							pc.addCols("Total x Cargo . . . . . . . . . . . . . . . . . . . :",2,4);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_x_cargo),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_desc_x_cargo),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_neto_x_cargo),2,1);
							pc.addCols("",2,1);
							total_x_cargo =0.00;
							total_desc_x_cargo =0.00;
							total_neto_x_cargo =0.00;
						}
						if(!centro.trim().equals(""))
						{
							pc.addCols("Total x Centro . . . . . . . . . . . . . . . . . . . :",2,4);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_x_centro),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_desc_x_centro),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_neto_x_centro),2,1);
							pc.addCols("",2,1);

							total_x_centro =0.00;
							total_desc_x_centro =0.00;
							total_neto_x_centro =0.00;
						}
				}
				else if(tipo.trim().equals("DPO"))// pagos otros
				{
					if(!cuentas.trim().equals(""))
					{
							pc.setFont(groupFontSize, 1,Color.blue);
							pc.addCols("Total x Cuenta . . . . . . . . . . . . . . . . . . . :",2,3);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_x_cuenta),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_desc_x_cuenta),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(total_neto_x_cuenta),2,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(totalPagado),2,1);

							pc.addCols("",2,1);

							total_x_cuenta =0.00;
							total_desc_x_cuenta =0.00;
							total_neto_x_cuenta =0.00;
							neto =0.00;

					 }
				}

			pc.setFont(groupFontSize, 1,Color.blue);
			if(total_x_tipo != 0 || total_desc_x_tipo != 0 ){
			if(!tipo.trim().equals("DPO"))
			pc.addCols("TOTAL FINAL PAGADO A ADMISIONES . . . . . . . . . . . . . . . . . . . :",2,4);
			else pc.addCols("Total final otros . . . . . . . . . . . . . . . . . . . :",2,4);
			pc.addCols(""+CmnMgr.getFormattedDecimal(total_x_tipo),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(total_desc_x_tipo),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(total_x_tipo-total_desc_x_tipo),2,1);
			pc.addCols("",2,1);
			}


	}//if else al, al2
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>