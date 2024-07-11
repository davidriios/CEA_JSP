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
		REPORTE:		INV00131.RDF
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

String almacen = request.getParameter("almacen");
String compania = request.getParameter("compania");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String depto = request.getParameter("depto");
String anio = request.getParameter("anio");
String cod_req = request.getParameter("cod_req");
String estado = request.getParameter("estado");

String tipo = request.getParameter("tipo");


if(almacen    == null) almacen  = "";
if(estado     == null) estado   = "";
if(anio       == null) anio     = "";
if(tDate      == null) tDate    = "";
if(fDate      == null) fDate    = "";
if(depto      == null) depto    = "";
if(cod_req    == null) cod_req  = "";
if(tipo       == null) tipo     = "";
if(compania   == null) compania = "";// (String) session.getAttribute("_companyId");
if (appendFilter == null) appendFilter = "";

if(!almacen.trim().equals("")) appendFilter +=" ";

if(!compania.trim().equals(""))appendFilter +=" and sr.compania = "+compania;
if(!anio.trim().equals(""))    appendFilter +=" and sr.anio = "+anio;
if(!cod_req.trim().equals("")) appendFilter +=" and sr.solicitud_no  = "+cod_req;
if(!tipo.trim().equals(""))    appendFilter +=" and sr.tipo_solicitud =  '"+tipo+"'";
if(!estado.trim().equals(""))  appendFilter +=" and sr.estado_solicitud = '"+estado+"'";
if(!fDate.trim().equals(""))   appendFilter +=" and to_date(to_char(sr.fecha_modificacion,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fDate+"','dd/mm/yyyy')";
if(!tDate.trim().equals(""))   appendFilter +=" and to_date(to_char(sr.fecha_modificacion,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+tDate+"','dd/mm/yyyy')";
if(estado.trim().equals("")) appendFilter += " and ds.estado_renglon = 'P' ";

 
 

sql="select sr.compania,sr.codigo_almacen,ue.codigo cod_unidad, ue.codigo||' '||ue.descripcion  desc_unidad, al.codigo_almacen||' '||al.descripcion  desc_almacen, sr.compania||'-'||sr.anio||'-'||sr.solicitud_no||' '||sr.tipo_solicitud codigo_req, sr.usuario_creacion usuario , to_char(sr.fecha_creacion,'dd/mm/yyyy') fecha , to_char(sr.fecha_modificacion,'dd/mm/yyyy') fecha_aprobacion, to_char(sr.fecha_modificacion,'hh12:mi:ss am') horaAprob, ds.art_familia||'-'||ds.art_clase||'-'||ds.cod_articulo cod_articulo, a.descripcion desc_articulo , nvl(ds.cantidad,0) cantidad, nvl(ds.despachado,0) recibidos , nvl(ds.cantidad,0) - nvl(ds.despachado,0) pendientes, nvl(i.disponible,0) disponible from tbl_inv_solicitud_req sr, tbl_sec_unidad_ejec ue, tbl_inv_d_sol_req ds, tbl_inv_articulo a, tbl_inv_inventario i, tbl_inv_almacen al where sr.tipo_transferencia = 'C'   "+appendFilter+" and (sr.compania = ue.compania and  sr.unidad_administrativa = ue.codigo) and (ds.compania = sr.compania and  ds.solicitud_no = sr.solicitud_no and  ds.tipo_solicitud = sr.tipo_solicitud and  ds.req_anio = sr.anio) and (ds.compania_sol = a.compania and  ds.art_familia = a.cod_flia and  ds.art_clase = a.cod_clase and  ds.cod_articulo = a.cod_articulo) and (sr.compania_sol = al.compania and  sr.codigo_almacen = al.codigo_almacen) and (i.compania = a.compania and  i.art_familia = a.cod_flia and  i.art_clase = a.cod_clase and i.cod_articulo = a.cod_articulo) and  i.codigo_almacen = sr.codigo_almacen order by sr.compania asc, ue.codigo||'-'||ue.descripcion asc, al.codigo_almacen asc, al.descripcion asc, sr.compania||'-'||sr.anio||'-'||sr.solicitud_no||' '||sr.tipo_solicitud asc ";

al = SQLMgr.getDataList(sql);

sql="select sum(line) nLine from ( ";

