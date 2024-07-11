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
		REPORTE:		INV0056.RDF
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
String userId = UserDet.getUserId();

String wh = request.getParameter("wh");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String anio = request.getParameter("anio");
String num = request.getParameter("num");
String codProv = request.getParameter("codProv");
String fg = request.getParameter("fg");
String consignacion = request.getParameter("consignacion");

if(wh== null) wh = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(anio== null) anio = "";
if(num== null) num = "";
if(codProv== null) codProv = "";
if(fg== null) fg = "";


if (appendFilter == null) appendFilter = "";
if(fg.trim().equals("RDP"))
{
if(!wh.trim().equals(""))         appendFilter  += " and dp.codigo_almacen = "+wh;
if(!codProv.trim().equals(""))         appendFilter  += " and dp.cod_provedor = "+codProv;
if(consignacion.trim().equals("N"))         appendFilter  += " and dp.tipo_dev = 'N'";
else if(consignacion.trim().equals("S"))         appendFilter  += " and dp.tipo_dev in ('C', 'R')";

//if(!anio.trim().equals(""))           appendFilter  += " and dp.anio = "+anio;
//if(!num.trim().equals(""))           appendFilter  += " and dp.num_devolucion = "+num;
if(!tDate.trim().equals(""))appendFilter += " and to_date(to_char(dp.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+tDate+"','dd/mm/yyyy') ";
if(!fDate.trim().equals(""))appendFilter += " and to_date(to_char(dp.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fDate+"','dd/mm/yyyy') ";
}



	sql= "select  dp.anio||'-'||dp.num_devolucion id, dp.anio as anio_devolucion, dp.num_devolucion, dp.compania, to_char(dp.fecha,'dd/mm/yyyy') as fecha_devolucion, dp.observacion, nvl(dp.monto,0) monto,dp.cod_provedor,p.nombre_proveedor as devuelve, decode(dp.tipo_dev,'C','DEV. CONSIGNACION','N','DEV. NORMAL','R','RETIRO (NOTA DE ENTREGA)') as desc_estado, dp.codigo_almacen, dp.nota_credito as nCredito, nvl(dp.itbm,0.0) itbm, nvl(dd.cantidad,0) cantidad, nvl(dd.precio,0) precio, al.descripcion as almacen, (nvl(dd.cantidad,0)*nvl(dd.precio,0)) as total, dd.cod_familia||'-'||dd.cod_clase||'-'||dd.cod_articulo as codigo, ar.descripcion, dp.usuario_creacion as usuario, dp.numero_factura as factura FROM tbl_inv_devolucion_prov dp ,tbl_com_proveedor p, tbl_inv_detalle_proveedor dd, tbl_inv_articulo ar, tbl_inv_almacen al where dp.compania = "+session.getAttribute("_companyId")+" and dp.num_devolucion = dd.num_devolucion and dp.anio = dd.anio and dp.compania = dd.compania and dd.cod_familia = ar.cod_flia and dd.cod_clase = ar.cod_clase and dd.cod_articulo = ar.cod_articulo and dd.compania = ar.compania and dp.codigo_almacen = al.codigo_almacen and dp.compania = al.compania and dp.cod_provedor= p.cod_provedor(+)"+ appendFilter+" order by dp.codigo_almacen asc, dp.cod_provedor asc ,dp.anio asc,dp.num_devolucion asc";


