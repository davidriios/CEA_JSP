<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
==================       INV00141.RDF      =======================================
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
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fechaini = request.getParameter("fechaIni");
String fechafin = request.getParameter("fechaFin");
String secini = request.getParameter("secini");
String secfin = request.getParameter("secfin");
String compania =  compania = (String) session.getAttribute("_companyId");

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (secini == null) secini = "";
if (secfin == null) secfin = "";
if (appendFilter == null) appendFilter = "";

String appendTitle = "";
if(!fechaini.trim().equals(""))
{
	appendFilter += " and to_date(to_char(a.fecha_de_entrada,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fechaini+"','dd/mm/yyyy')";
	appendTitle = "CON FECHA DE ENTRADA DESDE "+fechaini;
}
if(!fechafin.trim().equals(""))
{
	appendFilter += " and to_date(to_char(a.fecha_de_entrada,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fechafin+"','dd/mm/yyyy')";
	if (appendTitle.trim().equals("")) appendTitle += "CON FECHA DE ENTRADA";
	appendTitle += " HASTA "+fechafin;
}
if(!secini.trim().equals(""))
{
	appendFilter += " and a.secuencia_placa >= '"+secini+"'";
//	appendTitle = "CON SECUENCIA DESDE "+secini;
}
if(!secfin.trim().equals(""))
{
	appendFilter += " and a.secuencia_placa <= '"+secfin+"'";
//	if (appendTitle.trim().equals("")) appendTitle += "CON SECUENCIA";
//	appendTitle += " HASTA "+secfin;
}

sql = "select to_char(a.fecha_de_entrada,'dd/mm/yyyy') as fecha, a.observacion, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo as codArticulo, a.placa, a.comentario from tbl_con_temp_activo a where a.compania="+compania+appendFilter+" order by a.fecha_de_entrada";
al = SQLMgr.getDataList(sql);

int nGroup = 0;
sql = "select count(*) from (select distinct to_char(a.fecha_de_entrada,'dd/mm/yyyy') from tbl_con_temp_activo a where a.compania="+compania+appendFilter+")";
nGroup = CmnMgr.getCount(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 55; //max lines of items
	int nItems = al.size() + nGroup; //number of items
	int extraItems = nItems % maxLines;
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	if (extraItems == 0) nPages = (nItems / maxLines);
	else nPages = (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_codigo_barra_art";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"-"+UserDet.getUserId()+".pdf";
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
		setDetail.addElement(".20");
		setDetail.addElement(".40");
		setDetail.addElement(".10");
		setDetail.addElement(".30");

	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
	String title = "LISTADO DE ARTICULOS CON # DE PLACA";
	String subtitle = appendTitle;

	pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("Código.",1);
		pc.addBorderCols("Artículo",1);
		pc.addBorderCols("Placa",1);
		pc.addBorderCols("Comentario",1);
	pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("fecha")))
		{
			pc.setNoColumnFixWidth(setDetail);
			pc.createTable();
				pc.setFont(7, 1,Color.blue);
				pc.addBorderCols("Fecha de Entrada: "+cdo.getColValue("fecha"),0,setDetail.size(),0.5f,0.0f,0.0f,0.0f);
			pc.addTable();
			lCounter++;
		}

		pc.setFont(7, 0);
		pc.createTable();
		  pc.addCols(""+cdo.getColValue("codArticulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("observacion"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("placa"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("comentario"),0,1,cHeight);

		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
			pc.addCopiedTable("detailHeader");
		}

		groupBy = cdo.getColValue("fecha");
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
			pc.setFont(7, 1);
			pc.addCols("TOTAL DE ARTICULOS: "+al.size(),0,setDetail.size());
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>