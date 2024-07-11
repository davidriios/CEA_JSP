<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
		REPORTE:		INV00132.RDF
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
StringBuffer sbSql = new StringBuffer();
String appendFilter =  "",appendFilter1 = "";
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

if(prov.trim().equals("") || almacen.trim().equals("") )  throw new Exception("SELECCIONE PARAMETROS PARA EL REPORTE (ALMACEN Y PROVEEDOR)");
if (appendFilter == null) appendFilter = "";

if(!tDate.trim().equals(""))
{
appendFilter  = " and to_date(to_char(a.fecha_sistema,'dd/mm/yyyy'),'dd/mm/yyyy')   >= to_date('"+tDate+"','dd/mm/yyyy') ";
appendFilter1 = " and to_date(to_char(em.fecha_creacion,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+tDate+"','dd/mm/yyyy') ";
}
if(!fDate.trim().equals(""))
{
appendFilter  += " and to_date(to_char(a.fecha_sistema,'dd/mm/yyyy'),'dd/mm/yyyy')   <=  to_date('"+fDate+"','dd/mm/yyyy')";
appendFilter1 += " and to_date(to_char(em.fecha_creacion,'dd/mm/yyyy'),'dd/mm/yyyy') <=  to_date('"+fDate+"','dd/mm/yyyy')";
}


sbSql.append(" select  a.compania,al.codigo_almacen , al.descripcion desc_almacen , prov.cod_provedor cod_prov  , prov.nombre_proveedor desc_prov , ar.cod_flia||'-'||ar.cod_clase||'-'||ar.cod_articulo cod_articulo, ar.cod_flia, ar.cod_clase, ar.cod_articulo   cod_art, ar.descripcion desc_articulo, i.disponible inventario, nvl(xx.v_uso,0) v_uso, nvl(xx.v_pac,0) v_pac, nvl(yy.nentrega,0) nEntrega, nvl(yy.nfactura,0) nFactura, nvl(aj.v_ajuste,0) v_ajuste, nvl(yy.nentrega,0) - (nvl(yy.nfactura,0)+ nvl(aj.v_ajuste,0)) pendiente,ar.cod_subclase,(select nombre from tbl_inv_familia_articulo where compania = ar.compania and cod_flia=ar.cod_flia)descFamilia, (select descripcion from tbl_inv_clase_articulo where compania = a.compania and cod_flia =ar.cod_flia and cod_clase=ar.cod_clase)descClase,(select descripcion from tbl_inv_subclase where compania = a.compania and cod_flia =ar.cod_flia and cod_clase=ar.cod_clase and subclase_id=ar.cod_subclase) descSubClase  from tbl_inv_recepcion_material a, tbl_inv_detalle_recepcion de, tbl_com_proveedor prov, tbl_inv_inventario i, tbl_inv_articulo ar, tbl_inv_almacen al ,");

