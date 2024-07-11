<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="issi.caja.DetalleDistribuirPago"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="TPMgr" scope="page" class="issi.caja.TransaccionPagoMgr"/>
<%
/**
================================================================================
distribucion.fmb
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
TPMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String tipoCliente = request.getParameter("tipoCliente");
String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String secuenciaPago = request.getParameter("secuenciaPago");
String idx = request.getParameter("idx");
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");

if (tipoCliente == null || tipoCliente.trim().equals("")) throw new Exception("El Tipo de Recibo no es válido. Por favor intente nuevamente!");
else if (!tipoCliente.equalsIgnoreCase("E") && !tipoCliente.equalsIgnoreCase("P")) throw new Exception("La Distribución sólo es aplicable para los Recibos de Paciente o Empresa!");
if (codigo == null || codigo.trim().equals("") || compania == null || compania.trim().equals("") || anio == null || anio.trim().equals("") || secuenciaPago == null || secuenciaPago.trim().equals("")) throw new Exception("El Detalle de Recibo no es válido. Por favor intente nuevamente!");
if (idx == null) idx = "";
if (idx.trim().equals("")) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (tipoCliente.equalsIgnoreCase("P") && (pacId.trim().equals("") || admision.trim().equals(""))) throw new Exception("El Paciente o la Admisión no es válida. Por favor intente nuevamente!");

if (fg == null) fg = "";
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql = new StringBuffer();
	sbSql.append("select a.pago_por as docType, decode(a.pago_por,'F','FACTURA','R','REMANENTE','D','ADMISION') as docTypeDesc, decode(a.pago_por,'D',''||a.admi_secuencia,'F',fac_codigo,'R',''||a.cod_rem) as docNo, decode(a.admi_secuencia,null,' ',''||a.admi_secuencia) as admision, decode(a.cod_rem,null,' ',''||a.cod_rem) as remanente, nvl(a.fac_codigo,' ') as factura, nvl(to_char(a.doc_fecha,'dd/mm/yyyy'),' ') as fecha, nvl(a.doc_a_nombre,' ') as nombre, a.monto, a.tipo_transaccion as tipoTransaccion,nvl(b.rec_status,'A')rec_status from tbl_cja_detalle_pago a ,tbl_cja_transaccion_pago b where a.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.tran_anio = ");
	sbSql.append(anio);
	sbSql.append(" and a.codigo_transaccion = ");
	sbSql.append(codigo);
	sbSql.append(" and a.secuencia_pago = ");
	sbSql.append(secuenciaPago);
	sbSql.append(" and a.tran_anio = b.anio and a.compania = b.compania and a.codigo_transaccion = b.codigo");
	
	CommonDataObject dp = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select a.secuencia, a.fac_codigo as facCodigo, a.tipo, a.centro_servicio as centroServicio, a.med_codigo as medCodigo, a.empre_codigo as empreCodigo, a.monto, nvl(a.estatus,' ')estatus, 0 as montoCentro, decode(a.tipo,'C',nvl(''||a.centro_servicio,' '),'H',(select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = a.med_codigo),'E',''||a.empre_codigo,' ') as codTrabajo, decode(a.tipo,'C',(nvl(nvl((select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),a.desc_distribucion),'CO-PAGO/PERDIEM')),'H',(select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||apellido_de_casada from tbl_adm_medico where codigo = a.med_codigo),'E',(select nombre from tbl_adm_empresa where codigo = a.empre_codigo),'P','CO-PAGO','M','PERDIEM',null,'SALDO INICIAL') as trabajo,nvl(a.num_cheque,' ')numCheque from tbl_cja_distribuir_pago a where a.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.tran_anio = ");
	sbSql.append(anio);
	sbSql.append(" and a.codigo_transaccion = ");
	sbSql.append(codigo);
	sbSql.append(" and a.secuencia_pago = ");
	sbSql.append(secuenciaPago);
	sbSql.append(" order by secuencia");
	System.out.println("distribuido sql...\n"+sbSql);
	al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),DetalleDistribuirPago.class);
	
	System.out.println("distribucion  docType === "+dp.getColValue("docType"));
	if ((viewMode &&!fg.trim().equals("A")) || al.size() > 0|| dp.getColValue("rec_status").trim().equals("I")) viewMode = true;
	else
	{
		sbSql = new StringBuffer();
		if (dp.getColValue("docType").equalsIgnoreCase("F"))
		{
			sbSql.append(" select compania,fac_codigo facCodigo, cargo other1,decode(tipo,null,' ',nvl(tipo,' '))tipo, 'P' as estatus,centro_servicio centroServicio,  nvl(decode(tipo,'C',to_char(centro_servicio),'H',(select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = z.medico),'E',to_char(med_empresa)),' ') as codTrabajo, nvl(decode(tipo,'C',nvl(nombre_centro,' '),'H',nombre_medico,'E',nombre_empresa,nombre_centro),'CO-PAGO/PERDIEM') as trabajo, nvl(to_char(med_empresa),' ') empreCodigo,  nvl(medico,' ') medCodigo,ajustes, (nvl (monto, 0) - nvl (monto_pago, 0) + nvl (ajustes, 0)) montoCentro,'' as cdsCop,trim(replace(trim(nombre_centro),chr(10),'')) as  descDistribucion from (");

			sbSql.append(" select v.cargo,v.compania,v.fac_codigo , v.tipo, v.centro_servicio, v.med_empresa, v.medico, v.monto, v.nombre_empresa, v.nombre_medico, v.nombre_centro ");

			//monto_pago-------------------------------------------------------------------------------------------
			//centro
			sbSql.append(", case when nvl(v.centro_servicio,-1) <> 0 and v.med_empresa is null and v.medico is null and v.cargo in ('CF','CNF') then");
			if (tipoCliente.equalsIgnoreCase("E"))
			{
				sbSql.append(" (case when v.centro_servicio is null then (select sum(nvl(dp.monto,0)) from tbl_cja_distribuir_pago dp,tbl_cja_transaccion_pago tp where dp.fac_codigo=v.fac_codigo and dp.compania=v.compania and dp.cod_rem is null and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A' and dp.med_codigo is null and dp.empre_codigo is null and (dp.tipo_cobertura='P' or dp.centro_servicio is null)) else (case when v.tipo_cobertura in ('P','CO') then (select sum(monto) from tbl_cja_distribuir_pago where fac_codigo=v.fac_codigo and compania=v.compania and med_codigo is null and empre_codigo is null and (tipo_cobertura in ('P','CO') or centro_servicio is null)) else (select sum(nvl(dp.monto,0)) from tbl_cja_distribuir_pago dp,tbl_cja_transaccion_pago tp where dp.fac_codigo=v.fac_codigo and dp.compania=v.compania and centro_servicio=v.centro_servicio and dp.tipo_cobertura is null and dp.cod_rem is null and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A' group by dp.centro_servicio,dp.fac_codigo) end) end) ");
			
			}
			else if (tipoCliente.equalsIgnoreCase("P"))
			{
				sbSql.append(" case when v.centro_servicio is not null then (select coalesce(sum(decode(dp.tipo_cobertura, null,nvl(dp.monto,0))), sum(decode(dp.tipo_cobertura,'CO',nvl(dp.monto,0)))) from tbl_cja_distribuir_pago dp,tbl_cja_transaccion_pago tp where dp.fac_codigo = v.fac_codigo and dp.compania = v.compania and dp.centro_servicio = v.centro_servicio and cod_rem is null and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A' group by centro_servicio, fac_codigo) ");
				//CO-PAGO 
				sbSql.append(" when  v.nombre_centro  like '%COPAGO%' then (select sum (nvl (decode(dp.tipo_cobertura, 'CO', nvl(dp.monto,0)),0))+sum(nvl(decode(centro_servicio, null,nvl(dp.monto,0)),0)) from tbl_cja_distribuir_pago dp,tbl_cja_transaccion_pago tp where dp.fac_codigo = v.fac_codigo and dp.compania = v.compania and dp.med_codigo is null and dp.empre_codigo is null and dp.cod_rem is null and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A'  and  nvl(trim(dp.desc_distribucion),trim(replace(trim(v.nombre_centro),chr(10),'')))=trim(replace(trim(v.nombre_centro),chr(10),'')) ) ");
				//OTROS CASOS 
				sbSql.append(" else (select sum (nvl (decode(dp.tipo_cobertura, 'CO', nvl(dp.monto,0)),0))+sum(nvl(decode(centro_servicio, null,nvl(dp.monto,0)),0)) from tbl_cja_distribuir_pago dp,tbl_cja_transaccion_pago tp where dp.fac_codigo = v.fac_codigo and dp.compania = v.compania and dp.med_codigo is null and dp.empre_codigo is null and dp.cod_rem is null and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A' and dp.cds_cop is null  ) end ");
			}
			//medico
			sbSql.append(" when v.medico is not null and v.med_empresa is null and v.cargo in ('CF','HNF') then");
			//if (tipoCliente.equalsIgnoreCase("E"))
			//{
				sbSql.append(" (select nvl(sum(dp.monto),0) from tbl_cja_distribuir_pago dp, tbl_cja_transaccion_pago tp where dp.fac_codigo = v.fac_codigo and dp.compania = v.compania and dp.med_codigo = v.medico and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A' group by dp.med_codigo,dp.fac_codigo)");/*!!reemplazado group by dp.centro_servicio, dp.fac_codigo*/
			//}
			/*else if (tipoCliente.equalsIgnoreCase("P"))
			{
				sbSql.append(" (select nvl(sum(dp.monto),0) from tbl_cja_transaccion_pago tp, tbl_cja_detalle_pago dd, tbl_cja_distribuir_pago dp where tp.tipo_cliente = 'P' and tp.rec_status = 'A' and tp.pac_id = ");
				sbSql.append(pacId);
				sbSql.append(" and dd.admi_secuencia = ");
				sbSql.append(admision);
				sbSql.append(" and dp.med_codigo = v.medico and tp.compania = dd.compania and tp.anio = dd.tran_anio and tp.codigo = dd.codigo_transaccion and dd.compania = dp.compania and dd.tran_anio = dp.tran_anio and dd.codigo_transaccion = dp.codigo_transaccion and dd.secuencia_pago = dp.secuencia_pago group by dp.centro_servicio)");
			}*/
			//empresa
			sbSql.append(" when v.med_empresa is not null and v.medico is null and v.cargo in ('CF', 'ENF') then");
			//if (tipoCliente.equalsIgnoreCase("E"))
			//{
				sbSql.append(" (select nvl(sum(dp.monto),0) from tbl_cja_distribuir_pago dp, tbl_cja_transaccion_pago tp where dp.fac_codigo = v.fac_codigo and dp.compania = v.compania and dp.empre_codigo = v.med_empresa and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A' group by dp.empre_codigo, dp.fac_codigo)");/*!!reemplazado dp.centro_servicio, dp.fac_codigo*/
			//}
			/*else if (tipoCliente.equalsIgnoreCase("P"))
			{
				sbSql.append(" (select nvl(sum(dp.monto),0) from tbl_cja_transaccion_pago tp, tbl_cja_detalle_pago dd, tbl_cja_distribuir_pago dp where tp.tipo_cliente = 'P' and tp.rec_status = 'A' and tp.pac_id = ");
				sbSql.append(pacId);
				sbSql.append(" and dd.admi_secuencia = ");
				sbSql.append(admision);
				sbSql.append(" and dp.empre_codigo = v.med_empresa and tp.compania = dd.compania and tp.anio = dd.tran_anio and tp.codigo = dd.codigo_transaccion and dd.compania = dp.compania and dd.tran_anio = dp.tran_anio and dd.codigo_transaccion = dp.codigo_transaccion and dd.secuencia_pago = dp.secuencia_pago group by dp.centro_servicio)");
			}*/
			sbSql.append(" end as monto_pago");

			//ajustes-------------------------------------------------------------------------------------------
			//centro
			sbSql.append(", case when nvl(v.centro_servicio,-1) <> 0 and v.med_empresa is null and v.medico is null and v.cargo in ('CF','CNF') then case when v.centro_servicio is null then");
			//if (tipoCliente.equalsIgnoreCase("E"))
			//{
				sbSql.append(" decode(v.cargo,'CNF',0,(select nvl(sum(decode(lado_mov,'D',monto,'C',-monto)),0) from vw_con_adjustment_gral where factura = v.fac_codigo and compania = v.compania and centro is null and medico is null and empresa is null and tipo in (null,'M','P')))");
			/*}
			else if (tipoCliente.equalsIgnoreCase("P"))
			{
				sbSql.append(" decode(v.cargo,'CNF',0,(select nvl(sum(decode(lado_mov,'D',monto,'C',-monto)),0) from vw_con_adjustment_gral where factura = v.fac_codigo and compania = v.compania and centro is null and tipo in (null,'P')))");
			}*/
			sbSql.append(" else decode(v.cargo,'CNF',0,(select nvl(sum(decode(lado_mov,'D',monto,'C',-monto)),0) from vw_con_adjustment_gral where factura = v.fac_codigo and compania = v.compania and centro = v.centro_servicio)) end");
			//medico
			sbSql.append(" when v.medico is not null and v.cargo in ('CF','HNF') then decode(v.cargo,'HNF',0,(select nvl(sum(decode(lado_mov,'D',monto,'C',-monto)),0) from vw_con_adjustment_gral where factura = v.fac_codigo and compania = v.compania and medico = v.medico))");
			//empresa
			sbSql.append(" when v.med_empresa is not null and v.cargo in ('CF','ENF') then decode(v.cargo,'ENF',0,(select nvl(sum(decode(lado_mov,'D',monto,'C',-monto)),0) from vw_con_adjustment_gral where factura = v.fac_codigo and compania = v.compania and empresa = v.med_empresa))");
			sbSql.append(" end as ajustes,v.cds_cop");

			sbSql.append(" from (");
			// cargos facturados
			sbSql.append("select 'CF' as cargo, a.compania, a.fac_codigo, a.tipo, to_char(a.centro_servicio) as centro_servicio, a.med_empresa as med_empresa, a.medico, sum(nvl(a.monto,0)) - decode(b.nueva_formula,'S',0,nvl(getCopagoDet(a.compania,a.fac_codigo,nvl(to_char(a.med_empresa),a.medico),c.descripcion,b.pac_id,b.admi_secuencia,'DIST'),0))as monto, (select nombre from tbl_adm_empresa where codigo = a.med_empresa) as nombre_empresa, (select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||apellido_de_casada from tbl_adm_medico where codigo = a.medico) as nombre_medico, /*decode(a.centro_servicio,null,decode(b.facturar_a,'E',case when a.descripcion like '%PERDIEM%' then 'PERDIEM' when a.descripcion like '%PAQ%' then 'PAQUETE' else a.descripcion end,'P','CO-PAGO'),c.descripcion)*/ nvl(a.descripcion,c.descripcion) as nombre_centro,b.tipo_cobertura,null as cds_cop from (select compania, fac_codigo, centro_servicio, medico, med_empresa, tipo, decode(centro_servicio, -2, 'COPAGO', descripcion) descripcion, sum(monto) monto from tbl_fac_detalle_factura where compania = ");
			sbSql.append(compania);
			sbSql.append(" AND fac_codigo = '");
			sbSql.append(dp.getColValue("docNo"));
			sbSql.append("' group by compania, fac_codigo, centro_servicio, medico, med_empresa, tipo, decode(centro_servicio, -2, 'COPAGO', descripcion)) a, tbl_fac_factura b, tbl_cds_centro_servicio c where a.compania = ");
			sbSql.append(compania);
			sbSql.append(" and a.fac_codigo = '");
			sbSql.append(dp.getColValue("docNo"));
			sbSql.append("' and a.compania = b.compania and a.fac_codigo = b.codigo and a.centro_servicio = c.codigo(+) group by b.nueva_formula,a.compania,b.tipo_cobertura, a.fac_codigo, a.tipo, a.centro_servicio, to_char(a.med_empresa),a.medico, /*decode(a.centro_servicio,null,decode(b.facturar_a,'E',case when a.descripcion like '%PERDIEM%' then 'PERDIEM' when a.descripcion like '%PAQ%' then 'PAQUETE' else a.descripcion end,'P','CO-PAGO'),c.descripcion)*/ c.descripcion,b.pac_id,b.admi_secuencia, nvl(a.descripcion,c.descripcion),a.med_empresa");
			sbSql.append(" union all ");
			// cargos no facturados
			sbSql.append("select 'CNF' as cargo, a.compania, a.factura, a.tipo, to_char(a.centro) as centro, 0, '0', sum(decode(a.lado_mov,'D',a.monto,'C',-a.monto)), null, null, decode(a.tipo,'P','CO-PAGO','M','PERDIEM',(select descripcion from tbl_cds_centro_servicio where codigo = a.centro)) as nombre_centro,null as tipo_cobertura , a.cds_cop from vw_con_adjustment_gral a   where a.compania = ");
			sbSql.append(compania);
			sbSql.append(" and a.factura = '");
			sbSql.append(dp.getColValue("docNo"));
			sbSql.append("' and a.medico is null and a.empresa is null and nvl(a.centro,-1) not in (select nvl(centro_servicio,-1) from tbl_fac_detalle_factura where compania = a.compania and fac_codigo = a.factura and med_empresa is null and medico is null) group by a.compania, a.factura, a.tipo, a.centro,a.cds_cop having sum(decode(a.lado_mov,'D',a.monto,'C',-a.monto)) > 0");
			sbSql.append(" union all ");
			// honorarios no facturados
			sbSql.append("select 'HNF' as cargo, a.compania, a.factura, a.tipo, '0', 0, a.medico, sum(decode(a.lado_mov,'D',nvl(a.monto,0),'C',-nvl(a.monto,0))), null, (select primer_apellido||' '||primer_nombre from tbl_adm_medico where codigo = a.medico) as nombre_medico, null,null tipo_cobertura,a.cds_cop from vw_con_adjustment_gral a where a.compania = ");
			sbSql.append(compania);
			sbSql.append(" and a.factura = '");
			sbSql.append(dp.getColValue("docNo"));
			sbSql.append("' and a.medico is not null and a.empresa is null and a.medico not in (select distinct medico from tbl_fac_detalle_factura where compania = a.compania and fac_codigo = a.factura and tipo = 'H' and nvl(centro_servicio,0) = 0 and medico is not null) group by a.compania, a.factura, a.tipo, a.medico,a.cds_cop having sum(decode(a.lado_mov,'D',a.monto,'C',-a.monto)) > 0");
			sbSql.append(" union all ");
			// empresas no facturadas
			sbSql.append("select 'ENF' as cargo, a.compania, a.factura, a.tipo, '0', a.empresa, '0', sum(decode(a.lado_mov,'D',nvl(a.monto,0),'C',-nvl(a.monto,0))) , (select nombre from tbl_adm_empresa where codigo = a.empresa) as nombre_empresa, null, null,null tipo_cobertura,a.cds_cop from vw_con_adjustment_gral a where a.compania = ");
			sbSql.append(compania);
			sbSql.append(" and a.factura = '");
			sbSql.append(dp.getColValue("docNo"));
			sbSql.append("' and a.medico is null and a.empresa is not null and a.empresa not in (select distinct med_empresa from tbl_fac_detalle_factura where compania = a.compania and fac_codigo = a.factura and tipo = 'E' and nvl(centro_servicio,0) = 0 and medico is null and med_empresa is not null) group by a.compania, a.factura, a.tipo, a.empresa,a.cds_cop having sum(decode(a.lado_mov,'D',a.monto,'C',-a.monto)) > 0");

			sbSql.append(") v");

			sbSql.append(") z where nvl(monto,0) - nvl(monto_pago,0) + nvl(ajustes,0) > 0");
		}//docType = F
		else if (dp.getColValue("docType").equalsIgnoreCase("R"))
		{
		
			sbSql.append("select z.*, ' ' as facCodigo, ' ' as estado, 'P' as estatus, decode(sign(z.monto - z.monto_pago),1,decode(z.tipo,'C',z.centro_servicio,'H',(select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = z.medico),'E',z.med_empresa,'M',z.centro_servicio)) as codTrabajo, decode(sign(z.monto - z.monto_pago),1,decode(z.tipo,'C',z.nombre_centro,'H',z.nombre_medico,'E',z.nombre_empresa,'M',z.nombre_centro)) as trabajo, z.centro_servicio as centroServicio, z.med_empresa as empreCodigo, z.medico as medCodigo, z.codigo as codRem, nvl(decode(sign(z.monto - z.monto_pago),1,z.monto - z.monto_pago),0) as montoCentro from (");
			sbSql.append("select a.*, nvl((case when a.tipo = 'C' then (select nvl(sum(dp.monto),0) from tbl_cja_distribuir_pago dp, tbl_cja_transaccion_pago tp where dp.cod_rem = ");
			sbSql.append(dp.getColValue("docNo"));
			sbSql.append(" and dp.compania = ");
			sbSql.append(compania);
			sbSql.append(" and dp.centro_servicio = a.centro_servicio and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A' group by dp.centro_servicio, dp.cod_rem) when a.tipo = 'H' or a.cod = 'H' then (select nvl(sum(dp.monto),0) from tbl_cja_distribuir_pago dp, tbl_cja_transaccion_pago tp where dp.cod_rem = ");
			sbSql.append(dp.getColValue("docNo"));
			sbSql.append(" and dp.compania = ");
			sbSql.append(compania);
			sbSql.append(" and dp.med_codigo = a.medico and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A' group by dp.med_codigo, dp.cod_rem) when a.tipo = 'E' or a.cod = 'E' then (select nvl(sum(dp.monto),0) from tbl_cja_distribuir_pago dp, tbl_cja_transaccion_pago tp where dp.cod_rem = ");
			sbSql.append(dp.getColValue("docNo"));
			sbSql.append(" and dp.compania = ");
			sbSql.append(compania);
			sbSql.append(" and dp.empre_codigo = a.med_empresa and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A' group by dp.med_codigo, dp.cod_rem) when a.tipo = 'M' or a.cod = 'C' then (select nvl(sum(dp.monto),0) from tbl_cja_distribuir_pago dp, tbl_cja_transaccion_pago tp where dp.cod_rem = ");
			sbSql.append(dp.getColValue("docNo"));
			sbSql.append(" and dp.compania = ");
			sbSql.append(compania);
			sbSql.append(" and (dp.centro_servicio = a.centro_servicio or dp.centro_servicio is null) and dp.codigo_transaccion = tp.codigo and dp.compania = tp.compania and dp.tran_anio = tp.anio and tp.rec_status = 'A' group by dp.centro_servicio, dp.cod_rem) end),0) as monto_pago from (");

			sbSql.append("select r.compania, r.codigo, dr.factura, dr.renglon, dr.tipo, dr.centro_servicio, dr.med_empresa, dr.medico, sum(decode(r.tipo,'2',dr.monto,'7',-dr.monto)) as monto, e.nombre as nombre_empresa, m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.apellido_de_casada as nombre_medico, decode(dr.tipo,'C',cs.descripcion,decode(dr.tipo,'M',(decode(cs.descripcion,null,'PERDIEM',cs.descripcion)),decode(dr.tipo,'P',(decode(cs.descripcion,null,'COPAGO',cs.descripcion))))) as nombre_centro, decode(dr.tipo,'C',decode(dr.medico,null,decode(dr.med_empresa,null,'C','E'),'H'),'H',decode(dr.medico,null,'E'),'E',decode(dr.med_empresa,null,'H'),'M',decode(dr.medico,null,decode(dr.med_empresa,null,'C','E'),'H')) as cod from tbl_fac_remanente r, tbl_fac_det_remanente dr, tbl_cds_centro_servicio cs, tbl_adm_empresa e, tbl_adm_medico m where r.compania = ");
			sbSql.append(compania);
			sbSql.append(" and r.codigo = ");
			sbSql.append(dp.getColValue("docNo"));
			sbSql.append(" and dr.compania = r.compania and dr.codigo = r.codigo and dr.centro_servicio = cs.codigo(+) and dr.med_empresa = e.codigo(+) and dr.medico = m.codigo(+) and dr.monto > 0 group by r.compania, r.codigo, dr.factura, dr.renglon, dr.tipo, dr.centro_servicio, dr.med_empresa, dr.medico, e.nombre, m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.apellido_de_casada, decode(dr.tipo,'C',cs.descripcion,decode(dr.tipo,'M',(decode(cs.descripcion,null,'PERDIEM',cs.descripcion)), decode(dr.tipo,'P',(decode(cs.descripcion,null,'COPAGO',cs.descripcion))))),decode(dr.tipo,'C',decode(dr.medico,null,decode(dr.med_empresa,null,'C','E'),'H'),'H',decode(dr.medico,null,'E'),'E',decode(dr.med_empresa,null,'H'),'M',decode(dr.medico,null,decode(dr.med_empresa,null,'C','E'),'H'))");

			sbSql.append(") a");
			sbSql.append(") z");
		}
		System.out.println("distribucion sql...\n"+sbSql);
		al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),DetalleDistribuirPago.class);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'DISTRIBUIR PAGOS - '+document.title;
