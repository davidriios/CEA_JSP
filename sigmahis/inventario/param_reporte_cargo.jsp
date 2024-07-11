
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
======================================================================================================
	   INV00125.RDF			CP					REPORTE DE CARGOS A LOS PACIENTES 
						   INV00140.RDF			DC					REPORTE DE DETALLADO CARGOS A LOS PACIENTES 							   
================================================================================================

**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String almacen = "";
boolean viewMode = false;
String compania =  (String) session.getAttribute("_companyId");	
String fg = request.getParameter("fg");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");


if(fg == null ) fg = "CB";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reportes -  Inventario - '+document.title;
function doAction()
{
}

function showReporte(value)
	{
      	var fechaini = eval('document.form0.fechaini').value;
		var fechafin = eval('document.form0.fechafin').value;
	
			if(value=="0")
			abrir_ventana('../inventario/print_list_detalle_cargo.jsp?fg=CP&fDate='+fechaini+'&tDate='+fechafin);
			
		else if (value=="3")
			abrir_ventana('../inventario/print_list_detalle_cargo.jsp?fg=CD&fDate='+fechaini+'&tDate='+fechafin);
			
	}
</script>
<style type="text/css">
<!--
.style1 {color: #000000}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.trim().equals("CB")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE CARGO A LOS PACIENTES ."></jsp:param>
	</jsp:include>
<%}%>

<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="1">
  <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
  <%=fb.formStart(true)%>
  <%=fb.hidden("compania",compania)%>
  
 <tr class="TextHeader">
    <td colspan="2">REPORTE POR RANGO DE FECHAS</td>
  </tr>
  <tr class="TextFilter">
    <td>Fecha</td>
    <td>
      <jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="2" />
      <jsp:param name="clearOption" value="true" />
      <jsp:param name="nameOfTBox1" value="fechaini" />
      <jsp:param name="valueOfTBox1" value="" />
      <jsp:param name="nameOfTBox2" value="fechafin" />
      <jsp:param name="valueOfTBox2" value="" />
      </jsp:include>
    </td>
  </tr>
   <tr class="TextFilter">
    <td colspan="2" align="center"><%=fb.button("report","Reporte de Cargos",true,false,null,null,"onClick=\"javascript:showReporte(0)\"")%><%=fb.button("report","Reporte Detallado",true,false,null,null,"onClick=\"javascript:showReporte(3)\"")%></td>
  </tr>

 <%=fb.formEnd(true)%>
 
  <!-- ================================   F O R M   E N D   H E R E   ================================ -->
  
</table></td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
