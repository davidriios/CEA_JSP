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
		FG             	REPORTE                DESCRIPCION
		DUA          	INV00106.RDF       	   DEVOLUCIONES DE UNIDADES ADMINISTRATIVAS

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

String sql = "",desc ="";
String appendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fp = request.getParameter("fp");
String compania = request.getParameter("compania");//(String) session.getAttribute("_companyId");

String almacen = request.getParameter("almacen");
String anio    = request.getParameter("anio");
String titulo  = request.getParameter("titulo");
String depto   = request.getParameter("depto");
String tDate   = request.getParameter("tDate");
String fDate   = request.getParameter("fDate");
String codigo  = request.getParameter("codigo");
String unidad  = request.getParameter("unidad");
String subTitle  = "DEVOLUCION DE UNIDADES ADMINISTRATIVA A DEPOSITO";
String fg  = request.getParameter("fg");
String codDev ="";
String order = "";
if (fg == null) fg = "D";
if (compania == null) compania =(String) session.getAttribute("_companyId");
if (almacen == null) almacen = "";
if (anio == null) anio = "";
if (titulo == null) titulo = "";
if (depto == null) depto = "";
if (tDate == null) tDate = "";
if (fDate == null) fDate = "";
if (codigo == null) codigo = "";
if (unidad == null) unidad = "";

if (!almacen.trim().equals("")) appendFilter += " and d.codigo_almacen="+almacen+"";
if (!anio.trim().equals(""))    appendFilter += " and d.anio_devolucion="+anio;
if (!codigo.trim().equals(""))  appendFilter += " and d.num_devolucion="+codigo;
if (!unidad.trim().equals(""))  appendFilter += " and d.unidad_administrativa  ="+unidad;


if (!tDate.trim().equals(""))
appendFilter += " and to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+tDate+"','dd/mm/yyyy') ";


if (!fDate.trim().equals(""))
appendFilter += " and to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fDate+"','dd/mm/yyyy')";

if(fg.trim().equals("D"))
{
 appendFilter += " and  d.estado = 'R' and det.estado_renglon ='E' ";
 order = "  order by ue.descripcion asc,al.descripcion asc, fa.nombre asc ";
}
else order = " order by det.renglon asc";

if(!fg.trim().equals("D"))codDev = "  DEVOLUCION #  "+anio+" - "+codigo;


sql = "select d.unidad_administrativa unidad, d.codigo_almacen , ue.descripcion desc_unidad, al.descripcion desc_almacen , fa.nombre desc_familia, det.cod_familia familia, det.cod_familia ||'-'||det.cod_clase ||'-'||det.cod_articulo codigo_articulo , ar.descripcion desc_articulo, sum(nvl(det.cantidad,0)) cantidad , sum(nvl(det.precio,0) * nvl(det.cantidad,0)) precio , decode(det.estado_renglon, 'E', 'ENTREGADO','P','PENDIENTE','R','RECHAZADO') estado_renglon, det.renglon, d.cod_ref from tbl_inv_devolucion d , tbl_inv_detalle_devolucion det, tbl_inv_articulo ar, tbl_sec_unidad_ejec ue, tbl_inv_almacen al, tbl_inv_clase_articulo ca, tbl_inv_familia_articulo fa where  d.compania = "+compania+appendFilter+" and (det.compania = d.compania and det.num_devolucion = d.num_devolucion and det.anio_devolucion = d.anio_devolucion) and (det.cod_articulo = ar.cod_articulo and det.cod_clase = ar.cod_clase and det.cod_familia = ar.cod_flia and d.compania_dev  = ar.compania ) and (d.unidad_administrativa = ue.codigo and d.compania = ue.compania) and (d.compania_dev = al.compania and d.codigo_almacen = al.codigo_almacen) and (ar.compania = ca.compania and ar.cod_flia = ca.cod_flia and ar.cod_clase = ca.cod_clase) and (ca.compania = fa.compania and ca.cod_flia = fa.cod_flia) group by d.unidad_administrativa , d.codigo_almacen , ue.descripcion , al.descripcion , fa.nombre, det.cod_familia , det.cod_familia ||'-'||det.cod_clase ||'-'||det.cod_articulo , ar.descripcion, decode(det.estado_renglon, 'E', 'ENTREGADO','P','PENDIENTE','R','RECHAZADO'), det.renglon, d.cod_ref "+order;
al = SQLMgr.getDataList(sql);

