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

int iconHeight = 28;
int iconWidth = 28;
String mode=request.getParameter("mode");
String change=request.getParameter("change");
String id = request.getParameter("id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String artType = request.getParameter("artType");
String tipoCliente = request.getParameter("tipoCliente");
String cjaTipoRec = request.getParameter("cjaTipoRec");
String tipo_pos = request.getParameter("tipo_pos");
String tipoDocto = request.getParameter("tipoDocto");
String cds = request.getParameter("cds");
String familia = request.getParameter("familia");
String almacen = request.getParameter("almacen");
if(cjaTipoRec==null) cjaTipoRec = "";
if(tipoCliente==null) tipoCliente="";
if(tipoDocto==null) tipoDocto="";
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoHeader = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
ArrayList alCaja = new ArrayList();
if(mode==null) mode="add";
if(fp==null) fp="";
if(fg==null) fg="";
if(tipo_pos==null) tipo_pos="";
String usaPlanMedico="";
String caja = request.getParameter("caja");
String cajero = request.getParameter("cajero");
String proformaId = request.getParameter("proformaId");
String refId = request.getParameter("refId");
String referTo = request.getParameter("referTo");
String clienteId = request.getParameter("clienteId");
if(proformaId==null) proformaId="";
if(refId==null) refId="";
if(referTo==null) referTo="";
if(clienteId==null) clienteId="";

try {usaPlanMedico =java.util.ResourceBundle.getBundle("planmedico").getString("usaPlanMedico");}catch(Exception e){ usaPlanMedico = "N";}
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
sbSql.append(",'COD_ARTICULO_GRAL'), '0') cod_articulo_gral, NVL((select descripcion from tbl_inv_articulo where compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" and to_char(cod_articulo) = (select get_sec_comp_param(");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(",'COD_ARTICULO_GRAL') from dual)");
sbSql.append("), 'NA') desc_articulo_gral, nvl(get_sec_comp_param(");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(",'POS_ALWAYS_ALERT_SALDO'),'N') as always_alert_saldo, nvl(get_sec_comp_param(");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(",'APL_DESC_GLOBAL_POS'),'N') as APL_DESC_GLOBAL_POS from dual");
cdo = SQLMgr.getData(sbSql.toString());
boolean alwaysAlertSaldo = (cdo.getColValue("always_alert_saldo").equalsIgnoreCase("Y") || cdo.getColValue("always_alert_saldo").equalsIgnoreCase("S"));
cdo.addColValue("client_name", "CLIENTE CONTADO");
cdo.addColValue("fecha_factura", CmnMgr.getCurrentDate("dd/mm/yyyy"));
cdo.addColValue("comentario", "");
cdo.addColValue("client_id", "0");
//cdo.addColValue("ref_id", "11");
cdo.addColValue("RUC", "RUC");
cdo.addColValue("DV", "00");
cdo.addColValue("es_clt_cr", "N");
cdo.addColValue("id_precio", "0");
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
//sbSql.append(" and refer_to in ('CXCO')");
ArrayList alTC = SQLMgr.getDataList(sbSql.toString());
ArrayList alDesc = SQLMgr.getDataList("select id, codigo||'-'||descripcion descripcion, tipo||'|'||valor as titulo, (case when to_char(id) = nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'ID_TIPO_DESC_EMPL'),'0') then 'S' else 'N' end) as desc_empl, valor, es_desc_global from tbl_par_descuento d where compania = "+(String) session.getAttribute("_companyId")+" and estado = 'A' order by codigo||' - '||descripcion");
if(!proformaId.trim().equals(""))
{
		CommonDataObject cdoQry = new CommonDataObject();
	cdoQry=SQLMgr.getData("select query from tbl_gen_query where id = 1 and refer_to = '"+referTo+"'");
	if(cdoQry==null) throw new Exception("No existe un listado para el tipo de cliente solicitado!");
	System.out.println("query......=\n"+cdoQry.getColValue("query"));

	sbSql = new StringBuffer();
	sbSql.append("select a.compania, a.codigo, a.refer_to, a.nombre,");
	if (clienteId.trim().equals("0")) {
	sbSql.append(" (select  nvl(observations,'') from tbl_fac_proforma where doc_id= ");
	sbSql.append(proformaId);
	sbSql.append(") as comentario, ");
	}

	sbSql.append("  to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento, a.ruc, nvl(a.dv,' ')as dv, nvl(b.id_precio, 0) id_precio, decode(a.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = a.codigo), a.codigo) num_empleado, (case when nvl(get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'TP_CLIENTE_OTROS'),'-') ");
	sbSql.append(" = ");
	sbSql.append(refId);
	sbSql.append(" then 'Y' else 'N' end) es_clt_cxc_otros, (case when  nvl(get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'TP_CLIENTE_OTROS'),'-') = ");
	sbSql.append(refId);
	sbSql.append(" then (select facturar_al_costo from tbl_cxc_cliente_particular cp where cp.compania = a.compania and  to_char(cp.codigo) = a.codigo) else 'N' end) facturar_al_costo");
	if(referTo.trim().equals("CXCO")) {
		sbSql.append(", a.tipo_cliente as tipoCliente, nvl((select monto_cr_limite from tbl_cxc_cliente_particular cp where cp.compania = a.compania and to_char(cp.codigo) = a.codigo), 0) monto_cr_limite");
	} else {
		sbSql.append(", null as tipoCliente, 0 monto_cr_limite");
	}
	sbSql.append(", a.other1, a.other2, a.other3, a.other4, a.other5, (select get_age(a.fecha_nac,trunc(sysdate),'y') from dual) as edad");
	if (referTo.equalsIgnoreCase("PAC")) sbSql.append(", a.cedula, (select pp.apartado_postal from tbl_adm_paciente pp where pp.pac_id = a.codigo and rownum = 1) as cod_referencia ");
	sbSql.append(" from (");
	sbSql.append(cdoQry.getColValue("query").replace("@@compania", (String) session.getAttribute("_companyId")));
	sbSql.append(") a, tbl_clt_lista_precio b where nvl(compania,");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(")");
	if(referTo.trim().equals("COMP"))sbSql.append("<>");
	else sbSql.append("= ");
	sbSql.append(session.getAttribute("_companyId"));
	if (!referTo.trim().equals("")) {
		sbSql.append(" and refer_to = '");
		sbSql.append(referTo);
		sbSql.append("'");
	}
	if (!clienteId.trim().equals("")) {
		if(referTo.equals("EMPL")){
			sbSql.append(" and exists (select null from tbl_pla_empleado e where to_char(emp_id) = a.codigo and num_empleado ='");
			sbSql.append(clienteId);
			sbSql.append("')");
		} else {
			sbSql.append(" and codigo = '");
			sbSql.append(clienteId);
			sbSql.append("'");
		}
	}
	//sbSql.append(sbFilter.toString());
	sbSql.append(" and a.refer_to = b.tipo_clte(+) and a.codigo = b.id_clte(+) and b.ref_id(+) = ");
	sbSql.append(refId);
	//if(!subRefType.trim().equals("")){sbSql.append(" and a.tipo_cliente= ");sbSql.append(subRefType);}
	sbSql.append(" order by nombre");

	cdoHeader=SQLMgr.getData(sbSql.toString());

}

%>
<script language="javascript">
function setValue(){
var tipo_factura = getRadioButtonValue(document.form0.tipo_factura);
<% if (!proformaId.trim().equals("")) { %>
	if('<%=cdoHeader.getColValue("es_clt_cxc_otros")%>'=='Y'){
		var x = splitCols(getDBData('<%=request.getContextPath()%>', 'forma_pago, dias_cr_limite, nvl(monto_cr_limite,0.00), nvl(aplica_descuento,\'N\')<% if(referTo.trim().equals("CXCO")) { %>, (case when nvl((select limite_subsidio from tbl_cxc_tipo_otro_cliente where compania = z.compania and id = z.tipo_cliente),0) != 0 then nvl((select limite_subsidio from tbl_cxc_tipo_otro_cliente where compania = z.compania and id = z.tipo_cliente),0) - (select getconsumodia(compania,tipo_cliente,codigo,to_char(sysdate,\'dd/mm/yyyy\')) from dual) else nvl(monto_cr_limite,0) - nvl((select getSaldoClt(compania,<%=refId%>,codigo) from dual),0) end)<% } else { %>0<% } %> saldo', 'tbl_cxc_cliente_particular z','compania = <%=(String) session.getAttribute("_companyId")%> and codigo=<%=cdoHeader.getColValue("codigo")%>'));
		document.form0.clt_forma_pago.value = x[0];
		document.form0._clt_forma_pago.value = x[0];
		document.form0.dias_cr_limite.value = x[1];
		document.form0.monto_cr_limite.value = x[2];
		document.form0.clt_aplica_descuento.value = x[3];
		document.form0._clt_aplica_descuento.value = x[3];
		var saldo=parseFloat(x[4]);
		 if (tipo_factura=="CR" || <%=alwaysAlertSaldo%> ){alert('El cliente <%=cdoHeader.getColValue("nombre")%> tiene disponible: $'+saldo.toFixed(2));}

		document.form0.saldo.value = saldo;
		if(document.getElementById("tdCliente")){
			if(x[0]=='CR')document.getElementById("tdCliente").className='RedText';
			else document.getElementById("tdCliente").className='';
		}
	}

	document.form0.client_id.value = '<%=cdoHeader.getColValue("codigo")%>';
	document.form0.client_name.value = '<%=cdoHeader.getColValue("nombre")%>';
	<%if(clienteId.trim().equals("0")){%>document.form0.comentario.value = '<%=cdoHeader.getColValue("comentario")%>';<%}%>
	document.form0.ruc.value = '<%=cdoHeader.getColValue("ruc")%>';
	document.form0.dv.value = '<%=cdoHeader.getColValue("dv")%>';
	document.form0.id_precio.value = '<%=cdoHeader.getColValue("id_precio")%>';
	document.form0.facturar_al_costo.value = '<%=cdoHeader.getColValue("facturar_al_costo")%>';
	if(document.form0.subTipoCliente) document.form0.subTipoCliente.value = '<%=cdoHeader.getColValue("tipoCliente")%>';
	setFormaPagoIni();
	setFormaPago();
	//chkArt();
	chkTipoClte();

<% } %>
}
function selCliente(){
	var tipo_factura = getRadioButtonValue(document.form0.tipo_factura);
	var tipo_pos = document.form0.tipo_pos.value;
	var ref_id = document.form0.ref_id.value;
	var refer_to = document.form0.refer_to.value;
	var es_clt_cr = document.form0.es_clt_cr.value;
	var es_clt_cxco = document.form0.es_clt_cxco.value;
	if(refer_to=='' || refer_to == 'null') {
		setTipoClte();
		refer_to = document.form0.refer_to.value;
	}
if(es_clt_cr=='N' && tipo_factura=='CR' && es_clt_cxco=='N') CBMSG.warning('Tipo de cliente seleccionado no permite ventas a crédito!');
	else showPopWin('../pos/sel_otros_cliente.jsp?fp=cargo_dev_oc&mode=<%=mode%>&tipo_factura='+tipo_factura+'&tipo_pos='+tipo_pos+'&ref_id='+ref_id+'&Refer_To='+refer_to,winWidth*.99,_contentHeight*.99,null,null,'');
}

function chkArt(){
	var refer_to = document.form0.refer_to.value;
	var detSize = 0;
	var tipo_pos = document.form0.tipo_pos.value;
	if(document.form0.detSize) detSize = document.form0.detSize.value;
	if((refer_to=='EMPL' || refer_to=='EMPO' || tipo_pos =='FAR') && detSize>0){borrarAll();}
	chkCltQty();
}

function setFormaPagoIni(){
	if(document.form0.clt_forma_pago.value != '') $('input:radio[name="tipo_factura"]').filter('[value='+document.form0.clt_forma_pago.value+']').attr('checked', true);
}

function setFormaPago(){
	if(document.form0._tipo_factura.value=='X'){
	if(document.form0.clt_forma_pago.value == 'CO') $('input:radio[name="tipo_factura"]').filter('[value='+document.form0.clt_forma_pago.value+']').attr('checked', true);
	else null;
	} else {
		document.form0.tipo_factura.value=document.form0._tipo_factura.value;
	}


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

	if (getDetTot()>0)
		if (!confirm("Se borrarán los items cargados! Quiere Seguir?")) _continue = false;
		else {_continue = true; borrarAll();}

	if (_continue){
		if(val=='FAC'){
			document.getElementById("lblNoDGIDocto").style.display='none';
			document.form0.reference_no.value='';
			$("#btn_fac").addClass("btn_red_link").removeClass("CellbyteBtn");
			$("#btn_nc").removeClass("btn_red_link").addClass("CellbyteBtn");
			$("#btn_pr").removeClass("btn_red_link").addClass("CellbyteBtn");
			//window.frames['artFrame'].document.getElementById('lblArtTypeFact').style.display='none';
		}
		else if(val=='PRO') {
			showPopWin('../pos/dgi_docto_list.jsp?fp=cafeteria&docType=PRO&ref_id='+ref_id+'&client_id='+client_id,winWidth*.85,_contentHeight*.80,null,null,'');
			document.getElementById("lblNoDGIDocto").style.display='none';
			$("#btn_pr").addClass("btn_red_link").removeClass("CellbyteBtn");
			$("#btn_fac").removeClass("btn_red_link").addClass("CellbyteBtn");
			$("#btn_nc").removeClass("btn_red_link").addClass("CellbyteBtn");
		}
		else {
			var refer_to = document.form0.refer_to.value;
			var empl_es_cajero = getDBData('<%=request.getContextPath()%>', '\'S\'', 'dual', '\''+client_id+'\'=\'<%=UserDet.getRefCode()%>\'');
			if(refer_to=='EMPL' && empl_es_cajero=='S') CBMSG.warning('Usted no se puede aplicar una nota de credito!');
			else {
				showPopWin('../pos/dgi_docto_list.jsp?fp=cafeteria&ref_id='+ref_id+'&client_id='+client_id,winWidth*.85,_contentHeight*.80,null,null,'');
			document.getElementById("lblNoDGIDocto").style.display='';
				$("#btn_nc").addClass("btn_red_link").removeClass("CellbyteBtn");
				$("#btn_fac").removeClass("btn_red_link").addClass("CellbyteBtn");
				$("#btn_pr").removeClass("btn_red_link").addClass("CellbyteBtn");
			}
		}
	}
}

function chkDate(){
	var fecha = document.form0.fecha_factura.value;
	var x = getDBData('<%=request.getContextPath()%>', '(case when to_date(\''+fecha+'\', \'dd/mm/yyyy\') <> trunc(sysdate) then to_char(sysdate, \'dd/mm/yyyy\') else \'S\' end)', 'dual', '');
	if(x!='S'){
		CBMSG.warning('La fecha no puede ser diferente a la actual!');
		document.form0.fecha_factura.value=x;
	}
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
var tipo_factura = getTipoFactura();
if(tipo_factura=='CR') CBMSG.warning('La forma de pago crédito se define automáticamente!');
else {
	if(document.form0.fpAdded.value=='S') change=1;
	var url = '../pos/cafeteria_formapago.jsp?fg=<%=fg%>&fp=<%=fp%>&mode=<%=mode%>&tipoCliente=<%=tipoCliente%>&compania=<%=(String) session.getAttribute("_companyId")%>&anio=&codigo=&tipo_pos=<%=tipo_pos%>&change='+change+'&tipo_factura='+tipo_factura;
	showPopWin(url,winWidth*.95,_contentHeight*.85,null,null,'');
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
	var comment = document.form0.comentario.value;
	abrir_ventana('../pos/print_pos_docto.jsp?cliente='+cliente+'&subtotal='+subtotal+'&descuento='+descuento+'&itbm='+itbm+'&total='+total+'&comment='+comment);
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

function __setCds(obj){
	var codigo = obj.value;
	var cds = <%=cds%>;

	if(codigo) {
		if(cds != "") {

			 CBMSG.warning("Usted está cambiando el Centro de Servicio por lo cual se reiniciará la transacción!", {
				 cb: function(r){
						if (r=='Ok') window.location = '../pos/facturar.jsp?cds='+codigo+'&familia=<%=familia%>&almacen=<%=almacen%>&artType=<%=artType%>&tipo_pos=<%=tipo_pos%>';
				 }
			 });
		}
	}
}

function imprimeFormPM(){abrir_ventana('../planmedico/pm_clientes_list.jsp?fp=admision&tipo=B');}

</script>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr class="TextHeader">
	<td align="left" colspan="2">
	<input type="hidden" name="subTipoCliente" id="subTipoCliente">
	Tipo Factura:
	<input type="hidden" name="_tipo_factura" id="_tipo_factura" value = "X">
	<input type="hidden" name="tipo_cajero" id="tipo_cajero" value="<%=cdo.getColValue("cajero_tipo")%>">
	<input type="hidden" name="cod_articulo_gral" id="cod_articulo_gral" value="<%=cdo.getColValue("cod_articulo_gral")%>">
	<input type="hidden" name="desc_articulo_gral" id="desc_articulo_gral" value="<%=cdo.getColValue("desc_articulo_gral")%>">
	<input type="hidden" name="ref_id_empl" id="ref_id_empl" value="">
	<input type="radio" name="tipo_factura" id="tipo_factura" value="CO" checked onClick="javascript:setFormaPago();chkCltQty();setFormaPago();getTipoFactura();">
	Contado
	<input type="radio" name="tipo_factura" id="tipo_factura" value="CR" onClick="javascript:setFormaPago();chkCltQty();setFormaPago();getTipoFactura();">
	Cr&eacute;dito&nbsp;&nbsp;&nbsp;
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
					System.out.println("doc_type_2_btn"+cdoP.getColValue("doc_type_2_btn"));
					System.out.println("tipoDocto"+tipoDocto);
				%>
				Doc.
				<% if (docType2Btn){%>
					 <input type="hidden" name="tipo_docto" id="tipo_docto" value="FAC" />
					 <input type="hidden" name="tipo_docto_ref" id="tipo_docto_ref" value="" />
					 <input type="hidden" name="noDocNoFisc" id="noDocNoFisc" value="0" />
					 <%if(tipoDocto.equals("")){%>
							<authtype type="53">
							<a id="btn_fac" name="btn_fac" onClick="javascript:showList('FAC');" class="btn_red_link">FACT.</a></authtype>
						<authtype type="54">
							<a id="btn_nc" name="btn_nc" onClick="javascript:showList('NCR');" class="CellbyteBtn">NOTA CRED.</a></authtype>
					 <%} else if(tipoDocto.equals("F")){%>
						 <authtype type="53">
							<a id="btn_fac" name="btn_fac" onClick="javascript:showList('FAC');" class="CellbyteBtn">FACT.</a></authtype>
					 <%} else if(tipoDocto.equals("NC")){%>
							<authtype type="54">
							<a id="btn_nc" name="btn_nc" onClick="javascript:showList('NCR');" class="CellbyteBtn">NOTA CRED.</a></authtype>
					<%}%>
				<%}else{%>
				<input type="hidden" name="tipo_docto_ref" id="tipo_docto_ref" value="" />
				<input type="hidden" name="doc_type_2_sel" id="doc_type_2_sel" value="<%=docType2Btn?"1":"0"%>" />
				<select name="tipo_docto" id="tipo_docto" class="text12 FormDataObjectEnabled" onChange="javascript:showList();">
				<%if(tipoDocto.equals("")){%>
				<option value="FAC">FACTURA</option>
				<option value="NCR">NOTA CREDITO</option>
				<option value="PRO">PROFORMA</option>
				<%} else if(tipoDocto.equals("F")){%>
				<option value="FAC">FACTURA</option>
				<%} else if(tipoDocto.equals("NC")){%>
				<option value="NCR">NOTA CREDITO</option>
				<%} else if(tipoDocto.equals("PRO")){%>
				<option value="PRO">PROFORMA</option>
				<%}%>
				<input type="button" value="Lista" onClick="javascript:showList();" class="CellbyteBtn">
				<%}
								if(tipo_pos != null && tipo_pos.equalsIgnoreCase("GEN")){
								%>
								CDS
								<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cds_centro_servicio where nvl(usa_pos, 'N') = 'S' and estado = 'A' and compania_unorg = "+((String) session.getAttribute("_companyId")),"all_cds",cds,false,false,0,"Text10","","onchange=__setCds(this)",null,"S")%>
								<%}%>
				<!--<option value="NDB">NOTA DEBITO</option>-->
				</select><!---->	<%if(cjaTipoRec.equals("M")){%>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	No. Recibo:
	<input type="text" id="no_recibo" name = "no_recibo" value = "" class="FormDataObjectRequired" size="12" maxLength="12" onChange="javascript:chkNoRecibo()">
	<%}%>
	</td><td align="right"><a href="javascript:showDocNoFisc();" class="btn_link"><blink><label id="lblDocNoFisc" name="lblDocNoFisc">Documentos DGI</label></blink></a> &nbsp;&nbsp;&nbsp;<%if(usaPlanMedico.equals("S") && tipo_pos != null && tipo_pos.equalsIgnoreCase("GEN")){%><authtype type='74'><a href="javascript:imprimeFormPM();" class="hint hint--left" data-hint="Inprimir Formulario de Atenci&oacute;n Plan M&eacute;dico"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,35)" onMouseOut="javascript:mouseOut(this,35)" src="../images/plan_med.png"></a></authtype><%}%> &nbsp;&nbsp;&nbsp;<authtype type="52"><a href="javascript:doSubmit('print_copia');" class="btn_red_link">Reimprimir</a></authtype>&nbsp;<authtype type="50"><a href="javascript:printProforma();" class="btn_red_link">Proforma</a></authtype>
				<authtype type="51"><a href="javascript:loadMarbete();" class="btn_red_link">Marbete</a></authtype>
				<a href="javascript:addFormaPago();" class="btn_red_link">Pago</a>
	</td>
</tr>
<tr class="TextRow01">
	<td align="left" colspan="3">
	Tipo Cliente:
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
	&nbsp;&nbsp;&nbsp;Cajero:&nbsp;<%=cdo.getColValue("cajero_desc")%>
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
					<jsp:param name="onChange" value="setReadOnly()"/>
				</jsp:include>
				</td>
				<td align="left">
				<input type="button" id="btnClte" name = "btnClte" value = "..." onClick="javascript:selCliente();">
				<input type="hidden" id="refer_to" name = "refer_to" value = "<%=cdo.getColValue("refer_to")%>">
				<input type="hidden" id="ruc" name = "ruc" value = "<%=cdo.getColValue("ruc")%>">
				<input type="hidden" id="dv" name = "dv" value = "<%=cdo.getColValue("dv")%>">
				<input type="hidden" id="client_id" name = "client_id" value = "<%=cdo.getColValue("client_id")%>">
				<input type="hidden" id="id_precio" name = "id_precio" value = "<%=cdo.getColValue("id_precio")%>">
				<input type="hidden" id="reference_id" name = "reference_id" value = "">
				<label id="lblNoDGIDocto" style="display:none;"><input type="text" id="reference_no" name = "reference_no" value = "" class="FormDataObjectRequired" size="22" maxLength="22"></label>
				Coment.
				<textarea name="comentario" id="comentario" cols="40" rows="1" class="text10 FormDataObjectEnabled" style="width: 300px; height: 15px;"><%=cdo.getColValue("comentario")%></textarea>
				&nbsp;&nbsp;
				<%if (tipo_pos.equals("") || tipo_pos.equals(null) || tipo_pos.equals("FAR")){%>
					Farmacéutico:
					<input type="text" id="farmaceutico" name="farmaceutico" size="30" maxLength="100" style="text-align:right;">
					&nbsp;&nbsp;
				<%}%>
				<%if(cdo.getColValue("APL_DESC_GLOBAL_POS").equals("S")){%>
				&nbsp;&nbsp;
				Descuento General:
				<select id="descuento" name="descuento" class="Text10">
				<option value="">- Seleccione -</option>
				<%
				for(int i=0;i<alDesc.size();i++){
					CommonDataObject cd = (CommonDataObject) alDesc.get(i);
				%>
				<option value="<%=cd.getColValue("id")%>" title = "<%=cd.getColValue("titulo")%>" data-es_empleado="<%=cd.getColValue("desc_empl")%>" data-valor="<%=cd.getColValue("valor")%>" data-es_desc_global="<%=cd.getColValue("es_desc_global")%>"><%=cd.getColValue("descripcion")%></option>
				<%}%>
				</select>
				<input type="button" id="btnDesc" name = "btnClte" value = "Aplicar" onClick="javascript:setDesc();">
				<%}%>
				</td></tr></table></td>
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
