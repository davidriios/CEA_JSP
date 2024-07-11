<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**    REPORTE  :  INV0052.RDF
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
ArrayList alAl = new ArrayList();
ArrayList alTotal = new ArrayList();
ArrayList alTotAl = new ArrayList();
String sql = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fechaini = request.getParameter("fechaI");
String fechafin = request.getParameter("fechaF");
String almacen = request.getParameter("almacen");
String compania = request.getParameter("compania");
String consignacion = request.getParameter("consignacion");
String appendFilter = "", appendFilter2 = "";
if (fechaini == null) fechaini="";// fechaini="01/01/1901";
if (fechafin == null) fechafin="";// fechafin = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (compania == null) compania = "";
if (almacen == null) almacen = "";
if (consignacion == null) consignacion = "";

if(!compania.equals("")) appendFilter += " and fcc.compania = "+compania;
if(!almacen.equals("")) appendFilter += " and fdc.inv_almacen = "+almacen;
if(!fechaini.equals("")) appendFilter += " and to_date(to_char(fcc.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
if(!fechafin.equals("")) appendFilter += " and to_date(to_char(fcc.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')";
if(!consignacion.equals("")) appendFilter2 += " and a.consignacion_sino = '"+consignacion+"'";

sql = "select descripcion from tbl_inv_almacen where compania = " + compania + " and codigo_almacen = " + almacen;
CommonDataObject cdoAlm = SQLMgr.getData(sql);

System.out.println("-----------------------------------INICIA REPORTE-----------------------------------");
String sqlDet = "select 'FACTURA' tipo_trn, ftc.descripcion group1, to_char(fcc.fecha, 'dd/MON/yyyy') fecha, fcc.compania, fcc.anio, ff.numero_factura factura, fcc.codigo group3, nvl(ff.subtotal, fcc.subtotal) subtotal, nvl(nvl(ff.itbm, fcc.itbm),0) itbm, nvl(ff.monto_total, fcc.total) monto_total, fcc.tipo_transaccion, fcc.cliente group2, fdc.inv_almacen, sum(fdc.monto * fdc.cantidad) precio_venta, sum(decode(fdc.tipo_transaccion, 'C',(i.precio * fdc.cantidad))) monto_costo, 0, fcc.codigo||fcc.anio||fcc.tipo_transaccion key from tbl_fac_factura ff, tbl_fac_tipo_cliente ftc, tbl_fac_cargo_cliente fcc, tbl_fac_detc_cliente fdc, tbl_inv_inventario i where ff.facturar_a(+) = 'O' and ff.estatus(+) <> 'A' and fcc.tipo_transaccion = 'C' "+appendFilter+" and (fcc.compania = ftc.compania and fcc.tipo_cliente = ftc.codigo and (ff.compania(+) = fcc.compania and ff.anio_cargo(+) = fcc.anio and ff.codigo_cargo(+) = fcc.codigo and ff.tipo_cargo(+) = fcc.tipo_transaccion) and (fdc.compania = fcc.compania and fdc.anio = fcc.anio and fdc.tipo_transaccion = fcc.tipo_transaccion and fdc.cargo = fcc.codigo) and fdc.inv_almacen = i.codigo_almacen and fdc.inv_cod_articulo = i.cod_articulo and fdc.inv_art_familia = i.art_familia and fdc.inv_art_clase = i.art_clase and fdc.compania = i.compania) and exists (select 'x' from tbl_inv_articulo a where a.compania = i.compania and a.cod_flia = i.art_familia and a.cod_clase = i.art_clase and a.cod_articulo = i.cod_articulo "+appendFilter2+") group by ftc.descripcion, to_char(fcc.fecha, 'dd/MON/yyyy'), fcc.compania, fcc.anio, ff.numero_factura, fcc.codigo, nvl(ff.subtotal, fcc.subtotal), nvl(ff.itbm, fcc.itbm), nvl(ff.monto_total, fcc.total), fcc.tipo_transaccion, fcc.cliente, fdc.inv_almacen, fcc.codigo||fcc.anio||fcc.tipo_transaccion union select 'DEVOLUCION', ftc.descripcion, to_char(fcc.fecha, 'dd/MON/yyyy') fecha, fcc.compania, fcc.anio num_cargo, fcc.codigo, fcc.codigo devol, (fcc.subtotal * -1), (fcc.itbm * -1), (fcc.total * -1), fcc.tipo_transaccion, fcc.cliente, fdc.inv_almacen, (sum(fdc.monto * fdc.cantidad) * -1) precio_venta, (sum(decode(fdc.tipo_transaccion, 'D',(i.precio * fdc.cantidad))) * -1) monto_costo, 0, fcc.codigo||fcc.anio||fcc.tipo_transaccion key from tbl_fac_tipo_cliente ftc, tbl_fac_cargo_cliente fcc, tbl_fac_detc_cliente fdc, tbl_inv_inventario i where fcc.tipo_transaccion = 'D'"+appendFilter+" and (fcc.compania = ftc.compania and fcc.tipo_cliente = ftc.codigo and (fdc.compania = fcc.compania and fdc.anio = fcc.anio and fdc.tipo_transaccion = fcc.tipo_transaccion and fdc.cargo = fcc.codigo) and fdc.inv_almacen = i.codigo_almacen and fdc.inv_cod_articulo = i.cod_articulo and fdc.inv_art_familia = i.art_familia and fdc.inv_art_clase = i.art_clase and fdc.compania = i.compania) and exists(select 'x' from tbl_inv_articulo a where a.compania = i.compania and a.cod_flia = i.art_familia and a.cod_clase = i.art_clase and a.cod_articulo = i.cod_articulo "+appendFilter2+") group by ftc.descripcion, to_char(fcc.fecha, 'dd/MON/yyyy'), fcc.compania, fcc.anio, fcc.codigo, fcc.codigo, fcc.subtotal, fcc.itbm, fcc.total, fcc.tipo_transaccion, fcc.cliente, fdc.inv_almacen, fcc.codigo||fcc.anio||fcc.tipo_transaccion order by 2, 12, 7";
al = SQLMgr.getDataList(sqlDet);

