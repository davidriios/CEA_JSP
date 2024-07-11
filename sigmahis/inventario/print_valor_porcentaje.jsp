<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
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
		REPORTE:		INV00120.RDF   VALOR DEL PORCENTAGE DE GANANCIA.
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
ArrayList alTotal = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String compania  = (String) session.getAttribute("_companyId");
String rango_ini = request.getParameter("rango_ini");
String rango_fin = request.getParameter("rango_fin");
String titulo    = request.getParameter("titulo");
String familia   = request.getParameter("familia");
String almacen   = request.getParameter("almacen");
String filter = "";
if (appendFilter == null)  appendFilter="";
if(rango_ini == null) rango_ini = "";
if(rango_fin == null) rango_fin = "";
if(titulo    == null) titulo = "";
if(familia   == null) familia = "";
if(almacen   == null) almacen = "";

if(!almacen.trim().equals("")) appendFilter  = " and  i.codigo_almacen = "+almacen;
if(!familia.trim().equals("")) appendFilter += " and ar.cod_flia = "+familia;

if(!rango_ini.trim().equals("") && !rango_fin.trim().equals("")) filter += " where x.porcentaje >= "+rango_ini+" and x.porcentaje <= "+rango_fin+" ";

sql = " select x.* ,(select descripcion from tbl_inv_almacen where codigo_almacen = x.codigo_almacen and compania = 1 and rownum = 1) as almacen_desc,(select nombre from tbl_inv_familia_articulo where cod_flia = x.art_familia and compania = 1 and rownum = 1) as familia_desc from ( select  distinct ar.cod_flia||'-'||ar.cod_clase||'-'||ar.cod_articulo cod_articulo , ar.descripcion desc_articulo , nvl(i.precio,0) costo , nvl(ar.precio_venta,0) precio_venta , (((nvl(ar.precio_venta,0) -  nvl(i.precio,0)) * 100) / nvl(decode(i.precio,0,1,i.precio),1) ) porcentaje , min(i.codigo_almacen) codigo_almacen, i.art_familia from tbl_inv_articulo ar , tbl_inv_inventario i where (ar.venta_sino =  'S' and  ar.estado = 'A') and i.compania = "+compania+appendFilter +"  and (i.compania = ar.compania and  i.art_familia = ar.cod_flia and  i.art_clase = ar.cod_clase and  i.cod_articulo = ar.cod_articulo) group by ar.cod_flia||'-'||ar.cod_clase||'-'||ar.cod_articulo, ar.descripcion, nvl(i.precio,0) , nvl(ar.precio_venta,0), ( ((nvl(ar.precio_venta,0) - nvl(i.precio,0)) * 100) / nvl(decode(i.precio,0,1,i.precio),1) ), i.art_familia order by 2 ) x "+filter+" order by 6,7, x.desc_articulo";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String fotosFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	
	float width = 72* 8.5f;//612
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
	String subTitle = "VALOR DEL PORCENTAJE DE GANANCIA ENTRE EL PRECIO Y EL COSTO";
	String xtraSubtitle = titulo;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	Vector setDetail = new Vector();
	setDetail.addElement(".10");
	setDetail.addElement(".60");
	setDetail.addElement(".10");
	setDetail.addElement(".10");
	setDetail.addElement(".10");
	
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, setDetail.size());
	
	pc.setFont(7, 1);
	pc.addBorderCols("CODIGO",1,1);
	pc.addBorderCols("DESC. ARTICULO",0,1);
	pc.addBorderCols("COSTO",2,1);
	pc.addBorderCols("PRECIO",2,1);
	pc.addBorderCols("%",2,1);
	
	pc.setTableHeader(2);

	String gAlmacen = "", gFamilia = "";

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		pc.setFont(8, 1);
		
	    if (!gAlmacen.equals(cdo.getColValue("codigo_almacen"))){
		  pc.addCols("["+cdo.getColValue("codigo_almacen")+"] "+cdo.getColValue("almacen_desc"),0,setDetail.size());
	    }
		
		if (!gFamilia.equals(cdo.getColValue("art_familia"))){
		  pc.addCols("["+cdo.getColValue("art_familia")+"] "+cdo.getColValue("familia_desc"),0,setDetail.size());
		}
		
		pc.setFont(7, 0);
		pc.addCols(""+cdo.getColValue("cod_articulo"),1,1,cHeight);
		pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
		pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("costo")),2,1,cHeight);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("precio_venta")),2,1,cHeight);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("porcentaje")),2,1,cHeight);

		gAlmacen = cdo.getColValue("codigo_almacen");
		gFamilia = cdo.getColValue("art_familia");

	}//for i

	if (al.size() == 0){
		pc.addCols("No existen registros",1,setDetail.size());
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>