/* RECEPCIONES POR NOTAS DE ENTREGAS  Y FACTURAS DE PROVEEDORES */
sbSql.append(" ( select sum (case   when  a.fre_documento = 'NE'  then (nvl (dr.cantidad,0)* nvl(dr.articulo_und,1)) else 0 end ) as nentrega ,sum (case   when a.fre_documento = 'FG'  then (nvl (dr.cantidad,0)*nvl(dr.articulo_und,1)) else 0 end ) as nfactura ,dr.cod_familia,  dr.cod_clase, dr.cod_articulo  from   tbl_inv_recepcion_material a, tbl_inv_detalle_recepcion dr where a.compania =");
sbSql.append(compania);
sbSql.append(appendFilter.toString());
sbSql.append("  and a.cod_proveedor = ");
sbSql.append(prov);
sbSql.append(" and a.codigo_almacen = ");
sbSql.append(almacen);
sbSql.append(" and a.fre_documento in ( 'NE','FG') and (dr.compania = a.compania and dr.numero_documento = a.numero_documento and dr.anio_recepcion = a.anio_recepcion) group by dr.cod_familia,  dr.cod_clase, dr.cod_articulo )yy  ");
/* ENTREGAS DE MATERIAL A PACIENTES */
sbSql.append(" ,( select sum(case when em.req_anio is not null and em.req_solicitud_no is not null and em.req_tipo_solicitud is not null then nvl (de.cantidad,0) else 0 end ) as v_uso, sum(case when em.pac_anio is not null and em.pac_solicitud_no is not null then nvl (de.cantidad,0)  else 0 end ) as v_pac,de.cod_familia ,de.cod_clase,  de.cod_articulo from tbl_inv_entrega_material em , tbl_inv_detalle_entrega de where ( em.compania = ");
sbSql.append(compania);
sbSql.append( "  and em.codigo_almacen = ");
sbSql.append(almacen);
sbSql.append(appendFilter1.toString());
sbSql.append(" and de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio ) group by de.cod_familia,de.cod_clase,  de.cod_articulo ) xx ");
/* AJUSTES A CONSIGNACION */
sbSql.append(" ,( select sum(da.cantidad_ajuste)  v_ajuste,da.cod_familia,da.cod_clase,da.cod_articulo from tbl_inv_ajustes a, tbl_inv_detalle_ajustes da where (a.compania = ");
sbSql.append(compania);
sbSql.append( " and a.codigo_almacen = ");
sbSql.append(almacen);
sbSql.append(" and a.cod_proveedor =  ");
sbSql.append(prov);
sbSql.append(appendFilter.toString());
sbSql.append(" /*and a.codigo_ajuste = 5*/) and (da.compania = a.compania and da.codigo_ajuste = a.codigo_ajuste and da.numero_ajuste = a.numero_ajuste and da.anio_ajuste = a.anio_ajuste) group by da.cod_familia,da.cod_clase,da.cod_articulo, a.codigo_almacen )aj ");
  
sbSql.append(" where ( a.compania = ");
sbSql.append(compania);
sbSql.append(appendFilter.toString());
sbSql.append("  and  al.codigo_almacen = ");
sbSql.append(almacen);
sbSql.append(" and  prov.cod_provedor = ");
sbSql.append(prov);
sbSql.append(" and  ar.consignacion_sino = 'S' )");
if(!familyCode.trim().equals("")){sbSql.append(" and  ar.cod_flia =");sbSql.append(familyCode);}
if(!classCode.trim().equals("")){sbSql.append(" and  ar.cod_clase =");sbSql.append(classCode);}
if(!subclase.trim().equals("")){sbSql.append(" and  ar.cod_subclase =");sbSql.append(subclase);}

sbSql.append(" and (de.compania = a.compania and  de.numero_documento = a.numero_documento and  de.anio_recepcion = a.anio_recepcion) and (a.compania = prov.compania and  a.cod_proveedor = prov.cod_provedor) and (de.compania = i.compania and  de.cod_articulo = i.cod_articulo) and (i.compania = ar.compania and i.cod_articulo = ar.cod_articulo) and (i.compania = al.compania and  i.codigo_almacen = al.codigo_almacen) and  de.cod_articulo = yy.cod_articulo(+) and de.cod_articulo = xx.cod_articulo(+) and  de.cod_articulo = aj.cod_articulo(+)   group by a.compania,ar.compania,ar.cod_subclase,al.codigo_almacen, al.descripcion, prov.cod_provedor, prov.nombre_proveedor, ar.cod_flia||'-'||ar.cod_clase||'-'||ar.cod_articulo, ar.cod_flia, ar.cod_clase, ar.cod_articulo, ar.descripcion, i.disponible, nvl(xx.v_uso,0) , nvl(xx.v_pac,0), nvl(yy.nentrega,0), nvl(yy.nfactura,0), nvl(aj.v_ajuste,0) order by al.codigo_almacen asc, al.descripcion asc, prov.cod_provedor asc, prov.nombre_proveedor asc, ar.cod_flia,ar.cod_clase,ar.cod_subclase,ar.cod_articulo asc"); 


