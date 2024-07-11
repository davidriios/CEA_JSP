<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ArrayList"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iPago" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="FAC" scope="session" class="issi.pos.Factura"/>
<jsp:useBean id="CafMgr" scope="session" class="issi.pos.CafeteriaMgr"/>
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
CafMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alForma = new ArrayList();
ArrayList alTipo = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String tipoCliente = request.getParameter("tipoCliente");
String subTipoCliente = request.getParameter("subTipoCliente");
String subTipoClienteDesc = "";
String client_id = request.getParameter("client_id");
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String codigo = request.getParameter("codigo");
String tipo_pos = request.getParameter("tipo_pos");
String tipo_factura = request.getParameter("tipo_factura");
String artType = request.getParameter("artType");
String tipo = request.getParameter("tipo");
String usa_forma_pagos = request.getParameter("usa_forma_pagos");
String limite_subsidio = request.getParameter("limite_subsidio");
String saldo = request.getParameter("saldo");
String key = "";
int lastLineNo = 0;
if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
String forma_pago_credito = "";
String forma_pago_efectivo = "";
String valida_subsidio = "S";
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
boolean viewMode = false;
if (fg == null) fg = "";
if (limite_subsidio == null) limite_subsidio = "0";
if (saldo == null) saldo = "0";
if (subTipoCliente == null) subTipoCliente = "0";
if (client_id == null) client_id = "";
if (tipo_pos== null) tipo_pos = "";
if (tipo== null) tipo = "";
if (artType== null) artType = "";
if (tipo_factura== null) tipo_factura = "";
if (mode == null) mode = "add";
if (usa_forma_pagos == null) usa_forma_pagos = "N";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (subTipoCliente.trim().equals("")) subTipoCliente = "0";
double saldo_credito = 0;
boolean showPlus = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
		sbSql.append("select nvl(get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(",'POS_USE_KEYPAD'),'N') use_keypad");
		sbSql.append(", nvl((select limite_subsidio from tbl_cxc_tipo_otro_cliente where id = ");
		sbSql.append(subTipoCliente);
		sbSql.append(" and compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append("), 0) limite_subsidio, nvl((select descripcion from tbl_cxc_tipo_otro_cliente where id = ");
		sbSql.append(subTipoCliente);
		sbSql.append(" and compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append("), 0) subTipoClienteDesc");
		sbSql.append(", get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(", 'FORMA_PAGO_CREDITO') forma_pago_credito, get_sec_comp_param(-1, 'FORMA_PAGO_EFECTIVO') forma_pago_efectivo, get_sec_comp_param(-1, 'VALIDA_SUBSIDIO') valida_subsidio ");
		sbSql.append(", nvl((select nvl(sum(monto), 0) consumo from tbl_fac_trx_forma_pagos fp where exists (select null from tbl_fac_trx f where f.company_id = fp.compania and f.doc_id = fp.doc_id and to_char(fp_codigo) = get_sec_comp_param(f.company_id, 'FORMA_PAGO_CREDITO') and f.client_id = '");
		sbSql.append(client_id);
		sbSql.append("' and f.company_id = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and trunc(f.doc_date) = trunc(sysdate)) and fp.no_referencia = '");
		sbSql.append(subTipoCliente);
		sbSql.append("'), 0) consumo");
		sbSql.append(" from dual");
		System.out.println("................."+sbSql.toString());
    CommonDataObject cdoP = SQLMgr.getData(sbSql.toString());
    if (cdoP == null) {
      cdoP = new CommonDataObject();
      cdoP.addColValue("use_keypad","N");
		} else {
			limite_subsidio = cdoP.getColValue("limite_subsidio");
			forma_pago_credito = cdoP.getColValue("forma_pago_credito");
			forma_pago_efectivo = cdoP.getColValue("forma_pago_efectivo");
			valida_subsidio = cdoP.getColValue("valida_subsidio");
			subTipoClienteDesc = cdoP.getColValue("subTipoClienteDesc");
			saldo_credito = (Double.parseDouble(limite_subsidio)-Double.parseDouble(cdoP.getColValue("consumo")));
		}
		if(Double.parseDouble(saldo)>0){limite_subsidio=saldo;}
    boolean useKeypad = cdoP.getColValue("use_keypad").equalsIgnoreCase("S") || cdoP.getColValue("use_keypad").equalsIgnoreCase("Y"); 
    sbSql = new StringBuffer();
    sbSql.append("select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cja_forma_pago where usa in ('P', 'A') and codigo is not null");
	if(tipo_pos.equals("CAF")) sbSql.append(" and codigo in (1)");
	sbSql.append(" order by 2");
	alForma = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
	alTipo = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cja_tipo_tarjeta where estado != 'I' order by 2",CommonDataObject.class);
	System.out.println("change="+request.getParameter("change"));
	if (request.getParameter("change") == null || request.getParameter("change").equals(""))
	{
		iPago.clear();
		FAC.getAlFormaPago().clear();
		sbSql = new StringBuffer();
		sbSql.append("select a.codigo fp_codigo, a.descripcion, nvl(b.usa_tipo_tarjeta, 'N') usa_tipo_tarjeta, nvl(b.usa_ck_ref, 'N') usa_ck_ref, nvl(b.usa_banco, 'N') usa_banco from tbl_cja_forma_pago a, tbl_cja_forma_pago_det b where a.usa in ('P', 'A') and a.codigo = b.id_forma_pago");
		if(usa_forma_pagos.equalsIgnoreCase("N")){
		if(tipo_pos.equals("CAF")){
			if(tipo_factura.equals("CR")){ 
				sbSql.append(" and codigo = get_sec_comp_param(");
				sbSql.append((String) session.getAttribute("_companyId"));
				sbSql.append(", 'FORMA_PAGO_CREDITO')");
			} //else sbSql.append(" and codigo in (1)");
		}
		}
		sbSql.append(" order by a.codigo");
		System.out.println("..................................................................................S Q L =\n"+sbSql);
		al = SQLMgr.getDataList(sbSql.toString());
		//al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),DetalleTransFormaPagos.class);
		lastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			CommonDataObject det = (CommonDataObject) al.get(i - 1);
			if (i < 10) key = "00"+i;
			else if (i < 100) key = "0"+i;
			else key = ""+i;
			det.addColValue("key", key);
			iPago.put(key,det);
		}
		/*
		*/
	}
	else
	{
		al = CmnMgr.reverseRecords(iPago);
		for (int i=1; i<=iPago.size(); i++)
		{
			key = al.get(i - 1).toString();
			CommonDataObject det = (CommonDataObject) iPago.get(key);
			if (det.getColValue("Fp_Codigo").equalsIgnoreCase("0")) showPlus = false;
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/bootstrap.css" type="text/css"/>
<script src="<%=request.getContextPath()%>/css/bootstrap/js/bootstrap.min.js"></script>
<script language="javascript">
document.title = 'Formas de Pago - '+document.title;
function doAction(){chkSubsidio();/*newHeight();*/checkFormaPago('');for(i=1;i<=<%=iPago.size()%>;i++){checkFormaPago(i);}_calcTotal();}
function chkSaldoSubsidio(obj){
	var consumo = parseFloat(document.formFP.consumo_subsidio.value);
	var saldo = <%=limite_subsidio%>-consumo;
	if(parseFloat(obj.value)>saldo){
		alert('El credito es mayor al disponible!');
		if(saldo<0) saldo = '';
		obj.value = saldo;
	}
}
function chkSubsidio(){
	<%if(saldo.equals("0")){%>
	var consumo = getDBData('<%=request.getContextPath()%>', 'nvl(sum(monto), 0) consumo', 'tbl_fac_trx_forma_pagos fp', 'exists (select null from tbl_fac_trx f where f.company_id = fp.compania and f.doc_id = fp.doc_id and to_char(fp_codigo) = get_sec_comp_param(f.company_id, \'FORMA_PAGO_CREDITO\') and f.client_id = \'<%=client_id%>\' and f.company_id = <%=(String) session.getAttribute("_companyId")%> and trunc(f.doc_date) = trunc(sysdate)) and fp.no_referencia = \'<%=subTipoCliente%>\'');
	<%} else {%>
	consumo = 0;
	<%}%>
	var saldo = <%=limite_subsidio%>-consumo;
	var total = parseFloat(parent.window.document.form0.total.value);
	if(saldo>total) saldo = total;
	document.formFP.consumo_subsidio.value = consumo;
	for(i=1;i<=<%=iPago.size()%>;i++){
		if(eval('document.formFP.fpCodigo'+i).value.trim()=='<%=forma_pago_credito%>'){
			if(<%=limite_subsidio%>==0 || saldo == 0) eval('document.formFP.monto'+i).readOnly=true;
			if(saldo<=0.00) eval('document.formFP.noReferencia'+i).value='';
			else {
				eval('document.formFP.monto'+i).value=saldo;
				document.getElementById("lblCredito").style.display='';
			}
		}
	}	
}
function checkFormaPago(k){
	if(eval('document.formFP.fpCodigo'+k) && eval('document.formFP.fpCodigo'+k).value!=''){
		var x = splitCols(getDBData('<%=request.getContextPath()%>', 'usa_tipo_tarjeta, usa_ck_ref, usa_banco, (select descripcion from tbl_cja_forma_pago where codigo = '+eval('document.formFP.fpCodigo'+k).value+')', 'tbl_cja_forma_pago_det', 'id_forma_pago = '+eval('document.formFP.fpCodigo'+k).value));
		document.formFP.usa_tipo_tarjeta.value	= x[0];
		document.formFP.usa_ck_ref.value 				= x[1];
		document.formFP.usa_banco.value 				= x[2];
		document.formFP.descripcion.value 			= x[3];
	}
	var tipo_factura = parent.getTipoFactura();
	if(tipo_factura=='CR') document.formFP.fpCodigo.value=document.formFP.forma_pago_credito.value;
	else {
		var fp_cr = getDBData('<%=request.getContextPath()%>', 'param_value', 'tbl_sec_comp_param','param_name = \'FORMA_PAGO_CREDITO\' and compania = <%=(String) session.getAttribute("_companyId")%>');
		<%if(usa_forma_pagos.equalsIgnoreCase("N")){%>
		if(tipo_factura=='CO' && eval('document.formFP.fpCodigo'+k) && eval('document.formFP.fpCodigo'+k).value==fp_cr){eval('document.formFP.fpCodigo'+k).value='';}
		<%}%>
		var fpCodigo=eval('document.formFP.fpCodigo'+k)?eval('document.formFP.fpCodigo'+k).value:'';

		var bMonto=true;var bTipoTarjeta=true;var bNoReferencia=true;var bDescripcionBanco=true;var bTipoBanco=true;var clearValue=true;
		if(fpCodigo=='0'){
			bMonto=false;bNoReferencia=false;clearValue=false;getRecibo(k);
		}else if(fpCodigo=='2'){
			bMonto=false;bTipoTarjeta=true;bNoReferencia=false;bDescripcionBanco=false;bTipoBanco=false;
		}else if(fpCodigo=='3'){
			bMonto=false;bTipoTarjeta=false;bNoReferencia=false;bDescripcionBanco=true;bTipoBanco=true;
		}else if(fpCodigo!=''){
			bMonto=false;bTipoTarjeta=true;bNoReferencia=false;bDescripcionBanco=true;bTipoBanco=true;
		}
		if(k==''){
		if(bMonto&&clearValue && eval('document.formFP.monto'+k))eval('document.formFP.monto'+k).value='';
		if(bTipoTarjeta && eval('document.formFP.tipoTarjeta'+k))eval('document.formFP.tipoTarjeta'+k).value='';
		if(bNoReferencia&&clearValue && eval('document.formFP.noReferencia'+k))eval('document.formFP.noReferencia'+k).value='';
		if(bDescripcionBanco && eval('document.formFP.descripcionBanco'+k))eval('document.formFP.descripcionBanco'+k).value='';
		if(bTipoBanco && eval('document.formFP.tipoBanco'+k))eval('document.formFP.tipoBanco'+k).value='';
		if(eval('document.formFP.monto'+k)) eval('document.formFP.monto'+k).readOnly=(!bMonto)?<%=(viewMode)%>:bMonto;
		if(eval('document.formFP.tipoTarjeta'+k)){
			eval('document.formFP.tipoTarjeta'+k).disabled=(!bTipoTarjeta)?<%=(viewMode || !fg.trim().equals(""))%>:bTipoTarjeta;
			eval('document.formFP.tipoTarjeta'+k).className='Text10 '+(bTipoTarjeta?'FormDataObjectDisabled':'FormDataObjectEnabled');
		}
		if(eval('document.formFP.noReferencia'+k)){ 
			eval('document.formFP.noReferencia'+k).readOnly=(!bNoReferencia)?<%=(viewMode || !fg.trim().equals(""))%>:bNoReferencia;
			eval('document.formFP.noReferencia'+k).className='Text10 '+(bNoReferencia?'FormDataObjectDisabled':'FormDataObjectEnabled');
		}
		if(eval('document.formFP.descripcionBanco'+k)){
			eval('document.formFP.descripcionBanco'+k).readOnly=(!bDescripcionBanco)?<%=(viewMode || !fg.trim().equals(""))%>:bDescripcionBanco;
			eval('document.formFP.descripcionBanco'+k).className='Text10 '+(bDescripcionBanco?'FormDataObjectDisabled':'FormDataObjectEnabled');
		}
		if(eval('document.formFP.tipoBanco'+k)){
			eval('document.formFP.tipoBanco'+k).disabled=(!bTipoBanco)?<%=(viewMode || !fg.trim().equals(""))%>:bTipoBanco;
			eval('document.formFP.tipoBanco'+k).className='Text10 '+(bTipoBanco?'FormDataObjectDisabled':'FormDataObjectEnabled');
		}
		}
		//eval('document.formFP.monto'+k).className='Text10 '+(bMonto?'FormDataObjectDisabled':'FormDataObjectRequired');		
	}//
}
function isValidFormaPago(k){var fpCodigo=eval('document.formFP.fpCodigo'+k).value;var monto=(eval('document.formFP.monto'+k).value.trim()=='')?0:parseFloat(eval('document.formFP.monto'+k).value);var tipoTarjeta=eval('document.formFP.tipoTarjeta'+k).value;var noReferencia=eval('document.formFP.noReferencia'+k).value;var descripcionBanco=eval('document.formFP.descripcionBanco'+k).value;var tipoBanco=eval('document.formFP.tipoBanco'+k).value;if(fpCodigo=='0'){if(noReferencia.trim()==''){getRecibo(k);}}else if(fpCodigo=='2'){if(noReferencia.trim()==''){eval('document.formFP.noReferencia'+k).focus();alert('Por favor introduzca el Número de Cheque!');return false;}else if(descripcionBanco.trim()==''){eval('document.formFP.descripcionBanco'+k).focus();alert('Por favor introduzca el Banco!');return false;}else if(tipoBanco.trim()==''){eval('document.formFP.tipoBanco'+k).focus();alert('Por favor introduzca el Tipo de Banco!');return false;}}else if(fpCodigo=='3'){if(tipoTarjeta==''){eval('document.formFP.tipoTarjeta'+k).focus();alert('Por favor seleccione el Tipo de Tarjeta!');return false;}}else if(fpCodigo==''){alert('Por favor seleccione la Forma de Pago!');return false;}else if(document.formFP.baction.value=='+'&&monto<=0){alert('Por favor introduzca un Monto válido!');return false;}return true;}
function _calcTotal(){var total=0.00;for(i=1;i<=<%=iPago.size()%>;i++)if(eval('document.formFP.monto'+i).value.trim()!=''&&!isNaN(eval('document.formFP.monto'+i).value)){var monto=parseFloat(eval('document.formFP.monto'+i).value);total+=monto;eval('document.formFP.monto'+i).value=monto.toFixed(2);}if(parent.window.document.form0.pagoTotal)parent.window.document.form0.pagoTotal.value=total.toFixed(2);if(parent.window.document.form0.pagoRecibido)parent.window.document.form0.pagoRecibido.value=total.toFixed(2);var aplicado=(parent.window.document.form0.aplicadoDisplay)?parseFloat(parent.window.document.form0.aplicadoDisplay.value):0;var ajustado=(parent.window.document.form0.ajustado)?parseFloat(parent.window.document.form0.ajustado.value):0;var porAplicar=total-aplicado+ajustado;if(parent.window.document.form0.porAplicar)parent.window.document.form0.porAplicar.value=porAplicar.toFixed(2);<%if(mode.trim().equals("add")){%>if(parent.window.frames['detalle'].updSaldoAlq)parent.window.frames['detalle'].updSaldoAlq();<%}%>}

function isValid(baction){document.formFP.baction.value=baction;if(document.formFP.keySize.value<=0){alert('Por favor agregue por lo menos una Forma de Pago!');return false;}for(i=1;i<=document.formFP.keySize.value;i++)if(!isValidFormaPago(i))return false;return formFPValidation();}
function addBillSerie(){parent.showPopWin('../caja/reg_recibo_billete.jsp?fg=<%=fg%>&mode=<%=mode%>&compania=<%=compania%>&anio=<%=anio%>&codigo=<%=codigo%>',winWidth*.75,winHeight*.75,null,null,'');}
function getRecibo(k){<% if (iPago.size() == 0) { %>var fpCodigo=eval('document.formFP.fpCodigo'+k).value;if(fpCodigo=='0'){var refId=parent.window.document.form0.refId.value;var turno=parent.window.document.form0.turno.value;if(parent.window.document.form0.nombre.value==''){resetFormaPago(k);alert('Por favor seleccione el Cliente!');}else if(turno==''){resetFormaPago(k);alert('Usted no tiene un Turno válido!');}else if(eval('document.formFP.monto'+k).value==''&&eval('document.formFP.noReferencia'+k).value==''){parent.showPopWin('../common/search_recibo.jsp?fp=recibos&tipoCliente=<%=tipoCliente%>&refId='+refId+'&turno='+turno+'&idx='+k,winWidth*.95,winHeight*.75,null,false,'');}else{resetFormaPago(k);}}<% } %>}
function isRecibo(obj,k){var fpCodigo=eval('document.formFP.fpCodigo'+k).value;if(fpCodigo=='0'){obj.blur();}}
function resetFormaPago(k){eval('document.formFP.fpCodigo'+k).value='';}
function _checkFormaMonto(obj,fCod, x){ 
	var porAplicar=0.00, aplicado = 0.00;
	var total = parseFloat(parent.window.document.form0.total.value);
	for(i=1;i<=<%=iPago.size()%>;i++){
		if(eval('document.formFP.monto'+i).value.trim()!=''&&!isNaN(eval('document.formFP.monto'+i).value) && x!=i){
			aplicado+=parseFloat(eval('document.formFP.monto'+i).value);
		}
	}
	if(parseInt(fCod)==1) return true; 
	else{
		porAplicar=total - aplicado; 
		if((aplicado + parseFloat(obj.value))>total){
			alert('El valor recibido no puede ser mayor que el monto facturado en esta forma de pago!\nMonto pendiente a aplicar es '+porAplicar.toFixed(2)); 
			obj.value=''; 
			return false;
		}
	}
} 
function setEfectivo(){
	var total = parseFloat(parent.window.document.form0.total.value);
	var do_submit = false;
	for(i=1;i<=<%=iPago.size()%>;i++){
		if(eval('document.formFP.fpCodigo'+i).value.trim()=='<%=forma_pago_efectivo%>'){
			eval('document.formFP.monto'+i).value=total;
			do_submit = true;
			_calcTotal();
			break;
		}
	}
	if(do_submit){
		document.formFP.baction.value='Aceptar';
		document.formFP.submit();
	}
}
</script>
<%if(useKeypad){%>
<link href="../js/jquery.keypad.css" rel="stylesheet">
<style>
#inlineKeypad { width: 10em; }
</style>
<script src="../js/jquery.plugin.js"></script>
<script src="../js/jquery.keypad.js"></script>
<script>
$(function () {
	$('.usekeypad-int').keypad({onClose: function() {
		var obj = $(this);
		var index = obj.data('index');
		<%if(!limite_subsidio.equals("0")){%>			
			if($('#fpCodigo'+index).val()=='<%=forma_pago_credito%>')	<%if(valida_subsidio.equals("S")){%>chkSaldoSubsidio($(this).get(0))<%} else {%>null<%}%>;
		<%}%>
        _calcTotal();
	}, keypadOnly: false});

    $('.usekeypad-alpha').keypad({
        keypadOnly: false, 
        layout: [
        '1234567890-', 
        'qwertyuiop' + $.keypad.CLOSE, 
        'asdfghjkl' + $.keypad.CLEAR, 
        'zxcvbnm' + 
        $.keypad.SPACE_BAR + $.keypad.BACK],
        beforeShow: function(){
          //$('.usekeypad-int').keypad('destroy')
        }
      });
   
   $(document).on('keyup',function(evt) {
        if (evt.keyCode == 27) {
           $('.usekeypad-alpha, .usekeypad-int').keypad("hide");
        }
   });
});
$(document).ready(function(){$('#save').toggleClass($('#save').attr('class')+' btn btn-md btn-success');});
</script>
<%}%>
<link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("formFP",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document.formFP.baction.value!='Guardar')if(document.formFP.baction.value=='+'&&document.formFP.fpCodigo.value==''){alert('Por favor seleccione la Forma de Pago!');error++;}else return true;");%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("keySize",""+iPago.size())%>
<%=fb.hidden("forma_pago_credito","")%>
<%=fb.hidden("tipo_pos",tipo_pos)%>
<%=fb.hidden("usa_tipo_tarjeta","")%>
<%=fb.hidden("usa_ck_ref","")%>
<%=fb.hidden("usa_banco","")%>
<%=fb.hidden("descripcion","")%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("artType",artType)%>
<%=fb.hidden("consumo_subsidio","0")%>
		<tr class="TextHeader" align="center">
			<td width="15%">Forma Pago</td>
			<td width="8%">Monto</td>
			<td width="19%">Tipo Tarjeta</td>
			<td width="14%"># Cheque / Referencia</td>
			<td width="19%">Banco</td>
			<td width="10%">Tipo Banco</td>
			<td width="3%"><%//=fb.button("btnBillSerie","$",true,false,"Text10",null,"onClick=\"javascript:addBillSerie()\"","Agregar Denominaciones / Series")%></td>
		</tr>
		<tr class="TextHeader02" align="center">
			<td><%//=fb.select("fpCodigo",alForma,"",false,(viewMode || !fg.trim().equals("")),0,"Text10",null,"onChange=\"javascript:checkFormaPago('');\"",null,"S")%></td>
			<td><%//=fb.decPlusBox("monto","",false,false,(viewMode || !fg.trim().equals("")),10,12.2,"Text10","","onFocus=\"javascript:isRecibo(this,'');\"")%></td>
			<td><%//=fb.select("tipoTarjeta",alTipo,"",false,(viewMode || !fg.trim().equals("")),0,"Text10",null,null,null,"S")%></td>
			<td><%//=fb.textBox("noReferencia","",false,false,(viewMode || !fg.trim().equals("")),20,20,"Text10","","onFocus=\"javascript:isRecibo(this,'');\"")%></td>
			<td><%//=fb.textBox("descripcionBanco","",false,false,(viewMode || !fg.trim().equals("")),35,100,"Text10","","")%></td>
			<td><%//=fb.select("tipoBanco","L=LOCAL,E=EXTRANJERO","",false,(viewMode || !fg.trim().equals("")),0,"Text10",null,null,null,"S")%></td>
			<td><%//=(showPlus)?fb.submit("agregar","+",true,(viewMode || !fg.trim().equals("")),"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Forma Pago"):"&nbsp;"%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iPago);
for (int i=1; i<=iPago.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject det = (CommonDataObject) iPago.get(key);
%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("remove"+i,"")%>
		<tr><td colspan="7"><table width="100%"><tr class="TextHeader04">
			<td width="20%">
				<%=fb.hidden("fpCodigo"+i,det.getColValue("Fp_Codigo"))%>
				<%=fb.hidden("descripcion"+i,det.getColValue("descripcion"))%>
				<%=fb.hidden("usa_tipo_tarjeta"+i,det.getColValue("usa_tipo_tarjeta"))%>
				<%=fb.hidden("usa_ck_ref"+i,det.getColValue("usa_ck_ref"))%>
				<%=fb.hidden("usa_banco"+i,det.getColValue("usa_banco"))%>
				<%if(det.getColValue("Fp_Codigo").equals(forma_pago_efectivo)){%><a href="javascript:setEfectivo();" class="btn btn-md btn-danger" style="width: 100px; text-align:center"><%=det.getColValue("descripcion")%></a> <%} else {%><%=det.getColValue("descripcion")%><%}%>
			</td>
			<td align="left" width="15%">
           <%if (useKeypad){%>
              <%=fb.decPlusBox("monto"+i,det.getColValue("Monto"),false,false,viewMode,5,12.2,(det.getColValue("Fp_Codigo").equals(forma_pago_credito) &&(limite_subsidio.equals("0") || saldo_credito<=0)?"":"usekeypad-int"),"","onBlur=\"javascript:_checkFormaMonto(this,'"+det.getColValue("Fp_Codigo")+"', "+i+");"+(det.getColValue("Fp_Codigo").equals(forma_pago_credito) && valida_subsidio.equals("S")?"chkSaldoSubsidio(this)":"")+" \" onFocus=\"javascript:isRecibo(this,'"+i+"');\"", "", false, "data-index="+i)%>
            <%}else{%>
               <%=fb.decPlusBox("monto"+i,det.getColValue("Monto"),false,false,viewMode,5,12.2,"","","onBlur=\"javascript:_checkFormaMonto(this,'"+det.getColValue("Fp_Codigo")+"', "+i+");"+(det.getColValue("Fp_Codigo").equals(forma_pago_credito) && valida_subsidio.equals("S")?"chkSaldoSubsidio(this)":"")+"_calcTotal();\" onFocus=\"javascript:isRecibo(this,'"+i+"');\"")%>
            <%}%>
            </td>
			<%if(det.getColValue("usa_tipo_tarjeta").equals("S")){%>
			<td>Tipo Tarjeta:<%=fb.select("tipoTarjeta"+i,alTipo,det.getColValue("Tipo_Tarjeta"),false,(viewMode),0,"",null,null,null,"S")%></td>
			<%}%>
			<%if(det.getColValue("usa_ck_ref").equals("S") || (!limite_subsidio.equals("0") && det.getColValue("Fp_Codigo").equals(forma_pago_credito))){%>
			<td><%if(!limite_subsidio.equals("0") && det.getColValue("Fp_Codigo").equals(forma_pago_credito)){%><label id="lblCredito" class="RedTextBold" style="display:none"><%=subTipoClienteDesc%></label><%=fb.hidden("noReferencia"+i,subTipoCliente)%><%}else{%># Referencia:<%=fb.textBox("noReferencia"+i,det.getColValue("No_Referencia"),false,false,(viewMode),10,20,(useKeypad?"usekeypad-alpha":""),"","onFocus=\"javascript:isRecibo(this,'"+i+"');\"")%><%}%></td>
			<%}%>
			<%if(det.getColValue("usa_banco").equals("S")){%>
			<td>Banco:<%=fb.textBox("descripcionBanco"+i,det.getColValue("Descripcion_Banco"),false,false,(viewMode),20,100,(useKeypad?"usekeypad-alpha":""),"","")%></td>
			<td>Tipo Banco:<%=fb.select("tipoBanco"+i,"L=LOCAL,E=EXTRANJERO",det.getColValue("Tipo_Banco"),false,(viewMode),0,"",null,null,null,"S")%></td>
			<%}%>
			<td align="right"><%=fb.submit("rem"+i,".",true,true,"",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr></table></td></tr>
<%
}
%>
<tr class="TableTopBorder"><td colspan="7" align="right"><%=fb.submit("save","Aceptar",true,(viewMode || !fg.trim().equals("")),"",null,"onClick=\"javascript:document."+fb.getFormName()+".baction.value=this.value;\"","Aceptar")%></td></tr>
<%=fb.hidden("iPagoSize", ""+iPago.size())%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	System.out.println("______________________________post");
	String baction = request.getParameter("baction");
	lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	int keySize = Integer.parseInt(request.getParameter("keySize"));

	String itemRemoved = "";
	//solo para cuando registran nuevo recibo
	FAC.getAlFormaPago().clear();
	if (fg.trim().equals(""))
	{
		for (int i=1; i<=keySize; i++)
		{
			CommonDataObject det = new CommonDataObject();
			System.out.println("fpCodigo"+i+"="+request.getParameter("fpCodigo"+i));
			if(request.getParameter("fpCodigo"+i)!=null) det.addColValue("Fp_Codigo", request.getParameter("fpCodigo"+i));
			if(request.getParameter("descripcion"+i)!=null) det.addColValue("descripcion", request.getParameter("descripcion"+i));
			if(request.getParameter("monto"+i)!=null) det.addColValue("Monto", request.getParameter("monto"+i));
			if(request.getParameter("tipoTarjeta"+i)!=null) det.addColValue("Tipo_Tarjeta", request.getParameter("tipoTarjeta"+i));
			if(request.getParameter("tipoBanco"+i)!=null) det.addColValue("Tipo_Banco", request.getParameter("tipoBanco"+i));
			if(request.getParameter("noReferencia"+i)!=null) det.addColValue("No_Referencia", request.getParameter("noReferencia"+i));
			if(request.getParameter("descripcionBanco"+i)!=null) det.addColValue("Descripcion_Banco", request.getParameter("descripcionBanco"+i));
			if(request.getParameter("usa_tipo_tarjeta"+i)!=null) det.addColValue("usa_tipo_tarjeta", request.getParameter("usa_tipo_tarjeta"+i));
			if(request.getParameter("usa_ck_ref"+i)!=null) det.addColValue("usa_ck_ref", request.getParameter("usa_ck_ref"+i));
			if(request.getParameter("usa_banco"+i)!=null) det.addColValue("usa_banco", request.getParameter("usa_banco"+i));
			if(request.getParameter("key"+i)!=null) det.addColValue("Key", request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).trim().equals("")) itemRemoved = det.getColValue("Key");
			else {
			try
			{
				iPago.put(det.getColValue("Key"),det);
				if(request.getParameter("monto"+i)!=null && !request.getParameter("monto"+i).equals("")) FAC.getAlFormaPago().add(det);
				System.out.println("adding..."+det.getColValue("Key"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
			}
		}
	}

	if (!itemRemoved.equals(""))
	{
		iPago.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&mode"+mode+"&tipoCliente="+tipoCliente+"&compania="+compania+"&anio="+anio+"&codigo="+codigo+"&change=1&lastLineNo="+lastLineNo+"&tipo_pos="+tipo_pos+"&tipo="+tipo+"&artType="+artType);
		return;
	}
	else if (baction.equals("+"))
	{
		CommonDataObject det = new CommonDataObject();
		if(request.getParameter("fpCodigo")!=null) det.addColValue("Fp_Codigo", request.getParameter("fpCodigo"));
		if(request.getParameter("descripcion")!=null) det.addColValue("descripcion", request.getParameter("descripcion"));
		if(request.getParameter("monto")!=null) det.addColValue("Monto", request.getParameter("monto"));
		if(request.getParameter("tipoTarjeta")!=null) det.addColValue("Tipo_Tarjeta", request.getParameter("tipoTarjeta"));
		if(request.getParameter("noReferencia")!=null) det.addColValue("No_Referencia", request.getParameter("noReferencia"));
		if(request.getParameter("descripcionBanco")!=null) det.addColValue("Descripcion_Banco", request.getParameter("descripcionBanco"));
		if(request.getParameter("tipoBanco")!=null) det.addColValue("Tipo_Banco", request.getParameter("tipoBanco"));
		if(request.getParameter("usa_tipo_tarjeta")!=null) det.addColValue("usa_tipo_tarjeta", request.getParameter("usa_tipo_tarjeta"));
		if(request.getParameter("usa_ck_ref")!=null) det.addColValue("usa_ck_ref", request.getParameter("usa_ck_ref"));
		if(request.getParameter("usa_banco")!=null) det.addColValue("usa_banco", request.getParameter("usa_banco"));
		System.out.println("usa_tipo_tarjeta="+ request.getParameter("usa_tipo_tarjeta"));
		System.out.println("usa_ck_ref="+ request.getParameter("usa_ck_ref"));
		System.out.println("usa_banco="+ request.getParameter("usa_banco"));

		lastLineNo++;
		if (lastLineNo < 10) key = "00"+lastLineNo;
		else if (lastLineNo < 100) key = "0"+lastLineNo;
		else key = ""+lastLineNo;
		det.addColValue("Key", key);

		try
		{
			iPago.put(key,det);
			if(request.getParameter("monto")!=null && !request.getParameter("monto").equals("")) FAC.getAlFormaPago().add(det);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&mode"+mode+"&tipoCliente="+tipoCliente+"&compania="+compania+"&change=1&lastLineNo="+lastLineNo+"&tipo_pos="+tipo_pos+"&baction="+baction+"&artType="+artType+"&tipo="+tipo);
		return;
	}
	
%>
<html>
<head>
<script language="javascript">
function closeWindow(){parent.document.form0.fpAdded.value = 'S';parent.hidePopWin(false);submitOnFormaPago();}
function submitOnFormaPago(){
	if(parseFloat(parent.window.document.form0.porAplicar.value) >= 0) parent.doSubmit('Guardar');
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>