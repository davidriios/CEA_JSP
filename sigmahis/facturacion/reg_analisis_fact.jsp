<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.Factura"%>
<%@ page import="issi.admision.Beneficio"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="FacMgr" scope="page" class="issi.facturacion.FacturaMgr" />
<jsp:useBean id="FacDet" scope="session" class="issi.facturacion.Factura" />
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
FacMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String pacienteId = request.getParameter("pacienteId");
String noAdmision = request.getParameter("noAdmision");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
String compania =(String) session.getAttribute("_companyId");
String fromNewView = request.getParameter("from_new_view");
if(fg==null) fg = "AFA";
String fp = request.getParameter("fp");
if(fp==null) fp = "analisis_fact";
if (fromNewView == null) fromNewView = "";

String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
boolean viewMode = false;

if (mode == null) mode = "add";
if (mode.equals("view")) viewMode = true;

if (mode.equalsIgnoreCase("add") && pacienteId != null && !pacienteId.trim().equals("") && noAdmision != null && !noAdmision.trim().equals("") && request.getParameter("verified") == null) {
%>
<jsp:forward page="../facturacion/verify_account.jsp">
<jsp:param name="mode" value="${param.mode}"/>
<jsp:param name="pacienteId" value="${param.pacienteId}"/>
<jsp:param name="noAdmision" value="${param.noAdmision}"/>
<jsp:param name="fg" value="${param.fg}"/>
</jsp:forward>
<%
}

