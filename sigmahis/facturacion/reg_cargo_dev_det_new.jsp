<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactTransaccion"%>
<%@ page import="issi.facturacion.FactDetTransaccion"%>
<%@ page import="issi.facturacion.FactDetTransComp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="FTransMgr" scope="page" class="issi.facturacion.FactTransaccionMgr" />
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="FTransDet" scope="session" class="issi.facturacion.FactTransaccion" />
<jsp:useBean id="fTranComp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCompKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranDComp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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
FTransMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdoHon = new CommonDataObject();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String tipoTransaccion = (request.getParameter("tipoTransaccion")==null?"C":request.getParameter("tipoTransaccion"));
String noOrden = (request.getParameter("no_orden")==null?"":request.getParameter("no_orden"));
String codigoOrden = (request.getParameter("codigo_orden")==null?"":request.getParameter("codigo_orden"));
String idIntFar = (request.getParameter("id_int_far")==null?"":request.getParameter("id_int_far"));
String fPage = (request.getParameter("fPage")==null?"":request.getParameter("fPage"));
String bar__code = (request.getParameter("bar__code")==null?"":request.getParameter("bar__code"));
String id = request.getParameter("id");
String codTSHon = "";
boolean viewMode = false;
String codigo = request.getParameter("codigo");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
//if (tipoTransaccion == null) tipoTransaccion = "C";
if (mode == null) mode = "add";
if(mode.equals("view")) viewMode = true;
String imprimirCargo = java.util.ResourceBundle.getBundle("issi").getString("imprimirCargo");
if(imprimirCargo==null || imprimirCargo.equals("")) imprimirCargo = "N";
String  autoBoleta= "N";
try {autoBoleta =java.util.ResourceBundle.getBundle("issi").getString("autoBoleta");}catch(Exception e){ autoBoleta = "N";}

 if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'COD_TIPO_SERV_HON') as param_value,nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'CHECK_DISP'),'S')as valida_dsp from dual";
	cdoHon = SQLMgr.getData(sql);
	if(cdoHon!=null && !cdoHon.getColValue("param_value").equals("")) codTSHon = cdoHon.getColValue("param_value");
	if(cdoHon ==null){cdoHon =new CommonDataObject();cdoHon.addColValue("valida_dsp","S");}
	if(mode.equalsIgnoreCase("add") && change == null) fTranCarg.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
document.form1.tipoTransaccion.value =parent.document.form0.tipoTransaccion.value;
	var tipoTrans	= parent.document.form0.tipoTransaccion.value;
	<%
	if(type!=null && type.equals("1")){
	%>
	var fg = document.form1.fg.value;
	var cs = parent.document.form0.centroServicio.value;
	var tipo_cds = parent.document.form0.tipoCds.value;
	var reporta_a = parent.document.form0.reportaA.value;
	var inc = parent.document.form0.incremento.value;
	var tipoInc = parent.document.form0.tipoInc.value;
	
	var almacen=parent.document.form0.almacen.value;
	var empresa = parent.document.paciente.empresa.value
	var clasif = parent.document.paciente.clasificacion.value
	var edad = parent.document.paciente.edad.value;
	var cat = parent.document.paciente.categoria.value;

	var fechaNac = parent.document.paciente.fechaNacimiento.value;
	var admSec = parent.document.paciente.admSecuencia.value;
	var codPac = parent.document.paciente.codigoPaciente.value;
	var pacId = parent.document.paciente.pacienteId.value;
	var codProv = ""
	var codHonorario = '';
		if(parent.document.form0.pagar_sociedad){if(parent.document.form0.pagar_sociedad.checked==true){codHonorario = parent.document.form0.empreCodigo.value;}else codHonorario = parent.document.form0.medico.value;}		
		
	<%if(fg.equals("PAC")){%>
				codProv = parent.document.form0.seCodProveedor.value;
	<%}%>
	if(tipoTrans != '' && tipoTrans=='D' && pacId =='' )top.CBMSG.warning('Seleccione paciente..');else{
	abrir_ventana1('../common/sel_servicios_x_centro_new.jsp?mode=<%=mode%>&fg='+fg+'&fp=cargo_dev_pac&cs='+cs+'&tipo_cds='+tipo_cds+'&reporta_a='+reporta_a+'&v_empresa='+empresa+'&edad='+edad+'&clasificacion='+clasif+'&incremento='+inc+'&tipoInc='+tipoInc+'&tipoTransaccion='+tipoTrans+'&cat='+cat+'&admiSecuencia='+admSec+'&fechaNac='+fechaNac+'&codPaciente='+codPac+'&codProv='+codProv+'&pacId='+pacId+'&almacen='+almacen+'&codHonorario='+codHonorario);}
	<%
	}
	if(type!=null && type.equals("2")){
	%>
	parent.reloadCargosAfterDeleting();
	<%}%>
	calc();
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	
	restoreCant();
}

function getComp(key){
	var fg = document.form1.fg.value;
	var cs = parent.document.form0.centroServicio.value;
	var empresa = parent.document.paciente.empresa.value
	var edad = parent.document.paciente.edad.value;
	abrir_ventana1('../common/sel_componentes.jsp?mode=<%=mode%>&fg='+fg+'&fp=cargo_dev_pac&keyNPT='+key+'&v_empresa='+empresa+'&edad='+edad);
}

function calc(){
	var iCounter = 0;
	var availableQty = 0;
	var qty = 0;
	var action = document.form1.baction.value;
	var total = 0.00, monto = 0.00, totali;
<%
	if (fTranCarg.size() > 0) al = CmnMgr.reverseRecords(fTranCarg);
	for (int i=0; i<fTranCarg.size(); i++){
%>

	if (isNaN(document.form1.cantidad<%=i%>.value) || ((document.form1.cantidad<%=i%>.value != '') && ((parseFloat(document.form1.cantidad<%=i%>.value) % 1) != 0))){
		top.CBMSG.warning('Por favor ingresar Cantidad válida!');
		document.form1.cantidad<%=i%>.select();
		return false;
	} else if (document.form1.cantidad<%=i%>.value != '' && parseInt(document.form1.cantidad<%=i%>.value,10) != 0){
		iCounter++;
		qty = parseInt(document.form1.cantidad<%=i%>.value,10);
		if(!isNaN(document.form1.monto<%=i%>.value) && document.form1.monto<%=i%>.value !=''){
		monto = parseFloat(document.form1.monto<%=i%>.value);}
		else monto =0.00;
		totali = qty * monto;
		total += totali;
		document.form1.total<%=i%>.value=totali.toFixed(2);
	} else if (parseInt(document.form1.cantidad<%=i%>.value,10) == 0 && action=='Guardar'){
		iCounter++;
		top.CBMSG.warning('Cantidad no puede ser igual a 0!');
		document.form1.cantidad<%=i%>.select();
		return false;
	}
<%
	}
%>
	document.form1.total.value = total.toFixed(2);
	if(action=="Guardar"){
		if (iCounter > 0) return true;
		else return false;
	} else return true;
}

function _doSubmit(valor){
	parent.document.form0.baction.value = valor;
	parent.document.form0.clearHT.value = 'N';
	doSubmit();
}

