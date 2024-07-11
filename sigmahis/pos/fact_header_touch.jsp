<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iPago" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="FAC" scope="session" class="issi.pos.Factura"/>
<jsp:useBean id="CafMgr" scope="session" class="issi.pos.CafeteriaMgr"/>
<%
SQLMgr.setConnection(ConMgr);
CmnMgr.setConnection(ConMgr);
CafMgr.setConnection(ConMgr);

String mode=request.getParameter("mode");
String change=request.getParameter("change");
String id = request.getParameter("id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String artType = request.getParameter("artType");
String tipo = request.getParameter("tipo");
String tipoCliente = request.getParameter("tipoCliente");
String cjaTipoRec = request.getParameter("cjaTipoRec");
String tipo_pos = request.getParameter("tipo_pos");
String tipoDocto = request.getParameter("tipoDocto");
String useKeypad = request.getParameter("useKeypad");
if(cjaTipoRec==null) cjaTipoRec = "";
if(tipoCliente==null) tipoCliente="";
if(tipoDocto==null) tipoDocto="";
if(useKeypad==null) useKeypad="";
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
ArrayList alCaja = new ArrayList();
if(mode==null) mode="add";
if(fp==null) fp="";
if(fg==null) fg="";
if(tipo_pos==null) tipo_pos="";
if(tipo==null) tipo="";
if(artType==null) artType="";

String caja = request.getParameter("caja");
String cajero = request.getParameter("cajero");

if (caja == null) caja = "";

sbSql.append("select (select nombre from tbl_cja_cajera where estado = 'A' and usuario = '");
sbSql.append((String) session.getAttribute("_userName"));
sbSql.append("' and compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(") cajero_desc,(select tipo from tbl_cja_cajera where estado = 'A' and usuario = '");
sbSql.append((String) session.getAttribute("_userName"));
sbSql.append("' and compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(") cajero_tipo, nvl((select param_value from tbl_sec_comp_param where compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and param_name='MOD_FECHA_POS'), 'N') mod_fecha_pos, nvl(get_sec_comp_param(");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(",'TP_CLIENTE_OTROS'), '11') ref_id, nvl(get_sec_comp_param(");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(", 'USA_TODA_FORMA_PAGO'), 'N') usa_forma_pagos, nvl(get_sec_comp_param(");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(", 'IDS_TIPO_CLTE_EMPL_POS'), 'N') tipo_clte_empl_pos from dual");
cdo = SQLMgr.getData(sbSql.toString());
cdo.addColValue("client_name", "CLIENTE CONTADO");
cdo.addColValue("fecha_factura", CmnMgr.getCurrentDate("dd/mm/yyyy"));
cdo.addColValue("comentario", "");
cdo.addColValue("client_id", "0");
//cdo.addColValue("ref_id", "11");
cdo.addColValue("RUC", "RUC");
cdo.addColValue("DV", "00");
cdo.addColValue("es_clt_cr", "N");
cdo.addColValue("id_precio", "0");
//cdo.addColValue("tipo_clte_empl_pos", "");
sbSql =  new StringBuffer();
if (UserDet.getUserProfile().contains("0")) {
	sbSql.append("select codigo id, trim(to_char(codigo,'009')) as codigo, codigo||' - '||descripcion as descripcion from tbl_cja_cajas where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and estado = 'A' order by descripcion");
} else {
	sbSql.append("select codigo id, trim(to_char(codigo,'009')) as codigo, codigo||' - '||descripcion as descripcion from tbl_cja_cajas where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and codigo in (");
	sbSql.append((String) session.getAttribute("_codCaja"));
	sbSql.append(") and ip = '");
	sbSql.append(request.getRemoteAddr());
	sbSql.append("' and estado = 'A' and codigo in (select b.cod_caja from tbl_cja_turnos a, tbl_cja_turnos_x_cajas b, tbl_cja_cajera c where a.compania = b.compania and a.codigo = b.cod_turno and a.cja_cajera_cod_cajera = c.cod_cajera and a.compania = c.compania and c.usuario = '");
	sbSql.append(UserDet.getUserName());
	sbSql.append("' and b.estatus = 'A') order by descripcion");
}
alCaja = SQLMgr.getDataList(sbSql.toString());
//if (alCaja.size() == 0) throw new Exception("Este equipo no está definido como una Caja. Por favor consulte con su Administrador!");
sbSql =  new StringBuffer();
sbSql.append("select compania, codigo, descripcion, refer_to, es_clt_cr");
if(tipo_pos.equals("CAF")) sbSql.append(", nvl(usa_nivel_precio_caf, 'N') usa_nivel_precio");
if(tipo_pos.equals("FAR")) sbSql.append(", nvl(usa_nivel_precio_far, 'N') usa_nivel_precio");
if(tipo_pos.equals("GEN") || tipo_pos.equals("") ) sbSql.append(", nvl(usa_nivel_precio_gen, 'N') usa_nivel_precio, (case when get_sec_comp_param(-1, 'TP_CLIENTE_OTROS') = to_char(codigo) then 'S' else 'N' end) es_clt_cxco");
sbSql.append(" from tbl_fac_tipo_cliente where compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and activo_inactivo = 'A'");
if(tipo_pos.equals("CAF")) sbSql.append(" and refer_to in ('EMPL', 'MED', 'EMPO', 'CXCO')");
ArrayList alTC = SQLMgr.getDataList(sbSql.toString());
%>
<script language="javascript">
function selCliente(){
	var tipo_factura = getRadioButtonValue(document.form0.tipo_factura);
	var tipo_pos = document.form0.tipo_pos.value;
	var ref_id = document.form0.ref_id.value;
	var refer_to = document.form0.refer_to.value;
	var es_clt_cr = document.form0.es_clt_cr.value;
	var es_clt_cxco = document.form0.es_clt_cxco.value;
	if(es_clt_cr=='N' && tipo_factura=='CR' && es_clt_cxco=='N') CBMSG.alert('Tipo de cliente seleccionado no permite ventas a crédito!');
	else showPopWin('../pos/sel_otros_cliente.jsp?fp=cargo_dev_oc&mode=<%=mode%>&tipo_factura='+tipo_factura+'&tipo_pos='+tipo_pos+'&ref_id='+ref_id+'&Refer_To='+refer_to+'&touch=Y&useKeypad=<%=useKeypad%>',winWidth*.99,_contentHeight*.99,null,null,'');
}

function chkArt(){
	var refer_to = document.form0.refer_to.value;
	var detSize = 0;
	var tcep = splitCols('<%=cdo.getColValue("tipo_clte_empl_pos")%>');
	var tipo_pos = document.form0.tipo_pos.value;
	var subTipoCliente = document.form0.subTipoCliente.value;
	var empleado = false;
	for(i=0;i<tcep.length;i++){
		if(subTipoCliente==tcep[i]) {empleado = true; break;}
	}
	if(document.form0.detSize) detSize = document.form0.detSize.value;
	if((refer_to=='EMPL' || refer_to=='EMPO' || tipo_pos =='FAR' || (refer_to == 'CXCO' && empleado)) && detSize>0){borrarAll();}
	chkCltQty();
}

function setFormaPagoIni(){
	if(document.form0.clt_forma_pago.value != '') $('input:radio[name="tipo_factura"]').filter('[value='+document.form0.clt_forma_pago.value+']').attr('checked', true);
}

function setFormaPago(){
	if(document.form0.clt_forma_pago.value == 'CO') $('input:radio[name="tipo_factura"]').filter('[value='+document.form0.clt_forma_pago.value+']').attr('checked', true);
	else null;


	var tipoFact = getRadioButtonValue(document.form0.tipo_factura);
	if(tipoFact=='CR'){
		document.form0.pagoTotal.value=document.form0.total.value;
		chkArt();
		calcTotal();
	} else {
		document.form0.pagoTotal.value=document.form0.pagoRecibido.value;
		chkArt();
		calcTotal();
	}
}

function getTipoFactura(){
	return getRadioButtonValue(document.form0.tipo_factura);
}
function setArt(val, ref_no){document.form0.reference_id.value=val;document.form0.reference_no.value=ref_no;setCheckedValue(window.frames['artFrame'].document.search01.artType, 'F');window.frames['artFrame'].setArticles(window.frames['artFrame'].document.search01.artType);}

function showList(option){
	var val = "";
	if (typeof option != "undefined"){
	  val = option;
	  document.form0.tipo_docto.value = option;
	}else val = document.form0.tipo_docto.value;

	var ref_id = document.form0.ref_id.value;
	var client_id = document.form0.client_id.value;
	var _continue = true;

	if (getDetTot()>0){
		CBMSG.confirm('Se borrarán los items cargados! Quiere Seguir?',{
			btnTxt:'Si,No',cb:function(r){
		  if (r=="Si"){ _continue = true; borrarAll();console.log("articulos borrados");}
		  else _continue = false;
			if (_continue){
				if(val=='FAC'){
					document.getElementById("lblNoDGIDocto").style.display='none';
					document.form0.reference_no.value='';
				} else {
					showPopWin('../pos/dgi_docto_list.jsp?fp=cafeteria&ref_id='+ref_id+'&client_id='+client_id+'&touch=Y&useKeypad=<%=useKeypad%>',winWidth*.85,_contentHeight*.80,null,null,'');
					document.getElementById("lblNoDGIDocto").style.display='';
				}
			}

		  }});
	} else {
		if (_continue){
			if(val=='FAC'){
				document.getElementById("lblNoDGIDocto").style.display='none';
				document.form0.reference_no.value='';
			} else {
				showPopWin('../pos/dgi_docto_list.jsp?fp=cafeteria&ref_id='+ref_id+'&client_id='+client_id+'&touch=Y&useKeypad=<%=useKeypad%>',winWidth*.85,_contentHeight*.80,null,null,'');
				document.getElementById("lblNoDGIDocto").style.display='';
			}
		}		
	}

}

function chkDate(){
	var fecha = document.form0.fecha_factura.value;
	var x = getDBData('<%=request.getContextPath()%>', '(case when to_date(\''+fecha+'\', \'dd/mm/yyyy\') <> trunc(sysdate) then to_char(sysdate, \'dd/mm/yyyy\') else \'S\' end)', 'dual', '');
	if(x!='S'){
		CBMSG.alert('La fecha no puede ser diferente a la actual!');
		document.form0.fecha_factura.value=x;
	}
}
function setTipoClte(){
	var lookClt=false;
	if(document.form0.client_id.value!=0){
		document.form0.client_id.value=0;
		document.form0.client_name.value='CLIENTE CONTADO';
		lookClt=true;
	}
	document.form0.refer_to.value = eval('document.form0.refer_to_'+document.form0.ref_id.value).value;
	document.form0.es_clt_cr.value = eval('document.form0.es_clt_cr_'+document.form0.ref_id.value).value;
	document.form0.usa_nivel_precio.value = eval('document.form0.usa_nivel_precio_'+document.form0.ref_id.value).value;
	document.form0.es_clt_cxco.value = eval('document.form0.es_clt_cxco_'+document.form0.ref_id.value).value;
	chkArt();
	if(lookClt) selCliente();
}
function addFormaPago(){
var change = '';
var client_id = document.form0.client_id.value;
var subTipoCliente = document.form0.subTipoCliente.value;
var saldo = document.form0.saldo.value;
var tipo_factura = getTipoFactura();
if(document.form0.turno.value=='') {document.form0.save.disabled=true;CBMSG.warning('Sr(a). Usuario, usted no tiene turno definido!');}
else
if(tipo_factura=='CR') CBMSG.alert('La forma de pago crédito se define automáticamente!');
else {
	if(document.form0.fpAdded.value=='S') change=1;
    var tipo = $("#artFrame").contents().find("#tipo").val();
var url = '../pos/cafeteria_formapago_touch.jsp?fg=<%=fg%>&fp=<%=fp%>&mode=<%=mode%>&tipoCliente=<%=tipoCliente%>&subTipoCliente='+subTipoCliente+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio=&codigo=&tipo_pos=<%=tipo_pos%>&artType=<%=artType%>&tipo='+tipo+'&change='+change+'&tipo_factura='+tipo_factura+'&usa_forma_pagos=<%=cdo.getColValue("usa_forma_pagos")%>&client_id='+client_id+'&saldo='+saldo;
	showPopWin(url,winWidth*.80,winHeight*.80,null,null,'');
}
}

function chkFormaPago(){
	if(document.form0._clt_forma_pago.value=='CO') document.form0.clt_forma_pago.value = document.form0._clt_forma_pago.value;
}
function chkDescuento(){
	document.form0.clt_aplica_descuento.value = document.form0._clt_aplica_descuento.value;
}
function setCltEmpl(){
	document.form0.ref_id.value = document.form0.ref_id_empl.value;
}

function printProforma(){
	var cliente = document.form0.client_name.value;
	var subtotal = parseFloat(document.form0.subtotal_exe.value)+parseFloat(document.form0.subtotal_no_exe.value);
	var descuento = parseFloat(document.form0.descuento_exe.value)+parseFloat(document.form0.descuento_no_exe.value);
	var itbm = document.form0.itbm.value;
	var total = document.form0.total.value;
	abrir_ventana('../pos/print_pos_docto.jsp?cliente='+cliente+'&subtotal='+subtotal+'&descuento='+descuento+'&itbm='+itbm+'&total='+total);
}

function loadMarbete(){
	var cliente = document.form0.client_name.value;
	abrir_ventana('../pos/reg_marbete.jsp?fp=POS&client_name='+cliente);
}

function showCreditInfo(){
	var client_id = document.form0.client_id.value;
	var tipoFact = getRadioButtonValue(document.form0.tipo_factura);
	if(client_id!=0 && tipoFact=='CR'){
	if(document.getElementById("clientInfo").style.display=='none') document.getElementById("clientInfo").style.display='';
	else document.getElementById("clientInfo").style.display='none';
	}
}

function getDetTot(){
var detSize = 0;
  if(document.form0.detSize) detSize = document.form0.detSize.value;
  return detSize;
}

function abrirTurno(){
  var turno = document.getElementById("turno").value;
  if (!turno){
    showPopWin('../caja/mantenimientoturno_config.jsp?useKeypad=<%=useKeypad%>&touch=Y',winWidth*.95,winHeight*.99,null,null,'');
  }
}

function cajaTransicion(){
  var turno = document.getElementById("turno").value;
  var caja = document.getElementById("caja").value;
	if(caja!=undefined&&caja!=null&&caja.trim()!=''){
  var countStatus = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_cja_turnos_x_cajas','compania=<%=(String) session.getAttribute("_companyId")%> and cod_caja='+caja+' and estatus = \'A\' '),10);
    
  if (turno && caja && countStatus){
  
  var reemplazo = getDBData('<%=request.getContextPath()%>',' ( select sum(nvl(valor,0))  as saldo  from    (select sum(pago_total*-1)  valor  from tbl_cja_transaccion_pago where compania=<%=(String) session.getAttribute("_companyId")%>  and turno_anulacion = '+turno+'  and rec_status= \'I\'   and turno <> turno_anulacion  and nvl(anulacion_sup,\'x\') <> \'S\' union select sum(pago_total)  from tbl_cja_transaccion_pago a   where a.compania=<%=(String) session.getAttribute("_companyId")%>  and a.turno  = '+turno+'   and a.rec_status  = \'A\'   and exists  (select 1  from tbl_cja_trans_forma_pagos b  where b.compania = a.compania   and b.tran_anio  = a.anio  and b.tran_codigo  = a.codigo   and b.fp_codigo = 0) ) ) valor ',' dual ','');
  var count = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_cja_turnos_x_cajas','compania=<%=(String) session.getAttribute("_companyId")%> and cod_caja='+caja+' and estatus = \'T\' '),10);
  
  if (reemplazo=='0') {
  
    if (count <= 2) {
    
      CBMSG.confirm('Confirma que desea poner en tramite la caja '+caja+', turno '+turno, {btnTxt:'Si,No',cb:function(r){
        if (r == 'Si') showPopWin('../common/run_process.jsp?fp=CJA&actType=50&docType=CJA&docId='+turno+'&docNo='+caja+'&compania=<%=(String) session.getAttribute("_companyId")%>&touch=Y',winWidth*.75,winHeight*.20,null,null,'')
      }});
    
    } else CBMSG.error('Existe mas de (2) turno en estado TRAMITE. Solo está permitido tener dos turno en TRAMITE por caja!');
  
  } else CBMSG.error('Existen recibos ANULADOS que no han sido REEMPLAZADOS, debe completar este paso para poder poner en TRAMITE este turno!');

  }
	}else{CBMSG.error('Por favor seleccione una caja!');}
}
function checkPrinter(){$.ajax({url:'../common/execute_fiscal_cmds.jsp?service=CHECKPRINTER&ajax',success:function(result){var r=result.trim().split('\|');CBMSG.alert(r[0]);if(r[2]=='0'){document.form0.chkdgi.checked=false;document.form0.dgi.value='N';}}});}
function openCashDrawer(){showPopWin('../common/execute_fiscal_cmds.jsp?f_command=0',winWidth*.55,winHeight*.30,null,null,'');}
function showDocNoFisc(){
	var turno = document.form0.turno.value;
	var fecha_factura=document.form0.fecha_factura.value;
	showPopWin('../facturacion/docto_dgi_list.jsp?fp=POS&fg=documentos_pendientes&impreso=N&cod_caja='+document.form0.caja.value+'&turno='+turno+'&fecha_ini='+fecha_factura+'&fecha_fin='+fecha_factura+'&touch=Y',winWidth*.95,_contentHeight,null,null,'');
}
function printX()
{
var turno = document.form0.turno.value;
var caja = document.form0.cod_caja.value;
abrir_ventana('../caja/print_reporte_x.jsp?fp=POS&turno='+turno+'&caja='+caja);
}
function setReadOnly(){
	if(document.form0.client_id.value!=0){
		document.form0.client_id.value=0;
		document.form0.ref_id.value='<%=cdo.getColValue("ref_id")%>';
		CBMSG.warning('Al modificar el nombre se cambiara el tipo de cliente y sera un cliente contado!');
	}
}
function chkTipoClte(){
	var refer_to = document.form0.refer_to.value;
	if(refer_to!='EMPL' && refer_to!='EMPO'){document.form0.client_name.readOnly=true;} else document.form0.client_name.readOnly=false;
}