if (request.getMethod().equalsIgnoreCase("GET")){
	if (mode.equalsIgnoreCase("add")){
		if(change==null){
			FacDet = new Factura();
			if (pacienteId == null || pacienteId.trim().equals("") || noAdmision == null || noAdmision.trim().equals(""))
			{
				pacienteId = "0";
				noAdmision = "0";
				
				FacDet.setPaseK("");//descuento jubilado
				FacDet.setPase("");//paciente vip (fidelización)
				FacDet.setEditable("");//para indicar si usa programa de Fidelizacion.
				FacDet.setDistribuido("0");//cant. de cargos de paquete
			}
			else
			{
				sql = "select a.categoria, a.estado, nvl(b.clasificacion,' ') as clasificacion, nvl(get_adm_doblecobertura_msg(a.pac_id,a.secuencia),' ') as doble_msg,nvl(get_fac_desc_jub("+compania+",a.pac_id),'N') as paseK, get_sec_comp_param("+compania+",'ADM_USA_FIDELIZACION') as editable,decode((select vip from vw_adm_paciente where pac_id=a.pac_id),'P','S','N') as pase, (select count(*) from tbl_fac_detalle_transaccion where pac_id = a.pac_id and fac_secuencia = a.secuencia and ref_type = 'PAQ' and ref_id is not null) as distribuido from tbl_adm_admision a, tbl_adm_empresa b where a.pac_id="+pacienteId+" and a.secuencia="+noAdmision+" and a.aseguradora=b.codigo(+)";
				CommonDataObject cdo = SQLMgr.getData(sql);
				FacDet.setCategoriaAdmi(cdo.getColValue("categoria"));
				FacDet.setEstatus(cdo.getColValue("estado"));
				FacDet.setClasifAdmi(cdo.getColValue("clasificacion"));
				FacDet.setComentario(cdo.getColValue("doble_msg"));
				FacDet.setPaseK(cdo.getColValue("paseK"));//descuento jubilado
				FacDet.setPase(cdo.getColValue("pase"));//paciente vip (fidelización)
				FacDet.setEditable(cdo.getColValue("editable"));//para indicar si usa programa de Fidelizacion.
				FacDet.setDistribuido(cdo.getColValue("distribuido"));//cant. de cargos de paquete

				sql = "select a.fecha_nacimiento as fechaNacimiento, a.paciente, a.admision, a.secuencia, a.poliza, nvl(a.certificado,' ') as certificado, nvl(a.convenio_solicitud,' ') as convenioSolicitud, nvl(a.convenio_sol_emp,' ') as convenioSolEmp, a.prioridad, decode(a.plan,null,' ',a.plan) as plan, decode(a.convenio,null,' ',a.convenio) as convenio, a.empresa, decode(a.categoria_admi,null,' ',a.categoria_admi) as categoriaAdmi, decode(a.tipo_admi,null,' ',a.tipo_admi) as tipoAdmi, decode(a.clasif_admi,null,' ',a.clasif_admi) as clasifAdmi, decode(a.tipo_poliza,null,' ',a.tipo_poliza) as tipoPoliza, decode(a.tipo_plan,null,' ',a.tipo_plan) as tipoPlan, nvl(to_char(a.fecha_ini,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaIni, nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaFin, nvl(a.clinica_asume_cargos,' ') as clinicaAsumeCargos, nvl(a.pac_asume_cargos,' ') as pacAsumeCargos, decode(a.dias_perdiem,null,' ',a.dias_perdiem) as diasPerdiem, decode(a.estatus_pac,null,' ',a.estatus_pac) as estatusPac, nvl(a.usuario_creacion,' ') as usuarioCreacion, nvl(a.usuario_modificacion,' ') as usuarioModificacion, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaCreacion, nvl(to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaModificacion, nvl(a.estado,' ') as estado, nvl(a.jubilado,' ') as jubilado, decode(a.tipo_factura,null,' ',a.tipo_factura) as tipoFactura, nvl((select cod_reg from tbl_adm_clasif_x_plan_conv where empresa = a.empresa and convenio = a.convenio and plan = a.plan and categoria_admi = a.categoria_admi and tipo_admi = a.tipo_admi and clasif_admi = a.clasif_admi and paquete = 'S'),-1) as pase, nvl(a.pase_k,' ') as paseK, decode(a.num_aprobacion,null,' ',a.num_aprobacion) as numAprobacion, a.pac_id as pacId, b.nombre empresaNombre, c.nombre tipoPolizaDesc, d.nombre tipoPlanDesc, e.descripcion categoriaAdmiDesc, f.descripcion tipoAdmiDesc, g.descripcion clasifAdmiDesc, h.nombre convenioDesc, i.nombre planDesc from tbl_adm_beneficios_x_admision a, tbl_adm_empresa b, tbl_adm_tipo_poliza c, tbl_adm_tipo_plan d, tbl_adm_categoria_admision e, tbl_adm_tipo_admision_cia f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_convenio h, (select a.plan, a.clasif_admi, a.tipo_admi, a.categoria_admi, b.tipo_plan, b.tipo_poliza, b.empresa, b.convenio, b.nombre from tbl_adm_clasif_x_plan_conv a, tbl_adm_plan_convenio b where a.empresa = b.empresa and a.convenio = b.convenio and a.plan = b.secuencia) i where a.pac_id = "+pacienteId+" and a.admision="+noAdmision+" and a.estado='A' and a.empresa = b.codigo and a.tipo_poliza = c.codigo and a.tipo_poliza = d.poliza and a.tipo_plan = d.tipo_plan(+) and a.categoria_admi = e.codigo and a.categoria_admi = f.categoria and a.tipo_admi = f.codigo and a.categoria_admi = g.categoria and a.tipo_admi = g.tipo and a.clasif_admi = g.codigo and a.empresa = h.empresa and a.convenio = h.secuencia and a.plan = i.plan and a.clasif_admi = i.clasif_admi and a.tipo_admi = i.tipo_admi and a.categoria_admi = i.categoria_admi and a.tipo_plan = i.tipo_plan and a.tipo_poliza = i.tipo_poliza and a.empresa = i.empresa and a.convenio = i.convenio";
				System.out.println("sql=\n"+sql);
				al = sbb.getBeanList(ConMgr.getConnection(),sql,Beneficio.class);
				FacDet.getBeneficios().clear();
				FacDet.setBeneficios(al);
			}
			session.setAttribute("FacDet",FacDet);

			FacDet.setPacId(pacienteId);
			FacDet.setAdmiSecuencia(noAdmision);
			FacDet.setCodigo("0");
		}
	} else {
		if (pacienteId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");
	}

	boolean showDetPrint = false;
	boolean chkEKGTrat = false;
	CommonDataObject p = SQLMgr.getData("select nvl(get_sec_comp_param(-1,'FAC_PROFORMA_SHOW_DET'),'N') as show_proforma_det, nvl(get_sec_comp_param(-1,'FAC_CHK_EXP_EKG_TRAT'),'N') as chk_ekg_trat from dual");
	if (p == null) {

		p = new CommonDataObject();
		p.addColValue("show_proforma_det","N");
		p.addColValue("chk_ekg_trat","N");

	}
	showDetPrint = (p.getColValue("show_proforma_det").equalsIgnoreCase("Y") || p.getColValue("show_proforma_det").equalsIgnoreCase("S"));
	chkEKGTrat = (p.getColValue("chk_ekg_trat").equalsIgnoreCase("Y") || p.getColValue("chk_ekg_trat").equalsIgnoreCase("S"));
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script>
document.title = 'Facturación - '+document.title;


function setBAction(fName,actionValue){
	document.form0.baction.value = actionValue;
	doSubmit();
}

function showMedicoList(){abrir_ventana1('../common/search_medico.jsp?fp=cargo_dev');}
function doValidation(){if('<%=mode%>'=='view'){var empresa = '';if(document.form0.empresa0) empresa = document.form0.empresa0.value;var facturar_a = getDBData('<%=request.getContextPath()%>','facturar_a','tbl_fac_factura','pac_id=<%=pacienteId%> and admi_secuencia=<%=noAdmision%>','');if(facturar_a != null){<% if (showDetPrint) { %>abrir_ventana1('../facturacion/print_dfact.jsp?preprinted&pacId=<%=pacienteId%>&admision=<%=noAdmision%>&empresa='+empresa);<% } else { %>if(confirm('¿Desea imprimir Proforma en papel PRE-IMPRESO?'))abrir_ventana1('../facturacion/print_fact.jsp?pacId=<%=pacienteId%>&admision=<%=noAdmision%>&empresa='+empresa);else abrir_ventana1('../facturacion/print_factura.jsp?pacId=<%=pacienteId%>&admision=<%=noAdmision%>&empresa='+empresa);<% } %>}}document.form0.facturar.disabled=true;document.form0.imprimirDGIE.disabled=('<%=mode%>'=='add');if(document.form0.imprimirDGIP)document.form0.imprimirDGIP.disabled=('<%=mode%>'=='add');}
function DBxPF(bol){if(bol){document.form0.monto_c1.disabled = false;document.form0.monto_c2.disabled = false;} else {document.form0.monto_c1.value = '';document.form0.monto_c2.value = '';document.form0.monto_c1.disabled = true;document.form0.monto_c2.disabled = true;}}
function canSelGNC(bol){if(bol){if(document.form0.gastos) document.form0.gastos.disabled = false;}else{ if(document.form0.gastos)document.form0.gastos.disabled = true;}}
function selGNC(){abrir_ventana1('../common/sel_gastos_no_cubiertos.jsp?fp=analisis_fact');}
function doSubmit(){
	document.form0.nombrePaciente.value     = document.paciente.nombrePaciente.value;
	document.form0.fechaNacimiento.value    = document.paciente.fechaNacimiento.value;
	document.form0.codigoPaciente.value     = document.paciente.codigoPaciente.value;
	document.form0.pacienteId.value         = document.paciente.pacienteId.value;
	document.form0.provincia.value          = document.paciente.provincia.value;
	document.form0.sigla.value              = document.paciente.sigla.value;
	document.form0.tomo.value               = document.paciente.tomo.value;
	document.form0.asiento.value            = document.paciente.asiento.value;
	document.form0.dCedula.value            = document.paciente.dCedula.value;
	document.form0.pasaporte.value          = document.paciente.pasaporte.value;
	document.form0.jubilado.value           = document.paciente.jubilado.value;
	document.form0.numFactura.value         = document.paciente.numFactura.value;
	document.form0.categoria.value          = document.paciente.categoria.value;
	document.form0.categoriaDesc.value      = document.paciente.categoriaDesc.value;
	document.form0.fechaIngreso.value       = document.paciente.fechaIngreso.value;
	document.form0.mesCta.value             = document.paciente.mesCta.value;
	document.form0.admSecuencia.value       = document.paciente.admSecuencia.value;
	document.form0.estado.value             = document.paciente.estado.value;
	document.form0.desc_estado.value        = document.paciente.desc_estado.value;
	document.form0.empresa.value            = document.paciente.empresa.value;
	document.form0.clasificacion.value      = document.paciente.clasificacion.value;
	document.form0.embarazada.value         = document.paciente.embarazada.value;
	if (!parent.pacienteValidation()/* || !parent.form0Validation()*/){
		//return false;
	} else{
		//return true;
		if(document.form0.baction.value=='Analizar'){
			//beforeAnalizar();
			if(document.form0.tipo_factura.value==0){

				var pacId=document.form0.pacienteId.value;
				var noAdmision=document.form0.admSecuencia.value;
				var esJubilado=(document.form0.esJubilado.checked)?'S':'N';

				var appendParam='';
				var c=splitCols(getDBData('<%=request.getContextPath()%>','to_char(max(fecha_hora_creacion),\'dd/mm/yyyy hh24:mi:ss\') as last_charge, nvl(sum(decode(tipo_transaccion,\'D\',-cantidad,cantidad) * (monto + nvl(recargo,0))),0) as monto_cargado','tbl_fac_detalle_transaccion','compania = <%=(String) session.getAttribute("_companyId")%> and pac_id = '+pacId+' and fac_secuencia = '+noAdmision,''));
				var lastCharge=c[0];
				var totalCargado=c[1];
				if(totalCargado==0){CBMSG.warning('El paciente no tiene Cargos Registrados.!');return false;}
				else{
					c=splitCols(getDBData('<%=request.getContextPath()%>','count(*) as recs_analisis, max(fecha_creacion) as last_analisis, case when max(fecha_creacion) > to_date(\''+lastCharge+'\',\'dd/mm/yyyy hh24:mi:ss\') then 0 else 1 end analisis_required','tbl_fac_estado_cargos','compania = <%=(String) session.getAttribute("_companyId")%> and pac_id = '+pacId+' and admi_secuencia = '+noAdmision,''));
					console.log('tiene analisis = '+c[0]+' analisis requerido = '+c[2]);
					if(c[0]!=0&&c[2]==0){if(confirm('La cuenta tiene un analisis Realizado, ¿Desea continuar con el análisis registrado?'))appendParam='&mode=edit';}
				}
				abrir_ventana1('../facturacion/reg_facturacion_manual.jsp?pacId='+pacId+'&noAdmision='+noAdmision+'&esJubilado='+esJubilado+appendParam);

				document.form0.facturar.disabled=false;
				if(document.form0.imprimirDGIE)document.form0.imprimirDGIE.disabled=false;
				if(document.form0.imprimirDGIP)document.form0.imprimirDGIP.disabled=false;
				return false;
			}
		} else if(document.form0.baction.value=='Facturar'){
			//if(confirm('Desea analizar antes de Facturar?')) document.form0.alerta_analisis.value = 'S';
			//if(confirm('Imprimir Análisis de la Admisión?')) document.form0.alerta_imprimir.value = 'S';
			var factura=prompt('Si es una factura PRE-IMPRESA, introduzca la secuencia de la factura:','');
			document.form0.codigo.value=(factura==null||factura.trim()=='')?null:factura;
			document.form0.facturar.disabled=true; //form0BlockButtons(true);
		} else if(document.form0.baction.value != 'Guardar')form0BlockButtons(false);
		document.form0.submit();
	}

}

function beforeAnalizar(){var clasif_admi       = '<%=FacDet.getClasifAdmi()%>';var categoria         = '<%=FacDet.getCategoriaAdmi()%>';var size              = <%=FacDet.getBeneficios().size()%>;var proc_facturacion  = document.form0.proc_facturacion.value;
	var tipo_factura      = document.form0.tipo_factura0.value;
	if(proc_facturacion == 'C' && tipo_factura == '6'){for(i=0;i<size;i++){var tipo_admi = eval('document.form0.tipo_admi'+i).value;var tipo_plan   = eval('document.form0.tipo_plan'+i).value;	var empresa   = eval('document.form0.empresa'+i).value;	var count1    = eval('document.form0.count1_'+i).value;var count2    = eval('document.form0.count2_'+i).value;			if(tipo_plan == '2' && empresa == '21' && tipo_admi != '2'){if((count1=='0' || count1 =='1') && count2 == '1'){if(confirm('Se ha detectado en la cuenta del paciente, el centro SALON DE OPERACIONES. ¿Desea aplicar el COPAGO correspondiente?')) document.form0.copago_sop_pamd.value = 'S';}}}}}
function printCargos(){var pac_id=document.form0.pacienteId.value;var admi_secuencia=document.form0.admSecuencia.value;if(pac_id.trim()==''||pac_id=='0'||admi_secuencia.trim()=='')CBMSG.warning('Seleccione paciente!');else{if(checkCargos())abrir_ventana1('../facturacion/print_cargo_dev.jsp?noSecuencia='+admi_secuencia+'&pacId='+pac_id);}}
function printAnalisis(){var pac_id=document.form0.pacienteId.value;var admi_secuencia=document.form0.admSecuencia.value;if(pac_id.trim()==''||admi_secuencia.trim()=='')CBMSG.warning('Seleccione paciente!');else{abrir_ventana1('../facturacion/print_cargo_dev_resumen2.jsp?noSecuencia='+admi_secuencia+'&pacId='+pac_id/*+'&tf='+tf*/);abrir_ventana1('../facturacion/print_pagos_x_admision.jsp?noSecuencia='+admi_secuencia+'&pacId='+pac_id/*+'&tf='+tf*/);}}
function printFactura(){abrir_ventana1('../facturacion/print_fact.jsp?pacId=<%=pacienteId%>&admision=<%=noAdmision%>');}
function isValid(){var msg='';var pacId=document.form0.pacienteId.value;var noAdmision=document.form0.admSecuencia.value;var procFacturacion=document.form0.proc_facturacion.value;	var tipoFactura=parseInt(document.form0.tipo_factura0.value,10);if(parseFloat(getDBData('<%=request.getContextPath()%>','nvl(sum(decode(tipo_transaccion,\'C\',cantidad * (monto + nvl(recargo,0)),\'H\',cantidad * (monto + nvl(recargo,0)),\'D\',-1 * cantidad * (monto + nvl(recargo,0)))),0)','tbl_fac_detalle_transaccion','fac_secuencia='+noAdmision+' and pac_id='+pacId+'',''))<=0)msg+='\n- La admisión NO tiene cargos registrados.  No se puede iniciar el análisis.  VERIFIQUE';if(!hasDBData('<%=request.getContextPath()%>','tbl_adm_admision','secuencia='+noAdmision+' and pac_id='+pacId+'',''))msg+='\n- No existe Admisión.';if(tipoFactura==3){var nBenefits = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_beneficios_x_admision','admision='+noAdmision+' and pac_id='+pacId+' and estado=\'A\'',''),10);	if(nBenefits<2)msg+='\n- Se requieren dos (2) beneficios ACTIVOS para ejecutar el análisis.  VERIFIQUE.  Admisión tipo Asegurado y Jubilado.';else if(nBenefits>2)msg+='\n- Se ha encontrado más de un beneficio ACTIVO con prioridad uno (1). Elimine uno de los beneficios o corrija las PRIORIDADES.';else{var nBenefitsPriority1 = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_beneficios_x_admision','admision='+noAdmision+' and pac_id='+pacId+' and estado=\'A\' and empresa!=95 and prioridad=1',''),10);var nBenefitsPriority2 = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_beneficios_x_admision','admision='+noAdmision+' and pac_id='+pacId+' and estado=\'A\' and empresa=95 and prioridad=2',''),10);
			if(nBenefitsPriority1>0&&nBenefitsPriority2>0)null;else if(nBenefitsPriority1>0&&nBenefitsPriority2==0)msg+='\n- Posiblemente el 2° beneficio asignado sea una compañía incorrecta o el número de prioridad no sea el correcto. VERIFIQUE.';else if(nBenefitsPriority1==0&&nBenefitsPriority2>0)msg+='\n- Posiblemente el 1er. beneficio asignado sea una compañía incorrecta o el número de prioridad no sea el correcto. VERIFIQUE.';else if(nBenefitsPriority1==0&&nBenefitsPriority2==0)msg+='\n- Los beneficios de la admisión están mal asignados. VERIFIQUE.';}}else{	var nBenefits = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_beneficios_x_admision','admision='+noAdmision+' and pac_id='+pacId+' and estado=\'A\' and prioridad=1',''),10);if(nBenefits==0)msg+='\n- No existe Beneficio.';	else if(nBenefits>1)msg+='\n- Beneficio con prioridad 1 duplicado.';}	var admDetails=getDBData('<%=request.getContextPath()%>','b.categoria_admi||\'|\'||a.estado||\'|\'||b.tipo_plan||\'|\'||b.empresa||\'|\'||nvl(c.clasificacion,\'N\')||\'|\'||b.convenio||\'|\'||b.plan||\'|\'||b.tipo_admi||\'|\'||b.clasif_admi','tbl_adm_admision a, tbl_adm_beneficios_x_admision b, tbl_adm_empresa c','a.secuencia='+noAdmision+' and a.pac_id='+pacId+' and b.prioridad=1 and b.estado=\'A\' and a.secuencia=b.admision and a.pac_id=b.pac_id and b.empresa=c.codigo','');var admDetail=admDetails.split('|');var categoria=parseInt(admDetail[0],10);var estado=admDetail[1];var tipoPlan=parseInt(admDetail[2],10);var empresa=parseInt(admDetail[3],10);var clasificacion=admDetail[4];var convenio=parseInt(admDetail[5],10);var plan=parseInt(admDetail[6],10);var tipoAdmi=parseInt(admDetail[7],10);var clasifAdmi=parseInt(admDetail[8],10);if(categoria==2&&(estado=='A'||estado=='E'))null;else if(categoria==1&&estado=='E')null;else msg+='\n- Admisión Ambulatoria debe estar ACTIVA o admisión Hospitalizada debe estar en ESPERA.';if(!hasDBData('<%=request.getContextPath()%>','tbl_adm_aplicacion_beneficio','empresa='+empresa+' and convenio='+convenio+' and plan='+plan+' and categoria_admision='+categoria+' and tipo_admision='+tipoAdmi+' and clasif_admision='+clasifAdmi,''))msg+='\n- No existe Definición de Cálculos';
	if(procFacturacion=='C')//convenio, doble cobertura o paquetes
	{
		if(tipoPlan==1&&(tipoFactura==1||tipoFactura==4))//Proceso para planes Perdiem.
		{
			if(categoria==1){if(hasDBData('<%=request.getContextPath()%>','tbl_adm_beneficios_x_admision','admision='+noAdmision+' and pac_id='+pacId+' and nvl(estado,\'A\')=\'A\' and (fecha_ini is null or fecha_fin is null or dias_perdiem is null)',''))msg+='\n- Debe completar los parámetros de fecha inicial, fecha final o dias de perdiem en los planes asignados...,VERIFIQUE';}}
//		else if(((tipoPlan==1||tipoPlan==2)&&tipoFactura==5)/*2 TRADICIONAL -- Proceso para PAQUETES DE HEMODIALISIS DE H.N.A.*/||((tipoPlan==2||tipoPlan==3)&&(tipoFactura==2||tipoFactura==8)))/*Proceso para planes Tradicional o doble cobertura.*/null;
//		else if(aplicacionPlan=='C')null;
//		else if(tipoPlan==2&&tipoFactura==3)/*Proceso para Asegurados y Jubilados TRADICIONAL.*/null;
//		else if((tipoPlan==1&&tipoFactura==3)/*Proceso para Asegurados y Jubilados PERDIEM.*/||(tipoPlan==2&&tipoFactura==4))/*Paquetes Especiales de C.S.S.*/null;
//		else if(tipoPlan==2&&tipoFactura==6)/*Proceso para Facturas del P.A.M.D.*/null;
		else if(tipoFactura==9)//Paquete Obstétrico.
		{if(hasDBData('<%=request.getContextPath()%>','tbl_adm_admision','admi_madre='+noAdmision+' and pac_id_madre='+pacId+' and estado=\'A\'','')){if(hasDBData('<%=request.getContextPath()%>','tbl_fac_detalle_transaccion','compania=<%=(String) session.getAttribute("_companyId")%> and fac_fecha_nacimiento||\'|\'||fac_codigo_paciente||\'|\'||fac_secuencia=(select fecha_nacimiento||\'|\'||codigo_paciente||\'|\'||secuencia from tbl_adm_admision where secuencia='+noAdmision+' and pac_id='+pacId+')',''))msg+='\n- La admisión del Neonato aún tiene cargos por transferir a la admisión de la madre...,VERIFIQUE';}else msg+='\n- No se puede ubicar la admisión del neonato para verificar los cargos...,VERIFIQUE';}else msg+='\n- No ha seleccionado el tipo de cuenta bajo el cual desea facturar la admisión...,VERIFIQUE';}if(msg!=''){CBMSG.warning('La Admisión no se ha podido analizar por las siguientes razones:'+msg);	return false;}else return true;}
