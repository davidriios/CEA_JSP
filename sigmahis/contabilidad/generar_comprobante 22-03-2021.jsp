<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================================================
==================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

String key = "";
StringBuilder sbSql = new StringBuilder();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}
String usaPlanMedico = "N";
try { usaPlanMedico = java.util.ResourceBundle.getBundle("planmedico").getString("usaPlanMedico"); } catch (Exception ex) { }

if(fg==null) fg = "mes";
if(fp==null) fp ="INV";

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha = cDateTime;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CON_RECEP_INCLU_ITBM'),'N') as inclTax, nvl(get_sec_comp_param(-1,'VER_COMISION_ITBM_LIBRO_CAJA'),'N') as VER_COMISION_ITBM_LIBRO_CAJA, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'PM_CLASE_COMPROB'),'-1') as clase_comprob_pm, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'INT_REPL_DBLINK'),'-') as dblink,nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CON_VER_PAQ'),'S') as verPaq   from dual");
	cdo = SQLMgr.getData(sbSql.toString());
	if (cdo == null) {
	
		cdo = new CommonDataObject();
		cdo.addColValue("inclTax","N");
		cdo.addColValue("VER_COMISION_ITBM_LIBRO_CAJA","N");		
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Contabilidad - '+document.title;
function doAction(){}
function runProcess(baction){var x=0;var anio='';var fecha	= document.form1.fecha_desde.value;var v_tipo ='';var fecha_hasta	= document.form1.fecha_hasta.value;var accion='';var actType ='';var msg =' generar comprobante';
if(baction=='COMP'){if(fecha!=''){anio=fecha.substring(6);var cuentas=getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_plan_cuentas','compania=<%=session.getAttribute("_companyId")%> and ano = ' + anio,'');if(parseInt(cuentas) ==0 )x++;}if(eval('document.form1.process')){for(i=0;i<document.form1.process.length;i++){if(eval('document.form1.process')[i].checked){accion=eval('document.form1.process')[i].value;break;}}}}else{accion = baction;}if(x==0){if(accion !=''){if(fecha == '' || fecha_hasta ==''  ) alert('Los parámetros no están completos...,VERIFIQUE!');		else{if(accion=='LI'){v_tipo = '5';actType ='50';}else if(accion=='RM'){v_tipo = '7';actType ='51';}else if(accion=='TA'){v_tipo = '14';actType ='52';}else if(accion=='EU'){v_tipo = '9';actType ='57';}else if(accion=='EP'){v_tipo = '10';actType ='53';}else if(accion=='GA'){v_tipo = '27';actType ='54';}else if(accion=='GENLIB'){v_tipo = '';actType ='55';msg =' generar el Libro de Ingreso para éste Rango de Fecha ';}else if(accion=='ANLIB'){v_tipo = '';actType ='56';msg =' Anular Libro de Ingreso para éste Rango de Fecha ';}else if(accion=='CL'){ actType ='59'; v_tipo ='2';}else if(accion=='CK'){ actType ='60'; v_tipo ='3';}else if(accion=='AJS'){ actType ='62'; v_tipo ='20';}else if(accion=='PM'){ actType ='63'; v_tipo ='<%=cdo.getColValue("clase_comprob_pm")%>';}else if(accion=='COF'){ actType ='64'; v_tipo ='-1';}else if(accion=='GANPER'){ actType ='65'; v_tipo ='32';}
if(confirm('¿Esta seguro de  '+msg+'?')){
	if(accion=='GENLIB'||accion=='ANLIB'){
		showPopWin('../process/con_gen_libro_ingreso.jsp?actType='+actType+'&compania=<%=(String) session.getAttribute("_companyId")%>&fechaIni='+fecha+'&fechaFin='+fecha_hasta,winWidth*.75,winHeight*.50,null,null,'');
	}else{
		showPopWin('../process/con_gen_comprob.jsp?actType='+actType+'&tipo='+v_tipo+'&compania=<%=(String) session.getAttribute("_companyId")%>&fechaIni='+fecha+'&fechaFin='+fecha_hasta,winWidth*.75,winHeight*.50,null,null,'');
	}/*else{
		showPopWin('../common/run_process.jsp?fp=COMP&actType='+actType+'&docType=GENCOMP&docId='+accion+'&docNo='+v_tipo+'&tipo='+v_tipo+'&fechaIni='+fecha+'&fechaFin='+fecha_hasta+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.50,null,null,'');
	}*/
}else alert('Proceso Cancelado');}}else alert('Seleccione Proceso a Ejecutar ');}else{alert('No puede generar Comprobante. El año debe estar activo Ó en Transicion.!!');}}

