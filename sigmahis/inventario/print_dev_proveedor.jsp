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
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String noSecuencia = request.getParameter("noSecuencia");
String pacId = request.getParameter("pacId");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String wh = request.getParameter("wh");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String anio = request.getParameter("anio");
String num = request.getParameter("num");
String codProv = request.getParameter("codProv");
String fg = request.getParameter("fg");

if(wh== null) wh = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(anio== null) anio = "";
if(num== null) num = "";
if(codProv== null) codProv = "";
if(fg== null) fg = "";


if (appendFilter == null) appendFilter = "";

sbSql.append("select dp.anio anioDevolucion , dp.num_devolucion numDevolucion, to_char(dp.fecha,'dd/mm/yyyy') fechaDevolucion, nvl(dp.monto,0) monto_total, nvl(dp.subtotal,0)subtotal, nvl(dp.itbm,0) itbm, dp.usuario_creacion usuarioCreacion, to_char(dp.fecha_creacion,'dd/mm/yyyy') fechaCreacion, dp.usuario_mod usuarioMod, to_char(dp.fecha_mod,'dd/mm/yyyy')fechaMod, dp.cod_provedor codProvedor, dp.codigo_almacen codigoAlmacen, dp.anio_recepcion anioRecepcion, dp.numero_recepcion numeroRecepcion, dp.observacion, dp.numero_factura numeroFactura, dp.nota_credito notaCredito, dp.pagado, dp.anulado_sino anuladoSino, dp.tipo_dev devType, dp.pago,al.descripcion descAlmacen ,p.nombre_proveedor descProveedor,decode(nvl(dp.anulado_sino,'N'),'N','ACTIVA','S','ANULADA') as estado_desc from tbl_inv_devolucion_prov dp ,tbl_inv_almacen al ,tbl_com_proveedor p where dp.codigo_almacen = al.codigo_almacen(+) and dp.compania = al.compania(+) and dp.cod_provedor = p.cod_provedor(+)  and dp.compania = ");
sbSql.append(session.getAttribute("_companyId"));

