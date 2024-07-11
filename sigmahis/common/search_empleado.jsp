<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==============================================================================================  b.grupo
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo;
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbField = new StringBuffer();
StringBuffer sbTable = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String index = request.getParameter("index");
String emp_id_env = request.getParameter("emp_id_env");
String userId = request.getParameter("userId");
String grupo = request.getParameter("grupo");
String seccion = request.getParameter("seccion");
String fecha_inicio = request.getParameter("fecha_inicio");
String fecha_final = request.getParameter("fecha_final");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String cargo = request.getParameter("cargo");
String tipo_aumento = request.getParameter("tipo_aumento");
String secuencia = request.getParameter("secuencia");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (fg == null) fg = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (cargo == null) cargo = "";
if (tipo_aumento == null) tipo_aumento = "";
if (secuencia == null) secuencia = "0";
if (index == null) index = "";

String funcion = request.getParameter("funcion");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (fp.equalsIgnoreCase("evaluacion_empleado"))
	{
		if (grupo == null || grupo.trim().equals(""))
		{
			sbSql = new StringBuffer();
			sbSql.append("select codigo, descripcion from tbl_pla_ct_grupo where compania=");
			sbSql.append(session.getAttribute("_companyId"));

			if (!fg.equalsIgnoreCase("x_grupo_trab"))
			{
				sbSql.append(" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario='");
				sbSql.append(( (String) session.getAttribute("_userName")));
				sbSql.append("')");
			}
			cdo = SQLMgr.getData(sbSql.toString());
			if (cdo != null) grupo = cdo.getColValue("codigo");
		}
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

	String numEmp = request.getParameter("numEmp");
	String cedula = request.getParameter("cedula");
	String nombre = request.getParameter("nombre");
	String apellido = request.getParameter("apellido");
	String area		= request.getParameter("area");
	if (numEmp == null) numEmp = "";
	if (cedula == null) cedula = "";
	if (nombre == null) nombre = "";
	if (apellido == null) apellido = "";
	if (area == null) area = "";
	if (grupo == null) grupo = "";
		if (seccion == null) seccion = "";

	if (!numEmp.trim().equals("")) { sbFilter.append(" and upper(a.num_empleado) like '%"); sbFilter.append(numEmp.toUpperCase()); sbFilter.append("%'"); }
	if (!cedula.trim().equals("")) { sbFilter.append(" and upper(nvl(a.pasaporte,a.cedula1)) like '%"); sbFilter.append(cedula.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if (!apellido.trim().equals("")) { sbFilter.append(" and upper(a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' DE '||a.apellido_casada))) like '%"); sbFilter.append(apellido.toUpperCase()); sbFilter.append("%'"); }
	if (!area.trim().equals("")) { sbFilter.append(" and b.ubicacion_fisica="); sbFilter.append(area); }
	if (!grupo.trim().equals("")) { sbFilter.append(" and b.grupo="); sbFilter.append(grupo); }
	if (!cargo.trim().equals("")) { sbFilter.append(" and a.cargo="); sbFilter.append(cargo); }
	if (!seccion.trim().equals("")) { sbFilter.append(" and a.ubic_seccion="); sbFilter.append(seccion); }

	sbField = new StringBuffer();
	sbField.append("a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) as nombres, a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' DE '||a.apellido_casada)) as apellidos, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||' '||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' DE '||a.apellido_casada)) as nombre");
	if (fp.equalsIgnoreCase("admision_empleado_ben") ||fp.equalsIgnoreCase("fact_prov"))
	{
		if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
		sbFilter.append(" and a.estado!=3");
	}
	else if (fp.equalsIgnoreCase("admision_empleado_resp"))
	{
		if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
	}
	else if (fp.equalsIgnoreCase("DMA"))
	{
		sbFilter.append(" and a.emp_id!=");
		sbFilter.append(emp_id_env);
	}
	else if (fp.equalsIgnoreCase("user") )
	{
		if (userId == null) throw new Exception("El Usuario no es válido. Por favor intente nuevamente!");
		sbTable.append(", (select ref_code from tbl_sec_users where user_type in (select id from tbl_sec_user_type where ref_type='E') ");

				sbTable.append(" and user_id != ");
				sbTable.append(userId);
		sbTable.append(" and user_status <> 'I' ) b");
		sbFilter.append(" and to_char(a.emp_id)=b.ref_code(+) and b.ref_code is null");
	}
		else if (fp.equalsIgnoreCase("valores_criticos")||fp.equalsIgnoreCase("handover")||fp.equalsIgnoreCase("ronda_uci")||fp.equalsIgnoreCase("rondas")||fp.equalsIgnoreCase("nosocomial_bundle")||fp.equalsIgnoreCase("protocolo_cesarea")||fp.equalsIgnoreCase("protocolo_operatorio")||fp.equalsIgnoreCase("recuperacion_anes_sop"))
	{
			sbFilter.append(" and (a.estado = 1");
			if (fp.equalsIgnoreCase("valores_criticos") && fg.equalsIgnoreCase("quien_reporta")) {
				sbFilter.append(" or cargo in (select column_value from table (select split((select nvl(get_sec_comp_param(");
				sbFilter.append((String) session.getAttribute("_companyId"));
				sbFilter.append(",'EXP_VALOR_CRITICO_QUIEN_REPORTA_CARGOS'),'-') from dual),',') from dual))");
			}
			sbFilter.append(")");
	}
	else if (fp.equalsIgnoreCase("cambio_turno"))
	{
		sbField = new StringBuffer();
		sbField.append("a.primer_nombre as nombres, decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as apellidos, a.primer_nombre||' '||decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as nombre");
		sbTable.append(", tbl_pla_ct_empleado b, tbl_pla_cargo c");
		sbFilter.append(" and a.estado not in(3,12,13) and a.emp_id=b.emp_id and a.compania=b.compania and a.cargo=c.codigo and a.compania=c.compania and (b.fecha_egreso_grupo is null or trunc(b.fecha_egreso_grupo) >= to_date(sysdate,'dd/mm/yyyy')) and c.denominacion not like 'GERENTE%' and c.denominacion not like 'DIRECTOR%' and c.denominacion not like 'SUB-DIRECTOR%' and c.denominacion not like 'SUB-JEFE%' and c.denominacion not like 'VICE-PRESID%' and c.denominacion not like 'JEFE DE%'");
	}
	else if (fp.equalsIgnoreCase("evaluacion_empleado"))
	{
		sbTable.append(", tbl_pla_ct_empleado b");
		sbFilter.append(" and a.emp_id=b.emp_id and a.compania=b.compania and b.estado!=3 and (b.fecha_egreso_grupo is null or trunc(b.fecha_egreso_grupo) > to_date(sysdate,'dd/mm/yyyy')) and a.estado not in (3,13)");
	}
	else if (fp.equalsIgnoreCase("generar_trx"))
	{
		sbField = new StringBuffer();
		sbField.append("distinct a.primer_nombre as nombres, decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as apellidos, a.primer_nombre||' '||decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as nombre");
		sbTable.append(", tbl_pla_ct_empleado b");
		sbFilter.append(" and a.emp_id=b.emp_id and a.compania=b.compania and trunc(b.fecha_ingreso_grupo)<=to_date('");
		sbFilter.append(fecha_final);
		sbFilter.append("','dd/mm/yyyy') and (b.fecha_egreso_grupo is null or trunc(b.fecha_egreso_grupo)>=to_date('");
		sbFilter.append(fecha_inicio);
		sbFilter.append("','dd/mm/yyyy'))");
	}
	else if (fp.equalsIgnoreCase("consulta_prog_x_emp"))
	{
		sbField = new StringBuffer();
		sbField.append("distinct a.primer_nombre as nombres, decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as apellidos, a.primer_nombre||' '||decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as nombre, (select descripcion from tbl_pla_ct_grupo where codigo=b.grupo and compania=b.compania) as grupo_trab, b.grupo");
		sbTable.append(", tbl_pla_ct_tprograma b");
		sbFilter.append(" and a.emp_id=b.emp_id and a.compania=b.compania and b.mes=");
		sbFilter.append(mes);
		sbFilter.append(" and b.anio=");
		sbFilter.append(anio);
		sbFilter.append(" and b.aprobado='S'");
	}
	else if (fp.equalsIgnoreCase("citas"))// || fp.equalsIgnoreCase("citasimagenologia")
	{
		if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
		if (funcion == null) throw new Exception("La Función del Personal no es válida. Por favor intente nuevamente!");
		sbFilter.append(" and a.estado!=3 /*and a.ubic_depto=250 */ and (a.ubic_seccion in (select area from tbl_cds_funcion where codigo=");
		sbFilter.append(funcion);
		sbFilter.append(") or a.ubic_fisica in (select area from tbl_cds_funcion where codigo=");
		sbFilter.append(funcion);
		sbFilter.append(") or a.seccion in (select area from tbl_cds_funcion where codigo=");
		sbFilter.append(funcion);
		sbFilter.append("))");
	}
	else if (fp.equalsIgnoreCase("pUniversalCIRC"))//CIRCULADOR
	{
		sbFilter.append(" and a.estado!=3  and (a.ubic_seccion in (select area from tbl_cds_funcion where codigo in (select column_value  from table( select split((select get_sec_comp_param(");
		sbFilter.append((String) session.getAttribute("_companyId"));
		sbFilter.append(",'COD_FUNC_CIRC') from dual),',') from dual  ))");
		sbFilter.append(") or a.ubic_fisica in (select area from tbl_cds_funcion where codigo in (select column_value  from table( select split((select get_sec_comp_param(");
		sbFilter.append((String) session.getAttribute("_companyId"));
		sbFilter.append(",'COD_FUNC_CIRC') from dual),',') from dual  ))");
		sbFilter.append(") or a.seccion in (select area from tbl_cds_funcion where codigo in (select column_value  from table( select split((select get_sec_comp_param(");
		sbFilter.append((String) session.getAttribute("_companyId"));
		sbFilter.append(",'COD_FUNC_CIRC') from dual),',') from dual  ))");
		sbFilter.append("))");
	}
	else if (fp.equalsIgnoreCase("pUniversalINT"))//INTRUMENTISTA
	{
		sbFilter.append(" and a.estado!=3  and (a.ubic_seccion in (select area from tbl_cds_funcion where codigo in (select column_value  from table( select split((select get_sec_comp_param(");
		sbFilter.append((String) session.getAttribute("_companyId"));
		sbFilter.append(",'COD_FUNC_INTRUMEN') from dual),',') from dual  ))");
		sbFilter.append(") or a.ubic_fisica in (select area from tbl_cds_funcion where codigo in (select column_value  from table( select split((select get_sec_comp_param(");
		sbFilter.append((String) session.getAttribute("_companyId"));
		sbFilter.append(",'COD_FUNC_INTRUMEN') from dual),',') from dual  ))");
		sbFilter.append(") or a.seccion in (select area from tbl_cds_funcion where codigo in (select column_value  from table( select split((select get_sec_comp_param(");
		sbFilter.append((String) session.getAttribute("_companyId"));
		sbFilter.append(",'COD_FUNC_INTRUMEN') from dual),',') from dual  ))");
		sbFilter.append("))");
	}
	else if (fp.equalsIgnoreCase("libretas")||fp.equalsIgnoreCase("aumento")||fp.equalsIgnoreCase("aumentoConsulta"))//
	{
		if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
		sbField = new StringBuffer();
		sbField.append("distinct a.primer_nombre as nombre, a.primer_nombre||' '||decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as nombres, (select denominacion from tbl_pla_cargo where codigo = a.cargo and compania = a.compania) denominacion ,to_char(/*a.fecha_ult_aumento*/ sysdate,'dd/mm/yyyy') fechaAumento, a.salario_base salarioBaseN ");
	}
	else if (fp.equalsIgnoreCase("cartaRepr")||fp.equalsIgnoreCase("cartaLicenciaRepre"))//
	{
		//if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
		sbField = new StringBuffer();
		sbField.append(" initcap(a.nombre_empleado) as nombres, a.primer_nombre as nombre, decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as apellidos, initcap(c.denominacion) denominacion ");
		sbTable.append(", tbl_pla_cargo c");
		sbFilter.append(" and a.cargo = c.codigo and a.compania = c.compania  and c.firmar_carta_trabajo = 'S' and a.estado not in (3,13) ");
	}
	/*else if (fp.equalsIgnoreCase("cartaCert"))//
	{
		//if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
		sbField = new StringBuffer();
		sbField.append(" a.nombre_empleado as nombres, decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as apellidos, c.denominacion, ce.grupo ");
		sbTable.append(", tbl_pla_cargo c, tbl_pla_ct_empleado ce");
		sbFilter.append(" and a.cargo = c.codigo and a.compania = c.compania  and a.emp_id = ce.emp_id and a.compania = ce.compania ");
	}*/
	else if (fp.equalsIgnoreCase("cartaCert"))//
	{/*--para que no muestre los empleados cesante--*/
		//if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
		sbField = new StringBuffer();
		sbField.append(" a.nombre_empleado as nombres, decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as apellidos, c.denominacion /*, ce.grupo*/ ");
		sbTable.append(", tbl_pla_cargo c, /*tbl_pla_ct_empleado ce*/ tbl_sec_unidad_ejec u");
		sbFilter.append(" and a.cargo = c.codigo and a.compania = c.compania and u.codigo = a.unidad_organi and u.compania =a.compania and a.estado <> 3 /*and a.emp_id = ce.emp_id and a.compania = ce.compania*/ /*and ce.estado=1*/ ");
	}
		else if (fp.equalsIgnoreCase("empleado")||fp.equalsIgnoreCase("descuento"))//
	{
		//if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");
		sbField = new StringBuffer();
		sbField.append(" a.nombre_empleado as nombres, decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as apellidos, c.denominacion, ce.grupo ");
		sbTable.append(", tbl_pla_cargo c, tbl_pla_ct_empleado ce");
		sbFilter.append(" and a.cargo = c.codigo and a.compania = c.compania  and a.emp_id = ce.emp_id and a.compania = ce.compania and ce.estado=1 ");
	}
	else if (fp.equalsIgnoreCase("autorizaTrx"))
	{
		sbTable.append(", tbl_sec_unidad_ejec u ");
		sbFilter.append(" and a.ubic_seccion = u.codigo and a.compania = u.compania ");
	}
	else if (fp.equalsIgnoreCase("vac_aprob"))
	{
		sbField = new StringBuffer();
		sbField.append(" a.nombre_empleado as nombres, a.primer_nombre as nombre, decode(a.sexo,'F',decode(a.apellido_casada,null,a.primer_apellido,decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada,a.primer_apellido)),a.primer_apellido) as apellidos ");

	}
	else if (fp.equalsIgnoreCase("cons_sobretiempo"))
	{
	sbTable.append(", tbl_pla_ct_empleado b");
			sbFilter.append(" and a.emp_id=b.emp_id and a.compania=b.compania ");
			sbFilter.append(" and b.estado='1'");
	}
	else if (fp.equalsIgnoreCase("escort"))// ANFITRION ESCOLTA
	{
		sbField.append(" ,a.estado_civil, a.foto /************** FILTERING FOR ESCORT **************/");
		sbTable.append(", tbl_pla_cargo c");
		sbFilter.append(" and a.cargo = c.codigo and a.compania = c.compania and a.estado not in (3,13) ");
	}
	else if (fp.equalsIgnoreCase("paciente"))
	{
	sbField.append(" ,a.estado_civil,'' religion, a.comunidad_dir comunidad, a.corregimiento_dir corregimiento , a.distrito_dir distrito, a.provincia_dir, a.pais_dir pais, a.zona_postal, a.apartado_postal, a.telefono_otro as celular,a.email as e_mail , '' fax ,(select nacionalidad from tbl_sec_pais b  where  b.codigo = a.nacionalidad  )nacionalidadDesc,(select nvl(d.nombre_comunidad, ' ') from vw_sec_regional_location d where d.codigo_comunidad=a.comunidad_dir and d.codigo_corregimiento=a.corregimiento_dir and d.codigo_distrito=a.distrito_dir and d.codigo_provincia=a.provincia_dir and d.codigo_pais=a.pais_dir and nivel =4) as comunidadNombre,(select nvl(d.nombre_corregimiento, ' ') from vw_sec_regional_location d where d.codigo_corregimiento=a.corregimiento_dir and d.codigo_distrito=a.distrito_dir and d.codigo_provincia=a.provincia_dir and d.codigo_pais=a.pais_dir and nivel =3) as corregimientoNombre, (select nvl(d.nombre_distrito, ' ')  from vw_sec_regional_location d where d.codigo_distrito=a.distrito_dir and d.codigo_provincia=a.provincia_dir and d.codigo_pais=a.pais_dir and nivel =2) as distritoNombre, (select nvl(d.nombre_provincia, ' ') from vw_sec_regional_location d where d.codigo_provincia=a.provincia_dir and d.codigo_pais=a.pais_dir and nivel =1)  as provincianombre,a.nacionalidad,a.telefono_casa as telefono,(select nvl(d.nombre_pais, ' ') from vw_sec_regional_location d where d.codigo_pais=a.pais_dir and nivel =0 ) as paisnombre,a.tipo_sangre  ");
	}

	sbSql = new StringBuffer();
	sbSql.append("select ");
	sbSql.append(sbField);
	sbSql.append(", nvl(a.pasaporte,a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.sexo, a.emp_id, a.primer_nombre, nvl(a.segundo_nombre,' ') as segundo_nombre, a.primer_apellido, nvl(a.segundo_apellido,' ') as segundo_apellido, nvl(a.apellido_casada,' ') as apellido_casada, nvl(a.num_empleado,' ') as numEmpleado, nvl(a.num_ssocial,' ') as numSsocial, nvl(to_char(a.fecha_nacimiento,'dd/mm/yyyy'),' ') as fechaNacimiento, decode(a.calle_dir,null,'',a.calle_dir||decode(a.casa__dir,null,'',' '||a.casa__dir)) as direccion, a.compania, a.cargo, a.unidad_organi as unidadOrgani, (select descripcion from tbl_sec_unidad_ejec where codigo=a.unidad_organi and compania=a.compania) as depto, nvl(to_char(a.fecha_ingreso,'dd/mm/yyyy'),' ') as fechaIngreso, nvl(to_char(a.fecha_puestoact,'dd/mm/yyyy'),' ') as fechaPuestoact,nvl(mod(trunc(months_between(sysdate, a.fecha_ingreso)), 12), 0)  meses,nvl(trunc(months_between(sysdate, a.fecha_ingreso) / 12), 0) anios, a.salario_base as salarioBase,(select sangre_id from tbl_bds_tipo_sangre where tipo_sangre=a.tipo_sangre) as codTipoSangre from vw_pla_empleado a");
	sbSql.append(sbTable);

	if (!fp.equalsIgnoreCase("libretas")&&!fp.equalsIgnoreCase("admision_empleado_ben")&&!fp.equalsIgnoreCase("becario") &&!fp.equalsIgnoreCase("inscripcion")&&!fp.equalsIgnoreCase("inscripcionCs"))
	{
		sbSql.append(" where a.compania=");
		sbSql.append(session.getAttribute("_companyId"));
	} else if (fp.equalsIgnoreCase("admision_empleado_ben")||fp.equalsIgnoreCase("becario"))
	{
		sbSql.append(" where a.compania in (1,2) and estado <> 3 ");
	}
	else if (fp.equalsIgnoreCase("inscripcion")&&fp.equalsIgnoreCase("inscripcionCs"))
	{
		sbSql.append(" where a.compania=");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.estado not in(3,12) ");
	}
	else if (fp.equalsIgnoreCase("cons_sobretiempo"))
		{
			sbSql.append("  where a.compania=");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and a.compania = b.compania ");
			sbSql.append(" and a.emp_id = b.emp_id");
			sbSql.append(" and b.estado = 1");
	}
	else
	{
		sbSql.append(" where ( ( a.compania= ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.compania in (1,2)) or ( ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append("  = 6 and a.compania in (1,2)) )");
		sbSql.append(" and a.estado <> 3");
	}

	sbSql.append(sbFilter);
	sbSql.append(" order by 2, 1");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

	sbSql = new StringBuffer();
	sbSql.append("select count(*) from vw_pla_empleado a");
	sbSql.append(sbTable);
	if (fp.equalsIgnoreCase("libretas"))
	{
	sbSql.append(" where ( ( a.compania= ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.compania in (1,2)) or ( ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append("  = 6 and a.compania in (1,2)) )");
		sbSql.append(" and a.estado <> 3");
	}
	else if (fp.equalsIgnoreCase("cons_sobretiempo"))
			{
				sbSql.append(" where a.compania=");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(" and a.compania = b.compania ");
				sbSql.append(" and a.emp_id = b.emp_id");
				sbSql.append(" and b.estado = 1 and rownum = 1");
	}
	else
	{
		sbSql.append(" where a.compania=");
		sbSql.append(session.getAttribute("_companyId"));


	}
	sbSql.append(sbFilter);
	rowCount = CmnMgr.getCount(sbSql.toString());

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
<script language="javascript">
document.title = 'Empleados - '+document.title;

function setEmpleado(k)
{
<% if (fp.equalsIgnoreCase("admision_empleado_ben")) { %>
	window.opener.document.form4.poliza<%=index%>.value = eval('document.empleado.numEmpleado'+k).value;
	window.opener.document.form4.certificado<%=index%>.value = eval('document.empleado.cedula'+k).value;
<% } else if (fp.equalsIgnoreCase("admision_empleado_resp")) { %>
	//window.opener.document.form5.tipoIdentificacion<%=index%>.value = 'C';
	window.opener.document.form5.lugarNac<%=index%>.value = '';

	window.opener.document.form5.sexo<%=index%>.value = '';
	window.opener.document.form5.empresa<%=index%>.value = '';
	window.opener.document.form5.medico<%=index%>.value = '';
	window.opener.document.form5.parentesco<%=index%>.value = '';
	window.opener.document.form5.lugarNac<%=index%>.value = '';
	window.opener.document.form5.nacionalidad<%=index%>.value = '';
	window.opener.document.form5.nacionalidadDesc<%=index%>.value = '';
	window.opener.document.form5.tipoIdentificacion<%=index%>.value = 'C';

	window.opener.document.form5.nombre<%=index%>.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form5.identificacion<%=index%>.value = eval('document.empleado.cedula'+k).value;
	window.opener.document.form5.sexo<%=index%>.value = eval('document.empleado.sexo'+k).value;
	window.opener.document.form5.seguroSocial<%=index%>.value = eval('document.empleado.numSsocial'+k).value;
	window.opener.document.form5.numEmpleado<%=index%>.value = eval('document.empleado.numEmpleado'+k).value;
<% } else if (fp.equalsIgnoreCase("evaluacion_empleado")) { %>
	window.opener.document.form0.nombre.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form0.provincia.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.form0.sigla.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.form0.tomo.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.form0.asiento.value = eval('document.empleado.asiento'+k).value;
	window.opener.document.form0.emp_id.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.numEmpleado.value = eval('document.empleado.numEmpleado'+k).value;
	window.opener.document.form0.cargo.value = eval('document.empleado.cargo'+k).value;
	window.opener.document.form0.unidadAdm.value = eval('document.empleado.unidadOrgani'+k).value;
	window.opener.document.form0.depto.value = eval('document.empleado.depto'+k).value;
	window.opener.document.form0.fechaIngreso.value = eval('document.empleado.fechaIngreso'+k).value;
	window.opener.document.form0.fechaPuestoact.value = eval('document.empleado.fechaPuestoact'+k).value;
<% } else if (fp.equalsIgnoreCase("evaluador")) { %>
	window.opener.document.form0.evaluadorDesc.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form0.provinciaEval.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.form0.siglaEval.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.form0.tomoEval.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.form0.asientoEval.value = eval('document.empleado.asiento'+k).value;
<% } else if (fp.equalsIgnoreCase("DM")) { %>
	window.opener.document.devolucion.empNombre.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.devolucion.empProvincia.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.devolucion.empSigla.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.devolucion.empTomo.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.devolucion.empAsiento.value = eval('document.empleado.asiento'+k).value;
	window.opener.document.devolucion.emp_id.value = eval('document.empleado.emp_id'+k).value;
<% } else if (fp.equalsIgnoreCase("DMA")) { %>
	window.opener.document.devolucion.nombre_rec.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.devolucion.provincia_rec.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.devolucion.sigla_rec.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.devolucion.tomo_rec.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.devolucion.asiento_rec.value = eval('document.empleado.asiento'+k).value;
	window.opener.document.devolucion.emp_id_rec.value = eval('document.empleado.emp_id'+k).value;
<% } else if (fp.equalsIgnoreCase("user")) { %>
	window.opener.document.form0.name.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form0.refCode.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.refCodeDisplay.value = eval('document.empleado.numEmpleado'+k).value;
<% } else if (fp.equalsIgnoreCase("listado")) { %>
	window.opener.document.formUnidad.idDesc.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.formUnidad.id.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.formUnidad.num.value = eval('document.empleado.numEmpleado'+k).value;
<%}else if (fp.equalsIgnoreCase("listadoAcreedores")){%>
		window.opener.document.form0.idDesc.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form0.id.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.num.value = eval('document.empleado.numEmpleado'+k).value;
<%}else if (fp.equalsIgnoreCase("prima_antiguedad")){%>
		window.opener.document.form0.idDesc.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form0.id.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.num.value = eval('document.empleado.numEmpleado'+k).value;
<%}else if (fp.equalsIgnoreCase("distVacaciones")){%>
	window.opener.document.form0.idDesc.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form0.id.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.num_empleado.value = eval('document.empleado.numEmpleado'+k).value;
<%}else if (fp.equalsIgnoreCase("listadoIncap2")){%>
		window.opener.document.form0.idDesc2.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form0.id2.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.num2.value = eval('document.empleado.numEmpleado'+k).value;
<%}else if (fp.equalsIgnoreCase("listadoIncap3")){%>
		window.opener.document.form0.idDesc3.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form0.id3.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.num3.value = eval('document.empleado.numEmpleado'+k).value;
<% } else if (fp.equalsIgnoreCase("reg_vacaciones")) { %>
	var accion = '';
	if(confirm('De clic en OK/Aceptar para registrar Vacaciones y Cancel/Cancelar para Reintegro de Vacaciones!')){
		accion = 'RV';
	} else {
		var x = getDBData('<%=request.getContextPath()%>','1','tbl_pla_det_vacacion','emp_id = '+ eval('document.empleado.emp_id'+k).value +' and fecha_final >= sysdate and cod_compania = <%=(String) session.getAttribute("_companyId")%>','');
		if(x=='') alert('El periodo de vacaciones ya ha terminado!');
		accion = 'RI';
	}
	window.opener.location 				= '../rhplanilla/reg_vacaciones.jsp?empId='+eval('document.empleado.emp_id'+k).value+'&accion='+accion;
<% } else if (fp.equalsIgnoreCase("becario")) { %>
	window.opener.document.form0.nombre.value = eval('document.empleado.nombres'+k).value;
	window.opener.document.form0.apellido.value = eval('document.empleado.apellidos'+k).value;
	window.opener.document.form0.fecha.value = eval('document.empleado.fechaNacimiento'+k).value;
	window.opener.document.form0.sexo.value = eval('document.empleado.sexo'+k).value;
	window.opener.document.form0.provincia.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.form0.sigla.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.form0.tomo.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.form0.asiento.value = eval('document.empleado.asiento'+k).value;
	window.opener.document.form0.direccion.value = eval('document.empleado.direccion'+k).value;
	window.opener.document.form0.numSsocial.value = eval('document.empleado.numSsocial'+k).value;
	window.opener.document.form0.provinciaAso.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.form0.siglaAso.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.form0.tomoAso.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.form0.asientoAso.value = eval('document.empleado.asiento'+k).value;
	window.opener.document.form0.nombreAso.value = eval('document.empleado.nombres'+k).value;
	window.opener.document.form0.apellidoAso.value = eval('document.empleado.apellidos'+k).value;
	//window.opener.document.form0.observacion.value = eval('document.empleado.parentesco'+k).value;
	window.opener.document.form0.empId.value = eval('document.empleado.emp_id'+k).value;
<% } else if (fp.equalsIgnoreCase("liquidacion")) { %>
	window.opener.location 				= '../rhplanilla/reg_liquidacion.jsp?emp_id='+eval('document.empleado.emp_id'+k).value;
<% } else if (fp.equalsIgnoreCase("cambio_turno")) { %>
	window.opener.document.form1.nombre.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form1.provincia.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.form1.sigla.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.form1.tomo.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.form1.asiento.value = eval('document.empleado.asiento'+k).value;
	window.opener.document.form1.emp_id.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form1.num_empleado.value = eval('document.empleado.numEmpleado'+k).value;
<% } else if (fp.equalsIgnoreCase("generar_trx")) { %>
	window.opener.document.form1.nombre_empleado.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form1.provincia.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.form1.sigla.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.form1.tomo.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.form1.asiento.value = eval('document.empleado.asiento'+k).value;
	window.opener.document.form1.emp_id.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form1.num_empleado.value = eval('document.empleado.numEmpleado'+k).value;
<% } else if (fp.equalsIgnoreCase("consulta_prog_x_emp")) { %>
	window.opener.document.form1.nombre.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form1.provincia.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.form1.sigla.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.form1.tomo.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.form1.asiento.value = eval('document.empleado.asiento'+k).value;
	window.opener.document.form1.emp_id.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form1.num_empleado.value = eval('document.empleado.numEmpleado'+k).value;
<% } else if (fp.equalsIgnoreCase("citas") || fp.equalsIgnoreCase("citasimagenologia")) { %>
	window.opener.document.form2.medico<%=index%>.value='';
	window.opener.document.form2.empCompania<%=index%>.value=eval('document.empleado.compania'+k).value;
	window.opener.document.form2.empProvincia<%=index%>.value=eval('document.empleado.provincia'+k).value;
	window.opener.document.form2.empSigla<%=index%>.value=eval('document.empleado.sigla'+k).value;
	window.opener.document.form2.empTomo<%=index%>.value=eval('document.empleado.tomo'+k).value;
	window.opener.document.form2.empAsiento<%=index%>.value=eval('document.empleado.asiento'+k).value;
	window.opener.document.form2.empId<%=index%>.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.form2.tipoPersonal<%=index%>.value='E';
	window.opener.document.form2.nombre<%=index%>.value=eval('document.empleado.nombre'+k).value;
	if(window.opener.document.form2.sociedad<%=index%>)window.opener.document.	form2.sociedad<%=index%>.value = "N";
<% } else if (fp.equalsIgnoreCase("pUniversalINT")) { %>
	window.opener.document.form0.instrumentista.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.nombre_instrumentista.value=eval('document.empleado.nombre'+k).value;
<% } else if (fp.equalsIgnoreCase("pUniversalCIRC")) { %>
	window.opener.document.form0.circulador.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.nombre_circulador.value=eval('document.empleado.nombre'+k).value;

<% } else if (fp.equalsIgnoreCase("libretas")) { %>
	window.opener.document.form1.compania_planilla<%=index%>.value=eval('document.empleado.compania'+k).value;
	window.opener.document.form1.provincia<%=index%>.value=eval('document.empleado.provincia'+k).value;
	window.opener.document.form1.sigla<%=index%>.value=eval('document.empleado.sigla'+k).value;
	window.opener.document.form1.tomo<%=index%>.value=eval('document.empleado.tomo'+k).value;
	window.opener.document.form1.asiento<%=index%>.value=eval('document.empleado.asiento'+k).value;
	window.opener.document.form1.emp_id<%=index%>.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.form1.nombre<%=index%>.value=eval('document.empleado.nombres'+k).value;
	window.opener.document.form1.num_empleado<%=index%>.value = eval('document.empleado.numEmpleado'+k).value;
<% } else if (fp.equalsIgnoreCase("aumento")) { %>
	var emp_id = eval('document.empleado.emp_id'+k).value
	var fecha = '<%=fecha_inicio%>';
	var aumento = getDBData('<%=request.getContextPath()%>','count(*)','tbl_pla_aumento_cc','compania=<%=session.getAttribute("_companyId")%> and emp_id='+emp_id+' and trunc(fecha_aumento)= to_date(\''+fecha+'\',\'dd/mm/yyyy\') and tipo_aumento =<%=tipo_aumento%> and secuencia <> <%=secuencia%>');
	if(aumento > 0)
	{
		alert('Este empleado tiene '+aumento+' aumento del mismo tipo e igual fecha del que intenta registrar');
	}
	window.opener.document.form1.compania<%=index%>.value=<%=session.getAttribute("_companyId")%>;
	window.opener.document.form1.provincia<%=index%>.value=eval('document.empleado.provincia'+k).value;
	window.opener.document.form1.sigla<%=index%>.value=eval('document.empleado.sigla'+k).value;
	window.opener.document.form1.tomo<%=index%>.value=eval('document.empleado.tomo'+k).value;
	window.opener.document.form1.asiento<%=index%>.value=eval('document.empleado.asiento'+k).value;
	window.opener.document.form1.emp_id<%=index%>.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.form1.nombre<%=index%>.value=eval('document.empleado.nombres'+k).value;
	window.opener.document.form1.num_empleado<%=index%>.value = eval('document.empleado.numEmpleado'+k).value;
	window.opener.document.form1.denominacion<%=index%>.value = eval('document.empleado.denominacion'+k).value;
	window.opener.document.form1.fecha_ingreso<%=index%>.value = eval('document.empleado.fechaIngreso'+k).value;
	window.opener.document.form1.sueldo_anterior<%=index%>.value = eval('document.empleado.salarioBase'+k).value;
	window.opener.document.form1.fecha_anterior<%=index%>.value = eval('document.empleado.fechaAumento'+k).value;
	window.opener.document.form1.cedula<%=index%>.value = eval('document.empleado.cedula'+k).value;

<% } else if (fp.equalsIgnoreCase("aumentoConsulta")) { %>
	window.opener.location='../rhplanilla/list_aumentos_otros.jsp?mode=view&fp=CA&fg=CA&empId='+eval('document.empleado.emp_id'+k).value+'&nombre='+eval('document.empleado.nombres'+k).value;
<% } else if (fp.equalsIgnoreCase("cartaCert")||fp.equalsIgnoreCase("cartaLicencia") ) { %>
	window.opener.document.form0.empIdCert.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.nombreEmpCert.value=eval('document.empleado.nombres'+k).value;
	window.opener.document.form0.deptoEmpCert.value = eval('document.empleado.depto'+k).value;
	window.opener.document.form0.cargoEmpCert.value = eval('document.empleado.denominacion'+k).value;
	window.opener.document.form0.noEmpleado.value = eval('document.empleado.numEmpleado'+k).value;
<% } else if (fp.equalsIgnoreCase("cartaRepr") ||fp.equalsIgnoreCase("cartaLicenciaRepre")) { %>
	window.opener.document.form0.empIdRepr.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.nombreEmpRepr.value=eval('document.empleado.nombres'+k).value;
	window.opener.document.form0.deptoEmpRepr.value = eval('document.empleado.depto'+k).value;
	window.opener.document.form0.cargoEmpRepr.value = eval('document.empleado.denominacion'+k).value;
	window.opener.document.form0.cedula.value = eval('document.empleado.cedula'+k).value;
<% } else if (fp.equalsIgnoreCase("descuento") ) { %>
	window.opener.document.form1.empId.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.form1.cedula.value=eval('document.empleado.cedula'+k).value;
	window.opener.document.form1.nombre_empleado.value=eval('document.empleado.nombres'+k).value;
	window.opener.document.form1.unidadName.value = eval('document.empleado.depto'+k).value;
	window.opener.document.form1.provincia.value=eval('document.empleado.provincia'+k).value;
	window.opener.document.form1.sigla.value=eval('document.empleado.sigla'+k).value;
	window.opener.document.form1.tomo.value=eval('document.empleado.tomo'+k).value;
	window.opener.document.form1.asiento.value=eval('document.empleado.asiento'+k).value;
	window.opener.document.form1.num_empleado.value = eval('document.empleado.numEmpleado'+k).value;
	window.opener.document.form1.salario.value = eval('document.empleado.salarioBase'+k).value;
<% }else if(fp.equalsIgnoreCase("fact_prov")){ %>
	window.opener.document.fact_prov.emp_id<%=index%>.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.fact_prov.nombre_empleado<%=index%>.value=eval('document.empleado.nombres'+k).value;
<% } else if (fp.equalsIgnoreCase("cobrador")) { %>
	window.opener.document.form0.provincia.value=eval('document.empleado.provincia'+k).value;
	window.opener.document.form0.sigla.value=eval('document.empleado.sigla'+k).value;
	window.opener.document.form0.tomo.value=eval('document.empleado.tomo'+k).value;
	window.opener.document.form0.asiento.value=eval('document.empleado.asiento'+k).value;
	window.opener.document.form0.emp_id.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.codigo_cobrador.value=eval('document.empleado.cedula'+k).value;
	window.opener.document.form0.nombre_cobrador.value=eval('document.empleado.nombre'+k).value;
<%}else if (fp.equalsIgnoreCase("inscripcion")) { %>
	window.opener.document.form1.nombreEmpleado.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form1.provincia.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.form1.sigla.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.form1.tomo.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.form1.asiento.value = eval('document.empleado.asiento'+k).value;
	window.opener.document.form1.empId.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form1.cedula.value = eval('document.empleado.cedula'+k).value;
<% }else if (fp.equalsIgnoreCase("inscripcionCs")) { %>
window.opener.document.search00.nombreEmpleado.value=eval('document.empleado.nombre'+k).value;
window.opener.document.search00.cedula.value= eval('document.empleado.cedula'+k).value;
<% }else if (fp.equalsIgnoreCase("autorizaTrx")) { %>
window.opener.document.form0.nombreEmpleado.value=eval('document.empleado.nombre'+k).value;
window.opener.document.form0.empId.value= eval('document.empleado.emp_id'+k).value;
window.opener.document.form0.noEmpleado.value= eval('document.empleado.numEmpleado'+k).value;
<% }else if (fp.equalsIgnoreCase("listadoSalario")){%>
		window.opener.document.form0.idDesc.value = eval('document.empleado.nombre'+k).value;
	window.opener.document.form0.id.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.num.value = eval('document.empleado.numEmpleado'+k).value;
	window.opener.document.form0.cedula.value = eval('document.empleado.cedula'+k).value;
	window.opener.document.form0.num_empleado.value = eval('document.empleado.numEmpleado'+k).value;
	window.opener.document.form0.salario.value = eval('document.empleado.salarioBase'+k).value;
	window.opener.document.form0.unidad.value = eval('document.empleado.unidadOrgani'+k).value;
	window.opener.document.form0.unidadDesc.value = eval('document.empleado.depto'+k).value;
<% } else if (fp.equalsIgnoreCase("empleado") ) { %>
	<% } else if (fp.equalsIgnoreCase("empleado") ) { %>
	window.opener.document.empleado.nombre.value = eval('document.empleado.nombres'+k).value;
	window.opener.document.empleado.provincia.value = eval('document.empleado.provincia'+k).value;
	window.opener.document.empleado.sigla.value = eval('document.empleado.sigla'+k).value;
	window.opener.document.empleado.tomo.value = eval('document.empleado.tomo'+k).value;
	window.opener.document.empleado.asiento.value = eval('document.empleado.asiento'+k).value;
	window.opener.document.empleado.empId.value = eval('document.empleado.emp_id'+k).value;
	window.opener.document.empleado.num_empleado.value = eval('document.empleado.numEmpleado'+k).value;
	window.opener.document.empleado.salario_mes.value = eval('document.empleado.salarioBase'+k).value;

	window.opener.document.empleado.unidad_organi.value = eval('document.empleado.unidadOrgani'+k).value;
	window.opener.document.empleado.unidad_organi_desc.value = eval('document.empleado.depto'+k).value;
	window.opener.document.empleado.cargo.value = eval('document.empleado.cargo'+k).value;
	window.opener.document.empleado.descCargo.value = eval('document.empleado.denominacion'+k).value;
	window.opener.document.empleado.fechaIngreso.value = eval('document.empleado.fechaIngreso'+k).value;
	window.opener.document.empleado.anio.value = eval('document.empleado.anios'+k).value;
	window.opener.document.empleado.meses.value = eval('document.empleado.meses'+k).value;
	if(window.opener.document.form0.salario)window.opener.document.form0.salario.value = eval('document.empleado.salarioBase'+k).value;

	window.opener.document.empleado.num_ssocial.value = eval('document.empleado.numSsocial'+k).value;
	window.opener.document.empleado.gasto_rep.value = eval('document.empleado.gasto_rep'+k).value;
	window.opener.document.empleado.rata_hora.value = eval('document.empleado.rata_hora'+k).value;
	window.opener.document.empleado.tipo_renta.value = eval('document.empleado.tipo_renta'+k).value;
	window.opener.document.empleado.num_dependiente.value = eval('document.empleado.num_dependiente'+k).value;

<% }else if (fp.equalsIgnoreCase("anexo03")) { %>
	window.opener.document.form0.nombreEmpleado.value=eval('document.empleado.nombres'+k).value;
	window.opener.document.form0.empId.value= eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.noEmpleado.value= eval('document.empleado.numEmpleado'+k).value;


<% }else if (fp.equalsIgnoreCase("vac_aprob")) { %>
	window.opener.document.search01.nombre.value=eval('document.empleado.nombres'+k).value;
	window.opener.document.search01.empId.value= eval('document.empleado.emp_id'+k).value;
	window.opener.document.search01.submit();

<% }else if (fp.equalsIgnoreCase("cons_sobretiempo")) { %>
	window.opener.document.search01.nombreEmpleado.value=eval('document.empleado.nombre'+k).value;
	window.opener.document.search01.empId.value= eval('document.empleado.emp_id'+k).value;window.opener.document.search01.numEmpleado.value= eval('document.empleado.numEmpleado'+k).value;
	window.opener.document.search01.submit();

<% } else if ( fp.equalsIgnoreCase("escort") ){ %>
	window.opener.document.form0.provincia.value=eval('document.empleado.provincia'+k).value;
	window.opener.document.form0.sigla.value=eval('document.empleado.sigla'+k).value;
	window.opener.document.form0.tomo.value=eval('document.empleado.tomo'+k).value;
	window.opener.document.form0.asiento.value=eval('document.empleado.asiento'+k).value;
	window.opener.document.form0.empId.value=eval('document.empleado.emp_id'+k).value;
	window.opener.document.form0.primerNombre.value=eval('document.empleado.primer_nombre'+k).value;
	window.opener.document.form0.primerApellido.value = eval('document.empleado.primer_apellido'+k).value;
	window.opener.document.form0.segundoNombre.value=eval('document.empleado.segundo_nombre'+k).value;
	window.opener.document.form0.segundoApellido.value = eval('document.empleado.segundo_apellido'+k).value;
	window.opener.document.form0.fechaDeNacimiento.value = eval('document.empleado.fechaNacimiento'+k).value;
	window.opener.document.form0.sexo.value = eval('document.empleado.sexo'+k).value;
	window.opener.document.form0.maritalStatus.value = eval('document.empleado.estadoCivil'+k).value;
	window.opener.document.form0.fotoTmp.value = eval('document.empleado.foto'+k).value;
	preventEdit();

<% } else if ( fp.equalsIgnoreCase("valores_criticos") ){%>
	 <%if (fg.trim().equalsIgnoreCase("quien_recibe")) {%>
			 if(window.opener.document.form2.recibe_transcribe_confirma<%=index%>)
					 window.opener.document.form2.recibe_transcribe_confirma<%=index%>.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form2.recibe_transcribe_confirma_nombre<%=index%>)
					 window.opener.document.form2.recibe_transcribe_confirma_nombre<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%} else {%>
			 if(window.opener.document.form2.quien_reporta<%=index%>)
					 window.opener.document.form2.quien_reporta<%=index%>.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form2.quien_reporta_nombre<%=index%>)
					 window.opener.document.form2.quien_reporta_nombre<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%}%>
<%}else if ( fp.equalsIgnoreCase("protocolo_cesarea") || fp.equalsIgnoreCase("protocolo_operatorio") ){%>
	 <%if (fg.trim().equalsIgnoreCase("INS")) {%>
			 if(window.opener.document.form0.instrumentador<%=index%>)
					 window.opener.document.form0.instrumentador<%=index%>.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.instrumentador_nombre<%=index%>)
					 window.opener.document.form0.instrumentador_nombre<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%} else {%>
			 if(window.opener.document.form0.circulador<%=index%>)
					 window.opener.document.form0.circulador<%=index%>.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.circulador_nombre<%=index%>)
					 window.opener.document.form0.circulador_nombre<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%}%>