</script>

<table style="align:center;" width="99%" cellpadding="0" cellspacing="0" id="_tblPosHeader">
<tr style="border-bottom: .5px solid black;">
  <td  colspan="3" align="right">
  <authtype type="56"><a href="javascript:openCashDrawer();" class="btn btn-sm btn-info">Abrir Caj&oacute;n</a></authtype>
  <a href="javascript:checkPrinter();" class="btn btn-sm btn-info">Estado Impr.</a>
  <a href="javascript:showDocNoFisc();" class="btn btn-sm btn-info">Reporte X / Z</a>
  <a href="javascript:abrirTurno();" class="btn btn-sm btn-info">Turno</a>
  
  <a href="javascript:cajaTransicion();" class="btn btn-sm btn-info">Transici&oacute;n</a>&nbsp;
 <authtype type="55"> <a href="javascript:printX();" class="btn btn-sm btn-info">Reporte x Sist. </a></authtype>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  
  <authtype type="52"><a href="javascript:doSubmit('print_copia');" class="btn btn-sm btn-info">Reimprimir</a></authtype>&nbsp;<authtype type="50"><!--<a href="javascript:printProforma();" class="btn_red_link">Proforma</a>--></authtype>
				<authtype type="51"><!--<a href="javascript:loadMarbete();" class="btn_red_link">Marbete</a>--></authtype>
				
	</td>
