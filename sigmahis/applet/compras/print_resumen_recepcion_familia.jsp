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
		REPORTE:		INV70231.RDF
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


String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String cod_prov = request.getParameter("proveedor");
String familia = request.getParameter("familia");
String articulo = request.getParameter("articulo");
String factura = request.getParameter("factura");
String descAlm = request.getParameter("descAlm");
String appendFilter1 ="" , appendFilter2 = "",filter="";



String userName = UserDet.getUserName();
String userId = UserDet.getUserId();


if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(cod_prov== null) cod_prov = "";
if(familia== null) familia = "";
if(articulo== null) articulo = "";
if(factura== null) factura = "";
if(descAlm== null) descAlm = "";
StringBuffer sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(", 'TIPO_PAGO_ORD_COMP'), '1') excluir_recep_contado  from dual");
CommonDataObject _cdo = SQLMgr.getData(sbSql.toString());

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

if(!factura.trim().equals(""))
{
 appendFilter +=" and  a.numero_factura  = "+factura;
 appendFilter1 +=" and  a.numero_factura  = "+factura;
 appendFilter2 +=" and  a.numero_doc  = "+factura;
}

if(!familia.trim().equals(""))
{
 filter +=" and  fa.cod_flia  = "+familia;
 appendFilter1 +=" and  fa.cod_flia  = "+familia;
}

