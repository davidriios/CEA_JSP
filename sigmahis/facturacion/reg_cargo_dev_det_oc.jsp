<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactCargoCliente"%>
<%@ page import="issi.facturacion.FactDetCargoCliente"%>
<%@ page import="issi.facturacion.FactDetTransComp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="FTransMgr" scope="page" class="issi.facturacion.FactCargoClienteMgr" />
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="OtroCargo" scope="session" class="issi.facturacion.FactCargoCliente" />
<jsp:useBean id="fTranComp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCompKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranDComp" scope="session" class="java.util.Hashtable" />

<%
/**
==================================================================================
fg=xxx=FAC80150	FACTURACION
fg=yyy=FAC80060 INVENTARIO
fg=www=FAC80060_PAMD
==================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
FTransMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String id = request.getParameter("id");
String devol = request.getParameter("devol");

boolean viewMode = false;
System.out.println("fg........="+fg);


if (mode == null) mode = "add";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null && !devol.equals("S")) fTranCarg.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
	<%
	if(type!=null && type.equals("1")){
	%>
	var fg				= document.form1.fg.value;
	var tipoTrans	= parent.document.form0.tipoTransaccion.value;
	var tipo_clte	= parent.document.form0.tipo_cliente.value;
	var empresa	= parent.document.form0.cod_empresa.value;
	var medico	= parent.document.form0.cod_medico.value;

	abrir_ventana1('../common/sel_otros_cargos.jsp?mode=<%=mode%>&fg='+fg+'&fp=cargo_dev_pac_oc&tipoTransaccion='+tipoTrans+'&tipo_clte='+tipo_clte+'&empresa='+empresa+'&medico='+medico);
	<%
	}
	%>
	calc();
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	if(parent.document.form0.tipo_valor=='P') changeReadOnly(true);
	else changeReadOnly(false);

}

function calc(){
	var iCounter = 0;
	var availableQty = 0;
	var qty = 0;
	var action = document.form1.baction.value;
	var total = 0.00, monto = 0.00, totali = 0.00, desc = 0.00, desc_total = 0.00, itbm_x_item = 0.00, tot_itbm = 0.00;
	<%if(fg.equals("xxx") || fg.equals("yyy")){%>
	var valor = parent.document.form0.valor.value;
	var tipo_valor = parent.document.form0.tipo_valor.value;
	<%}%>
	var descuento = parent.document.form0.descuento.value;
	var tipo_cliente = parent.document.form0.tipo_cliente.value;
	var recargo = 0.00, porc_recargo = 0.00;
	<%if(fg.equals("www")){%>
	if(tipo_cliente!=''){
	porc_recargo = getDBData('<%=request.getContextPath()%>','porcentaje_recargo','tbl_fac_tipo_cliente','compania = <%=(String) session.getAttribute("_companyId")%> and codigo = '+tipo_cliente+' and activo_inactivo = \'A\'','');
	}
	if(porc_recargo!='') porc_recargo = parseFloat(porc_recargo);
	<%}%>
	if(!isNaN(descuento) && descuento != '') descuento = parseFloat(descuento);
	else descuento = 0.00;
<%
	if (fTranCarg.size() > 0) al = CmnMgr.reverseRecords(fTranCarg);
	for (int i=0; i<fTranCarg.size(); i++){
%>

	if (isNaN(document.form1.cantidad<%=i%>.value) || ((document.form1.cantidad<%=i%>.value != '') && ((parseFloat(document.form1.cantidad<%=i%>.value) % 1) != 0))){
		top.CBMSG.warning('Por favor ingresar Cantidad válida!');
		document.form1.cantidad<%=i%>.select();
		return false;
	} else if (document.form1.cantidad<%=i%>.value != '' && parseInt(document.form1.cantidad<%=i%>.value,10) != 0){
		iCounter++;
		qty = parseInt(document.form1.cantidad<%=i%>.value,10);
		monto = parseFloat(document.form1.monto<%=i%>.value);
		totali = qty * monto;
		total += totali;
		document.form1.monto_total<%=i%>.value=totali.toFixed(2);

		desc = 0.00;
		<%//if(devol.equals("S") || mode.equals("view")){%>
		//if(!isNaN(document.form1.desc<%=i%>.value) && document.form1.desc<%=i%>.value != '') desc_total += parseFloat(document.form1.desc<%=i%>.value);
		<%//} else {%>
		<%if(fg.equals("xxx") || fg.equals("yyy")){%>
		if(valor != '' && tipo_valor != '' && tipo_valor == 'P'){
			desc = monto * qty * parseFloat(valor)/100;
			var _desc = desc;
			desc_total += parseFloat(desc.toFixed(2));
			document.form1.desc<%=i%>.value = desc.toFixed(2);
		} else if(valor != '' && tipo_valor != '' && tipo_valor == 'M'){
			if(!isNaN(document.form1.desc<%=i%>.value) && document.form1.desc<%=i%>.value != '') desc_total += parseFloat(document.form1.desc<%=i%>.value);
		}
		<%} else if(fg.equals("www") && mode.equals("add")){%>
		if(tipo_cliente=='14'/* || tipo_cliente=='16'*/){
			desc = monto * qty * 15/100;
			var _desc = desc;
			desc_total += parseFloat(desc.toFixed(2));
			document.form1.desc<%=i%>.value = desc.toFixed(2);
			document.form1.recargo<%=i%>.value = monto * porc_recargo / 100;
		}
		<%}%>
		<%//}%>

		if(document.form1.itbm<%=i%>.value == 'S'){
		itbm_x_item = (totali-desc)*(<%=session.getAttribute("_taxPercent")%>/100);
		tot_itbm += itbm_x_item;
		document.form1.itbm_x_item<%=i%>.value = itbm_x_item.toFixed(2);
		}

	} else if (parseInt(document.form1.cantidad<%=i%>.value,10) == 0 && action=='Guardar'){
		iCounter++;
		top.CBMSG.warning('Cantidad no puede ser igual a 0!');
		document.form1.cantidad<%=i%>.select();
		return false;
	} else if (parseFloat(document.form1.monto<%=i%>.value) == 0 && action=='Guardar' && document.form1.tipo_detalle<%=i%>.value == 'I'){
		iCounter++;
		top.CBMSG.warning('Monto no puede ser igual a 0!');
		document.form1.monto<%=i%>.select();
		return false;
	}
<%
	}
%>
	//if(isNaN(desc_total) && desc_total != '' && desc_total==0 && descuento != 0) desc_total = descuento;
	//else desc_total = 0.00;
	var _desc_total = desc_total;
	document.form1.sub_total.value = total.toFixed(2);
