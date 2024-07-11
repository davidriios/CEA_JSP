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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario*** */

UserDet = SecMgr.getUserDetails(session.getId());  /* *** quitar el comentario **** */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al       = new ArrayList();
ArrayList alUnidad = new ArrayList();

String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String observ = "", estado = "", unidad = "", beneficiario = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String compania = (String) session.getAttribute("_companyId");
String user     = (String) session.getAttribute("_userName");

String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);

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
document.title = 'Reportes de Cuentas por Pagar - '+document.title;

function showReporte()
{
	var tipo       = document.form0.tipo.value||'ALL';
	var codigo       = document.form0.codigo.value||'ALL';
	var fechaini     = document.form0.fechaini.value;
	var fechafin     = document.form0.fechafin.value;
  var pCtrlHeader ="false";
	var excluirConta ="ALL";
	
	 
	abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxp/rpt_cxp_honorarios_no_pagados.rptdesign&tipoParam='+tipo+'&fDesdeParam='+fechaini+'&fHastaParam='+fechafin+'&codigoParam='+codigo);
	
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="HONORARIOS SIN PAGAR"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
<tr>
 <td>
	 <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

				<tr class="TextFilter" >
					 <td width="20%">Tipo</td>
					 <td width="80%"><%=fb.select("tipo","M=Medico, E=Empresa",estado,false,false,0,null,null,"","","T")%></td>
				</tr>

				<tr class="TextFilter">
						<td>C&oacute;digo</td>
					<td><%=fb.textBox("codigo","",false,false,false,20,20,"Text10",null,null)%>
				</td>
				</tr>
 				<tr class="TextFilter" >
					 <td >Fecha</td>
					 <td>
			&nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fechaini" />
					<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			<jsp:param name="nameOfTBox2" value="fechafin" />
			<jsp:param name="valueOfTBox2" value="<%=cDateTime%>" />
			</jsp:include>
							 </td>
				</tr>
				<tr class="TextFilter" align="center">
                            <td colspan="2"><%=fb.button("verTxt","Reporte",false,false,"text10","","onClick=\"javascript:showReporte();\"")%> </td>
                </tr>
			</table>

		
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</td>
	</tr>
	</td>
	</tr>

<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
%>

