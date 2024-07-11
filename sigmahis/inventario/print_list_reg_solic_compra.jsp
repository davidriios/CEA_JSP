<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

sql = "select a.requi_anio, a.requi_numero, a.compania, to_char(a.requi_fecha,'dd/mm/yyyy') as requi_fecha, a.estado_requi, decode(a.estado_requi,'A','APROBADO','P','PENDIENTE','R','Rechazado') as desc_estado_requi, a.usuario_creacion, a.fecha_creacion, a.usuario_modificacion, a.fecha_modificacion, nvl(a.observaciones,' ') as observaciones, nvl(a.monto_total,0) as monto_total, nvl(a.subtotal,0) as subtotal, nvl(a.itbm,0) as itbm, nvl(a.activa,' ') as activa, nvl(a.unidad_administrativa,0) as unidad_administrativa, nvl(a.codigo_almacen,0) as codigo_almacen, nvl(a.especificacion,' ') as especificacion, b.descripcion,getNoOrdenComp(a.compania,a.requi_anio,a.requi_numero) as ordenes,nvl((select descripcion from tbl_sec_unidad_ejec where codigo=a.unidad_administrativa and compania=a.compania),' ') as descripcionUnd  from tbl_inv_requisicion a, tbl_inv_almacen b where a.compania="+(String) session.getAttribute("_companyId")+" and a.codigo_almacen=b.codigo_almacen and a.compania=b.compania "+appendFilter+"  order by 1 desc, 2 desc";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 55; //max lines of items
	int nItems = al.size(); //number of items
	int extraItems = nItems % maxLines;
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	//calculating number of page
	if (extraItems == 0) nPages = (nItems / maxLines);
	else nPages = (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;
	//String currDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

	String folderName = "inventario";
	String fileNamePrefix = "print_list_reg_solic_compra";
	String fileNameSuffix = "";
	String fecha = cDateTime;
	//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
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
	//System.out.println("Year is: "+year+" Month is: "+month+" Day is: "+day);
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"-"+UserDet.getUserId()+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	//System.out.println("******* directory="+directory);
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
		setDetail.addElement(".07");
		setDetail.addElement(".10");
		setDetail.addElement(".08");
		setDetail.addElement(".20");
		setDetail.addElement(".30");
		setDetail.addElement(".10");
		setDetail.addElement(".15");

	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
	String title = "INVENTARIO";
	String subtitle = "REGISTRO DE SOLICITUD DE COMPRA";

	pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
	pc.setFont(7, 1);
			pc.addBorderCols("Año",1);
			pc.addBorderCols("No.Solicitud",1);
			pc.addBorderCols("Fecha Doc.",1);			
			pc.addBorderCols("Almacen",1);			
			pc.addBorderCols("Unidad",1);
			pc.addBorderCols("Estado",1);
			pc.addBorderCols("Ordenes Comp.",1); 			
	pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.createTable();
		pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("requi_anio"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("requi_numero"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("requi_fecha"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("descripcionUnd"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("desc_estado_requi"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("ordenes"),1,1,cHeight);
			
			
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
			pc.addCols(al.size()+" Registros en total",0,setDetail.size());
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>