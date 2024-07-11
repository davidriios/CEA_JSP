<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
/**
==================================================================================
==================================================================================
**/
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String num = request.getParameter("num");
String tp = request.getParameter("tp");
String fp = request.getParameter("fp");

if (anio == null) anio = "";
if (num == null) num = "";
if (tp == null) tp = "";
if (fp == null) fp = "";
if (anio.trim().equals("") || num.trim().equals("") || tp.trim().equals("")) throw new Exception("La Orden de Compra es inválida!");

sbSql = new StringBuffer();
if (fp.equals("")){
sbSql.append("select a.anio, a.tipo_compromiso, a.num_doc, a.anio||'-'||a.num_doc as ordenNum, a.compania, a.lugar_entrega as entrega, to_char(a.fecha_documento,'dd/mm/yyyy') as fecha_documento, a.status, to_char(a.monto_total,'999,999,999,990.00') as monto_total, a.numero_factura, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence, nvl(to_char(a.monto_pagado),'0.00') as monto_pago, a.tiempo_entrega as tiempo, to_char(a.sub_total,'9,999,999,990.00') as sub_total, to_char(a.descuento,'9,999,999,990.00') as descuento, to_char(a.itbm,'9,999,990.00') as itbm, to_char(a.sub_total - nvl(a.descuento,0),'9,999,999,990.00') as sub_desc, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE') as desc_status, to_char(a.monto_total - nvl(a.monto_pagado,0),'999,999,990.00') as saldo, a.cod_proveedor, 'COMENTARIOS:'||chr(13)||a.explicacion as explicacion, a.usuario, to_char(a.fecha_entrega,'dd/mm/yyyy') as fecha_entrega, a.requi_anio, a.requi_numero, decode(a.tipo_pago,1,'CONTADO',decode(a.dia_limite,0,'CONTADO',1,'15 DIAS',2,'30 DIAS',3,'45 DIAS',4,'60 DIAS',5,'90 DIAS',6, '120 DIAS')) as dias_limite_desc, 'ADMINISTRADOR' as usuario_mod");
sbSql.append(", nvl(get_sec_comp_param(a.compania,'COM_OC_FOOTER'),' ') as observaciones");
//sbSql.append(", nvl((select descripcion from tbl_com_tipo_compromiso where tipo_com = a.tipo_compromiso),' ') as tipoOrden");
sbSql.append(", nvl((select nombre_proveedor from tbl_com_proveedor where cod_provedor = a.cod_proveedor and compania = a.compania),' ') as nombre_proveedor");
sbSql.append(", nvl((select ruc||' D.V. '||digito_verificador from tbl_com_proveedor where cod_provedor = a.cod_proveedor and compania = a.compania),' ') as ruc");
sbSql.append(", nvl((select direccion from tbl_com_proveedor where cod_provedor = a.cod_proveedor and compania = a.compania),' ') as direccion");
sbSql.append(", nvl((select decode(telefono||fax,null,' ',nvl(telefono,'-')||' / '||nvl(fax,'-')) from tbl_com_proveedor where cod_provedor = a.cod_proveedor and compania = a.compania),' ') as telefono_fax");
sbSql.append(", nvl((select email from tbl_com_proveedor where cod_provedor = a.cod_proveedor and compania = a.compania),' ') as email");
//sbSql.append(", nvl((select descripcion from tbl_inv_almacen where codigo_almacen = a.cod_almacen and compania = a.compania),' ') as almacen_desc");
sbSql.append(", nvl(get_sec_comp_param(a.compania,'COM_OC_ADD_BARCODE'),'N') as add_barcode, a.cod_almacen, nvl(a.usuario_aprob,' ') usuario_aprob ");
sbSql.append(" from tbl_com_comp_formales a");
sbSql.append(" where a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.anio = ");
sbSql.append(anio);
sbSql.append(" and a.num_doc = ");
sbSql.append(num);
sbSql.append(" and a.tipo_compromiso = ");
sbSql.append(tp);
}else if(fp.equals("cambio_precio")){

  sbSql.append("select ff.no_sol, ff.prov_data, ff.dias_limite_desc, ff.fecha_documento, ff.usuario, sum(ff.monto) as sub_total, sum(ff.descuento) as descuento , sum(ff.itbms) as itbm,  sum(ff.monto) - sum(ff.descuento) as sub_desc, sum(ff.monto)-sum(ff.descuento)+sum(ff.itbms) as monto_total,  ff.status, nvl(get_sec_comp_param(ff.compania,'COM_OC_FOOTER'),' ') as observaciones, ff.explicacion, ff.tipoDescuento, ff.porcentaje, ff.usuario_aprob from(");
		sbSql.append("select aa.* ,getnewsaleprice(aa.compania,aa.cod_proveedor, aa.cod_almacen,aa.codarticulo,aa.codflia, aa.codclase,aa.last_purch_price,aa.monto,aa.sale_price) as new_sale_price from(");
			sbSql.append("select 'COMENTARIOS:'||chr(13)||e.explicacion as explicacion, e.cod_proveedor, e.cod_almacen, a.compania, a.cod_familia as codFlia, a.cod_clase as codClase, a.subclase_id as subclaseId, a.cod_articulo as codArticulo, a.cantidad, a.monto_articulo as monto, nvl(a.estado_renglon,' ') as estadoRenglon,nvl(a.especificacion,' ') as especificacion, a.cant_por_empaque as cantPorEmpaque, a.unidad_empaque as unidadEmpaque, (a.cantidad / a.cant_por_empaque) as cantidad_Empaque, (nvl(a.cant_promo,0) / a.cant_por_empaque) as cantPromoEmp, nvl(a.descuento,0) as descuento, (select itbm from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as itbm, (select cod_medida from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as unidad, (select descripcion from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as articulo, a.impuesto , /*getlastprecioprov(a.compania,e.cod_proveedor, e.cod_almacen, a.cod_articulo)*/ getlastprecio (a.compania, e.cod_almacen, a.cod_articulo) as last_purch_price, (select precio_venta from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania =a.compania) as sale_price, a.cantidad * a.monto_articulo * (a.cantidad / a.cant_por_empaque) as new_sale_price_box, get_incsaleprice(a.compania,a.cod_familia, a.cod_clase,a.cod_articulo) as perc_inc_sale_price, (select count(*) from  tbl_com_cambio_precio_hist h where a.compania = h.compania and a.cf_tipo_com = h.tipo_comp and a.cf_num_doc = h.num_doc and a.cf_anio = h.cf_anio and a.cod_articulo = h.cod_articulo and a.cod_clase = h.cod_clase and a.cod_familia = h.cod_flia) as action, e.itbm  as itbms, e.requi_anio||'-'||e.requi_numero as no_sol, nvl(e.porcentaje,0) as porcentaje, nvl(e.tipo_descuento,'P') as tipoDescuento, (select p.nombre_proveedor||'@@'||p.direccion||'@@'||decode(p.telefono||p.fax,null,' ',nvl(p.telefono,'-')||' / '||nvl(p.fax,'-'))||'@@'||p.email||'@@'||p.ruc||' D.V. '||p.digito_verificador from tbl_com_proveedor p where p.cod_provedor = e.cod_proveedor and p.compania = e.compania ) as prov_data,decode(e.tipo_pago,1,'CONTADO',decode(e.dia_limite,0,'CONTADO',1,'15 DIAS',2,'30 DIAS',3,'45 DIAS',4,'60 DIAS',5,'90 DIAS',6, '120 DIAS')) as dias_limite_desc, to_char(e.fecha_documento,'dd/mm/yyyy') as fecha_documento, e.usuario , e.status, nvl(e.usuario_aprob,' ') usuario_aprob from tbl_com_detalle_compromiso a, tbl_com_comp_formales e where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));

			sbSql.append(" and a.cf_anio = ");
			sbSql.append(anio);
			sbSql.append(" and a.cf_num_doc = ");
			sbSql.append(num);
			sbSql.append(" and a.compania = e.compania and a.cf_tipo_com = e.tipo_compromiso and a.cf_num_doc = e.num_doc and a.cf_anio = e.anio and a.monto_articulo <> getlastprecio (a.compania, e.cod_almacen, a.cod_articulo) /*and get_incsaleprice(a.compania,a.cod_familia, a.cod_clase,a.cod_articulo)>0*/  order by a.cod_familia, a.cod_clase, a.subclase_id, a.cod_articulo");
		sbSql.append(")aa");
	sbSql.append(")ff group by ff.no_sol, ff.prov_data, ff.dias_limite_desc, ff.fecha_documento, ff.usuario, ff.status, nvl(get_sec_comp_param(ff.compania,'COM_OC_FOOTER'),' '), ff.explicacion, ff.tipoDescuento,ff.porcentaje, ff.usuario_aprob");
}else if(fp.equals("cambio_precio_all")){

  sbSql.append("select ff.no_sol, ff.prov_data, ff.dias_limite_desc, ff.fecha_documento, ff.usuario, sum(ff.monto) as sub_total, decode(sum(ff.descuento),0,ff.descuentoH,sum(ff.descuento)) as descuento , sum(ff.itbms) as itbm,  sum(ff.monto) - sum(ff.descuento) as sub_desc, sum(ff.monto)-sum(ff.descuento)+sum(ff.itbms) as monto_total,  ff.status, nvl(get_sec_comp_param(ff.compania,'COM_OC_FOOTER'),' ') as observaciones, ff.explicacion, ff.tipoDescuento, ff.porcentaje,ff.usuario_aprob from(");
		sbSql.append("select aa.* ,getnewsaleprice(aa.compania,aa.cod_proveedor, aa.cod_almacen,aa.codarticulo,aa.codflia, aa.codclase,aa.last_purch_price,aa.monto,aa.sale_price) as new_sale_price from(");
			sbSql.append(" select 'COMENTARIOS:'||chr(13)||e.explicacion as explicacion, e.cod_proveedor, e.cod_almacen, a.compania, a.cod_familia as codFlia, a.cod_clase as codClase, a.subclase_id as subclaseId, a.cod_articulo as codArticulo, a.cantidad, a.monto_articulo as monto, nvl(a.estado_renglon,' ') as estadoRenglon,nvl(a.especificacion,' ') as especificacion, a.cant_por_empaque as cantPorEmpaque, a.unidad_empaque as unidadEmpaque, (a.cantidad / a.cant_por_empaque) as cantidad_Empaque, (nvl(a.cant_promo,0) / a.cant_por_empaque) as cantPromoEmp, nvl(a.descuento,0) as descuento, (select itbm from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as itbm, (select cod_medida from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as unidad, (select descripcion from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as articulo, a.impuesto , /*getlastprecioprov(a.compania,e.cod_proveedor, e.cod_almacen, a.cod_articulo)*/ getlastprecio (a.compania, e.cod_almacen, a.cod_articulo) as last_purch_price, (select precio_venta from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania =a.compania) as sale_price, a.cantidad * a.monto_articulo * (a.cantidad / a.cant_por_empaque) as new_sale_price_box, get_incsaleprice(a.compania,a.cod_familia, a.cod_clase,a.cod_articulo) as perc_inc_sale_price, (select count(*) from  tbl_com_cambio_precio_hist h where a.compania = h.compania and a.cf_tipo_com = h.tipo_comp and a.cf_num_doc = h.num_doc and a.cf_anio = h.cf_anio and a.cod_articulo = h.cod_articulo and a.cod_clase = h.cod_clase and a.cod_familia = h.cod_flia) as action, e.itbm  as itbms, e.requi_anio||'-'||e.requi_numero as no_sol, nvl(e.porcentaje,0) as porcentaje, nvl(e.descuento,0) as descuentoH, nvl(e.tipo_descuento,'P') as tipoDescuento, (select p.nombre_proveedor||'@@'||p.direccion||'@@'||decode(p.telefono||p.fax,null,' ',nvl(p.telefono,'-')||' / '||nvl(p.fax,'-'))||'@@'||p.email||'@@'||p.ruc||' D.V. '||p.digito_verificador from tbl_com_proveedor p where p.cod_provedor = e.cod_proveedor and p.compania = e.compania ) as prov_data,decode(e.tipo_pago,1,'CONTADO',decode(e.dia_limite,0,'CONTADO',1,'15 DIAS',2,'30 DIAS',3,'45 DIAS',4,'60 DIAS',5,'90 DIAS',6, '120 DIAS')) as dias_limite_desc, to_char(e.fecha_documento,'dd/mm/yyyy') as fecha_documento, e.usuario , e.status, nvl(e.usuario_aprob,' ') usuario_aprob from tbl_com_detalle_compromiso a, tbl_com_comp_formales e where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));

			sbSql.append(" and a.cf_anio = ");
			sbSql.append(anio);
			sbSql.append(" and a.cf_num_doc = ");
			sbSql.append(num);
			sbSql.append(" and a.compania = e.compania and a.cf_tipo_com = e.tipo_compromiso and a.cf_num_doc = e.num_doc and a.cf_anio = e.anio /*and a.monto_articulo <> getlastprecio (a.compania, e.cod_almacen, a.cod_articulo) and get_incsaleprice(a.compania,a.cod_familia, a.cod_clase,a.cod_articulo)>0*/  order by a.cod_familia, a.cod_clase, a.subclase_id, a.cod_articulo");
		sbSql.append(")aa");
	sbSql.append(")ff group by ff.no_sol, ff.prov_data, ff.dias_limite_desc, ff.fecha_documento, ff.usuario, ff.status, nvl(get_sec_comp_param(ff.compania,'COM_OC_FOOTER'),' '), ff.explicacion, ff.tipoDescuento,ff.porcentaje,ff.descuentoH, ff.usuario_aprob");

}

cdo = SQLMgr.getData(sbSql.toString());
if(cdo == null) cdo = new CommonDataObject();

sbSql = new StringBuffer();
if (fp.equals("")){
sbSql.append("select a.compania, a.cod_familia as codFlia, a.cod_clase as codClase, a.subclase_id as subclaseId, a.cod_articulo as codArticulo, a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo as codigoart, a.cantidad, nvl(a.cant_promo,0) as cantPromo, a.monto_articulo as montoArticulo, nvl(a.estado_renglon,' ') as estadoRenglon, nvl(a.especificacion,' ') as especificacion, a.cant_por_empaque as cantPorEmpaque, a.unidad_empaque, (a.cantidad / a.cant_por_empaque) as cantidad_empaque, (nvl(a.cant_promo,0) / a.cant_por_empaque) as cantPromoEmp, nvl(a.descuento,0) as descuento, nvl(a.tipo_descuento,'P') as tipo_descuento, (a.monto_articulo - round(decode(nvl(a.tipo_descuento,'P'),'P',a.monto_articulo * (nvl(a.descuento,0) / 100),'M',nvl(a.descuento,0)),6)) * a.cantidad as total");
sbSql.append(", (select itbm from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as itbm");
sbSql.append(", (select cod_medida from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as medida");
sbSql.append(", (select ");
if (cdo.getColValue("add_barcode") != null && cdo.getColValue("add_barcode").equalsIgnoreCase("S")) sbSql.append("decode(cod_barra,null,'','('||cod_barra||') ')||");
sbSql.append("descripcion from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania)||decode(a.especificacion,null,'',' '||a.especificacion) as articuloDesc");
sbSql.append(", nvl((select referencia from tbl_inv_arti_prov where cod_provedor = ");
sbSql.append(cdo.getColValue("cod_proveedor"));
sbSql.append(" and cod_articulo = a.cod_articulo and estado='A' and rownum=1),' ') as catalogo_producto");

sbSql.append(" from tbl_com_detalle_compromiso a where a.cf_tipo_com = ");
sbSql.append(tp);
sbSql.append(" and a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.cf_anio = ");
sbSql.append(anio);
sbSql.append(" and a.cf_num_doc = ");
sbSql.append(num);
sbSql.append(" order by a.cod_familia, a.cod_clase, a.subclase_id, a.cod_articulo");
}else if(fp.equals("cambio_precio")){
   
   sbSql.append("select aa.* ,getnewsaleprice(aa.compania,aa.cod_proveedor, aa.cod_almacen,aa.codarticulo,aa.codflia, aa.codclase,aa.last_purch_price,aa.monto,aa.sale_price) as new_sale_price, aa.cantPorEmpaque*getnewsaleprice(aa.compania,aa.cod_proveedor, aa.cod_almacen,aa.codarticulo,aa.codflia, aa.codclase,aa.last_purch_price,aa.monto,aa.sale_price)*aa.cantidad_Empaque as new_sale_price_box  from( select e.cod_proveedor, e.cod_almacen, a.compania, a.cod_familia as codFlia, a.cod_clase as codClase, a.subclase_id as subclaseId, a.cod_articulo as codArticulo, a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo as codigoart, a.cantidad, a.monto_articulo as monto, a.monto_articulo as montoArticulo,nvl(a.estado_renglon,' ') as estadoRenglon, nvl(a.especificacion,' ') as especificacion, a.cant_por_empaque as cantPorEmpaque, a.unidad_empaque, (a.cantidad / a.cant_por_empaque) as cantidad_Empaque, nvl(a.cant_promo,0) as cantPromo, (nvl(a.cant_promo,0) / a.cant_por_empaque) as cantPromoEmp, nvl(a.descuento,0) as descuento, nvl(a.tipo_descuento,'P') as tipo_Descuento, (select itbm from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as itbm, (select cod_medida from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as medida, (select descripcion from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as articuloDesc, a.impuesto , /*getlastprecioprov(a.compania,e.cod_proveedor, e.cod_almacen, a.cod_articulo)*/ getlastprecio (a.compania, e.cod_almacen, a.cod_articulo) as last_purch_price, (select precio_venta from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as sale_price, get_incsaleprice(a.compania,a.cod_familia, a.cod_clase,a.cod_articulo) as perc_inc_sale_price, (select count(*) from  tbl_com_cambio_precio_hist h where a.compania = h.compania and a.cf_tipo_com = h.tipo_comp and a.cf_num_doc = h.num_doc and a.cf_anio = h.cf_anio and a.cod_articulo = h.cod_articulo and a.cod_clase = h.cod_clase and a.cod_familia = h.cod_flia) as action, nvl((select ap.referencia from tbl_inv_arti_prov ap where ap.cod_provedor = e.cod_proveedor and cod_articulo = a.cod_articulo and estado='A' and rownum=1),' ') as catalogo_producto, (a.monto_articulo - round(decode(nvl(a.tipo_descuento,'P'),'P',a.monto_articulo * (nvl(a.descuento,0) / 100),'M',nvl(a.descuento,0)),6)) * a.cantidad as total from tbl_com_detalle_compromiso a, tbl_com_comp_formales e where a.compania = ");
	
	sbSql.append((String)session.getAttribute("_companyId"));
	sbSql.append(" and a.cf_anio = ");
	sbSql.append(anio);
	sbSql.append(" and a.cf_num_doc = ");
	sbSql.append(num);
	sbSql.append(" and a.compania = e.compania and a.cf_tipo_com = e.tipo_compromiso and a.cf_num_doc = e.num_doc and a.cf_anio = e.anio /*and get_incsaleprice(a.compania,a.cod_familia, a.cod_clase,a.cod_articulo)>0*/ and a.monto_articulo <> getlastprecio (a.compania, e.cod_almacen, a.cod_articulo)  order by a.cod_familia, a.cod_clase, a.subclase_id, a.cod_articulo)aa"); 
	
}else if (fp.equals("cambio_precio_all")){
   sbSql.append("select aa.* ,nvl(aa.p_venta_act,aa.sale_price) as new_sale_price, aa.cantPorEmpaque*nvl(aa.p_venta_act,aa.sale_price)*aa.cantidad_Empaque as new_sale_price_box  from( select e.cod_proveedor, e.cod_almacen, a.compania, a.cod_familia as codFlia, a.cod_clase as codClase, a.subclase_id as subclaseId, a.cod_articulo as codArticulo, a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo as codigoart, a.cantidad, a.monto_articulo as monto, a.monto_articulo as montoArticulo,nvl(a.estado_renglon,' ') as estadoRenglon, nvl(a.especificacion,' ') as especificacion, a.cant_por_empaque as cantPorEmpaque, a.unidad_empaque, (a.cantidad / a.cant_por_empaque) as cantidad_Empaque, nvl(a.cant_promo,0) as cantPromo, (nvl(a.cant_promo,0) / a.cant_por_empaque) as cantPromoEmp, nvl(a.descuento,0) as descuento, nvl(a.tipo_descuento,'P') as tipo_Descuento, (select itbm from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as itbm, (select cod_medida from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as medida, (select descripcion from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania) as articuloDesc, a.impuesto , /*getlastprecioprov(a.compania,e.cod_proveedor, e.cod_almacen, a.cod_articulo)*/ /*getlastprecio (a.compania, e.cod_almacen, a.cod_articulo)*/ h.costo_ant as last_purch_price, nvl(h.p_venta_ant,(select precio_venta from tbl_inv_articulo where cod_articulo = a.cod_articulo and cod_clase = a.cod_clase and cod_familia = a.cod_familia and compania = a.compania)) as sale_price, get_incsaleprice(a.compania,a.cod_familia, a.cod_clase,a.cod_articulo) as perc_inc_sale_price, (select count(*) from  tbl_com_cambio_precio_hist h where a.compania = h.compania and a.cf_tipo_com = h.tipo_comp and a.cf_num_doc = h.num_doc and a.cf_anio = h.cf_anio and a.cod_articulo = h.cod_articulo and a.cod_clase = h.cod_clase and a.cod_familia = h.cod_flia) as action, nvl((select ap.referencia from tbl_inv_arti_prov ap where ap.cod_provedor = e.cod_proveedor and cod_articulo = a.cod_articulo and estado='A' and rownum=1),' ') as catalogo_producto, (a.monto_articulo - round(decode(nvl(a.tipo_descuento,'P'),'P',a.monto_articulo * (nvl(a.descuento,0) / 100),'M',nvl(a.descuento,0)),6)) * a.cantidad as total, h.p_venta_act from tbl_com_detalle_compromiso a, tbl_com_comp_formales e, tbl_com_cambio_precio_hist h where a.compania =");
	
	sbSql.append((String)session.getAttribute("_companyId"));
	sbSql.append(" and a.cf_anio = ");
	sbSql.append(anio);
	sbSql.append(" and a.cf_num_doc = ");
	sbSql.append(num);
	sbSql.append(" and a.compania = e.compania and a.cf_tipo_com = e.tipo_compromiso and a.cf_num_doc = e.num_doc and a.cf_anio = e.anio /*and get_incsaleprice(a.compania,a.cod_familia, a.cod_clase,a.cod_articulo)>0 and a.monto_articulo <> getlastprecio (a.compania, e.cod_almacen, a.cod_articulo)*/ and a.cf_anio = h.cf_anio(+) and  a.cf_num_doc = h.num_doc(+) and a.compania = h.compania(+) and a.cf_tipo_com = h.tipo_comp(+) and a.cod_articulo = h.cod_articulo(+)   order by a.cod_familia, a.cod_clase, a.subclase_id, a.cod_articulo)aa"); 
}

// tbl_com_comp_formales
al = SQLMgr.getDataList(sbSql.toString());

CommonDataObject cdoUA = SQLMgr.getData("select get_sec_comp_param("+(String)session.getAttribute("_companyId")+",'OC_APPROVED_BY') show_approved_by from dual");
if (cdoUA==null) cdoUA = new CommonDataObject();
String showApprovedBy = cdoUA.getColValue("show_approved_by","Y");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+System.currentTimeMillis()+"_"+UserDet.getUserId()+".pdf";

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
	String statusPath = ResourceBundle.getBundle("path").getString("images")+"/anulado.png";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float dispHeight = 0.0f;//altura disponible para el ciclo for
	float headerHeight = 0.0f;//tamaño del encabezado
	float innerHeight = 0.0f;//tamaño del detalle
	float footerHeight = 0.0f;//tamaño del footer
	float modHeight = 0.0f;//tamaño del relleno en blanco
	float antHeight = 0.0f;//
	float finHeight = 0.0f;//
	float extra = 0.0f;//
	float total = 0.0f;//
	float innerTableHeight = 0.0f;
	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = (fp.equals("cambio_precio")||fp.equals("cambio_precio_all"));
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 30.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = (cdo.getColValue("status")!=null && !cdo.getColValue("status").trim().equals("") && cdo.getColValue("status").equals("N")?true:false);
	String xtraCompanyInfo = "";
	String title = "ORDEN DE COMPRA No. "+anio+" - "+ num;
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 25.0f;
	int  j = 0;
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
	Vector dInnerHeader=new Vector();
		dInnerHeader.addElement("59");
		dInnerHeader.addElement("59");
	Vector xInnerHeader=new Vector();
		xInnerHeader.addElement("90");
		xInnerHeader.addElement("93");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, null);

	Vector setDetail=new Vector();
	  if (fp.equals("cambio_precio")||fp.equals("cambio_precio_all")){
		setDetail.addElement(".04");
		setDetail.addElement(".08");
		setDetail.addElement(".24");
		setDetail.addElement(".09");
		setDetail.addElement(".04");
		setDetail.addElement(".05");
		setDetail.addElement(".03");
		setDetail.addElement(".06");
		setDetail.addElement(".07");
		setDetail.addElement(".05");
		setDetail.addElement(".08");
		
		//
		setDetail.addElement(".08"); // precio_venta unitario
		setDetail.addElement(".08"); // precio_venta paquete
		setDetail.addElement(".02"); //
	  }else {
	    setDetail.addElement(".04");
		setDetail.addElement(".10");
		setDetail.addElement(".30");
		setDetail.addElement(".11");
		setDetail.addElement(".05");
		setDetail.addElement(".06");
		setDetail.addElement(".04");
		setDetail.addElement(".07");
		setDetail.addElement(".08");
		setDetail.addElement(".06");
		setDetail.addElement(".09");
	  }

	Vector setHeader0=new Vector();
		setHeader0.addElement(".50");
		setHeader0.addElement(".50");

	Vector setHeader1=new Vector();
		setHeader1.addElement("82");
		setHeader1.addElement("95");
		
		double cantXEmp=0.0,cantEmp=0.0,cant=0.0,costo=0.0,iDisc=0.0,iTotal=0.0,iTax=0.0, subTotal=0.0,tDisc=0.0,tTax=0.0, taxPercent = 0.0, gDisc = 0.0, subTotal1 = 0.0;
		
		String gDiscType = "", iDiscType="";
		
	if (fp.equals("cambio_precio")||fp.equals("cambio_precio_all")){
		taxPercent = (session.getAttribute("_taxPercent") != null && !session.getAttribute("_taxPercent").toString().trim().equals("")?Double.parseDouble((String)session.getAttribute("_taxPercent")):0.0);
		
		gDisc = Double.parseDouble((cdo.getColValue("porcentaje")==null||cdo.getColValue("porcentaje").equals(""))?"0":cdo.getColValue("porcentaje")); 
		gDiscType = cdo.getColValue("tipodescuento")==null?"P":cdo.getColValue("tipodescuento");
		subTotal1 = Double.parseDouble((cdo.getColValue("sub_total")==null||cdo.getColValue("sub_total").equals(""))?"0":cdo.getColValue("sub_total"));
		double totalFinal = 0.0;
	   		   
	    if(gDiscType.equals("M")){
		  if(gDisc>subTotal1)gDisc=0.0;
	    }else if(gDiscType.equals("P")){
		  if(gDisc>100.00) gDisc=0.0;
	    }
		for(int i=0;i<al.size();i++){
		   CommonDataObject cdoT = (CommonDataObject)al.get(i);

		   cantXEmp=Double.parseDouble((cdoT.getColValue("cantPorEmpaque")==null||cdoT.getColValue("cantPorEmpaque").equals(""))?"0":cdoT.getColValue("cantPorEmpaque"));
		   cantEmp=Double.parseDouble((cdoT.getColValue("cantidad_Empaque")==null||cdoT.getColValue("cantidad_Empaque").equals(""))?"0":cdoT.getColValue("cantidad_Empaque"));
		   cant=cantXEmp*cantEmp;
		   costo = Double.parseDouble((cdoT.getColValue("monto")==null||cdoT.getColValue("monto").equals(""))?"0":cdoT.getColValue("monto"));
		   
		   iDisc=Double.parseDouble((cdoT.getColValue("descuento")==null||cdoT.getColValue("descuento").equals(""))?"0":cdoT.getColValue("descuento"));
		   iDiscType=cdoT.getColValue("tipo_Descuento");

		   if(iDiscType.equals("M")){
			 if(iDisc>costo) iDisc=0.0;
			 iTotal=cant*(costo-iDisc);
			}else if(iDiscType.equals("P")){
			  if(iDisc>100) iDisc=0.0;
			  iTotal=cant*costo*(1-(iDisc/100));
			}
			subTotal+=iTotal;
		}
		
		for(int i=0;i<al.size();i++){
		  CommonDataObject cdoT = (CommonDataObject)al.get(i);
		  
		  cantXEmp=Double.parseDouble((cdoT.getColValue("cantPorEmpaque")==null||cdoT.getColValue("cantPorEmpaque").equals(""))?"0":cdoT.getColValue("cantPorEmpaque"));
		   cantEmp=Double.parseDouble((cdoT.getColValue("cantidad_Empaque")==null||cdoT.getColValue("cantidad_Empaque").equals(""))?"0":cdoT.getColValue("cantidad_Empaque"));
		   cant=cantXEmp*cantEmp;
		   costo = Double.parseDouble((cdoT.getColValue("monto")==null||cdoT.getColValue("monto").equals(""))?"0":cdoT.getColValue("monto"));
		   
		   iDisc=Double.parseDouble((cdoT.getColValue("descuento")==null||cdoT.getColValue("descuento").equals(""))?"0":cdoT.getColValue("descuento"));
		   iDiscType=cdoT.getColValue("tipo_Descuento");
     	   double disc=0.0;
		  
		   if(iDiscType.equals("M")){
			 if(iDisc>costo) iDisc=0.0;
			 iTotal=cant*(costo-iDisc);
			}else if(iDiscType.equals("P")){
			  if(iDisc>100) iDisc=0.0;
			  iTotal=cant*costo*(1-(iDisc/100));
			}

		  if(gDiscType.equals("M")) disc = gDisc*(iTotal/subTotal);
		  else if(gDiscType.equals("P")) disc = (gDisc/100)*iTotal;
		  tDisc+=disc;
		
		  iTax=Double.parseDouble((cdoT.getColValue("impuesto")==null||cdoT.getColValue("impuesto").equals(""))?"0":cdoT.getColValue("impuesto"));
		  if (cdoT.getColValue("itbm")!=null && cdoT.getColValue("itbm").equals("S")) {
		    if(iTax==0.0)iTax=taxPercent;
		  }
		  else iTax = 0.0;
		  if(iTax!=0.0) tTax+=(iTotal-disc)*(iTax/100);
		}
	}
		   
		pc.setNoColumnFixWidth(setDetail);
		pc.createTable("footer", false, 0, 0.0f, width - (leftRightMargin * 2));
			pc.setFont(9, 0);

			pc.addCols(" ",0,setDetail.size());
			if(fp.equals("cambio_precio")||fp.equals("cambio_precio_all"))pc.addBorderCols(cdo.getColValue("explicacion"),0,13);
			else pc.addBorderCols(cdo.getColValue("explicacion"),0,8);
			pc.setNoInnerColumnFixWidth(dInnerHeader);
			pc.createInnerTable(false);

			pc.setInnerTableWidth((width - (leftRightMargin * 2)) * .3f);

				pc.addInnerTableCols("Sub-total",0,1);
				if (fp.equals("cambio_precio")||fp.equals("cambio_precio_all"))
				  pc.addInnerTableBorderCols(CmnMgr.getFormattedDecimal(subTotal),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				else
				 pc.addInnerTableBorderCols(cdo.getColValue("sub_total"),2,1, 0.0f, 0.0f, 0.0f, 0.0f);

				pc.addInnerTableCols("Descuento",0,1);
				if ((fp.equals("cambio_precio")||fp.equals("cambio_precio_all")) && tDisc != 0)
				  pc.addInnerTableBorderCols(CmnMgr.getFormattedDecimal(tDisc),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				else
				  pc.addInnerTableBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("descuento")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);

				pc.addInnerTableCols("Sub-total",0,1);
				if (fp.equals("cambio_precio")||fp.equals("cambio_precio_all"))
				  pc.addInnerTableBorderCols(CmnMgr.getFormattedDecimal(subTotal-tDisc),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				else
				  pc.addInnerTableBorderCols(""+ cdo.getColValue("sub_desc"),2,1, 0.0f, 0.5f, 0.0f, 0.0f);

				pc.addInnerTableCols("ITBMS",0,1);
				if (fp.equals("cambio_precio")||fp.equals("cambio_precio_all"))
				  pc.addInnerTableBorderCols(CmnMgr.getFormattedDecimal(tTax),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				else 
				  pc.addInnerTableBorderCols(""+cdo.getColValue("itbm"),2,1, 0.0f, 0.5f, 0.0f, 0.0f);

				pc.setFont(9, 1);
				pc.addInnerTableCols("Total",0,1);
				if (fp.equals("cambio_precio")||fp.equals("cambio_precio_all"))
				  pc.addInnerTableBorderCols(CmnMgr.getFormattedDecimal(subTotal-tDisc+tTax),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				else
				  pc.addInnerTableBorderCols(cdo.getColValue("monto_total"),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
					
			if(fp.equals("cambio_precio")||fp.equals("cambio_precio_all"))pc.addInnerTableToCols(1);
			else pc.addInnerTableToCols(3);

			pc.setFont(8, 0);

			pc.resetVAlignment();
			pc.addCols(" ",0,setDetail.size());
			
			if(fp.equals("cambio_precio")||fp.equals("cambio_precio_all")){
				pc.addCols(cdo.getColValue("observaciones"),0,9);
				pc.addCols(" ",0,2);
			}else{
			  pc.addCols(cdo.getColValue("observaciones"),0,5);
			  pc.addCols(" ",0,1);
			}
			pc.setNoInnerColumnFixWidth(xInnerHeader);
			pc.createInnerTable(false);
			pc.setInnerTableWidth((width - (leftRightMargin * 2)) * .3f);
				pc.setVAlignment(2);
				pc.addInnerTableCols("Preparado por:",0,1);
				pc.addInnerTableBorderCols(cdo.getColValue("usuario"),1,1,0.5f,0.0f,0.0f,0.0f);

				if (cdo.getColValue("status")!=null && cdo.getColValue("status").equalsIgnoreCase("A")) {
					pc.addInnerTableCols("Aprobado por:",0,1,24.0f);
                    if (showApprovedBy.trim().equalsIgnoreCase("S") || showApprovedBy.trim().equalsIgnoreCase("Y"))
                        pc.addInnerTableBorderCols(cdo.getColValue("usuario_aprob"),1,1,0.5f,0.0f,0.0f,0.0f);
                    else {   
                        pc.addInnerTableBorderCols(" ",1,1,0.5f,0.0f,0.0f,0.0f);

					pc.addInnerTableCols(" ",0,1);
					pc.addInnerTableCols(cdo.getColValue("usuario_mod"),1,1);}
				}
				pc.resetVAlignment();
			if(fp.equals("cambio_precio")||fp.equals("cambio_precio_all")) pc.addInnerTableToCols(3);
			else  pc.addInnerTableToCols(5);


			//pc.addBorderCols(" ",0,setDetail.size(),0.0f,0.0f,0.0f,0.0f,cHeight);

			float observationsHeight = pc.getTableHeight();

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable(true);

		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, subtitle, title, xtraSubtitle, userName, fecha, setDetail.size());
		
		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(setDetail);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();
		
		if (fp.trim().equals("")){
			pc.setFont(8, 0);
			pc.addInnerTableCols("Proveedor:",0,2);
			pc.setFont(8, 1);
			pc.addInnerTableCols(cdo.getColValue("nombre_proveedor"),0,2);
			pc.setFont(8, 0);
			pc.addInnerTableCols("Términos pago:",0,2);
			pc.addInnerTableCols(cdo.getColValue("dias_limite_desc"),0,2);

			pc.addInnerTableCols("Dirección:",0,1);
			pc.addInnerTableCols(cdo.getColValue("direccion"),0,2);
			
			pc.addInnerTableCols("No. de Solicitud:"+cdo.getColValue("requi_anio")+" - "+cdo.getColValue("requi_numero"),0,2);

			pc.addInnerTableCols("Teléfono/Fax: "+cdo.getColValue("telefono_fax"),0,1);
			pc.addInnerTableCols("Fecha: "+cdo.getColValue("fecha_documento")==null?"":cdo.getColValue("fecha_documento"),0,2);

			pc.addInnerTableCols("Correo: ",0,2);
			pc.addInnerTableCols(cdo.getColValue("correo"),0,2);
			pc.addInnerTableCols("F.entrega: "+cdo.getColValue("fecha_entrega")==null?"":cdo.getColValue("fecha_entrega"),0,2);
		}else if (fp.trim().equals("cambio_precio")||fp.equals("cambio_precio_all")){
		
		   String[] provData = {};
		   if (cdo.getColValue("prov_data")!=null && !cdo.getColValue("prov_data").equals("")) provData = cdo.getColValue("prov_data").split("@@");
		
		   try{
		     pc.setFont(8, 0);
			 pc.addInnerTableCols("Proveedor:",0,2);
			 pc.setFont(8, 1);
			 pc.addInnerTableCols(provData[0],0,2);
			 pc.setFont(8, 0);
			 pc.addInnerTableCols("Términos pago:",0,2);
			 pc.addInnerTableCols(cdo.getColValue("dias_limite_desc"),0,2);

			 pc.addInnerTableCols("Dirección:",0,1);
			 pc.addInnerTableCols(provData[1],0,5);
			 
			 pc.addInnerTableCols("No. de Solicitud: - ",0,2);

			 pc.addInnerTableCols("Teléfono/Fax: "+provData[2],0,1);
			 
			 pc.addInnerTableCols("Fecha: "+cdo.getColValue("fecha_documento"),0,2);

			 pc.addInnerTableCols("Correo: ",0,2);
			 pc.addInnerTableCols(cdo.getColValue("correo"),0,2);
			 pc.addInnerTableCols("Fecha de entrega: ",0,5);
		   }catch(Exception e){}
		}

		pc.addInnerTableToCols(setDetail.size());

		pc.setFont(9, 1);
		pc.resetVAlignment();
		
		if (fp.equals("cambio_precio")||fp.equals("cambio_precio_all")){
		  pc.setFont(9,1,Color.white);
		  pc.addCols("", 2, setDetail.size());
		  pc.addCols("S=SUBÍO, B=BAJÓ (Basado en precio venta)", 2, setDetail.size(),Color.lightGray);
		  pc.setFont(9,0);
		}
		
		pc.addBorderCols("Item",0,1,0.5f,0.5f,0.5f,0.5f);
		pc.addBorderCols("Código",0,1,0.5f,0.5f,0.5f,0.5f);
		pc.addBorderCols("Descripción",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Catálogo del producto",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Und Emp",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Cant Emp",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Und",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Cant",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Precio",2,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Desc",2,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Total",2,1,0.5f,0.5f,0.0f,0.5f);
		
		//
		if (fp.equals("cambio_precio")||fp.equals("cambio_precio_all")){
			pc.addBorderCols("PV Und",2,1,0.5f,0.5f,0.0f,0.5f);
			pc.addBorderCols("PV PAQ",2,1,0.5f,0.5f,0.0f,0.5f);
			pc.addBorderCols("...",2,1,0.5f,0.5f,0.0f,0.5f);
		}
		
		
	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	headerHeight =  pc.getTableHeight();

	pc.setNoInnerColumnFixWidth(setDetail);
	pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
	pc.createInnerTable(true);

	dispHeight = height -(topMargin + bottomMargin + headerHeight +footerHeight);
	/*System.out.println("********************** headerHeight ==   "+headerHeight);
	System.out.println("********************** footerHeight ==   "+footerHeight);
	System.out.println("********************** espacio disponible ===   "+dispHeight);*/
	float acumulado = 0.0f;
	float faltante = 0.0f;
	float actual = 0.0f;
	float cAnterior = 0.0f;
	float disponible = 0.0f;
	float cAltura = 0.00f;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		antHeight = pc.getInnerTableHeight();
		
		pc.setFont(9, 0);
		pc.addInnerTableBorderCols(""+(i+1),0, 1, 0.f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("codigoArt"),0, 1, 0.f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("articuloDesc"),0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("catalogo_producto"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("unidad_empaque"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("cantidad_empaque")+"/"+cdo1.getColValue("cantPromoEmp"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("medida"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("cantidad")+"/"+cdo1.getColValue("cantPromo"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("montoArticulo")),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		if (cdo1.getColValue("descuento").equals("0")) pc.addInnerTableBorderCols(" ",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		else {
			if (cdo1.getColValue("tipo_descuento").equals("M")) pc.addInnerTableBorderCols("$"+CmnMgr.getFormattedDecimal(cdo1.getColValue("descuento")),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			else pc.addInnerTableBorderCols(CmnMgr.getFormattedDecimal(cdo1.getColValue("descuento"))+"%",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		}
		pc.addInnerTableBorderCols((cdo1.getColValue("itbm").equals("S")?" * ":"")+CmnMgr.getFormattedDecimal(cdo1.getColValue("total")),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		
		if (fp.equals("cambio_precio")||fp.equals("cambio_precio_all")){
		   
		   String _legend = "", _color="", _title=""; 
		   double lastSprice = Double.parseDouble((cdo1.getColValue("sale_price")==null||cdo1.getColValue("sale_price").equals(""))?"0":cdo1.getColValue("sale_price"));
		   double curSprice = Double.parseDouble((cdo1.getColValue("new_sale_price")==null||cdo1.getColValue("new_sale_price").equals(""))?"0":cdo1.getColValue("new_sale_price"));
		   if (lastSprice>curSprice){_legend="B";
		   }
		   else if(lastSprice<curSprice)_legend="S";
		   
		   System.out.println(":::::::::::::::::::::::::::::::::::::::::lastSprice ="+lastSprice+" curSprice = "+curSprice);
		   
		  String newSalePrice = cdo1.getColValue("new_sale_price")==null?"0":cdo1.getColValue("new_sale_price");
		  String newSalePriceBox = cdo1.getColValue("new_sale_price_box")==null?"0":cdo1.getColValue("new_sale_price_box");
		  
		  pc.addInnerTableBorderCols(CmnMgr.getFormattedDecimal(newSalePrice.equals("")?"0":newSalePrice),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		   pc.addInnerTableBorderCols(CmnMgr.getFormattedDecimal(newSalePriceBox.equals("")?"0":newSalePriceBox),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		   pc.setFont(9,1);
		   pc.addInnerTableBorderCols(_legend,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		   pc.setFont(9,0);
		}
		
		finHeight = pc.getInnerTableHeight();
		cAltura = finHeight - antHeight;
		total += cAltura;
		if( total > dispHeight)
		{
			int ltotal  = (new Double(""+((cAltura-4)/9))).intValue();
			int ldisp = (new Double(""+((dispHeight - (total - cAltura) - 4) / 9))).intValue();
			int lpend = ltotal - ldisp;
			total = (lpend * 9) + 4;
		}
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,setDetail.size());
	else
	{
		innerTableHeight = pc.getInnerTableHeight();
		float altFooterLastPage = observationsHeight;
		float altura = dispHeight-total;
		
		if (fp.equals("cambio_precio")||fp.equals("cambio_precio_all")){
		    pc.addInnerTableBorderCols("",0, 1, 0.0f, 0.0f, 0.0f, 0.5f,(altura - altFooterLastPage-180));
		    pc.addInnerTableBorderCols("",0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		}else{
			if(altura < altFooterLastPage){
		
				pc.addInnerTableBorderCols("",0, 1, 0.0f, 0.0f, 0.0f, 0.5f,altura);
				pc.addInnerTableBorderCols("",0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.0f);

			} else {

				altura = altura - altFooterLastPage;

				pc.addInnerTableBorderCols("",0, 1, 0.0f, 0.0f, 0.0f, 0.5f,altura);
				pc.addInnerTableBorderCols("",0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.0f);

			}
		}


		pc.addInnerTableToBorderCols(setDetail.size());


			pc.addTableToCols("footer", 0, setDetail.size());

		//System.out.println("******************innerTableHeight  ===   "+innerTableHeight);

		pc.flushTableBody(true);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>