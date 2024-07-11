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
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String depto = request.getParameter("depto");
String anioEntrega = request.getParameter("anioEntrega");
String anioReq = request.getParameter("anioReq");
String noReq = request.getParameter("noReq");
String noEntrega = request.getParameter("noEntrega");
String articulo = request.getParameter("articulo");

String titulo = request.getParameter("titulo");
String descDepto = request.getParameter("descDepto");
String compania1 = request.getParameter("compania1");



if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(depto== null) depto = "";
if(anioEntrega== null) anioEntrega = "";
if(anioReq== null) anioReq = "";
if(noReq== null) noReq = "";
if(noEntrega== null) noEntrega = "";
if(articulo== null) articulo = "";
if(titulo== null) titulo = "";
if(descDepto== null) descDepto = "";
if(compania1== null) compania1 = "";

if (appendFilter == null) appendFilter = "";

sql=" select all em.compania, em.anio||' '||lpad(em.no_entrega, 6, '0') no_entrega, nvl(em.monto,0.00) monto, lpad(de.cod_familia, 3, '0')||lpad(de.cod_clase, 3, '0')||lpad(de.cod_articulo, 6, '0') cod_articulo, nvl(de.cantidad_entregada,0) entregada, a.descripcion desc_articulo, (select sum(d.cantidad) from d_sol_req d where d.cod_articulo = de.cod_articulo and d.req_anio = em.req_anio and  d.tipo_solicitud = em.req_tipo_solicitud and d.solicitud_no  = em.req_solicitud_no and d.compania = nvl(em.compania_sol,de.compania) and d.art_familia = de.cod_familia and d.art_clase = de.cod_clase ) /*de.cantidad*/ solicitada , i.disponible disponible , em.compania_sol, co.nombre from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_articulo a, tbl_inv_inventario i, tbl_sec_compania co where (em.compania = "+compania+" and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date(nvl('"+fDate+"',to_char(em.fecha_entrega,'dd/mm/yyyy')),'dd/mm/yyyy') and to_date(nvl('"+tDate+"',to_char(em.fecha_entrega,'dd/mm/yyyy')),'dd/mm/yyyy') and em.compania_sol = nvl ('"+compania1+"',em.compania_sol) and em.no_entrega = nvl( '"+noEntrega+"',em.no_entrega) and em.anio = nvl('"+anioEntrega+"',em.anio) and em.compania_sol is not null) and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (de.cod_familia = a.cod_flia and de.cod_clase = a.cod_clase and de.cod_articulo = a.cod_articulo) and (i.compania = a.compania and i.art_familia = a.cod_flia and i.art_clase = a.cod_clase and i.cod_articulo = a.cod_articulo) and i.codigo_almacen = em.codigo_almacen and (em.compania_sol = co.codigo) order by em.compania_sol, em.anio||' '||lpad(em.no_entrega, 6, '0'), lpad(de.cod_familia, 3, '0')||lpad(de.cod_clase, 3, '0')||lpad(de.cod_articulo, 6, '0') ";

al = SQLMgr.getDataList(sql);

sql="select count(*)*3 nLine, compania_sol,nombre from ( select distinct em.anio||' '||lpad(em.no_entrega, 6, '0') no_entrega,  em.compania_sol, co.nombre from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_articulo a, tbl_inv_inventario i, tbl_sec_compania co where (em.compania = "+compania+" and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date(nvl('"+fDate+"',to_char(em.fecha_entrega,'dd/mm/yyyy')),'dd/mm/yyyy') and to_date(nvl('"+tDate+"',to_char(em.fecha_entrega,'dd/mm/yyyy')),'dd/mm/yyyy') and em.compania_sol = nvl ('"+compania1+"',em.compania_sol) and em.no_entrega = nvl( '"+noEntrega+"',em.no_entrega) and em.anio = nvl('"+anioEntrega+"',em.anio) and em.compania_sol is not null) and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (de.cod_familia = a.cod_flia and de.cod_clase = a.cod_clase and de.cod_articulo = a.cod_articulo) and (i.compania = a.compania and i.art_familia = a.cod_flia and i.art_clase = a.cod_clase and i.cod_articulo = a.cod_articulo) and i.codigo_almacen = em.codigo_almacen and (em.compania_sol = co.codigo) order by em.compania_sol, em.anio||' '||lpad(em.no_entrega, 6, '0') ) group by compania_sol,nombre ";