sql = "select group2, count(*) trn_x_clt, sum(monto_costo) monto_costo, sum(subtotal) subtotal, sum(nvl(itbm,0)) itbm, sum(monto_total) monto_total from ("+sqlDet+") group by group2 order by group2";
ArrayList alTotXClte = SQLMgr.getDataList(sql);
Hashtable htSTot = new Hashtable();
CommonDataObject cdoTxC = new CommonDataObject();
for(int i=0;i<alTotXClte.size();i++){
	CommonDataObject cdoDet = (CommonDataObject) alTotXClte.get(i);
	htSTot.put(cdoDet.getColValue("group2"), cdoDet);
}

sql = "select group1, count(*) trn_x_clt, sum(monto_costo) monto_costo, sum(subtotal) subtotal, sum(nvl(itbm,0)) itbm, sum(monto_total) monto_total from ("+sqlDet+") group by group1 order by group1";
ArrayList alTotTClte = SQLMgr.getDataList(sql);
Hashtable htTot = new Hashtable();
CommonDataObject cdoTxTC = new CommonDataObject();
for(int i=0;i<alTotTClte.size();i++){
	CommonDataObject cdoDet = (CommonDataObject) alTotTClte.get(i);
	htTot.put(cdoDet.getColValue("group1"), cdoDet);
}

sql = "select count(*) trn_x_clt, sum(monto_costo) monto_costo, sum(subtotal) subtotal, sum(nvl(itbm,0)) itbm, sum(monto_total) monto_total from ("+sqlDet+")";
CommonDataObject cdoTotF = SQLMgr.getData(sql);

