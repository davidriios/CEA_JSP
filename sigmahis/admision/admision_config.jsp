<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr"/>
<jsp:useBean id="iCama" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCama" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iDiag" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDiag" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iBen" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vBen" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iResp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vResp" scope="session" class="java.util.Vector"/>
<jsp:useBean id="vCamaNew" scope="session" class="java.util.Vector"/>

<%
/**
==================================================================================
ADM3309
ADM3310_CON_SUP
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

int iconHeight = 24;
int iconWidth = 24;
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Admision adm = new Admision();
Admision resp = new Admision();
String key = "";
StringBuffer sbSql;
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String change = request.getParameter("change");
String fecha="",fechaIngreso="";
int camaLastLineNo = 0;
int diagLastLineNo = 0;
int docLastLineNo = 0;
int benLastLineNo = 0;
int respLastLineNo = 0;
int prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String estadoOptions = "A=ACTIVA,P=PRE-ADMISION,E=EN ESPERA";//,S=ESPECIAL se quita estado, soliciado el Mon, Aug 20, 2012 9:28 am por catherine.
String contCredOptions = "C=CONTADO, R=CREDITO";
String fp = request.getParameter("fp");
if (fg == null) fg = "";
if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view") || fg.equalsIgnoreCase("con_sup")) { viewMode = true; estadoOptions = "A=ACTIVA,P=PRE-ADMISION,S=ESPECIAL,E=EN ESPERA,I=INACTIVA,C=CANCELADA,N=ANULADA"; contCredOptions = "C=CONTADO, R=CREDITO"; }
if (fp == null) fp = "adm";


if (request.getParameter("camaLastLineNo") != null) camaLastLineNo = Integer.parseInt(request.getParameter("camaLastLineNo"));
if (request.getParameter("diagLastLineNo") != null) diagLastLineNo = Integer.parseInt(request.getParameter("diagLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));
if (request.getParameter("benLastLineNo") != null) benLastLineNo = Integer.parseInt(request.getParameter("benLastLineNo"));
if (request.getParameter("respLastLineNo") != null) respLastLineNo = Integer.parseInt(request.getParameter("respLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		iCama.clear();
		vCama.clear();
		iDiag.clear();
		vDiag.clear();
		iDoc.clear();
		vDoc.clear();
		iBen.clear();
		vBen.clear();
		iResp.clear();
		vResp.clear();
		vCamaNew.clear();
		if (pacId == null || pacId.trim().equals("")) pacId = "0";
		else
		{
			sbSql = new StringBuffer();
			sbSql.append("select to_char(fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, codigo as codigoPaciente, decode(provincia,null,' ',provincia) as provincia, nvl(sigla,' ') as sigla, decode(tomo,null,' ',tomo) as tomo, decode(asiento,null,' ',asiento) as asiento, nvl(d_cedula,' ') as dCedula, nvl(pasaporte,' ') as pasaporte, nombre_paciente as nombrePaciente, vip as key from vw_adm_paciente where pac_id = ");
			sbSql.append(pacId);
			Admision pac = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Admision.class);

			adm.setFechaNacimiento(pac.getFechaNacimiento());
			adm.setCodigoPaciente(pac.getCodigoPaciente());
			adm.setProvincia(pac.getProvincia());
			adm.setSigla(pac.getSigla());
			adm.setTomo(pac.getTomo());
			adm.setAsiento(pac.getAsiento());
			adm.setDCedula(pac.getDCedula());
			adm.setPasaporte(pac.getPasaporte());
			adm.setNombrePaciente(pac.getNombrePaciente());
			adm.setKey(pac.getKey());
		}
		noAdmision = "0";
		adm.setPacId(pacId);
		adm.setNoAdmision(noAdmision);
		adm.setFechaIngreso(cDateTime.substring(0,10));
		adm.setAmPm(cDateTime.substring(11));
		adm.setFechaPreadmision("");
		adm.setEstado("A");
		adm.setTipoCta("P");

		int nRec = 0;
		StringBuffer sbFilter = new StringBuffer();
		if (!UserDet.getUserProfile().contains("0")) { sbFilter.append(" and d.codigo in (select cod_cds from tbl_cds_usuario_x_cds where usuario='"); sbFilter.append(session.getAttribute("_userName")); sbFilter.append("' and crea_admision='S')"); }
		nRec = CmnMgr.getCount("select count(*) from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_x_cds c, tbl_cds_centro_servicio d where a.categoria=b.codigo and a.categoria=c.cod_categoria and a.codigo=c.cod_tipo and c.cod_centro=d.codigo and d.estado='A' and a.compania="+((String) session.getAttribute("_companyId"))+sbFilter.toString()+"");
		if (nRec == 1)
		{
			CommonDataObject cdo = SQLMgr.getData("select a.categoria, a.codigo as tipoAdmision, a.descripcion as tipoAdmisionDesc, b.descripcion as categoriaDesc, d.codigo as centroServicio, d.descripcion as centroServicioDesc from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_x_cds c, tbl_cds_centro_servicio d where a.categoria=b.codigo and a.categoria=c.cod_categoria and a.codigo=c.cod_tipo and c.cod_centro=d.codigo and d.estado='A' and a.compania="+((String) session.getAttribute("_companyId"))+sbFilter.toString()+" order by d.descripcion, b.descripcion, a.descripcion");
			adm.setCategoria(cdo.getColValue("categoria"));
			adm.setCategoriaDesc(cdo.getColValue("categoriaDesc"));
			adm.setTipoAdmision(cdo.getColValue("tipoAdmision"));
			adm.setTipoAdmisionDesc(cdo.getColValue("tipoAdmisionDesc"));
			adm.setCentroServicio(cdo.getColValue("centroServicio"));
			adm.setCentroServicioDesc(cdo.getColValue("centroServicioDesc"));
		}
	}
	else
	{
		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fechaIngreso, decode(a.dias_estimados,null,' ',a.dias_estimados) as diasEstimados, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, nvl(to_char(a.am_pm2,'hh12:mi am'),' ') as amPm2, a.dias_hospitalizados as diasHospitalizados, nvl(a.no_cuenta,'') as noCuenta, to_char(nvl(a.fecha_preadmision,sysdate),'dd/mm/yyyy hh12:mi am') as fechaPreadmision, a.categoria, a.tipo_admision as tipoAdmision, a.medico, a.usuario_creacion as usuarioCreacion, a.condicion_paciente as condicionPaciente, observ_adm as observAdm ,to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, to_char(nvl(a.am_pm,sysdate),'hh12:mi am') as amPm, nvl(a.tipo_cta,' ') as tipoCta, a.conta_cred as contaCred, coalesce(a.provincia,(select provincia from tbl_adm_paciente where pac_id=a.pac_id)) as provincia, coalesce(a.sigla,(select sigla from tbl_adm_paciente where pac_id=a.pac_id)) as sigla, coalesce(a.tomo,(select tomo from tbl_adm_paciente where pac_id=a.pac_id)) as tomo, coalesce(a.asiento,(select asiento from tbl_adm_paciente where pac_id=a.pac_id)) as asiento, coalesce(a.d_cedula,(select d_cedula from tbl_adm_paciente where pac_id=a.pac_id)) as dCedula, (select pasaporte from tbl_adm_paciente where pac_id=a.pac_id) as pasaporte, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.pac_id as pacId, a.responsabilidad, (select nombre_paciente from vw_adm_paciente where pac_id=a.pac_id) as nombrePaciente, (select descripcion from tbl_adm_categoria_admision where codigo=a.categoria) as categoriaDesc, (select descripcion from tbl_adm_tipo_admision_cia where categoria=a.categoria and codigo=a.tipo_admision and compania=a.compania) as tipoAdmisionDesc, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico) as nombreMedico, (select nvl(z.descripcion,'NO TIENE') from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=a.medico and x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) as especialidad, coalesce((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico_cabecera),' ') as nombreMedicoCabecera, (select descripcion from tbl_cds_centro_servicio where codigo=a.centro_servicio) as centroServicioDesc,a.mes_cta_bolsa mesCtaBolsa, a.oc as oc from tbl_adm_admision a where a.pac_id=");
		sbSql.append(pacId);
		sbSql.append(" and a.secuencia=");
		sbSql.append(noAdmision);
		sbSql.append(" and a.compania=");
		sbSql.append(session.getAttribute("_companyId"));
		adm = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Admision.class);
		fecha = ""+adm.getFechaNacimiento().substring(0,2)+"-"+adm.getFechaNacimiento().substring(3,5)+"-"+adm.getFechaNacimiento().substring(6,10)+"";
		fechaIngreso = ""+adm.getFechaIngreso().substring(0,2)+"-"+adm.getFechaIngreso().substring(3,5)+"-"+adm.getFechaIngreso().substring(6,10)+"";

		if (change == null)
		{
			iCama.clear();
			vCama.clear();
			iDiag.clear();
			vDiag.clear();
			iDoc.clear();
			vDoc.clear();
			iBen.clear();
			vBen.clear();
			iResp.clear();
			vResp.clear();
			vCamaNew.clear();

			sbSql = new StringBuffer();
			sbSql.append("select a.codigo, a.cama, a.habitacion, to_char(a.fecha_inicio,'dd/mm/yyyy') as fechaInicio, to_char(a.hora_inicio,'hh12:mi am') as horaInicio, nvl(a.precio_alt,'N') as precioAlt, a.precio_alterno as precioAlterno, a.motivo_precio_alt as motivoPrecioAlt, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, (select unidad_admin from tbl_sal_habitacion where compania=a.compania and codigo=a.habitacion) as centroServicio, (select y.descripcion from tbl_sal_habitacion z, tbl_cds_centro_servicio y where z.compania=a.compania and z.codigo=a.habitacion and z.unidad_admin=y.codigo) as centroServicioDesc, (select y.precio from tbl_sal_cama z, tbl_sal_tipo_habitacion y where z.compania=a.compania and z.habitacion=a.habitacion and z.codigo=a.cama and y.compania=a.compania and z.tipo_hab=y.codigo) as precio, (select y.descripcion||' - '||decode(y.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','O','OTROS','E','ECONOMICA','T','SUITE','Q','QUIROFANO','C','COMPARTIDA') from tbl_sal_cama z, tbl_sal_tipo_habitacion y where z.compania=a.compania and z.habitacion=a.habitacion and z.codigo=a.cama and y.compania=a.compania and z.tipo_hab=y.codigo) as habitacionDesc,case when to_date(to_char(a.fecha_inicio,'dd/mm/yyyy')||' '||to_char(a.hora_inicio,'hh12:mi am'),'dd/mm/yyyy hh12:mi am') + 3/24 > sysdate and a.fecha_final is null and '");
			sbSql.append(adm.getEstado());
			sbSql.append("'='A' then 1 else 0 end casoEspecial ,nvl(to_char(a.fecha_final,'dd/mm/yyyy'),' ') as fechaFinal, nvl(to_char(to_date(a.hora_final,'hh12:mi am'),'hh12:mi am'),' ') as horaFinal,(select count(*) from tbl_adm_cama_admision where pac_id = a.pac_id and admision= a.admision and fecha_final is null and hora_final is null )cantidadCa from tbl_adm_cama_admision a where a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
			sbSql.append("/* and a.fecha_final is null*/ order by 1");
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);
System.out.println("SQL CAMA =============================================================================================================="+sbSql.toString());
			camaLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				Admision obj = (Admision) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				obj.setKey(key);

				try
				{
					iCama.put(key, obj);
					if(obj.getFechaFinal() == null || obj.getFechaFinal().trim().equals(""))
					{
						vCamaNew.addElement(obj.getHabitacion()+"-"+obj.getCama());
					}
					//vCama.addElement(obj.getHabitacion()+"-"+obj.getCama());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sbSql = new StringBuffer();
			sbSql.append("select a.diagnostico, a.tipo, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.orden_diag as ordenDiag, (select coalesce(observacion,nombre) from tbl_cds_diagnostico where codigo=a.diagnostico) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a where a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
			sbSql.append(" order by 7");
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);

			diagLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				Admision obj = (Admision) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				obj.setKey(key);

				try
				{
					iDiag.put(key, obj);
					vDiag.addElement(obj.getDiagnostico());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sbSql = new StringBuffer();
			sbSql.append("select a.documento, a.revisado_admision as revisadoAdmision, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, (select nombre from tbl_adm_documento where codigo=a.documento) as documentoDesc, a.revisado_sala as revisadoSala, a.revisado_fac as revisadoFac, a.revisado_cob as revisadoCob, a.observacion, a.estatus as estado, a.user_entrega as userEntrega, a.user_recibe as userRecibe, to_char(a.fecha_entrega,'dd/mm/yyyy') as fechaEntrega, to_char(a.fecha_recibe,'dd/mm/yyyy') as fechaRecibe, a.area_entrega as areaEntrega, a.area_recibe as areaRecibe, a.pase, a.pase_k as paseK from tbl_adm_documentos_admision a where a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
			sbSql.append(" order by 1");
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);

			docLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				Admision obj = (Admision) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				obj.setKey(key);

				try
				{
					iDoc.put(key, obj);
					vDoc.addElement(obj.getDiagnostico());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sbSql = new StringBuffer();
			sbSql.append("select a.secuencia, a.poliza, nvl(a.certificado,' ') as certificado, nvl(a.convenio_solicitud,'C') as convenioSolicitud, nvl(a.convenio_sol_emp,'N') as convenioSolEmp, a.prioridad, decode(a.plan,null,' ',a.plan) as plan, decode(a.convenio,null,' ',a.convenio) as convenio, a.empresa, decode(a.categoria_admi,null,' ',a.categoria_admi) as categoriaAdmi, decode(a.tipo_admi,null,' ',a.tipo_admi) as tipoAdmi, decode(a.clasif_admi,null,' ',a.clasif_admi) as clasifAdmi, decode(a.tipo_poliza,null,' ',a.tipo_poliza) as tipoPoliza, decode(a.tipo_plan,null,' ',a.tipo_plan) as tipoPlan, to_char(nvl(a.fecha_ini,sysdate),'dd/mm/yyyy') as fechaIni, decode(a.categoria_admi,2,to_char(nvl(a.fecha_fin,sysdate),'dd/mm/yyyy'),' ') as fechaFin, nvl(a.usuario_creacion,' ') as usuarioCreacion, nvl(a.usuario_modificacion,' ') as usuarioModificacion, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaCreacion, nvl(to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaModificacion, nvl(a.estado,' ') as estado, decode(a.num_aprobacion,null,' ',a.num_aprobacion) as numAprobacion, (select tipo_poliza from tbl_adm_plan_convenio where empresa=a.empresa and convenio=a.convenio and secuencia=a.plan) as tipoPoliza, (select tipo_plan from tbl_adm_plan_convenio where empresa=a.empresa and convenio=a.convenio and secuencia=a.plan) as tipoPlan, (select nombre from tbl_adm_plan_convenio where empresa=a.empresa and convenio=a.convenio and secuencia=a.plan) as nombrePlan, (select y.nombre from tbl_adm_plan_convenio z, tbl_adm_convenio y where z.empresa=a.empresa and z.convenio=a.convenio and z.secuencia=a.plan and z.empresa=y.empresa and z.convenio=y.secuencia) as nombreConvenio, (select x.nombre from tbl_adm_plan_convenio z, tbl_adm_convenio y, tbl_adm_empresa x where z.empresa=a.empresa and z.convenio=a.convenio and z.secuencia=a.plan and z.empresa=y.empresa and z.convenio=y.secuencia and y.empresa=x.codigo) as nombreEmpresa, (select y.nombre from tbl_adm_plan_convenio z, tbl_adm_tipo_plan y where z.empresa=a.empresa and z.convenio=a.convenio and z.secuencia=a.plan and z.tipo_plan=y.tipo_plan and z.tipo_poliza=y.poliza) as nombreTipoPlan, (select y.nombre from tbl_adm_plan_convenio z, tbl_adm_tipo_poliza y where z.empresa=a.empresa and z.convenio=a.convenio and z.secuencia=a.plan and z.tipo_poliza=y.codigo) as nombreTipoPoliza, (select descripcion from tbl_adm_clasif_x_tipo_adm where categoria=a.categoria_admi and tipo=a.tipo_admi and codigo=a.clasif_admi) as clasifAdmiDesc, (select y.descripcion from tbl_adm_clasif_x_tipo_adm z, tbl_adm_tipo_admision_cia y where z.categoria=a.categoria_admi and z.tipo=a.tipo_admi and z.codigo=a.clasif_admi and z.categoria=y.categoria and z.tipo=y.codigo) as tipoAdmiDesc, (select x.descripcion from tbl_adm_clasif_x_tipo_adm z, tbl_adm_tipo_admision_cia y, tbl_adm_categoria_admision x where z.categoria=a.categoria_admi and z.tipo=a.tipo_admi and z.codigo=a.clasif_admi and z.categoria=y.categoria and z.tipo=y.codigo and y.categoria=x.codigo) as categoriaAdmiDesc, nvl(a.pac_asume_cargos,'N') as pacAsumeCargos, nvl(a.clinica_asume_cargos,'N') as clinicaAsumeCargos from tbl_adm_beneficios_x_admision a where nvl(a.estado,'A')='A' and a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
			sbSql.append(" order by 1, 6, 9, 8, 7, 10, 11, 12");
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);

			benLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				Admision obj = (Admision) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				obj.setKey(key);

				try
				{
					iBen.put(key, obj);
					vBen.addElement(obj.getEmpresa()+"-"+obj.getConvenio()+"-"+obj.getPlan()+"-"+obj.getCategoriaAdmi()+"-"+obj.getTipoAdmi()+"-"+obj.getClasifAdmi());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}


			sbSql = new StringBuffer();
			sbSql.append("select a.identificacion, a.tipo_identificacion as tipoIdentificacion, a.nombre, nvl(a.sexo,' ') as sexo, decode(a.nacionalidad,null,' ',a.nacionalidad) as nacionalidad, nvl(a.direccion,' ') as direccion, decode(a.comunidad, null, ' ', a.comunidad) as comunidad, decode(a.corregimiento, null, ' ', a.corregimiento) as corregimiento, decode(a.distrito, null, ' ', a.distrito) as distrito, decode(a.provincia, null, ' ', a.provincia) as provincia, decode(a.pais, null, ' ', a.pais) as pais, nvl(a.telefono_residencia,' ') as telefonoResidencia, nvl(a.apartado_postal,' ') as apartadoPostal, nvl(a.zona_postal,' ') as zonaPostal, decode(a.ingreso_mensual,null,' ',a.ingreso_mensual) as ingresoMensual, decode(a.anios_laborados,null,' ',a.anios_laborados) as aniosLaborados, decode(a.meses_laborados,null,' ',a.meses_laborados) as mesesLaborados, decode(a.otros_ingresos,null,' ',a.otros_ingresos) as otrosIngresos, nvl(a.fuente_otros_ingresos,' ') as fuenteOtrosIngresos, nvl(a.lugar_de_trabajo,' ') as lugarDeTrabajo, nvl(a.puesto_que_ocupa,' ') as puestoQueOcupa, nvl(a.direccion_trabajo,' ') as direccionTrabajo, nvl(a.telefono_de_trabajo,' ') as telefonoDeTrabajo, nvl(a.extension,' ') as extension, nvl(a.parentesco,' ') as parentesco, nvl(a.fax,' ') as fax, nvl(a.e_mail,' ') as eMail, nvl(a.observacion,' ') as observacion, nvl(a.lugar_nac,' ') as lugarNac, a.principal, nvl(a.seguro_social,' ') as seguroSocial, decode(a.cod_empresa,null,' ',a.cod_empresa) as empresa, nvl(a.od_medico,' ') as medico, nvl(a.num_empleado,' ') as numEmpleado, a.compania, a.usuario_creacion as usuarioCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(a.fecha_modifica,'dd/mm/yyyy') as fechaModifica, a.pac_id as pacId, nvl((select nacionalidad from tbl_sec_pais where codigo=a.nacionalidad),' ') as nacionalidadDesc, nvl((select decode(nombre_comunidad,'NA',null,nombre_comunidad) from vw_sec_regional_location where codigo_pais=a.pais and codigo_provincia=a.provincia and codigo_distrito=a.distrito and codigo_corregimiento=a.corregimiento and codigo_comunidad=a.comunidad),' ') as nombreComunidad, nvl((select decode(nombre_corregimiento,'NA',null,nombre_corregimiento) from vw_sec_regional_location where codigo_pais=a.pais and codigo_provincia=a.provincia and codigo_distrito=a.distrito and codigo_corregimiento=a.corregimiento and codigo_comunidad=a.comunidad), ' ') as nombreCorregimiento, nvl((select decode(nombre_distrito,'NA',null,nombre_distrito) from vw_sec_regional_location where codigo_pais=a.pais and codigo_provincia=a.provincia and codigo_distrito=a.distrito and codigo_corregimiento=a.corregimiento and codigo_comunidad=a.comunidad), ' ') as nombreDistrito, nvl((select decode(nombre_provincia,'NA',null,nombre_provincia) from vw_sec_regional_location where codigo_pais=a.pais and codigo_provincia=a.provincia and codigo_distrito=a.distrito and codigo_corregimiento=a.corregimiento and codigo_comunidad=a.comunidad), ' ') as nombreProvincia, nvl((select decode(nombre_pais,'NA',null,nombre_pais) from vw_sec_regional_location where codigo_pais=a.pais and codigo_provincia=a.provincia and codigo_distrito=a.distrito and codigo_corregimiento=a.corregimiento and codigo_comunidad=a.comunidad), ' ') as nombrePais, nvl((select nombre from tbl_adm_empresa where codigo=a.cod_empresa),' ') as empresaDesc, nvl((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.od_medico),' ') as nombreMedico, nvl((select primer_nombre||' '||primer_apellido from tbl_pla_empleado where compania=a.compania and num_empleado=a.num_empleado),' ') as nombreEmpleado from tbl_adm_responsable a where a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
			sbSql.append(" order by 30 desc");
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);

			if (al.size() == 0)
			{
				Admision obj = new Admision();

				respLastLineNo++;
				if (respLastLineNo < 10) key = "00"+respLastLineNo;
				else if (respLastLineNo < 100) key = "0"+respLastLineNo;
				else key = ""+respLastLineNo;
				obj.setKey(key);

				try
				{
					iResp.put(key, obj);
					vResp.addElement(obj.getKey());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else
			{
				respLastLineNo = al.size();
				for (int i=1; i<=al.size(); i++)
				{
					Admision obj = (Admision) al.get(i-1);

					if (i < 10) key = "00" + i;
					else if (i < 100) key = "0" + i;
					else key = "" + i;
					obj.setKey(key);

					try
					{
						iResp.put(key, obj);
						vResp.addElement(obj.getKey());
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}
			}
		}
	}

	ArrayList alDoc = SQLMgr.getDataList("select a.id, a.description, decode(a.display_area,'P','PACIENTE','X','EXPEDIENTE','A','ADMISION','H','RECURSOS HUMANOS','C','CONTABILIDAD','O','GERENCIA DE OPERACIONES','G','GERENCIA GENERAL',a.display_area) as display_area, decode((select doc_type from tbl_adm_admision_doc where pac_id="+pacId+" and admision="+noAdmision+" and doc_type=a.id),null,'N','Y') as checked from tbl_sec_doc_type a where a.status='A' and a.display_area in ('A','X') order by 3, 2");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Admisión - '+document.title;

function showBeneficioSol(i)
{
	var empresa=eval('document.form4.empresa'+i).value;
	if(eval('document.form4.secuencia'+i).value==''||eval('document.form4.secuencia'+i).value=='0')alert('Guarde los cambios antes de realizar la solicitud de Beneficio!');
	else
	{
		if(eval('document.form4.prioridad'+i).value=='1')
		{
			if(hasDBData('<%=request.getContextPath()%>','tbl_adm_solicitud_beneficio','empresa='+empresa+' and estatus=\'A\' and admision=<%=noAdmision%> and pac_id=<%=pacId%>',''))
			{
				if(confirm("Ya existe una Solicitud de Beneficios para esta Compañía de Seguros. Se consultará la Solicitud para que realice los cambios que desee."))abrir_ventana1('../admision/solicitud_beneficio.jsp?pac_id=<%=pacId%>&admision=<%=noAdmision%>');
			}
			else
			{
				var fecha='<%=fecha%>';
				var fIngreso='<%=fechaIngreso%>';
				var codPac=parseInt(eval('document.form4.codigoPaciente').value);
				if(eval('document.form4.poliza'+i).value==''&&eval('document.form4.status'+i).value!='D'&&eval('document.form4.estado'+i).value!='I')				alert('Introduca su póliza');
				else
				{
					var poliza=eval('document.form4.poliza'+i).value;
					var certificado=eval('document.form4.certificado'+i).value;
					var plan=eval('document.form4.plan'+i).value;
					var clasif_admi=eval('document.form4.clasifAdmi'+i).value;
					var tipo_admi=eval('document.form4.tipoAdmi'+i).value;
					var categoria_admi=eval('document.form4.categoriaAdmi'+i).value;
					var convenio=eval('document.form4.convenio'+i).value;
					var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','c.sol_benef_pac, c.sol_benef_emp', 'tbl_adm_beneficios_x_admision a, tbl_adm_categoria_admision b, tbl_adm_clasif_x_plan_conv c, tbl_adm_tipo_admision_cia d, tbl_adm_clasif_x_tipo_adm e where a.plan=c.plan and a.convenio=c.convenio and a.empresa=c.empresa and a.clasif_admi=c.clasif_admi and a.tipo_admi=c.tipo_admi and a.categoria_admi=c.categoria_admi and d.categoria=b.codigo and c.clasif_admi=e.codigo and c.tipo_admi=e.tipo and c.categoria_admi=e.categoria and e.tipo=d.codigo and e.categoria=d.categoria and c.plan='+plan+' and c.clasif_admi='+clasif_admi+' and c.tipo_admi='+tipo_admi+' and c.empresa='+empresa+' and c.categoria_admi='+categoria_admi+' and c.convenio='+convenio+' and a.pac_id=<%=pacId%> and a.admision=<%=noAdmision%> and a.estado=\'A\' and a.prioridad=1',''));
					for(i=0;i<r.length;i++)
					{
						var c=r[i];
						if(c[0]=='S'&&c[1]=='S')alert('De acuerdo al plan, se requiere generar la Solicitud de Beneficios para calcular el copago del paciente y el pago de la aseguradora, presione el botón SOLICITUD.');
						else if(c[0]=='S'&&c[1]=='N')alert('De acuerdo al plan, se requiere generar la Solicitud de Beneficios para que pueda calcular el copago del paciente, presione el botón SOLICITUD.');
						else if(c[0]=='N'&&c[1]=='S')alert('De acuerdo al plan, se requiere generar la Solicitud de Beneficios para que pueda calcular el monto que asume la Aseguradora, presione el botón SOLICITUD.');
						break;
					}
					if(executeDB('<%=request.getContextPath()%>','call adm_crea_solicitud_beneficio(\''+fecha+'\','+codPac+',<%=noAdmision%>,'+empresa+',\''+fIngreso+'\',\''+poliza+'\',\''+certificado+'\',<%=pacId%>)','tbl_adm_solicitud_beneficio,tbl_adm_detalle_solicitud'))
					{
						alert('La solicitud se ha generado Satisfactoriamente');
						abrir_ventana1('../admision/solicitud_beneficio.jsp?pac_id=<%=pacId%>&admision=<%=noAdmision%>');
					}
					else alert('No se ha generado la solicitud');
				}
			}
		}else alert('Solicitudes solo para Beneficios con prioridad 1');
	}
}

function chkBeneficioSol(){
	var size = document.form4.benSize.value;
	var action = document.form4.baction.value;

	for(i=1;i<=size;i++){
		var empresa = eval('document.form4.empresa'+i).value;

		if(eval('document.form4.prioridad'+i).value=="1" && action == 'Guardar'){
			var estatus='A'
			if(hasDBData('<%=request.getContextPath()%>','tbl_adm_solicitud_beneficio','empresa='+empresa+' and  estatus=\'A\' and admision=<%=noAdmision%> and pac_id=<%=pacId%>','')){
			} else {//abrir_ventana2('../admision/solicitud_beneficio.jsp?pac_id=<%=pacId%>&admision=<%=noAdmision%>');
				var fecha= '<%=fecha%>';
				var fIngreso='<%=fechaIngreso%>';
				var codPac = parseInt(eval('document.form4.codigoPaciente').value);
				if(eval('document.form4.poliza'+i).value=="" && eval('document.form4.status'+i).value!="D" )
					alert('Introduzca su poliza');
				else {
					var poliza = eval('document.form4.poliza'+i).value;
					var certificado = eval('document.form4.certificado'+i).value;
					var plan = eval('document.form4.plan'+i).value;
					var clasif_admi = eval('document.form4.clasifAdmi'+i).value;
					var tipo_admi = eval('document.form4.tipoAdmi'+i).value;
					var categoria_admi = eval('document.form4.categoriaAdmi'+i).value;
					var convenio = eval('document.form4.convenio'+i).value;

					var cod = getDBData('<%=request.getContextPath()%>','c.sol_benef_pac, c.sol_benef_emp','tbl_adm_beneficios_x_admision a, tbl_adm_categoria_admision b, tbl_adm_clasif_x_plan_conv c, tbl_adm_tipo_admision_cia d, tbl_adm_clasif_x_tipo_adm e', 'a.plan = c.plan and a.convenio = c.convenio and a.empresa = c.empresa and a.clasif_admi = c.clasif_admi and a.tipo_admi = c.tipo_admi and a.categoria_admi = c.categoria_admi and d.categoria = b.codigo and c.clasif_admi = e.codigo and c.tipo_admi = e.tipo and c.categoria_admi = e.categoria and e.tipo = d.codigo and e.categoria = d.categoria and c.plan = '+plan+' and c.clasif_admi = '+clasif_admi+' and c.tipo_admi = '+tipo_admi+' and c.empresa = '+empresa+' and c.categoria_admi = '+categoria_admi+' and c.convenio = '+convenio+' and a.pac_id = <%=pacId%> and a.admision = <%=noAdmision%> and a.estado = \'A\' and a.prioridad = 1','');
					if(cod.substr(0,1)=="S" && cod.substr(2,1)=="N"){
							alert('De acuerdo al plan, se requiere generar la Solicitud de Beneficios para que pueda calcular el copago del paciente.\nDebe hacer esto una vez sea guardado el Beneficio!.');
					}
					if(cod.substr(0,1)=="N" && cod.substr(2,1)=="S"){
							alert('De acuerdo al plan, se requiere generar la Solicitud de Beneficios para que pueda calcular el monto que asume la Aseguradora.\nDebe hacer esto una vez sea guardado el Beneficio!.');
					}
				}
			}
		}
	}
	return false;
}

function showPacienteList()
{
	abrir_ventana1('../common/search_paciente.jsp?fp=admision');
}

function showMedicoList(opt,k)
{
	if (opt.toLowerCase() == 'especialidad') abrir_ventana1('../common/search_medico.jsp?fp=admision_medico_esp&fg=admision');
	else if (opt.toLowerCase() == 'cabecera') abrir_ventana1('../common/search_medico.jsp?fp=admision_medico_cab&fg=admision');
	else if (opt.toLowerCase() == 'responsable') abrir_ventana1('../common/search_medico.jsp?fp=admision_medico_resp&fg=admision&index='+k);
}

function showTipoAdmisionList()
{
	abrir_ventana1('../common/search_tipo_admision.jsp?fp=admision&pac_id=<%=pacId%>&admision=<%=noAdmision%>');
}

function clearMedico(opt)
{
	if (opt.toLowerCase() == 'cabecera')
	{
		document.form0.medicoCabecera.value = '';
		document.form0.nombreMedicoCabecera.value = '';
	}
	else if (opt.toLowerCase() == 'responsable')
	{
		document.form5.medico.value = '';
		document.form5.nombreMedico.value = '';
	}
}

function showCamaList()
{
	abrir_ventana1('../common/check_cama.jsp?fp=admision&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>');
}

function usePrecioAlterno(k)
{
	if (eval('document.form1.precioAlt'+k).checked)
	{
		eval('document.form1.precioAlterno'+k).disabled = false;
		eval('document.form1.precioAlterno'+k).className = 'FormDataObjectEnabled';
	}
	else
	{
		eval('document.form1.precioAlterno'+k).disabled = true;
		eval('document.form1.precioAlterno'+k).className = 'FormDataObjectDisabled';
	}
	ctrlObsPrecioAlt(k);
}

function showDiagnosticoList()
{
	abrir_ventana1('../common/check_diagnostico.jsp?fp=admision&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>');
}

function showDocumentoList()
{
	abrir_ventana1('../common/check_documento.jsp?fp=admision&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>');
}

function showEmpresaList(k)
{
	abrir_ventana1('../common/search_empresa.jsp?fp=admision&index='+k);
}

function showEmpleadoList(opt,k)
{
	if (opt.toLowerCase() == 'beneficio') abrir_ventana1('../common/search_empleado.jsp?fp=admision_empleado_ben&index='+k);
	else if (opt.toLowerCase() == 'responsable') abrir_ventana1('../common/search_empleado.jsp?fp=admision_empleado_resp&index='+k);
}

function showNacionalidadList(k)
{
	abrir_ventana1('../rhplanilla/list_pais.jsp?id=6&index='+k);
}

function showUbicacionGeoList(k)
{
	abrir_ventana1('../common/search_ubicacion_geo.jsp?fp=admision&index='+k);
}

function showBeneficioList()
{
	var oldBenefits='N';//used to display previous admision benefits if 'Y'
	//if(hasDBData('<%=request.getContextPath()%>','tbl_adm_beneficios_x_admision','pac_id=<%=pacId%> and admision=(select max(secuencia) - 1 from tbl_adm_admision where pac_id=<%=pacId%>) and estado=\'A\'','')&&confirm('¿Desea utilizar Beneficios de la Admisión Anterior?'))oldBenefits='Y';
	abrir_ventana1('../common/check_convenio_plan.jsp?fp=admision&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>&oldBenefits='+oldBenefits+"&fg=<%=fg%>&tr=<%=fp%>");
}
function setPacTypeImg(){
	var img='blank.gif';
	var pacType='';
	if(document.form0.key.value=='D'){img='distinguido.gif';pacType='DISTINGUIDO';}
	else if(document.form0.key.value=='S'){img='vip.gif';pacType='V.I.P.';}
	else if(document.form0.key.value=='M'){img='medico.gif';pacType='MEDICO DEL STAFF';}
	else if(document.form0.key.value=='J'){img='junta_directiva.gif';pacType='JUNTA DIRECTIVA';}
	if(pacType.trim()!='')alert('<%=UserDet.getName()%>:\nRecuerda, este es un cliente '+pacType+', gracias!!');
	document.getElementById('pacTypeImg').src='../images/'+img;
}
function doAction()
{
	<% if (fp.trim().equalsIgnoreCase("hdadmision")){%>
		maximizeWin();
		if (parent.opener){
				//parent.opener.close();
			parent.window.opener.close();
			}
	<%}else{%>
	loadXtraInfo();
	<%}%>

	<%if(mode.equals("add") && (pacId == null || pacId.equals(""))){%>
	showPacienteList();
	<%}%>
	//setPacTypeImg();
	validateStatus();
<% for (int i=1; i<=iResp.size(); i++) { %>
	showHide('51.<%=i%>');
	showHide('51.<%=i%>.0');//ingresos
	showHide('51.<%=i%>.1');//generales
	showHide('51.<%=i%>.2');//observación
<% } %>
<% if (tab.equals("4")) { %>chkDobleCobertura();<% } %>
<% if (request.getParameter("type") != null) { %>
	<% if (tab.equals("1")) { %>showCamaList();
	<% } else if (tab.equals("2")) { %>showDiagnosticoList();
	<% } else if (tab.equals("3")) { %>showDocumentoList();
	<% } else if (tab.equals("4")) { %>showBeneficioList();
	<% } %>
<% } %>
}
function isValidPriority(){if(isDuplicatedBeneficioPrioridad())return false;chkDobleCobertura();return true;}
function chkDobleCobertura(){
	var benSize=parseInt(document.form4.benSize.value,10);
	var nValid=0;
	var idx=-1;
	for(i=1;i<=benSize;i++){
		if(eval('document.form4.status'+i).value!='D'&&eval('document.form4.estado'+i).value!='I'){
			nValid++;
			if(eval('document.form4.prioridad'+i).value==1)idx=i;
		}
	}
	if(idx!=-1&&nValid>1){
		var chk=$("input[name^=convenioSolEmp][type='checkbox']");chk.attr('checked',false);
		eval('document.form4.convenioSolEmp'+idx).checked=true;
	}
}
function isDuplicatedBeneficioPrioridad()
{
	var benSize=parseInt(document.form4.benSize.value,10);
	for(i=1;i<=benSize-1;i++)
	{
		for(j=i+1;j<=benSize;j++)
		{

			if(eval('document.form4.prioridad'+i).value==eval('document.form4.prioridad'+j).value&&eval('document.form4.status'+i).value!="D"&&eval('document.form4.status'+j).value!="D"&&eval('document.form4.estado'+i).value!="I"&&eval('document.form4.estado'+j).value!="I")
			{
				alert('No se permiten beneficios con la misma prioridad!');
				eval('document.form4.prioridad'+j).value='';
				return true;
			}
		}
		isFirstPriority(i);
	}
	if(benSize>1)isFirstPriority(benSize);
	return false;
}

function isFirstPriority(k)
{
	if(eval('document.form4.convenioSolEmp'+k).checked&&eval('document.form4.prioridad'+k).value!=1 && eval('document.form4.status'+k).value!="D")
	{
		eval('document.form4.convenioSolEmp'+k).checked=false;
		alert('Sólo se permite seleccionar cuando es prioridad 1!');
		return false;
	}
}

function hasBeneficioEmpleado()
{
	var benSize=parseInt(document.form4.benSize.value,10);
	for(i=1;i<=benSize;i++)
	{
		if(eval('document.form4.empresa'+i).value=='81')return true;
	}
	return false;
}

function pendingBalanceConfirmation(tab)
{
	var proceed = true;
	eval('document.form'+tab+'.proceedPendingBalance').value = 'Y';
	// var pacId = document.form0.pacId.value;
	// var noAdmision = document.form0.noAdmision.value;
	// var retVal = '';
	// var facturadoA = 'P';
	// if (noAdmision != 0 && hasBeneficioEmpleado()) facturadoA = 'E';
	// if(pacId !=''){
	// retVal = getDBData('<%=request.getContextPath()%>','trim(to_char(nvl(sum(nvl(a.grang_total,0)+ nvl(y.ajustes,0)-nvl(b.pagos,0)),0),\'99999990.00\')),count(a.codigo)','tbl_fac_factura a,(select sum(dp.monto) pagos,dp.compania,dp.fac_codigo from tbl_cja_detalle_pago dp where exists ( select 1 from tbl_cja_transaccion_pago where compania =dp.compania and anio =dp.tran_anio and codigo = dp.codigo_transaccion and rec_status<> \'I\' )group by dp.compania,dp.fac_codigo)b,(select nvl(sum(decode(z.lado_mov,\'D\',z.monto,\'C\',-z.monto)),0)ajustes,z.compania,z.factura from vw_con_adjustment_gral z where z.tipo_doc =\'F\' group by z.compania,z.factura ) y ','a.codigo=b.fac_codigo(+)  and a.compania =b.compania(+) and a.pac_id='+pacId+' and a.estatus <> \'A\' and a.facturar_a=\''+facturadoA+'\'  and a.codigo=y.factura(+) and a.compania =y.compania(+)','');
	// var deuda = parseFloat(retVal.substring(0,retVal.indexOf('|')));
	// var nFactura = retVal.substring(retVal.indexOf('|')+1);

	// if (deuda > 0)
	// {
		// proceed = confirm('El Paciente tiene '+nFactura+' facturas con monto pendientes que ascienden a '+deuda.toFixed(2)+'\n'+'El paciente tiene deuda pendiente con la Clínica, ¿Desea continuar con la admisión bajo su responsabilidad?');
		// if (proceed) eval('document.form'+tab+'.proceedPendingBalance').value = 'Y';
		// else eval('document.form'+tab+'.proceedPendingBalance').value = 'N';
	// }
	// else eval('document.form'+tab+'.proceedPendingBalance').value = '';
	// }
	return proceed;
}

function hasActiveAdmision()
{
	var pacId = document.form0.pacId.value;
	var categoria = document.form0.categoria.value;
	var centroServicio = document.form0.centroServicio.value;
	var admision = document.form0.noAdmision.value;
	var msg = '';
	if(pacId !=''){
	if(categoria==1)
	{
		if(parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision','pac_id='+pacId+' and categoria='+categoria+' and estado=\'A\' and secuencia <>'+admision,''),10)><%=(mode.equalsIgnoreCase("add"))?"0":"0"%>)msg='El paciente ya tiene una admisión ACTIVA!';
	}
	else
	{	if(categoria !='' && centroServicio !=''){
		if(parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision','pac_id='+pacId+' and categoria='+categoria+' and estado=\'A\' and centro_servicio='+centroServicio+' and secuencia <>'+admision,''),10)><%=(mode.equalsIgnoreCase("add"))?"0":"0"%>)msg='El paciente ya tiene una admisión de esta área ACTIVA!';
		}else msg='Seleccione categoria y tipo de admisión!';
	}

	if(msg=='')return false;
	else
	{
		alert(msg);
		return true;
	}
	}
}

