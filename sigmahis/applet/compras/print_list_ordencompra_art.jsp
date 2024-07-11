<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
/*=========================================================================
0 - SYSTEM ADMINISTRATOR 
    REPORTE   COM0014.RDF          FORMA   COM800051
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();


String sql = "";
String appendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();


String fp       = request.getParameter("fp");
String compania = (String) session.getAttribute("_companyId");	
String tDate    = request.getParameter("tDate");
String fDate    = request.getParameter("fDate");
String familia  = request.getParameter("familia");
String clase    = request.getParameter("clase");
String articulo = request.getParameter("articulo");
String titulo = request.getParameter("titulo");
String depto = request.getParameter("depto");
String subclase = request.getParameter("subclase");
String proveedor = request.getParameter("proveedor");
String anio = request.getParameter("anio");
String numOc = request.getParameter("numOc");

if(fp== null) fp = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(familia== null) familia = "";
if(clase== null) clase = "";
if(subclase== null) subclase = "";
if(articulo== null) articulo = "";
if(titulo== null) titulo = "";
if(depto== null) depto = "";
if(proveedor== null) proveedor = "";
if(anio== null) anio = "";
if(numOc== null) numOc = "";

if (appendFilter == null) appendFilter = "";

if(!fDate.trim().equals("")&&!tDate.trim().equals("")) 
appendFilter += " and to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and  to_date('"+tDate+"','dd/mm/yyyy') ";

if(!familia.trim().equals("")) 
appendFilter += " and f.cod_flia = "+familia ;

if(!clase.trim().equals("")) 
appendFilter += " and f.cod_clase = "+clase ;

if(!subclase.trim().equals("")) 
appendFilter += " and f.cod_subclase = "+subclase ;

if(!articulo.trim().equals("")) 
appendFilter += " and f.cod_articulo = "+articulo ;

if(!fp.trim().equals("RP"))//diferente a la opcion por articulo 
{
appendFilter += " and a.tipo_compromiso <> 2  ";
}
if(!proveedor.trim().equals("")) 
appendFilter += " and a.cod_proveedor = "+proveedor ;

if(!anio.trim().equals("")) appendFilter += " and a.anio = "+anio ;
if(!numOc.trim().equals("")) appendFilter += " and a.num_doc = "+numOc ;

sql = "SELECT a.anio, a.tipo_compromiso, a.num_doc, a.anio||'-'||a.num_doc as ordenNum, a.compania, to_char(a.fecha_documento,'DD-MON-RRRR') fecha_documento, a.status, d.descripcion, a.monto_total as monto_total, a.numero_factura, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence,nvl(a.monto_pagado,'0.00') as monto_pago, decode(substr(a.tipo_pago,0,2),'CR','CREDITO','CO','CONTADO') as tipo_pago, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE') desc_status, '[ '||nvl(a.cod_proveedor, 0) || '] ' || nvl(b.nombre_proveedor, ' ')as nombre_proveedor, nvl(a.cod_almacen, 0) || ' ' || c.descripcion almacen_desc, to_char(a.monto_total - nvl(a.monto_pagado,'0.00'),'999,999,990.00') as saldo, a.cod_proveedor, d.descripcion||'-'||decode(a.tipo_pago,2,'CREDITO',1,'CONTADO') as tipoOrden, f.descripcion as articuloDesc, e.cantidad, to_char(e.cantidad - nvl(e.entregado,'0'),'999,999,990.00') as pendiente, e.monto_articulo as montoArticulo, lpad(f.cod_flia,3,'0')||'-'||lpad(f.cod_clase,3,'0')||'-'||lpad(f.cod_subclase,3,'0')||'-'||lpad(f.cod_articulo,10,'0') as codigoArt ,e.estado_renglon as estadoRenglon, a.explicacion, e.entregado as cantEntregada "
+ " from tbl_com_comp_formales a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d, tbl_com_detalle_compromiso e, tbl_inv_articulo f "
+ " where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and "
+ " a.compania = c.compania and a.compania = e.compania and a.num_doc = e.cf_num_doc and a.tipo_compromiso = e.cf_tipo_com and e.cod_articulo = f.cod_articulo and e.compania = f.compania and a.anio = e.cf_anio and a.tipo_compromiso = d.tipo_com  and a.status in ('A','C','F') and e.estado_renglon ='P' and a.compania = "+compania+appendFilter+" and (nvl(e.cantidad,0) - nvl(e.entregado,0)) <> 0 order by  f.descripcion, a.anio, a.num_doc asc ";

//a.tipo_compromiso, a.cod_proveedor, a.anio, a.fecha_documento, a.num_doc, f.descripcion ";
al = SQLMgr.getDataList(sql);

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
	String title = "COMPRAS";
	String subtitle = "ORDENES  DE  COMPRA  APROBADAS  CON  ARTICULOS  PENDIENTES";
	String xtraSubtitle = "POR ORDEN POR ARTICULO (De Todos los Tipos) desde   "+fDate+ " hasta "+tDate;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	
		Vector dHeader=new Vector();
			dHeader.addElement(".50");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".30");			

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
					
		pc.setFont(7, 0, Color.red);
		pc.addCols("Proveedor",0,1);
		pc.addCols("Orden No.",1,1);
		pc.addCols("Fecha",1,1);
		pc.addCols("Tipo de Orden",1,1);
			
	  pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	 //table body
	 pc.setVAlignment(0);
	 pc.setFont(7, 0);			
	String groupBy = "";
	String subGroupBy = "";	
	int cantArt =0;			
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
				
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigoArt")))
		{
			if(i!=0)
			{
				pc.addCols(" ", 0,4,cHeight);			
			}
			pc.setFont(7, 1,Color.blue);
			pc.addBorderCols(""+cdo.getColValue("articuloDesc"), 0,3,cHeight);		
			pc.addBorderCols(""+cdo.getColValue("codigoArt"), 2,1,cHeight);	
			cantArt ++;		
		}
		
			pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("nombre_proveedor"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("anio")+" - "+cdo.getColValue("num_doc"),1,1,cHeight);	
			pc.addCols(" "+cdo.getColValue("fecha_documento"),1,1,cHeight) ;						
			pc.addCols(" "+cdo.getColValue("tipoOrden"),0,1,cHeight) ;
			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
			groupBy = cdo.getColValue("codigoArt");
			
	}	// end for i	
	
	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,dHeader.size());
	} else 
	{
		pc.setFont(7, 0,Color.blue);
		pc.addCols("Total de Artìculos   "+cantArt,0,dHeader.size());
	}
	
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>