sql = " select  'TU' type,d.unidad_administrativa unidad , d.codigo_almacen, ue.descripcion desc_unidad, al.descripcion almacen,  sum(nvl(det.precio,0) * nvl(det.cantidad,0)) precio, 0 familia from tbl_inv_devolucion d , tbl_inv_detalle_devolucion det, tbl_inv_articulo ar, tbl_sec_unidad_ejec ue, tbl_inv_almacen al, tbl_inv_clase_articulo ca, tbl_inv_familia_articulo fa where  /*and   d.compania_dev =  nvl ( :p_compania_dev , d.compania_dev)*/ d.compania = "+compania+appendFilter+" and (det.compania = d.compania and det.num_devolucion = d.num_devolucion and det.anio_devolucion = d.anio_devolucion) and (det.cod_articulo = ar.cod_articulo and det.cod_clase = ar.cod_clase and det.cod_familia = ar.cod_flia and d.compania_dev = ar.compania ) and (d.unidad_administrativa = ue.codigo and d.compania = ue.compania) and (d.compania_dev = al.compania and d.codigo_almacen = al.codigo_almacen) and (ar.compania = ca.compania and ar.cod_flia = ca.cod_flia and ar.cod_clase = ca.cod_clase) and (ca.compania = fa.compania and ca.cod_flia = fa.cod_flia) group by ue.descripcion, al.descripcion, d.unidad_administrativa, d.codigo_almacen ";

sql += " union   select  'FA' type,d.unidad_administrativa , d.codigo_almacen , ue.descripcion unidad, al.descripcion almacen,  sum(nvl(det.precio,0) * nvl(det.cantidad,0)) precio, det.cod_familia from tbl_inv_devolucion d , tbl_inv_detalle_devolucion det, tbl_inv_articulo ar, tbl_sec_unidad_ejec ue, tbl_inv_almacen al, tbl_inv_clase_articulo ca, tbl_inv_familia_articulo fa where  /*and   d.compania_dev =  nvl ( :p_compania_dev , d.compania_dev)*/ d.compania = "+compania+appendFilter+" and (det.compania = d.compania and det.num_devolucion = d.num_devolucion and det.anio_devolucion = d.anio_devolucion) and (det.cod_articulo = ar.cod_articulo and det.cod_clase = ar.cod_clase and det.cod_familia = ar.cod_flia and d.compania_dev = ar.compania) and (d.unidad_administrativa = ue.codigo and d.compania = ue.compania) and (d.compania_dev = al.compania and d.codigo_almacen = al.codigo_almacen) and (ar.compania = ca.compania and ar.cod_flia = ca.cod_flia and ar.cod_clase = ca.cod_clase) and (ca.compania = fa.compania and ca.cod_flia = fa.cod_flia) group by  ue.descripcion, al.descripcion, d.unidad_administrativa, d.codigo_almacen , det.cod_familia";