al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = cDateTime;
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;

	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "INVENTARIO";
	String subtitle = "COMPARATIVO DE MOVIMIENTO DEL MATERIAL A CONSIGNACION POR PROVEEDOR";
	String xtraSubtitle = "DEL  "+tDate+"   AL   "+fDate;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".30");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(8, 1);
			pc.addBorderCols("CODIGO",1);
			pc.addBorderCols("DESC. ARTICULO",0);
			pc.addBorderCols("N/E",1);
			pc.addBorderCols("V PAC.",1);
			pc.addBorderCols("V USO",1);
			pc.addBorderCols("INV.",1);
			pc.addBorderCols("AJUSTE",1);
			pc.addBorderCols("FACT.",1);
			pc.addBorderCols("PEND.",1);
			pc.setTableHeader(3);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "",groupBy2 = "",groupBy3 = "";
	double total = 0.00, totalCja = 0.00,totalSob=0.00;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (i == 0)
		{
				pc.setFont(8, 1,Color.blue);
				pc.addCols(""+cdo.getColValue("desc_almacen")+"     "+cdo.getColValue("codigo_almacen"),0,dHeader.size());
				pc.setFont(8, 1,Color.red);
				pc.addCols(" "+cdo.getColValue("cod_prov"),0,1);
				pc.addCols(" "+cdo.getColValue("desc_prov"),0,8);
		}
		
		if(!groupBy.trim().equals(cdo.getColValue("cod_flia")))
		{
				if(i!=0)pc.addCols(" ",1,dHeader.size());
				pc.setFont(8, 1,Color.gray);
				pc.addCols(" FAMILIA: "+cdo.getColValue("cod_flia")+"   -   "+cdo.getColValue("descFamilia"),0,dHeader.size());
				
		}
		if(!groupBy2.trim().equals(cdo.getColValue("cod_flia")+"-"+cdo.getColValue("cod_clase")))
		{
				pc.setFont(8, 1,Color.blue);
				pc.addCols(" CLASE: "+cdo.getColValue("cod_clase")+"   -   "+cdo.getColValue("descClase"),0,dHeader.size());
				//pc.addCols(" ",1,dHeader.size());
		}
		if(!groupBy3.trim().equals(cdo.getColValue("cod_flia")+"-"+cdo.getColValue("cod_clase")+"-"+cdo.getColValue("cod_subclase")))
		{
				pc.setFont(8, 1,Color.blue);
				pc.addCols(" SUB CLASE: "+cdo.getColValue("cod_subclase")+"   -   "+cdo.getColValue("descSubClase"),0,dHeader.size());
				
				//pc.addCols(" ",1,dHeader.size());
		}
		
			
			pc.setFont(7, 0);
			pc.addCols(""+cdo.getColValue("cod_articulo"),1,1);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1);
			pc.addCols(""+cdo.getColValue("nEntrega"),1,1);
			pc.addCols(""+cdo.getColValue("v_pac"),1,1);
			pc.addCols(""+cdo.getColValue("v_uso"),1,1);
			pc.addCols(""+cdo.getColValue("inventario"),1,1);
			pc.addCols(""+cdo.getColValue("v_ajuste"),1,1);
			pc.addCols(""+cdo.getColValue("nFactura"),1,1);
			if( Double.parseDouble(cdo.getColValue("pendiente")) >0)
			pc.setFont(7, 1,Color.blue);
			else if( Double.parseDouble(cdo.getColValue("pendiente")) <= 0) pc.setFont(7, 0,Color.gray);	
			pc.addCols(""+cdo.getColValue("pendiente"),1,1);					

			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
			
			groupBy=cdo.getColValue("cod_flia");
			groupBy2=cdo.getColValue("cod_flia")+"-"+cdo.getColValue("cod_clase");
			groupBy3=cdo.getColValue("cod_flia")+"-"+cdo.getColValue("cod_clase")+"-"+cdo.getColValue("cod_subclase");
			
			

	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