function validateStatus()
{
	var pacId = document.form0.pacId.value;
	var msg ='';
	if(document.form0.estado.value=='P')
	{
		<%if(mode.equals("edit")){%>

		if(parseFloat(getDBData('<%=request.getContextPath()%>','nvl(sum(decode(b.tipo_transaccion,\'C\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0) + nvl(sum(decode(b.tipo_transaccion,\'H\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0) - nvl(sum(decode(b.tipo_transaccion,\'D\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0)','tbl_fac_transaccion a, tbl_fac_detalle_transaccion b','a.pac_id=b.pac_id and a.admi_secuencia=b.fac_secuencia and a.compania=b.compania and a.tipo_transaccion=b.tipo_transaccion and a.codigo=b.fac_codigo and a.admi_secuencia=<%=noAdmision%> and a.pac_id=<%=pacId%>',''))>0)msg+='\n- La admisión tiene cargos registrados. Debe devolver los cargos para que la admisión quede en cero';
		if(msg.length>0){alert('La Admisión no se puede cambiar de estado por las siguientes razones:'+msg);
		document.form0.estado.value='<%=adm.getEstado()%>';

		}else{document.form0.fechaPreadmision.value='<%=cDateTime%>';
		document.form0.fechaPreadmision.className='FormDataObjectRequired';
		document.form0.resetfechaPreadmision.disabled=false;}
		<%}else{%>
		//document.form0.fechaIngreso.value='';
		//document.form0.amPm.value='';
		document.form0.fechaPreadmision.value='<%=cDateTime%>';
		document.form0.fechaPreadmision.className='FormDataObjectRequired';
		document.form0.resetfechaPreadmision.disabled=false;
<%}
//if (fg.equalsIgnoreCase("con_sup"))
//{
%>
		document.form0.fechaIngreso.readOnly=true;
		document.form0.fechaIngreso.className='FormDataObjectDisabled';
		document.form0.resetfechaIngreso.disabled=true;
		document.form0.amPm.readOnly=true;
		document.form0.amPm.className='FormDataObjectDisabled';
		document.form0.resetamPm.disabled=true;
		document.form0.fechaPreadmision.readOnly=false;

<%
//}
%>
	}
	else
	{
		<%if(mode.equals("add")){%>
		document.form0.fechaIngreso.value='<%=cDateTime.substring(0,10)%>';
		document.form0.amPm.value='<%=cDateTime.substring(11)%>';
		<%}%>
		document.form0.fechaPreadmision.value='';
<%
//if (fg.equalsIgnoreCase("con_sup"))
//{
%>
		//document.form0.fechaIngreso.readOnly=false;
		document.form0.fechaIngreso.className='FormDataObjectRequired';
		document.form0.resetfechaIngreso.disabled=false;
		document.form0.amPm.readOnly=false;
		document.form0.amPm.className='FormDataObjectRequired';
		document.form0.resetamPm.disabled=false;
		document.form0.fechaPreadmision.readOnly=true;
		document.form0.fechaPreadmision.className='FormDataObjectDisabled';
		document.form0.resetfechaPreadmision.disabled=true;
<%
//}
%>
	<%if(mode.equals("edit") && adm.getCategoria().equals("1")){%>
	if(document.form0.estado.value=='E'){
		alert('El proceso correcto para que una admision HOSPITALIZADA cambie a ESPERA es darle salida al paciente!');
		document.form0.estado.value='<%=adm.getEstado()%>';
	}
	<%}%>
	}
}

