<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="issi.caja.DetalleDistribuirPago"%>


<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDistri" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="TPMgr" scope="page" class="issi.caja.TransaccionPagoMgr" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
TPMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList lista = new ArrayList();
String mode = request.getParameter("mode");
String key = "";
String sql = "";
String factura = request.getParameter("factura");
int lastLineNo = 0;
double sumMonto = 0;
double porcentaje = 0.00;
double valor = 0.00;
double totalMonto = 0;
StringBuffer sbSql = new StringBuffer();
String tipoCliente = request.getParameter("tipoCliente");
String monto = request.getParameter("monto");
String cod_rem = request.getParameter("cod_rem");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fg = request.getParameter("fg");
String compania = request.getParameter("compania");
String codigo = request.getParameter("codigoTransaccion");
String anio = request.getParameter("anio");
String fp = request.getParameter("fp");
String fg2 = request.getParameter("fg2");
double montoAplicado = 0.00;

String secuenciaPago = request.getParameter("secuenciaPago");
if(anio==null)anio = cDateTime.substring(6,10);
if(compania==null)compania = (String) session.getAttribute("_companyId");

if(fg==null) fg="";
if(fp==null) fp="";
if(fg2==null) fg2="";

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
boolean viewMode = false;
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
 sbSql = new StringBuffer();
	sbSql.append("select a.secuencia, a.fac_codigo as facCodigo, nvl(a.tipo,' ')tipo, a.centro_servicio as centroServicio, a.med_codigo as medCodigo, a.empre_codigo as empreCodigo, nvl(a.monto,0) montoCentro, nvl(a.estatus,' ')estatus, 0 as monto, decode(a.tipo,'C',nvl(''||a.centro_servicio,'PERDIEM'),'H',a.med_codigo,'E',''||a.empre_codigo) as codTrabajo, decode(a.tipo,'C',(select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),'H',(select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||apellido_de_casada from tbl_adm_medico where codigo = a.med_codigo),'E',(select nombre from tbl_adm_empresa where codigo = a.empre_codigo)) as trabajo,nvl(a.num_cheque,' ')numCheque from tbl_cja_distribuir_pago a where a.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.tran_anio = ");
	sbSql.append(anio);
	sbSql.append(" and a.codigo_transaccion = ");
	sbSql.append(codigo);
	sbSql.append(" and a.secuencia_pago = ");
	sbSql.append(secuenciaPago);
	sbSql.append(" order by secuencia");
	System.out.println("distribuido sql...\n"+sbSql);
	sql = sbSql.toString();
	al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),DetalleDistribuirPago.class);
	if (viewMode || al.size() > 0) viewMode = true;
	else
	{
  
  if(tipoCliente.equals("E") || tipoCliente.equals("ARE")){
		sql = "select centro_servicio AS centroServicio, nvl(med_empresa, '0') as emprecodigo, nvl(medico,' ') as medcodigo, nvl(decode(tipo,'C',nvl(nombre_centro,' '),'H',nombre_medico,'E',nombre_empresa,nombre_centro),' ') as trabajo, nvl(decode(tipo,'C',nombre_centro,'H',nombre_medico,'E',nombre_empresa,nombre_centro),' ') as centroServicioNombre , decode(tipo,null,' ',nvl(tipo,' '))tipo, (nvl(monto,0) - nvl(monto_pag,0) + nvl(ajustes,0)) as montocentro, trim('P') as estatus, fac_codigo facCodigo, cargo as estado, nvl(decode(tipo,'C',centro_servicio,'H',medico,'E',med_empresa),' ') as codTrabajo from ("
			+"select v.cargo, v.fac_codigo, v.tipo, v.centro_servicio, v.med_empresa, v.medico, v.monto, v.nombre_empresa, v.nombre_medico, v.nombre_centro, v.tipo_cobertura, (case when v.tipo='C' and v.medico is null and v.med_empresa is null and v.cargo in ('CF','CNF') then (case when v.centro_servicio is null then (select sum(monto) from tbl_cja_distribuir_pago where fac_codigo=v.fac_codigo and compania=v.compania and med_codigo is null and empre_codigo is null and (tipo_cobertura='P' or centro_servicio is null)) else (case when v.tipo_cobertura in ('P','CO') then (select sum(monto) from tbl_cja_distribuir_pago where fac_codigo=v.fac_codigo and compania=v.compania and med_codigo is null and empre_codigo is null and (tipo_cobertura in ('P','CO') or centro_servicio is null)) else (select sum(monto) from tbl_cja_distribuir_pago where fac_codigo=v.fac_codigo and compania=v.compania and centro_servicio=v.centro_servicio and tipo_cobertura is null and cod_rem is null group by centro_servicio, fac_codigo) end) end) when v.tipo='H' and v.medico is not null and v.med_empresa is null and v.cargo in ('CF','HNF') then (select sum(monto) from tbl_cja_distribuir_pago where fac_codigo=v.fac_codigo and compania=v.compania and med_codigo=v.medico group by med_codigo, fac_codigo)   when v.tipo='E' and v.medico is null and v.med_empresa is not null and v.cargo in ('CF','ENF') then (select sum(monto) from tbl_cja_distribuir_pago where fac_codigo=v.fac_codigo and compania=v.compania and empre_codigo=v.med_empresa group by med_codigo, fac_codigo) end) as monto_pag, (case when v.tipo='C' and v.medico is null and v.med_empresa is null and v.cargo in ('CF','CNF') then (case when v.centro_servicio is null then (select sum(decode(lado_mov,'D',monto,'C',-monto)) from vw_con_adjustment_gral where factura=v.fac_codigo and compania=v.compania and centro is null) else decode(v.cargo,'CNF',0,(select sum(decode(lado_mov, 'D', monto, 'C', -monto)) from vw_con_adjustment_gral where factura=v.fac_codigo and compania=v.compania and centro=v.centro_servicio)) end) when v.tipo='H' and v.medico is not null and v.med_empresa is null and v.cargo in ('CF','HNF') then decode(v.cargo,'HNF',0,(select sum(decode(lado_mov,'D',monto,'C',-monto)) from vw_con_adjustment_gral where factura=v.fac_codigo and compania=v.compania and medico=v.medico))  when v.tipo='E' and v.medico is null and v.med_empresa is not null and v.cargo in ('CF','ENF') then decode(v.cargo,'ENF',0,(select nvl(sum(decode(lado_mov,'D',monto,'C',-monto)),0) from vw_con_adjustment_gral where factura=v.fac_codigo and compania=v.compania and empresa=v.med_empresa)) end) as ajustes  from ("
				+"select 'CF' as cargo,a.codigo fac_codigo, b.tipo, to_char(b.centro_servicio) as centro_servicio, b.med_empresa, b.medico, sum(b.monto)- nvl( getCopagoDet(a.compania,a.codigo,nvl(to_char(b.med_empresa),b.medico),c.descripcion,a.pac_id,a.admi_secuencia,'DIST' ),0) /* nvl((select sum(nvl(det.monto,0)) from tbl_fac_factura ff, tbl_fac_detalle_factura det where ff.codigo = det.fac_codigo and ff.compania = det.compania and ff.pac_id = a.pac_id and ff.admi_secuencia = a.admi_secuencia and ff.facturar_a <> a.facturar_a and ff.estatus <> 'A' and ff.codigo != a.codigo and substr(det.descripcion, 10, length(det.descripcion)-9) = c.descripcion and det.tipo_cobertura = 'CO' and trunc(ff.fecha) >= to_date('01/10/2011','dd/mm/yyyy')), 0)*/ as monto, d.nombre as nombre_empresa, e.primer_nombre||' '||e.segundo_nombre||' '||e.primer_apellido||' '||e.apellido_de_casada as nombre_medico, decode(b.tipo,'C',decode(b.tipo_cobertura,'P','PERDIEM',c.descripcion),decode(b.tipo_cobertura,'CO','COPAGO',c.descripcion)) as nombre_centro, b.tipo_cobertura, a.compania from tbl_fac_factura a, tbl_fac_detalle_factura b, tbl_cds_centro_servicio c, tbl_adm_empresa d, tbl_adm_medico e where (b.fac_codigo='"+factura+"'  and a.codigo='"+factura+"'  and a.compania="+(String) session.getAttribute("_companyId")+") and ((b.compania=a.compania and b.fac_codigo=a.codigo) and (b.centro_servicio=c.codigo(+)) and (b.med_empresa=d.codigo(+)) and (b.medico=e.codigo(+))) group by 'CF', a.codigo, b.tipo, b.centro_servicio, b.med_empresa, b.medico, d.nombre, e.primer_nombre||' '||e.segundo_nombre||' '||e.primer_apellido||' '||e.apellido_de_casada, decode(b.tipo, 'C', decode(b.tipo_cobertura, 'P', 'PERDIEM', c.descripcion),decode(b.tipo_cobertura, 'CO','COPAGO',c.descripcion)), b.tipo_cobertura, a.compania,a.admi_secuencia,a.pac_id,a.facturar_a ,c.descripcion,a.compania"
				+" union all "
				+"select 'CNF' as cargo, b.factura, /*decode(b.tipo,'P','C','M','C',b.tipo)*/b.tipo tipo, to_char(b.centro) as centro, 0, '0', sum(decode(b.lado_mov,'D',b.monto,'C',-b.monto)), null, null, decode(b.tipo,'P','CO-PAGO','M','PERDIEM', c.descripcion) as nombre_centro, null, a.compania from tbl_fac_factura a, vw_con_adjustment_gral b, tbl_cds_centro_servicio c, (select nvl(y.centro_servicio,777) as centro_servicio from tbl_fac_factura x, tbl_fac_detalle_factura y where x.compania="+(String) session.getAttribute("_companyId")+" and x.compania=y.compania and x.codigo=y.fac_codigo and x.codigo='"+factura+"' and (y.med_empresa is null and y.medico is null)) d where (b.factura ='"+factura+"'  and a.codigo='"+factura+"'  and a.compania="+(String) session.getAttribute("_companyId")+") and (b.medico is null and b.empresa is null) and (b.compania=a.compania and b.factura=a.codigo) and (b.centro=c.codigo(+)) and (nvl(b.centro,777)=d.centro_servicio(+) and d.centro_servicio is null) group by 'CNF', b.factura,b.tipo, b.centro, 0, '0'/*, null, null*/,decode(b.tipo,'P','CO-PAGO','M','PERDIEM', c.descripcion), a.compania having sum(decode(b.lado_mov,'D',b.monto,'C',-b.monto)) > 0"
				+" union all "
				+"select 'HNF' as cargo, b.factura, b.tipo, '0', 0, b.medico, sum(decode(b.lado_mov,'D',nvl(b.monto,0),'C',-nvl(b.monto,0))), null, c.primer_apellido||' '||c.primer_nombre as nombre_medico, null, null, a.compania from tbl_fac_factura a, vw_con_adjustment_gral b, tbl_adm_medico c, (select distinct y.medico from tbl_fac_factura x, tbl_fac_detalle_factura y where x.compania="+(String) session.getAttribute("_companyId")+" and (x.codigo=y.fac_codigo and x.compania=y.compania) and x.codigo='"+factura+"'  and y.tipo='H' and nvl(y.centro_servicio,0)=0 and y.medico is not null) d where (b.factura='"+factura+"'  and a.codigo='"+factura+"'  and a.compania="+(String) session.getAttribute("_companyId")+") and (b.medico is not null and b.empresa is null) and (b.compania=a.compania and b.factura=a.codigo) and (b.medico=c.codigo) and (b.medico=d.medico(+) and d.medico is null) group by 'HNF', b.factura, b.tipo, '0', 0, b.medico/*, null*/, c.primer_apellido||' '||c.primer_nombre/*, null*/, a.compania having sum(decode(b.lado_mov,'D',b.monto,'C',-b.monto)) > 0"
				+" union all "
				+"select 'ENF' as cargo, b.factura, b.tipo, '0', b.empresa, '0', sum(decode(b.lado_mov,'D',nvl(b.monto,0),'C',-nvl(b.monto,0))), c.nombre as nombre_empresa, null, null, null, a.compania from tbl_fac_factura a, vw_con_adjustment_gral b, tbl_adm_empresa c, (select distinct y.med_empresa as empresa from tbl_fac_factura x, tbl_fac_detalle_factura y where x.compania="+(String) session.getAttribute("_companyId")+" and (x.codigo=y.fac_codigo and x.compania=y.compania) and x.codigo='"+factura+"'  and nvl(y.centro_servicio,0)=0 and y.tipo='E' and (y.medico is null and y.med_empresa is not null)) d where (b.factura='"+factura+"'  and a.codigo='"+factura+"'  and a.compania="+(String) session.getAttribute("_companyId")+") and (b.medico is null and b.empresa is not null) and (b.compania=a.compania and b.factura=a.codigo) and (b.empresa=c.codigo) and (b.empresa=d.empresa(+) and d.empresa is null) group by 'ENF',b.factura, b.tipo, '0', b.empresa, '0', c.nombre/*, null, null*/, a.compania having sum(decode(b.lado_mov,'D',b.monto,'C',-b.monto)) > 0"
			+") v"
		+")  WHERE (nvl(monto,0) - nvl(monto_pag,0) + nvl(ajustes,0)) > 0 order by 6,1 ";
  } else if(tipoCliente.equals("F") || tipoCliente.equals("P") || tipoCliente.equals("ARP")){
    sql = "select a.compania, a.codigo facCodigo, a.cargo estado,decode(a.tipo,null,' ',nvl(tipo,' '))tipo, decode(a.centro_servicio, null, ' ', 'P') estatus, nvl(decode(a.centro_servicio,0,decode(a.medico,null,decode(a.med_empresa,null,to_char(a.centro_servicio),to_char(a.med_empresa)),a.medico),null,' ',to_char(a.centro_servicio)),' ') codTrabajo, nvl(decode(a.centro_servicio,0,decode(a.medico,null,decode(a.med_empresa,null,'CO-PAGO',a.nombre_empresa),a.nombre_medico),a.nombre_centro),' ') trabajo, a.centro_servicio centroServicio, nvl(to_char(a.med_empresa), ' ') empreCodigo, nvl(a.medico, ' ') medCodigo, a.nombre_empresa, a.nombre_medico, a.nombre_centro, a.monto, a.monto_pago, a.ajustes, (nvl (a.monto, 0) - nvl (a.monto_pago, 0) + nvl (a.ajustes, 0)) montoCentro from ("
			+"select z.*, (case when nvl(z.centro_servicio, 1) <> 0 and z.medico is null and z.med_empresa is null and z.cargo in ('CF', 'CNF') then (case when z.centro_servicio is not null then (select coalesce(sum(decode(tipo_cobertura, null, dp.monto)), sum(decode(tipo_cobertura,'CO',dp.monto))) from tbl_cja_distribuir_pago dp where fac_codigo = z.codigo and compania = z.compania and centro_servicio = z.centro_servicio and cod_rem is null group by centro_servicio, fac_codigo) else (select sum (nvl (decode(tipo_cobertura, 'CO', dp.monto), 0)) + sum(nvl(decode(centro_servicio, null, dp.monto),0)) from tbl_cja_distribuir_pago dp where fac_codigo = z.codigo and compania = z.compania and med_codigo is null and empre_codigo is null and cod_rem is null) end) when z.medico is not null and z.med_empresa is null and z.cargo in ('CF', 'HNF') then (select sum (dp.monto) from tbl_cja_distribuir_pago dp where fac_codigo = z.codigo and compania = z.compania and med_codigo = z.medico group by med_codigo, fac_codigo) when z.med_empresa is not null and z.medico is null and z.cargo in ('CF', 'ENF') then (select sum (dp.monto) from tbl_cja_distribuir_pago dp where fac_codigo = z.codigo and compania = z.compania and empre_codigo = z.med_empresa group by med_codigo, fac_codigo) end) as monto_pago, (case when nvl(z.centro_servicio, 1) <> 0 and z.medico is null and z.med_empresa is null and z.cargo = 'CF' then (case when z.centro_servicio is not null then (select sum (decode (lado_mov, 'D', monto, 'C', -monto)) from vw_con_adjustment_gral where factura = z.codigo and compania = z.compania and centro = z.centro_servicio) else (select sum (decode (lado_mov, 'D', monto, 'C', -monto)) from vw_con_adjustment_gral where factura = z.codigo and compania = z.compania and centro is null and medico is null and empresa is null and tipo = 'P') end) when z.medico is not null and z.med_empresa is null and z.cargo = 'CF' then (select sum (decode (lado_mov, 'D', monto, 'C', -monto)) from vw_con_adjustment_gral where factura = z.codigo and compania = z.compania and medico = z.medico) when z.med_empresa is not null and z.medico is null and z.cargo = 'CF' then (select sum (decode (lado_mov, 'D', monto, 'C', -monto)) from vw_con_adjustment_gral where factura = z.codigo and compania = z.compania and empresa = z.med_empresa) end) as ajustes from ("
				+"select 'CF' cargo, f.compania, f.codigo, df.tipo, df.centro_servicio, df.med_empresa, df.medico, e.nombre nombre_empresa, m.primer_nombre||' '|| m.segundo_nombre||' '|| m.primer_apellido||' '||m.apellido_de_casada nombre_medico,nvl(df.descripcion,cs.descripcion) /*decode (cs.descripcion,null, 'CO-PAGO',cs.descripcion)*/ nombre_centro, sum (df.monto)- nvl( getCopagoDet(f.compania,f.codigo,nvl(to_char(df.med_empresa),df.medico),cs.descripcion,f.pac_id,f.admi_secuencia,'DIST'),0) /* nvl((select det.monto from tbl_fac_factura ff, tbl_fac_detalle_factura det where ff.codigo = det.fac_codigo and ff.compania = det.compania and ff.pac_id = f.pac_id and ff.admi_secuencia = f.admi_secuencia and ff.facturar_a <> f.facturar_a and ff.estatus <> 'A' and ff.codigo != f.codigo and substr(det.descripcion, 10, length(det.descripcion)-9) = cs.descripcion and det.tipo_cobertura = 'CO' and trunc(ff.fecha) >= to_date('01/10/2011','dd/mm/yyyy')), 0)*/ monto from tbl_fac_factura f, tbl_fac_detalle_factura df, tbl_cds_centro_servicio cs, tbl_adm_empresa e, tbl_adm_medico m where f.codigo = '"+factura+"' and f.compania = "+(String) session.getAttribute("_companyId")+" and df.compania = f.compania and df.fac_codigo = f.codigo and df.centro_servicio = cs.codigo(+) and df.med_empresa = e.codigo(+) and df.medico = m.codigo(+) group by 'CF', f.compania, f.codigo, df.tipo, df.centro_servicio, df.med_empresa, df.medico, e.nombre, m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.apellido_de_casada, nvl(df.descripcion,cs.descripcion),f.admi_secuencia,f.pac_id,f.facturar_a,cs.descripcion"
				+" union all"
				+" select 'CNF' cargo, f.compania, f.codigo, na.tipo, na.centro, 0, '0', null, null, decode(na.tipo,'P','CO-PAGO','M','PERDIEM', cs.descripcion) nombre_centro, sum (decode (na.lado_mov, 'D', na.monto, 'C', -na.monto)) from tbl_fac_factura f, vw_con_adjustment_gral na, tbl_cds_centro_servicio cs where f.codigo = '"+factura+"' and f.compania = "+(String) session.getAttribute("_companyId")+" and na.medico is null and na.empresa is null and na.compania = f.compania and na.factura = f.codigo and na.centro = cs.codigo(+) and nvl (na.centro, 777) not in (select nvl(b.centro_servicio, 777) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = "+(String) session.getAttribute("_companyId")+" and a.compania = b.compania and a.codigo = b.fac_codigo and a.codigo = '"+factura+"' and b.med_empresa is null and b.medico is null) group by 'CNF', f.compania, f.codigo, na.tipo, na.centro, 0, '0', null, null,decode(na.tipo,'P','CO-PAGO','M','PERDIEM', cs.descripcion) having sum (decode (na.lado_mov, 'D', na.monto, 'C', -na.monto)) > 0"
				+" union all"
				+"select   'HNF' cargo, f.compania, f.codigo, na.tipo, 0, 0, na.medico medico, null, m.primer_apellido||' '||m.primer_nombre nombre_medico, null, sum (decode (na.lado_mov, 'D', nvl (na.monto, 0), 'C', -nvl (na.monto, 0))) from tbl_fac_factura f, vw_con_adjustment_gral na, tbl_adm_medico m where f.codigo = '"+factura+"' and f.compania = "+(String) session.getAttribute("_companyId")+" and na.medico is not null and na.empresa is null and na.compania = f.compania and na.factura = f.codigo and na.medico = m.codigo and na.medico not in (select distinct b.medico from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = "+(String) session.getAttribute("_companyId")+" and a.codigo = b.fac_codigo and a.compania = b.compania and a.codigo = '"+factura+"' and b.tipo = 'H' and nvl (b.centro_servicio, 0) = 0 and b.medico is not null) group by 'HNF', f.compania, f.codigo, na.tipo, 0, 0, na.medico, null, m.primer_apellido||' '||m.primer_nombre having   sum (decode (na.lado_mov, 'D', na.monto, 'C', -na.monto)) > 0"
				+" union all"
				+"select 'ENF' cargo, f.compania, f.codigo, na.tipo, 0, na.empresa empresa, '0', e.nombre nombre_empresa, null, null, sum (decode (na.lado_mov, 'D', nvl (na.monto, 0), 'C', -nvl (na.monto, 0))) from tbl_fac_factura f, vw_con_adjustment_gral na, tbl_adm_empresa e where f.codigo = '"+factura+"' and f.compania = "+(String) session.getAttribute("_companyId")+" and na.medico is null and na.empresa is not null and na.compania = f.compania and na.factura = f.codigo and na.empresa = e.codigo and na.empresa not in (select distinct b.med_empresa from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania ="+(String) session.getAttribute("_companyId")+" and a.codigo = b.fac_codigo and a.compania = b.compania and a.codigo = '"+factura+"' and nvl (b.centro_servicio, 0) = 0 and b.tipo = 'E' and b.medico is null and nvl b.med_empresa is not null) group by 'ENF', f.compania, f.codigo, na.tipo, 0, na.empresa, '0', e.nombre, null having   sum (decode (na.lado_mov, 'D', na.monto, 'C', -na.monto)) > 0"
			+") z"
		+") a where (nvl (a.monto, 0) - nvl (a.monto_pago, 0) + nvl (a.ajustes, 0)) > 0 order by 6,1";
  } else if(tipoCliente.equals("R")){
    sql = "select z.*, ' ' facCodigo, ' ' estado, 'P' estatus, decode(sign(z.monto - z.monto_pago), 1, decode(z.tipo, 'C', z.centro_servicio, 'H', z.medico, 'E', z.med_empresa, 'M', z.centro_servicio)) codTrabajo, decode(sign(z.monto-z.monto_pago), 1, decode(z.tipo, 'C', z.nombre_centro, 'H', z.nombre_medico, 'E', z.nombre_empresa, 'M', z.nombre_centro)) trabajo, z.centro_servicio centroServicio, z.med_empresa empreCodigo, z.medico medCodigo, '"+cod_rem+"' codRem, nvl(decode(sign(z.monto-z.monto_pago),1,z.monto-z.monto_pago),0) montoCentro from ("
			+"select a.*, nvl((case when a.tipo = 'C' then (select sum(dp.monto) from tbl_cja_distribuir_pago dp where cod_rem = "+cod_rem+" and compania = "+(String) session.getAttribute("_companyId")+" and centro_servicio = a.centro_servicio group by centro_servicio, cod_rem) when a.tipo = 'H' or a.cod = 'H' then (select sum(dp.monto) from tbl_cja_distribuir_pago dp where cod_rem = "+cod_rem+" and compania = "+(String) session.getAttribute("_companyId")+" and med_codigo = a.medico group by med_codigo, cod_rem) when a.tipo = 'E' or a.cod = 'E' then (select sum(dp.monto) from tbl_cja_distribuir_pago dp where cod_rem = "+cod_rem+" and compania = "+(String) session.getAttribute("_companyId")+" and empre_codigo = a.med_empresa group by med_codigo, cod_rem) when a.tipo = 'M' or a.cod = 'C' then (select sum(dp.monto) from tbl_cja_distribuir_pago dp where cod_rem = "+cod_rem+" and compania = "+(String) session.getAttribute("_companyId")+" and (centro_servicio = a.centro_servicio or centro_servicio is null) group by centro_servicio, cod_rem) end),0) monto_pago from ("
				+"select r.compania, dr.factura, dr.renglon, dr.tipo, dr.centro_servicio, dr.med_empresa, dr.medico, sum (decode (r.tipo, '2', dr.monto, '7', -dr.monto)) monto, e.nombre nombre_empresa, m.primer_nombre|| ' '|| m.segundo_nombre|| ' '|| m.primer_apellido|| ' '|| m.apellido_de_casada nombre_medico, decode(dr.tipo,'C', cs.descripcion,decode (dr.tipo,'M', (decode (cs.descripcion, null, 'PERDIEM', cs.descripcion)), decode (dr.tipo,'P', (decode (cs.descripcion, null, 'COPAGO', cs.descripcion))))) nombre_centro, decode(dr.tipo, 'C', decode(dr.medico, null, decode(dr.med_empresa, null, 'C', 'E'), 'H'), 'H', decode(dr.medico, null, 'E'), 'E', decode(dr.med_empresa, null, 'H'), 'M', decode(dr.medico, null, decode(dr.med_empresa, null, 'C', 'E'), 'H')) cod from tbl_fac_remanente r, tbl_fac_det_remanente dr, tbl_cds_centro_servicio cs, tbl_adm_empresa e, tbl_adm_medico m where dr.codigo = "+cod_rem+" and r.codigo = "+cod_rem+" and r.compania = "+(String) session.getAttribute("_companyId")+" and dr.compania = r.compania and dr.codigo = r.codigo and dr.centro_servicio = cs.codigo(+) and dr.med_empresa = e.codigo(+) and dr.medico = m.codigo(+) and dr.monto > 0 group by r.compania, dr.factura, dr.renglon, dr.tipo, dr.centro_servicio, dr.med_empresa, dr.medico, e.nombre, m.primer_nombre|| ' '|| m.segundo_nombre|| ' '|| m.primer_apellido|| ' '|| m.apellido_de_casada, decode (dr.tipo,'C', cs.descripcion,decode (dr.tipo,'M', (decode (cs.descripcion,null, 'PERDIEM',cs.descripcion)), decode (dr.tipo,'P', (decode(cs.descripcion,null, 'COPAGO',cs.descripcion))))),decode(dr.tipo, 'C', decode(dr.medico, null, decode(dr.med_empresa, null, 'C', 'E'), 'H'), 'H', decode(dr.medico, null, 'E'), 'E', decode(dr.med_empresa, null, 'H'), 'M', decode(dr.medico, null, decode(dr.med_empresa, null, 'C', 'E'), 'H'))"
			+") a"
		+") z";
  }
System.out.println("distribucion sql...\n"+sql);

        al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleDistribuirPago.class);
      
	  }
	    HashDistri.clear(); 
        lastLineNo = al.size();
		
				

        for (int i = 1; i <= al.size(); i++)
        {
          if (i < 10) key = "00" + i;
          else if (i < 100) key = "0" + i;
          else key = "" + i;
          HashDistri.put(key, al.get(i-1)); 
          
        //key = al3.get(i - 1).toString();                    
        DetalleDistribuirPago ddpe = (DetalleDistribuirPago) HashDistri.get(key);
        sumMonto += Double.parseDouble(ddpe.getMontoCentro());
        }
		
		sbSql = new StringBuffer();
		sbSql.append(" select nvl(sum(nvl(montocentro,0)),0) monto, ");
		sbSql.append(" nvl(( select nvl(monto,0) montoAplicado from tbl_cja_detalle_pago dp where dp.codigo_transaccion = ");
		sbSql.append(codigo);
		sbSql.append(" and dp.compania =");
		sbSql.append(compania);
		sbSql.append(" and dp.tran_anio =");
		sbSql.append(anio);
		sbSql.append(" and dp.secuencia_pago =");
		sbSql.append(secuenciaPago);
		sbSql.append("),0) montoAplicado ");
		sbSql.append(" from (");
		sbSql.append(sql);
		sbSql.append(") group by ");
		sbSql.append(codigo);
		sbSql.append(",");
		sbSql.append(compania);
		sbSql.append(",");
		sbSql.append(anio);
		sbSql.append(",");
		sbSql.append(secuenciaPago);
		
		Double montocentro =0.00;
		
		CommonDataObject cdoMC = SQLMgr.getData(sbSql.toString()); 
		if(cdoMC != null ){
		montocentro = Double.parseDouble(cdoMC.getColValue("monto"));
		montoAplicado = Double.parseDouble(cdoMC.getColValue("montoAplicado"));
		}
		sbSql = new StringBuffer();
		
		
		
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'DISTRIBUIR PAGOS - '+document.title;