if(!articulo.trim().equals(""))
{
 filter +=" and  d.cod_articulo = "+articulo;
 appendFilter1 +=" and  d.cod_articulo = "+articulo;
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


sql=" select type, descripcion ,nvl(monto,0) monto, cod_prov, codigo_almacen, familia, almacen, nombre from ( select 'A' type, p.nombre_proveedor descripcion, sum((d.cantidad* d.articulo_und)*d.precio) monto, a.cod_proveedor cod_prov , a.codigo_almacen, d.cod_familia familia, al.descripcion almacen, fa.nombre nombre from tbl_inv_recepcion_material a, tbl_inv_detalle_recepcion d, tbl_com_proveedor p, tbl_inv_almacen al, tbl_inv_familia_articulo fa where a.compania = "+compania+" and  (a.cod_proveedor =  p.cod_provedor) and  a.fre_documento in ('OC', 'FR'"+(_cdo.getColValue("excluir_recep_contado").equals("1")?"":", 'FC'")+") and (a.compania = al.compania and a.codigo_almacen = al.codigo_almacen) and (d.compania = fa.compania and d.cod_familia = fa.cod_flia) and  a.estado = 'R' and (d.compania = a.compania and d.numero_documento = a.numero_documento and d.anio_recepcion = a.anio_recepcion) "+appendFilter + filter +" group by 1,a.codigo_almacen,al.descripcion, a.cod_proveedor, p.nombre_proveedor, d.cod_familia, fa.nombre union  select 'A', p.nombre_proveedor desc_prov_dev, sum( ((d.precio * decode(d.cantidad,0,1,d.cantidad))+( decode(d.cantidad,0,1,d.cantidad)* d.art_itbm))*-1  ) monto_dev, a.cod_provedor cod_prov_dev, a.codigo_almacen alm_dev, d.cod_familia familia_dev, al.descripcion almacen_dev, fa.nombre familiaDev from tbl_inv_devolucion_prov a, tbl_com_proveedor p, tbl_inv_detalle_proveedor d, tbl_inv_articulo ar, tbl_inv_almacen al, tbl_inv_familia_articulo fa where a.compania = "+compania+" and a.anulado_sino = 'N'  and ( a.tipo_dev = 'N'  or a.tipo_dev is null) and (d.compania = fa.compania and d.cod_familia = fa.cod_flia) and (a.compania = al.compania and a.codigo_almacen = al.codigo_almacen) and a.anio = d.anio and a.num_devolucion = d.num_devolucion and a.compania = d.compania and (d.cod_familia = ar.cod_flia and d.cod_clase = ar.cod_clase and d.cod_articulo = ar.cod_articulo and d.compania = ar.compania) and (a.cod_provedor =  p.cod_provedor) "+appendFilter1 +" group by 1,a.codigo_almacen, al.descripcion, a.cod_provedor,p.nombre_proveedor, d.cod_familia, fa.nombre    union     select 'A', p.nombre_proveedor desc_prov_nd,  sum((decode(d.cantidad_ajuste,0,1,d.cantidad_ajuste)* d.precio)) monto_nd, a.cod_proveedor cod_prov_nd   , a.codigo_almacen alm_nd, to_number(d.cod_familia) familia_nd, al.descripcion almacen_aj, fa.nombre familiaAj from tbl_com_proveedor p, tbl_inv_ajustes a, tbl_inv_detalle_ajustes d, tbl_inv_articulo ar, tbl_inv_almacen al, tbl_inv_familia_articulo fa, tbl_inv_recepcion_material rm where a.compania = "+compania+" and a.codigo_ajuste=3 and a.compania = d.compania and a.anio_ajuste = d.anio_ajuste and a.numero_ajuste = d.numero_ajuste and a.codigo_ajuste = d.codigo_ajuste and (a.compania = al.compania and a.codigo_almacen = al.codigo_almacen) and (d.compania = fa.compania and to_number(d.cod_familia) = fa.cod_flia) and  (to_number(d.cod_familia) = ar.cod_flia and d.cod_clase = ar.cod_clase and d.cod_articulo = ar.cod_articulo and d.compania = ar.compania) and a.anio_doc = rm.anio_recepcion and a.numero_doc = rm.numero_documento and a.compania = rm.compania and ( a.cod_proveedor = p.cod_provedor) "+appendFilter2 + filter +" group by 1, a.codigo_almacen, al.descripcion, a.cod_proveedor, p.nombre_proveedor, to_number(d.cod_familia),fa.nombre 	)  union   select 'B' type,'0', 0 , 0,0,0,' ',' '  from dual  "; 

sql+="  union    select 'B' type, nivel, total,0,0,0,desc_nivel,' ' from  (select distinct nvl(a.nivel,'S/N')nivel  ,decode(a.nivel,'040','OXIGENO','041','MATERIALES','042','MEDICAMENTOS','043','COMESTIBLES','044','ANESTESIA','045','OTROS',null,'SIN NIVEL') desc_nivel, nvl(x.total,0)-nvl(y.nota_credito,0) + nvl(z.total_nd,0) total from    tbl_inv_familia_articulo a, (	 select sum((nvl(precio,0)*nvl(cantidad,0))*nvl(articulo_und,0))total, nvl(fa.nivel,'S/N') nivel from tbl_inv_recepcion_material a,  tbl_inv_detalle_recepcion d, tbl_inv_familia_articulo fa where a.compania =  "+compania+appendFilter + filter +"and a.fre_documento in ('OC', 'FR'"+(_cdo.getColValue("excluir_recep_contado").equals("1")?"":", 'FC'")+") and a.estado = 'R' and d.anio_recepcion = a.anio_recepcion and d.numero_documento = a.numero_documento and d.compania = a.compania and (d.compania = fa.compania(+) and d.cod_familia = fa.cod_flia(+) and fa.compania =a.compania) group by nvl(fa.nivel,'S/N') )x, (  select sum((nvl(d.precio,0)* decode(d.cantidad,0,1,d.cantidad))+( decode(d.cantidad,0,1,d.cantidad) * nvl(d.art_itbm,0))) nota_credito, nvl(fa.nivel,'S/N') nivel from tbl_inv_devolucion_prov  a, tbl_inv_detalle_proveedor d, tbl_inv_familia_articulo fa where a.compania = "+compania+" and a.anulado_sino = 'N' and (  a.tipo_dev = 'N' or a.tipo_dev is null) and a.compania = d.compania and a.anio = d.anio and a.num_devolucion = d.num_devolucion and d.compania = fa.compania and d.cod_familia = fa.cod_flia "+appendFilter1 +" group by  nvl(fa.nivel,'S/N')   ) y ,( select  sum(nvl(d.precio,0)* decode(d.cantidad_ajuste,0,1,d.cantidad_ajuste)) total_nd,nvl(fa.nivel,'S/N') nivel from tbl_inv_ajustes a, tbl_inv_detalle_ajustes  d, tbl_inv_familia_articulo fa, tbl_inv_recepcion_material rm where a.compania = "+compania+" and a.codigo_ajuste = 3 and a.compania = d.compania and a.anio_ajuste = d.anio_ajuste and a.numero_ajuste = d.numero_ajuste and a.anio_doc = rm.anio_recepcion and a.numero_doc = rm.numero_documento and a.compania = rm.compania and a.codigo_ajuste = d.codigo_ajuste and d.cod_familia = fa.cod_flia and d.compania = fa.compania "+appendFilter2+ filter +" group by  nvl(fa.nivel,'S/N')  )z where   compania = "+compania+" and nvl(a.nivel,'S/N') = x.nivel(+)  and nvl(a.nivel,'S/N') = y.nivel (+) and nvl(a.nivel,'S/N')  = z.nivel (+)  ) b  order by 1,5,6,4 ";				 
al = SQLMgr.getDataList(sql);


sql=" select cod_flia, desc_flia ,sum(nvl(monto,0)) monto from (  select 'FC' tipo_fac, sum((d.cantidad* d.articulo_und)*d.precio) monto , a.cod_proveedor cod_prov, p.nombre_proveedor desc_prov  , fa.cod_flia cod_flia, fa.nombre desc_flia from tbl_inv_recepcion_material a, tbl_inv_detalle_recepcion d, tbl_com_proveedor p, tbl_inv_almacen al, tbl_inv_familia_articulo fa where a.compania = "+compania+" and  (a.cod_proveedor =  p.cod_provedor) and  a.fre_documento in ('OC', 'FR'"+(_cdo.getColValue("excluir_recep_contado").equals("-1")?"":", 'FC'")+") and (a.compania = al.compania and a.codigo_almacen = al.codigo_almacen) and (d.compania = fa.compania and d.cod_familia = fa.cod_flia) and  a.estado = 'R' and (d.compania = a.compania and d.numero_documento = a.numero_documento and d.anio_recepcion = a.anio_recepcion) "+appendFilter + filter +" group by 1,fa.cod_flia,fa.nombre,a.cod_proveedor,p.nombre_proveedor   union  select 'NC' tipo_dev, sum( ((d.precio * decode(d.cantidad,0,1,d.cantidad))+( decode(d.cantidad,0,1,d.cantidad)* d.art_itbm))*-1  ) monto_dev, a.cod_provedor cod_prov_dev, p.nombre_proveedor desc_prov_dev , fa.cod_flia cod_flia, fa.nombre desc_flia from tbl_inv_devolucion_prov a, tbl_com_proveedor p, tbl_inv_detalle_proveedor d, tbl_inv_articulo ar, tbl_inv_almacen al, tbl_inv_familia_articulo fa where a.compania = "+compania+" and a.anulado_sino = 'N'  and ( a.tipo_dev = 'N'  or a.tipo_dev is null) and (d.compania = fa.compania and d.cod_familia = fa.cod_flia) and (a.compania = al.compania and a.codigo_almacen = al.codigo_almacen) and a.anio = d.anio and a.num_devolucion = d.num_devolucion and a.compania = d.compania and (d.cod_familia = ar.cod_flia and d.cod_clase = ar.cod_clase and d.cod_articulo = ar.cod_articulo and d.compania = ar.compania) and (a.cod_provedor =  p.cod_provedor) "+appendFilter1 +" group by 1,fa.cod_flia,fa.nombre,a.cod_provedor,p.nombre_proveedor  union     select 'ND' tipo_nd   , sum((decode(d.cantidad_ajuste,0,1,d.cantidad_ajuste)* d.precio)) monto_nd , a.cod_proveedor cod_prov_nd  , p.nombre_proveedor desc_prov_nd , fa.cod_flia cod_flia, fa.nombre desc_flia from tbl_com_proveedor p, tbl_inv_ajustes a, tbl_inv_detalle_ajustes d, tbl_inv_articulo ar, tbl_inv_almacen al, tbl_inv_familia_articulo fa where a.compania = "+compania+" and a.codigo_ajuste=3 and a.compania = d.compania and a.anio_ajuste = d.anio_ajuste and a.numero_ajuste = d.numero_ajuste and a.codigo_ajuste = d.codigo_ajuste and (a.compania = al.compania and a.codigo_almacen = al.codigo_almacen) and (d.compania = fa.compania and to_number(d.cod_familia) = fa.cod_flia) and  (to_number(d.cod_familia) = ar.cod_flia and d.cod_clase = ar.cod_clase and d.cod_articulo = ar.cod_articulo and d.compania = ar.compania) and ( a.cod_proveedor = p.cod_provedor) "+appendFilter2 + filter +" group by 1,fa.cod_flia,fa.nombre,a.cod_proveedor,p.nombre_proveedor  	) group by cod_flia, desc_flia"; 

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
		 htProv.put(cdo.getColValue("cod_flia"),cdo.getColValue("monto"));
		System.out.println("*************************************************");
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

	String folderName = "inventario";  
	String fileNamePrefix = "print_resumen_factura";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+userId+".pdf";
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
		setDetail.addElement(".20");
		setDetail.addElement(".45");
		setDetail.addElement(".25");
		
	Vector setDetail0 = new Vector();
		setDetail0.addElement(".10");
		setDetail0.addElement(".25");
		setDetail0.addElement(".25");
		setDetail0.addElement(".35");

	String groupBy = "",subGroupBy = "",observ ="" ,sGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 12.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "RESUMEN DE RECEPCIONES DE PROVEEDOR POR FAMILIA ", " "+fDate+"       AL       "+tDate, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(8, 1,Color.blue);
		pc.addCols(" "+descAlm,1,4);
	pc.addTable();
	pc.copyTable("detailHeader0");
	
	

	pc.createTable();
		pc.setFont(7, 1);
		pc.addCols("",1,1);
		pc.addCols("Proveedor",0,1);
		pc.addCols("Descripción",0,1);
		pc.addCols("Monto",2,1);
	//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(cdo.getColValue("type").trim().equals("A"))
		{
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("familia")))
			{
					if (i != 0)
					{
						pc.setFont(7, 1);
						pc.createTable();
							pc.addCols("Sub Total por Familia : _ _ _ _ _ _ _ ",1,3,cHeight);
							pc.addCols(" $"+CmnMgr.getFormattedDecimal((String) htProv.get(groupBy)),2,1,cHeight);
						pc.addTable();
						
						lCounter++;
					}
					
					pc.setFont(7, 1,Color.red);
					pc.createTable();
						pc.addCols("Familia :  "+cdo.getColValue("familia")+"      "+cdo.getColValue("nombre"),0,4,cHeight);
					pc.addTable();
					pc.addCopiedTable("detailHeader");
					
					lCounter+=2;
			}
			
			

		pc.setFont(7, 0);
		pc.createTable();
			
			pc.addCols("",1,1,cHeight);
			pc.setFont(7, 0);
			pc.addCols(""+cdo.getColValue("cod_prov"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("descripcion"),0,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
		pc.addTable();
		lCounter++;
		pc.setFont(7, 0);
		
	}//
	else 
	{
			
			//System.out.println("type =    "+cdo.getColValue("type")+"documento   "+cdo.getColValue("documento")); 
			
			if (cdo.getColValue("type").trim().equals("B")&& !cdo.getColValue("descripcion").trim().equals("")&& cdo.getColValue("descripcion").trim().equals("0"))
			{		
				
				String val = ((String) htProv.get(groupBy));
				if(val == null || val.trim().equals("")) val ="0";
				pc.setFont(8, 1);
						pc.createTable();
							pc.addCols("Sub Total por Familia : _ _ _ _ _ _ _ ",1,3,cHeight);
							pc.addCols(" $"+CmnMgr.getFormattedDecimal(val),2,1,cHeight);
							
						pc.addTable();
						
						lCounter++;
						
						
				pc.setFont(8, 0,Color.blue);
				pc.createTable();
					pc.addCols("Gran Total por Almacen : _ _ _ _ _ _ _",1,3,cHeight);
					pc.addCols("  $ "+CmnMgr.getFormattedDecimal(""+total),2,1,cHeight);
				pc.addTable();
				lCounter++;
				
				pc.createTable();
					pc.addCols(" ",0,4,cHeight);
				pc.addTable();
				
				pc.setNoColumnFixWidth(setDetail0);
				pc.setFont(8, 0,Color.blue);
				pc.createTable();
					pc.addCols("RESUMEN POR NIVEL CONTABLE ",1,3,cHeight);
					pc.addCols(" ",0,1,cHeight);
				pc.addTable();
				pc.setNoColumnFixWidth(setDetail0);
				pc.createTable();
					pc.addCols("Nivel ",1,1,cHeight);
					pc.addCols("Descripción",1,1,cHeight);
					pc.addCols("Sub-Total",1,1,cHeight);
					pc.addCols(" ",0,1,cHeight);
				pc.addTable();
				lCounter+=3;
			}	
			
			
			if (cdo.getColValue("type").trim().equals("B")&&!cdo.getColValue("descripcion").trim().equals("")&& !cdo.getColValue("descripcion").trim().equals("0"))
			{
				pc.setNoColumnFixWidth(setDetail0);
				pc.setFont(7, 0);
				pc.createTable();
					pc.addBorderCols(" "+cdo.getColValue("descripcion"),1,1,cHeight);
					pc.addBorderCols(" "+cdo.getColValue("almacen"),0,1,cHeight);
					pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
					pc.addCols(" ",0,1,cHeight);
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

			pdfHeader(pc, _comp, pCounter, nPages, "RESUMEN DE RECEPCIONES DE PROVEEDOR POR FAMILIA ", " "+fDate+"       AL       "+tDate, userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
				pc.createTable();
				pc.setFont(8, 1,Color.blue);
				pc.addCols(" "+descAlm,1,4);
	        	pc.addTable();
			
			pc.addCopiedTable("detailHeader0");
			if (cdo.getColValue("type").trim().equals("A"))
			{
				pc.setNoColumnFixWidth(setDetail);
				pc.setFont(7, 1,Color.red);
				pc.createTable();
					pc.addCols("Familia :  "+cdo.getColValue("familia")+"      "+cdo.getColValue("nombre"),0,4,cHeight);
				pc.addTable();
				pc.addCopiedTable("detailHeader");
			}
			else if (cdo.getColValue("type").trim().equals("B"))
			{
				pc.setNoColumnFixWidth(setDetail0);
					pc.createTable();
					pc.setFont(8, 0,Color.blue);
						pc.addCols(" ",0,1,cHeight);
						pc.addCols("RESUMEN POR NIVEL CONTABLE ",1,2,cHeight);
						pc.addCols(" ",0,1,cHeight);
					pc.addTable();
					
					pc.createTable();
						pc.addCols("Nivel ",1,1,cHeight);
						pc.addCols("Descripción",1,1,cHeight);
						pc.addCols("Sub-Total",1,1,cHeight);
						pc.addCols(" ",0,1,cHeight);
					pc.addTable();
			  }
				
		}

		groupBy    = cdo.getColValue("familia");
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
				pc.setFont(8, 0,Color.blue);
				pc.createTable();
					pc.addCols(" ",0,1,cHeight);
					pc.addBorderCols("Gran Total ",2,1,cHeight);
					pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+total),2,1,cHeight);
					pc.addCols(" ",0,1,cHeight);
				pc.addTable();
	
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>