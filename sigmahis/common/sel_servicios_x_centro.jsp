<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactDetTransaccion"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="XML" scope="page" class="issi.admin.XMLCreator" />
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="FTransDet" scope="session" class="issi.facturacion.FactTransaccion" />
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

String admiSecuencia = request.getParameter("admiSecuencia");
String fechaNac = request.getParameter("fechaNac");
String codPaciente			= request.getParameter("codPaciente");
String codProv 		= request.getParameter("codProv");
String pacId			= request.getParameter("pacId");
String almacen = request.getParameter("almacen");
String codHonorario = request.getParameter("codHonorario");
String cargarCAut = java.util.ResourceBundle.getBundle("issi").getString("cargarCAut");
String noDoc = request.getParameter("noDoc");

if(cargarCAut==null || cargarCAut.equals("")) cargarCAut = "N";

if (fg == null) fg = "";
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
if (noDoc == null) noDoc = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	boolean crypt = false;
	try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }

	sbSql.append("select (select param_value from tbl_sec_comp_param where compania in(-1,");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(") and param_name = 'CHECK_DISP') as valida_dsp from dual");
	cdoParam = SQLMgr.getData(sbSql.toString());
	if(cdoParam ==null||cdoParam.getColValue("valida_dsp")==null ||cdoParam.getColValue("valida_dsp").trim().equals("")){cdoParam = new CommonDataObject(); cdoParam.addColValue("valida_dsp","S");}


	int recsPerPage = 100;
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

	String tipoServicio = request.getParameter("tipoServicio");
	String trabajo = request.getParameter("trabajo");
	String descripcion = request.getParameter("descripcion");
	String barCode = request.getParameter("barcode");
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
	}

	if (tipoTransaccion.equalsIgnoreCase("C"))
	{
/*
		sbSql = new StringBuffer();
		sbSql.append("select a.tipo_servicio, a.tipo_servicio||' - '||(select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio) as descripcion from tbl_cds_servicios_x_centros a where a.centro_servicio=");
		sbSql.append(cs);
		sbSql.append(" order by 2 desc");
		al = SQLMgr.getDataList(sbSql.toString());
*/
//fh
//centro_costo, porc_farhosp

//(v_empresa=='20' || v_empresa == '236') && edad < 50
//usar_alert, precio1, precio2

//clasificacion == 'I'
//incremento

		sbSql = new StringBuffer();
		if (almacen != null && !almacen.trim().equals(""))
		{
			//articulo
			sbSql.append("select (select nvl(tipo_servicio,' ') from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania) as tipo_servicio, (select nvl((select descripcion from tbl_cds_tipo_servicio where codigo=z.tipo_servicio),' ') from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and compania = a.compania) as tipo_serv_desc, a.descripcion, /*a.cod_flia||'-'||a.cod_clase||'-'||*/ ''||a.cod_articulo as trabajo, coalesce(getprecio(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",(select (select clasif_cargo from tbl_cds_tipo_servicio where codigo=z.tipo_servicio) from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and z.compania = a.compania),a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo,");
			sbSql.append(v_empresa);
			sbSql.append(",");
			sbSql.append(cs);
			sbSql.append(",");
			sbSql.append(cat);
			sbSql.append("),a.precio_venta,0) as monto, ' ' as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, ");
			sbSql.append(almacen);
			sbSql.append(" as inv_almacen, a.cod_flia as art_familia, a.cod_clase as art_clase, a.cod_articulo as inv_articulo, trim(a.cod_barra) as codBarra, 0 as cod_uso, b.precio as costo_art, 'N' as incremento, 'S' as inventario, nvl(b.disponible, 0) as cantidad_disponible, 0 as centro_costo,nvl(a.other3,'Y')afecta_inv, null cama from tbl_inv_articulo a, tbl_inv_inventario b where a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and b.codigo_almacen = ");
			sbSql.append(almacen);
			sbSql.append(" and b.compania = a.compania and b.cod_articulo = a.cod_articulo and b.art_familia = a.cod_flia and b.art_clase = a.cod_clase and a.estado = 'A' and nvl(a.venta_sino,'N') ='S' and exists (select z.tipo_servicio from tbl_inv_familia_articulo z where z.cod_flia = a.cod_flia and z.compania = a.compania and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
			sbSql.append(cs);
			sbSql.append(" and tipo_servicio = z.tipo_servicio and visible_centro='S'))");
			sbSql.append(" union all ");
		}
		//habitacion
		sbSql.append("select (select tipo_servicio from tbl_sal_habitacion where codigo = a.habitacion and compania = a.compania) as tipo_servicio, (select (select descripcion from tbl_cds_tipo_servicio where codigo=z.tipo_servicio) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania) as tipo_serv_desc, (select (select descripcion from tbl_cds_centro_servicio where codigo=z.unidad_admin) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania) as descripcion, ''||a.habitacion||' - '||a.codigo as trabajo, coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select (select clasif_cargo from tbl_cds_tipo_servicio where codigo=z.tipo_servicio) from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania),a.codigo,");
		sbSql.append(v_empresa);
		sbSql.append(",");
		sbSql.append(cs);
		sbSql.append(",");
		sbSql.append(cat);
		sbSql.append("),(select precio from tbl_sal_tipo_habitacion where codigo = a.tipo_hab and compania = a.compania),0) as monto, ' ' as procedimiento, 0 as otros_cargos, 0 as cds_producto, a.habitacion, a.tipo_hab as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo, '' codBarra, 0 as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'N' afecta_inv, a.codigo as cama from tbl_sal_cama a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.estado_cama not in ('I') and exists (select z.unidad_admin from tbl_sal_habitacion z where z.codigo = a.habitacion and z.compania = a.compania and z.unidad_admin = ");
		sbSql.append(cs);
		sbSql.append(" and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = z.unidad_admin and tipo_servicio = z.tipo_servicio and visible_centro='S' ))");

		//producto_x_cds
		sbSql.append(" union all ");
		sbSql.append("select a.tser as tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tser) as tipo_serv_desc, a.descripcion, /*nvl(a.cpt,''||a.codigo)*/ nvl(''||a.codigo,'') as trabajo, coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select clasif_cargo from tbl_cds_tipo_servicio where codigo=a.tser),a.codigo,");
		sbSql.append(v_empresa);
		sbSql.append(",");
		sbSql.append(cs);
		sbSql.append(",");
		sbSql.append(cat);
		sbSql.append("),a.precio,0) as monto, ' ' as procedimiento, 0 as otros_cargos, a.codigo as cds_producto, ' ' as habitacion, 0 as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo, '' codBarra, 0 as cod_uso, 0 as costo_art, nvl(a.incremento,'S') as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'N'  afecta_inv, null as cama from tbl_cds_producto_x_cds a where a.cod_centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and a.estatus = 'A' and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = a.cod_centro_servicio and tipo_servicio = a.tser and visible_centro='S')");

		//uso
		sbSql.append(" union all ");
		sbSql.append("select a.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio) as tipo_serv_desc, a.descripcion,/* ''||*/  ''||a.codigo as trabajo, coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select clasif_cargo from tbl_cds_tipo_servicio where codigo=a.tipo_servicio),a.codigo,");
		sbSql.append(v_empresa);
		sbSql.append(",");
		sbSql.append(cs);
		sbSql.append(",");
		sbSql.append(cat);
		sbSql.append("),a.precio_venta,0) as monto, ' ' as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo,'' codBarra, a.codigo as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'N'  afecta_inv, null as cama from tbl_sal_uso a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.estatus = 'A' and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and tipo_servicio = a.tipo_servicio and visible_centro='S')");
		//otros_cargos
		sbSql.append(" union all ");
		sbSql.append("select a.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio) as tipo_serv_desc, a.descripcion,/* ''||*/ ''||a.codigo as trabajo, coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select clasif_cargo from tbl_cds_tipo_servicio where codigo=a.tipo_servicio),a.codigo,");
		sbSql.append(v_empresa);
		sbSql.append(",");
		sbSql.append(cs);
		sbSql.append(",");
		sbSql.append(cat);
		sbSql.append("),a.precio,0) as monto, ' ' as procedimiento, a.codigo as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo,'' codBarra, 0 as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'N'  afecta_inv, null as cama from tbl_fac_otros_cargos a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.codigo_tipo is not null and a.activo_inactivo = 'A' and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and tipo_servicio = a.tipo_servicio and visible_centro='S')");

		// PROCEDIMIENTO
		sbSql.append(" union all ");
		sbSql.append("select '07' as tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo='07') as tipo_serv_desc, decode(a.observacion, null, a.descripcion, a.observacion) descripcion,/*''||*/ ''||a.codigo as trabajo, coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select clasif_cargo from tbl_cds_tipo_servicio where codigo='07'),a.codigo,");
		sbSql.append(v_empresa);
		sbSql.append(",");
		sbSql.append(cs);
		sbSql.append(",");
		sbSql.append(cat);
		sbSql.append("),a.precio,0) as monto, a.codigo  as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, 0 as inv_almacen, 0 as art_familia, 0 as art_clase, 0 as inv_articulo,'' codBarra, 0 as cod_uso, 0 as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'N'  afecta_inv, null as cama from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds b where a.codigo=b.cod_procedimiento and b.cod_Centro_servicio=");
		sbSql.append(cs);
		sbSql.append(" and a.estado = 'A' and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and tipo_servicio = '07' and visible_centro='S')");

		//procedimientos externos

/*
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (cdo.getColValue("t_s").equals("1")){

				//'LOV_HABITACION_X_CENTRO'

				if(x!=0) sql += " union ";

				//if(fp.equals("cargo_dev_pac_sop")){

					sql += "select distinct '"+cdo.getColValue("t_s1")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, c.descripcion, a.codigo trabajo, nvl( getPrecioxAseg( "+v_empresa+", "+(String) session.getAttribute("_companyId")+" , '"+cdo.getColValue("t_s1")+"', null, null, null, null, null, null, a.codigo, b.precio,null), b.precio) monto, a.codigo habitacion, b.codigo servicio_hab, 0 cds_producto, 0 cod_uso, 0 centro_costo, 0 costo_art, ' ' procedimiento, ' ' otros_cargos, 'N' usar_alert, b.precio precio1, b.precio precio2, 'N' incremento from tbl_sal_habitacion a, tbl_sal_tipo_habitacion b, tbl_cds_centro_servicio c, tbl_sal_cama d where  a.compania = "+(String) session.getAttribute("_companyId")+" and a.codigo = d.habitacion and a.compania = d.compania and d.tipo_hab = b.codigo and d.compania = b.compania "+(fp.equals("cargo_dev_pac_sop")?"":" and d.estado_cama not in ('I')") + " and c.codigo = a.unidad_admin";
				x++;

			} else if ((((cdo.getColValue("t_s").equals("2") || cdo.getColValue("t_s").equals("3") || cdo.getColValue("t_s").equals("4") || cdo.getColValue("t_s").equals("6") || cdo.getColValue("t_s").equals("7") || cdo.getColValue("t_s").equals("16")) && (tipo_cds.equals("T") || tipo_cds.equals("E"))) || ((cdo.getColValue("t_s").equals("5")|| cdo.getColValue("t_s").equals("8") )&& tipo_cds.equals("T"))) || (cdo.getColValue("t_s").equals("3") && fg.equals("FH"))){

				//'LOV_PRODUCTO_X_CDS';

				if(x!=0) sql += " union ";

				if(fg.equals("PAC")){

				sql += "select '"+cdo.getColValue("t_s1")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, a.descripcion, a.cpt trabajo, nvl( getPrecioxAseg ("+v_empresa+", "+(String) session.getAttribute("_companyId")+", '"+cdo.getColValue("t_s1")+"', null, a.codigo, null, null, null, null, null, a.precio, null), a.precio) monto, ' ' habitacion, 0 servicio_hab, a.codigo cds_producto, 0 cod_uso, 0 centro_costo, 0 costo_art, ' ' procedimiento, ' ' otros_cargos, 'N' usar_alert, a.precio precio1, a.precio precio2, nvl(a.incremento, 'S') incremento from tbl_cds_producto_x_cds a where a.cod_centro_servicio = "+cs+" and a.tser = '"+cdo.getColValue("t_s1")+"' and a.estatus = 'A'";

				} else if(fg.equals("FH")){

				sql += "select '"+cdo.getColValue("t_s1")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, a.descripcion, a.cpt trabajo, a.precio monto, ' ' habitacion, 0 servicio_hab, a.codigo cds_producto, 0 cod_uso, 127 centro_costo, decode(a.codigo,73,a.precio,0) costo_art, ' ' procedimiento, ' ' otros_cargos, nvl(b.usar_alert,'N') usar_alert, nvl(b.precio1,0) precio1, nvl(b.precio2,0) precio2, nvl(a.incremento, 'S') incremento, nvl((select porc_farhosp from tbl_sec_compania where codigo = "+(String) session.getAttribute("_companyId")+"),0) porc_farhosp from tbl_cds_producto_x_cds a, (select cod_cds_prod, usar_alert, decode(sign("+edad+"-50),0,decode(precio2, null, precio, precio2),1,decode(precio2, null, precio, precio2),-1,nvl(precio,0)) precio1, decode(sign("+edad+"-50),0,decode(precio2, null, precio, precio2),1,decode(precio2, null, precio, precio2),-1,nvl(precio2,0)) precio2 from tbl_fac_precio_x_aseg where codigo_empresa = "+v_empresa+" and compania = "+(String) session.getAttribute("_companyId")+" and tipo_servicio = '"+cdo.getColValue("t_s1")+"' and centro_servicio = "+cs+") b where a.tser = '"+cdo.getColValue("t_s1")+"' and a.estatus = 'A' and a.codigo = b.cod_cds_prod(+)";
				}
				x++;

			} else if (((cdo.getColValue("t_s").equals("2") || cdo.getColValue("t_s").equals("3") || cdo.getColValue("t_s").equals("4")|| cdo.getColValue("t_s").equals("9")) && tipo_cds.equals("I")) || (cdo.getColValue("t_s").equals("5") && (tipo_cds.equals("I") || tipo_cds.equals("E"))) || ((cdo.getColValue("t_s").equals("16")) && tipo_cds.equals("I")) || ((cdo.getColValue("t_s").equals("16") || cdo.getColValue("t_s").equals("9") || cdo.getColValue("t_s").equals("10"))) || (fp.equals("cargo_dev_pac_sop") && cdo.getColValue("t_s").equals("16") && tipo_cds.equals("I"))){

				//'LOV_USO_EQUIPO';

				if(x!=0) sql += " union ";

				sql += "select '"+cdo.getColValue("t_s1")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, a.descripcion, to_char(a.codigo) trabajo, nvl(getPrecioxAseg ( "+v_empresa+", "+(String) session.getAttribute("_companyId")+", '"+cdo.getColValue("t_s1")+"', null, null, a.codigo, null, null, null, null, a.precio_venta, null) , a.precio_venta) monto, ' ' habitacion, 0 servicio_hab, 0 cds_producto, a.codigo cod_uso, 0 centro_costo, 0 costo_art, ' ' procedimiento, ' ' otros_cargos, 'N' usar_alert, a.precio_venta precio1, a.precio_venta precio2, 'N' incremento from tbl_sal_uso a where compania = "+(String) session.getAttribute("_companyId")+" and tipo_servicio = '"+cdo.getColValue("t_s1")+"' and estatus = 'A'";
				x++;
			} else if (cdo.getColValue("t_s").equals("6") && tipo_cds.equals("I")){//1

				//'LOV_AMBULANCIAS';

				if(x!=0) sql += " union ";

				sql += "select '"+cdo.getColValue("t_s1")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, a.descripcion, to_char(a.codigo) trabajo, nvl(getPrecioxAseg ( "+v_empresa+", "+(String) session.getAttribute("_companyId")+", '"+cdo.getColValue("t_s1")+"', null, null, a.codigo, null, null, null, null, a.precio_venta, null ) , a.precio_venta) monto, ' ' habitacion, 0 servicio_hab, 0 cds_producto, a.codigo cod_uso, 0 centro_costo, 0 costo_art, ' ' procedimiento, ' ' otros_cargos, 'N' usar_alert, a.precio_venta precio1, a.precio_venta precio2, 'N' incremento from tbl_sal_uso a where a.compania = "+(String) session.getAttribute("_companyId")+" and a.tipo_servicio = '"+cdo.getColValue("t_s1")+

				"' union select '"+cdo.getColValue("t_s1")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, a.descripcion, to_char(a.codigo) trabajo, nvl( getPrecioxAseg ("+v_empresa+", "+(String) session.getAttribute("_companyId")+", '06', null, a.codigo, null, null, null, null, null, a.precio, 905), a.precio) monto, ' ' habitacion, 0 servicio_hab, 0 cds_producto, a.codigo cod_uso, a.cod_centro_servicio centro_costo, a.costo costo_art, ' ' procedimiento, ' ' otros_cargos, 'N' usar_alert, a.precio precio1, a.precio precio2, nvl(a.incremento, 'S') incremento from tbl_cds_producto_x_cds a where tser = '06' and cod_centro_servicio = 905";
				x++;

			} else if (cdo.getColValue("t_s").equals("7") && tipo_cds.equals("I")){
//AGREGAR VALIDACION DE LOS CENTROS EN HPP.
				if (cs.equals("15") || cs.equals("66") || cs.equals("113") || cs.equals("114") || cs.equals("115") || cs.equals("116") || cs.equals("118")){

					//'LOV_PROCEDIMIENTOS_REPORTA_A';

					if(x!=0) sql += " union ";

					sql += "select '"+cdo.getColValue("t_s1")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, decode(a.observacion, null, a.descripcion, a.observacion) descripcion, a.codigo trabajo, DECODE(CDSX.NIVEL_PRECIO, 1, nvl( getPrecioxAseg("+v_empresa+", "+(String) session.getAttribute("_companyId")+", '"+cdo.getColValue("t_s1")+"', a.codigo, null, null, null, null, null, null, a.precio, null), a.PRECIO) , 2, NVL(a.PRECIO2,a.PRECIO), 3, NVL(a.PRECIO3,a.PRECIO), 4, NVL(a.PRECIO4,a.PRECIO), 5, NVL(a.PRECIO5,a.PRECIO) ) monto, ' ' habitacion, 0 servicio_hab, 0 cds_producto, 0 cod_uso, 0 centro_costo, 0 costo_art, a.codigo procedimiento, ' ' otros_cargos, 'N' usar_alert, a.precio precio1, a.precio precio2, 'N' incremento from tbl_cds_procedimiento a, ((select distinct reporta_a centro_ser, nivel_precio from tbl_cds_centro_servicio where reporta_a = "+reporta_a+")) cdsx where precio is not null and ((a.cod_cds = cdsx.centro_ser) OR (a.cod_cds2  = cdsx.centro_ser) OR (a.cod_cds3  = cdsx.centro_ser) OR (a.cod_cds4  = cdsx.centro_ser) OR (a.cod_cds5  = cdsx.centro_ser)) and a.estado = 'A' ";
					x++;

				} else {

					//'LOV_PROCEDIMIENTOS_X_CDS';

					if(x!=0) sql += " union ";

					sql += "select '"+cdo.getColValue("t_s1")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, decode(a.observacion, null, a.descripcion, a.observacion) descripcion, a.codigo trabajo,  DECODE(CDSX.NIVEL_PRECIO, 1, nvl( getPrecioxAseg("+v_empresa+", "+(String) session.getAttribute("_companyId")+", '"+cdo.getColValue("t_s1")+"', a.codigo, null, null, null, null, null, null, a.precio, null), a.PRECIO), 2, NVL(a.PRECIO2,a.PRECIO), 3, NVL(a.PRECIO3,a.PRECIO), 4, NVL(a.PRECIO4,a.PRECIO), 5, NVL(a.PRECIO5,a.PRECIO)) monto, ' ' habitacion, 0 servicio_hab, 0 cds_producto, 0 cod_uso, 0 centro_costo, 0 costo_art, a.codigo procedimiento, ' ' otros_cargos, 'N' usar_alert, a.precio precio1, a.precio precio2, 'N' incremento from tbl_cds_procedimiento a,  ((select codigo centro_ser, nivel_precio from tbl_cds_centro_servicio where codigo = "+cs+")) cdsx where a.precio is not null and ((a.cod_cds = cdsx.centro_ser) OR (a.cod_cds2  = cdsx.centro_ser) OR (a.cod_cds3  = cdsx.centro_ser) OR (a.cod_cds4  = cdsx.centro_ser) OR (a.cod_cds5  = cdsx.centro_ser)) and a.estado = 'A'";
					x++;
				}

			} else if (cdo.getColValue("t_s").equals("14")){

				//'LOV_OTROS_CARGOS';

				if(x!=0) sql += " union ";

				sql += "select '"+cdo.getColValue("t_s1")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, a.descripcion, to_char(a.codigo) trabajo, nvl(b.precio,nvl(a.precio, 0)) monto, ' ' habitacion, 0 servicio_hab, 0 cds_producto, 0 cod_uso, 0 centro_costo, 0 costo_art, ' ' procedimiento, to_char(a.codigo) otros_cargos, nvl(b.usar_alert,'N') usar_alert, nvl(b.precio1,0) precio1, nvl(b.precio2,0) precio2, 'N' incremento from tbl_fac_otros_cargos a, (select cod_otro, usar_alert, decode(sign("+edad+"-50),0,decode(precio2, null, precio, precio2),1,decode(precio2, null, precio, precio2),-1,nvl(precio,0)) precio1, decode(sign("+edad+"-50),0,decode(precio2, null, precio, precio2),1,decode(precio2, null, precio, precio2),-1,nvl(precio2,0)) precio2, precio from tbl_fac_precio_x_aseg where codigo_empresa = "+v_empresa+" and compania = "+(String) session.getAttribute("_companyId")+" and tipo_servicio = '"+cdo.getColValue("t_s1")+"') b where a.compania = "+(String) session.getAttribute("_companyId")+" and a.tipo_servicio = '"+cdo.getColValue("t_s1")+"' and a.codigo_tipo is not null and a.activo_inactivo = 'A' and a.codigo = b.cod_otro(+)";
				x++;

			} else if ((cdo.getColValue("t_s").equals("6") ||cdo.getColValue("t_s").equals("12"))&& tipo_cds.equals("I")){

				//'LOV_PROC_EXTERNOS';
				if(!codProv.trim().equals(""))
				{
						if(x!=0) sql += " union ";

						sql += "select '"+cdo.getColValue("t_s1")+"' tipo_servicio, '"+cdo.getColValue("descripcion")+"' tipo_serv_desc, decode(a.observacion,null,descripcion,a.observacion) descripcion, b.cod_proc trabajo, a.precio monto, ' ' habitacion, 0 servicio_hab, 0 cds_producto, 0 cod_uso, 0 centro_costo, b.costo costo_art, b.cod_proc procedimiento, ' ' otros_cargos, nvl(c.usar_alert,'N') usar_alert, nvl(c.precio1,0) precio1, nvl(c.precio2,0) precio2, 'N' incremento from tbl_cds_procedimiento a, tbl_cds_proc_x_cds_x_prov b, (select cod_procedimiento, usar_alert, decode(sign("+edad+"-50),0,decode(precio2, null, precio, precio2),1,decode(precio2, null, precio, precio2),-1,nvl(precio,0)) precio1, decode(sign("+edad+"-50),0,decode(precio2, null, precio, precio2),1,decode(precio2, null, precio, precio2),-1,nvl(precio2,0)) precio2 from tbl_fac_precio_x_aseg where codigo_empresa = "+v_empresa+" and compania = "+(String) session.getAttribute("_companyId")+" and tipo_servicio = '"+cdo.getColValue("t_s1")+"' and centro_servicio = "+cs+") c where b.cod_centro = "+cs+" and b.cod_prov = '"+codProv+"' and a.codigo = b.cod_proc and a.codigo = c.cod_procedimiento(+) and a.estado = 'A'";
						x++;
				}
			}
		}
*/
	}
	else if(tipoTransaccion.equals("D")&& !fg.trim().equals("HON"))
	{
		sbSql = new StringBuffer();
		sbSql.append("select nvl(a.procedimiento,' ') as procedimiento, nvl(''||a.otros_cargos,' ') as otros_cargos, nvl(''||a.cds_producto,' ') as cds_producto, nvl(a.habitacion,' ') as habitacion, nvl(''||a.inv_almacen,' ') as inv_almacen, nvl(''||a.art_familia,' ') as art_familia, nvl(''||a.art_clase,' ') as art_clase, nvl(''||a.inv_articulo,' ') as inv_articulo,'' codBarra, nvl(''||a.cod_uso,' ') as cod_uso, nvl(''||a.cod_paq_x_cds,' ') as cod_paq_x_cds, nvl(a.descripcion,' ') as descripcion, monto, nvl(a.servicio_hab,0) as servicio_hab, nvl(a.centro_costo,0) as centro_costo, nvl(a.costo_art,0) as costo_art, a.tipo_cargo as tipo_servicio, nvl(a.recargo,0) as recargo, to_char(nvl(a.fecha_cargo,sysdate),'dd/mm/yyyy') as fecha_cargo, nvl(a.cod_prod_far,0) as cod_prod_far, nvl(a.pedido_far,0) as pedido_far, case when a.procedimiento is not null then a.procedimiento when a.otros_cargos is not null then ''||a.otros_cargos when a.cds_producto is not null then ''||a.cds_producto when a.habitacion is not null then a.habitacion when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then a.inv_almacen||'-'||a.art_familia||'-'||a.art_clase||'-'||a.inv_articulo when a.cod_uso is not null then ''||a.cod_uso when a.cod_paq_x_cds is not null then ''||a.cod_paq_x_cds else ' ' end as trabajo, nvl(sum(case when a.tipo_transaccion in ('C') then a.cantidad else 0 end),0) as cantidad_cargo, nvl(sum(case when a.tipo_transaccion in ('D') then a.cantidad else 0 end),0) as cantidad_devolucion, nvl(sum(case when a.tipo_transaccion in ('C') then a.cantidad else -1 * a.cantidad end),0) as cantidad_disponible, nvl((select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_cargo),' ') as tipo_serv_desc, case when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then 'S' else 'N' end as inventario, a.centro_servicio,case when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then (select nvl(other3,'Y') from tbl_inv_articulo where cod_Articulo = a.inv_articulo and compania =a.compania) else 'N' end as afecta_inv,a.cama from tbl_fac_detalle_transaccion a where a.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and a.fac_secuencia = ");
		sbSql.append(admiSecuencia);
		sbSql.append(" and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and exists (select * from tbl_fac_transaccion where pac_id = a.pac_id and admi_secuencia = a.fac_secuencia and codigo = a.fac_codigo and tipo_transaccion = a.tipo_transaccion and compania = a.compania and centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(") group by a.cama,a.compania,a.procedimiento, a.otros_cargos, a.cds_producto, a.habitacion, a.inv_almacen, a.art_familia, a.art_clase, a.inv_articulo, '',a.cod_uso, a.cod_paq_x_cds, a.descripcion, a.monto, a.servicio_hab, a.centro_costo, a.costo_art, a.tipo_cargo, a.recargo, a.fecha_cargo, a.cod_prod_far, a.pedido_far, a.centro_servicio having nvl(sum(case when a.tipo_transaccion in ('C') then a.cantidad else -1 * a.cantidad end),0) > 0");
	}
	else if(tipoTransaccion.equals("D")&& fg.trim().equals("HON"))
	{
				sbSql = new StringBuffer();
		sbSql.append("select nvl(a.procedimiento,' ') as procedimiento, nvl(''||a.otros_cargos,' ') as otros_cargos, nvl(''||a.cds_producto,' ') as cds_producto, nvl(a.habitacion,' ') as habitacion, nvl(''||a.inv_almacen,' ') as inv_almacen, nvl(''||a.art_familia,' ') as art_familia, nvl(''||a.art_clase,' ') as art_clase, nvl(''||a.inv_articulo,' ') as inv_articulo,'' codBarra, nvl(''||a.cod_uso,' ') as cod_uso, nvl(''||a.cod_paq_x_cds,' ') as cod_paq_x_cds, nvl(a.descripcion,' ') as descripcion, (monto) as monto, nvl(a.servicio_hab,0) as servicio_hab, nvl(a.centro_costo,0) as centro_costo, nvl(a.costo_art,0) as costo_art, a.tipo_cargo as tipo_servicio, nvl(a.recargo,0) as recargo, to_char(nvl(a.fecha_cargo,sysdate),'dd/mm/yyyy') as fecha_cargo, nvl(a.cod_prod_far,0) as cod_prod_far, nvl(a.pedido_far,0) as pedido_far,'");
		sbSql.append(noDoc);
		sbSql.append("'");
		sbSql.append("||a.honorario_por as trabajo, nvl(sum(case when a.tipo_transaccion in ('C','H') then a.cantidad else 0 end),0) as cantidad_cargo, nvl(sum(case when a.tipo_transaccion in ('D') then a.cantidad else 0 end),0) as cantidad_devolucion, nvl(sum(case when a.tipo_transaccion in ('C','H') then a.cantidad else -1 * a.cantidad end),0) as cantidad_disponible, nvl((select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_cargo),' ') as tipo_serv_desc,'N' as inventario, a.centro_servicio,a.honorario_por,'N'  afecta_inv, null as cama from tbl_fac_detalle_transaccion a where a.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and a.fac_secuencia = ");
		sbSql.append(admiSecuencia);
		sbSql.append(" and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and exists (select * from tbl_fac_transaccion where pac_id = a.pac_id and admi_secuencia = a.fac_secuencia and codigo = a.fac_codigo and tipo_transaccion = a.tipo_transaccion and compania = a.compania and centro_servicio = ");
		sbSql.append(cs);
		sbSql.append(" and decode (nvl(pagar_sociedad,'N'),  'N',med_codigo,  'S', to_char(empre_codigo)) = '");
		sbSql.append(codHonorario);
		sbSql.append("' ");
		//noDoc=2398477674
		if(!noDoc.trim().equals("")){sbSql.append(" and no_documento ='"); sbSql.append(noDoc); sbSql.append("'"); }
		sbSql.append(" )");

		sbSql.append(" group by '");
		sbSql.append(noDoc);
		sbSql.append("'");
		sbSql.append("||a.honorario_por,to_char(nvl(a.fecha_cargo,sysdate),'dd/mm/yyyy'),nvl(a.procedimiento,' '), nvl(''||a.otros_cargos,' '), nvl(''||a.cds_producto,' '), nvl(a.habitacion,' '), nvl(''||a.inv_almacen,' '), nvl(''||a.art_familia,' '), nvl(''||a.art_clase,' '), nvl(''||a.inv_articulo,' '),'',nvl(''||a.cod_paq_x_cds,' '),nvl(a.servicio_hab,0),  nvl(a.centro_costo,0), nvl(a.costo_art,0), a.tipo_cargo,a.centro_servicio,a.honorario_por ,a.centro_servicio,nvl(a.recargo,0), nvl(a.cod_prod_far,0), nvl(a.pedido_far,0),case when a.procedimiento is not null then a.procedimiento when a.otros_cargos is not null then ''||a.otros_cargos when a.cds_producto is not null then ''||a.cds_producto when a.habitacion is not null then a.habitacion when a.inv_almacen is not null and a.art_familia is not null and a.art_clase is not null and a.inv_articulo is not null then a.inv_almacen||'-'||a.art_familia||'-'||a.art_clase||'-'||a.inv_articulo when a.cod_uso is not null then ''||a.cod_uso when a.cod_paq_x_cds is not null then ''||a.cod_paq_x_cds else ' ' end,nvl(''||a.cod_uso,' ') ,nvl(a.descripcion,' '), monto having nvl(sum(case when a.tipo_transaccion in ('C','H') then a.cantidad else -1 * a.cantidad end),0) > 0");

	}
	if (sbSql.length() > 0)
	{
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a "+sbFilter+" order by tipo_serv_desc, descripcion) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+") "+sbFilter);
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
document.title = 'Centro de Servicio - '+document.title;

function chkValues(){
	var size = parseInt(document.detail.keySize.value);
	for(i=0;i<size;i++){
		chkValue(i);
	}
	return true;
}

function chkValue(i){
	var cantidad				= parseInt(eval('document.detail.cantidad'+i).value,10);
	var cant_cargo				= parseInt(eval('document.detail.cant_cargo'+i).value,10);
	var cant_devolucion		= parseInt(eval('document.detail.cant_devolucion'+i).value,10);
	var cant_disponible		= parseInt(eval('document.detail.cantidad_disponible'+i).value,10);
	if(cantidad > (cant_cargo-cant_devolucion)){
		alert('La cantidad a devolver excede la cantidad del cargo...,VERIFIQUE!');
		eval('document.detail.cantidad'+i).value = 0;
		eval('document.detail.cantidad'+i).select();
	} else if (cantidad > cant_disponible){
		alert('La cantidad excede la cantidad disponible...,VERIFIQUE!');
		eval('document.detail.cantidad'+i).value = 0;
		eval('document.detail.cantidad'+i).select();
	}
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
			alert('La cantidad excede la cantidad disponible...,VERIFIQUE!'+cant_disponible);
			eval('document.detail.cantidad'+i).value = 0;
			eval('document.detail.cantidad'+i).select();
			eval('document.detail.chkServ'+i).checked= false;
		}
	}
	<%}%>
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
	<jsp:param name="fieldsToBeCleared" value="tipoServicio,trabajo,descripcion"></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE SERVICIOS POR CENTRO DE SERVICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
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
<%=fb.hidden("noDoc",noDoc)%>
			<td width="35%">
				<cellbytelabel>Tipo Servicio</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select a.tipo_servicio, (select descripcion from tbl_cds_tipo_servicio where codigo=a.tipo_servicio)||' - '||a.tipo_servicio as descripcion, a.tipo_servicio from tbl_cds_servicios_x_centros a where a.centro_servicio="+cs+" and a.visible_centro ='S' and exists (select tipo_servicio from tbl_cds_tipo_servicio where codigo = a.tipo_servicio) order by 2 desc","tipoServicio",tipoServicio,false,false,0,"Text10",null,null,null,"T")%>
			</td>
			<%if(!fg.trim().equals("HON")){%><td width="12%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("trabajo",trabajo,false,false,false,20,"Text10",null,null)%>
			</td>
			<td width="53%">
				<cellbytelabel>Desc. de Cargo</cellbytelabel>
				<%=fb.textBox("descripcion",descripcion,false,false,false,30,"Text10",null,null)%>
				<%=fb.submit("go","Ir")%>
				<span style="display:<%=(almacen.equals("")?"none":"")%>;">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>C&oacute;d Barra</cellbytelabel>
				<%=fb.textBox("barcode",barCode,false,false,false,15,"ignore",null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"")%></span>
			</td><%}else{%>
			<td width="53%"><%=fb.submit("go","Ir")%></td>
			<%}%>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("noDoc",noDoc)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
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
<%=fb.hidden("noDoc",noDoc)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
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
<%=fb.hidden("noDoc",noDoc)%>
		<tr>
			<td align="right" colspan="6"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel>Servicio</cellbytelabel></td>
			<%if(fp.equals("cargo_dev_pac") && tipoTransaccion.equals("D")){%>
			<td width="23%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
			<%}else{%>
			<td width="33%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<%}%>
			<td width="8%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="33%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Precio Unitario</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Cant</cellbytelabel>.</td>
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

<%
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	String key = "";
	String cargoKey = "";

	if(tipoTransaccion.equals("D"))cargoKey =cdo.getColValue("fecha_cargo")+"_";
	cargoKey  += cdo.getColValue("tipo_servicio") +"_"+cdo.getColValue("trabajo");
	String onChange = "onFocus=\"this.select();\" onChange=\"javascript:setChecked(this,document.detail.chkServ"+i+"); "+((tipoTransaccion.equals("D") && almacen != null && !almacen.trim().equals("")||(tipoTransaccion.equals("D") && fg.trim().equals("HON")))?" chkValue("+i+");":"chkDisp("+i+");")+"\"";


	//System.out.println("cargoKey = *************************************= "+cargoKey);
	if(fTranCargKey.containsKey(cargoKey)) key = (String) fTranCargKey.get(cargoKey);
	//System.out.println("key = "+key);
	if (fTranCarg.containsKey(key)){
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
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
		</tr>
<%
	} else {
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("tipo_servicio")%></td>
			<td>&nbsp;<%=cdo.getColValue("tipo_serv_desc")%></td>
			<%if(fp.equals("cargo_dev_pac") && tipoTransaccion.equals("D")){%>
			<td align="center"><%=cdo.getColValue("fecha_cargo")%></td>
			<%}%>
			<% if(cdo.getColValue("trabajo").indexOf("--")!=-1){ %>
			<td bgcolor="#FFFFFF" align="center"><%=cdo.getColValue("trabajo")%></td>
			<% }else{ %>
			<td align="center"><%=cdo.getColValue("trabajo")%></td>
			<% } %>
			<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
			<td align="right">
			<%
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
			}
			%>
			</td>
			<td align="center">
			<%=fb.intBox("cantidad"+i,(fg.trim().equals("HON"))?cdo.getColValue("cantidad_disponible"):"0",true,false,false,5,"","",onChange)%>
			</td>
			<td align="center">
			<%=(tipoTransaccion.equalsIgnoreCase("C") && (cdo.getColValue("inventario").equalsIgnoreCase("S")&& cdo.getColValue("afecta_inv").equalsIgnoreCase("Y")&& cdo.getColValue("cantidad_disponible").equals("0"))&&((cdoParam.getColValue("valida_dsp").trim().equals("S"))))?"":fb.checkbox("chkServ"+i,""+i,false,false,"","",onCheck)%>
			</td>
		</tr>
<%
	}
}
if(al.size()==0){
%>
		<tr align="center">
			<td colspan="6"><cellbytelabel>No Registros Encontrados</cellbytelabel></td>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
		</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("noDoc",noDoc)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("noDoc",noDoc)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	int lineNo = FTransDet.getFTransDetail().size();
	String artDel = "", key = "";
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
		if(request.getParameter("fecha_cargo"+i)!=null && !request.getParameter("fecha_cargo"+i).equals("")&& !request.getParameter("fecha_cargo"+i).equals("_")) fechaCargo = request.getParameter("fecha_cargo"+i);

		det.setFechaCargo(fechaCargo);// hh12:mi:ss am

		if(request.getParameter("habitacion"+i)!=null && !request.getParameter("habitacion"+i).equals("null") && !request.getParameter("habitacion"+i).equals("")) det.setHabitacion(request.getParameter("habitacion"+i));
		//else det.setHabitacion("0");
		if(request.getParameter("servicio_hab"+i)!=null && !request.getParameter("servicio_hab"+i).equals("null") && !request.getParameter("servicio_hab"+i).equals("")) det.setServicioHab(request.getParameter("servicio_hab"+i));
		//else det.setServicioHab("0");
		if(request.getParameter("cds_producto"+i)!=null && !request.getParameter("cds_producto"+i).equals("null") && !request.getParameter("cds_producto"+i).equals("")) det.setCdsProducto(request.getParameter("cds_producto"+i));
		//else det.set("0");
		if(request.getParameter("cod_uso"+i)!=null && !request.getParameter("cod_uso"+i).equals("null") && !request.getParameter("cod_uso"+i).equals("")) det.setCodUso(request.getParameter("cod_uso"+i));
		//else det.setCodUso("0");
		if(request.getParameter("centro_costo"+i)!=null && !request.getParameter("centro_costo"+i).equals("null") && !request.getParameter("centro_costo"+i).equals("")) det.setCentroCosto(request.getParameter("centro_costo"+i));
		//else det.setCentoCosto("0");
		if(request.getParameter("costo_art"+i)!=null && !request.getParameter("costo_art"+i).equals("null") && !request.getParameter("costo_art"+i).equals("")) det.setCostoArt(request.getParameter("costo_art"+i));
		//else det.setCostoArt("0");
		if(request.getParameter("procedimiento"+i)!=null && !request.getParameter("procedimiento"+i).equals("null") && !request.getParameter("procedimiento"+i).equals("")) det.setProcedimiento(request.getParameter("procedimiento"+i));
		//else det.setProcedimiento("0");
		if(request.getParameter("otros_cargos"+i)!=null && !request.getParameter("otros_cargos"+i).equals("null") && !request.getParameter("otros_cargos"+i).equals("") && !request.getParameter("otros_cargos"+i).equals("0")) det.setOtrosCargos(request.getParameter("otros_cargos"+i));
		//else det.setOtrosCargos("0");
		if(request.getParameter("recargo"+i)!=null && !request.getParameter("recargo"+i).equals("null") && !request.getParameter("recargo"+i).equals("")) det.setRecargo(request.getParameter("recargo"+i));
		//else det.setRecargo("0");

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

			try {
				fTranCarg.put(key, det);
				if(tipoTransaccion.equals("D"))
				fTranCargKey.put(det.getFechaCargo()+"_"+det.getTipoCargo()+"_"+det.getTrabajo(), key);
				else fTranCargKey.put(det.getTipoCargo()+"_"+det.getTrabajo(), key);
				FTransDet.getFTransDetail().add(det);
				System.out.println("adding item "+key+" _ "+det.getTipoCargo()+"_"+det.getTrabajo());
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
			if(cargarCAut.trim().equals("S")){
			if(det.getCama() != null && !det.getCama().trim().equals("")&& !det.getCama().trim().equals("null") && tipoTransaccion.trim().equals("C") )
			{

			sbSql = new StringBuffer();
			sbSql.append(" select cau.tipo_servicio,(select descripcion from tbl_cds_tipo_servicio where codigo=cau.tipo_servicio) as tipo_serv_desc, nvl(decode(cau.tipo_referencia,'US',(select descripcion from tbl_sal_uso where codigo=cau.codigo_item ),'AR',(select descripcion from tbl_inv_articulo where compania=cau.compania and cod_articulo=cau.codigo_item)),0) descripcion,''||cau.codigo_item as trabajo,coalesce(getprecio(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",(select clasif_cargo from tbl_cds_tipo_servicio where codigo=cau.tipo_servicio),cau.codigo_item,");
				sbSql.append(v_empresa);
				sbSql.append(",");
				sbSql.append(cs);
				sbSql.append(",");
				sbSql.append(cat);
				sbSql.append("), nvl(decode(cau.tipo_referencia,'US',(select precio_venta from tbl_sal_uso where codigo=cau.codigo_item),'AR',(select precio_venta from tbl_inv_articulo where compania=cau.compania and cod_articulo=cau.codigo_item)),0),0) as monto,' ' as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab, cau.almacen inv_almacen, cau.familia as art_familia, cau.clase as art_clase,  decode(cau.tipo_referencia,'AR',cau.codigo_item,null) inv_articulo,'' codBarra, decode(cau.tipo_referencia,'US',cau.codigo_item,null) as cod_uso, decode(cau.tipo_referencia,'AR',(select nvl(i.precio,0) costo from tbl_inv_inventario i where i.codigo_almacen = cau.almacen and i.compania =cau.compania and i.cod_articulo = cau.codigo_item ),0) as costo_art, 'N' as incremento, 'N' as inventario, 0 as cantidad_disponible, 0 as centro_costo,'N' afecta_inv,null cama ,1 as cantidad ,'C' from tbl_sal_cargos_automaticos cau  where cau.compania =");
				 sbSql.append(session.getAttribute("_companyId"));
								 sbSql.append(" and cau.cama = '");
				 sbSql.append(det.getCama());
				 sbSql.append("' and cau.habitacion ='");
				 sbSql.append(det.getHabitacion());
								 sbSql.append("' and cau.estado ='A'");

				//Condision para las devoluciones

				 al = SQLMgr.getDataList(sbSql.toString());

		for(int z=0; z<al.size(); z++){
			CommonDataObject cdo = (CommonDataObject) al.get(z);
			FactDetTransaccion det2 = new FactDetTransaccion();

			det2.setTipoCargo(cdo.getColValue("tipo_servicio"));
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
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;

			try {
				fTranCarg.put(key, det2);
				if(tipoTransaccion.equals("D"))
				fTranCargKey.put(det.getFechaCargo()+"_"+det2.getTipoCargo()+"_"+det2.getTrabajo(), key);
				else fTranCargKey.put(det2.getTipoCargo()+"_"+det2.getTrabajo(), key);
				FTransDet.getFTransDetail().add(det2);

			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		}
		}//cargarCAut
			}

		}
	}
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_servicios_x_centro.jsp?mode="+mode+"&change=1&type=1&fg="+fg+"&fp="+fp+"&cs="+cs+"&tipo_cds="+tipo_cds+"&reporta_a="+reporta_a+"&incremento="+incremento+"&tipoInc="+tipoInc+"&edad="+edad+"&v_empresa="+v_empresa+"&tipoTransaccion="+tipoTransaccion+"&cat="+cat+"&codProv="+codProv+"&almacen="+almacen+"&clasificacion="+request.getParameter("clasificacion")+"&codPaciente="+request.getParameter("codPaciente")+"&fechaNac="+request.getParameter("fechaNac")+"&admiSecuencia="+request.getParameter("admiSecuencia")+"&tipoServicio="+request.getParameter("tipoServicio")+"&pacId="+request.getParameter("pacId")+"&codHonorario="+request.getParameter("codHonorario")+"&urlEscapeChars="+request.getParameter("urlEscapeChars")+"&noDoc="+request.getParameter("noDoc"));

		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if(fp!= null && fp.equals("cargo_dev_pac")){%>
	window.opener.location = '<%=request.getContextPath()+"/facturacion/reg_cargo_dev_det.jsp?change=1&mode="+mode%>&fg=<%=fg%>&fp=<%=fp%>&cs=<%=cs%>&tipo_cds=<%=tipo_cds%>&reporta_a=<%=reporta_a%>&incremento=<%=incremento%>&tipoInc=<%=tipoInc%>&edad=<%=edad%>&v_empresa=<%=v_empresa%>&tipoTransaccion=<%=tipoTransaccion%>&cat=<%=cat%>&codProv=<%=codProv%>';
	<%}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
