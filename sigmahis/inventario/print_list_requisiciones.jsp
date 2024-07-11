<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
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

REQUISICIONES DE UNIDADES ADMINISTRATIVAS   INV0012.RDF                RUA
REQUISICIONES ENTRE ALMACENES               INV0035.RDF                REA
REQUISICIONES ENTRE COMPAÑIAS               INV0036.RDF								 REC


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

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String compania1 = request.getParameter("compania1");

String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String depto = request.getParameter("depto");
String anio = request.getParameter("anio");
String cod_req = request.getParameter("cod_req");
String estado = request.getParameter("estado");
String fg = request.getParameter("fg");
String almacen_dev = request.getParameter("almacen_dev");
String titulo = request.getParameter("titulo");
String descEstado = request.getParameter("descEstado");
String desc = "" ;

int nGroup = 0;
if (almacen == null) almacen = "";
if (estado == null) estado = "";
if (anio == null) anio = "";
if (tDate == null) tDate = "";
if (fDate == null) fDate = "";
if (depto == null) depto = "";
if (cod_req == null) cod_req = "";
if (almacen_dev == null) almacen_dev = "";
if (titulo == null) titulo = "";
if (descEstado == null) descEstado = "";
if (compania1 == null) compania1 = "";

if (appendFilter == null) appendFilter = "";

