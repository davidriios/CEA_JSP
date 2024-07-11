<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String compania = request.getParameter("compania");
String caja = request.getParameter("caja");
String banco = request.getParameter("banco");
String consecutivo = request.getParameter("consecutivo");
String cuenta = request.getParameter("cuenta");
String fp = request.getParameter("fp");
String ip = request.getRemoteAddr();

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
if (fp == null) fp = "deposito";
if(mode.equals("view")) viewMode=true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
if (mode.equalsIgnoreCase("add"))
	{
		consecutivo = "0";
		cdo = new CommonDataObject();
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("usuario",(String) session.getAttribute("_userName"));
		cdo.addColValue("tipo_dep","1");
		cdo.addColValue("tipo_tarjeta","1");
		cdo.addColValue("sobrante","N");
		if (!viewMode) mode = "add";
		CommonDataObject cdo1 = SQLMgr.getData("select nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'CJA_VALIDA_ESTADO_TUR'),'S') as validaTurno from dual");
		cdo.addColValue("valida_edicion",cdo1.getColValue("validaTurno"));
	}
	else
	{
			if (consecutivo == null || caja == null || banco== null || cuenta==null) throw new Exception("Los datos del Depósito no son válido. Por favor intente nuevamente!");
sql="SELECT a.CONSECUTIVO_AG, a.BANCO, a.COMPANIA,a.CUENTA_BANCO as cuenta, to_char(a.F_MOVIMIENTO,'dd/mm/yyyy') as fecha, a.TIPO_MOVIMIENTO,t.descripcion as tipoMovimiento,a.DESCRIPCION, a.NUM_DOCUMENTO, to_char(a.FECHA_CREACION,'dd/mm/yyyy') as fecha_creacion,a.USUARIO_CREACION as usuario,a.VERIFICACION, a.MONTO, a.LADO,a.ESTADO_TRANS, to_char(a.F_ANULACION,'dd/mm/yyyy') as fANULACION, a.OBSERVACION, a.NOTAS_DEBITO, a.NOTAS_CREDITO,a.ESTADO_DEP, to_char(a.FECHA_PAGO,'dd/mm/yyyy') as FECHAPAGO, a.CAJA, nvl(a.MTO_TOT_TARJETA,'') as MTO_TOT_TARJETA  , nvl(a.TIPO_TARJETA,'1')as tipo_tarjeta, nvl(a.COMISION,'') as comision, a.DEVOLUC_TARJ as devolucion, nvl(a.TIPO_DEP,'1')as tipo_dep, a.DEP_MODIF, a.TURNO, a.PAGO, nvl(a.SOBRANTE,'N')as sobrante , co.nombre as nombreCompania, ca.descripcion as nombreCaja,ban.nombre as nombreBanco, cu.descripcion as nombreCuenta,(select c.nombre nombre_cajera from tbl_cja_turnos_x_cajas x,tbl_cja_turnos b, tbl_cja_cajera c where x.cod_turno = b.codigo and b.cja_cajera_cod_cajera = c.cod_cajera and x.compania = c.compania and x.compania = a.compania and x.cod_caja = a.caja and x.cod_turno=a.turno)cajero ,nvl(get_sec_comp_param(a.compania,'CJA_VALIDA_EDIT_DEP'),'S') as valida_edicion,a.itbms  FROM TBL_CON_MOVIM_BANCARIO a , TBL_SEC_COMPANIA co ,TBL_CJA_CAJAS ca ,TBL_CON_BANCO ban, TBL_CON_CUENTA_BANCARIA cu,TBL_CON_TIPO_MOVIMIENTO t where a.CONSECUTIVO_AG ='"+consecutivo+"' and a.banco = '"+banco+"' and co.codigo=a.COMPANIA and ca.codigo=a.caja(+) and ca.compania = a.compania(+) and ban.compania = a.compania and ban.cod_banco=a.banco and cu.cod_banco = a.banco and cu.compania = a.compania and cu.cuenta_banco=a.CUENTA_BANCO and a.cuenta_banco='"+cuenta+"' and a.caja='"+caja+"' and a.compania='"+compania+"' and t.COD_TRANSAC = a.tipo_movimiento";
cdo = SQLMgr.getData(sql);

if (!viewMode) mode = "edit";

}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Registro de Depósitos- '+document.title;
function doAction(){}
function CheckFecha()
{
		var x=0;
		var com = eval('document.form0.compania').value;
		var fecha =eval('document.form0.fecha').value;
		var fecha_cierre = getDBData('<%=request.getContextPath()%>','count(*)','tbl_con_replibros','compania='+com+' and  nvl(comprobante,\'A\')= \'S\' and to_date(to_char(fecha,\'dd/mm/yyyy\'),\'dd/mm/yyyy\')=to_date(\''+fecha+'\',\'dd/mm/yyyy\')','');
		if(fecha_cierre !="0")
		{
			x++;
			alert('Esta fecha ya esta Procesada en el Departamento de Contabilidad...');
		}
		if(x>0)	return false;
			else return true;
}
function showComprobante()
{
<%if (!mode.equalsIgnoreCase("add")){%>
var turno = eval('document.form0.turno').value ;
var caja = eval('document.form0.caja').value ;
var com = eval('document.form0.compania').value ;
abrir_ventana1('../caja/reporte_cajas.jsp?caja='+caja+'&turno='+turno+"&com="+com);
<%}%>
}
function Comision()
{
<%if(mode.equalsIgnoreCase("add") || cdo.getColValue("tipo_dep").trim().equals("2") ){%>
	var tarjeta = eval('document.form0.tipo_tarjeta').value;
	var caja = eval('document.form0.caja').value;
	var turno = eval('document.form0.turno').value;

	var monto =0;
	var dev = 0;
	var deposito = 0;
	var t_tarjeta ='<%=cdo.getColValue("tipo_tarjeta")%>';
	<%if (mode.equalsIgnoreCase("add") ){%>
	if (document.form0.tar_monto.value != '' ) deposito =  parseFloat(eval('document.form0.tar_monto').value)
	<%}else{%>
	if (document.form0.venta_bruta.value != '' )
		if(t_tarjeta !=tarjeta)
		deposito =  parseFloat(eval('document.form0.venta_bruta').value)
		else deposito =  parseFloat(eval('document.form0.tar_monto').value)
	<%}%>

	if(document.form0.monto_devolucion.value != '') dev = parseFloat(eval('document.form0.monto_devolucion').value);
	monto = deposito - dev;
	var com = getDBData('<%=request.getContextPath()%>','tipo_valor,comision','tbl_cja_comision_tarjetas','tipo_tarjeta='+tarjeta+' and ABS('+monto+') >= nvl(rango_inicial,0) and  ABS('+monto+') <= nvl(rango_final,0)','');


	if(com !=null && com !=''){

com = getDBData('<%=request.getContextPath()%>','nvl(getComisionDep(<%=session.getAttribute("_companyId")%>,'+tarjeta+','+monto+','+caja+','+turno+'),0) comision','dual','');

	//var itbms = getDBData('<%=request.getContextPath()%>','nvl(itbms,0)','tbl_cja_tipo_tarjeta','codigo='+tarjeta,'');

		var pos = com.indexOf("|");
		var v_comision = com.substr(0,pos);
		var v_itbms = com.substr(pos+1,com.length);

		if(v_comision!='0')eval('document.form0.comision').value =v_comision;
		if(v_itbms!='0')eval('document.form0.itbms').value =v_itbms;


/*
		if(tipo_valor=="P"){
			eval('document.form0.comision').value = ((monto * v_comision)/100).toFixed(2);
		}
		else if(tipo_valor=="M") eval('document.form0.comision').value = v_comision;
		else {eval('document.form0.comision').value = '0';eval('document.form0.itbms').value = '0';}
		//--ITBMS DE COMISIONES
		if(parseFloat(eval('document.form0.comision').value) != 0)eval('document.form0.itbms').value = (eval('document.form0.comision').value *(itbms/100)).toFixed(2);
		else eval('document.form0.itbms').value = "0";
		//eval('document.form0.mto_tot_tarjeta').value =  (monto - eval('document.form0.comision').value ).toFixed(2);
		*/
		eval('document.form0.mto_tot_tarjeta').value =  ((monto ) - eval('document.form0.comision').value - eval('document.form0.itbms').value ).toFixed(2);


	} else {
		alert('Monto de Tarjeta se encuentra fuera de los limites para calcular la comisión'); //No Existen Comisiones Asignadas para este Tipo de Tarjetas
		eval('document.form0.comision').value = "";
		eval('document.form0.mto_tot_tarjeta').value ="";
		eval('document.form0.itbms').value = '0';
	}
<%}%>
}
function CheckTurno()
{
	var x=0;
	var compania = eval('document.form0.compania').value;
	var caja = eval('document.form0.caja').value;
	var turno = eval('document.form0.turno').value;
	var valida_edicion = eval('document.form0.valida_edicion').value;
	if(valida_edicion=='S'){
	var com = getDBData('<%=request.getContextPath()%>','cod_turno','tbl_cja_turnos_x_cajas','compania='+compania+' and cod_turno ='+turno+' and  estatus in (\'A\',\'T\') and cod_caja='+caja+'','');
	if(com ==""){
		x++;
		alert('No se Encontró Turno Abierto O en tramite');
	}  }
  	if(x>0) return false;
	else return true;
}
function CheckTurnoOld()
{
	var x=0;
	<%if(!fp.trim().equals("correccion")){%>
	var v_cajero = '<%=(String) session.getAttribute("_userName")%>';
	var compania = eval('document.form0.compania').value;
	var caja = eval('document.form0.caja').value;
	var com = getDBData('<%=request.getContextPath()%>','cod_turno,USUARIO_CREACION','tbl_cja_turnos_x_cajas','compania='+compania+' and  estatus in (\'A\',\'T\') and cod_caja='+caja+'','');
	if(com ==""){
		x++;
		alert('No se Encontró Turno Abierto');
	} else {
		var fin = com.indexOf("|");
		var turno = com.substr(0,fin);
		var cajero = com.substr(fin+1,com.length);
		if(cajero != v_cajero){
			x++;
			alert('EL USUARIO AUTORIZADO PARA REGISTRAR DEPOSITOS EN ESTE TURNO NO. '+turno+' ES '+cajero);
		} else eval('document.form0.turno').value = turno;
	}
	<%}%>
	if(x>0) return false;
	else return true;
//{if(com =="")alert('No se Encontró Turno Abierto');
//if(cajero != v_cajero)alert('EL USUARIO AUTORIZADO PARA REGISTRAR DEPOSITOS EN ESTE TURNO NO. '+turno+' ES '+cajero);
}

