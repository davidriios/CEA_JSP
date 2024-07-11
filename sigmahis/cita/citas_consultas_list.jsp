<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbFilterXtra = new StringBuffer();
String fp = request.getParameter("fp");
String toDay = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fg = request.getParameter("fg");
String cds = request.getParameter("cds");

if(fp == null) fp = "citas_cons";
if(fg == null) fg = "SOP";
if (cds == null) cds = "";

String habitacion = "", nombreMedico = "", procCode = "", procName = "", codTipo = "", nombrePaciente = "", anestesia = "", formaReserva = "", citaCirugia = "", tipoAtencion = "", estadoCita = "", pacId = "", noAdmision = "", medico = "", fDate = toDay, tDate = toDay, empresa = "";

String inclNoRel = request.getParameter("inclNoRel");
if (inclNoRel == null) inclNoRel = "n";
else inclNoRel = "y";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdoP = SQLMgr.getData("select nvl(get_sec_comp_param(-1,'CDC_CITAS_REALIZADA_VER_MONTO'),'N') as verCargos, nvl(get_sec_comp_param(-1,'CDC_VER_HORA_CIRUGIA_SOP'),'S') horaSop from dual");
	if (cdoP == null) {

		cdoP = new CommonDataObject();
		cdoP.addColValue("verCargos","N");
		}


	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if(fg.trim().equals("SOP")) sbFilter.append("  and sh.quirofano = 2  ");
	else if(fg.trim().equals("AMB"))sbFilter.append("  and sh.quirofano <> 2  ");

	if (!cds.trim().equals("")) { sbFilter.append(" and sh.unidad_admin = "); sbFilter.append(cds); }
	if (request.getParameter("habitacion") != null && !request.getParameter("habitacion").trim().equals("")){
		sbFilter.append(" and c.habitacion = '"); sbFilter.append(request.getParameter("habitacion")); sbFilter.append("'");
		habitacion = request.getParameter("habitacion");
	}
	if (request.getParameter("pacId") != null && !request.getParameter("pacId").trim().equals("")){
		sbFilter.append(" and c.pac_id = "); sbFilter.append(request.getParameter("pacId"));
		pacId = request.getParameter("pacId");
	}
	if (request.getParameter("noAdmision") != null && !request.getParameter("noAdmision").trim().equals("")){
		sbFilter.append(" and c.admision = "); sbFilter.append(request.getParameter("noAdmision"));
		noAdmision = request.getParameter("noAdmision");
	}
	if (request.getParameter("nombre_paciente") != null && !request.getParameter("nombre_paciente").trim().equals("")){
		sbFilter.append(" and c.nombre_paciente like '%"); sbFilter.append(request.getParameter("nombre_paciente")); sbFilter.append("%'");
		nombrePaciente = request.getParameter("nombre_paciente");
	}

	if (request.getParameter("medico") != null && !request.getParameter("medico").trim().equals("")){
		sbFilter.append(" and c.cod_medico = '"); sbFilter.append(request.getParameter("medico")); sbFilter.append("'");
		medico = request.getParameter("medico");
	}
	if (request.getParameter("nombre_medico") != null && !request.getParameter("nombre_medico").trim().equals("")){
		sbFilter.append(" and nvl(c.nombre_medico_externo,c.nombre_medico) like '%"); sbFilter.append(request.getParameter("nombre_medico")); sbFilter.append("%'");
		nombreMedico = request.getParameter("nombre_medico");
	}

	if (request.getParameter("proc_code") != null && !request.getParameter("proc_code").trim().equals("")){
		sbFilterXtra.append(" and aa.procedimientos like '%"); sbFilterXtra.append(request.getParameter("proc_code")); sbFilterXtra.append("%'");
		procCode = request.getParameter("proc_code");
	}
	if (request.getParameter("proc_name") != null && !request.getParameter("proc_name").trim().equals("")){
		sbFilterXtra.append(" and aa.procedimientos like '%"); sbFilterXtra.append(request.getParameter("proc_name")); sbFilterXtra.append("%'");
		procName = request.getParameter("proc_name");
	}

	if (request.getParameter("cod_tipo") != null && !request.getParameter("cod_tipo").trim().equals("")){
		sbFilter.append(" and c.cod_tipo = "); sbFilter.append(request.getParameter("cod_tipo"));
		codTipo = request.getParameter("cod_tipo");
	}

	if (request.getParameter("anestesia") != null && !request.getParameter("anestesia").trim().equals("")){
		sbFilter.append(" and c.anestesia = '"); sbFilter.append(request.getParameter("anestesia")); sbFilter.append("'");
		anestesia = request.getParameter("anestesia");
	}

	if (request.getParameter("forma_reserva") != null && !request.getParameter("forma_reserva").trim().equals("")){
		sbFilter.append(" and c.forma_reserva = '"); sbFilter.append(request.getParameter("forma_reserva")); sbFilter.append("'");
		formaReserva = request.getParameter("forma_reserva");
	}

	if (request.getParameter("cita_cirugia") != null && !request.getParameter("cita_cirugia").trim().equals("")){
		sbFilter.append(" and c.cita_cirugia = '"); sbFilter.append(request.getParameter("cita_cirugia")); sbFilter.append("'");
		citaCirugia = request.getParameter("cita_cirugia");
	}

	if (request.getParameter("hosp_amb") != null && !request.getParameter("hosp_amb").trim().equals("")){
		sbFilter.append(" and c.hosp_amb = '"); sbFilter.append(request.getParameter("hosp_amb")); sbFilter.append("'");
		tipoAtencion = request.getParameter("hosp_amb");
	}

	if (request.getParameter("estado_cita") != null && !request.getParameter("estado_cita").trim().equals("")){
		sbFilter.append(" and c.estado_cita = '"); sbFilter.append(request.getParameter("estado_cita")); sbFilter.append("'");
		estadoCita = request.getParameter("estado_cita");
	}

	if (request.getParameter("fDate") != null && !request.getParameter("fDate").trim().equals("") && request.getParameter("tDate") != null && !request.getParameter("tDate").trim().equals("")){
		sbFilter.append(" and trunc(c.hora_cita) between to_date('"); sbFilter.append(request.getParameter("fDate")); sbFilter.append("','dd/mm/yyyy') and to_date('"); sbFilter.append(request.getParameter("tDate")); sbFilter.append("','dd/mm/yyyy')");
		fDate = request.getParameter("fDate");
		tDate = request.getParameter("tDate");
	}

	if (fp.equals("RE")) {
		sbFilter.append(" and c.estado_cita = 'E'");
		if (inclNoRel.equalsIgnoreCase("n")) sbFilter.append(" and c.admision is not null");
	}

	if (request.getParameter("empresa") != null && !request.getParameter("empresa").equals("")) {
		sbFilter.append(" and ben.empresa = "); sbFilter.append(request.getParameter("empresa"));
		empresa = request.getParameter("empresa");
	}

	sbSql.append("select aa.* from(select sh.unidad_admin, c.habitacion, ");
	if (fg.equalsIgnoreCase("AMB")) sbSql.append("(select descripcion from tbl_cds_centro_servicio where codigo = sh.unidad_admin)||' - '||");
	sbSql.append("sh.descripcion as habitacion_desc, c.codigo, to_char(fecha_cita,'dd/mm/yyyy') as fecha_cita,to_char(c.hora_cita,'hh12:mi am') as hora_cita ,(select join(cursor( select '['||p.codigo||'] '||coalesce(p.nombre_corto,p.observacion,p.descripcion) from tbl_cdc_cita_procedimiento cp, tbl_cds_procedimiento p where cp.procedimiento = p.codigo and cp.cod_cita = c.codigo and fecha_cita = c.fecha_registro ) ,' ; ') as procedimientos from dual) as procedimientos,(select join(cursor( select p.codigo from tbl_cdc_cita_procedimiento cp, tbl_cds_procedimiento p where cp.procedimiento = p.codigo and cp.cod_cita = c.codigo and cp.fecha_cita = c.fecha_registro and nvl(cp.prioridad,cp.codigo) <= nvl(get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",'CDC_PRIORIDAD_CPT_SOL_INSUMOS'),100)) ,'~') as procedimientos from dual) as codProc,(select m.primer_nombre||' '||m.primer_apellido from tbl_adm_medico m, tbl_cdc_personal_cita pe where pe.cod_cita = c.codigo and m.codigo = pe.medico and pe.funcion in (select column_value  from table( select split((select get_sec_comp_param(-1,'COD_FUNC_CIRUJANO') from dual),',') from dual  )) and pe.fecha_cita = c.fecha_registro /*and pe.medico = c.cod_medico*/ and rownum = 1) as medico,getcama(c.pac_id,c.hosp_amb,c.admision,null) as cama, c.pac_id||'-'||c.admision as pid, c.nombre_paciente, getAseguradora2(c.pac_id,c.admision,decode(c.admision,null,c.empresa,ben.empresa)) as empresa, decode(c.estado_cita,'R','RESERVADA','C','CANCELADA','E','REALIZADA','T','TRANSFERIDA') as estado_cita, c.codigo as cod_cita, p.id_paciente cedula, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nac, c.persona_reserva, nvl(c.nombre_medico_externo,c.nombre_medico) nombre_medico_externo, decode(c.forma_reserva,'T','TELEFONICA','E','E-MAIL','PERSONALMENTE') forma_reserva, decode(c.cita_cirugia,'E','ELECTIVA','URGENCIA') tipo_cita, decode(c.hosp_amb,'H','HOSPITALIZADA','AMBULATORIA') as tipo_atencion, c.persona_q_llamo, c.telefono, c.observacion,to_char(c.fecha_registro,'dd/mm/yyyy') as fecha_reg,c.usuario_cancelacion, to_char(c.fecha_cancelacion,'dd/mm/yyyy hh12:mi:ss AM') as fecha_cancelacion, c.motivo_cancelacion,c.hora_cita horaC, c.usuario_creacion, to_char(c.fecha_creacion,'dd/mm/yyyy hh:mi pm') as fecha_creacion, decode('");
	sbSql.append(cdoP.getColValue("verCargos"));
	//sbSql.append("','S',nvl(fn_fac_total_cargos(c.compania,c.pac_id,c.admision,null),0),0) as totalCargos");
	sbSql.append("','S',nvl((select sum(decode(centro_servicio,0,0,decode(tipo_transaccion,'C',coalesce(difpaq_cantidad,cantidad),-coalesce(difpaq_cantidad,cantidad))) * (monto + nvl(recargo,0))) from tbl_fac_detalle_transaccion where compania = c.compania and pac_id = c.pac_id and fac_secuencia = c.admision and (nvl(ref_type,'-') <> 'PAQ' or nvl(difpaq_cantidad,0) > 0)),0) + nvl((select z.precio_paq from tbl_adm_clasif_x_plan_conv z where paquete = 'S' and exists (select null from tbl_fac_detalle_transaccion where ref_type = 'PAQ' and pac_id = c.pac_id and fac_secuencia = c.admision and compania = c.compania and ref_id = z.cod_reg) and exists (select null from tbl_adm_beneficios_x_admision where pac_id = c.pac_id and admision = c.admision and prioridad = 1 and estado = 'A' and empresa = z.empresa and convenio = z.convenio and plan = z.plan and categoria_admi = z.categoria_admi and tipo_admi = z.tipo_admi and clasif_admi = z.clasif_admi)),0),0) as totalCargos, decode('");
	sbSql.append(cdoP.getColValue("verCargos"));
	sbSql.append("','S',nvl((select sum(decode(centro_servicio,0,decode(tipo_transaccion,'H',coalesce(difpaq_cantidad,cantidad),-coalesce(difpaq_cantidad,cantidad))) * (monto + nvl(recargo,0))) from tbl_fac_detalle_transaccion where compania = c.compania and pac_id = c.pac_id and fac_secuencia = c.admision and (nvl(ref_type,'-') <> 'PAQ' or nvl(difpaq_cantidad,0) > 0)),0),0) as totalHon");
	sbSql.append(" from tbl_cdc_cita c, vw_adm_paciente p ,tbl_sal_habitacion sh , tbl_adm_beneficios_x_admision ben where c.pac_id = p.pac_id(+) and sh.compania = c.compania and sh.codigo=c.habitacion and ben.prioridad(+) = 1 and nvl(ben.estado(+),'A') = 'A' and ben.pac_id(+) = c.pac_id and ben.admision(+) = c.admision  and c.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append("  ) aa");
	if (sbFilterXtra.length() != 0) sbSql.append(sbFilterXtra.replace(0,4," where"));
	sbSql.append(" order by unidad_admin, habitacion, horaC asc ");

	if (request.getParameter("beginSearch")!=null){
		StringBuffer sbTmp = new StringBuffer();
		sbTmp.append(" select * from (select rownum as rn, a.* from (");
		sbTmp.append(sbSql);
		sbTmp.append(") a) where rn between ");
		sbTmp.append(previousVal);
		sbTmp.append(" and ");
		sbTmp.append(nextVal);
		al = SQLMgr.getDataList(sbTmp.toString());
		sbTmp = new StringBuffer();
		sbTmp.append("select count(*) from (");
		sbTmp.append(sbSql);
		sbTmp.append(")");
		rowCount = CmnMgr.getCount(sbTmp.toString());
	}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp = "Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal = nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Consulta de Citas en Salón de Operación - '+document.title;

function printList(opt){
if(opt==2)abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cita/print_citas_consultas_list2.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString().equals("")?"ALL":sbFilter.toString())%>&appendFilterXtra=<%=IBIZEscapeChars.forURL(sbFilterXtra.toString().equals("")?"ALL":sbFilterXtra.toString())%>&fp=<%=fp.equals("")?"ALL":fp%>&fg=<%=fg.equals("")?"ALL":fg%>&verCargos=<%=cdoP.getColValue("verCargos")%>&horaSop=<%=cdoP.getColValue("horaSop")%>&pCtrlHeader=false&inclNoRel=<%=inclNoRel%>');
else if(opt==3)abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cita/rpt_consumo_ts.rptdesign&pFg=<%=fg%>&pHabitacion=<%=habitacion%>&pPacId=<%=pacId%>&pAdmision=<%=noAdmision%>&pNombrePac=<%=nombrePaciente.trim()%>&pMedico=<%=medico%>&pNombreMed=<%=nombreMedico.trim()%>&pProcCode=<%=procCode.trim()%>&pProcName=<%=procName.trim()%>&pCodTipo=<%=codTipo%>&pAnestesia=<%=anestesia%>&pFormaReserva=<%=formaReserva%>&pCitaCirugia=<%=citaCirugia%>&pTipoAtencion=<%=tipoAtencion%>&pFDate=<%=fDate%>&pTDate=<%=tDate%>&pEmpresa=<%=empresa%>&pCtrlHeader=true');
else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cita/print_citas_consultas_list.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString().equals("")?"ALL":sbFilter.toString())%>&appendFilterXtra=<%=IBIZEscapeChars.forURL(sbFilterXtra.toString().equals("")?"ALL":sbFilterXtra.toString())%>&fp=<%=fp.equals("")?"ALL":fp%>&fg=<%=fg.equals("")?"ALL":fg%>&verCargos=<%=cdoP.getColValue("verCargos")%>&pCtrlHeader=false&inclNoRel=<%=inclNoRel%>');}

