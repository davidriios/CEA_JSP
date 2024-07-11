<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.File"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.HL7"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.planmedico.Cliente"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="CltMgr" scope="page" class="issi.planmedico.ClienteMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CltMgr.setConnection(ConMgr);

boolean isFpEnabled = CmnMgr.isValidFpType("PAC");
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String clientId = request.getParameter("clientId");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String popWinFunction = "abrir_ventana1";
String tipoHuella = request.getParameter("tipo");
String pac_id = request.getParameter("pac_id");
String id_cliente = request.getParameter("id_cliente");
int hasHuella = 0;
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fechaIni = request.getParameter("fechaIni") == null?cDate:request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin") == null?cDate:request.getParameter("fechaFin");
String showFacVal = request.getParameter("showFac") == null?"0":request.getParameter("showFac");
String clientName = request.getParameter("clientName") == null?"0":request.getParameter("clientName");

boolean showFac = Integer.parseInt(showFacVal) > 0 ? true : false;

if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (pac_id == null) pac_id = "";
if (!mode.equalsIgnoreCase("add") && !mode.equalsIgnoreCase("edit")) viewMode = true;
if (fp == null) fp = "";
if (fg == null) fg = "";
if (fp.equalsIgnoreCase("admision")) popWinFunction = "abrir_ventana3";
if (tipoHuella == null ) tipoHuella = "ADM";
String tabFunctions = "'1=tabFunctions(1)', '2=tabFunctions(2)', '5=tabFunctions(5)'";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	XMLCreator xml = new XMLCreator(ConMgr);
	xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"rh_x_tiposangre.xml","select rh as value_col, rh as label_col, tipo_sangre as key_col from tbl_bds_tipo_sangre order by 3,2");
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
		if(!pac_id.equals("")){
		sbSql = new StringBuffer();
		sbSql.append("select ' ' deseo, ' ' preferencia, a.tipo_id_paciente as tipoid, nvl (a.provincia, '') provincia, nvl (a.sigla, '') sigla, nvl (a.tomo, '') tomo, nvl (a.asiento, '') asiento, nvl (a.d_cedula, '') d_cedula, nvl (a.pasaporte, '') pasaporte, to_char (a.fecha_nacimiento, 'dd/mm/yyyy') as fechanaci, a.codigo, a.primer_nombre as primernom, a.estado_civil as estadocivil, a.segundo_nombre as segundonom, a.sexo, a.primer_apellido as primerapell, a.segundo_apellido as segundoapell, a.apellido_de_casada as casadaapell, a.seguro_social as seguro, a.rh, ts.tipo_sangre as tiposangre, '' nh, a.numero_de_hijos as hijo, a.vip, a.lugar_nacimiento as lugarnaci, a.nacionalidad as nacionalcode, b.nacionalidad as nacional, a.religion as religioncode, c.descripcion as religion, a.estatus, a.fallecido, a.nombre_padre as nompadre, a.nombre_madre as nommadre, a.datos_correctos as datoscorrec, to_char (a.fecha_fallecido, 'dd/mm/yyyy') as fechafallece, to_char (a.f_nac, 'dd/mm/yyyy') as fechacorrec, a.jubilado, a.residencia_direccion as direccion, a.tipo_residencia as tiporesi, a.telefono, a.residencia_pais as paiscode, decode (a.residencia_pais, null, null, d.nombre_pais) as pais, a.residencia_provincia as provcode, decode (a.residencia_provincia, null, null, d.nombre_provincia) as prov, a.residencia_distrito as distritocode, decode (a.residencia_distrito, null, null, d.nombre_distrito) as distrito, a.residencia_corregimiento as corregicode, decode (a.residencia_corregimiento, null, null, d.nombre_corregimiento) as corregi, a.residencia_comunidad as comunidadcode, decode (a.residencia_comunidad, null, null, d.nombre_comunidad) as comunidad, a.zona_postal as zonapostal, a.apartado_postal as apartado_postal, a.fax, nvl (a.e_mail, 'sincorreo@dominio.com') e_mail, a.persona_de_urgencia as persurgencia, a.direccion_de_urgencia as dirurgencia, a.telefono_urgencia as telurgencia, a.telefono_trabajo_urgencia as teltrabajourge, ' ' id_empresa, ' ' lt_nombre, ' ' lt_direccion, ' ' lt_telefono, a.puesto_que_ocupa, ' ' residencia_no, a.telefono_movil from tbl_adm_paciente a, tbl_sec_pais b, tbl_adm_religion c, vw_sec_regional_location d ,tbl_bds_tipo_sangre ts  where a.nacionalidad = b.codigo(+) and a.religion = c.codigo(+) and nvl (a.residencia_pais, 0) = d.codigo_pais(+) and nvl (a.residencia_provincia, 0) = d.codigo_provincia(+) and nvl (a.residencia_distrito, 0) = d.codigo_distrito(+) and nvl (a.residencia_corregimiento, 0) = d.codigo_corregimiento(+) and nvl (a.residencia_comunidad, 0) = d.codigo_comunidad(+) and to_char(ts.sangre_id(+)) = to_char(a.tipo_sangre) and a.pac_id = ");
		sbSql.append(pac_id);
		cdo = SQLMgr.getData(sbSql.toString());
		} else if(fp.equals("plan_medico") && fg.equals("beneficiario") && id_cliente != null && !id_cliente.equals("")){
			sbSql.append("select a.deseo,a.preferencia ,a.tipo_id_paciente as tipoId, '' provincia, '' sigla, '' tomo, '' asiento, '' d_cedula, '' pasaporte, '' as fechaNaci, '' codigo, '' as primerNom, a.estado_civil as estadoCivil, '' as segundoNom, '' sexo, ''  as primerApell, '' as segundoApell, '' as casadaApell, '' as seguro, a.rh, a.tipo_sangre as tipoSangre, decode(a.nh,'S','Nació en el hospital',null,' ') nh, a.numero_de_hijos as hijo, a.vip, a.lugar_nacimiento as lugarNaci, a.nacionalidad as nacionalCode, b.nacionalidad as nacional, a.religion as religionCode, c.descripcion as religion, a.estatus, a.fallecido, a.nombre_padre as nomPadre, a.nombre_madre as nomMadre, a.datos_correctos as datosCorrec, to_char(a.fecha_fallecido,'dd/mm/yyyy') as fechafallece, to_char(a.f_nac,'dd/mm/yyyy') as fechaCorrec, a.jubilado, a.residencia_direccion as direccion, a.tipo_residencia as tipoResi, a.telefono, a.residencia_pais as paisCode, decode(a.residencia_pais,null,null,d.nombre_pais) as pais, a.residencia_provincia as provCode, decode(a.residencia_provincia,null,null,d.nombre_provincia) as prov, a.residencia_distrito as distritoCode, decode(a.residencia_distrito,null,null,d.nombre_distrito) as distrito, a.residencia_corregimiento as corregiCode, decode(a.residencia_corregimiento,null,null,d.nombre_corregimiento) as corregi, a.residencia_comunidad as comunidadCode, decode(a.residencia_comunidad,null,null,d.nombre_comunidad) as comunidad, a.zona_postal as zonaPostal, a.apartado_postal as apartado_postal, a.fax, nvl(a.e_mail,'sincorreo@dominio.com')e_mail, a.persona_de_urgencia as persUrgencia, a.direccion_de_urgencia as dirUrgencia, a.telefono_urgencia as telUrgencia, a.telefono_trabajo_urgencia as telTrabajoUrge, a.id_empresa, nvl(e.nombre, ' ') lt_nombre, nvl(e.direccion, ' ') lt_direccion, nvl(e.telefono, ' ') lt_telefono, a.puesto_que_ocupa, a.residencia_no, a.telefono_movil FROM tbl_pm_cliente a , tbl_sec_pais b, tbl_adm_religion c, vw_sec_regional_location d, tbl_pm_empresa e WHERE a.nacionalidad = b.codigo(+) and a.religion = c.codigo(+) and nvl(a.residencia_pais,0) = d.codigo_pais(+) and nvl(a.residencia_provincia,0)=d.codigo_provincia(+) and nvl(a.residencia_distrito,0)=d.codigo_distrito(+) and nvl(a.residencia_corregimiento,0)=d.codigo_corregimiento(+) and nvl(a.residencia_comunidad,0)=d.codigo_comunidad(+) and a.id_empresa = e.id_empresa(+) and a.codigo = ");
		sbSql.append(id_cliente);
		cdo = SQLMgr.getData(sbSql.toString());
		}
		sbSql = new StringBuffer();
		sbSql.append("select a.id id_pregunta, a.pregunta, a.tipo_pregunta, ' ' respuesta, ' ' detalle, 0 id from tbl_pm_cuestionario_salud a where a.estado = 'A' order by a.id");
		al = SQLMgr.getDataList(sbSql.toString());

	}else{

		if (clientId == null) throw new Exception("El Ciente no es válido. Por favor intente nuevamente!");

		sbSql.append("select a.deseo,a.preferencia ,a.tipo_id_paciente as tipoId, nvl(a.provincia,'')provincia, nvl(a.sigla,'')sigla, nvl(a.tomo,'')tomo, nvl(a.asiento,'')asiento, nvl(a.d_cedula,'')d_cedula, nvl(a.pasaporte,'')pasaporte, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNaci, a.codigo, a.primer_nombre as primerNom, a.estado_civil as estadoCivil, a.segundo_nombre as segundoNom, a.sexo, a.primer_apellido as primerApell, a.segundo_apellido as segundoApell, a.apellido_de_casada as casadaApell, a.seguro_social as seguro, a.rh, a.tipo_sangre as tipoSangre, decode(a.nh,'S','Nació en el hospital',null,' ') nh, a.numero_de_hijos as hijo, a.vip, a.lugar_nacimiento as lugarNaci, a.nacionalidad as nacionalCode, b.nacionalidad as nacional, a.religion as religionCode, c.descripcion as religion, a.estatus, a.fallecido, a.nombre_padre as nomPadre, a.nombre_madre as nomMadre, a.datos_correctos as datosCorrec, to_char(a.fecha_fallecido,'dd/mm/yyyy') as fechafallece, to_char(a.f_nac,'dd/mm/yyyy') as fechaCorrec, a.jubilado, a.residencia_direccion as direccion, a.tipo_residencia as tipoResi, a.telefono, a.residencia_pais as paisCode, decode(a.residencia_pais,null,null,d.nombre_pais) as pais, a.residencia_provincia as provCode, decode(a.residencia_provincia,null,null,d.nombre_provincia) as prov, a.residencia_distrito as distritoCode, decode(a.residencia_distrito,null,null,d.nombre_distrito) as distrito, a.residencia_corregimiento as corregiCode, decode(a.residencia_corregimiento,null,null,d.nombre_corregimiento) as corregi, a.residencia_comunidad as comunidadCode, decode(a.residencia_comunidad,null,null,d.nombre_comunidad) as comunidad, a.zona_postal as zonaPostal, a.apartado_postal as apartado_postal, a.fax, nvl(a.e_mail,'sincorreo@dominio.com')e_mail, a.persona_de_urgencia as persUrgencia, a.direccion_de_urgencia as dirUrgencia, a.telefono_urgencia as telUrgencia, a.telefono_trabajo_urgencia as telTrabajoUrge, a.id_empresa, nvl(e.nombre, ' ') lt_nombre, nvl(e.direccion, ' ') lt_direccion, nvl(e.telefono, ' ') lt_telefono, a.puesto_que_ocupa, a.residencia_no, a.telefono_movil FROM tbl_pm_cliente a , tbl_sec_pais b, tbl_adm_religion c, vw_sec_regional_location d, tbl_pm_empresa e WHERE a.nacionalidad = b.codigo(+) and a.religion = c.codigo(+) and nvl(a.residencia_pais,0) = d.codigo_pais(+) and nvl(a.residencia_provincia,0)=d.codigo_provincia(+) and nvl(a.residencia_distrito,0)=d.codigo_distrito(+) and nvl(a.residencia_corregimiento,0)=d.codigo_corregimiento(+) and nvl(a.residencia_comunidad,0)=d.codigo_comunidad(+) and a.id_empresa = e.id_empresa(+) and a.codigo = ");
		sbSql.append(clientId);
		cdo = SQLMgr.getData(sbSql.toString());

		sbSql = new StringBuffer();
		sbSql.append("select a.id id_pregunta, a.pregunta, a.tipo_pregunta, nvl(b.respuesta, ' ') respuesta, nvl(b.detalle, ' ') detalle, nvl(b.id, 0) id from tbl_pm_cuestionario_salud a, tbl_pm_cliente_cuestionario b where a.estado = 'A' and a.id = b.id_pregunta(+)");
		sbSql.append(" and id_cliente(+) = ");
		sbSql.append(clientId);
		sbSql.append(" order by a.id");

		al = SQLMgr.getDataList(sbSql.toString());
	}

	System.out.println("::::::::::::::::::::::::::::::::::::::::::::::: TAB ="+tab);
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Mantenimiento de Paciente - '+document.title;
function addNacional(){<%=popWinFunction%>('../common/search_pais.jsp?fp=paciente_nac');}
function addReligion(){<%=popWinFunction%>('../common/search_religion.jsp?fp=paciente');}
function addUbica(){<%=popWinFunction%>('../common/search_ubicacion_geo.jsp?fp=paciente_ubica');}
function addConyuNacional(){<%=popWinFunction%>('../common/search_pais.jsp?fp=paciente_conyu_nac');}
function addTrabUbica(){<%=popWinFunction%>('../common/search_ubicacion_geo.jsp?fp=paciente_trabajo');}
function addEmpresa(){<%=popWinFunction%>('../planmedico/pm_sel_empresa.jsp?fp=cliente');}
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

