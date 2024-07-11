<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
String tipo_factura = request.getParameter("tipo_factura");
String tipo_pos = request.getParameter("tipo_pos");
String ref_id = request.getParameter("ref_id");
String subRefType = request.getParameter("subRefType");
String idx = request.getParameter("idx");
String touch = request.getParameter("touch") == null ? "" : request.getParameter("touch");
String useKeypad = request.getParameter("useKeypad") == null ? "" : request.getParameter("useKeypad");

if (fp == null) fp = "";
if (fg == null) fg = "";
if (mode == null) mode = "add";
if (tipoCliente == null) tipoCliente = "";
if (referTo == null) referTo = "";
if (tipo_factura == null) tipo_factura = "CO";
if (tipo_pos == null) tipo_pos = "";
if (fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (subRefType ==null)subRefType="";

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
	String name = request.getParameter("name");
	String dob = request.getParameter("dob");
	String pCode = request.getParameter("pCode");
	String ruc = request.getParameter("ruc");
	String Refer_To = request.getParameter("Refer_To");

	if (code == null) code = "";
	if (name == null) name = "";
	if (Refer_To == null) Refer_To = "";
	if (!code.trim().equals("")) {
		if(Refer_To.equals("EMPL")){
			sbFilter.append(" and exists (select null from tbl_pla_empleado e where to_char(emp_id) = a.codigo and num_empleado like '%");
			sbFilter.append(code);
			sbFilter.append("%')");
		} else {
			sbFilter.append(" and codigo like '");
			sbFilter.append(code);
			sbFilter.append("%'");
		}
	}

	if (!name.trim().equals("")) {
		sbFilter.append(" and upper(nombre) like '%");
		sbFilter.append(name.toUpperCase());
		sbFilter.append("%'");
	}
	/*
	if (tipo_factura.trim().equals("CR")) {
		sbFilter.append(" and es_clt_cr = 'S'");
	} else if (tipo_factura.trim().equals("CO") && tipo_pos.equals("CAF")) {
		sbFilter.append(" and refer_to in ('EMPL', 'MED')");
	}
	*/
	if (dob == null) dob = "";
	if (pCode == null) pCode = "";
	if (ruc == null) ruc = "";
	if (!ruc.trim().equals("")){
		sbFilter.append(" and ruc like '%");
		sbFilter.append(ruc);
		sbFilter.append("%'");
	}

	CommonDataObject cdoQry = new CommonDataObject();
	cdoQry=SQLMgr.getData("select query from tbl_gen_query where id = 1 and refer_to = '"+Refer_To+"'");
	if(cdoQry==null) throw new Exception("No existe un listado para el tipo de cliente solicitado!");
	System.out.println("query......=\n"+cdoQry.getColValue("query"));

	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'TP_CLIENTE_OTROS'),'-') as tp_cliente_otros, nvl(get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'POS_ALWAYS_ALERT_SALDO'),'N') as always_alert_saldo from dual");
	CommonDataObject p = SQLMgr.getData(sbSql.toString());
	if (p != null && p.getColValue("tp_cliente_otros").equals("-")) throw new Exception ("El parámetro de Tipo de Cliente Otros [TP_CLIENTE_OTROS] no está definido!");
	boolean alwaysAlertSaldo = (p.getColValue("always_alert_saldo").equalsIgnoreCase("Y") || p.getColValue("always_alert_saldo").equalsIgnoreCase("S"));

	sbSql = new StringBuffer();
	sbSql.append("select a.compania, a.codigo, a.refer_to, a.nombre, to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento, a.ruc, nvl(a.dv,' ')as dv, nvl(b.id_precio, 0) id_precio, decode(a.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = a.codigo), a.codigo) num_empleado, (case when ");
	sbSql.append(p.getColValue("tp_cliente_otros"));
	sbSql.append(" = ");
	sbSql.append(ref_id);
	sbSql.append(" then 'Y' else 'N' end) es_clt_cxc_otros, (case when ");
	sbSql.append(p.getColValue("tp_cliente_otros"));
	sbSql.append(" = ");
	sbSql.append(ref_id);
	sbSql.append(" then (select facturar_al_costo from tbl_cxc_cliente_particular cp where cp.compania = a.compania and  to_char(cp.codigo) = a.codigo) else 'N' end) facturar_al_costo");
	if(Refer_To.trim().equals("CXCO")) {
		sbSql.append(", a.tipo_cliente as tipoCliente, nvl((select monto_cr_limite from tbl_cxc_cliente_particular cp where cp.compania = a.compania and to_char(cp.codigo) = a.codigo), 0) monto_cr_limite");
	} else {
		sbSql.append(", null as tipoCliente, 0 monto_cr_limite");
	}
	sbSql.append(", a.other1, a.other2, a.other3, a.other4, a.other5, (select get_age(a.fecha_nac,trunc(sysdate),'y') from dual) as edad");
	if (Refer_To.equalsIgnoreCase("PAC")) sbSql.append(", a.cedula, (select pp.apartado_postal from tbl_adm_paciente pp where pp.pac_id = a.codigo and rownum = 1) as cod_referencia ");
	sbSql.append(" from (");
	sbSql.append(cdoQry.getColValue("query").replace("@@compania", (String) session.getAttribute("_companyId")));
	sbSql.append(") a, tbl_clt_lista_precio b where nvl(compania,");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(")");
	if(Refer_To.trim().equals("COMP"))sbSql.append("<>");
	else sbSql.append("= ");
	sbSql.append(session.getAttribute("_companyId"));
	if (!Refer_To.trim().equals("")) {
		sbSql.append(" and refer_to = '");
		sbSql.append(Refer_To);
		sbSql.append("'");
	}
	sbSql.append(sbFilter.toString());
	sbSql.append(" and a.refer_to = b.tipo_clte(+) and a.codigo = b.id_clte(+) and b.ref_id(+) = ");
	sbSql.append(ref_id);
	if(!subRefType.trim().equals("")){sbSql.append(" and a.tipo_cliente= ");
	sbSql.append(subRefType);}
	sbSql.append(" order by nombre");
