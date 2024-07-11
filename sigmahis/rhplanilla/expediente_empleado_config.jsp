<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr"       scope="session" class="issi.admin.ConnectionMgr" /><jsp:useBean id="SecMgr"       scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet"      scope="session" class="issi.admin.UserDetail" /><jsp:useBean id="CmnMgr"       scope="page"    class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr"       scope="page"    class="issi.admin.SQLMgr" /><jsp:useBean id="fb"           scope="page"    class="issi.admin.FormBean" />
<jsp:useBean id="hteducacion"  scope="session" class="java.util.Hashtable" /><jsp:useBean id="htcursof"     scope="session" class="java.util.Hashtable" />
<jsp:useBean id="hthabilidad"  scope="session" class="java.util.Hashtable"/><jsp:useBean id="htentrevista" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htidioma"     scope="session" class="java.util.Hashtable"/><jsp:useBean id="htenfermedad" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htmedida"     scope="session" class="java.util.Hashtable"/><jsp:useBean id="htreconocit"  scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htpariente"   scope="session" class="java.util.Hashtable" /><jsp:useBean id="vcteducacion" scope="session" class="java.util.Vector" />
<jsp:useBean id="vctcursof"    scope="session" class="java.util.Vector"/><jsp:useBean id="vcthabilidad" scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctentrete"   scope="session" class="java.util.Vector"/><jsp:useBean id="vctidioma"    scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctenfermed"  scope="session" class="java.util.Vector"/><jsp:useBean id="vctmedidas"   scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctreconoc"   scope="session" class="java.util.Vector"/><jsp:useBean id="vctpariente"  scope="session" class="java.util.Vector"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

boolean isFpEnabled = CmnMgr.isValidFpType("EMP");

CommonDataObject emple = new CommonDataObject();
ArrayList al = new ArrayList();
String sql="";
String mode = request.getParameter("mode");
String tab  = request.getParameter("tab");
String id   = request.getParameter("id");
String anio = request.getParameter("anio");
String cons = request.getParameter("cons");
String emp_id = request.getParameter("emp_id");
String key = "";
String change = request.getParameter("change");
String fp =request.getParameter("fp");
String fg =request.getParameter("fg");
String path = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
String compania = (String) session.getAttribute("_companyId");
boolean viewMode = false;
if(fp == null || fp == "") fp ="rrhh";
if(fg == null ) fg ="";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
int educaLastLineNo = 0;
int cursoLastLineNo = 0;
int habilidadLastLineNo = 0;
int entrenimientoLastLineNo = 0;
int idiomaLastLineNo = 0;
int enfermedadLastLineNo= 0;
int medidadLastLineNo = 0;
int reconocimientoLastLineNo = 0;
int parienteLastLineNo =0;
if(tab == null)  tab = "0";
if(mode == null) mode ="add";