</tr>
<tr >
	<td align="left" colspan="3">
	<input type="hidden" name="subTipoCliente" id="subTipoCliente">
	Tipo Factura:
	<input type="hidden" name="_tipo_factura" id="tipo_factura">
	<input type="hidden" name="tipo_cajero" id="tipo_cajero" value="<%=cdo.getColValue("cajero_tipo")%>">
	<input type="hidden" name="ref_id_empl" id="ref_id_empl" value="">
	<div class="btn-group" data-toggle="buttons">
	<label class="btn btn-sm btn-default active">
	<input type="radio" name="tipo_factura" id="tipo_factura" value="CO" checked onClick="javascript:setFormaPago();chkCltQty();">
	Contado
	</label>
	<label class="btn btn-sm btn-default">
	<input type="radio" name="tipo_factura" id="tipo_factura" value="CR" onClick="javascript:setFormaPago();chkCltQty();">
	Cr&eacute;dito</label></div>&nbsp;&nbsp;&nbsp;
Fecha:
				<%if(cdo.getColValue("mod_fecha_pos")!=null && cdo.getColValue("mod_fecha_pos").equals("S")){
				String _fecha = cdo.getColValue("fecha_factura");
				%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fecha_factura" />
				<jsp:param name="valueOfTBox1" value="<%=_fecha%>" />
				<jsp:param name="jsEvent" value="chkDate()" />
				</jsp:include>
				<%} else {%>
				<input type="text" id="fecha_factura" name = "fecha_factura" value = "<%=cdo.getColValue("fecha_factura")%>" class="FormDataObjectRequired" size="10" maxLength="10" readOnly>
				<%}%>
				<!--</td>
				<td align="left" width="20%">-->
				<%
				  CommonDataObject cdoP = SQLMgr.getData("select get_sec_comp_param("+(String)session.getAttribute("_companyId")+",'DOC_TYPE_2_BTN') as doc_type_2_btn from dual ");
				  if (cdoP==null){
				    cdoP = new CommonDataObject();
					cdoP.addColValue("doc_type_2_btn","N");
				  }
				  boolean docType2Btn = cdoP.getColValue("doc_type_2_btn")!=null&&cdoP.getColValue("doc_type_2_btn").equals("Y");
				%>
				Doc.
				<% if (docType2Btn){%>
				   <input type="hidden" name="tipo_docto" id="tipo_docto" value="FAC" />
				   <%if(tipoDocto.equals("")){%>
				      <authtype type="53">
				      <a id="btn_fac" name="btn_fac" onClick="javascript:showList('FAC');" class="btn btn-sm btn-success">FACT.</a></authtype>
					  <authtype type="54">
				      <a id="btn_nc" name="btn_nc" onClick="javascript:showList('NCR');" class="btn btn-sm btn-warning">NOTA CRED.</a></authtype>
				   <%} else if(tipoDocto.equals("F")){%>
				     <authtype type="53">
				      <a id="btn_fac" name="btn_fac" onClick="javascript:showList('FAC');" class="btn btn-sm btn-success">FACT.</a></authtype>
				   <%} else if(tipoDocto.equals("NC")){%>
				      <authtype type="54">
				      <a id="btn_nc" name="btn_nc" onClick="javascript:showList('NCR');" class="btn btn-sm btn-warning">NOTA CRED.</a></authtype>
				   <%}%>
				<%}else{%>
				<input type="hidden" name="doc_type_2_sel" id="doc_type_2_sel" value="<%=docType2Btn?"1":"0"%>" />
				<select name="tipo_docto" id="tipo_docto" class="text12 FormDataObjectEnabled" onChange="javascript:showList();">
				<%if(tipoDocto.equals("")){%>
				<option value="FAC">FACTURA</option>
				<option value="NCR">NOTA CREDITO</option>
				<%} else if(tipoDocto.equals("F")){%>
				<option value="FAC">FACTURA</option>
				<%} else if(tipoDocto.equals("NC")){%>
				<option value="NCR">NOTA CREDITO</option>
				<%}%>
				<input type="button" value="Lista" onClick="javascript:showList();" class="CellbyteBtn">
				<%}%>
				<!--<option value="NDB">NOTA DEBITO</option>-->
				</select><!---->	<%if(cjaTipoRec.equals("M")){%>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	No. Recibo:
	<input type="text" id="no_recibo" name = "no_recibo" value = "" class="FormDataObjectRequired" size="12" maxLength="12" onChange="javascript:chkNoRecibo()">
	<%}%>
    &nbsp;&nbsp;&nbsp;Cajero:&nbsp;<%=cdo.getColValue("cajero_desc")%>  
    </br>Tipo Cliente:
	<select id="ref_id" name="ref_id" class="Text10" onChange="javascript:setTipoClte();">
	<%
	for(int i=0;i<alTC.size();i++){
		CommonDataObject cd = (CommonDataObject) alTC.get(i);
	%>
	<option value="<%=cd.getColValue("codigo")%>" <%=(cd.getColValue("codigo").equals(cdo.getColValue("ref_id"))?"selected":"")%>><%=cd.getColValue("descripcion")%></option>
	<%}%>
	</select>
	Caja:
	<select id="caja" name="caja" class="Text10" onChange="javascript:chkCaja();/*setCajaDetail();*/">
	<%
		System.out.println("caja="+caja);
	for(int i=0;i<alCaja.size();i++){
		CommonDataObject ca = (CommonDataObject) alCaja.get(i);
	%>
	<option value="<%=ca.getColValue("codigo")%>" <%=(ca.getColValue("id").equals(caja)?"selected":"")%>><%=ca.getColValue("descripcion")%></option>
	<%}%>
	</select>
  <input type="hidden" name="dgi" id="dgi" value="Y"><authtype type='57'><input type="checkbox" name="chkdgi" id="chkdgi" value="Y" checked onClick="javascript:this.form.dgi.value=this.checked?'Y':'N';"></authtype>DGI
	</td>
    
    
