<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OrdPagoMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String nombre_cuenta = request.getParameter("nombre_cuenta");
String num_cheque = request.getParameter("num_cheque");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String estado = request.getParameter("estado");
String docType = request.getParameter("docType");
String fg = request.getParameter("fg");
String estado_impresion = request.getParameter("estado_impresion");
String tipo_fecha = request.getParameter("tipo_fecha");
String beneficiario = request.getParameter("beneficiario");
String cod_tipo_orden_pago = request.getParameter("cod_tipo_orden_pago");
String tipo_orden = request.getParameter("tipo_orden");
String tipo_orden_2 = request.getParameter("tipo_orden_2");
String solicitadoPor = request.getParameter("solicitadoPor");
String orden_salida = request.getParameter("orden_salida");
String concil = request.getParameter("concil");
String nombre_cheque = request.getParameter("nombre_cheque");
String cod_beneficiario = request.getParameter("cod_beneficiario");
String chk_anulado = request.getParameter("chk_anulado");
String fp = request.getParameter("fp");
String emailStatus = request.getParameter("emailStatus");

if(cod_banco==null) cod_banco = "";
if(cuenta_banco==null) cuenta_banco = "";
if(nombre_cuenta==null) nombre_cuenta = "";
if(num_cheque==null) num_cheque = "";
if(fecha_desde == null) fecha_desde = "";
if(fecha_hasta == null) fecha_hasta = "";
if (estado== null) estado = "";
if (docType== null) docType = "";
if (fg== null) fg = "";
if (estado_impresion== null) estado_impresion = "";
if (tipo_fecha== null) tipo_fecha = "E";
if (beneficiario == null) beneficiario = "";
if(cod_tipo_orden_pago == null) cod_tipo_orden_pago = "";
if(tipo_orden == null) tipo_orden = "";
if(tipo_orden_2 == null) tipo_orden_2 = "";
if(tipo_orden.trim().equals("")&&!tipo_orden_2.trim().equals("")) tipo_orden=tipo_orden_2;
if(solicitadoPor==null) solicitadoPor = "";
if(orden_salida==null) orden_salida = "DESC";
if(concil==null)concil="";
if(nombre_cheque==null)nombre_cheque="";
if(chk_anulado==null)chk_anulado="S";
if(cod_beneficiario==null)cod_beneficiario="";
if(fp==null)fp="";
if (emailStatus == null) emailStatus = "";

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

	if (!cod_banco.trim().equals("")) { sbFilter.append(" and upper(a.cod_banco) like '%"); sbFilter.append(cod_banco.toUpperCase()); sbFilter.append("%'"); }
	if (!cuenta_banco.trim().equals("")) { sbFilter.append(" and upper(a.cuenta_banco) like '%"); sbFilter.append(cuenta_banco.toUpperCase()); sbFilter.append("%'"); }
	if (!num_cheque.trim().equals("")) { sbFilter.append(" and upper(a.num_cheque) like '%"); sbFilter.append(num_cheque.toUpperCase()); sbFilter.append("%'"); }
	if (!fecha_desde.trim().equals("")) {
		if (tipo_fecha.equalsIgnoreCase("E")) { sbFilter.append(" and trunc(a.f_emision) >= to_date('"); sbFilter.append(fecha_desde); sbFilter.append("','dd/mm/yyyy')"); }
		else { sbFilter.append(" and trunc(a.f_anulacion) >= to_date('"); sbFilter.append(fecha_desde); sbFilter.append("','dd/mm/yyyy')"); }

		if (!tipo_fecha.equalsIgnoreCase("E")){if(!concil.trim().equals("")){if (!fecha_desde.trim().equals("")){sbFilter.append(" and trunc(a.f_emision) < to_date('"); sbFilter.append(fecha_desde); sbFilter.append("','dd/mm/yyyy')");}}}
	}
	if (!fecha_hasta.trim().equals("")) {
		if (tipo_fecha.equalsIgnoreCase("E")) { sbFilter.append(" and trunc(a.f_emision) <= to_date('"); sbFilter.append(fecha_hasta); sbFilter.append("','dd/mm/yyyy')"); }
		else { sbFilter.append(" and trunc(a.f_anulacion) <= to_date('"); sbFilter.append(fecha_hasta); sbFilter.append("','dd/mm/yyyy')"); }
	}
	if (!estado.trim().equals("")) { sbFilter.append(" and a.estado_cheque = '"); sbFilter.append(estado); sbFilter.append("'"); }
	if (chk_anulado.trim().equals("N")) { sbFilter.append(" and a.estado_cheque != 'A'"); }
	if (!docType.trim().equals("")) { sbFilter.append(" and a.tipo_pago = '"); sbFilter.append(docType); sbFilter.append("'"); }
	if (!estado_impresion.trim().equals("")) { sbFilter.append(" and a.estado_impresion = '"); sbFilter.append(estado_impresion); sbFilter.append("'"); }
	if (!beneficiario.trim().equals("")) { sbFilter.append(" and a.beneficiario like '%"); sbFilter.append(beneficiario); sbFilter.append("%'"); }
	if (!cod_beneficiario.trim().equals("")) { sbFilter.append(" and a.cod_proveedor like '%"); sbFilter.append(cod_beneficiario); sbFilter.append("%'"); }
	if (!nombre_cheque.trim().equals("")) { sbFilter.append(" and nvl(a.beneficiario2,' ') like '%"); sbFilter.append(nombre_cheque); sbFilter.append("%'"); }

	if (!cod_tipo_orden_pago.trim().equals("") || !tipo_orden.trim().equals("") || !solicitadoPor.trim().equals("")) {
		sbFilter.append(" and exists (select null from tbl_cxp_orden_de_pago where anio = a.anio and num_orden_pago = a.num_orden_pago and cod_compania = a.cod_compania");
		if (!cod_tipo_orden_pago.trim().equals("")) { sbFilter.append(" and cod_tipo_orden_pago = "); sbFilter.append(cod_tipo_orden_pago); }
		else if (solicitadoPor.trim().equals("OT")) sbFilter.append(" and cod_tipo_orden_pago = 3 and tipo_orden = 'O'");
		if (!tipo_orden.trim().equals("") && (cod_tipo_orden_pago.equals("3") || cod_tipo_orden_pago.equals("4"))) { sbFilter.append(" and tipo_orden = '"); sbFilter.append(tipo_orden); sbFilter.append("'"); }
		if (!solicitadoPor.trim().equals("") && !solicitadoPor.trim().equals("OT")) { sbFilter.append(" and solicitado_por = '"); sbFilter.append(solicitadoPor); sbFilter.append("'"); }
		sbFilter.append(")");
	}
	if (fg.equalsIgnoreCase("ACT")) {
		sbFilter.append(" and a.estado_cheque = 'A'");
	} else if (fg.equalsIgnoreCase("email")) {
		if (!emailStatus.trim().equals("")) sbFilter.append(" and ").append(emailStatus).append(" (select null from tbl_sec_mail_q where msg_ref = 'CXP_CHK_COMPROB' and ref_key = a.cod_compania||'_ck'||a.num_cheque||'_op'||a.anio||'-'||a.num_orden_pago)");
	}

	if (request.getParameter("fecha_hasta") != null) {
		sbSql.append("select a.cod_compania, a.cod_banco, a.cuenta_banco, a.num_cheque, a.cod_proveedor||' - '||a.beneficiario as beneficiario, a.beneficiario2, a.monto_girado, to_char(a.f_emision,'dd/mm/yyyy') as f_emision, a.estado_cheque");
		if (fg.equalsIgnoreCase("email")) sbSql.append(", nvl((select 'GENERADO' from tbl_sec_mail_q where msg_ref = 'CXP_CHK_COMPROB' and ref_key = a.cod_compania||'_ck'||a.num_cheque||'_op'||a.anio||'-'||a.num_orden_pago and rownum = 1),'PENDIENTE') as estado_desc");
		else sbSql.append(", decode(a.estado_cheque,'G','Girado','P','Pagado','A','Anulado') as estado_desc");
		sbSql.append(", a.anio, a.num_orden_pago, a.che_user, nvl(a.id_lote,0) as id_lote, a.tipo_pago, a.ch_reemplazo, case when nvl((select nvl(estado,'INA') from tbl_con_estado_anos where ano = to_number(to_char(a.f_emision,'yyyy')) and cod_cia = a.cod_compania),'ACT') = 'ACT' and nvl((select nvl(estatus,'X') from tbl_con_estado_meses where ano = to_number(to_char(a.f_emision,'yyyy')) and cod_cia = a.cod_compania and mes = to_number(to_char(a.f_emision,'mm')) ),'INA') <> 'CER' and nvl(comprobante,'N') = 'N' then 'S' else 'N' end as cambiarCta");
		sbSql.append(", (select nombre from tbl_con_banco where compania = a.cod_compania and cod_banco = a.cod_banco) as nombre_banco");
		sbSql.append(", (select descripcion from tbl_con_cuenta_bancaria where compania = a.cod_compania and cuenta_banco = a.cuenta_banco) as nombre_cuenta");
		if (fg.equalsIgnoreCase("CCK") || fg.equalsIgnoreCase("CC")) {
			sbSql.append(", nvl((select decode(nvl(mod_numero,'N'),'S',1,decode(nvl(mod_cuenta,'N'),'S',1,0),0) from tbl_con_cheque_modifica where cod_compania = a.cod_compania and cod_banco = a.cod_banco and num_cheque = a.num_cheque and cuenta_banco = a.cuenta_banco");
			if (fg.equalsIgnoreCase("CC")) sbSql.append(" and (nvl(mod_numero,'N') = 'S' or nvl(mod_cuenta,'N') = 'S')");
			sbSql.append("),0) as modificado");
		} else {
			sbSql.append(", nvl((select case cod_tipo_orden_pago when 1 then (select decode(pagar_ben,'M',e_mail,(select e_mail from tbl_adm_empresa where codigo = y.cod_empresa)) from tbl_adm_medico y where codigo = to_char(z.cod_provedor)) when 2 then (select email from tbl_com_proveedor where cod_provedor = z.cod_provedor) when 3 then ");
				sbSql.append("case tipo_orden when 'E' then (select e_mail from tbl_adm_empresa where codigo = z.cod_provedor) when 'P' then (select e_mail from tbl_adm_paciente where pac_id = z.cod_provedor) when 'L' then (select email from tbl_cds_centro_servicio where codigo = z.cod_provedor) when 'D' then (select email from tbl_con_accionista where codigo = z.cod_provedor and compania = a.cod_compania) when 'O' then (select email from tbl_con_pagos_otros where codigo = z.cod_provedor and compania = z.cod_compania) when 'C' then (select null from tbl_com_proveedor where cod_provedor = z.cod_provedor) when 'U' then (select email from tbl_pla_empleado where emp_id = z.cod_provedor) end");
			sbSql.append(" end from tbl_cxp_orden_de_pago z where anio = a.anio and num_orden_pago = a.num_orden_pago and cod_compania = a.cod_compania),' ') as email");
		}
		sbSql.append(" from tbl_con_cheque a where a.cod_compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		if (fg.equalsIgnoreCase("email")) sbSql.append(" and a.estado_cheque != 'A'");
		if (orden_salida.equalsIgnoreCase("DESC")) {
			sbSql.append(" order by regexp_replace(a.num_cheque,'[at|AT]?') desc, to_date(a.f_emision,'dd/mm/yyyy') desc");
		} else {
			sbSql.append(" order by regexp_replace(a.num_cheque,'[at|AT]?') asc, to_date(a.f_emision,'dd/mm/yyyy') asc");
		}
		StringBuffer sbTmp = new StringBuffer();
		sbTmp.append("select * from (select rownum as rn, a.* from (").append(sbSql).append(") a) where rn between ").append(previousVal).append(" and ").append(nextVal);
		al = SQLMgr.getDataList(sbTmp.toString());
		sbTmp = new StringBuffer();
		sbTmp.append("select count(*) from (").append(sbSql).append(")");
		rowCount = CmnMgr.getCount(sbTmp.toString());
	}
	if (!tipo_orden_2.trim().equals("")) tipo_orden = "";

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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Pagos Otros - '+document.title;

function anular(cod_banco, cuenta_banco, num_cheque)
{
	abrir_ventana('../cxp/cheque.jsp?mode=anular&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&num_cheque='+num_cheque);
}
function ver(cod_banco, cuenta_banco, num_cheque)
{
	abrir_ventana('../cxp/cheque.jsp?mode=view&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&num_cheque='+num_cheque);
}
function actualizar(cod_banco,cuenta_banco,num_cheque,fecha)
{
	abrir_ventana('../cxp/cheque_config.jsp?mode=edit&fp=modCheque&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&num_cheque='+num_cheque+'&fg=<%=fg%>');
}
function activar(cod_banco,cuenta_banco,num_cheque)
{
	showPopWin('../process/activar_cheque.jsp?mode=edit&fp=activar&banco='+cod_banco+'&cuenta='+cuenta_banco+'&noCheque='+num_cheque+'&fg=<%=fg%>',winWidth*.65,_contentHeight*.75,null,null,'');
}
function printList()
{
		var orden = document.search01.orden_salida.value;
		var chk_anulado = document.search01.chk_anulado.value;
	abrir_ventana('../cxp/print_list_cheque.jsp?orden='+orden+'&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&chk_anulado='+chk_anulado);
}
function printListTipo()
{
	var orden = document.search01.orden_salida.value;
	abrir_ventana('../cxp/print_list_cheque.jsp?fg=TP&orden='+orden+'&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');
}

function selCuentaBancaria(i){
	var cod_banco = eval('document.search01.cod_banco'+i).value;
	if(cod_banco=='') alert('Seleccione Banco!');
	else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=cheque&cod_banco='+cod_banco+'&index='+i);
}
function clearCuenta()
{
	document.search01.cuenta_banco.value='';
	document.search01.nombre_cuenta.value='';
	replaceAll(" id=\"cuenta_banco\"","");
	replaceAll(" id=\"nombre_cuenta\"","");
}

function viewComprobante(id, num_ck, tipo_pago, banco, cta){
	if(id!='0'){
		num_ck = '';
		abrir_ventana1('../cxp/print_comprobantes.jsp?id_lote='+id+'&num_ck='+num_ck+'&tipo_pago='+tipo_pago+'&cod_banco='+banco+'&cuenta_banco='+cta+'&fg=<%=fg%>');
	} else abrir_ventana1('../cxp/print_comprobantes.jsp?num_ck='+num_ck+'&tipo_pago='+tipo_pago+'&cod_banco='+banco+'&cuenta_banco='+cta+'&fg=<%=fg%>');

}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();setTipoOrden();setSubTipoOrden();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}
function setSubTipoOrden(){
var tipo_orden = document.search01.cod_tipo_orden_pago.value;
if(tipo_orden=='4'){
	document.getElementById("tipo_orden_2").style.display='';
	document.getElementById("tipo_orden").style.display='none';
} else {
	document.getElementById("tipo_orden_2").style.display='none';
	document.getElementById("tipo_orden").style.display='';
	document.getElementById("tipo_orden_2").value="";
}
}
function setTipoOrden(){
	var top = document.search01.cod_tipo_orden_pago.value;
	//if(top == '1' || top == '2') document.search01.tipo_orden.value = 'O';
}
function cambiarBenef(anio,id){
showPopWin('../process/cxp_upd_cambiar_benef.jsp?anio='+anio+'&op='+id,winWidth*.65,_contentHeight*.75,null,null,'');
}
function printRpt(gt){var orden = document.search01.orden_salida.value;abrir_ventana("../cellbyteWV/report_container.jsp?reportName=cxp/rpt_list_cheque.rptdesign&pFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&pCtrlHeader=true&pGroupType="+gt+"&pOrderDir="+orden);}
function genEmail(){<% if (sbFilter.length() > 0) { %>abrir_ventana('../process/cxp_gen_comprob_pago_email.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');<% } else { %>alert('Realizar la búsqueda para proceder a generar los Comprobantes de Pagos!');<% } %>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR PAGAR - CHEQUES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">
			<!--<authtype type='3'><a href="javascript:add()" class="Link00">[ Registro Nuevo ]</a></authtype>-->
		</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart(fg.equalsIgnoreCase("email"))%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("solicitadoPor",""+solicitadoPor)%>

<% if (fg.equalsIgnoreCase("email")) { %>
		<tr class="TextFilter">
			<td>
				Tipo Pago
				<%=fb.select("docType","1=CHEQUE,2=ACH,3=TRANSF.",docType,true,false,false,0,"Text10",null,"","","S")%>
				Tipo de Orden
				<%=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in "+(fp.equals("plan_medico")?"(4)":((solicitadoPor.trim().equals("OT"))?"(3)":"(select column_value from table(select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'CXP_TIPO_ORDEN') from dual),',') from dual))"))+" order by cod_tipo_orden_pago","cod_tipo_orden_pago",cod_tipo_orden_pago,true,false,false,0,"Text10","","onChange=\"javascript:setSubTipoOrden();\"","","S")%>
				Pago Otros
				<%=fb.select("tipo_orden",((solicitadoPor.trim().equals("OT"))?"O=Otros":"E=Empresa,P=Paciente,L=Liquidacion,D=Dividendo,O=Otros,C=Contratos"),tipo_orden,false,false,false,0,"Text10","","","","S")%>
				<%=fb.select("tipo_orden_2","E=Empresa,B=Beneficiario,M=Medico,S=Sociedad Medica,C=Corredor",tipo_orden_2,false,false,false,0,"Text10","","display:none","onChange=\"javascript:setTipoOrden();\"","S")%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha_desde" />
				<jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
				<jsp:param name="nameOfTBox2" value="fecha_hasta" />
				<jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
				</jsp:include>
				</br>
				<cellbytelabel>Benef. CXP</cellbytelabel>
				<%=fb.textBox("beneficiario",beneficiario,false,false,false,20,"Text10",null,"")%>
				<cellbytelabel>No. Cheque</cellbytelabel>
				<%=fb.textBox("num_cheque",num_cheque,false,false,false,10,"Text10",null,"")%>
				Email
				<%=fb.select("emailStatus","exists=GENERADO,not exists=PENDIENTE",emailStatus,false,false,0,"Text10",null,"",""," ")%>
				<%=fb.submit("go","Ir")%></td>
			</td>
		</tr>