<%} else if (fp.equalsIgnoreCase("recuperacion_anes_sop")) { %>
		<%if (fg.trim().equalsIgnoreCase("ENF")) {%>
			 if(window.opener.document.form0.enfermera_anes<%=index%>)
					 window.opener.document.form0.enfermera_anes<%=index%>.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.enfermera_nombre_anes<%=index%>)
					 window.opener.document.form0.enfermera_nombre_anes<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%} else if (fg.trim().equalsIgnoreCase("ASIS")) {%>
			 if(window.opener.document.form0.asistente<%=index%>)
					 window.opener.document.form0.asistente<%=index%>.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.asistente_nombre<%=index%>)
					 window.opener.document.form0.asistente_nombre<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%}else if (fg.trim().equalsIgnoreCase("ENFREC")) {%>
			 if(window.opener.document.form0.recup_enfer<%=index%>)
					 window.opener.document.form0.recup_enfer<%=index%>.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.recup_enfer_nombre<%=index%>)
					 window.opener.document.form0.recup_enfer_nombre<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%}else if (fg.trim().equalsIgnoreCase("ENFREL")) {%>
			 if(window.opener.document.form0.relev_enfer<%=index%>)
					 window.opener.document.form0.relev_enfer<%=index%>.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.relev_enfer_nombre<%=index%>)
					 window.opener.document.form0.relev_enfer_nombre<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%}%>
