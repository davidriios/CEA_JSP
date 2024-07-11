<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String careDate = request.getParameter("careDate");
if (pacId == null || pacId.trim().equals("") || admision == null || admision.trim().equals("")) throw new Exception("La Cuenta no es válida. Por favor intente nuevamente o consulte con su Administrador!");
if (careDate == null) careDate = "";

sbSql.append("select * from (select categoria, to_char(hora,'dd/mm/yyyy hh24:mi:ss') as triage_date from tbl_sal_signo_paciente where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(admision);
sbSql.append(" and tipo_persona = 'T' and status = 'A' order by hora desc) where rownum = 1");
CommonDataObject adm = SQLMgr.getData(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<style type="text/css">
.nourgente:hover{background-color: #008000;}
.critico:hover{background-color: #F00;}
.urgente:hover{background-color: #ff0;}
.nourgente:hover,.critico:hover,.urgente:hover{color:#000;}
</style>
<script language="javascript">
document.title = 'Expediente Cambio de Categoría Triage - '+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CAMBIAR CATEGORIA TRIAGE"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="5" cellspacing="1" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("careDate",careDate)%>
<%=fb.hidden("triage_date",adm.getColValue("triage_date"))%>
		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel>Cambiar Categor&iacute;a de Triage (<%=adm.getColValue("categoria")%>) de la Cuenta #<%=pacId%>-<%=admision%> a:</cellbytelabel></td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="2" class="critico">
				<table width="50%">
				<tr>
					<td width="20%" align="right"><%=fb.radio("categoria","1",adm.getColValue("categoria").equals("1"),false,false,"","","","","","critico")%></td>
					<td width="80%"><label for="critico" style="cursor:pointer"><cellbytelabel>[ I ] CRITICO</cellbytelabel></label></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="2" class="urgente">
				<table width="50%">
				<tr>
					<td width="20%" align="right"><%=fb.radio("categoria","2",adm.getColValue("categoria").equals("2"),false,false,"","","","","","urgente")%></td>
					<td width="80%"><label for="urgente" style="cursor:pointer"><cellbytelabel>[ II ] URGENTE</cellbytelabel></label></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow01" align="center">
			<td colspan="2" class="nourgente">
				<table width="50%">
				<tr>
					<td width="20%" align="right"><%=fb.radio("categoria","3",adm.getColValue("categoria").equals("3"),false,false,"","","","","","nourgente")%></td>
					<td width="80%"><label for="nourgente" style="cursor:pointer"><cellbytelabel>[ III ] NO URGENTE</cellbytelabel></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center"><b>Motivo:</b>
			<%=fb.textarea("motivo","",true,false,false,100,2, 1000)%>
			</td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td colspan="2">
				<%=fb.submit("save","Cambiar",true,false,null,"","")%>
				<%=fb.button("cancel","Cancelar",false,false,null,"","onClick=\"javascript:parent.hidePopWin(false)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
} else {
	CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	String rParam = null;//parámetro que devuelve el procedimiento almacenado

	sbSql = new StringBuffer();
	sbSql.append("update tbl_sal_signo_paciente z set categoria = ?, motivo_cambio_cat = ?, fecha_cambio_cat = sysdate, usuario_cambio_cat = ? where pac_id = ? and secuencia = ? and hora = to_date(?,'dd/mm/yyyy hh24:mi:ss') and tipo_persona = 'T' and status = 'A'");
	param.setSql(sbSql.toString());
	param.addInNumberStmtParam(1,request.getParameter("categoria"));
	param.addInStringStmtParam(2,IBIZEscapeChars.forSingleQuots(request.getParameter("motivo")));
	param.addInStringStmtParam(3,IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));
	param.addInNumberStmtParam(4,request.getParameter("pacId"));
	param.addInNumberStmtParam(5,request.getParameter("admision"));
	param.addInStringStmtParam(6,request.getParameter("triage_date"));

	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"pacId="+pacId+"&admision="+admision+"&careDate="+careDate+"&triage_date="+request.getParameter("triage_date"));
	SQLMgr.executePrepared(param);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
alert('<%=SQLMgr.getErrMsg()%>');
<% } else throw new Exception(SQLMgr.getErrException()); %>
parent.window.location.reload(true);
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>