sql = "select fcc.codigo cargo, fcc.anio, fcc.compania, fcc.tipo_transaccion, decode (a.consignacion_sino, 'S', 'CONS', fdc.tipo_servicio) tipo_serv, nvl(sum (fdc.monto * fdc.cantidad), 0) precio_venta_t_s, nvl(sum (decode (fdc.tipo_transaccion, 'C', (i.precio * fdc.cantidad))), 0) m_costo, decode(a.consignacion_sino, 'S', 'CONSIGNACION', cts.descripcion) tipo_serv_desc, fcc.codigo||fcc.anio||fcc.tipo_transaccion key from tbl_fac_factura ff, tbl_fac_tipo_cliente ftc, tbl_fac_cargo_cliente fcc, tbl_fac_detc_cliente fdc, tbl_inv_inventario i, tbl_inv_articulo a, tbl_cds_tipo_servicio cts where ff.facturar_a(+) = 'O' and fcc.tipo_transaccion = 'C' and ff.estatus(+) <> 'A' "+appendFilter+" and (fcc.compania = ftc.compania and fcc.tipo_cliente = ftc.codigo and (ff.compania(+) = fcc.compania and ff.anio_cargo(+) = fcc.anio and ff.codigo_cargo(+) = fcc.codigo and ff.tipo_cargo(+) = fcc.tipo_transaccion) and (fdc.compania = fcc.compania and fdc.anio = fcc.anio and fdc.tipo_transaccion = fcc.tipo_transaccion and fdc.cargo = fcc.codigo) and fdc.inv_almacen = i.codigo_almacen and fdc.inv_cod_articulo = i.cod_articulo and fdc.inv_art_familia = i.art_familia and fdc.inv_art_clase = i.art_clase and fdc.compania = i.compania) and (a.compania = i.compania and a.cod_flia = i.art_familia and a.cod_clase = i.art_clase and a.cod_articulo = i.cod_articulo) "+appendFilter2+" and fdc.tipo_servicio = cts.codigo(+) group by fcc.codigo, fcc.anio, fcc.compania, fcc.tipo_transaccion, decode(a.consignacion_sino, 'S', 'CONS', fdc.tipo_servicio), decode(a.consignacion_sino, 'S', 'CONSIGNACION', cts.descripcion), fcc.codigo||fcc.anio||fcc.tipo_transaccion UNION select fcc.codigo cargo, fcc.anio num_cargo, fcc.compania, fcc.tipo_transaccion, decode(a.consignacion_sino, 'S', 'CONS', fdc.tipo_servicio) tipo_serv, nvl((sum(fdc.monto * fdc.cantidad) * -1), 0) precio_venta_t_s, nvl((sum(decode (fdc.tipo_transaccion, 'D', (i.precio * fdc.cantidad))) * -1), 0) m_costo, decode(a.consignacion_sino, 'S', 'CONSIGNACION', cts.descripcion) tipo_serv_desc, fcc.codigo||fcc.anio||fcc.tipo_transaccion key from tbl_fac_cargo_cliente fcc, tbl_fac_detc_cliente fdc, tbl_inv_inventario i, tbl_inv_articulo a, tbl_cds_tipo_servicio cts where (fcc.tipo_transaccion = 'D'"+appendFilter+" and (fdc.compania = fcc.compania and fdc.anio = fcc.anio and fdc.tipo_transaccion = fcc.tipo_transaccion and fdc.cargo = fcc.codigo) and fdc.inv_almacen = i.codigo_almacen and fdc.inv_cod_articulo = i.cod_articulo and fdc.inv_art_familia = i.art_familia and fdc.inv_art_clase = i.art_clase and fdc.compania = i.compania) and (a.compania = i.compania and a.cod_flia = i.art_familia and a.cod_clase = i.art_clase and a.cod_articulo = i.cod_articulo) "+appendFilter2+" and fdc.tipo_servicio = cts.codigo(+) group by fcc.codigo, fcc.anio, fcc.compania, fcc.tipo_transaccion, decode (a.consignacion_sino, 'S', 'CONS', fdc.tipo_servicio), decode(a.consignacion_sino, 'S', 'CONSIGNACION', cts.descripcion), fcc.codigo||fcc.anio||fcc.tipo_transaccion";
System.out.println("sql detalle...\n"+sql);

ArrayList detail = new ArrayList();
detail = SQLMgr.getDataList(sql);
ArrayList asd = new ArrayList();
Hashtable htDet = new Hashtable();
String keyDet = "";
for(int i = 0; i<detail.size(); i++){
	CommonDataObject cdoDet = (CommonDataObject) detail.get(i);
	if(!cdoDet.getColValue("key").equals(keyDet) && i!=0){
		htDet.put(keyDet, asd);
		asd = new ArrayList();
	}
	keyDet = cdoDet.getColValue("key");
	asd.add(cdoDet);
}