alTotal = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int nLine = 0;
	double total = 0.00;
	int maxLines = 45; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill


	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);
		 nLine += Integer.parseInt(cdo.getColValue("nLine"));
	}

	int nItems = al.size() + (alTotal.size()*2 )+nLine;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

		//	System.out.println(" nLine ==  "+nLine+"   al.size()  =   "+al.size()+"    altotal.size()    =   "+alTotal.size()+"    =  nItems =   "+nItems );

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = false;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_ent_companias";
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
		setDetail.addElement(".12");
		setDetail.addElement(".58");
		setDetail.addElement(".10");
		setDetail.addElement(".10");
		setDetail.addElement(".10");

	Vector setDetail0 = new Vector();
		setDetail0.addElement(".15");
		setDetail0.addElement(".35");
		setDetail0.addElement(".15");
		setDetail0.addElement(".35");

	String groupBy = "",subGroupBy = "",observ ="";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 13.0f;

	pdfHeader(pc, _comp, pCounter, nPages, " "+descDepto,""+titulo+"    DESDE    "+fDate+"    HASTA    "+tDate, userName, fecha);


	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",0);
		pc.addBorderCols("EXISTENCIA",1);
		pc.addBorderCols("SOLICITADO",1);
		pc.addBorderCols("ENTREGADO",1);

	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


			if (!groupBy.equalsIgnoreCase(cdo.getColValue("compania_sol")))
			{

						pc.setNoColumnFixWidth(setDetail0);
						pc.createTable();
							pc.addCols(" ",2,4,cHeight);
						pc.addTable();
						lCounter++;

					pc.setNoColumnFixWidth(setDetail0);
					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						//pc.addCols(" ",1,1,cHeight);
						pc.addCols(" "+cdo.getColValue("nombre"),1,4,cHeight);
					pc.addTable();
					lCounter++;
			}



			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("compania_sol")+"-"+ cdo.getColValue("no_entrega")))
			{

					if (i != 0)
					{
						pc.setNoColumnFixWidth(setDetail0);
						pc.createTable();
							pc.addCols(" ",2,4,cHeight);
						pc.addTable();
						lCounter++;
					}
					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addCols("Entrega No :"+cdo.getColValue("no_entrega"),2,4,cHeight);
					pc.addTable();

					pc.setNoColumnFixWidth(setDetail);
					pc.addCopiedTable("detailHeader");

					lCounter+=2;
			}



		pc.setFont(9, 0);
		pc.createTable();
			pc.addCols(""+cdo.getColValue("cod_articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("disponible"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("solicitada"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("entregada"),2,1,cHeight);
		pc.addTable();
		lCounter++;

		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, " "+descDepto, ""+titulo+"    DESDE    "+fDate+"    HASTA    "+tDate, userName, fecha);

			pc.setNoColumnFixWidth(setDetail0);

					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						//pc.addCols(" "+cdo.getColValue("cod_almacen"),1,1,cHeight);
						pc.addCols(" "+cdo.getColValue("nombre"),1,4,cHeight);
					pc.addTable();


					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addCols("Entrega No :"+cdo.getColValue("no_entrega"),2,4,cHeight);
					pc.addTable();

					pc.setNoColumnFixWidth(setDetail);
					pc.addCopiedTable("detailHeader");
		}

		groupBy    = cdo.getColValue("compania_sol");
		subGroupBy = cdo.getColValue("compania_sol")+"-"+cdo.getColValue("no_entrega");
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