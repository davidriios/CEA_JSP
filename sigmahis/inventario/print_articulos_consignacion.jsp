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
		CC				inv0039 			   con costo
		SC				inv0039_b			   sin costo
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
String almacen = request.getParameter("almacen");
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String articulo = request.getParameter("articulo");
String tipo = request.getParameter("tipo");

String titulo = request.getParameter("titulo");
String depto = request.getParameter("depto");

if (titulo == null) titulo = "";
if (depto == null) depto = "INVENTARIO";

if (almacen == null) almacen = "";
if (familyCode == null) familyCode = "";
if (classCode == null) classCode = "";
if (!almacen.trim().equals(""))    appendFilter += " and i.codigo_almacen="+almacen;
if (!familyCode.trim().equals("")) appendFilter += " and ar.cod_flia="+familyCode;
if (!classCode.trim().equals(""))  appendFilter += " and ar.cod_clase="+classCode;
if (!articulo.trim().equals(""))   appendFilter += " and ar.cod_articulo="+articulo;
if (!tipo.trim().equals(""))       appendFilter += " and ar.tipo='"+tipo+"'";

if (fg.trim().equals("CE"))
{
	if (titulo.trim().equals(""))titulo = "REPORTE DE ARTICULOS A CONSIGNACION CON EXISTENCIA ";
	/* inv0039  i.disponible > 0  */
	appendFilter += " and i.disponible > 0 ";

}
else
{
/* inv0039_b disponible <=0 */
	if (titulo.trim().equals(""))titulo = "REPORTE DE ARTICULOS A CONSIGNACION SIN EXISTENCIA ";
	appendFilter += " and i.disponible <= 0 ";
}
sql = "select al.codigo_almacen, al.descripcion desc_almacen, ar.cod_flia, al.codigo_almacen||'-'||ar.cod_flia key , (select fa.nombre from tbl_inv_familia_articulo fa where fa.compania = ar.compania and fa.cod_flia = ar.cod_flia ) desc_familia, ar.cod_clase,(select ca.descripcion from tbl_inv_clase_articulo ca where ca.compania = ar.compania and ca.cod_flia = ar.cod_flia and ca.cod_clase = ar.cod_clase) desc_clase, ar.cod_articulo, ar.cod_flia||'-'||ar.cod_clase||'-'||ar.cod_articulo codigo_articulo, ar.descripcion desc_articulo, nvl(i.disponible,0) existencia, nvl(i.precio,0) costo, nvl(i.ultimo_precio,0) ultimo_costo, nvl(i.disponible,0)*nvl( i.precio,0)total_articulo from tbl_inv_inventario i, tbl_inv_articulo ar,tbl_inv_almacen al where ((i.compania = ar.compania and i.cod_articulo = ar.cod_articulo) and (i.compania = al.compania and i.codigo_almacen  = al.codigo_almacen)) and ar.consignacion_sino = 'S' and i.precio > 0 and i.compania = "+compania+appendFilter+"  order by al.descripcion,5,7, ar.descripcion ";
al = SQLMgr.getDataList(sql);

//Totales por cada almacen
sql=" select 'A' type, to_char(al.codigo_almacen) codigo, sum(nvl(i.disponible,0)*nvl( i.precio,0))total  from tbl_inv_inventario i,tbl_inv_articulo ar,tbl_inv_almacen al where ((i.compania = ar.compania and i.cod_articulo = ar.cod_articulo) and (i.compania = al.compania and i.codigo_almacen  = al.codigo_almacen)) and ar.consignacion_sino = 'S' and i.precio > 0 and i.compania =  "+compania+appendFilter+" group by al.codigo_almacen, al.descripcion ";
sql +=" union ";

//Totales por familia para cada almacen
sql +=" select 'F', al.codigo_almacen||'-'||ar.cod_flia codigo, sum(nvl(i.disponible,0)*nvl( i.precio,0))total_articulo from tbl_inv_inventario i, tbl_inv_articulo ar, tbl_inv_almacen al where ((i.compania = ar.compania and i.cod_articulo = ar.cod_articulo) and (i.compania = al.compania and i.codigo_almacen  = al.codigo_almacen)) and ar.consignacion_sino = 'S' and i.precio > 0 and i.compania = "+compania+appendFilter+"  group by al.codigo_almacen||'-'||ar.cod_flia";

alTotal = SQLMgr.getDataList(sql);

int nClases =  CmnMgr.getCount("select count(*) from (select distinct ar.cod_clase,(select ca.descripcion from tbl_inv_clase_articulo ca where ca.compania = ar.compania and ca.cod_flia = ar.cod_flia and ca.cod_clase = ar.cod_clase)  desc_clase from tbl_inv_inventario i, tbl_inv_articulo ar,tbl_inv_almacen al where ((i.compania = ar.compania and i.cod_articulo = ar.cod_articulo) and (i.compania = al.compania and i.codigo_almacen  = al.codigo_almacen)) and ar.consignacion_sino = 'S' and i.precio > 0 and i.compania = "+compania+appendFilter+" )");



