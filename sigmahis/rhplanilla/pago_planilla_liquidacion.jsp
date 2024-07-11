<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>

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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alExtra = new ArrayList();
ArrayList alDesc = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String empId = request.getParameter("empId");
String anio = request.getParameter("anio");
String num = request.getParameter("num");
String id = request.getParameter("id"); 


if (empId == null || anio == null || num == null) throw new Exception("El empleado no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{

sql = "SELECT a.emp_id, a.provincia,a.sigla, a.tomo,a.asiento, TO_CHAR(a.fecha_egreso,'dd/mm/yyyy') egreso, TO_CHAR(a.fecha_docto,'dd/mm/yyyy') fecha, a.motivo, c.descripcion AS motivoDesc, a.periodo_pago, a.anio_pago, a.ts_anios, a.ts_meses, a.ts_dias, TO_CHAR (a.dl_desde,'dd/mm/yyyy') desdeTrx , tO_CHAR(a.dl_hasta,'dd/mm/yyyy') hastaTrx, a.dl_dias_laborados, a.dl_thoras_regulares, a.vac_venc_dias, nvl(a.vac_venc_salario,0) vac_venc_salario,round((nvl(a.vac_venc_salario,0) * p.seg_soc_emp) / 100,2) as ssocial_vac_venc, round((nvl(a.vac_venc_salario,0) * p.seg_edu_emp) / 100,2) as seduc_vac_venc,round((nvl(a.vac_venc_gasto,0) * p.seg_soc_emp) / 100,2) as ssocial_vacVencGr, round((nvl(a.vac_venc_gasto,0) * p.seg_edu_emp) / 100,2) as seduc_vacVencGr,nvl(a.vac_venc_gasto,0) vac_venc_gasto, a.vac_prop_periodos, nvl(a.vac_prop_salario,0) vac_prop_salario,  round((nvl(a.vac_venc_salario,0) * p.seg_soc_emp) / 100+(nvl(a.vac_prop_salario,0) * p.seg_soc_emp) / 100,2) as ssocial_vacprop, round((nvl(a.vac_venc_salario,0) * p.seg_edu_emp) / 100+(nvl(a.vac_prop_salario,0) * p.seg_edu_emp) / 100,2) as seduc_vacprop, nvl(a.vac_prop_gasto,0)  vac_prop_gasto, round((nvl(a.vac_prop_gasto,0) * p.seg_soc_emp) / 100,2) as ssocial_vacpropGr, round((nvl(a.vac_prop_gasto,0) * p.seg_edu_emp) / 100,2) as seduc_vacpropGr, nvl(a.xiii_prop_salario,0) xiii_prop_salario, nvl(a.xiii_prop_gasto,0) xiii_prop_gasto, (nvl(a.xiii_prop_gasto,0) * p.ssoc_xiiim_gasto_emp) / 100 as ssocial_xiii_prop_gasto, round((nvl(a.xiii_prop_salario,0) * p.ssoc_xiiim_emp) / 100,2) as ssoc_xiii_prop_salario, a.prm_acumulado, a.prm_promedio_sem, a.prm_anios, nvl(a.prm_anios_valor,0) prm_anios_valor, nvl(a.prm_meses,0) prm_meses, nvl(a.prm_meses_valor,0) prm_meses_valor, a.prm_dias, nvl(a.prm_dias_valor,0) prm_dias_valor, nvl(a.prm_anios_valor,0) + nvl(a.prm_meses_valor,0) + nvl(a.prm_dias_valor,0) as prima_antiguedad, nvl(a.ind_salario_ult6m,0) ind_salario_ult6m, nvl(a.ind_salario_ultmes,0) ind_salario_ultmes, a.ind_promedio_sem, a.ind_promedio_mes, nvl(a.ind_valor,0) ind_valor, a.recibe_preaviso, nvl(a.preaviso_valor,0) preaviso_valor, nvl(a.ot_beneficios_valor,0) ot_beneficios_valor, nvl(a.imp_ssocial,0) imp_ssocial, nvl(a.imp_seducat,0) imp_seducat, nvl(a.imp_renta_sv,0) imp_renta_sv, nvl(a.imp_renta_ip,0) imp_renta_ip, a.cxc_empleado, a.imp_periodos, a.prm_semanas, a.desc_preaviso, nvl(a.desc_preaviso_valor,0) desc_preaviso_valor, nvl(a.cxc_clinica,0) cxc_clinica, a.estado, a.dl_thoras_regulares, (nvl(a.dl_thoras_regulares,0) * nvl(a.rata_hora,0)) as ingresoTrx, round((nvl(a.dl_thoras_regulares,0) * nvl(a.rata_hora,0) * p.seg_soc_emp) / 100,2) as ssocial_trx, round((nvl(a.dl_thoras_regulares,0) * nvl(a.rata_hora,0) * p.seg_edu_emp) / 100,2) as seduc_trx, a.forma_pago, a.num_cheque, TO_CHAR(a.fecha_cheque,'dd/mm/yyyy') fechaCk, TO_CHAR(a.fecha_ingreso,'dd/mm/yyyy') fechaIngreso, nvl(a.xiii_acum_salario,0) xiii_acum_salario, nvl(a.xiii_acum_grep,0) xiii_acum_grep, a.observacion, a.ajuste_creado, nvl(a.salario_base,0) AS salarioMensual, nvl(b.GASTO_REP,0) AS gastoRep, nvl(a.rata_hora,0) AS rataHora, nvl(a.RATA_X_HORAGR,0) AS rataHoraGr, nvl(a.desc_preaviso_valor,0) desc_preaviso_valor, decode(desc_preaviso,'N','N','S') pagar_preaviso, c.PAGAR_INDEMN, c.PAGAR_PANTIG, c.PAGAR_VACACION, c.PAGAR_XIII_MES, c.pagar_recargo25, c.pagar_recargo50, 'Periodo  Quincenal del '||TO_CHAR(a.fecha_ingreso,'dd/mm/yyyy')||' al '||TO_CHAR(a.fecha_egreso,'dd-mm-yyyy') AS periodoTrab, a.unidad_organi, e.descripcion AS unidadDesc, f.denominacion AS cargoDesc, NVL(a.ts_anios,0)||'a '||NVL(a.ts_meses,0)||'m '||NVL(a.ts_dias,0)||'d' AS antiguedad, b.cedula1 cedula, b.num_ssocial, b.nombre_empleado nomEmpleado, b.num_empleado numEmpleado, nvl(a.ind_recargo25,0) ind_recargo25, p.seg_soc_emp, p.seg_edu_emp, DECODE(c.pagar_recargo50,'S',NVL(a.ind_valor,0)*50/100,'0.00') ind_recargo50, to_char(dl_desde,'') FROM TBL_PLA_LI_LIQUIDACION a, vw_pla_empleado b, TBL_PLA_LI_MOTIVO c, TBL_SEC_UNIDAD_EJEC e, TBL_PLA_CARGO f, tbl_pla_parametros p WHERE a.emp_id = b.emp_id AND a.compania = b.compania AND a.motivo = c.CODIGO AND a.compania = c.compania AND b.UBIC_SECCION = e.CODIGO AND b.compania = e.COMPANIA AND b.CARGO = f.CODIGO AND b.compania = f.COMPANIA and e.compania = p.cod_compania AND a.emp_id="+empId+" AND a.anio_pago = "+anio+" and a.periodo_pago = "+num+" AND a.compania="+(String) session.getAttribute("_companyId");
	al = SQLMgr.getDataList(sql);

	sql = "select decode(accion,'DS',sum(monto),'DV',sum(monto*-1)) montoDesc from tbl_pla_aus_y_tard where emp_id = "+empId+" and anio_des = "+anio+" and quincena_des = "+num+" and estado_des = 'PE' and cod_planilla_des = 8 and accion <> 'ND' and compania="+(String) session.getAttribute("_companyId")+" group by accion";
	alDesc = SQLMgr.getDataList(sql);
	


	sql= "select nvl(sum(a.monto),0) montoExtra,  nvl(c.bonificacion,0) bonificacion, nvl(d.montoTrx,0) montoTrx from TBL_PLA_T_EXTRAORDINARIO a,  (SELECT SUM(NVL(monto,0)) bonificacion FROM TBL_PLA_T_EXTRAORDINARIO WHERE estado_pag = 'PE' AND cod_planilla_pag = 8 and quincena_pag = "+num+" and anio_pag = "+anio+" AND compania = "+(String) session.getAttribute("_companyId")+" AND emp_id = "+empId+" AND the_codigo = 30 ) c , (SELECT SUM(NVL(monto,0)) montoTrx FROM TBL_PLA_TRANSAC_EMP WHERE estado_pago = 'PE' AND cod_planilla_pago = 8 AND compania = "+(String) session.getAttribute("_companyId")+" AND emp_id = "+empId+" and quincena_pago = "+num+" and anio_pago = "+anio+" ) d WHERE a.emp_id = "+empId+" AND a.anio_pag = "+anio+" and a.quincena_pag = "+num+" AND a.estado_pag = 'PE' AND a.cod_planilla_pag = 8 AND a.compania= "+(String) session.getAttribute("_companyId")+" group by c.bonificacion, d.montoTrx";

	alExtra = SQLMgr.getDataList(sql);


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Pago a liquidación - '+document.title;
function printList(empId,anio,num){
	abrir_ventana('../rhplanilla/print_list_comprobante_liq.jsp?empId='+empId+'&anio='+anio+'&num='+num);
}
function printDet(empId,anio,num){
    var empName = $("#nomEmpleado").val(); 
    var empPID = $("#cedula").val(); 
    var empNo = $("#empNo").val(); 
    var empMsalary = $("#salarioMensual").val(); 
    var egreso = $("#egreso").val(); 
    var fechaIngreso = $("#fechaIngreso").val(); 
    var antiguedad = $("#antiguedad").val(); 
    var rataHora = $("#rataHora").val();
    var rataHoraGr = $("#rataHoraGr").val();
    var anioPago = $("#anioPago").val(); 
    var periodoPago = $("#periodoPago").val(); 
    var vacVencSalario = $("#vac_venc_salario").val() || 0.00; 
    var diasLaborados = $("#diasLaborados").val() || 0; 
    var gastoRep = $("#gastoRep").val() || 0; 
    var tsAnios = $("#tsAnios").val(); 
    var tsMeses = $("#tsMeses").val(); 
    var tsDias = $("#tsDias").val(); 
    var pVac = $("#pVac").val(); 
    var pXiii = $("#pXiii").val(); 
    var pPreaviso = $("#pPreaviso").val(); 
    var pPrima = $("#pPrima").val(); 
    var pIndemn = $("#pIndemn").val(); 
    var pRec25 = $("#pRec25").val(); 
    var pRec50 = $("#pRec50").val(); 
    var provincia = $("#provincia").val();
    var tomo = $("#tomo").val();
    var asiento = $("#asiento").val();
    var sigla = $("#sigla").val();
    var motivoDesc = $("#motivoDesc").val();
    var vacSalario = $("#vacSalario").val() || 0;
    var vacPropSalario = $("#vacPropSalario").val() || 0;
    var vacGasto = $("#vacGasto").val() || 0;
    var vacPropGasto = $("#vacPropGasto").val() || 0;
    var desdeTrx = $("#desdeTrx").val();
    var hastaTrx = $("#hastaTrx").val();
    var xiiiAcumSalario = $("#xiii_acum_salario").val() || 0;
    var xiiiAcumGrep = $("#xiii_acum_grep").val() || 0;
    var otBeneficiosValor = $("#ot_beneficios_valor").val() || 0;
	
	var data = splitCols(getDBData('<%=request.getContextPath()%>', "decode(count(*),0,'N','Y'), getPlaLiqDLTotales(<%=(String) session.getAttribute("_companyId")%>, "+empId+", "+anioPago+", "+periodoPago+") pla_liq_dl_totales",'tbl_pla_planilla_encabezado'," to_date('"+egreso+"','dd/mm/yyyy') between fecha_inicial and fecha_final",''));
	var hayPlanilla = data[0];
	var trPaSt = data[4];
	var salAPagar = data[10];
	var salAdescontar = data[11];
	var trPaTrxBon = data[2];
	var msg = "";
	
	if (pIndemn=="S"){
		executeDB('<%=request.getContextPath()%>','call sp_pla_liq_indemnizacion(<%=(String) session.getAttribute("_companyId")%>, ' + empId + ', ' + provincia + ', \'' + sigla + '\', ' + tomo + ', ' + asiento + ', \'' + fechaIngreso + '\', \'' + egreso + '\', ' + empMsalary + ')');
		msg = splitCols(getMsg('<%=request.getContextPath()%>', '<%=ConMgr.getClientIdentifier()%>'));
	}
	
	if (desdeTrx && hastaTrx){
	   var x = splitCols(getDBData('<%=request.getContextPath()%>', 'getDiasLaborados(<%=(String) session.getAttribute("_companyId")%>, '+empId+', \''+desdeTrx+'\', \''+hastaTrx+'\')','dual','',''));
	   diasLaborados = x[0];
	}

	abrir_ventana('../rhplanilla/print_detalle_liq.jsp?empId='+empId+'&anio='+anio+'&num='+num+'&empName='+empName+'&empPID='+empPID+'&empMsalary='+empMsalary+'&fechaIngreso='+fechaIngreso+'&egreso='+egreso+'&antiguedad='+antiguedad+'&rataHora='+rataHora+'&vacVencSalario='+vacVencSalario+'&hayPlanilla='+hayPlanilla+'&anioPago='+anioPago+'&periodoPago='+periodoPago+'&salAPagar='+salAPagar+'&salAdescontar='+salAdescontar+'&diasLaborados='+diasLaborados+'&pVac='+pVac+'&pXiii='+pXiii+'&pPreaviso='+pPreaviso+'&pPrima='+pPrima+'&pIndemn='+pIndemn+'&pRec25='+pRec25+'&pRec50='+pRec50+'&empNo='+empNo+'&empNo='+empNo+'&tsAnios='+tsAnios+'&tsMeses='+tsMeses+'&tsDias='+tsDias+'&gastoRep='+gastoRep+'&idenmData='+(msg||'')+'&motivoDesc='+motivoDesc+'&rataHoraGr='+rataHoraGr+'&trPaSt='+trPaSt+'&vacSalario='+vacSalario+'&vacPropSalario='+vacPropSalario+'&vacGasto='+vacGasto+'&vacPropGasto='+vacPropGasto+'&xiiiAcumSalario='+xiiiAcumSalario+'&trPaTrxBon='+trPaTrxBon+'&otBeneficiosValor='+otBeneficiosValor);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="PLANILLA DE LIQUIDACIÓN"></jsp:param>
  <jsp:param name="displayCompany" value="y"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode","")%>
<%=fb.hidden("seccion","")%>
<%=fb.hidden("size","")%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("anio",anio)%>

<table width="100%" cellpadding="1" cellspacing="1">
 
  <tr>
    <td align="right" colspan="7">&nbsp;<a href="javascript:printList('<%=empId%>','<%=anio%>','<%=num%>')" class="Link00">[ Imprimir Liquidación ]</a>&nbsp;<a href="javascript:printDet('<%=empId%>','<%=anio%>','<%=num%>')" class="Link00">[ Imprimir Detellado ]</a></td>
  </tr>
  <%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";	
	
	double 	totTrExtra = 0.00;
	double  seg_soc = 0.00, seg_edu = 0.00;
	int 	contExtra = 0;
	int 	contDesc = 0;
	double 	totNeto = 0.00, totNetoTrx = 0.00;	
	double 	totNetoTrxGr = 0.00, totNetoVac = 0.00;	
	double 	totNetoVacGr = 0.00, totNetoXm = 0.00;
	double 	totNetoPr = 0.00, totNetoXmGr = 0.00;
	double 	totNetoPrGr = 0.00, totNetoPant = 0.00;
	double 	totNetoInd = 0.00, totNetoInd25 = 0.00;
	double 	totNetoPra = 0.00, totNetoIsrEsp = 0.00;
	
	double 	totNetoIng = 0.00, totNetoSsocial = 0.00;
	double 	totNetoSeduc = 0.00, totNetoIsr = 0.00;
	double  totNetoPagar = 0.00;
	double totDesc = 0.00, totPreDesc = 0.00;
	double totExtra = 0.00, totBoni = 0.00,totNetoVacGrVenc=0.00;
	
for (int j=0; j<alDesc.size(); j++)
		{
		
		CommonDataObject cdo1 = (CommonDataObject) alDesc.get(j);
		totDesc = Double.parseDouble(cdo1.getColValue("montoDesc").replace(",",""));
		}
	
	
	for (int j=0; j<alExtra.size(); j++)
	{
	
	CommonDataObject cdo2 = (CommonDataObject) alExtra.get(j);
	totExtra = Double.parseDouble(cdo2.getColValue("montoExtra").replace(",","")) + Double.parseDouble(cdo2.getColValue("montoTrx").replace(",",""));
	totBoni = Double.parseDouble(cdo2.getColValue("bonificacion").replace(",",""));
	} 
%>
<%=fb.hidden("nomEmpleado",cdo.getColValue("nomEmpleado"))%>
<%=fb.hidden("cedula",cdo.getColValue("cedula"))%>
<%=fb.hidden("empNo",cdo.getColValue("numEmpleado"))%>
<%=fb.hidden("salarioMensual",cdo.getColValue("salarioMensual"))%>
<%=fb.hidden("fechaIngreso",cdo.getColValue("fechaIngreso"))%>
<%=fb.hidden("egreso",cdo.getColValue("egreso"))%>
<%=fb.hidden("antiguedad",cdo.getColValue("antiguedad"))%>
<%=fb.hidden("rataHora",cdo.getColValue("rataHora"))%>
<%=fb.hidden("rataHoraGr",cdo.getColValue("rataHoraGr"))%>
<%=fb.hidden("vac_venc_salario",CmnMgr.getFormattedDecimal(cdo.getColValue("vac_venc_salario")))%>
<%=fb.hidden("anioPago",cdo.getColValue("anio_pago"))%>
<%=fb.hidden("periodoPago",cdo.getColValue("periodo_pago"))%>
<%=fb.hidden("diasLaborados",cdo.getColValue("dl_dias_laborados"))%>
<%=fb.hidden("motivoDesc",cdo.getColValue("motivoDesc"))%>
<%=fb.hidden("pVac",cdo.getColValue("PAGAR_VACACION"))%>
<%=fb.hidden("pXiii",cdo.getColValue("PAGAR_XIII_MES"))%>
<%=fb.hidden("pPreaviso",cdo.getColValue("pagar_preaviso"))%>
<%=fb.hidden("pPrima",cdo.getColValue("PAGAR_PANTIG"))%>
<%=fb.hidden("pIndemn",cdo.getColValue("PAGAR_INDEMN"))%>
<%=fb.hidden("pRec25",cdo.getColValue("pagar_recargo25"))%>
<%=fb.hidden("pRec50",cdo.getColValue("pagar_recargo50"))%>
<%=fb.hidden("tsAnios",cdo.getColValue("ts_anios"))%>
<%=fb.hidden("tsMeses",cdo.getColValue("ts_meses"))%>
<%=fb.hidden("tsDias",cdo.getColValue("ts_dias"))%>
<%=fb.hidden("gastoRep",cdo.getColValue("gastoRep"))%>
<%=fb.hidden("provincia",cdo.getColValue("provincia"))%>
<%=fb.hidden("tomo",cdo.getColValue("tomo"))%>
<%=fb.hidden("sigla",cdo.getColValue("sigla"))%>
<%=fb.hidden("asiento",cdo.getColValue("asiento"))%>
<%=fb.hidden("vacSalario",cdo.getColValue("vac_venc_salario"))%>
<%=fb.hidden("vacPropSalario",cdo.getColValue("vac_prop_salario"))%>
<%=fb.hidden("vacGasto",cdo.getColValue("vac_venc_gasto"))%>
<%=fb.hidden("vacPropGasto",cdo.getColValue("vac_prop_gasto"))%>
<%=fb.hidden("desdeTrx",cdo.getColValue("desdeTrx"))%>
<%=fb.hidden("hastaTrx",cdo.getColValue("hastaTrx"))%>
<%=fb.hidden("xiii_acum_salario",cdo.getColValue("xiii_acum_salario"))%>
<%=fb.hidden("xiii_acum_grep",cdo.getColValue("xiii_acum_grep"))%>
<%=fb.hidden("ot_beneficios_valor",cdo.getColValue("ot_beneficios_valor"))%>

<tr align="center" class="TextHeader">
    <td width="28%">&nbsp;</td>
    <td colspan="4" align="center"><%=cdo.getColValue("periodoTrab")%></td>
    <td colspan="2">&nbsp;</td>
  </tr>

<tr align="center" class="TextRow01">
    <td width="28%"><p># Empleado &nbsp; <%=cdo.getColValue("numEmpleado")%> </p>
      <p>&nbsp;&nbsp; Fecha de Entrada &nbsp;&nbsp;<%=cdo.getColValue("fechaIngreso")%> </p></td>
    <td colspan="4" align="center"><%=cdo.getColValue("nomEmpleado")%> 
		 <p>&nbsp; <%=cdo.getColValue("cargoDesc")%> </p></td>
    <td colspan="2"><p># Cédula &nbsp;<%=cdo.getColValue("cedula")%> </p>
      <p>Sueldo Mensual &nbsp;<%=cdo.getColValue("salarioMensual")%></p></td>
  </tr>

  <tr align="left" class="TextRow02">
    <td width="28%"> Terminación - Egreso &nbsp;<%=cdo.getColValue("egreso")%></td>
    <td colspan="4">&nbsp;</td>
    <td colspan="2"> Gasto Rep.&nbsp;<%=cdo.getColValue("gastoRep")%></td>
  </tr>
  
  <tr align="left" class="TextRow01">
    <td width="28%"> Antiguedad &nbsp;<%=cdo.getColValue("antiguedad")%></td>
    <td colspan="4">&nbsp;</td>
    <td colspan="2"> Ingreso Base &nbsp;<%=cdo.getColValue("salarioMensual")%></td>
  </tr>
  
<tr align="left" class="TextRow02">
    <td width="28%">&nbsp;  </td>
    <td colspan="4">&nbsp;</td>
    <td colspan="2"> Tarifa x Hora &nbsp;<%=cdo.getColValue("rataHora")%></td>
  </tr>

  <tr align="left" class="TextHeader">
    <td colspan="4">* *   CAUSAL * * </td>
    <td colspan="3">* LIQUIDAR *</td>
  </tr>
  

  <tr align="left" class="TextRow01">
    <td colspan="4">&nbsp;<%=cdo.getColValue("motivoDesc")%> </td>
    <td colspan="3">&nbsp;<%=cdo.getColValue("PAGAR_VACACION")%> &nbsp Vacaciones</td>
  </tr>

<tr align="left" class="TextRow02">
    <td colspan="4">&nbsp; </td>
    <td colspan="3">&nbsp;<%=cdo.getColValue("PAGAR_XIII_MES")%> &nbsp XIII Mes</td>
  </tr>

<tr align="left" class="TextRow01">
    <td colspan="4">&nbsp; </td>
    <td colspan="3">&nbsp;<%=cdo.getColValue("pagar_preaviso")%> &nbsp Preaviso</td>
  </tr>

<tr align="left" class="TextRow02">
    <td colspan="4">&nbsp; </td>
    <td colspan="3">&nbsp;<%=cdo.getColValue("PAGAR_PANTIG")%> &nbsp Prima de Antiguedad</td>
  </tr>

<tr align="left" class="TextRow02">
    <td colspan="4">&nbsp; </td>
    <td colspan="3">&nbsp;<%=cdo.getColValue("PAGAR_INDEMN")%> &nbsp Indemnización</td>
  </tr>

<tr align="left" class="TextRow01">
    <td colspan="4">&nbsp; </td>
    <td colspan="3">&nbsp;<%=cdo.getColValue("pagar_recargo25")%> &nbsp Recargo 25% sobre Indemn.</td>
  </tr>

<tr align="left" class="TextRow02">
    <td colspan="4">&nbsp; </td>
    <td colspan="3">&nbsp;<%=cdo.getColValue("pagar_recargo50")%> &nbsp Recargo 50% sobre Indemn.</td>
  </tr>

  


<tr align="center" class="TextHeader">
    <td colspan="7" align="center">&nbsp; RESUMEN </td>
 </tr>

  <tr align="left" class="TextRow01">
    <td width="28%">Detalle</td>
    <td align="center" width="21%">Ingresos</td>
    <td width="3%">&nbsp;</td>
    <td width="12%">Impuesto S/Renta</td>
    <td width="12">Seguro Social</td>
    <td width="12%">Seguro Educativo</td>
    <td width="12%">Neto a Pagar</td>
  </tr>

<%

totTrExtra = Double.parseDouble(cdo.getColValue("ingresoTrx").replace(",","")) + totExtra - totDesc;

seg_soc = (totTrExtra * Double.parseDouble(cdo.getColValue("seg_soc_emp").replace(",","")))/ 100;
seg_edu = ((totTrExtra - totBoni) * Double.parseDouble(cdo.getColValue("seg_edu_emp").replace(",",""))) / 100;
totNeto = Double.parseDouble(cdo.getColValue("ingresoTrx").replace(",","")) + totExtra - totDesc - seg_soc - seg_edu;

%>

	<tr align="left" class="TextRow02">
    <td>Ingreso Pendiente</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(totTrExtra)%></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>

    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(seg_soc)%></td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(seg_edu)%></td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totNeto)%></td>
	</tr>

	<tr align="left" class="TextRow02">
    <td>Ingreso Pendiente x Gtos. Rep.</td>
    <td align="right"></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
	</tr>


<%
totNetoVac = Double.parseDouble(cdo.getColValue("vac_prop_salario").replace(",",""))+Double.parseDouble(cdo.getColValue("vac_venc_salario").replace(",","")) -
Double.parseDouble(cdo.getColValue("imp_renta_sv").replace(",","")) - 	
Double.parseDouble(cdo.getColValue("ssocial_vacprop").replace(",","")) - Double.parseDouble(cdo.getColValue("seduc_vacprop").replace(",",""));
%>

	<tr align="left" class="TextRow02">
    <td>Vacaciones</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("vac_prop_salario"))%></td>
	<td>&nbsp;</td>
	<td align="right" rowspan="4">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("imp_renta_sv"))%></td>
    <td align="right" rowspan="2">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ssocial_vacprop"))%></td>
    <td align="right" rowspan="2">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("seduc_vacprop"))%></td>
    <td align="right" rowspan="2">&nbsp;<%=CmnMgr.getFormattedDecimal(totNetoVac)%></td>
	</tr>
	<tr align="left" class="TextRow02">
    <td>Vacaciones Vencidas</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("vac_venc_salario"))%></td>
	<td>&nbsp;</td>
	</tr>
	

