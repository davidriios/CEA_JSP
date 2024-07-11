<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr"       scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr"       scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet"      scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr"       scope="page"    class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr"       scope="page"    class="issi.admin.SQLMgr" />
<jsp:useBean id="fb"           scope="page"    class="issi.admin.FormBean" />
<jsp:useBean id="hteducacion"  scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htcursof"     scope="session" class="java.util.Hashtable" />
<jsp:useBean id="hthabilidad"  scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htentrevista" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htidioma"     scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htenfermedad" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htmedida"     scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htreconocit"  scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htpariente"   scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vcteducacion" scope="session" class="java.util.Vector" />
<jsp:useBean id="vctcursof"    scope="session" class="java.util.Vector"/>
<jsp:useBean id="vcthabilidad" scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctentrete"   scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctidioma"    scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctenfermed"  scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctmedidas"   scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctreconoc"   scope="session" class="java.util.Vector"/>
<jsp:useBean id="vctpariente"  scope="session" class="java.util.Vector"/>
<%
/**
================================================================================
800059	AGREGAR SOLICITUD 
800060	MODIFICAR SOLICITUD 
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject emple = new CommonDataObject();
ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String prov = request.getParameter("prov");
String sig = request.getParameter("sig");
String tom = request.getParameter("tom");
String asi = request.getParameter("asi");
String tab = request.getParameter("tab");
String id = request.getParameter("id");
String anio = request.getParameter("anio");
String cons = request.getParameter("cons");
String key = "";
String change = request.getParameter("change");
String code =request.getParameter("code");
String codigo =request.getParameter("codigo");

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

if(request.getParameter("educaLastLineNo") != null)
educaLastLineNo = Integer.parseInt(request.getParameter("educaLastLineNo"));

if(request.getParameter("cursoLastLineNo") != null)
cursoLastLineNo = Integer.parseInt(request.getParameter("cursoLastLineNo"));

if(request.getParameter("habilidadLastLineNo") != null)
habilidadLastLineNo = Integer.parseInt(request.getParameter("habilidadLastLineNo"));

if(request.getParameter("entrenimientoLastLineNo") != null)
entrenimientoLastLineNo = Integer.parseInt(request.getParameter("entrenimientoLastLineNo"));

if(request.getParameter("idiomaLastLineNo")!= null)
idiomaLastLineNo = Integer.parseInt(request.getParameter("idiomaLastLineNo"));

if(request.getParameter("enfermedadLastLineNo") != null)
enfermedadLastLineNo = Integer.parseInt(request.getParameter("enfermedadLastLineNo"));

if(request.getParameter("medidadLastLineNo") != null)
medidadLastLineNo = Integer.parseInt(request.getParameter("medidadLastLineNo"));

if(request.getParameter("reconocimientoLastLineNo") != null)
reconocimientoLastLineNo = Integer.parseInt(request.getParameter("reconocimientoLastLineNo"));

if(request.getParameter("parienteLastLineNo") != null)
parienteLastLineNo = Integer.parseInt(request.getParameter("parienteLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id="0";
		prov = "0";
		sig = "00";
		tom = "0";
		asi = "0";
		emple.addColValue("id","0");
		emple.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		emple.addColValue("anio",CmnMgr.getCurrentDate("yyyy"));
		emple.addColValue("ingreso",CmnMgr.getCurrentDate("dd/mm/yyyy"));
		emple.addColValue("nacconyuge","");
		emple.addColValue("nacpadre","");
		emple.addColValue("nacmadre","");
		emple.addColValue("fechanac","");
		emple.addColValue("fechasol","");
		emple.addColValue("sigla","00");
		emple.addColValue("provincia","");
		emple.addColValue("tomo","");
		emple.addColValue("asiento","");
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
			
	}
	else
	{
	if (prov == null) throw new Exception("La Provincia no es válido. Por favor intente nuevamente!");
	if (sig == null) throw new Exception("La Sigla no es válido. Por favor intente nuevamente!");
	if (tom == null) throw new Exception("El Tomo no es válido. Por favor intente nuevamente!");
	if (asi == null) throw new Exception("El Asiento no es válido. Por favor intente nuevamente!");
	
	code="0";
	sql="Select DISTINCT a.consecutivo,a.anio,a.provincia|| '-' ||a.sigla|| '-' ||a.tomo|| '-' ||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.primer_nombre as nombre1, nvl(a.segundo_nombre,' ')  as nombre2, a.primer_apellido as apellido1, nvl(a.segundo_apellido,' ') as apellido2, nvl(a.apellido_casada, ' ') as casada, to_char(fecha_nacimiento,'dd/mm/yyyy') as fechanac, a.empleo_solicita1 as cargo1, a.empleo_solicita2 as cargo2, a.empleo_solicita3 as cargo3, a. salario_deseado as salario, a.lugar_prefiere as lugarpref, to_char(a.fecha_solicitud,'dd/mm/yyyy') as fechasol, a.nacionalidad as nacionalidadCode, a.lugar_nacimiento, a.dependientes as dependiente, a.sexo, a.estado_civil as civil, a.direccion, a.telefono as telcasa, a.telefono_oficina as telotros, a.telefono_celular as tellugar, a.seguro_social as seguro, a.peso, a.estatura, a.tipo_sangre as sang, a.apartado, a.zona, a.email, a.nombre_conyuge conyuge, to_char(a.fnac_conyuge,'dd/mm/yyyy') as nacconyuge, a.lugar_trabconyuge as traconyuge, a.profesion_conyuge as ocuconyuge, a.familiar_cia, a.nombre_fam, a.parentezco_fam, a.ocupacion_fam, a.vive_padre as vivepadre, a.nombre_padre as padre, to_char(a.fnac_padre,'dd/mm/yyyy') as nacpadre , a.ocupacion_padre as ocupadre, a.lugar_trabajo_padre as trapadre, a.vive_madre as vivemadre, a.nombre_madre as madre, to_char(a.fnac_madre,'dd/mm/yyyy') as nacmadre, a.ocupacion_madre as ocumadre, a.lugar_trabajo_madre as tramadre, a.maquinas, a.observaciones, decode(a.foto,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("fotosimages").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||a.foto) as foto, a.licencia_conducir as conducir, a.tipo_licencia as licencia, a.numero_licencia as nlicencia, a.rh as sangre, a.urgencia_llamar_a as urgllamar, a.urgencia_parentesco as urgCode, a.urgencia_telefono as telurg, a.urgencia_celular as celurg, a.comunidad_dir as comunidadCode, a.corregimiento_dir as corregimientoCode, a.distrito_dir as distritoCode, a.provincia_dir as provinciaCode, a.pais_dir as paisCode, a.inactivo_sino, a.inactivo_duracion, a.inactivo_actividad, a.caso_legal_pendiente, a.caso_legal_explique, a.otros_trabajos, a.datos_adicionales, a.estado_solicitante, a.depto_fam, a.evaluado_por, b.nacionalidad as nacionalidad, c.descripcion as urgParentesco, nvl(d.denominacion,' ') as nameCargo1, d.codigo as cargo11, nvl(e.denominacion,' ') as nameCargo2, e.codigo as cargo22, nvl(f.denominacion,' ') as nameCargo3, f.codigo as cargo33 from tbl_pla_solicitante a, tbl_sec_pais b, tbl_pla_parentesco c, (select codigo,denominacion,compania from tbl_pla_cargo ) d, (select codigo,denominacion,compania from tbl_pla_cargo ) e,(select codigo,denominacion,compania from tbl_pla_cargo ) f where  a.compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi+" and a.nacionalidad = b.codigo and a.empleo_solicita1 = d.codigo(+) and a.compania = d.compania(+)  and a.empleo_solicita2 = e.codigo(+) and a.compania = e.compania(+)  and a.empleo_solicita3 = f.codigo(+) and a.compania = f.compania(+) and a.urgencia_parentesco = c.codigo(+)   ";

		emple = SQLMgr.getData(sql);
		
			
		if(change == null)
		{



//============================================  QUERY DE EDUCACION ============================================
	
		sql=" select a.sol_anio as anio, a.sol_consecutivo as consecutivo, b.compania, b.provincia, b.sigla, b.tomo, b.asiento, a.codigo, a.centro_educativo, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, to_char(a.fecha_final,'dd/mm/yyyy') as fecha_final, a.carrera, a.certificado_obt , a.termino, a.anio_cursado , a.tipo_educacion as tipo, b.primer_nombre, b.primer_apellido, c.codigo as cot, c.descripcion as educacioName from tbl_pla_educacion_soli a, tbl_pla_solicitante b, tbl_pla_tipo_educacion c where a.sol_anio=b.anio and a.sol_consecutivo=b.consecutivo and a.tipo_educacion=c.codigo  and b.compania= "+(String) session.getAttribute("_companyId")+" and b.provincia="+prov+" and b.sigla='"+sig+"' and b.tomo="+tom+" and b.asiento="+asi;
		
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
		for(int i=1; i<=al.size(); i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i-1);
		
		if(i<10)  key = "00"+i;
		else if(i<100)
		key = "0"+i;
		else  
		key= ""+i;
		cdo.addColValue("key",key);
		try
		{
		hteducacion.put(key,cdo);
		vcteducacion.addElement(cdo.getColValue("tipo"));
		}//End Try
		catch (Exception e)
		{
		System.err.println(e.getMessage());
		}//End Catch
		}//End for
/*		
//======================  QUERY DE CURSO  =============================
		sql="select a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, a.descripcion, a.lugar, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, to_char(a.fecha_final,'dd/mm/yyyy') as fecha_final, a.duracion, b.codigo as ot, b.descripcion as nameCurso, c.primer_nombre, c.primer_apellido from tbl_pla_cursos_soli a, tbl_pla_tipo_actividad b, tbl_pla_solicitante c where a.tipo=b.codigo(+) and a.provincia = c.provincia and a.sigla = c.sigla(+) and  a.tomo = c.tomo and a.asiento = c.asiento and a.cod_compania= c.compania(+) and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi;
		
		al=SQLMgr.getDataList(sql);
		
		cursoLastLineNo= al.size();
		for(int i=1; i<=al.size(); i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i-1);
		if(i<10) key="00"+i;
		else if(i<100)
		key = "0" +i;
		else key=""+i;
		cdo.addColValue("key",key);
		try
			{
				htcursof.put(key,cdo);
				vctcursof.addElement(cdo.getColValue("tipo"));
			}//End try
			catch (Exception e)
			{
			System.err.println(e.getMessage());
			}//End Catch
		}//End For

//============================================ QUERY DE HABILIDADES =========================================
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.habilidad, a.calificacion, b.descripcion  as habilidadName, c.primer_apellido, c.primer_nombre  from tbl_pla_habilidad_empl a, tbl_pla_habilidad b, tbl_pla_empleado c where a.habilidad=b.codigo(+) and a.provincia=c.provincia and a.sigla= c.sigla and a.tomo= c.tomo and a.asiento= c.asiento and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi;
		al=SQLMgr.getDataList(sql);
		
		habilidadLastLineNo= al.size();
		for(int i=1; i<=al.size();i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i-1);
		if(i<10) 		key="00"+i;
		else if(i<100)  key = "0" +i;
		else key=""+i;
		cdo.addColValue("key",key);
		try
			{
				hthabilidad.put(key,cdo);
				vcthabilidad.addElement(cdo.getColValue("habilidad"));
			}//End try
			catch (Exception e)
			{
			System.err.println(e.getMessage());
			}//End Catch
		}//End For
		
//============================================  QUERY DE ENTRETENIMINETO  ============================================		
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.entretenimiento, a.tipo, b.descripcion as entretenimientoName, c.primer_apellido, c.primer_nombre from tbl_pla_entretenimiento_empl a, tbl_pla_entretenimiento b, tbl_pla_empleado c where a.entretenimiento=b.codigo(+) and a.provincia = c.provincia and a.sigla = c.sigla and a.tomo = c.tomo and a.asiento = c.asiento and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi;
		al=SQLMgr.getDataList(sql);
		
		entrenimientoLastLineNo= al.size();
		for(int i=1; i<=al.size();i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i-1);
		if(i<10) key="00"+i;
		else if(i<100)  
		key = "0" +i;
		else key=""+i;
		cdo.addColValue("key",key);
		try
			{
				htentrevista.put(key,cdo);
				vctentrete.addElement(cdo.getColValue("entretenimiento"));
			}//End try
			catch (Exception e)
			{
			System.err.println(e.getMessage());
			}//End Catch
		}//End for
		*/
