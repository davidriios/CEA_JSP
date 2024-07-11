
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Item"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.XMLCreator"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.io.*"%>

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
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String wh = request.getParameter("wh");
String estado = request.getParameter("estado");
String consignacion = request.getParameter("consignacion");
String venta = request.getParameter("venta");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String fechafin = request.getParameter("fechafin");
String fechaini = request.getParameter("fechaini");
String existencia = request.getParameter("existencia");
String cantidad = request.getParameter("cantidad");

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";

if (wh == null) wh = "";
if (!wh.trim().equals("")) appendFilter += " and d.codigo_almacen="+wh;
if (estado == null) estado = "";
if (!estado.trim().equals("")) appendFilter += " and upper(a.estado)='"+estado+"'";
if (consignacion == null) consignacion = "";
if (!consignacion.trim().equals("")) appendFilter += " and upper(a.consignacion_sino)='"+consignacion+"'";
if (venta == null) venta = "";
if (!venta.trim().equals("")) appendFilter += " and upper(a.venta_sino)='"+venta+"'";
if (existencia == null) existencia = "";
if (cantidad == null) cantidad = "";
if (!existencia.trim().equals("") && !cantidad.trim().equals("")){
if (existencia.trim().equals("MN")) appendFilter += "  and d.disponible < "+cantidad;
else if (existencia.trim().equals("M")) appendFilter += "  and d.disponible > "+cantidad;
else appendFilter += "  and d.disponible = "+cantidad;
}

if (familyCode == null)
{
	familyCode = "";
	classCode = "";
}
if (!familyCode.trim().equals(""))
{
	appendFilter += " and a.cod_flia="+familyCode;

	if (classCode == null) classCode = "";
	if (!classCode.equals("")) appendFilter += " and a.cod_clase="+classCode;
}

		sql = "select i.art_familia value_col, i.art_familia||' - '||a.nombre as label_col, i.art_familia as title_col, i.compania||'-'||i.codigo_almacen as key_col from (select distinct compania, ar.cod_flia as art_familia, codigo_almacen from tbl_inv_inventario x,tbl_inv_articulo ar where i.compania="+(String) session.getAttribute("_companyId")+" and i.cod_articulo=ar.cod_articulo) i, tbl_inv_familia_articulo a where i.compania=a.compania(+) and i.art_familia=a.cod_flia(+) order by i.compania, i.codigo_almacen, a.nombre";
		XMLCreator xc = new XMLCreator(ConMgr);
		 xc.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"familyCode.xml",sql);


