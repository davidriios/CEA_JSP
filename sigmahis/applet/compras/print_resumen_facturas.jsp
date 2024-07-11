<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
		REPORTE:		INV0032_F.RDF    issue 331
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
ArrayList alTotal = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String cod_prov = request.getParameter("cod_prov");
String titulo = request.getParameter("titulo");
String depto = request.getParameter("depto");
String descAlm = request.getParameter("descAlm");
String tipoDoc = request.getParameter("tipoDoc");
if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(cod_prov== null) cod_prov = "";
if(titulo== null) titulo = "";
if(depto== null) depto = "";
if(descAlm== null) descAlm = "";
if(tipoDoc== null) tipoDoc = "";
/*//appendFilter===========BEGIN==============
if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_documento) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_documento) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
//appendFilter=========END================
//appendFilter1===========BEGIN==============
if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_provedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else{sbSql.append(" and a.codigo_almacen is not null  ");}
//appendFilter1=========END================
//appendFilter2===========BEGIN==============
if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_ajuste) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_ajuste) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
//appendFilter2=========END================
//Filter===========BEGIN==============
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_proveedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else{sbSql.append("  and a.codigo_almacen is not null  ");}
//Filter=====
*/

sbSql.append("select type,tipo_fac, documento,  descripcion ,nvl(monto,0) monto ,  fecha, cod_prov , codigo_almacen, orden_compra from (");

sbSql.append(" select 'A' type,'FC' tipo_fac,nvl(a.numero_factura,' S/F') documento, cf_num_doc orden_compra, p.nombre_proveedor descripcion ,nvl(a.monto_total,0) monto , to_char(a.fecha_documento,'dd/mm/yyyy') fecha,   a.cod_proveedor cod_prov , a.codigo_almacen from tbl_inv_recepcion_material a, tbl_com_proveedor p where a.compania = ");
sbSql.append(compania);
sbSql.append(" and  (a.cod_proveedor =  p.cod_provedor)  and  a.estado = 'R'  ");
if(!tipoDoc.trim().equals(""))
{
sbSql.append("  and  a.fre_documento='");
sbSql.append(tipoDoc);
sbSql.append("'");
}else sbSql.append("  and  a.fre_documento in ('OC', 'FR') ");
if(!fDate.trim().equals("")){sbSql.append(" and trunc(a.fecha_documento) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy') ");}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(a.fecha_documento) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy') ");}
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_proveedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else sbSql.append("  and a.codigo_almacen is not null  ");

sbSql.append(" union  select 'A','NC' tipo_dev  ,a.nota_credito documento_dev, 0, p.nombre_proveedor desc_prov_dev,nvl(a.monto,0)*-1 monto_dev,  to_char(a.fecha,'dd/mm/yyyy') fecha_dev,a.cod_provedor cod_prov_dev, a.codigo_almacen alm_dev from tbl_inv_devolucion_prov a, tbl_com_proveedor p where a.compania = ");
sbSql.append(compania);
sbSql.append(" and a.anulado_sino = 'N'  and ( a.tipo_dev = 'N'  or a.tipo_dev is null) and (a.cod_provedor =  p.cod_provedor) ");
if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_provedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else{sbSql.append(" and a.codigo_almacen is not null  ");}

sbSql.append("    union all ");
sbSql.append(" select 'A','ND' tipo_nd , a.n_d documento_nd, 0, p.nombre_proveedor desc_prov_nd,nvl(a.total,0) monto_nd ,  to_char(a.fecha_ajuste,'dd/mm/yyyy') fecha_nd  , a.cod_proveedor cod_prov_nd   , a.codigo_almacen alm_nd from tbl_com_proveedor p, tbl_inv_ajustes a where a.compania = ");
sbSql.append(compania);
sbSql.append(" and a.codigo_ajuste = 3  and ( a.cod_proveedor = p.cod_provedor) ");

