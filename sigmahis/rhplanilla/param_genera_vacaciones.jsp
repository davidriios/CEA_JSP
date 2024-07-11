
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String compania = request.getParameter("compania");
String tipo = "";
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
if (compania == null) compania = (String) session.getAttribute("_companyId");

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Recursos Humanos- '+document.title;
function doAction()
{
}

function rutProceso()
{

var msg = '';
var anio = eval('document.form0.anio').value ;
var tipo = eval('document.form0.tipo').value ;
var estado = eval('document.form0.estado').value ;

if(anio == "")
msg = ' Año ';
if(estado == "")
msg += ', estado ';
if(msg == '')
{
  if(confirm('Está Seguro de Generar proceso de vacaciones!!!'))
	{
		
	showPopWin('../common/run_process.jsp?fp=VAC&actType=50&docType=VAC&docId='+anio+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&tipo='+tipo+'&estado='+estado,winWidth*.75,winHeight*.65,null,null,'');
		
	/*if(executeDB('<%=request.getContextPath()%>','call SP_PLA_VACACIONES('+anio+','+tipo+',<%=compania%>)','tbl_pla_vacacion'))
		
		{
		alert('Estatus Cambiado!');
		window.location = '../rhplanilla/param_genera_vacaciones.jsp';
		}*/
	}else alert('Proceso Cancelado!!!');
}
else alert('Seleccione '+msg);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="GENERAR VACACIONES"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="1">
	<tr>
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>

	<tr class="TextFilter">
			<td> Año <%=fb.textBox("anio","",false,false,false,5)%></td>
			</tr>

		<tr class="TextFilter">
			<td> Tipo de Empleado
	 <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_pla_tipo_empleado","tipo",tipo,false,false,0,"Text10",null,null,null,"")%></td>
	 </tr>



		<tr class="TextFilter">
			<td> Estado del Empleado <%=fb.select("estado","1 = EMPLEADOS ACTIVOS  ,3 = EXEMPLEADOS ","")%></td>
			</tr>

		<authtype type='50'>  
		<tr class="TextFilter">
			<td><%=fb.button("buscar","Generar Proceso",false,viewMode,"","","onClick=\"javascript:rutProceso()\"")%></td>
		</tr>
		</authtype>


	</table>
</td>
</tr>

<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
</body>
</html>
<%
}//GET
%>