if(!wh.trim().equals("")){         sbSql.append(" and dp.codigo_almacen = ");sbSql.append(wh);}
if(!codProv.trim().equals("")){    sbSql.append(" and dp.cod_provedor = ");sbSql.append(codProv);}
if(!anio.trim().equals(""))  {      sbSql.append(" and dp.anio = ");sbSql.append(anio);}
if(!num.trim().equals(""))  { sbSql.append(" and dp.num_devolucion = ");sbSql.append(num);}
if(!tDate.trim().equals("")){sbSql.append(" and trunc(dp.fecha) >= to_date('");sbSql.append(tDate);sbSql.append("','dd/mm/yyyy') ");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(dp.fecha) <= to_date('");sbSql.append(fDate);sbSql.append("','dd/mm/yyyy') ");}


CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
if(cdoHeader !=null){
sbSql.append(" select dp.anio, dp.num_devolucion numDevolucion, dp.cod_familia codFamilia, dp.cod_clase codClase, dp.cod_articulo codArticulo, nvl(dp.cantidad,0)cantidad , nvl(dp.precio,0) precio, nvl(dp.art_itbm,0) artItbm, dp.usuario_creacion usuarioCreacion, dp.usuario_modificacion usuarioModificacion, to_char(dp.fecha_creacion,'dd/mm/yyyy hh:mi:ss am') fechaCreacion, to_char(dp.fecha_modificacion,'dd/mm/yyyy') fechaModificacion , a.descripcion articulo ,nvl(a.cod_medida,' ') unidadMedida , nvl(x.cantDevuelta,0) cantDevuelta, nvl(y.cantEntrega,0) cantEntrega, a.cod_subclase subClaseid,nvl(dp.cantidad,0)*nvl(dp.precio,0) totalArticulo from tbl_inv_detalle_proveedor dp, tbl_inv_articulo a ,tbl_inv_devolucion_prov idp ,  ( select  nvl(sum(d.cantidad),0)cantDevuelta ,d.cod_familia,d.cod_clase,d.cod_articulo from tbl_inv_detalle_proveedor d,tbl_inv_devolucion_prov de where d.compania = ");
sbSql.append(session.getAttribute("_companyId"));

sbSql.append("  and d.anio = de.anio and d.num_devolucion = de.num_devolucion  and de.numero_recepcion = ");
sbSql.append(cdoHeader.getColValue("numeroRecepcion"));

sbSql.append(" and de.anio_recepcion =");
sbSql.append(cdoHeader.getColValue("anioRecepcion"));


sbSql.append("  and de.num_devolucion = ");
sbSql.append(cdoHeader.getColValue("numDevolucion"));

sbSql.append(" and de.anio = ");
sbSql.append(cdoHeader.getColValue("anioDevolucion"));

sbSql.append("  group by d.cod_familia,d.cod_clase,d.cod_articulo ) x, ( select sum(nvl(cantidad,0)*nvl(articulo_und,0)) cantEntrega,cod_familia , cod_clase, cod_articulo, anio_recepcion,numero_documento from tbl_inv_detalle_recepcion where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append("  and anio_recepcion = ");
sbSql.append(cdoHeader.getColValue("anioRecepcion"));
sbSql.append(" and numero_documento = ");
sbSql.append(cdoHeader.getColValue("numeroRecepcion"));
sbSql.append("  group by cod_familia , cod_clase, cod_articulo, anio_recepcion,numero_documento  )y  where idp.compania = dp.compania and idp.anio = dp.anio and idp.num_devolucion =dp.num_devolucion and dp.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and dp.anio = ");
sbSql.append(cdoHeader.getColValue("anioDevolucion"));
sbSql.append(" and dp.num_devolucion = ");
sbSql.append(cdoHeader.getColValue("numDevolucion"));
sbSql.append("   and dp.cod_familia = a.cod_flia and dp.cod_clase = a.cod_clase and dp.cod_articulo = a.cod_articulo and dp.compania = a.compania and dp.cod_familia = y.cod_familia(+) and dp.cod_clase = y.cod_clase(+) and dp.cod_articulo = y.cod_articulo(+)   and dp.cod_familia = x.cod_familia(+) and dp.cod_clase = x.cod_clase(+) and dp.cod_articulo = x.cod_articulo(+)  ");


al = SQLMgr.getDataList(sbSql.toString());
}

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
	String title = "DEVOLUCION DE PROVEEDORES";
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
		pc.addBorderCols("Devolucion No.:",0,2,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoHeader.getColValue("anioDevolucion")+" - "+cdoHeader.getColValue("numDevolucion"),0,2,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("       Recep. No "+cdoHeader.getColValue("anioRecepcion")+" - "+cdoHeader.getColValue("numeroRecepcion") ,0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Fecha:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoHeader.getColValue("fechaDevolucion"),0,3,0.0f,0.5f,0.0f,0.0f);

		pc.addCols("Almacén:",0,2);
		pc.addCols(cdoHeader.getColValue("codigoAlmacen")+" - "+cdoHeader.getColValue("descAlmacen"),0,3);
		pc.addCols("Estado:",0,1);
		pc.addCols(cdoHeader.getColValue("estado_desc"),0,3);
		
		pc.addCols("Proveedor:",0,2);
		pc.addCols(cdoHeader.getColValue("codProvedor")+" - "+cdoHeader.getColValue("descProveedor"),0,7);

		pc.addCols("Comentario:",0,2);
		pc.addCols(cdoHeader.getColValue("observacion"),0,7);

		pc.addBorderCols("Familia",1);
		pc.addBorderCols("Clase",1);
		pc.addBorderCols("Subclase",1);
		pc.addBorderCols("Artículo",1);
		pc.addBorderCols("Descripción",1);
		pc.addBorderCols("Cant. Rec",1);
		pc.addBorderCols("Dev",1,1);
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
		pc.addCols(cdo.getColValue("codFamilia"),2,1);
		pc.addCols(cdo.getColValue("codClase"),1,1);
		pc.addCols(cdo.getColValue("subClaseid"),1,1);
		pc.addCols(cdo.getColValue("codArticulo"),1,1);
		pc.addCols(cdo.getColValue("articulo"),0,1);
		pc.addCols(cdo.getColValue("cantEntrega"),1,1);
		pc.addCols(cdo.getColValue("cantidad"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("precio")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("totalArticulo")),2,1);

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