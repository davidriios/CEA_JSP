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
		REPORTE:		INV0002.RDF
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
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String anioEntrega = request.getParameter("anioEntrega");
String noEntrega = request.getParameter("noEntrega");

String titulo = request.getParameter("titulo");
String descDepto = request.getParameter("descDepto");
String fg = request.getParameter("fg");
String tr = request.getParameter("tr");


if(almacen== null) almacen = "";
if(anioEntrega== null) anioEntrega = "";
if(noEntrega== null) noEntrega = "";
if(titulo== null) titulo = "";
if(descDepto== null) descDepto = "";
if(tr== null) tr = "";

if (appendFilter == null) appendFilter = "";

if(!almacen.trim().equals(""))         appendFilter  = " and em.codigo_almacen = "+almacen;
if(!anioEntrega.trim().equals(""))       appendFilter  += " and em.anio = "+anioEntrega;
if(!noEntrega.trim().equals(""))         appendFilter  += " and em.no_entrega ="+noEntrega;
if(titulo.trim().equals(""))
titulo = "ENTREGA DE MATERIALES Y EQUIPOS";
if(descDepto.trim().equals(""))
descDepto = "INVENTARIO";

sbSql.append("select nvl(em.itbm,0) itbm,nvl(em.subtotal,0) subtotal, nvl(em.monto,0)monto ,em.unidad_administrativa unidad, em.codigo_almacen cod_almacen, em.anio||' '||lpad(em.no_entrega, 6, '0') no_entrega, nvl(em.req_anio, em.pac_anio) ||'-'||nvl(em.req_solicitud_no, em.pac_solicitud_no)||'   '||(decode (em.req_tipo_solicitud,'D','DIARIA','S','SEMANAL', 'Q','QUINCENAL','M','MENSUAL'))  no_requisicion, de.cod_familia||'-'||de.cod_clase||'-'||de.cod_articulo cod_articulo, a.descripcion desc_articulo, nvl((select sum(cantidad) from tbl_inv_detalle_entrega dee,tbl_inv_entrega_material ent where  dee.cod_articulo = de.cod_articulo and dee.anio =ent.anio and dee.no_entrega = ent.no_entrega  and dee.compania = ent.compania and ent.req_anio =em.req_anio  and ent.req_tipo_solicitud= em.req_tipo_solicitud and ent.req_solicitud_no =em.req_solicitud_no and ent.compania =em.compania),0) entregado, i.disponible disponible, sr.cantidad solicitado, decode(sr.estado_renglon,'R',0,sr.cantidad-de.cantidad) as pendiente,decode(sr.estado_renglon,'R',(nvl(sr.cantidad,0) - nvl(sr.despachado,0)),0) as rechazado, em.observaciones observacion,nvl(de.precio,0) precio,  nvl(de.precio,0)*nvl(de.cantidad,0) montoTotal, to_char(em.fecha_entrega,'dd/mm/yyyy') fecha_entrega,nvl(a.cod_medida,' ') cod_medida, decode('");
sbSql.append(tr);
sbSql.append("','U',decode(em.unidad_administrativa,'7',decode(em.centro_servicio,null,ue.codigo||' '||ue.descripcion,ue.descripcion||' -- '||cs.codigo||' '||cs.descripcion),ue.codigo||' '||ue.descripcion),'A',nvl((select (select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = z.compania and codigo_almacen = z.codigo_almacen) from tbl_inv_solicitud_req z where z.compania = em.compania and z.solicitud_no = em.req_solicitud_no and z.tipo_solicitud = em.req_tipo_solicitud and z.anio = em.req_anio and z.tipo_transferencia = 'A'),' ')/*al.codigo_almacen||' '||al.descripcion,'C',ue.codigo||' '||ue.descripcion*/) as desc_unidad");
sbSql.append(", nvl(decode('");
sbSql.append(tr);
sbSql.append("','A',(select (select codigo_almacen||' '||descripcion from tbl_inv_almacen where compania = z.compania_sol and codigo_almacen = z.codigo_almacen_ent) from tbl_inv_solicitud_req z where z.compania = em.compania and z.solicitud_no = em.req_solicitud_no and z.tipo_solicitud = em.req_tipo_solicitud and z.anio = em.req_anio and z.tipo_transferencia = 'A')),' ') as desc_unidad_src,sr.estado_renglon,nvl(de.cantidad,0) as entreg");
sbSql.append(" from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_sec_unidad_ejec ue, tbl_inv_inventario i, tbl_inv_articulo a, tbl_cds_centro_servicio cs, tbl_inv_almacen al, tbl_inv_d_sol_req sr /*,tbl_inv_solicitud_req sr*/ where  em.compania = ");
sbSql.append(compania);
sbSql.append("  /*se cambio compania x compania_sol*/ and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (de.cod_articulo = a.cod_articulo and de.compania = a.compania) and (em.compania_sol = ue.compania(+) and em.unidad_administrativa = ue.codigo(+))	and (i.codigo_almacen = em.codigo_almacen and i.compania = de.compania /*se activo*/ and i.cod_articulo = de.cod_articulo) and (sr.cod_articulo = de.cod_articulo and sr.req_anio = em.req_anio and sr.tipo_solicitud = em.req_tipo_solicitud and sr.solicitud_no = em.req_solicitud_no and sr.compania = em.compania_sol and sr.compania_sol = em.compania)  ");
sbSql.append(appendFilter);
sbSql.append("   and al.codigo_almacen = em.codigo_almacen and al.compania = em.compania    /*and sr.anio           = em.req_anio and sr.tipo_solicitud = em.req_tipo_solicitud and sr.solicitud_no   = em.req_solicitud_no and sr.compania   = em.compania */ and cs.codigo(+) = em.centro_servicio order by em.unidad_administrativa asc,ue.descripcion asc,em.codigo_almacen asc , em.anio||' '||lpad(em.no_entrega, 6, '0')  asc, de.cod_familia||'-'||de.cod_clase||'-'||de.cod_articulo asc ");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int totalArt = 0;
	double total = 0.00,itbm=0.00,subtotal = 0.00;
	Hashtable htEntrega = new Hashtable();
	Hashtable htFamily = new Hashtable();
	int maxLines = 43; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	int nItems = al.size() + 5;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;


	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_entregas";
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

	Vector setDetail = new Vector();
		setDetail.addElement(".04");        
		setDetail.addElement(".08");
		setDetail.addElement(".25");
		setDetail.addElement(".06");
		setDetail.addElement(".07");
		setDetail.addElement(".09");
		setDetail.addElement(".07");
		setDetail.addElement(".09");
		setDetail.addElement(".08");
		setDetail.addElement(".08");
		setDetail.addElement(".09");

	Vector setDetail0 = new Vector();
		setDetail0.addElement(".15");
		setDetail0.addElement(".35");
		setDetail0.addElement(".30");
		setDetail0.addElement(".20");

	String groupBy = "",subGroupBy = "",observ ="";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 13.0f;
    double pendiente = 0;
	pdfHeader(pc, _comp, pCounter, nPages, " "+descDepto,""+titulo, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 0);
		pc.addBorderCols(""         ,1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
		pc.addBorderCols(" CODIGO"         ,1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
		pc.addBorderCols(" DESC. ARTICULO" ,0, 1, 0.5f, 0.5f, 0.0f, 0.5f);
		pc.addBorderCols(" UNIDAD" ,0, 1, 0.5f, 0.5f, 0.0f, 0.5f);
		pc.addBorderCols(" SOLICITUD"      ,1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
		pc.addBorderCols(" ENTREGA ACUMULADO"      ,1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
		pc.addBorderCols(" ENTREGA ACTUAL"      ,1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
		pc.addBorderCols("RECHAZADO"      ,1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
		pc.addBorderCols(" PENDIENTE"     ,1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
		pc.addBorderCols(" PRECIO"     ,1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
		pc.addBorderCols(" TOTAL"          ,1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_almacen")+"-"+ cdo.getColValue("no_entrega")))
			{

					total    = Double.parseDouble(cdo.getColValue("monto"));
					itbm     = Double.parseDouble(cdo.getColValue("itbm"));
					subtotal = Double.parseDouble(cdo.getColValue("subtotal"));
					pc.setNoColumnFixWidth(setDetail0);

					pc.setFont(9, 1,Color.blue);
					pc.createTable();
						pc.addCols("ENTREGA NO :      "+cdo.getColValue("no_entrega"),0,2,cHeight);
						pc.addCols("REQUISICION NO :  "+cdo.getColValue("no_requisicion")+" - F. Entrega:"+cdo.getColValue("fecha_entrega"),0,2,cHeight);
					pc.addTable();

					pc.createTable();
					pc.addCols("ENTREGADO A: "+cdo.getColValue("desc_unidad"),0,2,cHeight);
					pc.addCols("ENTREGADO POR: "+cdo.getColValue("desc_unidad_src"),0,2,cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols("OBSERVACION: "+cdo.getColValue("observacion"),0,setDetail.size(),cHeight);
					pc.addTable();

					pc.setNoColumnFixWidth(setDetail);
					pc.addCopiedTable("detailHeader");

					lCounter+=4;
			}


		pc.setNoColumnFixWidth(setDetail);
		pc.setFont(9, 0);
		pc.createTable();
			pc.addBorderCols(" "+(i+1)  ,0, 1, 0.0f, 0.0f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(" "+cdo.getColValue("cod_articulo")  ,0, 1, 0.0f, 0.0f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(" "+cdo.getColValue("desc_articulo") ,0, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" "+cdo.getColValue("cod_medida") ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" "+cdo.getColValue("solicitado")    ,2, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" "+cdo.getColValue("entregado")    ,2, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" "+cdo.getColValue("entreg")    ,2, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" "+cdo.getColValue("rechazado")    ,2, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			if(!cdo.getColValue("estado_renglon").trim().equals("R"))
			pendiente = Double.parseDouble(cdo.getColValue("solicitado"))-Double.parseDouble(cdo.getColValue("entregado"));
			else pendiente =0;
			
			pc.addBorderCols(" "+pendiente    ,2, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal("###,###,###.####",cdo.getColValue("precio"))   ,2, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal("###,###,###.####",cdo.getColValue("montoTotal"))   ,2, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{

			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 0);
						pc.createTable();
				pc.addBorderCols(" ",1, 1, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols(" ",0, 1, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols(" ",1, 1, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols(" ",1, 1, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols(" ",1, 1, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols(" ",1, 1, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols(" ",1, 1, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols(" ",1, 1, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
			pc.addTable();

			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, " "+descDepto, ""+titulo, userName, fecha);

			pc.setNoColumnFixWidth(setDetail0);

					pc.setFont(9, 1,Color.blue);
					pc.createTable();
						pc.addCols("ENTREGA NO :      "+cdo.getColValue("no_entrega"),0,2,cHeight);
						pc.addCols("REQUISICION NO :  "+cdo.getColValue("no_requisicion")+" - F. Entrega:"+cdo.getColValue("fecha_entrega"),0,2,cHeight);
					pc.addTable();

					pc.createTable();
					pc.addCols("ENTREGADO A:      "+cdo.getColValue("unidad")+"     "+cdo.getColValue("desc_unidad"),0,4,cHeight);
					pc.addTable();

					pc.createTable();
						pc.addCols("OBSERVACION: "+cdo.getColValue("observacion"),0,setDetail.size(),cHeight);
					pc.addTable();

					pc.setNoColumnFixWidth(setDetail);
					pc.addCopiedTable("detailHeader");
		}

		groupBy    = cdo.getColValue("unidad");
		subGroupBy = cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("no_entrega");
	}//for i

	pc.setNoColumnFixWidth(setDetail);
	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
		for(int x =0; x <= maxLines-lCounter; x++)
		{
			pc.setFont(7, 1);
			pc.createTable();
			pc.addBorderCols(" ",1, 1, 0.0f, 0.0f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(" ",0, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" ",1, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" ",1, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" ",1, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" ",1, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" ",2, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addBorderCols(" ",2, 1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
				pc.addTable();

		}

			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(1, 0);
			pc.createTable();
			pc.addBorderCols(" ",1, setDetail.size(), 0.0f, 0.5f, 0.0f, 0.0f);
			pc.addTable();



			pc.setFont(8, 1);
			pc.createTable();
				pc.addCols("SutTotal: $ ",2,setDetail.size()-1,cHeight);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(""+subtotal),2,1,cHeight);
			pc.addTable();
			pc.setFont(9, 1);
			pc.createTable();
				pc.addCols("ITBM: $ ",2,setDetail.size()-1,cHeight);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(""+itbm),2,1,cHeight);
			pc.addTable();

			lCounter+=2;

			pc.createTable();
				pc.addCols("Total: $ ",2,setDetail.size()-1,cHeight);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(""+total),2,1,cHeight);
			pc.addTable();

			pc.createTable();
				pc.addCols("ENTREGADO POR  : _______________________________________",0,2,cHeight*2);
				pc.addCols("RECIBIDO POR  : _______________________________________",0,6,cHeight*2);
			pc.addTable();

	}


	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>