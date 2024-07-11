<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
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
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (desc == null) desc = "";

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	sql = "select nvl(x.residencia_direccion,' ') as residencia_direccion, nvl(x.telefono,' ') as telefono, nvl(x.telefono_trabajo,' ') as telefono_trabajo, nvl(x.lugar_trabajo,' ') as lugar_trabajo from (select nvl(a.residencia_direccion,' ') as residencia_direccion, nvl(a.telefono,' ') as telefono, nvl(a.telefono_trabajo,' ') as telefono_trabajo, nvl(a.lugar_trabajo,' ') as lugar_trabajo, a.pac_id from tbl_adm_paciente a where a.pac_id="+pacId+") x  ";

	cdo = SQLMgr.getData(sql);
	
	sql="select  d.nombre as nombre_empresa, b.empresa as empresa, b.poliza as poliza, nvl(b.certificado,' ') as certificado, b.pac_id, b.admision from tbl_adm_beneficios_x_admision b, tbl_adm_empresa d where b.pac_id="+pacId+" and b.admision="+noAdmision+"   and  b.empresa=d.codigo(+)";
	al = SQLMgr.getDataList(sql);

	sql="select nvl(c.nombre,' ') as nombre, nvl(c.ref_id,' ') as identificacion, (select descripcion from tbl_fac_tipo_cliente where codigo=c.ref_type and compania="+(String)session.getAttribute("_companyId")+" ) as tipo_identificacion, nvl(c.telefono_residencia,' ') as telefono_residencia, c.pac_id, c.admision from tbl_adm_responsable c where c.pac_id="+pacId+" and c.admision="+noAdmision+" and c.estado ='A'";
	al2 = SQLMgr.getDataList(sql);

	sql = "select a.diagnostico, decode(b.observacion,null,b.nombre,b.observacion) nombre, a.orden_diag from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.pac_id="+pacId+" and a.admision="+noAdmision+" and a.tipo='I' and a.diagnostico=b.codigo order by a.orden_diag";
	al3 = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - Datos de Admisión - '+document.title;
function doAction(){}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_21.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>");}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true" >
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
		<tr class="TextRow02" >
			<td colspan="4" align="right">&nbsp;<a href="javascript:printExp();" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel id="2">Datos Generales del paciente</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td width="15%"><cellbytelabel id="3">Tel&eacute;fono de Residencia</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,true,15,13)%></td>
			<td width="15%"><cellbytelabel id="4">Tel&eacute;fono de Oficina</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("telefono_oficina",cdo.getColValue("telefono_trabajo"),false,false,true,15,13)%></td>
		</tr>
		<tr class="TextRow01">
			<td valign="top"><cellbytelabel id="5">Direcci&oacute;n</cellbytelabel></td>
			<td colspan="3"><%=fb.textarea("direccion",cdo.getColValue("residencia_direccion"),false,false,true,20,2,100,"","width:92%","")%>	</td>
		</tr>
		<tr class="TextRow01">
			<td valign="top"><cellbytelabel id="6">Lugar de Trabajo</cellbytelabel></td>
			<td colspan="3"><%=fb.textarea("lugar_trabajo",cdo.getColValue("lugar_trabajo"),false,false,true,20,2,80,"","width:92%","")%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel id="7">Datos de la Aseguradora</cellbytelabel></td>
		</tr>
		<tr>
		
		<td colspan="4">
		<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextHeader">
				<td width="50%"><cellbytelabel id="8">Compa&ntilde;&iacute;a de Seguro</cellbytelabel></td>
				<td width="25%"><cellbytelabel id="9">P&oacute;liza</cellbytelabel></td>
				<td width="25"%><cellbytelabel id="10">Certificado</cellbytelabel></td>
			</tr>
	<%	for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo1= (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>	
		<tr class="<%=color%>">
			<td><%=cdo1.getColValue("nombre_empresa")%></td>
			<td><%=cdo1.getColValue("poliza")%></td>
			<td><%=cdo1.getColValue("certificado")%></td>
			
		</tr>
		
		<%}%>
		</table>
		</td>
		</tr>
	
		<tr class="TextHeader">
			<td colspan="4"> <cellbytelabel id="11">Datos del Responsable</cellbytelabel></td>
		</tr>
	
		<tr>
		<td colspan="4">
		<table width="100%" cellpadding="1" cellspacing="1">

		<tr class="TextHeader">
			<td width="30%"><cellbytelabel id="12">Nombre</cellbytelabel></td>
			<td width="20%"><cellbytelabel id="13">Tel&eacute;fono</cellbytelabel></td>
			<td width="20%"><cellbytelabel id="14">Tipo Identificaci&oacute;n</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="15">Identificaci&oacute;n</cellbytelabel></td>
		</tr>
			<%	for (int i=0; i<al2.size(); i++)
			{
				CommonDataObject cdo1= (CommonDataObject) al2.get(i);
				String color = "TextRow02";
				if (i % 2 == 0) color = "TextRow01";
			%>	
		<tr class="<%=color%>">
			<td><%=cdo1.getColValue("nombre")%></td>
			<td><%=cdo1.getColValue("telefono_residencia")%></td>
			<td><%=cdo1.getColValue("tipo_identificacion")%></td>
			<td><%=cdo1.getColValue("identificacion")%></td>
		</tr>
		
		<%}%>
		</table>
		</td>
		</tr>
<!---
		
		<tr class="TextRow01">
			<td>Nombre</td>
			<td><%=fb.textBox("nombre",cdo.getColValue("nombre"),false,false,true,25,100)%></td>
			<td>Tel&eacute;fono</td>
			<td><%=fb.textBox("telefono",cdo.getColValue("telefono_residencia"),false,false,true,15,20)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Tipo Identificaci&oacute;n</td>
			<td><%=fb.select("tipo","C=CEDULA,R=RUC,P=PASAPORTE,O=OTRO",cdo.getColValue("tipo_identificacion"),false,true,1)%></td>
			<td>Identificaci&oacute;n</td>
			
		</tr>
		--->
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel id="16">Diagn&oacute;stico de Ingreso</cellbytelabel></td>
		</tr>
		<tr>
		
		<td colspan="4">
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">
			<td width="15%"><cellbytelabel id="17">C&oacute;digo</cellbytelabel></td>
			<td width="75"%><cellbytelabel id="12">Nombre</cellbytelabel></td>
			<td width="10"%><cellbytelabel id="18">Orden</cellbytelabel></td>
		</tr>
<%
for (int i=0; i<al3.size(); i++)
{
	CommonDataObject cdo1= (CommonDataObject) al3.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>	
		<tr class="<%=color%>">
			<td><%=cdo1.getColValue("diagnostico")%></td>
			<td><%=cdo1.getColValue("nombre")%></td>
			<td align="center"><%=cdo1.getColValue("orden_diag")%></td>
		</tr>
<%
}
%>
		</table>
		</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
%>