function doSubmit(){
	document.form1.baction.value 						= parent.document.form0.baction.value;
	document.form1.saveOption.value 				= parent.document.form0.saveOption.value;
	//document.form1.fg.value 								= parent.document.form0.fg.value;
	document.form1.clearHT.value 						= parent.document.form0.clearHT.value;

	var pacId = parent.document.paciente.pacienteId.value;
	var noAdmision = parent.document.paciente.admSecuencia.value;
	
	
	var estado ='';
	if(document.form1.baction.value =='Guardar'){if(pacId!='')estado = getDBData('<%=request.getContextPath()%>','estado','tbl_adm_admision','pac_id='+pacId+' and secuencia='+noAdmision+' ','');else top.CBMSG.warning('Seleccione paciente/admision!');}
	
	var descEstado='';
	if(estado =='I')descEstado=' INACTIVA ';
	else if(estado =='N')descEstado=' ANULADA ';
	if((estado !='I' && estado !='N')){
	
	document.form1.centroServicio.value			= parent.document.form0.centroServicio.value;
	document.form1.centroServicioDesc.value	= parent.document.form0.centroServicioDesc.value;
	document.form1.codigo.value							= parent.document.form0.codigo.value;
	document.form1.fechaCreacion.value			= parent.document.form0.fechaCreacion.value;
	document.form1.fechaModificacion.value	= parent.document.form0.fechaModificacion.value;
<%if(fg.equals("PAC")){%>
	if(parent.document.form0.generaArchivo.checked==true)	document.form1.generaArchivo.value			= 'S';
	else document.form1.generaArchivo.value			= 'N';
	document.form1.medico.value							= parent.document.form0.medico.value;
	document.form1.nombreMedico.value				= parent.document.form0.nombreMedico.value;
	if(parent.document.form0.seCodProveedor){
		document.form1.seCodProveedor.value			= parent.document.form0.seCodProveedor.value;
		document.form1.seDescProveedor.value		= parent.document.form0.seDescProveedor.value;
		document.form1.seNumeroDocumento.value	= parent.document.form0.seNumeroDocumento.value;
		document.form1.seFechaDocumento.value		= parent.document.form0.seFechaDocumento.value;
	}
<%} else if(fg.equals("HON")){%>
	document.form1.medico.value							= parent.document.form0.medico.value;
	document.form1.nombreMedico.value				= parent.document.form0.nombreMedico.value;
	document.form1.empreCodigo.value				= parent.document.form0.empreCodigo.value;
	document.form1.empreDesc.value					= parent.document.form0.empreDesc.value;
	if(parent.document.form0.pagar_sociedad.checked)
	 document.form1.pagar_sociedad.value = "S";
	 else document.form1.pagar_sociedad.value = "N";
	 if(parent.document.form0.diferencia_honorario.checked)
	 document.form1.diferencia_honorario.value = "S";
	 else document.form1.diferencia_honorario.value = "N";

	//document.form1.pagar_sociedad.value			= parent.document.form0.pagar_sociedad.value;
	document.form1.descripcion.value				= parent.document.form0.descripcion.value;
<%}%>
	document.form1.incremento.value 				= parent.document.form0.incremento.value;
	document.form1.noDocumento.value				= parent.document.form0.noDocumento.value;
	document.form1.numSolicitud.value				= parent.document.form0.numSolicitud.value;
	document.form1.reportaA.value 					= parent.document.form0.reportaA.value;
	document.form1.tipoCds.value 						= parent.document.form0.tipoCds.value;
	document.form1.tipoInc.value 						= parent.document.form0.tipoInc.value;
	document.form1.tipoTransaccion.value		= parent.document.form0.tipoTransaccion.value;

	document.form1.nombrePaciente.value			= parent.document.paciente.nombrePaciente.value;
	document.form1.fechaNacimiento.value		= parent.document.paciente.fechaNacimiento.value;
	document.form1.codigoPaciente.value 		= parent.document.paciente.codigoPaciente.value;
	document.form1.pacienteId.value 				= parent.document.paciente.pacienteId.value;
	document.form1.provincia.value 					= parent.document.paciente.provincia.value;
	document.form1.sigla.value 							= parent.document.paciente.sigla.value;
	document.form1.tomo.value 							= parent.document.paciente.tomo.value;
	document.form1.asiento.value 						= parent.document.paciente.asiento.value;
	document.form1.dCedula.value 						= parent.document.paciente.dCedula.value;
	document.form1.pasaporte.value 					= parent.document.paciente.pasaporte.value;
	document.form1.jubilado.value						= parent.document.paciente.jubilado.value;
	document.form1.numFactura.value					= parent.document.paciente.numFactura.value;
	document.form1.categoria.value					= parent.document.paciente.categoria.value;
	document.form1.categoriaDesc.value			= parent.document.paciente.categoriaDesc.value;
	document.form1.fechaIngreso.value				= parent.document.paciente.fechaIngreso.value;
	document.form1.mesCta.value							= parent.document.paciente.mesCta.value;
	document.form1.admSecuencia.value 			= parent.document.paciente.admSecuencia.value;
	document.form1.estado.value 						= parent.document.paciente.estado.value;
	document.form1.desc_estado.value 				= parent.document.paciente.desc_estado.value;
	document.form1.empresa.value 						= parent.document.paciente.empresa.value;
	document.form1.clasificacion.value			= parent.document.paciente.clasificacion.value;
	document.form1.embarazada.value					= parent.document.paciente.embarazada.value;

	if (!parent.pacienteValidation() || !parent.form0Validation()||(!form1Validation()&&document.form1.baction.value =='Guardar')){
			parent.form0BlockButtons(false);
<%if(fg.equals("HON")){%>
	} else if(parent.document.form0.pagar_sociedad.checked==true && parent.document.form0.empreCodigo.value==''){
		top.CBMSG.warning('Debe seleccionar la Sociedad del Honorario!');
		parent.form0BlockButtons(false);
	} else if(parent.document.form0.pagar_sociedad.checked==false && parent.document.form0.medico.value==''){
		top.CBMSG.warning('Debe seleccionar el Médico del Honorario');
		parent.form0BlockButtons(false);
<%}%>
	} else{
		//return true;
		if (document.form1.baction.value != 'Guardar')parent.form0BlockButtons(false);

		if (document.form1.baction.value == 'Guardar' && <%=fTranCarg.size()%> == 0)
		{
			top.CBMSG.warning('Por favor agregue por lo menos un cargo antes de guardar! ');
			parent.form0BlockButtons(false);
		} else if(document.form1.baction.value == 'Guardar' && !validaFechas(-1)){
			top.CBMSG.warning('La fecha del cargo está fuera del rango de la fecha de ingreso o egreso... VERIFIQUE');
			parent.form0BlockButtons(false);
		}
		else if (!document.form1.centroServicio.value){
		   top.CBMSG.warning("Es imperativo indicar el Centro de Servicio!");
		   parent.form0BlockButtons(false);
		}
		else if(calc())
		{
			document.form1.submit();
		} else parent.form0BlockButtons(false);

	}
	}else {top.CBMSG.warning('La Admision se encuentra en estado:'+descEstado+' No puede Registrar Cargos !!!');return false;}

}