<% } else if ( fp.equalsIgnoreCase("handover") ){%>
	 <%if (fg.trim().equalsIgnoreCase("quien_recibe_handover")) {%>
			 if(window.opener.document.form0.persona_que_recibe<%=index%>)
					 window.opener.document.form0.persona_que_recibe.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.persona_que_recibe_nombre)
					 window.opener.document.form0.persona_que_recibe_nombre.value = eval('document.empleado.nombre'+k).value;
		 <%} else {%>
		 <%}%>
<%}else if ( fp.equalsIgnoreCase("ronda_uci") ){%>
	 <%if (fg.trim().equalsIgnoreCase("enfermera")) {%>
			 if(window.opener.document.form0.enfermera)
					 window.opener.document.form0.enfermera.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.enfermera_nombre)
						window.opener.document.form0.enfermera_nombre.value = eval('document.empleado.nombre'+k).value;
		 <%} else if(fg.trim().equalsIgnoreCase("terapista")) {%>
				if(window.opener.document.form0.terapista)
					 window.opener.document.form0.terapista.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.terapista_nombre)
						window.opener.document.form0.terapista_nombre.value = eval('document.empleado.nombre'+k).value;
		 <%}else if (fg.trim().equalsIgnoreCase("farmacia")) {%>
				if(window.opener.document.form0.farmacia)
					 window.opener.document.form0.farmacia.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.farmacia_nombre)
						window.opener.document.form0.farmacia_nombre.value = eval('document.empleado.nombre'+k).value;
		 <%}else if (fg.trim().equalsIgnoreCase("nutricion")) {%>
				if(window.opener.document.form0.nutricion)
					 window.opener.document.form0.nutricion.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.nutricion_nombre)
						window.opener.document.form0.nutricion_nombre.value = eval('document.empleado.nombre'+k).value;
		 <%}else if (fg.trim().equalsIgnoreCase("supervisor")) {%>
				if(window.opener.document.form0.supervisor)
					 window.opener.document.form0.supervisor.value = eval('document.empleado.emp_id'+k).value;
				if(window.opener.document.form0.supervisor_nombre)
						window.opener.document.form0.supervisor_nombre.value = eval('document.empleado.nombre'+k).value;
		 <%}%>