sql += " select distinct 3 line, sr.compania||'-'||sr.anio||'-'||sr.solicitud_no||' '||sr.tipo_solicitud codigo_req  from tbl_inv_solicitud_req sr, tbl_sec_unidad_ejec ue, tbl_inv_d_sol_req ds, tbl_inv_articulo a, tbl_inv_inventario i, tbl_inv_almacen al where sr.tipo_transferencia = 'C'  "+appendFilter+" and (sr.compania = ue.compania and  sr.unidad_administrativa = ue.codigo) and (ds.compania = sr.compania and  ds.solicitud_no = sr.solicitud_no and  ds.tipo_solicitud = sr.tipo_solicitud and  ds.req_anio = sr.anio) and (ds.compania_sol = a.compania and  ds.art_familia = a.cod_flia and  ds.art_clase = a.cod_clase and  ds.cod_articulo = a.cod_articulo) and (sr.compania_sol = al.compania and  sr.codigo_almacen = al.codigo_almacen) and (i.compania = a.compania and  i.art_familia = a.cod_flia and  i.art_clase = a.cod_clase and i.cod_articulo = a.cod_articulo) and  i.codigo_almacen = sr.codigo_almacen ";

sql += "  UNION  ";

sql += " select distinct 1 line, sr.compania||' '||sr.unidad_administrativa||' '||ue.descripcion cod from tbl_inv_solicitud_req sr, tbl_sec_unidad_ejec ue, tbl_inv_d_sol_req ds, tbl_inv_articulo a, tbl_inv_inventario i, tbl_inv_almacen al where sr.tipo_transferencia = 'C' "+appendFilter+" and (sr.compania = ue.compania and  sr.unidad_administrativa = ue.codigo) and (ds.compania = sr.compania and  ds.solicitud_no = sr.solicitud_no and  ds.tipo_solicitud = sr.tipo_solicitud and  ds.req_anio = sr.anio) and (ds.compania_sol = a.compania and  ds.art_familia = a.cod_flia and  ds.art_clase = a.cod_clase and  ds.cod_articulo = a.cod_articulo) and (sr.compania_sol = al.compania and  sr.codigo_almacen = al.codigo_almacen) and (i.compania = a.compania and  i.art_familia = a.cod_flia and  i.art_clase = a.cod_clase and i.cod_articulo = a.cod_articulo) and  i.codigo_almacen = sr.codigo_almacen ";

sql += "  UNION  ";

sql += " select distinct 1 line,sr.compania||' '||sr.unidad_administrativa||' '||ue.descripcion ||'-'||sr.codigo_almacen codigo_req  from tbl_inv_solicitud_req sr, tbl_sec_unidad_ejec ue, tbl_inv_d_sol_req ds, tbl_inv_articulo a, tbl_inv_inventario i, tbl_inv_almacen al where sr.tipo_transferencia = 'C' "+appendFilter+" and (sr.compania = ue.compania and  sr.unidad_administrativa = ue.codigo) and (ds.compania = sr.compania and  ds.solicitud_no = sr.solicitud_no and  ds.tipo_solicitud = sr.tipo_solicitud and  ds.req_anio = sr.anio) and (ds.compania_sol = a.compania and  ds.art_familia = a.cod_flia and  ds.art_clase = a.cod_clase and  ds.cod_articulo = a.cod_articulo) and (sr.compania_sol = al.compania and  sr.codigo_almacen = al.codigo_almacen) and (i.compania = a.compania and  i.art_familia = a.cod_flia and  i.art_clase = a.cod_clase and i.cod_articulo = a.cod_articulo) and  i.codigo_almacen = sr.codigo_almacen ) ";


int nGroup = CmnMgr.getCount(sql);

//alTotal = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int bed = 0;
	double total = 0.00;
	Hashtable htWh = new Hashtable();
	Hashtable htFamily = new Hashtable();
	int maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	int nItems = al.size() + nGroup;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;
System.out.println("nItems == "+nItems+" nPage ="+nPages+"  lineFill"+lineFill+"  nGroup  =   "+nGroup+"   al.size()  == "+al.size());

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_inv_req_company";
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

