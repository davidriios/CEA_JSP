<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" 		scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" 		scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" 	scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" 		scope="page" 		class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" 		scope="page" 		class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" 				scope="page" 		class="issi.admin.FormBean" />
<jsp:useBean id="cdo" 			scope="page" 		class="issi.admin.CommonDataObject" />
<jsp:useBean id="htTempVac" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htTempVacKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htTempVacProp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htTempVacPropKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="AEmpMgr" 			scope="page" 		class="issi.rhplanilla.AccionesEmpleadoMgr" />
<%
/**
==================================================================================
800033	VER LISTA DE TIPO DE UNIFORME
800034	IMPRIMIR LISTA DE TIPO DE UNIFORME
800035	AGREGAR TIPO DE UNIFORME
800036	MODIFICAR TIPO DE UNIFORME
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr);

htTempVac.clear();
htTempVacKey.clear();
htTempVacProp.clear();
htTempVacPropKey.clear();
CommonDataObject cdoM = new CommonDataObject();
cdoM.addColValue("pagar_vacacion", "N");
cdoM.addColValue("pagar_xiii_mes", "N");
cdoM.addColValue("pagar_pantig", "N");
cdoM.addColValue("pagar_indemn", "N");
cdoM.addColValue("pagar_recargo25", "N");
cdoM.addColValue("pagar_recargo50", "N");

ArrayList tempVac = new ArrayList();
ArrayList tempVacProp = new ArrayList();

String sql = "";
String mode = request.getParameter("mode");
String emp_id = request.getParameter("emp_id");
String change = request.getParameter("change");
String fp = "liquidacion";
if(request.getParameter("fp")!= null && !request.getParameter("fp").equals("")) fp = request.getParameter("fp");
String tabLabel = "'Liquidacion','Acumulados','Salario x Pagar'";
String tabFunctions = "'1=tabAcumulado()', '2=getPlaLiqDLTotales()'";
int idxTabs = 2;
if (mode == null) mode = "add";
if(change==null) change="";
int indTab = 0;
boolean viewMode = false;
if(mode.trim().equals("view"))viewMode=true;
//if(request.getParameter("indTab")!=null && !request.getParameter("indTab").equalsIgnoreCase("undefined")) indTab = Integer.parseInt(request.getParameter("indTab"));
String compania = (String) session.getAttribute("_companyId");


if (request.getMethod().equalsIgnoreCase("GET")){
	if(emp_id != null){
		String key = "";
		if(!mode.trim().equals("add")){
			sql = "select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, to_char(a.fecha_egreso, 'dd/mm/yyyy') fecha_egreso, to_char(a.fecha_docto, 'dd/mm/yyyy') fecha_docto, a.motivo, a.periodo_pago, a.anio_pago, nvl(a.ts_anios,0) anios, nvl(a.ts_meses,0) meses, nvl(a.ts_dias,0) dias, to_char(a.dl_desde, 'dd/mm/yyyy') fecha_inicio, to_char(a.dl_hasta, 'dd/mm/yyyy') fecha_final, a.dl_dias_laborados dias_laborados, a.dl_thoras_regulares horas_regulares, nvl(a.vac_venc_dias,0) dias_vacaciones, a.vac_venc_salario vac_salario, round(a.vac_venc_salario * 11, 2) acum_salario, a.vac_venc_gasto vac_gasto, round(a.vac_venc_gasto * 11, 2) acum_gasto, round(a.vac_prop_salario * a.vac_prop_periodos, 2) acump_salario, round(a.vac_prop_gasto * a.vac_prop_periodos, 2) acump_gasto, a.vac_prop_periodos vacp_periodos, a.vac_prop_salario vacp_salario, a.vac_prop_salario vac_prop_sal, a.vac_prop_gasto vacp_gasto, a.vac_prop_gasto vac_prop_gr, a.xiii_prop_salario xiii_salario, a.xiii_prop_gasto xiii_gasto, a.prm_acumulado pr_acumulado, nvl(a.prm_promedio_sem, 0) pr_promedio, a.prm_anios, nvl(a.prm_anios_valor, 0) pr_valor_anios, a.prm_meses, nvl(a.prm_meses_valor, 0) pr_valor_meses, a.prm_dias, nvl(a.prm_dias_valor, 0) pr_valor_dias, a.ind_salario_ult6m in_salario_ult6mes, a.ind_salario_ultmes in_ultimo_salario, a.ind_promedio_sem in_promedio_sem, a.ind_promedio_mes in_promedio_men, a.ind_valor in_indemnizacion, a.recibe_preaviso in_ck_preaviso, a.recibe_recargo50 in_ck_recargo50, a.recibe_recargo25 in_ck_recargo25, a.ind_recargo50, a.ind_recargo25, a.preaviso_valor in_preaviso, a.ot_beneficios_valor pr_otros_beneficios, a.imp_ssocial, a.imp_seducat, a.imp_renta_sv imp_renta, a.imp_renta_ip imp_rentae, a.imp_renta_trx, a.imp_renta_xiii, a.cxc_empleado imp_cxcemp, a.imp_periodos, nvl(a.prm_semanas, 0) pr_semanas, round(a.prm_anios_valor + a.prm_meses_valor + a.prm_dias_valor, 2) pr_valor_prima, a.desc_preaviso pr_ck_preaviso, a.desc_preaviso_valor pr_preaviso, a.cxc_clinica imp_clinica, a.estado, a.forma_pago, a.num_cheque, to_char(a.fecha_cheque, 'dd/mm/yyyy') fecha_cheque, nvl(a.xiii_acum_salario, 0) acum_xiii_sal, nvl(a.xiii_acum_grep, 0) acum_xiii_gr, a.unidad_organi, a.observacion, to_char(a.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso, a.ajuste_creado, a.emp_id, nvl(e.num_ssocial, ' ') num_ssocial, nvl(e.primer_nombre, ' ') primer_nombre, nvl(e.segundo_nombre, ' ') segundo_nombre, nvl(e.primer_apellido, ' ') primer_apellido, e.unidad_organi, b.descripcion as unidad_organi_desc, nvl(e.num_empleado, ' ') num_empleado, nvl(to_char(e.gasto_rep), ' ') gasto_rep, e.salario_base, nvl(to_char(round(nvl(e.rata_hora,0),2)), ' ') rata_hora, decode(nvl(e.salario_base, 0), 0, e.rata_hora, e.salario_base) salario_mes, e.ubic_seccion, to_char(e.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso, e.horario, e.tipo_renta, e.num_dependiente, e.cargo, c.denominacion cargo_desc, round((nvl(e.gasto_rep, 0) / d.cant_horas_mes), 2) rata_x_horagr, nvl(e.acum_decimo, 0) acum_xiii_sal, nvl(e.acum_decimo_gr, 0) acum_xiii_gr from tbl_pla_li_liquidacion a, tbl_pla_empleado e, tbl_sec_unidad_ejec b, tbl_pla_cargo c, tbl_pla_horario_trab d where a.compania = e.compania and a.emp_id = e.emp_id and e.unidad_organi = b.codigo and e.compania = b.compania and e.compania = c.compania and e.cargo = c.codigo and e.horario = d.codigo and e.compania = d.compania and a.compania = "+(String) session.getAttribute("_companyId")+" and a.emp_id = "+emp_id + " and trunc(a.fecha_egreso) = to_date('"+request.getParameter("liq_fecha_egreso")+"', 'dd/mm/yyyy')";

			cdo = SQLMgr.getData(sql);
		}
		if(mode.trim().equals("add") ||cdo ==null){
			sql = "select a.compania, a.emp_id, a.provincia, a.sigla, a.tomo, a.asiento, nvl(a.num_ssocial, ' ') num_ssocial, nvl(a.primer_nombre, ' ') primer_nombre, nvl(a.segundo_nombre, ' ') segundo_nombre, nvl(a.primer_apellido, ' ') primer_apellido, a.unidad_organi, b.descripcion as unidad_organi_desc, nvl(a.num_empleado, ' ') num_empleado, nvl(to_char(a.gasto_rep), ' ') gasto_rep, a.salario_base, nvl(to_char(a.rata_hora), ' ') rata_hora, decode(nvl(a.salario_base, 0), 0, a.rata_hora, a.salario_base) salario_mes, a.ubic_seccion, to_char(a.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso, a.horario, a.tipo_renta, a.num_dependiente, a.cargo, c.denominacion cargo_desc, round((nvl(a.gasto_rep, 0)/d.cant_horas_mes), 2) rata_x_horagr, nvl(a.acum_decimo, 0) acum_xiii_sal, nvl(a.acum_decimo_gr, 0) acum_xiii_gr from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_cargo c, tbl_pla_horario_trab d where a.compania = "+(String) session.getAttribute("_companyId")+" and a.unidad_organi = b.codigo and a.compania = b.compania and a.compania = c.compania and a.cargo = c.codigo and a.emp_id = "+emp_id + " and a.horario = d.codigo and a.compania = d.compania";
		cdo = SQLMgr.getData(sql);
		}

		if((request.getParameter("motivo")!=null && !request.getParameter("motivo").equals("")) || (cdo.getColValue("motivo") != null && !cdo.getColValue("motivo").equals(""))){
			sql = "select pagar_vacacion, pagar_xiii_mes, pagar_pantig, pagar_indemn, pagar_recargo25, pagar_recargo50 from tbl_pla_li_motivo where codigo = "+(request.getParameter("motivo")==null?cdo.getColValue("motivo"):request.getParameter("motivo"))+" and compania = " + (String) session.getAttribute("_companyId");
			System.out.println("sql tab motivos\n"+sql);
			cdoM = SQLMgr.getData(sql);
			if(cdoM.getColValue("pagar_vacacion").equals("S")){
				tabLabel += ",'Vacaciones'";
				idxTabs++;
				if(!mode.equals("view")) tabFunctions += ", '"+idxTabs+"=tabVacaciones()'";
			}
			if(cdoM.getColValue("pagar_xiii_mes").equals("S")){
				tabLabel += ",'Decimo'";
				idxTabs++;
				tabFunctions += ", '"+idxTabs+"=tabDecimo()'";
			}
			if(cdoM.getColValue("pagar_pantig").equals("S")){
				tabLabel 	+= ",'Prima de Antiguedad'";
				idxTabs++;
				//if(mode.equals("add"))
				tabFunctions += ", '"+idxTabs+"=tabPrimaAntiguedad()'";
			}
			if(cdoM.getColValue("pagar_indemn").equals("S")){
				tabLabel 	+= ",'Indemnizacion'";
				idxTabs++;
				//if(mode.equals("add"))
				tabFunctions += ", '"+idxTabs+"=tabIndemnizacion()'";
			}
			tabLabel += ",'Deducciones'";
			idxTabs++;
			tabFunctions += ", '"+idxTabs+"=tabImpuestos()'";

		}
		if(request.getParameter("fecha_egreso")!=null && !request.getParameter("fecha_egreso").equals("")){
			cdo.addColValue("fecha_egreso", request.getParameter("fecha_egreso"));
			sql = "select to_char(a.fecha_inicio, 'dd/mm/yyyy') fecha_inicio, a.anio, a.secuencia, a.periodo, a.provincia, a.sigla, a.tomo, a.asiento, a.cod_compania, nvl(a.sal_bruto, 0) sal_bruto, nvl(a.gasto_rep, 0) gasto_rep, nvl(a.salario_especie, 0) salario_especie, a.emp_id, b.descripcion mes, decode(b.quincena1, a.periodo, 'PRIMERA', 'SEGUNDA') quincena from tbl_pla_temporal_vac a, tbl_pla_vac_parametro b where cod_compania = "+(String) session.getAttribute("_companyId")+" and emp_id = "+emp_id+" and trunc(fecha_inicio) = to_date('"+request.getParameter("fecha_egreso")+"', 'dd/mm/yyyy') and (b.quincena1 = a.periodo or b.quincena2 = a.periodo) order by secuencia";
			tempVac = SQLMgr.getDataList(sql);
			int lineNo = 0;
			for(int j=0;j<tempVac.size();j++){
				CommonDataObject cdoDet = (CommonDataObject) tempVac.get(j);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				try{
					htTempVac.put(key,cdoDet);
					htTempVacKey.put(cdoDet.getColValue("secuencia"), key);
					System.out.println("Adding item... "+key +"_"+cdoDet.getColValue("secuencia"));
				} catch (Exception e){
					System.out.println("Unable to add item...");
				}
			}
			sql = "select to_char(a.fecha_inicio, 'dd/mm/yyyy') fecha_inicio, a.anio, a.secuencia, a.periodo, a.provincia, a.sigla, a.tomo, a.asiento, a.cod_compania, nvl(a.sal_bruto, 0) sal_bruto, nvl(a.gasto_rep, 0) gasto_rep, a.emp_id, b.descripcion mes, decode(b.quincena1, a.periodo, 'PRIMERA', 'SEGUNDA') quincena from tbl_pla_li_vacaciones_prop a, tbl_pla_vac_parametro b where cod_compania = "+(String) session.getAttribute("_companyId")+" and emp_id = "+emp_id+" and trunc(fecha_inicio) = to_date('"+request.getParameter("fecha_egreso")+"', 'dd/mm/yyyy') and (b.quincena1 = a.periodo or b.quincena2 = a.periodo) order by a.anio desc,a.periodo desc";
			tempVacProp = SQLMgr.getDataList(sql);
			lineNo = 0;
			for(int j=0;j<tempVacProp.size();j++){
				CommonDataObject cdoDet = (CommonDataObject) tempVacProp.get(j);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				try{
					htTempVacProp.put(key,cdoDet);
					htTempVacPropKey.put(cdoDet.getColValue("secuencia"), key);
					System.out.println("Adding item... "+key +"_"+cdoDet.getColValue("secuencia"));
				} catch (Exception e){
					System.out.println("Unable to add item...");
				}
			}
		}
		if(request.getParameter("fecha_docto")!=null && !request.getParameter("fecha_docto").equals("")) cdo.addColValue("fecha_docto", request.getParameter("fecha_docto"));
		if(request.getParameter("motivo")!=null && !request.getParameter("motivo").equals("")) cdo.addColValue("motivo", request.getParameter("motivo"));
		if(request.getParameter("periodo_pago")!=null && !request.getParameter("periodo_pago").equals("")) cdo.addColValue("periodo_pago", request.getParameter("periodo_pago"));
		if(request.getParameter("anio_pago")!=null && !request.getParameter("anio_pago").equals("")) cdo.addColValue("anio_pago", request.getParameter("anio_pago"));
		if(request.getParameter("num_cheque")!=null && !request.getParameter("num_cheque").equals("")) cdo.addColValue("num_cheque", request.getParameter("num_cheque"));

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Planilla - '+document.title;

function doAction()
{
<%if(mode.equals("add")){%>	alert('Recuerde revisar si el empleado tiene Vacaciones Vencidas, antes de Registrar la Liquidacion!!!');<%}%>
changeFechaEgreso();
<%if(mode.equals("edit")){%>
setFormsValues();
<%}%>
}
function reqInfo(showAlert){if(showAlert==undefined)showAlert=true;var isValid=false;
var p_empId='';var p_provincia='';var p_sigla='';var p_tomo='';var p_asiento='';
var v_fecha_egreso = '';var v_fecha_ingreso = '';var p_salario_base = '';var motivo = '';var p_ck_recargo50 = '';

if(showAlert){alert('Por favor seleccione Empleado!');}
else{p_empId=document.form0.emp_id.value;
p_provincia=document.form0.provincia.value;
p_sigla=document.form0.sigla.value;
p_tomo=document.form0.tomo.value;
p_asiento=document.form0.asiento.value;
v_fecha_egreso = document.form0.fecha_egreso.value;
v_fecha_ingreso = document.form0.fecha_ingreso.value;
p_salario_base = document.form0.salario_base.value;
motivo = document.form0.motivo.value;
p_ck_recargo50 = document.form0.p_ck_recargo50.value;
isValid=true;
}
return{isValid:isValid,p_empId:p_empId,p_provincia:p_provincia,p_sigla:p_sigla,p_tomo:p_tomo,p_asiento:p_asiento
,v_fecha_egreso:v_fecha_egreso,v_fecha_ingreso:v_fecha_ingreso,p_salario_base:p_salario_base,motivo:motivo,p_ck_recargo50:p_ck_recargo50};}
function getPromSemanal(){
	var promedioSemanal =0;
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	if(document.form5.pr_ck_preaviso.checked){

	var req=reqInfo(false);

	if(executeDB('<%=request.getContextPath()%>','call sp_pla_liq_sal_promedioSem(<%=compania%>,'+req.p_empId+','+req.p_provincia+',\''+req.p_sigla+'\','+req.p_tomo+','+req.p_asiento+',\''+req.v_fecha_egreso+'\','+req.p_salario_base+')'))
	{

		var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
		var arr_cursor = new Array();
		if(msg!='')
		{
			arr_cursor = splitCols(msg);
		 	/*promedioSemanal = getDBData('<%=request.getContextPath()%>', 'sp_pla_liq_sal_promedioSem(<%=compania%>,'+req.p_empId+','+req.p_provincia+',\''+req.p_sigla+'\','+req.p_tomo+','+req.p_asiento+',\''+req.v_fecha_egreso+'\','+req.p_salario_base+')','dual','','');
	 		*/
	 		promedioSemanal =arr_cursor[0];
	 	}
		if(promedioSemanal!=0)document.form5.pr_preaviso.value= promedioSemanal;

	}else document.form5.pr_preaviso.value = 0;
	}else document.form5.pr_preaviso.value = 0;

}

