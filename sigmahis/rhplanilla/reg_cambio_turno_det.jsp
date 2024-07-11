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
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vEmp" scope="session" class="java.util.Vector"/>
<%
/**
==================================================================================
sct0070: Utilizado x Jefe para aprobación
sct0070s: Utilizado x Secretaria para registro-
---
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
String change = request.getParameter("change");
String type = request.getParameter("type");
String mode = request.getParameter("mode");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String codigo = request.getParameter("codigo");

if (grupo == null) grupo = "";
if (area == null) area = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (codigo == null) codigo = "";

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
<% if (type != null && type.equals("1")) { %>abrir_ventana1('../common/select_ctempleado.jsp?mode=<%=mode%>&fp=cambio_turno&grupo=<%=grupo%>&area=<%=area%>&anio=<%=anio%>&mes=<%=mes%>&ct=<%=codigo%>&stype=cb');<% } %>
//newHeight();
}

function doSubmit(baction){
document.form0.baction.value=baction;
document.form0.anio.value=parent.document.form0.anio.value;
document.form0.mes.value=parent.document.form0.mes.value;
document.form0.motivo_cambio.value=parent.document.form0.motivo_cambio.value;
document.form0.fecha_solicitud.value=parent.document.form0.fecha_solicitud.value;
document.form0.provincia.value=parent.document.form0.provincia.value;
document.form0.sigla.value=parent.document.form0.sigla.value;
document.form0.tomo.value=parent.document.form0.tomo.value;
document.form0.asiento.value=parent.document.form0.asiento.value;
document.form0.num_empleado.value=parent.document.form0.num_empleado.value;
document.form0.emp_id.value=parent.document.form0.emp_id.value;
document.form0.observaciones.value=parent.document.form0.observaciones.value;
if(eval('parent.document.form0.aprobado'))document.form0.aprobado.value=parent.document.form0.aprobado.value;
if(!form0Validation())parent.form0BlockButtons(false);
else document.form0.submit();
}

function verificaData(i){
	var grupo = document.form.grupo.value;
	var p_emp_id = eval('document.form.emp_id'+i).value;
	var p_num_empleado = eval('document.form.num_empleado'+i).value;
	var fecha = eval('document.form.fecha_tasignado'+i).value;
	var fecha_old = eval('document.form.fecha_tasignado_old'+i).value;
	var p_mode = document.form.mode.value;
	var p_motivo_cambio = parent.document.form0.motivo_cambio.value;
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';

	//	when_validate_item:
	var sql = '/* AUSENCIA */ select \'N\' ausencia, \'\' incapacidad, \'\' sobretiempo, \'\' tardanza from tbl_pla_inasistencia_emp where to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fecha+'\', \'dd/mm/yyyy\') and ue_codigo = '+ grupo +' and compania = <%=(String) session.getAttribute("_companyId")%> and emp_id = '+ p_emp_id +' and num_empleado = '+p_num_empleado+' and estado <> \'EL\' and aprobacion <> \'A\' union /* INCAPACIDAD */ select \'\' ausencia, \'N\' incapacidad, \'\' sobretiempo, \'\' tardanza from tbl_pla_incapacidad where to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fecha+'\', \'dd/mm/yyyy\') and ue_codigo = '+ grupo +' and compania = <%=(String) session.getAttribute("_companyId")%> and emp_id = '+ p_emp_id +' and num_empleado = '+p_num_empleado+' union /* SOBRETIEMPO */ select \'\' ausencia, \'\' incapacidad, \'N\' sobretiempo, \'\' tardanza from tbl_pla_st_det_empleado where emp_id = '+ p_emp_id +' and to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fecha+'\', \'dd/mm/yyyy\') and ue_codigo = '+ grupo +' and compania = <%=(String) session.getAttribute("_companyId")%> union /* TARDANZA */ select \'\' ausencia, \'\' incapacidad, \'\' sobretiempo, \'N\' tardanza from tbl_pla_at_det_empfecha where emp_id = '+ p_emp_id +' and to_date(to_char(fecha, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fecha+'\', \'dd/mm/yyyy\') and ue_codigo = '+ grupo +' and compania = <%=(String) session.getAttribute("_companyId")%>';
	var x = getDBData('<%=request.getContextPath()%>','ausencia, incapacidad, sobretiempo, tardanza','('+sql+')','','');
	var arr_cursor = new Array();
	if(x!=''){
		arr_cursor = splitCols(x);
		var ausencia 		= arr_cursor[0];
		var incapacidad = arr_cursor[1];
		var sobretiempo = arr_cursor[2];
		var tardanza 		= arr_cursor[3];
		if(ausencia=='N') alert('El empleado tiene registrada una AUSENCIA para este día; por lo tanto, no será posible registrar un cambio para este día');
		else if(incapacidad=='N') alert('El empleado tiene registrada una INCAPACIDAD para este día');
		else if(sobretiempo=='N') alert('El empleado tiene una transaccion de SOBRETIEMPO registrada para este día');
		else if(tardanza=='N') alert('El empleado tiene una transaccion de TARDANZA registrada para este día');
		else {
			var x = getDBData('<%=request.getContextPath()%>','getDataVarios(\''+fecha+'\', '+p_emp_id+', \''+p_num_empleado+'\', <%=(String) session.getAttribute("_companyId")%>, '+grupo+', \''+((p_mode=='view')?'add':p_mode)+'\')','dual','','');

			if(x!=''){
				arr_cursor = splitCols(x);
				eval('document.form.fecha_tnuevo'+i).value 				= arr_cursor[0];
				eval('document.form.mes_ca'+i).value 							= arr_cursor[1];
				eval('document.form.anio_ca'+i).value							= arr_cursor[2];
				eval('document.form.ta_programado'+i).value				= arr_cursor[3];
				eval('document.form.turno_asignado'+i).value			= arr_cursor[4];
				eval('document.form.turno_asignado_desc'+i).value	= arr_cursor[5];
			} else {
				var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
				if(msg!='') alert(msg);
			}
		}
	} else {
		var x = getDBData('<%=request.getContextPath()%>','getDataVarios(\''+fecha+'\', '+p_emp_id+', \''+p_num_empleado+'\', <%=(String) session.getAttribute("_companyId")%>, '+grupo+', \''+((p_mode=='view')?'add':p_mode)+'\')','dual','','');

		if(x!=''){
			arr_cursor = splitCols(x);
			eval('document.form.fecha_tnuevo'+i).value 				= arr_cursor[0];
			eval('document.form.mes_ca'+i).value 							= arr_cursor[1];
			eval('document.form.anio_ca'+i).value							= arr_cursor[2];
			eval('document.form.ta_programado'+i).value				= arr_cursor[3];
			eval('document.form.turno_asignado'+i).value			= arr_cursor[4];
			eval('document.form.turno_asignado_desc'+i).value	= arr_cursor[5];
			var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
			if(msg!='') alert(msg);
		}
	}
	if(executeDB('<%=request.getContextPath()%>','call sp_pla_verifica_cambios_turnos(<%=(String) session.getAttribute("_companyId")%>, '+p_emp_id+', \''+p_num_empleado+'\', '+p_motivo_cambio+', \''+fecha+'\', \''+fecha_old+'\', \''+p_mode+'\')','')){
		var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
		if(msg!='') alert(msg);
	} else {
		var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
		if(msg!='') alert(msg);
	}

}
function checkFechaAsignado(k){
	var fechaTasignado=eval('document.form0.fecha_tasignado'+k).value.trim();
	if(fechaTasignado==''){alert('Se requiere la Fecha del Turno Asignado!');return false;}
	var empId=eval('document.form0.emp_id'+k).value;
	var numEmp=eval('document.form0.num_empleado'+k).value;
	var error=0;
<% if (!mode.equalsIgnoreCase("approve")) { %>
	if(hasTransaction(empId,fechaTasignado))error++;
	if(!checkCantCambio(empId,numEmp,fechaTasignado,k))error++;
<% } %>
	if(!getTurno(empId,fechaTasignado,k))error++;<% if (mode.equalsIgnoreCase("add")) { %><% } %>
	if(error>0){eval('document.form0.fecha_tasignado'+k).value=eval('document.form0.fecha_tasignado_old'+k).value;return false;}
	return true;
}
function hasTransaction(empId,fechaTasignado){
	var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','tipo, n','(select \'Ausencia\' as tipo, count(*) as n from tbl_pla_inasistencia_emp where fecha = to_date(\''+fechaTasignado+'\',\'dd/mm/yyyy\') and ue_codigo = <%=grupo%> and compania = <%=session.getAttribute("_companyId")%> and emp_id = '+empId+' and estado <> \'EL\' and aprobacion <> \'A\' UNION ALL select \'Incapacidad\', count(*) from tbl_pla_incapacidad where fecha = to_date(\''+fechaTasignado+'\',\'dd/mm/yyyy\') and ue_codigo = <%=grupo%> and compania = <%=session.getAttribute("_companyId")%> and emp_id = '+empId+' UNION ALL select \'Sobretiempo\', count(*) from tbl_pla_st_det_empleado where trunc(fecha) = to_date(\''+fechaTasignado+'\',\'dd/mm/yyyy\') and ue_codigo = <%=grupo%> and compania = <%=session.getAttribute("_companyId")%> and emp_id = '+empId+' UNION ALL select \'Tardanza\', count(*) from tbl_pla_at_det_empfecha where trunc(fecha) = to_date(\''+fechaTasignado+'\',\'dd/mm/yyyy\') and ue_codigo = <%=grupo%> and compania = <%=session.getAttribute("_companyId")%> and emp_id = '+empId+')','',''));
	var msg='';for(i=0;i<r.length;i++){if(parseInt(r[i][1],10)>0)msg+=', '+r[i][0];}
	if(msg!=''){alert('El Empleado tiene registrado transacciones de'+msg.substr(1)+' para ese día, por lo tanto, no será posible registrar el Cambio de Turno para ese día!');return true;}
	return false;
}
function getTurno(empId,fechaTasignado,k){
	if(empId==undefined||empId==null||empId.trim()==''){alert('Se requiere el Empleado involucrado en el cambio de turno!');return false;}
	if(fechaTasignado==undefined||fechaTasignado==null||fechaTasignado.trim()==''){alert('Se requiere la Fecha del Turno Asignado!');return false;}
	var c=splitCols(getDBData('<%=request.getContextPath()%>','getPlaCambioTurnoData(<%=(String) session.getAttribute("_companyId")%>,<%=grupo%>,'+empId+',\''+fechaTasignado+'\')','dual','',''));
	if(c!=null&&c!=''&&c.length==6){
		if(c[5]==''){alert('El Empleado no tiene asignado un horario!');return false;}
		eval('document.form0.fecha_tnuevo'+k).value=c[0];
		eval('document.form0.mes_ca'+k).value=c[1];
		eval('document.form0.anio_ca'+k).value=c[2];
		eval('document.form0.ta_programado'+k).value=c[3];
		eval('document.form0.turno_asignado'+k).value=c[4];
		eval('document.form0.turno_asignado_desc'+k).value=c[5];
		return true;
	}else{alert('Error!');return false;}
}
function checkCantCambio(empId,numEmp,fechaTasignado,k){
	var isValid=true;
	var motivo=parent.document.form0.motivo_cambio.value;
	if(motivo==''){alert('Por favor indique el Motivo!');return false;}
	else if(motivo=='1'){
		var f=fechaTasignado.split('/');
		if(empId==undefined||empId==null||empId.trim()==''){alert('Se requiere el Empleado involucrado en el cambio de turno!');return false;}
		if(fechaTasignado==undefined||fechaTasignado==null||fechaTasignado.trim()==''){alert('Se requiere la Fecha del Turno Asignado!');return false;}
		var c=splitCols(getDBData('<%=request.getContextPath()%>','cant, nvl((select cantidad_max_cambio_turno from tbl_pla_parametros_cc where cod_compania = <%=(String) session.getAttribute("_companyId")%> and estado = \'A\'),6) as lim','(select count(*) as cant from tbl_pla_ct_det_cambio_programa d, tbl_pla_ct_enc_cambio_programa e where d.emp_id = '+empId+' and d.compania = <%=(String) session.getAttribute("_companyId")%> and to_number(to_char(d.fecha_tasignado,\'yyyymm\')) = '+f[2]+f[1]+' and d.compania = e.compania and d.anio = e.anio and d.mes = e.mes and d.grupo = e.grupo and d.codigo = e.codigo and e.motivo_cambio = 1 and e.aprobado not in (\'A\'))','',''));
		if(c!=null){
	<% if (mode.equalsIgnoreCase("add")) { %>
			if(parseInt(c[0],10)>parseInt(c[1],10))isValid=false;
	<% } else { %>
			var fOld=eval('document.form0.fecha_tasignado_old'+k).value.split('/');
			if(f[2]+f[1]==fOld[2]+fOld[1]){
				if(parseInt(c[0],10)>parseInt(c[1],10))isValid=false;
			}else{
				if(parseInt(c[0],10)-1>=parseInt(c[1],10))isValid=false;
			}
	<% } %>
		}
		if(isValid){
			alert('Empleado #'+numEmp+', tiene registrado(s) *** '+c[0]+' *** cambio(s)!');
		}else{
			alert('El empleado #'+numEmp+', ya ha utilizado los cambios permitidos x mes!');
			return false;
		}
	}
	return true;
}
function showTurnoList(k){abrir_ventana('../common/search_turno.jsp?fp=cambio_turno&index='+k);}
function isValidFechaAsignado(){
	var nDet=0;
	for(i=1;i<=<%=iEmp.size()%>;i++){
		if(eval('document.form0.action'+i).value!='D'){nDet++;if(!checkFechaAsignado(i))return false;}
	}
	if(nDet==0){alert('Por favor seleccione al menos un Empleado!');return false;}
	return true;
}

