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
		REPORTE:		INV0031.RDF
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
ArrayList alRes = new ArrayList();
ArrayList alProv = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String depto = request.getParameter("depto");
String anioEntrega = request.getParameter("anioEntrega");
String anioReq = request.getParameter("anioReq");
String noReq = request.getParameter("noReq");
String noEntrega = request.getParameter("noEntrega");
String articulo = request.getParameter("articulo");

String titulo = request.getParameter("titulo");
String descDepto = request.getParameter("descDepto");

	String fp = request.getParameter("fp");
	String anaquelx = request.getParameter("anaquelx");
	String anaquely = request.getParameter("anaquely");
	String tipo = request.getParameter("tipo");
	String punto = request.getParameter("punto");
	String existencia = request.getParameter("existencia");
	String familia = request.getParameter("familia");
	String clase = request.getParameter("clase");


if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(depto== null) depto = "";
if(anioEntrega== null) anioEntrega = "";
if(anioReq== null) anioReq = "";
if(noReq== null) noReq = "";
if(noEntrega== null) noEntrega = "";
if(articulo== null) articulo = "";
if(titulo== null) titulo = "";
if(descDepto== null) descDepto = "";


	if(appendFilter== null) appendFilter="";
	if(fp== null) fp="CSE";
	if(anaquelx== null) anaquelx = "";
	if(anaquely== null) anaquely = "";
	if(tipo== null) tipo = "";
	if(familia== null) familia = "";
	if(clase== null) clase = "";
	if(existencia== null) existencia = "";
	if(punto== null) punto = "";

	if (fp.trim().equals("CPR"))
	descDepto = "COSTOS DE ARTICULOS POR ALMACEN PARA TODOS CON PUNTO DE REORDEN";
	else
	descDepto = "COSTOS DE ARTICULOS POR ALMACEN CON/SIN EXISTENCIA";

	if ((existencia.trim().equals("S"))&& fp.trim().equals("CSE"))
		{
		appendFilter += " and a.disponible <= 0 and b.tipo not like 'A' and b.estado like 'A' and d.cod_flia not in (31) ";
		descDepto = "COSTOS DE ARTICULOS POR ALMACEN SIN EXISTENCIA ";
  		}
	else if ((existencia.trim().equals("N"))&& fp.trim().equals("CSE"))
		{
		appendFilter += " and a.disponible > 0 and b.consignacion_sino = 'N' " ;
		descDepto = "COSTOS DE ARTICULOS POR ALMACEN CON EXISTENCIA";
		}

	if ((punto.trim().equals("S"))&& fp.trim().equals("CPR"))
	{

	    appendFilter += " and a.pto_reorden > a.disponible and a.pto_reorden is not null" ;
		descDepto = "COSTOS DE ARTICULOS POR ALMACEN SOLO ARTICULOS CON PUNTO DE REORDEN";
	}
	else if ((punto.trim().equals("N"))&& fp.trim().equals("CPR"))
	{
		appendFilter += " and a.disponible > 0 and b.consignacion_sino = 'N' and a.pto_reorden is not null" ;
		descDepto = "COSTOS DE ARTICULOS POR ALMACEN PARA TODOS CON PUNTO DE REORDEN";
	}

if (appendFilter == null) appendFilter = "";

