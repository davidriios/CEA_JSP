<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="issi.caja.DetallePago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="HashDetKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFacturas" scope="session" class="java.util.Vector" />
<jsp:useBean id="htFac" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFac" scope="session" class="java.util.Vector" />
<%
/**
==============================================================================
==============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList alRevCode = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String tipoCliente = request.getParameter("tipoCliente");
String pac_id = request.getParameter("pac_id");
String factura = request.getParameter("factura");
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String cds = request.getParameter("cds");
String categoria = request.getParameter("categoria");
String orderBy = request.getParameter("orderBy");
String orderByType = request.getParameter("orderByType");
String fact_corp = request.getParameter("fact_corp");
String  file837= "N";
try {file837 =java.util.ResourceBundle.getBundle("issi").getString("file837");}catch(Exception e){ file837 = "N";}

String key = "";
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
int lastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
if (request.getParameter("mode") == null) mode = "add";
if(codigo==null) codigo = "";
if(nombre==null) nombre = "";
if(fDate==null) fDate = "";
if(tDate==null) tDate = "";
if (cds == null) cds = "";
if(categoria==null) categoria = "";
if (orderBy == null) orderBy = "1";
if (orderByType == null) orderByType = "asc";
if (fact_corp == null) fact_corp = "N";

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

	if (!codigo.equals(""))
	{
		sbFilter.append(" and upper(a.codigo) like '%");
		sbFilter.append(request.getParameter("codigo").toUpperCase());
		sbFilter.append("%'");
	}
	if (!nombre.equals(""))
	{
		sbFilter.append(" and upper(p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada))) like '%");
		sbFilter.append(request.getParameter("nombre").toUpperCase());
		sbFilter.append("%'");
	}

	if (fp.equalsIgnoreCase("recibos")||fp.equalsIgnoreCase("aplicarRecibos")){
		
		if (tipoCliente.equalsIgnoreCase("E") || tipoCliente.equalsIgnoreCase("ARE")){
			
			sbSql.append("select a.fecha as fechaOrder, p.primer_nombre||' '||p.primer_apellido nombrepaciente, a.codigo faccodigo, a.admi_secuencia admsecuencia, b.estado admestado, b.categoria admcat, c.descripcion admcatdesc, 'P' estatus, to_char(a.fecha,'dd/mm/yyyy') fechafac, 'N' anulada, ' ' pagopor, 0 tipotransaccion, 0 monto, 'N' sw, (a.grang_total - nvl(d.saldo1, 0) + nvl(e.ajustes, 0)) montototal, (a.grang_total - nvl(d.saldo1, 0) + nvl(e.ajustes, 0)) montodeuda, /*getCajaSaldoFactura(a.compania,a.codigo,a.grang_total)*/ (a.grang_total - nvl(d.saldo1, 0) + nvl(e.ajustes, 0)) saldo, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fechanacimiento, p.pac_id, ' ' codrem from tbl_fac_factura a, tbl_adm_admision b, tbl_adm_categoria_admision c, tbl_adm_paciente p, (select fac_codigo, compania, nvl (sum (monto), 0) saldo1 from tbl_cja_detalle_pago group by fac_codigo, compania) d, (select b.factura, b.compania, nvl (sum (decode (b.lado_mov, 'D', b.monto, 'C', -b.monto)),0) ajustes from vw_con_adjustment_gral b group by b.factura, b.compania) e where a.compania = b.compania(+) and a.admi_secuencia = b.secuencia(+) and a.pac_id = b.pac_id(+) and a.compania = ");
			sbSql.append((String) session.getAttribute("_companyId"));
			sbSql.append(" and a.cod_empresa = '");
			sbSql.append(request.getParameter("cod_empresa"));
			sbSql.append("' /*and codigo = :cg$ctrl.facturas_por_pacientes*/ and a.estatus = 'P' and a.facturar_a = 'E' and (nvl(a.grang_total,0) - nvl(d.saldo1, 0) + nvl(e.ajustes, 0))  > 0 and a.pac_id = p.pac_id and a.codigo = d.fac_codigo(+) and a.compania = d.compania(+) and a.codigo = e.factura(+) and a.compania = e.compania(+) and b.categoria = c.codigo(+) ");
			sbSql.append(appendFilter);

		} else if(tipoCliente.equals("D")){
			sbSql.append("select a.fecha_ingreso as fechaOrder, p.primer_nombre||' '||p.primer_apellido nombrepaciente, '0' faccodigo, a.secuencia admsecuencia, a.estado admestado, a.categoria admcat, d.descripcion admcatdesc, 'N' estatus, to_char (a.fecha_ingreso, 'dd/mm/yyyy') fechafac, 'N' anulada, 'D' pagopor, 4 tipotransaccion, 0 monto, decode(b.sw, null, 'N', b.sw) sw, decode (b.cargos, null, 0, b.cargos) montototal, decode (b.cargos, null, 0, b.cargos - nvl (c.pagos, 0)) montodeuda, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fechanacimiento, p.pac_id, ' ' codrem from tbl_adm_admision a, (select a.pac_id, a.admi_secuencia admision, 'S' sw, nvl (sum (a.monto_paciente), 0) cargos from tbl_fac_estado_cargos a, tbl_cds_centro_servicio b, tbl_adm_medico c where a.monto_paciente is not null and a.monto_paciente <> 0 and a.centro_servicio = b.codigo(+) and a.med_codigo = c.codigo(+) group by a.pac_id, a.admi_secuencia) b, (select   b.pac_id, a.admi_secuencia admision, sum (a.monto) pagos from tbl_cja_detalle_pago a, tbl_cja_transaccion_pago b where a.monto > 0 and a.tran_anio = b.anio and a.compania = b.compania and a.codigo_transaccion = b.codigo group by b.pac_id, a.admi_secuencia) c, tbl_adm_categoria_admision d, tbl_adm_paciente p where a.pac_id = ");
			sbSql.append(pac_id);
			sbSql.append(" and a.estado not in ('I', 'N') and a.secuencia not in (select admi_secuencia from tbl_fac_factura where pac_id = ");
			sbSql.append(pac_id);
			sbSql.append(" and estatus <> 'A' and compania = ");
			sbSql.append((String) session.getAttribute("_companyId"));
			sbSql.append(") and a.pac_id = b.pac_id(+) and a.secuencia = b.admision(+) and a.pac_id = c.pac_id(+) and a.secuencia = c.admision(+) and a.categoria = d.codigo and a.pac_id = p.pac_id");
		} else if(tipoCliente.equals("F")||tipoCliente.equals("P")|| tipoCliente.equalsIgnoreCase("ARP")){
			sbSql.append("select a.fecha as fechaOrder, (select primer_nombre||' '||primer_apellido from tbl_adm_paciente where pac_id = a.pac_id) as nombrepaciente, a.codigo faccodigo, a.admi_secuencia admsecuencia, (select estado from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as admestado, (select categoria from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as admCat, (select (select descripcion from tbl_adm_categoria_admision where codigo = z.categoria) from tbl_adm_admision z where z.pac_id = a.pac_id and z.secuencia = a.admi_secuencia) as admCatDesc, ' ' as estatus, to_char(a.fecha,'dd/mm/yyyy') as fechafac, 'N' as anulada, 'F' as pagopor, 0 as tipotransaccion, 0 as monto, 'N' as sw, a.grang_total as montototal,fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) as montodeuda, (select to_char(fecha_nacimiento,'dd/mm/yyyy') from tbl_adm_paciente where pac_id = a.pac_id) as fechanacimiento, a.pac_id, nvl((select sum(decode(tipo_transaccion,'P',monto,'D',monto * -1)) from tbl_pla_autoriza_desc_detpago where procesado_caja = 'N' and num_referencia = a.codigo),0) as monto_planilla, fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) as saldo, ' ' as codrem from tbl_fac_factura a where a.pac_id = ");
			sbSql.append(pac_id);
			sbSql.append((factura!=null && !factura.equals("")?" and a.codigo = '"+factura+"'":""));
			sbSql.append(" and a.estatus = 'P' and a.facturar_a = 'P' and fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) >0");
		} else if(tipoCliente.equals("R")){
			sbSql.append("select a.fecha_creacion as fechaOrder, p.primer_nombre||' '||p.primer_apellido nombrepaciente, ' ' faccodigo, a.admi_secuencia admsecuencia, b.estado admestado, b.categoria admcat, c.descripcion admcatdesc, 'N' estatus, to_char(a.fecha_creacion,'dd/mm/yyyy') fechafac, 'N' anulada, 'R' pagopor, 0 tipotransaccion, a.codigo codrem, 0 monto, 'N' sw, a.monto_total montototal, nvl((nvl(f.monto_rem,0)-nvl(d.abono,0)),0) montodeuda, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fechanacimiento, p.pac_id, nvl((nvl(f.monto_rem,0)-nvl(d.abono,0)),0) saldo from tbl_fac_remanente a, tbl_adm_admision b, tbl_adm_categoria_admision c, tbl_adm_paciente p, (select cod_rem, sum(monto) abono from tbl_cja_detalle_pago group by cod_rem) d, (select numero_factura, sum (decode (tipo, '2', monto_total, '7', -monto_total)) monto_rem from tbl_fac_remanente group by numero_factura) f where a.facturar_a = 'P' and a.monto_total > 0 and a.pac_id = ");
			sbSql.append(pac_id);
			sbSql.append(" and a.pac_id = b.pac_id and a.admi_secuencia = b.secuencia and b.categoria = c.codigo and b.pac_id = p.pac_id and a.codigo = d.cod_rem(+) and a.numero_factura = f.numero_factura(+)");
		} else if(tipoCliente.equals("O")){
			sbSql.append("select a.fecha as fechaOrder, p.primer_nombre||' '||p.primer_apellido nombrepaciente, a.codigo faccodigo, ' ' admsecuencia, ' ' admestado, ' ' admcat, ' ' admcatdesc, 'N' estatus, to_char(a.fecha,'dd/mm/yyyy') fechafac, 'N' anulada, 'F' pagopor, 2 tipotransaccion, ' ' codrem, 0 monto, 'N' sw, nvl(a.grang_total, a.monto_total) montototal, (nvl(a.grang_total, a.monto_total) - nvl(d.monto, 0)) montodeuda, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fechanacimiento, p.pac_id, (nvl(a.grang_total, a.monto_total) - nvl(d.monto, 0)) saldo from tbl_fac_factura a, tbl_adm_paciente p, (select compania, fac_codigo, sum(monto) monto from tbl_cja_detalle_pago group by compania, fac_codigo) d where a.estatus = 'P' and a.pac_id = ");
			sbSql.append(pac_id);
			sbSql.append(" and a.pac_id = p.pac_id and a.compania = d.compania and a.codigo = d.fac_codigo(+)");
		}
		sbSql.append(" order by ");
		sbSql.append(orderBy);
		sbSql.append(" ");
		sbSql.append(orderByType);

		//al = SQLMgr.getDataList("SELECT * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) WHERE rn between "+previousVal+" and "+nextVal);
		al = SQLMgr.getDataList("select * from (select rownum as rn, tmp.* from ("+sbSql.toString()+") tmp where rownum <= "+nextVal+") where rn >= "+previousVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
	} else if(fp.equals("lista_envio")){
		if(!fDate.equals("")){
			sbFilter.append(" and a.fecha >= to_date('");
			sbFilter.append(fDate);
			sbFilter.append("', 'dd/mm/yyyy')");
		}
		if(!tDate.equals("")){
			sbFilter.append(" and a.fecha <= to_date('");
			sbFilter.append(tDate);
			sbFilter.append("', 'dd/mm/yyyy')");
		}
		if (cds.trim().equalsIgnoreCase("")) {
			if (!UserDet.getUserProfile().contains("0")) {				
				sbFilter.append(" and b.centro_servicio in (select codigo from tbl_cds_centro_servicio where si_no = 'S') and b.centro_servicio in (select cds from tbl_sec_user_cds where user_id=");
				sbFilter.append(UserDet.getUserId());
				sbFilter.append(")");
			}
		} else {
			sbFilter.append(" and b.centro_servicio in (select codigo from tbl_cds_centro_servicio where si_no = 'S' ) and b.centro_servicio = ");
			sbFilter.append(cds);
		}
		String filtrar_categoria = "S";
		CommonDataObject _fc = SQLMgr.getData("select nvl(get_sec_comp_param(-1, 'LISTA_ENVIO_FILTRO_CATEGORIA'), 'S') filtrar_categoria from dual");
		if(_fc!=null) filtrar_categoria = _fc.getColValue("filtrar_categoria");
		boolean showList = false;
		if(!categoria.equals("")) {
			sbFilter.append(" and b.categoria = ");
			sbFilter.append(categoria);
			showList = true;
		}	else if(filtrar_categoria.equals("N")) showList = true;
		if(showList){
			
			if(file837.trim().equals("S"))alRevCode = sbb.getBeanList(ConMgr.getConnection(),"select rev_code as optValueColumn, rev_code||' - '||descripcion as optLabelColumn, rev_code as optTitleColumn from tbl_map_cod_x_cat_adm where estado = 'A' and categoria = "+categoria+"  order by 2",CommonDataObject.class);
			
			
		
		sbSql.append("select a.fecha as fechaOrder, p.primer_nombre||' '||p.primer_apellido nombrepaciente, a.codigo faccodigo, a.admi_secuencia admsecuencia, b.estado admestado, b.categoria admcat, c.descripcion admcatdesc, 'P' estatus, to_char(a.fecha,'dd/mm/yyyy') fechafac, 'N' anulada, ' ' pagopor, 0 tipotransaccion, a.grang_total monto, 'N' sw, (a.grang_total - nvl(d.saldo1, 0) + nvl(e.ajustes, 0)) montototal, (a.grang_total - nvl(d.saldo1, 0) + nvl(e.ajustes, 0)) montodeuda, (a.grang_total - nvl(d.saldo1, 0) + nvl(e.ajustes, 0)) saldo, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fechanacimiento, p.pac_id, ' ' codrem, a.lista, a.facturar_a, to_char(fecha, 'dd/mm/yyyy') fecha, a.usuario_creacion, a.cod_empresa, nvl((select distinct 'S' from tbl_map_cod_x_cat_adm m where m.categoria = b.categoria and m.estado = 'A' and b.aseguradora in (select column_value from table(select split((select get_sec_comp_param(-1,'COD_EMP_AXA') from dual),',') from dual))), 'N') show_al, get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(", 'LISTA_ENVIO_VALIDA_SALDO') valida_saldo, nvl((select distinct lista from tbl_fac_lista_envio le where le.estado != 'I' and exists (select null from tbl_fac_lista_envio_det de where de.compania = le.compania and de.id = le.id and de.factura = a.codigo and de.compania = a.compania and de.estado = 'A')), -1) existe, nvl((select impreso from tbl_fac_dgi_documents d where d.compania = a.compania and d.codigo = a.codigo and d.tipo_docto = 'FACT'), 'N') impreso_fiscal from tbl_fac_factura a, tbl_adm_admision b, tbl_adm_categoria_admision c, tbl_adm_paciente p, (select fac_codigo, compania, nvl (sum (monto), 0) saldo1 from tbl_cja_detalle_pago group by fac_codigo, compania) d, (select b.factura, b.compania, nvl (sum (decode (b.lado_mov, 'D', b.monto, 'C', -b.monto)),0) ajustes from vw_con_adjustment_gral b group by b.factura, b.compania) e where a.compania = b.compania(+) and a.admi_secuencia = b.secuencia(+) and a.pac_id = b.pac_id(+) and a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and a.cod_empresa = '");
		sbSql.append(request.getParameter("cod_empresa"));
		sbSql.append("' and a.estatus <> 'A' and a.facturar_a = 'E' and (((nvl(a.grang_total,0) - nvl(d.saldo1, 0) + nvl(e.ajustes, 0))  > 0) or (a.estatus = 'P' and (nvl(a.grang_total,0) - nvl(d.saldo1, 0) + nvl(e.ajustes, 0))  = 0 and get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(", 'LISTA_ENVIO_MOSTRAR_FACT_SIN_SALDO') = 'S')) and a.pac_id = p.pac_id and a.codigo = d.fac_codigo(+) and a.compania = d.compania(+) and a.codigo = e.factura(+) and a.compania = e.compania(+) and b.categoria = c.codigo(+) and nvl(a.enviado, 'N') = 'N' and a.f_anio = (case nvl(get_sec_comp_param(-1, 'ANIO_FILE_AXA'), '0') when '0' then a.f_anio else to_number(get_sec_comp_param(-1, 'ANIO_FILE_AXA')) end)");
		sbSql.append(sbFilter.toString());
		sbSql.append(" order by ");
		sbSql.append(orderBy);
		sbSql.append(" ");
		sbSql.append(orderByType);
		al = SQLMgr.getDataList("select * from (select rownum as rn, tmp.* from ("+sbSql.toString()+") tmp where rownum <= "+nextVal+") where rn >= "+previousVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
		}
	}
	
	