if(fg.trim().equals("RUA"))
{
	desc = "INVENTARIO - REQUISICIONES POR ALMACEN";
	if (!depto.trim().equals("")) appendFilter += " and ue.codigo="+depto+"";
	if (!estado.trim().equals("")) appendFilter += " and sr.estado_solicitud='"+estado+"'";
	if (!fDate.trim().equals("") && !tDate.trim().equals("")) appendFilter += " and to_date(to_char(sr.fecha_creacion,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and to_date('"+tDate+"','dd/mm/yyyy')";
	if (!anio.trim().equals("")) appendFilter += " and sr.anio="+anio+"";
	if (!cod_req.trim().equals("")) appendFilter += " and sr.solicitud_no="+cod_req+"";
	if (!almacen.trim().equals("")) appendFilter += " and sr.codigo_almacen="+almacen+"";

	sql = "select sr.tipo_transferencia, decode(sr.estado_solicitud,'A','APROBADO','T','TRAMITE','P','PENDIENTE','N','ANULADO','R','PROCESADO') estado, to_char(sr.fecha_documento,'dd/mm/yyyy') fecha, to_char(sr.fecha_modificacion,'hh12:mi:ss am') horaAprob, sr.anio, decode(sr.tipo_solicitud,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL') tipo_solicitud, sr.solicitud_no, sr.unidad_administrativa, ue.descripcion, sr.codigo_almacen, al.descripcion descAlmacen from tbl_inv_solicitud_req sr, tbl_sec_unidad_ejec ue, tbl_inv_almacen al where (sr.unidad_administrativa=ue.codigo and (ue.codigo>1 and ue.codigo<=100 and ue.nivel=3) and sr.compania="+compania+appendFilter+") and al.compania=sr.compania and al.codigo_almacen=sr.codigo_almacen order by sr.codigo_almacen, ue.descripcion, sr.anio, solicitud_no, decode(sr.estado_solicitud,'A','APROBADO','T','TRAMITE','P','PENDIENTE','N','ANULADO','R','PROCESADO')";
	al = SQLMgr.getDataList(sql);

	sql = "select count(*) from (select distinct sr.codigo_almacen from tbl_inv_solicitud_req sr, tbl_sec_unidad_ejec ue, tbl_inv_almacen al where (sr.unidad_administrativa=ue.codigo and (ue.codigo>1 and ue.codigo<=100 and ue.nivel=3) and sr.compania="+compania+appendFilter+") and al.compania=sr.compania and al.codigo_almacen=sr.codigo_almacen)";
 	nGroup = CmnMgr.getCount(sql);
}
else if(fg.trim().equals("REA"))
{
	desc = " REQUISICIONES ENTRE ALMACENES";
	depto = "INVENTARIO";
	titulo = desc +"   -    ESTADO:  "+descEstado ;
	if (!almacen_dev.trim().equals("")) appendFilter += " and sr.codigo_almacen="+almacen_dev+"";
	if (!estado.trim().equals("")) appendFilter += " and sr.estado_solicitud='"+estado+"'";
	if (!fDate.trim().equals("") && !tDate.trim().equals("")) appendFilter += " and to_date(to_char(sr.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and to_date('"+tDate+"','dd/mm/yyyy')";

	sql = "select distinct sr.codigo_almacen, sr.tipo_transferencia, decode(sr.estado_solicitud,'A','APROBADO','T','EN TRAMITE','P','PENDIENTE','N','ANULADAS') estado, to_char(sr.fecha_documento,'dd/mm/yyyy') fecha, to_char(sr.fecha_modificacion,'hh12:mi:ss am') horaAprob, sr.anio, decode(sr.tipo_solicitud,'D','DIARIA','S','SEMANAL') tipo_solicitud, sr.solicitud_no, al.descripcion from tbl_inv_solicitud_req sr, tbl_inv_almacen al where (sr.compania=al.compania and sr.codigo_almacen=al.codigo_almacen) and (sr.tipo_transferencia='A' and sr.compania="+compania+appendFilter+") order by sr.codigo_almacen, sr.anio, sr.solicitud_no";
	al = SQLMgr.getDataList(sql);
}
else
{
	desc = " REQUISICIONES ENTRE COMPANIAS";
	if(depto.trim().equals("")) depto = "INVENTARIO";
	if(titulo.trim().equals("")) titulo = desc;
	if (!compania1.trim().equals("")) appendFilter += " and sr.compania="+compania1+"";
	else appendFilter += " and sr.compania=sr.compania_sol";
	if (!estado.trim().equals("")) appendFilter += " and sr.estado_solicitud='"+estado+"'";
	if (!fDate.trim().equals("") && !tDate.trim().equals("")) appendFilter += " and to_date(to_char(sr.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and to_date('"+tDate+"','dd/mm/yyyy')";

	sql = "select sr.compania, c.nombre descripcion, sr.tipo_transferencia, decode(sr.estado_solicitud,'A','APROBADO','T','TRAMITE',' ') estado, to_char(sr.fecha_documento,'DD/MM/YYYY') fecha, to_char(sr.fecha_modificacion,'hh12:mi:ss am') horaAprob, sr.anio, decode(sr.tipo_solicitud,'D','DIARIA','S','SEMANAL') tipo_solicitud, sr.solicitud_no from tbl_inv_solicitud_req sr, tbl_sec_compania c where sr.compania=c.codigo and sr.tipo_transferencia='C' and sr.compania_sol="+compania+appendFilter+" order by sr.anio, sr.solicitud_no";
	al = SQLMgr.getDataList(sql);
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 55; //max lines of items
	int nItems = al.size() + (nGroup * 2); //number of items
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
	String fileNamePrefix = "print_list_requisiciones";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+".pdf";
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
		setDetail.addElement(".40");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
	String title = "";
	String subtitle = "";

	if (fg.trim().equals("RUA"))
	{
		title = desc;
		if (!fDate.trim().equals("") && !tDate.trim().equals(""))	subtitle = "DEL "+fDate+" AL "+tDate;
	}
	else
	{
		title = depto;
		subtitle = titulo;
	}
	pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		if (fg.trim().equals("RUA")) pc.addBorderCols("Solicitado por",0);
		else pc.addBorderCols("Descripción",0);
		pc.addBorderCols("Año",1);
		pc.addBorderCols("Numero",1);
		pc.addBorderCols("Tipo",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Hora Aprob.",1);
		pc.addBorderCols("Estado",1);
		if(!fg.trim().equals("RUA")) pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		if (fg.trim().equals("RUA") && !groupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
		{
			pc.createTable();
				pc.addBorderCols("  "+cdo.getColValue("descAlmacen"),1,setDetail.size(),0.5f,0.0f,0.0f,0.0f,cHeight);
			pc.addTable();
			pc.addCopiedTable("detailHeader");
			lCounter+=2;
		}
		pc.setNoColumnFixWidth(setDetail);
		pc.createTable();
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("anio"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("solicitud_no"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("tipo_solicitud"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("fecha"),1,1,cHeight);
            pc.addCols(" "+cdo.getColValue("horaAprob"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("estado"),1,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines && i < al.size()-1)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			if (fg.trim().equals("RUA"))
			{
				pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);
				pc.setNoColumnFixWidth(setDetail);
				pc.createTable();
					pc.addBorderCols("  "+cdo.getColValue("descAlmacen"),1,setDetail.size(),0.5f,0.0f,0.0f,0.0f,cHeight);
				pc.addTable();
				pc.addCopiedTable("detailHeader");
			}
			else
			{
				pdfHeader(pc, _comp, pCounter, nPages, title, subtitle, userName, fecha);
				pc.addCopiedTable("detailHeader");
  	  }
		}

		groupBy = cdo.getColValue("codigo_almacen");
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
			pc.addCols(" ",1,setDetail.size());
		pc.addTable();
		lCounter ++;
	}
	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>