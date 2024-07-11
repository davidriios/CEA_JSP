<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.awt.Color" %>
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
ArrayList alTS = new ArrayList();
ArrayList alTST = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String noSecuencia = request.getParameter("noSecuencia");
String pacId = request.getParameter("pacId");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

if (appendFilter == null) appendFilter = "";

sbSql.append("select a.anio_recepcion anio, a.numero_documento numDocto, a.compania, a.explicacion, a.monto_total montoTotal,a.monto_total totalFact, a.numero_factura, a.codigo_almacen codAlmacen, to_char(a.fecha_documento,'dd/mm/yyyy') fechaDocto, a.itbm, a.subtotal, a.fre_documento freDocto, a.monto_pagado, a.cod_proveedor as codProveedor, a.tipo_factura, decode(a.estado,'R','RECIBIDO','A','ANULADO',a.estado) estado, nvl(a.ajuste,0) ajuste, a.descuento, a.porcentaje, b.nombre_proveedor nameproveedor, c.descripcion descalmacen, d.descripcion descfredocumento ,a.cf_anio cfAnio,cf_num_doc cfNumDoc,cf_tipo_com cfTipoCom,numero_factura as numFactura ,tc.descripcion descTipoComp,a.cod_concepto  codConcepto ,(select codigo||' - '||descripcion from tbl_con_conceptos where codigo = a.cod_concepto and rownum = 1) conceptodesc from tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_inv_documento_recepcion d,tbl_com_tipo_compromiso tc where  a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.fre_documento in ('FR','FC') /* comentado para el modo view  and a.estado = 'R' */ and a.anio_recepcion = ");
sbSql.append(request.getParameter("anio"));
sbSql.append(" and a.numero_documento = ");
sbSql.append(request.getParameter("numero"));
sbSql.append(" and a.cod_proveedor = b.cod_provedor and a.compania = c.compania and a.codigo_almacen = c.codigo_almacen and a.fre_documento = d.documento  and a.cf_tipo_com = tc.tipo_com(+) ");

CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("SELECT a.*, b.* , b.cantidad*b.vcosto as totalArticulo FROM (SELECT a.cod_flia||'-'||a.cod_clase||'-'||a.cod_subclase||'-'||a.cod_articulo art_key, a.compania, a.cod_flia codFamilia, a.cod_clase codClase,a.cod_subclase subclaseId, a.cod_articulo codArticulo, a.descripcion articulo, a.itbm, a.cod_medida unidad, a.precio_venta precio_venta, b.nombre descArtFamilia, c.descripcion descArtClase FROM TBL_INV_ARTICULO a, TBL_INV_FAMILIA_ARTICULO b, TBL_INV_CLASE_ARTICULO c WHERE (a.compania = c.compania AND a.cod_flia = c.cod_flia AND a.cod_clase = c.cod_clase ) AND (c.compania = b.compania AND c.cod_flia = b.cod_flia) AND a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" ) a, (SELECT a.cod_familia||'-'||a.cod_clase||'-'||a.subclase_id||'-'||a.cod_articulo art_key, NVL(anio_recepcion,0) anioRecepcion, NVL(numero_documento,0) numDocto, a.cantidad, v_costo precio, articulo_und artUnidad, cantidad_facturada cantFacturada, art_itbm artItbm, precio vcosto,nvl(variacion,0) as variacion FROM TBL_INV_DETALLE_RECEPCION a WHERE a.compania = "); // Deepak se modifico v_costo por precio para mostrar precio de factura de proveedor no costo promedio
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" AND a.anio_recepcion = ");
sbSql.append(request.getParameter("anio"));
sbSql.append(" and a.numero_documento = ");
sbSql.append(request.getParameter("numero"));
sbSql.append(" )b  WHERE a.art_key = b.art_key order by a.codFamilia, a.codClase,a.subclaseId, a.codArticulo ");