if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_ajuste) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_ajuste) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_proveedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else{sbSql.append("  and a.codigo_almacen is not null  ");}
sbSql.append(" order by 7 ,4 asc ) union select 'C' type,' ','0',' ', 0 , ' ' fecha,0,0, 0  from dual  union   select 'B' type,' ','0',' ', 0 , ' ' fecha,0,0, 0  from dual  ");
sbSql.append("  union all select dd.type,dd.tipo_fac,dd.documento, lpad(to_char(rownum), 4,'0') descripcion,nvl(dd.monto,0) monto, dd.fecha ,dd.cod_prov,dd.codigo_almacen, orden_compra from ( select 'C' type,' ' tipo_fac,' ' documento,' ' descripcion,sum(nvl(w.monto,0)) monto, w.fecha ,0 cod_prov,0 codigo_almacen, orden_compra  from (  select to_char(a.fecha_documento,'dd/mm/yyyy') fecha,nvl(a.monto_total,0) monto, to_char(a.numero_factura) codigo, cf_num_doc orden_compra from tbl_inv_recepcion_material a , tbl_com_proveedor p where a.compania =");
sbSql.append(compania);
sbSql.append(" and (a.cod_proveedor =  p.cod_provedor) ");
if(!tipoDoc.trim().equals(""))
{
sbSql.append("  and  a.fre_documento='");
sbSql.append(tipoDoc);
sbSql.append("'");
}else sbSql.append("  and  a.fre_documento in ('OC', 'FR') ");
sbSql.append(" and a.estado = 'R' ");
if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_documento) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_documento) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_proveedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else{sbSql.append("  and a.codigo_almacen is not null  ");}
sbSql.append(" union all select   to_char(a.fecha,'dd/mm/yyyy') fecha_devt  , nvl(a.monto,0)*-1  monto_devt, a.nota_credito documento_dev, 0 from tbl_inv_devolucion_prov a,  tbl_com_proveedor p where a.compania = ");
sbSql.append(compania);
sbSql.append(" and a.anulado_sino = 'N' and ( a.tipo_dev = 'N' or a.tipo_dev is null) and (a.cod_provedor =  p.cod_provedor)  ");
if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_provedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else{sbSql.append(" and a.codigo_almacen is not null  ");} 
sbSql.append(" union all select to_char(a.fecha_ajuste,'dd/mm/yyyy') fecha_ndt, nvl(a.total,0) monto_ndt,nvl(a.n_d,' ') documento_nd, 0 from tbl_com_proveedor p , tbl_inv_ajustes a where a.compania = "+compania+" and a.codigo_ajuste = 3  and ( a.cod_proveedor = p.cod_provedor) ");

if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_ajuste) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_ajuste) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_proveedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else{sbSql.append("  and a.codigo_almacen is not null  ");}
sbSql.append(" order by 1 asc) w  group by w.fecha,' ', orden_compra order by to_date(w.fecha,'dd/mm/yyyy') asc)  dd ");