<%}else if ( fp.equalsIgnoreCase("rondas") ){%>
	 <%if (fg.trim().equalsIgnoreCase("enfermera")) {%>
			 if(window.opener.document.form0.enfermera<%=index%>)
					 window.opener.document.form0.enfermera<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%} else if(fg.trim().equalsIgnoreCase("nutricion")) {%>
				if(window.opener.document.form0.nutricion<%=index%>)
					 window.opener.document.form0.nutricion<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%}else if (fg.trim().equalsIgnoreCase("farmacia")) {%>
				if(window.opener.document.form0.farmacia<%=index%>)
					 window.opener.document.form0.farmacia<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%}else if (fg.trim().equalsIgnoreCase("terapista_fisica")) {%>
				if(window.opener.document.form0.terapia_fisica<%=index%>)
					 window.opener.document.form0.terapia_fisica<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%}else if (fg.trim().equalsIgnoreCase("terapista_respiratorio")) {%>
				if(window.opener.document.form0.terapia_respiratorio<%=index%>)
					 window.opener.document.form0.terapia_respiratorio<%=index%>.value = eval('document.empleado.nombre'+k).value;
		 <%}%>
<%}else if (fp.equalsIgnoreCase("paciente")){%>

		if(window.opener.document.form0.nacionalCode)window.opener.document.form0.nacionalCode.value = eval('document.empleado.nacionalidad'+k).value;
	if(window.opener.document.form0.nacional)window.opener.document.form0.nacional.value = eval('document.empleado.nacionalidadDesc'+k).value;
	if(window.opener.document.form0.sexo)window.opener.document.form0.sexo.value = eval('document.empleado.sexo'+k).value;
	if(window.opener.document.form0.telefono)window.opener.document.form0.telefono.value = eval('document.empleado.telefono'+k).value;
	if(window.opener.document.form0.primerNom)window.opener.document.form0.primerNom.value = eval('document.empleado.primer_nombre'+k).value;
	if(window.opener.document.form0.segundoNom)window.opener.document.form0.segundoNom.value = eval('document.empleado.segundo_nombre'+k).value;
	if(window.opener.document.form0.primerApell)window.opener.document.form0.primerApell.value = eval('document.empleado.primer_apellido'+k).value;
	if(window.opener.document.form0.segundoApell)window.opener.document.form0.segundoApell.value = eval('document.empleado.segundo_apellido'+k).value;
	if(window.opener.document.form0.casadaApell)window.opener.document.form0.casadaApell.value = eval('document.empleado.apellido_casada'+k).value;
	if(window.opener.document.form0.fechaCorrec)window.opener.document.form0.fechaCorrec.value = eval('document.empleado.fechaNacimiento'+k).value;
	if(window.opener.document.form0.fechaNaci)window.opener.document.form0.fechaNaci.value = eval('document.empleado.fechaNacimiento'+k).value;
	if(window.opener.document.form0.religionCode)window.opener.document.form0.religionCode.value = eval('document.empleado.religion'+k).value;
	if(window.opener.document.form0.direccion)window.opener.document.form0.direccion.value = eval('document.empleado.direccion'+k).value;
	if(window.opener.document.form0.comunidadCode)window.opener.document.form0.comunidadCode.value = eval('document.empleado.comunidad'+k).value;
	if(window.opener.document.form0.corregiCode)window.opener.document.form0.corregiCode.value = eval('document.empleado.corregimiento'+k).value;
	if(window.opener.document.form0.distritoCode)window.opener.document.form0.distritoCode.value = eval('document.empleado.distrito'+k).value;
	if(window.opener.document.form0.provCode)window.opener.document.form0.provCode.value = eval('document.empleado.provincia_dir'+k).value;
	if(window.opener.document.form0.paisCode)window.opener.document.form0.paisCode.value = eval('document.empleado.pais'+k).value;
	if(window.opener.document.form0.comunidad)window.opener.document.form0.comunidad.value = eval('document.empleado.comunidadNombre'+k).value;
	if(window.opener.document.form0.corregi)window.opener.document.form0.corregi.value = eval('document.empleado.corregimientoNombre'+k).value;
	if(window.opener.document.form0.distrito)window.opener.document.form0.distrito.value = eval('document.empleado.distritoNombre'+k).value;
	if(window.opener.document.form0.prov)window.opener.document.form0.prov.value = eval('document.empleado.provincianombre'+k).value;
	if(window.opener.document.form0.pais)window.opener.document.form0.pais.value = eval('document.empleado.paisnombre'+k).value;
	if(window.opener.document.form0.zonaPostal)window.opener.document.form0.zonaPostal.value = eval('document.empleado.zona_postal'+k).value;
	if(window.opener.document.form0.aptdoPostal)window.opener.document.form0.aptdoPostal.value = eval('document.empleado.apartado_postal'+k).value;
	//if(window.opener.document.form0.telefono_movil)window.opener.document.form0.telefono_movil.value = eval('document.empleado.celular'+k).value;
	//if(window.opener.document.form2.telTrabajo)window.opener.document.form2.telTrabajo.value = eval('document.empleado.telefono_trabajo'+k).value;
	//if(window.opener.document.form2.lugarTrab)window.opener.document.form2.lugarTrab.value = eval('document.empleado.lugar_de_trabajo'+k).value;
	if(window.opener.document.form0.e_mail)window.opener.document.form0.e_mail.value = eval('document.empleado.e_mail'+k).value;
	if(window.opener.document.form0.fax)window.opener.document.form0.fax.value = eval('document.empleado.fax'+k).value;
	if(window.opener.document.form0.ref_id)window.opener.document.form0.ref_id.value = eval('document.empleado.emp_id'+k).value;
	if(window.opener.document.form0.estadoCivil)window.opener.document.form0.estadoCivil.value = eval('document.empleado.estadoCivil'+k).value;
	if(window.opener.document.form0.tipoSangre)window.opener.document.form0.tipoSangre.value = eval('document.empleado.codTipoSangre'+k).value;

	window.opener.document.form0.tipoId.value='C';
	window.opener.document.form0.provincia.value=eval('document.empleado.provincia'+k).value;
	window.opener.document.form0.sigla.value=eval('document.empleado.sigla'+k).value;
	window.opener.document.form0.tomo.value=eval('document.empleado.tomo'+k).value;
	window.opener.document.form0.asiento.value=eval('document.empleado.asiento'+k).value;;
	window.opener.CalculateAge();


<%} else if(fp.equalsIgnoreCase("nosocomial_bundle")){%>
		if(window.opener.document.form0.insertador<%=index%>)
			 window.opener.document.form0.insertador<%=index%>.value = eval('document.empleado.emp_id'+k).value;
		if(window.opener.document.form0.insertador_desc<%=index%>)
			 window.opener.document.form0.insertador_desc<%=index%>.value = eval('document.empleado.nombre'+k).value;
<%}%>

	window.close();
}


