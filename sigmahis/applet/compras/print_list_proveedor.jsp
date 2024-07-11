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
==================       COM0016.RDF       =======================================
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

String compania =  compania = (String) session.getAttribute("_companyId");


if (appendFilter == null) appendFilter = "";

sql = "SELECT cod_provedor as codigo, nombre_proveedor as nombre, compania, decode(estado_proveedor,'ACT','ACTIVO','INA','INACTIVO') as estado, ruc, digito_verificador as digito, telefono, fax, contacto_compra as contacto, apartado_postal as apartado, email FROM tbl_com_proveedor where compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by nombre_proveedor";


al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 50; //max lines of items
	int nItems = al.size(); //number of items
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

	String folderName = "compras";
	String fileNamePrefix = "print_list_proveedor";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+".pdf";
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
		setDetail.addElement(".30");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");

	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 12.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "COMPRAS", "LISTADO DE PROVEEDORES", userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("Nombre del Proveedor.",1);
		pc.addBorderCols("Código",1);
		pc.addBorderCols("Teléfono",1);
		pc.addBorderCols("Fax",1);
		pc.addBorderCols("E-Mail",1);
		pc.addBorderCols("R.U.C",1);
		pc.addBorderCols("D.V.",1);
		pc.addBorderCols("Apartado Postal.",1);

	pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


		pc.setFont(7, 0);
		pc.createTable();
		    pc.addBorderCols(""+cdo.getColValue("nombre"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("codigo"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("telefono"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("fax"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("email"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("ruc"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("digito"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("apartado"),1,1,cHeight);

		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

		pdfHeader(pc, _comp, pCounter, nPages, "COMPRAS", "LISTADO DE PROVEEDORES ", userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
			pc.addCopiedTable("detailHeader");
			//groupBy = "";//if this segment is uncommented then reset lCounter to 0 instead of the printed extra line (lCounter -  maxLines)
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
		pc.createTable();
			pc.setFont(7, 1);
			pc.addCols("TOTAL DE PROVEEDORES: "+al.size(),0,setDetail.size());
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>