function calMonto(j, k){
	var cantidad = parseInt(eval('document.form1.cantidad'+j).value,10);
	var cant_cargo = 0;
	var cant_devolucion = 0;
	var monto = eval('document.form1.monto'+j).value;
	var tipoTransaccion = parent.document.form0.tipoTransaccion.value;
	var cs = parent.document.form0.centroServicio.value;
	var fg = '<%=fg%>';
	var inventario = ''
	if(eval('document.form1.inventario'+j))inventario =eval('document.form1.inventario'+j).value;
	var afecta_inv = eval('document.form1.afecta_inv'+j).value;
 		cant_cargo = parseInt(eval('document.form1.cant_cargo'+j).value,10);
		cant_devolucion = parseInt(eval('document.form1.cant_devolucion'+j).value,10);
	 
	if(isNaN(cantidad) || isNaN(monto)){
		top.CBMSG.warning('Introduzca valores numéricos!');
		if(x=='c')eval('document.form1.cantidad'+j).value = 0;
		else if(x=='p')eval('document.form1.monto'+j).value = 0;
		return false;
	} else {
		if(tipoTransaccion=='C' && inventario == 'S' && afecta_inv=='Y'){
			var almacen = parent.document.form0.almacen.value;
			var flia = eval('document.form1.art_familia'+j).value;
			var clase = eval('document.form1.art_clase'+j).value;
			var codigo = eval('document.form1.inv_articulo'+j).value;
			var cantidad = eval('document.form1.cantidad'+j).value;
			<%if(cdoHon.getColValue("valida_dsp").trim().equals("S")){%>
			var disp = getInvDisponible('<%=request.getContextPath()%>', <%=(String) session.getAttribute("_companyId")%>, almacen, flia, clase, codigo);
			if(disp<cantidad){top.CBMSG.warning('La cantidad supera la disponible!');eval('document.form1.cantidad'+j).value=0;return false;}<%}%>
		}
		if(tipoTransaccion=='D')
		{
		
		//estado = getDBData('<%=request.getContextPath()%>','estado','tbl_adm_admision','pac_id='+pacId+' and secuencia='+noAdmision+' ','');
		
		
			if(cantidad > (cant_cargo-cant_devolucion))
			{
				top.CBMSG.warning('La cantidad a devolver excede la cantidad del cargo...,VERIFIQUE!');
				eval('document.form1.cantidad'+j).value = 0;
				eval('document.form1.cantidad'+j).select();
				return false;
			} 
			else 
			{
				eval('document.form1.total'+j).value = (cantidad * monto).toFixed(2);
				calc();
				return true;
			}
		} else {
			eval('document.form1.total'+j).value = (cantidad * monto).toFixed(2);
			calc();
			return true;
		}
	}
}

function setValidDate(i){
	/*
	var fecha_ingreso	= parent.document.paciente.fechaIngreso.value;
	var fecha_egreso	= parent.document.paciente.fechaEgreso.value;
	var fecha_cargo		= eval('document.form1.fecha_cargo'+i).value;
	var fecha = '<%=cDateTime%>';
	if(fecha_egreso==''){
		if(_setValidDate(fecha_cargo)<_setValidDate(fecha_ingreso)){
			top.CBMSG.warning('La fecha del cargo esta fuera del rango de la fecha de ingreso o egreso...VERIFIQUE!');
			eval('document.form1.fecha_cargo'+i).value = fecha;
		}
	} else if(_setValidDate(fecha_cargo)<_setValidDate(fecha_ingreso) || _setValidDate(fecha_cargo)>_setValidDate(fecha_egreso)){
		top.CBMSG.warning('La fecha del cargo esta fuera del rango de la fecha de ingreso o egreso...VERIFIQUE!');
		eval('document.form1.fecha_cargo'+i).value = fecha;
	}
	*/
	validaFechas(i);
}

function _setValidDate(fecha){
	var d = parseInt(fecha.substr(0,2),10);
	var m = parseInt(fecha.substr(3,2),10);
	var y = parseInt(fecha.substr(6,4),10);
	var _fecha 	= d + m*30 + y;
	return _fecha;
}

function validaFechas(j){
	var size = <%=fTranCarg.size()%>;
	var k = j;
	if(j!=-1) size = j+1;
	else j = 0;

	var fechaI = parent.document.paciente.fechaIngreso.value.trim();
	var fechaE = parent.document.paciente.fechaEgreso.value.trim();
	var x = 0;
	var validDate = '';
	var fecha ='';
	
if (parent.document.form0.tipoTransaccion.value != 'D') {
	for(i=j;i<size;i++)
	{
		
	  if(fecha != eval('document.form1.fecha_cargo'+i).value)
	  {	
	    fecha = eval('document.form1.fecha_cargo'+i).value;
		if(fechaE.trim()!=''){
			validDate = getDBData('<%=request.getContextPath()%>','\'true\' x','dual','to_date(\''+fecha+'\',\'dd/mm/yyyy\') between to_date(\''+fechaI+'\',\'dd/mm/yyyy\') and to_date(\''+fechaE+'\',\'dd/mm/yyyy\')','');
		} else {
			validDate = getDBData('<%=request.getContextPath()%>','\'true\' x','dual','to_date(\''+fecha+'\',\'dd/mm/yyyy\') >= to_date(\''+fechaI+'\',\'dd/mm/yyyy\')','');
		}
		if(validDate==''){
			x = 1;
			if(k!=-1) top.CBMSG.warning('La fecha del cargo está fuera del rango de la fecha de egreso o egreso... VERIFIQUE!!!');
			break;
		}
	  }
	}
}
	if(x==0) return true;
	else return false;
}

/*
*@param: FIE Update fecha ingreso, fecha egreso 
*@param: FC Aplicar esta fecha a todas las fechas de cargo
*/
function updateFIEC(paramVal){
	if (paramVal == "FIE"){
		  var pacId  = parent.document.paciente.pacienteId.value;
		  var noAdmision = parent.document.paciente.admSecuencia.value;
		  var _where = " a.pac_id = "+pacId+" and a.secuencia = "+noAdmision;
		  var _fields = "to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fechaIngreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso";
		  var $data = splitCols(getDBData('<%=request.getContextPath()%>',_fields,'tbl_adm_admision a',_where,''));
		  
		  parent.document.paciente.fechaIngreso.value = $data[0];
		  parent.document.paciente.fechaEgreso.value = $data[1];
	}else if(paramVal == "FC"){
	     var size = document.form1.size.value;
		 if (document.getElementById("applyChargeDate").value.trim()){
			 for (var i = 0; i<size; i++){
			    document.getElementById("fecha_cargo"+i).value = document.getElementById("applyChargeDate").value;
			 }
		 }else{
		   top.CBMSG.warning("Por favor ingrese una fecha antes de proceder!");
		 }
	}
}