//============================================  QUERY DE IDIOMAS ============================================			 
		sql="select c.compania, c.provincia, c.sigla, c.tomo, c.asiento, a.idioma, a.nivel_conversacion, a.nivel_lectura, a.nivel_escritura, b.descripcion as nameidioma, c.primer_nombre, c.primer_apellido from tbl_pla_idioma_soli a,tbl_pla_idioma b, tbl_pla_solicitante c where a.idioma=b.codigo(+) and a.anio=c.anio and a.consecutivo= c.consecutivo and c.compania="+(String) session.getAttribute("_companyId")+" and a.anio="+anio+" and a.consecutivo="+cons;
		al=SQLMgr.getDataList(sql);
		
		idiomaLastLineNo= al.size();
		
		for(int i=1; i<=al.size();i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i-1);
		if(i<10) key="00"+i;
		else if(i<100)
		key = "0" +i;
		else key=""+i;
		cdo.addColValue("key",key);
		try
			{
				htidioma.put(key,cdo);
				vctidioma.addElement(cdo.getColValue("idioma"));
			}//End try
			catch (Exception e)
			{
			System.err.println(e.getMessage());
			}//End Catch
		
		}//End For
		/*
//============================================  QUERY DE ENFERMEDAD  ============================================	
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.enfermedad, a.alto_riesgo,b.descripcion as enfermedadName, c.primer_apellido, c.primer_nombre from tbl_pla_enfermedad_empl a, tbl_pla_enfermedad b, tbl_pla_empleado c where a.enfermedad=b.codigo(+) and a.provincia=c.provincia and a.sigla= c.sigla and a.tomo = c.tomo and a.asiento= c.asiento and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi;
		al=SQLMgr.getDataList(sql);
		enfermedadLastLineNo= al.size();
		
		for(int i=1; i<=al.size();i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i-1);
		if(i<10) key="00"+i;
		else if(i<100)
		key = "0" +i;
		else key=""+i;
		cdo.addColValue("key",key);
		try
			{
				htenfermedad.put(key,cdo);
				vctenfermed.addElement(cdo.getColValue("enfermedad"));
			}//End try
		catch (Exception e)
			{
			System.err.println(e.getMessage());
			}//End Catch
		
		}//End For
	/*	
//============================================  QUERY DE MEDIDAS  ============================================
sql="select a.provincia, a.sigla, a.tomo, a.asiento, a.tipo_med, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fechamed, a.motivo, a.descripcion, a.autorizapo_por, c.primer_apellido, c.primer_nombre, b.descripcion as medidaName from tbl_pla_medidas_disciplinarias a ,tbl_pla_tipo_medida b, tbl_pla_empleado c where a.tipo_med=b.codigo(+) and a.provincia=c.provincia and a.sigla= c.sigla and a.tomo= c.tomo and a.asiento= c.asiento and a.compania= c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and  a.tomo="+tom+" and  a.asiento="+asi;		
		al=SQLMgr.getDataList(sql);
		medidadLastLineNo= al.size();
		
		for(int i=1; i<=al.size();i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i-1);
		if(i<10) key="00"+i;
		else if(i<100)
		key = "0" +i;
		else key=""+i;
		cdo.addColValue("key",key);
		try
			{
				htmedida.put(key,cdo);
				vctmedidas.addElement(cdo.getColValue("tipo_med"));
			}//End try
			catch (Exception e)
			{
			System.err.println(e.getMessage());
			}//End Catch		
		}//End For
		
//============================================  QUERY DE RECONOCIMIENTOS  ============================================
	
sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.motivo, a.descripcion, a.comentario, c.primer_apellido, c.primer_nombre  from tbl_pla_reconocimiento a, tbl_pla_empleado c where a.provincia=c.provincia and a.sigla=c.sigla and a.tomo=c.tomo and a.asiento = c.asiento and a.compania=c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi;

	al  = SQLMgr.getDataList(sql);
	reconocimientoLastLineNo = al.size();

	for (int i=0; i<al.size(); i++)
	{
		reconocimientoLastLineNo++;
		if (reconocimientoLastLineNo < 10)
		 key = "00" + reconocimientoLastLineNo;
		else if (reconocimientoLastLineNo < 100)
		 key = "0" + reconocimientoLastLineNo;
		else key = "" + reconocimientoLastLineNo;
		htreconocit.put(key, al.get(i));
	} //End For
	
//============================================  QUERY DE PARIENTES  ============================================
	sql="select a.codigo, a.provincia, a.sigla, a.tomo, a.asiento, a.nombre , a.apellido , a.sexo, a.parentesco, a.dependiente, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento , a.vive_con_empleado, a.invalido, a.proteg_por_riesgo, a.trabaja, a.lugar_trabajo, a.telefono_trabajo, a.estudia, a.emp_provincia, a.emp_sigla, a.emp_tomo, a.emp_asiento, a.cod_compania, a.vive, to_char(a.fecha_fallecimiento,'dd/mm/yyyy') as fecha_fallecimiento, a.beneficiario, b.descripcion as parentescoName, c.primer_apellido, c.primer_nombre from tbl_pla_pariente a, tbl_pla_parentesco b, tbl_pla_empleado c where a.parentesco=b.codigo(+) and a.provincia = c.provincia and a.sigla = c.sigla and a.tomo = c.tomo and a.asiento = c.asiento and a.cod_compania = c.compania(+) and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi;
	al=SQLMgr.getDataList(sql);
		parienteLastLineNo= al.size();
		
		for(int i=1; i<=al.size();i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i-1);
		if(i<10) key="00"+i;
		else if(i<100)
		key = "0" +i;
		else key=""+i;
		cdo.addColValue("key",key);
		try
			{
				htpariente.put(key,cdo);
				vctpariente.addElement(cdo.getColValue("parentesco"));
			}//End try
		catch (Exception e)
			{
			System.err.println(e.getMessage());
			}//End Catch
		
		}//End For
		
			*/
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
<%if (mode.equalsIgnoreCase("add"))
{%>
document.title="Expediente de Solicitantes - Agregar - "+document.title;
<%}
else if (mode.equalsIgnoreCase("edit")){%>
document.title="Expediente de Solicitantes - Edición - "+document.title;
<%}%>

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}

function agregar()
{
abrir_ventana1('../common/search_ubicacion_geo.jsp?fp=empleNac');
}

function localizacion()
{
abrir_ventana1('../rhplanilla/list_ubic_direccion.jsp?fp=empleDir');
}

function nacion()
{
abrir_ventana1('../rhplanilla/list_pais.jsp?id=1');
}

function Empleado()
{
abrir_ventana1('../rhplanilla/list_tipo_empleado.jsp?id=2');
}

function Direcciones()
{
abrir_ventana1('../rhplanilla/list_direccion.jsp?fp=empleado');
}

function Secciones()
{
abrir_ventana1('../rhplanilla/list_seccion.jsp?fp=empleado');
}

function Cargosss(op)
{
abrir_ventana1('../rhplanilla/list_cargo_sol.jsp?id='+op);
}

function Estados()
{
abrir_ventana1('../rhplanilla/list_estado.jsp?id=2');
}

function Formassss()
{
abrir_ventana1('../rhplanilla/list_forma.jsp?fp=empleado');
}

function Planillassss()
{
abrir_ventana1('../rhplanilla/list_planilla.jsp?id=2');
}

function Horariosss()
{
abrir_ventana1('../rhplanilla/list_horario.jsp?fp=empleado');
}

function Clavesss()
{
abrir_ventana1('../rhplanilla/list_clave.jsp?fp=empleado');
}

function Jefesss()
{
abrir_ventana1('../rhplanilla/list_cargo.jsp?id=1');
}

function Ubicaciones()
{
abrir_ventana1('../rhplanilla/list_seccion.jsp?fp=empleadoSeccion');
}

function parentesco()
{
abrir_ventana1('../rhplanilla/list_parentesco.jsp?id=1');
}

function clearPais()
{
	document.form0.paisCode.value = '';
	document.form0.paisName.value = '';
	document.form0.provinciaCode.value = '';
	document.form0.provinciaName.value = '';
	document.form0.distritoCode.value = '';
	document.form0.distritoName.value = '';
	document.form0.corregimientoCode.value = '';
	document.form0.corregimientoName.value = '';
}

function limpiarPaisDir()
{
	document.form0.paisC.value = '';
	document.form0.paisN.value = '';
	document.form0.provinciaC.value = '';
	document.form0.provinciaN.value = '';
	document.form0.distritoC.value = '';
	document.form0.distritoN.value = '';
	document.form0.corregimientoC.value = '';
	document.form0.corregimientoN.value = '';	
	document.form0.comunidadC.value = '';
	document.form0.comunidadN.value = '';
}

function clearProvincia()
{
	document.form0.provinciaCode.value = '';
	document.form0.provinciaName.value = '';
	document.form0.distritoCode.value = '';
	document.form0.distritoName.value = '';
	document.form0.corregimientoCode.value = '';
	document.form0.corregimientoName.value = '';
}

function limpiarProvinDir()
{
	document.form0.provinciaC.value = '';
	document.form0.provinciaN.value = '';
	document.form0.distritoC.value = '';
	document.form0.distritoN.value = '';
	document.form0.corregimientoC.value = '';
	document.form0.corregimientoN.value = '';
	document.form0.comunidadC.value = '';
	document.form0.comunidadN.value = '';
}

function clearDistrito()
{
	document.form0.distritoCode.value = '';
	document.form0.distritoName.value = '';
	document.form0.corregimientoCode.value = '';
	document.form0.corregimientoName.value = '';
}

function limpiarDistritDir()
{
	document.form0.distritoC.value = '';
	document.form0.distritoN.value = '';
	document.form0.corregimientoC.value = '';
	document.form0.corregimientoN.value = '';
	document.form0.comunidadC.value = '';
	document.form0.comunidadN.value = '';
}

function clearCorregimiento()
{
	document.form0.corregimientoCode.value = '';
	document.form0.corregimientoName.value = '';
}

function limpiarCorregDir()
{
	document.form0.corregimientoC.value = '';
	document.form0.corregimientoN.value = '';	
	document.form0.comunidadC.value = '';
	document.form0.comunidadN.value = '';
}

function clearComunidad()
{
	document.form0.comunidadC.value = '';
	document.form0.comunidadN.value = '';
}

function calculanor(){ 

var hoy;
var edad;
var fecha;

	if (document.form0.fechanac.value!="")
	{ 	
	fecha=document.form0.fechanac.value;
	hoy=new Date() ;
	
    var array_fecha = fecha.split("/") ;
    if (array_fecha.length!=3) 	document.form0.edades.value=" ";
	
    var ano ;
    ano = parseInt(array_fecha[2]); 
    if (isNaN(ano))  document.form0.edades.value="";

    var mes ;
    mes = parseInt(array_fecha[1]); 
    if (isNaN(mes)) 
       document.form0.edades.value=" ";

    var dia ;
    dia = parseInt(array_fecha[0]); 
    if (isNaN(dia)) 
       document.form0.edades.value=" ";

    edad=hoy.getFullYear()- ano - 1; //-1 porque no se si ha cumplido años ya este año 

    if (hoy.getMonth() + 1 - mes < 0) //+ 1 porque los meses empiezan en 0 
	   document.form0.edades.value= edad ;
    if (hoy.getMonth() + 1 - mes > 0) 
       document.form0.edades.value= edad+1 ;

    if (hoy.getUTCDate() - dia >= 0) 
       document.form0.edades.value=edad + 1;
	   document.form0.edades.value=edad + 1;
	}
	
}