function chkDateCama(){
var camaSize=parseInt(document.form1.camaSize.value,10);
	for(i=1;i<=camaSize;i++)
	{
		var fecha_creacion =  eval('document.form1.fechaInicio'+i).value+ ' ' +eval('document.form1.horaInicio'+i).value;
		var time = 1;

		if(eval('document.form1.status'+i).value!='D' && eval('document.form1.casoEspecial'+i).value=='1')
		{
			if(fecha_creacion!='') time = getDBData('<%=request.getContextPath()%>','case when to_date(\''+fecha_creacion+'\',\'dd/mm/yyyy hh12:mi am\') + 3/24 > sysdate then 1 else 0 end','dual','','');
			if(time==0)
			{
				alert('La cama no puede ser borrada, ya pasaron las 3 horas disponibles que tenía para borrarlas!');
				return false;
			} //else return true;
		}
	}
	return true;
}
function chkEstadoAdm(){<%if(mode.trim().equals("edit")){%>if(hasDBData('<%=request.getContextPath()%>','tbl_adm_admision','secuencia=<%=noAdmision%> and pac_id=<%=pacId%> and estado=\'E\'','')){alert('La admisión está En Espera. No puede asignarle cama!');return false;}else return true;<%}else{%>return true;<%}%>}
function hasMotherAdmision()
{
	var categoria = document.form0.categoria.value;
	var estado = document.form0.estado.value;
	var tipoAdmision = document.form0.tipoAdmision.value;
	var nRec = -1;

	var ct_tp_adm = getDBData('<%=request.getContextPath()%>','param_value','tbl_sec_comp_param','param_name=\'CT_TP_ADM\' and compania in (-1,<%=(String) session.getAttribute("_companyId")%>)','');
	var cat =ct_tp_adm.substr(0,1);//1|4|5
	var mat =ct_tp_adm.substr(4,1);
	var neo =ct_tp_adm.substr(2,1);

	if (estado == 'A' && categoria == cat && tipoAdmision == neo)
	{
		var provincia = document.form0.provincia.value.trim();
		var sigla = document.form0.sigla.value.trim();
		var tomo = document.form0.tomo.value.trim();
		var asiento = document.form0.asiento.value.trim();
		var pasaporte = document.form0.pasaporte.value.trim();


		if (provincia != '' && sigla != '' && tomo != '' && asiento != '')
		{
			 if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento)){alert('Valores invalidos en numero de cedula! Revise..')}else{
		 nRec = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision a, tbl_adm_paciente b','a.estado=\'A\' and a.categoria='+cat+' and a.tipo_admision='+mat+' and a.pac_id=b.pac_id and b.provincia='+provincia+' and b.sigla=\''+sigla+'\' and b.tomo='+tomo+' and b.asiento='+asiento,''),10);}}
		else if (pasaporte != ''){ nRec = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision a, tbl_adm_paciente b','a.estado=\'A\' and a.categoria='+cat+' and a.tipo_admision='+mat+' and a.pac_id=b.pac_id and b.pasaporte=\''+pasaporte+'\'',''),10);}
		if (nRec == 0)
		{
			alert('No se ha podido establecer enlace entre la admisión del Neonato y la Madre.  Es probable que el número de identificación (Cédula/Pasaporte) del Neonato no es igual al de la madre!');
			return false;
		}
		else if (nRec == 1) return true;
		else if (nRec > 1)
		{
			alert('Más de una admisión de la madre coincide con la identificación (Cédula/Pasaporte) del Neonato!');
			return false;
		}
	}
	return true;
}

function useOtherPrice()
{
	var camaSize=parseInt(document.form1.camaSize.value,10);
	for(i=1;i<=camaSize;i++)
	{
		if(eval('document.form1.status'+i).value!='D'&&eval('document.form1.precioAlt'+i).checked&&(eval('document.form1.precioAlterno'+i).value.trim()=='' || eval('document.form1.obsPrecioAlt'+i).value.trim()=='') )
		{
			alert('Usted ha marcado el Precio Alterno, por lo tanto debe introducir el monto del Precio Alterno y el motivo!');
			return false;
		}

	}
	return true;
}

//usePrecioAlterno()
function ctrlObsPrecioAlt(index){
	var rowObj = document.getElementById("obsPrecioAltRow"+index);
	var obsPrecioAlt = document.getElementById("obsPrecioAlt"+index);

	if (eval('document.form1.precioAlt'+index).checked ) {
		obsPrecioAlt.className = 'FormDataObjectEnabled';
		obsPrecioAlt.disabled = false;
		rowObj.style.display = "block";
	}else{
		obsPrecioAlt.className = 'FormDataObjectDisabled';
		obsPrecioAlt.disabled = true;
		rowObj.style.display = "none";
	}

}

function hasEmployeeDebt()
{
	var tipoCta=document.form0.tipoCta.value;
	var responsabilidad=document.form0.responsabilidad.value;

	if(tipoCta=='E'&&(responsabilidad=='P'||responsabilidad=='O'))
	{
		var provincia=document.form0.provincia.value;
		var sigla=document.form0.sigla.value;
		var tomo=document.form0.tomo.value;
		var asiento=document.form0.asiento.value;
		if(provincia.trim()==''||sigla.trim()==''||tomo.trim()==''||asiento.trim()=='')
		{
			alert('La Cédula no es válida!');
			return false;
		}
		else
		{
			var c=splitCols(getDBData('<%=request.getContextPath()%>','primer_nombre||\' \'||decode(sexo,\'F\',decode(apellido_casada,null,primer_apellido,decode(usar_apellido_casada,\'S\',\'DE \'||apellido_casada,primer_apellido)),primer_apellido), num_empleado, get_porc_endeudamiento(emp_id)','tbl_pla_empleado','provincia='+provincia+' and sigla=\''+sigla+'\' and tomo='+tomo+' and asiento='+asiento+' and estado!=3',''));
			if(c==null)
			{
				alert('ATENCION: La Cédula indicada no corresponde a ningún empleado válido, si se trata del dependiente\n de un empleado por favor indicar en la sección de Beneficios el empleado del cual depende!');
				return false;
			}
			else
			{
				var empName=c[0];
				var empNo=c[1];
				var empPerc=parseFloat(c[2]);
				//alert('Empleado #'+empNo+', '+empName+' '+empPerc);
				var porcPermitido=getDBData('<%=request.getContextPath()%>','decode(porc_endeudamiento,0,50,porc_endeudamiento)','tbl_pla_parametros','cod_compania=<%=session.getAttribute("_companyId")%> and estado=\'A\'','');
				if(porcPermitido.trim()=='')porcPermitido=50;
				else porcPermitido=parseFloat(porcPermitido);
				if(empPerc>porcPermitido)
				{
					alert('ATENCION USUARIO: El empleado no es sujeto de crédito por no tener capacidad de descuento.Debe pagar al contado la totalidad de la factura. Consultar a su SUPERVISOR!');
					return false;
				}
			}
		}
	}
	return true;
}