System.out.println("===== sql: "+sbSql.toString());

/*if(!fp.equals("lista_envio")){

al2 = CmnMgr.reverseRecords(HashDet);
for (int i = 1; i <= HashDet.size(); i++)
{
	key = al2.get(i - 1).toString();
	DetallePago dp = (DetallePago) HashDet.get(key);
}

}*/
	if (searchDisp==null) searchDisp="Listado";

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
<%@ include file="../common/calendar_base.jsp"%>

<script language="javascript">
document.title = 'FACTURAS - '+document.title;

function chkSaldo(i){
	var saldo = parseFloat(eval('document.facturas.saldo'+i).value);
	if (saldo == 0.00 ){
		alert('Esta factura tiene saldo = 0.00');
		eval('document.facturas.chkFact'+i).checked = false;
	}
}

function chkList(i){
	var existe = eval('document.facturas.existe_otra_lista'+i).value;
	if(existe!=-1){
		alert('Esta factura existe en otra lista ['+existe+']!');
		eval('document.facturas.chkFact'+i).checked = false;
	}
}
function doSubmit(valor){
	document.facturas.action.value = valor;
	document.facturas.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE FACTURAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<% fb = new FormBean("search01",request.getContextPath()+request.getServletPath()); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("fact_corp",fact_corp)%>
<%=fb.hidden("cod_empresa",request.getParameter("cod_empresa"))%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("desc",""+desc)%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.hidden("tipoCliente",""+request.getParameter("tipoCliente"))%>
<%=fb.hidden("pac_id",""+request.getParameter("pac_id"))%>
		<tr class="TextFilter">
			<td><cellbytelabel>Factura</cellbytelabel>:
			<%=fb.textBox("codigo",codigo,false,false,false,30,"Text10",null,null)%>
			<% if (tipoCliente != null && (tipoCliente.equalsIgnoreCase("E") || tipoCliente.equalsIgnoreCase("ARE"))) { %>
			&nbsp;<cellbytelabel>Nombre Pac</cellbytelabel>.:
			<%=fb.textBox("nombre",nombre,false,false,false,60,"Text10",null,null)%>
			<%
			}
			if (fp.equalsIgnoreCase("lista_envio")) {
			%>
			<cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel>
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="nameOfTBox1" value="fDate" />
			<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
			<jsp:param name="nameOfTBox2" value="tDate" />
			<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
			<jsp:param name="fieldClass" value="Text10" />
			<jsp:param name="buttonClass" value="Text10" />
			<jsp:param name="clearOption" value="true" />
			</jsp:include>
			<%
			sbSql = new StringBuffer();
			sbSql.append("select codigo, descripcion, codigo from tbl_cds_centro_servicio where si_no = 'S' and estado = 'A'");
			if (!UserDet.getUserProfile().contains("0")) { sbSql.append(" and codigo in (select cds from tbl_sec_user_cds where user_id = "); sbSql.append(UserDet.getUserId()); sbSql.append(")"); }
			sbSql.append(" order by 2");
			%>
			<cellbytelabel id="1">&Aacute;rea</cellbytelabel>
			<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"cds",cds,false,false,0,"Text10","width:175px",null,null,"T")%>
			Cat. Adm.:
			<%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion FROM tbl_adm_categoria_admision order by codigo asc","categoria",categoria,false,false,0,"Text10",null,null, "", "S")%>
			<% } %>
			<%=fb.select("orderBy","1=Fecha,2=Nombre,3=Factura",orderBy,false,false,0,"Text10",null,null)%>
			<%=fb.select("orderByType","asc=Ascendente,desc=Descendente",orderByType,false,false,0,"Text10",null,null)%>
			<%=fb.submit("go","Ir")%>
			</td>
			<%=fb.formEnd()%>
		</tr>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("facturas",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("desc",""+desc)%>
<%=fb.hidden("cod_empresa",request.getParameter("cod_empresa"))%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.hidden("tipoCliente",""+request.getParameter("tipoCliente"))%>
<%=fb.hidden("pac_id",""+request.getParameter("pac_id"))%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("action","")%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("orderBy",orderBy)%>
<%=fb.hidden("orderByType",orderByType)%>
<%=fb.hidden("fact_corp",fact_corp)%>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%if(fp.equals("lista_envio")){%>
						<%=fb.button("addFac","Agregar",false,false, "", "", "onClick=\"javascript:doSubmit(this.value);\"")%>
						<%=fb.button("addFacs","Agregar y Continuar",false,false, "", "", "onClick=\"javascript:doSubmit(this.value);\"")%>
						<%} else {%>
						<%=fb.submit("save","Guardar",true,false)%>
						<%}%>
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
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="7%"><cellbytelabel>Cod. Admi</cellbytelabel>.</td>
					<td width="7%"><cellbytelabel>Cod. Rem</cellbytelabel>.</td>
					<td width="7%"><cellbytelabel>Cod. Fact</cellbytelabel>.</td>
					<td width="10%"><cellbytelabel>Monto Total</cellbytelabel> </td>
					<td width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Nacimiento</cellbytelabel></td>
					<td width="31%"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Id Paciente</cellbytelabel> </td>
					<%if(fp.equals("lista_envio") && file837.trim().equals("S")){%>
					<td width="6%"><cellbytelabel>Rev. Code</cellbytelabel> </td>
					<%}%>
					<td width="10%"><%if(fp.equals("lista_envio")){%><%=fb.checkbox("_chkAll", "",false,false, "1", "", "onClick=\"javascript:jqCheckAll('"+fb.getFormName()+"', 'chkFact', this, true)\"")%><%}%></td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String codFactura = cdo.getColValue("faccodigo");
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
					if(fp.equals("lista_envio") && cdo.getColValue("existe")!=null && !cdo.getColValue("existe").equals("-1")){color="RedText";}
					
				%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("faccodigo"))%>
				<%=fb.hidden("fecha"+i,cdo.getColValue("fechafac"))%>
				<%=fb.hidden("monto_total"+i,cdo.getColValue("montototal"))%>
				<%=fb.hidden("nombre_paciente"+i,cdo.getColValue("nombrepaciente"))%>
				<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
				<%=fb.hidden("saldo"+i,cdo.getColValue("saldo"))%>

				<%=fb.hidden("montodeuda"+i,cdo.getColValue("montodeuda"))%>
				<%=fb.hidden("admsecuencia"+i,cdo.getColValue("admsecuencia"))%>
				<%=fb.hidden("admestado"+i,cdo.getColValue("admestado"))%>
				<%=fb.hidden("admcat"+i,cdo.getColValue("admcat"))%>
				<%=fb.hidden("admcatdesc"+i,cdo.getColValue("admcatdesc"))%>
				<%=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
				<%=fb.hidden("anulada"+i,cdo.getColValue("anulada"))%>
				<%=fb.hidden("pagopor"+i,cdo.getColValue("pagopor"))%>
				<%=fb.hidden("tipotransaccion"+i,cdo.getColValue("tipotransaccion"))%>
				<%=fb.hidden("monto"+i,cdo.getColValue("monto"))%>
				<%=fb.hidden("sw"+i,cdo.getColValue("sw"))%>
				<%=fb.hidden("fechanacimiento"+i,cdo.getColValue("fechanacimiento"))%>
				<%=fb.hidden("codrem"+i,cdo.getColValue("codrem"))%>
				<%=fb.hidden("lista"+i,cdo.getColValue("lista"))%>
				<%=fb.hidden("facturar_a"+i,cdo.getColValue("facturar_a"))%>
				<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
				<%=fb.hidden("cod_empresa"+i,cdo.getColValue("cod_empresa"))%>
				<%=fb.hidden("existe_otra_lista"+i,cdo.getColValue("existe"))%>
				
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
					<td align="center"><%=cdo.getColValue("admsecuencia")%></td>
					<td align="center"><%=cdo.getColValue("codrem")%></td>
					<td align="center"><%=cdo.getColValue("faccodigo")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("montototal"))%></td>
					<td align="center"><%=cdo.getColValue("fechafac")%></td>
					<td align="center"><%=cdo.getColValue("fechanacimiento")%></td>
					<td align="left">&nbsp;<%=cdo.getColValue("nombrepaciente")%></td>
					<td align="center"><%=cdo.getColValue("pac_id")%></td>
					<%if(fp.equals("lista_envio")  && file837.trim().equals("S")){%>
					<td align="center"><%if(cdo.getColValue("show_al").equals("S")){%><%=fb.select("rev_code"+i,alRevCode,"",false,false,0,"Text10",null,"",null,"S")%><%}%></td>
					
					<%}%>
					<td align="center">
					<%if(fp.equals("lista_envio") && fact_corp.equals("S") && (cdo.getColValue("impreso_fiscal")!=null && cdo.getColValue("impreso_fiscal").equals("Y"))){%>Impresa
					<%} else {%>
					<%=(vFacturas.contains(cdo.getColValue("faccodigo")) || vFac.contains(cdo.getColValue("faccodigo")))?"Elegido":fb.checkbox("chkFact"+i,""+i,false,false, "", "", (fp.equals("lista_envio") && cdo.getColValue("valida_saldo").equals("N")?"onClick=\"javascript:chkList("+i+");\"":"onClick=\"javascript:chkSaldo("+i+");chkList("+i+");\""))%>
					<%}%>
					</td>
				</tr>
				<%
				}
				%>
			</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
						<%if(fp.equals("lista_envio")){%>
						<%=fb.button("addFac","Agregar",false,false, "", "", "onClick=\"javascript:doSubmit(this.value);\"")%>
						<%=fb.button("addFacs","Agregar y Continuar",false,false, "", "", "onClick=\"javascript:doSubmit(this.value);\"")%>
						<%} else {%>
						<%=fb.submit("save","Guardar",true,false)%>
						<%}%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>