<%
totNetoVacGrVenc = Double.parseDouble(cdo.getColValue("vac_venc_gasto").replace(",","")) - Double.parseDouble(cdo.getColValue("ssocial_vacVencGr").replace(",","")) - Double.parseDouble(cdo.getColValue("seduc_vacVencGr").replace(",",""));
%>

	<tr align="left" class="TextRow02">
    <td>Vacaciones Venc. x Gastos Rep.</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("vac_venc_gasto"))%></td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ssocial_vacVencGr"))%></td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("seduc_vacVencGr"))%></td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totNetoVacGrVenc)%></td>
	</tr>
	
<%
totNetoVacGr = Double.parseDouble(cdo.getColValue("vac_prop_gasto").replace(",","")) - Double.parseDouble(cdo.getColValue("ssocial_vacpropGr").replace(",","")) - Double.parseDouble(cdo.getColValue("seduc_vacpropGr").replace(",",""));
%>

	<tr align="left" class="TextRow02">
    <td>Vacaciones x Gastos Rep.</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("vac_prop_gasto"))%></td>
	
	<td>&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ssocial_vacpropGr"))%></td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("seduc_vacpropGr"))%></td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totNetoVacGr)%></td>
	</tr>
	
	


<%
totNetoXm = Double.parseDouble(cdo.getColValue("xiii_prop_salario").replace(",","")) - Double.parseDouble(cdo.getColValue("ssoc_xiii_prop_salario").replace(",","")) ;
%>

