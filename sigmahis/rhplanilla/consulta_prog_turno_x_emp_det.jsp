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
	if(anio != null && mes != null && change == null){
		sql = "select a.provincia, a.sigla, a.tomo, a.asiento, a.num_empleado, a.compania, a.anio, a.mes, a.dia1, a.dia2, a.dia3, a.dia4, a.dia5, a.dia6, a.dia7, a.dia8, a.dia9, a.dia10, a.dia11, a.dia12, a.dia13, a.dia14, a.dia15, a.dia16, a.dia17, a.dia18, a.dia19, a.dia20, a.dia21, a.dia22, a.dia23, a.dia25, a.dia26, a.dia27, a.dia28, a.dia29, a.dia30, a.dia31, a.uf_dia1, a.uf_dia2, a.uf_dia3, a.uf_dia4, a.uf_dia5, a.uf_dia6, a.uf_dia7, a.uf_dia8, a.uf_dia9, a.uf_dia10, a.uf_dia11, a.uf_dia12, a.uf_dia13, a.uf_dia14, a.uf_dia15, a.uf_dia16, a.uf_dia17, a.uf_dia18, a.uf_dia19, a.uf_dia20, a.uf_dia21, a.uf_dia22, a.uf_dia23, a.uf_dia25, a.uf_dia26, a.uf_dia27, a.uf_dia28, a.uf_dia29, a.uf_dia30, a.uf_dia31, getplacambioturno(a.emp_id, a.anio, a.mes, 1) ct1, getplacambioturno(a.emp_id, a.anio, a.mes, 2) ct2, getplacambioturno(a.emp_id, a.anio, a.mes, 3) ct3, getplacambioturno(a.emp_id, a.anio, a.mes, 4) ct4, getplacambioturno(a.emp_id, a.anio, a.mes, 5) ct5, getplacambioturno(a.emp_id, a.anio, a.mes, 6) ct6, getplacambioturno(a.emp_id, a.anio, a.mes, 7) ct7, getplacambioturno(a.emp_id, a.anio, a.mes, 8) ct8, getplacambioturno(a.emp_id, a.anio, a.mes, 9) ct9, getplacambioturno(a.emp_id, a.anio, a.mes, 10) ct10, getplacambioturno(a.emp_id, a.anio, a.mes, 11) ct11, getplacambioturno(a.emp_id, a.anio, a.mes, 12) ct12, getplacambioturno(a.emp_id, a.anio, a.mes, 13) ct13, getplacambioturno(a.emp_id, a.anio, a.mes, 14) ct14, getplacambioturno(a.emp_id, a.anio, a.mes, 15) ct15, getplacambioturno(a.emp_id, a.anio, a.mes, 16) ct16, getplacambioturno(a.emp_id, a.anio, a.mes, 17) ct17, getplacambioturno(a.emp_id, a.anio, a.mes, 18) ct18, getplacambioturno(a.emp_id, a.anio, a.mes, 19) ct19, getplacambioturno(a.emp_id, a.anio, a.mes, 20) ct20, getplacambioturno(a.emp_id, a.anio, a.mes, 21) ct21, getplacambioturno(a.emp_id, a.anio, a.mes, 22) ct22, getplacambioturno(a.emp_id, a.anio, a.mes, 23) ct23, getplacambioturno(a.emp_id, a.anio, a.mes, 24) ct24, getplacambioturno(a.emp_id, a.anio, a.mes, 25) ct25, getplacambioturno(a.emp_id, a.anio, a.mes, 26) ct26, getplacambioturno(a.emp_id, a.anio, a.mes, 27) ct27, getplacambioturno(a.emp_id, a.anio, a.mes, 28) ct28, getplacambioturno(a.emp_id, a.anio, a.mes, 29) ct29, getplacambioturno(a.emp_id, a.anio, a.mes, 30) ct30, getplacambioturno(a.emp_id, a.anio, a.mes, 31) ct31, a.grupo, a.ubicacion_fisica, a.emp_id, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, a.usuario_creacion, b.primer_nombre || ' ' || decode (b.sexo, 'F', decode (b.apellido_casada, null, b.primer_apellido, decode (b.usar_apellido_casada, 'S', 'DE ' || b.apellido_casada, b.primer_apellido)), b.primer_apellido) nombre, (case when c.periodof_inicio < to_date('01/"+mes+"/"+anio+"', 'DD/MM/YYYY') then '01/"+mes+"/"+anio+"' else to_char(c.periodof_inicio, 'DD/MM/YYYY') end) vac_fi_ciclo, (case when c.periodof_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then to_char(last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')), 'dd/mm/yyyy') else to_char(c.periodof_final, 'DD/MM/YYYY') end) vac_ff_fciclo, (case when c.periodof_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) else c.periodof_final end - case when c.periodof_inicio < to_date('01/"+mes+"/"+anio+"', 'DD/MM/YYYY') then to_date('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') else c.periodof_inicio end) vac_dias_ciclo, (case when d.fecha_inicio < to_date ('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') then '01/"+mes+"/"+anio+"' else to_char(d.fecha_inicio, 'dd/mm/yyyy') end) liq_f_inicio, (case when d.fecha_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then to_char(last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')), 'dd/mm/yyyy') else to_char(d.fecha_final, 'dd/mm/yyyy') end) liq_f_final, (case when d.fecha_final > last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) then last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY')) else d.fecha_final end - case when d.fecha_inicio < to_date('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') then to_date('01/"+mes+"/"+anio+"', 'dd/mm/yyyy') else d.fecha_inicio end) liq_dias_ciclo from tbl_pla_ct_tprograma a, tbl_pla_empleado b, (select distinct emp_id, num_empleado, to_date(to_char(periodof_inicio, 'dd/mm/yyyy'), 'dd/mm/yyyy') periodof_inicio, to_date(to_char(periodof_final, 'dd/mm/yyyy'), 'dd/mm/yyyy') periodof_final from tbl_pla_sol_vacacion where compania = "+(String) session.getAttribute("_companyId")+" and ((to_date('01/"+mes+"/"+anio+"', 'dd/MM/YYYY') >= periodof_inicio and to_date('01/"+mes+"/"+anio+"', 'dd/MM/YYYY') <= periodof_final) or (last_day(to_date('01/"+mes+"/"+anio+"', 'dd/MM/YYYY')) >= periodof_inicio and last_day(to_date ('01/"+mes+"/"+anio+"', 'dd/MM/YYYY')) <= periodof_final)) and estado not in ('RE', 'AN')) c, (select distinct emp_id, to_date(to_char(fecha_inicio, 'dd/mm/yyyy'), 'dd/mm/yyyy') fecha_inicio, to_date(to_char(fecha_final, 'dd/mm/yyyy'), 'dd/mm/yyyy') fecha_final from tbl_pla_cc_licencia where compania = "+(String) session.getAttribute("_companyId")+" and ((fecha_inicio <= last_day(to_date('"+mes+"/"+anio+"', 'MM/YYYY'))) and (fecha_final >= (to_date('01/"+mes+"/"+anio+"', 'DD/MM/YYYY'))) and fecha_retorno is null) and motivo_falta = 37) d where a.emp_id = b.emp_id and a.aprobado = 'S' and a.anio = "+anio+" and a.mes = "+mes+"  /*and a.grupo = "+grupo+"and (a.emp_id, a.num_empleado, a.compania) in (select emp_id, num_empleado, compania from tbl_pla_ct_empleado where grupo = "+grupo+" and to_char(ubicacion_fisica) like '"+uf_codigo+"' and compania = "+(String) session.getAttribute("_companyId")+" and estado <> 3 and (fecha_egreso_grupo is null or (fecha_egreso_grupo > last_day (to_date ('01/' || "+mes+" || '/' || "+anio+", 'DD/MM/YYYY')))))*/ and a.emp_id = c.emp_id(+) and a.num_empleado = c.num_empleado(+) and a.emp_id = d.emp_id(+)";
		System.out.println("SQL TPR=\n"+sql);
		alTPR = SQLMgr.getDataList(sql);
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
					eval('document.form.dtext_'+i).className = 'FormRedTextBox10';
				} //else eval('document.form.dtext_'+i).className = 'FormDataObjectEnabled';
				eval('document.form.dtext_'+i).value	= valor;
			}
		}
	}
}