function doAction()
{
	calculanor();
	//showHide(1);
	showHide(2);
	showHide(3);

<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("1"))
		{
%>
		educaci();
<%
		}
		else if (tab.equals("2"))
		{
%>
		cursosFuera();
<%
		}
		else if (tab.equals("3"))
		{
%>
	 	habilidadExp();
<%
		}
		
		else if(tab.equals("4"))
		{
%>
		entrevistaExp();
<%
		}
		
		else if(tab.equals("5"))
		{
%>
		idiomaexp();
<%
		}
		
		else if(tab.equals("6"))
		{
%>
		enfermedadExp();
<%
		}
		
		else if(tab.equals("7"))
		{
%>
		medidaExp():
<%
		}

		else if(tab.equals("9"))
		{
%>
		parienteExp();
<%	
		}
	}
%>
}

function educaci()
{
abrir_ventana1('../rhplanilla/list_educa_sol.jsp?fp=empleado&mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&anio=<%=anio%>&cons=<%=cons%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&idiomaLastLineNo<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>');
}

function cursosFuera()
{
abrir_ventana1('../rhplanilla/curso_list.jsp?fp=empleado&mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&idiomaLastLineNo<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>');
}

function habilidadExp()
{
abrir_ventana1('../rhplanilla/list_habilidad.jsp?fp=empleado&mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&idiomaLastLineNo<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>');
}

function entrevistaExp()
{
abrir_ventana1('../rhplanilla/list_entretenimiento.jsp?fp=empleado&mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&idiomaLastLineNo<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>');
}

function idiomaexp()
{
abrir_ventana1('../rhplanilla/list_idioma.jsp?fp=solicitud&mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&anio=<%=anio%>&cons=<%=cons%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&idiomaLastLineNo<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>');
}

function enfermedadExp()
{
abrir_ventana1('../rhplanilla/list_enfermedad.jsp?fp=empleado&mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&idiomaLastLineNo<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>');
}

function medidaExp()
{
abrir_ventana1('../rhplanilla/list_medida.jsp?fp=empleado&mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&idiomaLastLineNo<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>');
}

function parienteExp()
{
abrir_ventana1('../rhplanilla/list_pariente.jsp?fp=empleado&mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&idiomaLastLineNo<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>');
}

function empleado()
{
abrir_ventana1('../rhplanilla/list_empleados.jsp?fp=empleado&mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&educaLastLineNo=<%=educaLastLineNo%>&cursoLastLineNo=<%=cursoLastLineNo%>&habilidadLastLineNo=<%=habilidadLastLineNo%>&idiomaLastLineNo<%=idiomaLastLineNo%>&enfermedadLastLineNo=<%=enfermedadLastLineNo%>&medidadLastLineNo=<%=medidadLastLineNo%>&reconocimientoLastLineNo=<%=reconocimientoLastLineNo%>&parienteLastLineNo=<%=parienteLastLineNo%>');
}




function checkProvincia(obj)
{
	var sigla=document.form0.sigla.value;
	var tomo=document.form0.tomo.value;
	var asiento=document.form0.asiento.value;
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_solicitante',' provincia=\''+obj.value+'\' and sigla=\''+sigla+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\'','<%=emple.getColValue("provincia").trim()%>')
}

function checkSigla(obj)
{
	var provincia=document.form0.provincia.value;
	var tomo=document.form0.tomo.value;
	var asiento=document.form0.asiento.value;
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_solicitante',' provincia=\''+provincia+'\' and sigla=\''+obj.value+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\'','<%=emple.getColValue("sigla").trim()%>')
}

function checkTomo(obj)
{
	var provincia=document.form0.provincia.value;
	var sigla=document.form0.sigla.value;
	var asiento=document.form0.asiento.value;
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_solicitante',' provincia=\''+provincia+'\' and sigla=\''+sigla+'\' and tomo=\''+obj.value+'\' and asiento=\''+asiento+'\'','<%=emple.getColValue("tomo").trim()%>')
}
function checkAsiento(obj)
{
	var provincia=document.form0.provincia.value;
	var sigla=document.form0.sigla.value;
	var tomo=document.form0.tomo.value;
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_solicitante','provincia=\''+provincia+'\' and sigla=\''+sigla+'\' and tomo=\''+tomo+'\' and asiento=\''+obj.value+'\'','<%=emple.getColValue("asiento").trim()%>')
}
function checkCode(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_solicitante','consecutivo=\''+obj.value+'\'','<%=emple.getColValue("consecutivo")%>');
}
function checkAnio(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_solicitante','anio=\''+obj.value+'\'','<%=emple.getColValue("anio")%>');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="SOLICITUD DE ASPIRANTES"></jsp:param>
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
				  <%=fb.hidden("tab","0")%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("anio",anio)%> 
				  <%=fb.hidden("cons",cons)%>
				  <%=fb.hidden("id",id)%>
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%> 
				  <%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				  <%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%> 
				  <%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%> 
				  <%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%> 
				  <%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%> 
				  <%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%> 
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("cursofSize",""+htcursof.size())%> 
				  <%=fb.hidden("habilidadSize",""+hthabilidad.size())%> 
				  <%=fb.hidden("entrevistaSize",""+htentrevista.size())%> 
				  <%=fb.hidden("idiomaSize",""+htidioma.size())%> 
				  <%=fb.hidden("enfermedadSize",""+htenfermedad.size())%> 
				  <%=fb.hidden("medidadSize",""+htmedida.size())%> 
				  <%=fb.hidden("reconSize",""+htreconocit.size())%> 
				  <%=fb.hidden("parienteSize",""+htpariente.size())%>
				  <%=fb.hidden("code",code)%>