function isAdmisionInactive()
{
	<%if(!fp.trim().equals("fact")){%>
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_admision','secuencia=<%=noAdmision%> and pac_id=<%=pacId%> and estado=\'I\'',''))
	{
		alert('La admisión está INACTIVA!');
		return true;
	}
	else return false;
	<%}%>
}

function confirmBenefitStatus(k)
{
	var status=eval('document.form4.estado'+k).value;
	if(status=='I'&&!confirm('¿Está seguro que desea INACTIVAR el beneficio?'))eval('document.form4.estado'+k).value='A';
}

function addBenefAnterior(k)
{
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_beneficios_x_admision','pac_id=<%=pacId%> and admision=(select max(secuencia) - 1 from tbl_adm_admision where pac_id=<%=pacId%>) and estado=\'A\'',''))
	{
		var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','distinct a.empresa, a.convenio, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, b.tipo_poliza as tipoPoliza, b.tipo_plan as tipoPlan, b.nombre as nombrePlan, c.nombre as nombreConvenio, d.nombre as nombreEmpresa, e.nombre as nombreTipoPlan, f.nombre as nombreTipoPoliza, g.descripcion as clasifAdmiDesc, h.descripcion as tipoAdmiDesc, i.descripcion as categoriaAdmiDesc, a.poliza, a.certificado, a.prioridad, a.convenio_sol_emp as convenioSolEmp, a.num_aprobacion as numAprobacion','tbl_adm_beneficios_x_admision a, tbl_adm_plan_convenio b, tbl_adm_convenio c, tbl_adm_empresa d, tbl_adm_tipo_plan e, tbl_adm_tipo_poliza f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_tipo_admision_cia h, tbl_adm_categoria_admision i','a.pac_id=<%=pacId%> and a.admision=(select max(secuencia) - 1 from tbl_adm_admision where pac_id=<%=pacId%>) and a.estado=\'A\' and a.empresa=b.empresa and a.convenio=b.convenio and a.plan=b.secuencia and b.empresa=c.empresa and b.convenio=c.secuencia and b.estado=\'A\' and c.empresa=d.codigo and c.estatus=\'A\' and a.tipo_plan=e.tipo_plan and a.tipo_poliza=e.poliza and a.tipo_poliza=f.codigo and a.categoria_admi=g.categoria and a.tipo_admi=g.tipo and a.clasif_admi=g.codigo and g.categoria=h.categoria and g.tipo=h.codigo and h.categoria=i.codigo order by a.empresa, a.convenio, a.plan, a.categoria_admi, a.tipo_admi, a.clasif_admi'));
		for(i=0;i<r.length;i++)
		{
			var c=r[i];
			eval('document.form4.empresa'+k).value=c[0].trim();
			document.getElementById('_lblEmpresa'+k).innerHTML=c[0].trim();
			eval('document.form4.convenio'+k).value=c[1].trim();
			eval('document.form4.plan'+k).value=c[2].trim();
			document.getElementById('_lblPlan'+k).innerHTML=c[2].trim();
			eval('document.form4.categoriaAdmi'+k).value=c[3].trim();
			document.getElementById('_lblCategoriaAdmi'+k).innerHTML=c[3].trim();
			eval('document.form4.tipoAdmi'+k).value=c[4].trim();
			document.getElementById('_lblTipoAdmi'+k).innerHTML=c[4].trim();
			eval('document.form4.clasifAdmi'+k).value=c[5].trim();
			document.getElementById('_lblClasifAdmi'+k).innerHTML=c[5].trim();
			eval('document.form4.tipoPoliza'+k).value=c[6].trim();
			document.getElementById('_lblTipoPoliza'+k).innerHTML=c[6].trim();
			eval('document.form4.tipoPlan'+k).value=c[7].trim();
			document.getElementById('_lblTipoPlan'+k).innerHTML=c[7].trim();
			eval('document.form4.nombrePlan'+k).value=c[8].trim();
			document.getElementById('_lblNombrePlan'+k).innerHTML=c[8].trim();
			eval('document.form4.nombreConvenio'+k).value=c[9].trim();
			eval('document.form4.nombreEmpresa'+k).value=c[10].trim();
			document.getElementById('_lblNombreEmpresa'+k).innerHTML=c[10].trim();
			eval('document.form4.nombreTipoPlan'+k).value=c[11].trim();
			document.getElementById('_lblNombreTipoPlan'+k).innerHTML=c[11].trim();
			eval('document.form4.nombreTipoPoliza'+k).value=c[12].trim();
			document.getElementById('_lblNombreTipoPoliza'+k).innerHTML=c[12].trim();
			eval('document.form4.clasifAdmiDesc'+k).value=c[13].trim();
			document.getElementById('_lblClasifAdmiDesc'+k).innerHTML=c[13].trim();
			eval('document.form4.tipoAdmiDesc'+k).value=c[14].trim();
			document.getElementById('_lblTipoAdmiDesc'+k).innerHTML=c[14].trim();
			eval('document.form4.categoriaAdmiDesc'+k).value=c[15].trim();
			document.getElementById('_lblCategoriaAdmiDesc'+k).innerHTML=c[15].trim();
			eval('document.form4.poliza'+k).value=c[16].trim();
			eval('document.form4.certificado'+k).value=c[17].trim();
			eval('document.form4.status'+k).value=c[18].trim();
			document.form4.baction.value="add";
			document.form4.submit();
			break;
		}
	}	else alert('No Hay beneficios activos!');
}
function printAdm(){abrir_ventana1('../admision/print_admision.jsp?mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');}
function printBarcode(){abrir_ventana('../admision/print_admision_barcode.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>');}
function getMedicDetail(code,type){var name='',esp='';if(code!=undefined&&code!=null&&code!=''&&type!=undefined&&type!=null&&type!=''){var c=splitCols(getDBData('<%=request.getContextPath()%>','a.primer_nombre||decode(a.segundo_nombre,null,\'\',\' \'||a.segundo_nombre)||\' \'||a.primer_apellido||decode(a.segundo_apellido,null,\'\',\' \'||a.segundo_apellido)||decode(a.sexo,\'F\',decode(a.apellido_de_casada,null,\'\',\' \'||a.apellido_de_casada)) as nombre,nvl((select y.descripcion from tbl_adm_medico_especialidad z,tbl_adm_especialidad_medica y where z.medico=a.codigo and z.secuencia=1 and z.especialidad=y.codigo),\'NO TIENE\') as especialidad','tbl_adm_medico a','a.codigo=\''+code+'\'',''));if(c!=null){name=c[0];esp=c[1];}}if(type=='adm'){document.form0.nombreMedico.value=name;document.form0.especialidad.value=esp;}else if(type=='cab'){document.form0.nombreMedicoCabecera.value=name;}}

function viewScan(){
	abrir_ventana("../admision/asociar_escaneados_a_doc_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>");
}
function notAValidDate(){
	 var preAdmDate = document.getElementById("fechaPreadmision").value;
	 if (preAdmDate!="") {
			 if(getDBData("<%=request.getContextPath()%>","count(*)","dual"," to_date('"+preAdmDate+"','dd/mm/yyyy hh12:mi AM') >= to_date(to_char(sysdate,'dd/mm/yyyy hh12:mi AM'),'dd/mm/yyyy hh12:mi AM')","") > 0)
		 return false;
		 else {
				alert("Por favor verifique que la fecha de la pre admisión no sea una fecha anterior a la de hoy!");
			return true;
		 }
	 }
	 return false;
}

///

function loadXtraInfo(){
	 var pacId = $("#pacId").val();
	 var _status = $("#ajaxStatus").val();
	 var noAdmision = $("#form0 #noAdmision").val();
	 var facturadoA = 'P';
	 var loaded = "0";

	 if (noAdmision != 0 && hasBeneficioEmpleado()) facturadoA = 'E';
	 if (pacId != "0"){
		 //$("#indicator").show(0).delay(2000).hide(0,function(){
				if(_status=="OK")loaded = "1";

				$.ajax({
					url: '../common/set_extra_info.jsp?fp=admision&pacId='+pacId+'&status='+loaded+'&facturadoA='+facturadoA+'&mode=<%=mode%>&noAdmision=<%=noAdmision%>',
					cache: false,
					dataType: "html"
				}).done(function(data){
					 $("#container").delay(1000).show(0);
					 $("#indicator").show(0).delay(3000).hide(0,function(){

							var inff = $('#pacInfoWrapper').html(data).find("#inff").length;
							var adma = $('#pacInfoWrapper').html(data).find("#adma").length;
							var rie  = $('#pacInfoWrapper').html(data).find("#rie").length;
							showHideInfo(inff, adma,rie);

							$("#ajaxStatus").val("OK");
							$("#iHide").show(0);

							$('#pacInfoWrapper').css("text-align","left").html(data);
							$("#accordion").accordion({
							 active: 0, header:"h3", icons:false,
							 heightStyle: "content"
							});
						});
				}).fail(function(jqXHR, textStatus){
					$('#pacInfoWrapper').html("La request has fallido: " + textStatus);
				});
		//});
	}

}
var showHideInfo = function(inff, adma,rie){
	if (inff>0) $("#saldoPendiente").show(0);
	if (adma>0) $("#admActivas").show(0);
	if (rie>0) $("#pacCondicion").show(0);
}
$(document).ready(function(){
	$("#container").on("dblclick",function(){
		 $(this).hide(0);
	 $("#iShow").show(0);
		 $("#iHide").hide(0);
	});
	$("#iHide").on("click",function(){
		 $("#container").hide(0);
		 $("#iShow").show(0);
		 $("#iHide").hide(0);
	});
	$("#iShow").on("click",function(){
		 $("#container").show(0);
	 $("#iHide").show(0);
	 $("#iShow").hide(0);
	});
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		 <table width="99%" cellpadding="0" cellspacing="0">
			 <tr>
				<td width="80%" class="RedTextBold">
			<div style="margin:5px 0 5px 0">
			<span id="saldoPendiente" style="display:none; margin-right:40px;">Paciente con Saldo pendiente</span>
			<span id="admActivas" style="display:none; margin-right:40px;">Paciente tiene otras admisiones activas</span>
			<span id="pacCondicion" style="display:none;">Paciente con condición de riesgo de caída</span>&nbsp;
			</div>
			</td>
			<td  align="right" width="20%">
			<label id="optDesc" class="TextInfo Text10">&nbsp;</label>
		&nbsp;
		<%if (!mode.equalsIgnoreCase("add")) {%>
		<authtype type='50'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/barcode.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir Brazalete')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:printBarcode()"></authtype>
		<authtype type='2'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir Boleta de Admisión')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:printAdm()"></authtype>
		<%}else{%>
		&nbsp;
		<%}%>
			</td>
			 </tr>
		 </table>
	</td>
</tr>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td width="80%" style="vertical-align:top">

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">



<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("ajaxStatus","")%>
<%=fb.hidden("infoStatus","")%>
<%=fb.hidden("do_adm","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("camaSize",""+iCama.size())%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benSize",""+iBen.size())%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respSize",""+iResp.size())%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
<%fb.appendJsValidation("if(isAdmisionInactive())error++;");%>
<%fb.appendJsValidation("if(!hasMotherAdmision())error++;");%>
<%fb.appendJsValidation("if(hasActiveAdmision())error++;");%>
<%//if(mode.equalsIgnoreCase("add"))fb.appendJsValidation("if(!pendingBalanceConfirmation(0))error++;");%>
<%=fb.hidden("proceedPendingBalance","")%>
<%fb.appendJsValidation("hasEmployeeDebt();");%>
<%fb.appendJsValidation("if(notAValidDate()==true)error++;");%>
<%fb.appendJsValidation("if(document.form0.estado.value=='P'&&document.form0.fechaPreadmision.value.trim()=='')alert('Por favor introduzca la fecha/hora de la preadmisión!');else if(document.form0.fechaIngreso.value.trim()==''||document.form0.amPm.value.trim()=='')alert('Por favor introduzca la fecha/hora de ingreso!');");%>
<%fb.appendJsValidation("if(document.form0.estado.value=='P' && (document.form0.categoria.value==2 || document.form0.categoria.value==4)){alert('No puede crear Pre-Admisión para Emergencia/Consulta Externa!'); error++;}");%>
				<tr class="TextRow02">
					<td align="right">
					<span class="showHideXtraInfo iShow" title="Esconder" id="iHide">&nbsp;
					</span>
					<span class="showHideXtraInfo iHide" title="Mostar" id="iShow">&nbsp;</span>
					&nbsp;
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="2">Nombre</cellbytelabel></td>
							<td >
								<%=fb.hidden("key",adm.getKey())%>
								<%=fb.intBox("pacId",adm.getPacId(),true,false,true,5)%>
								<%=fb.textBox("nombrePaciente",adm.getNombrePaciente(),true,false,true,40)%>
								<%=fb.button("btnPaciente","...",true,(!mode.equalsIgnoreCase("add")),null,null,"onClick=\"javascript:showPacienteList()\"")%>
								<img id='pacTypeImg' src='../images/blank.gif' height="8" width="20">							</td>
							<td width="14%" align="right">O/C</td>
							<td width="35%"><%=fb.textBox("oc",adm.getOc(),false,false,false,18,15)%></td>
						</tr>
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="3">C&eacute;dula</cellbytelabel></td>
							<td width="36%">
								<%=fb.intBox("provincia",adm.getProvincia(),false,false,true,2)%>
								<%=fb.textBox("sigla",adm.getSigla(),false,false,true,2)%>
								<%=fb.intBox("tomo",adm.getTomo(),false,false,true,4)%>
								<%=fb.intBox("asiento",adm.getAsiento(),false,false,true,5)%>
								<%=fb.hidden("dCedula",adm.getDCedula())%>
								<%=fb.select("dCedulaDisplay","D,R,H1,H2,H3,H4,H5",adm.getDCedula(),false,true,0)%>
							</td>
							<td width="14%" align="right"><cellbytelabel id="4">Pasaporte</cellbytelabel></td>
							<td width="35%"><%=fb.textBox("pasaporte",adm.getPasaporte(),false,false,true,20)%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td>
								<%=fb.textBox("fechaNacimiento",adm.getFechaNacimiento(),false,false,true,10)%>
								<%=fb.intBox("codigoPaciente",adm.getCodigoPaciente(),false,false,true,3)%>
							</td>
							<td align="right"><cellbytelabel id="6">Responsable de la Cta.</cellbytelabel></td>
							<td><%=fb.select("responsabilidad","P=PACIENTE,O=OTRA PERSONA,E=EMPRESA",adm.getResponsabilidad(),false,viewMode,0,null,null,null)%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="7">M&eacute;dico</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td colspan="3">
								<%=fb.textBox("medico",adm.getMedico(),true,false,viewMode,10,null,null,"onBlur=\"javascript:getMedicDetail(this.value,'adm')\"")%>
								<%=fb.textBox("nombreMedico",adm.getNombreMedico(),true,false,true,40)%>
								<%=fb.button("btnMedico","...",false,viewMode,null,null,"onClick=\"javascript:showMedicoList('especialidad')\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="9">Especialidad</cellbytelabel></td>
							<td colspan="3"><%=fb.textBox("especialidad",adm.getEspecialidad(),false,false,true,50)%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="10">M&eacute;dico Cabecera</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td colspan="3">
								<%=fb.textBox("medicoCabecera",adm.getMedicoCabecera(),false,false,viewMode,15,null,null,"onBlur=\"javascript:getMedicDetail(this.value,'cab')\"")%>
								<%=fb.textBox("nombreMedicoCabecera",adm.getNombreMedicoCabecera(),false,false,true,50,null,null,null)%>
								<%=fb.button("btnMedicoCabecera","...",false,viewMode,null,null,"onClick=\"javascript:showMedicoList('cabecera')\"")%>
							</td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="12">No.</cellbytelabel></td>
							<td><%=adm.getNoAdmision()%></td>
							<td align="right"><cellbytelabel id="13">Estado</cellbytelabel></td>
							<td>
								<%=fb.select("estado",estadoOptions,adm.getEstado(),false,(viewMode && !fg.equalsIgnoreCase("con_sup")),0,null,null,"onChange=\"javascript:validateStatus()\"")%>
								Mes
								<%=fb.select("mesCtaBolsa","ENE=ENERO,FEB=FEBRERO,MAR=MARZO,ABR=ABRIL,MAY=MAYO,JUN=JUNIO,JUL=JULIO,AGO=AGOSTO,SEP=SEPTIEMBRE,OCT=OCTUBRE,NOV=NOVIEMBRE,DIC=DICIEMBRE",adm.getMesCtaBolsa(),false,true,0,null,null,null,"","S")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="14">Area</cellbytelabel></td>
							<td>
								<%=fb.intBox("centroServicio",adm.getCentroServicio(),true,false,true,5)%>
								<%=fb.textBox("centroServicioDesc",adm.getCentroServicioDesc(),true,false,true,40)%>
							</td>

							<td align="right"><cellbytelabel id="17">Fecha y Hora de Ingreso</cellbytelabel></td>
							<td>
							<%System.out.println("adm.getFechaIngreso()="+adm.getFechaIngreso());%>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="dd/mm/yyyy"/>
									<jsp:param name="nameOfTBox1" value="fechaIngreso"/>
									<jsp:param name="valueOfTBox1" value="<%=adm.getFechaIngreso()%>"/>
									<jsp:param name="readonly" value="<%=(fg.equalsIgnoreCase("con_sup2"))?"n":"y"%>"/>
								</jsp:include>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="hh12:mi am"/>
									<jsp:param name="nameOfTBox1" value="amPm"/>
									<jsp:param name="valueOfTBox1" value="<%=adm.getAmPm()%>"/>
									<jsp:param name="readonly" value="<%=(fg.equalsIgnoreCase("con_sup2"))?"n":"y"%>"/>
								</jsp:include>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="15">Categor&iacute;a</cellbytelabel></td>
							<td>
								<%=fb.intBox("categoria",adm.getCategoria(),true,false,true,4)%>
								<%=fb.textBox("categoriaDesc",adm.getCategoriaDesc(),true,false,true,40)%>
							</td>
							<td align="right"><cellbytelabel id="18">Fecha Preadmisi&oacute;n</cellbytelabel></td>
							<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
								<jsp:param name="nameOfTBox1" value="fechaPreadmision"/>
								<jsp:param name="valueOfTBox1" value="<%=adm.getFechaPreadmision()%>"/>
								</jsp:include>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="16">Tipo</cellbytelabel></td>
							<td>
								<%=fb.intBox("tipoAdmision",adm.getTipoAdmision(),true,false,true,2)%>
								<%=fb.textBox("tipoAdmisionDesc",adm.getTipoAdmisionDesc(),true,false,true,36)%>
								<%=fb.button("btnTipoAdmision","...",false,viewMode,null,null,"onClick=\"javascript:showTipoAdmisionList()\"")%>
							</td>
							<td colspan="2">
							<cellbytelabel>D&iacute;as Estimados</cellbytelabel>
							<%=fb.intBox("diasEstimados",adm.getDiasEstimados(),false,false,(viewMode && !fg.equalsIgnoreCase("con_sup")),3)%>
							<cellbytelabel>Contado / Cr&eacute;dito</cellbytelabel>
							<%=fb.select("contaCred",contCredOptions,"C=CONTADO"/*adm.getContaCred()*/,false,viewMode,0)%>&nbsp;
							</td>
						</tr>
<%
if (viewMode || fg.equalsIgnoreCase("con_sup2"))
{
%>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="21">Fecha y Hora de Egreso</cellbytelabel></td>
							<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="dd/mm/yyyy"/>
									<jsp:param name="nameOfTBox1" value="fechaEgreso"/>
									<jsp:param name="valueOfTBox1" value="<%=adm.getFechaEgreso()%>"/>
									<jsp:param name="readonly" value="<%=(fg.equalsIgnoreCase("con_sup2"))?"n":"y"%>"/>
								</jsp:include>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="hh12:mi am"/>
									<jsp:param name="nameOfTBox1" value="amPm2"/>
									<jsp:param name="valueOfTBox1" value="<%=adm.getAmPm2()%>"/>
									<jsp:param name="readonly" value="<%=(fg.equalsIgnoreCase("con_sup2"))?"n":"y"%>"/>
								</jsp:include>
							</td>
							<td align="right">
								<cellbytelabel id="22">Dias Hosp.</cellbytelabel>
								<%=fb.intBox("diasHospitalizados",adm.getDiasHospitalizados(),false,false,(viewMode && !fg.equalsIgnoreCase("con_sup")),3)%>
							</td>
							<td>
								<cellbytelabel id="23">No. Cta. Appx</cellbytelabel>
								<%=fb.textBox("noCuenta",adm.getNoCuenta(),false,false,viewMode,20,15)%>
							</td>
						</tr>
<%}
if(mode.equals("edit") && !fg.equalsIgnoreCase("con_sup")){%>
<%=fb.hidden("fechaEgreso",adm.getFechaEgreso())%>
<%}%>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="24">Tipo de Paciente (Descuento)</cellbytelabel></td>
							<td><%=fb.select("tipoCta","J=JUBILADO,E=EMPLEADO,M=MEDICO,P=PARTICULAR,A=ASEGURADO",adm.getTipoCta(),false,(viewMode && !fg.equalsIgnoreCase("con_sup")),0,null,null,null)%></td>
							<td align="right"><cellbytelabel id="25">Hospitalizaci&oacute;n Directa</cellbytelabel></td>
							<td><%=fb.select("hospDirecta","N=NO,S=SI",adm.getHospDirecta(),false,viewMode,0)%></td>
						</tr>

						<tr class="TextHeader">
							<td colspan="4">&nbsp;<cellbytelabel id="1">Condici&oacute;n del paciente</cellbytelabel></td>
						</tr>

						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Riesgo de Ca&iacute;da</cellbytelabel></td>
							<td><%=fb.select("condPaciente","N=NO,S=SI",adm.getCondicionPaciente(),false,viewMode,0)%></td>
							<td align="right"><cellbytelabel id="25">Info. Importante</cellbytelabel></td>
							<td>
							<%=fb.textarea("observAdm",adm.getObservAdm(),false,false,viewMode,40,2,1000)%>
							</td>
						</tr>

						</table>
					</td>
				</tr>
				<tr>
					<td>
						<jsp:include page="../common/bitacora.jsp" flush="true">
							<jsp:param name="audTable" value="tbl_adm_admision"></jsp:param>
							<jsp:param name="audFilter" value="<%="secuencia="+adm.getNoAdmision()+" and pac_id="+adm.getPacId()%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,(viewMode /*&& !fg.equalsIgnoreCase("con_sup")*/),false)%><cellbytelabel id="27">Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,(viewMode /*&& !fg.equalsIgnoreCase("con_sup")*/),false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,(viewMode /*&& !fg.equalsIgnoreCase("con_sup")*/),false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,(viewMode /*&& !fg.equalsIgnoreCase("con_sup")*/),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>



<%
//if (adm.getCategoria().equals("1")){
%>
<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("camaSize",""+iCama.size())%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benSize",""+iBen.size())%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respSize",""+iResp.size())%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
<%fb.appendJsValidation("if(document.form1.baction.value=='Guardar'&&!useOtherPrice())error++;");%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='X'&&!chkDateCama())error++;");%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&!chkEstadoAdm())error++;");%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimiento()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="33">Habitaci&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="4%"><cellbytelabel id="34">C&oacute;d.</cellbytelabel></td>
							<td width="5%"><cellbytelabel id="35">Cama</cellbytelabel></td>
							<td width="5%"><cellbytelabel id="33">Habitaci&oacute;n</cellbytelabel></td>
							<td width="18%"><cellbytelabel id="36">Sala o Secci&oacute;n</cellbytelabel></td>
							<td width="22%"><cellbytelabel id="15">Categor&iacute;a</cellbytelabel></td>
							<td width="7%"><cellbytelabel id="37">Precio</cellbytelabel></td>
							<td width="12%"><cellbytelabel id="38">Precio Alterno</cellbytelabel></td>
							<td width="12%">Fecha y Hora Asignaci&oacute;n</td>
							<td width="12%">Fecha y Hora Final</td>
							<td width="3%"><%=(vCamaNew.size() < 1 && (adm.getCantidadCa()!= null && !adm.getCantidadCa().equals("0")) && adm.getEstado()!= null && !adm.getEstado().equals("E"))?fb.submit("addCama","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Camas"):""%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iCama);
