<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

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
document.title = 'Pagos Aplicados - '+document.title;
function doAction()
{
}
function showReport()
{
   var pacId = $("#pacId").val();
   var codPac = $("#codigoPaciente").val();
   var pacName = $("#nombrePaciente").val();
   var dob = $("#fechaNacimiento").val();
   var noRecibo =  $("#recibo").val() || 0;
   var pCtrlHeader = document.getElementById("pCtrlHeader").checked;
   var fecha = $("#fechaDesde").val();
   fecha = fecha.split("/");
   fecha = fecha[2]+"-"+fecha[1]+"-"+fecha[0];

   abrir_ventana("../cellbyteWV/report_container.jsp?reportName=cxc/rpt_pagos_aplicados.rptdesign&pPacId="+pacId+"&pCodPac="+codPac+"&pDOB="+dob+"&pRecibo="+noRecibo+"&pPacName="+pacName+"&pCtrlHeader="+pCtrlHeader+"&fDesde="+fecha);
}

function addPatient(){
	abrir_ventana("../common/sel_paciente.jsp?fp=rpt_pagos_aplicados");
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PAGOS APLICADOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">   
	<tr>  
		<td>   
		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("codigoPaciente","")%>
			<%=fb.hidden("fechaNacimiento","")%>
			<%=fb.hidden("admSecuencia","")%>
	<tr>
	<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
			
				<tr class="TextRow01"> 
					<td align="center">Paciente&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<%=fb.textBox("pacId","",false,false,true,15)%>
					<%=fb.textBox("nombrePaciente","",false,false,true,60)%>
					<%=fb.button("btnPac","...",true,false,null,null,"onClick=addPatient()","")%>
					</td>
				</tr>
				<tr class="TextRow01"> 
					<td align="center">
					No. Recibo&nbsp;&nbsp;<%=fb.textBox("recibo","",false,false,false,15)%>
					Informaci&oacute;n a partir del:
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fechaDesde" />
						<jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>" />
					</jsp:include>
					&nbsp;&nbsp;&nbsp;
					<label for="pCtrlHeader">Sin Cabecera</label>
					<input type="checkbox" name="pCtrlHeader" id="pCtrlHeader"  />
					&nbsp;&nbsp;&nbsp;
					<%=fb.button("addReporte","Generar Reporte",true,false,null,null,"onClick=showReport()","Reporte")%></td>
				</tr>	
<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
</table>
</td>
</tr> 
</table>
</body>
</html>
<%
}//GET
%>