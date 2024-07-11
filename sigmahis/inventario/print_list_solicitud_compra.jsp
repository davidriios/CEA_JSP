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
CommonDataObject cdo1 = new CommonDataObject();

String sql = "",desc ="";
String anio = request.getParameter("anio");
String id = request.getParameter("id");
String wh = request.getParameter("wh");

String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");



sql="SELECT a.requi_anio, a.requi_numero, a.compania, to_char(a.requi_fecha, 'dd/mm/yyyy') requi_fecha, a.estado_requi, 'PREPARADO POR: '||a.usuario_creacion||' - '||to_char(a.fecha_creacion,'dd/mm/yyyy') usuarioCrea,  decode(a.estado_requi,'A','Aprobado','P','Pendiente') desc_estado_requi, a.usuario_creacion, a.fecha_creacion, a.usuario_modificacion, a.fecha_modificacion, NVL(a.observaciones,' ') observaciones, NVL(a.monto_total,0) monto_total, NVL(a.subtotal,0) subtotal, NVL(a.itbm,0) itbm, nvl(a.activa,' ') activa, nvl(a.unidad_administrativa,0) unidad_administrativa, nvl(a.codigo_almacen,0) codigo_almacen, NVL(a.especificacion, ' ') especificacion, b.descripcion"
+ " FROM TBL_INV_REQUISICION a, tbl_inv_almacen b "
+ " where a.compania="+(String) session.getAttribute("_companyId")+" and a.codigo_almacen = b.codigo_almacen and a.compania = b.compania and a.requi_anio = "+anio+" and a.requi_numero = "+id+" and a.codigo_almacen = "+wh;

cdo1 = SQLMgr.getData(sql);


sql = "SELECT a.*, b.estado_renglon estadoRenglon, b.cantidad, b.costo, b.renglon, b.especificacion, b.comentario FROM (SELECT a.compania||'-'||a.cod_articulo art_key, a.compania, a.cod_flia artFamilia, a.cod_clase artClase, a.cod_articulo codArticulo,(a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo) as codigo, a.descripcion artDesc, a.itbm, a.cod_medida unidad, a.precio_venta, a.tipo, a.tipo_material, b.nombre descArtFamilia, c.descripcion descArtClase, d.precio, d.ultimo_precio ultimoPrecio FROM TBL_INV_ARTICULO a, TBL_INV_FAMILIA_ARTICULO b, TBL_INV_CLASE_ARTICULO c, TBL_INV_INVENTARIO d WHERE (d.compania = a.compania AND d.cod_articulo = a.cod_articulo) AND (a.compania = c.compania AND a.cod_flia = c.cod_flia AND a.cod_clase = c.cod_clase) AND (c.compania = b.compania AND c.cod_flia = b.cod_flia) AND d.compania = "+session.getAttribute("_companyId")+" AND d.codigo_almacen = "+wh+") a, (SELECT a.compania||'-'||a.cod_articulo art_key, a.estado_renglon, a.cantidad, a.precio_cotizado costo, a.renglon, a.especificacion, a.comentario FROM TBL_INV_DETALLE_REQ a WHERE a.compania = "+session.getAttribute("_companyId")+" /*AND a.estado_renglon = 'P'*/ AND a.requi_anio = "+anio+" and a.requi_numero = "+id+" and a.compania="+session.getAttribute("_companyId")+") b WHERE a.art_key = b.art_key order by b.renglon, b.especificacion asc,a.art_key  ";


al = SQLMgr.getDataList(sql);

System.out.println("al.size() ==  "+al.size());


if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 26; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	int nItems = al.size() +3 ;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";//print_articulos_consignacion.jsp
	String fileNamePrefix = "print_list_solicitud_compra";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";
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
		setDetail.addElement(".30");
		setDetail.addElement(".22");
		setDetail.addElement(".28");
		//setDetail.addElement(".08");//comentado por solicitud del personal de compras el dia 10/08/2009
		setDetail.addElement(".08");


	String  groupBy = "",subGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 22.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO","SOLICITUD DE COMPRA ", userName, fecha);
	
	pc.setNoColumnFixWidth(setDetail);



	pc.createTable();
		pc.setFont(9, 0);
		pc.addCols("Almacen: "+cdo1.getColValue("descripcion"),0,2);
		pc.addCols("Solicitud (Año - No. Solicitud): "+cdo1.getColValue("requi_anio")+" - "+cdo1.getColValue("requi_numero"),0,3);
	pc.addTable();
	pc.copyTable("detailHeader0");
	pc.createTable();
		pc.setFont(9, 0);
		pc.addCols("Departamento de Compras ",1,5);
	pc.addTable();
	pc.copyTable("detailHeader1");

	pc.createTable();
			pc.setFont(7, 1);
			pc.addBorderCols("CODIGO",1,1, 0.5f, 0.5f, 0.5f, 0.5f);
			pc.addBorderCols("DESCRIPCION",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
			pc.addBorderCols("ESPECIFICACIÓN",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
			pc.addBorderCols("COMENTARIO",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
			//pc.addBorderCols("UNIDAD",1); // benito: comentado por solicitud del personal de compras el dia 10 de agosto 2009 
			pc.addBorderCols("CANTIDAD",1,1 ,0.5f, 0.5f, 0.0f, 0.5f);
		pc.addTable();
		pc.copyTable("detailHeader");


	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		
		
		pc.setFont(9, 0);
		pc.createTable();
			pc.setVAlignment(3);
			pc.addBorderCols(""+cdo.getColValue("codigo"),0,1, 0.0f, 0.0f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(""+cdo.getColValue("artdesc"),0,1,0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(""+cdo.getColValue("especificacion"),0,1,0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(""+cdo.getColValue("comentario"),0,1,0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			//pc.addCols(""+cdo.getColValue("unidad"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("cantidad"),2,1,0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			
			

		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			pc.setFont(9, 0);
            pc.createTable();
            	pc.addBorderCols(" "+cdo1.getColValue("usuarioCrea"), 2, 5, 0.0f, 0.5f, 0.0f, 0.0f);
            pc.addTable();
			
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO","SOLICITUD DE COMPRA ", userName, fecha);

			pc.setNoColumnFixWidth(setDetail);

			pc.addCopiedTable("detailHeader0");
			pc.addCopiedTable("detailHeader1");
			pc.addCopiedTable("detailHeader");


		}


	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
	for (int z=0; z<maxLines -lCounter ; z++)
	{
		pc.setFont(9, 0);
		pc.createTable();
			pc.addBorderCols("",0,1, 0.0f, 0.0f, 0.5f, 0.5f);
			pc.addBorderCols("",0,1,0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols("",0,1,0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols("",0,1,0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols("",2,1,0.0f, 0.0f, 0.0f, 0.5f,cHeight);
		pc.addTable();
	}	
		pc.setFont(9, 0);
		pc.createTable();
			pc.addBorderCols(" "+cdo1.getColValue("usuarioCrea"), 2, 5, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>