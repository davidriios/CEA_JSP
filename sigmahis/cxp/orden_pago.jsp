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
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr"/>
<jsp:useBean id="OrdPago" scope="session" class="issi.cxp.OrdenPago"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="htCtas" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCtas" scope="session" class="java.util.Vector"/>
<jsp:useBean id="vFac" scope="session" class="java.util.Vector"/>
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

int iconHeight = 24;
int iconWidth = 24;
ArrayList al = new ArrayList();
String sql = "", key = "";
String mode = request.getParameter("mode");
String num_orden_pago = request.getParameter("num_orden_pago");
String anio = request.getParameter("anio");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
boolean viewMode = false;
String fecha = request.getParameter("fecha");
String cDateTime=CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if(fecha == null) fecha = cDateTime.substring(0,10);
if(anio == null) anio = cDateTime.substring(6,10);
if(fg==null) fg = "mat_paciente";
if(fp==null) fp = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	OP = new CommonDataObject();
	OrdPago = new OrdenPago();
	if (mode.equalsIgnoreCase("add")){

		num_orden_pago = "0";
		OP.addColValue("fecha_solicitud", fecha);
		OP.addColValue("num_orden_pago", num_orden_pago);
		OP.addColValue("user_creacion", (String) session.getAttribute("_userName"));
		OP.addColValue("fecha_creacion", cDateTime);
		OP.addColValue("anio", anio);
		if(fg!=null && fg.equals("PM")) OP.addColValue("cod_tipo_orden_pago", "4");
		htCtas.clear();
		vCtas.clear();
		vFac.clear();
		OrdPago.getFactDet().clear();
		session.removeAttribute("OrdPago");


	} else {
		if (num_orden_pago == null) throw new Exception("Orden de Pago no es válida. Por favor intente nuevamente!");

		if (change==null){

		htCtas.clear();
		vCtas.clear();
		vFac.clear();
		OrdPago.getFactDet().clear();
			/*
			encabezado
			*/
			sql="select a.cod_compania, a.anio, a.num_orden_pago, to_char(a.fecha_solicitud, 'dd/mm/yyyy') fecha_solicitud, a.estado, decode(a.estado,'P','PENDIENTE','A', 'APROBADO','R','RECHAZADO','N','ANULADO',a.estado) as estado_desc, a.nom_beneficiario, decode(a.generado,'H',nvl((select reg_medico from tbl_adm_medico where codigo=a.cod_medico),a.num_id_beneficiario),nvl(a.num_id_beneficiario, ' ')) as num_id_beneficiario, a.user_creacion, a.cod_tipo_orden_pago, a.monto, a.observacion, a.doc_fuente, to_char(a.fecha_nacimiento_paciente, 'dd/mm/yyyy') fecha_nacimiento_paciente, a.cod_paciente, a.cod_medico, a.cod_hacienda, a.provincia_empleado, a.sigla_empleado, a.tomo_empleado, a.asiento_empleado, a.cod_unidad_ejecutora, a.cod_provedor, a.compania_prov, a.cod_empresa, a.cod_compania_empleado, a.cod_autorizacion, a.cheque_girado, a.tipo_orden, a.solicitado_por, a.admision, a.ruc, a.dv, a.hacer, a.telepago, a.ach, a.beneficiario2, a.cod_banco, a.cuenta_banco, a.codigo_aux, a.tipo_persona, a.anio_doc_fuente, a.cod_concepto,to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')as fecha_creacion from tbl_cxp_orden_de_pago a where a.cod_compania = "+(String) session.getAttribute("_companyId") + " and a.num_orden_pago = "+num_orden_pago+" and a.anio = "+anio;
			OP = SQLMgr.getData(sql);

			sql="select a.renglon, a.anio, a.num_orden_pago, a.cod_compania, a.num_factura, a.monto_a_pagar, a.cg_1_cta1, a.cg_1_cta2, a.cg_1_cta3, a.cg_1_cta4, a.cg_1_cta5, a.cg_1_cta6, a.descripcion, b.descripcion as cuenta_desc from tbl_cxp_detalle_orden_pago a, tbl_con_catalogo_gral b where a.cod_compania = "+(String) session.getAttribute("_companyId") + " and a.num_orden_pago = "+num_orden_pago + " and a.anio = " + anio + " and a.cod_compania = b.compania and a.cg_1_cta1 = b.cta1 and a.cg_1_cta2 = b.cta2 and a.cg_1_cta3 = b.cta3 and a.cg_1_cta4 = b.cta4 and a.cg_1_cta5 = b.cta5 and a.cg_1_cta6 = b.cta6";
			al = SQLMgr.getDataList(sql);
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);

				cdoDet.setKey(i);
				cdoDet.setAction("U");


				try {
					htCtas.put(cdoDet.getKey(),cdoDet);
					String ctas = cdoDet.getColValue("cg_1_cta1")+"_"+cdoDet.getColValue("cg_1_cta2")+"_"+cdoDet.getColValue("cg_1_cta3")+"_"+cdoDet.getColValue("cg_1_cta4")+"_"+cdoDet.getColValue("cg_1_cta5")+"_"+cdoDet.getColValue("cg_1_cta6");
					vCtas.add(ctas);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
	session.setAttribute("OP",OP);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();setTipoOrden();setSubTipoOrden();}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,200);}
