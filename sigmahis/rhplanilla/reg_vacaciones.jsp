<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.Empleado"%>
<%@ page import="issi.rhplanilla.Vacaciones"%>
<%@ page import="issi.rhplanilla.TemporalVac"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="EmplMgr" scope="page" class="issi.rhplanilla.VacacionesMgr" />
<jsp:useBean id="del" scope="page" class="issi.rhplanilla.Empleado" />
<jsp:useBean id="DI" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />

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
EmplMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();

String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String empId = request.getParameter("empId");
String accion = request.getParameter("accion");
String anioSol = request.getParameter("anioSol");
String codigo = request.getParameter("codigo");

if(fp==null) fp="";
if(empId==null) empId = "";
if(accion==null) accion = "";
boolean viewMode = false;


if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{

    if (change == null)
    {
      del = new Empleado();
      DI.clear();
			if(!empId.equals("")){
				sql = "SELECT d.anioPago,d.periodoPago,a.compania, a.emp_id empId, a.provincia, a.sigla, a.tomo, a.asiento, nvl(a.primer_nombre, ' ') primernombre, nvl(a.segundo_nombre, ' ') segundonombre, nvl(a.primer_apellido, ' ') primerapellido, a.unidad_organi unidadorgani, nvl(a.num_empleado, ' ') numempleado, nvl(to_char(a.gasto_rep), ' ') gastorep, a.salario_base salariobase, nvl(to_char(a.rata_hora), ' ') ratahora, b.descripcion as unidadorganidesc, decode(nvl(a.salario_base, 0), 0, a.rata_hora, a.salario_base) salarioMes, nvl(c.dias_dispo,0) diasd, nvl(c.dias_dispo,0) diasdispo, nvl(c.dias_pend,0) diaspend, nvl(c.dias_res,0) diasres, nvl(c.dias_dinero, 0) diasdinero, nvl(d.periodof_inicio, ' ') fechaIni,to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo-1,'dd/mm/yyyy')/*, nvl(case nvl(d.val1,0) when 1 then (case when nvl(d.tipo_vacacion, ' ') in ('AB','DP') then (case nvl(d.count_det_vacacion,0) when 1 then null else to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo-1,'dd/mm/yyyy') end) else d.periodof_inicio end) else d.periodof_inicio end, ' ')*/ fechafin, nvl(to_char(case nvl(d.val1,0) when 1 then (case when nvl(d.tipo_vacacion, ' ') in ('AB','DP') then (case nvl(d.count_det_vacacion,0) when 1 then null else gethorasmestrabajadas(a.compania, a.emp_id, d.dias_tiempo, d.periodof_final, d.periodof_inicio, 'HT')  end) end) end), '0') cantidadHoras, nvl(to_char(case nvl(d.val1,0) when 1 then (case when nvl(d.tipo_vacacion, ' ') in ('AB','DP') then (case nvl(d.count_det_vacacion,0) when 1 then null else gethorasmestrabajadas(a.compania, a.emp_id, d.dias_tiempo, d.periodof_final, d.periodof_inicio, 'HM')  end) end) end), '0') horasMes, nvl(to_char(case nvl(d.val1,0) when 1 then (case when nvl(d.diferencia_por_reemplazo,0) > 0 and d.bonif_por_reemplazo = 'C' then (case when nvl(gethorasmestrabajadas(a.compania, a.emp_id, d.dias_tiempo, d.periodof_final, d.periodof_inicio, 'HT'), 0) /*cantidad horas*/ > 0 then case when nvl(gethorasmestrabajadas(a.compania, a.emp_id, d.dias_tiempo, d.periodof_final, d.periodof_inicio, 'HM'), 0) /*horas mes*/ > 0 then round(nvl(round(nvl(d.diferencia_por_reemplazo, 0)/nvl(gethorasmestrabajadas(a.compania, a.emp_id, d.dias_tiempo, d.periodof_final, d.periodof_inicio, 'HM'),0),2),0)*nvl(gethorasmestrabajadas(a.compania, a.emp_id, d.dias_tiempo, d.periodof_final, d.periodof_inicio, 'HM'),0),2) end else round(d.diferencia_por_reemplazo/(case when d.dias_tiempo between 0 and 12 then 1 else case when to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'yyyy')) = to_number(to_char((to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo),'yyyy')) then /*periodo_fin*/ (case when to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'DD')) between 1 and 15 then to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'MM')) * 2 -1 else to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'MM')) * 2 end) - /*periodo_ini*/ (case when to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'DD')) between 1 and 15 then to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'MM')) * 2 -1 else to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'MM')) * 2 end) + 1 else 24 - /*periodo_ini*/ (case when to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'DD')) between 1 and 15 then to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'MM')) * 2 -1 else to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'MM')) * 2 end) + 1 + /*periodo_fin*/ (case when to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'DD')) between 1 and 15 then to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'MM')) * 2 -1 else to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'MM')) * 2 end) - 1 + 1 end end),2)  end) end) end), ' ') rmontoxperiodo, nvl(to_char(case nvl(d.val1,0) when 1 then case when d.dias_tiempo between 0 and 12 then 1 else case when to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'yyyy')) = to_number(to_char((to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo),'yyyy')) then /*periodo_fin*/ (case when to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'DD')) between 1 and 15 then to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'MM')) * 2 -1 else to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'MM')) * 2 end) - /*periodo_ini*/ (case when to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'DD')) between 1 and 15 then to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'MM')) * 2 -1 else to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'MM')) * 2 end) + 1 else 24 - /*periodo_ini*/ (case when to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'DD')) between 1 and 15 then to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'MM')) * 2 -1 else to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy'),'MM')) * 2 end) + 1 + /*periodo_fin*/ (case when to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'DD')) between 1 and 15 then to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'MM')) * 2 -1 else to_number(to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo,'MM')) * 2 end) end end end), ' ') rtotalperiodos, nvl(to_char(d.dias_tiempo), ' ') tiemposol, nvl(to_char(d.dias_dinero), ' ') tiemposoldinero, nvl(d.observacion, ' ') comentario, nvl(to_char(d.acumulado_salario), ' ') acumulado, nvl(to_char(d.acumulado_gasto_rep), ' ') acumulado_gr, nvl(d.tipo_vacacion, ' ') tipovacacion, nvl(to_char(d.remp_id), ' ') rempid, nvl(to_char(d.r_provincia), ' ') rprovincia, nvl(d.r_sigla, ' ') rsigla, nvl(to_char(d.r_tomo), ' ') rtomo, nvl(to_char(d.r_asiento), ' ') rasiento, nvl(d.r_num_empleado, ' ') rnumempleado, nvl(d.bonif_por_reemplazo, ' ') bonifporreemplazo, nvl(to_char(d.diferencia_por_reemplazo), ' ') diferenciaxreemplazo FROM tbl_pla_empleado a, tbl_sec_unidad_ejec b, (select emp_id, nvl(sum(case when estado in (3, 4, 5) then dias_pendiente end),0) dias_dispo, nvl(sum(case when estado in (3, 5) then dias_pendiente end),0) dias_pend, nvl(sum(case when estado = 4 then dias_pendiente end),0) dias_res, nvl(sum(dias_pendiente_dinero),0) dias_dinero from tbl_pla_vacacion where estado in (3, 4, 5) and cod_compania = "+(String) session.getAttribute("_companyId")+" and emp_id = "+empId+" group by emp_id) c, (select a.emp_id, remp_id, to_char(a.periodof_inicio, 'dd/mm/yyyy') periodof_inicio, to_char(a.periodof_final, 'dd/mm/yyyy') periodof_final, a.dias_tiempo, a.dias_dinero, a.observacion, a.acumulado_salario, a.acumulado_gasto_rep, decode(a.tipo, 'TI', 'DP', 'DI', 'VR', 'AB') tipo_vacacion, a.r_provincia, a.r_sigla, a.r_tomo, a.r_asiento, a.r_num_empleado, a.bonif_por_reemplazo, a.diferencia_por_reemplazo, (c.primer_nombre||' '||decode(c.sexo,'F', decode(c.apellido_casada, null, c.primer_apellido, decode(c.usar_apellido_casada, 'S', 'DE' || c.apellido_casada, c.primer_apellido)), c.primer_apellido)) r_dsp_nombre, (case when a.periodof_inicio is not null and a.periodof_final is not null and a.dias_tiempo is not null and a.dias_dinero is not null then 1 else 0 end) val1, nvl((select count(x.emp_id) from tbl_pla_det_vacacion x where x.emp_id = b.emp_id and x.cod_compania = "+(String) session.getAttribute("_companyId")+" and trunc(x.fecha_final) > trunc(a.periodof_inicio)), 0) count_det_vacacion,a.anio_pago anioPago,a.periodo_pago periodoPago from tbl_pla_sol_vacacion a, tbl_pla_empleado b, tbl_pla_empleado c where a.compania = "+(String) session.getAttribute("_companyId");
	if(!mode.trim().equals("view"))	sql +=" and a.estado = 'AP'";
	else 	{sql +=" and a.anio ="+anioSol+" and a.codigo ="+codigo;}
				sql +=" and a.compania = b.compania and a.emp_id = b.emp_id and a.remp_id = c.emp_id(+)) d WHERE a.compania="+(String) session.getAttribute("_companyId")+" and a.unidad_organi = b.codigo and a.compania = b.compania and a.emp_id = c.emp_id(+) and a.emp_id = d.emp_id(+) and a.emp_id = "+empId;
				System.out.println("sql ENC ...\n"+sql);
				del = (Empleado) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Empleado.class);
				del.setAccion(accion);

			}
    }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title="Vacaciones - "+document.title;

