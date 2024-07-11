<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.convenio.CoberturaDetalle"%>
<%@ page import="issi.convenio.ExclusionDetalle"%>
<%@ page import="issi.admision.CoberturaDetalladaServicio"%>
<%@ page import="issi.admision.CdsSolicitudDetalle"%>
<%@ page import="issi.admision.CitaProcedimiento"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iProce" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vProce" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iCobCD" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCobCD" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iExclCD" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vExclCD" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iCobDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCobDet" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iExclDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vExclDet" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iProc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vProc" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iCPT" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCPT" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iCPTMapping" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCPTMapping" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iPaqProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPaqProc" scope="session" class="java.util.Vector" />
<jsp:useBean id="iProcPC" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vProcPC" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iProcInTra" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProcInTra" scope="session" class="java.util.Vector" />
<jsp:useBean id="iProcOpe" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vProcOpe" scope="session" class="java.util.Vector"/>
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

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
StringBuffer xCdsFilter = new  StringBuffer();
StringBuffer sbFilter = new  StringBuffer();
StringBuffer sbSql = new  StringBuffer();
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String empresa = request.getParameter("empresa");
int tServLastLineNo = 0;
int userLastLineNo = 0;
int tAdmLastLineNo = 0;
int pamLastLineNo = 0;
int procLastLineNo = 0;
int docLastLineNo = 0,diagPreLastLineNo=0,diagPostLastLineNo=0,whLastLineNo=0,CPTlastLineNo=0,cptLastLineNoMapping=0, paqProcLastLineNo=0;
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (mode == null) mode = "add";

if (request.getParameter("tServLastLineNo") != null) tServLastLineNo = Integer.parseInt(request.getParameter("tServLastLineNo"));
if (request.getParameter("userLastLineNo") != null) userLastLineNo = Integer.parseInt(request.getParameter("userLastLineNo"));
if (request.getParameter("tAdmLastLineNo") != null) tAdmLastLineNo = Integer.parseInt(request.getParameter("tAdmLastLineNo"));
if (request.getParameter("pamLastLineNo") != null) pamLastLineNo = Integer.parseInt(request.getParameter("pamLastLineNo"));
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));
if (request.getParameter("diagPostLastLineNo") != null) diagPostLastLineNo = Integer.parseInt(request.getParameter("diagPostLastLineNo"));
if (request.getParameter("diagPreLastLineNo") != null) diagPreLastLineNo = Integer.parseInt(request.getParameter("diagPreLastLineNo"));
if (request.getParameter("whLastLineNo") != null) whLastLineNo = Integer.parseInt(request.getParameter("whLastLineNo"));
if (request.getParameter("CPTlastLineNo") != null) CPTlastLineNo = Integer.parseInt(request.getParameter("CPTlastLineNo"));
if (request.getParameter("cptLastLineNoMapping") != null) cptLastLineNoMapping = Integer.parseInt(request.getParameter("cptLastLineNoMapping"));
if (request.getParameter("paqProcLastLineNo") != null) paqProcLastLineNo = Integer.parseInt(request.getParameter("paqProcLastLineNo"));

//convenio_cobertura_centro, convenio_exclusion_centro
String tab = request.getParameter("tab");
String cTab = request.getParameter("cTab");
//String empresa = request.getParameter("empresa");
String secuencia = request.getParameter("secuencia");
String tipoPoliza = request.getParameter("tipoPoliza");
String tipoPlan = request.getParameter("tipoPlan");
String planNo = request.getParameter("planNo");
String categoriaAdm = request.getParameter("categoriaAdm");
String tipoAdm = request.getParameter("tipoAdm");
String clasifAdm = request.getParameter("clasifAdm");
String tipoCE = request.getParameter("tipoCE");
String ce = request.getParameter("ce");
String index = request.getParameter("index");
String modalize = request.getParameter("modalize");
int ceCDLastLineNo = 0;
String tipoServicio = request.getParameter("tipoServicio");
//convenio solicitud de beneficio
String pac_id = request.getParameter("pac_id");
String cod_pac = request.getParameter("cod_pac");
String admision = request.getParameter("admision");
String fecha_nacimiento = request.getParameter("fecha_nacimiento");
String secuencia_cob = request.getParameter("secuencia_cob");
String secuencia_sol1= request.getParameter("secuencia_sol1");
String secuencia_sol2= request.getParameter("secuencia_sol2");
String solicitud = request.getParameter("solicitud");
String revenueId = request.getParameter("revenueId")==null?"0":request.getParameter("revenueId");
String citasSopAdm = request.getParameter("citasSopAdm")==null?"":request.getParameter("citasSopAdm");
String citasAmb = request.getParameter("citasAmb")==null?"":request.getParameter("citasAmb");
String exp = request.getParameter("exp")==null?"":request.getParameter("exp");
String fg = request.getParameter("fg")==null?"":request.getParameter("fg");
String modeSec = request.getParameter("modeSec")==null?"":request.getParameter("modeSec");
if (id == null) id = "";
if (tab == null) tab = "";
if (cTab == null) cTab = "";
if (empresa == null) empresa = "";
if (secuencia == null) secuencia = "";
if (tipoPoliza == null) tipoPoliza = "";
if (tipoPlan == null) tipoPlan = "";
if (planNo == null) planNo = "";
if (categoriaAdm == null) categoriaAdm = "";
if (tipoAdm == null) tipoAdm = "";
if (clasifAdm == null) clasifAdm = "";
if (tipoCE == null) tipoCE = "";
if (ce == null) ce = "";
if (index == null) index = "";
if (request.getParameter("ceCDLastLineNo") != null) ceCDLastLineNo = Integer.parseInt(request.getParameter("ceCDLastLineNo"));
if (tipoServicio == null) tipoServicio = "";
if (modalize == null) modalize = "";

//convenio_cobertura_detalle, pm_convenio_cobertura_detalle, convenio_exclusion_detalle, pm_convenio_exclusion_detalle
int ceDetLastLineNo = 0;
String centroServicio = request.getParameter("centroServicio");
String tipoCds = request.getParameter("tipoCds");
String inventarioSino = request.getParameter("inventarioSino");
String flagCds = request.getParameter("flagCds");

if (request.getParameter("ceDetLastLineNo") != null) ceDetLastLineNo = Integer.parseInt(request.getParameter("ceDetLastLineNo"));
if (centroServicio == null) centroServicio = "";
if (tipoCds == null) tipoCds = "";
if (inventarioSino == null) inventarioSino = "";
if (flagCds== null) flagCds = "";


//cds_solicitud_rayx_lab_ped, cds_solicitud_lab_ext, cds_solicitud_ima
String codigo = request.getParameter("codigo");
String cds = request.getParameter("cds");
String clasificacion = request.getParameter("clasificacion");
String cambioPrecio = request.getParameter("cambioPrecio");
String descuento = request.getParameter("descuento");
String cupon = request.getParameter("cupon");
String cdsReportaA = request.getParameter("cdsReportaA");
String cdsTipo = request.getParameter("cdsTipo");
String tipoSolicitud = request.getParameter("tipoSolicitud");
String seccion = request.getParameter("seccion");
String tipoProfil = request.getParameter("tipoProfil");

if (codigo == null) codigo = "";
if (cds == null) cds = "";
if (clasificacion == null) clasificacion = "";
if (cambioPrecio == null) cambioPrecio = "N";
if (descuento == null) descuento = "N";
if (cupon == null) cupon = "N";
if (cdsReportaA == null) cdsReportaA = "";
if (cdsTipo == null) cdsTipo = "";
if (tipoSolicitud == null) tipoSolicitud = "P";
if (tipoProfil == null) tipoProfil = "";

//citas || citasimagenologia
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String persLastLineNo = request.getParameter("persLastLineNo");
String equiLastLineNo = request.getParameter("equiLastLineNo");
if (codCita == null) codCita = "";
if (fechaCita == null) fechaCita = "";
if (persLastLineNo == null) persLastLineNo = "0";
if (equiLastLineNo == null) equiLastLineNo = "0";
if (cds.trim().equals("") && (fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("citasimagenologia"))) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");