al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "MATERIALES Y EQUIPO SIN ORDEN DE COMPRA";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".40");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".1");
		dHeader.addElement(".1");

	Vector tblDetail = new Vector();
	tblDetail.addElement(".06");
	tblDetail.addElement(".06");
	tblDetail.addElement(".06");
	tblDetail.addElement(".06");
	tblDetail.addElement(".24");
	tblDetail.addElement(".06");
	tblDetail.addElement(".06");
	tblDetail.addElement(".06");
	tblDetail.addElement(".08");
	tblDetail.addElement(".06");
	tblDetail.addElement(".06");
	tblDetail.addElement(".06");
	tblDetail.addElement(".08");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		pc.addCols("Recepción No.:",0,2);
		pc.addCols(cdoHeader.getColValue("anio")+" - "+cdoHeader.getColValue("numdocto"),0,2);
		pc.addCols("Fecha de Sistema: "+fecha.substring(0,10),0,1);
		pc.addCols("Estado: "+cdoHeader.getColValue("estado"),0,4,10f);

		pc.addCols("Doc.Recepción:",0,2);
		pc.addCols("["+cdoHeader.getColValue("freDocto")+"] "+cdoHeader.getColValue("descfredocumento"),0,7);

		pc.addCols("Almacón:",0,2);
		pc.addCols(cdoHeader.getColValue("codalmacen")+" - "+cdoHeader.getColValue("descalmacen"),0,7);

		pc.addCols("Proveedor:",0,2);
		pc.addCols(cdoHeader.getColValue("codproveedor")+" - "+cdoHeader.getColValue("nameproveedor"),0,7,10f);

		pc.addCols("No Factura:",0,2);
		pc.addCols(cdoHeader.getColValue("numFactura"),0,2,10f);
		pc.addCols(cdoHeader.getColValue("fechaDocto"),0,5,10f);

		pc.addCols("Concepto MEF:",0,2);
		pc.addCols(cdoHeader.getColValue("conceptodesc"),0,7,10f);

		pc.addCols("Comentario:",0,2);
		pc.addCols(cdoHeader.getColValue("explicacion"),0,7);

        pc.addCols(" ",0,dHeader.size());

        pc.setFont(headerFontSize,0,Color.white);
        pc.addCols("D E T A L L E",0,2,Color.lightGray);
        pc.addCols("**Qty = Cantidad, C=Costo, Fac=Factura, OC=Orden de Compra, Rec=Recibido",0,7,Color.lightGray);

        // begin table detail

        pc.setFont(headerFontSize,1);

		pc.setNoColumnFixWidth(tblDetail);
		pc.createTable("detail",false,0,0.0f,(pc.getWidth()-leftRightMargin*2));

		pc.addBorderCols("Familia",1,1);
		pc.addBorderCols("Clase",1,1);
		pc.addBorderCols("S.Clase",1,1);
		pc.addBorderCols("Art.",1,1);
		pc.addBorderCols("Descripción",0,1);
		pc.addBorderCols("Qty.Fac",1,1);
		pc.addBorderCols("Qty.Rec",1,1);
		pc.addBorderCols("UND",1,1);
		pc.addBorderCols("Art.x UND",1,1);
		pc.addBorderCols("Costo",1,1);
		pc.addBorderCols("Var.",1,1);
		pc.addBorderCols("Total",2,2);

		//pc.setTableHeader(6);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double cdsTotal = 0.00;
	double total = 0.00;
	boolean delPacDet = true;
	String _taxPercent = (String) session.getAttribute("_taxPercent");
	String porcentaje = (cdoHeader.getColValue("porcentaje")==null || cdoHeader.getColValue("porcentaje").trim().equals("")?"0":cdoHeader.getColValue("porcentaje"));
	String itbm = cdoHeader.getColValue("itbm");

	CommonDataObject cdoPrecio = new CommonDataObject();

	double desc = 0.00, acumDesc = 0.00, monto = 0.00, dif = 0.00, totalItbm = 0.00, subTotal1 = 0.00, subTotal2 = 0.00, artItbm = 0.00, precio = 0.0, descUnitario = 0.0, precioConItbm = 0.0, totalFac=0.0, ajuste=0.0, costoInv=0.0, variacion=0.0, totalFinal=0.0;
	int  cantidad = 0, artUnidad = 0;

	double porc =  Double.parseDouble(porcentaje);

	if (_taxPercent==null || _taxPercent.equals("")) _taxPercent="0";

	double taxPercentage = Double.parseDouble(_taxPercent);

	if(taxPercentage==0.0) taxPercentage = 0.07;
	else taxPercentage = taxPercentage/100;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		cantidad = Integer.parseInt(cdo.getColValue("cantidad"));
		monto = Double.parseDouble(cdo.getColValue("vcosto"));
		artItbm = Double.parseDouble(cdo.getColValue("artItbm"));
		artUnidad	= Integer.parseInt(cdo.getColValue("artUnidad"));
		subTotal1	+= (cantidad*monto);

		desc  = ((porc/100) * (cantidad*monto));
		dif = ((cantidad*monto) - desc);

		acumDesc += desc; //descuento

		if(cdo.getColValue("itbm").trim().equals("S")){
			artItbm = (monto/artUnidad)*taxPercentage*(1-(porc/100));
			//totalItbm += (cantidad * monto);
			totalItbm += dif * taxPercentage;
		} else artItbm = 0.00;

		precio = monto / artUnidad;
		descUnitario = precio * (porc/100);
		precioConItbm = precio - descUnitario + artItbm;

		total = cantidad * monto;

		cdoPrecio = SQLMgr.getData("select nvl(precio,0) precio from tbl_inv_inventario where art_familia = '"+cdo.getColValue("codfamilia")+"' and art_clase = '"+cdo.getColValue("codclase")+"' and cod_articulo = '"+cdo.getColValue("codarticulo")+"' and codigo_almacen = '"+cdoHeader.getColValue("codAlmacen")+"' and compania = "+session.getAttribute("_companyId"));
		
		if (cdoPrecio==null) {
		  cdoPrecio = new CommonDataObject();
		  cdoPrecio.addColValue("precio","0");
		}

		costoInv = Double.parseDouble((cdoPrecio.getColValue("precio")==null?"0":cdoPrecio.getColValue("precio")));

		//v_costo = monto
		if (artUnidad==0.0) variacion = artItbm - monto;
		else variacion = (monto/artUnidad) + artItbm - costoInv;

		//System.out.println("Precio>::::::::::::::::::::::::::::::::::::::::"+(variacion)+" "+((float)variacion));

		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("codfamilia"),1,1);
		pc.addCols(cdo.getColValue("codclase"),1,1);
		pc.addCols(cdo.getColValue("subclaseid"),1,1);
		pc.addCols(cdo.getColValue("codarticulo"),1,1);
		pc.addCols(cdo.getColValue("articulo"),0,1);
		pc.addCols(cdo.getColValue("cantidad"),1,1);
		pc.addCols(cdo.getColValue("cantidad"),1,1);
		pc.addCols(cdo.getColValue("unidad"),1,1);
		pc.addCols(cdo.getColValue("artUnidad"),1,1);
		pc.addCols(cdo.getColValue("vcosto"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("variacion")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(total),2,2);
	}

	if (al.size() == 0) pc.addCols("No existen registros",1,tblDetail.size());
	else
	{
		float descuento = Float.parseFloat((cdoHeader.getColValue("descuento")==null?"0":cdoHeader.getColValue("descuento")));
		double subTotalF = new Double(cdoHeader.getColValue("subtotal")).doubleValue();
		 
		pc.addCols("  ",1,tblDetail.size());
		pc.setFont(7,0);
		pc.addCols("Subtotal 1",2,12);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("subtotal")),2,1);

		pc.addCols("  ",2,8);
		pc.addCols("Total Fac:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("totalFact")),2,1);
		pc.addCols("Descto:",2,1);
		pc.addCols(porcentaje,2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("descuento")),2,1);

		pc.addCols("  ",2,8);
		pc.addCols("Ajuste:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.000000",cdoHeader.getColValue("ajuste")),2,1);
		pc.addCols("Subtotal 2:",2,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal((subTotalF- descuento)),2,1);

		pc.addCols("ITBM:",2,12);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("itbm")),2,1);

		pc.addCols("Total:",2,12);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoHeader.getColValue("totalFact")),2,1);

	}

	pc.useTable("main");
	pc.addTableToCols("detail",0,dHeader.size(),0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);

	//pc.flushTableBody(true);
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>