if(request.getMethod().equalsIgnoreCase("GET"))
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

	String codigo  = "";              // variables para mantener el valor de los campos filtrados en la consulta
	String descrip = "";

  if (request.getParameter("code") != null)
  {
    appendFilter += " and upper(a.cod_articulo) like '%"+request.getParameter("code").toUpperCase()+"%'";
    searchOn = "a.cod_articulo";
    searchVal = request.getParameter("code");
    searchType = "1";
    searchDisp = "Código";
		codigo = request.getParameter("code");            // utilizada para mantener el Código del Artículo
  }
  else if (request.getParameter("name") != null)
  {
    appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";
    searchOn = "a.descripcion";
    searchVal = request.getParameter("name");
    searchType = "1";
    searchDisp = "Nombre";
		descrip = request.getParameter("name");          // utilizada para mantener la Descripción del Artículo
  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
		if (searchType.equals("1"))
		{
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

	if (!appendFilter.trim().equals(""))
	{

		sql = "select   nvl(cf.fecha_corrida,' ')fecha_corrida , a.compania as companycode, a.cod_flia as familycode,a.cod_clase as classcode, a.cod_articulo as itemcode,a.descripcion as description, ( select b.nombre from tbl_inv_familia_articulo b where b.compania = a.compania and b.cod_flia =a.cod_flia ) as familyname,( select c.descripcion from tbl_inv_clase_articulo c where c.compania = a.compania and c.cod_flia = a.cod_flia and c.cod_clase = a.cod_clase ) as classname,nvl (a.consignacion_sino, 'N') as isappropiation,nvl (a.venta_sino, 'N') as issaleitem, nvl (estado, ' ') as status, d.codigo_almacen, nvl (d.disponible, 0) as disponible,nvl (e.cantidad, 0) as entradas, nvl (f.cantidad, 0) as dev,nvl (g.cantidad, 0) as devpac, nvl (h.cantidad1, 0) as ajuste1, nvl (h.cantidad2, 0) as ajuste2, nvl (i.cantidad, 0) as entalmacen, nvl (j.cantidad1, 0) as entotros, nvl (k.cantidad, 0) as devdep, nvl (l.cantidad, 0) as devund, nvl (m.cantidad, 0) as transf, nvl (n.cantidad, 0) as devolpac, nvl (o.cantidad, 0) as devprov, nvl (j.cantidad2, 0) as devotros, (  nvl (f.cantidad, 0) + nvl (g.cantidad, 0)+ nvl (e.cantidad, 0)+ nvl (i.cantidad, 0)+ nvl (j.cantidad1, 0)) as inqty,(  nvl (j.cantidad2, 0)+ nvl (o.cantidad, 0)+ nvl (n.cantidad, 0)+ nvl (m.cantidad, 0)+ nvl (k.cantidad, 0)+ nvl (l.cantidad, 0)) as outqty,(nvl (h.cantidad1, 0) + nvl (h.cantidad2, 0)) as adjqty,(  nvl (f.cantidad, 0)+ nvl (g.cantidad, 0)+ nvl (e.cantidad, 0)+ nvl (i.cantidad, 0)+ nvl (j.cantidad1, 0)- (  nvl (j.cantidad2, 0)+ nvl (o.cantidad, 0)+ nvl (n.cantidad, 0)+ nvl (m.cantidad, 0)+ nvl (k.cantidad, 0)+ nvl (l.cantidad, 0))+ (nvl (h.cantidad1, 0) + nvl (h.cantidad2, 0))) as totalqty from tbl_inv_articulo a, tbl_inv_familia_articulo b,tbl_inv_clase_articulo c,tbl_inv_inventario d,(select distinct cf.compania,  df.cod_familia ,df.cod_clase,df.cod_articulo ,cf.almacen,     to_char(cf.fecha_corrida,'dd/mm/yyyy hh:mi:ss am ') fecha_corrida from tbl_inv_detalle_fisico df,tbl_inv_conteo_fisico cf where (df.almacen = cf.almacen and  df.cf1_consecutivo = cf.consecutivo and  df.cf1_anio = cf.anio) and  cf.estatus = 'A'  and  cf.asiento_sino = 'S' )cf, (select   y.compania, y.codigo_almacen, z.cod_familia, z.cod_clase, z.cod_articulo,sum (nvl (z.cantidad, 0) * nvl (z.articulo_und, 0) ) as cantidad from tbl_inv_detalle_recepcion z, tbl_inv_recepcion_material y where z.compania = y.compania and z.anio_recepcion = y.anio_recepcion and z.numero_documento = y.numero_documento and y.estado = 'R' and to_date(to_char(y.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(y.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(y.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania, y.codigo_almacen,z.cod_familia,z.cod_clase,z.cod_articulo) e, (select   y.compania_dev compania, y.codigo_almacen, z.cod_familia, z.cod_clase, z.cod_articulo,sum (nvl (z.cantidad, 0)) as cantidad from tbl_inv_detalle_devolucion z,tbl_inv_devolucion y,tbl_sec_unidad_ejec u,tbl_sec_compania co where z.compania = y.compania and z.anio_devolucion = y.anio_devolucion and z.num_devolucion = y.num_devolucion and co.codigo = u.compania and u.codigo = y.unidad_administrativa and u.compania = y.compania and to_date(to_char(y.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(y.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(y.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania_dev,y.codigo_almacen,z.cod_familia,z.cod_clase,z.cod_articulo) f, (select   y.compania, y.codigo_almacen, z.cod_familia, z.cod_clase, z.cod_articulo, sum (nvl (z.cantidad, 0)) as cantidad from tbl_inv_detalle_paciente z, tbl_inv_devolucion_pac y where z.compania = y.compania and z.anio_devolucion = y.anio and z.num_devolucion = y.num_devolucion and y.estado = 'R' and to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania,y.codigo_almacen,z.cod_familia,z.cod_clase,z.cod_articulo) g, (select   y.compania, y.codigo_almacen, z.cod_familia, z.cod_clase, z.cod_articulo,sum (case   when y.codigo_ajuste = 4 and y.estado = 'A' then nvl (z.cantidad_ajuste, 0) else 0 end ) as cantidad1, sum (case     when y.codigo_ajuste != 4 and z.check_aprov = 'S'        then nvl (z.cantidad_ajuste, 0)     else 0  end ) as cantidad2 from tbl_inv_detalle_ajustes z, tbl_inv_ajustes y where z.compania = y.compania and z.codigo_ajuste = y.codigo_ajuste and z.numero_ajuste = y.numero_ajuste and z.anio_ajuste = y.anio_ajuste and to_date(to_char(y.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(y.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(y.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania,y.codigo_almacen,z.cod_familia,z.cod_clase,z.cod_articulo) h, (select   y.compania, x.codigo_almacen, y.cod_familia, y.cod_clase, y.cod_articulo, sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_entrega_material z, tbl_inv_detalle_entrega y,tbl_inv_solicitud_req x where x.tipo_transferencia = 'A' and (    z.compania = y.compania and z.no_entrega = y.no_entrega and z.anio = y.anio )and (    z.compania_sol = x.compania and z.req_solicitud_no = x.solicitud_no and z.req_tipo_solicitud = x.tipo_solicitud and z.req_anio = x.anio ) /*and z.codigo_almacen = x.codigo_almacen_ent*/  and to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania, x.codigo_almacen,y.cod_familia,y.cod_clase,y.cod_articulo) i, (select   y.compania, z.inv_almacen, z.inv_art_familia, z.inv_art_clase, z.inv_cod_articulo,sum (decode (y.tipo_transaccion,           'D', nvl (z.cantidad, 0), 0 )) as cantidad1,sum (decode (y.tipo_transaccion,            'C', nvl (z.cantidad, 0), 0 )) as cantidad2 from tbl_fac_detc_cliente z, tbl_fac_cargo_cliente y where z.compania = y.compania and z.anio = y.anio and z.tipo_transaccion = y.tipo_transaccion and z.cargo = y.codigo and z.inv_art_familia is not null and z.inv_art_clase is not null and z.inv_cod_articulo is not null and z.inv_almacen is not null   and to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania, z.inv_almacen,z.inv_art_familia,z.inv_art_clase,z.inv_cod_articulo) j /*dev otros*/,(select   z.compania, z.codigo_almacen_q_dev, y.cod_familia, y.cod_clase, y.cod_articulo,sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_devolucion z, tbl_inv_detalle_devolucion y where z.compania = y.compania and z.num_devolucion = y.num_devolucion and z.anio_devolucion = y.anio_devolucion  and to_date(to_char(z.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) group by z.compania,z.codigo_almacen_q_dev,y.cod_familia,y.cod_clase,y.cod_articulo) k /*salida por devolucion de mat. de deposito*/,(select   z.compania, z.codigo_almacen, y.cod_familia, y.cod_clase,y.cod_articulo, sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_entrega_material z, tbl_inv_detalle_entrega y, tbl_inv_solicitud_req x where x.tipo_transferencia in ('U', 'C') and (    z.compania = y.compania and z.no_entrega = y.no_entrega and z.anio = y.anio ) and (    z.compania_sol = x.compania and z.req_solicitud_no = x.solicitud_no and z.req_tipo_solicitud = x.tipo_solicitud and z.req_anio = x.anio ) and to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) group by z.compania,z.codigo_almacen,y.cod_familia,y.cod_clase, y.cod_articulo) l /* unidades administrativas y cia*/, (select   z.compania, x.codigo_almacen_ent, y.cod_familia,y.cod_clase, y.cod_articulo,sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_entrega_material z, tbl_inv_detalle_entrega y,tbl_inv_solicitud_req x where (    z.compania = y.compania and z.no_entrega = y.no_entrega and z.anio = y.anio ) and (    z.compania_sol = x.compania and z.req_solicitud_no = x.solicitud_no  and z.req_tipo_solicitud = x.tipo_solicitud and z.req_anio = x.anio )  and to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) group by z.compania,x.codigo_almacen_ent,y.cod_familia, y.cod_clase,y.cod_articulo) m /* transferencia entre almacenes*/, (select   z.compania, z.codigo_almacen, y.cod_familia, y.cod_clase,y.cod_articulo, sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_entrega_material z,tbl_inv_detalle_entrega y,tbl_inv_solicitud_pac x where (    z.compania = y.compania and z.no_entrega = y.no_entrega and z.anio = y.anio ) and (    z.compania = x.compania and z.pac_solicitud_no = x.solicitud_no and z.pac_anio = x.anio ) and to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) group by z.compania,z.codigo_almacen,y.cod_familia,y.cod_clase, y.cod_articulo) n /*entrega a paciente */, (select   z.compania, z.codigo_almacen, y.cod_familia, y.cod_clase, y.cod_articulo, sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_devolucion_prov z, tbl_inv_detalle_proveedor y where z.anulado_sino = 'N' and (    y.compania = z.compania  and y.num_devolucion = z.num_devolucion and y.anio = z.anio)  and to_date(to_char(z.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) group by z.compania, z.codigo_almacen,y.cod_familia,y.cod_clase,y.cod_articulo) o             /* dev a proveedor*/ where d.cod_articulo = a.cod_articulo  and d.compania = a.compania  and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and d.compania = e.compania(+) and d.codigo_almacen = e.codigo_almacen(+) and d.cod_articulo = e.cod_articulo(+) and d.compania = f.compania(+) and d.codigo_almacen = f.codigo_almacen(+) and d.cod_articulo = f.cod_articulo(+) and d.compania = g.compania(+) and d.codigo_almacen = g.codigo_almacen(+) and d.cod_articulo = g.cod_articulo(+) and d.compania = h.compania(+) and d.codigo_almacen = h.codigo_almacen(+) and d.cod_articulo = h.cod_articulo(+) and d.compania = i.compania(+) and d.codigo_almacen = i.codigo_almacen(+) and d.cod_articulo = i.cod_articulo(+) and d.compania = j.compania(+) and d.codigo_almacen = j.inv_almacen(+) and d.cod_articulo = j.inv_cod_articulo(+) and d.compania = k.compania(+) and d.codigo_almacen = k.codigo_almacen_q_dev(+) and d.cod_articulo = k.cod_articulo(+) and d.compania = l.compania(+) and d.codigo_almacen = l.codigo_almacen(+) and d.cod_articulo = l.cod_articulo(+) and d.compania = m.compania(+) and d.codigo_almacen = m.codigo_almacen_ent(+) and d.cod_articulo = m.cod_articulo(+) and d.compania = n.compania(+) and d.codigo_almacen = n.codigo_almacen(+) and d.cod_articulo = n.cod_articulo(+) and d.compania = o.compania(+) and d.codigo_almacen = o.codigo_almacen(+) and d.cod_articulo = o.cod_articulo(+) and d.compania = cf.compania(+) and d.codigo_almacen = cf.almacen(+) and d.cod_articulo = cf.cod_articulo(+)  order by d.art_familia, d.art_clase, d.cod_articulo    ";


		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);


		rowCount = CmnMgr.getCount("select count(*) from ("+sql+")  ");


	}

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
document.title = 'Inventario - Articulos - '+document.title;
function ver(familyCode, classCode, id, fp)
{
	abrir_ventana('../inventario/list_detalle_mov.jsp?mode=edit&id='+id+'&familyCode='+familyCode+'&classCode='+classCode+'&wh=<%=wh%>&fp='+fp+'&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>');
}
function printList()
{
	<%if(!appendFilter.trim().equals("")){%>
	abrir_ventana('printl_list_hist_mov.jsp?fechaini=<%=fechaini%>&fechafin=<%=fechafin%>&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
	<%}else{%>
			alert('Seleccione filtros de busqueda antes de Imprimir');
	<%}%>
}
function reporte(fecha, familyCode, classCode, id)
{
	abrir_ventana('../inventario/print_historia_mov_articulo.jsp?mode=edit&id='+id+'&fecha_corrida='+fecha+'&familyCode='+familyCode+'&classCode='+classCode+'&wh=<%=wh%>&tDate=<%=fechafin%>&fDate=<%=fechaini%>');
}
function getMain(formX)
{
	formX.wh.value = document.search00.wh.value;
	formX.estado.value = document.search00.estado.value;
	formX.consignacion.value = document.search00.consignacion.value;
	formX.venta.value = document.search00.venta.value;
	formX.familyCode.value = document.search00.familyCode.value;
	formX.classCode.value = document.search00.classCode.value;
	formX.existencia.value = document.search00.existencia.value;
	formX.cantidad.value = document.search00.cantidad.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
<tr>
	<td colspan="3" align="right">&nbsp;</td>
</tr>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
	<td colspan="3">
		Almac&eacute;n
		<%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen","wh",wh,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/familyCode.xml','familyCode','"+familyCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T');loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+document.search00.familyCode.value,'KEY_COL','T')\"")%>
		Estado
		<%=fb.select("estado","A=ACTIVO,I=INACTIVO",estado,false,false,0,"Text10",null,null,null,"T")%>
		Consignaci&oacute;n
		<%=fb.select("consignacion","S=SI,N=NO",consignacion,false,false,0,"Text10",null,null,null,"T")%>
		Venta
		<%=fb.select("venta","S=SI,N=NO",venta,false,false,0,"Text10",null,null,null,"T")%>
		Existencia
		<%=fb.select("existencia","MN=MENOR, M=MAYOR, I=IGUAL",existencia,false,false,0,"Text10",null,null,null,"T")%>
		Cantidad
		<%=fb.textBox("cantidad",cantidad,false,false,false,8,"Text10",null,null)%>
	</td>
</tr>
<tr class="TextFilter">
	<td colspan="3">
		Familia
		<%=fb.select("familyCode","","",false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/itemClass.xml','classCode','"+classCode+"','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">loadXML('../xml/familyCode.xml','familyCode','<%=familyCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(wh != null && !wh.equals(""))?wh:"document.search00.wh.value"%>,'KEY_COL','T');</script>
		Clase
		<%=fb.select("classCode","","",false,false,0,"Text10",null,null)%>
		<script language="javascript">loadXML('../xml/itemClass.xml','classCode','<%=classCode%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familyCode") != null && !request.getParameter("familyCode").equals(""))?familyCode:"document.search00.familyCode.value"%>,'KEY_COL','T');</script>
		<%=fb.submit("go","Ir")%>
	</td>
<%=fb.formEnd()%>
</tr>

<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET,"onSubmit=\"javascript:return(getMain(this))\"");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("wh","").replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("estado","").replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion","").replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta","").replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("familyCode","").replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode","").replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("existencia","").replaceAll(" id=\"existencia\"","")%>
<%=fb.hidden("cantidad","").replaceAll(" id=\"cantidad\"","")%>

	<td width="25%">
		C&oacute;digo
		<%=fb.textBox("code","",false,false,false,20,"Text10",null,null)%>
		<%=fb.submit("go","Ir")%>
	</td>
<%=fb.formEnd()%>

<%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET,"onSubmit=\"javascript:return(getMain(this))\"");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("wh","").replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("estado","").replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion","").replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta","").replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("familyCode","").replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode","").replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("existencia","").replaceAll(" id=\"existencia\"","")%>
<%=fb.hidden("cantidad","").replaceAll(" id=\"cantidad\"","")%>

	<td width="40%">
		Nombre
		<%=fb.textBox("name","",false,false,false,50,"Text10",null,null)%>
		<%=fb.submit("go","Ir")%>
	</td>
