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
FP		REPORTE
EA	    INV0089.RDF
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
ArrayList alResumen = new ArrayList();

String sql = "";
String appendFilter1 = "";
String appendFilter2 = "";
String fp = request.getParameter("fp");
String compania = request.getParameter("compania");
String almacen = request.getParameter("almacen");
String fechaI = request.getParameter("fechaI");
String fechaF = request.getParameter("fechaF");
String titulo ="" ;
String subTitulo ="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

if(almacen != null && !almacen.equals(""))	appendFilter1 += " and em.codigo_almacen = " + almacen;

if(fechaI != null && !fechaI.equals("")){
	appendFilter1 += " and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fechaI+"','dd/mm/yyyy')";
	appendFilter2 += " and to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fechaI+"','dd/mm/yyyy')";
}
if(fechaF != null && !fechaF.equals("")){
	appendFilter1 += " and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fechaF+"','dd/mm/yyyy')";
	appendFilter2 += " and to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fechaF+"','dd/mm/yyyy')";
}

if(fp== null)fp="";

sql = "select a.cod_almacenes, a.cod_flia, a.almacenes almacen_sol, a.desc_familia, a.almacen_soli_desc almacen_ent, a.unidades, round((a.montos-nvl(b.devoluciones,0)),2) monto_total, a.nivel from (select a.codigo_almacen||'-'||al1.codigo_almacen cod_almacenes, fa.cod_flia, a.descripcion almacenes, fa.nombre desc_familia, al1.descripcion almacen_soli_desc, sum (de.cantidad) unidades, sum(de.precio * de.cantidad) montos, fa.nivel from tbl_inv_almacen a, tbl_inv_almacen al1, tbl_inv_familia_articulo fa, tbl_inv_articulo ar, tbl_inv_inventario i, tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_req sr where (ar.consignacion_sino = 'N' and sr.tipo_transferencia = 'A' and sr.compania = "+compania+" and to_char(fa.cod_flia) not in (select PARAM_VALUE from tbl_sec_comp_param where compania in(-1,"+compania+") and param_name = 'FLIA_ACTIVO') and em.compania = "+compania+" and em.unidad_administrativa is null and (sr.solicitud_no = em.req_solicitud_no and sr.tipo_solicitud = em.req_tipo_solicitud and sr.anio = em.req_anio and sr.compania = em.compania) and (de.compania = em.compania and de.anio = em.anio and de.no_entrega = em.no_entrega) and (i.codigo_almacen = em.codigo_almacen and i.compania = em.compania and i.cod_articulo = de.cod_articulo and i.art_familia = de.cod_familia and i.art_clase = de.cod_clase) and (ar.cod_flia = i.art_familia and ar.cod_clase = i.art_clase and ar.cod_articulo = i.cod_articulo and ar.compania = i.compania) and (fa.cod_flia = de.cod_familia and fa.compania = de.compania) and (al1.compania = sr.compania and al1.codigo_almacen = sr.codigo_almacen) and (a.compania = sr.compania_sol and a.codigo_almacen = sr.codigo_almacen_ent) and fa.compania = em.compania "+appendFilter1+") group by a.codigo_almacen||'-'||al1.codigo_almacen, fa.cod_flia, a.descripcion, de.cod_familia, al1.descripcion, fa.nombre, fa.nivel order by a.codigo_almacen||'-'||al1.codigo_almacen, fa.cod_flia, a.descripcion, al1.descripcion) a, (select a.codigo_almacen||'-'||al1.codigo_almacen cod_almacenes, ar.cod_flia, ' ' almacenes, ' ' desc_familia, 0 unidades, sum (nvl (dd.cantidad, 0) * nvl (dd.precio, 0)) devoluciones, fa.nivel from tbl_inv_devolucion d, tbl_inv_detalle_devolucion dd, tbl_inv_articulo ar, tbl_inv_almacen a, tbl_inv_entrega_material em, tbl_inv_familia_articulo fa, tbl_inv_solicitud_req sr, tbl_inv_almacen al1 where sr.tipo_transferencia = 'A' and ar.consignacion_sino = 'N' and d.compania = "+compania+" and ((d.compania = a.compania) and (d.codigo_almacen = a.codigo_almacen) and (d.compania = em.compania) and (d.no_entrega = em.no_entrega) and (d.anio_entrega = em.anio) and (em.compania = a.compania) and (em.codigo_almacen = a.codigo_almacen) and (em.req_solicitud_no = sr.solicitud_no) and (em.req_tipo_solicitud = sr.tipo_solicitud) and (em.req_anio = sr.anio) and (sr.compania = a.compania) and (sr.codigo_almacen_ent = a.codigo_almacen) and (dd.compania = d.compania) and (dd.num_devolucion = d.num_devolucion) and (dd.anio_devolucion = d.anio_devolucion) and (dd.cod_articulo = ar.cod_articulo) and (dd.cod_clase = ar.cod_clase) and (dd.cod_familia = ar.cod_flia) and (dd.compania = ar.compania) and (sr.codigo_almacen = al1.codigo_almacen) and (sr.compania = al1.compania) and (fa.cod_flia = dd.cod_familia and fa.compania = d.compania) and to_char(fa.cod_flia) not in (select PARAM_VALUE from tbl_sec_comp_param where compania in(-1, "+compania+") and param_name = 'FLIA_ACTIVO')) "+appendFilter2+" group by a.codigo_almacen||'-'||al1.codigo_almacen, ar.cod_flia, fa.nivel order by a.codigo_almacen||'-'||al1.codigo_almacen, ar.cod_flia) b where a.cod_almacenes = b.cod_almacenes(+) and a.cod_flia = b.cod_flia(+) and a.nivel = b.nivel(+) order by 3, 5, 2";

