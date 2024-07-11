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
		REPORTE:		INV0084.RDF
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
String appendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String wh_dev = request.getParameter("wh_dev");
String wh_rec = request.getParameter("wh_rec");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String anioDev = request.getParameter("anioDev");
String noDev = request.getParameter("noDev");
String fg = request.getParameter("fg");
if(fg== null) fg = "D";

if(wh_dev== null) wh_dev = "";
if(wh_rec== null) wh_rec = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(anioDev== null) anioDev = "";
if(noDev== null) noDev = "";

if(!wh_rec.trim().equals("")) appendFilter += " and al1.codigo_almacen = "+wh_rec;
if(!wh_dev.trim().equals("")) appendFilter += " and  al.codigo_almacen = "+wh_dev;

if(!tDate.trim().equals(""))
 appendFilter += "  and to_date(to_char(dev.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') >=  to_date('"+tDate+"','dd/mm/yyyy') ";
if(!fDate.trim().equals(""))
 appendFilter += "  and to_date(to_char(dev.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fDate+"','dd/mm/yyyy')";

//if(!fDate.trim().equals(""))   appendFilter += "  and to_date(to_char(dev.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fDate+"','dd/mm/yyyy')";
if(!anioDev.trim().equals("")) appendFilter += "  and  dev.anio_devolucion  = "+anioDev;
if(!noDev.trim().equals(""))   appendFilter += "  and  dev.num_devolucion  = "+noDev;

if(fg.trim().equals("D"))  appendFilter += "  and  dev.estado  = 'R' and dd.estado_renglon = 'E' ";// estado  R= recibido E= entregado por adecuacion para las devoluciones. 

sql="select dev.codigo_almacen alm_q_recibe, al.descripcion desc_alm_q_recibe, sr.anio||'-'||sr.solicitud_no||'-'||sr.tipo_solicitud cod_requisicion , sr.codigo_almacen alm_q_devuelve , al1.descripcion desc_alm_q_devuelve, dev.anio_devolucion||'-'||dev.num_devolucion cod_devolucion , em.anio||'-'|| em.no_entrega cod_entrega , dd.cod_familia||'-'||dd.cod_clase||'-'||dd.cod_articulo cod_articulos , ar.descripcion desc_articulo , nvl(dd.cantidad,0) cantidad , nvl(dd.precio,0) precio , nvl(dd.cantidad,0)*nvl(dd.precio,0) monto , to_char(dev.fecha_devolucion, 'dd/mm/yyyy') fecha,dev.observacion from tbl_inv_devolucion dev, tbl_inv_detalle_devolucion dd, tbl_inv_articulo ar, tbl_inv_almacen al, tbl_inv_entrega_material em , tbl_inv_solicitud_req sr, tbl_inv_almacen al1 where sr.tipo_transferencia = 'A' and dev.compania = "+compania+ appendFilter +" and ((dev.compania = al.compania) and (dev.codigo_almacen = al.codigo_almacen) and (dev.compania = em.compania) and (dev.no_entrega = em.no_entrega) and (dev.anio_entrega = em.anio) and (em.compania = al.compania) and (em.codigo_almacen = al.codigo_almacen) and (em.req_solicitud_no = sr.solicitud_no) and (em.req_tipo_solicitud = sr.tipo_solicitud) and (em.req_anio = sr.anio) and (sr.compania = al.compania) and (sr.codigo_almacen_ent = al.codigo_almacen) and (dd.compania = dev.compania) and (dd.num_devolucion = dev.num_devolucion) and (dd.anio_devolucion = dev.anio_devolucion) and (dd.cod_articulo = ar.cod_articulo) and (dd.cod_clase = ar.cod_clase) and (dd.cod_familia = ar.cod_flia) and (dd.compania = ar.compania) and (sr.codigo_almacen = al1.codigo_almacen) and (sr.compania = al1.compania)) order by  dev.codigo_almacen asc, al.descripcion asc , dev.anio_devolucion||'-'||dev.num_devolucion   asc ,sr.codigo_almacen,al1.descripcion asc,to_char(dev.fecha_devolucion, 'dd/mm/yyyy')  ";

