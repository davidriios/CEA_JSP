<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLReader"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="xmlRdr" scope="page" class="issi.admin.XMLReader"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbCorteFilter = new StringBuffer();
String cds = request.getParameter("cds");
String careDate = request.getParameter("careDate");
String statusAdm = request.getParameter("statusAdm");
String statusE = request.getParameter("statusE");//En Espera de Atencion
String statusT = request.getParameter("statusT");//Triage Registrado
String statusP = request.getParameter("statusP");//Atencion en Proceso
String statusF = request.getParameter("statusF");//Atencion Finalizada
String statusR = "";//Atencion de expediente Reactivado
String statusZ = request.getParameter("statusZ");//Expediente no habilitado
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

//usadas para el proceso de Expediente > Consultas > Secciones Guardadas
String section = request.getParameter("section");
String sectionDesc = request.getParameter("sectionDesc");
String path = request.getParameter("path");
String fDate = request.getParameter("fDate");
if (fDate == null) fDate = "";

int iconHeight = 48;
int iconWidth = 48;
int nRecs = 200;
String aseguradora = request.getParameter("aseguradora");
String medico = request.getParameter("medico");
String categoria = request.getParameter("categoria");
String fp = request.getParameter("fp");
if (fp == null) fp = "";
String  solEquipos= "N";
try {solEquipos =java.util.ResourceBundle.getBundle("issi").getString("auto.equipo.comodato");}catch(Exception e){ solEquipos = "N";}
String  escolta= "S";
try {escolta =java.util.ResourceBundle.getBundle("issi").getString("escolta");}catch(Exception e){ escolta = "S";}

String expVersion = "1";
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

//expVersion = "3";

sbSql.append("select count(*) from tbl_sec_profiles a, tbl_sec_module b where a.profile_id in (");
sbSql.append(CmnMgr.vector2numSqlInClause(UserDet.getUserProfile()));
sbSql.append(") and a.module_id = b.id and a.module_id = 11");
if (!UserDet.getUserProfile().contains("0") && CmnMgr.getCount(sbSql.toString())==0) throw new Exception("Usted no tiene el Perfil para accesar al Expediente. Por favor consulte con su administrador!");
if (!UserDet.getUserProfile().contains("0") && !UserDet.getRefType().equalsIgnoreCase("A") && fp.equalsIgnoreCase("aseguradora")) throw new Exception("Usted no es un usuario de tipo Aseguradora. Por favor consulte con su administrador!");
else if (!UserDet.getUserProfile().contains("0") && !UserDet.getRefType().equalsIgnoreCase("M") && fp.equalsIgnoreCase("medico")) throw new Exception("Usted no es un usuario de tipo Médico. Por favor consulte con su administrador!");

