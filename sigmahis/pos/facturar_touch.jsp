<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.IFClient"%>
<%@ page import="issi.pos.Factura"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="htDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htDesc" scope="page" class="java.util.Hashtable" />
<jsp:useBean id="htPA" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDet" scope="session" class="java.util.Vector" />
<jsp:useBean id="vDesc" scope="page" class="java.util.Vector" />
<jsp:useBean id="vDescuento" scope="session" class="java.util.Vector" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iPago" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="FAC" scope="session" class="issi.pos.Factura"/>
<jsp:useBean id="CafMgr" scope="session" class="issi.pos.CafeteriaMgr"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

CafMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String fp=request.getParameter("fp");
String fg=request.getParameter("fg");
String mode=request.getParameter("mode");
String tipo=request.getParameter("tipo");
String msg = request.getParameter("msg");
String cds = request.getParameter("cds");
String almacen = request.getParameter("almacen");
String familia = request.getParameter("familia");
String tipo_pos = request.getParameter("tipo_pos");
String artType = request.getParameter("artType");
String tipoDocto = request.getParameter("tipoDocto");
String caja = request.getParameter("caja");
if(artType==null) artType = "A";
if (msg == null) msg = "";
if (fp == null) fp = "";
if (fg == null) fg = "";
if (mode == null) mode = "";
if (tipo == null) tipo = "";
if (artType == null) artType = "";
if (caja == null) caja = "";
if (tipoDocto == null) tipoDocto = "";
if (tipo_pos == null) tipo_pos = "";
String furl = request.getParameter("furl");
String ip = request.getRemoteAddr();
String cjaTipoRec = java.util.ResourceBundle.getBundle("issi").getString("cjaTipoRec");
String addDesc2NC = "N";
if (request.getMethod().equalsIgnoreCase("GET")){
	CommonDataObject cdoP = SQLMgr.getData("select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'POS_USE_KEYPAD'),'N') use_keypad, nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'POS_SHOW_SECOND_WINDOW'),'N') show_second_window from dual ");
	if (cdoP == null) {
		cdoP = new CommonDataObject();
		cdoP.addColValue("use_keypad","N");
	}
	boolean useKeypad = cdoP.getColValue("use_keypad").equalsIgnoreCase("S") || cdoP.getColValue("use_keypad").equalsIgnoreCase("Y");
	boolean show2win = cdoP.getColValue("show_second_window").equalsIgnoreCase("S") || cdoP.getColValue("show_second_window").equalsIgnoreCase("Y");

	FAC = new Factura();
	System.out.println("FAC.getAlDet().size()="+FAC.getAlDet().size());
	CommonDataObject cdoCaj = new CommonDataObject();
	if (furl == null) furl = "";
	htDet.clear();
	htDesc.clear();
	htPA.clear();
	vDet.clear();
	vDesc.clear();
	vDescuento.clear();
	iPago.clear();
	FAC.getAlFormaPago().clear();
	StringBuffer sbSql = new StringBuffer();
	sbSql.append("select cod_cajera, nombre, usuario, nvl(get_sec_comp_param(compania,'ADD_DESC_2_NC'),'N') as add_desc_2_nc, nvl(get_sec_comp_param(compania,'POS_CREDIT_STOP'),'N') as credit_stop, nvl(get_sec_comp_param(compania,'ID_TIPO_DESC_EMPL'),'0') as tipo_desc_empl, nvl(get_sec_comp_param(compania,'ID_TIPO_DESC_JUBIL'),'0') as tipo_desc_jubil, nvl(get_sec_comp_param(compania,'IDS_TIPO_CLTE_EMPL_POS'),'N') as tipo_clte_empl_pos, nvl(get_sec_comp_param(compania,'VALIDAR_EMPL_POS'),'N') as validar_empl_pos from tbl_cja_cajera where usuario = '");
	sbSql.append((String) session.getAttribute("_userName"));
	sbSql.append("' and estado = 'A' and compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	cdoCaj = SQLMgr.getData(sbSql.toString());
	if (cdoCaj == null) {

		sbSql = new StringBuffer();
		sbSql.append("select nvl(get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(",'ADD_DESC_2_NC'),'N') as add_desc_2_nc, nvl(get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(",'POS_CREDIT_STOP'),'N') as credit_stop, nvl(get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(",'ID_TIPO_DESC_EMPL'),'0') as tipo_desc_empl, nvl(get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(",'ID_TIPO_DESC_JUBIL'),'0') as tipo_desc_jubil, nvl(get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(",'IDS_TIPO_CLTE_EMPL_POS'),'N') as tipo_clte_empl_pos, nvl(get_sec_comp_param(");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(",'VALIDAR_EMPL_POS'),'N') as validar_empl_pos from dual");

		cdoCaj = SQLMgr.getData(sbSql.toString());
		if (cdoCaj == null) cdoCaj = new CommonDataObject(); //throw new Exception("Usuario, usted no esta registrado como cajero!. Por favor intente nuevamente!");
		cdoCaj.addColValue("cod_cajera","");

	}
	addDesc2NC = cdoCaj.getColValue("add_desc_2_nc");

	String codCaja = "";
	boolean allowTransaction=true;
	if(request.getParameter("codCaja")!=null && !request.getParameter("codCaja").equals("")) codCaja=request.getParameter("codCaja");
	else {
		if(session.getAttribute("_codCaja")== null){
			allowTransaction=false;
			//throw new Exception("Sr. Usuario: esta PC no tiene asignado un número de caja!");
		} else codCaja = (String) session.getAttribute("_codCaja");
	}
	if(cds== null) allowTransaction=false;//throw new Exception("Sr. Usuario: No ha sido definido el Centro de Servicio!");
	else {
		CommonDataObject cdCds = new CommonDataObject();
		sbSql = new StringBuffer();
		sbSql.append("select (case when exists (select null from tbl_cds_centro_servicio where compania_unorg = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and codigo = ");
		sbSql.append(cds);
		sbSql.append(") then 'S' else 'N' end) existe from dual");
		cdCds = SQLMgr.getData(sbSql.toString());
		if(cdCds.getColValue("existe").equals("N")) throw new Exception("Sr. Usuario: El centro de servicio no pertenece a la compañia en la que se encuentra!");
	}
	if(almacen== null) throw new Exception("Sr. Usuario: No ha sido definido el almacen!");

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/autocomplete_header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/bootstrap.css" type="text/css"/>
<script src="<%=request.getContextPath()%>/css/bootstrap/js/bootstrap.min.js"></script>
<script language="javascript">
document.title="CellByte POS Touch";
function doAction(){
//alert(jQuery.browser+' '+jQuery.browser.version);
//$('#container').css({'height':(_contentHeight-titleHeight()-footerHeight()-50)+'px'});
//$('#contentPage').css({'height':((_contentHeight-titleHeight()-footerHeight()-50)*.32)+'px'});
//$('#left').css({'height':((_contentHeight-titleHeight()-footerHeight()-50)*.93)+'px'});
//$('#right').css({'height':((_contentHeight-titleHeight()-footerHeight()-50)*.93)+'px'});
//$('#footer').css({'height':((_contentHeight-titleHeight()-footerHeight()-50)*.20)+'px'});
setCajaDetail();
setTipoClte();

}
function chkCaja(){
	var caja=document.form0.caja.value;
	if(caja!='') caja = parseInt(caja);
	if(document.form0.caja.length>1) window.location = '<%=request.getContextPath()%>/pos/facturar_touch.jsp?almacen=<%=almacen%>&cds=<%=cds%>&familia=<%=familia%>&tipo_pos=<%=tipo_pos%>&tipoDocto=<%=tipoDocto%>&tipo=<%=tipo%>&artType=<%=artType%>&caja=<%=caja%>&codCaja='+caja;
}
function setCajaDetail(){var caja=document.form0.caja.value;if(caja==undefined||caja==null||caja.trim()==''){CBMSG.warning('Usted no tiene Caja seleccionada!');if(document.form0.save)document.form0.save.disabled=true;return false;}else setTurno(caja);}
function setTurno(caja){
	var turno=null;
	if(caja!=undefined&&caja!=null&&caja.trim()!='')turno=getDBData('<%=request.getContextPath()%>','a.cod_turno','tbl_cja_turnos_x_cajas a, tbl_cja_cajas b','a.compania = b.compania and a.cod_caja = b.codigo and a.compania = <%=(String) session.getAttribute("_companyId")%> and a.cod_caja = '+caja+' and a.estatus = \'A\'<%=(UserDet.getUserProfile().contains("0"))?"":" and b.ip = \\\'"+request.getRemoteAddr()+"\\\'"%>');

	if(turno==undefined||turno==null||turno.trim()==''){
		document.form0.turno.value='';
		alert('Usted o la Caja seleccionada no tiene un turno definido!');
		if(document.form0.save)document.form0.save.disabled=true;
		//window.frames['detalle'].formDetalleBlockButtons(true);
		return false;
	}else{
		document.form0.turno.value=turno;
		//form0BlockButtons(false);
		//window.frames['detalle'].formDetalleBlockButtons(false);
	}
	return true;
}

function chkNoRecibo(){var obj = document.form0.no_recibo;if(obj.value!=''){if(hasDBData('<%=request.getContextPath()%>','tbl_cja_transaccion_pago','recibo = \''+obj.value+'\' and compania = <%=(String) session.getAttribute("_companyId")%>')){alert('El Número de Recibo ya existe!');obj.value='';return false;}}return true;}
function chkCltQty(){
	var refer_to = document.form0.refer_to.value;
	var tipoFact = getRadioButtonValue(document.form0.tipo_factura);
	if(refer_to=='EMPL' || refer_to == 'MED' || refer_to == 'EMPO' /*&& tipoFact=='CR'*/){
		var client_id = document.form0.client_id.value;
		var ref_id = document.form0.ref_id.value;
		var qty=getDBData('<%=request.getContextPath()%>','count(*)','tbl_fac_trx','client_id = \''+client_id+'\' and client_ref_id = '+ref_id+' and trunc(doc_date) = trunc(sysdate)');
		if(qty>0) document.form0.client_name.className='FormDataObjectAlert';
		else document.form0.client_name.className='FormDataObjectRequired';
	} else document.form0.client_name.className='FormDataObjectRequired';
}
function closeSession(){abrir_ventana('logout.jsp?exit=yes');}
function borrar(i){
	if(document.form0.tipo_cajero.value =='C'){
	showPopWin('../pos/permiso_supervisor.jsp?fp=POS&fg=DEL&cod_caja='+document.form0.caja.value+'&compania_caja=<%=(String) session.getAttribute("_companyId")%>&index='+i+'&useKeypad=<%=useKeypad?"Y":""%>&touch=Y',winWidth*.55,_contentHeight*.80,null,null,'');
	} else borra(i);
}
function borra(i){
	var url = eval('document.form0.spn'+i).value+'&del=1&touch=Y&use_keypad=<%=useKeypad?"Y":"N"%>'+'&show_desc=S';
	var txt=ajaxHandler('../pos/detail.jsp',url,'GET');
	$('#left',document).html(txt);
	calcTotal();
}
function borrarAll(){
	var txt = ajaxHandler('../pos/detail.jsp','del=all&touch=Y&use_keypad=<%=useKeypad?"Y":"N"%>'+'&show_desc=S','GET');
	$('#left',document).html(txt);
	calcTotal();
}
function adddisc(i, flg){
	var txt = ajaxHandler('../pos/detail.jsp',eval('document.form0.spn'+i).value+'&adding='+flg+'&touch=Y&use_keypad=<%=useKeypad?"Y":"N"%>'+'&show_desc=S','GET');
	$('#left',document).html(txt);
}

function descontar(i){
	if(document.form0._clt_aplica_descuento.value=='N' || document.form0.facturar_al_costo.value=='S') alert('Al cliente no se le puede aplicar descuento!');
	else {
		if(document.form0.tipo_cajero.value =='C'){
			showPopWin('../pos/permiso_supervisor.jsp?fp=POS&fg=DES&cod_caja='+document.form0.caja.value+'&compania_caja=<%=(String) session.getAttribute("_companyId")%>&index='+i+'&useKeypad=<%=useKeypad?"Y":""%>&touch=Y',winWidth*.55,_contentHeight*.80,null,null,'');
		} else descuenta(i);
	}
}
function descuenta(i){
	showPopWin('../pos/descuento_touch.jsp?fp=cafeteria&'+eval('document.form0.spn'+i).value+'&cantidad='+eval('document.form0.cantidad'+i).value+'&touch=Y&use_keypad=<%=useKeypad?"Y":"N"%>&val_desc='+eval('document.form0.val_desc'+i).value,winWidth*.55,winHeight*.70,null,null,'');
}
function calcTotal(){
	var size = 0;
	if(document.form0.detSize) size=document.form0.detSize.value;
	var sizePA = 0;
	if(document.form0.detSizePA) sizePA = document.form0.detSizePA.value;
	var sizeDesc = 0;
	if(document.form0.descSize) sizeDesc = document.form0.descSize.value;
	var total = 0.00, total_desc = 0.00, total_no_exe = 0.00, total_desc_no_exe = 0.00, total_itbm = 0.00, _total_itbm = 0.00, porAplicar = 0.00;
	var precio_aplicado = 0.00;
	var calcItbm = true;
	for(i=0;i<size;i++){
		precio_aplicado = 0.00;
		var cantidad = parseFloat(eval('document.form0.cantidad'+i).value);
		for(j=0;j<sizePA;j++){
			if(eval('document.form0.codigo'+i).value.replace('I@','').replace('C@','').replace('N@','')==eval('document.form0.codigo_pa'+j).value.replace('I@','').replace('C@','').replace('N@','')){
				precio_aplicado = parseFloat(eval('document.form0.precio_pa'+j).value);
				cantidad += -1;
				break;
			}
		}
		calcItbm = true;
		if(eval('document.form0.itbm'+i).value=='S'){
			if(eval('document.form0.tipo_art'+i).value=='N'){
				//if(sizeDesc>0){
					for(x=0;x<sizeDesc;x++){
						if(eval('document.form0.codigo'+i).value.replace('I@','').replace('C@','').replace('N@','')==eval('document.form0.codigo_d'+x).value.replace('I@','').replace('C@','').replace('N@','')){
							calcItbm = false;
							if(parseFloat(eval('document.form0.gravable_perc'+i).value)==0.00) {
															//alert('El artículo '+eval('document.form0.descripcion'+i).value+' tiene itbm = 0!');
														}
							else total_itbm += ((cantidad*parseFloat(eval('document.form0.precio'+i).value))+(parseFloat(eval('document.form0.cantidad_d'+x).value)*parseFloat(eval('document.form0.precio_d'+x).value)))*parseFloat(eval('document.form0.gravable_perc'+i).value);
							break;
						}
					}
				//} else
				if(calcItbm) total_itbm += ((cantidad*parseFloat(eval('document.form0.precio'+i).value)))*parseFloat(eval('document.form0.gravable_perc'+i).value);
			} //else total_itbm += parseFloat(eval('document.form0.total_itbm'+i).value);
			if(eval('document.form0.tipo_art'+i).value!='D') total_no_exe += cantidad*parseFloat(eval('document.form0.precio'+i).value)+precio_aplicado;
			if(eval('document.form0.tipo_art'+i).value=='D') total_desc_no_exe += parseFloat(eval('document.form0.total_desc'+i).value);
		} else {
			if(eval('document.form0.tipo_art'+i).value!='D') total += cantidad*parseFloat(eval('document.form0.precio'+i).value)+precio_aplicado;
			if(eval('document.form0.tipo_art'+i).value=='D') total_desc += parseFloat(eval('document.form0.total_desc'+i).value);
		}
	}
	var tmp=Math.round(total*100);
	total=tmp/100;
	tmp=Math.round(total_no_exe*100);
	total_no_exe=tmp/100;
	tmp=Math.round(total_itbm*100);
	total_itbm=tmp/100;
	tmp=Math.round(total_desc*100);
	total_desc=tmp/100;
	tmp=Math.round(total_desc_no_exe*100);
	total_desc_no_exe=tmp/100;
	var subtotal_exe = total;
	var subtotal_no_exe = total_no_exe;
	total = total + total_no_exe + total_itbm - total_desc - total_desc_no_exe;

	/*-------------------------------------------------------------*/
	var tipoFact = getRadioButtonValue(document.form0.tipo_factura);
	if(tipoFact=='CR'){
		var _total = total;
		document.form0.pagoTotal.value=_total.toFixed(2);
		//window.frames['formaPago'].document.formFP.monto.value=_total.toFixed(2);
	}
	/*-------------------------------------------------------------*/

	porAplicar = parseFloat(document.form0.pagoTotal.value)-total;
	tmp=Math.round(porAplicar*100);
	porAplicar=tmp/100;
	document.form0.subtotal_exe.value = subtotal_exe.toFixed(2);
	document.form0.subtotal_no_exe.value = subtotal_no_exe.toFixed(2);
	document.form0.descuento_exe.value = total_desc.toFixed(2);
	document.form0.descuento_no_exe.value = total_desc_no_exe.toFixed(2);
	document.form0.itbm.value = total_itbm.toFixed(2);
	document.form0.total.value = total.toFixed(2);
	document.form0.aplicadoDisplay.value = total.toFixed(2);
	document.form0.porAplicar.value = porAplicar.toFixed(2);
	if(size==0) document.form0.precio_aplicado.value='N';
}
function calcRegTotal(i){
	var flg = 'reem';
	var reference_id = document.form0.reference_id.value;
	var disp = 0, qty = parseInt(eval('document.form0.cantidad'+i).value) || 0;
	var almacen = eval('document.form0.codigo_almacen'+i).value;
	var codigo = eval('document.form0.codigo'+i).value;
	codigo = codigo.replace('I@','').replace('C@','').replace('N@','');
	var tipo_articulo = eval('document.form0.tipo_articulo'+i).value;
	var afecta_inventario = eval('document.form0.afecta_inventario'+i).value;
	var check_disp = 'N';
	if(tipo_articulo=='I'){
		var x = splitCols(getDBData('<%=request.getContextPath()%>', 'disponible, get_sec_comp_param(<%=(String) session.getAttribute("_companyId")%>, \'CHECK_DISP\')', 'tbl_inv_inventario','codigo_almacen = '+almacen+' and cod_articulo = '+codigo));
		disp = x[0];
		check_disp = x[1];
	}

	var _artType = getRadioButtonValue(window.frames['artFrame'].document.search01.artType);

	if(tipo_articulo!='I' || check_disp == 'N' || (tipo_articulo=='I' && disp >= qty) || (tipo_articulo=='I' && afecta_inventario=='N') || (tipo_articulo=='I' && disp <= qty && document.form0.tipo_docto.value=='NCR')){
		var qty_items = 0;
		if(reference_id!='')qty_items=parseInt(getDBData('<%=request.getContextPath()%>','getQtyItems('+reference_id+', <%=(String) session.getAttribute("_companyId")%>, '+codigo+')','dual',''));

		//if('<%=addDesc2NC%>'=='S' && document.form0.tipo_docto.value=='NCR' && (qty > parseInt(eval('document.form0._cantidad'+i).value) || parseInt(eval('document.form0._cantidad'+i).value)>qty_items) && _artType=='F'){


			var _qty = 0;
			_qty = (eval('document.form0.xx_'+size+'_'+codigo)?(parseInt(eval('document.form0.xx_'+size+'_'+codigo).value)+1):qty);

		if('<%=addDesc2NC%>'=='S' && document.form0.tipo_docto.value=='NCR' && (parseInt(eval('document.form0._cantidad'+i).value) + qty_items - _qty < 0) && _artType=='F'){
			alert('La cantidad no puede ser mayor a la registrada en la Factura!');
			eval('document.form0.cantidad'+i).value=0;//eval('document.form0._cantidad'+i).value;
		} else {
				if (qty){
		var txt = ajaxHandler('../pos/detail.jsp',eval('document.form0.spn'+i).value+'&adding='+flg+'&cantidad='+eval('document.form0.cantidad'+i).value+'&touch=Y&use_keypad=<%=useKeypad?"Y":"N"%>'+'&show_desc=S','GET');
		$('#left',document).html(txt);
		calcTotal();
				}
		//eval('document.form0._cantidad'+i).value=qty;
		//eval('document.form0.___'+codigo).value=qty;
		}
	} else {
		alert('La cantidad supera la disponibilidad del artículo!');
		eval('document.form0.cantidad'+i).value=eval('document.form0._cantidad'+i).value;
	}
	var size = 0;
	if(document.form0.detSize) size=document.form0.detSize.value;
	for(x=1;x<size;x++){
		var code = (eval('document.form0.codigo'+x).value).replace('@D@', '');;
		if(x!=i && code==codigo) {borra(x);break;}
	}
}
function checkQuantity(){flag=true;size=0;if(document.form0.detSize)size=document.form0.detSize.value;for(i=0;i<size;i++){qty=parseInt(eval('document.form0.cantidad'+i).value);if(qty==0){flag=false;alert('Cantidad de Venta no puede ser 0');break;}}return flag;}
function changeDesc(i){
	showPopWin('../pos/edit_descripcion.jsp?fp=cafeteria&'+eval('document.form0.spn'+i).value+'&cantidad='+eval('document.form0.cantidad'+i).value+'&touch=Y&useKeypad=<%=useKeypad?"Y":""%>',winWidth*.50,winHeight*.60,null,null,'');
	var flg = 'reem';
	var txt = ajaxHandler('../pos/detail.jsp',eval('document.form0.spn'+i).value+'&adding='+flg+'&cantidad='+eval('document.form0.cantidad'+i).value+'&touch=Y&use_keypad=<%=useKeypad?"Y":"N"%>'+'&show_desc=S','GET');
	$('#left',document).html(txt);
	calcTotal();
}
var stopCredit='<%=cdoCaj.getColValue("credit_stop").toUpperCase()%>';
function checkCredit()
{
var tipoFact = getRadioButtonValue(document.form0.tipo_factura);
var es_clt_cxco = document.form0.es_clt_cxco.value;
var clt_forma_pago = document.form0.clt_forma_pago.value;
//alert(stopCredit);
if (stopCredit=='Y' ||  stopCredit=='S'){
if(document.form0.tipo_docto.value=='FAC'){
if(tipoFact=='CR' && clt_forma_pago=='CR'){
if(parseFloat(document.form0.saldo.value)<0) {alert('Saldo de Cliente es menor!');if (document.form0.save) document.form0.save.disabled=true; return false;}
else if((parseFloat(document.form0.saldo.value)-parseFloat(document.form0.total.value))<0) {
 alert('Cliente supera el límite de Crédito!');
 if (document.form0.save) document.form0.save.disabled=true;
 return false;
 }
else {
	if (document.form0.save) document.form0.save.disabled=false;
	return true;}
}}
}else { if(document.form0.save) document.form0.save.disabled=false;
return true;}
}
function doSubmit(valor){
	if(document.form0.save) document.form0.save.disabled=true;
	else return false;
	document.form0.baction.value=valor;
	var err = 0;
	var tipoFact = getRadioButtonValue(document.form0.tipo_factura);
	var es_clt_cxco = document.form0.es_clt_cxco.value;
	var clt_forma_pago = document.form0.clt_forma_pago.value;
	if(valor=='Guardar'){
	<%if(cjaTipoRec.equals("M")){%>
	if(document.form0.no_recibo.value=='' && document.form0.tipo_docto.value=='FAC'){
		alert('Debe Ingresar No. Recibo!');
		document.form0.no_recibo.focus();
		err++;
	}
	<%}%>
	if(document.form0.ref_id.value==''){
		alert('Debe seleccionar tipo de cliente!');
		err++;
	}else	if(document.form0.client_id.value==''){
		alert('Debe seleccionar cliente!');
		err++;
	} else if(document.form0.fecha_factura.value==''){
		alert('Debe seleccionar Fecha!');
		err++;
	} else if(!checkQuantity()){
	if (document.form0.save) document.form0.save.disabled=false;
	return false;
	}/*else if(window.frames['formaPago'].document.formFP.iPagoSize.value==0){
		if(getRadioButtonValue(document.form0.tipo_factura)=='CR'){
			window.frames['formaPago'].document.formFP.baction.value='+';
			window.frames['formaPago'].document.formFP.submit();
		} else {
		alert('Debe Ingresar Forma de Pago!');
		err++;
		}
	}*/
	else if(document.form0.detSize&&document.form0.detSize.value==0){
		alert('Debe Seleccionar al menos un artículo!');
		err++;
	} else if(parseFloat(document.form0.pagoTotal.value)<parseFloat(document.form0.total.value)){
		//if(document.form0.tipo_docto.value=='FAC'){
		alert('El total a pagar es mayor a lo ingresado!');
		err++;
		//}// else document.form0.total.value = document.form0.pagoTotal.value;
	}
	 if((parseFloat(document.form0.saldo.value)-parseFloat(document.form0.total.value))<0 && tipoFact=='CR' && es_clt_cxco=='S' && clt_forma_pago=='CR'){
<% if (cdoCaj.getColValue("credit_stop").equalsIgnoreCase("Y") || cdoCaj.getColValue("credit_stop").equalsIgnoreCase("S")) { %>
		//err++;
		//alert('Cliente supera el límite de Crédito!');
<% } else { %>
		if(confirm('Cliente supera el límite de Crédito! Desea Continuar?')) {}
		else err++;
<% } %>
	} else if(document.form0.client_id.value=='0' && tipoFact=='CR'){
		alert('No puede vender a credito a un cliente contado!');
		err++;
	} else if((document.form0.reference_id.value=='' || document.form0.reference_id.value=='null' || document.form0.reference_id==null) && document.form0.tipo_docto.value=='NCR'){
		CBMSG.warning('Nota de Crédito sin referencia de Factura!');
		err++;
	}
	}


	if(err==0) document.form0.submit();
	else if (document.form0.save) document.form0.save.disabled=false;
}

function regFormaPago(path){
	showPopWin(path,winWidth*.85,_contentHeight*.65,null,null,'');
}


/*===============================================================================*/
/*       D       E       S       C       U       E       N       T       O       */
/*===============================================================================*/

function chkDesc(tipo_desc){
		if(document.form0._clt_aplica_descuento.value=='N' || document.form0.facturar_al_costo.value=='S'){
		alert('Al cliente no se le puede aplicar descuento!');
	} else {
		if(document.form0.tipo_cajero.value =='C'){
			showPopWin('../pos/permiso_supervisor.jsp?fp=POS&fg=DESG&cod_caja='+document.form0.caja.value+'&compania_caja=<%=(String) session.getAttribute("_companyId")%>&index='+i+'&useKeypad=<%=useKeypad?"Y":""%>&touch=Y&tipo_desc='+tipo_desc,winWidth*.55,_contentHeight*.80,null,null,'');
		} else setDescAuto(tipo_desc);
	}
}
function setDescAuto(tipo_desc){
	var size = 0;
	var tcep = splitCols('<%=cdoCaj.getColValue("tipo_clte_empl_pos")%>');
	var empleado = false;
	var validar_empleado = '<%=cdoCaj.getColValue("VALIDAR_EMPL_POS")%>';
	var subTipoCliente = document.form0.subTipoCliente.value;
	for(i=0;i<tcep.length;i++){
		if(subTipoCliente==tcep[i]) {empleado = true; break;}
	}
	if(validar_empleado=='N') empleado = true;
	if(document.form0.detSize) size=parseInt(document.form0.detSize.value)*2;
console.log('**************> empleado='+empleado+' size='+size+' tipo_desc='+tipo_desc);
	if(tipo_desc=='J' || (empleado && tipo_desc == 'E')){
		for(x=0;x<size;x++){
			addDescAuto(tipo_desc, x)
		}
	} else if(!empleado && tipo_desc == 'E') alert('El cliente no es Empleado!');
}
function addDescAuto(tipo_desc, x){
	var codigo = '';
	if(eval('document.form0.codigo'+x)) codigo = eval('document.form0.codigo'+x).value;//+'@D@';
console.log('**************> item'+x+'='+codigo+' tipo_desc='+tipo_desc);
	//alert('codigo='+codigo+',  index='+codigo.indexOf('@D@'));
	if(codigo!='' && codigo.indexOf('@D@')==-1){
		var xDesc = splitCols(eval('document.form0.val_desc'+x).value);
		if((tipo_desc=='E' && xDesc[0]!=0) || (tipo_desc=='J' && xDesc[1]!=0)){
			codigo = eval('document.form0.codigo'+x).value+'@D@';
			var precio = parseFloat(eval('document.form0.precio'+x).value);
			var id_descuento = '';
			//alert('0='+xDesc[0]+', 1='+xDesc[1]+', precio='+precio);
			//alert('x='+x+', '+eval('document.form0.val_desc'+x).value+', desc='+$.URLEncode(eval('document.form0.descripcion'+x).value));
			if(tipo_desc=='E' && xDesc[0]!=0) {
				precio = precio*(parseFloat(xDesc[0])/100);
				id_descuento = document.form0.tipo_desc_empl.value;
			} else if(tipo_desc=='J' && xDesc[1]!=0){
				precio = precio*(parseFloat(xDesc[1])/100);
				id_descuento = document.form0.tipo_desc_jubil.value;
			}
			if(precio>parseFloat(eval('document.form0.precio'+x).value)) alert('El precio con descuento es mayor al precio original!');
			else if(precio<0) alert('El descuento no puede ser menor a 0');
			else {
				var descripcion = $.URLEncode(eval('document.form0.descripcion'+x).value);
				var cantidad = eval('document.form0.cantidad'+x).value;
				var itbm = eval('document.form0.itbm'+x).value;
				var codigo_almacen = eval('document.form0.codigo_almacen'+x).value;

				var tipo_articulo = eval('document.form0.tipo_articulo'+x).value;
				var afecta_inventario = eval('document.form0.afecta_inventario'+x).value;
				var tipo_servicio = eval('document.form0.tipo_servicio'+x).value;
				var cod_barra = eval('document.form0.cod_barra'+x).value;
				var costo = 0;//document.form0.costo.value;
				var tipo_descuento = 'P';
				var total_desc2 = precio*cantidad;//getDBData('<%=request.getContextPath()%>', 'round('+precio+' * '+cantidad+', 2)', 'dual','');
				var total_desc = total_desc2.toFixed(2);//getDBData('<%=request.getContextPath()%>', 'round('+precio+' * '+cantidad+', 2)', 'dual','');
				var spn = 'codigo='+codigo+'&descripcion='+descripcion+'&cantidad='+cantidad+'&precio=-'+precio+'&itbm='+itbm+'&tipo_art=D&codigo_almacen='+codigo_almacen+'&id_descuento='+id_descuento+'&tipo_descuento='+tipo_descuento+'&total_desc='+total_desc+'&tipo_articulo='+tipo_articulo+'&afecta_inventario='+afecta_inventario+'&costo='+costo+'&tipo_servicio='+tipo_servicio+'&cod_barra='+cod_barra+'&total='+total_desc;
console.log('**************> aplicar descuento en item'+x+'='+descripcion+' spn='+spn);
				var flg = 'add';
				//alert(spn);
				var txt = ajaxHandler('../pos/detail.jsp',spn+'&adding='+flg+'&show_desc=S&tipo_desc='+tipo_desc,'GET');
				//alert(txt);
				$('#left',document).html(txt);
				calcTotal();
				}
			}
		}
}
/*===============================================================================*/
/*===============================================================================*/
$.extend ({
URLEncode: function (s) {
s = encodeURIComponent (s);
s = s.replace (/\~/g, '%7E').replace (/\!/g, '%21').replace (/\(/g, '%28').replace (/\)/g, '%29').replace (/\'/g, '%27');
s = s.replace (/%20/g, '+');
return s;
},
URLDecode: function (s) {
s = s.replace (/\+/g, '%20');
s = decodeURIComponent (s);
return s;
}
});
</script>
<%if(useKeypad){%>
<link href="../js/jquery.keypad.css" rel="stylesheet">
<style>#inlineKeypad { width: 10em; }</style>
<script src="../js/jquery.plugin.js"></script>
<script src="../js/jquery.keypad.js"></script>
<%}%>
<script>
function openSecondWindow() {
var width = 1024;
var height = 768;
var left = screen.availWidth + 1;//1625
//left += window.screenX;
//alert('screen.availWidth='+screen.availWidth+' screenX='+window.screenX);
window.open("../pos/fact_touch_monitor_display.jsp",'wndTouchMonitor','resizable=1,scrollbars=1,fullscreen=0,height='+height+',width='+width+',left='+left+',toolbar=0,menubar=0,status=1');
//return 0;
}
$(document).ready(function(){
var posHeaderHeight=objHeight('_tblPosHeader');
$('#left').css({'top':posHeaderHeight+'px'});
$('#right').css({'top':posHeaderHeight+'px'});
<%if(useKeypad){%>
	var opts ={
				keypadOnly: false,
				layout: [
				'1234567890-',
				'qwertyuiop' + $.keypad.CLOSE,
				'asdfghjkl' + $.keypad.CLEAR,
				'zxcvbnm' +
				$.keypad.SPACE_BAR + $.keypad.BACK]
	 };
	$('#client_name, #comentario').keypad(opts);

	$(document).on("focus", ".qty-use-keypad", function(e){
		var self = $(this);
		var i = self.data('i');
		self.keypad({
		 keypadOnly: false,
		 onClose: function(){
			 calcRegTotal(i);
		 }
		});
	});

	$(document).on('keyup',function(evt) {
				if (evt.keyCode == 27) {
					 $('#client_name, #comentario, .qty-use-keypad').keypad("hide");
				}
	 });
<%}%>
<% if (show2win) { %>openSecondWindow();<% } else { %>$('#btn2win').hide();<% } %>
});
</script>

<style type="text/css">
#container{position:fixed;/*height:100%;*/width:100%;}
#menu{border: .5px solid black;}
#left{
	position:fixed;
	left: 0.5%;
	top: 20%;
	border: .5px solid black;
	float:right;
	width: 38%;
	height: 61%;
	overflow-y:scroll;
}
#right{
	position:fixed;
	top: 20%;
	float:left;
	width: 60%;
	right: 10px;
	height: 61%;
	overflow-y:auto;
}
#footer{
	position:fixed;
	bottom: 3%;
	float:left;
	width: 98%;
	height: 14%;
}
#contentPage{position: fixed;border: .5px solid black;float:left;width: 99%;height: 100%; overflow-y:scroll;}
</style>
<link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("cod_cajera", cdoCaj.getColValue("cod_cajera"))%>
<%=fb.hidden("tipo_desc_empl", cdoCaj.getColValue("tipo_desc_empl"))%>
<%=fb.hidden("tipo_desc_jubil", cdoCaj.getColValue("tipo_desc_jubil"))%>
<%=fb.hidden("almacen", almacen)%>
<%=fb.hidden("cds", cds)%>
<%=fb.hidden("familia", familia)%>
<%=fb.hidden("cjaTipoRec", cjaTipoRec)%>
<%=fb.hidden("tipo_pos", tipo_pos)%>
<%=fb.hidden("tipoDocto", tipoDocto)%>
<%=fb.hidden("addDesc2NC", addDesc2NC)%>
<%=fb.hidden("tipo", tipo)%>
<%=fb.hidden("artType", artType)%>

