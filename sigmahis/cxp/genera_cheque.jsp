<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<%@ page import="java.util.ResourceBundle"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==========================================================================================
FORMA OP_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OrdPagoMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "", key = "";
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String anio = request.getParameter("anio");
String cod_tipo_orden_pago = request.getParameter("cod_tipo_orden_pago");
String tipo_orden = request.getParameter("tipo_orden");
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String solicitadoPor = request.getParameter("solicitadoPor");
String appendFilter ="";
String fecha_ach = CmnMgr.getCurrentDate("dd/mm/yyyy");
boolean viewMode = false;
int iconSize = 18;
String compania = (String)session.getAttribute("_companyId");
String busca_secuencia = "N";
if(fg==null) fg = "";
if(fp==null) fp = "";
String agrupa_hon = request.getParameter("agrupa_hon");
String ach = request.getParameter("ach");
if(ach==null) ach = "";
if(agrupa_hon==null) agrupa_hon = "";
if(agrupa_hon.equals("")){
	CommonDataObject cd = new CommonDataObject();
	cd = SQLMgr.getData("select get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'LIQ_RECL_AGRUPAR_HON') agrupa_hon from dual");
	agrupa_hon = cd.getColValue("agrupa_hon");
}
if(anio==null) anio = CmnMgr.getCurrentDate("yyyy");
if(cod_tipo_orden_pago==null) cod_tipo_orden_pago = "";
if(tipo_orden==null) tipo_orden = "";
if(cod_banco==null) cod_banco = "";
if(cuenta_banco==null) cuenta_banco = "";
if(fg.equals("PM")) cod_tipo_orden_pago = "4";
if(solicitadoPor==null) solicitadoPor = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	CommonDataObject _cdo = SQLMgr.getData("select get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'SEARCH_SEC_CK') busca_secuencia from dual");
	if(_cdo==null) _cdo.addColValue("busca_secuencia", "N");
	busca_secuencia=_cdo.getColValue("busca_secuencia");
	//ArrayList alBank = sbb.getBeanList(ConMgr.getConnection(),"select cod_banco as optValueColumn, cod_banco||' - '||nombre as optLabelColumn, cod_banco as optTitleColumn from tbl_con_banco where compania = "+session.getAttribute("_companyId")+" order by nombre",CommonDataObject.class);

	ArrayList alBank = sbb.getBeanList(ConMgr.getConnection(),"select b.cod_banco||'@@'||c.cuenta_banco as optValueColumn, /*b.nombre||' --------> '||c.descripcion*/ c.cuenta_banco||' --------> '||c.descripcion||' - '|| b.nombre as optLabelColumn, nvl(b.vista, 'NA') optTitleColumn from tbl_con_banco b, tbl_con_cuenta_bancaria c where  b.cod_banco = c.cod_banco and b.compania = c.compania and c.compania = "+compania+" and c.estado_cuenta ='ACT' order by b.nombre",CommonDataObject.class);

	if(!anio.equals("")) appendFilter = " and a.anio = " + anio;
	if(!cod_tipo_orden_pago.equals("")) appendFilter += " and a.cod_tipo_orden_pago = " + cod_tipo_orden_pago;
	if(!tipo_orden.equals("")) appendFilter += (agrupa_hon.equals("Y")?" and decode(a.tipo_orden, 'S', 'H', 'M', 'H', a.tipo_orden)":" and a.tipo_orden = ")+" = '"+tipo_orden+"'";
	if(!cod_banco.equals("")) appendFilter += " and a.cod_banco = '" + cod_banco.substring(0,cod_banco.indexOf("@"))+"'"; 
	if(!cuenta_banco.equals("")) appendFilter += " and a.cuenta_banco = '" + cuenta_banco+"'";
	if(!solicitadoPor.trim().equals("")) appendFilter += " and a.solicitado_por = '"+solicitadoPor+"'";
	if(!ach.trim().equals("")) appendFilter += " and a.ach = '"+ach+"'";

	if(!anio.equals("") || !cod_tipo_orden_pago.equals("") || !tipo_orden.equals("") || !cod_banco.equals("") || !cuenta_banco.equals("")){
		sql = "select a.compania, a.cod_compania, a.anio, a.num_orden_pago, to_char(a.fecha_solicitud, 'dd/mm/yyyy') fecha_solicitud, a.estado, decode(a.estado, 'A', 'Aprobado', 'R', 'Rechazado', 'P', 'Pendiente') estado_desc, a.nom_beneficiario, decode(a.cod_medico, null,a.num_id_beneficiario,(select nvl(reg_medico,codigo) from tbl_adm_medico where codigo =a.cod_medico)) as num_id_beneficiario, a.user_creacion, a.cod_tipo_orden_pago, a.monto, to_char(a.fecha_aprobado, 'dd/mm/yyyy') fecha_aprobado, a.user_aprobado, a.cod_hacienda, a.cod_provedor, a.cod_empresa, a.cod_autorizacion, a.tipo_orden, a.solicitado_por, a.ruc, a.dv, a.usuario_creacion, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_crecion, a.beneficiario2, a.cod_banco, a.cuenta_banco, nvl(b.descripcion, ' ') hacienda_nombre, nvl((select nombre from tbl_con_banco where compania = a.compania and cod_banco = a.cod_banco), ' ') banco_nombre, getVerAch(a.cod_tipo_orden_pago, a.tipo_orden, num_id_beneficiario) ver_ach, nvl(d.descripcion, ' ') solicitado_por,nvl(a.generado,'M') as generado from tbl_cxp_orden_de_pago a, tbl_cxp_clasif_hacienda b, tbl_sec_unidad_ejec d where a.cheque_girado = 'N' and nvl(a.cheque_impreso,'N') = 'N' and a.estado = 'A' and (a.ach='N' or a.ach='Y' or a.ach is null) "+appendFilter+" and a.cod_hacienda = b.cod_hacienda(+) and a.cod_unidad_ejecutora = d.codigo(+) and a.compania = d.compania(+) and a.compania = "+(String) session.getAttribute("_companyId")+" order by a.fecha_solicitud desc";
		al = SQLMgr.getDataList(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;
var xHeight=0;
function doAction(){setDetValues();showGenCK();xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200,3/5);resetFrameHeight(document.getElementById('itemFrame'),xHeight,100,2/5);}

function doSubmit(value){
	document.orden_pago.action.value = value;
	document.orden_pago.submit();
}

function reloadPage(){
	var anio = document.orden_pago.anio.value;
	var cod_tipo_orden_pago = document.orden_pago.cod_tipo_orden_pago.value;
	var tipo_orden = document.orden_pago.tipo_orden.value;
	var cod_banco = document.orden_pago.banco_cuenta.value;
	var cuenta_banco = document.orden_pago.cuenta_banco.value;
	var agrupa_hon = document.orden_pago.agrupa_hon.value;
	var fg = document.orden_pago.fg.value;
	var ach = "";if(document.orden_pago.ach.checked)ach='Y';
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?anio='+anio+'&cod_tipo_orden_pago='+cod_tipo_orden_pago+'&tipo_orden='+tipo_orden+'&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&solicitadoPor=<%=solicitadoPor%>'+'&agrupa_hon='+agrupa_hon+'&fg='+fg+'&ach='+ach;
}

function selOtros(){
	abrir_ventana1('../common/search_pago_otro.jsp?fp=orden_pago');
}

function addFacturas(){abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=orden_pago');}

function printCK(i){
	/*
	var cod_banco = eval('document.orden_pago.cod_banco'+i).value;
	var cuenta_banco = eval('document.orden_pago.cuenta_banco'+i).value;
	var cod_compania = eval('document.orden_pago.cod_compania'+i).value;
	var fecha_emi = document.orden_pago.desp_fecha.value;
	var num_ck = document.orden_pago.num_last_ck.value;
	abrir_ventana1('../cxp/print_cheque.jsp?cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&cod_compania='+cod_compania+'&num_ck='+num_ck+'&fecha_emi='+fecha_emi);
	*/
}

function chkRB(i){
	checkRadioButton(document.orden_pago.rb, i);
	//setEncValues(i);
	setDetValues();
}

function setEncValues(i){
	document.orden_pago.ruc.value = 	eval('document.orden_pago.ruc'+i).value;
	document.orden_pago.dv.value = 	eval('document.orden_pago.dv'+i).value;
	document.orden_pago.tipo_persona_desc.value = 	eval('document.orden_pago.tipo_persona_desc'+i).value;
	document.orden_pago.clasificacion.value = 	eval('document.orden_pago.clasificacion_desc'+i).value;
	document.orden_pago.observacion.value = 	eval('document.orden_pago.observacion'+i).value;
	document.orden_pago.usuario_creacion.value = 	eval('document.orden_pago.usuario_creacion'+i).value;
	document.orden_pago.fecha_creacion.value = 	eval('document.orden_pago.fecha_creacion'+i).value;
	document.orden_pago.usuario_unidad1.value = 	eval('document.orden_pago.usuario_unidad1'+i).value;
	document.orden_pago.fecha_aprobacion1_.value = 	eval('document.orden_pago.fecha_aprobacion1'+i).value;
	document.orden_pago.usuario_aprobacion2.value = 	eval('document.orden_pago.usuario_aprobacion2_'+i).value;
	document.orden_pago.fecha_aprobacion2.value = 	eval('document.orden_pago.fecha_aprobacion2_'+i).value;
}

function setDetValues(){
	if(document.orden_pago.rb){
		var index = 	getRadioButtonValue(document.orden_pago.rb);
		var num_orden_pago = eval('document.orden_pago.num_orden_pago'+index).value;
		var anio = eval('document.orden_pago.anio'+index).value;
		var tipo = eval('document.orden_pago.generado'+index).value;
		var mode ='';
		if(tipo=='H')mode ='view' ;
		if(num_orden_pago!='' && anio !=''){
			window.frames['itemFrame'].location = '../cxp/genera_cheque_det.jsp?num_orden_pago='+num_orden_pago+'&anio='+anio+'&index='+index+'&mode='+mode;
		}
	} else window.frames['itemFrame'].location = '../cxp/genera_cheque_det.jsp';
}

function chkMotivoRechazo(){
	var size = parseInt(document.orden_pago.keySize.value);
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.orden_pago.estado1_'+i).value=='X' && eval('document.orden_pago.motivo_rechazado'+i).value==''){
			alert('Introduzca Motivo de Rechazo!');
			x++;
			break;
		}
	}
	if(x==0) return true;
	else return false;
}

