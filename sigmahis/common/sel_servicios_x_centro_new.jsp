<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactDetTransaccion"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="XML" scope="page" class="issi.admin.XMLCreator"/>
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="fTranCargKey" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="FTransDet" scope="session" class="issi.facturacion.FactTransaccion"/>
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
XML.setConnection(ConMgr);
ArrayList al = new ArrayList();
CommonDataObject cdoParam = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
int rowCount = 0;
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");

String cs 				= request.getParameter("cs");
String tipo_cds 	= request.getParameter("tipo_cds");
String reporta_a 	= request.getParameter("reporta_a");
String mode 			= request.getParameter("mode");
String edad				= request.getParameter("edad");
String v_empresa	= request.getParameter("v_empresa");
String incremento	= request.getParameter("incremento");
String tipoInc		= request.getParameter("tipoInc");
String tipoTransaccion	= request.getParameter("tipoTransaccion");
String cat							= request.getParameter("cat");
String clasificacion		= request.getParameter("clasificacion");
String trxNo		= request.getParameter("trxNo");
String bar__code		= request.getParameter("bar__code")==null?"":request.getParameter("bar__code");

String admiSecuencia = request.getParameter("admiSecuencia");
String fechaNac = request.getParameter("fechaNac");
String codPaciente			= request.getParameter("codPaciente");
String codProv 		= request.getParameter("codProv");
String pacId			= request.getParameter("pacId");
String almacen = request.getParameter("almacen");
String codHonorario = request.getParameter("codHonorario");
String cargarCAut = java.util.ResourceBundle.getBundle("issi").getString("cargarCAut");
if(cargarCAut==null || cargarCAut.equals("")) cargarCAut = "N";
String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}
String  cdsDet2= "N";

if (fg == null) fg = "";
if (fp == null) fp = "";
if (cs == null) cs = "";

if (tipo_cds == null) tipo_cds = "";
if (reporta_a == null) reporta_a = "";
if (tipoTransaccion == null) tipoTransaccion = "";
if (tipoInc == null) tipoInc = "";
if (edad == null) edad = "0";
if (v_empresa == null) v_empresa = "0";
if (incremento == null) incremento = "0";
if (clasificacion == null) clasificacion = "";

if (admiSecuencia == null) admiSecuencia = "0";
if (fechaNac == null) fechaNac = "";
if (codPaciente == null) codPaciente = "";
if (codProv == null) codProv = "";
if (almacen == null) almacen = "";
if (trxNo == null) trxNo = "";

String noOrden = (request.getParameter("no_orden")==null?"":request.getParameter("no_orden"));
String codigoOrden = (request.getParameter("codigo_orden")==null?"":request.getParameter("codigo_orden"));
String idIntFar = (request.getParameter("id_int_far")==null?"":request.getParameter("id_int_far"));
String fPage = (request.getParameter("fPage")==null?"":request.getParameter("fPage"));

