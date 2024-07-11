<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTotal = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String codCat = request.getParameter("codCat");

String almacen = request.getParameter("almacen");
String almacen_dev = request.getParameter("almacen_dev");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String anio = request.getParameter("anio");
String cod_req = request.getParameter("cod_req");
String estado = request.getParameter("estado");
String tipo = request.getParameter("tipo");
String title = "";
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String fp = request.getParameter("fp");

if (appendFilter == null) appendFilter = "";
sbFilter.append(appendFilter);

if(almacen== null) almacen = "";
if(estado== null) estado = "";
if(anio== null) anio = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(cod_req== null) cod_req = "";
if(almacen_dev== null) almacen_dev = "";
if(tipo== null) tipo = "";
if(fp== null) fp = "";

title ="REQUISICION DE UNIDAD ADMINISTRATIVA";

if (!almacen.trim().equals("")) { sbFilter.append(" and sr.codigo_almacen = "); sbFilter.append(almacen); }
if (!almacen_dev.trim().equals("")) { sbFilter.append(" and sr.codigo_almacen_ent = "); sbFilter.append(almacen_dev); }
if (!estado.trim().equals("")) { sbFilter.append(" and sr.estado_solicitud  = '"); sbFilter.append(estado); sbFilter.append("'"); }
if (!anio.trim().equals("")) { sbFilter.append(" and sr.anio = "); sbFilter.append(anio); }
if (!cod_req.trim().equals("")) { sbFilter.append(" and sr.solicitud_no = "); sbFilter.append(cod_req); }
if (!tipo.trim().equals("")) { sbFilter.append(" and sr.tipo_solicitud = '"); sbFilter.append(tipo); sbFilter.append("'"); }
if (!fDate.trim().equals("") && !tDate.trim().equals("")) { sbFilter.append(" and trunc(sr.fecha_documento) between to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy') and to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }
if (fp.trim().equals("UA")) { sbFilter.append(" and sr.tipo_transferencia = 'U'"); }

sbSql.append("select sr.anio||'-'||sr.solicitud_no||'-'||sr.tipo_solicitud as codigo, ds.art_familia||'-'||ds.art_clase||'-'||ds.cod_articulo as cod_articulo, nvl(ds.cantidad,0) as pedido, nvl(ds.despachado,0) as recibido, decode(ds.estado_renglon,'R',0,nvl(ds.cantidad,0) - nvl(ds.despachado,0)) as pendiente, decode(ds.estado_renglon,'R',(nvl(ds.cantidad,0) - nvl(ds.despachado,0)),0) as rechazado,decode(sr.estado_solicitud,'A','APROBADO','P','PENDIENTE','N','ANULADO','R','RECHAZADO','T','TRAMITE','E','ENTREGADO',sr.estado_solicitud) as estado");
sbSql.append(", (select descripcion from tbl_inv_almacen where compania = sr.compania and codigo_almacen = sr.codigo_almacen) as almacen_sol");
sbSql.append(", (select descripcion from tbl_sec_unidad_ejec where codigo = sr.unidad_administrativa and compania = sr.compania) as unidad_adm_desc");
sbSql.append(", (select descripcion from tbl_inv_articulo where compania = ds.compania_sol and cod_articulo = ds.cod_articulo) as desc_articulo");
sbSql.append(", (select cod_barra from tbl_inv_articulo where compania = ds.compania_sol and cod_articulo = ds.cod_articulo) as cod_barra");
sbSql.append(", (select (select descripcion from tbl_inv_unidad_medida where cod_medida = z.cod_medida) from tbl_inv_articulo z where compania = ds.compania_sol and cod_articulo = ds.cod_articulo) as unidad_medida_desc");
sbSql.append(", (select disponible from tbl_inv_inventario where compania = ds.compania_sol and cod_articulo = ds.cod_articulo and codigo_almacen = sr.codigo_almacen) as disponible,to_char(sr.fecha_creacion, 'dd/mm/yyyy hh12:mi am') as fecha_doc ");
sbSql.append(" from tbl_inv_solicitud_req sr, tbl_inv_d_sol_req ds");
sbSql.append(" where sr.compania = ");
sbSql.append(compania);
sbSql.append(sbFilter);
sbSql.append("/* and sr.tipo_transferencia = 'A' and sr.activa = 'S' and ds.estado_renglon = 'P'*/ and (ds.compania = sr.compania and ds.solicitud_no = sr.solicitud_no and ds.tipo_solicitud = sr.tipo_solicitud and ds.req_anio = sr.anio)");
sbSql.append(" order by sr.anio, sr.solicitud_no, sr.codigo_almacen_ent, sr.codigo_almacen, ds.art_familia desc, ds.art_clase, ds.cod_articulo");
al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select sr.anio||'-'||sr.solicitud_no||'-'||sr.tipo_solicitud as codigo, count(*) as nItem from tbl_inv_solicitud_req sr, tbl_inv_d_sol_req ds where sr.compania = ");
sbSql.append(compania);
sbSql.append(sbFilter);
sbSql.append("/* and sr.tipo_transferencia = 'A' and sr.activa = 'S'and ds.estado_renglon = 'P'*/  and (ds.compania = sr.compania and  ds.solicitud_no = sr.solicitud_no and ds.tipo_solicitud = sr.tipo_solicitud and ds.req_anio = sr.anio) group by sr.anio||'-'||sr.solicitud_no||'-'||sr.tipo_solicitud");
alTotal = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int bed = 0;
	double price = 0.00;
	Hashtable htUse = new Hashtable();
	Hashtable htPrice = new Hashtable();
	int maxLines = 52; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);
		int nItems = Integer.parseInt(cdo.getColValue("nItem"))+3;
		int extraItems = nItems % maxLines;
		if (extraItems == 0) nPages += (nItems / maxLines);
		else nPages += (nItems / maxLines) + 1;

	}
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_sol_req_unidad_adm";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"-"+time+".pdf";
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
Vector setDetailEnc = new Vector();
		setDetailEnc.addElement(".50");
		setDetailEnc.addElement(".50");



	Vector setDetail = new Vector();
		setDetail.addElement(".05");
		setDetail.addElement(".10");
		setDetail.addElement(".15");
		setDetail.addElement(".36");
		setDetail.addElement(".10");
		setDetail.addElement(".07");
		setDetail.addElement(".08");
		setDetail.addElement(".10");
		setDetail.addElement(".09");
	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 12.0f;

	pdfHeader(pc, _comp, pCounter, nPages, " "+title, "AL "+cDateTime.substring(0,10), userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("",0);
		pc.addBorderCols("CODIGO",0);
		pc.addBorderCols("C.BARRA",1);
		pc.addBorderCols("ARTICULO",1);
		pc.addBorderCols("UNIDAD MED.",1);
		pc.addBorderCols("PEDIDO",1);
		pc.addBorderCols("RECIBIDO",1);
		pc.addBorderCols("RECHAZADO",1);
		pc.addBorderCols("PENDIENTE",1);

	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigo")))
		{
			if (i != 0)
			{

				lCounter = 0;
				pCounter++;
				pc.addNewPage();
				pdfHeader(pc, _comp, pCounter, nPages, " "+title, "AL "+cDateTime.substring(0,10), userName, fecha);
			}
			pc.setNoColumnFixWidth(setDetailEnc);
			pc.createTable();
				pc.setFont(8, 1,Color.blue);
				pc.addCols(" UNIDAD ADM.: "+cdo.getColValue("unidad_adm_desc"),0,1,cHeight);
				pc.addCols("  ",0,1,cHeight);
				pc.addCols(" SOLICITADO A: "+cdo.getColValue("almacen_sol"),0,1,cHeight);

				pc.setFont(8, 1,Color.blue);
				pc.addCols(" SOLICITUD # "+cdo.getColValue("codigo"),0,1,cHeight);
				pc.addCols(" ESTADO: "+cdo.getColValue("estado"),0,1,cHeight);
			pc.addTable();
			
			pc.createTable();
				pc.setFont(8, 1,Color.blue);
				 pc.addCols(" ESTADO: "+cdo.getColValue("estado"),0,1,cHeight);
				 pc.addCols(" FECHA DOC. "+cdo.getColValue("fecha_doc"),0,1,cHeight);
			pc.addTable();
			
			pc.addCopiedTable("detailHeader");
			lCounter += 3;
		}

		pc.setFont(8, 0);
		pc.setNoColumnFixWidth(setDetail);
		pc.createTable();
			pc.addCols(""+(i+1),0,1,cHeight);
			pc.addCols(cdo.getColValue("cod_articulo"),0,1,cHeight);
			pc.addCols(cdo.getColValue("cod_barra"),0,1,cHeight);
			pc.addCols(cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(cdo.getColValue("unidad_medida_desc"),1,1,cHeight);
			pc.addCols(cdo.getColValue("pedido"),1,1,cHeight);
			pc.addCols(cdo.getColValue("recibido"),1,1,cHeight);
			pc.addCols(cdo.getColValue("rechazado"),1,1,cHeight);
			pc.addCols(cdo.getColValue("pendiente"),1,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, " "+title, "AL "+cDateTime.substring(0,10), userName, fecha);
			
			pc.setNoColumnFixWidth(setDetailEnc);
			pc.createTable();
				pc.setFont(8, 1,Color.blue);
				pc.addCols(" UNIDAD ADM.: "+cdo.getColValue("unidad_adm_desc"),0,1,cHeight);
				pc.addCols("   ",0,1,cHeight);
				pc.addCols(" SOLICITADO A: "+cdo.getColValue("almacen_sol"),0,1,cHeight);

				pc.setFont(8, 1,Color.blue);
				pc.addCols(" SOLICITUD # "+cdo.getColValue("codigo"),0,1,cHeight);
				pc.addTable();
			
			pc.createTable();
				pc.setFont(8, 1,Color.blue);
				 pc.addCols(" ESTADO: "+cdo.getColValue("estado"),0,1,cHeight);
				 pc.addCols(" FECHA DOC. "+cdo.getColValue("fecha_doc"),0,1,cHeight);
			pc.addTable();
			
			pc.addCopiedTable("detailHeader");
			lCounter += 3;
		}

		groupBy = cdo.getColValue("codigo");
	}//for i

	pc.setNoColumnFixWidth(setDetail);
	if (al.size() == 0) {
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	} else {
		for(int x =0; x <= maxLines-lCounter; x++) {
			pc.setFont(7, 1);
			pc.createTable();
			pc.addCols(" ",1,setDetail.size(),cHeight);
			pc.addTable();
		}
		pc.setNoColumnFixWidth(setDetailEnc);
		pc.createTable();
			pc.addCols("ELABORADO POR  : _______________________________________",0,1,cHeight*2);
			pc.addCols("",0,1,cHeight*2);
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>