function setBAction(form, value){
	if(form=='form1'){
		window.frames['itemFrameAcum'].doSubmit(value);
	}
}

function setLiquidacion(fecha){
	var emp_id = document.form0.emp_id.value;
	if(fecha!='') window.location = '../rhplanilla/reg_liquidacion.jsp?mode=edit&emp_id='+emp_id+'&liq_fecha_egreso='+fecha;
	else window.location = '../rhplanilla/reg_liquidacion.jsp?mode=add&emp_id='+emp_id;
}

function setFormsValues(){
	getDiasLaborados();
}

function selEmpleado(){
	abrir_ventana1('../common/search_empleado.jsp?fp=liquidacion');
}

function changeMotivo(value){
	var emp_id = document.form0.emp_id.value;
	var fecha_egreso = document.form0.fecha_egreso.value;
	var fecha_docto = document.form0.fecha_docto.value;
	var periodo_pago = document.form0.periodo_pago.value;
	var anio_pago = document.form0.anio_pago.value;
	var num_cheque = document.form0.num_cheque.value;
	var url = 'emp_id='+emp_id+'&motivo='+value;
	if(fecha_egreso != '') url += '&fecha_egreso='+fecha_egreso;
	if(fecha_docto != '') url += '&fecha_docto='+fecha_docto;
	if(periodo_pago != '') url += '&periodo_pago='+periodo_pago;
	if(anio_pago != '') url += '&anio_pago='+anio_pago;
	if(num_cheque != '') url += '&num_cheque='+num_cheque;
	window.location= '../rhplanilla/reg_liquidacion.jsp?'+url;
}

function changeFechaEgreso(){
<%if(mode.equals("add")){%>
	var fecha_ingreso = document.form0.fecha_ingreso.value;
	var fecha_egreso = document.form0.fecha_egreso.value;
	var sql = 'trunc(months_between(to_date(\'' + fecha_egreso + '\', \'dd/mm/yyyy\'), to_date(\'' + fecha_ingreso + '\', \'dd/mm/yyyy\'))/12,0) anio,  mod(trunc(months_between(to_date(\'' + fecha_egreso + '\', \'dd/mm/yyyy\'), to_date(\'' + fecha_ingreso + '\', \'dd/mm/yyyy\')),0), 12) mes, to_date(\'' + fecha_egreso + '\', \'dd/mm/yyyy\') - add_months(to_date(\'' + fecha_ingreso + '\', \'dd/mm/yyyy\'), (nvl(trunc(months_between(to_date(\'' + fecha_egreso + '\', \'dd/mm/yyyy\'), to_date(\'' + fecha_ingreso + '\', \'dd/mm/yyyy\'))/12,0), 0)*12 + nvl(mod(trunc(months_between(to_date(\'' + fecha_egreso + '\', \'dd/mm/yyyy\'), to_date(\'' + fecha_ingreso + '\', \'dd/mm/yyyy\')),0), 12), 0))) + 1 dias, trunc(months_between(to_date(\'' + fecha_egreso + '\', \'dd/mm/yyyy\'), to_date(\'' + fecha_ingreso + '\',\'dd/mm/yyyy\'))/12,0) *  52 anios_semana, round(mod(trunc(months_between(to_date(\'' + fecha_egreso + '\', \'dd/mm/yyyy\'), to_date(\'' + fecha_ingreso + '\',\'dd/mm/yyyy\')),0), 12) * 52 / 12, 2) meses_semana, round((((to_date(\'' + fecha_egreso + '\', \'dd/mm/yyyy\') - add_months(to_date(\'' + fecha_ingreso + '\',\'dd/mm/yyyy\'), (nvl(trunc(months_between(to_date(\'' + fecha_egreso + '\', \'dd/mm/yyyy\'), to_date(\'' + fecha_ingreso + '\', \'dd/mm/yyyy\'))/12,0), 0)*12 + nvl(mod(trunc(months_between(to_date(\'' + fecha_egreso + '\', \'dd/mm/yyyy\'), to_date(\'' + fecha_ingreso + '\', \'dd/mm/yyyy\')),0), 12), 0))))/30)*52)/12, 2) dias_semana';
	if(fecha_egreso != ''){
		var x = getDBData('<%=request.getContextPath()%>', sql,'dual','','');
		var arr_cursor = new Array();
		if(x!=''){
			arr_cursor = splitCols(x);
			if(arr_cursor[0]!=' ') document.form0.anios.value	= arr_cursor[0];
			if(arr_cursor[1]!=' ') document.form0.meses.value	= arr_cursor[1];
			if(arr_cursor[2]!=' ') document.form0.dias.value	= arr_cursor[2] ;
			var anios_semana = arr_cursor[3];
			var meses_semana = arr_cursor[4];
			var dias_semana = arr_cursor[5];
			var total_semanas = parseFloat(anios_semana) + parseFloat(meses_semana) + parseFloat(dias_semana) ;
			if(total_semanas > 260) total_semanas = 260;
			document.form0.anios_semana.value = anios_semana;
			document.form0.meses_semana.value = meses_semana;
			document.form0.dias_semana.value = dias_semana ;
			document.form0.total_semanas.value = total_semanas;
		}
	}
<%} else if(mode.equals("edit")){%>
			var anios = document.form0.anios.value;
			var meses = document.form0.meses.value;
			var dias = document.form0.dias.value;
			var anios_semana = anios *52;
			var meses_semana = (meses*52)/12;
			var dias_semana = ((dias/30)*52)/12;
			meses_semana = meses_semana.toFixed(2)
			dias_semana = dias_semana.toFixed(2)
			var total_semanas = parseFloat(anios_semana) + parseFloat(meses_semana) + parseFloat(dias_semana) ;
			if(total_semanas > 260) total_semanas = 260;
			document.form0.anios_semana.value = anios_semana;
			document.form0.meses_semana.value = meses_semana;
			document.form0.dias_semana.value = dias_semana ;
			document.form0.total_semanas.value = total_semanas;
<%}%>
}

function getDiasLaborados(){
	var fecha_final = document.form2.fecha_final.value;
	var fecha_inicio = document.form2.fecha_inicio.value;
	var emp_id = document.form2.emp_id.value;
	var rata_x_hora = document.form2.rata_x_hora.value;
	var rata_x_horagr = document.form2.rata_x_horagr.value;

	if(fecha_inicio != '' && fecha_final != ''){
		var x = getDBData('<%=request.getContextPath()%>', 'getDiasLaborados(<%=(String) session.getAttribute("_companyId")%>, '+emp_id+', \''+fecha_inicio+'\', \''+fecha_final+'\')','dual','','');
		var arr_cursor = new Array();
		if(x!=''){
			arr_cursor = splitCols(x);
			if(arr_cursor[0]!=' ') document.form2.horas_regulares.value	= arr_cursor[0];
			if(arr_cursor[1]!=' ') document.form2.horas_sabados.value	= arr_cursor[1];
			if(arr_cursor[2]!=' ') document.form2.dias_laborados.value	= arr_cursor[2];
			document.form2.salario_pagar.value = (arr_cursor[0] * parseFloat(rata_x_hora)).toFixed(2);
			document.form2.salario_pagargr.value = (arr_cursor[0] * parseFloat(rata_x_horagr)).toFixed(2);
		}
	}
}

function getPlaLiqDLTotales(){//pu_verificar_totales
	var anio_pago = document.form0.anio_pago.value;
	var periodo_pago = document.form0.periodo_pago.value;
	var emp_id = document.form2.emp_id.value;
	if(anio_pago != '' && periodo_pago != ''){
		var x = getDBData('<%=request.getContextPath()%>', 'getPlaLiqDLTotales(<%=(String) session.getAttribute("_companyId")%>, '+emp_id+', '+anio_pago+', '+periodo_pago+')','dual','','');
		var arr_cursor = new Array();
		if(x!=''){
			arr_cursor = splitCols(x);
			document.form2.tr_pa_trx.value	= arr_cursor[0];
			document.form2.tr_pa_trx_bon.value	= arr_cursor[1];
			document.form2.tr_ds_trx.value	= arr_cursor[2];
			document.form2.tr_pa_st.value	= arr_cursor[3];
			document.form2.tr_pa_at.value	= arr_cursor[4];
			document.form2.tr_ds_st.value	= arr_cursor[5];
			document.form2.tr_ds_at.value	= arr_cursor[6];
			document.form2.tr_ausencia.value	= arr_cursor[7];
			document.form2.tr_tardanza.value	= arr_cursor[8];
			document.form2.tr_pa.value	= arr_cursor[9];
			document.form2.tr_ds.value	= arr_cursor[10];
		}
	} //else alert('Introduzca Año/Periodo de Pago!');
}

function tabAcumulado(){
	<%
	if(mode.equals("add")){
	%>
	var p_compania        = <%=(String) session.getAttribute("_companyId")%>;//in number,
	var p_emp_id          = document.form1.emp_id.value;					//in number,
	var p_num_empleado    = document.form1.num_empleado.value;		//in varchar2,
	var p_anios       = document.form0.anios.value;				//in number,
	var p_meses       = document.form0.meses.value;				//in number,
	var p_dias       = document.form0.dias.value;				//in number,
	var v_fecha_egreso    = document.form0.fecha_egreso.value;		//in varchar2,  --:trabajo.fecha_egreso
	var p_provincia       = document.form1.provincia.value;				//in number,
	var p_sigla           = document.form1.sigla.value;						//in varchar2,
	var p_tomo            = document.form1.tomo.value;						//in number,
	var p_asiento         = document.form1.asiento.value;					//in number,
	var p_salario_pagar   = document.form2.salario_pagar.value;		//in number,    --:trab_salario.salario_pagar
	var p_tr_pa           = document.form2.tr_pa.value;						//in number,    --:trab_transac.tr_pa
	var p_salario_pagargr = document.form2.salario_pagargr.value;	//in number     --:trab_salario.salario_pagargr
	var p_dias_laborados = document.form2.dias_laborados.value;	//in number     --:trab_salario.dias_laborados
	var p_salario_pagargr = document.form2.salario_pagargr.value;	//in number     --:trab_salario.salario_pagargr
	var v_fecha_final     = document.form2.fecha_final.value;			//in varchar2,  --:trab_salario.fecha_final
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	var calc_acumulados = false;

	if(p_sigla=='' || p_sigla ==' ') p_sigla = 'null';
	else p_sigla = '\''+p_sigla+'\'';
	if(v_fecha_final =='' || v_fecha_final ==' ') v_fecha_final = 'null';
	else v_fecha_final = '\''+v_fecha_final+'\'';
	if(p_salario_pagar =='' || p_salario_pagar ==' ') p_salario_pagar = 'null';
	if(p_tr_pa =='' || p_tr_pa ==' ') p_tr_pa = 'null';
	if(p_salario_pagargr =='' || p_salario_pagargr ==' ') p_salario_pagargr = 'null';
	if(p_dias_laborados =='' || p_dias_laborados ==' ') p_dias_laborados = 'null';

	if(v_fecha_egreso =='' || v_fecha_egreso ==' ') alert('Introduzca la fecha de la terminación del contrato!');
	else {
		var x = getDBData('<%=request.getContextPath()%>', '1','tbl_pla_li_pagos','emp_id = ' + p_emp_id + ' and num_empleado = \'' + p_num_empleado + '\' and trunc(fecha_inicio) = to_date(\''+v_fecha_egreso+'\', \'dd/mm/yyyy\')' ,'');
		if(x!=''){
			calc_acumulados = confirm('Existen acumulados grabados, desea trabajar con estos acumulados?')
		}
		if(!calc_acumulados){
			if(executeDB('<%=request.getContextPath()%>','call sp_pla_acumulado_001(' + p_compania + ', ' + p_emp_id + ', \'' + p_num_empleado + '\', ' + p_anios + ', ' + p_meses + ', ' + p_dias + ', \'' + v_fecha_egreso + '\', ' + p_provincia + ', ' + p_sigla + ', ' + p_tomo + ', ' + p_asiento + ', ' + p_salario_pagar + ', ' + p_tr_pa + ', ' + p_salario_pagargr +', ' + p_dias_laborados +', ' + v_fecha_final +')')){
				window.frames["itemFrameAcum"].location = '../rhplanilla/reg_liquidacion_det_acum.jsp?fp=<%=fp%>&emp_id=<%=emp_id%>&fecha_egreso='+v_fecha_egreso+'&num_empleado=<%=cdo.getColValue("num_empleado")%>';
				null;
			}
		}
		setHeight('itemFrameAcum',document.body.scrollHeight);
	}
	<%
	} else {
	%>
	setHeight('itemFrameAcum',document.body.scrollHeight);
	<%
	}
	%>
}

function tabVacaciones(){
	var p_compania        = <%=(String) session.getAttribute("_companyId")%>;//in number,
	var p_emp_id          = document.form3.emp_id.value;					//in number,
	var p_num_empleado    = document.form3.num_empleado.value;		//in varchar2,
	var p_provincia       = document.form3.provincia.value;				//in number,
	var p_sigla           = document.form3.sigla.value;						//in varchar2,
	var p_tomo            = document.form3.tomo.value;						//in number,
	var p_asiento         = document.form3.asiento.value;					//in number,
	var p_estado          = '<%=mode.equals("add")?"N":""%>';
	var v_fecha_docto     = document.form3.vac_fecha_docto.value;			//in varchar2,  --:trab_vac.fecha_docto
	var v_fecha_egreso    = document.form0.fecha_egreso.value;		//in varchar2,  --:trabajo.fecha_egreso
	var v_fecha_ingreso   = document.form0.fecha_ingreso.value;		//in varchar2,  --:emp1.fecha_ingreso
	var v_fecha_final     = document.form2.fecha_final.value;			//in varchar2,  --:trab_salario.fecha_final
	var p_cargo           = document.form0.cargo.value;						//in number,    --:emp1.cargo
	var p_salario_base    = document.form0.salario_base.value;		//in number,    --:emp1.salario_base
	var p_gasto_rep       = document.form0.gasto_rep.value;				//in number,    --:emp1.gasto_rep
	var p_salario_pagar   = document.form2.salario_pagar.value;		//in number,    --:trab_salario.salario_pagar
	var p_tr_pa           = document.form2.tr_pa.value;						//in number,    --:trab_transac.tr_pa
	var p_salario_pagargr = document.form2.salario_pagargr.value;	//in number     --:trab_salario.salario_pagargr
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';

	if(p_sigla=='' || p_sigla ==' ') p_sigla = 'null';
	else p_sigla = '\''+p_sigla+'\'';
	if(p_estado =='' || p_estado ==' ') p_estado = 'null';
	else p_estado = '\''+p_estado+'\'';
	if(v_fecha_docto =='' || v_fecha_docto ==' ') v_fecha_docto = 'null';
	else v_fecha_docto = '\''+v_fecha_docto+'\'';
	if(v_fecha_egreso =='' || v_fecha_egreso ==' ') v_fecha_egreso = 'null';
	else v_fecha_egreso = '\''+v_fecha_egreso+'\'';
	if(v_fecha_ingreso =='' || v_fecha_ingreso ==' ') v_fecha_ingreso = 'null';
	else v_fecha_ingreso = '\''+v_fecha_ingreso+'\'';
	if(v_fecha_final =='' || v_fecha_final ==' ') v_fecha_final = 'null';
	else v_fecha_final = '\''+v_fecha_final+'\'';
	if(p_cargo =='' || p_cargo ==' ') p_cargo = 'null';
	if(p_salario_base =='' || p_salario_base ==' ') p_salario_base = 'null';
	if(p_gasto_rep =='' || p_gasto_rep ==' ') p_gasto_rep = 'null';
	if(p_salario_pagar =='' || p_salario_pagar ==' ') p_salario_pagar = 'null';
	if(p_tr_pa =='' || p_tr_pa ==' ') p_tr_pa = 'null';
	if(p_salario_pagargr =='' || p_salario_pagargr ==' ') p_salario_pagargr = 'null';

	if(executeDB('<%=request.getContextPath()%>','call sp_pla_liq_blq_vacaciones(' + p_compania + ', ' + p_emp_id + ', \'' + p_num_empleado + '\', ' + p_provincia + ', ' + p_sigla + ', ' + p_tomo + ', ' + p_asiento + ', ' + p_estado + ', ' + v_fecha_docto + ', ' + v_fecha_egreso + ', ' + v_fecha_ingreso + ', ' + v_fecha_final + ', ' + p_cargo + ', ' + p_salario_base + ', ' + p_gasto_rep + ', ' + p_salario_pagar + ', ' + p_tr_pa + ', ' + p_salario_pagargr +')')){
		var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
		var arr_cursor = new Array();
		if(msg!=''){
			arr_cursor = splitCols(msg);
			/*
			v_acum_salario  number(10, 2);   --:trab_vac.acum_salario
			v_acum_gasto    number(10, 2);    --:trab_vac.acum_gasto
			v_dias_vacaciones number(10, 2); --:trab_vac.dias_vacaciones
			p_vac_salario     number(10, 2); --:trab_vac.vac_salario
			p_vac_gasto       number(10, 2);  --:trab_vac.vac_gasto
			v_acump_salario   number(10, 2); --:trab_vac.acump_salario
			v_acump_gasto     number(10, 2); --:trab_vac.acump_gasto
			v_vacp_salario    number(10, 2); --:trab_vac.vacp_salario
			v_vacp_gasto      number(10, 2); --:trab_vac.vacp_gasto
			v_vacp_periodos   number(10, 2); --:trab_vac.vacp_periodos
			*/
			document.form3.acum_salario.value			= arr_cursor[0];
			document.form3.acum_gasto.value				= arr_cursor[1];
			document.form3.dias_vacaciones.value	= arr_cursor[2];
			document.form3.vac_salario.value			= arr_cursor[3];
			document.form3.vac_gasto.value				= arr_cursor[4];
			document.form3.acump_salario.value		= arr_cursor[5];
			document.form3.acump_gasto.value			= arr_cursor[6];
			document.form3.vacp_salario.value			= arr_cursor[7];
			document.form3.vacp_gasto.value				= arr_cursor[8];
			document.form3.vacp_periodos.value		= arr_cursor[9];
		}
	}
}