function selCuentaBancaria(i){
	var cod_banco = eval('document.orden_pago.cod_banco'+i).value;
	if(cod_banco=='') alert('Seleccione Banco!');
	else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=orden_pago&cod_banco='+cod_banco+'&index='+i);
}

function setBancoValues(){
	var cod_banco = document.orden_pago.cod_banco.value;
	var cuenta_banco =	document.orden_pago.cuenta_banco.value;
	var nombre_cuenta = document.orden_pago.nombre_cuenta.value;
	var size = <%=al.size()%>
	for(i=0;i<size;i++){
		if(eval('document.orden_pago.cod_banco'+i).value==''){
			eval('document.orden_pago.cod_banco'+i).value = cod_banco;
			eval('document.orden_pago.cuenta_banco'+i).value = cuenta_banco;
			eval('document.orden_pago.nombre_cuenta'+i).value = nombre_cuenta;
		}
	}
}

function setBancoValuesNew(ind){
   var $bcObj = typeof ind == "undefined"?$("#banco_cuenta"):$("#banco_cuenta"+ind);
   var bancoCuenta = $bcObj.val();
   var banco = cuenta = "";
   var size = <%=al.size()%>;
   var cuentaNombre = $bcObj.find("option:selected").text();
   if (bancoCuenta != ""){
		banco  = bancoCuenta.split("@@")[0];
		cuenta = bancoCuenta.split("@@")[1];
	   if (typeof ind !== "undefined"){
			setVals(1);
	   }else{
		   eval('document.orden_pago.cuenta_banco').value = cuenta;
		   eval('document.orden_pago.nombre_cuenta').value = cuentaNombre.split("-------->")[1];
		   setVals(size);
	   }
		 <%if(busca_secuencia.equals("S")){%>searchLastCheque(cuenta);<%}%>
   }

   function setVals(qty){
         var __i, __ignore = false;
		 for(i=0;i<qty;i++){
		    __i = typeof ind == "undefined"?i:ind;
			__ignore = typeof ind == "undefined" && eval('document.orden_pago.cod_banco'+i).value!='';
			if(__ignore==false){
				eval('document.orden_pago.banco_cuenta'+__i).value = bancoCuenta;
				eval('document.orden_pago.cod_banco'+__i).value = banco;
				eval('document.orden_pago.cuenta_banco'+__i).value = cuenta;
				eval('document.orden_pago.nombre_cuenta'+__i).value = cuentaNombre.split("-------->")[1];
			}
		}
   }
}

