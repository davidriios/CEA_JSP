<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
Reporte
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
ArrayList al2 = new ArrayList();
ArrayList codMed = new ArrayList();
CommonDataObject cdoPac  = new CommonDataObject();
String userName = UserDet.getUserName();
String change = request.getParameter("change");
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbSubFilter = new StringBuffer();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String fecha = request.getParameter("fecha");
String fechaHasta = request.getParameter("fechaHasta");
String pacBarcode = request.getParameter("pacBarcode");
String paciente = request.getParameter("paciente");
String compania = (String) session.getAttribute("_companyId");
String estado = request.getParameter("estado");
String cds = request.getParameter("cds");
String orden = request.getParameter("orden");
String timer = request.getParameter("timer");
String setFecha =request.getParameter("setFecha");
boolean cdsExpanded = (request.getParameter("cdsExpanded") != null && (request.getParameter("cdsExpanded").equalsIgnoreCase("S") || request.getParameter("cdsExpanded").equalsIgnoreCase("Y")));
if (paciente == null) paciente = "";
if (pacBarcode == null) pacBarcode = "";
if (fechaHasta == null) fechaHasta = "";
if (cds == null) cds = "";
if (estado == null) estado = "";
if (orden == null) orden = "D";
if (timer == null) timer = "";
if (setFecha ==null)setFecha="";
if (mode == null) mode = "add";
String expVersion = "1"; 
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if (fg.trim().equals("ME") || fg.trim().equals("BM")) {//SOLICITUDES DE FARMACIA 

		sbSubFilter.append(" ( (p.cds_recibido = 'N' and p.estado_orden = 'A' and p.omitir_orden = 'N'");
		if (!fecha.trim().equals("")) { sbSubFilter.append(" and trunc(p.fecha_inicio) >= to_date('"); sbSubFilter.append(fecha); sbSubFilter.append("','dd/mm/yyyy')"); }
		if (!fechaHasta.trim().equals("")) { sbSubFilter.append(" and trunc(p.fecha_inicio) <= to_date('"); sbSubFilter.append(fechaHasta); sbSubFilter.append("','dd/mm/yyyy')"); }
		sbSubFilter.append(") or (p.cds_omit_recibido = 'N' and p.estado_orden = 'S' and p.omitir_orden = 'N'");
		if (!fecha.trim().equals("")) { sbSubFilter.append("  and trunc(p.fecha_suspencion) >= to_date('"); sbSubFilter.append(fecha); sbSubFilter.append("','dd/mm/yyyy')"); }
		if (!fechaHasta.trim().equals("")) { sbSubFilter.append(" and trunc(p.fecha_suspencion) <= to_date('"); sbSubFilter.append(fechaHasta); sbSubFilter.append("','dd/mm/yyyy')"); }		
		sbSubFilter.append(") ) and p.tipo_orden in (2,13,14)");

		sbFilter.append(" and a.omitir_orden = 'N' and a.tipo_orden in (2,13,14)");
		if (!fecha.trim().equals("")) { sbFilter.append(" and ( (trunc(a.fecha_inicio) >= to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')"); }
		if (!fechaHasta.trim().equals("")) { sbFilter.append(" and trunc(a.fecha_inicio) <= to_date('"); sbFilter.append(fechaHasta); sbFilter.append("','dd/mm/yyyy')"); }
		if (!fecha.trim().equals("")) { sbFilter.append(") or (a.estado_orden = 'S' and trunc(a.fecha_suspencion) >= to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')"); }
		if (!fechaHasta.trim().equals("")) { sbFilter.append(" and trunc(a.fecha_suspencion) <= to_date('"); sbFilter.append(fechaHasta); sbFilter.append("','dd/mm/yyyy')"); }
		if (!fecha.trim().equals("") || (!fechaHasta.trim().equals("") && !fecha.trim().equals(""))) sbFilter.append(") )");
	}

	if (!pacBarcode.trim().equals("")) { sbFilter.append(" and a.pac_id = "); sbFilter.append(pacBarcode.substring(0,10)); sbFilter.append(" and a.secuencia = "); sbFilter.append(pacBarcode.substring(10)); }
	if (!estado.trim().equals("") && estado.trim().equals("PP")) sbFilter.append(" and not exists (select 1 from tbl_int_orden_farmacia far where far.pac_id = a.pac_id and far.admision = a.secuencia and far.tipo_orden = a.tipo_orden and far.orden_med = a.orden_med and far.codigo = a.codigo)");
	else if (!estado.trim().equals("") && !estado.trim().equals("PP") && !estado.trim().equals("R")) { sbFilter.append(" and f.estado = '"); sbFilter.append(estado); sbFilter.append("'"); }
	else if (!estado.trim().equals("")&&estado.trim().equals("R")) sbFilter.append(" and a.cds_recibido = 'S'");
	if (!cds.trim().equals("")) { sbFilter.append(" and a.centro_servicio = "); sbFilter.append(cds); }
	if (!paciente.trim().equals("")) { sbFilter.append(" and upper(b.nombre_paciente) like '%"); sbFilter.append(paciente.toUpperCase()); sbFilter.append("%'"); }
	if (fg.trim().equals("BM")) sbFilter.append(" and a.id_articulo is not null and exists (select null from tbl_inv_articulo_bm where cod_articulo = a.id_articulo and compania = z.compania and estado = 'A')");
	//if (!fg.trim().equals("BM")) { sbFilter.append(" and z.compania <> "); sbFilter.append(compania); }

	sbSql.append("select (select descripcion from tbl_cds_centro_servicio where codigo = x.centro_servicio) as cds_desc, x.* from (");
		sbSql.append("select nvl((select count(*) as pendiente from tbl_sal_detalle_orden_med p where ");
		sbSql.append(sbSubFilter);
		sbSql.append("),0) as pendiente, a.pac_id||' - '||a.secuencia cuenta, a.cds_omit_recibido, (select v.descripcion from tbl_sal_via_admin v where  v.codigo = a.via) as descVia, a.frecuencia, a.dosis, a.observacion, decode(a.tipo_tubo,'G','GOTEO','N','BOLO') as tipo_tubo, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss AM') as fecha_inicio, decode(a.estado_orden,'S',to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi:ss AM'),'F',to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss AM')) as fecha_omitida, decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento||'-'||b.d_cedula,b.pasaporte) as identificacion, b.nombre_paciente, (to_number(to_char(sysdate,'YYYY')) - to_number(to_char(b.fecha_nacimiento,'YYYY'))) as edad, a.secuencia as dsp_admision, (select nombre_corto from tbl_sal_desc_estado_ord where estado=a.estado_orden) as dsp_estado, to_char(a.fecha_creacion,'hh12:mi:ss AM') as hora_solicitud, nvl(a.cds_recibido,'N') as cds_recibido, a.secuencia as secuenciaCorte, a.tipo_orden, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, a.nombre, a.ejecutado, a.cod_tratamiento, a.codigo, a.orden_med noOrden, a.pac_id, a.estado_orden, to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am') as fecha_fin, to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') as fechaSuspencion, nvl(a.cod_salida,0) as cod_salida, nvl((select cama from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia),' ') as cama, to_char(b.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, to_char(z.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, b.sexo, nvl(f.estado,'N') as despachado, a.codigo_orden_med, getaseguradora2(z.secuencia,z.pac_id,z.aseguradora) as empresa, decode(a.tipo_orden,2,'ME','NU') as tipoOrd, a.id_articulo, (select count(*) from tbl_inv_articulo_bm where cod_articulo = id_articulo and compania = z.compania and estado = 'A') as esBm, nvl(fn_far_orden_pend(a.codigo_orden_med,a.pac_id ,a.secuencia,'");
		sbSql.append(fg);
		sbSql.append("'),0) as ord_pen, get_admCorte(a.pac_id,z.adm_root) as admCorte, z.adm_root as admRoot, a.fecha_creacion, z.categoria as categoria_adm, nvl(a.dosis_desc,' ') as dosis_desc, f.codigo_articulo, f.descripcion, f.cantidad, a.cantidad as cant, a.centro_servicio, f.usuario_modificacion as usuario, nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'SAL_ADD_CANTIDAD_OMMEDICAMENTO'),'N') as addCantidad,decode(a.stat,'Y','[STAT]',' ') as stat");
		sbSql.append(" from vw_adm_paciente b, tbl_sal_detalle_orden_med a, tbl_adm_admision z, tbl_int_orden_farmacia f");
		sbSql.append(" where z.pac_id = a.pac_id and z.secuencia = a.secuencia and a.pac_id = b.pac_id ");
		sbSql.append(sbFilter);
		sbSql.append(" and a.pac_id = f.pac_id(+) and a.secuencia = f.admision(+) and a.tipo_orden = f.tipo_orden(+) and a.orden_med = f.orden_med(+) and a.codigo = f.codigo(+) and f.other1 = 1");
		if(fg.equals("BM")) sbSql.append(" AND f.estado IN ('P', 'A') and f.fg = 'BM' AND a.id_articulo IS NOT NULL");
		else sbSql.append(" AND f.estado IN ('P') and f.fg = 'ME'");
	sbSql.append(") x where exists (select null from tbl_adm_admision where pac_id = x.pac_id and secuencia = admCorte"); 
	sbSql.append(" and estado in ('A','E')");
	sbSql.append(") order by 1, x.centro_servicio, x.fecha_creacion");
	if(orden.trim().equals("D")) sbSql.append(" desc");
	sbSql.append(", x.pac_id, x.codigo_orden_med");
	System.out.println("---------> List SQL...");
	al = SQLMgr.getDataList(sbSql.toString());