al = SQLMgr.getDataList(sql);


String sqlTotal = "select cod_almacenes, sum(monto_total) total  from ("+ sql +") group by cod_almacenes";

String sqlGranTotal = "select sum(monto_total) total from ("+ sql +")";

sql = "select a.almacen_sol, a.almacen_ent, a.cod_flia, a.unidades, round((a.montos-nvl(b.devoluciones,0)),2) monto_total, a.nivel from (select a.codigo_almacen almacen_sol, al1.codigo_almacen almacen_ent, fa.cod_flia, sum(de.cantidad) unidades, sum (de.precio * de.cantidad) montos, fa.nivel from tbl_inv_almacen a, tbl_inv_almacen al1, tbl_inv_familia_articulo fa, tbl_inv_articulo ar, tbl_inv_inventario i, tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_req sr where (ar.consignacion_sino = 'N' and sr.tipo_transferencia = 'A' and sr.compania = "+compania+" and to_char(fa.cod_flia) not in (select PARAM_VALUE from tbl_sec_comp_param where compania in(-1,"+compania+") and param_name = 'FLIA_ACTIVO') and em.compania = "+compania+" and em.unidad_administrativa is null and (sr.solicitud_no = em.req_solicitud_no and sr.tipo_solicitud = em.req_tipo_solicitud and sr.anio = em.req_anio and sr.compania = em.compania) and (de.compania = em.compania and de.anio = em.anio and de.no_entrega = em.no_entrega) and (i.codigo_almacen = em.codigo_almacen and i.compania = em.compania and i.cod_articulo = de.cod_articulo and i.art_familia = de.cod_familia and i.art_clase = de.cod_clase) and (ar.cod_flia = i.art_familia and ar.cod_clase = i.art_clase and ar.cod_articulo = i.cod_articulo and ar.compania = i.compania) and (fa.cod_flia = de.cod_familia and fa.compania = de.compania) and (al1.compania = sr.compania and al1.codigo_almacen = sr.codigo_almacen) and (a.compania = sr.compania_sol and a.codigo_almacen = sr.codigo_almacen_ent) and fa.compania = em.compania "+appendFilter1+") group by a.codigo_almacen, al1.codigo_almacen, fa.cod_flia, fa.nivel) a, (select a.codigo_almacen almacen_sol, al1.codigo_almacen almacen_ent, fa.cod_flia, sum (nvl (dd.cantidad, 0) * nvl (dd.precio, 0)) devoluciones, fa.nivel from tbl_inv_devolucion d, tbl_inv_detalle_devolucion dd, tbl_inv_articulo ar, tbl_inv_almacen a, tbl_inv_entrega_material em, tbl_inv_familia_articulo fa, tbl_inv_solicitud_req sr, tbl_inv_almacen al1 where sr.tipo_transferencia = 'A' and ar.consignacion_sino = 'N' and d.compania = "+compania+" and ((d.compania = a.compania) and (d.codigo_almacen = a.codigo_almacen) and (d.compania = em.compania) and (d.no_entrega = em.no_entrega) and (d.anio_entrega = em.anio) and (em.compania = a.compania) and (em.codigo_almacen = a.codigo_almacen) and (em.req_solicitud_no = sr.solicitud_no) and (em.req_tipo_solicitud = sr.tipo_solicitud) and (em.req_anio = sr.anio) and (sr.compania = a.compania) and (sr.codigo_almacen_ent = a.codigo_almacen) and (dd.compania = d.compania) and (dd.num_devolucion = d.num_devolucion) and (dd.anio_devolucion = d.anio_devolucion) and (dd.cod_articulo = ar.cod_articulo) and (dd.cod_clase = ar.cod_clase) and (dd.cod_familia = ar.cod_flia) and (dd.compania = ar.compania) and (sr.codigo_almacen = al1.codigo_almacen) and (sr.compania = al1.compania) and (fa.cod_flia = dd.cod_familia and fa.compania = d.compania) and to_char(fa.cod_flia) not in (select PARAM_VALUE from tbl_sec_comp_param where compania in(-1,"+compania+") and param_name = 'FLIA_ACTIVO')) "+appendFilter2+" group by a.codigo_almacen, al1.codigo_almacen, fa.cod_flia, fa.nivel) b where a.almacen_sol = b.almacen_sol(+) and a.almacen_ent = b.almacen_ent(+) and a.cod_flia = b.cod_flia(+) and a.nivel = b.nivel(+) order by 3, 5, 2";