function clearCuenta(i){
	eval('document.orden_pago.cuenta_banco'+i).value = '';
	eval('document.orden_pago.nombre_cuenta'+i).value = '';
}

function chkConceptos(i){
	var num_orden_pago = eval('document.orden_pago.num_orden_pago'+i).value;
	var compania = eval('document.orden_pago.cod_compania'+i).value;
	var anio = eval('document.orden_pago.anio'+i).value;
	var generado = eval('document.orden_pago.generado'+i).value;
	if(eval('document.orden_pago.chk'+i).checked && (eval('document.orden_pago.cod_tipo_orden_pago'+i).value!='1' || eval('document.orden_pago.cod_tipo_orden_pago'+i).value!='3')){
	if(generado!='H'&& generado!='P'){
		var x = splitCols(getDBData('<%=request.getContextPath()%>','chkConceptos('+compania+', '+anio+', '+num_orden_pago+')','dual',''));
		if(x[0]=='N'){
			alert(x[1]);
			eval('document.orden_pago.chk'+i).checked = false;
		} else alert(x[1]);
		//if(eval('document.orden_pago.chk'+i).checked)chkRB(i)
	 }
	}
	chkRB(i);
}

function addFacturas(i){
	var num_orden_pago = eval('document.orden_pago.num_orden_pago'+i).value;
	var tipo_orden = eval('document.orden_pago.tipo_orden'+i).value;
	var cod_tipo_orden = eval('document.orden_pago.cod_tipo_orden_pago'+i).value;
	var num_id_beneficiario = eval('document.orden_pago.num_id_beneficiario'+i).value;

	var anio = eval('document.orden_pago.anio'+i).value;
	abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=orden_pago&anio='+anio+'&num_orden_pago='+num_orden_pago+'&tipo_orden='+tipo_orden+'&cod_tipo_orden='+cod_tipo_orden+'&idBeneficiario='+num_id_beneficiario);
}

