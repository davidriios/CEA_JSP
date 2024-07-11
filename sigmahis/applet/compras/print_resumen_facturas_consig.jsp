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
		REPORTE:		INV0032_CONSIG.RDF
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
String appendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String cod_prov = request.getParameter("cod_prov");
String appendFilter1 ="" , appendFilter2 = "",filter="";
String titulo = request.getParameter("titulo");
String depto = request.getParameter("depto");
String descAlm = request.getParameter("descAlm");


if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(cod_prov== null) cod_prov = "";
if(titulo== null) titulo = "";
if(depto== null) depto = "";
if(descAlm== null) descAlm = "";


if(!fDate.trim().equals(""))
{
appendFilter  +=" and  to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') >=  to_date('"+fDate+"' ,'dd/mm/yyyy') ";
appendFilter1 +=" and  to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') >=  to_date('"+fDate+"' ,'dd/mm/yyyy') ";
appendFilter2 +=" and  to_date(to_char(a.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') >=  to_date('"+fDate+"' ,'dd/mm/yyyy') ";

}
if(!tDate.trim().equals(""))
{
appendFilter  +=" and  to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') <=  to_date('"+tDate+"' ,'dd/mm/yyyy') ";
appendFilter1 +=" and  to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') <=  to_date('"+tDate+"' ,'dd/mm/yyyy') ";
appendFilter2 +=" and  to_date(to_char(a.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') <=  to_date('"+tDate+"' ,'dd/mm/yyyy') ";
}

if(!cod_prov.trim().equals(""))
{
 filter  +=" and  a.cod_proveedor = "+cod_prov;
 appendFilter1 +=" and  a.cod_provedor  = "+cod_prov;
}
if(!almacen.trim().equals(""))
{
	filter  +=" and  a.codigo_almacen = "+almacen;
	appendFilter1 +=" and  a.codigo_almacen = "+almacen;
}
else
{
filter  +="  and a.codigo_almacen is not null  ";
appendFilter1 +=" and a.codigo_almacen is not null  ";
}


sql="select 'A' type,'FC'  tipo_fac, a.cod_proveedor cod_prov, p.nombre_proveedor desc_prov, NVL (d.cantidad, 0) * NVL (d.precio, 0) + d.art_itbm monto ,0 cod_familia,' 'desc_familia, a.codigo_almacen , to_char(a.fecha_documento,'dd/mm/yyyy') fecha, nvl(a.numero_factura,' ') documento , a.usuario_creacion usuario from tbl_inv_recepcion_material a, tbl_com_proveedor p, tbl_inv_detalle_recepcion d where a.compania =  "+compania+" and (a.cod_proveedor =  p.cod_provedor and a.compania =  p.compania) AND (d.compania = a.compania AND d.anio_recepcion = a.anio_recepcion AND d.numero_documento = a.numero_documento) and a.fre_documento = 'FG' and a.estado='R' "+appendFilter+ filter+"        union           select 'A' type, 'NC'   tipo_dev , a.cod_provedor cod_prov_dev , p.nombre_proveedor desc_prov_dev , nvl(a.monto,0)*-1 monto_dev,0 cod_familia,' 'desc_familia , a.codigo_almacen alm_dev , to_char(a.fecha,'dd/mm/yyyy') fecha_dev , nvl(a.nota_credito,' ') documento_dev , a.usuario_creacion from tbl_inv_devolucion_prov a, tbl_com_proveedor p where a.compania = "+compania+" and (a.tipo_dev = 'C' ) and a.anulado_sino = 'N' and (a.cod_provedor =  p.cod_provedor) "+appendFilter1+"                union       select 'B' type,' ',x.cod_prov,x.desc_prov, sum(nvl(x.monto,0))monto,x.cod_familia,fa.nombre desc_familia,0 codigo_almacen , ' ' fecha_documento,' ' documento, ' ' usuario_creacion from ( select 'FC' tipo_fac , to_char(a.fecha_documento,'dd/mm/yyyy') fecha, nvl(a.numero_factura,' ') documento , NVL (d.cantidad, 0)*nvl(d.precio, 0) + d.art_itbm monto , a.cod_proveedor cod_prov , p.nombre_proveedor desc_prov  , a.codigo_almacen alm_fac , a.usuario_creacion usuario_creacion, d.cod_familia from tbl_inv_recepcion_material a, tbl_com_proveedor p, tbl_inv_detalle_recepcion d where a.compania =  "+compania+" and (a.cod_proveedor =  p.cod_provedor and a.compania =  p.compania) and (d.compania =  a.compania and d.anio_recepcion =  a.anio_recepcion and d.numero_documento =  a.numero_documento) "+appendFilter+ filter+" and a.fre_documento = (  'FG' ) and a.estado = 'R'        union                    select 'NC' tipo_dev  ,to_char(a.fecha,'dd/mm/yyyy')  fecha_dev, a.nota_credito documento_dev, nvl(a.monto,0)*-1 monto_dev, a.cod_provedor cod_prov_dev, p.nombre_proveedor desc_prov_dev , a.codigo_almacen alm_dev, a.usuario_creacion usuario_creacion, dp.cod_familia cod_flia_dev from tbl_inv_devolucion_prov a, tbl_com_proveedor p,tbl_inv_detalle_proveedor dp where a.compania = "+compania+" and (  a.tipo_dev = 'C' ) and a.anulado_sino = 'N'  and (a.cod_provedor =  p.cod_provedor) "+appendFilter1+" and (dp.compania = a.compania and dp.anio = a.anio and dp.num_devolucion = a.num_devolucion) /*and dp.cod_familia in (2,5)*/          union                 select 'ND' tipo_nd , to_char(a.fecha_ajuste,'dd/mm/yyyy') fecha_nd, a.n_d documento_nd , nvl(a.total,0) monto_nd , a.cod_proveedor cod_prov_nd , p.nombre_proveedor desc_prov_nd, a.codigo_almacen alm_nd, a.usuario_creacion usuario_creacion, to_number(da.cod_familia) cod_flia_nd from tbl_com_proveedor p , tbl_inv_ajustes  a,  tbl_inv_detalle_ajustes da where a.compania = "+compania+" and a.codigo_ajuste = 3 and (a.compania = da.compania and a.anio_ajuste = da.anio_ajuste and a.numero_ajuste = da.numero_ajuste and a.codigo_ajuste = da.codigo_ajuste)  and ( a.cod_proveedor = p.cod_provedor)"+appendFilter2 +filter+") x, 	tbl_inv_familia_articulo fa where  fa.compania = "+compania+" and fa.cod_flia(+) = x.Cod_familia  group by 'B' ,' ',x.cod_prov,x.desc_prov,x.cod_familia,fa.nombre,0  , ' ' ,' ' , ' '   order by 1,4 asc  ";



