<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.Hashtable" %>
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
				DESCRIPCION    										  NOMBRE REPORTES           FLAG
				NOTAS DE DEBITO                     INV00129.RDF                ND
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

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String groupBy = "",groupByProv="";

int nGroup =0;
if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";

if (appendFilter == null) appendFilter = "";

if(!fDate.trim().equals("")&&!tDate.trim().equals(""))
appendFilter += "  and to_date(to_char(a.fecha_ajuste ,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy')  and to_date('"+tDate+"' ,'dd/mm/yyyy'))";

sql = " select  al.codigo_almacen cod_almacen, al.descripcion desc_almacen, p.cod_provedor cod_proveedor, p.cod_provedor||' '||p.nombre_proveedor desc_proveedor, to_char(a.fecha_ajuste,'dd/mm/yyyy') fecha, nvl(a.n_d,' ')n_d, nvl(a.total,0) monto,a.codigo_almacen||'-'||a.cod_proveedor codigo from tbl_inv_ajustes a , tbl_inv_almacen al, tbl_com_proveedor p where a.codigo_ajuste = 3 and (a.codigo_almacen = al.codigo_almacen and a.compania = al.compania and a.cod_proveedor = p.cod_provedor) and (a.codigo_almacen ="+almacen+" and a.compania = "+compania+appendFilter+"  and   a.n_d  <> 0 order by a.codigo_almacen, a.cod_proveedor asc  ";

al = SQLMgr.getDataList(sql);

sql="select 'A' type, to_char(a.codigo_almacen) codigo, al.descripcion desc_almacen, sum(nvl(a.total,0)) monto from tbl_inv_ajustes a , tbl_inv_almacen al, tbl_com_proveedor p where a.codigo_ajuste = 3 and (a.codigo_almacen = al.codigo_almacen and a.compania = al.compania and a.cod_proveedor = p.cod_provedor) and (a.codigo_almacen ="+almacen+" and  a.compania = "+compania+appendFilter+"  and   a.n_d  <> 0  group by a.codigo_almacen, al.descripcion  ";

sql +=" union select 'P' type, a.codigo_almacen||'-'||a.cod_proveedor cod_proveedor, p.nombre_proveedor desc_proveedor, sum(nvl(a.total,0)) monto from tbl_inv_ajustes a , tbl_inv_almacen al, tbl_com_proveedor p where a.codigo_ajuste = 3 and (a.codigo_almacen = al.codigo_almacen and a.compania = al.compania and a.cod_proveedor = p.cod_provedor) and (a.codigo_almacen ="+almacen+" and a.compania = "+compania+appendFilter+"  and   a.n_d  <> 0  group by a.codigo_almacen||'-'||a.cod_proveedor,p.nombre_proveedor    order by 1,2 asc  ";

alTotal = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	double total = 0.00;
	Hashtable htWh = new Hashtable();
	Hashtable htProv = new Hashtable();
	int maxLines = 55; //max lines of items
	int nLine  = 0;

	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);
		 if (cdo.getColValue("type").trim().equals("A"))
		 {
				htWh.put(cdo.getColValue("codigo"),cdo.getColValue("monto"));
		 }
		 if (cdo.getColValue("type").trim().equals("P"))
		 {
				htProv.put(cdo.getColValue("codigo"),cdo.getColValue("monto"));
		 }
	}

	int nItems = ((al.size()*2)+(alTotal.size()*2))+1; //number of items
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
	String fileNamePrefix = "print_notas_debito";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"-"+userId+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;//+"/"+UserDet.getUserId();
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
		setDetail.addElement(".34");
		setDetail.addElement(".33");
		setDetail.addElement(".33");



	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
	pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO - NOTAS DE DEBITO ","DEL    "+fDate +" AL    "+tDate,  userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);

		pc.addCols("Fecha",1,1);
		pc.addCols("N D",0,1);
		pc.addCols("Monto",2,1);

	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);


				if (!groupByProv.equalsIgnoreCase(cdo.getColValue("codigo")))
				{
					if(i != 0)
					{
						pc.createTable();
						pc.addCols("Total x Proveedor:  "+CmnMgr.getFormattedDecimal((String) htProv.get(groupByProv)),2,setDetail.size(),cHeight);
						pc.addTable();
						lCounter++;
					}
				}

				if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")))
				{
					if(i != 0)
					{
						pc.createTable();
						pc.addCols("Total x Almacen:  "+CmnMgr.getFormattedDecimal((String) htWh.get(groupBy)),2,setDetail.size(),cHeight);
						pc.addTable();
						lCounter++;
					}
					pc.setFont(7, 0,Color.blue);
					pc.createTable();
						pc.addBorderCols("  "+cdo.getColValue("desc_almacen"),1,setDetail.size(),cHeight);
					pc.addTable();
					lCounter++;
					pc.setFont(7, 0);
				}


				if (!groupByProv.equalsIgnoreCase(cdo.getColValue("codigo")))
				{
					pc.createTable();
						pc.addCols("  "+cdo.getColValue("desc_proveedor"),0,setDetail.size(),cHeight);
					pc.addTable();
					pc.addCopiedTable("detailHeader");
					lCounter++;
				}

		pc.setNoColumnFixWidth(setDetail);
		pc.createTable();
			pc.addCols(" "+cdo.getColValue("fecha"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("n_d"),0,1,cHeight);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines && i < al.size()-1)
		{
			lCounter = lCounter - maxLines;

			pCounter++;
			pc.addNewPage();
				pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO - NOTAS DE DEBITO", "DEL    "+fDate +" AL    "+tDate, userName, fecha);
				pc.setNoColumnFixWidth(setDetail);
				pc.createTable();
					pc.addBorderCols("  "+cdo.getColValue("desc_almacen"),1,setDetail.size(),0.5f,0.0f,0.0f,0.0f,cHeight);
				pc.addTable();
				pc.createTable();
						pc.addCols("  "+cdo.getColValue("desc_proveedor"),1,setDetail.size(),cHeight);
					pc.addTable();
				pc.addCopiedTable("detailHeader");

		}

		groupBy     = cdo.getColValue("cod_almacen");
		groupByProv = cdo.getColValue("codigo");
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
		pc.addCols("Total x Proveedor:  "+CmnMgr.getFormattedDecimal((String) htProv.get(groupByProv)),2,setDetail.size(),cHeight);
		pc.addTable();
		pc.createTable();
		pc.addCols("Total x Almacen:     "+CmnMgr.getFormattedDecimal((String) htWh.get(groupBy)),2,setDetail.size(),cHeight);
		pc.addTable();

		pc.createTable();
		pc.addCols("    ",2,setDetail.size(),cHeight);
		pc.addTable();

		pc.createTable();
		pc.addCols("Total x Reporte:     "+CmnMgr.getFormattedDecimal(total),2,setDetail.size(),cHeight);
		pc.addTable();

	}
	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>