function listaEnvio(){abrir_ventana1('../facturacion/envio_lista.jsp');}
function viewBenef(k){var empresa=eval('document.form0.empresa'+k).value;var convenio=eval('document.form0.convenio'+k).value;var tipoPoliza=eval('document.form0.tipoPoliza'+k).value;var tipoPlan=eval('document.form0.tipo_plan'+k).value;var plan=eval('document.form0.plan'+k).value;abrir_ventana1('../convenio/convenio_config.jsp?mode=view&tab=1&empresa='+empresa+'&secuencia='+convenio+'&tipoPoliza='+tipoPoliza+'&tipoPlan='+tipoPlan+'&planNo='+plan);}
function chkAnalisis(formName, valor){var admision = document.paciente.admSecuencia.value;var factura = getDBData('<%=request.getContextPath()%>','nvl(count(codigo),0)','tbl_fac_factura','pac_id=<%=pacienteId%> and admi_secuencia='+admision+' and estatus <> \'A\'','');if (factura !='0'){CBMSG.warning('La cuenta ya fue facturada. Verifique !!');return false;}else{if(hasDBData('<%=request.getContextPath()%>','tbl_fac_estado_cargos','pac_id=<%=pacienteId%> and admi_secuencia='+admision,'')){CBMSG.warning('La cuenta tiene un analisis Realizado, Verifique que el mismo tenga todos los cargos!!');if(confirm('Está Seguro que desea Facturar la Cuenta!!!'))setBAction(formName, valor); }else CBMSG.warning('Debe realizar el análisis antes de Facturar!');}}
function checkCargos(){	var pacId=document.form0.pacienteId.value;var noAdmision=document.form0.admSecuencia.value;	var cargos = getDBData('<%=request.getContextPath()%>','NVL(SUM(DECODE(tipo_transaccion,\'C\',cantidad * (monto + NVL(recargo,0)),\'H\',cantidad * (monto + NVL(recargo,0)),\'D\',-1 * cantidad * (monto + NVL(recargo,0)))),0)  v_total ','tbl_fac_detalle_transaccion','compania =<%=(String) session.getAttribute("_companyId")%> and pac_id = '+pacId+' AND fac_secuencia = '+noAdmision,'');if(cargos ==0){CBMSG.warning('El paciente no tiene Cargos Registrados.!');return false;}else return true;}