sql = "select ' ' descripcion, decode (a.consignacion_sino, 'S', 'CONS', fdc.tipo_servicio) tipo_serv, nvl(sum (fdc.monto * fdc.cantidad), 0) precio_venta_t_s, nvl(sum (decode (fdc.tipo_transaccion, 'C', (i.precio * fdc.cantidad))), 0) m_costo, decode(a.consignacion_sino, 'S', 'CONSIGNACION', cts.descripcion) tipo_serv_desc from tbl_fac_factura ff, tbl_fac_tipo_cliente ftc, tbl_fac_cargo_cliente fcc, tbl_fac_detc_cliente fdc, tbl_inv_inventario i, tbl_inv_articulo a, tbl_cds_tipo_servicio cts where ff.facturar_a(+) = 'O' and fcc.tipo_transaccion = 'C' and ff.estatus(+) <> 'A' "+appendFilter+" and (fcc.compania = ftc.compania and fcc.tipo_cliente = ftc.codigo and (ff.compania(+) = fcc.compania and ff.anio_cargo(+) = fcc.anio and ff.codigo_cargo(+) = fcc.codigo and ff.tipo_cargo(+) = fcc.tipo_transaccion) and (fdc.compania = fcc.compania and fdc.anio = fcc.anio and fdc.tipo_transaccion = fcc.tipo_transaccion and fdc.cargo = fcc.codigo) and fdc.inv_almacen = i.codigo_almacen and fdc.inv_cod_articulo = i.cod_articulo and fdc.inv_art_familia = i.art_familia and fdc.inv_art_clase = i.art_clase and fdc.compania = i.compania) and (a.compania = i.compania and a.cod_flia = i.art_familia and a.cod_clase = i.art_clase and a.cod_articulo = i.cod_articulo) "+appendFilter2+" and fdc.tipo_servicio = cts.codigo(+) group by ' ', decode(a.consignacion_sino, 'S', 'CONS', fdc.tipo_servicio), decode(a.consignacion_sino, 'S', 'CONSIGNACION', cts.descripcion) UNION select 'DEVOLUCIONES' descripcion, decode(a.consignacion_sino, 'S', 'CONS', fdc.tipo_servicio) tipo_serv, nvl((sum(fdc.monto * fdc.cantidad) * -1), 0) precio_venta_t_s, nvl((sum(decode (fdc.tipo_transaccion, 'D', (i.precio * fdc.cantidad))) * -1), 0) m_costo, decode(a.consignacion_sino, 'S', 'CONSIGNACION', cts.descripcion) tipo_serv_desc from tbl_fac_cargo_cliente fcc, tbl_fac_detc_cliente fdc, tbl_inv_inventario i, tbl_inv_articulo a, tbl_cds_tipo_servicio cts where (fcc.tipo_transaccion = 'D'"+appendFilter+" and (fdc.compania = fcc.compania and fdc.anio = fcc.anio and fdc.tipo_transaccion = fcc.tipo_transaccion and fdc.cargo = fcc.codigo) and fdc.inv_almacen = i.codigo_almacen and fdc.inv_cod_articulo = i.cod_articulo and fdc.inv_art_familia = i.art_familia and fdc.inv_art_clase = i.art_clase and fdc.compania = i.compania) and (a.compania = i.compania and a.cod_flia = i.art_familia and a.cod_clase = i.art_clase and a.cod_articulo = i.cod_articulo) "+appendFilter2+" and fdc.tipo_servicio = cts.codigo(+) group by 'DEVOLUCIONES', decode (a.consignacion_sino, 'S', 'CONS', fdc.tipo_servicio), decode(a.consignacion_sino, 'S', 'CONSIGNACION', cts.descripcion)";

ArrayList alResTS = SQLMgr.getDataList(sql);

sql = "select sum(decode(tipo_serv, 'CONS', 0, precio_venta_t_s)) gran_total_inv, sum(decode(tipo_serv, 'CONS', 0, m_costo)) costo_total_inv, sum(decode(tipo_serv, 'CONS', precio_venta_t_s, 0)) gran_total_cons, sum(decode(tipo_serv, 'CONS', m_costo, 0)) costo_total_cons from ("+sql+")";
CommonDataObject cdoX = SQLMgr.getData(sql);