String tipoServicio = request.getParameter("tipoServicio");
String trabajo = request.getParameter("trabajo");
String descripcion = request.getParameter("descripcion");
String barCode = request.getParameter("barcode");
int iconHeight = 20;
int iconWidth = 20;
String byBarcode = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	boolean crypt = false;
	try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }

	sbSql.append("select get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'CHECK_DISP') as valida_dsp,get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'CDS_DET_CARGO') as cdsDet2,get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'FAR_ART_REPLICADOS') as valida_art_replicados,get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'USA_SYS_FAR_EXTERNA') usa_sys_far_externa from dual");
	cdoParam = SQLMgr.getData(sbSql.toString());
	if(cdoParam ==null)cdoParam = new CommonDataObject();
	if(cdoParam.getColValue("valida_dsp")==null ||cdoParam.getColValue("valida_dsp").trim().equals("")){ cdoParam.addColValue("valida_dsp","S");}
	if(cdoParam.getColValue("cdsDet2")==null ||cdoParam.getColValue("cdsDet2").trim().equals("")){ cdoParam.addColValue("cdsDet2","S");}
	if(cdoParam.getColValue("valida_art_replicados")==null ||cdoParam.getColValue("valida_art_replicados").trim().equals("")){ cdoParam.addColValue("valida_art_replicados","N");}


	int recsPerPage = 10;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null){
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (tipoServicio == null) tipoServicio = "";
	if (trabajo == null) trabajo = "";
	if (descripcion == null) descripcion = "";
	if (barCode == null) barCode = "";
	if (!tipoServicio.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("tipo_servicio = '"); sbFilter.append(tipoServicio); sbFilter.append("'"); }

	if (!trabajo.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("upper(trabajo) like '%"); sbFilter.append(trabajo.toUpperCase()); sbFilter.append("%'"); }

	if (!descripcion.trim().equals("")) { if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where "); sbFilter.append("upper(descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }

	if (!barCode.trim().equals("")) {
		if (crypt) {
			try{barCode = IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("barcode"),"_cUrl",256));}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, some one use the button. "+e);}
		}
		if (sbFilter.length() > 0) sbFilter.append(" and "); else sbFilter.append(" where ");
		sbFilter.append("trim(codBarra) = '");
		sbFilter.append(IBIZEscapeChars.forSingleQuots(barCode).trim());
		sbFilter.append("'");
		barCode = "";
		byBarcode = "Y";
	}

		//if (request.getParameter("urlEscapeChars") != null){

	System.out.println(":::::::::::::::::::::::::::::::::::::IR BOTTON HAS BEEN CLICKED");

	sbSql = new StringBuffer();
	if (tipoTransaccion.equalsIgnoreCase("C"))
	{
		if (almacen != null && !almacen.trim().equals(""))
		{
			//articulo con inventario
			sbSql.append("select 'C_ART_INV' uniq_identifier, (select nvl(tipo_servicio,' ') from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania) as tipo_servicio, (select nvl((select descripcion from tbl_cds_tipo_servicio where codigo = z.tipo_servicio),' ') from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and compania = a.compania) as tipo_serv_desc, a.descripcion, /*a.cod_flia||'-'||a.cod_clase||'-'||*/ ''||a.cod_articulo as trabajo, coalesce(getprecio(a.compania,(select (select clasif_cargo from tbl_cds_tipo_servicio where codigo = z.tipo_servicio) from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and z.compania = a.compania),a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo,");
			sbSql.append(v_empresa);
			sbSql.append(",");
			sbSql.append(cs);
			sbSql.append(",");
			sbSql.append(cat);
			sbSql.append("),a.precio_venta,0) as monto, ' ' as procedimiento, ' ' as otros_cargos, ' ' as cds_producto, ' ' as habitacion, ' ' as servicio_hab, ''||b.codigo_almacen as inv_almacen, ''||a.cod_flia as art_familia, ''||a.cod_clase as art_clase, ''||a.cod_articulo as inv_articulo, trim(a.cod_barra) as codBarra, ' ' as cod_uso, nvl(b.precio,0) as costo_art, 'N' as incremento, 'S' as inventario, nvl(b.disponible,0) as cantidad_disponible, 0 as centro_costo, a.other3 as afecta_inv, ' ' as cama, nvl(a.mostrar_fecha_vence, 'N') mostrar_fecha_vence from tbl_inv_articulo a, tbl_inv_inventario b where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and b.codigo_almacen = ");
			sbSql.append(almacen);

			if(fPage.equals("int_farmacia")){
			if(cdoParam.getColValue("usa_sys_far_externa").trim().equals("Y")||cdoParam.getColValue("usa_sys_far_externa").trim().equals("S"))sbSql.append(" and a.replicado_far='S' /*********************/ ");
			}else{
			 if(cdoParam.getColValue("valida_art_replicados").trim().equals("S")){ sbSql.append(" and a.replicado_far='N' /*********************/");}}

			sbSql.append(" and b.compania = a.compania and b.cod_articulo = a.cod_articulo and a.estado = 'A' and nvl(a.venta_sino,'N') = 'S' and exists (select z.tipo_servicio from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and z.compania = a.compania and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
			sbSql.append(cs);
			sbSql.append(" and tipo_servicio = z.tipo_servicio and visible_centro = 'S'))");
			//articulo sin inventario
			sbSql.append(" union all ");
			sbSql.append("select 'C_ART_INV' uniq_identifier, (select nvl(tipo_servicio,' ') from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania) as tipo_servicio, (select nvl((select descripcion from tbl_cds_tipo_servicio where codigo = z.tipo_servicio),' ') from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and compania = a.compania) as tipo_serv_desc, a.descripcion, /*a.cod_flia||'-'||a.cod_clase||'-'||*/ ''||a.cod_articulo as trabajo, coalesce(getprecio(a.compania,(select (select clasif_cargo from tbl_cds_tipo_servicio where codigo = z.tipo_servicio) from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and z.compania = a.compania),a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo,");
			sbSql.append(v_empresa);
			sbSql.append(",");
			sbSql.append(cs);
			sbSql.append(",");
			sbSql.append(cat);
			sbSql.append("),a.precio_venta,0) as monto, ' ' as procedimiento, ' ' as otros_cargos, ' ' as cds_producto, ' ' as habitacion, ' ' as servicio_hab, ' ' as inv_almacen, ''||a.cod_flia as art_familia, ''||a.cod_clase as art_clase, ''||a.cod_articulo as inv_articulo, trim(a.cod_barra) as codBarra, ' ' as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo, a.other3 as afecta_inv, ' ' as cama, nvl(a.mostrar_fecha_vence, 'N') mostrar_fecha_vence from tbl_inv_articulo a, tbl_inv_inventario b where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));

			if(fPage.equals("int_farmacia")){
			if((cdoParam.getColValue("usa_sys_far_externa").trim().equals("Y")||cdoParam.getColValue("usa_sys_far_externa").trim().equals("S")))sbSql.append(" and a.replicado_far='S' /*********************/ ");
			}
			 else{if(cdoParam.getColValue("valida_art_replicados").trim().equals("S")){ sbSql.append(" and a.replicado_far='N' /*********************/ ");}}

			sbSql.append(" and b.compania(+) = a.compania and b.cod_articulo(+) = a.cod_articulo and b.compania is null and nvl(a.other3,'N') = 'N' and a.estado = 'A' and nvl(a.venta_sino,'N') = 'S' and exists (select z.tipo_servicio from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and z.compania = a.compania and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
			sbSql.append(cs);
			sbSql.append(" and tipo_servicio = z.tipo_servicio and visible_centro = 'S'))");
			sbSql.append(" union all ");
		}
		//habitacion
		sbSql.append("select 'C_HAB' uniq_identifier, (select tipo_servicio from tbl_sal_habitacion where codigo = a.habitacion and compania = a.compania) as tipo_servicio, (select (select descripcion from tbl_cds_tipo_servicio where codigo = z.tipo_servicio) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania) as tipo_serv_desc, (select (select descripcion from tbl_cds_centro_servicio where codigo = z.unidad_admin) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania)|| ' ' || (select  descripcion from tbl_sal_tipo_habitacion where codigo = a.tipo_hab and compania = a.compania) as descripcion, a.habitacion||' - '||a.codigo as trabajo, coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select (select clasif_cargo from tbl_cds_tipo_servicio where codigo = z.tipo_servicio) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania),a.codigo,");
		sbSql.append(v_empresa);
		sbSql.append(",");
		sbSql.append(cs);
		sbSql.append(",");
		sbSql.append(cat);
		sbSql.append("),(select precio from tbl_sal_tipo_habitacion where codigo = a.tipo_hab and compania = a.compania),0) as monto, ' ' as procedimiento, ' ' as otros_cargos, ' ' as cds_producto, a.habitacion, ''||a.tipo_hab as servicio_hab, ' ' as inv_almacen, ' ' as art_familia, ' ' as art_clase, ' ' as inv_articulo, ' ' as codBarra, ' ' as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo, 'N' as afecta_inv, a.codigo as cama, 'N' mostrar_fecha_vence from tbl_sal_cama a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.estado_cama not in ('I') and exists (select z.unidad_admin from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania and z.unidad_admin = ");
		sbSql.append(cs);
		sbSql.append(" and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = z.unidad_admin and tipo_servicio = z.tipo_servicio and visible_centro='S' ))");

		//producto_x_cds
		sbSql.append(" union all ");
		sbSql.append("select 'C_PROD_CDS' uniq_identifier, a.tser as tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo = a.tser) as tipo_serv_desc, a.descripcion, /*nvl(a.cpt,''||a.codigo)*/ nvl(''||a.codigo,' ') as trabajo, coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select clasif_cargo from tbl_cds_tipo_servicio where codigo = a.tser),a.codigo,");
		sbSql.append(v_empresa);
		sbSql.append(",");
		sbSql.append(cs);
		sbSql.append(",");
		sbSql.append(cat);
		sbSql.append("),a.precio,0) as monto, ' ' as procedimiento, ' ' as otros_cargos, ''||a.codigo as cds_producto, ' ' as habitacion, ' ' as servicio_hab, ' ' as inv_almacen, ' ' as art_familia, ' ' as art_clase, ' ' as inv_articulo, ' ' codBarra, ' ' as cod_uso, 0 as costo_art, nvl(a.incremento,'S') as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo, 'N' as afecta_inv, ' ' as cama, 'N' mostrar_fecha_vence from tbl_cds_producto_x_cds a where a.cod_centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and a.estatus = 'A' and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = a.cod_centro_servicio and tipo_servicio = a.tser and visible_centro='S')");

		//uso
		sbSql.append(" union all ");
		sbSql.append("select 'C_USO' uniq_identifier, a.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo = a.tipo_servicio) as tipo_serv_desc, a.descripcion, ''||a.codigo as trabajo, coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select clasif_cargo from tbl_cds_tipo_servicio where codigo = a.tipo_servicio),a.codigo,");
		sbSql.append(v_empresa);
		sbSql.append(",");
		sbSql.append(cs);
		sbSql.append(",");
		sbSql.append(cat);
		sbSql.append("),a.precio_venta,0) as monto, ' ' as procedimiento, ' ' as otros_cargos, ' ' as cds_producto, ' ' as habitacion, ' ' as servicio_hab, ' ' as inv_almacen, ' ' as art_familia, ' ' as art_clase, ' ' as inv_articulo, trim(a.codigo_barra)  as codBarra, ''||a.codigo as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo, 'N' as afecta_inv, ' ' as cama, 'N' mostrar_fecha_vence from tbl_sal_uso a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.estatus = 'A' and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and tipo_servicio = a.tipo_servicio and visible_centro = 'S')");

		// PROCEDIMIENTO
		sbSql.append(" union all ");
		sbSql.append("select 'C_PROC' uniq_identifier, '07' as tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo = '07') as tipo_serv_desc, decode(a.observacion,null,a.descripcion,a.observacion) as descripcion, ''||a.codigo as trabajo, coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select clasif_cargo from tbl_cds_tipo_servicio where codigo = '07'),a.codigo,");
		sbSql.append(v_empresa);
		sbSql.append(",");
		sbSql.append(cs);
		sbSql.append(",");
		sbSql.append(cat);

		sbSql.append("),a.precio,0) as monto, a.codigo as procedimiento, ' ' as otros_cargos, ' ' as cds_producto, ' ' as habitacion, ' ' as servicio_hab, ' ' as inv_almacen, ' ' as art_familia, ' ' as art_clase, ' ' as inv_articulo, ' ' as codBarra, ' ' as cod_uso, nvl(a.costo,0) as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo, 'N' as afecta_inv, ' ' as cama, 'N' mostrar_fecha_vence from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where a.codigo = b.cod_procedimiento and b.cod_centro_servicio = ");

		sbSql.append(cs);
		sbSql.append(" and a.estado = 'A' and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and tipo_servicio = '07' and visible_centro = 'S')");

		//procedimientos externos
	}
	else if(tipoTransaccion.equals("D")&& !fg.trim().equals("HON"))
	{
		sbSql.append("select 'D_NOT_HON' uniq_identifier, nvl(a.procedimiento,' ') as procedimiento, nvl(''||a.otros_cargos,' ') as otros_cargos, nvl(''||a.cds_producto,' ') as cds_producto, nvl(a.habitacion,' ') as habitacion, nvl(''||a.inv_almacen,' ') as inv_almacen, nvl(''||a.art_familia,' ') as art_familia, nvl(''||a.art_clase,' ') as art_clase, nvl(''||a.inv_articulo,' ') as inv_articulo, art.cod_barra as codBarra, nvl(''||a.cod_uso,' ') as cod_uso, nvl(''||a.cod_paq_x_cds,' ') as cod_paq_x_cds, nvl(a.descripcion,' ') as descripcion, monto, nvl(''||a.servicio_hab,' ') as servicio_hab, nvl(a.centro_costo,0) as centro_costo, nvl(a.costo_art,0) as costo_art, a.tipo_cargo as tipo_servicio, nvl(a.recargo,0) as recargo, to_char(nvl(a.fecha_cargo,sysdate),'dd/mm/yyyy') as fecha_cargo, nvl(a.cod_prod_far,0) as cod_prod_far, nvl(a.pedido_far,0) as pedido_far, case when a.procedimiento is not null then a.procedimiento when a.otros_cargos is not null then ''||a.otros_cargos when a.cod_uso is not null then ''||a.cod_uso when a.cds_producto is not null then ''||a.cds_producto when a.habitacion is not null then a.habitacion when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then a.inv_almacen||'-'||a.art_familia||'-'||a.art_clase||'-'||a.inv_articulo when a.cod_uso is not null then ''||a.cod_uso when a.cod_paq_x_cds is not null then ''||a.cod_paq_x_cds else ' ' end as trabajo, nvl(sum(case when a.tipo_transaccion in ('C') then a.cantidad else 0 end),0) as cantidad_cargo, nvl(sum(case when a.tipo_transaccion in ('D') then a.cantidad else 0 end),0) as cantidad_devolucion, nvl(sum(case when a.tipo_transaccion in ('C') then a.cantidad else -1 * a.cantidad end),0) as cantidad_disponible, nvl((select descripcion from tbl_cds_tipo_servicio where codigo = a.tipo_cargo),' ') as tipo_serv_desc, case when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then 'S' else 'N' end as inventario");
		if(cdsDet.trim().equals("S")||cdsDet2.trim().equals("S"))sbSql.append(",a.centro_servicio ");
		else sbSql.append(",ft.centro_servicio ");

		sbSql.append(", case when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then (select nvl(other3,'Y') from tbl_inv_articulo where cod_Articulo = a.inv_articulo and compania = a.compania) else 'N' end as afecta_inv, a.cama, nvl(art.mostrar_fecha_vence, 'N') mostrar_fecha_vence");
		if (fPage.equalsIgnoreCase("int_farmacia"))sbSql.append(" ,a.ref_id");
		 else sbSql.append(" ,decode(a.ref_type,'PAQ',a.ref_id,null) ");

		sbSql.append(" as ref_id,decode(a.ref_type,'PAQ',a.ref_type,null) as ref_type ");
		sbSql.append("  from tbl_fac_detalle_transaccion a, tbl_fac_transaccion ft , tbl_inv_articulo art where a.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and a.fac_secuencia = ");
		sbSql.append(admiSecuencia);
		sbSql.append(" and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		if(!trxNo.equals("")){
			sbSql.append(" and ft.seq_trx = ");
			sbSql.append(trxNo);
		}
		if(!almacen.equals("")){
			sbSql.append(" and (case when a.inv_almacen is not null then a.inv_almacen else 1 end) = ");
			sbSql.append(" (case when a.inv_almacen is not null then ");
			sbSql.append(almacen);
			sbSql.append(" else 1 end)");

		}

		sbSql.append(" and ft.pac_id = a.pac_id and ft.admi_secuencia = a.fac_secuencia and ft.codigo = a.fac_codigo and ft.tipo_transaccion = a.tipo_transaccion and ft.compania = a.compania ");
		if(cdsDet.trim().equals("S"))sbSql.append(" and a.centro_servicio = ");
		else sbSql.append(" and ft.centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and a.inv_articulo = art.cod_articulo(+) group by decode(a.ref_type,'PAQ',a.ref_id,null),a.procedimiento, a.otros_cargos, a.cds_producto, a.habitacion, a.inv_almacen, a.art_familia, a.art_clase, a.inv_articulo, a.cod_uso, a.cod_paq_x_cds, a.descripcion, a.monto, a.servicio_hab, nvl(a.centro_costo,0), nvl(a.costo_art,0), a.tipo_cargo, nvl(a.recargo,0), to_char(nvl(a.fecha_cargo,sysdate),'dd/mm/yyyy'), a.cod_prod_far, a.pedido_far, a.cama, a.compania,decode(a.ref_type,'PAQ',a.ref_type,null) , nvl(art.mostrar_fecha_vence, 'N')");
		if(cdsDet.trim().equals("S")||cdsDet2.trim().equals("S"))sbSql.append(", a.centro_servicio");
		else sbSql.append(", ft.centro_servicio");
		sbSql.append(" ,art.cod_barra, nvl(art.mostrar_fecha_vence, 'N')");
		if (fPage.equalsIgnoreCase("int_farmacia"))sbSql.append(" ,a.ref_id");
		sbSql.append("  having nvl(sum(case when a.tipo_transaccion in ('C') then a.cantidad else -1 * a.cantidad end),0) > 0 ");
	}
	else if(tipoTransaccion.equals("D")&& fg.trim().equals("HON"))
	{
		sbSql.append("select 'D_HON' uniq_identifier, nvl(a.procedimiento,' ') as procedimiento, nvl(''||a.otros_cargos,' ') as otros_cargos, nvl(''||a.cds_producto,' ') as cds_producto, nvl(a.habitacion,' ') as habitacion, nvl(''||a.inv_almacen,' ') as inv_almacen, nvl(''||a.art_familia,' ') as art_familia, nvl(''||a.art_clase,' ') as art_clase, nvl(''||a.inv_articulo,' ') as inv_articulo, ' ' as codBarra, nvl(''||a.cod_uso,' ') as cod_uso, nvl(''||a.cod_paq_x_cds,' ') as cod_paq_x_cds, nvl(a.descripcion,' ') as descripcion, monto, nvl(''||a.servicio_hab,' ') as servicio_hab, nvl(a.centro_costo,0) as centro_costo, nvl(a.costo_art,0) as costo_art, a.tipo_cargo as tipo_servicio, nvl(a.recargo,0) as recargo, '_' as fecha_cargo, nvl(a.cod_prod_far,0) as cod_prod_far, nvl(a.pedido_far,0) as pedido_far, case when a.procedimiento is not null then a.procedimiento when a.otros_cargos is not null then ''||a.otros_cargos when a.cds_producto is not null then ''||a.cds_producto when a.habitacion is not null then a.habitacion when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then a.inv_almacen||'-'||a.art_familia||'-'||a.art_clase||'-'||a.inv_articulo when a.cod_uso is not null then ''||a.cod_uso when a.cod_paq_x_cds is not null then ''||a.cod_paq_x_cds else ' ' end as trabajo, nvl(sum(case when a.tipo_transaccion in ('C','H') then a.cantidad else 0 end),0) as cantidad_cargo, nvl(sum(case when a.tipo_transaccion in ('D') then a.cantidad else 0 end),0) as cantidad_devolucion, nvl(sum(case when a.tipo_transaccion in ('C','H') then a.cantidad else -1 * a.cantidad end),0) as cantidad_disponible, nvl((select descripcion from tbl_cds_tipo_servicio where codigo = a.tipo_cargo),' ') as tipo_serv_desc, 'N' as inventario, a.centro_servicio, a.honorario_por, 'N' as afecta_inv, ' ' as cama from tbl_fac_detalle_transaccion a where a.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and a.fac_secuencia = ");
		sbSql.append(admiSecuencia);
		sbSql.append(" and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and exists (select * from tbl_fac_transaccion where pac_id = a.pac_id and admi_secuencia = a.fac_secuencia and codigo = a.fac_codigo and tipo_transaccion = a.tipo_transaccion and compania = a.compania and centro_servicio = ");
		sbSql.append(cs);
		if(!trxNo.equals("")){
			sbSql.append(" and seq_trx = ");
			sbSql.append(trxNo);
		}
		sbSql.append(" and decode (nvl(pagar_sociedad,'N'),  'N',med_codigo,  'S', to_char(empre_codigo)) = '");
		sbSql.append(codHonorario);
		sbSql.append("' ) group by nvl(a.procedimiento,' '), nvl(''||a.otros_cargos,' '), nvl(''||a.cds_producto,' '), nvl(a.habitacion,' '), nvl(''||a.inv_almacen,' '), nvl(''||a.art_familia,' '), nvl(''||a.art_clase,' '), nvl(''||a.inv_articulo,' '),'',nvl(''||a.cod_paq_x_cds,' '),nvl(''||a.servicio_hab,' '),  nvl(a.centro_costo,0), nvl(a.costo_art,0), a.tipo_cargo, a.centro_servicio, a.honorario_por, nvl(a.recargo,0), nvl(a.cod_prod_far,0), nvl(a.pedido_far,0), case when a.procedimiento is not null then a.procedimiento when a.otros_cargos is not null then ''||a.otros_cargos when a.cds_producto is not null then ''||a.cds_producto when a.habitacion is not null then a.habitacion when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then a.inv_almacen||'-'||a.art_familia||'-'||a.art_clase||'-'||a.inv_articulo when a.cod_uso is not null then ''||a.cod_uso when a.cod_paq_x_cds is not null then ''||a.cod_paq_x_cds else ' ' end, nvl(''||a.cod_uso,' '), nvl(a.descripcion,' '), a.monto having nvl(sum(case when a.tipo_transaccion in ('C','H') then a.cantidad else -1 * a.cantidad end),0) > 0");

	} else issi.admin.ISSILogger.error("error","No query defined in "+request.getContextPath()+request.getServletPath()+" qs="+request.getQueryString());

	if (sbSql.length() > 0 && request.getParameter("tipoServicio") != null) {

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from (select * from ("+sbSql+")"+sbFilter+" order by tipo_serv_desc, descripcion) a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+") "+sbFilter);

	}
	//}

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
document.title = 'Centro de Servicio - '+document.title;
var sql  = "<%//=sbSql%>";
var ignoreSelectAnyWhere = true; // se usa para eliminar la opción global de seleccionar un checkbox/radio cliqueando cualquier lado.

function chkValues(){
	var size = parseInt(document.detail.keySize.value);
	for(i=0;i<size;i++){
		chkValue(i);
	}
	return true;
}

function chkValue(i){
	var cantidad = parseInt(eval('document.detail.cantidad'+i).value,10);
	var cant_cargo = parseInt(eval('document.detail.cant_cargo'+i).value,10);
	var cant_devolucion = parseInt(eval('document.detail.cant_devolucion'+i).value,10);
	var cant_disponible = parseInt(eval('document.detail.cantidad_disponible'+i).value,10);
	var __flag = true;
	if(cantidad > (cant_cargo-cant_devolucion)){
		 top.CBMSG.warning('La cantidad a devolver excede la cantidad del cargo...,VERIFIQUE!');
		eval('document.detail.cantidad'+i).value = 0;
		eval('document.detail.cantidad'+i).select();
		__flag = false;
	} else if (cantidad > cant_disponible){
		 top.CBMSG.warning('La cantidad excede la cantidad disponible...,VERIFIQUE!');
		eval('document.detail.cantidad'+i).value = 0;
		eval('document.detail.cantidad'+i).select();
		__flag = false;
	}
	return __flag;
}

function chkDisp(i){
	var inventario		= eval('document.detail.inventario'+i).value;
	var afecta_inv		= eval('document.detail.afecta_inv'+i).value;
	<%if(cdoParam.getColValue("valida_dsp").trim().equals("S")){%>
	if(inventario=='S'&&afecta_inv=='Y'){
		var cantidad				= parseInt(eval('document.detail.cantidad'+i).value,10);
		var inv_almacen				= parseInt(eval('document.detail.inv_almacen'+i).value,10);
		var art_familia				= parseInt(eval('document.detail.art_familia'+i).value,10);
		var art_clase				= parseInt(eval('document.detail.art_clase'+i).value,10);
		var inv_articulo		= parseInt(eval('document.detail.inv_articulo'+i).value,10);

		var cant_disponible = getInvDisponible('<%=request.getContextPath()%>', <%=(String) session.getAttribute("_companyId")%>, inv_almacen, art_familia, art_clase, inv_articulo);

		if (cantidad > cant_disponible){
			top.CBMSG.warning('La cantidad excede la cantidad disponible...,VERIFIQUE!');
			eval('document.detail.cantidad'+i).value = 0;
			eval('document.detail.cantidad'+i).select();
			eval('document.detail.chkServ'+i).checked= false;
		}
	}
	<%}%>
}


var totSel = 0;
function checkIndicator(i,opt){
	var chkServObj = $("#chkServ"+i), cant = 0, qtyChanged = false;
	var __dblClick = (typeof opt !== "undefined" && opt == "dc")
	var __ignored = $("#ignored"+i).length > 0;
	var tipoTrans = $("#tipoTransaccion").val();
	var almacen = $("#almacen").val();
	var fg = "<%=fg%>";
	var dochkVal = (tipoTrans=="D" && almacen != null && almacen.trim() != "" ||(tipoTrans=="D" && fg=="HON"));
		var trabajo = $("#trabajo"+i).val();
		var descripcion = $("#descripcion"+i).val();
		var cantDispo = $("#cantidad_disponible"+i).val() || '0';
		var inventario = document.getElementById('inventario'+i).value;
	var afectaInv= document.getElementById('afecta_inv'+i).value;
		var validaDsp = "<%=cdoParam.getColValue("valida_dsp").trim()%>";
		var shouldCheckDsp = false;

		cantDispo = parseInt(cantDispo, 10);

		if (validaDsp == 'S' && inventario == 'S' && afectaInv == 'Y') shouldCheckDsp = true;
	if (typeof opt !== "undefined" && opt == "qty") cant = $("#cantidad"+i).val();

	if (cant > 0) qtyChanged = true;
	var __type = (chkServObj.is(":checked") && qtyChanged == false)?"u":"c";
		var beenSent = $("#been_sent"+i).val();
		var dispMsg = "";

		if (!qtyChanged) cant = 1;
		if (!shouldCheckDsp) cantDispo = cant;

		if (shouldCheckDsp && ((!chkServObj.length && !beenSent) || cant > cantDispo || cantDispo == 0)){
				 $("#dispo-info").text("Disponibilidad: "+cantDispo);
				 chkServObj.prop("checked", false);
		}

	if (!__ignored && chkServObj.length && cant <= cantDispo) {
				$("#dispo-info").text("");
			 __doCheckUncheck(__type);
		}

	function __doCheckUncheck(type){
		var __checked = qtyChanged==false?(type=="c"):(type=="c" && cant > 0);
				var __icon = qtyChanged==false?(type=="c"?"&#9745;":"&#9744;"):(type=="c"&& cant > 0?"&#9745;":"&#9744;");

		$("#curCargosUrl").val(window.location.href);
		$("#parentCurCargosUrl", parent.document).val(window.location.href);

				totSel = type=="u"? (totSel > 0? totSel-1:0): totSel + 1;

		if(dochkVal && !chkValue(i)) {totSel--;__checked=false;__icon="&#9744;"}
				if (!isInteger(cant)) {top.CBMSG.warning("Por favor verifique!, esta cantidad no es válida.");totSel--;__checked=false;__icon="&#9744;"}

				chkServObj.prop('checked',__checked);
				$("#check_ind"+i).html(__icon);
				$("#totSel", parent.document).val(totSel);

				if (__dblClick==true) { doTempCant(); parent.doSumitCargos(); }
	}
}


var xxHeight=0;
function doAction(){xxHeight=objHeight('_tblMainx');resizeFrame();document.search01.barcode.focus();
<%if(request.getParameter("after_deleting") == null && byBarcode.trim().equals("Y") && al.size() == 1){%>
 $("#cantidad0").val(1);
 checkIndicator(0,'dc');
<%}%>
}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMainx'),xxHeight,100);}

function doTempCant(){
	var o;
	try{
		_t = getOBJ("size").o.value;
		_tmpA = new Array();
		for (i=0; i<_t; i++){
			var __data = getOBJ("curInd"+i).o.value;
			var _cant = getOBJ("cantidad"+i).o.value;
			_tmp = __data+":"+_cant;
			if(_cant>0) _tmpA.push(_tmp);
		 } //i
		 $("#tmpCant").val(_tmpA);
	}catch(e){debug("ERROR [sel_servicios_x_centro_new] doTempCant() CAUSED BY: "+e)}
}

function getOBJ(id){
	return {"dome":id, o:eval("parent.window.frames['itemFrame'].document.form1."+id)}
}
function showLoteFechaVenve(id, wh){
	parent.showPopWin('../process/inv_view_inf_art.jsp?almacen='+wh+'&codigo='+id,winWidth*.75,winHeight*.65,null,null,'');
}
</script>
<!--
	Dejar en blanco [fieldsToBeCleared] si el form donde esta el cod barra tiene bastante
	inputs y no quieres enumerar todos :D. Sin espacio entre los nombres

	La orden importa de los mensajes en wrongFrmElMsg
	ver formExists() in inc_barcode_filter.jsp
-->
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true" >
	<jsp:param name="formEl" value="search01"></jsp:param>
	<jsp:param name="barcodeEl" value="barcode"></jsp:param>
	<jsp:param name="last_barcode" value="last_barcode"></jsp:param>
	<jsp:param name="form_qty_to_increment_context" value="parent.window.frames['itemFrame'].document"></jsp:param>
	<jsp:param name="form_qty_to_field" value="cantidad"></jsp:param>
	<jsp:param name="form_context_barcode" value="barCode"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value="tipoServicio,trabajo,descripcion"></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMainx">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("urlEscapeChars","barcode")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipo_cds",tipo_cds)%>
<%=fb.hidden("reporta_a",reporta_a)%>
<%=fb.hidden("incremento",incremento)%>
<%=fb.hidden("tipoInc",tipoInc)%>
<%=fb.hidden("edad",edad)%>
<%=fb.hidden("v_empresa",v_empresa)%>
<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
<%=fb.hidden("cat",cat)%>
<%=fb.hidden("clasificacion",clasificacion)%>
<%=fb.hidden("codPaciente",codPaciente)%>
<%=fb.hidden("fechaNac",fechaNac)%>
<%=fb.hidden("admiSecuencia",admiSecuencia)%>
<%=fb.hidden("codProv",codProv)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("codHonorario",codHonorario)%>
<%=fb.hidden("no_orden",noOrden)%>
<%=fb.hidden("codigo_orden",codigoOrden)%>
<%=fb.hidden("id_int_far",idIntFar)%>
<%=fb.hidden("fPage",fPage)%>
<%=fb.hidden("bar__code",bar__code)%>
<%=fb.hidden("last_barcode", request.getParameter("barcode")!=null && !request.getParameter("barcode").equals("") ? ((crypt)?IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("barcode"),"_cUrl",256)):request.getParameter("barcode")) : "")%>
<td>
	<cellbytelabel><span onClick="doTempCant()">Tipo Serv.</span></cellbytelabel>
	<%=(cs.trim().equals(""))?"":fb.select(ConMgr.getConnection(),"select a.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio)||' - '||a.tipo_servicio as descripcion, a.tipo_servicio from tbl_cds_servicios_x_centros a where a.centro_servicio="+cs+" and a.visible_centro ='S' and exists (select tipo_servicio from tbl_cds_tipo_servicio where codigo = a.tipo_servicio)"+(fPage.equals("int_farmacia")?" and a.tipo_servicio = '"+tipoServicio+"' ":"")+" order by 2 desc","tipoServicio",tipoServicio,false,false,0,"Text10","width:100px","","",(fPage.equals("int_farmacia")?"":"T") )%>
