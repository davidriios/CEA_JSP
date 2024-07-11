<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String companyId = (String) session.getAttribute("_companyId");
if(request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario de Artículos  - '+document.title;
function viewReporte(){
var contrato = document.search00.contrato.value;
var responsable = document.search00.responsable.value;
abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_miembros_morosos.rptdesign&contratoParam='+contrato+'&responsableParam='+responsable);
}

var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();chkRptType();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,350);}


</script>
</head>
<body onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value=""></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<tr>
	<td class="TableBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
        
        <tr class="TextFilter">
			<td width="25%" align="right"><cellbytelabel id="1">Contrato</cellbytelabel></td>
			<td width="75%"> <%=fb.textBox("contrato","",false,false,false,20,50,null,null,"")%>
            </td>
		</tr>
        <tr class="TextFilter">
			<td width="25%" align="right"><cellbytelabel id="2">Responsable</cellbytelabel></td>
			<td width="75%"> <%=fb.textBox("responsable","",false,false,false,60,100,null,null,"")%>
            </td>
		</tr>
		
		<tr class="TextRow01">
			<td align="center" colspan="2">
				<%=fb.button("save","Reporte",true,false,null,null,"onClick=\"javascript:viewReporte();\"")%>
			</td>
		</tr>
		</table>
</div>
</div>

	</td>
</tr>
<%=fb.formEnd()%>
</table>
</body>
</html>
<% } %>