sql = "select ' ' descripcion, nvl(sum (fcc.itbm), 0) itbm from tbl_fac_factura ff, tbl_fac_tipo_cliente ftc, tbl_fac_cargo_cliente fcc, tbl_fac_detc_cliente fdc, tbl_inv_inventario i, tbl_inv_articulo a, tbl_cds_tipo_servicio cts where ff.facturar_a(+) = 'O' and fcc.tipo_transaccion = 'C' and ff.estatus(+) <> 'A' "+appendFilter+" and (fcc.compania = ftc.compania and fcc.tipo_cliente = ftc.codigo and (ff.compania(+) = fcc.compania and ff.anio_cargo(+) = fcc.anio and ff.codigo_cargo(+) = fcc.codigo and ff.tipo_cargo(+) = fcc.tipo_transaccion) and (fdc.compania = fcc.compania and fdc.anio = fcc.anio and fdc.tipo_transaccion = fcc.tipo_transaccion and fdc.cargo = fcc.codigo) and fdc.inv_almacen = i.codigo_almacen and fdc.inv_cod_articulo = i.cod_articulo and fdc.inv_art_familia = i.art_familia and fdc.inv_art_clase = i.art_clase and fdc.compania = i.compania) and (a.compania = i.compania and a.cod_flia = i.art_familia and a.cod_clase = i.art_clase and a.cod_articulo = i.cod_articulo) "+appendFilter2+" and fdc.tipo_servicio = cts.codigo(+) UNION select 'DEVOLUCIONES' descripcion, nvl(sum (fcc.itbm), 0) itbm from tbl_fac_cargo_cliente fcc, tbl_fac_detc_cliente fdc, tbl_inv_inventario i, tbl_inv_articulo a, tbl_cds_tipo_servicio cts where (fcc.tipo_transaccion = 'D'"+appendFilter+" and (fdc.compania = fcc.compania and fdc.anio = fcc.anio and fdc.tipo_transaccion = fcc.tipo_transaccion and fdc.cargo = fcc.codigo) and fdc.inv_almacen = i.codigo_almacen and fdc.inv_cod_articulo = i.cod_articulo and fdc.inv_art_familia = i.art_familia and fdc.inv_art_clase = i.art_clase and fdc.compania = i.compania) and (a.compania = i.compania and a.cod_flia = i.art_familia and a.cod_clase = i.art_clase and a.cod_articulo = i.cod_articulo) "+appendFilter2+" and fdc.tipo_servicio = cts.codigo(+)";
ArrayList alItbm = SQLMgr.getDataList(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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

	float width = 72 * 8.5f;
	float height = 72 * 11f;
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "Facturacion a Otros Clientes";//
	String subtitle = "Detalle de Ventas Factuardas de ARtículos de Inventario por Almacén";//
	String xtraSubtitle = "ALMACEN:"+cdoAlm.getColValue("descripcion");//"";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".02");
		dHeader.addElement(".03");
		dHeader.addElement(".12");
		dHeader.addElement(".20");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".12");
		dHeader.addElement(".09");
		dHeader.addElement(".12");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable(true);//table name = main
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setTableHeader(1);//create de table header (2 rows) and add header to the table

	//Header color
	Color hColor0 = Color.BLACK;
	Color hColor1 = Color.BLUE;
	Color hColor2 = Color.RED;
	Color hColor3 = Color.GREEN;

	//Header alignment
	int hHAlign0 = 0;
	int hHAlign1 = 1;
	int hHAlign2 = 2;
	//Header Total alignment
	int htHAlign0 = 0;
	int htHAlign1 = 1;
	int htHAlign2 = 2;
	//Header
	String h1 = "";
	String h2 = "";
	String h3 = "";
	String h4 = "";
	//Header counter
	int c1 = 0;
	int c2 = 0;
	int c3 = 0;
	//main table body start
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!h1.equalsIgnoreCase(cdo.getColValue("group1")))
		{
			if (i != 0)
			{
				pc.useTable("header2");
				pc.addTableToCols("header3",0,dHeader.size(),0.0f,null,null,0.0f,0.0f,0.0f,0.0f);

				pc.useTable("header1");
				pc.addTableToCols("header2",0,dHeader.size(),0.0f,null,null,0.0f,0.0f,0.0f,0.0f);

				pc.setFont(7, 1, hColor0);
				pc.addCols("SubTotal x Cliente:",htHAlign0,4);
				pc.setFont(7, 0, hColor0);
				pc.addCols("Trn. x Cliente: "+c2,htHAlign0,1);
				pc.setFont(7, 1, hColor0);
				pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", cdoTxC.getColValue("monto_costo")),htHAlign2,1);
				pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxC.getColValue("subtotal")),htHAlign2,1);
				pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxC.getColValue("itbm")),htHAlign2,1);
				pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxC.getColValue("monto_total")),htHAlign2,1);

				c2 = 0;

				pc.useTable("main");
				pc.addTableToCols("header1",0,dHeader.size(),0.0f,null,null,0.0f,0.0f,0.0f,0.0f);

				pc.setFont(7, 1, hColor0);
				pc.addCols("Totales por Tipo Cliente:",htHAlign0,5);
				pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", cdoTxTC.getColValue("monto_costo")),htHAlign2,1);
				pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxTC.getColValue("subtotal")),htHAlign2,1);
				pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxTC.getColValue("itbm")),htHAlign2,1);
				pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxTC.getColValue("monto_total")),htHAlign2,1);
				c1 = 0;
			}

			//create new subheader
			pc.setNoColumnFixWidth(dHeader);
			pc.createTable("header1",true);
				pc.setFont(7, 1, hColor0);
				pc.addBorderCols("",hHAlign0,9,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols("TIPO DE CLIENTE:  ",hHAlign0,3,0.5f,0.5f,0.0f,0.0f);
				pc.addBorderCols(cdo.getColValue("group1"),hHAlign0,6,0.5f,0.5f,0.0f,0.0f);
			pc.setTableHeader(2);//create de table header 1

			h2 = "";
			if (!h2.equalsIgnoreCase(cdo.getColValue("group2")))
			{
				//create new subheader
				pc.setNoColumnFixWidth(dHeader);
				pc.createTable("header2",true);
					pc.setFont(7, 1, hColor0);
					pc.addBorderCols("",hHAlign0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
					pc.addBorderCols("Cliente: "+cdo.getColValue("group2"),hHAlign0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
				pc.setTableHeader(2);//create de table header 2

				h3 = "";
				if (!h3.equalsIgnoreCase(cdo.getColValue("group3")))
				{
					//create new subheader
					pc.setNoColumnFixWidth(dHeader);
					pc.createTable("header3",true);
						pc.setFont(7, 1, hColor0);
						pc.addBorderCols("",hHAlign0,1,0.0f,0.0f,0.0f,0.0f);
						pc.addBorderCols("",hHAlign0,1,0.0f,0.0f,0.0f,0.0f);
						pc.addBorderCols("FACT./DEV.#: "+cdo.getColValue("factura"),0,7,0.0f,0.0f,0.0f,0.0f);
					pc.setTableHeader(1);//create de table header 3
				}
			}
		}
		else if (!h2.equalsIgnoreCase(cdo.getColValue("group2")))
		{
			pc.useTable("header2");
			pc.addTableToCols("header3",0,dHeader.size(),0.0f,null,null,0.0f,0.0f,0.0f,0.0f);

			pc.useTable("header1");
			pc.addTableToCols("header2",0,dHeader.size(),0.0f,null,null,0.0f,0.0f,0.0f,0.0f);

			pc.setFont(7, 1, hColor0);
			pc.addCols("SubTotal x Cliente:",htHAlign0,4);
			pc.setFont(7, 0, hColor0);
			pc.addCols("Trn. x Cliente: "+c2,htHAlign0,1);
			pc.setFont(7, 1, hColor0);
			pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", cdoTxC.getColValue("monto_costo")),htHAlign2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxC.getColValue("subtotal")),htHAlign2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxC.getColValue("itbm")),htHAlign2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxC.getColValue("monto_total")),htHAlign2,1);
			c2 = 0;

			//create new subheader
			pc.setNoColumnFixWidth(dHeader);
			pc.createTable("header2",true);
				pc.setFont(7, 1, hColor0);
				pc.addBorderCols("",hHAlign0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols("Cliente: "+cdo.getColValue("group2"),hHAlign0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
			pc.setTableHeader(2);//create de table header 2

			h3 = "";
			if (!h3.equalsIgnoreCase(cdo.getColValue("group3")))
			{
				//create new subheader
				pc.setNoColumnFixWidth(dHeader);
				pc.createTable("header3",true);
					pc.setFont(7, 1, hColor0);
					pc.addBorderCols("",hHAlign0,1,0.0f,0.0f,0.0f,0.0f);
					pc.addBorderCols("",hHAlign0,1,0.0f,0.0f,0.0f,0.0f);
					pc.addBorderCols("FACT./DEV.#: "+cdo.getColValue("factura"),0,7,0.0f,0.0f,0.0f,0.0f);
				pc.setTableHeader(1);//create de table header 3
			}
		}
		else if (!h3.equalsIgnoreCase(cdo.getColValue("group3")))
		{
			pc.useTable("header2");
			pc.addTableToCols("header3",0,dHeader.size(),0.0f,null,null,0.0f,0.0f,0.0f,0.0f);
			c3 = 0;

			//create new subheader
			pc.setNoColumnFixWidth(dHeader);
			pc.createTable("header3",true);
				pc.setFont(7, 1, hColor0);
				pc.addBorderCols("",hHAlign0,1,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",hHAlign0,1,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols("FACT./DEV.#: "+cdo.getColValue("factura"),0,7,0.0f,0.0f,0.0f,0.0f);
			pc.setTableHeader(1);//create de table (tipo) subheader (1 row) and add subheader to the table (tipo)
		}

		pc.useTable("header3");
		pc.setFont(7, 0);
		pc.setVAlignment(0);

		pc.addCols("",0,1);
		pc.addCols("",0,1);
		pc.addCols("Fecha",1,1);
		pc.addCols("Tipo de Trn.",1,1);
		pc.addCols("Trn. #",1,1);
		pc.addCols("Costo Total",1,1);
		pc.addCols("Subtotal",1,1);
		pc.addCols("Itbm",1,1);
		pc.addCols("Monto Total",1,1);

		pc.addCols("",0,1);
		pc.addCols("",0,1);
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.setFont(7, 1);
		pc.addCols(cdo.getColValue("tipo_trn"),1,1);
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("group3"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", cdo.getColValue("monto_costo")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdo.getColValue("subtotal")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdo.getColValue("itbm")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdo.getColValue("monto_total")),2,1);


		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("D e t a l l e   d e   l a   T r a n s a c c i ó n",0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("P. de Venta",1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("Monto (Costo)",1,1,0.5f,0.0f,0.0f,0.0f);

		ArrayList x = (ArrayList) htDet.get(cdo.getColValue("key"));
		double pVenta = 0.00, costo = 0.00;
		if(x!=null){
			for(int k=0;k<x.size(); k++){
				CommonDataObject xDet = (CommonDataObject) x.get(k);
				pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols(xDet.getColValue("tipo_serv"),1,1,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols(xDet.getColValue("tipo_serv_desc"),0,3,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", xDet.getColValue("precio_venta_t_s")),2,1,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",1,1,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", xDet.getColValue("m_costo")),2,1,0.0f,0.0f,0.0f,0.0f);
				pVenta += Double.parseDouble(xDet.getColValue("precio_venta_t_s"));
				costo += Double.parseDouble(xDet.getColValue("m_costo"));
			}
		}

		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("T o t a l   e n   D e t a l l e : . . . . . . . . . . .",0,4,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", pVenta),2,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", costo),2,1,0.5f,0.0f,0.0f,0.0f);
		pVenta = 0.00;
		costo = 0.00;


		h1 = cdo.getColValue("group1");
		h2 = cdo.getColValue("group2");
		h3 = cdo.getColValue("group3");
		cdoTxC = (CommonDataObject) htSTot.get(h2);
		cdoTxTC = (CommonDataObject) htTot.get(h1);
		c1++;
		c2++;
		c3++;
	}
	if (al.size() > 0)
	{
		pc.useTable("header2");
		pc.addTableToCols("header3",0,dHeader.size(),0.0f,null,null,0.0f,0.0f,0.0f,0.0f);

		pc.useTable("header1");
		pc.addTableToCols("header2",0,dHeader.size(),0.0f,null,null,0.0f,0.0f,0.0f,0.0f);

		pc.setFont(7, 1, hColor0);
		pc.addCols("SubTotal x Cliente:",htHAlign0,4);
		pc.setFont(7, 0, hColor0);
		pc.addCols("Trn. x Cliente: "+c2,htHAlign0,1);
		pc.setFont(7, 1, hColor0);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", cdoTxC.getColValue("monto_costo")),htHAlign2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxC.getColValue("subtotal")),htHAlign2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxC.getColValue("itbm")),htHAlign2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxC.getColValue("monto_total")),htHAlign2,1);

		c2 = 0;

		pc.useTable("main");
		pc.addTableToCols("header1",0,dHeader.size(),0.0f,null,null,0.0f,0.0f,0.0f,0.0f);

		pc.setFont(7, 1, hColor0);
		pc.addCols("Totales por Tipo Cliente:",htHAlign0,5);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", cdoTxTC.getColValue("monto_costo")),htHAlign2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxTC.getColValue("subtotal")),htHAlign2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxTC.getColValue("itbm")),htHAlign2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTxTC.getColValue("monto_total")),htHAlign2,1);

		pc.setFont(7, 1, hColor0);
		pc.addBorderCols("Totales Finales por Reporte:. . . . . . . . . . . .",htHAlign0,5,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", cdoTotF.getColValue("monto_costo")),htHAlign2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTotF.getColValue("subtotal")),htHAlign2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTotF.getColValue("itbm")),htHAlign2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoTotF.getColValue("monto_total")),htHAlign2,1,0.0f,0.5f,0.0f,0.0f);
		c1 = 0;

		pc.setFont(7, 0, hColor0);
		pc.addBorderCols("",0,9,0.0f,0.0f,0.0f,0.0f);

		pc.addBorderCols("RESUMEN POR TIPO DE SERVICIO",0,6,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("GRAN TOTAL",1,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("GRAN TOT. (COSTO)",1,2,0.5f,0.0f,0.0f,0.0f);

		for(int i=0;i<alResTS.size();i++){
			CommonDataObject cdoDet = (CommonDataObject) alResTS.get(i);

			pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdoDet.getColValue("tipo_serv")+ "   " + cdoDet.getColValue("tipo_serv_desc"),0,2,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdoDet.getColValue("descripcion"),0,2,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoDet.getColValue("precio_venta_t_s")),htHAlign2,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", cdoDet.getColValue("m_costo")),htHAlign2,2,0.0f,0.0f,0.0f,0.0f);

		}


		pc.addBorderCols("",0,1,0.0f,0.50f,0.0f,0.0f);
		pc.addBorderCols("",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Total Inventario .  .  .  .  .  .",0,4,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoX.getColValue("gran_total_inv")),htHAlign2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", cdoX.getColValue("costo_total_inv")),htHAlign2,2,0.0f,0.5f,0.0f,0.0f);

		pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("Total Consignación .  .  .  .  .  .",0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoX.getColValue("gran_total_cons")),htHAlign2,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", cdoX.getColValue("costo_total_cons")),htHAlign2,2,0.5f,0.0f,0.0f,0.0f);

		double totInv = Double.parseDouble(cdoX.getColValue("gran_total_inv")) - Double.parseDouble(cdoX.getColValue("gran_total_cons"));
		double totCons = Double.parseDouble(cdoX.getColValue("costo_total_inv")) - Double.parseDouble(cdoX.getColValue("costo_total_cons"));
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("SUB TOTAL DE TIPOS DE SERVICIOS:",0,4,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", totInv),htHAlign2,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.0000", totCons),htHAlign2,2,0.0f,0.0f,0.0f,0.0f);

		double itbm = 0.00;
		for(int i=0;i<alItbm.size();i++){
			CommonDataObject cdoDet = (CommonDataObject) alItbm.get(i);

			pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols("I.T.B.M. ",0,2,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdoDet.getColValue("descripcion"),0,2,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", cdoDet.getColValue("itbm")),htHAlign2,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",htHAlign2,2,0.0f,0.0f,0.0f,0.0f);
			itbm+=Double.parseDouble(cdoDet.getColValue("itbm"));
		}

		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("SUB TOTAL DE I.T.B.M.",1,4,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", itbm),htHAlign2,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",htHAlign2,2,0.0f,0.0f,0.0f,0.0f);

		pc.setFont(7, 1, hColor0);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("GRAN TOTAL DE VENTAS .   .   .   .   .   .   .   .   .",1,4,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00", (totInv+itbm)),htHAlign2,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",htHAlign2,2,0.0f,0.0f,0.0f,0.0f);

	} else {
		pc.addBorderCols("La datos de la consulta no generan información",htHAlign1,9,0.0f,0.0f,0.0f,0.0f);
	}
	pc.useTable("main");
	pc.flushTableBody(true);
	pc.close();
	//main table body end
	response.sendRedirect(redirectFile);
}//get
%>