<%
	if (viewMode)
	{
%>
	desc_total = <%=OtroCargo.getDescuento()%>;
	tot_itbm = <%=OtroCargo.getItbm()%>;
	document.form1.descuento_total.value = desc_total.toFixed(2);
	document.form1.itbm.value = tot_itbm.toFixed(2);
	document.form1.total.value = (total-desc_total+tot_itbm).toFixed(2);
//	parent.document.form0.descuento.value = _desc_total.toFixed(2);
<%
	}
	else
	{
%>
	document.form1.descuento_total.value = _desc_total.toFixed(2);
	document.form1.itbm.value = tot_itbm.toFixed(2);
	document.form1.total.value = (total-desc_total+tot_itbm).toFixed(2);
	parent.document.form0.descuento.value = _desc_total.toFixed(2);
<%
	}
%>
	if(action=="Guardar"){
		if (iCounter > 0) return true;
		else return false;
	} else return true;
}

function _doSubmit(valor){
	parent.document.form0.baction.value = valor;
	parent.document.form0.clearHT.value = 'N';
	doSubmit();
}

function doSubmit(){
	document.form1.baction.value 						= parent.document.form0.baction.value;
	document.form1.saveOption.value 				= parent.document.form0.saveOption.value;
	//document.form1.fg.value 								= parent.document.form0.fg.value;
	document.form1.clearHT.value 						= parent.document.form0.clearHT.value;

	//document.form1.codigo.value							= parent.document.form0.codigo.value;

	document.form1.provincia_emp.value 			= parent.document.form0.provincia_emp.value;
	document.form1.sigla_emp.value 					= parent.document.form0.sigla_emp.value;
	document.form1.tomo_emp.value 					= parent.document.form0.tomo_emp.value;
	document.form1.asiento_emp.value 				= parent.document.form0.asiento_emp.value;

	document.form1.cod_empresa.value 				= parent.document.form0.cod_empresa.value;
	document.form1.cod_medico.value 				= parent.document.form0.cod_medico.value;
	document.form1.centro_servicio.value 		= parent.document.form0.centro_servicio.value;
	document.form1.contrato.value 					= parent.document.form0.contrato.value;
	document.form1.particular.value 				= parent.document.form0.particular.value;
	document.form1.compania.value 					= parent.document.form0.compania.value;
	document.form1.compania_desc.value 			= parent.document.form0.compania_desc.value;
	document.form1.tipo_cliente.value 			= parent.document.form0.tipo_cliente.value;
	document.form1.tipo_cliente_desc.value 	= parent.document.form0.tipo_cliente_desc.value;
	document.form1.cliente.value 						= parent.document.form0.cliente.value;
	document.form1.cliente2.value 					= parent.document.form0.cliente2.value;
	document.form1.tipoTransaccion.value 		= parent.document.form0.tipoTransaccion.value;
	document.form1.num_factura.value 				= parent.document.form0.num_factura.value;
	document.form1.no_cargo_appx.value 			= parent.document.form0.no_cargo_appx.value;
	document.form1.descuento.value 					= parent.document.form0.descuento.value;
	<%if(fg.equals("xxx") || fg.equals("yyy")){%>
	document.form1.tipo_desc.value 					= parent.document.form0.tipo_desc.value;
	<%} else if(fg.equals("www")){%>
	document.form1.aprobacion_hna.value 		= parent.document.form0.aprobacion_hna.value;
	document.form1.fecha_vencim.value 			= parent.document.form0.fecha_vencim.value;
	document.form1.fecha_nacimiento.value 	= parent.document.form0.fecha_nacimiento.value;
	document.form1.codigo_paciente.value 		= parent.document.form0.codigo_paciente.value;
	document.form1.medico_receta.value 			= parent.document.form0.medico_receta.value;
	document.form1.limite.value 						= parent.document.form0.limite.value;
	document.form1.visita.value 						= parent.document.form0.visita.value;
	document.form1.diag_hna1.value 					= parent.document.form0.diag_hna1.value;
	document.form1.diag_hna2.value 					= parent.document.form0.diag_hna2.value;
	document.form1.diag_hna3.value 					= parent.document.form0.diag_hna3.value;
	document.form1.diag_hna4.value 					= parent.document.form0.diag_hna4.value;
	<%}%>
	document.form1.tipo_cli_alq.value 			= parent.document.form0.tipo_cli_alq.value;
	document.form1.cliente_alq.value 				= parent.document.form0.cliente_alq.value;
	document.form1.cia_contrato.value 			= parent.document.form0.cia_contrato.value;
	document.form1.cob_tasa_gasnet.value 		= parent.document.form0.cob_tasa_gasnet.value;

	document.form1.gasnet_pac_id.value 		= parent.document.form0.gasnet_pac_id.value;
	document.form1.codigo_pac.value 		= parent.document.form0.codigo_pac.value;
	document.form1.fecha_nac.value 		= parent.document.form0.fecha_nac.value;
	document.form1.admision.value 		= parent.document.form0.admision.value;
	document.form1.tipo_cta.value 		= parent.document.form0.tipo_cta.value;

	document.form1.codigo.value 		= parent.document.form0.codigo.value;
	document.form1.anio.value 		= parent.document.form0.anio.value;

	if (!parent.form0Validation()){
		//return false;
	} else{
		//return true;
		if (document.form1.baction.value != 'Guardar')parent.form0BlockButtons(false);

		if (document.form1.baction.value == 'Guardar' && <%=fTranCarg.size()%> == 0)
		{
			top.CBMSG.warning('Por favor agregue por lo menos un cargo antes de guardar!');
			parent.form0BlockButtons(false);
		}
		else if(!chkOtros()){
			parent.form0BlockButtons(false);
			document.form1.baction.value = '';
		}
		else if(!chkDisponible() && document.form1.baction.value == 'Guardar'){
			parent.form0BlockButtons(false);
			document.form1.baction.value = '';
		}
		else if(!chkMontoCero() && document.form1.baction.value == 'Guardar'){
			parent.form0BlockButtons(false);
			document.form1.baction.value = '';
			top.CBMSG.warning('Introduzca montos mayores que 0!');
		}
		else if(calc())
		{
			document.form1.submit();
		}
	}

}


function calMonto(j, k){
	var cantidad					= parseInt(eval('document.form1.cantidad'+j).value,10);
	var cant_cargo				= parseInt(eval('document.form1.cant_cargo'+j).value,10);
	var cant_devolucion		= 0;
	var monto 						= eval('document.form1.monto'+j).value;
	var tipoTransaccion		= parent.document.form0.tipoTransaccion.value;
	var fg 								= '<%=fg%>';

	if(isNaN(cantidad) || isNaN(monto)){
		top.CBMSG.warning('Introduzca valores numéricos!');
		if(x=='c')eval('document.form1.cantidad'+j).value = 0;
		else if(x=='p')eval('document.form1.monto'+j).value = 0;
		return false;
	} else {
		if(tipoTransaccion=='D' && cantidad > (cant_cargo/*-cant_devolucion*/)){
			top.CBMSG.warning('La cantidad a devolver excede la cantidad del cargo...,VERIFIQUE!');
			eval('document.form1.cantidad'+j).value = cant_cargo;
			eval('document.form1.cantidad'+j).select();
			return false;
		} else {
			eval('document.form1.monto_total'+j).value = (cantidad * monto).toFixed(2);
			calc();
			return true;
		}
	}
}