function setDetValues(){
	var size = <%=alTPR.size()%>;
	var mes = parent.document.form1.mes.value;
	var anio = parent.document.form1.anio.value;
	var x = 1, cont = 0;
	for(j=0;j<size;j++){
		var sql = '', uf_sql = '', data = '', dataArray = '';
		var grupo = eval('document.form.grupo'+j).value;
		var emp_id = eval('document.form.emp_id'+j).value;
		for(i=1;i<=31;i++){
			cont++;
			var dia = eval('document.form.dia'+i+'_'+j).value;
			var uf_dia = eval('document.form.uf_dia'+i+'_'+j).value;
			if(dia!=''){
				var xdata = '';
				if(x!=1) sql += ' union ';
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
				else xdata = 'to_char(hora_entrada,\'hh:mi\')||\'/\'||to_char(hora_salida, \'hh:mi\') b from tbl_pla_ct_turno where to_char(codigo)=coalesce(getplacambioturno('+emp_id+','+anio+','+mes+','+i+'),\''+dia+'\') and compania=<%=(String) session.getAttribute("_companyId")%>';
				
				sql += 'select \'d_dia'+i+'_'+j+'\' a, ' + xdata;
				if(cont==10){
					data = getDBData('<%=request.getContextPath()%>','a, b','('+sql+')','','');
					if(dataArray!='') dataArray += '~';
					dataArray += data;
					cont = 0;
					x=0;
					sql = '';
				} else if(i==31){
					data = getDBData('<%=request.getContextPath()%>','a, b','('+sql+')','','');
					if(dataArray!='') dataArray += '~';
					dataArray += data;
					cont = 0;
					x=0;
					sql = '';
				}
				x++;
			}
			if(uf_dia!=''){
				if(i!=1) uf_sql += ' union ';
				uf_sql += 'select \'d_uf_d'+i+'_'+j+'\' a, abreviatura b from tbl_pla_ct_area_x_grupo where to_char(codigo) = \''+uf_dia+'\' and grupo = '+grupo+' and compania = <%=(String) session.getAttribute("_companyId")%>';
			}
		}
		data = getDBData('<%=request.getContextPath()%>','a, b','('+uf_sql+')','','');
		
		if(data != '') dataArray += '~' + data;

		var arr_cursor = new Array();
		var xval = new Array();
		if(dataArray!=''){
			arr_cursor = splitRowsCols(dataArray);
			for(i=0;i<arr_cursor.length;i++){
				xval = arr_cursor[i];
				var valor = xval[1];
				eval('document.form.'+xval[0]).value	= replaceAll(valor,":00","");
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
							eval('document.form.d_dia'+index+'_'+i).value = 'V';
							index += j;
						}
					}
				}
			}
		}
	}
}