function tabDecimo(){
	var p_salario_base    = document.form0.salario_base.value;		//in number,    --:emp1.salario_base
	var p_gasto_rep       = document.form0.gasto_rep.value;				//in number,    --:emp1.gasto_rep
	var p_salario_pagar   = document.form2.salario_pagar.value;		//in number,    --:trab_salario.salario_pagar

	var p_tr_pa           = document.form2.tr_pa.value;						//in number,    --:trab_transac.tr_pa
	var p_tr_ds           = document.form2.tr_ds.value;						//in number,    --:trab_transac.tr_ds

	var p_salario_pagargr = document.form2.salario_pagargr.value;	//in number     --:trab_salario.salario_pagargr
	var p_tr_pa_trx_bon 	= document.form2.tr_pa_trx_bon.value;		//in number     --:trab_transac.tr_pa_trx_bon
	var p_acum_xiii_sal 	= document.form4.acum_xiii_sal_hidden.value;		//in number     --:trab_xiii.acum_xiii_sal
	var p_acum_xiii_gr 		= document.form4.acum_xiii_gr.value;		//in number     --:trab_xiii.acum_xiii_gr
	var p_vac_prop_sal 		= document.form4.vac_prop_sal.value;		//in number     --:trab_xiii.vac_prop_sal
	var p_vac_prop_gr 		= document.form4.vac_prop_gr.value;			//in number     --:trab_xiii.vac_prop_gr

	var p_vac_salario 		= document.form3.vac_salario.value;			//in number     --:trab_vac.vac_salario
	var p_vacp_salario 		= document.form3.vacp_salario.value;		//in number     --:trab_vac.vacp_salario
	var p_vac_gasto 			= document.form3.vac_gasto.value;				//in number     --:trab_vac.vac_gasto
	var p_vacp_gasto 			= document.form3.vacp_gasto.value;			//in number     --:trab_vac.vacp_gasto

	var v_salario_liq = 0.00, v_gasto_liq = 0.00, p_xiii_salario = 0.00, p_xiii_gasto = 0.00, p_xiii_salario = 0.00, p_xiii_gasto = 0.00;

	if(isNaN(p_salario_pagar) || p_salario_pagar =='') p_salario_pagar = 0.00;
	else p_salario_pagar = parseFloat(p_salario_pagar);

	if(isNaN(p_tr_pa) || p_tr_pa =='') p_tr_pa = 0.00;
	else p_tr_pa = parseFloat(p_tr_pa);

	if(isNaN(p_tr_ds) || p_tr_ds =='') p_tr_ds = 0.00;
	else p_tr_ds = parseFloat(p_tr_ds);

	if(isNaN(p_tr_pa_trx_bon) || p_tr_pa_trx_bon =='') p_tr_pa_trx_bon = 0.00;
	else p_tr_pa_trx_bon = parseFloat(p_tr_pa_trx_bon);

	if(isNaN(p_salario_pagargr) || p_salario_pagargr =='') p_salario_pagargr = 0.00;
	else p_salario_pagargr = parseFloat(p_salario_pagargr);

	if(isNaN(p_acum_xiii_sal) || p_acum_xiii_sal =='') p_acum_xiii_sal = 0.00;
	else p_acum_xiii_sal = parseFloat(p_acum_xiii_sal);

	if(isNaN(p_acum_xiii_gr) || p_acum_xiii_gr =='') p_acum_xiii_gr = 0.00;
	else p_acum_xiii_gr = parseFloat(p_acum_xiii_gr);

	if(isNaN(p_vacp_salario) || p_vacp_salario =='') p_vacp_salario = 0.00;
	else p_vacp_salario = parseFloat(p_vacp_salario);

	if(isNaN(p_vacp_gasto) || p_vacp_gasto =='') p_vacp_gasto = 0.00;
	else p_vacp_gasto = parseFloat(p_vacp_gasto);

	if(isNaN(p_vac_salario) || p_vac_salario =='') p_vac_salario = 0.00;
	else p_vac_salario = parseFloat(p_vac_salario);

	if(isNaN(p_vac_gasto) || p_vac_gasto =='') p_vac_gasto = 0.00;
	else p_vac_gasto = parseFloat(p_vac_gasto);

	v_salario_liq = p_salario_pagar + p_tr_pa - p_tr_pa_trx_bon - p_tr_ds;
	v_gasto_liq = p_salario_pagargr;

	p_acum_xiii_sal = p_acum_xiii_sal + v_salario_liq;
	p_acum_xiii_gr = p_acum_xiii_gr + v_gasto_liq;

  var acum_vac_manual = buscaAcumulado(0);
	var acum_dec_manual = buscaAcumulado(1);
	p_vac_prop_sal = p_vacp_salario;
	p_vac_prop_gr = p_vacp_gasto;
  p_acum_xiii_sal+=acum_dec_manual;
	p_xiii_salario = (p_acum_xiii_sal + p_vacp_salario + p_vac_salario) / 12;
	p_xiii_gasto 	= (p_acum_xiii_gr + p_vacp_gasto + p_vac_gasto) / 12;

	document.form4.acum_xiii_sal.value	= p_acum_xiii_sal;
	document.form4.acum_xiii_gr.value		= p_acum_xiii_gr;
	document.form4.vac_prop_sal.value		= p_vac_prop_sal;
	document.form4.vac_prop_gr.value		= p_vac_prop_gr;
	document.form4.xiii_salario.value		= p_xiii_salario;
	document.form4.xiii_gasto.value			= p_xiii_gasto;

}


function buscaAcumulado(tipo){
	var form = window.frames['itemFrameAcum'].document.form1;
	var size = form.keySize.value;
	var totalVac = 0.00, totalDec = 0.00;
	var obj;
	for(i=0;i<size;i++){
		if(tipo==0) obj = window.frames['itemFrameAcum'].document.getElementById("paga_vac"+i);
		else if(tipo==1) obj = window.frames['itemFrameAcum'].document.getElementById("paga_dec"+i);
		objSalario = window.frames['itemFrameAcum'].document.getElementById("sal_bruto"+i);
		if(obj.checked) totalVac += parseFloat(objSalario.value);
	}
	return totalVac;
}

function tabPrimaAntiguedad(){
	var p_compania        = <%=(String) session.getAttribute("_companyId")%>;//in number,
	var p_emp_id          = document.form0.emp_id.value;					//in number,
	var v_fecha_egreso    = document.form0.fecha_egreso.value;		//in varchar2,  --:trabajo.fecha_egreso
	var v_fecha_ingreso   = document.form0.fecha_ingreso.value;
//	alert(v_fecha_ingreso);//in varchar2,  --:emp1.fecha_ingreso
	var p_anios       		= document.form0.anios.value;
//	alert(p_anios);			//in number,    --:emp1.gasto_rep
	var p_meses       		= document.form0.meses.value;				//in number,    --:emp1.gasto_rep
	var p_dias       			= document.form0.dias.value;				//in number,    --:emp1.gasto_rep
	var p_total_semanas		= document.form0.total_semanas.value;				//in number,    --:emp1.gasto_rep

	var p_vac_salario 		= document.form3.vac_salario.value;			//in number     --:trab_vac.vac_salario
	var p_vacp_salario 		= document.form3.vacp_salario.value;		//in number     --:trab_vac.vacp_salario
	var p_vac_gasto 			= document.form3.vac_gasto.value;				//in number     --:trab_vac.vac_gasto
	var p_vacp_gasto 			= document.form3.vacp_gasto.value;			//in number     --:trab_vac.vacp_gasto
    var p_salario_pagar   		= document.form2.salario_pagar.value;				//in number,    --:trab_salario.salario_pagar
	var p_tr_pa           = document.form2.tr_pa.value;						//in number,    --:trab_transac.tr_pa
	var p_tr_ds           = document.form2.tr_ds.value;						//in number,    --:trab_transac.tr_ds
	var noEmpleado           = document.form0.num_empleado.value;

	if(isNaN(p_salario_pagar) || p_salario_pagar =='') p_salario_pagar = 0.00;
	else p_salario_pagar = parseFloat(p_salario_pagar);

	if(isNaN(p_vacp_salario) || p_vacp_salario =='') p_vacp_salario = 0.00;
	else p_vacp_salario = parseFloat(p_vacp_salario);

	if(isNaN(p_vacp_gasto) || p_vacp_gasto =='') p_vacp_gasto = 0.00;
	else p_vacp_gasto = parseFloat(p_vacp_gasto);

	if(isNaN(p_vac_salario) || p_vac_salario =='') p_vac_salario = 0.00;
	else p_vac_salario = parseFloat(p_vac_salario);

	if(isNaN(p_vac_gasto) || p_vac_gasto =='') p_vac_gasto = 0.00;
	else p_vac_gasto = parseFloat(p_vac_gasto);

	if(isNaN(p_tr_pa) || p_tr_pa =='') p_tr_pa = 0.00;
	else p_tr_pa = parseFloat(p_tr_pa);

	if(isNaN(p_tr_ds) || p_tr_ds =='') p_tr_ds = 0.00;
	else p_tr_ds = parseFloat(p_tr_ds);

	var v_acumulado = 0.00,	v_promedio = 0.00, v_salario_liq = 0.00, v_gasto_liq = 0.00;
	var v_valor_anios = 0.00, v_valor_meses = 0.00, v_valor_dias = 0.00, v_valor_prima = 0.00;
	if(v_fecha_egreso =='' || v_fecha_egreso ==' ') v_fecha_egreso = 'null';
	else v_fecha_egreso = '\''+v_fecha_egreso+'\'';
	if(v_fecha_ingreso =='' || v_fecha_ingreso ==' ') v_fecha_ingreso = 'null';
	else v_fecha_ingreso = '\''+v_fecha_ingreso+'\'';

	var x = getDBData('<%=request.getContextPath()%>', 'getPlaLiqPrimaAnt('+p_compania+', '+p_emp_id+', '+v_fecha_egreso+', '+v_fecha_ingreso+', '+p_anios+',\''+noEmpleado+'\')','dual','','');
	var arr_cursor = new Array();
	if(x!=''){
		arr_cursor = splitCols(x);
		var acumulado = arr_cursor[0];
		v_acumulado = parseFloat(acumulado);
		if(acumulado!=''){
			document.form5.fecha_inicio.value			= arr_cursor[1];
			v_acumulado += p_vacp_salario + p_vac_salario + p_vacp_gasto + p_vac_gasto + p_tr_pa - p_tr_ds + p_salario_pagar;
			/*if(p_anios>4){
				p_total_semanas = 260;
				p_anios = 5;
				p_meses = 0;
				p_dias = 0;
			}*/
			v_promedio = v_acumulado / p_total_semanas;
			v_valor_anios = v_promedio * p_anios;
			v_valor_meses = (v_promedio * p_meses) / 12;
			//if(p_anios>4) v_valor_meses = 0;
			v_valor_dias = ((v_promedio / 12) / 30) * p_dias;
			//if(p_anios>4) v_valor_dias = 0;
			v_valor_prima = v_valor_anios + v_valor_meses + v_valor_dias;
			document.form5.pr_valor_anios.value = v_valor_anios.toFixed(2);
			document.form5.pr_valor_meses.value = v_valor_meses.toFixed(2);
			document.form5.pr_valor_dias.value = v_valor_dias.toFixed(2);
			document.form5.pr_promedio.value = v_promedio.toFixed(2);
			document.form5.pr_acumulado.value = v_acumulado.toFixed(2);
			document.form5.anios.value = p_anios;
			document.form5.meses.value = p_meses;
			document.form5.dias.value = p_dias;
			document.form5.pr_valor_prima.value = v_valor_prima.toFixed(2);

		} else {
			document.form5.pr_valor_anios.value = 0;
			document.form5.pr_valor_meses.value = 0;
			document.form5.pr_valor_dias.value = 0;
			document.form5.pr_promedio.value = 0;
			document.form5.pr_acumulado.value = 0;
			document.form5.anios.value = 0;
			document.form5.meses.value = 0;
			document.form5.dias.value = 0;
		}
	}
	document.form5.fecha_egreso.value = v_fecha_egreso;
	document.form5.pr_semanas.value = p_total_semanas;
}

function tabIndemnizacion(){
	var p_compania        = <%=(String) session.getAttribute("_companyId")%>;//in number,
	var p_emp_id          = document.form0.emp_id.value;					//in number,
	var p_provincia       = document.form0.provincia.value;				//in number,
	var p_sigla           = document.form0.sigla.value;						//in varchar2,
	var p_tomo            = document.form0.tomo.value;						//in number,
	var p_asiento         = document.form0.asiento.value;					//in number,
	var v_fecha_egreso    = document.form0.fecha_egreso.value;		//in varchar2,  --:trabajo.fecha_egreso
	var v_fecha_ingreso   = document.form0.fecha_ingreso.value;		//in varchar2,  --:emp1.fecha_ingreso
	var p_salario_base 	  = document.form0.salario_base.value;				//in number,    --:emp1.gasto_rep
	var motivo		 	  = document.form0.motivo.value;				//in number,    --:emp1.motivo
	var p_ck_recargo50	  = document.form0.p_ck_recargo50.value;
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	var call_procedure = 0;
	var mode = '<%=mode%>';
	if(v_fecha_egreso =='' || v_fecha_egreso ==' ') v_fecha_egreso = 'null';
	else v_fecha_egreso = '\''+v_fecha_egreso+'\'';
	if(v_fecha_ingreso =='' || v_fecha_ingreso ==' ') v_fecha_ingreso = 'null';
	else v_fecha_ingreso = '\''+v_fecha_ingreso+'\'';
	if(p_salario_base =='' || p_salario_base ==' ') p_salario_base = 'null';
	if(p_sigla =='' || p_sigla ==' ') p_sigla = 'null';
	else p_sigla = '\''+p_sigla+'\'';

	if (v_fecha_egreso != 'null'){
		if (mode == 'add' || mode=='edit'){
			document.form6.anios.value = document.form0.anios.value;
			document.form6.meses.value = document.form0.meses.value;
			document.form6.dias.value = document.form0.dias.value;
			document.form6.in_ck_recargo50.value = p_ck_recargo50;
			var x = getDBData('<%=request.getContextPath()%>', '1','tbl_pla_li_dist_indem','cod_compania = '+p_compania+' and emp_id = '+p_emp_id+' and trunc(fecha_inicio) = to_date('+v_fecha_egreso+',\'dd/mm/yyyy\')' ,'');

			if (x == '1'){
				if(confirm('Ya existe una Indemnización calculada, desea trabajar con esta?')){
					 /*
					 go_block ('TRAB_INDEM');
					 go_block ('LDI');
					 execute_query;
					 */
					 call_procedure = 0;
				} else call_procedure = 1;	//pu_indemnizacion;
			} else call_procedure = 1;	//pu_indemnizacion;
		} else {
			/*
			go_block ('TRAB_INDEM');
			go_block ('LDI');
			execute_query;
			*/
			call_procedure = 0;
		}
	} else {
		alert('Introduzca la fecha de la terminación del contrato');
		call_procedure = 2;
	}

	if(call_procedure == 0){

	} else if(call_procedure == 1 && executeDB('<%=request.getContextPath()%>','call sp_pla_liq_indemnizacion(' + p_compania + ', ' + p_emp_id + ', ' + p_provincia + ', ' + p_sigla + ', ' + p_tomo + ', ' + p_asiento + ', ' + v_fecha_ingreso + ', ' + v_fecha_egreso + ', ' + p_salario_base + ')')){
		var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
		var arr_cursor = new Array();
		if(msg!=''){
			arr_cursor = splitCols(msg);
			/*
			:trab_indem.in_promedio_men := v_promedio_men;
			:trab_indem.in_promedio_sem := v_promedio_sem;
			:trab_indem.in_salario_ult6mes := v_prsal_ult6mes;
			:trab_indem.in_ultimo_salario := v_salario_ultmes;
			:trab_indem.in_indemnizacion := 0;
			*/
			document.form6.in_promedio_men.value			= arr_cursor[0];
			document.form6.in_promedio_sem.value			= arr_cursor[1];
			document.form6.in_salario_ult6mes.value			= arr_cursor[2];
			document.form6.in_ultimo_salario.value			= arr_cursor[3];
			document.form6.in_indemnizacion.value			= arr_cursor[4];
			var obj = document.form6.ind_recargo50;
			if(obj.checked){
		document.form6.ind_recargo50.value = ((in_monto_indemnizacion * 50) / 100).toFixed(2);
	} else document.form6.ind_recargo50.value = 0;

		}
	}
	window.frames['itemFrameInd'].location='../rhplanilla/reg_liquidacion_det_indem.jsp?emp_id='+p_emp_id;
}