<div id="container">
		<div id="contentPage">
			<jsp:include page="../pos/fact_header_touch.jsp" flush="true">
				<jsp:param name="fp" value="<%=fp%>"></jsp:param>
				<jsp:param name="tr" value="<%=fg%>"></jsp:param>
				<jsp:param name="artType" value="<%=artType%>"></jsp:param>
				<jsp:param name="caja" value="<%=codCaja%>"></jsp:param>
				<jsp:param name="mode" value="<%=mode%>"></jsp:param>
				<jsp:param name="tipo_pos" value="<%=tipo_pos%>"></jsp:param>
				<jsp:param name="cjaTipoRec" value="<%=cjaTipoRec%>"></jsp:param>
				<jsp:param name="tipoDocto" value="<%=tipoDocto%>"></jsp:param>
				<jsp:param name="tipo" value="<%=tipo%>"></jsp:param>
				<jsp:param name="useKeypad" value="<%=useKeypad?"Y":""%>"></jsp:param>

								</jsp:include>
		</div>
		<div id="left">
		<div width="95%" align="right">
				<a href="javascript:alert('Desc Jubilado');" class="btn btn-xs btn-danger">Desc. Jubilado</a>&nbsp;<a href="javascript:setDescAuto('E');" class="btn btn-xs btn-success">Desc. Empleado</a>
			</div>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextHeader" align="center">
				<td width="60%">Art&iacute;culo</td>
				<td width="7%">&nbsp;</td>
				<td width="10%">Cant.</td>
				<td width="10%">P/U</td>
				<td width="10%">Total</td>
				<td width="3%"></td>
			</tr>
			</table>
		</div>
		<div id="right"><iframe id="artFrame" name="artFrame" frameborder="0" width="100%" height="98%" src="../pos/sel_articles_cafeteria_touch.jsp?fp=fact_cafeteria&artType=<%=artType%>&cds=<%=cds%>&almacen=<%=almacen%>&familia=<%=familia%>&tipo_pos=<%=tipo_pos%>&tipo=<%=tipo%>" scroll="no"></iframe></div>
		<div id="footer">
			<jsp:include page="../pos/fact_footer_touch.jsp" flush="true">
			<jsp:param name="caja" value="<%=codCaja%>"></jsp:param>
			<jsp:param name="cajero" value="<%=cdoCaj.getColValue("cod_cajera")%>"></jsp:param>
			<jsp:param name="cds" value="<%=cds%>"></jsp:param>
			<jsp:param name="almacen" value="<%=almacen%>"></jsp:param>
			<jsp:param name="familia" value="<%=familia%>"></jsp:param>
			<jsp:param name="tipo_pos" value="<%=tipo_pos%>"></jsp:param>
			<jsp:param name="artType" value="<%=artType%>"></jsp:param>
			<jsp:param name="tipo" value="<%=tipo%>"></jsp:param>
			</jsp:include>
		</div>
