<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
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
/*=========================================================================
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
ArrayList alTotTipo = new ArrayList();
ArrayList alTotProv = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String fp       = request.getParameter("fp");
String compania = (String) session.getAttribute("_companyId");	
String tDate    = request.getParameter("tDate");
String fDate    = request.getParameter("fDate");
String proveedor = request.getParameter("proveedor");
String familia  = request.getParameter("familia");
String clase    = request.getParameter("clase");
String articulo = request.getParameter("articulo");
String subclase = request.getParameter("subclase");
String anio = request.getParameter("anio");
String numOc = request.getParameter("numOc");
String tipo_pago = request.getParameter("tipo_pago");

if(fp== null) fp = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(proveedor== null) proveedor = "";
if(familia== null) familia = "";
if(clase== null) clase = "";
if(subclase== null) subclase = "";
if(articulo== null) articulo = "";
if(anio== null) anio = "";
if(numOc== null) numOc = "";
if(tipo_pago== null) tipo_pago = "all";

if (appendFilter == null) appendFilter = "";
if(!fp.trim().equals("RP"))//diferente a opcion por proveedor 
{
appendFilter += " and a.tipo_compromiso <> 2  ";
}

if(!fDate.trim().equals("")&&!tDate.trim().equals("")) 
appendFilter += " and to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and  to_date('"+tDate+"','dd/mm/yyyy') ";

if(!proveedor.trim().equals("")) 
appendFilter += " and a.cod_proveedor = "+proveedor ;
if(!familia.trim().equals("")) 
appendFilter += " and f.cod_flia = "+familia ;

if(!clase.trim().equals("")) 
appendFilter += " and f.cod_clase = "+clase ;

if(!subclase.trim().equals("")) 
appendFilter += " and f.cod_subclase = "+subclase ;

if(!articulo.trim().equals("")) 
appendFilter += " and f.cod_articulo = "+articulo ;
if(!anio.trim().equals("")) appendFilter += " and a.anio = "+anio ;
if(!numOc.trim().equals("")) appendFilter += " and a.num_doc = "+numOc ;
if(!tipo_pago.equals("all")) appendFilter += " and a.tipo_pago = '"+tipo_pago+"'";

	sql = "SELECT a.anio, a.tipo_compromiso, a.num_doc, a.anio||'-'||a.num_doc as ordenNum, a.compania, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, d.descripcion, a.monto_total as monto_total,  nvl(a.monto_pagado,'0.00') as monto_pago, decode(substr(a.tipo_pago,0,2),'CR','CREDITO','CO','CONTADO') as tipo_pago, '[ '||nvl(a.cod_proveedor, 0) || '] ' || nvl(b.nombre_proveedor, ' ')as nombre_proveedor,  to_char(a.monto_total - nvl(a.monto_pagado,'0.00'),'999,999,990.00') as saldo, a.cod_proveedor, d.descripcion||'-'||decode(a.tipo_pago,2,'CREDITO',1,'CONTADO') as tipoOrden, f.descripcion as articuloDesc, e.cantidad, nvl(e.cantidad,0) - nvl(e.entregado,'0')as pendiente, nvl(e.cant_promo,0) - nvl(e.entregado_promo,'0')  as pendientePromo, e.monto_articulo as montoArticulo, lpad(f.cod_flia,3,'0')||' '||lpad(f.cod_clase,3,'0')||' '||lpad(f.cod_subclase,3,'0')||' '||lpad(f.cod_articulo,10,'0') as codigoArt , nvl(e.entregado,0) as cantEntregada,nvl(e.entregado_promo,0) as entregado_promo,nvl(e.cant_promo,0) as promo from tbl_com_comp_formales a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d, tbl_com_detalle_compromiso e, tbl_inv_articulo f where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and a.compania = c.compania and a.compania = e.compania and a.num_doc = e.cf_num_doc and a.tipo_compromiso = e.cf_tipo_com  and e.cod_articulo = f.cod_articulo and e.compania = f.compania and a.anio = e.cf_anio and a.tipo_compromiso = d.tipo_com  and a.status in ('A','C','F')  and e.estado_renglon ='P' and a.compania = "+compania+appendFilter+" order by a.tipo_compromiso, a.cod_proveedor, a.anio, a.fecha_documento, a.num_doc, f.descripcion";
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
	String subtitle = "ORDENES DE COMPRA APROB. CON ARTICULOS PENDIENTES ";
	String xtraSubtitle = "POR RECEPCION POR PROVEEDOR (De Todos los Tipos) del "+fDate+ " al "+tDate;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	
		Vector dHeader=new Vector();
			dHeader.addElement(".10");
			dHeader.addElement(".37");
			dHeader.addElement(".09");
			dHeader.addElement(".09");
			dHeader.addElement(".09");
			dHeader.addElement(".09");
			dHeader.addElement(".09");
			dHeader.addElement(".08");			
		
		
		

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
					
		pc.setFont(7, 0, Color.red);
			pc.addBorderCols("Ord. No",0);
			pc.addBorderCols("Artìculo",1);
			pc.addBorderCols("Solicitada",2);
			pc.addBorderCols("Promo",2);						
			pc.addBorderCols("Pendiente",2);
			pc.addBorderCols("Pend. Promo.",2);
			pc.addBorderCols("Monto ",2);
			pc.addBorderCols("Fecha",1); 
			
	  pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	 //table body
	 pc.setVAlignment(0);
	 pc.setFont(7, 0);			
	String groupBy = "";
	String subGroupBy = "";	
	int cantProv =0;			
	for (int i=0; i<al.size(); i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		 if (!groupBy.equalsIgnoreCase(cdo.getColValue("tipoOrden")))
		 {
			pc.setFont(7, 1,Color.blue);
				pc.addBorderCols(""+cdo.getColValue("tipoOrden"), 1,dHeader.size(),cHeight);		
			subGroupBy = "";
		 }	
		 	if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_proveedor")))
			{
				pc.setFont(7, 1,Color.blue);
					pc.addCols(""+cdo.getColValue("nombre_proveedor"), 0,dHeader.size(),cHeight);		
				cantProv ++;
			}
						
		pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("anio")+" - "+cdo.getColValue("num_doc"),0,1);							
			pc.addCols(" "+cdo.getColValue("articuloDesc"),0,1) ;
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("promo")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("pendiente")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("pendientePromo")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("montoArticulo")),2,1);
			pc.addCols(" "+cdo.getColValue("fecha_documento"),1,1);
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);			
		subGroupBy = cdo.getColValue("cod_proveedor");
		groupBy = cdo.getColValue("tipoOrden");
	}	// end for i	
	
if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,dHeader.size());
	} else 
	{
	pc.setFont(7, 0,Color.blue);
		pc.addCols("Total de Artìculos   "+al.size(),0,dHeader.size());
	pc.setFont(8, 1);					
		pc.addCols("Total de Proveedores :  "+cantProv,0,dHeader.size());
	}
	
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>