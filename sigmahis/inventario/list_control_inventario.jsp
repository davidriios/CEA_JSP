<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alWh = new ArrayList();
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbReqFilter = new StringBuffer();
String wh = request.getParameter("wh");
String familia = request.getParameter("familia");
String codClase = request.getParameter("codClase");
String descArticulo = request.getParameter("descArticulo");
String articulo = request.getParameter("articulo");
String estado = request.getParameter("estado");
String solicitud = request.getParameter("solicitud");
String stockValue = "0", pendingReq = "0";

sbSql.append("select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" order by codigo_almacen");
alWh = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);

sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'INV_CTRL_REQ_FROM_DATE'),'-') as req_fdate from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());

if (wh == null ) wh = "";
if (familia == null ) familia = "";
if (codClase == null ) codClase = "";
if (descArticulo == null ) descArticulo = "";
if (articulo == null ) articulo = "";
if (estado == null ) estado = "";
if (solicitud == null ) solicitud = "N";
if (!articulo.trim().equals("")) { sbFilter.append(" and z.cod_articulo = "); sbFilter.append(articulo); }
if (!familia.trim().equals("") || !estado.trim().equals("") || !descArticulo.trim().equals("") || !codClase.trim().equals("")) {
	sbFilter.append(" and exists (select null from tbl_inv_articulo where compania = z.compania and cod_articulo = z.cod_articulo");
	if (!familia.trim().equals("")) { sbFilter.append(" and cod_flia = "); sbFilter.append(familia); }
	if (!codClase.trim().equals("")) { sbFilter.append(" and cod_clase = "); sbFilter.append(codClase); }
	if (!descArticulo.trim().equals("")) { sbFilter.append(" and descripcion like '%"); sbFilter.append(descArticulo); sbFilter.append("%'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and estado = '"); sbFilter.append(estado); sbFilter.append("'"); }
	sbFilter.append(")");
}
if (!solicitud.equalsIgnoreCase("N")) {
	sbReqFilter.append(" and ( exists ( ");
		//OC aprobadas sin recepciones de item especifico
		sbReqFilter.append("select null from tbl_com_comp_formales a where compania = z.compania and cod_almacen = z.codigo_almacen and status = 'A' and exists (");
			sbReqFilter.append("select null from tbl_com_detalle_compromiso bb where compania = a.compania and cf_anio = a.anio and cf_tipo_com = a.tipo_compromiso and cf_num_doc = a.num_doc and cod_articulo = z.cod_articulo");
			//sin recepciones
			sbReqFilter.append(" and not exists (select null from tbl_inv_recepcion_material aa where compania = bb.compania and cf_anio = bb.cf_anio and cf_tipo_com = bb.cf_tipo_com and cf_num_doc = bb.cf_num_doc and estado = 'R' and exists (select null from tbl_inv_detalle_recepcion where compania = aa.compania and anio_recepcion = aa.anio_recepcion and numero_documento = aa.numero_documento and cod_articulo = bb.cod_articulo))");
		sbReqFilter.append(")");
		if (!p.getColValue("req_fdate").equals("-")) {
			sbReqFilter.append(" and fecha_documento >= to_date('");
			sbReqFilter.append(p.getColValue("req_fdate"));
			sbReqFilter.append("','dd/mm/yyyy')");
		}
	sbReqFilter.append(" ) or exists ( ");
		//Requisiciones (UA/Almacen) en tramites o aprobadas sin entregas de item especifico
		sbReqFilter.append(" select null from tbl_inv_solicitud_req a where compania = z.compania and codigo_almacen = z.codigo_almacen and tipo_transferencia in ('U','A') and estado_solicitud in ('T','A') and exists (");
			sbReqFilter.append("select null from tbl_inv_d_sol_req bb where compania = a.compania and req_anio = a.anio and solicitud_no = a.solicitud_no and tipo_solicitud = a.tipo_solicitud and cod_articulo = z.cod_articulo");
			//sin entregas
			sbReqFilter.append(" and not exists (select null from tbl_inv_entrega_material aa where compania_sol = bb.compania and req_anio = bb.req_anio and req_tipo_solicitud = bb.tipo_solicitud and req_solicitud_no = bb.solicitud_no and exists (select null from tbl_inv_detalle_entrega where compania = aa.compania and anio = aa.anio and no_entrega = aa.no_entrega and cod_articulo = bb.cod_articulo))");
		sbReqFilter.append(")");
		if (!p.getColValue("req_fdate").equals("-")) {
			sbReqFilter.append(" and fecha_documento >= to_date('");
			sbReqFilter.append(p.getColValue("req_fdate"));
			sbReqFilter.append("','dd/mm/yyyy')");
		}
	sbReqFilter.append(" ) or exists ( ");
		//Requisiciones (Paciente) en tramites o aprobadas sin entregas de item especifico
		sbReqFilter.append(" select 'RP_'||a.anio||'_'||a.solicitud_no from tbl_inv_solicitud_pac a where compania = z.compania and codigo_almacen = z.codigo_almacen and estado in ('T','A') and exists (");
			sbReqFilter.append("select null from tbl_inv_d_sol_pac bb where compania = a.compania and anio = a.anio and solicitud_no = a.solicitud_no and cod_articulo = z.cod_articulo");
			//sin entregas
			sbReqFilter.append(" and not exists (select null from tbl_inv_entrega_material aa where compania = bb.compania and pac_anio = bb.anio and pac_solicitud_no = bb.solicitud_no and exists (select null from tbl_inv_detalle_entrega where compania = aa.compania and anio = aa.anio and no_entrega = aa.no_entrega and cod_articulo = bb.cod_articulo))");
		sbReqFilter.append(")");
		if (!p.getColValue("req_fdate").equals("-")) {
			sbReqFilter.append(" and fecha_documento >= to_date('");
			sbReqFilter.append(p.getColValue("req_fdate"));
			sbReqFilter.append("','dd/mm/yyyy')");
		}
	sbReqFilter.append(" ) )");
}

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (!wh.trim().equals("")) {
		sbSql = new StringBuffer();
		sbSql.append("select (select cod_flia from tbl_inv_articulo a where compania = z.compania and cod_articulo = z.cod_articulo) as familia");
		sbSql.append(", (select (select nombre from tbl_inv_familia_articulo where compania = a.compania and cod_flia = a.cod_flia) from tbl_inv_articulo a where compania = z.compania and cod_articulo = z.cod_articulo) as familia_desc");
		sbSql.append(", (select cod_clase from tbl_inv_articulo a where compania = z.compania and cod_articulo = z.cod_articulo) as clase");
		sbSql.append(", (select (select descripcion from tbl_inv_clase_articulo where compania = a.compania and cod_flia = a.cod_flia and cod_clase = a.cod_clase) from tbl_inv_articulo a where compania = z.compania and cod_articulo = z.cod_articulo) as clase_desc");
		sbSql.append(", (select cod_subclase from tbl_inv_articulo a where compania = z.compania and cod_articulo = z.cod_articulo) as subclase");
		sbSql.append(", (select (select descripcion from tbl_inv_subclase where compania = a.compania and cod_flia = a.cod_flia and cod_clase = a.cod_clase and subclase_id = a.cod_subclase) from tbl_inv_articulo a where compania = z.compania and cod_articulo = z.cod_articulo) as subclase_desc");
		sbSql.append(", (select descripcion from tbl_inv_articulo a where compania = z.compania and cod_articulo = z.cod_articulo) as articulo_desc");
		sbSql.append(", z.cod_articulo as articulo, z.codigo_almacen, nvl(z.codigo_anaquel,0) as anaquel_id, z.disponible, nvl(z.pto_reorden,0) as pto_reorden, nvl(z.precio,0) as costo");
		sbSql.append(", (select descripcion from tbl_inv_almacen a where compania = z.compania and codigo_almacen = z.codigo_almacen) as almacen");
		sbSql.append(", nvl((select cod_anaquel from tbl_inv_anaqueles_x_almacen a where compania = z.compania and codigo_almacen = z.codigo_almacen and codigo = z.codigo_anaquel),'0') as anaquel_code");
		sbSql.append(", nvl((select descripcion from tbl_inv_anaqueles_x_almacen a where compania = z.compania and codigo_almacen = z.codigo_almacen and codigo = z.codigo_anaquel),'SIN DEFINIR') as anaquel_desc");
		sbSql.append(", (select cod_medida from tbl_inv_articulo a where compania = z.compania and cod_articulo = z.cod_articulo) as um");
		sbSql.append(", (select (select descripcion from tbl_inv_unidad_medida where cod_medida = a.cod_medida) from tbl_inv_articulo a where compania = z.compania and cod_articulo = z.cod_articulo) as um_desc");
		sbSql.append(", (select nvl(precio_venta,0) from tbl_inv_articulo a where compania = z.compania and cod_articulo = z.cod_articulo) as precio_venta");
		//sbSql.append(", '-' as solicitudes");//orden de compra (sin recepciones) o requisiciones (sin entregas)
		sbSql.append(", nvl(join(cursor(");
			//OC aprobadas sin recepciones de item especifico
			sbSql.append("select 'OC-'||a.anio||'-'||a.num_doc||'-'||a.tipo_compromiso from tbl_com_comp_formales a where compania = z.compania and cod_almacen = z.codigo_almacen and status = 'A' and exists (");
				sbSql.append("select null from tbl_com_detalle_compromiso bb where compania = a.compania and cf_anio = a.anio and cf_tipo_com = a.tipo_compromiso and cf_num_doc = a.num_doc and cod_articulo = z.cod_articulo");
				//sin recepciones
				sbSql.append(" and not exists (select null from tbl_inv_recepcion_material aa where compania = bb.compania and cf_anio = bb.cf_anio and cf_tipo_com = bb.cf_tipo_com and cf_num_doc = bb.cf_num_doc and estado = 'R' and exists (select null from tbl_inv_detalle_recepcion where compania = aa.compania and anio_recepcion = aa.anio_recepcion and numero_documento = aa.numero_documento and cod_articulo = bb.cod_articulo))");
			sbSql.append(")");
			if (!p.getColValue("req_fdate").equals("-")) {
				sbSql.append(" and fecha_documento >= to_date('");
				sbSql.append(p.getColValue("req_fdate"));
				sbSql.append("','dd/mm/yyyy')");
			}
			//Requisiciones (UA/Almacen) en tramites o aprobadas sin entregas de item especifico
			sbSql.append(" union all select 'REQ-'||a.tipo_transferencia||'-'||a.anio||'-'||a.solicitud_no||'-'||a.tipo_solicitud from tbl_inv_solicitud_req a where compania = z.compania and codigo_almacen = z.codigo_almacen and tipo_transferencia in ('U','A') and estado_solicitud in ('T','A') and exists (");
				sbSql.append("select null from tbl_inv_d_sol_req bb where compania = a.compania and req_anio = a.anio and solicitud_no = a.solicitud_no and tipo_solicitud = a.tipo_solicitud and cod_articulo = z.cod_articulo");
				//sin entregas
				sbSql.append(" and not exists (select null from tbl_inv_entrega_material aa where compania_sol = bb.compania and req_anio = bb.req_anio and req_tipo_solicitud = bb.tipo_solicitud and req_solicitud_no = bb.solicitud_no and exists (select null from tbl_inv_detalle_entrega where compania = aa.compania and anio = aa.anio and no_entrega = aa.no_entrega and cod_articulo = bb.cod_articulo))");
			sbSql.append(")");
			if (!p.getColValue("req_fdate").equals("-")) {
				sbSql.append(" and fecha_documento >= to_date('");
				sbSql.append(p.getColValue("req_fdate"));
				sbSql.append("','dd/mm/yyyy')");
			}
			//Requisiciones (Paciente) en tramites o aprobadas sin entregas de item especifico
			sbSql.append(" union all select 'REQ-P-'||a.anio||'-'||a.solicitud_no from tbl_inv_solicitud_pac a where compania = z.compania and codigo_almacen = z.codigo_almacen and estado in ('T','A') and exists (");
				sbSql.append("select null from tbl_inv_d_sol_pac bb where compania = a.compania and anio = a.anio and solicitud_no = a.solicitud_no and cod_articulo = z.cod_articulo");
				//sin entregas
				sbSql.append(" and not exists (select null from tbl_inv_entrega_material aa where compania = bb.compania and pac_anio = bb.anio and pac_solicitud_no = bb.solicitud_no and exists (select null from tbl_inv_detalle_entrega where compania = aa.compania and anio = aa.anio and no_entrega = aa.no_entrega and cod_articulo = bb.cod_articulo))");
			sbSql.append(")");
			if (!p.getColValue("req_fdate").equals("-")) {
				sbSql.append(" and fecha_documento >= to_date('");
				sbSql.append(p.getColValue("req_fdate"));
				sbSql.append("','dd/mm/yyyy')");
			}
		sbSql.append(" order by 1),','),'-') as solicitudes");
		sbSql.append(" from tbl_inv_inventario z where z.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and z.codigo_almacen = ");
		sbSql.append(wh);
		sbSql.append(sbFilter);
		sbSql.append(sbReqFilter);
		sbSql.append(" and (z.disponible > 0 or (z.disponible = 0 and nvl(z.pto_reorden,0) > 0))");
		sbSql.append(" order by 1,3,5,7");

		StringBuffer sbTmp = new StringBuffer();
		sbTmp.append("select * from (select rownum as rn, a.* from (");
		sbTmp.append(sbSql);
		sbTmp.append(") a) where rn between ");
		sbTmp.append(previousVal);
		sbTmp.append(" and ");
		sbTmp.append(nextVal);
		al = SQLMgr.getDataList(sbTmp.toString());
		sbTmp = new StringBuffer();
		sbTmp.append("select count(*) from (");
		sbTmp.append(sbSql);
		sbTmp.append(")");
		rowCount = CmnMgr.getCount(sbTmp.toString());

		sbSql = new StringBuffer();
		sbSql.append("select nvl(sum(z.disponible * nvl(z.precio,0)),0) as stockValue from tbl_inv_inventario z where z.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(sbReqFilter);
		sbSql.append(" and z.codigo_almacen = ");
		sbSql.append(wh);
		sbSql.append(" and (z.disponible > 0 or (z.disponible = 0 and nvl(z.pto_reorden,0) > 0))");
		CommonDataObject cdoS = SQLMgr.getData(sbSql.toString());
		stockValue = cdoS.getColValue("stockValue");

		sbSql = new StringBuffer();
		sbSql.append("select nvl((");
			//OC aprobadas sin recepciones de item especifico
			sbSql.append("select count('OC-'||a.anio||'-'||a.num_doc||'-'||a.tipo_compromiso) from tbl_com_comp_formales a where compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and cod_almacen = ");
			sbSql.append(wh);
			sbSql.append(" and status = 'A' and exists (");
				sbSql.append("select null from tbl_com_detalle_compromiso bb where compania = a.compania and cf_anio = a.anio and cf_tipo_com = a.tipo_compromiso and cf_num_doc = a.num_doc and exists (select null from tbl_inv_inventario z where compania = a.compania and codigo_almacen = a.cod_almacen and cod_articulo = bb.cod_articulo");
				sbSql.append(sbFilter);
				sbSql.append(" and (disponible > 0 or (disponible = 0 and nvl(pto_reorden,0) > 0)))");
				//sin recepciones
				sbSql.append(" and not exists (select null from tbl_inv_recepcion_material aa where compania = bb.compania and cf_anio = bb.cf_anio and cf_tipo_com = bb.cf_tipo_com and cf_num_doc = bb.cf_num_doc and estado = 'R' and exists (select null from tbl_inv_detalle_recepcion where compania = aa.compania and anio_recepcion = aa.anio_recepcion and numero_documento = aa.numero_documento and cod_articulo = bb.cod_articulo))");
			sbSql.append(")");
			if (!p.getColValue("req_fdate").equals("-")) {
				sbSql.append(" and fecha_documento >= to_date('");
				sbSql.append(p.getColValue("req_fdate"));
				sbSql.append("','dd/mm/yyyy')");
			}
		sbSql.append("),0) + nvl((");
			//Requisiciones (UA/Almacen) en tramites o aprobadas sin entregas de item especifico
			sbSql.append("select count('REQ-'||a.tipo_transferencia||'-'||a.anio||'-'||a.solicitud_no||'-'||a.tipo_solicitud) from tbl_inv_solicitud_req a where compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and codigo_almacen = ");
			sbSql.append(wh);
			sbSql.append(" and tipo_transferencia in ('U','A') and estado_solicitud in ('T','A') and exists (");
				sbSql.append("select null from tbl_inv_d_sol_req bb where compania = a.compania and req_anio = a.anio and solicitud_no = a.solicitud_no and tipo_solicitud = a.tipo_solicitud and exists (select null from tbl_inv_inventario z where compania = a.compania and codigo_almacen = a.codigo_almacen and cod_articulo = bb.cod_articulo");
				sbSql.append(sbFilter);
				sbSql.append(" and (disponible > 0 or (disponible = 0 and nvl(pto_reorden,0) > 0)))");
				//sin entregas
				sbSql.append(" and not exists (select null from tbl_inv_entrega_material aa where compania_sol = bb.compania and req_anio = bb.req_anio and req_tipo_solicitud = bb.tipo_solicitud and req_solicitud_no = bb.solicitud_no and exists (select null from tbl_inv_detalle_entrega where compania = aa.compania and anio = aa.anio and no_entrega = aa.no_entrega and cod_articulo = bb.cod_articulo))");
			sbSql.append(")");
			if (!p.getColValue("req_fdate").equals("-")) {
				sbSql.append(" and fecha_documento >= to_date('");
				sbSql.append(p.getColValue("req_fdate"));
				sbSql.append("','dd/mm/yyyy')");
			}
		sbSql.append("),0) + nvl((");
			//Requisiciones (Paciente) en tramites o aprobadas sin entregas de item especifico
			sbSql.append("select count('REQ-P-'||a.anio||'-'||a.solicitud_no) from tbl_inv_solicitud_pac a where compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and codigo_almacen = ");
			sbSql.append(wh);
			sbSql.append(" and estado in ('T','A') and exists (");
				sbSql.append("select null from tbl_inv_d_sol_pac bb where compania = a.compania and anio = a.anio and solicitud_no = a.solicitud_no and exists (select null from tbl_inv_inventario z where compania = a.compania and codigo_almacen = a.codigo_almacen and cod_articulo = bb.cod_articulo");
				sbSql.append(sbFilter);
				sbSql.append(" and (disponible > 0 or (disponible = 0 and nvl(pto_reorden,0) > 0)))");
				//sin entregas
				sbSql.append(" and not exists (select null from tbl_inv_entrega_material aa where compania = bb.compania and pac_anio = bb.anio and pac_solicitud_no = bb.solicitud_no and exists (select null from tbl_inv_detalle_entrega where compania = aa.compania and anio = aa.anio and no_entrega = aa.no_entrega and cod_articulo = bb.cod_articulo))");
			sbSql.append(")");
			if (!p.getColValue("req_fdate").equals("-")) {
				sbSql.append(" and fecha_documento >= to_date('");
				sbSql.append(p.getColValue("req_fdate"));
				sbSql.append("','dd/mm/yyyy')");
			}
		sbSql.append("),0) as pendingReq from dual");
		cdoS = SQLMgr.getData(sbSql.toString());
		pendingReq = cdoS.getColValue("pendingReq");
	}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);
	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario - Control de Inventario - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function viewItem(id){
	var mode='view';
	if($("#editable").val()=='y')mode='edit';
	abrir_ventana('../inventario/articulo_config.jsp?fg=CTRL&mode='+mode+'&id='+id+'&wh=<%=wh%>');
}
function viewKardex(id){
	abrir_ventana('../inventario/kardex_item.jsp?almacen=<%=wh%>&cod_articulo='+id+'&tipo_mov=&flia_kardex=ART');//&fDate=01/05/2019&tDate=31/05/2020
}
function viewReorder(id){
	var mode='view';
	if($("#editableReorder").val()=='y')mode='edit';
	abrir_ventana('../inventario/punto_reorden_articulo_list.jsp?fg=CTRL&mode='+mode+'&cod_articulo='+id+'&cod_almacen=<%=wh%>');
}
function viewShelf(id){
	var mode='view';
	if($("#editableShelf").val()=='y')mode='edit';
	abrir_ventana('../inventario/ubicacion_almacen_config.jsp?fg=CTRL&mode='+mode+'&cod_articulo='+id+'&ubicacionId=<%=wh%>');
}
function viewReq(reqId){
	var rId=reqId.split('-');
	if(rId[0]=='OC'){
		if(rId[3]=='3')abrir_ventana('../compras/reg_orden_compra_parcial.jsp?mode=view&id='+rId[2]+'&anio='+rId[1]);
	}else if(rId[0]=='REQ'){
		if(rId[1]=='U')abrir_ventana('../inventario/reg_req_unid_adm.jsp?mode=view&id='+rId[3]+'&anio='+rId[2]+'&tipoSolicitud='+rId[4]+'&tr=UA');
		else if(rId[1]=='A')abrir_ventana('../inventario/reg_req_unid_adm.jsp?mode=view&id='+rId[3]+'&anio='+rId[2]+'&tipoSolicitud='+rId[4]+'&tr=EA');
		else if(rId[1]=='P')abrir_ventana('../inventario/reg_sol_mat_pacientes.jsp?mode=view&id='+rId[3]+'&anio='+rId[2]);
	}
}
function printList(){
	if($("#printableList").val()=='y')abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/ctrl_inventario.rptdesign&fDate=<%=p.getColValue("req_fdate")%>&wh=<%=wh%>&familia=<%=familia%>&clase=<%=codClase%>&articulo=<%=articulo%>&descripcion=<%=descArticulo%>&estado=<%=estado%>&solicitud=<%=solicitud%>'+(($('#showCols').val()=='n')?'':'&c'));
	else alert('No tiene autorización para imprimir!');
}
function checkAuthtype(authType){
	$(document).ready(function() {
		if(authType==50){
			$(".dataInfo").show();
			$("#showCols").val("y");
		}else if(authType==51){
			$("#editable").val("y");
		}else if(authType==52){
			$("#editableReorder").val("y");
		}else if(authType==53){
			$("#editableShelf").val("y");
		}else if(authType==54){
			$("#printableList").val("y");
		}
	});
}
</script>
<style type="text/css">
<!--
.NoStock {background-color: #e62727 !important;}
.Reorder {background-color: #FFFF33 !important;}
.dataInfo {display: none;}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - ADMINISTRACION - CONTROL DE INVENTARIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right"><!--<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Entrega ]</a></authtype>-->&nbsp;</td>
</tr>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("searchMain",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("showCols","n")%>
<%=fb.hidden("editable","n")%>
<%=fb.hidden("editableReorder","n")%>
<%=fb.hidden("editableShelf","n")%>
<%=fb.hidden("printableList","n")%>
<tr class="TextFilter">
	<td>
		Almac&eacute;n
		<%=fb.select("wh",alWh,wh,true,false,false,0,"S")%>
		Familia
		<%=fb.select("familia","","",false,false,false,0,null,"width:200px","onChange=\"javascript:loadXML('../xml/itemClass.xml','codClase','"+codClase+"','VALUE_COL','LABEL_COL','"+session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','T')\"")%>
		<script language="javascript">
		loadXML('../xml/itemFamily.xml','familia','<%=familia%>','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>','KEY_COL','T');
		</script>
		Clase
		<%=fb.select("codClase","","",false,false,false,0,null,"width:200px",null)%>
		<script language="javascript">
		loadXML('../xml/itemClass.xml','codClase','<%=codClase%>','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-'+<%=(request.getParameter("familia") != null && !request.getParameter("familia").equals(""))?familia:"document.searchMain.familia.value"%>,'KEY_COL','T');
		</script>
		<br>
		C&oacute;digo
		<%=fb.textBox("articulo",articulo,false,false,false,15,null,null,null)%>
		Descripcion
		<%=fb.textBox("descArticulo",descArticulo,false,false,false,25,null,null,null)%>
		Estado
		<%=fb.select("estado","A=ACTIVO,I=INACTIVO",estado,false,false,0,"T")%>
		<label><%=fb.checkbox("solicitud","X",solicitud.equalsIgnoreCase("X"),false)%> S&oacute;lo con Solicitudes Pendientes</label>
		<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
<tr>
	<td align="right"><% if (request.getParameter("wh") != null && al.size() > 0) { %><authtype type='53'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype><% } %>&nbsp;</td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("codClase",codClase)%>
<%=fb.hidden("descArticulo",descArticulo)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("codClase",codClase)%>
<%=fb.hidden("descArticulo",descArticulo)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="2" cellspacing="1">
		<tr class="TextHeader02 WhiteText" align="center"<% if (wh.trim().equals("")) { %> style="display:none;"<% } %>>
			<td colspan="10">
				<table align="center" width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td width="50%" class="dataInfo"><font class="Text14">Valor del Inventario en Stock: &nbsp; <%=CmnMgr.getFormattedDecimal("###,###,##0.00",stockValue)%></font></td>
					<td width="50%" align="right"><font class="Text14">Solicitudes Pendientes: &nbsp; <%=pendingReq%></font></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="9%">&nbsp;</td>
			<td>Art&iacute;culo</td>
			<td width="9%">Anaquel</td>
			<td width="7%">Stock</td>
			<td width="6%" class="dataInfo">UM</td>
			<td width="7%">Pto.Reorden</td>
			<td width="8%" class="dataInfo">Costo Prom.</td>
			<td width="8%" class="dataInfo">Precio</td>
			<td width="14%">Solicitudes Pendientes</td>
		</tr>

<% if (request.getParameter("wh") == null) { %>
		<tr class="TextRow01" align="center">
			<td colspan="9">&nbsp;</td>
		</tr>
		<tr class="TextRow01 RedText" align="center">
			<td colspan="9">I N T R O D U Z C A &nbsp;&nbsp;&nbsp; P A R A M E T R O S &nbsp;&nbsp;&nbsp; D E &nbsp;&nbsp;&nbsp; B U S Q U E D A</td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="9">&nbsp;</td>
		</tr>
<% } else if (al.size() == 0) { %>
		<tr class="TextRow01" align="center">
			<td colspan="9">&nbsp;</td>
		</tr>
		<tr class="TextRow01 RedText" align="center">
			<td colspan="9">B U S Q U E D A &nbsp;&nbsp;&nbsp; S I N &nbsp;&nbsp;&nbsp; R E S U L T A D O S</td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="9">&nbsp;</td>
		</tr>
<% } %>
<%
String gf = "", gc = "", gs = "";
java.util.StringTokenizer st = null;
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	double stock = Double.parseDouble(cdo.getColValue("disponible"));
	int reorder = Integer.parseInt(cdo.getColValue("pto_reorden"));
	if (stock == 0) color = "TextRowOver ";
	else if (reorder > 0 && stock <= reorder) color = "Reorder ";

	st = new java.util.StringTokenizer(cdo.getColValue("solicitudes"),",");

	if (!gf.equalsIgnoreCase(cdo.getColValue("familia"))) {
%>
		<tr class="TextHeader01">
			<td colspan="9">[<%=cdo.getColValue("familia")%>] <%=cdo.getColValue("familia_desc")%></td>
		</tr>
<%
		gc = "";
		gs = "";
	}
	if (!gc.equalsIgnoreCase(cdo.getColValue("clase"))) {
%>
		<tr class="TextHeader01">
			<td colspan="9">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<%=cdo.getColValue("clase")%>] <%=cdo.getColValue("clase_desc")%></td>
		</tr>
<%
		gs = "";
	}
	if (!gs.equalsIgnoreCase(cdo.getColValue("subclase"))) {
%>
		<tr class="TextHeader01">
			<td colspan="9">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<%=cdo.getColValue("subclase")%>] <%=cdo.getColValue("subclase_desc")%></td>
		</tr>
<% } %>
		<tr class="<%=color%>"><!-- onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"-->
			<td align="right"><a href="javascript:viewItem(<%=cdo.getColValue("articulo")%>);" class="<%=(color.contains("TextRowOver"))?"Link04Bold":"Link00Bold"%>"><%=cdo.getColValue("articulo")%></a></td>
			<td><%=cdo.getColValue("articulo_desc")%></td>
			<td align="center"><a href="javascript:viewShelf(<%=cdo.getColValue("articulo")%>);" class="<%=(color.contains("TextRowOver"))?"Link04Bold":"Link00Bold"%>"><%=cdo.getColValue("anaquel_desc")%></a></td>
			<td align="center"><a href="javascript:viewKardex(<%=cdo.getColValue("articulo")%>);" class="<%=(color.contains("TextRowOver"))?"Link04Bold":"Link00Bold"%>"><%=cdo.getColValue("disponible")%></a></td>
			<td align="center" class="dataInfo"><%=cdo.getColValue("um")%></td>
			<td align="center"><a href="javascript:viewReorder(<%=cdo.getColValue("articulo")%>);" class="<%=(color.contains("TextRowOver"))?"Link04Bold":"Link00Bold"%>"><%=cdo.getColValue("pto_reorden")%></a></td>
			<td align="right" class="dataInfo"><%=CmnMgr.getFormattedDecimal("###,##0.000000",cdo.getColValue("costo"))%></td>
			<td align="right" class="dataInfo"><%=CmnMgr.getFormattedDecimal("###,##0.00",cdo.getColValue("precio_venta"))%></td>
			<td align="center">
				<%
				while (st.hasMoreTokens()) {
					String str = st.nextToken();
					StringBuffer sbNo = new StringBuffer();
					if (!str.equals("-")) {
						String[] r = str.split("-");
						if (r[0].equalsIgnoreCase("OC")) {
							sbNo.append(r[0]); sbNo.append("_"); sbNo.append(r[1]); sbNo.append("_"); sbNo.append(r[2]);
						} else if (r[0].equalsIgnoreCase("REQ")) {
							if (r[1].equalsIgnoreCase("P")) {
								sbNo.append("R"); sbNo.append(r[1]); sbNo.append("_"); sbNo.append(r[2]); sbNo.append("_"); sbNo.append(r[3]);
							} else {
								sbNo.append("R"); sbNo.append(r[1]); sbNo.append(r[4]); sbNo.append("_"); sbNo.append(r[2]); sbNo.append("_"); sbNo.append(r[3]);
							}
						}
					}
				%>
				&nbsp;<% if (!str.equals("-")) { %><a href="javascript:viewReq('<%=str%>')" class="<%=(color.contains("TextRowOver"))?"Link04Bold":"Link00Bold"%>"><%=sbNo%></a><% } %>
				<% } %>
			</td>
		</tr>
<%
	gf = cdo.getColValue("familia");
	gc = cdo.getColValue("clase");
	gs = cdo.getColValue("subclase");
}
%>
		</table>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("codClase",codClase)%>
<%=fb.hidden("descArticulo",descArticulo)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("wh",wh)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("codClase",codClase)%>
<%=fb.hidden("descArticulo",descArticulo)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<authtype type='50'><script language="javascript">checkAuthtype(50);</script></authtype><!--columns-->
<authtype type='51'><script language="javascript">checkAuthtype(51);</script></authtype><!--editable-->
<authtype type='52'><script language="javascript">checkAuthtype(52);</script></authtype><!--editableReorder-->
<authtype type='53'><script language="javascript">checkAuthtype(53);</script></authtype><!--editableShelf-->
<authtype type='54'><script language="javascript">checkAuthtype(54);</script></authtype><!--printList-->
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>
