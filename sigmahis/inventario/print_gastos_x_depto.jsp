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
ArrayList alSubTotal = new ArrayList();
ArrayList alTotal = new ArrayList();
StringBuffer sql = new StringBuffer();
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
if(compania == null)compania="";
if(almacen == null)almacen="";
if(fechaI == null)fechaI="";
if(fechaF == null)fechaF="";

if(!compania.trim().equals("")){
	appendFilter1 = " and em.compania = " + compania;
	appendFilter2 = " and d.compania = " + compania;
}
if(!almacen.trim().equals("")){
	appendFilter1 += " and em.codigo_almacen = " + almacen;
	appendFilter2 += " and al2.codigo_almacen = " + almacen;
}
if(fp== null)fp="";

sql.append("select distinct al2.descripcion almacen_sol, al1.descripcion almacen_ent, fa.cod_flia cod_familias, fa.nombre desc_familia, a.cod_flia || '-' || a.cod_clase || '-' || a.cod_articulo cod_art, a.descripcion, sum(nvl(de.cantidad, 0)) entregado, sum(nvl(de.cantidad, 0)) - sum(nvl(de.cantidad, 0)) devuelto,sum(nvl(de.cantidad, 0) * nvl(de.precio, 0)) cargo, de.precio costos, a.compania, al2.codigo_almacen||'-'||al1.codigo_almacen cod_almacenes, 'E' tipo_doc from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_familia_articulo fa, tbl_inv_solicitud_req sr ,tbl_inv_almacen al1, tbl_inv_almacen al2, tbl_inv_articulo a, tbl_inv_clase_articulo ca where a.consignacion_sino = 'N'");

if(!fechaI.trim().equals("")){
 sql.append(" and trunc(em.fecha_entrega) >= to_date('");
 sql.append(fechaI);
 sql.append("', 'dd/mm/yyyy') ");}
if(!fechaF.trim().equals("")){
 sql.append(" and trunc(em.fecha_entrega) <= to_date('");
 sql.append(fechaI);
 sql.append("', 'dd/mm/yyyy') ");}
 
 sql.append(" and fa.cod_flia  not in (select param_value from tbl_sec_comp_param where param_name ='FLIA_ACTIVO' and compania in(-1,al1.compania)) ");
sql.append(appendFilter1.toString());
sql.append(" and em.unidad_administrativa is null and sr.tipo_transferencia = 'A' and (em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (fa.cod_flia = de.cod_familia) and (sr.codigo_almacen = al2.codigo_almacen and sr.compania = al2.compania) and (em.codigo_almacen = al1.codigo_almacen and em.compania = al1.compania) and (a.compania = ca.compania and a.cod_flia = ca.cod_flia and a.cod_clase = ca.cod_clase) and (ca.compania = fa.compania and ca.cod_flia = fa.cod_flia) and (de.cod_familia = a.cod_flia and de.cod_clase = a.cod_clase and de.cod_articulo = a.cod_articulo and de.compania = a.compania) group by al1.descripcion, al2.descripcion, fa.cod_flia, fa.nombre, a.cod_flia || '-' || a.cod_clase || '-' || a.cod_articulo, a.descripcion, de.precio, a.compania, al2.codigo_almacen||'-'||al1.codigo_almacen, 'E' union select distinct al1.descripcion desc_alm_q_recibe, al2.descripcion desc_alm_q_devuelve, fa.cod_flia, fa.nombre, dd.cod_familia || '-' || dd.cod_clase || '-' || dd.cod_articulo cod_art, a.descripcion desc_articulos, sum(nvl(dd.cantidad, 0)) - sum(nvl(dd.cantidad, 0)) entregado, sum(dd.cantidad) *(-1) devuelto, sum(dd.cantidad * dd.precio) *(-1) devolucion, dd.precio costos, a.compania, al1.codigo_almacen||'-'||al2.codigo_almacen cod_almacenes, 'D' tipo_doc from tbl_inv_devolucion d, tbl_inv_detalle_devolucion dd, tbl_inv_articulo a, tbl_inv_almacen al1, tbl_inv_almacen al2, tbl_inv_clase_articulo ca, tbl_inv_familia_articulo fa where ( a.consignacion_sino = 'N' ");
if(!fechaI.trim().equals("")){
 sql.append(" and trunc(d.fecha_devolucion) >= to_date('");
 sql.append(fechaI);
 sql.append("', 'dd/mm/yyyy') ");}
