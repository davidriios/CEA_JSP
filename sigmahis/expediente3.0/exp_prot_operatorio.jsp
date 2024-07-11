<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
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
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String desc = request.getParameter("desc");

if (fg == null) fg = "I";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (tab == null) tab = "0";
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
String change = request.getParameter("change");
String code = request.getParameter("code");
String filter ="", filter2 ="";
String key = "";
if(code == null)code = "0";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET")) {
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_PROT_OPE_SHOW_CIR'),'-') as showCir,nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_PROT_OPE_SHOW_INS'),'-') as showIns from dual");
	CommonDataObject p = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.fecha,'hh12:mi:ss am') as hora, (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = a.cirujano) as cirujano from tbl_sal_protocolo_operatorio a where a.admision = ").append(noAdmision).append(" and a.pac_id = ").append(pacId).append(" order by 1 desc");
	al = SQLMgr.getDataList(sbSql.toString());

	if (cdo == null || code.equals("0")) {

		if (!viewMode) modeSec = "add";
		cdo = new CommonDataObject();
		cdo.addColValue("fecha", cDateTime.substring(0, 10));
		cdo.addColValue("descProc","");
		cdo.addColValue("anestesiologo","");
		cdo.addColValue("asistente","");
		cdo.addColValue("patologo","");
		cdo.addColValue("hora_fin","");
		cdo.addColValue("hora_inicio","");
		
		CommonDataObject cdoX = SQLMgr.getData("SELECT cirugia, nvl(desc_cirugia,cirugia) desc_cirugia, medico_cirujano as cirujano, nvl(desc_medico_cirujano, medico_cirujano) desc_medico_cirujano from tbl_sal_revision_preoperatoria where pac_id = "+pacId+" and secuencia = "+noAdmision+" and grupo = 'A' AND fecha = (SELECT max(fecha) FROM tbl_sal_revision_preoperatoria where pac_id = "+pacId+" and secuencia = "+noAdmision+" and grupo = 'A')");
		if (cdoX == null) cdoX = new CommonDataObject();
		
		if (!cdoX.getColValue("cirugia"," ").trim().equals("") && !cdoX.getColValue("desc_cirugia"," ").trim().equals("")) {
			cdo.addColValue("procedimiento", cdoX.getColValue("cirugia"));
			cdo.addColValue("procedimiento_desc", cdoX.getColValue("desc_cirugia"));
		}
		
		if (!cdoX.getColValue("cirujano"," ").trim().equals("") && !cdoX.getColValue("desc_medico_cirujano"," ").trim().equals("")) {
			cdo.addColValue("cirujano", cdoX.getColValue("cirujano"));
			cdo.addColValue("cirujanoName", cdoX.getColValue("desc_medico_cirujano"));
		}
		
	} else if (!code.trim().equals("0")) {
		
		if (!viewMode) modeSec = "edit";
		sbSql = new StringBuffer();
		sbSql.append("select a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.diag_pre_operatorio, a.diag_pre_operatorio_desc, a.diag_post_operatorio, a.diag_post_operatorio_desc, a.procedimiento, a.procedimiento_desc, a.cirujano, a.asistente, a.anestesia, a.anestesiologo, a.profilaxis_antibiotica as profilaxis, a.tiempo_profilaxis as tiempoProfilaxis, a.limpieza, a.incision, a.especimen_patologia as especimen, a.patologo, a.hallazgos, a.observacion, a.complicacion, a.transfusiones, a.medicamentos, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.cirujano) as cirujanoName, nvl((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.asistente),' ') as nombre_asistente, nvl((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.anestesiologo),' ') as nombre_anestesiologo, nvl(a.suturas,' ') as suturas, nvl(a.drenaje,' ') as drenaje, to_char(a.hora_inicio,'hh12:mi am') as hora_inicio, to_char(a.hora_fin,'hh12:mi am') as hora_fin, nvl(a.instrumentador,' ') as instrumentador, nvl(a.circulador,' ') as circulador, nvl(a.protocolo,' ') as protocolo, a.implantes, a.implantes_observ, coalesce((select nombre_empleado from vw_pla_empleado where to_char(emp_id) = a.instrumentador),a.instrumentador_nombre,' ') as instrumentador_nombre, coalesce((select nombre_empleado from vw_pla_empleado where to_char(emp_id) = a.circulador),a.circulador_nombre,' ') as circulador_nombre, a.sangrado, a.muestras_histo, a.tot_muestras, a.tot_muestras_desc, a.dispo_implantables, a.dispo_implantables_desc, a.sangrado_desc, a.transfusiones_desc, a.drenaje_desc, a.complicacion_desc from tbl_sal_protocolo_operatorio a where a.codigo = ").append(code).append(" and a.pac_id = ").append(pacId).append(" and a.admision = ").append(noAdmision);
		cdo = SQLMgr.getData(sbSql.toString());
		if (cdo == null) cdo = new CommonDataObject();
		
	}

	String active0 = "", active1 = "";
	if (tab.equals("0")) active0 = "active";
	else if (tab.equals("1")) active1 = "active";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<script>