alTotal = SQLMgr.getDataList(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	double total = 0.00;
	Hashtable htUnidad = new Hashtable();
	Hashtable htFamily = new Hashtable();
	int maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill


	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);
		if(cdo.getColValue("type").trim().equals("TU"))
		{
		  total    += Double.parseDouble(cdo.getColValue("precio"));
		  htUnidad.put(cdo.getColValue("unidad")+"-"+cdo.getColValue("codigo_almacen"),cdo.getColValue("precio"));
		}
		else if(cdo.getColValue("type").trim().equals("FA"))
		{
		  htFamily.put(cdo.getColValue("unidad")+"-"+cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("familia"),cdo.getColValue("precio"));
		}

	}





	int nItems = al.size() + (alTotal.size()*3);
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_devoluciones";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"-"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
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
		setDetail.addElement(".55");
		setDetail.addElement(".15");
		setDetail.addElement(".15");

	Vector setDetail0 = new Vector();
		setDetail0.addElement(".50");
		setDetail0.addElement(".50");


	String groupBy = "",subGroupBy = "",observ ="";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, " "+subTitle, "", userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",0);
		pc.addBorderCols("CANTIDAD",1);
		pc.addBorderCols("PRECIO",1);

	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("familia")))
			{
					if (i != 0)
					{
						pc.setFont(7, 1);
						pc.createTable();
							pc.addCols("Total x Familia  ",2,2,cHeight);
							pc.addCols(" "+CmnMgr.getFormattedDecimal((String) htFamily.get(subGroupBy)),2,2,cHeight);
						pc.addTable();

						lCounter++;
					}

			}
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("codigo_almacen")))
			{
					if (i != 0)
					{
						pc.setFont(7, 1);
						pc.createTable();
							pc.addCols("Total x Unidad  ",2,2,cHeight);
							pc.addCols(" "+CmnMgr.getFormattedDecimal((String) htUnidad.get(groupBy)),1,2,cHeight);
						pc.addTable();
						pc.setFont(7, 1);
						pc.createTable();
							pc.addCols(" ",0,setDetail.size(),cHeight);
						pc.addTable();
						lCounter+=2;
					}

					pc.setNoColumnFixWidth(setDetail0);
					pc.setFont(7, 1,Color.red);
					pc.createTable();
						pc.addCols(" "+cdo.getColValue("desc_unidad")+ "  "+codDev,0,1,cHeight);
						pc.setFont(7, 1,Color.blue);
						pc.addCols(" "+cdo.getColValue("desc_almacen")+" ***  Cód. Ref.: "+cdo.getColValue("cod_ref",""),0,1,cHeight);
					pc.addTable();

					/*pc.setNoColumnFixWidth(setDetail);
					pc.addCopiedTable("detailHeader");*/

					lCounter++;
			}
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("familia")))
			{
					pc.setNoColumnFixWidth(setDetail0);
					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addCols(" "+cdo.getColValue("desc_familia"),0,setDetail.size());
					pc.addTable();

					pc.setNoColumnFixWidth(setDetail);
					pc.addCopiedTable("detailHeader");

					lCounter+=2;
			}




		pc.setFont(7, 0);
		pc.createTable();
			pc.addCols(""+cdo.getColValue("codigo_articulo"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("cantidad"),1,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("precio")),2,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, " "+subTitle, "", userName, fecha);

					pc.setNoColumnFixWidth(setDetail0);
					pc.setFont(7, 1,Color.red);
					pc.createTable();
						pc.addCols(" AAA "+cdo.getColValue("desc_unidad")+"  "+codDev,0,1,cHeight);
					pc.setFont(7, 1,Color.blue);
						pc.addCols(" "+cdo.getColValue("desc_almacen")+" ***  Cód. Ref.: "+cdo.getColValue("cod_ref",""),0,1,cHeight);
					pc.addTable();

					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addCols(" "+cdo.getColValue("desc_familia"),0,setDetail0.size());
					pc.addTable();

					pc.setNoColumnFixWidth(setDetail);
					pc.addCopiedTable("detailHeader");
		}

		groupBy    = cdo.getColValue("unidad")+"-"+cdo.getColValue("codigo_almacen");
		subGroupBy = cdo.getColValue("unidad")+"-"+cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("familia");
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
				pc.addCols("Total x Familia  ",2,2,cHeight);
				pc.addCols(" "+CmnMgr.getFormattedDecimal((String) htFamily.get(subGroupBy)),2,2,cHeight);
			pc.addTable();

			pc.setFont(7, 1);
			pc.createTable();
				pc.addCols("Total x Unidad  ",2,2,cHeight);
				pc.addCols(" "+CmnMgr.getFormattedDecimal((String) htUnidad.get(groupBy)),1,2,cHeight);
			pc.addTable();

			lCounter++;

			pc.createTable();
				pc.addCols("Gran Total:  "+CmnMgr.getFormattedDecimal(""+total),0,5,cHeight);
			pc.addTable();

	}


	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>