sql= "select e.codigo_almacen as codAlmacen, e.descripcion as descAlmacen, d.cod_flia as codFamilia, d.nombre as descFamilia, c.cod_clase as codClase, c.descripcion as descClase, b.cod_articulo as codArticulo, a.pto_reorden as punto, d.cod_flia||'-'||c.cod_clase||'-'||b.cod_articulo as codArticulos, b.descripcion as descArticulo, a.disponible as existencia, a.precio as costo, a.ultimo_precio ultimoCosto, nvl(a.disponible,'0')*nvl(a.precio,0) as costoTotal, a.pto_reorden as punto,to_char(a.ultima_compra ,'dd/mm/yyyy') as fecha from tbl_inv_inventario a, tbl_inv_articulo b, tbl_inv_clase_articulo c, tbl_inv_familia_articulo d, tbl_inv_almacen e  where ((a.compania = b.compania and a.cod_articulo = b.cod_articulo) and (b.compania = c.compania and b.cod_flia = c.cod_flia and b.cod_clase = c.cod_clase) and (c.compania = d.compania and c.cod_flia = d.cod_flia) and (a.compania=e.compania and a.codigo_almacen=e.codigo_almacen)) and (a.compania = nvl('"+compania+"',a.compania)   and e.codigo_almacen = nvl('"+almacen+"',e.codigo_almacen) and a.art_familia = nvl('"+familia+"',d.cod_flia) and a.art_clase = nvl('"+clase+"',c.cod_clase) and a.cod_articulo = nvl('"+articulo+"',b.cod_articulo) and b.tipo = nvl('"+tipo+"',b.tipo))"+appendFilter+"  order by e.descripcion, d.nombre, c.descripcion, b.descripcion";
al = SQLMgr.getDataList(sql);


sql= "select e.codigo_almacen as codAlmacen, e.descripcion as descAlmacen, d.cod_flia as codFamilia, d.nombre as descFamilia, count(*) as count, sum(nvl(a.disponible,'0')*nvl(a.precio,0)) as costoTotal from tbl_inv_inventario a, tbl_inv_articulo b, tbl_inv_clase_articulo c, tbl_inv_familia_articulo d, tbl_inv_almacen e  where ((a.compania = b.compania and a.cod_articulo = b.cod_articulo) and  (b.compania = c.compania and b.cod_flia = c.cod_flia  and b.cod_clase = c.cod_clase) and (c.compania = d.compania and  c.cod_flia = d.cod_flia) and (a.compania=e.compania and a.codigo_almacen=e.codigo_almacen)) and (a.compania = nvl('"+compania+"',a.compania)   and e.codigo_almacen = nvl('"+almacen+"',e.codigo_almacen) and a.art_familia = nvl('"+familia+"',d.cod_flia) and a.art_clase = nvl('"+clase+"',c.cod_clase) and a.cod_articulo = nvl('"+articulo+"',b.cod_articulo) and b.tipo = nvl('"+tipo+"',b.tipo))"+appendFilter+" group by e.codigo_almacen, e.descripcion, d.cod_flia, d.nombre order by e.descripcion, d.nombre";
alTotal = SQLMgr.getDataList(sql);

sql="select fa.nivel, sum(i.disponible*i.precio) as costototal from tbl_inv_inventario i, tbl_inv_articulo ar, tbl_inv_clase_articulo ca, tbl_inv_familia_articulo fa, tbl_inv_almacen al where ((i.compania = ar.compania and i.cod_articulo = ar.cod_articulo) and (ar.compania = ca.compania and ar.cod_flia = ca.cod_flia and ar.cod_clase = ca.cod_clase) and (ca.compania = fa.compania and ca.cod_flia = fa.cod_flia) and (i.compania = al.compania and i.codigo_almacen = al.codigo_almacen)) and i.disponible > 0 and ar.consignacion_sino = 'N' and (i.compania = nvl('"+compania+"',i.compania) and i.codigo_almacen = nvl('"+almacen+"',i.codigo_almacen) and i.art_familia = nvl('"+familia+"',fa.cod_flia) and i.art_clase = nvl('"+clase+"',ca.cod_clase) and i.cod_articulo = nvl('"+articulo+"',ar.cod_articulo) and ar.tipo = nvl('"+tipo+"',ar.tipo)) group by fa.nivel";
alRes = SQLMgr.getDataList(sql);

sql="select max(rm.anio_recepcion||'-'||rm.numero_documento) rec, pr.cod_provedor, pr.nombre_proveedor as nombreProv, dr.COD_FAMILIA||'-'||dr.COD_CLASE||'-'||dr.COD_ARTICULO as codArticulos from tbl_inv_detalle_recepcion dr, tbl_inv_recepcion_material rm, tbl_com_proveedor pr where (dr.compania = rm.compania and dr.numero_documento = rm.numero_documento and dr.anio_recepcion = rm.anio_recepcion) and rm.cod_proveedor = pr.cod_provedor and rm.compania = pr.compania and rm.estado='R' group by pr.COD_PROVEDOR, pr.nombre_proveedor,dr.COD_FAMILIA||'-'||dr.COD_CLASE||'-'||dr.COD_ARTICULO";
alProv = SQLMgr.getDataList(sql);




