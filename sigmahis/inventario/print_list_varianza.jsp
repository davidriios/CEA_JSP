<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
==============================================================================
		REPORTE:		INV00124.RDF   VARIANZA EN COMPRA DE ARTICULOS
==============================================================================
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
CommonDataObject cdo1 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
String compania  = (String) session.getAttribute("_companyId");
String porcentaje = request.getParameter("porcentaje");
String condicion = request.getParameter("condicion");

String filter = "";
if (appendFilter == null)  appendFilter="";
if (porcentaje == null)  porcentaje="50";
if (condicion == null)  condicion="";

//sql = " select a.cod_familia ,a.cod_clase,a.cod_articulo, a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo cod_art, ar.descripcion, nvl(i.precio,'0.00') costo_inv, nvl(a.precio,'0.00') costo_recep, to_char(b.fecha_documento,'dd/mm/yyyy') as fecha, a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo||i.precio as llave from tbl_inv_detalle_recepcion a, tbl_inv_recepcion_material b, tbl_inv_inventario i, tbl_inv_articulo ar, tbl_inv_clase_articulo ca, tbl_inv_familia_articulo fa  where fa.tipo_servicio in (02, 03, 04) and a.precio > 0 and i.precio > 0  and  to_date(to_char(b.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') > to_date('01/01/2001' ,'dd/mm/yyyy') and b.estado = 'R' and (a.precio >= i.precio + i.precio/2 or  a.precio <= i.precio - i.precio/2) and (a.compania = b.compania and a.numero_documento = b.numero_documento and a.anio_recepcion = b.anio_recepcion) and (a.cod_familia = ar.cod_flia and a.cod_clase = ar.cod_clase and a.cod_articulo = ar.cod_articulo) and (i.compania = ar.compania and i.art_familia = ar.cod_flia and i.art_clase = ar.cod_clase and i.cod_articulo = ar.cod_articulo) and  (ar.compania = ca.compania and ar.cod_flia = ca.cod_flia and ar.cod_clase = ca.cod_clase) and (ca.compania = fa.compania and ca.cod_flia = fa.cod_flia) and b.compania = "+compania+appendFilter+" group by a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo, ar.descripcion, i.precio, a.precio, a.cod_familia ,a.cod_clase,a.cod_articulo , b.fecha_documento, a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo||i.precio order by a.cod_familia,a.cod_clase,a.cod_articulo asc, ar.descripcion asc,i.precio asc , b.fecha_documento asc "; 

if(!condicion.trim().equals("") && condicion.trim().equals("M"))
{
	appendFilter +=" and a.precio >= i.precio + ((i.precio * "+porcentaje+")/100 ) "; 
}
else if(!condicion.trim().equals("") && condicion.trim().equals("N"))
{
	appendFilter +=" and a.precio <= i.precio + ((i.precio * "+porcentaje+")/100 ) "; 
}
else appendFilter +=" and ( a.precio >= i.precio + ((i.precio * "+porcentaje+")/100 ) or a.precio <= i.precio - ((i.precio * "+porcentaje+")/100 ) )"; 


sql = " select a.cod_familia ,a.cod_clase,a.cod_articulo, a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo cod_art, ar.descripcion, nvl(i.precio,'0.00') costo_inv, nvl(a.precio,'0.00') costo_recep, to_char(b.fecha_documento,'dd/mm/yyyy') as fecha, a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo||i.precio as llave /*,a.anio_recepcion||'- '||a.numero_documento noRecepcion*/ from tbl_inv_detalle_recepcion a, tbl_inv_recepcion_material b, tbl_inv_inventario i, tbl_inv_articulo ar, tbl_inv_clase_articulo ca, tbl_inv_familia_articulo fa  where  a.precio > 0 and i.precio > 0  and  to_date(to_char(b.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') > to_date('01/01/2001' ,'dd/mm/yyyy') and b.estado = 'R' and (a.compania = b.compania and a.numero_documento = b.numero_documento and a.anio_recepcion = b.anio_recepcion) and (a.cod_familia = ar.cod_flia and a.cod_clase = ar.cod_clase and a.cod_articulo = ar.cod_articulo) and (i.compania = ar.compania and i.art_familia = ar.cod_flia and i.art_clase = ar.cod_clase and i.cod_articulo = ar.cod_articulo) and  (ar.compania = ca.compania and ar.cod_flia = ca.cod_flia and ar.cod_clase = ca.cod_clase) and (ca.compania = fa.compania and ca.cod_flia = fa.cod_flia) and b.compania = "+compania+appendFilter+" group by a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo, ar.descripcion, i.precio, a.precio, a.cod_familia ,a.cod_clase,a.cod_articulo , b.fecha_documento, a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo||i.precio /*,a.anio_recepcion||'- '||a.numero_documento*/ order by a.cod_familia,a.cod_clase,a.cod_articulo asc, ar.descripcion asc,i.precio asc , b.fecha_documento asc "; 
al = SQLMgr.getDataList(sql);

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
	String title = "INVENTARIO";
	String subtitle = "VARIACION DE COSTO EN RECEPCION VS. COSTO ACTUAL";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages    
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
    //float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	Vector dHeader = new Vector();		
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".35");
		dHeader.addElement(".15");
		//dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".20");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row		
		pc.setFont(7, 1);
		pc.addBorderCols("Código",0,1);
		pc.addBorderCols("Costo",2,1);
		pc.addBorderCols("Artículo",0,1);
		pc.addBorderCols("No. Recepción",0,1);
		pc.addBorderCols("Fecha",1,1);
		pc.addBorderCols("Costo Recepción",2,1);
		
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
        /**/
	String groupBy = "",subGroupBy = "";
	for (int i=0; i<al.size(); i++)
	{
	  CommonDataObject cdo = (CommonDataObject) al.get(i);
        if(!groupBy.equalsIgnoreCase(cdo.getColValue("llave")))
		{
			if (i != 0)
			{
				pc.setFont(7, 0);
				pc.addCols(" ",1,dHeader.size());
			}
				pc.addCols(""+cdo.getColValue("cod_art"),0,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("costo_inv")),2,1);
				pc.addCols(""+cdo.getColValue("descripcion"),0,4);
		}
				
				pc.addCols(" ",1,3);
				pc.addCols("",0,1);
				pc.addCols(""+cdo.getColValue("fecha"),1,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("costo_recep")),2,1);
		
				groupBy = cdo.getColValue("llave");
		
	}//for i
	if (al.size() == 0) 
	{
	  pc.addCols("No existen registros",1,dHeader.size());
	}
		  
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);	  
}//get
%>
