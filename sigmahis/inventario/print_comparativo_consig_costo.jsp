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
		REPORTE:		INV00132_V2.RDF
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
String appendFilter =  "",appendFilter1 = "",appendFilter3="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String prov = request.getParameter("prov");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String subclase = request.getParameter("subclase");

if(almacen== null) almacen = "";
if(tDate== null)   tDate   = "";
if(fDate== null)   fDate   = "";
if(prov== null)    prov    = "";
if(familyCode== null)    familyCode    = "";
if(classCode== null)    classCode    = "";
if(subclase== null)    subclase    = "";

//if(prov.trim().equals("") || almacen.trim().equals("") )  throw new Exception("SELECCIONE PARAMETROS PARA EL REPORTE (ALMACEN / PROVEEDOR)");
if (appendFilter == null) appendFilter = "";


if(!tDate.trim().equals(""))
{
appendFilter += " and to_date(to_char(e.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')   >= to_date('"+tDate+"','dd/mm/yyyy') ";
appendFilter1 +=" and to_date(to_char(r.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+tDate+"','dd/mm/yyyy') ";
appendFilter3 += " and fdt.fecha_creacion  >=  to_date('"+tDate+"','dd/mm/yyyy')";

}
if(!fDate.trim().equals(""))
{
appendFilter +="   and to_date(to_char(e.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')   <= to_date('"+fDate+"','dd/mm/yyyy') ";
appendFilter1 +="  and to_date(to_char(r.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fDate+"','dd/mm/yyyy') ";
appendFilter3 += " and fdt.fecha_creacion  <=  to_date('"+fDate+"','dd/mm/yyyy')";
}


sql=" select al.codigo_almacen , al.descripcion desc_almacen, prov.cod_provedor cod_prov , prov.nombre_proveedor desc_prov, ar.cod_flia||'-'||ar.cod_clase||'-'||ar.cod_articulo cod_articulo, ar.cod_flia, ar.cod_clase,ar.cod_subclase, ar.cod_articulo cod_art , ar.descripcion desc_articulo, nvl(  i.disponible,0) inventario, nvl(cargo_pac.cantidad,0)  v_pac,  nvl(cargo_pac.costo,0)  costopac, nvl(cargo_uso.cantidad,0)  v_uso,  nvl(cargo_uso.costo,0)  costouso , nvl(fac_prov.cantidad,0) nFactura, nvl(fac_prov.valor,0)  costofac , ((nvl(cargo_pac.cantidad,0) + nvl(cargo_uso.cantidad,0)) - nvl(fac_prov.cantidad,0)) pendiente  ,((nvl(cargo_pac.costo,0) + nvl(cargo_uso.costo,0) ) - nvl(fac_prov.valor,0)) costopend ,(select nombre from tbl_inv_familia_articulo where compania = ar.compania and cod_flia=ar.cod_flia)descFamilia, (select descripcion from tbl_inv_clase_articulo where compania = ar.compania and cod_flia =ar.cod_flia and cod_clase=ar.cod_clase)descClase,(select descripcion from tbl_inv_subclase where compania = ar.compania and cod_flia =ar.cod_flia and cod_clase=ar.cod_clase and subclase_id=ar.cod_subclase) descSubClase from tbl_inv_recepcion_material r , tbl_inv_detalle_recepcion dr , tbl_com_proveedor prov, tbl_inv_inventario i, tbl_inv_articulo ar, tbl_inv_almacen al  /*  cargos pacientes  */ , ( select cod_familia,cod_clase,cod_articulo,sum(cantidad) as cantidad,sum(nvl(costo,0)) as costo from( select d.cod_familia, d.cod_clase, d.cod_articulo,sum(nvl(d.cantidad,0))  cantidad, sum(nvl(d.cantidad,0)*nvl(d.costo,0))  as costo from   tbl_inv_entrega_material e, tbl_inv_detalle_entrega d where (  e.compania = "+compania+" and  e.codigo_almacen = "+almacen+ appendFilter+" and e.pac_anio is not null  and e.pac_solicitud_no is not null)   and (d.compania = e.compania and d.no_entrega = e.no_entrega  and d.anio = e.anio) group by d.cod_familia, d.cod_clase, d.cod_articulo  union all select fdt.art_familia ,fdt.art_clase,  fdt.inv_articulo, sum(decode(fdt.tipo_transaccion,'D',-fdt.cantidad,fdt.cantidad)) as v_pac, sum(decode(fdt.tipo_transaccion,'D',-fdt.cantidad,fdt.cantidad)*nvl(fdt.costo_art,0)) as costo from tbl_fac_detalle_transaccion fdt where fdt.compania = "+compania+"  and fdt.inv_almacen =  "+almacen+ appendFilter3+"  and fdt.tipo= 'CDIR'  group by fdt.art_familia ,fdt.art_clase,  fdt.inv_articulo )group by cod_familia,cod_clase,cod_articulo ) cargo_pac /*  cargos de usos  de salas */ , (select de.cod_familia, de.cod_clase, de.cod_articulo, sum(nvl(de.cantidad,0))  cantidad, sum(nvl(de.cantidad,0)*nvl(de.precio,0))  costo  from tbl_inv_entrega_material e, tbl_inv_detalle_entrega de where ( e.compania = "+compania+" and de.compania = e.compania and de.no_entrega = e.no_entrega and de.anio = e.anio) and e.tipo_transferencia in ('A','U','C') " +appendFilter+" and   e.codigo_almacen    = "+almacen +" group by de.cod_familia, de.cod_clase, de.cod_articulo )  cargo_uso /* facturas proveedor*/  ,(select  d.cod_familia, d.cod_clase, d.cod_articulo,  sum(d.cantidad * nvl(d.articulo_und,1)) cantidad, sum(((d.cantidad * nvl(d.articulo_und,1))*d.precio)+d.art_itbm) valor   from   tbl_inv_recepcion_material r , tbl_inv_detalle_recepcion  d where ( r.compania = "+compania+" and  r.cod_proveedor = "+prov+" and r.codigo_almacen ="+almacen +" "+appendFilter1+" and r.fre_documento = 'FG') and (d.compania = r.compania and d.numero_documento = r.numero_documento and d.anio_recepcion = r.anio_recepcion) group by d.cod_familia, d.cod_clase, d.cod_articulo) fac_prov where ( r.compania = "+compania+"  and al.codigo_almacen = "+almacen+" "+appendFilter1+"  and  prov.cod_provedor = "+prov+" and  ar.consignacion_sino = 'S' ) and (dr.compania = r.compania and  dr.numero_documento = r.numero_documento and  dr.anio_recepcion = r.anio_recepcion) and (r.compania = prov.compania and  r.cod_proveedor = prov.cod_provedor) and (dr.compania = i.compania and  dr.cod_familia = i.art_familia and  dr.cod_clase = i.art_clase and  dr.cod_articulo = i.cod_articulo) and (i.compania = ar.compania and  i.art_familia = ar.cod_flia and  i.art_clase = ar.cod_clase and  i.cod_articulo = ar.cod_articulo";

