<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />
<%
/**
sct0230a
==================================================================================
sct0230s
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String aprobada = request.getParameter("aprobada");
String grupo = request.getParameter("grupo");
String uf_codigo = request.getParameter("uf_codigo");
boolean viewMode = false;
int lineNo = 0;
System.out.println("mes="+mes);
CommonDataObject cdoDM = new CommonDataObject();
int cHeight = 30;

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;

if (aprobada == null) aprobada = "";
if (fp.equalsIgnoreCase("consulta_x_grupo")) {
	if (!aprobada.trim().equals("")) {
		sbFilter.append(" and a.aprobado = '");
		sbFilter.append(aprobada);
		sbFilter.append("'");
	}
}
if (uf_codigo == null)  uf_codigo = "0"; 
if (request.getMethod().equalsIgnoreCase("GET"))
{   
	if (change ==null) emp.clear();
	if(anio != null && mes != null){
	CommonDataObject cdUD = SQLMgr.getData("select to_number(to_char(last_day(to_date('01/'||to_char("+mes+", '09')||'/'||'"+anio+"', 'DD/MM/YYYY')), 'DD')) ud from dual");
		int ult_dia = Integer.parseInt(cdUD.getColValue("ud"));
		sbSql = new StringBuffer();
		sbSql.append("select ");
		for (int i=1; i<=ult_dia; i++) {
			if (i != 1) sbSql.append(", ");
			sbSql.append("to_char(to_date(");
			sbSql.append(i);
			sbSql.append("||'/'||");
			sbSql.append(mes);
			sbSql.append("||'/'||");
			sbSql.append(anio);
			sbSql.append(",'dd/mm/yyyy'),'FMDY DD','NLS_DATE_LANGUAGE=SPANISH') as dtext_");
			sbSql.append(i);
		}
		sbSql.append(" from dual");
		cdoDM = SQLMgr.getData(sbSql.toString());
		}
		if (cdoDM==null) cdoDM = new CommonDataObject();
	
	if(anio != null && mes != null && grupo != null  && change == null){
		

		sbSql = new StringBuffer();
		sbSql.append("select a.provincia, a.sigla, a.tomo, a.asiento, a.num_empleado, a.compania, a.anio, a.mes, a.dia1, a.dia2, a.dia3, a.dia4, a.dia5, a.dia6, a.dia7, a.dia8, a.dia9, a.dia10, a.dia11, a.dia12, a.dia13, a.dia14, a.dia15, a.dia16, a.dia17, a.dia18, a.dia19, a.dia20, a.dia21, a.dia22, a.dia23, a.dia24, a.dia25, a.dia26, a.dia27, a.dia28, a.dia29, a.dia30, a.dia31, a.uf_dia1, a.uf_dia2, a.uf_dia3, a.uf_dia4, a.uf_dia5, a.uf_dia6, a.uf_dia7, a.uf_dia8, a.uf_dia9, a.uf_dia10, a.uf_dia11, a.uf_dia12, a.uf_dia13, a.uf_dia14, a.uf_dia15, a.uf_dia16, a.uf_dia17, a.uf_dia18, a.uf_dia19, a.uf_dia20, a.uf_dia21, a.uf_dia22, a.uf_dia23, a.uf_dia24, a.uf_dia25, a.uf_dia26, a.uf_dia27, a.uf_dia28, a.uf_dia29, a.uf_dia30, a.uf_dia31, a.grupo, t.ubicacion_fisica, a.emp_id, to_char(a.fecha_creacion, 'dd/mm/yyyy') as fecha_creacion, a.usuario_creacion");
		sbSql.append(", b.primer_nombre||case when b.sexo = 'F' and b.apellido_casada is not null and b.usar_apellido_casada = 'S' then ' DE '||b.apellido_casada else ' '||b.primer_apellido end as nombre");
		sbSql.append(", (case when c.periodof_inicio < to_date('01/"+mes+"/"+anio+"', 'DD/MM/YYYY') then '01/"+mes+"/"+anio+"' else to_char(c.periodof_inicio, 'DD/MM/YYYY') end) vac_fi_ciclo, (case when c.periodof_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then to_char(last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')), 'dd/mm/yyyy') else to_char(c.periodof_final, 'DD/MM/YYYY') end) vac_ff_fciclo, (case when c.periodof_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) else c.periodof_final end - case when c.periodof_inicio < to_date('01/"+mes+"/"+anio+"', 'DD/MM/YYYY') then to_date('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') else c.periodof_inicio end) vac_dias_ciclo");
		sbSql.append(", (case when d.fecha_inicio < to_date ('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') then '01/"+mes+"/"+anio+"' else to_char(d.fecha_inicio, 'dd/mm/yyyy') end) liq_f_inicio, (case when d.fecha_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then to_char(last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')), 'dd/mm/yyyy') else to_char(d.fecha_final, 'dd/mm/yyyy') end) liq_f_final, (case when d.fecha_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) else d.fecha_final end - case when d.fecha_inicio < to_date('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') then to_date('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') else d.fecha_inicio end) liq_dias_ciclo");
		sbSql.append(", getTurno(to_char(a.dia1), a.compania) dsp_dia1, getTurno(to_char(a.dia2), a.compania) dsp_dia2, getTurno(to_char(a.dia3), a.compania) dsp_dia3, getTurno(to_char(a.dia4), a.compania) dsp_dia4, getTurno(to_char(a.dia5), a.compania) dsp_dia5, getTurno(to_char(a.dia6), a.compania) dsp_dia6, getTurno(to_char(a.dia7), a.compania) dsp_dia7, getTurno(to_char(a.dia8), a.compania) dsp_dia8, getTurno(to_char(a.dia9), a.compania) dsp_dia9, getTurno(to_char(a.dia10), a.compania) dsp_dia10, getTurno(to_char(a.dia11), a.compania) dsp_dia11, getTurno(to_char(a.dia12), a.compania) dsp_dia12, getTurno(to_char(a.dia13), a.compania) dsp_dia13, getTurno(to_char(a.dia14), a.compania) dsp_dia14, getTurno(to_char(a.dia15), a.compania) dsp_dia15, getTurno(to_char(a.dia16), a.compania) dsp_dia16, getTurno(to_char(a.dia17), a.compania) dsp_dia17, getTurno(to_char(a.dia18), a.compania) dsp_dia18, getTurno(to_char(a.dia19), a.compania) dsp_dia19, getTurno(to_char(a.dia20), a.compania) dsp_dia20, getTurno(to_char(a.dia21), a.compania) dsp_dia21, getTurno(to_char(a.dia22), a.compania) dsp_dia22, getTurno(to_char(a.dia23), a.compania) dsp_dia23, getTurno(to_char(a.dia24), a.compania) dsp_dia24, getTurno(to_char(a.dia25), a.compania) dsp_dia25, getTurno(to_char(a.dia26), a.compania) dsp_dia26, getTurno(to_char(a.dia27), a.compania) dsp_dia27, getTurno(to_char(a.dia28), a.compania) dsp_dia28, getTurno(to_char(a.dia29), a.compania) dsp_dia29, getTurno(to_char(a.dia30), a.compania) dsp_dia30, getTurno(to_char(a.dia31), a.compania) dsp_dia31");
		sbSql.append(", getUbicacionF(to_char(a.uf_dia1), a.compania, a.grupo) dsp_uf_dia1, getUbicacionF(to_char(a.uf_dia2), a.compania, a.grupo) dsp_uf_dia2, getUbicacionF(to_char(a.uf_dia3), a.compania, a.grupo) dsp_uf_dia3, getUbicacionF(to_char(a.uf_dia4), a.compania, a.grupo) dsp_uf_dia4, getUbicacionF(to_char(a.uf_dia5), a.compania, a.grupo) dsp_uf_dia5, getUbicacionF(to_char(a.uf_dia6), a.compania, a.grupo) dsp_uf_dia6, getUbicacionF(to_char(a.uf_dia7), a.compania, a.grupo) dsp_uf_dia7, getUbicacionF(to_char(a.uf_dia8), a.compania, a.grupo) dsp_uf_dia8, getUbicacionF(to_char(a.uf_dia9), a.compania, a.grupo) dsp_uf_dia9, getUbicacionF(to_char(a.uf_dia10), a.compania, a.grupo) dsp_uf_dia10, getUbicacionF(to_char(a.uf_dia11), a.compania, a.grupo) dsp_uf_dia11, getUbicacionF(to_char(a.uf_dia12), a.compania, a.grupo) dsp_uf_dia12, getUbicacionF(to_char(a.uf_dia13), a.compania, a.grupo) dsp_uf_dia13, getUbicacionF(to_char(a.uf_dia14), a.compania, a.grupo) dsp_uf_dia14, getUbicacionF(to_char(a.uf_dia15), a.compania, a.grupo) dsp_uf_dia15, getUbicacionF(to_char(a.uf_dia16), a.compania, a.grupo) dsp_uf_dia16, getUbicacionF(to_char(a.uf_dia17), a.compania, a.grupo) dsp_uf_dia17, getUbicacionF(to_char(a.uf_dia18), a.compania, a.grupo) dsp_uf_dia18, getUbicacionF(to_char(a.uf_dia19), a.compania, a.grupo) dsp_uf_dia19, getUbicacionF(to_char(a.uf_dia20), a.compania, a.grupo) dsp_uf_dia20, getUbicacionF(to_char(a.uf_dia21), a.compania, a.grupo) dsp_uf_dia21, getUbicacionF(to_char(a.uf_dia22), a.compania, a.grupo) dsp_uf_dia22, getUbicacionF(to_char(a.uf_dia23), a.compania, a.grupo) dsp_uf_dia23, getUbicacionF(to_char(a.uf_dia24), a.compania, a.grupo) dsp_uf_dia24, getUbicacionF(to_char(a.uf_dia25), a.compania, a.grupo) dsp_uf_dia25, getUbicacionF(to_char(a.uf_dia26), a.compania, a.grupo) dsp_uf_dia26, getUbicacionF(to_char(a.uf_dia27), a.compania, a.grupo) dsp_uf_dia27, getUbicacionF(to_char(a.uf_dia28), a.compania, a.grupo) dsp_uf_dia28, getUbicacionF(to_char(a.uf_dia29), a.compania, a.grupo) dsp_uf_dia29, getUbicacionF(to_char(a.uf_dia30), a.compania, a.grupo) dsp_uf_dia30, getUbicacionF(to_char(a.uf_dia31), a.compania, a.grupo) dsp_uf_dia31");
		sbSql.append(" from tbl_pla_ct_tprograma a, tbl_pla_empleado b, tbl_pla_ct_empleado t");
		sbSql.append(", (select distinct emp_id, num_empleado, to_date(to_char(periodof_inicio, 'dd/mm/yyyy'), 'dd/mm/yyyy') periodof_inicio, to_date(to_char(periodof_final, 'dd/mm/yyyy'), 'dd/mm/yyyy') periodof_final from tbl_pla_sol_vacacion where compania = "+(String) session.getAttribute("_companyId")+" and ((to_date('01/"+mes+"/"+anio+"', 'dd/MM/YYYY') >= periodof_inicio and to_date('01/"+mes+"/"+anio+"', 'dd/MM/YYYY') <= periodof_final) or (last_day(to_date('01/"+mes+"/"+anio+"', 'dd/MM/YYYY')) >= periodof_inicio and last_day(to_date ('01/"+mes+"/"+anio+"', 'dd/MM/YYYY')) <= periodof_final)) and estado not in ('RE', 'AN')) c");
		sbSql.append(", (select distinct emp_id, to_date(to_char(fecha_inicio, 'dd/mm/yyyy'), 'dd/mm/yyyy') fecha_inicio, to_date(to_char(fecha_final, 'dd/mm/yyyy'), 'dd/mm/yyyy') fecha_final from tbl_pla_cc_licencia where compania = "+(String) session.getAttribute("_companyId")+" and ((fecha_inicio <= last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY'))) and (fecha_final >= (to_date('01/"+mes+"/"+anio+"', 'DD/MM/YYYY'))) and fecha_retorno is null) and motivo_falta = 37) d");
		sbSql.append(" where a.emp_id = b.emp_id"+sbFilter+" and a.anio = "+anio+" and a.mes = "+mes+" and a.grupo = "+grupo+" and (a.emp_id, a.num_empleado, a.compania) in (select emp_id, num_empleado, compania from tbl_pla_ct_empleado where grupo = "+grupo+" and to_char(ubicacion_fisica) = decode('"+uf_codigo+"','0',to_char(ubicacion_fisica),'"+uf_codigo+"') and compania = "+(String) session.getAttribute("_companyId")+" and estado <> 3 and (fecha_egreso_grupo is null or (fecha_egreso_grupo > last_day (to_date ('01/' || "+mes+" || '/' || "+anio+", 'DD/MM/YYYY'))))) and a.emp_id = c.emp_id(+) and a.num_empleado = c.num_empleado(+) and a.emp_id = d.emp_id(+) and t.estado = 1 and a.emp_id = t.emp_id(+)");
		//System.out.println("SQL TPR=\n"+sbSql);
		al = SQLMgr.getDataList(sbSql.toString());
		
		for(int i=0;i<al.size();i++){
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				emp.put(key, cdo);
				empKey.put(cdo.getColValue("emp_id"), key);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		}
	}
	//fp="emp_otros_pagos";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
function doAction(){
	var fg				= document.form.fg.value;
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	//setTextValues();
	<%
	if(change==null){
	%>
	//setDetValues();
	//setVacaciones();
	<%
	}
	%>
}

function selTurno(name){
	<%
	if(!fp.equals("consulta_x_grupo")){
	%>
	abrir_ventana('../common/search_turno.jsp?fp=programa_turno_borrador&index='+name);
	<%
	}
	%>
}

function selUbicacion(name){
	var grupo = parent.document.form1.grupo.value;
	<%
	if(!fp.equals("consulta_x_grupo")){
	%>
	abrir_ventana('../common/search_area.jsp?fp=programa_turno_borrador&index='+name+'&grupo='+grupo);
	<%
	}
	%>
}


function doSubmit(action){
	document.form.baction.value 			= action;
	document.form.anio.value 				= parent.document.form1.anio.value;
	document.form.mes.value 				= parent.document.form1.mes.value;
	document.form.grupo.value 		= parent.document.form1.grupo.value;
	document.form.uf_codigo.value 	= parent.document.form1.uf_codigo.value;

	if(!parent.form1Validation()){}
	else {
		if(action != 'Guardar') parent.form1BlockButtons(false);
		if(action == 'Guardar' && !formValidation()){
			parent.form1BlockButtons(false);
		}else {
			formBlockButtons(false);
			document.form.submit();
		}
	}
}

function setTextValues(){
	var mes = parent.document.form1.mes.value;
	var anio = parent.document.form1.anio.value;
	if(mes != '' && anio != ''){
		var ult_dia = 	getDBData('<%=request.getContextPath()%>','to_number(to_char(last_day(to_date(\'01/\'||to_char('+mes+', \'09\')||\'/\'||'+anio+', \'DD/MM/YYYY\')), \'DD\'))','dual','','');
		var sql = '';
		for(i=1;i<=ult_dia;i++){
			sql += 'to_char(to_date('+i+'||\'/\'||to_char('+mes+', \'09\')||\'/\'||'+anio+', \'DD/MM/YYYY\'), \'FMDY DD\', \'NLS_DATE_LANGUAGE=SPANISH\')';
			if(i!=ult_dia) sql += ', ';
		}
		for(i=1;i<=31;i++){
			eval('document.form.dtext_'+i).value	= '';
		}
		sql = 	getDBData('<%=request.getContextPath()%>',sql,'dual','','');
		var arr_cursor = new Array();
		if(sql!=''){
			arr_cursor = splitCols(sql);
			for(i=1;i<=ult_dia;i++){
				var valor = arr_cursor[i-1];
				if(valor.substring(0, 3)=='SÁB' || valor.substring(0, 3) == 'DOM'){
					eval('document.form.dtext_'+i).className = 'FormRedTextBox';
				}
				eval('document.form.dtext_'+i).value	= valor;
			}
		}
	}
}

function setDetValues(){
	var size = <%=al.size()%>;
	var grupo = parent.document.form1.grupo.value;
	for(j=0;j<size;j++){
		var sql = '', uf_sql = '';
		for(i=1;i<=31;i++){
			var dia = eval('document.form.dia'+i+'_'+j).value;
			var uf_dia = eval('document.form.uf_dia'+i+'_'+j).value;
			if(dia!=''){
				var xdata = '';
				if(i!=1) sql += ' union ';
				if(dia == 'A') xdata = '\'Ausencia\' b from dual';
				else if(dia == 'LC') xdata = '\'Libre Compensatorio\' b from dual';
				else if(dia == 'LS') xdata = '\'Libre Semanal\' b from dual';
				else if(dia == 'N') xdata = '\'Nacional\' b from dual';
				else if(dia == 'PC') xdata = '\'Permiso con Sueldo\' b from dual';
				else if(dia == 'PS') xdata = '\'Permiso sin sueldo\' b from dual';
				else if(dia == 'HD') xdata = '\'Horas de Descanso\' b from dual';
				else if(dia == 'I') xdata = '\'Incapacidad\' b from dual';
				else if(dia == 'LG') xdata = '\'Lic. por Gravidez\' b from dual';
				else if(dia == 'V') xdata = '\'Vacaciones\' b from dual';
				else if(dia == 'RP') xdata = '\'Riesgo Profesional\' b from dual';
				else xdata = 'to_char(hora_entrada, \'hh:mi\')||\'/\'||to_char(hora_salida, \'hh:mi\') b from tbl_pla_ct_turno where to_char(codigo) = \''+dia+'\' and compania = <%=(String) session.getAttribute("_companyId")%>';

				sql += 'select \'dsp_dia'+i+'_'+j+'\' a, ' + xdata;
			}
			if(uf_dia!=''){
				if(i!=1) uf_sql += ' union ';
				uf_sql += 'select \'dsp_uf_d'+i+'_'+j+'\' a, abreviatura b from tbl_pla_ct_area_x_grupo where to_char(codigo) = \''+uf_dia+'\' and grupo = '+grupo+' and compania = <%=(String) session.getAttribute("_companyId")%>';
			}
		}
		sql = getDBData('<%=request.getContextPath()%>','a, b','('+sql+uf_sql+')','','');
		var arr_cursor = new Array();
		if(sql!=''){
			arr_cursor = splitRowsCols(sql);
			for(i=0;i<arr_cursor.length;i++){
				var x = arr_cursor[i];
				if(i<32){
					eval('document.form.'+x[0]).value	= x[1];
				} else {
					eval('document.form.'+x[0]).value	= x[1];
				}
			}
		}
	}
}

function setVacaciones(){
	var size = <%=al.size()%>;
	for(i=0;i<size;i++){
		var fecha_inicio = eval('document.form.vac_fi_ciclo_'+i).value
		if(fecha_inicio!=''){
			var dias = eval('document.form.vac_dias_ciclo_'+i).value;
			var sql = '';
			if(dias!=''){
				for(j=0;j<dias;j++){
					if(j==0) sql = 'to_char(to_date(\''+fecha_inicio+'\', \'dd/mm/yyyy\'), \'dd\'), ';
					sql += 'to_date(\''+fecha_inicio+'\', \'dd/mm/yyyy\') + '+j;
					if(j+1!=dias) sql += ', ';
				}
				sql = getDBData('<%=request.getContextPath()%>',sql,'dual','','');
				var arr_cursor = new Array();
				if(sql!=''){
					arr_cursor = splitCols(sql);
					var index = parseInt(arr_cursor[0]);
					for(j=0;j<dias;j++){
						if(eval('document.form.dia'+index+'_'+i).value==''){
							eval('document.form.dia'+index+'_'+i).value = 'V';
							eval('document.form.dsp_dia'+index+'_'+i).value = 'V';
							index += j;
						}
					}
				}
			}
		}
	}
}

function setIndex(dia, i, flag){
	//if(eval('document.form.dsp_dia1_'+i).value!=''){
		parent.document.form1.dia.value=dia;
		parent.document.form1.index.value=i;
		parent.document.form1.flag.value=flag;
	//}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" align="center" cellpadding="0" cellspacing="0">
<%fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("mes","")%>
<%=fb.hidden("grupo","")%>
<%=fb.hidden("uf_codigo","")%>
<tr>
	<td width="24%">
		<table width="100%" align="center" cellpadding="1" cellspacing="1">
		<tr class="TextHeader02" height="<%=cHeight%>">
			<td align="center">Empleado</td>
		</tr>
<%
if (emp.size() > 0) al = CmnMgr.reverseRecords(emp);
for (int i=0; i<emp.size(); i++) {
    key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) emp.get(key);

	String color = "";
	if (i%2 == 0) color = "TextHeader02";
	else color = "TextHeader01";
	boolean readonly = true;
%>
		<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
		<%=fb.hidden("nombre_empleado"+i,cdo.getColValue("nombre_empleado"))%>
		<%=fb.hidden("grupo"+i,cdo.getColValue("grupo"))%>
		<%=fb.hidden("ubicacion_fisica"+i,cdo.getColValue("ubicacion_fisica"))%>
		<%=fb.hidden("prioridad"+i,cdo.getColValue("prioridad"))%>
		<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
		<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
		<%=fb.hidden("dia1_"+i,cdo.getColValue("dia1"))%>
		<%=fb.hidden("dia2_"+i,cdo.getColValue("dia2"))%>
		<%=fb.hidden("dia3_"+i,cdo.getColValue("dia3"))%>
		<%=fb.hidden("dia4_"+i,cdo.getColValue("dia4"))%>
		<%=fb.hidden("dia5_"+i,cdo.getColValue("dia5"))%>
		<%=fb.hidden("dia6_"+i,cdo.getColValue("dia6"))%>
		<%=fb.hidden("dia7_"+i,cdo.getColValue("dia7"))%>
		<%=fb.hidden("dia8_"+i,cdo.getColValue("dia8"))%>
		<%=fb.hidden("dia9_"+i,cdo.getColValue("dia9"))%>
		<%=fb.hidden("dia10_"+i,cdo.getColValue("dia10"))%>
		<%=fb.hidden("dia11_"+i,cdo.getColValue("dia11"))%>
		<%=fb.hidden("dia12_"+i,cdo.getColValue("dia12"))%>
		<%=fb.hidden("dia13_"+i,cdo.getColValue("dia13"))%>
		<%=fb.hidden("dia14_"+i,cdo.getColValue("dia14"))%>
		<%=fb.hidden("dia15_"+i,cdo.getColValue("dia15"))%>
		<%=fb.hidden("dia16_"+i,cdo.getColValue("dia16"))%>
		<%=fb.hidden("dia17_"+i,cdo.getColValue("dia17"))%>
		<%=fb.hidden("dia18_"+i,cdo.getColValue("dia18"))%>
		<%=fb.hidden("dia19_"+i,cdo.getColValue("dia19"))%>
		<%=fb.hidden("dia20_"+i,cdo.getColValue("dia20"))%>
		<%=fb.hidden("dia21_"+i,cdo.getColValue("dia21"))%>
		<%=fb.hidden("dia22_"+i,cdo.getColValue("dia22"))%>
		<%=fb.hidden("dia23_"+i,cdo.getColValue("dia23"))%>
		<%=fb.hidden("dia24_"+i,cdo.getColValue("dia24"))%>
		<%=fb.hidden("dia25_"+i,cdo.getColValue("dia25"))%>
		<%=fb.hidden("dia26_"+i,cdo.getColValue("dia26"))%>
		<%=fb.hidden("dia27_"+i,cdo.getColValue("dia27"))%>
		<%=fb.hidden("dia28_"+i,cdo.getColValue("dia28"))%>
		<%=fb.hidden("dia29_"+i,cdo.getColValue("dia29"))%>
		<%=fb.hidden("dia30_"+i,cdo.getColValue("dia30"))%>
		<%=fb.hidden("dia31_"+i,cdo.getColValue("dia31"))%>
		<%=fb.hidden("vac_fi_ciclo_"+i,cdo.getColValue("vac_fi_ciclo"))%>
		<%=fb.hidden("vac_ff_ciclo_"+i,cdo.getColValue("vac_ff_ciclo"))%>
		<%=fb.hidden("vac_dias_ciclo_"+i,cdo.getColValue("vac_dias_ciclo"))%>
		<%=fb.hidden("liq_f_inicio_"+i,cdo.getColValue("liq_f_inicio"))%>
		<%=fb.hidden("liq_f_final_"+i,cdo.getColValue("liq_f_final"))%>
		<%=fb.hidden("liq_dias_ciclo_"+i,cdo.getColValue("liq_dias_ciclo"))%>
		<%=fb.hidden("uf_dia1_"+i,cdo.getColValue("uf_dia1"))%>
		<%=fb.hidden("uf_dia2_"+i,cdo.getColValue("uf_dia2"))%>
		<%=fb.hidden("uf_dia3_"+i,cdo.getColValue("uf_dia3"))%>
		<%=fb.hidden("uf_dia4_"+i,cdo.getColValue("uf_dia4"))%>
		<%=fb.hidden("uf_dia5_"+i,cdo.getColValue("uf_dia5"))%>
		<%=fb.hidden("uf_dia6_"+i,cdo.getColValue("uf_dia6"))%>
		<%=fb.hidden("uf_dia7_"+i,cdo.getColValue("uf_dia7"))%>
		<%=fb.hidden("uf_dia8_"+i,cdo.getColValue("uf_dia8"))%>
		<%=fb.hidden("uf_dia9_"+i,cdo.getColValue("uf_dia9"))%>
		<%=fb.hidden("uf_dia10_"+i,cdo.getColValue("uf_dia10"))%>
		<%=fb.hidden("uf_dia11_"+i,cdo.getColValue("uf_dia11"))%>
		<%=fb.hidden("uf_dia12_"+i,cdo.getColValue("uf_dia12"))%>
		<%=fb.hidden("uf_dia13_"+i,cdo.getColValue("uf_dia13"))%>
		<%=fb.hidden("uf_dia14_"+i,cdo.getColValue("uf_dia14"))%>
		<%=fb.hidden("uf_dia15_"+i,cdo.getColValue("uf_dia15"))%>
		<%=fb.hidden("uf_dia16_"+i,cdo.getColValue("uf_dia16"))%>
		<%=fb.hidden("uf_dia17_"+i,cdo.getColValue("uf_dia17"))%>
		<%=fb.hidden("uf_dia18_"+i,cdo.getColValue("uf_dia18"))%>
		<%=fb.hidden("uf_dia19_"+i,cdo.getColValue("uf_dia19"))%>
		<%=fb.hidden("uf_dia20_"+i,cdo.getColValue("uf_dia20"))%>
		<%=fb.hidden("uf_dia21_"+i,cdo.getColValue("uf_dia21"))%>
		<%=fb.hidden("uf_dia22_"+i,cdo.getColValue("uf_dia22"))%>
		<%=fb.hidden("uf_dia23_"+i,cdo.getColValue("uf_dia23"))%>
		<%=fb.hidden("uf_dia24_"+i,cdo.getColValue("uf_dia24"))%>
		<%=fb.hidden("uf_dia25_"+i,cdo.getColValue("uf_dia25"))%>
		<%=fb.hidden("uf_dia26_"+i,cdo.getColValue("uf_dia26"))%>
		<%=fb.hidden("uf_dia27_"+i,cdo.getColValue("uf_dia27"))%>
		<%=fb.hidden("uf_dia28_"+i,cdo.getColValue("uf_dia28"))%>
		<%=fb.hidden("uf_dia29_"+i,cdo.getColValue("uf_dia29"))%>
		<%=fb.hidden("uf_dia30_"+i,cdo.getColValue("uf_dia30"))%>
		<%=fb.hidden("uf_dia31_"+i,cdo.getColValue("uf_dia31"))%>
		<tr class="<%=color%>" align="center" height="<%=cHeight%>" valign="bottom">
			<td>
				<%=fb.textBox("num_empleado"+i,cdo.getColValue("num_empleado"),false,false,true,3,"Text09","","")%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<%=fb.textBox("provincia"+i,cdo.getColValue("provincia"),false,false,true,1,"Text09","","")%>
				<%=fb.textBox("sigla"+i,cdo.getColValue("sigla"),false,false,true,1,"Text09","","")%>
				<%=fb.textBox("tomo"+i,cdo.getColValue("tomo"),false,false,true,1,"Text09","","")%>
				<%=fb.textBox("asiento"+i,cdo.getColValue("asiento"),false,false,true,3,"Text09","","")%>
			</td>
		</tr>
		<tr class="<%=color%>" align="center" height="<%=cHeight%>" valign="top">
			<td><%=fb.textBox("nombre"+i,cdo.getColValue("nombre"),false,false,true,35,"Text09","","")%></td>
		</tr>
<% } %>
		</table>
	</td>
	<td id="col_1_15" width="73%">
		<table width="100%" align="center" cellpadding="1" cellspacing="1">
		<tr class="TextHeader02" align="center" height="<%=cHeight%>">
			<td><%=fb.textBox("dtext_1",cdoDM.getColValue("dtext_1"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_2",cdoDM.getColValue("dtext_2"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_3",cdoDM.getColValue("dtext_3"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_4",cdoDM.getColValue("dtext_4"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_5",cdoDM.getColValue("dtext_5"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_6",cdoDM.getColValue("dtext_6"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_7",cdoDM.getColValue("dtext_7"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_8",cdoDM.getColValue("dtext_8"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_9",cdoDM.getColValue("dtext_9"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_10",cdoDM.getColValue("dtext_10"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_11",cdoDM.getColValue("dtext_11"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_12",cdoDM.getColValue("dtext_12"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_13",cdoDM.getColValue("dtext_13"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_14",cdoDM.getColValue("dtext_14"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_15",cdoDM.getColValue("dtext_15"),false,false,true,5,"Text09","","")%></td>
		</tr>
<%
if (emp.size() > 0) al = CmnMgr.reverseRecords(emp);
for (int i=0; i<emp.size(); i++){
	key = al.get(i).toString();									  
	CommonDataObject cdo = (CommonDataObject) emp.get(key);

	String color = "";
	if (i%2 == 0) color = "TextHeader02";
	else color = "TextHeader01";
	boolean readonly = true;
%>
		<tr class="<%=color%>" align="center" height="<%=cHeight%>" valign="bottom">
			<td><%=fb.textBox("dsp_dia1_"+i,cdo.getColValue("dsp_dia1"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(1,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia2_"+i,cdo.getColValue("dsp_dia2"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(2,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia3_"+i,cdo.getColValue("dsp_dia3"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(3,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia4_"+i,cdo.getColValue("dsp_dia4"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(4,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia5_"+i,cdo.getColValue("dsp_dia5"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(5,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia6_"+i,cdo.getColValue("dsp_dia6"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(6,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia7_"+i,cdo.getColValue("dsp_dia7"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(7,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia8_"+i,cdo.getColValue("dsp_dia8"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(8,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia9_"+i,cdo.getColValue("dsp_dia9"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(9,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia10_"+i,cdo.getColValue("dsp_dia10"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(10,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia11_"+i,cdo.getColValue("dsp_dia11"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(11,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia12_"+i,cdo.getColValue("dsp_dia12"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(12,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia13_"+i,cdo.getColValue("dsp_dia13"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(13,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia14_"+i,cdo.getColValue("dsp_dia14"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(14,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia15_"+i,cdo.getColValue("dsp_dia15"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(15,"+i+",'d');\"")%></td>
		</tr>
		<tr class="<%=color%>" align="center" height="<%=cHeight%>" valign="top">
			<td><%=fb.textBox("dsp_uf_dia1_"+i,cdo.getColValue("dsp_uf_dia1"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(1,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia2_"+i,cdo.getColValue("dsp_uf_dia2"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(2,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia3_"+i,cdo.getColValue("dsp_uf_dia3"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(3,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia4_"+i,cdo.getColValue("dsp_uf_dia4"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(4,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia5_"+i,cdo.getColValue("dsp_uf_dia5"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(5,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia6_"+i,cdo.getColValue("dsp_uf_dia6"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(6,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia7_"+i,cdo.getColValue("dsp_uf_dia7"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(7,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia8_"+i,cdo.getColValue("dsp_uf_dia8"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(8,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia9_"+i,cdo.getColValue("dsp_uf_dia9"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(9,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia10_"+i,cdo.getColValue("dsp_uf_dia10"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(10,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia11_"+i,cdo.getColValue("dsp_uf_dia11"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(11,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia12_"+i,cdo.getColValue("dsp_uf_dia12"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(12,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia13_"+i,cdo.getColValue("dsp_uf_dia13"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(13,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia14_"+i,cdo.getColValue("dsp_uf_dia14"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(14,"+i+",'u')\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia15_"+i,cdo.getColValue("dsp_uf_dia15"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(15,"+i+",'u')\"")%></td>
		</tr>
<% } %>
		</table>
	</td>
	<td id="col_16_31" style="display:none">
		<table width="100%" align="center" cellpadding="1" cellspacing="1">
		<tr class="TextHeader02" align="center" height="<%=cHeight%>">
			<td><%=fb.textBox("dtext_16",cdoDM.getColValue("dtext_16"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_17",cdoDM.getColValue("dtext_17"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_18",cdoDM.getColValue("dtext_18"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_19",cdoDM.getColValue("dtext_19"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_20",cdoDM.getColValue("dtext_20"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_21",cdoDM.getColValue("dtext_21"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_22",cdoDM.getColValue("dtext_22"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_23",cdoDM.getColValue("dtext_23"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_24",cdoDM.getColValue("dtext_24"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_25",cdoDM.getColValue("dtext_25"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_26",cdoDM.getColValue("dtext_26"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_27",cdoDM.getColValue("dtext_27"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_28",cdoDM.getColValue("dtext_28"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_29",cdoDM.getColValue("dtext_29"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_30",cdoDM.getColValue("dtext_30"),false,false,true,5,"Text09","","")%></td>
			<td><%=fb.textBox("dtext_31",cdoDM.getColValue("dtext_31"),false,false,true,5,"Text09","","")%></td>
		</tr>
<%
if (emp.size() > 0) al= CmnMgr.reverseRecords(emp);
for (int i=0; i<emp.size(); i++){
	key = al.get(i).toString();									  
	CommonDataObject cdo = (CommonDataObject) emp.get(key);

	String color = "";
	if (i%2 == 0) color = "TextHeader02";
	else color = "TextHeader01";
	boolean readonly = true;
%>
		<tr class="<%=color%>" align="center" height="<%=cHeight%>" valign="bottom">
			<td><%=fb.textBox("dsp_dia16_"+i,cdo.getColValue("dsp_dia16"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(16,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia17_"+i,cdo.getColValue("dsp_dia17"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(17,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia18_"+i,cdo.getColValue("dsp_dia18"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(18,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia19_"+i,cdo.getColValue("dsp_dia19"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(19,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia20_"+i,cdo.getColValue("dsp_dia20"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(20,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia21_"+i,cdo.getColValue("dsp_dia21"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(21,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia22_"+i,cdo.getColValue("dsp_dia22"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(22,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia23_"+i,cdo.getColValue("dsp_dia23"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(23,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia24_"+i,cdo.getColValue("dsp_dia24"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(24,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia25_"+i,cdo.getColValue("dsp_dia25"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(25,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia26_"+i,cdo.getColValue("dsp_dia26"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(26,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia27_"+i,cdo.getColValue("dsp_dia27"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(27,"+i+",'d');\"")%></td>
			<td><%=fb.textBox("dsp_dia28_"+i,cdo.getColValue("dsp_dia28"),false,false,true,7,"Text09","","onDblClick=\"javascript:selTurno(this.name);\" onClick=\"javascript:setIndex(28,"+i+",'d');\"")%></td>
			
			
			<td><input type="text" id="dsp_dia29_<%=i%>" name="dsp_dia29_<%=i%>" value="<%=cdo.getColValue("dsp_dia29")%>" readonly class="Text09 FormDataObjectDisabled" onDblClick="<%=cdoDM.getColValue("dtext_29") != null ?"onDblClick=selTurno(this.name)":""%>" onClick="<%=cdoDM.getColValue("dtext_29") != null? "onDblClick=setIndex(29,"+i+",'d')":""%>" size="7"></td>
			<td>
			<input type="text" id="dsp_dia30_<%=i%>" name="dsp_dia30_<%=i%>" value="<%=cdo.getColValue("dsp_dia30")%>" readonly class="Text09 FormDataObjectDisabled" onDblClick="<%=cdoDM.getColValue("dtext_30") != null? "onDblClick=selTurno(this.name)":""%>" onClick="<%=cdoDM.getColValue("dtext_30") != null? "onDblClick=setIndex(30,"+i+",'d')":""%>" size="7"></td>
			<td>
			<input type="text" id="dsp_dia31_<%=i%>" name="dsp_dia31_<%=i%>" value="<%=cdo.getColValue("dsp_dia31")%>" readonly class="Text09 FormDataObjectDisabled" onDblClick="<%=cdoDM.getColValue("dtext_31") != null? "onDblClick=selTurno(this.name)":""%>" onClick="<%=cdoDM.getColValue("dtext_31") != null? "onDblClick=setIndex(31,"+i+",'d')":""%>" size="7"></td>

		</tr>
		<tr class="<%=color%>" align="center" height="<%=cHeight%>" valign="top">
			<td><%=fb.textBox("16_"+i,cdo.getColValue("dsp_uf_dia16"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(16,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia17_"+i,cdo.getColValue("dsp_uf_dia17"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(17,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia18_"+i,cdo.getColValue("dsp_uf_dia18"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(18,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia19_"+i,cdo.getColValue("dsp_uf_dia19"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(19,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia20_"+i,cdo.getColValue("dsp_uf_dia20"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(20,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia21_"+i,cdo.getColValue("dsp_uf_dia21"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(21,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia22_"+i,cdo.getColValue("dsp_uf_dia22"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(22,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia23_"+i,cdo.getColValue("dsp_uf_dia23"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(23,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia24_"+i,cdo.getColValue("dsp_uf_dia24"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(24,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia25_"+i,cdo.getColValue("dsp_uf_dia25"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(25,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia26_"+i,cdo.getColValue("dsp_uf_dia26"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(26,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia27_"+i,cdo.getColValue("dsp_uf_dia27"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(27,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia28_"+i,cdo.getColValue("dsp_uf_dia28"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(28,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia29_"+i,cdo.getColValue("dsp_uf_dia29"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(29,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia30_"+i,cdo.getColValue("dsp_uf_dia30"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(30,"+i+",'u');\"")%></td>
			<td><%=fb.textBox("dsp_uf_dia31_"+i,cdo.getColValue("dsp_uf_dia31"),false,false,true,7,"Text09","","onDblClick=\"javascript:selUbicacion(this.name);\" onClick=\"javascript:setIndex(31,"+i+",'u');\"")%></td>
		
		</tr>
<% } %>
		</table>
	</td>
<% if (fp.trim().equals("")) { %>
	<td width="3%">
		<table width="100%" align="center" cellpadding="1" cellspacing="1">
		<tr class="TextHeader02" align="center" height="<%=cHeight%>">
			<td>&nbsp;</td>
		</tr>
<%
if (emp.size() > 0) al = CmnMgr.reverseRecords(emp);
				for (int i=0; i<emp.size(); i++){
					key = al.get(i).toString();									  
          CommonDataObject cdo = (CommonDataObject) emp.get(key);

	String color = "";
	if (i%2 == 0) color = "TextHeader02";
	else color = "TextHeader01";
%>
		<tr class="<%=color%>" align="center" height="<%=cHeight%>">
			<td><%=fb.submit("del"+i,"x",false,false,"Text10","","onClick=\"javascript:doSubmit(this.value);\"")%></td>
		</tr>
		<tr class="<%=color%>" align="center" height="<%=cHeight%>">
			<td>&nbsp;</td>
		</tr>
<% } %>
		</table>
	</td>
<% } %>
</tr>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{
	String dl = "", sqlItem = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	al.clear();
	emp.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("del"+i)==null){
			cdo.addColValue("anio", request.getParameter("anio"));
			cdo.addColValue("mes", request.getParameter("mes"));
			cdo.addColValue("grupo", request.getParameter("grupo"+i));
			cdo.addColValue("ubicacion_fisica", request.getParameter("ubicacion_fisica"+i));

			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			cdo.addColValue("num_empleado", request.getParameter("num_empleado"+i));
			cdo.addColValue("provincia", request.getParameter("provincia"+i));
			cdo.addColValue("sigla", request.getParameter("sigla"+i));
			cdo.addColValue("tomo", request.getParameter("tomo"+i));
			cdo.addColValue("asiento", request.getParameter("asiento"+i));
			cdo.addColValue("nombre", request.getParameter("nombre"+i));
			for(int j=1; j<=31; j++){
				if(request.getParameter("dia"+j+"_"+i)!=null && !request.getParameter("dia"+j+"_"+i).equals("")) cdo.addColValue("dia"+j, request.getParameter("dia"+j+"_"+i));
				if(request.getParameter("uf_dia"+j+"_"+i)!=null && !request.getParameter("uf_dia"+j+"_"+i).equals("")) cdo.addColValue("uf_dia"+j, request.getParameter("uf_dia"+j+"_"+i));
				if(request.getParameter("dsp_dia"+j+"_"+i)!=null && !request.getParameter("dsp_dia"+j+"_"+i).equals("")) cdo.addColValue("dsp_dia"+j, request.getParameter("dsp_dia"+j+"_"+i));
				if(request.getParameter("dsp_uf_dia"+j+"_"+i)!=null && !request.getParameter("dsp_uf_dia"+j+"_"+i).equals("")) cdo.addColValue("dsp_uf_dia"+j, request.getParameter("dsp_uf_dia"+j+"_"+i));
			}
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("usuario_creacion", request.getParameter("usuario_creacion"+i));
			cdo.addColValue("fecha_creacion", request.getParameter("fecha_creacion"+i));			
			
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
	
			try{
				emp.put(key, cdo);
				empKey.put(cdo.getColValue("emp_id"), key);
				al.add(cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
			
		} else {
			dl = "1";
		}
	}
	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../rhplanilla/reg_cambio_turno_borrador_det.jsp?mode="+mode+"&change=1&fp="+fp+"&anio="+anio+"&mes="+mes);
		return;
	}

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&fp="+fp+"&fg="+fg+"&grupo="+grupo+"&uf_codigo="+uf_codigo+"&anio="+anio+"&mes="+mes+"&aprobada="+aprobada);
		AEmpMgr.updateTurnos(al);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
	parent.document.form1.baction.value = '<%=request.getParameter("baction")%>';
	parent.document.form1.errCode.value = <%=AEmpMgr.getErrCode()%>;
	parent.document.form1.errMsg.value = '<%=AEmpMgr.getErrMsg()%>';
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