sbSql.append(" union all select 'B' as type, ' ', cuenta as nivel, cuenta_desc as desc_nivel, sum(total) as total, null, 0, 0, 0 from (");
	sbSql.append("select coalesce((select decode(cta1||cta2||cta3||cta4||cta5||cta6,null,null,cta1||'-'||cta2||'-'||cta3||'-'||cta4||'-'||cta5||'-'||cta6) from tbl_con_ctas_x_flia y where compania = z.compania and wh = z.codigo_almacen and cod_flia = z.cod_familia),(select decode(cg_cta1||cg_cta2||cg_cta3||cg_cta4||cg_cta5||cg_cta6,null,null,cg_cta1||'-'||cg_cta2||'-'||cg_cta3||'-'||cg_cta4||'-'||cg_cta5||'-'||cg_cta6) from tbl_inv_almacen y where compania = z.compania and codigo_almacen = z.codigo_almacen),'S/C') as cuenta, coalesce((select (select descripcion from tbl_con_catalogo_gral where cta1 = y.cta1 and cta2 = y.cta2 and cta3 = y.cta3 and cta4 = y.cta4 and cta5 = y.cta5 and cta6 = y.cta6 and compania = y.compania) from tbl_con_ctas_x_flia y where compania = z.compania and wh = z.codigo_almacen and cod_flia = z.cod_familia),(select (select descripcion from tbl_con_catalogo_gral where cta1 = y.cg_cta1 and cta2 = y.cg_cta2 and cta3 = y.cg_cta3 and cta4 = y.cg_cta4 and cta5 = y.cg_cta5 and cta6 = y.cg_cta6 and compania = y.compania) from tbl_inv_almacen y where compania = z.compania and codigo_almacen = z.codigo_almacen),'SIN ASIGNAR CUENTA - ('||z.codigo_almacen||'-'||z.cod_familia||')') as cuenta_desc, sum(z.total) as total from (");
		sbSql.append("select a.compania, a.codigo_almacen, b.cod_familia, (b.precio * b.cantidad * b.articulo_und) as total from tbl_inv_recepcion_material a, tbl_inv_detalle_recepcion b where a.anio_recepcion = b.anio_recepcion and a.numero_documento = b.numero_documento and a.compania = b.compania and a.estado = 'R' and a.compania = ");
		sbSql.append(compania);
		if (!fDate.trim().equals("")) { sbSql.append(" and trunc(a.fecha_documento) >= to_date('"); sbSql.append(fDate); sbSql.append("','dd/mm/yyyy')"); }
		if (!tDate.trim().equals("")) { sbSql.append(" and trunc(a.fecha_documento) <= to_date('"); sbSql.append(tDate); sbSql.append("','dd/mm/yyyy')"); }
		if (!cod_prov.trim().equals("")) { sbSql.append(" and a.cod_proveedor = "); sbSql.append(cod_prov); }
		if (!almacen.trim().equals("")) { sbSql.append(" and a.codigo_almacen = "); sbSql.append(almacen); }
		else sbSql.append(" and a.codigo_almacen is not null");
		if (!tipoDoc.trim().equals("")) { sbSql.append(" and a.fre_documento = '"); sbSql.append(tipoDoc); sbSql.append("'"); }
		else sbSql.append(" and a.fre_documento in ('OC','FR')");
		sbSql.append(" union all select a.compania, a.codigo_almacen, b.cod_familia, -((b.precio + nvl(b.art_itbm,0)) * decode(b.cantidad,0,1,b.cantidad)) as total from tbl_inv_devolucion_prov a, tbl_inv_detalle_proveedor b where a.compania = b.compania and a.anio = b.anio and a.num_devolucion = b.num_devolucion and a.anulado_sino = 'N' and nvl(a.tipo_dev,'N') = 'N' and a.compania = ");
		sbSql.append(compania);
		if (!fDate.trim().equals("")) { sbSql.append(" and trunc(a.fecha) >= to_date('"); sbSql.append(fDate); sbSql.append("','dd/mm/yyyy')"); }
		if (!tDate.trim().equals("")) { sbSql.append(" and trunc(a.fecha) <= to_date('"); sbSql.append(tDate); sbSql.append("','dd/mm/yyyy')"); }
		if (!cod_prov.trim().equals("")) { sbSql.append(" and a.cod_provedor = "); sbSql.append(cod_prov); }
		if (!almacen.trim().equals("")) { sbSql.append(" and a.codigo_almacen = "); sbSql.append(almacen); }
		else sbSql.append(" and a.codigo_almacen is not null");
		sbSql.append(" union all select a.compania, a.codigo_almacen, to_number(b.cod_familia) as cod_familia, (nvl(b.precio,0) * decode(b.cantidad_ajuste,0,1,b.cantidad_ajuste)) as total from tbl_inv_ajustes a, tbl_inv_detalle_ajustes b where a.compania = b.compania and a.anio_ajuste = b.anio_ajuste and a.numero_ajuste = b.numero_ajuste and a.codigo_ajuste = b.codigo_ajuste and a.codigo_ajuste = 3 and a.compania = ");
		sbSql.append(compania);
		if (!fDate.trim().equals("")) { sbSql.append(" and trunc(a.fecha_ajuste) >= to_date('"); sbSql.append(fDate); sbSql.append("','dd/mm/yyyy')"); }
		if (!tDate.trim().equals("")) { sbSql.append(" and trunc(a.fecha_ajuste) <= to_date('"); sbSql.append(tDate); sbSql.append("','dd/mm/yyyy')"); }
		if (!cod_prov.trim().equals("")) { sbSql.append(" and a.cod_proveedor = "); sbSql.append(cod_prov); }
		if (!almacen.trim().equals("")) { sbSql.append(" and a.codigo_almacen = "); sbSql.append(almacen); }
		else sbSql.append(" and a.codigo_almacen is not null");
	sbSql.append(") z group by z.compania, z.codigo_almacen, z.cod_familia");