</tr>
<tr class="TextRow01" >
	<td align="left" colspan="3">
	
	</td>


</tr>
	<%
	for(int i=0;i<alTC.size();i++){
		CommonDataObject cd = (CommonDataObject) alTC.get(i);
	%>
	<input type="hidden" id="ref_id_<%=cd.getColValue("codigo")%>" name = "ref_id_<%=cd.getColValue("codigo")%>" value = "<%=cd.getColValue("codigo")%>">
	<input type="hidden" id="refer_to_<%=cd.getColValue("codigo")%>" name = "refer_to_<%=cd.getColValue("codigo")%>" value = "<%=cd.getColValue("refer_to")%>">
	<input type="hidden" id="es_clt_cr_<%=cd.getColValue("codigo")%>" name = "es_clt_cr_<%=cd.getColValue("codigo")%>" value = "<%=cd.getColValue("es_clt_cr")%>">
	<input type="hidden" id="usa_nivel_precio_<%=cd.getColValue("codigo")%>" name = "usa_nivel_precio_<%=cd.getColValue("codigo")%>" value = "<%=cd.getColValue("usa_nivel_precio")%>">
	<input type="hidden" id="es_clt_cxco_<%=cd.getColValue("codigo")%>" name = "es_clt_cxco_<%=cd.getColValue("codigo")%>" value = "<%=cd.getColValue("es_clt_cxco")%>">
	<%}%>