function genCheque(){
	if(document.orden_pago.num_last_ck.value != ''){
		var x = getDBData('<%=request.getContextPath()%>','1','tbl_con_cheque','che_user <> \'<%=(String) session.getAttribute("_userName")%>\'');
		if(x!='') alert('Hay otro usuario generando cheques, tenga cuidado con la secuencia de los mismos!');
		window.frames['itemFrame'].document.form1.baction.value = 'GeneraCK';
		if(window.frames['itemFrame'].chkMonto()) if(chkCuentas()&&checkEstado('2')) doSubmit('GeneraCK');
		window.frames['itemFrame'].document.form1.baction.value = '';
	} else alert('Introduzca Número de Cheque!');
}

function cierre(){var index = 	getRadioButtonValue(document.orden_pago.rg_tipopago);if(index=='1') doSubmit('Cierre');else alert('Cierre solamente para tipo de pago CHEQUE');}
function genACH(){var index =getRadioButtonValue(document.orden_pago.rg_tipopago);	if(index == '1'){alert('Seleccione el tipo de pago Correcto')}else{	window.frames['itemFrame'].document.form1.baction.value = 'GeneraACH';	if(window.frames['itemFrame'].chkMonto()) if(chkCuentas()&&checkEstado('ACH')&&chkEstructura())doSubmit('GeneraACH');	window.frames['itemFrame'].document.form1.baction.value = '';}}
function salirCK(){document.orden_pago.num_last_ck.value = '';document.orden_pago.desp_fecha.value = '';	document.getElementById("genCK").style.display = 'none'; window.close();}
function showGenCK(){var index = 	getRadioButtonValue(document.orden_pago.rg_tipopago);if(index == '1'){document.getElementById("genCK").style.display = '';} else{document.getElementById("genCK").style.display = 'none';document.getElementById("num_last_ck").value='';document.getElementById("desp_fecha").value='<%=fecha_ach%>';}}
function chkEstructura(){
	var size = <%=al.size()%>
	var x = 0, y = 0;
	var vista = '';
	for(i=0;i<size;i++){
		if(eval('document.orden_pago.chk'+i).checked){
			var $b = $("#banco_cuenta"+i);
			vista = $b.find("option:selected").attr("title");
			if(vista=='' || vista == 'NA') y++;
		}
	}
	if(y==0) return true;
	else {
		alert('No puede Generar esta transaccion con Bancos sin la estructura para tal fin!');
		return false;
	}
	
}
function chkCuentas(){
	var size = <%=al.size()%>
	var x = 0, y = 0;
	for(i=0;i<size;i++){
		if(eval('document.orden_pago.chk'+i).checked){
			y++;
		}
		if(eval('document.orden_pago.chk'+i).checked && (eval('document.orden_pago.cod_banco'+i).value == '' || eval('document.orden_pago.cuenta_banco'+i).value == '')){
			x++;
			break;
		}
	}
	if(y==0){
		alert('Seleccione al menos una Orden de Pago!');
		return false;
	} else {
		if(x==0) return true;
		else {
			alert('Ingrese el Banco y Cuenta!');
			return false;
		}
	}
}

function chkBancosCuentas(){
	var size = <%=al.size()%>
	var x = 0, y = 0;
	var banco = '', cuenta = '';
	for(i=0;i<size;i++){
		if(eval('document.orden_pago.chk'+i).checked && y==0){
			banco = eval('document.orden_pago.cod_banco'+i).value;
			cuenta = eval('document.orden_pago.cuenta_banco'+i).value;
			y++;
		} else if(eval('document.orden_pago.chk'+i).checked && y>0){
			var cod_banco = eval('document.orden_pago.cod_banco'+i).value;
			var cuenta_banco = eval('document.orden_pago.cuenta_banco'+i).value;
			if((cod_banco != '' && cod_banco != banco) || (cuenta_banco != '' && cuenta_banco != cuenta)){
				x++;
				break;
			}
		}
	}
	if(x==0) return true;
	else {
		alert('No puede Generar esta transaccion con Bancos y Cuentas Diferentes!');
		return false;
	}
}