function verTrx(fg){var fecha= document.form1.fecha_desde.value;var	fecha_hasta	= document.form1.fecha_hasta.value;var consignacion = 'N';var tipoFecha ='CC';var tipoReporte=''; var pCtrlHeader='false'; if(document.form1.consignacion) consignacion=document.form1.consignacion.value;if(document.form1.tipoFecha) tipoFecha=document.form1.tipoFecha.value;if(document.form1.tipoReporte) tipoReporte=document.form1.tipoReporte.value;if(document.form1.pCtrlHeader.checked==true) pCtrlHeader = "true";var comprob='';if(document.form1.comprob) comprob=document.form1.comprob.value;if(comprob=='')comprob='ALL';if(consignacion=='')consignacion='ALL';var afectaConta ='';if(document.form1.afectaConta) afectaConta=document.form1.afectaConta.value;if(afectaConta=='')afectaConta='ALL';var pTipoAdm =document.form1.categoria.value || 'ALL';
if(fecha == '' || fecha_hasta ==''  ) alert('Los parámetros no están completos...,VERIFIQUE!');else{if(fg=='LIB')abrir_ventana('../contabilidad/libro_ingreso_detail.jsp?xDate='+fecha+'&toDate='+fecha_hasta);else if(fg=='GASER')abrir_ventana('../contabilidad/print_comprob_servicios.jsp?xDate='+fecha+'&toDate='+fecha_hasta+'&comprob='+comprob);else if(fg=='COPAC'){ if(afectaConta=='S')afectaConta='Y'; abrir_ventana('../facturacion/print_consumo_x_centro_pacte.jsp?fg=COSTO&fp=COSTOPAC&fechaini='+fecha+'&fechafin='+fecha_hasta+'&consignacion='+consignacion+'&tipoFecha='+tipoFecha+'&afectaConta='+afectaConta);}
else if(fg=="COPACBI"||fg=="COPACBIC"||fg=="COPACBIC2"||fg=="COPACBI3"||fg=="COPACBI_RES"){var costoCero ='ALL';if(fg=="COPACBI3")costoCero ='S';
var fdArray = fecha.split("/");
	var fhArray = fecha_hasta.split("/");
	fecha = fdArray[2]+"-"+fdArray[1]+"-"+fdArray[0];
	fecha_hasta = fhArray[2]+"-"+fhArray[1]+"-"+fhArray[0];
//abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_intrega_mat_pac.rptdesign&pConsig='+consignacion+'&pDateType='+tipoFecha+'&fDesde='+fecha+'&fHasta='+fecha_hasta+'&pCtrlHeader='+pCtrlHeader+'&comprob='+comprob+'&pAfectaConta='+afectaConta+'&costocero='+costoCero+'&pAdmType='+pTipoAdm);
if (fg=="COPACBI_RES") abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_costos_pacientes_unif_res.rptdesign&pConsig='+consignacion+'&pDateType='+tipoFecha+'&fDesde='+fecha+'&fHasta='+fecha_hasta+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob+'&pAfectaConta='+afectaConta+'&pCostoCero='+costoCero+'&pAdmType='+pTipoAdm+'&pCds=<%=cdsDet%>&pType=TRANS_UNI');
else if (fg=="COPACBIC")abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_costos_pacientes_unif_det.rptdesign&pConsig='+consignacion+'&pDateType='+tipoFecha+'&fDesde='+fecha+'&fHasta='+fecha_hasta+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob+'&pAfectaConta='+afectaConta+'&pCostoCero='+costoCero+'&pAdmType='+pTipoAdm+'&pCds=<%=cdsDet%>&pType=TRANS_UNI');
else if (fg=="COPACBIC2")abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_costos_pacientes_unif_det2.rptdesign&pConsig='+consignacion+'&pDateType='+tipoFecha+'&fDesde='+fecha+'&fHasta='+fecha_hasta+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob+'&pAfectaConta='+afectaConta+'&pCostoCero='+costoCero+'&pAdmType='+pTipoAdm+'&pCds=<%=cdsDet%>&pType=TRANS_UNI');
else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_costos_pacientes_unif.rptdesign&pConsig='+consignacion+'&pDateType='+tipoFecha+'&fDesde='+fecha+'&fHasta='+fecha_hasta+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob+'&pAfectaConta='+afectaConta+'&pCostoCero='+costoCero+'&pAdmType='+pTipoAdm+'&pCds=<%=cdsDet%>&pType=TRANS_UNI');
 



}else if(fg=='COPACBI2'){
 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_intrega_mat_pac_res.rptdesign&pConsig='+consignacion+'&pDateType='+tipoFecha+'&fDesde='+fecha+'&fHasta='+fecha_hasta+'&pCtrlHeader='+pCtrlHeader+'&comprob='+comprob+'&pAfectaConta='+afectaConta);
}else if(fg=='POS1'){if(afectaConta=="S")
afectaConta='Y';abrir_ventana2('../facturacion/print_costo_otros_cliente.jsp?fechaIni='+fecha+'&fechaFin='+fecha_hasta+'&tipoFecha='+tipoFecha+'&fg=CDS&comprobante='+comprob+'&doc_type=&afectaConta='+afectaConta);}else if(fg=='POS2'){if(afectaConta=="S")afectaConta='Y';abrir_ventana2('../facturacion/print_costo_otros_cliente.jsp?fechaIni='+fecha+'&fechaFin='+fecha_hasta+'&tipoFecha='+tipoFecha+'&fg=INV&comprobante='+comprob+'&doc_type=&afectaConta='+afectaConta);}
else if(fg=='POS3'){if(afectaConta=="S")afectaConta='Y';abrir_ventana2('../facturacion/print_costo_otros_cliente.jsp?fechaIni='+fecha+'&fechaFin='+fecha_hasta+'&tipoFecha='+tipoFecha+'&fg=INV&comprobante='+comprob+'&doc_type=&afectaConta='+afectaConta+'&costoCero=S');}


}}
function viewReports(fg){
	var fDesde	= document.form1.fecha_desde.value;
	var fDesdeOrg	= document.form1.fecha_desde.value;
	var	fHasta= document.form1.fecha_hasta.value;
	var pType = '';
	var pAccount1 = "";//document.form1.account1.value;
	var pAccount2 = "";//document.form1.account2.value;
	var pAccount3 ="";// document.form1.account3.value;
	var pAccount4 = "";//document.form1.account4.value;
	var pAccount5 = "";//document.form1.account5.value;
	var pAccount6 = "";//document.form1.account6.value;
	var pCtrlHeader = "false";if(document.form1.pCtrlHeader)pCtrlHeader=document.form1.pCtrlHeader.checked;
    var afectaConta ="";if(document.form1.afectaConta)afectaConta=document.form1.afectaConta.value;
    var pTipoAdm ="ALL";if(document.form1.categoria)pTipoAdm=document.form1.categoria.value || 'ALL';
	var consignacion ='';
	//if(document.form1.consignacion) consignacion=document.form1.consignacion.value;
	var pDestino = "";
	if(afectaConta =='')afectaConta='ALL';
	if(consignacion =='')consignacion='ALL';
	var  comprob ='';
	if(document.form1.comprob)comprob=document.form1.comprob.value;
	 if(comprob =='')comprob='ALL';
	if(fg=='RECEP'||fg=='RECEP_RES'||fg=='RECEP_ITEM'){if(document.form1.pType)pType = document.form1.pType.value;pType='ALL';}
	else if(fg=='AJS2'){if(document.form1.pType2)pType = document.form1.pType2.value; pDestino = "H";}
	else if(fg=='SERV'||fg=='SERV_RES')pType = "OTHER";
	else if(fg=='SERV_OLD')pType = "OTHER_OLD";
	else if(fg=='UND'){if(document.form1.tipoReporte)pType = document.form1.tipoReporte.value;}
	else if(fg=='UND2'||fg=='UND2_RES'){pType ='ENTINV_DUINV';}
	else if(fg=='TRANS'){if(document.form1.tipoReporteTr)pType = document.form1.tipoReporteTr.value;}
	else if(fg=='TRANS_UNI'||fg=='TRANS_UNI_RES') pType = 'TRANS_UNI';

	if(pType=='AJS' && (fg=="RECEP"||fg=="RECEP_RES")){pDestino = "P";}
	else if(pType == 'AJS' && fg == "AJS2"){pDestino = "H";}
	else if(pType == 'OTHER'||pType == 'OTHER_OLD'){pDestino = "G";}
	else pDestino = "W";

	var fdArray = fDesde.split("/");
	var fhArray = fHasta.split("/");
	fDesde = fdArray[2]+"-"+fdArray[1]+"-"+fdArray[0];
	fHasta = fhArray[2]+"-"+fhArray[1]+"-"+fhArray[0];

	if (pAccount1=="") pAccount1 = "000";
	if (pAccount2=="") pAccount2 = "00";
	if (pAccount3=="") pAccount3 = "000";
	if (pAccount4=="") pAccount4 = "000";
	if (pAccount5=="") pAccount5 = "000";
	if (pAccount6=="") pAccount6 = "000";

	if(fg=='RECEP'||fg=='RECEP_RES'||fg=='SERV'||fg=='SERV_RES'||fg=='SERV_OLD'||fg=='RECEP_ITEM')
	{
	 var  status =document.form1.status.value;
	 var  tipoAj ='ANF';//document.form1.pTipoAj.value;
	 if(status =='')status='ALL';

		if (pType=="ALL"){
		   if (confirm("Esta opción puede tardar varios minutos, quiere seguir?")){
		   if(fg=='RECEP')
			  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_trx_comprob_recep_unif.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pDestino=P&pInclTax=<%=cdo.getColValue("inclTax")%>');
			  else if (fg=='RECEP_RES') abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_trx_comprob_recep_unif_res.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pDestino=P&pInclTax=<%=cdo.getColValue("inclTax")%>');
			  else if (fg=='RECEP_ITEM') abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_trx_comprob_recep_item.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pCtrlHeader='+pCtrlHeader+'&pCode=0&pAfectaConta='+afectaConta);			  
			  else  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_trx_comprob_recep.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pDestino=P');
		   }else{return false;}
	}
	else if (pType=="OTHER"){
	  if(fg=="SERV_RES")abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_gastos_de_servicios_res.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pDestino='+pDestino);
	  else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_gastos_de_servicios.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pDestino='+pDestino);
	}else if (pType=="OTHER_OLD"){
	  if(fg=="SERV_OLD")abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_trx_comprob_recep_old.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType=OTHER&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj);
	}	
	else if (pType=="OTHER")abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_trx_comprob_recep.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj);

	else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_trx_comprob_recep.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pDestino='+pDestino);
	} //
	else if(fg=='UND')//
	{
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_entre_a_unidades.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta);
	}	
	else if(fg=='UND2')
	{     comprob =document.form1.comprob.value;if(comprob =='')comprob='ALL';
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_entregas_und_unificado.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta);
	}else if(fg=='UND2_RES')
	{     comprob =document.form1.comprob.value;if(comprob =='')comprob='ALL';
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_entregas_und_unificado_res.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta);
	}
	else if(fg=='TRANS')
	{if(document.form1.consignacionTranwh) consignacion=document.form1.consignacionTranwh.value;if(consignacion =='')consignacion='ALL';
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_trx_entre_almacenes.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pConsig='+consignacion);
	}
	
	else if(fg=='TRANS_UNI')
	{if(document.form1.consignacionTranwh) consignacion=document.form1.consignacionTranwh.value;if(consignacion =='')consignacion='ALL';
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_trx_entre_almacenes_uni.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pConsig='+consignacion);
	}
	else if(fg=='TRANS_UNI_RES')
	{	if(document.form1.consignacionTranwh) consignacion=document.form1.consignacionTranwh.value;if(consignacion =='')consignacion='ALL';
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_trx_entre_almacenes_uni_res.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pConsig='+consignacion);
	}
	
	else if(fg=="LIB"||fg=="LIB2"||fg=="LIB3"){
	var _rpt_name ='rpt_libros_ingresos';
	 if(fg=="LIB2")_rpt_name ='rpt_libros_ingresos_cds';
	//if(fg=="LIB3")_rpt_name ='rpt_libros_ingresos_cds_cxc';
	var v_usa_cxc_cliente ='N';
	var p_compania = '<%=(String) session.getAttribute("_companyId")%>';
	v_usa_cxc_cliente=getDBData('<%=request.getContextPath()%>','nvl(get_con_usar_cxc_clte('+p_compania+',\''+fDesdeOrg+'\'),\'N\') ','dual','','');
	
	
	
	 if(fg=="LIB3"){ _rpt_name='rpt_libros_ingresos_det';
		   abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxc/'+_rpt_name+'.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+(!comprob?'ALL':comprob)+'&pTipoAdm='+pTipoAdm+'&pCentro_servicio=-4&v_usa_cxc_cliente='+v_usa_cxc_cliente+'&verPaq=<%=cdo.getColValue("verPaq")%>'+'&pRefId=&pTipo=&pTipoOtro=&pAdmision=&pFacturado=ALL');}

	else 
	   abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/'+_rpt_name+'.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+(!comprob?'ALL':comprob)+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pTipoAdm='+pTipoAdm+'&pCentro_servicio=-4&v_usa_cxc_cliente='+v_usa_cxc_cliente+'&verPaq=<%=cdo.getColValue("verPaq")%>');
	   
	}
	else  if(fg=="AJS2"){ abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_comprobante_ajustes_cxp.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+comprob+'&pTipoAj='+tipoAj+'&pAfectaConta='+afectaConta+'&pDestino='+pDestino);}
	else if(fg=="REPCJA"){ if(document.form1.tipoRepCja.value=='R')abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_libro_caja_res.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob+'&verComisionItbmParam=<%=cdo.getColValue("VER_COMISION_ITBM_LIBRO_CAJA")%>');else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_libro_caja_det.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob); }
	else if(fg=="REPCJA_CTAS"){ if(document.form1.tipoRepCja.value=='R')abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_libro_caja_det_ctas.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob);else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_libro_caja_det.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob); }
	else  if(fg=="PM"){ abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_comprobante_pm.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob);}
	else  if(fg=="PM_RES"){ abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_comprobante_pm_res.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob);}
	else  if(fg=="COF_RES"){fDesde	= document.form1.fecha_desde.value;
	 	fHasta= document.form1.fecha_hasta.value;
	abrir_ventana('../contabilidad/print_comprob_fijo.jsp?fechaIni='+fDesde+'&fechaFin='+fHasta);
	/* abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_comprobante_pm_res.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pCtrlHeader='+pCtrlHeader+'&pComprob='+comprob);*/}
	else  if(fg=="COF_RES2"){ abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_comprobante_fijos.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pCtrlHeader='+pCtrlHeader);}
	else if(fg=="GANPER"){ 
		   abrir_ventana('../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_dist_paquete_det.rptdesign&fDesde='+fDesde+'&fHasta='+fHasta+'&pType='+pType+'&pAccount1='+pAccount1+'&pAccount2='+pAccount2+'&pAccount3='+pAccount3+'&pAccount4='+pAccount4+'&pAccount5='+pAccount5+'&pAccount6='+pAccount6+'&pCtrlHeader='+pCtrlHeader+'&pStatus='+status+'&pComprob='+(!comprob?'ALL':comprob)+'&pTipoAdm='+pTipoAdm+'&pCentro_servicio=-4&v_usa_cxc_cliente=&pRefId=&pTipo=&pTipoOtro=&pAdmision=&pFacturado=ALL');}
	
	
	 
	

}
function eject(accion){
	var p_compania = '<%=(String) session.getAttribute("_companyId")%>';
	var fechaIni	= document.form1.fecha_desde.value;
	var fechaFin	= document.form1.fecha_hasta.value;
	var comprobante = "";if(document.form1.comprob)comprobante=document.form1.comprob.value;
	var count =0;
	var msg2='';
	var v_tipo =4;
	var tipoFecha='CC';if(document.form1.tipoFecha) tipoFecha=document.form1.tipoFecha.value;
    var pCtrlHeader ="false"; if(document.form1.pCtrlHeader)pCtrlHeader=document.form1.pCtrlHeader.checked;

	if(accion=='CM')
	{
		if(fechaIni == '') alert('Los parámetros no están completos...,VERIFIQUE!');
		else
		{
				count=getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_replibros','compania='+p_compania+' and nvl(comprobante,\'N\')= \'S\' and  trunc(fecha)=to_date(\''+fechaIni+'\',\'dd/mm/yyyy\')','');

			if(count == 0)
			{
				count=getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_replibros','compania='+p_compania+' and  trunc(fecha)=to_date(\''+fechaIni+'\',\'dd/mm/yyyy\')','');
				if(count == 0)
				{
				 	msg2 = '¿Desea generar el libro para esta fecha?';
				}else msg2 = '¿Desea generar nuevamente el libro para esta fecha?';
				if(confirm(msg2))
				{
					showPopWin('../common/run_process.jsp?fp=COMP&actType=58&docType=GENCOMP&docId=LIBCJA&docNo=LIBCJA&tipo='+v_tipo+'&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.50,null,null,'');
				}else alert('Proceso Cancelado');
			}else alert('Libro de caja para ese día ya tiene comprobante generado, verifique');
		 }
	}
	else if(accion=='CO')
	{
		abrir_ventana('../caja/libro_caja_detail.jsp?xDate='+fechaIni+'&toDate='+fechaFin);
	}
	else if(accion=='RE')
	{
		abrir_ventana('../caja/print_depositos_x_cajas.jsp?xDate='+fechaIni+'&fechafin='+fechaFin);
	}
	else if(accion=='REC')
	{
		 abrir_ventana2('../caja/print_recibos_x_caja.jsp?fp=reporte&fg=CONT&fechaini='+fechaIni+'&fechafin='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>');
	}
	else if(accion=='PAGOS')
	{
	abrir_ventana2('../caja/print_caja_pagos.jsp?fg=CONT&fechaini='+fechaIni+'&fecha_fin='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>');
	}
	else if(accion=='DEPOSITOS')
	{
	abrir_ventana2('../caja/print_reporte_deposito.jsp?fg=CONT&fechaini='+fechaIni+'&fechafin='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>');
	}
	else if(accion=='DEPBANCO')//
	{
	abrir_ventana2('../contabilidad/print_mov_banco_lib_caja.jsp?fg=BANCO&fechaini='+fechaIni+'&fechafin='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>');
	}
	else if(accion=='CK')
	{
	abrir_ventana2('../cxp/print_list_libro_cheque.jsp?fg=CONT&fDesde='+fechaIni+'&fHasta='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>');
	}
    else if(accion=='CK_E')
	{
      fechaIni = $("#fecha_desde").toRptFormat();
      fechaFin = $("#fecha_hasta").toRptFormat();
      abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxp/print_list_libro_cheque.rptdesign&FG=CONT&fDesde='+fechaIni+'&fHasta='+fechaFin+'&pCtrlHeader='+pCtrlHeader+'&pPlanmedico=<%=usaPlanMedico%>&pComprob='+comprobante);
	}
	else if(accion=='CKREP')
	{
	   abrir_ventana2('../cxp/print_libro_cheque.jsp?fg=CONT&fechaini='+fechaIni+'&fechafin='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>&comprobante='+comprobante);
	}
    else if(accion=='CKREP_E')
	{
      comprobante = comprobante || 'ALL';  
      abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=cxp/print_libro_cheque.rptdesign&FG=CONT&fechaini='+fechaIni+'&fechafin='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>&comprobante='+comprobante+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(accion=='REPLIB')
	{
	abrir_ventana2('../facturacion/param_reportes_libro_ingreso.jsp?fg=CA&fechaini='+fechaIni+'&fechafin='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>');
	}
	/*else if(accion=='AL')
	{
	}*/
	//else if(accion=='REPLIBING1')abrir_ventana2('../facturacion/print_ingresos_x_centros.jsp?admType=&cds=&xDate='+fechaIni+'&tDate='+fechaFin+'&tipoFecha='+tipoFecha);
	//else if(accion=='REPLIBING2')abrir_ventana2('../facturacion/print_ingresos_x_centros.jsp?fp=DET&admType=&cds=&xDate='+fechaIni+'&tDate='+fechaFin+'&tipoFecha='+tipoFecha);
	else if(accion=='TRXLIB'){if(confirm('¿Desea exportar a Excel?'))abrir_ventana('../cellbyteWV/report_container.jsp?reportName=facturacion/ingresos_x_pacientes.rptdesign&cdsDet=<%=cdsDet%>&tipoFecha='+tipoFecha+'&fDate='+fechaIni+'&tDate='+fechaFin+'&pCtrlHeader='+pCtrlHeader);else abrir_ventana('../facturacion/print_ingresos_x_centros.jsp?fp=DET&xDate='+fechaIni+'&tDate='+fechaFin+'&tipoFecha='+tipoFecha);}
	else if(accion=='CDSLIB')abrir_ventana2('../facturacion/print_ingresos_x_centros.jsp?xDate='+fechaIni+'&tDate='+fechaFin+'&tipoFecha='+tipoFecha+'&admType=I');
	else if(accion=='CDSLIB2')abrir_ventana2('../facturacion/print_ingresos_x_centros.jsp?xDate='+fechaIni+'&tDate='+fechaFin+'&tipoFecha='+tipoFecha+'&admType=O');
	else if(accion=='REPLIBING1')abrir_ventana2('../facturacion/print_ingresos_x_centros.jsp?fg=POS&admType=&cds=&xDate='+fechaIni+'&tDate='+fechaFin+'&tipoFecha='+tipoFecha);
	else if(accion=='REPLIBING2')abrir_ventana2('../facturacion/print_ingresos_x_centros.jsp?fg=NF&&admType=&cds=&xDate='+fechaIni+'&tDate='+fechaFin+'&tipoFecha='+tipoFecha);
	else if(accion=='REPLIBING3')abrir_ventana('../facturacion/print_descuentos_x_cds.jsp?fg=CONTA&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&status=N&jubilado=N');
	else if(accion=='REPLIBING4')abrir_ventana('../facturacion/print_descuentos_x_cds.jsp?fg=CONTA&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&status=A&jubilado=N');
	else if(accion=='REPLIBING5')abrir_ventana('../facturacion/print_descuentos_x_cds.jsp?fg=CONTA&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&status=N&jubilado=S');
	else if(accion=='REPLIBING6')abrir_ventana('../facturacion/print_descuentos_x_cds.jsp?fg=CONTA&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&status=A&jubilado=S');
	else if(accion=='REPLIBING7')abrir_ventana('../facturacion/print_ingresos_facturas_otros.jsp?fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&status=N&rep_type=D');
	else if(accion=='REPLIBING8')abrir_ventana('../facturacion/print_ingresos_facturas_otros.jsp?fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&status=N&rep_type=R');
	else if(accion=='REPLIBING9')abrir_ventana('../facturacion/print_ingresos_facturas_otros.jsp?fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&status=A&rep_type=R');
	else if(accion=='REPLIBING10')abrir_ventana('../facturacion/print_ingresos_notas_ajustes.jsp?fp=T&fg=F&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&tipoFecha=A&libro=S');
	else if(accion=='REPLIBING11')abrir_ventana('../facturacion/print_descuentos_x_cds_ajuste.jsp?fp=T&fg=F&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&tipoFecha=A&libro=S');
	else if(accion=='REPLIBING12')abrir_ventana('../facturacion/print_ingresos_x_ajustes_cds.jsp?fg=F&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&tipoFecha=A');



	else if(accion=='CT')
	{
			if(fechaIni == '' || fechaFin == '') alert('Los parámetros no están completos...,VERIFIQUE!');
			else {
			if(accion=='CT'){
			 	if(confirm('Esta seguro que desea ejecutar el Libro de Cheque?')){showPopWin('../common/run_process.jsp?fp=COMP&actType=61&docType=GENCOMP&docId=GENCOMP&docNo=GENCOMP&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.50,null,null,'');
					}else alert('Proceso Cancelado');
		  }//fin CT
		}//fin else
	}
}
$(document).ready(function(){
 try{
   serveStaticTooltip({toolTipContainer:"#container",content:'"content-1":"Tipo de Servicio","content-2":"Cargo a Paciente"',track:true});
 }catch(e){}
});
function runProcessInt(baction){var x=0;var anio='';var fecha	= document.form1.fecha_desde.value;var v_tipo ='';var fecha_hasta	= document.form1.fecha_hasta.value;var accion='GENCOMP';var actType ='50';var msg =' generar comprobante';/*if(baction=='COMP'){if(fecha!=''){anio=fecha.substring(6);var cuentas=getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_plan_cuentas<%=cdo.getColValue("inclTax")%>','compania=<%=session.getAttribute("_companyId")%> and ano = ' + anio,'');if(parseInt(cuentas) ==0 )x++;}}*/

if(x==0){if(accion !=''){if(fecha == '' || fecha_hasta ==''  ) alert('Los parámetros no están completos...,VERIFIQUE!');else{if(confirm('¿Esta seguro de  '+msg+'?')){showPopWin('../process/gen_comprob_cafet.jsp?fp=COMP&actType='+actType+'&docType=GENCOMP&docId='+accion+'&docNo='+v_tipo+'&tipo='+v_tipo+'&fecha='+fecha+'&fechaFin='+fecha_hasta+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.50,null,null,'');}else alert('Proceso Cancelado');}}else alert('Seleccione Proceso a Ejecutar ');}else{alert('No puede generar Comprobante. El año debe estar activo Ó en Transicion.!!');}}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="Generar Comprobante"></jsp:param>
</jsp:include>
<table align="center" width="95%" cellpadding="0" cellspacing="0">
  <tr align="center">
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
              <tr>
                <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                    <%=fb.formStart(true)%>
						<%=fb.hidden("mode",mode)%>
						<%=fb.hidden("errCode","")%>
						<%=fb.hidden("errMsg","")%>
						<%=fb.hidden("baction","")%>
						<%=fb.hidden("banco","")%>
						<%=fb.hidden("fg",fg)%>
						<%=fb.hidden("fp",fp)%>
						<%=fb.hidden("clearHT","")%>
                    <tr class="TextRow02">
                      <td>

                      <table width="100%" cellpadding="1" cellspacing="1" align="center">
                        <%if(fp.trim().equals("INV")){%>

                         <tr class="TextHeader">
                            <td align="left">Fecha para el proceso</td>
                            <td colspan="2" align="left">
                            <jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />
                            <jsp:param name="nameOfTBox1" value="fecha_desde" />
                            <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                            <jsp:param name="nameOfTBox2" value="fecha_hasta" />
                            <jsp:param name="valueOfTBox2" value="<%=cDateTime%>" />
                            <jsp:param name="fieldClass" value="text10" />
                            <jsp:param name="buttonClass" value="text10" />
							<jsp:param name="clearOption" value="true" />
                            </jsp:include>
                            </td>
                          </tr>
						  <%if(!fg.trim().equals("INT")){%>
						  <tr class="TextFilter" align="left">
                            <td width="25%" rowspan="7">Parametros Para reportes</td>
                            <td width="15%"><!--Cuenta:&nbsp;--></td>
							<td width="60%" align="left">
							<%=fb.hidden("account1","")%><%=fb.hidden("account2","")%><%=fb.hidden("account3","")%><%=fb.hidden("account4","")%>
							<%=fb.hidden("account5","")%><%=fb.hidden("account6","")%>
							   <%//=fb.textBox("account1","",false,false,false,3,3,"Text10",null,null)%>
							   <%//=fb.textBox("account2","",false,false,false,3,2,"Text10",null,null)%>
							   <%//=fb.textBox("account3","",false,false,false,3,3,"Text10",null,null)%>
							   <%//=fb.textBox("account4","",false,false,false,3,3,"Text10",null,null)%>
							   <%//=fb.textBox("account5","",false,false,false,3,3,"Text10",null,null)%>
							   <%//=fb.textBox("account6","",false,false,false,3,3,"Text10",null,null)%></td>
                          </tr>
						  
						  <tr class="TextFilter" align="left">
                            <td width="15%">Tipo Fecha:</td>
							<td width="60%"><%=fb.select("tipoFecha","CC=CREACION,C=CARGO","CC",false,false,0,"Text10",null,null,null,"")%></td>
                          </tr>
						  <tr class="TextFilter" align="left">
                            <td width="15%">Comprobante:</td>
							<td width="60%"><%=fb.select("comprob","S=SI,N=NO","","T")%></td>
                          </tr>
						 
						  <tr class="TextFilter" align="left">
                            <td width="15%">Esconder Cabecera?</td>
							<td width="60%"><%=fb.checkbox("pCtrlHeader","false")%></td>
                          </tr>
						  <tr class="TextFilter" align="left">
                            <td width="15%">Estado</td>
							<td width="60%"><%=fb.select("status","R=ACTIVO(RECIBIDO),A=ANULADA","","T")%></td>
                          </tr>
						  <tr class="TextFilter" align="left">
                            <td width="15%">Afecta Contabilidad</td>
							<td width="60%"><%=fb.select("afectaConta","S=SI,N=NO","S","")%><font color="#FF0000"> **SOLO PARA INSUMOS/MATERIALES DE INVENTARIO</font></td>
                          </tr>
						  <tr class="TextFilter" align="left">
                            <td width="15%">Categoria Admisión</td>
							<td width="60%"><span title="" id="container-1">
							 <%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","categoria","","T")%>
							   </span></td>
                          </tr>
						  <%}%>
						   
  <tr class="TextHeader01">
    <td colspan="3">
        <table width="100%" cellpadding="1" cellspacing="1" align="center">
                           <%if(!fg.trim().equals("INT")){%>
						  <tr class="TextRow01"  align="left">
                               <td width="3%"><%=fb.radio("process","RM",false,false,false,null,null,"")%></td>
                               <td width="10%">(INVENTARIO)</td>
							   <td width="20%">* RECEPCIONES DE PROVEEDORES</td>
							   <td width="40%" align="right"><!--Tipo&nbsp;<%=fb.select("pType","ALL=Todo,RECEP=Recepciones Normales,RECEPFG=Recepciones a Consignación,DEV=Devoluciones Normales,DEVFG=Devoluciones a Consignación,AJ=Ajustes a nota de débito,AJS=Ajustes a saldo de Facturas","ALL",false,false,0,"Text10",null,null,"","")%>
							   <authtype type='51'><%=fb.button("view_reports","Reporte",false,false,"text10","","onClick=\"javascript:viewReports('RECEP');\"")%></authtype>-->
							    <%=fb.button("view_reportsDet","Recep. Detalladas",false,false,"text10","","onClick=\"javascript:viewReports('RECEP_ITEM');\"")%>
							   </td>
							    <td width="27%"><authtype type='51'><%=fb.button("view_reports2","Rep. Auxiliar",false,false,"text10","","onClick=\"javascript:viewReports('RECEP');\"")%></authtype>
								<authtype type='66'><%=fb.button("view_reports3","Rep. Auxiliar Res.",false,false,"text10","","onClick=\"javascript:viewReports('RECEP_RES');\"")%></authtype>
								</td>
                          </tr>

						  <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","TA",false,false,false,null,null,"")%></td>
                               <td>(GASTOS)</td>
							   <td>* TRANSFERENCIAS ENTRE ALMACENES</td>
							   <td><authtype type='52'>
							   
							   Consig.<%=fb.select("consignacionTranwh","S=SI,N=NO","N",false,false,0,"Text10",null,null,"","S")%>&nbsp;
							   <%=fb.select("tipoReporteTr","ALMENT = TRANSFERENCIAS (CTA ALMACEN ENTREGA),ALMREC = TRANSFERENCIAS (CTA ALMACEN RECIBE),ALMDEV = DEVOLUCION (CTA ALMACEN DEVUELVE),ALMRECDEV = DEVOLUCION (CTA ALMACEN RECIBE), ALMENT_ALMRECDEV=TRANSFERENCIAS / DEVOLUCION(ENTREGA;RECIBE),ALMREC_ALMDEV=TRANSFERENCIAS (RECIBE;DEVUELVE)","ENALM",false,false,0,"Text10",null,null,"","")%>
							   <%=fb.button("reporteEntUa","Reporte",false,false,"text10","","onClick=\"verTrx('TRF'); viewReports('TRANS')\"")%></authtype>
							   </td>
							    <td>
								<authtype type='52'><%=fb.button("reporteEntUaAuxiliar","Rep. Auxiliar",false,false,"text10","","onClick=\"viewReports('TRANS_UNI')\"")%></authtype>
								<authtype type='67'><%=fb.button("reporteEntUaAuxiliarRes","Rep. Auxiliar Res.",false,false,"text10","","onClick=\"viewReports('TRANS_UNI_RES')\"")%></authtype>
							   </td>
                          </tr>
						   <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","EU",false,false,false,null,null,"")%></td>
                               <td>(GASTOS)</td>
							   <td>* ENTREGAS A UNIDADES ADM.</td>
							   <td>
							   <%=fb.select("tipoReporte","ENUND = ENTREGAS (CTA UNIDAD),ENTINV = ENTREGAS (CTA INVENTARIO),DEVUND = DEVOLUCION (CTA UNIDAD),DUINV = DEVOLUCION (CTA INVENTARIO), ENUND_DEVUND=ENTREGAS/DEVOLUCION(UNIDAD),ENTINV_DUINV=ENTREGAS/DEVOLUCION(INVENTARIO)","ENUND",false,false,0,"Text10",null,null,"","")%>
							   <authtype type='50'><%=fb.button("reporteEntTr","Reporte",false,false,"text10","","onClick=\"javascript:viewReports('UND');\"")%></authtype></td>
							    <td>
								<authtype type='50'><%=fb.button("reporteEntTr2","Rep. Auxiliar",false,false,"text10","","onClick=\"javascript:viewReports('UND2');\"")%></authtype>
								<authtype type='68'><%=fb.button("reporteEntTr2Res","Rep. Auxiliar Res.",false,false,"text10","","onClick=\"javascript:viewReports('UND2_RES');\"")%></authtype>
							   </td>
						   </tr>
						   <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","GA",false,false,false,null,null,"")%></td>
                               <td>(GASTOS)</td>
							   <td>* GASTOS POR SERVICIOS ADMINISTRATIVOS</td>
							   <td><%//=fb.select("estado","R=RECIBIDO,A=ANULADO","R",false,false,0,"Text10",null,null,"","")%>
							   <authtype type='53'><%=fb.button("ver_gasto2","Reporte(Pdf)",false,false,"text10","","onClick=\"javascript:verTrx('GASER');\"")%></authtype>
							   <authtype type='54'><%=fb.button("ver_gasto_old","Reporte",false,false,"text10","","onClick=\"javascript:viewReports('SERV_OLD');\"")%></authtype>
							   </td>
							    <td>
							   <authtype type='53'><%=fb.button("ver_gasto","Rep. Auxiliar",false,false,"text10","","onClick=\"javascript:viewReports('SERV');\"")%></authtype>
							   <authtype type='69'><%=fb.button("ver_gastoRes","Rep. Auxiliar Res.",false,false,"text10","","onClick=\"javascript:viewReports('SERV_RES');\"")%></authtype>
							   </td>
                          </tr>  <!------>
						  <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","EP",false,false,false,null,null,"")%></td>
                               <td>(COSTOS)</td>
							   <td>* ENTREGAS DE MATERIALES A PACIENTES <br>* POS (OTROS CLIENTES)<!--<br>* ENTREGAS DE MATERIALES A SALAS--></td>
							   <td> Consig.<%=fb.select("consignacion","S=SI,N=NO","",false,false,0,"Text10",null,null,"","S")%>&nbsp;
							   <authtype type='55'>
							   <%//=fb.button("ver_entregas","Reporte",false,false,"text10","","onClick=\"javascript:verTrx('COPAC');\"")%>

							   <%//=fb.button("ver_entregas_bi","Reporte BI",false,false,"text10","","onClick=\"javascript:verTrx('COPACBI');\"")%>
							   <%//=fb.button("ver_entregas_bi","Reporte Resumido BI",false,false,"text10","","onClick=\"javascript:verTrx('COPACBI2');\"")%>
							    <span title="" id="container-2">
							   <%=fb.select("ver_entregas","COPAC=Reporte de Costo De pacientes - Solo Inventario,COPACBI=Reporte de Costo De pacientes (DETALLADO BI),COPACBI2=Reporte de Costo De pacientes Resumido BI,COPACBI3=Reporte de Costo De pacientes(DETALLADO ARTICULOS SIN COSTO),POS1=Costos de Otros Ingresos (Cuentas por Centro),POS2=Costos de Otros Ingresos (Cuentas de Inventario),POS3=Costos de Otros Ingresos (Cuentas de Inventario con Costo Cero)","N",false,false,0,"Text10",null,"onChange=\"javascript:verTrx(this.value);\"","","S")%>							   </span></authtype></td>
							    <td width="15%">
								<authtype type='55'><%=fb.button("reporteCosto","Rep. Auxiliar (CTA)",false,false,"text10","","onClick=\"javascript:verTrx('COPACBIC');\"")%>	</authtype><authtype type='55'><%=fb.button("reporteCosto","Rep. Auxiliar (CTA) det",false,false,"text10","","onClick=\"javascript:verTrx('COPACBIC2');\"")%>	</authtype>
								<authtype type='55'><%=fb.button("reporteCosto2","Rep. Auxiliar",false,false,"text10","","onClick=\"javascript:verTrx('COPACBI');\"")%>	</authtype>						   
								<authtype type='70'><%=fb.button("reporteCostoRes","Rep. Auxiliar Res.",false,false,"text10","","onClick=\"javascript:verTrx('COPACBI_RES');\"")%>	</authtype>						   
								</td>
                          </tr>
						  <%}%>
						   
                          <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","LI",false,false,false,null,null,"")%></td>
                               <td>(INGRESOS)</td>
							   <td>* LIBRO DE INGRESO(CXC)</td>
							   <td><authtype type='56'><%=fb.button("gen_libro","Generar Libro",false,false,"text10","","onClick=\"javascript:runProcess('GENLIB');\"")%></authtype>

							   <!--<authtype type='57'><%=fb.button("del_libro","Anular Libro",false,false,"text10","","onClick=\"javascript:runProcess('ANLIB');\"")%></authtype>-->
							   <authtype type='63'><%//=fb.button("reporte_lib","Reportes",false,false,"text10","","onClick=\"javascript:eject('REPLIB');\"")%></authtype>
							   <authtype type='58'><%=fb.button("ver_libro","Ver Libro",false,false,"text10","","onClick=\"javascript:verTrx('LIB');\"")%></authtype>
							   <authtype type='59'>
							   <%=fb.select("cargos_pac","TRXLIB=Ingresos Detallado (paciente,cargo,cuenta)|CDSLIB=Ingresos por Centros y Tipo de Servicios(IP)|CDSLIB2=Ingresos por Centros y Tipo de Servicios(OP)|REPLIBING1=Ingresos por Centros y Tipo de Servicios(POS)|REPLIBING2=Ingresos por Centros( Admisiones No Facturadas)|REPLIBING3=Descuentos A Facturas(por Centros)|REPLIBING4=Descuentos A Facturas(por Centros) (ANULADAS)|REPLIBING5=Descuentos A Facturas(por Centros) (JUBILADOS)|REPLIBING6=Descuentos A Facturas(por Centros) - JUBILADOS ANULADAS|REPLIBING7=Ingresos Por Factura y Descuentos(Otros) Detallado|REPLIBING8=Ingresos Por Factura y Descuentos(Otros) Resumido|REPLIBING10=Notas de Ajustes (DETALLADO AFECTAN LIB. INGRESOS(CARGOS Y DEVOLUCIONES,CHEQUES DEVUELTOS,INCOBRABLES))|REPLIBING11=Notas de Ajustes a Facturas (Descuentos x CdS)|REPLIBING12=Notas de Ajustes a Facturas (Centros y Tipos de Servicio) (RESUMIDO)","N",false,false,0,"Text10","width:105px","onChange=\"javascript:eject(this.value);\"","","S","","|","")%>
							   </authtype>
							  </td>
							    <td width="15%">
								 <authtype type='59'><%=fb.button("rpt_libro","Rep. Auxiliar",false,false,"Text10","","onClick=\"javascript:viewReports('LIB');\"")%></authtype>
								 <authtype type='65'><%=fb.button("rpt_libro2","Rep. Auxiliar x CDS",false,false,"Text10","","onClick=\"javascript:viewReports('LIB2');\"")%></authtype><!---->
								 <authtype type='65'><%=fb.button("rpt_libro3","Rep. Auxiliar Det",false,false,"Text10","","onClick=\"javascript:viewReports('LIB3');\"")%></authtype>
							   </td>
                          </tr>
						  <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","CL",false,false,false,null,null,"")%></td>
                               <td>(CXC)</td>
							   <td>* LIBRO DE CAJA</td>
							   <td><authtype type='61'><%=fb.button("libro","Generar Libro",false,false,"text10","","onClick=\"javascript:eject('CM');\"")%>
							  	<%=fb.button("corre","Ver Libro",false,false,"text10","","onClick=\"javascript:eject('CO');\"")%>
<!--,NBAN=Notas Bancarias Pendiente-->
							    <%=fb.select("rep_lib_ingreso","RE=Libro de Caja X Cta,REC=Recibos x Caja,PAGOS=Recibos x Cta,DEPOSITOS=Depositos x Caja","N",false,false,0,"Text10",null,"onChange=\"javascript:eject(this.value);\"","","S")%>
								<%=fb.select("tipoRepCja","R=RESUMIDO,D=DETALLADO","N",false,false,0,"Text10",null,"","","")%>
								
							<%//=fb.button("reporte2","Libro de Caja X Cta",false,false,"text10","","onClick=\"javascript:eject('RE');\"")%>
							<%//=fb.button("reporte3","Recibos x Caja",false,false,"text10","","onClick=\"javascript:eject('REC');\"")%>
							<%//=fb.button("reporte4","Recibos x Cta",false,false,"text10","","onClick=\"javascript:eject('PAGOS');\"")%>
							<%//=fb.button("reporte5","Depositos x Caja",false,false,"text10","","onClick=\"javascript:eject('DEPOSITOS');\"")%>
							</authtype></td>
							    <td width="15%"><authtype type='64'><%=fb.button("rep_caja","Rep. Auxiliar",false,false,"text10","","onClick=\"javascript:viewReports('REPCJA');\"")%>
								<%=fb.button("rep_caja_s","Auxiliar X Turnos",false,false,"text10","","onClick=\"javascript:viewReports('REPCJA_CTAS');\"")%>
								</authtype></td>
							
						 </tr>
						 <%if(!fg.trim().equals("INT")){%>
						 <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","CK",false,false,false,null,null,"")%></td>
                               <td>(CXP)</td>
							   <td>* LIBRO DE CHEQUE [ TRANSACCIONES DE BANCO ]</td>
							   <td><authtype type='62'><font class="redText"> <cellbytelabel>Primero se realiza la generaci&oacute;n del Libro de Cheque, revisar las transacciones
y luego generar el Comprobante</cellbytelabel></font></br>
					<%=fb.button("genLibro","Generar Libro",false,false,"text10","","onClick=\"javascript:eject('CT');\"")%>
					<%//=fb.select("rep_lib_ingreso","CK=Reporte de Cheque,CKREP=Libro de Cheque,DEPBANCO=Transacciones  de Banco","N",false,false,0,"Text10",null,"onChange=\"javascript:eject(this.value);\"","","S")%>

					
					<%=fb.button("rep_lib_ck","Libro de Cheque",false,false,"text10","","onClick=\"javascript:eject('CKREP');\"")%>
                    
                    <%=fb.button("rep_lib_ck_e","Excel",false,false,"text10","","onClick=\"javascript:eject('CKREP_E');\"")%>
                    
                    </authtype> </td>
							    <td width="15%"><authtype type='62'><%=fb.button("rep_cheque","Rep. Auxiliar",false,false,"text10","","onClick=\"javascript:eject('CK');\"")%>
                                <%=fb.button("rep_cheque_e","Excel",false,false,"text10","","onClick=\"javascript:eject('CK_E');\"")%>
                                </authtype></td>
						 </tr>
						 <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","AJS",false,false,false,null,null,"")%></td>
                               <td>(CXP)</td>
							   <td>* AJUSTES A CUENTAS POR PAGAR (HONORARIOS)</td>
							   <td><%=fb.select("pType2","AJS=Ajustes a saldo de Facturas","ALL",false,false,0,"Text10",null,null,"","")%></td>
							    <td width="15%">
							   <authtype type='63'><%=fb.button("view_reports21","Rep Auxiliar",false,false,"text10","","onClick=\"javascript:viewReports('AJS2');\"")%></authtype></td>
						 </tr>
						 <% if (usaPlanMedico.equalsIgnoreCase("S")) { %>
						 <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","PM",false,false,false,null,null,"")%></td>
                               <td>(INGRESOS)</td>
							   <td>* PLAN MEDICO</td>
							   <td>&nbsp;</td>
							    <td width="15%">
							   <authtype type='71'><%=fb.button("view_reports22","Rep Auxiliar",false,false,"text10","","onClick=\"javascript:viewReports('PM');\"")%>
							   <%=fb.button("view_reports23","Rep. Auxiliar Res.",false,false,"text10","","onClick=\"javascript:viewReports('PM_RES');\"")%>
							   </authtype></td>
						 </tr>
						 <%}%>
						 <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","COF",false,false,false,null,null,"")%></td>
                               <td>(VARIOS)</td>
							   <td>* COMPROBANTES FIJOS</td>
							   <td>&nbsp;</td>
							    <td width="15%">
							   <authtype type='71'><%=fb.button("view_reports24","Rep. Auxiliar Res.",false,false,"text10","","onClick=\"javascript:viewReports('COF_RES');\"")%>
							   <%=fb.button("view_reports25","Rep. Auxiliar Excel.",false,false,"text10","","onClick=\"javascript:viewReports('COF_RES2');\"")%>
							   </authtype></td>
						 </tr><!---->
                         <tr class="TextRow01" align="left">
                               <td><%=fb.radio("process","GANPER",false,false,false,null,null,"")%></td>
                               <td>(INGRESOS)</td>
							   <td>* COMPROBANTES DE PAQUETES(GANANCIAS O PERDIDAS)</td>
							   <td>&nbsp;</td>
							    <td width="15%">
							   <authtype type='73'><%=fb.button("view_reports25","Rep. Auxiliar Cds",false,false,"text10","","onClick=\"javascript:viewReports('GANPER');\"")%>
							   <%//=fb.button("view_reports25","Rep. Auxiliar Excel.",false,false,"text10","","onClick=\"javascript:viewReports('COF_RES2');\"")%>
							   </authtype></td>
						 </tr>
						 <tr class="textRow01" align="left">
                            <td colspan="5" align="center"><%//=fb.button("cargar3","Cargar Datos",false,false,"text10","","onClick=\"javascript:eject('EA');\"")%>
                            <authtype type='60'><%=fb.button("comp_mayor3","Generar Comprobante",false,false,"text10","","onClick=\"javascript:runProcess('COMP');\"")%></authtype></td>
                          </tr>
						  <%}%>
						  <%if(fg.trim().equals("INT")){%>
						   <tr class="textRow01" align="left">
                            <td colspan="5" align="center">
                            <authtype type='72'><%=fb.button("comp_mayor3","Generar Comprobante",false,false,"text10","","onClick=\"javascript:runProcessInt('COMP');\"")%></authtype></td>
                          </tr>
						  <%}%>
						

  		</table>
  	</td>
  </tr>
                          <%}%>

                        </table>
                        </td>
                    </tr>
                    <%=fb.formEnd(true)%>
                    <!-- ================================   F O R M   E N D   H E R E   ================================ -->
                  </table></td>
              </tr>
            </table></td>
        </tr>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
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
%>
