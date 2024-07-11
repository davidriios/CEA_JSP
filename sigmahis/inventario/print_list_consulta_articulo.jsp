<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Properties"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
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

if (appendFilter == null) appendFilter = "";

sql = "select i.art_familia cod_familia, i.art_clase cod_clase, i.cod_articulo, nvl(a.descripcion,' ') desArticulo, al.descripcion descAlmacen, i.codigo_almacen, nvl(i.disponible,0) disponible, nvl(i.pto_reorden,0) pto_reorden, nvl(i.pto_max_existencia,0) pto_max_existencia, nvl(i.ultimo_precio,0) ultimo_precio, to_char(i.ultima_compra, 'dd/mm/yyyy') ultimo_compra, nvl(i.precio,0)precio, nvl((select codigo||' - '||descripcion from tbl_inv_anaqueles_x_almacen where compania = i.compania and codigo_almacen = i.codigo_almacen and codigo = i.codigo_anaquel),'- SIN ANAQUEL -') codigo_anaquel, nvl(i.descuento,0) descuento, nvl(i.porcentaje,0) porcentaje, nvl(i.costo_por_almacen,0) costo_x_almacen, nvl(i.saldo_activo,0) saldo_activo, nvl(i.reservado,0) reservado, nvl(i.transito,0) transito, nvl(i.disp_ant_pamd,0) disp_ant_pamd, nvl(i.rebajado,' ') rebajado, nvl(a.precio_venta,0) precio_venta, nvl(a.precio_venta_cr,0) precio_venta_cr from tbl_inv_inventario i, tbl_inv_articulo a, tbl_inv_almacen al where i.cod_articulo = a.cod_articulo(+) and i.compania = a.compania(+) and i.COMPANIA = "+(String) session.getAttribute("_companyId")+"and i.codigo_almacen = al.codigo_almacen(+) and i.compania = al.compania(+) "+appendFilter +" order by i.codigo_almacen,i.art_familia, i.art_clase,i.cod_articulo asc";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = cDateTime;
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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
	String title = "INVENTARIO";
	String subtitle = "ARTICULOS EN INVENTARIO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
		//float cHeight = 12.0f;


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".05");
		dHeader.addElement(".04");
		dHeader.addElement(".07");
		dHeader.addElement(".25");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".17");
		dHeader.addElement(".06");
		dHeader.addElement(".07");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".05");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	//second row
	pc.setFont(7, 1);
		pc.addBorderCols("Familia",1);
		pc.addBorderCols("Clase",1);
		pc.addBorderCols("Articulo",1);
		pc.addBorderCols("Descripción",0);
		pc.addBorderCols("Dispo.",1);
		pc.addBorderCols("Pto. Reorden",1);
		pc.addBorderCols("Ubicación",1);
		pc.addBorderCols("Exist. Maxima",1);
		pc.addBorderCols("C. Promedio",1);
		pc.addBorderCols("Precio Venta",1);
		pc.addBorderCols("U. Precio",1);
		pc.addBorderCols("Precio Venta Cr",1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	String wh = "", groupBy = "",subGroupBy = "";
	double totMontoFac = 0.0, subTotal = 0.00, totItbm = 0.0, subTotalItbm = 0.00;

	String tipo = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setVAlignment(0);
		if(!groupBy.equals(cdo.getColValue("descAlmacen"))){
			pc.setFont(8, 1);
			pc.addBorderCols(cdo.getColValue("descAlmacen"),0,dHeader.size(),0.5f,0.5f,0.0f,0.0f);
		}
		pc.setFont(6, 0);
		pc.addCols(cdo.getColValue("cod_familia"),1,1);
		pc.addCols(cdo.getColValue("cod_clase"),1,1);
		pc.addCols(cdo.getColValue("cod_articulo"),1,1);
		pc.addCols(cdo.getColValue("desArticulo"),0,1);
		pc.addCols(cdo.getColValue("disponible"),2,1);
		pc.addCols(cdo.getColValue("pto_reorden"),2,1);
		pc.addCols(cdo.getColValue("codigo_anaquel"),0,1);
		pc.addCols(cdo.getColValue("pto_max_existencia"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("precio")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("precio_venta")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("ultimo_precio")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("precio_venta_cr")),2,1);

		groupBy=cdo.getColValue("descAlmacen");
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.setFont(7, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>