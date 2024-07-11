
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200025") || SecMgr.checkAccess(session.getId(),"200026") || SecMgr.checkAccess(session.getId(),"200027") || SecMgr.checkAccess(session.getId(),"200028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alWh = new ArrayList();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String wh = request.getParameter("wh");
String fp = request.getParameter("fp");
String id = request.getParameter("id");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");

if (familyCode == null || familyCode.trim().equals("")) throw new Exception("La Familia del Artículo no es válida. Por favor intente nuevamente!");
if (classCode == null || classCode.trim().equals("")) throw new Exception("La Clase del Artículo no es válida. Por favor intente nuevamente!");
if (id == null || id.trim().equals("")) throw new Exception("El Código del Artículo no es válido. Por favor intente nuevamente!");
if (wh == null || wh.trim().equals("")) throw new Exception("La Bodega no es válida. Por favor intente nuevamente!");
if (fp == null || fp.trim().equals("")) throw new Exception("El Tipo de Movimiento no es válido. Por favor intente nuevamente!");
if (fechaini == null ) fechaini = "";
if (fechafin == null ) fechafin = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage=100;
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

	if (fp.trim().equals("S"))
	{
	// Salidas por Devolucion desde el Deposito
sql="select 'A' type,  d.anio_devolucion||'-'||d.num_devolucion codigo ,to_char(d.fecha_devolucion,'dd/mm/yyyy') fecha ,nvl(dd.cantidad,0)* -1 cantidad,to_char(nvl(dd.precio,0),'999,990.0000') costo ,to_char(nvl(((nvl(dd.cantidad,0)* -1) * nvl(dd.precio,0)),0),'999,990.0000') total ,' ' fecha_nacimiento,0 paciente ,0 admision ,0 centro,dd.cod_familia ,dd.cod_clase,dd.cod_articulo ,d.codigo_almacen_q_dev codigo_almacen ,' dev '||substr(al.descripcion,0,12)||'. - Recibe '||al1.descripcion nombre , a.descripcion descArticulo,'Salidas por Devolucion desde el Deposito' descType from tbl_inv_devolucion d , tbl_inv_detalle_devolucion dd, tbl_inv_almacen al,tbl_inv_almacen al1,tbl_inv_articulo a where (dd.compania =d.compania and dd.num_devolucion  =d.num_devolucion and dd.anio_devolucion  =d.anio_devolucion) and (d.compania = al.compania and d.codigo_almacen_q_dev = al.codigo_almacen) and to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and d.compania = "+(String) session.getAttribute("_companyId")+" and a.compania = d.compania and al1.codigo_almacen = d.codigo_almacen and al1.compania = d.compania  and d.codigo_almacen_q_dev  = "+wh+" and dd.cod_articulo= a.cod_articulo and dd.cod_articulo= "+id;


/* Salida x entrega a unidades o companias */

sql += " union " ;
sql +="select 'B' type , em.anio||'-'||em.no_entrega no_entrega, to_char(em.fecha_entrega,'dd/mm/yyyy') fecha_entrega, nvl(de.cantidad,0) * -1 cantidad,  to_char(decode(de.costo, null,de.precio,de.costo),'999,990.0000') costo_entrega ,to_char(((nvl(de.cantidad,0) * -1) * nvl(decode(de.costo, null,de.precio, de.costo),0)) ,'999,990.0000') total_entrega ,' ',0, 0,0, a.cod_flia cod_familia, a.cod_clase, de.cod_articulo , em.codigo_almacen, decode(sr.tipo_transferencia,'U',ue.descripcion,'C',co.nombre) nombre , a.descripcion descArticulo,'Salidas por Entrega a Unidades Adm. y Compañias'descType from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_req sr , tbl_sec_unidad_ejec ue , tbl_sec_compania co, tbl_inv_articulo a where (de.compania   = em.compania and   de.no_entrega = em.no_entrega and de.anio = em.anio) and  (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and ue.codigo = sr.unidad_administrativa and ue.compania = sr.compania and co.codigo = ue.compania and sr.tipo_transferencia in ('U','C') and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy'))  and em.compania = "+(String) session.getAttribute("_companyId")+" and a.compania = em.compania and de.cod_articulo= a.cod_articulo and de.cod_articulo= "+id+" and em.codigo_almacen = "+wh;

 /* Salida transferencia desde el deposito */
sql +=" union  ";
sql += "select 'C' type  ,em.anio||'-'||em.no_entrega no_entrega,to_char(em.fecha_entrega,'dd/mm/yyyy') fecha_entrega ,nvl(de.cantidad,0) * -1 cantidad ,to_char(nvl(decode(de.costo, null, de.precio, de.costo),0),'999,990.0000') costo_entrega ,to_char(((nvl(de.cantidad,0) * -1) * decode(de.costo, null,nvl(de.precio,0),nvl(de.costo,0))),'999,990.0000') total_entrega ,' ',0,0,0, a.cod_flia, a.cod_clase  , de.cod_articulo , em.codigo_almacen , al.descripcion   nombre_almacen , a.descripcion descArticulo,'Salidas por Transferencias entre  Almacenes'descType	from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_almacen al, tbl_inv_solicitud_req sr, tbl_inv_articulo a where (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and (sr.compania_sol = al.compania and  sr.codigo_almacen = al.codigo_almacen) and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and em.compania = "+(String) session.getAttribute("_companyId")+" and a.compania = em.compania and de.cod_articulo= a.cod_articulo and sr.codigo_almacen_ent = "+wh+" and de.cod_articulo=  "+id;

/* Salida x entrega a paciente */
sql +=" union  ";
sql +=" select 'D' type,em.anio||'-'||em.no_entrega no_entrega,to_char(em.fecha_entrega,'dd/mm/yyyy') fecha_entrega,nvl(de.cantidad,0) * -1  cantidad ,to_char(decode(de.costo, null, de.precio, de.costo),'999,990.0000') costo_entrega ,to_char(((nvl(de.cantidad,0) * -1)  * decode(de.costo, null, de.precio, de.costo)) ,'999,990.0000') total_entrega ,to_char(em.fecha_nacimiento,'dd/mm/yyyy')fecha_nacimiento ,em.paciente,em.adm_secuencia admision,sp.centro_servicio centro,a.cod_flia ,a.cod_clase ,de.cod_articulo ,em.codigo_almacen,primer_nombre||' '||primer_apellido||' '||cds.descripcion  nombre ,a.descripcion descArticulo,'Salidas por Entrega a Pacientes'descType from tbl_inv_entrega_material em , tbl_inv_detalle_entrega de, tbl_inv_solicitud_pac sp, tbl_adm_paciente p, tbl_cds_centro_servicio cds, tbl_inv_articulo a where (de.compania = em.compania and de.no_entrega  = em.no_entrega and de.anio = em.anio) and (em.compania   = sp.compania and em.pac_solicitud_no= sp.solicitud_no and em.pac_anio = sp.anio) and a.compania = em.compania and em.compania = "+(String) session.getAttribute("_companyId")+" and p.pac_id= em.pac_id and cds.codigo = sp.centro_servicio and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and de.cod_articulo= a.cod_articulo and de.cod_articulo= "+id+" and em.codigo_almacen = "+wh; 


/*devolucion provvedor*/
sql +=" union ";
sql +="select 'E' type , d.anio||'-'||d.num_devolucion no_devolucion, to_char(d.fecha,'dd/mm/yyyy') fecha_dev,nvl(dp.cantidad,0) * -1 cantidad,to_char(nvl(dp.precio,0),'999,990.0000') costo_devolucion ,to_char(nvl(((dp.cantidad * -1) * nvl(dp.precio,0)+nvl(dp.art_itbm,0)),0),'999,990.0000') total_devolucion ,' ',0,0,0 /*, dp.art_itbm*/ , a.cod_flia,a.cod_clase, dp.cod_articulo, d.codigo_almacen, cp.nombre_proveedor||'-'||d.nota_credito, a.descripcion descArticulo	,'Salidas por Devolucion a Proveedor'descType from tbl_inv_devolucion_prov d, tbl_inv_detalle_proveedor dp,tbl_inv_articulo a,tbl_com_proveedor cp where (dp.compania = d.compania and  dp.num_devolucion = d.num_devolucion and  dp.anio = d.anio) and to_date(to_char(d.fecha ,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(d.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(d.fecha,'dd/mm/yyyy'),'dd/mm/yyyy'))  and d.anulado_sino = 'N' and d.compania = "+(String) session.getAttribute("_companyId")+" and a.compania = d.compania and cp.cod_provedor = d.cod_provedor and dp.cod_articulo= a.cod_articulo and d.codigo_almacen = "+wh+" and dp.cod_articulo= "+id;

 sql +=" order by 1,3 asc ";
	}
	else if (fp.trim().equals("A"))
	{
		
		sql += " select 'A' op, w.type,w.descType,  w.codigo ,w.fecha ,w.cantidad,w.costo,w.total , ' ' factura ,0 n_entrega, ' ' usuario_creacion ,0 cod_proveedor, ' ' descAlmacen,' '||w.nombre nombre ,w.codigo_almacen, 0 cod_alm_ent , w.descArticulo , ' ' fecha_nacimiento,0 admision ,w.cod_familia,w.cod_clase,w.cod_articulo from ( select 'TA1' type,'Transacciones por Ajuste al Inventario' descType ,to_char(aj.fecha_ajuste,'dd/mm/yyyy') fecha, aj.anio_ajuste||'-'||aj.numero_ajuste  codigo, nvl(da.cantidad_ajuste,0) cantidad ,to_char( nvl(da.precio,0),'999,990.0000') costo ,to_char((nvl(da.cantidad_ajuste,0) * nvl(da.precio,0)),'999,990.0000') total,decode(aj.anio_ajuste||'-'||aj.numero_ajuste,'2006-79','AJUSTE 2006-79 POR VALORES AL CONTEO FISICO AL 04-12-2006' ,aj.anio_ajuste||'-'||aj.numero_ajuste||'-'||aj.numero_doc||'- User: '||aj.USUARIO_CREACION||' Tipo Ajuste: '||T.DESCRIPCION||' '||da.Observacion ) nombre,a.cod_flia ,  a.cod_clase , da.cod_articulo , aj.codigo_almacen , a.descripcion descArticulo from tbl_inv_ajustes aj, tbl_inv_detalle_ajustes da, tbl_inv_tipo_ajustes t,tbl_inv_articulo a where aj.codigo_ajuste = 4 and aj.estado = 'A' and (da.compania = aj.compania and da.codigo_ajuste = aj.codigo_ajuste and da.numero_ajuste = aj.numero_ajuste and da.anio_ajuste = aj.anio_ajuste) and aj.codigo_ajuste = t.codigo_ajuste  and to_date(to_char(aj.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(aj.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(aj.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy')) and aj.compania =  "+(String) session.getAttribute("_companyId")+" and a.compania = aj.compania and da.cod_articulo = a.cod_articulo and aj.codigo_almacen =  "+wh+" and da.cod_articulo =  "+id;
sql += " union  ";
sql += " select 'TA2' type,'Transacciones por Ajuste al Inventario' descType,to_char(aj.fecha_ajuste,'dd/mm/yyyy')  fecha_ajuste, aj.anio_ajuste||'-'||aj.numero_ajuste  no_ajuste, nvl(da.cantidad_ajuste ,0) cantidad, to_char(nvl(da.precio,0),'999,990.0000') costo_ajuste,to_char((nvl(da.cantidad_ajuste,0) * nvl(da.precio,0)),'999,990.0000') total_ajuste,decode(aj.anio_ajuste||'-'||aj.numero_ajuste,'2006-79','AJUSTE 2006-79 POR VALORES AL CONTEO FISICO AL 04-12-2006' 	,aj.anio_ajuste||'-'||aj.numero_ajuste||'-'||aj.numero_doc||'- User: '||aj.usuario_creacion||' Tipo Ajuste: '||ta.descripcion||' '||da.observacion) descripcion ,a.cod_flia, a.cod_clase,da.cod_articulo , aj.codigo_almacen, a.descripcion descArticulo  from  tbl_inv_detalle_ajustes da, tbl_inv_ajustes aj, tbl_inv_almacen al,tbl_inv_tipo_ajustes ta,tbl_inv_articulo a where aj.codigo_ajuste <> 4 and (da.compania = aj.compania and da.codigo_ajuste = aj.codigo_ajuste and da.numero_ajuste = aj.numero_ajuste and da.anio_ajuste = aj.anio_ajuste) and aj.codigo_ajuste = ta.codigo_ajuste and (aj.codigo_almacen = al.codigo_almacen and aj.compania = al.compania) and aj.codigo_almacen = "+wh+"  and da.check_aprov = 'S' and aj.compania = "+(String) session.getAttribute("_companyId")+"  and a.compania = aj.compania and da.cod_articulo = a.cod_articulo and da.cod_articulo = "+id+" and to_date(to_char(aj.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(aj.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(aj.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy'))) w ";
		 
	
	}
	else if (fp.trim().equals("E"))
	{
			sql="select 'A' type, ' Entradas por Recepcion de Material ' descType, /*recepcion de material*/ to_char(rm.fecha_documento,'dd/mm/yyyy') fecha, rm.anio_recepcion||'-'||rm.numero_documento codigo, sum(nvl(dr.cantidad,0) * nvl(dr.articulo_und,0)) cantidad ,to_char(nvl(dr.precio,0) ,'999,990.0000') costo ,to_char((nvl(dr.cantidad,0) * nvl(dr.articulo_und,0)) * nvl(dr.precio,0),'999,990.0000') total , rm.numero_factura factura, nvl(rm.numero_entrega,0) n_entrega, rm.usuario_creacion usuario_creacion, p.cod_provedor,' ' descAlmacen, rm.numero_factura||'-'||p.nombre_proveedor nombre, a.cod_flia , a.cod_clase, dr.cod_articulo, rm.codigo_almacen cod_almacen_sol,0 cod_alm_ent,a.descripcion descArticulo, ' ' paciente from tbl_inv_recepcion_material rm, tbl_inv_detalle_recepcion dr, tbl_com_proveedor p,tbl_inv_inventario i,tbl_inv_articulo a where rm.estado = 'R' and (dr.compania = rm.compania and dr.numero_documento  = rm.numero_documento and dr.anio_recepcion = rm.anio_recepcion) and (rm.cod_proveedor = p.cod_provedor) and dr.cod_articulo = i.cod_articulo and  dr.cod_articulo = a.cod_articulo and a.estado ='A'  and to_date(to_char(rm.fecha_documento ,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(rm.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(rm.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy')) and dr.cod_articulo = "+id+" and rm.codigo_almacen = "+wh+" and rm.compania = "+(String) session.getAttribute("_companyId")+" and rm.codigo_almacen = i.codigo_almacen group by to_char(rm.fecha_documento,'dd/mm/yyyy') , rm.anio_recepcion||'-'||rm.numero_documento , nvl(dr.cantidad,0) * nvl(dr.articulo_und,0),nvl(dr.precio,0), (nvl(dr.cantidad,0) * nvl(dr.articulo_und,0)) * nvl(dr.precio,0) , rm.numero_factura , nvl(rm.numero_entrega,0), rm.usuario_creacion, p.cod_provedor, rm.numero_factura||'-'||p.nombre_proveedor, a.cod_flia , a.cod_clase, dr.cod_articulo, rm.codigo_almacen ,a.descripcion ";
	
sql +=" union ";

/*Query Transferencia entre Almacenes*/

sql +="select 'B' type, ' Entradas por Transferencias desde Deposito' descType, to_char(em.fecha_entrega,'dd/mm/yyyy') fecha_recepcion ,em.anio||'-'||em.no_entrega no_recepcion, nvl(de.cantidad,0) cantidad, to_char(nvl(decode(de.costo,null, de.precio,de.costo),0),'999,990.0000') precio_recepcion , to_char(nvl(de.cantidad,0) * nvl((decode(de.costo,null,de.precio,de.costo)),0),'999,990.0000') total_recepcion, ' ' factura,em.no_entrega n_entrega,em.usuario_creacion , 0 cod_proveedor, ' ', al.descripcion   desc_proveedor , a.cod_flia , a.cod_clase , de.cod_articulo, sr.codigo_almacen cod_almacen_sol, em.codigo_almacen cod_alm_ent ,a.descripcion , ' ' paciente from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_req sr, tbl_inv_almacen al, tbl_inv_articulo a where sr.tipo_transferencia = 'A' and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and (al.compania = em.compania and al.codigo_almacen = em.codigo_almacen) and to_date(to_char(em.fecha_entrega ,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and a.compania = em.compania and de.cod_articulo = a.cod_articulo and de.cod_articulo = "+id+" and em.compania= "+(String) session.getAttribute("_companyId")+" /* and em.codigo_almacen = sr.codigo_almacen_ent*/ and sr.codigo_almacen = "+wh+"";

sql +=" union ";

/*Query Devolucion desde Unidades Administrativas y compañia*/

sql +="select 'C' type, ' Entradas por Devolucion desde Unidad y Cia' descType,to_char(dev.fecha_devolucion,'dd/mm/yyyy') fecha_devolucion ,dev.anio_devolucion||'-'||dev.num_devolucion num_devolucion , nvl(dd.cantidad,0) cantidad , to_char(nvl(dd.precio,0),'999,990.0000') precio ,to_char(nvl(dd.cantidad,0) * nvl(dd.precio,0)  ,'999,990.0000') total_devolucion, ' ' factura, dev.no_entrega n_entrega, dev.usuario_creacion, 0 cod_proveedor, ' '  descAlmacen, u.descripcion||' Dev:'||dev.anio_devolucion||'-'||dev.num_devolucion desc_proveedor , a.cod_flia , a.cod_clase, dd.cod_articulo, dev.codigo_almacen cod_almacen_dev , 0, a.descripcion , ' ' paciente from tbl_inv_devolucion dev, tbl_inv_detalle_devolucion dd, tbl_sec_unidad_ejec u, tbl_sec_compania c,tbl_inv_articulo a where (dd.compania = dev.compania and dd.num_devolucion = dev.num_devolucion and dd.anio_devolucion = dev.anio_devolucion) and c.codigo = u.compania and u.codigo = dev.unidad_administrativa and u.compania = dev.compania and to_date(to_char(dev.fecha_devolucion ,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(dev.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(dev.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and a.compania = dev.compania and dd.cod_articulo = a.cod_articulo  and dev.compania_dev  = "+(String) session.getAttribute("_companyId")+" and dd.cod_articulo = "+id+" and dev.codigo_almacen = "+wh;

sql +="  UNION  ";

/*Query Devolucion de Materiales de Paciente*/

sql +="select 'D' type,' Entradas por Devolucion de Paciente' descType, to_char(dp.fecha,'dd/mm/yyyy') fecha_devolucion, dp.anio||'-'||dp.num_devolucion no_devolucion, nvl(det.cantidad,0)cantidad, to_char(nvl(det.precio,0),'999,990.0000') precio, to_char(nvl(det.cantidad,0) * nvl(det.costo,0),'999,990.0000') total_devolucion, ' ' factura, nvl(dp.no_entrega,0) n_entrega, dp.usuario_creacion, dp.sala_cod cod_proveedor, al.descripcion descAlmacen, p.primer_nombre||' '||p.primer_apellido||' - '|| cds.descripcion desc_proveedor, a.cod_flia, a.cod_clase, det.cod_articulo, dp.codigo_almacen cod_almacen_dev_pac, 0, a.descripcion, p.primer_nombre||' '||p.primer_apellido paciente from tbl_inv_devolucion_pac dp, tbl_inv_detalle_paciente det,tbl_inv_almacen al, tbl_cds_centro_servicio cds,tbl_inv_articulo a,tbl_adm_paciente p where (det.compania = dp.compania and det.num_devolucion = dp.num_devolucion and det.anio_devolucion = dp.anio) and to_date(to_char(dp.fecha ,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(dp.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(dp.fecha,'dd/mm/yyyy'),'dd/mm/yyyy'))  and dp.compania = "+(String) session.getAttribute("_companyId")+" and dp.estado = 'R' and dp.codigo_almacen = al.codigo_almacen and dp.compania = al.compania and dp.sala_cod = cds.codigo and det.cod_articulo = a.cod_articulo and dp.pac_id = p.pac_id and det.cod_articulo = "+id+" and dp.codigo_almacen = "+wh+" order by 1,2 desc ";
	
	
	}
	
	
	
 //al = SQLMgr.getDataList(sql);
 al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		
 rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

	System.out.println(" al size() ="+al.size());
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
<script language="javascript">
document.title = 'Inventario - Articulos - '+document.title;

