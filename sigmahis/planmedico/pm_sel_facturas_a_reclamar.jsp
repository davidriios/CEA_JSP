<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Beneficio"%>
<%@ page import="issi.admision.Cama"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="vLiqRecl" scope="session" class="java.util.Vector"/>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iLiqRecl" scope="session" class="java.util.Hashtable" />
<% 
/**
==================================================================================
fg= liq_recl Flag para filtrar liquidación de reclamo para beneficiario.
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
ArrayList alCat = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");

String status = request.getParameter("status");
String categoria = request.getParameter("categoria");
String tipoAdm = "";
String factura = request.getParameter("factura");
String noAdmision = request.getParameter("noAdmision");
String admRoot = request.getParameter("admRoot");
String tipoEmpresa = request.getParameter("tipo_empresa");
StringBuffer sbSql  = new  StringBuffer();
String compania = (String)session.getAttribute("_companyId");
String tipoLiq = request.getParameter("tipo");
String sinDet = request.getParameter("sin_det");
String groupByCds = request.getParameter("by_cds");
String tipoAtencion = request.getParameter("tipo_atencion");
String tipoBeneficio = request.getParameter("tipo_beneficio");
String fechaReclamo = request.getParameter("fecha_reclamo");
String descDiagnostico = request.getParameter("desc_diagnostico");
String noAprob = request.getParameter("no_aprob");
String cat_reclamo = request.getParameter("cat_reclamo");
String hosp_si_no = request.getParameter("hosp_si_no");
String hosp_tipo_si = request.getParameter("hosp_tipo_si");
String hosp_tipo_no = request.getParameter("hosp_tipo_no");
String tipo_reclamacion = request.getParameter("tipo_reclamacion");


if(fg==null) fg = "";
if(fp==null) fp = "";
if(tipoEmpresa==null) tipoEmpresa = "";
if(categoria==null) categoria = "";
if(factura==null) factura = "";
if(noAdmision==null) noAdmision = "";
if(admRoot==null) admRoot = "";
if(tipoLiq==null) tipoLiq = "";
if(sinDet==null) sinDet = "";
if(groupByCds==null) groupByCds = "Y";
if(tipoAtencion==null) tipoAtencion = "";
if(tipoBeneficio==null) tipoBeneficio = "";
if(fechaReclamo==null) fechaReclamo = "";
if(descDiagnostico==null) descDiagnostico = "";
if(noAprob==null) noAprob = "";
if(cat_reclamo==null) cat_reclamo = "";
if(hosp_si_no==null) hosp_si_no = "";
if(hosp_tipo_si==null) hosp_tipo_si = "";
if(hosp_tipo_no==null) hosp_tipo_no = "";
if(tipo_reclamacion==null) tipo_reclamacion = "";

String dob = request.getParameter("dob");
String compReplica = "",compFar = "";

String provincia = "", sigla = "", tomo = "", asiento = "", pasaporte = "", cod_paciente = "", nombre = "", no_admision = "";
String estado = "A";
String filterCat = "";

if(request.getParameter("estado")!=null) estado = request.getParameter("estado");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

if (dob == null) dob = "";

String sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision where codigo <> 5 order by codigo";

if (request.getMethod().equalsIgnoreCase("GET")){
    
    iLiqRecl.clear(); 
    //vLiqRecl.clear();
    
   ArrayList alCds = sbb.getBeanList(ConMgr.getConnection(), " select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cds_centro_servicio where estado = 'A' order by 2 ", CommonDataObject.class);    

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

	if (request.getParameter("provincia") != null && request.getParameter("sigla") != null && request.getParameter("tomo") != null && request.getParameter("asiento") != null && !request.getParameter("provincia").equals("") &&  !request.getParameter("sigla").equals("") &&  !request.getParameter("tomo").equals("") &&  !request.getParameter("asiento").equals("")){
		appendFilter += " and upper(p.provincia) like '"+request.getParameter("provincia").toUpperCase()+"%' and upper(p.sigla) like '"+request.getParameter("sigla").toUpperCase()+"%' and upper(p.tomo) like '"+request.getParameter("tomo").toUpperCase()+"%' and upper(p.asiento) like '"+request.getParameter("asiento").toUpperCase()+"%'";
		provincia = request.getParameter("provincia");
		sigla = request.getParameter("sigla");
		tomo = request.getParameter("tomo");
		asiento = request.getParameter("asiento");
	}
    if (request.getParameter("pasaporte") != null && !request.getParameter("pasaporte").trim().equals("")){
		appendFilter += " and upper(p.pasaporte) like '%"+request.getParameter("pasaporte").toUpperCase()+"%'";
		pasaporte = request.getParameter("pasaporte");
	}
	if (request.getParameter("no_admision") != null && !request.getParameter("no_admision").trim().equals("")){
		appendFilter += " and a.secuencia like '%"+request.getParameter("no_admision").toUpperCase()+"%'";
		no_admision = request.getParameter("no_admision");
	}
	if (request.getParameter("noAdmision") != null && !request.getParameter("noAdmision").trim().equals(""))
	{
		appendFilter += " and a.secuencia <> "+request.getParameter("noAdmision");
		noAdmision = request.getParameter("noAdmision");
	}
	if (request.getParameter("cod_paciente") != null && !request.getParameter("cod_paciente").trim().equals("")){
		appendFilter += " and upper(a.pac_id) = "+request.getParameter("cod_paciente");
		cod_paciente = request.getParameter("cod_paciente");
	}
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals("")){
		appendFilter += " and upper(c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada))) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		nombre = request.getParameter("nombre");
	}
	if (request.getParameter("dob") != null && !request.getParameter("dob").equals("")){
		appendFilter += " and to_char(a.fecha_nacimiento,'dd/mm/yyyy')='"+dob+"'";
		dob = request.getParameter("dob");
	}
	
    if (fp.equalsIgnoreCase("liq_recl")){
        sbSql = new StringBuffer();
        
        if(tipoLiq.trim().equals("0")) groupByCds = "";
        
        if (groupByCds.trim().equalsIgnoreCase("Y")) sbSql.append("select zz.pac_id, zz.fac, zz.fecha_ingreso, zz.cedula, zz.fecha_egreso, zz.codigo_paciente, zz.fecha_nacimiento, zz.admision, zz.nombre, zz.edad, zz.sexo, zz.honorario_por, zz.centro_servicio, zz.tipo_cargo, sum(nvl(zz.monto,0)) total_x_fila, sum(nvl(zz.cantidad,0)) cantidad, sum(nvl(zz.total_x_fila,0)) monto, (select descripcion from tbl_cds_tipo_servicio where codigo = zz.tipo_cargo and rownum = 1) descripcion from ( ");
    
        sbSql.append(" select tbl1.*, cargos.* from (  select distinct a.pac_id, ff.codigo as fac, to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fecha_ingreso, nvl(c.pasaporte,c.provincia||'-'||c.sigla||'-'||c.tomo||'-'||c.asiento||'-'||c.d_cedula) as cedula, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fecha_egreso, cc.codigo_paciente,cc. fecha_nacimiento, a.secuencia admision, cc.nombrePaciente as nombre, nvl(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(c.f_nac,a.fecha_nacimiento))/12),0) as edad, c.sexo from tbl_pm_cliente c, tbl_adm_admision a, (select * from tbl_adm_beneficios_x_admision where nvl(estado,'A')='A' and prioridad=1) bb, tbl_fac_factura ff ,(select d.id, p.pac_id, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, p.codigo, p.nombre_paciente as nombrePaciente, p.primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre) as nombre, decode(primer_apellido,null,'',primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) as apellido, sexo, estatus, pasaporte, provincia, sigla, tomo, asiento, d_cedula, vip, edad||' a '||edad_mes||' m '||edad_dias || ' d' edad, residencia_direccion, p.codigo codigo_paciente from  vw_pm_cliente p, tbl_pm_sol_contrato_det d, tbl_pm_solicitud_contrato s where pac_id is not null and d.id_cliente = p.codigo /*and tipo_clte = 'C'*/ and s.fecha_ini_plan is not null and s.estado in ('A', 'F') and d.estado = 'A' and s.id = d.id_solicitud) cc where c.pac_id = a.pac_id and a.estado = 'I' and a.codigo_paciente=bb.paciente(+) and a.fecha_nacimiento=bb.fecha_nacimiento(+) and a.secuencia=bb.admision(+) and ff.pac_id = a.pac_id and ff.admi_secuencia = a.secuencia and ff.facturar_a = 'E' and ff.estatus in ('P', 'C') and bb.empresa in ( select codigo from tbl_adm_empresa where grupo_empresa = get_sec_comp_param(");
        sbSql.append(compania);
        sbSql.append(",'LIQ_RECL_TIPO_EMP') ) and a.compania = ");
        sbSql.append(compania);
        sbSql.append(" and a.categoria = ");
        sbSql.append(categoria);
        sbSql.append(appendFilter);
        sbSql.append(" and cc.pac_id = ff.pac_id) tbl1, ( select trim(aa.descripcions) as descripcion, aa.centro_servicio, aa.monto, aa.cantidad_total as cantidad, aa.tipo_cargo, null codigo_precio, aa.monto_total as total_x_fila, nvl(aa.med_codigo, aa.empre_codigo) medicoOrEmpre, aa.descripcions nombreMedicoOrEmpre, null seq_trx,  case when aa.med_codigo is not null then 'M' else 'E' end honorario_por, aa.med_codigo medico, aa.empre_codigo empresa, case when aa.med_codigo is not null then 'N' else 'Y' end pagar_sociedad,  aa.pac_id as pacid, aa.admi_secuencia from ( select z.*, decode (z.tipo_transaccion, 'C', nvl (z.descripcion, ' '), 'D', decode (z.tipo_cargo,get_sec_comp_param("+compania+",'COD_TIPO_SERV_HON'), coalesce ((select   '[' || codigo || '] ' || nombre from tbl_adm_empresa where codigo = z.empre_codigo),(select '['|| nvl(reg_medico,codigo)|| '] '|| primer_apellido|| ' '|| segundo_apellido|| ' '|| apellido_de_casada|| ', '|| primer_nombre || ' '|| segundo_nombre from   tbl_adm_medico where   codigo = z.med_codigo)), nvl (z.descripcion, ' ') ), 'H', coalesce ((select '[' || codigo || '] ' || nombre from tbl_adm_empresa where codigo = z.empre_codigo),(select '['|| nvl(reg_medico,codigo)|| '] '|| primer_apellido|| ' '|| segundo_apellido|| ' '|| apellido_de_casada|| ', '|| primer_nombre || ' '|| segundo_nombre from tbl_adm_medico where   codigo = z.med_codigo)), nvl (z.descripcion, ' ')) as descripcions from (select c.descripcion centro_servicio_desc, (case when x.cant_hon > 0 and x.cant_hon > x.cant_dev then 'H' when x.cant_cargo > 0 and x.cant_cargo > x.cant_dev then 'C' else 'D' end) tipo_transaccion, x.centro_servicio, x.tipo_cargo, x.med_codigo, x.empre_codigo, x.descripcion, (x.monto + nvl (x.recargo, 0)) as monto, x.cantidad cantidad_total, x.cantidad * (x.monto + nvl (x.recargo, 0)) monto_total, coalesce (x.procedimiento, x.habitacion, '' || x.cds_producto, '' || x.cod_uso, '' || x.otros_cargos, '' || x.cod_paq_x_cds, decode (x.articulo, null, '', x.articulo), ' ') as trabajo,x.fecha_cargo as fecha_cargos,f_cargo, x.pac_id, x.admi_secuencia, x.compania from ( select a.compania, a.pac_id, a.admi_secuencia, (select reporta_a from tbl_cds_centro_servicio x where x.codigo = b.centro_servicio) centro_servicio,  b.tipo_cargo, a.med_codigo, a.empre_codigo, b.descripcion, b.monto, nvl(b.recargo, 0) recargo, b.procedimiento, b.habitacion, b.cds_producto, b.cod_uso, b.otros_cargos, b.cod_paq_x_cds, b.art_familia || '-' || b.art_clase || '-' || b.inv_articulo articulo, sum(decode(b.tipo_transaccion,'D', -1*b.cantidad, 0)) cant_dev, sum(decode(b.tipo_transaccion,'H', b.cantidad, 0)) cant_hon, sum(decode(b.tipo_transaccion,'C', b.cantidad, 0)) cant_cargo, (sum(decode(b.tipo_transaccion,'H', b.cantidad, 0)) + sum(decode(b.tipo_transaccion,'C', b.cantidad, 0))+sum(decode(b.tipo_transaccion,'D', -1*b.cantidad, 0))) cantidad,to_char(b.fecha_cargo,'dd/mm/yyyy') fecha_cargo,b.fecha_cargo f_cargo from  tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.compania = ");
        sbSql.append(compania);
        
        if (tipoLiq.trim().equals("0") && sinDet.equals("")) {
          sbSql.append(" and b.tipo_transaccion = 'H' and (a.med_codigo is not null or a.empre_codigo is not null)");
        }else if (tipoLiq.trim().equals("1") || tipoLiq.trim().equals("2")) {
          sbSql.append(" and b.tipo_transaccion != 'H' /*and a.med_codigo is null and a.empre_codigo is null*/");
        } 
        
        sbSql.append(" and a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.compania = b.compania and a.tipo_transaccion = b.tipo_transaccion group by a.compania, a.pac_id, a.admi_secuencia, b.centro_servicio,  b.tipo_cargo, a.med_codigo, a.empre_codigo, b.descripcion, b.monto, nvl(b.recargo, 0), b.procedimiento, b.habitacion, b.cds_producto, b.cod_uso, b.otros_cargos, b.cod_paq_x_cds, b.art_familia || '-' || b.art_clase || '-' || b.inv_articulo ,b.fecha_cargo) x, tbl_cds_centro_servicio c where x.centro_servicio = c.codigo and x.cantidad != 0) z ) aa ) cargos where exists (select null from tbl_fac_factura f where f.codigo = tbl1.fac and f.estatus in ('P', 'C')) and tbl1.pac_id = cargos.pacid and tbl1.admision = cargos.admi_secuencia ");
        
        sbSql.append(" and not exists (select null from tbl_pm_det_liq_reclamo d, tbl_pm_liquidacion_reclamo l where d.pac_id = l.pac_id and d.fac_secuencia = l.admi_secuencia and l.num_factura =  tbl1.fac /*and trim(d.descripcion) = cargos.descripcion*/ and l.status not in( 'R','N') and l.tipo = "+tipoLiq+" )");
        
        if (groupByCds.trim().equalsIgnoreCase("Y"))  sbSql.append(" ) zz group by zz.pac_id, zz.fac, zz.fecha_ingreso, zz.cedula, zz.fecha_egreso, zz.codigo_paciente, zz.fecha_nacimiento, zz.admision, zz.nombre, zz.edad, zz.sexo, zz.honorario_por, zz.centro_servicio, zz.tipo_cargo order by 1, 9, 2, 12 ");
        else sbSql.append(" order by 1, 9, 2, 12 ");
    }

	if(request.getParameter("beginSearch") != null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script>
document.title = 'Paciente - '+document.title;
var s  = "<%=sbSql%>";
function setPaciente(k)
{
	if (eval('document.paciente.estatus'+k).value.toUpperCase() == 'I' && '<%=fp%>' != 'liq_recl' ){
		CBMSG.warning('No está permitido seleccionar pacientes inactivos!!');
	}	else {
    <% if (fp.equalsIgnoreCase("liq_recl")){ %>
        if(window.opener.document.form0.codigo_paciente)window.opener.document.form0.codigo_paciente.value 		= eval('document.paciente.codigo_paciente'+k).value;
		if(window.opener.document.form0.fecha_nacimiento)window.opener.document.form0.fecha_nacimiento.value 	= eval('document.paciente.fechaNacimiento'+k).value;
		if(window.opener.document.form0.admSecuencia)window.opener.document.form0.admSecuencia.value		= eval('document.paciente.admision'+k).value;
		if(window.opener.document.form0.nombreCliente)window.opener.document.form0.nombreCliente.value    	= eval('document.paciente.nombrePaciente'+k).value;
		if(window.opener.document.form0.pacId)window.opener.document.form0.pacId.value = eval('document.paciente.pac_id'+k).value;
        if(window.opener.document.form0.cedulaPasaporte)window.opener.document.form0.cedulaPasaporte.value = eval('document.paciente.cedula'+k).value;
        if(window.opener.document.form0.edad)window.opener.document.form0.edad.value = eval('document.paciente.edad'+k).value;
        if(window.opener.document.form0.sexo)window.opener.document.form0.sexo.value = eval('document.paciente.sexo'+k).value;
        if(window.opener.document.form0.fecha_ingreso)window.opener.document.form0.fecha_ingreso.value = eval('document.paciente.fechaIngreso'+k).value;
        if(window.opener.document.form0.fecha_egreso)window.opener.document.form0.fecha_egreso.value = eval('document.paciente.fechaEgreso'+k).value; 
        
        if(window.opener.document.form0.medico)window.opener.document.form0.medico.value = eval('document.paciente.medico_cabecera'+k).value; 
        if(window.opener.document.form0.medico_nombre)window.opener.document.form0.medico_nombre.value = eval('document.paciente.nombre_medico_cabecera'+k).value; 
        if(window.opener.document.form0.poliza)window.opener.document.form0.poliza.value = eval('document.paciente.poliza'+k).value; 
        if(window.opener.document.form0.no_factura)window.opener.document.form0.no_factura.value = eval('document.paciente.fac'+k).value; 
        
        if (typeof window.opener.getHospDays == 'function') { window.opener.getHospDays(); }
        <%if(!sinDet.equals("")){%>
          window.close();
        <%}%>
    <%}%>
    }
}

function getMain(formx)
{
	formx.estado.value = document.search00.estado.value;
	formx.categoria.value = document.search00.categoria.value;
	return true;
}
function setValue(id,obj)
{
var estado = document.search00.estado.value;
var tipo = document.search00.categoria.value;
<%if(fg != null && fg.trim().equals("CU")){%>
if(id=='0')
{
	if(tipo=='2') //obj.value = 'E';
	document.search00.estado.value='E';
	else if(tipo=='1')//	obj.value = 'A';
	document.search00.estado.value='A';
}else if(id=='1')
{
	if(estado =='E')
		document.search00.categoria.value = '2';
	if(estado =='A')
		document.search00.categoria.value = '1';
}
<%}%>
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}

//var ignoreSelectAnyWhere = true;

$(document).ready(function(){
   
   $(".tipo_servicio").focus(function(e){
     $("#nombre").focus();
   });
   
   $("input[type='radio']").change(function(){
     var fac = $(this).data("fac");  
     $(".checks").prop("checked", false);     
     $(".checks-"+fac).prop("checked",true);
     
     <%if(tipoLiq.equals("0")){%>
        
        var medOrEmp = $(".checks:checked").map(function() {
             return [$(this).data('medicoorempre')];
         }).get();
              
        if ($(".checks:checked").length == 1) $("#paciente").submit();
        else if ($(".checks:checked").length > 1){
          if (mixingFacs(medOrEmp)==false){
            CBMSG.error("Para las liquidaciones de tipo Honorarios, no debería poder seleccionar mas de un registro!");
            return false;
          }else $("#paciente").submit();
        }
     <%}else{%>
       $("#paciente").submit();
     <%}%>
   });
   
   $("#b-add, #t-add").click(function(e){
     e.preventDefault();
     
     var facs = $(".checks:checked").map(function() {
         return [$(this).data('fac')];
     }).get();
     
     <%if(tipoLiq.equals("0")){%>
        
        var medOrEmp = $(".checks:checked").map(function() {
             return [$(this).data('medicoorempre')];
         }).get();
              
        if ($(".checks:checked").length == 1) $("#paciente").submit();
        else if ($(".checks:checked").length > 1){
          if (mixingFacs(medOrEmp)==false){
            CBMSG.error("Para las liquidaciones de tipo Honorarios, no debería poder seleccionar mas de un registro!");
            return false;
          }else $("#paciente").submit();
        }
     <%}else{%>
       $("#paciente").submit();
     <%}%>
     
     
     if (facs.length){
        if (!!mixingFacs(facs)) {
          $("#paciente").submit();
        }
        else CBMSG.error("No puede esgoger entre varias facturas!");
     }
   });   
});

function mixingFacs(array) {
    var first = array[0];
    return array.every(function(element) {
        return element === first;
    });
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PACIENTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">
                    <%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart(true)%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("admRoot",admRoot)%>
					<%=fb.hidden("tipo_empresa",tipoEmpresa)%>
					<%=fb.hidden("beginSearch","")%>
					<%=fb.hidden("tipo",tipoLiq)%>
					<%=fb.hidden("tipo_atencion",tipoAtencion)%>
					<%=fb.hidden("tipo_beneficio",tipoBeneficio)%>
					<%=fb.hidden("fecha_reclamo",fechaReclamo)%>
					<%=fb.hidden("desc_diagnostico",descDiagnostico)%>
					<%=fb.hidden("no_aprob",noAprob)%>
					<%=fb.hidden("cat_reclamo",cat_reclamo)%>
					<%=fb.hidden("hosp_si_no",hosp_si_no)%>
					<%=fb.hidden("hosp_tipo_si",hosp_tipo_si)%>
					<%=fb.hidden("hosp_tipo_no",hosp_tipo_no)%>
					<%=fb.hidden("tipo_reclamacion",tipo_reclamacion)%>
					<td width="8%" align="right">
						<cellbytelabel id="1">Categor&iacute;a</cellbytelabel>
					</td>
					<td width="26%">
						<%=fb.select(ConMgr.getConnection(), sqlCat, "categoria", categoria,false,false,0,"",null,"onChange=\"javascript:setValue(0,this)\"","","")%>
					</td>
					<td width="12%" align="right">
						<cellbytelabel id="2">Estado</cellbytelabel>
					 </td>
					<td width="21%">
						<%
						String strEstado = "A=Activo,E=Espera,S=Especial,C=Cancelada";
						if(fp.equalsIgnoreCase("liq_recl")) strEstado = "I=Inactiva";

						%>
						<%=fb.select("estado",strEstado,estado,false,false,0,"",null,"onChange=\"javascript:setValue(1,this)\"","",(fp.equals("consulta_general")||fp.equals("secciones_guardadas")?"T":""))%>
					</td>
					<td width="12%" align="right"><%=(fp.equals("consulta_general")?"Factura":"")%>&nbsp;</td>
					<td width="21%">&nbsp;</td>
				</tr>
				<tr class="TextFilter">
					<td width="8%" align="right">
						<cellbytelabel id="3">C&eacute;dula</cellbytelabel>
					</td>
					<td width="26%">
						<%=fb.textBox("provincia",provincia,false,false,false,2)%>
						<%=fb.textBox("sigla",sigla,false,false,false,2)%>
						<%=fb.intBox("tomo",tomo,false,false,false,4)%>
						<%=fb.intBox("asiento",asiento,false,false,false,5)%>
					</td>
					<td width="12%" align="right">
						<cellbytelabel id="4">Pasaporte</cellbytelabel>
					</td>
					<td width="21%">
						<%=fb.textBox("pasaporte",pasaporte,false,false,false,20)%>
					</td>
					<td width="12%" align="right">
					<cellbytelabel id="5">Cod. Paciente</cellbytelabel>
					</td>
					<td width="21%">
					<%=fb.intBox("cod_paciente",cod_paciente,false,false,false,20)%>
					</td>
				</tr>
				<tr class="TextFilter">

					<td width="8%" align="right">
						<cellbytelabel id="6">Nombre</cellbytelabel>
					</td>
					<td width="26%">
						<%=fb.textBox("nombre",nombre,false,false,false,40)%>
					</td>
					<td width="12%" align="right">
						<cellbytelabel id="7">Fecha de Nacimiento</cellbytelabel>
					</td>
					<td width="21%">
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="nameOfTBox1" value="dob"/>
						<jsp:param name="valueOfTBox1" value="<%=dob%>"/>
						</jsp:include>
					</td>
					<td width="12%" align="right">
					<cellbytelabel id="8">No. Admisi&oacute;n</cellbytelabel>
					</td>
					<td width="21%">
					<%//=fb.intBox("no_admision",no_admision,false,false,false,20)%>
					<%=fb.intBox("no_admision",no_admision,false,false,false,(fp.equals("liq_recl")?5:20))%>
                    <%if (fp.equals("liq_recl")){%>
                    <label class="pointer">
                    <%=fb.checkbox("sin_det","Y",!sinDet.equals(""),false)%>Manual?</label>
                    <%}%>
					<%=fb.submit("go","Ir")%>
					</td>
				</tr>
					<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
    
    
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("provincia",provincia)%>
					<%=fb.hidden("sigla",sigla)%>
					<%=fb.hidden("tomo",tomo)%>
					<%=fb.hidden("asiento",asiento)%>
					<%=fb.hidden("pasaporte",pasaporte)%>
					<%=fb.hidden("cod_paciente",cod_paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("no_admision",no_admision)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("admRoot",admRoot)%>
                    <%=fb.hidden("beginSearch","")%>
                    <%=fb.hidden("tipo_empresa",tipoEmpresa)%>
                    <%=fb.hidden("tipo",tipoLiq)%>
                    <%=fb.hidden("sin_det",sinDet)%>
                    <%=fb.hidden("tipo_atencion",tipoAtencion)%>
					<%=fb.hidden("tipo_beneficio",tipoBeneficio)%>
					<%=fb.hidden("fecha_reclamo",fechaReclamo)%>
					<%=fb.hidden("desc_diagnostico",descDiagnostico)%>
					<%=fb.hidden("no_aprob",noAprob)%>
					<%=fb.hidden("cat_reclamo",cat_reclamo)%>
					<%=fb.hidden("hosp_si_no",hosp_si_no)%>
					<%=fb.hidden("hosp_tipo_si",hosp_tipo_si)%>
					<%=fb.hidden("hosp_tipo_no",hosp_tipo_no)%>
					<%=fb.hidden("tipo_reclamacion",tipo_reclamacion)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="9">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="10">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="11">hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("provincia",provincia)%>
					<%=fb.hidden("sigla",sigla)%>
					<%=fb.hidden("tomo",tomo)%>
					<%=fb.hidden("asiento",asiento)%>
					<%=fb.hidden("pasaporte",pasaporte)%>
					<%=fb.hidden("cod_paciente",cod_paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("no_admision",no_admision)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("admRoot",admRoot)%>
                    <%=fb.hidden("tipo_empresa",tipoEmpresa)%>
                    <%=fb.hidden("tipo",tipoLiq)%>
                    <%=fb.hidden("sin_det",sinDet)%>
                    <%=fb.hidden("tipo_atencion",tipoAtencion)%>
					<%=fb.hidden("tipo_beneficio",tipoBeneficio)%>
					<%=fb.hidden("fecha_reclamo",fechaReclamo)%>
					<%=fb.hidden("desc_diagnostico",descDiagnostico)%>
					<%=fb.hidden("no_aprob",noAprob)%>
					<%=fb.hidden("cat_reclamo",cat_reclamo)%>
					<%=fb.hidden("hosp_si_no",hosp_si_no)%>
					<%=fb.hidden("hosp_tipo_si",hosp_tipo_si)%>
					<%=fb.hidden("hosp_tipo_no",hosp_tipo_no)%>
					<%=fb.hidden("tipo_reclamacion",tipo_reclamacion)%>
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

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
            
<tr class="TextRow02"><td align="right" colspan="7">
<input type="button" name="t-add" id="t-add" value="Agregar" class="CellbyteBtn"<%=!sinDet.equals("")?" disabled":""%>>
</td></tr>
              
<%fb = new FormBean("paciente",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("clasificacion","")%>
<%=fb.hidden("pacienteId","")%>
<%=fb.hidden("admision","")%>
<%=fb.hidden("provincia",provincia)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("pasaporte",pasaporte)%>
<%=fb.hidden("cod_paciente",cod_paciente)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("no_admision",no_admision)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("doble_msg","")%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("admRoot",admRoot)%>
<%=fb.hidden("beginSearch","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("tipo_empresa",tipoEmpresa)%>
<%=fb.hidden("tipo",tipoLiq)%>
<%=fb.hidden("sin_det",sinDet)%>
<%=fb.hidden("tipo_atencion",tipoAtencion)%>
<%=fb.hidden("tipo_beneficio",tipoBeneficio)%>
<%=fb.hidden("fecha_reclamo",fechaReclamo)%>
<%=fb.hidden("desc_diagnostico",descDiagnostico)%>
<%=fb.hidden("no_aprob",noAprob)%>
<%=fb.hidden("cat_reclamo",cat_reclamo)%>
<%=fb.hidden("hosp_si_no",hosp_si_no)%>
<%=fb.hidden("hosp_tipo_si",hosp_tipo_si)%>
<%=fb.hidden("hosp_tipo_no",hosp_tipo_no)%>
<%=fb.hidden("tipo_reclamacion",tipo_reclamacion)%>

<tr class="TextHeader">
   <%if(sinDet.equals("")){%>
    <td width="8%" align="center"><cellbytelabel>Hon.Por</cellbytelabel></td>
    <td width="40%" align="center"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
    <td width="18%" align="center"><cellbytelabel>Centro Servicio</cellbytelabel></td>
    <td width="18%" align="center"><cellbytelabel>Tipo Servicio</cellbytelabel></td>
    <td width="6%" align="center"><cellbytelabel>Cantidad</cellbytelabel></td>
    <td width="8%" align="right"><cellbytelabel>Monto</cellbytelabel></td>
    <td width="2%" align="center"><cellbytelabel></cellbytelabel></td>
    <%}else{%>
      <td width="10%"><cellbytelabel>PID</cellbytelabel></td>
      <td width="10%"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
      <td width="5%"><cellbytelabel>Poliza</cellbytelabel></td>
      <td width="50%"><cellbytelabel>Nombre Paciente</cellbytelabel></td>
      <td width="10%"><cellbytelabel>Fecha Ingreso</cellbytelabel></td>
      <td width="10%"><cellbytelabel>Fecha Egreso</cellbytelabel></td>
      <td width="5%"></td>
    <%}%>
</tr>
<%
String gPac = "", gFac = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
    //String _key = cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision")+"-"+cdo.getColValue("descripcion");
    String _key = cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision")+"-"+cdo.getColValue("fac")+"-"+cdo.getColValue("descripcion");
    String _i = "";
%>
				<%=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
				<%=fb.hidden("codigo_paciente"+i,cdo.getColValue("codigo_paciente"))%>
				<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
				<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
				<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
				<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
				<%=fb.hidden("dCedula"+i,cdo.getColValue("d_cedula"))%>
				<%=fb.hidden("pasaporte"+i,cdo.getColValue("pasaporte"))%>
				<%=fb.hidden("id_paciente"+i,cdo.getColValue("id_paciente"))%>
				<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
				<%=fb.hidden("nombrePaciente"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("fechaNacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
				<%=fb.hidden("fechaIngreso"+i,cdo.getColValue("fecha_ingreso"))%>
				<%=fb.hidden("fechaEgreso"+i,cdo.getColValue("fecha_egreso"))%>
				<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
				<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
				<%=fb.hidden("categoriaDesc"+i,cdo.getColValue("desc_categoria"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("desc_estado"+i,cdo.getColValue("desc_estado"))%>
				<%=fb.hidden("jubilado"+i,cdo.getColValue("jubilado"))%>
				<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
				<%=fb.hidden("clasificacion"+i,cdo.getColValue("clasificacion"))%>
				<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
				<%=fb.hidden("nombreEmpresa"+i,cdo.getColValue("nombreEmpresa"))%>

				<%if (fg.trim().equals("DIET") || fg.trim().equals("CU"))
				{%>
				<%=fb.hidden("tipoIncremento"+i,cdo.getColValue("tipoIncremento"))%>
				<%=fb.hidden("incremento"+i,cdo.getColValue("incremento"))%>
				<%}%>

				<%=fb.hidden("edad"+i,cdo.getColValue("edad"))%>
				<%=fb.hidden("embarazada"+i,cdo.getColValue("embarazada"))%>
				<%=fb.hidden("area"+i,cdo.getColValue("area"))%>
				<%=fb.hidden("hosp_directa"+i,cdo.getColValue("hosp_directa"))%>
				<%=fb.hidden("dsp_tipo_admision"+i,cdo.getColValue("dsp_tipo_admision"))%>
				<%if (fp.equalsIgnoreCase("mat_paciente") || fp.equalsIgnoreCase("sol_img_estudio") || fp.equals("sol_lab_estudio")|| fp.equals("edit_cita")|| fp.equals("liq_recl")){%>
				<%=fb.hidden("cedulaPasaporte"+i,cdo.getColValue("cedulaPasaporte"))%>
				<%}%>

				<%=fb.hidden("descuento"+i,cdo.getColValue("descuento"))%>
				<%=fb.hidden("cambioPrecio"+i,cdo.getColValue("cambioPrecio"))%>
				<%=fb.hidden("edad_mes"+i,cdo.getColValue("edad_mes"))%>
				<%=fb.hidden("edad_dias"+i,cdo.getColValue("edad_dias"))%>
				<%=fb.hidden("area_desc"+i,cdo.getColValue("area_desc"))%>
				<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
				<%=fb.hidden("nombre_medico"+i,cdo.getColValue("nombre_medico"))%>
				<%=fb.hidden("medico_cabecera"+i,cdo.getColValue("medico_cabecera"))%>
				<%=fb.hidden("nombre_medico_cabecera"+i,cdo.getColValue("nombre_medico_cabecera"))%>
				<%=fb.hidden("empresa_nombre"+i,cdo.getColValue("empresa_nombre"))%>
				<%=fb.hidden("primer_nombre"+i,cdo.getColValue("primer_nombre"))%>
				<%=fb.hidden("segundo_nombre"+i,cdo.getColValue("segundo_nombre"))%>
				<%=fb.hidden("primer_apellido"+i,cdo.getColValue("primer_apellido"))%>
				<%=fb.hidden("segundo_apellido"+i,cdo.getColValue("segundo_apellido"))%>
				<%=fb.hidden("apellido_de_casada"+i,cdo.getColValue("apellido_de_casada"))%>
				<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
				<%=fb.hidden("residenciaDireccion"+i,cdo.getColValue("residencia_direccion"))%>
				<%=fb.hidden("telefono"+i,cdo.getColValue("telefono"))%>
				<%=fb.hidden("cama"+i,cdo.getColValue("cama"))%>
				<%=fb.hidden("doble_msg"+i,cdo.getColValue("doble_msg"))%>
				<%=fb.hidden("tipo_empresa"+i, tipoEmpresa)%>
				<%=fb.hidden("poliza"+i,cdo.getColValue("poliza"))%>
				<%=fb.hidden("fac"+i,cdo.getColValue("fac"))%>
				<%=fb.hidden("tipo_transaccion"+i,"F")%>
				<%=fb.hidden("seq_trx"+i, cdo.getColValue("seq_trx"))%>
				<%=fb.hidden("cantidad"+i, cdo.getColValue("cantidad"))%>
				<%=fb.hidden("monto"+i, cdo.getColValue("monto"))%>
				<%=fb.hidden("total_x_fila"+i, cdo.getColValue("total_x_fila"))%>
				<%=fb.hidden("descripcion"+i, cdo.getColValue("descripcion"))%>
				<%=fb.hidden("codigo_precio"+i, cdo.getColValue("codigo_precio"))%>
				<%=fb.hidden("medicoOrEmpre"+i, cdo.getColValue("medicoOrEmpre"))%>
				<%=fb.hidden("nombreMedicoOrEmpre"+i, cdo.getColValue("nombreMedicoOrEmpre"))%>
				<%=fb.hidden("empresa"+i, cdo.getColValue("empresa"))%>
				<%=fb.hidden("medico"+i, cdo.getColValue("medico"))%>
				<%=fb.hidden("pagar_sociedad"+i, cdo.getColValue("pagar_sociedad"))%>
				<%=fb.hidden("nombre_paciente"+i, cdo.getColValue("nombre"))%>
                
                <%if(sinDet.equals("")){%>
                
                <% if (!gPac.equals(cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision")) ){%>
                  <tr class="TextHeader">
                    <td colspan="7">[<%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%>]&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("nombre")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("cedula")%></td>
                  </tr>
                <% }%>
                <% if ( !gFac.equals(cdo.getColValue("fac")) ){%>
                  <tr class="TextHeader">
                    <td colspan="6">Factura #<%=cdo.getColValue("fac")%></td>
                    <td align="right">
                    
                    <input type="radio" name="check" id="check" value="<%=cdo.getColValue("fac")%>" data-fac="<%=cdo.getColValue("fac")%>">
                    
                    </td>
                  </tr>
                <% 
                }%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setPaciente(<%=i%>)" style="text-decoration:none; cursor:pointer">
					<td align="center"><%=cdo.getColValue("honorario_por")%></td>
					<td><%=cdo.getColValue("descripcion", " ")%></td>
					<td>
                      <%=fb.select("cds"+i,alCds,cdo.getColValue("centro_servicio"),false,true,0,"","width:225px","","","")%>
                    </td>
					<td>
                    <%=fb.select("tipo_servicio"+i,"","",false,false,0,"tipo_servicio","width:225px","")%>
                    <script>
                        loadXML('../xml/tipo_serv_x_cds_<%=UserDet.getUserId()%>.xml','tipo_servicio<%=i%>','<%=cdo.getColValue("tipo_cargo")%>','VALUE_COL','LABEL_COL','<%=cdo.getColValue("centro_servicio")%>','KEY_COL','');
                    </script>
                    
                    </td>
					<td align="center"><%=cdo.getColValue("cantidad")%></td>
					<td align="right"><%=cdo.getColValue("monto")%></td>
					<td align="center">
                    
                     <%//if ((fp.equalsIgnoreCase("liq_recl")) && vLiqRecl.contains(_key)){%><!--Elegido--><%//}else{%>
                    <input type="checkbox" name="check<%=i%>" id="check<%=i%>" class="checks checks-<%=cdo.getColValue("fac")%>" value="<%=i%>" data-fac="<%=cdo.getColValue("fac")%>" data-medicoorempre="<%=cdo.getColValue("medicoOrEmpre")%>">
                    
                    <%//}%>
                    
                    
                    </td>
				</tr>
                <%}else{%>
                <% if (!gPac.equals(cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision")) ){%>
                <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setPaciente(<%=i%>)" style="text-decoration:none; cursor:pointer">
                <td><%=cdo.getColValue("pac_id")%>-<%=cdo.getColValue("admision")%></td>
                <td><%=cdo.getColValue("cedula")%></td>
                <td><%=cdo.getColValue("poliza")%></td>
                <td><%=cdo.getColValue("nombre")%></td>
                <td><%=cdo.getColValue("fecha_ingreso")%></td>
                <td><%=cdo.getColValue("fecha_egreso")%></td>
                <td align="center"><input type="radio" name="check_sin_det" class="check_sin_det" data-i="<%=i%>"></td>
                </tr>
                <%}%>
                <%}%>
<%
gPac = cdo.getColValue("pac_id")+"-"+cdo.getColValue("admision");
gFac = cdo.getColValue("fac");
}
%>
<%=fb.formEnd()%>
<tr class="TextRow01"><td colspan="7">&nbsp;</td></tr>
<tr class="TextRow02"><td align="right" colspan="7">
<input type="button" name="b-add" id="b-add" value="Agregar" class="CellbyteBtn"<%=!sinDet.equals("")?" disabled":""%>>
</td></tr>
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
<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("provincia",provincia)%>
					<%=fb.hidden("sigla",sigla)%>
					<%=fb.hidden("tomo",tomo)%>
					<%=fb.hidden("asiento",asiento)%>
					<%=fb.hidden("pasaporte",pasaporte)%>
					<%=fb.hidden("cod_paciente",cod_paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("no_admision",no_admision)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("admRoot",admRoot)%>
                    <%=fb.hidden("beginSearch","")%>
                    <%=fb.hidden("tipo_empresa",tipoEmpresa)%>
                    <%=fb.hidden("tipo",tipoLiq)%>
                    <%=fb.hidden("sin_det",sinDet)%>
                    <%=fb.hidden("tipo_atencion",tipoAtencion)%>
					<%=fb.hidden("tipo_beneficio",tipoBeneficio)%>
					<%=fb.hidden("fecha_reclamo",fechaReclamo)%>
					<%=fb.hidden("desc_diagnostico",descDiagnostico)%>
					<%=fb.hidden("no_aprob",noAprob)%>
					<%=fb.hidden("cat_reclamo",cat_reclamo)%>
					<%=fb.hidden("hosp_si_no",hosp_si_no)%>
					<%=fb.hidden("hosp_tipo_si",hosp_tipo_si)%>
					<%=fb.hidden("hosp_tipo_no",hosp_tipo_no)%>
					<%=fb.hidden("tipo_reclamacion",tipo_reclamacion)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="9">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="10">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="11">hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
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
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("provincia",provincia)%>
					<%=fb.hidden("sigla",sigla)%>
					<%=fb.hidden("tomo",tomo)%>
					<%=fb.hidden("asiento",asiento)%>
					<%=fb.hidden("pasaporte",pasaporte)%>
					<%=fb.hidden("cod_paciente",cod_paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("no_admision",no_admision)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("admRoot",admRoot)%>
                    <%=fb.hidden("beginSearch","")%>
                    <%=fb.hidden("tipo_empresa",tipoEmpresa)%>
                    <%=fb.hidden("tipo",tipoLiq)%>
                    <%=fb.hidden("sin_det",sinDet)%>
                    <%=fb.hidden("tipo_atencion",tipoAtencion)%>
					<%=fb.hidden("tipo_beneficio",tipoBeneficio)%>
					<%=fb.hidden("fecha_reclamo",fechaReclamo)%>
					<%=fb.hidden("desc_diagnostico",descDiagnostico)%>
					<%=fb.hidden("no_aprob",noAprob)%>
					<%=fb.hidden("cat_reclamo",cat_reclamo)%>
					<%=fb.hidden("hosp_si_no",hosp_si_no)%>
					<%=fb.hidden("hosp_tipo_si",hosp_tipo_si)%>
					<%=fb.hidden("hosp_tipo_no",hosp_tipo_no)%>
					<%=fb.hidden("tipo_reclamacion",tipo_reclamacion)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}
else{
      int size = Integer.parseInt(request.getParameter("size"));
      int line = iLiqRecl.size();
      String _redirect = "";
      System.out.println("::::::::::::::::::::::::::::::::::::: POSTING..."+size);
        for (int i=0; i<size; i++){
            if (request.getParameter("check"+i) != null){
            
            System.out.println("::::::::::::::: CHECK... "+request.getParameter("check"+i));
            
                CommonDataObject cdo = new CommonDataObject();
                cdo.setAction("I");
                //cdo.setKey();
                
                cdo.addColValue("tipo_transaccion",request.getParameter("tipoTransaccion"));
                cdo.addColValue("tipo_cargo",request.getParameter("tipo_servicio"+i));
                cdo.addColValue("seq_trx",request.getParameter("seq_trx"+i));
                //cdo.addColValue("cantidad",request.getParameter("cantidad"+i));
								cdo.addColValue("cantidad","1");
                cdo.addColValue("monto",request.getParameter("monto"+i));
                cdo.addColValue("total_x_fila",request.getParameter("total_x_fila"+i));
                cdo.addColValue("estatus","A");
                cdo.addColValue("centro_servicio",request.getParameter("cds"+i));
                cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
                cdo.addColValue("codigo_precio",request.getParameter("codigo_precio"+i));
                cdo.addColValue("medicoOrEmpre",request.getParameter("medicoOrEmpre"+i));
                cdo.addColValue("nombreMedicoOrEmpre",request.getParameter("nombreMedicoOrEmpre"+i));
                cdo.addColValue("empresa",request.getParameter("empresa"+i));
                cdo.addColValue("medico",request.getParameter("medico"+i));
                cdo.addColValue("pagar_sociedad",request.getParameter("pagar_sociedad"+i));
                
                _redirect = "../planmedico/reg_liquidacion_reclamo.jsp?cedulaPasaporte="+request.getParameter("cedula"+i)+"&nombreCliente="+request.getParameter("nombre_paciente"+i)+"&tipoTransaccion=F&observacion=&tipo_empresa="+request.getParameter("tipo_empresa"+i)+"&categoria="+categoria+"&no_factura="+request.getParameter("fac"+i)+"&fecha_nacimiento="+request.getParameter("fechaNacimiento"+i)+"&edad="+request.getParameter("edad"+i)+"&sexo="+request.getParameter("sexo"+i)+"&codigo_paciente="+request.getParameter("codigo_paciente"+i)+"&fecha_ingreso="+request.getParameter("fechaIngreso"+i)+"&fecha_egreso="+request.getParameter("fechaEgreso"+i)+"&direccion_residencial&poliza="+request.getParameter("poliza"+i)+"&dias_hospitalizados="+request.getParameter("dias_hospitalizados"+i)+"&medico="+request.getParameter("medico"+i)+"&medico_nombre="+request.getParameter("nombreMedicoOrEmpre"+i)+"&icd9=&total=0.00&monto_pcte=&sub_total=&descuento=&copago=&apply_charges=Y&admSecuencia="+request.getParameter("admision"+i)+"&pacId="+request.getParameter("pac_id"+i)+"&tipo="+request.getParameter("tipo")+"&sin_det="+request.getParameter("sin_det")+"&tipo_atencion="+request.getParameter("tipo_atencion")+"&tipo_beneficio="+request.getParameter("tipo_beneficio")+"&fecha_reclamo="+request.getParameter("fecha_reclamo")+"&desc_diagnostico="+request.getParameter("desc_diagnostico")+"&no_aprob="+request.getParameter("no_aprob")+"&cat_reclamo="+request.getParameter("cat_reclamo")+"&hosp_si_no="+request.getParameter("hosp_si_no")+"&hosp_tipo_si="+request.getParameter("hosp_tipo_si")+"&hosp_tipo_no="+request.getParameter("hosp_tipo_no")+"&tipo_reclamacion="+request.getParameter("tipo_reclamacion");
								
                
                line++;

				String key = "";
				if (line < 10) key = "00"+line;
				else if (line < 100) key = "0"+line;
				else key = ""+line;
				cdo.addColValue("key",key);

                try
                {
                    iLiqRecl.put(key, cdo);
                    String _key =request.getParameter("pac_id"+i)+"-"+request.getParameter("admision"+i)+"-"+request.getParameter("fac"+i)+"-"+request.getParameter("descripcion"+i);
                    System.out.println("..................."+_key);
                    vLiqRecl.add(_key);
                }
                catch(Exception e)
                {
                    System.err.println(e.getMessage());
                }
            }
        }//for i
    
%>
<html>
<head>
<script>
function closeWindow()
{
    window.opener.document.location = "<%=_redirect%>";
    //window.close();
    //alert("<%=_redirect%>");
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>