for (int i=1; i<=iCama.size(); i++)
{
	key = al.get(i - 1).toString();
	Admision obj = (Admision) iCama.get(key);
	String displayCama = "";
	if (obj.getStatus() != null && obj.getStatus().equalsIgnoreCase("D")) displayCama = " style=\"display:none\"";
%>
						<%=fb.hidden("key"+i,obj.getKey())%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("codigo"+i,obj.getCodigo())%>
						<%=fb.hidden("cama"+i,obj.getCama())%>
						<%=fb.hidden("habitacion"+i,obj.getHabitacion())%>
						<%=fb.hidden("centroServicioDesc"+i,obj.getCentroServicioDesc())%>
						<%=fb.hidden("habitacionDesc"+i,obj.getHabitacionDesc())%>
						<%=fb.hidden("precio"+i,obj.getPrecio())%>
						<%=fb.hidden("fechaInicio"+i,obj.getFechaInicio())%>
						<%=fb.hidden("horaInicio"+i,obj.getHoraInicio())%>
						<%=fb.hidden("usuarioCreacion"+i,obj.getUsuarioCreacion())%>
						<%=fb.hidden("fechaCreacion"+i,obj.getFechaCreacion())%>
						<%=fb.hidden("usuarioModifica"+i,obj.getUsuarioModifica())%>
						<%=fb.hidden("fechaModifica"+i,obj.getFechaModifica())%>
						<%=fb.hidden("casoEspecial"+i,obj.getCasoEspecial())%>
						<%=fb.hidden("status"+i,obj.getStatus())%>
						<%=fb.hidden("fechaFinal"+i,obj.getFechaFinal())%>
						<%=fb.hidden("horaFinal"+i,obj.getHoraFinal())%>
						<tr class="TextRow01"<%=displayCama%>>
							<td align="center"><%=obj.getCodigo()%></td>
							<td align="center"><%=obj.getCama()%></td>
							<td align="center"><%=obj.getHabitacion()%></td>
							<td><%=obj.getCentroServicioDesc()%></td>
							<td><%=obj.getHabitacionDesc()%></td>
							<td align="right"><%=CmnMgr.getFormattedDecimal(obj.getPrecio())%></td>
							<td>
								<%=fb.checkbox("precioAlt"+i,"S",(obj.getPrecioAlt() != null && obj.getPrecioAlt().equalsIgnoreCase("S")),(viewMode||(obj.getCasoEspecial() != null && !obj.getCasoEspecial().trim().equals("")&& obj.getCasoEspecial().trim().equals("0"))),null,null,"onClick=\"javascript:usePrecioAlterno("+i+")\"","Utilizar Precio Alterno")%>
								<%=fb.decBox("precioAlterno"+i,obj.getPrecioAlterno(),false,!(obj.getPrecioAlt() != null && obj.getPrecioAlt().equalsIgnoreCase("S")),viewMode,10,8.2)%>
							</td>
							<td align="center"><%=obj.getFechaInicio()%> <%=obj.getHoraInicio()%></td>
							<td align="center"><%=obj.getFechaFinal()%> <%=obj.getHoraFinal()%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,(viewMode||(obj.getCasoEspecial() != null && !obj.getCasoEspecial().trim().equals("")&& obj.getCasoEspecial().trim().equals("0"))),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Cama")%></td>
						</tr>

						<tr class="TextRow01" id="obsPrecioAltRow<%=i%>">
							<td colspan="3">Motivo del precio alternativo</td>
														<td colspan="7">
										<%=fb.textarea("obsPrecioAlt"+i,obj.getMotivoPrecioAlt(),false,!(obj.getPrecioAlt() != null && obj.getPrecioAlt().equalsIgnoreCase("S")),viewMode,100,2,200)%>
														</td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB1 DIV END HERE-->
</div>
<%
//}
%>



<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("camaSize",""+iCama.size())%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benSize",""+iBen.size())%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respSize",""+iResp.size())%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimiento()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="39">Diagn&oacute;sticos</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel21">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="15%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td width="60%"><cellbytelabel id="2">Nombre</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="40">Prioridad</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="16">Tipo</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addDiagnostico","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Diagnósticos")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iDiag);
for (int i=1; i<=iDiag.size(); i++)
{
	key = al.get(i - 1).toString();
	Admision obj = (Admision) iDiag.get(key);
%>
						<%=fb.hidden("key"+i,obj.getKey())%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("diagnostico"+i,obj.getDiagnostico())%>
						<%=fb.hidden("diagnosticoDesc"+i,obj.getDiagnosticoDesc())%>
						<%=fb.hidden("usuarioCreacion"+i,obj.getUsuarioCreacion())%>
						<%=fb.hidden("fechaCreacion"+i,obj.getFechaCreacion())%>
						<%=fb.hidden("usuarioModifica"+i,obj.getUsuarioModifica())%>
						<%=fb.hidden("fechaModifica"+i,obj.getFechaModifica())%>
						<tr class="TextRow01">
							<td><%=obj.getDiagnostico()%></td>
							<td><%=obj.getDiagnosticoDesc()%></td>
							<td align="center"><%=fb.intBox("ordenDiag"+i,obj.getOrdenDiag(),true,false,viewMode,2)%></td>
							<td align="center"><%=fb.select("tipo"+i,"I=INGRESO,S=SALIDA",obj.getTipo(),false,viewMode,0)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diagnóstico")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB2 DIV END HERE-->
</div>


<%
//if (!adm.getCategoria().equals("3") && !adm.getCategoria().equals("4")){
%>
<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("camaSize",""+iCama.size())%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benSize",""+iBen.size())%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respSize",""+iResp.size())%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel30">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimiento()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="75%">&nbsp;<cellbytelabel id="41">Documentos</cellbytelabel></td>
							<td width="20%"><%//=fb.button("verScan",(mode.equals("edit")?"Agregar Escanedos":"Ver Escanedos"),false, false,null,null,"onClick=\"javascript:viewScan()\"")%></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel31">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td width="75%"><cellbytelabel id="2">Nombre</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="42">Verificado</cellbytelabel></td>
							<td width="5%"><%=fb.submit("addDocumento","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Documentos")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iDoc);