//protocolo
String desc = request.getParameter("desc");
if ( desc == null ) desc = "";
String perfilCpt= "N";
try {perfilCpt =java.util.ResourceBundle.getBundle("issi").getString("perfilCpt");}catch(Exception e){ perfilCpt = "N";}
String profileCPT = (request.getParameter("profileCPT")==null?"":request.getParameter("profileCPT"));
String change = request.getParameter("change");
sbSql.append("select nvl(get_sec_comp_param(-1,'ADM_SOL_PROC_ADD'),'N') as refreshPage from dual");
CommonDataObject cdoH = SQLMgr.getData(sbSql.toString());
String refresh = cdoH.getColValue("refreshPage");
String cdsFiltro=request.getParameter("cdsFiltro")==null?cds:request.getParameter("cdsFiltro");

	sbSql = new StringBuffer();

if (request.getMethod().equalsIgnoreCase("GET"))
{
		int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	String code = request.getParameter("code");
	String barcode = request.getParameter("barcode");
	String name = request.getParameter("name");
	String tipoProc=request.getParameter("tipoProc");
	if (code == null) code = "";
	if (barcode == null) barcode = "";
	if (name == null) name = "";
	if (tipoProc == null) tipoProc = "";
	if (!barcode.trim().equals("")) appendFilter += " and upper(a.codigo) like '"+request.getParameter("barcode").toUpperCase()+"'";
	if (!code.trim().equals("")) appendFilter += " and upper(a.codigo) like '%"+request.getParameter("code").toUpperCase()+"%'";
	if (!name.trim().equals("")) appendFilter += " and coalesce(a.observacion,a.descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";
	if (!tipoProc.trim().equals("")) appendFilter += " and a.tipo_categoria ='"+request.getParameter("tipoProc")+"'";

	/*---------------------------------------------------------------------------------------------*/
	/*QUERYS DE LAS FUNCIONES USADAS PARA OBTENER EL PRECIO Y SABER SI SE TRATA DE PRECIO DE OFERTA*/
	/*---------------------------------------------------------------------------------------------*/

	StringBuffer precioWOAs = new StringBuffer();
	precioWOAs.append("coalesce(getPrecio(");
	precioWOAs.append(session.getAttribute("_companyId"));
	precioWOAs.append(", 7, a.codigo, ");
	if (empresa == null || empresa.trim().equals("")) precioWOAs.append("null");
	else precioWOAs.append(empresa);
	precioWOAs.append(", ");
	if (fp.equalsIgnoreCase("cds_references") || fp.equalsIgnoreCase("convenio_cobertura_centro") || fp.equalsIgnoreCase("convenio_exclusion_centro") || fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle")  || fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle") || fp.equalsIgnoreCase("convenio_cobertura_detSol")||fp.equalsIgnoreCase("convenio_cobertura_solicitud")) precioWOAs.append("null");
	else precioWOAs.append("c.cod_centro_servicio");
	precioWOAs.append(", ");
	if (categoriaAdm == null || categoriaAdm.trim().equals("")) precioWOAs.append("null");
	else precioWOAs.append(categoriaAdm);
	precioWOAs.append("),a.precio,0)");
	String precio = precioWOAs+" precio";

	StringBuffer oferta = new StringBuffer();
	oferta.append("nvl(verOferta(");
	oferta.append(session.getAttribute("_companyId"));
	oferta.append(", 7, a.codigo, ");
	if (empresa == null || empresa.trim().equals("")) oferta.append("null");
	else oferta.append(empresa);
	oferta.append(",c.cod_centro_servicio,");
	if (categoriaAdm == null || categoriaAdm.trim().equals("")) oferta.append("null");
	else oferta.append(categoriaAdm);
	oferta.append("), 'N') oferta");

	String recargo = "nvl(getRecargo("+admision+",c.cod_centro_servicio, "+precioWOAs+", "+pac_id+"), 0) recargo";

	/*---------------------------------------------------------------------------------------------*/
	if (fp.equalsIgnoreCase("cds_references") || fp.equalsIgnoreCase("convenio_cobertura_centro") || fp.equalsIgnoreCase("convenio_exclusion_centro") || fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle")  || fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle") || fp.equalsIgnoreCase("convenio_cobertura_detSol")||fp.equalsIgnoreCase("convenio_cobertura_solicitud")) {
		sbSql = new StringBuffer();
		sbSql.append("SELECT a.codigo, coalesce(a.observacion,a.descripcion) as descripcion, b.nombre as tipoCategoriaDesc, ");
		sbSql.append(precio);
		sbSql.append(", nvl(a.costo,0) as costo FROM tbl_cds_procedimiento a, tbl_cds_tipo_categoria b WHERE a.tipo_categoria=b.codigo and a.estado = 'A' ");
		sbSql.append(appendFilter.toString());
		if (fp.equalsIgnoreCase("convenio_cobertura_solicitud")){sbSql.append(" and a.cod_cds =");sbSql.append(centroServicio);}
		sbSql.append(" order by coalesce(a.observacion,a.descripcion)");

	}	else if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped"))	{
		//cds400019_copia
		sbSql = new StringBuffer();
		if(profileCPT.trim().equals("")){if(cds.trim().equals("")||cds.trim().equals("0"))throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");}
			String 	appendFields = ", "+precio+", "+oferta+", "+recargo;
			sbSql.append("select distinct a.codigo, coalesce(a.observacion,a.descripcion) as descripcion, a.tipo_categoria, b.nombre as tipoCategoriaDesc, coalesce(a.costo,0) as costo");
			sbSql.append(appendFields);
			//if(!profileCPT.trim().equals(""))
			sbSql.append(",(select descripcion from tbl_cds_centro_servicio where codigo = c.cod_centro_servicio)cds_desc");
			sbSql.append(", c.cod_centro_servicio cds from tbl_cds_procedimiento a, tbl_cds_tipo_categoria b, tbl_cds_procedimiento_x_cds c where a.precio is not null and a.estado = 'A' and a.tipo_categoria = b.codigo and a.codigo = c.cod_procedimiento ");

			if(profileCPT.trim().equals(""))
			{
			 sbSql.append(" and (c.cod_centro_servicio = ");
			 sbSql.append(cds);
			 sbSql.append(")");
			 //sbSql.append(" or exists (select null from tbl_cds_centro_servicio where codigo = c.cod_centro_servicio and reporta_a = ");
			 //sbSql.append(cds);
			 //sbSql.append("))");
			}
			else  {
				sbSql.append(" and c.cod_centro_servicio in (select  cds.cod_centro_servicio from tbl_cds_procedimiento_x_cds cds ,tbl_cdc_cpt_x_profiles a where cds.cod_procedimiento = a.id_cpt and cds.cod_centro_servicio = a.cod_cds and a.id_profile =");
				sbSql.append(profileCPT);
				sbSql.append("  and a.id_cpt=a.codigo )");
				sbSql.append(" and c.cod_procedimiento in (select  cds.cod_procedimiento from tbl_cds_procedimiento_x_cds cds ,tbl_cdc_cpt_x_profiles a where cds.cod_procedimiento = a.id_cpt and cds.cod_centro_servicio = a.cod_cds and a.id_profile =");
				sbSql.append(profileCPT);
				sbSql.append(")");}

			sbSql.append(appendFilter);

			sbSql.append(" union ");
			sbSql.append("select a.codigo, coalesce(a.observacion,a.descripcion) as descripcion, a.tipo_categoria, b.nombre as tipoCategoriaDesc, coalesce(a.costo,0) as costo");
			sbSql.append(appendFields);
			//if(!profileCPT.trim().equals(""))
			sbSql.append(",(select descripcion from tbl_cds_centro_servicio where codigo = c.cod_centro_servicio)cds_desc");
			sbSql.append(", c.cod_centro_servicio cds from tbl_cds_procedimiento a, tbl_cds_tipo_categoria b, tbl_cds_procedimiento_x_cds c where a.precio is not null and a.estado = 'A' and a.tipo_categoria = b.codigo and a.codigo = c.cod_procedimiento");

			if(profileCPT.trim().equals(""))
			{ sbSql.append(" and exists (select null from tbl_cds_centro_servicio where codigo = c.cod_centro_servicio and reporta_a = ");
			sbSql.append(cds);
			sbSql.append(") and not exists (select null from tbl_cds_procedimiento_x_cds where cod_centro_servicio = ");
			sbSql.append(cds);
			sbSql.append(" and cod_procedimiento = c.cod_procedimiento)");
			}else{
			 sbSql.append(" and c.cod_centro_servicio in (select  cds.cod_centro_servicio from tbl_cds_procedimiento_x_cds cds ,tbl_cdc_cpt_x_profiles a where cds.cod_procedimiento = a.id_cpt and cds.cod_centro_servicio = a.cod_cds and a.id_profile =");
				sbSql.append(profileCPT);
				sbSql.append("  and a.id_cpt=a.codigo)");
				sbSql.append(" and c.cod_procedimiento in (select  cds.cod_procedimiento from tbl_cds_procedimiento_x_cds cds ,tbl_cdc_cpt_x_profiles a where cds.cod_procedimiento = a.id_cpt and cds.cod_centro_servicio = a.cod_cds and a.id_profile =");
				sbSql.append(profileCPT);
				sbSql.append(")");}

			sbSql.append(appendFilter);

			sbSql.append(" order by  9 asc, 2");


	}	else if (fp.equalsIgnoreCase("cds_solicitud_lab_ext")){
		if (cds.trim().equals("")) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");
		String 	appendFields = ", "+precio+", "+oferta+", "+recargo;
		sbSql = new StringBuffer();
		sbSql.append("select distinct a.codigo, coalesce(a.observacion,a.descripcion) as descripcion, a.tipo_categoria, b.nombre as tipoCategoriaDesc, coalesce(a.costo,0) as costo");
		sbSql.append(appendFields);
		sbSql.append(" from tbl_cds_procedimiento a, tbl_cds_tipo_categoria b, tbl_cds_procedimiento_x_cds c where a.precio is not null and a.estado = 'A' and a.tipo_categoria = b.codigo and a.codigo = c.cod_procedimiento");

		 sbSql.append(" and (c.cod_centro_servicio = ");
		 sbSql.append(cds);
		 sbSql.append(" or exists (select null from tbl_cds_centro_servicio where codigo = c.cod_centro_servicio and reporta_a = ");
		 sbSql.append(cds);
		 sbSql.append("))");
		 sbSql.append(appendFilter);

	}else if (fp.equalsIgnoreCase("cds_solicitud_ima")) {
	sbSql = new StringBuffer();
	xCdsFilter.append(" and (c.cod_centro_servicio = ");
	xCdsFilter.append(cds);
	xCdsFilter.append(" or exists (select null from tbl_cds_centro_servicio where codigo = c.cod_centro_servicio and reporta_a = ");
	xCdsFilter.append(cds);
	xCdsFilter.append("))" );
		if (!profileCPT.trim().equals(""))
		{
			sbFilter.append(" and c.cod_centro_servicio in (select  cds.cod_centro_servicio from tbl_cds_procedimiento_x_cds cds ,tbl_cdc_cpt_x_profiles a where cds.cod_procedimiento = a.id_cpt and cds.cod_centro_servicio = a.cod_cds and a.id_profile =");
			sbFilter.append(profileCPT);
			sbFilter.append(" and a.id_cpt=a.codigo )");
			sbFilter.append(" and c.cod_procedimiento in (select  cds.cod_procedimiento from tbl_cds_procedimiento_x_cds cds ,tbl_cdc_cpt_x_profiles a where cds.cod_procedimiento = a.id_cpt and cds.cod_centro_servicio = a.cod_cds and a.id_profile =");
			sbFilter.append(profileCPT);
			sbFilter.append(")");
			xCdsFilter = new StringBuffer();
		}
		String 	appendFields = ", "+precio+", "+oferta+", "+recargo;
			if(profileCPT.trim().equals(""))if (cds.trim().equals("")) throw new Exception("El Centro de Servicio o a quien Reporta no es válido. Por favor intente nuevamente!");
				sbSql.append("select distinct a.codigo, coalesce(a.observacion,a.descripcion) as descripcion, a.tipo_categoria, b.nombre as tipoCategoriaDesc, coalesce(a.costo,0) as costo, ");
				sbSql.append(precio);
				sbSql.append(", 0 as recargo,(select descripcion from tbl_cds_centro_servicio where codigo = c.cod_centro_servicio)cds_desc,c.cod_centro_servicio cds from tbl_cds_procedimiento a, tbl_cds_tipo_categoria b, tbl_cds_procedimiento_x_cds c where a.precio is not null and a.estado = 'A' and a.tipo_categoria = b.codigo and a.codigo = c.cod_procedimiento ");
				sbSql.append(appendFilter);
				sbSql.append(xCdsFilter);
				sbSql.append(sbFilter);
				sbSql.append(" order by 9 asc,2");//LOV_PROCEDIMIENTOS_REPORTA_A
			if(profileCPT.trim().equals("")){
			if (cdsTipo.equalsIgnoreCase("T") || cdsTipo.equalsIgnoreCase("E")){//utiliza bloques de facturacion posiblemente nunca entra a esta condición
				sbSql.append("select distinct a.cpt as codigo, a.descripcion, 0 as tipo_categoria, ' ' as tipoCategoriaDesc, coalesce(a.costo,0) as costo, a.precio, 0 as recargo, a.codigo as cdsProducto from tbl_cds_producto_x_cds a where a.tser = 'tipo_cargo' and a.estatus = 'A'");
				sbSql.append(appendFilter);
				sbSql.append(xCdsFilter);
				sbSql.append(sbFilter);
				sbSql.append(" order by 2");//LOV_PRODUCTO_X_CDS
			}else if (cdsTipo.trim().equals("")) throw new Exception("El Tipo de Centro de Servicio no es válido. Por favor intente nuevamente!");
			}

	}	else if (fp.equalsIgnoreCase("exp_prot_operatorio")||fp.equalsIgnoreCase("protocolo")||fp.equalsIgnoreCase("protocolo_cesarea")||fp.equalsIgnoreCase("sumario_egreso_med_neo")) {
		sbSql = new StringBuffer();
		sbSql.append("select a.codigo, coalesce(a.observacion,a.descripcion) as descripcion, b.nombre as tipoCategoriaDesc, decode(a.precio,null,0,a.precio) as precio, decode(a.costo,null,0,a.costo) as costo FROM tbl_cds_procedimiento a, tbl_cds_tipo_categoria b WHERE a.tipo_categoria=b.codigo and a.estado = 'A' /* and a.tipo_categoria = 2 --ver issue #5324*/ ");
		sbSql.append(appendFilter);
		sbSql.append(" order by coalesce(a.observacion,a.descripcion)");

	}	else if (fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("citasimagenologia")) {
		sbSql = new StringBuffer();
		sbSql.append("select a.codigo, coalesce(a.nombre_corto,a.observacion,a.descripcion) as descripcion, nvl((select descripcion from tbl_cdc_tipo_cirugia where codigo=a.tipo_cirugia),' ') as especialidad, decode(a.tipo_cirugia,null,' ',''||a.tipo_cirugia) as tipo_cirugia, nvl(a.tiempo_estimado,0) as horas, nvl(a.unidad_tiempo,0) as minutos, decode(a.precio,null,0,a.precio) as precio, decode(a.costo,null,0,a.costo) as costo, (select descripcion from tbl_cds_tipo_categoria where codigo=a.tipo_categoria) as tipoCategoriaDesc from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds c where a.estado='A'");
		sbSql.append(appendFilter);
		if (fp.equalsIgnoreCase("citas")||fp.equalsIgnoreCase("citasimagenologia")){
		sbSql.append(" and a.codigo = c.cod_procedimiento and c.cod_centro_servicio = '");sbSql.append(cds);sbSql.append("'");}

		sbSql.append(" order by 2");

	} else if (fp.equalsIgnoreCase("profileCPT") ) {
		sbSql = new StringBuffer();
		String filter = (tipoProfil.trim().equals("I")?"'RIS'":"'LIS'");

		//System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::::: "+tipoProfil+" * "+filter);

		sbSql.append("select distinct a.codigo, coalesce(a.observacion,a.descripcion) as descripcion, nvl((select descripcion from tbl_cdc_tipo_cirugia where codigo=a.tipo_cirugia),' ') as especialidad, decode(a.tipo_cirugia,null,' ',''||a.tipo_cirugia) as tipo_cirugia, nvl(a.tiempo_estimado,0) as horas, nvl(a.unidad_tiempo,0) as minutos, '' as precio,'' as costo, (select cat.nombre from tbl_cds_tipo_categoria cat where cat.codigo=a.tipo_categoria) as tipoCategoriaDesc,'' cds, '' cds_desc, nvl((select join(cursor(select cds2.codigo||'='||cds2.descripcion||' - Precio : '||decode(aa.precio,null,0,aa.precio)||' Costo: '||decode(aa.costo,null,0,aa.costo) from tbl_cds_procedimiento_x_cds cc,tbl_cds_centro_Servicio cds2 ,tbl_cds_procedimiento aa where cC.COD_CENTRO_SERVICIO = CDS2.CODIGO and (CDS2.REPORTA_A in (select codigo from tbl_cds_centro_servicio where interfaz = ");
		sbSql.append(filter);
		sbSql.append(") or flag_cds=decode(interfaz,'LIS','LAB','RIS','IMA','---'))");
		sbSql.append(" and cc.cod_procedimiento=aa.codigo and cc.cod_procedimiento=a.codigo and a.estado='A'),',') from dual),' ') as centros from tbl_cds_procedimiento a, tbl_cds_procedimiento_x_cds c, tbl_cds_centro_Servicio cds where a.estado='A' ");
		sbSql.append(appendFilter);
		sbSql.append("  and a.codigo = c.cod_procedimiento and C.COD_CENTRO_SERVICIO = CDS.CODIGO and CDS.REPORTA_A in (select codigo from tbl_cds_centro_servicio where interfaz = ");
		sbSql.append(filter);
		sbSql.append(")  order by 2");

	}
	else if (fp.equalsIgnoreCase("MAPPING_CPT"))	{



		sbSql = new StringBuffer();
		sbSql.append("select a.codigo, coalesce(a.observacion,a.descripcion) as descripcion, b.nombre as tipoCategoriaDesc, decode(a.precio,null,0,a.precio) as precio, decode(a.costo,null,0,a.costo) as costo FROM tbl_cds_procedimiento a, tbl_cds_tipo_categoria b WHERE a.tipo_categoria=b.codigo and a.estado = 'A' ");
		sbSql.append(appendFilter);
		if(cdsFiltro != null && !cdsFiltro.trim().equals(""))
		{
			sbSql.append(" and exists (select null from tbl_cds_procedimiento_x_cds where cod_procedimiento=a.codigo and cod_centro_servicio = ");
			sbSql.append(cdsFiltro);
			sbSql.append(" ) ");
		}
		sbSql.append(" order by coalesce(a.observacion,a.descripcion)");
	}else if (fp.equalsIgnoreCase("paquete_cargos"))	{
		sbSql = new StringBuffer();
		sbSql.append("select a.codigo, coalesce(a.observacion,a.descripcion) as descripcion, b.nombre as tipoCategoriaDesc, decode(a.precio,null,0,a.precio) as precio, decode(a.costo,null,0,a.costo) as costo, (select codigo||'@@'||descripcion from tbl_cds_tipo_servicio where codigo = '07') as tipo_servicio_desc FROM tbl_cds_procedimiento a, tbl_cds_tipo_categoria b WHERE a.tipo_categoria=b.codigo and a.estado = 'A' ");
		sbSql.append(appendFilter);
		sbSql.append(" order by coalesce(a.observacion,a.descripcion)");
	}
	if(request.getParameter("beginSearch") != null){
	al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sbSql.toString()+") a) WHERE rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
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
document.title = 'Procedimiento - '+document.title;
function verificarCant(k){var nProc=parseInt(document.result.nProc.value,10);if(eval('document.result.check'+k)&&eval('document.result.check'+k).checked)nProc++;else nProc--;if(nProc>4){alert('No puede seleccionar más de 4 procedimientos!');eval('document.result.check'+k).checked=false;nProc--;}document.result.nProc.value=nProc;}
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();document.search00.barcode.focus();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PROCEDIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("diagPreLastLineNo",""+diagPreLastLineNo)%>
<%=fb.hidden("diagPostLastLineNo",""+diagPostLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("CPTlastLineNo",""+CPTlastLineNo)%>
<%=fb.hidden("cptLastLineNoMapping",""+cptLastLineNoMapping)%>
<%=fb.hidden("paqProcLastLineNo",""+paqProcLastLineNo)%>

<%=fb.hidden("seccion",""+seccion)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("cTab",cTab)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("categoriaAdm",categoriaAdm)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
<%=fb.hidden("clasifAdm",clasifAdm)%>
<%=fb.hidden("tipoCE",tipoCE)%>
<%=fb.hidden("ce",ce)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("ceCDLastLineNo",""+ceCDLastLineNo)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("ceDetLastLineNo",""+ceDetLastLineNo)%>
<%=fb.hidden("centroServicio",centroServicio)%>
<%=fb.hidden("tipoCds",tipoCds)%>
<%=fb.hidden("inventarioSino",inventarioSino)%>
<%=fb.hidden("secuencia_cob",secuencia_cob)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("cod_pac",cod_pac)%>
<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>
<%=fb.hidden("secuencia_sol2",secuencia_sol2)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("clasificacion",clasificacion)%>
<%=fb.hidden("cambioPrecio",cambioPrecio)%>
<%=fb.hidden("descuento",descuento)%>
<%=fb.hidden("cupon",cupon)%>
<%=fb.hidden("cdsReportaA",cdsReportaA)%>
<%=fb.hidden("cdsTipo",cdsTipo)%>
<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("persLastLineNo",persLastLineNo)%>
<%=fb.hidden("equiLastLineNo",equiLastLineNo)%>
<%=fb.hidden("flagCds",flagCds)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("tipoProfil",tipoProfil)%>
<%=fb.hidden("profileCPT",profileCPT)%>
<%=fb.hidden("revenueId",revenueId)%>
<%=fb.hidden("citasSopAdm",citasSopAdm)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("citasAmb",citasAmb)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("exp",exp)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("modalize",modalize)%>
		<tr class="TextFilter">
			<td width="100%">
				<cellbytelabel>Barcode</cellbytelabel>
				<%=fb.textBox("barcode","",false,false,false,10)%>
				<cellbytelabel>C&oacute;digo&nbsp;&nbsp;</cellbytelabel>
				<%=fb.textBox("code",code,false,false,false,5)%>

				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("name",name,false,false,false,20)%>

								<cellbytelabel>Tipo</cellbytelabel>
								<%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_cds_tipo_categoria order by codigo","tipoProc",tipoProc,false,false,0,"T")%>
				<%if(fp.equalsIgnoreCase("MAPPING_CPT")){%>

				Centro: <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_cds_centro_servicio x where compania_unorg="+(String) session.getAttribute("_companyId")+" and estado='A' and exists (select null from tbl_cds_servicios_x_centros where centro_servicio =x.codigo and tipo_servicio = '07' and visible_centro = 'S')  order by 2 asc","cdsFiltro",cdsFiltro,false,false,0,"Text10",null,null,null,"S")%>
				<%}%>
								<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
<%fb = new FormBean("result",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextVal",""+(nxtVal))%>
<%=fb.hidden("previousVal",""+(preVal))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("diagPreLastLineNo",""+diagPreLastLineNo)%>
<%=fb.hidden("diagPostLastLineNo",""+diagPostLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("CPTlastLineNo",""+CPTlastLineNo)%>
<%=fb.hidden("cptLastLineNoMapping",""+cptLastLineNoMapping)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("cTab",cTab)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("categoriaAdm",categoriaAdm)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
<%=fb.hidden("clasifAdm",clasifAdm)%>
<%=fb.hidden("tipoCE",tipoCE)%>
<%=fb.hidden("ce",ce)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("ceCDLastLineNo",""+ceCDLastLineNo)%>
<%=fb.hidden("tipoServicio",tipoServicio)%>
<%=fb.hidden("ceDetLastLineNo",""+ceDetLastLineNo)%>
<%=fb.hidden("centroServicio",centroServicio)%>
<%=fb.hidden("tipoCds",tipoCds)%>
<%=fb.hidden("inventarioSino",inventarioSino)%>
<%=fb.hidden("secuencia_cob",secuencia_cob)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("cod_pac",cod_pac)%>
<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>
<%=fb.hidden("secuencia_sol2",secuencia_sol2)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("clasificacion",clasificacion)%>
<%=fb.hidden("cambioPrecio",cambioPrecio)%>
<%=fb.hidden("descuento",descuento)%>
<%=fb.hidden("cupon",cupon)%>
<%=fb.hidden("cdsReportaA",cdsReportaA)%>
<%=fb.hidden("cdsTipo",cdsTipo)%>
<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("tipoProc",tipoProc)%>
<%=fb.hidden("seccion",""+seccion)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("persLastLineNo",persLastLineNo)%>
<%=fb.hidden("equiLastLineNo",equiLastLineNo)%>
<%=fb.hidden("nProc",""+vProc.size())%>
<%=fb.hidden("flagCds",flagCds)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("tipoProfil",tipoProfil)%>
<%=fb.hidden("profileCPT",profileCPT)%>
<%=fb.hidden("revenueId",revenueId)%>
<%=fb.hidden("paqProcLastLineNo",""+paqProcLastLineNo)%>
<%=fb.hidden("barcode","")%>
<%=fb.hidden("citasSopAdm",citasSopAdm)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("citasAmb",citasAmb)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("exp",exp)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("cdsFiltro",cdsFiltro)%>
<%=fb.hidden("modalize",modalize)%>

<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("saveNcont","Agregar y Continuar",true,false)%>
				<%=fb.submit("save","Agregar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
				<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<%if(fp != null && !fp.equalsIgnoreCase("protocolo") && !fp.equalsIgnoreCase("protocolo_cesarea")&& !fp.equalsIgnoreCase("sumario_egreso_med_neo")){%>
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="14%"><cellbytelabel>CDS</cellbytelabel></td>
			<td width="24%"><cellbytelabel>Tipo Categor&iacute;a</cellbytelabel></td>
			<%if(!fp.equalsIgnoreCase("profileCPT")){%><td width="6%"><cellbytelabel>Precio</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Costo</cellbytelabel></td>
			<%}else{%>
			<td  colspan="2">&nbsp;</td>
			<%}%>
			<td width="8%"><%=(fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped") || fp.equalsIgnoreCase("cds_solicitud_lab_ext"))?"Recargo":""%></td>
			<td width="5%"><%=fb.checkbox("check","",false,(fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("citasimagenologia")),null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los procedimientos listados!")%></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
		<%=fb.hidden("costo"+i,cdo.getColValue("costo"))%>
		<%=fb.hidden("oferta"+i,cdo.getColValue("oferta"))%>
		<%=fb.hidden("recargo"+i,cdo.getColValue("recargo"))%>
		<%=fb.hidden("cdsProducto"+i,cdo.getColValue("cdsProducto"))%>
		<%=fb.hidden("tipo_cirugia"+i,cdo.getColValue("tipo_cirugia"))%>
		<%=fb.hidden("especialidad"+i,cdo.getColValue("especialidad"))%>
		<%=fb.hidden("horas"+i,cdo.getColValue("horas"))%>
		<%=fb.hidden("minutos"+i,cdo.getColValue("minutos"))%>
		<%=fb.hidden("centroServicio"+i,cdo.getColValue("cds"))%>
		<%=fb.hidden("cds"+i,cdo.getColValue("cds"))%>
		<%=fb.hidden("centroServicioDesc"+i,cdo.getColValue("cds_desc"))%>
		<%=fb.hidden("centros"+i,cdo.getColValue("centros"))%>
		<%=fb.hidden("tipo_servicio_desc"+i,cdo.getColValue("tipo_servicio_desc"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td><%if(!fp.equalsIgnoreCase("profileCPT")){%><%=(cdo.getColValue("cds_desc")==null?"":cdo.getColValue("cds_desc"))%><%}else{%>
			<%=fb.select("alCentros"+i,cdo.getColValue("centros"),"",false,false,false,0,"Text10",null,"","","S")%>
			<%}%>

			</td>
			<td><%=cdo.getColValue("tipoCategoriaDesc")%></td><%if(!fp.equalsIgnoreCase("profileCPT")){%>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%>&nbsp;</td>
			<td align="right"><%=(cdo.getColValue("costo").trim().equals(""))?"":CmnMgr.getFormattedDecimal(cdo.getColValue("costo"))%>&nbsp;</td>
			<%}else{%>
			<td align="right" colspan="2">&nbsp;</td>
			<%}%>
			<td align="right"><%=((fp.trim().equalsIgnoreCase("cds_solicitud_rayx_lab_ped") && cdo.getColValue("recargo") != null && cdo.getColValue("recargo").trim().equals("")))?CmnMgr.getFormattedDecimal(cdo.getColValue("recargo")):""%>&nbsp;</td>
			<td align="center"><%=((fp.equalsIgnoreCase("cds_references") && vProce.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("convenio_cobertura_centro") && vCobCD.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("convenio_exclusion_centro") && vExclCD.contains(cdo.getColValue("codigo"))) || ( ( fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle") ) && vCobDet.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("convenio_cobertura_solicitud") && vCobDet.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("convenio_cobertura_detSol") && vCobDet.contains(cdo.getColValue("codigo"))) || ( (fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle")) && vExclDet.contains(cdo.getColValue("codigo"))) || ((fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped") || fp.equalsIgnoreCase("cds_solicitud_lab_ext") || fp.equalsIgnoreCase("cds_solicitud_ima")) && vProce.contains(tipoSolicitud+cdo.getColValue("codigo"))) || ((fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("citasimagenologia")) && vProc.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("profileCPT") && vCPT.contains(cdo.getColValue("codigo")))  || (fp.equalsIgnoreCase("MAPPING_CPT") && vCPTMapping.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("paquete_cargos") && vPaqProc.contains(id+"-P-"+cdo.getColValue("codigo"))) )?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),((!profileCPT.trim().equals(""))?true:false),false,"","",(fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("citasimagenologia"))?"onClick=\"javascript:verificarCant("+i+")\"":"")%></td>
		</tr>
<%
}
%>
		</table>
<%}else{%>
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="45%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td width="24%"><cellbytelabel id="6">Tipo Categor&iacute;a</cellbytelabel></td>
			<td width="7%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los procedimientos listados!")%></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td><%=cdo.getColValue("tipoCategoriaDesc")%></td>
			<td align="center"><%=((fp.equalsIgnoreCase("exp_prot_operatorio") && vProc.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("protocolo") && vProcOpe.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("protocolo_cesarea") && vProcPC.contains(cdo.getColValue("codigo"))) || (fp.equalsIgnoreCase("sumario_egreso_med_neo") && vProcInTra.contains(cdo.getColValue("codigo"))) )?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false)%>
						</td>
		</tr>
<%
}
%>
		</table>
<%}%>
</div>
</div>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("saveNcont2","Agregar y Continuar",true,false)%>
				<%=fb.submit("save2","Agregar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<script>
<% if (al.size()==1&&refresh.trim().equals("S")){ %>
		if(!document.result.check0.checked) {
				document.result.check0.checked=true;
				$('#save2')[0].click();
		}
<% } %>
</script>

<%=fb.formEnd()%>
</table>
</body>
</html>
<%
} else {
	int size = Integer.parseInt(request.getParameter("size"));
	int hours = 0;
	int mins = 0;
	if (fp.equalsIgnoreCase("procedimiento"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("codProcedimiento",request.getParameter("codigo"+i));
				cdo.addColValue("procedimientoDesc",request.getParameter("descripcion"+i));
				cdo.addColValue("precio",request.getParameter("precio"+i));
				cdo.addColValue("costo",request.getParameter("costo"+i));
				procLastLineNo++;

				String key = "";
				if (procLastLineNo < 10) key = "00"+procLastLineNo;
				else if (procLastLineNo < 100) key = "0"+procLastLineNo;
				else key = ""+procLastLineNo;
				cdo.addColValue("key",key);

				try
				{
					iProce.put(key,cdo);
					vProce.add(cdo.getColValue("codProcedimiento"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//procedimiento
	else if (fp.equalsIgnoreCase("cds_references"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("codProcedimiento",request.getParameter("codigo"+i));
				cdo.addColValue("procedimientoDesc",request.getParameter("descripcion"+i));
				cdo.addColValue("precio",request.getParameter("precio"+i));
				cdo.addColValue("costo",request.getParameter("costo"+i));
				procLastLineNo++;

				cdo.setKey(iProce.size() + 1);
				cdo.setAction("I");

				try
				{
					iProce.put(cdo.getKey(),cdo);
					vProce.add(cdo.getColValue("codProcedimiento"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_centro"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CoberturaDetalle cd = new CoberturaDetalle();

				cd.setSecuencia("0");
				cd.setProcedimiento(request.getParameter("codigo"+i));
				cd.setCodigo(request.getParameter("codigo"+i));
				cd.setDescripcion(request.getParameter("descripcion"+i));

				ceCDLastLineNo++;

				String key = "";
				if (ceCDLastLineNo < 10) key = "00"+ceCDLastLineNo;
				else if (ceCDLastLineNo < 100) key = "0"+ceCDLastLineNo;
				else key = ""+ceCDLastLineNo;
				cd.setKey(key);

				try
				{
					iCobCD.put(key, cd);
					vCobCD.add(cd.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_cobertura_centro
	else if (fp.equalsIgnoreCase("convenio_exclusion_centro"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				ExclusionDetalle ed = new ExclusionDetalle();

				ed.setSecuencia("0");
				ed.setProcedimiento(request.getParameter("codigo"+i));
				ed.setCodigo(request.getParameter("codigo"+i));
				ed.setDescripcion(request.getParameter("descripcion"+i));

				ceCDLastLineNo++;

				String key = "";
				if (ceCDLastLineNo < 10) key = "00"+ceCDLastLineNo;
				else if (ceCDLastLineNo < 100) key = "0"+ceCDLastLineNo;
				else key = ""+ceCDLastLineNo;
				ed.setKey(key);

				try
				{
					iExclCD.put(key, ed);
					vExclCD.add(ed.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_exclusion_centro
	else if (fp.equalsIgnoreCase("convenio_cobertura_detalle") || fp.equalsIgnoreCase("pm_convenio_cobertura_detalle") )
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CoberturaDetalle cd = new CoberturaDetalle();

				cd.setSecuencia("0");
				cd.setProcedimiento(request.getParameter("codigo"+i));
				cd.setCodigo(request.getParameter("codigo"+i));
				cd.setDescripcion(request.getParameter("descripcion"+i));

				ceDetLastLineNo++;

				String key = "";
				if (ceDetLastLineNo < 10) key = "00"+ceDetLastLineNo;
				else if (ceDetLastLineNo < 100) key = "0"+ceDetLastLineNo;
				else key = ""+ceDetLastLineNo;
				cd.setKey(key);

				try
				{
					iCobDet.put(key, cd);
					vCobDet.add(cd.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_cobertura_detalle, pm_convenio_cobertura_detalle
	else if (fp.equalsIgnoreCase("convenio_exclusion_detalle") || fp.equalsIgnoreCase("pm_convenio_exclusion_detalle"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				ExclusionDetalle ed = new ExclusionDetalle();

				ed.setSecuencia("0");
				ed.setProcedimiento(request.getParameter("codigo"+i));
				ed.setCodigo(request.getParameter("codigo"+i));
				ed.setDescripcion(request.getParameter("descripcion"+i));

				ceDetLastLineNo++;

				String key = "";
				if (ceDetLastLineNo < 10) key = "00"+ceDetLastLineNo;
				else if (ceDetLastLineNo < 100) key = "0"+ceDetLastLineNo;
				else key = ""+ceDetLastLineNo;
				ed.setKey(key);

				try
				{
					iExclDet.put(key, ed);
					vExclDet.add(ed.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_exclusion_detalle, pm_convenio_exclusion_detalle
	else if (fp.equalsIgnoreCase("convenio_cobertura_solicitud")|| fp.equalsIgnoreCase("convenio_cobertura_detSol"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CoberturaDetalladaServicio cd = new CoberturaDetalladaServicio();

				cd.setSecuencia("0");
				cd.setProcedimiento(request.getParameter("codigo"+i));
				cd.setCodigo(request.getParameter("codigo"+i));
				cd.setDescripcion(request.getParameter("descripcion"+i));

				ceDetLastLineNo++;

				String key = "";
				if (ceDetLastLineNo < 10) key = "00"+ceDetLastLineNo;
				else if (ceDetLastLineNo < 100) key = "0"+ceDetLastLineNo;
				else key = ""+ceDetLastLineNo;
				cd.setKey(key);

				try
				{
					iCobDet.put(key, cd);
					vCobDet.add(cd.getCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//convenio_cobertura_solicitud
	else if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped") || fp.equalsIgnoreCase("cds_solicitud_lab_ext") || fp.equalsIgnoreCase("cds_solicitud_ima"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CdsSolicitudDetalle csd = new CdsSolicitudDetalle();

				csd.setCodigo("0");
				if (tipoSolicitud.equalsIgnoreCase("Q"))
				{
					csd.setCodPaq(request.getParameter("codigo"+i));
					csd.setTipoSolicit("Q");
				}
				else
				{
					csd.setCodProcedimiento(request.getParameter("codigo"+i));
					csd.setTipoSolicit("P");
				}
				csd.setProcedimientoDesc(request.getParameter("descripcion"+i));
				csd.setPrecio(request.getParameter("precio"+i));
				csd.setOferta(request.getParameter("oferta"+i));
				csd.setRecargo(request.getParameter("recargo"+i));
				csd.setCdsProducto(request.getParameter("cdsProducto"+i));
				csd.setCodCentroServicio(request.getParameter("cds"+i));

				procLastLineNo++;

				String key = "";
				if (procLastLineNo < 10) key = "00"+procLastLineNo;
				else if (procLastLineNo < 100) key = "0"+procLastLineNo;
				else key = ""+procLastLineNo;
				csd.setKey(key);

				try
				{
					iProce.put(key, csd);
					vProce.add(tipoSolicitud+request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//cds_solicitud_rayx_lab_ped or cds_solicitud_lab_ext or cds_solicitud_ima
	else if (fp.equalsIgnoreCase("exp_prot_operatorio"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("procedimiento",request.getParameter("codigo"+i));
				cdo.addColValue("descProc",request.getParameter("descripcion"+i));
				cdo.addColValue("codigo","0");
				cdo.setAction("I");
				cdo.setKey(iProc.size()+1);

				try
				{
					iProc.put(cdo.getKey(),cdo);
					vProc.add(cdo.getColValue("procedimiento"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}
		else if (fp.equalsIgnoreCase("protocolo"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("procedimiento",request.getParameter("codigo"+i));
				cdo.addColValue("descProc",request.getParameter("descripcion"+i));
				cdo.addColValue("codigo","0");
				cdo.setAction("I");
				cdo.setKey(iProcOpe.size()+1);
				cdo.setKey(iProc.size()+1);

				try
				{
					iProcOpe.put(cdo.getKey(),cdo);
					iProc.put(cdo.getKey(),cdo);
					vProcOpe.add(cdo.getColValue("procedimiento"));
					vProc.add(cdo.getColValue("procedimiento"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}
		else if (fp.equalsIgnoreCase("protocolo_cesarea"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("procedimiento",request.getParameter("codigo"+i));
				cdo.addColValue("descProc",request.getParameter("descripcion"+i));
				cdo.addColValue("codigo","0");
				cdo.setAction("I");
				cdo.setKey(iProcPC.size()+1);

				try
				{
					iProcPC.put(cdo.getKey(),cdo);
					vProcPC.add(cdo.getColValue("procedimiento"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}// protocolo cesarea
		else if (fp.equalsIgnoreCase("sumario_egreso_med_neo"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("procedimiento",request.getParameter("codigo"+i));
				cdo.addColValue("descProc",request.getParameter("descripcion"+i));
				cdo.addColValue("codigo","0");
				cdo.setAction("I");
				cdo.setKey(iProcInTra.size()+1);

				try
				{
					iProcInTra.put(cdo.getKey(),cdo);
					vProcInTra.add(cdo.getColValue("procedimiento"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}// sumario_egreso_med_neo
	else if (fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("citasimagenologia"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CitaProcedimiento proc = new CitaProcedimiento();

				proc.setProcedimiento(request.getParameter("codigo"+i));
				proc.setProcedimientoDesc(request.getParameter("descripcion"+i));
				proc.setTipoC(request.getParameter("tipo_cirugia"+i));
				//proc.setTipoCirugiaDesc(request.getParameter("especialidad"+i));
				proc.setStatus("N");//new record
				proc.setCodigo("0");
				procLastLineNo++;
				proc.setKey(""+procLastLineNo,3);
				//proc.setHoras(Integer.parseInt(request.getParameter("horas"+i)));
				//proc.setMinutos(Integer.parseInt(request.getParameter("minutos"+i)));
				hours += Integer.parseInt(request.getParameter("horas"+i));
				mins += Integer.parseInt(request.getParameter("minutos"+i));

				try
				{
					iProc.put(proc.getKey(),proc);
					vProc.addElement(proc.getProcedimiento());
				}
				catch (Exception e)
				{
					System.out.println("Unable to addget item "+proc.getKey());
				}
			}// checked
		}
	}//citas || citasimagenologia
	else if (fp.equalsIgnoreCase("profileCPT"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdoCPT = new CommonDataObject();

				cdoCPT.addColValue("id_cpt",request.getParameter("codigo"+i));
				cdoCPT.addColValue("descCPT",request.getParameter("descripcion"+i));
				cdoCPT.addColValue("cod_cds",request.getParameter("alCentros"+i));
				cdoCPT.addColValue("centroServicioDesc",request.getParameter("centroServicioDesc"+i));
				cdoCPT.addColValue("centros",request.getParameter("centros"+i));
				CPTlastLineNo++;

				String key = "";
				if (CPTlastLineNo < 10) key = "00"+CPTlastLineNo;
				else if (CPTlastLineNo < 100) key = "0"+CPTlastLineNo;
				else key = ""+CPTlastLineNo;
				cdoCPT.addColValue("key",key);

				try
				{
					iCPT.put(key,cdoCPT);
					vCPT.add(cdoCPT.getColValue("id_cpt"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//profileCPT

	else if (fp.equalsIgnoreCase("MAPPING_CPT"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdoCPTMapping = new CommonDataObject();

				cdoCPTMapping.addColValue("codigo",request.getParameter("codigo"+i));
				cdoCPTMapping.addColValue("descCPT",request.getParameter("descripcion"+i));
				cdoCPTMapping.setAction("I");
				cptLastLineNoMapping++;

				String key = "";
				if (cptLastLineNoMapping < 10) key = "00"+cptLastLineNoMapping;
				else if (cptLastLineNoMapping < 100) key = "0"+cptLastLineNoMapping;
				else key = ""+cptLastLineNoMapping;
				cdoCPTMapping.addColValue("key",key);

				try
				{
					iCPTMapping.put(key,cdoCPTMapping);
					vCPTMapping.add(request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//

	else
	if (fp.equalsIgnoreCase("paquete_cargos"))
	{

		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				String ts = "";
				String tsDesc = "";

				try{
					ts = request.getParameter("tipo_servicio_desc"+i).split("@@")[0];
					tsDesc = request.getParameter("tipo_servicio_desc"+i).split("@@")[1];
				}catch(Exception e){}

				cdo.addColValue("_usoCode",id+"-P-"+request.getParameter("codigo"+i));
				cdo.addColValue("tipo_servicio",ts);
				cdo.addColValue("tipo_servicio_desc",tsDesc);
				cdo.addColValue("tipo_cargo","P");
				cdo.addColValue("cod_cargo",request.getParameter("codigo"+i));
				cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
				cdo.addColValue("cantidad","1");

				paqProcLastLineNo++;

				String key = "";
				if (paqProcLastLineNo < 10) key = "00"+paqProcLastLineNo;
				else if (paqProcLastLineNo < 100) key = "0"+paqProcLastLineNo;
				else key = ""+paqProcLastLineNo;
				cdo.addColValue("key",key);

					System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: paqProcLastLineNo "+paqProcLastLineNo);
				try
				{
					iPaqProc.put(key, cdo);
					vPaqProc.add(id+"-P-"+request.getParameter("codigo"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}//paquete_cargos

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&diagPreLastLineNo="+diagPreLastLineNo+"&diagPostLastLineNo="+diagPostLastLineNo+"&whLastLineNo="+whLastLineNo+"&seccion="+seccion+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&code="+request.getParameter("code")+"&barcode="+request.getParameter("barcode")+"&name="+request.getParameter("name")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol2="+request.getParameter("secuencia_sol2")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_cob="+request.getParameter("secuencia_cob")+"&codigo="+codigo+"&cds="+cds+"&clasificacion="+clasificacion+"&cambioPrecio="+cambioPrecio+"&descuento="+descuento+"&cupon="+cupon+"&cdsReportaA="+cdsReportaA+"&cdsTipo="+cdsTipo+"&tipoSolicitud="+tipoSolicitud+"&codCita="+codCita+"&fechaCita="+fechaCita+"&persLastLineNo="+persLastLineNo+"&equiLastLineNo="+equiLastLineNo+"&flagCds="+flagCds+"&desc="+desc+"&CPTlastLineNo="+CPTlastLineNo+"&tipoProfil="+tipoProfil+"&tipoProc="+request.getParameter("tipoProc")+"&profileCPT="+request.getParameter("profileCPT")+"&cptLastLineNoMapping="+cptLastLineNoMapping+"&revenueId="+request.getParameter("revenueId")+"&paqProcLastLineNo="+paqProcLastLineNo+"&citasSopAdm="+citasSopAdm+"&citasAmb="+citasAmb+"&beginSearch="+request.getParameter("beginSearch")+"&exp="+exp+"&fg="+fg+"&modeSec="+modeSec+"&cdsFiltro="+cdsFiltro);
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&diagPreLastLineNo="+diagPreLastLineNo+"&diagPostLastLineNo="+diagPostLastLineNo+"&whLastLineNo="+whLastLineNo+"&seccion="+seccion+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&code="+request.getParameter("code")+"&name="+request.getParameter("name")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol2="+request.getParameter("secuencia_sol2")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_cob="+request.getParameter("secuencia_cob")+"&codigo="+codigo+"&cds="+cds+"&clasificacion="+clasificacion+"&cambioPrecio="+cambioPrecio+"&descuento="+descuento+"&cupon="+cupon+"&cdsReportaA="+cdsReportaA+"&cdsTipo="+cdsTipo+"&tipoSolicitud="+tipoSolicitud+"&codCita="+codCita+"&fechaCita="+fechaCita+"&persLastLineNo="+persLastLineNo+"&equiLastLineNo="+equiLastLineNo+"&flagCds="+flagCds+"&desc="+desc+"&CPTlastLineNo="+CPTlastLineNo+"&tipoProfil="+tipoProfil+"&tipoProc="+request.getParameter("tipoProc")+"&profileCPT="+request.getParameter("profileCPT")+"&cptLastLineNoMapping="+cptLastLineNoMapping+"&revenueId="+request.getParameter("revenueId")+"&paqProcLastLineNo="+paqProcLastLineNo+"&barcode="+request.getParameter("barcode")+"&citasSopAdm="+citasSopAdm+"&citasAmb="+citasAmb+"&beginSearch="+request.getParameter("beginSearch")+"&exp="+exp+"&fg="+fg+"&modeSec="+modeSec+"&cdsFiltro="+cdsFiltro);
		return;
	}
	else if (request.getParameter("saveNcont") != null || request.getParameter("saveNcont2") != null )
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&diagPreLastLineNo="+diagPreLastLineNo+"&diagPostLastLineNo="+diagPostLastLineNo+"&whLastLineNo="+whLastLineNo+"&seccion="+seccion+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&tipoServicio="+tipoServicio+"&ceDetLastLineNo="+ceDetLastLineNo+"&centroServicio="+centroServicio+"&tipoCds="+tipoCds+"&inventarioSino="+inventarioSino+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&code="+request.getParameter("code")+"&name="+request.getParameter("name")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol2="+request.getParameter("secuencia_sol2")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_cob="+request.getParameter("secuencia_cob")+"&codigo="+codigo+"&cds="+cds+"&clasificacion="+clasificacion+"&cambioPrecio="+cambioPrecio+"&descuento="+descuento+"&cupon="+cupon+"&cdsReportaA="+cdsReportaA+"&cdsTipo="+cdsTipo+"&tipoSolicitud="+tipoSolicitud+"&codCita="+codCita+"&fechaCita="+fechaCita+"&persLastLineNo="+persLastLineNo+"&equiLastLineNo="+equiLastLineNo+"&flagCds="+flagCds+"&desc="+desc+"&CPTlastLineNo="+CPTlastLineNo+"&tipoProfil="+tipoProfil+"&tipoProc="+request.getParameter("tipoProc")+"&profileCPT="+request.getParameter("profileCPT")+"&cptLastLineNoMapping="+cptLastLineNoMapping+"&revenueId="+request.getParameter("revenueId")+"&paqProcLastLineNo="+paqProcLastLineNo+"&citasSopAdm="+citasSopAdm+"&citasAmb="+citasAmb+"&beginSearch="+request.getParameter("beginSearch")+"&exp="+exp+"&fg="+fg+"&modeSec="+modeSec+"&cdsFiltro="+cdsFiltro);
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("cds_references"))
	{
%>
	window.opener.location = '../admin/reg_cds_references.jsp?change=1&tab=<%=tab%>&mode=<%=mode%>&id=<%=id%>&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&whLastLineNo=<%=whLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_centro"))
	{
%>
	window.opener.location = '../convenio/convenio_cobertura_cendet.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&index=<%=index%>&cobCDLastLineNo=<%=ceCDLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_exclusion_centro"))
	{
%>
	window.opener.location = '../convenio/convenio_exclusion_cendet.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&index=<%=index%>&exclCDLastLineNo=<%=ceCDLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_detalle"))
	{
%>
	window.opener.location = '../convenio/convenio_cobertura_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio_cobertura_detalle"))
	{
%>
				window.opener.location = '../planmedico/pm_convenio_cobertura_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
	{
%>
	window.opener.location = '../admision/detalle_cobertura_tipo.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&cds=<%=centroServicio%>&tipoCds=<%=tipoCds%>&secuencia_cob=<%=secuencia_cob%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&solicitud=<%=solicitud%>&admision=<%=admision%>&fecha_nacimiento=<%=fecha_nacimiento%>&secuencia_sol1=<%=secuencia_sol1%>&secuencia_sol2=<%=secuencia_sol2%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_detSol"))
	{
%>
	window.opener.location = '../admision/detalle_cobertura_tipo.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&cobDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&cds=<%=centroServicio%>&tipoCds=<%=tipoCds%>&secuencia_cob=<%=secuencia_cob%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&solicitud=<%=solicitud%>&admision=<%=admision%>&fecha_nacimiento=<%=fecha_nacimiento%>&secuencia_sol1=<%=secuencia_sol1%>&secuencia_sol2=<%=secuencia_sol2%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_exclusion_detalle"))
	{
%>
	window.opener.location = '../convenio/convenio_exclusion_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&exclDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio_exclusion_detalle"))
	{
%>
	window.opener.location = '../planmedico/pm_convenio_exclusion_det.jsp?change=1&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&exclDetLastLineNo=<%=ceDetLastLineNo%>&tipoServicio=<%=tipoServicio%>&centroServicio=<%=centroServicio%>&tipoCds=<%=tipoCds%>&inventarioSino=<%=inventarioSino%>';
<%
	}
	else if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped") || fp.equalsIgnoreCase("cds_solicitud_lab_ext") || fp.equalsIgnoreCase("cds_solicitud_ima"))
	{
	  
	  if (modalize.equalsIgnoreCase("Y")) {
%>
  var mainFrame = window.parent.document.querySelector("#i-content");
	var innerDoc = mainFrame.contentDocument || mainFrame.contentWindow.document;
	var itemFrame = innerDoc.querySelector("#itemFrame");
	itemFrame.src = '../admision/reg_solicitud_det.jsp?change=1&mode=<%=mode%>&fp=<%=fp%>&codigo=<%=codigo%>&procLastLineNo=<%=procLastLineNo%>'  
  window.parent.hidePopWin();
<%	  
	  } else {
%>
	window.opener.location = '../admision/reg_solicitud_det.jsp?change=1&mode=<%=mode%>&fp=<%=fp%>&codigo=<%=codigo%>&procLastLineNo=<%=procLastLineNo%>';
<%
  }
	}
	else if (fp.equalsIgnoreCase("exp_prot_operatorio"))
	{
%>
	window.opener.location = '../expediente<%=!exp.equals("")?"3.0":""%>/exp_prot_operatorio.jsp?change=1&tab=<%=tab%>&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pac_id%>&noAdmision=<%=admision%>&diagPreLastLineNo=<%=diagPreLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&seccion=<%=seccion%>&code=<%=id%>&desc=<%=desc%>';
<%
	}
		else if (fp.equalsIgnoreCase("protocolo"))
	{
%>
	window.opener.location = '../expediente<%=!exp.equals("")?"3.0":""%>/exp_prot_operatorio.jsp?change=1&tab=<%=tab%>&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pac_id%>&noAdmision=<%=admision%>&diagPreLastLineNo=<%=diagPreLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&seccion=<%=seccion%>&code=<%=id%>&desc=<%=desc%>';
<%
	}
		else if (fp.equalsIgnoreCase("protocolo_cesarea"))
	{
%>
	window.opener.location = '../expediente<%=!exp.equals("")?"3.0":""%>/exp_protocolo_cesarea.jsp?change=1&tab=<%=tab%>&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pac_id%>&noAdmision=<%=admision%>&diagPreLastLineNo=<%=diagPreLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&seccion=<%=seccion%>&code=<%=id%>&desc=<%=desc%>';
<%
	}
		else if (fp.equalsIgnoreCase("sumario_egreso_med_neo"))
	{
%>
	window.opener.location = '../expediente<%=!exp.equals("")?"3.0":""%>/exp_sumario_egreso_medico_neo.jsp?change=1&tab=2&mode=<%=mode%>&modeSec=<%=modeSec%>&pacId=<%=pac_id%>&noAdmision=<%=admision%>&diagPreLastLineNo=<%=diagPreLastLineNo%>&diagPostLastLineNo=<%=diagPostLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>';
<%
	}
	else if (fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("citasimagenologia"))
	{
		if (mode.equalsIgnoreCase("add"))
		{
%>
	window.opener.location='<%=request.getContextPath()%>/cita/reg_cita_det.jsp?fp=<%=(fp.endsWith("imagenologia"))?"imagenologia":""%>&mode=add&procLastLineNo=<%=procLastLineNo%>&change=1&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>';
	var hora=0;
	var min=0;
	if(window.opener.parent.document.form0.hora_est.value!='')hora=parseInt(window.opener.parent.document.form0.hora_est.value,10);
	if(window.opener.parent.document.form0.min_est.value!='')min=parseInt(window.opener.parent.document.form0.min_est.value,10);
	hora+=<%=hours%>;
	min+=<%=mins%>;
	hora+=parseInt(min/60,10);
	min=min%60;
<%
			if (fp.equalsIgnoreCase("citasimagenologia"))
			{
%>
	if(((hora*60)+min)<30)min=30;
	else if(((hora*60)+min)>30&&((hora*60)+min)<60)hora=1;
<%
			}
%>
	window.opener.parent.document.form0.hora_est.value=hora;
	window.opener.parent.document.form0.min_est.value=min;
<%
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
%>
	window.opener.location='<%=request.getContextPath()%>/cita/edit_cita.jsp?fp=<%=(fp.endsWith("imagenologia"))?"imagenologia":""%>&mode=edit&change=1&tab=<%=tab%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&procLastLineNo=<%=procLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&equiLastLineNo=<%=equiLastLineNo%>&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>';
<%
		}
	}
	else if (fp.equalsIgnoreCase("profileCPT")){ %>
		window.opener.location='<%=request.getContextPath()%>/admision/perfiles_cpt_config.jsp?fp=profileCPT&mode=edit&change=1&tab=<%=tab%>&id=<%=id%>&CPTlastLineNo=<%=CPTlastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("MAPPING_CPT")){ %>
		window.opener.location="<%=request.getContextPath()%>/admin/mapping_cpt_det.jsp?fp=MAPPING_CPT&mode=edit&change=1&id=<%=id%>&cptLastLineNoMapping=<%=cptLastLineNoMapping%>&revenueId=<%=revenueId%>&cds=<%=cds%>";
<%}else if (fp.equalsIgnoreCase("paquete_cargos")){ %>

window.opener.location = '../admision/paquete_cargo_config.jsp?change=1&tab=3&paqProcLastLineNo=<%=paqProcLastLineNo%>&mode=edit&comboId=<%=id%>';

<%
 }
 %>
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>