sbSql.append(") group by cuenta, cuenta_desc order by 1,4,7");
al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append(" select cod_prov, desc_prov ,sum(nvl(monto,0)) monto from (  select 'FC' tipo_fac, to_char(a.fecha_documento,'dd/mm/yyyy') fecha, a.numero_factura documento, nvl(a.monto_total,0) monto , a.cod_proveedor cod_prov, p.nombre_proveedor desc_prov  , a.codigo_almacen from tbl_inv_recepcion_material a, tbl_com_proveedor p where a.compania = ");
sbSql.append(compania);
sbSql.append(" and  (a.cod_proveedor =  p.cod_provedor) "); 
if(!tipoDoc.trim().equals(""))
{
sbSql.append("  and  a.fre_documento='");
sbSql.append(tipoDoc);
sbSql.append("'");
}else sbSql.append("  and  a.fre_documento in ('OC', 'FR') ");
sbSql.append(" and a.estado = 'R' ");

if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_documento) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_documento) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_proveedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else{sbSql.append("  and a.codigo_almacen is not null  ");}

 sbSql.append(" union all select 'NC' tipo_dev  , to_char(a.fecha,'dd/mm/yyyy') fecha_dev, a.nota_credito documento_dev, nvl(a.monto,0)*-1 monto_dev, a.cod_provedor cod_prov_dev, p.nombre_proveedor desc_prov_dev , a.codigo_almacen alm_dev from tbl_inv_devolucion_prov a, tbl_com_proveedor p where a.compania = ");
 sbSql.append(compania);
 sbSql.append(" and a.anulado_sino = 'N'  and ( a.tipo_dev = 'N'  or a.tipo_dev is null) and (a.cod_provedor =  p.cod_provedor) ");
if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_provedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else{sbSql.append(" and a.codigo_almacen is not null  ");}

 sbSql.append(" union select 'ND' tipo_nd   , to_char(a.fecha_ajuste,'dd/mm/yyyy') fecha_nd , a.n_d documento_nd , nvl(a.total,0) monto_nd , a.cod_proveedor cod_prov_nd  , p.nombre_proveedor desc_prov_nd , a.codigo_almacen alm_nd from tbl_com_proveedor p, tbl_inv_ajustes a where a.compania = ");
 sbSql.append(compania);
 sbSql.append(" and a.codigo_ajuste = 3  and ( a.cod_proveedor = p.cod_provedor)  ");
 
