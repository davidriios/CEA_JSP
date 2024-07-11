<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");


String titulo = request.getParameter("titulo");
String depto = request.getParameter("depto");

if (titulo == null) titulo = "KARDEX";
if (depto == null) depto = "INVENTARIO";

String art_familia = "";
String art_clase = "";
String cod_articulo = "";
String descripcion = "";
String almacen = "";
String fDate = "";
String tDate = "",consignacion="";
String flia_kardex = "";
String ver_art_sin_mov = "S";
if(request.getParameter("art_familia")!=null) art_familia = request.getParameter("art_familia");
if(request.getParameter("art_clase")!=null) art_clase = request.getParameter("art_clase");
if(request.getParameter("cod_articulo")!=null) cod_articulo = request.getParameter("cod_articulo");
if(request.getParameter("descripcion")!=null) descripcion = request.getParameter("descripcion");
if(request.getParameter("almacen")!=null) almacen = request.getParameter("almacen");
if(request.getParameter("fDate")!=null) fDate = request.getParameter("fDate");
if(request.getParameter("tDate")!=null) tDate = request.getParameter("tDate");
if(request.getParameter("consignacion")!=null) consignacion = request.getParameter("consignacion");
if(request.getParameter("flia_kardex")!=null) flia_kardex = request.getParameter("flia_kardex");
if(request.getParameter("ver_art_sin_mov")!=null) ver_art_sin_mov = request.getParameter("ver_art_sin_mov");
	sbSql.append("select a.compania, a.codigo_almacen, a.cod_familia, a.cod_clase, a.cod_articulo, a.descripcion, a.saldo_inicial + qty_prev saldo_inicial, a.qty_in, a.qty_out, a.qty_aju, (a.saldo_inicial + a.qty_prev + a.qty_in - a.qty_out + a.qty_aju) saldo, (select descripcion from tbl_inv_almacen ia where ia.compania = a.compania and ia.codigo_almacen = a.codigo_almacen) almacen_desc from (select compania, codigo_almacen,");
	 
	   if(flia_kardex.equalsIgnoreCase("TRX"))sbSql.append(" a.cod_familia, a.cod_clase,");
	   else sbSql.append(" a.flia_art as cod_familia, a.clase_art as cod_clase,");
	
	    sbSql.append(" cod_articulo, descripcion, saldo_inicial, sum(case when trunc(fecha_docto) < to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy') then qty_in - qty_out + qty_aju else 0 end) qty_prev, sum(case when trunc(fecha_docto) between to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy') and to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy') then qty_in else 0 end) qty_in, sum(case when trunc(fecha_docto) between to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy') and to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy') then qty_out else 0 end) qty_out, sum(case when trunc(fecha_docto) between to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy') and to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy') then qty_aju else 0 end) qty_aju from vw_inv_mov_item a where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
if (!consignacion.equals("")){
		sbSql.append(" and a.consignacion = '");
		sbSql.append(consignacion); 
		sbSql.append("'"); 
	}
	sbSql.append(" group by compania, codigo_almacen,");
	 
	   if(flia_kardex.equalsIgnoreCase("TRX"))sbSql.append(" a.cod_familia, a.cod_clase,");
	   else sbSql.append(" a.flia_art, a.clase_art,");
	
	    sbSql.append(" cod_articulo, descripcion, saldo_inicial) a where a.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if (!art_familia.equals("")){
		sbSql.append(" and a.cod_familia = ");
		sbSql.append(art_familia);
	}
	if (!art_clase.equals("")){
		sbSql.append(" and a.cod_clase = ");
		sbSql.append(art_clase);
	}
	if (!cod_articulo.equals("")){
		sbSql.append(" and a.cod_articulo = ");
		sbSql.append(cod_articulo);
	}
	if (!descripcion.equals("")){
		sbSql.append(" and a.descripcion like '%");
		sbSql.append(descripcion.toUpperCase());
		sbSql.append("%'");
	}
	if (!almacen.equals("")){
		sbSql.append(" and a.codigo_almacen = ");
		sbSql.append(almacen);
	}
	if(ver_art_sin_mov.equals("S")){
		sbSql.append(" and ( saldo_inicial + qty_prev != 0 or qty_in != 0 or qty_aju != 0 or qty_out != 0)");
	}
	if (request.getParameter("barcode") != null && !request.getParameter("barcode").equals(""))
	{
		String barcode = request.getParameter("barcode");
		sbSql.append(" and exists (select null from tbl_inv_articulo ar where ar.compania = a.compania and ar.cod_articulo = a.cod_articulo and ar.tipo !='A' and ar.cod_barra = '");
		sbSql.append(IBIZEscapeChars.forSingleQuots(barcode).trim());
		sbSql.append("')");
	}
	sbSql.append(" order by a.codigo_almacen, a.descripcion");
	
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
	String title = titulo+" [ " + fDate + " - " + tDate + " ]";
	String subtitle = "";
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
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".40");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		//second row
		pc.setFont(7,1);
		pc.addBorderCols("FLIA.",1);
		pc.addBorderCols("CLASE",1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESCRIPCION",1);
		pc.addBorderCols("SALDO INI.",1);
		pc.addBorderCols("CANT. ENTRADA",1);
		pc.addBorderCols("CANT. SALIDA",1);
		pc.addBorderCols("CANT. AJUSTE",1);
		pc.addBorderCols("SALDO",1);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	String wh = "", groupBy = "",subGroupBy = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if (!wh.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
		{
			pc.setFont(7, 1);
			pc.addBorderCols(" "+cdo.getColValue("almacen_desc"),0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,0.0f);
		}

		pc.setFont(7,0);
		pc.setVAlignment(0);
		pc.addCols(""+cdo.getColValue("cod_familia"),1,1);
		pc.addCols(""+cdo.getColValue("cod_clase"),1,1);
		pc.addCols(""+cdo.getColValue("cod_articulo"),1,1);
		pc.addCols(""+cdo.getColValue("descripcion"),0,1);
		pc.addCols(""+cdo.getColValue("saldo_inicial"),0,1);
		pc.addCols(""+cdo.getColValue("qty_in"),0,1);
		pc.addCols(""+cdo.getColValue("qty_out"),0,1);
		pc.addCols(""+cdo.getColValue("qty_aju"),0,1);
		pc.addCols(""+cdo.getColValue("saldo"),0,1);
		
		wh = cdo.getColValue("codigo_almacen");


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>