<%=fb.formEnd()%>

<%fb = new FormBean("search04",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET,"onSubmit=\"javascript:return(getMain(this))\"");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("wh","").replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("estado","").replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion","").replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta","").replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("familyCode","").replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode","").replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("existencia","").replaceAll(" id=\"existencia\"","")%>
<%=fb.hidden("cantidad","").replaceAll(" id=\"cantidad\"","")%>

	<td width="35%">
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="fieldClass" value="Text10" />
		<jsp:param name="noOfDateTBox" value="2" />
		<jsp:param name="clearOption" value="true" />
		<jsp:param name="nameOfTBox1" value="fechaini" />
		<jsp:param name="valueOfTBox1" value="" />
		<jsp:param name="nameOfTBox2" value="fechafin" />
		<jsp:param name="valueOfTBox2" value="" />
		</jsp:include>
		<%=fb.submit("go","Ir")%>
	</td>
<%=fb.formEnd()%>
</tr>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<tr>
	<td align="right">&nbsp;
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200026"))
//{
%>
		<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>
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
<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("existencia","").replaceAll(" id=\"existencia\"","")%>
<%=fb.hidden("cantidad","").replaceAll(" id=\"cantidad\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("existencia","").replaceAll(" id=\"existencia\"","")%>
<%=fb.hidden("cantidad","").replaceAll(" id=\"cantidad\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
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

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="5%">Familia</td>
			<td width="5%">Clase</td>
			<td width="5%">C&oacute;digo</td>
			<td width="36%">Nombre</td>
			<td width="10%">U. Inventario</td>
			<td width="7%">Disponible</td>
			<td width="7%">Entradas</td>
			<td width="7%">Salidas</td>
			<td width="7%">Ajustes</td>
			<td width="7%">Total</td>
			<td width="3%">&nbsp;</td>
		</tr>
<%
String familyClass = "";
int salidas =0,ajuste=0,entradas = 0;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	entradas = Integer.parseInt(cdo.getColValue("inQty"));
	salidas = Integer.parseInt(cdo.getColValue("outQty")) * -1;
	ajuste  = Integer.parseInt(cdo.getColValue("adjQty"));

%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("familyCode")%></td>
			<td align="center"><%=cdo.getColValue("classCode")%></td>
			<td><%=cdo.getColValue("itemCode")%></td>
			<td><%=cdo.getColValue("description")%></td>
			<td><%=cdo.getColValue("fecha_corrida")%></td>
			<td align="center"><%=cdo.getColValue("disponible")%></td>
			<td align="center">
			<%if(entradas>0){%>
				<a href="javascript:ver(<%=cdo.getColValue("familyCode")%>,<%=cdo.getColValue("classCode")%>,<%=cdo.getColValue("itemCode")%>,'E')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=entradas%></a>
			<%}else {%>
				<%=entradas%>
			<%}%>
			</td>
			<td align="center">
			<%if(salidas !=0){%>
				<a href="javascript:ver(<%=cdo.getColValue("familyCode")%>,<%=cdo.getColValue("classCode")%>,<%=cdo.getColValue("itemCode")%>,'S')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=salidas%></a>
			<%}else {%>
				<%=salidas%>
			<%}%>
			</td>
			<td align="center">
			<%if(ajuste != 0){%>
				<a href="javascript:ver(<%=cdo.getColValue("familyCode")%>,<%=cdo.getColValue("classCode")%>,<%=cdo.getColValue("itemCode")%>,'A')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=ajuste%></a>
			<%}else {%>
				<%=ajuste%>
			<%}%>
			</td>
			<td align="center"><%=cdo.getColValue("totalQty")%></td>
			<td align="center"><a href="javascript:reporte('<%=cdo.getColValue("fecha_corrida")%>',<%=cdo.getColValue("familyCode")%>,<%=cdo.getColValue("classCode")%>,<%=cdo.getColValue("itemCode")%>)" class="Link02Bold"><img src="../images/print_analysis.gif" width="18" height="18" border="0"></a></td>
		</tr>
<%
	salidas =0;
}
%>
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
<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("existencia","").replaceAll(" id=\"existencia\"","")%>
<%=fb.hidden("cantidad","").replaceAll(" id=\"cantidad\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("wh",wh).replaceAll(" id=\"wh\"","")%>
<%=fb.hidden("estado",estado).replaceAll(" id=\"estado\"","")%>
<%=fb.hidden("consignacion",consignacion).replaceAll(" id=\"consignacion\"","")%>
<%=fb.hidden("venta",venta).replaceAll(" id=\"venta\"","")%>
<%=fb.hidden("familyCode",familyCode).replaceAll(" id=\"familyCode\"","")%>
<%=fb.hidden("classCode",classCode).replaceAll(" id=\"classCode\"","")%>
<%=fb.hidden("existencia","").replaceAll(" id=\"existencia\"","")%>
<%=fb.hidden("cantidad","").replaceAll(" id=\"cantidad\"","")%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
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