function doAction(){
	newHeight();
	var accion = '<%=accion%>';
	var empId = '<%=empId%>';
	var tv = document.form1.tipo_vacacion.value;
	var dias_d = document.form1.dias_d.value;
	var dias_dinero = document.form1.dias_dinero.value;
	if('<%=mode%>' !='view'){
	if(empId!='' && accion !=''){
		if(parseInt(dias_d) > 0){
			if(accion=='RV'){
				var x = getDBData('<%=request.getContextPath()%>','1','tbl_pla_sol_vacacion','emp_id = <%=empId%> and compania = <%=(String) session.getAttribute("_companyId")%> and estado in(\'AP\',\'AC\')','');
				if(x=='') alert('Este empleado no tiene una solicitud de vacaciones registrada!');
				else if(x=='1'){
					//pu_control_tipo_vacacion
					if(tv=='DP'){
						if(dias_d=='' || dias_d == '0'){
							alert('El empleado no tiene dias disponible en TIEMPO');
						} else {
							document.getElementById('detail').style.display = '';
							window.frames['itemFrame'].newHeight();
						}
					} else if(tv=='VR'){
						if(dias_dinero=='' || dias_dinero == '0'){
							alert('El empleado no tiene dias disponible en DINERO');
						} else {
							document.getElementById('detail').style.display = '';
							window.frames['itemFrame'].newHeight();
						}
					} else if(tv=='AB'){
						if((dias_d == '' || dias_d == '0') && dias_dinero != '' ){
							alert('El empleado no tiene dias disponible de vacaciones en TIEMPO');
						} else if((dias_dinero == '' || dias_dinero == '0') && dias_d != '' ){
							alert('El empleado no tiene dias disponible de vacaciones en DINERO');
						} else if((dias_dinero == '' || dias_dinero == '0') && (dias_d == '' || dias_d == '0')){
							alert('El empleado no tiene dias disponible de vacaciones en TIEMPO y DINERO');
						} else {
							document.getElementById('detail').style.display = '';
							window.frames['itemFrame'].newHeight();
							//if (adjustIFrameSize) adjustIFrameSize(window);
						}
					}
					// fin pu_control_tipo_vacacion
				} else alert('Este empleado tiene varias solicitudes de vacaciones registradas!');
			} else if(accion=='RI'){
				var x = getDBData('<%=request.getContextPath()%>','1','tbl_pla_det_vacacion','emp_id = <%=empId%> and cod_compania = <%=(String) session.getAttribute("_companyId")%> and fecha_final >= sysdate','');
				if(x=='') alert('El periodo de vacaciones ya ha terminado!');
				else if(x=='1') {
					document.getElementById('detail').style.display = '';
					window.frames['itemFrame'].newHeight();
				}
			}
		} else {
			if(accion=='RI'){
				var x = getDBData('<%=request.getContextPath()%>','1','tbl_pla_det_vacacion','emp_id = <%=empId%> and cod_compania = <%=(String) session.getAttribute("_companyId")%> and fecha_final >= sysdate','');
				if(x=='') alert('El periodo de vacaciones ya ha terminado!');
				else if(x=='1') {
					document.getElementById('detail').style.display = '';
					window.frames['itemFrame'].newHeight();
				}
			} else alert('No tiene vacaciones pendientes!');
		}
	}
	}
	if('<%=mode%>' =='view'){ document.getElementById('detail').style.display = '';window.frames['itemFrame'].newHeight();}
}

