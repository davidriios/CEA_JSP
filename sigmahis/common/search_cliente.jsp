<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.caja.DetallePago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector"/>
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String tipoCliente = request.getParameter("tipoCliente");
String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String referTo = request.getParameter("referTo");
String fecha = request.getParameter("fecha");
String idx = request.getParameter("idx");
String tipo_clte = request.getParameter("tipo_clte");
String contrato = request.getParameter("contrato");

if (fp == null) fp = "";
if (fg == null) fg = "";
if (idx ==null) idx ="";
if (mode == null) mode = "add";
if (tipoCliente == null) tipoCliente = "";
if (referTo == null) referTo = "";
if (fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (tipo_clte == null) tipo_clte = "";
if (contrato == null) contrato = "";

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

	boolean pmInclSol = false;
	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'PM_REC_INCL_SOLICITANTE'),'N') as pm_incl_sol from dual");
	CommonDataObject p = SQLMgr.getData(sbSql.toString());
	pmInclSol = (p != null && (p.getColValue("pm_incl_sol").equalsIgnoreCase("S") || p.getColValue("pm_incl_sol").equalsIgnoreCase("Y")));
	String pmTipoClte = "C=CLIENTE";
	if (pmInclSol) pmTipoClte = "C=CLIENTE,S=SOLICITANTE";

	String code = request.getParameter("code");
	String name = request.getParameter("name");
	String dob = request.getParameter("dob");
	String pCode = request.getParameter("pCode");
	String codeEmpleado = request.getParameter("codeEmpleado");

	String cedulaPasaporte = request.getParameter("cedulaPasaporte");
	if (code == null) code = "";
	if (name == null) name = "";
	if (!referTo.equalsIgnoreCase("PART"))if (!code.trim().equals("")) { sbFilter.append(" and codigo like '"); sbFilter.append(code); sbFilter.append("%'"); }
	if (!name.trim().equals("")) { sbFilter.append(" and upper(nombre) like '%"); sbFilter.append(name.toUpperCase()); sbFilter.append("%'"); }
	if (dob == null) dob = "";
	if (pCode == null) pCode = "";
	if (cedulaPasaporte == null) cedulaPasaporte = "";
	if (codeEmpleado == null) codeEmpleado = "";
	if (referTo.equalsIgnoreCase("PART"))if (!code.trim().equals("")) { sbFilter.append(" and num_factura like '"); sbFilter.append(code); sbFilter.append("%'"); }
	if (referTo.equalsIgnoreCase("EMPL"))if (!codeEmpleado.trim().equals("")) { sbFilter.append(" and num_empleado like '"); sbFilter.append(codeEmpleado); sbFilter.append("%'"); }
	String tipoOtro = request.getParameter("tipoOtro");
	if (tipoOtro == null) tipoOtro = "";
	if (referTo.equalsIgnoreCase("CXCO")) if (!tipoOtro.trim().equals("")) { sbFilter.append(" and tipo_cliente = "); sbFilter.append(tipoOtro); }

	if (referTo.equalsIgnoreCase("PAC") || referTo.equalsIgnoreCase("AXA")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select pac_id as codigo, nombre_paciente as nombre, to_char(fecha_nacimiento,'dd/mm/yyyy') as fecha_nac, codigo as codigo_pac, id_paciente, apartado_postal cod_referencia,to_char(f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente where estatus = 'A'");
		if (!dob.trim().equals("")) { sbSql.append(" and trunc(f_nac) = to_date('"); sbSql.append(dob); sbSql.append("','dd/mm/yyyy')"); }
		if (!pCode.trim().equals("")) { sbSql.append(" and codigo = "); sbSql.append(pCode); }
		if (!cedulaPasaporte.trim().equals("")) { sbSql.append(" and id_paciente like '%"); sbSql.append(IBIZEscapeChars.forSingleQuots(cedulaPasaporte.trim())); sbSql.append("%'"); }
		sbSql.append(" order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("EMPR")|| referTo.equalsIgnoreCase("EMPRSM")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select codigo, nombre from tbl_adm_empresa where estado = 'A' ");
		 if (referTo.equalsIgnoreCase("EMPRSM"))sbSql.append(" and tipo_empresa=1");
		 else sbSql.append(" and tipo_empresa <> 1 ");
		sbSql.append(" order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("CDST")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select codigo, descripcion as nombre from tbl_cds_centro_servicio where compania_unorg = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and estado = 'A' and tipo_cds = 'T' order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("CDS")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select codigo, descripcion as nombre from tbl_cds_centro_servicio where compania_unorg = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and estado = 'A' and tipo_cds in ('I', 'E') order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("COMP")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select codigo, nombre from tbl_sec_compania where codigo <> ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and estado ='A' order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("MED")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select codigo, primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido||decode(sexo,'F',' '||apellido_de_casada) as nombre from tbl_adm_medico where estado='A' order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("EMPL")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select emp_id as codigo, nombre_empleado as nombre,num_empleado from vw_pla_empleado where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and estado <> 3 order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("EMPO")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select to_char (codigo) as codigo, descripcion as nombre from tbl_cxc_cliente_particular where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and cliente_alquiler != 'S' and colaborador = 'S' order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("PART")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select distinct ' ' as codigo, cliente as nombre, num_factura from tbl_fac_cargo_cliente a where tipo_cliente in (select codigo from tbl_fac_tipo_cliente where refer_to = '"+referTo+"') and compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and exists (select null from tbl_fac_factura where codigo = a.num_factura and compania = a.compania and estatus = 'P') and tipo_transaccion = 'C' order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("ALQ")) {


		sbSql = new StringBuffer();
		/*sbSql.append("select * from (");
		sbSql.append("select z.contrato as codigo, (select decode(y.refer_to,'EMPR',(select nombre from tbl_adm_empresa where codigo = z.empresa),'MED',(select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido from tbl_adm_medico where codigo = z.medico),'EMPL',(select primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido from tbl_pla_empleado where emp_id = z.emp_id),'PART',(select descripcion from tbl_cxc_cliente_particular where codigo = z.particular and compania = z.compania),y.refer_to) from tbl_fac_tipo_cliente y where y.codigo = z.tipo_cliente and y.compania = z.compania) nombre, z.tipo_cliente as tipo_cliente_alq, z.empresa, z.medico, z.provincia_emp, z.sigla_emp, z.tomo_emp, z.asiento_emp, z.compania_emp, z.emp_id, z.particular, decode(z.tipo_contrato,1,'OTROS',2,'ALQUILER') as tipo, (select y.refer_to from tbl_fac_tipo_cliente y where y.codigo = z.tipo_cliente and y.compania = z.compania) as ref_to, (select decode(y.refer_to,'EMPR',''||z.empresa,'MED',z.medico,'EMPL',''||z.emp_id,'PART',''||z.particular) from tbl_fac_tipo_cliente y where y.codigo = z.tipo_cliente and y.compania = z.compania) as ref_id, z.contrato from tbl_cxc_contrato_alq z where z.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and z.estado = 'A' and z.tipo_cliente is not null order by 2");
		sbSql.append(") ");*/

		sbSql.append(" select 'ALQ' refer_to, null compania, codigo, primer_nombre || ' ' || segundo_nombre || ' ' || primer_apellido || ' ' || segundo_apellido || decode (sexo, 'F', ' ' || apellido_de_casada) as nombre, null fecha_nac, null fecha_vencim, 0 limite, 0 aprobacion_hna, identificacion ruc, digito_verificador dv,nacionalidad other1,sexo other2,(select d.nacionalidad from tbl_sec_pais d where d.codigo = a.nacionalidad)as other3,'' other4,'' other5 from tbl_adm_medico a where alquiler='S' and estado='A' ");

	} else if (referTo.equalsIgnoreCase("DPTO")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select codigo, descripcion as nombre from tbl_sec_unidad_ejec where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("CXCO")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select codigo, descripcion as nombre, tipo_cliente, tipo_cliente||' - '||(select descripcion from tbl_cxc_tipo_otro_cliente where id = z.tipo_cliente and compania = z.compania) as tipo from tbl_cxc_cliente_particular z where estado = 'A' and compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and cliente_alquiler != 'S' order by 2");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("CXPP")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select cod_provedor as codigo, nombre_proveedor as nombre from tbl_com_proveedor where estado_proveedor = 'ACT' and compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and vetado ='N' order by 2 ");
		sbSql.append(")");

	} else if (referTo.equalsIgnoreCase("CXPO")) {

		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select codigo, nombre as nombre from tbl_con_pagos_otros where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and estado = 'A' order by 2");
		sbSql.append(")");

	}
	else if (referTo.equalsIgnoreCase("PLAN"))
	{
		sbSql = new StringBuffer();
		sbSql.append("select * from (");
		sbSql.append("select sc.id contrato, sc.id as contrato_no, lpad(sc.id, 9, '0') contrato_desc, c.codigo, c.primer_nombre || decode(c.segundo_nombre, null, '', ' ' || c.segundo_nombre) || decode(c.primer_apellido, null, '', ' ' || c.primer_apellido) || decode(c.sexo, 'F', decode(c.apellido_de_casada, null, decode(c.segundo_apellido, null, '', ' ' || c.segundo_apellido), ' DE ' || c.apellido_de_casada), decode(c.segundo_apellido, null, '', ' ' || c.segundo_apellido)) as nombre, nvl(getPmMontoCuota(sc.id), 0) cuota from tbl_pm_cliente c, tbl_pm_solicitud_contrato sc where estatus = 'A' and sc.id_cliente(+) = c.codigo and sc.estado(+) = 'A'");
		if (tipo_clte.equalsIgnoreCase("C")){
			sbSql.append(" and sc.id is not null");
			if (!contrato.trim().equals("")) { sbSql.append(" and sc.id="); sbSql.append(contrato); }			
		} 
		if (!tipo_clte.trim().equals("")) { sbSql.append(" and tipo_clte='"); sbSql.append(tipo_clte); sbSql.append("'"); }
		
		sbSql.append(" order by 2");
		sbSql.append(")");
	}


	if (sbSql.length() > 0 && request.getParameter("code")!=null)
	{
		if (sbFilter.length() > 0) { sbSql.append(" where"); sbSql.append(sbFilter.substring(4)); }
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");
	}
	else System.out.println("* * *   There is not sql statement to execute!   * * *");

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
document.title = 'Cliente - '+document.title;
function setCliente(k)
{
<% if (fp.equalsIgnoreCase("recibos")) { %>
	if(window.opener.document.form0.refId)window.opener.document.form0.refId.value=eval('document.result.codigo'+k).value;
	if(window.opener.document.form0.nombre)window.opener.document.form0.nombre.value=eval('document.result.nombre'+k).value;
	if(window.opener.document.form0.nombreAdicional)window.opener.document.form0.nombreAdicional.value=eval('document.result.nombre'+k).value;
	<% if (tipoCliente.equalsIgnoreCase("P")) { %>
	if(window.opener.document.form0.codigoPaciente)window.opener.document.form0.codigoPaciente.value=eval('document.result.codigo_pac'+k).value;
	if(window.opener.document.form0.fechaNacimiento)window.opener.document.form0.fechaNacimiento.value=eval('document.result.fecha_nac'+k).value;
	if(window.opener.document.form0.pacId)window.opener.document.form0.pacId.value=eval('document.result.codigo'+k).value;
	if(window.opener.document.form0.codReferencia)window.opener.document.form0.codReferencia.value=eval('document.result.cod_referencia'+k).value;
	if(window.opener.document.form0.f_nac)window.opener.document.form0.f_nac.value=eval('document.result.f_nac'+k).value;
	<% } else if (tipoCliente.equalsIgnoreCase("E")) { %>
	if(window.opener.document.form0.codigoEmpresa)window.opener.document.form0.codigoEmpresa.value=eval('document.result.codigo'+k).value;
	<% } else if (tipoCliente.equalsIgnoreCase("O") || tipoCliente.equalsIgnoreCase("A")) { %>
	if(window.opener.document.form0.tipoClienteOtros)window.opener.document.form0.tipoClienteOtros.value=eval('document.result.tipo_cliente_alq'+k).value;
	if(window.opener.document.form0.empresaOtros)window.opener.document.form0.empresaOtros.value=eval('document.result.empresa'+k).value;
	if(window.opener.document.form0.medicoOtros)window.opener.document.form0.medicoOtros.value=eval('document.result.medico'+k).value;
	if(window.opener.document.form0.provinciaEmp)window.opener.document.form0.provinciaEmp.value=eval('document.result.provincia_emp'+k).value;
	if(window.opener.document.form0.siglaEmp)window.opener.document.form0.siglaEmp.value=eval('document.result.sigla_emp'+k).value;
	if(window.opener.document.form0.tomoEmp)window.opener.document.form0.tomoEmp.value=eval('document.result.tomo_emp'+k).value;
	if(window.opener.document.form0.asientoEmp)window.opener.document.form0.asientoEmp.value=eval('document.result.asiento_emp'+k).value;
	if(window.opener.document.form0.companiaEmp)window.opener.document.form0.companiaEmp.value=eval('document.result.compania_emp'+k).value;
	if(window.opener.document.form0.empId)window.opener.document.form0.empId.value=eval('document.result.emp_id'+k).value;
	if(window.opener.document.form0.particularOtros)window.opener.document.form0.particularOtros.value=eval('document.result.particular'+k).value;
	if(window.opener.document.form0.numContrato)window.opener.document.form0.numContrato.value=eval('document.result.contrato'+k).value;
	<%if (referTo.equalsIgnoreCase("PLAN")){%>
	if(window.opener.document.form0.descripcion)window.opener.document.form0.descripcion.value='Contrato #'+eval('document.result.contrato_no'+k).value;
	<%}%>
	<% } %>
	if(window.opener.document.form0.clienteAlq)window.opener.document.form0.clienteAlq.value='<%=(tipoCliente.equalsIgnoreCase("A"))?"S":"N"%>';
	<% if (!(referTo.equalsIgnoreCase("PLAN") && tipo_clte.equalsIgnoreCase("S"))) { %>window.opener.getSaldoClte();<% } %>
<% } else if (fp.equalsIgnoreCase("facProv")) { %>
	// --- fp=facProv = Registro de Factura proveedor
	if(window.opener.document.fact_prov.refId<%=idx%>)window.opener.document.fact_prov.refId<%=idx%>.value=eval('document.result.codigo'+k).value;
	if(window.opener.document.fact_prov.refName<%=idx%>)window.opener.document.fact_prov.refName<%=idx%>.value=eval('document.result.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("comprob")) { %>
	// --- fp=comp = Registro de comprobante de diario
	if(window.opener.document.form1.refId<%=idx%>)window.opener.document.form1.refId<%=idx%>.value=eval('document.result.codigo'+k).value;
	if(window.opener.document.form1.refDesc<%=idx%>)window.opener.document.form1.refDesc<%=idx%>.value=eval('document.result.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("comprobFijo")) { %>
	// --- fp=comp = Registro de comprobante FIJO
	if(window.opener.document.formDetalle.refId<%=idx%>)window.opener.document.formDetalle.refId<%=idx%>.value=eval('document.result.codigo'+k).value;
	if(window.opener.document.formDetalle.refDesc<%=idx%>)window.opener.document.formDetalle.refDesc<%=idx%>.value=eval('document.result.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("saldoIni")) { %>
	window.opener.document.form1.id_cliente.value=eval('document.result.codigo'+k).value;
	window.opener.document.form1.nombre.value=eval('document.result.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("caja")) { %>
	window.opener.document.form0.subRefType.value=eval('document.result.tipo_cliente'+k).value;
	window.opener.document.form0.subRefTypeDesc.value=eval('document.result.tipo'+k).value;
	window.opener.document.form0.refId.value=eval('document.result.codigo'+k).value;
	window.opener.document.form0.nombre.value=eval('document.result.nombre'+k).value;
<% } %>
<% //if (tipoCliente.equalsIgnoreCase("A") || (tipoCliente.equalsIgnoreCase("O") && !referTo.equalsIgnoreCase("PLAN"))) { %>
	/*document.result.index.value=k;
	document.result.submit();*/
<% //} else { %>
	window.close();
<% //} %>
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CLIENTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("referTo",referTo)%>
<%=fb.hidden("fecha",fecha)%>
		<tr class="TextFilter">
			<td>
				C&oacute;digo&nbsp;<%if(referTo.equalsIgnoreCase("PART")){%>Factura<%}%><br>
				<%=fb.textBox("code","",false,false,false,20,20,"Text10",null,null)%>
			</td>
			<td>
			<% if (referTo.equalsIgnoreCase("EMPL")) { %>
			Num Empleado
				<%=fb.textBox("codeEmpleado","",false,false,false,10,"Text10",null,null)%>
			<%}%>
				Nombre<br>
				<%=fb.textBox("name","",false,false,false,50,"Text10",null,null)%>
			</td>
				<%if(tipoCliente.equals("O") && referTo.equals("PLAN")){%>
			<td>
				<cellbytelabel id="9">Tipo Clte.</cellbytelabel><br>
				<%=fb.select("tipo_clte",pmTipoClte,tipo_clte,false,false,0,"Text10",null,null,null,"")%>
			</td>
				<%}%>
<% if (tipoCliente.equalsIgnoreCase("P")) { %>
			<td>
				Fecha Nac.<br>
				<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="format" value="dd/mm/yyyy"/>
					<jsp:param name="nameOfTBox1" value="dob"/>
					<jsp:param name="valueOfTBox1" value=""/>
				</jsp:include>
			</td>
			<td>
				C&oacuted. Pac.<br>
				<%=fb.intBox("pCode","",false,false,false,5,5,"Text10",null,null)%>
			</td>
			<td>
				C&eacute;dula / Pasaporte<br>
				<%=fb.textBox("cedulaPasaporte","",false,false,false,20,30,"Text10",null,null)%>
				
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
<% } else { %>
		<%if (referTo.equalsIgnoreCase("PLAN")){%>
		<td>
		Contrato:
		<%=fb.textBox("contrato","",false,false,false,20,30,"Text10",null,null)%>
		</td>
		<% } else if (referTo.equalsIgnoreCase("CXCO")) { %>
		<td>
		Tipo:
		<%=fb.select(ConMgr.getConnection(),"select id, descripcion, id from tbl_cxc_tipo_otro_cliente where compania = "+session.getAttribute("_companyId")+" and estado = 'A' order by descripcion","tipoOtro",tipoOtro,false,false,0,"Text10","","","","T")%>
		</td>
		<% } %>			
			<td>
<br><%=fb.submit("go","Ir",false,false,"Text10",null,null)%></td>
<% } %>
		</tr>

		<%if (tipoCliente.equalsIgnoreCase("P")){fb.appendJsValidation("if((document.search00.dob.value!='' && !isValidateDate(document.search00.dob.value))){alert('Formato de fecha inválida!');error++;}");}%>

<%=fb.formEnd()%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("referTo",referTo)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("pCode",pCode)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("codeEmpleado",codeEmpleado)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("tipoOtro",tipoOtro)%>


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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("referTo",referTo)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("pCode",pCode)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("codeEmpleado",codeEmpleado)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("tipoOtro",tipoOtro)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="15%"><%if(referTo.equalsIgnoreCase("PLAN")){%>Contrato<%} else {%>C&oacute;digo<%}%>&nbsp;<%if(referTo.equalsIgnoreCase("PART")){%>Factura<%}%></td>
			<td>Nombre</td>
			<% if (tipoCliente.equalsIgnoreCase("P")) { %>
				<td width="8%">Fecha Nac.</td>
				<td width="10%">C&oacute;d. Pac.</td>
				<td width="12%">C&eacute;dula / Pasaporte</td>
			<% } %>
			<td width="10%">Tipo</td>
			<% if (!tipoCliente.equalsIgnoreCase("P")) { %>
				<td width="10%">Tipo Referencia</td>
				<td width="15%"><%if(referTo.equalsIgnoreCase("PLAN")){%>C&oacute;digo<%} else {%>Referencia<%}%></td>
				<%if(tipoCliente.equals("O") && referTo.equals("PLAN")){%>
				<td width="15%">Cuota</td>
				<%}%>
			<% }else{ %>
			   <td width="20%"># Referencia</td>
			<% }%>
		</tr>
<%fb = new FormBean("result",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("referTo",referTo)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("index","")%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("fecha_nac"+i,cdo.getColValue("fecha_nac"))%>
		<%=fb.hidden("codigo_pac"+i,cdo.getColValue("codigo_pac"))%>
		<%=fb.hidden("cod_referencia"+i,cdo.getColValue("cod_referencia"))%>
		<%=fb.hidden("tipo_cliente_alq"+i,cdo.getColValue("tipo_cliente_alq"))%>
		<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
		<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
		<%=fb.hidden("provincia_emp"+i,cdo.getColValue("provincia_emp"))%>
		<%=fb.hidden("sigla_emp"+i,cdo.getColValue("sigla_emp"))%>
		<%=fb.hidden("tomo_emp"+i,cdo.getColValue("tomo_emp"))%>
		<%=fb.hidden("asiento_emp"+i,cdo.getColValue("asiento_emp"))%>
		<%=fb.hidden("compania_emp"+i,cdo.getColValue("compania_emp"))%>
		<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
		<%=fb.hidden("particular"+i,cdo.getColValue("particular"))%>
		<%=fb.hidden("contrato"+i,cdo.getColValue("contrato"))%>
		<%=fb.hidden("contrato_desc"+i,cdo.getColValue("contrato_desc"))%>
		<%=fb.hidden("contrato_no"+i,cdo.getColValue("contrato_no"))%>
		<%=fb.hidden("f_nac"+i,cdo.getColValue("f_nac"))%>
		<%=fb.hidden("tipo_cliente"+i,cdo.getColValue("tipo_cliente"))%>
		<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
		<tr class="<%=color%>" onClick="javascript:setCliente(<%=i%>)" style="text-decoration:none; cursor:pointer">
			<td><%=(referTo.equalsIgnoreCase("PART"))?cdo.getColValue("num_factura"):(referTo.equalsIgnoreCase("PLAN"))?cdo.getColValue("contrato_desc"):cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<% if (tipoCliente.equalsIgnoreCase("P")) { %>
				<td align="center"><%=cdo.getColValue("f_nac")%></td>
				<td align="center"><%=cdo.getColValue("codigo_pac")%></td>
				<td><%=cdo.getColValue("id_paciente")%></td>
			<% } %>
			<td><%=(cdo.getColValue("tipo") == null)?"":cdo.getColValue("tipo")%></td>
			<% if (!tipoCliente.equalsIgnoreCase("P")) { %>
				<td align="center"><%=(cdo.getColValue("ref_to") == null)?referTo:cdo.getColValue("ref_to")%></td>
				<td><%=(cdo.getColValue("ref_id") == null)?cdo.getColValue("codigo"):cdo.getColValue("ref_id")%></td>
				<%if(tipoCliente.equals("O") && referTo.equals("PLAN")){%>
				<td><%=CmnMgr.getFormattedDecimal(cdo.getColValue("cuota"))%></td>
				<%}%>
			<% }else{ %>
				<td><%=cdo.getColValue("cod_referencia")%></td>
			<% } %>
		</tr>
<%
}
%>
<%=fb.formEnd()%>
		</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
</div>
</div>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("referTo",referTo)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("pCode",pCode)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("codeEmpleado",codeEmpleado)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("tipoOtro",tipoOtro)%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("idx",idx)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("referTo",referTo)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("name",name)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("pCode",pCode)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("codeEmpleado",codeEmpleado)%>
<%=fb.hidden("tipo_clte",tipo_clte)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("tipoOtro",tipoOtro)%>
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
	String index = request.getParameter("index");

	if (tipoCliente.equalsIgnoreCase("A"))
	{
		DetallePago dp = new DetallePago();
		dp.setDocType("C");
		dp.setDocNo(request.getParameter("codigo"+index));
		dp.setNumContrato(request.getParameter("codigo"+index));
		dp.setNombrePaciente(request.getParameter("nombre"+index));
		dp.setEstatus("N");
		//dp.setSw(request.getParameter("sw"+i));
		dp.setPagoPor("D");
		dp.setTipoTransaccion("2");

		sbSql = new StringBuffer();
		/*
		sbSql.append("select saldo_ant, debito, credito, (saldo_ant + debito - credito) as saldo_act from (select fn_cja_saldo_alq(");
		sbSql.append(compania);
		sbSql.append(",");
		sbSql.append(dp.getDocNo());
		sbSql.append(",null,-1,'");
		sbSql.append(fecha);
		sbSql.append("') as saldo_ant, fn_cja_saldo_alq(");
		sbSql.append(compania);
		sbSql.append(",");
		sbSql.append(dp.getDocNo());
		sbSql.append(",'DB',0,'");
		sbSql.append(fecha);
		sbSql.append("') as debito, fn_cja_saldo_alq(");
		sbSql.append(compania);
		sbSql.append(",");
		sbSql.append(dp.getDocNo());
		sbSql.append(",'CR',0,'");
		sbSql.append(fecha);
		sbSql.append("') as credito from dual)");
		*/

		sbSql.append("select saldo_ant, debito, credito, (saldo_ant + debito - credito) as saldo_act from (select get_saldo_a_la_fecha(");
				sbSql.append(compania);
				sbSql.append(",");
				sbSql.append(dp.getDocNo());
				sbSql.append(", '01/");
				sbSql.append(fecha.substring(3));
				sbSql.append("') as saldo_ant, fn_con_dbcr_alq_cja(");
				sbSql.append(compania);
				sbSql.append(", to_char(to_date('");
				sbSql.append(fecha);
				sbSql.append("','dd/mm/yyyy'),'yyyy'), to_char(to_date('");
				sbSql.append(fecha);
				sbSql.append("','dd/mm/yyyy'),'mm'), 'DB', ");
				sbSql.append(dp.getDocNo());
				sbSql.append(") as debito, fn_con_dbcr_alq_cja(");
				sbSql.append(compania);
				sbSql.append(", to_char(to_date('");
				sbSql.append(fecha);
				sbSql.append("','dd/mm/yyyy'),'yyyy'), to_char(to_date('");
				sbSql.append(fecha);
				sbSql.append("','dd/mm/yyyy'),'mm'), 'CR', ");
				sbSql.append(dp.getDocNo());
				sbSql.append(") as credito from dual)");

		CommonDataObject saldo = SQLMgr.getData(sbSql.toString());
		dp.setFecha(fecha);//fecha
		dp.setSaldoA(fecha.substring(3));//saldo a
		dp.setMontoTotal(saldo.getColValue("saldo_ant"));//saldo anterior
		dp.setDebito(saldo.getColValue("debito"));//debito
		dp.setCredito(saldo.getColValue("credito"));//credito
		dp.setMontoDeuda(saldo.getColValue("saldo_act"));//saldo actual
		dp.setDescProntoPago("0.00");//descuento
		dp.setMonto("0.00");//abono
		dp.setSaldo(saldo.getColValue("saldo_act"));//nuevo saldo
		try
		{
			iDoc.clear();
			iDoc.put("001",dp);
			vDoc.addElement(dp.getDocType()+"-"+dp.getDocNo());
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}//tipoCliente = A
	else if (tipoCliente.equalsIgnoreCase("O") && !referTo.equalsIgnoreCase("DPTO") && !referTo.equalsIgnoreCase("CXCO") && !referTo.equalsIgnoreCase("CXPP") && !referTo.equalsIgnoreCase("CXPO"))
	{
		String refId = request.getParameter("codigo"+index);
		String nombre = request.getParameter("nombre"+index);

		sbSql = new StringBuffer();
		sbSql.append("select a.facturar_a as ref_type, 'F' as doc_type, a.codigo as doc_no, a.compania, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as ref_to, (select case when z.refer_to in ('CDS','CDST') then ''||b.centro_servicio when z.refer_to in ('COMP') then ''||b.i_compania when z.refer_to in ('MED') then b.medico when z.refer_to in ('EMPR') then ''||b.empresa when z.refer_to in ('EMPL') then ''||b.emp_id when z.refer_to in ('AXA') then ''||b.pamd_pac_id when z.refer_to in ('PART') then ' ' /*when z.refer_to in ('ALQ') then ''||b.alquiler*/ else z.refer_to end from tbl_fac_tipo_cliente z where z.codigo = b.tipo_cliente and z.compania = b.compania) as cliente, null as pac_id, null as admision, null as cod_empresa, a.codigo as factura, null as remanente, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.grang_total as monto_total, fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) as monto_deuda, (select estado from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as estado_adm, (select categoria from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia) as categoria_adm, (select (select descripcion from tbl_adm_categoria_admision where codigo = z.categoria) from tbl_adm_admision z where z.pac_id = a.pac_id and z.secuencia = a.admi_secuencia) as categoria_adm_desc, b.cliente as nombre, ' ' as ubicacion from tbl_fac_factura a, tbl_fac_cargo_cliente b where a.compania = ");
		sbSql.append(compania);
		if (referTo.equalsIgnoreCase("CDS") || referTo.equalsIgnoreCase("CDST"))
		{
			sbSql.append(" and b.centro_servicio = ");
			sbSql.append(refId);
		}
		else if (referTo.equalsIgnoreCase("COMP"))
		{
			sbSql.append(" and b.i_compania = ");
			sbSql.append(refId);
		}
		else if (referTo.equalsIgnoreCase("MED"))
		{
			sbSql.append(" and b.medico = '");
			sbSql.append(refId);
			sbSql.append("'");
		}
		else if (referTo.equalsIgnoreCase("EMPR"))
		{
			sbSql.append(" and b.empresa = ");
			sbSql.append(refId);
		}
		else if (referTo.equalsIgnoreCase("EMPL"))
		{
			sbSql.append(" and b.emp_id = ");
			sbSql.append(refId);
		}
		else if (referTo.equalsIgnoreCase("AXA"))
		{
			sbSql.append(" and b.pamd_pac_id = ");
			sbSql.append(refId);
		}
		else if (referTo.equalsIgnoreCase("PART"))
		{
			sbSql.append(" and b.alquiler is null and b.centro_servicio is null and b.i_compania is null and b.medico is null and b.empresa is null and b.emp_id is null and b.pamd_pac_id is null and b.cliente = '");
			sbSql.append(IBIZEscapeChars.forSingleQuots(nombre.trim()));
			sbSql.append("'");
		}
		sbSql.append(" and a.facturar_a = '");
		sbSql.append(tipoCliente);
		sbSql.append("' and a.estatus = 'P' and a.grang_total > 0 and a.codigo_cargo = b.codigo and a.tipo_cargo = b.tipo_transaccion and a.anio_cargo = b.anio and a.compania = b.compania and a.cliente_otros = b.tipo_cliente and fn_cja_saldo_fact(a.facturar_a,a.compania,a.codigo,a.grang_total) > 0");
		//al = SQLMgr.getDataList(sbSql.toString());

		String key = "";
		int lastLineNo = 0;
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);

			DetallePago dp = new DetallePago();
			dp.setDocType(cdo.getColValue("doc_type"));
			dp.setDocNo(cdo.getColValue("doc_no"));
			dp.setAdmiSecuencia(cdo.getColValue("admision"));
			dp.setCodRem(cdo.getColValue("remanente"));
			dp.setFacCodigo(cdo.getColValue("factura"));
			dp.setFecha(cdo.getColValue("fecha"));
			dp.setMontoTotal(cdo.getColValue("monto_total"));
			dp.setMontoDeuda(cdo.getColValue("monto_deuda"));
			dp.setMonto(cdo.getColValue("monto_deuda"));
			dp.setNombrePaciente(cdo.getColValue("nombre"));
			dp.setEstatus(cdo.getColValue("estatus"));
			dp.setSw(cdo.getColValue("sw"));
			dp.setPagoPor(cdo.getColValue("doc_type"));
			dp.setTipoTransaccion(cdo.getColValue("tipo_transaccion"));
			dp.setAdmEstado(cdo.getColValue("estado_adm"));
			dp.setAdmCat(cdo.getColValue("categoria_adm"));
			dp.setAdmCatDesc(cdo.getColValue("categoria_adm_desc"));

			lastLineNo++;
			if (lastLineNo < 10) key = "00" + lastLineNo;
			else if (lastLineNo < 100) key = "0" + lastLineNo;
			else key = "" + lastLineNo;

			try
			{
				iDoc.put(key,dp);
				vDoc.addElement(dp.getDocType()+"-"+dp.getDocNo());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for i
	}//tipoCliente = O
%>
<html>
<head>
<script language="javascript">
function closeWindow(){<% if (fp.equalsIgnoreCase("recibos")) { %>window.opener.frames['detalle'].location='../caja/reg_recibo_det.jsp?fg=<%=fg%>&mode=<%=mode%>&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>&change=1';<% } %>window.close();}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>