function doAction(){<% if (viewMode) { %>calcTotal();<% } else { %>autoCalc();<% } %>}
function autoCalc(){var totalAplicado=parseFloat(document.formDist.totalAplicado.value);var totalDistribuido=parseFloat(document.formDist.totalDistribuido.value);var total=0.00;var pTotal=0.00;var size=document.formDist.size.value;for(i=0;i<size;i++){var monto=0.00;var montoCentro=(eval('document.formDist.montoCentro'+i).value=='')?0.00:parseFloat(eval('document.formDist.montoCentro'+i).value);if(i==size-1){var p=100-pTotal;monto=totalAplicado-total;}else{var p=0;if(totalDistribuido!=0)p=(montoCentro/totalDistribuido)*100;monto=Math.round(totalAplicado*p)/100;}pTotal+=p;if(monto>montoCentro)monto=montoCentro;total+=monto;eval('document.formDist.monto'+i).value=monto.toFixed(2);}document.formDist.total.value=total.toFixed(2);document.formDist.distribucion.value='A';}
function manualCalc(idx){var totalAplicado=parseFloat(document.formDist.totalAplicado.value);var total=0.00;var monto=(eval('document.formDist.monto'+idx).value=='')?0.00:parseFloat(eval('document.formDist.monto'+idx).value);var montoCentro=(eval('document.formDist.montoCentro'+idx).value=='')?0.00:parseFloat(eval('document.formDist.montoCentro'+idx).value);if(monto>montoCentro)monto=montoCentro;total+=monto;if(total>totalAplicado){total=totalAplicado;eval('document.formDist.monto'+idx).value=totalAplicado.toFixed(2);}else eval('document.formDist.monto'+idx).value=total.toFixed(2);var size=document.formDist.size.value;for(i=0;i<size;i++){if(idx!=i){var monto=(eval('document.formDist.monto'+i).value=='')?0.00:parseFloat(eval('document.formDist.monto'+i).value);var montoCentro=(eval('document.formDist.montoCentro'+i).value=='')?0.00:parseFloat(eval('document.formDist.montoCentro'+i).value);if(monto>montoCentro)monto=montoCentro;if(total>=totalAplicado)monto=0.00;else if(total+monto>=totalAplicado)monto=totalAplicado-total;else if(monto>=(totalAplicado-total))monto=totalAplicado-total;total+=monto;eval('document.formDist.monto'+i).value=monto.toFixed(2);}}document.formDist.total.value=total.toFixed(2);document.formDist.distribucion.value='M';}
function calcTotal(){var total=0.00;var size=document.formDist.size.value;var monto=0.00;for(i=0;i<size;i++){if(eval('document.formDist.monto'+i).value!=''){monto=parseFloat(eval('document.formDist.monto'+i).value);eval('document.formDist.monto'+i).value=monto.toFixed(2);total+=monto;}}document.formDist.total.value=total.toFixed(2);}
function isValidTotal(){var totalAplicado=<%=dp.getColValue("monto")%>;var totalCentro=parseFloat(document.formDist.totalCentro.value);var totalDistribuido=parseFloat(document.formDist.total.value);if(totalAplicado>totalCentro){if(totalCentro!=totalDistribuido){top.CBMSG.warning('El Total Distribuido debe ser igual al Monto Total a Distribuir!');return false;}}else if(totalAplicado!=totalDistribuido){top.CBMSG.warning('El Total Distribuido debe ser igual al Monto Aplicado!');return false;}return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DISTRIBUIR PAGO"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="12%">Tipo Doc.</td>
			<td width="13%">Doc. No.</td>
			<td width="10%">Admisi&oacute;n</td>
			<td width="13%">Fecha</td>
			<td width="40%">Nombre</td>
			<td width="12%">Monto Aplicado</td>
		</tr>
		<tr class="TextRow01" align="center">
			<td><%=dp.getColValue("docTypeDesc")%></td>
			<td><%=dp.getColValue("docNo")%></td>
			<td><%=(dp.getColValue("docType").equalsIgnoreCase("F"))?dp.getColValue("admision"):"&nbsp;"%></td>
			<td><%=dp.getColValue("fecha")%></td>
			<td align="left"><%=dp.getColValue("nombre")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(dp.getColValue("monto"))%>&nbsp;</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("formDist",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document.formDist.baction.value=='Guardar'){if(!isValidTotal())error++;else if(!confirm('¿Está seguro guardar?'))error++;}");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("secuenciaPago",secuenciaPago)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("distribucion","")%>
<%=fb.hidden("totalAplicado",dp.getColValue("monto"))%>
<%=fb.hidden("tipoTransaccion",dp.getColValue("tipoTransaccion"))%>
<%=(dp.getColValue("docType").equalsIgnoreCase("R"))?fb.hidden("codRem",dp.getColValue("docNo")):""%>
		<tr class="TextHeader" align="center">
			<td width="8%">No.</td>
			<td width="13%">Tipo</td>
			<td width="7%">Estado</td>
			<td width="7%">C&oacute;digo</td>
			<td width="35%">Nombre</td>
			<td width="10%">Monto a Distribuir</td>
			<td width="12%">Distribuci&oacute;n <% if (!viewMode) { %>(<a href="javascript:autoCalc();" class="Link05Bold">AUTO</a>)<% } %></td>
			<td width="8%">Num. Cheque</td>
		</tr>
<%
double total = 0.00;
for (int i=0; i<al.size(); i++)
{
	DetalleDistribuirPago det = (DetalleDistribuirPago) al.get(i);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	total += Double.parseDouble(det.getMontoCentro());
	System.out.println(" CDS   COP ================================="+det.getCdsCop());
%>
		<%=fb.hidden("tipo"+i,det.getTipo())%>
		<%=fb.hidden("centroServicio"+i,det.getCentroServicio())%>
		<%=fb.hidden("medCodigo"+i,det.getMedCodigo())%>
		<%=fb.hidden("empreCodigo"+i,det.getEmpreCodigo())%>
		<%=fb.hidden("estatus"+i,det.getEstatus())%>
		<%=fb.hidden("facCodigo"+i,det.getFacCodigo())%>
		<%=fb.hidden("montoCentro"+i,det.getMontoCentro())%>
		<%=fb.hidden("cdsCop"+i,det.getCdsCop())%>
		<%=fb.hidden("descDistribucion"+i,det.getDescDistribucion())%>
		<%=fb.hidden("other1_"+i,det.getOther1())%>
		<tr class="<%=color%>">
			<td align="right"><%=det.getSecuencia()%>&nbsp;</td>
			<td align="center"><%=fb.select("tipoDisplay"+i,"C=CENTRO,H=HONORARIO,E=EMPRESA,P=CO-PAGO,M=PERDIEM",det.getTipo(),false,true,0,"Text10",null,null)%></td>
			<td align="center"><%=det.getEstatus()%></td>
			<td align="center"><%=det.getCodTrabajo()%></td>
			<td><%=det.getTrabajo()%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(det.getMontoCentro())%>&nbsp;</td>
			<td align="center"><%=fb.decBox("monto"+i,det.getMonto(),false,false,viewMode,10,"Text10","","onBlur=\"javascript:manualCalc("+i+");\"")%></td>
			<td><%=(det.getNumCheque() != null)?det.getNumCheque():""%></td>
		</tr>
<%
}
double tmpTotal = Math.round(total * 100);
total = tmpTotal / 100;
%>
		<tr class="TextHeader">
			<td align="right" colspan="5">T O T A L &nbsp; D I S T R I B U I D O</td>
			<td align="right"><%=fb.hidden("totalCentro",""+total)%><%=CmnMgr.getFormattedDecimal(total)%>&nbsp;</td>
			<td align="center"><%=fb.decBox("total","0.00",false,false,true,10,"Text10","","")%></td>
			<td align="center"></td>
		</tr>
		<tr>
			<td colspan="8" align="right">
			<%if(fg.trim().equals("A")){%><authtype type='50'>
				<%=fb.submit("save","Guardar",true,(viewMode),"Text10",null,"onClick=\"javascript:setBAction('formDist',this.value);\"","Guardar")%></authtype><%}else{%>
				<%=fb.submit("save","Guardar",true,(viewMode  || !fg.equalsIgnoreCase("D")),"Text10",null,"onClick=\"javascript:setBAction('formDist',this.value);\"","Guardar")%>
				<%}%>
				<%=fb.button("cancel","Cancelar",false,false,"Text10",null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
		</tr>
<%=fb.hidden("totalDistribuido",""+total)%>
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
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	TransaccionPago tp = new TransaccionPago();
	tp.setCompania(compania);
	tp.setAnio(anio);
	tp.setCodigo(codigo);
	tp.setSecuenciaPago(secuenciaPago);
	for (int i=0; i<size; i++)
	{
		DetalleDistribuirPago det = new DetalleDistribuirPago();

		det.setCompania(compania);
		det.setCodigoTransaccion(codigo);
		det.setTranAnio(anio);
		det.setSecuenciaPago(secuenciaPago);
		det.setTipoCliente(tipoCliente);//P=factura, E=sp_cja_actualiza_ubicacion
		det.setTipoTransaccion(request.getParameter("tipoTransaccion"));//E=sp_cja_actualiza_ubicacion
		det.setDistribucion(request.getParameter("distribucion"));
		det.setUsuarioCreacion(UserDet.getUserName());
		det.setUsuarioModificacion(UserDet.getUserName());
		det.setFechaCreacion("sysdate");
		det.setFechaModificacion("sysdate");

		det.setTipo(request.getParameter("tipo"+i));
		det.setCentroServicio(request.getParameter("centroServicio"+i));
		det.setMedCodigo(request.getParameter("medCodigo"+i));
		det.setEmpreCodigo(request.getParameter("empreCodigo"+i));
		if (det.getEmpreCodigo().equals("0")) det.setEmpreCodigo(null);
		det.setEstatus(request.getParameter("estatus"+i));
		det.setFacCodigo(request.getParameter("facCodigo"+i));
		det.setMonto(request.getParameter("monto"+i));
		det.setOther1(request.getParameter("other1_"+i));

		det.setCodRem(request.getParameter("codRem"));
		det.setCdsCop(request.getParameter("cdsCop"+i));
		det.setDescDistribucion(request.getParameter("descDistribucion"+i));

		if (det.getMonto() != null && !det.getMonto().equals("") && Double.parseDouble(det.getMonto()) > 0) tp.addDetalleDistribuirPago(det);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg+"&mode="+mode+"&tipoCliente="+tipoCliente);
	if (baction.equalsIgnoreCase("Guardar")) TPMgr.addDetalleDistribuirPago(tp);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){<% if (TPMgr.getErrCode().equals("1")) { %>alert('<%=TPMgr.getErrMsg()%>');var imgObj=parent.window.frames['detalle'].document.getElementById('imgDistribucion<%=idx%>');imgObj.src='../images/search.gif';parent.hidePopWin(false);<% } else throw new Exception(TPMgr.getErrMsg()); %>}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>