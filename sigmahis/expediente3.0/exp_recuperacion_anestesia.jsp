<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.DatosCirugia"%>
<%@ page import="issi.expediente.DetalleRecuperacion"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="DCMgr" scope="page" class="issi.expediente.DatosCirugiaMgr" />
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
DCMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

DatosCirugia cirugia = new DatosCirugia();

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fecha = request.getParameter("fecha");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (desc == null) desc = "";

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String toDay = cDateTime.substring(0,10);

int tHe=0, tM15=0, tM30=0, tM60=0, tM90=0, tM120=0, tHs=0;
String id_cirugia = request.getParameter("id_cirugia");
String key = "";
int ld = 0;

if (fecha == null) fecha = "";
if (fecha.trim().equals("")) fecha = toDay;
else if (fecha.trim().equals("null")) fecha = toDay;

if (id_cirugia==null) id_cirugia = "0";
else if(id_cirugia.trim().equals("null")) id_cirugia = "0";

if (request.getMethod().equalsIgnoreCase("GET")) {

	sbSql.append("select codigo, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fc, to_char(fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fm, usuario_creacion as uc, usuario_modif as um, to_char(fecha_registro,'dd/mm/yyyy') as fecha_registro from tbl_sal_datos_cirugia where pac_id = ").append(pacId).append(" and secuencia = ").append(noAdmision).append(" order by codigo desc");
	al2 = SQLMgr.getDataList(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select a.codigo, to_char(a.fecha_registro,'dd/mm/yyyy') as fechaRegistro, nvl(to_char(a.hora_inicio,'hh12:mi:ss am'),' ') as horaInicio, nvl(to_char(a.hora_final,'hh12:mi:ss am'),' ') as horaFinal, a.tipo_cirugia as tipoCirugia, a.procedimiento, diagnostico, observaciones, emp_provincia as empProvincia, emp_sigla as empSigla, a.emp_tomo as empTomo, a.emp_asiento as empAsiento, a.emp_compania as empCompania, a.usuario_creacion as usuarioCreacion, a.usuario_modif as usuarioModif, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, to_char(a.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fechaModif, nvl(to_char(a.hora_anes,'hh12:mi:ss am'),' ') as horaAnes, nvl(to_char(a.hora_anes_f,'hh12:mi:ss am'),' ') as horAnesF, a.emp_id as empId, a.procedimiento_desc as procedimientoDesc from tbl_sal_datos_cirugia a where a.pac_id = ").append(pacId).append(" and a.secuencia = ").append(noAdmision).append(" and trunc(a.fecha_registro) = to_date('").append(fecha).append("','dd/mm/yyyy') and a.codigo = ").append(id_cirugia);
	cirugia = (DatosCirugia) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),DatosCirugia.class);
	if(cirugia == null) {
		cirugia = new DatosCirugia();
		cirugia.setCodigo("0");
		cirugia.setFechaRegistro(cDateTime.substring(0,10));
		cirugia.setHoraInicio("");
		cirugia.setHoraFinal("");
		cirugia.setEmpCompania((String) session.getAttribute("_companyId"));
		//cirugia.setTipoCirugia("PRO");//('CME', 'PRO', 'CMA'
		cirugia.setDiagnostico("490");
		cirugia.setUsuarioCreacion(UserDet.getUserName());
		cirugia.setUsuarioModif(UserDet.getUserName());
		cirugia.setFechaCreacion(cDateTime);
		cirugia.setFechaModif(cDateTime);
		cirugia.setHoraAnes("");
		cirugia.setHoraAnesF("");
		if (!viewMode) modeSec = "add";
	} else if (!viewMode) modeSec = "edit";
	sbSql = new StringBuffer();
	sbSql.append("select b.dat_cirugia as datCirugia, a.codigo, 0 as codAnestesia, a.descripcion, -1 as codEscala, b.minutos, nvl(b.escala_he,-1) as escalaHe, nvl(b.escala_min15,-1) as escalamin15, nvl(b.escala_min30,-1) as escalamin30, nvl(b.escala_min60,-1) as escalamin60, nvl(b.escala_min90,-1) as escalamin90, nvl(b.escala_min120,-1) as escalamin120, nvl(b.escala_hs,-1) as escalaHs from tbl_sal_recuperacion_anestesia a, (select dat_cirugia, recup_anestesia, detalle_recup, minutos, escala_he, escala_min15, escala_min30, escala_min60, escala_min90, escala_min120, escala_hs from tbl_sal_recuperacion where pac_id = ").append(pacId).append(" and secuencia = ").append(noAdmision).append(" and dat_cirugia = ").append(id_cirugia).append(" order by 2) b where a.codigo = b.recup_anestesia(+) union select 0, a.recup_anestesia, a.codigo, a.descripcion, a.escala as escala, -1, -1, 00, 00, 00, 00, 00, 00 from tbl_sal_detalle_recuperacion a order by 2, 3");
	al = SQLMgr.getDataList(sbSql.toString());
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
document.title = 'RECUPERACION DE ANESTESIA - '+document.title;
function setEscala(val,k,cod){
		var campo = document.getElementById("time").value;
		document.getElementById(""+campo+k).value = val;
		ocultar('',k,'');
}
function doAction(){}

function ocultar(obj,nombreCapa,val){
		nombreCapa = "obs-"+nombreCapa;
		<%if(modeSec.equalsIgnoreCase("add")){%>
		$("#"+nombreCapa).toggle();
		<%}%>
		$("#time").val(val);
}

function procedimientoList(){abrir_ventana1('../expediente/listado_procedimiento.jsp?fp=exp_recuperacion_anestesia');}

function setEvaluacion(k){
		var code=eval('document.listado.codigo'+k).value;
		var fecha=eval('document.listado.fechaRegistro'+k).value;
		var mode='view';
		if(fecha=='<%=cDateTime.substring(0,10)%>'){
				mode = 'edit';
		}
		window.location= '../expediente3.0/exp_recuperacion_anestesia.jsp?modeSec='+mode+'&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id_cirugia='+code+'&desc=<%=desc%>';
}
function add(){
		window.location='../expediente3.0/exp_recuperacion_anestesia.jsp?mode=<%=mode%>&modeSec=add&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id_cirugia=0&desc=<%=desc%>';
}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_42.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&id_cirugia=<%=id_cirugia%>");}

function doSubmit () {
	var totalhe = totalmin15 = totalmin30 = totalmin60 = totalmin90 = totalmin120 =  totalhs = 0;
	$(".escala-type").each(function(){
		var self = $(this);
		var type = self.data("type");

		if (type == 'he') {
		 var val = self.val() || '0';
		 totalhe = totalhe + parseInt(val, 10);
		}
		if (type == 'min15') {
			var val = self.val() || '0';
			totalmin15 = totalmin15 + parseInt(val, 10);
		}
		if (type == 'min30') {
			var val = self.val() || '0';
			totalmin30 = totalmin30 + parseInt(val, 10);
		}
		if (type == 'min60') {
			var val = self.val() || '0';
			totalmin60 = totalmin60 + parseInt(val, 10);
		}
		if (type == 'min90') {
			var val = self.val() || '0';
			totalmin90 = totalmin90 + parseInt(val, 10);
		}
		if (type == 'min120') {
			var val = self.val() || '0';
			totalmin120 = totalmin120 + parseInt(val, 10);
		}
		if (type == 'hs') {
			var val = self.val() || '0';
			totalhs = totalhs + parseInt(val, 10);
		}
	});
	$("#totalhe").val(totalhe)
	$("#totalmin15").val(totalmin15)
	$("#totalmin30").val(totalmin30)
	$("#totalmin60").val(totalmin60)
	$("#totalmin90").val(totalmin90)
	$("#totalmin120").val(totalmin120)
	$("#totalhs").val(totalhs)
}
function verHistorial() {$("#hist_container").toggle();}
function showMeasurement(opt) {
	if (opt==0)abrir_ventana1('../expediente/list_measurement_pac.jsp?pacId=<%=pacId%>&admision=<%=noAdmision%>');
	else if (opt==1)abrir_ventana1('../expediente/list_measurement_pac_interval.jsp?pacId=<%=pacId%>&admision=<%=noAdmision%>');
}
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">

<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform2">
<%fb = new FormBean2("listado",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("desc",desc)%>
		<table cellspacing="0" class="table pull-right table-striped table-custom-2">
				<tr>
			<td align="right">
				<%if(!mode.trim().equalsIgnoreCase("view")){%>
				<%=fb.button("agregar","Agregar Evaluación",true,false,"btn btn-inverse btn-sm|fa fa-plus fa-printico",null,"onclick=\"add()\"")%>
				<%}%>
				<%=fb.button("imprimir","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:printExp()\"")%>
				<%=fb.button("btnHistory","Historial",false,false,"btn btn-inverse btn-sm|fa fa-eye fa-printico",null,"onClick=\"javascript:verHistorial()\"")%>
				<%=fb.button("mediciones","Resultado Mediciones",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:showMeasurement(0)\"")%>
				<%=fb.button("medicionesInt","Mediciones x Intervalo",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:showMeasurement(1)\"")%>
			</td>
		</tr>
			</table>

			<div class="table-wrapper" id="hist_container" style="display:none">
				<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<thead>
		<tr class="bg-headtabla2">
			<th><cellbytelabel>C&oacute;digo</cellbytelabel></th>
			<th><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></th>
			<th><cellbytelabel>Usuario Creaci&oacute;n</cellbytelabel></th>
						<th><cellbytelabel>Fecha Modificaci&oacute;n</cellbytelabel></th>
			<th><cellbytelabel>Usuario Modificaci&oacute;n</cellbytelabel></th>
		</tr>
				</thead>
				<tbody>
				<%
				for (int i = 0; i< al2.size(); i++){
						CommonDataObject cdo1 = (CommonDataObject) al2.get(i);
				%>
						<%=fb.hidden("codigo"+i,cdo1.getColValue("codigo"))%>
						<%=fb.hidden("fechaRegistro"+i,cdo1.getColValue("fecha_registro"))%>
						<tr class="pointer" onClick="javascript:setEvaluacion(<%=i%>)">
								<td><%=cdo1.getColValue("codigo")%></td>
								<td><%=cdo1.getColValue("fc")%></td>
								<td><%=cdo1.getColValue("uc")%></td>
								<td><%=cdo1.getColValue("fm")%></td>
								<td><%=cdo1.getColValue("um")%></td>
						</tr>
				<%}%>
		</tbody>
		</table>
		</div>
<%=fb.formEnd(true)%>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
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
<%=fb.hidden("time","")%>
<%=fb.hidden("valAnterior","0")%>
<%=fb.hidden("usuarioCreacion",cirugia.getUsuarioCreacion())%>
<%=fb.hidden("fechaCreacion",cirugia.getFechaCreacion())%>
<%=fb.hidden("usuarioModif",cirugia.getUsuarioModif())%>
<%=fb.hidden("fechaModif",cirugia.getFechaModif())%>
<%=fb.hidden("datCirugia",cirugia.getCodigo())%>
<%=fb.hidden("tipoCirugia",cirugia.getTipoCirugia())%>
<%=fb.hidden("diagnostico",cirugia.getDiagnostico())%>
<%=fb.hidden("empProvincia",cirugia.getEmpProvincia())%>
<%=fb.hidden("empSigla",cirugia.getEmpSigla())%>
<%=fb.hidden("empTomo",cirugia.getEmpTomo())%>
<%=fb.hidden("empAsiento",cirugia.getEmpAsiento())%>
<%=fb.hidden("empCompania",cirugia.getEmpCompania())%>
<%=fb.hidden("horaAnes",cirugia.getHoraAnes())%>
<%=fb.hidden("horaAnesF",cirugia.getHoraAnesF())%>
<%=fb.hidden("empId ",cirugia.getEmpId())%>
<%=fb.hidden("desc ",desc)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("id_cirugia",id_cirugia)%>
<tr>
		<td colspan="8" class="controls form-inline">
				<cellbytelabel id="4">Fecha</cellbytelabel>:
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fechaRegistro" />
				<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
				<jsp:param name="valueOfTBox1" value="<%=cirugia.getFechaRegistro()%>" />
				</jsp:include>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<cellbytelabel id="5">Hora Entrada</cellbytelabel>:
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi:ss am"/>
				<jsp:param name="nameOfTBox1" value="horaInicio" />
				<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
				<jsp:param name="valueOfTBox1" value="<%=cirugia.getHoraInicio()%>" />
				</jsp:include>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<cellbytelabel id="6">Hora Salida</cellbytelabel>:
				<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi:ss am"/>
				<jsp:param name="nameOfTBox1" value="horaFinal" />
				<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
				<jsp:param name="valueOfTBox1" value="<%=cirugia.getHoraFinal()%>" />
				</jsp:include>
		</td>
</tr>
<tr>
		<td><cellbytelabel id="7">Operaci&oacute;n</cellbytelabel></td>
		<td colspan="7">
				<%=fb.hidden("procedimiento",cirugia.getProcedimiento())%>
				<%=fb.textarea("procedimientoDesc",cirugia.getProcedimientoDesc(),true,false,viewMode,60,1,2000,"form-control input-sm","width:100%",null)%>
				<%//=fb.textBox("procedimiento",cirugia.getProcedimiento(),true,false,true,5,"form-control input-sm","width:100%",null)%>
				<%//=fb.textBox("desProc",cirugia.getDescripcion(),false,true,viewMode,55,"form-control input-sm","width:100%",null)%>
				<%//=fb.button("oper","...",true,viewMode,null,null,"onClick=\"javascript:procedimientoList()\"","seleccionar Operación")%>
		</td>
</tr>
<tr>
		<td><cellbytelabel id="8">Observaciones</cellbytelabel>: </td>
		<td colspan="7"><%=fb.textarea("observaciones",cirugia.getObservaciones(),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%",null)%></td>
</tr>

<tr class="bg-headtabla">
		<td colspan="8"><cellbytelabel id="9">Escala de Recuperaci&oacute;n Post - Anestesica</cellbytelabel></td>
</tr>

<tr class="bg-headtabla2" align="center">
		<td width="50%">&nbsp;</td>
		<td width="7%"><cellbytelabel id="10">HE</cellbytelabel></td>
		<td width="7%">15</td>
		<td width="7%">30</td>
		<td width="7%">60</td>
		<td width="7%">90</td>
		<td width="7%">120</td>
		<td width="7%"><cellbytelabel id="11">HS</cellbytelabel></td>
</tr>
<%
String cod = "";
String codAnt = "";
int lc = 0;
for (int i=0; i<al.size(); i++){
	key = al.get(i).toString();
	cdo = (CommonDataObject) al.get(i);
	cod = cdo.getColValue("codigo");

	if(cdo.getColValue("escalaHe").equals("-1"))
	cdo.addColValue("escalaHe","");
	else tHe += (Integer.parseInt(cdo.getColValue("escalaHe")));
	if(cdo.getColValue("escalaMin15").equals("-1")) cdo.addColValue("escalaMin15","");
	else tM15 += Integer.parseInt(cdo.getColValue("escalaMin15"));
	if(cdo.getColValue("escalaMin30").equals("-1")) cdo.addColValue("escalaMin30","");
	else tM30 += Integer.parseInt(cdo.getColValue("escalaMin30"));
	if(cdo.getColValue("escalaMin60").equals("-1")) cdo.addColValue("escalaMin60","");
	else tM60 += Integer.parseInt(cdo.getColValue("escalaMin60"));
	if(cdo.getColValue("escalaMin90").equals("-1")) cdo.addColValue("escalaMin90","");
	else tM90 += Integer.parseInt(cdo.getColValue("escalaMin90"));
	if(cdo.getColValue("escalaMin120").equals("-1")) cdo.addColValue("escalaMin120","");
	else tM120 += Integer.parseInt(cdo.getColValue("escalaMin120"));
	if(cdo.getColValue("escalaHs").equals("-1")) cdo.addColValue("escalaHs","");
	else tHs += Integer.parseInt(cdo.getColValue("escalaHs"));

	if(cdo.getColValue("codAnestesia").equals("0")){
		ld++;
%>
		<%=fb.hidden("codigo"+ld,cdo.getColValue("codigo"))%>
		<%=fb.hidden("codAnestesia"+ld,cdo.getColValue("codAnestesia"))%>
		<tr align="center">
			<td align="left"><%=cdo.getColValue("descripcion")%></td>

			<td><%=fb.intBox("he"+ld,cdo.getColValue("escalaHe"),false,false,viewMode,1,8,"form-control input-sm escala-type",null,"onClick=\"javascript:ocultar(this,'"+ld+"','he');\"", null, false, " data-type='he'")%></td>
			<td><%=fb.intBox("min15"+ld,cdo.getColValue("escalaMin15"),false,false,viewMode,1,8,"form-control input-sm escala-type",null,"onClick=\"javascript:ocultar(this,'"+ld+"','min15')\"", null, false, " data-type='min15'")%></td>
			<td><%=fb.intBox("min30"+ld,cdo.getColValue("escalaMin30"),false,false,viewMode,1,8,"form-control input-sm escala-type",null,"onClick=\"javascript:ocultar(this,'"+ld+"','min30')\"", null, false, " data-type='min30'")%></td>
			<td><%=fb.intBox("min60"+ld,cdo.getColValue("escalaMin60"),false,false,viewMode,1,8,"form-control input-sm escala-type",null,"onClick=\"javascript:ocultar(this,'"+ld+"','min60')\"", null, false, " data-type='min60'")%></td>
			<td><%=fb.intBox("min90"+ld,cdo.getColValue("escalaMin90"),false,false,viewMode,1,8,"form-control input-sm escala-type",null,"onClick=\"javascript:ocultar(this,'"+ld+"','min90')\"", null, false, " data-type='min90'")%></td>
			<td><%=fb.intBox("min120"+ld,cdo.getColValue("escalaMin120"),false,false,viewMode,1,8,"form-control input-sm escala-type",null,"onClick=\"javascript:ocultar(this,'"+ld+"','min120')\"", null, false, " data-type='min120'")%></td>
			<td><%=fb.intBox("hs"+ld,cdo.getColValue("escalaHs"),false,false,viewMode,1,8,"form-control input-sm escala-type",null,"onClick=\"javascript:ocultar(this,'"+ld+"','hs')\"", null, false, " data-type='hs'")%></td>
		</tr>

				<tr id="obs-<%=ld%>" style="display:<%=modeSec.equalsIgnoreCase("add")?"none":""%>;">
			<td colspan="8">
				<!--<div>-->
				<table class="table table-small-font table-bordered table-striped">
				<tr class="bg-headtabla2">
					<td width="10%">&nbsp;</td>
					<td width="60%"><cellbytelabel id="12">Descripci&oacute;n</cellbytelabel></td>
					<td  width="30%"><cellbytelabel id="13">Escala</cellbytelabel></td>
				</tr>
<%
	}
	else
	{
		if(!cdo.getColValue("codEscala").equals("-1"))//cod.equals(cdo.getColValue("codigo"))
		{
			lc++;
%>
				<tr class="pointer" onClick="javascript:setEscala(<%=cdo.getColValue("codEscala")%>,<%=ld%>,<%=cdo.getColValue("codAnestesia")%>)">
					<td>&nbsp;</td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td><%=cdo.getColValue("codEscala")%></td>
				</tr>
<%
		}
	}
	if(i<al.size()-1)
	{
		cdo = (CommonDataObject) al.get(i+1);
		codAnt = cdo.getColValue("codigo");
	}
	else
	{
%>
				</table>
				<!--</div> -->
			</td>
		</tr>
<%
	}
	if(!codAnt.equals(cod))
	{
%>
				</table>
				</div>
			</td>
		</tr>
<%
	}
}
%>
		<tr class="TextRow01" align="center">
			<td align="right"><cellbytelabel id="14">Total</cellbytelabel>:</td>
			<td><%=fb.intBox("totalhe",""+tHe+"", false, false, true, 2, "form-control input-sm", "", "")%></td>
			<td><%=fb.intBox("totalmin15",""+tM15+"", false, false, true, 2, "form-control input-sm", "", "")%></td>
			<td><%=fb.intBox("totalmin30",""+tM30+"", false, false, true, 2, "form-control input-sm", "", "")%></td>
			<td><%=fb.intBox("totalmin60",""+tM60+"", false, false, true, 2, "form-control input-sm", "", "")%></td>
			<td><%=fb.intBox("totalmin90",""+tM90+"", false, false, true, 2, "form-control input-sm", "", "")%></td>
			<td><%=fb.intBox("totalmin120",""+tM120+"", false, false, true, 2, "form-control input-sm", "", "")%></td>
			<td><%=fb.intBox("totalhs",""+tHs+"", false, false, true, 2, "form-control input-sm", "", "")%></td>
		</tr>

<%=fb.hidden("size",""+ld)%>
</table>

			 <div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
				<tr>
					<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"onClick='doSubmit()'")%>
					</td>
				</tr>
		</table>
</div>
<%=fb.formEnd(true)%>


	</div>
</div>
</table>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	DatosCirugia newdatos = new DatosCirugia();
	newdatos.setCodigo(request.getParameter("datCirugia"));
	newdatos.setSecuencia(request.getParameter("noAdmision"));
	newdatos.setCodPaciente(request.getParameter("codPac"));
	newdatos.setFecNacimiento(request.getParameter("dob"));
	newdatos.setFechaRegistro(request.getParameter("fechaRegistro"));
	newdatos.setHoraInicio(request.getParameter("horaInicio"));
	newdatos.setHoraFinal(request.getParameter("horaFinal"));
	newdatos.setTipoCirugia(request.getParameter("tipoCirugia"));
	newdatos.setProcedimiento(request.getParameter("procedimiento"));
	newdatos.setProcedimientoDesc(request.getParameter("procedimientoDesc"));
	newdatos.setDiagnostico(request.getParameter("diagnostico"));
	newdatos.setObservaciones(request.getParameter("observaciones"));
	newdatos.setEmpProvincia(request.getParameter("empProvincia"));
	newdatos.setEmpSigla(request.getParameter("empSigla"));
	newdatos.setEmpTomo(request.getParameter("empTomo"));
	newdatos.setEmpAsiento(request.getParameter("empAsiento"));
	newdatos.setEmpCompania(request.getParameter("empCompania"));
	newdatos.setUsuarioCreacion(request.getParameter("usuarioCreacion"));
	newdatos.setFechaCreacion(request.getParameter("fechaCreacion"));
	newdatos.setUsuarioModif(UserDet.getUserName());
	newdatos.setFechaModif(cDateTime);
	if(request.getParameter("horaInicio") != null)newdatos.setHoraInicio(request.getParameter("horaInicio"));
	else newdatos.setHoraInicio("");
	if(request.getParameter("horaFinal") != null)newdatos.setHoraFinal(request.getParameter("horaFinal"));
	else newdatos.setHoraFinal("");
	newdatos.setPacId(request.getParameter("pacId"));
	newdatos.setEmpId(request.getParameter("empId"));

	int size = 0;
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
	for (int i=1; i<= size; i++)
	{
		DetalleRecuperacion detRec = new DetalleRecuperacion();
		//== null || request.getParameter("he"+i).trim().equals("")
		//if(!request.getParameter("he"+i).trim().equals("") )//&& !request.getParameter("codAnestesia"+i).equals("0"))
		//{
			detRec.setDatCirugia(request.getParameter("datCirugia"));
			detRec.setSecuencia(request.getParameter("noAdmision"));
			detRec.setCodPaciente(request.getParameter("codPac"));
			detRec.setFecNacimiento(request.getParameter("dob"));
			detRec.setRecupAnestesia(request.getParameter("codigo"+i));
			//detRec.setDetalleRecup(request.getParameter("codAnestesia"+i));
			//detRec.setMinutos(request.getParameter("minutos"));
			detRec.setEscalaHe(request.getParameter("he"+i));
			detRec.setEscalaMin15(request.getParameter("min15"+i));
			detRec.setEscalaMin30(request.getParameter("min30"+i));
			detRec.setEscalaMin60(request.getParameter("min60"+i));
			detRec.setEscalaMin90(request.getParameter("min90"+i));
			detRec.setEscalaMin120(request.getParameter("min120"+i));
			detRec.setEscalaHs(request.getParameter("hs"+i));
			detRec.setPacId(request.getParameter("pacId"));
			newdatos.addDetalleRecuperacion(detRec);
		//}
	}
	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) {
						DCMgr.add(newdatos);
						id_cirugia = DCMgr.getPkColValue("codigo");
				}
		else if (modeSec.equalsIgnoreCase("edit")) DCMgr.update(newdatos);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (DCMgr.getErrCode().equals("1"))
{
%>
	alert('<%=DCMgr.getErrMsg()%>');
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
} else throw new Exception(DCMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fecha=<%=fecha%>&id_cirugia=<%=id_cirugia%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>