function doSubmit(baction)
{
	var fecha_inicio = document.form1.fecha_ini.value;
	var accion = window.frames['itemFrame'].document.form1.paccion.value;
	var anio = document.form1.anio.value;
	var periodo = document.form1.periodo.value;
	if(confirm('Está seguro de pagar las vacaciones en el año '+anio+' y periodo '+periodo+' ?????')){

	if(accion=='RV' || accion =='RI'){
		var x = getDBData('<%=request.getContextPath()%>','distinct 1','tbl_pla_dist_dias_vac','emp_id = <%=empId%> and cod_compania = <%=(String) session.getAttribute("_companyId")%> and status in(\'PR\',\'AP\') and to_date(to_char(fecha_inicio, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fecha_inicio+'\', \'dd/mm/yyyy\')','');
		if(x=='1'){
			alert('Ya existe una distribución!');
			if(confirm('Desea modificar los acumulados, Borrar la Distribucion y Calcular Nueva Mente la Distribucion!')){
			document.form1.baction.value = baction;
			window.frames['itemFrame'].doSubmit();
			}else{
			window.frames['itemFrame'].document.location = '<%=request.getContextPath()%>/rhplanilla/reg_vacaciones_det.jsp?paccion=approve&emp_id=<%=empId%>&anio='+anio+'&periodo='+periodo+'&mode=<%=mode%>';
			window.frames['itemFrame'].calc();}
		} else {
			document.form1.baction.value = baction;
			window.frames['itemFrame'].doSubmit();
		}
	} else if(accion=='approve'){
		document.form1.baction.value = baction;
		window.frames['itemFrame'].doSubmit();
	}}

}