for (int i=1; i<=iDoc.size(); i++)
{
	key = al.get(i - 1).toString();
	Admision obj = (Admision) iDoc.get(key);
%>
						<%=fb.hidden("key"+i,obj.getKey())%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("documento"+i,obj.getDocumento())%>
						<%=fb.hidden("documentoDesc"+i,obj.getDocumentoDesc())%>
						<%=fb.hidden("usuarioCreacion"+i,obj.getUsuarioCreacion())%>
						<%=fb.hidden("fechaCreacion"+i,obj.getFechaCreacion())%>
						<%=fb.hidden("usuarioModifica"+i,obj.getUsuarioModifica())%>
						<%=fb.hidden("fechaModifica"+i,obj.getFechaModifica())%>
						<%=fb.hidden("revisadoSala"+i,obj.getRevisadoSala())%>
						<%=fb.hidden("revisadoFac"+i,obj.getRevisadoFac())%>
						<%=fb.hidden("revisadoCob"+i,obj.getRevisadoCob())%>
						<%=fb.hidden("observacion"+i,obj.getObservacion())%>
						<%=fb.hidden("estado"+i,obj.getEstado())%>
						<%=fb.hidden("userEntrega"+i,obj.getUserEntrega())%>
						<%=fb.hidden("userRecibe"+i,obj.getUserRecibe())%>
						<%=fb.hidden("fechaEntrega"+i,obj.getFechaEntrega())%>
						<%=fb.hidden("fechaRecibe"+i,obj.getFechaRecibe())%>
						<%=fb.hidden("areaEntrega"+i,obj.getAreaEntrega())%>
						<%=fb.hidden("areaRecibe"+i,obj.getAreaRecibe())%>
						<%=fb.hidden("pase"+i,obj.getPase())%>
						<%=fb.hidden("paseK"+i,obj.getPaseK())%>



						<tr class="TextRow01">
							<td><%=obj.getDocumento()%></td>
							<td><%=obj.getDocumentoDesc()%></td>
							<td align="center"><%=fb.checkbox("revisadoAdmision"+i,"S",(obj.getRevisadoAdmision() != null && obj.getRevisadoAdmision().equalsIgnoreCase("S")),viewMode)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Documento")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB3 DIV END HERE-->
</div>
<%
//}
%>


<!-- TAB4 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","4")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("camaSize",""+iCama.size())%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benSize",""+iBen.size())%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respSize",""+iResp.size())%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
<%fb.appendJsValidation("if(isAdmisionInactive())error++;");%>
<%fb.appendJsValidation("if(chkBeneficioSol())error++;");%>
<%//fb.appendJsValidation("if(!pendingBalanceConfirmation(4))error++;");//Commented by Jacinto Man Chen 20081015 - only for add mode%>
<%=fb.hidden("proceedPendingBalance","")%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(40)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus40" style="display:none">+</label><label id="minus40">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel40">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimiento()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(41)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="43">Beneficios Asignados</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus41" style="display:none">+</label><label id="minus41">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel41">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel id="12">No.</cellbytelabel></td>
							<td width="36%"><cellbytelabel id="44">Aseguradora</cellbytelabel></td>
							<td width="24%"><cellbytelabel id="45">P&oacute;liza</cellbytelabel></td>
							<td width="15%"><cellbytelabel id="46">Certificado</cellbytelabel></td>
							<td width="7%"><cellbytelabel id="40">Prioridad</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="13">Estado</cellbytelabel></td>
							<td width="3%"><%=fb.submit("addBeneficio","+",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Beneficios")%></td>
						</tr>
<%
String jsValidation = "";
al = CmnMgr.reverseRecords(iBen);
for (int i=1; i<=iBen.size(); i++)
{
	key = al.get(i - 1).toString();
	Admision obj = (Admision) iBen.get(key);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";
	fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'&&(document."+fb.getFormName()+".poliza"+i+".value==''||document."+fb.getFormName()+".prioridad"+i+".value==''))return true;");
	String displayBen = "";
	if (obj.getStatus() != null && obj.getStatus().equalsIgnoreCase("D")){ displayBen = " style=\"display:none\""; }
	else if (obj.getEstado() != null && !obj.getEstado().equalsIgnoreCase("I")) prioridad++;
%>
						<%=fb.hidden("key"+i,obj.getKey())%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("secuencia"+i,obj.getSecuencia())%>
						<%=fb.hidden("convenioSolicitud"+i,obj.getConvenioSolicitud())%>
						<%=fb.hidden("plan"+i,obj.getPlan())%>
						<%=fb.hidden("convenio"+i,obj.getConvenio())%>
						<%=fb.hidden("empresa"+i,obj.getEmpresa())%>
						<%=fb.hidden("categoriaAdmi"+i,obj.getCategoriaAdmi())%>
						<%=fb.hidden("tipoAdmi"+i,obj.getTipoAdmi())%>
						<%=fb.hidden("clasifAdmi"+i,obj.getClasifAdmi())%>
						<%=fb.hidden("tipoPoliza"+i,obj.getTipoPoliza())%>
						<%=fb.hidden("tipoPlan"+i,obj.getTipoPlan())%>
						<%=fb.hidden("nombrePlan"+i,obj.getNombrePlan())%>
						<%=fb.hidden("nombreConvenio"+i,obj.getNombreConvenio())%>
						<%=fb.hidden("nombreEmpresa"+i,obj.getNombreEmpresa())%>
						<%=fb.hidden("nombreTipoPlan"+i,obj.getNombreTipoPlan())%>
						<%=fb.hidden("nombreTipoPoliza"+i,obj.getNombreTipoPoliza())%>
						<%=fb.hidden("clasifAdmiDesc"+i,obj.getClasifAdmiDesc())%>
						<%=fb.hidden("tipoAdmiDesc"+i,obj.getTipoAdmiDesc())%>
						<%=fb.hidden("categoriaAdmiDesc"+i,obj.getCategoriaAdmiDesc())%>
						<%=fb.hidden("status"+i,obj.getStatus())%>
						<tr class="<%=color%>"<%=displayBen%>>
							<td><%=obj.getSecuencia()%></td>
							<td>[<label id="_lblEmpresa<%=i%>"><%=obj.getEmpresa()%></label>] <label id="_lblNombreEmpresa<%=i%>"><%=obj.getNombreEmpresa()%></label></td>
							<td align="center">
								<%=fb.textBox("poliza"+i,obj.getPoliza(),(!obj.getStatus().trim().equals("D")),false,((viewMode && !fg.equalsIgnoreCase("con_sup")) || obj.getEmpresa().equals("81")),30,30,"Text10",null,null)%>
								<%=fb.button("btnEmpleado","...",true,((viewMode && !fg.equalsIgnoreCase("con_sup")) || !obj.getEmpresa().equals("81")),"Text10",null,"onClick=\"javascript:showEmpleadoList('beneficio',"+i+")\"")%>
							</td>
							<td align="center"><%=fb.textBox("certificado"+i,obj.getCertificado(),false,false,(viewMode && !fg.equalsIgnoreCase("con_sup")),20,20,"Text10",null,null)%></td>
							<td align="center"><%=fb.intBox("prioridad"+i,(obj.getPrioridad() != null && !obj.getPrioridad().trim().equals("")&&(obj.getSecuencia() != null && !obj.getSecuencia().equals("0")))?obj.getPrioridad():""+prioridad,(!obj.getStatus().trim().equals("D")),false,(viewMode && !fg.equalsIgnoreCase("con_sup")),2,2,"Text10",null,"onBlur=\"javascript:isValidPriority()\"")%></td>
							<td align="center"><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",obj.getEstado(),false,(viewMode && !fg.equalsIgnoreCase("con_sup")),0,"Text10",null,"onChange=\"javascript:confirmBenefitStatus("+i+")\"")%></td>
							<td rowspan="2" align="center"><%=(obj.getSecuencia() != null && obj.getSecuencia().equals("0"))?fb.submit("rem"+i,"X",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Beneficio"):""%></td>
						</tr>
						<tr class="<%=color%>"<%=displayBen%>>
							<td colspan="6">
								<table width="100%" cellpadding="1" cellspacing="0">
								<tr class="<%=color%>">
									<td width="10%" align="right"><cellbytelabel id="47">Tipo P&oacute;liza</cellbytelabel>:</td>
									<td width="20%">[<label id="_lblTipoPoliza<%=i%>"><%=obj.getTipoPoliza()%></label>] <label id="_lblNombreTipoPoliza<%=i%>"><%=obj.getNombreTipoPoliza()%></label></td>
									<td width="10%" align="right"><cellbytelabel id="48">Tipo Plan</cellbytelabel>:</td>
									<td width="25%">[<label id="_lblTipoPlan<%=i%>"><%=obj.getTipoPlan()%></label>] <label id="_lblNombreTipoPlan<%=i%>"><%=obj.getNombreTipoPlan()%></label></td>
									<td width="10%" align="right"><cellbytelabel id="49">Plan Asig.</cellbytelabel>:</td>
									<td width="25%">[<label id="_lblPlan<%=i%>"><%=obj.getPlan()%></label>] <label id="_lblNombrePlan<%=i%>"><%=obj.getNombrePlan()%></label></td>
								</tr>
								<tr class="<%=color%>">
									<td align="right"><cellbytelabel id="50">Cat. Adm.</cellbytelabel>:</td>
									<td>[<label id="_lblCategoriaAdmi<%=i%>"><%=obj.getCategoriaAdmi()%></label>] <label id="_lblCategoriaAdmiDesc<%=i%>"><%=obj.getCategoriaAdmiDesc()%></label></td>
									<td align="right"><cellbytelabel id="51">Tipo Adm.</cellbytelabel>:</td>
									<td>[<label id="_lblTipoAdmi<%=i%>"><%=obj.getTipoAdmi()%></label>] <label id="_lblTipoAdmiDesc<%=i%>"><%=obj.getTipoAdmiDesc()%></label></td>
									<td align="right"><cellbytelabel id="52">Clasificaci&oacute;n</cellbytelabel>:</td>
									<td>[<label id="_lblClasifAdmi<%=i%>"><%=obj.getClasifAdmi()%></label>] <label id="_lblClasifAdmiDesc<%=i%>"><%=obj.getClasifAdmiDesc()%></label></td>
								</tr>
								<tr class="<%=color%>">
<%
if (fg.equalsIgnoreCase("con_sup2"))
{
%>
									<td colspan="4" rowspan="3">
										<table width="100%" cellpadding="1" cellspacing="1" class="TableBorder">
										<tr align="center">
											<td class="TextHeader Text10" colspan="2"><cellbytelabel id="53">I M P O R T A N T E</cellbytelabel> :</td>
										</tr>
										<tr>
											<td class="TextHeader Text10" width="35%" align="right"><cellbytelabel id="54">Asignaci&oacute;n de Rangos de Fecha a los Planes</cellbytelabel>:</td>
											<td width="65%">
												<cellbytelabel id="55">Fecha</cellbytelabel>
												<jsp:include page="../common/calendar.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="2"/>
												<jsp:param name="clearOption" value="true"/>
												<jsp:param name="format" value="dd/mm/yyyy"/>
												<jsp:param name="nameOfTBox1" value="<%="fechaIni"+i%>"/>
												<jsp:param name="valueOfTBox1" value="<%=obj.getFechaIni()%>"/>
												<jsp:param name="nameOfTBox2" value="<%="fechaFin"+i%>"/>
												<jsp:param name="valueOfTBox2" value="<%=obj.getFechaFin()%>"/>
												<jsp:param name="readonly" value="<%=(viewMode && !fg.equalsIgnoreCase("con_sup"))?"y":"n"%>"/>
												<jsp:param name="fieldClass" value="Text10"/>
												<jsp:param name="buttonClass" value="Text10"/>
												</jsp:include>
											</td>
										</tr>
										<tr>
											<td class="TextHeader Text10" align="right"><cellbytelabel id="56">Para uso del Depto. de Cobros</cellbytelabel>:</td>
											<td>
												<%=fb.checkbox("pacAsumeCargos"+i,"S",(obj.getPacAsumeCargos() != null && obj.getPacAsumeCargos().equalsIgnoreCase("S")),(viewMode && !fg.equalsIgnoreCase("con_sup")),null,null,"")%>
												<cellbytelabel id="57">Cargar D&iacute;as fuera de Cob. a PACIENT</cellbytelabel>E<br>
												<%=fb.checkbox("clinicaAsumeCargos"+i,"S",(obj.getClinicaAsumeCargos() != null && obj.getClinicaAsumeCargos().equalsIgnoreCase("S")),(viewMode && !fg.equalsIgnoreCase("con_sup")),null,null,"")%>
												<cellbytelabel id="58">Cargar D&iacute;as fuera de Cob. a CLINICA</cellbytelabel>
											</td>
										</tr>
										</table>
									</td>
<%
}
else
{
%>
						<%=fb.hidden("fechaIni"+i,obj.getFechaIni())%>
						<%=fb.hidden("fechaFin"+i,obj.getFechaFin())%>
						<%=fb.hidden("pacAsumeCargos"+i,obj.getPacAsumeCargos())%>
						<%=fb.hidden("clinicaAsumeCargos"+i,obj.getClinicaAsumeCargos())%>
<%
}
%>
									<td align="center" colspan="2">
										<cellbytelabel id="59">Doble Cobertura?</cellbytelabel>
										<%=fb.checkbox("convenioSolEmp"+i,"S",(obj.getConvenioSolEmp() != null && obj.getConvenioSolEmp().equalsIgnoreCase("S")),(viewMode && !fg.equalsIgnoreCase("con_sup")),null,null,"onClick=\"javascript:isFirstPriority("+i+")\"")%>
									</td>
<%
if (fg.equalsIgnoreCase("con_sup2"))
{
%>
								</tr>
								<tr class="<%=color%>">
<%
}
%>
									<td align="center" colspan="2">
										<!--No. Aprob. AXA-->
										<%//=fb.intBox("numAprobacion"+i,obj.getNumAprobacion(),false,false,(viewMode && !fg.equalsIgnoreCase("con_sup")),10,10)%>
									</td>
<%
if (fg.equalsIgnoreCase("con_sup2"))
{
%>
								</tr>
								<tr class="<%=color%>">
<%
}
%>
									<td align="center" colspan="2">
										<%=(obj.getSecuencia() != null && !obj.getSecuencia().trim().equals("") && !obj.getSecuencia().equals("0"))?fb.button("solBeneficio"+i,"Benef. adm. ant",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),"Text10",null,"onClick=\"javascript:addBenefAnterior('"+i+"',this.value)\"","Aplicar Beneficios adm. anterior"):""%>
										<%=(obj.getSecuencia() != null && !obj.getSecuencia().trim().equals("") && !obj.getSecuencia().equals("0"))?fb.button("solBeneficio"+i,"Solicitud De Benef.",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),"Text10",null,"onClick=\"javascript:showBeneficioSol('"+i+"',this.value)\"","Solicitar Beneficios"):""%>
									</td>
								</tr>
								</table>
							</td>
						</tr>
<%
//  jsValidation += "if(document."+fb.getFormName()+".poliza"+i+".value=='')error--;";
//  jsValidation += "if(document."+fb.getFormName()+".prioridad"+i+".value=='')error--;";
}
//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+jsValidation+"}");
fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&!isValidPriority())error++;");
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,(viewMode && !fg.equalsIgnoreCase("con_sup")),false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB4 DIV END HERE-->
</div>



<!-- TAB5 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","5")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("camaSize",""+iCama.size())%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benSize",""+iBen.size())%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respSize",""+iResp.size())%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(50)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus50" style="display:none">+</label><label id="minus50">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel50">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimiento()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(51)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="60">Responsables</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus51" style="display:none">+</label><label id="minus51">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel51">
					<td>
						<table width="100%" cellpadding="0" cellspacing="0">
						<tr>
							<td>
								<table width="100%" cellpadding="1" cellspacing="1">
								<tr class="TextHeader" align="center">
									<td width="12%"><cellbytelabel id="61">Tipo de Identificaci&oacute;n</cellbytelabel></td>
									<td width="15%"><cellbytelabel id="62">Identificaci&oacute;n</cellbytelabel></td>
									<td width="13%"><cellbytelabel id="63">No. S.S.</cellbytelabel></td>
									<td width="50%"><cellbytelabel id="64">Nombre Completo</cellbytelabel></td>
									<td width="5%"><cellbytelabel id="65">Sexo</cellbytelabel></td>
									<td width="5%" align="center"><%=(iResp.size() < 1)?fb.submit("addResponsable","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Responsables"):""%></td>
								</tr>