if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 48; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	Hashtable htWh = new Hashtable();
	Hashtable htFamily = new Hashtable();

	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);
		 if(cdo.getColValue("type").trim().equals("A"))
		 htWh.put(cdo.getColValue("codigo"),cdo.getColValue("total"));
		 else
		 htFamily.put(cdo.getColValue("codigo"),cdo.getColValue("total"));
	}





	int nItems = al.size() + nClases + (alTotal.size() * 3) ;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";//print_articulos_consignacion.jsp
	String fileNamePrefix = "print_articulos_consignacion";
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
		setDetail.addElement(".50");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");

	String wh = "", groupBy = "",subGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, depto,titulo, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",1);
		pc.addBorderCols("EXISTENCIA",1);
		pc.addBorderCols("COSTO",1);
		pc.addBorderCols("ULT. COSTO",1);
		pc.addBorderCols("TOTAL",1);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("key")))
		{
			if(i != 0)
			{
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols("Sub Total x Familia:",2,4,cHeight);
					pc.addCols("$"+CmnMgr.getFormattedDecimal((String) htFamily.get(groupBy)),2,2,cHeight);
				pc.addTable();

				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols(" ",1,6,cHeight);
				pc.addTable();
				lCounter+=2;
			}
		}
		if (!wh.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
		{
			if(i != 0)
			{
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols("Sub Total x Almacen:",2,4,cHeight);
					pc.addCols("$"+CmnMgr.getFormattedDecimal((String) htWh.get(wh)),2,2,cHeight);
				pc.addTable();
				lCounter++;
			}

			pc.setFont(7, 1);
			pc.createTable();
				pc.addCols(" "+cdo.getColValue("desc_almacen"),2,setDetail.size(),cHeight);
			pc.addTable();
			pc.addCopiedTable("detailHeader");
			lCounter+=2;
		}
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("key")))
		{
			pc.setFont(7, 1,Color.blue);
			pc.createTable();
				pc.addCols(" "+cdo.getColValue("desc_familia"),1,6,cHeight);
			pc.addTable();
			lCounter++;
		}
		if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_clase")+"-"+cdo.getColValue("key")))
		{
			pc.setFont(7, 1,Color.red);
			pc.createTable();
				//pc.addCols(" "+cdo.getColValue("desc_clase"),0,6,cHeight);
				pc.addBorderCols(" "+cdo.getColValue("desc_clase"),0,6, 0.5f, 0.0f, 0.0f, 0.0f);
				//pc.addBorderCols(" "+cdo.getColValue("medida"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				//pc.addBorderCols("ESPECIFICACION",1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
			pc.addTable();
			lCounter++;
		}




		pc.setFont(7, 0);
		pc.createTable();
			pc.addCols(""+cdo.getColValue("codigo_articulo"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("existencia"),2,1,cHeight);
			pc.addCols("$"+CmnMgr.getFormattedDecimal(cdo.getColValue("costo")),2,1,cHeight);
			pc.addCols("$"+CmnMgr.getFormattedDecimal(cdo.getColValue("ultimo_costo")),2,1,cHeight);
			pc.addCols("$"+CmnMgr.getFormattedDecimal(cdo.getColValue("total_articulo")),2,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, depto, titulo, userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1);
			pc.createTable();
				pc.addCols(" "+cdo.getColValue("desc_almacen"),2,setDetail.size(),cHeight);
			pc.addTable();
			pc.addCopiedTable("detailHeader");

			pc.setFont(7, 1,Color.blue);
			pc.createTable();
				pc.addCols(" "+cdo.getColValue("desc_familia"),1,setDetail.size(),cHeight);
			pc.addTable();

			pc.setFont(7, 1,Color.red);
			pc.createTable();
				//pc.addCols(" "+cdo.getColValue("desc_clase"),0,6,cHeight);
				pc.addBorderCols(" "+cdo.getColValue("desc_clase"),0,6, 0.5f, 0.0f, 0.0f, 0.0f);
				//pc.addBorderCols(" "+cdo.getColValue("medida"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
				//pc.addBorderCols("ESPECIFICACION",1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
			pc.addTable();
		}

		wh = cdo.getColValue("codigo_almacen");
		groupBy  = cdo.getColValue("key");
		subGroupBy = cdo.getColValue("cod_clase")+"-"+cdo.getColValue("key");

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
				pc.addCols("Sub Total x Familia:",2,4,cHeight);
				pc.addCols("$"+CmnMgr.getFormattedDecimal((String) htFamily.get(groupBy)),2,2,cHeight);
			pc.addTable();

			pc.setFont(7, 1,Color.blue);
			pc.createTable();
				pc.addCols("Sub Total x Almacen:",2,4,cHeight);
				pc.addCols("$"+CmnMgr.getFormattedDecimal((String) htWh.get(wh)),2,2,cHeight);
			pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>