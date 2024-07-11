<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="SOL" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SolMgr" scope="page" class="issi.planmedico.SolicitudMgr"/>
<jsp:useBean id="Sol" scope="session" class="issi.planmedico.Solicitud"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="htClt" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vClt" scope="session" class="java.util.Vector"/>
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable"/>
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
SolMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alPar = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String anio = request.getParameter("anio");
String id_motivo = request.getParameter("id_motivo");
int lineNo = 0;
if(fp==null)fp="plan_medico";
boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
alPar = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn from tbl_pla_parentesco where disponible_en_pm = 'S' and codigo != 0 order by 1 ",CommonDataObject.class);
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) htClt.clear();
	else if ((mode.equalsIgnoreCase("add") || mode.equalsIgnoreCase("edit"))  && change != null && change.equals("2")){
		int i = htClt.size();
		CommonDataObject cd = new CommonDataObject();
		cd.addColValue("id_cliente", request.getParameter("clientId"));
		cd.addColValue("client_name", request.getParameter("client_name"));
		cd.addColValue("identificacion", request.getParameter("identificacion"));
		cd.addColValue("fecha_nacimiento", request.getParameter("fecha_nacimiento"));
		cd.addColValue("edad", request.getParameter("edad"));
		cd.addColValue("sexo", request.getParameter("sexo"));
		cd.addColValue("id", "0");
		cd.addColValue("id_solicitud", "0");
		cd.addColValue("parentesco", "0");
		cd.addColValue("diagnostico", "");
		cd.addColValue("medicamento", "");

		if ((i+1) < 10) key = "00"+(i+1);
		else if ((i+1) < 100) key = "0"+(i+1);
		else key = ""+(i+1);

		htClt.put(key, cd);
		vClt.add(cd.getColValue("id_cliente"));
	} else if (mode.equalsIgnoreCase("add") && change != null && change.equals("3")){
		al = CmnMgr.reverseRecords(htClt);
		for (int i=1; i<=htClt.size(); i++)
		{
			key = al.get(i - 1).toString();
			CommonDataObject xcdo = (CommonDataObject) htClt.get(key);
			if(xcdo.getColValue("parentesco").equals("0")){
				htClt.remove(key);
				break;
			}
		}
		vClt.remove(request.getParameter("clientId"));
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction()
{
	var cuota = parent.document.solicitud.cuota.value;
	var afiliados = '';
	var estado = parent.document.solicitud.estadoDB.value;
	var en_transicion = parent.document.solicitud.en_transicion.value;
	var id_cliente = '';
	if(parent.window.frames['clteFrame'].document.getElementById('id_cliente')) id_cliente = parent.window.frames['clteFrame'].document.getElementById('id_cliente').value;
	if(parent.document.solicitud.afiliados) afiliados = parent.document.solicitud.afiliados.value;
	<%
	if(type!=null && type.equals("1")){
	%>
	abrir_ventana1('../planmedico/pm_sel_cliente.jsp?fp=<%=fp%>&mode=<%=mode%>&id=<%=id%>&fg=beneficiario&cuota='+cuota+'&afiliados='+afiliados+'&id_cliente='+id_cliente+'&en_transicion='+en_transicion);
	<%
	}
	%>
	if(estado!='A') calc();
	newHeight();
	setReadOnly();
}

function setReadOnly(){
	var size = <%=htClt.size()%>;
	var afiliados = parent.document.solicitud.afiliados.value;
	if(afiliados==2){
		for(i=0;i<size;i++){
			eval('document.form1.medicamento'+i).readOnly=true;
			eval('document.form1.medicamento'+i).value='NA';
		}
	}
}

function calc(){
	var iCounter = 0;
	var size = <%=htClt.size()%>;
	var costo_mensual = 0.00, plan_monto = 0.00;
    var estadoDB = parent.document.solicitud.estadoDB.value;
	var cuota = parent.document.solicitud.cuota.value;
	var parentescoHijo = parent.document.solicitud.parentescoHijo.value;
	var edadMaxHijo = parent.document.solicitud.edadMaxHijo.value;
	var estado = parent.document.solicitud.estadoDB.value;
	var en_transicion = parent.document.solicitud.en_transicion.value;

	if(cuota=='SF'){
	if(estadoDB=="P" || '<%=fp%>'=='adenda'){
		if('<%=fp%>'=='adenda'){
			var x = 0;
			for(i=0;i<size;i++){
				if(!eval('document.form1.estado'+i))x++;
				else if(eval('document.form1.estado'+i) && eval('document.form1.estado'+i).value=='A')x++;
			}
			size=x;
		}
		parent.document.solicitud.afiliados.value = getPlan(size,0);
		parent.document.solicitud.plan_desc.value = getPlan(size,1);
		parent.document.solicitud.cant_ben.value = getPlan(size,0);
	}else if('<%=fp%>'!='adenda'){document.getElementById("addClientes").disabled = true;}
	
	if(parent.document.solicitud.afiliados.value != '') plan_monto = eval('parent.document.solicitud.plan_monto_'+parent.document.solicitud.afiliados.value).value;
	plan_monto = plan_monto * size;
	parent.document.solicitud.cuota_mensual.value = plan_monto;
	} else if (cuota=='SFE'){
		var hijo = 0, cont = 0;
		var edad = 0, sexo = '', parentesco = '';
		var planSize = parent.document.solicitud.planSize.value;
		for(i=0;i<size;i++){
			if(estado=='A'){
				plan_monto = plan_monto + parseFloat(isNaN(eval('document.form1.costo_mensual'+i).value)?0:eval('document.form1.costo_mensual'+i).value);
			} else {
			
			edad = parseInt(eval('document.form1.edad'+i).value);
			//if(en_transicion=='S')edad++;
			sexo = eval('document.form1.sexo'+i).value;
			parentesco = eval('document.form1.parentesco'+i).value;
			if('<%=fp%>'=='adenda' && !isNaN(eval('document.form1.costo_mensual'+i).value) && parseFloat(eval('document.form1.costo_mensual'+i).value) != 0) null;
			else eval('document.form1.costo_mensual'+i).value='';
			if(parentesco=='') {
				break;
			} else {

				var estadoDet = (eval('document.form1.estado'+i)?eval('document.form1.estado'+i).value:'');
				//alert(estadoDet);
				if(parentesco==parentescoHijo){
					if('<%=fp%>'!='adenda'){
						hijo++;
					} else {
						if(estadoDet=='A' || estadoDet=='') hijo ++;
					}
					
					if (edad>edadMaxHijo && edadMaxHijo>0){
						alert('No puede incluir hijo mayor de '+edadMaxHijo+' años!');
						eval('document.form1.parentesco'+i).value='';
						break;
					}
				}// else {
				//if(eval('document.form1.costo_mensual'+i).value==''){
					//alert(eval('document.form1.costo_mensual'+i).value);
					if('<%=fp%>'=='adenda' && eval('document.form1.costo_mensual'+i).value!= '' && !isNaN(eval('document.form1.costo_mensual'+i).value) && parseFloat(eval('document.form1.costo_mensual'+i).value) != 0 && parent.document.solicitud.id_motivo.value != 1 && eval('document.form1.id'+i).value!=0){
						cont++;
						//alert('joselo');
					} else if('<%=fp%>'=='adenda' && eval('document.form1.costo_mensual'+i).value!= '' && !isNaN(eval('document.form1.costo_mensual'+i).value) && parseFloat(eval('document.form1.costo_mensual'+i).value) != 0 && (parent.document.solicitud.id_motivo.value == 1 || parent.document.solicitud.id_motivo.value == 5)){
						cont++;
						for(j=0;j<planSize;j++){
						if(parentesco==eval('parent.document.solicitud.parentesco'+j).value && edad >= parseInt(eval('parent.document.solicitud.cant_min'+j).value) && edad <= parseInt(eval('parent.document.solicitud.cant_max'+j).value) && parentesco!=parentescoHijo){
							if(estadoDet=='A'){
							eval('document.form1.costo_mensual'+i).value = eval('parent.document.solicitud.monto'+j).value;
							cont++;
							} else eval('document.form1.costo_mensual'+i).value = 0;
						} else if(parentesco==eval('parent.document.solicitud.parentesco'+j).value && parentesco==parentescoHijo){
							if(estadoDet=='A'){
							if(hijo>2) eval('document.form1.costo_mensual'+i).value = 0;
							else eval('document.form1.costo_mensual'+i).value = eval('parent.document.solicitud.monto'+j).value;
							cont++;
							} else eval('document.form1.costo_mensual'+i).value = 0;
						} 
					}
					} else {
						//alert('jose');
						//alert('edad='+edad);
					for(j=0;j<planSize;j++){
						if(parentesco==eval('parent.document.solicitud.parentesco'+j).value && edad >= parseInt(eval('parent.document.solicitud.cant_min'+j).value) && edad <= parseInt(eval('parent.document.solicitud.cant_max'+j).value) && parentesco!=parentescoHijo){
							eval('document.form1.costo_mensual'+i).value = eval('parent.document.solicitud.monto'+j).value;
							cont++;
						} else if(parentesco==eval('parent.document.solicitud.parentesco'+j).value && parentesco==parentescoHijo){
							if(hijo>2) eval('document.form1.costo_mensual'+i).value = 0;
							else eval('document.form1.costo_mensual'+i).value = eval('parent.document.solicitud.monto'+j).value;
							cont++;
						} 
					}
					}
				//}
				if(estadoDet == 'I')eval('document.form1.costo_mensual'+i).value = 0;
				//alert('estadoDet='+estadoDet);
				
				if(isNaN(eval('document.form1.costo_mensual'+i).value) || eval('document.form1.costo_mensual'+i).value=='' || cont==0) {
					alert('Verifique la edad de Beneficiario que no corresponde a la registrada en el mantenimiento de Afiliados!');
					eval('document.form1.parentesco'+i).value='';
					break;
				}	
				else 
				plan_monto = plan_monto + parseFloat((isNaN(eval('document.form1.costo_mensual'+i).value) || eval('document.form1.costo_mensual'+i).value==''?0:eval('document.form1.costo_mensual'+i).value));
			}
		}
		}
		//}
		parent.document.solicitud.cuota_mensual.value = plan_monto;
	}
	
	if (iCounter > 0) return true;
	else return false;
}

function getPlan(size,ind){
  var r = null;
  if (size > 0){
	r=splitRowsCols(getDBData('<%=request.getContextPath()%>','id, descripcion || \' [ B/ \' || to_char(monto, \'999,999.99\') || \']\'', 'tbl_pm_afiliado','estado = \'A\' and '+size+' between cant_min and cant_max and rownum = 1',''));
  }
  if (r != null) return r[0][ind];
  return "";
}

function doSubmit(valor){
	var x = 1;
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	var cuota = parent.document.solicitud.cuota.value;
	document.form1.id_cliente.value = parent.window.frames['clteFrame'].document.getElementById('id_cliente').value;
	if(parent.document.solicitud.cobertura_mi.checked) document.form1.cobertura_mi.value = 'S';
	else document.form1.cobertura_mi.value = 'N';
	if(parent.document.solicitud.cobertura_cy.checked) document.form1.cobertura_cy.value = 'S';
	else document.form1.cobertura_cy.value = 'N';
	if(parent.document.solicitud.cobertura_hi.checked) document.form1.cobertura_hi.value = 'S';
	else document.form1.cobertura_hi.value = 'N';
	if(parent.document.solicitud.cobertura_ot.checked) document.form1.cobertura_ot.value = 'S';
	else document.form1.cobertura_ot.value = 'N';
	document.form1.afiliados.value = parent.document.solicitud.afiliados.value;
	document.form1.forma_pago.value = parent.document.solicitud.forma_pago.value;
	document.form1.cuota_mensual.value = parent.document.solicitud.cuota_mensual.value;
	document.form1.fecha_ini_plan.value = parent.document.solicitud.fecha_ini_plan.value;
	document.form1.estado.value = parent.document.solicitud.estado.value;
	document.form1.tipo_cliente.value = parent.document.solicitud.tipo_cliente.value;
	document.form1.id.value = parent.document.solicitud.id.value;
	document.form1.id_corredor.value = parent.document.solicitud.id_corredor.value;
	document.form1.tipo_plan.value = parent.document.solicitud.tipo_plan.value;
	document.form1.cuota.value = parent.document.solicitud.cuota.value;
	document.form1.en_transicion.value = parent.document.solicitud.en_transicion.value;
	if(parent.document.solicitud.observacion)document.form1.observacion.value = parent.document.solicitud.observacion.value;
	if(parent.document.solicitud.id_motivo)document.form1.id_motivo.value = parent.document.solicitud.id_motivo.value;
	if(valor=='X') parent.document.solicitud.cobertura_mi.checked=false;
	if(parent.document.solicitud.afiliados.value != '') document.form1.plan_monto.value = eval('parent.document.solicitud.plan_monto_'+parent.document.solicitud.afiliados.value).value;
	if(parent.document.solicitud.cobertura_mi.value=='' && parent.document.solicitud.cobertura_cy.value=='' && parent.document.solicitud.cobertura_hi.value=='' && parent.document.solicitud.cobertura_ot.value=='' && cuota=='SF'){
		alert('Indique para quien solicita la cobertura de salud!');
	} else if((valor=='Guardar' || valor == 'Guardar y Aprobar') && parent.document.solicitud.afiliados.value == '' && cuota=='SF') alert('Seleccione Plan!');
	else if((valor == 'Guardar y Aprobar') && !chkFormaPago() && cuota=='SFE' && '<%=fp%>'!='adenda') alert('Introduzca Forma Pago!');
	else if((valor=='Guardar') && parent.document.solicitud.estado.value == 'A' && parent.document.solicitud.fecha_ini_plan.value == '') alert('Introduzca Fecha de Inicio de Plan!');
	else if((valor == 'Guardar y Aprobar') && parent.document.solicitud.fecha_ini_plan.value == '') alert('Introduzca Fecha de Inicio de Plan!');
	else if('<%=fp%>'!='adenda' && (valor=='Guardar' || valor == 'Guardar y Aprobar') && !parent.chkFecha()) x=2;
	else if((<%if(fp.equals("adenda")){%>valor=='Guardar' || <%}%>valor == 'Guardar y Aprobar') && !chkCeroRegisters()) alert('Al menos un Beneficiario debe registrar (Activo)!');
	else if((valor=='Guardar' || valor == 'Guardar y Aprobar') && !chkExcluisiones()) alert('Registre las Excluiones de los beneficiarios!');
	else if((valor=='Guardar' || valor == 'Guardar y Aprobar') && document.form1.id_corredor.value=='') alert('Seleccione Corredor!');
	<%if(fp.equals("adenda")){%>
	else if((valor=='Guardar' || valor == 'Guardar y Aprobar') && !chkCeroMotivos()) alert('Seleccione Motivo de Adenda!');
	else if((valor=='Guardar' || valor == 'Guardar y Aprobar') && !chkParentesco()) alert('Seleccione Parentesco!');
	else if((valor=='Guardar' || valor == 'Guardar y Aprobar') && !chkEdadPlan()) {}
	<%}%>
	else if((valor=='Guardar' || valor == 'Guardar y Aprobar') && !chkResponsable()) {alert('El responsable debe ser registrado como Beneficiario!');}
  else if((valor=='Guardar' || valor == 'Guardar y Aprobar') && !$("#tipo_plan").val() ) {
        alert('Por favor seleccione el tipo de plan!');}
	<%if(!fp.equals("adenda")){%>
	else if((valor=='Guardar' || valor == 'Guardar y Aprobar') && !chkEnTransicion()) {alert('La fecha de inicio no puede ser menor o igual a la actual para contratos en transicion');}
	<%}%>	
	else document.form1.submit();
}

function chkCeroRegisters(){
	var size = document.form1.keySize.value;
	<%if(fp.equals("adenda")){%>
	var con = 0;
	for(i=0;i<size;i++){
		if(eval('document.form1.estado'+i) && eval('document.form1.estado'+i).value == 'I') con++;
	}

	if(con==size) {
		document.form1.action.value = '';
		return false;
	} else return true;

	<%} else {%>
	if(size>0) return true;
	else{
		if(document.form1.action.value!='Guardar' && document.form1.action.value!='Guardar y Aprobar') return true;
		else {
			//alert('Seleccione al menos un Beneficiario!');
			document.form1.action.value = '';
			return false;
		}
	}
	<%}%>
}
function chkFormaPago(){
  var r = getDBData('<%=request.getContextPath()%>','count(*)', 'tbl_pm_cta_tarjeta','estado = \'A\' and id_solicitud=<%=id%>','')||0;
  if(r==0) return false;
	else return true;
}
function chkEdadPlan(){
	var size = document.form1.keySize.value;
	var con = 0, conJ = 0;
	var afiliados = parent.document.solicitud.afiliados.value;
	for(i=0;i<size;i++){
		var edad = eval('document.form1.edad'+i).value;
		var estado = '';
		if(eval('document.form1.estado'+i)) estado = eval('document.form1.estado'+i).value;
		if(afiliados==1){
			if(edad >= 60 && estado == 'A'){
				alert('La edad supera el limite para el PLAN FAMILIAR!')
				 con++;
				 break;
			}
		} else if(afiliados=2){
			if(edad < 60 && estado == 'A'){
				alert('La edad no corresponde al PLAN TERCERA EDAD!')
				 con++;
				 break;
			} else if(edad >= 60 && estado == 'A') conJ++;
		}
	}
	if(con==0)return true;
	else if(conJ>1){
		alert('No puede incluir mas de un beneficiario en un Plan Tercera Edad!');
		return false;
	}
	else return false;
}

function chkParentesco(){
	var size = document.form1.keySize.value;
	var count =0;
	for(i=0;i<size;i++){
		if(eval('document.form1.parentesco'+i).value=='') count++
	}
	if (count>0) return false;
	else return true;
}

function chkCeroMotivos(){
	if(parent.document.solicitud.id_motivo.value!='') return true;
	else return false;
}

function printSol(id, clientId){
	var id_cliente = parent.window.frames['clteFrame'].document.cliente.id_cliente.value;
	var fg='beneficiario';
	if(id_cliente==clientId) fg='responsable';
	abrir_ventana('../planmedico/print_pm_sol_plan.jsp?fg='+fg+'&id='+id+'&clientId='+clientId+'&responsable='+id_cliente);
}

function chkExcluisiones(){
	var size = document.form1.keySize.value;
	var count =0;
	for(i=0;i<size;i++){
		if(eval('document.form1.diagnostico'+i).value=='' || eval('document.form1.medicamento'+i).value=='') count++;
	}
	if (count>0) return false;
	else return true;
}

function chkResponsable(){
	var size = document.form1.keySize.value;
	var responsable = parent.window.frames['clteFrame'].document.cliente.id_cliente.value;
	var count =0;
	for(i=0;i<size;i++){
		if(eval('document.form1.id_cliente'+i).value==responsable) count++;
	}
	if (count==0) return false;
	else return true;
}

function editFechaNac(id, fecha){
	parent.CBMSG.confirm('Al cambiar la fecha de nacimiento se actualizará en el mantenimiento y por ende en el contrato! Desea Continuar?',{btnTxt:'Si,No',cb:function(r){
						  if (r=="Si") parent.showPopWin('../process/pm_run_process.jsp?docId='+id+'&docType=FECHA_NAC&actType=4&fp=adenda&fecha='+fecha,winWidth*.50,_contentHeight*.50,null,null,'');
						}});
	
}
function chkEnTransicion(){
	var fecha_ini_plan = parent.document.solicitud.fecha_ini_plan.value;
	var en_transicion = parent.document.solicitud.en_transicion.value;
	var x = 'N';
	if(en_transicion=='S') x = getDBData('<%=request.getContextPath()%>', '\'S\'', 'dual', 'to_date(\''+fecha_ini_plan+'\', \'dd/mm/yyyy\') <= trunc(sysdate)','')||'N';
	if(x=='S' && en_transicion=='S')return false;
	else return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
<%=fb.hidden("id_cliente", "")%>
<%=fb.hidden("cobertura_mi", "")%>
<%=fb.hidden("cobertura_cy", "")%>
<%=fb.hidden("cobertura_hi", "")%>
<%=fb.hidden("cobertura_ot", "")%>
<%=fb.hidden("afiliados", "")%>
<%=fb.hidden("forma_pago", "")%>
<%=fb.hidden("cuota_mensual", "")%>
<%=fb.hidden("fecha_ini_plan", "")%>
<%=fb.hidden("plan_monto", "")%>
<%=fb.hidden("estado", "")%>
<%=fb.hidden("tipo_cliente", "")%>
<%=fb.hidden("id_corredor", "")%>
<%=fb.hidden("tipo_plan", "")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cuota","")%>
<%=fb.hidden("observacion","")%>
<%=fb.hidden("id_motivo",id_motivo)%>
<%=fb.hidden("en_transicion", "")%>

<table width="100%" align="center">
	<tr>
		<td><table align="center" width="99%" cellpadding="0" cellspacing="1">
				<%
				int colspan = 8;
				%>
				<tr class="TextPanel">
					<td colspan="<%=colspan-2%>"><cellbytelabel>INFORMACION DEL CONYUGUE Y LOS HIJOS INCLUIDOS EN ESTA SOLICITUD</cellbytelabel></td>
					<td colspan="2" align="right"><%=fb.button("addClientes","Agregar",false,(!fp.equals("adenda") && viewMode), "", "", "onClick=\"javascript: doSubmit(this.value);\"")%></td>
				</tr>
				<tr class="TextHeader">
					<td width="27%" align="center"><cellbytelabel>Nombre</cellbytelabel>.</td>
					<td width="16%" align="center"><cellbytelabel>C&eacute;dula/Pasaporte</cellbytelabel></td>
					<td width="15%" align="center"><cellbytelabel>Parentesco</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Fecha Nacimiento</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Edad</cellbytelabel></td>
					<td width="10%" align="center"><cellbytelabel>Sexo</cellbytelabel></td>
					<td width="10%" align="center"><cellbytelabel>Fecha Ini.</cellbytelabel></td>
					<%if(fp.equals("adenda")){%>
					<td align="center"><cellbytelabel>No. Contrato</cellbytelabel></td>
					<%}%>
					<td width="3%" align="center"><%if(fp.equals("adenda")){%>Activo<%}%>&nbsp;</td>
					<td width="3%" align="center">&nbsp;</td>
				</tr>
				<%
				key = "";
				if (htClt.size() != 0) al = CmnMgr.reverseRecords(htClt);
				for (int i=0; i<htClt.size(); i++){
					key = al.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) htClt.get(key);

					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("id_cliente"+i,cdo.getColValue("id_cliente"))%>
				<%=fb.hidden("client_name"+i,cdo.getColValue("client_name"))%>
				<%=fb.hidden("identificacion"+i,cdo.getColValue("identificacion"))%>
				<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
				<%=fb.hidden("edad"+i,cdo.getColValue("edad"))%>
				<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
				
				<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
				
				<%=fb.hidden("id_solicitud"+i,cdo.getColValue("id_solicitud"))%>
				<tr class="<%=color%>">
					<td align="center"><%=cdo.getColValue("client_name")%>
					<%//=fb.decBox("costo_mensual"+i,cdo.getColValue("costo_mensual"),false,false,false,8,null,null,"")%>
					<%=fb.hidden("costo_mensual"+i,cdo.getColValue("costo_mensual"))%>
					</td>
					<td align="center"><%=cdo.getColValue("identificacion")%></td>
					<td align="center">
					<%if(cdo.getColValue("parentesco")!=null && cdo.getColValue("parentesco").equals("0")){%>
					Yo mismo
					<%=fb.hidden("parentesco"+i, cdo.getColValue("parentesco"))%>
					<%} else {%>
					<%=fb.select("parentesco"+i,alPar,cdo.getColValue("parentesco"),false,false,0,"Text10",null,"onChange='javascript:calc();'", "", "S")%>
					<%}%>
					</td>
					<td align="center">
					
					<%if(fp.equals("adenda")){%> 
					<a class="Link05Bold" href="javascript:editFechaNac('<%=cdo.getColValue("id_cliente")%>', '<%=cdo.getColValue("fecha_nacimiento")%>');" style="cursor:pointer">
					<%=cdo.getColValue("fecha_nacimiento")%>
					</a>
					<%} else {%>
					<%=cdo.getColValue("fecha_nacimiento")%>
					<%}%>
					</td>
					<td align="center"><%=cdo.getColValue("edad")%></td>
					<td align="center"><%=(cdo.getColValue("sexo").equals("M")?"Masculino":"Femenino")%></td>
					<td align="center">
					<%
					if(id_motivo!=null && id_motivo.equals("8")){
					String f_ini = "fecha_inicio"+i;
					%>
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="<%=f_ini%>" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_inicio")%>" />
					<jsp:param name="fieldClass" value="Text10" />
					<jsp:param name="buttonClass" value="Text10" />
					<jsp:param name="clearOption" value="true" />
					</jsp:include>
					<%} else {%>
					<%=cdo.getColValue("fecha_inicio")%>
					<%=fb.hidden("fecha_inicio"+i,cdo.getColValue("fecha_inicio"))%>
					<%}%>
					</td>
					<%if(fp.equals("adenda")){%>
					<td align="center"><%=fb.intBox("no_contrato"+i,cdo.getColValue("no_contrato"),false,false,(!UserDet.getUserProfile().contains("0")),2,2)%></td>
					<%}%>
					<td width="3%" align="center">
					<%if(fp.equals("adenda") && !cdo.getColValue("id").equals("0")){%>
					<%=fb.select("estado"+i,"A=Si,I=No", cdo.getColValue("estado"), false, false,0,"text12",null,"onChange=\"javascript:calc();\"")%>
					<%} else {%>
					<%=fb.submit("dele"+i,"X",false,false, "text10", "", "onClick=\"javascript: document.form1.action.value=this.value;\"")%>
					<%}%>
					</td>
					<td width="3%" align="center"><%if(!mode.equals("add")){%>
					<img size = "15" src="../images/printer.png" onClick="javascript:printSol(<%=cdo.getColValue("id_solicitud")%>, <%=cdo.getColValue("id_cliente")%>)" style="cursor:pointer" /><%}%>
					</td>
				</tr>
				<tr class="<%=color%>">
					<td colspan="2">Exclusi&oacute;n Diagnostico:
					<%=fb.textarea("diagnostico"+i,cdo.getColValue("diagnostico"),true,false,viewMode,60,2, 1024)%></td>
					<td colspan="4">Exclusi&oacute;n Medicamento:
					<%=fb.textarea("medicamento"+i,cdo.getColValue("medicamento"),true,false,viewMode,60,2, 1024)%></td>
					<td colspan="3">L&iacute;mite Poliza Anual:
					<%=fb.decBox("limite_anual"+i,cdo.getColValue("limite_anual"),true,false,viewMode,10,null,null,"")%>
					</td>
				</tr>
				<%
				}
				%>
				<%=fb.hidden("keySize",""+htClt.size())%>
			</table></td>
	</tr>
</table>
<%
fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
fb.appendJsValidation("\n\tif (!chkResponsable()){alert('El responsable debe ser registrado como beneficiario!'); error++;}\n");
if(fp.equals("adenda")) fb.appendJsValidation("\n\tif (!chkCeroMotivos()) error++;\n");
fb.appendJsValidation("\n\tif (document.form1.action.value!='Guardar' && document.form1.action.value!='Guardar y Aprobar') return true;\n");
%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{

	String companyId = (String) session.getAttribute("_companyId");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	String uAdmDel = "";
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	SOL = new CommonDataObject();
	if(request.getParameter("id")!=null) SOL.addColValue("id", request.getParameter("id"));
	if(request.getParameter("cobertura_cy")!=null) SOL.addColValue("cobertura_cy", request.getParameter("cobertura_cy"));
	if(request.getParameter("cobertura_hi")!=null) SOL.addColValue("cobertura_hi", request.getParameter("cobertura_hi"));
	if(request.getParameter("cobertura_mi")!=null) SOL.addColValue("cobertura_mi", request.getParameter("cobertura_mi"));
	if(request.getParameter("cobertura_ot")!=null) SOL.addColValue("cobertura_ot", request.getParameter("cobertura_ot"));
	if(request.getParameter("estado")!=null) SOL.addColValue("estado", request.getParameter("estado"));
	//if(request.getParameter("fecha_creacion")!=null) SOL.addColValue("fecha_creacion", request.getParameter("fecha_creacion"));
	if(request.getParameter("fecha_ini_plan")!=null) SOL.addColValue("fecha_ini_plan", request.getParameter("fecha_ini_plan"));
	if(request.getParameter("afiliados")!=null) SOL.addColValue("afiliados", request.getParameter("afiliados"));
	if(request.getParameter("cuota_mensual")!=null) SOL.addColValue("cuota_mensual", request.getParameter("cuota_mensual"));
	if(request.getParameter("forma_pago")!=null) SOL.addColValue("forma_pago", request.getParameter("forma_pago"));
	if(request.getParameter("id_cliente")!=null) SOL.addColValue("id_cliente", request.getParameter("id_cliente"));
	if(request.getParameter("observacion")!=null) SOL.addColValue("observacion", request.getParameter("observacion"));
	if(request.getParameter("id_motivo")!=null) SOL.addColValue("id_motivo", request.getParameter("id_motivo"));
	if(request.getParameter("en_transicion")!=null) SOL.addColValue("en_transicion", request.getParameter("en_transicion"));
	if(request.getParameter("estado")!=null){
		SOL.addColValue("estado", request.getParameter("estado"));
		if(request.getParameter("estado").equals("I")) SOL.addColValue("fecha_inactivo", CmnMgr.getCurrentDate("dd/mm/yyyy"));
	}
	if(fp.equals("adenda") && mode.equals("add")) SOL.addColValue("estado", "P");
	if(request.getParameter("tipo_cliente")!=null) SOL.addColValue("tipo_cliente", request.getParameter("tipo_cliente"));
	if(fp.equals("adenda") && request.getParameter("id")!=null && mode.equals("add")) SOL.addColValue("id_solicitud", request.getParameter("id"));
	SOL.addColValue("id_corredor", request.getParameter("id_corredor"));
	SOL.addColValue("tipo_plan", request.getParameter("tipo_plan"));
	

	htClt.clear();
	vClt.clear();
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		CommonDataObject cd = new CommonDataObject();
		cd.addColValue("id_cliente", request.getParameter("id_cliente"+i));
		cd.addColValue("client_name", request.getParameter("client_name"+i));
		cd.addColValue("identificacion", request.getParameter("identificacion"+i));
		cd.addColValue("fecha_nacimiento", request.getParameter("fecha_nacimiento"+i));
		cd.addColValue("edad", request.getParameter("edad"+i));
		cd.addColValue("sexo", request.getParameter("sexo"+i));
		cd.addColValue("fecha_inicio", request.getParameter("fecha_inicio"+i));
		cd.addColValue("parentesco", request.getParameter("parentesco"+i));	
		cd.addColValue("diagnostico", request.getParameter("diagnostico"+i));	
		cd.addColValue("medicamento", request.getParameter("medicamento"+i));	
		if(request.getParameter("limite_anual"+i)!=null && !request.getParameter("limite_anual"+i).equals("")) cd.addColValue("limite_anual", request.getParameter("limite_anual"+i));	
		else cd.addColValue("limite_anual", "0");
		if(fp.equals("adenda") && request.getParameter("no_contrato"+i)!=null && !request.getParameter("no_contrato"+i).equals("")) cd.addColValue("no_contrato", request.getParameter("no_contrato"+i));	
		cd.addColValue("id", request.getParameter("id"+i));	
		if(fp.equals("adenda") && mode.equals("add") && request.getParameter("action")!=null && (request.getParameter("action").equals("Guardar") || request.getParameter("action").equals("Guardar y Aprobar"))) cd.addColValue("id", "0");	
		if(request.getParameter("cuota")!=null &&  request.getParameter("cuota").equals("SF")) cd.addColValue("costo_mensual", request.getParameter("plan_monto"));	
		else cd.addColValue("costo_mensual", request.getParameter("costo_mensual"+i));	
		if(request.getParameter("estado"+i)!=null) cd.addColValue("estado", request.getParameter("estado"+i));	
		if (mode.equalsIgnoreCase("add")&& request.getParameter("action")!=null && request.getParameter("action").equals("Guardar")){
			cd.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		} else {    
			cd.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		}
		if(fp.equals("adenda") && request.getParameter("id_motivo"+i)!=null && request.getParameter("id_motivo"+i).equals("8") && request.getParameter("fecha_inicio"+i)!=null && !request.getParameter("fecha_inicio"+i).equals("")) cd.addColValue("fecha_inicio", request.getParameter("fecha_inicio"+i));	


		if ((i+1) < 10) key = "00"+(i+1);
		else if ((i+1) < 100) key = "0"+(i+1);
		else key = ""+(i+1);

		if(request.getParameter("dele"+i)==null){
			try {
				htClt.put(key, cd);
				vClt.add(cd.getColValue("id_cliente"));
				al.add(cd);
			} catch (Exception e) {
				System.out.println("Unable to addget item "+key);
			}
		} else {
			uAdmDel = "1";
			vClt.remove(cd.getColValue("id_cliente"));
		}
		System.out.println("..................................del="+request.getParameter("dele"+i)+", i="+i);
	}
System.out.println("action.....................................................="+request.getParameter("action")+", uAdmDel="+uAdmDel);

	if(uAdmDel.equals("1") || clearHT.equals("S")){
		response.sendRedirect("../planmedico/reg_solicitud_det.jsp?mode="+mode+"&id="+id+"&change=1&type=2&fg="+fg+"&fp="+fp);
		return;
	}

	/*if(!uAdmDel.equals("") || clearHT.equals("S")){
		response.sendRedirect("../planmedico/reg_solicitud_det.jsp?mode="+mode+"&id="+id+"&change=1&type=2&fg="+fg+"&fp="+fp);
		return;
	}*/
	if(request.getParameter("action")!=null && request.getParameter("action").equalsIgnoreCase("Agregar")){
		response.sendRedirect("../planmedico/reg_solicitud_det.jsp?mode="+mode+"&id="+id+"&change=1&type=1&fp="+fp+"&fg="+fg);
		return;
	}

	Sol.setAl(al);

	if (mode.equalsIgnoreCase("add")&& request.getParameter("action")!=null && (request.getParameter("action").equals("Guardar") || request.getParameter("action").equals("Guardar y Aprobar"))){
		SOL.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		if(request.getParameter("action").equals("Guardar y Aprobar")) SOL.addColValue("aprobar", "S");
		Sol.setCdo(SOL);
		if(fp.equals("adenda")) SolMgr.addAdenda(Sol);
		else SolMgr.add(Sol);
		id = SolMgr.getPkColValue("id");
		System.out.println(".......................................................................................id="+id);
	} else if (mode.equalsIgnoreCase("edit")&& request.getParameter("action")!=null && (request.getParameter("action").equals("Guardar") || request.getParameter("action").equals("Guardar y Aprobar"))){    
		if(request.getParameter("action").equals("Guardar y Aprobar")) SOL.addColValue("aprobar", "S");
		Sol.setCdo(SOL);
		SOL.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		if(fp.equals("adenda")) SolMgr.updAdenda(Sol);
		else SolMgr.update(Sol);  
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if (SolMgr.getErrCode().equals("1")){%>
			parent.document.solicitud.errCode.value = <%=SolMgr.getErrCode()%>;
			parent.document.solicitud.errMsg.value = '<%=SolMgr.getErrMsg()%>';
			parent.document.solicitud.id.value = '<%=id%>';
			parent.document.solicitud.fp.value = '<%=fp%>';
			parent.document.solicitud.submit();
	<%} else throw new Exception(SolMgr.getErrMsg());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>