al = SQLMgr.getDataList(sql);

int nWh =  CmnMgr.getCount("select count(*) from (select distinct dev.codigo_almacen  from tbl_inv_devolucion dev, tbl_inv_detalle_devolucion dd, tbl_inv_articulo ar, tbl_inv_almacen al, tbl_inv_entrega_material em , tbl_inv_solicitud_req sr, tbl_inv_almacen al1 where sr.tipo_transferencia = 'A' and dev.compania = "+compania+ appendFilter +" and ((dev.compania = al.compania) and (dev.codigo_almacen = al.codigo_almacen) and (dev.compania = em.compania) and (dev.no_entrega = em.no_entrega) and (dev.anio_entrega = em.anio) and (em.compania = al.compania) and (em.codigo_almacen = al.codigo_almacen) and (em.req_solicitud_no = sr.solicitud_no) and (em.req_tipo_solicitud = sr.tipo_solicitud) and (em.req_anio = sr.anio) and (sr.compania = al.compania) and (sr.codigo_almacen_ent = al.codigo_almacen) and (dd.compania = dev.compania) and (dd.num_devolucion = dev.num_devolucion) and (dd.anio_devolucion = dev.anio_devolucion) and (dd.cod_articulo = ar.cod_articulo) and (dd.cod_clase = ar.cod_clase) and (dd.cod_familia = ar.cod_flia) and (dd.compania = ar.compania) and (sr.codigo_almacen = al1.codigo_almacen) and (sr.compania = al1.compania)))");