issi.admin.ISSILogger.info("dgi",">>>>>>>>>>>>>>:>>"+sbSql.toString());
	if ((sbSql.length() > 0 && sbFilter.length() >= 0)||(request.getParameter("code")!=null && (fp.equalsIgnoreCase("admision_medico_resp_new")||fp.equalsIgnoreCase("addCliente") ))){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Common - '+document.title;

function setValue(i){
<% if (fp.equalsIgnoreCase("cargo_dev_oc")||fp.equalsIgnoreCase("proforma")) { %>

<% if (fp.equalsIgnoreCase("proforma")) { %>
var profId = getDBData('<%=request.getContextPath()%>','getProfId(<%=(String) session.getAttribute("_companyId")%>,<%=ref_id%>,'+eval('document.detail.codigo'+i).value+')','dual','');
if(profId!=0){if(confirm('El cliente seleccionado tiene registro pendiente por facturar. Desea agregar los registros a la Proforma Activa??'))parent.document.form0.profId.value = profId;
}
<%}%>

	if(eval('document.detail.es_clt_cxc_otros'+i).value=='Y'){
		var x = splitCols(getDBData('<%=request.getContextPath()%>', 'forma_pago, dias_cr_limite, nvl(monto_cr_limite,0.00), nvl(aplica_descuento,\'N\')<% if(Refer_To.trim().equals("CXCO")) { %>, (case when nvl((select limite_subsidio from tbl_cxc_tipo_otro_cliente where compania = z.compania and id = z.tipo_cliente),0) != 0 then nvl((select limite_subsidio from tbl_cxc_tipo_otro_cliente where compania = z.compania and id = z.tipo_cliente),0) - (select getconsumodia(compania,tipo_cliente,codigo,to_char(sysdate,\'dd/mm/yyyy\')) from dual) else nvl(monto_cr_limite,0) - nvl((select getSaldoClt(compania,<%=ref_id%>,codigo) from dual),0) end)<% } else { %>0<% } %> saldo', 'tbl_cxc_cliente_particular z','compania = <%=(String) session.getAttribute("_companyId")%> and codigo='+eval('document.detail.codigo'+i).value));
		
		parent.document.form0.clt_forma_pago.value = x[0];
		parent.document.form0._clt_forma_pago.value = x[0];
		parent.document.form0.dias_cr_limite.value = x[1];
		parent.document.form0.monto_cr_limite.value = x[2];
		parent.document.form0.clt_aplica_descuento.value = x[3];
		parent.document.form0._clt_aplica_descuento.value = x[3];
		var saldo=parseFloat(x[4]);
		if (<%=tipo_factura.trim().equals("CR")%> && parent.document.form0.clt_forma_pago.value == "CO") { alert('El cliente no es de tipo Credito.'); return }
		<% if (tipo_factura.trim().equals("CR") || alwaysAlertSaldo) { %>alert('El cliente '+eval('document.detail.nombre'+i).value+' tiene disponible: $'+saldo.toFixed(2));<% } %>
		parent.document.form0.saldo.value = saldo;
		if(parent.document.getElementById("tdCliente")){
			if(x[0]=='CR') parent.document.getElementById("tdCliente").className='RedText';
			else parent.document.getElementById("tdCliente").className='';
		}
		//parent.setFormaPagoIni();
		//parent.setFormaPago();
	}
	add(null, null, eval('document.detail.codigo'+i).value, eval('document.detail.nombre'+i).value, eval('document.detail.ruc'+i).value, eval('document.detail.dv'+i).value, eval('document.detail.id_precio'+i).value, eval('document.detail.facturar_al_costo'+i).value, eval('document.detail.subTipoCliente'+i).value);
	/*
	parent.document.form0.client_id.value = eval('document.detail.codigo'+i).value;
	parent.document.form0.client_name.value = eval('document.detail.nombre'+i).value;
	parent.document.form0.ruc.value = eval('document.detail.ruc'+i).value;
	parent.document.form0.dv.value = eval('document.detail.dv'+i).value;
	parent.document.form0.id_precio.value = eval('document.detail.id_precio'+i).value;
	*/
	//parent.document.form0.ref_id.value = eval('document.detail.ref_id'+i).value;
	//parent.document.form0.refer_to.value = eval('document.detail.refer_to'+i).value;
	//parent.document.form0.es_clt_cr.value = eval('document.detail.es_clt_cr'+i).value;
	parent.chkArt();
	parent.chkTipoClte();
	parent.hidePopWin(false);
<% } else if (fp.equalsIgnoreCase("saldoIni")) { %>
	window.opener.document.form1.id_cliente.value=eval('document.detail.codigo'+i).value;
	window.opener.document.form1.nombre.value=eval('document.detail.nombre'+i).value;
	window.opener.document.form1.id_cliente_view.value=eval('document.detail.codigo'+i).value;
	window.close();
<% }else if (fp.equalsIgnoreCase("morosidad")) { %>
	window.opener.document.form0.pacId.value=eval('document.detail.codigo'+i).value;
	window.opener.document.form0.nombre.value=eval('document.detail.nombre'+i).value;
	if(window.opener.document.form0.subRefType.value)window.opener.document.form0.subRefType.value=eval('document.detail.subTipoCliente'+i).value;
	window.close();
<% } else if (fp.equalsIgnoreCase("comprob")) { %>
	window.opener.document.form1.ref_id<%=idx%>.value=eval('document.detail.codigo'+i).value;
	window.opener.document.form1.nombre<%=idx%>.value=eval('document.detail.nombre'+i).value;
	window.opener.document.form1.ruc<%=idx%>.value=eval('document.detail.ruc'+i).value;
	window.opener.document.form1.dv<%=idx%>.value=eval('document.detail.dv'+i).value;
	window.close();
<% } else if (fp.equalsIgnoreCase("admision_medico_resp_new")) { %>
	window.opener.document.form1.ref_id<%=idx%>.value=eval('document.detail.codigo'+i).value;
	window.opener.document.form1.nombre<%=idx%>.value=eval('document.detail.nombre'+i).value;
	window.opener.document.form1.identificacion<%=idx%>.value=eval('document.detail.ruc'+i).value;
	//window.opener.document.form1.dv<%=idx%>.value=eval('document.detail.dv'+i).value;
	window.opener.document.form1.nacionalidad<%=idx%>.value = eval('document.detail.other1'+i).value;
	window.opener.document.form1.sexo<%=idx%>.value = eval('document.detail.other2'+i).value;
	window.opener.document.form1.nacionalidadDesc<%=idx%>.value = eval('document.detail.other3'+i).value;
	window.close();
<% } else if (fp.equalsIgnoreCase("addCliente")) { %>
	window.opener.document.form1.ref_id_resp.value=eval('document.detail.codigo'+i).value;
	window.opener.document.form1.nombreResp.value=eval('document.detail.nombre'+i).value;
	window.close();
<% }  else if (fp.equalsIgnoreCase("paciente")) { %>
	window.opener.document.form0.ref_id.value=eval('document.detail.codigo'+i).value;
	window.opener.document.form0.nombre.value=eval('document.detail.nombre'+i).value;
	//window.opener.document.form0.identificacion.value=eval('document.detail.ruc'+i).value;
	//window.opener.document.form0.dv.value=eval('document.detail.dv'+i).value;
	window.opener.document.form0.nacionalCode.value = eval('document.detail.other1'+i).value;
	window.opener.document.form0.sexo.value = eval('document.detail.other2'+i).value;
	window.opener.document.form0.nacionalidad.value = eval('document.detail.other3'+i).value;
	window.close();

	<%}%>
}

function addCliente(){
	showPopWin('../pos/add_cliente.jsp?fp=<%=fp%>&ref_id=<%=ref_id%>&refer_to=<%=Refer_To%>',winWidth*.80,_contentHeight*.80,null,null,'');
}

function add(ref_id, referTo, codigo, name, ruc, dv, id_precio, facturar_al_costo, subTipoCliente){
	parent.document.form0.client_id.value = codigo;
	parent.document.form0.client_name.value = name;
	//parent.document.form0.ref_id.value = ref_id;
	//parent.document.form0.refer_to.value = referTo;
	parent.document.form0.ruc.value = ruc;
	parent.document.form0.dv.value = dv;
	parent.document.form0.id_precio.value = id_precio;
	parent.document.form0.facturar_al_costo.value = facturar_al_costo;
	if(parent.document.form0.subTipoCliente) parent.document.form0.subTipoCliente.value = subTipoCliente;
	parent.setFormaPagoIni();
	parent.setFormaPago();
	parent.chkArt();
	parent.hidePopWin(false);
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
<% if(touch.trim().equalsIgnoreCase("Y")){%>
<link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/>
<%if(useKeypad.trim().equalsIgnoreCase("Y")){%>
<link href="../js/jquery.keypad.css" rel="stylesheet">
<style>#inlineKeypad { width: 10em; }
input[type=radio] {
		display:none;
		margin:10px;
}
</style>
<script src="../js/jquery.plugin.js"></script>
<script src="../js/jquery.keypad.js"></script>

<script>
$(document).ready(function(){
	<%if(useKeypad.trim().equalsIgnoreCase("Y")){%>
			var opts ={
				keypadOnly: false,
				layout: [
				'1234567890-',
				'qwertyuiop' + $.keypad.CLOSE,
				'asdfghjkl' + $.keypad.CLEAR,
				'zxcvbnm' +
				$.keypad.SPACE_BAR + $.keypad.BACK]
			};
			$('#name, #ruc').keypad(opts);
			$('#code').keypad({keypadOnly: false});

			$(document).on('keyup',function(evt) {
				if (evt.keyCode == 27) {
					 $('#name, #code, #ruc').keypad("hide");
				}
			});
	<%}%>
});
</script>

<%}%>
<%}%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE COMPA&Ntilde;&Iacute;A"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td align="right"><authtype type='3'><%if(tipo_factura.equals("CO")){%><a href="javascript:addCliente()" class="Link00">[ Registrar Nuevo ]</a><%}%></authtype></td>
	</tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<%
				fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("compania",compania)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("fecha",fecha)%>
				<%=fb.hidden("tipo_factura",tipo_factura)%>
				<%=fb.hidden("ref_id",ref_id)%>
				<%=fb.hidden("Refer_To",Refer_To)%>
				<%=fb.hidden("idx",idx)%>
				<%=fb.hidden("useKeypad",useKeypad)%>
				<%=fb.hidden("touch",touch)%>

				<tr class="TextFilter">
					<td>
					<%if(Refer_To.trim().equals("CXCO")){%>
					Tipo:
					<%=fb.select(ConMgr.getConnection(),"select id, descripcion from tbl_cxc_tipo_otro_cliente where compania ="+session.getAttribute("_companyId")+" and estado='A' order by descripcion","subRefType",subRefType,false,false,0, "text10", "", "", "", "T")%><%}else{%>
					<%=fb.hidden("subRefType",subRefType)%>
					<%}%>
					C&oacute;digo&nbsp;
					<%=fb.textBox("code",code,false,false,false,6,20,"Text10",null,null)%>
					Nombre
					<%=fb.textBox("name",name,false,false,false,20,"Text10",null,null)%>
					RUC/CEDULA:
					<%=fb.textBox("ruc",ruc,false,false,false,10,"Text10",null,null)%>
					Fecha Nac.:
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="format" value="dd/mm/yyyy"/>
						<jsp:param name="nameOfTBox1" value="dob"/>
						<jsp:param name="valueOfTBox1" value="<%=dob%>"/>
					</jsp:include>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("Refer_To",Refer_To)%>
				<%=fb.hidden("tipo_factura",tipo_factura)%>
				<%=fb.hidden("ref_id",ref_id)%>
				<%=fb.hidden("subRefType",subRefType)%>
				<%=fb.hidden("idx",idx)%>
				<%=fb.hidden("useKeypad",useKeypad)%>
				<%=fb.hidden("touch",touch)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("Refer_To",Refer_To)%>
				<%=fb.hidden("tipo_factura",tipo_factura)%>
				<%=fb.hidden("ref_id",ref_id)%>
				<%=fb.hidden("subRefType",subRefType)%>
				<%=fb.hidden("idx",idx)%>
				<%=fb.hidden("useKeypad",useKeypad)%>
				<%=fb.hidden("touch",touch)%>
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
		<table align="center" width="100%" cellpadding="<%=touch.trim().equalsIgnoreCase("Y")?"8":"0"%>" cellspacing="1">
			<tr class="TextHeader" align="center">
			<%if(Refer_To.equalsIgnoreCase("PAC")){%>
				<td>PacId</td>
				<%}%>
				<td>Nombre</td>
		<%if(Refer_To.equalsIgnoreCase("PAC")){%>
				<td>Fecha Nac.</td>
				<td>Edad</td>
				<td>C&eacute;dula</td>
				<td>C&oacute;digo Ref.</td>
				<%}else{%>
					<td>C&oacute;digo</td>
				<%}%>
				<%if(Refer_To.equalsIgnoreCase("EMPR")){%>
				<td>RUC</td>
				<td>DV</td>
				<%}%>
				<%if(Refer_To.equals("CXCO")){%>
		<td>C&eacute;dula</td>
				<td>L&iacute;mite Cr&eacute;dito</td>
				<%}%>
			</tr>
			<%
			fb = new FormBean("detail","","post","");
			%>
			<%=fb.formStart()%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%
			String refer_to = "";
			for (int i=0; i<al.size(); i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				String color = "TextRow02";
				if (i % 2 == 0) color = "TextRow01";
			%>
				<%//=fb.hidden("ref_id"+i,cdo.getColValue("ref_id"))%>
				<%=fb.hidden("refer_to"+i,cdo.getColValue("refer_to"))%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("ruc"+i,cdo.getColValue("ruc"))%>
				<%=fb.hidden("dv"+i,cdo.getColValue("dv"))%>
				<%=fb.hidden("id_precio"+i,cdo.getColValue("id_precio"))%>
				<%=fb.hidden("es_clt_cxc_otros"+i,cdo.getColValue("es_clt_cxc_otros"))%>
				<%=fb.hidden("facturar_al_costo"+i,cdo.getColValue("facturar_al_costo"))%>
				<%=fb.hidden("subTipoCliente"+i,cdo.getColValue("tipoCliente"))%>
				<%=fb.hidden("other1"+i,cdo.getColValue("other1"))%>
				<%=fb.hidden("other2"+i,cdo.getColValue("other2"))%>
				<%=fb.hidden("other3"+i,cdo.getColValue("other3"))%>
				<%=fb.hidden("other4"+i,cdo.getColValue("other4"))%>
				<%=fb.hidden("other5"+i,cdo.getColValue("other5"))%>
				<%//=fb.hidden("es_clt_cr"+i,cdo.getColValue("es_clt_cr"))%>
				<%//if(i!=0 && !refer_to.equals(cdo.getColValue("refer_to"))){%>
				<!--
				<tr class="TextRow03">
					<td colspan = "4"><%=cdo.getColValue("ref_desc")%></td>
				</tr>
				-->
				<%//}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onClick="javascript:setValue('<%=i%>')">
		<%if(Refer_To.equalsIgnoreCase("PAC")){%>
					<td><%=cdo.getColValue("codigo")%></td>
		<%}%>
					<td><%=cdo.getColValue("nombre")%></td>
			<%if(Refer_To.equalsIgnoreCase("PAC")){%>
					<td><%=cdo.getColValue("fecha_nacimiento")%></td>
					<td><%=cdo.getColValue("edad")%></td>
					<td><%=cdo.getColValue("cedula")%></td>
					<td><%=cdo.getColValue("cod_referencia")%></td>
		 <%}else{%>
				<td><%=(cdo.getColValue("refer_to").equals("EMPL")?cdo.getColValue("num_empleado"):cdo.getColValue("codigo"))%></td>
		 <%}%>
					<%if(Refer_To.equalsIgnoreCase("EMPR")){%>
			<td><%=cdo.getColValue("ruc")%></td>
					<td><%=cdo.getColValue("dv")%></td>
					<%}%>
				<%if(Refer_To.equals("CXCO")){%>
		 <td><%=cdo.getColValue("ruc")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cr_limite"))%></td>
					<%}%>
				</tr>
			<%
			refer_to=cdo.getColValue("refer_to");
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("Refer_To",Refer_To)%>
				<%=fb.hidden("tipo_factura",tipo_factura)%>
				<%=fb.hidden("ref_id",ref_id)%>
				<%=fb.hidden("subRefType",subRefType)%>
				<%=fb.hidden("idx",idx)%>
				<%=fb.hidden("useKeypad",useKeypad)%>
				<%=fb.hidden("touch",touch)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("Refer_To",Refer_To)%>
				<%=fb.hidden("tipo_factura",tipo_factura)%>
				<%=fb.hidden("ref_id",ref_id)%>
				<%=fb.hidden("subRefType",subRefType)%>
				<%=fb.hidden("idx",idx)%>
				<%=fb.hidden("useKeypad",useKeypad)%>
				<%=fb.hidden("touch",touch)%>
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
%>
