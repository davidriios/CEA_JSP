<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet=SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String sql = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
ArrayList al = new ArrayList();
String appendFilter = request.getParameter("appendFilter");
String fechafin = request.getParameter("fechafin");
String fechaini = request.getParameter("fechaini");

String filterTr = "";
String titulo = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";

if(appendFilter == null) appendFilter ="";

		sql = "select   a.compania as companycode, a.cod_flia as familycode,a.cod_clase as classcode, a.cod_articulo as itemcode,a.descripcion as description,( select b.nombre from tbl_inv_familia_articulo b where b.compania = a.compania and b.cod_flia =a.cod_flia ) as familyname,( select c.descripcion from tbl_inv_clase_articulo c where c.compania = a.compania and c.cod_flia = a.cod_flia and c.cod_clase = a.cod_clase ) as classname,nvl (a.consignacion_sino, 'N') as isappropiation,nvl (a.venta_sino, 'N') as issaleitem, nvl (estado, ' ') as status, d.codigo_almacen, nvl (d.disponible, 0) as disponible,nvl (e.cantidad, 0) as entradas, nvl (f.cantidad, 0) as dev,nvl (g.cantidad, 0) as devpac, nvl (h.cantidad1, 0) as ajuste1, nvl (h.cantidad2, 0) as ajuste2, nvl (i.cantidad, 0) as entalmacen, nvl (j.cantidad1, 0) as entotros, nvl (k.cantidad, 0) as devdep, nvl (l.cantidad, 0) as devund, nvl (m.cantidad, 0) as transf, nvl (n.cantidad, 0) as devolpac, nvl (o.cantidad, 0) as devprov, nvl (j.cantidad2, 0) as devotros, (  nvl (f.cantidad, 0) + nvl (g.cantidad, 0)+ nvl (e.cantidad, 0)+ nvl (i.cantidad, 0)+ nvl (j.cantidad1, 0)) as inqty,(  nvl (j.cantidad2, 0)+ nvl (o.cantidad, 0)+ nvl (n.cantidad, 0)+ nvl (m.cantidad, 0)+ nvl (k.cantidad, 0)+ nvl (l.cantidad, 0)) as outqty,(nvl (h.cantidad1, 0) + nvl (h.cantidad2, 0)) as adjqty,(  nvl (f.cantidad, 0)+ nvl (g.cantidad, 0)+ nvl (e.cantidad, 0)+ nvl (i.cantidad, 0)+ nvl (j.cantidad1, 0)- (  nvl (j.cantidad2, 0)+ nvl (o.cantidad, 0)+ nvl (n.cantidad, 0)+ nvl (m.cantidad, 0)+ nvl (k.cantidad, 0)+ nvl (l.cantidad, 0))+ (nvl (h.cantidad1, 0) + nvl (h.cantidad2, 0))) as totalqty from tbl_inv_articulo a,tbl_inv_inventario d, (select   y.compania, y.codigo_almacen, z.cod_familia, z.cod_clase, z.cod_articulo,sum (nvl (z.cantidad, 0) * nvl (z.articulo_und, 0) ) as cantidad from tbl_inv_detalle_recepcion z, tbl_inv_recepcion_material y where z.compania = y.compania and z.anio_recepcion = y.anio_recepcion and z.numero_documento = y.numero_documento and y.estado = 'R' and to_date(to_char(y.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(y.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(y.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania, y.codigo_almacen,z.cod_familia,z.cod_clase,z.cod_articulo) e, (select   y.compania_dev compania, y.codigo_almacen, z.cod_familia, z.cod_clase, z.cod_articulo,sum (nvl (z.cantidad, 0)) as cantidad from tbl_inv_detalle_devolucion z,tbl_inv_devolucion y,tbl_sec_unidad_ejec u,tbl_sec_compania co where z.compania = y.compania and z.anio_devolucion = y.anio_devolucion and z.num_devolucion = y.num_devolucion and co.codigo = u.compania and u.codigo = y.unidad_administrativa and u.compania = y.compania and to_date(to_char(y.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(y.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(y.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania_dev,y.codigo_almacen,z.cod_familia,z.cod_clase,z.cod_articulo) f, (select   y.compania, y.codigo_almacen, z.cod_familia, z.cod_clase, z.cod_articulo, sum (nvl (z.cantidad, 0)) as cantidad from tbl_inv_detalle_paciente z, tbl_inv_devolucion_pac y where z.compania = y.compania and z.anio_devolucion = y.anio and z.num_devolucion = y.num_devolucion and y.estado = 'R' and to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania,y.codigo_almacen,z.cod_familia,z.cod_clase,z.cod_articulo) g, (select   y.compania, y.codigo_almacen, z.cod_familia, z.cod_clase, z.cod_articulo,sum (case   when y.codigo_ajuste = 4 and y.estado = 'A' then nvl (z.cantidad_ajuste, 0) else 0 end ) as cantidad1, sum (case     when y.codigo_ajuste != 4 and z.check_aprov = 'S'        then nvl (z.cantidad_ajuste, 0)     else 0  end ) as cantidad2 from tbl_inv_detalle_ajustes z, tbl_inv_ajustes y where z.compania = y.compania and z.codigo_ajuste = y.codigo_ajuste and z.numero_ajuste = y.numero_ajuste and z.anio_ajuste = y.anio_ajuste and to_date(to_char(y.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(y.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(y.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania,y.codigo_almacen,z.cod_familia,z.cod_clase,z.cod_articulo) h, (select   y.compania, x.codigo_almacen, y.cod_familia, y.cod_clase, y.cod_articulo, sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_entrega_material z, tbl_inv_detalle_entrega y,tbl_inv_solicitud_req x where x.tipo_transferencia = 'A' and (    z.compania = y.compania and z.no_entrega = y.no_entrega and z.anio = y.anio )and (    z.compania_sol = x.compania and z.req_solicitud_no = x.solicitud_no and z.req_tipo_solicitud = x.tipo_solicitud and z.req_anio = x.anio ) /*and z.codigo_almacen = x.codigo_almacen_ent*/  and to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania, x.codigo_almacen,y.cod_familia,y.cod_clase,y.cod_articulo) i, (select   y.compania, z.inv_almacen, z.inv_art_familia, z.inv_art_clase, z.inv_cod_articulo,sum (decode (y.tipo_transaccion,           'D', nvl (z.cantidad, 0), 0 )) as cantidad1,sum (decode (y.tipo_transaccion, 'C', nvl (z.cantidad, 0), 0 )) as cantidad2 from tbl_fac_detc_cliente z, tbl_fac_cargo_cliente y where z.compania = y.compania and z.anio = y.anio and z.tipo_transaccion = y.tipo_transaccion and z.cargo = y.codigo and z.inv_art_familia is not null and z.inv_art_clase is not null and z.inv_cod_articulo is not null and z.inv_almacen is not null   and to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(y.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')) group by y.compania, z.inv_almacen,z.inv_art_familia,z.inv_art_clase,z.inv_cod_articulo) j /*dev otros*/,(select   z.compania, z.codigo_almacen_q_dev, y.cod_familia, y.cod_clase, y.cod_articulo,sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_devolucion z, tbl_inv_detalle_devolucion y where z.compania = y.compania and z.num_devolucion = y.num_devolucion and z.anio_devolucion = y.anio_devolucion  and to_date(to_char(z.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) group by z.compania,z.codigo_almacen_q_dev,y.cod_familia,y.cod_clase,y.cod_articulo) k /*salida por devolucion de mat. de deposito*/,(select   z.compania, z.codigo_almacen, y.cod_familia, y.cod_clase,y.cod_articulo, sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_entrega_material z, tbl_inv_detalle_entrega y, tbl_inv_solicitud_req x where x.tipo_transferencia in ('U', 'C') and (    z.compania = y.compania and z.no_entrega = y.no_entrega and z.anio = y.anio ) and (    z.compania_sol = x.compania and z.req_solicitud_no = x.solicitud_no and z.req_tipo_solicitud = x.tipo_solicitud and z.req_anio = x.anio ) and to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) group by z.compania,z.codigo_almacen,y.cod_familia,y.cod_clase, y.cod_articulo) l /* unidades administrativas y cia*/, (select   z.compania, x.codigo_almacen_ent, y.cod_familia,y.cod_clase, y.cod_articulo,sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_entrega_material z, tbl_inv_detalle_entrega y,tbl_inv_solicitud_req x where (    z.compania = y.compania and z.no_entrega = y.no_entrega and z.anio = y.anio ) and (    z.compania_sol = x.compania and z.req_solicitud_no = x.solicitud_no  and z.req_tipo_solicitud = x.tipo_solicitud and z.req_anio = x.anio )  and to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) group by z.compania,x.codigo_almacen_ent,y.cod_familia, y.cod_clase,y.cod_articulo) m /* transferencia entre almacenes*/, (select   z.compania, z.codigo_almacen, y.cod_familia, y.cod_clase,y.cod_articulo, sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_entrega_material z,tbl_inv_detalle_entrega y,tbl_inv_solicitud_pac x where (    z.compania = y.compania and z.no_entrega = y.no_entrega and z.anio = y.anio ) and (    z.compania = x.compania and z.pac_solicitud_no = x.solicitud_no and z.pac_anio = x.anio ) and to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(z.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) group by z.compania,z.codigo_almacen,y.cod_familia,y.cod_clase, y.cod_articulo) n /*entrega a paciente */, (select   z.compania, z.codigo_almacen, y.cod_familia, y.cod_clase, y.cod_articulo, sum (nvl (y.cantidad, 0)) as cantidad from tbl_inv_devolucion_prov z, tbl_inv_detalle_proveedor y where z.anulado_sino = 'N' and (    y.compania = z.compania  and y.num_devolucion = z.num_devolucion and y.anio = z.anio ) group by z.compania, z.codigo_almacen,y.cod_familia,y.cod_clase,y.cod_articulo) o  /* dev a proveedor*/ where d.cod_articulo = a.cod_articulo and d.compania = a.compania and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and d.compania = e.compania(+) and d.codigo_almacen = e.codigo_almacen(+) and d.cod_articulo = e.cod_articulo(+) and d.compania = f.compania(+) and d.codigo_almacen = f.codigo_almacen(+) and d.cod_articulo = f.cod_articulo(+) and d.compania = g.compania(+) and d.codigo_almacen = g.codigo_almacen(+) and d.cod_articulo = g.cod_articulo(+) and d.compania = h.compania(+) and d.codigo_almacen = h.codigo_almacen(+) and d.cod_articulo = h.cod_articulo(+) and d.compania = i.compania(+) and d.codigo_almacen = i.codigo_almacen(+) and d.cod_articulo = i.cod_articulo(+) and d.compania = j.compania(+) and d.codigo_almacen = j.inv_almacen(+) and d.cod_articulo = j.inv_cod_articulo(+) and d.compania = k.compania(+) and d.codigo_almacen = k.codigo_almacen_q_dev(+) and d.cod_articulo = k.cod_articulo(+) and d.compania = l.compania(+) and d.codigo_almacen = l.codigo_almacen(+) and d.cod_articulo = l.cod_articulo(+) and d.compania = m.compania(+) and d.codigo_almacen = m.codigo_almacen_ent(+) and d.cod_articulo = m.cod_articulo(+) and d.compania = n.compania(+) and d.codigo_almacen = n.codigo_almacen(+) and d.cod_articulo = n.cod_articulo(+) and d.compania = o.compania(+) and d.codigo_almacen = o.codigo_almacen(+) and d.cod_articulo = o.cod_articulo(+) order by d.art_familia, d.art_clase, d.cod_articulo  ";


