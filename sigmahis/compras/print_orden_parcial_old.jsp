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

sql =" SELECT a.anio, a.tipo_compromiso, a.num_doc, a.anio||'-'||a.num_doc as ordenNum, a.compania, a.lugar_entrega as entrega, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, d.descripcion, to_char(a.monto_total,'999,999,999,990.00') as monto_total, a.numero_factura, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence,nvl(to_char(a.monto_pagado),'0.00') as monto_pago,a.tiempo_entrega as tiempo, to_char(a.sub_total,'9,999,999,990.00') as sub_total,  to_char(a.descuento,'9,999,999,990.00') as descuento,  to_char(a.itbm,'9,999,990.00') as itbm,  to_char(a.sub_total-nvl(a.descuento,0),'9,999,999,990.00') as sub_desc, b.ruc||'          D.V.: '||b.digito_verificador as ruc, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE','Z','CERRADO') desc_status, nvl(b.nombre_proveedor, ' ')as nombre_proveedor,  c.descripcion almacen_desc, to_char(a.monto_total - nvl(to_char(a.monto_pagado),'0.00'),'999,999,990.00') as saldo, a.cod_proveedor, d.descripcion as tipoOrden, 'COMENTARIOS:'||chr(13)|| a.explicacion explicacion, a.usuario, 'OBSERVACIONES:' || chr(13) || 'Producto que no tenga existencia favor notificarlo a los Tel.: 204-8076 / 77 / 78' || chr(13) || 'No se recibirán productos con el sello de garantía violados, rayado, rotos, oxidado, etc.' || chr(13) || 'Toda factura debe incluir el número de orden de compra' || chr(13) || 'Horario de recibo: Lunes a Viernes de 9:00 am a 4:00 pm, los sábados no se recibe mercancia.' || chr(13) || chr(13) || 'PARA EQUIPOS:' || chr(13) || 'El equipo debe ser entregado con manual de usuario y servicio técnico.' || chr(13) || 'La garantía es a partir de la instalación de los equipos.' || chr(13) || 'Debe incluir una caja del insumo que requiere el equipo ofrecido.' || chr(13) || 'El proveedor debe capacitar al personal usuario del equipo en el uso adecuado y limpieza del mismo en los 3 turnos existentes, debidamente coordinado con la oficina de capacitación.' || chr(13) || 'El equipo debe ser entregado en almacén y evaluado por biomédica previo a la cancelación de la factura' observaciones, nvl(b.direccion, ' ') direccion, nvl(b.telefono || ' - ' || b.fax, ' ') telefono_fax, nvl(b.email, ' ') email, to_char(a.fecha_entrega, 'dd/mm/yyyy') fecha_entrega, a.requi_anio, a.requi_numero, decode(a.dia_limite, 0, ' ', 1, '15 DIAS', 2, '30 DIAS', 3, '45 DIAS', 4, '60 DIAS', 5, '90 DIAS', 6, '120 DIAS') dias_limite_desc,a.motivo ,to_char(a.fecha_entrega_proveedor,'dd/mm/yyyy') as fecha_entrega_prov from tbl_com_comp_formales a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and A.compania = c.compania  and a.tipo_compromiso = d.tipo_com  and a.compania = "+compania+appendFilter;
cdo = SQLMgr.getData(sql);