function printCargoDev(){
	var pacId = parent.document.paciente?parent.document.paciente.pacienteId.value:'';
	var noAdmision = parent.document.paciente?parent.document.paciente.admSecuencia.value:'';
	if(pacId!='' && noAdmision != '')	abrir_ventana1('../facturacion/print_cargo_dev.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);
	else top.CBMSG.warning('Seleccione Admisión!');
}

function restoreCant(){
  var _tmp = "<%=(String)session.getAttribute("_tmpCant")==null?"":(String)session.getAttribute("_tmpCant")%>";
  if (_tmp != ""){
    var _t = _tmp.split(",");
	
	for (i=0; i<_t.length; i++){
	  var _data = _t[i].split(":");
	  var curInd = $("#curInd"+i).val();
	  if (curInd==_data[0]) $("#cantidad"+curInd).val(_data[1]);
	}
	
	//top.CBMSG.warning(_t.length);
  }
}
function setRegalia(idx){eval('document.form1.monto'+idx).value='0.00';calMonto(idx,'p');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='x')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("size",""+fTranCarg.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("nombrePaciente","")%>
<%=fb.hidden("fechaNacimiento","")%>
<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("pacienteId","")%>
<%=fb.hidden("provincia","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("dCedula","")%>
<%=fb.hidden("pasaporte","")%>
<%=fb.hidden("jubilado","")%>
<%=fb.hidden("numFactura","")%>
<%=fb.hidden("categoria","")%>
<%=fb.hidden("categoriaDesc","")%>
<%=fb.hidden("fechaIngreso","")%>
<%=fb.hidden("mesCta","")%>
<%=fb.hidden("admSecuencia","")%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("desc_estado","")%>
<%=fb.hidden("empresa","")%>
<%=fb.hidden("clasificacion","")%>
<%=fb.hidden("embarazada","")%>


<%=fb.hidden("codigo","")%>
<%=fb.hidden("fechaCreacion","")%>
<%=fb.hidden("fechaModificacion","")%>
<%=fb.hidden("numSolicitud","")%>
<%=fb.hidden("noDocumento","")%>
<%=fb.hidden("medico","")%>
<%=fb.hidden("nombreMedico","")%>

<%=fb.hidden("centroServicio","")%>
<%=fb.hidden("centroServicioDesc","")%>
<%=fb.hidden("tipoCds","")%>
<%=fb.hidden("reportaA","")%>
<%=fb.hidden("incremento","")%>
<%=fb.hidden("tipoInc","")%>
<%=fb.hidden("tipoTransaccion","")%>
<%=fb.hidden("generaArchivo","")%>

<%=fb.hidden("seCodProveedor","")%>
<%=fb.hidden("seDescProveedor","")%>
<%=fb.hidden("seNumeroDocumento","")%>
<%=fb.hidden("seFechaDocumento","")%>

<%=fb.hidden("empreCodigo","")%>
<%=fb.hidden("empreDesc","")%>
<%=fb.hidden("pagar_sociedad","")%>
<%=fb.hidden("descripcion","")%>
<%=fb.hidden("diferencia_honorario","")%>


<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("tipo_servicioy",codTSHon)%>
<%=fb.hidden("proveedor","")%>
<%=fb.hidden("no_orden",noOrden)%>
<%=fb.hidden("codigo_orden",codigoOrden)%>
<%=fb.hidden("id_int_far",idIntFar)%>
<%=fb.hidden("fPage",fPage)%>
<%=fb.hidden("bar__code",bar__code)%>
<%
String colspan = "8";
int _substract = 0;

if(fg.equals("PAC") || fg.equals("FH")){
  colspan = "9";
  if (mode.trim().equals("add")) _substract = 2;
}
%>
<table width="100%" align="center">
<%if(fg.equals("HON")){%>
<!--<tr class="TextHeader" align="center">
	<td width="13%"><cellbytelabel id="1">Fecha</cellbytelabel></td>
	<td width="7%"><cellbytelabel id="2">Serv</cellbytelabel>.</td>
	<td width="10%"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
	<td width="37%"><cellbytelabel id="4">Descripci&oacute;n del Cargo</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="5">Cant.</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="6">Precio Unit.</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="7">Total</cellbytelabel></td>
	<td width="3%"></td>
</tr>
<tr class="TextHeader" align="center">
	<td>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="nameOfTBox1" value="fecha_cargoy" />
		<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
		<jsp:param name="jsEvent" value="setValidDate(-1)" />
		</jsp:include>
	</td>
	<td><%//=fb.textBox("tipo_servicioy",codTSHon,false,false,true,10)%></td>
	<td><%//=fb.textBox("trabajoy","",false,false,true,10)%></td>
	<td><%//=fb.select("honorario_pory","M=Medico,P=Procedimientos Especiales,O=Otros","")%></td>
	<td><%//=fb.intPlusBox("cantidady","1",false,false,true,10,null,null,"onChange=\"javascript:calMonto('y','c')\"")%></td>
	<td><%//=fb.decBox("montoy","",true,false,false,10,10.2,null,null,"onChange=\"javascript:calMonto('y','p')\"")%></td>
	<td><%//=fb.decBox("totaly","0",false,false,true,10, 10.2)%></td>
	<td align="center"><%//=fb.submit("addy","+",false,viewMode)%></td>
</tr>-->


<%}%>
<%if(fg.equals("PAC") || fg.equals("FH")|| fg.equals("HON")){%>
<tr class="TextHeader" align="center">
<%if(!fPage.equalsIgnoreCase("int_farmacia") && mode.trim().equals("add") && tipoTransaccion.trim().equals("C")){%>
    <td colspan="2" align="left">
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="applyChargeDate" />
				<jsp:param name="valueOfTBox1" value="" />
			</jsp:include>
			<img src="../images/update.png" alt="Cambiar Fecha Cargo" title="Cambiar Fecha Cargo" onClick="updateFIEC('FC')" style="cursor:pointer;"/>
	</td>
	<%}else{_substract=0;}%>
	<td colspan="<%=Integer.parseInt(colspan)-_substract%>" align="right"><%if( !fPage.equalsIgnoreCase("int_farmacia") &&imprimirCargo.trim().equals("S")){%>
		Imprimir Cargos al Guardar?&nbsp;&nbsp;
		<%=fb.checkbox("printCargosOF", "S",(!fPage.equalsIgnoreCase("int_farmacia")),false)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%>
		
		<%if (!fPage.equalsIgnoreCase("int_farmacia") && tipoTransaccion.trim().equals("C")){%>
		<%=fb.button("updFIE", "Actualizar F. Ing/Egr", false, viewMode, "", "", "onClick=\"javascript: updateFIEC('FIE');\"")%>
		<%}%>
		
	   <%//=fb.button("addCargos", "Agregar Cargos", false, viewMode, "", "", "onClick=\"javascript: _doSubmit(this.value);\"")%>
	    <%//=fb.submit("addCargos", "Agregar Cargos", false, false, "", "", "onClick=\"javascript: return(doSubmit());\"")%>
    </td>
</tr>
<%}%>
<tr class="TextHeader" align="center">
	<td width="13%"><cellbytelabel id="1">Fecha</cellbytelabel></td>
	<td width="7%"><cellbytelabel id="2">Serv</cellbytelabel>.</td>
	<td width="10%"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
	<%if(fg.equals("PAC") || fg.equals("FH")){%>
	  <td>C.Barra</td>
	<%}%>
	<td width="35%"><cellbytelabel id="4">Descripci&oacute;n del Cargo</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="5">Cant.</cellbytelabel></td>
	<td width="12%"><cellbytelabel id="6">Precio Unit.</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="7">Total</cellbytelabel></td>
	<td width="3%"></td>
</tr>
<%if(fg.equals("FAR")){%>
<tr class="TextHeader" align="center">
	<td>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="nameOfTBox1" value="fecha_cargox" />
		<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
		<jsp:param name="jsEvent" value="setValidDate(-1)" />
		</jsp:include>
	</td>
	<td><%=fb.textBox("tipo_serviciox","03",false,false,true,10)%></td>
	<td><%=fb.textBox("trabajox","1",false,false,true,10)%></td>
	<td><%=fb.textBox("descripcionx","",false,false,true,65)%></td>
	<td><%=fb.intPlusBox("cantidadx","0",false,false,false,10,null,null,"onChange=\"javascript:calMonto('x','c')\"")%></td>
	<td><%=fb.decBox("montox","0",false,false,false,10,10.2,null,null,"onChange=\"javascript:calMonto('x','p')\"")%></td>
	<td><%=fb.decBox("totalx","0",false,false,true,10, 10.2)%></td>
	<td align="center"><%=fb.submit("addx","+",false,false)%></td>
</tr>
<%}%>
<%
if (fTranCarg.size() > 0) al = CmnMgr.reverseRecords(fTranCarg);

for (int i=0; i<fTranCarg.size(); i++)
{
	key = al.get(i).toString();

	FactDetTransaccion ad = (FactDetTransaccion) fTranCarg.get(key);

	String color = "";

	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	String fecha = "fecha_cargo"+i;
	String setValidDate = "javascript:setValidDate("+i+");newHeight();";
	String fdtc = "";
	boolean readonly = true;
	if(fg.equals("HON")&&tipoTransaccion.equals("H"))readonly = false;
	if(FTransDet.getCentroServicio().equals("99")) readonly = false;
	//if(ad.getCdsProducto().equals("73")) fdtc = " onMouseOver=\"javascript:setoverc(this,'TextRowOver')\" onMouseOut=\"javascript:setoutc(this,'"+color+"')\" onDblClick=\"javascript:getComp('"+key+"');\" style=\"cursor:pointer\"";
%>
<%=fb.hidden("habitacion"+i,ad.getHabitacion())%>
<%=fb.hidden("servicio_hab"+i,ad.getServicioHab())%>
<%=fb.hidden("cds_producto"+i,ad.getCdsProducto())%>
<%=fb.hidden("cod_uso"+i,ad.getCodUso())%>
<%=fb.hidden("centro_costo"+i,ad.getCentroCosto())%>
<%=fb.hidden("costo_art"+i,ad.getCostoArt())%>
<%=fb.hidden("procedimiento"+i,ad.getProcedimiento())%>
<%=fb.hidden("otros_cargos"+i,ad.getOtrosCargos())%>
<%=fb.hidden("recargo"+i,ad.getRecargo())%>
<%=fb.hidden("compSize"+i,""+ad.getFDetTransComp().size())%>
<%=fb.hidden("cant_cargo"+i,""+ad.getCantCargo())%>
<%=fb.hidden("cant_devolucion"+i,""+ad.getCantDevolucion())%>

<%=fb.hidden("trabajo"+i,""+ad.getTrabajo())%>
<%=fb.hidden("inv_almacen"+i,""+ad.getInvAlmacen())%>
<%=fb.hidden("art_familia"+i,""+ad.getArtFamilia())%>
<%=fb.hidden("art_clase"+i,""+ad.getArtClase())%>
<%=fb.hidden("inv_articulo"+i,""+ad.getInvArticulo())%>
<%=fb.hidden("inventario"+i,""+ad.getInventario())%>
<%=fb.hidden("cantidad_disponible"+i,""+ad.getCantidadDisponible())%>
<%=fb.hidden("barCode"+i,""+ad.getBarCode())%>
<%=fb.hidden("cama"+i,""+ad.getCama())%>
<%=fb.hidden("afecta_inv"+i,""+ad.getAfectaInv())%>
<%=fb.hidden("curInd"+i,""+i)%>
<%=fb.hidden("uniq_identifier"+i,""+ad.getUniqIdentifier())%>
<%=fb.hidden("ref_id"+i, ad.getRefId())%>
<%=fb.hidden("ref_type"+i, ad.getRefType())%>
<%if(ad.getCentroServicio()!=null && !ad.getCentroServicio().equals("")){%>
<%=fb.hidden("centro_servicio"+i,ad.getCentroServicio())%>
<%}%>
<tr class="<%=color%>" align="center" <%=fdtc%>>
	<td>
	<%if (mode.equalsIgnoreCase("add")){%>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="nameOfTBox1" value="<%=fecha%>" />
		<jsp:param name="valueOfTBox1" value="<%=ad.getFechaCargo()%>" />
		<jsp:param name="jsEvent" value="<%=setValidDate%>" />
		<jsp:param name="readonly" value="<%=(!tipoTransaccion.trim().equals("D")?"n":"y")%>" />
		</jsp:include>
	<%}else{%>
		<%=fb.textBox(fecha,ad.getFechaCargo(),false,false,true,10)%>
	<%}%>
	<%=fb.hidden("descripcion"+i,ad.getTrabajoDesc())%>
	</td>
	<td><%=fb.textBox("tipo_servicio"+i,ad.getTipoCargo(),false,false,true,3)%></td>
	<td><%=ad.getTrabajo()%></td>
	<%if(fg.equals("PAC") || fg.equals("FH")){%>
	  <td><%=ad.getBarCode()%></td>
	<%}%>
	<td align="left">
	<%if(fg.equals("HON") &&tipoTransaccion.equals("C") ){%>
	<%=fb.select("honorario_por"+i,"M=Medico,P=Procedimientos Especiales,O=Otros",ad.getHonorarioPor(),false,viewMode,0)%>
	<%}else{%>
		<%=fb.hidden("honorario_por"+i,""+ad.getHonorarioPor())%>
		<%=ad.getTrabajoDesc()%>
	<%}%>
	</td>
	<td>
    <%
    String _calMonto = "";
    if (!fPage.equalsIgnoreCase("int_farmacia")) _calMonto = "onChange=\"javascript:calMonto("+i+",'c')\"";
    %>
    <%=fb.intPlusBox("cantidad"+i,ad.getCantidad(),(fg.equals("HON"))?true:false,false,viewMode,5,10,"cantidad"+ad.getBarCode(),null,_calMonto, null,false,null)%>
    </td>
	<td>
    <%if(fPage.equalsIgnoreCase("int_farmacia")){%>0.00
    <%=fb.hidden("monto"+i,ad.getMonto())%>
    <%}else{%>
    <% if (tipoTransaccion.equalsIgnoreCase("C") && !ad.getInvArticulo().trim().equals("")) { %><authtype type="51"><a href="javascript:setRegalia(<%=i%>);"><img height="20" width="20" src="../images/gift.png"></a></authtype><% } %>
		<%=fb.decBox("monto"+i,ad.getMonto(),(fg.equals("HON"))?true:false,false,readonly,10,10.2, "", "", "onChange=\"javascript:calMonto("+i+",'p')\"")%>
    <%}%>
    </td>
	<td>
    <%if(fPage.equalsIgnoreCase("int_farmacia")){%>
      <%=fb.hidden("total"+i,ad.getMontoTotal())%>0.00
    <%}else{%>
      <%=fb.decBox("total"+i,ad.getMontoTotal(),false,false,true,10, 10.2)%>
    <%}%>
    </td>
	<td align="center"><%=fb.submit("del"+i,"x",false,viewMode,"","","onClick=\"javascript:document.form1.baction.value=this.value\"")%></td>
</tr>
	<%
}
%>
<tr class="TextRow02" align="center">
    <%if(!fPage.equalsIgnoreCase("int_farmacia")){%>
	<td colspan="2" align="right">
    <%=fb.button("btnImpresionCargoDev","Imprimir Detalle de Cargos",true,false,null,null,"onClick=\"javascript:printCargoDev()\"")%>
    </td>
	<td colspan="4" align="right"><cellbytelabel id="7">Total</cellbytelabel></td>
	<td><%=fb.decBox("total","0",false,false,true,10,12.2)%></td>
	<td colspan="<%=(fg.equals("PAC") || fg.equals("FH")?"3":"2")%>">&nbsp;</td>
    <%}else{%>
      <%=fb.hidden("total","0")%>
    <%}%>
</tr>
<%=fb.hidden("keySize",""+fTranCarg.size())%>
</table>
<%fb.appendJsValidation("if(error>0)doAction();");%>
<%//fb.appendJsValidation("\n\tif (!validaFechas(-1))\n\t{\n\t\t\n\t\terror++;\n\t}\n");%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String dl = "";
	tipoTransaccion = request.getParameter("tipoTransaccion");
	//Ajuste FTransDet = new Ajuste();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	FTransDet.setAdmCategoria(request.getParameter("categoria"));
	FTransDet.setAdmCategoriaDesc(request.getParameter("categoriaDesc"));
	FTransDet.setNumFactura(request.getParameter("numFactura"));
	FTransDet.setAdmFechaIngreso(request.getParameter("fechaIngreso"));
	FTransDet.setAdmiCodigoPaciente(request.getParameter("codigoPaciente"));
	FTransDet.setAdmiFechaNacimiento(request.getParameter("fechaNacimiento"));
	FTransDet.setAdmiSecuencia(request.getParameter("admSecuencia"));
	FTransDet.setCentroServicio(request.getParameter("centroServicio"));
	FTransDet.setCentroServicioDesc(request.getParameter("centroServicioDesc"));
	FTransDet.setClasificacion(request.getParameter("clasificacion"));
	FTransDet.setCodigo(request.getParameter("codigo"));
	FTransDet.setDescEstado(request.getParameter("desc_estado"));
	FTransDet.setEstado(request.getParameter("estado"));
	FTransDet.setEmbarazada(request.getParameter("embarazada"));
	//FTransDet.setEmpreCodigo(request.getParameter("empresa"));
	FTransDet.setFechaCreacion(request.getParameter("fechaCreacion"));
	FTransDet.setFechaModificacion(request.getParameter("fechaModificacion"));
	FTransDet.setIncremento(request.getParameter("incremento"));
	FTransDet.setJubilado(request.getParameter("jubilado"));
	FTransDet.setMedicoCirugia(request.getParameter("medico"));
	FTransDet.setMesCta(request.getParameter("mesCta"));
	FTransDet.setNoDocumento(request.getParameter("noDocumento"));
	FTransDet.setNombreMedicoCirugia(request.getParameter("nombreMedico"));
	FTransDet.setNombrePaciente(request.getParameter("nombrePaciente"));
	FTransDet.setNumSolicitud(request.getParameter("numSolicitud"));
	FTransDet.setPacAsiento(request.getParameter("asiento"));
	FTransDet.setPacDCedula(request.getParameter("dCedula"));
	FTransDet.setPacienteId(request.getParameter("pacienteId"));
	FTransDet.setPacProvincia(request.getParameter("provincia"));
	FTransDet.setPacSigla(request.getParameter("sigla"));
	FTransDet.setPacTomo(request.getParameter("tomo"));
	FTransDet.setPasaporte(request.getParameter("pasaporte"));
	FTransDet.setReportaA(request.getParameter("reportaA"));
	FTransDet.setTipoCds(request.getParameter("tipoCds"));
	FTransDet.setTipoIncremento(request.getParameter("tipoInc"));
	FTransDet.setTipoTransaccion(request.getParameter("tipoTransaccion"));
	//System.out.println("generaArchivo="+request.getParameter("generaArchivo"));
	if(request.getParameter("generaArchivo") !=null && request.getParameter("generaArchivo").equals("S")) FTransDet.setGeneraArchivo("S");
	else FTransDet.setGeneraArchivo("N");
	//System.out.println("generaArchivo="+FTransDet.getGeneraArchivo());
	if(fg.equals("HON")){
		if(request.getParameter("medico") !=null && !request.getParameter("medico").equals("")) FTransDet.setMedCodigo(request.getParameter("medico"));
	}

	if(request.getParameter("seCodProveedor") !=null && !request.getParameter("seCodProveedor").equals("")) FTransDet.setSeCodProveedor(request.getParameter("seCodProveedor"));
	if(request.getParameter("seDescProveedor") !=null && !request.getParameter("seDescProveedor").equals("")) FTransDet.setSeDescProveedor(request.getParameter("seDescProveedor"));
	if(request.getParameter("seNumeroDocumento") !=null && !request.getParameter("seNumeroDocumento").equals("")) FTransDet.setSeNumeroDocumento(request.getParameter("seNumeroDocumento"));
	if(request.getParameter("seFechaDocumento") !=null && !request.getParameter("seFechaDocumento").equals("")) FTransDet.setSeFechaDocumento(request.getParameter("seFechaDocumento"));

	if(request.getParameter("empreCodigo") !=null && !request.getParameter("empreCodigo").equals("")) FTransDet.setEmpreCodigo(request.getParameter("empreCodigo"));
	if(request.getParameter("empreDesc") !=null && !request.getParameter("empreDesc").equals("")) FTransDet.setEmpreNombre(request.getParameter("empreDesc"));
	if(request.getParameter("pagar_sociedad") !=null && request.getParameter("pagar_sociedad").equals("S")) FTransDet.setPagarSociedad("S");
	else FTransDet.setPagarSociedad("N");
	if(request.getParameter("diferencia_honorario") !=null && request.getParameter("diferencia_honorario").equals("S")) FTransDet.setDiferenciaHonorario("S");
	else FTransDet.setDiferenciaHonorario("N");

	if(request.getParameter("descripcion") !=null && !request.getParameter("descripcion").equals("")) FTransDet.setDescripcion(request.getParameter("descripcion"));
    
    if (fPage.equalsIgnoreCase("int_farmacia")){
      FTransDet.setRefType("FARINSUMOS");
      FTransDet.setNumSolicitud(request.getParameter("id_int_far"));
      FTransDet.setDescripcion(request.getParameter("id_int_far")+"-"+codigoOrden+"-INSUMOS FARMACIA");
      System.out.println("................................................. 1");
    }
    

	int size = Integer.parseInt(request.getParameter("size"));
	FTransDet.getFTransDetail().clear();
	fTranCarg.clear();
	int lineNo = 0, _lineNo = 0;
	String _key = "", okey = "";

	for (int i=0; i<keySize; i++){
		FactDetTransaccion det = new FactDetTransaccion();

		det.setTipoCargo(request.getParameter("tipo_servicio"+i));
		det.setTipoCargoDesc(request.getParameter("tipo_serv_desc"+i));
		det.setTrabajoDesc(request.getParameter("descripcion"+i));
		det.setTrabajo(request.getParameter("trabajo"+i));
		det.setMonto(request.getParameter("monto"+i));
		det.setFechaCargo(request.getParameter("fecha_cargo"+i));
		det.setCantidad(request.getParameter("cantidad"+i));
		det.setEstatus("S");
		det.setDescripcion(request.getParameter("descripcion"+i));
		det.setUsuarioCreacion((String) session.getAttribute("_userName"));
		det.setUsuarioModificacion((String) session.getAttribute("_userName"));
		det.setNoCubierto("N");
        det.setUniqIdentifier(request.getParameter("uniq_identifier"+i));

		//System.out.println("det.setEstatus()="+det.getEstatus());
        if (tipoTransaccion.trim().equalsIgnoreCase("D"))det.setRefType(request.getParameter("ref_type"+i));
    	if (tipoTransaccion.trim().equalsIgnoreCase("D"))det.setRefId(request.getParameter("ref_id"+i));
		
        if (fPage.equalsIgnoreCase("int_farmacia")){
          det.setRefType("FARINSUMOS");
          
          if (tipoTransaccion.trim().equalsIgnoreCase("C")) det.setRefId(request.getParameter("id_int_far"));
          else det.setRefId(request.getParameter("ref_id"+i));
          
          System.out.println("................................................. 2");
        }

		det.setCentroServicio(FTransDet.getCentroServicio());
		if(request.getParameter("centro_servicio"+i)!=null && !request.getParameter("centro_servicio"+i).equals("")) det.setCentroServicio(request.getParameter("centro_servicio"+i));
		if(request.getParameter("habitacion"+i)!=null && !request.getParameter("habitacion"+i).equals("null") && !request.getParameter("habitacion"+i).equals("")) det.setHabitacion(request.getParameter("habitacion"+i));
		//else det.setHabitacion("0");
		if(request.getParameter("servicio_hab"+i)!=null && !request.getParameter("servicio_hab"+i).equals("null") && !request.getParameter("servicio_hab"+i).equals("")) det.setServicioHab(request.getParameter("servicio_hab"+i));
		//else det.setServicioHab("0");
		if(request.getParameter("cds_producto"+i)!=null && !request.getParameter("cds_producto"+i).equals("null") && !request.getParameter("cds_producto"+i).equals("") && !request.getParameter("cds_producto"+i).equals("0")) det.setCdsProducto(request.getParameter("cds_producto"+i));
		//else det.set("0");
		if(request.getParameter("cod_uso"+i)!=null && !request.getParameter("cod_uso"+i).equals("null") && !request.getParameter("cod_uso"+i).equals("") && !request.getParameter("cod_uso"+i).equals("0")) det.setCodUso(request.getParameter("cod_uso"+i));
		//else det.setCodUso("0");
		if(request.getParameter("centro_costo"+i)!=null && !request.getParameter("centro_costo"+i).equals("null") && !request.getParameter("centro_costo"+i).equals("")) det.setCentroCosto(request.getParameter("centro_costo"+i));
		//else det.setCentoCosto("0");
		if(request.getParameter("costo_art"+i)!=null && !request.getParameter("costo_art"+i).equals("null") && !request.getParameter("costo_art"+i).equals("")) det.setCostoArt(request.getParameter("costo_art"+i));
		//else det.setCostoArt("0");
		if(request.getParameter("procedimiento"+i)!=null && !request.getParameter("procedimiento"+i).equals("null") && !request.getParameter("procedimiento"+i).equals("")) det.setProcedimiento(request.getParameter("procedimiento"+i));
		//else det.setProcedimiento("0");
		if(request.getParameter("otros_cargos"+i)!=null && !request.getParameter("otros_cargos"+i).equals("null") && !request.getParameter("otros_cargos"+i).equals("")) det.setOtrosCargos(request.getParameter("otros_cargos"+i));
		//else det.setOtrosCargos("0");
		if(request.getParameter("recargo"+i)!=null && !request.getParameter("recargo"+i).equals("null") && !request.getParameter("recargo"+i).equals("")) det.setRecargo(request.getParameter("recargo"+i));
		//else det.setRecargo("0");
		if(request.getParameter("cant_cargo"+i)!=null && !request.getParameter("cant_cargo"+i).equals("null") && !request.getParameter("cant_cargo"+i).equals("")) det.setCantCargo(request.getParameter("cant_cargo"+i));
		//else det.setCantCargo("0");
		if(request.getParameter("cant_devolucion"+i)!=null && !request.getParameter("cant_devolucion"+i).equals("null") && !request.getParameter("cant_devolucion"+i).equals("")) det.setCantDevolucion(request.getParameter("cant_devolucion"+i));
		//else det.setCantDevolucion("0");
		if(request.getParameter("cama"+i)!=null && !request.getParameter("cama"+i).equals("null") && !request.getParameter("cama"+i).equals("")) det.setCama(request.getParameter("cama"+i));
		det.setAfectaInv(request.getParameter("afecta_inv"+i));
		
		if(request.getParameter("honorario_por"+i)!=null && !request.getParameter("honorario_por"+i).equals("null") && !request.getParameter("honorario_por"+i).equals("")){ det.setHonorarioPor(request.getParameter("honorario_por"+i));
		if(det.getHonorarioPor().equals("M")) det.setTrabajoDesc("Medicos");
		else if(det.getHonorarioPor().equals("P")) det.setTrabajoDesc("Procedimientos Especiales");
	    else if(det.getHonorarioPor().equals("O")) det.setTrabajoDesc("Otros");}
		if(det.getDescripcion() == null || det.getDescripcion().trim().equals(""))det.setDescripcion(""+det.getTrabajoDesc());
		
		det.setInvAlmacen(request.getParameter("inv_almacen"+i));
		det.setArtFamilia(request.getParameter("art_familia"+i));
		det.setArtClase(request.getParameter("art_clase"+i));
		det.setInvArticulo(request.getParameter("inv_articulo"+i));
		det.setInventario(request.getParameter("inventario"+i));
		det.setCantidadDisponible(request.getParameter("cantidad_disponible"+i));
		det.setBarCode(request.getParameter("barCode"+i));
		_lineNo++;
		if (_lineNo < 10) _key = "00"+_lineNo;
		else if (_lineNo < 100) _key = "0"+_lineNo;
		else _key = ""+_lineNo;

		if(fTranDComp.containsKey(_key)) det.setFDetTransComp((ArrayList) fTranDComp.get(_key));

		if(!dl.equals("")){
			for(int j=0;j<det.getFDetTransComp().size();j++){
				FactDetTransComp _det = new FactDetTransComp();

				if ((j+1) < 10) okey = "00"+(j+1);
				else if ((j+1) < 100) okey = "0"+(j+1);
				else okey = ""+(j+1);

				String artDel = _key+"_"+_det.getCodProdFar();
				if (fTranCompKey.containsKey(artDel)){
					//System.out.println("- remove item "+artDel);
					fTranComp.remove((String) fTranCompKey.get(artDel));
					fTranCompKey.remove(artDel);
				}
			}
		}

		if(request.getParameter("del"+i)==null){
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				fTranCarg.put(key,det);

				if(tipoTransaccion.equals("D"))
				fTranCargKey.put(det.getUniqIdentifier()+"_"+det.getFechaCargo()+"_"+det.getTipoCargo()+"_"+det.getTrabajo(), key);
				else fTranCargKey.put(det.getUniqIdentifier()+"_"+det.getTipoCargo()+"_"+det.getTrabajo(), key);
				FTransDet.getFTransDetail().add(det);
				//System.out.println("Adding item... "+key +"_"+det.getUniqIdentifier()+"_"+det.getTipoCargo()+"_"+det.getTrabajo());
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}

			for(int j=0;j<det.getFDetTransComp().size();j++){
				FactDetTransComp _det = new FactDetTransComp();

				if ((j+1) < 10) okey = "00"+(j+1);
				else if ((j+1) < 100) okey = "0"+(j+1);
				else okey = ""+(j+1);

				try {
					fTranComp.put(key+"_"+okey, det);
					fTranCompKey.put(key + "_" + det.getCodProdFar(), _key+"_"+key);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}
		} else {
			if(tipoTransaccion.equals("D"))
			dl = det.getUniqIdentifier()+"_"+det.getFechaCargo()+"_"+det.getTipoCargo()+"_"+det.getTrabajo();
			else dl = det.getUniqIdentifier()+"_"+det.getTipoCargo()+"_"+det.getTrabajo();


			if (fTranCargKey.containsKey(dl)){
				System.out.println("- remove item "+dl+" size ==== "+fTranCarg.size());
				//System.out.println("- item "+(String) fTranCargKey.get(dl));
				fTranCarg.remove((String) fTranCargKey.get(dl));
				fTranCargKey.remove(dl);
				System.out.println("- remove item "+fTranCarg.size());
			}
			//FTransDet.getFTransDetail().remove(i);
		}
		//System.out.println("det.setEstatus()="+det.getEstatus());
	}
	if(request.getParameter("addx")!= null && fg.equals("FAR")){
		FactDetTransaccion det = new FactDetTransaccion();

		det.setTipoCargo(request.getParameter("tipo_serviciox"));
		det.setTipoCargoDesc(request.getParameter("tipo_serv_desc"));
		//det.setTrabajoDesc(request.getParameter("descripcion"));
		det.setTrabajo(request.getParameter("trabajo"));
		det.setMonto(request.getParameter("montox"));
		det.setFechaCargo(request.getParameter("fecha_cargox"));
		det.setCantidad(request.getParameter("cantidadx"));
		det.setEstatus("S");
        
         if (fPage.equalsIgnoreCase("int_farmacia")){
          det.setRefType("FARINSUMOS");
          det.setRefId(request.getParameter("id_int_far"));
          System.out.println("................................................. 3");
        }

		lineNo++;

		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;

		try{
			fTranCarg.put(key,det);
			if(tipoTransaccion.equals("D"))
			fTranCargKey.put(det.getFechaCargo()+"_"+det.getTipoCargo()+"_"+det.getTrabajo(), key);
			else fTranCargKey.put(det.getTipoCargo()+"_"+det.getTrabajo(), key);
			FTransDet.getFTransDetail().add(det);
			//System.out.println("Adding item... "+key +"_"+det.getTipoCargo()+"_"+det.getTrabajo());
		} catch (Exception e){
			System.out.println("Unable to add item...");
		}
	}
	
	if((tipoTransaccion!= null && tipoTransaccion.trim().equals("H"))&& fg.equals("HON") && dl.equals("")&&!clearHT.equals("S")&&!request.getParameter("baction").equalsIgnoreCase("Guardar")){
		FactDetTransaccion det = new FactDetTransaccion();

		det.setTipoCargo(request.getParameter("tipo_servicioy"));
		//det.setHonorarioPor(request.getParameter("honorario_pory"));

		//if(det.getHonorarioPor().equals("M")) det.setTrabajoDesc("Medicos");
		//else if(det.getHonorarioPor().equals("P")) det.setTrabajoDesc("Procedimientos Especiales");
		//else if(det.getHonorarioPor().equals("O")) det.setTrabajoDesc("Otros");

		//det.setMonto(request.getParameter("montoy"));
		det.setFechaCargo(cDateTime);
		det.setCantidad("1");
		det.setEstatus("S");

		lineNo++;
		det.setTrabajo(""+lineNo);
		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;

		/*if(request.getParameter("del"+i)==null){*/
		try{
			fTranCarg.put(key,det);
			if(tipoTransaccion.equals("D"))
			fTranCargKey.put(det.getFechaCargo()+"_"+det.getTipoCargo()+"_"+det.getTrabajo(), key);
			else fTranCargKey.put(det.getTipoCargo()+"_"+det.getTrabajo(), key);
			FTransDet.getFTransDetail().add(det);
			System.out.println("Adding item... "+key +"_"+det.getTipoCargo()+"_"+det.getTrabajo());
		} catch (Exception e){
			System.out.println("Unable to add item...");
		}
	}

	//System.out.println("clearHT="+clearHT);
	if(!dl.equals("") || clearHT.equals("S") || (request.getParameter("addx")!=null && request.getParameter("addx").equals("+")) || ((tipoTransaccion!= null && tipoTransaccion.trim().equals("H"))&& fg.equals("HON"))&&!request.getParameter("baction").equalsIgnoreCase("Guardar")){
		response.sendRedirect("../facturacion/reg_cargo_dev_det_new.jsp?mode="+mode+ "&change=1&type=2&fg="+fg+"&tipoTransaccion="+tipoTransaccion+"&bar__code="+bar__code+"&fPage="+fPage);
		return;
	}

	if(request.getParameter("baction")!=null && (request.getParameter("baction").equals("Agregar Cargos") || request.getParameter("baction").equals("[+]Cargos"))){
		response.sendRedirect("../facturacion/reg_cargo_dev_det_new.jsp?mode="+mode+"&id="+id+"&change=1&type=1&fg="+fg+"&tipoTransaccion="+tipoTransaccion+"&bar__code="+bar__code+"&fPage="+fPage);
		return;
	}

	//System.out.println("request.getParameter(addCargos)="+request.getParameter("addCargos"));


	CommonDataObject cdoMsg = null;
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		FTransDet.setCompania((String) session.getAttribute("_companyId"));
		FTransDet.setUsuarioCreacion((String) session.getAttribute("_userName"));
		FTransDet.setSeFechaCxP(cDateTime);
		FTransDet.setUsuarioModificacion((String) session.getAttribute("_userName"));
		FTransDet.setIp(request.getRemoteAddr());
		if(fg.equals("HON"))FTransDet.setAutoBoleta(autoBoleta);else FTransDet.setAutoBoleta("N");
		//FTransDet.setEmpreCodigo("");
		FTransMgr.add(FTransDet);
		codigo = FTransMgr.getPkColValue("codigo");
		ConMgr.clearAppCtx(null);
		
		StringBuffer sbSql = new StringBuffer();
		sbSql.append("select join(cursor(select distinct notes from tbl_fac_detalle_transaccion where pac_id = ");
		sbSql.append(FTransDet.getPacienteId());
		sbSql.append(" and fac_secuencia = ");
		sbSql.append(FTransDet.getAdmiSecuencia());
		sbSql.append(" and tipo_transaccion = '");
		sbSql.append(FTransDet.getTipoTransaccion());
		sbSql.append("' and fac_codigo = ");
		sbSql.append(codigo);
		sbSql.append(" and notes not like 'REPLICADA%'),chr(10)||'* ') as notes, (select TO_CHAR (fecha, 'yyyy')||'|'||seq_trx  from tbl_fac_transaccion where pac_id = ");
		sbSql.append(FTransDet.getPacienteId());
		sbSql.append(" and admi_secuencia = ");
		sbSql.append(FTransDet.getAdmiSecuencia());
		sbSql.append(" and tipo_transaccion = '");
		sbSql.append(FTransDet.getTipoTransaccion());
		sbSql.append("' and codigo = ");
		sbSql.append(codigo);
		sbSql.append(") ref_code from dual");
		cdoMsg = SQLMgr.getData(sbSql.toString());
	}
	if (cdoMsg == null) cdoMsg = new CommonDataObject();

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if (FTransMgr.getErrCode().equals("1")){%>
<% if (cdoMsg.getColValue("notes") != null && !cdoMsg.getColValue("notes").trim().equals("")) { %>alert('El cargo/devolución se registró con la(s) siguiente(s) advertencia(s): \n* <%=cdoMsg.getColValue("notes")%>');<% } %>
	parent.document.form0.errCode.value = <%=FTransMgr.getErrCode()%>;
	parent.document.form0.errMsg.value = '<%=FTransMgr.getErrMsg()%>';
	parent.document.form0.ref_code.value = '<%=cdoMsg.getColValue("ref_code")%>';
	//parent.document.form0.codigo.value = '<%=codigo%>';
	<%if((request.getParameter("fg")!=null && (request.getParameter("fg").equals("PAC") || request.getParameter("fg").equals("FH")||request.getParameter("fg").equals("HON"))) && request.getParameter("printCargosOF")!=null && request.getParameter("printCargosOF").trim().equals("S") ){%>
	    parent.document.form0.printOF.value = "S";
	<%}%>
	parent.document.form0.submit();
	<%
	session.removeAttribute("_tmpCant");
	} else throw new Exception(FTransMgr.getErrException());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST 
%>