function doAction()
{
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
	var save = document.form0.save.value;
	if(document.form0.check_cedula.value=='S'){
	if (document.form0.tipoId.value == 'C')
	{
		var provincia=document.form0.provincia.value.trim();
		var sigla=document.form0.sigla.value.trim();
		var tomo=document.form0.tomo.value.trim();
		var asiento=document.form0.asiento.value.trim();
		var dCedula=document.form0.d_cedula.value.trim();
		var codigo=document.form0.clientId.value.trim();

		var provinciaE='<%=cdo.getColValue("provincia").trim()%>';
		var siglaE='<%=cdo.getColValue("sigla").trim().replaceAll("'","\\\\'")%>';
		var tomoE='<%=cdo.getColValue("tomo").trim()%>';
		var asientoE='<%=cdo.getColValue("asiento").trim()%>';
		var dCedulaE='<%=cdo.getColValue("d_cedula").trim()%>';

		if(provincia==''||sigla==''||tomo==''||asiento=='')
		{
			alert('Introduzca o complete el número de CEDULA!');
			return false;
		}
		else{
				if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
				{
					 alert('Valores invalidos en numero de cedula! Revise..')
				}
				else
				{
					 if(provinciaE!=provincia||''!=sigla||siglaE!=tomo||asientoE!=asiento||dCedulaE!=dCedula)
					{
						if(hasDBData('<%=request.getContextPath()%>','tbl_pm_cliente','provincia='+provincia+' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo='+tomo+' and asiento='+asiento+' and d_cedula=\''+dCedula+'\' /*and codigo != '+codigo+'*/',''))
						{
							alert('Ya existe un cliente con este número de CEDULA!');
							return false;
						} else if(hasDBData('<%=request.getContextPath()%>','tbl_adm_paciente','provincia='+provincia+' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo='+tomo+' and asiento='+asiento+' and d_cedula=\''+dCedula+'\' /*and codigo != '+codigo+'*/',''))
						{
							if(save == ''){alert('Ya existe un paciente con este número de CEDULA!');
							return false;}
						}
					}
				}
	  		}
	}
	else if (document.form0.tipoId.value == 'P')
	{
		var pasaporte=document.form0.pasaporte.value.trim();
		var pasaporteE='<%=cdo.getColValue("pasaporte").trim()%>';
		if(pasaporte=='')
		{
			alert('Introduzca el número de PASAPORTE!');
			return false;
		}
		else if('<%=cdo.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>'!=pasaporte||'<%=cdo.getColValue("d_cedula").trim()%>'!=dCedula)
		{
			if(hasDBData('<%=request.getContextPath()%>','tbl_pm_cliente','pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula=\''+dCedula+'\'',''))
			{
				alert('Ya existe un cliente con este número de PASAPORTE!');
				return false;
			} else if(hasDBData('<%=request.getContextPath()%>','tbl_adm_paciente','pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula=\''+dCedula+'\'',''))
			{
				if(save == ''){alert('Ya existe un paciente con este número de PASAPORTE!');
				return false;}
			}
		}
	}
	}
	return true;
}

