
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" 		scope="page" 		class="issi.admin.SQLMgr" />
<jsp:useBean id="del" scope="page" class="issi.rhplanilla.Empleado" />
<jsp:useBean id="DI" scope="session" class="java.util.Hashtable" />
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String emp_id = request.getParameter("emp_id");
String id ="";
String anio ="";
boolean viewMode = false;

if (mode == null) mode = "add";
if (fg == null) fg = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;
CommonDataObject cdoT = new CommonDataObject();
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(emp_id != null && !emp_id.equals("")){
		sql = "select to_char(fecha_inicio, 'dd/mm/yyyy') fecha_inicio, to_char(escala_desde, 'dd/mm/yyyy') escala_desde, to_char(escala_hasta, 'dd/mm/yyyy') escala_hasta, provincia, sigla, tomo, asiento, cod_compania, ts_anios, ts_meses, ts_dias, td_semanas, td_meses, valor, emp_id from tbl_pla_li_dist_indem where cod_compania = "+(String) session.getAttribute("_companyId")+" and emp_id = "+request.getParameter("emp_id");
		al = SQLMgr.getDataList(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{	
	//calc();
	parent.newHeight();
}


function calcTotales(a)
{
	var iCounter = 0;
	var size = parseInt(document.form1.keySize.value);
	var sal_bruto = 0.00, gasto_rep = 0.00, prima_produccion = 0.00, xiii_mes = 0.00, vacaciones = 0.00, incentivo = 0.00, bonificacion = 0.00, otros = 0.00;
	var t_sal_bruto = 0.00, t_gasto_rep = 0.00, t_prima_produccion = 0.00, t_xiii_mes = 0.00, t_vacaciones = 0.00, t_incentivo = 0.00, t_bonificacion = 0.00, t_otros = 0.00;
	for(i=0;i<size;i++){
		sal_bruto 				= eval('document.form1.sal_bruto'+i).value;
		gasto_rep 				= eval('document.form1.gasto_rep'+i).value;
		prima_produccion	= eval('document.form1.prima_produccion'+i).value;
		xiii_mes 					= eval('document.form1.xiii_mes'+i).value;
		vacaciones 				= eval('document.form1.vacaciones'+i).value;
		incentivo 				= eval('document.form1.incentivo'+i).value;
		bonificacion 			= eval('document.form1.bonificacion'+i).value;
		otros 						= eval('document.form1.otros'+i).value;
		if(!isNaN(sal_bruto) && sal_bruto!='') t_sal_bruto += parseFloat(sal_bruto);
		if(!isNaN(gasto_rep) && gasto_rep!='') t_gasto_rep += parseFloat(gasto_rep);
		if(!isNaN(prima_produccion) && prima_produccion!='') t_prima_produccion += parseFloat(prima_produccion);
		if(!isNaN(xiii_mes) && xiii_mes!='') t_xiii_mes += parseFloat(xiii_mes);
		if(!isNaN(vacaciones) && vacaciones!='') t_vacaciones += parseFloat(vacaciones);
		if(!isNaN(incentivo) && incentivo!='') t_incentivo += parseFloat(incentivo);
		if(!isNaN(bonificacion) && bonificacion!='') t_bonificacion += parseFloat(bonificacion);
		if(!isNaN(otros) && otros!='') t_otros += parseFloat(otros);
	}
	document.form1.sal_bruto.value 				= t_sal_bruto.toFixed(2);
	document.form1.gasto_rep.value 				= t_gasto_rep.toFixed(2);
	document.form1.prima_produccion.value	= t_prima_produccion.toFixed(2);
	document.form1.xiii_mes.value 				= t_xiii_mes.toFixed(2);
	document.form1.vacaciones.value 			= t_vacaciones.toFixed(2);
	document.form1.incentivo.value 				= t_incentivo.toFixed(2);
	document.form1.bonificacion.value 		= t_bonificacion.toFixed(2);
	document.form1.otros.value 						= t_otros.toFixed(2);
	if (iCounter > 0) return true;
	else return false;
}

function calcThis(i){
	var salario=0.00, gasto_rep = 0.00, s_especie = 0.00;
	salario = eval('document.form1.sal_bruto'+i).value;
	gasto_rep = eval('document.form1.gasto_rep'+i).value;
	s_especie = eval('document.form1.salario_especie'+i).value;
	if(!isNaN(salario) && salario!='') calc();
	else if(salario != '' && isNaN(salario)){
		alert('Introduzca valores numéricos1');
		eval('document.form1.sal_bruto'+i).value = '';
	}
	if(!isNaN(gasto_rep) && gasto_rep!='') calc();
	else if(gasto_rep != '' && isNaN(gasto_rep)){
		alert('Introduzca valores numéricos2');
		eval('document.form1.gasto_rep'+i).value = '';
	}
	if(!isNaN(s_especie) && s_especie!='') calc();
	else if(s_especie != '' && isNaN(s_especie)){
		alert('Introduzca valores numéricos3');
		eval('document.form1.salario_especie'+i).value = '';
	}
}

function doSubmit()
{
	var fg = '<%=fg%>';
	document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.emp_id.value = parent.document.form1.emp_id.value;
	document.form1.segundo_nombre.value = parent.document.form1.segundo_nombre.value;
	document.form1.segundo_apellido.value = parent.document.form1.segundo_apellido.value;
	document.form1.primer_nombre.value = parent.document.form1.primer_nombre.value;
	document.form1.primer_apellido.value = parent.document.form1.primer_apellido.value;
	document.form1.provincia.value = parent.document.form1.provincia.value;
	document.form1.sigla.value = parent.document.form1.sigla.value;
	document.form1.tomo.value = parent.document.form1.tomo.value;
	document.form1.asiento.value = parent.document.form1.asiento.value;
	document.form1.num_empleado.value = parent.document.form1.num_empleado.value;

	if (!parent.form1Validation()) return false;
  else document.form1.submit();
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%//=fb.hidden("size",""+DI.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>

<%=fb.hidden("emp_id","")%>
<%=fb.hidden("segundo_nombre","")%>
<%=fb.hidden("segundo_apellido","")%>
<%=fb.hidden("primer_nombre","")%>
<%=fb.hidden("primer_apellido","")%>
<%=fb.hidden("provincia","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("num_empleado","")%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td>Desde</td>
	<td>Hasta</td>
	<td>A&ntilde;os</td>
	<td>Mes</td>
	<td>D&iacute;as</td>
	<td>Tiempo</td>
	<td>Valor</td>
</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<tr class="<%=color%>" align="center">
  <td>
	<%=fb.textBox("escala_desde"+i,cdo.getColValue("escala_desde"),false,false,true,10,"text10","","")%>
  </td>
  <td>
	<%=fb.textBox("escala_hasta"+i,cdo.getColValue("escala_hasta"),false,false,true,10,"text10","","")%>
  </td>
  <td>
	<%=fb.intBox("ts_anios"+i,cdo.getColValue("ts_anios"),false,false,true, 6, 3,null,null,"")%>
  </td>
  <td>
	<%=fb.intBox("ts_meses"+i,cdo.getColValue("ts_meses"),false,false,true, 6, 3,null,null,"")%>
  </td>
  <td>
	<%=fb.intBox("ts_dias"+i,cdo.getColValue("ts_dias"),false,false,true, 6, 3,null,null,"")%>
  </td>
	<td>
	<%=fb.intBox("td_semanas"+i,cdo.getColValue("td_semanas"),false,false,true, 6, 3,null,null,"")%>
  </td>
	<td>
	<%=fb.decBox("valor"+i,cdo.getColValue("valor"),false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onBlur=\"javascript:calcTotales('gr')\"","",false,"")%>
  </td>
</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
else
{
/*
	System.out.println("_________________________________________________________________");
	String dl = "", close = "true";
	
	del = new Empleado();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	
	if (request.getParameter("emp_id") != null && !request.getParameter("emp_id").equals("") && !request.getParameter("emp_id").equals("NA")) del.setEmpId(request.getParameter("emp_id"));
	
	if (request.getParameter("segundo_nombre") != null && !request.getParameter("segundo_nombre").equals("") && !request.getParameter("segundo_nombre").equals("NA")) del.setSegundoNombre(request.getParameter("segundo_nombre"));
	
	if (request.getParameter("segundo_apellido") != null && !request.getParameter("segundo_apellido").equals("") && !request.getParameter("segundo_apellido").equals("NA")) del.setSegundoApellido(request.getParameter("segundo_apellido"));
	
	if (request.getParameter("primer_nombre") != null && !request.getParameter("primer_nombre").equals("") && !request.getParameter("primer_nombre").equals("NA")) del.setPrimerNombre(request.getParameter("primer_nombre"));
	
	if (request.getParameter("primer_apellido") != null && !request.getParameter("primer_apellido").equals("") && !request.getParameter("primer_apellido").equals("NA")) del.setPrimerApellido(request.getParameter("primer_apellido"));
	
	if (request.getParameter("provincia") != null && !request.getParameter("provincia").equals("") && !request.getParameter("provincia").equals("NA")) del.setProvincia(request.getParameter("provincia"));
	
	if (request.getParameter("sigla") != null && !request.getParameter("sigla").equals("") && !request.getParameter("sigla").equals("NA")) del.setSigla(request.getParameter("sigla"));
	
	if (request.getParameter("tomo") != null && !request.getParameter("tomo").equals("") && !request.getParameter("tomo").equals("NA")) del.setTomo(request.getParameter("tomo"));
	
	if (request.getParameter("asiento") != null && !request.getParameter("asiento").equals("") && !request.getParameter("asiento").equals("NA")) del.setAsiento(request.getParameter("asiento"));
	
	if (request.getParameter("num_empleado") != null && !request.getParameter("num_empleado").equals("") && !request.getParameter("num_empleado").equals("NA")) del.setNumEmpleado(request.getParameter("num_empleado"));
	
	if (request.getParameter("salario_mes") != null && !request.getParameter("salario_mes").equals("") && !request.getParameter("salario_mes").equals("NA")) del.setSalarioMes(request.getParameter("salario_mes"));
	
	if (request.getParameter("gasto_rep") != null && !request.getParameter("gasto_rep").equals("") && !request.getParameter("gasto_rep").equals("NA")) del.setGastoRep(request.getParameter("gasto_rep"));
	
	if (request.getParameter("unidad_organi") != null && !request.getParameter("unidad_organi").equals("") && !request.getParameter("unidad_organi").equals("NA")) del.setUnidadOrgani(request.getParameter("unidad_organi"));
	
	if (request.getParameter("unidad_organi_desc") != null && !request.getParameter("unidad_organi_desc").equals("") && !request.getParameter("unidad_organi_desc").equals("NA")) del.setUnidadOrganiDesc(request.getParameter("unidad_organi_desc"));
	
	if (request.getParameter("accion") != null && !request.getParameter("accion").equals("") && !request.getParameter("accion").equals("NA")) del.setAccion(request.getParameter("accion"));
	
	if (request.getParameter("dias_d") != null && !request.getParameter("dias_d").equals("") && !request.getParameter("dias_d").equals("NA")) del.setDiasD(request.getParameter("dias_d"));
	
	if (request.getParameter("dias_dinero") != null && !request.getParameter("dias_dinero").equals("") && !request.getParameter("dias_dinero").equals("NA")) del.setDiasDinero(request.getParameter("dias_dinero"));
	
	if (request.getParameter("tipo_vacacion") != null && !request.getParameter("tipo_vacacion").equals("") && !request.getParameter("tipo_vacacion").equals("NA")) del.setTipoVacacion(request.getParameter("tipo_vacacion"));
	
	if (request.getParameter("horas_mes") != null && !request.getParameter("horas_mes").equals("") && !request.getParameter("horas_mes").equals("NA")) del.setHorasMes(request.getParameter("horas_mes"));
	
	if (request.getParameter("r_dsp_nombre") != null && !request.getParameter("r_dsp_nombre").equals("") && !request.getParameter("r_dsp_nombre").equals("NA")) del.setRDspNombre(request.getParameter("r_dsp_nombre"));
	
	if (request.getParameter("tiempo_sol") != null && !request.getParameter("tiempo_sol").equals("") && !request.getParameter("tiempo_sol").equals("NA")) del.setTiempoSol(request.getParameter("tiempo_sol"));
	
	if (request.getParameter("cantidad_horas") != null && !request.getParameter("cantidad_horas").equals("") && !request.getParameter("cantidad_horas").equals("NA")) del.setCantidadHoras(request.getParameter("cantidad_horas"));
	
	if (request.getParameter("r_emp_id") != null && !request.getParameter("r_emp_id").trim().equals("") && !request.getParameter("r_emp_id").trim().equals("NA")) del.setREmpId(request.getParameter("r_emp_id"));
	else del.setREmpId("null");
	
	if (request.getParameter("r_num_empleado") != null && !request.getParameter("r_num_empleado").trim().equals("") && !request.getParameter("r_num_empleado").trim().equals("NA")) del.setRNumEmpleado(request.getParameter("r_num_empleado"));
	else del.setRNumEmpleado("null");
	
	if (request.getParameter("r_provincia") != null && !request.getParameter("r_provincia").trim().equals("") && !request.getParameter("r_provincia").trim().equals("NA")) del.setRProvincia(request.getParameter("r_provincia"));
	else del.setRProvincia("null");
	
	if (request.getParameter("r_sigla") != null && !request.getParameter("r_sigla").trim().equals("") && !request.getParameter("r_sigla").trim().equals("NA")) del.setRSigla(request.getParameter("r_sigla"));
	
	if (request.getParameter("r_tomo") != null && !request.getParameter("r_tomo").trim().equals("") && !request.getParameter("r_tomo").trim().equals("NA")) del.setRTomo(request.getParameter("r_tomo"));
	else del.setRTomo("null");
	
	if (request.getParameter("r_asiento") != null && !request.getParameter("r_asiento").trim().equals("") && !request.getParameter("r_asiento").trim().equals("NA")) del.setRAsiento(request.getParameter("r_asiento"));
	else del.setRAsiento("null");
	
	if (request.getParameter("tiempo_sol_dinero") != null && !request.getParameter("tiempo_sol_dinero").equals("") && !request.getParameter("tiempo_sol_dinero").equals("NA")) del.setTiempoSolDinero(request.getParameter("tiempo_sol_dinero"));
	
	if (request.getParameter("acumulado") != null && !request.getParameter("acumulado").equals("") && !request.getParameter("acumulado").equals("NA")) del.setAcumulado(request.getParameter("acumulado"));
	
	if (request.getParameter("bonif_por_reemplazo") != null && !request.getParameter("bonif_por_reemplazo").equals("") && !request.getParameter("bonif_por_reemplazo").equals("NA")) del.setBonifPorReemplazo(request.getParameter("bonif_por_reemplazo"));
	
	if (request.getParameter("diferencia_x_reemplazo") != null && !request.getParameter("diferencia_x_reemplazo").equals("") && !request.getParameter("diferencia_x_reemplazo").equals("NA")) del.setDiferenciaXReemplazo(request.getParameter("diferencia_x_reemplazo"));
	else del.setDiferenciaXReemplazo("null");
	
	if (request.getParameter("fecha_ini") != null && !request.getParameter("fecha_ini").equals("") && !request.getParameter("fecha_ini").equals("NA")) del.setFechaIni(request.getParameter("fecha_ini"));
	
	if (request.getParameter("acumulado_gr") != null && !request.getParameter("acumulado_gr").equals("") && !request.getParameter("acumulado_gr").equals("NA")) del.setAcumuladoGr(request.getParameter("acumulado_gr"));
	
	if (request.getParameter("r_total_periodos") != null && !request.getParameter("r_total_periodos").equals("") && !request.getParameter("r_total_periodos").equals("NA")) del.setRTotalPeriodos(request.getParameter("r_total_periodos"));
	else del.setRTotalPeriodos("null");
	
	if (request.getParameter("r_monto_periodo") != null && !request.getParameter("r_monto_periodo").equals("") && !request.getParameter("r_monto_periodo").equals("NA")) del.setRMontoXPeriodo(request.getParameter("r_monto_periodo"));
	else del.setRMontoXPeriodo("null");
	
	if (request.getParameter("fecha_fin") != null && !request.getParameter("fecha_fin").equals("") && !request.getParameter("fecha_fin").equals("NA")) del.setFechaFin(request.getParameter("fecha_fin"));
	
	if (request.getParameter("acumulado_sespecie") != null && !request.getParameter("acumulado_sespecie").equals("") && !request.getParameter("acumulado_sespecie").equals("NA")) del.setAcumuladoSEspecie(request.getParameter("acumulado_sespecie"));
	
	if (request.getParameter("comentario") != null && !request.getParameter("comentario").equals("") && !request.getParameter("comentario").equals("NA")) del.setComentario(request.getParameter("comentario"));
	
	if (request.getParameter("anio") != null && !request.getParameter("anio").equals("") && !request.getParameter("anio").equals("NA")) del.setAnio(request.getParameter("anio"));
	
	if (request.getParameter("periodo") != null && !request.getParameter("periodo").equals("") && !request.getParameter("periodo").equals("NA")) del.setPeriodo(request.getParameter("periodo"));
	
	if (request.getParameter("forma_pago") != null && !request.getParameter("forma_pago").equals("") && !request.getParameter("forma_pago").equals("NA")) del.setFormaPago(request.getParameter("forma_pago"));

	//int size = Integer.parseInt(request.getParameter("size"));
	int ln = 0;
	del.getTemporalVacs().clear();
	del.getDistDiasVacs().clear();
	DI.clear();
	for (int i=0; i<keySize; i++){
		if(){
			DistDiasVac di = new DistDiasVac();
			
			if (request.getParameter("dias_vac"+i) != null && !request.getParameter("dias_vac"+i).equals("")) di.setDiasVac(request.getParameter("dias_vac"+i));
			if (request.getParameter("valor_vac"+i) != null && !request.getParameter("valor_vac"+i).equals("")) di.setValorVac(request.getParameter("valor_vac"+i));
			if (request.getParameter("dias_libres"+i) != null && !request.getParameter("dias_libres"+i).equals("")) di.setDiasLibres(request.getParameter("dias_libres"+i));
			if (request.getParameter("valor_libres"+i) != null && !request.getParameter("valor_libres"+i).equals("")) di.setValorLibres(request.getParameter("valor_libres"+i));
			if (request.getParameter("dias_neto"+i) != null && !request.getParameter("dias_neto"+i).equals("")) di.setDiasNeto(request.getParameter("dias_neto"+i));
			if (request.getParameter("valor_neto"+i) != null && !request.getParameter("valor_neto"+i).equals("")) di.setValorNeto(request.getParameter("valor_neto"+i));
			if (request.getParameter("gasto_rep"+i) != null && !request.getParameter("gasto_rep"+i).equals("")) di.setGastoRep(request.getParameter("gasto_rep"+i));
			if (request.getParameter("salario_especie"+i) != null && !request.getParameter("salario_especie"+i).equals("")) di.setSalarioEspecie(request.getParameter("salario_especie"+i));
			if (request.getParameter("anio_ac"+i) != null && !request.getParameter("anio_ac"+i).equals("")) di.setAnioAc(request.getParameter("anio_ac"+i));
			if (request.getParameter("mes"+i) != null && !request.getParameter("mes"+i).equals("")) di.setMes(request.getParameter("mes"+i));
			if (request.getParameter("quincena"+i) != null && !request.getParameter("quincena"+i).equals("")) di.setQuincena(request.getParameter("quincena"+i));
			if (request.getParameter("anio_pago"+i) != null && !request.getParameter("anio_pago"+i).equals("")) di.setAnioPago(request.getParameter("anio_pago"+i));
			if (request.getParameter("quincena_pago"+i) != null && !request.getParameter("quincena_pago"+i).equals("")) di.setQuincenaPago(request.getParameter("quincena_pago"+i));
			if (request.getParameter("codigo"+i) != null && !request.getParameter("codigo"+i).equals("")) di.setCodigo(request.getParameter("codigo"+i));
			
			try{
				ln++;
				if (ln < 10) key = "00"+ln;
				else if (ln < 100) key = "0"+ln;
				else key = ""+ln;

				DI.put(key,di);
				del.getDistDiasVacs().add(di);
				//System.out.println("Adding item...");
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		} else {
			TemporalVac di = new TemporalVac();
			
			if (request.getParameter("secuencia"+i) != null && !request.getParameter("secuencia"+i).equals("")) di.setSecuencia(request.getParameter("secuencia"+i));
			if (request.getParameter("anio"+i) != null && !request.getParameter("anio"+i).equals("")) di.setAnio(request.getParameter("anio"+i));
			if (request.getParameter("periodo"+i) != null && !request.getParameter("periodo"+i).equals("")) di.setPeriodo(request.getParameter("periodo"+i));
			if (request.getParameter("mes"+i) != null && !request.getParameter("mes"+i).equals("")) di.setMes(request.getParameter("mes"+i));
			if (request.getParameter("quincena"+i) != null && !request.getParameter("quincena"+i).equals("")) di.setQuincena(request.getParameter("quincena"+i));
			if (request.getParameter("sal_bruto"+i) != null && !request.getParameter("sal_bruto"+i).equals("")) di.setSalBruto(request.getParameter("sal_bruto"+i));
			if (request.getParameter("gasto_rep"+i) != null && !request.getParameter("gasto_rep"+i).equals("")) di.setGastoRep(request.getParameter("gasto_rep"+i));
			if (request.getParameter("salario_especie"+i) != null && !request.getParameter("salario_especie"+i).equals("")) di.setSalarioEspecie(request.getParameter("salario_especie"+i));
			
			try{
				ln++;
				if (ln < 10) key = "00"+ln;
				else if (ln < 100) key = "0"+ln;
				else key = ""+ln;

				DI.put(key,di);
				del.getTemporalVacs().add(di);
				//System.out.println("Adding item...");
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		}
	}

	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../inventario/reg_delivery_item.jsp?mode="+mode+ "&change=1&type=2&fg="+fg);
		return;
	}
	
	System.out.println("del.getDistDiasVacs().size()="+del.getDistDiasVacs().size());

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		del.setCompania((String) session.getAttribute("_companyId"));
		del.setUsuarioCreacion((String) session.getAttribute("_userName"));
		del.setUsuarioModificacion((String) session.getAttribute("_userName"));
		EmplMgr.updateDist(del);
	} else if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		del.setCompania((String) session.getAttribute("_companyId"));
		del.setUsuarioCreacion((String) session.getAttribute("_userName"));
		del.setUsuarioModificacion((String) session.getAttribute("_userName"));
		EmplMgr.approve(del);
	}
	if(EmplMgr.getErrCode().equals("1")){
	}
	*/
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	parent.document.form1.errCode.value = <%//=EmplMgr.getErrCode()%>;
	parent.document.form1.errMsg.value = '<%//=EmplMgr.getErrMsg()%>';
	parent.document.form1.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
