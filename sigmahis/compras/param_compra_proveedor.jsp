
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
		OCP				INV70304.RDF		   ORDENES DE COMPRA POR PROVEEDOR
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


String anio = "";
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
	var anio   = eval('document.form0.anio').value;
	var proveedor = eval('document.form0.codProv').value;


	abrir_ventana('../compras/print_compra_proveedor.jsp?fp=OCP&anio='+anio+'&proveedor='+proveedor);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE ORDENES DE COMPRA POR PROVEEDOR"></jsp:param>
</jsp:include>

<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
		<tr class="TextFilter">
			<td><cellbytelabel>A&ntilde;o</cellbytelabel></td>
			<td><%=fb.textBox("anio","",false,false,false,10)%></td>

		</tr>


		<tr class="TextFilter">
			<td><cellbytelabel>Proveedor</cellbytelabel> </td>
			<td>
				<%=fb.textBox("codProv","",false,false,true,5)%>
				<%=fb.textBox("descProv","",false,false,true,50)%>
				<%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showProveedor()\"")%>
			</td>
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