sql = "select f.descripcion || ' ' || a.especificacion /*|| decode (a.cod_familia, 7, '  * FAVOR INDICAR LA VIDA UTIL DEL ARTICULO ', null)*/ as articulodesc, a.cod_familia || '-' || a.cod_clase || '-' || a.cod_articulo as codigoart, a.cod_articulo, f.precio_venta, f.cod_medida as medida, a.cantidad, to_char (a.monto_articulo, '999,999,990.0000') as montoarticulo, to_char (((a.monto_articulo - round(decode(nvl(a.tipo_descuento,'P'),'P',a.monto_articulo * (nvl(a.descuento,0) / 100),'M',nvl(a.descuento,0)),6)) * a.cantidad), '999,999,999,990.00') as total, a.estado_renglon as estadorenglon, a.entregado as cantentregada, nvl (g.referencia, '') catalogo_producto, decode(nvl(a.descuento,0),0,' ',decode(a.tipo_descuento,'M','$'||a.descuento,a.descuento||'%')) as descuento from (select a.compania, a.anio, a.num_doc, a.tipo_compromiso, a.cod_proveedor, b.especificacion, b.cod_familia, b.cod_clase, b.cod_articulo, b.cantidad, b.monto_articulo, b.estado_renglon, b.entregado, b.descuento, b.tipo_descuento from tbl_com_comp_formales a, tbl_com_detalle_compromiso b where a.anio = b.cf_anio and a.tipo_compromiso = b.cf_tipo_com and a.num_doc = b.cf_num_doc and a.compania = b.compania) a, tbl_inv_articulo f, tbl_inv_arti_prov g where a.cod_articulo = f.cod_articulo and a.compania = f.compania and a.compania = "+compania+appendFilter+" and a.cod_proveedor = g.cod_provedor(+) and a.cod_articulo = g.cod_articulo(+) order by a.cod_familia, a.cod_clase, a.cod_articulo";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String time_stamp = CmnMgr.getCurrentDate("ddmmyyyyhh12missam");

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+time_stamp+"_"+UserDet.getUserId()+".pdf";

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
	String statusPath = ResourceBundle.getBundle("path").getString("images")+"/anulado.png";
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
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 30.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = (cdo.getColValue("status").equals("N")?true:false);
	String xtraCompanyInfo = "";
	String title = "ORDEN DE COMPRA No. "+anio+" - "+ num;
	String subtitle = "TELEFONO: 204-8076 / 77 / 78   FAX: 204-8059";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 25.0f;
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
		dInnerHeader.addElement("59");
		dInnerHeader.addElement("59");
	Vector xInnerHeader=new Vector();
		xInnerHeader.addElement("90");
		xInnerHeader.addElement("93");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, null);

	Vector setDetail=new Vector();
		setDetail.addElement(".06");
		setDetail.addElement(".10");
		setDetail.addElement(".32");
		setDetail.addElement(".11");
		setDetail.addElement(".04");
		setDetail.addElement(".07");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");

	Vector setHeader0=new Vector();
		setHeader0.addElement(".50");
		setHeader0.addElement(".50");

	Vector setHeader1=new Vector();
		setHeader1.addElement("82");
		setHeader1.addElement("95");

		pc.setNoColumnFixWidth(setDetail);
		pc.createTable("footer", false, 0, 0.0f, width - (leftRightMargin * 2));
			pc.setFont(9, 0);

			pc.addBorderCols(" ",0,setDetail.size(),0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("explicacion"),0,7);
			pc.setNoInnerColumnFixWidth(dInnerHeader);
			pc.createInnerTable(false);
			
			pc.setInnerTableWidth((width - (leftRightMargin * 2)) * .3f);
				
				pc.addInnerTableCols("Sub-total",0,1);
				pc.addInnerTableBorderCols(cdo.getColValue("sub_total"),2,1, 0.0f, 0.0f, 0.0f, 0.0f);
	
				pc.addInnerTableCols("Descuento",0,1);
				pc.addInnerTableBorderCols(""+cdo.getColValue("descuento"),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
	
				pc.addInnerTableCols("Sub-total",0,1);
				pc.addInnerTableBorderCols(""+ cdo.getColValue("sub_desc"),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
	
				pc.addInnerTableCols("ITBMS",0,1);
				pc.addInnerTableBorderCols(""+cdo.getColValue("itbm"),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
	
				pc.setFont(9, 1);
				pc.addInnerTableCols("Total",0,1);
				pc.addInnerTableBorderCols(""+cdo.getColValue("monto_total"),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
			pc.addInnerTableToCols(2);

			pc.setFont(8, 0);

			pc.resetVAlignment();
			pc.addCols(" ",0,setDetail.size());
			pc.addBorderCols(cdo.getColValue("observaciones"),0,5);
			pc.setNoInnerColumnFixWidth(xInnerHeader);
			pc.createInnerTable(false);
			pc.setInnerTableWidth((width - (leftRightMargin * 2)) * .3f);
				pc.addInnerTableCols("Aprobaciones:", 0, 2);
	
				pc.addInnerTableCols("Depto. de Compras:", 0, 1);
				pc.addInnerTableBorderCols("",1, 1, 0.5f, 0.0f, 0.0f, 0.0f);

				pc.addInnerTableCols(" ",2,2);
	
				pc.addInnerTableCols("Depto. de Logística:", 0, 1);
				pc.addInnerTableBorderCols("",1, 1, 0.5f, 0.0f, 0.0f, 0.0f);

				pc.addInnerTableCols(" ",2,2);
	
				pc.addInnerTableCols("Depto. de Contabilidad:", 0, 1);
				pc.addInnerTableBorderCols("",1, 1, 0.5f, 0.0f, 0.0f, 0.0f);

				pc.addInnerTableCols(" ",2,2);

				pc.addInnerTableCols("Dirección de Finanzas:", 0, 1);
				pc.addInnerTableBorderCols("",1, 1, 0.5f, 0.0f, 0.0f, 0.0f);

				pc.addInnerTableCols(" ",2,2);
				pc.addInnerTableCols(" ",2,2);

				pc.addInnerTableCols("Preparado por:",0,1);
				pc.addInnerTableBorderCols(cdo.getColValue("usuario"),0, 1, 0.0f, 0.0f, 0.0f, 0.0f);

			pc.addInnerTableToCols(4);
			
			
			//pc.addBorderCols(" ",0,setDetail.size(),0.0f,0.0f,0.0f,0.0f,cHeight);

			float observationsHeight = pc.getTableHeight();

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable(true);

		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, subtitle, title, xtraSubtitle, userName, fecha, setDetail.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(setDetail);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();
			pc.setFont(8, 0);
			pc.addInnerTableCols("Nombre del Proveedor:",0,2);
			pc.setFont(8, 1);
			pc.addInnerTableCols(cdo.getColValue("nombre_proveedor"),0,2);
			pc.setFont(8, 0);
			pc.addInnerTableCols("Términos pago:",0,2);
			pc.addInnerTableCols(cdo.getColValue("dias_limite_desc"),0,3);

			pc.addInnerTableCols("Dirección:",0,2);
			pc.addInnerTableCols(cdo.getColValue("direccion"),0,2);
			pc.addInnerTableCols("No. de Solicitud:"+cdo.getColValue("requi_anio")+" - "+cdo.getColValue("requi_numero"),0,5);

			pc.addInnerTableCols("Teléfonos y Fax:",0,2);
			pc.addInnerTableCols(cdo.getColValue("telefono_fax"),0,2);
			
			pc.addInnerTableCols("Fecha: "+cdo.getColValue("fecha_documento"),0,5);

			pc.addInnerTableCols("Correo: ",0,2);
			pc.addInnerTableCols(cdo.getColValue("correo"),0,2);
			pc.addInnerTableCols("Fecha de entrega: "+cdo.getColValue("fecha_entrega_prov"),0,5);
			
			
			 
			if(cdo.getColValue("status").trim().equals("Z"))
			{
				pc.setFont(9, 0,Color.red); 
				pc.addInnerTableCols("Mot. Cierre:",0,2); 
				pc.addInnerTableCols(cdo.getColValue("motivo"),0,7);
				 
 			}
  
		pc.addInnerTableToCols(setDetail.size());

		pc.setFont(9, 1);
		pc.resetVAlignment();
		pc.addBorderCols("Item",0,1,0.5f,0.5f,0.5f,0.5f);
		pc.addBorderCols("Código",0,1,0.5f,0.5f,0.5f,0.5f);
		pc.addBorderCols("Descripción",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Catálogo del producto",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Und",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Cant.",1,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Precio",2,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Descuento",2,1,0.5f,0.5f,0.0f,0.5f);
		pc.addBorderCols("Total",2,1,0.5f,0.5f,0.0f,0.5f);
	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	headerHeight =  pc.getTableHeight();
	
	pc.setNoInnerColumnFixWidth(setDetail);
	pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
	pc.createInnerTable(true);
	
	dispHeight = height -(topMargin + bottomMargin + headerHeight +footerHeight);
	/*System.out.println("********************** headerHeight ==   "+headerHeight);
	System.out.println("********************** footerHeight ==   "+footerHeight);
	System.out.println("********************** espacio disponible ===   "+dispHeight);*/
	float acumulado = 0.0f;
	float faltante = 0.0f;
	float actual = 0.0f;
	float cAnterior = 0.0f;
	float disponible = 0.0f;
	float cAltura = 0.00f;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);	
		antHeight = pc.getInnerTableHeight();
		pc.setFont(9, 0);
		pc.addInnerTableBorderCols(""+i,0, 1, 0.f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("codigoArt"),0, 1, 0.f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("articuloDesc"),0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("catalogo_producto"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("medida"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("cantidad"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("montoArticulo"),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("descuento"),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		pc.addInnerTableBorderCols(cdo1.getColValue("total"),2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		
		
		
		
		
		
		
		finHeight = pc.getInnerTableHeight();
		cAltura = finHeight - antHeight;
		total += cAltura;
		if( total > dispHeight)
		{
			int ltotal  = (new Double(""+((cAltura-4)/9))).intValue();
			int ldisp = (new Double(""+((dispHeight - (total - cAltura) - 4) / 9))).intValue();
			int lpend = ltotal - ldisp;
			total = (lpend * 9) + 4;
			
			//System.out.println("******************total   ===   "+total);
		}
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,setDetail.size());
	else
	{
		innerTableHeight = pc.getInnerTableHeight();
		float altFooterLastPage = observationsHeight;
		float altura = dispHeight-total;

		if(altura < altFooterLastPage){
		
			pc.addInnerTableBorderCols("",0, 1, 0.0f, 0.0f, 0.0f, 0.5f,altura);
			pc.addInnerTableBorderCols("",0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.0f);

		} else {
		
			altura = altura - altFooterLastPage;
		
			pc.addInnerTableBorderCols("",0, 1, 0.0f, 0.0f, 0.0f, 0.5f,altura);
			pc.addInnerTableBorderCols("",0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addInnerTableBorderCols("",2, 1, 0.0f, 0.0f, 0.0f, 0.0f);

		}

		pc.addInnerTableToBorderCols(setDetail.size());

			
			pc.addTableToCols("footer", 0, setDetail.size());

		//System.out.println("******************innerTableHeight  ===   "+innerTableHeight);

		pc.flushTableBody(true);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>