var noNewHeight = true;
document.title = 'PROTOCOLO OPERATORIO - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function add(){	window.location = '../expediente3.0/exp_prot_operatorio.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0';}
function showAnesList(){abrir_ventana1('../common/search_medico.jsp?fp=protocolo');}
function showProcList(){abrir_ventana1('../common/sel_procedimiento.jsp?fp=protocolo&modeSec=<%=modeSec%>&mode=<%=mode%>&seccion=<%=seccion%>&pac_id=<%=pacId%>&admision=<%=noAdmision%>&id=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&exp=3');}
function showDiagPost(){abrir_ventana1('../common/search_diagnostico.jsp?fp=protocoloPost&mode=<%=mode%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&exp=3');}
function showDiagPre(){abrir_ventana1('../common/search_diagnostico.jsp?fp=protocolo&mode=<%=mode%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&exp=3');}
function setProtocolo(code){window.location = '../expediente3.0/exp_prot_operatorio.jsp?modeSec=edit&mode=<%=mode%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code='+code;}
function doAction(){<%if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("1")){%>showDiagPre();<%}else if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("2")){%>showDiagPost();<%}else if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("3")){%>	showProcList();<%}%>checkViewMode();}
function imprimirProtocolo(){var fecha = eval('document.form0.fecha').value;abrir_ventana1('../expediente3.0/print_protocolo_op.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&desc=<%=desc%>&seccion=<%=seccion%>&fechaProt='+fecha);}
function showAnestesiaList(){abrir_ventana1('../expediente/list_anestesia.jsp?id=2');}
function showMedicoList(fg){abrir_ventana1('../common/search_medico.jsp?fp=protocoloOp&fg='+fg);}

function verHistorial() {
	$("#hist_container").toggle();
}

function showEmpleadoList(fg){
		var obj = {
				'CIR': 'circulador',
				'INS': 'instrumentador',
		};
		$("input[name*='"+obj[fg]+"']").val("");
		abrir_ventana1('../common/search_empleado.jsp?fp=protocolo_operatorio&fg='+fg);
}

$(function(){
		$('iframe').iFrameResize({
				log: false
		});

		$("input[name*='muestras_histo']").click(function(){
				if (this.value == 'S') {
			$("#tot_muestras").prop("readOnly", false);
			$("#tot_muestras_desc").prop("readOnly", false);
		}
				else {
			$("#tot_muestras").prop("readOnly", true).val("");
			$("#tot_muestras_desc").prop("readOnly", true).val("");
		}
		});

		$("input[name*='dispo_implantables']").click(function(){
				if (this.value == 'S') $("#dispo_implantables_desc").prop("readOnly", false);
				else $("#dispo_implantables_desc").prop("readOnly", true).val("");
		});

	$("input[name*='drenaje']").click(function(){
				if (this.value == 'S') $("#drenaje_desc").prop("readOnly", false);
				else $("#drenaje_desc").prop("readOnly", true).val("");
		});

	$("input[name*='complicacion']").click(function(){
				if (this.value == 'S') $("#complicacion_desc").prop("readOnly", false);
				else $("#complicacion_desc").prop("readOnly", true).val("");
		});

	$("input[name*='sangrado']").click(function(){
				if (this.value == 'S') $("#sangrado_desc").prop("readOnly", false);
				else $("#sangrado_desc").prop("readOnly", true).val("");
		});

	$("input[name*='transfusiones']").click(function(){
				if (this.value == 'S') $("#transfusiones_desc").prop("readOnly", false);
				else $("#transfusiones_desc").prop("readOnly", true).val("");
		});

	//
	$("#dispo_implantables_desc").attr('maxlength', 500);
	$("#tot_muestras_desc").attr('maxlength', 500);
	$("#sangrado_desc").attr('maxlength', 500);
});
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">

