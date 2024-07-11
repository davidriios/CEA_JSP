<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
StringBuffer sbAppFilter = new StringBuffer();
StringBuffer sbSqlX = new StringBuffer();
StringBuffer sbSqlFinal = new StringBuffer();

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String almacen = request.getParameter("almacen");
String fg = request.getParameter("fg");
String compania     = (String) session.getAttribute("_companyId");
String familia   = request.getParameter("familia");
String clase = request.getParameter("clase");
String codigo  = request.getParameter("codigo");
String operador   = request.getParameter("operador");
String variacion = request.getParameter("variacion");



if (almacen == null) almacen = "";
if (familia == null) familia = "";
if (clase == null) clase = "";
if (codigo == null) codigo = "";
if (operador == null) operador = "";
if (variacion == null) variacion = "";

if (!almacen.trim().equals("")){
	sbAppFilter.append(" and i.codigo_almacen = ");
	sbAppFilter.append(almacen);
}
if (!familia.trim().equals("")){
	sbAppFilter.append(" and i.art_familia = ");
	sbAppFilter.append(familia);
}
if (!clase.trim().equals("")){
	sbAppFilter.append(" and i.art_clase = ");
	sbAppFilter.append(clase);
}
if (!codigo.trim().equals("")){
	sbAppFilter.append(" and i.cod_articulo  = ");
	sbAppFilter.append(codigo);
}

sbSql.append("select descripcion from tbl_inv_almacen where compania = ");
sbSql.append(compania);
sbSql.append(" and codigo_almacen = ");
sbSql.append(almacen);

CommonDataObject cdoA = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();

sbSql.append("select i.art_familia||'-'||i.art_clase||'-'||i.cod_articulo as codigo_articulo, (select descripcion from tbl_inv_articulo where compania = i.compania and cod_articulo = i.cod_articulo) as desc_articulo, i.precio costo_prom, (select descripcion from tbl_inv_almacen where compania = i.compania and codigo_almacen = i.codigo_almacen) as desc_almacen, i.codigo_almacen, nvl(getPrecioInicial(i.compania,i.codigo_almacen,i.cod_articulo),0) as precio_inicial from tbl_inv_inventario i where i.compania = ");
sbSql.append(compania);
sbSql.append(sbAppFilter.toString());
sbSql.append(" order by 2");
sbSqlX.append("select a.*, ((costo_prom - precio_inicial) / precio_inicial) * 100 as variacion from (");
sbSqlX.append(sbSql.toString());
sbSqlX.append(") a where precio_inicial != 0");
sbSqlFinal.append("select * from (");
sbSqlFinal.append(sbSqlX.toString());
sbSqlFinal.append(") ");
if(operador.equals("L")) sbSqlFinal.append(" where variacion < ");	
else if(operador.equals("E")) sbSqlFinal.append(" where variacion = ");	
else if(operador.equals("M")) sbSqlFinal.append(" where variacion > ");	
sbSqlFinal.append(variacion);
al = SQLMgr.getDataList(sbSqlFinal.toString());

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
	String title = "VARIACION DE COSTO PROMEDIO";
	String subtitle = cdoA.getColValue("descripcion");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".11");
		dHeader.addElement(".50");
		//dHeader.addElement(".20");
		dHeader.addElement(".13");
		dHeader.addElement(".13");
		dHeader.addElement(".13");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Codigo",1);
		pc.addBorderCols("Descripción",0);
		//pc.addBorderCols("Almacen",0);
		pc.addBorderCols("Precio Inicial",1);
		pc.addBorderCols("Costo Promedio",1);
		pc.addBorderCols("Variacion",1);
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	String groupBy = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(""+cdo.getColValue("codigo_articulo"),0,1);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1);
			//pc.addCols(" "+cdo.getColValue("desc_almacen"),0,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,###.000000", cdo.getColValue("precio_inicial")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,###.000000", cdo.getColValue("costo_prom")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,###.000000", cdo.getColValue("variacion")),2,1);
			
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>