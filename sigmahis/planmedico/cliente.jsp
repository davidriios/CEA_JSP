<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.File"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.planmedico.Solicitud"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="SOL" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==========================================================================================
FORMA SOL_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
XMLCreator xml = new XMLCreator(ConMgr);
xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"rh_x_tiposangre.xml","select rh as value_col, rh as label_col, tipo_sangre as key_col from tbl_bds_tipo_sangre order by 3,2");

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String id_cliente = request.getParameter("id_cliente");
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
SOL = new CommonDataObject();
if (id_cliente == null) throw new Exception("Id Cliente no es válido. Por favor intente nuevamente!");
sbSql.append("select a.deseo, a.preferencia ,a.tipo_id_paciente, nvl(a.provincia,'') provincia, nvl(a.sigla,'') sigla, nvl(a.tomo,'') tomo, nvl(a.asiento,'') asiento, nvl(a.d_cedula,'') d_cedula, nvl(a.pasaporte,'') pasaporte, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.codigo, a.primer_nombre, a.estado_civil, a.segundo_nombre, a.sexo, a.primer_apellido, a.segundo_apellido, a.apellido_de_casada, a.seguro_social, a.rh, a.tipo_sangre, decode(a.nh,'S','Nació en el hospital',null,' ') nh, a.numero_de_hijos, a.vip, a.lugar_nacimiento, a.nacionalidad, b.nacionalidad as nacionalidad_name, a.religion, c.descripcion as religion, a.estatus, a.fallecido, a.nombre_padre, a.nombre_madre, a.datos_correctos, to_char(a.fecha_fallecido,'dd/mm/yyyy') as fecha_fallecido, to_char(a.f_nac,'dd/mm/yyyy') as f_nac, a.jubilado, a.residencia_direccion, a.tipo_residencia, a.telefono, a.residencia_pais, decode(a.residencia_pais,null,null,d.nombre_pais) as pais_name, a.residencia_provincia, decode(a.residencia_provincia,null,null,d.nombre_provincia) as residencia_provincia_name, a.residencia_distrito, decode(a.residencia_distrito,null,null,d.nombre_distrito) as residencia_distrito_name, a.residencia_corregimiento, decode(a.residencia_corregimiento,null,null,d.nombre_corregimiento) as residencia_corregimiento_name, a.residencia_comunidad, decode(a.residencia_comunidad,null,null,d.nombre_comunidad) as residencia_comunidad_name, a.zona_postal, a.apartado_postal, a.fax, nvl(a.e_mail,'sincorreo@dominio.com') e_mail, a.persona_de_urgencia, a.direccion_de_urgencia, a.telefono_urgencia, a.telefono_trabajo_urgencia, a.id_empresa, nvl(e.nombre, ' ') lt_nombre, nvl(e.direccion, ' ') lt_direccion, nvl(e.telefono, ' ') lt_telefono, a.puesto_que_ocupa, a.residencia_no, a.telefono_movil, nvl (trunc (months_between (sysdate,coalesce (f_nac, fecha_nacimiento)-nvl((select to_number(get_sec_comp_param(-1, 'PARAM_DIAS_EDAD')) from dual), 0))/ 12),0) as edad, primer_nombre || decode (segundo_nombre, null, '', ' ' || segundo_nombre) || decode (primer_apellido, null, '', ' ' || primer_apellido) || decode (segundo_apellido, null, '', ' ' || segundo_apellido) || decode (sexo, 'F', decode (apellido_de_casada, null, '', ' DE ' || apellido_de_casada)) as nombre_cliente, decode(tipo_id_paciente, 'P', pasaporte, provincia || '-' || sigla || '-' || tomo || '-' || asiento) || '-' || d_cedula identificacion FROM tbl_pm_cliente a, tbl_sec_pais b, tbl_adm_religion c, vw_sec_regional_location d, tbl_pm_empresa e WHERE a.nacionalidad = b.codigo(+) and a.religion = c.codigo(+) and nvl(a.residencia_pais,0) = d.codigo_pais(+) and nvl(a.residencia_provincia,0)=d.codigo_provincia(+) and nvl(a.residencia_distrito,0)=d.codigo_distrito(+) and nvl(a.residencia_corregimiento,0)=d.codigo_corregimiento(+) and nvl(a.residencia_comunidad,0)=d.codigo_comunidad(+) and a.id_empresa = e.id_empresa(+) and a.codigo = ");
sbSql.append(id_cliente);
SOL = SQLMgr.getData(sbSql.toString());
if(SOL==null) SOL = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Plan Médico - Solicitud'+document.title;

