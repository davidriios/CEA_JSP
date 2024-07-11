<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.rhplanilla.AccionesMovilidad"%>
<%@ page import="issi.rhplanilla.AccionEnc"%>
<%@ page import="issi.rhplanilla.AccionesEmpleadoMgr"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iFact" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFact" scope="session" class="java.util.Vector" />
<jsp:useBean id="iMat" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iLim" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="AccMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject emp = new CommonDataObject();
AccionEnc eval= new AccionEnc();// Datos del paciente
AccionesMovilidad accionEval = new AccionesMovilidad();//Datos del encabesado
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
AccMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();

String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String emp_id = request.getParameter("emp_id");
String id = request.getParameter("id");
String tipo_accion = request.getParameter("tipo_accion");
String accion = request.getParameter("accion");
String fp = request.getParameter("fp");
String fechaEfectiva ="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate =  CmnMgr.getCurrentDate("dd-mm-yyyy");
String filter="";
boolean viewMode = false;
System.out.println("cDate"+cDate);
if (mode == null) mode = "edit";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (tab == null) tab = "0";
if(request.getParameter("tipo_accion")==null)tipo_accion="1";
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(!accion.trim().equals("1"))
if ( emp_id == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");
if ( accion == null) throw new Exception("La acccion no es válida. Por favor intente nuevamente!");
if(!accion.trim().equals("3")&& !accion.trim().equals("1"))
if ( tipo_accion == null) throw new Exception("El sub tipo de acccion no es válida. Por favor intente nuevamente!");
	

	sql="select b.provincia, b.sigla, b.tomo, b.asiento, b.compania, b.primer_nombre as primerNombre,b.segundo_nombre as segundoNombre, b.primer_apellido as primerApellido,b.segundo_apellido as segundoApellido,b.apellido_casada as apellidoCasada, b.num_empleado as numEmpleado, b.num_ssocial as numSsocial,b.salario_base as salarioBase, b.sexo, b.cargo,b.unidad_organi as gerencia, b.gasto_rep as gastoRep, /*b.seccion,*/b.ubic_depto as depto,b.ubic_seccion as seccion, b.emp_id as empId, b.primer_nombre||decode(b.segundo_nombre,null,' ',' '||b.segundo_nombre)||' '||b.primer_apellido||decode(b.segundo_apellido,null,' ',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_casada,null,' ',' '||b.apellido_casada)) as nombre,un.descripcion as gerenciaDesc,dep.descripcion as deptoDesc,sec.descripcion as seccionDesc,ca.denominacion as cargoDesc,b.horario ,hr.descripcion as horarioDesc,to_char(b.fecha_ingreso,'dd/mm/yyyy')as fechaIngreso from tbl_pla_empleado b ,tbl_sec_unidad_ejec un ,tbl_sec_unidad_ejec sec,tbl_sec_unidad_ejec dep,tbl_pla_cargo ca,tbl_pla_horario_trab hr where b.emp_id="+emp_id+" and b.compania="+(String) session.getAttribute("_companyId")+" and b.unidad_organi= un.codigo(+) and b.ubic_depto=dep.codigo(+) and b.ubic_seccion=sec.codigo(+) and b.cargo=ca.codigo(+) and b.horario=hr.codigo(+)";
eval = (AccionEnc) sbb.getSingleRowBean(ConMgr.getConnection(),sql,AccionEnc.class);
		System.out.println("sql:\n"+sql);	
	eval.setFechaCreacion(cDateTime);
	eval.setUsuarioCreacion((String) session.getAttribute("_userName"));

		if(!accion.trim().equals("3")&& !accion.trim().equals("1"))
		filter=" and sub_t_accion="+tipo_accion;
		
		sql="select a.compania, a.tipo_accion as tipoAccion, a.sub_t_accion as subTAccion, to_char(a.fecha_doc,'dd/mm/yyyy')as fechaDoc, a.t_documento as tDocumento, a.num_documento as numDocumento,/*a.primer_nombre||decode(a.segundo_nombre,null,'',''||a.segundo_nombre)||''||a.primer_apellido||decode(a.segundo_apellido,null,'',''||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',''||a.apellido_casada)) as nombre,*/ a.ced_provincia as cedProvincia,a.ced_sigla as cedSigla, a.ced_tomo as cedTomo, a.ced_asiento as cedAsiento, a.num_ssocial as numSsocial, a.codigo_general as codigoGeneral,a.grado_sal as gradoSal,a.salario, a.posicion, a.anio_partida as anioPartida, a.area_partida as areaPartida, a.ent_partida as entPartida, a.tipo_pgpartida as tipoPgpartida,a.prog_partida as progPartida, a.ffin_partida as ffinPartida, a.subp_partida as subpPartida, a.acti_partida as actiPartida, a.obj_partida as objPartida, to_char(a.fecha_actap,'dd/mm/yyyy')as fechaActap, a.unidad_adm as unidadAdm, a.resultado_ppru as resultadoPpru, a.num_con_ascenso as numConAscenso, a.cod_a_dest as codADes, a.cod_i_dest as codIDest, a.cargo_insti_dest as cargoInstiDest,a.posicion_dest as posicionDest, a.unidad_adm_dest as  unidadAdmDest , a.salario_dest as salarioDest,a.anio_partida_dest as anioPartidaDest, a.area_partida_dest as areaPartidaDest, a.ent_partida_dest as entPartidaDest, a.tipo_pgpartida_dest as tipoPgpartidaDest, a.prog_partida_dest as progPartidaDest, a.ffin_partida_dest as ffinPartidaDest, a.subp_partida_dest as subpPartidaDest, a.acti_partida_dest as actiPartidaDest, a.obj_partida_dest as objPartidaDest,to_char(a.periodo_ini,'dd/mm/yyyy') as periodoIni, decode(to_char(a.periodo_fin,'dd/mm/yyyy'),null,' ',to_char(a.periodo_fin,'dd/mm/yyyy')) as periodoFin, to_char(a.periodo_fin,'dd/mm/yyyy') as periodoFinIngreso,  a.ced_provincia2 as cedProvincia2, a.ced_sigla2 as cedSigla2,a.ced_tomo2 as cedTomo2, a.ced_asiento2 as cedAsiento2, a.tipo_permiso as tipoPermiso,a.thora_ause as thoraAuse, a.tminuto_ause as tminutoAuse, a.tdias_ause as tdiasAuse,to_char(a.fecha_efectiva,'dd/mm/yyyy')as fechaEfectiva, a.reincorporacion, a.periodo_ini_vac as periodoIniVac, a.periodo_fin_vac as periodoFinVac, a.dias_resuelto as diasResuelto, a.dias_tomado as diasTomado, a.dias_pendiente as diasPendiente, a.t_documentore as tDocumentore, a.num_documentore as numDocumentore, to_char(a.fecha_docre,'dd/mm/yyyy')as fechaDocre, a.num_decretorf as numDecretorf, a.tipo_servidor as tipoServidor,a.causal_hecho as causalHecho, a.causal_derecho as causalDerecho, a.derecho_intr as derechoIntr, a.num_acta_defun as numActaDefun, decode(to_char(a.fec_acta_defun,'dd/mm/yyyy'),null,' ',to_char(a.fec_acta_defun,'dd/mm/yyyy'))as fecActaDefun, a.codigo_estructura as  codigoEstructura, a.codigo_est_dest as codigoEstDest, a.gasto_rep as gastoRep, a.gasto_rep_dest as  gastoRepDest, a.num_planilla as numPlanilla, a.num_planilla_dest as numPlanillaDest, a.num_empleado as  numEmpleado,  a.usuario_creacion as usuarioCreacion,to_char(a.fecha_creacion,'dd/mm/yyyy')as fechaCreacion, a.comentarios_rrhh as  comentariosRrhh, a.comentarios_pla as comentariosPla, a.cargo, a.ubic_rhgeren as ubicRhgeren, a.ubic_rhdepto as ubicRhdepto, a.ubic_rhseccion as ubicRhseccion, a.ubic_plaseccion as ubicPlaseccion, a.estado, to_char(a.fecha_ingreso,'dd/mm/yyyy')as fechaIngreso, a.horario, a.horario_dest as horarioDest,a.ubic_rhgeren_dest as ubicRhgerenDest, a.ubic_rhdepto_dest as ubicRhdeptoDest, a.ubic_rhseccion_dest as ubicRhseccionDest,a.origen_datos as origenDatos, a.sol_empleo_anio as solEmpleoAnio, a.sol_empleo_codigo as solEmpleoCodigo,a.usuario_anula as usuarioAnula, a.estado, to_char(a.fecha_anula,'dd/mm/yyyy')as fechaAnula, a.justificacion_anula as justificacionAnula,a.emp_id as empId,un.descripcion as newGerenciaDest,dep.descripcion as newDeptoDest,sec.descripcion as newSeccionDest,ca.denominacion as newCargoDest,hr.descripcion as newHorarioDest,uAdm.descripcion as newCargoDest,cEstruc.descripcion as NewPosicionDest from tbl_pla_ap_accion_per a,tbl_sec_unidad_ejec un ,tbl_sec_unidad_ejec sec,tbl_sec_unidad_ejec dep,tbl_sec_unidad_ejec uAdm,tbl_sec_unidad_ejec cEstruc,tbl_pla_cargo ca,tbl_pla_horario_trab hr  where  a.emp_id="+emp_id+" and a.estado = 'T' and a.compania="+(String) session.getAttribute("_companyId")+" and tipo_accion= "+accion+filter+" and a.ubic_rhgeren_dest= un.codigo(+) and a.ubic_rhdepto_dest=dep.codigo(+) and a.ubic_rhseccion_dest=sec.codigo(+) and a.cargo_insti_dest = ca.codigo(+) and a.horario_dest=hr.codigo(+)and a.unidad_adm=uAdm.codigo(+) and a.codigo_estructura=cEstruc.codigo(+) " ;
		accionEval = (AccionesMovilidad) sbb.getSingleRowBean(ConMgr.getConnection(),sql,AccionesMovilidad.class);
		System.out.println("sql:\n"+sql);
		if(accionEval!=null)
		{
			mode="edit";
			fechaEfectiva=accionEval.getFechaEfectiva();
		}
		else
		{
			accionEval = new AccionesMovilidad();
			mode="edit";
			fechaEfectiva = cDateTime.substring(0,10);
		}

%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Acciones Empleado - '+document.title;
function Direcciones(cTab)
{
abrir_ventana1('../rhplanilla/list_departamento.jsp?fp=movilidad&cTab='+cTab);
}
function Gerencia(cTab)
{
abrir_ventana1('../rhplanilla/list_direccion.jsp?fp=movilidad&cTab='+cTab);
}
function Secciones(cTab)
{
abrir_ventana1('../rhplanilla/list_seccion.jsp?fp=movilidad&cTab='+cTab);
}

function Cargosss(cTab)
{
abrir_ventana1('../rhplanilla/list_cargo.jsp?id=3&cTab='+cTab);
}
function addHorario()
{
abrir_ventana1('../rhplanilla/list_horario.jsp?fp=movilidad');
}
function Acta(obj)
{
var val = obj.value;
if(val=="3")
{
	eval('document.form3.num_acta').className = 'FormDataObjectEnabled';
	///eval('document.form3.num_acta').disabled=true;
	eval('document.form3.num_acta').readOnly=false;
}
else
{
	eval('document.form3.num_acta').className = 'FormDataObjectDisabled';
	//eval('document.form3.num_acta').disabled=true;
	eval('document.form3.num_acta').readOnly=true;
}
}
function Empleado()
{
abrir_ventana1('../rhplanilla/empleado_ingreso_list.jsp?fp=ingreso_empleado');
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" >
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RHPLANILLA - ACCIONES - EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<%if (tab.equals("0")){%>

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("accion",accion)%>
<%=fb.hidden("tipo_accion",tipo_accion)%>
<%=fb.hidden("primer_nombre",eval.getPrimerNombre())%>
<%=fb.hidden("segundo_nombre",eval.getSegundoNombre())%>
<%=fb.hidden("primer_apellido",eval.getPrimerApellido())%>
<%=fb.hidden("segundo_apellido",eval.getSegundoApellido())%>
<%=fb.hidden("apellido_casada",eval.getApellidoCasada())%>
<%=fb.hidden("usuario_creacion",eval.getUsuarioCreacion())%>
<%=fb.hidden("fecha_creacion",eval.getFechaCreacion())%>

	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
	<tr class="TextPanel">
		<td width="95%">Datos del Empleado</td>
		<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
	</tr>
		</table>
		</td>
	</tr>
	<tr id="panel0">
		<td>	
		<table width="100%" cellpadding="1" cellspacing="1">								
	<tr class="TextRow01">
		<td width="15%">Empleado</td>
	    <td width="35%"><%=fb.textBox("nombre",eval.getNombre(),false,false,true,40)%></td>														
		<td width="25%">C&eacute;dula</td>
	    <td width="25%"><%=fb.textBox("provincia",eval.getProvincia(),false,false,true,3)%><%=fb.textBox("sigla",eval.getSigla(),false,false,true,3)%><%=fb.textBox("tomo",eval.getTomo(),false,false,true,5)%><%=fb.textBox("asiento",eval.getAsiento(),false,false,true,5)%></td>
														
	</tr>					
	<tr class="TextRow01">
		<td>Cargo</td>
		<td><%=fb.textBox("cargo",eval.getCargo(),false,false,true,5)%><%=fb.textBox("cargoDesc",eval.getCargoDesc(),false,false,true,30)%></td>
		<td>No. Emp <%=fb.textBox("numEmpleado",eval.getNumEmpleado(),false,false,true,5)%></td>	
		<td>No. S Social <%=fb.textBox("numSS",eval.getNumSsocial(),false,false,true,15)%></td>	
	</tr>
	<tr class="TextRow01">
		<td>Gerencia</td>
		<td><%=fb.textBox("gerencia",eval.getGerencia(),false,false,true,5)%><%=fb.textBox("gerenciaDesc",eval.getGerenciaDesc(),false,false,true,30)%></td>
		<td>Fecha Ingr. a la Empresa</td>	
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechaIngreaso" />
			<jsp:param name="valueOfTBox1" value="<%=eval.getFechaIngreso()%>" />
			</jsp:include></td>	
	</tr>	
	<tr class="TextRow01">
		<td>Depto.</td><%//=fb.hidden("unidadAdm",eval.getUnidadAdm())%>
		<td><%=fb.textBox("depto",eval.getDepto(),false,false,true,5)%><%=fb.textBox("desc",eval.getDeptoDesc(),false,false,true,30)%></td>
		<td>Salario Base</td>
		<td><%=fb.decBox("salarioBase",eval.getSalarioBase(),false,false,true,10,8.2)%></td>													
	</tr>	
	<tr class="TextRow01">
		<td>Seccion</td>
		<td><%=fb.textBox("seccion",eval.getSeccion(),false,false,true,5)%><%=fb.textBox("seccionDesc",eval.getSeccionDesc(),false,false,true,30)%></td>
		<td>Gasto Rep.</td>	
		<td><%=fb.textBox("gastoRep",eval.getGastoRep(),false,false,true,20)%></td>	
	</tr>
																					
		</table>
		</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
	<tr class="TextPanel">
		<td width="95%">Detalle del Pr&eacute;stamo</td>
		<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
	</tr>
		</table>
		</td>
	</tr>
	<tr id="panel1">
		<td>	
		<table width="100%" cellpadding="1" cellspacing="1">	
	<tr class="TextRow01">
		<td width="15%">Gerencia</td>
		<td width="35%"><%=fb.textBox("ubica_ge",accionEval.getUbicRhgerenDest(),true,false,true,5)%><%=fb.textBox("ubica_gerenDesc",accionEval.getNewGerenciaDest(),false,false,true,30)%><%=fb.button("btnGerencia","...",false,false,null,null,"onClick=\"javascript:Gerencia(0)\"")%></td>
		<td width="25%">Fecha Efectiva</td>	
		<td width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fechaEfectiva" />
						<jsp:param name="valueOfTBox1" value="<%=fechaEfectiva%>" />
						</jsp:include></td>	
	</tr>	
	<tr class="TextRow01">
		<td>Depto.</td><%//=fb.hidden("unidadAdm",eval.getUnidadAdm())%>
		<td><%=fb.textBox("depto_dest",accionEval.getUbicRhdeptoDest(),true,false,true,5)%><%=fb.textBox("depto_desc",accionEval.getNewDeptoDest(),false,false,true,30)%><%=fb.button("btnDeptoDesp","...",false,false,null,null,"onClick=\"javascript:Direcciones(0)\"")%></td>
		<td>Desde</td>
		<td>		<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="periodoIni" />
					<jsp:param name="valueOfTBox1" value="<%=accionEval.getPeriodoIni()%>" />
					</jsp:include></td>													
	</tr>	
	<tr class="TextRow01">
		<td>Seccion</td>
		<td><%=fb.textBox("seccion_dest",accionEval.getUbicRhseccionDest(),true,false,true,5)%><%=fb.textBox("seccion_desc",accionEval.getNewSeccionDest(),false,false,true,30)%><%=fb.button("btnDeptoSeccion","...",false,false,null,null,"onClick=\"javascript:Secciones(0)\"")%></td>
		<td>Hasta</td>	
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="periodoFin" />
			<jsp:param name="valueOfTBox1" value="<%=accionEval.getPeriodoFin()%>" />
			</jsp:include></td>	
	</tr>
							
	<tr class="TextRow01">
		<td>Comentarios</td>
        <td colspan="2"><%=fb.textarea("comentario_rrhh",accionEval.getComentariosRrhh(),false,false,false,60,3,2000,"","width:100%","")%></td>
		<td>Estado <%=fb.select("estado","T=TRAMITE,A=APROBADO,R=RECHAZADO,N=ANULADO",accionEval.getEstado(),false,false,0)%>
		</td>
	</tr>							
		</table>
		</td>
	</tr>
		<tr class="TextRow02">
		<td align="right">
			Opciones de Guardar: 
			
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
            <%=fb.radio("saveOption","C")%>Cerrar 
			<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
		</td>
	</tr>
			<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

	</table>

<!-- TAB0 DIV END HERE-->
</div>
<%}%>
<%if (tab.equals("1")){%>
<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("accion",accion)%>
<%=fb.hidden("tipo_accion",tipo_accion)%>
<%=fb.hidden("primer_nombre",eval.getPrimerNombre())%>
<%=fb.hidden("segundo_nombre",eval.getSegundoNombre())%>
<%=fb.hidden("primer_apellido",eval.getPrimerApellido())%>
<%=fb.hidden("segundo_apellido",eval.getSegundoApellido())%>
<%=fb.hidden("apellido_casada",eval.getApellidoCasada())%>
<%=fb.hidden("usuario_creacion",eval.getUsuarioCreacion())%>
<%=fb.hidden("fecha_creacion",eval.getFechaCreacion())%>

	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
	<tr class="TextPanel">
		<td width="95%">Datos del Empleado</td>
		<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
	</tr>
		</table>
		</td>
	</tr>
	<tr id="panel10">
		<td>	
		<table width="100%" cellpadding="1" cellspacing="1">								
	<tr class="TextRow01">
		<td width="15%">Empleado</td>
	    <td width="35%"><%=fb.textBox("nombre",eval.getNombre(),false,false,true,40)%></td>														
		<td width="25%">C&eacute;dula</td>
	    <td width="25%"><%=fb.textBox("provincia",eval.getProvincia(),false,false,true,3)%><%=fb.textBox("sigla",eval.getSigla(),false,false,true,3)%><%=fb.textBox("tomo",eval.getTomo(),false,false,true,5)%><%=fb.textBox("asiento",eval.getAsiento(),false,false,true,5)%></td>
														
	</tr>					
	<tr class="TextRow01">
		<td>Cargo</td>
		<td><%=fb.textBox("cargo",eval.getCargo(),false,false,true,5)%><%=fb.textBox("cargoDesc",eval.getCargoDesc(),false,false,true,30)%></td>
		<td>No. Emp <%=fb.textBox("numEmpleado",eval.getNumEmpleado(),false,false,true,5)%></td>	
		<td>No. S Social <%=fb.textBox("numSS",eval.getNumSsocial(),false,false,true,15)%></td>	
	</tr>
	<tr class="TextRow01">
		<td>Gerencia</td>
		<td><%=fb.textBox("gerencia",eval.getGerencia(),false,false,true,5)%><%=fb.textBox("gerenciaDesc",eval.getGerenciaDesc(),false,false,true,30)%></td>
		<td>Fecha Ingr. a la Empresa&nbsp;&nbsp;&nbsp;&nbsp;</td>	
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechaIngreaso" />
			<jsp:param name="valueOfTBox1" value="<%=eval.getFechaIngreso()%>" />
			</jsp:include></td>	
	</tr>	
	<tr class="TextRow01">
		<td>Depto.</td><%//=fb.hidden("unidadAdm",eval.getUnidadAdm())%>
	<td><%=fb.textBox("depto",eval.getDepto(),false,false,true,5)%><%=fb.textBox("deptoDesc",eval.getDeptoDesc(),false,false,true,30)%></td>
		<td>Salario Base</td>
		<td><%=fb.decBox("salarioBase",eval.getSalarioBase(),false,false,true,10,8.2)%></td>													
	</tr>	
	<tr class="TextRow01">
		<td>Seccion</td>
		<td><%=fb.textBox("seccion",eval.getSeccion(),false,false,true,5)%><%=fb.textBox("seccionDesc",eval.getSeccionDesc(),false,false,true,30)%></td>
		<td>Gasto Rep.</td>	
		<td><%=fb.textBox("gastoRep",eval.getGastoRep(),false,false,true,20)%></td>	
	</tr>
	<tr class="TextRow01">
		<td>Horario</td>
		<td colspan="3"><%=fb.textBox("horario",eval.getHorario(),false,false,true,5)%><%=fb.textBox("horarioDesc",eval.getHorarioDesc(),false,false,true,50)%><%//=fb.button("btnHorario","...",false,false,null,null,"onClick=\"javascript:addHorario()\"")%></td>
		
								
	</tr>																
		</table>
		</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
	<tr class="TextPanel">
		<td width="95%">Detalle del Ascenso</td>
		<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
	</tr>
		</table>
		</td>
	</tr>
	<tr id="panel11">
		<td>	
		<table width="100%" cellpadding="1" cellspacing="1">	
	<tr class="TextRow01">
		<td  width="15%">Cargo Nuevo</td>
		<td  width="35%"><%=fb.textBox("cargo_dest",accionEval.getCargoInstiDest(),true,false,true,5)%><%=fb.textBox("cargo_desc",accionEval.getNewCargoDest(),false,false,true,30)%><%=fb.button("btnCargo","...",false,false,null,null,"onClick=\"javascript:Cargosss(1)\"")%></td>
		<td  width="25%">Fecha Efectiva</td>	
		<td  width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
	   					 <jsp:param name="noOfDateTBox" value="1" />
						 <jsp:param name="clearOption" value="true" />
						 <jsp:param name="nameOfTBox1" value="fechaEfectiva" />
						<jsp:param name="valueOfTBox1" value="<%=fechaEfectiva%>" />
						</jsp:include></td>	
	</tr>																
					
	<tr class="TextRow01">
		<td>Horario Nuevo</td>
		<td><%=fb.textBox("newHorario",accionEval.getHorarioDest(),true,false,true,5)%><%=fb.textBox("newHorarioDesc",accionEval.getNewHorarioDest(),false,false,true,30)%><%=fb.button("btnHorario","...",false,false,null,null,"onClick=\"javascript:addHorario()\"")%></td>
		<td>Gasto de Rep. Nuevo</td>
		<td><%=fb.decBox("gastoRepDest",accionEval.getGastoRepDest(),false,false,false,10,8.2)%></td>
	</tr>	
	<tr class="TextRow01">
		<td>Salario Nuevo</td>
		<td><%=fb.decBox("newSalario",accionEval.getSalarioDest(),false,false,false,10,8.2)%></td>
		<td>&nbsp;</td><td>&nbsp;</td>
	</tr>		
	<tr class="TextRow01">
		<td>Comentarios</td>
       	<td colspan="2"><%=fb.textarea("comentario_rrhh",accionEval.getComentariosRrhh(),false,false,false,60,3,2000,"","width:100%","")%></td>
		<td>Estado <%=fb.select("estado","T=TRAMITE,A=APROBADO,R=RECHAZADO,N=ANULADO",accionEval.getEstado(),false,false,0)%></td>
	</tr>							
		</table>
		</td>
	</tr>
	<tr class="TextRow02">
		<td align="right">
			Opciones de Guardar: 
			
    	    <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
            <%=fb.radio("saveOption","C")%>Cerrar 
			<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
		</td>
		</tr>
			<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>

<!-- TAB1 DIV END HERE-->
</div>

<%}%>
<%if (tab.equals("2")){%>
<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

		<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("accion",accion)%>
<%=fb.hidden("tipo_accion",tipo_accion)%>
<%=fb.hidden("primer_nombre",eval.getPrimerNombre())%>
<%=fb.hidden("segundo_nombre",eval.getSegundoNombre())%>
<%=fb.hidden("primer_apellido",eval.getPrimerApellido())%>
<%=fb.hidden("segundo_apellido",eval.getSegundoApellido())%>
<%=fb.hidden("apellido_casada",eval.getApellidoCasada())%>
<%=fb.hidden("usuario_creacion",eval.getUsuarioCreacion())%>
<%=fb.hidden("fecha_creacion",eval.getFechaCreacion())%>

	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
	<tr class="TextPanel">
		<td width="95%">Datos del Empleado</td>
		<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
	</tr>
	</table>					</td>
	</tr>
	<tr id="panel20">
		<td>	
		<table width="100%" cellpadding="1" cellspacing="1">								
	<tr class="TextRow01">
		<td width="15%">Empleado</td>
	    <td width="35%"><%=fb.textBox("nombre",eval.getNombre(),false,false,true,40)%></td>														
		<td width="25%">C&eacute;dula</td>
	    <td width="25%"><%=fb.textBox("provincia",eval.getProvincia(),false,false,true,3)%><%=fb.textBox("sigla",eval.getSigla(),false,false,true,3)%><%=fb.textBox("tomo",eval.getTomo(),false,false,true,5)%><%=fb.textBox("asiento",eval.getAsiento(),false,false,true,5)%></td>
	</tr>					
	<tr class="TextRow01">
		<td>Cargo</td>
		<td><%=fb.textBox("cargo",eval.getCargo(),false,false,true,5)%><%=fb.textBox("cargoDesc",eval.getCargoDesc(),false,false,true,30)%></td>
		<td>No. Emp <%=fb.textBox("numEmpleado",eval.getNumEmpleado(),false,false,true,5)%></td>	
		<td>No. S Social <%=fb.textBox("numSS",eval.getNumSsocial(),false,false,true,15)%></td>	
	</tr>
	<tr class="TextRow01">
		<td>Gerencia</td>
		<td><%=fb.textBox("gerencia",eval.getGerencia(),false,false,true,5)%><%=fb.textBox("gerenciaDesc",eval.getGerenciaDesc(),false,false,true,30)%></td>
		<td>Fecha Ingr. a la Empresa&nbsp;&nbsp;&nbsp;&nbsp;</td>	
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechaIngreaso" />
			<jsp:param name="valueOfTBox1" value="<%=eval.getFechaIngreso()%>" />
			</jsp:include></td>	
	</tr>	
	<tr class="TextRow01">
		<td>Depto.</td>
		<td><%=fb.textBox("depto",eval.getDepto(),false,false,true,5)%><%=fb.textBox("deptoDesc",eval.getDeptoDesc(),false,false,true,30)%></td>
		<td>Salario Base</td>
		<td><%=fb.decBox("salarioBase",eval.getSalarioBase(),false,false,true,10,8.2)%></td>													
	</tr>	
	<tr class="TextRow01">
		<td>Seccion</td>
		<td><%=fb.textBox("seccion",eval.getSeccion(),false,false,true,5)%><%=fb.textBox("seccionDesc",eval.getSeccionDesc(),false,false,true,30)%></td>
		<td>Gasto Rep.</td>	
		<td><%=fb.textBox("gastoRep",eval.getGastoRep(),false,false,true,20)%></td>	
	</tr>
	</table>					</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
	<tr class="TextPanel">
		<td width="95%">Detalle del Traslado</td>
		<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
	</tr>
		</table>					</td>
	</tr>
	<tr id="panel21">
		<td><table width="100%" cellpadding="1" cellspacing="1">
        <tr class="TextRow01">
        <td width="15%">Gerencia</td>
        <td width="35%"><%=fb.textBox("ubica_ge",accionEval.getUbicRhgerenDest(),true,false,true,5)%><%=fb.textBox("ubica_gerenDesc",accionEval.getNewGerenciaDest(),false,false,true,30)%><%=fb.button("btnGerencia","...",false,false,null,null,"onClick=\"javascript:Gerencia(2)\"")%></td>
        <td width="25%">Fecha Efectiva</td>
        <td width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />          
                <jsp:param name="clearOption" value="true" />          
                <jsp:param name="nameOfTBox1" value="fechaEfectiva" />          
                <jsp:param name="valueOfTBox1" value="<%=fechaEfectiva%>" />          
                </jsp:include></td>
    </tr>
    <tr class="TextRow01">
        <td>Depto.</td>
        <td><%=fb.textBox("depto_dest",accionEval.getUbicRhdeptoDest(),true,false,true,5)%><%=fb.textBox("depto_desc",accionEval.getNewDeptoDest(),false,false,true,30)%><%=fb.button("btnDeptoDesp","...",false,false,null,null,"onClick=\"javascript:Direcciones(2)\"")%></td>
        <td>Desde</td>
        <td><jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />          
            <jsp:param name="clearOption" value="true" />          
            <jsp:param name="nameOfTBox1" value="periodo_ini" />          
            <jsp:param name="valueOfTBox1" value="<%=accionEval.getPeriodoIni()%>" />          
            </jsp:include></td>
    </tr>
    <tr class="TextRow01">
        <td>Seccion</td>
        <td><%=fb.textBox("seccion_dest",accionEval.getUbicRhseccionDest(),true,false,true,5)%><%=fb.textBox("seccion_desc",accionEval.getNewSeccionDest(),false,false,true,30)%><%=fb.button("btnDeptoSeccion","...",false,false,null,null,"onClick=\"javascript:Secciones(2)\"")%></td>
        <td>Salario Nuevo</td>
        <td><%=fb.decBox("newSalario",accionEval.getSalarioDest(),false,false,false,10,8.2)%></td>
    </tr>
    <tr class="TextRow01">
        <td>Cargo Nuevo</td>
        <td><%=fb.textBox("cargo_dest",accionEval.getCargoInstiDest(),true,false,true,5)%><%=fb.textBox("cargo_desc",accionEval.getNewCargoDest(),false,false,true,30)%><%=fb.button("btnCargo","...",false,false,null,null,"onClick=\"javascript:Cargosss(2)\"")%></td>
		<td>Gasto de Rep. Nuevo</td>
        <td><%=fb.decBox("gastoRepDest",accionEval.getGastoRepDest(),false,false,false,10,8.2)%></td>
    </tr>
    <tr class="TextRow01">
		<td>Comentarios</td>
        <td colspan="2"><%=fb.textarea("comentario_rrhh",accionEval.getComentariosRrhh(),false,false,false,60,3,2000,"","width:100%","")%></td>
		<td>Estado <%=fb.select("estado","T=TRAMITE,A=APROBADO,R=RECHAZADO,N=ANULADO",accionEval.getEstado(),false,false,0)%></td>
		</tr>
    </table></td>
	</tr>
	
	<tr class="TextRow02">
		<td align="right">
			Opciones de Guardar: 
			
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
            <%=fb.radio("saveOption","C")%>Cerrar 
			<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>										        </td>
	</tr>
			<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
<!-- TAB2 DIV END HERE-->
</div>
<%}%>
<%if (tab.equals("3")){%>
<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("accion",accion)%>
<%=fb.hidden("tipo_accion",tipo_accion)%>
<%=fb.hidden("primer_nombre",eval.getPrimerNombre())%>
<%=fb.hidden("segundo_nombre",eval.getSegundoNombre())%>
<%=fb.hidden("primer_apellido",eval.getPrimerApellido())%>
<%=fb.hidden("segundo_apellido",eval.getSegundoApellido())%>
<%=fb.hidden("apellido_casada",eval.getApellidoCasada())%>
<%=fb.hidden("usuario_creacion",eval.getUsuarioCreacion())%>
<%=fb.hidden("fecha_creacion",eval.getFechaCreacion())%>

	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
	<tr class="TextPanel">
		<td width="95%">Datos del Empleado</td>
		<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
	</tr>
		</table>
		</td>
	</tr>
	<tr id="panel30">
		<td>	
		<table width="100%" cellpadding="1" cellspacing="1">								
	<tr class="TextRow01">
		<td width="15%">Empleado</td>
	    <td width="35%"><%=fb.textBox("nombre",eval.getNombre(),false,false,true,40)%></td>														
		<td width="25%">C&eacute;dula</td>
	    <td width="25%"><%=fb.textBox("provincia",eval.getProvincia(),false,false,true,3)%><%=fb.textBox("sigla",eval.getSigla(),false,false,true,3)%><%=fb.textBox("tomo",eval.getTomo(),false,false,true,5)%><%=fb.textBox("asiento",eval.getAsiento(),false,false,true,5)%></td>
														
	</tr>					
	<tr class="TextRow01">
		<td>Cargo</td>
		<td><%=fb.textBox("cargo",eval.getCargo(),false,false,true,5)%><%=fb.textBox("cargoDesc",eval.getCargoDesc(),false,false,true,30)%></td>
		<td>No. Emp <%=fb.textBox("numEmpleado",eval.getNumEmpleado(),false,false,true,5)%></td>	
		<td>No. S Social <%=fb.textBox("numSS",eval.getNumSsocial(),false,false,true,15)%></td>	
	</tr>
	<tr class="TextRow01">
		<td>Gerencia</td>
		<td><%=fb.textBox("gerencia",eval.getGerencia(),false,false,true,5)%><%=fb.textBox("gerenciaDesc",eval.getGerenciaDesc(),false,false,true,30)%></td>
		<td>Fecha Ingr. a la Empresa&nbsp;&nbsp;&nbsp;&nbsp;</td>	
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechaIngreaso" />
			<jsp:param name="valueOfTBox1" value="<%=eval.getFechaIngreso()%>" />
			</jsp:include></td>	
	</tr>	
	<tr class="TextRow01">
		<td>Depto.</td><%//=fb.hidden("unidadAdm",eval.getUnidadAdm())%>
		<td><%=fb.textBox("depto",eval.getDepto(),false,false,true,5)%><%=fb.textBox("deptoDesc",eval.getDeptoDesc(),false,false,true,30)%></td>
		<td>Salario Base</td>
		<td><%=fb.decBox("salarioBase",eval.getSalarioBase(),false,false,true,10,8.2)%></td>													
	</tr>	
	<tr class="TextRow01">
		<td>Seccion</td>
		<td><%=fb.textBox("seccion",eval.getSeccion(),false,false,true,5)%><%=fb.textBox("seccionDesc",eval.getSeccionDesc(),false,false,true,30)%></td>
		<td>Gasto Rep.</td>	
		<td><%=fb.textBox("gastoRep",eval.getGastoRep(),false,false,true,20)%></td>	
	</tr>
		</table>
		</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
	<tr class="TextPanel">
		<td width="95%">Detalle del Egreso</td>
		<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;</td>
	</tr>
		</table>					</td>
	</tr>
	<tr id="panel31">
		<td><table width="100%" cellpadding="1" cellspacing="1">
    <tr class="TextRow01">
        <td width="15%">Tipo de Egreso</td>
        <td width="35%"><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion FROM tbl_pla_ap_sub_tipo where tipo_accion=3 ORDER  BY 1","tipo_egreso",tipo_accion,false,false,0,"",null,"onChange=\"javascript:Acta(this)\"")%></td>
        <td width="25%">Fecha Egreso</td>
        <td width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
      		            <jsp:param name="noOfDateTBox" value="1" />          
               			<jsp:param name="clearOption" value="true" />          
                		<jsp:param name="nameOfTBox1" value="fecha_efectiva" />          
                		<jsp:param name="valueOfTBox1" value="<%=fechaEfectiva%>" />          
              			</jsp:include></td>
    </tr>
	<tr class="TextRow01">
		 <td>Num. del Acta </td>
         <td><%=fb.textBox("num_acta",accionEval.getNumActaDefun(),false,false,true,25,20)%></td>
         <td>Fecha del Acta</td>
         <td><jsp:include page="../common/calendar.jsp" flush="true">
             <jsp:param name="noOfDateTBox" value="1" />          
             <jsp:param name="clearOption" value="true" />          
             <jsp:param name="nameOfTBox1" value="fec_acta_defun" />          
             <jsp:param name="valueOfTBox1" value="<%=accionEval.getFecActaDefun()%>" />          
    	     </jsp:include></td>
	</tr>
    <tr class="TextRow01">
        <td>Causal del Hecho</td>
        <td colspan="3"><%=fb.textarea("causal_hecho",accionEval.getCausalHecho(),false,false,false,60,3,3000,"","width:100%","")%></td>
    </tr>
    <tr class="TextRow01">
		<td>Comentarios</td>
        <td colspan="2"><%=fb.textarea("comentario_rrhh",accionEval.getComentariosRrhh(),false,false,false,60,3,2000,"","width:100%","")%></td>
		<td>Estado <%=fb.select("estado","T=TRAMITE,A=APROBADO,R=RECHAZADO,N=ANULADO",accionEval.getEstado(),false,false,0)%></td>
    </tr>
    </table></td>
	</tr>
				
	<tr class="TextRow02">
		<td align="right">
			Opciones de Guardar: 
			
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
            <%=fb.radio("saveOption","C")%>Cerrar 
			<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>								        </td>
	</tr>
			<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
<!-- TAB3 DIV END HERE-->
</div>
<%}%>
<%if (tab.equals("4")){%>

<!-- TAB4 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

	<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("tab","4")%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("emp_id",emp_id)%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("accion",accion)%>
	<%=fb.hidden("tipo_accion",tipo_accion)%>
	<%=fb.hidden("usuario_creacion",eval.getUsuarioCreacion())%>
	<%=fb.hidden("fecha_creacion",eval.getFechaCreacion())%>

	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(40)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
	<tr class="TextPanel">
		<td width="95%">Datos del Empleado</td>
		<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus40" style="display:none">+</label><label id="minus40">-</label></font>]&nbsp;</td>
	</tr>
		</table>
		</td>
	</tr>
	<tr id="panel40">
		<td>	
		<table width="100%" cellpadding="1" cellspacing="1">								
	<tr class="TextRow01">
	    <td width="20%">Primer Nombre</td>
        <td width="20%">Segundo Nombre</td>
		<td width="20%">Primer Apellido</td>
		<td width="20%">Segundo Apellido</td>
		<td width="20%">Apellido de Casada</td>
	</tr>
	<tr class="TextRow01">
		<td><%=fb.textBox("primer_nombre",eval.getPrimerNombre(),true,false,false,20,30)%></td>
        <td><%=fb.textBox("segundo_nombre",eval.getSegundoNombre(),false,false,false,20,30)%></td>
    	<td><%=fb.textBox("primer_apellido",eval.getPrimerApellido(),true,false,false,20,30)%></td>
        <td><%=fb.textBox("segundo_apellido",eval.getSegundoApellido(),false,false,false,20,30)%></td>
		<td><%=fb.textBox("apellido_casada",eval.getApellidoCasada(),false,false,false,20,30)%></td>
    </tr>
    <tr class="TextRow01">
        <td>C&eacute;dula</td>
	    <td colspan="4"><%=fb.textBox("provincia",eval.getProvincia(),false,false,true,3)%><%=fb.textBox("sigla",eval.getSigla(),false,false,true,3)%><%=fb.textBox("tomo",eval.getTomo(),false,false,true,5)%><%=fb.textBox("asiento",eval.getAsiento(),false,false,true,5)%><%=fb.button("btnEmpleado","...",false,false,null,null,"onClick=\"javascript:Empleado()\"")%></td>
													
    </tr>
		</table>
		</td>
	</tr>
	<tr>
		<td onClick="javascript:showHide(41)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
	<tr class="TextPanel">
		<td width="95%">Detalle del Ingreso</td>
		<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus41" style="display:none">+</label><label id="minus41">-</label></font>]&nbsp;</td>
	</tr>
	</table>					</td>
	</tr>
	<tr id="panel41">
		<td><table width="100%" cellpadding="1" cellspacing="1">
    <tr class="TextRow01">
        <td width="15%">Tipo Ingreso</td>
        <td width="35%"><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion FROM tbl_pla_ap_sub_tipo where tipo_accion not in(2,3)ORDER  BY 1","tipo_ingreso",accion,false,false,0,"",null,"")%></td>
        <td width="25%">Fecha&nbsp;&nbsp;&nbsp;&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />          
                <jsp:param name="clearOption" value="true" />          
                <jsp:param name="nameOfTBox1" value="fecha_doc" />          
                <jsp:param name="valueOfTBox1" value="<%=accionEval.getFechaDoc()%>" />          
                </jsp:include></td>
        <td width="25%">Estado&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.select("estado","T=TRAMITE,A=APROBADO,R=RECHAZADO,N=ANULADO",accionEval.getEstado(),false,false,0)%></td>
    </tr>
	<tr class="TextRow01">
		 <td>Cargo</td>
         <td><%=fb.textBox("cargo_dest",accionEval.getCodigoEstructura(),true,false,true,5)%><%=fb.textBox("cargo_desc",accionEval.getNewCargoDest(),false,false,true,30)%><%=fb.button("btnCargo","...",false,false,null,null,"onClick=\"javascript:Cargosss(4)\"")%></td>
         <td>Salario</td>
	  	 <td><%=fb.decBox("newSalario",accionEval.getSalarioDest(),false,false,false,10,8.2)%></td>
	</tr>
	<tr class="TextRow01">
		<td>Departamento</td>
        <td><%=fb.textBox("seccion_dest",accionEval.getUnidadAdm(),true,false,true,5)%><%=fb.textBox("seccion_desc",accionEval.getNewPosicionDest(),false,false,true,30)%><%=fb.button("btnDeptoDesp","...",false,false,null,null,"onClick=\"javascript:Secciones(4)\"")%></td>
		<td>Gasto de Rep. Nuevo</td>
		<td><%=fb.decBox("gastoRepDest",accionEval.getGastoRepDest(),false,false,false,10,8.2)%></td>
    </tr>
    <tr class="TextRow01">
        <td>Inicio de Labores</td>
		<td><jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />          
            <jsp:param name="clearOption" value="true" />          
            <jsp:param name="nameOfTBox1" value="fecha_inicio" />          
            <jsp:param name="valueOfTBox1" value="<%=accionEval.getFechaEfectiva()%>" />          
            </jsp:include></td>
		<td>Prueba de Ingreso</td>
		<td><%=fb.select("resultado_ppru","S=SATISFACTORIA,N=NO SATISFACTORIA",accionEval.getResultadoPpru(),false,false,0)%></td>
	</tr>
	<tr class="TextRow01">		
		<td>Periodo Inicial</td>
		<td>		<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="periodo_ini_ingreso" />
					<jsp:param name="valueOfTBox1" value="<%=accionEval.getPeriodoIni()%>" />
					</jsp:include></td>													
		<td>Periodo Final</td>	
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="periodo_fin_ingreso" />
			<jsp:param name="valueOfTBox1" value="<%=accionEval.getPeriodoFin()%>" />
			</jsp:include></td>	
	</tr>
        </table></td>
	</tr>
				
	<tr class="TextRow02">
		<td align="right">
			Opciones de Guardar: 
			
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
            <%=fb.radio("saveOption","C")%>Cerrar 
			<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>									        </td>
	</tr>
			<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
<!-- TAB3 DIV END HERE-->
</div>
<!-- MAIN DIV END HERE -->
<%}%>
</div>

<script type="text/javascript">
<%
String tabLabel = "";// "'Prestamo','Ascenso','Traslado'";
//String tabLabel =  "'Prestamo','Ascenso','Traslado','Egreso','Ingreso'";

if(tab.equals("0"))
{tabLabel = "'Prestamo'";}
else if(tab.equals("1"))
{
tab = ""+(Integer.parseInt(tab)-1);
tabLabel = "'Ascenso'";
}
else if(tab.equals("2"))
{
tab = ""+(Integer.parseInt(tab)-2);
tabLabel = "'Traslado'";
}
else if(tab.equals("3"))
{
tab = ""+(Integer.parseInt(tab)-3);
tabLabel = "'Egreso'";
}
else if(tab.equals("4"))
{
tab = ""+(Integer.parseInt(tab)-4);
tabLabel = "'Ingreso'";
}
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');

</script>

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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	emp_id = request.getParameter("emp_id");
	accion=request.getParameter("accion");
	tipo_accion=request.getParameter("tipo_accion");
		 AccionEnc acEmp = new AccionEnc();
		
		 acEmp.setCompania((String) session.getAttribute("_companyId"));
		 acEmp.setTipoAccion(request.getParameter("accion"));
		// System.out.println("tipo egreso--"+request.getParameter("tipo_egreso"));
		 if(tab.equals("3"))
		 acEmp.setSubTAccion(request.getParameter("tipo_egreso"));
		 else
		 acEmp.setSubTAccion(request.getParameter("tipo_accion"));
		 acEmp.setTDocumento("");
		 acEmp.setNumDocumento("");
		 acEmp.setEstado(request.getParameter("estado"));
		 acEmp.setUsuarioModificacion((String) session.getAttribute("_userName")); 	
		 acEmp.setFechaModificacion(cDateTime);
		 if (mode.equalsIgnoreCase("add"))
		 {	 
				acEmp.setMode("add");
		 }
		 else if (mode.equalsIgnoreCase("edit"))
		 {	  
				acEmp.setMode("edit");	
		 }
		 //INTO AP_ACCION_ENC
		 AccionesMovilidad EmpMovie = new AccionesMovilidad();
		
		 EmpMovie.setUbicRhgeren(request.getParameter("gerencia"));
		 EmpMovie.setUbicRhdepto(request.getParameter("depto"));
		 EmpMovie.setUbicRhseccion(request.getParameter("seccion"));
		 EmpMovie.setCargo(request.getParameter("cargo"));
		 EmpMovie.setNumEmpleado(request.getParameter("numEmpleado"));
		 EmpMovie.setNumSsocial(request.getParameter("numSS"));
		 EmpMovie.setSalario(request.getParameter("salarioBase"));
		 EmpMovie.setGastoRep(request.getParameter("gastoRep"));
		 EmpMovie.setUsuarioModificacion((String) session.getAttribute("_userName")); 	
		 EmpMovie.setFechaModificacion(cDateTime);
		 EmpMovie.setUbicPlaseccion(request.getParameter("seccion"));
		 EmpMovie.setCodigoEstructura(request.getParameter("cargo"));
		 EmpMovie.setUnidadAdm(request.getParameter("gerencia"));
		// EmpMovie.setEstado(request.getParameter("estado"));
		 EmpMovie.setComentariosRrhh(request.getParameter("comentario_rrhh"));
 		 EmpMovie.setFechaEfectiva(request.getParameter("fechaEfectiva"));
		 
	if (tab.equals("0"))
	{
		EmpMovie.setUbicRhgerenDest(request.getParameter("ubica_ge"));
		EmpMovie.setUbicRhdeptoDest(request.getParameter("depto_dest"));
		EmpMovie.setUbicRhseccionDest(request.getParameter("seccion_dest"));
		EmpMovie.setPeriodoIni(request.getParameter("periodoIni"));
		EmpMovie.setPeriodoFin(request.getParameter("periodoFin"));
	 EmpMovie.setEstado(request.getParameter("estado"));
		AccMgr.add(acEmp,EmpMovie);
	}
	else if (tab.equals("1"))
	{
			EmpMovie.setHorario(request.getParameter("Horario"));
			EmpMovie.setHorarioDest(request.getParameter("newHorario"));
		    EmpMovie.setSalarioDest(request.getParameter("newSalario"));
		    EmpMovie.setGastoRepDest(request.getParameter("gastoRepDest"));
			EmpMovie.setCargoInstiDest(request.getParameter("cargo_dest"));
			EmpMovie.setEstado(request.getParameter("estado"));
			AccMgr.add(acEmp,EmpMovie);
	}
	else if (tab.equals("2"))
	{
			EmpMovie.setUbicRhgerenDest(request.getParameter("ubica_ge"));
		    EmpMovie.setUbicRhdeptoDest(request.getParameter("depto_dest"));
			EmpMovie.setUbicRhseccionDest(request.getParameter("seccion_dest"));
		    EmpMovie.setCargoInstiDest(request.getParameter("cargo_dest"));
			EmpMovie.setPeriodoIni(request.getParameter("periodo_ini"));
			EmpMovie.setSalarioDest(request.getParameter("newSalario"));
			EmpMovie.setEstado(request.getParameter("estado"));
		    EmpMovie.setGastoRepDest(request.getParameter("gastoRepDest"));
			AccMgr.add(acEmp,EmpMovie);
			
	}
	else if(tab.equals("3"))
	{
		EmpMovie.setFechaEfectiva(request.getParameter("fecha_efectiva"));
		EmpMovie.setSubTAccion(request.getParameter("tipo_egreso"));
		EmpMovie.setCausalHecho(request.getParameter("causal_hecho"));
		EmpMovie.setNumActaDefun(request.getParameter("num_acta"));
		EmpMovie.setFecActaDefun(request.getParameter("fec_acta_defun"));
		EmpMovie.setEstado(request.getParameter("estado"));
		AccMgr.add(acEmp,EmpMovie);
		tipo_accion=request.getParameter("tipo_egreso");
	}
	else if(tab.equals("4"))
	{
			EmpMovie.setFechaEfectiva(request.getParameter("fecha_inicio"));
			EmpMovie.setPeriodoIni(request.getParameter("periodo_ini_ingreso"));
		    EmpMovie.setPeriodoFin(request.getParameter("periodo_fin_ingreso"));
			EmpMovie.setSalarioDest(request.getParameter("newSalario"));
		    EmpMovie.setGastoRepDest(request.getParameter("gastoRepDest"));
			EmpMovie.setResultadoPpru(request.getParameter("resultado_ppru"));
			EmpMovie.setCodigoEstructura(request.getParameter("cargo_dest"));
		    EmpMovie.setUnidadAdm(request.getParameter("seccion_dest"));
			EmpMovie.setSubTAccion(request.getParameter("tipo_ingreso"));
			EmpMovie.setEstado(request.getParameter("estado"));
			tipo_accion=request.getParameter("tipo_ingreso");
			AccMgr.add(acEmp,EmpMovie);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (AccMgr.getErrCode().equals("1"))
{
%>
	alert('<%=AccMgr.getErrMsg()%>');
<%
	if(tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_accionmove.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_accionmove.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/list_accionmove.jsp';
<%
		}
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
} else throw new Exception(AccMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=e&mode=edit&tab=<%=tab%>&accion=<%=accion%>&tipo_accion=<%=tipo_accion%>&emp_id=<%=emp_id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>