<% } else { %>
		<tr class="TextFilter">
			<td><cellbytelabel>Banco</cellbytelabel>:
				<%=fb.select(ConMgr.getConnection(),"select cod_banco, cod_banco||' - '||nombre from tbl_con_banco where compania = "+(String) session.getAttribute("_companyId")+" order by nombre","cod_banco",cod_banco,false,false,0, "Text10", "",  "onChange=\"javascript:clearCuenta()\"","", "T")%></br>
				<cellbytelabel>Cta</cellbytelabel>.:
				<%=fb.textBox("cuenta_banco",cuenta_banco,false,false,true,15,"Text10",null,"")%>
				<%=fb.textBox("nombre_cuenta",nombre_cuenta,false,false,true,30,"Text10",null,"")%>
				<%=fb.button("buscarCuenta","...",false, false,"Text10","","onClick=\"javascript:selCuentaBancaria('')\"")%>
				<cellbytelabel>Benef. CXP</cellbytelabel>.:
				<%=fb.textBox("beneficiario",beneficiario,false,false,false,20,"Text10",null,"")%>
				<cellbytelabel>No. Cheque</cellbytelabel>
				<%=fb.textBox("num_cheque",num_cheque,false,false,false,10,"Text10",null,"")%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha_desde" />
				<jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
				<jsp:param name="nameOfTBox2" value="fecha_hasta" />
				<jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
				</jsp:include>
				Conciliacion:<%=fb.checkbox("concil","S",concil.equals("S"),false)%>&nbsp;
			</td>


			</tr>
			<tr class="TextFilter">
				<td><cellbytelabel>Estado</cellbytelabel>:<%=fb.select("estado",(!fg.trim().equals("ACT"))?"G=Girado, P=Pagado, A=Anulado":"A=Anulado", estado, false, false,0,"Text10",null,"","","T")%>
				Tipo Pago:<%=fb.select("docType","1=CHEQUE,2=ACH,3=TRANSF.",docType, false, false,0,"Text10",null,"","","T")%>
				Estado Impresion:<%=fb.select("estado_impresion","C=CERRADO,P=PENDIENTE",estado_impresion, false, false,0,"Text10",null,"","","T")%>
				&nbsp; Tipo Fecha:<%=fb.select("tipo_fecha","E=CREACION,A=ANULACION",tipo_fecha, false, false,0,"Text10",null,"","","S")%>
 &nbsp;Tipo de Orden



 <%//=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago order by cod_tipo_orden_pago","cod_tipo_orden_pago",cod_tipo_orden_pago,false,false,0, "text10", "", "", "", "S")%>

 <%=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in "+(fp.equals("plan_medico")?"(4)":((solicitadoPor.trim().equals("OT"))?"(3)":"(select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'CXP_TIPO_ORDEN') from dual),',') from dual  ))"))+" order by cod_tipo_orden_pago","cod_tipo_orden_pago",cod_tipo_orden_pago,false,false,0,"Text10","","onChange=\"javascript:setSubTipoOrden();\"","","S")%>




 &nbsp;
