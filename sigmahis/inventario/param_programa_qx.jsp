
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
FG = PQ  REPORTE DEL PROGRAMA QUIRURGICO 
FG = IN  REPORTE INSUMOS Y MATERIALES POR PROCEDIMIENTOS
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
String fg = request.getParameter("fg");
if(fg == null) fg = "PQ";

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
function showReporte(opt)
{
	<%if(fg.trim().equals("PQ")){%>
	var fecha = eval('document.form0.fecha').value;
	if(fecha != '')abrir_ventana('../cita/print_citas_quirofano.jsp?fechaCita='+fecha);
	else alert('Seleccione fecha');
	<%} else if(fg.trim().equals("IN")){%>
	var cpt = eval('document.form0.cpt').value;
	if(cpt != '') {
    if(!opt) abrir_ventana('../inventario/print_cdc_insumos.jsp?cpt='+cpt);
    else if(opt==1) abrir_ventana('../inventario/print_cdc_insumos.jsp?cost=Y&cpt='+cpt);
    else if(opt==2) abrir_ventana('../inventario/print_cdc_insumos.jsp?price=Y&cpt='+cpt);
  } else alert('Seleccione Procedimiento');
	<%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
	<%if(fg.trim().equals("PQ")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE PROGRAMA QUIRURGICO"></jsp:param>
	</jsp:include>
<%} else if(fg.trim().equals("IN")){%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE PROGRAMA QUIRURGICO"></jsp:param>
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
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
			
			<%if(fg.trim().equals("PQ")){%>
			<tr class="TextFilter">
				<td align="center">Fecha <jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fecha" />
											<jsp:param name="valueOfTBox1" value="" />
											</jsp:include> </td>
			</tr>
		<%} else if(fg.trim().equals("IN")){%>
		  <tr class="TextFilter">
				<td align="center">Código de CPT del Procedimiento  <%=fb.textBox("cpt","",false,false,false,10,20)%></td>
			</tr>
			
		<%}%>	
		<tr class="TextFilter">
			<td align="center">
        <authtype type='51'>
          <%=fb.button("report","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"")%>
          <%=fb.button("report2","Con Costo",true,false,null,null,"onClick=\"javascript:showReporte(1)\"")%>
          <%=fb.button("report3","Con Precio",true,false,null,null,"onClick=\"javascript:showReporte(2)\"")%>
        </authtype>
      </td>
		</tr>
<%=fb.formEnd(true)%>
	</table>
</td></tr>

</table>
</body>
</html>
<%
}//GET
%>