function printDGI(facturar_a){
	var pac_id = document.form0.pacienteId.value;var admi_secuencia = document.form0.admSecuencia.value;if(pac_id == '' ||pac_id == '0'|| admi_secuencia == '') CBMSG.warning('Seleccione paciente!');else{
	var x = splitCols(getDBData('<%=request.getContextPath()%>', 'a.id, a.codigo, a.tipo_docto, a.ruc_cedula, nvl(a.impreso, \'N\') impreso', 'tbl_fac_dgi_documents a', ' exists (select null from tbl_fac_factura f where f.codigo = a.codigo and a.tipo_docto = \'FACT\' and f.pac_id = '+pac_id+' and f.admi_secuencia = '+admi_secuencia+' and f.facturar_a = \''+facturar_a+'\' and f.estatus != \'A\')'));
	if(x=='' || x==null) CBMSG.warning('No existe Factura para '+(facturar_a=='P'?'Paciente':'Empresa'));
	else if(x[4]=='Y'){
		if(confirm('Desea Reimprimir Factura de '+(facturar_a=='P'?'Paciente':'Empresa'))){
			showPopWin('../common/run_process.jsp?fp=reg_analisis_fact&actType=5&docType=DGI&docId='+x[0]+'&docNo='+x[1]+'&tipo='+x[2]+'&ruc='+x[3],winWidth*.75,winHeight*.80,null,null,'');
		}
	} else if(x[4]=='N'){
		showPopWin('../common/run_process.jsp?fp=reg_analisis_fact&actType=2&docType=DGI&docId='+x[0]+'&docNo='+x[1]+'&tipo='+x[2]+'&ruc='+x[3],winWidth*.75,winHeight*.80,null,null,'');
	}
}
}
var xHeight=0;
function doAction(){
xHeight=objHeight('_tblMain');resizeFrame();doValidation();
<% if (chkEKGTrat && pacienteId != null && !pacienteId.trim().equals("") && noAdmision != null && !noAdmision.trim().equals("")) { %>
var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','tipo, recs', '(select 0 as tipo, count(*) as recs from tbl_sal_resultado_ekg where pac_id = <%=pacienteId%> and secuencia = <%=noAdmision%> union all select 1 as tipo, count(*) as recs from tbl_sal_detalle_orden_med where pac_id = <%=pacienteId%> and secuencia = <%=noAdmision%> and tipo_orden = 4)'));
console.log(r[0][1]+' '+r[1][1]);
if((r[0][0]=='0'&&r[0][1]!='0')||(r[1][0]=='1'&&r[1][1]!='0'))CBMSG.warning('Estimado usuario, la cuenta que está por facturar tiene una O/M de EKG o Tratamiento en su expediente. Favor asegurarse de que todos los cargos estén registrados.');
<% } %>
}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function setCargosPaquete(paquete){showPopWin('../process/fac_cargos_paq.jsp?compania=<%=compania%>&pacId=<%=pacienteId%>&admision=<%=noAdmision%>&paquete='+paquete,winWidth*.75,winHeight*.65,null,null,'');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ANALISIS Y FACTURACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr<%=(FacDet.getComentario().trim().equals(""))?" class=\"TextRow02\"":""%>>
					<td align="center">&nbsp;<label id="lblMsg" class="alert1"><%=FacDet.getComentario()%></label><script language="javascript">blinkId('lblMsg','red','white');</script></td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Datos del Paciente</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0">+</label><label id="minus0" style="display:none">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0" style="display:none">
					<td>
						<jsp:include page="../common/paciente.jsp" flush="true">
							<jsp:param name="pacienteId" value="<%=pacienteId%>"></jsp:param>
							<jsp:param name="fp" value="<%=fp%>"></jsp:param>
							<jsp:param name="tr" value="<%=fg%>"></jsp:param>
							<jsp:param name="mode" value="<%=mode%>"></jsp:param>
							<jsp:param name="admisionNo" value="<%=FacDet.getAdmiSecuencia()%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if((document."+fb.getFormName()+".baction.value=='Analizar'||(document."+fb.getFormName()+".baction.value=='Facturar'&&document."+fb.getFormName()+".alerta_analisis.value=='S'))/*&&!isValid()*/)error++;");%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("pacienteId",pacienteId)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>