function chkPac(){
	var tipo_cliente = parent.document.form0.tipo_cliente.value;
	var cod_empresa = parent.document.form0.cod_empresa.value;
	var size = document.form1.size.value;
	var x = 0;
	if(tipo_cliente=='2' && (cod_empresa == '86' || cod_empresa == '90149')){
		for(i=0;i<size;i++){
			if(eval().value==57){
				x++;
				break;
			}
		}
	}
	if(x==0) return true;
	else return false;
}

function chkOtros(){
	var tipo_cliente = parent.document.form0.tipo_cliente.value;
	var cia_contrato = parent.document.form0.cia_contrato.value;
	var size = document.form1.keySize.value;
	var cia = '<%=(String) session.getAttribute("_companyId")%>';

	var x = 0;
	<%if(fg.equals("yyy")){%>
	if(cia!=cia_contrato && (tipo_cliente==9 || tipo_cliente==12)){
		for(i=0;i<size;i++){
			if(eval('document.form1.tipo_detalle'+i).value=='O'){
				var cod = eval('document.form1.cod_otro'+i).value;
				var desc = eval('document.form1.descripcion'+i).value;
				var codigo=getDBData('<%=request.getContextPath()%>','codigo','tbl_fac_otros_cargos','codigo = ' + cod + ' and compania = ' + cia_contrato,'');
				if(codigo==''){
					top.CBMSG.warning('Problemas al registrar automaticamente el cargo al contrato en la compania ' + cia_contrato + ', esta compañia no tiene registrado el item: ' + desc + ' codigo: ' + cod + ' Informe a contabilidad para crear el item en la compañia en mension');
					x++;
					break;
				}
			}
		}
	}
	<%}%>
	if(x==0) return true;
	else return false;
}

function chkMontoCero(){
	var size = document.form1.keySize.value;
	var x = 0;
	for(i=0;i<size;i++){
		if(isNaN(eval('document.form1.monto'+i).value)){
			x++;
			break;
		} else {
			if(parseFloat(eval('document.form1.monto'+i).value)==0){
				x++;
				break;
			}
		}
	}
	if(x==0) return true;
	else return false;
}

function changeReadOnly(value){
	var size = document.form1.keySize.value;
	var x = 0;
	for(i=0;i<size;i++){
			eval('document.form1.desc'+i).readOnly = value;
	}
}

function calculaDescuento(){
	var size = document.form1.keySize.value;
	var valor = parent.document.form0.valor.value;
	var acum_desc = 0.00;
	var x = 0;
	for(i=0;i<size;i++){
		if(!isNaN(eval('document.form1.desc'+i).value) && eval('document.form1.desc'+i).value != ''){
			acum_desc += parseFloat(eval('document.form1.desc'+i).value);
		}
		if(acum_desc>parseFloat(valor)){
			top.CBMSG.warning('La suma de los descuentos del detalle han sobrepasado la cantidad del descuento del encabezado!');
			eval('document.form1.desc'+i).value = '';
			break
		}
	}
	calc();
	if(x==0) return true;
	else return false;
}

function chkDisponible(){
	var size = document.form1.keySize.value;
	for(i=0;i<size;i++){
		var tipoTransaccion		= parent.document.form0.tipoTransaccion.value;
		var art_flia 				= eval('document.form1.art_familia'+i).value;
		var art_clase 			= eval('document.form1.art_clase'+i).value;
		var cod_art 				= eval('document.form1.cod_articulo'+i).value;
		var desc 				= eval('document.form1.descripcion'+i).value;
		var almacen 				= eval('document.form1.inv_almacen'+i).value;
		var tipo_detalle				= eval('document.form1.tipo_detalle'+i).value;
		var cia = <%=(String) session.getAttribute("_companyId")%>;
		var cantidad					= parseInt(eval('document.form1.cantidad'+i).value,10);
		var x=0;
		if(tipoTransaccion=='C' && tipo_detalle=='I'){
			var disponible = getInvDisponible('<%=request.getContextPath()%>', cia, almacen, art_flia, art_clase, cod_art);
			if(!isNaN(parseFloat(disponible))){
				disponible = parseFloat(disponible);
				if(disponible<=0.00){
					top.CBMSG.warning('No hay cantidad disponible para el artículo '+art_flia+'-'+art_clase+'-'+cod_art+'-'+desc+'!');
					x=1;
					break;
				} else if(disponible<cantidad){
					top.CBMSG.warning('La cantidad introducida supera la cantidad disponible!');
					eval('document.form1.cantidad'+i).value = disponible;
					x=1;
					break;
				}
			}
		}
	}
	if(x==0) return true;
	else return false;
}

function chkNumDoc(){
	var tipo_cliente = parent.document.form0.tipo_cliente.value;
	var centro_servicio = parent.document.form0.centro_servicio.value;
	var baction = document.form1.baction.value;
	if((tipo_cliente=='5' && centro_servicio == '123' && no_cargo_apps == '') || baction != 'Guardar') return true;
	else return false;
}