if (request.getMethod().equalsIgnoreCase("GET"))
{
	int cantidad = alTotal.size();
	int totAlm = 0;
	double total = 0.00;
	Hashtable htAlmacen = new Hashtable();
	Hashtable htFamily = new Hashtable();
	Hashtable htProveedor = new Hashtable();
	int maxLines = 45; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	if(fp.trim().equals("CSE"))
		cantidad = (cantidad *5) + alRes.size();
	else
		cantidad = cantidad *3;

	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);
		 totAlm += Integer.parseInt(cdo.getColValue("count"));
		 total    += Double.parseDouble(cdo.getColValue("costoTotal"));
		 htAlmacen.put(cdo.getColValue("descAlmacen")+"-"+cdo.getColValue("descFamilia"),cdo.getColValue("costoTotal"));

	}

	for (int j=0; j<alProv.size(); j++)
	{
	 CommonDataObject cdo1 = (CommonDataObject) alProv.get(j);
	  htProveedor.put(cdo1.getColValue("codArticulos"),cdo1.getColValue("nombreProv"));

	}

   	int nItems = al.size() + cantidad;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "compras";
	String fileNamePrefix = "print_consin_existencia";
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
		setDetail.addElement(".15");
		setDetail.addElement(".25");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");



	Vector setDetail0 = new Vector();
		setDetail0.addElement(".30");
		setDetail0.addElement(".20");
		setDetail0.addElement(".20");
		setDetail0.addElement(".30");



	String groupBy = "",subGroupBy = "",proveedor ="";
	int lCounter = 0;
	int pCounter = 1;
	int sw = 0;
	float cHeight = 12.0f;

	pdfHeader(pc, _comp, pCounter, nPages, " "+descDepto,""+titulo, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

		pc.setFont(7, 1);
		pc.addBorderCols("CODIGO",0,1);

	if(fp.trim().equals("CSE"))
	{
		pc.addBorderCols("DESC. ARTICULO",0,3);
		pc.addBorderCols("EXISTENCIA",1,1);
		pc.addBorderCols("COSTO",2,1);
		pc.addBorderCols("ULT.COSTO",2,1);
		pc.addBorderCols("MONTO",2,1);
	}
	else
	{
		pc.addBorderCols("DESC. ARTICULO",0,1);
		pc.addBorderCols("DISPONIBLE",1,1);
		pc.addBorderCols("COSTO",2,1);
		pc.addBorderCols("ULT.COMPRA",2,1);
		pc.addBorderCols("PROVEEDOR",1,2);
		pc.addBorderCols("PTO.REORDEN",2,1);
	}
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		 if (!groupBy.equalsIgnoreCase(cdo.getColValue("codAlmacen")))
 		 {
			 pc.setNoColumnFixWidth(setDetail0);
					pc.setFont(8, 1,Color.red);
					pc.createTable();
						pc.addCols(" "+cdo.getColValue("descAlmacen"),2,setDetail.size(),cHeight);
					pc.addTable();

			}
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("descAlmacen")+"-"+cdo.getColValue("descFamilia")))
			{
					if (i != 0 )
					{
					if(fp.trim().equals("CSE"))
					{
					pc.setFont(7, 1);
					pc.createTable();
						pc.addCols("SutTotal: $ ",2,6,cHeight);
						pc.addCols(" "+CmnMgr.getFormattedDecimal((String) htAlmacen.get(subGroupBy)),2,2,cHeight);
					pc.addTable();
						lCounter+=2;
					}
					}

					pc.setNoColumnFixWidth(setDetail0);
					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addCols(" "+cdo.getColValue("descFamilia"),1,setDetail.size(),cHeight);
					pc.addTable();


					pc.setNoColumnFixWidth(setDetail);
					pc.addCopiedTable("detailHeader");

					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addCols(""+cdo.getColValue("descClase"),0,setDetail.size(),cHeight);
					pc.addTable();

					lCounter+=3;
			}

		pc.setFont(7, 0);
		pc.createTable();
			pc.addCols(""+cdo.getColValue("codArticulos"),0,1,cHeight);

		if(fp.trim().equals("CSE"))
			{
			pc.addCols(""+cdo.getColValue("descArticulo"),0,3,cHeight);
			pc.addCols(""+cdo.getColValue("existencia"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("costo"),2,1,cHeight);
			pc.addCols(""+cdo.getColValue("ultimoCosto"),2,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("costoTotal")),2,1,cHeight);
			}
		else
			{
			pc.addCols(""+cdo.getColValue("descArticulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("existencia"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("costo"),2,1,cHeight);
			pc.addCols(""+cdo.getColValue("fecha"),1,1,cHeight);
			pc.addCols(""+(((String) htProveedor.get(cdo.getColValue("codArticulos")))==null?"":((String) htProveedor.get(cdo.getColValue("codArticulos")))),0,2,cHeight);
			pc.addCols(""+cdo.getColValue("punto"),2,1,cHeight);
			}

		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, " "+descDepto, ""+titulo, userName, fecha);

			pc.setNoColumnFixWidth(setDetail0);
					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addCols(" "+cdo.getColValue("descFamilia"),1,setDetail.size(),cHeight);
					pc.addTable();


					pc.setNoColumnFixWidth(setDetail);
					pc.addCopiedTable("detailHeader");

					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addCols(""+cdo.getColValue("descClase"),0,setDetail.size(),cHeight);
					pc.addTable();
		}

		groupBy    = cdo.getColValue("codAlmacen");
		subGroupBy = cdo.getColValue("descAlmacen")+"-"+cdo.getColValue("descFamilia");
		sw=0;
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
			if(fp.trim().equals("CSE"))
			{
			pc.setFont(7, 1,Color.red);
			pc.createTable();
				pc.addCols("",0,setDetail.size(),cHeight);
			pc.addTable();

			pc.setFont(7, 1);
			pc.createTable();
				pc.addCols("SutTotal: $ ",2,6,cHeight);
				pc.addCols(" "+CmnMgr.getFormattedDecimal((String) htAlmacen.get(subGroupBy)),2,2,cHeight);
			pc.addTable();

			lCounter+=2;

			pc.createTable();
				pc.addCols("",0,setDetail.size(),cHeight);
			pc.addTable();

			pc.createTable();
				pc.addCols("Total: $ ",2,6,cHeight);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(""+total),2,2,cHeight);
			pc.addTable();

			pc.createTable();
				pc.addCols("Cantidad Total de Articulos  :  ",2,6,cHeight);
				pc.addCols(" "+totAlm,2,2,cHeight);
			pc.addTable();


			pc.createTable();
				pc.addCols("",0,setDetail.size(),cHeight);
			pc.addTable();

		if (lCounter+alRes.size() >= maxLines)
			{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, " "+descDepto, ""+titulo, userName, fecha);
			}
		if (existencia.trim().equals("C"))
		{
		pc.setNoColumnFixWidth(setDetail0);
		pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("",0,1);
		pc.addBorderCols("RESUMEN DE EXISTENCIA POR NIVEL",1,2);
		pc.addCols("",1,1);
		pc.addTable();

		for (int j=0; j<alRes.size(); j++)
		{
			CommonDataObject cdo1 = (CommonDataObject) alRes.get(j);

			pc.createTable();
			pc.setFont(7, 1);
			pc.addCols("",0,1);
			pc.addBorderCols(""+cdo1.getColValue("nivel"),1,1);
			pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("costoTotal")),2,1);
			pc.addCols("",1,1);
			pc.addTable();

		}
				pc.createTable();
				pc.addCols("Gran Total ",2,2,cHeight);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(""+total),2,1,cHeight);
				pc.addCols(" ",2,1,cHeight);
			pc.addTable();
		}
	}
	}


	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>