al = SQLMgr.getDataList(sql);


sql=" select cod_prov,desc_prov,sum(nvl(monto,0)) monto from ( select 'A' type,'FC'  tipo_fac, a.cod_proveedor cod_prov, p.nombre_proveedor desc_prov, NVL (d.cantidad, 0) * NVL (d.precio, 0) + d.art_itbm monto ,0 cod_familia,' 'desc_familia, a.codigo_almacen , to_char(a.fecha_documento,'dd/mm/yyyy') fecha, nvl(a.numero_factura,' ') documento , a.usuario_creacion usuario_creacion from tbl_inv_recepcion_material a, tbl_com_proveedor p, tbl_inv_detalle_recepcion d where a.compania =  "+compania+" and (a.cod_proveedor =  p.cod_provedor and a.compania =  p.compania) AND (d.compania = a.compania AND d.anio_recepcion = a.anio_recepcion AND d.numero_documento = a.numero_documento) and a.fre_documento = 'FG' and a.estado='R' "+appendFilter+ filter+"        union           select 'A' type, 'NC'   tipo_dev , a.cod_provedor cod_prov_dev , p.nombre_proveedor desc_prov_dev , nvl(a.monto,0)*-1 monto_dev,0 cod_familia,' 'desc_familia , a.codigo_almacen alm_dev , to_char(a.fecha,'dd/mm/yyyy') fecha_dev , nvl(a.nota_credito,' ') documento_dev , a.usuario_creacion from tbl_inv_devolucion_prov a, tbl_com_proveedor p where a.compania = "+compania+" and (a.tipo_dev = 'C' ) and a.anulado_sino = 'N' and (a.cod_provedor =  p.cod_provedor) "+appendFilter1+" ) x group by cod_prov,  desc_prov";

alTotal = SQLMgr.getDataList(sql);



