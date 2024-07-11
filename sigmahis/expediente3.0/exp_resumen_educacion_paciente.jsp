<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="resumen" scope="page" class="issi.expediente.ResumenEducacionMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
resumen.setConnection(ConMgr);

Properties prop = new Properties();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String companyId = (String) session.getAttribute("_companyId");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String desc = request.getParameter("desc");
String code = request.getParameter("code");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";

if (fg == null) fg = "AD";
if (code == null) code = "0";
if (desc == null) desc = "";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
		ArrayList al = SQLMgr.getDataList("select codigo, to_char(fecha_creacion, 'dd/mm/yyyy') fc, to_char(fecha_creacion, 'hh12:mi am') hc, usuario_creacion from tbl_sal_resumen_edu where pac_id="+pacId+" and admision="+noAdmision+" order by 1 desc");

		cdo = SQLMgr.getData("select (select diagnostico from tbl_adm_diagnostico_x_admision where pac_id = adm.pac_id and admision = adm.secuencia and tipo = 'I' and orden_diag = 1) codigo_diag, (select (select nvl(observacion, nombre) from tbl_cds_diagnostico where codigo = a.diagnostico ) from tbl_adm_diagnostico_x_admision a where pac_id = adm.pac_id and admision = adm.secuencia and tipo = 'I' and orden_diag = 1)  desc_diag,(select count(*) count_neo from tbl_sal_sumario_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_sumario = 'NEO') as count_neo from tbl_adm_admision adm where adm.pac_id = "+pacId+" and adm.secuencia = "+noAdmision);

		if (cdo==null) {
			cdo = new CommonDataObject();
			cdo.addColValue("count_neo","0");
		}

		int countNeo = Integer.parseInt(cdo.getColValue("count_neo", "0"));

		Hashtable iInsIng = new Hashtable();
		iInsIng.put("1", "Funcionamiento y uso del llamado de enfermera");
		iInsIng.put("2", "Derechos y deberes");
		iInsIng.put("3", "Resaltar importancia de no tener objetos de valor consigo durante la hospitalización");
		iInsIng.put("4", "Visitas, rutinas, restricciones y normas de la unidad");
		iInsIng.put("5", "Importancia del respeto de las normas de bioseguridad");
		iInsIng.put("6", "Prevención de caídas");
		iInsIng.put("7", "Evaluación , reevaluación y Manejo del dolor");
		iInsIng.put("8", "Seguridad y uso efectivo de la tecnología médica(alarmas, ruidos, equipos)");
		iInsIng.put("9", "Restricciones de Medicamentos usados en casa");
		iInsIng.put("10", "Estándar de Seguridad, Identificación del Paciente y lavado de manos");

		Hashtable iInsGenerales = new Hashtable();
		iInsGenerales.put("1","Funcionamiento y uso del llamado de enfermera");
		iInsGenerales.put("2","Derechos y Responsabilidades");
		iInsGenerales.put("3","importancia de no tener objetos de valor consigo<br>durante la hospitalización");
		iInsGenerales.put("4","Visitas, rutina,restricciones y normas de la unidad");
		iInsGenerales.put("5","importancia del respeto de las normas de bioseguridad");
		iInsGenerales.put("6","Estandares de seguridad Identificación, lavado mano, restricción de medicamentos usados en casa");
		iInsGenerales.put("7","*INSTRUCCIONES DE MEDICAMENTOS");
		iInsGenerales.put("8","* EVALUACIÓN REEVALUACIÓN Y MANEJO DEL<br>DOLOR (ESCALAS, INTERVENCIONES)");
		iInsGenerales.put("9","* PREVENCIÓN DE CAÍDA");
		iInsGenerales.put("10","* SEGURIDAD Y USO EFECTIVO DE LA TECNOLOGÍA<br>MÉDICA(Alarmas,ruidos equipos)");
		iInsGenerales.put("11","* TRATAMIENTO");
		iInsGenerales.put("12","* PLAN DE SALIDA");

		CommonDataObject cdoIns = new CommonDataObject();
		Hashtable iInsEngSe = new Hashtable();
		String tipoSumario = "AD";

		if ( countNeo > 0 ) {
				tipoSumario = "NEO";

				iInsEngSe.put("0", "Lactancia materna");
				iInsEngSe.put("1", "Complemento (tipo formula)");
				iInsEngSe.put("2", "Forma de preparación");
				iInsEngSe.put("3", "Posición de la madre y bebe");
				iInsEngSe.put("4", "Baño del bebe");
				iInsEngSe.put("5", "Forma de sacar los gases");
				iInsEngSe.put("6", "Cuidados del cordón umbilical");
				iInsEngSe.put("7", "Higiene de genitales");
				iInsEngSe.put("8", "Cuidados de circuncisión");

		} else  {

			 iInsEngSe.put("0", "Equipos especiales");
			 iInsEngSe.put("1", "Cuidados post operatorios");
			 iInsEngSe.put("2", "Curación de heridas");
			 iInsEngSe.put("3", "Signos y síntomas de infección");
			 iInsEngSe.put("4", "Terapia respiratoria");
			 iInsEngSe.put("5", "Fisioterapia");
			 iInsEngSe.put("6", "Glicemia capilar");
			 iInsEngSe.put("7", "Dieta especial");
			 iInsEngSe.put("8", "Prevención de caídas");
			 iInsEngSe.put("9", "Manejo del dolor");
			 iInsEngSe.put("10", "Medicamentos");
			 iInsEngSe.put("11", "Otros");
		}

		cdoIns = SQLMgr.getData("select acciones from tbl_sal_sumario_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_sumario = '"+tipoSumario+"'");

		if(!code.trim().equals("") && !code.trim().equals("0")) {
				prop = SQLMgr.getDataProperties("select resumen from tbl_sal_resumen_edu where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+code);
				if (prop == null) {
						if(!viewMode) modeSec = "add";
				}
				else{
						if(!viewMode) modeSec = "edit";
				}
		}

		if (modeSec.trim().equalsIgnoreCase("add")){
				prop = SQLMgr.getDataProperties("select sumario from tbl_sal_sumario_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_sumario = '"+tipoSumario+"'");
				if(prop == null) prop = new Properties();
		}

		if (cdoIns == null) {
		 cdoIns = new CommonDataObject();
		 cdoIns.addColValue("acciones"," ");
		}

		Hashtable iOtros = new Hashtable();
		iOtros.put("1", "OTROS TEMAS");
		iOtros.put("2", "PEDIATRIA");

		Hashtable iSop = new Hashtable();
		iSop.put("1", "SALÓN DE OPERACIONES");
		iSop.put("2", "Pre operatoria");
		iSop.put("3", "Consentimientos");
		iSop.put("4", "Prevencion de Caídas");
		iSop.put("5", "Pausa de seguridad");
		iSop.put("5", "Preparación");
		iSop.put("6", "Medicamentos");
		iSop.put("7", "Otros");
		iSop.put("8", "Post Operatoria");
		iSop.put("9", "Àrea de recobro");
		iSop.put("10", "Evaluación");
		iSop.put("11", "Manejo del dolor");
		iSop.put("12", "Prevencion de Caídas");
		iSop.put("13", "Otro");

		//Partos
		iSop.put("14", "PARTOS");
		iSop.put("15", "Norma de la sala");
		iSop.put("16", "Monitoreo");
		iSop.put("17", "Prevencion de Caídas");
		iSop.put("18", "Labor y parto");
		iSop.put("19", "Consentimientos");
		iSop.put("20", "Dolor y analgesia");
		iSop.put("21", "Respiración");
		iSop.put("22", "Relajación");
		iSop.put("23", "Lactancia");

		// Nutricion
		Hashtable iNutricion = new Hashtable();
		/*iNutricion.put("1", "Entrega Volante Educativa Tipo De Dieta escogida para paciente");
		iNutricion.put("2", "Entrega Volante Educativa Interacción Droga/Alimento");
		iNutricion.put("3", "Educación Tipo de Dieta de Preparación Fuera de Hospital");
		iNutricion.put("4", "Rechazo De Dieta Hospitalaria-Paciente: Por dieta según la cultura del paciente");*/

		Hashtable iNeo = new Hashtable();
		iNeo.put("1", "Norma");
		iNeo.put("2", "Identificación");
		iNeo.put("3", "Cuidado de transición");
		iNeo.put("4", "Apego madre -hijo");
		iNeo.put("5", "Lactancia materna:posturas y tecnicas");
		iNeo.put("6", "Recolección de leche materna y su manejo");
		iNeo.put("7", "Uso de ordeñadores");
		iNeo.put("8", "Higiene y baño del recien nacido");
		iNeo.put("9", "Vigilancia del recien nacido: cambios importantes. (ictericia, aspecto del meconio diuresis, cuidado del ombligo,color, piel)");
		iNeo.put("10","NUTRICIÓN: (específique)");
		iNeo.put("11","TERAPIA RESPIRATORIA: (específique)");
		iNeo.put("12","TÉCNICA DE REHABILITACIÓN: (específique)");
		iNeo.put("13","TEMAS MÉDICOS");
		iNeo.put("14","ORIENTACIÓN MÉDICA A LA ADMISIÓN");
		iNeo.put("15","PROCEDIMIENTOS MÉDICOS");
		iNeo.put("16","COMPLICACIONES");
		iNeo.put("17","PRUEBAS COMPLEMENTARIAS");
		iNeo.put("18","CONSENTIMIENTOS");
		iNeo.put("19","INSTRUCCIONES DE MEDICAMENTOS (posibles efectos adversos, reacciones de hipersensibilidad)");
		iNeo.put("20","ORIENTACIÓN MÉDICA AL EGRESO (Sumario de Egreso,Carenotes, signos de alarma)");

		int domIndex = iInsIng.size() + 1;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
<script>
var noNewHeight = true;
function doAction(){}

$(document).ready(function(){
<%if(!viewMode){%>
		$("input[type='text'], textarea").prop('readOnly', true);
		$("button[name*='resetfecha0_'], select").prop('disabled', true);

		$("input[type='radio'][name*='acompaniado_por']").click(function(e){
				var $self = $(this);
				var i = $self.attr('name').replace ( /[^\d]/g, '' );
				$("#fecha0_"+i).prop('readOnly', false);
				$("#observacion"+i).prop('readOnly', false);
				$("#resetfecha0_"+i).prop('disabled', false);
				$("#forma0_"+i).prop('disabled', false);
				$("#quien_recibe0_"+i).prop('disabled', false);
				$("#evaluacion0_"+i).prop('disabled', false);
		});
<%}%>
});

function canSubmit() {
	var proceed = true;
	$("input[type='radio'][name*='acompaniado_por']:checked").each(function(){
		var $self = $(this);
		var i = $self.attr('name').replace ( /[^\d]/g, '' );
		var $applyValidation = $(".apply-validation-"+i);
		var $fecha = $("#fecha0_"+i);
		var $forma = $("#forma0_"+i);
		var $quienRecibe = $("#quien_recibe0_"+i);
		var $evaluacion = $("#evaluacion0_"+i);
		var $observacion = $("#observacion"+i);

		if ($applyValidation.length && (
				($fecha.length > 0 && !$fecha.val()) ||
				($forma.length > 0 && !$forma.val()) ||
				($quienRecibe.length > 0 && !$quienRecibe.val()) ||
				($evaluacion.length > 0 && !$evaluacion.val()) ||
				($observacion.length > 0 && !$observacion.val())
		)) {
			 proceed = false;
			 parent.CBMSG.error("Por favor suministre información para toda la fila.");
			 return false;
		}
	});

	return proceed;
}

function setAcciones() {
	var acciones = $("input:checked[type='checkbox'][name^='instrucciones']").map(function(){
		return this.value;
	}).get().join();
	alert(acciones)
	$("#acciones").val(acciones);
}

function add(){window.location = '../expediente3.0/exp_resumen_educacion_paciente.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0';}

function verHistorial() {
	$("#hist_container").toggle();
}

function setResumen(code){
		window.location = '../expediente3.0/exp_resumen_educacion_paciente.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code='+code;
}

function printExp(n){
	var url="../expediente3.0/print_resumen_educacion_paciente.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>";
	if(n==1)url+="&code=<%=code%>";
	abrir_ventana(url);
}
</script>
<style>
	.text-center{text-align:center !important;}
	.remove-default{padding:0 !important; line-height: 0 !important; border:0 !important; background-color:inherit !important}
	.form-inline .input-group {z-index:0 !important;}
	table {width: 100%; border-collapse: collapse;}
	td, th {padding: .25em;border: 1px solid black;}
	tbody:nth-child(odd) {background: #CCC;}
</style>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
		<div class="table-responsive" data-pattern="priority-columns">
		<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
		<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("modeSec",modeSec)%>
		<%=fb.hidden("seccion",seccion)%>
		<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
		<%=fb.hidden("dob","")%>
		<%=fb.hidden("codPac","")%>
		<%=fb.hidden("pacId",pacId)%>
		<%=fb.hidden("noAdmision",noAdmision)%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("desc",desc)%>
		<%=fb.hidden("acciones","")%>
		<%=fb.hidden("codigo_diag", cdo.getColValue("codigo_diag"))%>
		<%=fb.hidden("desc_diag", cdo.getColValue("desc_diag"))%>
				<%=fb.hidden("code",code)%>

				<div class="headerform">
						<table cellspacing="0" class="table pull-right table-striped table-custom-1">
								<tr>
										<td>
										<%if(!mode.trim().equals("view")){%>
											<button type="button" class="btn btn-inverse btn-sm" onClick="add()">
												<i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
											</button>
										<%}%>
											<button type="button" class="btn btn-inverse btn-sm" onClick="verHistorial()">
												<i class="fa fa-eye fa-printico"></i> <b>Historial</b>
											</button>
										<%if(!code.trim().equals("") && !code.trim().equals("0")){%>
												<button type="button" class="btn btn-inverse btn-sm" onClick="printExp(1)"><i class="material-icons fa-printico">print</i> <b>Imprimir</b></button>
										<%}%>
										<% if (al.size() > 0) { %><button type="button" class="btn btn-inverse btn-sm" onClick="printExp(0)"><i class="material-icons fa-printico">print</i> <b>Imprimir Todos</b></button><% } %>
										</td>
								</tr>
						</table>

						<div class="table-wrapper" id="hist_container" style="display:none">
								<table cellspacing="0" class="table table-small-font table-bordered table-striped">
								<thead>
										<tr class="bg-headtabla2">
										<th style="vertical-align: middle !important;">C&oacute;digo</th>
										<th style="vertical-align: middle !important;">Fecha</th>
										<th style="vertical-align: middle !important;">Hora</th>
										<th style="vertical-align: middle !important;">Usuario</th>
										</thead>
										<%
										for (int p = 1; p <= al.size(); p++){
												cdo = (CommonDataObject)al.get(p-1);
										%>
										<tbody>
												<tr onClick="javascript:setResumen('<%=cdo.getColValue("codigo")%>')" class="pointer">
														<td><%=cdo.getColValue("codigo")%></td>
														<td><%=cdo.getColValue("fc")%></td>
														<td><%=cdo.getColValue("hc")%></td>
														<td><%=cdo.getColValue("usuario_creacion")%></td>
												</tr>
										</tbody>
										<% }%>
								</table>
						 </div>

						<table class="table table-small-font table-bordered">
								<tr>
										<th width="10%" colspan="3" class="text-center">Evaluación al<br>Ingreso</th>
										<th width="50%" class="text-center">
												TEMAS EDUCATIVOS
										</th>
										<th width="40%" colspan="4" class="text-center">EDUCACIÓN DEL PACIENTE</th>
								</tr>

								<tr>
										<th class="text-center" width="3%">E</th>
										<th class="text-center" width="3%">R</th>
										<th class="text-center" width="4%">C</th>
										<th style="font-size:12px" width="50%">
												E = Necesita que se le enseñe No domina el tema<br>
												R = Necesita reforzamiento, lo domina parcialmente<br>
												C = Se siente cómodo con el tema, lo entiende y domina
										</th>
										<th class="text-center" width="10%">Fecha</th>
										<th class="text-center" width="10%">Forma</th>
										<th class="text-center" width="10%">Inicial a quién<br>orienta</th>
										<th class="text-center" width="10%">Evaluación</th>
								</tr>
				</table>
				</div>

				<table class="table table-small-font table-bordered" style="margin-top:89px !important" id="content">

								<!-- dummy-->
								<tr>
										<th width="10%" colspan="3" style="height:0px"></th>
										<th width="50%" style="height:0px"></th>
										<th width="40%" colspan="4" style="height:0px"></th>
								</tr>

								<tr style="height:0px">
										<th class="text-center" width="3%"></th>
										<th class="text-center" width="3%"></th>
										<th class="text-center" width="4%"></th>
										<th style="font-size:12px" width="50%"></th>
										<th class="text-center" width="10%"></th>
										<th class="text-center" width="10%"></th>
										<th class="text-center" width="10%"></th>
										<th class="text-center" width="10%"></th>
								</tr>
								<!--dummy -->

								<tr>
										<th colspan="3"></th>
										<th><b>*INSTRUCCIONES AL INGRESO</b></th>
										<th colspan="8"></th>
								</tr>



								<%
								for (int i = 1; i <= iInsIng.size(); i++) {
								%>
								<tbody>
								<tr class="text-center">
										<td><%=fb.radio("acompaniado_por"+i,"E",prop.getProperty("acompaniado_por"+i)!=null&&prop.getProperty("acompaniado_por"+i).equals("E"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+i,"R",prop.getProperty("acompaniado_por"+i)!=null&&prop.getProperty("acompaniado_por"+i).equals("R"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+i,"C",prop.getProperty("acompaniado_por"+i)!=null&&prop.getProperty("acompaniado_por"+i).equals("C"),viewMode,false)%></td>

										<td style="text-align: left">
												<%=iInsIng.get(""+(i))%>
										</td>
										<%if(i != 1){%>
										<td colspan="8"></td>
										<%}else {%>
										<td class="controls form-inline">
												<input type="hidden" class="apply-validation-<%=i%>">
												<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1"/>
														<jsp:param name="format" value="dd/mm/yyyy"/>
														<jsp:param name="nameOfTBox1" value="<%="fecha0_"+i%>" />
														<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha0_"+i)!=null?prop.getProperty("fecha0_"+i):""%>" />
														<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
												</jsp:include>
										</td>
										<td class="controls form-inline">
										<%=fb.select("forma0_"+i,"O=O-Oral,D=D-Demostración,H=H-Documentación,A=A-Audiovisual,T=T-Taller",prop.getProperty("forma0_"+i),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline">
										<%=fb.select("quien_recibe0_"+i,"P=P-Paciente,F=F-Familiar",prop.getProperty("quien_recibe0_"+i),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline">
										<%=fb.select("evaluacion0_"+i,"1=1-No se pudo realizar/entender,2=2-Necesita reforzamiento y/o práctica,3=3-Realiza / Verbaliza comprende",prop.getProperty("evaluacion0_"+i),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										<%}%>
								</tr>
								</tbody>
								<%} //for %> <!-- Instrucciones al ingreso -->

								<tr>
										<td colspan="3"></td>
										<td><b>*INSTRUCCIONES GENERALES</b></td>
										<td colspan="8"></td>
								</tr>

								<% for (int i = 1; i <= iInsGenerales.size(); i++) {
								domIndex++;
								%>
								<tr class="text-center">
										<td><%=fb.radio("acompaniado_por"+domIndex,"E",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("E"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"R",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("R"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"C",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("C"),viewMode,false)%></td>

										<td style="text-align: left">
										<%if (i<8) {%>
											<%=i+".&nbsp;&nbsp;"%><%=iInsGenerales.get(i+"")!=null?iInsGenerales.get(i+""):""%>
										<%}else {%>
										 <b><%=iInsGenerales.get(i+"")!=null?iInsGenerales.get(i+""):""%><b>
										<%}%>

										</td>
										<td class="controls form-inline">
												<input type="hidden" class="apply-validation-<%=domIndex%>">
												<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1"/>
														<jsp:param name="format" value="dd/mm/yyyy"/>
														<jsp:param name="nameOfTBox1" value="<%="fecha0_"+domIndex%>" />
														<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha0_"+domIndex)!=null?prop.getProperty("fecha0_"+domIndex):""%>" />
														<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
												</jsp:include>
										</td>
										<td class="controls form-inline">
										<%=fb.select("forma0_"+domIndex,"O=O-Oral,D=D-Demostración,H=H-Documentación,A=A-Audiovisual,T=T-Taller",prop.getProperty("forma0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline">
												<%=fb.select("quien_recibe0_"+domIndex,"P=P-Paciente,F=F-Familiar",prop.getProperty("quien_recibe0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline">
										<%=fb.select("evaluacion0_"+domIndex,"1=1-No se pudo realizar/entender,2=2-Necesita reforzamiento y/o práctica,3=3-Realiza / Verbaliza comprende",prop.getProperty("evaluacion0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>

								</tr>

								<%} //for %> <!-- Generales -->

								<tr>
										<td colspan="3"></td>
										<td><b>*INSTRUCCIONES AL EGRESO (S.E)</b></td>
										<td colspan="8"></td>
								</tr>
								<%
								boolean showEval = true;
								for (int i = 0; i < iInsEngSe.size(); i++) {
								domIndex++;
								%>
								<%if( (modeSec.trim().equalsIgnoreCase("add") && prop.getProperty("instrucciones"+i) != null ) || prop.getProperty("observacion"+domIndex) != null) {%>
								<tr class="text-center">
										<td><%=fb.radio("acompaniado_por"+domIndex,"E",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("E"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"R",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("R"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"C",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("C"),viewMode,false)%></td>

										<td style="text-align: left">
												<%if(modeSec.trim().equalsIgnoreCase("add")){%>
														<%=prop.getProperty("instrucciones"+i)==null||"".equals(prop.getProperty("instrucciones"+i)) ? "" : iInsEngSe.get(""+prop.getProperty("instrucciones"+i))%>
												<%} else {%>
														<%=iInsEngSe.get(""+i)%>
												<%}%>

						 <%//=prop.getProperty("instrucciones"+i)%>

												<input type="hidden" class="apply-validation-<%=domIndex%>">
												<%=fb.textarea("observacion"+domIndex,modeSec.trim().equalsIgnoreCase("add")?prop.getProperty("observacion"+(prop.getProperty("instrucciones"+i)==null||"".equals(prop.getProperty("instrucciones"+i))?"-1" : Integer.parseInt(prop.getProperty("instrucciones"+i))+3) ):prop.getProperty("observacion"+domIndex),false,false,viewMode,0,1,2000,"form-control input-sm","",null)%>
										</td>
										<%if(!showEval){%>
										<td colspan="8"></td>
										<%}else {%>

										<td class="controls form-inline">
												<input type="hidden" class="apply-validation-<%=domIndex%>">
												<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1"/>
														<jsp:param name="format" value="dd/mm/yyyy"/>
														<jsp:param name="nameOfTBox1" value="<%="fecha0_"+domIndex%>" />
														<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha0_"+domIndex)!=null?prop.getProperty("fecha0_"+domIndex):""%>" />
														<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
												</jsp:include>
										</td>
										<td class="controls form-inline">
										<%=fb.select("forma0_"+domIndex,"O=O-Oral,D=D-Demostración,H=H-Documentación,A=A-Audiovisual,T=T-Taller",prop.getProperty("forma0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline">
										<%=fb.select("quien_recibe0_"+domIndex,"P=P-Paciente,F=F-Familiar",prop.getProperty("quien_recibe0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline">
										<%=fb.select("evaluacion0_"+domIndex,"1=1-No se pudo realizar/entender,2=2-Necesita reforzamiento y/o práctica,3=3-Realiza / Verbaliza comprende",prop.getProperty("evaluacion0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										<%
										showEval = false;
										}%>
								</tr>
								<%}%>
								<%} //for %>

								<%
								for (int i = 1; i <= iOtros.size(); i++) {
								domIndex++;
								%>
								<tr class="text-center">
										<td><%=fb.radio("acompaniado_por"+domIndex,"E",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("E"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"R",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("R"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"C",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("C"),viewMode,false)%></td>

										<td style="text-align: left">
										<input type="hidden" class="apply-validation-<%=domIndex%>">
										<b><%=iOtros.get(""+i)%></b>&nbsp;&nbsp;<%=fb.textarea("observacion"+domIndex,prop.getProperty("observacion"+domIndex),false,false,viewMode,0,1,2000,"form-control input-sm","",null)%>
										</td>
										<td class="controls form-inline">
												<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1"/>
														<jsp:param name="format" value="dd/mm/yyyy"/>
														<jsp:param name="nameOfTBox1" value="<%="fecha0_"+domIndex%>" />
														<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha0_"+domIndex)!=null?prop.getProperty("fecha0_"+domIndex):""%>" />
														<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
												</jsp:include>
										</td>
										<td class="controls form-inline">
										<%=fb.select("forma0_"+domIndex,"O=O-Oral,D=D-Demostración,H=H-Documentación,A=A-Audiovisual,T=T-Taller",prop.getProperty("forma0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline"><%=fb.select("quien_recibe0_"+domIndex,"P=P-Paciente,F=F-Familiar",prop.getProperty("quien_recibe0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										<td class="controls form-inline"><%=fb.select("evaluacion0_"+domIndex,"1=1-No se pudo realizar/entender,2=2-Necesita reforzamiento y/o práctica,3=3-Realiza / Verbaliza comprende",prop.getProperty("evaluacion0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
								</tr>
								<%} //for %>

								<%
								for (int i = 1; i <= iSop.size(); i++) {
								domIndex++;
								String sopDesc = iSop.get(""+i) !=null?iSop.get(""+i).toString().trim():"";
								%>
								<tr class="text-center">
										<%if (sopDesc.equalsIgnoreCase("SALÓN DE OPERACIONES")||sopDesc.equalsIgnoreCase("Pre operatoria")||sopDesc.equalsIgnoreCase("Post Operatoria")){%>
											<td colspan="3"></td>
											<td style="text-align: left"><b><%=sopDesc%>:</b></td>
											<td colspan="8"></td>
										<%} else if(sopDesc.equalsIgnoreCase("PARTOS")){%>
											<td colspan="3"></td>
											<td style="text-align: left"><b><%=sopDesc%>:</b></td>
											<td colspan="8"></td>
										<%} else {%>
										<td><%=fb.radio("acompaniado_por"+domIndex,"E",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("E"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"R",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("R"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"C",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("C"),viewMode,false)%></td>

										<td style="text-align: left">
												<input type="hidden" class="apply-validation-<%=domIndex%>">
												<%=sopDesc%>
												<% if (sopDesc.equalsIgnoreCase("otros") || sopDesc.equalsIgnoreCase("otro")) { %>&nbsp;&nbsp;<%=fb.textarea("observacion"+domIndex,prop.getProperty("observacion"+domIndex),false,false,viewMode,0,1,2000,"form-control input-sm","",null)%><% } %>
										</td>

										<td class="controls form-inline">
												<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1"/>
														<jsp:param name="format" value="dd/mm/yyyy"/>
														<jsp:param name="nameOfTBox1" value="<%="fecha0_"+domIndex%>" />
														<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha0_"+domIndex)!=null?prop.getProperty("fecha0_"+domIndex):""%>" />
														<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
												</jsp:include>
										</td>
										<td class="controls form-inline">
										<%=fb.select("forma0_"+domIndex,"O=O-Oral,D=D-Demostración,H=H-Documentación,A=A-Audiovisual,T=T-Taller",prop.getProperty("forma0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline"><%=fb.select("quien_recibe0_"+domIndex,"P=P-Paciente,F=F-Familiar",prop.getProperty("quien_recibe0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										<td class="controls form-inline"><%=fb.select("evaluacion0_"+domIndex,"1=1-No se pudo realizar/entender,2=2-Necesita reforzamiento y/o práctica,3=3-Realiza / Verbaliza comprende",prop.getProperty("evaluacion0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										<%}%>
								</tr>
								<%if(i == iSop.size()){
								domIndex++;
								%>
										<tr class="text-center">
										<td colspan="3">Otro</td>
										<td>
										<input type="hidden" class="apply-validation-<%=domIndex%>">
										<%=fb.textarea("observacion"+domIndex,prop.getProperty("observacion"+domIndex),false,false,viewMode,0,1,2000,"form-control input-sm","",null)%>
										</td>
										<td class="controls form-inline">
												<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1"/>
														<jsp:param name="format" value="dd/mm/yyyy"/>
														<jsp:param name="nameOfTBox1" value="<%="fecha0_"+domIndex%>" />
														<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha0_"+domIndex)!=null?prop.getProperty("fecha0_"+domIndex):""%>" />
														<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
												</jsp:include>
										</td>
										<td class="controls form-inline">
										<%=fb.select("forma0_"+domIndex,"O=O-Oral,D=D-Demostración,H=H-Documentación,A=A-Audiovisual,T=T-Taller",prop.getProperty("forma0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline"><%=fb.select("quien_recibe0_"+domIndex,"P=P-Paciente,F=F-Familiar",prop.getProperty("quien_recibe0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										<td class="controls form-inline"><%=fb.select("evaluacion0_"+domIndex,"1=1-No se pudo realizar/entender,2=2-Necesita reforzamiento y/o práctica,3=3-Realiza / Verbaliza comprende",prop.getProperty("evaluacion0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										</tr>
								<%}%>
								<%} //for %>

								<!-- Nutricion -->
								<!--<tr>
										<td colspan="3"></td>
										<td><b>NUTRICIÓN</b></td>
										<td colspan="8"></td>
								</tr>-->
								<%
								for (int i = 1; i <= iNutricion.size(); i++) {
								domIndex++;
								String seoDesc = iNutricion.get(""+i) !=null?iNutricion.get(""+i).toString().trim():"";
								%>
								<tr class="text-center">
										<%if(!seoDesc.equalsIgnoreCase("TEMAS MÉDICOS")){%>
										<td><%=fb.radio("acompaniado_por"+domIndex,"E",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("E"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"R",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("R"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"C",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("C"),viewMode,false)%></td>
										<%}else{%>
											<td colspan="3"></td>
										<%}%>

										<td style="text-align: left">
										<%if(seoDesc.contains("NUTRICIÓN") || seoDesc.contains("TERAPIA RESPIRATORIA") || seoDesc.contains("TÉCNICA DE REHABILITACIÓN") || seoDesc.contains("TEMAS MÉDICOS")){%>
												<b><%=seoDesc%></b>
										<%} else {%>
												<%=seoDesc%>
										<%}%>
										<%if(seoDesc.contains("específique")){%>
										<input type="hidden" class="apply-validation-<%=domIndex%>">
										<br>
										<%=fb.textarea("observacion"+domIndex,prop.getProperty("observacion"+domIndex),false,false,viewMode,0,1,2000,"form-control input-sm","",null)%>
										<input type="hidden" class="apply-validation-<%=i%>">
										<%}%>
										</td>
										<%if(!seoDesc.equalsIgnoreCase("TEMAS MÉDICOS")){%>
										<input type="hidden" class="apply-validation-<%=domIndex%>">
										<td class="controls form-inline">
												<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1"/>
														<jsp:param name="format" value="dd/mm/yyyy"/>
														<jsp:param name="nameOfTBox1" value="<%="fecha0_"+domIndex%>" />
														<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha0_"+domIndex)!=null?prop.getProperty("fecha0_"+domIndex):""%>" />
														<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
												</jsp:include>
										</td>
										<td class="controls form-inline">
										<%=fb.select("forma0_"+domIndex,"O=O-Oral,D=D-Demostración,H=H-Documentación,A=A-Audiovisual,T=T-Taller",prop.getProperty("forma0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline"><%=fb.select("quien_recibe0_"+domIndex,"P=P-Paciente,F=F-Familiar",prop.getProperty("quien_recibe0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										<td class="controls form-inline"><%=fb.select("evaluacion0_"+domIndex,"1=1-No se pudo realizar/entender,2=2-Necesita reforzamiento y/o práctica,3=3-Realiza / Verbaliza comprende",prop.getProperty("evaluacion0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										<%}else {%>
											<td colspan="4"></td>
										<%}%>
								</tr>
								<%} //for %>

								<!-- neonatologia -->
								<tr>
										<td colspan="3"></td>
										<td><b>NEONATOLOGÍA</b></td>
										<td colspan="8"></td>
								</tr>
								<%
								for (int i = 1; i <= iNeo.size(); i++) {
								domIndex++;
								String seoDesc = iNeo.get(""+i) !=null?iNeo.get(""+i).toString().trim():"";
								%>
								<tr class="text-center">
										<%if(!seoDesc.equalsIgnoreCase("TEMAS MÉDICOS")){%>
										<td><%=fb.radio("acompaniado_por"+domIndex,"E",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("E"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"R",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("R"),viewMode,false)%></td>
										<td><%=fb.radio("acompaniado_por"+domIndex,"C",prop.getProperty("acompaniado_por"+domIndex)!=null&&prop.getProperty("acompaniado_por"+domIndex).equals("C"),viewMode,false)%></td>
										<%}else{%>
											<td colspan="3"></td>
										<%}%>

										<td style="text-align: left">
										<%if(seoDesc.contains("NUTRICIÓN") || seoDesc.contains("TERAPIA RESPIRATORIA") || seoDesc.contains("TÉCNICA DE REHABILITACIÓN") || seoDesc.contains("TEMAS MÉDICOS")){%>
												<b><%=seoDesc%></b>
										<%} else {%>
												<%=seoDesc%>
										<%}%>
										<%if(seoDesc.contains("específique")){%>
										<br>
										<input type="hidden" class="apply-validation-<%=domIndex%>">
										<%=fb.textarea("observacion"+domIndex,prop.getProperty("observacion"+domIndex),false,false,viewMode,0,1,2000,"form-control input-sm","",null)%>
										<%}%>
										</td>
										<%if(!seoDesc.equalsIgnoreCase("TEMAS MÉDICOS")){%>
										<input type="hidden" class="apply-validation-<%=domIndex%>">
										<td class="controls form-inline">
												<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1"/>
														<jsp:param name="format" value="dd/mm/yyyy"/>
														<jsp:param name="nameOfTBox1" value="<%="fecha0_"+domIndex%>" />
														<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha0_"+domIndex)!=null?prop.getProperty("fecha0_"+domIndex):""%>" />
														<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
												</jsp:include>
										</td>
										<td class="controls form-inline">
										<%=fb.select("forma0_"+domIndex,"O=O-Oral,D=D-Demostración,H=H-Documentación,A=A-Audiovisual,T=T-Taller",prop.getProperty("forma0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%>
										</td>
										<td class="controls form-inline"><%=fb.select("quien_recibe0_"+domIndex,"P=P-Paciente,F=F-Familiar",prop.getProperty("quien_recibe0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										<td class="controls form-inline"><%=fb.select("evaluacion0_"+domIndex,"1=1-No se pudo realizar/entender,2=2-Necesita reforzamiento y/o práctica,3=3-Realiza / Verbaliza comprende",prop.getProperty("evaluacion0_"+domIndex),false,viewMode,0,"form-control input-sm","width:53px","",null," ")%></td>
										<%}else {%>
											<td colspan="4"></td>
										<%}%>
								</tr>
								<%} //for %>





				</table>

		<div class="footerform">
				<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
				<tr>
						<td>
						<%=fb.hidden("saveOption","O")%>
						<%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>
						</td>
				</tr>
		</table> </div>
		<%=fb.hidden("domIndex", ""+domIndex)%>
<%=fb.formEnd(true)%>

 </div>
 </div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	prop = new Properties();

		prop.setProperty("codigo",request.getParameter("code"));
		prop.setProperty("pac_id",request.getParameter("pacId"));
	prop.setProperty("admision",request.getParameter("noAdmision"));
	prop.setProperty("tipo_cuestionario",request.getParameter("fg"));
		prop.setProperty("usuario_creacion", (String) session.getAttribute("_userName"));
		prop.setProperty("fecha_creacion", cDateTime);

		int domIndex = Integer.parseInt(request.getParameter("domIndex"));

		for ( int o = 1; o <= domIndex; o++ ){

			if(request.getParameter("acompaniado_por"+o) != null) prop.setProperty("acompaniado_por"+o,request.getParameter("acompaniado_por"+o));
			if (request.getParameter("observacion"+o) != null && !request.getParameter("observacion"+o).trim().equals("")) prop.setProperty("observacion"+o, request.getParameter("observacion"+o));
			if(request.getParameter("fecha0_"+o) != null) prop.setProperty("fecha0_"+o,request.getParameter("fecha0_"+o));
			if(request.getParameter("fecha1_"+o) != null) prop.setProperty("fecha1_"+o,request.getParameter("fecha1_"+o));
			if(request.getParameter("forma0_"+o) != null) prop.setProperty("forma0_"+o,request.getParameter("forma0_"+o));
			if(request.getParameter("forma1_"+o) != null) prop.setProperty("forma1_"+o,request.getParameter("forma1_"+o));
			if(request.getParameter("quien_recibe0_"+o) != null) prop.setProperty("quien_recibe0_"+o,request.getParameter("quien_recibe0_"+o));
			if(request.getParameter("quien_recibe1_"+o) != null) prop.setProperty("quien_recibe1_"+o,request.getParameter("quien_recibe1_"+o));
			if(request.getParameter("evaluacion0_"+o) != null) prop.setProperty("evaluacion0_"+o,request.getParameter("evaluacion0_"+o));
			if(request.getParameter("evaluacion1_"+o) != null) prop.setProperty("evaluacion1_"+o,request.getParameter("evaluacion1_"+o));
		}

	if (modeSec.trim().equalsIgnoreCase("edit")) {
			prop.setProperty("usuario_modificacion", (String) session.getAttribute("_userName"));
			prop.setProperty("fecha_modificacion", cDateTime);
			prop.setProperty("fecha_creacion", cDateTime);
		}

	if (baction.equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) resumen.add(prop);
		else resumen.update(prop);
		ConMgr.clearAppCtx(null);
	}

		if (modeSec.trim().equalsIgnoreCase("add")) {
			code = resumen.getPkColValue("codigo");
		}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (resumen.getErrCode().equals("1"))
{
%>
	alert('<%=resumen.getErrMsg()%>');
<%

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
	parent.doRedirect(0);
<%
	}
} else throw new Exception(resumen.getErrException());
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&code=<%=code%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>