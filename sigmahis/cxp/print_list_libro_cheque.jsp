<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
ArrayList alPm = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter2 = new StringBuffer();
StringBuffer sbFilter3 = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fechaini = request.getParameter("fDesde");
String fechafin = request.getParameter("fHasta");
String tipo = request.getParameter("tipo");
String estado = request.getParameter("estado");
String fg = request.getParameter("fg");
String comprobante = request.getParameter("pComprob");
String pAnio = request.getParameter("pAnio");
String pConsecutivo = request.getParameter("pConsecutivo");
String ordensal = request.getParameter("ordensal");
String usaPlanMedico = "N";
try { usaPlanMedico = java.util.ResourceBundle.getBundle("planmedico").getString("usaPlanMedico"); } catch (Exception ex) { }

if (appendFilter  == null) appendFilter  = "";
if (fechaini  == null) fechaini  = "";
if (fechafin  == null) fechafin  = "";
if (tipo  == null) tipo  = "";
if (estado  == null) estado  = "";
if (fg  == null) fg  = "";
if (comprobante  == null) comprobante  = "";
if (pAnio  == null) pAnio  = "";
if (pConsecutivo  == null) pConsecutivo  = "";
if (ordensal == null) ordensal = "DESC";

if(!tipo.trim().equals("")){appendFilter += " and ch.tipo_pago = "+tipo;}
if(!estado.trim().equals("")){appendFilter += " and ch.estado_cheque = '"+estado+"'";}

if(!comprobante.trim().equals("")){sbFilter2.append(" and comprobante='");sbFilter2.append(comprobante);sbFilter2.append("'");}
if(!pAnio.trim().equals("")){sbFilter2.append(" and anio_comprob=");sbFilter2.append(pAnio);}
if(!pConsecutivo.trim().equals("")){sbFilter2.append(" and consecutivo=");sbFilter2.append(pConsecutivo);}

if(!comprobante.trim().equals("")){sbFilter3.append(" and ch.comprobante_an='");sbFilter3.append(comprobante);sbFilter3.append("'");}
if(!pAnio.trim().equals("")){sbFilter3.append(" and ch.anio_comprob_an=");sbFilter3.append(pAnio);}
if(!pConsecutivo.trim().equals("")){sbFilter3.append(" and ch.consecutivo_an=");sbFilter3.append(pConsecutivo);}

if (usaPlanMedico.equalsIgnoreCase("S"))appendFilter += " and ch.tipo_orden not in(4)";

