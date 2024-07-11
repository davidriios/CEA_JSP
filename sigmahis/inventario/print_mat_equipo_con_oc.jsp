<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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

sbSql.append("select a.anio_recepcion as anio, a.numero_documento as numDocto, a.fre_documento as freDocto, a.compania, a.explicacion, a.cod_proveedor as codProveedor, a.tipo_factura, a.estado, a.numero_factura as numFactura, a.codigo_almacen as codAlmacen, to_char(a.fecha_documento,'dd/mm/yyyy') as fechaDocto, nvl(a.subtotal,0) as subtotal, nvl(a.porcentaje,0) as porcentaje, nvl(a.descuento,0) as descuento, nvl(a.itbm,0) as itbm, nvl(a.monto_total,0) as totalFact, nvl(a.ajuste,0) as ajuste, a.cf_anio as cfAnio, cf_num_doc as cfNumDoc, cf_tipo_com as cfTipoCom, a.cod_concepto as codConcepto");
sbSql.append(", (select nombre_proveedor from tbl_com_proveedor where cod_provedor = a.cod_proveedor) as nameproveedor");
sbSql.append(", (select descripcion from tbl_inv_almacen where compania = a.compania and codigo_almacen = a.codigo_almacen) as descalmacen");
sbSql.append(", (select descripcion from tbl_inv_documento_recepcion where documento = a.fre_documento) as descfredocumento");
sbSql.append(", (select descripcion from tbl_com_tipo_compromiso where tipo_com = a.cf_tipo_com and estatus = 'A') as descTipoComp");
sbSql.append(", (select codigo||' - '||descripcion from tbl_con_conceptos where codigo = a.cod_concepto and rownum = 1) as conceptodesc");
sbSql.append(", decode(a.estado,'R','RECIBIDO','A','ANULADO',a.estado) descEstado ");
sbSql.append(" from tbl_inv_recepcion_material a, tbl_com_tipo_compromiso tc where a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.fre_documento in ('OC','FC') /* comentado para el modo view and  a.estado = 'R' */ and a.anio_recepcion = ");
sbSql.append(request.getParameter("anio"));
sbSql.append(" and a.numero_documento = ");
sbSql.append(request.getParameter("numero"));
//sbSql.append("/* and a.cf_tipo_com = tc.tipo_com(+) no sale resultado con este condicion*/ ");
CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select z.compania, z.cod_familia as codFamilia, z.cod_clase as codClase, z.subclase_id as subclaseId, z.cod_articulo as codArticulo, z.articulo_und as artUnidad, nvl(z.art_itbm,0) as artItbm, nvl(z.v_costo,0) as vcosto, z.cantidad, z.cantidad_facturada as cantFacturada, nvl(z.cant_promo_fac,0) as cantPromoFac, nvl(z.cant_rec,0) as cantidadRecibida, nvl(z.cant_promo_rec,0) as cantPromoRec, nvl(z.cantidad_oc,0) as cantOC, nvl(z.cant_promo_oc,0) as cantPromoOC, nvl(z.precio_cotizado,0) as precioCotizado, z.variacion as var, z.impuesto, (z.cantidad_facturada * nvl(z.v_costo,0)) as total");
sbSql.append(", (select descripcion from tbl_inv_articulo where compania = z.compania and cod_articulo = z.cod_articulo) as articulo");
sbSql.append(", (select cod_medida from tbl_inv_articulo where compania = z.compania and cod_articulo = z.cod_articulo) as unidad");
sbSql.append(", (select sum(cantidad) from tbl_com_detalle_compromiso where compania = z.compania and cf_anio = ");
			sbSql.append(cdoHeader.getColValue("cfAnio"));
			sbSql.append(" and cf_tipo_com = ");
			sbSql.append(cdoHeader.getColValue("cfTipoCom"));
			sbSql.append(" and cf_num_doc = '");
			sbSql.append(cdoHeader.getColValue("cfNumDoc"));
			sbSql.append("' and cod_articulo = z.cod_articulo) as cantOC");
			sbSql.append(", (select sum(cant_promo) from tbl_com_detalle_compromiso where compania = z.compania and cf_anio = ");
			sbSql.append(cdoHeader.getColValue("cfAnio"));
			sbSql.append(" and cf_tipo_com = ");
			sbSql.append(cdoHeader.getColValue("cfTipoCom"));
			sbSql.append(" and cf_num_doc = '");
			sbSql.append(cdoHeader.getColValue("cfNumDoc"));
			sbSql.append("' and cod_articulo = z.cod_articulo) as cantPromoOC ");
