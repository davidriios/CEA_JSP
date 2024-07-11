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
String almacen = request.getParameter("almacen");
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String subclase =  request.getParameter("subclase");
String articulo = request.getParameter("articulo");
String tipo = request.getParameter("tipo");

String titulo = request.getParameter("titulo");
String depto = request.getParameter("depto");
String afectaConta = request.getParameter("afectaConta");
String afectaInv = request.getParameter("afectaInv");

if (titulo == null) titulo = "LISTADO DE ARTICULOS";
if (depto == null) depto = "INVENTARIO";

if (almacen == null) almacen = "";
if (familyCode == null) familyCode = "";
if (classCode == null) classCode = "";
if(subclase == null )   subclase = "";
if(appendFilter == null )   appendFilter = "";
if (afectaConta == null) afectaConta = "";
if (afectaInv == null) afectaInv = "";

if (!almacen.trim().equals(""))    appendFilter += " and i.codigo_almacen="+almacen;
if (!familyCode.trim().equals("")) appendFilter += " and ar.cod_flia="+familyCode;
if (!classCode.trim().equals(""))  appendFilter += " and ar.cod_clase="+classCode;
if(!subclase.trim().equals(""))    appendFilter += " and ar.cod_subclase ="+subclase;
if (!articulo.trim().equals(""))   appendFilter += " and ar.cod_articulo="+articulo;
if (!tipo.trim().equals(""))       appendFilter += " and ar.tipo='"+tipo+"'";
if (!afectaInv.trim().equals(""))       appendFilter += " and ar.other3='"+afectaInv+"'";
if (!afectaConta.trim().equals(""))       appendFilter += " and ar.other4='"+afectaConta+"'";
	sbSql.append("select al.codigo_almacen, al.descripcion desc_almacen, ar.cod_flia, al.codigo_almacen||'-'||ar.cod_flia key , (select fa.nombre from tbl_inv_familia_articulo fa where fa.compania = ar.compania and fa.cod_flia = ar.cod_flia ) desc_familia, ar.cod_clase, (select ca.descripcion from tbl_inv_clase_articulo ca where ca.compania = ar.compania and ca.cod_flia = ar.cod_flia and ca.cod_clase = ar.cod_clase)desc_clase, ar.cod_articulo, lpad(ar.cod_flia,3,0)||'-'||lpad(ar.cod_clase,3,0)||'-'||lpad(ar.cod_articulo,10,0) codigo_articulo, ar.descripcion desc_articulo, nvl(i.disponible,0) existencia, nvl(i.precio,0) costo, nvl(i.ultimo_precio,0) ultimo_costo, nvl(i.disponible,0)*nvl( i.precio,0)total_articulo from tbl_inv_inventario i, tbl_inv_articulo ar, tbl_inv_almacen al where ((i.compania = ar.compania and i.cod_articulo = ar.cod_articulo)  and (i.compania = al.compania and i.codigo_almacen  = al.codigo_almacen)) and ar.estado = 'A' and i.compania = ");
	sbSql.append(compania);
	sbSql.append(appendFilter);
	sbSql.append("  order by al.descripcion,5,7,ar.descripcion ");
al = SQLMgr.getDataList(sbSql.toString());

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
	String title = ""+depto;
	String subtitle = ""+titulo;
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
		dHeader.addElement(".80");
		dHeader.addElement(".20");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		//second row
		pc.setFont(fontSize,1);
		pc.addBorderCols("DESC. ARTICULO",0);
		pc.addBorderCols("CODIGO",0);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	String wh = "", groupBy = "",subGroupBy = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if (!wh.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
		{
			pc.setFont(7, 1);
			pc.addCols(" "+cdo.getColValue("desc_almacen"),2,dHeader.size());
		}
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("key")))
		{
			pc.setFont(7, 1,Color.blue);
			pc.addCols(" "+cdo.getColValue("desc_familia"),0,2);
		}
		if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_clase")+"-"+cdo.getColValue("key")))
		{
			pc.setFont(7, 1,Color.red);
			pc.addBorderCols(" "+cdo.getColValue("desc_clase"),0,2, 0.5f, 0.0f, 0.0f, 0.0f);
		}

		pc.setFont(fontSize-1,0);
		pc.setVAlignment(0);
		pc.addCols(""+cdo.getColValue("desc_articulo"),0,1);
		pc.addCols(""+cdo.getColValue("codigo_articulo"),0,1);
		
		wh = cdo.getColValue("codigo_almacen");
		groupBy  = cdo.getColValue("key");
		subGroupBy = cdo.getColValue("cod_clase")+"-"+cdo.getColValue("key");


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>