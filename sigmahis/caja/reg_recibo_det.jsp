<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="issi.caja.DetallePago"%>
<%@ page import="issi.caja.DetalleRecibos"%>
<%@ page import="issi.caja.DetalleBilletes"%>
<%@ page import="issi.caja.DetalleTransFormaPagos"%>
<%@ page import="java.util.ArrayList"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iPago" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iBill" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="TPMgr" scope="page" class="issi.caja.TransaccionPagoMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>

<%
/**
================================================================================
PACIENTE		cja20010
EMPRESA			cja20020
OTROS				cja20040pru
ALQUILER		cja20040_alq
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
TPMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String tipoCliente = request.getParameter("tipoCliente");
String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String change = request.getParameter("change");
String type = request.getParameter("type");
String fp = request.getParameter("fp");
String appDet= "N";
try {appDet =java.util.ResourceBundle.getBundle("issi").getString("appDet");}catch(Exception e){ appDet = "N";}
String saldoFact= "N";
try {saldoFact =java.util.ResourceBundle.getBundle("issi").getString("saldoFact");}catch(Exception e){ saldoFact = "N";}
String distAut ="";
String key = "";
int lastLineNo = 0;

if (fg == null) fg = "";
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (type == null) type = "";
if (fp == null) fp = "";

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;

ArrayList alTT = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn from tbl_cja_tipo_transaccion order by descripcion",CommonDataObject.class);
	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CJA_DIST_AUT'),'N') as dist_aut from dual");
	CommonDataObject cdoTA = (CommonDataObject) SQLMgr.getData(sbSql.toString());
	distAut = cdoTA.getColValue("dist_aut");

if (request.getMethod().equalsIgnoreCase("GET"))
{


	if (codigo != null && !codigo.trim().equals(""))
	{
		if (change == null)
		{
			iDoc.clear();
			vDoc.clear();
			if (!fg.equalsIgnoreCase("A")||appDet.trim().equals("S")){
				sbSql = new StringBuffer();
				sbSql.append("select a.pago_por as docType, decode(a.pago_por,'D',''||a.admi_secuencia,'F',fac_codigo,'R',''||a.cod_rem) as docNo, decode(a.admi_secuencia,null,' ',''||a.admi_secuencia) as admiSecuencia, decode(a.cod_rem,null,' ',''||a.cod_rem) as codRem, nvl(a.fac_codigo,' ') as facCodigo");
				sbSql.append(", (select nvl(sum(nvl(monto,0)),0) from tbl_cja_distribuir_pago where compania = a.compania and tran_anio = a.tran_anio and codigo_transaccion = a.codigo_transaccion and secuencia_pago = a.secuencia_pago) as montoDistribuido, a.estatus, a.pago_por as pagoPor, a.tipo_transaccion as tipoTransaccion");
				sbSql.append(", nvl(to_char(a.doc_fecha,'dd/mm/yyyy'),' ') as fecha, to_char(nvl(a.doc_fecha,b.fecha),'mm/yyyy') as saldoA, nvl(a.doc_a_nombre,' ') as nombrePaciente, nvl(a.doc_monto_total,0) as montoTotal, nvl(a.doc_monto_debito,0) as debito, nvl(a.doc_monto_credito,0) as credito,  a.monto, a.monto monto1, nvl(a.desc_pronto_pago,0) as descProntoPago,");
				if(saldoFact.trim().equals("S"))sbSql.append(" fn_cja_saldo_fact(b.tipo_cliente,a.compania,a.fac_codigo,nvl((select f.grang_total from tbl_fac_factura f where f.compania =a.compania and f.codigo=a.fac_codigo),0)) ");
				else sbSql.append(" nvl(a.doc_monto_deuda,0) ");
				sbSql.append(" as montoDeuda,nvl(a.doc_monto_deuda,0) - nvl(a.desc_pronto_pago,0) - a.monto ");
				sbSql.append(" as saldo,a.tran_anio tranAnio,a.compania,a.codigo_transaccion CodigoTransaccion, a.secuencia_pago secuenciaPago,nvl(a.anulada,'N')anulada,nvl(b.rec_status,'A') recStatus,nvl(a.distribuir_aut,'N') as distribuir ");
				sbSql.append(" from tbl_cja_detalle_pago a, tbl_cja_transaccion_pago b where a.compania = ");
				sbSql.append(compania);
				sbSql.append(" and a.tran_anio = ");
				sbSql.append(anio);
				sbSql.append(" and a.codigo_transaccion = ");
				sbSql.append(codigo);
				sbSql.append(" and a.compania = b.compania and a.tran_anio = b.anio and a.codigo_transaccion = b.codigo order by a.secuencia_pago");
				System.out.println("S Q L =\n"+sbSql);
				if(!codigo.trim().equals("")&&!codigo.trim().equals("0"))al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),DetallePago.class);
				lastLineNo = al.size();
				for (int i=1; i<=al.size(); i++)
				{
					DetallePago dp = (DetallePago) al.get(i - 1);

					if (i < 10) key = "00" + i;
					else if (i < 100) key = "0" + i;
					else key = "" + i;

					iDoc.put(key,dp);
					//vDoc.add(dp.getDocType()+"-"+dp.getDocNo());
				}
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Detalle Factores - '+document.title;
function distribuir(secuenciaPago,idx,distForced){if(distForced==undefined||distForced==null)distForced=false;var pacId=parent.document.form0.pacId.value;var admision=eval('document.formDetalle.admiSecuencia'+idx).value;parent.showPopWin('../caja/reg_recibo_distribucion.jsp?fg=<%=fg%>&fp=<%=fp%>&mode='+(distForced?'edit':'view')+'&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>&secuenciaPago='+secuenciaPago+'&idx='+idx+'&pacId='+pacId+'&admision='+admision,winWidth*.90,winHeight*.75,null,null,'');}


function doAction(){

newHeight();

<%if(mode.trim().equals("add")){%>updSaldoAlq();<%}%>calcTotal();


<% if (type.equals("1")) { %>
parent.form0BlockButtons(false);

<% if (!fg.equalsIgnoreCase("A")) { %>

parent.window.frames['formaPago'].formFPBlockButtons(false);

<% } %>

var referTo=getSelectedOptionTitle(parent.document.form0.refType,parent.document.form0.refType.value);
abrir_ventana1('../common/check_recibo_det.jsp?fp=recibos&fg=<%=fg%>&flag=<%=fp%>&mode=<%=mode%>&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>&referTo='+referTo+'&refId='+parent.document.form0.refId.value+'&refType='+parent.document.form0.refType.value+'&lastLineNo=<%=lastLineNo%>');

<% } %>


}

function doSubmit(baction){document.formDetalle.baction.value=baction;if(parent.document.form0.tipoCliente)document.formDetalle.tipoCliente.value=parent.document.form0.tipoCliente.value;if(parent.document.form0.recNo)document.formDetalle.recNo.value=parent.document.form0.recNo.value;if(parent.document.form0.tipoTrans)document.formDetalle.tipoTrans.value=parent.document.form0.tipoTrans.value;if(parent.document.form0.detallado)document.formDetalle.detallado.value=parent.document.form0.detallado.value;if(parent.document.form0.caja)document.formDetalle.caja.value=parent.document.form0.caja.value;if(parent.document.form0.recibo)document.formDetalle.recibo.value=parent.document.form0.recibo.value;if(parent.document.form0.refType)document.formDetalle.refType.value=parent.document.form0.refType.value;if(parent.document.form0.xtra1)document.formDetalle.xtra1.value=parent.document.form0.xtra1.value;if(parent.document.form0.fecha)document.formDetalle.fecha.value=parent.document.form0.fecha.value;if(parent.document.form0.turno)document.formDetalle.turno.value=parent.document.form0.turno.value;if(parent.document.form0.pacId)document.formDetalle.pacId.value=parent.document.form0.pacId.value;if(parent.document.form0.fechaNacimiento)document.formDetalle.fechaNacimiento.value=parent.document.form0.fechaNacimiento.value;if(parent.document.form0.codigoPaciente)document.formDetalle.codigoPaciente.value=parent.document.form0.codigoPaciente.value;if(parent.document.form0.codigoEmpresa)document.formDetalle.codigoEmpresa.value=parent.document.form0.codigoEmpresa.value;if(parent.document.form0.tipoClienteOtros)document.formDetalle.tipoClienteOtros.value=parent.document.form0.tipoClienteOtros.value;if(parent.document.form0.empresaOtros)document.formDetalle.empresaOtros.value=parent.document.form0.empresaOtros.value;if(parent.document.form0.medicoOtros)document.formDetalle.medicoOtros.value=parent.document.form0.medicoOtros.value;if(parent.document.form0.provinciaEmp)document.formDetalle.provinciaEmp.value=parent.document.form0.provinciaEmp.value;if(parent.document.form0.siglaEmp)document.formDetalle.siglaEmp.value=parent.document.form0.siglaEmp.value;if(parent.document.form0.tomoEmp)document.formDetalle.tomoEmp.value=parent.document.form0.tomoEmp.value;if(parent.document.form0.asientoEmp)document.formDetalle.asientoEmp.value=parent.document.form0.asientoEmp.value;if(parent.document.form0.companiaEmp)document.formDetalle.companiaEmp.value=parent.document.form0.companiaEmp.value;if(parent.document.form0.empId)document.formDetalle.empId.value=parent.document.form0.empId.value;if(parent.document.form0.particularOtros)document.formDetalle.particularOtros.value=parent.document.form0.particularOtros.value;if(parent.document.form0.clienteAlq)document.formDetalle.clienteAlq.value=parent.document.form0.clienteAlq.value;if(parent.document.form0.numContrato)document.formDetalle.numContrato.value=parent.document.form0.numContrato.value;if(parent.document.form0.refId)document.formDetalle.refId.value=parent.document.form0.refId.value;if(parent.document.form0.nombre)document.formDetalle.nombre.value=parent.document.form0.nombre.value;if(parent.document.form0.nombreAdicional)document.formDetalle.nombreAdicional.value=parent.document.form0.nombreAdicional.value;if(parent.document.form0.descripcion)document.formDetalle.descripcion.value=parent.document.form0.descripcion.value;if(parent.document.form0.pagoTotal)document.formDetalle.pagoTotal.value=parent.document.form0.pagoTotal.value;if(parent.document.form0.tmpDescAlquiler)document.formDetalle.tmpDescAlquiler.value=parent.document.form0.tmpDescAlquiler.value;if(parent.document.form0.hnaCapitation)document.formDetalle.hnaCapitation.value=(parent.document.form0.hnaCapitation.checked)?parent.document.form0.hnaCapitation.value:'';if(parent.document.form0.adelanto)document.formDetalle.adelanto.value=(parent.document.form0.adelanto.checked)?parent.document.form0.adelanto.value:'';if(!formDetalleValidation()){parent.form0BlockButtons(false);return false;}<% if (fg.equalsIgnoreCase("A")&&!tipoCliente.equalsIgnoreCase("O") ) { %>document.formDetalle.doDistribution.value=confirm('¿Desea distribuir lo aplicado?\n\nAceptar  ==> Distribuir\nCancelar ==> Continuar Aplicando')?'S':'N';<% } %>document.formDetalle.submit();}
function deleteItem(k){removeItem('formDetalle',k);setBAction('formDetalle','X');}
function calcTotal(){<% /*if (!tipoCliente.equalsIgnoreCase("A")) {*/ %>var pagoTotal=0.00;if(parent.document.form0.pagoTotal.value!=''){pagoTotal=parseFloat(parent.document.form0.pagoTotal.value);parent.document.form0.pagoTotal.value=pagoTotal.toFixed(2);}var aplicado=0.00;if(parent.document.form0.aplicado.value!=''){aplicado=parseFloat(parent.document.form0.aplicado.value);if(parent.document.form0.aplicadoDisplay)parent.document.form0.aplicadoDisplay.value=aplicado.toFixed(2);}var ajustado=0.00;if(parent.document.form0.ajustado.value!=''){ajustado=parseFloat(parent.document.form0.ajustado.value);parent.document.form0.ajustado.value=ajustado.toFixed(2);}var porAplicar=pagoTotal-aplicado+ajustado;var total=0.00;<%if ((!viewMode&&!fg.equalsIgnoreCase("D")||fg.equalsIgnoreCase("A"))&&(appDet.trim().equals("N"))) { %>;total+=aplicado;<% } %>for(i=1;i<=<%=iDoc.size()%>;i++){var monto=parseFloat(eval('document.formDetalle.monto'+i).value);var montoDeuda=parseFloat(eval('document.formDetalle.montoDeuda'+i).value);var docType=eval('document.formDetalle.docType'+i).value;var tipoTransaccion=eval('document.formDetalle.tipoTransaccion'+i).value;var estatus=eval('document.formDetalle.estatus'+i).value;var secPago = eval('document.formDetalle.secuenciaPago'+i).value;<% if (!viewMode&&!fg.equalsIgnoreCase("D")) { %>if(secPago==''){if((porAplicar-monto)<0)monto=porAplicar;else if(monto>montoDeuda&&docType!='D'){monto=montoDeuda;}}	<%}%>if(docType=='D'){tipoTransaccion=4;estatus='N';}else{if(monto<montoDeuda){tipoTransaccion=2;estatus=(docType=='R')?'S':'N';}else{tipoTransaccion=1;estatus='S';}}eval('document.formDetalle.monto'+i).value=monto.toFixed(2);<% if (!viewMode&&!fg.equalsIgnoreCase("D")) { %>if(secPago==''){eval('document.formDetalle.tipoTransaccion'+i).value=tipoTransaccion;if(estatus=='')estatus='N';eval('document.formDetalle.estatus'+i).value=estatus;}<% } %>total+=monto;if(secPago==''){porAplicar=parseFloat((porAplicar-monto).toFixed(2));}}if(document.formDetalle.total)document.formDetalle.total.value=(total).toFixed(2);if(parent.document.form0.aplicadoDisplay)parent.document.form0.aplicadoDisplay.value=total.toFixed(2);if(parent.document.form0.porAplicar)parent.document.form0.porAplicar.value=(pagoTotal-total.toFixed(2)+ajustado).toFixed(2);<% //} %>}
function updSaldoAlq(){<% if (tipoCliente.equalsIgnoreCase("A") && iDoc.size() > 0  ) { %>
var contrato=parent.document.form0.refId.value;
var fecha=parent.document.form0.fecha.value;
var saldoAnt=parseFloat(document.formDetalle.montoDeuda1.value);
var saldoAct=parseFloat(document.formDetalle.saldo1.value);
var monto=parseFloat(parent.document.form0.pagoTotal.value);

if(monto !=0){
	var tmpDescAlquiler=0;   //parseFloat(getDBData('<%=request.getContextPath()%>','fn_cja_descuento_alq(<%=compania%>,'+contrato+','+monto+','+saldoAct+',\''+fecha+'\')','dual',''));
	var descProntoPago=tmpDescAlquiler;
	var saldoNew=saldoAnt-descProntoPago-monto;
	var precioAlq=parseFloat(getDBData('<%=request.getContextPath()%>','nvl(sum(nvl(y.precio,0)),0)','tbl_cxc_contrato_alq z, tbl_cxc_det_contrato_alq y, tbl_cxc_tipo_alquiler x','z.contrato = '+contrato+' and z.compania = <%=compania%> and x.descripcion like \'%CONSULTORIOS%\' and z.compania = y.compania and z.contrato = y.contrato and y.cod_tipo_alq = x.cod_tipo_alq and y.compania = x.compania and z.estado = \'A\' and nvl(y.estatus,\'A\') <> \'I\''));
	var descAplicado=parseFloat(getDBData('<%=request.getContextPath()%>','nvl(sum(nvl(y.desc_pronto_pago,0) + nvl(z.tmp_desc_alquiler,0)),0)','tbl_cja_transaccion_pago z, tbl_cja_detalle_pago y','z.num_contrato = '+contrato+' and z.compania = <%=compania%> and z.compania = y.compania(+) and z.codigo = y.codigo_transaccion(+) and z.anio = y.tran_anio(+) and z.rec_status = \'A\' and to_char(z.fecha,\'mm/yyyy\') = \''+fecha.substring(3,10)+'\''));
	/*-------------------------------->>>---------------------------------
	if(monto+tmpDescAlquiler==saldoAct&&parseInt(fecha.substring(0,2),10)<=10)	{
		//top.CBMSG.warning('Fecha de pago fuera de período para calcular Descuento por Pronto Pago!');
		if(parent.document.form0.tmpDescAlquiler)parent.document.form0.tmpDescAlquiler.value=tmpDescAlquiler.toFixed(2);
	} else if(monto+descProntoPago>saldoAct&&monto>=precioAlq)
	{
		if(descAplicado!=0&&tmpDescAlquiler>0)	top.CBMSG.warning('NOTA: Este contrato ya recibió descuento por pronto pago en este mes, pero se ha calculado otra vez por no tener saldo pendiente..');

		if(descProntoPago==0)
		{
			if(precioAlq ==0)top.CBMSG.warning('El contrato no tiene consultorios agregados, no se aplicará descuentos');
			else top.CBMSG.warning('No se calculará descuento por: Cliente canceló saldo pero la fecha de pago esta fuera de los parámetros establecidos!');
		}
	} else top.CBMSG.warning('No se calculará descuento por: Cliente no está cancelando saldo pendiente o está realizando el pago fuera de la fecha establecida o el pago_total no cancela la letra mensual por un valor de: $'+precioAlq.toFixed(2));
	----------------------------------<<<<----------------------------------*/

	if(parent.document.form0.tmpDescAlquiler)parent.document.form0.tmpDescAlquiler.value=tmpDescAlquiler.toFixed(2);
	document.formDetalle.descProntoPago1.value=descProntoPago.toFixed(2);
	document.formDetalle.monto1.value=monto.toFixed(2);
	document.formDetalle.saldo1.value=saldoNew.toFixed(2);calcTotal();

}

<% } %>


}
function printFact(facCodigo){var referTo=getSelectedOptionTitle(parent.document.form0.refType,parent.document.form0.refType.value);var refId = parent.document.form0.refId.value;if(parent.document.form0._refTypeDisplayDsp)referTo=getSelectedOptionTitle(parent.document.form0._refTypeDisplayDsp,parent.document.form0._refTypeDisplayDsp.value); abrir_ventana1('../facturacion/print_estado_cargo_det.jsp?factId='+facCodigo+'&pacId='+refId+'&refId='+refId+'&referTo='+referTo+'&refType='+parent.document.form0.refType.value+'&facturarA=<%=tipoCliente%>');}
function liberarAplicacion(tran_anio, codigo_transaccion, secuencia_pago,factura){parent.liberarAplicacion(tran_anio, codigo_transaccion, secuencia_pago,factura);}
function isValid(){if(document.formDetalle.keySize.value<=0 && '<%=tipoCliente%>' =='P'&& parent.document.form0.remplazo.value==''){top.CBMSG.warning('Por favor agregue por lo menos una Factura ó Admision!');return false;}return formDetalleValidation();}