sbSql.append("select * from (select 1 orden, 'CR' lado_mov, dc.compania, dc.num_cheque, cb.cg_1_cta1 cta1, cb.cg_1_cta2 cta2, cb.cg_1_cta3 cta3, cb.cg_1_cta4 cta4, cb.cg_1_cta5 cta5, cb.cg_1_cta6 cta6, cb.descripcion, sum(dc.monto_renglon) monto_cr, 0 monto_db, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA') tipo_pago_desc, to_char(ch.f_emision, 'dd/mm/yyyy') fecha_docto, '' as no_doc ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania,bco.nombre descBanco,cb.descripcion descCuenta,ch.estado_cheque,'G' grupo from tbl_con_detalle_cheque dc, tbl_con_cheque ch, tbl_con_cuenta_bancaria cb, tbl_con_banco bco where dc.compania = ch.cod_compania and dc.cod_banco = ch.cod_banco and dc.cuenta_banco = ch.cuenta_banco and dc.num_cheque = ch.num_cheque and ch.cod_compania = cb.compania and ch.cod_banco = cb.cod_banco and ch.cuenta_banco = cb.cuenta_banco and bco.cod_banco = cb.cod_banco and bco.compania = cb.compania ");
	if(!fechaini.trim().equals("")){sbSql.append(" and trunc(ch.f_emision) >= to_date('");
	sbSql.append(fechaini);
	sbSql.append("','dd/mm/yyyy')");}
	if(!fechafin.trim().equals("")){sbSql.append(" and trunc(ch.f_emision) <= to_date('");
	sbSql.append(fechafin);
	sbSql.append("','dd/mm/yyyy')");}
	sbSql.append(appendFilter.toString());
 sbSql.append("  and ch.cod_compania = ");
 sbSql.append((String) session.getAttribute("_companyId"));
 sbSql.append(sbFilter2);

 sbSql.append(" group by 1, 'CR', dc.compania, dc.num_cheque, cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6, cb.descripcion,0, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA'), to_char(ch.f_emision, 'dd/mm/yyyy'), '' ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania,bco.nombre,cb.descripcion,ch.estado_cheque,'G'  /* DEBITOA*/               union all select 3.5, 'DBA' lado_mov, dc.compania, dc.num_cheque, cb.cg_1_cta1 cta1, cb.cg_1_cta2 cta2, cb.cg_1_cta3 cta3, cb.cg_1_cta4 cta4, cb.cg_1_cta5 cta5, cb.cg_1_cta6 cta6, cb.descripcion, 0 monto_cr, sum(nvl(dc.monto_renglon,0)) monto_db, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA') tipo_pago_desc, to_char(ch.f_anulacion, 'dd/mm/yyyy') fecha_docto,dc.num_factura  as no_doc ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania,nvl((select nombre from tbl_con_banco where cod_banco = ch.cod_banco and compania = ch.cod_compania),' ') descBanco,cb.descripcion descCuenta,ch.estado_cheque,'A' grupo from  tbl_con_detalle_cheque dc, tbl_con_cheque ch, tbl_con_cuenta_bancaria cb where dc.compania = ch.cod_compania and dc.cod_banco = ch.cod_banco and dc.cuenta_banco = ch.cuenta_banco and dc.num_cheque = ch.num_cheque and ch.cod_compania = cb.compania and ch.cod_banco = cb.cod_banco and ch.cuenta_banco = cb.cuenta_banco");
	if(!fechaini.trim().equals("")){sbSql.append(" and trunc(ch.f_anulacion) >= to_date('");
	sbSql.append(fechaini);
	sbSql.append("','dd/mm/yyyy')");}
	if(!fechafin.trim().equals("")){sbSql.append(" and trunc(ch.f_anulacion) <= to_date('");
	sbSql.append(fechafin);
	sbSql.append("','dd/mm/yyyy')");}
	sbSql.append(appendFilter.toString());
 sbSql.append("  and ch.cod_compania = ");
 sbSql.append((String) session.getAttribute("_companyId"));
 sbSql.append(sbFilter3);
 sbSql.append(" group by 3.5, 'DBA', dc.compania, dc.num_cheque, cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6, cb.descripcion,0, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA'), to_char(ch.f_anulacion, 'dd/mm/yyyy'),dc.num_factura,ch.cod_banco,ch.cuenta_banco,ch.cod_compania,cb.descripcion,ch.estado_cheque,'A'  union all select 2, 'DB' lado_mov, dc.compania, dc.num_cheque, dc.cuenta1 cta1, dc.cuenta2 cta2, dc.cuenta3 cta3, dc.cuenta4 cta4, dc.cuenta5 cta5, dc.cuenta6 cta6, cg.descripcion, 0 monto_cr, sum(dc.monto_renglon) monto_db, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA') tipo_pago_desc, to_char(ch.f_emision, 'dd/mm/yyyy') fecha_docto,dc.num_factura  as no_doc ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania,nvl((select nombre from tbl_con_banco where cod_banco = ch.cod_banco and compania = ch.cod_compania),' ') descBanco,cb.descripcion descCuenta,ch.estado_cheque,'G' grupo from tbl_con_detalle_cheque dc, tbl_con_cheque ch, tbl_con_catalogo_gral cg,tbl_con_cuenta_bancaria cb where dc.compania = ch.cod_compania and dc.cod_banco = ch.cod_banco and dc.cuenta_banco = ch.cuenta_banco and dc.num_cheque = ch.num_cheque and cg.compania = dc.compania and cg.cta1 = dc.cuenta1 and cg.cta2 = dc.cuenta2 and cg.cta3 = dc.cuenta3 and cg.cta4 = dc.cuenta4 and cg.cta5 = dc.cuenta5 and cg.cta6 = dc.cuenta6 and ch.cod_compania = cb.compania and ch.cod_banco = cb.cod_banco and ch.cuenta_banco = cb.cuenta_banco");
	if(!fechaini.trim().equals("")){sbSql.append(" and trunc(ch.f_emision) >= to_date('");
	sbSql.append(fechaini);
	sbSql.append("','dd/mm/yyyy')");}
	if(!fechafin.trim().equals("")){sbSql.append(" and trunc(ch.f_emision) <= to_date('");
	sbSql.append(fechafin);
	sbSql.append("','dd/mm/yyyy')");}
	sbSql.append(appendFilter.toString());
 sbSql.append(" and ch.cod_compania = ");
 sbSql.append((String) session.getAttribute("_companyId"));
 sbSql.append(sbFilter2);
 sbSql.append("  group by 2, dc.num_renglon,'DB', dc.compania, dc.num_cheque, dc.cuenta1, dc.cuenta2, dc.cuenta3, dc.cuenta4, dc.cuenta5, dc.cuenta6, cg.descripcion, 0, dc.monto_renglon, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA'), to_char(ch.f_emision, 'dd/mm/yyyy'),dc.num_factura ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania,cb.descripcion,ch.estado_cheque,'G'   UNION all select 4.5, 'CRA' lado_mov, dc.compania, dc.num_cheque, dc.cuenta1 cta1, dc.cuenta2 cta2, dc.cuenta3 cta3, dc.cuenta4 cta4, dc.cuenta5 cta5, dc.cuenta6 cta6, cg.descripcion, sum(dc.monto_renglon) monto_cr, 0 monto_db, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA') tipo_pago_desc, to_char(ch.f_anulacion, 'dd/mm/yyyy') fecha_docto, ''  as no_doc ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania,nvl((select nombre from tbl_con_banco where cod_banco = ch.cod_banco and compania = ch.cod_compania),' ')descBanco,cb.descripcion descCuenta,ch.estado_cheque,'A' grupo from tbl_con_detalle_cheque dc, tbl_con_cheque ch, tbl_con_catalogo_gral cg,tbl_con_cuenta_bancaria cb where dc.compania = ch.cod_compania and dc.cod_banco = ch.cod_banco and dc.cuenta_banco = ch.cuenta_banco and dc.num_cheque = ch.num_cheque and cg.cta1 = dc.cuenta1 and cg.cta2 = dc.cuenta2 and cg.cta3 = dc.cuenta3 and cg.cta4 = dc.cuenta4 and cg.cta5 = dc.cuenta5 and cg.cta6 = dc.cuenta6 and cg.compania = dc.compania and ch.cod_compania = cb.compania and ch.cod_banco = cb.cod_banco and ch.cuenta_banco = cb.cuenta_banco");
	if(!fechaini.trim().equals("")){sbSql.append(" and trunc(ch.f_anulacion) >= to_date('");
	sbSql.append(fechaini);
	sbSql.append("','dd/mm/yyyy')");}
	if(!fechafin.trim().equals("")){sbSql.append(" and trunc(ch.f_anulacion) <= to_date('");
	sbSql.append(fechafin);
	sbSql.append("','dd/mm/yyyy')");}
	sbSql.append(appendFilter.toString());
 sbSql.append("   and ch.cod_compania = ");
 sbSql.append((String) session.getAttribute("_companyId"));
 sbSql.append(sbFilter3);
 sbSql.append(" group by 4.5, 'CRA', dc.compania, dc.num_cheque, dc.cuenta1, dc.cuenta2, dc.cuenta3, dc.cuenta4, dc.cuenta5, dc.cuenta6, cg.descripcion, dc.monto_renglon, 0, ch.beneficiario, ch.tipo_pago, decode(ch.tipo_pago, 1, 'CHEQUE', 2, 'ACH', 3, 'TRANSFERENCIA'), to_char(ch.f_anulacion, 'dd/mm/yyyy'), '' ,ch.cod_banco,ch.cuenta_banco,ch.cod_compania,cb.descripcion,ch.estado_cheque,'A') aa ");

 if (ordensal.trim().equals("DESC")) {
			sbSql.append(" order by 25 desc,19,20,decode(substr(aa.num_cheque,1,1), 'T',to_number( 0||substr(aa.num_cheque,2,11)), 'A',to_number( 0||substr(aa.num_cheque,2,11)), to_number(aa.num_cheque)) desc,5,6,7,8,9,10,1");
		}
		else {
			sbSql.append(" order by 25 desc,19,20,decode(substr(aa.num_cheque,1,1), 'T',to_number( 0||substr(aa.num_cheque,2,11)), 'A',to_number( 0||substr(aa.num_cheque,2,11)), to_number(aa.num_cheque)) asc,5,6,7,8,9,10,1 ");
		}



