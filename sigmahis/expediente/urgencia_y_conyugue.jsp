<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.File"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.HL7"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
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

ArrayList al = new ArrayList();
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String fp = request.getParameter("fp");
String popWinFunction = "abrir_ventana1";

if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (!mode.equalsIgnoreCase("add") && !mode.equalsIgnoreCase("edit")) viewMode = true;
if (fp == null) fp = "";
if (fp.equalsIgnoreCase("admision")) popWinFunction = "abrir_ventana3";

if (request.getMethod().equalsIgnoreCase("GET"))
{

		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.tipo_id_paciente as tipoId, a.provincia, a.sigla, a.tomo, a.asiento, a.d_cedula, a.pasaporte, a.codigo, a.primer_nombre as primerNom, a.estado_civil as estadoCivil, a.segundo_nombre as segundoNom, a.sexo, a.primer_apellido as primerApell, a.ingreso_men, a.segundo_apellido as segundoApell, a.apellido_de_casada as casadaApell, a.seguro_social as seguro, a.tipo_sangre as tipoSangre, a.rh, a.numero_de_hijos as hijo, a.vip, a.lugar_nacimiento as lugarNaci, a.nacionalidad as nacionalCode, b.nacionalidad as nacional, a.religion as religionCode, c.descripcion as religion, a.estatus, a.fallecido, a.nombre_padre as nomPadre, a.nombre_madre as nomMadre, a.datos_correctos as datosCorrec, to_char(a.fecha_fallecido,'dd/mm/yyyy') as fechafallece, to_char(a.f_nac,'dd/mm/yyyy') as fechaCorrec, a.jubilado, a.residencia_direccion as direccion, a.tipo_residencia as tipoResi, a.telefono, a.telefono_movil, a.residencia_pais as paisCode, decode(a.residencia_pais,null,null,d.nombre_pais) as pais, a.residencia_provincia as provCode, decode(a.residencia_provincia,null,null,d.nombre_provincia) as prov, a.residencia_distrito as distritoCode, decode(a.residencia_distrito,null,null,d.nombre_distrito) as distrito, a.residencia_corregimiento as corregiCode, decode(a.residencia_corregimiento,null,null,d.nombre_corregimiento) as corregi, a.residencia_comunidad as comunidadCode, decode(a.residencia_comunidad,null,null,d.nombre_comunidad) as comunidad, a.zona_postal as zonaPostal, a.apartado_postal as aptdoPostal, a.fax, a.e_mail, a.persona_de_urgencia as persUrgencia, a.direccion_de_urgencia as dirUrgencia, a.telefono_urgencia as telUrgencia, a.telefono_trabajo_urgencia as telTrabajoUrge, a.nombre_conyugue as nomConyugue, a.lugar_trabajo_conyugue as lugarTrabConyugue, a.telefono_trabajo_conyugue as telTrabConyugue, a.tipo_identificacion_conyugue as tipoIdConyugue, a.identificacion_conyugue as idConyugue, a.conyugue_nacionalidad as conyuNacionalCode, e.nacionalidad as conyuNacional, a.lugar_trabajo as lugarTrab, a.puesto_que_ocupa as puestoOcu, a.trabajo_direccion as trabDireccion, a.departamento_donde_labora as deptdoLabora, a.nombre_jefe_inmediato as jefeInmediato, a.telefono_trabajo as telTrabajo, a.extension_oficina as extOficina, a.periodos_laborados as periodoLab, a.trabajo_pais as trabPaisCode, decode(a.trabajo_pais,null,null,f.nombre_pais) as trabPais, a.trabajo_provincia as trabProvCode, decode(a.trabajo_provincia,null,null,f.nombre_provincia) as trabProv, a.trabajo_distrito as trabDistritoCode, decode(a.trabajo_distrito,null,null,f.nombre_distrito) as trabDistrito, a.trabajo_corregimiento as trabCorregiCode, decode(a.trabajo_corregimiento,null,null,f.nombre_corregimiento) as trabCorregi FROM tbl_adm_paciente a, tbl_sec_pais b, tbl_adm_religion c, vw_sec_regional_location d, tbl_sec_pais e, vw_sec_regional_location f WHERE a.nacionalidad=b.codigo(+) and a.religion=c.codigo(+) and nvl(a.residencia_pais,0)=d.codigo_pais(+) and nvl(a.residencia_provincia,0)=d.codigo_provincia(+) and nvl(a.residencia_distrito,0)=d.codigo_distrito(+) and nvl(a.residencia_corregimiento,0)=d.codigo_corregimiento(+) and nvl(a.residencia_comunidad,0)=d.codigo_comunidad(+) and a.conyugue_nacionalidad=e.codigo(+) and nvl(a.trabajo_pais,0)=f.codigo_pais(+) and nvl(a.trabajo_provincia,0)=f.codigo_provincia(+) and nvl(a.trabajo_distrito,0)=f.codigo_distrito(+) and nvl(a.trabajo_corregimiento,0)=f.codigo_corregimiento(+) and nvl(a.residencia_comunidad,0)=f.codigo_comunidad(+) and a.pac_id="+pacId;
		cdo = SQLMgr.getData(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Mantenimiento de Paciente - '+document.title;
function doAction(){}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="">
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("pacId",pacId)%>
		<tr>
			<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel id="1">Urgencia y C&oacute;nyuge</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel10">
			<td>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextRow01">
					<td width="15%"><cellbytelabel id="2">Nombre</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("persUrgencia",cdo.getColValue("persUrgencia"),false,false,viewMode,40,100)%></td>
					<td width="15%"><cellbytelabel id="3">Direcci&oacute;n</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("dirUrgencia",cdo.getColValue("dirUrgencia"),false,false,viewMode,40,100)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="4">Tel. Residencia</cellbytelabel></td>
					<td><%=fb.textBox("telUrgencia",cdo.getColValue("telUrgencia"),false,false,viewMode,13,13)%></td>
					<td><cellbytelabel id="5">Tel. Trabajo</cellbytelabel></td>
					<td><%=fb.textBox("telTrabajoUrge",cdo.getColValue("telTrabajoUrge"),false,false,viewMode,13,13)%></td>
				</tr>
				<tr class="TextHeader">
					<td colspan="4">&nbsp;<cellbytelabel id="6">Datos del C&oacute;nyuge</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="2">Nombre</cellbytelabel></td>
					<td><%=fb.textBox("nomConyugue",cdo.getColValue("nomConyugue"),false,false,viewMode,40,100)%></td>
					<td><cellbytelabel id="7">Lugar de Trabajo</cellbytelabel></td>
					<td><%=fb.textBox("lugarTrabConyugue",cdo.getColValue("lugarTrabConyugue"),false,false,viewMode,40,100)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="4">Tel. Residencia</cellbytelabel></td>
					<td><%=fb.textBox("telTrabConyugue",cdo.getColValue("telTrabConyugue"),false,false,viewMode,13,13)%></td>
					<td><cellbytelabel id="8">Identificaci&oacute;n</cellbytelabel></td>
					<td>
						<%=fb.select("tipoIdConyugue","P=Pasaporte,C=Cédula",cdo.getColValue("tipoIdConyugue"),false,viewMode,0,null,null,null)%>
						<%=fb.textBox("idConyugue",cdo.getColValue("idConyugue"),false,false,viewMode,20,30)%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="9">Nacionalidad</cellbytelabel></td>
					<td colspan="3">
						<%=fb.intBox("conyuNacionalCode",cdo.getColValue("conyuNacionalCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','conyuNacionalCode,conyuNacional')\"")%>
						<%=fb.textBox("conyuNacional",cdo.getColValue("conyuNacional"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','conyuNacionalCode,conyuNacional')\"")%>
						<%=fb.button("btnnacional","...",false,viewMode,null,null,"onClick=\"javascript:addConyuNacional()\"")%>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="4">
<% if (fp.equalsIgnoreCase("admision")) { %>
						<%=fb.hidden("saveOption","O")%>
<% } else { %>
						<cellbytelabel id="9">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="10">Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
<% } %>
						<%=fb.submit("save","Guardar",true,viewMode)%>
						<%//=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				</table>
			</td>
		</tr>
<%=fb.formEnd(true)%>
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