if(!fechaF.trim().equals("")){
 sql.append(" and trunc(d.fecha_devolucion) <= to_date('");
 sql.append(fechaI);
 sql.append("', 'dd/mm/yyyy') ");}



sql.append(appendFilter2.toString());
sql.append("  and fa.cod_flia not in (select param_value from tbl_sec_comp_param where param_name ='FLIA_ACTIVO' and compania in(-1,al1.compania))) and (d.compania_dev = al1.compania) and (d.codigo_almacen_q_dev = al1.codigo_almacen) and (dd.compania = d.compania) and (dd.num_devolucion = d.num_devolucion) and (dd.anio_devolucion = d.anio_devolucion) and (dd.cod_articulo = a.cod_articulo) and (dd.cod_clase = a.cod_clase) and (dd.cod_familia = a.cod_flia) and (dd.compania = a.compania) and (d.codigo_almacen = al2.codigo_almacen) and (d.compania = al2.compania) and (dd.cod_familia = fa.cod_flia and dd.compania = fa.compania and fa.compania = d.compania_dev) and (a.compania = ca.compania and a.cod_flia = ca.cod_flia and a.cod_clase = ca.cod_clase) and (fa.cod_flia = a.cod_flia and fa.compania = a.compania) and (ca.compania = fa.compania and ca.cod_flia = fa.cod_flia) group by al1.descripcion, al2.descripcion, fa.cod_flia, fa.nombre, dd.cod_familia || '-' || dd.cod_clase || '-' || dd.cod_articulo, a.descripcion, dd.precio, a.compania, al1.codigo_almacen||'-'||al2.codigo_almacen, 'D'");

al = SQLMgr.getDataList(sql.toString());

String sqlSubTotal = "select almacen_sol, almacen_ent, cod_familias, sum(cargo) total, cod_almacenes from ("+ sql.toString() +") group by almacen_sol, almacen_ent, cod_familias, cod_almacenes order by almacen_sol, almacen_ent, cod_familias";

String sqlTotal = "select almacen_sol, almacen_ent, sum(cargo) total, cod_almacenes from ("+ sql.toString() +") group by almacen_sol, almacen_ent, cod_almacenes order by almacen_sol, almacen_ent";

String sqlGranTotal = "select sum(cargo) total from ("+ sql.toString() +")";

alSubTotal = SQLMgr.getDataList(sqlSubTotal);

alTotal = SQLMgr.getDataList(sqlTotal);

