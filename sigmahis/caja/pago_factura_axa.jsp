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

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
int reciboLastLineNo =0;
if (mode == null) mode = "add";
if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{

if (mode.equalsIgnoreCase("add"))
	{
		iReciboAxa.clear();
		secuencia = "0";
		anio = cDateTime.substring(6,10);
		pAxa = new PagoAutoFacAxa();
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

if (mode.equalsIgnoreCase("view"))
{
		iReciboAxa.clear();
		try
		{
			if(pAxa.getRec1Numero() != null && !pAxa.getRec1Numero().trim().equals(""))
			{
				PagoFacAxaDet pDet = new PagoFacAxaDet();
				pDet.setCompania("1");
				pDet.setRecibo(pAxa.getRec1Numero());
				pDet.setFecha("");
				pDet.setMonto(pAxa.getRec1Monto());
				iReciboAxa.put("000",pDet);
				reciboLastLineNo++;
			}
			if(pAxa.getRec2Numero() != null && !pAxa.getRec2Numero().trim().equals(""))
			{
				PagoFacAxaDet pDet = new PagoFacAxaDet();
				pDet.setCompania("1");
				pDet.setRecibo(pAxa.getRec2Numero());
				pDet.setFecha("");
				pDet.setMonto(pAxa.getRec2Monto());
				iReciboAxa.put("001",pDet);
				reciboLastLineNo++;
			}
			if(pAxa.getRec3Numero() != null && !pAxa.getRec3Numero().trim().equals(""))
			{
				PagoFacAxaDet pDet = new PagoFacAxaDet();
				pDet.setCompania("1");
				pDet.setRecibo(pAxa.getRec3Numero());
				pDet.setFecha("");
				pDet.setMonto(pAxa.getRec3Monto());
				iReciboAxa.put("002",pDet);
				reciboLastLineNo++;
			}
			if(pAxa.getRec4Numero() != null && !pAxa.getRec4Numero().trim().equals(""))
			{
				PagoFacAxaDet pDet = new PagoFacAxaDet();
				pDet.setCompania("1");
				pDet.setRecibo(pAxa.getRec4Numero());
				pDet.setFecha("");
				pDet.setMonto(pAxa.getRec4Monto());
				iReciboAxa.put("003",pDet);
				reciboLastLineNo++;
			}
			if(pAxa.getRec5Numero() != null && !pAxa.getRec5Numero().trim().equals(""))
			{
				PagoFacAxaDet pDet = new PagoFacAxaDet();
				pDet.setCompania("1");
				pDet.setRecibo(pAxa.getRec5Numero());
				pDet.setFecha("");
				pDet.setMonto(pAxa.getRec5Monto());
				iReciboAxa.put("004",pDet);
				reciboLastLineNo++;
			}
		}
		catch(Exception ex)
		{
			System.err.println(ex.getMessage());
		}
}
else
if(change == null)
{
	 iReciboAxa.clear();
	 sql="SELECT COMPANIA, RECIBO, to_char(FECHA,'dd/mm/yyyy')as fecha, MONTO FROM TBL_CJA_RECIBO_CAPITATION ";
		System.out.println("SQL:\n"+sql);

		al = sbb.getBeanList(ConMgr.getConnection(),sql,PagoFacAxaDet.class);
		reciboLastLineNo = al.size();
		for (int i=0; i<al.size(); i++)
		{
			PagoFacAxaDet pDet = (PagoFacAxaDet) al.get(i);
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			pDet.setKey(key);
			try
			{
				iReciboAxa.put(pDet.getKey(), pDet);
				vRecibos.add(pDet.getRecibo());
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}//for i
}
}//else
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Pago de Facturas - Axa- '+document.title;
function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}
function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
	window.frames['itemFrame'].doSubmit();
}
function saveMethod(actionValue)
{
	var msg ='';
	if(document.form0.fecha_ini.value == "" )
	msg +='Fecha Inicial ';
	if(document.form0.fecha_fin.value == "" )
	msg +='Fecha Final';
	if(msg !='')
	{
			alert('Introduzca '+msg);
			return false;
	}
	if (form0Validation())
  {
			 window.frames['itemFrame'].form1.baction.value = "Guardar";
			 window.frames['itemFrame'].form1.v_baction.value = actionValue;
			 window.frames['itemFrame'].doSubmit();
  }
}