int nDev =  CmnMgr.getCount("select count(*) from (select distinct dev.anio_devolucion, dev.num_devolucion from tbl_inv_devolucion dev, tbl_inv_detalle_devolucion dd, tbl_inv_articulo ar, tbl_inv_almacen al, tbl_inv_entrega_material em , tbl_inv_solicitud_req sr, tbl_inv_almacen al1 where sr.tipo_transferencia = 'A' and dev.compania = "+compania+ appendFilter +" and ((dev.compania = al.compania) and (dev.codigo_almacen = al.codigo_almacen) and (dev.compania = em.compania) and (dev.no_entrega = em.no_entrega) and (dev.anio_entrega = em.anio) and (em.compania = al.compania) and (em.codigo_almacen = al.codigo_almacen) and (em.req_solicitud_no = sr.solicitud_no) and (em.req_tipo_solicitud = sr.tipo_solicitud) and (em.req_anio = sr.anio) and (sr.compania = al.compania) and (sr.codigo_almacen_ent = al.codigo_almacen) and (dd.compania = dev.compania) and (dd.num_devolucion = dev.num_devolucion) and (dd.anio_devolucion = dev.anio_devolucion) and (dd.cod_articulo = ar.cod_articulo) and (dd.cod_clase = ar.cod_clase) and (dd.cod_familia = ar.cod_flia) and (dd.compania = ar.compania) and (sr.codigo_almacen = al1.codigo_almacen) and (sr.compania = al1.compania)))");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int nLine = 0;
	double total = 0.00;
	Hashtable htEntrega = new Hashtable();
	Hashtable htFamily = new Hashtable();
	int maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill


	int nItems = al.size() + (nDev*3)+nWh;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;
		//System.out.println(" nLine ==  "+nLine+"   al.size()  =   "+al.size()+"    altotal.size()    =   "+alTotal.size()+"    =  nItems =   "+nItems );

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_devoluciones_almacen";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
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

	Vector setDetail0 = new Vector();
		setDetail0.addElement(".30");
		setDetail0.addElement(".40");
		setDetail0.addElement(".30");

	String groupBy = "",subGroupBy = "";
	double subTotal =0.00;
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO - DEVOLUCIONES ENTRE ALMACENES "," DESDE    "+tDate+"    HASTA    "+fDate, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",0);
		pc.addBorderCols("CANTIDAD",1);
		pc.addBorderCols("PRECIO",1);
		pc.addBorderCols("MONTO",1);

	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_devolucion")))
			{
					if (i != 0)
					{

						pc.setFont(7, 1,Color.blue);
						pc.createTable();
							pc.addCols("SutTotal:  ",2,3,cHeight);
							pc.addCols(" "+CmnMgr.getFormattedDecimal(subTotal),2,2,cHeight);
						pc.addTable();

						lCounter++;
						subTotal =0;
					}
			}
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("alm_q_recibe")))
			{
				pc.setNoColumnFixWidth(setDetail);
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols(" "+cdo.getColValue("alm_q_recibe"),1,1,cHeight);
					pc.addCols(" "+cdo.getColValue("desc_alm_q_recibe"),1,4,cHeight);
				pc.addTable();
				lCounter++;

			}


			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_devolucion")))
			{
					pc.setNoColumnFixWidth(setDetail0);

					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("Devolución # :"+cdo.getColValue("cod_devolucion"),0,1,cHeight);
						pc.setFont(7, 1,Color.red);
						pc.addCols(" "+cdo.getColValue("alm_q_devuelve")+" - "+cdo.getColValue("desc_alm_q_devuelve"),0,1,cHeight);
						pc.setFont(7, 1);
						pc.addCols("Fecha :"+cdo.getColValue("fecha"),0,1,cHeight);
					 
						pc.addCols("Observacion:"+cdo.getColValue("observacion"),0,setDetail0.size(),cHeight); 
					pc.addTable();
					 

					pc.setNoColumnFixWidth(setDetail);
					pc.addCopiedTable("detailHeader");

					lCounter+=2;
			}



		pc.setFont(7, 0);
		pc.createTable();
			pc.addCols(""+cdo.getColValue("cod_articulos"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("cantidad"),1,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("precio")),1,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
		pc.addTable();
		lCounter++;
		total    += Double.parseDouble(cdo.getColValue("monto"));
		subTotal += Double.parseDouble(cdo.getColValue("monto"));

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

				pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO - DEVOLUCIONES ENTRE ALMACENES "," DESDE    "+tDate+"    HASTA    "+fDate, userName, fecha);

				pc.setNoColumnFixWidth(setDetail);
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols(" "+cdo.getColValue("alm_q_recibe"),1,1,cHeight);
					pc.addCols(" "+cdo.getColValue("desc_alm_q_recibe"),0,4,cHeight);
				pc.addTable();
				pc.setNoColumnFixWidth(setDetail0);
				pc.setFont(7, 1);
				pc.createTable();
					pc.addCols("Devolución # :"+cdo.getColValue("cod_devolucion"),0,1,cHeight);
					pc.setFont(7, 1,Color.red);
					pc.addCols(" "+cdo.getColValue("alm_q_devuelve")+" - "+cdo.getColValue("desc_alm_q_devuelve"),0,1,cHeight);
					pc.setFont(7, 1);
					pc.addCols("Fecha :"+cdo.getColValue("fecha"),0,1,cHeight);
				pc.addTable();

				pc.setNoColumnFixWidth(setDetail);
				pc.addCopiedTable("detailHeader");
		}

		groupBy    = cdo.getColValue("alm_q_recibe");
		subGroupBy = cdo.getColValue("cod_devolucion");
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
			pc.setFont(7, 1,Color.blue);
			pc.createTable();
				pc.addCols("SutTotal:  ",2,3,cHeight);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(""+subTotal),2,2,cHeight);
			pc.addTable();

			lCounter++;

			pc.createTable();
				pc.addCols("T O T A L:  ",2,3,cHeight);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(""+total),2,2,cHeight);
			pc.addTable();
	}


	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>