/*if(!familyCode.trim().equals("")){sbSql.append(" and  ar.cod_flia =");sbSql.append(familyCode);}
if(!classCode.trim().equals("")){sbSql.append(" and  ar.cod_clase =");sbSql.append(classCode);}
if(!subclase.trim().equals("")){sbSql.append(" and  ar.cod_subclase =");sbSql.append(subclase);}*/
if(!familyCode.trim().equals("")){sql +=" and  ar.cod_flia ="+familyCode;}
if(!classCode.trim().equals("")){sql +=" and  ar.cod_clase ="+classCode;}
if(!subclase.trim().equals("")){sql +=" and  ar.cod_subclase ="+subclase;}

sql +=" ) and (i.compania = al.compania and  i.codigo_almacen = al.codigo_almacen)   /* join con tabla select cargo pac */ and (i.art_familia = cargo_pac.cod_familia(+) and  i.art_clase = cargo_pac.cod_clase(+) and  i.cod_articulo = cargo_pac.cod_articulo(+)) /* join con tabla select cargo uso  */ and (i.art_familia = cargo_uso.cod_familia(+) and  i.art_clase = cargo_uso.cod_clase(+) and  i.cod_articulo = cargo_uso.cod_articulo(+)) /* join con tabla select facturas proveedor */  and (i.art_familia = fac_prov.cod_familia(+) and  i.art_clase = fac_prov.cod_clase(+) and  i.cod_articulo = fac_prov.cod_articulo(+))    group by   ar.compania,al.codigo_almacen , al.descripcion , prov.cod_provedor, prov.nombre_proveedor, ar.cod_flia||'-'||ar.cod_clase||'-'||ar.cod_articulo, ar.cod_flia, ar.cod_clase, ar.cod_subclase,ar.cod_articulo, ar.descripcion, i.disponible, cargo_pac.cantidad  ,  cargo_pac.costo    , cargo_uso.cantidad  ,  cargo_uso.costo, fac_prov.cantidad   ,  fac_prov.valor         order by   al.codigo_almacen asc , al.descripcion asc, prov.cod_provedor asc, prov.nombre_proveedor asc, ar.cod_flia,ar.cod_clase,ar.cod_subclase,ar.cod_articulo asc";