<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform">
<%fb = new FormBean2("formTop",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
<tr>
	<td class="controls form-inline">
		<%if(!mode.trim().equalsIgnoreCase("view")){%>
		<%=fb.button("agregar","Agregar",true,false,"btn btn-inverse btn-sm|fa fa-plus fa-printico",null,"onclick=\"add()\"")%>
		<%}%>
		<%=fb.button("imprimir","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimirProtocolo()\"")%>
		<%if(al.size() > 0){%>
		<%=fb.button("btnHistory","Historial",false,false,"btn btn-inverse btn-sm|fa fa-eye fa-printico",null,"onClick=\"javascript:verHistorial()\"")%>
		<%}%>
	</td>
</tr>
</table>
<%=fb.formEnd()%>
</div>

<div class="table-wrapper" id="hist_container" style="display:none">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">

<tr class="bg-headtabla">
		<td><cellbytelabel id="4">C&oacute;digo</cellbytelabel></td>
		<td><cellbytelabel id="5">Fecha</cellbytelabel></td>
		<td><cellbytelabel id="5">Cirujano</cellbytelabel></td>
</tr>
	<%
	for (int i=1; i<=al.size(); i++){
		CommonDataObject cdo2 = (CommonDataObject) al.get(i-1);
	%>
				<tr style="text-decoration:none; cursor:pointer" onclick="setProtocolo(<%=cdo2.getColValue("codigo","0")%>)">
						<td><%=cdo2.getColValue("codigo")%></td>
						<td><%=cdo2.getColValue("fecha")%></td>
						<td><%=cdo2.getColValue("cirujano")%></td>
				</tr>
	<%}%>
</tbody>
</table>
</div>
</div>

<ul class="nav nav-tabs" role="tablist">
		<li role="presentation" class="<%=active0%>">
				<a href="#generales" aria-controls="generales" role="tab" data-toggle="tab"><b>Datos Generales</b></a>
		</li>
		<%if (!modeSec.equalsIgnoreCase("add")){%>

		<li role="presentation" class="<%=active1%>">
				<a href="#documentos" aria-controls="documentos" role="tab" data-toggle="tab"><b>Documentos</b></a>
		</li>
		<%}%>
</ul>

<!-- Tab panes -->
	<div class="tab-content">

		<!-- Generales -->
		<div role="tabpanel" class="tab-pane <%=active0%>" id="generales">

		 <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
		 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
		 <%=fb.formStart(true)%>
		 <%=fb.hidden("baction","")%>
		 <%=fb.hidden("mode",mode)%>
		 <%=fb.hidden("modeSec",modeSec)%>
		 <%=fb.hidden("seccion",seccion)%>
		 <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
		 <%=fb.hidden("dob","")%>
		 <%=fb.hidden("codPac","")%>
		 <%=fb.hidden("pacId",pacId)%>
		 <%=fb.hidden("noAdmision",noAdmision)%>
		 <%=fb.hidden("code",code)%>
		 <%=fb.hidden("tab","0")%>
		 <%=fb.hidden("desc",desc)%>
		 <table cellspacing="0" class="table table-small-font table-bordered table-striped">

				<tr>
						<td colspan="4" class="controls form-inline">
								<cellbytelabel id="15">Fecha Operac&oacute;n</cellbytelabel>
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
								<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
								<jsp:param name="format" value="dd/mm/yyyy"/>
								</jsp:include>

						</td>
				</tr>

				<tr>
						<td width="25%"><cellbytelabel id="16">Cirujano</cellbytelabel></td>
						<td colspan="3" class="controls form-inline">
						<%=fb.hidden("cirujano", cdo.getColValue("cirujano",  (UserDet.getRefType().trim().equalsIgnoreCase("M") ? UserDet.getRefCode() : "")))%>
						<%=fb.textBox("cirujanoName",cdo.getColValue("cirujanoName", (UserDet.getRefType().trim().equalsIgnoreCase("M") ? UserDet.getName() : "")),true,false,true,45,"form-control input-sm","","")%>
						<%=fb.button("btnCirujao","...",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:showMedicoList('CR')\"","Cirujano")%></td>
				</tr>
				<tr>
						<td width="25%"><cellbytelabel id="17">Medico Asistente</cellbytelabel></td>
						<td colspan="3" class="controls form-inline">
								<%=fb.hidden("asistente",""+cdo.getColValue("asistente"))%>
								<%=fb.textBox("asistenteName",cdo.getColValue("nombre_asistente"),false,false,true,45,150,"form-control input-sm","","")%>
								<%=fb.button("btnAsistente","...",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:showMedicoList('AS')\"","Asistente")%>
						</td>
				</tr>

				<tr>
						<td width="25%"><cellbytelabel id="19">Anestesi&oacute;logo *</cellbytelabel></td>
						<td colspan="3" class="controls form-inline">
						<%=fb.hidden("anestesiologo",""+cdo.getColValue("anestesiologo"))%>
						<%=fb.textBox("anestesiologoNombre",cdo.getColValue("nombre_anestesiologo"),true,false,true,45,150,"form-control input-sm","","")%>
						<%=fb.button("btnAnes","...",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:showAnesList()\"","Anestesiologo")%>

			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			Tipo de Anestesia:
			<%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo, codigo FROM TBL_SAL_TIPO_ANESTESIA ORDER BY 1","anestesia",cdo.getColValue("anestesia"),false,(cdo.getColValue("anestesia"," ").equals("N") || viewMode),0,"form-control input-sm",null,null,null, "S")%>
			</td>
				</tr>
				<% if (!p.getColValue("showIns").equalsIgnoreCase("N")) { %>
				<tr>
						<td width="25%"><cellbytelabel id="20">Instrumentador (a)</cellbytelabel>:</td>
						<td colspan="3" class="controls form-inline">
								<%=fb.hidden("instrumentador", cdo.getColValue("instrumentador"))%>
								<%=fb.textBox("instrumentador_nombre",cdo.getColValue("instrumentador_nombre"),false,false,false,45,0,"form-control input-sm","","")%>
								<%=fb.button("btn_instrumentador","...",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=showEmpleadoList('INS')","")%>
						</td>
				</tr>
				<%
				} 
				if (!p.getColValue("showCir").equalsIgnoreCase("N")) { %>
				<tr>
						<td width="25%"><cellbytelabel id="21">Circulador (a)</cellbytelabel>:</td>
						<td colspan="3" class="controls form-inline">
								<%=fb.hidden("circulador", cdo.getColValue("circulador"))%>
								<%=fb.textBox("circulador_nombre",cdo.getColValue("circulador_nombre"),false,false,false,45,0,"form-control input-sm","","")%>
								<%=fb.button("btn_circulador","...",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=showEmpleadoList('CIR')","")%>
						</td>
				</tr>
				<% } %>
				<tr>
						<td width="25%"><cellbytelabel id="22">Hora</cellbytelabel>:</td>
						<td colspan="3" class="controls form-inline"><cellbytelabel id="23">Inicio</cellbytelabel>
								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora_inicio" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_inicio")%>" />
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include> <cellbytelabel id="24">Fin</cellbytelabel>:<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora_fin" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_fin")%>" />
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
				</jsp:include>
						</td>
		</tr>

				<tr>
						<td width="25%"><cellbytelabel id="31">Hallazgos Transoperatorios *</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("hallazgos",cdo.getColValue("hallazgos"),true,false,viewMode,60,2,4000,"form-control input-sm","","")%></td>
				</tr>

				<tr>
						<td width="25%"><cellbytelabel id="32">Protocolo Operatorio *</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("protocolo",cdo.getColValue("protocolo"),true,false,viewMode,60,2,4000,"form-control input-sm","","")%></td>
				</tr>

		<tr>
						<td width="25%"><cellbytelabel id="34">Diagn&oacute;stico Preoperatorio</cellbytelabel></td>
			<td colspan="3" class="controls form-inline">
						<%=fb.hidden("codDiagPre", cdo.getColValue("diag_pre_operatorio"))%>
						<%=fb.textBox("descDiagPre",cdo.getColValue("diag_pre_operatorio_desc"),false,false,true,100,0,"form-control input-sm","","")%>
						<%=fb.button("btn_diag_pre_ope","...",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=showDiagPre()","")%>
			</td>
				</tr>

		<tr>
						<td width="25%"><cellbytelabel id="34">Diagn&oacute;stico Postoperatorio</cellbytelabel></td>
			<td colspan="3" class="controls form-inline">
						<%=fb.hidden("diagPost", cdo.getColValue("diag_post_operatorio"))%>
						<%=fb.textBox("descDiagPost",cdo.getColValue("diag_post_operatorio_desc"),false,false,true,100,0,"form-control input-sm","","")%>
						<%=fb.button("btn_diag_pos_ope","...",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=showDiagPost()","")%>
			</td>
				</tr>

		<tr>
						<td width="25%"><cellbytelabel id="34">Operaciones</cellbytelabel></td>
			<td colspan="3" class="controls form-inline">
						<%=fb.hidden("codProc", cdo.getColValue("procedimiento"))%>
						<%=fb.textBox("descProc",cdo.getColValue("procedimiento_desc"),false,false,true,100,0,"form-control input-sm","","")%>
						<%=fb.button("btn_proc","...",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=showProcList()","")%>
			</td>
				</tr>

		<tr>
						<td width="25%"><cellbytelabel id="34">Drenajes</cellbytelabel></td>
						<td colspan="3" class="controls form-inline">
				<label class="pointer"><%=fb.radio("drenaje","S",cdo.getColValue("drenaje")!=null&&cdo.getColValue("drenaje").equalsIgnoreCase("S"),viewMode,false,null,null,"")%>&nbsp;<b>SI</b></label>
								&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("drenaje","N",cdo.getColValue("drenaje")!=null&&cdo.getColValue("drenaje").equalsIgnoreCase("N"),viewMode,false,null,null,"")%>&nbsp;<b>NO</b></label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Detallar:&nbsp;
								<%=fb.textarea("drenaje_desc",cdo.getColValue("drenaje_desc"),false,false,cdo.getColValue("drenaje_desc"," ").trim().equals(""),100,1,0,"form-control input-sm","","")%>
			</td>
				</tr>

				<tr>
						<td width="25%"><cellbytelabel id="37">Registro de Dispositivos Implantables</cellbytelabel></td>
						<td colspan="3" class="controls form-inline">
								<label class="pointer"><%=fb.radio("dispo_implantables","S",cdo.getColValue("dispo_implantables")!=null&&cdo.getColValue("dispo_implantables").equalsIgnoreCase("S"),viewMode,false,null,null,"")%>&nbsp;<b>SI</b></label>
								&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("dispo_implantables","N",cdo.getColValue("dispo_implantables")!=null&&cdo.getColValue("dispo_implantables").equalsIgnoreCase("N"),viewMode,false,null,null,"")%>&nbsp;<b>NO</b></label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Detallar:&nbsp;
								<%=fb.textarea("dispo_implantables_desc",cdo.getColValue("dispo_implantables_desc"),false,false,cdo.getColValue("dispo_implantables_desc"," ").trim().equals(""),100,1,0,"form-control input-sm","","")%>
						</td>
				</tr>

		<tr>
						<td width="25%"><cellbytelabel id="37">Complicaciones perioperatorias</cellbytelabel></td>
						<td colspan="3" class="controls form-inline">
								<label class="pointer"><%=fb.radio("complicacion","S",cdo.getColValue("complicacion")!=null&&cdo.getColValue("complicacion").equalsIgnoreCase("S"),viewMode,false,null,null,"")%>&nbsp;<b>SI</b></label>
								&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("complicacion","N",cdo.getColValue("complicacion")!=null&&cdo.getColValue("complicacion").equalsIgnoreCase("N"),viewMode,false,null,null,"")%>&nbsp;<b>NO</b></label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Detallar:&nbsp;
								<%=fb.textarea("complicacion_desc",cdo.getColValue("complicacion_desc"),false,false,cdo.getColValue("complicacion_desc"," ").trim().equals(""),100,1,0,"form-control input-sm","","")%>
						</td>
				</tr>

				<tr>
						<td width="25%"><cellbytelabel id="37">N&uacute;mero de muestras histopatol&oacute;gicas</cellbytelabel></td>
						<td colspan="3" class="controls form-inline">
								<label class="pointer"><%=fb.radio("muestras_histo","S",cdo.getColValue("muestras_histo")!=null&&cdo.getColValue("muestras_histo").equalsIgnoreCase("S"),viewMode,false,null,null,"")%>&nbsp;<b>SI</b></label>
								&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("muestras_histo","N",cdo.getColValue("muestras_histo")!=null&&cdo.getColValue("muestras_histo").equalsIgnoreCase("N"),viewMode,false,null,null,"")%>&nbsp;<b>NO</b></label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								N&uacute;mero de muestras&nbsp;
								<%=fb.textBox("tot_muestras",cdo.getColValue("tot_muestras"),false,false,cdo.getColValue("tot_muestras"," ").trim().equals(""),5,2,"form-control input-sm","","")%>

				&nbsp;&nbsp;&nbsp;Espec&iacute;fique:

				<%=fb.textarea("tot_muestras_desc",cdo.getColValue("tot_muestras_desc"),false,false,cdo.getColValue("tot_muestras_desc"," ").trim().equals(""),50,1,0,"form-control input-sm","","")%>
						</td>
				</tr>

		<tr>
						<td width="25%"><cellbytelabel id="37">P&eacute;rdida sangu&iacute;nea</cellbytelabel></td>
						<td colspan="3" class="controls form-inline">
								<label class="pointer"><%=fb.radio("sangrado","S",cdo.getColValue("sangrado")!=null&&cdo.getColValue("sangrado").equalsIgnoreCase("S"),viewMode,false,null,null,"")%>&nbsp;<b>SI</b></label>
								&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("sangrado","N",cdo.getColValue("sangrado")!=null&&cdo.getColValue("sangrado").equalsIgnoreCase("N"),viewMode,false,null,null,"")%>&nbsp;<b>NO</b></label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Detallar:&nbsp;
								<%=fb.textarea("sangrado_desc",cdo.getColValue("sangrado_desc"),false,false,cdo.getColValue("sangrado_desc"," ").trim().equals(""),100,1,0,"form-control input-sm","","")%>
						</td>
				</tr>

		<tr>
						<td width="25%"><cellbytelabel id="37">Transfusiones</cellbytelabel></td>
						<td colspan="3" class="controls form-inline">
								<label class="pointer"><%=fb.radio("transfusiones","S",cdo.getColValue("transfusiones")!=null&&cdo.getColValue("transfusiones").equalsIgnoreCase("S"),viewMode,false,null,null,"")%>&nbsp;<b>SI</b></label>
								&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("transfusiones","N",cdo.getColValue("transfusiones")!=null&&cdo.getColValue("transfusiones").equalsIgnoreCase("N"),viewMode,false,null,null,"")%>&nbsp;<b>NO</b></label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Detallar:&nbsp;
								<%=fb.textarea("transfusiones_desc",cdo.getColValue("transfusiones_desc"),false,false,cdo.getColValue("transfusiones_desc"," ").trim().equals(""),100,1,0,"form-control input-sm","","")%>
						</td>
				</tr>

	</table>

		<div class="footerform">
				<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
				<tr>
					 <td>
								<%=fb.hidden("saveOption","O")%>
								<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"")%>
						</td>
				</tr>
				</table>
		</div>
		<%=fb.formEnd(true)%>
</div>

 <!-- Documentos -->
<div role="tabpanel" class="tab-pane <%=active1%>" id="documentos">
		<table width="100%" cellpadding="1" cellspacing="1" >
				<tr>
						<td>
								<iframe id="doc_esc" name="doc_esc" width="100%" scrolling="yes" frameborder="0" src="../expediente3.0/exp_documentos.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&exp=3&expStatus=<%=request.getParameter("estado")!=null?request.getParameter("estado"):""%>&area_revision=SL&docs_for=protocolo_operatorio&docId=45"></iframe>
						</td>
				</tr>
		</table>
</div>

</div> <!-- Tabs container-->



</div>
</div>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");


	if (tab.equals("0")) //Protocolo
	{
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_sal_protocolo_operatorio");
	//cdo.setWhereClause("codigo="+request.getParameter("code"));
	cdo.addColValue("fecha",request.getParameter("fecha"));

	cdo.addColValue("diag_pre_operatorio",request.getParameter("codDiagPre"));
	cdo.addColValue("diag_pre_operatorio_desc",request.getParameter("descDiagPre"));
	cdo.addColValue("diag_post_operatorio",request.getParameter("diagPost"));
	cdo.addColValue("diag_post_operatorio_desc",request.getParameter("descDiagPost"));
	cdo.addColValue("procedimiento",request.getParameter("codProc"));
	cdo.addColValue("procedimiento_desc",request.getParameter("descProc"));

	cdo.addColValue("cirujano",request.getParameter("cirujano"));
	cdo.addColValue("asistente",request.getParameter("asistente"));
	cdo.addColValue("anestesia",request.getParameter("anestesia"));
	cdo.addColValue("anestesiologo",request.getParameter("anestesiologo"));
	cdo.addColValue("nombre_anestesiologo",request.getParameter("anestesiologoNombre"));
	cdo.addColValue("nombre_asistente",request.getParameter("asistenteName"));
	cdo.addColValue("profilaxis_antibiotica",request.getParameter("profilaxis"));
	cdo.addColValue("tiempo_profilaxis",request.getParameter("tiempoProfilaxis"));
	cdo.addColValue("limpieza",request.getParameter("limpieza"));
	cdo.addColValue("incision",request.getParameter("incision"));
	cdo.addColValue("especimen_patologia",request.getParameter("especimen"));
	cdo.addColValue("patologo",request.getParameter("patologo"));
	cdo.addColValue("nombre_patologo",request.getParameter("patologoNombre"));
	cdo.addColValue("hallazgos",request.getParameter("hallazgos"));
	cdo.addColValue("suturas",request.getParameter("suturas"));

	cdo.addColValue("hora_inicio",request.getParameter("hora_inicio"));
	cdo.addColValue("hora_fin",request.getParameter("hora_fin"));

	cdo.addColValue("protocolo",request.getParameter("protocolo"));
	cdo.addColValue("circulador",request.getParameter("circulador"));
	cdo.addColValue("circulador_nombre",request.getParameter("circulador_nombre"));
	cdo.addColValue("instrumentador",request.getParameter("instrumentador"));
	cdo.addColValue("instrumentador_nombre",request.getParameter("instrumentador_nombre"));

	cdo.addColValue("muestras_histo",request.getParameter("muestras_histo"));
	cdo.addColValue("tot_muestras",request.getParameter("tot_muestras"));
	cdo.addColValue("tot_muestras_desc",request.getParameter("tot_muestras_desc"));

	cdo.addColValue("sangrado",request.getParameter("sangrado"));
	cdo.addColValue("sangrado_desc",request.getParameter("sangrado_desc"));

	cdo.addColValue("transfusiones",request.getParameter("transfusiones"));
	cdo.addColValue("transfusiones_desc",request.getParameter("transfusiones_desc"));

	cdo.addColValue("dispo_implantables",request.getParameter("dispo_implantables"));
	cdo.addColValue("dispo_implantables_desc",request.getParameter("dispo_implantables_desc"));

	cdo.addColValue("complicacion",request.getParameter("complicacion"));
	cdo.addColValue("complicacion_desc",request.getParameter("complicacion_desc"));

	cdo.addColValue("drenaje",request.getParameter("drenaje"));
	cdo.addColValue("drenaje_desc",request.getParameter("drenaje_desc"));

		if (request.getParameter("implantes") != null) {
				cdo.addColValue("implantes", request.getParameter("implantes"));
				if(request.getParameter("implantes").equalsIgnoreCase("S")) cdo.addColValue("implantes_observ", request.getParameter("implantes_observ"));
		}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
	{
		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));
		cdo.addColValue("fecha_creacion",cDateTime);
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));

		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");

		SQLMgr.insert(cdo);
		code = SQLMgr.getPkColValue("codigo");
	}
	else
	{
		cdo.addColValue("fecha_modificacion",cDateTime);
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));

		cdo.setWhereClause("codigo = "+request.getParameter("code")+" and pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);

	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
	parent.doRedirect(0);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

