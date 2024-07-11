<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Cita"%>
<%@ page import="issi.facturacion.FactDetTransaccion"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CitasMgr" scope="page" class="issi.admision.CitaMgr" />
<jsp:useBean id="iProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProc" scope="session" class="java.util.Vector" />
<%
/**
===============================================================================
FP            FORMA         MENU                                          NOMBRE EN FORMA
              CDC100100     CITAS\TRANSACCIONES\CRONOGRAMA DE QUIROFANOS  SALON DE OPERACIONES PROGRAMA QUIRURGICO
imagenologia  cdc100200_v2  CITAS\TRANSACCIONES\PROG. CITAS IMAG. V2
Cuando se edita llama a la forma CDC100010
==============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CitasMgr.setConnection(ConMgr);
CommonDataObject cdoParam = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Cita cita = new Cita();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String cds = request.getParameter("cds");
String habitacion = request.getParameter("habitacion");
String habCds = request.getParameter("habCds");
String codigo = request.getParameter("codigo");
String fechaCita = request.getParameter("fechaCita");
String horaCita = request.getParameter("horaCita");
String change = request.getParameter("change");
String citasSopAdm = request.getParameter("citasSopAdm");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String codMedico  = request.getParameter("medico");
String medicoNombre  = request.getParameter("nombreMedico"); 
String formaReserva  = request.getParameter("forma_reserva");
String provincia  = request.getParameter("provincia");
String sigla  = request.getParameter("sigla");
String tomo  = request.getParameter("tomo");
String asiento  = request.getParameter("asiento");
String dCedula  = request.getParameter("d_cedula");
String pasaporte  = request.getParameter("pasaporte");
String tipoPaciente  = request.getParameter("tipo_paciente");
String fechaNacimiento  = request.getParameter("f_nac");
String codPaciente  = request.getParameter("codigo_paciente");
String sexo  = request.getParameter("sexo");
String citasAmb = request.getParameter("citasAmb");
boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (fp == null) fp = "";
if (cds == null) throw new Exception("El Centro de Servicio no es v�lido. Por favor intente nuevamente!");
if (fp.equalsIgnoreCase("imagenologia") && habCds == null) throw new Exception("El Centro de Servicio del Area de Cita no es v�lida. Por favor intente nuevamente!");
if (habCds == null) habCds = "";
if (codigo == null) codigo = "0";
if (fechaCita == null) fechaCita = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (horaCita == null) horaCita = "";
if (citasSopAdm == null) citasSopAdm = "";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (codMedico  == null) codMedico  = "";
if (medicoNombre  == null) medicoNombre  = ""; 
if (formaReserva  == null) formaReserva  = "";
if (tipoPaciente  == null) tipoPaciente  = "";
if (fechaNacimiento  == null) fechaNacimiento  = "";
if (codPaciente  == null) codPaciente  = "";
if (sexo  == null) sexo  = "";
if (citasAmb  == null) citasAmb  = "";

boolean allowBackdate = false;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		if (change == null)
		{
			iProc.clear();
			vProc.clear();

			  sbSql = new StringBuffer();
			sbSql.append("select nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'CDC_CITA_BACKDATE'),'N') as backdate,get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'CDC_CITA_TIPO_LABEL') as tipoLabel  from dual");
			 cdoParam = SQLMgr.getData(sbSql.toString());
			if (cdoParam.getColValue("backdate").equalsIgnoreCase("Y") || cdoParam.getColValue("backdate").equalsIgnoreCase("S")) allowBackdate = true;

			cita.setCodigo(codigo);
			cita.setFechaCita(fechaCita);
			cita.setHoraCita(horaCita);
			if (habitacion == null) habitacion = "";
			cita.setHabitacion(habitacion);
			cita.setProbableHospitalizacion("");
			cita.setFecNacimiento("");
			cita.setHospAmb("A");
			cita.setAnestesia("N");
			cita.setSegundaOpinionAprobada("N");
			
            if((citasSopAdm.equalsIgnoreCase("Y") || citasSopAdm.equalsIgnoreCase("S"))||citasAmb.equalsIgnoreCase("S")){
			 CommonDataObject cdoE = new CommonDataObject();
			if(!pacId.trim().equals("")&&!pacId.trim().equals("0")) {
			    cdoE = (CommonDataObject) SQLMgr.getData("select nombre_paciente  from vw_adm_paciente where pac_id ="+pacId);}
              cita.setPacId(pacId);
              cita.setAdmision(noAdmision);
              cita.setCodMedico(codMedico);
              cita.setMedicoNombre(medicoNombre);
              cita.setPersonaReserva(medicoNombre);
              cita.setNombrePaciente(cdoE.getColValue("nombre_paciente"));
              cita.setFormaReserva(formaReserva);
              cita.setTipoPaciente(tipoPaciente);
              cita.setFecNacimiento(fechaNacimiento);
              cita.setCodPaciente(codPaciente);
              
              if (!pasaporte.equals("")){
                 cita.setPasaporte(pasaporte);
              }else{
                cita.setProvincia(provincia);
                cita.setTomo(tomo);
                cita.setAsiento(asiento);
                cita.setSigla(sigla);
                cita.setDCedula(dCedula);
              }
              
            }else {
              cita.setPacId("");
              cita.setTipoPaciente("OUT");
            }
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Citas - '+document.title;
function doSubmit(fName,actionValue){
   setBAction(fName,actionValue);
  if( validateAnestesia() ) window.frames['itemFrame'].doSubmit();
}

function validateAnestesia(){
  var size = document.getElementById('itemFrame').contentWindow.document.getElementById("size").value
  var anestesia = $("#anestesia").val();
  var anestesiologo = $("#anestesiologo").val();
  var procedimientos = [];
  if (anestesia=="S"){
      for (p=0; p<=size; p++){
	    var procedimiento = $('#itemFrame').contents().find('#procedimiento'+p).val();
		if(procedimiento) procedimientos.push("'"+procedimiento+"'");
	  }	
      if(!anestesiologo) CBMSG.warning("Usted escogi� anestesia, por favor recuerda suplir un anaestesiologo por lo menos!");
	  if (procedimientos.length){
		  if(getDBData('<%=request.getContextPath()%>','count(*)','tbl_cds_procedimiento',"codigo in("+procedimientos+") and tipo_maletin_anestesia is not null",'') < 1 ) CBMSG.warning("Cita o cupo marcado para usar anestesia, verificar CPT: no tiene configurado malet�n de anestesia!");
	  } 
  }
  return isAValidateHour();
}

function isAValidateHour(){
<% if (!allowBackdate) { %>
  var _date = $("#fechaCita").val();
  var _hour = $("#hora_cita").val();
  if ( hasDBData('<%=request.getContextPath()%>',"(select case when to_date('"+_date+" "+_hour+"','dd/mm/yyyy hh12:mi am') < sysdate then '1'  else null end b from dual)",'b is not null','') ){
   CBMSG.error("Por favor verificar que la 'D�a/Hora de Cirug�a' no este en blanco o menor a la hora actual!");
   return false;
  }
<% } %>
 return true;
}

function showMedicoList(fg){var sociedad =false;if(fg=='dr_anestesiologo'){  sociedad = document.form0.sociedad.checked;}if(sociedad)abrir_ventana1('../common/search_empresa.jsp?fp=citasAnest&fg='+fg);else abrir_ventana1('../common/search_medico.jsp?fp=citas&fg='+fg);}
function doAction(){CalculateAge();}
function showPacienteList(){abrir_ventana1('../common/search_paciente.jsp?fp=cita');}
function selEmpresa(){abrir_ventana1('../common/search_empresa.jsp?fp=citas');}
function checkPacId(){CalculateAge(); if(document.form0.pacId.value!=''){document.form0.btnPaciente.focus();CBMSG.error('No se puede cambiar los datos del paciente ya que el paciente est� registrado en el sistema!');return false;}return true;}
function validDateTime(){
  var cds=document.form0.cds.value;
  var room=document.form0.habitacion.value;
  var xDate=document.form0.fechaCita.value;
  var xTime=document.form0.hora_cita.value;
  var hour=document.form0.hora_est.value;
  var min=document.form0.min_est.value;
  <% if (!allowBackdate) { %>if(getDBData('<%=request.getContextPath()%>','case when to_date(\''+xDate+'\',\'dd/mm/yyyy\')<trunc(sysdate) then 1 else 0 end','dual','','')==1){CBMSG.warning('La nueva fecha es menor al d�a de hoy!');return false;}<% } %>
  var filter='';if(cds!=null&&cds!='')filter='centro_servicio='+cds;
  
  //if(filter!='')filter+=' and ';filter+='habitacion=\''+room+'\' and estado_cita not in (\'C\',\'T\') and ((hora_cita<=to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') and hora_final>to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\')) or (hora_cita<to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\')+(((coalesce('+hour+',hora_est,0) * 60) + coalesce('+min+',min_est,0)) / (24 * 60)) and hora_final>to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\')+(((coalesce('+hour+',hora_est,0) * 60) + coalesce('+min+',min_est,0)) / (24 * 60))))';
  
  if(filter!='')filter+=' and ';filter+='habitacion=\''+room+'\' and estado_cita not in (\'C\',\'T\') and (hora_cita = to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') or hora_final = to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') + (('+hour+' + ('+min+' / 60)) / 24) or ( hora_cita > to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') and hora_cita < to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') + (('+hour+' + ('+min+' / 60)) / 24) ) or ( hora_final > to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') and hora_final < to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') + (('+hour+' + ('+min+' / 60)) / 24) ) or ( hora_cita < to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') and hora_final > to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') + (('+hour+' + ('+min+' / 60)) / 24) ))';
  
  
  
  if(hasDBData('<%=request.getContextPath()%>','tbl_cdc_cita',filter,'')){CBMSG.warning('La Programaci�n de la Cita choca con otras Citas Programadas.\nPor favor revise la programaci�n!');return false;}return true;}
function validLastTime(){var hour=parseInt(document.form0.hora_est.value,10);var min=parseInt(document.form0.min_est.value,10);if(hour+min<=0){CBMSG.warning('Verifique el Tiempo Total Approximado!');return false;}hour+=parseInt(min/60,10);min=min%60;document.form0.hora_est.value=hour;document.form0.min_est.value=min;return true;}
function clearMedico(){document.form0.medico.value='';document.form0.nombre_medico.value='';}
function clearPaciente(){
	document.form0.pacIdi.value='';
	document.form0.nombre_paciente.value='';}
function setCds(sObj){var cds=getSelectedOptionTitle(sObj,'<%=cds%>');document.form0.cds.value=cds;}

function CalculateAge() {
	var fecha = document.form0.f_nac.value;
	if(fecha!=''){
	if(isValidateDate(document.form0.f_nac.value)){
		var sql = 'nvl(trunc(months_between(sysdate, to_date(\''+fecha+'\', \'dd/mm/yyyy\'))/12),0) || \' A&ntilde;os \' || nvl(mod(trunc(months_between(sysdate, to_date(\''+fecha+'\', \'dd/mm/yyyy\'))),12),0) || \' Meses \' || trunc(sysdate-add_months(to_date(\''+fecha+'\', \'dd/mm/yyyy\'),(nvl(trunc(months_between(sysdate,to_date(\''+fecha+'\', \'dd/mm/yyyy\'))/12),0)*12+nvl(mod(trunc(months_between(sysdate,to_date(\''+fecha+'\', \'dd/mm/yyyy\'))),12),0)))) || \' Dias \'';
		var data = splitRowsCols(getDBData('<%=request.getContextPath()%>',sql,'dual','',''));
		document.getElementById('lbl_edad').innerHTML = data;
	}else CBMSG.warning('Valor Invalido en Fecha Nacimiento!!');}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CITA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("habCds",habCds)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("citasSopAdm",citasSopAdm)%>
<%=fb.hidden("citasAmb",citasAmb)%>
<%if ((citasSopAdm.equals("Y") || citasSopAdm.equals("S"))||citasAmb.equals("S")){%>
<%=fb.hidden("nombreMedico", medicoNombre)%> 
<%=fb.hidden("f_nac", fechaNacimiento)%>
<%=fb.hidden("codigo_paciente", codPaciente)%>
<%}%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("baction","")%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Transacci&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="10%" align="right">
								<%//=(fp.equalsIgnoreCase("imagenologia"))?"M&eacute;dico":"M&eacute;dico/Persona Que Reserva"%>
								<%if(fp.equalsIgnoreCase("imagenologia")){%> 
								   <cellbytelabel>M&eacute;dico</cellbytelabel>
								<%}else{%>
								  <cellbytelabel>M&eacute;dico/Persona Que Reserva</cellbytelabel>
								<%}%>
							</td>
							<td colspan="3">
								<%=fb.textBox("medico",cita.getCodMedico(),false,false,true,5,"Text10","","onDblClick=\"javascript:clearMedico();\"")%>								
								<%=fb.textBox("nombre_medico",cita.getMedicoNombre(),false,false,viewMode,40,"Text10","","onDblClick=\"javascript:clearMedico();\"")%>
								<%=fb.button("btnMedico","...",true,viewMode,"Text10",null,"onClick=\"javascript:showMedicoList('dr_reserva')\"")%>
								<%=(!fp.equalsIgnoreCase("imagenologia"))?fb.textBox("persona_reserva",cita.getPersonaReserva(),true,false,viewMode,40,"Text10","",""):""%>
							</td>
							<td width="10%" align="right"><cellbytelabel>Forma</cellbytelabel></td>
							<td width="15%"><%=fb.select("forma_reserva","T=TELEFONICA,P=PERSONALMENTE,E=E-MAIL",cita.getFormaReserva(),false,viewMode,0,"Text10","","")%></td>
							<td width="10%" align="right"><cellbytelabel>Tipo Cita</cellbytelabel></td>
							<td width="15%"><%=fb.select("cita_cirugia","E=ELECTIVA,U=URGENCIA",cita.getCitaCirugia(),false,viewMode,0,"Text10","","")%></td>
						</tr>
						<tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>M&eacute;dico Referente</cellbytelabel></td>
							<td colspan="7">
								<%=fb.textBox("nombre_medico_externo",cita.getNombreMedExterno(),false,false,viewMode,50,"Text10","","")%>
							</td>
						</tr>
<%
if (fp.equalsIgnoreCase("imagenologia"))
{
%>

<%=fb.hidden("noAdmision",cita.getAdmision())%>
<%=fb.hidden("provincia",cita.getProvincia())%>
<%=fb.hidden("sigla",cita.getSigla())%>
<%=fb.hidden("tomo",cita.getTomo())%>
<%=fb.hidden("asiento",cita.getAsiento())%>
<%=fb.hidden("fec_nacimiento",cita.getFecNacimiento())%>
<%=fb.hidden("f_nac",cita.getFecNacimiento())%>
<%=fb.hidden("cod_paciente",cita.getCodPaciente())%>
<%=fb.hidden("d_cedula",cita.getDCedula())%> 

<tr class="TextRow01">
<td align="right"><cellbytelabel>Paciente</cellbytelabel></td>

<td colspan="3">
<%=fb.textBox("pacId",cita.getPacId(),false,false,true,5,"Text10","","")%>
<%=fb.textBox("nombre_paciente",cita.getNombrePaciente(),true,false,(viewMode||(citasSopAdm.equals("S")||citasSopAdm.equals("Y"))||citasAmb.equals("S")),40,"Text10","","onDblClick=\"javascript:clearPaciente();\"")%>
 <%=fb.button("btnPaciente","...",true,viewMode,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
&nbsp;&nbsp;<strong>C&oacute;d. Ref.:&nbsp;<span id="cod_ref"><%=cita.getCodigoReferencia()%></span></strong>
</td>
<td align="right"><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
<td><%=fb.textBox("telefono",cita.getTelefono(),false,false,viewMode,15,"Text10","","")%></td>
<td align="right"><cellbytelabel>Tipo Paciente</cellbytelabel></td>
<td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cdc_tipo_paciente where status = 'A'","tipo_paciente",cita.getTipoPaciente(),false,viewMode,0,"Text10","","")%></td>
</tr>
<%
}
else
{
%>
<tr class="TextRow01">
<td align="right"><cellbytelabel>Paciente</cellbytelabel></td>
<td colspan="3">
<%if ((citasSopAdm.equals("Y") || citasSopAdm.equals("S"))||citasAmb.equals("S")){%>
  <%=fb.intBox("pacId",cita.getPacId(),false,false,true,10,"Text10",null,"")%>
  -<%=fb.intBox("noAdmision",cita.getAdmision(),false,false,true,4,"Text10",null,"")%>
<%}else{%>
<%=fb.intBox("pacId",cita.getPacId(),false,false,true,10,"Text10",null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','pacId,cod_paciente')\"")%>
<%}%>


<%=fb.textBox("nombre_paciente",cita.getNombrePaciente(),true,false,(viewMode||(citasSopAdm.equals("S")||citasSopAdm.equals("Y"))||citasAmb.equals("S")),40,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
<%=fb.button("btnPaciente","...",true,(viewMode||(citasSopAdm.equals("S")||citasSopAdm.equals("Y"))||citasAmb.equals("S")),"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
&nbsp;&nbsp;<strong>C&oacute;d. Ref.:&nbsp;<span id="cod_ref"><%=cita.getCodigoReferencia()%></span></strong>
</td>
<td align="right"><cellbytelabel>No. C&eacute;dula</cellbytelabel></td>
							<td colspan="1">
								<%=fb.intBox("provincia",cita.getProvincia(),false,false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")),2,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
								<%=fb.textBox("sigla",cita.getSigla(),false,false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")),2,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
								<%=fb.intBox("tomo",cita.getTomo(),false,false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")),4,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
								<%=fb.intBox("asiento",cita.getAsiento(),false,false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")),5,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
								<%=fb.select("d_cedula","D=D,R=R,H1=H1,H2=H2,H3=H3,H4=H4,H5=H5",cita.getDCedula(),false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")),0,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
							</td>
							<td align="right"><cellbytelabel>Tipo Paciente</cellbytelabel></td>
<td><%=fb.select("tipo_paciente","IN=PACIENTE HOSPITALIZADA,OUT=PACIENTE EXTERNO,UR=URGENCIA,AM=AMBULATORIO",cita.getTipoPaciente(),false,viewMode,0,"Text10","","")%></td>
</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Fecha Nac</cellbytelabel>.</td>
							<td width="10%">
							<%=fb.hidden("fec_nacimiento",cita.getFecNacimiento())%>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="f_nac" />
									<jsp:param name="valueOfTBox1" value="<%=cita.getFecNacimiento()%>" />
									<jsp:param name="format" value="dd/mm/yyyy" />
									<jsp:param name="fieldClass" value="Text10" />
									<jsp:param name="buttonClass" value="Text10" />
									<jsp:param name="readonly" value="<%=(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S"))?"y":"n"%>" />
									<jsp:param name="appendOnClickEvt" value="if(!checkPacId())return false;" />
									<jsp:param name="appendOnFocus" value="checkPacId();" />
								</jsp:include>
								<cellbytelabel id="5">Edad:</cellbytelabel>
								<label id="lbl_edad">&nbsp;</label>
							</td>
							<td width="15%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="15%"><%=fb.intBox("cod_paciente",cita.getCodPaciente(),false,false,true,10,"Text10","","onFocus=\"javascript:checkPacId()\"")%></td>
							<td align="right"><cellbytelabel>Pasaporte</cellbytelabel></td>
							<td><%=fb.textBox("pasaporte",cita.getPasaporte(),false,false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")),15,"Text10","","")%></td>
							<td align="right">Fecha Cirug&iacute;a</td>
							<td>
                                <%if((!citasSopAdm.equals("S")||!citasSopAdm.equals("Y"))||!citasAmb.equals("S")){%>
                                    <%=fb.textBox("fechaCita",cita.getFechaCita(),false,true,true,10,"Text10","","")%>
                                <%}%>
								<%if(cdoParam.getColValue("tipoLabel").equalsIgnoreCase("H")){%>
								Hora
                                <jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="clearOption" value="true"/>
									<jsp:param name="nameOfTBox1" value="hora_cita"/>
									<jsp:param name="valueOfTBox1" value="<%=cita.getHoraCita()%>"/>
									<jsp:param name="format" value="hh12:mi am"/>
									<jsp:param name="fieldClass" value="Text10 FormDataObjectRequired"/>
									<jsp:param name="buttonClass" value="Text10"/>
									<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
								</jsp:include>
								<%}else{ %>
								<%=fb.hidden("hora_cita","08:01 am")%>
								<%}%>
							</td>
						</tr>
<%
}
%>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>C&iacute;a. Seguro</cellbytelabel></td>
							<td colspan="3">
								<%=fb.intBox("empresa",cita.getEmpresa(),false,false,true,5,"Text10","","")%>
								<%=fb.textBox("empresa_desc",cita.getEmpresaNombre(),false,false,true,50,"Text10","","")%>
								<%=fb.button("btnEmpresa","...",true,viewMode,"Text10",null,"onClick=\"javascript:selEmpresa()\"")%>
							</td>
<%
if (fp.equalsIgnoreCase("imagenologia"))
{
%>
							<td align="right"><cellbytelabel>Sala/Cuarto (ubicaci&oacute;n)</cellbytelabel></td>
							<td><%=fb.textBox("cuarto",cita.getCuarto(),false,viewMode,viewMode,12,15,"Text10","","")%></td>
							<td align="right">Hora Cirug&iacute;a</td>
							<td><%=fb.textBox("fechaCita",cita.getFechaCita(),false,true,true,10,"Text10","","")%>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="hora_cita" />
									<jsp:param name="valueOfTBox1" value="<%=cita.getHoraCita()%>" />
									<jsp:param name="format" value="hh12:mi am" />
									<jsp:param name="fieldClass" value="Text10 FormDataObjectRequired" />
									<jsp:param name="buttonClass" value="Text10" />
									<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>" />
								</jsp:include>
							</td>
<%
}
else
{
%>
							<td align="right"><cellbytelabel>Persona que llam&oacute;</cellbytelabel></td>
							<td colspan="1"><%=fb.textBox("persona_q_llamo",cita.getPersonaQLlamo(),false,false,viewMode,40,"Text10","","")%></td>
              <td align="right"><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
              <td><%=fb.textBox("telefono",cita.getTelefono(),false,false,viewMode,15,"Text10","","")%></td>
<%
}
%>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
							<td colspan="7"><%=fb.textarea("observacion",cita.getObservacion(),false,false,viewMode,100,2,2000)%></td>
						</tr>
<%
if (fp.equalsIgnoreCase("imagenologia"))
{
%>
						<%=fb.hidden("habitacion",cita.getHabitacion())%>
						<%=fb.hidden("cod_tipo","3")%>
						<%=fb.hidden("hosp_amb","A")%>
<%
}
else
{
%>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Quir&oacute;fano</cellbytelabel></td>
							<td colspan="2">
 					<%	
			    sbSql = new StringBuffer();		
				sbSql.append(" select codigo, descripcion, nvl(centro_servicio,unidad_admin) as cds from tbl_sal_habitacion a where quirofano=2 and compania=");
				sbSql.append(session.getAttribute("_companyId"));
				if(!UserDet.getUserProfile().contains("0"))
				{
					sbSql.append(" and exists ( select null from tbl_sec_user_quirofano x where x.habitacion = a. codigo and x.compania=a.compania and x.user_id=");
						 
					sbSql.append(UserDet.getUserId());
					sbSql.append(")");
				} 
				
				%>
							<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"habitacion",cita.getHabitacion(),false,viewMode,0,"Text10","","onChange=\"javascript:setCds(this)\"")%>
              </td>
							<td align="right"><!--Sala/Cuarto (ubicaci&oacute;n)--></td>
							<td><%//=fb.textBox("cuarto",cita.getCuarto(),false,viewMode,viewMode,12,15,"Text10","","")%></td>
							<td align="right"><cellbytelabel>Clasificaci&oacute;n</cellbytelabel></td>
							<td colspan="2"><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cdc_tipo_cita","cod_tipo",cita.getCodTipo(),false,viewMode,0,"Text10","","")%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><!--II Opini&oacute;n aprob.--></td>
							<td><%=fb.hidden("segunda_opinion_aprobada","N")%><%//=fb.select("segunda_opinion_aprobada","S=SI,N=NO",cita.getSegundaOpinionAprobada(),false,viewMode,0,"Text10","","")%></td>
							<td align="right"><cellbytelabel>Anestesia</cellbytelabel>?</td>
							<td><%=fb.select("anestesia","S=SI,N=NO",cita.getAnestesia(),false,viewMode,0,"Text10","","")%></td>
							<td align="right"><cellbytelabel>Anestesi&oacute;logo</cellbytelabel></td>
							<td colspan="3">
								Sociedad????<%=fb.checkbox("sociedad","S",(cita.getXtra2().equals("S")),viewMode,"","","","")%>
								<%=fb.textBox("anestesiologo",cita.getAnestesiologo(),false,false,true,10,"Text10","","")%>
								<%=fb.textBox("anestesiologoNombre",cita.getAnestesiologoNombre(),false,false,true,40,"Text10","","")%>
								<%=fb.button("btnMedicoAnes","...",true,viewMode,"Text10",null,"onClick=\"javascript:showMedicoList('dr_anestesiologo')\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Tipo Atenci&oacute;n o Admisi&oacute;n</cellbytelabel></td>
							<td><%=fb.select("hosp_amb","H=HOSPITALIZADA,A=AMBULATORIA",cita.getHospAmb(),false,viewMode,0,"Text10","","")%></td>
							<td colspan="2" align="right"><cellbytelabel>Probable Hospitalizaci&oacute;n</cellbytelabel>?</td>
							<td><%=fb.checkbox("probable_hospitalizacion","S",(cita.getProbableHospitalizacion().equals("S")),viewMode,"","","","")%></td>
							<td colspan="3" align="right">&nbsp;</td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr> 
				<tr> 
					<td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../cita/reg_cita_det.jsp?mode=<%=mode%>&fp=<%=fp%>&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>"></iframe></td>
				</tr>
				<tr class="TextRow02" align="center">
					<td align="center"><%if(cdoParam.getColValue("tipoLabel").equalsIgnoreCase("H")){%>
						<cellbytelabel>Tiempo total Aprox</cellbytelabel>.
						
						<%=fb.intBox("hora_est",cita.getHoraEst(),true,false,viewMode,2,2)%> Hrs.
						<%=fb.intBox("min_est",cita.getMinEst(),true,false,viewMode,2,2)%> Min.
						<%}else{%>
						<%=fb.hidden("hora_est","0")%>
						<%=fb.hidden("min_est","1")%>
						<%}%>
						
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%if(!fp.equalsIgnoreCase("imagenologia")){%>
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
            <%}%>
						<%=fb.radio("saveOption","C",true,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'){if(document."+fb.getFormName()+".hora_cita.value.trim()==''){CBMSG.warning('Por favor indicar la Hora de Cirug�a!');error++;}else if(error==0){if(!validDateTime())error++;else if(!validLastTime())error++;}}");%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				</table>
			</td>
		</tr>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
		codigo = cita.getCodigo();
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
<%
	if (saveOption.equalsIgnoreCase("N")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('viewMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
		if (fp.equalsIgnoreCase("imagenologia"))
		{
%>
	window.opener.location.reload(true);
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/cita/quirofano_list.jsp?citasSopAdm=<%=citasSopAdm%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombreMedico=<%=medicoNombre%>&medico=<%=codMedico%>&forma_reserva=<%=formaReserva%>&provincia=<%=provincia%>&sigla=<%=sigla%>&tomo=<%=tomo%>&asiento=<%=asiento%>&d_cedula=<%=dCedula%>&pasaporte=<%=pasaporte%>&tipo_paciente=<%=tipoPaciente%>&f_nac=<%=fechaNacimiento%>&codigo_paciente=<%=codPaciente%>&sexo=<%=sexo%>';
<%
		}
%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fp=<%=fp%>&habitacion=<%=habitacion%>&fechaCita=<%=fechaCita%>&cds=<%=cds%>&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombreMedico=<%=medicoNombre%>&medico=<%=codMedico%>&forma_reserva=<%=formaReserva%>&provincia=<%=provincia%>&sigla=<%=sigla%>&tomo=<%=tomo%>&asiento=<%=asiento%>&d_cedula=<%=dCedula%>&pasaporte=<%=pasaporte%>&tipo_paciente=<%=tipoPaciente%>&f_nac=<%=fechaNacimiento%>&codigo_paciente=<%=codPaciente%>&sexo=<%=sexo%>';
}

function viewMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&fp=<%=fp%>&codigo=<%=codigo%>&fechaRegistro=<%//=fechaRegistro%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>