<%fb.appendJsValidation("if(checkCode(document.form0.consecutivo))error++;");%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Datos Personales del Solicitante </td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel0">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01"><%=fb.hidden("CONSECUTIVO",emple.getColValue("CONSECUTIVO"))%>
                          <td>&nbsp;C&eacute;dula</td>
                          <td colspan="1">
						  <%=fb.intBox("provincia",emple.getColValue("provincia"),true,mode.equals("edit"),false,5,2,null,null,"onBlur=\"javascript:checkProvincia(this)\"")%>
						  <%=fb.textBox("sigla",emple.getColValue("sigla"),true,mode.equals("edit"),false,5,2,null,null,"onBlur=\"javascript:checkSigla(this)\"")%> 
						  <%=fb.intBox("tomo",emple.getColValue("tomo"),true,mode.equals("edit"),false,5,4,null,null,"onBlur=\"javascript:checkTomo(this)\"")%> 
						  <%=fb.intBox("asiento",emple.getColValue("asiento"),true,mode.equals("edit"),false,5,5,null,null,"onBlur=\"javascript:checkAsiento(this)\"")%>						   </td>
						    <td colspan="1">&nbsp;&nbsp;&nbsp;&nbsp;Foto</td>
						<td><%=fb.fileBox("foto",emple.getColValue("foto"),false,false,15)%></td>
                        </tr>
                        <tr class="TextRow01" >
                          <td width="17%">&nbsp;Primer Nombre</td>
                          <td width="33%"><%=fb.textBox("nombre1",emple.getColValue("nombre1"),true,false,false,30,30)%></td>
                          <td width="20%">&nbsp;&nbsp;&nbsp;&nbsp;Segundo Nombre</td>
                          <td width="30%"><%=fb.textBox("nombre2",emple.getColValue("nombre2"),false,false,false,30,30)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Primer Apellido</td>
                          <td><%=fb.textBox("apellido1",emple.getColValue("apellido1"),true,false,false,30,30)%></td>
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Segundo Apellido</td>
                          <td><%=fb.textBox("apellido2",emple.getColValue("apellido2"),false,false,false,30,30)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Apellido de Casada</td>
                          <td><%=fb.textBox("casada",emple.getColValue("casada"),false,false,false,30,30)%>&nbsp;</td>
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Estado Civil</td>
                          <td><%=fb.select("civil","CS=CASADO, DV=DIVORCIADO, SP=SEPARADO, ST=SOLTERO, UN=UNIDO, VD=VIUDO ",emple.getColValue("civil"))%> </td>
                        </tr>
						 <tr class="TextRow01">
                          <td>&nbsp;Sexo</td>
                          <td><%=fb.select("sexo","F=FEMENINO, M=MASCULINO",emple.getColValue("sexo"))%></td>
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Nacionalidad</td>
                          <td><%=fb.intBox("nacionalidadCode",emple.getColValue("nacionalidadCode"),false,false,true,5,4)%> 
						  <%=fb.textBox("nacionalidad",emple.getColValue("nacionalidad"),false,false,true,23)%> 
						  <%=fb.button("btndireccion","Ir",true,false,null,null,"onClick=\"javascript:nacion()\"")%> </td>
                        </tr>
							<tr class="TextRow01">
						<td width="18%">&nbsp;Peso</td>
                          <td width="32%"><%=fb.intBox("peso",emple.getColValue("peso"),false,false,false,10,10)%> </td>
                          <td width="18%">&nbsp;&nbsp;&nbsp;&nbsp;Estatura:</td>
                          <td width="32%"><%=fb.textBox("estatura",emple.getColValue("estatura"),false,false,false,10,10)%></td>
                        </tr>
						<tr class="TextRow01">
						<td width="18%">&nbsp;Lic. de Conducir</td>
                          <td width="32%"><%=fb.checkbox("conducir","S",(emple.getColValue("conducir") != null && emple.getColValue("conducir").equalsIgnoreCase("S")),false)%> </td>
                          <td width="18%">&nbsp;&nbsp;&nbsp;&nbsp;Tipo de Lic:</td>
                          <td width="32%"><%=fb.textBox("licencia",emple.getColValue("licencia"),false,false,false,10,10)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;No. de Lic.</td>
                          <td><%=fb.textBox("nlicencia",emple.getColValue("nlicencia"),false,false,false,10,20)%></td>
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Dependientes</td>
                          <td><%=fb.textBox("dependiente",emple.getColValue("dependiente"),false,false,false,10,150)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Tipo Sangre</td>
                          <td><%=fb.select(ConMgr.getConnection()," select distinct tipo_sangre  from tbl_bds_tipo_sangre order by tipo_sangre ","sang",emple.getColValue("sang"))%> 
						  <%=fb.select(ConMgr.getConnection()," select distinct rh from tbl_bds_tipo_sangre order by rh","sangre",emple.getColValue("sangre"))%> </td>
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;A&ntilde;o</td>
                          <td><%=fb.intBox("anio",emple.getColValue("anio"),false,false,false,10,4)%></td>
                        </tr>
        
                        <tr class="TextRow01">
                          <td>&nbsp;Fecha Nacimiento</td>
                        <td>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fechanac" />
						<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("fechanac")%>" />
						<jsp:param name="jsEvent" value="calculanor()" />
						</jsp:include>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Edad:&nbsp;&nbsp;
							<%=fb.textBox("edades","",false,false,true,5)%></td>
						
						<td>&nbsp;&nbsp;&nbsp;&nbsp;No. S.S.</td>
                        <td><%=fb.textBox("seguro", emple.getColValue("seguro"),false,false,false,15,20)%></td>
                        </tr>

                     	
                        <tr class="TextRow01">
                          <td>&nbsp;Lugar Nacimiento</td>
                          <td><%=fb.textBox("lugar_nacimiento",emple.getColValue("lugar_nacimiento"),false,false,false,35,100)%></td>
                        
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Dirección</td>
                          <td><%=fb.textBox("direccion",emple.getColValue("direccion"),false,false,false,35,100)%></td>
                        </tr>
						
                        <tr class="TextHeader">
                          <td colspan="4">&nbsp;Telefono</td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Tel. Casa</td>
                          <td><%=fb.textBox("telcasa",emple.getColValue("telcasa"),false,false,false,34,11)%></td>
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Tel.Trabajo </td>
                          <td><%=fb.textBox("telotros",emple.getColValue("telotros"),false,false,false,34,11)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Tel. Celular </td>
                          <td colspan="3"><%=fb.textBox("tellugar",emple.getColValue("tellugar"),false,false,false,34,11)%></td>
                        </tr>
                        <tr class="TextHeader">
                          <td colspan="4">Direccion Postal</td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Apartado</td>
                          <td><%=fb.textBox("apartado",emple.getColValue("apartado"),false,false,false,34,20)%></td>
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Zona</td>
                          <td><%=fb.textBox("zona",emple.getColValue("zona"),false,false,false,34,20)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Correo Electronico</td>
                          <td colspan="3"><%=fb.emailBox("email",emple.getColValue("email"),false,false,false,34,100)%></td>
                        </tr>
						
						 <tr class="TextHeader">
                          <td colspan="4">&nbsp;En Caso de Urgencia</td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Llama a:</td>
                          <td><%=fb.textBox("urgllamar",emple.getColValue("urgllamar"),false,false,false,34,100)%></td>
              <td>&nbsp;&nbsp;&nbsp;&nbsp;Parentesco</td>
                          <td><%=fb.intBox("urgCode",emple.getColValue("urgCode"),false,false,true,5,4)%> 
						  <%=fb.textBox("urgParentesco",emple.getColValue("urgParentesco"),false,false,true,23)%> 
						  <%=fb.button("btnparentesco","Ir",true,false,null,null,"onClick=\"javascript:parentesco()\"")%> </td>
                        </tr>
                        <tr class="TextRow01">
                              <td>&nbsp;&nbsp;&nbsp;&nbsp;Teléfono:</td>
                          <td><%=fb.textBox("telurg",emple.getColValue("telurg"),false,false,false,34,15)%></td>
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Celular</td>
                          <td><%=fb.textBox("celurg",emple.getColValue("celurg"),false,false,false,34,15)%></td>
                        </tr>
						
						
                      </table></td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">Cargos del  Aspirante </td>
				         <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel1">
                   <td><table width="100%" align="center" cellpadding="1" cellspacing="1">
				    <tr class="TextRow01">
					              <td>&nbsp;Lugar que Prefiere:</td>
                          <td><%=fb.textBox("lugarpref",emple.getColValue("lugarpref"),false,false,false,34,30)%></td>
                          <td>&nbsp;Fecha de Solicitud</td>
                            <td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fechasol" />
								<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("fechasol")%>" />
								</jsp:include></td>
				    </tr>
                        <tr class="TextRow01">
                         <td>&nbsp;Primer Cargo que Aspira</td>
                          <td><%=fb.textBox("cargo1",emple.getColValue("cargo1"),false,false,true,5,12)%> 
						  <%=fb.textBox("nameCargo1",emple.getColValue("nameCargo1"),false,false,true,28)%> 
						  <%=fb.button("btnCargo","Ir",true,false,null,null,"onClick=\"javascript:Cargosss(1)\"")%> </td>
                        
                          <td>&nbsp;Segundo Cargo que Aspira</td>
                          <td><%=fb.textBox("cargo2",emple.getColValue("cargo2"),false,false,true,5,12)%> 
						  <%=fb.textBox("nameCargo2",emple.getColValue("nameCargo2"),false,false,true,28)%> 
						  <%=fb.button("btnCargo2","Ir",true,false,null,null,"onClick=\"javascript:Cargosss(2)\"")%> </td>
                        </tr>
                        <tr class="TextRow01">
                         <td>&nbsp;Tercer Cargo que Aspira</td>
                          <td><%=fb.textBox("cargo3",emple.getColValue("cargo3"),false,false,true,5,12)%> 
						  <%=fb.textBox("nameCargo3",emple.getColValue("nameCargo3"),false,false,true,28)%> 
						  <%=fb.button("btnCargo3","Ir",true,false,null,null,"onClick=\"javascript:Cargosss(3)\"")%> </td>
                        
                          <td>&nbsp;Salario Deseado </td>
                          <td><%=fb.textBox("salario",emple.getColValue("salario"),false,false,false,35,80)%></td>
                        </tr>
                        
                      </table></td>
                  </tr>
              
                  <tr>
                    <td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Datos Familiares</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
				  
                  <tr id="panel3">
                    <td><table width="100%" align="center" cellpadding="1" cellspacing="1">
                      
                      <tr class="TextRow01">
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Nombre de la Madre</td>
                        <td><%=fb.textBox("madre",emple.getColValue("madre"),false,false,false,35,80)%></td>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Nombre del Padre</td>
                        <td><%=fb.textBox("padre",emple.getColValue("padre"),false,false,false,35,80)%></td>
                      </tr>
                      <tr class="TextRow01">
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Vive Madre?</td>
                        <td><%=fb.checkbox("vivemadre","S",(emple.getColValue("vivemadre") != null && emple.getColValue("vivemadre").equalsIgnoreCase("S")),false)%></td>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Vive Padre?</td>
                        <td><%=fb.checkbox("vivepadre","S",(emple.getColValue("vivepadre") != null && emple.getColValue("vivepadre").equalsIgnoreCase("S")),false)%></td>
                      </tr>
                      <tr class="TextRow01">
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Fecha de Nacimiento</td>
                        <td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="nacmadre" />
								<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("nacmadre")%>" />
								</jsp:include></td>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Fecha de Nacimiento</td>
                       <td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="nacpadre" />
								<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("nacpadre")%>" />
								</jsp:include></td>
                      </tr>
                      <tr class="TextRow01">
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Ocupación de la Madre</td>
                        <td><%=fb.textBox("ocumadre",emple.getColValue("ocumadre"),false,false,false,35,80)%></td>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Ocupación del Padre</td>
                        <td><%=fb.textBox("ocupadre",emple.getColValue("ocupadre"),false,false,false,35,80)%></td>
                      </tr>
					                        <tr class="TextRow01">
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Lugar de Trabajo de la Madre</td>
                        <td><%=fb.textBox("tramadre",emple.getColValue("tramadre"),false,false,false,35,80)%></td>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Lugar de Trabajo del Padre</td>
                        <td><%=fb.textBox("trapadre",emple.getColValue("trapadre"),false,false,false,35,80)%></td>
                      </tr>
					  
					   <tr class="TextHeader">
                          <td colspan="4">&nbsp;Personas que Dependen / Viven con Usted</td>
                        </tr>
                        <tr class="TextRow01">
						<td colspan="4"> &nbsp;&nbsp;&nbsp;&nbsp;Trabaja algún Familiar en esta Empresa ? &nbsp;&nbsp;<%=fb.select("familiar_cia","S=SI,N=NO",emple.getColValue("familiar_cia"),false,false,0," ")%> </td>
					    </tr>
                    
						<tr class="TextRow01">
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Nombre</td>
                          <td><%=fb.textBox("nombre_fam",emple.getColValue("nombre_fam"),false,false,false,30,80)%> 
						   <%=fb.button("btnempleado","Ir",true,false,null,null,"onClick=\"javascript:empleado()\"")%> </td>
						 
                          <td>&nbsp;&nbsp;&nbsp;&nbsp;Parentesco</td>
                          <td><%=fb.select(ConMgr.getConnection()," select descripcion from tbl_pla_parentesco order by descripcion ","parentezco_fam",emple.getColValue("parentezco_fam"),false,false,0," ")%> </td>
                        </tr>
	
					 <tr class="TextRow01">
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Ocupacion</td>
                        <td><%=fb.textBox("ocupacion_fam",emple.getColValue("ocupacion_fam"),false,false,false,35,100)%></td>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Departamento</td>
                        <td><%=fb.textBox("depto_fam",emple.getColValue("depto_fam"),false,false,false,35,100)%></td>
                      </tr>
									  
                      <tr class="TextHeader">
                        <td colspan="4">&nbsp;Coyuge</td>
                      </tr>
                      <tr class="TextRow01">
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Nombre del Conyuge </td>
                        <td><%=fb.textBox("conyuge",emple.getColValue("conyuge"),false,false,false,35,80)%></td>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Fecha de Nacimiento </td>
                        <td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="nacconyuge" />
								<jsp:param name="valueOfTBox1" value="<%=emple.getColValue("nacconyuge")%>" />
								</jsp:include></td>
                      </tr>
                      <tr class="TextRow01">
                                <td>&nbsp;&nbsp;&nbsp;&nbsp;Ocupación del Conyuge </td>
                        <td><%=fb.textBox("ocuconyuge",emple.getColValue("ocuconyuge"),false,false,false,35,80)%></td>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Lugar de Trabajo </td>
                        <td><%=fb.textBox("traconyuge",emple.getColValue("traconyuge"),false,false,false,35,20)%></td>
                      </tr>
                    </table></td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false)%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
                  <%=fb.formEnd(true)%>
                </table>
              </div>
                  <!-- ===================   Tab1 EDUCACION    ============================ -->
              <div class="dhtmlgoodies_aTab">
                <table width="100%" cellpadding="0" cellspacing="1">
                  <!-- =================   F O R M   S T A R T   H E R E   ================== -->
                  <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("tab","1")%> 
				  <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("anio",anio)%> 
				  <%=fb.hidden("cons",cons)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%> 
				  <%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				  <%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%> 
				  <%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%> 
				  <%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%> 
				  <%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%> 
				  <%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("cursofSize",""+htcursof.size())%> 
				  <%=fb.hidden("habilidadSize",""+hthabilidad.size())%> 
				  <%=fb.hidden("entrevistaSize",""+htentrevista.size())%> 
				  <%=fb.hidden("idiomaSize",""+htidioma.size())%> 
				  <%=fb.hidden("enfermedadSize",""+htenfermedad.size())%> 
				  <%=fb.hidden("medidadSize",""+htmedida.size())%> 
				  <%=fb.hidden("reconSize",""+htreconocit.size())%> 
				  <%=fb.hidden("parienteSize",""+htpariente.size())%> 
				  <%=fb.hidden("code",code)%>
				   <%=fb.hidden("codigo",codigo)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
  
                  <tr>
                    <td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Educaci&oacute;n</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel1">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
                          <td width="5%">Cod.</td>
                          <td width="5%">Cod. Tipo Educ.</td>
                          <td width="15%">Educaci&oacute;n</td>
                          <td width="14%">Titulo</td>
                          <td width="15">Lugar</td>
                          <td width="15%">Desde</td>
                          <td width="15%">Hasta</td>
                          <td width="5%">Termin&oacute;</td>
                          <td width="6%">Años Cursados</td>
                          <td width="5%"><%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:educaci()\"","Agregar Educación")%></td>
                        </tr>
                        <%   String js = "";
							al=CmnMgr.reverseRecords(hteducacion);	
							for(int i=1; i<=hteducacion.size(); i++)
							{
							key = al.get(i - 1).toString();	
							CommonDataObject cdo = (CommonDataObject) hteducacion.get(key);
							String fecha_inicio = "fecha_inicio"+i;
							String fecha_final = "fecha_final"+i;
							%>
                        <%=fb.hidden("key"+i,cdo.getColValue("key"))%> 
						<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%> 
						<%=fb.hidden("tipo_educacion"+i,cdo.getColValue("tipo"))%> 
						  <%=fb.hidden("sol_anio",anio)%> 
						<%=fb.hidden("sol_consecutivo",cons)%> 
						<%=fb.hidden("educacioName"+i,cdo.getColValue("educacioName"))%> 
						<%=fb.hidden("remove"+i,"")%>						
         <tr class="TextRow01">
             <td align="center"><%=fb.intBox("codigo"+i,cdo.getColValue("codigo"),false,false,true,2,2,"Text10",null,null)%></td>
             <td align="center"><%=cdo.getColValue("tipo")%></td>
             <td><%=cdo.getColValue("educacioName")%></td>
			 <td><%=fb.textBox("certificado_obt"+i,cdo.getColValue("certificado_obt"),false,false,false,18,60,"Text10",null,null)%></td>
             <td><%=fb.textBox("centro_educativo"+i,cdo.getColValue("centro_educativo"),true,false,false,18,60,"Text10",null,null)%></td>
                         <td align="center"><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="<%=fecha_inicio%>" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_inicio")%>" />
							</jsp:include> </td>
             <td><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="<%=fecha_final%>"/>
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_final")%>"/>
							</jsp:include> </td>
             <td align="center"><%=fb.checkbox("termino"+i,"S",(cdo.getColValue("termino") != null && cdo.getColValue("termino").trim().equalsIgnoreCase("S")),false)%></td>
             <td><%=fb.select("anio_cursado"+i,"1,2,3,4,5,6",cdo.getColValue("anio_cursado"),false,false,0,"Text10",null,null)%></td>
             <td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Educación")%> 
         </tr>
                 <%
				 js += "if(document."+fb.getFormName()+".centro_educativo"+i+".value=='')error--;";
						
				} 
				fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");		
				%>
                      </table></td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
                  <%=fb.formEnd(true)%>
                </table>
              </div>
			  
			  <%-- ==================== Tab2 Cursos de Afuera  ======================--%>
              <div class="dhtmlgoodies_aTab">
                <table width="100%" cellpadding="0" cellspacing="1">
                  <%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("tab","2")%> 
				  <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("anio",anio)%> 
				  <%=fb.hidden("cons",cons)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%> 
				  <%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				  <%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%> 
				  <%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%> 
				  <%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%> 
				  <%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%> 
				  <%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("cursofSize",""+htcursof.size())%> 
				  <%=fb.hidden("habilidadSize",""+hthabilidad.size())%> 
				  <%=fb.hidden("entrevistaSize",""+htentrevista.size())%> 
				  <%=fb.hidden("idiomaSize",""+htidioma.size())%> 
				  <%=fb.hidden("enfermedadSize",""+htenfermedad.size())%> 
				  <%=fb.hidden("medidadSize",""+htmedida.size())%> 
				  <%=fb.hidden("reconSize",""+htreconocit.size())%> 
				  <%=fb.hidden("parienteSize",""+htpariente.size())%> 
				  <%=fb.hidden("code",code)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Registro de Empleado</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
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
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
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
                          <td width="5%"><%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:cursosFuera()\"","Agregar Cursos")%></td>
                        </tr>
                        <%
						String jss = "";
						al=CmnMgr.reverseRecords(htcursof);
						for (int i=1; i<=htcursof.size(); i++)
						{
						key = al.get(i - 1).toString();
						CommonDataObject cdo = (CommonDataObject) htcursof.get(key);
						String fecha_inicio1 = "fecha_inicio1"+i;
						String fecha_final1 = "fecha_final1"+i;		
						%>
                        <%=fb.hidden("key"+i,cdo.getColValue("key"))%> 
						<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%> 
						<%=fb.hidden("nameCurso"+i,cdo.getColValue("nameCurso"))%> 
						<%=fb.hidden("remove"+i,"")%>
                        <tr class="TextRow01">
                          <td><%=fb.intBox("code"+i,cdo.getColValue("codigo"),false,false,true,3,3,"Text10",null,null)%></td>
                          <td><%=cdo.getColValue("tipo")%></td>
                          <td><%=cdo.getColValue("nameCurso")%></td>
                          <td><%=fb.textBox("institucion"+i,cdo.getColValue("institucion"),true,false,false,30,60,"Text10",null,null)%></td>
                          <td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),true,false,false,30,60,"Text10",null,null)%></td>
                          <td align="center"><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="<%=fecha_inicio1%>" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_inicio")%>" />
								</jsp:include></td>
                          <td align="center"><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="<%=fecha_final1%>" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_final")%>" />
								</jsp:include></td>
                          <td><%=fb.intBox("duracion"+i,cdo.getColValue("duracion"),false,false,false,5,8,"Text10",null,null)%></td>
                          <td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Cursos")%> 
                        </tr>
                        <%
						 jss += "if(document."+fb.getFormName()+".institucion"+i+".value=='')error--;";
						 jss += "if(document."+fb.getFormName()+".descripcion"+i+".value=='')error--;";
						}//End for
						fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+jss+"}");	
						%>
                      </table></td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
					 <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
					
                  </tr>
                  <%=fb.formEnd(true)%>
                </table>
              </div>
              <%-- ========================= Tab3 Habilidades  =========================--%>
              <div class="dhtmlgoodies_aTab">
                <table width="100%" cellpadding="0" cellspacing="1">
				  <% fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST); %>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("tab","3")%> 
				  <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("anio",anio)%> 
				  <%=fb.hidden("cons",cons)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%> 
				  <%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				  <%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%> 
				  <%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%> 
				  <%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%> 
				  <%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%> 
				  <%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>  
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("cursofSize",""+htcursof.size())%> 
				  <%=fb.hidden("habilidadSize",""+hthabilidad.size())%> 
				  <%=fb.hidden("entrevistaSize",""+htentrevista.size())%> 
				  <%=fb.hidden("idiomaSize",""+htidioma.size())%> 
				  <%=fb.hidden("enfermedadSize",""+htenfermedad.size())%> 
				  <%=fb.hidden("medidadSize",""+htmedida.size())%> 
				  <%=fb.hidden("reconSize",""+htreconocit.size())%> 
				  <%=fb.hidden("parienteSize",""+htpariente.size())%> 
				  <%=fb.hidden("code",code)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Registro de Empleado</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
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
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel31">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
                          <td width="10%">Codigo</td>
                          <td width="85%">Descripci&oacute;n</td>
                          <td width="5%"><%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:habilidadExp()\"","Agregar Habilidades")%></td>
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
                          <td><%=cdo.getColValue("habilidad")%></td>
                          <td><%=cdo.getColValue("habilidadName")%></td>
                          <td><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Habilidades")%></td>
                        </tr>
                        <%
							}
							%>
                      </table></td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
                  <%=fb.formEnd(true)%>
                </table>
              </div>
              <%-- =============================   Tab4 Entretenimiento   ================= --%>
              <div class="dhtmlgoodies_aTab">
			  <table width="100%"  cellpadding="0" cellspacing="1">
			  	<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                <%=fb.formStart(true)%> 
				<%=fb.hidden("mode",mode)%> 
				<%=fb.hidden("tab","4")%> 
				<%=fb.hidden("prov",prov)%> 
				<%=fb.hidden("sig",sig)%> 
				<%=fb.hidden("tom",tom)%> 
				<%=fb.hidden("asi",asi)%> 
				<%=fb.hidden("anio",anio)%> 
				<%=fb.hidden("cons",cons)%> 
				<%=fb.hidden("baction","")%> 
				<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%> 
				<%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%> 
				<%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				<%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%> 
				<%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%> 
				<%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%> 
				<%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%> 
				<%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%> 
				<%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				<%=fb.hidden("cursofSize",""+htcursof.size())%> 
				<%=fb.hidden("habilidadSize",""+hthabilidad.size())%> 
				<%=fb.hidden("entrevistaSize",""+htentrevista.size())%> 
				<%=fb.hidden("idiomaSize",""+htidioma.size())%> 
				<%=fb.hidden("enfermedadSize",""+htenfermedad.size())%> 
				<%=fb.hidden("medidadSize",""+htmedida.size())%> 
				<%=fb.hidden("reconSize",""+htreconocit.size())%> 
				<%=fb.hidden("parienteSize",""+htpariente.size())%> 
				<%=fb.hidden("code",code)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(40)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Registro de Empleado</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus40" style="display:none">+</label><label id="minus40">-</label></font>]&nbsp;</td>
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
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus41" style="display:none">+</label><label id="minus41">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel41">
                    <td>
						<table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
							<td width="10%">C&oacute;digo</td>
							<td width="70%">Descripci&oacute;n</td>
							<td width="15%">Tipo</td>
							<td width="5%" align="center"><%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:entrevistaExp()\"","Agregar Entretenimientos")%></td>
						</tr>
						<%
						System.out.println("al size="+htentrevista.size());
						al=CmnMgr.reverseRecords(htentrevista);
						for (int i=1; i<=htentrevista.size(); i++)
						{
						key = al.get(i - 1).toString();	
						CommonDataObject cdo = (CommonDataObject) htentrevista.get(key);
						%>
						<%System.out.println("******************************FORM1 CYCLE WHEN i ="+i+" AND KEY = "+cdo.getColValue("key"));%>
						 <%=fb.hidden("key"+i,cdo.getColValue("key"))%> 
						<%=fb.hidden("entretenimiento"+i,cdo.getColValue("entretenimiento"))%>
						<%=fb.hidden("entretenimientoName"+i,cdo.getColValue("entretenimientoName"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
							<td><%=cdo.getColValue("entretenimiento")%></td>
							<td><%=cdo.getColValue("entretenimientoName")%></td>
							<td><%=fb.select("tip"+i,"D=DEPORTE,P=PASATIEMPO",cdo.getColValue("tipo"),false,false,0,"Text10",null,null)%></td>
							 <td><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Entretenimiento")%></td>
						</tr>
						<%
						}
						%>
						</table>
					</td>
				</tr>
				  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',this.value)\"")%>
					 <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
					
                  </tr>
						
			  <%=fb.formEnd(true)%>
			  </table>
			  </div>
  
              <%-- ===========================  Tab5 Idioma  ======================== --%>
              <div class="dhtmlgoodies_aTab">
                <table width="100%" cellpadding="0" cellspacing="1">
                  <%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("tab","5")%> 
				  <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("anio",anio)%> 
				  <%=fb.hidden("cons",cons)%>
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%> 
				  <%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				  <%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%> 
				  <%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%> 
				  <%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%> 
				  <%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%> 
				  <%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%> 
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("cursofSize",""+htcursof.size())%> 
				  <%=fb.hidden("habilidadSize",""+hthabilidad.size())%> 
				  <%=fb.hidden("entrevistaSize",""+htentrevista.size())%> 
				  <%=fb.hidden("idiomaSize",""+htidioma.size())%> 
				  <%=fb.hidden("enfermedadSize",""+htenfermedad.size())%> 
				  <%=fb.hidden("medidadSize",""+htmedida.size())%> 
				  <%=fb.hidden("reconSize",""+htreconocit.size())%> 
				  <%=fb.hidden("parienteSize",""+htpariente.size())%> 
				  <%=fb.hidden("code",code)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(50)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Registro del Solicitante</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus50" style="display:none">+</label><label id="minus50">-</label></font>]&nbsp;</td>
                        </tr>
                      </table>
				    </td>
                  </tr>
                  <tr id="panel50">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="15%" align="right"># Cédula</td>
                          <td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
                          <td width="15%" align="right">Nombre del Solicitante</td>
                          <td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(51)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Idioma</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus51" style="display:none">+</label><label id="minus51">-</label></font>]&nbsp;</td>
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
                          <td width="5%">&nbsp;<%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:idiomaexp()\"","Agregar Idiomas")%></td>
                        </tr>
                        <%
							System.out.println("******************************FORM5 htidioma ="+htidioma.size());		
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
                        <tr class="TextRow01">
                          <td><%=cdo.getColValue("idioma")%></td>
                          <td><%=cdo.getColValue("nameidioma")%></td>
                          <td><%=fb.select("nivel_conversacion"+i,"A=AVANZADO,I=INTERMEDIO,B=BASICO",cdo.getColValue("nivel_conversacion"),false,false,0,"Text10",null,null)%></td>
                          <td><%=fb.select("nivel_lectura"+i,"A=AVANZADO,I=INTERMEDIO,B=BASICO",cdo.getColValue("nivel_lectura"),false,false,0,"Text10",null,null)%></td>
                          <td><%=fb.select("nivel_escritura"+i,"A=AVANZADO,I=INTERMEDIO,B=BASICO",cdo.getColValue("nivel_escritura"),false,false,0,"Text10",null,null)%></td>
                          <td><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Idioma")%></td>
                        </tr>
                        <%}
						%>
                      </table>
				    </td>
                  </tr>
				    <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',this.value)\"")%>
					 <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
					
                  </tr>
                 <%=fb.formEnd(true)%>
                </table>
              </div>
              <%-- ===========================  Tab6  Enfermedad  ===================== --%>
              <div class="dhtmlgoodies_aTab">
                <table width="100%" cellpadding="0" cellspacing="1">
                  <%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("tab","6")%> 
				  <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("anio",anio)%> 
				  <%=fb.hidden("cons",cons)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%> 
				  <%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				  <%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%> 
				  <%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%> 
				  <%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%> 
				  <%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%> 
				  <%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>  
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("cursofSize",""+htcursof.size())%> 
				  <%=fb.hidden("habilidadSize",""+hthabilidad.size())%> 
				  <%=fb.hidden("entrevistaSize",""+htentrevista.size())%> 
				  <%=fb.hidden("idiomaSize",""+htidioma.size())%> 
				  <%=fb.hidden("enfermedadSize",""+htenfermedad.size())%> 
				  <%=fb.hidden("medidadSize",""+htmedida.size())%> 
				  <%=fb.hidden("reconSize",""+htreconocit.size())%> 
				  <%=fb.hidden("parienteSize",""+htpariente.size())%> 
				  <%=fb.hidden("code",code)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Registro de Empleado</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;</td>
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
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus61" style="display:none">+</label><label id="minus61">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel61">
                    <td>
					<table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
                          <td width="5%">Codigo</td>
                          <td width="75%">Enfermedad</td>
                          <td width="15%">Alto Riesgo</td>
                          <td width="5%" align="center"><%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:enfermedadExp()\"","Agregar Enfermedades")%></td>
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
                        <tr class="TextRow01">
                          <td><%=cdo.getColValue("enfermedad")%></td>
                          <td><%=cdo.getColValue("enfermedadName")%></td>
                          <td align="center"><%=fb.checkbox("alto_riesgo"+i,"S",(cdo.getColValue("alto_riesgo") != null && cdo.getColValue("alto_riesgo").trim().equalsIgnoreCase("S")),false)%></td>
                          <td><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Enfermedades")%></td>
                        </tr>
                        <%
							}
							%>
                      </table>
				    </td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
                  <%=fb.formEnd(true)%>
                </table>
              </div>
			  <%-- ===========================  Tab7 Medidas Disciplinarias  ==================== --%>
			   <div class="dhtmlgoodies_aTab">
                <table width="100%" cellpadding="0" cellspacing="1">
                  <%fb = new FormBean("form7",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("tab","7")%> 
				  <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("anio",anio)%> 
				  <%=fb.hidden("cons",cons)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%> 
				  <%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				  <%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%> 
				  <%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%> 
				  <%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%> 
				  <%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%> 
				  <%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>  
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("cursofSize",""+htcursof.size())%> 
				  <%=fb.hidden("habilidadSize",""+hthabilidad.size())%> 
				  <%=fb.hidden("entrevistaSize",""+htentrevista.size())%> 
				  <%=fb.hidden("idiomaSize",""+htidioma.size())%> 
				  <%=fb.hidden("enfermedadSize",""+htenfermedad.size())%> 
				  <%=fb.hidden("medidadSize",""+htmedida.size())%> 
				  <%=fb.hidden("reconSize",""+htreconocit.size())%> 
				  <%=fb.hidden("parienteSize",""+htpariente.size())%> 
				  <%=fb.hidden("code",code)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(70)" style="text-decoration:none; cursor:pointer">
					<table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Registro de Empleado</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus70" style="display:none">+</label><label id="minus70">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel70">
                    <td>
					<table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="15%" align="right">Empleado</td>
                          <td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
                          <td width="15%" align="right">Nombre del Empleado</td>
                          <td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
                        </tr>
                      </table>
				    </td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(71)" style="text-decoration:none; cursor:pointer">
					<table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Medidas Disciplinarias</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                            <label id="plus71" style="display:none">+</label><label id="minus71">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel71">
                    <td>
					<table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
                          <td width="5%">Codigo</td>
                          <td width="5%">Cod. Tipo</td>
						  <td width="20%">Tipo</td>
						  <td width="13%">Fecha</td>
						  <td width="20%">Descripci&oacute;n</td>
						  <td width="12%">Autorizado Por</td>
						  <td width="20%">Motivo</td>
                          <td width="5%" align="center"><%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:medidaExp()\"","Agregar Medidas")%></td>
                        </tr>
                        <%
							String jsp="";
							al=CmnMgr.reverseRecords(htmedida);
							for (int i=1; i<=htmedida.size(); i++)
							{
							key = al.get(i - 1).toString();
							CommonDataObject cdo = (CommonDataObject) htmedida.get(key);
							String fechamed="fechamed"+i;
							%>
                        <%=fb.hidden("key"+i,cdo.getColValue("key"))%> 
						<%=fb.hidden("tipo_med"+i,cdo.getColValue("tipo_med"))%>
						<%=fb.hidden("medidaName"+i,cdo.getColValue("medidaName"))%>
						<%=fb.hidden("remove"+i,"")%>
                        <tr class="TextRow01">
						<td><%=fb.intBox("code"+i,cdo.getColValue("codigo"),false,false,true,2,4,"Text10",null,null)%></td>
						<td><%=cdo.getColValue("tipo_med")%></td>
						<td><%=cdo.getColValue("medidaName")%></td>
						<td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="<%=fechamed%>" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechamed")%>" />
								</jsp:include>
						</td>
						<td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,false,20,2000,"Text10",null,null)%></td>
						<td><%=fb.textBox("autorizado"+i,cdo.getColValue("autorizapo_por"),false,false,false,15,100,"Text10",null,null)%></td>
						<td><%=fb.textBox("motivo"+i,cdo.getColValue("motivo"),true,false,false,20,200,"Text10",null,null)%></td>	
                        <td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Medidas")%></td>
                        </tr>
                        <%
						 jsp += "if(document."+fb.getFormName()+".motivo"+i+".value=='')error--;";
						}
						fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+jsp+"}");	
						%>
                      </table>
				    </td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
				  <%=fb.formEnd(true)%>
                </table>
              </div>
			  
		<%-- ======================= TAB 8 RECONOCIMIENTO ======================= --%>	  
		<div class="dhtmlgoodies_aTab">
                <table width="100%" cellpadding="0" cellspacing="1">
                  <%fb = new FormBean("form8",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("tab","8")%> 
				  <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("anio",anio)%> 
				  <%=fb.hidden("cons",cons)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%> 
				  <%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				  <%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%> 
				  <%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%> 
				  <%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%> 
				  <%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%> 
				  <%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%>  
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("cursofSize",""+htcursof.size())%> 
				  <%=fb.hidden("habilidadSize",""+hthabilidad.size())%> 
				  <%=fb.hidden("entrevistaSize",""+htentrevista.size())%> 
				  <%=fb.hidden("idiomaSize",""+htidioma.size())%> 
				  <%=fb.hidden("enfermedadSize",""+htenfermedad.size())%> 
				  <%=fb.hidden("medidadSize",""+htmedida.size())%> 
				  <%=fb.hidden("reconSize",""+htreconocit.size())%> 
				  <%=fb.hidden("parienteSize",""+htpariente.size())%> 
				  <%=fb.hidden("code",code)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(80)" style="text-decoration:none; cursor:pointer">
					<table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Registro de Empleado</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"> <label id="plus80" style="display:none">+</label><label id="minus80">-</label></font>]&nbsp;</td>
                        </tr>
                      </table>
				    </td>
                  </tr>
                  <tr id="panel80">
                    <td>
						<table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="15%" align="right">Empleado</td>
                          <td width="15%">&nbsp;<%=emple.getColValue("cedula")%></td>
                          <td width="15%" align="right">Nombre del Empleado</td>
                          <td width="55%">&nbsp;<%=emple.getColValue("apellido1")%>,&nbsp;<%=emple.getColValue("nombre1")%> </td>
                        </tr>
                      </table>
				    </td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(81)" style="text-decoration:none; cursor:pointer">
					<table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="95%">&nbsp;Reconocimiento</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus81" style="display:none">+</label><label id="minus81">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel81">
                    <td>
					<table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
                          <td width="5%">Cod.</td>
                          <td width="30%">Descripci&oacute;n</td>
                          <td width="20%">Fecha</td>
                          <td width="20%">Motivo</td>
                          <td width="20%">Comentario</td>
                          <td width="5%" align="center"><%=fb.submit("btnagrega","+",false,false)%></td>	                        </tr>
                        <%	String jsps="";
							al=CmnMgr.reverseRecords(htreconocit);
							for (int i=0; i<htreconocit.size(); i++)
							{
							key = al.get(i).toString();
							CommonDataObject cdo = (CommonDataObject) htreconocit.get(key);
							String fecha="fecha"+i;
							%>
                        <%=fb.hidden("key"+i,key)%> 
						<%//=fb.hidden("key"+i,cdo.getColValue("key"))%> 
						<%=fb.hidden("remove"+i,"")%>
                        <tr class="TextRow01">
                          <td align="center">
						  <%=fb.intBox("code"+i,cdo.getColValue("codigo"),false,false,true,2,2,"Text10",null,null)%>
						  </td>
                          <td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,false,20,100,"Text10",null,null)%></td>
                          <td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="<%=fecha%>" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
								</jsp:include>
						  </td>
						  <td><%=fb.textBox("motivo"+i,cdo.getColValue("motivo"),true,false,false,20,100,"Text10",null,null)%></td>
                          <td><%=fb.textBox("comentario"+i,cdo.getColValue("comentario"),false,false,false,20,100,"Text10",null,null)%></td>
						  <td align="center">
						  <%//=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Reconocimiento")%>
						  <%=fb.submit("remover"+i,"X",false,false)%></td>
                        </tr>
                        <%
						jsps += "if(document."+fb.getFormName()+".motivo"+i+".value=='')error--;";
						}
						fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+jsps+"}");	
						%>
                      </table>
				    </td>
                  </tr>
                  <tr class="TextRow02">
                   <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false)%>	<!--Guardar	-->	
					<%//=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
                  <%=fb.formEnd(true)%>
                </table>
              </div>
 <%-- ======================== TAB9 PARIENTES ======================  --%>
   <div class="dhtmlgoodies_aTab">
			  <table width="100%"  cellpadding="0" cellspacing="1">
			  	<%fb = new FormBean("form9",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                <%=fb.formStart(true)%> 
				<%=fb.hidden("mode",mode)%> 
				<%=fb.hidden("tab","9")%> 
				<%=fb.hidden("prov",prov)%> 
				<%=fb.hidden("sig",sig)%> 
				<%=fb.hidden("tom",tom)%> 
				<%=fb.hidden("asi",asi)%> 
				<%=fb.hidden("anio",anio)%> 
				<%=fb.hidden("cons",cons)%> 
				<%=fb.hidden("baction","")%> 
				<%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%> 
				<%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				<%=fb.hidden("habilidadLastLineNo",""+habilidadLastLineNo)%> 
				<%=fb.hidden("entrenimientoLastLineNo",""+entrenimientoLastLineNo)%>
				<%=fb.hidden("idiomaLastLineNo",""+idiomaLastLineNo)%> 
				<%=fb.hidden("enfermedadLastLineNo",""+enfermedadLastLineNo)%> 
				<%=fb.hidden("medidadLastLineNo",""+medidadLastLineNo)%> 
				<%=fb.hidden("reconocimientoLastLineNo",""+reconocimientoLastLineNo)%> 
				<%=fb.hidden("parienteLastLineNo",""+parienteLastLineNo)%> 
				<%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				<%=fb.hidden("cursofSize",""+htcursof.size())%> 
				<%=fb.hidden("habilidadSize",""+hthabilidad.size())%> 
				<%=fb.hidden("entrevistaSize",""+htentrevista.size())%> 
				<%=fb.hidden("idiomaSize",""+htidioma.size())%> 
				<%=fb.hidden("enfermedadSize",""+htenfermedad.size())%> 
				<%=fb.hidden("medidadSize",""+htmedida.size())%> 
				<%=fb.hidden("reconSize",""+htreconocit.size())%> 
				<%=fb.hidden("parienteSize",""+htpariente.size())%> <%=fb.hidden("code",code)%>
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
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus91" style="display:none">+</label><label id="minus91">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel91">
                    <td>
						<table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
							<td width="5%" rowspan="2">C&oacute;d.</td>
							<td width="20%" rowspan="2">Nombre</td>
							<td width="20%" rowspan="2">Apellido</td>
							<td colspan="2">Parentesco</td>
							<td width="20%" rowspan="2">Cedula</td>
							<td width="5%" rowspan="2">Sexo</td>
							<td width="5%" rowspan="2" align="center"><%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:parienteExp()\"","Agregar Parientes")%></td>
						</tr>
                        <tr class="TextHeader" align="center">
							<td width="5%">Cod.</td>
							<td width="20%">Descripci&oacute;n.</td>
						</tr>
						<%
						System.out.println("******************************FORM1 htpariente.size ="+htpariente.size());		
						String jpss="";	
						
						al=CmnMgr.reverseRecords(htpariente);
						for (int i=1; i<=htpariente.size(); i++)
						{
						key = al.get(i - 1).toString();	
						CommonDataObject cdo = (CommonDataObject) htpariente.get(key);
						String fecha_nacimiento="fecha_nacimiento"+i;
						String fecha_fallecimiento="fecha_fallecimiento"+i;
						String color = "";
						if (i%2 == 0) color = "TextRow02";
						else color = "TextRow01";
						%>
						<%System.out.println("******************************FORM1 CYCLE WHEN i ="+i+" AND KEY = "+cdo.getColValue("key"));%>
						<%
						cdo.addColValue("emp_sigla","00");
						%>
						 <%=fb.hidden("key"+i,cdo.getColValue("key"))%> 
						<%=fb.hidden("parentesco"+i,cdo.getColValue("parentesco"))%>
						<%=fb.hidden("parentescoName"+i,cdo.getColValue("parentescoName"))%>
						<%=fb.hidden("remove"+i,"")%>
						<tr class="<%=color%>">
							<td align="center"><%=fb.intBox("code"+i,cdo.getColValue("codigo"),false,false,true,1,2,"Text10",null,null)%></td>
							<td align="center"><%=fb.textBox("namepariente"+i,cdo.getColValue("nombre"),true,false,false,30,30,"Text10",null,null)%></td>
							<td align="center"><%=fb.textBox("apellidopariente"+i,cdo.getColValue("apellido"),true,false,false,30,30,"Text10",null,null)%></td>
							<td align="center"><%=cdo.getColValue("parentesco")%></td>
							<td align="center"><%=cdo.getColValue("parentescoName")%></td>
							<td align="center"><%=fb.intBox("emp_provincia"+i,cdo.getColValue("emp_provincia"),true,false,false,1,2,"Text10",null,null)%>
								<%=fb.textBox("emp_sigla"+i,cdo.getColValue("emp_sigla"),true,false,false,1,2,"Text10",null,null)%>
								<%=fb.intBox("emp_tomo"+i,cdo.getColValue("emp_tomo"),true,false,false,2,4,"Text10",null,null)%>
								<%=fb.intBox("emp_asiento"+i,cdo.getColValue("emp_asiento"),true,false,false,3,5,"Text10",null,null)%>							</td>
							<td align="center"><%=fb.select("sexo"+i,"M,F",cdo.getColValue("sexo"),false,false,0,"Text10",null,null)%></td>
							<td rowspan="2" align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Pariente")%></td>
						</tr>
						<tr class="<%=color%>">
							<td colspan="3">
							Beneficiario&nbsp;
							<%=fb.checkbox("beneficiario"+i,"S",(cdo.getColValue("beneficiario") != null && cdo.getColValue("beneficiario").trim().equalsIgnoreCase("S")),false)%>
							&nbsp;&nbsp;
							Dependiente
							<%=fb.checkbox("dependiente"+i,"S",(cdo.getColValue("dependiente") != null && cdo.getColValue("dependiente").trim().equalsIgnoreCase("S")),false)%>&nbsp;&nbsp;
							Vive con Emp.?&nbsp;
							<%=fb.checkbox("vive_con_empleado"+i,"S",(cdo.getColValue("vive_con_empleado") != null && cdo.getColValue("vive_con_empleado").trim().equalsIgnoreCase("S")),false)%>
							<br>
							Invalido  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%=fb.checkbox("invalido"+i,"S",(cdo.getColValue("invalido") != null && cdo.getColValue("invalido").trim().equalsIgnoreCase("S")),false)%>
							&nbsp;&nbsp;
							Fecha Nac.
							&nbsp;&nbsp;&nbsp;&nbsp;
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="<%=fecha_nacimiento%>" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_nacimiento")%>" />
							</jsp:include>
							<br>
							Vive?  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%=fb.checkbox("vive"+i,"S",(cdo.getColValue("vive") != null && cdo.getColValue("vive").trim().equalsIgnoreCase("S")),false)%>
							&nbsp;&nbsp;
							Fecha Fallec.&nbsp;&nbsp;
							<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="<%=fecha_fallecimiento%>" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_fallecimiento")%>" />
								</jsp:include>							</td>
							<td colspan="4">
							Estudia
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%=fb.checkbox("estudia"+i,"S",(cdo.getColValue("estudia") != null && cdo.getColValue("estudia").trim().equalsIgnoreCase("S")),false)%>
							&nbsp;&nbsp;
							Trabaja
							<%=fb.checkbox("trabaja"+i,"S",(cdo.getColValue("trabaja") != null && cdo.getColValue("trabaja").trim().equalsIgnoreCase("S")),false)%>&nbsp;&nbsp;
							Protegido x Riesgo Prof.&nbsp;
							<%=fb.checkbox("proteg_por_riesgo"+i,"S",(cdo.getColValue("proteg_por_riesgo") != null && cdo.getColValue("proteg_por_riesgo").trim().equalsIgnoreCase("S")),false)%>
							<br>
							Lugar de Trabajo&nbsp;
							<%=fb.textBox("lugar_trabajo"+i,cdo.getColValue("lugar_trabajo"),false,false,false,50,100,"Text10",null,null)%>
							<br>
							Tel&eacute;fono
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%=fb.textBox("telefono_trabajo"+i,cdo.getColValue("telefono_trabajo"),false,false,false,15,11,"Text10",null,null)%></td>
						</tr>
						<%
						jpss += "if(document."+fb.getFormName()+".codigo"+i+".value=='')error--;";
						jpss += "if(document."+fb.getFormName()+".nombre"+i+".value=='')error--;";
						jpss += "if(document."+fb.getFormName()+".emp_provincia"+i+".value=='')error--;";
						jpss += "if(document."+fb.getFormName()+".emp_sigla"+i+".value=='')error--;";
						jpss += "if(document."+fb.getFormName()+".emp_tomo"+i+".value=='')error--;";
						jpss += "if(document."+fb.getFormName()+".emp_asiento"+i+".value=='')error--;";
						}
						fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+jpss+"}");		
						%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
						
			  <%=fb.formEnd(true)%>
			  </table>
			  </div>
            </div>
            <script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Solicitante'),0,'100%','');