al = SQLMgr.getDataList(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 50; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	int nItems = al.size() + 7;
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
		setDetail.addElement(".08");
		setDetail.addElement(".40");
		setDetail.addElement(".05");
		setDetail.addElement(".08");
		setDetail.addElement(".05");
		setDetail.addElement(".08");
		setDetail.addElement(".05");
		setDetail.addElement(".08");
		setDetail.addElement(".05");
		setDetail.addElement(".08");
	
	String groupBy = "",subGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 14.0f;
	int c_pac = 0, c_uso=0, c_fac=0, c_pen=0;
	double m_pac = 0.00, m_uso=0.00, m_fac=0.00, m_pen=0.00;
	String groupBy2 = "",groupBy3 = "";

	pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO","COMPARATIVO DE MOVIMIENTO DEL MATERIAL A CONSIGNACION POR PROVEEDOR   DEL "+tDate+" AL " +fDate, userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("      Código              Artículo   ",0,2);
		pc.addBorderCols("Ventas Paciente          Cant.   Total.",1,2);
		pc.addBorderCols("Ventas Usos              Cant.   Total.",1,2);
		pc.addBorderCols("Factura Prov.            Cant.   Total.",1,2);
		pc.addBorderCols("Pendiente                Cant.   Total.",1,2);
		//pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (i == 0)
		{
			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(8, 1,Color.blue);
			pc.createTable();
				pc.addCols(""+cdo.getColValue("desc_almacen")+"     "+cdo.getColValue("codigo_almacen"),2,setDetail.size(),cHeight);
			pc.addTable();
		
			pc.setFont(8, 1,Color.red);
			pc.createTable();
				pc.addCols(" "+cdo.getColValue("cod_prov"),0,1,cHeight);
				pc.addCols(" "+cdo.getColValue("desc_prov"),0,9,cHeight);
			pc.addTable();
			pc.addCopiedTable("detailHeader");
			lCounter+=4;
		}
		
		if(!groupBy.trim().equals(cdo.getColValue("cod_flia")))
		{
				if(i!=0){pc.createTable();pc.addBorderCols(" ",1,setDetail.size(),0.0f, 0.5f, 0.5f, 0.5f);pc.addTable();}
				pc.setFont(8, 1,Color.gray);
				pc.createTable();
				pc.addBorderCols(" FAMILIA: "+cdo.getColValue("cod_flia")+"   -   "+cdo.getColValue("descFamilia"),0,setDetail.size(),0.0f, 0.0f, 0.5f, 0.5f);
				pc.addTable();
				
		}
		if(!groupBy2.trim().equals(cdo.getColValue("cod_flia")+"-"+cdo.getColValue("cod_clase")))
		{
				pc.setFont(8, 1,Color.blue);
				pc.createTable();
				if(i==0)pc.addBorderCols(" CLASE: "+cdo.getColValue("cod_clase")+"   -   "+cdo.getColValue("descClase"),0,setDetail.size(),0.0f, 0.0f, 0.5f, 0.5f);
				else pc.addBorderCols(" CLASE: "+cdo.getColValue("cod_clase")+"   -   "+cdo.getColValue("descClase"),0,setDetail.size(),0.0f, 0.5f, 0.5f, 0.5f);
				pc.addTable();
				//pc.addCols(" ",1,dHeader.size());
		}
		if(!groupBy3.trim().equals(cdo.getColValue("cod_flia")+"-"+cdo.getColValue("cod_clase")+"-"+cdo.getColValue("cod_subclase")))
		{
				pc.setFont(8, 1,Color.blue);
				pc.createTable();
				if(i==0)pc.addBorderCols(" SUB CLASE: "+cdo.getColValue("cod_subclase")+"   -   "+cdo.getColValue("descSubClase"),0,setDetail.size(),0.5f, 0.0f, 0.5f, 0.5f);
				else pc.addBorderCols(" SUB CLASE: "+cdo.getColValue("cod_subclase")+"   -   "+cdo.getColValue("descSubClase"),0,setDetail.size(),0.5f, 0.5f, 0.5f, 0.5f);
				pc.addTable();
				//pc.addCols(" ",1,dHeader.size());
		}

		pc.setFont(7, 0);
		pc.createTable();
		pc.addBorderCols(""+cdo.getColValue("cod_articulo"),1,1,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols(""+cdo.getColValue("desc_articulo"),0,1,0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(""+cdo.getColValue("v_pac"),1,1,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("costopac")), 2,1,0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(""+cdo.getColValue("v_uso"),1,1,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("costouso")), 2,1,0.0f, 0.0f, 0.0f, 0.5f);
		pc.addBorderCols(""+cdo.getColValue("nfactura"),1,1,0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("costofac")), 2,1,0.0f, 0.0f, 0.0f, 0.5f);
		pc.addBorderCols(""+cdo.getColValue("pendiente"),1,1,0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("costopend")), 2,1,0.0f, 0.0f, 0.0f, 0.5f);
			groupBy=cdo.getColValue("cod_flia");
			groupBy2=cdo.getColValue("cod_flia")+"-"+cdo.getColValue("cod_clase");
			groupBy3=cdo.getColValue("cod_flia")+"-"+cdo.getColValue("cod_clase")+"-"+cdo.getColValue("cod_subclase");

		pc.addTable();
		lCounter++;
		
		c_pac +=  Integer.parseInt(cdo.getColValue("v_pac")); 
		m_pac +=  Double.parseDouble(cdo.getColValue("costopac"));
		c_uso +=  Integer.parseInt(cdo.getColValue("v_uso")); 
		m_uso +=  Double.parseDouble(cdo.getColValue("costouso"));
		c_fac +=  Integer.parseInt(cdo.getColValue("nFactura")); 
		m_fac +=  Double.parseDouble(cdo.getColValue("costofac"));
		c_pen +=  Integer.parseInt(cdo.getColValue("pendiente")); 
		m_pen +=  Double.parseDouble(cdo.getColValue("costopend"));
		
		if (lCounter >= maxLines && (((pCounter -1)* maxLines)+lCounter < nItems))
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO","COMPARATIVO DE MOVIMIENTO DEL MATERIAL A CONSIGNACION POR PROVEEDOR   DEL  "+tDate+" AL " +fDate, userName, fecha);

			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(8, 1,Color.blue);
			pc.createTable();
				pc.addCols(""+cdo.getColValue("desc_almacen")+"     "+cdo.getColValue("codigo_almacen"),2,setDetail.size(),cHeight);
			pc.addTable();
			
			pc.setFont(8, 1,Color.red);
			pc.createTable();
				pc.addCols(" "+cdo.getColValue("cod_prov"),0,1,cHeight);
				pc.addCols(" "+cdo.getColValue("desc_prov"),0,9,cHeight);
			pc.addTable();
			pc.addCopiedTable("detailHeader");
		}
	}//for i

	if (al.size() == 0)
	{
	pc.createTable();
		pc.addCols("No existen registros",1,setDetail.size());
	pc.addTable();
	}
    else 
	{
	
	pc.setFont(7, 0);
	pc.createTable();
		pc.addBorderCols("",0,2,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols("",0,2,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols("",0,2,0.0f, 0.0f, 0.5f, 0.5f);
		pc.addBorderCols("",0,2,0.0f, 0.0f, 0.0f, 0.5f);
		pc.addBorderCols("",0,2,0.0f, 0.0f, 0.0f, 0.5f);
	pc.addTable();
	
	pc.setFont(7, 0);
	pc.createTable();
		pc.addBorderCols("",0,2,0.0f, 0.5f, 0.5f, 0.0f);
		pc.addBorderCols("",0,2,0.0f, 0.5f, 0.5f, 0.0f);
		pc.addBorderCols("",0,2,0.0f, 0.5f, 0.5f, 0.5f);
		pc.addBorderCols("",0,2,0.0f, 0.5f, 0.0f, 0.5f);
		pc.addBorderCols("",0,2,0.0f, 0.5f, 0.0f, 0.5f);
	pc.addTable();
			
	pc.setFont(7, 0);
	pc.createTable();
		pc.addBorderCols("Cantidad Total ...........",2,2,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols(""+c_pac,2,2,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols(""+c_uso,2,2,0.0f, 0.0f, 0.5f, 0.5f);
		pc.addBorderCols(""+c_fac,2,2,0.0f, 0.0f, 0.0f, 0.5f);
		pc.addBorderCols(""+c_pen,2,2,0.0f, 0.0f, 0.0f, 0.5f);
	pc.addTable();
	
	pc.setFont(7, 0);
	pc.createTable();
		pc.addBorderCols("Monto Total ...........",2,2,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal("###,###,##0.00",m_pac),2,2,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal("###,###,##0.00",m_uso),2,2,0.0f, 0.0f, 0.5f, 0.5f);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal("###,###,##0.00",m_fac),2,2,0.0f, 0.0f, 0.0f, 0.5f);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal("###,###,##0.00",m_pen),2,2,0.0f, 0.0f, 0.0f, 0.5f);
	pc.addTable();
	
	pc.setFont(7, 0);
	pc.createTable();
		pc.addBorderCols("",0,2,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols("",0,2,0.0f, 0.0f, 0.5f, 0.0f);
		pc.addBorderCols("",0,2,0.0f, 0.0f, 0.5f, 0.5f);
		pc.addBorderCols("",0,2,0.0f, 0.0f, 0.0f, 0.5f);
		pc.addBorderCols("",0,2,0.0f, 0.0f, 0.0f, 0.5f);
	pc.addTable();
	
	pc.setFont(7, 0);
	pc.createTable();
		pc.addBorderCols("",0,10,0.0f, 0.5f, 0.0f, 0.0f);
	pc.addTable();
	
	}
	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>