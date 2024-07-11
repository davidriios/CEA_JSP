<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/*=========================================================================
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String almacen = request.getParameter("almacen");
String compania = request.getParameter("compania");// (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String proveedor = request.getParameter("proveedor");
String familia = request.getParameter("familia");
String articulo = request.getParameter("articulo");

String factura = request.getParameter("factura");

String appendFilter1 = "";
String appendFilter2 = "";

if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(proveedor== null) proveedor = "";
if(articulo== null) articulo = "";
if(familia== null) familia = "";
if(factura== null) factura = "";


if (appendFilter == null) appendFilter = "";

if(!fDate.trim().equals(""))
{
	appendFilter  +=" and  to_date(to_char(rm.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') >=  to_date('"+fDate+"' ,'dd/mm/yyyy') ";
	appendFilter1 +=" and to_date(to_char(dp.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') >=  to_date('"+fDate+"' ,'dd/mm/yyyy') ";
	appendFilter2 +=" and  to_date(to_char(aj.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') >=  to_date('"+fDate+"' ,'dd/mm/yyyy') ";
}
if(!tDate.trim().equals(""))
{
    appendFilter +=" and  to_date(to_char(rm.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') <=  to_date('"+tDate+"' ,'dd/mm/yyyy') ";
	appendFilter1 +=" and to_date(to_char(dp.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') <=  to_date('"+tDate+"' ,'dd/mm/yyyy') ";
	appendFilter2 +=" and  to_date(to_char(aj.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') <=  to_date('"+tDate+"' ,'dd/mm/yyyy') ";

}
if(!almacen.trim().equals(""))
{
	appendFilter  +=" and al.codigo_almacen = "+almacen;
	appendFilter1 +=" and dp.codigo_almacen = "+almacen;
	appendFilter2 +=" and aj.codigo_almacen = "+almacen;

}
if(!proveedor.trim().equals(""))
{
	appendFilter  +=" and rm.cod_proveedor = "+proveedor;
	appendFilter1 +=" and dp.cod_provedor = "+proveedor;
	appendFilter2 +=" and aj.cod_proveedor = "+proveedor;
}
if(!factura.trim().equals(""))
{
    appendFilter  +=" and rm.numero_factura = '"+factura+"'";
    appendFilter1 +=" and ( dp.numero_factura ='"+factura+"' or dp.nota_credito =  dp.nota_credito ) ";
	appendFilter2 +=" and rm.numero_factura = '"+factura+"'";
}

if(!articulo.trim().equals(""))
{
  	appendFilter  +=" and dr.cod_familia ||'-'||dr.cod_clase||'-'||dr.cod_articulo =  '"+articulo+"'";
	appendFilter1 +=" and d.cod_familia ||'-'||d.cod_clase||'-'||d.cod_articulo =  '"+articulo+"'";
	appendFilter2 +=" and da.cod_familia ||'-'||da.cod_clase||'-'||da.cod_articulo =  '"+articulo+"'";
}
if(!familia.trim().equals(""))
{
	appendFilter  +=" and dr.cod_familia = "+familia;
	appendFilter1 +=" and d.cod_familia = "+familia;
	appendFilter2 +=" and da.cod_familia = "+familia;
}

sql=" select p.cod_provedor cod_prov,al.codigo_almacen cod_almacen, al.descripcion desc_almacen ,al.codigo_almacen||'-'||p.cod_provedor cod_proveedor , p.nombre_proveedor desc_proveedor , rm.anio_recepcion||'-'||rm.numero_documento no_registro , rm.numero_factura no_factura , rm.cf_anio||'-'||rm.cf_num_doc||'-'||rm.cf_tipo_com orden_compra  , to_char(rm.fecha_documento,'dd/mm/yyyy') fecha , nvl(rm.monto_total,0) monto_fac  , dr.cod_familia||'-'||dr.cod_clase||'-'||dr.cod_articulo cod_articulos, a.descripcion desc_articulo,nvl((select sum(cantidad) from tbl_com_detalle_compromiso where compania = rm.compania and cf_anio = rm.cf_anio and cf_tipo_com = rm.cf_tipo_com and cf_num_doc =rm.cf_num_doc and cod_articulo = dr.cod_articulo),0) /*nvl(dr.cantidad_oc,0)*/ as unidades_oc,nvl(dr.cantidad ,0) unidades , /*nvl(dr.cantidad_oc,0)*/nvl((select sum(cantidad) from tbl_com_detalle_compromiso where compania = rm.compania and cf_anio = rm.cf_anio and cf_tipo_com = rm.cf_tipo_com and cf_num_doc =rm.cf_num_doc and cod_articulo = dr.cod_articulo),0) -nvl(dr.cantidad,0) unidades_pend , nvl(dr.articulo_und,0) uds_x_caja , nvl(dr.precio,0) costo, nvl(dr.art_itbm,0) itbm  , (nvl(dr.precio,0)* nvl(dr.cantidad,0)) total , nvl(dr.cantidad,0)*nvl(dr.articulo_und,0) total_unidades, (nvl(dr.cantidad,0)*nvl(dr.articulo_und,0))*nvl(dr.precio,0)  monto_unidades from tbl_inv_detalle_recepcion dr,tbl_inv_recepcion_material rm,tbl_inv_articulo a,tbl_com_proveedor p,tbl_inv_almacen al where rm.compania = "+compania+"  and (dr.compania = rm.compania and dr.numero_documento  = rm.numero_documento and dr.anio_recepcion = rm.anio_recepcion) and (dr.cod_familia = a.cod_flia and dr.cod_clase = a.cod_clase and dr.cod_articulo = a.cod_articulo and dr.compania = a.compania) and (rm.cod_proveedor = p.cod_provedor) and (rm.compania = al.compania and rm.codigo_almacen = al.codigo_almacen) and rm.estado = 'R' and rm.fre_documento in ( 'OC', 'FR' )  and dr.cantidad  > 0   "+appendFilter;