if(request.getParameter("educaLastLineNo") != null) educaLastLineNo = Integer.parseInt(request.getParameter("educaLastLineNo"));
if(request.getParameter("cursoLastLineNo") != null) cursoLastLineNo = Integer.parseInt(request.getParameter("cursoLastLineNo"));
if(request.getParameter("habilidadLastLineNo") != null) habilidadLastLineNo = Integer.parseInt(request.getParameter("habilidadLastLineNo"));
if(request.getParameter("entrenimientoLastLineNo") != null) entrenimientoLastLineNo = Integer.parseInt(request.getParameter("entrenimientoLastLineNo"));
if(request.getParameter("idiomaLastLineNo")!= null) idiomaLastLineNo = Integer.parseInt(request.getParameter("idiomaLastLineNo"));
if(request.getParameter("enfermedadLastLineNo") != null) enfermedadLastLineNo = Integer.parseInt(request.getParameter("enfermedadLastLineNo"));
if(request.getParameter("medidadLastLineNo") != null) medidadLastLineNo = Integer.parseInt(request.getParameter("medidadLastLineNo"));
if(request.getParameter("reconocimientoLastLineNo") != null) reconocimientoLastLineNo = Integer.parseInt(request.getParameter("reconocimientoLastLineNo"));
if(request.getParameter("parienteLastLineNo") != null) parienteLastLineNo = Integer.parseInt(request.getParameter("parienteLastLineNo"));
if (request.getMethod().equalsIgnoreCase("GET")){
	if (mode.equalsIgnoreCase("add")){
		if(fp!=null && fp.equalsIgnoreCase("ingreso")){
			sql="Select DISTINCT a.sexo,a.provincia|| '-' ||a.sigla|| '-' ||a.tomo|| '-' ||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.primer_nombre as nombre1, nvl(a.segundo_nombre,' ')  as nombre2, a.primer_apellido as apellido1, nvl(a.segundo_apellido,' ') as apellido2, nvl(a.apellido_casada, ' ') as casada,  nvl(a.seguro_social, ' ') as seguro, a.dependientes as dependiente, a.licencia_conducir as conducir, a.estado_civil as civil, a.sexo, a.nacionalidad as nacionalidadCode, decode(a.corregimiento_dir, null, ' ',a.corregimiento_dir) as corregimientoC, decode(a.provincia_dir, null, ' ', a.provincia_dir) as provinciaC,decode(a.comunidad_dir, null, ' ',a.comunidad_dir ) as comunidadC,  decode(a.distrito_dir,  null,'',a.distrito_dir) as distritoC,  decode(a.pais_dir, null, ' ', a.pais_dir ) as paisC,a.urgencia_telefono as telefonos,to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha,nvl(a.telefono, ' ') as telcasa,nvl(a.telefono_celular, ' ') as telotros, a.vive_madre as vivemadre, a.vive_padre as vivepadre, nvl(a.nombre_madre, ' ') as madre, nvl(a.nombre_padre, ' ') as padre,nvl(a.urgencia_llamar_a, ' ') as llamar,nvl(a.apartado, ' ') as apartado,nvl(a.email,' ') AS email,nvl(a.zona, ' ') as zona,nvl(a.tipo_licencia, ' ') as licencia, nvl(a.numero_licencia, '') as nlicencia,nvl(d.nombre_comunidad, ' ') as comunidadN, nvl(d.nombre_corregimiento, ' ') as corregimientoN, nvl(d.nombre_distrito, ' ') as distritoN, nvl(d.nombre_provincia, ' ') as provinciaN, nvl(d.nombre_pais, ' ') as paisN, nvl(b.nacionalidad, 'NA') as nacionalidad,'' as pasaporte FROM TBL_PLA_SOLICITANTE a , tbl_sec_pais b, (select codigo_pais, nombre_pais,  decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null, nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito,decode(codigo_corregimiento,0,null, codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) d where  a.nacionalidad = b.codigo(+) and a.pais_dir = d.codigo_pais(+) and a.provincia_dir = d.codigo_provincia(+) and a.distrito_dir = d.codigo_distrito(+) and a.corregimiento_dir = d.codigo_corregimiento(+) and a.comunidad_dir = d.codigo_comunidad(+) and a.compania="+compania+" and a.anio="+anio+" and a.consecutivo="+cons;
			emple = SQLMgr.getData(sql);
		}	else {
			id="0";
			emple.addColValue("sigla","00");
			emple.addColValue("provincia","");
			emple.addColValue("tomo","");
			emple.addColValue("asiento","");
			emple.addColValue("pasaporte","");
			emple.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		}
		emp_id = "0";
		emple.addColValue("EMP_ID","0");
		emple.addColValue("ingreso",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		emple.addColValue("contrato","");
		emple.addColValue("egreso","");
		emple.addColValue("puestoA","");
		emple.addColValue("aumento","");
		emple.addColValue("incapacidad","");
		emple.addColValue("numEmpleado","");
		emple.addColValue("pasaporte","");
		hteducacion.clear();
		htcursof.clear();
		hthabilidad.clear();
		htentrevista.clear();
		htidioma.clear();
		htenfermedad.clear();
		htmedida.clear();
		htreconocit.clear();
		htpariente.clear();
		vcteducacion.clear();
		vctcursof.clear();
		vcthabilidad.clear();
		vctentrete.clear();
		vctidioma.clear();
		vctenfermed.clear();
		vctmedidas.clear();
		vctreconoc.clear();
		vctpariente.clear();
	} else {
		
		if (emp_id == null) throw new Exception("El Número de empleado no es válido. Por favor intente nuevamente!");
		
		sql="Select DISTINCT a.EMP_ID,a.provincia|| '-' ||a.sigla|| '-' ||a.tomo|| '-' ||a.asiento as cedula, decode(a.firma,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("fotosimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.firma) firma, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.primer_nombre as nombre1, nvl(a.segundo_nombre,' ')  as nombre2, a.primer_apellido as apellido1, nvl(a.segundo_apellido,' ') as apellido2, nvl(a.apellido_casada, ' ') as casada, a.num_empleado as numEmpleado, nvl(a.num_ssocial, ' ') as seguro, a.num_dependiente as dependiente, a.licencia_conducir as conducir, a.OTROS_ING_FIJOS as otros, a.salario_base as salario, a.rata_hora as rata, a.REC_ALTO_RIESGO as recibe, nvl(a.calle_dir, ' ') as calle, nvl(a.casa__dir, ' ') as casa, nvl(a.apartado_postal, ' ') as apartado, nvl(a.zona_postal, ' ') as zona, nvl(a.telefono_casa, ' ') as telcasa, nvl(a.telefono_otro, ' ') as telotros, nvl(a.lugar_telefono, ' ') as tellugar, a.nacionalidad as nacionalidadCode, a.NUM_EMP_REMPLAZA as remplazado, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha, a.estado_civil as civil, a.sexo, a.sin_huella, a.vive_madre as vivemadre, a.vive_padre as vivepadre, nvl(a.nombre_madre, ' ') as madre, nvl(a.nombre_padre, ' ') as padre, nvl(a.emergencia_llamar, ' ') as llamar, a.telefono_emergencia as telefonos, a.num_hijos as hijos, a.num_cuenta as cta, nvl(a.email,' ') AS email, a.fecha_creacion as creacion, nvl(a.comentario, ' ') as comentario, nvl(a.cedula_beneficiario, ' ') as cbeneficiario, nvl(a.nombre_beneficiario, ' ') as nbeneficiario, nvl(a.apellido_beneficiario, ' ') as abeneficiario, nvl(a.num_contrato, ' ') as numero, to_char(a.fecha_contrato,'dd/mm/yyyy') as contrato, to_char(a.fecha_ingreso, 'dd/mm/yyyy') as ingreso, to_char(a.FECHA_EGRESO,'dd/mm/yyyy') as egreso, to_char(a.FECHA_PUESTOACT, 'dd/mm/yyyy') as puestoA, to_char(a.fecha_ult_aumento,'dd/mm/yyyy') as aumento, to_char(a.FECHA_INICIO_INCAPACIDAD, 'dd/mm/yyyy') as incapacidad , a.tipo_emple as tipos,  a.estado, a.tipo_pla as planilla, a.cargo, decode(a.comunidad_dir, null, ' ',a.comunidad_dir ) as comunidadC, decode(a.corregimiento_dir, null, ' ',a.corregimiento_dir) as corregimientoC, decode(a.distrito_dir,  null,'',a.distrito_dir) as distritoC, decode(a.provincia_dir, null, ' ', a.provincia_dir) as provinciaC, decode(a.pais_dir, null, ' ', a.pais_dir ) as paisC, decode(a.corregimiento_nac, null, ' ', a.corregimiento_nac) as corregimientoCode, decode(a.distrito_nac, null, ' ', a.distrito_nac) as distritoCode, decode(a.provincia_nac, null, ' ', a.provincia_nac) as provinciaCode, decode(a.pais_nac, null,' ',a.pais_nac) as paisCode, nvl(a.tipo_renta, ' ') as clave, a.forma_pago as forma, a.compania_uniorg, a.unidad_organi as secciones, nvl(a.tipo_sangre, ' ') as sang, nvl(a.rh, ' ') as sangre, a.tipo_cuenta as ahorro, a.gasto_rep as gastos, nvl(a.cargo_jefe, ' ') as jefe, a.sindicato as sindicatos, a.sind_nombre as spertenece, a.fuero, nvl(a.tipo_licencia, ' ') as licencia, nvl(a.numero_licencia, ' ') as nlicencia, nvl(a.dias_incapacidad,0) diasIncap, a.horario, a.acum_decimo as acumulado, a.acum_decimo_gr as gastoAcum, a.seccion, ss.descripcion nameseccion, nvl(a.ruta_bancaria, ' ') as ruta, a.CALCULO_RENTA_ESP as calculo, a.renta_fija as renta, a.valor_renta as valorenta, decode(a.foto,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("fotosimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.foto) as foto, a.horas_base as horas, a.ubic_depto, a.ubic_seccion, a.ubic_fisica as ubicacion, a.usar_apellido_casada as usar, to_char(a.fecha_fin_contrato,'dd/mm/yyyy') as fincontrato, a.digito_verificador as digito, a.salario_especie as especie, a.aseg_grupo, aseg_certificado, a.emp_id, a.jefe_emp_id, nvl(b.nacionalidad, 'NA') as nacionalidad, nvl(d.nombre_comunidad, ' ') as comunidadN, nvl(d.nombre_corregimiento, ' ') as corregimientoN, nvl(d.nombre_distrito, ' ') as distritoN, nvl(d.nombre_provincia, ' ') as provinciaN, nvl(d.nombre_pais, ' ') as paisN, nvl(e.nombre_pais, ' ') as paisName, nvl(e.nombre_provincia, ' ') as provinciaName, nvl(e.nombre_corregimiento, ' ') as corregimientoName, nvl(e.nombre_distrito, ' ') as distritoName, f.codigo as cot, f.descripcion as nameEmpleado, g.codigo as dire, g.descripcion as ubic_depto_desc, h.codigo as se, h.descripcion as ubic_seccion_desc, i.codigo as car, i.denominacion as nameCargo, z.CODIGO as uno, z.DENOMINACION as nameJefe, j.codigo as est, j.descripcion as nameEstado, k.codigo as fr, k.descripcion as nameForma, l.tipopla as tip, l.descripcion as namePlanilla, m.codigo as hor, m.descripcion as namehorario, n.clave as cls, n.descripcion as nameClave, p.codigo as ubs, p.descripcion as nameUbicacion,a.unidad_organi, w.descripcion as unidad_organi_desc,a.pasaporte from tbl_pla_empleado a, tbl_sec_pais b, tbl_pla_tipo_empleado f, (select codigo_pais, nombre_pais,  decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null, nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito,decode(codigo_corregimiento,0,null, codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) d, (select codigo_pais, nombre_pais, decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null,  nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito,decode(codigo_corregimiento,0,null, codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) e, tbl_sec_unidad_ejec g, tbl_sec_unidad_ejec h, tbl_pla_cargo i, TBL_PLA_CARGO z, tbl_pla_estado_emp j, tbl_pla_f_pago_emp k, tbl_pla_tipo_planilla l, tbl_pla_horario_trab m, tbl_pla_clave_renta n, tbl_sec_unidad_ejec w, tbl_sec_unidad_ejec p, tbl_sec_unidad_ejec ss where a.nacionalidad = b.codigo(+) and a.pais_dir = d.codigo_pais(+) and a.provincia_dir = d.codigo_provincia(+) and a.distrito_dir = d.codigo_distrito(+) and a.corregimiento_dir = d.codigo_corregimiento(+) and a.comunidad_dir = d.codigo_comunidad(+) and a.pais_nac = e.codigo_pais(+) and a.provincia_nac = e.codigo_provincia(+) and a.distrito_nac = e.codigo_distrito(+) and a.corregimiento_nac = e.codigo_corregimiento(+) and a.tipo_emple=f.codigo and a.UBIC_DEPTO=g.codigo(+)and a.unidad_organi = w.codigo(+) and a.compania = w.compania and a.compania=g.compania(+) and a.ubic_seccion = h.codigo(+) and a.compania= h.compania(+) and a.seccion = ss.codigo(+) and a.compania= ss.compania(+) and a.CARGO= i.codigo(+) and a.CARGO_JEFE = z.CODIGO(+) and a.compania = i.compania(+) and a.ESTADO = j.codigo(+) and a.FORMA_PAGO = k.codigo(+) and a.tipo_pla = l.tipopla(+) and a.HORARIO= m.codigo(+) and a.compania=m.compania(+) and a.TIPO_RENTA = n.clave(+) and a.compania = z.COMPANIA(+) and a.UBIC_FISICA = p.codigo(+) and a.compania= p.compania(+) and a.compania="+compania+" AND a.COMPANIA_UNIORG="+compania+" and a.emp_id= "+emp_id;
		emple = SQLMgr.getData(sql);
		if(fg.equalsIgnoreCase("reIngreso"))emple.addColValue("estado","13");
		if(change == null){
			//============================================  QUERY DE EDUCACION ============================================
			sql="select a.compania,a.codigo, a.lugar, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, to_char(a.fecha_final,'dd/mm/yyyy') as fecha_final, a.carrera, a.certificado_obt , a.termino, a.nivel , a.tipo as tipo,b.primer_nombre, b.primer_apellido, c.codigo as cot, c.descripcion as educacioName from tbl_pla_educacion a, tbl_pla_empleado b, tbl_pla_tipo_educacion c where a.emp_id=b.emp_id and a.tipo=c.codigo and a.compania=b.compania and a.compania="+compania+" and a.emp_id="+emp_id;
			al=SQLMgr.getDataList(sql);
			hteducacion.clear();
			htcursof.clear();
			hthabilidad.clear();
			htentrevista.clear();
			htidioma.clear();
			htenfermedad.clear();
			htmedida.clear();
			htreconocit.clear();
			htpariente.clear();
			vcteducacion.clear();
			vctcursof.clear();
			vcthabilidad.clear();
			vctentrete.clear();
			vctidioma.clear();
			vctenfermed.clear();
			vctmedidas.clear();
			vctreconoc.clear();
			vctpariente.clear();
			educaLastLineNo= al.size();
			for(int i=1; i<=al.size(); i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);
				if(i<10)  key = "00"+i;
				else if(i<100) key = "0"+i;
				else key= ""+i;
				cdo.addColValue("key",key);
				try{
					hteducacion.put(key,cdo);
					vcteducacion.addElement(cdo.getColValue("tipo"));
				} catch (Exception e) {
					System.err.println(e.getMessage());
				}//End Catch
			}//End for
			//============================================  QUERY DE CURSO  ===================================================
			sql="select a.compania,a.codigo, a.descripcion, a.institucion, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, to_char(a.fecha_final,'dd/mm/yyyy') as fecha_final, a.duracion, a.tipo, b.codigo as ot, b.descripcion as nameCurso, c.primer_nombre, c.primer_apellido from tbl_pla_cursos_fuera a, tbl_pla_tipo_actividad b, tbl_pla_empleado c where a.tipo=b.codigo(+) and a.emp_id=c.emp_id and a.compania= c.compania(+) and a.compania="+compania+" and a.emp_id="+emp_id;
			al=SQLMgr.getDataList(sql);
			cursoLastLineNo= al.size();
			for(int i=1; i<=al.size(); i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);
				if(i<10) key="00"+i;
				else if(i<100) key = "0" +i;
				else key=""+i;
				cdo.addColValue("key",key);
				try{
						htcursof.put(key,cdo);
						vctcursof.addElement(cdo.getColValue("tipo"));
				} catch (Exception e)	{
					System.err.println(e.getMessage());
				}//End Catch
			}//End For
			//============================================ QUERY DE HABILIDADES =========================================
			sql="select a.compania,a.habilidad, a.calificacion, b.descripcion  as habilidadName, c.primer_apellido, c.primer_nombre  from tbl_pla_habilidad_empl a, tbl_pla_habilidad b, tbl_pla_empleado c where a.habilidad=b.codigo(+) and a.emp_id= c.emp_id 	and a.compania = c.compania(+) and a.compania="+compania+" and a.emp_id="+emp_id;
			al=SQLMgr.getDataList(sql);
			habilidadLastLineNo= al.size();
			for(int i=1; i<=al.size();i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);
				if(i<10) 		key="00"+i;
				else if(i<100)  key = "0" +i;
				else key=""+i;
				cdo.addColValue("key",key);
				try{
					hthabilidad.put(key,cdo);
					vcthabilidad.addElement(cdo.getColValue("habilidad"));
				} catch (Exception e){
					System.err.println(e.getMessage());
				}//End Catch
			}//End For
			//============================================  QUERY DE ENTRETENIMINETO  ============================================
			sql="select a.compania, a.entretenimiento, a.tipo, b.descripcion as entretenimientoName, c.primer_apellido, c.primer_nombre from tbl_pla_entretenimiento_empl a, tbl_pla_entretenimiento b, tbl_pla_empleado c where a.entretenimiento=b.codigo(+) and a.emp_id=c.emp_id and a.compania = c.compania(+) and a.compania="+compania+" and a.emp_id="+emp_id;
			al=SQLMgr.getDataList(sql);
			entrenimientoLastLineNo= al.size();
			for(int i=1; i<=al.size();i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);
				if(i<10) key="00"+i;
				else if(i<100) key = "0" +i;
				else key=""+i;
				cdo.addColValue("key",key);
				try{
					htentrevista.put(key,cdo);
					vctentrete.addElement(cdo.getColValue("entretenimiento"));
				} catch (Exception e)	{
					System.err.println(e.getMessage());
				}//End Catch
			}//End for
			//============================================  QUERY DE IDIOMAS ============================================
			sql="select a.compania, a.idioma, a.nivel_conversacional, a.nivel_lectura, a.nivel_escritura, b.descripcion as nameidioma, c.primer_nombre, c.primer_apellido from tbl_pla_idioma_empl a,tbl_pla_idioma b, tbl_pla_empleado c where a.idioma=b.codigo(+) and a.emp_id=c.emp_id and a.compania = c.compania(+) and a.compania="+compania+" and a.emp_id="+emp_id;
			al=SQLMgr.getDataList(sql);
			idiomaLastLineNo = al.size();
			for(int i=1; i<=al.size();i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);
				if(i<10) key="00"+i;
				else if(i<100) key = "0" +i;
				else key=""+i;
				cdo.addColValue("key",key);
				try{
					htidioma.put(key,cdo);
					vctidioma.addElement(cdo.getColValue("idioma"));
				} catch (Exception e){
					System.err.println(e.getMessage());
				}//End Catch
			}//End For
			//============================================  QUERY DE ENFERMEDAD  ============================================
			sql="select a.compania,a.enfermedad, a.alto_riesgo,b.descripcion as enfermedadName, c.primer_apellido, c.primer_nombre from tbl_pla_enfermedad_empl a, tbl_pla_enfermedad b, tbl_pla_empleado c where a.enfermedad=b.codigo(+) and a.emp_id=c.emp_id and a.compania = c.compania(+) and a.compania="+compania+" and a.emp_id="+emp_id;
			al=SQLMgr.getDataList(sql);
			enfermedadLastLineNo= al.size();
			for(int i=1; i<=al.size();i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);
				if(i<10) key="00"+i;
				else if(i<100) key = "0" +i;
				else key=""+i;
				cdo.addColValue("key",key);
				try	{
					htenfermedad.put(key,cdo);
					vctenfermed.addElement(cdo.getColValue("enfermedad"));
				} catch (Exception e){
					System.err.println(e.getMessage());
				}//End Catch
			}//End For
			//============================================  QUERY DE MEDIDAS  ============================================
			sql="select a.tipo_med, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fechamed, a.motivo, a.descripcion, a.autorizapo_por, c.primer_apellido, c.primer_nombre, b.descripcion as medidaName from tbl_pla_medidas_disciplinarias a ,tbl_pla_tipo_medida b, tbl_pla_empleado c where a.tipo_med=b.codigo(+) and a.emp_id=c.emp_id and a.compania= c.compania(+) and a.compania="+compania+" and a.emp_id="+emp_id;
			al=SQLMgr.getDataList(sql);
			medidadLastLineNo= al.size();
			for(int i=1; i<=al.size();i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);
				if(i<10) key="00"+i;
				else if(i<100) key = "0" +i;
				else key=""+i;
				cdo.addColValue("key",key);
				try {
					htmedida.put(key,cdo);
					vctmedidas.addElement(cdo.getColValue("tipo_med"));
				} catch (Exception e){
					System.err.println(e.getMessage());
				}//End Catch
			}//End For
			//============================================  QUERY DE RECONOCIMIENTOS  ============================================
			sql="select a.compania,a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.motivo, a.descripcion, a.comentario, c.primer_apellido, c.primer_nombre  from tbl_pla_reconocimiento a, tbl_pla_empleado c where a.emp_id=c.emp_id and a.compania=c.compania(+) and a.compania="+compania+" and a.emp_id="+emp_id;
			al  = SQLMgr.getDataList(sql);
			reconocimientoLastLineNo = al.size();
			for (int i=0; i<al.size(); i++){
				reconocimientoLastLineNo++;
				if (reconocimientoLastLineNo < 10) key = "00" + reconocimientoLastLineNo;
				else if (reconocimientoLastLineNo < 100) key = "0" + reconocimientoLastLineNo;
				else key = "" + reconocimientoLastLineNo;
				htreconocit.put(key, al.get(i));
			} //End For
			//============================================  QUERY DE PARIENTES  ============================================
			sql="select a.codigo,a.nombre , a.apellido , a.sexo, a.parentesco, a.dependiente, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento , a.vive_con_empleado, a.invalido, a.proteg_por_riesgo, a.trabaja, a.lugar_trabajo, a.telefono_trabajo, a.estudia, a.provincia, a.sigla, a.tomo, a.asiento, a.cod_compania, a.vive, to_char(a.fecha_fallecimiento,'dd/mm/yyyy') as fecha_fallecimiento, a.beneficiario, b.descripcion as parentescoName, c.primer_apellido, c.primer_nombre from tbl_pla_pariente a, tbl_pla_parentesco b, tbl_pla_empleado c where a.parentesco=b.codigo(+) and a.emp_id=c.emp_id and a.cod_compania = c.compania(+) and a.cod_compania="+compania+" and a.emp_id="+emp_id;
			al=SQLMgr.getDataList(sql);
			parienteLastLineNo= al.size();
			for(int i=1; i<=al.size();i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);
				if(i<10) key="00"+i;
				else if(i<100) key = "0" +i;
				else key=""+i;
				cdo.addColValue("key",key);
				try	{
					htpariente.put(key,cdo);
					vctpariente.addElement(cdo.getColValue("parentesco"));
				} catch (Exception e){
					System.err.println(e.getMessage());
				}//End Catch
			}//End For
		}//End change
	}//End Edit
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript" type="text/javascript">
document.title="Expediente de Empleados - "+document.title;
function agregar(){	abrir_ventana1('../common/search_ubicacion_geo.jsp?fp=empleNac');}
function localizacion(){ abrir_ventana1('../rhplanilla/list_ubic_direccion.jsp?fp=empleDir');}
function nacion(){	abrir_ventana1('../rhplanilla/list_pais.jsp?id=1');}
function Empleado(){	abrir_ventana1('../rhplanilla/list_tipo_empleado.jsp?id=2');}
function Direcciones(){	abrir_ventana1('../rhplanilla/list_direccion.jsp?fp=empleado&fg=<%=fp%>');}
function Gerencia(){	abrir_ventana1('../rhplanilla/list_departamento.jsp?fp=empleado&fg=<%=fp%>');}
function Secciones(){	abrir_ventana1('../rhplanilla/list_seccion.jsp?fp=empleado&fg=<%=fp%>');}
function Cargosss(){	abrir_ventana1('../rhplanilla/list_cargo.jsp?id=2');}
function Estados(){	abrir_ventana1('../rhplanilla/list_estado.jsp?id=2');}
function Formassss(){	abrir_ventana1('../rhplanilla/list_forma.jsp?fp=empleado');}
function Planillassss(){	abrir_ventana1('../rhplanilla/list_planilla.jsp?id=2');}
function Horariosss(){	abrir_ventana1('../rhplanilla/list_horario.jsp?fp=empleado');}
function Clavesss(){	abrir_ventana1('../rhplanilla/list_clave.jsp?fp=empleado');}
function Jefesss(){	abrir_ventana1('../rhplanilla/list_cargo.jsp?id=1');}
function Ubicaciones(){	abrir_ventana1('../rhplanilla/list_seccion.jsp?fp=empleadoSeccion');}
function clearPais(){document.form0.paisCode.value = '';document.form0.paisName.value = '';document.form0.provinciaCode.value = '';document.form0.provinciaName.value = '';document.form0.distritoCode.value = '';document.form0.distritoName.value = '';document.form0.corregimientoCode.value = '';document.form0.corregimientoName.value = '';}
function limpiarPaisDir(){document.form0.paisC.value = '';document.form0.paisN.value = '';document.form0.provinciaC.value = '';document.form0.provinciaN.value = '';document.form0.distritoC.value = '';document.form0.distritoN.value = '';document.form0.corregimientoC.value = '';document.form0.corregimientoN.value = '';document.form0.comunidadC.value = '';document.form0.comunidadN.value = '';}
function clearProvincia(){document.form0.provinciaCode.value = '';document.form0.provinciaName.value = '';document.form0.distritoCode.value = '';document.form0.distritoName.value = '';document.form0.corregimientoCode.value = '';document.form0.corregimientoName.value = '';}
function limpiarProvinDir(){document.form0.provinciaC.value = '';document.form0.provinciaN.value = '';document.form0.distritoC.value = '';document.form0.distritoN.value = '';document.form0.corregimientoC.value = '';document.form0.corregimientoN.value = '';document.form0.comunidadC.value = '';document.form0.comunidadN.value = '';}
function clearDistrito(){document.form0.distritoCode.value = '';document.form0.distritoName.value = '';document.form0.corregimientoCode.value = '';document.form0.corregimientoName.value = '';}
function limpiarDistritDir(){document.form0.distritoC.value = '';document.form0.distritoN.value = '';document.form0.corregimientoC.value = '';document.form0.corregimientoN.value = '';document.form0.comunidadC.value = '';document.form0.comunidadN.value = '';}
function clearCorregimiento(){document.form0.corregimientoCode.value = '';document.form0.corregimientoName.value = '';}
function limpiarCorregDir(){document.form0.corregimientoC.value = '';document.form0.corregimientoN.value = '';document.form0.comunidadC.value = '';document.form0.comunidadN.value = '';}
function clearComunidad(){document.form0.comunidadC.value = '';document.form0.comunidadN.value = '';}
function calculanor(){var hoy;var edad;var fecha;if (document.form0.fecha.value!=""){fecha=document.form0.fecha.value;hoy=new Date() ;var array_fecha = fecha.split("/") ;if (array_fecha.length!=3) 	document.form0.edades.value=" ";var ano ;ano = parseInt(array_fecha[2]);if (isNaN(ano))  document.form0.edades.value="";var mes ;mes = parseInt(array_fecha[1]);if (isNaN(mes)) document.form0.edades.value=" ";var dia ;dia = parseInt(array_fecha[0]);if (isNaN(dia)) document.form0.edades.value=" ";edad=hoy.getFullYear()- ano - 1; //-1 porque no se si ha cumplido años ya este año
if (hoy.getMonth() + 1 - mes < 0) //+ 1 porque los meses empiezan en 0
 document.form0.edades.value= edad ;if (hoy.getMonth() + 1 - mes > 0) document.form0.edades.value= edad+1;if (hoy.getUTCDate() - dia >= 0) document.form0.edades.value=edad + 1; document.form0.edades.value=edad + 1;}
}
function doAction(){
	calculanor();
	<%if(fp.equals("RH")){%>showHide(2);<%}%>
	showHide(3);

<%
if (request.getParameter("type") != null){
	     if(tab.equals("1")){%>educaci();
<%}	else if(tab.equals("2")){%>cursosFuera();
<%} else if(tab.equals("3")){%>habilidadExp();
<%}	else if(tab.equals("4")){%>entrevistaExp();
<%}	else if(tab.equals("5")){%>idiomaexp();
<%}	else if(tab.equals("6")){%>enfermedadExp();
<%} else if(tab.equals("7")){%>medidaExp():
<%} else if(tab.equals("9")){%>parienteExp();
<%}}%>
}
function educaci(){	abrir_ventana1('../rhplanilla/list_educa.jsp?fp=empleado&mode=<%=mode%>&emp_id=<%=emp_id%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&entrenimientoLastLineNo=<%=entrenimientoLastLineNo%>&idiomaLastLineNo=<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>&fg=<%=fg%>&fg1=<%=fp%>');}
function cursosFuera(){	abrir_ventana1('../rhplanilla/curso_list.jsp?fp=empleado&mode=<%=mode%>&emp_id=<%=emp_id%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&entrenimientoLastLineNo=<%=entrenimientoLastLineNo%>&idiomaLastLineNo=<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>&fg=<%=fg%>&fg1=<%=fp%>');}
function habilidadExp(){	abrir_ventana1('../rhplanilla/list_habilidad.jsp?fp=empleado&mode=<%=mode%>&emp_id=<%=emp_id%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&entrenimientoLastLineNo=<%=entrenimientoLastLineNo%>&idiomaLastLineNo=<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>&fg=<%=fg%>&fg1=<%=fp%>');}
function entrevistaExp(){	abrir_ventana1('../rhplanilla/list_entretenimiento.jsp?fp=empleado&mode=<%=mode%>&emp_id=<%=emp_id%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&entrenimientoLastLineNo=<%=entrenimientoLastLineNo%>&idiomaLastLineNo=<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>&fg=<%=fg%>&fg1=<%=fp%>');}
function idiomaexp(){	abrir_ventana1('../rhplanilla/list_idioma.jsp?fp=empleado&mode=<%=mode%>&emp_id=<%=emp_id%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&entrenimientoLastLineNo=<%=entrenimientoLastLineNo%>&idiomaLastLineNo=<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>&fg=<%=fg%>&fg1=<%=fp%>');}
function enfermedadExp(){	abrir_ventana1('../rhplanilla/list_enfermedad.jsp?fp=empleado&mode=<%=mode%>&emp_id=<%=emp_id%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&entrenimientoLastLineNo=<%=entrenimientoLastLineNo%>&idiomaLastLineNo=<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>&fg=<%=fg%>&fg1=<%=fp%>');}
function medidaExp(){	abrir_ventana1('../rhplanilla/list_medida.jsp?fp=empleado&mode=<%=mode%>&emp_id=<%=emp_id%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&entrenimientoLastLineNo=<%=entrenimientoLastLineNo%>&idiomaLastLineNo=<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>&fg=<%=fg%>&fg1=<%=fp%>');}
function parienteExp(){	abrir_ventana1('../rhplanilla/list_pariente.jsp?fp=empleado&mode=<%=mode%>&emp_id=<%=emp_id%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&entrenimientoLastLineNo=<%=entrenimientoLastLineNo%>&idiomaLastLineNo=<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>&fg=<%=fg%>&fg1=<%=fp%>');}
function checkProvincia(obj){var sigla=document.form0.sigla.value;var tomo=document.form0.tomo.value;var asiento=document.form0.asiento.value;
if(!isNaN(obj.value)){
return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_empleado',' provincia=\''+obj.value+'\' and sigla=\''+sigla+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\'','<%=emple.getColValue("provincia").trim()%>')}else alert('Valor Invalido!!');}
function checkSigla(obj){var provincia=document.form0.provincia.value;var tomo=document.form0.tomo.value;var asiento=document.form0.asiento.value;if(!isNaN(provincia)){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_empleado',' provincia=\''+provincia+'\' and sigla=\''+obj.value+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\'','<%=emple.getColValue("sigla").trim()%>')}else alert('Valor Invalido!!');}
function checkTomo(obj){var provincia=document.form0.provincia.value;var sigla=document.form0.sigla.value;var asiento=document.form0.asiento.value;if(!isNaN(provincia)){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_empleado',' provincia=\''+provincia+'\' and sigla=\''+sigla+'\' and tomo=\''+obj.value+'\' and asiento=\''+asiento+'\'','<%=emple.getColValue("tomo").trim()%>')}else alert('Valor Invalido!!');}
function checkAsiento(obj){var provincia=document.form0.provincia.value;var sigla=document.form0.sigla.value;var tomo=document.form0.tomo.value;if(!isNaN(provincia)){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_empleado','provincia=\''+provincia+'\' and sigla=\''+sigla+'\' and tomo=\''+tomo+'\' and asiento=\''+obj.value+'\'','<%=emple.getColValue("asiento").trim()%>')}else alert('Valor Invalido!!');}
function checkCode(obj){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_empleado','num_empleado=\''+obj.value+'\'','<%=emple.getColValue("numEmpleado")%>');}
function Empleado(){abrir_ventana2('../rhplanilla/empleado_ingreso_list.jsp?fp=ingreso_solicitud');}
function addNota(){var emp_id=document.form0.emp_id.value;abrir_ventana2('../rhplanilla/reg_notas.jsp?fp=exp_empleado&emp_id='+emp_id);}
function calValue(){var horas=document.form0.horas.value;var salario=document.form0.salario.value;if(horas!=''&&salario!=''){document.form0.rata.value = (salario / (horas * 4.333)).toFixed(5);}}