function VerificaTarjeta(){
	if(eval('document.form0.tipo_dep').value=="2"){
		var x=0;
		if(eval('document.form0.banco').value=="4" && eval('document.form0.tipo_dep').value=="2"&& eval('document.form0.tipo_tarjeta').value!="10"){
				x++;
		}
		if(x>0){alert('Permitido solo Tipo de Tarjeta Codigo 10');return false;}
		else return true;
	}//return
}

function Tarjeta(obj){
	var t_tipo = '<%=cdo.getColValue("tipo_tarjeta")%>';
	<%if (mode.equalsIgnoreCase("edit") && cdo.getColValue("tipo_dep").trim().equals("2")){%>
	if(t_tipo!= obj.value)
	if(confirm('Si cambia de tipo de tarjeta, el deposito se recalculará en base a la venta bruta ya asignada ')) Comision();
	<%}else{%>
	Comision();
	<%}%>
}

function showBanco(){
	var compania = eval('document.form0.compania').value;
	if(compania!=""){
		eval('document.form0.tipo_deposito').value='1';
		setTipo(eval('document.form0.tipo_deposito'));
		abrir_ventana1('../bancos/saldobank_cta_list.jsp?id=4&fp=deposito&compania='+compania);
	} else alert('Seleccione Compañia');
}
function showCompania(){abrir_ventana1('../caja/compania_caja_list.jsp?fp=deposito');}

