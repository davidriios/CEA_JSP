<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
Reporte sal10010
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
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
Properties prop = new Properties();
String compania = (String) session.getAttribute("_companyId");

String showVC = ""; // Valores Críticos
boolean forceTriageESI = false; //Forzar etiquetas Triage ESI
boolean useAdmFilter = false;
CommonDataObject c1 = SQLMgr.getData("select nvl(get_sec_comp_param("+compania+",'SAL_SHOW_VAL_CRITICOS'),'N') as show_vc, nvl(get_sec_comp_param("+compania+",'EXP_FORCE_TRIAGE_ESI_LABEL'),'N') as force_triage_esi, nvl(get_sec_comp_param("+compania+",'EXP_ANT_USE_ADM_FILTER'),'N') as use_adm_filter from dual ");
if (c1==null) {
	c1 = new CommonDataObject();
}
showVC = c1.getColValue("show_vc","N");
forceTriageESI = (c1.getColValue("force_triage_esi","N").equalsIgnoreCase("Y") || c1.getColValue("force_triage_esi","N").equalsIgnoreCase("S"));
useAdmFilter = "SY".contains(c1.getColValue("use_adm_filter"));
StringBuffer sbSql = new StringBuffer();

String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String fg = request.getParameter("fg")==null?"":request.getParameter("fg");
String fp = request.getParameter("fp")==null?"":request.getParameter("fp");
String factura = request.getParameter("factura");
String listId = request.getParameter("listId");
String categoria = request.getParameter("categoria");
String categoria_desc = request.getParameter("categoria_desc");
String yearList = request.getParameter("yearList");
String mesList = request.getParameter("mesList");
String exp = request.getParameter("exp");
if (yearList == null) yearList = "0";
if (mesList == null) mesList = "";
if (factura == null) factura = "";
if (listId == null) listId = "";
if (categoria == null) categoria = "";
if (categoria_desc == null) categoria_desc = "";
if (exp == null) exp = "";

if (appendFilter == null) appendFilter = "";
ArrayList alVC = new ArrayList();

if (showVC.equals("Y")){
	sbSql.append(" select to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fc, b.descripcion, a.valor, a.observacion, c.descripcion as cds from tbl_sal_val_criticos a, tbl_sal_cds_val_criticos b, tbl_cds_centro_servicio c where a.codigo_valor = b.codigo and a.compania = ");
	sbSql.append(compania);
	sbSql.append(" and b.cds = c.codigo and a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.admision = ");
	sbSql.append(noAdmision);
	sbSql.append(" order by a.fecha_creacion");

	alVC = SQLMgr.getDataList(sbSql.toString());
}

if (cds == null) {
	sbSql = new StringBuffer();
	sbSql.append("(select cds from tbl_adm_atencion_cu where pac_id = ")
			 .append(pacId)
			 .append(" and secuencia = ")
			 .append(noAdmision)
			 .append(")");
	cds = sbSql.toString();
}

