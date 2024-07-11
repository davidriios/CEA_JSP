<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactCargoCliente"%>
<%@ page import="issi.facturacion.FactDetCargoCliente"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="FTransMgr" scope="page" class="issi.facturacion.FactCargoClienteMgr" />
<jsp:useBean id="OtroCargo" scope="session" class="issi.facturacion.FactCargoCliente" />
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargKey" scope="session" class="java.util.Hashtable" />
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
FTransMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
//FactCargoCliente OtroCargo = new FactCargoCliente();
FactCargoCliente resp = new FactCargoCliente();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String tt = request.getParameter("tipoTransaccion");
String codigo = request.getParameter("codigo");
String anio = request.getParameter("anio");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
String devol = request.getParameter("devol");
if(fg==null) fg = "xxx";
String fp = request.getParameter("fp");
if(fp==null) fp = "cargo_dev_oc";
if(devol==null) devol = "";
String fPage = request.getParameter("fPage");
if(fPage==null) fPage = "";
boolean viewMode = false;
int camaLastLineNo = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
int lineNo = 0;
if (tab == null) tab = "0";
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		fTranCarg.clear();
		fTranCargKey.clear();
		fTranComp.clear();
		fTranCompKey.clear();
		if(change==null){
			OtroCargo = new FactCargoCliente();
			session.setAttribute("OtroCargo",OtroCargo);
		}
		if(devol.equals("S")){
			sql = "select nvl(to_char(a.tipo_descuento), '') tipoDescuento, a.compania, a.anio, a.codigo, a.tipo_cliente tipoCliente, a.cliente, nvl(a.cliente2, nvl(a.cliente, '')) cliente2, a.tipo_transaccion tipoTransaccion, nvl(a.num_factura, '') numFactura, to_char(a.fecha, 'dd/mm/yyyy') fecha, nvl(to_char(a.no_cargo_appx), '') noCargoAppx, nvl(a.medico, '') medico, nvl(to_char(a.empresa), '') empresa, nvl(to_char(a.centro_servicio), '') centroServicio, nvl(a.sigla_emp, '') siglaEmp, nvl(to_char(a.tomo_emp), '') tomoEmp, nvl(to_char(a.asiento_emp), '') asientoEmp, nvl(to_char(a.subtotal), '') subtotal, nvl(to_char(a.itbm), '') itbm, nvl(to_char(a.total), '') total, nvl(a.tipo_cli_alq, '') tipoCliAlq, nvl(to_char(a.cia_contrato), '') ciaContrato, nvl(to_char(a.alquiler), '') alquiler, nvl(a.cliente_alq, '') clienteAlq, nvl(a.tipo_cta, '') tipoCta, nvl(to_char(a.anio_devol), '') anioDevol, nvl(to_char(a.codigo_devol), '') codigoDevol, nvl(a.mes_alq, '') mesAlq, nvl(to_char(a.anio_alq), '') anioAlq, nvl(to_char(a.descuento), '') descuento, b.nombre companiaDesc, c.descripcion tipoClienteDesc from tbl_fac_cargo_cliente a, tbl_sec_compania b, tbl_fac_tipo_cliente c where a.anio = " + anio + " and a.codigo = "+codigo+" and a.tipo_transaccion = 'C' and a.compania = " + (String) session.getAttribute("_companyId") +" /*and a.codigo_devol is null*/ and a.compania = b.codigo and a.compania = c.compania and a.tipo_cliente = c.codigo";
			System.out.println("SQL:\n"+sql);
			OtroCargo = (FactCargoCliente) sbb.getSingleRowBean(ConMgr.getConnection(),sql,FactCargoCliente.class);
			session.setAttribute("OtroCargo",OtroCargo);

			sql = "select a.*, a.cant-nvl(b.cantidad, 0) cantidad from (select a.tipo_detalle, nvl(a.tipo_servicio, '') tipo_servicio, nvl(to_char(a.cod_otro), '') cod_otro, nvl(to_char(a.inv_almacen), '') inv_almacen, nvl(to_char(a.inv_art_familia), '') inv_art_familia, nvl(to_char(a.inv_art_clase), '') inv_art_clase, nvl(to_char(a.inv_cod_articulo), '') inv_cod_articulo, nvl(a.act_secuencia, '') act_secuencia, a.cantidad cant, a.monto, nvl(a.descripcion, '') descripcion, nvl(to_char(a.desc_x_item), '') desc_x_item, nvl(to_char(a.descuento), '') descuento, nvl(to_char(a.itbm_x_item), '') itbm_x_item, decode(b.itbm, 'S', b.itbm, 'N') itbm, a.tipo_detalle ||'_'|| a.tipo_servicio ||'_'|| a.cod_otro ||'_'|| a.inv_almacen ||'_'|| a.inv_art_familia ||'_'|| a.inv_art_clase ||'_'|| a.inv_cod_articulo ||'_'|| a.act_secuencia key from tbl_fac_detc_cliente a, tbl_inv_articulo b where a.compania = " + (String) session.getAttribute("_companyId") + " and a.anio = " + anio + " and a.tipo_transaccion = 'C' and a.cargo = "+codigo+" and a.inv_art_familia = b.cod_flia(+) and a.inv_art_clase = b.cod_clase(+) and a.inv_cod_articulo = b.cod_articulo(+) and a.compania = b.compania(+) and nvl(b.estado, 'A') = 'A') a, (select c.tipo_detalle ||'_'|| c.tipo_servicio ||'_'|| c.cod_otro ||'_'|| c.inv_almacen ||'_'|| c.inv_art_familia ||'_'|| c.inv_art_clase ||'_'|| c.inv_cod_articulo ||'_'|| c.act_secuencia key, cantidad from (select   b.tipo_detalle, b.tipo_servicio, b.cod_otro, b.inv_almacen, b.inv_art_familia, b.inv_art_clase, b.inv_cod_articulo, b.act_secuencia, b.monto, b.descripcion, b.desc_x_item, b.itbm_x_item, sum (cantidad) cantidad from tbl_fac_cargo_cliente a, tbl_fac_detc_cliente b where a.compania = b.compania and a.codigo = b.cargo and a.tipo_transaccion = b.tipo_transaccion and a.anio = b.anio and a.compania = " + (String) session.getAttribute("_companyId") + " and a.anio_devol = " + anio + " and a.tipo_transaccion = 'D' and a.codigo_devol = "+codigo+" group by b.tipo_detalle, b.tipo_servicio, b.cod_otro, b.inv_almacen, b.inv_art_familia, b.inv_art_clase, b.inv_cod_articulo, b.act_secuencia, b.monto, b.descripcion, b.desc_x_item, b.itbm_x_item) c) b where a.key = b.key(+) and (a.cant - nvl (b.cantidad, 0)) > 0";

			System.out.println("sql detail:\n"+sql);

			al = SQLMgr.getDataList(sql);

			for(int i=0; i<al.size(); i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				FactDetCargoCliente det = new FactDetCargoCliente();

				det.setCodOtro(cdo.getColValue("cod_otro"));
				det.setDescripcion(cdo.getColValue("descripcion"));
				det.setMonto(cdo.getColValue("monto"));
				det.setTipoDetalle(cdo.getColValue("tipo_detalle"));
				if(fg.equals("xxx")) det.setTipoDetalle("O");
				det.setMontoRecargo("0");
				det.setCantidad(cdo.getColValue("cantidad"));
				det.setCantCargo(cdo.getColValue("cant"));

				det.setInvArtFamilia(cdo.getColValue("inv_art_familia"));
				det.setInvArtClase(cdo.getColValue("inv_art_clase"));
				det.setInvCodArticulo(cdo.getColValue("inv_cod_articulo"));
				det.setDisponible(cdo.getColValue(""));
				det.setActSecuencia(cdo.getColValue("act_secuencia"));
				det.setTipoServicio(cdo.getColValue("tipo_servicio"));
				det.setInvAlmacen(cdo.getColValue("inv_almacen"));
				det.setItbm(cdo.getColValue("itbm"));
				det.setDescuento(cdo.getColValue("descuento"));

				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					fTranCarg.put(key, det);
					//fTranCargKey.put(det.getTipoCargo()+"_"+det.getTrabajo(), key);
					//OtroCargo.getFTransDetail().add(det);
					//System.out.println("adding item "+key+" _ "+det.getTipoCargo()+"_"+det.getTrabajo());
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
	else if (mode.equalsIgnoreCase("view"))
	{
		if (codigo == null) throw new Exception("El Código de Cargo no es válido. Por favor intente nuevamente!");
		if (anio == null) throw new Exception("El A&ntilde;o de Cargo no es válido. Por favor intente nuevamente!");
		fTranCarg.clear();
		fTranCargKey.clear();
		fTranComp.clear();
		fTranCompKey.clear();
		if(change==null){
			OtroCargo = new FactCargoCliente();
			session.setAttribute("OtroCargo",OtroCargo);
		}

		viewMode = true;

		sql = "select nvl(to_char(a.tipo_descuento), ' ') tipoDescuento, a.compania, a.anio, a.codigo, a.tipo_cliente tipoCliente, a.cliente, nvl(a.cliente2, nvl(a.cliente, ' ')) cliente2, a.tipo_transaccion tipoTransaccion, nvl(a.num_factura, ' ') numFactura, to_char(a.fecha, 'dd/mm/yyyy') fecha, nvl(to_char(a.no_cargo_appx), ' ') noCargoAppx, nvl(a.medico, ' ') medico, nvl(to_char(a.empresa), ' ') empresa, nvl(to_char(a.centro_servicio), ' ') centroServicio, nvl(a.sigla_emp, ' ') siglaEmp, nvl(to_char(a.tomo_emp), ' ') tomoEmp, nvl(to_char(a.asiento_emp), ' ') asientoEmp, nvl(to_char(a.subtotal), ' ') subtotal, nvl(to_char(a.itbm), ' ') itbm, nvl(to_char(a.total), ' ') total, nvl(a.tipo_cli_alq, ' ') tipoCliAlq, nvl(to_char(a.cia_contrato), ' ') ciaContrato, nvl(to_char(a.alquiler), ' ') alquiler, nvl(a.cliente_alq, ' ') clienteAlq, nvl(a.tipo_cta, ' ') tipoCta, nvl(to_char(a.anio_devol), ' ') anioDevol, nvl(to_char(a.codigo_devol), ' ') codigoDevol, nvl(a.mes_alq, ' ') mesAlq, nvl(to_char(a.anio_alq), ' ') anioAlq, nvl(to_char(a.descuento), ' ') descuento, b.nombre companiaDesc, c.descripcion tipoClienteDesc, nvl(to_char(a.fecha_nacimiento, 'dd/mm/yyyy'), ' ') fechaNacimiento, nvl(to_char(a.codigo_paciente), ' ') codigoPaciente, nvl(to_char(a.aprobacion_hna), ' ') aprobacionHna, nvl(to_char(a.fecha_vencim, 'dd/mm/yyyy'), ' ') fechaVencim, nvl(a.diag_hna, ' ') diagHna, nvl(a.diag_hna2, ' ') diagHna2, nvl(a.diag_hna3, ' ') diagHna3, nvl(a.diag_hna4, ' ') diagHna4, nvl(to_char(a.visita), ' ') visita from tbl_fac_cargo_cliente a, tbl_sec_compania b, tbl_fac_tipo_cliente c where a.anio = " + anio + " and a.codigo = "+codigo+" and a.tipo_transaccion = '"+tt+"' and a.compania = " + (String) session.getAttribute("_companyId") +"/* and a.codigo_devol is null*/ and a.compania = b.codigo and a.compania = c.compania and a.tipo_cliente = c.codigo";
		System.out.println("SQL:\n"+sql);
		OtroCargo = (FactCargoCliente) sbb.getSingleRowBean(ConMgr.getConnection(),sql,FactCargoCliente.class);
		session.setAttribute("OtroCargo",OtroCargo);

		String cs = OtroCargo.getCentroServicio();
		String v_empresa = "";//OtroCargo.getEmpreCodigo();
		sql = "select a.tipo_detalle, nvl(a.tipo_servicio, ' ') tipo_servicio, nvl(to_char(a.cod_otro), ' ') cod_otro, nvl(to_char(a.inv_almacen), ' ') inv_almacen, nvl(to_char(a.inv_art_familia), ' ') inv_art_familia, nvl(to_char(a.inv_art_clase), ' ') inv_art_clase, nvl(to_char(a.inv_cod_articulo), ' ') inv_cod_articulo, nvl(a.act_secuencia, ' ') act_secuencia, a.cantidad, a.monto, nvl(a.descripcion, ' ') descripcion, nvl(to_char(a.desc_x_item), ' ') desc_x_item, nvl(to_char(a.descuento), '') descuento, nvl(to_char(a.itbm_x_item), ' ') itbm_x_item, decode(b.itbm, 'S', b.itbm, 'N') itbm from tbl_fac_detc_cliente a, tbl_inv_articulo b where a.compania = " + (String) session.getAttribute("_companyId") + " and a.compania = b.compania and a.anio = " + anio + " and a.tipo_transaccion = '"+tt+"' and a.cargo = "+codigo+" and a.inv_art_familia = b.cod_flia(+) and a.inv_art_clase = b.cod_clase(+) and a.inv_cod_articulo = b.cod_articulo(+) and b.estado(+) = 'A'";

		System.out.println("sql detail:\n"+sql);

		al = SQLMgr.getDataList(sql);

		for(int i=0; i<al.size(); i++){
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			FactDetCargoCliente det = new FactDetCargoCliente();
			System.out.println("cod_otro:"+cdo.getColValue("cod_otro"));
			det.setCodOtro(cdo.getColValue("cod_otro"));
			det.setDescripcion(cdo.getColValue("descripcion"));
			det.setMonto(cdo.getColValue("monto"));
			det.setTipoDetalle(cdo.getColValue("tipo_detalle"));
			if(fg.equals("xxx")) det.setTipoDetalle("O");
			det.setMontoRecargo("0");
			det.setCantidad(cdo.getColValue("cantidad"));
			det.setCantCargo(cdo.getColValue("cantidad"));

			det.setInvArtFamilia(cdo.getColValue("inv_art_familia"));
			det.setInvArtClase(cdo.getColValue("inv_art_clase"));
			det.setInvCodArticulo(cdo.getColValue("inv_cod_articulo"));
			det.setDisponible(cdo.getColValue(""));
			det.setActSecuencia(cdo.getColValue("act_secuencia"));
			det.setTipoServicio(cdo.getColValue("tipo_servicio"));
			det.setInvAlmacen(cdo.getColValue("inv_almacen"));
			det.setItbm(cdo.getColValue("itbm"));
			det.setDescuento(cdo.getColValue("descuento"));

			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;

			try {
				fTranCarg.put(key, det);
				//fTranCargKey.put(det.getTipoCargo()+"_"+det.getTrabajo(), key);
				//OtroCargo.getFTransDetail().add(det);
				//System.out.println("adding item "+key+" _ "+det.getTipoCargo()+"_"+det.getTrabajo());
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		}

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Facturación - '+document.title;

function removeItem(fName,k){
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue){
	document.forms[fName].baction.value = actionValue;
	window.frames['itemFrame'].doSubmit();
}

function showMedicoList(){
	abrir_ventana1('../common/search_medico.jsp?fp=cargo_dev');
}

function doAction(){
			if(document.form0.cob_tasa_gasnet.value=='S' && (document.form0.cod_empresa.value == '86' || document.form0.cod_empresa.value == '90149')){
				document.getElementById('pac_data').style.display='';
			}
	<%
	if((fg.equals("xxx") || fg.equals("yyy")) && devol.equals("S")){
	%>
	setDescValues(document.form0.desc.value);
	<%}%>

}

function selCia(){
	var fg = document.form0.fg.value;
	abrir_ventana1('../common/sel_compania.jsp?fp=cargo_dev_oc&mode=<%=mode%>&fg='+fg);
}

function selCliente(){
	var compania = document.form0.compania.value;
	var tipo_cliente = document.form0.tipo_cliente.value;
	var tipo_cliente_desc = document.form0.tipo_cliente_desc.value;
	var urlVal = "";
	var fg = '';
	if (tipo_cliente_desc=='EMPLEADO') fg = '1';
	else if(tipo_cliente_desc=='EMPRESA' || tipo_cliente=='12') fg = '2';
	else if(tipo_cliente_desc=='MEDICO' || tipo_cliente=='13') fg = '3';
	else if(tipo_cliente_desc=='PARTICULAR') fg = '8';
	else if(tipo_cliente=='5' && compania=='1') fg = '4';
	else if(tipo_cliente=='6' && compania=='1') fg = '5';
	else if(tipo_cliente=='7' && compania=='1'){
		fg = '6';
		urlVal = '&compania = ' + compania;
	}	else if(tipo_cliente=='8' && compania=='1') fg = '';
	else if(tipo_cliente_desc=='CLIENTE-ALQUILER') fg = '7';
	else if(tipo_cliente=='12') fg = '2';
	else if(tipo_cliente=='14') fg = '9';
	else if(tipo_cliente=='16') fg = '10';

	abrir_ventana1('../common/sel_cliente.jsp?fp=cargo_dev_oc&mode=<%=mode%>&fg='+fg+'&compania='+compania);
}

function chkDocNo(obj)
{
	var tipo_transaccion	= document.form0.tipoTransaccion.value;

	if(tipo_transaccion=='C'){
		if(hasDBData('<%=request.getContextPath()%>','tbl_fac_cargo_cliente','no_cargo_appx=\''+obj.value+'\' and compania=<%=(String) session.getAttribute("_companyId")%>','')){
			CBMSG.warning('El número de documento YA EXISTE!');
			obj.value = '';
			obj.focus();
		}
	}
}

function selEmpresa(){
	abrir_ventana1('../common/search_empresa.jsp?fp=cargo_dev');
}

function setDescValues(i){
	if(i!=-1){
		var valor 					= eval('document.form0.valor'+i).value;
		var tipo_valor 			= eval('document.form0.tipo_valor'+i).value;
		var tipo_desc 			= eval('document.form0.tipo_desc'+i).value;
		var desc_tipo_desc	= eval('document.form0.desc_tipo_desc'+i).value;
		document.form0.valor.value = valor;
		document.form0.tipo_valor.value = tipo_valor;
		document.form0.tipo_desc.value = tipo_desc;
		if(valor=='' && tipo_valor == ''){
			document.form0.valor.readOnly=false;
			document.form0.tipo_valor.readOnly=false;
			//document.form0.descuento.readOnly=false;
		} else {
			document.form0.valor.readOnly=true;
			document.form0.tipo_valor.readOnly=true;
			document.form0.descuento.readOnly=true;
		}
	} else {
		document.form0.valor.value = '';
		document.form0.tipo_valor.value = '';
		document.form0.tipo_desc.value = '';
		document.form0.valor.readOnly=true;
		document.form0.tipo_valor.readOnly=true;
		document.form0.descuento.readOnly=true;
	}
	setDescuento();
}

function setDescuento(){
	window.frames['itemFrame'].calc();
	if(document.form0.tipo_valor=='P') window.frames['itemFrame'].changeReadOnly(true);
	else window.frames['itemFrame'].changeReadOnly(false);
}

function selPaciente(){
	abrir_ventana1('../common/sel_paciente.jsp?fp=cargo_oc&fg=cargo_oc');
}

function selDiagnostico(id){
	abrir_ventana1('../common/search_diagnostico.jsp?fp=cargo_oc&fg=cargo_oc&id='+id);
}

function selMedico(){
	abrir_ventana1('../common/search_medico.jsp?fp=cargo_oc&fg=cargo_oc');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("errCode","")%>
				<%=fb.hidden("errMsg","")%>
				<%=fb.hidden("codigoPaciente","")%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("clearHT","")%>
				<%=fb.hidden("fPage",fPage)%>
				<%=fb.hidden("icompania",OtroCargo.getICompania())%>
				<%=fb.hidden("provincia_emp",OtroCargo.getProvinciaEmp())%>
				<%=fb.hidden("sigla_emp",OtroCargo.getSiglaEmp())%>
				<%=fb.hidden("tomo_emp",OtroCargo.getTomoEmp())%>
				<%=fb.hidden("asiento_emp",OtroCargo.getAsientoEmp())%>
				<%=fb.hidden("cod_empresa",OtroCargo.getEmpresa())%>
				<%=fb.hidden("cod_medico",OtroCargo.getMedico())%>
				<%=fb.hidden("centro_servicio",OtroCargo.getCentroServicio())%>
				<%=fb.hidden("contrato",OtroCargo.getAlquiler())%>
				<%=fb.hidden("particular",OtroCargo.getParticular())%>

				<%=fb.hidden("tipo_cli_alq",OtroCargo.getTipoCliAlq())%>
				<%=fb.hidden("cia_contrato",OtroCargo.getCiaContrato())%>
				<%=fb.hidden("cob_tasa_gasnet","")%>
				<%=fb.hidden("codigo",OtroCargo.getCodigo())%>
				<%=fb.hidden("anio",OtroCargo.getAnio())%>
				<%=fb.hidden("cliente_alq",OtroCargo.getClienteAlq())%>

				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Datos del Cliente</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
								<td colspan="2">
								<%=fb.textBox("compania",OtroCargo.getCompania(),true,false,true,10)%>
								<%=fb.textBox("compania_desc",OtroCargo.getCompaniaDesc(),false,false,true,50)%>
								<%=fb.button("btnCia","...",true,(devol.equals("S")?true:viewMode),null,null,"onClick=\"javascript:selCia()\"")%>
								</td>
								<td></td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Tipo Cliente</cellbytelabel></td>
								<td colspan="2">
								<%=fb.textBox("tipo_cliente",OtroCargo.getTipoCliente(),true,false,true,10)%>
								<%=fb.textBox("tipo_cliente_desc",OtroCargo.getTipoClienteDesc(),false,false,true,50)%>
								</td>
								<td></td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Cliente</cellbytelabel></td>
								<td>
								<%=fb.textBox("cliente",OtroCargo.getCliente(),false,false,true,50)%>
								<%=fb.button("btnClte","...",true,(devol.equals("S")?true:viewMode),null,null,"onClick=\"javascript:selCliente()\"")%>
								</td>
								<td colspan="2"><cellbytelabel>Cargo a favor de</cellbytelabel>:
								<%=fb.textBox("cliente2",OtroCargo.getCliente2(),true,false,false,50)%>
								</td>
							</tr>
							<tr id="pac_data" class="TextRow01" style="display:none">
								<td align="right"><cellbytelabel>Paciente</cellbytelabel></td>
								<td colspan="3">
								<%=fb.hidden("gasnet_pac_id",OtroCargo.getGasnetPacId())%>
								<%=fb.textBox("fecha_nac",OtroCargo.getFechaNac(),false,false,true,10)%>
								<%=fb.textBox("codigo_pac",OtroCargo.getCodigoPac(),false,false,true,5)%>
								<%=fb.textBox("nombre_paciente",OtroCargo.getNombrePaciente(),false,false,true,50)%>
								<cellbytelabel>Admisi&oacute;n</cellbytelabel>
								<%=fb.textBox("admision",OtroCargo.getAdmision(),false,false,true,5)%>
								<%=fb.button("btnPte","...",true,viewMode,null,null,"onClick=\"javascript:selPaciente()\"")%>
								</td>
							</tr>
							<%if(fg.equals("www")){%>
							<tr class="TextRow01">
								<td align="right">Paciente</td>
								<td>
								<%=fb.hidden("nombre_paciente",OtroCargo.getNombrePaciente())%>
								<%=fb.textBox("fecha_nacimiento",OtroCargo.getFechaNacimiento(),false,false,true,10)%>
								<%=fb.textBox("codigo_paciente",OtroCargo.getCodigoPaciente(),false,false,true,5)%>
								</td>
								<td>
								<cellbytelabel>M&eacute;dico</cellbytelabel>
								</td>
								<td>
								<%=fb.textBox("medico_receta",OtroCargo.getMedicoReceta(),false,false,true,5)%>
								<%=fb.textBox("medico_receta_desc",OtroCargo.getMedicoRecetaDesc(),false,false,true,50)%>
								<%=fb.button("btnMdco","...",true,viewMode,null,null,"onClick=\"javascript:selMedico()\"")%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Aprobaci&oacute;n HNA</cellbytelabel></td>
								<td colspan="3">
								<%=fb.intBox("aprobacion_hna",OtroCargo.getAprobacionHna(),true,false,false,10)%>
								<cellbytelabel>Vence</cellbytelabel>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="fecha_vencim" />
									<jsp:param name="valueOfTBox1" value="<%=OtroCargo.getFechaVencim()%>" />
									<jsp:param name="fieldClass" value="Text10" />
									<jsp:param name="buttonClass" value="Text10" />
									<jsp:param name="format" value="dd/mm/yyyy" />
								</jsp:include>
								<cellbytelabel>L&iacute;mite</cellbytelabel>
								<%=fb.textBox("limite",OtroCargo.getLimite(),false,false,false,5)%>
								<cellbytelabel>Visita</cellbytelabel>
								<%=fb.textBox("visita",OtroCargo.getVisita(),false,false,false,5)%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Diagn&oacute;sticos</cellbytelabel></td>
								<td colspan="3">
								<cellbytelabel>HNA1</cellbytelabel>
								<%=fb.textBox("diag_hna1",OtroCargo.getDiagHna(),false,false,false,5)%>
								<%=fb.button("btnDiag1","...",true,viewMode,null,null,"onClick=\"javascript:selDiagnostico(1)\"")%>
								<cellbytelabel>HNA2</cellbytelabel>
								<%=fb.textBox("diag_hna2",OtroCargo.getDiagHna2(),false,false,false,5)%>
								<%=fb.button("btnDiag2","...",true,viewMode,null,null,"onClick=\"javascript:selDiagnostico(2)\"")%>
								<cellbytelabel>HNA3</cellbytelabel>
								<%=fb.textBox("diag_hna3",OtroCargo.getDiagHna3(),false,false,false,5)%>
								<%=fb.button("btnDiag3","...",true,viewMode,null,null,"onClick=\"javascript:selDiagnostico(3)\"")%>
								<cellbytelabel>HNA4</cellbytelabel>
								<%=fb.textBox("diag_hna4",OtroCargo.getDiagHna4(),false,false,false,5)%>
								<%=fb.button("btnDiag4","...",true,viewMode,null,null,"onClick=\"javascript:selDiagnostico(4)\"")%>
								</td>
							</tr>
							<%}%>
						</table>
					</td>
				</tr>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Transacci&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<%
				sql = "select rownum-1 codigo, descripcion, codigo tipo_desc, valor, tipo_valor from tbl_fac_tipo_descuento where codigo in (1, 4) and compania = "+(String) session.getAttribute("_companyId") + " order by codigo";
				ArrayList alDesc = new ArrayList();
				alDesc = SQLMgr.getDataList(sql);
				for(int i=0; i<alDesc.size(); i++){
					CommonDataObject cdoDesc = (CommonDataObject) alDesc.get(i);
				%>
					<%=fb.hidden("valor"+i,cdoDesc.getColValue("valor"))%>
					<%=fb.hidden("tipo_valor"+i,cdoDesc.getColValue("tipo_valor"))%>
					<%=fb.hidden("tipo_desc"+i,cdoDesc.getColValue("tipo_desc"))%>
					<%=fb.hidden("desc_tipo_desc"+i,cdoDesc.getColValue("descripcion"))%>
				<%
				}
				%>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Tipo Transacci&oacute;n</cellbytelabel></td>
							<td width="15%">
							<%if(mode.equalsIgnoreCase("add") && devol.equals("S")){%>
							<%=fb.select("tipoTransaccion","D=DEVOLUCION",OtroCargo.getTipoTransaccion(), false, viewMode, 0)%>
							<%} else {%>
							<%=fb.select("tipoTransaccion","C=CARGO",OtroCargo.getTipoTransaccion(), false, viewMode, 0)%>
							<%}%>
							</td>
							<td width="15%" align="right"><cellbytelabel>Fecha del Cargo</cellbytelabel></td>
							<td width="10%"><%=fb.textBox("fecha",cDateTime,false,false,true,10)%></td>
							<td width="10%" align="right">Creaci&oacute;n</td>
							<td width="10%"><%=fb.textBox("fechaCreacion",cDateTime,false,false,true,10)%></td>
							<td width="20%"><cellbytelabel>Descuento</cellbytelabel>
							<%
							if(fg.equals("xxx") || fg.equals("yyy")){
							sql = "select rownum -2 codigo, a.descripcion from (select '- Seleccione -' descripcion from dual union select descripcion from tbl_fac_tipo_descuento where codigo in (1, 4) and compania = "+(String) session.getAttribute("_companyId")+") a";
							String tipoDesc = "";
							if(OtroCargo.getTipoDescuento()!=null && OtroCargo.getTipoDescuento().equals("1")) tipoDesc = "0";
							else if(OtroCargo.getTipoDescuento()!=null && OtroCargo.getTipoDescuento().equals("4")) tipoDesc = "1";
							%>
							<%=fb.select(ConMgr.getConnection(), sql, "desc",tipoDesc, false, viewMode, 0, "", "", "onChange=\"javascript:setDescValues(this.value)\"")%>
							<%} else if(fg.equals("www")){%>
							<%=fb.decBox("descuento",OtroCargo.getDescuento(),false,false,true,10, 10.2, null, null, "")%>
							<%}%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Factura No</cellbytelabel>.</td>
							<td><%=fb.intBox("num_factura",OtroCargo.getNumFactura(),false,false,true,4)%></td>
							<td align="right"><cellbytelabel>No. Documento</cellbytelabel></td>
							<td><%=fb.textBox("no_cargo_appx",OtroCargo.getNoCargoAppx(),false,viewMode,viewMode,10, "", "", "onChange=\"javascrip:chkDocNo(this);\"")%></td>
							<td align="right"><cellbytelabel>Modificaci&oacute;n</cellbytelabel></td>
							<td><%=fb.textBox("fechaModificacion",mTime,false,false,true,10)%></td>
							<td>
							<%
							if(fg.equals("xxx") || fg.equals("yyy")){
							%>
							<%=fb.decBox("valor","",false,false,true,10, 10.2, null, null, "onChange=\"javascript:setDescuento()\"")%>
							<%=fb.select("tipo_valor","P=%,M=$","", false, viewMode, 0, "", "", "onChange=\"javascript:setDescuento()\"")%>
							<%=fb.decBox("descuento",OtroCargo.getDescuento(),false,false,true,10, 10.2, null, null, "")%>
							<%=fb.hidden("tipo_desc",OtroCargo.getTipoDescuento())%>
							<%}%>
							</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../facturacion/reg_cargo_dev_det_oc.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&fPage=<%=fPage%>&devol=<%=devol%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02" align="center">
					<td align="center"><cellbytelabel>Tipo de Cuenta</cellbytelabel>&nbsp;<%=fb.select("tipo_cta","CO=CONTADO,CR=CREDITO","", false, viewMode, 0)%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",false,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",true,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
			</td>
		</tr>
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
	String errCode = "";
	String errMsg = "";
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
		/*
		codigo = OtroCargo.getCodigo();
		noAdmision = OtroCargo.getAdmiSecuencia();
		pacienteId = OtroCargo.getPacienteId();
		tt = OtroCargo.getTipoTransaccion();
		*/
	}
	session.removeAttribute("fTranCarg");
	session.removeAttribute("fTranCargKey");
	session.removeAttribute("OtroCargo");
	session.removeAttribute("fTranComp");
	session.removeAttribute("fTranCompKey");
	session.removeAttribute("fTranDComp");

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
<%
	if (saveOption.equalsIgnoreCase("N")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('viewMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
		System.out.println("fPage="+fPage);
		System.out.println("fg="+fg);
		if(!fPage.equals("general_page")){
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/list_cargo_dev_oc.jsp?fg=<%=fg%>';
<%
		}
%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fg=<%=fg%>&fPage=<%=fPage%>';
}

function viewMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&codigo=<%=codigo%>&tt=<%=tt%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