sql += " union ";
sql += "  select p.cod_provedor,dp.codigo_almacen cod_alm_nc,al.descripcion desc_alm_nc,dp.codigo_almacen||'-'||p.cod_provedor cod_prov_nc,p.nombre_proveedor nombre_prov_nc  ,dp.anio||'-'||dp.num_devolucion ||'-'||'N/C:'||dp.nota_credito num_nota_cr,' N/C:'|| dp.numero_factura  fac_nc,'0', to_char(dp.fecha,'dd/mm/yyyy')  fecha_nc, (nvl(dp.monto,0)*-1) monto_nc, d.cod_familia||'-'||d.cod_clase  ||'-'||d.cod_articulo   cod_art_nc,a.descripcion desc_art_nc,0,(d.cantidad*-1) cant_nc,0,0,((d.precio+d.art_itbm)*-1)  costo_nc  ,d.art_itbm itbm,((d.precio* decode(d.cantidad,0,1,-d.cantidad))+( decode(d.cantidad,0,-1,-d.cantidad)  *d.art_itbm)*-1) total_nc, (d.cantidad*-1)*1 total_unidades,(case when (nvl(d.cantidad,0)*-1) = 0  then ((nvl(d.precio,0)+nvl(d.art_itbm,0))*-1)  when (nvl(d.cantidad,0)*-1) <> 0 then (nvl(d.cantidad,1)) * ((nvl(d.precio,0)+nvl(d.art_itbm,0))*-1) else 0 end  ) monto_unidades  from tbl_inv_devolucion_prov dp,tbl_inv_detalle_proveedor d, tbl_com_proveedor p, tbl_inv_articulo a,tbl_inv_almacen al where dp.compania = "+compania+" and dp.anulado_sino = 'N' and dp.tipo_dev = 'N' and (dp.cod_provedor =  p.cod_provedor) and dp.anio = d.anio and dp.num_devolucion = d.num_devolucion and dp.compania = d.compania and d.cod_articulo = a.cod_articulo and d.compania = a.compania and (dp.cod_provedor = p.cod_provedor) and (dp.compania = al.compania and dp.codigo_almacen = al.codigo_almacen)  "+appendFilter1 ;

sql += " union ";