/**;
* Bloqueada los textbox en ecolta_config
* Ya que si es empleado interno, no hay motivo
* modificarle la cédula por ejemplo
**/
function preventEdit(){
	 var formEl = "form0";
	 var totFormEl = window.opener.document.forms["form0"].elements.length;
	 var omitedElements = {"telCentro":1,"extTelCentro":1,"email":1,"celular":1,"jefe_inmediato":1};
	 for (var e = 0; e<=totFormEl; e++ ){
			if ( window.opener.document.forms[formEl].elements[e]){
			if (window.opener.document.forms[formEl].elements[e].type == "text" && !(window.opener.document.forms[formEl].elements[e].name in omitedElements)  ){
				 window.opener.document.forms[formEl].elements[e].className = "FormDataObjectDisabled";
				 window.opener.document.forms[formEl].elements[e].readOnly = true;
			}else
			if(window.opener.document.forms[formEl].elements[e].type == "reset"){
				//Para los botones del componente de fecha. (resetNombreDelCampo: type reset)
				window.opener.document.forms[formEl].elements[e].disabled = true;
			}
			else{
				//console.log("thebrain: won't disable other elements");
			}
		}
	}

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="SELECCION DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("emp_id_env",emp_id_env)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("fecha_inicio",fecha_inicio)%>
<%=fb.hidden("fecha_final",fecha_final)%>
<%=fb.hidden("funcion",funcion)%>
<%=fb.hidden("tipo_aumento",tipo_aumento)%>
<%=fb.hidden("secuencia",secuencia)%>

		<tr class="TextFilter">
			<td width="<%=(fp.equalsIgnoreCase("cambio_turno") || fp.equalsIgnoreCase("evaluacion_empleado")?"8":"15")%>%">
				No. Empleado<br>
				<%=fb.textBox("numEmp","",false,false,false,10,"Text10",null,null)%>
			</td>
			<td width="<%=(fp.equalsIgnoreCase("cambio_turno") || fp.equalsIgnoreCase("evaluacion_empleado")?"10":"15")%>%">
				C&eacute;dula/Pass<br>
				<%=fb.textBox("cedula","",false,false,false,20,"Text10",null,null)%>
			</td>
			<td width="<%=(fp.equalsIgnoreCase("cambio_turno") || fp.equalsIgnoreCase("evaluacion_empleado")?"20":"35")%>%">
				Nombre<br>
				<%=fb.textBox("nombre","",false,false,false,40,"Text10",null,null)%>
			</td>
			<td width="<%=(fp.equalsIgnoreCase("cambio_turno") || fp.equalsIgnoreCase("evaluacion_empleado")?"20":"35")%>%">
				Apellido<br>
				<%=fb.textBox("apellido","",false,false,false,40,"Text10",null,null)%>
				<%if (!fp.equalsIgnoreCase("cambio_turno") && !fp.equalsIgnoreCase("evaluacion_empleado")) {%>
					<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
				<%}%>
			</td>
<%if (fp.equalsIgnoreCase("cambio_turno")) {%>
			<td colspan="42%">
				Area<br>
				<%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_pla_ct_area_x_grupo where compania="+(String) session.getAttribute("_companyId")+" and grupo="+grupo+" and estado=1","area",area,false,false,0,"Text10","","","","T")%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
<%} else if (fp.equalsIgnoreCase("evaluacion_empleado")) {%>
			<td colspan="42%">
				Grupo<br>
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_pla_ct_grupo where compania="+(String) session.getAttribute("_companyId")+(!fg.equalsIgnoreCase("x_grupo_trab")?" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario='"+((String) session.getAttribute("_userName"))+"')":"")+" ","grupo",grupo,false,false,0,"Text10","","","","")%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
			<%}%>
		</tr>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("emp_id_env",emp_id_env)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("numEmp",numEmp)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("fecha_inicio",fecha_inicio)%>
