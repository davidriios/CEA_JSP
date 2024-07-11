<%@ page errorPage="../errorpage.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr" />

<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

	String pacId = request.getParameter("pacId");
	String noAdmision = request.getParameter("noAdmision");
	String sql = "";
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
	Admision adm = new Admision();
	Company com= new Company ();
	ArrayList list   = new ArrayList();
	ArrayList al = new ArrayList();
	ArrayList alDiagI = new ArrayList();
	ArrayList alDiagE = new ArrayList();
	ArrayList alDoc = new ArrayList();
	ArrayList alBenef = new ArrayList();
	ArrayList alRespon = new ArrayList();


//	if(request.getParameter("noAdmision")!=null	{	noAdmision=request.getParameter("noAdmision");}
//if (request.getParameter("pacId")!=null){	pacId= request.getParameter("pacId"); }

//----------------------------------------------- Company ---------------------------
sql="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1 from TBL_SEC_COMPANIA where codigo="+(String) session.getAttribute("_companyId");
com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);

//---------------------------------------------    Tab General   ------------------------------------------------
sql="Select b.sexo,/*to_number(to_char(sysdate,'YYYY')) - to_number(to_char(a.fecha_nacimiento,'YYYY')) as paseK, */
MONTHS_BETWEEN(sysdate,a.fecha_nacimiento)/12 as paseK,to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento , a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fechaIngreso, decode(a.dias_estimados,null,' ',a.dias_estimados) as diasEstimados, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, to_char(nvl(a.fecha_preadmision,sysdate),'dd/mm/yyyy hh12:mi:ss am') as fechaPreadmision, a.categoria, a.tipo_admision as tipoAdmision, a.medico, a.usuario_creacion as usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, to_char(nvl(a.am_pm,sysdate),'hh12:mi:ss am') as amPm, nvl(a.tipo_cta,' ') as tipoCta, a.conta_cred as contaCred, decode(a.provincia,null,' ',a.provincia) as provincia, DECODE(b.nacionalidad, null,' ',(SELECT NACIONALIDAD FROM tbl_sec_pais WHERE CODIGO=b.nacionalidad)) as nacionalidad, decode(b.zona_postal,null,' ',b.zona_postal) as zonaPostal, decode(b.apartado_postal,null,' ',b.apartado_postal) as apartadoPostal, decode(b.residencia_direccion,null,' ',b.residencia_direccion) as direccion, decode(b.telefono,null,' ',b.telefono) as telefonoResidencia, decode(b.lugar_nacimiento,null,' ',b.lugar_nacimiento) as lugarNac, decode(b.telefono_urgencia,null,' ',b.telefono_urgencia) as comunidad , decode(b.lugar_trabajo,null, ' ',b.lugar_trabajo) as lugarDeTrabajo, decode(b.PERSONA_DE_URGENCIA,null,' ',b.PERSONA_DE_URGENCIA) as parentesco, decode(b.extension_oficina,null,' ',b.extension_oficina) as extension, decode(b.telefono_trabajo_urgencia,null,' ',b.telefono_trabajo_urgencia) as telefonoDeTrabajo, decode(b.fax,null,' ',b.fax) as fax, DECODE(b.religion,0,' ',(SELECT DESCRIPCION from TBL_ADM_RELIGION where codigo=b.religion)) as cama, nvl(a.sigla,' ') as sigla, decode(a.tomo,null,' ',a.tomo) as tomo, decode(a.asiento,null,' ',a.asiento) as asiento, nvl(a.d_cedula,' ') as dCedula, nvl(a.pasaporte,' ') as pasaporte, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.pac_id as pacId, a.responsabilidad, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombrePaciente, c.descripcion as categoriaDesc, d.descripcion as tipoAdmisionDesc, e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' '||e.apellido_de_casada)) as nombreMedico, e.especialidad, decode(f.primer_nombre,null,' ',f.primer_nombre||decode(f.segundo_nombre,null,'',' '||f.segundo_nombre)||' '||f.primer_apellido||decode(f.segundo_apellido,null,'',' '||f.segundo_apellido)||decode(f.sexo,'F',decode(f.apellido_de_casada,null,'',' '||f.apellido_de_casada))) as nombreMedicoCabecera, g.descripcion as centroServicioDesc from tbl_adm_admision a, tbl_adm_paciente b, tbl_adm_categoria_admision c, tbl_adm_tipo_admision_cia d, (select x.codigo, x.primer_nombre, x.segundo_nombre, x.primer_apellido, x.segundo_apellido, x.apellido_de_casada, x.sexo, nvl(z.descripcion,'NO TIENE') as especialidad from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) e, tbl_adm_medico f, tbl_cds_centro_servicio g where a.pac_id=b.pac_id and a.categoria=c.codigo and a.categoria=d.categoria and a.tipo_admision=d.codigo and a.compania=d.compania and a.medico=e.codigo and a.medico_cabecera=f.codigo(+) and a.centro_servicio=g.codigo and a.compania="+(String) session.getAttribute("_companyId")+" and a.pac_id="+pacId+" and a.secuencia="+noAdmision;
//System.out.println("\n\n\n"+sql+"\n\n\n");
		adm = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Admision.class);