$(document).ready(function(){
	$("#tabTabdhtmlgoodies_tabView1_11").on("click",function(){
        $('#iFingerprint').attr('src', '../biometric/capture_fingerprint.jsp?mode=<%=mode%>&fp=employee&type=EMP&owner=<%=emp_id%>');
	});
});
function isValidId()
{ 
      var pasaporte=document.form0.pasaporte.value.trim();
	  if(pasaporte!='')
	  {
	    if('<%=emple.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>'!=pasaporte)
		{
			if(hasDBData('<%=request.getContextPath()%>','tbl_pla_empleado','pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\'',''))
			{
				CBMSG.warning('Ya existe un empleado con este número de PASAPORTE!');
				return false;
			}  
		}
	}
	return true;
}
function checkPasaporte(obj)
{ 
	if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_empleado',' pasaporte=\''+obj.value+'\' ','<%=emple.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>')) return true;
	else return false;

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPEDIENTE DE EMPLEADOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
				<tr>
					<td><!--Inicio del Tab Principal -->
						<div id="dhtmlgoodies_tabView1">
							<!-- Tab0 Div Start Here -->
							<div class="dhtmlgoodies_aTab">
								<table width="100%" align="center" cellpadding="0" cellspacing="1">
									<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
									<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
									<%=fb.formStart(true)%>
									<%=fb.hidden("tab","0")%><%=fb.hidden("mode",mode)%><%=fb.hidden("id",id)%>
									<%=fb.hidden("emp_id",emp_id)%><%=fb.hidden("baction","")%>
									<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%><%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
									<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%><%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
									<%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%><%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%>
									<%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%><%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%>
									<%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%><%=fb.hidden("educacionSize",""+hteducacion.size())%>
									<%=fb.hidden("cursofSize",""+htcursof.size())%><%=fb.hidden("habilidadSize",""+hthabilidad.size())%>
									<%=fb.hidden("entrevistaSize",""+htentrevista.size())%><%=fb.hidden("idiomaSize",""+htidioma.size())%>
									<%=fb.hidden("enfermedadSize",""+htenfermedad.size())%><%=fb.hidden("medidadSize",""+htmedida.size())%>
									<%=fb.hidden("reconSize",""+htreconocit.size())%><%=fb.hidden("parienteSize",""+htpariente.size())%>
									<%=fb.hidden("fg",fg)%><%=fb.hidden("fp",fp)%>
									<%fb.appendJsValidation("if(checkCode(document.form0.numEmpleado))error++;");%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel" onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
													<td colspan="3" width="95%">&nbsp;Generales del Empleado</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;
													</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;C&eacute;dula</td>
													<td colspan="1">
													<%=fb.intBox("provincia",emple.getColValue("provincia"),true,false,(!mode.equals("add")),5,2,null,null,"onBlur=\"javascript:checkProvincia(this)\"")%>
													<%=fb.textBox("sigla",emple.getColValue("sigla"),true,false,(!mode.equals("add")),5,2,null,null,"onBlur=\"javascript:checkSigla(this)\"")%>
													<%=fb.intBox("tomo",emple.getColValue("tomo"),true,false,(!mode.equals("add")),5,5,null,null,"onBlur=\"javascript:checkTomo(this)\"")%>
													<%=fb.intBox("asiento",emple.getColValue("asiento"),true,false,(!mode.equals("add")),5,6,null,null,"onBlur=\"javascript:checkAsiento(this)\"")%>/PASS:<%=fb.textBox("pasaporte",emple.getColValue("pasaporte"),false,false,(!mode.equals("add")),15,20,null,null,"onBlur=\"javascript:checkPasaporte(this)\"")%>
													</td>
													<td colspan="1">&nbsp;&nbsp;&nbsp;&nbsp;Foto</td>
													<td><%=fb.fileBox("foto",emple.getColValue("foto"),false,viewMode,20)%></td>
												</tr>
												<tr class="TextRow01" >
													<td width="17%">&nbsp;Primer Nombre</td>
													<td width="33%"><%=fb.textBox("nombre1",emple.getColValue("nombre1"),true,false,viewMode,30,30)%></td>
													<td width="20%">&nbsp;&nbsp;&nbsp;&nbsp;Segundo Nombre</td>
													<td width="30%"><%=fb.textBox("nombre2",emple.getColValue("nombre2"),false,false,viewMode,30,30)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;Primer Apellido</td>
													<td><%=fb.textBox("apellido1",emple.getColValue("apellido1"),true,false,viewMode,30,30)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Segundo Apellido</td>
													<td><%=fb.textBox("apellido2",emple.getColValue("apellido2"),false,false,viewMode,30,30)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;Apellido de Casada</td>
													<td><%=fb.textBox("casada",emple.getColValue("casada"),false,false,viewMode,30,30)%>&nbsp;
														Usar &nbsp;<%=fb.checkbox("usar","S",(emple.getColValue("usar") != null && emple.getColValue("usar").equalsIgnoreCase("S")),viewMode)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Estado Civil</td>
													<td><%=fb.select("civil","CS=CASADO, DV=DIVORCIADO, SP=SEPARADO, ST=SOLTERO, UN=UNIDO, VD=VIUDO ",emple.getColValue("civil"))%> </td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel0">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td>&nbsp;Fecha Nacimiento</td>
													<td>
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="nameOfTBox1" value="fecha" />
														<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("fecha")%>" />
														
														<jsp:param name="jsEvent" value="calculanor()" />
														</jsp:include>
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Edad:&nbsp;&nbsp; <%=fb.textBox("edades","",false,false,true,5)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;No. S.S.</td>
													<td><%=fb.textBox("seguro", emple.getColValue("seguro"),false,false,viewMode,15,20)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;Sexo</td>
													<td><%=fb.select("sexo","F=FEMENINO, M=MASCULINO",emple.getColValue("sexo"))%>
													
													&nbsp;&nbsp;&nbsp;&nbsp;
													Sin huella:
													<%=fb.select("sin_huella","Z=--SELECCIONE--,S=SI,N=NO",emple.getColValue("sin_huella"))%> 
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Nacionalidad</td>
													<td>
													<%=fb.intBox("nacionalidadCode",emple.getColValue("nacionalidadCode"),true,false,true,5,4)%>
													<%=fb.textBox("nacionalidad",emple.getColValue("nacionalidad"),false,false,true,23)%>
													<%=fb.button("btndireccion","...",true,viewMode,null,null,"onClick=\"javascript:nacion()\"")%>
													</td>
												</tr>
												<tr class="TextHeader">
													<td colspan="4">Lugar de Nacimiento</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Pa&iacute;s</td>
													<td>
													<%=fb.intBox("paisCode",emple.getColValue("paisCode"),false,false,true,5,4,null,null,"onDblClick=\"javascript:clearPais()\"")%>
													<%=fb.textBox("paisName",emple.getColValue("paisName"),false,false,true,23,null,null,"onDblClick=\"javasript:clearPais()\"")%>
													<%=fb.button("btnpais","...",true,viewMode,null,null,"onClick=\"javascript:localizacion()\"")%>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Provincia</td>
													<td>
													<%=fb.intBox("provinciaCode",emple.getColValue("provinciaCode"),false,false,true,5,2,null,null,"onDblClick=\"javascript:clearProvincia()\"")%>
													<%=fb.textBox("provinciaName",emple.getColValue("ProvinciaName"),false,false,true,23,null,null,"onDblClick=\"javascript:clearProvincia()\"")%>
													</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Distrito</td>
													<td>
													<%=fb.intBox("distritoCode",emple.getColValue("distritoCode"),false,false,true,5,3,null,null,"onDblClick=\"javascript:clearDistrito()\"")%>
													<%=fb.textBox("distritoName",emple.getColValue("distritoName"),false,false,true,23,null,null,"onDblClick=\"javascript:clearDistrito()\"")%>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Corregimiento</td>
													<td>
													<%=fb.intBox("corregimientoCode",emple.getColValue("corregimientoCode"),false,false,true,5,4,null,null,"onDblClick=\"javascript:clearCorregimiento()\"")%>
													<%=fb.textBox("corregimientoName",emple.getColValue("corregimientoName"),false,false,true,23,null,null,"onDblClick=\"javasccript:clearCorregimiento()\"")%>
													</td>
												</tr>
												<tr class="TextHeader">
													<td colspan="4">Direcci&oacute;n</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Pa&iacute;s</td>
													<td>
													<%=fb.intBox("paisC",emple.getColValue("paisC"),false,false,true,5,4,null,null,"onDblClick=\"javascript:limpiarPaisDir()\"")%>
													<%=fb.textBox("paisN",emple.getColValue("paisN"),false,false,true,23,null,null,"onDblClick=\"javascript:limpiarPaisDir()\"")%>
													<%=fb.button("btndireccion","Ir",true,false,null,null,"onClick=\"javascript:agregar();\"")%>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Provincia</td>
													<td>
													<%=fb.intBox("provinciaC",emple.getColValue("provinciaC"),false,false,true,5,2,null,null,"onDblClick=\"javascript:limpiarProvinDir()\"")%>
													<%=fb.textBox("provinciaN",emple.getColValue("provinciaN"),false,false,true,23,null,null,"onDblClick=\"javascript:limpiarProvinDir()\"")%>
													</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Distrito</td>
													<td>
													<%=fb.intBox("distritoC",emple.getColValue("distritoC"),false,false,true,5,3,null,null,"onDblClick=\"javascript:limpiarDistritDir()\"")%>
													<%=fb.textBox("distritoN",emple.getColValue("distritoN"),false,false,true,23,null,null,"onDblClick=\"javascript:limpiarDistritDir()\"")%>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Corregimiento</td>
													<td>
													<%=fb.intBox("corregimientoC",emple.getColValue("corregimientoC"),false,false,true,5,4,null,null,"onDblClick=\"javascript:limpiarCorregDir()\"")%>
													<%=fb.textBox("corregimientoN",emple.getColValue("corregimientoN"),false,false,true,23,null,null,"onDblClick=\"javascript:limpiarCorregDir()\"")%>
													</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Comunidad</td>
													<td>
													<%=fb.intBox("comunidadC",emple.getColValue("comunidadC"),false,false,true,5,6,null,null,"onDblClick=\"javascript:clearComunidad()\"")%>
													<%=fb.textBox("comunidadN",emple.getColValue("comunidadN"),false,false,true,23,null,null,"onDblClick=\"javascript:clearComunidad()\"")%>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Calle</td>
													<td><%=fb.textBox("calle",emple.getColValue("calle"),false,false,false,34,50)%>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Casa</td>
													<td colspan="3"><%=fb.textBox("casa",emple.getColValue("casa"),false,false,viewMode,34,50)%></td>
												</tr>
												<tr class="TextHeader">
													<td colspan="4">&nbsp;Telefono</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Tel. Casa</td>
													<td><%=fb.textBox("telcasa",emple.getColValue("telcasa"),false,false,viewMode,34,11)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Tel. Celular/Otros</td>
													<td><%=fb.textBox("telotros",emple.getColValue("telotros"),false,false,viewMode,34,11)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Tel. Oficina </td>
													<td colspan="3"><%=fb.textBox("tellugar",emple.getColValue("tellugar"),false,false,viewMode,34,11)%></td>
												</tr>
												<tr class="TextHeader">
													<td colspan="4">Direccion Postal</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Apartado</td>
													<td><%=fb.textBox("apartado",emple.getColValue("apartado"),false,false,viewMode,34,20)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Zona</td>
													<td><%=fb.textBox("zona",emple.getColValue("zona"),false,false,viewMode,34,20)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Correo Electronico</td>
													<td colspan="3"><%=fb.emailBox("email",emple.getColValue("email"),false,false,viewMode,34,100)%></td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Generales de Trabajo</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel1">
										<td height="301"><table width="100%" cellpadding="1" cellspacing="1" align="center">
												<tr class="TextRow01">
													<td width="17%">&nbsp;&nbsp;&nbsp;&nbsp;Tipo de Empleado</td>
													<td width="33%"><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_pla_tipo_empleado order by descripcion ","tipos",emple.getColValue("tipos"))%> </td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;No. Empleado</td>
													<td><%=fb.textBox("numEmpleado",emple.getColValue("numEmpleado"),true,false,(!mode.trim().equals("add")),20,15,null,null,"onBlur=\"javascript:checkCode(this)\"")%> </td>
												</tr>
												<%if(fp.equals("planilla_old")){%>
												<tr class="TextRow01">
													<td width="17%">&nbsp;&nbsp;&nbsp;&nbsp;Direcci&oacute;n</td>
													<td width="33%">
													<%=fb.intBox("ubic_depto",emple.getColValue("ubic_depto"),true,false,true,5,4)%>
													<%=fb.textBox("ubic_depto_desc",emple.getColValue("ubic_depto_desc"),false,false,true,28)%>
													<%=fb.button("btnDireccion","...",true,viewMode,null,null,"onClick=\"javascript:Gerencia();\"")%>
													</td>
													<td width="20%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
													<td width="30%">
													</td>
												</tr>
												<%} else if(fp.equals("rrhh")|| fp.equals("planilla")|| fp.equals("RH")){%>
												<tr class="TextRow01">
													<td width="17%">&nbsp;&nbsp;&nbsp;&nbsp;Direcci&oacute;n</td>
													<td width="33%">					  
													<%=fb.intBox("unidad_organi",emple.getColValue("unidad_organi"),true,false,true,5,4)%> 
						  							<%=fb.textBox("unidad_organi_desc",emple.getColValue("unidad_organi_desc"),false,false,true,28)%> 
													  <%=fb.button("btnDireccion","...",true,viewMode,null,null,"onClick=\"javascript:Direcciones();\"")%> 
													</td>
													<%if(fp.equals("RH")){%>
													<%=fb.hidden("ubic_depto",emple.getColValue("ubic_depto"))%>
													<%=fb.hidden("ubic_depto_desc",emple.getColValue("ubic_depto_desc"))%>
													<td width="20%">&nbsp;&nbsp;&nbsp;&nbsp;</td>
													<td width="30%">&nbsp;</td>
													<%}else{%>
													<td width="20%">&nbsp;&nbsp;&nbsp;&nbsp;Gerencia</td>
													<td width="30%">
													<%=fb.intBox("ubic_depto",emple.getColValue("ubic_depto"),false,false,true,5,4)%>
													<%=fb.textBox("ubic_depto_desc",emple.getColValue("ubic_depto_desc"),false,false,true,28)%>
													<%=fb.button("btnDireccion","...",true,viewMode,null,null,"onClick=\"javascript:Gerencia();\"")%>
													</td>
													<%}%>
												</tr>
												<%}%>
												<%if(fp.equals("planilla_old")|| fp.equals("RH")){%>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Secci&oacute;n</td>
													<td>
													<%=fb.textBox("ubic_seccion",emple.getColValue("ubic_seccion"),true,false,true,5,12)%>
													<%=fb.textBox("ubic_seccion_desc",emple.getColValue("ubic_seccion_desc"),false,false,true,28)%>
													<%=fb.button("btnSeccion","...",true,viewMode,null,null,"onClick=\"javascript:Secciones();\"")%>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Cargos</td>
													<td>
													<%=fb.textBox("cargo",emple.getColValue("cargo"),true,false,true,5,12)%>
													<%=fb.textBox("nameCargo",emple.getColValue("nameCargo"),false,false,true,28)%>
													<%=fb.button("btnCargo","...",true,viewMode,null,null,"onClick=\"javascript:Cargosss()\"")%>
													</td>
												</tr>
												<%} else if(fp.equals("rrhh")|| fp.equals("planilla")){%>
												<tr class="TextRow01">
													<%if(fp.equals("rrhh")|| fp.equals("planilla")){%>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Secci&oacute;n</td>
													<td>
													<%=fb.intBox("seccion",emple.getColValue("seccion"),true,false,true,5,4)%>
													<%=fb.textBox("nameseccion",emple.getColValue("nameseccion"),false,false,true,28)%>
													<%=fb.button("btnSeccion","...",true,false,null,null,"onClick=\"javascript:Secciones();\"")%>
													</td>
													<%}else{%><%=fb.hidden("seccion",emple.getColValue("seccion"))%>
													<%=fb.hidden("nameseccion",emple.getColValue("nameseccion"))%>
													<%}%>
													
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Cargos</td>
													<td>
													<%=fb.textBox("cargo",emple.getColValue("cargo"),true,false,true,5,12)%>
													<%=fb.textBox("nameCargo",emple.getColValue("nameCargo"),false,false,true,28)%>
													<%=fb.button("btnCargo","...",true,viewMode,null,null,"onClick=\"javascript:Cargosss()\"")%>
													</td>
													
												</tr>
												<%=fb.hidden("ubic_seccion",emple.getColValue("ubic_seccion"))%>
												<%}%>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Estado</td>
													<td>
													<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_pla_estado_emp "+((fg.equalsIgnoreCase("ingreso")||fg.equalsIgnoreCase("reIngreso"))?"where codigo =13 ":"")+" order by descripcion ","estado",emple.getColValue("estado"))%>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Forma de Pago</td>
													<td><%=fb.select(ConMgr.getConnection()," select codigo, descripcion from tbl_pla_f_pago_emp order by descripcion ","forma",emple.getColValue("forma"))%> </td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Tipo de Planilla</td>
													<td><%=fb.select(ConMgr.getConnection(),"select tipopla as codigo, descripcion from tbl_pla_tipo_planilla order by descripcion ","planilla",emple.getColValue("planilla"))%> </td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Horario de Trabajo</td>
													<td>
													<%=fb.intBox("horario",emple.getColValue("horario"),false,false,true,5,4)%>
													<%=fb.textBox("namehorario",emple.getColValue("namehorario"),false,false,true,28)%>
													<%=fb.button("btnHorario","...",true,viewMode,null,null,"onClick=\"javascript:Horariosss();\"")%>
													</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Clave de Renta</td>
													<td><%=fb.select(ConMgr.getConnection(),"select clave from tbl_pla_clave_renta order by clave ","clave",emple.getColValue("clave"))%> </td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;No. Dependiente</td>
													<td><%=fb.intBox("dependiente",emple.getColValue("dependiente"),false,false,viewMode,20,2)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;D&iacute;gito Verificador</td>
													<td><%=fb.intBox("digito",emple.getColValue("digito"),false,false,viewMode,20,4)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Tipo de Cuenta</td>
													<td><%=fb.select("ahorro","A=Cta. Ahorro,C=Cta. Corriente",emple.getColValue("ahorro"))%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;No. Cta. Bancaria</td>
													<td><%=fb.textBox("cta",emple.getColValue("cta"),false,false,viewMode,20,20)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Horas Base(Semanales)</td>                             <td>&nbsp;<%=fb.decBox("horas",emple.getColValue("horas"),false,false,false,20,"Text10",null,"onChange=\"javascript:calValue()\"")%></td>								
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Ruta Bancaria</td>
													<td><%=fb.textBox("ruta",emple.getColValue("ruta"),false,false,viewMode,20,9)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Salario Base</td>										<td>&nbsp;<%=fb.decBox("salario",emple.getColValue("salario"),true,false,false,20,"Text10",null,"onChange=\"javascript:calValue()\"")%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Gastos de Rep.</td>
													<td><%=fb.decBox("gastos",emple.getColValue("gastos"),false,false,viewMode,20,11.2)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Rata x Hora</td>
													<td><%=fb.decBox("rata",emple.getColValue("rata"),false,false,viewMode,20,8.6)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Fecha de Ingreso</td>
													<td>
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="nameOfTBox1" value="ingreso" />
														<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("ingreso")%>" />
														</jsp:include>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Fecha Contrato</td>
													<td>
													<jsp:include page="../common/calendar.jsp" flush="true">
													<jsp:param name="noOfDateTBox" value="1" />
													<jsp:param name="nameOfTBox1" value="contrato" />
													<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("contrato")%>" />
													</jsp:include>
													</td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Datos del Puesto</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel2">
										<td><table width="100%" cellpadding="1" cellspacing="1" align="center">
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;No. Remplazado</td>
													<td><%=fb.intBox("remplazado",emple.getColValue("remplazado"),false,false,viewMode,10,20)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;I/S [Renta Fija]</td>
													<td><%=fb.checkbox("renta","S",(emple.getColValue("renta") != null && emple.getColValue("renta").equalsIgnoreCase("S")),false)%>&nbsp;&nbsp;[V. Renta Fija.]&nbsp;&nbsp; <%=fb.decBox("valorenta",emple.getColValue("valorenta"),false,false,viewMode,10,11.2)%> </td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;No. de Contrato</td>
													<td><%=fb.intBox("numero",emple.getColValue("numero"),false,false,viewMode,10,20)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;I/S [Recibe Pago x Alto Riesgo?]</td>
													<td><%=fb.checkbox("recibe","S",(emple.getColValue("recibe") != null && emple.getColValue("recibe").equalsIgnoreCase("S")),false)%> </td>
												</tr>
												<tr class="TextRow01">
													<td width="23%">&nbsp;&nbsp;&nbsp;&nbsp;Días de Incapacidad </td>
													<td width="25%"><%=fb.decBox("diasIncap",emple.getColValue("diasIncap"),false,false,viewMode,20,6.2)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Acum. Gastos Rep. XIII Mes</td>
													<td><%=fb.decBox("gastoAcum",emple.getColValue("gastoAcum"),false,false,viewMode,20,11.2)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Otros Ingresos</td>
													<td><%=fb.decBox("otros",emple.getColValue("otros"),false,false,viewMode,20,9.2)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Acum. de Salario Para XIII Mes </td>
													<td><%=fb.decBox("acumulado",emple.getColValue("acumulado"),false,false,viewMode,20,11.2)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Fecha de Egreso</td>
													<td>
													<jsp:include page="../common/calendar.jsp" flush="true">
													<jsp:param name="noOfDateTBox" value="1" />
													<jsp:param name="clearOption" value="true" />
													<jsp:param name="nameOfTBox1" value="egreso" />
													<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("egreso")%>" />
													</jsp:include>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Fecha de Puesto Actual</td>
													<td>
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="clearOption" value="true" />
														<jsp:param name="nameOfTBox1" value="puestoA" />
														<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("puestoA")%>" />
														</jsp:include>
													</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Fecha de &Uacute;ltimo Aumento</td>
													<td>
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="clearOption" value="true" />
														<jsp:param name="nameOfTBox1" value="aumento" />
														<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("aumento")%>" />
														</jsp:include>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;F. Inicio Nvo. Conteo Incapacidad</td>
													<td>
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="clearOption" value="true" />
														<jsp:param name="nameOfTBox1" value="incapacidad" />
														<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("incapacidad")%>" />
														</jsp:include>
													</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Cargo del Jefe del Empleado</td>
													<td>
													<%=fb.textBox("jefe",emple.getColValue("jefe"),false,false,true,4,12)%>
													<%=fb.textBox("nameJefe",emple.getColValue("nameJefe"),false,false,true,20)%>
													<%=fb.button("btnJefe","...",true,viewMode,null,null,"onClick=\"javascript:Jefesss();\"")%>
													</td>
													<%if(fp.equals("rrhh")|| fp.equals("planilla")){%>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Ubicaci&oacute;n F&iacute;sica del Empleado</td>
													<td>
													<%=fb.intBox("ubicacion",emple.getColValue("ubicacion"),true,false,true,3,4)%>
													<%=fb.textBox("nameUbicacion",emple.getColValue("nameUbicacion"),true,false,true,20)%>
													<%=fb.button("btnUbicacion","...",true,viewMode,null,null,"onClick=\"javascript:Ubicaciones()\"")%>
													</td><%}else{%> <td colspan="2">&nbsp;</td><%}%>
												</tr>
												
												
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Otros Datos del Empleado</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel3">
										<td><table width="100%" align="center" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="18%">&nbsp;&nbsp;&nbsp;&nbsp;Lic. de Conducir</td>
													<td width="32%"><%=fb.checkbox("conducir","S",(emple.getColValue("conducir") != null && emple.getColValue("conducir").equalsIgnoreCase("S")),viewMode)%> </td>
													<td width="18%">&nbsp;&nbsp;&nbsp;&nbsp;Tipo de Lic:</td>
													<td width="32%"><%=fb.textBox("licencia",emple.getColValue("licencia"),false,false,viewMode,10,20)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;No. de Lic.</td>
													<td><%=fb.textBox("nlicencia",emple.getColValue("nlicencia"),false,false,viewMode,10,20)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Firma</td>
													<td><%=fb.fileBox("firma",emple.getColValue("firma"),false,viewMode,20)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Tipo Sangre</td>
													<td>
													<%=fb.select(ConMgr.getConnection()," select distinct tipo_sangre  from tbl_bds_tipo_sangre order by tipo_sangre ","sang",emple.getColValue("sang"))%>
													<%=fb.select(ConMgr.getConnection()," select distinct rh from tbl_bds_tipo_sangre order by rh","sangre",emple.getColValue("sangre"))%>
													</td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Hijos</td>
													<td><%=fb.intBox("hijos",emple.getColValue("hijos"),false,false,viewMode,10,2)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Nombre de la Madre</td>
													<td><%=fb.textBox("madre",emple.getColValue("madre"),false,false,viewMode,35,80)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Nombre de Padre</td>
													<td><%=fb.textBox("padre",emple.getColValue("padre"),false,false,viewMode,35,80)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Vive Madre?</td>
													<td><%=fb.checkbox("vivemadre","S",(emple.getColValue("vivemadre") != null && emple.getColValue("vivemadre").equalsIgnoreCase("S")),viewMode)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Vive Padre?</td>
													<td>
													<%=fb.checkbox("vivepadre","S",(emple.getColValue("vivepadre") != null && emple.getColValue("vivepadre").equalsIgnoreCase("S")),viewMode)%>
													&nbsp;&nbsp;&nbsp;
													<%=fb.button("btnNotas","Notas",true,false,null,null,"onClick=\"javascript:addNota();\"")%>
													</td>
												</tr>
												<tr class="TextHeader">
													<td colspan="4">&nbsp;Emergencia</td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Llamar a</td>
													<td><%=fb.textBox("llamar",emple.getColValue("llamar"),false,false,viewMode,35,80)%></td>
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Tel&eacute;fono</td>
													<td><%=fb.textBox("telefonos",emple.getColValue("telefonos"),false,false,viewMode,35,11)%></td>
												</tr>
												<tr class="TextRow01">
													<td>&nbsp;&nbsp;&nbsp;&nbsp;Comentario</td>
													<td colspan="3"><%=fb.textarea("comentario",emple.getColValue("comentario"),false,false,viewMode,50,4)%></td>
												</tr>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right"> Opciones de Guardar: <%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro <%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto <%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar <%=fb.submit("save","Guardar",true,viewMode)%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
									</tr>
									