if (request.getMethod().equalsIgnoreCase("GET"))
{
	int totalArt = 0;
	double total = 0.00,total_nivel = 0.00,total_fecha = 0.00;
	Hashtable htProv = new Hashtable();
	int maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill


	for (int i=0; i<alTotal.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alTotal.get(i);
		 total    += Double.parseDouble(cdo.getColValue("monto"));
		 htProv.put(cdo.getColValue("cod_prov"),cdo.getColValue("monto"));
	}

	int nItems = al.size() + (alTotal.size()*3)+6;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
    String month = mon;
	String servletPath = request.getServletPath();
	String day=fecha.substring(0, 2);
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";
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

	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	String create = CmnMgr.createFolder(directory, folderName, year, month);

	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".12");
		setDetail.addElement(".12");
		setDetail.addElement(".25");
		setDetail.addElement(".25");
		setDetail.addElement(".26");

	Vector setDetail0 = new Vector();
		setDetail0.addElement(".10");
		setDetail0.addElement(".25");
		setDetail0.addElement(".25");
		setDetail0.addElement(".35");

	String groupBy = "",subGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INFORME DE DOCUMENTOS RECIBIDOS( CONSIGNACION) ", " "+fDate+"       A       "+tDate, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols(" "+descAlm,1,5);
	pc.addTable();
	pc.copyTable("detailHeader0");

	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("TIPO",1,1);
		pc.addCols("FECHA",1,1);
		pc.addCols("DOCUMENTO",1,1);
		pc.addCols("MONTO",1,1);
		pc.addCols("USUARIO",0,1);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(cdo.getColValue("type").trim().equals("A"))
		{
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_prov")))
			{
					if (i != 0)
					{
						pc.setFont(7, 1);
						pc.createTable();
							pc.addCols("Total:  ",2,3,cHeight);
							pc.addCols(" $"+CmnMgr.getFormattedDecimal((String) htProv.get(groupBy)),2,1,cHeight);
							pc.addCols("  ",1,1,cHeight);
						pc.addTable();

						lCounter++;
					}

					pc.setFont(7, 1,Color.blue);
					pc.createTable();
						pc.addCols(" "+cdo.getColValue("cod_prov")+"      "+cdo.getColValue("desc_prov"),0,5,cHeight);
					pc.addTable();
					pc.addCopiedTable("detailHeader");

					lCounter+=2;
			}



		pc.setFont(7, 0);
		pc.createTable();
			if(cdo.getColValue("tipo_fac").trim().equals("NC")) pc.setFont(7, 0,Color.red);
			else if(cdo.getColValue("tipo_fac").trim().equals("ND")) pc.setFont(7, 0,Color.magenta);
			pc.addCols(""+cdo.getColValue("tipo_fac"),1,1,cHeight);
			pc.setFont(7, 0);
			pc.addCols(""+cdo.getColValue("fecha"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("documento"),1,1,cHeight);
			if(cdo.getColValue("tipo_fac").trim().equals("NC")) pc.setFont(7, 0,Color.red);
			else if(cdo.getColValue("tipo_fac").trim().equals("ND")) pc.setFont(7, 0,Color.magenta);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
			pc.setFont(7, 0);
			pc.addCols(""+cdo.getColValue("usuario"),0,1,cHeight);
		pc.addTable();
		lCounter++;
		pc.setFont(7, 0);

	}//
	else
	{

			if (subGroupBy.trim().equals("A"))
			{

				pc.setFont(7, 1);
						pc.createTable();
							pc.addCols("Total:  ",2,3,cHeight);
							pc.addCols(" $"+CmnMgr.getFormattedDecimal((String) htProv.get(groupBy)),2,1,cHeight);
							pc.addCols("  ",1,1,cHeight);
						pc.addTable();

						lCounter++;

				pc.setFont(7, 0,Color.blue);
				pc.createTable();
					pc.addCols("Total:",2,3,cHeight);
					pc.addCols("  $ "+CmnMgr.getFormattedDecimal(""+total),2,1,cHeight);
					pc.addCols(" ",1,1,cHeight);
				pc.addTable();
				lCounter++;

				pc.createTable();
					pc.addCols(" ",0,4,cHeight);
				pc.addTable();

				pc.setNoColumnFixWidth(setDetail0);
				pc.createTable();
					pc.addBorderCols("DESGLOSE POR FAMILIA",1,4,cHeight);
				pc.addTable();

				lCounter+=2;
				subGroupBy = cdo.getColValue("type");
			}


			if (cdo.getColValue("type").trim().equals("B"))
			{
				pc.setNoColumnFixWidth(setDetail0);
				pc.setFont(7, 0);
				pc.createTable();
					pc.addBorderCols(" "+cdo.getColValue("cod_prov"),1,1,cHeight);
					pc.addBorderCols(" "+cdo.getColValue("desc_prov"),0,1,cHeight);
					pc.addBorderCols(" "+cdo.getColValue("desc_familia"),0,1,cHeight);
					pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
				pc.addTable();

				total_nivel +=Double.parseDouble(cdo.getColValue("monto"));
				lCounter++;
			}

	}
		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "INFORME DE DOCUMENTOS RECIBIDOS ( CONSIGNACION )", " "+fDate+"       A       "+tDate, userName, fecha);
			pc.addCopiedTable("detailHeader0");
			if (cdo.getColValue("type").trim().equals("A"))
			{
				pc.setNoColumnFixWidth(setDetail);
				pc.setFont(7, 1,Color.blue);
				pc.createTable();
					pc.addCols(" "+cdo.getColValue("cod_prov")+"      "+cdo.getColValue("desc_prov"),0,5,cHeight);
				pc.addTable();
				pc.addCopiedTable("detailHeader");
			}
			else if (cdo.getColValue("type").trim().equals("B"))
			{
				pc.setNoColumnFixWidth(setDetail0);
					pc.createTable();
					pc.addBorderCols("DESGLOSE POR FAMILIA",1,4,cHeight);
				pc.addTable();
		  }

	  }

		groupBy    = cdo.getColValue("cod_prov");
		subGroupBy = cdo.getColValue("type");

	}//for i

	if (al.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
				pc.setFont(7, 0,Color.blue);
				pc.createTable();
					pc.addCols("Total ",2,3,cHeight);
					pc.addCols(" $"+CmnMgr.getFormattedDecimal(""+total_nivel),2,1,cHeight);
				pc.addTable();

	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