String sqlResumen = "select distinct nvl(a.nivel, 'S/N') nivel, (select max(nombre) from tbl_inv_familia_articulo where nivel = a.nivel) nivel_desc, nvl(b.total, 0) total, s.cg_cta1||'.'||s.cg_cta2||'.'||s.cg_cta3||'.'||s.cg_cta4||'.'||s.cg_cta5||'.'||s.cg_cta6||' - '|| s.descripcion almacen_sol_desc, e.cg_cta1||'.'||e.cg_cta2||'.'||e.cg_cta3||'.'||e.cg_cta4||'.'||e.cg_cta5||'.'||e.cg_cta6||' - '|| e.descripcion almacen_ent_desc from tbl_inv_familia_articulo a, (select almacen_sol, almacen_ent, nivel, sum(monto_total) total from ("+ sql +") group by almacen_sol, almacen_ent, nivel) b, tbl_inv_almacen s, tbl_inv_almacen e where a.nivel = b.nivel(+) and b.almacen_sol = s.codigo_almacen and b.almacen_ent = e.codigo_almacen";

alTotal = SQLMgr.getDataList(sqlTotal);

alResumen = SQLMgr.getDataList(sqlResumen);

CommonDataObject cdoGT = SQLMgr.getData(sqlGranTotal);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int bed = 0, cantidad=0;
	double total = 0.00;
	int maxLines = 44; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	Hashtable htWh = new Hashtable();

	cantidad = (alTotal.size() * 3)+ alResumen.size()+3;

	for (int i=0; i<alTotal.size(); i++){
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);
		htWh.put(cdo.getColValue("cod_almacenes"),cdo.getColValue("total"));
	}

	int nItems = al.size() + cantidad;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;
