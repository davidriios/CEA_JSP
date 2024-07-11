<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario*** */

UserDet = SecMgr.getUserDetails(session.getId());  /* *** quitar el comentario **** */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String fg = request.getParameter("fg");
String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}
if (mode == null) mode = "add";
if (fg == null) fg = "";
ArrayList alWh = new ArrayList();
ArrayList alFlia = new ArrayList();
StringBuffer sbSql = new StringBuffer();
if(fg.trim().equals("CO")||fg.trim().equals("COF")){
sbSql.append("select codigo_almacen as optValueColumn, descripcion||' [ '||codigo_almacen||' ]' as optLabelColumn from tbl_inv_almacen where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" order by 1");
alWh = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
sbSql = new StringBuffer();
sbSql.append("select cod_flia as optValueColumn, nombre||' [ '||cod_flia||' ]' as optLabelColumn from tbl_inv_familia_articulo where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and tipo_servicio in ('02','03','04')order by 1");
alFlia = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
}
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Consumo por Centro de Servicio - '+document.title;
function doAction()
{
}

function showReporte(value,printRes)
{
  var categoria    ='';
  var tipoFecha ='';
  var area         = document.form0.area.value;
  var ts     = document.form0.ts.value;
  var fechaini     = document.form0.fechaini.value;
  var fechafin     = document.form0.fechafin.value;
  var consignacion ='';
  var comprob='';
  if(document.form0.consignacion)consignacion =document.form0.consignacion.value;
  if(document.form0.categoria)categoria =document.form0.categoria.value;
  if(document.form0.tipoFecha)tipoFecha =document.form0.tipoFecha.value;
  if(document.form0.comprob)comprob =document.form0.comprob.value;
  var doc_type = '';
  var rep_type = '';
  var comprobante = '',afectaConta='';
  var fg='', cargosFact='', aseguradora="ALL",wh="",codFlia="",admision="",pacId="";
  if(document.form0.doc_type)doc_type =document.form0.doc_type.value;
  if(document.form0.rep_type)rep_type =document.form0.rep_type.value;
  if(document.form0.comprobante)comprobante =document.form0.comprobante.value;
  if(document.form0.afectaConta)afectaConta =document.form0.afectaConta.value;
  if(document.form0.cargosFact)cargosFact =document.form0.cargosFact.value;
  if(document.form0.aseguradora)aseguradora =document.form0.aseguradora.value;
  if(document.form0.wh)wh =document.form0.wh.value;
  if(document.form0.codFlia)codFlia =document.form0.codFlia.value;
  if(document.form0.pacId)pacId =document.form0.pacId.value;
  if(document.form0.admision)admision =document.form0.admision.value;
var descAseg = '';
  
  if(document.form0.aseguradora)descAseg=getSelectedOptionTitle(document.form0.aseguradora,''); 
  
  var _printRes = printRes||"";
	if(value=="1" || value == "15" ||  value == "16")
	{
    if(value != "15" && value != "16") abrir_ventana2('../facturacion/print_consumo_x_centro_pacte.jsp?categoria='+categoria+'&area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&ts='+ts+'&tipoFecha='+tipoFecha+'&printRes='+_printRes+'&codFlia='+codFlia+'&wh='+wh+'&consignacion='+consignacion+'&pacId='+pacId+'&admision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
    else {
      categoria = categoria || 'ALL';
      area = area || 'ALL';
      fechaini = fechaini || 'ALL';
      fechafin = fechafin || 'ALL';
      ts = ts || 'ALL';
      tipoFecha = tipoFecha || 'ALL';
      printRes = printRes || 'ALL';
      codFlia = codFlia || 'ALL';
      wh = wh || 'ALL';
      consignacion = consignacion || 'ALL';
      pacId = pacId || 'ALL';
      admision = admision || 'ALL';
      aseguradora = aseguradora || 'ALL';
      descAseg = descAseg || 'ALL';
      
      if(value == "15")
        abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/print_consumo_x_centro_pacte.rptdesign&cdsDet=<%=cdsDet%>&pCtrlHeader=true&categoria='+categoria+'&area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&ts='+ts+'&tipoFecha='+tipoFecha+'&printRes='+_printRes+'&codFlia='+codFlia+'&wh='+wh+'&consignacion='+consignacion+'&pacId='+pacId+'&admision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
      else 
        abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/print_consumo_x_centro_pacte_res.rptdesign&cdsDet=<%=cdsDet%>&pCtrlHeader=true&categoria='+categoria+'&area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&ts='+ts+'&tipoFecha='+tipoFecha+'&printRes='+_printRes+'&codFlia='+codFlia+'&wh='+wh+'&consignacion='+consignacion+'&pacId='+pacId+'&admision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
    }
	}
	else if(value=="2")
	{
 	abrir_ventana2('../facturacion/print_cargos_x_cds_in_out.jsp?admType='+categoria+'&cds='+area+'&xDate='+fechaini+'&tDate='+fechafin+'&tipoFecha='+tipoFecha+'&ts='+ts+'&cargosFact='+cargosFact+'&aseguradora='+aseguradora+'&pDescAseg='+descAseg);
	}
	else if(value=="3")
	{
 	abrir_ventana2('../facturacion/print_ingresos_x_centros.jsp?admType='+categoria+'&cds='+area+'&xDate='+fechaini+'&tDate='+fechafin+'&tipoFecha='+tipoFecha+'&ts='+ts+'&aseguradora='+aseguradora+'&pDescAseg='+descAseg);
	}
	else if(value=="4")
	{
 	abrir_ventana2('../facturacion/print_ingresos_x_centros.jsp?admType='+categoria+'&cds='+area+'&xDate='+fechaini+'&tDate='+fechafin+'&tipoFecha='+tipoFecha+'&ts='+ts+'&cargosFact='+cargosFact+'&aseguradora='+aseguradora+'&pDescAseg='+descAseg);
	}
	else if(value=="7")
	{
 	abrir_ventana2('../facturacion/print_ingresos_x_centros.jsp?fp=DET&admType='+categoria+'&cds='+area+'&xDate='+fechaini+'&tDate='+fechafin+'&tipoFecha='+tipoFecha+'&ts='+ts+'&cargosFact='+cargosFact+'&aseguradora='+aseguradora+'&pDescAseg='+descAseg);
	}
	else if(value=="5")
	{
	abrir_ventana2('../contabilidad/print_costo_cargos_pacientes.jsp?area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&ts='+ts+'&consignacion='+consignacion+'&tipoFecha='+tipoFecha+'&comprob='+comprob+'&afectaConta='+afectaConta+'&codFlia='+codFlia+'&wh='+wh+'&pacId='+pacId+'&admision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
	}
	else if(value=="9")
	{
 	 
	abrir_ventana2('../facturacion/print_consumo_x_centro_pacte.jsp?fg=COSTO&categoria='+categoria+'&area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&ts='+ts+'&tipoFecha='+tipoFecha+'&fp=COSTOPAC&comprob='+comprob+'&afectaConta='+afectaConta+'&codFlia='+codFlia+'&wh='+wh+'&consignacion='+consignacion+'&pacId='+pacId+'&admision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
	}
	else if(value=="8")
	{ 
	abrir_ventana2('../facturacion/print_consumo_x_centro_pacte.jsp?fg=COSTO&categoria='+categoria+'&area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&ts='+ts+'&tipoFecha='+tipoFecha+'&fp=COSTOINV&comprob='+comprob+'&afectaConta='+afectaConta+'&codFlia='+codFlia+'&wh='+wh+'&consignacion='+consignacion+'&pacId='+pacId+'&admision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
	}
	else if(value=="6" || value=="17" || value=="18")
	{
    if(value != "17" && value != "18") abrir_ventana2('../facturacion/print_consumo_x_centro_pacte.jsp?fg=COSTO&categoria='+categoria+'&area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&ts='+ts+'&tipoFecha='+tipoFecha+'&comprob='+comprob+'&afectaConta='+afectaConta+'&printRes='+_printRes+'&codFlia='+codFlia+'&wh='+wh+'&consignacion='+consignacion+'&pacId='+pacId+'&admision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
    else {
      categoria = categoria || 'ALL';
      area = area || 'ALL';
      fechaini = fechaini || 'ALL';
      fechafin = fechafin || 'ALL';
      ts = ts || 'ALL';
      tipoFecha = tipoFecha || 'ALL';
      printRes = printRes || 'ALL';
      codFlia = codFlia || 'ALL';
      wh = wh || 'ALL';
      consignacion = consignacion || 'ALL';
      pacId = pacId || 'ALL';
      admision = admision || 'ALL';
      aseguradora = aseguradora || 'ALL';
      descAseg = descAseg || 'ALL';
      
      if(value == "17")
        abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/print_consumo_x_centro_pacte_costo.rptdesign&cdsDet=<%=cdsDet%>&pCtrlHeader=true&categoria='+categoria+'&area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&ts='+ts+'&tipoFecha='+tipoFecha+'&printRes='+_printRes+'&codFlia='+codFlia+'&wh='+wh+'&consignacion='+consignacion+'&pacId='+pacId+'&admision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
      else 
        abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/print_consumo_x_centro_pacte_costo_res.rptdesign&cdsDet=<%=cdsDet%>&pCtrlHeader=true&categoria='+categoria+'&area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&ts='+ts+'&tipoFecha='+tipoFecha+'&printRes='+_printRes+'&codFlia='+codFlia+'&wh='+wh+'&consignacion='+consignacion+'&pacId='+pacId+'&admision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
    }
	}
	else if(value=="10")
	{
 	abrir_ventana2('../facturacion/print_ingresos_x_centros.jsp?cds='+area+'&xDate='+fechaini+'&tDate='+fechafin+'&tipoFecha='+tipoFecha+'&fg=POS&ts='+ts+'&aseguradora='+aseguradora+'&pDescAseg='+descAseg);
	}
	else if(value=='11' || value=='12')
	{
 	if(value=='11')fg='CDS';else fg='INV';
	abrir_ventana2('../facturacion/print_costo_otros_cliente.jsp?cds='+area+'&fechaIni='+fechaini+'&fechaFin='+fechafin+'&tipoFecha='+tipoFecha+'&fg='+fg+'&rep_type='+rep_type+'&comprobante='+comprobante+'&doc_type='+doc_type+'&cds='+area+'&ts='+ts+'&afectaConta='+afectaConta+'&codFlia='+codFlia+'&wh='+wh);
	}
	else if(value=="13")
	{
	var pCtrlHeader = false;
	if(document.form0.pCtrlHeader.checked==true) pCtrlHeader = "true";
	var usar_fecha_fact = (document.form0.usar_fecha_fact.checked?'S':'N');
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/consumo_x_cds_pac_fact.rptdesign&categoriaParam='+categoria+'&cdsParam='+area+'&tsParam='+ts+'&fechaDesdeParam='+fechaini+'&fechaHastaParam='+fechafin+'&tipoFechaParam='+tipoFecha+'&cdsDetParam=<%=cdsDet%>&pCtrlHeader='+pCtrlHeader);
	//abrir_ventana2('../facturacion/print_consumo_x_centro_pacte_fact.jsp?categoria='+categoria+'&area='+area+'&fechaini='+fechaini+'&fechafin='+fechafin+'&ts='+ts+'&tipoFecha='+tipoFecha+'&usar_fecha_fact='+usar_fecha_fact);
	} else if(value=="14")
	{
		var fechainih = document.form0.fechainih.value;
		var fechafinh = document.form0.fechafinh.value;
 	abrir_ventana2('../facturacion/print_cargos_resumidos.jsp?categoria='+categoria+'&area='+area+'&fechaini='+fechainih+'&fechafin='+fechafinh+'&ts='+ts+'&tipoFecha='+tipoFecha);
	}
	
}

function showExcel(value)
{
  var categoria    ='';
  var tipoFecha ='';
  var area         = document.form0.area.value;
  var ts     = document.form0.ts.value;
  var fechaini     = document.form0.fechaini.value;
  var fechafin     = document.form0.fechafin.value;
  var consignacion ='';
  var comprob='';
  if(document.form0.consignacion)consignacion =document.form0.consignacion.value;
  if(document.form0.categoria)categoria =document.form0.categoria.value;
  if(document.form0.tipoFecha)tipoFecha =document.form0.tipoFecha.value;
  if(document.form0.comprob)comprob =document.form0.comprob.value;
  var doc_type = '';
  var rep_type = '';
  var comprobante = '',afectaConta='';
  var fg='', cargosFact='', aseguradora="ALL",wh="",codFlia="",admision="",pacId="";
  if(document.form0.doc_type)doc_type =document.form0.doc_type.value;
  if(document.form0.rep_type)rep_type =document.form0.rep_type.value;
  if(document.form0.comprobante)comprobante =document.form0.comprobante.value;
  if(document.form0.afectaConta)afectaConta =document.form0.afectaConta.value;
  if(document.form0.wh)wh =document.form0.wh.value;
  if(document.form0.codFlia)codFlia =document.form0.codFlia.value;
  if(document.form0.pacId)pacId =document.form0.pacId.value;
  if(document.form0.admision)admision =document.form0.admision.value;
  if(document.form0.aseguradora)aseguradora =document.form0.aseguradora.value;
  var descAseg = ''; 
  if(document.form0.aseguradora)descAseg=getSelectedOptionTitle(document.form0.aseguradora,''); 
  var pCtrlHeader = false;
	if(document.form0.pCtrlHeader.checked==true) pCtrlHeader = "true";
	if(value=="4"){
		abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/ingresos_x_centros.rptdesign&cdsDet=<%=cdsDet%>&tipoFecha='+tipoFecha+'&fDate='+fechaini+'&tDate='+fechafin+'&cds='+area+'&admType='+categoria+'&ts='+ts+'&cargosFact='+cargosFact+'&pCtrlHeader='+pCtrlHeader+'&aseguradora='+aseguradora);
	}else if(value=="5")
	{ 	
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_costo_cargos_pacientes.rptdesign&paramCDS='+area+'&paramFDesde='+fechaini+'&paramFHasta='+fechafin+'&paramTipoServ='+ts+'&paramConsignacion='+consignacion+'&pCtrlHeader='+pCtrlHeader+'&paramTipoFecha='+tipoFecha+'&paramComprob='+comprob+'&paramAfectaConta='+afectaConta+'&paramCdsDet=<%=cdsDet%>&pFlia='+codFlia+'&pWh='+wh+'&pPacId='+pacId+'&pAdmision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
	}
	else if(value=="55")
	{
 	
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_costo_cargos_pacientes_proc.rptdesign&paramCDS='+area+'&paramFDesde='+fechaini+'&paramFHasta='+fechafin+'&paramTipoServ='+ts+'&paramConsignacion='+consignacion+'&pCtrlHeader='+pCtrlHeader+'&paramTipoFecha='+tipoFecha+'&paramComprob='+comprob+'&paramAfectaConta='+afectaConta+'&paramCdsDet=<%=cdsDet%>&pFlia='+codFlia+'&pWh='+wh+'&pPacId='+pacId+'&pAdmision='+admision);
	}
	else if(value=="9")
	{
 	
abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_consumo_x_centro_pacte.rptdesign&paramCDS='+area+'&paramFDesde='+fechaini+'&paramFHasta='+fechafin+'&paramTipoServ='+ts+'&paramCategoria='+categoria+'&paramTipoFecha='+tipoFecha+'&pCtrlHeader='+pCtrlHeader+'&paramComprob='+comprob+'&paramAfectaConta='+afectaConta+'&paramCdsDet=<%=cdsDet%>&pConsignacion='+consignacion+'&pFlia='+codFlia+'&pWh='+wh+'&pPacId='+pacId+'&pAdmision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg+'&fg=COSTO&fp=COSTOPAC');
	}
	else if(value=="99")
	{ 	
abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_consumo_x_centro_pacte.rptdesign&paramCDS='+area+'&paramFDesde='+fechaini+'&paramFHasta='+fechafin+'&paramTipoServ='+ts+'&paramCategoria='+categoria+'&paramTipoFecha='+tipoFecha+'&pCtrlHeader='+pCtrlHeader+'&paramComprob='+comprob+'&paramAfectaConta=&paramCdsDet=<%=cdsDet%>&pConsignacion=&pFlia=&pWh='+wh+'&pPacId='+pacId+'&pAdmision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg+'&fg=COSTO&fp=COSTO_TRX');
   	}
	else if(value=="8")
	{
 	
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_consumo_x_centro_pacte_inv.rptdesign&paramCDS='+area+'&paramFDesde='+fechaini+'&paramFHasta='+fechafin+'&paramTipoServ='+ts+'&paramCategoria='+categoria+'&paramTipoFecha='+tipoFecha+'&paramComprob='+comprob+'&pCtrlHeader='+pCtrlHeader+'&paramAfectaConta='+afectaConta+'&paramCdsDet=<%=cdsDet%>&pFlia='+codFlia+'&pWh='+wh+'&pPacId='+pacId+'&pAdmision='+admision+'&pAseguradora='+aseguradora+'&pDescAseg='+descAseg);
	}
	else if(value=='11' || value=='12')
	{
 	if(value=='11')fg='CDS';else fg='INV';
	if(rep_type=='D')
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_costo_otros_clientes.rptdesign&paramCDS='+area+'&paramFDesde='+fechaini+'&paramFHasta='+fechafin+'&paramTipoServ='+ts+'&paramTipoDocto='+doc_type+'&paramCostoCero=N&paramComprob='+comprob+'&paramAfectaConta='+afectaConta+'&paramFG='+fg+'&pCtrlHeader='+pCtrlHeader+'&pFlia='+codFlia+'&pWh='+wh);
	else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_costo_otros_clientes_res.rptdesign&paramCDS='+area+'&paramFDesde='+fechaini+'&paramFHasta='+fechafin+'&paramTipoServ='+ts+'&paramTipoDocto='+doc_type+'&paramCostoCero=N&paramComprob='+comprob+'&paramAfectaConta='+afectaConta+'&paramFG='+fg+'&pCtrlHeader='+pCtrlHeader+'&pFlia='+codFlia+'&pWh='+wh);
	
	//abrir_ventana2('../facturacion/print_costo_otros_cliente.jsp?cds='+area+'&fechaIni='+fechaini+'&fechaFin='+fechafin+'&tipoFecha='+tipoFecha+'&fg='+fg+'&rep_type='+rep_type+'&comprobante='+comprobante+'&doc_type='+doc_type+'&cds='+area+'&ts='+ts+'&afectaConta='+afectaConta);
	}	
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="POR CENTRO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
<tr>
 <td>
   <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

				<tr class="TextFilter">
				    <td width="8%"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A'  and compania_unorg = "+(String)session.getAttribute("_companyId")+" order by 2","area",area,"T")%>
					</td>
				</tr>
				<tr class="TextFilter">
				    <td width="8%"><cellbytelabel>Tipo de Servicio</cellbytelabel></td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_tipo_servicio where compania = "+(String) session.getAttribute("_companyId")+"  order by 2","ts","","T")%>
					</td>
				</tr>
 <%if(!fg.trim().equals("CO")){%>
			  <tr class="TextFilter" >
				   <td width="8">Categoría</td>
				   <td width="92%">
				  
           <%if(!fg.trim().equals("CA")){%>
		<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
				   <%}else{%>
           <%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
				 
           <%}%>
           </td>
			  </tr>
<%}%>

				<tr class="TextFilter" >
				   <td width="50%"><cellbytelabel>Fecha</cellbytelabel></td>
				   <td width="50%">
						<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="2" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fechaini" />
							<jsp:param name="valueOfTBox1" value="<%=(fg.trim().equals("CA"))?"":cDateTime%>" />
							<jsp:param name="nameOfTBox2" value="fechafin" />
							<jsp:param name="valueOfTBox2" value="<%=(fg.trim().equals("CA"))?"":cDateTime%>" />
						</jsp:include>
		           </td>
			  </tr>
			  <tr class="TextFilter" >
				   <td width="50%"><cellbytelabel>Tipo de Fecha</cellbytelabel></td>
				   <td width="50%"><%=fb.select("tipoFecha","C=CARGO,CC=CREACION","CC",false,false,0,"Text10",null,null,null,"")%>
		           </td>
			  </tr>
				<%if(fg.trim().equals("CA")){%>
			  <tr class="TextFilter" >
				   <td width="50%"><cellbytelabel>Cargos:</cellbytelabel></td>
				   <td width="50%"><%=fb.select("cargosFact","S=FACTURADOS,N=NO FACTURADOS","",false,false,0,"Text10",null,null,null,"T")%>
		           </td>
			  </tr>
			  <%} else fb.hidden("cargosFact", "");%>
			  <%if(fg.trim().equals("CA")||fg.trim().equals("CO")){%>
			  <tr class="TextFilter" >
				   <td width="50%"><cellbytelabel>Aseguradora:</cellbytelabel></td>
				   <td width="50%"><%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa, nombre||' - '||codigo as label from tbl_adm_empresa order by 2","aseguradora",aseguradora,"T")%>
		           </td>
			  </tr>
			  <%}%>
			  <%if(fg.trim().equals("CO")){%>
			  <tr class="TextFilter" >
				   <td><cellbytelabel>Consignaci&oacute;n</cellbytelabel></td>
				   <td><%=fb.select("consignacion","S=SI,N=NO","N","T")%></td>
			  </tr>
			  <tr class="TextFilter" >
				   <td><cellbytelabel>Comprobante</cellbytelabel></td>
				   <td><%=fb.select("comprob","S=SI,N=NO","","T")%></td>
			  </tr>
			  <tr class="TextFilter">
				<td>Afecta Contabilidad</td>
				<td><%=fb.select("afectaConta","Y=SI,N=NO","Y","")%></td>
			  </tr>
			  <tr class="TextFilter">
				<td>Almacen</td>
				<td> <%=fb.select("wh",alWh,"",false,false,false,0,"Text10","","","","T")%></td>
			  </tr>
			  <tr class="TextFilter">
				<td>Familia</td>
				<td> <%=fb.select("codFlia",alFlia,"",false,false,false,0,"Text10","","","","T")%></td>
			  </tr> <%}%>
			  <%if(fg.trim().equals("CO")||fg.trim().equals("COF")){%> 
			  <tr class="TextFilter">
				<td>Paciente</td>
				<td> <%=fb.intBox("pacId","",false,false,false,7)%>Admision:<%=fb.intBox("admision","",false,false,false,7)%></td>
			  </tr>
			 <%}%>
			  <tr class="TextFilter" align="left">
                            <td>Esconder Cabecera?</td>
							<td><%=fb.checkbox("pCtrlHeader","false")%></td>
                          </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTES</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2">
				<%if(!fg.trim().equals("CA")&&!fg.trim().equals("CO")&&!fg.trim().equals("COF")){%>
      	<%=fb.radio("reporte1","1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Cargos a Pacientes 
      	<%=fb.radio("reporte1","15",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Excel
      	<br>
		<%=fb.radio("reporte1","1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value,'S')\"")%>Cargos a Pacientes - Resumido por CDS
		<%=fb.radio("reporte1","16",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value,'S')\"")%>Excel
		<br>
		<authtype type='55'>
		<%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Costos de Cargos a Pacientes</cellbytelabel>
		<%=fb.radio("reporte1","17",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Excel</cellbytelabel>
		<br>
		<%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value,'S')\"")%><cellbytelabel>Costos de Cargos a Pacientes - Resumido por CDS</cellbytelabel>
		<%=fb.radio("reporte1","18",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value,'S')\"")%><cellbytelabel>Excel</cellbytelabel>
		</authtype>
		<br>
		<authtype type='58'><%=fb.radio("reporte1","13",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Cargos a Pacientes Facturados &nbsp;&nbsp;&nbsp;<%=fb.checkbox("usar_fecha_fact","")%>Usar Fecha de Facturacion</cellbytelabel></authtype>
		<br>
		
		<authtype type='59'><%=fb.radio("reporte1","14",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Cargos Resumidos</cellbytelabel>
						<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="2" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
							<jsp:param name="nameOfTBox1" value="fechainih" />
							<jsp:param name="valueOfTBox1" value="" />
							<jsp:param name="nameOfTBox2" value="fechafinh" />
							<jsp:param name="valueOfTBox2" value="" />
						</jsp:include>
		
		</authtype>
		
		
					
				<%}else if(fg.trim().equals("CO")||fg.trim().equals("COF")){%>
				<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<%if(fg.trim().equals("CO")){%>
				<tr>
				<td width="45%">
      	<%=(fg.trim().equals("CO"))?fb.radio("reporte1","5",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\""):""%>
				<cellbytelabel>Costos de Cargos a Pacientes - Inventarios</cellbytelabel>
				&nbsp;&nbsp;&nbsp; <a href="javascript:showExcel(5)" class="Link00"> Excel </a> 
				</td>
				<td width="55%" valign="top">&nbsp;***Para Comparar diferencias con comprobante de costos.. </td>
				<tr>
				<td>
				<authtype type='56'>
				<%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>
				<cellbytelabel>Costos de Cargos a Pacientes (Cuentas por Centro)
				&nbsp;&nbsp;&nbsp; <a href="javascript:showExcel(9)" class="Link00"> Excel </a></cellbytelabel></authtype>
				</br>
				<authtype type='57'>
				<%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>
				<cellbytelabel>Costos de Cargos a Pacientes (Cuentas de Inventario)
				&nbsp;&nbsp;&nbsp; <a href="javascript:showExcel(8)" class="Link00"> Excel </a></cellbytelabel>
				</authtype></br>
				</td>
				<td valign="top">
				Costo de  TRX distintos de Articulos<a href="javascript:showExcel(99)" class="Link00"> Excel </a></cellbytelabel></authtype>
				
				</td>
				</tr>
				<tr>
				<td>
      	<authtype type='58'>
				<%=fb.radio("reporte1","11",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>
				<cellbytelabel>Costos de Cargos a Otros cliente (Cuentas por Centro)
				&nbsp;&nbsp;&nbsp; <a href="javascript:showExcel(11)" class="Link00"> Excel </a></cellbytelabel>
				</authtype></br>
				<authtype type='59'>
				<%=fb.radio("reporte1","12",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>
				<cellbytelabel>Costos de Cargos a Otros cliente (Cuentas de Inventario)
				&nbsp;&nbsp;&nbsp; <a href="javascript:showExcel(12)" class="Link00"> Excel </a></cellbytelabel>
				</authtype>
				
				<td> Tipo Doc.	<%=fb.select("doc_type","FAC=FACTURA,NCR=NOTA CREDITO,NDB=NOTA DEBITO","T",false,false,0,"Text10",null,null,null,"T")%>	
						&nbsp; Reporte	<%=fb.select("rep_type","D=DETALLADO,R=RESUMIDO","",false,false,0,"Text10",null,null,null,"")%>	
						&nbsp;Comprobante	<%=fb.select("comprobante","S=SI,N=NO","T",false,false,0,"Text10",null,null,null,"T")%>
						</td>
				</tr>
				
				<%}else{%>
				<tr>
				<td width="45%"> 
				<cellbytelabel>Costos de Cargos a Pacientes</cellbytelabel>
				&nbsp;&nbsp;&nbsp; <a href="javascript:showExcel(55)" class="Link00"> Excel </a>
				</br> 
				</td>
				<td width="55%">&nbsp;</td>
				</tr>
				<%}%>
				</table>
				
				<%}else{%>
        <%=fb.radio("reporte1","1",false,false,false,null,null,"onClick=\"javascript:showReporte(2)\"")%> <cellbytelabel>Ingresos</cellbytelabel> <br>
        <%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(3)\"")%> <cellbytelabel>Ingresos por Centros y Tipo de Servicios</cellbytelabel><authtype type='56'><br><%=fb.radio("reporte1","10",false,false,false,null,null,"onClick=\"javascript:showReporte(10)\"")%> <cellbytelabel>Ingresos por Centros y Tipo de Servicios(POS)</cellbytelabel></br></authtype>
		<%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(7)\"")%> <cellbytelabel>Ingresos Detallado (paciente,cargo,cuenta)</cellbytelabel></br>
		<%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(4)\"")%> <cellbytelabel>Ingresos por Centros</cellbytelabel>&nbsp;&nbsp;&nbsp; <a href="javascript:showExcel(4)" class="Link00"> Excel </a>
				<%}%>
        	</td>
        </tr>

<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</td>
	</tr>
	</td>
	</tr>

</table>
</body>
</html>
<%
}//GET
%>
