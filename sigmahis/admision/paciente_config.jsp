<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.HL7"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<%
/**
==================================================================================
ADM60096
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

boolean isFpEnabled = CmnMgr.isValidFpType("PAC");
ArrayList al = new ArrayList();
ArrayList alDoc =  new ArrayList();
StringBuffer sbSql = new StringBuffer();
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String identificacion = request.getParameter("identificacion");
String popWinFunction = "abrir_ventana1";
String tipoHuella = request.getParameter("tipo");
String catAdm = request.getParameter("cat_adm");
String context = request.getParameter("context");
String  correoReq= "N";
String  usaPlanMedico= "N";
try {correoReq =java.util.ResourceBundle.getBundle("issi").getString("correoReq");}catch(Exception e){ correoReq = "N";}
try {usaPlanMedico =java.util.ResourceBundle.getBundle("planmedico").getString("usaPlanMedico");}catch(Exception e){ usaPlanMedico = "N";}
int hasHuella = 0;

String tabFunctions = "'4=tabFunctions(4)'";
if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (!mode.equalsIgnoreCase("add") && !mode.equalsIgnoreCase("edit")) viewMode = true;
if (fp == null) fp = "";
if (fg == null) fg = "";
if (fp.equalsIgnoreCase("admision")) popWinFunction = "abrir_ventana3";
if (tipoHuella == null ) tipoHuella = "ADM";
if (catAdm == null ) catAdm = "";
if (context == null ) context = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql.append("select nvl(get_sec_comp_param(-1,'ADM_PATIENT_REFCODE_LABEL'),'C&oacute;d. Referencia:') as refCodeLabel, get_sec_comp_param(").append(session.getAttribute("_companyId")).append(",'ADM_PAC_CAMPOS_REQ') as camposReq, get_sec_comp_param(").append(session.getAttribute("_companyId")).append(",'CAMPO_PAC_REQ_UBIC_GEO') as camposReqUbicGeo, get_sec_comp_param(").append(session.getAttribute("_companyId")).append(",'ADM_COD_PAIS_PANAMA') as codNac, nvl(get_sec_comp_param(").append(session.getAttribute("_companyId")).append(",'ADM_EDAD_JUB_F'),0) as edad_jub_mujeres, nvl(get_sec_comp_param(").append(session.getAttribute("_companyId")).append(",'ADM_EDAD_JUB_M'),0) as edad_jub_varones, nvl(get_sec_comp_param(").append(session.getAttribute("_companyId")).append(",'ADM_PAC_TEL_REQ'),'N') as telReq from dual");
	CommonDataObject cdox = SQLMgr.getData(sbSql.toString());

	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("codigo","0");
		cdo.addColValue("fechaNaci","");
		cdo.addColValue("fechaFallece","");
		cdo.addColValue("fechaCorrec","");

		cdo.addColValue("provincia","");
		cdo.addColValue("sigla","");
		cdo.addColValue("tomo","");
		cdo.addColValue("asiento","");
		cdo.addColValue("pasaporte","");
		cdo.addColValue("d_cedula","");
		if(fg.equals("load_from_pm") && !identificacion.equals("")){
			sbSql = new StringBuffer();
			sbSql.append("select '' deseo, '' preferencia, a.tipo_id_paciente as tipoid, a.provincia, a.sigla, a.tomo, a.asiento, a.d_cedula, a.pasaporte, to_char (nvl (a.f_nac, a.fecha_nacimiento), 'dd/mm/yyyy') as fechanaci, a.codigo, a.primer_nombre as primernom, a.estado_civil as estadocivil, a.segundo_nombre as segundonom, a.sexo, a.primer_apellido as primerapell, '' ingreso_men, a.segundo_apellido as segundoapell, a.apellido_de_casada as casadaapell, a.seguro_social as seguro, a.tipo_sangre as tiposangre, '' nh, a.numero_de_hijos as hijo, a.vip, a.lugar_nacimiento as lugarnaci, a.nacionalidad as nacionalcode, b.nacionalidad as nacional, a.religion as religioncode, c.descripcion as religion, a.estatus, a.fallecido, a.nombre_padre as nompadre, a.nombre_madre as nommadre, a.datos_correctos as datoscorrec, to_char (a.fecha_fallecido, 'dd/mm/yyyy') as fechafallece, to_char (nvl (a.f_nac, fecha_nacimiento), 'dd/mm/yyyy') as fechacorrec, to_char (a.f_nac, 'dd/mm/yyyy') as f_nac, a.jubilado, '' excluido, a.residencia_direccion as direccion, a.tipo_residencia as tiporesi, a.telefono, a.residencia_pais as paiscode, decode (a.residencia_pais, null, null, d.nombre_pais) as pais, a.residencia_provincia as provcode, decode (a.residencia_provincia, null, null, d.nombre_provincia) as prov, a.residencia_distrito as distritocode, decode (a.residencia_distrito, null, null, d.nombre_distrito) as distrito, a.residencia_corregimiento as corregicode, decode (a.residencia_corregimiento, null, null, d.nombre_corregimiento) as corregi, a.residencia_comunidad as comunidadcode, decode (a.residencia_comunidad, null, null, d.nombre_comunidad) as comunidad, a.zona_postal as zonapostal, a.apartado_postal as aptdopostal, a.fax, nvl (a.e_mail, 'sincorreo@dominio.com') e_mail, a.persona_de_urgencia as persurgencia, a.direccion_de_urgencia as dirurgencia, a.telefono_urgencia as telurgencia, a.telefono_trabajo_urgencia as teltrabajourge, '' as nomconyugue, '' as lugartrabconyugue, '' as teltrabconyugue, '' as tipoidconyugue, '' as idconyugue, '' as conyunacionalcode, '' as conyunacional, '' as lugartrab, a.puesto_que_ocupa as puestoocu, '' as trabdireccion, '' as deptdolabora, '' as jefeinmediato, '' as teltrabajo, '' as extoficina, '' as periodolab, '' as trabpaiscode, '' as trabpais, '' as trabprovcode, '' as trabprov, '' as trabdistritocode, '' as trabdistrito, '' as trabcorregicode, '' as trabcorregi, '' as comidaid, '' as lenguajeid from vw_pm_cliente a, tbl_sec_pais b, tbl_adm_religion c, vw_sec_regional_location d where     a.nacionalidad = b.codigo(+) and a.religion = c.codigo(+) and nvl (a.residencia_pais, 0) = d.codigo_pais(+) and nvl (a.residencia_provincia, 0) = d.codigo_provincia(+) and nvl (a.residencia_distrito, 0) = d.codigo_distrito(+) and nvl (a.residencia_corregimiento, 0) = d.codigo_corregimiento(+) and nvl (a.residencia_comunidad, 0) = d.codigo_comunidad(+) and a.id_paciente = '").append(identificacion).append("'");
			cdo = SQLMgr.getData(sbSql.toString());
		}
		}
		else
		{
		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("SELECT a.deseo,a.preferencia ,a.tipo_id_paciente as tipoId, a.provincia, a.sigla, a.tomo, a.asiento, a.d_cedula, a.pasaporte, to_char(nvl(a.f_nac,a.fecha_nacimiento),'dd/mm/yyyy') as fechaNaci, a.codigo, a.primer_nombre as primerNom, a.estado_civil as estadoCivil, a.segundo_nombre as segundoNom, a.sexo, a.primer_apellido as primerApell, a.ingreso_men, a.segundo_apellido as segundoApell, a.apellido_de_casada as casadaApell, a.seguro_social as seguro, a.tipo_sangre as tipoSangre, decode(a.nh,'S','Nació en el hospital',null,' ') nh, a.numero_de_hijos as hijo, a.vip, a.lugar_nacimiento as lugarNaci, a.nacionalidad as nacionalCode, b.nacionalidad as nacional, a.religion as religionCode,  c.descripcion as religion, a.estatus, a.fallecido, a.nombre_padre as nomPadre, a.nombre_madre as nomMadre, a.datos_correctos as datosCorrec, to_char(a.fecha_fallecido,'dd/mm/yyyy') as fechafallece, to_char(nvl(a.f_nac,fecha_nacimiento),'dd/mm/yyyy') as fechaCorrec,to_char(a.f_nac,'dd/mm/yyyy') as f_nac, a.jubilado, a.excluido, a.residencia_direccion as direccion, a.tipo_residencia as tipoResi, a.telefono, a.residencia_pais as paisCode, decode(a.residencia_pais,null,null,d.nombre_pais) as pais, a.residencia_provincia as provCode, decode(a.residencia_provincia,null,null,d.nombre_provincia) as prov, a.residencia_distrito as distritoCode, decode(a.residencia_distrito,null,null,d.nombre_distrito) as distrito, a.residencia_corregimiento as corregiCode, decode(a.residencia_corregimiento,null,null,d.nombre_corregimiento) as corregi, a.residencia_comunidad as comunidadCode, decode(a.residencia_comunidad,null,null,d.nombre_comunidad) as comunidad, a.zona_postal as zonaPostal, a.apartado_postal as aptdoPostal, a.fax, nvl(a.e_mail,'sincorreo@dominio.com')e_mail, a.persona_de_urgencia as persUrgencia, a.direccion_de_urgencia as dirUrgencia, a.telefono_urgencia as telUrgencia, a.telefono_trabajo_urgencia as telTrabajoUrge, a.nombre_conyugue as nomConyugue, a.lugar_trabajo_conyugue as lugarTrabConyugue, a.telefono_trabajo_conyugue as telTrabConyugue, a.tipo_identificacion_conyugue as tipoIdConyugue, a.identificacion_conyugue as idConyugue, a.conyugue_nacionalidad as conyuNacionalCode, e.nacionalidad as conyuNacional, a.lugar_trabajo as lugarTrab, a.puesto_que_ocupa as puestoOcu, a.trabajo_direccion as trabDireccion, a.departamento_donde_labora as deptdoLabora, a.nombre_jefe_inmediato as jefeInmediato, a.telefono_trabajo as telTrabajo, a.extension_oficina as extOficina, a.periodos_laborados as periodoLab, a.trabajo_pais as trabPaisCode, decode(a.trabajo_pais,null,null,f.nombre_pais) as trabPais, a.trabajo_provincia as trabProvCode, decode(a.trabajo_provincia,null,null,f.nombre_provincia) as trabProv, a.trabajo_distrito as trabDistritoCode, decode(a.trabajo_distrito,null,null,f.nombre_distrito) as trabDistrito, a.trabajo_corregimiento as trabCorregiCode, decode(a.trabajo_corregimiento,null,null,f.nombre_corregimiento) as trabCorregi,g.comida_id as comidaId,h.lenguaje_id as lenguajeId,a.ref_id FROM tbl_adm_paciente a, tbl_sec_pais b, tbl_adm_religion c, vw_sec_regional_location d, tbl_sec_pais e, vw_sec_regional_location f,tbl_adm_comida g,tbl_adm_lenguaje h WHERE a.nacionalidad=b.codigo(+) and a.religion=c.codigo(+) and nvl(a.residencia_pais,0)=d.codigo_pais(+) and nvl(a.residencia_provincia,0)=d.codigo_provincia(+) and nvl(a.residencia_distrito,0)=d.codigo_distrito(+) and nvl(a.residencia_corregimiento,0)=d.codigo_corregimiento(+) and nvl(a.residencia_comunidad,0)=d.codigo_comunidad(+) and a.conyugue_nacionalidad=e.codigo(+) and nvl(a.trabajo_pais,0)=f.codigo_pais(+) and nvl(a.trabajo_provincia,0)=f.codigo_provincia(+) and nvl(a.trabajo_distrito,0)=f.codigo_distrito(+) and nvl(a.trabajo_corregimiento,0)=f.codigo_corregimiento(+) and nvl(a.residencia_comunidad,0)=f.codigo_comunidad(+) and a.lenguaje_id=h.lenguaje_id(+) and a.comida_id=g.comida_id(+) and a.pac_id = ").append(pacId);
		cdo = SQLMgr.getData(sbSql.toString());


		sbSql = new StringBuffer();
		sbSql.append("SELECT a.secuencia, a.nombre as custNombre, b.nacionalidad as custNacional, c.nombre as custEmpresa, a.num_empleado as custNoEmpleado, a.ocupacion as custOcupacion FROM tbl_adm_custodio a, tbl_sec_pais b, tbl_adm_empresa c WHERE a.nacionalidad=b.codigo(+) and a.cod_empresa=c.codigo(+) and a.pac_id = ").append(pacId);
		al = SQLMgr.getDataList(sbSql.toString());

		sbSql = new StringBuffer();
		sbSql.append("select a.id, a.description, decode(a.display_area,'P','PACIENTE','X','EXPEDIENTE','A','ADMISION','H','RECURSOS HUMANOS','C','CONTABILIDAD','O','GERENCIA DE OPERACIONES','G','GERENCIA GENERAL',a.display_area) as display_area, decode((select doc_type from tbl_adm_paciente_doc where pac_id = ").append(pacId).append(" and doc_type = a.id),null,'N','Y') as checked from tbl_sec_doc_type a where a.status = 'A' and a.display_area in ('P') order by 3, 2");
		alDoc = SQLMgr.getDataList(sbSql.toString());

	}


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script>
document.title = 'Mantenimiento de Paciente - '+document.title;
function addNacional(){<%=popWinFunction%>('../common/search_pais.jsp?fp=paciente_nac');}
function addReligion(){<%=popWinFunction%>('../common/search_religion.jsp?fp=paciente');}
function addUbica(){<%=popWinFunction%>('../common/search_ubicacion_geo.jsp?fp=paciente_ubica');}
function addConyuNacional(){<%=popWinFunction%>('../common/search_pais.jsp?fp=paciente_conyu_nac');}
function addTrabUbica(){<%=popWinFunction%>('../common/search_ubicacion_geo.jsp?fp=paciente_trabajo');}
function add(){<%=popWinFunction%>('../admision/paciente_custodio_config.jsp?fp=<%=fp%>&code=<%=cdo.getColValue("codigo")%>&dob=<%=cdo.getColValue("fechaNaci")%>&pacId=<%=pacId%>&tab=3&tipo=<%=tipoHuella%>');}
function edit(id){<%=popWinFunction%>('../admision/paciente_custodio_config.jsp?fp=<%=fp%>&mode=edit&id='+id+'&pacId=<%=pacId%>&tab=3&tipo=<%=tipoHuella%>&cat_adm=<%=catAdm%>');}
function setId(clearOnChange){
<%
	if (!viewMode)
	{
%>
	if (document.form0.tipoId.value == 'C')
	{
		document.form0.pasaporte.className = 'FormDataObjectDisabled';
		document.form0.pasaporte.readOnly = true;
		if (clearOnChange) document.form0.pasaporte.value = '';

		document.form0.provincia.className = 'FormDataObjectEnabled';
		document.form0.sigla.className = 'FormDataObjectEnabled';
		document.form0.tomo.className = 'FormDataObjectEnabled';
		document.form0.asiento.className = 'FormDataObjectEnabled';
		document.form0.provincia.readOnly = false;
		document.form0.sigla.readOnly = false;
		document.form0.tomo.readOnly = false;
		document.form0.asiento.readOnly = false;
	}
	else if (document.form0.tipoId.value == 'P')
	{
		document.form0.provincia.className = 'FormDataObjectDisabled';
		document.form0.sigla.className = 'FormDataObjectDisabled';
		document.form0.tomo.className = 'FormDataObjectDisabled';
		document.form0.asiento.className = 'FormDataObjectDisabled';
		document.form0.provincia.readOnly = true;
		document.form0.sigla.readOnly = true;
		document.form0.tomo.readOnly = true;
		document.form0.asiento.readOnly = true;
		if (clearOnChange)
		{
			document.form0.provincia.value = '';
			document.form0.sigla.value = '';
			document.form0.tomo.value = '';
			document.form0.asiento.value = '';
		}

		document.form0.pasaporte.className = 'FormDataObjectEnabled';
		document.form0.pasaporte.readOnly = false;
	}
	chkReqCampos();
<%
	}
%>
}

$(document).ready(function(){
	$("#tabTabdhtmlgoodies_tabView1_5").on("click",function(){
			 $('#iFingerprint').attr('src', '../biometric/capture_fingerprint.jsp?mode=<%=mode%>&fp=patient&type=PAC&owner=<%=pacId%>');
	});
});

function doAction()
{
	// doResetFrameHeight();
	setId(false);
	<%if(mode.equals("edit")){%>
	var valor = document.getElementById('vip').value;
	setImagen(valor);
	<%}%>
	habFF();
	CalculateAge();

	<%if(fp.trim().equalsIgnoreCase("hdadmision")){%>
		 maximizeWin();
		 if (parent.opener){
				//parent.opener.close();
			parent.window.opener.close();
		 }
	<%}%>
	chkReqCampos();

		<%if(!mode.trim().equalsIgnoreCase("add") && cdo.getColValue("excluido") != null && cdo.getColValue("excluido").equalsIgnoreCase("S")  ){%>
			 CBMSG.warning('"NO EXISTE DISPONIBILIDAD DE CAMAS. CONSULTAR CON SU SUPERVISOR"',
			 {
				 opacity:1,
				 btnTxt: "Ok"
			 });
		<%}%>
}

function chkReqCampos(){
	if(document.form0.tipoId.value=='C'){
		document.form0.provincia.className = 'FormDataObjectRequired';
		document.form0.sigla.className = 'FormDataObjectRequired';
		document.form0.tomo.className = 'FormDataObjectRequired';
		document.form0.asiento.className = 'FormDataObjectRequired';
		document.form0.d_cedula.className = 'FormDataObjectRequired';
		document.form0.pasaporte.className = 'FormDataObjectDisabled';
	} else {
		document.form0.provincia.className = 'FormDataObjectDisabled';
		document.form0.sigla.className = 'FormDataObjectDisabled';
		document.form0.tomo.className = 'FormDataObjectDisabled';
		document.form0.asiento.className = 'FormDataObjectDisabled';
		document.form0.d_cedula.className = 'FormDataObjectDisabled';
		document.form0.pasaporte.className = 'FormDataObjectRequired';
	}

}

function isValidId()
{
	var dCedula=document.form0.d_cedula.value;
	if (document.form0.tipoId.value == 'C')
	{
		var provincia=document.form0.provincia.value.trim();
		var sigla=document.form0.sigla.value.trim();
		var tomo=document.form0.tomo.value.trim();
		var asiento=document.form0.asiento.value.trim();
		var dCedula=document.form0.d_cedula.value.trim();
		if(provincia==''||sigla==''||tomo==''||asiento=='')
		{
			CBMSG.warning('Introduzca o complete el número de CEDULA!');
			return false;
		}
		else{
				if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
				{
					 CBMSG.warning('Valores invalidos en numero de cedula! Revise..')
				}
				else
				{
					 if('<%=cdo.getColValue("provincia").trim()%>'!=provincia||'<%=cdo.getColValue("sigla").trim().replaceAll("'","\\\\'")%>'!=sigla||'<%=cdo.getColValue("tomo").trim()%>'!=tomo||'<%=cdo.getColValue("asiento").trim()%>'!=asiento||'<%=cdo.getColValue("d_cedula").trim()%>'!=dCedula)
					{
						if(hasDBData('<%=request.getContextPath()%>','tbl_adm_paciente','provincia='+provincia+' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo='+tomo+' and asiento='+asiento+' and d_cedula=\''+dCedula+'\'',''))
						{
							CBMSG.warning('Ya existe un paciente con este número de CEDULA!');
							return false;
						} else if('<%=usaPlanMedico%>'=='S'){
							if(hasDBData('<%=request.getContextPath()%>','tbl_pm_cliente','provincia='+provincia+' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo='+tomo+' and asiento='+asiento+' and d_cedula=\''+dCedula+'\'',''))
							{
								CBMSG.warning('Ya existe un paciente de Plan Medico con este número de CEDULA!');
								return false;
							}
						}
					}
				}
				}
	}
	else if (document.form0.tipoId.value == 'P')
	{
		var pasaporte=document.form0.pasaporte.value.trim();
		if(pasaporte=='')
		{
			CBMSG.warning('Introduzca el número de PASAPORTE!');
			return false;
		}
		else if('<%=cdo.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>'!=pasaporte||'<%=cdo.getColValue("d_cedula").trim()%>'!=dCedula)
		{
			if(hasDBData('<%=request.getContextPath()%>','tbl_adm_paciente','pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula=\''+dCedula+'\'',''))
			{
				CBMSG.warning('Ya existe un paciente con este número de PASAPORTE!');
				return false;
			} else if('<%=usaPlanMedico%>'=='S'){
							if(hasDBData('<%=request.getContextPath()%>','tbl_pm_cliente','pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula=\''+dCedula+'\'',''))
							{
								CBMSG.warning('Ya existe un paciente de Plan Medico con este número de PASAPORTE!');
								return false;
							}
						}
		}
	}
	return true;
}

function checkProvincia(obj)
{
<%
	if (!viewMode)
	{
%>
	var sigla=document.form0.sigla.value.trim();
	var tomo=document.form0.tomo.value.trim();
	var asiento=document.form0.asiento.value.trim();
	var dCedula=document.form0.d_cedula.value.trim();
		if(isNaN(obj.value.trim())||isNaN(tomo)||isNaN(asiento))
		{
			 CBMSG.warning('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_paciente','tipo_id_paciente=\'C\' and provincia=\''+obj.value+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("provincia").trim()%>'))
			{
					 document.form0.provincia.value = '';
					 return true;
			} else if('<%=usaPlanMedico%>'=='S'){
				if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'C\' and provincia=\''+obj.value+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("provincia").trim()%>'))
				{
					if(confirm('Ya existe este paciente en Plan Medico, Desea cargar la Informacion de plan Medico?')){
						 window.location = '../admision/paciente_config.jsp?fg=load_from_pm&identificacion='+obj.value+'-'+replaceAll(sigla,'\'','\'\'')+'-'+tomo+'-'+asiento+'-'+dCedula+'&fp=<%=fp%>&cat_adm=<%=catAdm%>';
					 }
						 document.form0.provincia.value = '';
						 return true;
				}
			} else return false;
		}
<%
	}
%>
}

function checkSigla(obj)
{
<%
	if (!viewMode)
	{
%>
	var provincia=document.form0.provincia.value.trim();
	var tomo=document.form0.tomo.value.trim();
	var asiento=document.form0.asiento.value.trim();
	var dCedula=document.form0.d_cedula.value.trim();
		if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
		{
			 CBMSG.warning('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_paciente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(obj.value,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("sigla").trim().replaceAll("'","\\\\'")%>'))
			{
					 document.form0.sigla.value = '';
					 return true;
			}else if('<%=usaPlanMedico%>'=='S'){
				if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(obj.value,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("sigla").trim().replaceAll("'","\\\\'")%>'))
			{
				if(confirm('Ya existe este paciente en Plan Medico, Desea cargar la Informacion de plan Medico?')){
						 window.location = '../admision/paciente_config.jsp?fg=load_from_pm&identificacion='+provincia+'-'+replaceAll(obj.value,'\'','\'\'')+'-'+tomo+'-'+asiento+'-'+dCedula+'&fp=<%=fp%>&cat_adm=<%=catAdm%>';
					 }
					 document.form0.sigla.value = '';
					 return true;
			}
			} else return false;
		}
<%
	}
%>
}

function checkTomo(obj)
{
<%
	if (!viewMode)
	{
%>
	var provincia=document.form0.provincia.value.trim();
	var sigla=document.form0.sigla.value.trim();
	var asiento=document.form0.asiento.value.trim();
	var dCedula=document.form0.d_cedula.value.trim();
		if(isNaN(provincia)||isNaN(obj.value.trim())||isNaN(asiento))
		{
			 CBMSG.warning('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_paciente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+obj.value+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("tomo").trim()%>'))
			{
					 document.form0.tomo.value = '';
					 return true;
			} else if('<%=usaPlanMedico%>'=='S'){
				if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+obj.value+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("tomo").trim()%>'))
				{
					if(confirm('Ya existe este paciente en Plan Medico, Desea cargar la Informacion de plan Medico?')){
						 window.location = '../admision/paciente_config.jsp?fg=load_from_pm&identificacion='+provincia+'-'+replaceAll(sigla,'\'','\'\'')+'-'+obj.value+'-'+asiento+'-'+dCedula+'&fp=<%=fp%>&cat_adm=<%=catAdm%>';
					 }
						 document.form0.tomo.value = '';
						 return true;
				}
			} else return false;
		}
<%
	}
%>
}

function checkAsiento(obj)
{
<%
	if (!viewMode)
	{
%>
	var provincia=document.form0.provincia.value.trim();
	var sigla=document.form0.sigla.value.trim();
	var tomo=document.form0.tomo.value.trim();
	var dCedula=document.form0.d_cedula.value.trim();
		if(isNaN(provincia)||isNaN(tomo)||isNaN(obj.value.trim()))
		{
			 CBMSG.warning('Valores invalidos en numero de cedula! Revise..');
		}
		else
		{
			if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_paciente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+obj.value+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("asiento").trim()%>'))
			{
				 document.form0.asiento.value = '';
				 return true;
			} else if('<%=usaPlanMedico%>'=='S'){
				if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+obj.value+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("asiento").trim()%>'))
				{
					 if(confirm('Ya existe este paciente en Plan Medico, Desea cargar la Informacion de plan Medico?')){
						 window.location = '../admision/paciente_config.jsp?fg=load_from_pm&identificacion='+provincia+'-'+replaceAll(sigla,'\'','\'\'')+'-'+tomo+'-'+obj.value+'-'+dCedula+'&fp=<%=fp%>&cat_adm=<%=catAdm%>';
					 }
					 document.form0.asiento.value = '';
					 return true;
				}
			}
			else return false;
		}
<%
	}
%>
}

function checkPasaporte(obj)
{
	var dCedula=document.form0.d_cedula.value.trim();
	if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_paciente','tipo_id_paciente=\'P\' and pasaporte=\''+obj.value+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>')) return true;
	else if('<%=usaPlanMedico%>'=='S'){
		if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'P\' and pasaporte=\''+obj.value+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>')) return true;
		else return false;
	} else return false;

}

function checkDCedula(obj)
{
	var tipoId=document.form0.tipoId.value;
	if(tipoId=='C')
	{
		var provincia=document.form0.provincia.value.trim();
		var sigla=document.form0.sigla.value.trim();
		var tomo=document.form0.tomo.value.trim();
		var asiento=document.form0.asiento.value.trim();
		if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
		{
			 CBMSG.warning('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_paciente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+obj.value+'\'','<%=cdo.getColValue("d_cedula").trim()%>')) return true;
			else if('<%=usaPlanMedico%>'=='S'){
				if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+obj.value+'\'','<%=cdo.getColValue("d_cedula").trim()%>')) return true;
				else return false;
			} else return false;
		}
	}
	else if(tipoId='P')
	{
		var pasaporte=document.form0.pasaporte.value.trim();
		if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_paciente','tipo_id_paciente=\'P\' and pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula=\''+obj.value+'\'','<%=cdo.getColValue("d_cedula").trim()%>')) return true;
		else if('<%=usaPlanMedico%>'=='S'){
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'P\' and pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula=\''+obj.value+'\'','<%=cdo.getColValue("d_cedula").trim()%>')) return true;
			else return false;
		} else return false;
	}
}

function setImagen(valor,fg)
{
	var source = '';
	if(valor=='N') source = '../images/blank.gif';
	else if(valor=='S') source = '../images/vip.png';
	else if(valor=='D') source = '../images/distinguido.png';
	else if(valor=='M') source = '../images/medico.png';
	else if(valor=='J') source = '../images/junta_directiva.png';
	else if(valor=='E') source = '../images/empleados.png'
	else if(valor=='A') source = '../images/accionista.png';
	document.getElementById('imagen_vip').src=source;

	if (fg=='UPD'){
	document.form0.provincia.value='';
		document.form0.sigla.value='';
		document.form0.tomo.value='';
		document.form0.asiento.value='';

	document.form0.nacionalCode.value ='';
		document.form0.nacional.value = '';
		document.form0.sexo.value = '';
		document.form0.telefono.value = '';
		document.form0.primerNom.value = '';
		document.form0.segundoNom.value = '';
		document.form0.primerApell.value = '';
		document.form0.segundoApell.value ='';
		document.form0.casadaApell.value ='';
		document.form0.fechaCorrec.value = '';
		document.form0.fechaNaci.value = '';
		document.form0.religionCode.value = '';
		document.form0.direccion.value = '';

		document.form0.comunidadCode.value = '';
		document.form0.corregiCode.value = '';
		document.form0.distritoCode.value = '';
		document.form0.provCode.value ='';
		document.form0.paisCode.value = '';

		document.form0.comunidad.value = '';
		document.form0.corregi.value = '';
		document.form0.distrito.value = '';
		document.form0.prov.value = '';
		document.form0.pais.value ='';


		document.form0.zonaPostal.value = '';
		document.form0.aptdoPostal.value = '';

		document.form2.telTrabajo.value = '';
		document.form2.lugarTrab.value ='';
		document.form0.e_mail.value = '';
		document.form0.fax.value = '';
		document.form0.ref_id.value = '';
		document.form0.estadoCivil.value ='';

		document.form0.tipoSangre.value = 'S';}

	CalculateAge();
}

function setDias(val)
{
	if(val=='S'){
		document.form0.fechaFallece.className = 'FormDataObjectEnabled';
		eval('document.form0.fechaFallece').disabled = false;

	} else {
		document.form0.fechaFallece.className = 'FormDataObjectDisabled';
		 eval('document.form0.fechaFallece').disabled = true;
	}
}



function CalculateAge() {
	var fecha = document.form0.fechaCorrec.value;
	var fechaF  = document.form0.fechaFallece.value;
	var fechaFallece='sysdate';
	if(fechaF!='')fechaFallece='to_date(\''+fechaF+'\', \'dd/mm/yyyy\')';

	if(fecha!=''){
	if(isValidateDate(document.form0.fechaCorrec.value)){
		var sql = 'nvl(trunc(months_between('+fechaFallece+', to_date(\''+fecha+'\', \'dd/mm/yyyy\'))/12),0) || \' A&ntilde;os \' || nvl(mod(trunc(months_between('+fechaFallece+', to_date(\''+fecha+'\', \'dd/mm/yyyy\'))),12),0) || \' Meses \' || trunc('+fechaFallece+'-add_months(to_date(\''+fecha+'\', \'dd/mm/yyyy\'),(nvl(trunc(months_between('+fechaFallece+',to_date(\''+fecha+'\', \'dd/mm/yyyy\'))/12),0)*12+nvl(mod(trunc(months_between('+fechaFallece+',to_date(\''+fecha+'\', \'dd/mm/yyyy\'))),12),0)))) || \' Dias \'';
		var anio=getDBData('<%=request.getContextPath()%>','nvl(trunc(months_between('+fechaFallece+', to_date(\''+fecha+'\', \'dd/mm/yyyy\'))/12),0) as anios','dual','','');
		var data = splitRowsCols(getDBData('<%=request.getContextPath()%>',sql,'dual','',''));
		document.form0.edad.value=anio;
		document.getElementById('lbl_edad').innerHTML = data;
	}else CBMSG.warning('Valor Invalido en Fecha Nacimiento!!');}
}

function habFF(){
	var obj = document.form0.fallecido;
	<%if(!mode.trim().equals("view")){%>
	if (!obj) return true;

	if(obj.checked){
		document.form0.fechaFallece.className='FormDataObjectRequired';
		document.form0.fechaFallece.disabled='';
		document.form0.fechaFallece.readOnly=false;
		document.form0.resetfechaFallece.disabled='';
		if ( document.form0.fechaFallece.value == '' ){
			return false;
		}else{return true;}
	} else {
		document.form0.fechaFallece.className='FormDataObjectDisabled';
		document.form0.fechaFallece.value='';
		document.form0.fechaFallece.disabled='disabled';
		document.form0.resetfechaFallece.disabled='disabled';
		CalculateAge();
		return true;
	}


	<%}%>

}

function validateDCedula(obj, val){

	var tipoId=document.form0.tipoId.value;
	var nextValidSecuence = 0;
		var userSecuence = 0;
	var values = new Array();
	var r;
	var dCedula = "";
	var mode = "<%=mode%>";
	var tabla = 'tbl_adm_paciente';
	if(val=='C') tabla = 'tbl_pm_cliente';

	if ( obj == undefined ){
		 dCedula = document.form0.d_cedula.value;
	}else{dCedula = obj.value;}

	if (dCedula.indexOf("H")>-1){
			userSecuence = parseInt(dCedula.substring(1),10);
		if(tipoId=='C')
		{
			var provincia=document.form0.provincia.value.trim();
			var sigla=document.form0.sigla.value.trim();
			var tomo=document.form0.tomo.value.trim();
			var asiento=document.form0.asiento.value.trim();
			if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
			{
				 CBMSG.warning('Valores invalidos en numero de cedula!   Revise..')
			}
			else
			{
				r = splitRowsCols(getDBData('<%=request.getContextPath()%>','d_cedula',tabla,'tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula like \'%H%\''));
			}
		}
		else if(tipoId=='P')
		{
			var pasaporte=document.form0.pasaporte.value.trim();
			r = splitRowsCols(getDBData('<%=request.getContextPath()%>','d_cedula',tabla,'tipo_id_paciente=\'P\' and pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula like \'%H%\''));
		}

		if ( r!=null){values = (""+r).replace(/[A-Za-z]/gi,"").split(",");if ( mode === "add" ){nextValidSecuence = parseInt(values.sort(function(a,b){return b-a;})[0],10) + 1;		}else{if(document.form0.old_d_cedula.value != dCedula ){
		nextValidSecuence =userSecuence;
		for (var i = 0; i < r.length; i++){if (r[i] == 'H'+nextValidSecuence){nextValidSecuence++;}

		 //nextValidSecuence = parseInt(values.sort(function(a,b){return b-a;})[0],10);
		 }
				}else{nextValidSecuence =userSecuence;}}
				if ( userSecuence != nextValidSecuence ){

					 CBMSG.warning("Lo sentimos, pero debe continuar con H"+nextValidSecuence);

					 return false;
				}else{return true;}
		}else{
				nextValidSecuence=1;
				if ( userSecuence != nextValidSecuence ){
					 CBMSG.warning("Lo sentimos, pero debe empezar con H"+nextValidSecuence);

					 return false;
				}else{return true;}
		}

	}else{return true;}
}

function chkDireccion(){if((document.form0.direccion.value).trim()=='' ){CBMSG.warning('Introduzca Direccion Valida');return false;}return true;}
function chkAdmision(){

	<%if(mode.equals("add")){%>
	//if((document.form0.direccion.value).trim()=='' ){CBMSG.warning('Introduzca Direccion Valida');return false;}

	return true;
	<%} else {%>
	if(document.form0.estatus.value=='I'){
	var count = getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision','pac_id=<%=pacId%> and estado in (\'A\',\'E\')','');
	{

		if(count!=0) return false;
		else return true;
	}
	}
	else{ return true;}
	<%}%>
}

function notAValidPassport(){
	var mode = "<%=mode%>";
	var oldPassport = "<%=cdo.getColValue("pasaporte")==null?"":cdo.getColValue("pasaporte")%>";
	var curPassport = document.getElementById("pasaporte").value;
	var _pattern = /\s/g;
	var hadBlankSpace = _pattern.test(oldPassport);
	if (curPassport.trim() != ""){
		if (mode == "add"){
		if (_pattern.test(curPassport) == true){
			CBMSG.warning("No se permite espacio en el campo PASAPORTE!"); return true;
		}
		}else{
		if (hadBlankSpace==false && _pattern.test(curPassport) == true){
			CBMSG.warning("No se permite espacio en el campo PASAPORTE!"); return true;
		}
		}
	}else{return false;}
}
//window.notAValidPassport;

function checkSexo(){
	if (!$("#sexo").val()){
		CBMSG.error("Por favor seleccionar el sexo!");
		return false;
	}
	return true;
}
function checkFidelizacion(){
	var vip = $("#vip").val();
	var nac = $("#nacionalCode").val();
	var paisRes =  $("#paisCode").val();
	var codNac = "<%=cdox.getColValue("codNac")%>";
	var sexo =  $("#sexo").val();
	var edad =  $("#edad").val();
	var edad_jub ='';
	var msg ='';
	if (vip == 'T'||vip=='P'){
		if (vip == 'T'){
			if(edad.trim()=='')msg=' Fecha de Nacimiento del Paciente.';
			if(sexo =='F')edad_jub=	"<%=cdox.getColValue("edad_jub_mujeres")%>";
			else if(sexo =='M')edad_jub=	"<%=cdox.getColValue("edad_jub_varones")%>";
			else msg+=' Sexo del Paciente.';
			//alert('edad ='+edad+'   edad_jub ='+edad_jub+'  nac =='+nac+' codNac = '+codNac);
			if(parseInt(edad) < parseInt(edad_jub) && parseInt(edad_jub) != 0 )
			{
				msg+=' Paciente no Tiene la edad para Jubilado/ tercera edad.';
			}
			if(nac=='')msg +=' Nacionalidad del Paciente.';
			if(nac!=codNac && paisRes=='')msg +=' Pais de Residencia del Paciente.';

			if(nac!=codNac && paisRes!=''){if((paisRes!=codNac )) msg +=' El Paciente no es nacional o Extrenjero Residente .';	    }
		}
		if(msg!=''){
			CBMSG.error("Por favor Revisar:"+msg);
			return false;
		} else return true;
	}
	return true;
}


function istAnInvalidDob() {
	var dob = document.getElementById("fechaCorrec").value;
	var result = getDBData('<%=request.getContextPath()%>',"'y' as res",'dual',"trunc(sysdate) < to_date('"+dob+"','dd/mm/yyyy')",'');
	if (result && result == 'y'){
		CBMSG.error("La fecha de nacimiento ingresada es incorrecta por favor ingresar una fecha menor o igual al día actual!");
		return true;
	}
	return false;
}
function ctrlSex(val){
	var nombre_bb = document.getElementById("primerNom").value;
	if ( val != "" ){
		if ( val == "F" ){
			nombre_bb = nombre_bb.replace("HIJO","HIJA");
			document.getElementById("primerNom").value = nombre_bb;
		}else{
			nombre_bb = nombre_bb.replace("HIJA","HIJO");
			document.getElementById("primerNom").value = nombre_bb;
		}
	}
}
function searchPaciente()
{
	var tipo = document.getElementById('vip').value;


			 if(tipo=='M') <%=popWinFunction%>('../common/search_medico.jsp?fp=paciente');
	else if(tipo=='J') <%=popWinFunction%>('../common/search_accionista.jsp?fp=paciente&fg=JD');
	else if(tipo=='E') <%=popWinFunction%>('../common/search_empleado.jsp?fp=paciente');
	else if(tipo=='A') <%=popWinFunction%>('../common/search_accionista.jsp?fp=paciente&fg=ACC');
	else{CBMSG.warning("Opcion no definida !");}
}
function tabFunctions(tab){
	var iFrameName = '';
	if(tab==5){
		if(window.frames["iFingerprint"])window.frames["iFingerprint"].doResetFrameHeight();
	} else if(tab==4) {
		iFrameName='iFrameTarjeta';
		window.frames[iFrameName].doAction();
	}
}
function showInfo(tab, id, mode){
	var iFrameName = '', page = '';
	if(tab==4){
		iFrameName='iFrameTarjeta';
		page = '../admision/reg_tarjetas_cta.jsp?pac_id=<%=pacId%>&id='+id+'&mode='+mode+'&tab='+tab;
	}
	window.frames[iFrameName].location=page;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION - MANTENIMIENTO - PACIENTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
<div id="dhtmlgoodies_tabView1">
<!--GENERALES TAB0-->
<div class="dhtmlgoodies_aTab">
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("tipo",tipoHuella)%>
<%=fb.hidden("docTypeSize",""+alDoc.size())%>
<%=fb.hidden("old_d_cedula",""+cdo.getColValue("d_cedula"))%>
<%=fb.hidden("ref_id",""+cdo.getColValue("ref_id"))%>
<%=fb.hidden("edad","")%>
<%=fb.hidden("cat_adm", catAdm)%>
<%=fb.hidden("context", context)%>
<%fb.appendJsValidation("if(document.form0.fechaCorrec.value==''){CBMSG.warning('Por favor ingrese la Fecha de Nacimiento!');error++;}");%>
<%fb.appendJsValidation("if(!habFF()){CBMSG.warning('Por favor ingrese la Fecha de Fallecimiento!'+habFF());error++;}");%>
<%fb.appendJsValidation("if(!chkAdmision()){CBMSG.warning('Este paciente tiene admisiones activas o en espera!');error++;}");%>
<%fb.appendJsValidation("if(!chkDireccion()){error++;}");%>
<%if(mode.equalsIgnoreCase("add")) fb.appendJsValidation("if(istAnInvalidDob())error++;");%>
		<tr>
			<td colspan="2" onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel id="1">Datos Principales</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>

		<%if(catAdm.trim().equals("")){%>
		<tr id="panel0">
			<td width="50%">
				<table width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow01">
					<td width="30%"><cellbytelabel id="2">Tipo ID</cellbytelabel></td>
					<td width="70%"><%=fb.select("tipoId","C=Cedula,P=Pasaporte",cdo.getColValue("tipoId"),false,viewMode,0,null,null,"onChange=\"javascript:setId(true)\"")%>
										<%if(mode.equalsIgnoreCase("edit")){%>
										&nbsp;&nbsp;&nbsp;&nbsp;
										<a href="javascript:showPopWin('../expediente/exp_avatar.jsp?pacId=<%=pacId%>&mode=<%=mode%>',winWidth*.45,winHeight*.40,null,null,'')" class="Link00Bold">Avatar</a>
										<%}%>
										</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="3">Hijos</cellbytelabel></td>
					<td><%=fb.select("d_cedula","D=D,R=R,H1=H1,H2=H2,H3=H3,H4=H4,H5=H5,H6=H6,H7=H7,H8=H8,H9=H9",cdo.getColValue("d_cedula"),false,viewMode,0,null,null,"onChange=\"checkDCedula(this); validateDCedula(this,'P'); "+(usaPlanMedico.equals("S")?"validateDCedula(this,'C');":"")+"\"")%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="25">Programa Fidelizaci&oacute;n</cellbytelabel></td>
					<td>
						<%=fb.select(ConMgr.getConnection(),"select vip as code, descripcion,empresa FROM tbl_adm_tipo_paciente order by id","vip",cdo.getColValue("vip"),false,(viewMode ||!mode.trim().equals("add")),0,"text10","","onChange=\"javascript:setImagen(this.value,'UPD')\"")%>


						<%//=fb.select("vip","N=Normal,S=VIP,D=Distinguido,M=Médico Staff,J=J.Directiva,E=Empleado",cdo.getColValue("vip"),false,viewMode,0,"text10","","onChange=\"javascript:setImagen(this.value)\"")%>
						<%=fb.button("btnTipo","...",true,(viewMode||!mode.trim().equals("add")),null,null,"onClick=\"javascript:searchPaciente()\"")%>
						<img id="imagen_vip" src="../images/blank.gif">
						<%//=fb.button("testFid","test fidelizacion",true,false,null,null,"onClick=\"javascript:checkFidelizacion();\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="4">Fecha Nacimiento</cellbytelabel></td>
					<td><%=fb.hidden("fechaNaci",cdo.getColValue("fechaNaci"))%>
					<%=fb.hidden("f_nac",cdo.getColValue("f_nac"))%>

						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="nameOfTBox1" value="fechaCorrec"/>
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaCorrec")%>"/>
						<jsp:param name="fieldClass" value="FormDataObjectRequired"/>
						<jsp:param name="readonly" value="<%=(viewMode||!mode.trim().equals("add"))?"y":"n"%>"/>
						<jsp:param name="jsEvent"  value="CalculateAge()"/>
						<jsp:param name="onChange" value="CalculateAge()"/>
						</jsp:include>
						<cellbytelabel id="5">Edad:</cellbytelabel>
						<label id="lbl_edad">&nbsp;</label>

					</td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="6">Primer Nombre</cellbytelabel></td>
					<td><%=fb.textBox("primerNom",cdo.getColValue("primerNom"),true,false,viewMode,30,30)%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="7">Segundo Nombre</cellbytelabel></td>
					<td><%=fb.textBox("segundoNom",cdo.getColValue("segundoNom"),false,false,viewMode,30,30)%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="8">Apellido Paterno</cellbytelabel></td>
					<td><%=fb.textBox("primerApell",cdo.getColValue("primerApell"),true,false,viewMode,30,30)%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="9">Apellido Materno</cellbytelabel></td>
					<td><%=fb.textBox("segundoApell",cdo.getColValue("segundoApell"),false,false,viewMode,30,30)%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="10">Seguro Social</cellbytelabel></td>
					<td><%=fb.textBox("seguro",cdo.getColValue("seguro"),false,false,viewMode,13,13)%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="3">Hijos</cellbytelabel></td>
					<td><%=fb.intBox("hijo",cdo.getColValue("hijo"),false,false,viewMode,2,2)%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="11">Lugar de Nacimiento</cellbytelabel></td>
					<td><%=fb.textBox("lugarNaci",cdo.getColValue("lugarNaci"),false,false,viewMode,40,80)%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="12">Religi&oacute;n</cellbytelabel></td>
					<td>
						<%//=fb.intBox("religionCode",cdo.getColValue("religionCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','religionCode,religion')\"")%>
						<%//=fb.textBox("religion",cdo.getColValue("religion"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','religionCode,religion')\"")%>

						<%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion FROM tbl_adm_religion order by codigo asc","religionCode",cdo.getColValue("religionCode"),false,viewMode,0,null,null,null)%>
						<%//=fb.button("btnreligion","...",true,viewMode,null,null,"onClick=\"javascript:addReligion()\"")%>
					</td>

				</tr>

				<tr class="TextRow01">
					<td><cellbytelabel id="13">Nombre del Padre</cellbytelabel></td>
					<td><%=fb.textBox("nomPadre",cdo.getColValue("nomPadre"),false,false,viewMode,40,100)%></td>

				</tr>



				<tr class="TextRow01">
					<td><cellbytelabel id="14">Comida Preferida</cellbytelabel></td>
				<td><%=fb.select(ConMgr.getConnection(),"SELECT comida_id, descripcion FROM tbl_adm_comida order by comida_id asc","comidaId",cdo.getColValue("comidaId"),false,viewMode,0,null,null,null,null,"0")%></td>

			</tr>

			<tr class="TextRow01">
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>

				<!--<tr class="TextRow01">
					<td><cellbytelabel id="15">Datos Correctos</cellbytelabel></td>
					<td><%=fb.select("datosCorrec","S=Sí,N=No",cdo.getColValue("datosCorrec"),false,viewMode,0,null,null,null)%></td>

				</tr>
				<tr class="TextRow01">
					<td>&nbsp;<cellbytelabel id="16">Correcci&oacute;n Fecha Nac.</cellbytelabel></td>
					<td>&nbsp;
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="nameOfTBox1" value="fechaCorrec"/>
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaCorrec")%>"/>
						<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
						</jsp:include>


					</td>
				</tr>-->

				 <tr class="TextRow01">
					<td><cellbytelabel id="17">Preferencia</cellbytelabel></td>
					<td><%=fb.textarea("preferencia",cdo.getColValue("preferencia"),false,false,viewMode,40,4)%></td>

				</tr>

				</table>
			</td>
			<td width="50%">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextRow01">
					<td width="30%"><cellbytelabel id="18">C&eacute;dula</cellbytelabel></td>
					<td width="70%">
						<%=fb.intBox("provincia",cdo.getColValue("provincia"),false,false,viewMode,3,2,null,null,"onBlur=\"javascript:checkProvincia(this)\"")%>
						<%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,viewMode,3,2,null,null,"onBlur=\"javascript:checkSigla(this)\"")%>
						<%=fb.intBox("tomo",cdo.getColValue("tomo"),false,false,viewMode,5,4,null,null,"onBlur=\"javascript:checkTomo(this)\"")%>
						<%=fb.intBox("asiento",cdo.getColValue("asiento"),false,false,viewMode,6,6,null,null,"onBlur=\"javascript:checkAsiento(this)\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="19">Pasaporte</cellbytelabel></td>
					<td><%=fb.textBox("pasaporte",cdo.getColValue("pasaporte"),false,false,viewMode,20,20,null,null,"onBlur=\"javascript:checkPasaporte(this)\"")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="20">C&oacute;digo</cellbytelabel></td>
					<td><%=fb.intBox("codigo",cdo.getColValue("codigo"),false,false,true,5)%>&nbsp;&nbsp;<%=cdox.getColValue("refCodeLabel")%><%=fb.textBox("aptdoPostal",cdo.getColValue("aptdoPostal"),false,false,viewMode,20,20)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="21">Estado Civil</cellbytelabel></td>
				<td><%=fb.select("estadoCivil","ST=Soltero,CS=Casado,DV=Divorciado,UN=Unido,SP=Separado,VD=Viudo",cdo.getColValue("estadoCivil"),true,false,viewMode,0,"")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="22">Sexo</cellbytelabel></td>
					<td><%=fb.select("sexo","M=Masculino,F=Femenino",cdo.getColValue("sexo"),false,viewMode,0,null,null,"onchange=\"ctrlSex(this.value);\"",null,"S")%>
										<authtype type='50'>
										<label class="pointer">
										<%=fb.checkbox("excluido","S",(cdo.getColValue("excluido")!=null && cdo.getColValue("excluido").equalsIgnoreCase("S")),viewMode)%>Exlusi&oacute;n de Atenci&oacute;n al Paciente</label>
										</authtype>
										</td>
				</tr>
				<tr class="TextRow01">
					<td><!--Ingreso Mensual--></td>
					<td><%//=fb.decBox("ingreso_men",cdo.getColValue("ingreso_men"),false,false,viewMode,10,10)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="23">Apellido de Casada</cellbytelabel></td>
					<td><%=fb.textBox("casadaApell",cdo.getColValue("casadaApell"),false,false,viewMode,30,30)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="24">Tipo de Sangre</cellbytelabel></td>
					<td>
						<%=fb.select(ConMgr.getConnection(),"SELECT sangre_id as code, tipo_sangre FROM tbl_bds_tipo_sangre order by tipo_sangre","tipoSangre",cdo.getColValue("tipoSangre"),false,viewMode,0,"S")%>
					</td>
				</tr>

				<tr class="TextRow01">
					<td><cellbytelabel id="26">Nacionalidad</cellbytelabel></td>
					<td>
						<%=fb.intBox("nacionalCode",cdo.getColValue("nacionalCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','nacionalCode,nacional')\"")%>
						<%=fb.textBox("nacional",cdo.getColValue("nacional"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','nacionalCode,nacional')\"")%>
						<%=fb.button("btnnacional","...",true,viewMode,null,null,"onClick=\"javascript:addNacional()\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="27">Estatus</cellbytelabel></td>
					<td>
						<%=fb.select("estatus","A=Activo,I=Inactivo",cdo.getColValue("estatus"),false,viewMode,0,null,null,null)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fallecido&nbsp;?
		<%=fb.checkbox("fallecido","S",(cdo.getColValue("fallecido")!=null && cdo.getColValue("fallecido").equalsIgnoreCase("S")),viewMode,"","","onClick=\"javascript:habFF(this);\"")%>
									 <% if (cdo.getColValue("nh")!=null && !cdo.getColValue("nh").equals("")){%>
											 <strong style="color:#F00; padding-left:10px;"><%=cdo.getColValue("nh")%>&nbsp;</strong>
											 <img src="../images/check.gif" width="20" height="20">
									 <%}%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="28">Nombre de la Madre</cellbytelabel></td>
					<td><%=fb.textBox("nomMadre",cdo.getColValue("nomMadre"),false,false,viewMode,40,100)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="29">Lenguaje Preferido</cellbytelabel></td>
					<td><%=fb.select(ConMgr.getConnection(),"SELECT lenguaje_id, descripcion FROM tbl_adm_lenguaje order by lenguaje_id asc","lenguajeId",cdo.getColValue("lenguajeId"),false,viewMode,0,null,null,null)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="30">Fecha de Fallecido</cellbytelabel></td>
					<td>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="nameOfTBox1" value="fechaFallece"/>
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaFallece")%>"/>
						<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
						<jsp:param name="jsEvent"  value="CalculateAge()"/>
						<jsp:param name="onChange" value="CalculateAge()"/>
						</jsp:include>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="31">Jubilado?</cellbytelabel></td>
					<td><%=fb.checkbox("jubilado","S",(cdo.getColValue("jubilado")!=null && cdo.getColValue("jubilado").equalsIgnoreCase("S")),viewMode)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel  id="32">Deseo</cellbytelabel></td>
					<td><%=fb.textarea("deseo",cdo.getColValue("deseo"),false,false,viewMode,40,4)%></td>

				</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel id="33">Direcci&oacute;n Personal</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel1">
			<td colspan="2">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel id="34">Direcci&oacute;n</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("direccion",cdo.getColValue("direccion"),true,false,viewMode,40,100)%></td>
					<td width="15%"><cellbytelabel id="35">Tipo de Residencia<cellbytelabel></td>
					<td width="35%"><%=fb.select("tipoResi","P=Permanente,T=Temporal",cdo.getColValue("tipoResi"),false,viewMode,0,null,null,null)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="36">Tel&eacute;fono</cellbytelabel></td>
					<td colspan="3"><%=fb.textBox("telefono",cdo.getColValue("telefono"),((cdox.getColValue("telReq").trim().equals("S"))?true:false),false,viewMode,13,13)%>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="37">Ubicaci&oacute;n Geogr&aacute;fica</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="38">Pa&iacute;s</cellbytelabel></td>
					<td>
						<%=fb.intBox("paisCode",cdo.getColValue("paisCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.textBox("pais",cdo.getColValue("pais"),(cdox.getColValue("camposReqUbicGeo").trim().equals("S")?true:false),false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
					</td>
					<td><cellbytelabel id="39">Provincia</cellbytelabel></td>
					<td>
						<%=fb.intBox("provCode",cdo.getColValue("provCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.textBox("prov",cdo.getColValue("prov"),(cdox.getColValue("camposReqUbicGeo").trim().equals("S")?true:false),false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="40">Distrito</cellbytelabel></td>
					<td>
						<%=fb.intBox("distritoCode",cdo.getColValue("distritoCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.textBox("distrito",cdo.getColValue("distrito"),(cdox.getColValue("camposReqUbicGeo").trim().equals("S")?true:false),false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
					</td>
					<td><cellbytelabel id="41">Corregimiento</cellbytelabel></td>
					<td>
						<%=fb.intBox("corregiCode",cdo.getColValue("corregiCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.textBox("corregi",cdo.getColValue("corregi"),(cdox.getColValue("camposReqUbicGeo").trim().equals("S")?true:false),false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbtelabel id="42">Comunidad</cellbtelabel></td>
					<td colspan="3">
						<%=fb.intBox("comunidadCode",cdo.getColValue("comunidadCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.textBox("comunidad",cdo.getColValue("comunidad"),(cdox.getColValue("camposReqUbicGeo").trim().equals("S")?true:false),false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.button("btnpais","...",true,viewMode,null,null,"onClick=\"javascript:addUbica()\"")%>
					</td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="42">Otras Direcciones</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="43">Zona Postal</cellbytelabel></td>
					<td><%=fb.textBox("zonaPostal",cdo.getColValue("zonaPostal"),false,false,viewMode,20,20)%></td>
					<td><cellbytelabel id="44">Correo Electr&oacute;nico</cellbytelabel></td>
					<td><%=fb.emailBox("e_mail",cdo.getColValue("e_mail"),(correoReq.equalsIgnoreCase("S")),false,viewMode,40)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="45">N&uacute;mero Fax</cellbytelabel></td>
					<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,false,viewMode,13,13)%></td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<%} else {%>
				<tr id="panel0">
			<td width="50%" style="vertical-align: top">
				<table width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow01">
					<td width="30%"><cellbytelabel id="2">Tipo ID</cellbytelabel></td>
					<td width="70%"><%=fb.select("tipoId","C=Cedula,P=Pasaporte",cdo.getColValue("tipoId"),false,viewMode,0,null,null,"onChange=\"javascript:setId(true)\"")%>
										<%if(mode.equalsIgnoreCase("edit")){%>
										&nbsp;&nbsp;&nbsp;&nbsp;
										<a href="javascript:showPopWin('../expediente/exp_avatar.jsp?pacId=<%=pacId%>&mode=<%=mode%>',winWidth*.45,winHeight*.40,null,null,'')" class="Link00Bold">Avatar</a>
										<%}%>
										</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="3">Hijos</cellbytelabel></td>
					<td><%=fb.select("d_cedula","D=D,R=R,H1=H1,H2=H2,H3=H3,H4=H4,H5=H5,H6=H6,H7=H7,H8=H8,H9=H9",cdo.getColValue("d_cedula"),false,viewMode,0,null,null,"onChange=\"checkDCedula(this); validateDCedula(this,'P'); "+(usaPlanMedico.equals("S")?"validateDCedula(this,'C');":"")+"\"")%></td>

				</tr>

				<tr class="TextRow01">
					<td><cellbytelabel id="4">Fecha Nacimiento</cellbytelabel></td>
					<td><%=fb.hidden("fechaNaci",cdo.getColValue("fechaNaci"))%>
					<%=fb.hidden("f_nac",cdo.getColValue("f_nac"))%>

						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="nameOfTBox1" value="fechaCorrec"/>
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaCorrec")%>"/>
						<jsp:param name="fieldClass" value="FormDataObjectRequired"/>
						<jsp:param name="readonly" value="<%=(viewMode||!mode.trim().equals("add"))?"y":"n"%>"/>
						<jsp:param name="jsEvent"  value="CalculateAge()"/>
						<jsp:param name="onChange" value="CalculateAge()"/>
						</jsp:include>
						<cellbytelabel id="5">Edad:</cellbytelabel>
						<label id="lbl_edad">&nbsp;</label>

					</td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="6">Primer Nombre</cellbytelabel></td>
					<td><%=fb.textBox("primerNom",cdo.getColValue("primerNom"),true,false,viewMode,30,30)%></td>

				</tr>

				<tr class="TextRow01">
					<td><cellbytelabel id="7">Segundo Nombre</cellbytelabel></td>
					<td><%=fb.textBox("segundoNom",cdo.getColValue("segundoNom"),false,false,viewMode,30,30)%></td>
				</tr>

				<tr class="TextRow01">
					<td><cellbytelabel id="8">Apellido Paterno</cellbytelabel></td>
					<td><%=fb.textBox("primerApell",cdo.getColValue("primerApell"),true,false,viewMode,30,30)%></td>
				</tr>

				<tr class="TextRow01">
					<td><cellbytelabel id="9">Apellido Materno</cellbytelabel></td>
					<td><%=fb.textBox("segundoApell",cdo.getColValue("segundoApell"),false,false,viewMode,30,30)%></td>
				</tr>

				<tr class="TextRow01">
					<td>Direcci&oacute;n</td>
					<td>
					<%=fb.textBox("direccion",cdo.getColValue("direccion"),true,false,viewMode,35,100)%>
					Tipo
					<%=fb.select("tipoResi","P=Permanente,T=Temporal",cdo.getColValue("tipoResi"),false,viewMode,0,null,null,null)%>
					</td>
				</tr>

				<tr class="TextRow01">
					<td><cellbytelabel id="25">Programa Fidelizaci&oacute;n</cellbytelabel></td>
					<td>
						<%=fb.select(ConMgr.getConnection(),"select vip as code, descripcion,empresa FROM tbl_adm_tipo_paciente order by id","vip",cdo.getColValue("vip"),false,(viewMode ||!mode.trim().equals("add")),0,"text10","","onChange=\"javascript:setImagen(this.value,'UPD')\"")%>
						<%=fb.button("btnTipo","...",true,(viewMode||!mode.trim().equals("add")),null,null,"onClick=\"javascript:searchPaciente()\"")%>
						<img id="imagen_vip" src="../images/blank.gif">
					</td>
				</tr>

				</table>
			</td>
			<td width="50%" style="vertical-align: top">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextRow01">
					<td width="30%"><cellbytelabel id="18">C&eacute;dula</cellbytelabel></td>
					<td width="70%">
						<%=fb.intBox("provincia",cdo.getColValue("provincia"),false,false,viewMode,3,2,null,null,"onBlur=\"javascript:checkProvincia(this)\"")%>
						<%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,viewMode,3,2,null,null,"onBlur=\"javascript:checkSigla(this)\"")%>
						<%=fb.intBox("tomo",cdo.getColValue("tomo"),false,false,viewMode,5,4,null,null,"onBlur=\"javascript:checkTomo(this)\"")%>
						<%=fb.intBox("asiento",cdo.getColValue("asiento"),false,false,viewMode,6,6,null,null,"onBlur=\"javascript:checkAsiento(this)\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="19">Pasaporte</cellbytelabel></td>
					<td><%=fb.textBox("pasaporte",cdo.getColValue("pasaporte"),false,false,viewMode,20,20,null,null,"onBlur=\"javascript:checkPasaporte(this)\"")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="20">C&oacute;digo</cellbytelabel></td>
					<td><%=fb.intBox("codigo",cdo.getColValue("codigo"),false,false,true,5)%>&nbsp;&nbsp;<%=cdox.getColValue("refCodeLabel")%><%=fb.textBox("aptdoPostal",cdo.getColValue("aptdoPostal"),false,false,viewMode,20,20)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="21">Estado Civil</cellbytelabel></td>
				<td><%=fb.select("estadoCivil","ST=Soltero,CS=Casado,DV=Divorciado,UN=Unido,SP=Separado,VD=Viudo",cdo.getColValue("estadoCivil"),true,false,viewMode,0,"")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="22">Sexo</cellbytelabel></td>
					<td><%=fb.select("sexo","M=Masculino,F=Femenino",cdo.getColValue("sexo"),false,viewMode,0,null,null,"onchange=\"ctrlSex(this.value);\"",null,"")%>
										<authtype type='50'>
										<label class="pointer">
										<%=fb.checkbox("excluido","S",(cdo.getColValue("excluido")!=null && cdo.getColValue("excluido").equalsIgnoreCase("S")),viewMode)%>Exlusi&oacute;n de Atenci&oacute;n al Paciente</label>
										</authtype>
										</td>
				</tr>
				<tr class="TextRow01">
					<td><!--Ingreso Mensual--></td>
					<td><%//=fb.decBox("ingreso_men",cdo.getColValue("ingreso_men"),false,false,viewMode,10,10)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="23">Apellido de Casada</cellbytelabel></td>
					<td><%=fb.textBox("casadaApell",cdo.getColValue("casadaApell"),false,false,viewMode,30,30)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="24">Tipo de Sangre</cellbytelabel></td>
					<td>
						<%=fb.select(ConMgr.getConnection(),"SELECT sangre_id as code, tipo_sangre FROM tbl_bds_tipo_sangre order by tipo_sangre","tipoSangre",cdo.getColValue("tipoSangre"),false,viewMode,0,"S")%>
					</td>
				</tr>

				<tr class="TextRow01">
					<td><cellbytelabel id="29">Lenguaje Preferido</cellbytelabel></td>
					<td><%=fb.select(ConMgr.getConnection(),"SELECT lenguaje_id, descripcion FROM tbl_adm_lenguaje order by lenguaje_id asc","lenguajeId",cdo.getColValue("lenguajeId"),false,viewMode,0,null,null,null)%></td>
				</tr>

				</table>
			</td>
		</tr>
		<%=fb.hidden("estatus", "A")%>
		<%}%>

		<tr class="TextRow02">
			<td colspan="2" align="right">
				<% if (fp.equalsIgnoreCase("admision") || fp.equalsIgnoreCase("admFP")) { %>
				<%=fb.hidden("saveOption","O")%>
<% } else if (fp.equalsIgnoreCase("admision_list")) { %>
				<%=fb.hidden("saveOption","C")%>
<% } else { %>
				<cellbytelabel id="46">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="68">Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="69">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="70">Cerrar</cellbytelabel>
<% } %>

				<%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".save.value=='Guardar'&&notAValidPassport()==true){error++;}");%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".save.value=='Guardar'&&!isValidId()){error++;}");%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".save.value=='Guardar'&&!validateDCedula()){error++;}");%>
<%fb.appendJsValidation("if(!checkSexo()){error++;}");%>
<%fb.appendJsValidation("if(!checkFidelizacion()){error++;}");%>

<%=fb.formEnd(true)%>
		</table>
</div>


<!--DATOS URGENCIAS TAB1-->
<div class="dhtmlgoodies_aTab">
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("tipo",tipoHuella)%>
<%=fb.hidden("docTypeSize",""+alDoc.size())%>
		<tr>
			<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel id="47">Urgencia y C&oacute;nyugue</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel10">
			<td>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel id="48">Nombre</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("persUrgencia",cdo.getColValue("persUrgencia"),false,false,viewMode,40,100)%></td>
					<td width="15%"><cellbytelabel id="34">Direcci&oacute;n</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("dirUrgencia",cdo.getColValue("dirUrgencia"),false,false,viewMode,40,100)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="49">Tel. Residencia</cellbytelabel></td>
					<td><%=fb.textBox("telUrgencia",cdo.getColValue("telUrgencia"),false,false,viewMode,13,13)%></td>
					<td><cellbytelabel id="50">Tel. Trabajo</cellbytelabel></td>
					<td><%=fb.textBox("telTrabajoUrge",cdo.getColValue("telTrabajoUrge"),false,false,viewMode,13,13)%></td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="51">Datos del C&oacute;nyugue</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="52">Nombre</cellbytelabel></td>
					<td><%=fb.textBox("nomConyugue",cdo.getColValue("nomConyugue"),false,false,viewMode,40,100)%></td>
					<td><cellbytelabel id="53">Lugar de Trabajo</cellbytelabel></td>
					<td><%=fb.textBox("lugarTrabConyugue",cdo.getColValue("lugarTrabConyugue"),false,false,viewMode,40,100)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="49">Tel. Residencia</cellbytelabel></td>
					<td><%=fb.textBox("telTrabConyugue",cdo.getColValue("telTrabConyugue"),false,false,viewMode,13,13)%></td>
					<td><cellbytelabel id="54">Identificaci&oacute;n</cellbytelabel></td>
					<td>
						<%=fb.select("tipoIdConyugue","P=Pasaporte,C=Cédula",cdo.getColValue("tipoIdConyugue"),false,viewMode,0,null,null,null)%>
						<%=fb.textBox("idConyugue",cdo.getColValue("idConyugue"),false,false,viewMode,20,30)%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="26">Nacionalidad</cellbytelabel></td>
					<td colspan="3">
						<%=fb.intBox("conyuNacionalCode",cdo.getColValue("conyuNacionalCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','conyuNacionalCode,conyuNacional')\"")%>
						<%=fb.textBox("conyuNacional",cdo.getColValue("conyuNacional"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','conyuNacionalCode,conyuNacional')\"")%>
						<%=fb.button("btnnacional","...",false,viewMode,null,null,"onClick=\"javascript:addConyuNacional()\"")%>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="4">

<% if (fp.equalsIgnoreCase("admision") || fp.equalsIgnoreCase("admFP")) { %>
						<%=fb.hidden("saveOption","O")%>
<% } else if (fp.equalsIgnoreCase("admision_list")) { %>
						<%=fb.hidden("saveOption","C")%>
<% } else { %>
						Opciones de Guardar:
						<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
						<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
<% } %>
						<%=fb.submit("save","Guardar",true,viewMode)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				</table>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
</div>

<%--TAB DE TRABAJO--%>
<div class="dhtmlgoodies_aTab">
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("tipo",tipoHuella)%>
		<tr>
			<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel id="55">Trabajo</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel20">
			<td>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel id="53">Lugar de Trabajo</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("lugarTrab",cdo.getColValue("lugarTrab"),(cdox.getColValue("camposReq").trim().equals("S")?true:false),false,viewMode,40,80)%></td>
					<td width="15%"><cellbytelabel id="56">Puesto que Ocupa</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("puestoOcu",cdo.getColValue("puestoOcu"),(cdox.getColValue("camposReq").trim().equals("S")?true:false),false,viewMode,40,100)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="34">Direcci&oacute;n</cellbytelabel></td>
					<td><%=fb.textBox("trabDireccion",cdo.getColValue("trabDireccion"),false,false,viewMode,40,100)%></td>
					<td><cellbytelabel id="57">Departamento</cellbytelabel></td>
					<td><%=fb.textBox("deptdoLabora",cdo.getColValue("deptdoLabora"),false,false,viewMode,40,100)%>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="58">Jefe Inmediato</cellbytelabel></td>
					<td><%=fb.textBox("jefeInmediato",cdo.getColValue("jefeInmediato"),false,false,viewMode,40,100)%></td>
					<td><cellbytelabel id="36">Tel&eacute;fono</cellbytelabel></td>
					<td><%=fb.textBox("telTrabajo",cdo.getColValue("telTrabajo"),false,false,viewMode,13,13)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="59">Extensi&oacute;n</cellbytelabel></td>
					<td><%=fb.textBox("extOficina",cdo.getColValue("extOficina"),false,false,viewMode,6,6)%></td>
					<td><cellbytelabel id="60">A&ntilde;os y Meses Laborados</cellbytelabel></td>
					<td><%=fb.intBox("periodoLab",cdo.getColValue("periodoLab"),false,false,viewMode,2,2)%></td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="37">Ubicaci&oacute;n Geogr&aacute;fica</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="38">Pa&iacute;s</cellbytelabel></td>
					<td>
						<%=fb.intBox("trabPaisCode",cdo.getColValue("trabPaisCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','trabPaisCode,trabPais,trabProvCode,trabProv,trabDistritoCode,trabDistrito,trabCorregiCode,trabCorregi')\"")%>
						<%=fb.textBox("trabPais",cdo.getColValue("trabPais"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','trabPaisCode,trabPais,trabProvCode,trabProv,trabDistritoCode,trabDistrito,trabCorregiCode,trabCorregi')\"")%>
						<%=fb.button("btntrabpais","...",false,viewMode,null,null,"onClick=\"javascript:addTrabUbica()\"")%>
					</td>
					<td><cellbytelabel id="39">Provincia</cellbytelabel></td>
					<td>
						<%=fb.intBox("trabProvCode",cdo.getColValue("trabProvCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','trabPaisCode,trabPais,trabProvCode,trabProv,trabDistritoCode,trabDistrito,trabCorregiCode,trabCorregi')\"")%>
						<%=fb.textBox("trabProv",cdo.getColValue("trabProv"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','trabPaisCode,trabPais,trabProvCode,trabProv,trabDistritoCode,trabDistrito,trabCorregiCode,trabCorregi')\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="40">Distrito</cellbytelabel></td>
					<td>
						<%=fb.intBox("trabDistritoCode",cdo.getColValue("trabDistritoCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','trabPaisCode,trabPais,trabProvCode,trabProv,trabDistritoCode,trabDistrito,trabCorregiCode,trabCorregi')\"")%>
						<%=fb.textBox("trabDistrito",cdo.getColValue("trabDistrito"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','trabPaisCode,trabPais,trabProvCode,trabProv,trabDistritoCode,trabDistrito,trabCorregiCode,trabCorregi')\"")%>
					</td>
					<td><cellbytelabel id="41">Corregimiento</cellbytelabel></td>
					<td>
						<%=fb.intBox("trabCorregiCode",cdo.getColValue("trabCorregiCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','trabPaisCode,trabPais,trabProvCode,trabProv,trabDistritoCode,trabDistrito,trabCorregiCode,trabCorregi')\"")%>
						<%=fb.textBox("trabCorregi",cdo.getColValue("trabCorregi"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','trabPaisCode,trabPais,trabProvCode,trabProv,trabDistritoCode,trabDistrito,trabCorregiCode,trabCorregi')\"")%>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="4">

<% if (fp.equalsIgnoreCase("admision") || fp.equalsIgnoreCase("admFP")) { %>
						<%=fb.hidden("saveOption","O")%>
<% } else if (fp.equalsIgnoreCase("admision_list")) { %>
						<%=fb.hidden("saveOption","C")%>
<% } else { %>
						Opciones de Guardar:
						<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
						<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
<% } %>
						<%=fb.submit("save","Guardar",true,viewMode)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				</table>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
</div>

<%--TAB DE CUSTODIO--%>
<div class="dhtmlgoodies_aTab">
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("tipo",tipoHuella)%>
<%=fb.hidden("docTypeSize",""+alDoc.size())%>
		<tr>
			<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel id="61">Custodio</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel30">
			<td>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel id="62">No.Empleado</cellbytelabel></td>
					<td width="25%"><cellbytelabel id="52">Nombre</cellbytelabel></td>
					<td width="20%"><cellbytelabel id="63">Empresa</cellbytelabel></td>
					<td width="20%"><cellbytelabel id="64">Ocupaci&oacute;n</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="26">Nacionalidad</cellbytelabel></td>
					<td width="10%"><%=fb.button("agregar","+",true,viewMode,null,null,"onClick=\"javascript:add()\"")%></td>
				</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo2 = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo2.getColValue("custNoEmpleado")%><%=cdo2.getColValue("secuencia")%></td>
					<td><%=cdo2.getColValue("custNombre")%></td>
					<td><%=cdo2.getColValue("custEmpresa")%></td>
					<td><%=cdo2.getColValue("custOcupacion")%></td>
					<td><%=cdo2.getColValue("custNacional")%></td>
					<td align="center">
<%
	if (!viewMode)
	{
%>
						<a href="javascript:edit(<%=cdo2.getColValue("secuencia")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="65">Editar</cellbytelabel></a>
<%
	}
%>
					</td>
				</tr>
<%
}
%>
				</table>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
</div>

<!-- TAB4 DIV END HERE [SOLICITUD]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","5")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
					<tr class="TextPanel">
						<td colspan="3">TARJETA/CUENTA</td>
						<td align="right">
						</td>
					</tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameTarjeta" id="iFrameTarjeta" frameborder="0" align="center" width="100%" height="350" scrolling="yes" src="../admision/reg_tarjetas_cta.jsp?pac_id=<%=pacId%>&mode=<%=mode%>&tab=6"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
<!-- =============================== HUELLA DIGITAL TAB 5 ============================================ -->
<% if (isFpEnabled) { %>
<!-- TAB5 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
	<iframe name="iFingerprint" id="iFingerprint" frameborder="0" align="center" width="100%" height="590" scrolling="no" src=""></iframe>
</div>
<!-- TAB5 DIV END HERE-->
<% } %>
<!-- =============================== END HUELLA DIGITAL TAB 5 ============================================ -->

</div>
<script type="text/javascript">
<%
String tabInactivo="";
String tabLabel = "'Generales'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Urgencia y Conyuges','Trabajo','Custodio','Forma Pago'";
if (!mode.equalsIgnoreCase("add")){
//tabLabel += ",'Documento'";
if (isFpEnabled && !fp.equalsIgnoreCase("admFP")) tabLabel += ",'Huella Dactilar'";}
%>
//initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,<% if (isFpEnabled) { %>Array()<% } else { %>[]<% } %>,[]);
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,Array(<%=tabFunctions%>),[]);
</script>
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
	fp = request.getParameter("fp");
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_adm_paciente");

	if (tab.equals("0"))
	{
		cdo.addColValue("tipo_id_paciente",request.getParameter("tipoId"));
		if (request.getParameter("provincia") != null)
		cdo.addColValue("provincia",request.getParameter("provincia"));
		if (request.getParameter("sigla") != null)
		cdo.addColValue("sigla",request.getParameter("sigla"));
		if (request.getParameter("tomo") != null)
		cdo.addColValue("tomo",request.getParameter("tomo"));
		if (request.getParameter("asiento") != null)
		cdo.addColValue("asiento",request.getParameter("asiento"));
		cdo.addColValue("d_cedula",request.getParameter("d_cedula"));
		if (request.getParameter("pasaporte") != null)
		cdo.addColValue("pasaporte",request.getParameter("pasaporte"));
		cdo.addColValue("primer_nombre",request.getParameter("primerNom"));
		cdo.addColValue("estado_civil",request.getParameter("estadoCivil"));
		if (request.getParameter("segundoNom") != null)
		cdo.addColValue("segundo_nombre",request.getParameter("segundoNom"));
		cdo.addColValue("sexo",request.getParameter("sexo"));
		if (request.getParameter("primerApell") != null)
		cdo.addColValue("primer_apellido",request.getParameter("primerApell"));
	/*	if (request.getParameter("ingreso_men") != null)
		cdo.addColValue("ingreso_men",request.getParameter("ingreso_men"));*/

		cdo.addColValue("ingreso_men","0");

		if (request.getParameter("segundoApell") != null)
		cdo.addColValue("segundo_apellido",request.getParameter("segundoApell"));
		if (request.getParameter("casadaApell") != null)
		cdo.addColValue("apellido_de_casada",request.getParameter("casadaApell"));
		if (request.getParameter("seguro") != null)
		cdo.addColValue("seguro_social",request.getParameter("seguro"));
		cdo.addColValue("tipo_sangre",request.getParameter("tipoSangre"));
	//	cdo.addColValue("rh",request.getParameter("rh"));
		if (request.getParameter("hijo") != null)
		cdo.addColValue("numero_de_hijos",request.getParameter("hijo"));
		cdo.addColValue("vip",request.getParameter("vip"));
		if (request.getParameter("lugarNaci") != null)
		cdo.addColValue("lugar_nacimiento",request.getParameter("lugarNaci"));
		if (request.getParameter("nacionalCode") != null)
		cdo.addColValue("nacionalidad",request.getParameter("nacionalCode"));
		if (request.getParameter("religionCode") != null)
		cdo.addColValue("religion",request.getParameter("religionCode"));
		if (request.getParameter("fallecido") == null) cdo.addColValue("fallecido","N");
		else cdo.addColValue("fallecido",request.getParameter("fallecido"));
		cdo.addColValue("estatus",request.getParameter("estatus"));
		if (request.getParameter("nomPadre") != null)
		cdo.addColValue("nombre_padre",request.getParameter("nomPadre"));
		if (request.getParameter("nomMadre") != null)
		cdo.addColValue("nombre_madre",request.getParameter("nomMadre"));
		cdo.addColValue("datos_correctos",request.getParameter("datosCorrec"));
		if (request.getParameter("fechaFallece") != null)
		cdo.addColValue("fecha_fallecido",request.getParameter("fechaFallece"));
		if (request.getParameter("fechaCorrec") != null&& (request.getParameter("f_nac") != null && !request.getParameter("f_nac").trim().equals("")))
		cdo.addColValue("f_nac",request.getParameter("fechaCorrec"));
		if (request.getParameter("jubilado") == null) cdo.addColValue("jubilado","N");
		else cdo.addColValue("jubilado",request.getParameter("jubilado"));
				if (request.getParameter("excluido") == null) cdo.addColValue("excluido","N");
		else cdo.addColValue("excluido",request.getParameter("excluido"));
		cdo.addColValue("residencia_direccion",request.getParameter("direccion"));
		cdo.addColValue("tipo_residencia",request.getParameter("tipoResi"));
		if (request.getParameter("telefono") != null)
		cdo.addColValue("telefono",request.getParameter("telefono"));
		if (request.getParameter("paisCode") != null)
		cdo.addColValue("residencia_pais",request.getParameter("paisCode"));
		if (request.getParameter("provCode") != null)
		cdo.addColValue("residencia_provincia",request.getParameter("provCode"));
		if (request.getParameter("distritoCode") != null)
		cdo.addColValue("residencia_distrito",request.getParameter("distritoCode"));
		if (request.getParameter("corregiCode") != null)
		cdo.addColValue("residencia_corregimiento",request.getParameter("corregiCode"));
		if (request.getParameter("comunidadCode") != null)
		cdo.addColValue("residencia_comunidad",request.getParameter("comunidadCode"));
		if (request.getParameter("zonaPostal") != null)
		cdo.addColValue("zona_postal",request.getParameter("zonaPostal"));
		if (request.getParameter("aptdoPostal") != null)
		cdo.addColValue("apartado_postal",request.getParameter("aptdoPostal"));
		if (request.getParameter("fax") != null)
		cdo.addColValue("fax",request.getParameter("fax"));
		if (request.getParameter("e_mail") != null)
		cdo.addColValue("e_mail",request.getParameter("e_mail"));

		if (request.getParameter("comidaId") != null)
		cdo.addColValue("comida_id",request.getParameter("comidaId"));

		if (request.getParameter("lenguajeId") != null)
		cdo.addColValue("lenguaje_id",request.getParameter("lenguajeId"));

		if (request.getParameter("deseo") != null)
		cdo.addColValue("deseo",request.getParameter("deseo"));

		if (request.getParameter("preferencia") != null)
		cdo.addColValue("preferencia",request.getParameter("preferencia"));
		if (request.getParameter("ref_id") != null)cdo.addColValue("ref_id",request.getParameter("ref_id"));


	}
	else if (tab.equals("1"))
	{
		if (request.getParameter("persUrgencia") != null)
		cdo.addColValue("persona_de_urgencia",request.getParameter("persUrgencia"));
		if (request.getParameter("dirUrgencia") != null)
		cdo.addColValue("direccion_de_urgencia",request.getParameter("dirUrgencia"));
		if (request.getParameter("telUrgencia") != null)
		cdo.addColValue("telefono_urgencia",request.getParameter("telUrgencia"));
		if (request.getParameter("telTrabajoUrge") != null)
		cdo.addColValue("telefono_trabajo_urgencia",request.getParameter("telTrabajoUrge"));
		if (request.getParameter("nomConyugue") != null)
		cdo.addColValue("nombre_conyugue",request.getParameter("nomConyugue"));
		if (request.getParameter("lugarTrabConyugue") != null)
		cdo.addColValue("lugar_trabajo_conyugue",request.getParameter("lugarTrabConyugue"));
		if (request.getParameter("telTrabConyugue") != null)
		cdo.addColValue("telefono_trabajo_conyugue",request.getParameter("telTrabConyugue"));
		cdo.addColValue("tipo_identificacion_conyugue",request.getParameter("tipoIdConyugue"));
		if (request.getParameter("idConyugue") != null)
		cdo.addColValue("identificacion_conyugue",request.getParameter("idConyugue"));
		if (request.getParameter("conyuNacionalCode") != null)
		cdo.addColValue("conyugue_nacionalidad",request.getParameter("conyuNacionalCode"));
	}
	else if (tab.equals("2"))
	{
		if (request.getParameter("lugarTrab") != null)
		cdo.addColValue("lugar_trabajo",request.getParameter("lugarTrab"));
		if (request.getParameter("puestoOcu") != null)
		cdo.addColValue("puesto_que_ocupa",request.getParameter("puestoOcu"));
		if (request.getParameter("trabDireccion") != null)
		cdo.addColValue("trabajo_direccion",request.getParameter("trabDireccion"));
		if (request.getParameter("deptdoLabora") != null)
		cdo.addColValue("departamento_donde_labora",request.getParameter("deptdoLabora"));
		if (request.getParameter("jefeInmediato") != null)
		cdo.addColValue("nombre_jefe_inmediato",request.getParameter("jefeInmediato"));
		if (request.getParameter("telTrabajo") != null)
		cdo.addColValue("telefono_trabajo",request.getParameter("telTrabajo"));
		if (request.getParameter("extOficina") != null)
		cdo.addColValue("extension_oficina",request.getParameter("extOficina"));
		if (request.getParameter("periodoLab") != null)
		cdo.addColValue("periodos_laborados",request.getParameter("periodoLab"));
		if (request.getParameter("trabPaisCode") != null)
		cdo.addColValue("trabajo_pais",request.getParameter("trabPaisCode"));
		if (request.getParameter("trabProvCode") != null)
		cdo.addColValue("trabajo_provincia",request.getParameter("trabProvCode"));
		if (request.getParameter("trabDistritoCode") != null)
		cdo.addColValue("trabajo_distrito",request.getParameter("trabDistritoCode"));
		if (request.getParameter("trabCorregiCode") != null)
		cdo.addColValue("trabajo_corregimiento",request.getParameter("trabCorregiCode"));
	}
	else if (tab.equals("4"))
	{
		int size = 0;
		if (request.getParameter("docTypeSize") != null) size = Integer.parseInt(request.getParameter("docTypeSize"));

		al = new ArrayList();
		for (int i=0; i<size; i++)
		{
			CommonDataObject obj = new CommonDataObject();

			obj.setTableName("tbl_adm_paciente_doc");
			obj.setWhereClause("pac_id="+pacId);
			obj.addColValue("pac_id",pacId);
			obj.addColValue("doc_type",request.getParameter("id"+i));
			if (request.getParameter("checked"+i) != null && request.getParameter("checked"+i).equalsIgnoreCase("Y")) al.add(obj);
		}

		if (al.size() == 0)
		{
			CommonDataObject obj = new CommonDataObject();

			obj.setTableName("tbl_adm_paciente_doc");
			obj.setWhereClause("pac_id="+pacId);
			al.add(obj);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}

	if (tab.equals("0") || tab.equals("1") || tab.equals("2"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add"))
		{

			cdo.addColValue("fecha_nacimiento",request.getParameter("fechaCorrec"));
			cdo.addColValue("f_nac","");

			if(tab.equals("0")){
			sbSql = new StringBuffer();
			sbSql.append("select chkPaciente('");
			sbSql.append(IBIZEscapeChars.forSingleQuots(cdo.getColValue("tipo_id_paciente")).trim());
			sbSql.append("', '");
			sbSql.append(cdo.getColValue("provincia"));
			sbSql.append("', '");
			sbSql.append(IBIZEscapeChars.forSingleQuots(cdo.getColValue("sigla")).trim());
			sbSql.append("', '");
			sbSql.append(cdo.getColValue("tomo"));
			sbSql.append("', '");
			sbSql.append(cdo.getColValue("asiento"));
			sbSql.append("', '");
			sbSql.append(IBIZEscapeChars.forSingleQuots(cdo.getColValue("pasaporte")).trim());
			sbSql.append("', '");
			sbSql.append(IBIZEscapeChars.forSingleQuots(cdo.getColValue("d_cedula")).trim());
			sbSql.append("') num_pac from dual");
			CommonDataObject cd = SQLMgr.getData(sbSql.toString());
			if(cd!=null && cd.getColValue("num_pac").equals("N")) throw new Exception("Ya existe esta identificacion!");
		}

			//fechaNaci = request.getParameter("fechaNaci");
			cdo.addColValue("usuario_adiciona",(String) session.getAttribute("_userName")/*UserDet.getUserEmpId()*/);
			cdo.addColValue("usuario_modifica",(String) session.getAttribute("_userName")/*UserDet.getUserEmpId()*/);
			cdo.addColValue("fecha_adiciona","sysdate");//CmnMgr.getCurrentDate("dd/mm/yyyy")
			cdo.addColValue("fecha_modifica","sysdate");//CmnMgr.getCurrentDate("dd/mm/yyyy")
			cdo.addColValue("pac_id","(SELECT nvl(max(pac_id),0)+1 FROM tbl_adm_paciente)");
			cdo.setAutoIncCol("codigo");
			cdo.setAutoIncWhereClause("fecha_nacimiento=to_date('"+request.getParameter("fechaCorrec")+"','dd/mm/yyyy')");
			cdo.addPkColValue("pac_id","");
			cdo.setWhereClause("pac_id=(select max(pac_id) from tbl_adm_paciente)");
			cdo.addColValue("origen_reg","ADM");

			if (fp.equalsIgnoreCase("admFP")) {

				SQLMgr.insert(cdo,true,true,false);
				pacId = SQLMgr.getPkColValue("pac_id");

				if (SQLMgr.getErrCode().equals("1")) {

					CommonDataObject param = new CommonDataObject();
					param.setSql("call sp_bio_save_fp_tmp2owner (?,?,?)");
					param.addInStringStmtParam(1,session.getId());
					param.addInStringStmtParam(2,pacId);
					param.addInStringStmtParam(3,"PAC");
					param = SQLMgr.executeCallable(param,false,true);

				}

			} else {

				SQLMgr.insert(cdo);
				pacId = SQLMgr.getPkColValue("pac_id");

			}

		}
		else
		{
			cdo.addColValue("origen_reg","ADM");
			cdo.addColValue("usuario_modifica",(String) session.getAttribute("_userName")/*UserDet.getUserEmpId()*/);
			cdo.addColValue("fecha_modifica","sysdate");//CmnMgr.getCurrentDate("dd/mm/yyyy")
			cdo.setWhereClause("pac_id="+pacId);
			/*if (CmnMgr.getCount("select count(*) from tbl_cds_detalle_solicitud where pac_id="+pacId+" and cod_sala=885 and num_orden is not null") == 0) SQLMgr.update(cdo);
			else
			{
				String path = null;
				CommonDataObject doc = SQLMgr.getData("select doc_path from tbl_sec_doc_path where upper(doc_code)='RIS_PAC'");
				if (doc != null) path = doc.getColValue("doc_path");
				if (path != null && !path.trim().equals(""))
				{
					HL7 hl7 = new HL7(ConMgr);
					SQLMgr.update(cdo, true, true, false);
					if (SQLMgr.getErrCode().equals("1"))
					{
//		hl7.createFile("ADT", "08", path, (String) session.getAttribute("_companyId"), pacId, null, null, false, true);
	//	hl7.createFile("ADT", "08", path, (String) session.getAttribute("_companyId"), pacId);
						//if (!hl7.getErrCode().equals("1"))
						//{
						//	SQLMgr.setErrCode(hl7.getErrCode());
						//	SQLMgr.setErrMsg(hl7.getErrMsg());
						//}
					}
				}
				else
				{
					if (SQLMgr.getErrCode().equals("1")) SQLMgr.setErrMsg(SQLMgr.getErrMsg()+"\nEl Archivo para la Interfaz RIS no ha sido creada ya que la Ruta para generar el archivo no ha sido especificada");
				}
			}*/
			SQLMgr.update(cdo);
		}

		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<% if (tab.equals("0")) { %>
		<% if (fp.equalsIgnoreCase("admision")) { %>
			<% if (fg.equalsIgnoreCase("upd")){ %>

				window.opener.document.form0.provincia.value='<%=cdo.getColValue("provincia","")%>';
				window.opener.document.form0.sigla.value='<%=cdo.getColValue("sigla","")%>';
				window.opener.document.form0.tomo.value='<%=cdo.getColValue("tomo","")%>';
				window.opener.document.form0.asiento.value='<%=cdo.getColValue("asiento","")%>';
				window.opener.document.form0.pasaporte.value='<%=cdo.getColValue("pasaporte","")%>';
				window.opener.document.form0.dCedula.value='<%=cdo.getColValue("d_cedula","")%>';
				window.opener.document.form0.dCedulaDisplay.value='<%=cdo.getColValue("d_cedula","")%>';
				window.opener.document.form0.nombrePaciente.value='<%=cdo.getColValue("primer_nombre","")%><%=(cdo.getColValue("segundo_nombre","").trim().equals(""))?"":(" "+cdo.getColValue("segundo_nombre",""))%> <%=cdo.getColValue("primer_apellido","")%><%=(cdo.getColValue("segundo_apellido","").trim().equals(""))?"":(" "+cdo.getColValue("segundo_apellido",""))%><%=(cdo.getColValue("apellido_de_casada","").trim().equals(""))?"":(" DE "+cdo.getColValue("apellido_de_casada",""))%>';
				window.opener.document.form0.cod_referencia.value='<%=cdo.getColValue("apartado_postal","")%>';
				//if(window.opener.document.form0.f_nac)window.opener.document.form0.f_nac.value='<%=cdo.getColValue("f_nac","")%>';
				if(window.opener.document.form0.pac_phone)window.opener.document.form0.pac_phone.value='<%=cdo.getColValue("telefono","")%>';
				if(window.opener.document.form0.pac_email)window.opener.document.form0.pac_email.value='<%=cdo.getColValue("e_mail","")%>';
				if(window.opener.document.form0.pac_address)window.opener.document.form0.pac_address.value='<%=cdo.getColValue("residencia_direccion","")%>';
				if(window.opener.document.form0.pac_tipo_sangre)window.opener.document.form0.pac_tipo_sangre.value='<%=cdo.getColValue("tipo_sangre","")%>';
				window.opener.loadXtraInfo();
				window.close();

			<% } else if (catAdm.equalsIgnoreCase("OPD")) { %>
					if (window.opener) window.opener.location = '<%=request.getContextPath()%>/common/search_paciente.jsp?fp=admision&pacId=<%=pacId%>&cat_adm=<%=catAdm%>&context=<%=context%>&status=A';
					window.close();
			<% } else { %>
				if (window.opener) window.opener.location = '<%=request.getContextPath()%>/common/search_paciente.jsp?fp=admision&pacId=<%=pacId%>&status=A';

				// window.opener.location.reload(true);
				// = '<%=request.getContextPath()%>/common/search_paciente.jsp?fp=admision';
			<% } %>
		<% } else if (fp.equalsIgnoreCase("admFP")) { %>
	window.opener.parent.reloadPage('<%=pacId%>');
		<% } else if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/paciente_list.jsp")) { %>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/paciente_list.jsp")%>';
		<% } else if (fp.equalsIgnoreCase("atencion_express")) { %>
	window.opener.location.reload(true);
		<% } else { %>
	window.opener.location = '<%=request.getContextPath()%>/admision/paciente_list.jsp';
		<% } %>
	<% }
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
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&cat_adm=<%=catAdm%>&context=<%=context%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&cat_adm=<%=catAdm%>&context=<%=context%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>