System.out.println("nItems == "+nItems+" nPage ="+nPages+"  lineFill"+lineFill);

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_trxs_entre_almacenes";
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
		setDetail.addElement(".60");
		setDetail.addElement(".20");
		setDetail.addElement(".20");

	Vector setResumen = new Vector();
		setResumen.addElement(".37");
		setResumen.addElement(".38");
		setResumen.addElement(".15");
		setResumen.addElement(".10");

	String groupBy = "",subGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 14.0f;

	titulo ="RESUMEN DE TRANSFERENCIAS ENTRE ALMACENES X FAMILIA";
	subTitulo = "Desde "+fechaI+" Hasta "+fechaF;

	pdfHeader(pc, _comp, pCounter, nPages, " "+titulo,subTitulo , userName, fecha);

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_almacenes"))){
				if (i != 0){
					pc.setNoColumnFixWidth(setDetail);
					pc.createTable();
					pc.setFont(7, 0,Color.black);
					pc.addBorderCols("Total: ",2,2,0.0f,0.0f,0.0f,0.0f,cHeight);
					pc.addBorderCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",(String) htWh.get(groupBy)),2,1,0.0f,0.5f,0.0f,0.0f,cHeight);
					pc.addTable();
					lCounter++;
				}

				pc.setFont(7, 1,Color.blue);
				pc.setNoColumnFixWidth(setDetail);
				pc.createTable();
					pc.addBorderCols("De: "+cdo.getColValue("almacen_sol"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
					pc.addBorderCols("Para: "+cdo.getColValue("almacen_ent"),0,2,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.addTable();

				lCounter++;
				pc.createTable();
					pc.setFont(7, 1);
					pc.addBorderCols(" ", 1, 1, 0.0f, 0.0f, 0.0f, 0.0f, cHeight);
					pc.addBorderCols("Uds", 1, 1, 0.5f, 0.0f, 0.0f, 0.0f, cHeight);
					pc.addBorderCols("Montos", 1, 1, 0.5f, 0.0f, 0.0f, 0.0f, cHeight);
				pc.addTable();
				pc.copyTable("detailHeader");
				lCounter+=2;
			}

		pc.setNoColumnFixWidth(setDetail);
		pc.createTable();
		pc.setFont(7, 0, Color.black);
		pc.addCols(" "+cdo.getColValue("desc_familia"), 0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("unidades"), 2,1,cHeight);
		pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("monto_total")), 2,1,cHeight);
		pc.addTable();


		lCounter++;

		if (lCounter >= maxLines){
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, " "+titulo, subTitulo, userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1,Color.blue);
			pc.createTable();
			pc.addBorderCols("De: "+cdo.getColValue("almacen_sol"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.addBorderCols("Para: "+cdo.getColValue("almacen_ent"),0,2,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.addTable();

			pc.addCopiedTable("detailHeader");
		}

		groupBy = cdo.getColValue("cod_almacenes");

	}//for i

	if (al.size() == 0){
		pc.createTable();
			pc.addCols("No existen registros",1,3);
		pc.addTable();
	} else {
		pc.setNoColumnFixWidth(setDetail);
		pc.createTable();
		pc.setFont(7, 0,Color.black);
		pc.addBorderCols("Total: ",2,2,0.0f,0.0f,0.0f,0.0f,cHeight);
		pc.addBorderCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",(String) htWh.get(groupBy)),2,1,0.0f,0.5f,0.0f,0.0f,cHeight);
		pc.addTable();

		pc.createTable();
		pc.setFont(7, 0,Color.black);
		pc.addCols("Gran Total: ",2,2,cHeight);
		pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",(String) cdoGT.getColValue("total")),2,1,cHeight);
		pc.addTable();

		pc.setNoColumnFixWidth(setResumen);
		pc.setFont(7, 0,Color.black);
		pc.createTable();
		pc.addBorderCols("R E S U M E N   P O R   N I V E L   C O N T A B L E",1,4,0.5f,0.0f,0.0f,0.0f,cHeight);
		pc.addTable();

		pc.createTable();
		pc.addBorderCols("ALMACEN ENTREGA",1,1,0.5f,0.0f,0.0f,0.0f,cHeight);
		pc.addBorderCols("ALMACEN SOLICITA",1,1,0.5f,0.0f,0.0f,0.0f,cHeight);
		pc.addBorderCols("NIVEL",2,1,0.5f,0.0f,0.0f,0.0f,cHeight);
		pc.addBorderCols("SUB-TOTAL",2,1,0.5f,0.0f,0.0f,0.0f,cHeight);
		pc.addTable();
		double totRes = 0.00;
		for(int i=0;i<alResumen.size();i++){
			CommonDataObject cdo = (CommonDataObject) alResumen.get(i);
			pc.createTable();
			pc.addBorderCols(cdo.getColValue("almacen_sol_desc"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.addBorderCols(cdo.getColValue("almacen_ent_desc"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.addBorderCols(cdo.getColValue("nivel")+ " - " +cdo.getColValue("nivel_desc"),0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("total")),2,1,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.addTable();
			totRes += Double.parseDouble(cdo.getColValue("total"));
		}
		pc.createTable();
		pc.addBorderCols("Gran Total:",2,3,0.0f,0.0f,0.0f,0.0f,cHeight);
		pc.addBorderCols(CmnMgr.getFormattedDecimal("###,###,##0.00",totRes),2,1,0.0f,0.5f,0.0f,0.0f,cHeight);
		pc.addTable();

	}
	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>