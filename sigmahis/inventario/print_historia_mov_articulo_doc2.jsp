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
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
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
String tipoMov = request.getParameter("tipo_mov") == null ? "" : request.getParameter("tipo_mov");
String filter ="";
String compania = (String) session.getAttribute("_companyId");
StringBuffer sbSql = new StringBuffer();
if(tDate == null ) tDate="";
if(fDate == null ) fDate="";
if(fecha_corrida == null ) fecha_corrida="";

if (familyCode == null) familyCode = "";
if (classCode == null) classCode = "";

if(!fecha_corrida.trim().equals("")){

if(fecha_corrida.trim().equals(fDate))
	 filter = " and to_date(to_char(em.fecha_creacion,'dd/mm/yyyy hh:mi:ss am'),'dd/mm/yyyy hh:mi:ss am') >= to_date('"+fecha_corrida+"','dd/mm/yyyy hh:mi:ss am') ";
else filter = " and to_date(to_char(em.fecha_creacion,'dd/mm/yyyy hh:mi:ss am'),'dd/mm/yyyy hh:mi:ss am') >= to_date('"+fDate+"','dd/mm/yyyy hh:mi:ss am') ";
}
else
{
if(!fDate.trim().equals(""))
filter = " and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fDate+"','dd/mm/yyyy') ";
}
if(!tDate.trim().equals(""))
filter += " and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+tDate+"','dd/mm/yyyy') ";


if (appendFilter == null) appendFilter = "";

sbSql.append("select ");
if(!fDate.trim().equals("")&& !fecha_corrida.trim().equals("")){sbSql.append(" nvl(case when to_date(nvl( getFechaCorrida(i.art_familia,i.art_clase ,i.cod_articulo, i.codigo_almacen, i.codigo_anaquel,i.compania),' ' ), 'dd/mm/yyyy') >= to_date('");
sbSql.append(fDate);
sbSql.append("','dd/mm/yyyy') then 'N' else 'S'  end,'N') ");
}else sbSql.append(" 'N' ");

sbSql.append(" sumarConteo,a.compania , a.cod_flia, a.cod_clase, a.cod_articulo, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo codigo, a.descripcion descArticulo, a.itbm, a.cod_medida, nvl(a.precio_venta,0) precio_venta, a.venta_sino, a.consignacion_sino, a.estado, al.codigo_almacen, al.descripcion descAlmacen, nvl(i.disponible,0)disponible , nvl(i.precio,0) costo, nvl(i.ultimo_precio,0) ultimo_precio  ,nvl(to_char((select to_date(to_char(max(r.fecha_sistema),'dd-mm-yyyy'),'dd-mm-yyyy')  from  tbl_inv_recepcion_material r,tbl_inv_detalle_recepcion d where r.anio_recepcion    = d.anio_recepcion and   r.numero_documento  = d.numero_documento and   r.compania = d.compania and   r.estado <> 'A' and r.fre_documento not in ('FG') and   r.codigo_almacen = i.codigo_almacen and d.cod_articulo = i.cod_articulo and   d.compania = i.compania group by d.cod_articulo),'dd/mm/yyyy'),'  ') ultima_compra ,nvl(getFechaconteo(i.art_familia,i.art_clase ,i.cod_articulo, i.codigo_almacen, i.codigo_anaquel,i.compania),' ') fecha_conteo ,nvl(getnoconteo(i.art_familia,i.art_clase ,i.cod_articulo, i.codigo_almacen, i.codigo_anaquel,i.compania),' ') codigo_conteo ,nvl(( select nvl(cantidad_contada,0) from tbl_inv_detalle_fisico df where   df.cf1_consecutivo||'-'||df.cf1_anio        = getnoconteo(i.art_familia,i.art_clase ,i.cod_articulo, i.codigo_almacen, i.codigo_anaquel,i.compania) and df.cod_articulo = i.cod_articulo and df.almacen = i.codigo_almacen  and df.anaquel = i.codigo_anaquel ),0) cantidad_contada  ,nvl(i.codigo_anaquel,0) anaquel from tbl_inv_articulo a , tbl_inv_inventario i, tbl_inv_almacen al where (i.compania = a.compania and i.cod_articulo = a.cod_articulo) and (i.compania = al.compania and i.codigo_almacen = al.codigo_almacen) and al.codigo_almacen= ");
sbSql.append(wh);
/* sbSql.append(" and a.cod_flia = ");
sbSql.append(familyCode);
sbSql.append(" and a.cod_clase = ");
sbSql.append(classCode);*/
sbSql.append(" and a.cod_articulo = ");
sbSql.append(id);
sbSql.append(" and a.compania = ");
sbSql.append(compania);

cdo1 = SQLMgr.getData(sbSql.toString());
 
 sbSql = new StringBuffer();
sbSql.append("select all 'SA' op, x.type,x.descDoc, x.descType, x.codigo, x.fecha, x.fecha_docto, x.cantidad,x.costo ,x.total, x.factura,x.n_entrega,x.usuario_creacion,0 cod_proveedor, ' ' descAlmacen ,x.nombre,x.codigo_almacen, 0 cod_alm_ent, x.descArticulo, x.fecha_nacimiento,x.admision,''||x.cod_familia,''||x.cod_clase,''||x.cod_articulo, x.rn  from ");

sbSql.append(" (select 'A' type,'DEV. ALM' descDoc,'Salidas por Devolucion desde el Deposito' descType,  d.anio_devolucion||'-'||d.num_devolucion codigo ,to_char(d.fecha_devolucion,'dd/mm/yyyy') fecha, d.fecha_devolucion fecha_docto, nvl(dd.cantidad,0)*-1 cantidad,nvl(dd.precio,0) costo ,nvl(((nvl(dd.cantidad,0)* -1) * nvl(dd.precio,0)),0) total, ' ' factura,0 n_entrega,' ' usuario_creacion,' 'fecha_nacimiento ,0 paciente ,0 admision ,dd.cod_familia ,dd.cod_clase,dd.cod_articulo ,d.codigo_almacen_q_dev codigo_almacen,' dev '||substr(al.descripcion,0,12)||'. - Recibe '||al1.descripcion nombre,a.descripcion descArticulo,dd.renglon,rownum+0 rn from tbl_inv_devolucion d , tbl_inv_detalle_devolucion dd, tbl_inv_almacen al,tbl_inv_almacen al1,tbl_inv_articulo a where (dd.compania =d.compania and dd.num_devolucion  =d.num_devolucion and dd.anio_devolucion=d.anio_devolucion) and (d.compania = al.compania and d.codigo_almacen_q_dev = al.codigo_almacen) and al1.codigo_almacen = d.codigo_almacen and al1.compania = d.compania ");

