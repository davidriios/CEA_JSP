
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
=============================================================================================
		FG             	REPORTE                DESCRIPCION                         
		FV          	COM0008.RDF            COMPROMISOS POR FECHA DE VENCIMIENTO
		PP				COM0001.RDF			   PAGO A PROVEEDORES 
=============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String proveedor = "";
String tipo = "";
String compania =  (String) session.getAttribute("_companyId");	
String fg = request.getParameter("fg");

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reporte de Compras- '+document.title;
function doAction()
{
}
function showProveedor()
{
		abrir_ventana('../compras/sel_proveedor.jsp?fp=OC');
}

function showReporte()
{
	var fecha_i   = eval('document.form0.fechaini').value;
	var fecha_f   = eval('document.form0.fechafin').value;
	var proveedor = eval('document.form0.codProv').value;
	var tipo      = eval('document.form0.tipo').value;
	
	if((fecha_i =='') || (fecha_f ==''))
	alert('Seleccione una Fecha')
	else
	
		<%if(fg.trim().equals("FV")){%>

	abrir_ventana('../compras/print_detalle_fvencimiento.jsp?fp=FV&fDate='+fecha_i+'&tDate='+fecha_f+'&proveedor='+proveedor+'&tipo='+tipo);

		<%} else if(fg.trim().equals("PP")){%>
		abrir_ventana('../compras/print_pagos_proveedor.jsp?fp=PP&fDate='+fecha_i+'&tDate='+fecha_f+'&proveedor='+proveedor+'&tipo='+tipo);

		<%}%>
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(fg.trim().equals("FV")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE COMPROMISOS POR FECHA DE VENCIMIENTO"></jsp:param>
</jsp:include>
<%} else if(fg.trim().equals("PP")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE PAGOS A PROVEEDORES"></jsp:param>
</jsp:include>

<%}%>

<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
	<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%> 
		
			
	<tr class="TextFilter">
		<td><cellbytelabel>Tipo</cellbytelabel> </td>
		<td>
				<%=fb.select(ConMgr.getConnection(),"select tipo_com, '[ '||tipo_com||' ] '||descripcion from tbl_com_tipo_compromiso where estatus='A' order by tipo_com","tipo","",false,false,0,"","","S")%>

<%//=fb.select("tipo","2=ORDEN DE COMPRA ESPECIAL,3=ORDEN DE COMPRA PARCIAL","","S")%></td>
		
		</tr>
	
	<tr class="TextFilter">
		<td><cellbytelabel>Proveedor</cellbytelabel> </td>
		<td><%=fb.textBox("codProv","",false,false,false,5)%> 
		 <%=fb.textBox("descProv","",false,false,true,50)%><%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showProveedor()\"")%></td>
	</tr>
	
	<tr class="TextFilter">
		<td><cellbytelabel>Fecha</cellbytelabel></td>
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechaini" />
			<jsp:param name="valueOfTBox1" value="" />
						
			<jsp:param name="nameOfTBox2" value="fechafin" />
			<jsp:param name="valueOfTBox2" value="" />
			</jsp:include></td>
			
	</tr>
	
		
	<tr class="TextHeader">
		<td>&nbsp;</td>
		<td><%=fb.button("reporte","Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"")%></td>
	</tr>
  </table>
</td></tr>
</table>
</body>
</html>
<%
}//GET
%>
