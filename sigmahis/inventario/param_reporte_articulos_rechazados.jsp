
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

String almacen = "";
String compania =  (String) session.getAttribute("_companyId");
String fg = request.getParameter("fg");

if(fg == null ) fg = "DUA";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reportes -  Inventario - Devoluciones- '+document.title;
function doAction()
{
}
function showArea()
{
		var fg = '';
		abrir_ventana1('../inventario/sel_unid_ejec.jsp?fg=DUA');
}
function clearText()
{
 document.form0.codArea.value="";
 document.form0.descArea.value="";
}
function showReporte2()
{	
	var fecha_ini = eval('document.form0.fechaini').value||'ALL';
	var fecha_fin = eval('document.form0.fechafin').value||'ALL';
	var wh        = eval('document.form0.almacen').value||'ALL';
	var area      = eval('document.form0.codArea').value||'ALL';
	abrir_ventana('../cellbyteWV/report_container.jsp?reportName=inventario/rpt_articulos_rechazados.rptdesign&fDesde='+fecha_ini+'&fHasta='+fecha_fin+'&almacenParam='+wh+'&uaParam='+area);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE ARTICULOS RECHAZADOS"></jsp:param>
	</jsp:include>


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
			<tr class="TextFilter">
				<td>Almacen</td>
				<td colspan="2"><%=fb.select("almacen","","")%>

      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:""%>','KEY_COL','S');
			</script></td>
			</tr>

			<tr class="TextFilter">
			<td>Unidad Administrativa </td>
				<td colspan="2">
					<%=fb.textBox("codArea","",false,false,false,5,null,null,"onFocus=\"javascript:clearText()\"")%>
				 <%=fb.textBox("descArea","",false,false,true,50)%>
				 <%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showArea()\"")%>
			 </td>
			</tr>
			<tr class="TextFilter">
			<td>Fecha</td>
			<td colspan="2"><jsp:include page="../common/calendar.jsp" flush="true">
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
			<td colspan="3" align="center"> <%=fb.button("report","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte2()\"")%>	</td>
		</tr>	
			
			
	<%=fb.formEnd(true)%>
	<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>

</td></tr>


</table>
</body>
</html>
<%
}//GET
%>