<%fb.appendJsValidation("if(document."+fb.getFormName()+".save.value=='Guardar'&&!isValidId()){error++;}");%>
									<%=fb.formEnd(true)%>
								</table>
							</div>
							<!-- ===================   Tab1 EDUCACION    ============================ -->
							<div class="dhtmlgoodies_aTab">
								<table width="100%" cellpadding="0" cellspacing="1">
									<!-- =================   F O R M   S T A R T   H E R E   ================== -->
									<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
									<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
									<%=fb.formStart(true)%>
									<%=fb.hidden("mode",mode)%><%=fb.hidden("tab","1")%>
									<%=fb.hidden("emp_id",emp_id)%><%=fb.hidden("baction","")%>
									<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%><%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
									<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%><%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
									<%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%><%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%>
									<%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%><%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%>
									<%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%><%=fb.hidden("educacionSize",""+hteducacion.size())%>
									<%=fb.hidden("cursofSize",""+htcursof.size())%><%=fb.hidden("habilidadSize",""+hthabilidad.size())%>
									<%=fb.hidden("entrevistaSize",""+htentrevista.size())%><%=fb.hidden("idiomaSize",""+htidioma.size())%>
									<%=fb.hidden("enfermedadSize",""+htenfermedad.size())%><%=fb.hidden("medidadSize",""+htmedida.size())%>
									<%=fb.hidden("reconSize",""+htreconocit.size())%><%=fb.hidden("parienteSize",""+htpariente.size())%>
									<%=fb.hidden("fg",fg)%><%=fb.hidden("fp",fp)%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Registro de Empleado</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel10">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="15%" align="right">Empleado</td>
													<td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
													<td width="15%" align="right">Nombre del Empleado</td>
													<td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Educaci&oacute;n</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel11">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextHeader" align="center">
													<td width="5%">Cod.</td>
													<td width="5%">Cod. Tipo Educ.</td>
													<td width="10%">Educaci&oacute;n</td>
													<td width="14%">Carrera</td>
													<td width="13">T&iacute;tulo</td>
													<td width="13">Lugar</td>
													<td width="12%">Desde</td>
													<td width="12%">Hasta</td>
													<td width="5%">Termin&oacute;</td>
													<td width="6%">Años Cursados</td>
													<td width="5%"><%=fb.button("agregar","+",true,viewMode,null,null,"onClick=\"javascript:educaci()\"","Agregar Educación")%></td>
												</tr>
												<%
													String js = "";
													al=CmnMgr.reverseRecords(hteducacion);
													for(int i=1; i<=hteducacion.size(); i++)
													{
													key = al.get(i - 1).toString();
													CommonDataObject cdo = (CommonDataObject) hteducacion.get(key);
												%>
												<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
												<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%>
												<%=fb.hidden("educacioName"+i,cdo.getColValue("educacioName"))%>
												<%=fb.hidden("remove"+i,"")%>
												<tr class="TextRow01">
													<td align="center"><%=fb.intBox("code"+i,cdo.getColValue("codigo"),false,false,true,2,2,"Text10",null,null)%></td>
													<td align="center"><%=cdo.getColValue("tipo")%></td>
													<td><%=cdo.getColValue("educacioName")%></td>
													<td><%=fb.textBox("carrera"+i,cdo.getColValue("carrera"),true,false,viewMode,18,60,"Text10",null,null)%></td>
													<td><%=fb.textBox("titulo"+i,cdo.getColValue("certificado_obt"),false,false,viewMode,18,60,"Text10",null,null)%></td>
													<td><%=fb.textBox("lugar"+i,cdo.getColValue("lugar"),true,false,viewMode,18,60,"Text10",null,null)%></td>
													<td align="center"> <jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="clearOption" value="true" />
														<jsp:param name="nameOfTBox1" value="<%="fecha_inicio"+i%>" />
														<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_inicio")%>" />
														</jsp:include> 	</td>
													<td> 	<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1"/>
														<jsp:param name="clearOption" value="true" />
														<jsp:param name="nameOfTBox1" value="<%="fecha_final"+i%>"/>
														<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_final")%>"/>
														</jsp:include> </td>
													<td align="center">
													<%=fb.checkbox("termino"+i,"S",(cdo.getColValue("termino") != null && cdo.getColValue("termino").trim().equalsIgnoreCase("S")),viewMode)%>
													</td>
													<td><%=fb.select("nivel"+i,"1,2,3,4,5,6",cdo.getColValue("nivel"),false,viewMode,0,"Text10",null,null)%></td>
													<td align="center">
													<%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Educación")%>
													</td>
												</tr>
												<%}%>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right"> Opciones de Guardar:
										<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
										<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
										<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
										<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
										<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
										</td>
									</tr>
									<%=fb.formEnd(true)%>
								</table>
							</div>
							<%-- ==================== Tab2 Cursos de Afuera  ======================--%>
							<div class="dhtmlgoodies_aTab">
								<table width="100%" cellpadding="0" cellspacing="1">
									<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
									<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
									<%=fb.formStart(true)%>
									<%=fb.hidden("mode",mode)%><%=fb.hidden("tab","2")%><%=fb.hidden("baction","")%>
									<%=fb.hidden("emp_id",emp_id)%><%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
									<%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%><%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%>
									<%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%><%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%>
									<%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%><%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%>
									<%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%><%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>
									<%=fb.hidden("educacionSize",""+hteducacion.size())%><%=fb.hidden("cursofSize",""+htcursof.size())%>
									<%=fb.hidden("habilidadSize",""+hthabilidad.size())%><%=fb.hidden("entrevistaSize",""+htentrevista.size())%>
									<%=fb.hidden("idiomaSize",""+htidioma.size())%><%=fb.hidden("enfermedadSize",""+htenfermedad.size())%>
									<%=fb.hidden("medidadSize",""+htmedida.size())%><%=fb.hidden("reconSize",""+htreconocit.size())%>
									<%=fb.hidden("parienteSize",""+htpariente.size())%><%=fb.hidden("fg",fg)%><%=fb.hidden("fp",fp)%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Registro de Empleado</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel20">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="15%" align="right">Empleado</td>
													<td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
													<td width="15%" align="right">Nombre del Empleado</td>
													<td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Cursos Tomados Fuera</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel21">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextHeader" align="center">
													<td width="5%">&nbsp;Cod.</td>
													<td width="5%">Cod. Actividad</td>
													<td width="5">Actividad</td>
													<td width="25%">Lugar</td>
													<td width="25%">Descripci&oacute;n</td>
													<td width="15%">Fecha Inicio</td>
													<td width="15	%">Fecha Final</td>
													<td width="5%">Duraci&oacute;n</td>
													<td width="5%"><%=fb.button("agregar","+",true,viewMode,null,null,"onClick=\"javascript:cursosFuera()\"","Agregar Cursos")%></td>
												</tr>
												<%  al=CmnMgr.reverseRecords(htcursof);
													for (int i=1; i<=htcursof.size(); i++)
													{
													key = al.get(i - 1).toString();
													CommonDataObject cdo = (CommonDataObject) htcursof.get(key);
													String fecha_inicio1 = "fecha_inicio1"+i;
													String fecha_final1 = "fecha_final1"+i;
												%>
												<%=fb.hidden("key"+i,cdo.getColValue("key"))%> <%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%> <%=fb.hidden("nameCurso"+i,cdo.getColValue("nameCurso"))%> <%=fb.hidden("remove"+i,"")%>
												<tr class="TextRow01">
													<td><%=fb.intBox("code"+i,cdo.getColValue("codigo"),false,false,true,3,3,"Text10",null,null)%></td>
													<td><%=cdo.getColValue("tipo")%></td>
													<td><%=cdo.getColValue("nameCurso")%></td>
													<td><%=fb.textBox("institucion"+i,cdo.getColValue("institucion"),true,false,viewMode,30,60,"Text10",null,null)%></td>
													<td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),true,false,viewMode,30,60,"Text10",null,null)%></td>
													<td align="center">
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="clearOption" value="true" />
														<jsp:param name="nameOfTBox1" value="<%=fecha_inicio1%>" />
														<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_inicio")%>" />
														</jsp:include>
													</td>
													<td align="center">
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="clearOption" value="true" />
														<jsp:param name="nameOfTBox1" value="<%=fecha_final1%>" />
														<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_final")%>" />
														</jsp:include>
													</td>
													<td><%=fb.intBox("duracion"+i,cdo.getColValue("duracion"),false,false,viewMode,5,8,"Text10",null,null)%></td>
													<td align="center">
													<%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Cursos")%>
													</td>
												</tr>
												<%
						}//End for
						%>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right"> Opciones de Guardar:
										<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
										<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
										<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
										<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
										<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
										</td>
									</tr>
									<%=fb.formEnd(true)%>
								</table>
							</div>
							<%-- ========================= Tab3 Habilidades  =========================--%>
							<div class="dhtmlgoodies_aTab">
								<table width="100%" cellpadding="0" cellspacing="1">
									<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST); %>
									<%=fb.formStart(true)%>
									<%=fb.hidden("mode",mode)%><%=fb.hidden("tab","3")%>
									<%=fb.hidden("emp_id",emp_id)%><%=fb.hidden("baction","")%><%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
									<%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%><%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%>
									<%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%><%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%>
									<%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%><%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%>
									<%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%><%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>
									<%=fb.hidden("educacionSize",""+hteducacion.size())%><%=fb.hidden("cursofSize",""+htcursof.size())%>
									<%=fb.hidden("habilidadSize",""+hthabilidad.size())%><%=fb.hidden("entrevistaSize",""+htentrevista.size())%>
									<%=fb.hidden("idiomaSize",""+htidioma.size())%><%=fb.hidden("enfermedadSize",""+htenfermedad.size())%>
									<%=fb.hidden("medidadSize",""+htmedida.size())%><%=fb.hidden("reconSize",""+htreconocit.size())%>
									<%=fb.hidden("parienteSize",""+htpariente.size())%><%=fb.hidden("fg",fg)%><%=fb.hidden("fp",fp)%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Registro de Empleado</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel30">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="15%" align="right">Empleado</td>
													<td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
													<td width="15%" align="right">Nombre del Empleado</td>
													<td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Habilidades</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel31">
										<td><table width="100%" cellpadding="1" cellspacing="1">
											  <tr class="TextHeader" align="center">
												<td width="10%">Codigo</td>
												<td width="85%">Descripci&oacute;n</td>
												<td width="5%"><%=fb.button("agregar","+",true,viewMode,null,null,"onClick=\"javascript:habilidadExp()\"","Agregar Habilidades")%></td>
												</tr>
												<%
													al=CmnMgr.reverseRecords(hthabilidad);
													for(int i=1;i<=hthabilidad.size();i++)
													{
													key=al.get(i - 1).toString();
													CommonDataObject cdo = (CommonDataObject) hthabilidad.get(key);
												%>
												<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
												<%=fb.hidden("habilidad"+i,cdo.getColValue("habilidad"))%>
												<%=fb.hidden("habilidadName"+i,cdo.getColValue("habilidadName"))%>
												<%=fb.hidden("remove"+i,"")%>
												<tr class="TextRow01">
													<td align="center"><%=cdo.getColValue("habilidad")%></td>
													<td><%=cdo.getColValue("habilidadName")%></td>
													<td align="center">
													<%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Habilidades")%>
													</td>
												</tr>
												<%  } 	%>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right"> Opciones de Guardar:
										<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
										<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
										<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
										<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
										<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
										</td>
									</tr>
									<%=fb.formEnd(true)%>
								</table>
							</div>
							<%-- =============================   Tab4 Entretenimiento   ================= --%>
							<div class="dhtmlgoodies_aTab">
								<table width="100%"  cellpadding="0" cellspacing="1">
									<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
									<%=fb.formStart(true)%>
									<%=fb.hidden("mode",mode)%><%=fb.hidden("tab","4")%><%=fb.hidden("emp_id",emp_id)%><%=fb.hidden("baction","")%>
									<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%><%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
									<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%>
									<%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%><%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%>
									<%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%><%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%>
									<%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%><%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>
									<%=fb.hidden("educacionSize",""+hteducacion.size())%><%=fb.hidden("cursofSize",""+htcursof.size())%>
									<%=fb.hidden("habilidadSize",""+hthabilidad.size())%><%=fb.hidden("entrevistaSize",""+htentrevista.size())%>
									<%=fb.hidden("idiomaSize",""+htidioma.size())%><%=fb.hidden("enfermedadSize",""+htenfermedad.size())%>
									<%=fb.hidden("medidadSize",""+htmedida.size())%><%=fb.hidden("reconSize",""+htreconocit.size())%>
									<%=fb.hidden("parienteSize",""+htpariente.size())%><%=fb.hidden("fg",fg)%><%=fb.hidden("fp",fp)%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(40)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Registro de Empleado</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus40" style="display:none">+</label><label id="minus40">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel40">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="15%" align="right">Empleado</td>
													<td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
													<td width="15%" align="right">Nombre del Empleado</td>
													<td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(41)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Entretenimiento</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus41" style="display:none">+</label><label id="minus41">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel41">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextHeader" align="center">
													<td width="10%">C&oacute;digo</td>
													<td width="70%">Descripci&oacute;n</td>
													<td width="15%">Tipo</td>
													<td width="5%" align="center"><%=fb.button("agregar","+",true,viewMode,null,null,"onClick=\"javascript:entrevistaExp()\"","Agregar Entretenimientos")%></td>
												</tr>
												<%
													al=CmnMgr.reverseRecords(htentrevista);
													for (int i=1; i<=htentrevista.size(); i++)
													{
													key = al.get(i - 1).toString();
													CommonDataObject cdo = (CommonDataObject) htentrevista.get(key);
												%>
												<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
												<%=fb.hidden("entretenimiento"+i,cdo.getColValue("entretenimiento"))%>
												<%=fb.hidden("entretenimientoName"+i,cdo.getColValue("entretenimientoName"))%>
												<%=fb.hidden("remove"+i,"")%>
												<tr class="TextRow01" align="center">
													<td><%=cdo.getColValue("entretenimiento")%></td>
													<td align="left"><%=cdo.getColValue("entretenimientoName")%></td>
													<td><%=fb.select("tip"+i,"D=DEPORTE,P=PASATIEMPO",cdo.getColValue("tipo"),false,viewMode,0,"Text10",null,null)%></td>
													<td><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Entretenimiento")%></td>
												</tr>
												<%
													}
												%>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right"> Opciones de Guardar: <%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro <%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto <%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
									</tr>
									<%=fb.formEnd(true)%>
								</table>
							</div>
							<%-- ===========================  Tab5 Idioma  ======================== --%>
							<div class="dhtmlgoodies_aTab">
								<table width="100%" cellpadding="0" cellspacing="1">
									<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
									<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
									<%=fb.hidden("tab","5")%><%=fb.hidden("emp_id",emp_id)%><%=fb.hidden("baction","")%><%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
									<%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%><%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%>
									<%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%><%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%>
									<%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%><%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%>
									<%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%><%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>
									<%=fb.hidden("educacionSize",""+hteducacion.size())%><%=fb.hidden("cursofSize",""+htcursof.size())%>
									<%=fb.hidden("habilidadSize",""+hthabilidad.size())%><%=fb.hidden("entrevistaSize",""+htentrevista.size())%>
									<%=fb.hidden("idiomaSize",""+htidioma.size())%><%=fb.hidden("enfermedadSize",""+htenfermedad.size())%>
									<%=fb.hidden("medidadSize",""+htmedida.size())%><%=fb.hidden("reconSize",""+htreconocit.size())%>
									<%=fb.hidden("parienteSize",""+htpariente.size())%><%=fb.hidden("fg",fg)%><%=fb.hidden("fp",fp)%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(50)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Registro de Empleado</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus50" style="display:none">+</label><label id="minus50">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel50">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="15%" align="right">Empleado</td>
													<td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
													<td width="15%" align="right">Nombre del Empleado</td>
													<td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(51)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Idioma</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus51" style="display:none">+</label><label id="minus51">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel51">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextHeader" align="center">
													<td width="5%">Cod.</td>
													<td width="30%">Idioma</td>
													<td width="20%">Nivel de Conversaci&oacute;n</td>
													<td width="20%">Nivel de Lectura</td>
													<td width="20%">Nivel de Escritura</td>
													<td width="5%">&nbsp;<%=fb.button("agregar","+",true,viewMode,null,null,"onClick=\"javascript:idiomaexp()\"","Agregar Idiomas")%></td>
												</tr>
												<%
													al=CmnMgr.reverseRecords(htidioma);
													for (int i=1; i<=htidioma.size(); i++)
													{
													key = al.get(i - 1).toString();
													CommonDataObject cdo = (CommonDataObject) htidioma.get(key);
												%>
												<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
												<%=fb.hidden("idioma"+i,cdo.getColValue("idioma"))%>
												<%=fb.hidden("nameidioma"+i,cdo.getColValue("nameidioma"))%>
												<%=fb.hidden("remove"+i,"")%>
												<tr class="TextRow01" align="center">
													<td><%=cdo.getColValue("idioma")%></td>
													<td align="left"><%=cdo.getColValue("nameidioma")%></td>
													<td><%=fb.select("nivel_conversacional"+i,"A=AVANZADO,I=INTERMEDIO,B=BASICO",cdo.getColValue("nivel_conversacional"),false,viewMode,0,"Text10",null,null)%></td>
													<td><%=fb.select("nivel_lectura"+i,"A=AVANZADO,I=INTERMEDIO,B=BASICO",cdo.getColValue("nivel_lectura"),false,viewMode,0,"Text10",null,null)%></td>
													<td><%=fb.select("nivel_escritura"+i,"A=AVANZADO,I=INTERMEDIO,B=BASICO",cdo.getColValue("nivel_escritura"),false,viewMode,0,"Text10",null,null)%></td>
													<td><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Idioma")%></td>
												</tr>
												<%}
						%>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right"> Opciones de Guardar:
										<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
										<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
										<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
										<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',this.value)\"")%>
										<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
										</td>
									</tr>
									<%=fb.formEnd(true)%>
								</table>
							</div>
							<%-- ===========================  Tab6  Enfermedad  ===================== --%>
							<div class="dhtmlgoodies_aTab">
								<table width="100%" cellpadding="0" cellspacing="1">
									<%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					<%=fb.formStart(true)%><%=fb.hidden("mode",mode)%><%=fb.hidden("tab","6")%><%=fb.hidden("emp_id",emp_id)%><%=fb.hidden("baction","")%>
					<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%><%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
					<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%><%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
					<%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%><%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%>
					<%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%><%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%>
					<%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%><%=fb.hidden("educacionSize",""+hteducacion.size())%>
					<%=fb.hidden("cursofSize",""+htcursof.size())%><%=fb.hidden("habilidadSize",""+hthabilidad.size())%><%=fb.hidden("entrevistaSize",""+htentrevista.size())%>
					<%=fb.hidden("idiomaSize",""+htidioma.size())%><%=fb.hidden("enfermedadSize",""+htenfermedad.size())%><%=fb.hidden("medidadSize",""+htmedida.size())%>
					<%=fb.hidden("reconSize",""+htreconocit.size())%><%=fb.hidden("parienteSize",""+htpariente.size())%><%=fb.hidden("fg",fg)%><%=fb.hidden("fp",fp)%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Registro de Empleado</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel60">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="15%" align="right">Empleado</td>
													<td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
													<td width="15%" align="right">Nombre del Empleado</td>
													<td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(61)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Enfermedad</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus61" style="display:none">+</label><label id="minus61">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel61">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextHeader" align="center">
													<td width="5%">Codigo</td>
													<td width="75%">Enfermedad</td>
													<td width="15%">Alto Riesgo</td>
													<td width="5%" align="center">
													<%=fb.button("agregar","+",true,viewMode,null,null,"onClick=\"javascript:enfermedadExp()\"","Agregar Enfermedades")%>
													</td>
												</tr>
												<%
													al=CmnMgr.reverseRecords(htenfermedad);
													for (int i=1; i<=htenfermedad.size(); i++)
													{
													key = al.get(i - 1).toString();
													CommonDataObject cdo = (CommonDataObject) htenfermedad.get(key);
												%>
												<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
												<%=fb.hidden("enfermedad"+i,cdo.getColValue("enfermedad"))%>
												<%=fb.hidden("enfermedadName"+i,cdo.getColValue("enfermedadName"))%>
												<%=fb.hidden("remove"+i,"")%>
												<tr class="TextRow01" align="center">
													<td><%=cdo.getColValue("enfermedad")%></td>
													<td align="left"><%=cdo.getColValue("enfermedadName")%></td>
													<td>
													<%=fb.checkbox("alto_riesgo"+i,"S",(cdo.getColValue("alto_riesgo") != null && cdo.getColValue("alto_riesgo").trim().equalsIgnoreCase("S")),viewMode)%>
													</td>
													<td>
													<%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Enfermedades")%>
													</td>
												</tr>
												<%
													}
												%>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right"> Opciones de Guardar:
										<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
										<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
										<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
										<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
										<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
										</td>
									</tr>
									<%=fb.formEnd(true)%>
								</table>
							</div>
							<%-- ===========================  Tab7 Medidas Disciplinarias  ==================== --%>
							<div class="dhtmlgoodies_aTab">
								<table width="100%" cellpadding="0" cellspacing="1">
									<%fb = new FormBean("form7",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
									<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
									<%=fb.formStart(true)%>
									<%=fb.hidden("mode",mode)%><%=fb.hidden("tab","7")%><%=fb.hidden("emp_id",emp_id)%><%=fb.hidden("baction","")%>
									<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%><%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
									<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%><%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
									<%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%><%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%>
									<%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%><%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%>
									<%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%><%=fb.hidden("educacionSize",""+hteducacion.size())%>
									<%=fb.hidden("cursofSize",""+htcursof.size())%><%=fb.hidden("habilidadSize",""+hthabilidad.size())%>
									<%=fb.hidden("entrevistaSize",""+htentrevista.size())%><%=fb.hidden("idiomaSize",""+htidioma.size())%>
									<%=fb.hidden("enfermedadSize",""+htenfermedad.size())%><%=fb.hidden("medidadSize",""+htmedida.size())%>
									<%=fb.hidden("reconSize",""+htreconocit.size())%><%=fb.hidden("parienteSize",""+htpariente.size())%>
									<%=fb.hidden("fg",fg)%><%=fb.hidden("fp",fp)%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(70)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Registro de Empleado</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus70" style="display:none">+</label><label id="minus70">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel70">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="15%" align="right">Empleado</td>
													<td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
													<td width="15%" align="right">Nombre del Empleado</td>
													<td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(71)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Medidas Disciplinarias</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus71" style="display:none">+</label><label id="minus71">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel71">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextHeader" align="center">
													<td width="5%">Codigo</td>
													<td width="5%">Cod. Tipo</td>
													<td width="20%">Tipo</td>
													<td width="13%">Fecha</td>
													<td width="20%">Descripci&oacute;n</td>
													<td width="12%">Autorizado Por</td>
													<td width="20%">Motivo</td>
													<td width="5%" align="center"><%=fb.button("agregar","+",true,viewMode,null,null,"onClick=\"javascript:medidaExp()\"","Agregar Medidas")%></td>
												</tr>
												<%al=CmnMgr.reverseRecords(htmedida);
													for (int i=1; i<=htmedida.size(); i++)
													{
													key = al.get(i - 1).toString();
													CommonDataObject cdo = (CommonDataObject) htmedida.get(key);
												%>
												<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
												<%=fb.hidden("tipo_med"+i,cdo.getColValue("tipo_med"))%>
												<%=fb.hidden("medidaName"+i,cdo.getColValue("medidaName"))%>
												<%=fb.hidden("remove"+i,"")%>
												<tr class="TextRow01" align="center">
													<td><%=fb.intBox("code"+i,cdo.getColValue("codigo"),false,false,true,2,4,"Text10",null,null)%></td>
													<td align="left"><%=cdo.getColValue("tipo_med")%></td>
													<td><%=cdo.getColValue("medidaName")%></td>
													<td>
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="nameOfTBox1" value="<%="fechamed"+i%>" />
														<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechamed")%>" />
														</jsp:include>
													</td>
													<td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,viewMode,30,2000,"Text10",null,null)%></td>
													<td><%=fb.textBox("autorizado"+i,cdo.getColValue("autorizapo_por"),false,false,viewMode,15,100,"Text10",null,null)%></td>
													<td><%=fb.textBox("motivo"+i,cdo.getColValue("motivo"),true,false,viewMode,20,200,"Text10",null,null)%></td>
													<td><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Medidas")%></td>
												</tr>
												<%}%>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right"> Opciones de Guardar:
										<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
										<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
										<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
										<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
										<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
										</td>
									</tr>
									<%=fb.formEnd(true)%>
								</table>
							</div>
							<%-- ======================= TAB 8 RECONOCIMIENTO ======================= --%>
							<div class="dhtmlgoodies_aTab">
								<table width="100%" cellpadding="0" cellspacing="1">
									<%fb = new FormBean("form8",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
									<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
									<%=fb.formStart(true)%>
									<%=fb.hidden("mode",mode)%><%=fb.hidden("tab","8")%> <%=fb.hidden("emp_id",emp_id)%><%=fb.hidden("baction","")%>
									<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%><%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
									<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%><%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
									<%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%><%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%>
									<%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%><%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%>
									<%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%><%=fb.hidden("educacionSize",""+hteducacion.size())%>
									<%=fb.hidden("cursofSize",""+htcursof.size())%><%=fb.hidden("habilidadSize",""+hthabilidad.size())%>
									<%=fb.hidden("entrevistaSize",""+htentrevista.size())%><%=fb.hidden("idiomaSize",""+htidioma.size())%>
									<%=fb.hidden("enfermedadSize",""+htenfermedad.size())%><%=fb.hidden("medidadSize",""+htmedida.size())%>
									<%=fb.hidden("reconSize",""+htreconocit.size())%><%=fb.hidden("parienteSize",""+htpariente.size())%>
									<%=fb.hidden("fg",fg)%><%=fb.hidden("fp",fp)%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(80)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Registro de Empleado</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus80" style="display:none">+</label><label id="minus80">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel80">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="15%" align="right">Empleado</td>
													<td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
													<td width="15%" align="right">Nombre del Empleado</td>
													<td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(81)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Reconocimiento</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus81" style="display:none">+</label><label id="minus81">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel81">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextHeader" align="center">
													<td width="5%">Cod.</td>
													<td width="30%">Descripci&oacute;n</td>
													<td width="20%">Fecha</td>
													<td width="20%">Motivo</td>
													<td width="20%">Comentario</td>
													<td width="5%" align="center"><%=fb.submit("btnagrega","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
												</tr>
												<%	String jsps="";
													al=CmnMgr.reverseRecords(htreconocit);
													for (int i=0; i<htreconocit.size(); i++)
													{
													key = al.get(i).toString();
													CommonDataObject cdo = (CommonDataObject) htreconocit.get(key);
												%>
												<%=fb.hidden("key"+i,key)%> <%=fb.hidden("remove"+i,"")%>
												<tr class="TextRow01" align="center">
													<td><%=fb.intBox("code"+i,cdo.getColValue("codigo"),false,false,true,2,2,"Text10",null,null)%></td>
													<td align="left"><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,viewMode,20,100,"Text10",null,null)%></td>
													<td>
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
														<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
														</jsp:include>
													</td>
													<td><%=fb.textBox("motivo"+i,cdo.getColValue("motivo"),true,false,viewMode,20,100,"Text10",null,null)%></td>
													<td><%=fb.textBox("comentario"+i,cdo.getColValue("comentario"),false,false,viewMode,20,100,"Text10",null,null)%></td>
													<td>
													<%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Reconocimiento")%>
													</td>
												</tr>
												<%  } 	%>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right"> Opciones de Guardar:
										<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
										<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
										<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
										<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
										<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
										</td>
									</tr>
									<%=fb.formEnd(true)%>
								</table>
							</div>
							<%-- ======================== TAB9 PARIENTES ======================  --%>
							<div class="dhtmlgoodies_aTab">
								<table width="100%"  cellpadding="0" cellspacing="1">
									<%fb = new FormBean("form9",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
									<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
									<%=fb.formStart(true)%>
									<%=fb.hidden("mode",mode)%><%=fb.hidden("tab","9")%><%=fb.hidden("emp_id",emp_id)%><%=fb.hidden("baction","")%>
									<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%><%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%>
									<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%><%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
									<%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%><%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%>
									<%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%><%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%>
									<%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%><%=fb.hidden("educacionSize",""+hteducacion.size())%>
									<%=fb.hidden("cursofSize",""+htcursof.size())%><%=fb.hidden("habilidadSize",""+hthabilidad.size())%>
									<%=fb.hidden("entrevistaSize",""+htentrevista.size())%><%=fb.hidden("idiomaSize",""+htidioma.size())%>
									<%=fb.hidden("enfermedadSize",""+htenfermedad.size())%><%=fb.hidden("medidadSize",""+htmedida.size())%>
									<%=fb.hidden("reconSize",""+htreconocit.size())%><%=fb.hidden("parienteSize",""+htpariente.size())%>
									<%=fb.hidden("fg",fg)%><%=fb.hidden("fp",fp)%>
									<tr class="TextRow02">
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(90)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextPanel">
													<td width="95%">&nbsp;Registro de Empleado</td>
													<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus90" style="display:none">+</label><label id="minus90">-</label></font>]&nbsp;</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel90">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextRow01">
													<td width="15%" align="right">Empleado</td>
													<td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
													<td width="15%" align="right">Nombre del Empleado</td>
													<td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
												</tr>
											</table></td>
									</tr>
									<tr>
										<td onClick="javascript:showHide(91)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
												<tr class="TextHeader" height="45">
													<td width="95%">&nbsp;Parientes</td>
													<td width="5%" align="right">
														[<font face="Courier New, Courier, mono"><label id="plus91" style="display:none">+</label><label id="minus91">-</label></font>]&nbsp;
													</td>
												</tr>
											</table></td>
									</tr>
									<tr id="panel91">
										<td><table width="100%" cellpadding="1" cellspacing="1">
												<tr class="TextHeader" align="center">
													<td width="5%" rowspan="2">C&oacute;d.</td>
													<td width="20%" rowspan="2">Nombre</td>
													<td width="20%" rowspan="2">Apellido</td>
													<td colspan="2">Parentesco</td>
													<td width="20%" rowspan="2">Cedula</td>
													<td width="5%" rowspan="2">Sexo</td>
													<td width="5%" rowspan="2" align="center">
													<%=fb.button("agregar","+",true,viewMode,null,null,"onClick=\"javascript:parienteExp()\"","Agregar Parientes")%>
													</td>
												</tr>
												<tr class="TextHeader" align="center">
													<td width="5%">Cod.</td>
													<td width="20%">Descripci&oacute;n.</td>
												</tr>
												<%  al=CmnMgr.reverseRecords(htpariente);
													for (int i=1; i<=htpariente.size(); i++)
													{
													key = al.get(i - 1).toString();
													CommonDataObject cdo = (CommonDataObject) htpariente.get(key);
													String color = "";
													if (i%2 == 0) color = "TextRow02";
													else color = "TextRow01";
												%>
												<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
												<%=fb.hidden("parentesco"+i,cdo.getColValue("parentesco"))%>
												<%=fb.hidden("parentescoName"+i,cdo.getColValue("parentescoName"))%>
												<%=fb.hidden("remove"+i,"")%>
												<tr class="<%=color%>" align="center">
													<td><%=fb.intBox("code"+i,cdo.getColValue("codigo"),false,false,true,1,2,"Text10",null,null)%></td>
													<td><%=fb.textBox("namepariente"+i,cdo.getColValue("nombre"),true,false,viewMode,30,30,"Text10",null,null)%></td>
													<td><%=fb.textBox("apellidopariente"+i,cdo.getColValue("apellido"),true,false,viewMode,30,30,"Text10",null,null)%></td>
													<td><%=cdo.getColValue("parentesco")%></td>
													<td><%=cdo.getColValue("parentescoName")%></td>
													<td>
													<%=fb.intBox("pa_provincia"+i,cdo.getColValue("provincia"),false,false,viewMode,1,2,"Text10",null,null)%>
													<%=fb.textBox("pa_sigla"+i,cdo.getColValue("sigla"),false,false,viewMode,1,2,"Text10",null,null)%>
													<%=fb.intBox("pa_tomo"+i,cdo.getColValue("tomo"),false,false,viewMode,2,5,"Text10",null,null)%>
													<%=fb.intBox("pa_asiento"+i,cdo.getColValue("asiento"),false,false,viewMode,3,6,"Text10",null,null)%>
													</td>
													<td><%=fb.select("sexo"+i,"M,F",cdo.getColValue("sexo"),false,viewMode,0,"Text10",null,null)%></td>
													<td rowspan="2"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Pariente")%>
													</td>
												</tr>
												<tr class="<%=color%>">
													<td colspan="3"> Beneficiario&nbsp; <%=fb.checkbox("beneficiario"+i,"S",(cdo.getColValue("beneficiario") != null && cdo.getColValue("beneficiario").trim().equalsIgnoreCase("S")),viewMode)%> &nbsp;&nbsp;
														Dependiente <%=fb.checkbox("dependiente"+i,"S",(cdo.getColValue("dependiente") != null && cdo.getColValue("dependiente").trim().equalsIgnoreCase("S")),viewMode)%>&nbsp;&nbsp;
														Vive con Emp.?&nbsp; <%=fb.checkbox("vive_con_empleado"+i,"S",(cdo.getColValue("vive_con_empleado") != null && cdo.getColValue("vive_con_empleado").trim().equalsIgnoreCase("S")),viewMode)%> <br>
														Invalido  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=fb.checkbox("invalido"+i,"S",(cdo.getColValue("invalido") != null && cdo.getColValue("invalido").trim().equalsIgnoreCase("S")),viewMode)%> &nbsp;&nbsp;
														Fecha Nac.
														&nbsp;&nbsp;&nbsp;&nbsp;
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="clearOption" value="true" />
														<jsp:param name="nameOfTBox1" value="<%="fecha_nacimiento"+i%>" />
														<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_nacimiento")%>" />
														</jsp:include>
														<br>
														Vive?  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=fb.checkbox("vive"+i,"S",(cdo.getColValue("vive") != null && cdo.getColValue("vive").trim().equalsIgnoreCase("S")),viewMode)%> &nbsp;&nbsp;
														Fecha Fallec.&nbsp;&nbsp;
                            <%
                            if(cdo.getColValue("fecha_fallecimiento").equals("")){
														%>
														<jsp:include page="../common/calendar.jsp" flush="true">
														<jsp:param name="noOfDateTBox" value="1" />
														<jsp:param name="clearOption" value="true" />
														<jsp:param name="nameOfTBox1" value="<%="fecha_fallecimiento"+i%>" />
														<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_fallecimiento")%>" />
														</jsp:include>
                            <%} else {%>
                            <%=fb.textBox("fecha_fallecimiento"+i,cdo.getColValue("fecha_fallecimiento"),false,false,true,12,12,"Text10",null,null)%>
                            <%}%>
													</td>
													<td colspan="4"> Estudia
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=fb.checkbox("estudia"+i,"S",(cdo.getColValue("estudia") != null && cdo.getColValue("estudia").trim().equalsIgnoreCase("S")),viewMode)%> &nbsp;&nbsp;
														Trabaja <%=fb.checkbox("trabaja"+i,"S",(cdo.getColValue("trabaja") != null && cdo.getColValue("trabaja").trim().equalsIgnoreCase("S")),viewMode)%>&nbsp;&nbsp;
														Protegido x Riesgo Prof.&nbsp; <%=fb.checkbox("proteg_por_riesgo"+i,"S",(cdo.getColValue("proteg_por_riesgo") != null && cdo.getColValue("proteg_por_riesgo").trim().equalsIgnoreCase("S")),viewMode)%> <br>
														Lugar de Trabajo <%=fb.textBox("lugar_trabajo"+i,cdo.getColValue("lugar_trabajo"),false,false,viewMode,50,100,"Text10",null,null)%> <br>
														Tel&eacute;fono
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=fb.textBox("telefono_trabajo"+i,cdo.getColValue("telefono_trabajo"),false,false,viewMode,15,11,"Text10",null,null)%></td>
												</tr>
												<%
							}
						%>
											</table></td>
									</tr>
									<tr class="TextRow02">
										<td align="right"> Opciones de Guardar:
										<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
										<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
										<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
										<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
										<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
										</td>
									</tr>
									<%=fb.formEnd(true)%>
								</table>
							</div>
                            
                            
                            <%-- ======================== TAB9 PARIENTES ======================  --%>
							<div class="dhtmlgoodies_aTab">
                               <iframe id="iidoneidad" name="iidoneidad" src="../rhplanilla/empleado_idoneidad.jsp?fp=<%=fp%>&fg=<%=fg%>&cedula=<%=emple.getColValue("cedula")%>&nombre=<%=emple.getColValue("nombre1")%>&apellido=<%=emple.getColValue("apellido1")%>&emp_id=<%=emp_id%>&parent_mode=<%=mode%>" style="width:100%;height:500px"></iframe> 
                            </div>
                            
                            <!-- =============================== HUELLA DIGITAL TAB 10 ============================================ -->
                            <% if (isFpEnabled) { %>
                            <!-- TAB10 DIV START HERE-->
                            <div class="dhtmlgoodies_aTab">
                                <iframe name="iFingerprint" id="iFingerprint" frameborder="0" align="center" width="100%" height="590" scrolling="no" src=""></iframe>
                            </div>
                            <!-- TAB10 DIV END HERE-->
                            <% } %>
                            <!-- =============================== END HUELLA DIGITAL TAB 10 ============================================ -->
                            
                            
                            
                            
                            
                            
                            
						</div>

                        
						<script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add")){%>
initTabs('dhtmlgoodies_tabView1',Array('Empleado'),0,'100%','');
<%} else if(fp.equalsIgnoreCase("rrhh")){
String tabLabel = "'Empleado','Educación','Cursos','Habilidades','Entretenimiento','Idioma','Enfermedades','Medidas Disciplinarias','Reconocimientos','Parientes','Idoneidad'";
if (isFpEnabled) tabLabel += ",'Huella Dactilar'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,<% if (isFpEnabled) { %>Array('11=if(window.frames["iFingerprint"])window.frames["iFingerprint"].doResetFrameHeight();')<% } else { %>[]<% } %>,[]);
<%} else {%>initTabs('dhtmlgoodies_tabView1',Array('Empleado'),<%=tab%>,'100%','');
<%}%>
</script>
					</td>
				</tr>
			</table></td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size=0;
	String itemRemoved = "";
	id = request.getParameter("id");
	mode = request.getParameter("mode");
	fg = request.getParameter("fg");
	fp = request.getParameter("fp");
	emp_id  = request.getParameter("emp_id");
	al.clear();
if(tab.equals("0")){ //Generales de Empleado
		Hashtable ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("fotosimages"),20);
		saveOption = (String) ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
		baction = (String) ht.get("baction");
		id = (String) ht.get("id");
		mode = (String) ht.get("mode");
		fg = (String) ht.get("fg");
		fp = (String) ht.get("fp");
		emp_id  = (String) ht.get("emp_id");
		emple = new CommonDataObject();
		emple.setTableName("tbl_pla_empleado");
		emple.addColValue("PRIMER_NOMBRE", (String) ht.get("nombre1"));
		emple.addColValue("SEGUNDO_NOMBRE",(String) ht.get("nombre2"));
		if((String) ht.get("apellido1")!= null) emple.addColValue("PRIMER_APELLIDO",(String) ht.get("apellido1"));
		if((String) ht.get("apellido2")!= null) emple.addColValue("SEGUNDO_APELLIDO",(String) ht.get("apellido2"));
		if((String) ht.get("casada")!= null) emple.addColValue("APELLIDO_CASADA",(String) ht.get("casada"));
		if((String) ht.get("usar")== null) emple.addColValue("USAR_APELLIDO_CASADA","N");
		else emple.addColValue("USAR_APELLIDO_CASADA",(String) ht.get("usar"));
		emple.addColValue("ESTADO_CIVIL",(String) ht.get("civil"));
		if((String) ht.get("fecha")!=null) emple.addColValue("FECHA_NACIMIENTO",(String) ht.get("fecha"));
		if((String) ht.get("seguro")!= null) emple.addColValue("NUM_SSOCIAL",(String) ht.get("seguro"));
		emple.addColValue("SEXO",(String) ht.get("sexo"));
		if((String) ht.get("nacionalidadCode")!=null) emple.addColValue("NACIONALIDAD",(String) ht.get("nacionalidadCode"));
		if ((String) ht.get("provinciaCode") != null)	emple.addColValue("PROVINCIA_NAC",(String) ht.get("provinciaCode"));
		if ((String) ht.get("paisCode") != null) emple.addColValue("PAIS_NAC",(String) ht.get("paisCode"));
		if ((String) ht.get("corregimientoCode") != null)	emple.addColValue("CORREGIMIENTO_NAC",(String) ht.get("corregimientoCode"));
		if ((String) ht.get("distritoCode") != null)	emple.addColValue("DISTRITO_NAC",(String) ht.get("distritoCode"));
		if ((String) ht.get("provinciaC") != null) emple.addColValue("PROVINCIA_DIR",(String) ht.get("provinciaC"));
		if ((String) ht.get("paisC") != null)	emple.addColValue("PAIS_DIR",(String) ht.get("paisC"));
		if ((String) ht.get("corregimientoC") != null) emple.addColValue("CORREGIMIENTO_DIR",(String) ht.get("corregimientoC"));
		if ((String) ht.get("distritoC") != null)	emple.addColValue("DISTRITO_DIR",(String) ht.get("distritoC"));
		if ((String) ht.get("comunidadC") != null) emple.addColValue("COMUNIDAD_DIR",(String) ht.get("comunidadC"));
		if((String) ht.get("calle")!=null) emple.addColValue("CALLE_DIR",(String) ht.get("calle"));
		if((String) ht.get("zona")!= null) emple.addColValue("ZONA_POSTAL",(String) ht.get("zona"));
		if((String) ht.get("apartado")!=null) emple.addColValue("APARTADO_POSTAL",(String) ht.get("apartado"));
		if((String) ht.get("casa")!=null) emple.addColValue("CASA__DIR",(String) ht.get("casa"));
		if((String) ht.get("telcasa") != null) emple.addColValue("TELEFONO_CASA",(String) ht.get("telcasa"));
		if((String) ht.get("telotros")!=null) emple.addColValue("TELEFONO_OTRO",(String) ht.get("telotros"));
		if((String) ht.get("tellugar")!= null) emple.addColValue("LUGAR_TELEFONO",(String) ht.get("tellugar"));
		if((String) ht.get("email")!= null) emple.addColValue("EMAIL",(String) ht.get("email"));
		emple.addColValue("FECHA_MODIFICACION",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		emple.addColValue("USUARIO_MODIFICACION",(String) session.getAttribute("_userName"));
		if((String) ht.get("tipos")!=null) emple.addColValue("TIPO_EMPLE",(String) ht.get("tipos"));
		if((String) ht.get("ubic_depto")!=null) emple.addColValue("UBIC_DEPTO",(String) ht.get("ubic_depto"));
		if((String) ht.get("ubic_seccion")!=null) emple.addColValue("ubic_seccion",(String) ht.get("ubic_seccion"));
		if((String) ht.get("seccion")!=null) emple.addColValue("seccion",(String) ht.get("seccion"));
		if((String) ht.get("unidad_organi")!=null) emple.addColValue("UNIDAD_ORGANI",(String) ht.get("unidad_organi"));
		if((String) ht.get("cargo")!=null) emple.addColValue("CARGO",(String) ht.get("cargo"));
		if((String) ht.get("jefe")!=null) emple.addColValue("CARGO_JEFE",(String) ht.get("jefe"));
		if((String) ht.get("foto")!=null)	emple.addColValue("foto",(String) ht.get("foto"));
		if((String) ht.get("estado")!=null) emple.addColValue("ESTADO",(String) ht.get("estado"));
		if((String) ht.get("forma")!=null) emple.addColValue("FORMA_PAGO",(String) ht.get("forma"));
		if((String) ht.get("planilla")!=null) emple.addColValue("TIPO_PLA",(String) ht.get("planilla"));
		if((String) ht.get("horario")!=null) emple.addColValue("HORARIO",(String) ht.get("horario"));
		if((String) ht.get("clave")!=null) emple.addColValue("TIPO_RENTA",(String) ht.get("clave"));
		if((String) ht.get("dependiente")!=null) emple.addColValue("NUM_DEPENDIENTE",(String) ht.get("dependiente"));
		if ((String) ht.get("digito") != null) emple.addColValue("DIGITO_VERIFICADOR",(String) ht.get("digito"));
		if((String) ht.get("cta")!=null) emple.addColValue("NUM_CUENTA",(String) ht.get("cta"));
		emple.addColValue("TIPO_CUENTA",(String) ht.get("ahorro"));
		if((String) ht.get("ruta")!=null) emple.addColValue("RUTA_BANCARIA",(String) ht.get("ruta"));
		if((String) ht.get("salario")!=null) emple.addColValue("SALARIO_BASE",(String) ht.get("salario"));
		if((String) ht.get("gastos")!=null) emple.addColValue("GASTO_REP",(String) ht.get("gastos"));
		if((String) ht.get("rata")!=null) emple.addColValue("RATA_HORA",(String) ht.get("rata"));
		if((String) ht.get("remplazado")!=null) emple.addColValue("NUM_EMP_REMPLAZA",(String) ht.get("remplazado"));
		if ((String) ht.get("calculo") == null) emple.addColValue("CALCULO_RENTA_ESP","N");
		else  emple.addColValue("CALCULO_RENTA_ESP",(String) ht.get("calculo"));
		if((String) ht.get("contrato")!= null) emple.addColValue("FECHA_CONTRATO",(String) ht.get("contrato"));
		if((String) ht.get("numero")!=null) emple.addColValue("NUM_CONTRATO",(String) ht.get("numero"));
		if ((String) ht.get("renta") == null) emple.addColValue("RENTA_FIJA","N");
		else emple.addColValue("RENTA_FIJA",(String) ht.get("renta"));
		if((String) ht.get("valorenta")!=null) emple.addColValue("VALOR_RENTA",(String) ht.get("valorenta"));
		if ((String) ht.get("recibe") == null) emple.addColValue("REC_ALTO_RIESGO","N");
		else  emple.addColValue("REC_ALTO_RIESGO",(String) ht.get("recibe"));
		if((String) ht.get("horas")!=null) emple.addColValue("HORAS_BASE",(String) ht.get("horas"));
		if((String) ht.get("otros")!=null) emple.addColValue("OTROS_ING_FIJOS",(String) ht.get("otros"));
		if((String) ht.get("acumulado")!=null) emple.addColValue("ACUM_DECIMO",(String) ht.get("acumulado"));
		if((String) ht.get("gastoAcum")!=null) emple.addColValue("ACUM_DECIMO_GR", (String) ht.get("gastoAcum"));
		if((String) ht.get("ingreso")!=null) emple.addColValue("FECHA_INGRESO",(String) ht.get("ingreso"));
		if((String) ht.get("egreso")!=null) emple.addColValue("FECHA_EGRESO",(String) ht.get("egreso"));
		if((String) ht.get("puestoA")!=null) emple.addColValue("FECHA_PUESTOACT",(String) ht.get("puestoA"));
		if((String) ht.get("aumento")!=null) emple.addColValue("FECHA_ULT_AUMENTO",(String) ht.get("aumento"));
		if((String) ht.get("incapacidad")!=null) emple.addColValue("FECHA_INICIO_INCAPACIDAD",(String) ht.get("incapacidad"));
		if((String) ht.get("diasIncap")!=null) emple.addColValue("DIAS_INCAPACIDAD",(String) ht.get("diasIncap"));
		if((String) ht.get("ubicacion")!=null) emple.addColValue("UBIC_FISICA",(String) ht.get("ubicacion"));
		if ((String) ht.get("sindicatos") == null) emple.addColValue("SINDICATO","N");
		else emple.addColValue("SINDICATO",(String) ht.get("sindicatos"));
		if ((String) ht.get("fuero") == null) emple.addColValue("FUERO","N");
		else emple.addColValue("FUERO",(String) ht.get("fuero"));
		if((String) ht.get("spertenece")!=null) emple.addColValue("SIND_NOMBRE",(String) ht.get("spertenece"));
		if ((String) ht.get("conducir") == null) emple.addColValue("LICENCIA_CONDUCIR","N");
		else emple.addColValue("LICENCIA_CONDUCIR",(String) ht.get("conducir"));
		if((String) ht.get("licencia")!=null) emple.addColValue("TIPO_LICENCIA",(String) ht.get("licencia"));
		if((String) ht.get("nlicencia")!=null) emple.addColValue("NUMERO_LICENCIA",(String) ht.get("nlicencia"));
		if((String) ht.get("firma")!=null) emple.addColValue("firma",(String) ht.get("firma"));
		if((String) ht.get("sang")!=null) emple.addColValue("TIPO_SANGRE",(String) ht.get("sang"));
		if((String) ht.get("hijos")!=null) emple.addColValue("NUM_HIJOS",(String) ht.get("hijos"));
		if ((String) ht.get("sangre") != null) emple.addColValue("RH",(String) ht.get("sangre"));
		if((String) ht.get("madre")!=null) emple.addColValue("NOMBRE_MADRE",(String) ht.get("madre"));
		if((String) ht.get("padre")!=null) emple.addColValue("NOMBRE_PADRE",(String) ht.get("padre"));
		if ((String) ht.get("vivemadre") == null) emple.addColValue("VIVE_MADRE","N");
		else emple.addColValue("VIVE_MADRE",(String) ht.get("vivemadre"));
		if ((String) ht.get("vivepadre") == null) emple.addColValue("VIVE_PADRE","N");
		else emple.addColValue("VIVE_PADRE",(String) ht.get("vivepadre"));
		if((String) ht.get("llamar")!=null) emple.addColValue("EMERGENCIA_LLAMAR",(String) ht.get("llamar"));
		if((String) ht.get("telefonos")!=null) emple.addColValue("TELEFONO_EMERGENCIA",(String) ht.get("telefonos"));
		if((String) ht.get("comentario")!=null) emple.addColValue("COMENTARIO",(String) ht.get("comentario"));
		if((String) ht.get("sin_huella")!=null) emple.addColValue("sin_huella",(String) ht.get("sin_huella"));
		emple.addColValue("compania",compania);
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		
		if (mode.equalsIgnoreCase("add")){
			emple.addColValue("COMPANIA_UNIORG",compania);
			emple.addColValue("provincia",(String) ht.get("provincia"));
			emple.addColValue("NUM_EMPLEADO",(String) ht.get("numEmpleado"));
			emple.addColValue("sigla",(String) ht.get("sigla"));
			emple.addColValue("tomo",(String) ht.get("tomo"));
			emple.addColValue("asiento",(String) ht.get("asiento"));
			emple.addColValue("pasaporte",(String) ht.get("pasaporte"));
			emple.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			emple.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			emple.addColValue("emp_id","(SELECT nvl(max(emp_id),0)+1 FROM tbl_pla_empleado)");
			emple.addPkColValue("emp_id","");
			SQLMgr.insert(emple);
			emp_id = SQLMgr.getPkColValue("emp_id");
		} else {
			emple.setWhereClause("compania="+compania+"  and emp_id="+emp_id);
			SQLMgr.update(emple);
		}
		ConMgr.clearAppCtx(null);
	}//End Tab de Generales de Empleado
//  ==============================   TAB1 EDUCACION 	===============================
	else if(tab.equals("1")){
		if(request.getParameter("educacionSize")!=null)
		size= Integer.parseInt(request.getParameter("educacionSize"));
		for(int i=1; i<=size; i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_educacion");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id); 
			cdo.addColValue("emp_id",emp_id);
			cdo.addColValue("codigo",request.getParameter("code"+i));
			cdo.addColValue("educacioName",request.getParameter("educacioName"+i));
			cdo.addColValue("lugar",request.getParameter("lugar"+i));
			cdo.addColValue("fecha_inicio",request.getParameter("fecha_inicio"+i));
			cdo.addColValue("fecha_final",request.getParameter("fecha_final"+i));
			cdo.addColValue("carrera",request.getParameter("carrera"+i));
			cdo.addColValue("certificado_obt",request.getParameter("titulo"+i));
			cdo.addColValue("compania",compania);
			cdo.addColValue("termino",(request.getParameter("termino"+i)== null)?"N":"S");
			cdo.addColValue("nivel",request.getParameter("nivel"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("tipo",request.getParameter("tipo"+i));
			cdo.setAutoIncWhereClause("compania="+compania+" and emp_id="+request.getParameter("emp_id"));
			cdo.setAutoIncCol("codigo");
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else {
				try	{
					hteducacion.put(cdo.getColValue("key"),cdo);
					al.add(cdo);
				} catch (Exception e) {
					System.err.println(e.getMessage());
				}//end Catch
			}//End else
		}//End For
		if (!itemRemoved.equals("")){
			vcteducacion.remove(((CommonDataObject) hteducacion.get(itemRemoved)).getColValue("tipo"));
			hteducacion.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}//End remover
		if (al.size() == 0){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_educacion");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id);
			al.add(cdo);
		}//end al.size
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}//End Tab1 de Educación

//===========================  TAB2  CURSO  ============================
	else if(tab.equals("2")){
		if(request.getParameter("cursofSize")!=null)
		size=Integer.parseInt(request.getParameter("cursofSize"));
		for(int i=1; i<=size; i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_cursos_fuera");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id); 
			cdo.addColValue("emp_id",emp_id);
			cdo.addColValue("codigo",request.getParameter("code"+i));
			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("institucion",request.getParameter("institucion"+i));
			cdo.addColValue("fecha_inicio",request.getParameter("fecha_inicio1"+i));
			cdo.addColValue("fecha_final",request.getParameter("fecha_final1"+i));
			cdo.addColValue("duracion",request.getParameter("duracion"+i));
			cdo.addColValue("tipo",request.getParameter("tipo"+i));
			cdo.addColValue("nameCurso",request.getParameter("nameCurso"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("compania",compania);
			cdo.setAutoIncWhereClause("compania="+compania+" and emp_id="+request.getParameter("emp_id"));
			cdo.setAutoIncCol("codigo");
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else {
				try	{
					htcursof.put(cdo.getColValue("key"),cdo);
					al.add(cdo);
				} catch(Exception e){
					System.err.println(e.getMessage());
				}
			}
		}//Enf for
		if (!itemRemoved.equals("")){
			vctcursof.remove(((CommonDataObject) htcursof.get(itemRemoved)).getColValue("tipo"));
			htcursof.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (baction != null && baction.equals("+")){
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (al.size() == 0){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_cursos_fuera");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id);
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}//End Tab2 Cursos
//  ================================  TAB3 HABILIDADES  =============================
	else if(tab.equals("3")){
		if(request.getParameter("habilidadSize")!=null)
		size=Integer.parseInt(request.getParameter("habilidadSize"));
		for(int i=1; i<=size; i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_habilidad_empl");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id); 
			cdo.addColValue("emp_id",emp_id);
			cdo.addColValue("compania",compania);
			cdo.addColValue("habilidad",request.getParameter("habilidad"+i));
			cdo.addColValue("habilidadName",request.getParameter("habilidadName"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else {
				try {
					hthabilidad.put(cdo.getColValue("key"),cdo);
					al.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}//End for
		if (!itemRemoved.equals("")){
			vcthabilidad.remove(((CommonDataObject) hthabilidad.get(itemRemoved)).getColValue("habilidad"));
			hthabilidad.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (baction != null && baction.equals("+")){
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (al.size() == 0){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_habilidad_empl");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id);
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}//End Tab Habilidades
//  ==============================  TAB4 ENTRETENIMIENTO  ==========================
	else if(tab.equals("4")){
		if(request.getParameter("entrevistaSize") != null) size = Integer.parseInt(request.getParameter("entrevistaSize"));
		for (int i=1; i<=size; i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_entretenimiento_empl");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id);
			cdo.addColValue("emp_id",emp_id);
			cdo.addColValue("compania",compania);
			cdo.addColValue("entretenimiento",request.getParameter("entretenimiento"+i));
			cdo.addColValue("entretenimientoName",request.getParameter("entretenimientoName"+i));
			cdo.addColValue("tipo", request.getParameter("tip"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else {
				try{
					htentrevista.put(cdo.getColValue("key"),cdo);
					al.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}//End for
		if (!itemRemoved.equals("")){
			vctentrete.remove(((CommonDataObject) htentrevista.get(itemRemoved)).getColValue("entretenimiento"));
			htentrevista.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (baction != null && baction.equals("+")){
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (al.size() == 0){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_entretenimiento_empl");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id);
			al.add(cdo);
		}
		SQLMgr.insertList(al);
	}//End Tab4 Entretenimiento
//  ==============================  TAB5 IDIOMA  =============================
	else if(tab.equals("5")){
		if(request.getParameter("idiomaSize")!=null) size=Integer.parseInt(request.getParameter("idiomaSize"));
		for(int i=1; i<=size; i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_idioma_empl");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id); 
			cdo.addColValue("emp_id",emp_id);
			cdo.addColValue("compania",compania);
			cdo.addColValue("idioma", request.getParameter("idioma"+i));
			cdo.addColValue("nameidioma",request.getParameter("nameidioma"+i));
			cdo.addColValue("nivel_conversacional", request.getParameter("nivel_conversacional"+i));
			cdo.addColValue("nivel_lectura", request.getParameter("nivel_lectura"+i));
			cdo.addColValue("nivel_escritura", request.getParameter("nivel_escritura"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else {
				try{
					htidioma.put(cdo.getColValue("key"),cdo);
					al.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}//End For
		if (!itemRemoved.equals("")){
			vctidioma.remove(((CommonDataObject) htidioma.get(itemRemoved)).getColValue("idioma"));
			htidioma.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (baction != null && baction.equals("+")){
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (al.size() == 0){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_idioma_empl");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id);
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}//End tab 5
//  ==============================  TAB6 ENFERMEDAD  ===============================
	else if(tab.equals("6")){
		if(request.getParameter("enfermedadSize")!=null) size=Integer.parseInt(request.getParameter("enfermedadSize"));
		for(int i=1; i<=size; i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_enfermedad_empl");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id); 
			cdo.addColValue("emp_id",emp_id);
			cdo.addColValue("compania",compania);
			cdo.addColValue("enfermedad", request.getParameter("enfermedad"+i));
			cdo.addColValue("enfermedadName",request.getParameter("enfermedadName"+i));
			cdo.addColValue("alto_riesgo",(request.getParameter("alto_riesgo"+i)== null)?"N":"S");
			cdo.addColValue("key",request.getParameter("key"+i));
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else {
				try	{
					htenfermedad.put(cdo.getColValue("key"),cdo);
					al.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}//End For
		if (!itemRemoved.equals("")){
		vctenfermed.remove(((CommonDataObject) htenfermedad.get(itemRemoved)).getColValue("enfermedad"));
			htenfermedad.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=6&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (baction != null && baction.equals("+")){
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=6&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (al.size() == 0){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_enfermedad_empl");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id);
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}//End tab 6 enfermedad
	//  =======================  TAB7 MEDIDAS DISCIPLINARIAS  ==============================
	else if(tab.equals("7")){
		if(request.getParameter("medidadSize")!=null)	size=Integer.parseInt(request.getParameter("medidadSize"));
		for(int i=1; i<=size; i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("TBL_PLA_MEDIDAS_DISCIPLINARIAS");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id);
			cdo.addColValue("compania",compania); 
			cdo.addColValue("emp_id",emp_id);
			cdo.addColValue("TIPO_MED",request.getParameter("tipo_med"+i));
			cdo.addColValue("medidaName",request.getParameter("medidaName"+i));
			cdo.addColValue("codigo",request.getParameter("code"+i));
			cdo.addColValue("FECHA",request.getParameter("fechamed"+i));
			cdo.addColValue("fechamed",request.getParameter("fechamed"+i));
			cdo.addColValue("motivo",request.getParameter("motivo"+i));
			cdo.addColValue("DESCRIPCION",request.getParameter("descripcion"+i));
			cdo.addColValue("AUTORIZAPO_POR",request.getParameter("autorizado"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.setAutoIncWhereClause("compania="+compania+" and emp_id="+request.getParameter("emp_id"));
			cdo.setAutoIncCol("codigo");
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else {
				try {
					htmedida.put(cdo.getColValue("key"),cdo);
					al.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}//End For
		if (!itemRemoved.equals("")){
			vctmedidas.remove(((CommonDataObject) htmedida.get(itemRemoved)).getColValue("tipo_med"));
			htmedida.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=7&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}

		if (baction != null && baction.equals("+")){
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=7&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}

		if (al.size() == 0){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("TBL_PLA_MEDIDAS_DISCIPLINARIAS");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id);
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}//End Tab7 Medidas
 // ==============================  TAB8 RECONOCIMIENTOS  ==============================
	else if(tab.equals("8")){
		ArrayList list = new ArrayList();
		int reconSize = Integer.parseInt(request.getParameter("reconSize"));
		for (int i=0; i<reconSize; i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("TBL_PLA_RECONOCIMIENTO");
			cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id); 
			cdo.addColValue("emp_id",emp_id);
			cdo.addColValue("compania",compania);
			cdo.addColValue("codigo",request.getParameter("code"+i));
			cdo.addColValue("fecha",request.getParameter("fecha"+i));
			cdo.addColValue("motivo",request.getParameter("motivo"+i));
			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("comentario",request.getParameter("comentario"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.setAutoIncWhereClause("compania="+compania+" and emp_id="+request.getParameter("emp_id"));
			cdo.setAutoIncCol("codigo");
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else {
				try{
					htreconocit.put(cdo.getColValue("key"),cdo);
					list.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}//End For
		if(!itemRemoved.equals("")){
			htreconocit.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=8&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if(baction.equals("+")){	 //Agregar
			CommonDataObject cdo = new CommonDataObject(); 
			cdo.addColValue("codigo","0");
			cdo.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
			reconocimientoLastLineNo++;
			if(reconocimientoLastLineNo < 10) key = "00" + reconocimientoLastLineNo;
			else if(reconocimientoLastLineNo <100) key = "0" +reconocimientoLastLineNo;
			else key = "" + reconocimientoLastLineNo;
			cdo.addColValue("key",key);
			htreconocit.put(key,cdo);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=8&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}//End
		if (baction.equalsIgnoreCase("Guardar")){
			if(al.size() == 0){
				CommonDataObject cdo = new CommonDataObject();
				cdo.setTableName("TBL_PLA_RECONOCIMIENTO");
				cdo.setWhereClause("compania="+compania+" and emp_id="+emp_id);
				list.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.insertList(list);
			ConMgr.clearAppCtx(null);
		}
	}//End tab8
// ===================================  TAB9 PARIENTES  ================================
	else if(tab.equals("9")){
		if(request.getParameter("parienteSize")!=null) size=Integer.parseInt(request.getParameter("parienteSize"));
		for(int i=1; i<=size; i++){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("TBL_PLA_PARIENTE");
			cdo.setWhereClause("cod_compania="+compania+" and emp_id="+emp_id); 
			cdo.addColValue("emp_id",emp_id);
			cdo.addColValue("codigo",request.getParameter("code"+i));
			cdo.addColValue("nombre",request.getParameter("namepariente"+i));
			cdo.addColValue("namepariente",request.getParameter("namepariente"+i));
			cdo.addColValue("apellido",request.getParameter("apellidopariente"+i));
			cdo.addColValue("sexo",request.getParameter("sexo"+i));
			cdo.addColValue("parentesco",request.getParameter("parentesco"+i));
			cdo.addColValue("parentescoName",request.getParameter("parentescoName"+i));
			cdo.addColValue("dependiente",(request.getParameter("dependiente"+i)== null)?"N":"S");
			cdo.addColValue("fecha_nacimiento",request.getParameter("fecha_nacimiento"+i));
			cdo.addColValue("vive_con_empleado",(request.getParameter("vive_con_empleado"+i)==null)?"N":"S");
			cdo.addColValue("invalido",(request.getParameter("invalido"+i)==null)?"N":"S");
			cdo.addColValue("proteg_por_riesgo",(request.getParameter("proteg_por_riesgo"+i)==null)?"N":"S");
			cdo.addColValue("trabaja",(request.getParameter("trabaja"+i)==null)?"N":"S");
			cdo.addColValue("lugar_trabajo",request.getParameter("lugar_trabajo"+i));
			cdo.addColValue("telefono_trabajo",request.getParameter("telefono_trabajo"+i));
			cdo.addColValue("estudia",(request.getParameter("estudia"+i)==null)?"N":"S");
			cdo.addColValue("provincia",request.getParameter("pa_provincia"+i));
			cdo.addColValue("sigla",request.getParameter("pa_sigla"+i));
			cdo.addColValue("tomo",request.getParameter("pa_tomo"+i));
			cdo.addColValue("asiento",request.getParameter("pa_asiento"+i));
			cdo.addColValue("vive",(request.getParameter("vive"+i)==null)?"N":"S");
			cdo.addColValue("fecha_fallecimiento",request.getParameter("fecha_fallecimiento"+i));
			cdo.addColValue("beneficiario",(request.getParameter("beneficiario"+i)==null)?"N":"S");
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.addColValue("cod_compania",compania);
			cdo.setAutoIncWhereClause("cod_compania="+compania+" and emp_id="+emp_id);
			cdo.setAutoIncCol("codigo");
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) itemRemoved = cdo.getColValue("key");
			else {
				try{
					htpariente.put(cdo.getColValue("key"),cdo);
					al.add(cdo);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}//Enf for
		if (!itemRemoved.equals("")){
			//vctpariente.remove(((CommonDataObject) htpariente.get(itemRemoved)).getColValue("parentesco"));
			htpariente.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=9&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (baction != null && baction.equals("+")){
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=9&mode="+mode+"&emp_id="+emp_id+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo+"&fg="+fg+"&fp="+fp);
			return;
		}
		if (al.size() == 0){
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_pariente");
			cdo.setWhereClause("cod_compania="+compania+" and emp_id="+emp_id);
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}//End Tab9 Parientes
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if (SQLMgr.getErrCode().equals("1")){
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (tab.equals("0") && fp.equals("rrhh") && (!fg.equals("reIngreso"))){
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empleado_list.jsp")){
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empleado_list.jsp")%>';
<%  } else {
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empleado_list.jsp?fp=<%=fp%>&fg=<%=fg%>';
<%	}
	} else if (tab.equals("0") && fp.equals("planilla")){
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empleado_list.jsp")){
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empleado_list.jsp")%>';
<%  }else if( fp.equals("rrhh") && fg.equals("reIngreso")){%>

<%}else {%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empleado_list.jsp?fp=<%=fp%>&fg=<%=fg%>';
<%	}
}		
	if (saveOption.equalsIgnoreCase("N")){
%>
	setTimeout('addMode()',500);
<%
	} else if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('editMode()',500);
<%
	} else if (saveOption.equalsIgnoreCase("C")) {
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&fg=<%=fg%>';
}
function editMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&emp_id=<%=emp_id%>&fg=<%=fg%>&fp=<%=fp%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>