//------------------------------------------- Tab Habilitaciones y Cama  ---------------------------------------------------
			sql = "select a.codigo, a.cama, a.habitacion, to_char(a.fecha_inicio,'dd/mm/yyyy') as fechaInicio, to_char(a.hora_inicio,'hh12:mi am') as horaInicio, nvl(a.precio_alt,'N') as precioAlt, a.precio_alterno as precioAlterno, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, c.unidad_admin as centroServicio, d.descripcion as centroServicioDesc, e.precio, e.descripcion||' - '||decode(e.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','O','OTROS','E','ECONOMICA','T','SUITE','Q','QUIROFANO','C','COMPARTIDA') as habitacionDesc from tbl_adm_cama_admision a, tbl_sal_cama b, tbl_sal_habitacion c, tbl_cds_centro_servicio d, tbl_sal_tipo_habitacion e where a.compania=b.compania and a.habitacion=b.habitacion and a.cama=b.codigo and a.compania=c.compania and a.habitacion=c.codigo and c.unidad_admin=d.codigo and a.compania=e.compania and b.tipo_hab=e.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" order by a.codigo";
			System.out.println("SQL:\n"+sql);
			al  = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);



//---------------------------------------------   Tab de Diagnostico   ------------------------------------------------------


	sql = "select a.diagnostico, a.tipo, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.orden_diag as ordenDiag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.tipo='I' and a.admision="+noAdmision+" and a.pac_id="+pacId+" order by a.orden_diag";
	System.out.println("SQL:\n"+sql);
	alDiagI  = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);

	sql = "select a.diagnostico, a.tipo, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.orden_diag as ordenDiag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.tipo='S' and a.admision="+noAdmision+" and a.pac_id="+pacId+" order by a.orden_diag";
	System.out.println("SQL:\n"+sql);
	alDiagE  = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);



// -------------------------------------------- Tab de Beneficios  ---------------------------------------------------------
			sql = "select a.secuencia, a.poliza, nvl(a.certificado,' ') as certificado, nvl(a.convenio_solicitud,'C') as convenioSolicitud, nvl(a.convenio_sol_emp,'N') as convenioSolEmp, prioridad, decode(a.plan,null,' ',a.plan) as plan, decode(a.convenio,null,' ',a.convenio) as convenio, a.empresa, decode(a.categoria_admi,null,' ',a.categoria_admi) as categoriaAdmi, decode(a.tipo_admi,null,' ',a.tipo_admi) as tipoAdmi, decode(a.clasif_admi,null,' ',a.clasif_admi) as clasifAdmi, decode(a.tipo_poliza,null,' ',a.tipo_poliza) as tipoPoliza, decode(a.tipo_plan,null,' ',a.tipo_plan) as tipoPlan, to_char(nvl(a.fecha_ini,sysdate),'dd/mm/yyyy hh24:mi:ss') as fechaIni, nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaFin, nvl(a.usuario_creacion,' ') as usuarioCreacion, nvl(a.usuario_modificacion,' ') as usuarioModificacion, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaCreacion, nvl(to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaModificacion, nvl(a.estado,' ') as estado, decode(a.num_aprobacion,null,' ',a.num_aprobacion) as numAprobacion, b.tipo_poliza as tipoPoliza, b.tipo_plan as tipoPlan, b.nombre as nombrePlan, c.nombre as nombreConvenio, d.nombre as nombreEmpresa, e.nombre as nombreTipoPlan, f.nombre as nombreTipoPoliza, g.descripcion as clasifAdmiDesc, h.descripcion as tipoAdmiDesc, i.descripcion as categoriaAdmiDesc from tbl_adm_beneficios_x_admision a, tbl_adm_plan_convenio b, tbl_adm_convenio c, tbl_adm_empresa d, tbl_adm_tipo_plan e, tbl_adm_tipo_poliza f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_tipo_admision_cia h, tbl_adm_categoria_admision i where a.empresa=b.empresa and a.convenio=b.convenio and a.plan=b.secuencia and b.empresa=c.empresa and b.convenio=c.secuencia and c.empresa=d.codigo and b.tipo_plan=e.tipo_plan and b.tipo_poliza=e.poliza and b.tipo_poliza=f.codigo and a.categoria_admi=g.categoria and a.tipo_admi=g.tipo and a.clasif_admi=g.codigo and g.categoria=h.categoria and g.tipo=h.codigo and h.categoria=i.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" order by a.secuencia, a.prioridad, a.empresa, a.convenio, a.plan, a.categoria_admi, a.tipo_admi, a.clasif_admi";
	System.out.println("SQL:\n"+sql);
	alBenef  = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);


if(request.getMethod().equalsIgnoreCase("GET")) {

		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		else {


//***************//GENERAL HEADER END HERE



//Begin de Diagnostico de Ingreso
//End de Diagnostico de Ingreso

//Begin Diagnostico de Egreso



					//MAIN FOOTER END HERE
//***************//

				pc.close();
				response.sendRedirect(redirectFile);
			}//folder created
		}//get


//} else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
//} else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>