<tr align="left" class="TextRow02">
    <td>Décimo Tercer Mes</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("xiii_prop_salario"))%></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ssoc_xiii_prop_salario"))%></td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totNetoXm)%></td>
	</tr>

<%
totNetoXmGr = Double.parseDouble(cdo.getColValue("xiii_prop_gasto").replace(",","")) - Double.parseDouble(cdo.getColValue("ssocial_xiii_prop_gasto").replace(",","")) ;
%>


	<tr align="left" class="TextRow02">
    <td>Décimo Tercer Mes x Gtos. Rep.</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("xiii_prop_gasto"))%></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ssocial_xiii_prop_gasto"))%></td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totNetoXmGr)%></td>
	</tr>
	
	<tr align="left" class="TextRow02">
    <td>*Preaviso</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("preaviso_valor"))%></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("preaviso_valor"))%></td>
	</tr>
  	
	<tr align="left" class="TextRow02">
    <td>Preaviso x Gasto Rep.</td>
    <td align="right"></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
	</tr>
	
	<tr align="left" class="TextRow02">
    <td>*Prima de Antiguedad</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("prima_antiguedad"))%></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("prima_antiguedad"))%></td>
	</tr>
	
	<tr align="left" class="TextRow02">
    <td>*Indemnización</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ind_valor"))%></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ind_valor"))%></td>
	</tr>
	
	<tr align="left" class="TextRow02">
    <td>*Indemnización (Recargo 25%)</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ind_recargo25"))%></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ind_recargo25"))%></td>
	</tr>
	
	<tr align="left" class="TextRow02">
    <td>*Indemnización (Recargo 50%)</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ind_recargo50"))%></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ind_recargo50"))%></td>
	</tr>
	