al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 55; //max lines of items
	int nItems = al.size(); //number of items
	int extraItems = nItems % maxLines;
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	//calculating number of page
	if (extraItems == 0) nPages = (nItems / maxLines);
	else nPages = (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = false;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_list_hist_mov";
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
		setDetail.addElement(".05");
		setDetail.addElement(".05");
		setDetail.addElement(".05");
		setDetail.addElement(".40");
		setDetail.addElement(".09");
		setDetail.addElement(".09");
		setDetail.addElement(".09");
		setDetail.addElement(".09");
		setDetail.addElement(".09");

	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;

	pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO", "HISTORIA DE MOVIMIENTO DE ARTICULOS", userName, fecha);

	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
	pc.setFont(7, 1);
			pc.addBorderCols("Familia",1);
			pc.addBorderCols("Clase",1);
			pc.addBorderCols("Codigo",1);
			pc.addBorderCols("Descripcion",1);
			pc.addBorderCols("Disponible",1);
			pc.addBorderCols("Entradas",1);
			pc.addBorderCols("Salidas",1);
			pc.addBorderCols("Ajustes",1);
			pc.addBorderCols("Total",1);
	pc.addTable();
	pc.copyTable("detailHeader");

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		pc.createTable();
		pc.setFont(7, 0);
			pc.addCols(" "+cdo1.getColValue("familyCode"),1,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("classCode"),1,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("itemCode"),0,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("description"),0,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("disponible"),1,1,cHeight);
			pc.addCols(" "+Integer.parseInt(cdo1.getColValue("inQty")),1,1,cHeight);
			pc.addCols(" "+Integer.parseInt(cdo1.getColValue("outQty")) * -1,1,1,cHeight);
			pc.addCols(" "+Integer.parseInt(cdo1.getColValue("adjQty")),1,1,cHeight);
			pc.addCols(" "+cdo1.getColValue("totalQty"),1,1,cHeight);
		pc.addTable();
		lCounter++;


		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			pdfHeader(pc, _comp, pCounter, nPages, "INVENTARIO", "HISTORIA DE MOVIMIENTO DE ARTICULOS", userName, fecha);
			pc.setNoColumnFixWidth(setDetail);
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
		pc.createTable();
			pc.addCols(al.size()+" Registros en total",0,setDetail.size());
		pc.addTable();
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>