function printDGI(factura){
	var x = splitCols(getDBData('<%=request.getContextPath()%>', 'a.id, a.codigo, a.tipo_docto, a.ruc_cedula, nvl(a.impreso, \'N\') impreso', 'tbl_fac_dgi_documents a', ' exists (select null from tbl_fac_factura f where f.codigo = a.codigo and a.tipo_docto = \'FACT\' and f.codigo = \''+factura+'\' and f.estatus != \'A\' and f.compania = <%=(String) session.getAttribute("_companyId")%>)'));
	if(x[4]=='Y'){
		if(confirm('Desea Reimprimir Factura?')){
			parent.showPopWin('../common/run_process.jsp?fp=pago_recibo&actType=5&docType=DGI&docId='+x[0]+'&docNo='+x[1]+'&tipo='+x[2]+'&ruc='+x[3],winWidth*.75,winHeight*.80,null,null,'');
		}
	} else if(x[4]=='N'){
		parent.showPopWin('../common/run_process.jsp?fp=pago_recibo&actType=2&docType=DGI&docId='+x[0]+'&docNo='+x[1]+'&tipo='+x[2]+'&ruc='+x[3],winWidth*.75,winHeight*.80,null,null,'');
	}
}
function getPagoTotal(){ return parseFloat(parent.document.form0.pagoTotal.value);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("recNo","")%>
<%=fb.hidden("tipoTrans","")%>
<%=fb.hidden("detallado","")%>
<%=fb.hidden("caja","")%>
<%=fb.hidden("recibo","")%>
<%=fb.hidden("refType","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("turno","")%>
<%=fb.hidden("pacId","")%>
<%=fb.hidden("fechaNacimiento","")%>
<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("codigoEmpresa","")%>
<%=fb.hidden("tipoClienteOtros","")%>
<%=fb.hidden("empresaOtros","")%>
<%=fb.hidden("medicoOtros","")%>
<%=fb.hidden("provinciaEmp","")%>
<%=fb.hidden("siglaEmp","")%>
<%=fb.hidden("tomoEmp","")%>
<%=fb.hidden("asientoEmp","")%>
<%=fb.hidden("companiaEmp","")%>
<%=fb.hidden("empId","")%>
<%=fb.hidden("particularOtros","")%>
<%=fb.hidden("clienteAlq","")%>
<%=fb.hidden("numContrato","")%>
<%=fb.hidden("refId","")%>
<%=fb.hidden("nombre","")%>
<%=fb.hidden("nombreAdicional","")%>
<%=fb.hidden("descripcion","")%>
<%=fb.hidden("pagoTotal","")%>
<%=fb.hidden("tmpDescAlquiler","")%>
<%=fb.hidden("hnaCapitation","")%>
<%=fb.hidden("adelanto","")%>
<%=fb.hidden("xtra1","")%>
<%=fb.hidden("keySize",""+iDoc.size())%>
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("doDistribution","")%>
<%fb.appendJsValidation("if(document.formDetalle.baction.value=='Guardar'){if('"+fg+"'=='A'&&parseInt(document.formDetalle.keySize.value,10)<=0){top.CBMSG.warning('Por favor agregue por lo menos un Detalle de Pago!');error++;}}else if(document.formDetalle.baction.value=='+'){var refTypeObj=parent.document.form0.refType;if(refTypeObj.nodeName!='SELECT')refTypeObj=parent.document.form0.refTypeDisplay;var referTo=getSelectedOptionTitle(refTypeObj,refTypeObj.value);if(referTo!='PART'&&parent.document.form0.refId.value==''){top.CBMSG.warning('Por favor seleccione el Cliente!');formDetalleBlockButtons(false);return false;}return true;}else return true;");%>
<% if (tipoCliente.equalsIgnoreCase("A")) { %>
		<tr class="TextHeader" align="center">
			<td width="10%">Saldo A</td>
			<td width="10%">Saldo Ant.</td>
			<td width="10%">D&eacute;bito</td>
			<td width="10%">Cr&eacute;dito</td>
			<td width="10%">Saldo Act.</td>
			<td width="10%">Descto.</td>
			<td width="10%">Abono</td>
			<td width="10%">Nuevo Saldo</td>
			<td width="20%">Tipo Transacci&oacute;n</td>
		</tr>
<% } else { %>
		<tr class="TextHeader" align="center">
			<td width="7%">Tipo</td>
			<td width="8%">Doc.</td>
			<td width="5%">Adm.</td>
			<td width="8%">Fecha</td>
			<td width="29%">Nombre</td>
			<td width="7%">Monto Total</td>
			<td width="7%">Saldo</td>
			<td width="9%">Monto Pago</td>
			<td width="12%">Tipo Transacci&oacute;n</td>
			<td width="2%">&nbsp;</td>
			<td width="2%">&nbsp;</td>
			<td width="2%"><%=((tipoCliente.equalsIgnoreCase("P")||tipoCliente.equalsIgnoreCase("E"))&&distAut.trim().equals("S"))?fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','distribuir',"+iDoc.size()+",this,1)\"","DISTRIBUIR todos los Registros listados!"):""%></td>
			<td width="2%"><%=fb.submit("btnFactura","+",true,(viewMode || fg.equalsIgnoreCase("D")),"Text10",null,"onClick=\"javascript:setBAction('formDetalle',this.value)\"")%></td>
		</tr>
<% } %>
<%
double totalMonto = 0.00;
al = CmnMgr.reverseRecords(iDoc);
for (int i=1; i<=iDoc.size(); i++)
{
	key = al.get(i - 1).toString();
	DetallePago dp = (DetallePago) iDoc.get(key);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	String docTypeDisplay = "";
	if (dp.getDocType().equalsIgnoreCase("F")) docTypeDisplay = "FACTURA";
	else if (dp.getDocType().equalsIgnoreCase("D")) docTypeDisplay = "ADMISION";
	else if (dp.getDocType().equalsIgnoreCase("R")) docTypeDisplay = "REMANENTE";
	else if (dp.getDocType().equalsIgnoreCase("C")) docTypeDisplay = "CONTRATO";
%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("docType"+i,dp.getDocType())%>
		<%=fb.hidden("docNo"+i,dp.getDocNo())%>
		<%=fb.hidden("admiSecuencia"+i,dp.getAdmiSecuencia())%>
		<%=fb.hidden("codRem"+i,dp.getCodRem())%>
		<%=fb.hidden("facCodigo"+i,dp.getFacCodigo())%>
		<%=fb.hidden("fecha"+i,dp.getFecha())%>
		<%=fb.hidden("montoTotal"+i,dp.getMontoTotal())%>
		<%=fb.hidden("montoDeuda"+i,dp.getMontoDeuda())%>
		<%=fb.hidden("nombrePaciente"+i,dp.getNombrePaciente())%>
		<%=fb.hidden("admEstado"+i,dp.getAdmEstado())%>
		<%=fb.hidden("admCat"+i,dp.getAdmCat())%>
		<%=fb.hidden("admCatDesc"+i,dp.getAdmCatDesc())%>
		<%=fb.hidden("estatus"+i,dp.getEstatus())%>
		<%=fb.hidden("pagoPor"+i,dp.getPagoPor())%>
		<%=fb.hidden("secuenciaPago"+i,dp.getSecuenciaPago())%>
		<%=fb.hidden("anulada"+i,dp.getAnulada())%>

<% if (tipoCliente.equalsIgnoreCase("D")) { %>
		<%//=fb.hidden("sw"+i,"S")%>
<% } else if (tipoCliente.equalsIgnoreCase("E") || tipoCliente.equalsIgnoreCase("F")) { %>
		<%//=fb.hidden("sw"+i,"N")%>
<% } else if (tipoCliente.equalsIgnoreCase("R")) { %>
		<%//=fb.hidden("sw"+i,"N")%>
<% } %>
		<%=fb.hidden("numContrato"+i,dp.getNumContrato())%>
		<%=fb.hidden("debito"+i,dp.getDebito())%>
		<%=fb.hidden("credito"+i,dp.getCredito())%>
<% if (tipoCliente.equalsIgnoreCase("A")) { %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="right">
			<td align="center"><%=dp.getSaldoA()%></td>
			<td><%=CmnMgr.getFormattedDecimal(dp.getMontoTotal())%>&nbsp;</td>
			<td><%=CmnMgr.getFormattedDecimal(dp.getDebito())%>&nbsp;</td>
			<td><%=CmnMgr.getFormattedDecimal(dp.getCredito())%>&nbsp;</td>
			<td><%=CmnMgr.getFormattedDecimal(dp.getMontoDeuda())%>&nbsp;</td>
			<td align="center"><%=fb.decBox("descProntoPago"+i,dp.getDescProntoPago(),false,false,true,10,"Text10","","")%></td>
			<td align="center"><%=fb.decPlusBox("monto"+i,dp.getMonto(),true,false,true,10,"Text10","","")%></td>
			<td align="center"><%=fb.decBox("saldo"+i,dp.getSaldo(),false,false,true,10,"Text10","","")%></td>
			<td align="center"><%=fb.select("tipoTransaccion"+i,alTT,dp.getTipoTransaccion(),false,(mode.equalsIgnoreCase("edit") || viewMode),0,"Text10",null,"onFocus=\"javascript:this.blur();\"")%></td>
		</tr>
<% } else { %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<td>
			<%if (dp.getDocType().equalsIgnoreCase("F") && tipoCliente.equals("P") && dp.getTipoTransaccion() != null && dp.getTipoTransaccion().equals("1") && dp.getAnulada()!=null && dp.getAnulada().trim().equals("N")){%>
			<%=fb.button("imprimirDGIP","Imprimir",true,false,null,null,"onClick=\"javascript:printDGI('"+dp.getDocNo()+"');\"")%>
			<%} else {%><%=docTypeDisplay%><%}%>
			</td>
			<td><% if ((tipoCliente.equalsIgnoreCase("P") || tipoCliente.equalsIgnoreCase("E")|| tipoCliente.equalsIgnoreCase("O")) && dp.getDocType().equalsIgnoreCase("F")) { %><a href="javascript:printFact('<%=dp.getDocNo()%>')" class="Link00Bold"><%=dp.getDocNo()%></a><% } else { %><%=dp.getDocNo()%><% } %></td>
			<td><%=(dp.getDocType().equalsIgnoreCase("F"))?dp.getAdmiSecuencia():""%></td>
			<td><%=dp.getFecha()%></td>
			<td align="left" o><%=dp.getNombrePaciente()%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(dp.getMontoTotal())%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(dp.getMontoDeuda())%>&nbsp;</td>
			<td><%=(dp.getAnulada().trim().equals("S")||(dp.getSecuenciaPago()!=null && !dp.getSecuenciaPago().equals("")))?fb.decBox("monto"+i,dp.getMonto(),true,false,(viewMode || fg.equalsIgnoreCase("D")||(dp.getSecuenciaPago()!=null && !dp.getSecuenciaPago().equals(""))),10,"Text10","","onBlur=\"javascript:calcTotal(this);\""):fb.decPlusBox("monto"+i,dp.getMonto(),true,false,(viewMode || fg.equalsIgnoreCase("D")||(dp.getSecuenciaPago()!=null && !dp.getSecuenciaPago().equals(""))),10,"Text10","","onBlur=\"javascript:calcTotal(this);\"")%></td>
			<td><%=fb.select("tipoTransaccion"+i,alTT,dp.getTipoTransaccion(),false,(viewMode || fg.equalsIgnoreCase("D")||(dp.getSecuenciaPago()!=null && !dp.getSecuenciaPago().equals("")&& !dp.getSecuenciaPago().equals("0"))),0,"Text10",null,"onFocus=\"javascript:this.blur();\"")%></td>
			<td><% if (!dp.getDocType().equalsIgnoreCase("D") && !mode.equalsIgnoreCase("add") && !tipoCliente.equalsIgnoreCase("O") && dp.getSecuenciaPago() != null && !dp.getSecuenciaPago().trim().equals("") && !dp.getSecuenciaPago().equals("0") && !dp.getPacId().equals("-1") && (((UserDet.getUserProfile().contains("0")) && Double.parseDouble(dp.getMonto()) != 0) || Double.parseDouble(dp.getMonto()) > 0)) { %>
			<% if (!dp.getMontoDistribuido().equals("0") || (dp.getMontoDistribuido().equals("0") && !dp.getAnulada().equalsIgnoreCase("S") && (!mode.equalsIgnoreCase("view") || fg.equalsIgnoreCase("A")))) { %><a href="javascript:distribuir(<%=dp.getSecuenciaPago()%>,<%=i%>,<%=(dp.getMontoDistribuido().equals("0") && !dp.getAnulada().equalsIgnoreCase("S") && (!mode.equalsIgnoreCase("view") || fg.equalsIgnoreCase("A")))%>)"><img id="imgDistribucion<%=i%>" height="20" width="20" class="ImageBorder" src="../images/<%=(dp.getMontoDistribuido().equals("0"))?"distribute.gif":"search.gif"%>"></a><% } else { %>&nbsp;<% } %>
			<% } %></td>
			<td align="center">
			<authtype type='51'>
			<%if(Double.parseDouble(dp.getMonto()) > 0 && (dp.getAnulada() !=null && !dp.getAnulada().trim().equals("") && !dp.getAnulada().trim().equals("S")&& !dp.getRecStatus().trim().equals("I")&& (dp.getSecuenciaPago()!=null && !dp.getSecuenciaPago().equals("")&& !dp.getSecuenciaPago().equals("0"))) ){%>
			<a href="javascript:liberarAplicacion('<%=dp.getTranAnio()%>','<%=dp.getCodigoTransaccion()%>','<%=dp.getSecuenciaPago()%>','<%=dp.getFacCodigo()%>','<%=dp.getMonto()%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><img id="imgDistDel<%=i%>" height="20" width="20" class="ImageBorder" src="../images/trash.gif"></a><%}%>
			</authtype>
			</td>
			<td><%=(!dp.getDocType().equalsIgnoreCase("F") || (!tipoCliente.equalsIgnoreCase("P")&&!tipoCliente.equalsIgnoreCase("E"))||(dp.getAdmiSecuencia() != null && dp.getAdmiSecuencia().trim().equals("0")) || !distAut.trim().equals("S"))?"":fb.checkbox("distribuir"+i,"S",(dp.getDistribuir().trim().equals("S")),(viewMode),null,null,"")%></td>
			<td><%=fb.submit("rem"+i,"X",true,(viewMode || fg.equalsIgnoreCase("D") ||(dp.getSecuenciaPago()!=null && !dp.getSecuenciaPago().equals(""))),"Text10",null,"onClick=\"javascript:deleteItem("+i+");\"","Eliminar Factura")%></td>
		</tr>
<% } %>
<%
totalMonto += Double.parseDouble(dp.getMonto());
}
%>
<% if (!tipoCliente.equalsIgnoreCase("A")) { %>
		<tr class="TextHeader">
			<td colspan="7" align="right">Total</td>
			<td align="center"><%=fb.decBox("total",CmnMgr.getFormattedDecimal(totalMonto),false,false,true,10,"Text10","","")%></td>
			<td colspan="5">&nbsp;</td>
		</tr>
<% } %>
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
	String baction = request.getParameter("baction");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close

	TransaccionPago tp = new TransaccionPago();
	tp.setTipoCliente((tipoCliente.equalsIgnoreCase("A"))?"O":tipoCliente);
	tp.setCodigo(codigo);
	tp.setCompania(compania);
	tp.setAnio(anio);
	tp.setRecNo(request.getParameter("recNo"));
	tp.setTipoTrans(request.getParameter("tipoTrans"));
	tp.setDetallado(request.getParameter("detallado"));
	tp.setCaja(request.getParameter("caja"));
	tp.setRecibo(request.getParameter("recibo"));
	tp.setRefType(request.getParameter("refType"));
	tp.setFecha(request.getParameter("fecha"));//"trunc(sysdate)"
	tp.setTurno(request.getParameter("turno"));
	tp.setPacId(request.getParameter("pacId"));
	tp.setFechaNacimiento(request.getParameter("fechaNacimiento"));
	tp.setCodigoPaciente(request.getParameter("codigoPaciente"));
	if(baction.equalsIgnoreCase("guardar") && tipoCliente.equalsIgnoreCase("P")&& (tp.getPacId().trim().equals("")||tp.getPacId().equals("null")))throw new Exception("Datos de Paciente Invalidos. Verifique");

	tp.setCodigoEmpresa(request.getParameter("codigoEmpresa"));
	tp.setTipoClienteOtros(request.getParameter("tipoClienteOtros"));
	tp.setEmpresaOtros(request.getParameter("empresaOtros"));
	tp.setMedicoOtros(request.getParameter("medicoOtros"));
	tp.setProvinciaEmp(request.getParameter("provinciaEmp"));
	tp.setSiglaEmp(request.getParameter("siglaEmp"));
	tp.setTomoEmp(request.getParameter("tomoEmp"));
	tp.setAsientoEmp(request.getParameter("asientoEmp"));
	tp.setCompaniaEmp(request.getParameter("companiaEmp"));
	tp.setEmpId(request.getParameter("empId"));
	tp.setParticularOtros(request.getParameter("particularOtros"));
	tp.setClienteAlq(request.getParameter("clienteAlq"));
	tp.setNumContrato(request.getParameter("numContrato"));
	tp.setRefId(request.getParameter("refId"));
	tp.setNombre(request.getParameter("nombre"));
	tp.setNombreAdicional(request.getParameter("nombreAdicional"));
	if (tp.getNombreAdicional() == null || tp.getNombreAdicional().trim().equals("")) tp.setNombreAdicional(tp.getNombre());
	tp.setDescripcion(request.getParameter("descripcion"));
	tp.setPagoTotal(request.getParameter("pagoTotal"));
	tp.setTmpDescAlquiler("0");//request.getParameter("tmpDescAlquiler")
	tp.setHnaCapitation(request.getParameter("hnaCapitation"));
	tp.setAdelanto(request.getParameter("adelanto"));
	tp.setXtra1(request.getParameter("xtra1"));
	if(request.getParameter("fp")!=null && request.getParameter("fp").equals("PM")) tp.setXtra2("-1");
	else tp.setXtra2("1");

	tp.setUsuarioCreacion(UserDet.getUserName());
	tp.setUsuarioModificacion(UserDet.getUserName());
	tp.setFechaCreacion("sysdate");
	tp.setFechaModificacion("sysdate");
	tp.setAnulada("N");
	tp.setStatus("C");
	tp.setRecStatus("A");
	tp.setRecImpreso("N");
	tp.setImpreso("N");

	String itemRemoved = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	for (int i=1; i<=keySize; i++)
	{
		DetallePago dp = new DetallePago();

		dp.setDocType(request.getParameter("docType"+i));
		dp.setDocNo(request.getParameter("docNo"+i));
		dp.setAdmiSecuencia(request.getParameter("admiSecuencia"+i));
		dp.setCodRem(request.getParameter("codRem"+i));
		dp.setFacCodigo(request.getParameter("facCodigo"+i));
		dp.setCodigoTransaccion(codigo);
		dp.setFecha(request.getParameter("fecha"+i));
		dp.setMontoTotal(request.getParameter("montoTotal"+i));
		dp.setMontoDeuda(request.getParameter("montoDeuda"+i));
		dp.setNombrePaciente(request.getParameter("nombrePaciente"+i));
		dp.setAdmEstado(request.getParameter("admEstado"+i));
		dp.setAdmCat(request.getParameter("admCat"+i));
		dp.setAdmCatDesc(request.getParameter("admCatDesc"+i));
		dp.setEstatus(request.getParameter("estatus"+i));
		dp.setPagoPor(request.getParameter("pagoPor"+i));
		dp.setSw(request.getParameter("sw"+i));
		dp.setMonto(request.getParameter("monto"+i));
		dp.setTipoTransaccion(request.getParameter("tipoTransaccion"+i));
		if ((request.getParameter("distribuir"+i)!= null && request.getParameter("distribuir"+i).equalsIgnoreCase("S"))&&request.getParameter("docType"+i).trim().equals("F"))
		dp.setDistribuir("S");
		else dp.setDistribuir("N");
		if(!tipoCliente.equalsIgnoreCase("E")&&!tipoCliente.equalsIgnoreCase("P"))dp.setDistribuir("N");


		dp.setCompania(compania);
		dp.setTranAnio(anio);
		dp.setDistribuido("N");
		dp.setUsuarioCreacion(UserDet.getUserName());
		dp.setUsuarioModificacion(UserDet.getUserName());
		dp.setFechaCreacion("sysdate");
		dp.setFechaModificacion("sysdate");

		dp.setNumContrato(request.getParameter("numContrato"+i));
		dp.setDescProntoPago(request.getParameter("descProntoPago"+i));
		dp.setDebito(request.getParameter("debito"+i));
		dp.setCredito(request.getParameter("credito"+i));
		dp.setSecuenciaPago(request.getParameter("secuenciaPago"+i));
		dp.setAnulada(request.getParameter("anulada"+i));


		key = request.getParameter("key"+i);
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = key;
		try
		{
			if (baction.equalsIgnoreCase("guardar") && (dp.getSecuenciaPago()==null || dp.getSecuenciaPago().equals("")))tp.addDetallePago(dp);
			iDoc.put(key,dp);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}//for i

	//solo para cuando registran nuevo recibo
	if (fg.trim().equals(""))
	{
		boolean hasReceipt = false;
		boolean hasCash = false;
		al = CmnMgr.reverseRecords(iPago);
		for (int i=1; i<=iPago.size(); i++)
		{
			key = al.get(i - 1).toString();
			DetalleTransFormaPagos det = (DetalleTransFormaPagos) iPago.get(key);
			if (i == 1 && det.getFpCodigo().equals("0")) hasReceipt = true;
			else if (det.getFpCodigo().equals("1")) hasCash = true;
			tp.addDetalleTransFormaPagos(det);
		}//for i

		if (hasReceipt)
		{
			tp.getDetallePago().clear();
			tp.getDetalleBilletes().clear();
		}
		else if (hasCash)
		{
			al = CmnMgr.reverseRecords(iBill);
			for (int i=1; i<=iBill.size(); i++)
			{
				key = al.get(i - 1).toString();
				DetalleBilletes det = (DetalleBilletes) iBill.get(key);
				if (det.getDenominacion() != null && !det.getDenominacion().trim().equals("") && det.getSerie() != null && !det.getSerie().trim().equals("")) 				tp.addDetalleBilletes(det);
			}//for i
		}
	}

	if (!itemRemoved.equals(""))
	{
		DetallePago dp = (DetallePago) iDoc.get(itemRemoved);
		vDoc.remove(dp.getDocType()+"-"+dp.getDocNo());
		iDoc.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&fp="+fp+"&mode="+mode+"&tipoCliente="+tipoCliente+"&codigo="+codigo+"&compania="+compania+"&anio="+anio+"&change=1&lastLineNo="+lastLineNo);
		return;
	}
	else if (baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&fp="+fp+"&mode="+mode+"&tipoCliente="+tipoCliente+"&codigo="+codigo+"&compania="+compania+"&anio="+anio+"&change=1&type=1&lastLineNo="+lastLineNo);
		return;
	}
	else if (baction.equalsIgnoreCase("guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg+"&mode="+mode+"&tipoCliente="+tipoCliente);
		if (fg.trim().equals(""))
		{
			TPMgr.add(tp);
			codigo = TPMgr.getPkColValue("codigo");
			tp.setRecNo(TPMgr.getPkColValue("recNo"));
			tp.setRecibo(TPMgr.getPkColValue("recibo"));
		}
		else if (fg.equalsIgnoreCase("A"))
		{
			TPMgr.appPago(tp);
		}
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){<% if (TPMgr.getErrCode().equals("1")) { %><% if (fg.trim().equals("")) { %>parent.document.form0.recNo.value='<%=tp.getRecNo()%>';parent.document.form0.recibo.value='<%=tp.getRecibo()%>';<% } %>parent.document.form0.errCode.value=<%=TPMgr.getErrCode()%>;parent.document.form0.errMsg.value='<%=TPMgr.getErrMsg()%>';parent.document.form0.codigo.value='<%=codigo%>';parent.document.form0.doDistribution.value='<%=request.getParameter("doDistribution")%>';
parent.document.form0.distAut.value='<%=distAut%>'
parent.document.form0.submit();<% } else throw new Exception(TPMgr.getErrException()); %>}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>