CommonDataObject cdoGT = SQLMgr.getData(sqlGranTotal);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int bed = 0, cantidad=0;
	double total = 0.00;
	int maxLines = 44; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	Hashtable htWh = new Hashtable();
	Hashtable htFlia = new Hashtable();

	cantidad = (alTotal.size()*2)+(alSubTotal.size()*3);

	for (int i=0; i<alTotal.size(); i++){
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);
		htWh.put(cdo.getColValue("cod_almacenes"),cdo.getColValue("total"));
	}

	for (int i=0; i<alSubTotal.size(); i++){
		CommonDataObject cdo = (CommonDataObject) alSubTotal.get(i);
		htFlia.put(cdo.getColValue("cod_almacenes")+"-"+cdo.getColValue("cod_familias"),cdo.getColValue("total"));
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
	String fileNamePrefix = "print_cargos_x_depto";
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
		setDetail.addElement(".10");
		setDetail.addElement(".59");
		setDetail.addElement(".07");
		setDetail.addElement(".07");
		setDetail.addElement(".07");
		setDetail.addElement(".10");

	String groupBy = "",subGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 12.0f;

	titulo ="INFORME DE GASTOS POR DEPARTAMENTO";
	subTitulo = "Desde "+fechaI+" Hasta "+fechaF;

	pdfHeader(pc, _comp, pCounter, nPages, " "+titulo,subTitulo , userName, fecha);

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_almacenes")+"-"+cdo.getColValue("cod_familias"))){
				if (i != 0){

					pc.setNoColumnFixWidth(setDetail);
					pc.createTable();
					pc.setFont(7, 0,Color.black);
					pc.addCols("",2,5,cHeight);
					pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",(String) htFlia.get(subGroupBy)),2,1,cHeight);
					pc.addTable();

					lCounter++;
				}
			}
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_almacenes"))){
				if (i != 0){
					pc.setNoColumnFixWidth(setDetail);
					pc.createTable();
					pc.setFont(7, 0,Color.black);
					pc.addCols("Total x Alm.: ",2,5,cHeight);
					pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",(String) htWh.get(groupBy)),2,1,cHeight);
					pc.addTable();
					lCounter++;
				}

				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addBorderCols("Entra a: "+cdo.getColValue("almacen_sol"),0,2,0.0f,0.0f,0.0f,0.0f,cHeight);
					pc.addBorderCols("Sale de: "+cdo.getColValue("almacen_ent"),0,4,0.0f,0.0f,0.0f,0.0f,cHeight);
				pc.addTable();
				lCounter++;
			}

			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_almacenes")+"-"+cdo.getColValue("cod_familias"))){
					pc.setNoColumnFixWidth(setDetail);
					pc.createTable();
					pc.setFont(7, 1,Color.black);
					pc.addCols("Codigo:  "+cdo.getColValue("cod_familias"),0,1,cHeight);
					pc.addCols(cdo.getColValue("desc_familia"),0,5,cHeight);
					pc.addTable();

					pc.setNoColumnFixWidth(setDetail);
					pc.createTable();
						pc.setFont(8, 1);
						pc.addBorderCols("Cod. Art.", 1, 1, 0.5f, 0.0f, 0.0f, 0.0f, cHeight);
						pc.addBorderCols("Descripción", 1, 1, 0.5f, 0.0f, 0.0f, 0.0f, cHeight);
						pc.addBorderCols("Uds", 1, 1, 0.5f, 0.0f, 0.0f, 0.0f, cHeight);
						pc.addBorderCols("Devuelto", 1, 1, 0.5f, 0.0f, 0.0f, 0.0f, cHeight);
						pc.addBorderCols("Precio", 1, 1, 0.5f, 0.0f, 0.0f, 0.0f, cHeight);
						pc.addBorderCols("Total", 1, 1, 0.5f, 0.0f, 0.0f, 0.0f, cHeight);
					pc.addTable();
					pc.copyTable("detailHeader");
					lCounter+=2;



			}
		pc.setNoColumnFixWidth(setDetail);
		pc.createTable();
		pc.setFont(7, 0, Color.black);
		pc.addCols(" "+cdo.getColValue("cod_art"), 0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("descripcion"), 0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("entregado"), 2,1,cHeight);
		if(cdo.getColValue("tipo_doc").equals("D")) pc.setFont(7, 0, Color.red);
		pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("devuelto")), 2,1,cHeight);
		pc.setFont(7, 0, Color.black);
		pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("costos")), 2,1,cHeight);
		if(cdo.getColValue("tipo_doc").equals("D")) pc.setFont(7, 0, Color.red);
		pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("cargo")), 2,1,cHeight);
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
			pc.addBorderCols("Entra a: "+cdo.getColValue("almacen_sol"),0,2,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.addBorderCols("Sale de: "+cdo.getColValue("almacen_ent"),0,4,0.0f,0.0f,0.0f,0.0f,cHeight);
			pc.addTable();

			pc.createTable();
			pc.setFont(7, 1,Color.black);
			pc.addCols("Codigo:  "+cdo.getColValue("cod_familias"),0,1,cHeight);
			pc.addCols(cdo.getColValue("desc_familia"),0,5,cHeight);
			pc.addTable();

			pc.addCopiedTable("detailHeader");
		}

		groupBy = cdo.getColValue("cod_almacenes");
		subGroupBy = cdo.getColValue("cod_almacenes")+"-"+cdo.getColValue("cod_familias");

	}//for i

	if (al.size() == 0){
		pc.createTable();
			pc.addCols("No existen registros",1,6);
		pc.addTable();
	} else {
		pc.setNoColumnFixWidth(setDetail);
		pc.createTable();
		pc.setFont(7, 0,Color.black);
		pc.addCols("",2,5,cHeight);
		pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",(String) htFlia.get(subGroupBy)),2,1,cHeight);
		pc.addTable();

		pc.createTable();
		pc.setFont(7, 0,Color.black);
		pc.addCols("Total x Alm.: ",2,5,cHeight);
		pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",(String) htWh.get(groupBy)),2,1,cHeight);
		pc.addTable();

		pc.createTable();
		pc.setFont(7, 0,Color.black);
		pc.addCols("Gran Total: ",2,5,cHeight);
		pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",(String) cdoGT.getColValue("total")),2,1,cHeight);
		pc.addTable();

	}
	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>