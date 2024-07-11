<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.caja.PagoAutoFacAxa"%>
<%@ page import="issi.caja.PagoFacAxaDet"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iReciboAxa" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vRecibos" scope="session" class="java.util.Vector" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
PagoAutoFacAxa pAxa = new PagoAutoFacAxa();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();

String key = "";
String sql = "";
String mode = request.getParameter("mode");
String secuencia = request.getParameter("secuencia");
String anio = request.getParameter("anio");
String change = request.getParameter("change");
String caja = request.getParameter("caja");


boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
int reciboLastLineNo =0;
if (mode == null) mode = "add";
if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;
if (caja == null) caja = "1";


if (request.getMethod().equalsIgnoreCase("GET"))
{

if (mode.equalsIgnoreCase("add"))
	{
		iReciboAxa.clear();
		secuencia = "0";
		anio = cDateTime.substring(6,10);
		
		pAxa = new PagoAutoFacAxa();
		pAxa.setAnio(anio);
		pAxa.setSecuencia("0");
		pAxa.setAplicarPerdida("N");
		pAxa.setFechaFinal("");
		pAxa.setFechaInicial("");
		pAxa.setAplicarPago("N");
		if (!viewMode) mode = "add";
	}
	else
	{
 if (secuencia == null && anio == null) throw new Exception("El codigo  no es válido. Por favor intente nuevamente!");
sql="select a.secuencia, a.cod_empresa as codEmpresa, to_char(a.fecha_inicial,'dd/mm/yyyy')as fechaInicial ,to_char(a.fecha_final,'dd/mm/yyyy') as fechaFinal, a.numero_recibo as numeroRecibo, a.monto_recibo as montoRecibo,a.monto_pendiente as montoPendiente, a.total_facturado as totalFacturado, a.total_pagado as totalPagado, a.total_ajustado as totalAjustado, a.factura_corte as facturaCorte, a.anio, a.monto_capitation as montoCapitation, a.status, a.aplicar_perdida as aplicarPerdida, a.aplicar_pago as aplicarPago,e.nombre as nombreEmpresa, a.rec1_numero as rec1Numero, a.rec1_monto as rec1Monto, a.rec2_numero as rec2Numero, a.rec2_monto as rec2Monto, a.rec3_numero as rec3Numero, a.rec3_monto as rec3Monto, a.rec4_numero as rec4Numero, a.rec4_monto as rec4Monto, a.rec5_numero as rec5Numero, a.rec5_monto as rec5Monto, a.porcentaje, a.pago_liquidables as pagoLiquidables, a.pagar_inasa as pagarInasa , (nvl(a.rec1_monto,0)+ nvl(a.rec2_monto,0)+nvl(a.rec3_monto,0)+ nvl(a.rec4_monto,0)+nvl(a.rec5_monto,0))as totales from tbl_fac_param_pago_automatico a , tbl_adm_empresa e where  a.secuencia = "+secuencia+" and a.anio= "+anio+" and a.cod_empresa = e.codigo(+)";

System.out.println("SQL:\n"+sql);
pAxa = (PagoAutoFacAxa) sbb.getSingleRowBean(ConMgr.getConnection(), sql, PagoAutoFacAxa.class);
}//else
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Pago de Facturas - Empleado- '+document.title;
function fDescontada()
{
}
function showProceso()
{

var p_compania        = eval('document.form0.compania').value;
var p_cod_caja        = '<%=caja%>';
var p_cod_empresa     = eval('document.form0.empresa').value; 
var p_anio_trx        = eval('document.form0.anio_trx').value;
var p_mes_trx         = eval('document.form0.mes').value; 
var p_monto_recibo    = eval('document.form0.monto_recibo').value;
var p_num_recibo      = eval('document.form0.numero_recibo').value; 
var v_proceso = '1';
var v_confirm = 'S';
var dob ='';
var codPac =1245;
var noAdmision =1 ;alert(v_confirm+' --'+v_proceso);

if(confirm('Esta seguro que desea iniciar el proceso de pago automático?'))
{

if(executeDB('<%=request.getContextPath()%>','call sp_cja_pago_factura_empleado('+p_compania+','+p_cod_caja+','+p_cod_empresa+','+p_anio_trx+','+p_mes_trx+','+p_monto_recibo+',\''+p_num_recibo+'\',\''+v_proceso+'\',\''+v_confirm+'\')',''))
alert('Generando proceso');
}else alert('Error al Correr el Procedimiento');



}
function showRecibo()
{
}
function doAction()
{
}
function showCompania()
{
abrir_ventana('../common/search_empresa.jsp?fp=pago_automatico');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PROCESO AUTOMATICO - PAGO DE FACTURAS EMPLEADOS"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">   
	<tr>  
		<td>   
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
			 
				<tr class="TextHeader">
							<td colspan="4"><cellbytelabel>PARAMETROS</cellbytelabel></td>
				</tr>
				<tr class="TextRow01"> 
					<td align="right"><cellbytelabel>código TX</cellbytelabel></td>
					<td colspan="3"><%=fb.textBox("anio",pAxa.getAnio(),false,false,true,10,4)%>
					<%=fb.textBox("secuencia",pAxa.getSecuencia(),false,false,true,10,3)%>
					</td>
				</tr>
				<tr class="TextRow01"> 
					<td align="right"><cellbytelabel>Empresa</cellbytelabel></td>
					<td colspan="3">
  				<%=fb.textBox("empresa","81",true,false,viewMode,10,10)%>
					<%=fb.textBox("nombreEmpresa","Empleado",false,false,true,30,100)%>
					<%=fb.button("addcompania","...",(!viewMode),viewMode,null,null,"onClick=\"javascript:showCompania()\"","Agregar Empresa")%>
					</td>
				</tr>
				<tr class="TextRow01"> 
					<td width="15%" align="right"><cellbytelabel>Año</cellbytelabel> </td>
					<td width="20%"><%=fb.textBox("anio_trx","",true,false,viewMode,10,4)%></td>
					<td width="16%" align="right"><cellbytelabel>Mes</cellbytelabel></td>
					<td width="21%"><%=fb.select("mes","1=ENERO, 2=FEBRERO, 3=MARZO, 4=ABRIL, 5=MAYO, 6=JUNIO, 7=JULIO, 8=AGOSTO, 9=SEPTIEMBRE, 10=OCTUBRE, 11=NOVIEMBRE, 12=DICIEMBRE","",false,viewMode,0,"Text10",null,null)%></td>
				</tr>
				<tr class="TextRow01"> 
					<td align="right"><cellbytelabel>Compania</cellbytelabel></td>
					<td colspan="3"><%=fb.select(ConMgr.getConnection(),"SELECT codigo, nombre||' - '||codigo, codigo FROM tbl_sec_compania where codigo in (1,2)","compania","",false,viewMode,0,"Text10",null,null)%></td>
				</tr>
				<tr class="TextRow01"> 
				<td align="right">No: <cellbytelabel>Recibo</cellbytelabel></td>
				<td><%=fb.textBox("numero_recibo",pAxa.getNumeroRecibo(),true,false,false,15,12)%></td>
				<td  align="right"><cellbytelabel>Monto del Recibo</cellbytelabel></td>
				<td><%=fb.textBox("monto_recibo",pAxa.getMontoRecibo(),true,false,false,15,15)%></td>
				</tr>
				<tr class="TextRow01"> 
				<td align="right" colspan="3"><cellbytelabel>Total Descontado en el Mes</cellbytelabel>:</td>
				<td><%=fb.textBox("fin_total","",false,false,true,15,15)%></td>	
				 			
			 </tr>
			 <tr class="TextRow01"> 
				<td align="right" colspan="3"><cellbytelabel>Cantidad Facturas</cellbytelabel></td>
				<td><%=fb.decBox("c_facturs","",false,false,true,15,10)%></td>	
				 			
			 </tr>
	<tr class="TextRow02">
	<td colspan="5" align="right">
	<%=fb.button("Reporte","Facturas Descontadas",(!viewMode),viewMode,null,null,"onClick=\"javascript:fDescontada()\"","")%>
	<%=fb.button("Pagar","Proceso para Pago de Factura",(!viewMode),viewMode,null,null,"onClick=\"javascript:showProceso()\"","")%>
	<%=fb.button("addFactura","Detalle Del Recibo",(!viewMode),viewMode,null,null,"onClick=\"javascript:showRecibo()\"","")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
</td>
</tr>	
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