<%=fb.hidden("fecha_final",fecha_final)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("funcion",funcion)%>
<%=fb.hidden("tipo_aumento",tipo_aumento)%>
<%=fb.hidden("secuencia",secuencia)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("emp_id_env",emp_id_env)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("numEmp",numEmp)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("fecha_inicio",fecha_inicio)%>
<%=fb.hidden("fecha_final",fecha_final)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("funcion",funcion)%>
<%=fb.hidden("tipo_aumento",tipo_aumento)%>
<%=fb.hidden("secuencia",secuencia)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="expe">
		<tr class="TextHeader" align="center">
			<%if(!fp.trim().equals("libretas") && !fp.trim().equals("aumento")  && !fp.trim().equals("aumentoConsulta") && !fp.trim().equals("cartaRepr") && !fp.trim().equals("cartaCert") &&  !fp.trim().equals("descuento")){%>
						<td width="15%">No. Empleado</td>
						<td width="25%">C&eacute;dula</td>
						<td width="30%">Nombre</td>
						<td width="30%">Apellido</td>
			<%}else {%>
						<td width="15%">No. Empleado</td>
						<td width="25%">C&eacute;dula</td>
						<td width="30%">Nombre</td>
						<td width="30%">Denominación</td>
			<%}%>
		</tr>