Vector setDetail0 = new Vector();
		setDetail0.addElement(".20");
		setDetail0.addElement(".25");
		setDetail0.addElement(".30");
		setDetail0.addElement(".25");


	Vector setDetail = new Vector();
		setDetail.addElement(".10");
		setDetail.addElement(".50");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");


	String groupBy = "",subGroupBy = "",unidad ="";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "REQUISICIONES  DE COMPAÑIAS", "", userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",0);
		pc.addBorderCols("EXISTENCIA",1);
		pc.addBorderCols("PEDIDO",1);
		pc.addBorderCols("RECIBIDO",1);
		pc.addBorderCols("PENDIENTE",1);

	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


				if (!groupBy.equalsIgnoreCase(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_req")))
				{
						pc.createTable();
							pc.addCols("  ",0,setDetail.size(),cHeight);
						pc.addTable();
						lCounter++;
				}
				if (!unidad.equalsIgnoreCase(cdo.getColValue("compania")+"-"+cdo.getColValue("cod_unidad")))
				{
						pc.setFont(7, 1,Color.blue);
						pc.createTable();
							pc.addCols("  "+cdo.getColValue("desc_unidad"),0,setDetail.size(),cHeight);
						pc.addTable();
						lCounter++;
				}


			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("compania")+"-"+cdo.getColValue("cod_unidad")+"-"+cdo.getColValue("codigo_almacen")))
			{
					pc.setFont(7, 1,Color.red);
					pc.createTable();
						pc.addCols(" "+cdo.getColValue("desc_almacen"),0,setDetail.size(),cHeight);
					pc.addTable();
					lCounter++;

			}
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_req")))
			{
				pc.setNoColumnFixWidth(setDetail0);
				pc.setFont(7, 1);
				pc.createTable();
					pc.addCols(" Codigo Req:  "+cdo.getColValue("codigo_req"),0,1,cHeight);
					pc.addCols(" Fecha Req:  "+cdo.getColValue("fecha"),0,1,cHeight);
	pc.addCols(" Aprob.: "+cdo.getColValue("fecha_aprobacion")+"        Hora Aprob.  "+cdo.getColValue("horaAprob"),0,1,cHeight);		
					pc.addCols("Usuario:  "+cdo.getColValue("usuario"),1,1,cHeight);
				pc.addTable();
				pc.setNoColumnFixWidth(setDetail);
				pc.addCopiedTable("detailHeader");

				lCounter+=2;

			}



		pc.setFont(6, 0);
		pc.createTable();
			pc.addCols(""+cdo.getColValue("cod_articulo"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("disponible"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("cantidad"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("recibidos"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("pendientes"),1,1,cHeight);

		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "REQUISICIONES  DE COMPAÑIAS", "", userName, fecha);

			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1,Color.blue);
			pc.createTable();
				pc.addCols("  "+cdo.getColValue("desc_unidad"),0,setDetail.size(),cHeight);
			pc.addTable();
			pc.setFont(7, 1,Color.red);
			pc.createTable();
				pc.addCols(" "+cdo.getColValue("desc_almacen"),0,setDetail.size(),cHeight);
			pc.addTable();
			pc.setNoColumnFixWidth(setDetail0);
			pc.setFont(7, 1);
			pc.createTable();
				pc.addCols(" Codigo Req: "+cdo.getColValue("codigo_req"),0,1,cHeight);
				pc.addCols(" Fecha Req: "+cdo.getColValue("fecha"),0,1,cHeight);
	pc.addCols(" Aprob.: "+cdo.getColValue("fecha_aprobacion")+"        Hora Aprob.  "+cdo.getColValue("horaAprob"),0,1,cHeight);		
				//pc.addCols(" Aprob.:"+cdo.getColValue("fecha_aprobacion"),0,1,cHeight);
				pc.addCols(" Usuario"+cdo.getColValue("usuario"),1,1,cHeight);
			pc.addTable();
			pc.setNoColumnFixWidth(setDetail);
			pc.addCopiedTable("detailHeader");


		}

		unidad = cdo.getColValue("compania")+"-"+cdo.getColValue("cod_unidad");
		subGroupBy = cdo.getColValue("compania")+"-"+cdo.getColValue("cod_unidad")+"-"+cdo.getColValue("codigo_almacen");
		groupBy    = cdo.getColValue("compania")+"-"+cdo.getColValue("codigo_req");

	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}



	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>