var xHeight = 0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}

function showPacienteList(){abrir_ventana1('../common/sel_paciente.jsp?fp=citas_cons');}
function showMedicoList(fg){abrir_ventana1('../common/search_medico.jsp?fp=citas_cons&fg=');}
function showProcList(fg){abrir_ventana1('../common/sel_procedimiento.jsp?fp=citas_cons&cs=24');}

$(function(){
	 //tooltip
		$(".tpContent").tooltip({
		content: function () {
				var i = $(this).data("i");
			var _tpContent = $("#tpContent"+i).val();
			var $content = "<span style='font-size:11px; display: inline-block;'>" + _tpContent + "</span>";
			if (!$content) $content = "";
			return $content;
		}
		});

		$('#empresa').css({width:200})
});
function showInsumos(fecha,codigo,codProc){
abrir_ventana1('../admision/procedimientos_config_insumos.jsp?fp=citas_cons&codProc='+codProc+'&codCita='+codigo+'&fechaCita='+fecha);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CITAS SALON DE OPERACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td>
		<table width="100%" cellpadding="0" cellspacing="1">
			<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("beginSearch","")%>
			<%=fb.hidden("fg",fg)%>
			<tr class="TextFilter">
				<td width="100%">
<%
if (fg.equalsIgnoreCase("AMB")) {
	sbSql = new StringBuffer();
	if (!UserDet.getUserProfile().contains("0")) {
		sbSql.append(" and a.codigo in (");
		if (session.getAttribute("_cds") != null) sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
		else sbSql.append("-1");
		sbSql.append(")");
	}
%>
					<cellbytelabel>Centro de Servicio</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(),"select a.codigo, a.codigo||' - '||a.descripcion, a.codigo from tbl_cds_centro_servicio a where a.flag_cds in ('IMA', 'CAR', 'LAB','EJE','CEX')"+sbSql.toString(),"cds",cds,false,false,0,"Text10","","onChange=\"javascript:loadXML('../xml/hab_cds_x_unidad.xml','habitacion','','VALUE_COL','LABEL_COL','"+session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','S')\"",null,"S")%>
					Area de Cita<!--Habitaci&oacute;n-->
					<%=fb.select("habitacion","","",false,false,0,"Text10",null,null,null,"S")%>
					<script language="javascript">
					loadXML('../xml/hab_cds_x_unidad.xml','habitacion','<%=habitacion%>','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-'+document.search01.cds.value,'KEY_COL','S');
					</script></br>
<% } else { %>
					<cellbytelabel>Quir&oacute;fano</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_sal_habitacion where quirofano = 2 order by 2", "habitacion",habitacion, false, false, 0, "Text10", null, "",null,"T")%>&nbsp;&nbsp;
<% } %>

					<cellbytelabel>Paciente</cellbytelabel>
					<%=fb.intBox("pacId",pacId,false,false,false,7,"Text10",null,"")%>-<%=fb.intBox("noAdmision",noAdmision,false,false,false,3,"Text10",null,"")%>
					<%=fb.textBox("nombre_paciente",nombrePaciente,false,false,false,40,"Text10","","")%>
					<%=fb.button("btnPaciente","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>

					&nbsp;&nbsp;<cellbytelabel>M&eacute;dico</cellbytelabel>
					<%=fb.intBox("medico",medico,false,false,false,7,"Text10",null,"")%>
					<%=fb.textBox("nombre_medico",nombreMedico,false,false,false,40,"Text10","","")%>
					<%=fb.button("btnMed","...",true,false,"Text10",null,"onClick=\"javascript:showMedicoList()\"")%>
				</td>
			</tr>
			<tr class="TextFilter">
				<td width="100%">
					<cellbytelabel>Procedimiento</cellbytelabel>
					<%=fb.intBox("proc_code",procCode,false,false,false,7,"Text10",null,"")%>
					<%=fb.textBox("proc_name",procName,false,false,false,30,"Text10","","")%>
					<%=fb.button("btnProc","...",true,false,"Text10",null,"onClick=\"javascript:showProcList()\"")%>

					&nbsp;&nbsp;<cellbytelabel>Clasificaci&oacute;n</cellbytelabel>
										<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cdc_tipo_cita","cod_tipo",codTipo,false,false,0,"Text10","width:120px;","","","T")%>

					&nbsp;&nbsp;<cellbytelabel>Anestesia?</cellbytelabel>
										<%=fb.select("anestesia","S=SI,N=NO",anestesia,false,false,0,"Text10","","","","T")%>

					&nbsp;&nbsp;<cellbytelabel>Forma Reservaci&oacute;n</cellbytelabel>
					<%=fb.select("forma_reserva","T=TELEFONICA,P=PERSONALMENTE,E=E-MAIL",formaReserva,false,false,0,"Text10","","","","T")%>

					&nbsp;&nbsp;<cellbytelabel>Tipo de Cita</cellbytelabel>
					<%=fb.select("cita_cirugia","E=ELECTIVA,U=URGENCIA",citaCirugia,false,false,0,"Text10","","","","T")%>

				</td>
			</tr>

			<tr class="TextFilter">
				<td width="100%"><cellbytelabel>Tipo Atenci&oacute;n</cellbytelabel>
										<%=fb.select("hosp_amb","H=HOSPITALIZADA,A=AMBULATORIA,E=EXTERNO,U=URGENCIA",tipoAtencion,false,false,0,"Text10","","","","T")%>

					<% if (fp.equals("RE")) { %>
					&nbsp;&nbsp;<label for="inclNoRel">Incluir Citas No Relacionadas</label><%=fb.checkbox("inclNoRel","",!inclNoRel.equalsIgnoreCase("n"),false)%>
					<% } else { %>
					&nbsp;&nbsp;<cellbytelabel>Estado Cita</cellbytelabel>
					<%=fb.select("estado_cita","C=CANCELADA,R=RESERVADA,T=TRANSFERIDA",estadoCita,false,false,0,"Text10","","","","T")%>
					<% } %>

					&nbsp;&nbsp;
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="nameOfTBox1" value="fDate" />
						<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
						<jsp:param name="nameOfTBox2" value="tDate" />
						<jsp:param name="valueOfTBox2" value="<%=tDate%>" />
						<jsp:param name="fieldClass" value="Text10" />
						<jsp:param name="buttonClass" value="Text10" />
					</jsp:include>
										&nbsp;&nbsp;Aseguradora
										<%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_adm_empresa  where estado = 'A' order by 2","empresa",empresa,false,false,false,0,"Text10","","","","S")%>
										&nbsp;&nbsp;

					<%=fb.submit("go","Ir")%>
				</td>
			</tr>

			<%=fb.formEnd()%>
		</%%>
	</td>
</tr>

<tr>
	<td align="right">&nbsp;
		<authtype type='0'><a href="javascript:printList(1)" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
		&nbsp;&nbsp;&nbsp;&nbsp;<authtype type='50'><a href="javascript:printList(2)" class="Link00">[ <cellbytelabel>Imprimir Reporte Detallado</cellbytelabel> ]</a></authtype>
		<% if (fp.equalsIgnoreCase("RE") && fg.equalsIgnoreCase("SOP")) { %>&nbsp;&nbsp;&nbsp;&nbsp;<authtype type='51'><a href="javascript:printList(3)" class="Link00">[ <cellbytelabel>Imprimir Consumo</cellbytelabel> ]</a></authtype><% } %>
	</td>
</tr>

<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("habitacion",habitacion)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("nombreMedico",nombreMedico)%>
				<%=fb.hidden("procCode",procCode)%>
				<%=fb.hidden("procName",procName)%>
				<%=fb.hidden("codTipo",codTipo)%>
				<%=fb.hidden("nombrePaciente",nombrePaciente)%>
				<%=fb.hidden("anestesia",anestesia)%>
				<%=fb.hidden("formaReserva",formaReserva)%>
				<%=fb.hidden("citaCirugia",citaCirugia)%>
				<%=fb.hidden("tipoAtencion",tipoAtencion)%>
				<%=fb.hidden("estadoCita",estadoCita)%>
				<%=fb.hidden("medico",medico)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("inclNoRel",inclNoRel)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("habitacion",habitacion)%>
				<%=fb.hidden("nombreMedico",nombreMedico)%>
				<%=fb.hidden("procCode",procCode)%>
				<%=fb.hidden("procName",procName)%>
				<%=fb.hidden("codTipo",codTipo)%>
				<%=fb.hidden("nombrePaciente",nombrePaciente)%>
				<%=fb.hidden("anestesia",anestesia)%>
				<%=fb.hidden("formaReserva",formaReserva)%>
				<%=fb.hidden("citaCirugia",citaCirugia)%>
				<%=fb.hidden("tipoAtencion",tipoAtencion)%>
				<%=fb.hidden("estadoCita",estadoCita)%>
				<%=fb.hidden("medico",medico)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("inclNoRel",inclNoRel)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
				</tr>
		</table>
	</td>
</tr>

<tr>
	<td class="TableLeftBorder TableRightBorder">
		<div id="_cMain" class="Container">
		<div id="_cContent" class="ContainerContent">
			<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("index","")%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("fg",fg)%>
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
					<tr class="TextHeader" align="center">
						<td width="7%"><cellbytelabel>Fecha</cellbytelabel></td>
						<td width="<%=!fp.equals("RE")?"18%":((cdoP.getColValue("verCargos").trim().equals("S"))?"22":"27%")%>"><cellbytelabel>Procedimiento</cellbytelabel></td>
						<td width="15%"><cellbytelabel>M&eacute;dico</cellbytelabel></td>
						<td width="18%"><cellbytelabel>Paciente&nbsp;<span class="miniinfoBtn">i</span></cellbytelabel></td>
						<td width="5%"><cellbytelabel>Sala</cellbytelabel></td>
						<td width="15%"><cellbytelabel>Aseguradora</cellbytelabel></td>
						<%if(cdoP.getColValue("verCargos").trim().equals("S")){%>
						<td width="5%" align="right"><cellbytelabel>Total Cargos</cellbytelabel></td>
						<td width="5%" align="right"><cellbytelabel>Total Hon.</cellbytelabel></td>
						<%}%>
						<td width="10%"><cellbytelabel>Creado Por</cellbytelabel></td>

						<%if(!fp.equals("RE")){%>
						<td width="7%"><cellbytelabel>Estado</cellbytelabel></td>
						<%}%>
					</tr>
					<%
					String gHabitacion = "";
					int totXhab = 0;
					for (int i=0; i<al.size(); i++){
						CommonDataObject cdo = (CommonDataObject) al.get(i);
						String color = "TextRow02";
						if (i % 2 == 0) color = "TextRow01";

							if (i!=0){
								if (!gHabitacion.equals(cdo.getColValue("habitacion"))){
								%>
									<tr class="TextHeader02">
										<td colspan="<%=(cdoP.getColValue("verCargos").trim().equals("S"))?"10":"8"%>">TOTAL: <%=totXhab%></td>
									</tr>

								<%
								totXhab=0;
								}
							}
						if (!gHabitacion.equals(cdo.getColValue("habitacion"))){
							%>
							<tr class="TextHeader02">
								<td colspan="<%=(cdoP.getColValue("verCargos").trim().equals("S"))?"10":"8"%>"><%=cdo.getColValue("habitacion_desc")%></td>
							</tr>
						<%}%>

						<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
							<td align="center"><%=cdo.getColValue("fecha_cita")%> <%=cdo.getColValue("hora_cita")%></td>
							<td>
							<authtype type='52'><a href="javascript:showInsumos('<%=cdo.getColValue("fecha_reg")%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("codProc")%>')" class="Link00">[ <cellbytelabel><%=cdo.getColValue("procedimientos")%></cellbytelabel> ]</a></authtype>

							</td>
							<td><%=cdo.getColValue("medico")%></td>
							<td title="" data-i="<%=i%>" class="tpContent"><%=cdo.getColValue("nombre_paciente")%></td>
							<td align="center"><%=cdo.getColValue("cama")%></td>
							<td><%=cdo.getColValue("empresa")%></td>
							<%if(cdoP.getColValue("verCargos").trim().equals("S")){%>
							<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("totalCargos"))%></td>
							<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("totalHon"))%></td>
							<%}%>
							<td align="center"><%=cdo.getColValue("usuario_creacion")%></br><%=cdo.getColValue("fecha_creacion")%></td>
							<%if(!fp.equals("RE")){%>
							<td align="center"><%=cdo.getColValue("estado_cita")%></td>
							<%}
							String tooltip = "";
							if (fp.equals("RE"))
								 tooltip = "<span> <div style='text-align:center'><strong>"+cdo.getColValue("nombre_paciente")+"</strong></div><br /><strong>#Cita:</strong>"+cdo.getColValue("cod_cita")+"<br /><strong>PID:</strong> "+cdo.getColValue("pid")+"<br /><strong>C&eacute;dula:</strong> "+cdo.getColValue("cedula")+"<br /><strong>F.Nac.:</strong> "+cdo.getColValue("fecha_nac")+"<br /><strong>Reservada por:</strong> "+cdo.getColValue("persona_reserva")+"<br /><strong>M&eacute;dico Ref.:</strong> "+cdo.getColValue("nombre_medico_externo")+"<br /><strong>Tipo cita:</strong> "+cdo.getColValue("tipo_cita")+"<br /><strong>Forma:</strong> "+cdo.getColValue("forma_reserva")+"<br /><strong>Tipo Pac.:</strong> "+cdo.getColValue("tipo_atencion")+"<br /><strong>Llamó.:</strong> "+cdo.getColValue("persona_q_llamo")+" <br /><strong>Tel.:</strong> "+cdo.getColValue("telefono")+" </span>";
							else
								 tooltip = "<span><strong>#Cita:</strong> "+cdo.getColValue("cod_cita")+" - "+cdo.getColValue("fecha_reg")+"<br /><strong>Reservada por:</strong> "+cdo.getColValue("persona_reserva")+"<br /><strong>M&eacute;dico Ref.:</strong> "+cdo.getColValue("nombre_medico_externo")+"<br /><strong>Tipo cita:</strong> "+cdo.getColValue("tipo_cita")+"<br /><strong>Forma:</strong> "+cdo.getColValue("forma_reserva")+"<br /><strong>Tipo Pac.:</strong> "+cdo.getColValue("tipo_atencion")+"<br /><strong>Llamó.:</strong> "+cdo.getColValue("persona_q_llamo")+"<br /><strong>Tel.:</strong> "+cdo.getColValue("telefono")+" </span>";
							%>
							<%=fb.hidden("tpContent"+i,tooltip)%>
						</tr>
					<%
					totXhab++;
					gHabitacion = cdo.getColValue("habitacion");

										if (!(cdo.getColValue("observacion","")).equals("")||!(cdo.getColValue("motivo_cancelacion","")).equals("")){
										%>

										<tr class="<%=color%>">
										<td align="right">Observaci&oacute;n:&nbsp;&nbsp;</td>
										<td colspan="3"><%=cdo.getColValue("observacion")%></td>
					<td colspan="<%=(cdoP.getColValue("verCargos").trim().equals("S"))?"6":"4"%>">MOT. CANCEL.: <%=cdo.getColValue("motivo_cancelacion")%>&nbsp;&nbsp;[Cancelado Por: <%=cdo.getColValue("usuario_cancelacion")%>&nbsp;&nbsp;<%=cdo.getColValue("fecha_cancelacion")%>]</td>
										</tr>
										<%}}%>

					<tr class="TextHeader02">
						<td colspan="<%=(cdoP.getColValue("verCargos").trim().equals("S"))?"10":"8"%>">TOTAL: <%=totXhab%></td>
					</tr>
					<%
					 totXhab = 0;
					%>

				</table>
			<%=fb.formEnd()%>
		</div>
		</div>
	</td>
