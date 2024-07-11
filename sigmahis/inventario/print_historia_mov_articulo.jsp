<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
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
CommonDataObject cdo1 = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String wh = request.getParameter("wh");
String fp = request.getParameter("fp");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String id = request.getParameter("id");
String fecha_corrida = request.getParameter("fecha_corrida");
String compania = (String) session.getAttribute("_companyId");
if(tDate == null ) tDate="";
if(fDate == null ) fDate="";
if(fecha_corrida == null ) fecha_corrida="";
if (familyCode == null) familyCode = "";
if (classCode == null) classCode = "";

if (!fecha_corrida.trim().equals("")) {
	if (fecha_corrida.trim().equals(fDate)) {
		sbFilter.append(" and em.fecha_creacion >= to_date('"); sbFilter.append(fecha_corrida); sbFilter.append("','dd/mm/yyyy hh:mi:ss am')");
	} else {
		sbFilter.append(" and em.fecha_creacion >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy hh:mi:ss am')");
	}
} else {
	if (!fDate.trim().equals("")) { sbFilter.append(" and trunc(em.fecha_entrega) >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
}
if (!tDate.trim().equals("")) { sbFilter.append(" and trunc(em.fecha_entrega) <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }

sbSql.append("select a.compania, a.cod_flia, a.cod_clase, a.cod_articulo, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as codigo, a.descripcion as descArticulo, a.itbm, a.cod_medida, nvl(a.precio_venta,0) as precio_venta, a.venta_sino, a.consignacion_sino, a.estado, al.codigo_almacen, al.descripcion as descAlmacen, nvl(i.disponible,0) as disponible, nvl(i.precio,0) as costo, nvl(i.ultimo_precio,0) as ultimo_precio, nvl((select to_char(max(r.fecha_sistema),'dd/mm/yyyy') from tbl_inv_recepcion_material r, tbl_inv_detalle_recepcion d where r.anio_recepcion = d.anio_recepcion and r.numero_documento = d.numero_documento and r.compania = d.compania and r.estado <> 'N' and r.codigo_almacen = i.codigo_almacen and d.cod_articulo = i.cod_articulo and d.compania = i.compania group by d.cod_familia, d.cod_clase, d.cod_articulo),' ') as ultima_compra, nvl((select getFechaconteo(i.art_familia,i.art_clase,i.cod_articulo,i.codigo_almacen,i.codigo_anaquel,i.compania) from dual),' ') as fecha_conteo, nvl((select getNoConteo(i.art_familia,i.art_clase,i.cod_articulo,i.codigo_almacen,i.codigo_anaquel,i.compania) from dual),' ') as codigo_conteo, nvl((select cantidad_contada from tbl_inv_detalle_fisico df where df.cf1_consecutivo||'-'||df.cf1_anio = (select getnoconteo(i.art_familia,i.art_clase,i.cod_articulo,i.codigo_almacen,i.codigo_anaquel,i.compania) from dual) and df.cod_articulo = i.cod_articulo and df.almacen = i.codigo_almacen and df.anaquel = i.codigo_anaquel),0) as cantidad_contada, nvl(i.codigo_anaquel,0) as anaquel from tbl_inv_articulo a, tbl_inv_inventario i, tbl_inv_almacen al where (i.compania = a.compania and i.cod_articulo = a.cod_articulo) and (i.compania = al.compania and i.codigo_almacen  = al.codigo_almacen) and al.codigo_almacen = ");
sbSql.append(wh);
sbSql.append(" and a.cod_articulo = ");
sbSql.append(id);
sbSql.append(" and a.compania = ");
sbSql.append(compania);
cdo1 = SQLMgr.getData(sbSql.toString());
System.out.println("-------------------------------");


sbSql = new StringBuffer();
sbSql.append("select all 'SA' as op, x.type, x.descType, x.codigo, x.fecha, x.fecha_docto, x.cantidad, x.costo, x.total, x.factura, x.n_entrega, x.usuario_creacion, 0 as cod_proveedor, ' ' as descAlmacen, x.nombre, x.codigo_almacen, 0 as cod_alm_ent, x.descArticulo, x.fecha_nacimiento, x.admision, ''||x.cod_familia, ''||x.cod_clase, ''||x.cod_articulo, x.rn from (");
	sbSql.append("select 'A' as type, 'Salidas por Devolucion desde el Deposito' as descType, d.anio_devolucion||'-'||d.num_devolucion as codigo, to_char(d.fecha_devolucion,'dd/mm/yyyy') as fecha, d.fecha_devolucion as fecha_docto, nvl(-dd.cantidad,0) as cantidad, to_char(nvl(dd.precio,0),'999,990.0000') as costo, to_char(nvl((nvl(-dd.cantidad,0) * nvl(dd.precio,0)),0),'999,990.0000') as total, ' ' as factura, 0 as n_entrega, ' ' as usuario_creacion, ' ' as fecha_nacimiento, 0 as paciente, 0 as admision, dd.cod_familia, dd.cod_clase, dd.cod_articulo, d.codigo_almacen_q_dev as codigo_almacen, ' dev '||substr(al.descripcion,0,12)||'. - Recibe '||al1.descripcion as nombre, a.descripcion as descArticulo, dd.renglon, rownum as rn from tbl_inv_devolucion d, tbl_inv_detalle_devolucion dd, tbl_inv_almacen al, tbl_inv_almacen al1, tbl_inv_articulo a where (dd.compania = d.compania and dd.num_devolucion = d.num_devolucion and dd.anio_devolucion = d.anio_devolucion) and (d.compania = al.compania and d.codigo_almacen_q_dev = al.codigo_almacen) and al1.codigo_almacen = d.codigo_almacen and al1.compania = d.compania and trunc(d.fecha_devolucion) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(d.fecha_devolucion)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(d.fecha_devolucion)) and d.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.compania = d.compania and d.codigo_almacen_q_dev = ");
	sbSql.append(wh);
	sbSql.append(" and dd.cod_articulo = a.cod_articulo and dd.cod_articulo = ");
	sbSql.append(id);
/* Salida x entrega a unidades o companias */
	sbSql.append(" union all select 'B' as type, 'Salidas por Entrega a Unidades Adm. y Compañias' as descType, em.anio||'-'||em.no_entrega as no_entrega, to_char(em.fecha_entrega,'dd/mm/yyyy') as fecha_entrega, em.fecha_entrega as fecha_docto, nvl(-de.cantidad,0) as cantidad, to_char(decode(de.costo,null,de.precio,de.costo),'999,990.0000') as costo_entrega, to_char((nvl(-de.cantidad,0) * nvl(decode(de.costo,null,de.precio,de.costo),0)),'999,990.0000') as total_entrega, ' ' as factura, 0, ' ', ' ', 0, 0, de.cod_familia, de.cod_clase, de.cod_articulo, em.codigo_almacen, decode(sr.tipo_transferencia,'U',decode(sr.codigo_centro,null,ue.descripcion,cs.descripcion),'C',co.nombre), a.descripcion as descArticulo, de.renglon, rownum + 1000 as rn from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_req sr, tbl_sec_unidad_ejec ue, tbl_sec_compania co, tbl_inv_articulo a, tbl_cds_centro_servicio cs  where (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and ue.codigo = sr.unidad_administrativa and ue.compania = sr.compania and co.codigo = ue.compania and sr.tipo_transferencia in ('U','C') and trunc(em.fecha_entrega) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(em.fecha_entrega)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(em.fecha_entrega)) and em.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.compania = em.compania and de.cod_articulo = a.cod_articulo and de.cod_articulo = ");
	sbSql.append(id);
	sbSql.append(" and em.codigo_almacen = ");
	sbSql.append(wh);
	sbSql.append(" and sr.codigo_centro = cs.codigo(+)");
/* Salida transferencia desde el deposito */
	sbSql.append(" union all select 'C' as type, 'Salidas por Transferencias entre Almacenes' as descType, em.anio||'-'||em.no_entrega as no_entrega, to_char(em.fecha_entrega,'dd/mm/yyyy') as fecha_entrega, em.fecha_entrega as fecha_docto, nvl(-de.cantidad,0) as cantidad, to_char(nvl(decode(de.costo,null,de.precio,de.costo),0),'999,990.0000') as costo_entrega, to_char((nvl(-de.cantidad,0) * decode(de.costo,null,nvl(de.precio,0),nvl(de.costo,0))),'999,990.0000') as total_entrega, ' ' as factura, 0, ' ', ' ', 0, 0, de.cod_familia, de.cod_clase, de.cod_articulo, em.codigo_almacen, al.descripcion as nombre_almacen, a.descripcion as descArticulo, de.renglon, rownum + 3000 as rn from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_almacen al, tbl_inv_solicitud_req sr, tbl_inv_articulo a where (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and (sr.compania_sol = al.compania and  sr.codigo_almacen = al.codigo_almacen) and trunc(em.fecha_entrega) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(em.fecha_entrega)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(em.fecha_entrega)) and em.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.compania = em.compania and de.cod_articulo = a.cod_articulo and sr.codigo_almacen_ent = ");
	sbSql.append(wh);
	sbSql.append(" and de.cod_articulo = ");
	sbSql.append(id);
/* Salida x entrega a paciente */
	sbSql.append(" union all select 'D' as type, 'Salidas por Entrega a Pacientes' as descType, em.anio||'-'||em.no_entrega as no_entrega, to_char(em.fecha_entrega,'dd/mm/yyyy') as fecha_entrega, em.fecha_entrega as fecha_docto, nvl(-de.cantidad,0) as cantidad, to_char(decode(de.costo,null,de.precio,de.costo),'999,990.0000') as costo_entrega, to_char((nvl(-de.cantidad,0) * decode(de.costo,null,de.precio,de.costo)),'999,990.0000') as total_entrega, ' ' as factura,em.paciente, ' ', to_char(em.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, em.adm_secuencia as admision, sp.centro_servicio as centro, de.cod_familia, de.cod_clase, de.cod_articulo, em.codigo_almacen, primer_nombre||' '||primer_apellido||' - '||cds.descripcion as nombre, a.descripcion as descArticulo, 0, rownum + 6000 as rn from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_pac sp, tbl_adm_paciente p, tbl_cds_centro_servicio cds, tbl_inv_articulo a where (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania = sp.compania and em.pac_solicitud_no = sp.solicitud_no and em.pac_anio = sp.anio) and a.compania = em.compania and em.compania = ");
	sbSql.append(compania);
	sbSql.append(" and p.pac_id = em.pac_id and cds.codigo = sp.centro_servicio and de.cod_articulo = a.cod_articulo and de.cod_articulo = ");
	sbSql.append(id);
	sbSql.append(" and em.codigo_almacen = ");
	sbSql.append(wh);
	sbSql.append(" /* and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) modificado probar y comparar con chsf **/ ");
	sbSql.append(sbFilter);
/* devolucion provvedor */
	sbSql.append(" union all select 'E' as type, 'Salidas por Devolucion a Proveedor' as descType, d.anio||'-'||d.num_devolucion as no_devolucion, to_char(d.fecha,'dd/mm/yyyy') as fecha_dev, d.fecha as fecha_docto, nvl(-dp.cantidad,0) as cantidad, to_char(nvl(dp.precio,0),'999,990.0000') as costo_devolucion, to_char(nvl((-dp.cantidad * nvl(dp.precio,0) + nvl(dp.art_itbm,0)),0),'999,990.0000') as total_devolucion, ' ' as factura, 0, ' ', ' ', 0, 0, dp.cod_familia, dp.cod_clase, dp.cod_articulo, d.codigo_almacen, cp.nombre_proveedor||'-'||d.nota_credito, a.descripcion as descArticulo, -1, rownum + 9000 as rn from tbl_inv_devolucion_prov d, tbl_inv_detalle_proveedor dp, tbl_inv_articulo a, tbl_com_proveedor cp where (dp.compania = d.compania and dp.num_devolucion = d.num_devolucion and dp.anio = d.anio) and trunc(d.fecha) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(d.fecha)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(d.fecha)) and d.anulado_sino = 'N' and d.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.compania = d.compania and cp.cod_provedor = d.cod_provedor and dp.cod_articulo = a.cod_articulo and d.codigo_almacen = ");
	sbSql.append(wh);
	sbSql.append(" and dp.cod_articulo = ");
	sbSql.append(id);
/* Entregas a otros cliente */
	sbSql.append(" union all select 'F' as type, 'Transacciones de tipo otros Cargos' as descType, cc.anio||'-'||cc.codigo||'-'||cc.tipo_transaccion as no_cargo, to_char(cc.fecha,'dd/mm/yyyy') as fecha_cargo, cc.fecha as fecha_docto, nvl(decode(cc.tipo_transaccion,'C',-dc.cantidad,'D',dc.cantidad),0) as cantidad, to_char(nvl(dc.costo,0),'999,990.0000') as costo_cargo, to_char(nvl((decode(cc.tipo_transaccion,'C',dc.cantidad,'D',-dc.cantidad) * dc.costo),0),'999,990.0000') as total_cargos, ' ' as factura, 0, ' ', ' ', 0, 0, dc.inv_art_familia, dc.inv_art_clase, dc.inv_cod_articulo, dc.inv_almacen, decode(cc.tipo_transaccion,'C','CARGOS OTROS'||'- '||cc.cliente,'D','DEVOLUCION OTROS'||'- '||cc.cliente) as nombre, a.descripcion as descArticulo, to_number(dc.secuencia), rownum + 15000 as rn from tbl_fac_detc_cliente dc, tbl_fac_cargo_cliente cc, tbl_inv_articulo a where (dc.compania = cc.compania and dc.anio = cc.anio and dc.tipo_transaccion = cc.tipo_transaccion and dc.cargo = cc.codigo) and trunc(cc.fecha) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(cc.fecha)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(cc.fecha)) and cc.compania = ");
	sbSql.append(compania);
	sbSql.append(" and dc.inv_cod_articulo = a.cod_articulo and dc.inv_almacen = ");
	sbSql.append(wh);
	sbSql.append(" and a.compania = cc.compania and dc.inv_cod_articulo = ");
	sbSql.append(id);
sbSql.append(" order by 1, 3) x");

sbSql.append(" union all select 'EM' as op, y.type, y.descType, y.codigo, y.fecha, y.fecha_docto, y.cantidad, y.costo, y.total, y.factura, y.n_entrega, y.usuario_creacion, y.cod_proveedor, y.descAlmacen, ' '||y.nombre as nombre, y.cod_almacen_sol, y.cod_alm_ent, y.descArticulo, ' ' as fecha_nacimiento, 0 as admision, ''||y.cod_familia, ''||y.cod_clase, ''||y.cod_articulo, y.rn from (");
	sbSql.append("select 'A' as type, ' Entradas por Recepcion de Material ' as descType, /*recepcion de material*/ rm.anio_recepcion||'-'||rm.numero_documento as codigo, to_char(rm.fecha_documento,'dd/mm/yyyy') as fecha, rm.fecha_documento as fecha_docto, sum(nvl(dr.cantidad,0) * nvl(dr.articulo_und,0)) as cantidad, to_char(nvl(dr.precio,0),'999,990.0000') as costo, to_char((nvl(dr.cantidad,0) * nvl(dr.articulo_und,0)) * nvl(dr.precio,0),'999,990.00') as total, rm.numero_factura as factura, nvl(rm.numero_entrega,0) as n_entrega, rm.usuario_creacion as usuario_creacion, p.cod_provedor as cod_proveedor, ' ' as descAlmacen, rm.numero_factura||'-'||p.nombre_proveedor as nombre, dr.cod_familia, dr.cod_clase, dr.cod_articulo, rm.codigo_almacen as cod_almacen_sol, 0 as cod_alm_ent, a.descripcion as descArticulo, ' ' as paciente, rownum + 20000 as rn from tbl_inv_recepcion_material rm, tbl_inv_detalle_recepcion dr, tbl_com_proveedor p, tbl_inv_inventario i, tbl_inv_articulo a where rm.estado = 'R' and (dr.compania = rm.compania and dr.numero_documento = rm.numero_documento and dr.anio_recepcion = rm.anio_recepcion) and (rm.cod_proveedor = p.cod_provedor) and dr.cod_articulo = i.cod_articulo and  dr.cod_articulo = a.cod_articulo and dr.compania = a.compania and a.estado = 'A' and trunc(rm.fecha_documento) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(rm.fecha_documento)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(rm.fecha_documento)) and dr.cod_articulo = ");
	sbSql.append(id);
	sbSql.append(" and rm.codigo_almacen = ");
	sbSql.append(wh);
	sbSql.append(" and rm.compania = ");
	sbSql.append(compania);
	sbSql.append(" and rm.codigo_almacen = i.codigo_almacen and i.compania = rm.compania group by to_char(rm.fecha_documento,'dd/mm/yyyy'), rm.fecha_documento, rm.anio_recepcion||'-'||rm.numero_documento, nvl(dr.cantidad,0) * nvl(dr.articulo_und,0), nvl(dr.precio,0), (nvl(dr.cantidad,0) * nvl(dr.articulo_und,0)) * nvl(dr.precio,0), rm.numero_factura, nvl(rm.numero_entrega,0), rm.usuario_creacion, p.cod_provedor, rm.numero_factura||'-'||p.nombre_proveedor, dr.cod_familia, dr.cod_clase, dr.cod_articulo, rm.codigo_almacen, a.descripcion, rownum + 20000");
/*Query Transferencia entre Almacenes*/
	sbSql.append(" union all select 'B' as type, ' Entradas por Transferencias desde Deposito' as descType, em.anio||'-'||em.no_entrega as no_recepcion, to_char(em.fecha_entrega,'dd/mm/yyyy') as fecha_recepcion, em.fecha_entrega as fecha_docto, nvl(de.cantidad,0) as cantidad, to_char(nvl(decode(de.costo,null,de.precio,de.costo),0),'999,990.0000') as precio_recepcion, to_char(nvl(de.cantidad,0) * nvl((decode(de.costo,null,de.precio,de.costo)),0),'999,990.0000') as total_recepcion, ' ' as factura, em.no_entrega as n_entrega, em.usuario_creacion, 0 as cod_proveedor, ' ', al.descripcion as desc_proveedor, de.cod_familia, de.cod_clase, de.cod_articulo, sr.codigo_almacen as cod_almacen_sol, em.codigo_almacen as cod_alm_ent, a.descripcion, ' ' as paciente, rownum + 30000 as rn from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_req sr, tbl_inv_almacen al, tbl_inv_articulo a where sr.tipo_transferencia = 'A' and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and (al.compania = em.compania and al.codigo_almacen = em.codigo_almacen) and trunc(em.fecha_entrega) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(em.fecha_entrega)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(em.fecha_entrega)) and a.compania = em.compania and de.cod_articulo = a.cod_articulo and de.cod_articulo = ");
	sbSql.append(id);
	sbSql.append(" and em.compania = ");
	sbSql.append(compania);
	sbSql.append(" and sr.codigo_almacen = ");
	sbSql.append(wh);
/*Query Devolucion desde Unidades Administrativas y compañia*/
	sbSql.append(" union all select 'C' as type, ' Entradas por Devolucion desde Unidad y Cia' as descType, dev.anio_devolucion||'-'||dev.num_devolucion as num_devolucion, to_char(dev.fecha_devolucion,'dd/mm/yyyy') as fecha_devolucion, dev.fecha_devolucion as fecha_docto, nvl(dd.cantidad,0) as cantidad, to_char(nvl(dd.precio,0),'999,990.0000') as precio, to_char(nvl(dd.cantidad,0) * nvl(dd.precio,0),'999,990.0000') as total_devolucion, ' ' as factura, dev.no_entrega as n_entrega, dev.usuario_creacion, 0 as cod_proveedor, ' ' as descAlmacen, u.descripcion||' Dev:'||dev.anio_devolucion||'-'||dev.num_devolucion as desc_proveedor, dd.cod_familia, dd.cod_clase, dd.cod_articulo, dev.codigo_almacen as cod_almacen_dev, 0, a.descripcion, ' ' as paciente, rownum + 40000 as rn from tbl_inv_devolucion dev, tbl_inv_detalle_devolucion dd, tbl_sec_unidad_ejec u, tbl_sec_compania c, tbl_inv_articulo a where (dd.compania = dev.compania and dd.num_devolucion = dev.num_devolucion and dd.anio_devolucion = dev.anio_devolucion) and c.codigo = u.compania and u.codigo = dev.unidad_administrativa and u.compania = dev.compania and trunc(dev.fecha_devolucion) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(dev.fecha_devolucion)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(dev.fecha_devolucion)) and a.compania = dev.compania and dd.cod_articulo = a.cod_articulo and dev.compania_dev = ");
	sbSql.append(compania);
	sbSql.append(" and dd.cod_articulo = ");
	sbSql.append(id);
	sbSql.append(" and dev.codigo_almacen = ");
	sbSql.append(wh);
/*Query Devolucion de Materiales de Paciente*/
	sbSql.append(" union all select 'D' as type, ' Entradas por Devolucion de Materiales de Paciente' as descType, dp.anio||'-'||dp.num_devolucion as no_devolucion, to_char(dp.fecha,'dd/mm/yyyy') as fecha_devolucion, dp.fecha as fecha_docto, nvl(det.cantidad,0) as cantidad, to_char(nvl(det.costo,0),'999,990.0000') as precio, to_char(nvl(det.cantidad,0) * nvl(det.costo,0),'999,990.0000') as total_devolucion, ' ' as factura, nvl(dp.no_entrega,0) as n_entrega, dp.usuario_creacion, dp.sala_cod as cod_proveedor, al.descripcion as descAlmacen, p.primer_nombre||' '||p.primer_apellido||' - '||cds.descripcion as desc_proveedor, det.cod_familia, det.cod_clase, det.cod_articulo, dp.codigo_almacen as cod_almacen_dev_pac, 0, a.descripcion, p.primer_nombre||' '||p.primer_apellido as paciente, rownum + 50000 as rn from tbl_inv_devolucion_pac dp, tbl_inv_detalle_paciente det, tbl_inv_almacen al, tbl_cds_centro_servicio cds, tbl_inv_articulo a, tbl_adm_paciente p where (det.compania = dp.compania and det.num_devolucion = dp.num_devolucion and det.anio_devolucion = dp.anio) and trunc(dp.fecha) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(dp.fecha)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(dp.fecha)) and dp.compania = ");
	sbSql.append(compania);
	sbSql.append(" and dp.estado = 'R' and dp.codigo_almacen = al.codigo_almacen and dp.compania = al.compania and dp.sala_cod = cds.codigo and det.cod_articulo = a.cod_articulo and det.compania = a.compania and dp.pac_id = p.pac_id and det.cod_articulo = ");
	sbSql.append(id);
	sbSql.append(" and dp.codigo_almacen = ");
	sbSql.append(wh);
	sbSql.append(" order by 1, 2 desc, 11");
sbSql.append(") y");

/* transacciones de ajustes*/
sbSql.append(" union all select 'TA' as op, w.type, w.descType, w.codigo, w.fecha, w.fecha_docto, nvl(w.cantidad,0) as cantidad, nvl(w.costo,0) as costo, nvl(w.total,0) as total, ' ' as factura, 0 as n_entrega, ' ' as usuario_creacion, 0 as cod_proveedor, ' ' as descAlmacen, ' '||w.nombre, w.codigo_almacen, 0 as cod_alm_ent, w.descArticulo, ' ' as fecha_nacimiento, 0 as admision, w.cod_familia, w.cod_clase, w.cod_articulo, w.rn from (");
	sbSql.append("select 'TA1' as type, 'Transacciones por Ajuste al Inventario' as descType, to_char(aj.fecha_ajuste,'dd/mm/yyyy') as fecha, aj.fecha_ajuste as fecha_docto, aj.anio_ajuste||'-'||aj.numero_ajuste as codigo, decode(t.sign_tipo_ajuste,'-',nvl(-da.cantidad_ajuste,0),nvl(da.cantidad_ajuste,0)) as cantidad, to_char(nvl(da.precio,0),'999,990.0000') as costo, to_char((decode(t.sign_tipo_ajuste,'-',nvl(-da.cantidad_ajuste,0),nvl(da.cantidad_ajuste,0)) * nvl(da.precio,0)),'999,990.0000') as total, decode(aj.anio_ajuste||'-'||aj.numero_ajuste,'2006-79','AJUSTE 2006-79 POR VALORES AL CONTEO FISICO AL 04-12-2006',aj.anio_ajuste||'-'||aj.numero_ajuste||'-'||aj.numero_doc||'- User: '||aj.USUARIO_CREACION||' Tipo Ajuste: '||T.DESCRIPCION||' '||da.Observacion) as nombre, da.cod_familia, da.cod_clase, da.cod_articulo, aj.codigo_almacen, a.descripcion as descArticulo, rownum + 60000 as rn from tbl_inv_ajustes aj, tbl_inv_detalle_ajustes da, tbl_inv_tipo_ajustes t, tbl_inv_articulo a where aj.codigo_ajuste = 4 and aj.estado = 'A' and (da.compania = aj.compania and da.codigo_ajuste = aj.codigo_ajuste and da.numero_ajuste = aj.numero_ajuste and da.anio_ajuste = aj.anio_ajuste) and aj.codigo_ajuste = t.codigo_ajuste and trunc(aj.fecha_ajuste) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(aj.fecha_ajuste)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(aj.fecha_ajuste)) and aj.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.compania = aj.compania and da.cod_articulo = a.cod_articulo and aj.codigo_almacen = ");
	sbSql.append(wh);
	sbSql.append(" and da.cod_articulo = ");
	sbSql.append(id);
	sbSql.append(" union all select 'TA2' as type, 'Transacciones por Ajuste al Inventario' as descType, to_char(aj.fecha_ajuste,'dd/mm/yyyy') as fecha_ajuste, aj.fecha_ajuste as fecha_docto, aj.anio_ajuste||'-'||aj.numero_ajuste as no_ajuste, decode(ta.sign_tipo_ajuste,'-',nvl(-da.cantidad_ajuste,0),nvl(da.cantidad_ajuste,0)) as cantidad, to_char(nvl(da.precio,0),'999,990.0000') as costo_ajuste, to_char((decode(ta.sign_tipo_ajuste,'-',nvl(-da.cantidad_ajuste,0),nvl(da.cantidad_ajuste,0)) * nvl(da.precio,0)),'999,990.0000') as total_ajuste, decode(aj.anio_ajuste||'-'||aj.numero_ajuste,'2006-79','AJUSTE 2006-79 POR VALORES AL CONTEO FISICO AL 04-12-2006',aj.anio_ajuste||'-'||aj.numero_ajuste||'-'||aj.numero_doc||'- User: '||aj.usuario_creacion||' Tipo Ajuste: '||ta.descripcion||' '||da.observacion) as descripcion, da.cod_familia, da.cod_clase, da.cod_articulo, aj.codigo_almacen, a.descripcion as descArticulo, rownum + 80000 as rn from tbl_inv_detalle_ajustes da, tbl_inv_ajustes aj, tbl_inv_almacen al, tbl_inv_tipo_ajustes ta, tbl_inv_articulo a where aj.codigo_ajuste <> 4 and aj.estado = 'A' and (da.compania = aj.compania and da.codigo_ajuste = aj.codigo_ajuste and da.numero_ajuste = aj.numero_ajuste and da.anio_ajuste = aj.anio_ajuste) and aj.codigo_ajuste = ta.codigo_ajuste and (aj.codigo_almacen = al.codigo_almacen and aj.compania = al.compania) and aj.codigo_almacen = ");
	sbSql.append(wh);
	sbSql.append(" and da.check_aprov = 'S' and aj.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.compania = aj.compania and da.cod_articulo = a.cod_articulo and da.cod_articulo = ");
	sbSql.append(id);
	sbSql.append(" and trunc(aj.fecha_ajuste) between nvl(to_date('");
	sbSql.append(fDate);
	sbSql.append("','dd/mm/yyyy'),trunc(aj.fecha_ajuste)) and nvl(to_date('");
	sbSql.append(tDate);
	sbSql.append("','dd/mm/yyyy'),trunc(aj.fecha_ajuste))");
sbSql.append(") w order by 6, 5, 2, 4 desc");
if (cdo1 != null) al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
	double subTotal = 0.0;
	double total = 0.0;
	int maxLines = 42; //max lines of items
	int nItems = al.size()+11; //number of items  11 = lineas para los sub totales
	int extraItems = nItems % maxLines;
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	//calculating number of page
	if (extraItems == 0) nPages = (nItems / maxLines);
	else nPages = (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = false;
	boolean statusMark = false;
	//String currDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

	String fecha = cDateTime;
	//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String month=fecha.substring(3, 5);
	String day=fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

	if(month.equals("01")) month = "january";
	else if(month.equals("02")) month = "february";
	else if(month.equals("03")) month = "march";
	else if(month.equals("04")) month = "april";
	else if(month.equals("05")) month = "may";
	else if(month.equals("06")) month = "june";
	else if(month.equals("07")) month = "july";
	else if(month.equals("08")) month = "august";
	else if(month.equals("09")) month = "september";
	else if(month.equals("10")) month = "october";
	else if(month.equals("11")) month = "november";
	else month = "december";

	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	//System.out.println("******* directory="+directory);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".10");
		setDetail.addElement(".15");
		setDetail.addElement(".35");
		setDetail.addElement(".10");
		setDetail.addElement(".15");
		setDetail.addElement(".15");

	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 13.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO", "MOVIMIENTO DE ARTICULOS POR DEPOSITO", userName, fecha);

if (cdo1 == null) {

	StringBuffer sbTmp = new StringBuffer();
	sbTmp.append("Almacén (");
	sbTmp.append(wh);
	sbTmp.append(") / Artículo (");
	sbTmp.append(id);
	sbTmp.append(") no existe!");

	pc.createTable();
		pc.addCols(sbTmp.toString(),1,setDetail.size());
	pc.addTable();

} else {

	pc.createTable();
		pc.setFont(9, 1);
		pc.addCols("Fecha de Ultimo Inventario: "+fecha_corrida,1,6);
	pc.addTable();
	pc.copyTable("detailHeader4");
	pc.createTable();
		pc.setFont(9, 1);
		pc.addCols("Desde    "+fDate+"     hasta      "+tDate,1,6);
	pc.addTable();
	pc.copyTable("detailHeader6");
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(9, 1);
		pc.addCols(cdo1.getColValue("descAlmacen"),1,6);
	pc.addTable();
	pc.copyTable("detailHeader5");
	pc.createTable();
		pc.setFont(9, 1);
		pc.addCols(" Codigo: ",0,1);
		pc.addCols(cdo1.getColValue("codigo"),0,1);
		pc.addCols(cdo1.getColValue("descArticulo"),0,2);
		pc.addCols(" Und Sist:  "+CmnMgr.getFormattedDecimal(cdo1.getColValue("disponible")),0,1);
		pc.addCols(" Precio Venta:  "+CmnMgr.getFormattedDecimal(cdo1.getColValue("precio_venta")),0,1);
	pc.addTable();
	pc.copyTable("detailHeader3");
	pc.createTable();
		pc.setFont(9, 1);
		pc.addCols(" Anaquel: ",0,1);
		pc.addCols(cdo1.getColValue("anaquel"),0,3);
		pc.addCols(" U. Compra:  "+cdo1.getColValue("ultima_compra"),0,1);
		pc.addCols(" Costo Promedio:  "+CmnMgr.getFormattedDecimal(cdo1.getColValue("costo")),0,1);
	pc.addTable();
	pc.copyTable("detailHeader2");

	pc.createTable();
		pc.setFont(9, 1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("# Documento",1);
		pc.addBorderCols("Descripciòn",1);
		pc.addBorderCols("Cantidad",1);
		pc.addBorderCols("Costo",1);
		pc.addBorderCols("Total",1);
	pc.addTable();
	pc.copyTable("detailHeader");

	pc.createTable();
		pc.setFont(9, 1);
		pc.addCols(cdo1.getColValue("fecha_conteo"),0,1);
		pc.addCols("Conteo # "+cdo1.getColValue("codigo_conteo"),0,1);
		pc.addCols("Valores Del Conteo Fisico ",0,1);
		pc.addCols(cdo1.getColValue("cantidad_contada"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo1.getColValue("costo")),2,1);
		pc.addCols("  ",0,1);
	pc.addTable();
	pc.copyTable("detailHeader1");
	try { total += Double.parseDouble(cdo1.getColValue("cantidad_contada")); } catch(Exception e) {}
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		//pc.setFont(7, 0,Color.blue);

		if(cdo.getColValue("codigo").trim().equals("0"))
		{
			if(i>0)
			{
						pc.setFont(9, 1);
						pc.createTable();
						pc.addCols(" Sub Total :",2,3,cHeight);
						pc.addCols(CmnMgr.getFormattedDecimal(subTotal),2,1,cHeight);
						pc.addCols(" ",2,2,cHeight);
						pc.addTable();
						lCounter++;
						subTotal=0;
			}

			pc.setFont(9, 0,Color.blue);
			pc.createTable();
			pc.addCols(cdo.getColValue("descType"),0,6,cHeight);
			pc.copyTable("detailHeader10");
		}
		else
		{

			pc.setFont(9, 0);
			pc.setVAlignment(1);
			pc.createTable();
			pc.addCols(cdo.getColValue("fecha"),0,1,cHeight);
			pc.addCols(cdo.getColValue("codigo"),0,1,cHeight);
			pc.addCols(cdo.getColValue("nombre"),0,0,cHeight);
			pc.addCols(cdo.getColValue("cantidad"),2,1,cHeight);
			pc.addCols(" $"+cdo.getColValue("costo"),2,1,cHeight);
			if(cdo.getColValue("op").trim().equals("EM") && cdo.getColValue("type").trim().equals("C"))
			pc.addCols(" $"+cdo.getColValue("costo"),2,1,cHeight);
			else if(cdo.getColValue("op").trim().equals("EM") && cdo.getColValue("type").trim().equals("A")){
			pc.addCols(" $"+cdo.getColValue("total"),2,1,cHeight);

			}
			else pc.addCols(" $"+cdo.getColValue("total"),2,1,cHeight);
			total +=  Double.parseDouble(cdo.getColValue("cantidad"));
			subTotal +=  Double.parseDouble(cdo.getColValue("cantidad"));

		}
		pc.addTable();
		lCounter++;
		pc.resetVAlignment();

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO", "MOVIMIENTO DE ARTICULOS POR DEPOSITO", userName, fecha);
			pc.setNoColumnFixWidth(setDetail);

			pc.addCopiedTable("detailHeader4");
			pc.addCopiedTable("detailHeader6");
			pc.addCopiedTable("detailHeader5");
			pc.addCopiedTable("detailHeader3");
			pc.addCopiedTable("detailHeader2");
			pc.addCopiedTable("detailHeader");
			pc.addCopiedTable("detailHeader1");
			pc.addCopiedTable("detailHeader10");

			//groupBy = "";//if this segment is uncommented then reset lCounter to 0 instead of the printed extra line (lCounter -  maxLines)
		}
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
		pc.setFont(9, 1);
		pc.createTable();
			pc.addCols(" Sub Total :",2,3,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal(subTotal),2,1,cHeight);
			pc.addCols(" ",2,2,cHeight);
		pc.addTable();
		pc.setFont(9, 1,Color.blue);
		pc.createTable();
			pc.addCols(" T O T A L :",2,2,cHeight);
			pc.addCols(CmnMgr.getFormattedDecimal(total),2,2,cHeight);
			pc.addCols(" ",2,2,cHeight);
		pc.addTable();
		lCounter++;

		/*pc.createTable();
			pc.addCols(al.size()+" Registros en total",0,setDetail.size());
		pc.addTable();*/
	}
}
	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>