function chkRecargo25(obj){
	var in_promedio_men = document.form6.in_promedio_men.value;
	var in_ultimo_salario = document.form6.in_ultimo_salario.value;
	var in_promedio_men = document.form6.in_promedio_men.value;
	var in_monto_indemnizacion	= document.form6.in_indemnizacion.value;
	if(!isNaN(in_promedio_men) && in_promedio_men != '') in_promedio_men = parseFloat(in_promedio_men);
	else in_promedio_men = 0;
	if(!isNaN(in_ultimo_salario) && in_ultimo_salario != '') in_ultimo_salario = parseFloat(in_ultimo_salario);
	else in_ultimo_salario = 0;
	if(obj.checked){
		if(document.form6.ind_recargo25){document.form6.ind_recargo25.value = parseFloat((in_monto_indemnizacion * 25) / 100);}
	} else {if(document.form6.ind_recargo25)document.form6.ind_recargo25.value = 0;}
}


function chkRecargo50(obj){
	var in_promedio_men = document.form6.in_promedio_men.value;
	var in_ultimo_salario = document.form6.in_ultimo_salario.value;
	var in_promedio_men = document.form6.in_promedio_men.value;
	var in_monto_indemnizacion	= document.form6.in_indemnizacion.value;
	if(!isNaN(in_promedio_men) && in_promedio_men != '') in_promedio_men = parseFloat(in_promedio_men);
	else in_promedio_men = 0;
	if(!isNaN(in_ultimo_salario) && in_ultimo_salario != '') in_ultimo_salario = parseFloat(in_ultimo_salario);
	else in_ultimo_salario = 0;
	if(obj.checked){
		document.form6.ind_recargo50.value = parseFloat((in_monto_indemnizacion * 50) / 100);
	} else document.form6.ind_recargo50.value = 0;
}


function chkPreaviso(obj){
	var in_promedio_men = document.form6.in_promedio_men.value;
	var in_ultimo_salario = document.form6.in_ultimo_salario.value;
	var in_promedio_men = document.form6.in_promedio_men.value;
	if(!isNaN(in_promedio_men) && in_promedio_men != '') in_promedio_men = parseFloat(in_promedio_men);
	else in_promedio_men = 0;
	if(!isNaN(in_ultimo_salario) && in_ultimo_salario != '') in_ultimo_salario = parseFloat(in_ultimo_salario);
	else in_ultimo_salario = 0;
	if(obj.checked){
		if(in_promedio_men > in_ultimo_salario) document.form6.in_preaviso.value = in_promedio_men;
		else document.form6.in_preaviso.value = in_ultimo_salario;
	} else document.form6.in_preaviso.value = 0;
}

function tabImpuestos(){
	var p_compania        		= <%=(String) session.getAttribute("_companyId")%>;//in number,
	var p_emp_id          		= document.form0.emp_id.value;							//in number,
	var p_tr_ds           		= document.form2.tr_ds.value;								//in number,    --:trab_transac.tr_ds
	var p_pr_valor_prima			= document.form5.pr_valor_prima.value;			//in number,    --:trab_prima.pr_valor_prima
	var p_pr_preaviso					= document.form5.pr_preaviso.value;					//in number,    --:trab_prima.pr_preaviso
	var p_salario_pagar   		= document.form2.salario_pagar.value;				//in number,    --:trab_salario.salario_pagar
	var p_salario_pagargr 		= document.form2.salario_pagargr.value;			//in number     --:trab_salario.salario_pagargr
	var p_tr_pa           		= document.form2.tr_pa.value;								//in number,    --:trab_transac.tr_pa
	var p_tr_pa_st        		= document.form2.tr_pa_st.value;						//in number,    --:trab_transac.tr_pa_st

	var p_vac_salario       	= document.form3.vac_salario.value;					//in number,    --:trab_vac.vac_salario
	var p_vac_gasto       		= document.form3.vac_gasto.value;						//in number,    --:trab_vac.vac_gasto
	var p_vacp_salario       	= document.form3.vacp_salario.value;				//in number,    --:trab_vac.vacp_salario
	var p_vacp_gasto       		= document.form3.vacp_gasto.value;					//in number,    --:trab_vac.vacp_gasto
	var p_xiii_salario       	= document.form4.xiii_salario.value;				//in number,    --:trab_xiii.xiii_salario
	var p_xiii_gasto       		= document.form4.xiii_gasto.value;					//in number,    --:trab_xiii.xiii_gasto
	var p_in_recargo25			= 0;
	var p_in_recargo50 =0;
	<%
	if(cdoM.getColValue("pagar_indemn").equals("S")){
	%>
	var p_in_indemnizacion		= document.form6.in_indemnizacion.value;		//in number,    --:trab_indem.in_indemnizacion
	if(document.form6.ind_recargo25)p_in_recargo25=document.form6.ind_recargo25.value;		//in number,    --:trab_indem.in_recargo25
	if(document.form6.ind_recargo50)p_in_recargo50			= document.form6.ind_recargo50.value;		//in number,    --:trab_indem.in_recargo50
	var p_in_preaviso       	= document.form6.in_preaviso.value;					//in number,    --:trab_indem.in_preaviso
	<%} else {%>
	var p_in_indemnizacion		= 0;
	var p_in_preaviso       	= 0;
	var p_ind_recargo25			= 0;
	var p_ind_recargo50       	= 0;
	<%}%>
	var p_pr_otros_beneficios	= document.form5.pr_otros_beneficios.value;	//in number,    --:trab_prima.pr_otros_beneficios
	var v_fecha_egreso				= document.form0.fecha_egreso.value;				//in number,    --:trabajo.fecha_egreso
	var p_estado       				= '<%=mode.equals("add")?"N":""%>'					//in number,    --:trabajo.estado
	var p_anios       				= document.form0.anios.value;								//in number,    --:trabajo.anios
	var p_tipo_renta       		= document.form0.tipo_renta.value;					//in number,    --:emp1.tipo_renta
	var p_num_dependiente     = document.form0.num_dependiente.value;			//in number,    --:emp1.num_dependiente
	var p_tr_pa_trx_bon       = document.form2.tr_pa_trx_bon.value;				//in number,    --:trab_transac.tr_pa_trx_bon

	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';

/*
p_compania              in number,
p_emp_id                in number,
p_tr_ds                 in number,    --:trab_transac.tr_ds
p_pr_valor_prima        in number,    --:trab_prima.pr_valor_prima
p_pr_preaviso           in number,    --:trab_prima.pr_preaviso
p_salario_pagar         in number,    --:trab_salario.salario_pagar
p_salario_pagargr       in number,    --:TRAB_SALARIO.SALARIO_PAGARGR
p_tr_pa                 in number,    --:trab_transac.tr_pa
p_tr_pa_st              in number,    --:trab_transac.tr_pa_st
p_vac_salario           in number,    --:trab_vac.vac_salario
p_vac_gasto             in number,    --:trab_vac.vac_gasto
p_vacp_salario          in number,    --:trab_vac.vacp_salario
p_vacp_gasto            in number,    --:trab_vac.vacp_gasto
p_xiii_salario          in number,    --:trab_xiii.xiii_salario
p_xiii_gasto            in number,    --:trab_xiii.xiii_gasto
p_in_indemnizacion      in number,    --:trab_indem.in_indemnizacion
p_in_preaviso           in number,    --:trab_indem.in_preaviso
p_pr_otros_beneficios   in number,    --:trab_prima.pr_otros_beneficios
p_estado                in number,    --:trabajo.estado
v_fecha_egreso          in varchar2,  --:trabajo.fecha_egreso
p_anios                 in number,    --:trabajo.anios
p_tipo_renta            in varchar2,  --:emp1.tipo_renta
p_num_dependiente       in number,    --:emp1.num_dependiente
p_tr_pa_trx_bon         in number     --:trab_transac.tr_pa_trx_bon

*/

	if(p_tr_ds=='' || p_tr_ds ==' ') p_tr_ds = 'null';
	else p_tr_ds = parseFloat(p_tr_ds);

	if(p_pr_valor_prima=='' || p_pr_valor_prima ==' ') p_pr_valor_prima = 'null';
	else p_pr_valor_prima = parseFloat(p_pr_valor_prima);

	if(p_pr_preaviso=='' || p_pr_preaviso ==' ') p_pr_preaviso = 'null';
	else p_pr_preaviso = parseFloat(p_pr_preaviso);

	if(p_salario_pagar=='' || p_salario_pagar ==' ') p_salario_pagar = 'null';
	else p_salario_pagar = parseFloat(p_salario_pagar);

	if(p_salario_pagargr=='' || p_salario_pagargr ==' ') p_salario_pagargr = 'null';
	else p_salario_pagargr = parseFloat(p_salario_pagargr);

	if(p_tr_pa=='' || p_tr_pa ==' ') p_tr_pa = 'null';
	else p_tr_pa = parseFloat(p_tr_pa);

	if(p_tr_pa_st=='' || p_tr_pa_st ==' ') p_tr_pa_st = 'null';
	else p_tr_pa_st = parseFloat(p_tr_pa_st);

	if(p_vac_salario=='' || p_vac_salario ==' ') p_vac_salario = 'null';
	else p_vac_salario = parseFloat(p_vac_salario);

	if(p_vac_gasto=='' || p_vac_gasto ==' ') p_vac_gasto = 'null';
	else p_vac_gasto = parseFloat(p_vac_gasto);

	if(p_vacp_salario=='' || p_vacp_salario ==' ') p_vacp_salario = 'null';
	else p_vacp_salario = parseFloat(p_vacp_salario);

	if(p_vacp_gasto=='' || p_vacp_gasto ==' ') p_vacp_gasto = 'null';
	else p_vacp_gasto = parseFloat(p_vacp_gasto);

	if(p_xiii_salario=='' || p_xiii_salario ==' ') p_xiii_salario = 'null';
	else p_xiii_salario = parseFloat(p_xiii_salario);

	if(p_xiii_gasto=='' || p_xiii_gasto ==' ') p_xiii_gasto = 'null';
	else p_xiii_gasto = parseFloat(p_xiii_gasto);

	if(p_in_indemnizacion=='' || p_in_indemnizacion ==' ') p_in_indemnizacion = 'null';
	else p_in_indemnizacion = parseFloat(p_in_indemnizacion);

	if(p_in_recargo25=='' || p_in_recargo25 ==' ') p_in_recargo25 = 'null';
	else p_in_recargo25 = parseFloat(p_in_recargo25);

	if(p_in_recargo50=='' || p_in_recargo50 ==' ') p_in_recargo50 = 'null';
	else p_in_recargo50 = parseFloat(p_in_recargo50);


	if(p_in_preaviso=='' || p_in_preaviso ==' ') p_in_preaviso = 'null';
	else p_in_preaviso = parseFloat(p_in_preaviso);

	if(p_pr_otros_beneficios=='' || p_pr_otros_beneficios ==' ') p_pr_otros_beneficios = 'null';
	else p_pr_otros_beneficios = parseFloat(p_pr_otros_beneficios);

	if(p_estado =='' || p_estado ==' ') p_estado = 'null';
	else p_estado = '\''+p_estado+'\'';

	if(v_fecha_egreso =='' || v_fecha_egreso ==' ') v_fecha_egreso = 'null';
	else v_fecha_egreso = '\''+v_fecha_egreso+'\'';

	if(p_anios=='' || p_anios ==' ') p_anios = 'null';

	if(p_tipo_renta=='' || p_tipo_renta ==' ') p_tipo_renta = 'null';
	else p_tipo_renta = '\''+p_tipo_renta+'\'';

	if(p_num_dependiente=='' || p_num_dependiente ==' ') p_num_dependiente = 'null';
	else p_num_dependiente = parseFloat(p_num_dependiente);

	if(p_tr_pa_trx_bon=='' || p_tr_pa_trx_bon ==' ') p_tr_pa_trx_bon = 'null';
	else p_tr_pa_trx_bon = parseFloat(p_tr_pa_trx_bon);


	var x = getDBData('<%=request.getContextPath()%>', 'getPlaLiqImpuestos(<%=(String) session.getAttribute("_companyId")%>, '+p_emp_id+', '+ p_tr_ds +', '+ p_pr_valor_prima +', '+ p_pr_preaviso +', '+ p_salario_pagar +', '+ p_salario_pagargr +', '+p_tr_pa+', '+p_tr_pa_st+', '+p_vac_salario+', '+p_vac_gasto+', '+p_vacp_salario+', '+p_vacp_gasto+', '+p_xiii_salario+', '+p_xiii_gasto+', '+p_in_indemnizacion+', '+p_in_preaviso+', '+p_pr_otros_beneficios+', '+p_estado+', '+v_fecha_egreso+', '+p_anios+', '+p_tipo_renta+', '+p_num_dependiente+', '+p_tr_pa_trx_bon+')','dual','','');
	var arr_cursor = new Array();
	if(x!=''){
		arr_cursor = splitCols(x);
		document.form7.imp_tardanzas.value					= arr_cursor[0];
		document.form7.imp_total_liquidacion.value			= arr_cursor[1];
		document.form7.imp_total_liqss.value				= arr_cursor[2];
		document.form7.imp_ssocial.value						= arr_cursor[3];
		document.form7.imp_total_liqse.value				= arr_cursor[4];
		document.form7.imp_seducat.value						= arr_cursor[5];
		document.form7.imp_total_liqrentae.value		= arr_cursor[6];
		document.form7.imp_rentae.value							= arr_cursor[7];
		document.form7.imp_periodos.value						= arr_cursor[8];
		document.form7.imp_total_liqrenta.value			= arr_cursor[9];
		document.form7.imp_renta.value							= arr_cursor[10];
		document.form7.imp_clinica.value						= arr_cursor[11];
		document.form7.imp_cxcemp.value							= arr_cursor[12];
	}
}

function addTransaccions(){
	var emp_id = document.form2.emp_id.value;
	abrir_ventana1('../rhplanilla/reg_transac_config.jsp?empId='+emp_id+'&fp=liquidacion');
}

function addSobretiempo(){
	var emp_id = document.form2.emp_id.value;
	var anio_pago = document.form0.anio_pago.value;
	var quincena_pago = document.form0.periodo_pago.value;
	abrir_ventana1('../rhplanilla/reg_sobretiempo_config.jsp?emp_id='+emp_id+'&fp=liquidacion&anio_pago='+anio_pago+'&quincena_pago='+quincena_pago);
}

function addAusencia(){
	var emp_id = document.form2.emp_id.value;
	var anio_pago = document.form0.anio_pago.value;
	var quincena_pago = document.form0.periodo_pago.value;
	abrir_ventana1('../rhplanilla/reg_asistencia.jsp?emp_id='+emp_id+'&fp=liquidacion&anio_pago='+anio_pago+'&quincena_pago='+quincena_pago);
}