al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int totalArt = 0;
	double total = 0.00;
	Hashtable htEntrega = new Hashtable();
	Hashtable htFamily = new Hashtable();
	int maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0,nGroup =0,nDev=0; //empty lines to be fill

	int nItems = al.size()+(nGroup*3)+(nDev*6);
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_list_devolucion_cons";
	String fileNameSuffix = "";
	String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
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

	String day=fecha.substring(0, 2);
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+userId+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".10");
		setDetail.addElement(".60");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");



	String groupBy = "",subGroupBy = "",groupByWh ="";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
    int cantArt = 0,cantDev=0,whCant=0;
	double subTotal =0.0,itbm=0.0,monto=0.00, grantotal = 0.00;
	pdfHeader(pc, _comp, pCounter, nPages, "DEVOLUCIONES DE MATERIALES A PROVEEDORES ", "Desde "+tDate+" Hasta "+fDate, userName, fecha);
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("Producto",1,1);
		pc.addCols("Descripción",0,1);
		pc.addCols("Cantidad",1,1);
		pc.addCols("Precio",2,1);
		pc.addCols("Total",2,1);

	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("id")))
			{
				if (i != 0)
				{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("Sub Total ",2,4,cHeight);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(subTotal),2,1,cHeight);
					pc.addTable();
					pc.createTable();
						pc.addCols("Itbm:  ",2,4,cHeight);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(""+itbm),2,1,cHeight);
					pc.addTable();
					pc.createTable();
						pc.addCols("Gran Total:  ",2,4,cHeight);
						pc.addCols(" "+CmnMgr.getFormattedDecimal(""+monto),2,1,cHeight);
					pc.addTable();
					pc.createTable();
						pc.addCols(" ",2,5,cHeight);
					pc.addTable();

					subTotal = 0;
					lCounter+=4;

				}

				}
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_provedor")))
			{
				if (i != 0)
				{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("Cantidad de Dev. x Proveedor : "+cantArt,0,setDetail.size(),cHeight);
					pc.addTable();

					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("",0,setDetail.size(),cHeight);
					pc.addTable();
					cantArt =0;
					lCounter+=2;
				}
			}


			if (!groupByWh.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
			{
				if (i != 0)
				{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("Cantidad de Dev. x Almacén : "+whCant,0,setDetail.size(),cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols("",0,setDetail.size(),cHeight);
					pc.addTable();
					whCant=0;
					lCounter+=2;
				}

			}

			if (!groupByWh.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
			{
				pc.setFont(7, 1);
				pc.createTable();
					pc.addCols("Almacén     : "+cdo.getColValue("codigo_almacen")+"   -   "+cdo.getColValue("almacen"),0,setDetail.size(),cHeight);
				pc.addTable();
				whCant=0;
				lCounter++;


			}

			if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_provedor")))
			{
				pc.setFont(7, 1);
				pc.createTable();
					pc.addCols("Proveedor    : "+cdo.getColValue("cod_provedor")+"   -   "+cdo.getColValue("devuelve"),0,setDetail.size(),cHeight);
				pc.addTable();
				lCounter++;
				cantArt = 0;

			}

			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("id")))
			{
				pc.setNoColumnFixWidth(setDetail);
				pc.setFont(7, 1);
				pc.createTable();
					pc.addCols(" Devolución  No. "+cdo.getColValue("anio_devolucion")+" - "+cdo.getColValue("num_devolucion"),0,3,cHeight);
					pc.addCols(" Nota de Crédito No.  "+cdo.getColValue("nCredito"),0,2,cHeight);
					//pc.addCols("User: "+cdo.getColValue("usuario"),1,1,cHeight);
				pc.addTable();

				pc.setNoColumnFixWidth(setDetail);
				pc.addCopiedTable("detailHeader");
				cantDev ++;
				cantArt ++;
				whCant ++;
				lCounter+=2;
				}



				pc.setFont(7, 0);
				pc.createTable();
					pc.addCols(""+cdo.getColValue("codigo"),1,1,cHeight);
					pc.addCols(""+cdo.getColValue("descripcion"),0,1,cHeight);
					pc.addCols(""+cdo.getColValue("cantidad"),1,1,cHeight);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("precio")),2,1,cHeight);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1,cHeight);
				pc.addTable();
				subTotal += Double.parseDouble(cdo.getColValue("total"));
				itbm = Double.parseDouble(cdo.getColValue("itbm"));
				monto = Double.parseDouble(cdo.getColValue("monto"));
				
				if(!(groupByWh+"_"+groupBy+"_"+subGroupBy).equals(cdo.getColValue("codigo_almacen")+"_"+cdo.getColValue("cod_provedor")+"_"+cdo.getColValue("id"))){
				grantotal += Double.parseDouble(cdo.getColValue("monto"));
				}

				lCounter++;


			if (lCounter >= maxLines)
			{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "DEVOLUCIONES DE MATERIALES A PROVEEDORES ", "Desde "+fDate+" Hasta "+tDate, userName, fecha);


			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1);
			pc.createTable();
				pc.addCols("Almacén     : "+cdo.getColValue("codigo_almacen")+"   -   "+cdo.getColValue("almacen"),0,setDetail.size(),cHeight);
			pc.addTable();

			pc.setFont(7, 1);
			pc.createTable();
				pc.addCols("Proveedor    : "+cdo.getColValue("cod_provedor")+"   -   "+cdo.getColValue("devuelve"),0,setDetail.size(),cHeight);
			pc.addTable();

		}

		subGroupBy = cdo.getColValue("id");
		groupBy = cdo.getColValue("cod_provedor");
		groupByWh = cdo.getColValue("codigo_almacen");

	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{

		pc.setFont(7, 1);
		pc.createTable();
			pc.addCols("Sub Total ",2,4,cHeight);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(subTotal),2,1,cHeight);
		pc.addTable();
		pc.createTable();
			pc.addCols("Itbm:  ",2,4,cHeight);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(itbm),2,1,cHeight);
		pc.addTable();
		pc.createTable();
			pc.addCols("Gran Total:  ",2,4,cHeight);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+monto),2,1,cHeight);
		pc.addTable();
		pc.createTable();
			pc.addCols(" ",2,5,cHeight);
		pc.addTable();
		pc.createTable();
			pc.addCols("MONTO TOTAL:  ",2,4,cHeight);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(""+grantotal),2,1,cHeight);
		pc.addTable();


		pc.setFont(7, 1);
		pc.createTable();
			pc.addCols("Cantidad de Dev. x Proveedor : "+cantArt,0,setDetail.size(),cHeight);
		pc.addTable();

		pc.createTable();
			pc.addCols("Cantidad de Dev. x Almacén : "+whCant,0,setDetail.size(),cHeight);
		pc.addTable();

		pc.createTable();
			pc.addCols("Cantidad Total de Dev. x Reporte : "+cantDev,0,setDetail.size(),cHeight);
		pc.addTable();
    }
	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>