function verDist(){
	var fecha_inicio = document.form1.fecha_ini.value;
	var accion = window.frames['itemFrame'].document.form1.paccion.value;
	var anio = document.form1.anio.value;
	var periodo = document.form1.periodo.value;
	var x = getDBData('<%=request.getContextPath()%>','distinct 1','tbl_pla_dist_dias_vac','emp_id = <%=empId%> and cod_compania = <%=(String) session.getAttribute("_companyId")%> and status in(\'PR\',\'AP\',\'PE\') and to_date(to_char(fecha_inicio, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fecha_inicio+'\', \'dd/mm/yyyy\')','');
	if(x=='1'){
		if(anio !='' && periodo !=''){
		window.frames['itemFrame'].document.location = '<%=request.getContextPath()%>/rhplanilla/reg_vacaciones_det.jsp?paccion=approve&emp_id=<%=empId%>&anio='+anio+'&periodo='+periodo+'&mode=<%=mode%>';
		window.frames['itemFrame'].calc();}else alert('Introduzca año y período de pago!');
	} else alert('No existe Distribución!');
}

function verAcumulado(mode,fg){
	var fecha_inicio = document.form1.fecha_ini.value;
	var accion = document.form1.accion.value;
	var anio = document.form1.anio.value;
	var periodo = document.form1.periodo.value;

	var p_emp_id   	= '<%=empId%>';
	var provincia	= document.form1.provincia.value;
	var sigla 		= document.form1.sigla.value;
	var tomo 			= document.form1.tomo.value;
	var asiento 	= document.form1.asiento.value;
	var fecha_ini = document.form1.fecha_ini.value;

	//alert(accion);
	window.frames['itemFrame'].document.location = '<%=request.getContextPath()%>/rhplanilla/reg_vacaciones_acum.jsp?paccion='+accion+'&emp_id=<%=empId%>&anio='+anio+'&periodo='+periodo+'&mode='+mode+'&fg='+fg+'&provincia='+provincia+'&sigla='+sigla+'&tomo='+tomo+'&asiento='+asiento+'&fechaIni='+fecha_ini;
	window.frames['itemFrame'].calc();
}
function selEmpleado(){
	abrir_ventana1('../common/search_empleado.jsp?fp=reg_vacaciones');
}

