<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="turHash" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="tur" scope="page" class="issi.admin.CommonDataObject"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
String change = request.getParameter("change");
String emp_id = request.getParameter("emp_id");
String provincia = "";
String sigla = "";
String tomo = "";
String asiento = "";
String numEmpleado = "";
String seccion = "";
String area = "";
String grupo = "";
String key = "";
String sql = "";
String date = "";
String dateRec = "";
int turLastLineNo = 0;
int count = 0;

if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");
if (request.getParameter("turLastLineNo") != null && !request.getParameter("turLastLineNo").equals("")) turLastLineNo = Integer.parseInt(request.getParameter("turLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET")){
	    
	if (change == null){
		//sql = "select provincia, sigla, tomo, asiento, num_empleado, anio, mes, dia1, dia2, dia3, dia4, dia5, dia6, dia7, dia8, dia9, dia10, dia11, dia12, dia13, dia14, dia15, dia16, dia17, dia18, dia19, dia20, dia21, dia22, dia23, dia24, dia25, dia26, dia26, dia27, dia28, dia29, dia30, dia31, uf_dia1, uf_dia2, uf_dia3, uf_dia4, uf_dia5, uf_dia6, uf_dia7, uf_dia8, uf_dia9, uf_dia10, uf_dia11, uf_dia12, uf_dia13, uf_dia14, uf_dia15, uf_dia16, uf_dia17, uf_dia18, uf_dia19, uf_dia20, uf_dia21, uf_dia22, uf_dia23, uf_dia24, uf_dia25, uf_dia26, uf_dia26, uf_dia27, uf_dia28, uf_dia29, uf_dia30, uf_dia31 from tbl_pla_ct_tprograma where aprobado = 'N' and emp_id = "+emp_id+" order by anio desc, mes desc";
		//al = SQLMgr.getDataList(sql);
		
		turHash.clear();
		turLastLineNo ++;
		if (turLastLineNo < 10) key = "00" + turLastLineNo;
		else if (turLastLineNo < 100) key = "0" + turLastLineNo;
		else key = "" + turLastLineNo;

		date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
		dateRec = CmnMgr.getCurrentDate("dd/mm/yyyy");
		tur.addColValue("fecha",date.substring(0,10));
		tur.addColValue("dateRec",dateRec.substring(0,10));
		tur.addColValue("hora_entrada",date.substring(11));
		tur.addColValue("hora_salida",date.substring(11));
		tur.addColValue("codigo",""+turLastLineNo);
		tur.addColValue("tiempo_horas",""+0);
		tur.addColValue("tiempo_minutos",""+0);
		turHash.put(key,tur);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Programación de Turnos - '+document.title;

function doSubmit(){
	 document.formTurno.save.disableOnSubmit = true;
	 if (parent.doRedirect('1','0') != false){
		document.formTurno.grupo.value = parent.frames['iEmpleado'].document.formEmpleado.grupo.value;
		for (i=0; i<<%=iEmp.size()%>; i++){
			if(eval("parent.frames['iEmpleado'].document.formEmpleado.check"+i).checked){
				document.formTurno.provincia.value = eval("parent.frames['iEmpleado'].document.formEmpleado.provincia"+i).value;
				document.formTurno.sigla.value = eval("parent.frames['iEmpleado'].document.formEmpleado.sigla"+i).value;
				document.formTurno.tomo.value = eval("parent.frames['iEmpleado'].document.formEmpleado.tomo"+i).value;
				document.formTurno.asiento.value = eval("parent.frames['iEmpleado'].document.formEmpleado.asiento"+i).value;
				document.formTurno.numEmpleado.value = eval("parent.frames['iEmpleado'].document.formEmpleado.num_empleado"+i).value;
				document.formTurno.empId.value = eval("parent.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
			}
		}

		var firstDay = parseInt(document.formTurno.firstDay.value);
		var dayOfMonth = parseInt(document.formTurno.dayOfMonth.value);
		var x = 1;
		var y = 1;

		if (document.formTurno.codTurno.value != "" && document.formTurno.ubicacion_fisica.value != ""){
			for (i=1; i<=37;i++){
				if (i>=firstDay && i<(firstDay+dayOfMonth)){
					if (eval('document.formTurno.turno_'+x+'_'+y).value != ""){
						document.formTurno.submit();
						return;
					}
				}
				x++;
				if (x > 7){
					x = 1;
					y++;
				}
			}
		}
	}
}

function setBAction(fName,actionValue){
	document.forms[fName].baction.value = actionValue;
}
function doAction(){
	newHeight();
	parent.setHeight('secciones',document.body.scrollHeight);
//  sumHoras(0,0,0);
}
function addMotivo(index){
	abrir_ventana1("../common/search_motivo_falta.jsp?fp=turnos_empleado&index="+index);
}
function fecha(){
	var anio;
	var mes;
	var firstDay = 0;
	var dayOfMonth = 0;
	var x = 1;
	var y = 1;
	anio = document.formTurno.anio.value;
	mes = document.formTurno.mes.value;

	clearSelect(3,0);
	defaultSelect(1);

	switch(mes) {
		case '1':
			document.formTurno.monthYear.value = "Enero";
			break;
		case '2':
			document.formTurno.monthYear.value = "Febrero";
			break;
		case '3':
			document.formTurno.monthYear.value = "Marzo";
			break;
		case '4':
			document.formTurno.monthYear.value = "Abril";
			break;
		case '5':
			document.formTurno.monthYear.value = "Mayo";
			break;
		case '6':
			document.formTurno.monthYear.value = "Junio";
			break;
		case '7':
			document.formTurno.monthYear.value = "Julio";
			break;
		case '8':
			document.formTurno.monthYear.value = "Agosto";
			break;
		case '9':
			document.formTurno.monthYear.value = "Septiembre";
			break;
		case '10':
			document.formTurno.monthYear.value = "Octubre";
			break;
		case '11':
			document.formTurno.monthYear.value = "Noviembre";
			break;
		case '12':
			document.formTurno.monthYear.value = "Diciembre";
			break;
	}
	if (anio!=null && anio!=""){
		if (parseInt(mes,10) < 10) mes = '0'+mes;
//alert('mes = '+mes+' anio = '+anio);
		firstDay = parseInt(getDBData('<%=request.getContextPath()%>',"to_char(to_date('01-"+mes+"-"+anio+"','dd-mm-yyyy'),'D') as primerDia",'dual','',''),10);
		//firstDay = parseInt(getDBData('<%=request.getContextPath()%>',"1 + TRUNC(to_date('01-"+mes+"-"+anio+"','dd-mm-yyyy')) - TRUNC(to_date('01-"+mes+"-"+anio+"','dd-mm-yyyy'), 'IW') as primerDia",'dual','',''),10);
		dayOfMonth = parseInt(getDBData('<%=request.getContextPath()%>',"to_number(to_char(last_day(to_date('01-"+mes+"-"+anio+"','dd-mm-yyyy')),'dd'))",'dual','',''),10);

		document.formTurno.firstDay.value = ""+firstDay;
		document.formTurno.dayOfMonth.value = ""+dayOfMonth;
		
//alert('First Day = '+firstDay+' day of month = '+dayOfMonth);
		if (anio!=null && anio!="" && mes!=null && mes!=""){
			for (i=1; i<=37;i++){
				//alert('First Day = '+firstDay+' day of month = '+dayOfMonth+'i = '+i+' x = '+x+' y = '+y+' '+(i>=firstDay && i<(firstDay+dayOfMonth))+' value = '+(i-firstDay+1));
				if (i>=firstDay && i<(firstDay+dayOfMonth)){
					eval('document.formTurno.campo_'+x+'_'+y).value = i-firstDay+1;
					eval('document.formTurno.dia_'+x+'_'+y).value = i-firstDay+1;
					eval('document.formTurno.check_'+x+'_'+y).disabled = false;
				} else {
					eval('document.formTurno.campo_'+x+'_'+y).value = "";
					eval('document.formTurno.dia_'+x+'_'+y).value = "";
					eval('document.formTurno.check_'+x+'_'+y).disabled = true;
				}
				x++;
				if (x > 7){
					x = 1;
					y++;
				}
			}
		}
	} else {
		alert('El Campo Año no puede estar vacío !!');
		return;
	}
}

function campoSelect(index){
	if (eval('document.formTurno.check_'+index).checked == true){
		eval('document.formTurno.campo_'+index).style.background = "#99CCFF";
	}	else {
		eval('document.formTurno.campo_'+index).style.background = "";
	}
}
function diaSelect(dia){
	if (eval('document.formTurno.semanaCheck'+dia).checked == true){
		for(i=1; i<=6;i++){
			if (eval('document.formTurno.campo_'+dia+'_'+i)){
				if (eval('document.formTurno.campo_'+dia+'_'+i).value != null && eval('document.formTurno.campo_'+dia+'_'+i).value != ""){
					eval('document.formTurno.campo_'+dia+'_'+i).style.background = "#99CCFF";
					eval('document.formTurno.check_'+dia+'_'+i).checked = true;
				}
			}
		}
	} else {
		clearSelect(1,dia);
	}
}

function filaSelect(index){
	if (eval('document.formTurno.fila'+index).checked == true){
		for(i=1; i<=7;i++){
			if (eval('document.formTurno.campo_'+i+'_'+index)){
				if (eval('document.formTurno.campo_'+i+'_'+index).value != null && eval('document.formTurno.campo_'+i+'_'+index).value != ""){
					eval('document.formTurno.campo_'+i+'_'+index).style.background = "#99CCFF";
					eval('document.formTurno.check_'+i+'_'+index).checked = true;
				}
			}
		}
	}	else {
		clearSelect(2,index);
	}
}
function monthYearSelect(){
	var firstDay;
	var dayOfMonth;
	var anio;
	var mes;
	var x = 1;
	var y = 1;

	firstDay = parseInt(document.formTurno.firstDay.value);
	dayOfMonth = parseInt(document.formTurno.dayOfMonth.value);
	anio = document.formTurno.anio.value;
	mes = document.formTurno.mes.value;

	defaultSelect(0);

	if (document.formTurno.monthYearCheck.checked == true){
		if (anio!=null && anio!="" && mes!=null && mes!=""){
			for (i=1; i<=37;i++){
				if (i>=firstDay && i<(firstDay+dayOfMonth)){
					eval('document.formTurno.campo_'+x+'_'+y).style.background = "#99CCFF";
					eval('document.formTurno.check_'+x+'_'+y).checked = true;
				}	else {
					eval('document.formTurno.campo_'+x+'_'+y).value = "";
					eval('document.formTurno.check_'+x+'_'+y).disabled = true;
				}
				x++;
				if (x > 7){
					x = 1;
					y++;
				}
			}
		}
	} else {
		clearSelect(3,0);
	}
}
function defaultSelect(op)
{
	 document.formTurno.semanaCheck1.disabled = false;
	 document.formTurno.semanaCheck1.checked = false;
	 document.formTurno.semanaCheck2.disabled = false;
	 document.formTurno.semanaCheck2.checked = false;
	 document.formTurno.semanaCheck3.disabled = false;
	 document.formTurno.semanaCheck3.checked = false;
	 document.formTurno.semanaCheck4.disabled = false;
	 document.formTurno.semanaCheck4.checked = false;
	 document.formTurno.semanaCheck5.disabled = false;
	 document.formTurno.semanaCheck5.checked = false;
	 document.formTurno.semanaCheck6.disabled = false;
	 document.formTurno.semanaCheck6.checked = false;
	 document.formTurno.semanaCheck7.disabled = false;
	 document.formTurno.semanaCheck7.checked = false;
	 document.formTurno.fila1.disabled = false;
	 document.formTurno.fila1.checked = false;
	 document.formTurno.fila2.disabled = false;
	 document.formTurno.fila2.checked = false;
	 document.formTurno.fila3.disabled = false;
	 document.formTurno.fila3.checked = false;
	 document.formTurno.fila4.disabled = false;
	 document.formTurno.fila4.checked = false;
	 document.formTurno.fila5.disabled = false;
	 document.formTurno.fila5.checked = false;
	 document.formTurno.fila6.disabled = false;
	 document.formTurno.fila6.checked = false;

	 if (op == 1)
	 {
		document.formTurno.monthYearCheck.disabled = false;
		document.formTurno.monthYearCheck.checked = false;
	 }
}
function clearSelect(op,index){
	var firstDay;
	var dayOfMonth;
	var anio;
	var mes;
	var x = 1;
	var y = 1;

	firstDay = parseInt(document.formTurno.firstDay.value);
	dayOfMonth = parseInt(document.formTurno.dayOfMonth.value);
	anio = document.formTurno.anio.value;
	mes = document.formTurno.mes.value;

	switch (op){
		case 1:
			for(i=1; i<=6;i++){
				if (eval('document.formTurno.campo_'+index+'_'+i)){
					eval('document.formTurno.campo_'+index+'_'+i).style.background = "";
					eval('document.formTurno.check_'+index+'_'+i).checked = false;
				}
			}
			break;

		case 2:
			for(i=1; i<=7;i++){
				if (eval('document.formTurno.campo_'+i+'_'+index)){
					eval('document.formTurno.campo_'+i+'_'+index).style.background = "";
					eval('document.formTurno.check_'+i+'_'+index).checked = false;
				}
			}
			break;

		case 3:
			for (i=1; i<=37;i++){
				eval('document.formTurno.campo_'+x+'_'+y).style.background = "";
				eval('document.formTurno.check_'+x+'_'+y).checked = false;
				x++;
				if (x > 7){
					x = 1;
					y++;
				}
			}
			break;
	}
}
function turnoSelect(){
	abrir_ventana1('../common/search_turno.jsp?fp=empleado_programa');
}
function ubicacion(){
	var grupo;
	grupo = parent.document.form0.grupo.value;
	abrir_ventana1('../common/search_area.jsp?fp=empleado_programa&grupo='+grupo+'&beginSearch=Y');
}
function aplicarTurno(){
	var firstDay = parseInt(document.formTurno.firstDay.value);
	var dayOfMonth = parseInt(document.formTurno.dayOfMonth.value);
	var x = 1;
	var y = 1;

	if (document.formTurno.codTurno.value != "" && document.formTurno.ubicacion_fisica.value != ""){
		for (i=1; i<=37;i++){
			if (i>=firstDay && i<(firstDay+dayOfMonth)){
				if (eval('document.formTurno.check_'+x+'_'+y).checked == true){
					eval('document.formTurno.campo_'+x+'_'+y).value = "";
					eval('document.formTurno.campo_'+x+'_'+y).value = eval('document.formTurno.dia_'+x+'_'+y).value+"("+document.formTurno.codTurno.value+")["+document.formTurno.ubicacion_fisica.value+"]";
					eval('document.formTurno.turno_'+x+'_'+y).value = document.formTurno.codTurno.value;
					eval('document.formTurno.ubicacion_'+x+'_'+y).value = document.formTurno.ubicacion_fisica.value;
				}
			}
			x++;
			if (x > 7){
				x = 1;
				y++;
			}
		}
	}
	clearSelect(3,0);
	if (document.formTurno.anio.value != ""){
		defaultSelect(1);
	}
}

function clearData(index)
{
	 eval('document.formTurno.campo_'+index).value = eval('document.formTurno.dia_'+index).value;
	 eval('document.formTurno.turno_'+index).value = "";
	 eval('document.formTurno.ubicacion_'+index).value = "";
}

function getTurnos(){
	var anio;
	var mes;
	var firstDay = 0;
	var dayOfMonth = 0;
	var x = 1;
	var y = 1;
	var z = 0, contUbic = 62, contTurno = 31;
	anio = document.formTurno.anio.value;
	mes = document.formTurno.mes.value;
	var emp_id = document.formTurno.emp_id.value;
	var sql = '\'(\'|| dia1|| \') [\' || uf_dia1 || \']\', \'(\' || dia2|| \') [\' || uf_dia2 || \']\', \'(\' || dia3|| \') [\' || uf_dia3 || \']\', \'(\' || dia4|| \') [\' || uf_dia4 || \']\', \'(\' || dia5|| \') [\' || uf_dia5 || \']\', \'(\' || dia6|| \') [\' || uf_dia6 || \']\', \'(\' || dia7|| \') [\' || uf_dia7 || \']\', \'(\' || dia8|| \') [\' || uf_dia8 || \']\', \'(\' || dia9|| \') [\' || uf_dia9 || \']\', \'(\' || dia10|| \') [\' || uf_dia10 || \']\', \'(\' || dia11|| \') [\' || uf_dia11 || \']\', \'(\' || dia12|| \') [\' || uf_dia12 || \']\', \'(\' || dia13|| \') [\' || uf_dia13 || \']\', \'(\' || dia14|| \') [\' || uf_dia14 || \']\', \'(\' || dia15|| \') [\' || uf_dia15 || \']\', \'(\' || dia16|| \') [\' || uf_dia16 || \']\', \'(\' || dia17|| \') [\' || uf_dia17 || \']\', \'(\' || dia18|| \') [\' || uf_dia18 || \']\', \'(\' || dia19|| \') [\' || uf_dia19 || \']\', \'(\' || dia20|| \') [\' || uf_dia20 || \']\', \'(\' || dia21|| \') [\' || uf_dia21 || \']\', \'(\' || dia22|| \') [\' || uf_dia22 || \']\', \'(\' || dia23|| \') [\' || uf_dia23 || \']\', \'(\' || dia24|| \') [\' || uf_dia24 || \']\', \'(\' || dia25|| \') [\' || uf_dia25 || \']\', \'(\' || dia26|| \') [\' || uf_dia26 || \']\', \'(\' || dia27|| \') [\' || uf_dia27 || \']\', \'(\' || dia28|| \') [\' || uf_dia28 || \']\', \'(\' || dia29|| \') [\' || uf_dia29 || \']\', \'(\' || dia30|| \') [\' || uf_dia30 || \']\', \'(\' || dia31|| \') [\' || uf_dia31 || \']\', dia1, dia2, dia3, dia4, dia5, dia6, dia7, dia8, dia9, dia10, dia11, dia12, dia13, dia14, dia15, dia16, dia17, dia18, dia19, dia20, dia21, dia22, dia23, dia24, dia25, dia26, dia27, dia28, dia29, dia30, dia31, uf_dia1, uf_dia2, uf_dia3, uf_dia4, uf_dia5, uf_dia6, uf_dia7, uf_dia8, uf_dia9, uf_dia10, uf_dia11, uf_dia12, uf_dia13, uf_dia14, uf_dia15, uf_dia16, uf_dia17, uf_dia18, uf_dia19, uf_dia20, uf_dia21, uf_dia22, uf_dia23, uf_dia24, uf_dia25, uf_dia26, uf_dia27, uf_dia28, uf_dia29, uf_dia30, uf_dia31, provincia, sigla, tomo, asiento, num_empleado, anio, mes';
	clearSelect(3,0);
	defaultSelect(1);

	if (anio!=null && anio!=""){
		if (parseInt(mes,10) < 10) mes = '0'+mes;
		firstDay = parseInt(getDBData('<%=request.getContextPath()%>',"to_char(to_date('01-"+mes+"-"+anio+"','dd-mm-yyyy'),'D') as primerDia",'dual','',''),10);
		dayOfMonth = parseInt(getDBData('<%=request.getContextPath()%>',"to_number(to_char(last_day(to_date('01-"+mes+"-"+anio+"','dd-mm-yyyy')),'dd'))",'dual','',''),10);

		document.formTurno.firstDay.value = ""+firstDay;
		document.formTurno.dayOfMonth.value = ""+dayOfMonth;
		if (anio!=null && anio!="" && mes!=null && mes!=""){
			var data = getDBData('<%=request.getContextPath()%>',sql,'tbl_pla_ct_tprograma','emp_id = '+emp_id +' and anio = ' + anio + ' and mes = ' + mes + ' and compania = <%=(String) session.getAttribute("_companyId")%> and aprobado = \'N\'','');
			var arr_cursor = new Array();
			if(data!=''){
				arr_cursor = splitCols(data);
				for (i=1; i<=37;i++){
					if(i>=firstDay && i<(firstDay+dayOfMonth)){
						eval('document.formTurno.campo_'+x+'_'+y).value 		= i-firstDay+1 + ' ' + arr_cursor[z];
						eval('document.formTurno.dia_'+x+'_'+y).value 			= i-firstDay+1;
						eval('document.formTurno.check_'+x+'_'+y).disabled	= false;
						eval('document.formTurno.turno_'+x+'_'+y).value = arr_cursor[contTurno];
						eval('document.formTurno.ubicacion_'+x+'_'+y).value = arr_cursor[contUbic];
						z++;
						contUbic+=1;
						contTurno+=1;
					} else {
						eval('document.formTurno.campo_'+x+'_'+y).value 		= "";
						eval('document.formTurno.dia_'+x+'_'+y).value 			= "";
						eval('document.formTurno.check_'+x+'_'+y).disabled 	= true;
					}
					x++;
					if (x > 7){
						x = 1;
						y++;
					}
				}
			}
		}
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("formTurno",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("turLastLineNo",""+turLastLineNo)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("area",area)%>
			<%=fb.hidden("grupo",grupo)%>
			<%=fb.hidden("keySize",""+turHash.size())%>
			<%=fb.hidden("firstDay","")%>
			<%=fb.hidden("dayOfMonth","")%>
			<%=fb.hidden("dateRec",dateRec)%>
			<%=fb.hidden("emp_id",emp_id)%>
			<%=fb.hidden("provincia","")%>
			<%=fb.hidden("sigla","")%>
			<%=fb.hidden("tomo","")%>
			<%=fb.hidden("asiento","")%>
			<%=fb.hidden("numEmpleado","")%>
			<%=fb.hidden("empId","")%>
			<%=fb.hidden("check","")%>
				<tr class="TextRow01">
					<td width="2%">&nbsp;</td>
					<td width="14%" align="right" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">DOM<%=fb.checkbox("semanaCheck1","S",false,false,null,null,"onClick=\"javascript:diaSelect(1)\"")%></td>
				<td width="14%" align="right" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">LUN<%=fb.checkbox("semanaCheck2","S",false,false,null,null,"onClick=\"javascript:diaSelect(2)\"")%></td>
				<td width="14%" align="right" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">MAR<%=fb.checkbox("semanaCheck3","S",false,false,null,null,"onClick=\"javascript:diaSelect(3)\"")%></td>
				<td width="14%" align="right" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">MIE<%=fb.checkbox("semanaCheck4","S",false,false,null,null,"onClick=\"javascript:diaSelect(4)\"")%></td>
				<td width="14%" align="right" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">JUE<%=fb.checkbox("semanaCheck5","S",false,false,null,null,"onClick=\"javascript:diaSelect(5)\"")%></td>
				<td width="14%" align="right" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">VIE<%=fb.checkbox("semanaCheck6","S",false,false,null,null,"onClick=\"javascript:diaSelect(6)\"")%></td>
				<td width="14%" align="right" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">SAB<%=fb.checkbox("semanaCheck7","S",false,false,null,null,"onClick=\"javascript:diaSelect(7)\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td width="2%"><%=fb.checkbox("fila1","S",false,false,null,null,"onClick=\"javascript:filaSelect(1)\"")%></td>
				<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
				<%=fb.textBox("campo_1_1","",false,false,true,8,"Text10",null,"onDblClick=\"javascript:clearData('1_1')\"")%>
				<%=fb.checkbox("check_1_1","S",false,false,null,null,"onClick=\"javascript:campoSelect('1_1')\"")%>
				<%=fb.hidden("dia_1_1","")%>
				<%=fb.hidden("turno_1_1","")%>
				<%=fb.hidden("ubicacion_1_1","")%>
				</td>
				<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
				<%=fb.textBox("campo_2_1","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('2_1')\"")%>
				<%=fb.checkbox("check_2_1","S",false,false,null,null,"onClick=\"javascript:campoSelect('2_1')\"")%>
				<%=fb.hidden("dia_2_1","")%>
				<%=fb.hidden("turno_2_1","")%>
				<%=fb.hidden("ubicacion_2_1","")%>
				</td>
				<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
				<%=fb.textBox("campo_3_1","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('3_1')\"")%>
				<%=fb.checkbox("check_3_1","S",false,false,null,null,"onClick=\"javascript:campoSelect('3_1')\"")%>
				<%=fb.hidden("dia_3_1","")%>
				<%=fb.hidden("turno_3_1","")%>
				<%=fb.hidden("ubicacion_3_1","")%>
				</td>
				<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
				<%=fb.textBox("campo_4_1","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('4_1')\"")%>
				<%=fb.checkbox("check_4_1","S",false,false,null,null,"onClick=\"javascript:campoSelect('4_1')\"")%>
				<%=fb.hidden("dia_4_1","")%>
				<%=fb.hidden("turno_4_1","")%>
				<%=fb.hidden("ubicacion_4_1","")%>
				</td>
				<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
				<%=fb.textBox("campo_5_1","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('5_1')\"")%>
				<%=fb.checkbox("check_5_1","S",false,false,null,null,"onClick=\"javascript:campoSelect('5_1')\"")%>
				<%=fb.hidden("dia_5_1","")%>
				<%=fb.hidden("turno_5_1","")%>
				<%=fb.hidden("ubicacion_5_1","")%>
				</td>
				<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
				<%=fb.textBox("campo_6_1","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('6_1')\"")%>
				<%=fb.checkbox("check_6_1","S",false,false,null,null,"onClick=\"javascript:campoSelect('6_1')\"")%>
				<%=fb.hidden("dia_6_1","")%>
				<%=fb.hidden("turno_6_1","")%>
				<%=fb.hidden("ubicacion_6_1","")%>
				</td>
				<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
				<%=fb.textBox("campo_7_1","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('7_1')\"")%>
				<%=fb.checkbox("check_7_1","S",false,false,null,null,"onClick=\"javascript:campoSelect('7_1')\"")%>
				<%=fb.hidden("dia_7_1","")%>
				<%=fb.hidden("turno_7_1","")%>
				<%=fb.hidden("ubicacion_7_1","")%>
				</td>
			</tr>
							<tr class="TextRow01">
								<td width="2%"><%=fb.checkbox("fila2","S",false,false,null,null,"onClick=\"javascript:filaSelect(2)\"")%></td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_1_2","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('1_2')\"")%>
								<%=fb.checkbox("check_1_2","S",false,false,null,null,"onClick=\"javascript:campoSelect('1_2')\"")%>
								<%=fb.hidden("dia_1_2","")%>
								<%=fb.hidden("turno_1_2","")%>
								<%=fb.hidden("ubicacion_1_2","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_2_2","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('2_2')\"")%>
								<%=fb.checkbox("check_2_2","S",false,false,null,null,"onClick=\"javascript:campoSelect('2_2')\"")%>
								<%=fb.hidden("dia_2_2","")%>
								<%=fb.hidden("turno_2_2","")%>
								<%=fb.hidden("ubicacion_2_2","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_3_2","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('3_2')\"")%>
								<%=fb.checkbox("check_3_2","S",false,false,null,null,"onClick=\"javascript:campoSelect('3_2')\"")%>
								<%=fb.hidden("dia_3_2","")%>
								<%=fb.hidden("turno_3_2","")%>
								<%=fb.hidden("ubicacion_3_2","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_4_2","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('4_2')\"")%>
								<%=fb.checkbox("check_4_2","S",false,false,null,null,"onClick=\"javascript:campoSelect('4_2')\"")%>
								<%=fb.hidden("dia_4_2","")%>
								<%=fb.hidden("turno_4_2","")%>
								<%=fb.hidden("ubicacion_4_2","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_5_2","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('5_2')\"")%>
								<%=fb.checkbox("check_5_2","S",false,false,null,null,"onClick=\"javascript:campoSelect('5_2')\"")%>
								<%=fb.hidden("dia_5_2","")%>
								<%=fb.hidden("turno_5_2","")%>
								<%=fb.hidden("ubicacion_5_2","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_6_2","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('6_2')\"")%>
								<%=fb.checkbox("check_6_2","S",false,false,null,null,"onClick=\"javascript:campoSelect('6_2')\"")%>
								<%=fb.hidden("dia_6_2","")%>
								<%=fb.hidden("turno_6_2","")%>
								<%=fb.hidden("ubicacion_6_2","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_7_2","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('7_2')\"")%>
								<%=fb.checkbox("check_7_2","S",false,false,null,null,"onClick=\"javascript:campoSelect('7_2')\"")%>
								<%=fb.hidden("dia_7_2","")%>
								<%=fb.hidden("turno_7_2","")%>
								<%=fb.hidden("ubicacion_7_2","")%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td width="2%"><%=fb.checkbox("fila3","S",false,false,null,null,"onClick=\"javascript:filaSelect(3)\"")%></td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_1_3","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('1_3')\"")%>
								<%=fb.checkbox("check_1_3","S",false,false,null,null,"onClick=\"javascript:campoSelect('1_3')\"")%>
								<%=fb.hidden("dia_1_3","")%><%=fb.hidden("turno_1_3","")%>
								<%=fb.hidden("ubicacion_1_3","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_2_3","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('2_3')\"")%>
								<%=fb.checkbox("check_2_3","S",false,false,null,null,"onClick=\"javascript:campoSelect('2_3')\"")%>
								<%=fb.hidden("dia_2_3","")%>
								<%=fb.hidden("turno_2_3","")%>
								<%=fb.hidden("ubicacion_2_3","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_3_3","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('3_3')\"")%>
								<%=fb.checkbox("check_3_3","S",false,false,null,null,"onClick=\"javascript:campoSelect('3_3')\"")%>
								<%=fb.hidden("dia_3_3","")%>
								<%=fb.hidden("turno_3_3","")%>
								<%=fb.hidden("ubicacion_3_3","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_4_3","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('4_3')\"")%>
								<%=fb.checkbox("check_4_3","S",false,false,null,null,"onClick=\"javascript:campoSelect('4_3')\"")%>
								<%=fb.hidden("dia_4_3","")%>
								<%=fb.hidden("turno_4_3","")%>
								<%=fb.hidden("ubicacion_4_3","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_5_3","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('5_3')\"")%>
								<%=fb.checkbox("check_5_3","S",false,false,null,null,"onClick=\"javascript:campoSelect('5_3')\"")%>
								<%=fb.hidden("dia_5_3","")%>
								<%=fb.hidden("turno_5_3","")%>
								<%=fb.hidden("ubicacion_5_3","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_6_3","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('6_3')\"")%>
								<%=fb.checkbox("check_6_3","S",false,false,null,null,"onClick=\"javascript:campoSelect('6_3')\"")%>
								<%=fb.hidden("dia_6_3","")%>
								<%=fb.hidden("turno_6_3","")%>
								<%=fb.hidden("ubicacion_6_3","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_7_3","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('7_3')\"")%>
								<%=fb.checkbox("check_7_3","S",false,false,null,null,"onClick=\"javascript:campoSelect('7_3')\"")%>
								<%=fb.hidden("dia_7_3","")%>
								<%=fb.hidden("turno_7_3","")%>
								<%=fb.hidden("ubicacion_7_3","")%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td width="2%"><%=fb.checkbox("fila4","S",false,false,null,null,"onClick=\"javascript:filaSelect(4)\"")%></td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_1_4","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('1_4')\"")%>
								<%=fb.checkbox("check_1_4","S",false,false,null,null,"onClick=\"javascript:campoSelect('1_4')\"")%>
								<%=fb.hidden("dia_1_4","")%>
								<%=fb.hidden("turno_1_4","")%>
								<%=fb.hidden("ubicacion_1_4","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_2_4","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('2_4')\"")%>
								<%=fb.checkbox("check_2_4","S",false,false,null,null,"onClick=\"javascript:campoSelect('2_4')\"")%>
								<%=fb.hidden("dia_2_4","")%>
								<%=fb.hidden("turno_2_4","")%>
								<%=fb.hidden("ubicacion_2_4","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_3_4","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('3_4')\"")%>
								<%=fb.checkbox("check_3_4","S",false,false,null,null,"onClick=\"javascript:campoSelect('3_4')\"")%>
								<%=fb.hidden("dia_3_4","")%>
								<%=fb.hidden("turno_3_4","")%>
								<%=fb.hidden("ubicacion_3_4","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_4_4","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('4_4')\"")%>
								<%=fb.checkbox("check_4_4","S",false,false,null,null,"onClick=\"javascript:campoSelect('4_4')\"")%>
								<%=fb.hidden("dia_4_4","")%>
								<%=fb.hidden("turno_4_4","")%>
								<%=fb.hidden("ubicacion_4_4","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_5_4","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('5_4')\"")%>
								<%=fb.checkbox("check_5_4","S",false,false,null,null,"onClick=\"javascript:campoSelect('5_4')\"")%>
								<%=fb.hidden("dia_5_4","")%>
								<%=fb.hidden("turno_5_4","")%>
								<%=fb.hidden("ubicacion_5_4","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_6_4","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('6_4')\"")%>
								<%=fb.checkbox("check_6_4","S",false,false,null,null,"onClick=\"javascript:campoSelect('6_4')\"")%>
								<%=fb.hidden("dia_6_4","")%>
								<%=fb.hidden("turno_6_4","")%>
								<%=fb.hidden("ubicacion_6_4","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_7_4","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('7_4')\"")%>
								<%=fb.checkbox("check_7_4","S",false,false,null,null,"onClick=\"javascript:campoSelect('7_4')\"")%>
								<%=fb.hidden("dia_7_4","")%>
								<%=fb.hidden("turno_7_4","")%>
								<%=fb.hidden("ubicacion_7_4","")%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td width="2%"><%=fb.checkbox("fila5","S",false,false,null,null,"onClick=\"javascript:filaSelect(5)\"")%></td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_1_5","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('1_5')\"")%>
								<%=fb.checkbox("check_1_5","S",false,false,null,null,"onClick=\"javascript:campoSelect('1_5')\"")%>
								<%=fb.hidden("dia_1_5","")%>
								<%=fb.hidden("turno_1_5","")%>
								<%=fb.hidden("ubicacion_1_5","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_2_5","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('2_5')\"")%>
								<%=fb.checkbox("check_2_5","S",false,false,null,null,"onClick=\"javascript:campoSelect('2_5')\"")%>
								<%=fb.hidden("dia_2_5","")%>
								<%=fb.hidden("turno_2_5","")%>
								<%=fb.hidden("ubicacion_2_5","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_3_5","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('3_5')\"")%>
								<%=fb.checkbox("check_3_5","S",false,false,null,null,"onClick=\"javascript:campoSelect('3_5')\"")%>
								<%=fb.hidden("dia_3_5","")%>
								<%=fb.hidden("turno_3_5","")%>
								<%=fb.hidden("ubicacion_3_5","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_4_5","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('4_5')\"")%>
								<%=fb.checkbox("check_4_5","S",false,false,null,null,"onClick=\"javascript:campoSelect('4_5')\"")%>
								<%=fb.hidden("dia_4_5","")%>
								<%=fb.hidden("turno_4_5","")%>
								<%=fb.hidden("ubicacion_4_5","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_5_5","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('5_5')\"")%>
								<%=fb.checkbox("check_5_5","S",false,false,null,null,"onClick=\"javascript:campoSelect('5_5')\"")%>
								<%=fb.hidden("dia_5_5","")%>
								<%=fb.hidden("turno_5_5","")%>
								<%=fb.hidden("ubicacion_5_5","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_6_5","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('6_5')\"")%>
								<%=fb.checkbox("check_6_5","S",false,false,null,null,"onClick=\"javascript:campoSelect('6_5')\"")%>
								<%=fb.hidden("dia_6_5","")%>
								<%=fb.hidden("turno_6_5","")%>
								<%=fb.hidden("ubicacion_6_5","")%>
								</td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<%=fb.textBox("campo_7_5","",false,false,true,8, "Text10",null,"onDblClick=\"javascript:clearData('7_5')\"")%>
								<%=fb.checkbox("check_7_5","S",false,false,null,null,"onClick=\"javascript:campoSelect('7_5')\"")%>
								<%=fb.hidden("dia_7_5","")%>
								<%=fb.hidden("turno_7_5","")%>
								<%=fb.hidden("ubicacion_7_5","")%>
								</td>
							</tr>
							<tr class="TextRow01">
									<td width="2%"><%=fb.checkbox("fila6","S",false,false,null,null,"onClick=\"javascript:filaSelect(6)\"")%></td>
									<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')"><%=fb.textBox("campo_1_6","",false,false,true,6,null,null,"onDblClick=\"javascript:clearData('1_6')\"")%><%=fb.checkbox("check_1_6","S",false,false,null,null,"onClick=\"javascript:campoSelect('1_6')\"")%><%=fb.hidden("dia_1_6","")%><%=fb.hidden("turno_1_6","")%><%=fb.hidden("ubicacion_1_6","")%></td>
								<td width="14%" align="center" class="TextRow01" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')"><%=fb.textBox("campo_2_6","",false,false,true,6,null,null,"onDblClick=\"javascript:clearData('2_6')\"")%><%=fb.checkbox("check_2_6","S",false,false,null,null,"onClick=\"javascript:campoSelect('2_6')\"")%><%=fb.hidden("dia_2_6","")%><%=fb.hidden("turno_2_6","")%><%=fb.hidden("ubicacion_2_6","")%></td>
																<td colspan="5" align="right"><%=fb.textBox("monthYear","Enero",false,false,true,10)%><%=fb.checkbox("monthYearCheck","S",false,false,null,null,"onClick=\"javascript:monthYearSelect()\"")%></td>
							</tr>
						<tr>

					 <td align="center" colspan="8">MES PROGRAMADO</td>
					 </tr>
							<tr class="TextRow01">
									<td colspan="8">&nbsp;</td>
							</tr>

							<tr class="TextRow02">
									<td colspan="1">A&ntilde;o</td>
								<td colspan="3"><%=fb.intBox("anio",tur.getColValue("anio"),false,false,false,15,4,null,null,"onChange=\"javascript:fecha(); getTurnos();\"")%></td>
								<td colspan="1">Mes</td>
								<td colspan="3"><%=fb.select("mes","1=Enero,2=Febrero,3=Marzo,4=Abril,5=Mayo,6=Junio,7=Julio,8=Agosto,9=Septiembre,10=Octubre,11=Noviembre,12=Diciembre",tur.getColValue("mes"),false,false,0,null,null,"onChange=\"javascript:fecha(); getTurnos();\"")%></td>
							</tr>
							<tr class="TextRow01">
									<td colspan="8">&nbsp;</td>
							</tr>
							<tr>
									<td align="center" colspan="8">TURNO ASIGNADO</td>
							</tr>
							<tr class="TextRow01">
									<td align="center" colspan="8">&nbsp;
								</td>
							</tr>
							<tr class="TextRow02">
									<td colspan="1">Turno</td>
								<td colspan="3"><%=fb.intBox("codTurno",tur.getColValue("codTurno"),false,false,true,5,2)%><%=fb.textBox("turnoDesc",tur.getColValue("turnoDesc"),false,false,true,25)%><%=fb.button("btnTurno","...",false,false,null,null,"onClick=\"javascript:turnoSelect()\"")%></td>
									<td colspan="1">Ubicaci&oacute;n</td>
								<td colspan="3"><%=fb.intBox("ubicacion_fisica",tur.getColValue("ubicacion_fisica"),false,false,true,5,2)%><%=fb.textBox("ubicacionFisicaDesc",tur.getColValue("ubicacionFisicaDesc"),false,false,true,25)%><%=fb.button("btnUbicacion","...",false,false,null,null,"onClick=\"javascript:ubicacion()\"")%></td>
							</tr>
				<tr class="TextRow01">
					<td colspan="8" align="right">
					<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit()\"")%>
					<%=fb.button("aplicar","Aplicar",true,false,null,null,"onClick=\"javascript:aplicarTurno()\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0,1)\"")%>
					</td>
					</tr>
						<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	//int x = 1;
	//int y = 1;
	String turno = "";
	String ubicacion = "";
	String index = "";
	seccion = request.getParameter("seccion");
	area = request.getParameter("area");
	grupo = request.getParameter("grupo");


	int x = 1;
	int y = 1;
	CommonDataObject cdo = new CommonDataObject();
	cdo.setTableName("tbl_pla_ct_tprograma");
	cdo.setWhereClause("compania = "+session.getAttribute("_companyId")+" and anio = "+request.getParameter("anio")+" and mes = "+request.getParameter("mes")+" and grupo = "+grupo+" and emp_id = "+emp_id+" and (aprobado = 'N' or aprobado is null)");
	cdo.addColValue("provincia",request.getParameter("provincia"));
	cdo.addColValue("sigla",request.getParameter("sigla"));
	cdo.addColValue("tomo",request.getParameter("tomo"));
	cdo.addColValue("asiento",request.getParameter("asiento"));
	cdo.addColValue("num_empleado",request.getParameter("numEmpleado"));
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("anio",request.getParameter("anio"));
	cdo.addColValue("mes",request.getParameter("mes"));
	cdo.addColValue("grupo",grupo);
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_creacion",request.getParameter("dateRec"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",request.getParameter("dateRec"));
	cdo.addColValue("emp_id",request.getParameter("empId"));
	cdo.addColValue("ubicacion_fisica",request.getParameter("ubicacion_fisica"));
	cdo.addColValue("aprobado","N");
	for (int j=1; j<=37;j++){
		if (request.getParameter("turno_"+x+"_"+y) != null && !request.getParameter("turno_"+x+"_"+y).equalsIgnoreCase("")){
			turno = request.getParameter("turno_"+x+"_"+y);
			ubicacion = request.getParameter("ubicacion_"+x+"_"+y);
			index = request.getParameter("dia_"+x+"_"+y);
			cdo.addColValue("dia"+index,turno);
			cdo.addColValue("uf_dia"+index,ubicacion);
		}
		x++;
		if (x > 7){
			x = 1;
			y++;
		}
	}
	list.add(cdo);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"compania = "+session.getAttribute("_companyId")+", anio = "+request.getParameter("anio")+", mes = "+request.getParameter("mes")+", grupo = "+grupo+", emp_id = "+emp_id+", (aprobado = N or aprobado is null)");
	SQLMgr.insertList(list, false, true);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empl_prog_turnos_detail.jsp"))
	{
%>
//  window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empl_prog_turnos_detail.jsp")%>';
<%
	}
	else
	{
%>
//  window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>