if (fecha.trim().equals(""))fecha=CmnMgr.getCurrentDate("dd/mm/yyyy");
if (request.getMethod().equalsIgnoreCase("GET"))
{
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ORDENENES MEDICAS DE FARMACIA";
	String subtitle = "";
	String xtraSubtitle = "";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector dHeader = new Vector();
		dHeader.addElement(".09");
		dHeader.addElement(".11");
		dHeader.addElement(".10");
		dHeader.addElement(".03");
		dHeader.addElement(".08");
		dHeader.addElement(".13");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".14");
		dHeader.addElement(".14");
CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPac.addColValue("is_landscape",""+isLandscape);
    }

		footer.setNoColumn(3);
		footer.createTable("footer",false,0,0.0f,width);
		footer.setVAlignment(2);
		footer.setFont(7, 1);
		footer.addBorderCols(" ",1,1,0.0f,0.5f,0.0f,0.0f);

		
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, permission, passRequired, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		if(!fg.trim().equals("PAC"))pdfHeader(pc, _comp,xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		else pdfHeader(pc, _comp,cdoPac,xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("ESTADO",1,1);
		pc.addBorderCols("HORA SOL.",1,2);
		pc.addBorderCols("DESCRIPCION",1,5);		
		pc.addBorderCols("FECHA INI.",1,1);
		pc.addBorderCols("FECHA DESAP.",1,1);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);
	String groupBy="";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
 		if(!fg.trim().equals("PAC")){
			if(!groupBy.trim().equals(cdo.getColValue("pac_id")))
			{
				pc.setFont(7, 1);
				pc.addCols("PACIENTE: "+cdo.getColValue("nombre_paciente")+" - "+cdo.getColValue("cuenta"),0,dHeader.size());
			}
		}
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("dsp_estado"),1,1);
		pc.addCols(cdo.getColValue("hora_solicitud"),1,2);
		pc.addCols(cdo.getColValue("nombre")+" Cant.="+cdo.getColValue("cantidad")+" - "+cdo.getColValue("codigo_articulo")+" "+cdo.getColValue("descripcion")+" "+cdo.getColValue("stat"),0,5);
		pc.addCols(cdo.getColValue("fecha_inicio"),1,1);
		pc.addCols(cdo.getColValue("fecha_despacho"),1,1);
		pc.setFont(7, 1);
		pc.addBorderCols("Presentación:",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("descVia"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 1);
		pc.addBorderCols("Concentración:",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("dosis"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 1);
		pc.addBorderCols("Frecuencia:",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("frecuencia"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 1);
		pc.addBorderCols("Observación:",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("observacion")+" Usuario Desap.:"+cdo.getColValue("usuario"),0,3,0.5f,0.0f,0.0f,0.0f);
		pc.setFont(7, 0);
		
		if(cdo.getColValue("addCantidad").equals("S") ){pc.setFont(9,0,Color.red);pc.addBorderCols("Cantidad Solicitada:"+cdo.getColValue("cant"),0,dHeader.size(),0.0f,0.0f,0.0f,0.0f);}
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("pac_id");
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {


	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>