<%if(tipoTransaccion.equals("D")){%>
No. Trx.
<%=fb.intBox("trxNo",trxNo,false,false,false,10,"Text10",null,null)%>
<%}%>
<%if(!fg.trim().equals("HON")){%>
	<cellbytelabel>C&oacute;d.</cellbytelabel>
	<%=fb.textBox("trabajo",trabajo,false,false,false,5,"Text10",null,null)%>

	<cellbytelabel>Cargo</cellbytelabel>
	<%=fb.textBox("descripcion",descripcion,false,false,false,10,"Text10",null,null)%>
	<%=fb.submit("go","Ir")%>
	<!--<span style="display:<%=(almacen.equals("")?"none":"")%>;"></span>-->
	&nbsp;<cellbytelabel>C.B</cellbytelabel>
	<%=fb.textBox("barcode","",false,false,false,10,0,"ignore",null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"",null,false,"placeholder='Código Barra'")%>

		&nbsp;&nbsp;<span id="dispo-info" class="TextRowYell"></span>
<%}else{%>
<%=fb.submit("go","Ir")%>
<%}%>
</td>

<%=fb.formEnd(true)%>
		</tr>
		</table>
	</td>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipo_cds",tipo_cds)%>
<%=fb.hidden("reporta_a",reporta_a)%>
<%=fb.hidden("incremento",incremento)%>
<%=fb.hidden("tipoInc",tipoInc)%>
<%=fb.hidden("edad",edad)%>
<%=fb.hidden("v_empresa",v_empresa)%>
<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
<%=fb.hidden("cat",cat)%>
<%=fb.hidden("clasificacion",clasificacion)%>
<%=fb.hidden("codPaciente",codPaciente)%>
<%=fb.hidden("fechaNac",fechaNac)%>
<%=fb.hidden("admiSecuencia",admiSecuencia)%>
<%=fb.hidden("codProv",codProv)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("barcode",barCode)%>
<%=fb.hidden("codHonorario",codHonorario)%>
<%=fb.hidden("urlEscapeChars","barcode")%>
<%=fb.hidden("trxNo",trxNo)%>
<%=fb.hidden("no_orden",noOrden)%>
<%=fb.hidden("codigo_orden",codigoOrden)%>
<%=fb.hidden("id_int_far",idIntFar)%>
<%=fb.hidden("fPage",fPage)%>
<%=fb.hidden("bar__code",bar__code)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previoust","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipo_cds",tipo_cds)%>
<%=fb.hidden("reporta_a",reporta_a)%>
<%=fb.hidden("incremento",incremento)%>
<%=fb.hidden("tipoInc",tipoInc)%>
<%=fb.hidden("edad",edad)%>
<%=fb.hidden("v_empresa",v_empresa)%>
<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
<%=fb.hidden("cat",cat)%>
<%=fb.hidden("clasificacion",clasificacion)%>
<%=fb.hidden("codPaciente",codPaciente)%>
<%=fb.hidden("fechaNac",fechaNac)%>
<%=fb.hidden("admiSecuencia",admiSecuencia)%>
<%=fb.hidden("codProv",codProv)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("barcode",barCode)%>
<%=fb.hidden("codHonorario",codHonorario)%>
<%=fb.hidden("urlEscapeChars","barcode")%>
<%=fb.hidden("trxNo",trxNo)%>
<%=fb.hidden("no_orden",noOrden)%>
<%=fb.hidden("codigo_orden",codigoOrden)%>
<%=fb.hidden("id_int_far",idIntFar)%>
<%=fb.hidden("fPage",fPage)%>
<%=fb.hidden("bar__code",bar__code)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextt","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMainx" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%
String onSubmit = "";
fb = new FormBean("detail",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>


<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipo_cds",tipo_cds)%>
<%=fb.hidden("reporta_a",reporta_a)%>
<%=fb.hidden("incremento",incremento)%>
<%=fb.hidden("tipoInc",tipoInc)%>
<%=fb.hidden("edad",edad)%>
<%=fb.hidden("v_empresa",v_empresa)%>
<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
<%=fb.hidden("cat",cat)%>
<%=fb.hidden("clasificacion",clasificacion)%>
<%=fb.hidden("codPaciente",codPaciente)%>
<%=fb.hidden("fechaNac",fechaNac)%>
<%=fb.hidden("admiSecuencia",admiSecuencia)%>
<%=fb.hidden("codProv",codProv)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("barcode",barCode)%>
<%=fb.hidden("codHonorario",codHonorario)%>
<%=fb.hidden("urlEscapeChars","barcode")%>
<%=fb.hidden("curCargosUrl","")%>
<%=fb.hidden("tmpCant","")%>
<%=fb.hidden("no_orden",noOrden)%>
<%=fb.hidden("codigo_orden",codigoOrden)%>
<%=fb.hidden("id_int_far",idIntFar)%>
<%=fb.hidden("fPage",fPage)%>
<%=fb.hidden("bar__code",bar__code)%>
		<tr class="TextHeader">
			<td width="<%=fp.equals("cargo_dev_pac") && tipoTransaccion.equals("D")?"35%":"40%"%>">
			<cellbytelabel>Tipo Servicio</cellbytelabel></td>
			<%if(fp.equals("cargo_dev_pac") && tipoTransaccion.equals("D")){%>
			<td width="9%"><cellbytelabel>Fecha</cellbytelabel></td>
			<%}%>
			<td width="<%=fp.equals("cargo_dev_pac") && tipoTransaccion.equals("D")?"35%":"40%"%>">
			<cellbytelabel>Descripci&oacute;n Servicio</cellbytelabel></td>
			<td width="9%"><cellbytelabel>Precio/U</cellbytelabel></td>
			<%if(fp.equals("cargo_dev_pac") && tipoTransaccion.equals("D")){%>
			<td width="10%"><cellbytelabel>Cant. Neta</cellbytelabel></td>
			<%}%>
			<td width="3%" align="center"><cellbytelabel>Cant</cellbytelabel>.</td>
			<td width="5%">&nbsp;</td>
			<td width="3%">&nbsp;</td>
		</tr>
<%
String onCheck = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	//onCheck = "onClick=\"javascript:chkValues("+i+");\"";
	%>
<%=fb.hidden("tipo_servicio"+i,cdo.getColValue("tipo_servicio"))%>
<%=fb.hidden("tipo_serv_desc"+i,cdo.getColValue("tipo_serv_desc"))%>
<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
<%=fb.hidden("trabajo"+i,cdo.getColValue("trabajo"))%>
<%=fb.hidden("habitacion"+i,cdo.getColValue("habitacion"))%>
<%=fb.hidden("servicio_hab"+i,cdo.getColValue("servicio_hab"))%>
<%=fb.hidden("cds_producto"+i,cdo.getColValue("cds_producto"))%>
<%=fb.hidden("cod_uso"+i,cdo.getColValue("cod_uso"))%>
<%=fb.hidden("centro_costo"+i,cdo.getColValue("centro_costo"))%>
<%=fb.hidden("costo_art"+i,cdo.getColValue("costo_art"))%>
<%=fb.hidden("procedimiento"+i,cdo.getColValue("procedimiento"))%>
<%=fb.hidden("otros_cargos"+i,cdo.getColValue("otros_cargos"))%>
<%=fb.hidden("usar_alert"+i,cdo.getColValue("usar_alert"))%>
<%=fb.hidden("precio1_"+i,cdo.getColValue("precio1"))%>
<%=fb.hidden("precio2_"+i,cdo.getColValue("precio2"))%>
<%=fb.hidden("recargo"+i,cdo.getColValue("recargo"))%>
<%=fb.hidden("incremento"+i,cdo.getColValue("incremento"))%>
<%if(tipoTransaccion.equals("D")){%>
<%=fb.hidden("centro_servicio"+i,cdo.getColValue("centro_servicio"))%>
<%}%>
<%=fb.hidden("tipo_cargo"+i,cdo.getColValue("tipo_cargo"))%>
<%=fb.hidden("cod_paq_x_cds"+i,cdo.getColValue("cod_paq_x_cds"))%>
<%=fb.hidden("tipo_transaccion"+i,cdo.getColValue("tipo_transaccion"))%>
<%=fb.hidden("fac_codigo"+i,cdo.getColValue("fac_codigo"))%>
<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
<%=fb.hidden("fecha_cargo"+i,cdo.getColValue("fecha_cargo"))%>

<%=fb.hidden("cant_cargo"+i,cdo.getColValue("cantidad_cargo"))%>
<%=fb.hidden("cant_devolucion"+i,cdo.getColValue("cantidad_devolucion"))%>
<%=fb.hidden("cama"+i,cdo.getColValue("cama"))%>
<%=fb.hidden("ref_id"+i,cdo.getColValue("ref_id"))%>
<%=fb.hidden("ref_type"+i,cdo.getColValue("ref_type"))%>


<%
	if(fg.equals("FH") && cdo.getColValue("cds_producto").equals("73")){
%>
<%=fb.hidden("porc_farhosp"+i,cdo.getColValue("porc_farhosp"))%>
<%
	}
%>

<%=fb.hidden("inv_almacen"+i,cdo.getColValue("inv_almacen"))%>
<%=fb.hidden("art_familia"+i,cdo.getColValue("art_familia"))%>
<%=fb.hidden("art_clase"+i,cdo.getColValue("art_clase"))%>
<%=fb.hidden("inv_articulo"+i,cdo.getColValue("inv_articulo"))%>
<%=fb.hidden("inventario"+i,cdo.getColValue("inventario"))%>
<%=fb.hidden("afecta_inv"+i,cdo.getColValue("afecta_inv"))%>
<%=fb.hidden("cantidad_disponible"+i,cdo.getColValue("cantidad_disponible"))%>
<%=fb.hidden("barcode"+i,cdo.getColValue("codBarra"))%>
<%=fb.hidden("honorario_por"+i,cdo.getColValue("honorario_por"))%>
<%=fb.hidden("uniq_identifier"+i,cdo.getColValue("uniq_identifier"))%>

<%
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String key = "";
	String cargoKey = cdo.getColValue("uniq_identifier","") + "_";

	if(tipoTransaccion.equals("D"))cargoKey += cdo.getColValue("fecha_cargo")+"_";
	cargoKey  += cdo.getColValue("tipo_servicio") +"_"+cdo.getColValue("trabajo");
	String onChange = "onFocus=\"this.select();\" onkeyup=\"checkIndicator("+i+",'qty');\" onChange=\" "+((tipoTransaccion.equals("D") && almacen != null && !almacen.trim().equals("")||(tipoTransaccion.equals("D") && fg.trim().equals("HON")))?"chkValue("+i+");":"chkDisp("+i+");")+"\"";

	//System.out.println("cargoKey = *************************************= "+cargoKey);
	if(fTranCargKey.containsKey(cargoKey)) key = (String) fTranCargKey.get(cargoKey);
	//System.out.println("key = "+key);
	//if (fTranCarg.containsKey(key)){
%>
		<!--<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("tipo_servicio")%></td>
			<td>&nbsp;<%=cdo.getColValue("tipo_serv_desc")%></td>
			<%if(fp.equals("cargo_dev_pac") && tipoTransaccion.equals("D")){%>
			<td align="center"><%=cdo.getColValue("fecha_cargo")%></td>
			<%}%>
			<td align="center"><%=cdo.getColValue("trabajo")%></td>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>&nbsp;</td>
			<td align="center">&nbsp;</td>
			<td align="center"><cellbytelabel>elegido</cellbytelabel></td>
		</tr>-->
<%
	//} else {
%>		<%if(fTranCarg.containsKey(key)){%>
			<%=fb.hidden("ignored"+i,""+i)%>
		<%}%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="<%=fTranCarg.containsKey(key)?"cursor:not-allowed;":"cursor:pointer"%>">
			<td onClick="checkIndicator(<%=i%>);" onDblClick="checkIndicator(<%=i%>,'dc');">[<%=cdo.getColValue("tipo_servicio")%>]<%=cdo.getColValue("tipo_serv_desc")%></td>
			<%if(fp.equals("cargo_dev_pac") && tipoTransaccion.equals("D")){%>
			<td onClick="checkIndicator(<%=i%>)" onDblClick="checkIndicator(<%=i%>,'dc');" align="center"><%=cdo.getColValue("fecha_cargo")%></td>
			<%}%>
			<td onClick="checkIndicator(<%=i%>)"  ondblclick="checkIndicator(<%=i%>,'dc');">&nbsp;
			<% if(cdo.getColValue("trabajo").indexOf("--")!=-1){ %>
			<span style="background-color:#fff">[<%=cdo.getColValue("trabajo")%>]</span>
			<% }else{ %>
			[<%=cdo.getColValue("trabajo")%>]
			<% } %><%=cdo.getColValue("descripcion")%></td>
			<td onClick="checkIndicator(<%=i%>)"  ondblclick="checkIndicator(<%=i%>,'dc');" align="right">
			<%
						if (!fPage.equalsIgnoreCase("int_farmacia")){
			if(fg.equals("FH") && cdo.getColValue("cds_producto").equals("73")){
			%>
			<%=fb.hidden("_monto"+i,cdo.getColValue("monto"))%>
			<%=fb.decBox("monto"+i,cdo.getColValue("monto"),false,false,false,10,10.2)%>
			<%
			} else {
			%>
			<%=fb.hidden("monto"+i,cdo.getColValue("monto"))%>
			<%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>
			<%
			}}else{%>
						<%=fb.hidden("monto"+i,cdo.getColValue("monto"))%>
						-
						<%
						}
			%>
			</td>
			<%if(fp.equals("cargo_dev_pac") && tipoTransaccion.equals("D")){%>
			<td width="10%" align="right"><cellbytelabel><%=cdo.getColValue("cantidad_disponible")%></cellbytelabel></td>
			<%}%>
			<td align="center">
			<%if(fTranCarg.containsKey(key)){%>--
						<%=fb.hidden("been_sent"+i, key)%>
			<%}else{%>
			<%=fb.intBox("cantidad"+i,(fg.trim().equals("HON"))?cdo.getColValue("cantidad_cargo"):"0",true,false,false,3,5,null,null,onChange,"title",false,"data"+i+"="+cdo.getColValue("tipo_servicio")+""+cdo.getColValue("trabajo"))%>
			<%}%>
			</td>
			<td align="center" onClick="checkIndicator(<%=i%>)"  ondblclick="checkIndicator(<%=i%>,'dc');">
			<% if(fTranCarg.containsKey(key)){%>
			<span id="check_ind<%=i%>" class="Text12Bold" style="font-size:medium;font-style: normal;">&#9745;</span>
			<%}else{%>
			<span style="display:none;">
			<%=(tipoTransaccion.equalsIgnoreCase("C") && (cdo.getColValue("inventario").equalsIgnoreCase("S")&& cdo.getColValue("afecta_inv").equalsIgnoreCase("Y")&& cdo.getColValue("cantidad_disponible").equals("0"))&&((cdoParam.getColValue("valida_dsp").trim().equals("S"))))?"":fb.checkbox("chkServ"+i,""+i,false,false,"","",onCheck)%></span>
			<em id="check_ind<%=i%>" style="font-size:medium;font-style: normal;">&#9744;</em>
			<%}%>
			</td>
			<td <%if(cdo.getColValue("uniq_identifier").equals("C_ART_INV") && cdo.getColValue("mostrar_fecha_vence").equals("S")){%>onDblClick="javascript:showLoteFechaVenve(<%=cdo.getColValue("inv_articulo")%>, <%=cdo.getColValue("inv_almacen")%>);"<%}%>>
			<%if(cdo.getColValue("uniq_identifier").equals("C_ART_INV") && cdo.getColValue("mostrar_fecha_vence").equals("S")){%>
			<img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/barcode.gif">
			<%}%>
			</td>
		</tr>
<%
	//}
}
if(al.size()==0){
%>
		<tr align="center">
			<td colspan="6"><cellbytelabel><%=request.getParameter("urlEscapeChars")==null?"No hubó búsqueda!":"No se ha Encontrados Registros"%></cellbytelabel></td>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
		</table>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
<!--<tr>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipo_cds",tipo_cds)%>
<%=fb.hidden("reporta_a",reporta_a)%>
<%=fb.hidden("incremento",incremento)%>
<%=fb.hidden("tipoInc",tipoInc)%>
<%=fb.hidden("edad",edad)%>
<%=fb.hidden("v_empresa",v_empresa)%>
<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
<%=fb.hidden("cat",cat)%>
<%=fb.hidden("clasificacion",clasificacion)%>
<%=fb.hidden("codPaciente",codPaciente)%>
<%=fb.hidden("fechaNac",fechaNac)%>
<%=fb.hidden("admiSecuencia",admiSecuencia)%>
<%=fb.hidden("codProv",codProv)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("barcode",barCode)%>
<%=fb.hidden("codHonorario",codHonorario)%>
<%=fb.hidden("urlEscapeChars","barcode")%>
<%=fb.hidden("trxNo",trxNo)%>
<%=fb.hidden("no_orden",noOrden)%>
<%=fb.hidden("codigo_orden",codigoOrden)%>
<%=fb.hidden("id_int_far",idIntFar)%>
<%=fb.hidden("fPage",fPage)%>
<%=fb.hidden("bar__code",bar__code)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previousb","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%>
			</td>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipo_cds",tipo_cds)%>
<%=fb.hidden("reporta_a",reporta_a)%>
<%=fb.hidden("incremento",incremento)%>
<%=fb.hidden("tipoInc",tipoInc)%>
<%=fb.hidden("edad",edad)%>
<%=fb.hidden("v_empresa",v_empresa)%>
<%=fb.hidden("tipoTransaccion",tipoTransaccion)%>
<%=fb.hidden("cat",cat)%>
<%=fb.hidden("clasificacion",clasificacion)%>
<%=fb.hidden("codPaciente",codPaciente)%>
<%=fb.hidden("fechaNac",fechaNac)%>
<%=fb.hidden("admiSecuencia",admiSecuencia)%>
<%=fb.hidden("codProv",codProv)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("trabajo",trabajo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("almacen",almacen)%>
<%=fb.hidden("barcode",barCode)%>
<%=fb.hidden("codHonorario",codHonorario)%>
<%=fb.hidden("urlEscapeChars","barcode")%>
<%=fb.hidden("trxNo",trxNo)%>
<%=fb.hidden("no_orden",noOrden)%>
<%=fb.hidden("codigo_orden",codigoOrden)%>
<%=fb.hidden("id_int_far",idIntFar)%>
<%=fb.hidden("fPage",fPage)%>
<%=fb.hidden("bar__code",bar__code)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextb","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>-->
</table>
</body>
</html>
<%
}
else
{
	int lineNo = FTransDet.getFTransDetail().size();
	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String fechaCargo = CmnMgr.getCurrentDate("dd/mm/yyyy");
	if(request.getParameter("fecha_cargo")!=null && !request.getParameter("fecha_cargo").equals("") && !request.getParameter("fecha_cargo").equals("_")) fechaCargo = request.getParameter("fecha_cargo");
	for(int i=0;i<keySize;i++){

		FactDetTransaccion det = new FactDetTransaccion();

		det.setTipoCargo(request.getParameter("tipo_servicio"+i));
		det.setTipoCargoDesc(request.getParameter("tipo_serv_desc"+i));
		det.setTrabajo(request.getParameter("trabajo"+i));
		det.setTrabajoDesc(request.getParameter("descripcion"+i));
		det.setMonto(request.getParameter("monto"+i));
		det.setCantidad(request.getParameter("cantidad"+i));
		det.setRefType(request.getParameter("ref_type"+i));
		if(request.getParameter("fecha_cargo"+i)!=null && !request.getParameter("fecha_cargo"+i).equals("")&& !request.getParameter("fecha_cargo"+i).equals("_")) fechaCargo = request.getParameter("fecha_cargo"+i);

		det.setFechaCargo(fechaCargo);// hh12:mi:ss am

				det.setUniqIdentifier(request.getParameter("uniq_identifier"+i));

				 if (fPage.equalsIgnoreCase("int_farmacia")){
					det.setRefType("FARINSUMOS");
					if (tipoTransaccion.trim().equalsIgnoreCase("C")) det.setRefId(request.getParameter("id_int_far"));
					System.out.println("................................................. 2 "+request.getParameter("ref_id"+i));
				} else det.setRefId(request.getParameter("ref_id"+i));


		if (request.getParameter("habitacion"+i) != null && !request.getParameter("habitacion"+i).equals("null") && !request.getParameter("habitacion"+i).trim().equals("")) det.setHabitacion(request.getParameter("habitacion"+i));
		if (request.getParameter("servicio_hab"+i) != null && !request.getParameter("servicio_hab"+i).equals("null") && !request.getParameter("servicio_hab"+i).trim().equals("")) det.setServicioHab(request.getParameter("servicio_hab"+i));
		if (request.getParameter("cds_producto"+i) != null && !request.getParameter("cds_producto"+i).equals("null") && !request.getParameter("cds_producto"+i).trim().equals("")) det.setCdsProducto(request.getParameter("cds_producto"+i));
		if (request.getParameter("cod_uso"+i) != null && !request.getParameter("cod_uso"+i).equals("null") && !request.getParameter("cod_uso"+i).trim().equals("")) det.setCodUso(request.getParameter("cod_uso"+i));
		if (request.getParameter("centro_costo"+i) != null && !request.getParameter("centro_costo"+i).equals("null") && !request.getParameter("centro_costo"+i).trim().equals("")) det.setCentroCosto(request.getParameter("centro_costo"+i));
		if (request.getParameter("costo_art"+i) != null && !request.getParameter("costo_art"+i).equals("null") && !request.getParameter("costo_art"+i).trim().equals("")) det.setCostoArt(request.getParameter("costo_art"+i));
		if (request.getParameter("procedimiento"+i) != null && !request.getParameter("procedimiento"+i).equals("null") && !request.getParameter("procedimiento"+i).trim().equals("")) det.setProcedimiento(request.getParameter("procedimiento"+i));
		if (request.getParameter("otros_cargos"+i) != null && !request.getParameter("otros_cargos"+i).equals("null") && !request.getParameter("otros_cargos"+i).trim().equals("")) det.setOtrosCargos(request.getParameter("otros_cargos"+i));
		if (request.getParameter("recargo"+i) != null && !request.getParameter("recargo"+i).equals("null") && !request.getParameter("recargo"+i).trim().equals("")) det.setRecargo(request.getParameter("recargo"+i));

		if(request.getParameter("secuencia"+i)!=null && !request.getParameter("secuencia"+i).equals("null") && !request.getParameter("secuencia"+i).equals("")) det.setSecuencia(request.getParameter("secuencia"+i));

		if(tipoTransaccion.equals("D") && request.getParameter("centro_servicio"+i)!=null && !request.getParameter("centro_servicio"+i).equals("null") && !request.getParameter("centro_servicio"+i).equals("")) det.setCentroServicio(request.getParameter("centro_servicio"+i));
		//else det.setSecuencia("0");
		//if(request.getParameter("tipo_cargo"+i)!=null && !request.getParameter("tipo_cargo"+i).equals("null") && !request.getParameter("tipo_cargo"+i).equals("")) det.setTipoCargo(request.getParameter("tipo_cargo"+i));
		//else det.setTipoCargo("0");
		if(request.getParameter("cod_paq_x_cds"+i)!=null && !request.getParameter("cod_paq_x_cds"+i).equals("null") && !request.getParameter("cod_paq_x_cds"+i).equals("")) det.setCodPaqXCds(request.getParameter("cod_paq_x_cds"+i));
		//else det.setCodPaqXCds("0");
		if(request.getParameter("tipo_transaccion"+i)!=null && !request.getParameter("tipo_transaccion"+i).equals("null") && !request.getParameter("tipo_transaccion"+i).equals("")) det.setTipoTransaccion(request.getParameter("tipo_transaccion"+i));
		//else det.setTipoTransaccion("0");
		if(request.getParameter("fac_codigo"+i)!=null && !request.getParameter("fac_codigo"+i).equals("null") && !request.getParameter("fac_codigo"+i).equals("")) det.setFacCodigo(request.getParameter("fac_codigo"+i));
		//else det.setFacCodigo("0");
		if(request.getParameter("cod_prod_far"+i)!=null && !request.getParameter("cod_prod_far"+i).equals("null") && !request.getParameter("cod_prod_far"+i).equals("")) det.setCodProdFar(request.getParameter("cod_prod_far"+i));
		//else det.setCodProdFar("0");
		if(request.getParameter("pedido_far"+i)!=null && !request.getParameter("pedido_far"+i).equals("null") && !request.getParameter("pedido_far"+i).equals("")) det.setPedidoFar(request.getParameter("pedido_far"+i));
		//else det.setPedidoFar("0");
		if(request.getParameter("cant_cargo"+i)!=null && !request.getParameter("cant_cargo"+i).equals("null") && !request.getParameter("cant_cargo"+i).equals("")) det.setCantCargo(request.getParameter("cant_cargo"+i));
		//else det.setCantCargo("0");
		if(request.getParameter("cant_devolucion"+i)!=null && !request.getParameter("cant_devolucion"+i).equals("null") && !request.getParameter("cant_devolucion"+i).equals("")) det.setCantDevolucion(request.getParameter("cant_devolucion"+i));

		if(request.getParameter("honorario_por"+i)!=null && !request.getParameter("honorario_por"+i).equals("null") && !request.getParameter("honorario_por"+i).equals(""))det.setHonorarioPor(request.getParameter("honorario_por"+i));

		det.setInvAlmacen(request.getParameter("inv_almacen"+i));
		det.setArtFamilia(request.getParameter("art_familia"+i));
		det.setArtClase(request.getParameter("art_clase"+i));
		det.setInvArticulo(request.getParameter("inv_articulo"+i));
		det.setInventario(request.getParameter("inventario"+i));
		det.setCantidadDisponible(request.getParameter("cantidad_disponible"+i));
		det.setCama(request.getParameter("cama"+i));
		det.setAfectaInv(request.getParameter("afecta_inv"+i));

		det.setBarCode(request.getParameter("barcode"+i));

		if(request.getParameter("chkServ"+i)!=null){
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;

						String uniqId = det.getUniqIdentifier();

			try {
				fTranCarg.put(key, det);
				if(tipoTransaccion.equals("D"))
				fTranCargKey.put(uniqId+"_"+det.getFechaCargo()+"_"+det.getTipoCargo()+"_"+det.getTrabajo(), key);
				else fTranCargKey.put(uniqId+"_"+det.getTipoCargo()+"_"+det.getTrabajo(), key);
				FTransDet.getFTransDetail().add(det);
				System.out.println("adding item "+key+" _ "+det.getTipoCargo()+"_"+det.getTrabajo());
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
			if(cargarCAut.trim().equals("S")){
			if(det.getCama() != null && !det.getCama().trim().equals("")&& !det.getCama().trim().equals("null") && tipoTransaccion.trim().equals("C") )
			{

			sbSql = new StringBuffer();
			sbSql.append("select 'D_COND' as uniq_identifier, cau.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo = cau.tipo_servicio) as tipo_serv_desc, nvl(decode(cau.tipo_referencia,'US',(select descripcion from tbl_sal_uso where codigo = cau.codigo_item ),'AR',(select descripcion from tbl_inv_articulo where compania = cau.compania and cod_articulo = cau.codigo_item)),0) as descripcion, ''||cau.codigo_item as trabajo, coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select clasif_cargo from tbl_cds_tipo_servicio where codigo = cau.tipo_servicio),cau.codigo_item,");
				sbSql.append(v_empresa);
				sbSql.append(",");
				sbSql.append(cs);
				sbSql.append(",");
				sbSql.append(cat);
				sbSql.append("),nvl(decode(cau.tipo_referencia,'US',(select precio_venta from tbl_sal_uso where codigo = cau.codigo_item),'AR',(select precio_venta from tbl_inv_articulo where compania = cau.compania and cod_articulo = cau.codigo_item)),0),0) as monto, ' ' as procedimiento, ' ' as otros_cargos, ' ' as cds_producto, ' ' as habitacion, ' ' as servicio_hab, cau.almacen as inv_almacen, cau.familia as art_familia, cau.clase as art_clase, decode(cau.tipo_referencia,'AR',cau.codigo_item,null) as inv_articulo, ' ' as codBarra, decode(cau.tipo_referencia,'US',cau.codigo_item,null) as cod_uso, decode(cau.tipo_referencia,'AR',(select nvl(i.precio,0) costo from tbl_inv_inventario i where i.codigo_almacen = cau.almacen and i.compania = cau.compania and i.cod_articulo = cau.codigo_item),0) as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo, 'N' as afecta_inv, ' ' as cama, 1 as cantidad, 'C' from tbl_sal_cargos_automaticos cau where cau.compania = ");
				 sbSql.append(session.getAttribute("_companyId"));
								 sbSql.append(" and cau.cama = '");
				 sbSql.append(det.getCama());
				 sbSql.append("' and cau.habitacion = '");
				 sbSql.append(det.getHabitacion());
								 sbSql.append("' and cau.estado = 'A'");

				//Condision para las devoluciones

				 al = SQLMgr.getDataList(sbSql.toString());

		for(int z=0; z<al.size(); z++){
			CommonDataObject cdo = (CommonDataObject) al.get(z);
			FactDetTransaccion det2 = new FactDetTransaccion();

			det2.setTipoCargo(cdo.getColValue("tipo_servicio"));
			det2.setUniqIdentifier(cdo.getColValue("uniq_identifier"));
			det2.setTipoCargoDesc(cdo.getColValue("tipo_serv_desc"));
			det2.setTrabajoDesc(cdo.getColValue("descripcion"));
			det2.setTrabajo(cdo.getColValue("trabajo"));
			det2.setArtClase(cdo.getColValue("art_clase"));
			det2.setArtFamilia(cdo.getColValue("art_familia"));
			det2.setFechaCargo(fechaCargo);
			det2.setCodUso(cdo.getColValue("cod_uso"));
			det2.setCentroCosto(cdo.getColValue("centro_costo"));
			det2.setCostoArt(cdo.getColValue("costo_art"));
			det2.setInvArticulo(cdo.getColValue("inv_articulo"));
			det2.setInventario(cdo.getColValue("inventario"));
			det2.setInvAlmacen(cdo.getColValue("inv_almacen"));

			det2.setMonto(cdo.getColValue("monto"));
			det2.setCantidad(cdo.getColValue("cantidad"));
			//det2.setCodPaqXCds(cdo.getColValue("cod_paq_x_cds"));
			//det2.setTipoTransaccion(cdo.getColValue("tipo_transaccion"));
			//det2.setFacCodigo(cdo.getColValue("fac_codigo"));
			//det2.setSecuencia(cdo.getColValue("secuencia"));
			//det2.setRecargo(cdo.getColValue("recargo"));
			//det2.setFechaCargo(cdo.getColValue("fecha_cargo"));

			det2.setCantCargo("1");
			//det2.setCantDevolucion(cdo.getColValue("cant_devolucion"));

			det.setCentroServicio(request.getParameter("centro_servicio"+i));


			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;

						 uniqId = det.getUniqIdentifier();

			try {
				fTranCarg.put(key, det2);
				if(tipoTransaccion.equals("D"))
				fTranCargKey.put(uniqId+"_"+det.getFechaCargo()+"_"+det2.getTipoCargo()+"_"+det2.getTrabajo(), key);
				else fTranCargKey.put(uniqId+"_"+det2.getTipoCargo()+"_"+det2.getTrabajo(), key);
				FTransDet.getFTransDetail().add(det2);

			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		}
		}//cargarCAut
			}

		}
	}
	session.setAttribute("_tmpCant",request.getParameter("tmpCant"));

	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_servicios_x_centro_new.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&fp="+fp+"&cs="+cs+"&tipo_cds="+tipo_cds+"&reporta_a="+reporta_a+"&incremento="+incremento+"&tipoInc="+tipoInc+"&edad="+edad+"&v_empresa="+v_empresa+"&tipoTransaccion="+tipoTransaccion+"&cat="+cat+"&codProv="+codProv+"&almacen="+almacen+"&clasificacion="+request.getParameter("clasificacion")+"&codPaciente="+request.getParameter("codPaciente")+"&fechaNac="+request.getParameter("fechaNac")+"&admiSecuencia="+request.getParameter("admiSecuencia")+"&tipoServicio="+request.getParameter("tipoServicio")+"&pacId="+request.getParameter("pacId")+"&codHonorario="+request.getParameter("codHonorario")+"&urlEscapeChars="+request.getParameter("urlEscapeChars")+"&fPage="+request.getParameter("fPage")+"&no_orden="+request.getParameter("no_orden")+"&id_int_far="+request.getParameter("id_int_far")+"&bar__code="+bar__code);

		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%
	String curCargosUrl = "";
	if(fp!= null && fp.equals("cargo_dev_pac")){
		 curCargosUrl = request.getParameter("curCargosUrl")==null?"":request.getParameter("curCargosUrl");%>
	//alert(parent.document.getElementById("itemFrame").src); return false;
	parent.document.getElementById("itemFrame").src = '<%=request.getContextPath()+"/facturacion/reg_cargo_dev_det_new.jsp?change=1&mode="+mode%>&fg=<%=fg%>&fp=<%=fp%>&cs=<%=cs%>&tipo_cds=<%=tipo_cds%>&reporta_a=<%=reporta_a%>&incremento=<%=incremento%>&tipoInc=<%=tipoInc%>&edad=<%=edad%>&v_empresa=<%=v_empresa%>&tipoTransaccion=<%=tipoTransaccion%>&cat=<%=cat%>&codProv=<%=codProv%>&tb=s&no_orden=<%=noOrden%>&fPage=<%=fPage%>&codigo_orden=<%=codigoOrden%>&id_int_far=<%=idIntFar%>&bar__code=<%=bar__code%>&tipoServicio=<%=tipoServicio%>';
	<%}%>
	window.location = "<%=curCargosUrl%>";
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>