<%
	
if(!cdo.getColValue("desc_preaviso_valor").equals("0"))
	totPreDesc = Double.parseDouble(cdo.getColValue("desc_preaviso_valor").replace(",","")) * -1 ;
	 else totPreDesc = Double.parseDouble(cdo.getColValue("desc_preaviso_valor").replace(",",""));
%>


	<tr align="left" class="TextRow02">
    <td>*Preaviso(Desc.)</td>
    <td align="right"><%=CmnMgr.getFormattedDecimal(totPreDesc)%></td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totPreDesc)%></td>
	</tr>


	<tr align="right" class="TextRow02">
    <td colspan="7"></td>
	</tr>


<%
totNetoIng = totTrExtra + Double.parseDouble(cdo.getColValue("vac_prop_salario").replace(",","")) +
	Double.parseDouble(cdo.getColValue("vac_prop_gasto").replace(",","")) +
	Double.parseDouble(cdo.getColValue("xiii_prop_salario").replace(",","")) +
	Double.parseDouble(cdo.getColValue("xiii_prop_gasto").replace(",","")) +
	Double.parseDouble(cdo.getColValue("preaviso_valor").replace(",","")) +
	Double.parseDouble(cdo.getColValue("prima_antiguedad").replace(",","")) +
	Double.parseDouble(cdo.getColValue("ind_valor").replace(",","")) +
	Double.parseDouble(cdo.getColValue("ind_recargo25").replace(",","")) +
	Double.parseDouble(cdo.getColValue("ind_recargo50").replace(",","")) +
	totPreDesc+Double.parseDouble(cdo.getColValue("vac_venc_salario").replace(",",""))+Double.parseDouble(cdo.getColValue("vac_venc_gasto").replace(",",""));