function calcularAcumulado(){
	var p_emp_id   	= '<%=empId%>';
	var p_provincia	= document.form1.provincia.value;
	var p_sigla 		= document.form1.sigla.value;
	var p_tomo 			= document.form1.tomo.value;
	var p_asiento 	= document.form1.asiento.value;
	var v_fecha_ini = document.form1.fecha_ini.value;
	if(p_emp_id != '')
	{
		var x = getDBData('<%=request.getContextPath()%>','distinct 1','tbl_pla_dist_dias_vac','emp_id = <%=empId%> and cod_compania = <%=(String) session.getAttribute("_companyId")%> and status in(\'PR\',\'AP\') and to_date(to_char(fecha_inicio, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+v_fecha_ini+'\', \'dd/mm/yyyy\')','');

			if(x=='')
			{
				var x = getDBData('<%=request.getContextPath()%>','1','tbl_pla_temporal_vac','emp_id = <%=empId%> and cod_compania = <%=(String) session.getAttribute("_companyId")%> and to_date(to_char(fecha_inicio, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+v_fecha_ini+'\', \'dd/mm/yyyy\')','');
				if(x!='')
				{
					if(confirm('Ya existen acumulados para esta fecha de inicio, ¿Desea volver a calcular los acumulados?'))
					{
						verAcumulado('add','CALACUM');
					}

				} else {verAcumulado('add','CALACUM');}
			}else{ alert('Ya existe una distribución');}
	}
}
function showReporte()
{
	var empId=document.form1.empId.value;
	var noEmpleado=document.form1.num_empleado.value;
	var anio=document.form1.anio.value;
	var periodo=document.form1.periodo.value;
	var fechaInicio=document.form1.fecha_ini.value;
	abrir_ventana('../rhplanilla/print_vacaciones_det.jsp?empId='+empId+'&noEmpleado='+noEmpleado+'&anio='+anio+'&periodo='+periodo+'&fechaInicio='+fechaInicio);
}
function checkPeriodo(){var anio=document.form1.anio.value;	var periodo=document.form1.periodo.value;	var empId=document.form1.empId.value;if (anio!=''&&periodo!='' && empId !=''){var planilla=  getDBData('<%=request.getContextPath()%>','count(*) as   v_planilla','tbl_pla_pago_empleado',' cod_compania=<%=(String) session.getAttribute("_companyId")%> and cod_planilla  = 3 and num_planilla  = '+periodo+' and anio = '+anio);if(parseInt(planilla)>0){alert('Ya existe planilla Generada para el AÑO/PERIODO introducido. Verifique!!!');document.form1.anio.value='';document.form1.periodo.value='';}}}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="VACACIONES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
      <table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	  <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
      <%=fb.formStart(true)%>
      <%=fb.hidden("mode",mode)%>
      <%=fb.hidden("baction","")%>
      <%=fb.hidden("errCode","")%>
      <%=fb.hidden("errMsg","")%>
      <%=fb.hidden("fg",fg)%>
      <%=fb.hidden("fp",fp)%>
      <%=fb.hidden("clearHT","")%>
	  <%=fb.hidden("tipo_vacacion",del.getTipoVacacion())%>
	  <%=fb.hidden("anioSol",anioSol)%>
	  <%=fb.hidden("codigo",codigo)%>
      <tr>
        <td colspan="4">&nbsp;</td>
      </tr>
      <tr class="TextRow02">
        <td colspan="4">&nbsp;</td>
      </tr>
        <tr class="TextPanel">
          <td colspan="4"><cellbytelabel>Empleado</cellbytelabel></td>
        </tr>
        <tr class="TextRow01">
          <td><cellbytelabel>Empleado</cellbytelabel></td>
          <td colspan="3">
          <%=fb.hidden("empId",del.getEmpId())%>
          <%=fb.hidden("segundo_nombre",del.getSegundoNombre())%>
          <%=fb.hidden("segundo_apellido",del.getSegundoApellido())%>
          <%=fb.textBox("primer_nombre",del.getPrimerNombre(),false,false,true,30)%>
          <%=fb.textBox("primer_apellido",del.getPrimerApellido(),false,false,true,30)%>
					<%=fb.textBox("provincia",del.getProvincia(),false,false,true,2)%>-
          <%=fb.textBox("sigla",del.getSigla(),false,false,true,3)%>-
          <%=fb.textBox("tomo",del.getTomo(),false,false,true,5)%>-
          <%=fb.textBox("asiento",del.getAsiento(),false,false,true,5)%>
          <%=fb.button("buscar","...",false,true,"","","onClick=\"javascript:selEmpleado()\"")%>          </td>
        </tr>
        <tr class="TextRow01" >
          <td><cellbytelabel>No. Empleado</cellbytelabel></td>
          <td><%=fb.textBox("num_empleado",del.getNumEmpleado(),false,false,true,5)%></td>
          <td>Salario Mes:
					<%//=fb.decBox("salario_mes",(del.getSalarioMes()!=null && !del.getSalarioMes().equals("")?CmnMgr.getFormattedDecimal(del.getSalarioMes()):""),false,false,false,7, 8.2,null,null,"","",false,"")%>

