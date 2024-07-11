<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.admision.Cama"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htCama" scope="session" class="java.util.Hashtable" />
<br>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Admision AdmDet = new Admision();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String pacienteId = request.getParameter("pacienteId");
String noAdmision = request.getParameter("noAdmision");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
if(fg==null) fg = "SAL";
String fp = request.getParameter("fp");
if(fp==null) fp = "salida";
int countCama = 0;

String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
boolean viewMode = false;

if (mode == null) mode = "add";
if (mode.equals("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")){
	if (mode.equalsIgnoreCase("add")){
		if(change==null){
			htCama.clear();
			pacienteId = "0";
			noAdmision = "0";
			htCama = new Hashtable();
			session.setAttribute("htCama",htCama);
		} else {
			if (pacienteId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
			if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");
			sql = "select count(*) count from tbl_adm_cama_admision c, tbl_adm_admision a where a.pac_id = c.pac_id and a.secuencia = c.admision and ((a.estado = 'A' and c.compania = 1) or (a.estado = 'S' and c.compania = 4)) and c.pac_id = "+pacienteId+" and c.admision = "+noAdmision+" and c.fecha_final is null";
			countCama = CmnMgr.getCount(sql);
		}
	}	else {
		if (pacienteId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");

		sql = "select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fechaIngreso, decode(a.dias_estimados,null,' ',a.dias_estimados) as diasEstimados, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, to_char(nvl(a.fecha_preadmision,sysdate),'dd/mm/yyyy hh12:mi:ss am') as fechaPreadmision, a.categoria, a.tipo_admision as tipoAdmision, a.medico, a.usuario_creacion as usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, to_char(nvl(a.am_pm,sysdate),'hh12:mi:ss am') as amPm, nvl(a.tipo_cta,' ') as tipoCta, a.conta_cred as contaCred, decode(a.provincia,null,' ',a.provincia) as provincia, nvl(a.sigla,' ') as sigla, decode(a.tomo,null,' ',a.tomo) as tomo, decode(a.asiento,null,' ',a.asiento) as asiento, nvl(a.d_cedula,' ') as dCedula, nvl(a.pasaporte,' ') as pasaporte, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.paciente_id as pacienteId, a.responsabilidad, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombrePaciente, c.descripcion as categoriaDesc, d.descripcion as tipoAdmisionDesc, e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' '||e.apellido_de_casada)) as nombreMedico, e.especialidad, decode(f.primer_nombre,null,' ',f.primer_nombre||decode(f.segundo_nombre,null,'',' '||f.segundo_nombre)||' '||f.primer_apellido||decode(f.segundo_apellido,null,'',' '||f.segundo_apellido)||decode(f.sexo,'F',decode(f.apellido_de_casada,null,'',' '||f.apellido_de_casada))) as nombreMedicoCabecera, g.descripcion as centroServicioDesc from tbl_adm_admision a, tbl_adm_paciente b, tbl_adm_categoria_admision c, tbl_adm_tipo_admision_cia d, (select x.codigo, x.primer_nombre, x.segundo_nombre, x.primer_apellido, x.segundo_apellido, x.apellido_de_casada, x.sexo, nvl(z.descripcion,'NO TIENE') as especialidad from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) e, tbl_adm_medico f, tbl_cds_centro_servicio g where a.paciente_id=b.paciente_id and a.categoria=c.codigo and a.categoria=d.categoria and a.tipo_admision=d.codigo and a.compania=d.compania and a.medico=e.codigo and a.medico_cabecera=f.codigo(+) and a.centro_servicio=g.codigo and a.compania="+(String) session.getAttribute("_companyId")+" and a.paciente_id="+pacienteId+" and a.secuencia="+noAdmision;
		System.out.println("SQL:\n"+sql);
		//AdmDet = (Factura) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Factura.class);

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Salida - '+document.title;

function setBAction(fName,actionValue){
	document.form0.baction.value = actionValue;
	var countCama = '<%=countCama%>';
	if(parseInt(countCama,2)==0) CBMSG.warning('El paciente no tiene una cama asignada activa!');
	else if(document.form0.fallecido[0].checked==false && document.form0.fallecido[1].checked==false) CBMSG.warning('Seleccione si el paciente es fallecido o no!');
	else doSubmit();
}

function doAction(){
}

function doSubmit(){

	document.form0.nombrePaciente.value			= document.paciente.nombrePaciente.value;
	document.form0.fechaNacimiento.value		= document.paciente.fechaNacimiento.value;
	document.form0.codigoPaciente.value 		= document.paciente.codigoPaciente.value;
	document.form0.pacienteId.value 				= document.paciente.pacienteId.value;
	document.form0.provincia.value 					= document.paciente.provincia.value;
	document.form0.sigla.value 							= document.paciente.sigla.value;
	document.form0.tomo.value 							= document.paciente.tomo.value;
	document.form0.asiento.value 						= document.paciente.asiento.value;
	document.form0.dCedula.value 						= document.paciente.dCedula.value;
	document.form0.pasaporte.value 					= document.paciente.pasaporte.value;
	document.form0.jubilado.value						= document.paciente.jubilado.value;
	document.form0.numFactura.value					= document.paciente.numFactura.value;
	document.form0.categoria.value					= document.paciente.categoria.value;
	document.form0.categoriaDesc.value			= document.paciente.categoriaDesc.value;
	document.form0.fechaIngreso.value				= document.paciente.fechaIngreso.value;
	document.form0.mesCta.value							= document.paciente.mesCta.value;
	document.form0.admSecuencia.value 			= document.paciente.admSecuencia.value;
	document.form0.estado.value 						= document.paciente.estado.value;
	document.form0.desc_estado.value 				= document.paciente.desc_estado.value;
	document.form0.empresa.value 						= document.paciente.empresa.value;
	document.form0.clasificacion.value			= document.paciente.clasificacion.value;
	document.form0.embarazada.value					= document.paciente.embarazada.value;


	if (!parent.pacienteValidation() || !parent.form0Validation()){
		//return false;
	} else{
		//return true;
		document.form0.submit();
	}

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SALIDA"></jsp:param>
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
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Datos del Paciente</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<jsp:include page="../common/paciente.jsp" flush="true">
							<jsp:param name="pacienteId" value="<%=pacienteId%>"></jsp:param>
							<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
							<jsp:param name="fp" value="<%=fp%>"></jsp:param>
							<jsp:param name="tr" value="<%=fg%>"></jsp:param>
							<jsp:param name="mode" value="<%=mode%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
				<tr class="TextRow01">
					<td>&nbsp;</td>
				</tr>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
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
				<tr class="TextRow01">
					<td>Fallecido
						<%=fb.radio("fallecido","S", false, false, false, "", "", "")%>S&iacute;
						<%=fb.radio("fallecido","N", false, false, false, "", "", "")%>No
					</td>
				</tr>
				<tr class="TextRow01">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Camas</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td class="TextRow01">
						<div id="planes" style="overflow:scroll; position:static; height:165">
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextHeader">
								<td width="10%" align="center" rowspan="2">Cama</td>
								<td width="20%" align="center" rowspan="2">Habitaci&oacute;n</td>
								<td width="40%" align="center" rowspan="2"></td>
								<td width="26%" align="center" colspan="2">Ocupada</td>
								<td width="4%" align="center" rowspan="2">&nbsp;</td>
							</tr>
							<tr class="TextHeader">
								<td width="13%" align="center">Desde</td>
								<td width="13%" align="center">Hasta</td>
							</tr>
							<%
							for(int i=0;i<htCama.size();i++){
								Cama ca = (Cama) htCama.get(""+i);
								String color = "TextRow02";
								if (i % 2 == 0) color = "TextRow01";
							%>
							<tr class="<%=color%>">
								<%=fb.hidden("habitacion"+i,ca.getHabitacion())%>
								<%=fb.hidden("cama"+i,ca.getCama())%>
								<%=fb.hidden("descripcion"+i,ca.getDescripcion())%>
								<%=fb.hidden("fecha_inicio"+i,ca.getFechaInicio())%>
								<%=fb.hidden("fecha_fin"+i,ca.getFechaFin())%>
								<%=fb.hidden("codigo"+i,ca.getCodigo())%>
								<td align="center"><%=ca.getCama()%></td>
								<td align="center"><%=ca.getHabitacion()%></td>
								<td><%=ca.getDescripcion()%></td>
								<td align="center"><%=ca.getFechaInicio()%></td>
								<td align="center"><%=ca.getFechaFin()%></td>
								<td width="2%" align="right">&nbsp;</td>
							</tr>
							<%
							}
							%>
							<%=fb.hidden("camaSize",""+htCama.size())%>
						</table>
						</div>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<%=fb.button("guardar","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
			</td>
		</tr>
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


	AdmDet.setCompania((String) session.getAttribute("_companyId"));
	AdmDet.setSecuencia(request.getParameter("admSecuencia"));
	AdmDet.setPacId(request.getParameter("pacienteId"));
	AdmDet.setFallecido(request.getParameter("fallecido"));
	AdmDet.setUsuarioModifica(UserDet.getUserName());

	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String flag = "0";
	System.out.println("baction="+request.getParameter("baction"));
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		AdmMgr.salidaPaciente(AdmDet);
		flag = "1";
		session.removeAttribute("htCama");
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">

function closeWindow()
{
<%
if (AdmMgr.getErrCode().equals("1")){
%>
	alert('<%=AdmMgr.getErrMsg()%>');
	window.opener.location = '<%=request.getContextPath()%>/admision/list_sal_pac.jsp';
	window.close();
<%
	//if (flag.equalsIgnoreCase("1")){
%>
	//setTimeout('addMode()',500);
<%
	//}
} else throw new Exception(AdmMgr.getErrMsg());
%>
}
/*
function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add';
}
*/
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>