function doSubmit(){
/*
:emp1 				= form0
:trabajo 			= form0

:trab_salario = form2
:trab_vac 		= form3
:trab_xiii		= form4
:trab_prima		= form5
:trab_indem		= form6
*/
	if(document.form0.motivo.value ==''){alert('Seleccione motivo de la liquidacion!');}
	else{

	document.form0.baction.value='Guardar';
	document.form0.sp_fecha_inicio.value 				= document.form2.fecha_inicio.value;
	document.form0.sp_fecha_final.value 					= document.form2.fecha_final.value;
	document.form0.dias_laborados.value 			= document.form2.dias_laborados.value;
	document.form0.horas_regulares.value 			= document.form2.horas_regulares.value;
	document.form0.dias_vacaciones.value 			= document.form3.dias_vacaciones.value;
	document.form0.vac_salario.value 					= document.form3.vac_salario.value;
	document.form0.vac_gasto.value 						= document.form3.vac_gasto.value;
	document.form0.vacp_periodos.value 				= document.form3.vacp_periodos.value;
	document.form0.vacp_salario.value 				= document.form3.vacp_salario.value;
	document.form0.vacp_gasto.value 					= document.form3.vacp_gasto.value;
	document.form0.xiii_salario.value 				= document.form4.xiii_salario.value;
	document.form0.xiii_gasto.value 					= document.form4.xiii_gasto.value;

	if(document.form0.motivo.value !='7'){
	document.form0.pr_acumulado.value 				= document.form5.pr_acumulado.value;
	document.form0.pr_promedio.value 					= document.form5.pr_promedio.value;
	//document.form0.anios.value 								= document.form5.anios.value;
	document.form0.pr_valor_anios.value 			= document.form5.pr_valor_anios.value;
	//document.form0.meses.value 								= document.form5.meses.value;
	document.form0.pr_valor_meses.value 			= document.form5.pr_valor_meses.value;
	//document.form0.dias.value 								= document.form5.dias.value;
	document.form0.pr_valor_dias.value 				= document.form5.pr_valor_dias.value;
	}

	if(document.form0.motivo.value !='1' && document.form0.motivo.value !='5' && document.form0.motivo.value !='7' && document.form0.motivo.value !='8'){
	if(document.form6.in_salario_ult6mes) document.form0.in_salario_ult6mes.value 	= document.form6.in_salario_ult6mes.value;
	if(document.form6.in_ultimo_salario) document.form0.in_ultimo_salario.value 		= document.form6.in_ultimo_salario.value;
	if(document.form6.in_promedio_sem) document.form0.in_promedio_sem.value 			= document.form6.in_promedio_sem.value;
	if(document.form6.in_promedio_men) document.form0.in_promedio_men.value 			= document.form6.in_promedio_men.value;
	if(document.form6.in_indemnizacion) document.form0.in_indemnizacion.value 		= document.form6.in_indemnizacion.value;
	if(document.form6.in_ck_preaviso && document.form6.in_ck_preaviso.checked) document.form0.in_ck_preaviso.value 			= 'S';
	else document.form0.in_ck_preaviso.value 			= 'N';
	if(document.form6.in_preaviso) document.form0.in_preaviso.value = document.form6.in_preaviso.value;
	}else{
	document.form0.in_salario_ult6mes.value 	= 0;
	document.form0.in_ultimo_salario.value 		= 0;
	document.form0.in_promedio_sem.value 			=0;
	document.form0.in_promedio_men.value 			= 0;
	document.form0.in_indemnizacion.value 		= 0;
	document.form0.in_ck_preaviso.value 			= 'N';
	document.form0.in_preaviso.value 					= 0;
	}
	if(document.form0.motivo.value !='7'){

	if(document.form5.pr_otros_beneficios) document.form0.pr_otros_beneficios.value	= document.form5.pr_otros_beneficios.value;
	if(document.form5.pr_semanas) document.form0.pr_semanas.value 					= document.form5.pr_semanas.value;
	if(document.form5.pr_ck_preaviso && document.form5.pr_ck_preaviso.checked) document.form0.pr_ck_preaviso.value 			= 'S';
	else document.form0.pr_ck_preaviso.value 			= 'N';

	if(document.form5.pr_preaviso) document.form0.pr_preaviso.value 					= document.form5.pr_preaviso.value;
	if(document.form7.imp_clinica) document.form0.imp_clinica.value 					= document.form7.imp_clinica.value;
	if(document.form4.acum_xiii_sal) document.form0.acum_xiii_sal.value 				= document.form4.acum_xiii_sal.value;
	if(document.form4.acum_xiii_gr) document.form0.acum_xiii_gr.value 				= document.form4.acum_xiii_gr.value;
	}


	if(document.form7.imp_ssocial) document.form0.imp_ssocial.value 					= document.form7.imp_ssocial.value;
	if(document.form7.imp_seducat) document.form0.imp_seducat.value 					= document.form7.imp_seducat.value;
	if(document.form7.imp_renta) document.form0.imp_renta.value 						= document.form7.imp_renta.value;
	if(document.form7.imp_rentae) document.form0.imp_rentae.value 					= document.form7.imp_rentae.value;
	if(document.form7.imp_cxcemp) document.form0.imp_cxcemp.value 					= document.form7.imp_cxcemp.value;
	var msg ='';
	if (!form0Validation()){return false;}
  	else {if(document.form0.anio_pago.value =='')msg +=',año';if(document.form0.fecha_docto.value =='')msg +=',Fecha de Doc.';if(msg !=''){alert('Seleccione '+msg.substring(1));form0BlockButtons(false);return false;}else document.form0.submit();}
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CREAR LIQUIDACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
			<div id="dhtmlgoodies_tabView1">
        <!--GENERALES TAB0-->
				<!-- E M P L E A D O -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%fb.appendJsValidation("if(document.form0.baction.value!='Guardar')return true;");%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("emp_id",emp_id)%>
			<%=fb.hidden("indTab","0")%>
			<%=fb.hidden("baction","")%>
      <%=fb.hidden("anios_semana", "")%>
      <%=fb.hidden("meses_semana", "")%>
      <%=fb.hidden("dias_semana", "")%>
      <%=fb.hidden("total_semanas", "")%>
      <%=fb.hidden("sp_fecha_inicio", "")%>
      <%=fb.hidden("sp_fecha_final", "")%>
      <%=fb.hidden("dias_laborados", "")%>
      <%=fb.hidden("horas_regulares", "")%>
      <%=fb.hidden("dias_vacaciones", "")%>
      <%=fb.hidden("vac_salario", "")%>
      <%=fb.hidden("vac_gasto", "")%>
      <%=fb.hidden("vacp_periodos", "")%>
      <%=fb.hidden("vacp_salario", "")%>
      <%=fb.hidden("vacp_gasto", "")%>
      <%=fb.hidden("xiii_salario", "")%>
      <%=fb.hidden("xiii_gasto", "")%>
      <%=fb.hidden("pr_acumulado", "")%>
      <%=fb.hidden("pr_promedio", "")%>
      <%//=fb.hidden("anios","")%>
      <%=fb.hidden("pr_valor_anios", "")%>
      <%//=fb.hidden("meses","")%>
      <%=fb.hidden("pr_valor_meses", "")%>
      <%//=fb.hidden("dias","")%>
      <%=fb.hidden("pr_valor_dias", "")%>
      <%=fb.hidden("in_salario_ult6mes", "")%>
      <%=fb.hidden("in_ultimo_salario", "")%>
      <%=fb.hidden("in_promedio_sem", "")%>
      <%=fb.hidden("in_promedio_men", "")%>
      <%=fb.hidden("in_indemnizacion", "")%>
      <%=fb.hidden("in_ck_preaviso", "")%>
      <%=fb.hidden("in_preaviso", "")%>
      <%=fb.hidden("pr_otros_beneficios", "")%>
      <%=fb.hidden("imp_ssocial", "")%>
      <%=fb.hidden("imp_seducat", "")%>
      <%=fb.hidden("imp_renta", "")%>
      <%=fb.hidden("imp_rentae", "")%>
      <%=fb.hidden("imp_cxcemp", "")%>
      <%=fb.hidden("pr_semanas", "")%>
      <%=fb.hidden("pr_ck_preaviso", "")%>
      <%=fb.hidden("pr_preaviso", "")%>
      <%=fb.hidden("imp_clinica", "")%>
      <%=fb.hidden("acum_xiii_sal", "")%>
      <%=fb.hidden("acum_xiii_gr", "")%>
	  <%=fb.hidden("in_ck_recargo_25", "")%>
      <%=fb.hidden("in_ck_recargo_50", "")%>
	  <%=fb.hidden("ind_recargo_25", "")%>
      <%=fb.hidden("ind_recargo_50", "")%>
	  <%=fb.hidden("p_ck_recargo50","")%>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="8"><cellbytelabel>Generales del Empleado</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,2,"text10","","")%>-
        <%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3,"text10","","")%>-
        <%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,true,5,"text10","","")%>-
        <%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,true,5,"text10","","")%>
        <%=fb.button("buscarEmp","...",false,false,"text10","","onClick=\"javascript:selEmpleado()\"")%>
				</td>
				<td width="" align="right"><cellbytelabel>Num. Empleado</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_empleado",cdo.getColValue("num_empleado"),false,false,true,10,"text10","","")%></td>
				<td width="" align="right"><cellbytelabel>Seg. Social</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_ssocial",cdo.getColValue("num_ssocial"),false,false,true,10,"text10","","")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Primer/Segundo Nombre</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("primer_nombre",cdo.getColValue("primer_nombre"),false,false,true,30,"text10","","")%>
				<%=fb.textBox("segundo_nombre",cdo.getColValue("segundo_nombre"),false,false,true,30,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Primer/Segundo Apellido</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("primer_apellido",cdo.getColValue("primer_apellido"),false,false,true,30,"text10","","")%>
        <%=fb.textBox("segundo_apellido",cdo.getColValue("segundo_apellido"),false,false,true,30,"text10","","")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Unid. Administrativa</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("unidad_organi",cdo.getColValue("unidad_organi"),false,false,true,10,"text10","","")%>
				<%=fb.textBox("unidad_organi_desc",cdo.getColValue("unidad_organi_desc"),false,false,true,50,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Cargo o Posici&oacute;n</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("cargo",cdo.getColValue("cargo"),false,false,true,10,"text10","","")%>
        <%=fb.textBox("cargo_desc",cdo.getColValue("cargo_desc"),false,false,true,50,"text10","","")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Clave</cellbytelabel></td>
				<td width="">
        <%=fb.textBox("tipo_renta",cdo.getColValue("tipo_renta"),false,false,true,5,"text10","","")%>
        <%=fb.textBox("num_dependiente",cdo.getColValue("num_dependiente"),false,false,true,5,"text10","","")%>
				</td>
				<td width="" align="right"><cellbytelabel>Salario</cellbytelabel></td>
				<td width=""><%=fb.textBox("salario_base",cdo.getColValue("salario_base"),false,false,true,10,"text10","","")%></td>
				<td width="" align="right"><cellbytelabel>Gasto Rep</cellbytelabel>.&nbsp;</td>
				<td width=""><%=fb.textBox("gasto_rep",cdo.getColValue("gasto_rep"),false,false,true,10,"text10","","")%></td>
				<td width="" align="right"><cellbytelabel>Rata x Hora</cellbytelabel>&nbsp;</td>
        <td width=""><%=fb.textBox("rata_hora",cdo.getColValue("rata_hora"),false,false,true,10,"text10","","")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Fecha Ingreso</cellbytelabel></td>
				<td width="">
        <%=fb.textBox("fecha_ingreso",cdo.getColValue("fecha_ingreso"),false,false,true,10,"text10","","")%>
				</td>
				<td width="" align="right"><cellbytelabel>Fecha Egreso</cellbytelabel></td>
				<td width="">
        <jsp:include page="../common/calendar.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="nameOfTBox1" value="fecha_egreso"/>
        <jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fecha_egreso")==null)?"":cdo.getColValue("fecha_egreso")%>" />
        <jsp:param name="fieldClass" value="text10"/>
        <jsp:param name="buttonClass" value="text10"/>
        <jsp:param name="jsEvent" value="changeFechaEgreso();"/>
        </jsp:include>
				</td>
				<td width="" align="right"><cellbytelabel>Fecha Docto</cellbytelabel>.</td>
        <td width="">
        <jsp:include page="../common/calendar.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="nameOfTBox1" value="fecha_docto"/>
        <jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fecha_docto")==null)?"":cdo.getColValue("fecha_docto")%>" />
        <jsp:param name="fieldClass" value="text10"/>
        <jsp:param name="buttonClass" value="text10"/>
        </jsp:include>
        </td>
				<td width="" align="right">Motivo Egreso</td>
        <td width="">
				<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_pla_li_motivo where compania = "+(String) session.getAttribute("_companyId"), "motivo", (request.getParameter("motivo")!= null && !request.getParameter("motivo").equals(""))? request.getParameter("motivo"):cdo.getColValue("motivo"), false, false, 0, "text10", "", "onChange=\"javascript:changeMotivo(this.value)\"", "", "S")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right">         ** <cellbytelabel>Periodo</cellbytelabel>   				:       ** <cellbytelabel>A&ntilde;o de Pago</cellbytelabel>:</td>
				<td width="">
        <%=fb.textBox("periodo_pago",cdo.getColValue("periodo_pago"),true,false,false,5,2,"text10","","onChange=\"javascript:getPlaLiqDLTotales()\"")%>
        <%=fb.textBox("anio_pago",cdo.getColValue("anio_pago"),true,false,false,5,4,"text10","","onChange=\"javascript:getPlaLiqDLTotales()\"")%>
				</td>
				<td width="" align="right"><cellbytelabel>Cargar Liquidaci&oacute;n</cellbytelabel>
				</td>
				<td width="" align="right">
				<%=fb.select(ConMgr.getConnection(), "select to_char(fecha_egreso, 'dd/mm/yyyy'), to_char(fecha_egreso, 'dd/mm/yyyy') from tbl_pla_li_liquidacion where compania = "+(String) session.getAttribute("_companyId") + " and emp_id = " + emp_id, "liq_fecha_egreso", (request.getParameter("liq_fecha_egreso")!= null && !request.getParameter("liq_fecha_egreso").equals(""))? request.getParameter("liq_fecha_egreso"):"", false, false, 0, "text10", "", "onChange=\"javascript:setLiquidacion(this.value)\"", "", "S")%>
        </td>
				<td width="" colspan="4" rowspan="4"><cellbytelabel>Observaciones</cellbytelabel>:<br><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,77,3)%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>No. Cheque</cellbytelabel></td>
				<td width="" colspan="2">
        <%=fb.textBox("num_cheque",cdo.getColValue("num_cheque"),false,false,false,5,"text10","","")%>
				</td>
				<td width="" align="right">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Tiempo Servicio</cellbytelabel></td>
				<td width="" align="center"><cellbytelabel>A&ntilde;os</cellbytelabel></td>
				<td width="" align="center" ><cellbytelabel>Meses</cellbytelabel></td>
				<td width="" align="center" ><cellbytelabel>D&iacute;as</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Cantidad</cellbytelabel></td>
				<td width="" align="center" ><%=fb.textBox("anios",cdo.getColValue("anios"),true,false,true,5,"text10","","")%></td>
				<td width="" align="center" ><%=fb.textBox("meses",cdo.getColValue("meses"),true,false,true,5,"text10","","")%></td>
				<td width="" align="center" ><%=fb.textBox("dias",cdo.getColValue("dias"),true,false,true,5,"text10","","")%></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="8" align="right">
				<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
        </td>
			</tr>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>

			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<!-- A C U M U L A D O S -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%fb.appendJsValidation("if(document.form1.baction.value!='Guardar')return true;");%>
			<%=fb.hidden("emp_id",emp_id)%>
			<%=fb.hidden("indTab","1")%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
      <%=fb.hidden("fecha_egreso",cdo.getColValue("fecha_egreso"))%>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="8"><cellbytelabel>Generales del Empleado</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,2,"text10","","")%>-
        <%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3,"text10","","")%>-
        <%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,true,5,"text10","","")%>-
        <%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,true,5,"text10","","")%>
				</td>
				<td width="" align="right"><cellbytelabel>Num. Empleado</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_empleado",cdo.getColValue("num_empleado"),false,false,true,10,"text10","","")%></td>
				<td width="" align="right"><cellbytelabel>Seg. Social</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_ssocial",cdo.getColValue("num_ssocial"),false,false,true,10,"text10","","")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Primer/Segundo Nombre</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("primer_nombre",cdo.getColValue("primer_nombre"),false,false,true,30,"text10","","")%>
				<%=fb.textBox("segundo_nombre",cdo.getColValue("segundo_nombre"),false,false,true,30,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Primer/Segundo Apellido</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("primer_apellido",cdo.getColValue("primer_apellido"),false,false,true,30,"text10","","")%>
        <%=fb.textBox("segundo_apellido",cdo.getColValue("segundo_apellido"),false,false,true,30,"text10","","")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Unid. Administrativa</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("unidad_organi",cdo.getColValue("unidad_organi"),false,false,true,10,"text10","","")%>
				<%=fb.textBox("unidad_organi_desc",cdo.getColValue("unidad_organi_desc"),false,false,true,50,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Cargo o Posici&oacute;n</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("cargo",cdo.getColValue("cargo"),false,false,true,10,"text10","","")%>
        <%=fb.textBox("cargo_desc",cdo.getColValue("cargo_desc"),false,false,true,50,"text10","","")%>
        </td>
			</tr>
      <tr>
        <td colspan="8" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
          <table width="100%" cellpadding="1" cellspacing="0">
          <tr class="TextPanel">
            <td width="95%">&nbsp;<cellbytelabel>Detalle de Acumulado</cellbytelabel></td>
            <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
          </tr>
          </table>
        </td>
      </tr>
      <tr id="panel1">
        <td colspan="8">
          <iframe name="itemFrameAcum" id="itemFrameAcum" frameborder="0" align="center" width="100%" height="100px" scrolling="yes" src="../rhplanilla/reg_liquidacion_det_acum.jsp?fp=<%=fp%>&emp_id=<%=emp_id%>&fecha_egreso=<%=cdo.getColValue("fecha_egreso")%>&num_empleado=<%=cdo.getColValue("num_empleado")%>"></iframe>
        </td>
      </tr>
			<tr class="TextRow02">
				<td colspan="8" align="right">
				<%=fb.button("save","Guardar",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
        </td>
			</tr>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<!-- S A L A R I O   P O R   P A G A R -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document.form2.baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
			<%=fb.hidden("emp_id",emp_id)%>
			<%=fb.hidden("indTab","2")%>
			<%=fb.hidden("baction","")%>
      <%=fb.hidden("fecha_egreso",cdo.getColValue("fecha_egreso"))%>
	  <%=fb.hidden("motivo",cdo.getColValue("motivo"))%>
	   <%=fb.hidden("fecha_docto",cdo.getColValue("fecha_docto"))%>
      <%=fb.hidden("horas_sabados",cdo.getColValue("horas_sabados"))%>
      <%=fb.hidden("tr_pa_trx_bon",cdo.getColValue("tr_pa_trx_bon"))%>
      <%=fb.hidden("tr_ausencia",cdo.getColValue("tr_ausencia"))%>
      <%=fb.hidden("tr_tardanza",cdo.getColValue("tr_tardanza"))%>

	  <%=fb.hidden("imp_renta_xiii",cdo.getColValue("imp_renta_xiii"))%>
      <%=fb.hidden("imp_renta_trx",cdo.getColValue("imp_renta_trx"))%>

	  <%=fb.hidden("periodo_pago",cdo.getColValue("periodo_pago"))%>
	  <%=fb.hidden("anio_pago",cdo.getColValue("anio_pago"))%>
	  <%=fb.hidden("anios",cdo.getColValue("ts_anios"))%>
	  <%=fb.hidden("meses",cdo.getColValue("ts_meses"))%>

	  <%=fb.hidden("dias",cdo.getColValue("ts_dias"))%>

	  			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="8"><cellbytelabel>Generales del Empleado</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,2,"text10","","")%>-
        <%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3,"text10","","")%>-
        <%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,true,5,"text10","","")%>-
        <%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,true,5,"text10","","")%>
				</td>
				<td width="" align="right"><cellbytelabel>Num. Empleado</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_empleado",cdo.getColValue("num_empleado"),false,false,true,10,"text10","","")%></td>
				<td width="" align="right"><cellbytelabel>Seg. Social</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_ssocial",cdo.getColValue("num_ssocial"),false,false,true,10,"text10","","")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Primer/Segundo Nombr</cellbytelabel>e</td>
				<td width="" colspan="3">
				<%=fb.textBox("primer_nombre",cdo.getColValue("primer_nombre"),false,false,true,30,"text10","","")%>
				<%=fb.textBox("segundo_nombre",cdo.getColValue("segundo_nombre"),false,false,true,30,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Primer/Segundo Apellido</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("primer_apellido",cdo.getColValue("primer_apellido"),false,false,true,30,"text10","","")%>
        <%=fb.textBox("segundo_apellido",cdo.getColValue("segundo_apellido"),false,false,true,30,"text10","","")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Unid. Administrativa</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("unidad_organi",cdo.getColValue("unidad_organi"),false,false,true,10,"text10","","")%>
				<%=fb.textBox("unidad_organi_desc",cdo.getColValue("unidad_organi_desc"),false,false,true,50,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Cargo o Posici&oacute;n</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("cargo",cdo.getColValue("cargo"),false,false,true,10,"text10","","")%>
        <%=fb.textBox("cargo_desc",cdo.getColValue("cargo_desc"),false,false,true,50,"text10","","")%>
        </td>
			</tr>
			<tr class="TextPanel">
				<td colspan="8"><cellbytelabel>D&iacute;as Laborados</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right" colspan="2"><cellbytelabel>Desde</cellbytelabel></td>
				<td width="">
        <jsp:include page="../common/calendar.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="nameOfTBox1" value="fecha_inicio"/>
        <jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fecha_inicio")==null)?"":cdo.getColValue("fecha_inicio")%>" />
        <jsp:param name="fieldClass" value="text10"/>
        <jsp:param name="buttonClass" value="text10"/>
        <jsp:param name="jsEvent" value="getDiasLaborados()"/>
        <jsp:param name="onChange" value="getDiasLaborados()"/>
        </jsp:include>
        </td>
				<td width="" align="center"><cellbytelabel>Pagar</cellbytelabel></td>
        <td width="" align="center"><cellbytelabel>Descontar</cellbytelabel></td>
				<td width="" colspan="3">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right" colspan="2"><cellbytelabel>Hasta</cellbytelabel></td>
				<td width="">
        <jsp:include page="../common/calendar.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="nameOfTBox1" value="fecha_final"/>
        <jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fecha_final")==null)?"":cdo.getColValue("fecha_final")%>" />
        <jsp:param name="fieldClass" value="text10"/>
        <jsp:param name="buttonClass" value="text10"/>
        <jsp:param name="jsEvent" value="getDiasLaborados()"/>
        <jsp:param name="onChange" value="getDiasLaborados()"/>
        </jsp:include>
        </td>
				<td width="" align="center">
				<%=fb.decBox("tr_pa_trx",cdo.getColValue("tr_pa_trx"),false,false,true,10, 8.2,null,null,"onFocus=\"this.select();\"","",false,"")%>
        </td>
        <td width="" align="center">
				<%=fb.decBox("tr_ds_trx",cdo.getColValue("tr_ds_trx"),false,false,true,10, 8.2,null,null,"onFocus=\"this.select();\"","",false,"")%>
        </td>
				<td width="" colspan="3" align="center">
				<%=fb.button("buscarTrx","Registro de Transacciones",false,false,"text10","","onClick=\"javascript:addTransaccions()\"")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right" colspan="2"><cellbytelabel>D&iacute;as Laborados</cellbytelabel></td>
				<td width="">
				<%=fb.intBox("dias_laborados",cdo.getColValue("dias_laborados"),false,false,false,5,2,null,null,"")%>
        </td>
				<td width="" align="center">
				<%=fb.decBox("tr_pa_st",cdo.getColValue("tr_pa_st"),false,false,true,10, 8.2,null,null,"onFocus=\"this.select();\"","",false,"")%>
        </td>
        <td width="" align="center">
				<%=fb.decBox("tr_ds_st",cdo.getColValue("tr_ds_st"),false,false,true,10, 8.2,null,null,"onFocus=\"this.select();\"","",false,"")%>
        </td>
				<td width="" colspan="3" align="center">
				<%=fb.button("buscarExtra","Registro de Sobretiempo",false,false,"text10","","onClick=\"javascript:addSobretiempo()\"")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right" colspan="2"><cellbytelabel>Horas Regulares</cellbytelabel></td>
				<td width="">
				<%=fb.intBox("horas_regulares",cdo.getColValue("horas_regulares"),false,false,true,5,2,null,null,"")%>
        </td>
				<td width="" align="center">
				<%=fb.decBox("tr_pa_at",cdo.getColValue("tr_pa_at"),false,false,true,10, 8.2,null,null,"onFocus=\"this.select();\"","",false,"")%>
        </td>
        <td width="" align="center">
				<%=fb.decBox("tr_ds_at",cdo.getColValue("tr_ds_at"),false,false,true,10, 8.2,null,null,"onFocus=\"this.select();\"","",false,"")%>
        </td>
				<td width="" colspan="3" align="center"><%=fb.button("buscarAus","Registro Ausencias/Tardanzas",false,false,"text10","","onClick=\"javascript:addAusencia()\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="center">&nbsp;</td>
				<td width="" align="center"><cellbytelabel>Rata por Hora</cellbytelabel></td>
				<td width="" align="center"><cellbytelabel>Salario a Pagar</cellbytelabel></td>
				<td width="" align="center"><%=fb.decBox("tr_pa",cdo.getColValue("tr_pa"),false,false,true,10, 8.2,null,null,"","",false,"")%></td>
        <td width="" align="center"><%=fb.decBox("tr_ds",cdo.getColValue("tr_ds"),false,false,true,10, 8.2,null,null,"","",false,"")%></td>
				<td width="" colspan="3">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Salario Base</cellbytelabel></td>
				<td width="" align="center"><%=fb.decBox("rata_x_hora",cdo.getColValue("rata_hora"),false,false,true,10, 8.2,null,null,"","",false,"")%></td>
				<td width="" align="center"><%=fb.decBox("salario_pagar",cdo.getColValue("salario_pagar"),false,false,true,10, 8.2,null,null,"","",false,"")%></td>
				<td width="" colspan="5">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Gastos Repr</cellbytelabel>.</td>
				<td width="" align="center"><%=fb.decBox("rata_x_horagr",cdo.getColValue("rata_x_horagr"),false,false,true,10, 8.2,null,null,"","",false,"")%></td>
				<td width="" align="center"><%=fb.decBox("salario_pagargr",cdo.getColValue("salario_pagargr"),false,false,true,10, 8.2,null,null,"","",false,"")%></td>
				<td width="" colspan="5">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="8" align="right"><%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<%
if(cdoM.getColValue("pagar_vacacion").equals("S")){
%>
<!-- V A C A C I O N E S -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document.form3.baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
			<%=fb.hidden("emp_id",emp_id)%>
			<%=fb.hidden("indTab","3")%>
			<%=fb.hidden("baction","")%>
			 <%//=fb.hidden("dias_vacaciones", "")%>
      <%=fb.hidden("fecha_egreso",cdo.getColValue("fecha_egreso"))%>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="8"><cellbytelabel>Generales del Empleado</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,2,"text10","","")%>-
        <%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3,"text10","","")%>-
        <%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,true,5,"text10","","")%>-
        <%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,true,5,"text10","","")%>
				</td>
				<td width="" align="right"><cellbytelabel>Num. Empleado</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_empleado",cdo.getColValue("num_empleado"),false,false,true,10,"text10","","")%></td>
				<td width="" align="right"><cellbytelabel>Seg. Social</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_ssocial",cdo.getColValue("num_ssocial"),false,false,true,10,"text10","","")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Primer/Segundo Nombre</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("primer_nombre",cdo.getColValue("primer_nombre"),false,false,true,30,"text10","","")%>
				<%=fb.textBox("segundo_nombre",cdo.getColValue("segundo_nombre"),false,false,true,30,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Primer/Segundo Apellido</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("primer_apellido",cdo.getColValue("primer_apellido"),false,false,true,30,"text10","","")%>
        <%=fb.textBox("segundo_apellido",cdo.getColValue("segundo_apellido"),false,false,true,30,"text10","","")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Unid. Administrativa</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("unidad_organi",cdo.getColValue("unidad_organi"),false,false,true,10,"text10","","")%>
				<%=fb.textBox("unidad_organi_desc",cdo.getColValue("unidad_organi_desc"),false,false,true,50,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Cargo o Posici&oacute;n</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("cargo",cdo.getColValue("cargo"),false,false,true,10,"text10","","")%>
        <%=fb.textBox("cargo_desc",cdo.getColValue("cargo_desc"),false,false,true,50,"text10","","")%>
        </td>
			</tr>
			<tr class="TextPanel">
				<td colspan="8"><cellbytelabel>Vacaciones</cellbytelabel></td>
			</tr>
      <tr>
      	<td colspan="8">
        	<table width="100%">
            <tr class="TextPanel02">
              <td colspan="2"><cellbytelabel>Vacaciones Vencidas</cellbytelabel></td>
              <td colspan="2"><cellbytelabel>Vacaciones Proporcionales</cellbytelabel></td>
              <td>&nbsp;</td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>D&iacute;as</cellbytelabel></td>
              <td width="">
              <%=fb.intBox("dias_vacaciones",cdo.getColValue("dias_vacaciones"),false,false,false,5,2,null,null,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Periodos</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.decBox("vacp_periodos",cdo.getColValue("vacp_periodos"),false,false,true,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">
              <jsp:include page="../common/calendar.jsp" flush="true">
              <jsp:param name="noOfDateTBox" value="1" />
              <jsp:param name="clearOption" value="true" />
              <jsp:param name="nameOfTBox1" value="vac_fecha_docto"/>
              <jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("vac_fecha_docto")==null)?"":cdo.getColValue("vac_fecha_docto")%>" />
              <jsp:param name="fieldClass" value="text10"/>
              <jsp:param name="buttonClass" value="text10"/>
              </jsp:include>
              </td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Salario</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("vac_salario",cdo.getColValue("vac_salario"),false,false,true,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Salario</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.decBox("vacp_salario",cdo.getColValue("vacp_salario"),false,false,true,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">
              <%//=fb.button("buscar","Acumulados Vacaciones Vencidas",false,false,"text10","","onClick=\"javascript:selEmpleado()\"")%>
              </td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Gasto Rep</cellbytelabel>.</td>
              <td width="">
              <%=fb.decBox("vac_gasto",cdo.getColValue("vac_gasto"),false,false,true,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Gasto Rep</cellbytelabel>.</td>
              <td width="" align="center">
              <%=fb.decBox("vacp_gasto",cdo.getColValue("vacp_gasto"),false,false,true,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">
              <%//=fb.button("buscar","Acumulados Vacaciones Proporcionales",false,false,"text10","","onClick=\"javascript:selEmpleado()\"")%>
              </td>
            </tr>
            <tr class="TextPanel02">
              <td colspan="2"><cellbytelabel>Acumulados</cellbytelabel></td>
              <td colspan="2"><cellbytelabel>Acumulados</cellbytelabel></td>
              <td>&nbsp;</td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Salario</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("acum_salario",cdo.getColValue("acum_salario"),false,false,true,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Salario</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.decBox("acump_salario",cdo.getColValue("acump_salario"),false,false,true,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">&nbsp;</td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Gasto Rep</cellbytelabel>.</td>
              <td width="">
              <%=fb.decBox("acum_gasto",cdo.getColValue("acum_gasto"),false,false,true,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Gasto Rep</cellbytelabel>.</td>
              <td width="" align="center">
              <%=fb.decBox("acump_gasto",cdo.getColValue("acump_gasto"),false,false,true,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">&nbsp;</td>
            </tr>
            <tr>
              <td colspan="5" onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
                <table width="100%" cellpadding="1" cellspacing="0">
                <tr class="TextPanel">
                  <td width="95%">&nbsp;<cellbytelabel>Detalle de Acumulado de Vacaciones</cellbytelabel></td>
                  <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
                </tr>
                </table>
              </td>
            </tr>
            <tr id="panel2">
              <td colspan="5">
                <iframe name="itemFrameVacVen" id="itemFrameVacVen" frameborder="0" align="center" width="100%" height="73" scrolling="yes" src="../rhplanilla/reg_liquidacion_det_temporal_vac.jsp?fp=<%=fp%>&emp_id=<%=emp_id%>&fecha_egreso=<%=cdo.getColValue("fecha_egreso")%>"></iframe>
              </td>
            </tr>
            <tr>
              <td colspan="5" onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer">
                <table width="100%" cellpadding="1" cellspacing="0">
                <tr class="TextPanel">
                  <td width="95%">&nbsp;<cellbytelabel>Detalle de Acumulado de Vacaciones Proporcionales</cellbytelabel></td>
                  <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
                </tr>
                </table>
              </td>
            </tr>
            <tr id="panel3">
              <td colspan="4">
                <iframe name="itemFrameVacVenProp" id="itemFrameVacVenProp" frameborder="0" align="center" width="100%" height="73" scrolling="yes" src="../rhplanilla/reg_liquidacion_det_temporal_vac_prop.jsp?fp=<%=fp%>&emp_id=<%=emp_id%>&fecha_egreso=<%=cdo.getColValue("fecha_egreso")%>"></iframe>
              </td>
              <td>
              	<table>
                	<tr>
                  	<td><cellbytelabel>Fecha de Inicio</cellbytelabel></td>
                    <td width="" align="center">
                    <jsp:include page="../common/calendar.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fecha_inicio"/>
                    <jsp:param name="valueOfTBox1" value="" />
                    <jsp:param name="fieldClass" value="text10"/>
                    <jsp:param name="buttonClass" value="text10"/>
                    </jsp:include>
                    </td>
                  </tr>
                	<tr>
                    <td width="" align="center" colspan="2"><cellbytelabel>Vacaciones Proporcionales</cellbytelabel></td>
                  </tr>
                	<tr>
                    <td width="" align="right"><cellbytelabel>Salario</cellbytelabel>:</td>
                    <td width="" align="right">
			              <%=fb.decBox("vp_salario",cdo.getColValue("vp_salario"),false,false,true,10, 8.2,null,null,"","",false,"")%>
                    </td>
                  </tr>
                	<tr>
                    <td width="" align="right"><cellbytelabel>Gasto de Rep</cellbytelabel>.:</td>
                    <td width="" align="right">
			              <%=fb.decBox("vp_gastorep",cdo.getColValue("vp_gastorep"),false,false,true,10, 8.2,null,null,"","",false,"")%>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
      		</table>
         </td>
      </tr>
			<tr class="TextRow02">
				<td colspan="8" align="right"><%//=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<%
}
if(cdoM.getColValue("pagar_xiii_mes").equals("S")){
%>
<!-- D E C I M O  -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document.form4.baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
			<%=fb.hidden("emp_id",emp_id)%>
			<%=fb.hidden("indTab","4")%>
			<%=fb.hidden("baction","")%>
      <%=fb.hidden("fecha_egreso",cdo.getColValue("fecha_egreso"))%>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="8"><cellbytelabel>Generales del Empleado</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,2,"text10","","")%>-
        <%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3,"text10","","")%>-
        <%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,true,5,"text10","","")%>-
        <%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,true,5,"text10","","")%>
				</td>
				<td width="" align="right"><cellbytelabel>Num. Empleado</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_empleado",cdo.getColValue("num_empleado"),false,false,true,10,"text10","","")%></td>
				<td width="" align="right"><cellbytelabel>Seg. Social</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_ssocial",cdo.getColValue("num_ssocial"),false,false,true,10,"text10","","")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Primer/Segundo Nombre</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("primer_nombre",cdo.getColValue("primer_nombre"),false,false,true,30,"text10","","")%>
				<%=fb.textBox("segundo_nombre",cdo.getColValue("segundo_nombre"),false,false,true,30,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Primer/Segundo Apellido</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("primer_apellido",cdo.getColValue("primer_apellido"),false,false,true,30,"text10","","")%>
        <%=fb.textBox("segundo_apellido",cdo.getColValue("segundo_apellido"),false,false,true,30,"text10","","")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Unid. Administrativa</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("unidad_organi",cdo.getColValue("unidad_organi"),false,false,true,10,"text10","","")%>
				<%=fb.textBox("unidad_organi_desc",cdo.getColValue("unidad_organi_desc"),false,false,true,50,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Cargo o Posici&oacute;n</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("cargo",cdo.getColValue("cargo"),false,false,true,10,"text10","","")%>
        <%=fb.textBox("cargo_desc",cdo.getColValue("cargo_desc"),false,false,true,50,"text10","","")%>
        </td>
			</tr>
			<tr class="TextPanel">
				<td colspan="8"><cellbytelabel>Decimo</cellbytelabel></td>
			</tr>
      <tr>
      	<td colspan="8">
        	<table width="100%">
            <tr class="TextPanel02">
              <td colspan="6"><cellbytelabel>Acumulados</cellbytelabel></td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right">&nbsp;</td>
              <td width="" align="center"><cellbytelabel>Acumulado</cellbytelabel></td>
              <td width="" align="right">&nbsp;</td>
              <td width="" align="center"><cellbytelabel>Vacaciones Proporcionales</cellbytelabel></td>
              <td width="" align="right">&nbsp;</td>
              <td width="" align="center"><cellbytelabel>Total</cellbytelabel></td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Salario</cellbytelabel></td>
              <td width="">
              <%=fb.hidden("acum_xiii_sal_hidden",cdo.getColValue("acum_xiii_sal"))%>
							<%=fb.decBox("acum_xiii_sal",cdo.getColValue("acum_xiii_sal"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">+</td>
              <td width="" align="center">
              <%=fb.decBox("vac_prop_sal",cdo.getColValue("vac_prop_sal"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">=</td>
              <td width="" align="center">
              <%=fb.decBox("xiii_salario",cdo.getColValue("xiii_salario"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Gasto de Representaci&oacute;n</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("acum_xiii_gr",cdo.getColValue("acum_xiii_gr"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">+</td>
              <td width="" align="center">
              <%=fb.decBox("vac_prop_gr",cdo.getColValue("vac_prop_gr"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">=</td>
              <td width="" align="center">
              <%=fb.decBox("xiii_gasto",cdo.getColValue("xiii_gasto"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
            </tr>
      		</table>
         </td>
      </tr>
			<tr class="TextRow02">
				<td colspan="8" align="right"><%//=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<%
}
if(cdoM.getColValue("pagar_pantig").equals("S")){
%>
<!-- P R I M A   D E   A N T I G U E D A D -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
			<%fb.appendJsValidation("if(document.form5.baction.value!='Guardar')return true;");%>
			<%=fb.hidden("emp_id",emp_id)%>
			<%=fb.hidden("indTab","5")%>
			<%=fb.hidden("baction","")%>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="8"><cellbytelabel>Generales del Empleado</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,2,"text10","","")%>-
        <%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3,"text10","","")%>-
        <%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,true,5,"text10","","")%>-
        <%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,true,5,"text10","","")%>
				</td>
				<td width="" align="right"><cellbytelabel>Num. Empleado</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_empleado",cdo.getColValue("num_empleado"),false,false,true,10,"text10","","")%></td>
				<td width="" align="right"><cellbytelabel>Seg. Social</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_ssocial",cdo.getColValue("num_ssocial"),false,false,true,10,"text10","","")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Primer/Segundo Nombre</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("primer_nombre",cdo.getColValue("primer_nombre"),false,false,true,30,"text10","","")%>
				<%=fb.textBox("segundo_nombre",cdo.getColValue("segundo_nombre"),false,false,true,30,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Primer/Segundo Apellido</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("primer_apellido",cdo.getColValue("primer_apellido"),false,false,true,30,"text10","","")%>
        <%=fb.textBox("segundo_apellido",cdo.getColValue("segundo_apellido"),false,false,true,30,"text10","","")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Unid. Administrativa</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("unidad_organi",cdo.getColValue("unidad_organi"),false,false,true,10,"text10","","")%>
				<%=fb.textBox("unidad_organi_desc",cdo.getColValue("unidad_organi_desc"),false,false,true,50,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Cargo o Posici&oacute;n</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("cargo",cdo.getColValue("cargo"),false,false,true,10,"text10","","")%>
        <%=fb.textBox("cargo_desc",cdo.getColValue("cargo_desc"),false,false,true,50,"text10","","")%>
        </td>
			</tr>
			<tr class="TextPanel">
				<td colspan="8"><cellbytelabel>Prima de Antig&uuml;edad</cellbytelabel></td>
			</tr>
      <tr>
      	<td colspan="8">
        	<table width="100%">
            <tr class="TextRow01">
              <td width="" align="right" colspan="2"><cellbytelabel>Salarios Acumulados desde</cellbytelabel></td>
              <td width="">
              <%=fb.textBox("fecha_inicio",cdo.getColValue("fecha_inicio"),false,false,true,12,"text10","","")%>
              </td>
              <td width="" align="center"><cellbytelabel>Hasta</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.textBox("fecha_egreso",cdo.getColValue("fecha_egreso"),false,false,true,12,"text10","","")%>
              </td>
              <td width="" align="center">&nbsp;</td>
              <td width="" align="center">
              <%=fb.textBox("fecha_docto",cdo.getColValue("fecha_docto"),false,false,true,12,"text10","","")%>
              </td>
            </tr>
            <tr class="TextRow01">
              <cellbytelabel>
              	<td width="" align="right" colspan="2">&nbsp;</td>
              	<td width="">&nbsp;</td>
              	<td width="" align="center"><cellbytelabel>Cantidad</cellbytelabel></td>
              	<td width="" align="center"><cellbytelabel>Monto</cellbytelabel></td>
              	<td width="" align="right"><cellbytelabel>Descontar Preaviso</cellbytelabel>?</td>
              	<td width="" align="left">
              	<%//=fb.checkbox("pr_ck_preaviso",cdo.getColValue("pr_ck_preaviso"),false,false,"text10","","")%>
              	<%=fb.checkbox("pr_ck_preaviso",cdo.getColValue("pr_ck_preaviso"),(cdo.getColValue("pr_ck_preaviso")!= null && cdo.getColValue("pr_ck_preaviso").equals("S")?true:false),false,"text10","","onClick=\"javascript:getPromSemanal()\"")%>
              	</td>
              </cellbytelabel>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Acumulado</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("pr_acumulado",cdo.getColValue("pr_acumulado"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center"><cellbytelabel>A&ntilde;os</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.intBox("anios",cdo.getColValue("anios"),false,false,false, 6, 3,null,null,"")%>
              </td>
              <td width="" align="center">
              <%=fb.decBox("pr_valor_anios",cdo.getColValue("pr_valor_anios"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Preaviso</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.decBox("pr_preaviso",cdo.getColValue("pr_preaviso"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Semanas</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("pr_semanas",cdo.getColValue("pr_semanas"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center"><cellbytelabel>Meses</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.intBox("meses",cdo.getColValue("meses"),false,false,false,6, 2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">
              <%=fb.decBox("pr_valor_meses",cdo.getColValue("pr_valor_meses"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Otros Beneficios</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.decBox("pr_otros_beneficios",cdo.getColValue("pr_otros_beneficios"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Promedio Sem</cellbytelabel>.</td>
              <td width="">
              <%=fb.decBox("pr_promedio",cdo.getColValue("pr_promedio"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center"><cellbytelabel>D&iacute;as</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.intBox("dias",cdo.getColValue("dias"),false,false,false,6, 3,null,null,"","",false,"")%>
              </td>
              <td width="" align="center">
              <%=fb.decBox("pr_valor_dias",cdo.getColValue("pr_valor_dias"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right">&nbsp;</td>
              <td width="" align="center">&nbsp;</td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right" colspan="2">&nbsp;</td>
              <td width="" align="right" colspan="2"><cellbytelabel>Prima de Antig&uuml;edad</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.decBox("pr_valor_prima",cdo.getColValue("pr_valor_prima"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center" colspan="2">&nbsp;</td>
            </tr>
      		</table>
         </td>
      </tr>
			<tr class="TextRow02">
				<td colspan="8" align="right"><%//=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<%
}
if(cdoM.getColValue("pagar_indemn").equals("S")){
%>
<!-- I N D E M N I Z A C I O N -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
			<%fb.appendJsValidation("if(document.form5.baction.value!='Guardar')return true;");%>
			<%=fb.hidden("emp_id",emp_id)%>
			<%=fb.hidden("indTab","6")%>
			<%=fb.hidden("baction","")%>
      <%=fb.hidden("fecha_egreso",cdo.getColValue("fecha_egreso"))%>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="8"><cellbytelabel>Generales del Empleado</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,2,"text10","","")%>-
        <%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3,"text10","","")%>-
        <%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,true,5,"text10","","")%>-
        <%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,true,5,"text10","","")%>
				</td>
				<td width="" align="right"><cellbytelabel>Num. Empleado</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_empleado",cdo.getColValue("num_empleado"),false,false,true,10,"text10","","")%></td>
				<td width="" align="right"><cellbytelabel>Seg. Social</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_ssocial",cdo.getColValue("num_ssocial"),false,false,true,10,"text10","","")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Primer/Segundo Nombre</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("primer_nombre",cdo.getColValue("primer_nombre"),false,false,true,30,"text10","","")%>
				<%=fb.textBox("segundo_nombre",cdo.getColValue("segundo_nombre"),false,false,true,30,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Primer/Segundo Apellido</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("primer_apellido",cdo.getColValue("primer_apellido"),false,false,true,30,"text10","","")%>
        <%=fb.textBox("segundo_apellido",cdo.getColValue("segundo_apellido"),false,false,true,30,"text10","","")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Unid. Administrativa</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("unidad_organi",cdo.getColValue("unidad_organi"),false,false,true,10,"text10","","")%>
				<%=fb.textBox("unidad_organi_desc",cdo.getColValue("unidad_organi_desc"),false,false,true,50,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Cargo o Posici&oacute;n</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("cargo",cdo.getColValue("cargo"),false,false,true,10,"text10","","")%>
        <%=fb.textBox("cargo_desc",cdo.getColValue("cargo_desc"),false,false,true,50,"text10","","")%>
        </td>
			</tr>
			<tr class="TextPanel">
				<td colspan="8"><cellbytelabel>Indemnizaci&oacute;n</cellbytelabel></td>
			</tr>
      <tr>
      	<td colspan="8">
        	<table width="100%">
            <tr class="TextRow01">
              <td width="" align="right" colspan="2"><cellbytelabel>Salario Ultimos 6 Meses</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("in_salario_ult6mes",cdo.getColValue("in_salario_ult6mes"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center" colspan="2"><cellbytelabel>Promedio Mensual</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.decBox("in_promedio_men",cdo.getColValue("in_promedio_men"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center"><%=fb.textBox("fecha_egreso",cdo.getColValue("fecha_egreso"),false,false,true,12,"text10","","")%></td>
              <td width="" align="center"><%=fb.textBox("fecha_docto",cdo.getColValue("fecha_docto"),false,false,true,12,"text10","","")%></td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right" colspan="2"><cellbytelabel>Salario Ultimo Mes</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("in_ultimo_salario",cdo.getColValue("in_ultimo_salario"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center" colspan="2"><cellbytelabel>Promedio Semanal</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.decBox("in_promedio_sem",cdo.getColValue("in_promedio_sem"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Recibe Preaviso</cellbytelabel>?</td>
              <td width="" align="left">
              <%=fb.checkbox("in_ck_preaviso",cdo.getColValue("in_ck_preaviso"),(cdo.getColValue("in_ck_preaviso")!= null && cdo.getColValue("in_ck_preaviso").equals("S")?true:false),false,"text10","","onClick=\"javascript:chkPreaviso(this)\"")%>
              </td>
            </tr>

			<tr class="TextRow01">
              <td width="" align="right" colspan="2"></td>
              <td width="">&nbsp;</td>
              <td width="" align="center" colspan="2"></td>
              <td width="" align="center">&nbsp;   </td>
              <td width="" align="right"> <%=fb.decBox("ind_recargo25",cdo.getColValue("ind_recargo25"),false,false,false,10, 8.2,null,null,"","",false,"")%>  </td>
              <td width="" align="left"> <%=fb.checkbox("in_ck_recargo25",cdo.getColValue("in_ck_recargo25"),(cdo.getColValue("in_ck_recargo25")!= null && cdo.getColValue("in_ck_recargo25").equals("S")?true:false),false,"text10","","onClick=\"javascript:chkRecargo25(this)\"")%><cellbytelabel>Indem.(Recargo 25%)</cellbytelabel>   </td>
            </tr>

			<tr class="TextRow01">
              <td width="" align="right" colspan="2"></td>
              <td width="">&nbsp;</td>
              <td width="" align="center" colspan="2"></td>
              <td width="" align="center">&nbsp;   </td>
              <td width="" align="right"> <%=fb.decBox("ind_recargo50",cdo.getColValue("ind_recargo50"),false,false,false,10, 8.2,null,null,"","",false,"")%>   </td>
              <td width="" align="left"> <%=fb.checkbox("in_ck_recargo50",cdo.getColValue("in_ck_recargo50"),(cdo.getColValue("in_ck_recargo50")!= null && cdo.getColValue("in_ck_recargo50").equals("S")?true:false),false,"text10","","onClick=\"javascript:chkRecargo50(this)\"")%><cellbytelabel>Indem.(Recargo 50%)</cellbytelabel>
              </td>
            </tr>

            <tr class="TextPanel">
              <td colspan="8"><cellbytelabel>Tiempo de Servicio</cellbytelabel></td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="center"><cellbytelabel>A&ntilde;os</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.intBox("anios",cdo.getColValue("anios"),false,false,true, 6, 3,null,null,"")%>
              </td>
              <td width="" align="center"><cellbytelabel>Meses</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.intBox("meses",cdo.getColValue("meses"),false,false,true,6, 2,null,null,"","",false,"")%>
              </td>
              <td width="" align="center"><cellbytelabel>D&iacute;as</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.intBox("dias",cdo.getColValue("dias"),false,false,true,6, 3,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Preaviso</cellbytelabel></td>
              <td width="" align="left">
              <%=fb.decBox("in_preaviso",cdo.getColValue("in_preaviso"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="center" colspan="6">&nbsp;</td>
              <td width="" align="right"><cellbytelabel>Total Indenmizaci&oacute;n</cellbytelabel></td>
              <td width="" align="left">
              <%=fb.decBox("in_indemnizacion",cdo.getColValue("in_indemnizacion"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
            </tr>
      		</table>
         </td>
      </tr>
      <tr>
        <td colspan="8">
          <iframe name="itemFrameInd" id="itemFrameInd" frameborder="0" align="center" width="100%" height="73" scrolling="yes" src="../rhplanilla/reg_liquidacion_det_indem.jsp?fp=<%=fp%>&emp_id=<%=emp_id%>&fecha_egreso=<%=cdo.getColValue("fecha_egreso")%>"></iframe>
        </td>
      </tr>
			<tr class="TextRow02">
				<td colspan="8" align="right"><%//=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<%
}
%>
<!-- D E D U C C I O N E S   L E G A L E S   C X C -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form7",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
			<%fb.appendJsValidation("if(document.form5.baction.value!='Guardar')return true;");%>
			<%=fb.hidden("emp_id",emp_id)%>
			<%=fb.hidden("indTab","7")%>
			<%=fb.hidden("baction","")%>
      <%=fb.hidden("fecha_egreso",cdo.getColValue("fecha_egreso"))%>
      <%=fb.hidden("imp_tardanzas",cdo.getColValue("imp_tardanzas"))%>
      <%=fb.hidden("imp_periodos",cdo.getColValue("imp_periodos"))%>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="8">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="8"><cellbytelabel>Generales del Empleado</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,true,2,"text10","","")%>-
        <%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3,"text10","","")%>-
        <%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,true,5,"text10","","")%>-
        <%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,true,5,"text10","","")%>
				</td>
				<td width="" align="right"><cellbytelabel>Num. Empleado</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_empleado",cdo.getColValue("num_empleado"),false,false,true,10,"text10","","")%></td>
				<td width="" align="right"><cellbytelabel>Seg. Social</cellbytelabel></td>
				<td width=""><%=fb.textBox("num_ssocial",cdo.getColValue("num_ssocial"),false,false,true,10,"text10","","")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Primer/Segundo Nombre</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("primer_nombre",cdo.getColValue("primer_nombre"),false,false,true,30,"text10","","")%>
				<%=fb.textBox("segundo_nombre",cdo.getColValue("segundo_nombre"),false,false,true,30,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Primer/Segundo Apellido</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("primer_apellido",cdo.getColValue("primer_apellido"),false,false,true,30,"text10","","")%>
        <%=fb.textBox("segundo_apellido",cdo.getColValue("segundo_apellido"),false,false,true,30,"text10","","")%>
        </td>
			</tr>
			<tr class="TextRow01">
				<td width="" align="right"><cellbytelabel>Unid. Administrativa</cellbytelabel></td>
				<td width="" colspan="3">
				<%=fb.textBox("unidad_organi",cdo.getColValue("unidad_organi"),false,false,true,10,"text10","","")%>
				<%=fb.textBox("unidad_organi_desc",cdo.getColValue("unidad_organi_desc"),false,false,true,50,"text10","","")%>
        </td>
				<td width="" align="right"><cellbytelabel>Cargo o Posici&oacute;n</cellbytelabel></td>
				<td width="" colspan="3">
        <%=fb.textBox("cargo",cdo.getColValue("cargo"),false,false,true,10,"text10","","")%>
        <%=fb.textBox("cargo_desc",cdo.getColValue("cargo_desc"),false,false,true,50,"text10","","")%>
        </td>
			</tr>
			<tr class="TextPanel">
				<td colspan="8"><cellbytelabel>Deducciones - Impuestos</cellbytelabel></td>
			</tr>
      <tr>
      	<td colspan="8">
        	<table width="100%">
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Total Bruto Liquidaci&oacute;n</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("imp_total_liquidacion",cdo.getColValue("imp_total_liquidacion"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Total para C&aacute;lculo de Seg. Social</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.decBox("imp_total_liqss",cdo.getColValue("imp_total_liqss"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Seguro Social</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("imp_ssocial",cdo.getColValue("imp_ssocial"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Total para C&aacute;lculo de Seg. Educ</cellbytelabel>.</td>
              <td width="" align="center">
              <%=fb.decBox("imp_total_liqse",cdo.getColValue("imp_total_liqse"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Seguro Educativo</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("imp_seducat",cdo.getColValue("imp_seducat"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right">&nbsp;</td>
              <td width="" align="center">&nbsp;</td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Impuesto S/Renta</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("imp_renta",cdo.getColValue("imp_renta"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Total para C&aacute;lculo de Imp. S/Renta</cellbytelabel></td>
              <td width="" align="center">
              <%=fb.decBox("imp_total_liqrenta",cdo.getColValue("imp_total_liqrenta"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Impuesto S/Renta</cellbytelabel> *</td>
              <td width="">
              <%=fb.decBox("imp_rentae",cdo.getColValue("imp_rentae"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right"><cellbytelabel>Total para C&aacute;lculo de Imp. S/Renta</cellbytelabel> *</td>
              <td width="" align="center">
              <%=fb.decBox("imp_total_liqrentae",cdo.getColValue("imp_total_liqrentae"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>Cl&iacute;nica</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("imp_clinica",cdo.getColValue("imp_clinica"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right">&nbsp;</td>
              <td width="" align="center">&nbsp;</td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>CxC Empleado/Otros</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("imp_cxcemp",cdo.getColValue("imp_cxcemp"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="right">&nbsp;</td>
              <td width="" align="center">&nbsp;</td>
            </tr>
            <tr class="TextRow01">
              <td width="" align="right"><cellbytelabel>NETO A PAGAR</cellbytelabel></td>
              <td width="">
              <%=fb.decBox("imp_neto_pagar",cdo.getColValue("imp_neto_pagar"),false,false,false,10, 8.2,null,null,"","",false,"")%>
              </td>
              <td width="" align="left"><cellbytelabel>Este total incluye los descuentos por tardanza, ausencia y ajustes</cellbytelabel>.<br>* <cellbytelabel>Ver secci&oacute;n de Salarios</cellbytelabel></td>
              <td width="" align="center">&nbsp;</td>
            </tr>
      		</table>
         </td>
      </tr>
			<tr class="TextRow02">
				<td colspan="8" align="right"><%//=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="8">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
</div>
<script type="text/javascript">
<%if(mode.trim().equals("view")){
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=indTab%>,'100%','',null,null,null);
<%}else{%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=indTab%>,'100%','',null,null,Array(<%=tabFunctions%>));
<%}%>
</script>
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
	String companyId = (String) session.getAttribute("_companyId");
	String del = "0";
	String baction = request.getParameter("baction");
	String tableName1 = "";
	emp_id = request.getParameter("emp_id");

	cdo = new CommonDataObject();
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("provincia",request.getParameter("provincia"));
	cdo.addColValue("sigla",request.getParameter("sigla"));
	cdo.addColValue("tomo",request.getParameter("tomo"));
	cdo.addColValue("asiento",request.getParameter("asiento"));
	cdo.addColValue("fecha_egreso",request.getParameter("fecha_egreso"));
	cdo.addColValue("fecha_docto", request.getParameter("fecha_docto"));
	cdo.addColValue("motivo",request.getParameter("motivo"));
	cdo.addColValue("periodo_pago",request.getParameter("periodo_pago"));
	cdo.addColValue("anio_pago",request.getParameter("anio_pago"));
	cdo.addColValue("ts_anios",request.getParameter("anios"));
	cdo.addColValue("ts_meses",request.getParameter("meses"));
	cdo.addColValue("ts_dias",request.getParameter("dias"));
	cdo.addColValue("emp_id",emp_id);

	if(request.getParameter("sp_fecha_inicio")!=null && !request.getParameter("sp_fecha_inicio").trim().equals(""))
		cdo.addColValue("dl_desde", request.getParameter("sp_fecha_inicio"));

	if(request.getParameter("sp_fecha_final")!=null && !request.getParameter("sp_fecha_final").trim().equals(""))
		cdo.addColValue("dl_hasta", request.getParameter("sp_fecha_final"));

	if(request.getParameter("dias_laborados")!=null && !request.getParameter("dias_laborados").trim().equals(""))
		cdo.addColValue("dl_dias_laborados", request.getParameter("dias_laborados"));

	if(request.getParameter("horas_regulares")!=null && !request.getParameter("horas_regulares").trim().equals(""))
		cdo.addColValue("dl_thoras_regulares", request.getParameter("horas_regulares"));

	if(request.getParameter("dias_vacaciones")!=null && !request.getParameter("dias_vacaciones").trim().equals(""))
      cdo.addColValue("vac_venc_dias", request.getParameter("dias_vacaciones"));

	if(request.getParameter("vac_salario")!=null && !request.getParameter("vac_salario").trim().equals(""))
		cdo.addColValue("vac_venc_salario", request.getParameter("vac_salario"));

	if(request.getParameter("vac_gasto")!=null && !request.getParameter("vac_gasto").trim().equals(""))
		cdo.addColValue("vac_venc_gasto", request.getParameter("vac_gasto"));

	if(request.getParameter("vacp_periodos")!=null && !request.getParameter("vacp_periodos").trim().equals(""))
		cdo.addColValue("vac_prop_periodos", request.getParameter("vacp_periodos"));

	if(request.getParameter("vacp_salario")!=null && !request.getParameter("vacp_salario").trim().equals(""))
		cdo.addColValue("vac_prop_salario", request.getParameter("vacp_salario"));

	if(request.getParameter("vacp_gasto")!=null && !request.getParameter("vacp_gasto").trim().equals(""))
		cdo.addColValue("vac_prop_gasto", request.getParameter("vacp_gasto"));

	if(request.getParameter("xiii_salario")!=null && !request.getParameter("xiii_salario").trim().equals(""))
		cdo.addColValue("xiii_prop_salario", request.getParameter("xiii_salario"));

	if(request.getParameter("xiii_gasto")!=null && !request.getParameter("xiii_gasto").trim().equals(""))
		cdo.addColValue("xiii_prop_gasto", request.getParameter("xiii_gasto"));

	if(request.getParameter("pr_acumulado")!=null && !request.getParameter("pr_acumulado").trim().equals(""))
		cdo.addColValue("prm_acumulado", request.getParameter("pr_acumulado"));

	if(request.getParameter("pr_promedio")!=null && !request.getParameter("pr_promedio").trim().equals(""))
		cdo.addColValue("prm_promedio_sem", request.getParameter("pr_promedio"));

	if(request.getParameter("anios")!=null && !request.getParameter("anios").trim().equals(""))
		cdo.addColValue("prm_anios", request.getParameter("anios"));

	if(request.getParameter("pr_valor_anios")!=null && !request.getParameter("pr_valor_anios").trim().equals(""))
		cdo.addColValue("prm_anios_valor", request.getParameter("pr_valor_anios"));

	if(request.getParameter("meses")!=null && !request.getParameter("meses").trim().equals(""))
		cdo.addColValue("prm_meses", request.getParameter("meses"));

	if(request.getParameter("pr_valor_meses")!=null && !request.getParameter("pr_valor_meses").trim().equals(""))
		cdo.addColValue("prm_meses_valor", request.getParameter("pr_valor_meses"));

	if(request.getParameter("dias")!=null && !request.getParameter("dias").trim().equals(""))
		cdo.addColValue("prm_dias", request.getParameter("dias"));

	if(request.getParameter("pr_valor_dias")!=null && !request.getParameter("pr_valor_dias").trim().equals(""))
		cdo.addColValue("prm_dias_valor", request.getParameter("pr_valor_dias"));

	if(request.getParameter("in_salario_ult6mes")!=null && !request.getParameter("in_salario_ult6mes").trim().equals(""))
		cdo.addColValue("ind_salario_ult6m", request.getParameter("in_salario_ult6mes"));

	if(request.getParameter("in_ultimo_salario")!=null && !request.getParameter("in_ultimo_salario").trim().equals(""))
		cdo.addColValue("ind_salario_ultmes", request.getParameter("in_ultimo_salario"));

	if(request.getParameter("in_promedio_sem")!=null && !request.getParameter("in_promedio_sem").trim().equals(""))
		cdo.addColValue("ind_promedio_sem", request.getParameter("in_promedio_sem"));

	if(request.getParameter("in_promedio_men")!=null && !request.getParameter("in_promedio_men").trim().equals(""))
		cdo.addColValue("ind_promedio_mes", request.getParameter("in_promedio_men"));

	if(request.getParameter("in_indemnizacion")!=null && !request.getParameter("in_indemnizacion").trim().equals(""))
		cdo.addColValue("ind_valor", request.getParameter("in_indemnizacion"));

	if(request.getParameter("in_ck_preaviso")!=null && !request.getParameter("in_ck_preaviso").trim().equals(""))
		cdo.addColValue("recibe_preaviso", request.getParameter("in_ck_preaviso"));
	else cdo.addColValue("recibe_preaviso", "N");


/*
	if(request.getParameter("ind_recargo25")!=null && !request.getParameter("ind_recargo25").trim().equals(""))
		cdo.addColValue("ind_recargo25", request.getParameter("ind_recargo25"));

	if(request.getParameter("ind_recargo50")!=null && !request.getParameter("ind_recargo50").trim().equals(""))
		cdo.addColValue("ind_recargo50", request.getParameter("ind_recargo50"));


	if(request.getParameter("in_ck_recargo25")!=null && !request.getParameter("in_ck_recargo25").trim().equals(""))
		cdo.addColValue("recibe_recargo25", request.getParameter("in_ck_recargo25"));
	else cdo.addColValue("recibe_recargo25", "N");

	if(request.getParameter("in_ck_recargo50")!=null && !request.getParameter("in_ck_recargo50").trim().equals(""))
		cdo.addColValue("recibe_recargo50", request.getParameter("in_ck_recargo50"));
	else cdo.addColValue("recibe_recargo50", "N");

	if(request.getParameter("imp_renta_xiii")!=null && !request.getParameter("imp_renta_iii").trim().equals(""))
		cdo.addColValue("imp_renta_xiii", request.getParameter("imp_renta_xiii"));

	if(request.getParameter("imp_renta_trx")!=null && !request.getParameter("imp_renta_trx").trim().equals(""))
		cdo.addColValue("imp_renta_trx", request.getParameter("imp_renta_trx"));

*/

	if(request.getParameter("in_preaviso")!=null && !request.getParameter("in_preaviso").trim().equals(""))
		cdo.addColValue("preaviso_valor", request.getParameter("in_preaviso"));

	if(request.getParameter("pr_otros_beneficios")!=null && !request.getParameter("pr_otros_beneficios").trim().equals(""))
		cdo.addColValue("ot_beneficios_valor", request.getParameter("pr_otros_beneficios"));

	if(request.getParameter("imp_ssocial")!=null && !request.getParameter("imp_ssocial").trim().equals(""))
		cdo.addColValue("imp_ssocial", request.getParameter("imp_ssocial"));

	if(request.getParameter("imp_seducat")!=null && !request.getParameter("imp_seducat").trim().equals(""))
		cdo.addColValue("imp_seducat", request.getParameter("imp_seducat"));

	if(request.getParameter("imp_renta")!=null && !request.getParameter("imp_renta").trim().equals(""))
		cdo.addColValue("imp_renta_sv", request.getParameter("imp_renta"));

	if(request.getParameter("imp_rentae")!=null && !request.getParameter("imp_rentae").trim().equals(""))
		cdo.addColValue("imp_renta_ip", request.getParameter("imp_rentae"));

	if(request.getParameter("imp_cxcemp")!=null && !request.getParameter("imp_cxcemp").trim().equals(""))
		cdo.addColValue("cxc_empleado", request.getParameter("imp_cxcemp"));

	if(request.getParameter("pr_semanas")!=null && !request.getParameter("pr_semanas").trim().equals(""))
		cdo.addColValue("prm_semanas", request.getParameter("pr_semanas"));

	if(request.getParameter("pr_ck_preaviso")!=null && !request.getParameter("pr_ck_preaviso").trim().equals(""))
		cdo.addColValue("desc_preaviso", request.getParameter("pr_ck_preaviso"));
	else cdo.addColValue("desc_preaviso", "N");

	if(request.getParameter("pr_preaviso")!=null && !request.getParameter("pr_preaviso").trim().equals(""))
		cdo.addColValue("desc_preaviso_valor", request.getParameter("pr_preaviso"));

	if(request.getParameter("imp_clinica")!=null && !request.getParameter("imp_clinica").trim().equals(""))
		cdo.addColValue("cxc_clinica", request.getParameter("imp_clinica"));

	if(request.getParameter("acum_xiii_sal")!=null && !request.getParameter("acum_xiii_sal").trim().equals(""))
		cdo.addColValue("xiii_acum_salario", request.getParameter("acum_xiii_sal"));

	if(request.getParameter("acum_xiii_gr")!=null && !request.getParameter("acum_xiii_gr").trim().equals(""))
		cdo.addColValue("xiii_acum_grep", request.getParameter("acum_xiii_gr"));

	if(request.getParameter("observacion")!=null && !request.getParameter("observacion").trim().equals(""))
		cdo.addColValue("observacion", request.getParameter("observacion"));

	if(request.getParameter("num_cheque")!=null && !request.getParameter("num_cheque").trim().equals(""))
		cdo.addColValue("num_cheque", request.getParameter("num_cheque"));

	if(request.getParameter("fecha_ingreso")!=null && !request.getParameter("fecha_ingreso").trim().equals(""))
		cdo.addColValue("fecha_ingreso", request.getParameter("fecha_ingreso"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add")){
		AEmpMgr.addLiquidacion(cdo);
	} else {
		AEmpMgr.updLiquidacion(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(mode,indTap)
{
<%
if (AEmpMgr.getErrCode().equals("1"))
{
%>
	alert('<%=AEmpMgr.getErrMsg()%>');

	if(mode=='edit' || mode=='add' ){
		window.location = '<%=request.getContextPath()+"/rhplanilla/reg_liquidacion.jsp?mode=edit&emp_id="+emp_id+"&indTab="%>'+indTap+'&liq_fecha_egreso=<%=request.getParameter("fecha_egreso")%>&fecha_egreso=<%=request.getParameter("fecha_egreso")%>';
	}
	<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_liquidaciones.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_liquidaciones.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_liquidaciones.jsp';
<%
	}
%>
//window.close();
<%
} else throw new Exception(AEmpMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow('<%=mode%>','<%=indTab%>')">
</body>
</html>
<%
}//POST
%>