<%
al = CmnMgr.reverseRecords(iResp);
for (int i=1; i<=iResp.size(); i++)
{
	key = al.get(i - 1).toString();
	Admision obj = (Admision) iResp.get(key);
	String panelId = "Audit51."+i;
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";
%>
								<%=fb.hidden("key"+i,obj.getKey())%>
								<%=fb.hidden("remove"+i,"")%>
								<%=fb.hidden("usuarioCreacion"+i,obj.getUsuarioCreacion())%>
								<%=fb.hidden("fechaCreacion"+i,obj.getFechaCreacion())%>
								<%=fb.hidden("usuarioModifica"+i,obj.getUsuarioModifica())%>
								<%=fb.hidden("fechaModifica"+i,obj.getFechaModifica())%>
								<tr class="<%=color%>" align="center">
									<td><%=fb.select("tipoIdentificacion"+i,(adm.getResponsabilidad() != null && adm.getResponsabilidad().equalsIgnoreCase("E"))?"R=RUC":"R=RUC,C=CEDULA,P=PASAPORTE,O=OTRO",obj.getTipoIdentificacion(),false,viewMode,0,"Text10",null,null)%></td>
									<td><%=fb.textBox("identificacion"+i,obj.getIdentificacion(),true,false,viewMode,20,30,"Text10",null,null)%></td>
									<td><%=fb.textBox("seguroSocial"+i,obj.getSeguroSocial(),false,false,viewMode,15,13,"Text10",null,null)%></td>
									<td><%=fb.textBox("nombre"+i,obj.getNombre(),true,false,viewMode,80,100,"Text10",null,null)%></td>
									<td><%=fb.select("sexo"+i,"M,F",obj.getSexo(),false,viewMode,0,"Text10",null,null,null,"S")%></td>
									<td align="center" rowspan="2"><%=(iResp.size() > 1)?fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Responsable"):""%></td>
								</tr>
								<tr class="<%=color%>">
									<td colspan="2">
										<cellbytelabel id="66">C&oacute;d. Empresa</cellbytelabel>
										<%=fb.intBox("empresa"+i,obj.getEmpresa(),false,false,true,5,"Text10",null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','empresa"+i+"');\"")%>
										<%=fb.button("btnEmpresa","...",false,viewMode,"Text10",null,"onClick=\"javascript:showEmpresaList("+i+")\"")%>
										<br>
										<cellbytelabel id="67">C&oacute;d. M&eacute;dico</cellbytelabel>
										<%=fb.textBox("medico"+i,obj.getMedico(),false,false,true,15,"Text10",null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','medico"+i+"');\"")%>
										<%=fb.button("btnMedico","...",false,viewMode,"Text10",null,"onClick=\"javascript:showMedicoList('responsable',"+i+")\"")%>
										<br>
										<cellbytelabel id="68">C&oacute;d. Empleado</cellbytelabel>
										<%=fb.textBox("numEmpleado"+i,obj.getNumEmpleado(),false,false,true,15,"Text10",null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','numEmpleado"+i+"');\"")%>
										<%=fb.button("btnEmpleado","...",false,viewMode,"Text10",null,"onClick=\"javascript:showEmpleadoList('responsable',"+i+")\"")%>
									</td>
									<td colspan="2">
										<cellbytelabel id="69">Parentesco</cellbytelabel>
										<%=fb.textBox("parentesco"+i,obj.getParentesco(),false,false,viewMode,30,30,"Text10",null,null)%>
										<cellbytelabel id="70">Es el Principal de la p&oacute;liza?</cellbytelabel>
										<%=fb.checkbox("principal"+i,"S",(obj.getPrincipal() != null && obj.getPrincipal().equalsIgnoreCase("S")),viewMode)%>
										<br>
										<cellbytelabel id="71">Nacionalidad</cellbytelabel>
										<%=fb.intBox("nacionalidad"+i,obj.getNacionalidad(),false,false,true,5,"Text10",null,null)%>
										<%=fb.textBox("nacionalidadDesc"+i,obj.getNacionalidadDesc(),false,false,true,40,"Text10",null,null)%>
										<%=fb.button("btnNacionalidad","...",false,viewMode,"Text10",null,"onClick=\"javascript:showNacionalidadList("+i+")\"")%>
										<br>
										<cellbytelabel id="72">Lugar de Nacimiento</cellbytelabel>
										<%=fb.textBox("lugarNac"+i,obj.getLugarNac(),false,false,viewMode,75,100,"Text10",null,null)%>
									</td>
									<td align="center" onClick="javascript:showHide('51.<%=i%>')" style="text-decoration:none; cursor:pointer" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
										<i><label id="plus51.<%=i%>" style="display:none">+</label><label id="minus51.<%=i%>">-</label> <cellbytelabel id="71">Detalles</cellbytelabel></i>
									</td>
								</tr>
								<tr id="panel51.<%=i%>" style="display:none">
									<td colspan="6">
										<table width="100%" cellpadding="0" cellspacing="0">
										<tr>
											<td onClick="javascript:showHide('51.<%=i%>.0')" style="text-decoration:none; cursor:pointer">
												<table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel" height="25">
													<td width="95%">&nbsp;<cellbytelabel id="72">Ingresos</cellbytelabel></td>
													<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus51.<%=i%>.0" style="display:none">+</label><label id="minus51.<%=i%>.0">-</label></font>]&nbsp;</td>
												</tr>
												</table>
											</td>
										</tr>
										<tr id="panel51.<%=i%>.0">
											<td>
												<table width="100%" cellpadding="1" cellspacing="1">
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="73">Lugar de Trabajo</cellbytelabel></td>
													<td colspan="3"><%=fb.textBox("lugarDeTrabajo"+i,obj.getLugarDeTrabajo(),false,false,viewMode,80,80,"Text10",null,null)%></td>
												</tr>
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="74">Puesto que ocupa</cellbytelabel></td>
													<td colspan="3"><%=fb.textBox("puestoQueOcupa"+i,obj.getPuestoQueOcupa(),false,false,viewMode,80,80,"Text10",null,null)%></td>
												</tr>
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="75">Direcci&oacute;n del Trabajo</cellbytelabel></td>
													<td colspan="3"><%=fb.textBox("direccionTrabajo"+i,obj.getDireccionTrabajo(),false,false,viewMode,80,100,"Text10",null,null)%></td>
												</tr>
												<tr class="<%=color%>">
													<td width="15%" align="right"><cellbytelabel id="76">Tel&eacute;fono del Trabajo</cellbytelabel></td>
													<td width="35%"><%=fb.textBox("telefonoDeTrabajo"+i,obj.getTelefonoDeTrabajo(),false,false,viewMode,15,13,"Text10",null,null)%></td>
													<td width="15%" align="right"><cellbytelabel id="77">Extensi&oacute;n Telef&oacute;nica</cellbytelabel></td>
													<td width="35%"><%=fb.textBox("extension"+i,obj.getExtension(),false,false,viewMode,10,6,"Text10",null,null)%></td>
												</tr>
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="78">A&ntilde;os Laborados</cellbytelabel></td>
													<td><%=fb.intBox("aniosLaborados"+i,obj.getAniosLaborados(),false,false,viewMode,5,2,"Text10",null,null)%></td>
													<td align="right"><cellbytelabel id="79">Meses Laborados</cellbytelabel></td>
													<td><%=fb.intBox("mesesLaborados"+i,obj.getMesesLaborados(),false,false,viewMode,5,2,"Text10",null,null)%></td>
												</tr>
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="80">Ingreso Mensual</cellbytelabel></td>
													<td><%=fb.decBox("ingresoMensual"+i,obj.getIngresoMensual(),false,false,viewMode,15,8.2,"Text10",null,null)%></td>
													<td align="right"><cellbytelabel id="81">Otros Ingresos</cellbytelabel></td>
													<td><%=fb.decBox("otrosIngresos"+i,obj.getOtrosIngresos(),false,false,viewMode,15,8.2,"Text10",null,null)%></td>
												</tr>
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="82">Fuente de otros ingresos</cellbytelabel></td>
													<td colspan="3"><%=fb.textBox("fuenteOtrosIngresos"+i,obj.getFuenteOtrosIngresos(),false,false,viewMode,80,100,"Text10",null,null)%></td>
												</tr>
												</table>
											</td>
										</tr>

										<tr>
											<td onClick="javascript:showHide('51.<%=i%>.1')" style="text-decoration:none; cursor:pointer">
												<table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel" height="25">
													<td width="95%">&nbsp;<cellbytelabel id="83">Generales</cellbytelabel></td>
													<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus51.<%=i%>.1" style="display:none">+</label><label id="minus51.<%=i%>.1">-</label></font>]&nbsp;</td>
												</tr>
												</table>
											</td>
										</tr>
										<tr id="panel51.<%=i%>.1">
											<td>
												<table width="100%" cellpadding="1" cellspacing="1">
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="84">Direcci&oacute;n Residencial</cellbytelabel></td>
													<td colspan="3"><%=fb.textBox("direccion"+i,obj.getDireccion(),false,false,viewMode,80,100,"Text10",null,null)%></td>
												</tr>
												<tr class="<%=color%>">
													<td width="15%" align="right"><cellbytelabel id="85">Pa&iacute;s</cellbytelabel></td>
													<td width="35%">
														<%=fb.intBox("pais"+i,obj.getPais(),false,false,true,4,"Text10",null,null)%>
														<%=fb.textBox("nombrePais"+i,obj.getNombrePais(),false,false,true,40,"Text10",null,null)%>
														<%=fb.button("btnUbicacionGeo","...",false,viewMode,"Text10",null,"onClick=\"javascript:showUbicacionGeoList("+i+")\"")%>
													</td>
													<td width="15%" align="right"><cellbytelabel id="86">Provincia</cellbytelabel></td>
													<td width="35%">
														<%=fb.intBox("provincia"+i,obj.getProvincia(),false,false,true,2,"Text10",null,null)%>
														<%=fb.textBox("nombreProvincia"+i,obj.getNombreProvincia(),false,false,true,40,"Text10",null,null)%>
													</td>
												</tr>
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="87">Distrito</cellbytelabel></td>
													<td>
														<%=fb.intBox("distrito"+i,obj.getDistrito(),false,false,true,3,"Text10",null,null)%>
														<%=fb.textBox("nombreDistrito"+i,obj.getNombreDistrito(),false,false,true,40,"Text10",null,null)%>
													</td>
													<td align="right"><cellbytelabel id="88">Corregimiento</cellbytelabel></td>
													<td>
														<%=fb.intBox("corregimiento"+i,obj.getCorregimiento(),false,false,true,4,"Text10",null,null)%>
														<%=fb.textBox("nombreCorregimiento"+i,obj.getNombreCorregimiento(),false,false,true,40,"Text10",null,null)%>
													</td>
												</tr>
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="89">Comunidad</cellbytelabel></td>
													<td>
														<%=fb.intBox("comunidad"+i,obj.getComunidad(),false,false,true,6,"Text10",null,null)%>
														<%=fb.textBox("nombreComunidad"+i,obj.getNombreComunidad(),false,false,true,40,"Text10",null,null)%>
													</td>
													<td align="right"><cellbytelabel id="90">Correo Electr&oacute;nico</cellbytelabel></td>
													<td><%=fb.textBox("eMail"+i,obj.getEMail(),false,false,viewMode,50,100,"Text10",null,null)%></td>
												</tr>
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="91">Tel&eacute;fono Residencial</cellbytelabel></td>
													<td><%=fb.textBox("tel_responsable"+i,obj.getTelefonoResidencia(),false,false,viewMode,15,13,"Text10",null,null)%></td>
													<td align="right"><cellbytelabel id="92">Fax</cellbytelabel></td>
													<td><%=fb.textBox("fax"+i,obj.getFax(),false,false,viewMode,15,13,"Text10",null,null)%></td>
												</tr>
												<tr class="<%=color%>">
													<td align="right"><cellbytelabel id="93">Zona Postal</cellbytelabel></td>
													<td><%=fb.textBox("zonaPostal"+i,obj.getZonaPostal(),false,false,viewMode,20,20,"Text10",null,null)%></td>
													<td align="right"><cellbytelabel id="94">Apartado Postal</cellbytelabel></td>
													<td><%=fb.textBox("apartadoPostal"+i,obj.getApartadoPostal(),false,false,viewMode,20,20,"Text10",null,null)%></td>
												</tr>
												</table>
											</td>
										</tr>

										<tr>
											<td onClick="javascript:showHide('51.<%=i%>.2')" style="text-decoration:none; cursor:pointer">
												<table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel" height="25">
													<td width="95%">&nbsp;<cellbytelabel id="95">Observaci&oacute;n</cellbytelabel></td>
													<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus51.<%=i%>.2" style="display:none">+</label><label id="minus51.<%=i%>.2">-</label></font>]&nbsp;</td>
												</tr>
												</table>
											</td>
										</tr>
										<tr id="panel51.<%=i%>.2">
											<td>
												<table width="100%" cellpadding="1" cellspacing="1">
												<tr class="<%=color%>">
													<td width="15%" align="right"><cellbytelabel id="96">Observaciones</cellbytelabel></td>
													<td width="85%" colspan="3"><%=fb.textarea("observacion"+i,obj.getObservacion(),false,false,viewMode,80,5)%></td>
												</tr>
												</table>
											</td>
										</tr>

										<tr>
											<td>
<jsp:include page="../common/bitacora.jsp" flush="true">
	<jsp:param name="panelId" value="<%=panelId%>"></jsp:param>
	<jsp:param name="panelTitleClass" value="TextPanel"></jsp:param>
	<jsp:param name="panelDetailClass" value="<%=color%>"></jsp:param>
	<jsp:param name="audTable" value="tbl_adm_responsable"></jsp:param>
	<jsp:param name="audFilter" value="<%="admision="+adm.getNoAdmision()+" and pac_id="+adm.getPacId()%>"></jsp:param>
</jsp:include>
											</td>
										</tr>
										</table>
									</td>
								</tr>
<%
}
%>
								</table>
							</td>
						</tr>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div>



<!-- TAB6 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","6")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("camaSize",""+iCama.size())%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benSize",""+iBen.size())%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respSize",""+iResp.size())%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
<%=fb.hidden("docTypeSize",""+alDoc.size())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel60">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimiento()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(61)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="41">Documentos</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus61" style="display:none">+</label><label id="minus61">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel61">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="15%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td width="75%"><cellbytelabel id="97">Descripci&oacute;n</cellbytelabel></td>
							<td width="10%"><%=fb.checkbox("check","",false,viewMode,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','checked',"+alDoc.size()+",this)\"","Seleccionar todas los documentos listados!")%></td>
						</tr>
<%
String groupBy = "";
for (int i=0; i<alDoc.size(); i++)
{
	CommonDataObject obj = (CommonDataObject) alDoc.get(i);
	if (!groupBy.equalsIgnoreCase(obj.getColValue("display_area")))
	{
%>
						<tr class="TextHeader01">
							<td colspan="3"><%=obj.getColValue("display_area")%></td>
						</tr>
<%
	}
%>
						<%=fb.hidden("id"+i,obj.getColValue("id"))%>
						<%=fb.hidden("description"+i,obj.getColValue("description"))%>
						<%=fb.hidden("display_area"+i,obj.getColValue("display_area"))%>
						<tr class="TextRow01">
							<td><%=obj.getColValue("id")%></td>
							<td><%=obj.getColValue("description")%></td>
							<td align="center"><%=fb.checkbox("checked"+i,"Y",obj.getColValue("checked").equalsIgnoreCase("Y"),viewMode)%></td>
						</tr>
<%
	groupBy = obj.getColValue("display_area");
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB6 DIV END HERE-->
</div>



<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Admisión','Camas','Diagnóstico','Documentos','Beneficios','Responsable'";
String tabInactivo ="";
if (mode.equalsIgnoreCase("add"))tabInactivo ="1,2,3,4,5,6";
else if (adm.getCategoria().equals("2") || adm.getCategoria().equals("3"))tabInactivo="1";
else if (adm.getCategoria().equals("4"))tabInactivo="1,3";
/*
if (!mode.equalsIgnoreCase("add"))
{
	//2=Urgencia
	if (!adm.getCategoria().equals("2") && !adm.getCategoria().equals("4"))
		tabLabel += ",'Camas','Diagnóstico','Documentos'";
	else
	{
		tabLabel += ",'Diagnóstico'";
		if (adm.getCategoria().equals("2")){
			tabLabel += ",'Documentos'";
		}
		if (tab.equals("2")) tab = ""+(Integer.parseInt(tab)-1);
		else if (Integer.parseInt(tab) > 3) tab = ""+(Integer.parseInt(tab)-2);
	}
	tabLabel += ",'Beneficios','Responsable'";

}*/
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','','','','',[<%=tabInactivo%>]);
</script>

			</td>
			<td width="20%" class="TableLeftBorder" style="vertical-align:top; padding-top:21px; display:none; cursor:pointer;" id="container">
				<div id="pacInfoWrapper" style="text-align:center; height:500px; overflow-y:scroll;">
					 <span id="indicator" style="display:none">
					<img src="../images/loading-bar2.gif" alt="Loading" />
				 </span>
				</div>
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
	String errCode = "";
	String errMsg = "";

	adm = new Admision();
	adm.setPacId(request.getParameter("pacId"));
	adm.setNoAdmision(request.getParameter("noAdmision"));
	adm.setFechaNacimiento(request.getParameter("fechaNacimiento"));
	adm.setCodigoPaciente(request.getParameter("codigoPaciente"));
	adm.setCompania((String) session.getAttribute("_companyId"));
	adm.setUsuarioModifica((String) session.getAttribute("_userName"));
	if (tab.equals("0")) //ADMISION
	{
		adm.setNombrePaciente(request.getParameter("nombrePaciente"));
		adm.setProvincia(request.getParameter("provincia").trim());
		adm.setSigla(request.getParameter("sigla").trim());
		adm.setTomo(request.getParameter("tomo").trim());
		adm.setAsiento(request.getParameter("asiento").trim());
		adm.setDCedula(request.getParameter("dCedula"));
		adm.setPasaporte(request.getParameter("pasaporte").trim());
		adm.setResponsabilidad(request.getParameter("responsabilidad"));
		adm.setMedico(request.getParameter("medico"));
		adm.setNombreMedico(request.getParameter("nombreMedico"));
		adm.setEspecialidad(request.getParameter("especialidad"));
		adm.setMedicoCabecera(request.getParameter("medicoCabecera"));
		adm.setNombreMedicoCabecera(request.getParameter("nombreMedicoCabecera"));
		adm.setEstado(request.getParameter("estado"));
		adm.setCategoria(request.getParameter("categoria"));
		adm.setCategoriaDesc(request.getParameter("categoriaDesc"));
		adm.setCentroServicio(request.getParameter("centroServicio"));
		adm.setCentroServicioDesc(request.getParameter("centroServicioDesc"));
		adm.setTipoAdmision(request.getParameter("tipoAdmision"));
		adm.setTipoAdmisionDesc(request.getParameter("tipoAdmisionDesc"));
		adm.setDiasEstimados(request.getParameter("diasEstimados"));
		adm.setContaCred(request.getParameter("contaCred"));
		adm.setTipoCta(request.getParameter("tipoCta"));
		adm.setHospDirecta(request.getParameter("hospDirecta"));
		adm.setMesCtaBolsa(request.getParameter("mesCtaBolsa"));
		adm.setOc(request.getParameter("oc"));
		adm.setObservAdm(request.getParameter("observAdm"));
		adm.setCondicionPaciente(request.getParameter("condPaciente"));

		//Asigna fecha de egreso para admisiones ambulatorias, EXCLUYE HEMODIALISIS
		if (((adm.getCategoria().equals("2") && !adm.getTipoAdmision().equals("6")) || adm.getCategoria().equals("4")) && mode.equals("add")) adm.setFechaEgreso(CmnMgr.getCurrentDate("dd/mm/yyyy"));
		if(mode.equalsIgnoreCase("edit") && request.getParameter("fechaEgreso")!=null && !request.getParameter("fechaEgreso").equals("")) adm.setFechaEgreso(request.getParameter("fechaEgreso"));

		if (((adm.getCategoria().equals("2") && !adm.getTipoAdmision().equals("6")) || adm.getCategoria().equals("4")) && mode.equals("edit") && adm.getEstado().equals("A")){}
		else if (mode.equals("edit") && adm.getEstado().equals("A")) adm.setFechaEgreso("");

		adm.setFechaPreadmision(request.getParameter("fechaPreadmision"));// --> sysdate (DD-MM-YYYY HH12:MI AM)

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg+"&mode="+mode);
		if (mode.equalsIgnoreCase("add"))
		{
			adm.setUsuarioCreacion((String) session.getAttribute("_userName"));

			//default values from ADM3309
			adm.setFechaIngreso(request.getParameter("fechaIngreso"));// --> sysdate (DD-MM-YYYY)
			adm.setAmPm(request.getParameter("amPm"));// --> sysdate (HH12:MI AM)
			adm.setAdmitidoPor("M");
			adm.setUnidadOrgni("1");
			adm.setProceedPendingBalance(request.getParameter("proceedPendingBalance"));

			AdmMgr.add(adm);
			noAdmision = AdmMgr.getPkColValue("noAdmision");
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			if (fg.equalsIgnoreCase("con_sup"))
			{
				adm.setFechaIngreso(request.getParameter("fechaIngreso"));// --> sysdate (DD-MM-YYYY)
				adm.setAmPm(request.getParameter("amPm"));// --> sysdate (HH12:MI AM)
				adm.setFechaEgreso(request.getParameter("fechaEgreso"));
				adm.setAmPm2(request.getParameter("amPm2"));
				adm.setDiasHospitalizados(request.getParameter("diasHospitalizados"));
				AdmMgr.updateX(adm);
			}
			else AdmMgr.update(adm);
		}
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();
	}
	else if (tab.equals("1")) //CAMA
	{
		int size = 0;
		if (request.getParameter("camaSize") != null) size = Integer.parseInt(request.getParameter("camaSize"));
		String itemRemoved = "";

		adm.getCamas().clear();
		for (int i=1; i<=size; i++)
		{
			Admision obj = new Admision();

			obj.setCodigo(request.getParameter("codigo"+i));
			obj.setHabitacion(request.getParameter("habitacion"+i));
			obj.setCama(request.getParameter("cama"+i));
			obj.setCentroServicio(request.getParameter("centroServicio"+i));
			obj.setCentroServicioDesc(request.getParameter("centroServicioDesc"+i));
			obj.setPrecio(request.getParameter("precio"+i));
			if (request.getParameter("precioAlt"+i) != null && request.getParameter("precioAlt"+i).equalsIgnoreCase("S"))
			{
				obj.setPrecioAlt("S");
				obj.setPrecioAlterno(request.getParameter("precioAlterno"+i));

				obj.setMotivoPrecioAlt(request.getParameter("obsPrecioAlt"+i));
			}
			else
			{
				obj.setPrecioAlt("N");
				obj.setPrecioAlterno("");
			}
			obj.setHabitacionDesc(request.getParameter("habitacionDesc"+i));
			obj.setFechaInicio(request.getParameter("fechaInicio"+i));
			obj.setHoraInicio(request.getParameter("horaInicio"+i));
			obj.setUsuarioCreacion((String) session.getAttribute("_userName"));
			obj.setUsuarioModifica((String) session.getAttribute("_userName"));
			obj.setKey(request.getParameter("key"+i));
			obj.setCasoEspecial(request.getParameter("casoEspecial"+i));

			obj.setFechaFinal(request.getParameter("fechaFinal"+i));
			obj.setHoraFinal(request.getParameter("horaFinal"+i));


			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = obj.getKey();
				obj.setStatus("D");//D=Delete action in AdmisionMgr
				vCama.remove(obj.getHabitacion()+"-"+obj.getCama());
				vCamaNew.remove(obj.getHabitacion()+"-"+obj.getCama());
			}
			else obj.setStatus(request.getParameter("status"+i));

			try
			{
				iCama.put(obj.getKey(),obj);
				adm.addCama(obj);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}

		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AdmMgr.saveCama(adm);
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();
	}
	else if (tab.equals("2")) //DIAGNOSTICOS
	{
		int size = 0;
		if (request.getParameter("diagSize") != null) size = Integer.parseInt(request.getParameter("diagSize"));
		String itemRemoved = "";

		adm.getDiagnosticos().clear();
		for (int i=1; i<=size; i++)
		{
			Admision obj = new Admision();

			obj.setDiagnostico(request.getParameter("diagnostico"+i));
			obj.setDiagnosticoDesc(request.getParameter("diagnosticoDesc"+i));
			obj.setOrdenDiag(request.getParameter("ordenDiag"+i));
			obj.setTipo(request.getParameter("tipo"+i));
			obj.setUsuarioCreacion(request.getParameter("usuarioCreacion"+i));
			obj.setFechaCreacion(request.getParameter("fechaCreacion"+i));
			obj.setUsuarioModifica((String) session.getAttribute("_userName"));
			obj.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = obj.getKey();
			else
			{
				try
				{
					iDiag.put(obj.getKey(),obj);
					adm.addDiagnostico(obj);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			Admision obj = (Admision) iDiag.get(itemRemoved);
			vDiag.remove(obj.getDiagnostico());
			iDiag.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&type=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AdmMgr.saveDiagnostico(adm);
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();
	}


	else if (tab.equals("3")) //DOCUMENTOS
	{
		int size = 0;
		if (request.getParameter("docSize") != null) size = Integer.parseInt(request.getParameter("docSize"));
		String itemRemoved = "";

		adm.getDocumentos().clear();
		for (int i=1; i<=size; i++)
		{
			Admision obj = new Admision();

			obj.setDocumento(request.getParameter("documento"+i));
			obj.setDocumentoDesc(request.getParameter("documentoDesc"+i));
			if (request.getParameter("revisadoAdmision"+i) != null && request.getParameter("revisadoAdmision"+i).equalsIgnoreCase("S"))
				obj.setRevisadoAdmision("S");
			else
				obj.setRevisadoAdmision("N");
			obj.setUsuarioCreacion(request.getParameter("usuarioCreacion"+i));
			obj.setFechaCreacion(request.getParameter("fechaCreacion"+i));
			obj.setUsuarioModifica((String) session.getAttribute("_userName"));

			obj.setRevisadoSala(request.getParameter("revisadoSala"+i));
			obj.setRevisadoFac(request.getParameter("revisadoFac"+i));
			obj.setRevisadoCob(request.getParameter("revisadoCob"+i));
			obj.setObservacion(request.getParameter("observacion"+i));
			obj.setEstado(request.getParameter("estado"+i));

			obj.setUserEntrega(request.getParameter("userEntrega"+i));
			obj.setUserRecibe(request.getParameter("userRecibe"+i));
			obj.setFechaEntrega(request.getParameter("fechaEntrega"+i));
			obj.setFechaRecibe(request.getParameter("fechaRecibe"+i));
			obj.setAreaEntrega(request.getParameter("areaEntrega"+i));
			obj.setAreaRecibe(request.getParameter("areaRecibe"+i));
			obj.setPase(request.getParameter("pase"+i));
			obj.setPaseK(request.getParameter("paseK"+i));

			obj.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = obj.getKey();
			else
			{
				try
				{
					iDoc.put(obj.getKey(),obj);
					adm.addDocumento(obj);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			Admision obj = (Admision) iDoc.get(itemRemoved);
			vDoc.remove(obj.getDocumento());
			iDoc.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&type=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AdmMgr.saveDocumento(adm);
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();

	}



	else if (tab.equals("4")) //BENEFICIOS
	{
		int size = 0;
		if (request.getParameter("benSize") != null) size = Integer.parseInt(request.getParameter("benSize"));
		String itemRemoved = "";

		adm.setProceedPendingBalance(request.getParameter("proceedPendingBalance"));
		if(mode.equals("edit")) adm.setProceedPendingBalance("Y");
		adm.getBeneficios().clear();
		for (int i=1; i<=size; i++)
		{
			Admision obj = new Admision();

			obj.setEmpresa(request.getParameter("empresa"+i));
			obj.setConvenio(request.getParameter("convenio"+i));
			obj.setPlan(request.getParameter("plan"+i));
			obj.setCategoriaAdmi(request.getParameter("categoriaAdmi"+i));
			obj.setTipoAdmi(request.getParameter("tipoAdmi"+i));
			obj.setClasifAdmi(request.getParameter("clasifAdmi"+i));
			obj.setTipoPoliza(request.getParameter("tipoPoliza"+i));
			obj.setTipoPlan(request.getParameter("tipoPlan"+i));
			obj.setNombrePlan(request.getParameter("nombrePlan"+i));
			obj.setNombreConvenio(request.getParameter("nombreConvenio"+i));
			obj.setNombreEmpresa(request.getParameter("nombreEmpresa"+i));
			obj.setNombreTipoPlan(request.getParameter("nombreTipoPlan"+i));
			obj.setNombreTipoPoliza(request.getParameter("nombreTipoPoliza"+i));
			obj.setClasifAdmiDesc(request.getParameter("clasifAdmiDesc"+i));
			obj.setTipoAdmiDesc(request.getParameter("tipoAdmiDesc"+i));
			obj.setCategoriaAdmiDesc(request.getParameter("categoriaAdmiDesc"+i));
			obj.setSecuencia(request.getParameter("secuencia"+i));
			obj.setConvenioSolicitud(request.getParameter("convenioSolicitud"+i));
			obj.setPoliza(request.getParameter("poliza"+i));
			obj.setCertificado(request.getParameter("certificado"+i));
			obj.setPrioridad(request.getParameter("prioridad"+i));
			obj.setEstado(request.getParameter("estado"+i));
			if (request.getParameter("convenioSolEmp"+i) != null && request.getParameter("convenioSolEmp"+i).equalsIgnoreCase("S")) obj.setConvenioSolEmp("S");
			else obj.setConvenioSolEmp("N");
			//obj.setNumAprobacion(request.getParameter("numAprobacion"+i));
			obj.setUsuarioCreacion((String) session.getAttribute("_userName"));
			obj.setUsuarioModifica((String) session.getAttribute("_userName"));
			obj.setKey(request.getParameter("key"+i));
			obj.setStatus("A");

			obj.setFechaIni(request.getParameter("fechaIni"+i));
			obj.setFechaFin(request.getParameter("fechaFin"+i));
			if (request.getParameter("pacAsumeCargos"+i) != null && request.getParameter("pacAsumeCargos"+i).equalsIgnoreCase("S")) obj.setPacAsumeCargos(request.getParameter("pacAsumeCargos"+i));
			else obj.setPacAsumeCargos("N");
			if (request.getParameter("clinicaAsumeCargos"+i) != null && request.getParameter("clinicaAsumeCargos"+i).equalsIgnoreCase("S")) obj.setClinicaAsumeCargos(request.getParameter("clinicaAsumeCargos"+i));
			else obj.setClinicaAsumeCargos("N");

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = obj.getKey();
				obj.setStatus("D");
			}
			else obj.setStatus(request.getParameter("status"+i));

			try
			{
				iBen.put(obj.getKey(),obj);
				adm.addBeneficio(obj);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for

		if (!itemRemoved.equals(""))
		{
			Admision obj = (Admision) iBen.get(itemRemoved);
			vBen.remove(obj.getEmpresa()+"-"+obj.getConvenio()+"-"+obj.getPlan()+"-"+obj.getCategoriaAdmi()+"-"+obj.getTipoAdmi()+"-"+obj.getClasifAdmi());
			//iBen.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo+"&fp="+fp);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&type=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (baction != null && baction.equals("add"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AdmMgr.saveBeneficio(adm);
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();
	}
	else if (tab.equals("5")) //RESPONSABLE
	{
		int size = 0;
		if (request.getParameter("respSize") != null) size = Integer.parseInt(request.getParameter("respSize"));
		String itemRemoved = "";

		adm.getResponsables().clear();
		for (int i=1; i<=size; i++)
		{
			Admision obj = new Admision();

			obj.setTipoIdentificacion(request.getParameter("tipoIdentificacion"+i));
			obj.setIdentificacion(request.getParameter("identificacion"+i));
			obj.setSeguroSocial(request.getParameter("seguroSocial"+i));
			obj.setNombre(request.getParameter("nombre"+i));
			obj.setSexo(request.getParameter("sexo"+i));
			obj.setEmpresa(request.getParameter("empresa"+i));
			obj.setMedico(request.getParameter("medico"+i));
			obj.setNumEmpleado(request.getParameter("numEmpleado"+i));
			obj.setParentesco(request.getParameter("parentesco"+i));
			if (request.getParameter("principal"+i) != null && request.getParameter("principal"+i).equalsIgnoreCase("S")) obj.setPrincipal("S");
			else obj.setPrincipal("N");
			obj.setNacionalidad(request.getParameter("nacionalidad"+i));
			obj.setNacionalidadDesc(request.getParameter("nacionalidadDesc"+i));
			obj.setLugarNac(request.getParameter("lugarNac"+i));

			obj.setLugarDeTrabajo(request.getParameter("lugarDeTrabajo"+i));
			obj.setPuestoQueOcupa(request.getParameter("puestoQueOcupa"+i));
			obj.setDireccionTrabajo(request.getParameter("direccionTrabajo"+i));
			obj.setTelefonoDeTrabajo(request.getParameter("telefonoDeTrabajo"+i));
			obj.setExtension(request.getParameter("extension"+i));
			obj.setAniosLaborados(request.getParameter("aniosLaborados"+i));
			obj.setMesesLaborados(request.getParameter("mesesLaborados"+i));
			obj.setIngresoMensual(request.getParameter("ingresoMensual"+i));
			obj.setOtrosIngresos(request.getParameter("otrosIngresos"+i));
			obj.setFuenteOtrosIngresos(request.getParameter("fuenteOtrosIngresos"+i));

			obj.setDireccion(request.getParameter("direccion"+i));
			obj.setPais(request.getParameter("pais"+i));
			obj.setNombrePais(request.getParameter("nombrePais"+i));
			obj.setProvincia(request.getParameter("provincia"+i));
			obj.setNombreProvincia(request.getParameter("nombreProvincia"+i));
			obj.setDistrito(request.getParameter("distrito"+i));
			obj.setNombreDistrito(request.getParameter("nombreDistrito"+i));
			obj.setCorregimiento(request.getParameter("corregimiento"+i));
			obj.setNombreCorregimiento(request.getParameter("nombreCorregimiento"+i));
			obj.setComunidad(request.getParameter("comunidad"+i));
			obj.setNombreComunidad(request.getParameter("nombreComunidad"+i));
			obj.setEMail(request.getParameter("eMail"+i));

			System.out.println(" telefon responsable: "+request.getParameter("tel_responsable"+i));
			obj.setTelefonoResidencia(request.getParameter("tel_responsable"+i));
			obj.setFax(request.getParameter("fax"+i));
			obj.setZonaPostal(request.getParameter("zonaPostal"+i));
			obj.setApartadoPostal(request.getParameter("apartadoPostal"+i));

			obj.setObservacion(request.getParameter("observacion"+i));

			obj.setUsuarioCreacion(request.getParameter("usuarioCreacion"+i));
			obj.setFechaCreacion(request.getParameter("fechaCreacion"+i));
			obj.setUsuarioModifica((String) session.getAttribute("_userName"));
			obj.setKey(request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = obj.getKey();
			else
			{
				try
				{
					iResp.put(obj.getKey(),obj);
					adm.addResponsable(obj);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			Admision obj = (Admision) iResp.get(itemRemoved);
			vResp.remove(obj.getKey());
			iResp.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			Admision obj = new Admision();

			respLastLineNo++;
			if (respLastLineNo < 10) key = "00"+respLastLineNo;
			else if (respLastLineNo < 100) key = "0"+respLastLineNo;
			else key = ""+respLastLineNo;
			obj.setKey(key);

			try
			{
				iResp.put(key, obj);
				vResp.addElement(obj.getKey());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo);
			return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AdmMgr.saveResponsable(adm);
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();
	}
	else if (tab.equals("6")) //DOCUMENTOS
	{
		int size = 0;
		if (request.getParameter("docTypeSize") != null) size = Integer.parseInt(request.getParameter("docTypeSize"));

		al = new ArrayList();
		for (int i=0; i<size; i++)
		{
			CommonDataObject obj = new CommonDataObject();

			obj.setTableName("tbl_adm_admision_doc");
			obj.setWhereClause("pac_id="+pacId+" and admision="+noAdmision);
			obj.addColValue("pac_id",pacId);
			obj.addColValue("admision",noAdmision);
			obj.addColValue("doc_type",request.getParameter("id"+i));
			if (request.getParameter("checked"+i) != null && request.getParameter("checked"+i).equalsIgnoreCase("Y")) al.add(obj);
		}

		if (al.size() == 0)
		{
			CommonDataObject obj = new CommonDataObject();

			obj.setTableName("tbl_adm_admision_doc");
			obj.setWhereClause("pac_id="+pacId+" and admision="+noAdmision);
			al.add(obj);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();
	}
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
	if (tab.equals("0"))
	{
		if (mode.equalsIgnoreCase("add"))
		{
%>
	alert('Recuerde llenar la información en las pestañas adicionales!');
<%
		}
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/admision_list.jsp"))
		{
		if(!fp.trim().equals("hdadmision")){
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/admision_list.jsp")%>';
<%
		}else{%>
		<%}

		}
		else
		{
		if(fp.trim().equals("hdadmision")){
%>

	//window.location = '<%=request.getContextPath()%>/admision/admision_list.jsp';
<%}else{%>
window.opener.location = '<%=request.getContextPath()%>/admision/admision_list.jsp';
<%

		}}
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>