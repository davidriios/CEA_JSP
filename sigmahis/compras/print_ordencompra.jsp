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

String sql = "", key="";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
String anio = request.getParameter("anio");
String numId = request.getParameter("id");
String fp = request.getParameter("fp");
String tp = request.getParameter("tp");
String wh = request.getParameter("wh");
int lineNo = 0;

if (anio == null) anio = "";
if (numId == null) numId = "";

if (appendFilter == null) appendFilter = "";
/*
 sql = "select (b.cod_familia||'-'||b.cod_clase||'-'||b.cod_articulo) as codigoArt, b.cantidad, c.cod_medida as medida, c.descripcion as articuloDesc, b.especificacion, b.comentario, b.requi_anio||'-'||b.requi_numero as orden from tbl_inv_detalle_req b, tbl_inv_articulo c where b.requi_anio = '"+anio+"' and b.requi_numero = '"+numId+"' and b.compania = "+(String) session.getAttribute("_companyId")+" and c.cod_flia = b.cod_familia and c.cod_clase = b.cod_clase and c.cod_articulo = b.cod_articulo and c.compania = b.compania order by b.cod_familia, b.cod_clase, b.cod_articulo";
 */

 sql = "SELECT a.*, b.* FROM (SELECT a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo codigoArt, a.compania, a.cod_flia codFlia, a.cod_clase codClase, a.cod_articulo codArticulo, a.descripcion articuloDesc, a.itbm, a.cod_medida medida, a.precio_venta, a.tipo, a.tipo_material, b.nombre descArtFamilia, c.descripcion descArtClase FROM TBL_INV_ARTICULO a, TBL_INV_FAMILIA_ARTICULO b, TBL_INV_CLASE_ARTICULO c WHERE (a.compania = c.compania AND a.cod_flia = c.cod_flia AND a.cod_clase = c.cod_clase) AND (c.compania = b.compania AND c.cod_flia = b.cod_flia) AND a.compania = "+session.getAttribute("_companyId")+") a, (SELECT a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo codigoArt, NVL(anio_requi,0) aniorequi, NVL(requi_num,0) requinum, a.cantidad as cantidad, a.cf_anio||'-'||a.cf_num_doc as orden, monto_articulo monto, round(cantidad*monto_articulo,6) total, entregado, a.estado_renglon estadorenglon, especificacion, ''comentario FROM TBL_COM_DETALLE_COMPROMISO a WHERE a.cf_tipo_com = 1 and a.compania = "+session.getAttribute("_companyId")+" AND a.cf_anio = "+anio+" AND a.cf_num_doc = "+numId+") b WHERE a.codigoArt = b.codigoArt order by a.codflia, a.codclase, a.codarticulo";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int bed = 0;
	double price = 0.00;
	Hashtable htUse = new Hashtable();
	Hashtable htPrice = new Hashtable();
	int maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_ordencompra";
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

	Vector setCol=new Vector();
		   setCol.addElement(".80");
		   setCol.addElement(".20");


	Vector setDetail = new Vector();
		setDetail.addElement(".15");
		setDetail.addElement(".35");
		setDetail.addElement(".15");
		setDetail.addElement(".15");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 12.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "ORDEN DE COMPRA", "AL "+cDateTime.substring(0,10), userName, fecha,"",null);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(8, 1);
		pc.addCols(" TELEFONO: 305-6374   FAX: 305-6378  ", 1,6);
	pc.addTable();

	pc.createTable();
		pc.setFont(7, 1);
			pc.addBorderCols("CODIGO",0, 1, 0.5f, 0.5f, 0.5f, 0.5f);
			pc.addBorderCols("DESCRIPCION",1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
			pc.addBorderCols("ESPECIFICACION",1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
			pc.addBorderCols("COMENTARIO",1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
			pc.addBorderCols("UNIDAD",1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
			pc.addBorderCols("CANTIDAD",2, 1, 0.5f, 0.5f, 0.5f, 0.5f);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("orden")))
		{

			pc.setNoColumnFixWidth(setCol);
						pc.createTable();
							pc.setFont(8, 1,Color.blue);
							pc.addCols("Solicitud No. :   "+anio+" - "+numId, 0,1);
							pc.addCols("", 2,1);
						pc.addTable();

						pc.setNoColumnFixWidth(setCol);
						pc.createTable();
							pc.setFont(8, 1,Color.blue);
							pc.addCols("Departamento de Compras. ", 0,2);

						pc.addTable();
						pc.setNoColumnFixWidth(setDetail);
			pc.addCopiedTable("detailHeader");
		}

				pc.setNoColumnFixWidth(setDetail);
						pc.createTable();
						pc.setFont(7, 0, Color.red);
				  			pc.setFont(6, 0);
			pc.addBorderCols(" "+cdo.getColValue("codigoArt"),0, 1, 0.0f, 0.0f, 0.5f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("articuloDesc"),0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("especificacion"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);									         	pc.addBorderCols(" "+cdo.getColValue("comentario"),0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("medida"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("cantidad"),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "ORDEN DE COMPRA", "AL "+cDateTime.substring(0,10), userName, fecha);
			pc.setNoColumnFixWidth(setCol);
						pc.createTable();
							pc.setFont(8, 1,Color.blue);
							pc.addCols("Solicitud No. :   "+anio+" - "+numId, 0,1);
							pc.addCols("", 2,1);
						pc.addTable();

						pc.setNoColumnFixWidth(setCol);
						pc.createTable();
							pc.setFont(8, 1,Color.blue);
							pc.addCols("Departamento de Compras. ", 0,2);

						pc.addTable();
			pc.setNoColumnFixWidth(setDetail);
			pc.addCopiedTable("detailHeader");
			//groupBy = "";//if this segment is uncommented then reset lCounter to 0 instead of the printed extra line (lCounter -  maxLines)
		}

		groupBy = cdo.getColValue("orden");
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	if (al.size() > 0 )
	{
    if (lCounter < maxLines)
	{
	for(int n=lCounter;n<maxLines;n++)
	{
                 pc.setFont(8, 0);
                 pc.createTable();
                 pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.5f, 0.5f);
                 pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                 pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				 pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                 pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                 pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                 pc.addTable();
       	}
				pc.setFont(8, 0);
                pc.createTable();
                pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
                pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
                pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
                pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
                pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
                pc.addTable();
	}
	}
	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