<tr>
	<td colspan="3" class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<input type="hidden" id="mode" name = "mode" value = "<%=mode%>">
			<input type="hidden" id="change" name = "change" value = "<%=change%>">
			<input type="hidden" id="baction" name = "baction" value = "">
			<input type="hidden" id="fg" name = "fg" value = "<%=fg%>">
			<input type="hidden" id="fp" name = "fp" value = "<%=fp%>">
			<input type="hidden" id="cod_caja" name = "cod_caja" value = "<%=caja%>">
			<input type="hidden" id="turno" name = "turno" value = "">
			<input type="hidden" id="precio_aplicado" name = "precio_aplicado" value = "N">
			<input type="hidden" id="combo_adicional_aplicado" name = "combo_adicional_aplicado" value = "N">
			<input type="hidden" id="es_clt_cr" name = "es_clt_cr" value = "N">
			<input type="hidden" id="usa_nivel_precio" name = "usa_nivel_precio" value = "N">
			<input type="hidden" id="fpAdded" name = "fpAdded" value = "N">
			<input type="hidden" id="facturar_al_costo" name = "facturar_al_costo" value = "N">
			<input type="hidden" id="es_clt_cxco" name = "es_clt_cxco" value = "N">
			<tr class="TextRow01">
				<td colspan="3"><table><tr>
				<td id="tdCliente" align="left" onClick="javascript:showCreditInfo()" style="cursor:pointer"> <!--width="32%"-->Cliente:</td>
				<td align="left">
				<jsp:include page="../common/autocomplete.jsp" flush="true">
					<jsp:param name="fieldId" value="client_name"/>
					<jsp:param name="fieldValue" value="<%=cdo.getColValue("client_name")%>"/>
					<jsp:param name="fieldType" value="text"/>
					<jsp:param name="fieldIsRequired" value="y"/>
					<jsp:param name="fieldIsReadOnly" value="n"/>
					<jsp:param name="fieldClass" value="Text10"/>
					<jsp:param name="fieldSize" value="30"/>
					<jsp:param name="dObjId" value="document.form0.client_id"/>
					<jsp:param name="dObjDescription" value="document.form0.client_name"/>
					<jsp:param name="dObjXtra1" value="document.form0.ruc"/>
					<jsp:param name="dObjXtra2" value="document.form0.dv"/>
					<jsp:param name="dObjXtra3" value="document.form0.id_precio"/>
					<jsp:param name="dObjXtra4" value="document.form0.ref_id_empl"/>
					<jsp:param name="containerSize" value="150%"/>
					<jsp:param name="containerFormat" value="@@description (@@id - @@refer)"/>
					<jsp:param name="containerOnSelect" value="setCltEmpl();setTipoClte();setFormaPagoIni();setFormaPago();"/>
					<jsp:param name="dsMatchBy" value="refer"/>
					<jsp:param name="dsQueryString" value=""/>
					<jsp:param name="dsType" value="EMPL_POS"/>
					<jsp:param name="minChars" value="1"/>
				</jsp:include>
				</td>
				<TD>
				<input class="CellbyteBtn" type="button" id="btnClte" name = "btnClte" value = "..." onClick="javascript:selCliente();">
				CB:
				<iframe name="iFrameClte" id="iFrameClte" frameborder="0" align="center" width="38%" height="20" scrolling="no" src="../pos/sel_otros_cliente_br.jsp?Refer_To=EMPL"></iframe>
				</TD>
				<td align="left">
				<input type="hidden" id="refer_to" name = "refer_to" value = "<%=cdo.getColValue("refer_to")%>">
				<input type="hidden" id="ruc" name = "ruc" value = "<%=cdo.getColValue("ruc")%>">
				<input type="hidden" id="dv" name = "dv" value = "<%=cdo.getColValue("dv")%>">
				<input type="hidden" id="client_id" name = "client_id" value = "<%=cdo.getColValue("client_id")%>">
				<input type="hidden" id="id_precio" name = "id_precio" value = "<%=cdo.getColValue("id_precio")%>">
				<input type="hidden" id="reference_id" name = "reference_id" value = "">
				<label id="lblNoDGIDocto" style="display:none;"><input type="text" id="reference_no" name = "reference_no" value = "" class="FormDataObjectRequired" size="22" maxLength="22"></label>
				Coment.
				<textarea name="comentario" id="comentario" cols="40" rows="1" class="text10 FormDataObjectEnabled" style="width: 300px; height: 15px;"><%=cdo.getColValue("comentario")%></textarea>

				</td>
				</tr></table></td>
			</tr>
			<tr id="clientInfo" style="display:none">
				<td class="TextRow01" align="left" colspan="2">