function setTipo(obj){
	if(obj.value=="1" || obj.value=="5"){
		document.getElementById('DCE').style.visibility = "visible";
		document.getElementById('DCE').style.height = "auto";
		document.getElementById('DCE').style.display = "";
	} else {
		document.getElementById('DCE').style.visibility = "hidden";
		document.getElementById('DCE').style.height = "1";
		document.getElementById('DCE').style.display = "none";
	}
	if(obj.value=="2"){
	var cuenta = eval('document.form0.cuenta').value;
	var banco = eval('document.form0.banco').value;
	var compania = eval('document.form0.compania').value;

	var dep_tarjeta = getDBData('<%=request.getContextPath()%>','nvl(dep_tarjeta,\'N\')',' tbl_con_cuenta_bancaria','compania='+compania+' and cod_banco=\''+banco+'\' and cuenta_banco =\''+cuenta+'\' ','');
	if(dep_tarjeta=='S'){

		document.getElementById('DT').style.visibility = "visible";
		document.getElementById('DT').style.height = "auto";
		document.getElementById('DT').style.display = "";
		}else{ CBMSG.alert('La cuenta no permite registros para tarjetas. Consulte con su administrador..!!');obj.value="1";}
	} else {
		document.getElementById('DT').style.visibility = "hidden";
		document.getElementById('DT').style.height = "1";
		document.getElementById('DT').style.display = "none";
	}
	if(obj.value=="3"){
		document.getElementById('DA').style.visibility = "visible";
		document.getElementById('DA').style.height = "auto";
		document.getElementById('DA').style.display = "";
	} else {
		document.getElementById('DA').style.visibility = "hidden";
		document.getElementById('DA').style.height = "1";
		document.getElementById('DA').style.display = "none";
	}
	if(obj.value=="4"){
		document.getElementById('DTT').style.visibility = "visible";
		document.getElementById('DTT').style.height = "auto";
		document.getElementById('DTT').style.display = "";
	} else {
		document.getElementById('DTT').style.visibility = "hidden";
		document.getElementById('DTT').style.height = "1";
		document.getElementById('DTT').style.display = "none";
	}
}