<%
}
else
{
%>
//initTabs('dhtmlgoodies_tabView1',Array('Solicitante'),0,'100%','');
initTabs('dhtmlgoodies_tabView1',Array('Solicitante','Educación','Salud','Habilidades','Entretenimiento','Idioma','Enfermedades','Medidas Disciplinarias','Reconocimientos','Parientes'),<%=tab%>,'100%','');
<%
}
%>
</script>
          </td>
        </tr>
       </table>
	</td>
  </tr>
</table>
<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
}//GET 
else
{ 
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	id=request.getParameter("id");
	prov = request.getParameter("prov");
	sig  = request.getParameter("sig"); 
	tom  = request.getParameter("tom"); 
	asi  = request.getParameter("asi");
	anio = request.getParameter("anio");
	cons = request.getParameter("cons");
	mode = request.getParameter("mode");
	code = request.getParameter("code");
		
	if(tab.equals("0")) //Generales de Empleado
	{
   	 
	 Hashtable ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("fotosimages"),20);
	 saveOption = (String) ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
		baction = (String) ht.get("baction");
		id = (String) ht.get("id");
		mode = (String) ht.get("mode");
		code = (String) ht.get("code");
		prov = (String) ht.get("prov");
		sig  = (String) ht.get("sig"); 
		tom  = (String) ht.get("tom"); 
		asi  = (String) ht.get("asi");
	 	anio = (String) ht.get("anio");
		cons = (String) ht.get("cons");
		
	  emple = new CommonDataObject();
	  emple.setTableName("tbl_pla_solicitante");	    
	 
	
	  emple.addColValue("PRIMER_NOMBRE", (String) ht.get("nombre1")); 
	  emple.addColValue("SEGUNDO_NOMBRE",(String) ht.get("nombre2"));	
	  if((String) ht.get("apellido1")!= null)
	  emple.addColValue("PRIMER_APELLIDO",(String) ht.get("apellido1"));
	  if((String) ht.get("apellido2")!= null)
	  emple.addColValue("SEGUNDO_APELLIDO",(String) ht.get("apellido2"));	  
	    
	  emple.addColValue("APELLIDO_CASADA",(String) ht.get("casada")); 
	  if((String) ht.get("cargo1")!= null)
	  emple.addColValue("EMPLEO_SOLICITA1",(String) ht.get("cargo1"));	  
	  if((String) ht.get("cargo2")!= null)	  
	  emple.addColValue("EMPLEO_SOLICITA2",(String) ht.get("cargo2")); 
	  if((String) ht.get("cargo3")!= null)	  
	  emple.addColValue("EMPLEO_SOLICITA3",(String) ht.get("cargo3"));
	  
	  if((String) ht.get("salario")!= null)	  
	  emple.addColValue("SALARIO_DESEADO",(String) ht.get("salario"));  
	  if((String) ht.get("lugarpref")!= null)	  
	  emple.addColValue("LUGAR_PREFIERE",(String) ht.get("lugarpref")); 
	  	  emple.addColValue("FECHA_SOLICITUD",(String) ht.get("fechasol"));
	   if((String) ht.get("nacionalidadCode")!=null)
	  emple.addColValue("NACIONALIDAD",(String) ht.get("nacionalidadCode")); 
	  if ((String) ht.get("lugar_nacimiento") != null)	
      emple.addColValue("LUGAR_NACIMIENTO",(String) ht.get("lugar_nacimiento"));
	  if ((String) ht.get("dependiente") != null)	
      emple.addColValue("DEPENDIENTES",(String) ht.get("dependiente"));
	  emple.addColValue("FECHA_NACIMIENTO",(String) ht.get("fechanac")); 
	  emple.addColValue("SEXO",(String) ht.get("sexo")); 	  
	  emple.addColValue("ESTADO_CIVIL",(String) ht.get("civil"));  
	  if ((String) ht.get("direccion") != null)	
	  emple.addColValue("DIRECCION",(String) ht.get("direccion"));
	  if((String) ht.get("telcasa") != null)
	  emple.addColValue("TELEFONO",(String) ht.get("telcasa"));
	  if((String) ht.get("telotros")!=null)  
  	  emple.addColValue("TELEFONO_OFICINA",(String) ht.get("telotros"));
	  if((String) ht.get("tellugar")!= null)
      emple.addColValue("TELEFONO_CELULAR",(String) ht.get("tellugar")); 
	  if((String) ht.get("seguro")!= null)
	  emple.addColValue("SEGURO_SOCIAL",(String) ht.get("seguro"));
	  if ((String) ht.get("peso") != null)	
  	  emple.addColValue("PESO",(String) ht.get("peso"));
	  if ((String) ht.get("estatura") != null)	
  	  emple.addColValue("ESTATURA",(String) ht.get("estatura"));
	  if((String) ht.get("sang")!=null)
	  emple.addColValue("TIPO_SANGRE",(String) ht.get("sang")); 
	  if((String) ht.get("zona")!= null)  
	  emple.addColValue("ZONA",(String) ht.get("zona"));
	  if((String) ht.get("apartado")!=null)  
      emple.addColValue("APARTADO",(String) ht.get("apartado"));	
	  if((String) ht.get("email")!= null)
	  emple.addColValue("EMAIL",(String) ht.get("email")); 
	  if((String) ht.get("foto")!= null)
	  emple.addColValue("FOTO",(String) ht.get("foto")); 
	
	  if((String) ht.get("conyuge")!= null)
	  emple.addColValue("NOMBRE_CONYUGE",(String) ht.get("conyuge")); 
	  if((String) ht.get("nacconyuge")!= null)
	  emple.addColValue("FNAC_CONYUGE",(String) ht.get("nacconyuge"));
	  if((String) ht.get("ocuconyuge")!= null)
	  emple.addColValue("LUGAR_TRABCONYUGE",(String) ht.get("ocuconyuge"));
	  if((String) ht.get("traconyuge")!= null)
	  emple.addColValue("PROFESION_CONYUGE",(String) ht.get("traconyuge")); 
	  if((String) ht.get("madre")!=null)
	  emple.addColValue("NOMBRE_MADRE",(String) ht.get("madre"));
	  if((String) ht.get("padre")!=null)
      emple.addColValue("NOMBRE_PADRE",(String) ht.get("padre"));
	   if((String) ht.get("nacpadre")!= null)
	  emple.addColValue("FNAC_PADRE",(String) ht.get("nacpadre"));
	  if ((String) ht.get("vivemadre") == null) emple.addColValue("VIVE_MADRE","N"); 
	  else emple.addColValue("VIVE_MADRE",(String) ht.get("vivemadre"));
	  if ((String) ht.get("vivepadre") == null) emple.addColValue("VIVE_PADRE","N"); 
	  else emple.addColValue("VIVE_PADRE",(String) ht.get("vivepadre")); 
	   if((String) ht.get("nacmadre")!= null)
	  emple.addColValue("FNAC_MADRE",(String) ht.get("nacmadre"));
	  if((String) ht.get("parentezco_fam")!= null)
	  emple.addColValue("parentezco_fam",(String) ht.get("parentezco_fam"));
	  if((String) ht.get("ocumadre")!= null)
	  emple.addColValue("OCUPACION_MADRE",(String) ht.get("ocumadre"));
	  if((String) ht.get("tramadre")!= null)
	  emple.addColValue("LUGAR_TRABAJO_MADRE",(String) ht.get("tramadre")); 
	  if((String) ht.get("nacpadre")!= null)
	  
	  if ((String) ht.get("familiar_cia") != null)	
	 emple.addColValue("familiar_cia",(String) ht.get("familiar_cia")); 
	  if ((String) ht.get("ocupacion_fam") != null)	
	 emple.addColValue("ocupacion_fam",(String) ht.get("ocupacion_fam")); 
	  if ((String) ht.get("depto_fam") != null)	
	 emple.addColValue("depto_fam",(String) ht.get("depto_fam")); 
	  if ((String) ht.get("nombre_fam") != null)	
	 emple.addColValue("nombre_fam",(String) ht.get("nombre_fam")); 
	 // emple.addColValue("FNAC_PADRE",(String) ht.get("nacpadre"));
	
	  if((String) ht.get("ocupadre")!= null)
	  emple.addColValue("OCUPACION_PADRE",(String) ht.get("ocupadre"));
	  if((String) ht.get("trapadre")!= null)
	  emple.addColValue("LUGAR_TRABAJO_PADRE",(String) ht.get("trapadre")); 
	  if ((String) ht.get("conducir") == null) emple.addColValue("LICENCIA_CONDUCIR","N"); 
	  else emple.addColValue("LICENCIA_CONDUCIR",(String) ht.get("conducir"));
	  if((String) ht.get("licencia")!=null)
      emple.addColValue("TIPO_LICENCIA",(String) ht.get("licencia"));
	  if((String) ht.get("nlicencia")!=null)	
	  emple.addColValue("NUMERO_LICENCIA",(String) ht.get("nlicencia"));
	  if ((String) ht.get("sangre") != null)
	  emple.addColValue("RH",(String) ht.get("sangre"));
	  if((String) ht.get("urgllamar")!=null)
	 emple.addColValue("URGENCIA_LLAMAR_A",(String) ht.get("urgllamar"));  
	   if((String) ht.get("urgCode")!=null)
	 emple.addColValue("URGENCIA_PARENTESCO",(String) ht.get("urgCode")); 
	   if((String) ht.get("telurg")!=null)
	 emple.addColValue("URGENCIA_TELEFONO",(String) ht.get("telurg")); 
	  if((String) ht.get("celurg")!=null)
	 emple.addColValue("URGENCIA_CELULAR",(String) ht.get("celurg")); 
	 if ((String) ht.get("provinciaC") != null)	
	 emple.addColValue("PROVINCIA_DIR",(String) ht.get("provinciaC"));
	 if ((String) ht.get("paisC") != null)	
	 emple.addColValue("PAIS_DIR",(String) ht.get("paisC")); 
	 if ((String) ht.get("corregimientoC") != null)	
	 emple.addColValue("CORREGIMIENTO_DIR",(String) ht.get("corregimientoC"));  
	 if ((String) ht.get("distritoC") != null)	
	 emple.addColValue("DISTRITO_DIR",(String) ht.get("distritoC"));
	 if ((String) ht.get("comunidadC") != null)	
	 emple.addColValue("COMUNIDAD_DIR",(String) ht.get("comunidadC")); 
	 emple.addColValue("ANIO",(String) ht.get("anio")); 	 
	  emple.addColValue("compania",(String) session.getAttribute("_companyId"));
	 
		
	//ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  { 
		
		emple.addColValue("provincia",(String) ht.get("provincia"));
		emple.addColValue("sigla",(String) ht.get("sigla"));
		emple.addColValue("tomo",(String) ht.get("tomo"));	
		emple.addColValue("asiento",(String) ht.get("asiento"));	
		emple.addColValue("anio",(String) ht.get("anio")); 
		//emple.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 	
		//emple.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));	
		emple.addColValue("consecutivo","(SELECT nvl(max(CONSECUTIVO),0)+1 FROM tbl_pla_solicitante)");
		emple.setAutoIncCol("consecutivo");  
		
		SQLMgr.insert(emple);
		prov = (String) ht.get("provincia");
		sig  = (String) ht.get("sigla"); 
		tom  = (String) ht.get("tomo"); 
		asi  = (String) ht.get("asiento");
		
	}
  else
  {
    
		emple.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia ="+prov+" and sigla ='"+sig+"' and tomo ="+tom+" and asiento ="+asi+" and consecutivo ="+id);
	
		SQLMgr.update(emple);
  }
	ConMgr.clearAppCtx(null);
}//End Tab de Generales de Empleado


