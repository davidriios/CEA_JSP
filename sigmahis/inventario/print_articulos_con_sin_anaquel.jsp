<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fp = request.getParameter("fp");
String compania = request.getParameter("compania");
String almacen = request.getParameter("almacen");
String consignacion = request.getParameter("consignacion");
String status = request.getParameter("status")==null?"":request.getParameter("status");

if (appendFilter == null) appendFilter = "";
if (fp == null) fp = "";
if (compania == null) throw new Exception("La Compañía no es válida. Por favor intente nuevamente!");
if (almacen == null) throw new Exception("El Almacén no es válido. Por favor intente nuevamente!");
if (consignacion == null) consignacion = "";

if(!status.trim().equals("")) appendFilter  += " and a.estado ='"+status+"'";

if (fp.equalsIgnoreCase("SACE"))  appendFilter += " and i.codigo_anaquel is null and nvl(i.disponible,0) > 0";
if (fp.equalsIgnoreCase("SASE"))  appendFilter += " and i.codigo_anaquel is null and nvl(i.disponible,0) <= 0";
if (fp.equalsIgnoreCase("CSACE")) appendFilter += " and nvl(i.disponible,0) > 0";

sbSql.append("select i.codigo_almacen as cod_almacen, al.descripcion as desc_almacen, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as codigo, a.descripcion as articulo, a.cod_medida, i.codigo_anaquel anaquel, i.disponible, a.cod_barra from tbl_inv_almacen al, tbl_inv_inventario i, tbl_inv_articulo a where (i.compania=al.compania and i.codigo_almacen=al.codigo_almacen) and (i.compania=a.compania and i.cod_articulo=a.cod_articulo) /*and a.estado = 'A'*/ and i.codigo_almacen="+almacen+" and i.compania=");
sbSql.append(compania);
sbSql.append(appendFilter);
if(!consignacion.equals("")){
sbSql.append(" and a.consignacion_sino = '");
sbSql.append(consignacion);
sbSql.append("'");
}
sbSql.append(" order by a.descripcion");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String subtitle = "ARTICULOS CON Y SIN ANAQUEL";
    
    if (fp.trim().equalsIgnoreCase("SASE")) subtitle = "ARTICULOS SIN ANAQUEL Y SIN EXISTENCIA";
    else if (fp.trim().equalsIgnoreCase("SACE")) subtitle = "ARTICULOS SIN ANAQUEL Y CON EXISTENCIA";
    
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".18");
		dHeader.addElement(".40");
		dHeader.addElement(".10");
		dHeader.addElement(".08");
		dHeader.addElement(".09");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row

		pc.setFont(fontSize,1);
		pc.addBorderCols("Còdigo ", 0,1);
		pc.addBorderCols("Cod. Barra", 0,1);
		pc.addBorderCols("Descripciòn ", 0,1);
		pc.addBorderCols("UND", 0,1);
		pc.addBorderCols("Cantidad", 2,1);
		pc.addBorderCols("Anaquel", 1,1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	String groupBy = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		if (!groupBy.equalsIgnoreCase(cdo1.getColValue("cod_almacen")))
		{
				pc.setFont(7, 1,Color.blue);
				pc.addCols(""+cdo1.getColValue("desc_almacen"),0,dHeader.size());
		}
		pc.setFont(fontSize-1,0);
		pc.setVAlignment(0);
		pc.addCols(" "+cdo1.getColValue("codigo"), 0,1);
		pc.addCols(" "+cdo1.getColValue("cod_barra"), 0,1);
		pc.addCols(" "+cdo1.getColValue("articulo"), 0,1);
		pc.addCols(" "+cdo1.getColValue("cod_medida"), 0,1);
		pc.addCols(" "+cdo1.getColValue("disponible"), 2,1);
		pc.addCols(" "+cdo1.getColValue("anaquel"), 1,1);
		groupBy = cdo1.getColValue("cod_almacen");
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registros en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>