function checkCedula(obj)
{
<%
	if (!viewMode)
	{
%>
	document.form0.check_cedula.value='S';
	var provincia=document.form0.provincia.value.trim();
	var sigla=document.form0.sigla.value.trim();
	var tomo=document.form0.tomo.value.trim();
	var asiento=document.form0.asiento.value.trim();
	var dCedula=document.form0.d_cedula.value.trim();
	var default_val = '';
	if(obj.name=='provincia') default_val = '<%=cdo.getColValue("provincia").trim()%>';
	else if(obj.name=='sigla') default_val = '<%=cdo.getColValue("sigla").trim()%>';
	else if(obj.name=='tomo') default_val = '<%=cdo.getColValue("tomo").trim()%>';
	else if(obj.name=='asiento') default_val = '<%=cdo.getColValue("asiento").trim()%>';
		if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'',default_val))
			{
				 obj.value = '';
				 return true;
			} else if(hasDBData('<%=request.getContextPath()%>','tbl_adm_paciente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+dCedula+'\'' + ('<%=mode%>'=='edit'?' and \''+obj.value + '\' != \''+default_val+'\'':''))){
				alert('Cedula ya registrada en Pacientes!');
				obj.value = '';
				return true;
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
	var default_val = '<%=cdo.getColValue("pasaporte").trim()%>';
	if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'P\' and pasaporte=\''+obj.value+'\' and d_cedula=\''+dCedula+'\'','<%=cdo.getColValue("pasaporte").trim().replaceAll("'","\\\\'")%>')) return true;
	else if(hasDBData('<%=request.getContextPath()%>','tbl_adm_paciente','tipo_id_paciente=\'P\' and pasaporte=\''+obj.value+'\' and d_cedula=\''+dCedula+'\'')){
				alert('Cedula ya registrada en Pacientes!');
				obj.value = '';
				return true;
			}

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
		var default_val = '<%=cdo.getColValue("d_cedula").trim()%>';
		if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
		{
			 alert('Valores invalidos en numero de cedula! Revise..')
		}
		else
		{
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+obj.value+'\'','<%=cdo.getColValue("d_cedula").trim()%>')) return true;
			else  if(hasDBData('<%=request.getContextPath()%>','tbl_adm_paciente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula=\''+obj.value+'\'')){
				alert('Cedula ya registrada en Pacientes!');
				obj.value = '';
				return true;
			}
		}
	}
	else if(tipoId='P')
	{
		var pasaporte=document.form0.pasaporte.value.trim();
		if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pm_cliente','tipo_id_paciente=\'P\' and pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula=\''+obj.value+'\'','<%=cdo.getColValue("d_cedula").trim()%>')) return true;
		else if(hasDBData('<%=request.getContextPath()%>','tbl_adm_paciente','tipo_id_paciente=\'P\' and pasaporte=\''+obj.value+'\' and d_cedula=\''+dCedula+'\' and \''+obj.value + '\' != \''+default_val+'\'')){
				alert('Cedula ya registrada en Pacientes!');
				obj.value = '';
				return true;
			}
	}
}

function setImagen(valor)
{
	var source = '';
	if(valor=='N') source = '../images/blank.gif';
	else if(valor=='S') source = '../images/ico-vip.JPG';
	else if(valor=='D') source = '../images/ico-distinguido.JPG';
	else if(valor=='M') source = '../images/ico-medico.JPG';
	else if(valor=='J') source = '../images/ico-junta-dir.JPG';
	document.getElementById('imagen_vip').src=source;
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
	var fecha = document.form0.fechaNaci.value;

	if(fecha!=''){
	if(isValidateDate(document.form0.fechaNaci.value)){
		var sql = 'nvl(trunc(months_between(sysdate, to_date(\''+fecha+'\', \'dd/mm/yyyy\'))/12),0) || \' A&ntilde;os \' || nvl(mod(trunc(months_between(sysdate, to_date(\''+fecha+'\', \'dd/mm/yyyy\'))),12),0) || \' Meses \' || trunc(sysdate-add_months(to_date(\''+fecha+'\', \'dd/mm/yyyy\'),(nvl(trunc(months_between(sysdate,to_date(\''+fecha+'\', \'dd/mm/yyyy\'))/12),0)*12+nvl(mod(trunc(months_between(sysdate,to_date(\''+fecha+'\', \'dd/mm/yyyy\'))),12),0)))) || \' Dias \'';
		var data = splitRowsCols(getDBData('<%=request.getContextPath()%>',sql,'dual','',''));
		document.getElementById('lbl_edad').innerHTML = data;
	}else alert('Valor Invalido en Fecha Nacimiento!!');}
}