<%fb = new FormBean("empleado",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("numEmpleado"+i,cdo.getColValue("numEmpleado"))%>
		<%=fb.hidden("numSsocial"+i,cdo.getColValue("numSsocial"))%>
		<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
		<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
		<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
		<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
		<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("cargo"+i,cdo.getColValue("cargo"))%>
		<%=fb.hidden("grupo"+i,cdo.getColValue("grupo"))%>
		<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
		<%=fb.hidden("unidadOrgani"+i,cdo.getColValue("unidadOrgani"))%>
		<%=fb.hidden("depto"+i,cdo.getColValue("depto"))%>
		<%=fb.hidden("fechaIngreso"+i,cdo.getColValue("fechaIngreso"))%>
		<%=fb.hidden("fechaPuestoact"+i,cdo.getColValue("fechaPuestoact"))%>
		<%=fb.hidden("primer_nombre"+i,cdo.getColValue("primer_nombre"))%>
		<%=fb.hidden("segundo_nombre"+i,cdo.getColValue("segundo_nombre"))%>
		<%=fb.hidden("primer_apellido"+i,cdo.getColValue("primer_apellido"))%>
		<%=fb.hidden("segundo_apellido"+i,cdo.getColValue("segundo_apellido"))%>
		<%=fb.hidden("nombres"+i,cdo.getColValue("nombres"))%>
		<%=fb.hidden("apellidos"+i,cdo.getColValue("apellidos"))%>
		<%=fb.hidden("fechaNacimiento"+i,cdo.getColValue("fechaNacimiento"))%>
		<%=fb.hidden("direccion"+i,cdo.getColValue("direccion"))%>
		<%=fb.hidden("denominacion"+i,cdo.getColValue("denominacion"))%>
		<%=fb.hidden("salarioBase"+i,cdo.getColValue("salarioBase"))%>
		<%=fb.hidden("fechaAumento"+i,cdo.getColValue("fechaAumento"))%>
		<%=fb.hidden("anios"+i,cdo.getColValue("anios"))%>
		<%=fb.hidden("meses"+i,cdo.getColValue("meses"))%>
		<%=fb.hidden("estadoCivil"+i,cdo.getColValue("estado_civil"))%>
		<%=fb.hidden("foto"+i,cdo.getColValue("foto"))%>

		<%if(fp.equalsIgnoreCase("paciente")){%>

		<%=fb.hidden("nacionalidadDesc"+i,cdo.getColValue("nacionalidadDesc"))%>
		<%=fb.hidden("nacionalidad"+i,cdo.getColValue("nacionalidad"))%>
		<%=fb.hidden("telefono"+i,cdo.getColValue("telefono"))%>
		<%=fb.hidden("apellido_casada"+i,cdo.getColValue("apellido_casada"))%>
		<%=fb.hidden("religion"+i,cdo.getColValue("religion"))%>
		<%=fb.hidden("comunidad"+i,cdo.getColValue("comunidad"))%>
		<%=fb.hidden("corregimiento"+i,cdo.getColValue("corregimiento"))%>
		<%=fb.hidden("distrito"+i,cdo.getColValue("distrito"))%>

		<%=fb.hidden("provincia_dir"+i,cdo.getColValue("provincia_dir"))%>
		<%=fb.hidden("pais"+i,cdo.getColValue("pais"))%>
		<%=fb.hidden("zona_postal"+i,cdo.getColValue("zona_postal"))%>
		<%=fb.hidden("apartado_postal"+i,cdo.getColValue("apartado_postal"))%>
		<%=fb.hidden("celular"+i,cdo.getColValue("celular"))%>
		<%//=fb.hidden("telefono_trabajo"+i,cdo.getColValue("telefono_trabajo"))%>
		<%//=fb.hidden("lugar_de_trabajo"+i,cdo.getColValue("lugar_de_trabajo"))%>
		<%=fb.hidden("e_mail"+i,cdo.getColValue("e_mail"))%>
		<%=fb.hidden("fax"+i,cdo.getColValue("fax"))%>
		<%=fb.hidden("comunidadNombre"+i,cdo.getColValue("comunidadNombre"))%>
		<%=fb.hidden("corregimientoNombre"+i,cdo.getColValue("corregimientoNombre"))%>
		<%=fb.hidden("distritoNombre"+i,cdo.getColValue("distritoNombre"))%>
		<%=fb.hidden("provincianombre"+i,cdo.getColValue("provincianombre"))%>
		<%=fb.hidden("paisnombre"+i,cdo.getColValue("paisnombre"))%>
		<%=fb.hidden("tipo_sangre"+i,cdo.getColValue("tipo_sangre"))%>
		<%=fb.hidden("codTipoSangre"+i,cdo.getColValue("codTipoSangre"))%>

<%}%>


		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEmpleado(<%=i%>)" style="cursor:pointer">
			<td><%=cdo.getColValue("numEmpleado")%></td>
			<td><%=cdo.getColValue("cedula")%></td>
			<td><%=cdo.getColValue("nombres")%></td>
			<%if(!fp.trim().equals("libretas") && !fp.trim().equals("aumento") && !fp.trim().equals("aumentoConsulta") && !fp.trim().equals("cartaRepr") && !fp.trim().equals("cartaCert") && !fp.trim().equals("descuento")){%>
				<td><%=cdo.getColValue("apellidos")%></td>
			<%} else {%>
				<td><%=cdo.getColValue("denominacion")%></td>
			<%}%>
		</tr>
<%
}
%>
<%=fb.formEnd()%>
		</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%> <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("emp_id_env",emp_id_env)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("numEmp",numEmp)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("fecha_inicio",fecha_inicio)%>
<%=fb.hidden("fecha_final",fecha_final)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("funcion",funcion)%>
<%=fb.hidden("tipo_aumento",tipo_aumento)%>
<%=fb.hidden("secuencia",secuencia)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("emp_id_env",emp_id_env)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("numEmp",numEmp)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("fecha_inicio",fecha_inicio)%>
<%=fb.hidden("fecha_final",fecha_final)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("funcion",funcion)%>
<%=fb.hidden("tipo_aumento",tipo_aumento)%>
<%=fb.hidden("secuencia",secuencia)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