if (aseguradora == null) aseguradora = (UserDet.getRefType().equalsIgnoreCase("A"))?UserDet.getRefCode():"";
if (medico == null) medico = (UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getRefCode():"";
if (categoria == null) categoria = "";
if (careDate == null) careDate = cDate;//(fp.trim().equals(""))?cDate:"";
if (statusAdm == null) statusAdm = "A,E";//(fp.trim().equals(""))?"A,E":"";
String status = "";//Estado Atención
if (statusE == null && statusT == null && statusP == null && statusF == null && statusZ == null)
{
	//status = "'E','T','P','F','R','Z'";
	statusE = "E";
	statusT = "T";
	statusP = "P";
	statusF = "F";
	statusR = "R";
	//statusZ = "Z";
}
else
{
	if (statusE != null)
	{
		if (!status.trim().equals("")) status += ",";
		status += "'E'";
		statusE = "E";
	}
	if (statusT != null)
	{
		if (!status.trim().equals("")) status += ",";
		status += "'T'";
		statusT = "T";
	}
	if (statusP != null)
	{
		if (!status.trim().equals("")) status += ",";
		status += "'P'";
		statusP = "P";
	}
	if (statusF != null)
	{
		if (!status.trim().equals("")) status += ",";
		status += "'F'";
		statusF = "F";
	}
	if (statusR != null)
	{
		if (!status.trim().equals("")) status += ",";
		status += "'R'";
		statusR = "R";
	}
	if (statusZ != null)
	{
		if (!status.trim().equals("")) status += ",";
		status += "'Z'";
		statusZ = "Z";
	}
}

if (!careDate.trim().equals("") && fDate.trim().equals("")) { sbFilter.append(" and a.fecha_ingreso <= to_date('"); sbFilter.append(careDate); sbFilter.append("','dd/mm/yyyy') and decode(y.adm_root,null,nvl(a.fecha_egreso,decode(a.categoria,2,a.fecha_ingreso,sysdate)),nvl(y.fecha_egreso,decode(y.categoria,2,y.fecha_ingreso,sysdate))) >= to_date('"); sbFilter.append(careDate); sbFilter.append("','dd/mm/yyyy')"); }
if (!statusAdm.equals("")) { sbFilter.append(" and decode(y.adm_root,null,a.estado,y.estado) in ('"); sbFilter.append(statusAdm.replaceAll(" ","").replaceAll(",","','")); sbFilter.append("')"); }
if (!status.trim().equals("")) { sbFilter.append(" and d.estado in ("); sbFilter.append(status); sbFilter.append(")"); }

/*
cds
Ambulatorio
10  | CUARTO DE URGENCIAS-ADULTO
22  | CUARTO DE URGENCIAS-PEDIATRICO
601 | CUARTO DE URGENCIAS-CORONADO
607 | CONSULTA EXTERNA-CORONADO

Hospital
6   | INTENSIVO
11  | SALON DE OPERACIONES ***
21  | INTENSIVO PEDIATRICO
39  | HOSPITAL PEDIATRICO
70  | NEONATOLOGIA
101 | SALA D
102 | SALA E-F
103 | SALA G-H
104 | SALA I-J
105 | SALA A ***
106 | SALA K-L ***
110 | HABITACION ***
887 | RESIDENCIAL ***

categoria
1 hospital
2 ambulatorio

categoria tipo admision
2         1  consulta cu
2         13 otros servicios
2         15 endoscopia
2         19 consulta externa

profiles
86  CLTA_EXPEDIENTE
84  AUX_EXPEDIENTE
89  ENF_EXPEDIENTE
125 MED_INTERCON
124 MED_EXPEDIENTE
5   ADMI_EXPEDIENTE
126 RADIOLOGOS_EXP
182 EXP_TERAPISTAS
183 EXP_NUTRICIONISTA
185 EXP_SECRETARIO
*/

String cds1 = (String) session.getAttribute("COD_CENTRO1");//utilizado para listado inicial
String cds2 = (String) session.getAttribute("COD_CENTRO2");//utilizado para centros adicionales
if (cds1 == null) cds1 = "";
if (cds2 == null) cds2 = "";

String xCds = "";
if (!cds1.trim().equals("")) {xCds = cds1; if (cds == null) cds = cds1;}
if (!xCds.trim().equals("") && !cds2.trim().equals("") && !cds1.equals(cds2)) xCds += ","+cds2;
else if (!cds2.trim().equals("")) xCds = cds2;
if (fp.trim().equals("") && xCds.trim().equals("")) throw new Exception("Usted no tiene registrado centros de servicio en las variables ambiente. Por favor consulte con su Administrador!");
if (cds == null) cds = "";
if (fp.trim().equals("")) { sbFilter.append(" and d.cds in ("); sbFilter.append(((cds.trim().equals(""))?xCds:cds)); sbFilter.append(")"); }

if (request.getMethod().equalsIgnoreCase("GET"))
{
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

	sbSql = new StringBuffer();
	sbSql.append("select get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CAT_EGY') as cat, nvl(get_sec_comp_param(-1,'EXP_LIST_AUTO_SEARCH'),'Y') as auto_search, nvl(get_sec_comp_param(-1,'EXP_LIST_SEARCH_PARAM_REQ'),'N') as search_param_required, nvl(get_sec_comp_param(-1,'EXP_SET_TYPE_ENF_MED'),'N') as userRefType, nvl(get_sec_comp_param(-1,'EXP_CAT_SHOW_REJECTED_OM'),'-') as catShowRejectedOM, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_EXCLU_ALERGIA'),'0') as exclAlergia, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_MOSTRAR_ALERGIA_ANT'),'S') as showAllergyAnt from dual");
	CommonDataObject cdsP = SQLMgr.getData(sbSql.toString());
	if (cdsP==null) {
		cdsP = new CommonDataObject();
		cdsP.addColValue("cat","-1");
		cdsP.addColValue("auto_search","Y");
		cdsP.addColValue("param_required","N");
		cdsP.addColValue("userRefType","N");
	}
	if (UserDet.getUserTypeCode().trim().equalsIgnoreCase("AU") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("EN") || /*UserDet.getUserTypeCode().trim().equalsIgnoreCase("SS") ||*/ UserDet.getUserTypeCode().trim().equalsIgnoreCase("ES"))UserDet.setXtra5(cdsP.getColValue("userRefType","N"));/*Se utilizará para validacion en casos donde la enfermera es quien le han habilitado el uso del expediente. Caso de HCH */

	Vector vCatShowRejected = CmnMgr.str2vector(cdsP.getColValue("catShowRejectedOM"));

	String catPa=cdsP.getColValue("cat");
	boolean autoSearch = cdsP.getColValue("auto_search").equalsIgnoreCase("Y") || cdsP.getColValue("auto_search").equalsIgnoreCase("S");
	boolean searchParamReq = cdsP.getColValue("search_param_required").equalsIgnoreCase("Y") || cdsP.getColValue("search_param_required").equalsIgnoreCase("S");

	boolean showInterconsulta = false;

	if ((UserDet.getRefType().trim().equalsIgnoreCase("M"))){
		sbSql = new StringBuffer();
		sbSql.append("select (select count(*) as tot_pregunta from tbl_sal_interconsultor i where i.medico = '");
		sbSql.append(UserDet.getRefCode());
		sbSql.append("' and not exists (select r.codigo from tbl_sal_interconsultor_resp r where r.codigo_preg = i.codigo and r.pac_id = i.pac_id and r.admision = i.secuencia)) as tot_pregunta, (select count(*) from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b where a.pac_id = b.pac_id and a.secuencia = b.secuencia and a.codigo = b.orden_med and b.forma_solicitud = 'T' and ((b.omitir_orden = 'N' and b.estado_orden = 'A') or (b.ejecutado = 'N' and b.estado_orden = 'S')) and nvl(b.validada,'N') = 'N' and exists (select null from tbl_adm_medico where nvl(reg_medico,codigo) = '");
		sbSql.append(UserDet.getRefCode());
		sbSql.append("' and codigo = a.medico)) as ordenTelefonica from dual");
		CommonDataObject cdoInt = SQLMgr.getData(sbSql.toString());
		if (cdoInt == null) cdoInt = new CommonDataObject();

		if (cdoInt.getColValue("tot_pregunta","0")!=null && !cdoInt.getColValue("tot_pregunta","0").equals("0") ) showInterconsulta = true;
		cdsP.addColValue("ordenTelefonica",cdoInt.getColValue("ordenTelefonica","0"));
	}

	String cedulaPasaporte = request.getParameter("cedulaPasaporte");
	String dob = request.getParameter("dob");
	String codigo = request.getParameter("codigo");
	String noAdmision = request.getParameter("noAdmision");
	String paciente = request.getParameter("paciente");
	String pacBarcode = request.getParameter("pacBarcode");
	String tDate = request.getParameter("tDate");
	String sexo = request.getParameter("sexo");
	String barPacId="";

	if (cedulaPasaporte == null) cedulaPasaporte = "";
	if (dob == null) dob = "";
	if (codigo == null) codigo = "";
	if (noAdmision == null) noAdmision = "";
	if (paciente == null) paciente = "";
	if (pacBarcode == null) pacBarcode = "";
	if (tDate == null) tDate = "";
	if (sexo == null) sexo = "";

	if (!codigo.trim().equals(""))
	{
		sbCorteFilter.append(" and pac_id = "+codigo);
	}
	if (!noAdmision.trim().equals("")) { sbFilter.append(" and a.secuencia = (select adm_root from tbl_adm_admision where pac_id = a.pac_id and secuencia = "); sbFilter.append(noAdmision); sbFilter.append(")"); }
	if (!pacBarcode.trim().equals("")) {
		barPacId=pacBarcode.substring(0,10);
		System.err.println("Pacient Id="+barPacId+"            admision id="+pacBarcode.substring(10));
		sbFilter.append(" and a.pac_id = "); sbFilter.append(barPacId); sbFilter.append(" and a.secuencia = (select adm_root from tbl_adm_admision where pac_id = a.pac_id and secuencia = "); sbFilter.append(pacBarcode.substring(10)); sbFilter.append(")");
		//(select max(secuencia) from tbl_adm_admision aa where pac_id = a.pac_id and estado in ('A','E') and exists (select null from tbl_adm_admision where pac_id = aa.pac_id and secuencia = "+pacBarcode.substring(10)+" and adm_root = aa.adm_root))
	}



	if (!fDate.trim().equals("")) { sbFilter.append(" and a.fecha_ingreso = to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }

	if (!sexo.trim().equals("")||!paciente.trim().equals("")||!codigo.trim().equals("")||!dob.trim().equals("")||!cedulaPasaporte.trim().equals("")) {
		sbFilter.append(" and exists (select null from vw_adm_paciente where pac_id = a.pac_id ");
		if (!cedulaPasaporte.trim().equals("")) { sbFilter.append(" and upper(id_paciente) like '%"); sbFilter.append(request.getParameter("cedulaPasaporte").toUpperCase()); sbFilter.append("%'"); }
		if (!dob.trim().equals("")) { sbFilter.append(" and trunc(f_nac) = to_date('"); sbFilter.append(dob); sbFilter.append("','dd/mm/yyyy')"); }
		if (!codigo.trim().equals("")) { sbFilter.append(" and exp_id = "); sbFilter.append(codigo); }
		if (!paciente.trim().equals("")) { sbFilter.append(" and upper(nombre_paciente) like '%"); sbFilter.append(paciente.toUpperCase()); sbFilter.append("%'"); }
		if (!sexo.trim().equals("")) { sbFilter.append(" and sexo = '"); sbFilter.append(sexo); sbFilter.append("'"); }
		sbFilter.append(" ) ");
	}
	//	if (!fDate.trim().equals("")) { sbFilter.append(" and a.fecha_ingreso >= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); }
	//	if (!tDate.trim().equals("")) { sbFilter.append(" and a.fecha_ingreso <= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }


	sbSql = new StringBuffer();
	/* * * * *   C O L U M N S   * * * * */
	sbSql.append("select distinct to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia, to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am') as fechaIngreso, to_date(to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') as fi, a.medico, a.pac_id as pacId, (select exp_id from vw_adm_paciente where pac_id = a.pac_id) as expedienteId, a.pac_id_madre, (select id_paciente from vw_adm_paciente where pac_id = a.pac_id) as cedulaPasaporte, (select nombre_paciente/*replace(replace(nombre_paciente,upper(a.name_match),a.name_match),upper(a.lastname_match),a.lastname_match)*/ from vw_adm_paciente where pac_id = a.pac_id) as nombrePaciente, case when a.name_match is not null or a.lastname_match is not null then 1 else 0 end as matches, case when (select count(*) as nRecs from tbl_sec_alert z where z.pac_id = a.pac_id and z.admision = a.secuencia and status = 'A' and z.alert_type = 16 and exists (select null from tbl_sec_alert_type where id = z.alert_type)) > 0 then 'HO' when (select count(*) as nRecs from tbl_sec_alert z where z.pac_id = a.pac_id and z.admision = a.secuencia and status = 'A' and z.alert_type = 12 and exists (select null from tbl_sec_alert_type where id = z.alert_type)) > 0 then 'AC' else (select vip from vw_adm_paciente where pac_id = a.pac_id) end as idFidelizacion, (select decode (vip,'S','VIP','N','NORMAL','D','DISTINGUIDO','J','JUNTA DIRECTIVA','M','MEDICO STAFF','NO IDENTIFICADO') from vw_adm_paciente where pac_id = a.pac_id) as vip_dsp, a.am_pm as amPm, decode(y.adm_root,null,a.estado,y.estado) as estado, to_date(to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') as inDate, (select get_age((select f_nac from vw_adm_paciente where pac_id = a.pac_id),a.fecha_ingreso,null) from dual) as edad, decode(a.tipo_admision,13,1/*inyectable*/,0) as displayIcon, a.categoria, d.estado as estadoAtencion, d.hora_proceso as horaProcesoAtencion, d.hora_finalizado as horaFinalizadoAtencion, coalesce(d.cama,decode(a.categoria,1,'SIN ASIGNAR',' ')) as cama, d.cds, lpad(d.cds,3,'0') as cdsDisplay, to_char(a.fecha_ingreso,'yyyymmdd')||to_char(a.am_pm,'hh24miss') as fechaIngresoSort, a.centro_servicio as cdsAdm, (select sexo from vw_adm_paciente where pac_id = a.pac_id) as sexo");

	//categoria signos vitales del dia ingreso (del día que ingreso) o fecha antencion (del dia de hoy)
	sbSql.append(", decode((select categoria from tbl_sal_signo_paciente z where pac_id = a.pac_id and secuencia = a.secuencia and tipo_persona = 'T' and status = 'A' and hora = (select max(hora) from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and tipo_persona = 'T' and status = 'A'");
	//if (!careDate.trim().equals("")){ sbSql.append(" and fecha = to_date('"); sbSql.append(careDate); sbSql.append("','dd/mm/yyyy')"); }
	//else sbSql.append(" and fecha = trunc(a.fecha_ingreso)");
	sbSql.append(")),1,'I',2,'II',3,'III',(select nombre_corto from tbl_adm_categoria_admision where codigo = a.categoria)) as categoriaSigno");
	sbSql.append(", nvl((select categoria from tbl_sal_signo_paciente z where pac_id = a.pac_id and secuencia = a.secuencia and tipo_persona = 'T' and status = 'A' and hora = (select max(hora) from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and tipo_persona = 'T' and status = 'A'");
	//if (!careDate.trim().equals("")){ sbSql.append(" and fecha = to_date('"); sbSql.append(careDate); sbSql.append("','dd/mm/yyyy')"); }
	//else sbSql.append(" and fecha = trunc(a.fecha_ingreso)");
	sbSql.append(")),0) as cat_triage");

	//notas enfermeria
	sbSql.append(", (select decode(nvl(sum(decode(z.estado,'P',1,0)),0),0,decode(nvl(sum(decode(z.estado,'F',1,0)),0),0,0/*blank*/,1/*check*/),-1/*flag_red*/) from tbl_sal_notas_enfermeria z, tbl_sal_resultado_nota y where z.pac_id = a.pac_id and z.secuencia = a.secuencia and z.id = y.id and y.estado = 'A') as neIcon");
	//admisiones cortes
	sbSql.append(", nvl(y.secuencia,a.secuencia) as secuenciaCorte");
	//ordenes medicas (total y ejecutadas)
	sbSql.append(", (select nvl(sum(decode(z.ejecutado,'S',1,0)),0)||'/'||count(*) as executed from tbl_sal_detalle_orden_med z, tbl_adm_admision y where y.pac_id = z.pac_id and y.secuencia = z.secuencia and y.pac_id = a.pac_id and y.adm_root = a.secuencia and ((z.omitir_orden = 'N' and z.estado_orden = 'A') or (z.ejecutado = 'N' and z.estado_orden = 'S'))) as nOrdenMedExec, a.tipo_admision as tipoAdmision, (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = a.pac_id) as f_nac");
	//Ordenes Medicas Rechazadas / confirmadas
	sbSql.append(", (select nvl(sum(decode(z.confirmado,'Y',1,0)),0)||'/'||count(*) as executed from tbl_int_orden_farmacia f, tbl_sal_detalle_orden_med z, tbl_adm_admision y where y.pac_id = z.pac_id and y.secuencia = z.secuencia and y.pac_id = a.pac_id and y.adm_root = a.secuencia /*and ((z.omitir_orden = 'N' and z.estado_orden = 'A') or (z.ejecutado = 'N' and z.estado_orden = 'S'))*/ and z.pac_id = f.pac_id and z.secuencia = nvl(f.adm_cargo,f.admision)/*admision*/ and z.tipo_orden = f.tipo_orden and z.orden_med = f.orden_med and z.codigo = f.codigo and f.seguir_despachando = 'N' and f.other1 = 0) as nOrdenMedDesap");

	sbSql.append(", (select fn_sal_om_salida(a.pac_id,a.secuencia,'ANE') from dual) as omSalida, (select nvl(fn_sal_alergias(a.pac_id,a.secuencia,'D','");
	sbSql.append(cdsP.getColValue("showAllergyAnt","S"));
	sbSql.append("','N'),' ') from dual) as alergias, case when (select count(*) as nRecs from tbl_sec_alert z where z.pac_id = a.pac_id and z.admision = a.secuencia and status = 'A' and z.alert_type in(7,14,15) and exists (select null from tbl_sec_alert_type where id = z.alert_type)) > 0 then 'S' when nvl(a.condicion_paciente,'N') = 'S' then 'S' else 'N' end as riesgo");

	/* * * * *   T A B L E S   * * * * */
	sbSql.append(" from tbl_adm_admision a, tbl_adm_atencion_cu d");
	//admisiones cortes
	sbSql.append(", (select pac_id, secuencia, adm_root, estado, categoria, fecha_ingreso, fecha_egreso from tbl_adm_admision where (pac_id, secuencia) in (select pac_id, max(secuencia) from tbl_adm_admision where corte_cta is not null");
	sbSql.append(" and compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(sbCorteFilter.toString());
	sbSql.append(" group by pac_id, adm_root)) y");

	/* * * * *   F I L T E R S   * * * * */
	sbSql.append(" where a.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" and a.pac_id = d.pac_id and a.secuencia = d.secuencia");
	if (fp.equalsIgnoreCase("aseguradora")) {

		sbSql.append(" and exists (select null from tbl_adm_beneficios_x_admision where nvl(estado,'A') = 'A' and pac_id = a.pac_id and admision = a.secuencia");
		if (!aseguradora.trim().equals("")) {
			sbSql.append(" and empresa = ");
			sbSql.append(aseguradora);
		}
		sbSql.append(")");
		if (!categoria.trim().equals("")) {
			sbSql.append(" and a.categoria = ");
			sbSql.append(categoria);
		}

	} else if (fp.equalsIgnoreCase("medico") && !medico.trim().equals("")) {

		sbSql.append(" and (");
			sbSql.append("a.medico = '");
			sbSql.append(medico);
			sbSql.append("' or a.medico_cabecera = '");
			sbSql.append(medico);
			sbSql.append("'");
			//P R O G R E S O   C L I N I C O
			sbSql.append(" or exists (select null from tbl_sal_progreso_clinico where pac_id = a.pac_id and admision = a.secuencia and medico = '");
			sbSql.append(medico);
			sbSql.append("')");
			//I N T E R C O N S U L T A S
			sbSql.append(" or exists (select null from tbl_sal_interconsultor where pac_id = a.pac_id and secuencia = a.secuencia and medico = '");
			sbSql.append(medico);
			sbSql.append("')");
			sbSql.append(" or exists (select null from tbl_sal_interconsultor_espec where pac_id = a.pac_id and secuencia = a.secuencia and medico = '");
			sbSql.append(medico);
			sbSql.append("')");
			//A N E S T E S I O L O G O
			sbSql.append(" or exists (select null from tbl_sal_eval_preanestesica where pac_id = a.pac_id and admision = a.secuencia and cod_anestesiologo = '");
			sbSql.append(medico);
			sbSql.append("')");
		sbSql.append(")");

	}
	//admisiones cortes
	sbSql.append(" and a.pac_id = y.pac_id(+) and a.secuencia = y.adm_root(+)");

	sbSql.append(" order by 5 desc, 8 desc ");
	//order by to_date(to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') desc, b.exp_id desc

	//if (fp.trim().equals("") || (!fp.trim().equals("") && request.getParameter("careDate") != null))
	if(request.getParameter("noAdmision") != null){//para no ejecutar query cuando entran a la pantalla
	al = SQLMgr.getDataList("select * from ("+sbSql.toString()+") where rownum<="+nRecs);
	rowCount = al.size();}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Expediente - '+document.title;

function activarExpediente(pacId,noAdmision,estado)
{

	if(estado=="F")
	{
		abrir_ventana('../expediente/exp_activar_expediente.jsp?pacId='+pacId+'&noAdmision='+noAdmision);
	}else alert('Solo para Expedientes en estado Finalizado');
	/*
	var mode = '';
	var justificacion = "";//  prompt("","");
	if(estado=='F')
	{
		if(confirm('¿Está seguro que desea Activar el Expediente de este Paciente ?'))
		{
			if(executeDB('<%=request.getContextPath()%>','call sp_adm_activar_exp('+pacId+','+noAdmision+',\''+justificacion+'\')',''))//tbl_adm_atencion_cu,tbl_sal_adm_salida_datos,tbl_sal_notas_enfermeria
			{
				alert('Expediente Activado');
				reloadPage();
			}
			else alert('Error al Activar el Expediente');
		}
		else alert('Activar Expediente Cancelado');
	}else alert('Solo para Expedientes en estado Finalizado');*/
}

function printList()
{
	abrir_ventana('../expediente/print_list_expediente.jsp?fp=<%=fp%>&careDate=<%=IBIZEscapeChars.forURL(careDate)%>&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&corteFilter=<%=IBIZEscapeChars.forURL(sbCorteFilter.toString())%>&nRecs=<%=nRecs%><% if (fp.equalsIgnoreCase("aseguradora")){ %>&aseguradora=<%=aseguradora%>&categoria=<%=categoria%><% } else if (fp.equalsIgnoreCase("medico")){ %>&medico=<%=medico%><% } %>');
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();loaded=true;<%if (fp.trim().equals("")) {%>document.getElementById("pacBarcode").focus();checkPendingOM();<%}%><%if(UserDet.getRefType().equalsIgnoreCase("M")){%>showOrdenTelef();<%}%>}
function showOrdenTelef(){
 var orden = '<%=cdsP.getColValue("ordenTelefonica","0")%>';

 if(orden !=0)showPopWin('../expediente/list_orden_telefonicas.jsp?fp=EXP&medico=<%=UserDet.getRefCode()%>',winWidth*.75,winHeight*.65,null,null,'');

}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function reloadPage()
{
	//window.location.reload(true);
<%
if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
{
%>
	window.location='<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
}
else
{
%>
	window.location='../expediente/expediente_list.jsp';
<%
}
%>
}

function setIndex(k)
{
	if(document.form01.index.value!=k)
	{
		document.form01.index.value=k;
		getPatientDetails(k);
	}
}



function goOption(option){

	 var i = document.form01.index.value;
	 var cat = $("#categoria"+i).val();
	 var bed = $("#cama"+i).val();
	 var pacName = $("#nombrePaciente"+i).val();
	 var _sexo = $("#sexo"+i).val();
	 var excludes = {}; // can be a configuration variable: 'option':1,'option':1 (ie: myVar='0':1,'2':1)
	 var notExclude = !(excludes.hasOwnProperty(option));

	 if ( cat == 1 && (bed.trim()=="" ||bed.trim()=="SIN ASIGNAR" ) && notExclude == true ){
		 var deter = (_sexo == "F")?"La":"El";
		 CBMSG.confirm(deter+" paciente "+pacName+" no tiene cama!",{btnTxt:"Continuar,Cancelar",cb:function(r){if(r=="Continuar")__goOption(option);}});
	 }else{__goOption(option);}

	function __goOption(option)
	{
		if(option==undefined)CBMSG.error('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
				else if (option==23) abrir_ventana('../facturacion/reg_cargo_dev_new.jsp?fg=PAC&fPage=general_page&bac__code=Y');
		else
		{
			var k=document.form01.index.value;

			if(k=='-1')CBMSG.error('Por favor seleccione una admisión antes de ejecutar una acción!');
			else
			{
				var pacId = eval('document.form01.pacId'+k).value;
				var noAdmision = eval('document.form01.secuencia'+k).value;//admRoot
				var noAdmisionCorte = eval('document.form01.secuenciaCorte'+k).value;//nueva admision corte
				var estadoAtencion = eval('document.form01.estadoAtencion'+k).value;
				var fecha_nacimiento = eval('document.form01.fecha_nacimiento'+k).value;
				var codPac = eval('document.form01.codPac'+k).value;
				var cds = eval('document.form01.cds'+k).value;
				var cdsAdm = eval('document.form01.cdsAdm'+k).value;
				var categoria = eval('document.form01.categoria'+k).value;
				var msg='';
				var mode = '';
				var pacIdMadre = eval('document.form01.pacIdMadre'+k).value;
				var fromBed = eval('document.form01.cama'+k).value;
				var estadoAdm = eval('document.form01.estado'+k).value;
				var cdsAdmDesc = "";

				if (estadoAtencion!="Z"){
				if(option==0||option==21){
					//if(estadoAtencion=='F') mode = 'view';
					var expId = eval('document.form01.expId'+k).value;
					var medico = eval('document.form01.medico'+k).value;
					if(<%=(UserDet.getRefType().equalsIgnoreCase("M")||UserDet.getXtra5().trim().equalsIgnoreCase("S"))%>&&getDBData('<%=request.getContextPath()%>','upper(cambia_otro)','tbl_adm_medico','codigo=\''+medico+'\'','')=='S')openWin('../expediente/expediente_medic_registry.jsp?pacId='+pacId+'&noAdmision='+noAdmision+'&mode='+mode+'&medico='+medico+'&cds='+cds+'&estado='+estadoAtencion+'&estadoAdm='+estadoAdm+'&expId='+expId,'regMed',getPopUpOptions(false,false,false,true,700,200));
					else{
						var expVersion = "<%=expVersion%>";
						<% if (expVersion.equalsIgnoreCase("2")) { %>
						var url='../expediente/expediente_iconificado.jsp?pacId='+expId+'&noAdmision='+noAdmision+'&mode='+mode+'&cds='+cds+'&estado='+estadoAtencion+'&catId='+categoria+'&careDate=<%=careDate%>';
						<% } else if (expVersion.equalsIgnoreCase("3")) { %>
						var url='../expediente3.0/expediente.jsp?pacId='+expId+'&noAdmision='+noAdmision+'&mode='+mode+'&cds='+cds+'&estado='+estadoAtencion+'&catId='+categoria;
						<% } else { %>
						var url='../expediente/expediente_config.jsp?pacId='+expId+'&noAdmision='+noAdmision+'&mode='+mode+'&cds='+cds+'&estado='+estadoAtencion+'&catId='+categoria;
						<% } %>

						if (expVersion == "3") {
							CBMSG.confirm("Recuerde que <%=_comp.getNombreCorto().trim().equals("")?_comp.getNombre():_comp.getNombreCorto()%>, maneja estricta confidencialidad con la información de nuestros pacientes. Toda Actividad en el Expediente Clínico será monitoreada. ¿Desea continuar?",{
								btnTxt: 'Si,No',
								cb: function(r){
									if(r=='Si') {
											if(estadoAdm=='I'||estadoAdm=='N'){
												CBMSG.confirm("La admisión del Expediente #"+expId+" tiene estado Anulado/Inactivo. Desea Continuar con el proceso?",{
													btnTxt: 'Si,No',
													cb: function(r){
														if(r=='Si')abrir_ventana(url);
													}
												});
											}else abrir_ventana(url);

									}
								}
							});
						} else {
							if(estadoAdm=='I'||estadoAdm=='N'){
								CBMSG.confirm("La admisión del Expediente #"+expId+" tiene estado Anulado/Inactivo. Desea Continuar con el proceso?",{
									btnTxt: 'Si,No',
									cb: function(r){
										if(r=='Si')abrir_ventana(url);
									}
								});
							}else abrir_ventana(url);
						}
					}
				}
				else if(option==1)abrir_ventana('../facturacion/reg_cargo_dev_new.jsp?noAdmision='+noAdmisionCorte+'&pacienteId='+pacId+'&fg=PAC&fPage=general_page');
				else if(option==2)abrir_ventana('../facturacion/reg_cargo_dev.jsp?noAdmision='+noAdmisionCorte+'&pacienteId='+pacId+'&fg=HON&fPage=general_page');
				else if(option==3 ){
					if(categoria!=="<%=catPa%>") CBMSG.alert("Solo para Cuarto de Urgencia!");
					else abrir_ventana('../expediente/print_sal10010_cu.jsp?codPac='+codPac+'&pacId='+pacId+'&noAdmision='+noAdmision+'&fecha_nacimiento='+fecha_nacimiento+'&cds='+cds<%=expVersion.equalsIgnoreCase("3")?"+'&exp="+expVersion+"'" : ""%>);
				}
				else if(option==4)
				{
					if(hasDBData('<%=request.getContextPath()%>','tbl_fac_detalle_transaccion','pac_id='+pacId+' and fac_secuencia='+noAdmisionCorte,''))abrir_ventana('../facturacion/print_cargo_dev.jsp?noSecuencia='+noAdmisionCorte+'&pacId='+pacId);
					else alert('La admisión no tiene cargos registrados!');
				}
				else if(option==5)/*CU*/
				{
					if(estadoAtencion!='F')alert('Solo para Expedientes en estado Finalizado');
					else
						if(hasDBData('<%=request.getContextPath()%>','tbl_sal_adm_salida_datos','pac_id='+pacId+' and secuencia='+noAdmision+' and estado=\'F\' ',''))abrir_ventana('../expediente/exp_cambiar_dx.jsp?noAdmision='+noAdmision+'&pacId='+pacId+'&fechaNacimiento='+fecha_nacimiento+'&codPac='+codPac);
						else alert('La admisión no tiene Datos de Salida registrados!');
				}
				else if(option==6)/*CU*/activarExpediente(pacId,noAdmision,estadoAtencion);
				else if(option==7)
				{
					if(estadoAtencion=='F') mode = 'view';
					abrir_ventana('../expediente/exp_obser_admin.jsp?mode='+mode+'&noAdmision='+noAdmision+'&pacId='+pacId+'&dob='+fecha_nacimiento+'&codPac='+codPac+'&tipo=E');
				}
				else if(option==8){
					<% if (expVersion.equalsIgnoreCase("2")) { %>
					var page='../expediente/expediente_iconificado.jsp';
					<% } else if (expVersion.equalsIgnoreCase("3")) { %>
					var page='../expediente3.0/expediente.jsp';
					<% } else { %>
					var page='../expediente/expediente_config.jsp';
					<% } %>

									 var url = page+'?pacId='+pacId+'&noAdmision='+noAdmision+'&mode=view&cds='+cds<%=(fp.equalsIgnoreCase("secciones_guardadas")?"+'&section="+section+"&sectionDesc="+sectionDesc+"&path="+path+"&fp=secciones_guardadas'":"")%>;

									 if (estadoAdm ==  'I' || estadoAdm == 'N'){
												CBMSG.confirm("La admisión del Expediente #"+expId+" tiene estado Anulado/Inactivo. Desea Continuar con el proceso?",{
														btnTxt: 'Si,No',
														cb: function(r){
															 if (r == 'Si') abrir_ventana(url);
														}
												});
										} else abrir_ventana(url);

					<%if(fp.equalsIgnoreCase("secciones_guardadas")){%>
						 parent.hidePopWin(false);
					<%}%>
				}

				else if(option==9)
				{
					/*if(categoria==1)
					{
						*/cds=eval('document.main.cds').value;
						if(cds!='')abrir_ventana('../expediente/print_plan_cuidados.jsp?cds='+cds+'&pacId='+pacId+'&noAdmision='+noAdmision);
						else alert('Seleccione centro de servicio');
					/*}
					else alert('Sólo aplica para las admisiones con categoría hospitalizada!');*/
				}
				else if(option==10)abrir_ventana('../expediente/print_atencion_paciente.jsp?pacId='+pacId+'&noAdmision='+noAdmision);
				else if(option==11){
				var tipoAdmision = eval('document.form01.tipoAdmision'+k).value;
				var cedPas = eval('document.form01.cedulaPasaporte'+k).value;

				var ct_tp_adm = getDBData('<%=request.getContextPath()%>','param_value','tbl_sec_comp_param','param_name=\'CT_TP_ADM\' and compania in(-1,<%=(String) session.getAttribute("_companyId")%>)','');
				var cat =ct_tp_adm.substr(0,1);//ejemplo 1|4|5
				var mat =ct_tp_adm.substr(4,1);
				var neo =ct_tp_adm.substr(2,1);


					if(categoria==cat && tipoAdmision==mat)
					{
						abrir_ventana('../expediente/exp_datos_bb.jsp?fg=con_sup&pacId='+pacId+'&noAdmision='+noAdmision+'&dob='+fecha_nacimiento+'&codPac='+codPac+'&pacIdMadre='+pacIdMadre+'&cedPas='+cedPas);
					}else alert('Solo para Admisiones de Maternidad');
				}
				else if(option==12)abrir_ventana('../expediente/ver_carenotes.jsp?pacId='+pacId+'&noAdmision='+noAdmision);
				else if(option==13)abrir_ventana('../admision/print_admision_barcode.jsp?pacId='+pacId+'&noAdmision='+noAdmisionCorte+'&cds='+cdsAdm);
				else if(option==14){abrir_ventana('../escolta/reg_sol_escolta.jsp?mode=add&pacId='+pacId+'&noAdmision='+noAdmision+'&fromCDS='+cds+'&fromBed='+fromBed+'&cdsAdmDesc='+cdsAdmDesc+'&admCategory='+categoria);}
				else if(option==15){abrir_ventana('../expediente/reg_sol_equipos_med.jsp?mode=add&pacId='+pacId+'&admRoot='+noAdmision+'&cds='+cds+'&noAdmision='+noAdmisionCorte);}
				else if(option==16){abrir_ventana('../inventario/print_monitoreo_cargos_eq_comodato.jsp?fg=EXP&pacId='+pacId+'&noAdmision='+noAdmision);}
				else if(option==17){abrir_ventana('../farmacia/exp_orden_medicamentos_dev.jsp?mode=aprobar&pacId='+pacId+'&noAdmision='+noAdmision+'&tipo=A&fg=ME');}
				else if(option==18){abrir_ventana('../expediente/exp_gen_recetas.jsp?pacId='+pacId+'&noAdmision='+noAdmision+'&desc=DATOS DE SALIDA&modeSec=edit&seccion=26');}
				else if(option==20){
				var expId = eval('document.form01.expId'+k).value;
				abrir_ventana('../expediente/expediente_new_flow.jsp?pacId='+expId+'&noAdmision='+noAdmision+'&mode='+mode+'&cds='+cds+'&estado='+estadoAtencion+'&careDate=<%=careDate%>&catId='+categoria);}
				else if(option==24){abrir_ventana('../admision/print_label_unico.jsp?mode=edit&pacId='+pacId+'&noAdmision='+noAdmision);}
				else if(option==25){abrir_ventana('../dashboard/patients_dashboard.jsp?mode=&pacId='+pacId+'&admision='+noAdmision);}
				else if(option==26){abrir_ventana('../admision/print_label_unico.jsp?mode=edit&pacId='+pacId+'&noAdmision='+noAdmision+'&nobarcode');}



			}//not Z
			else{
					 if(option==19){

						 showPopWin('../common/run_process.jsp?fp=EXP&actType=8&docType=EXP&pacId='+pacId+'&docId='+pacId+'&docNo='+noAdmision+'&noAdmision='+noAdmision,winWidth*.75,winHeight*.65,null,null,'');

					 }
				}
		}//admision selected
	}
}
}

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Expediente<% if (expVersion.equalsIgnoreCase("2")) { %> Clínico Iconificado<% } %>';break;
		case 1:msg='Cargos / Devoluciones';break;
		case 2:msg='Honorario Médico';break;
		case 3:msg='Imprimir Informe Atención CU';break;
		case 4:msg='Imprimir Detalles de Cargos';break;
		case 5:msg='Cambiar Diagnóstico';break;
		case 6:msg='Activar Expediente';break;
		case 7:msg='Observaciones Administrativas';break;
		case 8:msg='Ver Expediente';break;
		case 9:msg='Plan de Cuidados';break;
		case 10:msg='Imprimir Atención del Paciente';break;
		case 11:msg='Detalles de Bebe';break;
		case 12:msg='CARENOTES';break;
		case 13:msg='Imprimir Brazalete'; break;
		case 14:msg='Anfitrión Escolta';break;
		case 15:msg='Equipos Médicos';break;
		case 16:msg='Imprimir Solicitudes de Equipos Médicos';break;
		case 17:msg='Devolucion de Medicamentos (Farmacia)';break;
		case 18:msg='Receta Médica';break;
		case 19:msg='Habilitar Expediente';break;
		case 20:msg='Flujo de Atención';break;
		case 22:msg='Interconsultas';break;
		case 23:msg='Cargos / Devoluciones - CB';break;
		case 24:msg='Imprimir Label - Individual';break;
		case 25:msg='Dashboard paciente';break;
		case 26:msg='Imprimir Label - Individual Sin Código Barra';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}

function mouseOut(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	setoutc(obj,'ImageBorder');
	optDescObj.innerHTML='&nbsp;';
}

function doSearch()
{
var paramValid=true;
<% if (searchParamReq) { %>
var statusAdm=document.main.statusAdm.value;
var sObj=<% if (fp.trim().equals("")) { %>document.main.cds.value;<% } else if (fp.equalsIgnoreCase("aseguradora")){ %>document.main.aseguradora.value;<% } else if (fp.equalsIgnoreCase("medico")){ %>document.main.medico.value;<% } else { %>'';<%}%>
var careDate=document.main.careDate.value;
var dob=document.main.dob.value;
var codigo=document.main.codigo.value;
var noAdmision=document.main.noAdmision.value;
var pacBarcode=document.main.pacBarcode.value;
if(document.main.pacBarcode.value!='')pacBarcode=getPB();
var cedulaPasaporte=document.main.cedulaPasaporte.value;
var paciente=document.main.paciente.value;
var fDate=document.main.fDate.value;
var sexo=document.main.sexo.value;
if (statusAdm=='A,E,I'&&sObj.trim()==''&&careDate==''&&dob==''&&codigo==''&&noAdmision==''&&pacBarcode==''&&cedulaPasaporte==''&&paciente==''&&fDate==''&&sexo==''){alert('Por favor indicar por lo menos un parámetro de búsqueda!');paramValid=false;}
<% } %>
if(paramValid)__submitForm(document.main,'Ir');
}
function getPatientDetails(k)
{
	var expId=eval('document.form01.expId'+k).value;
	var pacId=eval('document.form01.pacId'+k).value;
	var noAdmision=eval('document.form01.secuencia'+k).value;
	var cama=eval('document.form01.cama'+k).value;
	var medico=eval('document.form01.medico'+k).value;
	var cds=eval('document.form01.cdsDisplay'+k).value;
	var asegDesc='';
	var camaDesc=cama;//'';
	var medDesc='';
	var cdsDesc=cds;
	if(pacId!=undefined&&noAdmision!=undefined)
	{
		asegDesc=getDBData('<%=request.getContextPath()%>','y.nombre','(select * from tbl_adm_beneficios_x_admision where pac_id='+pacId+' and admision='+noAdmision+'<%=(fp.equalsIgnoreCase("aseguradora"))?"":" and prioridad=1"%> and nvl(estado,\'A\')=\'A\') z, tbl_adm_empresa y','z.empresa=y.codigo',' order by prioridad');
	}
	if(medico!=undefined)medDesc=getDBData('<%=request.getContextPath()%>','\'[\'||nvl(reg_medico,codigo)||\'] \'||decode(sexo,\'F\',\'DRA. \',\'M\',\'DR. \')||primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada))','tbl_adm_medico','codigo=\''+medico+'\'','');

	document.getElementById("aseguradoraDesc").innerHTML=asegDesc;
	if(camaDesc=='')
	{
		document.getElementById("camaId").className='TextRow2';
		document.getElementById("camaLabel").style.display='none';
		document.getElementById("camaDesc").style.display='none';
	}
	else
	{
		document.getElementById("camaId").className='TextHeader';
		document.getElementById("camaLabel").style.display='';
		document.getElementById("camaDesc").style.display='';
		document.getElementById("camaDesc").innerHTML=camaDesc;
	}
	document.getElementById("medicoDesc").innerHTML=medDesc;
	document.getElementById("cdsDesc").innerHTML=cdsDesc;
	document.getElementById("fNacimiento").innerHTML = eval('document.form01.fecha_nacimiento'+k).value;
}

function displayValue(k,type,value)
{
	if(value!='')value='['+value+']';
	if(document.getElementById('lbl'+type+k))document.getElementById('lbl'+type+k).innerHTML=value;
}
function AbrirExp(k){
setIndex(k);
<% if (fp.equalsIgnoreCase("secciones_guardadas")) { %>
goOption(8);
<% } else { %>
goOption(0);
<% } %>
}
function checkPendingOM()
{
<%
if (UserDet.getUserTypeCode().trim().equalsIgnoreCase("EN") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("SS") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("ES"))
{
%>
	var gExe=parseInt(document.form01.gExe.value,10);
	var gTot=parseInt(document.form01.gTot.value,10);
	if((gTot-gExe)>0)
	{
		document.getElementById('pendingMsg').style.display='';
		//setTimeout('replaySound(\'pendingSound\',5000)',10);
		soundAlert({delay:5000});
	}
<%
}else if (UserDet.getRefType().trim().equalsIgnoreCase("M")||UserDet.getRefType().trim().equalsIgnoreCase("MI")){
%>
	var gExe=parseInt(document.form01.gConf.value,10);
	var gTot=parseInt(document.form01.gDesap.value,10);
	if((gTot-gExe)>0)
	{
		document.getElementById('pendingMsg').style.display='';
		//setTimeout('replaySound(\'pendingSound\',5000)',10);
		soundAlert({delay:5000});
	}
<%}%>
}

$(document).ready(function(r){

});

//called from interconsulta window
window.redrawTheModalWithInterconsulta = function () {
	 //if ($("#tmpIntUrl").val()) showPopWin('../expediente/exp_interconsulta_resp.jsp?fg=EXP',winWidth*.85,winHeight*.80,null,null,'');
}
function getPB(){
	var pb = $("#pacBarcode").val(), _pb = "";
	if (pb.indexOf("-") > 0){
	try{
		_pb = pb.split("-");
		_pb = _pb[0].lpad(10,"0")+""+_pb[1].lpad(3,"0");
	}catch(e){_pb="";}
	}else if (pb.trim().length == 13) _pb = pb;
	return _pb;
}

jQuery(document).ready(function(){
	doAction();
	<%if(fp.trim().equalsIgnoreCase("secciones_guardadas")){%>AbrirExp(0);<%}%>
	 $("#interconsulta").css({position:"absolute"}).effect('slide', { direction: 'left', mode: 'show' }, 700, function(){
			$(this).css({position:"",marginRight:5});
	 });

	 $("#interconsulta").click(function(){
			var i = document.form01.index.value;
		var pacId = "",noAdmision = "";
		if (i > 0){
		pacId = $("#pacId"+i).val();
		noAdmision = $("#secuencia"+i).val();
		}
			showPopWin('../expediente/exp_interconsulta_resp.jsp?fg=EXP&pacId='+pacId+'&noAdmision='+noAdmision,winWidth*.85,winHeight*.80,null,null,'');
	 });

	 <%if(request.getParameter("redraw") != null){%>
			showPopWin('../expediente/exp_interconsulta_resp.jsp?fg=EXP',winWidth*.85,winHeight*.80,null,null,'');
	 <%}%>
	$("#pacBarcode").keyup(function(e){
		var pacBrazalete = pacId = noAdmision = "";
		var key;
		(window.event) ? key = window.event.keyCode : key = e.which;
				var self = $(this);

		if(key == 13){
			pacBrazalete = getPB(self.val());
						pacId = parseInt(pacBrazalete.substr(0,10),10);
				noAdmision = parseInt(pacBrazalete.substr(10),10);
			document.main.codigo.value=pacId;
			document.main.noAdmision.value=noAdmision;
			document.main.pacBarcode.value='';
			doSearch();
		}
	});
});
</script>
<style type="text/css">
<!--
.VerdeAqua {color: #1ABC9C !important;}
.DarkGreen {color: #006400 !important;}
.DarkGreenBold {color: #006400 !important; font-weight: bold !important;}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>

<% if (fp.trim().equals("")) { %>

		<%if (showInterconsulta){%>
			<authtype type='70'><a style="display:none" id="interconsulta" href="javascript:void(0);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,22)" onMouseOut="javascript:mouseOut(this,22)" src="../images/icons/_interconsulta.png" style="box-shadow: 1px -4px 5px red"></a></authtype>
		<%}%>
		<authtype type='68'><a href="javascript:goOption(20);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,20)" onMouseOut="javascript:mouseOut(this,20)" src="../images/flow.png"></a></authtype>
		<authtype type='67'><a href="javascript:goOption(19);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,19)" onMouseOut="javascript:mouseOut(this,19)" src="../images/habilitar_expediente.png"></a></authtype>
		<authtype type='65'><a href="javascript:goOption(12)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,12)" onMouseOut="javascript:mouseOut(this,12)" src="../images/carenotes.png"></a></authtype>
		<authtype type='4'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/<%=(expVersion.equalsIgnoreCase("2"))?"folder160.png":"expediente.png"%>"></a></authtype>
		<authtype type='50'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/cargos_devoluciones.png"></a></authtype>
		<authtype type='50'><a href="javascript:goOption(23)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,23)" onMouseOut="javascript:mouseOut(this,23)" src="../images/cargos_devoluciones_cb.png"></a></authtype>
		<authtype type='51'><a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/honorario_medico.png"></a></authtype>
		<authtype type='52'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/imprimir_atencion_del_paciente.png"></a></authtype>
		<authtype type='53'><a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/imprimir_detalles_de_cargo.png"></a></authtype>
		<authtype type='54'><a href="javascript:goOption(5);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/cambiar_diagnostico.png"></a></authtype>
		<authtype type='55'><a href="javascript:goOption(6);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/activar_expediente.png"></a></authtype>
		<authtype type='56'><a href="javascript:goOption(7);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/observaciones_administrativas.png"></a></authtype>
		<authtype type='57'><a href="javascript:goOption(9);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,9)" onMouseOut="javascript:mouseOut(this,9)" src="../images/plan_de_cuidados.png"></a></authtype>
		<authtype type='58'><a href="javascript:goOption(10);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/imprimir_informe_atencion_cu.png"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(8)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/ver_expediente.png"></a></authtype>

		<authtype type='59'><a href="javascript:goOption(11);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,11)" onMouseOut="javascript:mouseOut(this,11)" src="../images/detalles_de_bebe.png"></a></authtype>
		<authtype type='60'><a href="javascript:goOption(13)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,13)" onMouseOut="javascript:mouseOut(this,13)"  src="../images/imprimir_brazalete.png"></a></authtype>
		<%if(escolta.trim().equals("S")){%>
		<authtype type='61'><a href="javascript:goOption(14);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,14)" onMouseOut="javascript:mouseOut(this,14)" src="../images/anfitrion_escolta.png"></a></authtype><%}%>
		<%if(solEquipos.trim().equals("S")){%>
		<authtype type='62'><a href="javascript:goOption(15);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,15)" onMouseOut="javascript:mouseOut(this,15)" src="../images/equipos_medicos.png"></a></authtype>
		<authtype type='63'><a href="javascript:goOption(16);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,16)" onMouseOut="javascript:mouseOut(this,16)" src="../images/imprimir_solicitudes_de_equipos_medicos.png"></a></authtype><%}%>
		<authtype type='64'><a href="javascript:goOption(17);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,17)" onMouseOut="javascript:mouseOut(this,17)" src="../images/devolucion_de_medicamentos.png"></a></authtype>
		<authtype type='66'><a href="javascript:goOption(18);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,18)" onMouseOut="javascript:mouseOut(this,18)" src="../images/receta_medica.png"></a></authtype>
		<authtype type='71'><a href="javascript:goOption(24);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,24)" onMouseOut="javascript:mouseOut(this,24)" src="../images/label_pac.png"></a></authtype>
		<authtype type='74'><a href="javascript:goOption(26);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,26)" onMouseOut="javascript:mouseOut(this,26)" src="../images/no-barcode.png"></a></authtype>
		<authtype type='73'><a href="javascript:goOption(25);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,25)" onMouseOut="javascript:mouseOut(this,25)" src="../images/dashboard.png"></a></authtype>
		<!--authtype 74 usado al final-->

<% } else if (fp.equalsIgnoreCase("medico")) { %>

		<authtype type='1'><a href="javascript:goOption(8)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/ver_expediente.png"></a></authtype>

<% } else if (fp.equalsIgnoreCase("aseguradora") || fp.equalsIgnoreCase("medico")) { %>

		<authtype type='1'><a href="javascript:goOption(8)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/ver_expediente.png"></a></authtype>
		<authtype type='52'><a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/imprimir_atencion_del_paciente.png"></a></authtype>
		<authtype type='53'><a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/imprimir_detalles_de_cargo.png"></a></authtype>
		<authtype type='58'><a href="javascript:goOption(10);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/imprimir_informe_atencion_cu.png"></a></authtype>

<% } %>

	</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("main",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("_timer","")%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".careDate.value.trim()=='' && document."+fb.getFormName()+".codigo.value.trim()==''&&document."+fb.getFormName()+".dob.value.trim()==''&&document."+fb.getFormName()+".noAdmision.value.trim()==''&&document."+fb.getFormName()+".pacBarcode.value.trim()==''&&!confirm('La consulta puede tardar un poco si no coloca la Fecha de Atención.\\n¿Está usted seguro que desea continuar?'))error++;");%>
		<tr class="TextFilter">
			<td colspan="2" class="Text10">
				<cellbytelabel id="1">Admisiones</cellbytelabel>
				<%=fb.select("statusAdm","A,E,I=TODOS=A,E,I|A,E=ACTIVA Y EN ESPERA=A,E|A=ACTIVA=A|E=EN ESPERA=E|I=INACTIVA=I",statusAdm,false,false,0,"Text10",null,null,null,null,null,"|",null)%>
				<cellbytelabel id="2">Estado</cellbytelabel><!-- Atenci&oacute;n-->:
				<%=fb.checkbox("statusE","E",(statusE != null && !statusE.trim().equals("")),false,null,null,null)%> <img src="../images/lampara_rojo.png" alt="En Espera de Atenci&oacute;n"> <cellbytelabel id="3">En Espera de Atenci&oacute;n</cellbytelabel>
				<%=fb.checkbox("statusT","T",(statusT != null && !statusT.trim().equals("")),false,null,null,null)%> <img src="../images/lampara_amarillo.png" alt="Triage Registrado"> <cellbytelabel id="4">Triage Registrado</cellbytelabel>
				<%=fb.checkbox("statusP","P",(statusP != null && !statusP.trim().equals("")),false,null,null,null)%> <img src="../images/lampara_verde.png" alt="Atenci&oacute;n en Proceso"> <cellbytelabel id="5">Atenci&oacute;n en Proceso</cellbytelabel>
				<%=fb.checkbox("statusF","F",(statusF != null && !statusF.trim().equals("")),false,null,null,null)%> <img src="../images/lampara_blanco.png" alt="Atenci&oacute;n Finalizada"> <cellbytelabel id="6">Atenci&oacute;n Finalizada</cellbytelabel>
				<%=fb.checkbox("statusZ","Z",(statusZ != null && !statusZ.trim().equals("")),false,null,null,null)%> <img src="../images/lampara_gris.png" alt="Atenci&oacute;n Finalizada"> <cellbytelabel id="6">Exp inabilitado</cellbytelabel>
			</td>
		</tr>
		<tr class="TextFilter">
			<td colspan="2" class="Text10">
<% if (fp.trim().equals("")) { %>
				<%//=fb.select(ConMgr.getConnection(),"select codigo, lpad(codigo,3,'0')||' - '||descripcion, codigo from tbl_cds_centro_servicio where codigo in ("+xCds+") order by descripcion","cds",cds,false,false,0,"Text10",null,autoSearch?"onChange=\"javascript:doSearch()\"":"",null,(xCds.indexOf(",")==-1)?"":"T")%>
				<%
					//xmlRdr.setXmlPath("D:/Projects/cellbytedemo/build/web/xml"); //Si queren cambiar la ruta raiz del xml
					//xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId")); //regresa todo el xml
					//xmlRdr.read(xr.xmlPath+"/cds_all.xml",(String) session.getAttribute("_companyId"),false,"0,77,76"); //true: excluye los valores separados por coma; false: imprime solamente los valores separados por coma
				%>
				<%=fb.select("cds",xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId"),false,xCds),cds,false,false,0,"Text10",null,autoSearch?"onChange=\"javascript:doSearch()\"":"",null,(xCds.indexOf(",")==-1)?"":"T")%>
<% } else if (fp.equalsIgnoreCase("aseguradora")) { %>
				<%=fb.select(ConMgr.getConnection(),"select codigo, nombre, codigo from tbl_adm_empresa where estado='A'"+((UserDet.getRefType().equalsIgnoreCase("A"))?" and codigo="+UserDet.getRefCode():"")+" order by nombre","aseguradora",aseguradora,false,false,0,"Text10",null,autoSearch?"onChange=\"javascript:doSearch()\"":"",null,((UserDet.getUserProfile().contains("0"))?"T":""))%>
				<cellbytelabel id="2">Categor&iacute;a</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_adm_categoria_admision","categoria",categoria,false,false,0,"Text10",null,null,null,"T")%>
<% } else if (fp.equalsIgnoreCase("medico")) { %>
				<%=fb.select(ConMgr.getConnection(),"select codigo, primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||', '||primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre) as nombreMedico, codigo as etiqueta from tbl_adm_medico where estado='A'"+((UserDet.getRefType().equalsIgnoreCase("M"))?" and codigo='"+UserDet.getRefCode()+"'":"")+" order by 2","medico",medico,false,false,0,"Text10",null,autoSearch?"onChange=\"javascript:doSearch()\"":"",null,((UserDet.getUserProfile().contains("0"))?"T":""))%>
<% } %>
				<cellbytelabel id="7">Fecha Atenci&oacute;n</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="careDate" />
				<jsp:param name="valueOfTBox1" value="<%=careDate%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				<cellbytelabel id="8">Fecha Nac.</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="dob" />
				<jsp:param name="valueOfTBox1" value="<%=dob%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				<cellbytelabel id="9">C&oacute;d. Pac.</cellbytelabel>
				<%=fb.intBox("codigo","",false,false,false,5,"Text10",null,null)%>
				<cellbytelabel id="10">No. Adm.</cellbytelabel>
				<%=fb.intBox("noAdmision","",false,false,false,3,5,"Text10",null,null)%>
				<cellbytelabel id="11">Barcode</cellbytelabel>
				<%=fb.textBox("pacBarcode","",false,false,false,20,"Text10",null,null)%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td colspan="2" class="Text10">
				<cellbytelabel id="12">C&eacute;dula/Pasaporte</cellbytelabel>
				<%=fb.textBox("cedulaPasaporte","",false,false,false,15,"Text10",null,null)%>
				<cellbytelabel id="13">Paciente</cellbytelabel>
				<%=fb.textBox("paciente","",false,false,false,40,"Text10",null,null)%>
				<cellbytelabel id="14">Fecha Ingreso</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fDate" />
				<jsp:param name="valueOfTBox1" value="<%=fDate%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				<!--jsp:param name="nameOfTBox2" value="tDate" /-->
				<!--jsp:param name="valueOfTBox2" value="<%=tDate%>" /-->
				&nbsp;&nbsp;
				<cellbytelabel>Sexo</cellbytelabel>

				<%=fb.select("sexo","F=Femenino,M=Masculino",sexo, false,false,0,"Text10",null,null,null,"T")%>&nbsp;
				<%=fb.button("go","Ir",false,false,"Text10",null,"onClick=\"javascript:doSearch()\"")%>
			</td>
		</tr>
<%fb.appendJsValidation("if((document.main.fDate.value!='' && !isValidateDate(document.main.fDate.value))||(document.main.dob.value!='' &&!isValidateDate(document.main.dob.value) )||(document.main.careDate.value!='' && !isValidateDate(document.main.careDate.value)) ){alert('Formato de fecha inválida!');error++;}");%>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
<tr>
	<td height="20">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<!--<tr>
			<td width="15%">&nbsp;</td>
			<td width="70%" align="center"><font size="3" id="ordMedMsg" style="display:none">Hay Ordenes M&eacute;dicas pendientes!</font><embed id="ordMedSound" src="../media/chimes.wav" width="0" height="0" autostart="false" hidden="true" loop="true"></embed><script language="javascript">blinkId('ordMedMsg','red','white');</script></td>
			<td width="15%" align="right">&nbsp;<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></td>
		</tr>-->
		<tr>
			<td width="15%">&nbsp;</td>
			<td width="70%" align="center"><font size="3" id="pendingMsg" style="display:none"><cellbytelabel id="15"><%=(UserDet.getRefType().trim().equals("M")||UserDet.getXtra5().trim().equals("S"))?"Hay Ordenes M&eacute;dicas Rechazadas pendientes por Confirmar":"Hay Ordenes M&eacute;dicas pendientes"%></cellbytelabel>!</font><script language="javascript">blinkId('pendingMsg','red','white');</script><!--<embed id="pendingSound" src="../media/chimes.wav" autostart="false" width="0" height="0"></embed>--></td>
			<td width="15%" align="right">&nbsp;<a href="javascript:printList()" class="Link00">[ <cellbytelabel id="16">Imprimir Lista</cellbytelabel> ]</a></td>
		</tr>

		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%">&nbsp;</td>
			<td width="40%"><cellbytelabel id="17">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><label id="timerMsgTop"></label></td>
			<td width="10%" align="right">&nbsp;</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder" align="center">
		<table width="100%" border="0" cellpadding="1" cellspacing="1">
		<tr class="TextRow05"><!-- height="28"-->
			<td width="10%" class="TextHeader" align="center"><cellbytelabel id="18">Aseguradora</cellbytelabel></td>
			<td width="13%"><label id="aseguradoraDesc"></label></td>
			<td width="7%" class="TextHeader" align="center"><cellbytelabel id="19">Fecha de Nacimiento</cellbytelabel></td>
			<td width="7%"><label id="fNacimiento"></label></td>
			<td width="5%" id="camaId" align="center"><label id="camaLabel" style="display:none"><cellbytelabel id="20">Cama</cellbytelabel></label></td>
			<td width="9%"><label id="camaDesc" style="display:none"></label></td>
			<td width="6%" class="TextHeader" align="center"><cellbytelabel id="21">M&eacute;dico</cellbytelabel></td>
			<td width="35%"><label id="medicoDesc"></label></td>
			<td width="5%" class="TextHeader" align="center"><label id="cdsLabel"><cellbytelabel id="22">&Aacute;rea</cellbytelabel></label></td>
			<td width="3%"><label id="cdsDesc"></label></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<%fb = new FormBean("form01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("index","-1")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("tmpIntUrl","")%>
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tbody id="list">
		<tr class="TextHeader" align="center">
			<td width="2%"><cellbytelabel id="23">N.E.</cellbytelabel></td>
			<td width="2%">&nbsp;</td>
			<td width="2%"><cellbytelabel id="24">Cat.</cellbytelabel></td>
			<td width="7%"><cellbytelabel id="8">Fecha Nac.</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="25">C&oacute;d. Exp</cellbytelabel>.</td>
			<td width="6%"><cellbytelabel id="9">C&oacute;d. Pac</cellbytelabel>.</td>
			<td width="3%"><cellbytelabel id="10">Adm</cellbytelabel>.</td>
			<td width="13%"><cellbytelabel id="26">C&eacute;dula / Pasaporte</cellbytelabel></td>
			<td width="27%"><cellbytelabel id="13">Paciente</cellbytelabel></td>
			<td width="3%"><cellbytelabel id="27">Edad</cellbytelabel></td>
			<td width="2%">S</td>
			<td width="2%">A</td>
			<td width="2%">C</td>
			<td width="6%"><cellbytelabel id="28">O.M. Ejec</cellbytelabel>.</td>
			<td width="9%"><cellbytelabel id="14">Fecha Ingreso</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="2">Estado</cellbytelabel><!-- Atenci&oacute;n--></td>
			<td width="3%"><img src="../images/refresh.png" height="20" width="20" onClick="javascript:reloadPage()" style="cursor:pointer" alt="Actualizar Listado!"></td>
		</tr>
<%
int gExe = 0,gConf=0,gDesap=0;
int gTot = 0;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (cdo.getColValue("matches").equals("1")) color += " VerdeAqua";

	String statusDisplay = "";
	if (cdo.getColValue("estadoAtencion").equalsIgnoreCase("E")) statusDisplay = "<img src=\"../images/lampara_rojo.png\" alt=\"En Espera de Atenci&oacute;n\">";
	else if (cdo.getColValue("estadoAtencion").equalsIgnoreCase("T")) statusDisplay = "<img src=\"../images/lampara_amarillo.png\" alt=\"Triage Registrado\">";
	else if (cdo.getColValue("estadoAtencion").equalsIgnoreCase("P")) statusDisplay = "<img src=\"../images/lampara_verde.png\" alt=\"Atenci&oacute;n en Proceso\">";
	else if (cdo.getColValue("estadoAtencion").equalsIgnoreCase("F")) statusDisplay = "<img src=\"../images/lampara_blanco.png\" alt=\"Atenci&oacute;n Finalizada\">";
	else if (cdo.getColValue("estadoAtencion").equalsIgnoreCase("Z")) statusDisplay = "<img src=\"../images/lampara_gris.png\" alt=\"Expediente inabilitado\">";

	String neIcon = "../images/blank.gif";
	String meIcon = "../images/blank.gif";
	String neIconDesc = "";
	if (cdo.getColValue("neIcon").equals("1")) { neIcon = "../images/check.gif"; neIconDesc = "Nota de Enf. Finalizada!"; }
	else if (cdo.getColValue("neIcon").equals("-1")) { neIcon = "../images/flag_red.png"; neIconDesc = "Nota de Enf. Pendiente!"; }

	String displayIcon = "../images/blank.gif";
	String displayIconDesc = "";
	if (cdo.getColValue("displayIcon").equals("1")) { displayIcon = "../images/syringe.gif"; displayIconDesc = "Inyectable!"; }

	String catColor = "RedTextBold";
	if (cdo.getColValue("cat_triage").equals("1")) catColor = "span-circled-red";
	else if (cdo.getColValue("cat_triage").equals("2")) catColor = "span-circled-yellow";
	else if (cdo.getColValue("cat_triage").equals("3")) catColor = "span-circled-green";

	int sep = cdo.getColValue("nOrdenMedExec").indexOf("/");
	int exe = Integer.parseInt(cdo.getColValue("nOrdenMedExec").substring(0,sep));
	int tot = Integer.parseInt(cdo.getColValue("nOrdenMedExec").substring(sep+1));
	sep = cdo.getColValue("nOrdenMedDesap").indexOf("/");
	int conf = Integer.parseInt(cdo.getColValue("nOrdenMedDesap").substring(0,sep));
	int totDesap = Integer.parseInt(cdo.getColValue("nOrdenMedDesap").substring(sep+1));
	if ((vCatShowRejected.contains("-") || vCatShowRejected.contains(cdo.getColValue("categoria"))) && totDesap != 0) {
		gExe += exe;
		gTot += tot;
		gConf += conf;
		gDesap += totDesap;
	}
%>
<%=fb.hidden("expId"+i,cdo.getColValue("expedienteid"))%>
<%=fb.hidden("pacId"+i,cdo.getColValue("pacId"))%>
<%=fb.hidden("nombrePaciente"+i,cdo.getColValue("nombrePaciente"))%>
<%=fb.hidden("expedienteId"+i,cdo.getColValue("expedienteId"))%>
<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
<%=fb.hidden("estadoAtencion"+i,cdo.getColValue("estadoAtencion"))%>
<%=fb.hidden("fecha_nacimiento"+i,cdo.getColValue("fechaNacimiento"))%>
<%=fb.hidden("codPac"+i,cdo.getColValue("codigoPaciente"))%>
<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
<%=fb.hidden("cds"+i,cdo.getColValue("cds"))%>
<%=fb.hidden("cdsDisplay"+i,cdo.getColValue("cdsDisplay"))%>
<%=fb.hidden("cama"+i,cdo.getColValue("cama"))%>
<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
<%=fb.hidden("secuenciaCorte"+i,cdo.getColValue("secuenciaCorte"))%>
<%=fb.hidden("tipoAdmision"+i,cdo.getColValue("tipoAdmision"))%>
<%=fb.hidden("pacIdMadre"+i,cdo.getColValue("pac_id_madre"))%>
<%=fb.hidden("cedulaPasaporte"+i,cdo.getColValue("cedulaPasaporte"))%>
<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
<%=fb.hidden("f_nac"+i,cdo.getColValue("f_nac"))%>
<%=fb.hidden("cdsAdm"+i,cdo.getColValue("cdsAdm"))%>

		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><img src="<%=neIcon%>" title="<%=neIconDesc%>" height="20" width="20"></td>
			<td align="center"><img src="<%=displayIcon%>" title="<%=displayIconDesc%>" height="20" width="20"></td>
			<td align="center" class="RedTextBold">&nbsp;<label  class="<%=color%>" style="cursor:pointer"><label class="<%=catColor%>">&nbsp;&nbsp;<a <% if (!cdo.getColValue("cat_triage").equals("0")) { %>onClick="javacript:if(typeof changeTriageCat === 'function')changeTriageCat(<%=cdo.getColValue("pacId")%>,<%=cdo.getColValue("secuencia")%>)"<% } %>><%=cdo.getColValue("categoriaSigno")%></a>&nbsp;&nbsp;</label></label>&nbsp;</td>
			<td align="center"><%=cdo.getColValue("f_nac")%></td>
			<td align="center"><%=cdo.getColValue("expedienteId")%></td>
			<td align="center"><%=cdo.getColValue("pacId")%></td>
			<td align="center" onMouseOver="javascript:displayValue(<%=i%>,'AdmCorte','<%=(!cdo.getColValue("secuenciaCorte").equals(cdo.getColValue("secuencia")))?cdo.getColValue("secuenciaCorte"):""%>');" onMouseOut="javascript:displayValue(<%=i%>,'AdmCorte','');"><%=cdo.getColValue("secuencia")%> <label id="lblAdmCorte<%=i%>"></label></td>
			<td><%=cdo.getColValue("cedulaPasaporte")%></td>

			<td onMouseOver="javascript:displayElementValue('lblPacId<%=i%>','[<%=cdo.getColValue("pacId")%>]');" onMouseOut="javascript:displayElementValue('lblPacId<%=i%>','');">
			<label onClick="javascript:AbrirExp(<%=i%>)" class="<%=color%>" style="cursor:pointer">
			<%//=cdo.getColValue("nombrePaciente")%>

			<%
				String idF = cdo.getColValue("idFidelizacion");
				String cssClass = "d";
				String eaClass = (cdo.getColValue("estadoAtencion")!=null && cdo.getColValue("estadoAtencion").equals("R")?"class='react react-bg'":"style='display:none;'");
				if (idF.trim().equals("S")) cssClass = " vip-vip";
				else if (idF.trim().equals("D")) cssClass = " vip-dis";
				else if (idF.trim().equals("J")) cssClass = " vip-jd";
				else if (idF.trim().equals("M")) cssClass = " vip-med";
				else if (idF.trim().equals("A")) cssClass = " vip-acc";
				else if (idF.trim().equals("E")) cssClass = " vip-emp";
				else if (idF.trim().equals("AC")) {
									cssClass = " alerta-cribado";
									cdo.addColValue("vip_dsp", "CRIBADO NUTRICIONAL");
								}
								else if (idF.trim().equals("HO")) {
									cssClass = " alerta-handover";
									cdo.addColValue("vip_dsp", "HANDOVER");
								}

				if (idF != null && !idF.trim().equals("N")){
				%>
					<span class="vip<%=cssClass%>" title="<%=cdo.getColValue("vip_dsp")%>"><%=cdo.getColValue("nombrePaciente")%></span>
				<%}else{%>
					 <%=cdo.getColValue("nombrePaciente")%>
				<%}%>


			</label><label id="lblPacId<%=i%>"></label>

			<!--<a href="javascript:ordenDesap(<%=cdo.getColValue("pacId")%>, <%=cdo.getColValue("secuenciaCorte")%>)"></a>-->

		<%


	if ((vCatShowRejected.contains("-") || vCatShowRejected.contains(cdo.getColValue("categoria"))) && totDesap != 0)
	{
	if(conf != totDesap)meIcon = "../images/icono_medic_rechazado.png";
	else meIcon = "../images/medic_confirma.png";

%>				<img src="<%=meIcon%>" title="OM RECHAZADAS" height="20" width="20" border="0">
				<label style="display:none"><%=totDesap%>.<%=conf%></label>
				<label class="<%=color%>">&nbsp;&nbsp;<label<%=(conf != totDesap)?" style=\"color: red\"":""%>><%=conf%>/<%=totDesap%></label>&nbsp;&nbsp;</label>
				<img src="../images/dwn.gif" onClick="javascript:showPopWin('../expediente/expediente_ordenes_medicas_confirm.jsp?pacId=<%=cdo.getColValue("pacId")%>&secuencia=<%=cdo.getColValue("secuencia")%>&id=<%=i%><%=(fp.equalsIgnoreCase("aseguradora"))?"&mode=view":""%>',winWidth*.95,winHeight*.60,null,null,'')" style="cursor:pointer" title="ORDENES MEDICAS RECHAZADAS POR FARMACIA">
<%
	}
%>

			</td>
			<td align="center"><%=cdo.getColValue("edad")%></td>

			<td align="center">
				<% if (!cdo.getColValue("omSalida").equals("0")) { %><span class="span-circled span-circled-20 span-circled-green" data-content="" title="OM SALIDA X EJECUTAR"></span><% } %>
			</td>
			<td align="center"><% if (cdo.getColValue("alergias").trim().equals("")) { %>&nbsp;<% } else { %><span class="span-circled span-circled-20 span-circled-red" data-content="" title="ALERGICO A --> <%=cdo.getColValue("alergias")%>"></span><% } %></td>
			<td align="center"><% if (cdo.getColValue("riesgo").equalsIgnoreCase("S")) { %><span class="span-circled span-circled-20 span-circled-yellow" data-content="C" title="RIESGO DE CAIDA"></span><% } else { %>&nbsp;<% } %></td>

			<%--<td align="right">
<%
	//if (tot != 0)
	//{
%>
				<label<%//=(exe != tot)?" style=\"color: red\"":""%>><%//=exe%>/<%//=tot%></label>
				<img src="../images/dwn.gif" onClick="javascript:diFrame('list','9','rs<%//=i%>','950','225','0','0','1','DIVExpandRowsScroll',true,'0','../expediente/expediente_ordenes_medicas.jsp?pacId=<%//=cdo.getColValue("pacId")%>&secuencia=<%//=cdo.getColValue("secuencia")%>&id=<%//=i%>',false)" style="cursor:pointer">
<%
	//}
%>
			</td>--%>
			<td align="right"<%//=(tot != 0)?" onClick=\"javascript:showPopWin('../expediente/expediente_ordenes_medicas.jsp?pacId="+cdo.getColValue("pacId")+"&secuencia="+cdo.getColValue("secuencia")+"&id="+i+((fp.equalsIgnoreCase("aseguradora"))?"&mode=view":"")+"',winWidth*.95,winHeight*.90,null,null,'')\" style=\"cursor:pointer\"":""%>>
<%
	if (tot != 0)
	{
%>				<label style="display:none"><%=tot%>.<%=exe%></label>
				<label class="<%=color%>">&nbsp;&nbsp;<label<%=(exe != tot)?" style=\"color: red\"":""%>><%=exe%>/<%=tot%></label>&nbsp;&nbsp;</label>
				<img src="../images/dwn.gif" onClick="javascript:showPopWin('../expediente/expediente_ordenes_medicas.jsp?pacId=<%=cdo.getColValue("pacId")%>&secuencia=<%=cdo.getColValue("secuencia")%>&id=<%=i%><%=(fp.equalsIgnoreCase("aseguradora"))?"&mode=view":""%>&nombre=<%=IBIZEscapeChars.forURL(cdo.getColValue("nombrePaciente"))%>&cedula=<%=IBIZEscapeChars.forURL(cdo.getColValue("cedulaPasaporte"))%>&cama=<%=IBIZEscapeChars.forURL(cdo.getColValue("cama"))%>&edad=<%=cdo.getColValue("edad")%>&sexo=<%=cdo.getColValue("sexo")%>',winWidth*.98,winHeight*.90,null,null,'')" style="cursor:pointer">
<%
	}
%>
			</td>

			<td align="center"><label style="display:none"><%=cdo.getColValue("fechaIngresoSort")%></label><%=cdo.getColValue("fechaIngreso")%></td>
			<td align="center" onMouseOver="javascript:displayValue(<%=i%>,'Status','<%=cdo.getColValue("estado")%>');" onMouseOut="javascript:displayValue(<%=i%>,'Status','');"><label style="display:none"><%=cdo.getColValue("estadoAtencion")%></label><%=statusDisplay%>
			<span <%=eaClass%> title="Expediente Reactivado">&nbsp;</span>
			<label id="lblStatus<%=i%>"></label></td>
			<td align="center"><%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%
}
%>
		</tbody>
		</table>
<%=fb.hidden("gExe",""+gExe)%>
<%=fb.hidden("gTot",""+gTot)%>
<%=fb.hidden("gConf",""+gConf)%>
<%=fb.hidden("gDesap",""+gDesap)%>
<%=fb.formEnd()%>
		</div>
		</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%">&nbsp;</td>
			<td width="40%"><cellbytelabel id="17">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><label id="timerMsgBottom"></label></td>
			<td width="10%" align="right">&nbsp;</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="Text10">
		<img src="../images/flag_red.png" title="NOTA DE ENF. PENDIENTE" height="16" width="16">N. ENF. PEND.
		<img src="../images/check.gif" title="NOTA DE ENF. FINALIZADA" height="16" width="16">N. ENF. FINAL.
		<img src="../images/syringe.gif" title="INYECTABLE" height="16" width="16">INYECTABLE
		<label class="span-circled-red" title="CRITICO">&nbsp;&nbsp;I&nbsp;&nbsp;</label>CRITICO
		<label class="span-circled-yellow" title="URGENTE">&nbsp;&nbsp;II&nbsp;&nbsp;</label>URGENTE
		<label class="span-circled-green" title="NO URGENTE">&nbsp;&nbsp;III&nbsp;&nbsp;</label>NO URGENTE
		<span class="span-circled span-circled-20 span-circled-green" data-content="S" title="OM SALIDA X EJECUTAR"></span>OM SALIDA X EJECUTAR
		<span class="span-circled span-circled-20 span-circled-red" data-content="A" title="ALERGICO"></span>ALERGICO
		<span class="span-circled span-circled-20 span-circled-yellow" data-content="C" title="RIESGO DE CAIDA"></span>RIESGO DE CAIDA
		<span title="VIP" class="vip vip-vip">VIP</span>
		<span title="DISTINGUIDO" class="vip vip-dis">DISTINGUIDO</span>
		<span title="JUNTA DIRECTIVA" class="vip vip-jd">JUNTA DIRECTIVA</span>
		<span title="STAFF MEDICO" class="vip vip-med">STAFF MEDICO</span>
		<span title="ACCIONISTA" class="vip vip-acc">ACCIONISTA</span>
		<span title="EMPLEADO" class="vip vip-emp">EMPLEADO</span>
<% if (expVersion.equalsIgnoreCase("3")) { %>
		<span title="CRIBADO NUTRICIONAL" class="vip alerta-cribado">CRIBADO NUTRICIONAL</span>
		<span title="HANDOVER" class="vip alerta-handover">HANDOVER</span>
<% } %>
		<img src="../images/icono_medic_rechazado.png" title="OM RECHAZADAS" height="16" width="16">OM RECHAZADAS
		<img src="../images/medic_confirma.png" title="OM RECHAZADAS X CONFIRMAR" height="16" width="16">OM RECHAZADAS X CONF.
	</td>
</tr>
</table>
</body>
</html>
<!--<authtype type='72'>--><script language="javascript">
function changeTriageCat(pacId,admision) {
	showPopWin('../process/exp_change_triage_cat.jsp?pacId='+pacId+'&admision='+admision+'&careDate=<%=careDate%>',winWidth*.75,winHeight*.65,null,null,'');
}
</script><!--</authtype>-->
<%
}
%>
