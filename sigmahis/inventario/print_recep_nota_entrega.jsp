<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
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

sbSql.append("select a.anio_recepcion anio, a.numero_documento as numDocto,a.fre_documento freDocto, a.compania, a.explicacion, a.monto_total, a.numero_factura, a.codigo_almacen codAlmacen, to_char(a.fecha_documento,'dd/mm/yyyy') fechaDocto, a.itbm, a.subtotal, a.monto_pagado, a.cod_proveedor codProveedor, a.tipo_factura, a.estado, a.ajuste, a.descuento, a.porcentaje, b.nombre_proveedor nameproveedor, c.descripcion descalmacen, d.descripcion descfredocumento,a.cf_anio cfAnio,cf_num_doc cfNumDoc,cf_tipo_com cfTipoCom,numero_factura as numFactura ,a.numero_entrega as numEntrega from tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_inv_documento_recepcion d where  a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.fre_documento = 'NE' and a.anio_recepcion = ");
sbSql.append(request.getParameter("anio"));
sbSql.append(" and a.numero_documento = ");
sbSql.append(request.getParameter("numero"));
sbSql.append(" and a.cod_proveedor = b.cod_provedor and a.compania = c.compania and a.codigo_almacen = c.codigo_almacen and a.fre_documento = d.documento");
CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select a.*, b.*,(nvl(b.cantidad,0) * nvl(vcosto,0)) as totalarticulo, decode(nvl(b.artitbm, 0), 0, 'N', 'S') itbm from (select a.cod_flia||'-'||a.cod_clase||'-'||a.cod_subclase||'-'||a.cod_articulo art_key, a.compania, a.cod_flia codfamilia, a.cod_clase codclase, a.cod_subclase subclaseid, a.cod_articulo codarticulo, a.descripcion articulo, a.itbm itbms, a.cod_medida unidad, a.precio_venta , b.nombre descartfamilia, c.descripcion descartclase from tbl_inv_articulo a, tbl_inv_familia_articulo b, tbl_inv_clase_articulo c where (a.compania = c.compania and a.cod_flia = c.cod_flia and a.cod_clase = c.cod_clase) and (c.compania = b.compania and c.cod_flia = b.cod_flia) and a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(") a,(select a.cod_familia||'-'||a.cod_clase||'-'||a.subclase_id||'-'||a.cod_articulo art_key, nvl(anio_recepcion,0) aniorecepcion, nvl(numero_documento,0) numdocto, a.cantidad, precio, articulo_und artunidad, cantidad_facturada cantfacturada, art_itbm artitbm, v_costo vcosto from tbl_inv_detalle_recepcion a where a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.anio_recepcion = ");
sbSql.append(request.getParameter("anio"));
sbSql.append(" and a.numero_documento = ");
sbSql.append(request.getParameter("numero"));
sbSql.append(") b where a.art_key = b.art_key order by a.codfamilia, a.codclase,a.subclaseid, a.codarticulo");

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
	String title = "MATERIALES Y EQUIPOS A CONSIGNACION - NOTA DE ENTREGA";
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

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		pc.addBorderCols("Recepción No.:",0,2,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoHeader.getColValue("anio")+" - "+cdoHeader.getColValue("numdocto"),0,3,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Fecha:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoHeader.getColValue("fechadocto")+" "+" "+" "+" Docto No.: "+cdoHeader.getColValue("numentrega"),0,4,0.0f,0.5f,0.0f,0.0f);

		pc.addCols("Almacén:",0,2);
		pc.addCols(cdoHeader.getColValue("codalmacen")+" - "+cdoHeader.getColValue("descalmacen"),0,7);
		pc.addCols("Proveedor:",0,2);
		pc.addCols(cdoHeader.getColValue("codproveedor")+" - "+cdoHeader.getColValue("nameproveedor"),0,7);

		pc.addCols("Comentario:",0,2);
		pc.addCols(cdoHeader.getColValue("explicacion"),0,7);

		pc.addBorderCols("Familia",1);
		pc.addBorderCols("Clase",1);
		pc.addBorderCols("Subclase",1);
		pc.addBorderCols("Artículo",1);
		pc.addBorderCols("Descripción",1);
		pc.addBorderCols("Cant.",1);
		pc.addBorderCols("Art. Unid.",1,1);
		pc.addBorderCols("Precio",1);
		pc.addBorderCols("Total",1);
		pc.setTableHeader(6);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double cdsTotal = 0.00;
	double total = 0.00;
	boolean delPacDet = true;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("codfamilia"),2,1);
		pc.addCols(cdo.getColValue("codclase"),1,1);
		pc.addCols(cdo.getColValue("subclaseid"),1,1);
		pc.addCols(cdo.getColValue("codarticulo"),1,1);
		pc.addCols(cdo.getColValue("articulo"),0,1);
		pc.addCols(cdo.getColValue("cantidad"),1,1);
		pc.addCols(cdo.getColValue("artunidad"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("vcosto")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("totalarticulo")),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(groupFontSize,1);
		pc.addBorderCols("SUBTOTAL",2,8,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("subtotal")),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("ITBM",2,8,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("itbm")),2,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("TOTAL",2,8,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("monto_total")),2,1,0.0f,0.0f,0.0f,0.0f);

	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>