function doAction()
{
	<%//if(request.getParameter("type").trim().equals("1")%>

}
function showCompania()
{
abrir_ventana('../common/search_empresa.jsp?fp=pago_automatico');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PROCESO AUTOMATICO - PAGO DE FACTURAS AXA"></jsp:param>
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
	 		<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("secuencia",secuencia)%>
			<%=fb.hidden("anio",anio)%>
			<%=fb.hidden("monto_capitation",pAxa.getMontoCapitation())%>
			<%=fb.hidden("monto_pendiente",pAxa.getMontoPendiente())%>
			<%=fb.hidden("numero_recibo",pAxa.getNumeroRecibo())%>
			<%=fb.hidden("monto_recibo",pAxa.getMontoRecibo())%>
			<%=fb.hidden("rec1_numero",pAxa.getRec1Numero())%>
			<%=fb.hidden("rec1_monto",pAxa.getRec1Monto())%>
			<%=fb.hidden("rec2_numero",pAxa.getRec2Numero())%>
			<%=fb.hidden("rec2_monto",pAxa.getRec2Monto())%>
			<%=fb.hidden("rec3_numero",pAxa.getRec3Numero())%>
			<%=fb.hidden("rec3_monto",pAxa.getRec3Monto())%>
			<%=fb.hidden("rec4_numero",pAxa.getRec4Numero())%>
			<%=fb.hidden("rec4_monto",pAxa.getRec4Monto())%>
			<%=fb.hidden("rec5_numero",pAxa.getRec5Numero())%>
			<%=fb.hidden("rec5_monto",pAxa.getRec5Monto())%>
			<%=fb.hidden("pago_liquidables",pAxa.getPagoLiquidables())%>

				<tr class="TextHeader">
							<td colspan="4"><cellbytelabel>PARAMETROS</cellbytelabel></td>
							<td align="center"><cellbytelabel>RESULTADOS</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Empresa</cellbytelabel></td>
					<td colspan="3">
  				<%=fb.textBox("empresa",pAxa.getCodEmpresa(),true,false,viewMode,10)%>
					<%=fb.textBox("nombreEmpresa",pAxa.getNombreEmpresa(),false,false,true,30)%>
					<%=fb.button("addcompania","...",(!viewMode),viewMode,null,null,"onClick=\"javascript:showCompania()\"","Agregar Compañia")%>
					</td>
					<td align="right"><cellbytelabel>Total Pagado</cellbytelabel> <%=fb.decBox("total_pagado",pAxa.getTotalPagado(),false,false,true,15,12.2)%></td>
				</tr>
				<tr class="TextRow01">
					<td width="15%" align="right"><cellbytelabel>Del</cellbytelabel> </td>
					<td width="20%"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fecha_ini" />
											<jsp:param name="valueOfTBox1" value="<%=pAxa.getFechaInicial()%>" />
											</jsp:include></td>
					<td width="16%"><cellbytelabel>AL</cellbytelabel></td>
					<td width="21%"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fecha_fin" />
											<jsp:param name="valueOfTBox1" value="<%=pAxa.getFechaFinal()%>" />
											</jsp:include></td>
					<td align="right"><cellbytelabel>Total Ajustado</cellbytelabel> <%=fb.decBox("total_ajustado",pAxa.getTotalAjustado(),false,false,true,15,12.2)%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel>Pagar a inasa</cellbytelabel></td>
					<td><%=fb.decBox("monto_inasa",pAxa.getPagarInasa(),true,false,viewMode,15,12.2)%></td>
					<td><%=fb.checkbox("aplicar_pago","S",(pAxa.getAplicarPago().trim().equals("S")),viewMode,null,null,"")%>&nbsp;<cellbytelabel>Aplicar Pago</cellbytelabel> ? </td>
					<td><%=fb.checkbox("aplicar_perdida","S",(pAxa.getAplicarPerdida().trim().equals("S")),viewMode,null,null,"")%>&nbsp;<cellbytelabel>Aplicar Perdída En Este Pago</cellbytelabel> ?</td>
					<td align="right"><cellbytelabel>Total Facturado</cellbytelabel> <%=fb.decBox("total_facturado",pAxa.getTotalFacturado(),false,false,true,15,12.2)%></td>
				</tr>
				<tr class="TextRow01">
				<td colspan="5" align="right"><cellbytelabel>Porcentaje a Pagar</cellbytelabel><%=fb.decBox("Porcentaje",pAxa.getPorcentaje(),false,false,true,15,10.4)%></td>
				</tr>
				<tr class="TextRow01">
				<td colspan="5" align="right"><cellbytelabel>Factura Corte</cellbytelabel><%=fb.textBox("factura_corte",pAxa.getFacturaCorte(),false,false,true,15)%></td>
				</tr>
				<tr>
					<td colspan="5">
				  <iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../caja/pago_axa_det.jsp?mode=<%=mode%>&secuencia=<%=secuencia%>&anio=<%=anio%>&reciboLastLineNo=<%=reciboLastLineNo%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow01">
				<td align="right" colspan="3"><cellbytelabel>Total</cellbytelabel></td>
				<td align="center" colspan="2"><%=fb.decBox("fin_total","",false,false,true,15,12.2)%></td>

			 </tr>
	<tr class="TextRow02">
					<td colspan="5" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!-- <%=fb.radio("saveOption","N",true,viewMode,false)%>Crear Otro--->
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.button("Reporte","Reporte Preliminar",(!viewMode),viewMode,null,null,"onClick=\"javascript:saveMethod(this.value)\"")%>
						<%=fb.button("Pagar","Pagar",(!viewMode),viewMode,null,null,"onClick=\"javascript:saveMethod(this.value)\"")%>
						<%=fb.button("addFactura","Facturas Canceladas",(!viewMode),viewMode,null,null,"onClick=\"javascript:showFactura()\"","Facturas Canceladas")%>
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
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
	%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/list_capitation_axa.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/list_capitation_axa.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/caja/list_capitation_axa.jsp';
<%
		}
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&secuencia=<%=secuencia%>&anio=<%=anio%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>