<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.FactTransaccion"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
tr2 utilizada para filtrar los paciente de hemodialisis.
==================================================================================
**/
/*
SecMgr.setConnection(ConMgr);
CmnMgr.setConnection(ConMgr);
*/
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = null;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String pacienteId = request.getParameter("pacienteId");
String admisionNo = request.getParameter("admisionNo");
String fg = request.getParameter("tr");
String fp = request.getParameter("fp");
String tr2 = request.getParameter("tr2");

String mode = request.getParameter("mode");
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

String compReplica = "", compFar = "";
try {compReplica = java.util.ResourceBundle.getBundle("farmacia").getString("compReplica");}catch(Exception e){compReplica="";}
try {compFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar");}catch(Exception e){compFar="";}
String compania =(String) session.getAttribute("_companyId");
if(compFar.trim().equals((String) session.getAttribute("_companyId")))compania=compReplica;

if (pacienteId == null) pacienteId = "";
if (admisionNo == null) admisionNo = "";
if (fg == null) fg = "PAC_S";
if (fp == null) fp = "";
if (tr2 == null) tr2 = "";

if (!pacienteId.trim().equals("") && !admisionNo.trim().equals("")) {

	CommonDataObject p = SQLMgr.getData("select nvl(get_sec_comp_param(-1,'INT_HIS_DB_LINK'),'-') as dblink from dual");

	sbSql.append("select a.pac_id, nvl(a.embarazada,' ') as embarazada, a.codigo_paciente, a.secuencia as no_admision, to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fecha_ingreso, decode(a.dias_estimados,null,' ',a.dias_estimados) as dias_estimados, a.estado, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA','I','INACTIVA') as desc_estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fecha_egreso, a.categoria, a.tipo_admision, a.medico, a.centro_servicio, to_char(nvl(a.am_pm,sysdate),'hh12:mi:ss am') as amPm, nvl(a.hosp_directa,' ') as hosp_directa, nvl(a.medico_cabecera,' ') as medico_cabecera, a.responsabilidad");
	sbSql.append(", (select exp_id from vw_adm_paciente where pac_id = a.pac_id) as exp_id");
	sbSql.append(", (select nvl(religion,0) from vw_adm_paciente where pac_id = a.pac_id) as religion");
	sbSql.append(", (select nvl(comida_id,0) from vw_adm_paciente where pac_id = a.pac_id) as comida");
	sbSql.append(", (select to_char(fecha_nacimiento,'dd/mm/yyyy') from vw_adm_paciente where pac_id = a.pac_id) as fecha_nacimiento");
	sbSql.append(", (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = a.pac_id) as f_nac");
	sbSql.append(", get_age((select f_nac from vw_adm_paciente where pac_id = a.pac_id),nvl(a.fecha_ingreso,a.fecha_creacion),null) as edad");
	sbSql.append(", get_age((select f_nac from vw_adm_paciente where pac_id = a.pac_id),nvl(a.fecha_ingreso,a.fecha_creacion),'mm') as edad_mes");
	sbSql.append(", get_age((select f_nac from vw_adm_paciente where pac_id = a.pac_id),nvl(a.fecha_ingreso,a.fecha_creacion),'dd') as edad_dias");
	sbSql.append(", (select decode(provincia,null,' ',provincia) from vw_adm_paciente where pac_id = a.pac_id) as provincia");
	sbSql.append(", (select nvl(sigla,' ') from vw_adm_paciente where pac_id = a.pac_id) as sigla");
	sbSql.append(", (select decode(tomo,null,' ',tomo) from vw_adm_paciente where pac_id = a.pac_id) as tomo");
	sbSql.append(", (select decode(asiento,null,' ',asiento) from vw_adm_paciente where pac_id = a.pac_id) as asiento");
	sbSql.append(", (select nvl(d_cedula,' ') from vw_adm_paciente where pac_id = a.pac_id) as d_cedula");
	sbSql.append(", (select nvl(pasaporte,' ') from vw_adm_paciente where pac_id = a.pac_id) as pasaporte");
	sbSql.append(", (select primer_nombre from vw_adm_paciente where pac_id = a.pac_id) as primer_nombre");
	sbSql.append(", (select nvl(segundo_nombre,' ')from vw_adm_paciente where pac_id = a.pac_id) as segundo_nombre");
	sbSql.append(", (select nvl(primer_apellido,' ') from vw_adm_paciente where pac_id = a.pac_id) as primer_apellido");
	sbSql.append(", (select nvl(segundo_apellido,' ') from vw_adm_paciente where pac_id = a.pac_id) as segundo_apellido");
	sbSql.append(", (select nvl(apellido_de_casada,' ') from vw_adm_paciente where pac_id = a.pac_id) as apellido_de_casada");
	sbSql.append(", (select nvl(sexo,' ') from vw_adm_paciente where pac_id = a.pac_id) as sexo");
	sbSql.append(", (select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id) as nombre_paciente");
	sbSql.append(", (select decode(pasaporte,null,provincia||'-'||sigla||'-'||tomo||'-'||asiento,pasaporte)||decode(d_cedula,'D',null,'-'||d_cedula) from vw_adm_paciente where pac_id = a.pac_id) as cedulaPasaporte");
	sbSql.append(", (select id_paciente from vw_adm_paciente where pac_id = a.pac_id) as id_paciente");
	sbSql.append(", (select residencia_direccion from vw_adm_paciente where pac_id = a.pac_id) as residencia_direccion");
	sbSql.append(", (select telefono from vw_adm_paciente where pac_id = a.pac_id) as telefono");
	sbSql.append(", (select vip from vw_adm_paciente where pac_id = a.pac_id) as vip");
	sbSql.append(", (select decode(vip,'S','VIP','N','NORMAL','D','DISTINGUIDO','J','JUNTA DIRECTIVA','M','MEDICO STAFF','NO IDENTIFICADO') from vw_adm_paciente where pac_id = a.pac_id) as vip_dsp");
	sbSql.append(", nvl((select cama from tbl_adm_atencion_cu z where z.pac_id = a.pac_id and z.secuencia = a.secuencia),' ') as cama");
	sbSql.append(", nvl((select getExt(cama,a.compania) from tbl_adm_atencion_cu z where z.pac_id = a.pac_id and z.secuencia = a.secuencia),' ') as extension");
	sbSql.append(", nvl((select ''||cds from tbl_adm_atencion_cu z where z.pac_id = a.pac_id and z.secuencia = a.secuencia),' ') as cds_atencion");
	sbSql.append(", nvl((select (select descripcion from tbl_cds_centro_servicio where codigo = z.cds) from tbl_adm_atencion_cu z where z.pac_id = a.pac_id and z.secuencia = a.secuencia),' ') as cds_atencion_desc");
	sbSql.append(", (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as categoria_desc");
	sbSql.append(", (select descripcion from tbl_adm_tipo_admision_cia where compania = a.compania and categoria = a.categoria and codigo = a.tipo_admision) as tipo_admision_desc");
	sbSql.append(", (select decode(sexo,'F','DRA. ','DR. ')||primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico) as nombre_medico");
	sbSql.append(", (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre) from tbl_adm_medico where codigo = a.medico) as medico_nombres");
	sbSql.append(", (select primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico) as medico_apellidos");
	sbSql.append(", (select nvl((select (select descripcion from tbl_adm_especialidad_medica where codigo = y.especialidad) from tbl_adm_medico_especialidad y where y.medico = z.codigo and y.secuencia = 1),'NO TIENE') from tbl_adm_medico z where z.codigo = a.medico) as especialidad");
	sbSql.append(", nvl((select decode(sexo,'F','DRA. ','DR. ')||primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico_cabecera),' ') as nombre_medico_cabecera");
	sbSql.append(", (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) as centro_servicio_desc");
	sbSql.append(", nvl((select z.empresa from tbl_adm_beneficios_x_admision z where z.pac_id = a.pac_id and z.admision = a.secuencia and nvl(z.estado,'A') = 'A' and z.prioridad = 1 and rownum = 1),0) as empresa");
	sbSql.append(", nvl((select (select clasificacion from tbl_adm_empresa where codigo = z.empresa) from tbl_adm_beneficios_x_admision z where z.pac_id = a.pac_id and z.admision = a.secuencia and nvl(z.estado,'A') = 'A' and z.prioridad = 1 and rownum = 1),' ') as clasificacion");
	sbSql.append(", nvl((select (select nombre from tbl_adm_empresa where codigo = z.empresa) from tbl_adm_beneficios_x_admision z where z.pac_id = a.pac_id and z.admision = a.secuencia and nvl(z.estado,'A') = 'A' and z.prioridad = 1 and rownum = 1),' ') as empresa_nombre");
	sbSql.append(", nvl((select (select descuento from tbl_adm_empresa where codigo = z.empresa) from tbl_adm_beneficios_x_admision z where z.pac_id = a.pac_id and z.admision = a.secuencia and nvl(z.estado,'A') = 'A' and z.prioridad = 1 and rownum = 1),'N') as descuento");
	sbSql.append(", nvl((select (select cambio_precio from tbl_adm_empresa where codigo = z.empresa) from tbl_adm_beneficios_x_admision z where z.pac_id = a.pac_id and z.admision = a.secuencia and nvl(z.estado,'A') = 'A' and z.prioridad = 1 and rownum = 1),' ') as cambioPrecio");
sbSql.append(",(select nvl(reg_medico,codigo) as reg_medico from tbl_adm_medico where codigo = a.medico_cabecera ) as reg_medico_cab ");
sbSql.append(",(select nvl(reg_medico,codigo) as reg_medico from tbl_adm_medico where codigo = a.medico ) as reg_medico ");
	sbSql.append(", decode(a.pac_id_ref,null,' ',''||a.pac_id_ref) as pac_id_ref, decode(a.admision_ref,null,' ',''||a.admision_ref) as admision_ref");
	if (p.getColValue("dblink").equals("-")) sbSql.append(", ' ' as estado_ref");
	else {

		sbSql.append(", (select decode(estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA','I','INACTIVA') from tbl_adm_admision");
		sbSql.append(p.getColValue("dblink"));
		sbSql.append(" where pac_id = a.pac_id_ref and secuencia = a.admision_ref) as estado_ref");

	}

	sbSql.append(" from tbl_adm_admision a where a.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and a.secuencia = ");
	sbSql.append(admisionNo);
	cdo = SQLMgr.getData(sbSql.toString());

}

if (cdo == null) {

	cdo = new CommonDataObject();
	cdo.addColValue("edad_mes","0");
	cdo.addColValue("edad_dias","0");
	cdo.addColValue("edad","0");
	cdo.addColValue("vip","S/I");
	cdo.addColValue("pac_id_ref","");
	cdo.getColValue("admision_ref","");
	cdo.getColValue("estado_ref","");

}
%>
<script language="javascript">
function showPacienteList(){
	abrir_ventana1('../common/sel_paciente.jsp?fp=<%=fp%>&fg=<%=fg%>&tr2=<%=tr2%>');
}
function showMedicoList(){
	abrir_ventana1('../common/search_medico.jsp?fp=<%=fp%>&fg=<%=fg%>');
}
function getPacienteInfo(patientRequired){if(patientRequired==undefined)patientRequired=true;var pacId=document.paciente.pacienteId.value.trim();var admision=document.paciente.admSecuencia.value.trim();var dob=document.paciente.fechaNacimiento.value.trim();var pacCode=document.paciente.codigoPaciente.value.trim();var jubilado=document.paciente.jubilado.checked;var invalid=(pacId==''||admision=='');if(invalid&&patientRequired)alert('Seleccione el paciente!');return {isValid:!invalid,pacId:pacId,admision:admision,dob:dob,pacCode:pacCode,jubilado:jubilado}}
</script>

<table width="100%" cellpadding="0" cellspacing="1" class="pure-table">
	<%fb = new FormBean("paciente",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("embarazada",cdo.getColValue("embarazada"))%>
	<%=fb.hidden("edad",cdo.getColValue("edad"))%>
	<%=fb.hidden("edad_mes",cdo.getColValue("edad_mes"))%>
	<%=fb.hidden("edad_dias",cdo.getColValue("edad_dias"))%>
	<%=fb.hidden("provincia",cdo.getColValue("provincia"))%>
	<%=fb.hidden("sigla",cdo.getColValue("sigla"))%>
	<%=fb.hidden("tomo",cdo.getColValue("tomo"))%>
	<%=fb.hidden("asiento",cdo.getColValue("asiento"))%>
	<%=fb.hidden("dCedula",cdo.getColValue("d_cedula"))%>
	<%=fb.hidden("pasaporte",cdo.getColValue("pasaporte"))%>
	<%=fb.hidden("primerNombre",cdo.getColValue("primer_nombre"))%>
	<%=fb.hidden("segundoNombre",cdo.getColValue("segundo_nombre"))%>
	<%=fb.hidden("primerApellido",cdo.getColValue("primer_apellido"))%>
	<%=fb.hidden("segundoApellido",cdo.getColValue("segundo_apellido"))%>
	<%=fb.hidden("apellidoDeCasada",cdo.getColValue("apellido_de_casada"))%>
	<%//=fb.hidden("sexo",cdo.getColValue("sexo"))%>
	<%=fb.hidden("residenciaDireccion",cdo.getColValue("residencia_direccion"))%>
	<%=fb.hidden("telefono",cdo.getColValue("telefono"))%>
	<%=fb.hidden("estado",cdo.getColValue("estado"))%>
	<%=fb.hidden("desc_estado",cdo.getColValue("desc_estado"))%>
	<%=fb.hidden("numFactura",cdo.getColValue("numFactura"))%>
		<%=fb.hidden("empresa",cdo.getColValue("empresa"))%>
		<%=fb.hidden("clasificacion",cdo.getColValue("clasificacion"))%>
	<%=fb.hidden("descuento",cdo.getColValue("descuento"))%>
	<%=fb.hidden("cambioPrecio",cdo.getColValue("cambioPrecio"))%>
	<%=fb.hidden("empresaNombre",cdo.getColValue("empresa_nombre"))%>
	<%=fb.hidden("fechaEgreso",cdo.getColValue("fecha_egreso"))%>
	<%=fb.hidden("pacienteId",cdo.getColValue("pac_id"))%>
	<%=fb.hidden("cedulaPasaporte",cdo.getColValue("cedulaPasaporte"))%>

		<%//=fb.hidden("expedienteId",cdo.getColValue("exp_id"))%>
	<tr class="TextResultRowsWhite">
		<td align="left" colspan="9">
		<cellbytelabel id="1">ExpId</cellbytelabel>
		<%=fb.intBox("expedienteId",cdo.getColValue("exp_id"),false,false,true,3,"Text10",null,null)%>
		<cellbytelabel id="2">Nombre</cellbytelabel>
		 <%
			String idF = cdo.getColValue("vip");
			String cssClass = "";
			if (idF.trim().equals("S")) cssClass = " vip-vip";
			else if (idF.trim().equals("D")) cssClass = " vip-dis";
			else if (idF.trim().equals("J")) cssClass = " vip-jd";
			else if (idF.trim().equals("M")) cssClass = " vip-med";
			if (idF != null && !idF.trim().equals("") && !idF.trim().equals("N")){
		 %>
		<span style="cursor:pointer" class="vip<%=cssClass%>" title="<%=cdo.getColValue("vip_dsp")%>" >
		&nbsp;
		</span>
		<%}%>

		<%=fb.textBox("nombrePaciente",cdo.getColValue("nombre_paciente"),!viewMode,false,true,30,"Text10",null,null)%>
		<%=fb.button("btnPaciente","...",true,viewMode,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
			<%=fb.hidden("codigoPaciente",cdo.getColValue("codigo_paciente"))%>
			<cellbytelabel id="3">C&eacute;d/Pasa.</cellbytelabel>
			<%=fb.textBox("id_paciente",cdo.getColValue("id_paciente"),false,false,true,16,"Text10",null,null)%>
			<cellbytelabel id="4">Fecha Nac.</cellbytelabel>
			<%=fb.hidden("fechaNacimiento",cdo.getColValue("fecha_nacimiento"))%>
			<%=fb.textBox("fNacimiento",cdo.getColValue("f_nac"),false,false,true,9,"Text10",null,null)%>
			<cellbytelabel id="5">Edad</cellbytelabel>
			<label id="lbl_edad"><%=cdo.getColValue("edad")%></label>
			<cellbytelabel id="6">a</cellbytelabel>&nbsp;
			<label id="lbl_edad_mes"><%=cdo.getColValue("edad_mes")%></label>
			<cellbytelabel id="7">m</cellbytelabel>&nbsp;
			<label id="lbl_edad_dias"><%=cdo.getColValue("edad_dias")%></label>
			<cellbytelabel id="8">d</cellbytelabel>&nbsp;<cellbytelabel id="9">Sexo</cellbytelabel>&nbsp;<%=fb.textBox("sexo",cdo.getColValue("sexo"),false,false,true,1,"Text10",null,null)%>
			<cellbytelabel id="10">Jubilado</cellbytelabel> <%=fb.checkbox("jubilado",cdo.getColValue("Jubilado"),false,viewMode)%>
		 <cellbytelabel id="11">Comida</cellbytelabel> <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from TBL_ADM_comida ","comida",cdo.getColValue("comida"),false,true,0,"Text10",null,null,"","")%>
			</td>
	</tr>
	<tr class="TextResultRowsWhite">
		<td align="left" colspan="8">
		<cellbytelabel id="12">No. Adm.</cellbytelabel>
		<%=fb.intBox("admSecuencia",cdo.getColValue("no_admision"),false,false,true,3,"Text10",null,null)%>
		<cellbytelabel id="13">Ingreso</cellbytelabel>&nbsp;
		<%=fb.textBox("fechaIngreso",cdo.getColValue("fecha_ingreso"),!viewMode,false,true,10,"Text10",null,null)%>
		<%=fb.select("mesCta","ENE=ENERO,FEB=FEBRERO,MAR=MARZO,ABR=ABRIL,MAY=MAYO,JUN=JUNIO,JUL=JULIO,AGO=AGOSTO,SEP=SEPTIEMBRE,OCT=OCTUBRE,NOV=NOVIEMBRE,DIC=DICIEMBRE",cdo.getColValue("mes_cta"),false,true,0,"Text10",null,null,"","S")%>&nbsp;
		<cellbytelabel id="14">Cama</cellbytelabel>&nbsp;
		<%=fb.textBox("cama",cdo.getColValue("cama"),false,false,true,6,"Text10",null,null)%>
		Ext.&nbsp;
		<%=fb.textBox("extension",cdo.getColValue("extension"),false,false,true,6,"Text10",null,null)%>
		Area/Centro Adm.&nbsp;
		<%=fb.textBox("cds",cdo.getColValue("centro_servicio"),false,false,true,2,"Text10",null,null)%>
		<%=fb.textBox("cdsDesc",cdo.getColValue("centro_servicio_desc"),false,false,true,15,"Text10",null,null)%>
			<cellbytelabel id="16">Categor&iacute;a</cellbytelabel>&nbsp;
			<%=fb.intBox("categoria",cdo.getColValue("categoria"),!viewMode,false,true,1,"Text10",null,null)%>
			<%=fb.textBox("categoriaDesc",cdo.getColValue("categoria_desc"),!viewMode,false,true,20,"Text10",null,null)%>
	</td>
	</tr>

	<tr class="TextResultRowsWhite">
		<td width="81%" align="left"><%
	if(fp.equals("mat_paciente") && fg.equals("SOP")){
	%>
			<cellbytelabel id="17">M&eacute;dico que ejecuta la cirug&iacute;a</cellbytelabel>
			<%} else {%>
			<cellbytelabel id="18">M&eacute;dico Atiende</cellbytelabel>
			<%}%>
			<%=fb.hidden("medico",cdo.getColValue("medico"))%>
			<%=fb.textBox("reg_medico",cdo.getColValue("reg_medico"),false,false,true,4,"Text10",null,null)%>
			<%=fb.textBox("nombreMedico",cdo.getColValue("nombre_medico"),false,false,true,34,"Text10",null,null)%>
			<%=fb.hidden("medicoNombres",cdo.getColValue("medico_nombres"))%>
			<%=fb.hidden("medicoApellidos",cdo.getColValue("medico_apellidos"))%>
			<%
			if(fp.equals("mat_paciente") && fg.equals("SOP")){
			%>
			<%=fb.button("btnMedico","...",true,viewMode,null,"Text10","onClick=\"javascript:showMedicoList()\"")%>
			<%}%>
			<cellbytelabel id="19">M&eacute;dico Cabecera</cellbytelabel>
			<%=fb.hidden("medicoCabecera",cdo.getColValue("medico_cabecera"))%>
			<%=fb.textBox("reg_medico_cab",cdo.getColValue("reg_medico_cab"),false,false,true,4,"Text10",null,null)%>

			<%=fb.textBox("nombreMedicoCabecera",cdo.getColValue("nombre_medico_cabecera"),false,false,true,34,"Text10",null,null)%>
		</td>
	 <td width="19%" align="left"><cellbytelabel id="20">Relig.</cellbytelabel><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from TBL_ADM_RELIGION ","religion",cdo.getColValue("religion"),false,true,0,"Text10",null,null,"","")%>
		</td>
	</tr>
	<tr class="TextResultRowsWhite">
		<td align="left" colspan="8">
		<cellbytelabel id="21">&Aacute;rea de Atenci&oacute;n</cellbytelabel>
		<%=fb.textBox("cdsAtencion",cdo.getColValue("cds_atencion"),false,false,true,10,"Text10",null,null)%>
		<%=fb.textBox("cdsAtencionDesc",cdo.getColValue("cds_atencion_desc"),false,false,true,93,"Text10",null,null)%>
	</td>
	</tr>
	<%=fb.formEnd(true)%>
	<tr>
		<td colspan="2" class="TableBorder">
			<jsp:include page="../common/data_link_info.jsp" flush="true">
				<jsp:param name="pacIdRef" value="<%=cdo.getColValue("pac_id_ref")%>"></jsp:param>
				<jsp:param name="admisionRef" value="<%=cdo.getColValue("admision_ref")%>"></jsp:param>
				<jsp:param name="admStatusRef" value="<%=cdo.getColValue("estado_ref")%>"></jsp:param>
			</jsp:include>
		</td>
	</tr>
	<tr class="TextResultRowsWhite"> </tr>
</table>
