
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
String codigo = "";
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
document.title = 'Planilla - Procesos - '+document.title;
function doAction()
{
}

function rutProceso()
{

var msg = '';
//var anio = eval('document.form0.tipo').value ;
var tipo = eval('document.form0.tipo').value ;
//var estado = eval('document.form0.estado').value ;

if(anio == "")
msg = ' Año ';
if(estado == "")
msg += ', estado ';
if(msg == '')
{
if(estado != null)
{
  if(confirm('Desea Cambiar el Estatus para Empleados Activos'))
	{
		
		
	if(executeDB('<%=request.getContextPath()%>','call SP_PLA_VACACIONES('+anio+','+tipo+',<%=compania%>)','tbl_pla_vacacion'))
		
		{
		alert('Estatus Cambiado!');
		window.location = '../rhplanilla/param_genera_vacaciones.jsp';
		}
	}
}//if estatus != ''
}
else alert('Seleccione '+msg);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="PLANILLA EN DEFINITIVA"></jsp:param>
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
			<td> PLANILLA DE ACREEDORES A ESTADO EN DEFINITIVA </td>
			</tr>
	
		<tr class="TextFilter">
			<td> Planilla a poner en Definitiva
	 <%=fb.select(ConMgr.getConnection(),"select a.anio||'-'||a.cod_planilla||'-'||a.num_planilla, '[ '||a.anio||'-'||a.cod_planilla||'-'||a.num_planilla||' ] '||b.nombre from tbl_pla_planilla_encabezado a,tbl_pla_planilla b where a.estado = 'B' and a.cod_planilla = b.cod_planilla and a.cod_compania = "+(String) session.getAttribute("_companyId")+" and b.compania = a.cod_compania and b.cod_planilla = 4 order by 1","codigo",codigo,false,false,0,"Text10",null,null,null,"S")%></td>
	  </tr>
		
		
		
			<tr class="TextFilter">
			<td><%=fb.button("buscar","Generar Proceso",false,viewMode,"","","onClick=\"javascript:rutProceso()\"")%></td>
		</tr>
	
	
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
