<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());  /* *** quitar el comentario **** */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fg = request.getParameter("fg");

if (mode == null) mode = "add";
if (fg == null) fg = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Cuentas por Centro de Servicio - '+document.title;
function showReporte(value)
{

  var cds     = eval('document.form0.area').value;
  var type    = eval('document.form0.type').value;
  var fg      = eval('document.form0.fg').value;
  var recibeMov      = eval('document.form0.recibeMov').value;

	if(value=="1")
	{
 	abrir_ventana2('../contabilidad/print_mapping_cuenta.jsp?cds='+cds+'&type='+type+'&fg='+fg+'&recibeMov='+recibeMov);
	}

}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="POR CENTRO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<tr>
	<td class="TableBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
  	<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
			<td width="20%">Centro de Servicio</td>
			<td width="80%"><%=fb.select(ConMgr.getConnection(),"select distinct b.codigo, '['||b.codigo||'] '||b.descripcion, b.descripcion from tbl_cds_servicios_x_centros a, tbl_cds_centro_servicio b where a.centro_servicio = b.codigo and b.compania_unorg = "+session.getAttribute("_companyId")+" union all select -1, '[-1] NO APLICA','[-1] NO APLICA' from dual order by 3","area",area,"T")%></td>
		</tr>
		<tr class="TextRow01">
			<td>Tipo de Cuenta</td>
			<td><%=fb.select(ConMgr.getConnection(),"select id,description||' - '||id codigo from tbl_con_acctype where status = 'A' order by 1","type","4","")%></td>
		</tr>
		<tr class="TextRow01">
			<td>Sin Cuentas</td>
			<td><%=fb.select("fg","SC=CENTROS SIN CUENTAS ASIGNADAS,CC=CON CUENTAS ASIGNADAS","",false,false,0,"Text10",null,null,null,"T")%></td>
		</tr>
		<tr class="TextRow01">
			<td>Recibe Movimiento</td>
			<td><%=fb.select("recibeMov","S=SI,N=NO","",false,false,0,"Text10",null,null,null,"T")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="center"></td>
			<td><authtype type='50'><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Mapping de Cuenta</authtype></td>
		</tr>
		</table>
</div>
</div>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
%>
