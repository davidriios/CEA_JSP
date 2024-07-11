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
===============         REPORTE CHSF :  ACT003.RDF     ==========================
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
String compania = (String) session.getAttribute("_companyId");
String fechaini = request.getParameter("fDate");
String fechafin = request.getParameter("tDate");
String estado = request.getParameter("estado");
String familia = request.getParameter("familia");
String clase = request.getParameter("clase");
String articulo = request.getParameter("articulo");
String fg = request.getParameter("fg");

if (appendFilter == null) appendFilter = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (estado == null) estado = "";
if (familia == null) familia = "";
if (clase == null) clase = "";
if (articulo == null) articulo = "";
if (fg == null) fg = "EE";

if(!fechaini.trim().equals("")) 
appendFilter += " and to_date(to_char(t.fecha_de_entrada,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fechaini+"','dd/mm/yyyy') ";
if(!fechafin.trim().equals("")) 
appendFilter += " and to_date(to_char(t.fecha_de_entrada,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fechafin+"','dd/mm/yyyy') ";

if(!familia.trim().equals("")) appendFilter += " and t.cod_flia     = "+familia;
if(!clase.trim().equals(""))   appendFilter += " and t.cod_clase    = "+clase;
if(!estado.trim().equals(""))  appendFilter += " and t.estado       = '"+estado+"'";
if(!articulo.trim().equals(""))appendFilter += " and t.cod_articulo = "+articulo;



    sql = "select t.compania, t.ue_codigo, t.valor_inicial, t.cod_provee, t.observacion, t.factura, t.cod_flia||' - '||t.cod_clase||' - '||t.cod_articulo as codArticulo, t.placa, t.anio, t.no_entrega, p.nombre_proveedor, u.descripcion, t.numero_serie, t.comentario, t.fecha_de_entrada, to_number(to_char(t.fecha_de_entrada, 'yyyymm')) periodo, to_char(to_date(to_number(to_char(t.fecha_de_entrada, 'yyyymm')),'yyyymm'),'FMMONTH  yyyy','NLS_DATE_LANGUAGE=SPANISH') as descPeriodo, 1 cantidad from tbl_con_temp_activo t, tbl_com_proveedor p, tbl_sec_unidad_ejec u where (p.cod_provedor(+) = t.cod_provee) and (u.codigo = t.ue_codigo and u.compania = t.compania) and t.compania = "+compania+appendFilter+" and t.factura IS NOT NULL order by to_number(to_char(t.fecha_de_entrada, 'yyyymm')), t.fecha_de_entrada, t.anio, t.no_entrega";

al = SQLMgr.getDataList(sql);


sql = "select to_number(to_char(t.fecha_de_entrada, 'yyyymm')) periodo, count(*) as count from tbl_con_temp_activo t, tbl_com_proveedor p, tbl_sec_unidad_ejec u where (p.cod_provedor(+) = t.cod_provee) and (u.codigo = t.ue_codigo and u.compania = t.compania) and t.compania = "+compania+appendFilter+" group by to_number(to_char(t.fecha_de_entrada, 'yyyymm'))";

alTotal = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int bed = 0;
	double price = 0.00;
	Hashtable htAct = new Hashtable();
	Hashtable htFecha = new Hashtable();
	int maxLines = 25; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	
	int nItems = al.size() + (alTotal.size()*4) +1;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";  
	String fileNamePrefix = "print_list_equipo_entregado";
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
	boolean isLandscape = true;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".10");
		setDetail.addElement(".05");
		setDetail.addElement(".12");
		setDetail.addElement(".05");
		setDetail.addElement(".08");
		setDetail.addElement(".08");
		setDetail.addElement(".08");
		setDetail.addElement(".05");
		setDetail.addElement(".12");
		setDetail.addElement(".10");
		setDetail.addElement(".05");
		setDetail.addElement(".12");
		
	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 16.0f;
	int cantArt = 0;
	pdfHeader(pc, _comp, pCounter, nPages, "Informe de Equipos Entregados ( A C T I V O S ) ", "Desde "+fechaini+" Hasta "+fechafin, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("Código Artículo",1);
		pc.addBorderCols("Cantidad",1);
		pc.addBorderCols("Descripcion del Artículo",1);
		pc.addBorderCols("Año",1);
		pc.addBorderCols("No. Entrega",1);
		pc.addBorderCols("No. Placa",1);
		pc.addBorderCols("No. Serie",1);
		pc.addBorderCols("Codigo",1);
		pc.addBorderCols("Nombre de Proveedor",1);
		pc.addBorderCols("No. Factura",1);
		pc.addBorderCols("Costo",1);
		pc.addBorderCols("Unidad a la que se le Entregó",1);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("descPeriodo")))
		{
			if (i != 0)
			{
				
				pc.createTable();
					pc.setFont(8, 3,Color.blue);
					pc.addCols("Total de Equipos Entregados : "+cantArt,0,setDetail.size());
				pc.addTable();
				
				pc.createTable();
				pc.setFont(12, 1);
				pc.addCols("",0,setDetail.size());
				pc.addTable();
				
				lCounter +=2;
				cantArt = 0;

			}
			pc.setNoColumnFixWidth(setDetail);
			pc.createTable();
				pc.setFont(9, 2,Color.blue);
				pc.addCols(""+cdo.getColValue("descPeriodo"),0,setDetail.size(),cHeight);
			pc.addTable();
			pc.addCopiedTable("detailHeader");
			lCounter +=2;
		}

		pc.setFont(6, 0);
		pc.createTable();
			
			pc.addCols(""+cdo.getColValue("codArticulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("cantidad"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("observacion"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("anio"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("no_entrega"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("placa"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("numero_serie"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("cod_provee"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("nombre_proveedor"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("factura"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("valor_inicial"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("descripcion"),0,1,cHeight);
		pc.addTable();
		lCounter++;
		cantArt ++;
		if (lCounter >= maxLines  && (((pCounter -1)* maxLines)+lCounter < nItems))
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

				pdfHeader(pc, _comp, pCounter, nPages, "Informe de Equipos Entregados ( A C T I V O S ) ", "Desde "+fechaini+" Hasta "+fechafin, userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
			pc.createTable();
				pc.setFont(9, 2,Color.blue);
				pc.addCols(""+cdo.getColValue("descPeriodo"),0,setDetail.size(),cHeight);
			pc.addTable();
			pc.addCopiedTable("detailHeader");
		}

		groupBy = cdo.getColValue("descPeriodo");
	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
		
	}
	else
	{
				pc.createTable();
					pc.setFont(8, 3,Color.blue);
					pc.addCols("Total de Equipos Entregados : "+cantArt,0,setDetail.size());
				pc.addTable();

				pc.createTable();
				pc.setFont(12, 1);
				pc.addCols("",0,setDetail.size());
				pc.addTable();
		
		
		pc.createTable();
			pc.setFont(9, 1,Color.blue);
			pc.addCols("Total Final de Equipos Entregados : "+al.size(),1,setDetail.size());
		pc.addTable();
		
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>