sbSql.append(" from tbl_inv_detalle_recepcion z");
sbSql.append(" where z.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and z.anio_recepcion = ");
sbSql.append(request.getParameter("anio"));
sbSql.append(" and z.numero_documento = ");
sbSql.append(request.getParameter("numero"));
sbSql.append(" order by 2,3,4,5");
System.out.println("sqlDetails....="+sbSql);
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
	String title = "MATERIALES Y EQUIPO CON ORDEN DE COMPRA";
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
	tblDetail.addElement(".06");
	tblDetail.addElement(".08");
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
		pc.addCols("Fecha: "+cdoHeader.getColValue("fechadocto"),0,1);
		pc.addCols("Doc. Recepción: "+cdoHeader.getColValue("descfredocumento"),0,4,10f);

		pc.addCols("Almacén:",0,2);
		pc.addCols(cdoHeader.getColValue("codalmacen")+" - "+cdoHeader.getColValue("descalmacen"),0,3);
		pc.addCols("Estado:  "+cdoHeader.getColValue("descEstado"),0,4);

		pc.addCols("Ord compra No:",0,2);
		pc.addCols(cdoHeader.getColValue("cfAnio")+" - "+cdoHeader.getColValue("cfNumDoc")+" - "+cdoHeader.getColValue("descTipoComp"),0,7,10f);

		pc.addCols("No Factura:",0,2);
		pc.addCols(cdoHeader.getColValue("numFactura"),0,7,10f);

		pc.addCols("Concepto MEF:",0,2);
		pc.addCols(cdoHeader.getColValue("conceptodesc"),0,7,10f);


		pc.addCols("Proveedor:",0,2);
		pc.addCols(cdoHeader.getColValue("codproveedor")+" - "+cdoHeader.getColValue("nameproveedor"),0,7,10f);

		pc.addCols("Comentario:",0,2);
		pc.addCols(cdoHeader.getColValue("explicacion"),0,7);

				pc.addCols(" ",0,dHeader.size());

				pc.setFont(headerFontSize,0,Color.white);
				pc.addCols("D E T A L L E",0,2,Color.lightGray);
				pc.addCols("**Qty = Cantidad, C=Costo, Fac=Factura, OC=Orden de Compra",0,7,Color.lightGray);

				// begin table detail

				pc.setFont(headerFontSize,1);

		pc.setNoColumnFixWidth(tblDetail);
		pc.createTable("detail",false,0,0.0f,(pc.getWidth()-leftRightMargin*2));

		pc.addBorderCols("Familia",1,1);
		pc.addBorderCols("Clase",1,1);
		pc.addBorderCols("S.Clase",1,1);
		pc.addBorderCols("Art.",1,1);
		pc.addBorderCols("Descripción",0,1);
		pc.addBorderCols("Qty.OC",1,1);
		pc.addBorderCols("Qty.Fac",1,1);
		pc.addBorderCols("Qty.",1,1);
		pc.addBorderCols("UND",1,1);
		pc.addBorderCols("Art.x UND",1,1);
		pc.addBorderCols("C.OC",1,1);
		pc.addBorderCols("C.Fac",1,1);
		pc.addBorderCols("Total",2,1);

		//pc.setTableHeader(6);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("codfamilia"),1,1);
		pc.addCols(cdo.getColValue("codclase"),1,1);
		pc.addCols(cdo.getColValue("subclaseid"),1,1);
		pc.addCols(cdo.getColValue("codarticulo"),1,1);
		pc.addCols(cdo.getColValue("articulo"),0,1);
		pc.addCols(cdo.getColValue("cantOC")+"/"+cdo.getColValue("cantPromoOC"),1,1);
		pc.addCols(cdo.getColValue("cantFacturada")+"/"+cdo.getColValue("cantPromoFac"),1,1);
		pc.addCols(cdo.getColValue("cantidad"),1,1);
		pc.addCols(cdo.getColValue("unidad"),1,1);
		pc.addCols(cdo.getColValue("artUnidad"),1,1);
		pc.addCols(cdo.getColValue("precioCotizado"),1,1);
		pc.addCols(cdo.getColValue("vcosto"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1);
	}


	if (al.size() == 0) pc.addCols("No existen registros",1,tblDetail.size());
	else
	{
		double subTotal = new Double(cdoHeader.getColValue("subtotal")).doubleValue();
		double descuento = new Double(cdoHeader.getColValue("descuento")).doubleValue();

		pc.addCols("  ",1,tblDetail.size());
		pc.setFont(7,0);
		pc.addCols("Subtotal 1",2,12);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.000000",cdoHeader.getColValue("subtotal")),2,1,0.0f,0.5f,0.0f,0.0f);

		pc.addCols("  ",2,8);
		pc.addCols("Total Fac:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("totalFact")),2,1);
		pc.addCols("Descto:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("porcentaje")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.000000",cdoHeader.getColValue("descuento")),2,1);

		pc.addCols("  ",2,8);
		pc.addCols("Ajuste:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("ajuste")),2,1);
		pc.addCols("Subtotal 2:",2,2);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.000000",(subTotal - descuento)),2,1);

		pc.addCols("ITBM:",2,12);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.000000",cdoHeader.getColValue("itbm")),2,1);

	}

	pc.useTable("main");
	pc.addTableToCols("detail",0,dHeader.size(),0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);

	//pc.flushTableBody(true);
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>