sbSql = new StringBuffer();
sbSql.append("select  ( select listagg(descripcion,';') within group(order by descripcion) descripcion from (select all nvl(decode(p.observacion,null,p.descripcion,p.observacion),det.nombre) descripcion  from tbl_sal_detalle_orden_med det, tbl_sal_orden_medica ord ,tbl_cds_procedimiento p where ord.codigo = det.orden_med and det.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and det.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and ord.secuencia = det.secuencia and ord.pac_id =  det.pac_id and det.tipo_orden = 1 and p.codigo=det.procedimiento and det.centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz ='RIS') and det.ejecutado = 'S' and det.estado_orden not in ('O','S') order by 1 )) img, ( select listagg(descripcion,';') within group(order by descripcion) descripcion from (select all nvl(decode(p.observacion,null,p.descripcion,p.observacion),det.nombre) descripcion from tbl_sal_detalle_orden_med det, tbl_sal_orden_medica ord ,tbl_cds_procedimiento p where ord.codigo = det.orden_med and det.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and det.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and ord.secuencia = det.secuencia and ord.pac_id =  det.pac_id and det.tipo_orden = 1 and p.codigo=det.procedimiento and det.centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz ='LIS') and det.ejecutado = 'S' and det.estado_orden not in ('O','S') order by 1 )) lab, ( select listagg(descripcion,';') within group(order by descripcion) descripcion from ( select all descripcion from tbl_sal_resultado_ekg where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" )) ekg, ( select listagg(descripcion,';') within group(order by descripcion) descripcion from (select all nvl(descripcion,' ') as descripcion from tbl_sal_procedimiento_paciente a, tbl_sal_detalle_orden_med b where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and a.pac_id =b.pac_id and a.secuencia = b.secuencia and a.orden = b.orden_med and a.orden_det = b.codigo and b.tipo_orden = 12 and b.ejecutado= 'S' and b.estado_orden not in ('O','S'))) procedimiento, ( select listagg(tratamiento,';') within group(order by tratamiento) tratamiento from ( select all b.descripcion||' [ '||decode(a.observacion,null,null,a.observacion)||' ] ' tratamiento  from tbl_sal_tratamiento_paciente a, tbl_sal_tratamiento b,tbl_sal_detalle_orden_med om where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and a.cod_tratamiento = b.codigo and a.seleccionar = 'S' and a.pac_id =om.pac_id and a.secuencia = om.secuencia and a.orden = om.orden_med and a.orden_det = om.codigo and om.tipo_orden = 4 and om.ejecutado= 'S' and om.estado_orden not in ('O','S'))) tratamiento, ( select listagg(medicamento,';') within group(order by medicamento) medicamento from (select all nvl(s.medicamento,' ')/*||' '|| nvl(s.dosis,' ')*/||' '||nvl(g.descripcion,' ')||' '||nvl(s.cod_frecuencia,' ')||' '|| nvl(v.descripcion ,' ') medicamento  from tbl_sal_medicacion_paciente s ,tbl_sal_grupo_dosis g,tbl_sal_via_admin v,tbl_sal_detalle_orden_med b where s.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and s.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and g.codigo(+) = s.cod_grupo_dosis and v.codigo = s.via_admin and s.pac_id =b.pac_id and s.secuencia = b.secuencia and s.orden = b.orden_med and s.orden_det = b.codigo and b.tipo_orden = 2 and b.ejecutado= 'S' and b.estado_orden not in ('O','S'))) medicamento, ( select listagg(descripcion,';') within group(order by descripcion) descripcion from ( select all descripcion from tbl_SAL_ANTECEDENT_MEDICAMENTO where pac_id = ");
sbSql.append(pacId);
if (useAdmFilter) {
	sbSql.append(" and admision = ");
	sbSql.append(noAdmision);
}
sbSql.append("  )) antMedicamento, nvl(hr.dolencia_principal,' ')dolencia  ,nvl(hr.observacion,' ') historia, ( select listagg(observacion,';') within group(order by observacion) observacion from ( select all nvl(b.descripcion,' ') ||'('||nvl(decode(a.observacion,null,null,a.observacion),' ')||')' observacion from tbl_sal_antecedente_personal a, tbl_sal_diagnostico_personal b where  a.pac_id = ");
sbSql.append(pacId);
if (useAdmFilter) {
	sbSql.append(" and a.admision = ");
	sbSql.append(noAdmision);
}
sbSql.append("  and a.antecedente = b.codigo and a.valor = 'S' union all select all nvl(b.descripcion,' ') ||'('||nvl(decode(a.observacion,null,null,a.observacion),' ')||')' observacion from tbl_sal_enfermedad_operacion a, tbl_sal_parametro b where a.pac_id(+)=");
sbSql.append(pacId);
if (useAdmFilter) {
	sbSql.append(" and a.admision(+) = ");
	sbSql.append(noAdmision);
}
sbSql.append(" and b.tipo='PEO' and  a.parametro_id(+)=b.id and nvl(a.seleccionado,'N') ='S' )) eAnteriores /* --ENFERMEDADES ( select listagg(observacion,';') within group(order by observacion) observacion from (select all nvl(b.descripcion,' ') ||'('||nvl(decode(a.observacion,null,null,a.observacion),' ')||')' observacion from tbl_sal_enfermedad_operacion a, tbl_sal_parametro b where a.pac_id(+)=");
sbSql.append(pacId);
sbSql.append(" and b.tipo='PEO' and  a.parametro_id(+)=b.id and nvl(a.seleccionado,'N') ='S'  order by a.observacion desc )) efn */, (select nvl(join(cursor(select (select descripcion from tbl_sal_tipo_alergia where codigo = z.tipo_alergia)||' ('||nvl(z.observacion,'  ')||')' from (select distinct a.tipo_alergia, join(cursor(select observacion from tbl_sal_alergia_paciente where pac_id = a.pac_id and aplicar = 'S' and tipo_alergia = a.tipo_alergia and observacion is not null order by admision),', ') as observacion from tbl_sal_alergia_paciente a where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.admision = ");
sbSql.append(noAdmision);
sbSql.append(" and a.aplicar = 'S') z),'; '),(select pa.alergico_a from tbl_sal_padecimiento_admision pa where pa.pac_id=");
sbSql.append(pacId);
sbSql.append(" and pa.secuencia =");
sbSql.append(noAdmision);
sbSql.append(")) alergias from dual ) alergias");

//last triage or vital signs (before changes, it was the first one)
sbSql.append(", ( select listagg(signo,';') within group(order by signo) signo from (select all b.descripcion||': '||a.resultado||' ' signo from tbl_sal_detalle_signo a, tbl_sal_signo_vital b where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" /*and a.tipo_persona = 'T'*/ and exists (select null from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia and fecha = a.fecha_signo and hora = a.hora and tipo_persona = a.tipo_persona and status = 'A') and a.signo_vital = b.codigo /*and a.hora = (select max(ds.hora) from tbl_sal_detalle_signo ds where ds.pac_id = a.pac_id and ds.secuencia = a.secuencia and exists (select null from tbl_sal_signo_paciente where pac_id = ds.pac_id and secuencia = ds.secuencia and fecha = ds.fecha_signo and hora = ds.hora and tipo_persona = ds.tipo_persona and status = 'A'))*/  and a.hora = (select max(hora) from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia /*and tipo_persona = 'T'*/ and status = 'A'))) signos");


//sbSql.append(" /*and a.tipo_persona = 'T' */ and exists (select null from tbl_sal_signo_paciente where pac_id = a.pac_id and secuencia = a.secuencia and fecha = a.fecha_signo and hora = a.hora and tipo_persona = a.tipo_persona and status = 'A') and a.signo_vital = b.codigo and a.hora = (select max(ds.hora) from tbl_sal_detalle_signo ds where ds.pac_id = a.pac_id and ds.secuencia = a.secuencia and exists (select null from tbl_sal_signo_paciente where pac_id = ds.pac_id and secuencia = ds.secuencia and fecha = ds.fecha_signo and hora = ds.hora and tipo_persona = ds.tipo_persona and status = 'A')))) signos");

//last triage info
sbSql.append(", (select to_char(hora_registro,'hh12:mi:ss am') from tbl_sal_signo_paciente z where pac_id = a.pac_id and secuencia = a.secuencia and tipo_persona = 'T' and status = 'A' and hora = (select max(hora) from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and tipo_persona = 'T' and status = 'A')) as horaTriage");
sbSql.append(", (select ");
if (forceTriageESI || fg.equalsIgnoreCase("TSV_ESI")) sbSql.append("case when categoria between 1 and 3 then 'PRIORIDAD '||categoria else 'OTROS' end");
else sbSql.append("decode(categoria,1,'CRITICO',2,'URGENTE',3,'NO URGENTE','OTROS')");
sbSql.append(" from tbl_sal_signo_paciente z where pac_id = a.pac_id and secuencia = a.secuencia and tipo_persona = 'T' and status = 'A' and hora = (select max(hora) from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and tipo_persona = 'T' and status = 'A')) as categoriaTriage");
sbSql.append(", (select usuario_creacion from tbl_sal_signo_paciente z where pac_id = a.pac_id and secuencia = a.secuencia and tipo_persona = 'T' and status = 'A' and hora = (select max(hora) from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and tipo_persona = 'T' and status = 'A')) as usuario_creacion");

//sbSql.append(",  to_char(ss.hora,'hh12:mi:ss am') horaTriage, ");
//String triageCatLabel = "decode(ss.categoria,1,'CRITICO',2,'URGENTE',3,'NO URGENTE','OTROS')";
//if (forceTriageESI || fg.equalsIgnoreCase("TSV_ESI")) triageCatLabel = "case when ss.categoria between 1 and 3 then 'PRIORIDAD '||ss.categoria else 'OTROS' end";
//sbSql.append(triageCatLabel);
//sbSql.append(" categoriaTriage, ss.usuario_creacion");
//sbSq.append(", nvl(to_char(ss.hora_registro,'HH12:MI:SS AM'), ' ') as hora_registro");<--- no se usa

sbSql.append(", get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),null) as anio, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),'mm') as mes, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),'dd') as dias, b.nombre_paciente nombre_paciente,b.id_paciente cedula,b.seguro_social seguroSocial,nvl((SELECT primer_nombre||decode(segundo_nombre,null,' ','  '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ','  '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',' '||apellido_de_casada)) as nombre FROM tbl_adm_medico WHERE codigo=a.medico),' ')  as medico_atiende, a.medico, to_char(a.fecha_ingreso, 'dd/mm/yyyy')||' '||to_char (a.am_pm, 'hh12:mi:ss am') llegada, decode (b.sexo, 'M', 'MASCULINO', 'F', 'FEMENINO') sexo, nvl(to_char (b.f_nac, 'dd/mm/yyyy'), to_char (b.f_nac, 'dd/mm/yyyy')) f_nac,b.codigo codigo_paciente,a.pac_id pacId, a.secuencia admision, b.residencia_direccion direccion, b.telefono tel_residencia, nvl(b.lugar_trabajo, ' ') lugar_trabajo, nvl(b.telefono_trabajo, ' ') tel_trabajo, nvl(a.medico_cabecera, ' ') medico_cabecera, m.primer_nombre || ' ' || m.segundo_nombre || ' ' || decode(m.apellido_de_casada, null, m.primer_apellido || ' ' || m.segundo_apellido, m.apellido_de_casada) as nombre_medico_cab, ab.poliza, ab.certificado, ab.empresa, e.nombre nom_empresa, nvl(resp.nombre_responsable, ' ') nombre_responsable , nvl(resp.telefono_residencia, ' ') as tel_responsable, to_char (hr.hora, 'HH12:MI:SS AM') as hora_atencion, nvl(ne.categoria, ' ') categoria, ds.*, nvl(to_char (g.fum, 'dd/mm/yyyy'), ' ') fum, g.gestacion, g.parto, nvl(to_char(g.aborto), ' ') aborto, nvl(to_char(g.cesarea), ' ') cesarea,' ' AS embarazada,nvl(to_char(ne.hora,'hh12:mi:ss am'),' ') as hora_triage,b.sexo as sex, a.categoria categoria_adm");

// TABLES
sbSql.append(" from tbl_adm_admision a, vw_adm_paciente b, tbl_adm_medico m, tbl_adm_beneficios_x_admision ab, tbl_adm_empresa e, tbl_sal_antecedente_ginecologo g, tbl_sal_notas_enfermeria ne");
sbSql.append(", (select a.nombre as nombre_responsable, a.telefono_residencia, a.fecha_nacimiento, a.paciente, a.admision, a.pac_id from tbl_adm_responsable a where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.admision = ");
sbSql.append(noAdmision);
sbSql.append(" and estado = 'A') resp");
sbSql.append(",	tbl_sal_padecimiento_admision	hr");
sbSql.append(", (select b.primer_nombre||' '||b.segundo_nombre||' '||decode(b.apellido_de_casada,null,b.primer_apellido||' '||b.segundo_apellido,b.apellido_de_casada) as v_consulta_externa, decode(a.hospitalizar,'S','SI','N','NO') as hospitalizar, decode(a.transf,'S', (select transferido_a||'@@'||to_char(fecha_transferencia,'dd/mm/yyyy hh12:mi:ss am') from tbl_sal_cons_incap_transf where pac_id = a.pac_id and admision = a.secuencia and rownum = 1),a.transf) transf, nvl(to_char(a.hora_transf, 'HH12:MI AM'), ' ') as hora_transf, nvl(to_char (a.hora_salida, 'HH12:MI AM'), ' ') as hora_salida, a.cond, decode(a.cond,null,'','M','MEJOR' ,'I','IGUAL','S','PEOR','F','FALLECIO') as condicion, nvl(to_char(a.hora_incap),' ') hora_incap, nvl(to_char(a.horai_incap, 'HH12:MI AM'), ' ') horai_incap, nvl(to_char(a.horaf_incap, 'HH12:MI AM'), ' ') horaf_incap, nvl(to_char(a.dia_incap), ' ') dis_incap, nvl(to_char(a.diai_incap,'dd/mm/yyyy'), ' ') diai_incap, nvl(to_char(a.diaf_incap,'dd/mm/yyyy'), ' ') diaf_incap, nvl(nvl(a.icd10,a.cod_diag_sal), ' ') cod_diag_sal, nvl(decode(c.observacion,null,c.nombre,c.observacion), ' ') as observacion, d.primer_nombre||' '||d.segundo_nombre||' '||decode(d.apellido_de_casada,null,d.primer_apellido||' '||d.segundo_apellido,d.apellido_de_casada) as nombre_med_turno, nvl(a.cod_medico_turno,' ') as cod_med_turno, nvl(decode(a.hora_incap,null,decode(a.dia_incap,null,null,a.dia_incap||' DIA(S) DESDE '||to_char(a.diai_incap,'DD/MM/YYYY')||' HASTA '||to_char(a.diaf_incap,'DD/MM/YYYY')),a.hora_incap||' HORA(S) DESDE '||to_char(a.horai_incap,'HH12:MI AM')||' HASTA '||to_char(a.horaf_incap,'HH12:MI AM')), ' ') v_incapacidad,to_char(a.fec_nacimiento,'dd/mm/yyyy')as fec_nacimiento,a.cod_paciente,a.secuencia,nvl(a.instruccion_med,' ') as instruccion,nvl(a.especialista_p,' ')as especialista_p, nvl(a.observacion,' ') as observacion_salida, a.pac_id,(SELECT descripcion FROM tbl_adm_especialidad_medica WHERE codigo=a.cod_especialidad_ce) AS especialidad_nom, a.transf_sbar hospitalizacion_sbar, a.motivos_sbar, a.sbar_reporte, a.sbar_recibe from tbl_sal_adm_salida_datos a, tbl_adm_medico b,tbl_cds_diagnostico c,tbl_adm_medico d where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and a.cod_medico = b.codigo(+) and a.cod_diag_sal = c.codigo(+) and a.cod_medico_turno = d.codigo(+)) ds");

//FILTERS
sbSql.append(" where a.pac_id= ");
sbSql.append(pacId);
sbSql.append(" and a.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and a.pac_id = b.pac_id and m.codigo(+)=a.medico_cabecera and ab.pac_id(+)= a.pac_id and ab.admision(+) = a.secuencia and nvl(ab.estado(+),'A')= 'A' and ab.prioridad(+) = 1 and ab.empresa = e.codigo(+) and a.pac_id = resp.pac_id(+) and a.secuencia = resp.admision(+) and a.pac_id = hr.pac_id(+) and a.secuencia = hr.secuencia(+) and a.pac_id = ds.pac_id(+) and a.secuencia = ds.secuencia(+) and a.pac_id = g.pac_id(+) and a.secuencia = ne.secuencia(+) and a.pac_id = ne.pac_id(+)");
System.out.println("-->"+sbSql);
cdo = SQLMgr.getData(sbSql.toString());
if (cdo == null) cdo = new CommonDataObject();

sbSql = new StringBuffer();
sbSql.append("select a.descripcion, decode(b.normal,null,'No Evaluado',");
if (!exp.equals("")) sbSql.append("'A','Anormal','N','Normal'||");
else sbSql.append("'N','Normal','A',");
sbSql.append("decode(b.observaciones,null,'',' '||b.observaciones),'')||'  '||busca_caract(");
sbSql.append(pacId);
sbSql.append(",");
sbSql.append(noAdmision);
sbSql.append(", ");
sbSql.append(cds);
sbSql.append(",a.codigo) as observacion from tbl_sal_examen_areas_corp a, (select normal, cod_area, observaciones from tbl_sal_areas_corp_paciente where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noAdmision);
sbSql.append(") b, tbl_sal_examen_area_corp_x_cds c where a.codigo = b.cod_area(+) and a.codigo = c.cod_area and c.centro_servicio  = ");
sbSql.append(cds);
sbSql.append(" order by c.sec_orden, a.codigo");
//and a.codigo in (select cod_area from tbl_sal_examen_area_corp_x_cds where centro_servicio="+cds+") ";

al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select  'A' type, nvl(decode(a.observacion, null, ' ', 'Observ. Med. planta: '||a.observacion)  ,' ' ) observacion, nvl(a.cod_especialidad,' ') cod_especialidad, nvl(a.medico,' ') cod_medico, nvl(a.codigo,0) codigo ,nvl(c.primer_nombre||' '||c.segundo_nombre||' '||decode(c.apellido_de_casada,null,c.primer_apellido||' '||c.segundo_apellido,c.apellido_de_casada),' ') medico_nombre, nvl(to_char(a.hora,'HH12:MI:SS AM'),' ')as hora from tbl_sal_interconsultor a,tbl_adm_medico c,tbl_sal_detalle_orden_med b where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and  a.medico = c.codigo and a.pac_id =b.pac_id and a.secuencia = b.secuencia and a.orden = b.orden_med and a.orden_det = b.codigo and b.tipo_orden = 6 and b.ejecutado= 'S' and b.estado_orden not in ('O','S') union all select 'B' ,'CONSULTAS ESPECIALISTAS',' ', ' ' ,0,' ',' ' from dual  union  select 'C',nvl(b.observacion,' ')observacion ,nvl(a.cod_especialidad,' ') cod_especialidad, nvl(a.medico,' ') cod_medico, nvl(a.codigo,0) codigo ,nvl(c.primer_nombre||' '||c.segundo_nombre||' '||decode(c.apellido_de_casada,null,c.primer_apellido||' '||c.segundo_apellido,c.apellido_de_casada),' ') medico_nombre, nvl(to_char(a.hora,'HH12:MI:SS AM'),' ')as hora from tbl_sal_interconsultor_espec a,tbl_sal_diagnostico_inter_esp b,tbl_adm_medico c where a.pac_id = ");
sbSql.append(pacId);
sbSql.append("  and a.secuencia = ");
sbSql.append(noAdmision);
sbSql.append(" and  a.pac_id = b.pac_id(+) and  a.secuencia = b.secuencia(+) and  a.codigo = b.cod_interconsulta(+) and  a.medico = c.codigo order by 1");
al2 = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append(" select b.descripcion descTipo,( select join(cursor( select nombre||decode(nombre,null,'',decode(observacion,null,'','-'))||observacion as observacion from tbl_sal_detalle_orden_med det, tbl_sal_orden_medica ord where ord.codigo = det.orden_med and det.pac_id =");
sbSql.append(pacId);
sbSql.append(" and det.secuencia =  ");
sbSql.append(noAdmision);
sbSql.append(" and ord.secuencia = det.secuencia and ord.pac_id =  det.pac_id and det.tipo_orden =b.codigo and det.ejecutado = 'S' and det.estado_orden not in ('O','S')order by det.tipo_orden ),'; ') from dual )observacion from tbl_sal_tipo_orden_med b where  b.codigo not in(1,2,4,6,10,11,12) and b.visible_cu ='S'");
al3 = SQLMgr.getDataList(sbSql.toString());

	prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = 'NEEU'");
	if (prop == null)
	{
		prop = new Properties();
		prop.setProperty("historiaobs"," ");
		prop.setProperty("fum"," ");
		prop.setProperty("g"," ");
		prop.setProperty("p"," ");
		prop.setProperty("a"," ");
		prop.setProperty("c"," ");
	}

	if(prop.getProperty("historiaobs").equalsIgnoreCase("S")&&cdo.getColValue("sex").equalsIgnoreCase("F"))cdo.addColValue("embarazada","SI");
	else if(prop.getProperty("historiaobs").equalsIgnoreCase("N")&&cdo.getColValue("sex"," ").equalsIgnoreCase("F"))cdo.addColValue("embarazada","NO");


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	if(fp.equals("lista_envio") && !yearList.equals("0")) year = yearList;

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";
	if(!mesList.equals("")) month = mesList;

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	String subFolderName = "archivos";
	if(fp.equals("lista_envio")){
		directory = ResourceBundle.getBundle("path").getString("docs.files_axa")+"/";
		folderName=categoria_desc;
		if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	} else if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "FAX "+_comp.getFax();
	String title = "EXPEDIENTE";
	String subtitle = cdo.getColValue("categoria_adm").equals("2")?"CUARTO DE URGENCIAS":"";
	String xtraSubtitle = " ";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	if(fp.equals("lista_envio")) fileName=factura+"_EXP.pdf";
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+(fp.equals("lista_envio")?"":"")+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".17");
			dHeader.addElement(".07");
			dHeader.addElement(".04");
			dHeader.addElement(".07");
			dHeader.addElement(".20");
			dHeader.addElement(".20");
			dHeader.addElement(".12");
			dHeader.addElement(".13");

	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row

String NombredelPac=cdo.getColValue("nombre_paciente");


										pc.setFont(fontSize, 0);

										pc.addCols("Exp. No.  "+cdo.getColValue("pacId")+" - "+cdo.getColValue("admision"), 2,dHeader.size());
										//pc.addCols(" ",0,dHeader.size());
																				pc.setFont();

										pc.addBorderCols("Nombre: "+NombredelPac, 0,4);
										pc.setFont(fontSize, 0);

										pc.addBorderCols("Cédula/Pas.: "+cdo.getColValue("cedula"),0,1);
										pc.addBorderCols("ss: "+cdo.getColValue("seguroSocial"),0,1);
										pc.addBorderCols("Llegada: "+cdo.getColValue("llegada"),0,2);
									String anio="",mes="",dia="";
									if(cdo.getColValue("anio"," ").equals("0") || cdo.getColValue("anio"," ").equals("1")){anio=" Año ";} else{anio=" Años ";}
									if(cdo.getColValue("mes"," ").equals("1")){mes=" Mes ";} else{mes=" Meses ";}
									if(cdo.getColValue("dias"," ").equals("1")){dia=" Dia ";} else{dia=" Dias ";}
										pc.addBorderCols("Fecha Nacimiento: "+cdo.getColValue("f_nac"," ")+"  ("+cdo.getColValue("codigo_paciente"," ")+" )-("+cdo.getColValue("admision"," ")+" )"+"("+cdo.getColValue("pacId")+")", 0,4);
										pc.addBorderCols("Edad: "+cdo.getColValue("anio"," ")+anio+cdo.getColValue("mes"," ")+mes+cdo.getColValue("dias"," ")+dia, 0,2);
										pc.addBorderCols("Sexo: "+cdo.getColValue("sexo"," "), 0,2);

										pc.addBorderCols("Dirección del Paciente: "+cdo.getColValue("direccion"), 0,5);
										pc.addBorderCols("Teléfono Residencia: "+cdo.getColValue("tel_residencia"),0,3);

										pc.addBorderCols("Lugar de Trabajo del Paciente: "+cdo.getColValue("lugar_trabajo"), 0,5);
										pc.addBorderCols("Teléfono Oficina: "+cdo.getColValue("tel_trabajo"),0,3);

										pc.addCols(" ", 2,dHeader.size());
										pc.setTableHeader(7);

										pc.addBorderCols("Beneficios: "+cdo.getColValue("nom_empresa"), 0,5);
										pc.addBorderCols("No de Póliza: "+cdo.getColValue("poliza"),0,1);
										pc.addBorderCols("Certificado: "+cdo.getColValue("certificado"),0,2);

										pc.addBorderCols("Responsable de la Cuenta: "+cdo.getColValue("nombre_responsable"), 0,5);
										//pc.addBorderCols("Forma de Pago: ",0,1);
										pc.addBorderCols("Teléfono: "+cdo.getColValue("tel_responsable"),0,3);

										//pc.addBorderCols("Acompañante: ", 0,3);
										pc.addBorderCols("Médico de Cabecera "+cdo.getColValue("nombre_medico_cab"),0,dHeader.size());

										String _triageCat = cdo.getColValue("categoriaTriage");

										/*if(fg.equals("TSV_ESI")){

											if (cdo.getColValue("categoriaTriage")!=null){
												if(_triageCat.equals("CRITICO")) _triageCat = "PRIORIDAD 1";
											else if (_triageCat.equals("URGENTE")) _triageCat = "PRIORIDAD 2";
											else if (_triageCat.equals("NO URGENTE")) _triageCat = "PRIORIDAD 3";
											}
										}*/

										pc.addBorderCols("Triage Hora: "+cdo.getColValue("horaTriage"), 0,1);
										pc.addBorderCols("Clasificación "+_triageCat,0,3);
										pc.addBorderCols("Firma del que lo Efectuo: "+cdo.getColValue("usuario_creacion",""),0,2);
										pc.addBorderCols("Hora inicio Atención CU "+cdo.getColValue("hora_atencion"),0,2);

																				if (!exp.equals("")) {
																						if (cdo.getColValue("sex"," ").trim().equalsIgnoreCase("F")) {
																								pc.addBorderCols("F.U.M  "+cdo.getColValue("fum", prop.getProperty("fum")), 0,1);
																								pc.addBorderCols("Embarazada:  "+cdo.getColValue("embarazada"," "),0,2);
																								pc.addBorderCols("G:  "+cdo.getColValue("gestacion", prop.getProperty("g")),0,2);
																								pc.addBorderCols("P:  "+cdo.getColValue("parto", prop.getProperty("p")),0,1);
																								pc.addBorderCols("A:  "+cdo.getColValue("aborto", prop.getProperty("a")),0,1);
																								pc.addBorderCols("C: "+cdo.getColValue("cesarea", prop.getProperty("c")),0,1);
																						}
																				} else{
																						pc.addBorderCols("F.U.M  "+cdo.getColValue("fum"), 0,1);
																						pc.addBorderCols("Embarazada  "+cdo.getColValue("embarazada"),0,2);
																						pc.addBorderCols("G  "+cdo.getColValue("gestacion"),0,2);
																						pc.addBorderCols("P  "+cdo.getColValue("parto"),0,1);
																						pc.addBorderCols("A  "+cdo.getColValue("aborto"),0,1);
																						pc.addBorderCols("C  "+cdo.getColValue("cesarea"),0,1);
																				}
										pc.setFont();
										pc.setVAlignment(1);
										pc.addBorderCols("ALERGIAS:  ", 0,2);
										pc.resetVAlignment();
										pc.setFont(fontSize, 0);
										pc.addBorderCols(""+cdo.getColValue("alergias"), 0,dHeader.size()-2);
										pc.setFont();
										pc.setVAlignment(1);
										pc.addBorderCols("ENFERMEDADES ANTERIORES:   ", 0,2);
										pc.resetVAlignment();
										pc.setFont(fontSize,0);
										pc.addBorderCols(""+cdo.getColValue("eAnteriores"), 0,dHeader.size()-2);
										pc.setFont();
										pc.setVAlignment(1);
										pc.addBorderCols("HISTORIA ENFERMEDAD ACTUAL:   ",0,2);
										pc.resetVAlignment();
										pc.setFont(fontSize, 0);
										pc.addBorderCols(""+cdo.getColValue("dolencia"),0,dHeader.size()-2);

										pc.addBorderCols(" ",0,2);
										pc.addBorderCols(" "+cdo.getColValue("historia"),0,6);
										pc.setFont();
										pc.setVAlignment(1);
											pc.addBorderCols("MEDICAMENTOS ACTUALES:   ",0,2);
										pc.resetVAlignment();
										pc.setFont(fontSize, 0);
										pc.addBorderCols(""+cdo.getColValue("antMedicamento"),0,dHeader.size()-2);
									pc.setFont();
									pc.setVAlignment(1);
										pc.addBorderCols("EXAMEN FISICO:   ",0,1);


										pc.addBorderCols("SIGNOS VITALES TRIAGE: ",0,3);
										pc.resetVAlignment();
										pc.setFont(fontSize, 0);
										pc.addBorderCols(""+cdo.getColValue("signos"),0,4);

										for (int i=0; i<al.size(); i++)
										{

												CommonDataObject cdo3 = (CommonDataObject) al.get(i);
												String descripcionI=cdo3.getColValue("descripcion");
												descripcionI=descripcionI.substring(0,1);
												String descripcionX= cdo3.getColValue("descripcion");
												descripcionX=descripcionX.substring(1).toLowerCase();
												descripcionX=descripcionI+descripcionX;

													pc.addBorderCols(" "+descripcionX,0,2);
													pc.addBorderCols(" "+cdo3.getColValue("observacion"),0,6);

										}
										pc.addCols("  ",0,dHeader.size());
										pc.setFont();
										pc.setVAlignment(1);
										pc.addBorderCols("Examenes Laboratorio:",0,1);
										pc.resetVAlignment();
										pc.setFont(fontSize,0);
										pc.addBorderCols(" "+cdo.getColValue("lab"),0,7);
										pc.setFont();
										pc.setVAlignment(1);
										pc.addBorderCols("Examenes Imagenologia:",0,1);
										pc.resetVAlignment();
										pc.setFont(fontSize,0);
										pc.addBorderCols(" "+cdo.getColValue("img"),0,7);
										pc.setFont();
										pc.setVAlignment(1);
										pc.addBorderCols("EKG:",0,1);
										pc.resetVAlignment();
										pc.setFont(fontSize,0);
										pc.addBorderCols(" "+cdo.getColValue("ekg"),0,7);
										pc.setFont();
										pc.setVAlignment(1);
										pc.addBorderCols("TRATAMIENTO:",0,1);
										pc.resetVAlignment();
										pc.setFont(fontSize,0);
										pc.addBorderCols(" "+cdo.getColValue("tratamiento"),0,7);
										pc.setFont();
										pc.setVAlignment(1);
										pc.addBorderCols("MEDICAMENTOS:",0,1);
										pc.resetVAlignment();
										pc.setFont(fontSize,0);
										pc.addBorderCols(" "+cdo.getColValue("medicamento"),0,7);
										pc.setFont();
										pc.setVAlignment(1);
										pc.addBorderCols("PROCEDIMIENTOS:",0,1);
										pc.resetVAlignment();
										pc.setFont(fontSize,0);
										pc.addBorderCols(" "+cdo.getColValue("procedimiento"),0,7);

									String tipo="";
								for (int i=0; i<al3.size(); i++)
								{
									CommonDataObject cdo3 = (CommonDataObject) al3.get(i);
									pc.setFont();
										pc.setVAlignment(1);
									pc.addBorderCols(""+cdo3.getColValue("descTipo"),0,2);
									pc.resetVAlignment();
									pc.setFont(fontSize,0);
									pc.addBorderCols(" "+cdo3.getColValue("observacion"),0,6);
								}


								pc.addCols("  ",0,dHeader.size());

								pc.addBorderCols("REFERIDO A CONSULTA EXTERNA: "+cdo.getColValue("v_consulta_externa"), 0,5);
								pc.addBorderCols("Especialidad: "+cdo.getColValue("especialidad_nom"),0,3);
								//pc.addBorderCols("Dr:",0,1);
								//pc.addBorderCols("Hora de Consulta ",0,2);
								//pc.addBorderCols(" ",0,1);
								//pc.addBorderCols(" ",0,2);

														pc.setFont();
								pc.addBorderCols(" DATOS DE SALIDA ",0,dHeader.size());
								pc.setFont(fontSize,0);
								pc.addBorderCols("Especialista pedido x (Familiar o Pte.): "+cdo.getColValue("especialista_p"), 0,dHeader.size());

								String _transf = "", horaTransf = "";

								if (cdo.getColValue("transf"," ").trim()!=null ){
									if (cdo.getColValue("transf"," ").equals("N")){
										_transf = cdo.getColValue("transf");
										horaTransf = cdo.getColValue("hora_transf");
									}else {
										try{
											_transf = cdo.getColValue("transf").split("@@")[0];
										horaTransf = cdo.getColValue("transf").split("@@")[1];
										}catch(Exception e){}
									}
								}

								pc.addBorderCols("Hospitalización: "+cdo.getColValue("hospitalizar"), 0,1);
								pc.addBorderCols("Transferido a: "+_transf,0,5);
								pc.addBorderCols("Hora: "+horaTransf,0,2);

								if (request.getParameter("cod_diag_sal_tmp") != null && !"".equals(request.getParameter("cod_diag_sal_tmp")) ) {
									cdo.addColValue("cod_diag_sal", request.getParameter("cod_diag_sal_tmp"));
									cdo.addColValue("observacion", request.getParameter("nombre_diag_sal_tmp"));
								}

								pc.setFont();
								pc.setVAlignment(1);
								pc.addBorderCols("Dx de Salida: "+cdo.getColValue("cod_diag_sal"), 0,4);
								pc.resetVAlignment();
								pc.setFont(fontSize,0);
								pc.addBorderCols(" "+cdo.getColValue("observacion"),0,4);


								pc.addBorderCols("Hora Salida: "+cdo.getColValue("hora_salida"), 0,4);
								pc.addBorderCols("Condición: "+cdo.getColValue("condicion"),0,4);

								if(cdo.getColValue("hora_incap")!=null && !cdo.getColValue("hora_incap").trim().equals(""))
								 pc.addBorderCols("CONSTANCIA POR: "+cdo.getColValue("v_incapacidad"), 0,dHeader.size());
								else pc.addBorderCols("INCAPACIDAD POR: "+cdo.getColValue("v_incapacidad"), 0,dHeader.size());

								pc.addBorderCols("  ",0,dHeader.size());


								pc.addBorderCols("Instrucciones al paciente (medicamentos): "+cdo.getColValue("instruccion"), 0,dHeader.size());
								pc.addCols("  ",0,dHeader.size());

								pc.setFont();
								pc.addBorderCols("INTERCONSULTA (DR:)", 0,dHeader.size());
								pc.setFont(fontSize,0);
								pc.addBorderCols("MEDICO", 0,3);
								pc.addBorderCols("REG. NO", 0,1);
								pc.addBorderCols("HORA", 0,1);
								pc.addBorderCols("OBSERVACION", 0,3);
								String type = "";

								for (int i=0; i<al2.size(); i++)
								{

										CommonDataObject cdo3 = (CommonDataObject) al2.get(i);
										//if(cdo.getColValue("tipo") != null && !cdo.getColValue("tipo").trim().equals("") && cdo.getColValue("tipo").trim().equals("A") )

											if(cdo3.getColValue("type") != null && !cdo3.getColValue("type").trim().equals("") && cdo3.getColValue("type").trim().equals("B") )
											{
													pc.addCols(" ",0,dHeader.size());
													pc.setFont();
													pc.addBorderCols(" "+cdo3.getColValue("observacion"),0,dHeader.size());
													pc.setFont(fontSize,0);
											}
											else
											{
													pc.setVAlignment(1);
													pc.addBorderCols(" "+cdo3.getColValue("medico_nombre"),0,3);
													pc.addBorderCols(" "+cdo3.getColValue("cod_medico"),0,1);
													pc.addBorderCols(" "+cdo3.getColValue("hora"),0,1);
													pc.addBorderCols(" "+cdo3.getColValue("observacion"),0,3);
													pc.resetVAlignment();
											}

								}
								pc.addCols("  ",0,dHeader.size());
								pc.resetVAlignment();


								pc.addBorderCols("Se entrega por cambio de turno al DR.: "+cdo.getColValue("nombre_med_turno"), 0,dHeader.size());

String MedicoAtiende=cdo.getColValue("medico_atiende");
String RegistroMedido=cdo.getColValue("medico");


								pc.addBorderCols("Nombre del medico de urgencia que inicia el caso: ",0,4);
								pc.setFont();
								pc.addBorderCols(MedicoAtiende+ " - "+ RegistroMedido,0,4);
								pc.setFont(7,0);

								pc.addBorderCols("  ",0,dHeader.size());
								/*
								pc.addBorderCols("Consulta: "+cdo.getColValue("v_consulta_externa"), 0,3);
								pc.addBorderCols("Especialidad ",0,1);
								pc.addBorderCols("Dr:",0,1);
								pc.addBorderCols("Hora de Consulta ",0,2);
								*/


								pc.addBorderCols("Observaciones: "+cdo.getColValue("observacion_salida"), 0,dHeader.size());

								if (alVC.size() > 0 ){
									 Vector tblVC = new Vector();
									 tblVC.addElement("15");
									 tblVC.addElement("37");
									 tblVC.addElement("15");
									 tblVC.addElement("33");

									 pc.setNoColumnFixWidth(tblVC);
									 pc.createTable("tblvc",false,0,0.0f,(width-leftRightMargin));
									 pc.setFont(9,1);
									 pc.addCols("VALORES CRITICOS",0,tblVC.size());

									 String gCds = "";
									 for(int i = 0; i<alVC.size(); i++){

										CommonDataObject cdoVC = (CommonDataObject) alVC.get(i);

										if (!gCds.equals(cdoVC.getColValue("cds"))){
											 pc.setFont(8, 1);
											 pc.addCols(cdoVC.getColValue("cds"),0,dHeader.size());

											 pc.addBorderCols("Fecha",1 ,1);
											 pc.addBorderCols("Prueba",0 ,1);
											 pc.addBorderCols("Valor Crítico",1 ,1);
											 pc.addBorderCols("Observación",0 ,1);
										}

											 pc.setFont(8, 0);
											 pc.addCols(cdoVC.getColValue("fc"),1 ,1);
											 pc.addCols(cdoVC.getColValue("descripcion"),0 ,1);
											 pc.addCols(cdoVC.getColValue("valor"),1 ,1);
											 pc.addCols(cdoVC.getColValue("observacion"),0 ,1);

										gCds = cdoVC.getColValue("cds");

									}

									 pc.useTable("main");
									 pc.addTableToCols("tblvc",1,dHeader.size(),0,null,null,0.1f,0.1f,0.1f,0.1f);
								}

																pc.addCols(" ",1,dHeader.size());
						pc.setFont(9, 1);

						if (!exp.equals("")){
								if (cdo.getColValue("hospitalizar", " ").trim().equals("SI")){
										pc.addCols("HOSPITALIZACIÓN: "+cdo.getColValue("hospitalizar", " "), 0,dHeader.size());
								}
								String sbar = "";
								if (cdo.getColValue("hospitalizacion_sbar"," ").equalsIgnoreCase("S")) sbar = "SI";
								else if (cdo.getColValue("hospitalizacion_sbar"," ").equalsIgnoreCase("N")) sbar = "NO";
								if (sbar.equals("SI")){
										pc.addCols("SBAR: "+sbar,0,dHeader.size());
										pc.addCols("MOTIVOS SBAR: "+cdo.getColValue("motivos_sbar"," "),0,dHeader.size());
								}
								if (!cdo.getColValue("sbar_reporte"," ").trim().equals("")){
										pc.addCols("QUIEN REPORTA: "+cdo.getColValue("sbar_reporte"," "),0,dHeader.size());
								}
								if (!cdo.getColValue("sbar_recibe"," ").trim().equals("")){
										pc.addCols("QUIEN RECIBE: "+cdo.getColValue("sbar_recibe"," "),0,dHeader.size());
								}
						}

				pc.setFont(7,0);
		pc.addCols(" ",1,dHeader.size());
		pc.addCols(" ",1,dHeader.size());
		pc.addBorderCols(" Firma y sello ",1,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
		//pc.addCols(" Firma y sello",1,dHeader.size());

	pc.addTable();
	pc.close();
	if(!fp.equals("lista_envio")) response.sendRedirect(redirectFile);
}//GET
%>