function searchLastCheque(num_cta){
//select max(to_number(x)) z from (select replace(replace(num_cheque,'T','+'),'A','-') x from tbl_con_cheque where cod_compania= 1 and cuenta_banco = '23333')
	var x = getDBData('<%=request.getContextPath()%>','nvl(max(to_number(x)),0)+1','(select (case when substr(num_cheque,1,1) in (\'A\',\'T\',\'-\') then replace(replace(num_cheque,\'T\',\'\'),\'A\',\'\') else num_cheque end) x, num_cheque from tbl_con_cheque where cod_compania = <%=(String) session.getAttribute("_companyId")%> and cuenta_banco = \''+num_cta+'\')','');
	if(x!='') document.orden_pago.num_last_ck.value = x;
}

function chkDate(){
	/**/
	var object = document.orden_pago.fecha_ach;
	var z = splitCols(getDBData('<%=request.getContextPath()%>', 'get_sec_comp_param(-1, \'CHECK_FECHA_EMISION_ACH\'), (case when to_date(\''+object.value+'\', \'dd/mm/yyyy\') > trunc(sysdate) then 1 else 0 end)','dual',''));
	if(z[0]=='S' && z[1]!='0'){
		alert('La fecha de emisión es mayor a la fecha actual!');
		object.value = '';
	} else if(z[0]=='N'){
	alert ('Verifique el parametro "CHECK_FECHA_EMISION_ACH" si desea cambiar la fecha del ACH...');
	/*object.value = trunc(sysdate);*/
     document.getElementById("fecha_ach").value='<%=fecha_ach%>'
	}
	
}
function checkEstado(fg){var fecha = '';
if(fg=='1')fecha = document.orden_pago.fecha_ach.value;
else fecha = document.orden_pago.desp_fecha.value;
var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){if(fg=='1')document.orden_pago.fecha_ach.value='';else document.orden_pago.desp_fecha.value='';return false;}else return true;}
function updBenef(idx){var op=eval('document.orden_pago.num_orden_pago'+idx).value;var anio=eval('document.orden_pago.anio'+idx).value;showPopWin('../common/urlRedirect.jsp?forwardPage=../process/cxp_upd_op_benef.jsp&anio='+anio+'&op='+op,winWidth*.8,winHeight*.7,null,true,'');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CHEQUES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("orden_pago",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("agrupa_hon",agrupa_hon)%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.hidden("solicitadoPor",""+solicitadoPor)%>
		<tr class="TextPanel">
			<td colspan="7"><cellbytelabel>Generaci&oacute;n de Pagos</cellbytelabel></td>
		</tr>
		<tr class="TextPanel">
			<td colspan="4">
				<cellbytelabel>A&ntilde;o</cellbytelabel>:<%=fb.intBox("anio",anio,false,false,false,6,"Text10","","")%>
				Tipo Orden:
				<%if(fg.equals("PM")){%>
				<%=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in (4)"+" order by cod_tipo_orden_pago","cod_tipo_orden_pago",cod_tipo_orden_pago,false,false,0,"Text10","","","","S")%>
				<cellbytelabel>Pagos Otros</cellbytelabel>:<%=fb.select("tipo_orden","E=Empresa,B=Beneficiario,C=Corredor,"+(agrupa_hon.equals("Y")?"H=Honorarios":"M=Medico,S=Sociedad Medica"),tipo_orden,false,false,0,"Text10",null,"","","S")%>				
				<%} else {%>
				<%=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in (select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'CXP_TIPO_ORDEN') from dual),',') from dual  )) order by cod_tipo_orden_pago","cod_tipo_orden_pago",cod_tipo_orden_pago,false,false,0,"Text10","","","","S")%>
				<cellbytelabel>Pagos Otros</cellbytelabel>:<%=fb.select("tipo_orden","E=Empresa,P=Paciente,L=Liquidacion,D=Dividendo,O=Otros,C=Contratos,M=Medico,B=Beneficiario,S=Sociedad Medica,N=Ninguno",tipo_orden,false,false,0,"Text10",null,"","","S")%>				
				<%}%>
				ACH:&nbsp;<%=fb.checkbox("ach","Y",ach.equals("Y"),false)%>
				<%=fb.button("if","Ir",false, viewMode,"text10","","onClick=\"javascript:reloadPage()\"")%>
			</td>
			<td colspan="3">
				<cellbytelabel>Tipo Pago</cellbytelabel>:
				<%=fb.radio("rg_tipopago","1",true,viewMode,false,"Text10","","onClick=\"javascript:showGenCK()\"")%><cellbytelabel>Cheque</cellbytelabel>
				<!--<a href="javascript:showGenCK()"><img src="../images/cheque.gif" border="0" height="20" width="20" title="Generar Cheque"></a>-->
				<%=fb.radio("rg_tipopago","3",false,viewMode,false,"Text10","","onClick=\"javascript:showGenCK()\"")%><cellbytelabel>Transf</cellbytelabel>.
				<%=fb.radio("rg_tipopago","2",false,viewMode,false,"Text10","","onClick=\"javascript:showGenCK()\"")%><cellbytelabel>ACH</cellbytelabel>
				<a href="javascript:genACH()"><img src="../images/AirMail.png" border="0" height="20" width="20" title="Generar Transf./ACH"></a>
				&nbsp;
				<%String checkEstado = "javascript:checkEstado(1);chkDate();newHeight();";%>
				<cellbytelabel>Fecha de Ach</cellbytelabel>:
                <jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="fecha_ach" />
                <jsp:param name="valueOfTBox1" value="<%=fecha_ach%>" />
                <jsp:param name="jsEvent" value="<%=checkEstado%>" />
                <jsp:param name="onChange" value="<%=checkEstado%>" />
              </jsp:include>
				
			</td>
		</tr>
		<tr class="TextPanel" id="genCK" style="display:none">
			<td colspan="7" class="TextNormal" align="right">
			<% checkEstado = "javascript:checkEstado(2);newHeight();";%>
				<cellbytelabel>No. Cheque</cellbytelabel>:
				<%=fb.textBox("num_last_ck","",false,false,false,10,"Text10",null,"")%>
				<cellbytelabel>Fecha</cellbytelabel>:
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="desp_fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=fecha_ach%>"/>
				<jsp:param name="jsEvent" value="<%=checkEstado%>" />
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>
				&nbsp;<a href="javascript:salirCK()"><img src="../images/exit-door.jpg" border="0" height="24" width="24" title="Salir"></a>
				&nbsp;<a href="javascript:genCheque();"><img src="../images/printer.gif" border="0" height="24" width="24" title="Imprimir"></a>
			</td>
		</tr>
		<tr class="TextPanel">
			<td colspan="7">

			<%=fb.select("banco_cuenta",alBank,"",false,false,0,"Text10",null,"onChange=\"setBancoValuesNew()\"","","S")%>

			<!--<cellbytelabel>Banco!</cellbytelabel>:<%//=fb.select(ConMgr.getConnection(),"select cod_banco, cod_banco||' - '||nombre from tbl_con_banco where compania = "+session.getAttribute("_companyId")+" order by nombre","cod_banco","",false,false,0,"Text10","","","","S")%>-->
			<cellbytelabel>Cta</cellbytelabel>.:<%=fb.textBox("cuenta_banco","",false,false,true,20,"Text10",null,"")%><%=fb.textBox("nombre_cuenta","",false,false,true,40,"Text10",null,"")%>
			<%//=fb.button("buscarCuenta","...",false, viewMode,"Text10","","onClick=\"javascript:selCuentaBancaria('')\"")%>
			</td>
		</tr>
		<tr class="TextPanel">
			<td colspan="7"><cellbytelabel>Ordenes de Pagos</cellbytelabel></td>
			<!--<td colspan="1" align="right">Cierre&nbsp;<a href="javascript:chkBancosCuentas();"><img src="../images/lock.gif" border="0" height="24" width="24" title="Cierre"></a>&nbsp;</td>-->
		</tr>
		<tr>
			<td colspan="7">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader02">
					<td align="center" width="2%">&nbsp;</td>
					<!--<td align="center" width="">&nbsp;</td>-->
					<td align="center" width="2%"><%=fb.checkbox("chkAll","",false,false,"","","onClick=\"javascript:jqCheckAll(this.form.id,'chk',this);\"")%></td>
					<td align="center" width="3%"><cellbytelabel>No</cellbytelabel>.</td>
					<td align="center" width="8%"><cellbytelabel>Fecha Sol</cellbytelabel>.</td>
					<td align="center" colspan="2"><cellbytelabel>Beneficiario</cellbytelabel></td>
					<td align="center" width="5%"><cellbytelabel>Monto</cellbytelabel></td>
					<td align="center" width="4%"><cellbytelabel>Ruta Trn</cellbytelabel>.</td>
					<td align="center" width="10%"><cellbytelabel>Ruc</cellbytelabel></td>
					<td align="center" width="3%"><cellbytelabel>DV</cellbytelabel></td>
					<td align="center" width="10%"><cellbytelabel>Hacienda</cellbytelabel></td>
					<td align="center" width="5%"><cellbytelabel>Otro Benef</cellbytelabel>.</td>
					<td align="center" width="10%"><cellbytelabel>Solicitado Por</cellbytelabel></td>
					<td align="center" width="8%"><cellbytelabel>Aprobado Por</cellbytelabel></td>
					<td align="center" width="8%"><cellbytelabel>Estado</cellbytelabel></td>
					<td align="center" width="8%"><cellbytelabel>Fecha</cellbytelabel></td>
					<td align="center" width="3%"><cellbytelabel>Det</cellbytelabel>.</td>
				</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject OP = (CommonDataObject) al.get(i);
	String color = "TextRow03";
	if (i % 2 == 0) color = "TextRow04";