Pago Otros <%=fb.select("tipo_orden",((solicitadoPor.trim().equals("OT"))?"O=Otros":"E=Empresa,P=Paciente,L=Liquidacion,D=Dividendo,O=Otros,C=Contratos"),tipo_orden,false,false,false,0,"Text10","","","","S")%>
			 <%=fb.select("tipo_orden_2","E=Empresa,B=Beneficiario,M=Medico,S=Sociedad Medica,C=Corredor",tipo_orden_2,false,false,false,0,"Text10","","display:none","onChange=\"javascript:setTipoOrden();\"","S")%>
			 &nbsp; Ordenamiento:<%=fb.select("orden_salida","DESC=DESCENDENTE,ASC=ASCENDENTE",orden_salida, false, false,0,"Text10",null,"","","")%>

				</td>
			</tr>
			<tr class="TextFilter">
				<td><cellbytelabel>Imprimir Cheques Anulados</cellbytelabel>:<%=fb.select("chk_anulado","N=NO,S=SI", chk_anulado, false, false,0,"Text10",null,"","","")%>
				<cellbytelabel>C&oacute;digo Beneficiario:</cellbytelabel>:
				<%=fb.textBox("cod_beneficiario",cod_beneficiario,false,false,false,20,"Text10",null,"")%>
				<cellbytelabel>Nombre Cheque</cellbytelabel>:
				<%=fb.textBox("nombre_cheque",nombre_cheque,false,false,false,20,"Text10",null,"")%>

				<%=fb.submit("go","Ir")%></td>
			</tr>