//  ==============================   TAB1 EDUCACION 	===============================
	else if(tab.equals("1"))
	{
		int  size=0;
		if(request.getParameter("educacionSize")!=null)
		size= Integer.parseInt(request.getParameter("educacionSize"));
		
		String itemRemoved = "";
		id=request.getParameter("id");
		prov = request.getParameter("prov");
		sig  = request.getParameter("sig"); 
		tom  = request.getParameter("tom"); 
		asi  = request.getParameter("asi");
		anio = request.getParameter("anio");
		cons = request.getParameter("cons");
		mode = request.getParameter("mode");
		code = request.getParameter("code");
		al.clear();
		
		for(int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_educacion_soli"); 
			cdo.setWhereClause("sol_anio="+anio+" and sol_consecutivo = "+cons);

			//cdo.addColValue("codigo",request.getParameter("codigo"+i));
			cdo.addColValue("sol_anio",request.getParameter("sol_anio"));
			cdo.addColValue("sol_consecutivo",request.getParameter("sol_consecutivo"));

			cdo.addColValue("tipo_educacion",request.getParameter("tipo"+i));
			cdo.addColValue("certificado_obt",request.getParameter("certificado_obt"+i));
			cdo.addColValue("centro_educativo",request.getParameter("centro_educativo"+i));
			cdo.addColValue("fecha_inicio",request.getParameter("fecha_inicio"+i));
			cdo.addColValue("fecha_final",request.getParameter("fecha_final"+i));
			cdo.addColValue("carrera","");
			cdo.addColValue("termino",(request.getParameter("termino"+i)== null)?"N":"S");
			cdo.addColValue("anio_cursado",request.getParameter("anio_cursado"+i));
			cdo.addColValue("key",request.getParameter("key"+i));
			cdo.setAutoIncWhereClause("sol_anio="+anio+" and sol_consecutivo = "+cons+"");
			cdo.setAutoIncCol("codigo");
			
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
			itemRemoved = cdo.getColValue("key");
			else 
			{
				try
				{
				hteducacion.put(cdo.getColValue("key"),cdo);
				al.add(cdo);
				}//end try
				
				catch (Exception e)
				{
				System.err.println(e.getMessage());
				}//end Catch
				
				}//End else
		}//End For
		
		if (!itemRemoved.equals(""))
		
		{
		vcteducacion.remove(((CommonDataObject) hteducacion.get(itemRemoved)).getColValue("tipo"));
		hteducacion.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&anio="+anio+"&cons="+cons+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo);
    	return;
		}//End remover
		
		if (al.size() == 0)
		{
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_pla_educacion_soli");
		cdo.setWhereClause("sol_anio="+anio+" and sol_consecutivo = "+cons);

		al.add(cdo);
		}//end al.size
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}//End Tab1 de Educación