function habFF(){
	var obj = document.form0.fallecido;
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
		return true;
	}

}

function validateDCedula(obj){

	var tipoId=document.form0.tipoId.value;
	var nextValidSecuence = 0;
    var userSecuence = 0;
	var values = new Array();
	var r;
	var dCedula = "";
	var mode = "<%=mode%>";

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
			var codigo=document.form0.clientId.value.trim();
			if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
			{
				 alert('Valores invalidos en numero de cedula!   Revise..')
			}
			else
			{
				<%if(mode.equals("edit")){%>
				r = splitRowsCols(getDBData('<%=request.getContextPath()%>','d_cedula','tbl_pm_cliente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula like \'%H%\' /*and codigo != '+codigo+'*/'));
				<%} else {%>
				r = splitRowsCols(getDBData('<%=request.getContextPath()%>','d_cedula','tbl_pm_cliente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula like \'%H%\''));
				<%}%>
			}
		}
		else if(tipoId=='P')
		{
			var pasaporte=document.form0.pasaporte.value.trim();
			r = splitRowsCols(getDBData('<%=request.getContextPath()%>','d_cedula','tbl_pm_cliente','tipo_id_paciente=\'P\' and pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula like \'%H%\''));
		}

		if ( r!=null){values = (""+r).replace(/[A-Za-z]/gi,"").split(",");if ( mode === "add" ){nextValidSecuence = parseInt(values.sort(function(a,b){return b-a;})[0],10) + 1;		}else{if(document.form0.old_d_cedula.value != dCedula ){
		nextValidSecuence =userSecuence;
		for (var i = 0; i < r.length; i++){if (r[i] == 'H'+nextValidSecuence){nextValidSecuence++;}

		 //nextValidSecuence = parseInt(values.sort(function(a,b){return b-a;})[0],10);
		 }
				}else{nextValidSecuence =userSecuence;}}
				if ( userSecuence != nextValidSecuence ){

				   alert("Lo sentimos, pero debe continuar con H"+nextValidSecuence);

				   return false;
				}else{return true;}
		}else{
			  nextValidSecuence=1;
			  if ( userSecuence != nextValidSecuence ){
				   alert("Lo sentimos, pero debe empezar con H"+nextValidSecuence);

				   return false;
			  }else{return true;}
		}

	}else{return true;}
}

function chkDireccion(){if((document.form0.direccion.value).trim()=='' ){alert('Introduzca Direccion Valida');return false;}return true;}
function tabFunctions(tab){
	var iFrameName = '';
	if(tab==1) iFrameName='iFrameSeg';
	else if(tab==2) iFrameName='iFrameNota';
	else if(tab==3) iFrameName='iFrameFacturas';
	else if(tab==4) iFrameName='iFramePagos';
	else if(tab==5) iFrameName='iFrameFacturasRes';
	window.frames[iFrameName].doAction();
}
//3 2 add
function showInfo(tab, id, mode){
	var iFrameName = '', page = '';
	if(tab==1){
		iFrameName='iFrameSeg';
		page = '../planmedico/reg_seguimiento.jsp?id_trx=<%=clientId%>&id='+id+'&mode='+mode+'&tipo=CLIENTE';
	} else if(tab==2){
		iFrameName='iFrameNota';
		page = '../planmedico/reg_notas.jsp?id_trx=<%=clientId%>&id='+id+'&mode='+mode+'&tipo=CLIENTE';
	}
	window.frames[iFrameName].location=page;
}

function chkRespuesta(){
	var size = document.form0.respSize.value;
	var err = 0;
	for(i=0;i<size;i++){
		if(eval('document.form0.respuesta'+i) && eval('document.form0.respuesta'+i).value=='S' && eval('document.form0.detalle'+i).value==''){
			err++;
			alert('Introduzca Detalle de Respuesta '+(i+1));
			break;
		}
	}
	if(err==0) return true;
	else return false;
}

function _goAndFilter(opt){

  var fechaIni = $("#fechaIni"+opt).val();
  var fechaFin = $("#fechaFin"+opt).val();
  var estadoFact = "";
  
  switch (opt){
    case 'F':
        estadoFact = $("#estadofactF").val();
		window.frames["iFrameFacturas"].location = "../planmedico/pm_facturas_list.jsp?&clientId=<%=clientId%>&mode=edit&tab=3&fechaIni="+fechaIni+"&fechaFin="+fechaFin+"&estadoFact="+estadoFact;
	break;
	case 'P':
		window.frames["iFramePagos"].location = "../planmedico/pm_estado_cuenta_list.jsp?clientId=<%=clientId%>&clientName=<%=clientName%>&tab=4&fechaIni="+fechaIni+"&fechaFin="+fechaFin;
	break;
    case 'FR':
        estadoFact = $("#estadofactFR").val();
		window.frames["iFrameFacturasRes"].location = "../planmedico/pm_facturas_list_res.jsp?&clientId=<%=clientId%>&mode=edit&tab=5&fechaIni="+fechaIni+"&fechaFin="+fechaFin+"&estadoFact="+estadoFact;
	break;
	default: alert("No encontramos esta opción!");

  }
}

function _goAndPrint(opt){
  var fechaIni = $("#fechaIni"+opt).val();
  var fechaFin = $("#fechaFin"+opt).val();
  var estadoFact = "";
  switch (opt){
    case 'F':
	estadoFact = $("#estadofactF").val();
	abrir_ventana("../planmedico/pm_print_facturas_list.jsp?clientId=<%=clientId%>&fechaIni="+fechaIni+"&fechaFin="+fechaFin+"&estadoFact="+estadoFact);
	break;
	case 'P': abrir_ventana("../planmedico/print_estado_cuenta.jsp?clientId=<%=clientId%>&clientName=<%=clientName%>&fechaIni="+fechaIni+"&fechaFin="+fechaFin);
	break;
	case 'EC': abrir_ventana("../planmedico/print_estado_cuenta.jsp?clientId=<%=clientId%>&clientName=<%=clientName%>&fechaIni="+fechaIni+"&fechaFin="+fechaFin);
	break;
	default: alert("No encontramos esta opción!");

  }
}

function reloadParent(tab){
  var p = (parent.window.location.href).replace(/&tab=\d+/gi,"");
  return parent.window.location = p+"&tab="+tab;
}

$(document).ready(function(){
   $("#tabTabdhtmlgoodies_tabView1_3").click(function(){
	   reloadParent(3);
   });
   $("#tabTabdhtmlgoodies_tabView1_4").click(function(){
       reloadParent(4);
   });
});

