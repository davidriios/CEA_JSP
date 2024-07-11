<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

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
StringBuffer sbAppendFilter = new StringBuffer();
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
String tipo = request.getParameter("tipo");
String acumHonNoFacturaro = request.getParameter("acumHonNoFacturaro");

if(codigo == null) codigo = "";
if(nombre == null) nombre = "";
if(fecha_ini == null) fecha_ini = "";
if(fecha_fin == null) fecha_fin = "";
if(tipo == null) tipo="M";
if(acumHonNoFacturaro == null) acumHonNoFacturaro="N";
if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }
  if(fecha_ini.equals("")){
		sbSql.append("select '01/'||to_char(sysdate,'mm/yyyy') fecha_ini, to_char(last_day(sysdate), 'dd/mm/yyyy') fecha_fin from dual");
		CommonDataObject cdoF = SQLMgr.getData(sbSql.toString());
		fecha_ini = cdoF.getColValue("fecha_ini");
		fecha_fin = cdoF.getColValue("fecha_fin");
  }
	
	sbSql = new StringBuffer();
	
//saldo_inicial = todo lo facturado + lo ajustado(debito o credito)- lo pagado en cheques.. 

  sbSql.append(" select x.tipo,x.cod_honorario,x.nombre, x.saldo_inicial, x.facturado,x.ajustado,x.cobrado,x.pagado, x.pagado_cont, x.auxiliar, x.ajuste_pago, x.ajuste_cxp, x.facturado+x.ajustado - x.cobrado ");
	if(acumHonNoFacturaro.equals("S")){
	sbSql.append("+ x.hon_no_facturado");
	}
	sbSql.append(" por_cobrar, x.saldo_inicial+x.cobrado-x.pagado+x.ajuste_pago por_pagar, (nvl(x.saldo_inicial,0)+nvl(x.facturado, 0)+ nvl(x.ajustado,0) -nvl(x.pagado,0) -nvl(x.pagado_cont,0)/**/ + nvl(x.ajuste_pago,0)  + nvl(x.auxiliar, 0)/*+ nvl(x.ajuste_cxp, 0)*/ ");
	if(acumHonNoFacturaro.equals("S")){
	sbSql.append("+ x.hon_no_facturado");
	}
	sbSql.append(") saldo_final, x.hon_no_facturado from(select 'M' tipo, m.codigo cod_honorario,m.primer_nombre ||decode(m.segundo_nombre,null,'', ' '||m.segundo_nombre)|| ' '||m.primer_apellido||decode(m.segundo_apellido,null,'', ' '||m.segundo_apellido)||decode(m.apellido_de_casada,null,'',' '||m.apellido_de_casada) nombre,nvl(getsaldoinicialHon2(");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(",'");
  sbSql.append(fecha_ini);
  sbSql.append("',m.codigo,'M'),0)saldo_inicial,nvl(( select sum(nvl(d.monto,0)) monto from tbl_fac_factura f, tbl_fac_detalle_factura d where f.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and (d.compania = f.compania and d.fac_codigo = f.codigo) and (d.tipo_cobertura <> 'CI' or d.tipo_cobertura is null) and (d.med_empresa is null) and  d.medico = m.codigo and f.fecha >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and f.fecha <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and f.estatus <>'A' ),0)facturado,nvl(( select sum (decode (ad.lado_mov, 'D', ad.monto,'C',-1*monto)) from vw_con_adjustment_gral ad,tbl_fac_tipo_ajuste ta,tbl_fac_factura f where (ad.medico = m.codigo and ad.tipo = 'H' and ad.tipo_doc='F') and ta.group_type not in ('D','F') and ta.compania = ad.compania and ta.codigo = ad.tipo_ajuste and ad.fecha_aprob_idx >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and ad.fecha_aprob_idx <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and f.estatus <> 'A' and f.compania = ad.compania and f.codigo  = ad.factura and ad.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append("),0) ajustado,nvl((select sum (nvl (a.monto, 0)) cobrado from tbl_cja_distribuir_pago a, tbl_cja_detalle_pago p, tbl_cja_transaccion_pago t where a.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" /*and t.rec_status <> 'I'*/ and a.med_codigo = m.codigo and p.cod_rem is null and p.tran_anio = t.anio and p.compania = t.compania and p.codigo_transaccion = t.codigo and a.secuencia_pago = p.secuencia_pago and a.codigo_transaccion = p.codigo_transaccion and a.tran_anio = p.tran_anio and a.compania = p.compania and a.fac_codigo = p.fac_codigo and trunc(a.fecha_creacion) >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and trunc(a.fecha_creacion) <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and a.tipo='H'  ),0) cobrado, nvl(( select sum(c.monto_girado) pagado from tbl_con_cheque c,tbl_cxp_orden_de_pago op where op.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and op.cod_tipo_orden_pago=1 and op.cod_medico is not null and c.estado_cheque <> 'A' and op.estado = 'A' and op.generado='H' and c.f_emision >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and c.f_emision <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and op.num_id_beneficiario = m.codigo and op.cod_medico is not null), 0) as pagado, nvl((select sum(nvl(h.monto_ajuste,0))-sum(nvl(h.retencion,0)) ajuste_pago from tbl_cxp_hon_det h where h.cod_medico=m.codigo and h.tipo in ('M','H') and h.fecha >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and h.fecha <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and h.data_refer is null  /*and h.codigo_paciente = 0*/ ), 0) ajuste_pago, nvl(( select sum(c.monto_girado) pagado from tbl_con_cheque c,tbl_cxp_orden_de_pago op /*,tbl_cxp_orden_de_pago_fact b*/ where op.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and op.cod_tipo_orden_pago=1 and op.cod_medico is not null and c.estado_cheque <> 'A' and op.generado='M'  and c.f_emision >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and c.f_emision <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and op.num_id_beneficiario = m.codigo and op.cod_medico is not null /*and op.cod_compania = b.cod_compania and op.anio = b.anio and op.num_orden_pago = b.num_orden_pago*/), 0) /*+ nvl((select sum(c.monto_girado) pagado from tbl_con_cheque c,tbl_cxp_orden_de_pago op where op.num_id_beneficiario =m.codigo and op.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and c.estado_cheque <> 'A' and op.cod_tipo_orden_pago = 1 and c.f_emision >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("','dd/mm/yyyy') and c.f_emision <= to_date('"); 
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and op.cod_medico is not null), 0)*/ pagado_cont, nvl((select nvl(sum(decode(z.lado, 'CR', z.monto,'DB',-z.monto)),0) from tbl_con_registros_auxiliar z where z.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and z.fecha_doc >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and z.fecha_doc <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') ");
  
  sbSql.append(" and z.estado = 'A' and z.ref_id = m.codigo and (subref_type = to_number(get_sec_comp_param(z.compania, 'TIPO_CLIENTE_MEDICO'))) /*and z.reg_sistema='S' */ and z.ref_type = 2 and exists (select null from tbl_con_encab_comprob a where a.consecutivo = z.trans_id and a.ea_ano = z.trans_anio and a.compania =z.compania and a.status = 'AP' and a.estado = 'A')), 0) auxiliar, nvl((select sum(decode(cxp.cod_tipo_ajuste, 1, -1 * nvl(cxp.monto, 0), nvl(cxp.monto, 0))) from tbl_cxp_ajuste_saldo_enc cxp where cxp.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and destino_ajuste = 'H' and cxp.fecha  >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and cxp.fecha  <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and cxp.ref_id = m.codigo and cxp.estado ='R'), 0) ajuste_cxp, nvl((SELECT SUM (DECODE (b.tipo_transaccion, 'D', -1 * b.cantidad, b.cantidad) * (b.monto + nvl(b.recargo, 0))) monto FROM tbl_fac_transaccion a, tbl_fac_detalle_transaccion b WHERE a.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and a.fecha  >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and a.fecha  <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') AND a.codigo = b.fac_codigo AND a.pac_id = b.pac_id AND a.admi_secuencia = b.fac_secuencia AND a.compania = b.compania AND a.tipo_transaccion = b.tipo_transaccion and b.tipo_cargo = get_sec_comp_param(-1, 'COD_TIPO_SERV_HON') and a.pagar_sociedad = 'N' and a.med_codigo = m.codigo  and not exists (select null from tbl_fac_factura f where f.estatus  != 'A' and f.pac_id = a.pac_id and f.admi_secuencia = a.admi_secuencia and f.compania = a.compania ) ), 0) hon_no_facturado from tbl_adm_medico m union all select 'E' tipo, to_char(e.codigo)cod_honorario,e.nombre, nvl(getsaldoinicialHon2(");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(",'");
  sbSql.append(fecha_ini);
  sbSql.append("',e.codigo,'E'),0)saldo_inicial, nvl(( select sum(nvl(d.monto,0)) monto from tbl_fac_factura f, tbl_fac_detalle_factura d where f.compania =");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and (d.compania = f.compania and d.fac_codigo = f.codigo) and (d.tipo_cobertura <> 'CI' or d.tipo_cobertura is null) and (d.med_empresa = e.codigo) and  d.medico is null and f.fecha >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and f.fecha <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and f.estatus <>'A' ),0)facturado,nvl(( select sum (decode (ad.lado_mov, 'D', ad.monto,'C',-1*monto)) from vw_con_adjustment_gral ad,tbl_fac_tipo_ajuste ta,tbl_fac_factura f where (ad.empresa = e.codigo and ad.tipo = 'E' and ad.tipo_doc='F') and ta.group_type not in ('D','F') and ta.compania = ad.compania and ta.codigo = ad.tipo_ajuste and ad.fecha_aprob_idx >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy')and ad.fecha_aprob_idx <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and f.estatus <> 'A' and f.compania = ad.compania and f.codigo = ad.factura and ad.compania =");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append("),0)ajustado,nvl((select sum (nvl (a.monto, 0)) cobrado from tbl_cja_distribuir_pago a, tbl_cja_detalle_pago p, tbl_cja_transaccion_pago t where a.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" /*and t.rec_status <> 'I'*/ and a.empre_codigo = to_char(e.codigo) and p.cod_rem is null and p.tran_anio = t.anio and p.compania = t.compania and p.codigo_transaccion = t.codigo and a.secuencia_pago = p.secuencia_pago and a.codigo_transaccion = p.codigo_transaccion and a.tran_anio = p.tran_anio and a.compania = p.compania and a.fac_codigo = p.fac_codigo and trunc(a.fecha_creacion) >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and trunc(a.fecha_creacion) <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and a.tipo='E' ),0) cobrado,nvl(( select sum(c.monto_girado) pagado from tbl_con_cheque c,tbl_cxp_orden_de_pago op where op.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and op.cod_tipo_orden_pago in (1) and op.cod_empresa is not null and c.estado_cheque <> 'A' and op.generado in ('H') and c.f_emision >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("','dd/mm/yyyy') and c.f_emision <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("','dd/mm/yyyy') and op.num_id_beneficiario = to_char(e.codigo)), 0) as pagado, nvl((select sum(nvl(h.monto_ajuste,0))-sum(nvl(h.retencion,0)) ajuste_pago from tbl_cxp_hon_det h where h.cod_medico=to_char(e.codigo) and h.tipo='E' and h.fecha >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and h.fecha <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and h.codigo_paciente = 0 ), 0) ajuste_pago, nvl(( select sum(c.monto_girado) pagado from tbl_con_cheque c,tbl_cxp_orden_de_pago op /*,tbl_cxp_orden_de_pago_fact b*/ where op.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and op.cod_tipo_orden_pago=3 and op.tipo_orden = 'E' and op.cod_empresa is not null and c.estado_cheque <> 'A' /*and op.estado = 'A'*/ and op.generado='M' and c.f_emision >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("','dd/mm/yyyy') and c.f_emision <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("','dd/mm/yyyy') and op.num_id_beneficiario = to_char(e.codigo) /*and op.cod_compania = b.cod_compania and op.anio = b.anio and op.num_orden_pago = b.num_orden_pago*/), 0) /*+ nvl((select sum(c.monto_girado) pagado from tbl_con_cheque c, tbl_cxp_orden_de_pago op where op.num_id_beneficiario = to_char(e.codigo) and op.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and c.estado_cheque <> 'A' and op.cod_tipo_orden_pago = 3 and op.tipo_orden='E' AND op.generado = 'M' and c.f_emision >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("','dd/mm/yyyy') and c.f_emision <= to_date('"); 
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and op.cod_medico is null), 0)*/ pagado_cont, nvl((select nvl(sum(decode(z.lado, 'CR', z.monto,'DB',-z.monto)),0) from tbl_con_registros_auxiliar z where z.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));
  sbSql.append(" and z.fecha_doc >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and z.fecha_doc <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') "); 
  sbSql.append(" and z.estado = 'A' and z.ref_id = to_char(e.codigo) and (subref_type = to_number(get_sec_comp_param(z.compania, 'TIPO_CLIENTE_SOC_MED'))) /*and z.reg_sistema='S' */ and z.ref_type = 2 and exists (select null from tbl_con_encab_comprob a where a.consecutivo = z.trans_id and a.ea_ano = z.trans_anio and a.compania =z.compania and a.status = 'AP' and a.estado = 'A')), 0) auxiliar, nvl((select sum(decode(cxp.cod_tipo_ajuste, 1, -1 * nvl(cxp.monto, 0), nvl(cxp.monto, 0))) from tbl_cxp_ajuste_saldo_enc cxp where cxp.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));
  sbSql.append(" and destino_ajuste = 'E' and cxp.fecha  >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and cxp.fecha  <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and cxp.ref_id = to_char(e.codigo) and cxp.estado ='R'), 0) ajuste_cxp, nvl((SELECT SUM (DECODE (b.tipo_transaccion, 'D', -1 * b.cantidad, b.cantidad, 0) * (b.monto + nvl(b.recargo, 0))) monto FROM tbl_fac_transaccion a, tbl_fac_detalle_transaccion b WHERE a.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and a.fecha  >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and a.fecha  <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') AND a.codigo = b.fac_codigo AND a.pac_id = b.pac_id AND a.admi_secuencia = b.fac_secuencia AND  a.compania = b.compania AND a.tipo_transaccion = b.tipo_transaccion and b.tipo_cargo = get_sec_comp_param(-1, 'COD_TIPO_SERV_HON') and a.pagar_sociedad = 'S' and  a.empre_codigo = e.codigo  and not exists (select null from tbl_fac_factura f where f.estatus != 'A' and f.pac_id = a.pac_id and f.admi_secuencia = a.admi_secuencia and f.compania = a.compania) ), 0) hon_no_facturado from tbl_adm_empresa e  where e.tipo_empresa=1 ) x where (nvl(x.facturado,0)+nvl(x.ajustado,0)<> 0 or nvl(x.cobrado,0) > 0 or nvl(x.pagado,0) >0 or nvl(x.pagado_cont,0) >0 /*or nvl(x.ajuste_cxp,0) >0*/ or nvl(x.saldo_inicial,0) <>0)"); 
 if(!tipo.trim().equals("")){
		sbSql.append(" and x.tipo='");
		sbSql.append(tipo);
		sbSql.append("' ");
	}

 if(!codigo.trim().equals("")){
		sbSql.append(" and x.cod_honorario like '%");
		sbSql.append(codigo);
		sbSql.append("%'");
	}
	if(!nombre.trim().equals("")){
		sbSql.append(" and x.nombre like '%");
		sbSql.append(nombre);
		sbSql.append("%'");
	}
	sbSql.append(" order by 3");
  if(request.getParameter("fecha_fin")!=null){
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
  StringBuffer sqlCount = new StringBuffer();
  sqlCount.append("select count(*) from (");
  sqlCount.append(sbSql.toString());
  sqlCount.append(")");
	System.out.println("al.zise..............................................="+al.size());
 rowCount = CmnMgr.getCount(sqlCount.toString());}
		System.out.println("rowCount..............................................="+rowCount);
 

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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = '- Honorarios y pagos - '+document.title;
function printList(){var codigo = document.search01.codigo.value;var nombre = document.search01.nombre.value;var fechaini = document.search01.fecha_ini.value;var fechafin = document.search01.fecha_fin.value;var tipo = document.search01.tipo.value;abrir_ventana('../cxp/print_estado_cta_hon_resumen.jsp?codigo='+codigo+'&nombre='+nombre+'&fecha_ini='+fechaini+'&fecha_fin='+fechafin+'&tipo='+tipo);}
function printListBI(){var codigo = document.search01.codigo.value;var nombre = document.search01.nombre.value;var fechaini = document.search01.fecha_ini.value;var fechafin = document.search01.fecha_fin.value;var tipo = document.search01.tipo.value;

abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxp/rpt_cxp_estado_cta_hon_resumen.rptdesign&codigoParam='+codigo+'&nombreParam='+nombre+'&fIniParam='+fechaini+'&fFinParam='+fechafin+'&tipoParam='+tipo); 
}

function viewEC(code, tipo){var fechaini = document.search01.fecha_ini.value;var fechafin = document.search01.fecha_fin.value;abrir_ventana('../cxp/ver_mov_hon.jsp?mode=ver&beneficiario='+code+'&tipo='+tipo+'&fechaini='+fechaini+'&fechafin='+fechafin);}
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0"  onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR PAGAR - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0"  id="_tblMain">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">		
                    <%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				    <td width="15%">Tipo:<%=fb.select("tipo","M=MEDICOS,E=EMPRESA",tipo,false,false,0,"T")%></td>
					<td><cellbytelabel>C&oacute;digo</cellbytelabel>:
					<%=fb.textBox("codigo",codigo,false,false,false,10,"text10",null,"")%> 
					<cellbytelabel>Nombre</cellbytelabel>:
					<%=fb.textBox("nombre",nombre,false,false,false,40,"text10",null,"")%> 
					<cellbytelabel>Fecha</cellbytelabel>:
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="nameOfTBox1" value="fecha_ini" />
					<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
					<jsp:param name="nameOfTBox2" value="fecha_fin" />
					<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
					</jsp:include>
					Inc. Hon. No Facturados:
					<%=fb.select("acumHonNoFacturaro","N=No,S=Si,",acumHonNoFacturaro,false,false,0,"Text10",null,"","","")%>
						<%=fb.submit("go","Ir")%>		  
            </td>
				    <%=fb.formEnd()%>	   </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right">
		  		<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<authtype type='0'><a href="javascript:printListBI()" class="Link00">[ <cellbytelabel>Excel</cellbytelabel> ]</a></authtype>
				</td>
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("acumHonNoFacturaro",acumHonNoFacturaro)%>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("acumHonNoFacturaro",acumHonNoFacturaro)%>
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
				<tr class="TextHeader">
					<td width="5%" align="center" rowspan="2"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="18%" align="center" rowspan="2"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="7%" rowspan="2"><cellbytelabel>Saldo Ini.</cellbytelabel></td>
				    <td align="center" width="14%" colspan="2"><cellbytelabel>Cargos</cellbytelabel></td>
				    <td align="center" width="7%" rowspan="2"><cellbytelabel>Ajustado</cellbytelabel></td>
				    <!--<td align="center" width="7%" rowspan="2"><cellbytelabel>Hon. No Facturado</cellbytelabel></td>-->
				    <td align="center" width="7%" rowspan="2"><cellbytelabel>Cobrado</cellbytelabel></td>
					<td align="center" width="7%" rowspan="2"><cellbytelabel>Retenci&oacute;n/ajuste</cellbytelabel></td>
				    <td align="center" width="6%" rowspan="2"><cellbytelabel>Pagado Hon.</cellbytelabel></td>
				    <td align="center" width="6%" rowspan="2"><cellbytelabel>Pagado Cont.</cellbytelabel></td>
				    <td align="center" width="6%" rowspan="2"><cellbytelabel>Auxiliar</cellbytelabel></td>
				    <!--<td align="center" width="6%"><cellbytelabel>Ajuste CxP.</cellbytelabel></td>-->
				    <td align="center" width="6%" rowspan="2"><cellbytelabel>Por Cobrar</cellbytelabel></td>
				    <td align="center" width="6%" rowspan="2"><cellbytelabel>Por Pagar</cellbytelabel></td>
				    <td align="center" width="7%" rowspan="2"><cellbytelabel>Saldo Final</cellbytelabel></td>
					<td width="3%" align="center" rowspan="2"></td>
				</tr>	
				<tr class="TextHeader">
					<td>Fact.</td>
					<td>No Fact.</td>
				</tr>
				<%
				double saldo = 0.00, saldo_por_pagar = 0.00, saldo_inicial = 0.00, saldo_final = 0.00;
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				  saldo_final = Double.parseDouble(cdo.getColValue("saldo_inicial"))+ Double.parseDouble(cdo.getColValue("cobrado"))- Double.parseDouble(cdo.getColValue("pagado"));
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("cod_honorario")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td align="right">
					<%if(Double.parseDouble(cdo.getColValue("saldo_inicial"))<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
						<%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial"))%>
					<%if(Double.parseDouble(cdo.getColValue("saldo_inicial"))<0){%>&nbsp;&nbsp;</label></label><%}%>
					</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("facturado"))%>&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("hon_no_facturado"))%>&nbsp;</td>
					<td align="right">
					<%if(Double.parseDouble(cdo.getColValue("ajustado"))<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
						<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajustado"))%>
					<%if(Double.parseDouble(cdo.getColValue("ajustado"))<0){%>&nbsp;&nbsp;</label></label><%}%>
					</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cobrado"))%>&nbsp;</td>
					<td align="right">
					<%if(Double.parseDouble(cdo.getColValue("ajuste_pago"))<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
						<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_pago"))%>
					<%if(Double.parseDouble(cdo.getColValue("ajuste_pago"))<0){%>&nbsp;&nbsp;</label></label><%}%>
					</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagado"))%>&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagado_cont"))%>&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("auxiliar"))%>&nbsp;</td>
					<!--<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_cxp"))%>&nbsp;</td>-->
					<td align="right">
					<%if(Double.parseDouble(cdo.getColValue("por_cobrar"))<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
						<%=CmnMgr.getFormattedDecimal(cdo.getColValue("por_cobrar"))%>
					<%if(Double.parseDouble(cdo.getColValue("por_cobrar"))<0){%>&nbsp;&nbsp;</label></label><%}%>
					</td>
					<td align="right">
					<%if(Double.parseDouble(cdo.getColValue("por_pagar"))<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
						<%=CmnMgr.getFormattedDecimal(cdo.getColValue("por_pagar"))%>
					<%if(Double.parseDouble(cdo.getColValue("por_pagar"))<0){%>&nbsp;&nbsp;</label></label><%}%>
					</td>
					<td align="right">
					<%if(Double.parseDouble(cdo.getColValue("saldo_final"))<0){%><label  class="<%=color%>" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>
						<%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_final"))%>
					<%if(Double.parseDouble(cdo.getColValue("saldo_final"))<0){%>&nbsp;&nbsp;</label></label><%}%>
					</td>
					<td align="center">
					<a href="javascript:viewEC('<%=cdo.getColValue("cod_honorario")%>', '<%=cdo.getColValue("tipo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><img height="20" width="20" class="ImageBorder" src="../images/search.gif"></a>
					</td>
				</tr>
				<%
				}
				%>							
			</table>
	
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</div>
	</div>
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("acumHonNoFacturaro",acumHonNoFacturaro)%>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("acumHonNoFacturaro",acumHonNoFacturaro)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>