function chkCantDevol(i){
	var flia = eval('document.form1.art_familia'+i).value;
	var clase = eval('document.form1.art_clase'+i).value;
	var articulo = eval('document.form1.cod_articulo'+i).value;
	var inv_almacen = eval('document.form1.inv_almacen'+i).value;
	var cod_otro = eval('document.form1.cod_otro'+i).value;
	var act_secuencia = eval('document.form1.act_secuencia'+i).value;
	var cantidad = parseInt(eval('document.form1.cantidad'+i).value);
	var cant_cargo = parseInt(eval('document.form1.cant_cargo'+i).value);
	var codigo = parent.document.form0.codigo.value;
	var anio = parent.document.form0.anio.value;
	var appendFilter = '';
	if(inv_almacen!='' && flia != '' && clase != '' && articulo != ''){
		appendFilter = ' and b.inv_almacen = ' + inv_almacen + ' and b.inv_art_familia = ' + flia + ' and b.inv_art_clase = ' + clase + ' and b.inv_cod_articulo = ' + articulo;
	} else if(cod_otro != ''){
		appendFilter = ' and b.cod_otro = ' + cod_otro;
	} else if(act_secuencia != ''){
		appendFilter = ' and b.act_secuencia = \''+act_secuencia+'\'';
	}

	var tabla = '(select b.tipo_detalle, b.tipo_servicio, b.cod_otro, b.inv_almacen, b.inv_art_familia, b.inv_art_clase, b.inv_cod_articulo, b.act_secuencia, b.monto, b.descripcion, b.desc_x_item, b.itbm_x_item, sum(cantidad) cantidad from tbl_fac_cargo_cliente a, tbl_fac_detc_cliente b where a.compania = b.compania and a.codigo = b.cargo and a.tipo_transaccion = b.tipo_transaccion and a.anio = b.anio and a.compania = <%=(String) session.getAttribute("_companyId")%> and a.anio_devol = '+anio+' and a.tipo_transaccion = \'D\' and a.codigo_devol = '+codigo+appendFilter+' group by b.tipo_detalle, b.tipo_servicio, b.cod_otro, b.inv_almacen, b.inv_art_familia, b.inv_art_clase, b.inv_cod_articulo, b.act_secuencia, b.monto, b.descripcion, b.desc_x_item, b.itbm_x_item)';

	var cant_devuelta = getDBData('<%=request.getContextPath()%>','nvl(cantidad, 0) cantidad',tabla,'','');
	if(cant_devuelta=='') return true;
	else{
		cant_devuelta = parseInt(cant_devuelta);
		if((cant_devuelta+cantidad) > cant_cargo){
			top.CBMSG.warning('La cantidad introducida supera a la que se puede devolver!');
			eval('document.form1.cantidad'+i).value = cant_cargo-cant_devuelta;
			calMonto(i,0);
			return false;
		} else return true;
	}
}