sql += " select p.cod_provedor, aj.codigo_almacen cod_alm_nd, al.descripcion desc_alm_nd, aj.codigo_almacen||'-'||p.cod_provedor cod_prov_nd, p.nombre_proveedor nombre_prov_nd, to_char(aj.anio_ajuste||'-'||aj.numero_ajuste||'-'||'N/D'||aj.n_d) nota_db#, 'N/D:'||to_char(aj.numero_doc)  num_doc_nd, '0',to_char(aj.fecha_ajuste,'dd/mm/yyyy') fecha_nd, nvl(aj.total,0) total_nd,to_char(da.cod_familia||'-'||da.cod_clase||'-'||da.cod_articulo) art_ndb, a.descripcion desc_art_nd ,0, da.cantidad_ajuste cant_nd ,0,0, da.precio precio_nd,0,(da.precio*da.cantidad_ajuste)total_ndb ,nvl(da.cantidad_ajuste ,0)*0 total_ajustes, (nvl(da.cantidad_ajuste ,0)*0)*nvl(da.precio,0)  monto_unidades from tbl_inv_ajustes aj, tbl_inv_detalle_ajustes da, tbl_inv_articulo a, tbl_com_proveedor p, tbl_inv_almacen al , tbl_inv_recepcion_material rm where aj.compania = "+compania+" and aj.codigo_ajuste = 3 and aj.compania = da.compania and aj.anio_ajuste = da.anio_ajuste and aj.numero_ajuste = da.numero_ajuste and aj.codigo_ajuste = da.codigo_ajuste  and aj.anio_doc = rm.anio_recepcion and aj.numero_doc = rm.numero_documento and aj.compania = rm.compania and da.cod_articulo = a.cod_articulo and da.compania = a.compania and (aj.cod_proveedor = p.cod_provedor) and (aj.compania = al.compania and aj.codigo_almacen = al.codigo_almacen) "+appendFilter2+" order by 2 asc  ";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;

	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "COMPRAS";
	String subtitle = "DETALLE DE FACTURAS POR ALMACEN";
	String xtraSubtitle = " DESDE   "+fDate+"             HASTA   "+tDate;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

		Vector dHeader=new Vector();
			dHeader.addElement(".10");
			dHeader.addElement(".34");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(7, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",0);
		pc.addBorderCols("UDS. ORD",1);
		pc.addBorderCols("UDS. REC",1);
		pc.addBorderCols("UDS. PEND",1);
		pc.addBorderCols("U/C",1);
		pc.addBorderCols("TOT. UDS",1);
		pc.addBorderCols("COSTO UDS",1);
		pc.addBorderCols("COSTO TOTAL",1);

	  pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	 //table body
	 pc.setVAlignment(0);
	 pc.setFont(7, 0);
	String groupBy = "",nRegistro ="";
	String subGroupBy = "";
	int cantProv =0,total_unidades_prov=0,total_uds=0;
	double total_unidades_wh = 0.00,g_total_wh =0.00,total_prov =0.00,total_monto=0.00,monto_fac=0.00,total_fac=0.00,total_wh=0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!nRegistro.equalsIgnoreCase(cdo.getColValue("no_registro")))
		{
				if (i != 0)
				{
					pc.setFont(7, 1);
					pc.addCols("SUB-TOTAL EN FACTURA X TRN :  ",0,2,cHeight);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(monto_fac),2,1,cHeight);
					pc.addCols("sub-total x trn :  ",1,3,cHeight);
					pc.addCols(" "+total_uds,1,1,cHeight);
					pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,###,##0.0000",total_monto),2,2,cHeight);

					total_uds=0;
					total_fac += monto_fac;
					total_monto=0.00;
					monto_fac =0.00;
 				}
		}
		if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_proveedor")))
		{
				if (i != 0)
				{
					pc.setFont(7, 1);
						pc.addCols("SUB-TOTAL EN FACTURA X PROV. :  ",0,2,cHeight);
						pc.addCols(""+CmnMgr.getFormattedDecimal(total_fac),2,1,cHeight);
						pc.addCols("sub-total x trn :  ",1,3,cHeight);
						pc.addCols(" "+total_unidades_prov,1,1,cHeight);
						pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,###,##0.0000",total_prov),2,2,cHeight);
					total_wh += total_fac;
					total_fac = 0.00;
					total_unidades_prov =0;
					total_prov =0.00;

					pc.setFont(7, 1,Color.blue);
						pc.addCols(" ",0,9,cHeight);
				}
		}
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")))
			{
					if (i != 0)
					{
						pc.setFont(7, 3);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(total_wh),2,1,cHeight);
						pc.addCols("GRAN TOTAL :  ",1,3,cHeight);
						pc.addCols(" "+total_unidades_wh,1,1,cHeight);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(g_total_wh),2,2,cHeight);
						total_wh =0.00;

						pc.setFont(7, 1,Color.blue);
						pc.addCols(" ",0,9,cHeight);
						total_unidades_wh =0;
						g_total_wh =0.00;
 					}
			}
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")))
			{
					pc.setFont(7, 1,Color.blue);
					pc.addCols("ALMACEN: "+cdo.getColValue("cod_almacen"),0,1,cHeight);
					pc.addCols(" "+cdo.getColValue("desc_almacen"),1,8,cHeight);
			}
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_proveedor")))
			{
					pc.setFont(7, 1,Color.red);
					pc.addCols("PROVEEDOR: ",0,1,cHeight);
					pc.addCols(" "+cdo.getColValue("cod_prov")+"       "+cdo.getColValue("desc_proveedor"),0,8,cHeight);
 			}
 			if (!nRegistro.equalsIgnoreCase(cdo.getColValue("no_registro")))
			{
 					pc.setFont(7, 1,Color.blue);
					pc.addCols(" Factura # :"+cdo.getColValue("no_factura")+"      No Orden: "+cdo.getColValue("orden_compra"),0,2,cHeight);
			//		pc.addCols("No Orden: "+cdo.getColValue("orden_compra"),0,1,cHeight);
					pc.addCols("No Registro: "+cdo.getColValue("no_registro"),0,3,cHeight);
					pc.addCols("Fecha: "+cdo.getColValue("fecha"),0,4,cHeight);
 			}

  			pc.setFont(7, 0);
 			pc.addCols(""+cdo.getColValue("cod_articulos"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("unidades_oc"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("unidades"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("unidades_pend"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("uds_x_caja"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("total_unidades"),1,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,###,##0.0000",cdo.getColValue("costo")),2,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,###,##0.0000",cdo.getColValue("monto_unidades")),2,1,cHeight);

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

 	  	groupBy      = cdo.getColValue("cod_almacen");
 		subGroupBy   = cdo.getColValue("cod_proveedor");
 		nRegistro    = cdo.getColValue("no_registro");
 		monto_fac    = Double.parseDouble(cdo.getColValue("monto_fac"));//Double.parseDouble(cdo.getColValue("monto_fac"));
 		total_uds   += Integer.parseInt(cdo.getColValue("total_unidades"));
 		total_monto += Double.parseDouble(cdo.getColValue("monto_unidades"));

 		total_unidades_wh   += Integer.parseInt(cdo.getColValue("total_unidades"));
 		g_total_wh += Double.parseDouble(cdo.getColValue("monto_unidades"));
 		total_unidades_prov   += Integer.parseInt(cdo.getColValue("total_unidades"));
		total_prov += Double.parseDouble(cdo.getColValue("monto_unidades"));

	

	}	// end for i

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,dHeader.size());
	} else
	{
   			pc.setFont(7, 1);
			pc.addCols("SUB-TOTAL EN FACTURA X TRN :  ",0,2,cHeight);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(monto_fac),2,1,cHeight);
			pc.addCols("sub-total x trn :  ",1,3,cHeight);
			pc.addCols(" "+total_uds,1,1,cHeight);
			pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,###,##0.0000",total_monto),2,2,cHeight);

			pc.addCols(" ",0,9,cHeight);

			pc.addCols("SUB-TOTAL EN FACTURA X PROV. :  ",0,2,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(total_fac),2,1,cHeight);
			pc.addCols("sub-total x trn :  ",1,3,cHeight);
			pc.addCols(" "+total_unidades_prov,1,1,cHeight);
			pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,###,##0.0000",total_prov),2,2,cHeight);

			pc.addCols(" ",0,9,cHeight);

			pc.addCols("GRAN-TOTAL EN FACTURA X ALM. :  ",0,2,cHeight);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(total_wh),2,1,cHeight);
			pc.addCols("GRAN TOTAL :  ",1,3,cHeight);
			pc.addCols(" "+total_unidades_wh,1,1,cHeight);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(g_total_wh),2,2,cHeight);

 	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>