<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
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
 reporte :   COM0000.rdf
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
String compania = (String) session.getAttribute("_companyId");
String id     = request.getParameter("id");
String anio   = request.getParameter("anio");
String num    = request.getParameter("num");
String tp     = request.getParameter("tp");
String fp     = request.getParameter("fp");
String wh     = request.getParameter("wh");

if(num  == null)  num  = "";
if(anio == null)  anio = "";
if(id   == null)  id   = "";
if(tp   == null)  tp   = "";
if (appendFilter == null) appendFilter = "";

if(!anio.trim().equals("")) appendFilter += " and a.anio = "+anio;
if(!num.trim().equals("")) appendFilter += " and a.num_doc = "+num;
if(!tp.trim().equals("")) appendFilter += " and a.tipo_compromiso = "+tp;

sql =" SELECT a.anio, a.tipo_compromiso, a.num_doc, a.anio||'-'||a.num_doc as ordenNum, a.compania, a.lugar_entrega as entrega, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, d.descripcion, to_char(a.monto_total,'999,999,999,990.00') as monto_total, a.numero_factura, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence,nvl(a.monto_pagado,'0.00') as monto_pago,a.tiempo_entrega as tiempo, to_char(a.sub_total,'9,999,999,990.00') as sub_total,  to_char(a.descuento,'9,999,999,990.00') as descuento,  to_char(a.itbm,'9,999,990.00') as itbm,  to_char(a.sub_total-nvl(a.descuento,0),'9,999,999,990.00') as sub_desc, b.ruc||'          D.V.: '||b.digito_verificador as ruc, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE') desc_status, nvl(b.nombre_proveedor, ' ')as nombre_proveedor,  c.descripcion almacen_desc, to_char(a.monto_total - nvl(a.monto_pagado,'0.00'),'999,999,990.00') as saldo, a.cod_proveedor, d.descripcion as tipoOrden, a.explicacion, a.usuario from tbl_com_comp_formales a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and A.compania = c.compania  and a.tipo_compromiso = d.tipo_com  and a.compania = "+compania+appendFilter;
cdo = SQLMgr.getData(sql);


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

	float dispHeight = 0.0f;//altura disponible para el ciclo for 
	float headerHeight = 0.0f;//tamaño del encabezado
	float innerHeight = 0.0f;//tamaño del detalle
	float footerHeight = 0.0f;//tamaño del footer
	float modHeight = 0.0f;//tamaño del relleno en blanco
	float antHeight = 0.0f;//
	float finHeight = 0.0f;//
	float extra = 0.0f;//
	float total = 0.0f;//
	float innerTableHeight = 0.0f;
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
	String title = "ORDEN DE COMPRA";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 13.0f;
	int  j = 0;
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
	Vector dInnerHeader=new Vector();
		dInnerHeader.addElement("108.8");
		dInnerHeader.addElement("69.4");
	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
		footer.setFont(9, 0);
		footer.setVAlignment(1);
		footer.addCols("ENTREGA: _______________________________    RECIBE: _______________________________",0,5,cHeight);
	
		footer.setNoInnerColumnFixWidth(dInnerHeader);
		footer.createInnerTable();
		footer.setInnerTableWidth((width - (leftRightMargin * 2)) * .3f);
			footer.setFont(9, 1);
			footer.addInnerTableCols("SUBTOTAL",2,1);
			footer.addInnerTableCols(cdo.getColValue("sub_total"),2,1);

			footer.addInnerTableCols("DESCUENTO",2,1);
			footer.addInnerTableCols(""+cdo.getColValue("descuento"),2,1);

			
			footer.addInnerTableCols("TOTAL",2,1);
			footer.addInnerTableCols(""+cdo.getColValue("monto_total"),2,1);
		footer.addInnerTableToCols(3);

		footer.setFont(9, 0);
		footer.setVAlignment(2);
		
		footer.addCols("APROBADO EN DEPARTAMENTO POR:",0,3);
		footer.addBorderCols(" ",0,5,0.5f,0.0f,0.0f,0.0f,cHeight);

		footer.addCols("APROBADO EN GERENCIA DE OPERACIONES POR:",0,3);
		footer.addBorderCols(" ",0,5,0.5f,0.0f,0.0f,0.0f,cHeight);

		footer.addCols("APROBADO EN GERENCIA GENERAL POR:",0,3);
		footer.addBorderCols(" ",0,5,0.5f,0.0f,0.0f,0.0f,cHeight);

		footer.addCols("PREPARADO POR: "+cdo.getColValue("usuario"),0,dHeader.size(),cHeight);
		footer.addCols("**TODA FACTURA DEBE VENIR CON EL NÚMERO DE ORDEN DE COMPRA**",1,dHeader.size(),cHeight);
		
		footer.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,cHeight);
		footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());

	Vector setDetail=new Vector();
		setDetail.addElement(".15");
		setDetail.addElement(".43");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".12");

	Vector setHeader0=new Vector();
		setHeader0.addElement(".50");
		setHeader0.addElement(".50");

	Vector setHeader1=new Vector();
		setHeader1.addElement("82");
		setHeader1.addElement("95");

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable(true);

		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, setDetail.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(setDetail);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();
			pc.setFont(9, 1);
			pc.addInnerTableCols("Proveedor:",0,1);
			pc.addInnerTableCols(cdo.getColValue("nombre_proveedor"),0,1);
			pc.addInnerTableCols("Términos:",0,4);

			pc.addInnerTableCols("R.U.C.:",0,1);
			pc.addInnerTableCols(cdo.getColValue("ruc"),0,1);
			pc.addInnerTableCols("Solicitud No.:",0,4);

			pc.addInnerTableCols("Lugar de Entrega:",0,1);
			pc.addInnerTableCols(cdo.getColValue("almacen_desc"),0,1);
			pc.addInnerTableCols("Orden de Compra No.: "+anio+" - "+num,0,4);

			pc.addInnerTableCols("Tiempo de Entrega: "+cdo.getColValue("tiempo"),0,2);
			pc.addInnerTableCols("Factura No.: "+cdo.getColValue("numero_factura"),0,4);

			pc.addInnerTableCols(" ",0,1);
			pc.addInnerTableCols(" ",0,1);
			pc.addInnerTableCols("Fecha Documento: "+cdo.getColValue("fecha_documento"),0,4);
		pc.addInnerTableToCols(setDetail.size());

		pc.resetVAlignment();
		pc.addBorderCols("DESCRIPCION",0,5,0.5f,0.5f,0.5f,0.5f);
		pc.addBorderCols("TOTAL",2,1,0.5f,0.5f,0.0f,0.5f);
	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	headerHeight =  pc.getTableHeight();
	
	pc.setNoInnerColumnFixWidth(setDetail);
	pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
	pc.createInnerTable(true);
	
	dispHeight = height -(topMargin + bottomMargin + headerHeight +footerHeight);
	/*System.out.println("********************** headerHeight ==   "+headerHeight);
	System.out.println("********************** footerHeight ==   "+footerHeight);
	System.out.println("********************** espacio disponible ===   "+dispHeight);*/
	float cAltura = 0.00f;

		antHeight = pc.getInnerTableHeight();
		pc.setFont(9, 0);
		pc.addInnerTableBorderCols(""+cdo.getColValue("explicacion"),0, 5, 0.f, 0.0f, 0.0f, 0.5f);
		/*pc.addInnerTableBorderCols(""+cdo1.getColValue("articuloDesc"),0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(""+cdo1.getColValue("medida"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(""+cdo1.getColValue("cantidad"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(""+cdo1.getColValue("montoArticulo"),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		*/
		pc.addInnerTableBorderCols(""+cdo.getColValue("sub_total"),2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		finHeight = pc.getInnerTableHeight();
		cAltura = finHeight - antHeight;
		total += cAltura;
		System.out.println("******************total   ===   "+total);
		
		if( total > dispHeight)
		{
			int ltotal  = (new Double(""+((cAltura-4)/9))).intValue();
			int ldisp = (new Double(""+((dispHeight - (total - cAltura) - 4) / 9))).intValue();
			int lpend = ltotal - ldisp;
			total = (lpend * 9) + 4;
			
			//System.out.println("******************total   ===   "+total);
		}
	//}
	if (cdo == null) pc.addCols("No existen registros",1,setDetail.size());
	else
	{
		innerTableHeight = pc.getInnerTableHeight();
		modHeight =  innerTableHeight % dispHeight; 
		float altura = (dispHeight-total);
		//System.out.println("******************altura   ===   "+altura);
		pc.addInnerTableBorderCols("",0, 5, 0.0f, 0.0f, 0.0f, 0.5f,altura);
		pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.0f);

		///System.out.println("******************innerTableHeight  ===   "+innerTableHeight);

		pc.addInnerTableToBorderCols(setDetail.size());
		pc.flushTableBody(true);
	}

	pc.addTable();
	
	//System.out.println("****************** tamaño total de la tabla  ===   "+pc.getTableHeight());	
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>