Cliente es:
				<select name="clt_forma_pago" id="clt_forma_pago" class="text12 FormDataObjectEnabled" onChange="javascript:chkFormaPago();" readOnly>
				<option value="">--</option>
				<option value="CR">Cr&eacute;dito</option>
				<option value="CO">Contado</option>
				</select>
				<input type="hidden" id="_clt_forma_pago" name="_clt_forma_pago" value="">
				<input type="hidden" id="_clt_aplica_descuento" name="_clt_aplica_descuento" value="">
				D&iacute;as Cr&eacute;dito:
				<select name="dias_cr_limite" id="dias_cr_limite" class="text12 FormDataObjectEnabled" onChange="" readOnly>
				<option value="0">--</option>
				<option value="1">15 Dias</option>
				<option value="2">30 Dias</option>
				<option value="3">45 Dias</option>
				<option value="4">60 Dias</option>
				<option value="5">90 Dias</option>
				<option value="6">120 Dias</option>
				</select>Descuento:
								<select name="clt_aplica_descuento" id="clt_aplica_descuento" class="text12 FormDataObjectEnabled" onChange="javascript:chkDescuento();" readOnly>
								<option value="">--</option>
								<option value="Y">Si</option>
								<option value="N">No</option>
				</select><input type="hidden" name="pagoRecibido" id="pagoRecibido" value="0.00" class="text14 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0" readOnly>
				<td class="TextHeader02">Cr&eacute;dito:
												<input type="text" id="monto_cr_limite" name = "monto_cr_limite" value = "0.00" class="FormDataObjectDisabled" size="12" maxLength="12" style="text-align:right;" readOnly>
												Disp.:
								<input type="text" id="saldo" name = "saldo" value = "0.00" class="FormDataObjectDisabled" size="12" maxLength="12" style="text-align:right;" readOnly>
				</td>


			</tr>
<!--
			<tr class="TextRow02">
				<td colspan="7"><iframe name="formaPago" id="formaPago" frameborder="0" align="center" width="100%" height="100" scrolling="yes" src="../pos/cafeteria_formapago.jsp?fg=<%=fg%>&fp=<%=fp%>&mode=<%=mode%>&tipoCliente=<%=tipoCliente%>&compania=<%=(String) session.getAttribute("_companyId")%>&anio=<%=2012%>&codigo=<%=1%>&tipo_pos=<%=tipo_pos%>"></iframe></td>
			</tr>
			-->

		</table>
	</td>
</tr>
</table>