<% } %>
			 <%=fb.formEnd(fg.equalsIgnoreCase("email"))%>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">
<% if (fg.equalsIgnoreCase("email")) { %>
				<a href="javascript:genEmail()" class="Link00 btn_link">[ <cellbytelabel>Generar Emails de Comprobante Electr&oacute;nico</cellbytelabel> ]</a>
<% } else { %>
				<authtype type='0'>
				<a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>
				<a href="javascript:printRpt('')" class="Link00">[ <cellbytelabel>Imprimir Lista - Excel</cellbytelabel> ]</a>
				<a href="javascript:printListTipo()" class="Link00">[ <cellbytelabel>Imprimir Por Tipo</cellbytelabel> ]</a>
				<a href="javascript:printRpt('TP')" class="Link00">[ <cellbytelabel>Imprimir Por Tipo - Excel</cellbytelabel> ]</a>
				</authtype>
<% } %>
				</td>
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
					<%=fb.hidden("cod_banco",cod_banco)%>
					<%=fb.hidden("cuenta_banco",cuenta_banco)%>
					<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
					<%=fb.hidden("num_cheque",num_cheque)%>
					<%=fb.hidden("fecha_desde",fecha_desde)%>
					<%=fb.hidden("fecha_hasta",fecha_hasta)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("docType",docType)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("estado_impresion",estado_impresion)%>
					<%=fb.hidden("tipo_fecha",tipo_fecha)%>
					<%=fb.hidden("beneficiario",beneficiario)%>
					<%=fb.hidden("tipo_orden",tipo_orden)%>
					<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
					<%=fb.hidden("tipo_orden_2",tipo_orden_2)%>
					<%=fb.hidden("solicitadoPor",""+solicitadoPor)%>
					<%=fb.hidden("orden_salida",orden_salida)%>
					<%=fb.hidden("concil",concil)%>
					<%=fb.hidden("nombre_cheque",nombre_cheque)%>
					<%=fb.hidden("chk_anulado",chk_anulado)%>
					<%=fb.hidden("cod_beneficiario",cod_beneficiario)%>
					<%=fb.hidden("fp",fp)%>

					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("cod_banco",cod_banco)%>
					<%=fb.hidden("cuenta_banco",cuenta_banco)%>
					<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
					<%=fb.hidden("num_cheque",num_cheque)%>
					<%=fb.hidden("fecha_desde",fecha_desde)%>
					<%=fb.hidden("fecha_hasta",fecha_hasta)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("docType",docType)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("estado_impresion",estado_impresion)%>
					<%=fb.hidden("tipo_fecha",tipo_fecha)%>
					<%=fb.hidden("beneficiario",beneficiario)%>
					<%=fb.hidden("tipo_orden",tipo_orden)%>
					<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
					<%=fb.hidden("tipo_orden_2",tipo_orden_2)%>
					<%=fb.hidden("solicitadoPor",""+solicitadoPor)%>
					<%=fb.hidden("orden_salida",orden_salida)%>
					<%=fb.hidden("concil",concil)%>
					<%=fb.hidden("nombre_cheque",nombre_cheque)%>
					<%=fb.hidden("chk_anulado",chk_anulado)%>
					<%=fb.hidden("cod_beneficiario",cod_beneficiario)%>
					<%=fb.hidden("fp",fp)%>
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
	<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("size",""+al.size())%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("cod_banco",cod_banco)%>
	<%=fb.hidden("cuenta_banco",cuenta_banco)%>
	<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
	<%=fb.hidden("num_cheque",num_cheque)%>
	<%=fb.hidden("fecha_desde",fecha_desde)%>
	<%=fb.hidden("fecha_hasta",fecha_hasta)%>
	<%=fb.hidden("estado",estado)%>
	<%=fb.hidden("docType",docType)%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("estado_impresion",estado_impresion)%>
	<%=fb.hidden("tipo_fecha",tipo_fecha)%>
	<%=fb.hidden("beneficiario",beneficiario)%>
	<%=fb.hidden("tipo_orden",tipo_orden)%>
	<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
	<%=fb.hidden("tipo_orden_2",tipo_orden_2)%>
	<%=fb.hidden("solicitadoPor",""+solicitadoPor)%>
	<%=fb.hidden("orden_salida",orden_salida)%>
	<%=fb.hidden("concil",concil)%>
