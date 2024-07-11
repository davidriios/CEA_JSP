<%@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable"/>
<%
/*
===============================================================================
=============================================================================== 
*/
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
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String emp_id = request.getParameter("emp_id");
int lineNo = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String anio = CmnMgr.getCurrentDate("yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
//String fecha = request.getParameter("fecha");
//if(fecha==null) fecha = cDateTime;
boolean viewMode = false;
if(mode == null) mode = "add";
if(fp==null) fp="ausencia_rrhh";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change==null){
		String sqlNotas = "select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.tipo_trx, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.secuencia, a.motivo_falta, c.descripcion motivo_falta_desc, to_char(a.hora_entrada, 'hh12:mi am') hora_entrada, to_char(a.fecha_salida, 'dd/mm/yyyy') fecha_salida, to_char(a.hora_salida, 'hh12:mi am') hora_salida, a.comentario, a.accion, a.anio_dev, a.mes_dev, a.quincena_dev, a.anio_des, a.mes_des, a.quincena_des, a.cod_planilla_des, a.estado_dev, to_char(a.fecha_dev, 'dd/mm/yyyy') fecha_dev, a.usuario_creacion, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, a.usuario_modificacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.cantidad, a.vobo_estado, a.vobo_usuario, to_char(a.vobo_fecha, 'dd/mm/yyyy') vobo_fecha, a.emp_id, nvl(b.rata_hora, 0) rata_hora, d.nombre cod_planilla_des_desc, nvl(a.monto, 0) monto, a.tiempo, to_char(a.fecha_des, 'dd/mm/yyyy') fecha_des, a.comentario from tbl_pla_aus_y_tard a, tbl_pla_empleado b, tbl_pla_motivo_falta c, tbl_pla_planilla d where a.compania = b.compania and a.emp_id = b.emp_id and a.accion IN ('DS','DV','ND') AND a.estado_des = 'PE' and a.motivo_falta = c.codigo(+) and a.compania = d.compania and a.cod_planilla_des = d.cod_planilla and a.emp_id = "+emp_id;
		ArrayList alNotas = SQLMgr.getDataList(sqlNotas);
		for(int i = 0; i<alNotas.size(); i++){
			CommonDataObject cdo = (CommonDataObject) alNotas.get(i);
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;

			try{
				emp.put(key, cdo);
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
/*
function doAction(){
	newHeight();
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}
*/
function doAction()
{
	<%
	if(fp.equals("liquidacion")){
	%>
	var size 		= document.form.keySize.value;
	var anio_pago 		= parent.document.form1.anio_pago.value;
	var quincena_pago 	= parent.document.form1.quincena_pago.value;
	if(size>0){
		for(i=0;i<size;i++){
			if(eval('document.form.anio_des'+i).value == '') eval('document.form.anio_des'+i).value = anio_pago;
			if(eval('document.form.quincena_des'+i).value == '') eval('document.form.quincena_des'+i).value = quincena_pago;
		}
	}
	<%}%>
		<%
	if(fp.equals("ausencia")){
	%>
	var size = document.form.keySize.value;
	var anio_pago = parent.document.form1.anio_pago.value;
	var quincena_pago = parent.document.form1.quincena_pago.value;
	if(size>0){
		for(i=0;i<size;i++){
			if(eval('document.form.anio_des'+i).value == '') eval('document.form.anio_des'+i).readOnly=false;
			if(eval('document.form.quincena_des'+i).value == '') eval('document.form.quincena_des'+i).readOnly=false;
			if(eval('document.form.anio_des'+i).value == '') eval('document.form.anio_des'+i).value = anio_pago;
			if(eval('document.form.quincena_des'+i).value == '') eval('document.form.quincena_des'+i).value = quincena_pago;
		}
	}
	<%} %>
	
}

function getCodigo(i){
	abrir_ventana('../common/sel_cod_axa.jsp?fp=<%=fp%>&index='+i);
}

function doSubmit(action){
	var x = 0;
	document.form.baction.value 	= action;
	document.form.provincia.value 	= parent.document.form1.provincia.value;
	document.form.sigla.value 	= parent.document.form1.sigla.value;
	document.form.tomo.value 	= parent.document.form1.tomo.value;
	document.form.asiento.value 	= parent.document.form1.asiento.value;
	document.form.emp_id.value 	= parent.document.form1.emp_id.value;

	if(!parent.form1Validation()){}
	else {
		if(action != 'Guardar') parent.form1BlockButtons(false);
		if(action == 'Guardar' && !formValidation()){parent.form1BlockButtons(false);}
		if(action == 'Guardar' && !chkValues()){
			parent.form1BlockButtons(false);
		} else {
			formBlockButtons(false);
			document.form.submit();
		}
	}
}


function chkValues(){
	var size = <%=emp.size()%>;
	x = 0, y = 0, z = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.fecha'+i).value==''){
			x++;
			y++;
			break;
		} else if(eval('document.form.motivo_falta'+i).value==''){
			x++;
			z++;
			break;
		}
	}
	if(x==0) return true;
	else {
		if(y!=0) alert('Fecha en blanco no permitida');
		if(z!=0) alert('Motivo de falta en blanco no permitido');
		return false;
	}
}

function calcMonto(i){
var rata_hora = parent.document.form1.rata_hora.value;
var tiempo = eval('document.form.tiempo'+i).value;
var tmp1=Math.round(tiempo * rata_hora * 100);
	eval('document.form.comentario'+i).value = rata_hora;
	eval('document.form.monto'+i).value = (tmp1/100).toFixed(2);
}

function addMotivo(index)
{
		abrir_ventana1("../common/search_motivo_falta.jsp?fp=ausencia_rrhh&index="+index);
}

function setTipoTrxValues(i){
	var fecha = eval('document.form.fecha'+i).value;
	var tipo_trx = eval('document.form.tipo_trx'+i).value;
	var emp_id = eval('document.form.emp_id'+i).value;
	eval('document.form.hora_entrada'+i).value 		= '';
	eval('document.form.hora_salida'+i).value = '';

	if (tipo_trx == 2 || tipo_trx == 1){
		eval('document.form.fecha_salida'+i).value = fecha;
		var x = getDBData('<%=request.getContextPath()%>','nvl(to_char(h.hora_gracia_entrada, \'hh12:mi am\'), \' \'), nvl(to_char(h.hora_salida, \'hh12:mi am\'), \' \')','tbl_pla_horario_trab h, tbl_pla_empleado e','h.codigo = e.horario and h.compania = e.compania and e.emp_id = '+emp_id+' and e.compania = <%=(String) session.getAttribute("_companyId")%>','');
		var arr_cursor = new Array();
		if(x!=''){
			arr_cursor = splitCols(x);
			if(arr_cursor[0]!=' ') eval('document.form.hora_entrada'+i).value	= arr_cursor[0];
			if(arr_cursor[1]!=' ') eval('document.form.hora_salida'+i).value	= arr_cursor[1];
		}
	}
}

function motivoFalta(i){
	var fecha = eval('document.form.fecha'+i).value;
	var fecha_salida = eval('document.form.fecha_salida'+i).value;
	var hora_entrada = eval('document.form.hora_entrada'+i).value;
	var hora_salida = eval('document.form.hora_salida'+i).value;
	var tipo_trx = eval('document.form.tipo_trx'+i).value;
	var emp_id = eval('document.form.emp_id'+i).value;
	var accion = eval('document.form.accion'+i).value;
	var motivo_falta = eval('document.form.motivo_falta'+i).value;
	var tiempo = eval('document.form.tiempo'+i).value;
	var cantidad = eval('document.form.cantidad'+i).value;
	//var rata_hora = eval('document.form.rata_hora'+i).value;
	var rata_hora = parent.document.form1.rata_hora.value;
	var total = 0.00, v_horas_dias = 0.00 ;


	var x = getDBData('<%=request.getContextPath()%>','round((to_date(\''+hora_entrada+'\',\'hh12:mi am\') - to_date(to_char(h.hora_entrada, \'hh12:mi am\'), \'hh12:mi am\'))*24, 2) + round((to_date(to_char(h.hora_salida, \'hh12:mi am\'), \'hh12:mi am\') - to_date(\''+hora_salida+'\',\'hh12:mi am\'))*24, 2), h.cant_horas','tbl_pla_horario_trab h, tbl_pla_empleado e', 'h.codigo = e.horario and h.compania = e.compania and e.emp_id = '+emp_id+' and e.compania = <%=(String) session.getAttribute("_companyId")%>','');
	var arr_cursor = new Array();
	if(x!=''){
		arr_cursor = splitCols(x);
		total	= arr_cursor[0];
		v_horas_dias	= arr_cursor[1];
	}
/// alert('estoy' +total );
	if (accion == 'DS'){// DESCONTAR
		eval('document.form.anio_des'+i).readonly = false;
		eval('document.form.quincena_des'+i).readonly = false;
		eval('document.form.estado_des'+i).readonly = false;
		eval('document.form.fecha_des'+i).readonly = false;
		eval('document.form.tiempo'+i).readonly = false;
		eval('document.form.cantidad'+i).readonly = false;
		eval('document.form.monto'+i).readonly = false;

		if (motivo_falta == 10 || motivo_falta == 11)
		{// OMISION DE ENTRADA(10) / SALIDA(11)
			eval('document.form.tiempo'+i).value = tiempo;
			eval('document.form.cantidad'+i).value = tiempo;
			eval('document.form.monto'+i).value = ((tiempo * rata_hora * 100)/ 100).toFixed(2);
			
			
			
		} else {
			if (tipo_trx = 2 &&  fecha != '' && hora_entrada != '' && fecha_salida != '' && hora_salida != ''){
				eval('document.form.tiempo'+i).value = total;
				eval('document.form.cantidad'+i).value = total;
				eval('document.form.monto'+i).value = ((total * rata_hora * 100) / 100).toFixed(2);
			} else if(tipo_trx == 1){
				eval('document.form.tiempo'+i).value = v_horas_dias;
				eval('document.form.cantidad'+i).value = v_horas_dias;
				eval('document.form.monto'+i).value = ((v_horas_dias * rata_hora * 100) / 100).toFixed(2);
			}
		}
	} else {
		if (accion == 'DV'){ //DEVOLVER
			eval('document.form.anio_des'+i).readonly = false;
			eval('document.form.quincena_des'+i).readonly = false;
			eval('document.form.estado_des'+i).readonly = false;
			eval('document.form.fecha_des'+i).readonly = false;
			eval('document.form.tiempo'+i).readonly = false;
			eval('document.form.cantidad'+i).readonly = false;
			eval('document.form.monto'+i).readonly = false;

			if (motivo_falta == 10 || motivo_falta == 11){
				eval('document.form.tiempo'+i).value = tiempo;
				eval('document.form.cantidad'+i).value = tiempo;
			} else {
				if (tipo_trx == 2 && fecha != '' && hora_entrada != '' && fecha_salida != '' && hora_salida != ''){
					eval('document.form.tiempo'+i).value = total;
					eval('document.form.cantidad'+i).value = total;
					eval('document.form.monto'+i).value = ((total * rata_hora *100) / 100).toFixed(2);
				} else if (tipo_trx == 1){
					eval('document.form.tiempo'+i).value = v_horas_dias;
					eval('document.form.cantidad'+i).value = v_horas_dias;
					eval('document.form.monto'+i).value = ((v_horas_dias * rata_hora *100) / 100).toFixed(2);
				}
			}
		} else {
			eval('document.form.anio_des'+i).readonly = true;
			eval('document.form.quincena_des'+i).readonly = true;
			eval('document.form.estado_des'+i).readonly = true;
			eval('document.form.fecha_des'+i).readonly = true;
			eval('document.form.tiempo'+i).readonly = true;
			eval('document.form.cantidad'+i).readonly = true;
			eval('document.form.monto'+i).readonly = true;
		}
	} //end devolver

	if(tiempo != '' )
	{
	var v_minutos = 0;
	var v_horas = getDBData('<%=request.getContextPath()%>','trunc('+tiempo+',0)','dual' , '','');
	var v_minutos = getDBData('<%=request.getContextPath()%>','round((\''+tiempo+'\' - trunc('+tiempo+',0))*100/60,2)','dual' , '','');
	//	v_horas	= trunc(tiempo,0);
	//	v_minutos	= (tiempo - trunc(tiempo,0))*100;
	//	v_minutos	= ROUND(v_minutos/60,2);
		v_cantidad	= v_horas ;
// alert('***************'+v_cantidad);
		var tmp=Math.round(v_cantidad * rata_hora * 100);
				eval('document.form.monto'+i).value = (tmp/100).toFixed(2);


	} else
	{
		if(tiempo==''||tiempo=='NaN') tiempo=0;
			var tmp1=Math.round(tiempo * rata_hora * 100);
			eval('document.form.monto'+i).value = (tmp1/100).toFixed(2);

	}
}

function showPlanillaList(i){
	abrir_ventana('../rhplanilla/planilla_list.jsp?fp=<%=fp%>&id='+i);
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
<%=fb.hidden("provincia","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("emp_id",emp_id)%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td colspan="12" align="right"><%=fb.button("AddEmploys","+",false,false,"", "", "onClick=\"javascript:doSubmit(this.value)\"")%></td>
</tr>
	<%
	if (emp.size() > 0) al = CmnMgr.reverseRecords(emp);
	for (int i=0; i<emp.size(); i++){
		key = al.get(i).toString();
		CommonDataObject ad = (CommonDataObject) emp.get(key);

		String color = "";
		String fecha = "fecha"+i;
		String fecha_salida = "fecha_salida"+i;
		String fecha_des = "fecha_des"+i;
		String hora_entrada = "hora_entrada"+i;
		String hora_salida = "hora_salida"+i;
		if (i%2 == 0) color = "TextRow02";
		else color = "TextRow01";
		boolean readonly = true;
	%>
	<tr class="TextHeader02">
		<td align="center">Sec.</td>
		<td align="center">Tipo Trx.</td>
		<td align="center">Fecha</td>
		<td align="center">Hora Entrada</td>
		<td align="center">Fecha Salida</td>
		<td align="center">Hora Salida</td>
		<td align="center">Tiempo</td>
		<td align="center">Cant.</td>
		<td align="center">Acci&oacute;n</td>
				<td align="center">Motivo Falta</td>
		<td align="center">Monto</td>
		<td align="center">&nbsp;</td>
	</tr>

	<%=fb.hidden("emp_id"+i, ad.getColValue("emp_id"))%>
	<%=fb.hidden("provincia"+i, ad.getColValue("provincia"))%>
	<%=fb.hidden("sigla"+i, ad.getColValue("sigla"))%>
	<%=fb.hidden("tomo"+i, ad.getColValue("tomo"))%>
	<%=fb.hidden("asiento"+i, ad.getColValue("asiento"))%>
	<%=fb.hidden("rata_hora"+i, ad.getColValue("rata_hora"))%>

	<tr class="<%=color%>" align="center">
		<td><%=fb.intBox("secuencia"+i,ad.getColValue("secuencia"),false,false,true,2,4,"Text10",null,"")%></td>
		<td><%=fb.select("tipo_trx"+i,"1=Ausencia,2=Tardanza",ad.getColValue("tipo_trx"),false,false,0,"Text10",null,"onChange=\"javascript:setTipoTrxValues("+i+")\"")%></td>
		<td>
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1"/>
			<jsp:param name="clearOption" value="true"/>
			<jsp:param name="nameOfTBox1" value="<%=fecha%>"/>
			<jsp:param name="valueOfTBox1" value="<%=(ad.getColValue("fecha")==null)?fecha:ad.getColValue("fecha")%>"/>
			<jsp:param name="fieldClass" value="Text10"/>
			<jsp:param name="buttonClass" value="Text10"/>
			</jsp:include>
		</td>
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1"/>
			<jsp:param name="nameOfTBox1" value="<%=hora_entrada%>"/>
			<jsp:param name="format" value="hh12:mi am"/>
			<jsp:param name="valueOfTBox1" value="<%=(ad.getColValue("hora_entrada")==null)?"":ad.getColValue("hora_entrada")%>"/>


			</jsp:include>
		</td>
		<td>
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1"/>
			<jsp:param name="clearOption" value="true"/>
			<jsp:param name="nameOfTBox1" value="<%=fecha_salida%>"/>
			<jsp:param name="valueOfTBox1" value="<%=(ad.getColValue("fecha_salida")==null)?"":ad.getColValue("fecha_salida")%>"/>
			<jsp:param name="fieldClass" value="Text10"/>
			<jsp:param name="buttonClass" value="Text10"/>
			</jsp:include>
		</td>
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1"/>
			<jsp:param name="nameOfTBox1" value="<%=hora_salida%>"/>
			<jsp:param name="format" value="hh12:mi am"/>
			<jsp:param name="valueOfTBox1" value="<%=(ad.getColValue("hora_salida")==null)?"":ad.getColValue("hora_salida")%>"/>

			</jsp:include>
		</td>



		<td> <%=fb.decBox("tiempo"+i,ad.getColValue("tiempo"),false,false,false,5,8.2,"Text10",null,"onChange=\"javascript:calcMonto("+i+")\"")%></td>
		<td><%=fb.decBox("cantidad"+i,ad.getColValue("cantidad"),false,false,false,3,6.2,null,null,"","",false,"")%></td>
			<td><%=fb.select("accion"+i,"ND=NO DESCONTAR,DS=DESCONTAR,DV=DEVOLVER",ad.getColValue("accion"),false,false,0,"Text10",null,"onChange=\"javascript:motivoFalta("+i+")\"")%></td>
			<td>
				<%=fb.intBox("motivo_falta"+i,ad.getColValue("motivo_falta"),false,false,true,2,2,"Text10",null,null)%>
				<%=fb.textBox("motivo_falta_desc"+i,ad.getColValue("motivo_falta_desc"),false,false,true,25,25,"Text10",null,null)%>
				<%=fb.button("btnmotivo"+i,"...",true,false,null,null,"onClick=\"javascript:addMotivo("+i+")\"")%>
		</td>
		<td><%=fb.decBox("monto"+i,ad.getColValue("monto"),false,false,viewMode,5, 8.2,null,null,"onFocus=\"this.select();\"","Monto",false,"")%></td>
		<td align="center"><%=fb.submit("del"+i, "x", false, true, "", "", "onClick=\"javascript:doSubmit(this.value);\"")%></td>
	</tr>
	<tr>
		<td colspan="12"><table width="100%">
			<tr class="TextHeader02">
				<td align="center">A&ntilde;o</td>
				<td align="center">Periodo</td>
				<td align="center">Planilla</td>
				<td align="center">Estado</td>
				<td align="center">Fecha</td>
				<td align="center">Comentario</td>
			</tr>
			<tr class="<%=color%>" align="center">
				<td><%=fb.intBox("anio_des"+i,ad.getColValue("anio_des"),false,false,true,5,5,"Text10",null,"")%></td>
				<td><%=fb.intBox("quincena_des"+i,ad.getColValue("quincena_des"),false,false,true,5,5,"Text10",null,"")%></td>
				<td>
				<%=fb.intBox("cod_planilla_des"+i,ad.getColValue("cod_planilla_des"),false,false,true,5,5,"Text10",null,"")%>
				<%=fb.textBox("cod_planilla_des_desc"+i,ad.getColValue("cod_planilla_des_desc"),false,false,true,40,50,"Text10",null,null)%>
				<%if(!ad.getColValue("secuencia").equals("0")&&fp.equalsIgnoreCase("liquidacion")){%>
				<%=fb.button("btnPlanilla","...",true,viewMode,"Text10",null,"onClick=\"javascript:showPlanillaList("+i+")\"")%>
				<%}%>
				 <%if(fp.equalsIgnoreCase("ausencia")){%>
				<%=fb.button("btnPlanilla","...",true,viewMode,"Text10",null,"onClick=\"javascript:showPlanillaList("+i+")\"")%>
				<%}%>
				</td>
				<td><%=fb.select("estado_des"+i,"PE=PENDIENTE,DS=DESCONTADO,AN=ANULADO",ad.getColValue("estado_des"),false,false,0,"Text10",null,null)%></td>
				<td>

					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="<%=fecha_des%>"/>
					<jsp:param name="valueOfTBox1" value="<%=(ad.getColValue("fecha_des")==null)?"":ad.getColValue("fecha_des")%>"/>
					<jsp:param name="fieldClass" value="Text10"/>
					<jsp:param name="buttonClass" value="Text10"/>
					</jsp:include>

				</td>

				<td><%=fb.textarea("comentario"+i,ad.getColValue("comentario"),false,false,false,50,2)%></td>
			</tr>
		</table>
	 </td>
	</tr>
	<%
}
%>
</table>
<%=fb.hidden("keySize",""+emp.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	System.out.println("-----------------------POST-----------------------1");

	String dl = "", sqlItem = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	emp.clear();
	al.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("del"+i)==null){
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			cdo.addColValue("provincia", request.getParameter("provincia"+i));
			cdo.addColValue("sigla", request.getParameter("sigla"+i));
			cdo.addColValue("tomo", request.getParameter("tomo"+i));
			cdo.addColValue("asiento", request.getParameter("asiento"+i));
			cdo.addColValue("fecha", request.getParameter("fecha"+i));
			if(request.getParameter("fecha_salida"+i)!=null && !request.getParameter("fecha_salida"+i).equals("")) cdo.addColValue("fecha_salida", request.getParameter("fecha_salida"+i));
			if(request.getParameter("tipo_trx"+i)!=null && !request.getParameter("tipo_trx"+i).equals("")) cdo.addColValue("tipo_trx", request.getParameter("tipo_trx"+i));
			if(request.getParameter("secuencia"+i)!=null && !request.getParameter("secuencia"+i).equals("")) cdo.addColValue("secuencia", request.getParameter("secuencia"+i));

			if(request.getParameter("hora_entrada"+i)!=null && !request.getParameter("hora_entrada"+i).equals("")) cdo.addColValue("hora_entrada", request.getParameter("hora_entrada"+i));
			if(request.getParameter("hora_salida"+i)!=null && !request.getParameter("hora_salida"+i).equals("")) cdo.addColValue("hora_salida", request.getParameter("hora_salida"+i));
			if(request.getParameter("motivo_falta"+i)!=null && !request.getParameter("motivo_falta"+i).equals("")) cdo.addColValue("motivo_falta", request.getParameter("motivo_falta"+i));
			if(request.getParameter("motivo_falta_desc"+i)!=null && !request.getParameter("motivo_falta_desc"+i).equals("")) cdo.addColValue("motivo_falta_desc", request.getParameter("motivo_falta_desc"+i));
			if(request.getParameter("accion"+i)!=null && !request.getParameter("accion"+i).equals("")) cdo.addColValue("accion", request.getParameter("accion"+i));
			if(request.getParameter("tiempo"+i)!=null && !request.getParameter("tiempo"+i).equals("")) cdo.addColValue("tiempo", request.getParameter("tiempo"+i));
			if(request.getParameter("cantidad"+i)!=null && !request.getParameter("cantidad"+i).equals("")) cdo.addColValue("cantidad", request.getParameter("cantidad"+i));
			if(request.getParameter("monto"+i)!=null && !request.getParameter("monto"+i).equals("")) cdo.addColValue("monto", request.getParameter("monto"+i));
			if(request.getParameter("anio_des"+i)!=null && !request.getParameter("anio_des"+i).equals("")) cdo.addColValue("anio_des", request.getParameter("anio_des"+i));
			if(request.getParameter("quincena_des"+i)!=null && !request.getParameter("quincena_des"+i).equals("")) cdo.addColValue("quincena_des", request.getParameter("quincena_des"+i));
			if(request.getParameter("cod_planilla_des"+i)!=null && !request.getParameter("cod_planilla_des"+i).equals("")) cdo.addColValue("cod_planilla_des", request.getParameter("cod_planilla_des"+i));
			if(request.getParameter("cod_planilla_des_desc"+i)!=null && !request.getParameter("cod_planilla_des_desc"+i).equals("")) cdo.addColValue("cod_planilla_des_desc", request.getParameter("cod_planilla_des_desc"+i));
			if(request.getParameter("estado_des"+i)!=null && !request.getParameter("estado_des"+i).equals("")) cdo.addColValue("estado_des", request.getParameter("estado_des"+i));
			if(request.getParameter("fecha_des"+i)!=null && !request.getParameter("fecha_des"+i).equals("")) cdo.addColValue("fecha_des", request.getParameter("fecha_des"+i));
			if(request.getParameter("comentario"+i)!=null && !request.getParameter("comentario"+i).equals("")) cdo.addColValue("comentario", request.getParameter("comentario"+i));
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));

			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;

			try{
				emp.put(key, cdo);
				al.add(cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		} else {
			System.out.println("-----------------------POST-----------------------5");
			dl = "1";
		} // end if
	} // end for
	lineNo = emp.size();
	if(request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("+")){
		keySize = 0;
		CommonDataObject cdoMFD = SQLMgr.getData("select nombre from tbl_pla_planilla where cod_planilla = 8 and compania = "+(String) session.getAttribute("_companyId"));
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("emp_id", request.getParameter("emp_id"));
		cdo.addColValue("provincia", request.getParameter("provincia"));
		cdo.addColValue("sigla", request.getParameter("sigla"));
		cdo.addColValue("tomo", request.getParameter("tomo"));
		cdo.addColValue("asiento", request.getParameter("asiento"));
		cdo.addColValue("fecha", "");
		cdo.addColValue("fecha_salida", "");
		cdo.addColValue("tipo_trx", "");
		cdo.addColValue("secuencia", "0");
		cdo.addColValue("hora_entrada", "");
		cdo.addColValue("hora_salida", "");
		cdo.addColValue("motivo_falta", "");
		cdo.addColValue("motivo_falta_desc", "");
		cdo.addColValue("accion", "");
		cdo.addColValue("tiempo", "");
		cdo.addColValue("cantidad", "");
		cdo.addColValue("monto", "");
		cdo.addColValue("anio_des", "");
		cdo.addColValue("comentario", "");
		cdo.addColValue("quincena_des", "");
		if(fp.equalsIgnoreCase("liquidacion")) {
		cdo.addColValue("cod_planilla_des", "8");
		cdo.addColValue("cod_planilla_des_desc", cdoMFD.getColValue("nombre"));
		}
		else {
		cdo.addColValue("cod_planilla_des", "1");
		cdo.addColValue("cod_planilla_des_desc", "PLANILLA QUINCENAL DE EMPLEADOS");
		}
		cdo.addColValue("estado_des", "");
		cdo.addColValue("fecha_des", "");
		lineNo++;
		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;

		try{
			emp.put(key, cdo);
			al.add(cdo);
		} catch (Exception e){
			System.out.println("Unable to add item...");
		}
	}

	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../rhplanilla/reg_asistencia_det.jsp?mode="+mode+"&change=1&type=2&emp_id="+emp_id+"&fp="+fp);
		return;
	}

	if(request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("+")){
		response.sendRedirect("../rhplanilla/reg_asistencia_det.jsp?mode="+mode+"&change=1&type=1&emp_id="+emp_id+"&fp="+fp);
		return;
	}

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AEmpMgr.addAusencias(al);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
	parent.document.form1.errCode.value = <%=AEmpMgr.getErrCode()%>;
	parent.document.form1.errMsg.value = '<%=AEmpMgr.getErrMsg()%>';
	//parent.window.location='<%=request.getContextPath()%>/rhplanilla/reg_asistencia.jsp?emp_id=<%=emp_id%>';
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