if(!fDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_ajuste) >=  to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!tDate.trim().equals("")){sbSql.append(" and  trunc(a.fecha_ajuste) <=  to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!cod_prov.trim().equals("")){sbSql.append(" and  a.cod_proveedor = ");sbSql.append(cod_prov);}
if(!almacen.trim().equals("")){sbSql.append(" and  a.codigo_almacen = ");sbSql.append(almacen);}
else{sbSql.append("  and a.codigo_almacen is not null  ");}
sbSql.append("   order by 5,6 ,1,2 asc 			 ) group by cod_prov, desc_prov");

alTotal = SQLMgr.getDataList(sbSql.toString());



if (request.getMethod().equalsIgnoreCase("GET"))
{
	int totalArt = 0;
	double total = 0.00,total_nivel = 0.00,total_fecha = 0.00;
	Hashtable htProv = new Hashtable();
	int maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill


	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);

		 total    += Double.parseDouble(cdo.getColValue("monto"));
		 htProv.put(cdo.getColValue("cod_prov"),cdo.getColValue("monto"));

	}





	int nItems = al.size() + (alTotal.size()*3)+6;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
    String month = mon;
	String servletPath = request.getServletPath();
	String day=fecha.substring(0, 2);
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";
	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

	
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	String create = CmnMgr.createFolder(directory, folderName, year, month);

	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	
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
		setDetail.addElement(".20");
		setDetail.addElement(".20");
		setDetail.addElement(".20");
		setDetail.addElement(".20");
		setDetail.addElement(".20");

	Vector setDetail0 = new Vector();
		setDetail0.addElement(".20");
		setDetail0.addElement(".25");
		setDetail0.addElement(".25");
		setDetail0.addElement(".30");

	String groupBy = "",subGroupBy = "",observ ="";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INFORME DE DOCUMENTOS RECIBIDOS ", " "+fDate+"       A       "+tDate, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols(" "+descAlm,1,setDetail.size());
	pc.addTable();
	pc.copyTable("detailHeader0");

	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("TIPO",1,1);
		pc.addCols("ORDEN COMPRA",1,1);
		pc.addCols("FECHA",1,1);
		pc.addCols("DOCUMENTO",1,1);
		pc.addCols("MONTO",1,1);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(cdo.getColValue("type").trim().equals("A"))
		{
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_prov")))
			{
					if (i != 0)
					{
						pc.setFont(7, 1);
						pc.createTable();
							pc.addCols("Total:  ",2,4,cHeight);
							pc.addCols(" $"+CmnMgr.getFormattedDecimal((String) htProv.get(groupBy)),2,1,cHeight);
						pc.addTable();

						lCounter++;
					}

					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addCols(" "+cdo.getColValue("cod_prov")+"      "+cdo.getColValue("descripcion"),0,setDetail.size(),cHeight);
					pc.addTable();
					pc.addCopiedTable("detailHeader");

					lCounter+=2;
			}



		pc.setFont(7, 0);
		pc.createTable();
			if(cdo.getColValue("tipo_fac").trim().equals("NC")) pc.setFont(7, 0,Color.red);
			else if(cdo.getColValue("tipo_fac").trim().equals("ND")) pc.setFont(7, 0,Color.magenta);
			pc.addCols(""+cdo.getColValue("tipo_fac"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("orden_compra"),1,1,cHeight);
			pc.setFont(7, 0);
			pc.addCols(""+cdo.getColValue("fecha"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("documento"),1,1,cHeight);
			if(cdo.getColValue("tipo_fac").trim().equals("NC")) pc.setFont(7, 0,Color.red);
			else if(cdo.getColValue("tipo_fac").trim().equals("ND")) pc.setFont(7, 0,Color.magenta);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
		pc.addTable();
		lCounter++;
		pc.setFont(7, 0);

	}//
	else
	{

			//System.out.println("type =    "+cdo.getColValue("type")+"documento   "+cdo.getColValue("documento"));

			if (cdo.getColValue("type").trim().equals("B")&& !cdo.getColValue("documento").trim().equals("")&& cdo.getColValue("documento").trim().equals("0"))
			{

				pc.setFont(7, 1);
						pc.createTable();
							pc.addCols("Total:  ",2,4,cHeight);
							pc.addCols(" $"+CmnMgr.getFormattedDecimal((String) htProv.get(groupBy)),2,1,cHeight);
						pc.addTable();

						lCounter++;


				pc.setFont(7, 0,Color.blue);
				pc.createTable();
					pc.addCols("Total:",2,4,cHeight);
					pc.addCols("  $ "+CmnMgr.getFormattedDecimal(""+total),2,1,cHeight);
				pc.addTable();
				lCounter++;

				pc.createTable();
					pc.addCols(" ",0,setDetail.size(),cHeight);
				pc.addTable();

				pc.setNoColumnFixWidth(setDetail0);
				pc.createTable();
					pc.addCols("RESUMEN POR NIVEL CONTABLE ",1,3,cHeight);
					pc.addCols(" ",0,1,cHeight);
				pc.addTable();
				pc.setNoColumnFixWidth(setDetail0);
				pc.createTable();
					pc.addCols(" ",0,1,cHeight);
					pc.addCols("NIVEL",1,1,cHeight);
					pc.addCols("SUB-TOTAL",1,1,cHeight);
					pc.addCols(" ",0,1,cHeight);
				pc.addTable();
				lCounter+=3;
			}
			else if (cdo.getColValue("type").trim().equals("C")&&!cdo.getColValue("documento").trim().equals("")&&cdo.getColValue("documento").trim().equals("0"))
			{

					pc.setNoColumnFixWidth(setDetail0);
						pc.setFont(7, 0,Color.blue);
						pc.createTable();
							pc.addBorderCols("Gran Total",2,2,cHeight);
							pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+total_nivel),2,1,cHeight);
							pc.addCols(" ",0,1,cHeight);
						pc.addTable();


				pc.createTable();
					pc.addCols(" ",0,4,cHeight);
				pc.addTable();

				pc.setNoColumnFixWidth(setDetail0);
				pc.setFont(7, 0,Color.blue);
				pc.createTable();
					pc.addCols(" ",0,1,cHeight);
					pc.addCols("RESUMEN POR FECHA",1,2,cHeight);
					pc.addCols(" ",0,1,cHeight);
				pc.addTable();

				pc.createTable();
					pc.addCols(" ",0,1,cHeight);
					pc.addCols("FECHA",1,1,cHeight);
					pc.addCols("MONTO",1,1,cHeight);
					pc.addCols(" ",0,1,cHeight);
				pc.addTable();
				lCounter+=3;
			}

			if (cdo.getColValue("type").trim().equals("B")&&!cdo.getColValue("documento").trim().equals("")&& !cdo.getColValue("documento").trim().equals("0"))
			{
				pc.setNoColumnFixWidth(setDetail0);
				pc.setFont(7, 0);
				pc.createTable();
					pc.addBorderCols(" "+cdo.getColValue("documento"),1,1,cHeight);
					pc.addBorderCols(" "+cdo.getColValue("descripcion"),0,1,cHeight);
					pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
					pc.addCols(" ",0,1,cHeight);
				pc.addTable();

				total_nivel +=Double.parseDouble(cdo.getColValue("monto"));
				lCounter++;
			}
			else if (cdo.getColValue("type").trim().equals("C") && cdo.getColValue("documento").trim().equals(""))
			{


				pc.setNoColumnFixWidth(setDetail0);
				pc.setFont(7, 0);
				pc.createTable();
					pc.addCols(" ",0,1,cHeight);
					pc.addBorderCols(" "+cdo.getColValue("fecha"),1,1,cHeight);
					pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
					pc.addCols(" ",0,1,cHeight);
				pc.addTable();
				lCounter++;
					total_fecha +=Double.parseDouble(cdo.getColValue("monto"));
			}
	}
		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "INFORME DE DOCUMENTOS RECIBIDOS ", " "+fDate+"       A       "+tDate, userName, fecha);
			pc.addCopiedTable("detailHeader0");
			if (cdo.getColValue("type").trim().equals("A"))
			{
				pc.setNoColumnFixWidth(setDetail);
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols(" "+cdo.getColValue("cod_prov")+"      "+cdo.getColValue("descripcion"),0,setDetail.size(),cHeight);
				pc.addTable();
				pc.addCopiedTable("detailHeader");
			}
			else if (cdo.getColValue("type").trim().equals("B"))
			{
				pc.setNoColumnFixWidth(setDetail0);
					pc.createTable();
						pc.addCols(" ",0,1,cHeight);
						pc.addCols("RESUMEN POR NIVEL CONTABLE ",1,2,cHeight);
						pc.addCols(" ",0,1,cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols(" ",0,1,cHeight);
						pc.addCols("NIVEL",1,1,cHeight);
						pc.addCols("SUB-TOTAL",1,1,cHeight);
						pc.addCols(" ",0,1,cHeight);
					pc.addTable();
			  }
				else if (cdo.getColValue("type").trim().equals("C"))
				{

					pc.setNoColumnFixWidth(setDetail0);
					pc.setFont(7, 0,Color.blue);
					pc.createTable();
						pc.addCols(" ",0,1,cHeight);
						pc.addCols("RESUMEN POR FECHA",1,2,cHeight);
						pc.addCols(" ",0,1,cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols(" ",0,1,cHeight);
						pc.addCols("FECHA",1,1,cHeight);
						pc.addCols("MONTO",1,1,cHeight);
						pc.addCols(" ",0,1,cHeight);
					pc.addTable();

				}
		}

		groupBy    = cdo.getColValue("cod_prov");
		subGroupBy = cdo.getColValue("type");

	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
				pc.setFont(7, 0,Color.blue);
				pc.createTable();
					pc.addCols(" ",0,1,cHeight);
					pc.addBorderCols("Gran Total ",2,1,cHeight);
					pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+total_fecha),2,1,cHeight);
					pc.addCols(" ",0,1,cHeight);
				pc.addTable();

	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>