if(!fDate.trim().equals("")){sbSql.append(" and trunc(d.fecha_devolucion) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(d.fecha_devolucion) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}

sbSql.append(" and d.compania = ");
sbSql.append(compania);
sbSql.append(" and a.compania = d.compania and d.codigo_almacen_q_dev=");
sbSql.append(wh);
sbSql.append(" and dd.cod_articulo= a.cod_articulo and dd.cod_familia =");
sbSql.append(familyCode);
sbSql.append(" and dd.cod_clase=");
sbSql.append(classCode);
sbSql.append("  and dd.cod_articulo= ");
sbSql.append(id);
sbSql.append(" and nvl(dd.estado_renglon,'P')='E' and nvl(d.estado,'T')in ('R','A')  and d.tipo_transferencia='EA' ");

//sql += " union ";

//sql += " select 'A' type,'Salidas por Devolucion desde el Deposito' descType ,'0' no_cargo,' '  ,0  ,' '  costo_cargo ,' ' total_cargos , ' ' factura,0,' ',' '  ,0,0, 0 , 0, 0, 0,' ' nombre,' ' descArticulo,-1,rownum-1 rn from dual ";
/* Salida x entrega a unidades o companias */

//sql += " union ";
//sql += " select 'B' type,'Salidas por Entrega a Unidades Adm. y Compañias' descType ,'0' no_cargo,' '  ,0  ,' '  costo_cargo ,' ' total_cargos , ' ' factura,0,' ',' '  ,0,0, 0 , 0, 0, 0,' ' nombre,' ' descArticulo,-1,rownum-1 rn from dual ";

sbSql.append(" union all ");
sbSql.append(" select 'B' type ,'ENT. UND' descDoc,'Salidas por Entrega a Unidades Adm. y Compañias'descType, em.anio||'-'||em.no_entrega no_entrega, to_char(em.fecha_entrega,'dd/mm/yyyy') fecha_entrega, em.fecha_entrega fecha_docto, nvl(de.cantidad,0) * -1 cantidad,  nvl(decode(de.costo, null,de.precio,de.costo),0) costo_entrega ,nvl(((nvl(de.cantidad,0) * -1) * nvl(decode(de.costo, null,de.precio, de.costo),0)),0)  total_entrega , ' ' factura,0,' ',' ', 0,0, de.cod_familia, de.cod_clase, de.cod_articulo , em.codigo_almacen, decode(sr.tipo_transferencia,'U',decode(sr.codigo_centro,null, ue.descripcion,cs.descripcion),'C',co.nombre) , a.descripcion descArticulo,de.renglon ,rownum+1000 rn from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_req sr , tbl_sec_unidad_ejec ue , tbl_sec_compania co, tbl_inv_articulo a, tbl_cds_centro_servicio cs  where (de.compania   = em.compania and   de.no_entrega = em.no_entrega and de.anio = em.anio) and  (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and ue.codigo = sr.unidad_administrativa and ue.compania = sr.compania and co.codigo = ue.compania and sr.tipo_transferencia in ('U','C')");
if(!fDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}

sbSql.append(" and em.compania = ");
sbSql.append(compania);
sbSql.append(" and a.compania = em.compania and de.cod_articulo= a.cod_articulo and de.cod_familia =  ");
sbSql.append(familyCode);
sbSql.append("  and de.cod_clase =  ");
sbSql.append(classCode);
sbSql.append("  and de.cod_articulo=  ");
sbSql.append(id);
sbSql.append("  and em.codigo_almacen = ");
sbSql.append(wh);
sbSql.append(" and sr.codigo_centro = cs.codigo(+)");

 /* Salida transferencia desde el deposito */
//sql += " union ";
//sql += " select 'C' type,'Salidas por Transferencias entre  Almacenes' descType ,'0' no_cargo,' '  ,0  ,' '  costo_cargo ,' ' total_cargos , ' ' factura,0,' ',' '  ,0,0, 0 , 0, 0, 0,' ' nombre,' ' descArticulo,-1 ,rownum-1 rn from dual ";

sbSql.append(" union all ");
sbSql.append(" select 'C' type,'TRF. ALM.' descDoc ,'Salidas por Transferencias entre  Almacenes'descType ,em.anio||'-'||em.no_entrega no_entrega,to_char(em.fecha_entrega,'dd/mm/yyyy') fecha_entrega, em.fecha_entrega fecha_docto ,nvl(de.cantidad,0) * -1 cantidad ,nvl(decode(de.costo, null, de.precio, de.costo),0) costo_entrega ,((nvl(de.cantidad,0) * -1) * decode(de.costo, null,nvl(de.precio,0),nvl(de.costo,0))) total_entrega, ' ' factura,0,' ' ,' ',0,0, de.cod_familia, de.cod_clase  , de.cod_articulo , em.codigo_almacen , al.descripcion   nombre_almacen , a.descripcion descArticulo,de.renglon,rownum+3000 rn	from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_almacen al, tbl_inv_solicitud_req sr, tbl_inv_articulo a where (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and (sr.compania_sol = al.compania and  sr.codigo_almacen = al.codigo_almacen) ");
if(!fDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}

sbSql.append(" and sr.tipo_transferencia ='A' and em.compania = ");
sbSql.append(compania);
sbSql.append(" and a.compania = em.compania and de.cod_articulo= a.cod_articulo and sr.codigo_almacen_ent =");
sbSql.append(wh);
sbSql.append(" and de.cod_familia =");
sbSql.append(familyCode);
sbSql.append(" and de.cod_clase =");
sbSql.append(classCode);
sbSql.append(" and de.cod_articulo= ");
sbSql.append(id);

/* Salida x entrega a paciente */

//sql += " union ";

//sql +=" select 'D' type,'Salidas por Entrega a Pacientes' descType ,'0' no_cargo,' '  ,0  ,' '  costo_cargo ,' ' total_cargos , ' ' factura,0,' ',' '  ,0,0, 0 , 0, 0, 0,' ' nombre,' ' descArticulo,-1,rownum-1 rn from dual ";

sbSql.append("  union  all ");

sbSql.append(" select 'D' type,'ENT. PAC' descDoc,'Salidas por Entrega a Pacientes'descType,em.anio||'-'||em.no_entrega no_entrega,to_char(em.fecha_entrega,'dd/mm/yyyy') fecha_entrega, em.fecha_entrega fecha_docto,/*sum(nvl(de.cantidad,0)) * -1 */ nvl(de.cantidad,0) * -1 cantidad ,nvl(decode(de.costo, null, de.precio, de.costo),0) costo_entrega ,nvl(((nvl(de.cantidad,0) * -1)  * decode(de.costo, null, de.precio, de.costo)),0)  total_entrega , ' ' factura,em.paciente,' ' ,to_char(em.fecha_nacimiento,'dd/mm/yyyy')fecha_nacimiento ,em.adm_secuencia admision,sp.centro_servicio centro,de.cod_familia ,de.cod_clase ,de.cod_articulo ,em.codigo_almacen,primer_nombre||' '||primer_apellido||' -  '||cds.descripcion  nombre ,a.descripcion descArticulo,0,rownum+6000 rn from tbl_inv_entrega_material em , tbl_inv_detalle_entrega de, tbl_inv_solicitud_pac sp, tbl_adm_paciente p, tbl_cds_centro_servicio cds, tbl_inv_articulo a where (de.compania = em.compania and de.no_entrega  = em.no_entrega and de.anio = em.anio) and (em.compania = sp.compania and em.pac_solicitud_no= sp.solicitud_no and em.pac_anio = sp.anio) and a.compania = em.compania and em.compania =");
sbSql.append(compania);
sbSql.append(" and p.pac_id= em.pac_id and cds.codigo = sp.centro_servicio and de.cod_articulo= a.cod_articulo and de.cod_familia = ");
sbSql.append(familyCode);
sbSql.append(" and de.cod_clase   =  ");
sbSql.append(classCode);
sbSql.append(" and de.cod_articulo=  ");
sbSql.append(id);
sbSql.append(" and em.codigo_almacen =  ");
sbSql.append(wh);
sbSql.append(filter);

/*devolucion provvedor*/
//sql += " union ";
//sql += " select 'E' type,'Salidas por Devolucion a Proveedor' descType ,'0' no_cargo,' '  ,0  ,' '  costo_cargo ,' ' total_cargos , ' ' factura,0,' ',' '  ,0,0, 0 , 0, 0, 0,' ' nombre,' ' descArticulo,-1,rownum-1 rn from dual ";

sbSql.append(" union all ");

sbSql.append(" select 'E' type,'DEV. PROV' descDoc ,'Salidas por Devolucion a Proveedor'descType, d.anio||'-'||d.num_devolucion no_devolucion, to_char(d.fecha,'dd/mm/yyyy') fecha_dev, d.fecha fecha_docto, nvl(dp.cantidad,0) * -1 cantidad,nvl(dp.precio,0) costo_devolucion ,nvl(nvl(((dp.cantidad * -1) * nvl(dp.precio,0)+nvl(dp.art_itbm,0)),0),0) total_devolucion, ' ' factura,0,' ' ,' ',0,0 /*, dp.art_itbm*/ , dp.cod_familia,dp.cod_clase, dp.cod_articulo, d.codigo_almacen, cp.nombre_proveedor||'-'||d.nota_credito, a.descripcion descArticulo,-1,rownum+9000 rn from tbl_inv_devolucion_prov d, tbl_inv_detalle_proveedor dp,tbl_inv_articulo a,tbl_com_proveedor cp where (dp.compania = d.compania and  dp.num_devolucion = d.num_devolucion and  dp.anio = d.anio) ");

if(!fDate.trim().equals("")){sbSql.append(" and trunc(d.fecha) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(d.fecha) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}

sbSql.append(" and nvl(d.anulado_sino,'N') = 'N' and d.tipo_dev not in('C') and d.compania =");
sbSql.append(compania);
sbSql.append(" and a.compania = d.compania and cp.cod_provedor = d.cod_provedor and dp.cod_articulo= a.cod_articulo and d.codigo_almacen =");
sbSql.append(wh);
sbSql.append(" and dp.cod_familia =");
sbSql.append(familyCode);
sbSql.append("  and dp.cod_clase= ");
sbSql.append(classCode);
sbSql.append(" and dp.cod_articulo=");
sbSql.append(id);

/* Entregas a otros cliente */
/* sbSql.append(" union all ");
sbSql.append(" select 'F' type,'OTROS CARGOS' descDoc,'Transacciones de tipo otros Cargos' descType ,cc.anio||'-'||cc.codigo||'-'||cc.tipo_transaccion no_cargo,to_char(cc.fecha,'dd/mm/yyyy') fecha_cargo, cc.fecha fecha_docto, nvl(decode(cc.tipo_transaccion,'C',dc.cantidad * -1,'D', dc.cantidad ),0) cantidad ,nvl(dc.costo,0)   costo_cargo ,nvl((decode(cc.tipo_transaccion,'C', dc.cantidad * 1,'D',dc.cantidad * -1) * dc.costo),0) total_cargos , ' ' factura,0,' ',' '  ,0,0, dc.inv_art_familia , dc.inv_art_clase, dc.inv_cod_articulo, dc.inv_almacen,decode(cc.tipo_transaccion,'C','CARGOS OTROS' ||'- '||cc.cliente,'D','DEVOLUCION OTROS' ||'- '||cc.cliente) nombre,a.descripcion descArticulo,to_number(dc.secuencia),rownum+15000 rn from tbl_fac_detc_cliente dc , tbl_fac_cargo_cliente cc,tbl_inv_articulo a where (dc.compania = cc.compania and dc.anio = cc.anio and dc.tipo_transaccion = cc.tipo_transaccion and dc.cargo = cc.codigo)"); 
if(!fDate.trim().equals("")){sbSql.append(" and trunc(cc.fecha) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(cc.fecha) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}
sbSql.append(" and cc.compania = ");
sbSql.append(compania);
sbSql.append(" and dc.inv_cod_articulo = a.cod_articulo and dc.inv_almacen =");
sbSql.append(wh);
sbSql.append(" and a.compania = cc.compania and dc.inv_art_familia=");
sbSql.append(familyCode);
sbSql.append(" and dc.inv_art_clase =");
sbSql.append(classCode);
sbSql.append(" and dc.inv_cod_articulo =");
sbSql.append(id);*/

//sql += " union ";

//sql += " select 'F' type,'Transacciones de tipo otros Cargos' descType ,'0' no_cargo,' '  ,0  ,' '  costo_cargo ,' ' total_cargos , ' ' factura,0,' ',' '  ,0,0, 0 , 0, 0, 0,' ' nombre,' ' descArticulo,-1,rownum-1 rn from dual ";
sbSql.append(" order by 1,5 asc )x  union all ");
sbSql.append(" select 'EM' op, y.type,y.descDoc,y.descType,  y.codigo ,y.fecha, y.fecha_docto ,y.cantidad,y.costo ,y.total, y.factura ,y.n_entrega,y.usuario_creacion ,y.cod_proveedor, y.descAlmacen,' '||y.nombre as nombre, y.cod_almacen_sol, y.cod_alm_ent , y.descArticulo ,' ' fecha_nacimiento,0 admision, ''||y.cod_familia,''||y.cod_clase,''||y.cod_articulo,y.rn    from (");

sbSql.append("  select 'A' type,'RECEP. ' descDoc, ' Entradas por Recepcion de Material ' descType, /*recepcion de material*/  rm.anio_recepcion||'-'||rm.numero_documento codigo,to_char(rm.fecha_documento,'dd/mm/yyyy') fecha, rm.fecha_documento fecha_docto, sum(nvl(dr.cantidad,0) * nvl(dr.articulo_und,0)) cantidad ,nvl(dr.precio,0)  costo ,nvl((nvl(dr.cantidad,0) * nvl(dr.articulo_und,0)) * nvl(dr.precio,0),0) total , rm.numero_factura factura, nvl(rm.numero_entrega,0) n_entrega, rm.usuario_creacion usuario_creacion, p.cod_provedor cod_proveedor,' ' descAlmacen, rm.numero_factura||'-'||p.nombre_proveedor nombre, dr.cod_familia , dr.cod_clase, dr.cod_articulo, rm.codigo_almacen cod_almacen_sol, 0 cod_alm_ent,a.descripcion descArticulo, ' ' paciente,rownum+20000 rn from tbl_inv_recepcion_material rm, tbl_inv_detalle_recepcion dr, tbl_com_proveedor p,tbl_inv_inventario i,tbl_inv_articulo a where rm.estado = 'R' and rm.fre_documento not in ('FG') and (dr.compania = rm.compania and dr.numero_documento  = rm.numero_documento and dr.anio_recepcion = rm.anio_recepcion) and (rm.cod_proveedor = p.cod_provedor) and dr.cod_articulo = i.cod_articulo and  dr.cod_articulo = a.cod_articulo and dr.compania = a.compania and a.estado ='A' ");
if(!fDate.trim().equals("")){sbSql.append(" and trunc(rm.fecha_documento) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(rm.fecha_documento) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}
sbSql.append(" and  a.cod_flia  =");
sbSql.append(familyCode);
sbSql.append(" and a.cod_clase =  ");
sbSql.append(classCode);
sbSql.append(" and  dr.cod_articulo =");
sbSql.append(id);
sbSql.append(" and rm.codigo_almacen =");
sbSql.append(wh);
sbSql.append("  and rm.compania =");
sbSql.append(compania);
sbSql.append(" and rm.codigo_almacen = i.codigo_almacen and i.compania =  rm.compania  group by to_char(rm.fecha_documento,'dd/mm/yyyy'), rm.fecha_documento, rm.anio_recepcion||'-'||rm.numero_documento , nvl(dr.cantidad,0) * nvl(dr.articulo_und,0),nvl(dr.precio,0), (nvl(dr.cantidad,0) * nvl(dr.articulo_und,0)) * nvl(dr.precio,0) , rm.numero_factura , nvl(rm.numero_entrega,0), rm.usuario_creacion, p.cod_provedor, rm.numero_factura||'-'||p.nombre_proveedor, dr.cod_familia , dr.cod_clase, dr.cod_articulo, rm.codigo_almacen ,a.descripcion, rownum+20000 ");


//sql += " union ";  
//sql += " select 'A' type, ' Entradas por Recepcion de Material' descType ,'0' no_recepcion, ' ' fecha_recepcion, 0 cantidad, '0' precio_recepcion , '0' total_recepcion, ' ' factura,0 n_entrega,' ' usuario_creacion , 0 , ' ',' ' ,0,0  , 0, 0 ,0  ,' ', ' ' ,rownum-1 rn from dual ";
sbSql.append(" union  all ");

/*Query Transferencia entre Almacenes*/
sbSql.append(" select a.* from ( select 'B' type,'ENT. TRF ALM ' descDoc, ' Entradas por Transferencias desde Deposito' descType ,em.anio||'-'||em.no_entrega no_recepcion, to_char(em.fecha_entrega,'dd/mm/yyyy') fecha_recepcion, em.fecha_entrega fecha_docto, nvl(de.cantidad,0) cantidad, nvl(decode(de.costo,null, de.precio,de.costo),0) precio_recepcion , nvl(de.cantidad,0) * nvl((decode(de.costo,null,de.precio,de.costo)),0) total_recepcion, ' ' factura,em.no_entrega n_entrega,em.usuario_creacion , 0 cod_proveedor, ' ', al.descripcion   desc_proveedor , de.cod_familia , de.cod_clase , de.cod_articulo, sr.codigo_almacen cod_almacen_sol, em.codigo_almacen cod_alm_ent ,a.descripcion , ' ' paciente,rownum+30000 rn from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_req sr, tbl_inv_almacen al, tbl_inv_articulo a where sr.tipo_transferencia = 'A' and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and (al.compania = em.compania and al.codigo_almacen = em.codigo_almacen) ");
if(!fDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}

sbSql.append(" and a.compania = em.compania and de.cod_articulo = a.cod_articulo and  a.cod_flia  =");
sbSql.append(familyCode);
sbSql.append(" and  a.cod_clase =");
sbSql.append(classCode);
sbSql.append(" and de.cod_articulo = ");
sbSql.append(id);
sbSql.append(" and em.compania=");
sbSql.append(compania);
sbSql.append(" and sr.codigo_almacen =");
sbSql.append(wh);

//sql += " union ";
//sql += " select 'B' type, ' Entradas por Transferencias desde Deposito' descType ,'0' no_recepcion, ' ' fecha_recepcion, 0 cantidad, '0' precio_recepcion , '0' total_recepcion, ' ' factura,0 n_entrega,' ' usuario_creacion , 0 , ' ',' ' ,0,0  , 0, 0 ,0  ,' ', ' ',rownum-1 rn  from dual";
sbSql.append(" )a union all ");

/*Query Devolucion desde Unidades Administrativas y compañia*/
sbSql.append(" select 'C' type,'DEV. UND' descDoc, ' Entradas por Devolucion desde Unidad y Cia' descType ,dev.anio_devolucion||'-'||dev.num_devolucion num_devolucion ,to_char(dev.fecha_devolucion,'dd/mm/yyyy') fecha_devolucion, dev.fecha_devolucion fecha_docto, nvl(dd.cantidad,0) cantidad , nvl(dd.precio,0) precio ,nvl(dd.cantidad,0) * nvl(dd.precio,0)   total_devolucion, ' ' factura, dev.no_entrega n_entrega, dev.usuario_creacion, 0 cod_proveedor, ' '  descAlmacen, u.descripcion||' Dev:'||dev.anio_devolucion||'-'||dev.num_devolucion desc_proveedor , dd.cod_familia , dd.cod_clase, dd.cod_articulo, dev.codigo_almacen cod_almacen_dev , 0, a.descripcion , ' ' paciente,rownum+40000 rn from tbl_inv_devolucion dev, tbl_inv_detalle_devolucion dd, tbl_sec_unidad_ejec u, tbl_sec_compania c,tbl_inv_articulo a where (dd.compania = dev.compania and dd.num_devolucion = dev.num_devolucion and dd.anio_devolucion = dev.anio_devolucion) and c.codigo = u.compania and u.codigo = dev.unidad_administrativa and u.compania = dev.compania ");

if(!fDate.trim().equals("")){sbSql.append(" and trunc(dev.fecha_devolucion) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(dev.fecha_devolucion) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}

sbSql.append(" and nvl(dev.estado,'T') in ('R','A') and nvl(dd.estado_renglon,'P') ='E' and a.compania = dev.compania and dd.cod_articulo = a.cod_articulo  and dev.compania_dev =");
sbSql.append(compania);
sbSql.append(" and a.cod_flia =");
sbSql.append(familyCode);
sbSql.append(" and a.cod_clase = ");
sbSql.append(classCode);
sbSql.append(" and dd.cod_articulo = ");
sbSql.append(id);
sbSql.append(" and dev.codigo_almacen = ");
sbSql.append(wh);

/*Query entradas por devolucion de almacenes*/

sbSql.append(" union all select 'C' type,'DEV. ALM' descDoc,'Entrada por Devolucion desde el Deposito' descType,  d.anio_devolucion||'-'||d.num_devolucion num_devolucion ,to_char(d.fecha_devolucion,'dd/mm/yyyy') fecha_devolucion, d.fecha_devolucion fecha_docto, nvl(dd.cantidad,0) cantidad,nvl(dd.precio,0) costo ,nvl(((nvl(dd.cantidad,0)) * nvl(dd.precio,0)),0) total, ' ' factura,d.no_entrega n_entrega,d.usuario_creacion,0 cod_proveedor, ' ' desc_almacen,' dev '||substr(al.descripcion,0,12)||'. - Recibe '||al1.descripcion nombre,dd.cod_familia , dd.cod_clase, dd.cod_articulo, d.codigo_almacen cod_almacen_dev , 0, a.descripcion , ' ' paciente,rownum+4500 rn from tbl_inv_devolucion d , tbl_inv_detalle_devolucion dd, tbl_inv_almacen al,tbl_inv_almacen al1,tbl_inv_articulo a where (dd.compania =d.compania and dd.num_devolucion  =d.num_devolucion and dd.anio_devolucion=d.anio_devolucion) and (d.compania = al.compania and d.codigo_almacen_q_dev = al.codigo_almacen) and al1.codigo_almacen = d.codigo_almacen and al1.compania = d.compania ");

if(!fDate.trim().equals("")){sbSql.append(" and trunc(d.fecha_devolucion) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(d.fecha_devolucion) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}

sbSql.append(" and d.compania = ");
sbSql.append(compania);
sbSql.append(" and a.compania = d.compania and d.codigo_almacen=");
sbSql.append(wh);
sbSql.append(" and dd.cod_articulo= a.cod_articulo and a.cod_flia =");
sbSql.append(familyCode);
sbSql.append(" and a.cod_clase=");
sbSql.append(classCode);
sbSql.append("  and dd.cod_articulo= ");
sbSql.append(id);
sbSql.append(" and nvl(dd.estado_renglon,'P')='E' and nvl(d.estado,'T') in ('R','A')  and d.tipo_transferencia='EA' ");

//sql += " union ";
//sql += "select 'C' type, ' Entradas por Devolucion desde Unidad y Cia' descType ,'0' no_recepcion, ' ' fecha_recepcion, 0 cantidad, '0' precio_recepcion , '0' total_recepcion, ' ' factura,0 n_entrega,' ' usuario_creacion , 0 , ' ',' ' ,0,0  , 0, 0 ,0  ,' ', ' ',rownum -1 rn  from dual";

//sql += "  union  ";

/*Query Devolucion de Materiales de Paciente*/
//sql += " select 'D' type, ' Entradas por Devolucion de Materiales de Paciente' descType ,'0' no_recepcion, ' ' fecha_recepcion, 0 cantidad, '0' precio_recepcion , '0' total_recepcion, ' ' factura,0 n_entrega,' ' usuario_creacion , 0 , ' ',' ' ,0,0  , 0, 0 ,0  ,' ', ' ' ,rownum-1 rn from dual ";     
sbSql.append(" union all ");
sbSql.append(" select 'D' type,'DEV. PAC' descDoc,' Entradas por Devolucion de Materiales de Paciente' descType,  dp.anio||'-'||dp.num_devolucion no_devolucion,to_char(dp.fecha,'dd/mm/yyyy') fecha_devolucion, dp.fecha fecha_docto, nvl(det.cantidad,0)cantidad, nvl(det.costo,0) precio, nvl(det.cantidad,0) * nvl(det.costo,0) total_devolucion, ' ' factura, nvl(dp.no_entrega,0) n_entrega, dp.usuario_creacion, dp.sala_cod cod_proveedor, al.descripcion descAlmacen, p.primer_nombre||' '||p.primer_apellido||' - '||cds.descripcion desc_proveedor, det.cod_familia, det.cod_clase, det.cod_articulo, dp.codigo_almacen cod_almacen_dev_pac, 0, a.descripcion, p.primer_nombre||' '||p.primer_apellido paciente,rownum+50000 rn from tbl_inv_devolucion_pac dp, tbl_inv_detalle_paciente det,tbl_inv_almacen al, tbl_cds_centro_servicio cds,tbl_inv_articulo a,tbl_adm_paciente p where (det.compania = dp.compania and det.num_devolucion = dp.num_devolucion and det.anio_devolucion = dp.anio)");
if(!fDate.trim().equals("")){sbSql.append(" and trunc(dp.fecha) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(dp.fecha) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}

sbSql.append(" and dp.compania = ");
sbSql.append(compania);
sbSql.append(" and dp.estado = 'R' and dp.codigo_almacen = al.codigo_almacen  and dp.compania = al.compania and dp.sala_cod = cds.codigo and det.cod_articulo = a.cod_articulo and det.compania = a.compania and dp.pac_id = p.pac_id and a.cod_flia =");
sbSql.append(familyCode);
sbSql.append("  and a.cod_clase =");
sbSql.append(classCode);
sbSql.append("  and det.cod_articulo = ");
sbSql.append(id);
sbSql.append("  and dp.codigo_almacen =");
sbSql.append(wh);
sbSql.append("  order by 1,2 desc,11 asc ");

sbSql.append(" ) y  union all ");


/* transacciones de ajustes*/

sbSql.append(" select 'TA' op,w.type,w.descDoc,w.descType,  w.codigo ,w.fecha, w.fecha_docto, nvl(w.cantidad,0) cantidad,nvl(w.costo,0) costo,nvl(w.total,0) total , ' ' factura ,0 n_entrega, ' ' usuario_creacion ,0 cod_proveedor, ' ' descAlmacen,' '||w.nombre,w.codigo_almacen, 0 cod_alm_ent , w.descArticulo , ' ' fecha_nacimiento,0 admision ,w.cod_familia,w.cod_clase,w.cod_articulo,w.rn from ( select 'TA1' type,'AJ. CORR' descDoc,'Transacciones por Ajuste al Inventario' descType ,to_char(aj.fecha_ajuste,'dd/mm/yyyy') fecha, aj.fecha_ajuste fecha_docto, aj.anio_ajuste||'-'||aj.numero_ajuste  codigo, decode(t.sign_tipo_ajuste,'-',-1*nvl(da.cantidad_ajuste,0),nvl(da.cantidad_ajuste,0)) cantidad , nvl(da.precio,0) costo ,( decode(t.sign_tipo_ajuste,'-',-1*nvl(da.cantidad_ajuste,0),nvl(da.cantidad_ajuste,0)) * nvl(da.precio,0)) total,aj.anio_ajuste||'-'||aj.numero_ajuste||'-'||aj.numero_doc||'- User: '||aj.USUARIO_CREACION||' Tipo Ajuste: '||T.DESCRIPCION||' '||da.Observacion nombre , da.cod_familia , da.cod_clase , da.cod_articulo , aj.codigo_almacen , a.descripcion descArticulo,rownum+60000 rn from tbl_inv_ajustes aj, tbl_inv_detalle_ajustes da, tbl_inv_tipo_ajustes t,tbl_inv_articulo a where aj.codigo_ajuste = 4 and aj.estado = 'A' and nvl(da.check_aprov,'N') = 'S' and (da.compania = aj.compania and da.codigo_ajuste = aj.codigo_ajuste and da.numero_ajuste = aj.numero_ajuste and da.anio_ajuste = aj.anio_ajuste) and aj.codigo_ajuste = t.codigo_ajuste ");
if(!fDate.trim().equals("")){sbSql.append(" and trunc(aj.fecha_ajuste) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(aj.fecha_ajuste) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}

sbSql.append(" and aj.compania = ");
sbSql.append(compania);
sbSql.append(" and a.compania = aj.compania and da.cod_articulo = a.cod_articulo and aj.codigo_almacen = ");
sbSql.append(wh);
sbSql.append(" and a.cod_flia = ");
sbSql.append(familyCode);
sbSql.append(" and a.cod_clase =");
sbSql.append(classCode);
sbSql.append(" and da.cod_articulo =");
sbSql.append(id);

sbSql.append(" union all ");
sbSql.append(" select 'TA2' type,'AJ. OTROS' descDoc,'Transacciones por Ajuste al Inventario' descType,to_char(aj.fecha_ajuste,'dd/mm/yyyy')  fecha_ajuste, aj.fecha_ajuste fecha_docto, aj.anio_ajuste||'-'||aj.numero_ajuste  no_ajuste, decode(ta.sign_tipo_ajuste,'-',-1*nvl(da.cantidad_ajuste,0),nvl(da.cantidad_ajuste,0)) cantidad, nvl(da.precio,0) costo_ajuste,(decode(ta.sign_tipo_ajuste,'-',-1*nvl(da.cantidad_ajuste,0),nvl(da.cantidad_ajuste,0)) * nvl(da.precio,0)) total_ajuste,	aj.anio_ajuste||'-'||aj.numero_ajuste||'-'||aj.numero_doc||'- User: '||aj.usuario_creacion||' Tipo Ajuste: '||ta.descripcion||' '||da.observacion descripcion , da.cod_familia, da.cod_clase , da.cod_articulo , aj.codigo_almacen, a.descripcion descArticulo ,rownum+80000 rn from  tbl_inv_detalle_ajustes da, tbl_inv_ajustes aj, tbl_inv_almacen al,tbl_inv_tipo_ajustes ta,tbl_inv_articulo a where aj.codigo_ajuste <> 4 and aj.estado = 'A' and (da.compania = aj.compania and da.codigo_ajuste = aj.codigo_ajuste and da.numero_ajuste = aj.numero_ajuste and da.anio_ajuste = aj.anio_ajuste) and aj.codigo_ajuste = ta.codigo_ajuste and (aj.codigo_almacen = al.codigo_almacen and aj.compania = al.compania) and aj.codigo_almacen =");
sbSql.append(wh);
sbSql.append("  and nvl(da.check_aprov,'N') = 'S' and aj.compania =");
sbSql.append(compania);
sbSql.append(" and a.compania = aj.compania and da.cod_articulo = a.cod_articulo and a.cod_flia =");
sbSql.append(familyCode);
sbSql.append(" and a.cod_clase =");
sbSql.append(classCode);
sbSql.append(" and da.cod_articulo  =");
sbSql.append(id);
if(!fDate.trim().equals("")){sbSql.append(" and trunc(aj.fecha_ajuste) >= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(aj.fecha_ajuste) <= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy')");}

//sql += " union ";

sbSql.append("/*select 'TA0' type,'Transacciones por Ajuste al Inventario' descType,' ' fecha_ajuste, '0' no_ajuste, 0 cantidad, '  ' costo_ajuste,' ' total_ajuste,' ' descripcion ,'0' cod_familia, '0 'cod_clase , '0' cod_articulo , 0 codigo_almacen, ' '  descArticulo,rownum-1 rn from dual*/) w   order by 7, 6, 2 asc,5 desc");

if (!tipoMov.trim().equals("")) {
   StringBuffer _sbSql = new StringBuffer();
   _sbSql.append("select aaa.* from(");
   _sbSql.append(sbSql.toString());
   _sbSql.append(") aaa where aaa.descDoc like '");
   _sbSql.append(tipoMov);
   _sbSql.append("%'");
  
   al = SQLMgr.getDataList(_sbSql.toString());
}
else al = SQLMgr.getDataList(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
/*--------------------------------------------------------------------------------------*/
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
	String title = "INVENTARIO";
	String subtitle = "MOVIMIENTO DE ARTICULOS POR DEPOSITO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages    
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
    //float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	Vector dHeader = new Vector();		
		dHeader.addElement(".08");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".25");
		dHeader.addElement(".09");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row		
		/*pc.setFont(7, 1);
		pc.addBorderCols("DESC. ARTICULO",0);
		pc.addBorderCols("CODIGO",0);
		
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
        */

	//table body
	String groupBy = "",subGroupBy = "";
/*--------------------------------------------------------------------------------------*/

	double subTotal = 0.0,subTotal2=0.0,subTotal3 =0.0;
	double total = 0.0;
	
	pc.setFont(9, 1);
	pc.addCols("Fecha de Ultimo Inventario: "+fecha_corrida,1,dHeader.size());	
	pc.copyTable("detailHeader4");	
	
	pc.setFont(9, 1);
	pc.addCols("Desde    "+fDate+"     hasta      "+tDate,1,dHeader.size());	
	pc.copyTable("detailHeader6");
	
	pc.setNoColumnFixWidth(dHeader);	
	pc.setFont(9, 1);
	pc.addCols(" "+cdo1.getColValue("descAlmacen"),1,dHeader.size());	
	pc.copyTable("detailHeader5");	
	
	pc.setFont(9, 1);
	pc.addCols(" Codigo: ",0,1);
	pc.addCols(" "+cdo1.getColValue("codigo"),0,1);
	pc.addCols(" "+cdo1.getColValue("descArticulo"),0,3);
	pc.addCols(" Und Sist:  "+CmnMgr.getFormattedDecimal(cdo1.getColValue("disponible")),0,2);
	pc.addCols(" Precio Venta:  "+CmnMgr.getFormattedDecimal(cdo1.getColValue("precio_venta")),0,2);	
	pc.copyTable("detailHeader3");	
	
	pc.setFont(9, 1);
	pc.addCols(" Anaquel: ",0,1);
	pc.addCols(" "+cdo1.getColValue("anaquel"),0,4);		
	pc.addCols(" U. Compra:  "+cdo1.getColValue("ultima_compra"),0,2);
	pc.addCols(" Costo Promedio:  "+CmnMgr.getFormattedDecimal(cdo1.getColValue("costo")),0,2);	
	pc.copyTable("detailHeader2");
	
	pc.setFont(9, 1);
	pc.addBorderCols("Fecha",1);
	pc.addBorderCols("# Documento",1);
	pc.addBorderCols("Tipo Mov.",1);
	pc.addBorderCols("Descripciòn",1);
	pc.addBorderCols("Disponible",1);
	pc.addBorderCols("Cantidad",1);
	pc.addBorderCols("Costo",1);
	pc.addBorderCols("Total",1);
	pc.addBorderCols("Total Disp.",1);	
	pc.copyTable("detailHeader");
	
	pc.setFont(9, 1);
	pc.addCols("  "+cdo1.getColValue("fecha_conteo"),0,1);
	pc.addCols("Conteo # "+cdo1.getColValue("codigo_conteo"),0,2);
	pc.addCols("Valores Del Conteo Fisico ",0,2);
	pc.addCols("  "+cdo1.getColValue("cantidad_contada"),2,1);
	pc.addCols("  "+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo1.getColValue("costo")),2,1);
	pc.addCols("  ",0,2);	
	pc.copyTable("detailHeader1");
	
	if(cdo1.getColValue("sumarConteo").trim().equals("S")){total +=  Double.parseDouble(cdo1.getColValue("cantidad_contada"));
	subTotal2 +=  Double.parseDouble(cdo1.getColValue("cantidad_contada"));
	subTotal +=  Double.parseDouble(cdo1.getColValue("cantidad_contada"));
	}
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		String totalCosto ="0";
		if(cdo.getColValue("codigo").trim().equals("0"))
		{
			if(i > 0)
			{
			  pc.setFont(9, 1);				
			  pc.addCols(" Sub Total :",2,5);
			  pc.addCols(" "+CmnMgr.getFormattedDecimal(""+subTotal),2,1);
			  pc.addCols(" "+CmnMgr.getFormattedDecimal(""+subTotal2),2,1);
			  pc.addCols(" ",2,2);				
			  subTotal=0;
			}

			pc.setFont(9, 0,Color.blue);			
			pc.addCols(" "+cdo.getColValue("descType"),0,dHeader.size());
			pc.copyTable("detailHeader10");
		}
		else
		{
			pc.setFont(9, 0);
			pc.setVAlignment(1);			
			pc.addCols(" "+cdo.getColValue("fecha"),0,1);
			pc.addCols(" "+cdo.getColValue("codigo"),0,1);
			pc.addCols(" "+cdo.getColValue("descDoc"),0,1);
			pc.addCols(" "+cdo.getColValue("nombre"),0,0);
			subTotal2 +=  Double.parseDouble(cdo.getColValue("cantidad"));
			pc.addCols(" "+subTotal2,2,1);			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad")),2,1);
			pc.addCols(" $"+CmnMgr.getFormattedDecimal(cdo.getColValue("costo")),2,1);
			if(cdo.getColValue("op").trim().equals("EM") && cdo.getColValue("type").trim().equals("C"))//DEV. UND
			totalCosto = cdo.getColValue("costo");
			else if(cdo.getColValue("op").trim().equals("EM") && cdo.getColValue("type").trim().equals("A")){//recepcion de material 
			 totalCosto = cdo.getColValue("total");
			}
			else totalCosto = cdo.getColValue("total");//Entradas por Transferencias desde Deposito
			
			if(totalCosto != null && !totalCosto.trim().equals(""))
			subTotal3 =  Double.parseDouble(totalCosto);
			
			pc.addCols(" $"+CmnMgr.getFormattedDecimal(totalCosto),2,1);
			pc.addCols(" $"+CmnMgr.getFormattedDecimal((subTotal2 * Double.parseDouble(cdo.getColValue("costo")))),2,1);
			
			
			total +=  Double.parseDouble(cdo.getColValue("cantidad"));
			subTotal +=  Double.parseDouble(cdo.getColValue("cantidad"));
			
				
		}	
		pc.resetVAlignment();
				
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		
	}//for i	
	
	if (al.size() == 0) 
	{
	  pc.addCols("No existen registros",1,dHeader.size());
	}else{
	  pc.setFont(9, 1);
	  pc.addCols(" Sub Total :",2,4);
	  pc.addCols(" "+CmnMgr.getFormattedDecimal(subTotal2),2,1);
	  pc.addCols(" "+CmnMgr.getFormattedDecimal(subTotal),2,1);
	  pc.addCols(" ",2,3);
	
	  pc.setFont(9, 1,Color.blue);		
	  pc.addCols(" T O T A L :",2,4);
	  pc.addCols(" "+CmnMgr.getFormattedDecimal(total),2,2);
	  pc.addCols(" ",2,3);	  
	  pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	  }
	   pc.addCols(" ",0,dHeader.size());
	  pc.addCols("TIPOS DE MOVIMIENTOS ",0,dHeader.size());
	  pc.setFont(9, 1);
pc.addCols("DEV. ALM      Devolucion desde el Deposito",0,dHeader.size());
pc.addCols("ENT. UND      Entrega a  unidades",0,dHeader.size());
pc.addCols("ENT. TRF ALM  Transferencias desde Deposito",0,dHeader.size());
pc.addCols("TRF. ALM.     Transferencias entre  Almacenes",0,dHeader.size());
pc.addCols("ENT. PAC.     Entrega a Pacientes",0,dHeader.size());
pc.addCols("DEV. PROV     Devolucion a Proveedor",0,dHeader.size());
pc.addCols("OTROS CARGOS  Transacciones de tipo otros Cargos",0,dHeader.size());
pc.addCols("RECEP         Recepcion de Material",0,dHeader.size());
pc.addCols("DEV. UND      Devolucion desde Unidad y Cia",0,dHeader.size());
pc.addCols("DEV. PAC      Devolucion de Materiales de Paciente",0,dHeader.size());
pc.addCols("AJ. CORR      Ajuste al Inventario para Correccion",0,dHeader.size());
pc.addCols("AJ. OTROS     Ajuste al Inventario",0,dHeader.size());
	  
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);	  
}//get
%>
