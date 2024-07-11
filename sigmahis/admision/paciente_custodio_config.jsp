<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String tab = request.getParameter("tab");
String code = request.getParameter("code");
String dob = request.getParameter("dob");
String pacId = request.getParameter("pacId");
String fp = request.getParameter("fp");
String popWinFunction = "abrir_ventana2";
String tipo = request.getParameter("tipo");

if (mode == null) mode = "add";
if (fp == null) fp = "";
if (fp.equalsIgnoreCase("admision")) popWinFunction = "abrir_ventana4";
if (tipo == null) tipo = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Custodio del Paciente no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.nombre, a.sexo, a.tipo_identificacion as tipoId, a.identificacion, a.principal, a.nacionalidad as nacionalCode, b.nacionalidad as nacional, a.parentesco, a.direccion_residencia as direccion, a.telefono_residencia as telefono, a.cod_empresa as empresaCode, c.nombre as empresa, a.num_empleado as noEmpleado, a.apartado_postal as aptdo, a.zona_postal as zona, a.lugar_de_trabajo as lugarTrab, a.direccion_trabajo as direcTrab, a.ocupacion as ocupacion, a.telefono_trabajo as telTrabajo, a.fax, a.e_mail, a.observacion as observ FROM tbl_adm_custodio a, tbl_sec_pais b, tbl_adm_empresa c WHERE a.nacionalidad=b.codigo(+) and a.cod_empresa=c.codigo(+) and a.pac_id="+pacId+" and a.secuencia="+id;
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Mantenimiento de Custodio - "+document.title;
function addNacional(){<%=popWinFunction%>('../common/search_pais.jsp?fp=paciente_custodio');}
function addEmpr(){<%=popWinFunction%>('../common/search_empresa.jsp?fp=paciente_custodio');}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MANTENIMIENTO DE CUSTODIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("fp",fp)%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="15%">Nombre</td>
			<td width="35%"><%=fb.textBox("nombre",cdo.getColValue("nombre"),false,false,false,40,100)%></td>
			<td width="15%">Sexo</td>
			<td width="35%"><%=fb.select("sexo","F=Femenino,M=Masculino",cdo.getColValue("sexo"))%></td>
		</tr>
		<tr class="TextRow01">
			<td>Identificaci&oacute;n</td>
			<td>
				<%=fb.select("tipoId","C=Cedula,P=Pasaporte,O=Otros",cdo.getColValue("tipoId"))%>
				<%=fb.textBox("identificacion",cdo.getColValue("identificacion"),true,false,false,30,30)%>
			</td>
			<td>Principal</td>
			<td><%=fb.select("principal","S=Si,N=No",cdo.getColValue("principal"))%></td>
		</tr>
		<tr class="TextRow01">
			<td>Nacionalidad</td>
			<td>
				<%=fb.intBox("nacionalCode",cdo.getColValue("nacionalCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','nacionalCode,nacional')\"")%>
				<%=fb.textBox("nacional",cdo.getColValue("nacional"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','nacionalCode,nacional')\"")%>
				<%=fb.button("btnnacional","...",false,false,null,null,"onClick=\"javascript:addNacional()\"")%>
			</td>
			<td>Parentesco</td>
			<td><%=fb.textBox("parentesco",cdo.getColValue("parentesco"),false,false,false,30,30)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Direcci&oacute;n</td>
			<td><%=fb.textBox("direccion",cdo.getColValue("direccion"),false,false,false,40,100)%></td>
			<td>Tel&eacute;fono</td>
			<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,false,13,13)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Empresa</td>
<td>
<%=fb.intBox("empresaCode",cdo.getColValue("empresaCode"),false,false,true,5,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','empresaCode,empresa')\"")%>
<%=fb.textBox("empresa",cdo.getColValue("empresa"),false,false,true,30,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','empresaCode,empresa')\"")%>
<%=fb.button("btnempr","...",false,false,null,null,"onClick=\"javascript:addEmpr()\"")%>
</td>
			<td>No. Empleado</td>
			<td><%=fb.textBox("noEmpleado",cdo.getColValue("noEmpleado"),false,false,false,15,15)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Apartado</td>
			<td><%=fb.textBox("aptdo",cdo.getColValue("aptdo"),false,false,false,20,20)%></td>
			<td>Zona Postal</td>
			<td><%=fb.textBox("zona",cdo.getColValue("zona"),false,false,false,20,20)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Lugar Trabajo</td>
			<td><%=fb.textBox("lugarTrab",cdo.getColValue("lugarTrab"),false,false,false,40,80)%></td>
			<td>Direc. Trabajo</td>
			<td><%=fb.textBox("direcTrab",cdo.getColValue("direcTrab"),false,false,false,40,100)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Ocupaci&oacute;n</td>
			<td><%=fb.textBox("ocupacion",cdo.getColValue("ocupacion"),false,false,false,40,100)%></td>
			<td>Tel&eacute;fono Trabajo</td>
			<td><%=fb.textBox("telTrabajo",cdo.getColValue("telTrabajo"),false,false,false,13,13)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Fax</td>
			<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,false,false,13,13)%></td>
			<td>Email</td>
			<td><%=fb.textBox("e_mail",cdo.getColValue("e_mail"),false,false,false,40,100)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Observaci&oacute;n</td>
			<td colspan="3"><%=fb.textarea("observ",cdo.getColValue("observ"),false,false,false,40,4)%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
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
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_adm_custodio");
	if (request.getParameter("nombre") != null)
	cdo.addColValue("nombre",request.getParameter("nombre"));
	cdo.addColValue("sexo",request.getParameter("sexo"));
	cdo.addColValue("tipo_identificacion",request.getParameter("tipoId"));
	cdo.addColValue("identificacion",request.getParameter("identificacion"));
	cdo.addColValue("principal",request.getParameter("principal"));
	if (request.getParameter("nacionalCode") != null)
	cdo.addColValue("nacionalidad",request.getParameter("nacionalCode"));
	if (request.getParameter("parentesco") != null)
	cdo.addColValue("parentesco",request.getParameter("parentesco"));
	if (request.getParameter("direccion") != null)
	cdo.addColValue("direccion_residencia",request.getParameter("direccion"));
	if (request.getParameter("telefono") != null)
	cdo.addColValue("telefono_residencia",request.getParameter("telefono"));
	if (request.getParameter("empresaCode") != null)
	cdo.addColValue("cod_empresa",request.getParameter("empresaCode"));
	if (request.getParameter("noEmpleado") != null)
	cdo.addColValue("num_empleado",request.getParameter("noEmpleado"));
	if (request.getParameter("aptdo") != null)
	cdo.addColValue("apartado_postal",request.getParameter("aptdo"));
	if (request.getParameter("zona") != null)
	cdo.addColValue("zona_postal",request.getParameter("zona"));
	if (request.getParameter("lugarTrab") != null)
	cdo.addColValue("lugar_de_trabajo",request.getParameter("lugarTrab"));
	if (request.getParameter("direcTrab") != null)
	cdo.addColValue("direccion_trabajo",request.getParameter("direcTrab"));
	if (request.getParameter("ocupacion") != null)
	cdo.addColValue("ocupacion",request.getParameter("ocupacion"));
	if (request.getParameter("telTrabajo") != null)
	cdo.addColValue("telefono_trabajo",request.getParameter("telTrabajo"));
	if (request.getParameter("fax") != null)
	cdo.addColValue("fax",request.getParameter("fax"));
	if (request.getParameter("e_mail") != null)
	cdo.addColValue("e_mail",request.getParameter("e_mail"));
	if (request.getParameter("observ") != null)
	cdo.addColValue("observacion",request.getParameter("observ"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("fecha_nacimiento",dob);
		cdo.addColValue("paciente",code);
		cdo.addColValue("pac_id",pacId);
		cdo.setWhereClause("pac_id="+pacId);
		cdo.setAutoIncCol("secuencia");
		SQLMgr.insert(cdo);
	}
	else
	{
		cdo.setWhereClause("pac_id="+pacId+" and secuencia="+id);
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
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
	window.opener.location = '<%=request.getContextPath()%>/admision/paciente_config.jsp?fp=<%=fp%>&mode=edit&pacId=<%=pacId%>&tab=<%=tab%>&tipo=<%=tipo%>';
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>