function CheckMonto(){
	var x=0;
	var tipo_dep = eval('document.form0.tipo_deposito').value;
	if((tipo_dep =="1" || tipo_dep =="5"|| tipo_dep =="6") && eval('document.form0.e_monto').value=="" || eval('document.form0.e_monto').value=="0")
	{x++;}
	else if(tipo_dep == "2" && eval('document.form0.tar_monto').value == "" || eval('document.form0.tar_monto').value == "0") x++;
	else if(tipo_dep == "3" && eval('document.form0.a_monto').value == "" || eval('document.form0.a_monto').value == "0") x++;
	else if(tipo_dep == "4" && eval('document.form0.t_monto').value == "" || eval('document.form0.t_monto').value == "0") x++;

	if(x>0 && '<%=fp%>' != 'correccion'){
		alert('Introduzca Monto Para Depositar');
		return false;
	}	else return true;
}
function showTurno()
{var caja = eval('document.form0.caja').value;var v_cajero = '<%=(String) session.getAttribute("_userName")%>';
abrir_ventana2('../caja/turnos_list.jsp?fp=deposito&caja='+caja+'&usuario='+v_cajero);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE DEPÓSITOS DIARIOS"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
						<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>

			<%=fb.hidden("venta_bruta",cdo.getColValue("monto"))%>
			<%=fb.hidden("consecutivo",cdo.getColValue("consecutivo_ag"))%>
			<%=fb.hidden("valida_edicion",cdo.getColValue("valida_edicion"))%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("compania",(String) session.getAttribute("_companyId"))%>

				<tr class="TextHeader">
							<td colspan="3"><cellbytelabel>Depósitos de</cellbytelabel>:</td>
				</tr>
				<tr class="TextRow01">
					<td width="25%"><cellbytelabel>Caja</cellbytelabel></td>
					<td width="50%">
					<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_cja_cajas where estado != 'I' and compania = "+(String) session.getAttribute("_companyId")+" /*and ip = '"+ip+"'*/ order by descripcion asc","caja",cdo.getColValue("caja"),false,(!mode.trim().equals("add")||viewMode),0,null,null,"")%></td>
					<%//=fb.textBox("caja",cdo.getColValue("caja"),true,false,true,10)%>
					<%//=fb.textBox("name_caja",cdo.getColValue("nombrecaja"),false,false,true,30)%>
					</td>
					<td width="25%"><%=fb.textBox("turno",cdo.getColValue("turno"),true,false,true,3)%>
					<%=fb.textBox("name_cajera",cdo.getColValue("cajero"),false,false,true,20)%>
					<%=fb.button("addTurno","...",true,false,null,null,"onClick=\"javascript:showTurno()\"","Agregar Turno")%></td>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Banco</cellbytelabel></td>
					<td colspan="2">
					<%=fb.textBox("banco",cdo.getColValue("banco"),true,false,true,10)%>
					<%=fb.textBox("name_banco",cdo.getColValue("nombrebanco"),false,false,true,30)%>
					<%=fb.button("addBanco","...",true,(!mode.equalsIgnoreCase("add")),null,null,"onClick=\"javascript:showBanco()\"","Agregar Banco")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Cuenta Bancaria</cellbytelabel></td>
					<td colspan="2">
					<%=fb.textBox("cuenta",cdo.getColValue("cuenta"),true,false,true,30)%>
					<%=fb.textBox("name_cuenta",cdo.getColValue("nombrecuenta"),false,false,true,30)%>
					<%//=fb.button("addCuenta","...",true,false,null,null,"onClick=\"javascript:showCuenta()\"","Agregar Cuenta")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Tipo de Depósito</cellbytelabel></td>
					<td colspan="2">
					<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_con_tipo_deposito "+(!mode.trim().equals("view")?" where estado='A'":"")+" order by descripcion asc","tipo_deposito",cdo.getColValue("tipo_dep"),false,viewMode,0,null,null,"onChange=\"javascript:setTipo(this)\"")%></td>
				</tr>

			<tr class="TextRow01">
					<td colspan="3">
			<div id = "Tarjeta" style="visibility:visible;display:"";">
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextRow01">
					<td colspan="4">
					<%if(cdo.getColValue("tipo_dep").trim().equals("1") || cdo.getColValue("tipo_dep").trim().equals("5")  || mode.equalsIgnoreCase("add")){%>
				<div id = "DCE" style="visibility:visible;display:'';">
				<%}else {%>
				<div id = "DCE" style="visibility:hidden;display:none;">
				<%}%>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="4">Depositos de Efectivo y cheques</td>
				</tr>
				<tr class="TextRow01">
					<!--<td>Introduzca el Total a depositar entre efectivo y cheques x slip de deposito</td>--->
					<td width="25%" align="right">Total a depositar:</td>
					<td width="25%"><%=fb.decPlusZeroBox("e_monto",(cdo.getColValue("tipo_dep")!=null && (cdo.getColValue("tipo_dep").trim().equals("1") || cdo.getColValue("tipo_dep").trim().equals("5") ))?cdo.getColValue("monto"):"",false,false,false,20,12.2)%></td>
					<td colspan="2"><%=fb.checkbox("sobrante","S",(cdo.getColValue("sobrante").trim().equals("S")),false,null,null,"")%>Sobrante?</td>
				</tr>
				</table>
				</div>
				</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="4">
					<%if(cdo.getColValue("tipo_dep").trim().equals("3")){%>
				<div id = "DA" style="visibility:visible;display:' ';">
				<%}else {%>
				<div id = "DA" style="visibility:hidden;display:none;">
				<%}%>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="3">Depósitos de Adelantos</td>
				</tr>
				<tr class="TextRow01">
					<td width="25%" align="right">
					<!--Introduzca el Monto a depositar en Concepto de adelanto<br>---->
					Total a Depositar:</td><td colspan="3"><%=fb.decPlusZeroBox("a_monto",(cdo.getColValue("tipo_dep")!=null && cdo.getColValue("tipo_dep").trim().equals("3"))?cdo.getColValue("monto"):"",false,false,false,20,12.2)%></td>
				</tr>
				</table>
				</div>
				</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="3">
				<%if(cdo.getColValue("tipo_dep").trim().equals("4")){%>
				<div id = "DTT" style="visibility:visible;display:' ';">
				<%}else {%>
				<div id = "DTT" style="visibility:hidden;display:none;">
				<%}%>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="4">Depósitos de Transferencias</td>
				</tr>
				<tr class="TextRow01">
					<td><!--Introduzca el Monto a depositar en Concepto de Transferencias<br>---->
					Comprobante #:</td>
					<td><%=fb.textBox("comprobante1",(cdo.getColValue("tipo_dep")!=null && cdo.getColValue("tipo_dep").trim().equals("4"))?cdo.getColValue("num_documento"):"",false,false,false,20)%></td>
					<td>Total a Depositar:</td><td><%=fb.decPlusZeroBox("t_monto",(cdo.getColValue("tipo_dep")!=null && cdo.getColValue("tipo_dep").trim().equals("4"))?cdo.getColValue("monto"):"",false,false,false,20,12.2)%></td>
				</tr>
				</table>
				</div>
				</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="4">
				<%if(cdo.getColValue("tipo_dep").trim().equals("2")){%>
				<div id = "DT" style="visibility:visible;display:' ';">
				<%}else {%>
				<div id = "DT" style="visibility:hidden;display:none;">
				<%}%>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="4">Depositos de Tarjetas</td>
				</tr>
				<tr class="TextRow01">
					<td>Tipos de Tarjetas</td>
					<td>Venta Bruta x Tipo de Tarjeta</td>
					<td colspan="2">Total Devoluciones</td>
				</tr>
				<tr class="TextRow01">
					<td>Tarjeta
					<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,DESCRIPCION||' - '||codigo FROM   TBL_CJA_TIPO_TARJETA ORDER BY 1","tipo_tarjeta",cdo.getColValue("tipo_tarjeta"),false,false,0,"",null,"onChange=\"javascript:Tarjeta(this)\"")%></td>
					<td><%=fb.decPlusZeroBox("tar_monto",(cdo.getColValue("tipo_dep")!=null && cdo.getColValue("tipo_dep").trim().equals("2"))?cdo.getColValue("monto"):"",false,false,false,15,12.2,null,null,"onBlur=\"javascript:Comision()\"")%></td>
					<td colspan="2"><%=fb.decPlusZeroBox("monto_devolucion",cdo.getColValue("devolucion"),false,false,false,15,12.2)%></td>
				</tr>
				<tr class="TextRow01">
					<td>Total Comision x tipo de Tarjetas</td>
					<td>Total de ITBMS Comision x tipo de Tarjetas</td>
					<td>Total a Depositar x Tipo de Tarjeta</td>
					<td>Comprobante # de terminal</td>
					<td>Sobrante?</td>
				</tr>
				<tr class="TextRow01">
					<td><%=fb.decPlusZeroBox("comision",cdo.getColValue("comision"),false,false,true,15,12.2)%></td>
					<td><%=fb.decBox("itbms",cdo.getColValue("itbms"),false,false,true,15,12.2)%>
					</td>
					<td><%=fb.decPlusZeroBox("mto_tot_tarjeta",cdo.getColValue("mto_tot_tarjeta"),false,false,true,15,12.2)%></td>
					<td><%=fb.textBox("comprobante",(cdo.getColValue("tipo_dep")!=null && cdo.getColValue("tipo_dep").trim().equals("2"))?cdo.getColValue("num_documento"):"",false,false,false,15)%></td>
					<td><%=fb.checkbox("sobrante1","S",(cdo.getColValue("sobrante").trim().equals("S")),false,null,null,"")%></td>
				</tr>
				</table>
				</div>
				</td>
				</tr>
				</table>
				</div>
				</td>
				</tr>
				<tr class="TextRow01">
						<td>Observaciones</td>
						<td>Creado Por</td>
						<td>Fecha</td>
				</tr>
				<tr class="TextRow01">
						<td><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,60,3,200,"","width:100%","")%></td>
						<td><%=fb.textBox("usuario",cdo.getColValue("usuario"),false,false,true,15)%></td>
						<td><%=fb.textBox("fecha",cdo.getColValue("fecha"),false,false,true,15)%> &nbsp; <%=fb.button("addComprobante","Comprobante",false,false,null,null,"onClick=\"javascript:showComprobante()\"","Comprobante de registro de Depósito")%></td>
				 </tr>
	<%//fb.appendJsValidation("\n\tif (!VerificaTarjeta()) error++;\n");%>
	<%fb.appendJsValidation("\n\tif (!CheckTurno()) error++;\n");%>
	<%fb.appendJsValidation("\n\tif (!CheckFecha()) error++;\n");%>

	<%fb.appendJsValidation("\n\tif (!CheckMonto()) error++;\n");%>

	<tr class="TextRow02">
					<td colspan="3" align="right">
						Opciones de Guardar:
						<!--< ---><%=fb.radio("saveOption","N")%>Crear Otro
						<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C")%>Cerrar
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{

	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String monto="0";
	banco = request.getParameter("banco");
	cuenta = request.getParameter("cuenta");
	caja = request.getParameter("caja");
	compania = request.getParameter("compania");
	fp = request.getParameter("fp");

					cdo = new CommonDataObject();
					cdo.setTableName("TBL_CON_MOVIM_BANCARIO");

					if(request.getParameter("observacion") !=null && !request.getParameter("observacion").trim().equals(""))
					cdo.addColValue("OBSERVACION",request.getParameter("observacion"));
					else
					{
							if(request.getParameter("tipo_deposito") !=null && request.getParameter("tipo_deposito").trim().equals("1"))//efectivo
								cdo.addColValue("observacion","DEPOSITO DE EFECTIVO");
							if(request.getParameter("tipo_deposito") !=null && request.getParameter("tipo_deposito").trim().equals("6"))//cheque
								cdo.addColValue("observacion","DEPOSITO DE CHEQUES");
							if(request.getParameter("tipo_deposito") !=null && request.getParameter("tipo_deposito").trim().equals("2"))//tarjeta
								cdo.addColValue("observacion","DEPOSITO DE TARJETAS");
							if(request.getParameter("tipo_deposito") !=null && request.getParameter("tipo_deposito").trim().equals("3"))//adelanto
								cdo.addColValue("observacion","DEPOSITO DE ADELANTOS");
							if(request.getParameter("tipo_deposito") !=null && request.getParameter("tipo_deposito").trim().equals("4"))//transfe
								cdo.addColValue("observacion","DEPOSITO DE TRANSFERENCIAS");
							if(request.getParameter("tipo_deposito") !=null && request.getParameter("tipo_deposito").trim().equals("5"))//re_depos
								cdo.addColValue("observacion","DEPOSITO CAJAS-CAMBIOS / REDEPOSITOS");
					}
					if(request.getParameter("tipo_deposito") !=null && request.getParameter("tipo_deposito").trim().equals("2"))
					{
						cdo.addColValue("TIPO_TARJETA",request.getParameter("tipo_tarjeta"));
						cdo.addColValue("COMISION",request.getParameter("comision"));
						cdo.addColValue("itbms",request.getParameter("itbms"));
						cdo.addColValue("devoluc_tarj",request.getParameter("monto_devolucion"));
						//cdo.addColValue("nuevo_proc","S");
						cdo.addColValue("MTO_TOT_TARJETA",request.getParameter("mto_tot_tarjeta"));
						monto = request.getParameter("tar_monto");
						if(request.getParameter("comprobante")!=null && !request.getParameter("comprobante").trim().equals(""))
						cdo.addColValue("NUM_DOCUMENTO",request.getParameter("comprobante"));
					else
						cdo.addColValue("NUM_DOCUMENTO","2");

						if (request.getParameter("sobrante1") != null && request.getParameter("sobrante1").equalsIgnoreCase("S"))
						{
							cdo.addColValue("sobrante","S");
						}
						else cdo.addColValue("sobrante","N");
					}
					else
					{
						cdo.addColValue("TIPO_TARJETA","");
						cdo.addColValue("COMISION","");
						cdo.addColValue("itbms","");
						cdo.addColValue("devoluc_tarj","");
						cdo.addColValue("MTO_TOT_TARJETA","");
					}
					cdo.addColValue("tipo_dep",request.getParameter("tipo_deposito"));
					if(request.getParameter("tipo_deposito") !=null &&( request.getParameter("tipo_deposito").trim().equals("1")||request.getParameter("tipo_deposito").trim().equals("6") || request.getParameter("tipo_deposito").trim().equals("5")))
					{
							monto = request.getParameter("e_monto");
							if (request.getParameter("sobrante") != null && request.getParameter("sobrante").equalsIgnoreCase("S"))
							{
								cdo.addColValue("sobrante","S");
							}
							else cdo.addColValue("sobrante","N");
					}
					if(request.getParameter("tipo_deposito") !=null && request.getParameter("tipo_deposito").trim().equals("3"))
						monto = request.getParameter("a_monto");
					if(request.getParameter("tipo_deposito") !=null && request.getParameter("tipo_deposito").trim().equals("4"))
					monto = request.getParameter("t_monto");
					cdo.addColValue("turno",request.getParameter("turno"));
					cdo.addColValue("MONTO",monto);
					cdo.addColValue("USUARIO_MODIFICACION",(String) session.getAttribute("_userName"));
					cdo.addColValue("FECHA_MODIFICACION",cDateTime);
					if(request.getParameter("tipo_deposito") !=null && request.getParameter("tipo_deposito").trim().equals("4"))
					{
					if(request.getParameter("comprobante1")!=null && !request.getParameter("comprobante1").trim().equals(""))
						cdo.addColValue("NUM_DOCUMENTO",request.getParameter("comprobante1"));
					else
						cdo.addColValue("NUM_DOCUMENTO","2");
					}
					cdo.addColValue("DESCRIPCION","DEPOSITO POR CIERRE DE CAJAS");

					if (mode.equalsIgnoreCase("add"))
					{
						cdo.setWhereClause("compania="+request.getParameter("compania")+" and cuenta_banco='"+request.getParameter("cuenta")+"' and banco='"+request.getParameter("banco")+"' and tipo_movimiento='1'");cdo.addColValue("F_MOVIMIENTO",request.getParameter("fecha"));
							cdo.addColValue("CUENTA_BANCO",request.getParameter("cuenta"));
							cdo.addColValue("BANCO",request.getParameter("banco"));
							cdo.addColValue("COMPANIA",request.getParameter("compania"));
							cdo.addColValue("ESTADO_TRANS","T");
							cdo.addColValue("TIPO_MOVIMIENTO","1");//deposito
							cdo.addColValue("LADO","DB");//lado debito
							cdo.addColValue("ESTADO_DEP","DT");
							cdo.addColValue("CAJA",request.getParameter("caja"));

							cdo.addColValue("USUARIO_CREACION",(String) session.getAttribute("_userName"));
							cdo.addColValue("FECHA_CREACION",cDateTime);

							cdo.setAutoIncWhereClause("compania="+request.getParameter("compania")+" and cuenta_banco='"+request.getParameter("cuenta")+"' and banco='"+request.getParameter("banco")+"' and tipo_movimiento='1'");
							cdo.setAutoIncCol("consecutivo_ag");
							cdo.addPkColValue("consecutivo_ag","");

							ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
							SQLMgr.insert(cdo);
							consecutivo = SQLMgr.getPkColValue("consecutivo_ag");
							ConMgr.clearAppCtx(null);
					}
					else if (mode.equalsIgnoreCase("edit"))
					{
						 cdo.addColValue("DEP_MODIF","S");
						 consecutivo = request.getParameter("consecutivo");
						 cdo.setWhereClause("compania="+request.getParameter("compania")+" and cuenta_banco='"+request.getParameter("cuenta")+"' and banco='"+request.getParameter("banco")+"' and tipo_movimiento='1' and consecutivo_ag="+consecutivo);
						 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
						 SQLMgr.update(cdo);
						 ConMgr.clearAppCtx(null);
					}

					if (SQLMgr.getErrCode().equals("1")) {

					CommonDataObject param = new CommonDataObject();
					param.setSql("call sp_ban_crea_trx_com_itbms (?,?,?,?,?,?)");
					param.addInStringStmtParam(1,request.getParameter("compania"));
					param.addInStringStmtParam(2,request.getParameter("cuenta"));
					param.addInStringStmtParam(3,request.getParameter("banco"));
					param.addInStringStmtParam(4,(String) session.getAttribute("_userName"));
					param.addInStringStmtParam(5,consecutivo);
					param.addInStringStmtParam(6,(mode.equalsIgnoreCase("add")?"INS":"UPD"));
					param = SQLMgr.executeCallable(param,false,true);

				}


	%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/transacciones_depositos_list.jsp?fp="+fp))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/transacciones_depositos_list.jsp?fp="+fp)%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/caja/transacciones_depositos_list.jsp?fp=<%=fp%>';
<%
		}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&fp=<%=fp%>&compania=<%=compania%>&caja=<%=caja%>&banco=<%=banco%>&cuenta=<%=cuenta%>&consecutivo=<%=consecutivo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