//  ==============================  TAB5 IDIOMA  =============================
	else if(tab.equals("5"))
	{
	int size=0;
	if(request.getParameter("idiomaSize")!=null)
	size=Integer.parseInt(request.getParameter("idiomaSize"));
	String itemRemoved = "";
		id=request.getParameter("id");
		prov = request.getParameter("prov");
		sig  = request.getParameter("sig"); 
		tom  = request.getParameter("tom"); 
		asi  = request.getParameter("asi");
		anio = request.getParameter("anio");
		cons = request.getParameter("cons");
		mode = request.getParameter("mode");
		code = request.getParameter("code");
	al.clear();
	for(int i=1; i<=size; i++)
	{
	CommonDataObject cdo = new CommonDataObject();
	cdo.setTableName("tbl_pla_idioma_soli");
	cdo.setWhereClause("anio="+anio+" and consecutivo = "+cons);
	
	cdo.addColValue("anio",anio);
	cdo.addColValue("consecutivo",cons);
	
	cdo.addColValue("idioma", request.getParameter("idioma"+i));
	cdo.addColValue("nivel_conversacion", request.getParameter("nivel_conversacion"+i));	
	cdo.addColValue("nivel_lectura", request.getParameter("nivel_lectura"+i));
	cdo.addColValue("nivel_escritura", request.getParameter("nivel_escritura"+i));
	cdo.addColValue("key",request.getParameter("key"+i));
	
	if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
	itemRemoved = cdo.getColValue("key");  
		else 
		{
			try
			{
			 htidioma.put(cdo.getColValue("key"),cdo); 
			 al.add(cdo); 
			}
			catch(Exception e)
			{
			System.err.println(e.getMessage());
			}
		}		
	}//End For

	if (!itemRemoved.equals(""))
		{
		vctidioma.remove(((CommonDataObject) htidioma.get(itemRemoved)).getColValue("idioma"));
    	htidioma.remove(itemRemoved);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&anio="+anio+"&cons="+cons+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo);
    	return;
		}
		
	if (baction != null && baction.equals("+"))
		{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&anio="+anio+"&cons="+cons+"&educaLastLineNo="+educaLastLineNo+"&cursoLastLineNo="+cursoLastLineNo+"&habilidadLastLineNo="+habilidadLastLineNo+"&entrenimientoLastLineNo="+entrenimientoLastLineNo+"&idiomaLastLineNo="+idiomaLastLineNo+"&enfermedadLastLineNo="+enfermedadLastLineNo+"&medidadLastLineNo="+medidadLastLineNo+"&reconocimientoLastLineNo="+reconocimientoLastLineNo+"&parienteLastLineNo="+parienteLastLineNo);
	
    	return;
		}
		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_pla_idioma_soli");  
			cdo.setWhereClause("anio="+anio+" and consecutivo = "+cons);

			al.add(cdo); 
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}//End tab 5

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/solicitud_empleado_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/solicitud_empleado_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/solicitud_empleado_list.jsp';
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&anio=<%=anio%>&cons=<%=cons%>&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