function doAction(){
newHeight();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%
fb = new FormBean("cliente","","post");
%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("id_cliente",id_cliente)%>
	<%=fb.hidden("nombre_cliente",SOL.getColValue("nombre_cliente"))%>
	<%=fb.hidden("identificacion",SOL.getColValue("identificacion"))%>
	<tr class="TextRow01">
		<td align="right" width="12%"><cellbytelabel>Primer Nombre</cellbytelabel></td>
		<td width="21%">
		<%=fb.textBox("primer_nombre",SOL.getColValue("primer_nombre"),false,false,true,30,30,"Text10",null,"")%>
		</td>
		<td align="right" width="12%"><cellbytelabel>Primer Apellido</cellbytelabel></td>
		<td width="21%"><%=fb.textBox("primer_apellido",SOL.getColValue("primer_apellido"),false,false,true,30,30,"Text10",null,"")%></td>
		<td align="right" width="12%"><cellbytelabel>Apellido de Casada</cellbytelabel></td>
		<td width="21%"><%=fb.textBox("apellido_de_casada",SOL.getColValue("apellido_de_casada"),false,false,true,30,30,"Text10",null,"")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right" width="12%"><cellbytelabel>Segundo Nombre</cellbytelabel></td>
		<td width="21%">
		<%=fb.textBox("segundo_nombre",SOL.getColValue("segundo_nombre"),false,false,true,30,30,"Text10",null,"")%>
		</td>
		<td align="right" width="12%"><cellbytelabel>Segundo Apellido</cellbytelabel></td>
		<td width="21%"><%=fb.textBox("segundo_apellido",SOL.getColValue("segundo_apellido"),false,false,true,30,30,"Text10",null,"")%></td>
		<td align="right" width="12%"><cellbytelabel>Fecha Nacimiento</cellbytelabel></td>
		<td width="21%"><%=fb.textBox("fecha_nacimiento",SOL.getColValue("fecha_nacimiento"),false,false,true,12,12,"Text10",null,"")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel>Estado Civil</cellbytelabel></td>
		<td>
		<%=fb.select("estado_civil","ST=Soltero,CS=Casado,DV=Divorciado,UN=Unido,SP=Separado,VD=Viudo",SOL.getColValue("estado_civil"),false,false,0,null,null,null)%>
		</td>
		<td align="right"><cellbytelabel>Ocupaci&oacute;n</cellbytelabel></td>
		<td><%=fb.textBox("puesto_que_ocupa",SOL.getColValue("puesto_que_ocupa"),false,false,true,40,100,"Text10",null,"")%></td>
		<td align="right">Nacionalidad:</td>
		<td><%=fb.textBox("pais_name",SOL.getColValue("nacionalidad_name"),false,false,true,30,30,"Text10",null,"")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right"><cellbytelabel>Lugar de Trabajo</cellbytelabel></td>
		<td colspan="2"><%=fb.textBox("lt_nombre",SOL.getColValue("lt_nombre"),false,false,true,40,100,"Text10",null,"")%></td>
		<td align="right"><cellbytelabel>Direcci&oacute;n de Trabajo</cellbytelabel></td>
		<td colspan="2"><%=fb.textarea("lt_direccion", SOL.getColValue("lt_direccion"), false, false, true, 50, 3, 1000, "text10", "", "", "", false, "", "")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right">Tel. Residencia:</td>
		<td><%=fb.textBox("telefono",SOL.getColValue("telefono"),false,false,true,13,13,"Text10",null,"")%></td>
		<td align="right">Tel. Trabajo</td>
		<td><%=fb.textBox("lt_telefono",SOL.getColValue("lt_telefono"),false,false,true,20,20,"Text10",null,"")%></td>
		<td align="right">Celular</td>
		<td><%=fb.textBox("telefono_movil",SOL.getColValue("telefono_movil"),false,false,true,20,20,"Text10",null,"")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right">Edad:</td>
		<td><%=fb.textBox("edad",SOL.getColValue("edad"),false,false,true,3,3,"Text10",null,"")%></td>
		<td align="right">Sexo</td>
		<td><%=fb.select("sexo","M=Masculino,F=Femenino", SOL.getColValue("sexo"), false, false,0,"text10","Text10","")%></td>
		<td align="right">Tipo Sangre</td>
		<td>
		<%=fb.select(ConMgr.getConnection(),"SELECT tipo_sangre as code, tipo_sangre FROM tbl_bds_tipo_sangre where rh='P' order by tipo_sangre","tipoSangre",SOL.getColValue("tipo_sangre"),false,viewMode,0,null,null,"onChange=\"javascript:loadXML('../xml/rh_x_tiposangre.xml','rh','','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"",null,"S")%>
		<%=fb.select("rh","",SOL.getColValue("rh"),false,viewMode,0,null,null,null,null,"S")%>
		<script language="javascript">
		loadXML('../xml/rh_x_tiposangre.xml','rh','<%=SOL.getColValue("rh")%>','VALUE_COL','LABEL_COL',document.cliente.tipoSangre.value,'KEY_COL','S');
		</script>

		<%//=fb.select(ConMgr.getConnection(),"SELECT sangre_id as code, tipo_sangre FROM tbl_bds_tipo_sangre order by tipo_sangre","tipo_sangre",SOL.getColValue("tipo_sangre"),false,viewMode,0,"S")%>
		</td>
	</tr>
	<tr class="TextRow01">
		<td colspan="6">Direcci&oacute;n</td>
	</tr>
	<tr class="TextRow01">
		<td align="right">Provincia:</td>
		<td><%=fb.textBox("residencia_provincia",SOL.getColValue("residencia_provincia_name"),false,false,true,30,30,"Text10",null,"")%></td>
		<td align="right">Corregimiento</td>
		<td><%=fb.textBox("residencia_corregimiento",SOL.getColValue("residencia_corregimiento_name"),false,false,true,30,30,"Text10",null,"")%></td>
		<td align="right">Barrio o Sector</td>
		<td><%=fb.textBox("residencia_comunidad",SOL.getColValue("residencia_comunidad_name"),false,false,true,30,30,"Text10",null,"")%></td>
	</tr>
	<tr class="TextRow01">
		<td align="right">Calle:</td>
		<td><%=fb.textBox("residencia_direccion",SOL.getColValue("residencia_direccion"),false,false,true,30,30,"Text10",null,"")%></td>
		<td align="right">No. Casa/Edificio</td>
		<td><%=fb.textBox("residencia_no",SOL.getColValue("residencia_no"),false,false,true,30,30,"Text10",null,"")%></td>
		<td align="right">&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<%=fb.formEnd(true)%>
</table>
</body>
</html>