<%=fb.textBox("salario_mes",(del.getSalarioMes()!=null && !del.getSalarioMes().equals("")?CmnMgr.getFormattedDecimal(del.getSalarioMes()):""),false,false,true,8)%></td>

									</td>
          <td><cellbytelabel>Gasto de Rep</cellbytelabel>.:<%=fb.textBox("gasto_rep",del.getGastoRep(),false,false,true,5)%></td>
        </tr>
        <tr class="TextRow01" >
          <td><cellbytelabel>Unidad Admin</cellbytelabel>.:</td>
          <td colspan="3">
					<%=fb.textBox("unidad_organi",del.getUnidadOrgani(),false,false,true,5)%>
          <%=fb.textBox("unidad_organi_desc",del.getUnidadOrganiDesc(),false,false,true,50)%>          </td>
        </tr>
        <tr class="TextRow01">
          <td><cellbytelabel>Acci&oacute;n a realizar</cellbytelabel>:</td>
          <td>
          <%
					String accionDesc = "";
					if(accion.equals("RV")) accionDesc = "REGISTRAR VACACIONES";
					else if(accion.equals("RI")) accionDesc = "REINTEGRO DE VACACIONES";
					%>
					<%=fb.hidden("accion",del.getAccion())%>
					<%=fb.textBox("accion_desc", accionDesc,false,false,true,50)%>
					<%//=fb.select("accion","RV=REGISTRAR VACACIONES",del.getAccion())%></td>
          <td>Disponibles:<%=fb.textBox("dias_d",del.getDiasD(),false,false,true,5)%>(Tiempo)</td>
          <td><%=fb.textBox("dias_dinero",del.getDiasDinero(),false,false,true,5)%>(Dinero)</td>
        </tr>
        <tr class="TextPanel">
          <td colspan="4"><cellbytelabel>Registro de Vacaciones</cellbytelabel></td>
        </tr>
        <tr>
        <td colspan="4"><table width="100%">
        <tr class="TextRow01">
          <td colspan="2"><cellbytelabel>Tipo</cellbytelabel><%=fb.select("tipo_vacacion_view","DP=TIEMPO,VR=DINERO,AB=TIEMPO Y DINERO",del.getTipoVacacion(),false,true,0)%></td>
          <td width="24%"><cellbytelabel>Hrs x Mes</cellbytelabel>:</td>
          <td width="11%">
					<%=fb.decBox("horas_mes","0",false,false,true,7, 8.2,null,null,"","",false,"")%>          </td>
          <td width="16%"><cellbytelabel>Reemplazo</cellbytelabel>:</td>
          <td width="21%"><%=fb.textBox("r_dsp_nombre",del.getRDspNombre(),false,false,true,50)%></td>
        </tr>
        <tr class="TextRow01">
          <td width="14%"><cellbytelabel>D&iacute;as Solicitados</cellbytelabel></td>
          <td width="14%"><%=fb.textBox("tiempo_sol",del.getTiempoSol(),false,false,true,5)%><cellbytelabel>Tiempo</cellbytelabel></td>
          <td><cellbytelabel>Hrs Vacaciones</cellbytelabel>:</td>
          <td>
          <%=fb.decBox("cantidad_horas","0",false,false,true,7, 8.2,null,null,"","",false,"")%>          </td>
          <td>&nbsp;</td>
          <td>
					<%=fb.hidden("r_emp_id",del.getREmpId())%>
					<%=fb.textBox("r_num_empleado",del.getRNumEmpleado(),false,false,true,5)%>
          <%=fb.textBox("r_provincia",del.getRProvincia(),false,false,true,5)%>
          <%=fb.textBox("r_sigla",del.getRSigla(),false,false,true,5)%>
          <%=fb.textBox("r_tomo",del.getRTomo(),false,false,true,5)%>
					<%=fb.textBox("r_asiento",del.getRAsiento(),false,false,true,5)%>          </td>
        </tr>
        <tr class="TextRow01">
          <td>&nbsp;</td>
          <td><%=fb.textBox("tiempo_sol_dinero",del.getTiempoSolDinero(),false,false,true,5)%><cellbytelabel>Dinero</cellbytelabel></td>
          <td><cellbytelabel>Salario</cellbytelabel>:</td>
          <td>
					<%=fb.decBox("acumulado",((del.getAcumulado()!=null && !del.getAcumulado().trim().equals(""))?CmnMgr.getFormattedDecimal(del.getAcumulado()):""),false,false,true,7, 8.2,null,null,"","",false,"")%>          </td>
          <td><cellbytelabel>Tipo y Monto de la Bonific</cellbytelabel>.</td>
          <td>
          <%=fb.select("bonif_por_reemplazo","A=Jefe,B=Supervisor,C=Categoria,D=No Recibe",del.getBonifPorReemplazo(),false,true,0,"Text10",null,null,"","")%>
				   $      <%=fb.decBox("diferencia_x_reemplazo",(del.getDiferenciaXReemplazo()!=null && !del.getDiferenciaXReemplazo().equals("") && !del.getDiferenciaXReemplazo().equals(" ")?CmnMgr.getFormattedDecimal(del.getDiferenciaXReemplazo()):""),false,false,true,7, 8.2,null,null,"","",false,"")%> </td>
        </tr>
        <tr class="TextRow01">
          <td><cellbytelabel>Fecha inicio</cellbytelabel>:</td>
          <td>
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />
          <jsp:param name="nameOfTBox1" value="fecha_ini" />
          <jsp:param name="valueOfTBox1" value="<%=del.getFechaIni()%>" />
          <jsp:param name="fieldClass" value="Text10" />
          <jsp:param name="buttonClass" value="Text10" />
		  <jsp:param name="readonly" value="Y" />
          <jsp:param name="clearOption" value="true" />          </jsp:include>					</td>
          <td><cellbytelabel>Gastos Rep</cellbytelabel>.:</td>
          <td>
					<%=fb.decBox("acumulado_gr",(del.getAcumuladoGr()!=null && !del.getAcumuladoGr().equals("")?CmnMgr.getFormattedDecimal(del.getAcumuladoGr()):""),false,false,true,7, 8.2,null,null,"","",false,"")%>          </td>
          <td><cellbytelabel>Total Periodos</cellbytelabel>:</td>
          <td>
					<%=fb.textBox("r_total_periodos",del.getRTotalPeriodos(),false,false,true,5)%>
          <cellbytelabel>Monto x Per</cellbytelabel>.: $      <%=fb.decBox("r_monto_periodo",(del.getRMontoXPeriodo()!=null && !del.getRMontoXPeriodo().equals("") && !del.getRMontoXPeriodo().equals(" ")?CmnMgr.getFormattedDecimal(del.getRMontoXPeriodo()):""),false,false,true,7, 8.2,null,null,"","",false,"")%> </td>
        </tr>
        <tr class="TextRow01">
          <td><cellbytelabel>Fecha final</cellbytelabel>:</td>
          <td>
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />
          <jsp:param name="nameOfTBox1" value="fecha_fin" />
          <jsp:param name="valueOfTBox1" value="<%=del.getFechaFin()%>" />
          <jsp:param name="fieldClass" value="Text10" />
          <jsp:param name="buttonClass" value="Text10" />
		  <jsp:param name="readonly" value="Y" />
          <jsp:param name="clearOption" value="true" />          </jsp:include>          </td>
          <td><cellbytelabel>S. Especie</cellbytelabel>:</td>
          <td>
					<%=fb.decBox("acumulado_sespecie",(del.getAcumuladoSEspecie()!=null && !del.getAcumuladoSEspecie().equals("")?CmnMgr.getFormattedDecimal(del.getAcumuladoSEspecie()):""),false,false,true,7, 8.2,null,null,"","",false,"")%>          </td>
          <td colspan="2" rowspan="2"><cellbytelabel>Comentario</cellbytelabel>:<br>&nbsp;<%=fb.textarea("comentario",del.getComentario(),false,false,viewMode,60,2)%></td>
        </tr>
        <tr class="TextRow01">
          <td colspan="2">
          <%if(!mode.trim().equals("view")){%><a href="javascript:calcularAcumulado();"><font class="BottonNew"><cellbytelabel>CA</cellbytelabel></font></a>&nbsp;<%}%>
          <a href="javascript:verDist();"><font class="BottonNew"><cellbytelabel>DIST</cellbytelabel>.</font></a>&nbsp;
          <a href="javascript:verAcumulado('view');"><font class="BottonNew"><cellbytelabel>VA</cellbytelabel></font></a>          </td>
          <td colspan="2">&nbsp;&nbsp;&nbsp;<cellbytelabel>A&ntilde;o</cellbytelabel>&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Per&iacute;odo</cellbytelabel>&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Planilla de Pago</cellbytelabel><br>
					<%=fb.textBox("anio",del.getAnioPago(),true,false,((del.getAnioPago() !=null && !del.getAnioPago().trim().equals(""))?true:false),5,4,"text10",null,"onChange=\"javascript:checkPeriodo()\"")%>
          <%=fb.textBox("periodo",del.getPeriodoPago(),true,false,((del.getPeriodoPago() !=null && !del.getPeriodoPago().trim().equals(""))?true:false),5,2,"text10",null,"onChange=\"javascript:checkPeriodo()\"")%>
          <%=fb.select("forma_pago","PV=VACACIONES",del.getFormaPago())%>    <%if(del.getAnioPago() !=null && !del.getAnioPago().trim().equals("") && del.getPeriodoPago() !=null && !del.getPeriodoPago().trim().equals("")){%> <%=fb.button("printRep","REPORTE",true,false,null,null,"onClick=\"javascript:showReporte()\"")%><%}%>     </td>
        </tr>
        </table></td></tr>
        <%if(accion.equals("RV")){%>
        <tr id="detail" style="display:none">
          <td colspan="4">
            <iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="100" scrolling="yes" src="../rhplanilla/reg_vacaciones_acum.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&paccion=<%=accion%>&emp_id=<%=empId%>&anioSol=<%=anioSol%>&codigo=<%=codigo%>&fechaIni=<%=del.getFechaIni()%>"></iframe>
			   </td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4" align="right">
		  <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
            <%=fb.button("save","Guardar",false,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>          </td>
        </tr>
        <%}%>
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>
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
  //String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
  String errCode = "";
  String errMsg = "";
  	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	fg = request.getParameter("fg");
  if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
  {
    errCode = request.getParameter("errCode");
    errMsg = request.getParameter("errMsg");
  }
  session.removeAttribute("DI");
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_vacaciones.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_vacaciones.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_vacaciones.jsp';
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
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&empId=<%=empId%>&accion=<%=accion%>&fg=<%=fg%>&fp=<%=fp%>&anioSol=<%=anioSol%>&codigo=<%=codigo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>