al = SQLMgr.getDataList(sbSql.toString());
if (usaPlanMedico.equalsIgnoreCase("S"))alPm = SQLMgr.getDataList((sbSql.toString()).replace("not",""));
sbSql = new StringBuffer();
appendFilter ="";
if(!fechaini.equals("")) appendFilter += " and trunc(mb.f_movimiento)>= to_date('"+fechaini+"', 'dd/mm/yyyy')";
if(!fechafin.equals("")) appendFilter += " and trunc(mb.f_movimiento)<= to_date('"+fechafin+"', 'dd/mm/yyyy')";

//Depositos desde Banco
sbSql.append("select  mb.num_documento,1 orden,mb.f_movimiento,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy')f_doc, mb.caja,mb.compania,mb.usuario_creacion, mb.turno,cb.cg_1_cta1 as cta1, cb.cg_1_cta2 as cta2,cb.cg_1_cta3 as cta3,cb.cg_1_cta4 as cta4,cb.cg_1_cta5 as cta5,cb.cg_1_cta6 as cta6,sum (nvl (mb.monto, 0)) debito,0 as credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6 cuenta,( select descripcion from tbl_con_catalogo_gral where cta1||'.'||cta2||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6 = cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6 and compania =mb.compania) descCatalogo from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString());
sbSql.append(sbFilter2);
sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans <> 'A' and mb.tipo_movimiento in(select column_value from table( select split((get_sec_comp_param(mb.compania,'CJA_TP_MOV_DEP')),',') from dual)) and mb.caja is null and mb.turno is null and nvl(mb.dep_conta,'X') <> 'S' having sum (nvl (mb.monto, 0)) > 0 group by mb.caja,mb.usuario_creacion,mb.turno,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento, mb.compania,cb.cg_1_cta1,cb.cg_1_cta2,cb.cg_1_cta3,cb.cg_1_cta4,cb.cg_1_cta5,cb.cg_1_cta6,mb.num_documento,mb.tipo_movimiento,cb.descripcion,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6");
sbSql.append("  union all ");//CONTRA CUENTA DE DEPOSITOS
sbSql.append(" select  mb.num_documento,1.5 orden,mb.f_movimiento, mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy')f_movimiento,mb.caja,mb.compania,mb.usuario_creacion,mb.turno,nvl(mb.cta1,getCta(mb.compania,'CTA_BAN_DEPOSITOS',1)) as cta1,nvl(mb.cta2,getCta(mb.compania,'CTA_BAN_DEPOSITOS',2))as cta2,nvl(mb.cta3,getCta(mb.compania,'CTA_BAN_DEPOSITOS',3)) as cta3,nvl(mb.cta4,getCta(mb.compania,'CTA_BAN_DEPOSITOS',4)) as cta4,nvl(mb.cta5,getCta(mb.compania,'CTA_BAN_DEPOSITOS',5)) as cta5,nvl(mb.cta6,getCta(mb.compania,'CTA_BAN_DEPOSITOS',6)) as cta6 ,0 debito,sum (nvl (mb.monto, 0)) credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco,nvl(get_sec_comp_param(mb.compania,'CTA_BAN_DEPOSITOS'),' ') cuenta,( select descripcion from tbl_con_catalogo_gral where cta1||'.'||cta2||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6 = decode(mb.cta1, null, nvl(get_sec_comp_param(mb.compania,'CTA_BAN_DEPOSITOS'),' '),mb.cta1||'.'||mb.cta2||'.'||mb.cta3||'.'||mb.cta4||'.'||mb.cta5||'.'||mb.cta6 ) and compania =mb.compania) descCatalogo from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb  where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString());
sbSql.append(sbFilter2);
sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans <> 'A' and mb.tipo_movimiento in(select column_value from table( select split((get_sec_comp_param(mb.compania,'CJA_TP_MOV_DEP')),',') from dual)) and mb.caja is null and mb.turno is null and nvl(mb.dep_conta,'X') <> 'S' having   sum (nvl (mb.monto, 0)) > 0 group by   mb.cta1||'.'||mb.cta2||'.'||mb.cta3||'.'||mb.cta4||'.'||mb.cta5||'.'||mb.cta6,mb.cta1,mb.cta2,mb.cta3,mb.cta4,mb.cta5,mb.cta6, mb.caja,mb.usuario_creacion,mb.turno, mb.cuenta_banco,mb.banco, to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento, mb.compania, mb.num_documento, mb.tipo_movimiento,cb.descripcion ");
sbSql.append(" union  all ");//NOTAS DE CREDITO CUENTA DE BANCO
sbSql.append(" select  mb.num_documento,2 orden,mb.f_movimiento, mb.cuenta_banco,mb.banco, to_char(mb.f_movimiento,'dd/mm/yyyy')f_movimiento, mb.caja,mb.compania, mb.usuario_creacion,mb.turno,cb.cg_1_cta1,cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6,decode(tm.lado_transac,'DB', sum(nvl (mb.monto, 0)),0) debito, decode(tm.lado_transac,'CR', sum (nvl (mb.monto, 0)),0) credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6 cuenta,( select descripcion from tbl_con_catalogo_gral where cta1||'.'||cta2||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6 = cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6 and compania =mb.compania) descCatalogo from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb, tbl_con_tipo_nota_cr_db t,tbl_con_tipo_movimiento tm  where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString());
sbSql.append(sbFilter2);
sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans <> 'A' and mb.notas_credito = t.codigo and mb.compania = t.compania and mb.tipo_movimiento = '2' and mb.tipo_movimiento=tm.cod_transac and nvl(mb.nuevo_proc,'N') ='N' group by  tm.lado_transac ,mb.caja,mb.usuario_creacion,mb.turno, mb.cuenta_banco,mb.banco, to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento, mb.compania,mb.num_documento ,mb.tipo_movimiento, cb.descripcion,cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6,t.tipo_mov,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6");
sbSql.append(" union all ");//NOTAS DE CREDITO CONTRACUENTA
sbSql.append(" select  mb.num_documento,2.5 orden,mb.f_movimiento,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy')f_movimiento,mb.caja,mb.compania,mb.usuario_creacion,mb.turno,t.cta1, t.cta2, t.cta3, t.cta4, t.cta5, t.cta6,decode(tm.lado_transac,'CR', sum(nvl (mb.monto, 0)),0) debito,decode(tm.lado_transac,'DB', sum (nvl (mb.monto, 0)),0) credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco,t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4||'.'||t.cta5||'.'||t.cta6 cuenta,( select descripcion from tbl_con_catalogo_gral where cta1||'.'||cta2||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6 = t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4||'.'||t.cta5||'.'||t.cta6 and compania =mb.compania) descCatalogo from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb, tbl_con_tipo_nota_cr_db t,tbl_con_tipo_movimiento tm where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString());
sbSql.append(sbFilter2);
sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans <> 'A' and mb.notas_credito = t.codigo and mb.compania = t.compania and mb.tipo_movimiento = '2' and mb.tipo_movimiento=tm.cod_transac and nvl(mb.nuevo_proc,'N') ='N' group by  tm.lado_transac ,mb.caja,mb.usuario_creacion,mb.turno,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento,mb.compania,mb.num_documento,mb.tipo_movimiento,cb.descripcion,t.cta1, t.cta2, t.cta3, t.cta4, t.cta5, t.cta6,t.tipo_mov ,t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4||'.'||t.cta5||'.'||t.cta6 ");
sbSql.append(" union all ");//NOTAS DE DEBITO CUENTA DE BANCO
sbSql.append(" select  mb.num_documento,3 orden,mb.f_movimiento,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy')f_movimiento, mb.caja,mb.compania,mb.usuario_creacion,mb.turno,cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6,decode(tm.lado_transac,'DB', sum(nvl (mb.monto, 0)),0) debito,decode(tm.lado_transac,'CR', sum (nvl (mb.monto, 0)),0) credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco ,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6 cuenta,( select descripcion from tbl_con_catalogo_gral where cta1||'.'||cta2||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6 = cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6 and compania =mb.compania) descCatalogo from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb, tbl_con_tipo_nota_cr_db t,tbl_con_tipo_movimiento tm where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString());
sbSql.append(sbFilter2);
sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans <> 'A' and mb.notas_debito = t.codigo and mb.compania = t.compania  and mb.tipo_movimiento = '3' and mb.tipo_movimiento=tm.cod_transac and nvl(mb.nuevo_proc,'N') ='N' group by  tm.lado_transac,mb.caja,mb.usuario_creacion,mb.turno,mb.cuenta_banco,mb.banco, to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento, mb.compania,mb.num_documento, mb.tipo_movimiento, cb.cg_1_cta1, cb.cg_1_cta2, cb.cg_1_cta3, cb.cg_1_cta4, cb.cg_1_cta5, cb.cg_1_cta6,t.tipo_mov,cb.cg_1_cta1||'.'||cb.cg_1_cta2||'.'||cb.cg_1_cta3||'.'||cb.cg_1_cta4||'.'||cb.cg_1_cta5||'.'||cb.cg_1_cta6,cb.descripcion ");
sbSql.append(" union all  ");//NOTAS DE DEBITO CONTRACUENTA
sbSql.append(" select  mb.num_documento,3.5 orden,mb.f_movimiento,mb.cuenta_banco,mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy') f_movimiento,mb.caja, mb.compania,mb.usuario_creacion,mb.turno,t.cta1, t.cta2, t.cta3, t.cta4, t.cta5, t.cta6,decode(tm.lado_transac,'CR', sum(nvl (mb.monto, 0)),0) debito,decode(tm.lado_transac,'DB', sum (nvl (mb.monto, 0)),0) credito,(select descripcion from tbl_con_tipo_movimiento where cod_transac=mb.tipo_movimiento)descmov,cb.descripcion descCuenta,  nvl((select nombre from tbl_con_banco where cod_banco = mb.banco and compania = mb.compania),' ')descBanco ,t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4||'.'||t.cta5||'.'||t.cta6 cuenta ,( select descripcion from tbl_con_catalogo_gral where cta1||'.'||cta2||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6 = t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4||'.'||t.cta5||'.'||t.cta6 and compania =mb.compania) descCatalogo from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb, tbl_con_tipo_nota_cr_db t,tbl_con_tipo_movimiento tm  where mb.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter.toString());
sbSql.append(sbFilter2);
sbSql.append(" and cb.cuenta_banco = mb.cuenta_banco and cb.cod_banco = mb.banco and cb.compania = mb.compania and mb.estado_trans <> 'A' and mb.notas_debito = t.codigo and mb.compania = t.compania and mb.tipo_movimiento = '3' and mb.tipo_movimiento=tm.cod_transac and nvl(mb.nuevo_proc,'N') ='N' group by tm.lado_transac,  mb.caja,mb.usuario_creacion, mb.turno,mb.cuenta_banco, mb.banco,to_char(mb.f_movimiento,'dd/mm/yyyy'),mb.f_movimiento,mb.compania,mb.num_documento,mb.tipo_movimiento,cb.descripcion,t.cta1, t.cta2, t.cta3, t.cta4, t.cta5, t.cta6,t.tipo_mov,t.cta1||'.'||t.cta2||'.'||t.cta3||'.'||t.cta4||'.'||t.cta5||'.'||t.cta6 order by 5,4,1,2,3 asc ");
if(!fg.trim().equals("CSCXP"))al2 = SQLMgr.getDataList(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;

	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONTABILIDAD";
	String subtitle = "LIBRO DE CHEQUES";
	String xtraSubtitle = "DEL  "+fechaini+"   AL   "+fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();

			dHeader.addElement(".10");
			dHeader.addElement(".22");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".32");
			dHeader.addElement(".10");
			dHeader.addElement(".10");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(8, 1);

			pc.addBorderCols("TIPO DOC.",0);
			pc.addBorderCols("BENEFICIARIO",1);
			pc.addBorderCols("No. FACT.",1);
			pc.addBorderCols("FECHA",1);
			pc.addBorderCols("CUENTA",1);
			pc.addBorderCols("DEBITO",1);
			pc.addBorderCols("CREDITO",0);
			pc.addCols("",1,dHeader.size());
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "",groupBy2="",groupBy3="",anulacion="";
	double totalDb = 0.00, totalCr = 0.00,totDbCheques=0.00,totCrCheques=0.00;
	double saldo = 0.00,totalDbBanco= 0.00,totalCrBanco = 0.00,totDbBanco= 0.00,totCrBanco = 0.00,totalDbCta = 0.00, totalCrCta = 0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(cdo.getColValue("orden").trim().equals("3.5")||cdo.getColValue("orden").trim().equals("4.5")){anulacion="S";}

		if(!groupBy.trim().equals(cdo.getColValue("cod_banco")+"-"+cdo.getColValue("cuenta_banco")+"-"+cdo.getColValue("grupo")))
		{	pc.setFont(8, 1,Color.blue);
			if(i!=0)
			{
				pc.addCols("TOTAL POR BANCO Y CUENTA : ",1,5);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDbCta),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCrCta),2,1);

				totalDbCta = 0.00;
				totalCrCta = 0.00;
			}

			if(!groupBy2.trim().equals(cdo.getColValue("cod_banco")))
			{	pc.setFont(8, 1);
				if(i!=0)
				{
					pc.addCols("TOTAL POR BANCO : ",1,5);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totDbBanco),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totCrBanco),2,1);
					totDbBanco = 0.00;
					totCrBanco = 0.00;
				}

				if(i!=0)pc.addCols(" ",1,dHeader.size());
			}
			if(i==0&&cdo.getColValue("grupo").trim().equals("G"))
			{
				pc.setFont(8, 1,Color.blue);
				pc.addCols("PAGOS REALIZADOS POR BANCOS ",0,dHeader.size());
			}

			pc.setFont(8, 1,Color.blue);
			pc.addCols("BANCO: ",1,1);
			pc.addCols(""+cdo.getColValue("descBanco"),0,3);
			pc.addCols("CUENTA BANCARIA: "+cdo.getColValue("descCuenta"),0,4);
			if(i!=0)pc.addCols(" ",1,dHeader.size());
		}
		//if(cdo.getColValue("descCuenta").trim().equals("3.5")||cdo.getColValue("descCuenta").trim().equals("4.5"))

			pc.setFont(7, 1);
			if(anulacion.trim().equals("S")&&!groupBy3.trim().equals(cdo.getColValue("grupo"))){pc.setFont(7, 1,Color.red);	pc.addCols("PAGOS [ANULADOS] ",0,dHeader.size());anulacion="";}
			if(cdo.getColValue("estado_cheque").trim().equals("A")&&!cdo.getColValue("grupo").trim().equals("A"))pc.setFont(7, 1,Color.red);
			else pc.setFont(7, 1);
			//pc.addCols(" AN=="+cdo.getColValue("tipo_pago_desc")+" [ "+cdo.getColValue("num_cheque")+" ]",0,1);
			pc.addCols(" "+cdo.getColValue("tipo_pago_desc")+" [ "+cdo.getColValue("num_cheque")+" ]",0,1);
			pc.addCols(" "+cdo.getColValue("beneficiario"),0,1);
			pc.addCols(" "+cdo.getColValue("no_doc"),1,1);
			pc.addCols(" "+cdo.getColValue("fecha_docto"),1,1);
			pc.addCols(" "+cdo.getColValue("cta1")+"."+cdo.getColValue("cta2")+"."+cdo.getColValue("cta3")+"."+cdo.getColValue("cta4")+"."+cdo.getColValue("cta5")+"."+cdo.getColValue("cta6")+" - "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_db")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cr")),2,1);

		   totalDb += Double.parseDouble(cdo.getColValue("monto_db"));
		   totalCr += Double.parseDouble(cdo.getColValue("monto_cr"));
		   totalDbCta += Double.parseDouble(cdo.getColValue("monto_db"));
		   totalCrCta += Double.parseDouble(cdo.getColValue("monto_cr"));
		   totDbBanco += Double.parseDouble(cdo.getColValue("monto_db"));
		   totCrBanco += Double.parseDouble(cdo.getColValue("monto_cr"));
		   totDbCheques += Double.parseDouble(cdo.getColValue("monto_db"));
		   totCrCheques += Double.parseDouble(cdo.getColValue("monto_cr"));

			groupBy = cdo.getColValue("cod_banco")+"-"+cdo.getColValue("cuenta_banco")+"-"+cdo.getColValue("grupo");
			groupBy2 =cdo.getColValue("cod_banco");
			groupBy3 =cdo.getColValue("grupo");

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}

		if(al.size() != 0)
		{
			pc.setFont(8, 1,Color.blue);
			pc.addCols(" ",1,dHeader.size());
			pc.addCols("TOTAL POR BANCO Y CUENTA : ",1,5);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDbCta),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCrCta),2,1);

			pc.addCols(" ",1,dHeader.size());
			pc.addCols("TOTAL POR BANCO : ",1,5);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totDbBanco),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totCrBanco),2,1);

			pc.addCols(" ",1,dHeader.size());

		}
	pc.setFont(8, 1,Color.blue);

			pc.addCols("TOTAL TRX CHEQUES : ",1,5);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totDbCheques),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totCrCheques),2,1);

			pc.addCols(" ",1,dHeader.size());

			//========================================================================
	if (usaPlanMedico.equalsIgnoreCase("S")) {
	pc.addCols(" ",1,dHeader.size());
	pc.addCols("",0,dHeader.size());
	pc.addCols("TRANSACCIONES PLAN MEDICO ",1,dHeader.size());
	groupBy="";
	totalDbCta=0.00;
	totalCrCta=0.00;
	totDbBanco = 0.00;
	totCrBanco = 0.00;
	totDbBanco = 0.00;
	totCrBanco = 0.00;
    groupBy2 ="";anulacion="";
	groupBy3 ="";
	totDbCheques =0.00;totCrCheques=0.00;

	for (int i=0; i<alPm.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alPm.get(i);

		if(cdo.getColValue("orden").trim().equals("3.5")||cdo.getColValue("orden").trim().equals("4.5")){anulacion="S";}

		if(!groupBy.trim().equals(cdo.getColValue("cod_banco")+"-"+cdo.getColValue("cuenta_banco")+"-"+cdo.getColValue("grupo")))
		{	pc.setFont(8, 1,Color.blue);
			if(i!=0)
			{
				pc.addCols("TOTAL POR BANCO Y CUENTA : ",1,5);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDbCta),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCrCta),2,1);

				totalDbCta = 0.00;
				totalCrCta = 0.00;
			}

			if(!groupBy2.trim().equals(cdo.getColValue("cod_banco")))
			{	pc.setFont(8, 1);
				if(i!=0)
				{
					pc.addCols("TOTAL POR BANCO : ",1,5);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totDbBanco),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totCrBanco),2,1);
					totDbBanco = 0.00;
					totCrBanco = 0.00;
				}

				if(i!=0)pc.addCols(" ",1,dHeader.size());
			}
			if(i==0&&cdo.getColValue("grupo").trim().equals("G"))
			{
				pc.setFont(8, 1,Color.blue);
				pc.addCols("PAGOS REALIZADOS POR BANCOS ",0,dHeader.size());
			}

			pc.setFont(8, 1,Color.blue);
			pc.addCols("BANCO: ",1,1);
			pc.addCols(""+cdo.getColValue("descBanco"),0,3);
			pc.addCols("CUENTA BANCARIA: "+cdo.getColValue("descCuenta"),0,4);
			if(i!=0)pc.addCols(" ",1,dHeader.size());
		}
		//if(cdo.getColValue("descCuenta").trim().equals("3.5")||cdo.getColValue("descCuenta").trim().equals("4.5"))

			pc.setFont(7, 1);
			if(anulacion.trim().equals("S")&&!groupBy3.trim().equals(cdo.getColValue("grupo"))){pc.setFont(7, 1,Color.red);	pc.addCols("PAGOS [ANULADOS] ",0,dHeader.size());anulacion="";}
			if(cdo.getColValue("estado_cheque").trim().equals("A")&&!cdo.getColValue("grupo").trim().equals("A"))pc.setFont(7, 1,Color.red);
			else pc.setFont(7, 1);
			//pc.addCols(" AN=="+cdo.getColValue("tipo_pago_desc")+" [ "+cdo.getColValue("num_cheque")+" ]",0,1);
			pc.addCols(" "+cdo.getColValue("tipo_pago_desc")+" [ "+cdo.getColValue("num_cheque")+" ]",0,1);
			pc.addCols(" "+cdo.getColValue("beneficiario"),0,1);
			pc.addCols(" "+cdo.getColValue("no_doc"),1,1);
			pc.addCols(" "+cdo.getColValue("fecha_docto"),1,1);
			pc.addCols(" "+cdo.getColValue("cta1")+"."+cdo.getColValue("cta2")+"."+cdo.getColValue("cta3")+"."+cdo.getColValue("cta4")+"."+cdo.getColValue("cta5")+"."+cdo.getColValue("cta6")+" - "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_db")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cr")),2,1);

		   totalDb += Double.parseDouble(cdo.getColValue("monto_db"));
		   totalCr += Double.parseDouble(cdo.getColValue("monto_cr"));
		   totalDbCta += Double.parseDouble(cdo.getColValue("monto_db"));
		   totalCrCta += Double.parseDouble(cdo.getColValue("monto_cr"));
		   totDbBanco += Double.parseDouble(cdo.getColValue("monto_db"));
		   totCrBanco += Double.parseDouble(cdo.getColValue("monto_cr"));
		   totDbCheques += Double.parseDouble(cdo.getColValue("monto_db"));
		   totCrCheques += Double.parseDouble(cdo.getColValue("monto_cr"));

			groupBy = cdo.getColValue("cod_banco")+"-"+cdo.getColValue("cuenta_banco")+"-"+cdo.getColValue("grupo");
			groupBy2 =cdo.getColValue("cod_banco");
			groupBy3 =cdo.getColValue("grupo");

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}

		if(alPm.size() != 0)
		{
			pc.setFont(8, 1,Color.blue);
			pc.addCols(" ",1,dHeader.size());
			pc.addCols("TOTAL POR BANCO Y CUENTA : ",1,5);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDbCta),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCrCta),2,1);

			pc.addCols(" ",1,dHeader.size());
			pc.addCols("TOTAL POR BANCO : ",1,5);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totDbBanco),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totCrBanco),2,1);

			pc.addCols(" ",1,dHeader.size());

		}
	pc.setFont(8, 1,Color.blue);


			pc.addCols("TOTAL TRX CHEQUES PLAN MEDICO: ",1,5);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totDbCheques),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totCrCheques),2,1);

			pc.addCols(" ",1,dHeader.size());
			}
			//========================================================================


	if(al2.size()>0){pc.addCols(" ",1,dHeader.size());pc.addCols(" ",1,dHeader.size());pc.addCols(" ",1,dHeader.size());pc.addCols(" ",1,dHeader.size());
	pc.addCols("OTRAS TRANSANCIONES       [ DEPOSITOS, NOTAS DE DEBITO/CREDITO ]",0,dHeader.size());}
	totalDbCta = 0.00;
	totalCrCta = 0.00;
	totDbBanco = 0.00;
	totCrBanco = 0.00;
	groupBy = "";
	groupBy2="";
	groupBy3="";
	for (int i=0; i<al2.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al2.get(i);
		if(!groupBy.trim().equals(cdo.getColValue("banco")+"-"+cdo.getColValue("cuenta_banco")))
		{	pc.setFont(8, 1,Color.blue);
			if(i!=0)
			{
				pc.addCols("TOTAL POR BANCO Y CUENTA : ",1,5);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDbCta),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCrCta),2,1);

				totalDbCta = 0.00;
				totalDbCta = 0.00;
			}

			if(!groupBy2.trim().equals(cdo.getColValue("banco")))
			{	pc.setFont(8, 1);
				if(i!=0)
				{
					pc.addCols("TOTAL POR BANCO : ",1,5);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totDbBanco),2,1);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(totCrBanco),2,1);
					totDbBanco = 0.00;
					totCrBanco = 0.00;
				}

				if(i!=0)pc.addCols(" ",1,dHeader.size());
			}

			pc.addCols("BANCO: ",1,1);
			pc.addCols(""+cdo.getColValue("descBanco"),0,3);
			pc.addCols("CUENTA BANCARIA: "+cdo.getColValue("descCuenta"),0,3);
			if(i!=0)pc.addCols(" ",1,dHeader.size());
		}
		if(!groupBy3.trim().equals(cdo.getColValue("descmov"))){if(i!=0)pc.addCols(" ",1,dHeader.size());}

 			pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("descmov"),1,2);
			pc.addCols(" "+cdo.getColValue("num_documento"),1,1);
			pc.addCols(" "+cdo.getColValue("f_doc"),1,1);
			pc.addCols(" "+cdo.getColValue("cuenta")+" - "+cdo.getColValue("descCatalogo"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("debito")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("credito")),2,1);
			totalDb += Double.parseDouble(cdo.getColValue("debito"));
			totalCr += Double.parseDouble(cdo.getColValue("credito"));
			totalDbBanco += Double.parseDouble(cdo.getColValue("debito"));
			totalCrBanco += Double.parseDouble(cdo.getColValue("credito"));

			totDbBanco += Double.parseDouble(cdo.getColValue("debito"));
			totCrBanco += Double.parseDouble(cdo.getColValue("credito"));
			totalDbCta += Double.parseDouble(cdo.getColValue("debito"));
			totalCrCta += Double.parseDouble(cdo.getColValue("credito"));

			groupBy = cdo.getColValue("banco")+"-"+cdo.getColValue("cuenta_banco");
			groupBy2 =cdo.getColValue("banco");
			groupBy3 =cdo.getColValue("descmov");
 		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
 	}
	pc.addCols(" ",1,dHeader.size());



	if (al.size() == 0&&al2.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		if(al2.size() != 0)
		{
			pc.setFont(8, 1,Color.blue);
			pc.addCols("TOTAL POR BANCO Y CUENTA : ",1,5);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDbCta),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCrCta),2,1);

			pc.addCols(" ",1,dHeader.size());
			pc.addCols("TOTAL POR BANCO : ",1,5);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totDbBanco),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totCrBanco),2,1);

			pc.addCols(" ",1,dHeader.size());

		}
		pc.addCols(" TOTAL POR REPORTE ",2,5);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totalDb),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totalCr),2,1);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>