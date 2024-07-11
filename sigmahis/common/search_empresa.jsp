<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
============================================================================
===========================================================================
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
StringBuffer sbField = new StringBuffer();
StringBuffer sbTable = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

String fp = request.getParameter("fp");
String index = request.getParameter("index");
String userId = request.getParameter("userId");
String fg = request.getParameter("fg");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (fg == null) fg = "";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (!fg.equalsIgnoreCase("DEVHON")) sbFilter.append(" and a.estado = 'A'");

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

	String codigo = request.getParameter("codigo");
	String nombre = request.getParameter("nombre");
	if (codigo == null) codigo = "";
	if (nombre == null) nombre = "";
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(a.codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(a.nombre) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }

	String appendTable = "";

	if (fp.equalsIgnoreCase("admision") || fp.equalsIgnoreCase("admisionSearch") || fp.equalsIgnoreCase("admision_new")) {

		if (fp.equalsIgnoreCase("admision") && index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
		sbFilter.append(" and a.tipo_empresa != 1");

	}	else if (fp.equalsIgnoreCase("convenio")) sbFilter.append(" and a.tipo_empresa  in ( select column_value from table( select split((select get_sec_comp_param("+session.getAttribute("_companyId")+",'ADM_TIPO_EMPRESA_CONV') from dual) ,',') from dual  ))");
	else if (fp.equalsIgnoreCase("cargo_dev") || fp.equalsIgnoreCase("liq_recl") || fp.equalsIgnoreCase("notas_ajustes") || fp.equalsIgnoreCase("pago_otro") || fp.equalsIgnoreCase("saldoIni")) {

		if (fg.equalsIgnoreCase("DEVHON")) {

			sbField.append(", e.monto_total,e.no_documento");
			sbTable.append(", (select x.empre_codigo, sum(decode(x.tipo_transaccion,'D',-y.cantidad,y.cantidad) * y.monto) as monto_total,x.no_documento from tbl_fac_transaccion x, tbl_fac_detalle_transaccion y where x.pac_id = ");
			sbTable.append(pacId);
			sbTable.append(" and x.admi_secuencia = ");
			sbTable.append(noAdmision);
			sbTable.append(" and x.centro_servicio = 0 and x.codigo = y.fac_codigo and x.admi_secuencia = y.fac_secuencia and x.pac_id = y.pac_id and x.compania = y.compania and x.tipo_transaccion = y.tipo_transaccion group by x.no_documento,x.empre_codigo having sum(decode(x.tipo_transaccion,'D',-y.cantidad,y.cantidad) * y.monto) > 0) e");
			sbFilter.append(" and a.codigo = e.empre_codigo");

		}

		sbFilter.append(" and a.tipo_empresa = 1");

	} else if (fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("cxc")) sbFilter.append(" and a.tipo_empresa in (2,5)");
	else if (fp.equalsIgnoreCase("resAdmision") || fp.equalsIgnoreCase("facturacionAj")) sbFilter.append(" and a.tipo_empresa = 2");
	else if (fp.equalsIgnoreCase("lista_envio") || fp.equalsIgnoreCase("list_envio")){ sbFilter.append(" and exists (select null from tbl_fac_factura f where f.cod_empresa = a.codigo and estatus <> 'A' and compania =");
	sbFilter.append(session.getAttribute("_companyId"));
	sbFilter.append(")");}
	else if (fp.equalsIgnoreCase("user")) {

		if (userId == null) throw new Exception("El Usuario no es válido. Por favor intente nuevamente!");
		//commented to allow multiple users from same insurance company
		//sbTable.append(", (select ref_code from tbl_sec_users where user_type in (select id from tbl_sec_user_type where ref_type = 'A') and user_id! = ");
		//sbTable.append(userId);
		//sbTable.append(") z");
		//sbFilter.append(" and to_char(a.codigo) = z.ref_code(+) and z.ref_code is null");

	}else if (fp.equalsIgnoreCase("ajuste_cxp")||fp.equalsIgnoreCase("citasAnest")||fp.equalsIgnoreCase("citas_personal")||fp.equalsIgnoreCase("notas_h") )sbFilter.append(" and a.tipo_empresa = 1");

	sbSql.append("select a.codigo, a.nombre, a.ruc, (select descripcion from tbl_adm_tipo_empresa where codigo = a.tipo_empresa) as tipo_descripcion, (select descripcion from tbl_adm_grupo_empresa where codigo = a.grupo_empresa) as grupo_descripcion, nvl(a.porcentaje_liq_reclamo, 0) porcentaje_liq_reclamo");
	sbSql.append(sbField);
	sbSql.append(" from tbl_adm_empresa a");
	sbSql.append(sbTable);
	if (sbFilter.length() != 0) sbSql.append(sbFilter.replace(0,4," where"));
	sbSql.append(" order by 5, a.tipo_empresa, a.nombre");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");

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
document.title = 'Empresa - '+document.title;
function setEmpresa(k){
<% if (fp.equalsIgnoreCase("recibos")) { %>
	window.opener.document.form0.codEmpresa.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form0.empresaNombre.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("notas_ajustes")) { %>
	window.opener.document.form1.v_codigo<%=index%>.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form1.name_code<%=index%>.value = eval('document.empresa.nombre'+k).value;
	if(window.opener.document.form1.reg_medico<%=index%>)window.opener.document.form1.reg_medico<%=index%>.value = eval('document.empresa.codigo'+k).value;
<% } else if (fp.equalsIgnoreCase("notas_h")) { %>
	window.opener.document.form1.codigo_medico<%=index%>.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form1.descripcion<%=index%>.value = eval('document.empresa.nombre'+k).value;
	if(window.opener.document.form1.reg_medico<%=index%>)window.opener.document.form1.reg_medico<%=index%>.value = eval('document.empresa.codigo'+k).value;
<% } else if (fp.equalsIgnoreCase("medico")) { %>
	window.opener.document.form0.codEmpresa.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form0.empresaNombre.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("admision")) { %>
//  window.opener.document.form5.tipoIdentificacion<%=index%>.value = 'R';
	window.opener.document.form5.nacionalidad<%=index%>.value = '';
	window.opener.document.form5.nacionalidadDesc<%=index%>.value = '';
	window.opener.document.form5.lugarNac<%=index%>.value = '';
	window.opener.document.form5.seguroSocial<%=index%>.value = '';
	window.opener.document.form5.sexo<%=index%>.value = '';
	window.opener.document.form5.medico<%=index%>.value = '';
	window.opener.document.form5.numEmpleado<%=index%>.value = '';
	window.opener.document.form5.tipoIdentificacion<%=index%>.value = 'R';
	window.opener.document.form5.empresa<%=index%>.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form5.nombre<%=index%>.value = eval('document.empresa.nombre'+k).value;
	window.opener.document.form5.identificacion<%=index%>.value = eval('document.empresa.ruc'+k).value;
<% } else if (fp.equalsIgnoreCase("admision_new")) { %>
//  window.opener.document.form1.tipoIdentificacion<%=index%>.value = 'R';
	window.opener.document.form1.nacionalidad<%=index%>.value = '';
	window.opener.document.form1.nacionalidadDesc<%=index%>.value = '';
	window.opener.document.form1.lugarNac<%=index%>.value = '';
	window.opener.document.form1.seguroSocial<%=index%>.value = '';
	window.opener.document.form1.sexo<%=index%>.value = '';
	window.opener.document.form1.medico<%=index%>.value = '';
	window.opener.document.form1.numEmpleado<%=index%>.value = '';
	window.opener.document.form1.tipoIdentificacion<%=index%>.value = 'R';
	window.opener.document.form1.empresa<%=index%>.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form1.nombre<%=index%>.value = eval('document.empresa.nombre'+k).value;
	window.opener.document.form1.identificacion<%=index%>.value = eval('document.empresa.ruc'+k).value;
<% } else if (fp.equalsIgnoreCase("convenio") || fp.equalsIgnoreCase("pago_automatico")) { %>
	window.opener.document.form0.empresa.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form0.nombreEmpresa.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("citas")) { %>
	window.opener.document.form0.empresa.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form0.empresa_desc.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("cargo_dev")) { %>
	if(window.opener.document.form0.medico)window.opener.document.form0.medico.value='';
	if(window.opener.document.form0.nombreMedico)window.opener.document.form0.nombreMedico.value='';
	if(window.opener.document.form0.empreCodigo)window.opener.document.form0.empreCodigo.value = eval('document.empresa.codigo'+k).value;
	if(window.opener.document.form0.empreDesc)window.opener.document.form0.empreDesc.value = eval('document.empresa.nombre'+k).value;
	if(window.opener.document.form0.noDocumento)window.opener.document.form0.noDocumento.value = eval('document.empresa.boleta'+k).value;
<% } else if (fp.equalsIgnoreCase("resAdmision")) { %>
	window.opener.document.form1.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form1.aseguradoraDesc.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("contrato")) { %>
	window.opener.document.form1.empresa<%=index%>.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form1.nombreEmpresa<%=index%>.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("paciente_custodio")) { %>
	window.opener.document.form0.empresaCode.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form0.empresa.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("pago_otro")) { %>
	window.opener.document.form1.medicoRefId.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form1.medicoRefNombre.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("admisionSearch")) { %>
	window.opener.document.search00.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.search00.aseguradoraDesc.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("rep_aux")) { %>
	window.opener.document.search00.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.search00.aseguradoraDesc.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("user")) { %>
	window.opener.document.form0.refCode.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form0.name.value = eval('document.empresa.nombre'+k).value;
	window.opener.document.form0.refCodeDisplay.value = eval('document.empresa.codigo'+k).value;
<% } else if (fp.equalsIgnoreCase("procedimientos")) { %>
	window.opener.document.form7.ref_code<%=index%>.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form7.nivel_nombre<%=index%>.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("cxc") ||fp.equalsIgnoreCase("saldoIni")) { %>
	window.opener.document.form1.id_cliente.value = eval('document.empresa.codigo'+k).value;
	if(window.opener.document.form1.id_cliente_view)window.opener.document.form1.id_cliente_view.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form1.nombre.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("morosidad") || fp.equalsIgnoreCase("facturacion")|| fp.equalsIgnoreCase("facturacionAj")) { %>
	window.opener.document.form0.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form0.aseguradoraDesc.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("updateLista")) { %>
	window.opener.document.search01.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.search01.aseguradoraDesc.value = eval('document.empresa.nombre'+k).value;
	window.opener.document.search01.ruc.value = eval('document.empresa.ruc'+k).value;
<% } else if (fp.equalsIgnoreCase("rep_list_aseg")) { %>
	window.opener.document.form1.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form1.aseguradoraDesc.value = eval('document.empresa.nombre'+k).value;
	window.opener.creaXML();
<% } else if (fp.equalsIgnoreCase("listaEnvio")) { %>
	window.opener.document.form0.empresa.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.form0.nombreEmpresa.value = eval('document.empresa.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("centro_educ")) { %>
	window.opener.document.form1.empresa.value=eval('document.empresa.codigo'+k).value;
	window.opener.document.form1.descripcion.value=eval('document.empresa.nombre'+k).value;
<% }
	else if (fp.equalsIgnoreCase("ajuste_cxp"))
{
%>
		window.opener.document.form1.ref_id.value = eval('document.empresa.codigo'+k).value;
		window.opener.document.form1.nombre.value = eval('document.empresa.nombre'+k).value;
<%}
	else if (fp.equalsIgnoreCase("citasAnest"))
{
%>
		if(window.opener.document.form0.anestesiologo)window.opener.document.form0.anestesiologo.value = eval('document.empresa.codigo'+k).value;
		if(window.opener.document.form0.anestesiologoNombre)window.opener.document.form0.anestesiologoNombre.value = eval('document.empresa.nombre'+k).value;
<%}else if (fp.equalsIgnoreCase("citas_personal"))
{
%>
		window.opener.document.form2.medico<%=index%>.value = eval('document.empresa.codigo'+k).value;
		window.opener.document.form2.nombre<%=index%>.value = eval('document.empresa.nombre'+k).value;
		window.opener.document.form2.sociedad<%=index%>.value = "S";
		window.opener.document.form2.tipoPersonal<%=index%>.value='S';
<%
} else if (fp.equalsIgnoreCase("informe_ingresos")) { %>
	window.opener.document.search01.empresa.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.search01.empresa_desc.value = eval('document.empresa.nombre'+k).value;
<%} else if (fp.equalsIgnoreCase("consFact")) { %>
	window.opener.document.search01.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.search01.aseguradoraDesc.value = eval('document.empresa.nombre'+k).value;
<%} else if (fp.equalsIgnoreCase("incobrable")) { %>
	window.opener.document.search00.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.search00.aseguradoraDesc.value = eval('document.empresa.nombre'+k).value;

 <%}  else if (fp.equalsIgnoreCase("ajuste_lote")) { %>
	window.opener.document.search00.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.search00.aseguradoraDesc.value = eval('document.empresa.nombre'+k).value;

 <%} else if (fp.equalsIgnoreCase("list_envio")) { %>
	window.opener.document.search01.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.search01.aseguradora_desc.value = eval('document.empresa.nombre'+k).value;

 <%} else if (fp.equalsIgnoreCase("lista_envio")) { %>
	window.opener.document.lista_envio.aseguradora.value = eval('document.empresa.codigo'+k).value;
	window.opener.document.lista_envio.aseguradora_desc.value = eval('document.empresa.nombre'+k).value;

 <%}else if (fp.equalsIgnoreCase("cobrador")) { %>
	window.opener.document.form0.codigo_empresa.value=eval('document.empresa.codigo'+k).value;
	window.opener.document.form0.codigo_cobrador.value=eval('document.empresa.codigo'+k).value;
	window.opener.document.form0.nombre_cobrador.value=eval('document.empresa.nombre'+k).value;
<%}else if(fp.equalsIgnoreCase("liq_recl")) {%>
  if ($("#medicoOrEmpre<%=index%>",window.opener.document).length) $("#medicoOrEmpre<%=index%>",window.opener.document).val(eval('document.empresa.codigo'+k).value);
     if ($("#nombreMedicoOrEmpre<%=index%>",window.opener.document).length) $("#nombreMedicoOrEmpre<%=index%>",window.opener.document).val(eval('document.empresa.nombre'+k).value);
     
     if ($("#empresa<%=index%>",window.opener.document).length) $("#empresa<%=index%>",window.opener.document).val(eval('document.empresa.codigo'+k).value);
     if ($("#porcentaje_liq_reclamo<%=index%>",window.opener.document).length) $("#porcentaje_liq_reclamo<%=index%>",window.opener.document).val(eval('document.empresa.porcentaje_liq_reclamo'+k).value);
     
    if ($("#descripcion<%=index%>",window.opener.document).length && !$("#descripcion<%=index%>",window.opener.document).val() ) $("#descripcion<%=index%>",window.opener.document).val(eval('document.empresa.nombre'+k).value)
		window.opener.$("#desc_aplicado").val('N');	
		window.opener.setXtra();
<%}else if(fp.equalsIgnoreCase("hist_reclamo")) {%>
  if ($("#medicoOrEmpre",window.opener.document).length) $("#medicoOrEmpre",window.opener.document).val(eval('document.empresa.codigo'+k).value);
     if ($("#nombreMedicoOrEmpre",window.opener.document).length) $("#nombreMedicoOrEmpre",window.opener.document).val(eval('document.empresa.nombre'+k).value);
     
     if ($("#empresa",window.opener.document).length) $("#empresa",window.opener.document).val(eval('document.empresa.codigo'+k).value);
     
    if ($("#descripcion",window.opener.document).length && !$("#descripcion",window.opener.document).val() ) $("#descripcion",window.opener.document).val(eval('document.empresa.nombre'+k).value)
     
<%}else if(fp.equalsIgnoreCase("docto_dgi")) {%>
    if(window.opener.document.search01.cod_aseg)window.opener.document.search01.cod_aseg.value = eval('document.empresa.codigo'+k).value;
	if(window.opener.document.search01.nombre_aseg)window.opener.document.search01.nombre_aseg.value = eval('document.empresa.nombre'+k).value;
<%}else if(fp.equalsIgnoreCase("empresa_config")) {%>
    if(window.opener.document.form1.codigo_resp)window.opener.document.form1.codigo_resp.value = eval('document.empresa.codigo'+k).value;
	if(window.opener.document.form1.empresaDesc)window.opener.document.form1.empresaDesc.value = eval('document.empresa.nombre'+k).value;
<%}%>
	window.close();
}
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE EMPRESA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
			<td width="50%">
				<cellbytelabel id="1">C&oacute;digo</cellbytelabel>
				<%=fb.textBox("codigo","",false,false,false,20)%>
			</td>
			<td width="50%">
				<cellbytelabel id="2">Nombre</cellbytelabel>
				<%=fb.textBox("nombre","",false,false,false,40)%>
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
<%=fb.hidden("index",index)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("index",index)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="2">Nombre</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="6">R.U.C.</cellbytelabel></td>
			<td width="25%"><% if (fp.equalsIgnoreCase("cxc")||fg.equalsIgnoreCase("DEVHON")) { %><cellbytelabel id="2">Tipo Configuraci&oacute;n</cellbytelabel><% } %></td>
			<%if (fg.equalsIgnoreCase("DEVHON")) {%>
			<td width="25%"><cellbytelabel id="6">Boleta</cellbytelabel></td>
			<%}%>
		</tr>
<%fb = new FormBean("empresa",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%
String filter="";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
<%=fb.hidden("ruc"+i,cdo.getColValue("ruc"))%>
<%=fb.hidden("boleta"+i,cdo.getColValue("no_documento"))%>
<%=fb.hidden("porcentaje_liq_reclamo"+i,cdo.getColValue("porcentaje_liq_reclamo"))%>

<% if (!filter.equalsIgnoreCase(cdo.getColValue("grupo_descripcion"))) { %>
		<tr class="TextRow03">
			<td colspan="4"><%=cdo.getColValue("grupo_descripcion")%></td>
			<%if(fg.equalsIgnoreCase("DEVHON")){%>
			<td>&nbsp;</td>
			<%}%>
		</tr>
<%
}
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEmpresa(<%=i%>)" style="cursor:pointer">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td align="center"><%=cdo.getColValue("ruc")%></td>
			<td><%=cdo.getColValue("tipo_descripcion")%></td>
			<%if (fg.equalsIgnoreCase("DEVHON")) {%>
			<td><%=cdo.getColValue("no_documento")%></td>
			<%}%>
		</tr>

<%
	filter = cdo.getColValue("grupo_descripcion");
}
%>
<%=fb.formEnd()%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("index",index)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
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
<% } %>