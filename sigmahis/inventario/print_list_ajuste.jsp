<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR
==========================================================================*/
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

String titulo   = "";
String fgFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if(appendFilter==null) appendFilter = "";
if(fg==null) fg = "DM";
if (fp==null) fp = "";
if(fg.equals("DM")){
	fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste in (2, 6, 7) ";
	titulo = "AJUSTES - SOLICITUD DE DESCARTE DE MERCANCÍA";
} else if(fg.equals("ED")){
	fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste = 1 ";
	titulo = "AJUSTES - POR ERROR O DESCARTE";
} else if(fg.equals("AI")){
	fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste = 4 ";
	titulo = "AJUSTES - SOLICITUD DE AJUSTE A INVENTARIO";
} else if(fg.equals("ND")){
	fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste in (3, 8) ";
	titulo = "AJUSTES  POR NOTA DE DÉBITO";
} else if(fg.equals("NE")){
	fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste = 5 ";
	titulo = "AJUSTES  A NOTAS DE ENTREGA";
}

if(fp.equals("aprob")){
fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste in (select codigo_ajuste from tbl_inv_tipo_ajustes where tipo_ajuste IN ('FAC','GEN'))";
}else{
fgFilter = " where a.compania = "+session.getAttribute("_companyId") + " and a.codigo_ajuste in (select codigo_ajuste from tbl_inv_tipo_ajustes where tipo_ajuste ='"+fg+"')";
}

sql = "select a.anio_ajuste, a.numero_ajuste, a.compania, '[ '||a.codigo_ajuste||' ] '||b.descripcion as descripcion, to_char(a.fecha_ajuste,'dd/mm/yyyy') fecha_ajuste,al.descripcion as descAlmacen ,decode(a.estado,'A','APROBADO','T','TRAMITE','P','PENDIENTE','R','RECHAZADO') estado, a.cod_ref from tbl_inv_ajustes a, tbl_inv_tipo_ajustes b, tbl_inv_almacen al " + fgFilter +" and a.codigo_ajuste = b.codigo_ajuste and a.codigo_almacen = al.codigo_almacen and al.compania = a.compania "+ appendFilter;

al = SQLMgr.getDataList(sql);

if(request.getMethod().equalsIgnoreCase("GET")) {

	int maxLines = 55; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	int nItems = al.size();
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_list_ajuste";
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

	Vector setDetail=new Vector();
		setDetail.addElement(".05");
		setDetail.addElement(".07");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".32");
		setDetail.addElement(".30");
		setDetail.addElement(".10");

	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO"," "+titulo, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.addBorderCols("Año",1);
		pc.addBorderCols("No. Ajuste",1,1);
		pc.addBorderCols("Cód.Ref.",1,1);
		pc.addBorderCols("Fecha Doc.",0);
		pc.addBorderCols("Tipo de Ajuste",0);
		pc.addBorderCols("Almacén",0);
		pc.addBorderCols("Estado",0);
	pc.addTable();
	pc.copyTable("detailHeader");

for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.createTable();
		pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("anio_ajuste"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("numero_ajuste"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("cod_ref"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("fecha_ajuste"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("descAlmacen"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("estado"),0,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines &&(((pCounter -1)* maxLines)+lCounter < nItems))
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO"," "+titulo, userName, fecha);
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