<%@ include file="../common/footer.jsp"%>


</body>
</html>
<%
} else {

	String cod_empresa = request.getParameter("cod_empresa");
	int keySize=Integer.parseInt(request.getParameter("keySize"));
	if(fp.equals("lista_envio")){
		int lineNo = htFac.size();
		for (int i=0; i<keySize; i++){
			if(request.getParameter("chkFact"+i)!=null){
				CommonDataObject cd = new CommonDataObject();
				if(request.getParameter("cod_empresa"+i)!=null) cd.addColValue("aseguradora", request.getParameter("cod_empresa"+i));
				if(request.getParameter("admcat"+i)!=null) cd.addColValue("categoria", request.getParameter("admcat"+i));
				if(request.getParameter("admcatdesc"+i)!=null) cd.addColValue("categoria_nombre", request.getParameter("admcatdesc"+i));
				cd.addColValue("compania", (String) session.getAttribute("_companyId"));
				if(request.getParameter("lista"+i)!=null) cd.addColValue("lista_old", request.getParameter("lista"+i));
				cd.addColValue("secuencia", "0");
				if(request.getParameter("codigo"+i)!=null) cd.addColValue("factura", request.getParameter("codigo"+i));
				if(request.getParameter("facturar_a"+i)!=null) cd.addColValue("facturar_a", request.getParameter("facturar_a"+i));
				if(request.getParameter("usuario_creacion"+i)!=null) cd.addColValue("usuario_creacion", request.getParameter("usuario_creacion"+i));
				if(request.getParameter("fecha"+i)!=null) cd.addColValue("fecha_creacion", request.getParameter("fecha"+i));
				if(request.getParameter("pac_id"+i)!=null) cd.addColValue("pac_id", request.getParameter("pac_id"+i));
				if(request.getParameter("admsecuencia"+i)!=null) cd.addColValue("admision", request.getParameter("admsecuencia"+i));
				if(request.getParameter("nombre_paciente"+i)!=null) cd.addColValue("nombre_paciente", request.getParameter("nombre_paciente"+i));
				if(request.getParameter("monto_total"+i)!=null) cd.addColValue("monto", request.getParameter("monto_total"+i));
				if(request.getParameter("rev_code"+i)!=null) cd.addColValue("rev_code", request.getParameter("rev_code"+i));
				cd.addColValue("estado", "A");
				lineNo++;
				if (lineNo < 10) key = "00" + lineNo;
				else if (lineNo < 100) key = "0" + lineNo;
				else key = "" + lineNo;
				try{
					htFac.put(key, cd);
					vFac.addElement(""+request.getParameter("codigo"+i));
					System.out.println("adding..."+request.getParameter("codigo"+i));
				} catch(Exception e){ System.err.println(e.getMessage()); }
			}
		}
	} else {
		vFacturas.clear();
		int lineNo = HashDet.size();
		for (int i=0; i<keySize; i++){
			DetallePago dp = new DetallePago();

			dp.setFacCodigo(""+request.getParameter("codigo"+i));
			dp.setFecha(""+request.getParameter("fecha"+i));
			dp.setMontoTotal(""+request.getParameter("monto_total"+i));
			dp.setNombrePaciente(""+request.getParameter("nombre_paciente"+i));
			dp.setPacId(""+request.getParameter("pac_id"+i));
			dp.setSaldo(""+request.getParameter("saldo"+i));

			dp.setMontoDeuda(""+request.getParameter("montodeuda"+i));
			dp.setAdmiSecuencia(""+request.getParameter("admsecuencia"+i));
			dp.setAdmEstado(""+request.getParameter("admestado"+i));
			dp.setAdmCat(""+request.getParameter("admcat"+i));
			dp.setAdmCatDesc(""+request.getParameter("admcatdesc"+i));
			dp.setEstatus(""+request.getParameter("estatus"+i));
			dp.setAnulada(""+request.getParameter("anulada"+i));
			dp.setPagoPor(""+request.getParameter("pagopor"+i));
			dp.setTipoTransaccion(""+request.getParameter("tipotransaccion"+i));
			dp.setMonto(""+request.getParameter("monto"+i));
			dp.setSw(""+request.getParameter("sw"+i));
			dp.setFechaNacimiento(""+request.getParameter("fechanacimiento"+i));
			dp.setCodRem(""+request.getParameter("codrem"+i));
			//dp.setTipoTransaccion("");
			dp.setTransacDetalle("");

			//dp.setMonto(""+request.getParameter("monto"+i));

			key = request.getParameter("key"+i);
			if(request.getParameter("chkFact"+i)!=null){

				lineNo++;
				if (lineNo < 10) key = "00" + lineNo;
				else if (lineNo < 100) key = "0" + lineNo;
				else key = "" + lineNo;

				try{
						HashDet.put(key, dp);
						HashDetKey.put(dp.getFacCodigo(), key);
						vFacturas.addElement(""+request.getParameter("codigo"+i));
				} catch(Exception e){ System.err.println(e.getMessage()); }
			}
		}
	}

	if(request.getParameter("action")!=null && request.getParameter("action").equalsIgnoreCase("Agregar y Continuar")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&lastLineNo="+lastLineNo+"&desc="+desc+"&tipoCliente="+tipoCliente+"&pac_id="+pac_id+"&cod_empresa="+request.getParameter("cod_empresa")+"&codigo="+request.getParameter("codigo")+"&nombre="+request.getParameter("nombre")+"&fg="+request.getParameter("fg")+"&categoria="+request.getParameter("categoria")+"&orderBy="+orderBy+"&orderByType="+orderByType+"&fact_corp="+fact_corp);
		return;
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&lastLineNo="+lastLineNo+"&desc="+desc+"&tipoCliente="+tipoCliente+"&pac_id="+pac_id+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&cod_empresa="+request.getParameter("cod_empresa")+"&codigo="+request.getParameter("codigo")+"&nombre="+request.getParameter("nombre")+"&fg="+request.getParameter("fg")+"&categoria="+request.getParameter("categoria")+"&cds="+request.getParameter("cds")+"&orderBy="+orderBy+"&orderByType="+orderByType+"&fact_corp="+fact_corp);
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&lastLineNo="+lastLineNo+"&desc="+desc+"&tipoCliente="+tipoCliente+"&pac_id="+pac_id+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&cod_empresa="+request.getParameter("cod_empresa")+"&codigo="+request.getParameter("codigo")+"&nombre="+request.getParameter("nombre")+"&fg="+request.getParameter("fg")+"&categoria="+request.getParameter("categoria")+"&cds="+request.getParameter("cds")+"&orderBy="+orderBy+"&orderByType="+orderByType+"&fact_corp="+fact_corp);
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("recibos"))
	{
		if (tipoCliente.equalsIgnoreCase("ARE"))
		{
%>
	window.opener.location = '../caja/aplicar_recibo_emp_det.jsp?cod_empresa=<%=cod_empresa%>&tipoCliente=<%=tipoCliente%>&mode=<%=mode%>&fg=<%=fg%>';
<%
		} else if (tipoCliente.equalsIgnoreCase("ARP"))
		{
%>
	window.opener.location = '../caja/aplicar_recibo_emp_det.jsp?pac_id=<%=pac_id%>&tipoCliente=<%=tipoCliente%>&mode=<%=mode%>&fg=<%=fg%>';
<% 	} else	if (tipoCliente.equalsIgnoreCase("E"))
		{
%>
	window.opener.location = '../caja/detalletransaccion_config.jsp?cod_empresa=<%=cod_empresa%>&tipoCliente=<%=tipoCliente%>&mode=<%=mode%>&fg=<%=fg%>';
<% 	} else	if (tipoCliente.equalsIgnoreCase("P"))
		{
%>
	window.opener.location = '../caja/detalletransaccion_config.jsp?pac_id=<%=pac_id%>&tipoCliente=<%=tipoCliente%>&mode=<%=mode%>&fg=<%=fg%>';
<%
		
		} else 	{
%>
	window.opener.location = '../caja/detalletransaccion_config.jsp?cod_empresa=<%=cod_empresa%>&tipoCliente=<%=tipoCliente%>&mode=<%=mode%>&fg=<%=fg%>';
<%
		}
	}
	else if(fp.equalsIgnoreCase("aplicarRecibos"))
	{%>
		window.opener.location = '../caja/aplicar_recibo_emp_det.jsp?cod_empresa=<%=cod_empresa%>&tipoCliente=<%=tipoCliente%>&mode=<%=mode%>&fg=<%=fg%>';
<%
	}
	else if(fp.equalsIgnoreCase("lista_envio"))
	{%>
		window.opener.location = '../facturacion/reg_lista_envio_det.jsp?change=1&aseguradora=<%=request.getParameter("cod_empresa")%>';
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
