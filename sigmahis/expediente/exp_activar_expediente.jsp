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

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String tipoReactivacion = request.getParameter("tipoReactivacion")==null?"":request.getParameter("tipoReactivacion");
String tiempoReactivacion = request.getParameter("tiempoReactivacion")==null?"":request.getParameter("tiempoReactivacion");

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getMethod().equalsIgnoreCase("GET"))
{
	StringBuffer sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_ACTIVATION_HIDE_INCOMPLETE_OPTION'),'N') as hideIncomplete from dual");
	CommonDataObject p = SQLMgr.getData(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Activar expediente - '+document.title;
function doAction(){}
function activarExpediente(){
	var mode = '';
	var justificacion = eval('document.form0.observacion').value;
	var tipoReact = eval('document.form0.tipoReactivacion').value;
	var tiempoReact = eval('document.form0.tiempoReactivacion').value;
	if(justificacion.length < 5 ){
		CBMSG.error('Debe justificar esta acción!...  Sea lo más explicito posible ');return false;
	}else if (validateReact()){
		if(confirm('¿Está seguro que desea Re-activar el Expediente de este Paciente ?')){
		   if (tipoReact != "R") document.form0.tiempoReactivacion.value = "";
		   showPopWin('../common/run_process.jsp?fp=ACTEXP&actType=50&docType=ACTEXP&docId=ACTEXP&docNo=<%=pacId%>-<%=noAdmision%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&comentario='+justificacion+'&compania=<%=(String) session.getAttribute("_companyId")%>&tipoReact='+tipoReact+'&tiempoReact='+tiempoReact,winWidth*.75,winHeight*.50,null,null,'');
		}
	}
}

function validateReact(){
	  var tipoReact = eval('document.form0.tipoReactivacion').value;
	  var tiempoReact = eval('document.form0.tiempoReactivacion').value;
	  if (!tipoReact){
		 CBMSG.error('Sr. Usuario: Favor indique el motivo de la re-activación del expediente');
		 return false;
	  }else{
		if ((tipoReact=='R') && !tiempoReact ){
			CBMSG.error('Sr. USUARIO: Para activaciones por expediente incompleto, favor indicar el tiempo que estará abierto el expediente (TIEMPO DE ACTIVACION)!!!');
			return false;
		}
	  }
	  return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ACTIVAR EXPEDIENTE"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td colspan="4" align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td colspan="4">
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="fp" value="expediente"></jsp:param>
					<jsp:param name="mode" value="view"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		</table>
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("pacId",pacId)%>
		<%=fb.hidden("noAdmision",noAdmision)%>
		<tr class="Textrow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader02">
			<td width="13%">Motivo de Acci&oacute;n:</td>
<%
StringBuffer sbOpt = new StringBuffer();
if ("YS".contains(p.getColValue("hideIncomplete").toUpperCase())) sbOpt.append("P=EXPEDIENTE CERRADO POR ERROR U OMISION DE SALIDA");
else sbOpt.append("R=EXPEDIENTE INCOMPLETO,P=EXPEDIENTE CERRADO POR ERROR U OMISION DE SALIDA");
%>
			<td width="55%"><%=fb.select("tipoReactivacion",sbOpt.toString(),tipoReactivacion,false,false,0,"","","",null,"S")%></td>
			<td width="16%">Tiempo de activaci&oacute;n:</td>
			<td width="16%"><%=fb.select("tiempoReactivacion","6=6 horas,12=12 horas,24=24 horas,36=36 horas,48=48 horas",tiempoReactivacion,false,false,0,"","","",null,"S")%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="3">Justifique esta acci&oacute;n</td>
			<td width="10%">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4"><%=fb.textarea("observacion","",false,false,false,80,4, 2000,"", "width:100%", "")%></td>
		</tr>
		
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<%=fb.button("Activar","Activar Expediente",true,false,null,null,"onClick=\"javascript:activarExpediente()\"")%><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
			</td>
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