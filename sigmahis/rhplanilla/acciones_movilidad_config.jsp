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
AccionEnc eval= new AccionEnc();// Datos del Empleado
AccionesMovilidad accionEval = new AccionesMovilidad();//Datos del encabesado
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
AccMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();

String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String mode1 = request.getParameter("mode1");
String emp_id = request.getParameter("emp_id");
String fecha = request.getParameter("fecha");
String id = request.getParameter("id");
String tipo_accion = request.getParameter("tipo_accion");
String sub_tipo_accion = request.getParameter("sub_tipo_accion");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String fechaEfectiva ="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate =  CmnMgr.getCurrentDate("dd/mm/yyyy");
String filter="";
String fecha_doc = request.getParameter("fecha_doc");
String fecha_efectiva = request.getParameter("fecha_efectiva");
String prov = request.getParameter("prov");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
boolean viewMode = false;
if (fg == null) fg = "";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (mode1 == null) mode1 = "add";
if (mode1.equalsIgnoreCase("view")) viewMode = true;
if (tab == null) tab = "0";
if (fecha == null) fecha = ""+cDate;
if(request.getParameter("tipo_accion")==null)tipo_accion="1";
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(!tipo_accion.trim().equals("1"))
if ( emp_id == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");
if ( tipo_accion == null) throw new Exception("El tipo de acccion no es válido. Por favor intente nuevamente!");
//if(!tipo_accion.trim().equals("3")&& !tipo_accion.trim().equals("1"))
//if ( sub_tipo_accion == null) throw new Exception("El sub tipo de acccion no es válida. Por favor intente nuevamente!");
if (fecha_doc == null) fecha_doc = cDate;

if(!fp.equalsIgnoreCase("ingreso"))
{
	sql="select distinct(b.emp_id),b.provincia, b.sigla, b.tomo, b.asiento, b.compania, b.primer_nombre as primerNombre,b.segundo_nombre as segundoNombre, b.primer_apellido as primerApellido,b.segundo_apellido as segundoApellido,b.apellido_casada as apellidoCasada, to_char(b.num_empleado) as numEmpleado, b.num_ssocial as numSsocial,b.salario_base as salarioBase, b.sexo, b.cargo, b.unidad_organi ubicDepto, b.gasto_rep as gastoRep, b.ubic_depto as unidadOrgani, b.ubic_seccion ubicSeccion, b.seccion, b.emp_id as empId, b.ubic_fisica as ubicFisica, b.primer_nombre||decode(b.segundo_nombre,null,' ',' '||b.segundo_nombre)||' '||b.primer_apellido||decode(b.segundo_apellido,null,' ',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_casada,null,' ',' '||b.apellido_casada)) as nombre, un.descripcion as gerenciaDesc, dep.descripcion as deptoDesc, sec.descripcion as seccionDesc,ca.denominacion as cargoDesc,b.horario ,hr.descripcion as horarioDesc,to_char(b.fecha_ingreso,'dd/mm/yyyy')as fechaIngreso from vw_pla_empleado b , tbl_sec_unidad_ejec un , tbl_sec_unidad_ejec sec, tbl_sec_unidad_ejec dep, tbl_pla_cargo ca, tbl_pla_horario_trab hr where b.emp_id="+emp_id+" and b.compania="+(String) session.getAttribute("_companyId")+" and b.ubic_depto= un.codigo(+) and b.unidad_organi=dep.codigo(+) and b.seccion=sec.codigo(+) and b.cargo=ca.codigo(+) and b.horario=hr.codigo(+) and b.compania = un.compania(+) and b.compania = sec.compania(+) and b.compania = ca.compania(+) and b.compania = hr.compania(+)";
	System.out.println("sql:\n"+sql);
eval = (AccionEnc) sbb.getSingleRowBean(ConMgr.getConnection(),sql,AccionEnc.class);

	eval.setFechaCreacion(cDateTime);
	eval.setUsuarioCreacion((String) session.getAttribute("_userName"));

		//if (!fp.equalsIgnoreCase("new")){
		filter=" and sub_t_accion="+sub_tipo_accion+" and trunc(a.fecha_doc) = to_date('"+fecha_doc+"', 'dd/mm/yyyy')";
		//} else filter=" and sub_t_accion=999  ";

		if(mode.equals("edit") || mode.equals("view")){
		sql="select a.compania, a.tipo_accion as tipoAccion, a.sub_t_accion as subTAccion, to_char(a.fecha_doc,'dd/mm/yyyy') as fechaDoc, a.t_documento as tDocumento, a.num_documento as numDocumento, a.ced_provincia as cedProvincia,a.ced_sigla as cedSigla, a.ced_tomo as cedTomo, a.ced_asiento as cedAsiento, a.num_ssocial as numSsocial, a.codigo_general as codigoGeneral,a.grado_sal as gradoSal,a.salario, a.posicion, a.anio_partida as anioPartida, a.area_partida as areaPartida, a.ent_partida as entPartida, a.tipo_pgpartida as tipoPgpartida,a.prog_partida as progPartida, a.ffin_partida as ffinPartida, a.subp_partida as subpPartida, a.acti_partida as actiPartida, a.obj_partida as objPartida, to_char(a.fecha_actap,'dd/mm/yyyy')as fechaActap, a.unidad_adm as unidadAdm, a.resultado_ppru as resultadoPpru, a.num_con_ascenso as numConAscenso, a.cod_a_dest as codADes, a.cod_i_dest as codIDest, a.cargo_insti_dest as cargoInstiDest,a.posicion_dest as posicionDest, a.unidad_adm_dest as  unidadAdmDest , a.salario_dest as salarioDest,a.anio_partida_dest as anioPartidaDest, a.area_partida_dest as areaPartidaDest, a.ent_partida_dest as entPartidaDest, a.tipo_pgpartida_dest as tipoPgpartidaDest, a.prog_partida_dest as progPartidaDest, a.ffin_partida_dest as ffinPartidaDest, a.subp_partida_dest as subpPartidaDest, a.acti_partida_dest as actiPartidaDest, a.obj_partida_dest as objPartidaDest, decode(to_char(a.periodo_ini,'dd/mm/yyyy'),null,'',to_char(a.periodo_ini,'dd/mm/yyyy')) as periodoIni, decode(to_char(a.periodo_fin,'dd/mm/yyyy'),null,'',to_char(a.periodo_fin,'dd/mm/yyyy')) as periodoFin, a.ced_provincia2 as cedProvincia2, a.ced_sigla2 as cedSigla2, a.ced_tomo2 as cedTomo2, a.ced_asiento2 as cedAsiento2, a.tipo_permiso as tipoPermiso, a.thora_ause as thoraAuse, a.tminuto_ause as tminutoAuse, a.tdias_ause as tdiasAuse, nvl(to_char(a.fecha_efectiva,'dd/mm/yyyy'),' ') as fechaEfectiva, a.reincorporacion, a.periodo_ini_vac as periodoIniVac, a.periodo_fin_vac as periodoFinVac, a.dias_resuelto as diasResuelto, a.dias_tomado as diasTomado, a.dias_pendiente as diasPendiente, a.t_documentore as tDocumentore, a.num_documentore as numDocumentore, to_char(a.fecha_docre,'dd/mm/yyyy')as fechaDocre, a.num_decretorf as numDecretorf, a.tipo_servidor as tipoServidor, a.causal_hecho as causalHecho, a.causal_derecho as causalDerecho, a.derecho_intr as derechoIntr, a.num_acta_defun as numActaDefun, decode(to_char(a.fec_acta_defun,'dd/mm/yyyy'),null,' ',to_char(a.fec_acta_defun,'dd/mm/yyyy'))as fecActaDefun, a.codigo_estructura as  codigoEstructura, a.codigo_est_dest as codigoEstDest, a.gasto_rep as gastoRep, a.gasto_rep_dest as  gastoRepDest, a.num_planilla as numPlanilla, a.num_planilla_dest as numPlanillaDest, to_char(a.num_empleado) as  numEmpleado,  a.usuario_creacion as usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy')as fechaCreacion, a.comentarios_rrhh as  comentariosRrhh, a.comentarios_pla as comentariosPla, a.cargo, decode(a.tipo_accion, 3, a.ubic_rhgeren, decode(a.sub_t_accion, 5, a.ubic_rhgeren_dest, 2, a.ubic_rhgeren_dest, 1, a.ubic_rhgeren)) as ubicrhgeren, decode(a.tipo_accion, 3, a.ubic_rhdepto, decode(a.sub_t_accion, 5, a.ubic_rhdepto_dest, 2, a.ubic_rhgeren_dest, 1, a.ubic_rhdepto))  as ubicrhdepto, decode(a.tipo_accion, 3, a.ubic_rhseccion, decode(a.sub_t_accion, 5, a.ubic_rhseccion_dest, 2, a.ubic_rhgeren_dest, 1, a.ubic_rhseccion)) as ubicrhseccion, a.ubic_plaseccion as ubicPlaseccion, a.estado, to_char(a.fecha_ingreso,'dd/mm/yyyy')as fechaIngreso, a.horario, nvl(a.horario_dest,a.horario) as horarioDest, nvl(a.ubic_rhgeren_dest, a.ubic_rhgeren) as ubicRhgerenDest, nvl(a.ubic_rhdepto_dest, a.ubic_rhdepto) as ubicRhdeptoDest, nvl(a.ubic_rhseccion_dest,ubic_rhseccion) as ubicRhseccionDest,a.origen_datos as origenDatos, a.sol_empleo_anio as solEmpleoAnio, a.sol_empleo_codigo as solEmpleoCodigo,a.usuario_anula as usuarioAnula, to_char(a.fecha_anula,'dd/mm/yyyy')as fechaAnula, a.justificacion_anula as justificacionAnula,a.emp_id as empId,un.descripcion as newGerenciaDest,dep.descripcion as newDeptoDest,sec.descripcion as newSeccionDest,ca.denominacion as newCargoDest,hr.descripcion as newHorarioDest, cEstruc.descripcion as NewPosicionDest from tbl_pla_ap_accion_per a, tbl_sec_unidad_ejec un ,tbl_sec_unidad_ejec sec,tbl_sec_unidad_ejec dep,tbl_sec_unidad_ejec uAdm,tbl_sec_unidad_ejec cEstruc,tbl_pla_cargo ca,tbl_pla_horario_trab hr  where  a.emp_id="+emp_id+" and a.compania="+(String) session.getAttribute("_companyId")+" and a.tipo_accion= "+tipo_accion+filter+" and a.compania = un.compania(+) and nvl(a.ubic_rhgeren_dest, a.ubic_rhgeren) = un.codigo(+) and a.compania = sec.compania(+) and nvl(a.ubic_rhseccion_dest,a.ubic_rhseccion) = sec.codigo(+) and a.compania = dep.compania(+) and nvl(a.ubic_rhdepto_dest, a.ubic_rhdepto) = dep.codigo(+) and a.compania = uadm.compania(+) and a.unidad_adm = uadm.codigo(+) and a.compania = cestruc.compania(+) and a.codigo_estructura = cestruc.codigo(+) and a.compania = ca.compania(+) and a.cargo_insti_dest = ca.codigo(+) and a.compania = hr.compania(+) and nvl(a.horario_dest,a.horario) = hr.codigo(+)" ;
		System.out.println("sql:\n"+sql);
		accionEval = (AccionesMovilidad) sbb.getSingleRowBean(ConMgr.getConnection(),sql,AccionesMovilidad.class);

		if(accionEval!=null)
		{
			mode="edit";
			if(accionEval.getFechaEfectiva()!=null && !accionEval.getFechaEfectiva().trim().equals(""))
			{
			fechaEfectiva=accionEval.getFechaEfectiva();
			fecha_doc=accionEval.getFechaDoc();
			}
		}
		else
		{
			accionEval = new AccionesMovilidad();
			mode="add";
			fechaEfectiva = cDateTime.substring(0,10);
			accionEval.setFechaDoc(cDateTime.substring(0,10));
		}
	}
}
else
{
	eval= new AccionEnc();
	accionEval = new AccionesMovilidad();
	if(mode==null) mode="add";
	fechaEfectiva = cDateTime.substring(0,10);
	accionEval.setFechaDoc(cDateTime.substring(0,10));
	eval.setFechaCreacion(cDateTime);
	eval.setUsuarioCreacion((String) session.getAttribute("_userName"));
	if(tab.equals("4") && (mode.equals("edit") || mode.equals("view")))
	{
		sql = "select compania, tipo_accion tipoAccion, sub_t_accion subtaccion, to_char(fecha_doc, 'dd/mm/yyyy') fechadoc, estado, usuario_creacion usuariocreacion, usuario_modificacion usuariomodificacion, to_char(fecha_creacion, 'dd/mm/yyyy') fechacreacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fechamodificacion from  tbl_pla_ap_accion_enc where compania = "+(String) session.getAttribute("_companyId")+" and tipo_accion = "+tipo_accion+" and sub_t_accion = "+sub_tipo_accion+" and trunc(fecha_doc) = to_date('"+fecha_doc+"', 'dd/mm/yyyy')";
		//eval = (AccionEnc) sbb.getSingleRowBean(ConMgr.getConnection(),sql,AccionEnc.class);

		sql = "select compania, tipo_accion tipoaccion, sub_t_accion subtaccion, to_char(fecha_doc, 'dd/mm/yyyy') fechadoc, primer_nombre primernombre, primer_apellido primerapellido, ced_provincia cedprovincia, ced_sigla cedsigla, ced_tomo cedtomo, ced_asiento cedasiento, salario, gasto_rep gastorep, emp_id empid, num_empleado numepleado, resultado_ppru resultadoppru, segundo_nombre segundonombre, segundo_apellido segundoapellido, unidad_adm unidadadm, salario_dest salariodest, nvl(to_char(periodo_ini, 'dd/mm/yyyy'), ' ') periodoini, nvl(to_char(fecha_efectiva, 'dd/mm/yyyy'),' ') as fechaefectiva, codigo_estructura codigoestructura, origen_datos origendatos, sol_empleo_anio solempleoanio, sol_empleo_codigo solempleocodigo, usuario_creacion usuariocreacion, usuario_modificacion usuariomodificacion, to_char(fecha_creacion, 'dd/mm/yyyy') fechacreacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fechamodificacion, nvl((select denominacion from tbl_pla_cargo where compania = "+(String) session.getAttribute("_companyId")+" and codigo = p.codigo_estructura), ' ') newcargodest, nvl((select descripcion from tbl_sec_unidad_ejec where compania = "+(String) session.getAttribute("_companyId")+" and nivel = 2 and codigo = p.unidad_adm), ' ') newPosicionDest, nvl (to_char (periodo_fin, 'dd/mm/yyyy'), ' ') periodofin, nvl(num_ssocial, ' ') numssocial,p.num_empleado numEmpleado from tbl_pla_ap_accion_per p where compania = "+(String) session.getAttribute("_companyId")+" and tipo_accion = "+tipo_accion+" and sub_t_accion = "+sub_tipo_accion+" and trunc(fecha_doc) = to_date('"+fecha_doc+"', 'dd/mm/yyyy') and ced_provincia = "+prov+" and ced_sigla = '"+sigla+"' and ced_tomo = "+tomo+" and ced_asiento = "+asiento;
		accionEval = (AccionesMovilidad) sbb.getSingleRowBean(ConMgr.getConnection(),sql,AccionesMovilidad.class);
		System.out.println("sql eval\n"+sql);
	}
	if(tab.equals("4") && mode.equals("add"))
	{
		/*sql = "select to_char(nueva_secuencia,'00009') numEpleado from tbl_sec_secuencia_trx where compania = "+(String) session.getAttribute("_companyId")+" and tipo_trx = 18 ";
		eval = (AccionEnc) sbb.getSingleRowBean(ConMgr.getConnection(),sql,AccionEnc.class);
		if(eval ==null)eval = new AccionEnc();
		eval.setNumEmpleado("");*/
		
		if(fp.equalsIgnoreCase("ingreso") && (emp_id !=null && !emp_id.trim().equals("")))
		{
			sql="select distinct(b.emp_id),b.provincia cedProvincia, b.sigla cedSigla, b.tomo cedTomo, b.asiento cedAsiento, b.compania, b.primer_nombre as primerNombre,b.segundo_nombre as segundoNombre, b.primer_apellido as primerApellido,b.segundo_apellido as segundoApellido,b.apellido_casada as apellidoCasada, to_char(b.num_empleado) as numEmpleado, b.num_ssocial as numSsocial,b.salario_base as salariodest, b.sexo, b.cargo codigoestructura, b.unidad_organi unidadadm, b.gasto_rep as gastoRep, b.ubic_depto as unidadOrgani, b.ubic_seccion ubicSeccion, b.seccion, b.emp_id as empId, b.ubic_fisica as ubicFisica, b.primer_nombre||decode(b.segundo_nombre,null,' ',' '||b.segundo_nombre)||' '||b.primer_apellido||decode(b.segundo_apellido,null,' ',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_casada,null,' ',' '||b.apellido_casada)) as nombre, un.descripcion as gerenciaDesc, dep.descripcion as newPosicionDest, sec.descripcion as seccionDesc,ca.denominacion as newcargodest,b.horario ,hr.descripcion as horarioDesc,to_char(b.fecha_ingreso,'dd/mm/yyyy')as fechaIngreso from vw_pla_empleado b , tbl_sec_unidad_ejec un , tbl_sec_unidad_ejec sec, tbl_sec_unidad_ejec dep, tbl_pla_cargo ca, tbl_pla_horario_trab hr where b.emp_id="+emp_id+" and b.estado in (3) and b.compania="+(String) session.getAttribute("_companyId")+" and b.ubic_depto= un.codigo(+) and b.unidad_organi=dep.codigo(+) and b.seccion=sec.codigo(+) and b.cargo=ca.codigo(+) and b.horario=hr.codigo(+) and b.compania = un.compania(+) and b.compania = sec.compania(+) and b.compania = ca.compania(+) and b.compania = hr.compania(+)";
			System.out.println("sql:\n"+sql);
			accionEval = (AccionesMovilidad) sbb.getSingleRowBean(ConMgr.getConnection(),sql,AccionesMovilidad.class);
			fechaEfectiva = cDateTime.substring(0,10);
			accionEval.setFechaDoc(cDateTime.substring(0,10));
			eval.setFechaCreacion(cDateTime);
			eval.setUsuarioCreacion((String) session.getAttribute("_userName"));
		}

	}
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
	var ubica_ge = "";
	if (cTab=="0") ubica_ge = eval('document.form0.ubica_ge').value;
	abrir_ventana1('../rhplanilla/list_departamento.jsp?fp=movilidad&cTab='+cTab+'&dep='+ubica_ge);
}
function Gerencia(cTab)
{
	abrir_ventana1('../rhplanilla/list_direccion.jsp?fp=movilidad&cTab='+cTab);
}
function Secciones(cTab)
{
	var depto_dest = "";
	if (cTab=="0") depto_dest = eval('document.form0.depto_dest').value;
	abrir_ventana1('../rhplanilla/list_seccion.jsp?fp=movilidad&cTab='+cTab+'&dep='+depto_dest);
}

function Cargosss(cTab)
{
	abrir_ventana1('../rhplanilla/list_cargo.jsp?id=3&cTab='+cTab);
}
function addHorario()
{
	abrir_ventana1('../rhplanilla/list_horario.jsp?fp=movilidad');
}
function addAccionMov()
{
	abrir_ventana1('../rhplanilla/list_tipo_accion.jsp?fp=movilidad');
}

function Move(obj)
{
var val = obj.value;
var empid = eval('document.form0.emp_id').value;
var ger = eval('document.form0.gerencia').value;
var gerDes = eval('document.form0.gerenciaDesc').value;
var dep = eval('document.form0.depto').value;
var depDes = eval('document.form0.desc').value;
var sec = eval('document.form0.seccion').value;
var secDes = eval('document.form0.seccionDesc').value;
tipo_accion= val;

  var admDetails=getDBData('<%=request.getContextPath()%>','em.estado||\'|\'||es.descripcion','tbl_pla_empleado em, tbl_pla_estado_emp es','em.estado = es.codigo and em.emp_id = '+empid+' and em.compania = <%=(String) session.getAttribute("_companyId")%>','');
	var admDetail=admDetails.split('|');
	var estado=parseInt(admDetail[0],2);
	var descripcion=admDetail[1];

	  if (estado==3) { alert('El empleado seleccionado actualmente esta Cesante no es posible procesar una Acción de Egreso..');
	  return false;}
	 else if (estado==12) { alert('El empleado seleccionado actualmente esta Ausente no es posible procesar una Acción de Egreso..');
	 return false; }
	else alert('El empleado seleccionado actualmente esta '+descripcion+' ..');

	var otra = getDBData('<%=request.getContextPath()%>','count(*)','tbl_pla_ap_accion_per','compania=<%=(String) session.getAttribute("_companyId")%> and emp_id ='+empid+' and tipo_accion = 2 and sub_t_accion = 2 and estado in (\'T\',\'A\')','');

	if(otra != 0) {
    alert('El empleado tiene una acción de MOVILIDAD X ASCENSO pendiente por procesar... Verifique!!!');
	return false;
	}

	if(tipo_accion == 1)
	{
	eval('document.form0.ubica_ge').value=ger;
	eval('document.form0.ubica_gerenDesc').value=gerDes;
	eval('document.form0.btnGerencia').disabled=true;
	eval('document.form0.ubica_ge').readOnly=true;
	eval('document.form0.ubica_gerenDesc').readOnly=true;

	eval('document.form0.depto_dest').value=dep;
	eval('document.form0.depto_desc').value=depDes;
	eval('document.form0.btnDeptoDesp').disabled=true;
	eval('document.form0.depto_dest').readOnly=true;
	eval('document.form0.depto_desc').readOnly=true;

	eval('document.form0.seccion_dest').value=sec;
	eval('document.form0.seccion_desc').value=secDes;
	eval('document.form0.btnDeptoSeccion').disabled=true;
	eval('document.form0.seccion_dest').readOnly=true;
	eval('document.form0.seccion_desc').readOnly=true;

	}
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

function setPeriodoIni(tab)
{
	var val = eval('document.form0.sub_tipo_accion').value;
	var fecha = eval('document.form0.fechaEfectiva').value;

	//alert('el tab'+tab+' fecha ..  '+fecha+' sub tipo'+val);
		eval('document.form0.resetperiodoFin').disabled=false;
		eval('document.form0.resetperiodo_ini').disabled=false;
		eval('document.form0.periodoFin').readOnly=false;
		eval('document.form0.periodo_ini').readOnly=false;
	if(tab=="0" && val == "2")
	{
		eval('document.form0.periodo_ini').value = fecha;
	}
	 else if(tab=="0" && val == "5")
	{
		eval('document.form0.periodo_ini').value = fecha;
		eval('document.form0.periodoFin').className = 'FormDataObjectDisabled';
		eval('document.form0.periodoFin').readOnly=true;
		eval('document.form0.resetperiodoFin').disabled=true;
	}
	 else if(tab=="0" && val == "1")
	{

		eval('document.form0.periodo_ini').className = 'FormDataObjectDisabled';
		eval('document.form0.periodo_ini').readOnly=true;
		eval('document.form0.resetperiodo_ini').disabled=true;

		eval('document.form0.periodoFin').className = 'FormDataObjectDisabled';
		eval('document.form0.periodoFin').readOnly=true;
		eval('document.form0.resetperiodoFin').disabled=true;

	}
}

function validateInfo(tab)
{

	if (tab=="0")
	{
			var val=eval('document.form0.sub_tipo_accion').value;
			var cargo_dest=eval('document.form0.cargo_dest').value;
			if (val =="1"||val=="5")
			{
				if (cargo_dest=="")
				{
					alert("Por favor introduzca el Cargo");
					return false;
				} else return true;
			} else return true;
	} else return true;
}



function Empleado()
{
abrir_ventana1('../rhplanilla/empleado_ingreso_list.jsp?fp=ingreso_empleado');
}
function checkCode(obj){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_empleado','num_empleado=\''+obj.value+'\'','<%=accionEval.getNumEmpleado()%>');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" >
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - ACCIONES - EMPLEADO"></jsp:param>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("baction","")%>
<%//=fb.hidden("accion",accion)%>
<%=fb.hidden("tipo_accion",tipo_accion)%>
<%=fb.hidden("primer_nombre",eval.getPrimerNombre())%>
<%=fb.hidden("segundo_nombre",eval.getSegundoNombre())%>
<%=fb.hidden("primer_apellido",eval.getPrimerApellido())%>
<%=fb.hidden("segundo_apellido",eval.getSegundoApellido())%>
<%=fb.hidden("apellido_casada",eval.getApellidoCasada())%>
<%=fb.hidden("usuario_creacion",eval.getUsuarioCreacion())%>
<%=fb.hidden("fecha_creacion",eval.getFechaCreacion())%>
<%=fb.hidden("fecha",accionEval.getFechaDoc())%>
<%=fb.hidden("fecha_doc",fecha_doc)%>
<%=fb.hidden("unidadAdm",eval.getUbicDepto())%>
<%=fb.hidden("ubicDepto",eval.getUbicDepto())%>
<%=fb.hidden("ubicFisica",eval.getUbicDepto())%>
<%=fb.hidden("fecha_efectiva",fecha_efectiva)%>
<%=fb.hidden("fechaDoc",accionEval.getFechaDoc())%>
<%=fb.hidden("ubic_seccion",eval.getUbicSeccion())%>
<%fb.appendJsValidation("if(document.form0.cargo_dest.value==''&&(document.form0.sub_tipo_accion.value.trim()=='1'||document.form0.sub_tipo_accion.value.trim()=='5')) { alert('Por favor introduzca el Cargo!');error++; }");%>
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
							    <td width="25%">
									<%=fb.textBox("provincia",eval.getProvincia(),false,false,true,3)%>
									<%=fb.textBox("sigla",eval.getSigla(),false,false,true,3)%>
									<%=fb.textBox("tomo",eval.getTomo(),false,false,true,5)%>
									<%=fb.textBox("asiento",eval.getAsiento(),false,false,true,5)%>
                  </td>

						    </tr>
							<tr class="TextRow01">
								<td>Cargo</td>
								<td>
								<%=fb.textBox("cargo",eval.getCargo(),false,false,true,5)%>
								<%=fb.textBox("cargoDesc",eval.getCargoDesc(),false,false,true,30)%>
                </td>
								<td>No. Emp <%=fb.textBox("numEmpleado",eval.getNumEmpleado(),false,false,true,6)%></td>
								<td>No. S Social <%=fb.textBox("numSS",eval.getNumSsocial(),false,false,true,15)%></td>
							</tr>
							<tr class="TextRow01">
								<td>Gerencia</td>
								<td>
								<%=fb.textBox("gerencia",eval.getUnidadOrgani(),false,false,true,5)%>
								<%=fb.textBox("gerenciaDesc",eval.getGerenciaDesc(),false,false,true,30)%>
                </td>
								<td>Fecha Ingr. a la Empresa</td>
								<td><jsp:include page="../common/calendar.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="1" />
												<jsp:param name="clearOption" value="true" />
												<jsp:param name="nameOfTBox1" value="fechaIngreaso" />
												<jsp:param name="valueOfTBox1" value="<%=eval.getFechaIngreso()%>" />
												</jsp:include></td>
							</tr>
							<tr class="TextRow01">
								<td>Depto.</td><%//=fb.hidden("unidadAdm",eval.getUbicDepto())%>
								<td>
								<%=fb.textBox("depto",eval.getUbicDepto(),false,false,true,5)%>
								<%=fb.textBox("desc",eval.getDeptoDesc(),false,false,true,30)%>
                </td>
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
								<td width="95%">SELECCION DE ACCION - SUB TIPO DE MOVILIDAD </td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>
									</table>
					</td>
				</tr>

				<tr id="panel19">
				<td>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextRow01">
              <td width="30%">Tipos de Acciones</td>
              <td width="70%"><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion FROM tbl_pla_ap_sub_tipo where tipo_accion = 2 and codigo in (1, 2, 5) ORDER  BY 1","sub_tipo_accion",sub_tipo_accion,false,false,0,"",null,"onChange=\"javascript:Move(this)\"","","S")%></td>
             </tr>
					</table>
					</td>
				</tr>

					<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">Detalle - Sub Tipo de Movilidad </td>
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
								<td width="35%">
								<%=fb.textBox("ubica_ge",accionEval.getUbicRhgerenDest(),true,false,true,5)%>
								<%=fb.textBox("ubica_gerenDesc",accionEval.getNewGerenciaDest(),false,false,true,30)%>
								<%=fb.button("btnGerencia","...",false,false,null,null,"onClick=\"javascript:Gerencia(0)\"")%>
                </td>
								<td width="25%">Fecha Efectiva</td>
								<td width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="1" />
												<jsp:param name="clearOption" value="true" />
												<jsp:param name="nameOfTBox1" value="fechaEfectiva" />
												<jsp:param name="valueOfTBox1" value="<%=(fechaEfectiva!= null && !fechaEfectiva.trim().equals("")?fechaEfectiva:"")%>" />
                                                <jsp:param name="jsEvent" value="javascript:setPeriodoIni(0);" />
                                                <jsp:param name="onChange" value="javascript:setPeriodoIni(0);" />
												</jsp:include></td>
							</tr>
							<tr class="TextRow01">
								<td>Depto.</td><%//=fb.hidden("unidadAdm",eval.getUnidadAdm())%>
								<td>
								<%=fb.textBox("depto_dest",accionEval.getUbicRhdeptoDest(),true,false,true,5)%>
								<%=fb.textBox("depto_desc",accionEval.getNewDeptoDest(),false,false,true,30)%>
								<%=fb.button("btnDeptoDesp","...",false,false,null,null,"onClick=\"javascript:Direcciones(0)\"")%>
                </td>
								<td>Desde</td>
								<td>		<jsp:include page="../common/calendar.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="1" />
												<jsp:param name="clearOption" value="true" />
												<jsp:param name="nameOfTBox1" value="periodo_ini" />
												<jsp:param name="valueOfTBox1" value="<%=(accionEval.getPeriodoIni()==null)?"":accionEval.getPeriodoIni()%>" />
												</jsp:include></td>


							</tr>
							<tr class="TextRow01">
								<td>Seccion</td>
								<td>
									<%=fb.textBox("seccion_dest",accionEval.getUbicRhseccionDest(),true,false,true,5)%>
									<%=fb.textBox("seccion_desc",accionEval.getNewSeccionDest(),false,false,true,30)%>
									<%=fb.button("btnDeptoSeccion","...",false,false,null,null,"onClick=\"javascript:Secciones(0)\"")%>
                </td>
								<td  width="25%">Hasta</td>
								<td  width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="1" />
												<jsp:param name="clearOption" value="true" />
												<jsp:param name="nameOfTBox1" value="periodoFin" />
												<jsp:param name="valueOfTBox1" value="<%=(accionEval.getPeriodoFin()==null)?"":accionEval.getPeriodoFin()%>" />
												</jsp:include></td>
							</tr>

							<tr class="TextRow01">
								<td  width="15%">Cargo Nuevo</td>
								<td  width="35%"><%=fb.textBox("cargo_dest",accionEval.getCargoInstiDest(),false,false,true,5)%><%=fb.textBox("cargo_desc",accionEval.getNewCargoDest(),false,false,true,30)%><%=fb.button("btnCargo","...",false,false,null,null,"onClick=\"javascript:Cargosss(0)\"")%></td>
								<td>Salario Nuevo</td>
								<td><%=fb.decBox("newSalario",accionEval.getSalarioDest(),false,false,false,10,8.2)%></td>
							</tr>

							<tr class="TextRow01">
								<td>Horario Nuevo</td>
								<td><%=fb.textBox("newHorario",accionEval.getHorarioDest(),false,false,true,5)%><%=fb.textBox("newHorarioDesc",accionEval.getNewHorarioDest(),false,false,true,30)%><%=fb.button("btnHorario","...",false,false,null,null,"onClick=\"javascript:addHorario()\"")%></td>
								<td>Gasto de Rep. Nuevo</td>
								<td><%=fb.decBox("gastoRepDest",accionEval.getGastoRepDest(),false,false,false,10,8.2)%></td>
							</tr>

							<tr class="TextRow01">
								<td>Comentarios</td>
              <td colspan="4"><%=fb.textarea("comentario_rrhh",accionEval.getComentariosRrhh(),false,false,false,60,3,2000,"","width:100%","")%></td>

							</tr>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar:
						<%=fb.radio("saveOption","N")%>Crear Otro
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
            <%=fb.radio("saveOption","C")%>Cerrar
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("baction","")%>
<%//=fb.hidden("accion",accion)%>
<%=fb.hidden("tipo_accion",tipo_accion)%>
<%=fb.hidden("fecha_doc",fecha_doc)%>
<%=fb.hidden("primer_nombre",eval.getPrimerNombre())%>
<%=fb.hidden("segundo_nombre",eval.getSegundoNombre())%>
<%=fb.hidden("primer_apellido",eval.getPrimerApellido())%>
<%=fb.hidden("segundo_apellido",eval.getSegundoApellido())%>
<%=fb.hidden("apellido_casada",eval.getApellidoCasada())%>
<%=fb.hidden("usuario_creacion",eval.getUsuarioCreacion())%>
<%=fb.hidden("fecha_creacion",eval.getFechaCreacion())%>
<%=fb.hidden("fechaDoc",accionEval.getFechaDoc())%>
<%=fb.hidden("unidadAdmin",eval.getUnidadOrgani())%>
<%=fb.hidden("ubicSeccion",eval.getUbicSeccion())%>
<%=fb.hidden("sub_tipo_accion_old",accionEval.getSubTAccion())%>
<%=fb.hidden("fecha_doc_old",accionEval.getFechaDoc())%>


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
								<td><%=fb.textBox("gerencia",eval.getUbicDepto(),false,false,true,5)%><%=fb.textBox("gerenciaDesc",eval.getDeptoDesc(),false,false,true,30)%></td>
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
								<td><%=fb.textBox("depto",eval.getUnidadOrgani(),false,false,true,5)%><%=fb.textBox("deptoDesc",eval.getGerenciaDesc(),false,false,true,30)%></td>
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
              <td width="35%"><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion FROM tbl_pla_ap_sub_tipo where tipo_accion=3 ORDER  BY 1","sub_tipo_accion",sub_tipo_accion,false,false,0,"",null,"onChange=\"javascript:Acta(this)\"")%></td>
              <td width="25%">Fecha Egreso</td>
              <td width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="fieldClass" value="FormDataObjectRequired"/>
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
              <td colspan="4"><%=fb.textarea("comentario_rrhh",accionEval.getComentariosRrhh(),false,false,false,60,3,2000,"","width:100%","")%></td>
            </tr>
          </table></td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar:
						<%=fb.radio("saveOption","N")%>Crear Otro
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
            <%=fb.radio("saveOption","C")%>Cerrar
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>					</td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("baction","")%>
<%//=fb.hidden("accion",accion)%>
<%=fb.hidden("tipo_accion",tipo_accion)%>
<%=fb.hidden("usuario_creacion",accionEval.getUsuarioCreacion())%>
<%=fb.hidden("fecha_creacion",accionEval.getFechaCreacion())%>
<%=fb.hidden("fechaDoc",accionEval.getFechaDoc())%>
<%=fb.hidden("origenDatos",accionEval.getOrigenDatos())%>
<%=fb.hidden("sol_empleo_anio",accionEval.getSolEmpleoAnio())%>
<%=fb.hidden("num_empleado",eval.getNumEmpleado())%>
<%=fb.hidden("sol_empleo_no",accionEval.getSolEmpleoCodigo())%>
<%=fb.hidden("sub_tipo_accion_old",accionEval.getSubTAccion())%>

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
								       <tr class="TextRow01" >
                          <td width="20%">Primer Nombre</td>
                          <td width="20%">Segundo Nombre</td>
													<td width="20%">Primer Apellido</td>
													<td width="20%">Segundo Apellido</td>
													<td width="20%">Apellido de Casada</td>
											 </tr>
											 <tr class="TextRow01">
													<td><%=fb.textBox("primer_nombre",accionEval.getPrimerNombre(),true,false,true,20,30)%></td>
                          <td><%=fb.textBox("segundo_nombre",accionEval.getSegundoNombre(),false,false,true,20,30)%></td>
                          <td><%=fb.textBox("primer_apellido",accionEval.getPrimerApellido(),true,false,true,20,30)%></td>
                          <td><%=fb.textBox("segundo_apellido",accionEval.getSegundoApellido(),false,false,true,20,30)%></td>
													<td><%=fb.textBox("apellido_casada",accionEval.getApellidoCasada(),false,false,true,20,30)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>C&eacute;dula</td>
							    <td colspan="4">
									<%=fb.textBox("provincia",accionEval.getCedProvincia(),false,false,true,3)%>
									<%=fb.textBox("sigla",accionEval.getCedSigla(),false,false,true,3)%>
									<%=fb.textBox("tomo",accionEval.getCedTomo(),false,false,true,5)%>
									<%=fb.textBox("asiento",accionEval.getCedAsiento(),false,false,true,5)%>&nbsp;&nbsp;
                  No. S Social <%=fb.textBox("numSS",accionEval.getNumSsocial(),false,false,true,15)%>
									<%if(!mode.equals("edit")){%>
									<%=fb.button("btnEmpleado","...",false,false,null,null,"onClick=\"javascript:Empleado()\"")%>
                  <%}%>
                   	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No.Empleado
                  	<%//=fb.select(ConMgr.getConnection(),"SELECT to_char(nueva_secuencia,'00009') nueva_secuencia FROM tbl_sec_secuencia_trx where tipo_trx in (18) and compania = 1","numEmpleado","",false,false,0,"",null,"")%>
					<%=fb.intBox("numEmpleado",accionEval.getNumEmpleado(),true,false,(!mode.trim().equals("add")),20,15,null,null,"onBlur=\"javascript:checkCode(this)\"")%>
                  </td>

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
              <td width="35%">
							<%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion FROM tbl_pla_ap_sub_tipo where tipo_accion not in (2,3) ORDER  BY 1","sub_tipo_accion",sub_tipo_accion,false,false,0,"",null,"")%>
              </td>
              <td width="25%">Fecha&nbsp;&nbsp;&nbsp;&nbsp;</td>
              <td width="25%">
              <%if(mode.equals("edit")){%>
              <%=fb.textBox("fecha_doc",accionEval.getFechaDoc(),true,false,true,12)%>
              <%} else {%>
              <jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="fecha_doc" />
                <jsp:param name="valueOfTBox1" value="<%=accionEval.getFechaDoc()%>" />
              </jsp:include>
              <%}%>
              </td>
            </tr>
						<tr class="TextRow01">
						 <td>Cargo</td>
              <td>
							<%=fb.textBox("cargo_dest",accionEval.getCodigoEstructura(),true,false,true,5)%>
							<%=fb.textBox("cargo_desc",accionEval.getNewCargoDest(),false,false,true,30)%>
							<%=fb.button("btnCargo","...",false,false,null,null,"onClick=\"javascript:Cargosss(4)\"")%>
              </td>
              <td>Salario</td>
							<td><%=fb.decBox("newSalario",accionEval.getSalario(),false,false,false,10,8.2)%></td>
						</tr>
						<tr class="TextRow01">
							<td>Departamento</td>
              <td>
							<%=fb.textBox("seccion_dest",accionEval.getUnidadAdm(),true,false,true,5)%>
							<%=fb.textBox("seccion_desc",accionEval.getNewPosicionDest(),false,false,true,30)%>
							<%=fb.button("btnDeptoDesp","...",false,false,null,null,"onClick=\"javascript:Secciones(4)\"")%>
              </td>
							<td>Gasto de Rep. Nuevo</td>
							<td><%=fb.decBox("gastoRepDest",accionEval.getGastoRep(),false,false,false,10,8.2)%></td>
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
						<%=fb.radio("saveOption","N")%>Crear Otro
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
            <%=fb.radio("saveOption","C")%>Cerrar
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>					</td>
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
//{tabLabel = "'Prestamo'";}//RH9038
{tabLabel = "'Movilidad'";}
else if(tab.equals("1"))
{
tab = ""+(Integer.parseInt(tab)-1);
tabLabel = "'Ascenso'";//RH9031
}
else if(tab.equals("2"))
{
tab = ""+(Integer.parseInt(tab)-2);
tabLabel = "'Traslado'";//RH9041
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
	tipo_accion=request.getParameter("tipo_accion");
	AccionEnc acEmp = new AccionEnc();

	acEmp.setCompania((String) session.getAttribute("_companyId"));
	acEmp.setTipoAccion(request.getParameter("tipo_accion"));

	if(tab.equals("3")){
		acEmp.setSubTAccion(request.getParameter("sub_tipo_accion"));
		acEmp.setEstado("A");
	} else  if(tab.equals("0")){
		acEmp.setSubTAccion(request.getParameter("sub_tipo_accion"));
		acEmp.setEstado("A");
		acEmp.setTDocumento("");
		acEmp.setNumDocumento("");
		acEmp.setFechaDoc(request.getParameter("fechaDoc"));
	} else  if(tab.equals("4")){
		acEmp.setSubTAccion(request.getParameter("sub_tipo_accion"));
	} else {
		acEmp.setSubTAccion(request.getParameter("sub_tipo_accion"));
		acEmp.setTDocumento("");
		acEmp.setNumDocumento("");
		acEmp.setFechaDoc(request.getParameter("fechaDoc"));
		acEmp.setEstado("A");
	}

	acEmp.setUsuarioCreacion(request.getParameter("usuario_creacion"));
	acEmp.setFechaCreacion(cDateTime);
	acEmp.setUsuarioModificacion((String) session.getAttribute("_userName"));
	acEmp.setFechaModificacion(cDateTime);
	if (mode.equalsIgnoreCase("add")){
		acEmp.setMode("add");
		acEmp.setEstado("T");
	} else if (mode.equalsIgnoreCase("edit")){
		acEmp.setMode("edit");
	}
		//INTO AP_ACCION_ENC
		AccionesMovilidad EmpMovie = new AccionesMovilidad();

		EmpMovie.setCedProvincia(request.getParameter("provincia"));
		EmpMovie.setCedSigla(request.getParameter("sigla"));
		EmpMovie.setCedTomo(request.getParameter("tomo"));
		EmpMovie.setCedAsiento(request.getParameter("asiento"));
		EmpMovie.setEmpId(request.getParameter("emp_id"));

		EmpMovie.setUbicRhgeren(request.getParameter("gerencia"));
		EmpMovie.setUbicRhdepto(request.getParameter("depto"));
		EmpMovie.setUbicRhseccion(request.getParameter("seccion"));
		EmpMovie.setUbicPlaseccion(request.getParameter("ubic_seccion"));
		EmpMovie.setCargo(request.getParameter("cargo"));
		EmpMovie.setNumEmpleado(request.getParameter("numEmpleado"));
		EmpMovie.setNumSsocial(request.getParameter("numSS"));
		EmpMovie.setSalario(request.getParameter("salarioBase"));
		EmpMovie.setGastoRep(request.getParameter("gastoRep"));
		EmpMovie.setFechaIngreso(request.getParameter("fechaIngreaso"));
		EmpMovie.setPrimerNombre(request.getParameter("primer_nombre"));
		EmpMovie.setSegundoNombre(request.getParameter("segundo_nombre"));
		EmpMovie.setPrimerApellido(request.getParameter("primer_apellido"));
		EmpMovie.setSegundoApellido(request.getParameter("segundo_apellido"));
		EmpMovie.setApellidoCasada(request.getParameter("apellido_casada"));
		EmpMovie.setUsuarioCreacion(request.getParameter("usuario_creacion"));
		EmpMovie.setFechaCreacion(request.getParameter("fecha_creacion"));
		EmpMovie.setUsuarioModificacion((String) session.getAttribute("_userName"));
		EmpMovie.setCompania((String) session.getAttribute("_companyId"));
		EmpMovie.setFechaModificacion(cDateTime);
	//	EmpMovie.setUbicPlaseccion(request.getParameter("seccion"));
		EmpMovie.setCodigoEstructura(request.getParameter("cargo"));
		EmpMovie.setUnidadAdm(request.getParameter("ubicDepto"));
		EmpMovie.setEstado("T");

		if(tab.equals("0")) EmpMovie.setEstado("T");

		EmpMovie.setComentariosRrhh(request.getParameter("comentario_rrhh"));
		EmpMovie.setFechaEfectiva(request.getParameter("fechaEfectiva"));
		EmpMovie.setFechaDoc(request.getParameter("fecha_doc"));

		if (tab.equals("0")){
			if(sub_tipo_accion!=null && sub_tipo_accion.equals("5"))
			{
				EmpMovie.setUbicRhgerenDest(request.getParameter("ubica_ge"));
				EmpMovie.setUbicRhdeptoDest(request.getParameter("depto_dest"));
				EmpMovie.setUbicRhseccionDest(request.getParameter("seccion_dest"));
				EmpMovie.setHorario(request.getParameter("Horario"));
				EmpMovie.setHorarioDest(request.getParameter("newHorario"));
				EmpMovie.setUnidadAdm(request.getParameter("ubicDepto"));
			  EmpMovie.setUnidadAdmDest(request.getParameter("ubicDepto"));
			}

			if(sub_tipo_accion!=null && (sub_tipo_accion.equals("2") || sub_tipo_accion.equals("1")))
			{
				EmpMovie.setUbicRhgerenDest(request.getParameter("ubica_ge"));
				EmpMovie.setUbicRhdeptoDest(request.getParameter("depto_dest"));
				EmpMovie.setUbicRhseccionDest(request.getParameter("seccion_dest"));
			}

			EmpMovie.setPeriodoIni(request.getParameter("periodo_ini"));
			EmpMovie.setPeriodoFin(request.getParameter("periodoFin"));

		//	EmpMovie.setFechaEfectiva(request.getParameter("fecha_inicio"));
			EmpMovie.setFechaEfectiva(request.getParameter("fechaEfectiva"));
			EmpMovie.setHorario(request.getParameter("Horario"));
			EmpMovie.setHorarioDest(request.getParameter("newHorario"));
			EmpMovie.setSalarioDest(request.getParameter("newSalario"));
			EmpMovie.setGastoRepDest(request.getParameter("gastoRepDest"));
			EmpMovie.setCargoInstiDest(request.getParameter("cargo_dest"));
			AccMgr.add(acEmp,EmpMovie);

		}	else if (tab.equals("0") && sub_tipo_accion.equals("1")){
			EmpMovie.setHorario(request.getParameter("Horario"));
			EmpMovie.setHorarioDest(request.getParameter("newHorario"));
			EmpMovie.setSalarioDest(request.getParameter("newSalario"));
			EmpMovie.setGastoRepDest(request.getParameter("gastoRepDest"));
			EmpMovie.setCargoInstiDest(request.getParameter("cargo_dest"));
			EmpMovie.setUbicRhdeptoDest(request.getParameter("depto_dest"));
			EmpMovie.setUbicRhseccionDest(request.getParameter("seccion_dest"));
			AccMgr.add(acEmp,EmpMovie);

		} else if (tab.equals("0") && sub_tipo_accion.equals("5")){
			EmpMovie.setUbicRhgerenDest(request.getParameter("ubica_ge"));
		  EmpMovie.setUbicRhdeptoDest(request.getParameter("depto_dest"));
			EmpMovie.setUbicRhseccionDest(request.getParameter("seccion_dest"));
		  EmpMovie.setCargoInstiDest(request.getParameter("cargo_dest"));
			EmpMovie.setPeriodoIni(request.getParameter("periodo_ini"));
			EmpMovie.setSalarioDest(request.getParameter("newSalario"));
		  EmpMovie.setGastoRepDest(request.getParameter("gastoRepDest"));
		  EmpMovie.setUnidadAdm(request.getParameter("ubicFisica"));
		   EmpMovie.setUnidadAdmDest(request.getParameter("ubicFisica"));

			AccMgr.add(acEmp,EmpMovie);

		} else if(tab.equals("3")){
			EmpMovie.setFechaEfectiva(request.getParameter("fecha_efectiva"));
			EmpMovie.setSubTAccion(request.getParameter("sub_tipo_accion"));
			EmpMovie.setCausalHecho(request.getParameter("causal_hecho"));
			EmpMovie.setComentariosRrhh(request.getParameter("comentario_rrhh"));
			EmpMovie.setNumActaDefun(request.getParameter("num_acta"));
			EmpMovie.setFecActaDefun(request.getParameter("fec_acta_defun"));
			EmpMovie.setUnidadAdm(request.getParameter("unidadAdmin"));
			EmpMovie.setFechaDoc(CmnMgr.getCurrentDate("dd/mm/yyyy"));
			EmpMovie.setUbicRhgeren(request.getParameter("gerencia"));

			EmpMovie.setUbicRhdepto(request.getParameter("depto"));
			EmpMovie.setUbicRhseccion(request.getParameter("seccion"));
			EmpMovie.setUbicRhdeptoDest(request.getParameter("depto_dest"));
			EmpMovie.setUbicRhseccionDest(request.getParameter("seccion_dest"));
			EmpMovie.setUbicPlaseccion(request.getParameter("ubicSeccion"));
			EmpMovie.setEstado("T");
			if(mode.equals("add")){
					acEmp.setFechaDoc(CmnMgr.getCurrentDate("dd/mm/yyyy"));
					AccMgr.add(acEmp,EmpMovie);
			}  else if(mode.equals("edit")){
						EmpMovie.setFechaDoc(request.getParameter("fecha_doc_old"));
						EmpMovie.setNewFechaDoc(request.getParameter("fechaDoc"));
						EmpMovie.setTipoAccion(tipo_accion);
						EmpMovie.setSubTAccion(request.getParameter("sub_tipo_accion_old"));
						EmpMovie.setNewSubTAccion(request.getParameter("sub_tipo_accion"));
						AccMgr.update(EmpMovie);
			}
			//AccMgr.add(acEmp,EmpMovie);
		} else if(tab.equals("4")){
			EmpMovie.setFechaEfectiva(request.getParameter("fecha_inicio"));
			EmpMovie.setPeriodoIni(request.getParameter("periodo_ini_ingreso"));
			EmpMovie.setPeriodoFin(request.getParameter("periodo_fin_ingreso"));
			EmpMovie.setSalario(request.getParameter("newSalario"));
			EmpMovie.setGastoRep(request.getParameter("gastoRepDest"));
			EmpMovie.setResultadoPpru(request.getParameter("resultado_ppru"));
			EmpMovie.setCodigoEstructura(request.getParameter("cargo_dest"));
			EmpMovie.setUnidadAdm(request.getParameter("seccion_dest"));
			EmpMovie.setSubTAccion(request.getParameter("sub_tipo_accion"));
			EmpMovie.setTipoAccion(tipo_accion);
			EmpMovie.setEstado("T");
			EmpMovie.setOrigenDatos(request.getParameter("origenDatos"));
			EmpMovie.setSolEmpleoAnio(request.getParameter("sol_empleo_anio"));
			EmpMovie.setSolEmpleoCodigo(request.getParameter("sol_empleo_no"));
				EmpMovie.setNumEmpleado(request.getParameter("numEmpleado"));
				EmpMovie.setNumSsocial(request.getParameter("numSS"));
			if(mode.equals("add"))
			{
			AccMgr.add(acEmp,EmpMovie);}
			else if(mode.equals("edit")){
				EmpMovie.setFechaDoc(request.getParameter("fecha_doc"));
				EmpMovie.setSubTAccion(request.getParameter("sub_tipo_accion_old"));
				EmpMovie.setNewSubTAccion(request.getParameter("sub_tipo_accion"));
				ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"tab="+tab);
				AccMgr.update(EmpMovie);
				ConMgr.clearAppCtx(null);
			}
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

	if(tab.equals("0")&&(!fg.equals("ap")))
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
<%	}
	} else if (tab.equals("0")&&(fg.equals("ap")))
	{
			if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_accionmove.jsp"))
		{
%>
			window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_accionmove_aprob.jsp")%>';
<%
		}
	} else if(tab.equals("4") && fg.equals("ap"))
	{
			if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_accionmove_aprob.jsp"))
		{
%>
			window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_accionmove_aprob.jsp")%>';
<%
		}
	} else if(tab.equals("4") && fg!=null && fg.equals("TI")){
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/tramite_ingreso.jsp';
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
} else throw new Exception(AccMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
<%
if(tab.equals("3"))
{
%>
 window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&fg=ap&mode=edit&tab=<%=tab%>&tipo_accion=<%=tipo_accion%>&emp_id=<%=emp_id%>&sub_tipo_accion=<%=request.getParameter("sub_tipo_accion")%>&fecha_doc=<%=fecha_doc%>&fecha_efectiva=<%=fecha_efectiva%>&fecha=<%=fecha%>&prov=<%=request.getParameter("provincia")%>&sigla=<%=request.getParameter("sigla")%>&tomo=<%=request.getParameter("tomo")%>&asiento=<%=request.getParameter("asiento")%>';
<%
} else if(tab.equals("0"))
{
%>
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&fg=ap&mode=edit&tab=<%=tab%>&tipo_accion=<%=tipo_accion%>&emp_id=<%=emp_id%>&sub_tipo_accion=<%=request.getParameter("sub_tipo_accion")%>&fecha_doc=<%=fecha_doc%>&fecha_efectiva=<%=fecha_efectiva%>&prov=<%=request.getParameter("provincia")%>&sigla=<%=request.getParameter("sigla")%>&tomo=<%=request.getParameter("tomo")%>&asiento=<%=request.getParameter("asiento")%>';
  <%
  } else
{
%>
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&fg=ap&mode=edit&tab=<%=tab%>&tipo_accion=<%=tipo_accion%>&emp_id=<%=emp_id%>&sub_tipo_accion=<%=request.getParameter("sub_tipo_accion")%>&fecha_doc=<%=fecha_doc%>&fecha_efectiva=<%=fecha_efectiva%>&fecha=<%=fecha%>&emp_id=<%=request.getParameter("emp_id")%>&prov=<%=request.getParameter("provincia")%>&sigla=<%=request.getParameter("sigla")%>&tomo=<%=request.getParameter("tomo")%>&asiento=<%=request.getParameter("asiento")%>';
  <%
  }
  %>

}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>