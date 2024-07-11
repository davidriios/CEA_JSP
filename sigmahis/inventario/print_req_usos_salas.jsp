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
		REPORTE:		INV0066.RDF  SOLICITUDES DE MATERIALES PARA USOS DE SALAS.
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

String compania = (String) session.getAttribute("_companyId");
String anio = request.getParameter("anio");
String id = request.getParameter("id");

if(id== null) id = "";
if(anio== null) anio = "";

if (appendFilter == null) appendFilter = "";


sql=" select ue.descripcion||decode(c.descripcion, null, '', '   -> '||c.descripcion) sala , sr.anio||' '||sr.solicitud_no||' '||sr.tipo_solicitud  solicitud , sr.observacion, sr.usuario_modif usuario , a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo cod_articulo , a.descripcion desc_articulo, nvl(ds.cantidad,0) cantidad, nvl(i.precio,0)  costo from  tbl_inv_solicitud_req sr, tbl_inv_d_sol_req ds, tbl_inv_articulo a, tbl_sec_unidad_ejec ue, tbl_inv_inventario i, tbl_cds_centro_servicio c where ((ds.compania=sr.compania and ds.solicitud_no=sr.solicitud_no and ds.tipo_solicitud=sr.tipo_solicitud and ds.req_anio=sr.anio) and (sr.codigo_centro = c.codigo(+)) and (ds.compania_sol=a.compania and ds.art_familia=a.cod_flia and ds.art_clase=a.cod_clase and ds.cod_articulo=a.cod_articulo) and (sr.compania=ue.compania and sr.unidad_administrativa=ue.codigo) and (i.compania=a.compania and i.art_familia=a.cod_flia and i.art_clase=a.cod_clase and i.cod_articulo=a.cod_articulo) and (ds.compania_sol=a.compania) and (ds.art_familia=a.cod_flia) and (ds.art_clase=a.cod_clase) and (ds.cod_articulo=a.cod_articulo) and (sr.compania=ue.compania) and (sr.unidad_administrativa=ue.codigo) and (i.compania=a.compania) and (i.art_familia=a.cod_flia) and (i.art_clase=a.cod_clase) and (i.cod_articulo=a.cod_articulo) and (ds.compania=sr.compania) and (ds.solicitud_no=sr.solicitud_no) and (ds.tipo_solicitud=sr.tipo_solicitud) and (ds.req_anio=sr.anio)) and  sr.codigo_almacen =   i.codigo_almacen  and  sr.anio||sr.solicitud_no||sr.tipo_solicitud  = '"+id+"' and sr.compania = "+compania;

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int totalArt = 0;
	double total = 0.00;
	int maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	int nItems = al.size() +3;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = false;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_req_usos_salas";
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
		setDetail.addElement(".13");
		setDetail.addElement(".55");
		setDetail.addElement(".16");
		setDetail.addElement(".16");

	Vector setDetail0 = new Vector();
		setDetail0.addElement(".15");
		setDetail0.addElement(".35");
		setDetail0.addElement(".30");
		setDetail0.addElement(".20");

	String groupBy = "",subGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 13.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO","MATERIALES PARA USOS DE SALAS", userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(8, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESCCRIPCION",0);
		pc.addBorderCols("UNIDADES",1);
		pc.addBorderCols("PRECIO",1);

	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (i == 0)
			{
					pc.setNoColumnFixWidth(setDetail);

					pc.setFont(9, 1,Color.blue);
					pc.createTable();
						pc.addCols(" "+cdo.getColValue("sala"),0,2,cHeight);
						pc.addCols("SOLICITADO POR:  "+cdo.getColValue("usuario"),0,2,cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols("Nota: "+cdo.getColValue("observacion"),0,2,cHeight);
						pc.addCols("SOLICITUD: "+cdo.getColValue("solicitud"),0,2,cHeight);
					pc.addTable();

					pc.addCopiedTable("detailHeader");
					lCounter+=3;
			}

		pc.setFont(9, 0);
		pc.createTable();
			pc.addCols(""+cdo.getColValue("cod_articulo"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("cantidad"),1,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("costo")),2,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO","MATERIALES PARA USOS DE SALAS", userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
			pc.addCopiedTable("detailHeader");
		}

	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols(" ",1,setDetail.size());
		pc.addTable();
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}


	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>