function selDosis(i){
	abrir_ventana1('../common/sel_dosis.jsp?fp=cargo_oc&index='+i);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("size",""+fTranCarg.size())%>

<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fp","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%//=fb.hidden("fPage",fPage)%>
<%=fb.hidden("provincia_emp","")%>
<%=fb.hidden("sigla_emp","")%>
<%=fb.hidden("tomo_emp","")%>
<%=fb.hidden("asiento_emp","")%>
<%=fb.hidden("cod_empresa","")%>
<%=fb.hidden("cod_medico","")%>
<%=fb.hidden("centro_servicio","")%>
<%=fb.hidden("contrato","")%>
<%=fb.hidden("particular","")%>

<%=fb.hidden("compania","")%>
<%=fb.hidden("compania_desc","")%>
<%=fb.hidden("tipo_cliente","")%>
<%=fb.hidden("tipo_cliente_desc","")%>
<%=fb.hidden("cliente","")%>
<%=fb.hidden("cliente2","")%>
<%=fb.hidden("tipoTransaccion","")%>
<%=fb.hidden("num_factura","")%>
<%=fb.hidden("no_cargo_appx","")%>
<%=fb.hidden("descuento","")%>
<%=fb.hidden("tipo_desc","")%>

<%=fb.hidden("cliente_alq","")%>
<%=fb.hidden("tipo_cli_alq","")%>
<%=fb.hidden("cia_contrato","")%>
<%=fb.hidden("cob_tasa_gasnet","")%>

<%=fb.hidden("gasnet_pac_id","")%>
<%=fb.hidden("fecha_nac","")%>
<%=fb.hidden("codigo_pac","")%>
<%=fb.hidden("admision","")%>
<%=fb.hidden("tipo_cta","")%>

<%=fb.hidden("codigo","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("devol",devol)%>

<%=fb.hidden("aprobacion_hna","")%>
<%=fb.hidden("fecha_vencim","")%>
<%=fb.hidden("fecha_nacimiento","")%>
<%=fb.hidden("codigo_paciente","")%>
<%=fb.hidden("medico_receta","")%>
<%=fb.hidden("limite","")%>
<%=fb.hidden("visita","")%>
<%=fb.hidden("diag_hna1","")%>
<%=fb.hidden("diag_hna2","")%>
<%=fb.hidden("diag_hna3","")%>
<%=fb.hidden("diag_hna4","")%>
<%
String colspan = "8";
if(fg.equals("yyy")) colspan = "10";
else if(fg.equals("www")) colspan = "11";
%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td colspan="<%=colspan%>" align="right">
	<%=fb.button("addCargos", "Agregar Cargos", false, (devol.equals("S")?true:viewMode), "", "", "onClick=\"javascript: _doSubmit(this.value);\"")%>
</tr>
<%
if(fg.equals("xxx")){
%>
<tr class="TextHeader" align="center">
	<td width="13%"><cellbytelabel>Tipo</cellbytelabel></td>
	<td width="7%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
	<td width="37%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Cant</cellbytelabel>.</td>
	<td width="10%"><cellbytelabel>Precio</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Desc</cellbytelabel>.</td>
	<td width="10%"><cellbytelabel>Total</cellbytelabel></td>
	<td width="3%">&nbsp;</td>
</tr>
<%} else if(fg.equals("yyy")){%>
<tr class="TextHeader" align="center">
	<td width="5%"><cellbytelabel>Tipo</cellbytelabel></td>
	<td width="5%"><cellbytelabel>Serv</cellbytelabel>.</td>
	<td width="5%"><cellbytelabel>Alm</cellbytelabel>.</td>
	<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
	<td width="32%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Cant</cellbytelabel>.</td>
	<td width="10%"><cellbytelabel>Precio</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Desc</cellbytelabel>.</td>
	<td width="10%"><cellbytelabel>Total</cellbytelabel></td>
	<td width="3%">&nbsp;</td>
</tr>
<%} else if(fg.equals("www")){%>
<tr class="TextHeader" align="center">
	<td width="5%"><cellbytelabel>Tipo</cellbytelabel></td>
	<td width="5%"><cellbytelabel>Serv</cellbytelabel>.</td>
	<td width="5%"><cellbytelabel>Alm</cellbytelabel>.</td>
	<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
	<td width="32%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="7%"><cellbytelabel>Cant</cellbytelabel>.</td>
	<td width="7%"><cellbytelabel>Precio Vta.</cellbytelabel></td>
	<td width="8%"><cellbytelabel>Desc</cellbytelabel>.</td>
	<td width="8%"><cellbytelabel>Total</cellbytelabel></td>
	<td width="12%"><cellbytelabel>Dosificaciones</cellbytelabel></td>
	<td width="1%">&nbsp;</td>
</tr>
<%}%>
<%
if (fTranCarg.size() > 0) al = CmnMgr.reverseRecords(fTranCarg);

for (int i=0; i<fTranCarg.size(); i++)
{
	key = al.get(i).toString();

	FactDetCargoCliente ad = (FactDetCargoCliente) fTranCarg.get(key);

	String color = "";

	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	String fecha = "fecha_cargo"+i;
	String setValidDate = "javascript:setValidDate("+i+");newHeight();";
	String fdtc = "";
	boolean readonly = true;
%>
	<%=fb.hidden("tipo_transaccion"+i,ad.getTipoTransaccion())%>
	<%=fb.hidden("cargo"+i,ad.getCargo())%>
	<%=fb.hidden("tipo_servicio"+i,ad.getTipoServicio())%>
	<%=fb.hidden("inv_almacen"+i,ad.getInvAlmacen())%>
	<%=fb.hidden("monto_recargo"+i,ad.getMontoRecargo())%>

	<%=fb.hidden("act_secuencia"+i,ad.getActSecuencia())%>
	<%=fb.hidden("art_familia"+i,ad.getInvArtFamilia())%>
	<%=fb.hidden("art_clase"+i,ad.getInvArtClase())%>
	<%=fb.hidden("cod_articulo"+i,ad.getInvCodArticulo())%>
	<%=fb.hidden("disponible"+i,ad.getDisponible())%>
	<%=fb.hidden("cero_value"+i,ad.getCeroValue())%>
	<%=fb.hidden("itbm"+i,ad.getItbm())%>
	<%=fb.hidden("itbm_x_item"+i,ad.getItbmXItem())%>
	<%=fb.hidden("cant_cargo"+i,ad.getCantCargo())%>
<!--_______________________________________________________________________________________________________________________________________-->
<!--_______________________________________________________________________________________________________________________________________-->

<%
if(fg.equals("xxx")){
%>
<tr class="<%=color%>" align="center">
	<%=fb.hidden("tipo_detalle"+i,ad.getTipoDetalle())%>
	<%=fb.hidden("cod_otro"+i,ad.getCodOtro())%>
	<%=fb.hidden("descripcion"+i,ad.getDescripcion())%>
	<td><%=ad.getTipoDetalle()%></td>
	<td><%=ad.getCodOtro()%></td>
	<td align="left"><%=ad.getDescripcion()%></td>
	<td><%=fb.intBox("cantidad"+i,ad.getCantidad(),false,false,viewMode,10, 5, null,null,"onChange=\"javascript:calMonto("+i+",'c')\"","Cantidad",false,"tabindex=\""+i+"1\"")%></td>
	<td><%=fb.decBox("monto"+i,CmnMgr.getFormattedDecimal(ad.getMonto()),false,false,false,10,10.2, null, null, "onChange=\"javascript:calMonto("+i+",'p')\"","Monto",false,"tabindex=\""+i+"2\"")%></td>
	<td><%=fb.decBox("desc"+i,ad.getDescuento(),false,false,true,10, 10.2)%></td>
	<td><%=fb.decBox("monto_total"+i,"",false,false,true,10, 10.2)%></td>
	<td align="center"><%=fb.submit("del"+i,"x",false,viewMode)%></td>
</tr>
<!--_______________________________________________________________________________________________________________________________________-->
<!--_______________________________________________________________________________________________________________________________________-->

<%} else if(fg.equals("yyy")){

	String vCodigo = ad.getInvArtFamilia()+"-"+ad.getInvArtClase()+"-"+ad.getInvCodArticulo();
	if(ad.getTipoServicio().equals("30")) vCodigo = ad.getCodOtro();

%>
	<%=fb.hidden("cod_otro"+i,ad.getCodOtro())%>

<tr class="<%=color%>" align="center">
	<%=fb.hidden("tipo_detalle"+i,ad.getTipoDetalle())%>
	<%=fb.hidden("v_codigo"+i,vCodigo)%>
	<%=fb.hidden("descripcion"+i,ad.getDescripcion())%>
	<%=fb.hidden("costo"+i,ad.getCosto())%>
	<%
	String onChange = "onChange=\"javascript:calMonto("+i+",'c');\"";
	if(devol.equals("S")) onChange = "onChange=\"javascript:calMonto("+i+",'c'); chkCantDevol("+i+");\"";
	%>
	<td><%=ad.getTipoDetalle()%></td>
	<td><%=ad.getTipoServicio()%></td>
	<td><%=ad.getInvAlmacen()%></td>
	<td><%=vCodigo%></td>
	<td align="left"><%=ad.getDescripcion()%></td>
	<td><%=fb.intBox("cantidad"+i,ad.getCantidad(),false,false,viewMode,10, 5, null,null,onChange,"Cantidad",false,"tabindex=\""+i+"1\"")%></td>
	<td><%=fb.decBox("monto"+i,ad.getMonto(),false,false,(ad.getCeroValue().equals("0")?false:true),10,10.2, null, null, "onChange=\"javascript:calMonto("+i+",'p')\"","Monto",false,"tabindex=\""+i+"2\"")%></td>
	<td><%=fb.decBox("desc"+i,ad.getDescuento(),false,false,true,10, 10.2, null, null, "onChange=\"javascript:calculaDescuento()\"","Descuento",false,"tabindex=\""+i+"3\"")%></td>
	<td><%=fb.decBox("monto_total"+i,"",false,false,true,10, 10.2)%></td>
	<td align="center">
	<%=fb.submit("del"+i,"x",false,viewMode, "", "", "onClick=\"javascript:document.form1.baction.value=this.value;\"")%>
	</td>
</tr>
<!--_______________________________________________________________________________________________________________________________________-->
<!--_______________________________________________________________________________________________________________________________________-->
<%} else if(fg.equals("www")){

	String vCodigo = ad.getInvArtFamilia()+"-"+ad.getInvArtClase()+"-"+ad.getInvCodArticulo();
	if(ad.getTipoDetalle().equals("Q")) vCodigo = ad.getCodUso();

%>
	<%=fb.hidden("cod_otro"+i,ad.getCodOtro())%>

<tr class="<%=color%>" align="center">
	<%=fb.hidden("tipo_detalle"+i,ad.getTipoDetalle())%>
	<%=fb.hidden("v_codigo"+i,vCodigo)%>
	<%=fb.hidden("descripcion"+i,ad.getDescripcion())%>
	<%=fb.hidden("cod_frecuencia"+i,ad.getCodFrecuencia())%>
	<%=fb.hidden("recargo"+i,ad.getRecargo())%>
	<%=fb.hidden("cod_uso"+i,ad.getCodUso())%>
	<%=fb.hidden("costo"+i,ad.getCosto())%>
	<%
	String onChange = "onChange=\"javascript:calMonto("+i+",'c');\"";
	if(devol.equals("S")) onChange = "onChange=\"javascript:calMonto("+i+",'c'); chkCantDevol("+i+");\"";
	%>
	<td><%=ad.getTipoDetalle()%></td>
	<td><%=ad.getTipoServicio()%></td>
	<td><%=ad.getInvAlmacen()%></td>
	<td><%=vCodigo%></td>
	<td align="left"><%=ad.getDescripcion()%></td>
	<td><%=fb.intBox("cantidad"+i,ad.getCantidad(),false,false,viewMode,8, 5, null,null,onChange,"Cantidad",false,"tabindex=\""+i+"1\"")%></td>
	<td><%=fb.decBox("monto"+i,ad.getMonto(),false,false,(ad.getCeroValue().equals("0")?false:true),8,10.2, null, null, "","Monto",false,"")%></td>
	<td><%=fb.decBox("desc"+i,ad.getDescuento(),false,false,true,8, 10.2, null, null, "","Descuento",false,"")%></td>
	<td><%=fb.decBox("monto_total"+i,"",false,false,true,8, 10.2)%></td>
	<td>
	<%=fb.textBox("frecuencia_desc"+i,ad.getFrecuenciaDesc(),false,false,true,10)%>
	<%=fb.button("btnDosis"+i,"...",true,viewMode,null,null,"onClick=\"javascript:selDosis("+i+");\"")%>
	</td>
	<td align="center">
	<%=fb.submit("del"+i,"x",false,viewMode, "", "", "onClick=\"javascript:document.form1.baction.value=this.value;\"")%>
	</td>
</tr>
<%}%>
	<%
}
%>
<tr class="TextRow02" align="center">
<%
if(fg.equals("xxx")){
%>
	<td align="right"><%=fb.checkbox("reg_tardio","N")%><cellbytelabel>Gasnet</cellbytelabel></td>
	<td colspan="5" align="right"><cellbytelabel>Sub-Total</cellbytelabel></td>
<%} else if(fg.equals("yyy")){%>
	<td colspan="8" align="right"><cellbytelabel>Sub-Total</cellbytelabel></td>
<%} else if(fg.equals("www")){%>
	<td colspan="8" align="right"><cellbytelabel>Sub-Total</cellbytelabel></td>
<%}
if(fg.equals("xxx")) colspan = "6";
else if(fg.equals("www")) colspan = "8";
else if(fg.equals("yyy")) colspan = "8";
%>
	<td><%=fb.decBox("sub_total","0",false,false,true,10,12.2)%></td>
	<td>&nbsp;</td>
	<%if(fg.equals("www")){%>
	<td>&nbsp;</td>
	<%}%>
</tr>
<tr class="TextRow02" align="center">
	<td colspan="<%=colspan%>" align="right"><cellbytelabel>Descuento</cellbytelabel></td>
	<td><%=fb.decBox("descuento_total",(viewMode)?OtroCargo.getDescuento():"0",false,false,true,10,12.2)%><%="*"+OtroCargo.getDescuento()%></td>
	<td>&nbsp;</td>
	<%if(fg.equals("www")){%>
	<td>&nbsp;</td>
	<%}%>
</tr>
<tr class="TextRow02" align="center">
	<td colspan="<%=colspan%>" align="right"><cellbytelabel>Impuesto</cellbytelabel></td>
	<td><%=fb.decBox("itbm",(viewMode)?OtroCargo.getItbm():"0",false,false,true,10,12.2)%><%="*"+OtroCargo.getItbm()%></td>
	<td>&nbsp;</td>
	<%if(fg.equals("www")){%>
	<td>&nbsp;</td>
	<%}%>
</tr>
<tr class="TextRow02" align="center">
	<td colspan="<%=colspan%>" align="right"><cellbytelabel>Total</cellbytelabel></td>
	<td><%=fb.decBox("total","0",false,false,true,10,12.2)%></td>
	<td>&nbsp;</td>
	<%if(fg.equals("www")){%>
	<td>&nbsp;</td>
	<%}%>
</tr>
<%=fb.hidden("keySize",""+fTranCarg.size())%>
</table>
<%fb.appendJsValidation("\n\tif (!chkPac())\n\t{\n\t\ttop.CBMSG.warning('Debe completar los datos del paciente!');\n\t\terror++;\n\t}\n");%>
<%fb.appendJsValidation("\n\tif (!chkNumDoc())\n\t{\n\t\ttop.CBMSG.warning('Debe colocar el número de documento!');\n\t\terror++;\n\t}\n");%>
<%fb.appendJsValidation("\n\tif (!chkMontoCero())\n\t{\n\t\ttop.CBMSG.warning('Introduzca montos mayores que 0!');\n\t\terror++;\n\t}\n");%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String dl = "";
	//Ajuste OtroCargo = new Ajuste();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	String anio = CmnMgr.getCurrentDate("yyyy");
	String mes = CmnMgr.getCurrentDate("mm");

	OtroCargo.setCompania(request.getParameter("compania"));
	OtroCargo.setTipoCliente(request.getParameter("tipo_cliente"));
	OtroCargo.setCliente(request.getParameter("cliente"));
	OtroCargo.setCliente2(request.getParameter("cliente2"));
	OtroCargo.setTipoTransaccion(request.getParameter("tipoTransaccion"));
	OtroCargo.setNoCargoAppx(request.getParameter("no_cargo_appx"));
	//OtroCargo.setDescuento(request.getParameter("descuento_total"));
	OtroCargo.setAnio(anio);
	OtroCargo.setClienteAlq(request.getParameter("cliente_alq"));
//	OtroCargo.set(request.getParameter(""));

	if(request.getParameter("provincia_emp") !=null && !request.getParameter("provincia_emp").equals("")) OtroCargo.setProvinciaEmp(request.getParameter("provincia_emp"));
	if(request.getParameter("sigla_emp") !=null && !request.getParameter("sigla_emp").equals("")) OtroCargo.setSiglaEmp(request.getParameter("sigla_emp"));
	if(request.getParameter("tomo_emp") !=null && !request.getParameter("tomo_emp").equals("")) OtroCargo.setTomoEmp(request.getParameter("tomo_emp"));
	if(request.getParameter("asiento_emp") !=null && !request.getParameter("asiento_emp").equals("")) OtroCargo.setAsientoEmp(request.getParameter("asiento_emp"));
	if(request.getParameter("cod_empresa") !=null && !request.getParameter("cod_empresa").equals("")) OtroCargo.setEmpresa(request.getParameter("cod_empresa"));
	if(request.getParameter("cod_medico") !=null && !request.getParameter("cod_medico").equals("")) OtroCargo.setMedico(request.getParameter("cod_medico"));
	if(request.getParameter("centro_servicio") !=null && !request.getParameter("centro_servicio").equals("")) OtroCargo.setCentroServicio(request.getParameter("centro_servicio"));
	if(request.getParameter("contrato") !=null && !request.getParameter("contrato").equals("")) OtroCargo.setAlquiler(request.getParameter("contrato"));
	if(request.getParameter("particular") !=null && !request.getParameter("particular").equals("")) OtroCargo.setParticular(request.getParameter("particular"));

	if(request.getParameter("tipo_cli_alq") !=null && !request.getParameter("tipo_cli_alq").equals("")) OtroCargo.setTipoCliAlq(request.getParameter("tipo_cli_alq"));
	if(request.getParameter("cia_contrato") !=null && !request.getParameter("cia_contrato").equals("")) OtroCargo.setCiaContrato(request.getParameter("cia_contrato"));

	if(request.getParameter("gasnet_pac_id") !=null && !request.getParameter("gasnet_pac_id").equals("")) OtroCargo.setGasnetPacId(request.getParameter("gasnet_pac_id"));
	if(request.getParameter("fecha_nac") !=null && !request.getParameter("fecha_nac").equals("")) OtroCargo.setFechaNac(request.getParameter("fecha_nac"));
	if(request.getParameter("codigo_pac") !=null && !request.getParameter("codigo_pac").equals("")) OtroCargo.setCodigoPac(request.getParameter("codigo_pac"));
	if(request.getParameter("admision") !=null && !request.getParameter("admision").equals("")) OtroCargo.setAdmision(request.getParameter("admision"));
	if(request.getParameter("reg_tardio") !=null) OtroCargo.setRegTardio(request.getParameter("reg_tardio"));

	if(request.getParameter("sub_total") !=null && !request.getParameter("sub_total").equals("")) OtroCargo.setSubtotal(request.getParameter("sub_total"));
	if(request.getParameter("descuento_total") !=null && !request.getParameter("descuento_total").equals("")) OtroCargo.setDescuento(request.getParameter("descuento_total"));
	if(request.getParameter("tipo_desc") !=null && !request.getParameter("tipo_desc").equals("")) OtroCargo.setTipoDescuento(request.getParameter("tipo_desc"));
	if(request.getParameter("itbm") !=null && !request.getParameter("itbm").equals("")) OtroCargo.setItbm(request.getParameter("itbm"));
	if(request.getParameter("total") !=null && !request.getParameter("total").equals("")) OtroCargo.setTotal(request.getParameter("total"));
	if(request.getParameter("tipo_cta") !=null && !request.getParameter("tipo_cta").equals("")) OtroCargo.setTipoCta(request.getParameter("tipo_cta"));

	if(request.getParameter("fecha_nacimiento") !=null && !request.getParameter("fecha_nacimiento").equals("")) OtroCargo.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
	if(request.getParameter("codigo_paciente") !=null && !request.getParameter("codigo_paciente").equals("")) OtroCargo.setCodigoPaciente(request.getParameter("codigo_paciente"));
	if(request.getParameter("diag_hna1") !=null && !request.getParameter("diag_hna1").equals("")) OtroCargo.setDiagHna(request.getParameter("diag_hna1"));
	if(request.getParameter("diag_hna2") !=null && !request.getParameter("diag_hna2").equals("")) OtroCargo.setDiagHna2(request.getParameter("diag_hna2"));
	if(request.getParameter("diag_hna3") !=null && !request.getParameter("diag_hna3").equals("")) OtroCargo.setDiagHna3(request.getParameter("diag_hna3"));
	if(request.getParameter("diag_hna4") !=null && !request.getParameter("diag_hna4").equals("")) OtroCargo.setDiagHna4(request.getParameter("diag_hna4"));
	if(request.getParameter("aprobacion_hna") !=null && !request.getParameter("aprobacion_hna").equals("")) OtroCargo.setAprobacionHna(request.getParameter("aprobacion_hna"));
	if(request.getParameter("fecha_vencim") !=null && !request.getParameter("fecha_vencim").equals("")) OtroCargo.setFechaVencim(request.getParameter("fecha_vencim"));
	if(request.getParameter("limite") !=null && !request.getParameter("limite").equals("")) OtroCargo.setLimite(request.getParameter("limite"));
	if(request.getParameter("visita") !=null && !request.getParameter("visita").equals("")) OtroCargo.setVisita(request.getParameter("visita"));
	if(request.getParameter("medico_receta") !=null && !request.getParameter("medico_receta").equals("")) OtroCargo.setMedicoReceta(request.getParameter("medico_receta"));


	if(OtroCargo.getTipoTransaccion().equals("D")){
		if(request.getParameter("anio") !=null && !request.getParameter("anio").equals("")) OtroCargo.setAnioDevol(request.getParameter("anio"));
		if(request.getParameter("codigo") !=null && !request.getParameter("codigo").equals("")) OtroCargo.setCodigoDevol(request.getParameter("codigo"));
		if(OtroCargo.getAnioDevol()!=null && OtroCargo.getCodigoDevol()!=null){
			OtroCargo.setMesAlq(mes);
			OtroCargo.setAnioAlq(anio);
		}
	} else {
		OtroCargo.setAnioDevol("null");
		OtroCargo.setCodigoDevol("null");
	}



	//if(request.getParameter("") !=null && !request.getParameter("").equals("")) OtroCargo.setAdmision(request.getParameter(""));

	int size = Integer.parseInt(request.getParameter("size"));
	OtroCargo.getFacDetCargoClientes().clear();
	fTranCarg.clear();
	int lineNo = 0, _lineNo = 0;
	String _key = "", okey = "";

	for (int i=0; i<keySize; i++){
		FactDetCargoCliente det = new FactDetCargoCliente();

		det.setTipoDetalle(request.getParameter("tipo_detalle"+i));
		det.setCodOtro(request.getParameter("cod_otro"+i));
		det.setDescripcion(request.getParameter("descripcion"+i));
		det.setCantidad(request.getParameter("cantidad"+i));
		det.setMonto(request.getParameter("monto"+i));
		
		if(fg.equals("www")){ 
			if(OtroCargo.getTipoCliente().equals("14")) det.setDescXItem(request.getParameter("desc"+i));
		} else det.setDescuento(request.getParameter("desc"+i));
		
		if((fg.equals("yyy") || fg.equals("www") || fg.equals("zzz")) && det.getTipoDetalle().equals("I") && OtroCargo.getTipoTransaccion().equals("C")) det.setRebajado("N");
		System.out.println("tipo_detalle...="+det.getTipoDetalle());

		if(request.getParameter("tipo_transaccion"+i)!=null && !request.getParameter("tipo_transaccion"+i).equals("null") && !request.getParameter("tipo_transaccion"+i).equals("")) det.setTipoTransaccion(request.getParameter("tipo_transaccion"+i));
		if(request.getParameter("cargo"+i)!=null && !request.getParameter("cargo"+i).equals("null") && !request.getParameter("cargo"+i).equals("")) det.setCargo(request.getParameter("cargo"+i));
		if(request.getParameter("tipo_servicio"+i)!=null && !request.getParameter("tipo_servicio"+i).equals("null") && !request.getParameter("tipo_servicio"+i).equals("")) det.setTipoServicio(request.getParameter("tipo_servicio"+i));
		if(request.getParameter("inv_almacen"+i)!=null && !request.getParameter("inv_almacen"+i).equals("null") && !request.getParameter("inv_almacen"+i).equals("") && request.getParameter("tipo_detalle"+i).equals("I")) det.setInvAlmacen(request.getParameter("inv_almacen"+i));
		if(request.getParameter("monto_recargo"+i)!=null && !request.getParameter("monto_recargo"+i).equals("null") && !request.getParameter("monto_recargo"+i).equals("")) det.setMontoRecargo(request.getParameter("monto_recargo"+i));
		//if(request.getParameter(""+i)!=null && !request.getParameter(""+i).equals("null") && !request.getParameter(""+i).equals("")) det.set(request.getParameter(""+i));
		if(request.getParameter("art_familia"+i)!=null && !request.getParameter("art_familia"+i).equals("null") && !request.getParameter("art_familia"+i).equals("")) det.setInvArtFamilia(request.getParameter("art_familia"+i));
		if(request.getParameter("art_clase"+i)!=null && !request.getParameter("art_clase"+i).equals("null") && !request.getParameter("art_clase"+i).equals("")) det.setInvArtClase(request.getParameter("art_clase"+i));
		if(request.getParameter("cod_articulo"+i)!=null && !request.getParameter("cod_articulo"+i).equals("null") && !request.getParameter("cod_articulo"+i).equals("")) det.setInvCodArticulo(request.getParameter("cod_articulo"+i));
		if(request.getParameter("disponible"+i)!=null && !request.getParameter("disponible"+i).equals("null") && !request.getParameter("disponible"+i).equals("")) det.setDisponible(request.getParameter("disponible"+i));
		if(request.getParameter("act_secuencia"+i)!=null && !request.getParameter("act_secuencia"+i).equals("null") && !request.getParameter("act_secuencia"+i).equals("")) det.setActSecuencia(request.getParameter("act_secuencia"+i));
		if(request.getParameter("cero_value"+i)!=null && !request.getParameter("cero_value"+i).equals("null") && !request.getParameter("cero_value"+i).equals("")) det.setCeroValue(request.getParameter("cero_value"+i));
		if(request.getParameter("itbm"+i)!=null && !request.getParameter("itbm"+i).equals("null") && !request.getParameter("itbm"+i).equals("")) det.setItbm(request.getParameter("itbm"+i));
		if(request.getParameter("itbm_x_item"+i)!=null && !request.getParameter("itbm_x_item"+i).equals("null") && !request.getParameter("itbm_x_item"+i).equals("")) det.setItbmXItem(request.getParameter("itbm_x_item"+i));
		if(request.getParameter("cant_cargo"+i)!=null && !request.getParameter("cant_cargo"+i).equals("null") && !request.getParameter("cant_cargo"+i).equals("")) det.setCantCargo(request.getParameter("cant_cargo"+i));

		if(request.getParameter("cod_frecuencia"+i)!=null && !request.getParameter("cod_frecuencia"+i).equals("null") && !request.getParameter("cod_frecuencia"+i).equals("")) det.setCodFrecuencia(request.getParameter(""+i));
		if(request.getParameter("recargo"+i)!=null && !request.getParameter("recargo"+i).equals("null") && !request.getParameter("recargo"+i).equals("")) det.setRecargo(request.getParameter("recargo"+i));
		if(request.getParameter("frecuencia_desc"+i)!=null && !request.getParameter("frecuencia_desc"+i).equals("null") && !request.getParameter("frecuencia_desc"+i).equals("")) det.setFrecuenciaDesc(request.getParameter("frecuencia_desc"+i));
		if(request.getParameter("cod_uso"+i)!=null && !request.getParameter("cod_uso"+i).equals("null") && !request.getParameter("cod_uso"+i).equals("")) det.setCodUso(request.getParameter("cod_uso"+i));
		if(request.getParameter("costo"+i)!=null && !request.getParameter("costo"+i).equals("null") && !request.getParameter("costo"+i).equals("")) det.setCosto(request.getParameter("costo"+i));
		if(request.getParameter("cod_uso"+i)!=null && !request.getParameter("cod_uso"+i).equals("null") && !request.getParameter("cod_uso"+i).equals("")) det.setCodUso(request.getParameter("cod_uso"+i));
		//if(request.getParameter(""+i)!=null && !request.getParameter(""+i).equals("null") && !request.getParameter(""+i).equals("")) det.set(request.getParameter(""+i));

		String fck = fg+"_"+det.getCodOtro()+"_"+det.getInvArtFamilia()+"_"+det.getInvArtClase()+"_"+det.getInvCodArticulo()+"_"+det.getActSecuencia();
		if(request.getParameter("del"+i)==null){
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				fTranCarg.put(key,det);
				fTranCargKey.put(fck, key);
				OtroCargo.getFacDetCargoClientes().add(det);
				System.out.println("Adding item... "+key +"_"+fck);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}

		} else {
			dl = fck;
			if (fTranCargKey.containsKey(dl)){
				System.out.println("- remove item "+dl);
				System.out.println("- item "+(String) fTranCargKey.get(dl));
				fTranCarg.remove((String) fTranCargKey.get(dl));
				fTranCargKey.remove(dl);
			}
			//OtroCargo.getFTransDetail().remove(i);
		}
	}
	System.out.println("dl......="+dl);
	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../facturacion/reg_cargo_dev_det_oc.jsp?mode="+mode+ "&change=1&type=2&fg="+fg+"&devol="+devol);
		return;
	}

	System.out.println("baction="+request.getParameter("baction"));

	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Agregar Cargos")){
		response.sendRedirect("../facturacion/reg_cargo_dev_det_oc.jsp?mode="+mode+"&id="+id+"&change=1&type=1&fg="+fg+"&devol="+devol);
		return;
	}

	System.out.println("request.getParameter(addCargos)="+request.getParameter("addCargos"));

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		OtroCargo.setCompania((String) session.getAttribute("_companyId"));
		OtroCargo.setUsuarioCrea((String) session.getAttribute("_userName"));
		OtroCargo.setUsuarioModifica((String) session.getAttribute("_userName"));
		//OtroCargo.setEmpreCodigo("");
		OtroCargo.setFg(fg);
		FTransMgr.add(OtroCargo);
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (FTransMgr.getErrCode().equals("1")){%>
			parent.document.form0.errCode.value = <%=FTransMgr.getErrCode()%>;
			parent.document.form0.errMsg.value = '<%=FTransMgr.getErrMsg()%>';
			parent.document.form0.submit();
	<%} else throw new Exception(FTransMgr.getErrMsg());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