function  printList()
{
	abrir_ventana1('print_list_articulos.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MOVIMIENTO - ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<tr>
	<td align="right">&nbsp;
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200026"))
//{
%>
		<!--<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>-->
<%
//}
%>
	</td>
</tr>	
</table>	

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("id",id).replaceAll(" id=\"id\"","")%>
<%=fb.hidden("fp",fp).replaceAll(" id=\"fp\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("id",id).replaceAll(" id=\"id\"","")%>
<%=fb.hidden("fp",fp).replaceAll(" id=\"fp\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>	
		
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%">Fecha</td>
			<td width="15%">C&oacute;digo</td>
			<td width="45%">Descripciòn</td>
			<td width="10%">Cantidad</td>
			<td width="10%">Costo</td>
			<td width="10%">Total</td>
		</tr>
<%
String nameArticulo = "",type ="";
int tQty = 0;
double tCost = 0.00;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	if (!nameArticulo.equalsIgnoreCase("["+cdo.getColValue("descArticulo")+"] "))
	{
%>
		<tr class="TextHeader01">
			<td colspan="7">[<%=cdo.getColValue("descArticulo")%>]</td>
		</tr>
<%
	}

	if (!type.equalsIgnoreCase("["+cdo.getColValue("type")+"] "))
	{
%>
		<tr class="TextHeader02">
			<td colspan="7">[<%=cdo.getColValue("descType")%>]</td>
		</tr>
<%
	}
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td align="center"><%=cdo.getColValue("cantidad")%></td>
			<td align="right"><%=cdo.getColValue("costo")%></td>
			<td align="right">
<%
	if (fp.trim().equals("E") && cdo.getColValue("type").trim().equals("C"))
	{
				tCost += Double.parseDouble(cdo.getColValue("costo"));
%>
				<%= cdo.getColValue("costo")%>
				
<%
	}
	else if (fp.trim().equals("E") && cdo.getColValue("type").trim().equals("A"))
	{
				tCost += Double.parseDouble(cdo.getColValue("total"));
%>
				<%=CmnMgr.getFormattedDecimal(cdo.getColValue("total"))%>
				
<%
	}
	else
	{
	
				tCost += Double.parseDouble(cdo.getColValue("total"));
%>
				<%=cdo.getColValue("total")%>
				
<%
	}
%>
			</td>
		</tr>
<%
	tQty += Integer.parseInt(cdo.getColValue("cantidad"));
		nameArticulo = "["+cdo.getColValue("descArticulo")+"] ";
	type = "["+cdo.getColValue("type")+"] ";
}
%>
		<tr class="TextHeader02">
			<td align="right" colspan="3">Total</td>
			<td align="center"><%=tQty%></td>
			<td align="right">&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(tCost)%></td>
		</tr>
		</table>	

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>	

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("id",id).replaceAll(" id=\"id\"","")%>
<%=fb.hidden("fp",fp).replaceAll(" id=\"fp\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("id",id).replaceAll(" id=\"id\"","")%>
<%=fb.hidden("fp",fp).replaceAll(" id=\"fp\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
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