</div>
<%=fb.formEnd(true)%>
<input type="hidden" id="_winTitle" name="_winTitle" value="<%=java.util.ResourceBundle.getBundle("issi").getString("windowTitle")%>">
<script language="javascript">//resetContentHeight();</script>
</body>
</html>
<%
}//GET
else
{
	String docId="0";
	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Guardar")){
	CommonDataObject cdo = new CommonDataObject();
	cdo.addColValue("cjaTipoRec", request.getParameter("cjaTipoRec"));
	if(request.getParameter("no_recibo")!=null) cdo.addColValue("no_recibo", request.getParameter("no_recibo"));
	if(request.getParameter("fecha_factura")!=null) cdo.addColValue("doc_date", request.getParameter("fecha_factura"));
	if(request.getParameter("tipo_docto")!=null) cdo.addColValue("doc_type", request.getParameter("tipo_docto"));
	if(request.getParameter("client_id")!=null) cdo.addColValue("client_id", request.getParameter("client_id"));
	if(request.getParameter("client_name")!=null) cdo.addColValue("client_name", request.getParameter("client_name"));
	if(request.getParameter("ref_id")==null||request.getParameter("ref_id").trim().equals("")) throw new Exception("Tipo de Cliente no válido, por favor intente nuevamente!");
	else cdo.addColValue("client_ref_id", request.getParameter("ref_id"));
	if(request.getParameter("refer_to")!=null) cdo.addColValue("client_type", request.getParameter("refer_to"));
	if(request.getParameter("ruc")!=null) cdo.addColValue("ruc", request.getParameter("ruc"));
	if(request.getParameter("dv")!=null) cdo.addColValue("dv", request.getParameter("dv"));
	cdo.addColValue("company_id", (String) session.getAttribute("_companyId"));
	if(request.getParameter("tipo_docto").equals("NCR") || request.getParameter("tipo_docto").equals("NDB")){
		cdo.addColValue("reference_id", request.getParameter("reference_id"));
		cdo.addColValue("reference_no", request.getParameter("reference_no"));
	}
	if(request.getParameter("comentario")!=null) cdo.addColValue("observations", request.getParameter("comentario"));
	if(request.getParameter("subtotal_exe")!=null) cdo.addColValue("gross_amount", request.getParameter("subtotal_exe"));
	if(request.getParameter("subtotal_no_exe")!=null) cdo.addColValue("gross_amount_gravable", request.getParameter("subtotal_no_exe"));
	if(request.getParameter("descuento_exe")!=null) cdo.addColValue("total_discount", request.getParameter("descuento_exe"));
	if(request.getParameter("descuento_no_exe")!=null) cdo.addColValue("total_discount_gravable", request.getParameter("descuento_no_exe"));
	cdo.addColValue("sub_total", ""+(Double.parseDouble(request.getParameter("subtotal_exe"))-Double.parseDouble(request.getParameter("descuento_exe"))));
	cdo.addColValue("sub_total_gravable", ""+(Double.parseDouble(request.getParameter("subtotal_no_exe"))-Double.parseDouble(request.getParameter("descuento_no_exe"))));
	if(request.getParameter("itbm")!=null) cdo.addColValue("tax_amount", request.getParameter("itbm"));
	if(request.getParameter("total")!=null) cdo.addColValue("net_amount", request.getParameter("total"));
	if(request.getParameter("tipo_factura")!=null) cdo.addColValue("tipo_factura", request.getParameter("tipo_factura"));
	if(request.getParameter("caja")!=null) cdo.addColValue("cod_caja", request.getParameter("caja"));
	if(request.getParameter("cds")!=null) cdo.addColValue("centro_servicio", request.getParameter("cds"));
	if(request.getParameter("turno")!=null) cdo.addColValue("turno", request.getParameter("turno"));
	if(request.getParameter("cod_cajera")!=null) cdo.addColValue("cod_cajero", request.getParameter("cod_cajera"));
	cdo.addColValue("created_by", (String) session.getAttribute("_userName"));
	cdo.addColValue("modified_by", (String) session.getAttribute("_userName"));
	cdo.addColValue("page_name", "facturar_touch.jsp");
	FAC.setCdo(cdo);
	FAC.getAlDet().clear();
	if(request.getParameter("porAplicar")!=null && Double.parseDouble(request.getParameter("porAplicar"))>0.00){
		CommonDataObject _cdoFP = new CommonDataObject();
		_cdoFP.addColValue("Fp_Codigo", "1");
		_cdoFP.addColValue("monto", "-"+request.getParameter("porAplicar"));
		FAC.getAlFormaPago().add(_cdoFP);
	}
	if(request.getParameter("tipo_factura")!=null && request.getParameter("tipo_factura").equals("CR")){
		CommonDataObject _cdoFP = new CommonDataObject();
		_cdoFP.addColValue("Fp_Codigo", "get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'FORMA_PAGO_CREDITO')");
		_cdoFP.addColValue("monto", request.getParameter("pagoTotal"));
		FAC.getAlFormaPago().clear();
		FAC.getAlFormaPago().add(_cdoFP);
	}
	int size = 0;
	try { size = Integer.parseInt(request.getParameter("detSize")); } catch (Exception ex) {}
	for(int i=0; i<size; i++){
		CommonDataObject cd = new CommonDataObject();
		String codigo = request.getParameter("codigo"+i);
		if(request.getParameter("codigo_almacen"+i)!=null) cd.addColValue("almacen", request.getParameter("codigo_almacen"+i));
		if(request.getParameter("codigo"+i)!=null) cd.addColValue("codigo", codigo.replace("@D@","").replace("@PA@",""));
		if(request.getParameter("descripcion"+i)!=null) cd.addColValue("descripcion", request.getParameter("descripcion"+i));
		if(request.getParameter("tipo_art"+i)!=null) cd.addColValue("tipo_art", request.getParameter("tipo_art"+i));
		if(request.getParameter("id_descuento"+i)!=null) cd.addColValue("id_descuento", request.getParameter("id_descuento"+i));
		if(request.getParameter("valor_descuento"+i)!=null) cd.addColValue("valor_descuento", request.getParameter("valor_descuento"+i));
		if(request.getParameter("tipo_descuento"+i)!=null) cd.addColValue("tipo_descuento", request.getParameter("tipo_descuento"+i));
		if(request.getParameter("itbm"+i)!=null) cd.addColValue("gravable", request.getParameter("itbm"+i));
		if(request.getParameter("gravable_perc"+i)!=null) cd.addColValue("gravable_perc", ""+(Double.parseDouble(request.getParameter("gravable_perc"+i))*100));
		if(request.getParameter("precio"+i)!=null) cd.addColValue("precio", request.getParameter("precio"+i));
		if(request.getParameter("precio_normal"+i)!=null) cd.addColValue("other2", request.getParameter("precio_normal"+i));
		if(request.getParameter("id_precio"+i)!=null) cd.addColValue("other1", request.getParameter("id_precio"+i));
		if(request.getParameter("cantidad"+i)!=null) cd.addColValue("cantidad", request.getParameter("cantidad"+i));
		if(request.getParameter("total"+i)!=null) cd.addColValue("total", request.getParameter("total"+i).replace(",",""));
		if(request.getParameter("total_desc"+i)!=null) cd.addColValue("total_desc", request.getParameter("total_desc"+i));
		if(request.getParameter("total_itbm"+i)!=null) cd.addColValue("total_itbm", request.getParameter("total_itbm"+i));
		if(request.getParameter("tipo_servicio"+i)!=null) cd.addColValue("tipo_servicio", request.getParameter("tipo_servicio"+i));
		if(request.getParameter("tipo_articulo"+i)!=null) cd.addColValue("other3", request.getParameter("tipo_articulo"+i));
		if(request.getParameter("costo"+i)!=null) cd.addColValue("costo", request.getParameter("costo"+i));
		cd.addColValue("compania", (String)session.getAttribute("_companyId"));
		FAC.getAlDet().add(cd);
	}
	
	if(request.getParameter("tipo_docto")!=null && request.getParameter("tipo_docto").equals("NCR")){ 
		if(request.getParameter("reference_id")==null || request.getParameter("reference_id").equals("")) throw new Exception("Nota de Credito sin referencia de Factura!");
	}
	tipoDocto=request.getParameter("tipo_docto");
	if(tipoDocto!=null && tipoDocto.equals("NCR")) tipoDocto="NDC";

	if (FAC.getAlDet().size() == 0) throw new Exception("Por favor registrar por lo menos un ITEM en la transacción a realizar!");
	else if (FAC.getAlFormaPago().size() == 0) throw new Exception("Por favor registar alguna FORMA DE PAGO en la transacción a realizar!");
	else if(tipoDocto.equals("NDC") && (request.getParameter("reference_id")==null || request.getParameter("reference_id").equals(""))) throw new Exception("Nota de credito sin referencia!");
	else CafMgr.addFactura(FAC);
	if(CafMgr.getErrCode().equals("1")){
	session.removeAttribute("htDet");
	session.removeAttribute("FAC");
	docId = CafMgr.getPkColValue("doc_id");

	/*__________________________________________*/
	if(request.getParameter("dgi")!=null&&request.getParameter("dgi").equalsIgnoreCase("Y")){
		StringBuffer sbSql = new StringBuffer();
		sbSql.append("select id from tbl_fac_dgi_documents where decode(facturar_a,'O',decode(tipo_docto,'NCP',codigo,cod_ref),cod_ref) = '");
		sbSql.append(docId);
		sbSql.append("' and compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and tipo_docto = '");
		if(request.getParameter("tipo_docto").equals("NCR")) sbSql.append("NCP");
		else if(request.getParameter("tipo_docto").equals("NDB")) sbSql.append("NDP");
		else sbSql.append("FACP");
		sbSql.append("'");
		cdo = SQLMgr.getData(sbSql.toString());
		docId = cdo.getColValue("id");


		/*
		boolean printerFlag = false;
		IFClient printDGI = new IFClient(request.getRemoteHost(), 3232);


		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp+"&actType="+actType+"&docType="+docType+xtraNotes);


			StringBuffer sbSql = new StringBuffer();

			sbSql.append("select doc_id id, decode(doc_type, 'FAC', 'FAC', 'NDB', 'NDD', 'NCR', 'NDC') tipo_docto, trim(to_char(nvl(net_amount, 0), '999999999990.00')) monto, /*trim(to_char(nvl(total_discount, 0)+nvl(total_discount_gravable, 0), '999999999990.00'))* / 0 totalDiscount, to_char(doc_date, 'dd/mm/yyyy') fecha");
			// valor (incluyendo etiqueta) sin truncar (IFClient se encargará de truncar)
			sbSql.append(", ' ' as labeled");//if label is append to value, if not the comment this line
			sbSql.append(", ruc as clientRUC");
			//sbSql.append(", ruc || '@@0'  as clientRUC"); // se agrego en RUC comando de abrir cashdrawer eso se aplica cuando ya cash drawer esta conectado a impresora fiscal
			sbSql.append(", client_name as clientName");
			sbSql.append(", ' ' as clientAseg");
			sbSql.append(", decode(other2, null, ' ', 'Referencia:'||other3) as docRef");
			sbSql.append(", nvl(a.observations, ' ') as clientAge");
			sbSql.append(", ' ' as clientDOB");
			sbSql.append(", ' ' as clientCategoria");
			sbSql.append(", ' ' as clientMedico");
			sbSql.append(", ' ' as clientAsegComplete");
			sbSql.append(", 'Caja: ' || cod_caja || ' - ' || (select usuario from tbl_cja_cajera where cod_cajera = a.cod_cajero and compania = a.company_id) as totalCentrosTerceros");
			sbSql.append(", ' ' totalCopago");
			sbSql.append(", printed impreso, decode(doc_type, 'FAC', ' ',reference_no) refFactura, dv, checkFactTrxAnulada(company_id, doc_id, doc_type) anulada, trim(to_char(nvl(total_discount, 0) + nvl(total_discount_gravable, 0), '999999999990.99')) totalDescuento, 'N' as printingFlag, ' ' as oc, ' ' direccion1, ' ' direccion2, '0.00' centrosTerceros, 3 num_cols, 'Y' printingCopago, nvl(get_sec_comp_param(company_id,'DGI_DOCUMENT_COPY'),'0') as dgi_copy from tbl_fac_trx a where doc_id = ");
			sbSql.append(docId);
			cdo = SQLMgr.getData(sbSql.toString());
			if(cdo.getColValue("anulada").equals("S")) throw new Exception("La factura fue Anulada previamente! No puede imprimirla!");
			if (printDGI.checkPrinter()) {
				//increase document sequence on IFServer
				//printerFlag = printDGI.setInitialConsecutives(cdo.getColValue("tipo_docto"));
				//if (!printerFlag) throw new Exception("Por favor revisar impresora!");
			}else throw new Exception("Por favor revisar impresora!");

			sbSql = new StringBuffer();
			sbSql.append("select doc_id id, codigo,  substr(descripcion,0,40) itemName, to_char(nvl(cantidad, 1), '999999999990.999') itemQty, to_char(precio, '999999999990.'||NVL((SELECT co.no_dec_dgi FROM TBL_SEC_COMPANIA co WHERE co.codigo = f.compania), 99)) itemUnitPrice, nvl(gravable_perc, 0) taxPerc, to_char(nvl(getDescuentoItem(doc_id, codigo, almacen), 0), '9999990.99') discount from tbl_fac_trxitems f where tipo_descuento is null and doc_id = ");
			sbSql.append(docId);
			ArrayList al = SQLMgr.getDataList(sbSql.toString());

			if(printDGI.checkPrinter()){
			String statusCode1 ="",statusCodeFinal ="";
			boolean closeCmdFlag = false;
			printDGI.sendCmd("7");
				statusCode1 = printDGI.getStatusCode();
				if(cdo.getColValue("tipo_docto").equals("FAC")) printerFlag = printDGI.printInvoice(cdo,al);
				else if(cdo.getColValue("tipo_docto").equals("NDD")) printerFlag = printDGI.printNDD(cdo,al);
				else if(cdo.getColValue("tipo_docto").equals("NDC")) printerFlag = printDGI.printNDC(cdo,al);
				if (!printerFlag) {

					if (printDGI.sendCmd("7")) {

						//20131230 Jacinto: se incrementa la secuencia solo cuando se anula la transacción correctamente
						printDGI.setInitialConsecutives(cdo.getColValue("tipo_docto"));
						msg+="El documento ha sido anulado! Por favor revisar impresora!";

					} else msg += "Error al anular documento! Por favor revisar impresora!";

				} else {

					closeCmdFlag=printDGI.sendCmd("101");
					System.out.println("ejecutando 101 desde runprocess");
					msg="El documento se imprimio correctamente!";

				}
				issi.admin.ISSILogger.error("dgi",request.getContextPath()+request.getServletPath()+" "+msg);

				statusCodeFinal = printDGI.getStatusCode();
				long startTime=System.currentTimeMillis() ;
				long endTime=System.currentTimeMillis()+2000 ;
				while(endTime<startTime) startTime=System.currentTimeMillis() ;

				msg = printDGI.getLastErrMsg();
				if (msg == null || msg.trim().equals("")) msg = "La impresión no se realizó!";
				String _lastDocNum = "";
				if(closeCmdFlag){
					//printDGI.sendBatchCmd("0");//to open cashdrawer
					if(statusCodeFinal.trim().equals("4")||statusCodeFinal.trim().equals("5")||statusCodeFinal.trim().equals("6")){printerFlag = printDGI.setInitialConsecutives(cdo.getColValue("tipo_docto"));
					_lastDocNum = printDGI.lastDocNum(cdo.getColValue("tipo_docto"));}

					if(!_lastDocNum.trim().equals("")){
					sbSql = new StringBuffer();
					sbSql.append("call sp_fac_dgi_upd_numfact(");
					sbSql.append(docId);
					sbSql.append(", '");
					sbSql.append(_lastDocNum);
					sbSql.append("', '");
					sbSql.append((String) session.getAttribute("_userName"));
					sbSql.append("')");
					SQLMgr.execute(sbSql.toString());
					sbSql = new StringBuffer();
					}//update dgi number to document
					System.err.println("printerFlag = "+printerFlag);
					System.err.println("last document = "+_lastDocNum);
					System.err.println("sbSql.toString() = "+sbSql.toString());

					int nCopy = 0;
					try { nCopy = Integer.parseInt(cdo.getColValue("dgi_copy")); } catch (Exception ex) { System.out.println("* * * DGI_DOCUMENT_COPY ["+cdo.getColValue("dgi_copy")+"] invalid number! * * *"); }
					for (int i=1; i<=nCopy; i++) {
						printDGI.sendBatchCmd("RU00000000000000");//to reprint last document
						if (nCopy > 1 && i != nCopy) { System.out.println("Sleeping..."); Thread.sleep(2000); }
					}

				} else throw new Exception(msg);
			} else throw new Exception("Por favor, revisar Impresora.  Si los problemas persisten debe reiniciar el IFServer de impresora fiscal en la PC local!");
	*/}
	}
		/*
		ConMgr.clearAppCtx(null);
		sbSql = new StringBuffer();
		*/
	/*__________________________________________*/
	} else if(request.getParameter("baction").equals("print_copia")){
		/*StringBuffer sbSql = new StringBuffer();
		boolean printerFlag = false;
		IFClient printDGI = new IFClient(request.getRemoteHost(), 3232);
		if(printDGI.checkPrinter()){
			String statusCode1 ="",statusCodeFinal ="";
			boolean closeCmdFlag = false;
			//printDGI.sendCmd("7");
			sbSql.append("select nvl(get_sec_comp_param(");
			sbSql.append((String) session.getAttribute("_companyId"));
			sbSql.append(",'DGI_DOCUMENT_COPY'),'0') as dgi_copy from dual");
			CommonDataObject cdo = SQLMgr.getData(sbSql.toString());

			int nCopy = 1;
			try { nCopy = Integer.parseInt(cdo.getColValue("dgi_copy")); } catch (Exception ex) { System.out.println("* * * DGI_DOCUMENT_COPY ["+cdo.getColValue("dgi_copy")+"] invalid number! * * *"); }
			for (int i=1; i<=nCopy; i++) {
				printDGI.sendBatchCmd("RU00000000000000");//to reprint last document
				if (nCopy > 1 && i != nCopy) { System.out.println("Sleeping..."); Thread.sleep(2000); }
			}

			CafMgr.setErrCode("1");
			CafMgr.setErrMsg("Copia impresa satisfactoriamente!");


		} else throw new Exception("Por favor, revisar Impresora.  Si los problemas persisten debe reiniciar el IFServer de impresora fiscal en la PC local!");	}*/
			CafMgr.setErrCode("1");
			CafMgr.setErrMsg("Copia impresa satisfactoriamente!");


		}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
