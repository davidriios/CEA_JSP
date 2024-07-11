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
<jsp:useBean id="AccMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />
<%
/**
===============================================================================
FORMA								MENU																																				NOMBRE EN FORMA
INV950128						INVENTARIO\TRANSACCIONES\CODIGOS AXA.																				ENLACE DEL CODIGO DEL MEDICAMENTO CON LOS CODIGOS DE AXA.
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AccMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alTPR = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String fecha = request.getParameter("fecha");
String emp_id = request.getParameter("emp_id");
boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();
int cont = 0;
if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(emp_id != null && fecha != null && change == null){
		sql = "select a.compania, a.ue_codigo, a.anio, a.periodo, a.provincia, a.sigla, a.tomo, a.asiento, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.codigo, a.secuencia, a.tipo_he, a.cantidad, a.generado, to_char(a.fecha_generado, 'dd/mm/yyyy') fecha_generado, to_char(a.hora_desde, 'HH12:MI am') hora_desde, to_char(a.hora_hasta, 'HH12:MI am') hora_hasta, a.semana, a.trx_generada, a.trx_usuario, to_char(a.trx_fecha, 'dd/mm/yyyy') trx_fecha, a.anio_pago, a.periodo_pago, a.tipo_detalle, a.emp_id, b.descripcion dsp_tipo_hora, nvl(b.factor_multi, 0) factor_multi, c.te_hent enc_hora_inicio, c.te_hsal enc_hora_final, d.rata_hora from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_st_det_turext c, tbl_pla_empleado d where a.emp_id = "+emp_id+" and a.compania = "+(String) session.getAttribute("_companyId")+" and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fecha+"', 'dd/mm/yyyy') and a.tipo_he = b.codigo and a.ue_codigo = c.ue_codigo and a.anio = c.anio and a.periodo = c.periodo and a.emp_id = c.emp_id and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date(to_char(c.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') and a.codigo = c.codigo and a.emp_id = d.emp_id";
		alTPR = SQLMgr.getDataList(sql);
		sql = "select round (nvl (a.rata_hora, 0) * b.monto_pagar, 2) total_monto_pagar, b.cantidad from tbl_pla_empleado a, (select a.emp_id, sum (a.cantidad) cantidad, sum (a.cantidad * nvl (b.factor_multi, 0)) monto_pagar from tbl_pla_st_det_disttur a, tbl_pla_t_horas_ext b, tbl_pla_st_det_turext c where a.emp_id = "+emp_id+" and a.compania = "+(String) session.getAttribute("_companyId")+" and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fecha+"', 'dd/mm/yyyy') and a.tipo_he = b.codigo and a.ue_codigo = c.ue_codigo and a.anio = c.anio and a.periodo = c.periodo and a.emp_id = c.emp_id and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date(to_char(c.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') and a.codigo = c.codigo group by a.emp_id) b where a.emp_id = "+emp_id+" and a.emp_id = b.emp_id";
		cdoT = SQLMgr.getData(sql);
		if(cdoT==null) cdoT = new CommonDataObject();
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function doSubmit(action){
	document.form.baction.value 			= action;
	if(action == 'Guardar'){
		formBlockButtons(true);
		if(formValidation() && chkValues()) document.form.submit();
		formBlockButtons(false);
	}
}

function selTurno(i){
	var turno = eval('document.form.tipo_he'+i).value;
	var data = getDBData('<%=request.getContextPath()%>','descripcion, nvl(factor_multi, 0)','tbl_pla_t_horas_ext','codigo = '+turno,'');
	var arr_cursor = new Array();
	if(validaTipoHora(turno)){
		if(data!=''){
			arr_cursor = splitCols(data);
			eval('document.form.dsp_tipo_hora'+i).value	= arr_cursor[0];
			eval('document.form.factor_multi'+i).value	= arr_cursor[1];
			eval('document.form.tipo_he2'+i).value = turno;
		} else {
			eval('document.form.tipo_he'+i).value = eval('document.form.tipo_he2'+i).value;
			alert('CODIGO INVALIDO');
			selTurno(i);
		}
		calcTotales();
	} else {
		alert('No puede repetir el mismo Tipo de Hora!');
		eval('document.form.tipo_he'+i).value = eval('document.form.tipo_he2'+i).value;
	}
}

function calcTotales(){
	var size = <%=alTPR.size()%>;
	var monto_pagar = 0.00, totCantidad = 0, rata_hora = 0;
	for(i=0;i<size;i++){
		var cantidad = eval('document.form.cantidad'+i).value;
		var factor_multi = eval('document.form.factor_multi'+i).value;
		monto_pagar += parseFloat(cantidad)*parseFloat(factor_multi);
		totCantidad += parseFloat(cantidad);
		rata_hora = eval('document.form.rata_hora'+i).value;
	}
	document.form.cantidad.value = totCantidad;
	document.form.total_monto_pagar.value = monto_pagar * rata_hora;
}

function validaTipoHora(turno){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.tipo_he'+i).value == turno) x++;
	}
	if(x>1) return false;
	else return true;
}

function validaTipoHora(turno){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.tipo_he'+i).value == turno) x++;
	}
	if(x>1) return false;
	else return true;
}

function chkValues(){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.hora_desde'+i).value == '') x++;
		if(eval('document.form.hora_hasta'+i).value == '') x++;
	}
	if(x>1) {
		alert('Horario Incorrecto!');
		return false;
	}
	else return true;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()" style="vertical-align:top">

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
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("quincena","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
	<tr class="TextHeaderOver">
		<td width="12%">
			<table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
				<tr class="TextHeader02" height="21">
					<td align="left" colspan="5">Detalle de Sobretiempo Generado por D&iacute;a</td>
				</tr>
				<tr class="TextHeader02" height="21">
					<td align="center">Hora Inicio</td>
					<td align="center">Hora Final</td>
					<td align="center">Cant.</td>
					<td align="center" colspan="2">Tipo de Hora</td>
				</tr>
				<%
				for (int i=0; i<alTPR.size(); i++){
					CommonDataObject cd = (CommonDataObject) alTPR.get(i);
					String color = "";
					String hora_desde = "hora_desde"+i, hora_hasta = "hora_hasta"+i;
					if (i%2 == 0) color = "TextRow02";
					else color = "TextRow01";
					boolean readonly = true;
				%>
				<%=fb.hidden("factor_multi"+i,cd.getColValue("factor_multi"))%>
				<%=fb.hidden("rata_hora"+i,cd.getColValue("rata_hora"))%>
				<%=fb.hidden("tipo_he2"+i,cd.getColValue("tipo_he"))%>
				<%=fb.hidden("tipo_he_origen"+i,cd.getColValue("tipo_he"))%>
				<%=fb.hidden("ue_codigo"+i,cd.getColValue("ue_codigo"))%>
				<%=fb.hidden("anio"+i,cd.getColValue("anio"))%>
				<%=fb.hidden("periodo"+i,cd.getColValue("periodo"))%>
				<%=fb.hidden("codigo"+i,cd.getColValue("codigo"))%>
				<%=fb.hidden("secuencia"+i,cd.getColValue("secuencia"))%>
				<tr class="<%=color%>" align="center">
					<td align="center">
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="<%=hora_desde%>" />
						<jsp:param name="valueOfTBox1" value="<%=cd.getColValue("hora_desde")%>" />
						<jsp:param name="fieldClass" value="text10" />
						<jsp:param name="buttonClass" value="text10" />
						<jsp:param name="format" value="hh12:mi am" />
					</jsp:include>
					<%//=fb.textBox("hora_desde"+i,cd.getColValue("hora_desde"),false,false,false,4,"text10","","")%>
					</td>
					<td align="center">
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="<%=hora_hasta%>" />
						<jsp:param name="valueOfTBox1" value="<%=cd.getColValue("hora_hasta")%>" />
						<jsp:param name="fieldClass" value="text10" />
						<jsp:param name="buttonClass" value="text10" />
						<jsp:param name="format" value="hh12:mi am" />
					</jsp:include>
					<%//=fb.textBox("hora_hasta"+i,cd.getColValue("hora_hasta"),false,false,false,10,"text10","","")%>
					</td>
					<td align="center"><%=fb.textBox("cantidad"+i,cd.getColValue("cantidad"),true,false,false,4,"text10","","")%></td>
					<td align="center"><%=fb.textBox("tipo_he"+i,cd.getColValue("tipo_he"),true,false,false,4,"text10","","onChange=\"javascript:selTurno("+i+")\"")%></td>
					<td align="center"><%=fb.textBox("dsp_tipo_hora"+i,cd.getColValue("dsp_tipo_hora"),false,false,true,40,"text10","","")%></td>
				</tr>
				<%}%>
				<tr class="TextHeader02" height="21">
					<td align="right" colspan="2">Total Horas:</td>
					<td align="center"><%=fb.textBox("cantidad",cdoT.getColValue("cantidad"),false,false,false,4,"text10","","")%></td>
					<td align="center" colspan="2">Total Pagar:&nbsp;<%=fb.textBox("total_monto_pagar",cdoT.getColValue("total_monto_pagar"),false,false,false,10,"text10","","")%></td>
				</tr>
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
		cdo = new CommonDataObject();
		cdo.addColValue("fecha", request.getParameter("fecha"));
		cdo.addColValue("emp_id", request.getParameter("emp_id"));
		cdo.addColValue("tipo_he_origen", request.getParameter("tipo_he_origen"+i));
		cdo.addColValue("tipo_he", request.getParameter("tipo_he"+i));
		cdo.addColValue("cantidad", request.getParameter("cantidad"+i));
		cdo.addColValue("hora_desde", request.getParameter("hora_desde"+i));
		cdo.addColValue("hora_hasta", request.getParameter("hora_hasta"+i));
		cdo.addColValue("ue_codigo", request.getParameter("ue_codigo"+i));
		cdo.addColValue("anio", request.getParameter("anio"+i));
		cdo.addColValue("periodo", request.getParameter("periodo"+i));
		cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
		cdo.addColValue("codigo", request.getParameter("codigo"+i));
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
		alTPR.add(cdo);
	}

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AccMgr.updateDistSobretiempo(alTPR);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if (AccMgr.getErrCode().equals("1")){
%>
	alert('<%=AccMgr.getErrMsg()%>');
	parent.window.setMarDetValuesOnLoad();
<%
} else throw new Exception(AccMgr.getErrMsg());
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