<% String hideCol = ""; if (fg.equalsIgnoreCase("email")) { hideCol = " style=\"display:none\""; } %>
				<tr class="TextHeader">
					<td width="15%" align="center"><cellbytelabel>Banco</cellbytelabel></td>
					<td width="15%" align="center"><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
					<td width="<%=(fg.equalsIgnoreCase("email"))?"20":"13"%>%"><cellbytelabel>Beneficiario CXP</cellbytelabel></td>
					<td><cellbytelabel><% if (fg.equalsIgnoreCase("email")) { %>E-mail<% } else { %>Nombre Cheque<% } %></cellbytelabel></td>
					<td width="6%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="7%" align="center"><cellbytelabel>Num. Cheque</cellbytelabel></td>
					<td width="6%" align="center"><cellbytelabel>Fecha Emisi&oacute;n</cellbytelabel></td>
					<td width="4%" align="center"<%//=hideCol%>><cellbytelabel>Estado</cellbytelabel></td>
					<td width="7%" align="center"<%=hideCol%>><cellbytelabel>Usuario</cellbytelabel></td>
					<td width="6%" align="center"><cellbytelabel>Lote ACH</cellbytelabel></td>
					<td width="4%" align="center"<%=hideCol%>>&nbsp;</td>
					<td width="3%" align="center">&nbsp;</td>
					<td width="4%" align="center"<%=hideCol%>>&nbsp;</td>
				</tr>



				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("cod_banco"+i,cdo.getColValue("cod_banco"))%>
				<%=fb.hidden("cuenta_banco"+i,cdo.getColValue("cuenta_banco"))%>
				<%=fb.hidden("num_cheque"+i,cdo.getColValue("num_cheque"))%>
				<%=fb.hidden("f_emision"+i,cdo.getColValue("f_emision"))%>
				<%=fb.hidden("che_user"+i,cdo.getColValue("che_user"))%>
				<%=fb.hidden("monto"+i,cdo.getColValue("monto_girado"))%>
				<%//=fb.hidden("num_cheque"+i,cdo.getColValue("num_cheque"))%>
				<%//=fb.hidden("factura"+i,cdo.getColValue("factura"))%>
				<%//=fb.hidden("numero"+i,cdo.getColValue("numero"))%>
				<%//=fb.hidden("cuenta"+i,cdo.getColValue("cuenta"))%>
				<%=fb.hidden("modificado"+i,cdo.getColValue("modificado"))%>



				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("cod_banco")%> - <%=cdo.getColValue("nombre_banco")%></td>
					<td><%=cdo.getColValue("nombre_cuenta")%></td>
					<td><%=cdo.getColValue("beneficiario")%></td>
					<td><%=(fg.equalsIgnoreCase("email"))?cdo.getColValue("email"):cdo.getColValue("beneficiario2")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_girado"))%>&nbsp;</td>
					<td align="center"><a href="javascript:viewComprobante('0', '<%=cdo.getColValue("num_cheque")%>', '<%=cdo.getColValue("tipo_pago")%>', '<%=cdo.getColValue("cod_banco")%>', '<%=cdo.getColValue("cuenta_banco")%>');" class="Link00"><%=cdo.getColValue("num_cheque")%></a></td>
					<td align="center"><%=cdo.getColValue("f_emision")%></td>
					<td align="center"<%//=hideCol%>><%=cdo.getColValue("estado_desc")%></td>
					<td align="center"<%=hideCol%>><%=cdo.getColValue("che_user")%></td>
					<td align="center"><%if(!cdo.getColValue("id_lote").equals("0")){%><a href="javascript:viewComprobante('<%=cdo.getColValue("id_lote")%>', '<%=cdo.getColValue("num_cheque")%>', '<%=cdo.getColValue("tipo_pago")%>', '<%=cdo.getColValue("cod_banco")%>', '<%=cdo.getColValue("cuenta_banco")%>');" class="Link00"><%=cdo.getColValue("id_lote")%> <%}%></td>
					<td align="center"<%=hideCol%>>
					<% if (fg.equalsIgnoreCase("ACT")) { %>
						<% if (cdo.getColValue("cambiarCta").trim().equals("S")&& (cdo.getColValue("ch_reemplazo") != null && !cdo.getColValue("ch_reemplazo").trim().equals(""))) { %>
						<authtype type='55'><a href="javascript:activar('<%=cdo.getColValue("cod_banco")%>', '<%=cdo.getColValue("cuenta_banco")%>', '<%=cdo.getColValue("num_cheque")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Activar</a></authtype>
						<% } %>
					<% } else if (!fg.equalsIgnoreCase("email")) { %>
						<% if (cdo.getColValue("cambiarCta").trim().equals("S")) { %>
						<authtype type='52'><a href="javascript:actualizar('<%=cdo.getColValue("cod_banco")%>', '<%=cdo.getColValue("cuenta_banco")%>', '<%=cdo.getColValue("num_cheque")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar Cuenta</a></authtype>
						<% } %>
					<% } %>
					</td>
					<td align="center"><authtype type='1'><a href="javascript:ver('<%=cdo.getColValue("cod_banco")%>', '<%=cdo.getColValue("cuenta_banco")%>', '<%=cdo.getColValue("num_cheque")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>ver</cellbytelabel></a></authtype>
					</td>
					<td align="center"<%=hideCol%>><%if(solicitadoPor.trim().equals("OT")){%><authtype type='53'><a href="javascript:cambiarBenef(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("num_orden_pago")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextblack')"><cellbytelabel>Cambiar Benef.</cellbytelabel></a></authtype><%}%></td>
				</tr>
				<%
				}
				if(fg.trim().equals("CCK")){%>
				<tr class="TextRow02">
					<td align="right" colspan="12"><!--<authtype type='50'><%=fb.submit("save","Guardar",true,(al.size() == 0),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>--></td>
				</tr>
				<%}%>
	<%=fb.formEnd(true)%>
			</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		</div>
	<div>
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
					<%=fb.hidden("cod_banco",cod_banco)%>
					<%=fb.hidden("cuenta_banco",cuenta_banco)%>
					<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
					<%=fb.hidden("num_cheque",num_cheque)%>
					<%=fb.hidden("fecha_desde",fecha_desde)%>
					<%=fb.hidden("fecha_hasta",fecha_hasta)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("docType",docType)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("estado_impresion",estado_impresion)%>
					<%=fb.hidden("tipo_fecha",tipo_fecha)%>
					<%=fb.hidden("beneficiario",beneficiario)%>
					<%=fb.hidden("tipo_orden",tipo_orden)%>
					<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
					<%=fb.hidden("tipo_orden_2",tipo_orden_2)%>
					<%=fb.hidden("solicitadoPor",""+solicitadoPor)%>
					<%=fb.hidden("orden_salida",orden_salida)%>
					<%=fb.hidden("concil",concil)%>
					<%=fb.hidden("nombre_cheque",nombre_cheque)%>
					<%=fb.hidden("chk_anulado",chk_anulado)%>
					<%=fb.hidden("cod_beneficiario",cod_beneficiario)%>
					<%=fb.hidden("fp",fp)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("cod_banco",cod_banco)%>
					<%=fb.hidden("cuenta_banco",cuenta_banco)%>
					<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
					<%=fb.hidden("num_cheque",num_cheque)%>
					<%=fb.hidden("fecha_desde",fecha_desde)%>
					<%=fb.hidden("fecha_hasta",fecha_hasta)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("docType",docType)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("estado_impresion",estado_impresion)%>
					<%=fb.hidden("tipo_fecha",tipo_fecha)%>
					<%=fb.hidden("beneficiario",beneficiario)%>
					<%=fb.hidden("tipo_orden",tipo_orden)%>
					<%=fb.hidden("cod_tipo_orden_pago",cod_tipo_orden_pago)%>
					<%=fb.hidden("tipo_orden_2",tipo_orden_2)%>
					<%=fb.hidden("solicitadoPor",""+solicitadoPor)%>
					<%=fb.hidden("orden_salida",orden_salida)%>
					<%=fb.hidden("concil",concil)%>
					<%=fb.hidden("nombre_cheque",nombre_cheque)%>
					<%=fb.hidden("chk_anulado",chk_anulado)%>
					<%=fb.hidden("cod_beneficiario",cod_beneficiario)%>
					<%=fb.hidden("fp",fp)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//End Method GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{
	int size = Integer.parseInt(request.getParameter("size"));

	for (int i=0; i<size; i++)
	{
		if (request.getParameter("checkNo"+i) != null ||request.getParameter("checkCta"+i) != null)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("usuario_anulacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("che_aprobacion",(String) session.getAttribute("_userName"));
			//cdo.addColValue("mod_numero",request.getParameter("checkNo"));
			//cdo.addColValue("mod_monto",request.getParameter("checkMonto"));
			//cdo.addColValue("mod_cuenta",request.getParameter("checkCta"));
			//cdo.addColValue("mod_factura",request.getParameter("checkFact"));

			cdo.addColValue("f_emision",request.getParameter("f_emision"+i));
			cdo.addColValue("che_user",request.getParameter("che_user"+i));
			if(request.getParameter("checkNo"+i) != null )cdo.addColValue("numero","S");
			else cdo.addColValue("numero","N");
			if(request.getParameter("checkCta"+i) != null )cdo.addColValue("cuenta","S");
			else cdo.addColValue("cuenta","N");
			if(request.getParameter("checkMonto"+i) != null )cdo.addColValue("monto","S");
			else cdo.addColValue("monto","N");
			if(request.getParameter("checkFact"+i) != null )cdo.addColValue("factura","S");
			else cdo.addColValue("factura","N");

			cdo.addColValue("cod_banco",request.getParameter("cod_banco"+i));
			cdo.addColValue("cuenta_banco",request.getParameter("cuenta_banco"+i));
			cdo.addColValue("modificado",request.getParameter("modificado"+i));
			cdo.addColValue("num_cheque",request.getParameter("num_cheque"+i));

			al.add(cdo);
		}
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg);
	//OrdPagoMgr.aprobarCambioCK(al);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<% if (OrdPagoMgr.getErrCode().equals("1")) { %>
	alert('<%=OrdPagoMgr.getErrMsg()%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxp/cheques_list.jsp")) { %>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxp/cheques_list.jsp")%>';
<% } else { %>
	window.location = '<%=request.getContextPath()%>/cxp/cheques_list.jsp?fg=<%=fg%>';
<% } %>
<% } else throw new Exception(OrdPagoMgr.getErrException()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>