<%=fb.hidden("nombrePaciente","")%>
<%=fb.hidden("fechaNacimiento","")%>
<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("provincia","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("dCedula","")%>
<%=fb.hidden("pasaporte","")%>
<%=fb.hidden("jubilado","")%>
<%=fb.hidden("numFactura","")%>
<%=fb.hidden("categoria",FacDet.getCategoriaAdmi())%>
<%=fb.hidden("categoriaDesc","")%>
<%=fb.hidden("fechaIngreso","")%>
<%=fb.hidden("mesCta","")%>
<%=fb.hidden("admSecuencia",FacDet.getAdmiSecuencia())%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("desc_estado","")%>
<%=fb.hidden("empresa","")%>
<%=fb.hidden("clasificacion",FacDet.getClasifAdmi())%>
<%=fb.hidden("embarazada","")%>
<%=fb.hidden("copago_sop_pamd","N")%>
<%=fb.hidden("alerta_analisis","N")%>
<%=fb.hidden("alerta_imprimir","N")%>
<%=fb.hidden("benSize",""+FacDet.getBeneficios().size())%>
<%=fb.hidden("codigo","")%>
<%=fb.hidden("from_new_view", fromNewView)%>
<!--
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">Procesar Admisi&oacute;n de acuerdo a</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td colspan="3" align="left">
							<%
							if(FacDet.getProFacturacion()==null || FacDet.getProFacturacion().equals("")) FacDet.setProFacturacion("C");
							%>
							<%=fb.radio("proc_facturacion","C", (FacDet.getProFacturacion().equals("C")?true:false), false, viewMode, "", "", "onClick=\"javascript:DBxPF(false);\"")%>Par&aacute;metros del Convenio&nbsp;
							<%=fb.radio("proc_facturacion","Q", (FacDet.getProFacturacion().equals("Q")?true:false), false, viewMode, "", "", "onClick=\"javascript:DBxPF(true);\"")%>Doble Cobertura por par&aacute;metros fijos&nbsp;
							<%=fb.radio("proc_facturacion","P", (FacDet.getProFacturacion().equals("P")?true:false), false, viewMode, "", "", "onClick=\"javascript:DBxPF(false);\"")%>Paquetes Particulares
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right" width="30%">Primera Compa&ntilde;&iacute;a</td>
							<td width="8%"><%=fb.decBox("monto_c1","",false,true,false,10)%></td>
							<td width="62%"><%=fb.select("tipo_monto_c1","P=%,M=$","")%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right">Segunda Compa&ntilde;&iacute;a</td>
							<td><%=fb.decBox("monto_c2","",false,true,false,10)%></td>
							<td><%=fb.select("tipo_monto_c2","P=%,M=$","")%></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">Gastos no cubiertos o no elegibles</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel2">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td colspan="3" align="left">
							<%
							if(FacDet.getGastoNoCubiertos()==null || FacDet.getGastoNoCubiertos().equals("")) FacDet.setGastoNoCubiertos("N");
							%>
							<%=fb.radio("gastos_no_cubiertos","N", (FacDet.getGastoNoCubiertos().equals("N")?true:false), viewMode, false, "", "", "onClick=\"javascript:canSelGNC(false);\"")%>No utilizar listados
							<%=fb.radio("gastos_no_cubiertos","A", (FacDet.getGastoNoCubiertos().equals("A")?true:false), viewMode, false, "", "", "onClick=\"javascript:canSelGNC(false);\"")%>Gastos no cubiertos definidos en el convenio
							<%=fb.radio("gastos_no_cubiertos","B", (FacDet.getGastoNoCubiertos().equals("B")?true:false), viewMode, false, "", "", "onClick=\"javascript:canSelGNC(true);\"")%>Seleccionar gastos no cubiertos manualmente
							<%=fb.button("gastos","Seleccionar",true,viewMode,null,null,"onClick=\"javascript:selGNC()\"")%>
							</td>
						</tr>
						</table>
					</td>
				</tr>
-->
				<tr>
					<td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="2">Beneficios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel3">
					<td class="TextRow01">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader">
							<td width="10%" align="center"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
							<td width="40%" align="center"><cellbytelabel id="4">Nombre Compa&ntilde;&iacute;a</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="5">Prioridad</cellbytelabel></td>
							<td width="38%" align="center"><cellbytelabel id="6">Convenio</cellbytelabel></td>
							<td width="2%" align="center">&nbsp;</td>
						</tr>
						<% if (request.getParameter("pacienteId") != null && request.getParameter("noAdmision") != null && FacDet.getBeneficios().size() == 0) { %><tr class="TextRow01">
							<td align="center" colspan="5"><label class="RedTextBold">EL PROCESO DE ANALISIS Y FACTURACION REQUIERE DE AL MENOS UN BENEFICIO</label></td>
						</tr><% } %>
<%
String paquete = "-1";
for (int i=0; i<FacDet.getBeneficios().size(); i++)
{
	Beneficio ben = (Beneficio) FacDet.getBeneficios().get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (ben.getPrioridad().equals("1")) paquete = ben.getPase();
%>
						<%=fb.hidden("empresa"+i,ben.getEmpresa())%>
						<%=fb.hidden("convenio"+i,ben.getConvenio())%>
						<%=fb.hidden("tipoPoliza"+i,ben.getTipoPoliza())%>
						<%=fb.hidden("plan"+i,ben.getPlan())%>
						<%=fb.hidden("sec_beneficio"+i,ben.getSecuencia())%>
						<%=fb.hidden("tipo_admi"+i,ben.getTipoAdmi())%>
						<%=fb.hidden("tipo_plan"+i,ben.getTipoPlan())%>
						<%=fb.hidden("count1_"+i,ben.getCount1())%>
						<%=fb.hidden("count2_"+i,ben.getCount2())%>
						<tr class="TextPanel01">
							<td align="center"><%=ben.getEmpresa()%></td>
							<td><%=ben.getEmpresaNombre()%></td>
							<td align="center"><%=ben.getPrioridad()%></td>
							<td><a href="javascript:viewBenef(<%=i%>)" class="Link04">[<%=ben.getConvenio()%>] <%=ben.getConvenioDesc()%></a></td>
							<td align="center" onClick="javascript:showHide(3<%=i%>)" style="text-decoration:none; cursor:pointer" >[<font face="Courier New, Courier, mono"><label id="plus3<%=i%>" style="display:none">+</label><label id="minus3<%=i%>">-</label></font>]</td>
						</tr>
						<tr id="panel3<%=i%>">
							<td colspan="5">
								<table width="100%" cellpadding="1" cellspacing="1">
								<tr class="TextRow03">
									<td width="20%" align="right"><cellbytelabel id="7">Tipo de P&oacute;liza</cellbytelabel></td>
									<td width="10%" align="center"><%=ben.getTipoPoliza()%></td>
									<td width="20%"><%=ben.getTipoPolizaDesc()%></td>
									<td width="20%" align="right"><cellbytelabel id="8">Tipo de Plan</cellbytelabel></td>
									<td width="10%" align="center"><%=ben.getTipoPlan()%></td>
									<td width="20%"><%=ben.getTipoPlanDesc()%></td>
								</tr>
								<tr class="TextRow04">
									<td width="20%" align="right"><cellbytelabel id="9">Plan</cellbytelabel></td>
									<td width="10%" align="center"><%=ben.getPlan()%></td>
									<td width="20%" align="left"><%=ben.getPlanDesc()%></td>
									<td width="20%" align="right"><cellbytelabel id="10">Categor&iacute;a</cellbytelabel></td>
									<td width="10%" align="center"><%=ben.getCategoriaAdmi()%></td>
									<td width="20%" align="left"><%=ben.getCategoriaAdmiDesc()%></td>
								</tr>
								<tr class="TextRow03">
									<td width="20%" align="right"><cellbytelabel id="11">Tipo</cellbytelabel></td>
									<td width="10%" align="center"><%=ben.getTipoAdmi()%></td>
									<td width="20%" align="left"><%=ben.getTipoAdmiDesc()%></td>
									<td width="20%" align="right"><cellbytelabel id="12">Clasificaci&oacute;n</cellbytelabel></td>
									<td width="10%" align="center"><%=ben.getClasifAdmi()%></td>
									<td width="20%" align="left"><%=ben.getClasifAdmiDesc()%></td>
								</tr>
								<tr class="TextRow04">
									<td width="20%" align="right"><cellbytelabel id="13">P&oacute;liza</cellbytelabel></td>
									<td width="10%" align="left" colspan="2"><%=ben.getPoliza()%></td>
									<!--<td width="20%" align="right">&nbsp;</td>-->
									<td width="20%" align="right"><cellbytelabel id="14">Certificado</cellbytelabel></td>
									<td width="10%" align="left" colspan="2"><%=ben.getCertificado()%></td>
									<!--<td width="20%" align="right">&nbsp;</td>-->
								</tr>
								<tr class="TextRow03">
									<td align="right"><cellbytelabel id="15">Periodo de Cobertura - PERDIEM</cellbytelabel></td>
									<td colspan="2"><cellbytelabel id="16">Del</cellbytelabel>:&nbsp;<%=ben.getFechaIni()%></td>
									<td colspan="2"><cellbytelabel id="17">Al</cellbytelabel>:&nbsp;<%=ben.getFechaFin()%></td>
									<td><cellbytelabel id="18">D&iacute;as</cellbytelabel>:<%=ben.getDiasPerdiem()%></td>
								</tr>
								</table>
							</td>
						</tr>
<%
}
%>
						</table>
</div>
</div>
					</td>
				</tr>
<% if (FacDet.getEstatus().equalsIgnoreCase("I") || FacDet.getBeneficios().size() == 0) viewMode = true; %>
				<tr class="TextRow02">
					<td align="right">
						<% if (paquete.equals("-1") && !FacDet.getDistribuido().equals("0")) { %>
							<%=fb.button("paquete","Limpiar Cargos Paquete",true,viewMode,null,null,"onClick=\"javascript:setCargosPaquete('"+paquete+"')\"")%>
						<% } else if (!paquete.equals("-1")) { %>
							<%=fb.button("paquete","Cargos Paquete",true,viewMode,null,null,"onClick=\"javascript:setCargosPaquete('"+paquete+"')\"")%>
						<% } %>
						<% if (FacDet.getEditable().equalsIgnoreCase("S")){%>
						
						<% if (FacDet.getPaseK().equalsIgnoreCase("S")){%>
						<cellbytelabel id="19">Es Jubilado</cellbytelabel>?
						<%=fb.checkbox("esJubilado","S",true,viewMode,null,null,"")%>
						<%}else{%>
						<%=fb.hidden("esJubilado","N")%>
						<%}}else{%>					
						
						<cellbytelabel id="19">Es Jubilado</cellbytelabel>?
						<%=fb.checkbox("esJubilado","S",(FacDet.getPaseK().equalsIgnoreCase("S")),viewMode,null,null,"")%>
						<%}%>
						
						<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_fac_tipo_factura order by 1","tipo_factura","")%>
						<%=fb.button("analizar","Analizar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("imprimirAnalisis","Imprimir Análisis",true,viewMode,null,null,"onClick=\"javascript:printAnalisis();\"")%>
						<%=fb.button("facturar","Facturar",true,viewMode,null,null,"onClick=\"javascript:chkAnalisis('"+fb.getFormName()+"',this.value)\"")%>
						<%//=fb.button("envio","Listas de Envío",true,false,null,null,"onClick=\"javascript:listaEnvio();\"")%>
						<%=fb.button("imprimirFactura","Reimprimir Factura",true,!FacDet.getEstatus().equalsIgnoreCase("I"),null,null,"onClick=\"javascript:printFactura();\"")%>
						
						<%if(fromNewView.equalsIgnoreCase("Y")){%>
						<%=fb.button("imprimirDGIP","Impresión DGI Paciente",true,false,null,null,"onClick=\"javascript:printDGI('P');\"")%>
						<%}%>
						
						<%=fb.button("imprimirDGIE","Impresión DGI Empresa",true,false,null,null,"onClick=\"javascript:printDGI('E');\"")%>
						<%=fb.button("imprimirDetalle","Imprimir Detalle de Cargos",true,false,null,null,"onClick=\"javascript:printCargos();\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<!--
				<tr class="TextRow02">
					<td align="right">
						<%//=fb.button("imprimirDetalle","Imprimir Detalle de Cargos",true,false,null,null,"onClick=\"javascript:printCargos();\"")%>
						<%//=fb.button("facturar","Facturar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%//=fb.button("envio","Listas de Envío",true,false,null,null,"onClick=\"javascript:listaEnvio();\"")%>
						<%//=fb.button("analizar","Analizar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>

						<%//=fb.button("imprimirAnalisis","Imprimir Análisis",true,false,null,null,"onClick=\"javascript:printAnalisis();\"")%>
						<%//=fb.button("imprimirFactura","Reimprimir Factura",true,(FacDet.getEstatus().equals("I")?false:true),null,null,"onClick=\"javascript:printFactura();\"")%>
						<%//=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<%//=fb.button("analizar","Analizar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%//=fb.button("facturar","Facturar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%//=fb.button("imprimirDetalle","Imprimir Detalle de Cargos",true,false,null,null,"onClick=\"javascript:printCargos();\"")%>
						<%//=fb.button("imprimirAnalisis","Imprimir Análisis",true,false,null,null,"onClick=\"javascript:printAnalisis();\"")%>
						<%//=fb.button("imprimirFactura","Reimprimir Factura",true,(FacDet.getEstatus().equals("I")?false:true),null,null,"onClick=\"javascript:printFactura();\"")%>
						<%//=fb.button("solBeneficios","Solicitud de Beneficios",true,false,null,null,"onClick=\"javascript:solBeneficios();\"")%>
						<%//=fb.button("beneficios","Beneficios",true,false,null,null,"onClick=\"javascript:beneficios();\"")%>
						<%//=fb.button("transferir","Transferir",true,false,null,null,"onClick=\"javascript:transferir();\"")%>
						<%//=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<%//=fb.button("anular","Anular Factura",true,false,null,null,"onClick=\"javascript:anular();\"")%>
						<%//=fb.button("imprimirFactura","Reimprimir Factura",true,(FacDet.getEstatus().equals("I")?false:true),null,null,"onClick=\"javascript:printFactura();\"")%>
						<%//=fb.button("solBeneficios","Solicitud de Beneficios",true,false,null,null,"onClick=\"javascript:solBeneficios();\"")%>
						<%//=fb.button("beneficios","Beneficios",true,false,null,null,"onClick=\"javascript:beneficios();\"")%>
						<%//=fb.button("transferir","Transferir",true,false,null,null,"onClick=\"javascript:transferir();\"")%>
						<%//=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				-->
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	FacDet.setCompania((String) session.getAttribute("_companyId"));
	FacDet.setUsuarioCreacion((String) session.getAttribute("_userName"));
	FacDet.setAdmiFechaNacimiento(request.getParameter("fechaNacimiento"));
	FacDet.setAdmiCodigoPaciente(request.getParameter("codigoPaciente"));
	FacDet.setAdmiSecuencia(request.getParameter("admSecuencia"));
	FacDet.setProFacturacion(request.getParameter("proc_facturacion"));
	FacDet.setAplicacionPlan(request.getParameter("aplicacion_plan"));
	FacDet.setTipoFactura(request.getParameter("tipo_factura"));
	FacDet.setGastoNoCubiertos(request.getParameter("gastos_no_cubiertos"));
	FacDet.setAplicacionPlan("B");
	//FacDet.setTipoFactura(request.getParameter("tipo_factura0"));
	FacDet.setCopagoSopPamd(request.getParameter("copago_sop_pamd"));
	FacDet.setTipoMontoC1(request.getParameter("tipo_monto_c1"));
	FacDet.setAlertaAnalisis(request.getParameter("alerta_analisis"));
	FacDet.setAlertaImprimir(request.getParameter("alerta_imprimir"));

	FacDet.setTipoMontoC2(request.getParameter("tipo_monto_c2"));
	if(request.getParameter("monto_c1")!=null && !request.getParameter("monto_c1").equals("")) FacDet.setMontoC1(request.getParameter("monto_c1"));
	else FacDet.setMontoC1("0");
	if(request.getParameter("monto_c2")!=null && !request.getParameter("monto_c2").equals("")) FacDet.setMontoC1(request.getParameter("monto_c2"));
	else FacDet.setMontoC2("0");

	FacDet.setNombrePaciente(request.getParameter("nombrePaciente"));
	FacDet.setPacId(request.getParameter("pacienteId"));
	FacDet.setProvincia(request.getParameter("provincia"));
	FacDet.setSigla(request.getParameter("sigla"));
	FacDet.setTomo(request.getParameter("tomo"));
	FacDet.setAsiento(request.getParameter("asiento"));
	FacDet.setDCedula(request.getParameter("dCedula"));
	FacDet.setPasaporte(request.getParameter("pasaporte"));
	FacDet.setJubilado(request.getParameter("jubilado"));
	FacDet.setNumeroFactura(request.getParameter("numFactura"));
	FacDet.setCategoriaAdmi(request.getParameter("categoria"));
	FacDet.setCategoriaDesc(request.getParameter("categoriaDesc"));
	FacDet.setFechaIngreso(request.getParameter("fechaIngreso"));
	FacDet.setMesCta(request.getParameter("mesCta"));
	FacDet.setAdmiSecuencia(request.getParameter("admSecuencia"));
	FacDet.setAdmEstado(request.getParameter("estado"));
	FacDet.setAdmEstadoDesc(request.getParameter("desc_estado"));
	FacDet.setEmpresa(request.getParameter("empresa"));
	FacDet.setSecBeneficio(request.getParameter("sec_beneficio0"));
	FacDet.setClasifAdmi(request.getParameter("clasificacion"));
	FacDet.setEmbarazada(request.getParameter("embarazada"));

	FacDet.setCodigo(request.getParameter("codigo"));
	if (FacDet.getCodigo() != null && FacDet.getCodigo().trim().equals("")) FacDet.setCodigo(null);

	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String flag = "0";
	//System.out.println("baction="+request.getParameter("baction"));
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg+"&fp="+fp+"&baction="+request.getParameter("baction"));
	if (request.getParameter("baction").equalsIgnoreCase("Analizar")){
		FacMgr.analizar(FacDet);
		flag = "1";
	} else if (request.getParameter("baction").equalsIgnoreCase("Facturar")){
		FacMgr.facturar(FacDet);
		flag = "2";
		//session.removeAttribute("FacDet");
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (FacMgr.getErrCode().equals("1")){
%>
	alert('<%=FacMgr.getErrMsg()%>');
<%
	if (flag.equalsIgnoreCase("1")){
%>
	setTimeout('addMode()',500);
<%
	} else if (flag.equalsIgnoreCase("2")){
%>
	setTimeout('viewMode()',500);
<%
	}
} else throw new Exception(FacMgr.getErrException());
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&pacienteId=<%=pacienteId%>&noAdmision=<%=FacDet.getAdmiSecuencia()%>&change=1&from_new_view=<%=fromNewView%>';
}

function viewMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&pacienteId=<%=pacienteId%>&noAdmision=<%=FacDet.getAdmiSecuencia()%>&change=1&from_new_view=<%=fromNewView%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