%>
				<%=fb.hidden("anio"+i,OP.getColValue("anio"))%>
				<%=fb.hidden("compania"+i,OP.getColValue("compania"))%>
				<%=fb.hidden("cod_compania"+i,OP.getColValue("cod_compania"))%>
				<%=fb.hidden("num_orden_pago"+i,OP.getColValue("num_orden_pago"))%>
				<%=fb.hidden("fecha_solicitud"+i,OP.getColValue("fecha_solicitud"))%>
				<%=fb.hidden("monto"+i,OP.getColValue("monto"))%>
				<%=fb.hidden("num_id_beneficiario"+i,OP.getColValue("num_id_beneficiario"))%>
				<%=fb.hidden("nom_beneficiario"+i,OP.getColValue("nom_beneficiario"))%>
				<%=fb.hidden("ruc"+i,OP.getColValue("ruc"))%>
				<%=fb.hidden("dv"+i,OP.getColValue("dv"))%>
				<%=fb.hidden("tipo_persona"+i,OP.getColValue("tipo_persona"))%>
				<%=fb.hidden("usuario_creacion"+i,OP.getColValue("usuario_creacion"))%>
				<%=fb.hidden("fecha_creacion"+i,OP.getColValue("fecha_creacion"))%>
				<%=fb.hidden("user_aprobado"+i,OP.getColValue("user_aprobado"))%>
				<%=fb.hidden("fecha_aprobado"+i,OP.getColValue("fecha_aprobado"))%>
				<%=fb.hidden("estado_ini"+i,OP.getColValue("estado"))%>
				<%=fb.hidden("cod_hacienda"+i,OP.getColValue("cod_hacienda"))%>
				<%=fb.hidden("beneficiario2"+i,OP.getColValue("beneficiario2"))%>
				<%=fb.hidden("tipo_orden"+i,OP.getColValue("tipo_orden"))%>
				<%=fb.hidden("cod_tipo_orden_pago"+i,OP.getColValue("cod_tipo_orden_pago"))%>
				<%=fb.hidden("generado"+i,OP.getColValue("generado"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
					<td align="center"><%if(!OP.getColValue("generado").trim().equals("H")){%><a href="javascript:addFacturas(<%=i%>)"><img src="../images/open-folder.jpg" border="0" height="16" width="16" title="Ingreso de Facturas"></a><%}%></td>
					<!--<td align="center"><a href="javascript:printCK(<%=i%>)"><img src="../images/printer.gif" border="0" height="16" width="16" title="Ingreso de Facturas"></a></td>-->
					<td align="center"><%=fb.checkbox("chk"+i,""+i,false,false,"","","onClick=\"javascript:chkConceptos("+i+");\"")%></td>
					<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("num_orden_pago")%></td>
					<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("fecha_solicitud")%></td>
					<td width="3%" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("num_id_beneficiario")%></td>
					<td width="8%" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("nom_beneficiario")%></td>
					<td align="right" onClick="javascript:chkRB(<%=i%>);"><%=CmnMgr.getFormattedDecimal("###,###,###.99", OP.getColValue("monto"))%></td>
					<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("ver_ach")%></td>
					<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("ruc")%></td>
					<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("dv")%></td>
					<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("hacienda_nombre")%></td>
					<td onClick="javascript:chkRB(<%=i%>);"><authtype type='50'><a href="javascript:updBenef(<%=i%>)"><img src="../images/edit.png" border="0" height="20" width="20" title="Cambiar Beneficiario"></a></authtype><%=OP.getColValue("beneficiario2")%></td>
					<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("solicitado_por")%></td>
					<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("user_aprobado")%></td>
					<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("estado_desc")%></td>
					<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("fecha_aprobado")%></td>
					<td align="center" rowspan="2" onClick="javascript:chkRB(<%=i%>);"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false,"","","onClick=\"javascript:setDetValues()\"")%></td>
				</tr>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
				    <%=fb.hidden("cod_banco"+i,"")%>
					<td align="left" colspan="9"><cellbytelabel>Banco</cellbytelabel>: <%=fb.select("banco_cuenta"+i,alBank,"",false,false,0,"Text10",null,"onChange=\"clearCuenta("+i+");setBancoValuesNew("+i+")\"","","S")%></td>
					<td align="left" colspan="7"><cellbytelabel>Cta</cellbytelabel>.: <%=fb.textBox("cuenta_banco"+i,"",false,false,true,20,"Text10",null,"")%><%=fb.textBox("nombre_cuenta"+i,"",false,false,true,40,"Text10",null,"")%><%//=fb.button("buscarCuenta"+i,"...",false, viewMode,"Text10","","onClick=\"javascript:selCuentaBancaria("+i+")\"")%></td>
				</tr>
<% } %>
				</table>