function showPacienteList()
{
	abrir_ventana1('../common/search_paciente.jsp?fp=<%=fp%>&fg=<%=fg%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLAN MEDICO - MANTENIMIENTO - CLIENTE"></jsp:param>
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
<%=fb.hidden("clientId",clientId)%>
<%=fb.hidden("tipo",tipoHuella)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("old_d_cedula",""+cdo.getColValue("d_cedula"))%>
<%=fb.hidden("check_cedula","N")%>
<%=fb.hidden("id_cliente",id_cliente)%>

<%fb.appendJsValidation("if(document.form0.fechaNaci.value==''){alert('Por favor ingrese la Fecha de Nacimiento!');error++;}");%>
<%fb.appendJsValidation("if(!habFF()){alert('Por favor ingrese la Fecha de Fallecimiento!'+habFF());error++;}");%>
<%fb.appendJsValidation("if(!chkDireccion()){error++;}");%>
<%fb.appendJsValidation("if(!chkRespuesta()){error++;}");%>

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
		<tr id="panel0">
			<td width="50%">
				<table width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow01">
					<td width="30%"><cellbytelabel id="2">Tipo ID</cellbytelabel></td>
					<td width="70%"><%=fb.select("tipoId","C=Cedula,P=Pasaporte",cdo.getColValue("tipoId"),false,viewMode,0,null,null,"onChange=\"javascript:setId(true)\"")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="3">Hijos</cellbytelabel></td>
					<td><%=fb.select("d_cedula","D=D,R=R,H1=H1,H2=H2,H3=H3,H4=H4,H5=H5,H6=H6,H7=H7,H8=H8,H9=H9",cdo.getColValue("d_cedula"),false,viewMode,0,null,null,"onChange=\"checkDCedula(this); validateDCedula(this)\"")%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="4">Fecha Nacimiento</cellbytelabel></td>
					<td>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fechaNaci" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaNaci")%>" />
						<jsp:param name="fieldClass" value="FormDataObjectRequired" />
						<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>" />
            <jsp:param name="jsEvent"  value="CalculateAge()" />
            <jsp:param name="onChange" value="CalculateAge()" />
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


<!--
				<tr class="TextRow01">
					<td><cellbytelabel id="14">Comida Preferida</cellbytelabel></td>
				<td><%//=fb.select(ConMgr.getConnection(),"SELECT comida_id, descripcion FROM tbl_adm_comida order by comida_id asc","comidaId",cdo.getColValue("comidaId"),false,viewMode,0,null,null,null,null,"0")%></td>

			</tr>-->
				<tr class="TextRow01">
					<td><cellbytelabel id="15">Datos Correctos</cellbytelabel></td>
					<td><%=fb.select("datosCorrec","S=Si,N=No",cdo.getColValue("datosCorrec"),false,viewMode,0,null,null,null)%></td>

				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="16">Correcci&oacute;n Fecha Nac.</cellbytelabel></td>
					<td>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fechaCorrec" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaCorrec")%>" />
						<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>" />
						</jsp:include>
					</td>

				</tr>

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
						<%=fb.intBox("provincia",cdo.getColValue("provincia"),false,false,viewMode,3,2,null,null,"onBlur=\"javascript:checkCedula(this)\"")%>
						<%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,viewMode,3,2,null,null,"onBlur=\"javascript:checkCedula(this)\"")%>
						<%=fb.intBox("tomo",cdo.getColValue("tomo"),false,false,viewMode,5,4,null,null,"onBlur=\"javascript:checkCedula(this)\"")%>
						<%=fb.intBox("asiento",cdo.getColValue("asiento"),false,false,viewMode,6,6,null,null,"onBlur=\"javascript:checkCedula(this)\"")%>
						<%=fb.button("btnPaciente","...",true,(!mode.equalsIgnoreCase("add")),null,null,"onClick=\"javascript:showPacienteList()\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="19">Pasaporte</cellbytelabel></td>
					<td><%=fb.textBox("pasaporte",cdo.getColValue("pasaporte"),false,false,viewMode,20,20,null,null,"onBlur=\"javascript:checkPasaporte(this)\"")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="20">C&oacute;digo</cellbytelabel></td>
					<td><%=fb.intBox("codigo",cdo.getColValue("codigo"),false,false,true,5)%>&nbsp;&nbsp;Cod. Referencia:<%=fb.textBox("apartado_postal",cdo.getColValue("apartado_postal"),false,false,viewMode,20,20)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="21">Estado Civil</cellbytelabel></td>
					<td><%=fb.select("estadoCivil","ST=Soltero,CS=Casado,DV=Divorciado,UN=Unido,SP=Separado,VD=Viudo",cdo.getColValue("estadoCivil"),false,viewMode,0,null,null,null)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="22">Sexo</cellbytelabel></td>
					<td><%=fb.select("sexo","M=Masculino,F=Femenino",cdo.getColValue("sexo"),false,viewMode,0,null,null,null)%></td>
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
					<%=fb.select(ConMgr.getConnection(),"SELECT tipo_sangre as code, tipo_sangre FROM tbl_bds_tipo_sangre where rh='P' order by tipo_sangre","tipoSangre",cdo.getColValue("tipoSangre"),false,viewMode,0,null,null,"onChange=\"javascript:loadXML('../xml/rh_x_tiposangre.xml','rh','','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"",null,"S")%>
						<%=fb.select("rh","",cdo.getColValue("rh"),false,viewMode,0,null,null,null,null,"S")%>
						<script language="javascript">
						loadXML('../xml/rh_x_tiposangre.xml','rh','<%=cdo.getColValue("rh")%>','VALUE_COL','LABEL_COL',document.form0.tipoSangre.value,'KEY_COL','S');
						</script>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="25">Programa Fidelizaci&oacute;n</cellbytelabel></td>
					<td>
						<%=fb.select("vip","N=Normal,S=VIP,D=Distinguido,M=Médico Staff,J=J.Directiva",cdo.getColValue("vip"),false,viewMode,0,"text10","","onChange=\"javascript:setImagen(this.value)\"")%>
						<img id="imagen_vip" src="../images/blank.gif" with="30" height="30">
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


				<!--
				<tr class="TextRow01">
					<td><cellbytelabel id="29">Lenguaje Preferido</cellbytelabel></td>
					<%System.out.print("printing##############################################"+cdo.getColValue("lenguajeId"));
					%>
						<td><%//=fb.select(ConMgr.getConnection(),"SELECT lenguaje_id, descripcion FROM tbl_adm_lenguaje order by lenguaje_id asc","lenguajeId",cdo.getColValue("lenguajeId"),false,viewMode,0,null,null,null)%></td>
			</tr>-->
				<tr class="TextRow01">
					<td><cellbytelabel id="30">Fecha de Fallecido</cellbytelabel></td>
					<td>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fechaFallece" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaFallece")%>" />
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
					<td width="15%"><cellbytelabel id="">Casa No./Edificio</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("residencia_no",cdo.getColValue("residencia_no"),true,false,viewMode,20,20)%></td>
					<td width="15%">&nbsp;</td>
					<td width="35%">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="36">Tel&eacute;fono</cellbytelabel></td>
					<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,viewMode,13,13)%>
					<td><cellbytelabel id="">Celular</cellbytelabel></td>
					<td><%=fb.textBox("telefono_movil",cdo.getColValue("telefono_movil"),false,false,viewMode,13,20)%>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="37">Ubicaci&oacute;n Geogr&aacute;fica</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="38">Pa&iacute;s</cellbytelabel></td>
					<td>
						<%=fb.intBox("paisCode",cdo.getColValue("paisCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.textBox("pais",cdo.getColValue("pais"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
					</td>
					<td><cellbytelabel id="39">Provincia</cellbytelabel></td>
					<td>
						<%=fb.intBox("provCode",cdo.getColValue("provCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.textBox("prov",cdo.getColValue("prov"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="40">Distrito</cellbytelabel></td>
					<td>
						<%=fb.intBox("distritoCode",cdo.getColValue("distritoCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.textBox("distrito",cdo.getColValue("distrito"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
					</td>
					<td><cellbytelabel id="41">Corregimiento</cellbytelabel></td>
					<td>
						<%=fb.intBox("corregiCode",cdo.getColValue("corregiCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.textBox("corregi",cdo.getColValue("corregi"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbtelabel id="42">Comunidad</cellbtelabel></td>
					<td colspan="3">
						<%=fb.intBox("comunidadCode",cdo.getColValue("comunidadCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.textBox("comunidad",cdo.getColValue("comunidad"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','paisCode,pais,provCode,prov,distritoCode,distrito,corregiCode,corregi,comunidadCode,comunidad')\"")%>
						<%=fb.button("btnpais","...",true,viewMode,null,null,"onClick=\"javascript:addUbica()\"")%>
					</td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="42">Otras Direcciones</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="43">Zona Postal</cellbytelabel></td>
					<td><%=fb.textBox("zonaPostal",cdo.getColValue("zonaPostal"),false,false,viewMode,20,20)%></td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="45">N&uacute;mero Fax</cellbytelabel></td>
					<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,false,viewMode,13,13)%></td>
					<td><cellbytelabel id="44">Correo Electr&oacute;nico</cellbytelabel></td>
					<td><%=fb.emailBox("e_mail",cdo.getColValue("e_mail"),false,false,viewMode,40)%></td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="46">Informaci&oacute;n Laboral</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="47">Nombre Empresa</cellbytelabel></td>
					<td>
					<%=fb.hidden("id_empresa",cdo.getColValue("id_empresa"))%>
					<%=fb.textBox("lt_nombre",cdo.getColValue("lt_nombre"),false,false,viewMode,70,100)%>
					<%=fb.button("btnempresa","...",true,viewMode,null,null,"onClick=\"javascript:addEmpresa()\"")%>
					</td>
					<td><cellbytelabel id="">Puesto que Ocupa</cellbytelabel></td>
					<td><%=fb.textBox("puesto_que_ocupa",cdo.getColValue("puesto_que_ocupa"),false,false,viewMode,30,30)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="49">Direcci&oacute;n</cellbytelabel></td>
					<td><%=fb.textarea("lt_direccion", cdo.getColValue("lt_direccion"), false, false, false, 70, 3, 1000, "text12", "", "", "", false, "", "")%></td>
					<td><cellbytelabel id="48">Tel&eacute;fono</cellbytelabel></td>
					<td><%=fb.textBox("lt_telefono",cdo.getColValue("lt_telefono"),false,false,viewMode,30,30)%></td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="50">Cuestionario de Salud</cellbytelabel></td>
				</tr>
				<tr>
					<td colspan="4">
						<table width="99%" border="0" align="center" class="TableLeftBorder TableBottomBorder TableRightBorder TableTopBorder">
							<tr class="TextHeader">
								<td width="80%">Pregunta</td>
								<td width="20%" align="center">Opci&oacute;n</td>
							</tr>
								<%
								for (int i=0; i<al.size(); i++){
									CommonDataObject cd = (CommonDataObject) al.get(i);
								%>
								<%=fb.hidden("id"+i, cd.getColValue("id"))%>
								<%=fb.hidden("id_pregunta"+i, cd.getColValue("id_pregunta"))%>
								<tr>
									<td><%=(i+1)%>. <%=cd.getColValue("pregunta")%></td>
									<td align="center">
									<%if(cd.getColValue("tipo_pregunta").equals("1")){%>
									<%=fb.select("respuesta"+i,"N=No,S=Si",cd.getColValue("respuesta"),false,false,0,null,null,null)%>
									<%}%>
									</td>
								</tr>
								<%if(cd.getColValue("tipo_pregunta").equals("1")){%>
								<tr>
									<td colspan="2">Indique Cu&aacute;l:<%=fb.textarea("detalle"+i, cd.getColValue("detalle"), false, false, false, 100, 2, 1000, "text12", "", "", "", false, "", "")%></td>
								</tr>
								<%}%>
								<%}%>
								<%=fb.hidden("respSize", ""+al.size())%>
							</table>
					</td>
				</tr>
				</table>
			</td>
		</tr>
		<%System.out.println("_______________________________fp="+fp+", fg="+fg);%>
		<tr class="TextRow02">
			<td colspan="2" align="right">
				<cellbytelabel id="46">Opciones de Guardar</cellbytelabel>:
				<%if(fp!=null && (fp.equals("plan_medico") || fp.equals("adenda")) && fg!=null && (fg.equals("responsable") || fg.equals("beneficiario"))){%><%} else {%>
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="68">Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="69">Mantener Abierto</cellbytelabel>
				<%}%>
				<%=fb.radio("saveOption","C",(fp!=null && (fp.equals("plan_medico") || fp.equals("adenda")) && fg!=null && (fg.equals("responsable") || fg.equals("beneficiario"))?true:false),viewMode,false)%><cellbytelabel id="70">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".save.value=='Guardar'&&!isValidId()){error++;}");%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".save.value=='Guardar'&&!validateDCedula()){error++;}");%>

<%=fb.formEnd(true)%>
		</table>
</div>
				<!-- TAB2 DIV START HERE [SEGUIMIENTO]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","1")%>
				<%=fb.hidden("id_trx","")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("client_id",clientId)%>
				<%//=fb.hidden("change",change)%>
				<%=fb.hidden("baction","")%>
				<%//=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
					<tr class="TextRow02">
						<td colspan="4">&nbsp;</td>
					</tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameSeg" id="iFrameSeg" frameborder="0" align="center" width="100%" height="220" scrolling="yes" src="../planmedico/reg_seguimiento.jsp?tipo=CLIENTE&id_trx=<%=clientId%>&mode=<%=mode%>&tab=1"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				<!-- TAB2 DIV END HERE [SEGUIMIENTO]-->
				</div>
				<!-- TAB3 DIV START HERE [NOTAS]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","2")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("client_id",clientId)%>
				<%//=fb.hidden("change",change)%>
				<%=fb.hidden("baction","")%>
				<%//=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
					<tr class="TextRow02">
						<td colspan="4">&nbsp;</td>
					</tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameNota" id="iFrameNota" frameborder="0" align="center" width="100%" height="220" scrolling="yes" src="../planmedico/reg_notas.jsp?tipo=CLIENTE&id_trx=<%=clientId%>&mode=<%=mode%>&tab=2"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
				<!-- TAB3 DIV END HERE [NOTAS]-->

				<% if (showFac) {%>

				<!-- TAB4 DIV START HERE [FACTURAS]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","3")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("client_id",clientId)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("fp",fp)%>
					<tr class="TextPanel">
						<td colspan="3">FACTURAS DETALADO</td>
						<td align="right">
						   <%=fb.button("ir","Imprimir",true,false,"","","onClick=\"javascript:_goAndPrint('F');\"")%>
						</td>
					</tr>
					 <tr class="TextPanel">
						<td colspan="4"><cellbytelabel>Fecha</cellbytelabel>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%="fechaIniF"%>" />
						<jsp:param name="valueOfTBox1" value="<%=fechaIni%>" />
						<jsp:param name="nameOfTBox2" value="<%="fechaFinF"%>" />
						<jsp:param name="valueOfTBox2" value="<%=fechaFin%>" />
						<jsp:param name="fieldClass" value="text10" />
						<jsp:param name="buttonClass" value="text10" />
						</jsp:include>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Estado Factura
						<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cja_tipo_transaccion order by codigo","estadofactF","",false,viewMode,0,null,null,null,null,"T")%>
							<%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:_goAndFilter('F');\"")%>
						</td>
                    </tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameFacturas" id="iFrameFacturas" frameborder="0" align="center" width="100%" height="200px" scrolling="yes" src="../planmedico/pm_facturas_list.jsp?clientId=<%=clientId%>&mode=<%=mode%>&tab=3"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
				<!-- TAB4 DIV END HERE [FACTURAS]-->
				<% } %>

				<!-- TAB5 DIV START HERE [ESTADO DE CUENTA]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","4")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("client_id",clientId)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("fp",fp)%>
					<tr class="TextFilter">
						<td colspan="3">ESTADO DE CUENTA</td>
						<td align="right">
						   <%=fb.button("ir","Imprimir",true,false,"","","onClick=\"javascript:_goAndPrint('P');\"")%>
						</td>
					</tr>
					<tr class="TextFilter">
						<td colspan="4"><cellbytelabel>Fecha</cellbytelabel>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%="fechaIniP"%>" />
						<jsp:param name="valueOfTBox1" value="" />
						<jsp:param name="nameOfTBox2" value="<%="fechaFinP"%>" />
						<jsp:param name="valueOfTBox2" value="" />
						<jsp:param name="fieldClass" value="text10" />
						<jsp:param name="buttonClass" value="text10" />
						</jsp:include>
							<%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:_goAndFilter('P');\"")%>
						</td>
                    </tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFramePagos" id="iFramePagos" frameborder="0" align="center" width="100%" height="200px" scrolling="yes" src="../planmedico/pm_estado_cuenta_list.jsp?clientId=<%=clientId%>&mode=<%=mode%>&clientName=<%=clientName%>&tab=4"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
				<!-- TAB5 DIV END HERE [PAGOS]-->
				<% if (showFac) {%>

				<!-- TAB4 DIV START HERE [FACTURAS]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","5")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("client_id",clientId)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("fp",fp)%>
					<tr class="TextPanel">
						<td colspan="3">FACTURAS</td>
						<td align="right">
						   <%//=fb.button("ir","Imprimir",true,false,"","","onClick=\"javascript:_goAndPrint('F');\"")%>
						</td>
					</tr>
					 <tr class="TextPanel">
						<td colspan="4"><cellbytelabel>Fecha</cellbytelabel>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="<%="fechaIniFR"%>" />
						<jsp:param name="valueOfTBox1" value="<%=fechaIni%>" />
						<jsp:param name="nameOfTBox2" value="<%="fechaFinFR"%>" />
						<jsp:param name="valueOfTBox2" value="<%=fechaFin%>" />
						<jsp:param name="fieldClass" value="text10" />
						<jsp:param name="buttonClass" value="text10" />
						</jsp:include>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Estado Factura
						<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cja_tipo_transaccion order by codigo","estadofactFR","",false,viewMode,0,null,null,null,null,"T")%>
							<%=fb.button("ir","Ir",true,false,"","","onClick=\"javascript:_goAndFilter('FR');\"")%>
						</td>
                    </tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameFacturasRes" id="iFrameFacturasRes" frameborder="0" align="center" width="100%" height="200px" scrolling="yes" src="../planmedico/pm_facturas_list_res.jsp?clientId=<%=clientId%>&mode=<%=mode%>&tab=3"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
				<!-- TAB5 DIV END HERE [FACTURAS]-->
				<% } %>
			</div>
<script type="text/javascript">
<%
String tabInactivo="";
String tabLabel = "'Generales'";
if (!mode.equalsIgnoreCase("add")) {
	tabLabel += ",'Seguimiento', 'Notas'";
	if(fp.equals("cxc")){
		if (showFac) tabLabel += ", 'Facturas Detallado','Estado de Cuenta','Facturas'";
		else tabLabel += ",'Estado de Cuenta'";
	}
}
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,Array(<%=tabFunctions%>),[]);
</script>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	fp = request.getParameter("fp");
	cdo = new CommonDataObject();

	if (tab.equals("0"))
	{
		cdo.addColValue("tipo_id_paciente",request.getParameter("tipoId"));
		if (request.getParameter("provincia") != null) cdo.addColValue("provincia",request.getParameter("provincia"));
		if (request.getParameter("sigla") != null) cdo.addColValue("sigla",request.getParameter("sigla"));
		if (request.getParameter("tomo") != null) cdo.addColValue("tomo",request.getParameter("tomo"));
		if (request.getParameter("asiento") != null) cdo.addColValue("asiento",request.getParameter("asiento"));
		cdo.addColValue("d_cedula",request.getParameter("d_cedula"));
		if (request.getParameter("pasaporte") != null) cdo.addColValue("pasaporte",request.getParameter("pasaporte"));
		cdo.addColValue("primer_nombre",request.getParameter("primerNom"));
		cdo.addColValue("estado_civil",request.getParameter("estadoCivil"));
		if (request.getParameter("segundoNom") != null) cdo.addColValue("segundo_nombre",request.getParameter("segundoNom"));
		cdo.addColValue("sexo",request.getParameter("sexo"));
		if (request.getParameter("primerApell") != null) cdo.addColValue("primer_apellido",request.getParameter("primerApell"));
		if (request.getParameter("segundoApell") != null) cdo.addColValue("segundo_apellido",request.getParameter("segundoApell"));
		if (request.getParameter("casadaApell") != null) cdo.addColValue("apellido_de_casada",request.getParameter("casadaApell"));
		if (request.getParameter("seguro") != null) cdo.addColValue("seguro_social",request.getParameter("seguro"));
		cdo.addColValue("tipo_sangre",request.getParameter("tipoSangre"));
		if (request.getParameter("rh") != null) cdo.addColValue("rh",request.getParameter("rh"));
		if (request.getParameter("hijo") != null) cdo.addColValue("numero_de_hijos",request.getParameter("hijo"));
		cdo.addColValue("vip",request.getParameter("vip"));
		if (request.getParameter("lugarNaci") != null) cdo.addColValue("lugar_nacimiento",request.getParameter("lugarNaci"));
		if (request.getParameter("nacionalCode") != null) cdo.addColValue("nacionalidad",request.getParameter("nacionalCode"));
		if (request.getParameter("religionCode") != null) cdo.addColValue("religion",request.getParameter("religionCode"));
		if (request.getParameter("fallecido") == null) cdo.addColValue("fallecido","N");
		else cdo.addColValue("fallecido",request.getParameter("fallecido"));
		cdo.addColValue("estatus",request.getParameter("estatus"));
		if (request.getParameter("nomPadre") != null) cdo.addColValue("nombre_padre",request.getParameter("nomPadre"));
		if (request.getParameter("nomMadre") != null) cdo.addColValue("nombre_madre",request.getParameter("nomMadre"));
		cdo.addColValue("datos_correctos",request.getParameter("datosCorrec"));
		if (request.getParameter("fechaFallece") != null) cdo.addColValue("fecha_fallecido",request.getParameter("fechaFallece"));
		if (request.getParameter("fechaCorrec") != null) cdo.addColValue("f_nac",request.getParameter("fechaCorrec"));
		if (request.getParameter("jubilado") == null) cdo.addColValue("jubilado","N");
		else cdo.addColValue("jubilado",request.getParameter("jubilado"));
		cdo.addColValue("residencia_direccion",request.getParameter("direccion"));
		cdo.addColValue("tipo_residencia",request.getParameter("tipoResi"));
		if (request.getParameter("telefono") != null) cdo.addColValue("telefono",request.getParameter("telefono"));
		if (request.getParameter("paisCode") != null) cdo.addColValue("residencia_pais",request.getParameter("paisCode"));
		if (request.getParameter("provCode") != null) cdo.addColValue("residencia_provincia",request.getParameter("provCode"));
		if (request.getParameter("distritoCode") != null) cdo.addColValue("residencia_distrito",request.getParameter("distritoCode"));
		if (request.getParameter("corregiCode") != null) cdo.addColValue("residencia_corregimiento",request.getParameter("corregiCode"));
		if (request.getParameter("comunidadCode") != null) cdo.addColValue("residencia_comunidad",request.getParameter("comunidadCode"));
		if (request.getParameter("zonaPostal") != null) cdo.addColValue("zona_postal",request.getParameter("zonaPostal"));
		if (request.getParameter("apartado_postal") != null) cdo.addColValue("apartado_postal",request.getParameter("apartado_postal"));
		if (request.getParameter("fax") != null) cdo.addColValue("fax",request.getParameter("fax"));
		if (request.getParameter("e_mail") != null) cdo.addColValue("e_mail",request.getParameter("e_mail"));

		if (request.getParameter("comidaId") != null) cdo.addColValue("comida_id",request.getParameter("comidaId"));

		if (request.getParameter("lenguajeId") != null) cdo.addColValue("lenguaje_id",request.getParameter("lenguajeId"));

		if (request.getParameter("deseo") != null) cdo.addColValue("deseo",request.getParameter("deseo"));

		if (request.getParameter("preferencia") != null) cdo.addColValue("preferencia",request.getParameter("preferencia"));

		if (request.getParameter("id_empresa") != null) cdo.addColValue("id_empresa",request.getParameter("id_empresa"));
		if (request.getParameter("residencia_no") != null) cdo.addColValue("residencia_no",request.getParameter("residencia_no"));
		if (request.getParameter("puesto_que_ocupa") != null) cdo.addColValue("puesto_que_ocupa",request.getParameter("puesto_que_ocupa"));
		if (request.getParameter("telefono_movil") != null) cdo.addColValue("telefono_movil",request.getParameter("telefono_movil"));
		if (request.getParameter("pac_id") != null) cdo.addColValue("pac_id",request.getParameter("pac_id"));
		System.out.println("pac_id="+cdo.getColValue("pac_id"));
	}
	Cliente _cdo = new Cliente();
	if (tab.equals("0"))
	{
		int respSize = Integer.parseInt(request.getParameter("respSize"));
		al = new ArrayList();
		for(int i = 0; i< respSize; i++){
			CommonDataObject cd = new CommonDataObject();
			if(request.getParameter("id"+i)!=null) cd.addColValue("id", request.getParameter("id"+i));
			if(request.getParameter("id_pregunta"+i)!=null) cd.addColValue("id_pregunta", request.getParameter("id_pregunta"+i));
			if(request.getParameter("detalle"+i)!=null) cd.addColValue("detalle", request.getParameter("detalle"+i));
			if(request.getParameter("respuesta"+i)!=null) cd.addColValue("respuesta", request.getParameter("respuesta"+i));
			al.add(cd);
		}
		_cdo.setAl(al);
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add")){
			cdo.addColValue("fecha_nacimiento",request.getParameter("fechaNaci"));
			cdo.addColValue("usuario_adiciona",(String) session.getAttribute("_userName")/*UserDet.getUserEmpId()*/);
			cdo.addColValue("usuario_modifica",(String) session.getAttribute("_userName")/*UserDet.getUserEmpId()*/);
			cdo.addColValue("fecha_adiciona",cDate);
			cdo.addColValue("fecha_modifica",cDate);
			_cdo.setCdo(cdo);
			CltMgr.add(_cdo);
			clientId = CltMgr.getPkColValue("codigo");
		}
		else
		{
			cdo.addColValue("usuario_modifica",(String) session.getAttribute("_userName")/*UserDet.getUserEmpId()*/);
			cdo.addColValue("fecha_modifica",cDate);
			cdo.addColValue("codigo", clientId);
			_cdo.setCdo(cdo);
			CltMgr.update(_cdo);
		}
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (CltMgr.getErrCode().equals("1"))
{
%>
	alert('<%=CltMgr.getErrMsg()%>');
<% if (tab.equals("0")) {
		if(fp!=null && (fp.equals("plan_medico") || fp.equals("adenda")) && fg!=null && (fg.equals("responsable") || fg.equals("beneficiario"))){
			%>
			window.opener.cargarPagina(<%=clientId%>);
		<%
		} else {
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/planmedico/pm_clientes_list.jsp")) { %>
		window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/planmedico/pm_clientes_list.jsp")%>';
		<% } else { %>
			window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_clientes_list.jsp';
		<% } %>

	<% } if (saveOption.equalsIgnoreCase("N")){%>
		setTimeout('addMode()',500);
    <%}else if (saveOption.equalsIgnoreCase("O")){%>
		setTimeout('editMode()',500);
    <%}else if (saveOption.equalsIgnoreCase("C")){%>
		window.close();
    <%}
		}
} else throw new Exception(CltMgr.getErrMsg());
%>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&fg=<%=fg%>';
}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&fg=<%=fg%>&mode=edit&tab=<%=tab%>&clientId=<%=clientId%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%} //POST%>