function selThis(name){
	var old_index = document.form.index.value;
	var grupo = document.form.grupo0.value;
	var nameText = name.substring(0, 5);
	var dia = '';
	dia = replaceAll(name, "d_dia", "");
	dia = replaceAll(dia, "d_uf_d", "");
	dia = replaceAll(dia, "_0", "");
	var x = 5;
	if(nameText!='d_dia') x = 6;
	var index = name.substring(x);
	parent.window.callMCT(grupo, dia);
	if(old_index!=''){
		eval('document.form.d_dia'+old_index).className = 'FormDataObjectDisabled text09';
		eval('document.form.d_uf_d'+old_index).className = 'FormDataObjectDisabled text09';
	} 
	eval('document.form.d_dia'+index).className = 'FormBlueWhiteData text09';
	eval('document.form.d_uf_d'+index).className = 'FormBlueWhiteData text09';
	document.form.index.value = index;
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
<%=fb.hidden("index","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
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
        <%}%>
    <td id="col_1_15" width="50%">
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
          <td align="center"><%=fb.textBox("d_dia1_"+i,cdo.getColValue("d_dia1"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia2_"+i,cdo.getColValue("d_dia2"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia3_"+i,cdo.getColValue("d_dia3"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia4_"+i,cdo.getColValue("d_dia4"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia5_"+i,cdo.getColValue("d_dia5"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia6_"+i,cdo.getColValue("d_dia6"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia7_"+i,cdo.getColValue("d_dia7"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia8_"+i,cdo.getColValue("d_dia8"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia9_"+i,cdo.getColValue("d_dia9"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia10_"+i,cdo.getColValue("d_dia10"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia11_"+i,cdo.getColValue("d_dia11"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia12_"+i,cdo.getColValue("d_dia12"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia13_"+i,cdo.getColValue("d_dia13"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia14_"+i,cdo.getColValue("d_dia14"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia15_"+i,cdo.getColValue("d_dia15"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
        </tr>
        <tr class="<%=color%>" align="center">
          <td align="center"><%=fb.textBox("d_uf_d1_"+i,cdo.getColValue("d_uf_d1"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d2_"+i,cdo.getColValue("d_uf_d2"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d3_"+i,cdo.getColValue("d_uf_d3"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d4_"+i,cdo.getColValue("d_uf_d4"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d5_"+i,cdo.getColValue("d_uf_d5"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d6_"+i,cdo.getColValue("d_uf_d6"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d7_"+i,cdo.getColValue("d_uf_d7"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d8_"+i,cdo.getColValue("d_uf_d8"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d9_"+i,cdo.getColValue("d_uf_d9"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d10_"+i,cdo.getColValue("d_uf_d10"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d11_"+i,cdo.getColValue("d_uf_d11"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d12_"+i,cdo.getColValue("d_uf_d12"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d13_"+i,cdo.getColValue("d_uf_d13"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d14_"+i,cdo.getColValue("d_uf_d14"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d15_"+i,cdo.getColValue("d_uf_d15"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
        </tr>
       <%}%>
      </table>
    </td>
    <td id="col_16_31"  style="display:none" width="50%">
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
          <td align="center"><%=fb.textBox("d_dia16_"+i,cdo.getColValue("d_dia16"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia17_"+i,cdo.getColValue("d_dia17"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia18_"+i,cdo.getColValue("d_dia18"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia19_"+i,cdo.getColValue("d_dia19"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia20_"+i,cdo.getColValue("d_dia20"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia21_"+i,cdo.getColValue("d_dia21"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia22_"+i,cdo.getColValue("d_dia22"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia23_"+i,cdo.getColValue("d_dia23"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia24_"+i,cdo.getColValue("d_dia24"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia25_"+i,cdo.getColValue("d_dia25"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia26_"+i,cdo.getColValue("d_dia26"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia27_"+i,cdo.getColValue("d_dia27"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia28_"+i,cdo.getColValue("d_dia28"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia29_"+i,cdo.getColValue("d_dia29"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia30_"+i,cdo.getColValue("d_dia30"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_dia31_"+i,cdo.getColValue("d_dia31"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
        </tr>
        <tr class="<%=color%>" align="center">
          <td align="center"><%=fb.textBox("d_uf_d16_"+i,cdo.getColValue("d_uf_d16"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d17_"+i,cdo.getColValue("d_uf_d17"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d18_"+i,cdo.getColValue("d_uf_d18"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d19_"+i,cdo.getColValue("d_uf_d19"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d20_"+i,cdo.getColValue("d_uf_d20"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d21_"+i,cdo.getColValue("d_uf_d21"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d22_"+i,cdo.getColValue("d_uf_d22"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d23_"+i,cdo.getColValue("d_uf_d23"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d24_"+i,cdo.getColValue("d_uf_d24"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d25_"+i,cdo.getColValue("d_uf_d25"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d26_"+i,cdo.getColValue("d_uf_d26"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d27_"+i,cdo.getColValue("d_uf_d27"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d28_"+i,cdo.getColValue("d_uf_d28"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d29_"+i,cdo.getColValue("d_uf_d29"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d30_"+i,cdo.getColValue("d_uf_d30"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
          <td align="center"><%=fb.textBox("d_uf_d31_"+i,cdo.getColValue("d_uf_d31"),false,false,true,7,"text09","","onClick=\"selThis(this.name);\"")%></td>
        </tr>
        <%}%>
      </table>
    </td>
  </tr>
  <tr class="TextHeader01" align="center">
    <td align="center" colspan="2">&nbsp;</td>
  </tr>
  
</table>
<%=fb.hidden("keySize",""+alTPR.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
%>