</div>
</div>
			</td>
		</tr>
		<tr>
			<td colspan="7"><iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../cxp/genera_cheque_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>"></iframe></td>
		</tr>
		</table>
	</td>
</tr>
<%
fb.appendJsValidation("\n\tif (!chkMotivoRechazo()) error++;\n");
fb.appendJsValidation("\n\tif (!chkMonto()) error++;\n");
fb.appendJsValidation("\n\tif (!chkBancosCuentas()) error++;\n");
%>
<%=fb.formEnd(true)%>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));

	String banco = "";
	String cuenta = "";
	boolean once = true;
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		if(request.getParameter("chk"+i)!=null){
			cdo = new CommonDataObject();
			cdo.addColValue("anio", request.getParameter("anio"+i));
			cdo.addColValue("num_orden_pago", request.getParameter("num_orden_pago"+i));
			cdo.addColValue("fecha_solicitud", request.getParameter("fecha_solicitud"+i));
			if(request.getParameter("cuenta_banco"+i)!=null && !request.getParameter("cuenta_banco"+i).equals("")) cdo.addColValue("cuenta_banco", request.getParameter("cuenta_banco"+i));
			if(request.getParameter("cod_banco"+i)!=null && !request.getParameter("cod_banco"+i).equals("")) cdo.addColValue("cod_banco", request.getParameter("cod_banco"+i));
			if(request.getParameter("desp_fecha")!=null && !request.getParameter("desp_fecha").equals("")) cdo.addColValue("desp_fecha", request.getParameter("desp_fecha"));
			if(request.getParameter("num_last_ck")!=null && !request.getParameter("num_last_ck").equals("")) cdo.addColValue("num_ck", request.getParameter("num_last_ck"));
			cdo.addColValue("cod_tipo_orden_pago", request.getParameter("cod_tipo_orden_pago"+i));
			cdo.addColValue("tipo_orden", request.getParameter("tipo_orden"+i));
			cdo.addColValue("num_id_beneficiario", request.getParameter("num_id_beneficiario"+i));
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("cod_compania", request.getParameter("cod_compania"+i));
			cdo.addColValue("fecha_ach", request.getParameter("fecha_ach"));
			if(request.getParameter("rg_tipopago")!=null && !request.getParameter("rg_tipopago").equals("")) cdo.addColValue("rg_tipopago", request.getParameter("rg_tipopago"));
			al.add(cdo);
			if (once) {
				once = false;
				banco = request.getParameter("cod_banco"+i);
				cuenta = request.getParameter("cuenta_banco"+i);
			}
		}
	}

	if (request.getParameter("action").equalsIgnoreCase("generaCK")){
		OrdPagoMgr.generarCK(al);
	} else if (request.getParameter("action").equalsIgnoreCase("Cierre")){
		OrdPagoMgr.cierreCK(al);
	} else if (request.getParameter("action").equalsIgnoreCase("GeneraACH")){
		OrdPagoMgr.generaACH(al);
	}
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow()
{
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
<%
if (OrdPagoMgr.getErrCode().equals("1")){
%>
	alert('<%=OrdPagoMgr.getErrMsg()%>');

	<%if(request.getParameter("action").equalsIgnoreCase("generaCK")){%>

	abrir_ventana1('../cxp/print_cheque.jsp?fp=cheque&cod_banco=<%=banco%>&cuenta_banco=<%=cuenta%>&cod_compania=<%=session.getAttribute("_companyId")%>&num_ck=<%=request.getParameter("num_last_ck")%>&fecha_emi=<%=request.getParameter("desp_fecha")%>');
	var x = getMsg('<%=request.getContextPath()%>',clientIdentifier);
	if(x=='PRINT_ANEXO'){
		alert('Hacer impresion de Anexo!');
		//abrir_ventana2('../cxp/print_cheque_anexo.jsp?num_ck=<%=request.getParameter("num_last_ck")%>&fecha_emi=<%=request.getParameter("desp_fecha")%>');
	}
	<%}%>
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?anio=<%=request.getParameter("anio")%>&cod_tipo_orden_pago=<%=request.getParameter("cod_tipo_orden_pago")%>&tipo_orden=<%=request.getParameter("tipo_orden")%>&solicitadoPor=<%=request.getParameter("solicitadoPor")%>&fg=<%=request.getParameter("fg")%>';
<%
} else throw new Exception(OrdPagoMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