function enviar(fName,actionValue){
	if(formFactorValidation()){
  montoAplicado = parseFloat(document.getElementById("montoAplicado").value);
    total = parseFloat(document.getElementById("total").value);
if(confirm("¿Seguro desea guardar?")){
  monto = parseFloat(document.getElementById('monto').value);
  if(total <= monto){ 
 	if(total <= montoAplicado ){
	 setBAction(fName,actionValue);}
	 else{alert('¡Distribución Manual Incorrecta! El \"total\" debe ser menor o igual a '+monto);return;}
  } else {
  alert('¡Distribución Manual Incorrecta! El \"total\" debe ser menor o igual a '+monto);
  return;
  }
  }
  }
  
}


function setBAction(fName,actionValue)
{
  document.forms[fName].baction.value = actionValue; 
  document.forms[fName].submit();
}

function calcAuto(){
maximo = parseInt(document.formFactor.size.value);
for (i=0; i < maximo; i++){
  document.getElementById('monto'+i).value = ''+document.getElementById('montoAuto'+i).value;
}
gTotal(-1);
document.getElementById('distribucion').value = 'A';
alert('Distribución Automática Completada');
}


function gTotal(x){
// ------------------------------ inicio gTotal --------------------------------------
document.getElementById('distribucion').value = 'M';

  var total = 0.00;
  var nTotal = 0.00;
  var totalx = 0.00;
  maximo = parseInt(document.formFactor.size.value);
  cantidad = parseFloat(document.getElementById('monto').value);

  if (!(cantidad >= 0 )){ cantidad = 0; }
  for (i=0; i < maximo; i++){
		if(document.getElementById('monto'+i).value=='') document.getElementById('monto'+i).value = 0;
    if (parseFloat(document.getElementById('monto'+i).value) > parseFloat(document.getElementById('montoCentro'+i).value)){
      document.getElementById('monto'+i).value = document.getElementById('montoCentro'+i).value;
    }

    if(!(parseFloat(document.getElementById('monto'+i).value) >= 0)){ 
      //document.getElementById('monto'+i).value=0; 
      totalx=0; 
    } else { 
      totalx=parseFloat(document.getElementById('monto'+i).value.replace(',','')); 
    }


    nTotal = total + totalx;
    if(nTotal > cantidad){ 
      totalx = Math.round((totalx - (nTotal - cantidad))*100)/100; 
      document.getElementById('monto'+i).value = totalx;
    } else if (nTotal < cantidad && (i+1)==maximo){
			totalx = Math.round((totalx + (cantidad - nTotal))*100)/100; 
			if(totalx>parseFloat(document.getElementById('montoCentro'+i).value)) totalx = parseFloat(document.getElementById('montoCentro'+i).value);
			if((x+1)==maximo && totalx>parseFloat(document.getElementById('monto'+i).value.replace(',',''))) totalx=parseFloat(document.getElementById('monto'+i).value.replace(',',''));
      document.getElementById('monto'+i).value = totalx;
    }
    total += totalx;
  }
  document.getElementById("total").value = Math.round(total*100)/100; 
// ------------------------------ fin gTotal --------------------------------------
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:gTotal()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="DISTRIBUIR PAGO"></jsp:param>
</jsp:include>



<table align="center" width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">

<table align="center" width="100%" cellpadding="0" cellspacing="1">   
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
System.out.println("monto="+monto);
System.out.println("montocentro="+montocentro);
if(Double.parseDouble(monto)>montocentro) monto = ""+montocentro;
System.out.println("monto="+monto);
%>
	  <%fb = new FormBean("formFactor",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	  <%=fb.formStart(true)%> 
      <%=fb.hidden("baction","")%>
      <%=fb.hidden("lastLineNo",""+lastLineNo)%>
      <%=fb.hidden("mode", mode)%>
      <%=fb.hidden("keySize",""+HashDistri.size())%>      
      <%=fb.hidden("factorDesc", "")%>
      <%=fb.hidden("id", "")%>
      <%=fb.hidden("codigoTransaccion", ""+request.getParameter("codigoTransaccion"))%>
      <%=fb.hidden("secuenciaPago", ""+request.getParameter("secuenciaPago"))%>
      <%=fb.hidden("codTransaccion", ""+request.getParameter("codTransaccion"))%>
      <%=fb.hidden("anio", ""+request.getParameter("anio"))%>
      <%=fb.hidden("compania", ""+request.getParameter("compania"))%>
      <%=fb.hidden("tipoTransaccion", ""+request.getParameter("tipoTransaccion"))%>
	  <%=fb.hidden("montoAplicado", ""+montoAplicado)%>     
      <%=fb.hidden("monto", ""+monto)%>     
      <%=fb.hidden("estatus", "P")%>      
      <%=fb.hidden("pagado", "N")%>
      <%=fb.hidden("distribucion", "A")%>
      <%=fb.hidden("tipoCliente", tipoCliente)%>
      <%=fb.hidden("cod_rem", cod_rem)%>
      <%=fb.hidden("recibo", request.getParameter("recibo"))%>
      <%=fb.hidden("fg", fg)%>
	  <%=fb.hidden("fp", fp)%>
	  <%=fb.hidden("fg2", fg2)%>
      
      <tr class="TextHeader" align="center">
        <td width="8%"><cellbytelabel>No.</cellbytelabel></td>
        <td width="20%"><cellbytelabel>Tipo</cellbytelabel></td>
        <td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
        <td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel> </td>                 
        <td width="35%"><cellbytelabel>Nombre</cellbytelabel></td>
        <td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
        <td><cellbytelabel>Monto Distribuido</cellbytelabel></td>
        <td width="7%">&nbsp;</td>
    </tr>



<%
int lc = 0;
al2 = CmnMgr.reverseRecords(HashDistri);  
for (int i = 0; i < HashDistri.size(); i++)
{
  key = al2.get(i).toString();                    
  DetalleDistribuirPago ddp = (DetalleDistribuirPago) HashDistri.get(key);
  
         String color = "TextRow02";
         if (i % 2 == 0) color = "TextRow01";
%>
         <%=fb.hidden("estado"+i,"")%>
         <%=fb.hidden("key"+i,key)%>
         <%=fb.hidden("remove"+i,"")%>
         <%=fb.hidden("fecha"+i,"")%>
         <%=fb.hidden("pac_id"+i,"")%>
         <%=fb.hidden("centroServicio"+i,""+ddp.getCentroServicio())%>
         <%=fb.hidden("empreCodigo"+i,""+ddp.getEmpreCodigo().trim())%>
         <%=fb.hidden("estatus"+i,ddp.getEstatus())%>           
         <%=fb.hidden("facCodigo"+i,""+ddp.getFacCodigo())%>
         <%=fb.hidden("medCodigo"+i,""+ddp.getMedCodigo())%>
         <%=fb.hidden("montoCentro"+i,""+ddp.getMontoCentro())%>
         <%=fb.hidden("tipo"+i,""+ddp.getTipo())%>
         <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
            <td>&nbsp;</td>
            <td><%=ddp.getTipo()%></td>
            <td align="center"><%=ddp.getEstatus()%></td>
            <td><%=ddp.getCodTrabajo()%></td>
            <td><%=ddp.getTrabajo()%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(ddp.getMontoCentro())%>&nbsp;</td>
            <td>
            <% 
            porcentaje = Double.parseDouble(ddp.getMontoCentro())/sumMonto; 
            valor      = porcentaje*Double.parseDouble(monto);
            %>            
            <%=fb.decBox("monto"+i,""+CmnMgr.getFormattedDecimal(valor), false, false,false,10,"Text10","","onKeyUp=\" gTotal("+i+"); \" ")%>
            <%=fb.hidden("montoAuto"+i,""+CmnMgr.getFormattedDecimal(valor))%>
            </td>
            <% totalMonto+= valor;  %>
            <td align="center">&nbsp;</td>
         </tr>
         <% lc++; } %>
         <tr class="TextRow01">
           <td>&nbsp;</td>
           <td>&nbsp;</td>
           <td>&nbsp;</td>
           <td>&nbsp;</td>
           <td align="right"><cellbytelabel>Total</cellbytelabel>:</td>
           <td align="center">&nbsp;</td>
           <td><%=fb.decBox("total",""+CmnMgr.getFormattedDecimal(totalMonto), false, false,true,10,"Text10","","")%></td>
           <td>&nbsp;</td>
        </tr>
        <tr class="TextRow01">
        <td colspan="8" align="right">
        <%=fb.button("distriAuto","Distribución Automática",false,(viewMode||al.size()==0),"Text10",null," onClick=\"javascript:calcAuto()\" ","Guardar")%>
        <%=fb.button("guardar","Guardar",false,(viewMode||al.size()==0),"Text10",null,"onClick=\"javascript:enviar('"+fb.getFormName()+"',this.value)\"","Guardar")%>
        <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
        </td>     
        </tr>

<%=fb.hidden("size",""+HashDistri.size())%>
<%=fb.formEnd(true)%>     
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>

    </td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{

System.out.println("==================== iniciando POST  =================");

ArrayList list = new ArrayList();
String baction = request.getParameter("baction");
String itemRemoved = "";
int keySize =  Integer.parseInt(request.getParameter("keySize"));

TransaccionPago trpgo = new TransaccionPago();
	trpgo.setCompania(request.getParameter("compania"));
	trpgo.setAnio(request.getParameter("anio"));
	trpgo.setCodigo(request.getParameter("codigoTransaccion"));
	trpgo.setSecuenciaPago(request.getParameter("secuenciaPago"));
	
	  for (int i=0; i< keySize; i++)
      {
      DetalleDistribuirPago disp = new DetalleDistribuirPago();

      //disp.setSecuencia()
      disp.setCompania(""+request.getParameter("compania"));
      disp.setCodigoTransaccion(""+request.getParameter("codigoTransaccion"));
      disp.setTranAnio(""+request.getParameter("anio"));
      disp.setSecuenciaPago(""+request.getParameter("secuenciaPago"));
      disp.setTipo(""+request.getParameter("tipo"+i));

      if(request.getParameter("centroServicio"+i)!=null && !request.getParameter("centroServicio"+i).equals("") && !request.getParameter("centroServicio"+i).equals("null")) disp.setCentroServicio(request.getParameter("centroServicio"+i));
      if(request.getParameter("medCodigo"+i)!=null && !request.getParameter("medCodigo"+i).equals("") && !request.getParameter("medCodigo"+i).equals("null")) disp.setMedCodigo(""+request.getParameter("medCodigo"+i));
      if(request.getParameter("empreCodigo"+i)!=null && !request.getParameter("empreCodigo"+i).equals("") && !request.getParameter("empreCodigo"+i).equals("null") && !request.getParameter("empreCodigo"+i).equals("0")) disp.setEmpreCodigo(request.getParameter("empreCodigo"+i));
      if(request.getParameter("estatus"+i)!=null && !request.getParameter("estatus"+i).equals("") && !request.getParameter("estatus"+i).equals("null")) disp.setEstatus(request.getParameter("estatus"+i));
      if(request.getParameter("facCodigo"+i)!=null && !request.getParameter("facCodigo"+i).equals("") && !request.getParameter("facCodigo"+i).equals("null")) disp.setFacCodigo(request.getParameter("facCodigo"+i));
      if(request.getParameter("monto"+i)!=null && !request.getParameter("monto"+i).equals("") && !request.getParameter("monto"+i).equals("null")) disp.setMonto(request.getParameter("monto"+i).replace(",",""));
      System.out.println("empreCodigo="+request.getParameter("empreCodigo"+i));
      disp.setTipoCliente(request.getParameter("tipoCliente"));
      disp.setTipoTransaccion(request.getParameter("tipoTransaccion"));
      
      disp.setDistribucion(""+request.getParameter("distribucion"));
      disp.setUsuarioCreacion(""+UserDet.getUserName());
      disp.setUsuarioModificacion(""+UserDet.getUserName());
      disp.setFechaCreacion(""+cDate);
      disp.setFechaModificacion(""+cDate);
      if(disp.getMonto()!=null && !disp.getMonto().equals("")) list.add(disp);
      }


if (request.getParameter("baction") != null && request.getParameter("baction").equalsIgnoreCase("guardar"))
{ 
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"tipoCliente="+tipoCliente+"&fg="+fg+"&fp="+fp+"&fg2="+fg2);
	trpgo.setDetalleDistribuirPago(list);
	TPMgr.addDetalleDistribuirPago(trpgo);
	ConMgr.clearAppCtx(null);
}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
// -----------------------------------------------------------------------------------------------------------
<%
if (TPMgr.getErrCode().equals("1"))
{%>
  alert('<%=TPMgr.getErrMsg()%>');
<%		if ((fg.equals("") && (tipoCliente.equalsIgnoreCase("ARE") || tipoCliente.equalsIgnoreCase("ARP"))) || fg.equals("aplicarRecibos"))
		{
%>
	window.opener.location = '../caja/aplicar_recibo_emp_det.jsp?codigo=<%=request.getParameter("codigoTransaccion")%>&tipoCliente=<%=tipoCliente%>&mode=<%=mode%>&compania=<%=request.getParameter("compania")%>&anio=<%=request.getParameter("anio")%>&fp=<%=request.getParameter("fp")%>&fg=<%=request.getParameter("fg2")%>';
<%
		} else 	{
%>
  window.opener.location = '<%="../caja/detalletransaccion_config.jsp?codigo="+request.getParameter("codigoTransaccion")+"&recibo="+request.getParameter("recibo")+"&tipoCliente="+request.getParameter("tipoCliente")+"&mode="+request.getParameter("mode")%>&compania=<%=request.getParameter("compania")%>';
<%
		}
%>
  window.close();
<%
} else throw new Exception(TPMgr.getErrMsg());
%>

// -----------------------------------------------------------------------------------------------------------
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>