%>

<%
totNetoIsr = Double.parseDouble(cdo.getColValue("imp_renta_sv").replace(",","")) +
	Double.parseDouble(cdo.getColValue("imp_renta_ip").replace(",","")) ;
%>

<%
totNetoSsocial = seg_soc + Double.parseDouble(cdo.getColValue("ssocial_vacprop").replace(",","")) +
	Double.parseDouble(cdo.getColValue("ssocial_vacpropGr").replace(",","")) +
	Double.parseDouble(cdo.getColValue("ssoc_xiii_prop_salario").replace(",","")) +
	Double.parseDouble(cdo.getColValue("ssocial_xiii_prop_gasto").replace(",","")) +
	Double.parseDouble(cdo.getColValue("ssocial_vacVencGr").replace(",",""));
%>

<%
totNetoSeduc = seg_edu + Double.parseDouble(cdo.getColValue("seduc_vacprop").replace(",","")) +
	Double.parseDouble(cdo.getColValue("seduc_vacpropGr").replace(",",""))+Double.parseDouble(cdo.getColValue("seduc_vacVencGr").replace(",","")) ;
%>

<%
totNetoPagar = totNetoIng - totNetoIsr - totNetoSsocial - totNetoSeduc;
%>


	<tr align="left" class="TextRow01">
    <td align="left"> TOTALES :</td>
	<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totNetoIng)%></td>
	<td>&nbsp;</td>
	<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totNetoIsr)%></td>
	<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totNetoSsocial)%></td>
	<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totNetoSeduc)%></td>
	<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(totNetoPagar)%></td>
	</tr>

	<tr align="right" class="TextRow02">
    <td colspan="7">&nbsp;</td>
	</tr>

<%
  }
  %>

	</table>
	<%=fb.formEnd(true)%>
	</body>
	</html>
	<%
		}//GET
	%>