</tr>

<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("habitacion",habitacion)%>
				<%=fb.hidden("nombreMedico",nombreMedico)%>
				<%=fb.hidden("procCode",procCode)%>
				<%=fb.hidden("procName",procName)%>
				<%=fb.hidden("codTipo",codTipo)%>
				<%=fb.hidden("nombrePaciente",nombrePaciente)%>
				<%=fb.hidden("anestesia",anestesia)%>
				<%=fb.hidden("formaReserva",formaReserva)%>
				<%=fb.hidden("citaCirugia",citaCirugia)%>
				<%=fb.hidden("tipoAtencion",tipoAtencion)%>
				<%=fb.hidden("estadoCita",estadoCita)%>
				<%=fb.hidden("medico",medico)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("inclNoRel",inclNoRel)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("habitacion",habitacion)%>
				<%=fb.hidden("nombreMedico",nombreMedico)%>
				<%=fb.hidden("procCode",procCode)%>
				<%=fb.hidden("procName",procName)%>
				<%=fb.hidden("codTipo",codTipo)%>
				<%=fb.hidden("nombrePaciente",nombrePaciente)%>
				<%=fb.hidden("anestesia",anestesia)%>
				<%=fb.hidden("formaReserva",formaReserva)%>
				<%=fb.hidden("citaCirugia",citaCirugia)%>
				<%=fb.hidden("tipoAtencion",tipoAtencion)%>
				<%=fb.hidden("estadoCita",estadoCita)%>
				<%=fb.hidden("medico",medico)%>
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("inclNoRel",inclNoRel)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%}%>