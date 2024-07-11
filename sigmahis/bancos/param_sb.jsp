<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
sb1008
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reporte de Saldo Bancario Consolidado- '+document.title;
function doAction(){}
function showReport(){var fDate=document.form0.fDate.value;var fc1=document.form0.fc1.value;var fc2=document.form0.fc2.value;var bf=document.form0.bf.value;var pf1=document.form0.pf1.value;var pf2=document.form0.pf2.value;var pf3=document.form0.pf3.value;var pf4=document.form0.pf4.value;var pf5=document.form0.pf5.value;if(fDate=='')alert('Por favor introduzca la fecha para poder generar el reporte!');else abrir_ventana('../bancos/print_sb_consolidado.jsp?fDate='+fDate+'&fc1='+fc1+'&fc2='+fc2+'&bf='+bf+'&pf1='+pf1+'&pf2='+pf2+'&pf3='+pf3+'&pf4='+pf4+'&pf5='+pf5);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SALDO BANCARIO CONSOLIDADO"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
		<tr class="TextRow01">
			<td width="35%" align="right">Fecha</td>
			<td width="65%">
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fDate"/>
				<jsp:param name="valueOfTBox1" value=""/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextPanel">
		 <td colspan="2" align="center">DEPOSITOS A PLAZO FIJO</td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Fondo de Cesant&iacute;a CSF</td>
			<td><%=fb.decBox("fc1","853884",false,false,false,15,12.2,null,null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Fondo de Cesant&iacute;a BFE</td>
			<td><%=fb.decBox("fc2","20606",false,false,false,15,12.2,null,null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Bound Fund</td>
			<td><%=fb.decBox("bf","1500000",false,false,false,15,12.2,null,null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Banco General</td>
			<td><%=fb.decBox("pf1","",false,false,false,15,12.2,null,null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Inversiones con Terceros</td>
			<td><%=fb.decBox("pf5","",false,false,false,15,12.2,null,null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">TowerBank - Plazo Fijo</td>
			<td><%=fb.decBox("pf2","",false,false,false,15,12.2,null,null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Banistmo (Bethania) - Plazo Fijo</td>
			<td><%=fb.decBox("pf3","",false,false,false,15,12.2,null,null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">Banistmo (Paitilla) - Plazo Fijo</td>
			<td><%=fb.decBox("pf4","",false,false,false,15,12.2,null,null,null)%></td>
		</tr>
		<tr>
			<td colspan="2" align="center"><%=fb.button("btnReport","Generar Informe",false,false,null,null,"onClick=\"javascript:showReport()\"")%></td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
%>