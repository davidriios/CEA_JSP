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
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
INV950128						INVENTARIO\TRANSACCIONES\CODIGOS AXA.																				ENLACE DEL CODIGO DEL MEDICAMENTO CON LOS CODIGOS DE AXA.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alTPR = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String grupo = request.getParameter("grupo");
String uf_codigo = request.getParameter("uf_codigo");
boolean viewMode = false;
int lineNo = 0;
System.out.println("mes="+mes);
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(anio != null && mes != null && grupo != null && uf_codigo != null && change == null){
		sql = "select a.provincia, a.sigla, a.tomo, a.asiento, a.num_empleado, a.compania, a.anio, a.mes, a.dia1, a.dia2, a.dia3, a.dia4, a.dia5, a.dia6, a.dia7, a.dia8, a.dia9, a.dia10, a.dia11, a.dia12, a.dia13, a.dia14, a.dia15, a.dia16, a.dia17, a.dia18, a.dia19, a.dia20, a.dia21, a.dia22, a.dia23, a.dia25, a.dia26, a.dia27, a.dia28, a.dia29, a.dia30, a.dia31, a.uf_dia1, a.uf_dia2, a.uf_dia3, a.uf_dia4, a.uf_dia5, a.uf_dia6, a.uf_dia7, a.uf_dia8, a.uf_dia9, a.uf_dia10, a.uf_dia11, a.uf_dia12, a.uf_dia13, a.uf_dia14, a.uf_dia15, a.uf_dia16, a.uf_dia17, a.uf_dia18, a.uf_dia19, a.uf_dia20, a.uf_dia21, a.uf_dia22, a.uf_dia23, a.uf_dia25, a.uf_dia26, a.uf_dia27, a.uf_dia28, a.uf_dia29, a.uf_dia30, a.uf_dia31, a.grupo, a.ubicacion_fisica, a.emp_id, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, a.usuario_creacion, b.primer_nombre || ' ' || decode (b.sexo, 'F', decode (b.apellido_casada, null, b.primer_apellido, decode (b.usar_apellido_casada, 'S', 'DE ' || b.apellido_casada, b.primer_apellido)), b.primer_apellido) nombre, (case when c.periodof_inicio < to_date('01/"+mes+"/"+anio+"', 'DD/MM/YYYY') then '01/"+mes+"/"+anio+"' else to_char(c.periodof_inicio, 'DD/MM/YYYY') end) vac_fi_ciclo, (case when c.periodof_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then to_char(last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')), 'dd/mm/yyyy') else to_char(c.periodof_final, 'DD/MM/YYYY') end) vac_ff_fciclo, (case when c.periodof_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) else c.periodof_final end - case when c.periodof_inicio < to_date('01/"+mes+"/"+anio+"', 'DD/MM/YYYY') then to_date('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') else c.periodof_inicio end) vac_dias_ciclo, (case when d.fecha_inicio < to_date ('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') then '01/"+mes+"/"+anio+"' else to_char(d.fecha_inicio, 'dd/mm/yyyy') end) liq_f_inicio, (case when d.fecha_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then to_char(last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')), 'dd/mm/yyyy') else to_char(d.fecha_final, 'dd/mm/yyyy') end) liq_f_final, (case when d.fecha_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) else d.fecha_final end - case when d.fecha_inicio < to_date('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') then to_date('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') else d.fecha_inicio end) liq_dias_ciclo from tbl_pla_ct_tprograma a, tbl_pla_empleado b, (select distinct emp_id, num_empleado, to_date(to_char(periodof_inicio, 'dd/mm/yyyy'), 'dd/mm/yyyy') periodof_inicio, to_date(to_char(periodof_final, 'dd/mm/yyyy'), 'dd/mm/yyyy') periodof_final from tbl_pla_sol_vacacion where compania = "+(String) session.getAttribute("_companyId")+" and ((to_date('01/"+mes+"/"+anio+"', 'dd/MM/YYYY') >= periodof_inicio and to_date('01/"+mes+"/"+anio+"', 'dd/MM/YYYY') <= periodof_final) or (last_day(to_date('01/"+mes+"/"+anio+"', 'dd/MM/YYYY')) >= periodof_inicio and last_day(to_date ('01/"+mes+"/"+anio+"', 'dd/MM/YYYY')) <= periodof_final)) and estado not in ('RE', 'AN')) c, (select distinct emp_id, to_date(to_char(fecha_inicio, 'dd/mm/yyyy'), 'dd/mm/yyyy') fecha_inicio, to_date(to_char(fecha_final, 'dd/mm/yyyy'), 'dd/mm/yyyy') fecha_final from tbl_pla_cc_licencia where compania = "+(String) session.getAttribute("_companyId")+" and ((fecha_inicio <= last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY'))) and (fecha_final >= (to_date('01/"+mes+"/"+anio+"', 'DD/MM/YYYY'))) and fecha_retorno is null) and motivo_falta = 37) d where a.emp_id = b.emp_id and a.aprobado = 'S' and a.anio = "+anio+" and a.mes = "+mes+" and a.grupo = "+grupo+" and a.emp_id = c.emp_id(+) and a.num_empleado = c.num_empleado(+) and a.emp_id = d.emp_id(+)";
		System.out.println("SQL TPR=\n"+sql);
		alTPR = SQLMgr.getDataList(sql);
		emp.clear();
		empKey.clear();
		for(int i=0;i<alTPR.size();i++){
			CommonDataObject cdo = (CommonDataObject) alTPR.get(i);
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
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	var fg				= document.form.fg.value;
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	setTextValues();
	<%
	if(change==null){
	%>
	setDetValues();
	setVacaciones();
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
	var size = <%=alTPR.size()%>;
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
	var size = <%=alTPR.size()%>;
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

function reversar(i){
	var v_compania	= <%=(String) session.getAttribute("_companyId")%>;
	var v_grupo 		= parent.document.form1.grupo.value;
	var anio 				= parent.document.form1.anio.value;
	var mes 				= parent.document.form1.mes.value;
	var v_user 			= '<%=(String) session.getAttribute("_userName")%>';
	var generar 		= false;
	var p_emp_id 		= 'null';
	var p_num_empleado	= 'null';
	if(i !='all') p_emp_id		= eval('document.form.emp_id'+i).value;
	if(i !='all') p_num_empleado	= eval('document.form.num_empleado'+i).value;
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	formBlockButtons(true);
	var msg = '';
	
	if(i!='all') generar = confirm('Seguro que desea Revertir el Programa de Turnos?');
	else generar = confirm('Está seguro que desea REVERTIR la APROBACION del Programa de turnos para este departamento?');

	if(generar){
		if(executeDB('<%=request.getContextPath()%>', 'call sp_pla_reversar_prog_turno(' + v_compania + ', ' + v_grupo + ', ' + anio + ', ' + mes + ', \'' + v_user + '\', ' + p_emp_id + ', \'' + p_num_empleado + '\')', '', '')){
			msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
			alert(msg);
			parent.setTextValues();
		} else {
			msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
			alert(msg);
		}
	}
	formBlockButtons(false);
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
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
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center">&nbsp;Empleado</td>
        </tr>
        <%
				if (emp.size() > 0) alTPR = CmnMgr.reverseRecords(emp);
				for (int i=0; i<emp.size(); i++){
					key = alTPR.get(i).toString();									  
          CommonDataObject cdo = (CommonDataObject) emp.get(key);
        
          String color = "";
          if (i%2 == 0) color = "TextHeader02";
          else color = "TextHeader01";
          boolean readonly = true;
        %>
        <%=fb.hidden("emp_id"+i, cdo.getColValue("emp_id"))%>
        <%=fb.hidden("num_empleado"+i, cdo.getColValue("num_empleado"))%>
        <%=fb.hidden("nombre_empleado"+i, cdo.getColValue("nombre_empleado"))%>
        <%=fb.hidden("grupo"+i, cdo.getColValue("grupo"))%>
        <%=fb.hidden("ubicacion_fisica"+i, cdo.getColValue("ubicacion_fisica"))%>
        <%=fb.hidden("prioridad"+i, cdo.getColValue("prioridad"))%>
        <%=fb.hidden("usuario_creacion"+i, cdo.getColValue("usuario_creacion"))%>
        <%=fb.hidden("fecha_creacion"+i, cdo.getColValue("fecha_creacion"))%>
        <%=fb.hidden("dia1_"+i, cdo.getColValue("dia1"))%>
        <%=fb.hidden("dia2_"+i, cdo.getColValue("dia2"))%>
        <%=fb.hidden("dia3_"+i, cdo.getColValue("dia3"))%>
        <%=fb.hidden("dia4_"+i, cdo.getColValue("dia4"))%>
        <%=fb.hidden("dia5_"+i, cdo.getColValue("dia5"))%>
        <%=fb.hidden("dia6_"+i, cdo.getColValue("dia6"))%>
        <%=fb.hidden("dia7_"+i, cdo.getColValue("dia7"))%>
        <%=fb.hidden("dia8_"+i, cdo.getColValue("dia8"))%>
        <%=fb.hidden("dia9_"+i, cdo.getColValue("dia9"))%>
        <%=fb.hidden("dia10_"+i, cdo.getColValue("dia10"))%>
        <%=fb.hidden("dia11_"+i, cdo.getColValue("dia11"))%>
        <%=fb.hidden("dia12_"+i, cdo.getColValue("dia12"))%>
        <%=fb.hidden("dia13_"+i, cdo.getColValue("dia13"))%>
        <%=fb.hidden("dia14_"+i, cdo.getColValue("dia14"))%>
        <%=fb.hidden("dia15_"+i, cdo.getColValue("dia15"))%>
        <%=fb.hidden("dia16_"+i, cdo.getColValue("dia16"))%>
        <%=fb.hidden("dia17_"+i, cdo.getColValue("dia17"))%>
        <%=fb.hidden("dia18_"+i, cdo.getColValue("dia18"))%>
        <%=fb.hidden("dia19_"+i, cdo.getColValue("dia19"))%>
        <%=fb.hidden("dia20_"+i, cdo.getColValue("dia20"))%>
        <%=fb.hidden("dia21_"+i, cdo.getColValue("dia21"))%>
        <%=fb.hidden("dia22_"+i, cdo.getColValue("dia22"))%>
        <%=fb.hidden("dia23_"+i, cdo.getColValue("dia23"))%>
        <%=fb.hidden("dia24_"+i, cdo.getColValue("dia24"))%>
        <%=fb.hidden("dia25_"+i, cdo.getColValue("dia25"))%>
        <%=fb.hidden("dia26_"+i, cdo.getColValue("dia26"))%>
        <%=fb.hidden("dia27_"+i, cdo.getColValue("dia27"))%>
        <%=fb.hidden("dia28_"+i, cdo.getColValue("dia28"))%>
        <%=fb.hidden("dia29_"+i, cdo.getColValue("dia29"))%>
        <%=fb.hidden("dia30_"+i, cdo.getColValue("dia30"))%>
        <%=fb.hidden("dia31_"+i, cdo.getColValue("dia31"))%>
        <%=fb.hidden("vac_fi_ciclo_"+i, cdo.getColValue("vac_fi_ciclo"))%>
        <%=fb.hidden("vac_ff_ciclo_"+i, cdo.getColValue("vac_ff_ciclo"))%>
        <%=fb.hidden("vac_dias_ciclo_"+i, cdo.getColValue("vac_dias_ciclo"))%>
				<%=fb.hidden("liq_f_inicio_"+i, cdo.getColValue("liq_f_inicio"))%>
        <%=fb.hidden("liq_f_final_"+i, cdo.getColValue("liq_f_final"))%>
        <%=fb.hidden("liq_dias_ciclo_"+i, cdo.getColValue("liq_dias_ciclo"))%>
        <%=fb.hidden("uf_dia1_"+i, cdo.getColValue("uf_dia1"))%>
        <%=fb.hidden("uf_dia2_"+i, cdo.getColValue("uf_dia2"))%>
        <%=fb.hidden("uf_dia3_"+i, cdo.getColValue("uf_dia3"))%>
        <%=fb.hidden("uf_dia4_"+i, cdo.getColValue("uf_dia4"))%>
        <%=fb.hidden("uf_dia5_"+i, cdo.getColValue("uf_dia5"))%>
        <%=fb.hidden("uf_dia6_"+i, cdo.getColValue("uf_dia6"))%>
        <%=fb.hidden("uf_dia7_"+i, cdo.getColValue("uf_dia7"))%>
        <%=fb.hidden("uf_dia8_"+i, cdo.getColValue("uf_dia8"))%>
        <%=fb.hidden("uf_dia9_"+i, cdo.getColValue("uf_dia9"))%>
        <%=fb.hidden("uf_dia10_"+i, cdo.getColValue("uf_dia10"))%>
        <%=fb.hidden("uf_dia11_"+i, cdo.getColValue("uf_dia11"))%>
        <%=fb.hidden("uf_dia12_"+i, cdo.getColValue("uf_dia12"))%>
        <%=fb.hidden("uf_dia13_"+i, cdo.getColValue("uf_dia13"))%>
        <%=fb.hidden("uf_dia14_"+i, cdo.getColValue("uf_dia14"))%>
        <%=fb.hidden("uf_dia15_"+i, cdo.getColValue("uf_dia15"))%>
        <%=fb.hidden("uf_dia16_"+i, cdo.getColValue("uf_dia16"))%>
        <%=fb.hidden("uf_dia17_"+i, cdo.getColValue("uf_dia17"))%>
        <%=fb.hidden("uf_dia18_"+i, cdo.getColValue("uf_dia18"))%>
        <%=fb.hidden("uf_dia19_"+i, cdo.getColValue("uf_dia19"))%>
        <%=fb.hidden("uf_dia20_"+i, cdo.getColValue("uf_dia20"))%>
        <%=fb.hidden("uf_dia21_"+i, cdo.getColValue("uf_dia21"))%>
        <%=fb.hidden("uf_dia22_"+i, cdo.getColValue("uf_dia22"))%>
        <%=fb.hidden("uf_dia23_"+i, cdo.getColValue("uf_dia23"))%>
        <%=fb.hidden("uf_dia24_"+i, cdo.getColValue("uf_dia24"))%>
        <%=fb.hidden("uf_dia25_"+i, cdo.getColValue("uf_dia25"))%>
        <%=fb.hidden("uf_dia26_"+i, cdo.getColValue("uf_dia26"))%>
        <%=fb.hidden("uf_dia27_"+i, cdo.getColValue("uf_dia27"))%>
        <%=fb.hidden("uf_dia28_"+i, cdo.getColValue("uf_dia28"))%>
        <%=fb.hidden("uf_dia29_"+i, cdo.getColValue("uf_dia29"))%>
        <%=fb.hidden("uf_dia30_"+i, cdo.getColValue("uf_dia30"))%>
        <%=fb.hidden("uf_dia31_"+i, cdo.getColValue("uf_dia31"))%>
        <tr class="<%=color%>" align="center" height="21">
          <td align="center">
          <%=fb.textBox("provincia"+i,cdo.getColValue("provincia"),false,false,true,1,"text09","","")%>
          <%=fb.textBox("sigla"+i,cdo.getColValue("sigla"),false,false,true,1,"text09","","")%>
          <%=fb.textBox("tomo"+i,cdo.getColValue("tomo"),false,false,true,1,"text09","","")%>
          <%=fb.textBox("asiento"+i,cdo.getColValue("asiento"),false,false,true,3,"text09","","")%>
          </td>
        </tr>
        <tr class="<%=color%>" align="center" height="21">
          <td align="center"><%=fb.textBox("nombre"+i,cdo.getColValue("nombre"),false,false,true,25,"text09","","")%><%//=cdo.getColValue("nombre")%></td>
        </tr>
        <%}%>
      </table>
    </td>
    <td id="col_1_15" width="43%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02">
          <td align="center"><%=fb.textBox("dtext_1",cdoDM.getColValue("dtext_1"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_2",cdoDM.getColValue("dtext_2"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_3",cdoDM.getColValue("dtext_3"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_4",cdoDM.getColValue("dtext_4"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_5",cdoDM.getColValue("dtext_5"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_6",cdoDM.getColValue("dtext_6"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_7",cdoDM.getColValue("dtext_7"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_8",cdoDM.getColValue("dtext_8"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_9",cdoDM.getColValue("dtext_9"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_10",cdoDM.getColValue("dtext_10"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_11",cdoDM.getColValue("dtext_11"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_12",cdoDM.getColValue("dtext_12"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_13",cdoDM.getColValue("dtext_13"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_14",cdoDM.getColValue("dtext_14"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_15",cdoDM.getColValue("dtext_15"),false,false,true,5,"text09","","")%></td>
        </tr>
        <%
				if (emp.size() > 0) alTPR = CmnMgr.reverseRecords(emp);
				for (int i=0; i<emp.size(); i++){
					key = alTPR.get(i).toString();									  
          CommonDataObject cdo = (CommonDataObject) emp.get(key);
        
          String color = "";
          if (i%2 == 0) color = "TextHeader02";
          else color = "TextHeader01";
          boolean readonly = true;
        %>
        <tr class="<%=color%>" align="center">
          <td align="center"><%=fb.textBox("dsp_dia1_"+i,cdo.getColValue("dsp_dia1"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia2_"+i,cdo.getColValue("dsp_dia2"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia3_"+i,cdo.getColValue("dsp_dia3"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia4_"+i,cdo.getColValue("dsp_dia4"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia5_"+i,cdo.getColValue("dsp_dia5"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia6_"+i,cdo.getColValue("dsp_dia6"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia7_"+i,cdo.getColValue("dsp_dia7"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia8_"+i,cdo.getColValue("dsp_dia8"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia9_"+i,cdo.getColValue("dsp_dia9"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia10_"+i,cdo.getColValue("dsp_dia10"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia11_"+i,cdo.getColValue("dsp_dia11"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia12_"+i,cdo.getColValue("dsp_dia12"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia13_"+i,cdo.getColValue("dsp_dia13"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia14_"+i,cdo.getColValue("dsp_dia14"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia15_"+i,cdo.getColValue("dsp_dia15"),false,false,true,7,"text09","","")%></td>
        </tr>
        <tr class="<%=color%>" align="center">
          <td align="center"><%=fb.textBox("dsp_uf_dia1_"+i,cdo.getColValue("dsp_uf_dia1"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia2_"+i,cdo.getColValue("dsp_uf_dia2"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia3_"+i,cdo.getColValue("dsp_uf_dia3"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia4_"+i,cdo.getColValue("dsp_uf_dia4"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia5_"+i,cdo.getColValue("dsp_uf_dia5"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia6_"+i,cdo.getColValue("dsp_uf_dia6"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia7_"+i,cdo.getColValue("dsp_uf_dia7"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia8_"+i,cdo.getColValue("dsp_uf_dia8"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia9_"+i,cdo.getColValue("dsp_uf_dia9"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia10_"+i,cdo.getColValue("dsp_uf_dia10"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia11_"+i,cdo.getColValue("dsp_uf_dia11"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia12_"+i,cdo.getColValue("dsp_uf_dia12"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia13_"+i,cdo.getColValue("dsp_uf_dia13"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia14_"+i,cdo.getColValue("dsp_uf_dia14"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia15_"+i,cdo.getColValue("dsp_uf_dia15"),false,false,true,7,"text09","","")%></td>
        </tr>
       <%}%>
      </table>
    </td>
    <td id="col_16_31"  style="display:none" width="43%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02">
          <td align="center"><%=fb.textBox("dtext_16",cdoDM.getColValue("dtext_16"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_17",cdoDM.getColValue("dtext_17"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_18",cdoDM.getColValue("dtext_18"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_19",cdoDM.getColValue("dtext_19"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_20",cdoDM.getColValue("dtext_20"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_21",cdoDM.getColValue("dtext_21"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_22",cdoDM.getColValue("dtext_22"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_23",cdoDM.getColValue("dtext_23"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_24",cdoDM.getColValue("dtext_24"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_25",cdoDM.getColValue("dtext_25"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_26",cdoDM.getColValue("dtext_26"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_27",cdoDM.getColValue("dtext_27"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_28",cdoDM.getColValue("dtext_28"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_29",cdoDM.getColValue("dtext_29"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_30",cdoDM.getColValue("dtext_30"),false,false,true,5,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dtext_31",cdoDM.getColValue("dtext_31"),false,false,true,5,"text09","","")%></td>
        </tr>
        <%
				if (emp.size() > 0) alTPR = CmnMgr.reverseRecords(emp);
				for (int i=0; i<emp.size(); i++){
					key = alTPR.get(i).toString();									  
          CommonDataObject cdo = (CommonDataObject) emp.get(key);
        
          String color = "";
          if (i%2 == 0) color = "TextHeader02";
          else color = "TextHeader01";
          boolean readonly = true;
        %>
        <tr class="<%=color%>" align="center">
          <td align="center"><%=fb.textBox("dsp_dia16_"+i,cdo.getColValue("dsp_dia16"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia17_"+i,cdo.getColValue("dsp_dia17"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia18_"+i,cdo.getColValue("dsp_dia18"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia19_"+i,cdo.getColValue("dsp_dia19"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia20_"+i,cdo.getColValue("dsp_dia20"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia21_"+i,cdo.getColValue("dsp_dia21"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia22_"+i,cdo.getColValue("dsp_dia22"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia23_"+i,cdo.getColValue("dsp_dia23"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia24_"+i,cdo.getColValue("dsp_dia24"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia25_"+i,cdo.getColValue("dsp_dia25"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia26_"+i,cdo.getColValue("dsp_dia26"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia27_"+i,cdo.getColValue("dsp_dia27"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia28_"+i,cdo.getColValue("dsp_dia28"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia29_"+i,cdo.getColValue("dsp_dia29"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia30_"+i,cdo.getColValue("dsp_dia30"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_dia31_"+i,cdo.getColValue("dsp_dia31"),false,false,true,7,"text09","","")%></td>
        </tr>
        <tr class="<%=color%>" align="center">
          <td align="center"><%=fb.textBox("dsp_uf_dia16_"+i,cdo.getColValue("dsp_uf_dia16"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia17_"+i,cdo.getColValue("dsp_uf_dia17"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia18_"+i,cdo.getColValue("dsp_uf_dia18"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia19_"+i,cdo.getColValue("dsp_uf_dia19"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia20_"+i,cdo.getColValue("dsp_uf_dia20"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia21_"+i,cdo.getColValue("dsp_uf_dia21"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia22_"+i,cdo.getColValue("dsp_uf_dia22"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia23_"+i,cdo.getColValue("dsp_uf_dia23"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia24_"+i,cdo.getColValue("dsp_uf_dia24"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia25_"+i,cdo.getColValue("dsp_uf_dia25"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia26_"+i,cdo.getColValue("dsp_uf_dia26"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia27_"+i,cdo.getColValue("dsp_uf_dia27"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia28_"+i,cdo.getColValue("dsp_uf_dia28"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia29_"+i,cdo.getColValue("dsp_uf_dia29"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia30_"+i,cdo.getColValue("dsp_uf_dia30"),false,false,true,7,"text09","","")%></td>
          <td align="center"><%=fb.textBox("dsp_uf_dia31_"+i,cdo.getColValue("dsp_uf_dia31"),false,false,true,7,"text09","","")%></td>
        </tr>
        <%}%>
      </table>
    </td>
    <td width="2%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center">&nbsp;</td>
        </tr>
        <%
				if (emp.size() > 0) alTPR = CmnMgr.reverseRecords(emp);
				for (int i=0; i<emp.size(); i++){
					key = alTPR.get(i).toString();									  
          CommonDataObject cdo = (CommonDataObject) emp.get(key);
        
          String color = "";
          if (i%2 == 0) color = "TextHeader02";
          else color = "TextHeader01";
        %>
        <tr class="<%=color%>" align="center" height="21">
          <td align="center">
          <a href="javascript:reversar(<%=i%>)"><img src="../images/check.gif" border="0" height="16" width="16" title="Revertir"></a>
          </td>
        </tr>
        <tr class="<%=color%>" align="center" height="21">
          <td align="center">&nbsp;</td>
        </tr>
        <%}%>
      </table>
    </td>
  </tr>
</table>
<%=fb.hidden("keySize",""+alTPR.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
	alTPR.clear();
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
				alTPR.add(cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		} else {
			dl = "1";
		}
	}
	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../rhplanilla/reg_cambio_turno_borrador_det.jsp?mode="+mode+"&change=1");
		return;
	}
	
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AEmpMgr.updateTurnos(alTPR);
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