var _height = 0.25;
var _width = 0.80;
function doAction(){
<% if (request.getParameter("baction") != null && request.getParameter("baction").equals("Guardar") && request.getParameter("dgi") != null && request.getParameter("dgi").equalsIgnoreCase("Y")) { %>
showPopWin('../common/print_fiscal.jsp?fp=facturarpos&actType=2&docType=DGI&docId=<%=docId%>&docNo=POS&tipo=<%=tipoDocto%>&ruc=&touch=y',winWidth*_width,winHeight*_height,null,null,'');
<% } else if(request.getParameter("baction")!=null && request.getParameter("baction").equals("print_copia")) { %>
showPopWin('../common/print_fiscal.jsp?fp=facturarpos&actType=5&docType=DGI&docId=0&docNo=POS&tipo=<%=tipoDocto%>&ruc=',winWidth*_width,winHeight*_height,null,null,'');
<% } else { %>
//CBMSG.warning("Espere hasta que termine de imprimir documento fiscal!");
closeWindow();
<% } %>
}
function closeWindow(){setTimeout('loadPos()',2000);}
function loadPos(){
<% if (CafMgr.getErrCode().equals("1")) { %>
window.location = '<%=request.getContextPath()%>/pos/facturar_touch.jsp?almacen=<%=almacen%>&cds=<%=cds%>&familia=<%=familia%>&tipo_pos=<%=tipo_pos%>';
<% } else throw new Exception(CafMgr.getErrException()); %>
}
</script>
</head>
<body style="margin:0 auto;" onLoad="javascript:doAction();">
<% if (CafMgr.getErrCode().equals("1")) { %>
<p style="font-size: 2em; font-weight:bold; color: #004f72; text-align:center">
<%//=CafMgr.getErrMsg()%>Gracias por su compra! <%=(request.getParameter("tipo_docto").equals("FAC") && request.getParameter("porAplicar") != null && Double.parseDouble(request.getParameter("porAplicar")) > 0.00?"Su cambio es por: "+request.getParameter("porAplicar"):"")%><br>
<button onclick="javascript:loadPos()" class="btn_red_link">Aceptar</button>
</p>
<% } else throw new Exception(CafMgr.getErrException()); %>
</body>
</html>
<%
}//POST
%>