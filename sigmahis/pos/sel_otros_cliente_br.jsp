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
CommonDataObject cdo = new CommonDataObject();
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
			sbFilter.append(" and exists (select null from tbl_pla_empleado e where to_char(emp_id) = a.codigo and num_empleado = '");
			sbFilter.append(code);
			sbFilter.append("')");
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
	if (dob == null) dob = "";
	if (pCode == null) pCode = "";
	if (ruc == null) ruc = "";
	if (!ruc.trim().equals("")){
		sbFilter.append(" and ruc like '");
		sbFilter.append(ruc);
		sbFilter.append("%'");
	}

	CommonDataObject cdoQry = new CommonDataObject();
	cdoQry=SQLMgr.getData("select query from tbl_gen_query where id = 1 and refer_to = '"+Refer_To+"'");
	if(cdoQry==null) throw new Exception("No existe un listado para el tipo de cliente solicitado!");
	System.out.println("query......=\n"+cdoQry.getColValue("query"));

	sbSql = new StringBuffer();
	sbSql.append("select a.compania, a.codigo, a.refer_to, a.nombre, to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento, a.ruc, nvl(a.dv,' ')as dv, nvl(b.id_precio, 0) id_precio, decode(a.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = a.codigo), a.codigo) num_empleado, (case when to_number(get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'TP_CLIENTE_OTROS')) = ");
	sbSql.append(ref_id);
	sbSql.append(" then 'Y' else 'N' end) es_clt_cxc_otros, (case when to_number(get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'TP_CLIENTE_OTROS')) = ");
	sbSql.append(ref_id);
	sbSql.append(" then (select facturar_al_costo from tbl_cxc_cliente_particular cp where cp.compania = a.compania and  to_char(cp.codigo) = a.codigo) else 'N' end) facturar_al_costo,");
	if(Refer_To.trim().equals("CXCO"))sbSql.append(" a.tipo_cliente ");
	else sbSql.append(" null");
	sbSql.append(" as tipoCliente");
	if(Refer_To.trim().equals("CXCO")){
		sbSql.append(", decode(nvl((select forma_pago from tbl_cxc_cliente_particular cp where cp.compania = a.compania and to_char(cp.codigo) = a.codigo), 'CO'), 'CR', (nvl((select monto_cr_limite from tbl_cxc_cliente_particular cp where cp.compania = a.compania and to_char(cp.codigo) = a.codigo), 0)-nvl(getSaldoClt(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(", ");
		sbSql.append(ref_id);
		sbSql.append(", a.codigo), 0)), 0) saldo, nvl((select monto_cr_limite from tbl_cxc_cliente_particular cp where cp.compania = a.compania and to_char(cp.codigo) = a.codigo), 0) monto_cr_limite");
	} else {
		sbSql.append(", 0 saldo, 0 monto_cr_limite");
	}
	sbSql.append(",a.other1, a.other2,a.other3,a.other4,a.other5, get_age(a.fecha_nac, trunc(sysdate), 'y') as edad ");
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


	if ((sbSql.length() > 0 && sbFilter.length() > 0)||(request.getParameter("code")!=null && fp.equalsIgnoreCase("admision_medico_resp_new"))){
		cdo = SQLMgr.getData(sbSql.toString());
	}
	else System.out.println("* * *   There is not sql statement to execute!   * * *");
	if(cdo==null){
		cdo = new CommonDataObject();
		cdo.addColValue("nombre", "NO EXISTE");
		cdo.addColValue("codigo", "0");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Common - '+document.title;
function filtrar(){
	selCliente();
}
function selCliente(){
	var tipo_factura = getRadioButtonValue(parent.document.form0.tipo_factura);
	var tipo_pos = parent.document.form0.tipo_pos.value;
	var ref_id = parent.document.form0.ref_id.value;
	var refer_to = parent.document.form0.refer_to.value;
	var es_clt_cr = parent.document.form0.es_clt_cr.value;
	var es_clt_cxco = parent.document.form0.es_clt_cxco.value;
	var code = document.search01.code.value;
	document.search01.ref_id.value = ref_id;
	document.search01.fp.value = 'cargo_dev_oc';
	document.search01.referTo.value = refer_to;
	document.search01.tipo_factura.value = tipo_factura;
	document.search01.Refer_To.value = refer_to;
	if(es_clt_cr=='N' && tipo_factura=='CR' && es_clt_cxco=='N') alert('Tipo de cliente seleccionado no permite ventas a crédito!');
	else window.location='../pos/sel_otros_cliente_br.jsp?fp=cargo_dev_oc&mode=<%=mode%>&tipo_factura='+tipo_factura+'&tipo_pos='+tipo_pos+'&ref_id='+ref_id+'&Refer_To='+refer_to+'&code='+code;
}

function setValue(codigo){
<% if (fp.equalsIgnoreCase("cargo_dev_oc")) { %>

	if('<%=cdo.getColValue("es_clt_cxc_otros")%>'=='Y'){
		var x = splitCols(getDBData('<%=request.getContextPath()%>', 'forma_pago, dias_cr_limite, nvl(monto_cr_limite, 0.00), nvl(aplica_descuento, \'N\')', 'tbl_cxc_cliente_particular','codigo='+codigo));
		parent.document.form0.clt_forma_pago.value = x[0];
		parent.document.form0._clt_forma_pago.value = x[0];
		parent.document.form0.dias_cr_limite.value = x[1];
		parent.document.form0.monto_cr_limite.value = x[2];
		parent.document.form0.clt_aplica_descuento.value = x[3];
		parent.document.form0._clt_aplica_descuento.value = x[3];
		parent.document.form0.saldo.value = '<%=cdo.getColValue("saldo")%>';
		if(parent.document.getElementById("tdCliente")){
			if(x[0]=='CR') parent.document.getElementById("tdCliente").className='RedText';
			else parent.document.getElementById("tdCliente").className='';
		}
		//parent.setFormaPagoIni();
		//parent.setFormaPago();
	}
	if('<%=cdo.getColValue("nombre")%>'=='NO EXISTE'){
		 alert('No existe cliente!');
		 add(null, null, '0', 'CLIENTE CONTADO', '0', '0', '0', 'N');
	}
	else {
		add(null, null, '<%=cdo.getColValue("codigo")%>', '<%=cdo.getColValue("nombre")%>', '<%=cdo.getColValue("ruc")%>', '<%=cdo.getColValue("dv")%>', '<%=cdo.getColValue("id_precio")%>', '<%=cdo.getColValue("facturar_al_costo")%>', '<%=cdo.getColValue("tipoCliente")%>');
		parent.chkArt();
	}
<% }%>
}

function addCliente(){
	showPopWin('../pos/add_cliente.jsp?fp=cafeteria&ref_id=<%=ref_id%>&refer_to=<%=Refer_To%>',winWidth*.80,_contentHeight*.80,null,null,'');
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
}
var xHeight=0;
function doAction(){
	var codigo = '<%=cdo.getColValue("codigo")%>';
	if(codigo!='') setValue(codigo);
}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- =============================   S E A R C H   E N G I N E S   S T A R T   H E R E   ============================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<%
				fb = new FormBean("search01",request.getContextPath()+request.getServletPath(),FormBean.GET,"onSubmit=\"javascript:filtrar();\"");
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

				<tr class="TextRow01">
					<td>
					<%=fb.textBox("code",code,false,false,false,12,20,"Text10",null,null)%>
					<%=fb.button("go"," I R ",true,false,null,null,"onClick=\"javascript:filtrar()\"")%>
					</td>
				</tr>
				<%=fb.formEnd()%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
