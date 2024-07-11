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
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr" />

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
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
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
document.title = 'Reporte de Cajas- '+document.title;
function doAction()
{
}
function showReporte(id)
{
var msg= '';
var fRecDesde = document.form0.fRecDesde.value ;
var fRecHasta = document.form0.fRecHasta.value ;
var fAplDesde = document.form0.fAplDesde.value ;
var fAplHasta = document.form0.fAplHasta.value ;
var pagosLiberados = document.form0.pagosLiberados.value ;
abrir_ventana("../cellbyteWV/report_container.jsp?reportName=caja/rpt_pagos_aplicados.rptdesign&fRecDesde="+fRecDesde+'&fRecHasta='+fRecHasta+'&fAplDesde='+fAplDesde+'&fAplHasta='+fAplHasta+'&pagoLiberado='+pagosLiberados);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE CAJAS"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>  
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"> 
		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
				<tr class="TextHeader">
<td colspan="4"><cellbytelabel>Reporte de Pagos Aplicados</cellbytelabel></td>
				</tr>
				<tr class="TextRow01"> 
					<td width="25%"><cellbytelabel>Fecha Recibo</cellbytelabel></td>
					<td width="25%" colspan="3"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fRecDesde" />
											<jsp:param name="valueOfTBox1" value="" />
											<jsp:param name="nameOfTBox2" value="fRecHasta" />
											<jsp:param name="valueOfTBox2" value="" />
											</jsp:include></td>
				
				</tr>
				<tr class="TextRow01"> 
					<td width="25%"><cellbytelabel>Fecha Aplicaci&oacute;n</cellbytelabel></td>
					<td width="25%" colspan="3"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="2" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fAplDesde" />
											<jsp:param name="valueOfTBox1" value="" />
											<jsp:param name="nameOfTBox2" value="fAplHasta" />
											<jsp:param name="valueOfTBox2" value="" />
											</jsp:include></td>
				
				</tr>
				<tr class="TextRow01"> 
					<td colspan="4" align="center">
					Mostrar Pagos Liberados?
					<%=fb.select("pagosLiberados","N=NO,S=SI","N",false,false,0,"Text10",null,null,null,"")%>
					<%=fb.button("addReporteR","Reporte ",false,false,null,null,"onClick=\"javascript:showReporte(1)\"","Reporte")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			
	<%fb.appendJsValidation("if(error>0)doAction();");%>		
	<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>