function doSubmit(fname,baction){if(orden_pagoValidation()){setBAction(fname,baction);window.frames['itemFrame'].doSubmit();}}

function setTipoOrden(){
	var top = document.orden_pago.cod_tipo_orden_pago.value;
	if(top == '1' || top == '2') document.orden_pago.tipo_orden.value = 'O';
	<%if(mode.equals("add")){%>
	clearValues();
	<%}%>
}

function selOtros(){
	var top = document.orden_pago.cod_tipo_orden_pago.value;
	var tipo = document.orden_pago.tipo_orden.value;
	var sub_tipo = document.orden_pago.tipo_orden_2.value;
	if(top == '1') tipo = 'M';
	else if(top == '2') tipo = 'PR';
	else if(top == '4') tipo = 'PM';
	if(window.frames['itemFrame'].chkCeroRegisters(false))CBMSG.alert('Existen detalles de Orden de Pago, no se permite cambiar de Beneficiario!');
	else abrir_ventana1('../common/search_beneficiario.jsp?fp=orden_pago&flag_tipo='+tipo+'&sub_tipo='+sub_tipo);
}

function setPacCon(){
	var to = document.orden_pago.tipo_orden.value;
	document.getElementById("_paciente").style.display = 'none';
	document.getElementById("_contrato").style.display = 'none';
	document.getElementById("_pac").style.display = 'none';
	document.getElementById("_con").style.display = 'none';
	if(to == 'P'){
		document.getElementById("_paciente").style.display = '';
		document.getElementById("_pac").style.display = '';
	} else if(to == 'C'){
		document.getElementById("_contrato").style.display = '';
		document.getElementById("_con").style.display = '';
	}
}

function setTrans(){
	if(document.orden_pago.chk_transf.checked){
		document.getElementById("_trans").style.display = '';
	} else {
		document.getElementById("_trans").style.display = 'none';
	}
}

function setReadOnly(){
	var top = document.orden_pago.cod_tipo_orden_pago.value;
	var tipo = document.orden_pago.tipo_orden.value;
	var truefalse = true;
	if(top == '1' || top == '2') document.orden_pago.tipo_orden.value = 'O';
	clearValues();

	if(top == '3' && tipo == 'O') truefalse = false;

	document.orden_pago.num_id_beneficiario.readOnly = truefalse;
	document.orden_pago.nom_beneficiario.readOnly = truefalse;
	document.orden_pago.ruc.readOnly = truefalse;
	document.orden_pago.dv.readOnly = truefalse;
}

function clearValues(){
	document.orden_pago.num_id_beneficiario.value = '';
	document.orden_pago.nom_beneficiario.value = '';
	document.orden_pago.ruc.value = '';
	document.orden_pago.dv.value = '';
	document.orden_pago.tipo_persona.value = '';
	document.orden_pago.cod_paciente.value = '';
	document.orden_pago.pac_provincia.value = '';
	document.orden_pago.pac_sigla.value = '';
	document.orden_pago.pac_tomo.value = '';
	document.orden_pago.pac_asiento.value = '';	
}