function isValidAsignado(){
	var nDet=0;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" align="center" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("fecha_solicitud","")%>
<%=fb.hidden("motivo_cambio","")%>
<%=fb.hidden("provincia","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("num_empleado","")%>
<%=fb.hidden("emp_id","")%>
<%=fb.hidden("observaciones","")%>
<%=fb.hidden("aprobado","")%>
<%=fb.hidden("size",""+iEmp.size())%>
<%fb.appendJsValidation("if(document.form0.baction.value=='Guardar'&&!isValidAsignado())error++;");%>
<tr class="TextHeader">
	<td colspan="7">DETALLE DEL CAMBIO DE TURNO</td>
</tr>
<tr class="TextHeader02" align="center">
	<td width="2%">&nbsp;</td>
	<td width="20%">Empleado</td>
	<td width="13%">Fecha</td>
	<td width="24%">Turno Asignado</td>
	<td width="27%">Turno a Realizar</td>
	<td width="11%">Adicional / Reemplazo?</td>
	<td width="3%"><%=fb.submit("AddEmploys","+",true,viewMode,"","","onClick=\"javascript:setBAction(this.form.name,this.value)\"")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(iEmp);
for (int i=1; i<=iEmp.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) iEmp.get(al.get(i - 1).toString());
	String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";

	String functionName = "verificaData("+i+")";
	StringBuffer dEvent = new StringBuffer();
	//if (cdo.getAction().equalsIgnoreCase("I")) {
		dEvent.append("checkFechaAsignado(");
		dEvent.append(i);
		dEvent.append(")");
	//}
	String color = "TextRow01";
	if (i%2 == 0) color = "TextRow02";
%>
<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
<%=fb.hidden("num_empleado"+i,cdo.getColValue("num_empleado"))%>
<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
<%=fb.hidden("nombre_empleado"+i,cdo.getColValue("nombre_empleado"))%>
<%=fb.hidden("fecha_tnuevo"+i,cdo.getColValue("fecha_tnuevo"))%>
<%=fb.hidden("provincia_ca"+i,cdo.getColValue("provincia_ca"))%>
<%=fb.hidden("sigla_ca"+i,cdo.getColValue("sigla_ca"))%>
<%=fb.hidden("tomo_ca"+i,cdo.getColValue("tomo_ca"))%>
<%=fb.hidden("asiento_ca"+i,cdo.getColValue("asiento_ca"))%>
<%=fb.hidden("num_empleado_ca"+i,cdo.getColValue("num_empleado_ca"))%>
<%=fb.hidden("emp_id_ca"+i,cdo.getColValue("emp_id_ca"))%>
<%=fb.hidden("nombre_empleado_ca"+i,cdo.getColValue("nombre_empleado_ca"))%>
<%=fb.hidden("mes_ca"+i,cdo.getColValue("mes_ca"))%>
<%=fb.hidden("anio_ca"+i,cdo.getColValue("anio_ca"))%>
<%=fb.hidden("ta_programado"+i,cdo.getColValue("ta_programado"))%>
<%=fb.hidden("tn_programado"+i,cdo.getColValue("tn_programado"))%>

<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("action"+i,cdo.getAction())%>
<%=fb.hidden("key"+i,cdo.getKey())%>
<%=fb.hidden("fecha_tasignado_old"+i,cdo.getColValue("fecha_tasignado"))%>
<tr class="<%=color%>" align="center"<%=style%>>
	<td><%=cdo.getColValue("secuencia")%></td>
	<td align="left"><%=cdo.getColValue("num_empleado")%> - <%=cdo.getColValue("nombre_empleado")%></td>
	<td>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1"/>
		<jsp:param name="clearOption" value="true"/>
		<jsp:param name="nameOfTBox1" value="<%="fecha_tasignado"+i%>"/>
		<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_tasignado")%>"/>
		<jsp:param name="fieldClass" value="Text10"/>
		<jsp:param name="buttonClass" value="Text10"/>
		<jsp:param name="clearOption" value="true"/>
		<jsp:param name="jsEvent" value="<%=dEvent%>"/>
		<jsp:param name="onChange" value="<%=dEvent%>"/>
		<jsp:param name="readonly" value="<%=(viewMode?"y":"n")%>"/>
		<jsp:param name="appendOnClickEvt" value="<%="document.form0.fecha_tasignado_old"+i+".value=document.form0.fecha_tasignado"+i+".value;"%>"/>
		</jsp:include>
	</td>
	<td><%=fb.textBox("turno_asignado"+i,cdo.getColValue("turno_asignado"),false,false,true,5,5,"Text10",null,null)%><%=fb.textBox("turno_asignado_desc"+i,cdo.getColValue("turno_asignado_desc"),false,false,true,30,100,"Text10",null,null)%></td>
	<td><%=fb.button("btnTurnoNuevo"+i,"...",true,viewMode,"Text10",null,"onClick=\"javascript:showTurnoList("+i+")\"")%>
	<%=fb.textBox("turno_nuevo"+i,cdo.getColValue("turno_nuevo"),false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("turno_nuevo_desc"+i,cdo.getColValue("turno_nuevo_desc"),false,false,true,30,100,"Text10",null,null)%></td>
	<td><%=fb.select("adic"+i,"R=REEMPLAZA,A=ADICIONAL",cdo.getColValue("adic"),false,viewMode,0,"Text10",null,null)%></td>
	<td><%=fb.submit("rem"+i,"X",true,viewMode,"Text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
<% } %>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
} else {
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));
	String itemRemoved = "";

	CommonDataObject cdo = new CommonDataObject();
	if (baction.equalsIgnoreCase("guardar")) {
		//Header
		cdo.addColValue("codigo",codigo);
		cdo.addColValue("motivo_cambio",request.getParameter("motivo_cambio"));
		cdo.addColValue("fecha_solicitud",request.getParameter("fecha_solicitud"));
		cdo.addColValue("provincia",request.getParameter("provincia"));
		cdo.addColValue("sigla",request.getParameter("sigla"));
		cdo.addColValue("tomo",request.getParameter("tomo"));
		cdo.addColValue("asiento",request.getParameter("asiento"));
		cdo.addColValue("num_empleado",request.getParameter("num_empleado"));
		cdo.addColValue("emp_id",request.getParameter("emp_id"));
		cdo.addColValue("observaciones",request.getParameter("observaciones"));
		cdo.addColValue("fecha_modificacion","sysdate");
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));

		if (mode.equalsIgnoreCase("add")) {
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("anio",anio);
			cdo.addColValue("mes",mes);
			cdo.addColValue("grupo",grupo);
			cdo.addColValue("aprobado","N");
			cdo.addColValue("fecha_creacion","sysdate");
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));

			cdo.setAutoIncCol("codigo");
			cdo.setAutoIncWhereClause("compania = "+session.getAttribute("_companyId")+" and anio = "+anio+" and mes = "+mes+" and grupo = "+grupo);
			cdo.addPkColValue("codigo","");
		} else if (mode.equalsIgnoreCase("approve")) {
			cdo.addColValue("aprobado",request.getParameter("aprobado"));
			cdo.addColValue("fecha_aprobacion","sysdate");
			cdo.addColValue("aprobado_por",(String) session.getAttribute("_userName"));
		}

		cdo.setTableName("tbl_pla_ct_enc_cambio_programa");

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		if (mode.equalsIgnoreCase("add")) {
			cdo.setWhereClause("compania = "+session.getAttribute("_companyId")+" and anio = "+anio+" and mes = "+mes+" and grupo = "+grupo);
			SQLMgr.insert(cdo,true,true,false);
			codigo = SQLMgr.getPkColValue("codigo");
		} else if (mode.equalsIgnoreCase("edit") || mode.equalsIgnoreCase("approve")) {
			cdo.setWhereClause("compania = "+session.getAttribute("_companyId")+" and anio = "+anio+" and mes = "+mes+" and grupo = "+grupo+" and codigo = "+codigo);
			SQLMgr.update(cdo,true,true,false);
		}
	}

	al.clear();
	iEmp.clear();
	for (int i=1; i<=size; i++) {
		CommonDataObject det = new CommonDataObject();

		det.setKey(i);
		det.setAction(request.getParameter("action"+i));
		det.setTableName("tbl_pla_ct_det_cambio_programa");
		det.setAutoIncCol("secuencia");
		det.setAutoIncWhereClause("compania = "+session.getAttribute("_companyId")+" and anio = "+anio+" and mes = "+mes+" and grupo = "+grupo+" and codigo = "+codigo);
		det.setWhereClause("compania = "+session.getAttribute("_companyId")+" and anio = "+anio+" and mes = "+mes+" and grupo = "+grupo+" and codigo = "+codigo+" and secuencia = "+request.getParameter("secuencia"+i));

		det.addColValue("secuencia",request.getParameter("secuencia"+i));
		det.addColValue("fecha_solicitud",request.getParameter("fecha_solicitud"));
		det.addColValue("provincia",request.getParameter("provincia"+i));
		det.addColValue("sigla",request.getParameter("sigla"+i));
		det.addColValue("tomo",request.getParameter("tomo"+i));
		det.addColValue("asiento",request.getParameter("asiento"+i));
		det.addColValue("num_empleado",request.getParameter("num_empleado"+i));
		det.addColValue("emp_id",request.getParameter("emp_id"+i));
		det.addColValue("nombre_empleado",request.getParameter("nombre_empleado"+i));
		det.addColValue("turno_asignado",request.getParameter("turno_asignado"+i));
		det.addColValue("turno_asignado_desc",request.getParameter("turno_asignado_desc"+i));
		det.addColValue("fecha_tasignado",request.getParameter("fecha_tasignado"+i));
		det.addColValue("turno_nuevo",request.getParameter("turno_nuevo"+i));
		det.addColValue("turno_nuevo_desc",request.getParameter("turno_nuevo_desc"+i));
		det.addColValue("fecha_tnuevo",request.getParameter("fecha_tnuevo"+i));
		/*det.addColValue("provincia_ca",request.getParameter("provincia_ca"+i));
		det.addColValue("sigla_ca",request.getParameter("sigla_ca"+i));
		det.addColValue("tomo_ca",request.getParameter("tomo_ca"+i));
		det.addColValue("asiento_ca",request.getParameter("asiento_ca"+i));
		det.addColValue("num_empleado_ca",request.getParameter("num_empleado_ca"+i));
		det.addColValue("emp_id_ca",request.getParameter("emp_id_ca"+i));
		det.addColValue("nombre_empleado_ca",request.getParameter("nombre_empleado_ca"+i));*/
		det.addColValue("mes_ca",request.getParameter("mes_ca"+i));
		det.addColValue("anio_ca",request.getParameter("anio_ca"+i));
		det.addColValue("adic",request.getParameter("adic"+i));
		if (request.getParameter("adic"+i).equalsIgnoreCase("A")) det.addColValue("motivo_cambio","5");
		else det.addColValue("motivo_cambio",request.getParameter("motivo_cambio"));
		det.addColValue("ta_programado",request.getParameter("ta_programado"+i));
		det.addColValue("tn_programado",request.getParameter("tn_programado"+i));
		det.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		det.addColValue("fecha_modificacion","sysdate");

		if (det.getAction().equalsIgnoreCase("I")) {
			det.addColValue("compania",(String) session.getAttribute("_companyId"));
			det.addColValue("anio",anio);
			det.addColValue("mes",mes);
			det.addColValue("grupo",grupo);
			det.addColValue("codigo",codigo);

			det.addColValue("aprobado","N");
			det.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			det.addColValue("fecha_creacion","sysdate");
		}
		if (mode.equalsIgnoreCase("approve") && cdo.getColValue("aprobado") != null && cdo.getColValue("aprobado").equalsIgnoreCase("S")) {
			det.addColValue("aprobado_por",(String) session.getAttribute("_userName"));
			det.addColValue("fecha_aprobacion","sysdate");
			det.addColValue("aprobado","S");
			det.addColValue("ta_programado",request.getParameter("ta_programado"+i));
			//det.addColValue("tn_programado",request.getParameter("tn_programado"+i));
			
			det.addColValue("tn_programado","S"); //agregado 30/07/2013 José Acevedo
		} 

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {
			itemRemoved = request.getParameter("emp_id"+i);
			if (det.getAction().equalsIgnoreCase("I")) det.setAction("X");//if it is not in DB then remove it
			else det.setAction("D");
		}

		if (!det.getAction().equalsIgnoreCase("X")) {
			try {
				iEmp.put(det.getKey(),det);
				al.add(det);
			} catch(Exception e) {
				System.err.println(e.getMessage());
			}
		}
	}

	if (!itemRemoved.equals("")) {
		vEmp.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&grupo="+grupo+"&area="+area+"&anio="+anio+"&mes="+mes+"&codigo="+codigo);
		return;
	} else if (baction.equalsIgnoreCase("+")) {
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&grupo="+grupo+"&area="+area+"&anio="+anio+"&mes="+mes+"&codigo="+codigo);
		return;
	} else if (baction.equalsIgnoreCase("Guardar")) {
		SQLMgr.saveList(al,true,false,false,true);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function closeWindow(){
	parent.document.form0.errCode.value=<%=SQLMgr.getErrCode()%>;
	parent.document.form0.errMsg.value='<%=SQLMgr.getErrMsg()%>';
	parent.document.form0.baction.value='<%=request.getParameter("baction")%>';
	parent.document.form0.codigo.value='<%=codigo%>';
<% if (SQLMgr.getErrCode().equals("1")) { %>parent.document.form0.submit();<% } else { %>alert('<%=SQLMgr.getErrMsg()%>');parent.form0BlockButtons(false);history.go(-1);<% } %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>