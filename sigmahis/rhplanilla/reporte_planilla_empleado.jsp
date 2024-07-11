<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String appendFilter = "";
String key = "";


String seccion = "";
String area = request.getParameter("area");
String grupo = request.getParameter("grupo");


if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Planilla - "+document.title;

function doRedirect(seccion)
{
  var empId;
	var grupo;
	
	
   document.getElementById("iDetalle").src = '../rhplanilla/reg_varios_empleado_redirect.jsp?seccion='+seccion;
}


function doAction()
{
    
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE PLANILLA - EMPLEADOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("grupo",grupo)%>
					
		
		<tr>
			<td width="20%" class="TableBorder">	
			<table width="100%" cellpadding="1" cellspacing="1">
		
		<tr class="TextHeader">
			<td>Listado de Reportes</td>
		</tr>
		<tr>
			<td>
			<div id="secciones" style="overflow:scroll; position:static; height:400">
			<table width="100%" border="0" cellpadding="1" cellspacing="0">
		<tr class="TextRow02" onClick="javascript:doRedirect('1')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">	  <td>Empleados por Tipo de Sangre</td>
		</tr>
		<tr class="TextRow01" onClick="javascript:doRedirect('2')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">		<td>Empleados por Estado Civil</td>
		</tr>
		<tr class="TextRow02" onClick="javascript:doRedirect('3')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">		<td>Empleados por Sexo / Puesto</td>
		</tr>
		<tr class="TextRow01" onClick="javascript:doRedirect('4')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">		<td>Parientes de Empleados</td>
		</tr>
		<tr class="TextRow02" onClick="javascript:doRedirect('5')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">		<td>Información de Escolaridad de Empleados </td>
		</tr>
		<tr class="TextRow01" onClick="javascript:doRedirect('6')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">		<td>Parientes de Empleados - Urgencia</td>
		</tr>
		<tr class="TextRow02" onClick="javascript:doRedirect('7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">		<td>Empleados por Sexo</td>
		</tr>
		<tr class="TextRow01" onClick="javascript:doRedirect('8')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">		<td>Empleados por Puesto</td>
		</tr>
		<tr class="TextRow02" onClick="javascript:doRedirect('9')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">		<td>Empleados por Número de Seguro Social(Fichas)</td>
		</tr>
		<tr class="TextRow01" onClick="javascript:doRedirect('10')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">		<td>Empleados Alfabeticamente</td>
		</tr>
		<tr class="TextRow02" onClick="javascript:doRedirect('11')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">		<td>Empleados Segun Horas Diarias Laboradas</td>
		</tr>
		<tr class="TextRow01" onClick="javascript:doRedirect('12')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">		<td>Cumpleaños de Empleados</td>
		</tr>
		<tr class="TextRow02" onClick="javascript:doRedirect('13')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">		<td>Empleados por Clave de Renta</td>
		</tr>	
		<tr class="TextRow02" onClick="javascript:doRedirect('14')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">		<td>Empleados con/sin Licencia de Conducir</td>
		</tr>	  
			   
	   </table>
	   </div>
		  </td>
		</tr>														
			</table>
			</td>
	 		<td  valign="top" width="80%" class="TableBorder TextRow01">
			<iframe id="iDetalle" name="iDetalle" width="100%" height="418" scrolling="no" frameborder="0" src="../rhplanilla/reg_varios_empleado_redirect.jsp"></iframe>
			</td>
		</tr>
				
		<tr class="TextRow02">
			<td colspan="2" align="right"><%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:closeWin()\"")%></td>
		</tr>
			<%=fb.formEnd(true)%>

<!-- ================   F O R M   E N D   H E R E   ================================ -->

			
		
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
%>