function setSubTipoOrden(){
var tipo_orden = document.orden_pago.cod_tipo_orden_pago.value;
if(tipo_orden=='4'){
	document.getElementById("tipo_orden_2").style.display='';
	document.getElementById("tipo_orden").style.display='none';
} else {
	document.getElementById("tipo_orden_2").style.display='none';
	document.getElementById("tipo_orden").style.display='';
}
}

function addFacturas(){
	var num_orden = document.orden_pago.num_orden_pago.value;
	var anio = document.orden_pago.anio.value;
	<%if(mode.equals("add")){%>
	abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=orden_pago');
	<%} else if(mode.equals("edit")||mode.equals("view")){%>
	abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=orden_pago&anio='+anio+'&num_orden_pago='+num_orden+'&mode=<%=mode%>');
	<%}%>
}

function selBanco(){
	abrir_ventana1('../common/search_banco.jsp?fp=orden_pago');
}
function selCuentaBancaria(){
	var cod_banco = document.orden_pago.cod_banco.value;
	if(cod_banco=='') CBMSG.alert('Seleccione Banco!');
	else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=orden_pago&cod_banco='+cod_banco);
}

//Used by itemFrame
function _printOrder(){
	var noOrder = '<%=num_orden_pago%>';
	var curCompany = '<%=(String) session.getAttribute("_companyId")%>';
	var orderYear = '<%=anio%>';
	abrir_ventana('../cxp/print_orden_pago.jsp?noOrder='+noOrder+'&curCompany='+curCompany+'&orderYear='+orderYear);
	//console.log(noOrder+ " "+ curCompany+ " "+ orderYear);
}
function chkType(){if(window.frames['itemFrame'].chkCeroRegisters(false)){CBMSG.alert('Existen detalles de Orden de Pago, no se permite cambiar de Tipo de Orden!');document.orden_pago.cod_tipo_orden_pago.blur();}}
function viewCheque(){abrir_ventana1('../cxp/cheque.jsp?fg=CSOP&anio=<%=anio%>&num_orden_pago=<%=num_orden_pago%>&mode=view');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">
		<label id="optDesc" class="TextInfo Text10">&nbsp;</label>
		&nbsp;
		<% if (!mode.equalsIgnoreCase("add")) { %>
		<img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir Orden Pago')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:_printOrder()">
		<% } %>
	</td>
</tr>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("orden_pago",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("nuevo","S")%>
<%//=fb.hidden("",OP.getColValue(""))%>
<%=fb.hidden("cta1","")%>
<%=fb.hidden("cta2","")%>
<%=fb.hidden("cta3","")%>
<%=fb.hidden("cta4","")%>
<%=fb.hidden("cta5","")%>
<%=fb.hidden("cta6","")%>
<%=fb.hidden("ctaDesc","")%>
		<tr class="TextPanel">
			<td colspan="6"><cellbytelabel>Orden de Pago</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel>Orden No</cellbytelabel>.</td>
			<td width="30%"><%=fb.intBox("anio",OP.getColValue("anio"),true,false,true,6,"Text10",null,"")%><%=fb.intBox("num_orden_pago",OP.getColValue("num_orden_pago"),true,false,true,10,"Text10",null,"")%></td>
			<td width="10%" align="right"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="15%"><%=viewMode?OP.getColValue("estado_desc"):fb.select("estado","P=Pendiente",OP.getColValue("estado"),false,false,0,"Text10",null,"")%></td>
			<td width="10%" align="right"><cellbytelabel>Fecha</cellbytelabel></td>
			<td width="20%"><%=fb.textBox("fecha_solicitud",OP.getColValue("fecha_solicitud"),true,false,true,12,"Text10",null,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><!--Conceptos MEF--></td>
			<td><%=fb.hidden("cod_concepto","")%><%//=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_con_conceptos order by codigo","cod_concepto",OP.getColValue("cod_concepto"),false,false,0,"Text10","","")%></td>
			<td align="right"><cellbytelabel>Tipo de Orden</cellbytelabel></td>
			<%
			StringBuffer sbSql = new StringBuffer();
			sbSql.append("select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in ");
			if(fg.equals("PM")) sbSql.append("(4)");
			else {
				sbSql.append("(select column_value  from table( select split((select get_sec_comp_param(");
				sbSql.append((String) session.getAttribute("_companyId"));
				sbSql.append(",'CXP_TIPO_ORDEN') from dual),',') from dual  )) and cod_tipo_orden_pago != 4");
			}
			sbSql.append(" order by cod_tipo_orden_pago");
			%>
			<td><%=fb.select(ConMgr.getConnection(),sbSql.toString(),"cod_tipo_orden_pago",OP.getColValue("cod_tipo_orden_pago"),false,false,0,"Text10","","onFocus=\"javascript:chkType();\" onChange=\"javascript:clearValues();setReadOnly();setSubTipoOrden();\"")%></td>
 			<td align="right"><cellbytelabel>Pago Otros</cellbytelabel></td>
			<td>
			
			<%=fb.select("tipo_orden","E=Empresa,P=Paciente,L=Liquidacion,D=Dividendo,O=Otros,C=Contratos,U=Empleados",OP.getColValue("tipo_orden"),false,false,false,0,"Text10","","onChange=\"javascript:setTipoOrden();setPacCon();setReadOnly();\"")%>
			<%=fb.select("tipo_orden_2","E=Empresa,B=Beneficiario,M=Medico,S=Sociedad Medica,C=Corredor",OP.getColValue("tipo_orden"),false,false,false,0,"Text10","display:none","onChange=\"javascript:setTipoOrden();setPacCon();setReadOnly();\"")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Cod. Econ. y Fin</cellbytelabel>.</td>
			<td colspan="3"><%=fb.select(ConMgr.getConnection(),"select cod_hacienda, descripcion, cod_hacienda from tbl_cxp_clasif_hacienda order by 1","cod_hacienda",OP.getColValue("cod_hacienda"),false,false,0,"Text10","","")%></td>
			<td align="right"><label id="_paciente" style="display:none"><cellbytelabel>Paciente</cellbytelabel></label><label id="_contrato" style="display:none"><cellbytelabel>Contrato No</cellbytelabel>.</label></td>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0">
				<tr id="_pac" style="display:none">
					<td><%=fb.textBox("cod_paciente",OP.getColValue("cod_paciente"),false,false,true,2,"Text10",null,"")%><%=fb.textBox("pac_provincia",OP.getColValue("pac_provincia"),false,false,true,2,"Text10",null,"")%><%=fb.textBox("pac_sigla",OP.getColValue("pac_sigla"),false,false,true,2,"Text10",null,"")%><%=fb.textBox("pac_tomo",OP.getColValue("pac_tomo"),false,false,true,4,"Text10",null,"")%><%=fb.textBox("pac_asiento",OP.getColValue("pac_asiento"),false,false,true,4,"Text10",null,"")%></td>
				</tr>
				<tr id="_con" style="display:none">
					<td><%=fb.textBox("num_contrato",OP.getColValue("num_contrato"),false,false,true,15,"Text10",null,"")%><%=fb.button("buscarCon","...",false,viewMode,"Text10","","onClick=\"javascript:selOtros()\"")%></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>A Favor de</cellbytelabel></td>
			<td colspan="3">
				<%=fb.textBox("num_id_beneficiario",OP.getColValue("num_id_beneficiario"),true,false,true,10,"Text10",null,"onChange=\"javascrip:document.orden_pago.nuevo.value='S';\"")%>
				<%=fb.textBox("nom_beneficiario",OP.getColValue("nom_beneficiario"),true,false,true,80,"Text10",null,"")%>
				<%=fb.button("buscar","...",false, viewMode,"Text10","","onClick=\"javascript:selOtros()\"")%>
			</td>
			<td colspan="2"><%=fb.hidden("tipo_persona", OP.getColValue("tipo_persona"))%>R.U.C.<%=fb.textBox("ruc",OP.getColValue("ruc"),false,false,false,30,"Text10",null,"")%>D.V.<%=fb.textBox("dv",OP.getColValue("dv"),false,false,false,2,"Text10",null,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Otro Beneficiario (Caja Men., J. Direc.)</cellbytelabel></td>
			<td colspan="3"><%=fb.textBox("beneficiario2",OP.getColValue("beneficiario2"),false,false,false,80,"Text10",null,"")%></td>
			<td align="right"><cellbytelabel>Monto</cellbytelabel></td>
			<td><%=fb.decBox("monto",OP.getColValue("monto"),true,false,true,10,8.2,"Text10",null,"onFocus=\"this.select();\"","Monto",false,"")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Transf.<%=fb.checkbox("chk_transf","",false,false,"","","onClick=\"javascript:setTrans();\"")%></td>
			<td colspan="4">
				<table width="100%" cellpadding="0" cellspacing="0">
				<tr id="_trans" style="display:none">
					<td>
						<cellbytelabel>Banco</cellbytelabel>:<%//=fb.select(ConMgr.getConnection(),"select cod_banco, cod_banco||' - '||nombre from tbl_con_banco order by nombre","cod_tipo_orden_pago",OP.getColValue("cod_banco"),false,false,0,"Text10","","","","S")%><%=fb.textBox("cod_banco",OP.getColValue("cod_banco"),false,false,true,8,"Text10",null,"")%><%=fb.textBox("nombre_banco",OP.getColValue("nombre_banco"),false,false,true,40,"Text10",null,"")%><%=fb.button("buscarBanco","...",false, viewMode,"Text10","","onClick=\"javascript:selBanco()\"")%>
						Cta.:<%=fb.textBox("nombre_cuenta",OP.getColValue("nombre_cuenta"),false,false,true,40,"Text10",null,"")%><%=fb.button("buscarCuenta","...",false, viewMode,"Text10","","onClick=\"javascript:selCuentaBancaria()\"")%><%=fb.hidden("cuenta_banco", OP.getColValue("cuenta_banco"))%>
					</td>
				</tr>
				</table>
			</td>
			<td align="center"><%=(mode.trim().equals("view"))?fb.button("add_facturas","Facturas",false,false,"Text10","","onClick=\"javascript:addFacturas()\""):""%>
			<%=(mode.trim().equals("view"))?fb.button("view_cheque","CHEQUE",false,false,"","","onClick=\"javascript:viewCheque()\""):""%>
				</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Observaci&oacute;n:</td>
			<td colspan="3"><%=fb.textarea("observacion",OP.getColValue("observacion"),false,false,viewMode,70,2,300)%></td>
			<td colspan="2">Fecha    &nbsp;&nbsp;Creacion: <%=OP.getColValue("fecha_creacion")%><br>Usuario Creacion: <%=OP.getColValue("user_creacion")%></td>
		</tr>
		<tr>
			<td colspan="6"><iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../cxp/orden_pago_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&num_orden_pago=<%=num_orden_pago%>"></iframe></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="6" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",false,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript:doSubmit(this.form.name,this.value);\"")%>
				<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String tipo_orden_pago = request.getParameter("cod_tipo_orden_pago");
	String tipo_orden = request.getParameter("tipo_orden");
	String beneficiario = request.getParameter("num_id_beneficiario");
	if(tipo_orden_pago.equals("4")) tipo_orden = request.getParameter("tipo_orden_2");
	num_orden_pago = request.getParameter("num_orden_pago");
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function unload(){closeChild=false;}
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.opener.location = '<%=request.getContextPath()%>/cxp/orden_pago_list.jsp?fg=<%=fg%>';
	abrir_ventana2('<%=request.getContextPath()%>/cxp/ingreso_facturas.jsp?fp=orden_pago&num_orden_pago=<%=num_orden_pago%>&anio=<%=request.getParameter("anio")%>&fg=registro_orden_pago&tipo_orden=<%=tipo_orden%>&idBeneficiario=<%=beneficiario%>&cod_tipo_orden=<%=tipo_orden_pago%>');
<%
session.removeAttribute("OrdPago");
if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&tr=<%=tr%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&num_orden_pago=<%=num_orden_pago%>';
	///reg_sol_mat_pacientes.jsp?mode=view&id=1&anio=2009&tr=PAC_S
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
