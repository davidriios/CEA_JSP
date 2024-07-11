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
String tipoPersona = request.getParameter("tipoPersona");
String fecha = request.getParameter("fecha");
String hora = request.getParameter("hora");
if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (tipoPersona == null) tipoPersona = "";
if (fecha == null) fecha = "";
if (hora == null) hora = "";
if (pacId.trim().equals("") || admision.trim().equals("") || tipoPersona.trim().equals("") || fecha.trim().equals("") || hora.trim().equals("")) throw new Exception("Signo Vital no es válido. Por favor intente nuevamente o consulte con su Administrador!");

sbSql.append("select to_char(fecha_registro,'dd/mm/yyyy')||' '||to_char(hora_registro,'hh12:mi:ss am') as fhRegistro, decode(tipo_persona,'T','TRIAGE','M','MEDICO','E','ENFERMERA','A','AUXILIAR',tipo_persona)||' - '||usuario_creacion as usrRegistro, status, (select nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) as paciente from tbl_sal_signo_paciente z where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(admision);
sbSql.append(" and tipo_persona = '");
sbSql.append(tipoPersona);
sbSql.append("' and trunc(fecha) = to_date('");
sbSql.append(fecha);
sbSql.append("','dd/mm/yyyy') and hora = to_date('");
sbSql.append(fecha);
sbSql.append(" ");
sbSql.append(hora);
sbSql.append("','dd/mm/yyyy hh12:mi:ss am')");
CommonDataObject adm = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select a.signo_vital, nvl(a.resultado,' ') resultado, b.descripcion as signoDesc, nvl(c.sigla_um,' ') as signoUnit from tbl_sal_detalle_signo a, tbl_sal_signo_vital b, tbl_sal_signo_vital_um c where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.secuencia = ");
sbSql.append(admision);
sbSql.append(" and a.signo_vital = b.codigo and a.signo_vital = c.cod_signo(+) and c.valor_default(+) = 'S' and a.tipo_persona = '");
sbSql.append(tipoPersona);
sbSql.append("' and trunc(a.fecha_signo) = to_date('");
sbSql.append(fecha);
sbSql.append("','dd/mm/yyyy') and a.hora = to_date('");
sbSql.append(fecha);
sbSql.append(" ");
sbSql.append(hora);
sbSql.append("','dd/mm/yyyy hh12:mi:ss am') order by b.orden, a.fecha_signo, a.hora, a.signo_vital");//depends on header's status
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Expediente Invalidar Signo Vital - '+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INVALIDAR SIGNO VITAL"></jsp:param>
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
<%=fb.hidden("tipoPersona",tipoPersona)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("hora",hora)%>
		<tr class="TextPanel" align="center">
			<td colspan="2">
				<cellbytelabel>Invalidar toma del d&iacute;a <%=adm.getColValue("fhRegistro")%> (Registrado por <%=adm.getColValue("usrRegistro")%>)
				<br>Cuenta #<%=pacId%>-<%=admision%> - <%=adm.getColValue("paciente")%></cellbytelabel>
			</td>
		</tr>
		<tr align="center">
			<td colspan="2">
				<table align="center" width="80%" cellpadding="1" cellspacing="1">
					<tr class="TextPanel" align="center">
						<td>Signo Vital</td>
						<td>Valor</td>
						<td>&nbsp;</td>
						<td>Signo Vital</td>
						<td>Valor</td>
						<td>&nbsp;</td>
					</tr>
					<tr class="TextRow01">
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	if (i%2 == 0) {
%>
					</tr>
					<tr class="TextRow01">
<% } %>
						<td><%=cdo.getColValue("signoDesc")%></td>
						<td align="right"><%=cdo.getColValue("resultado")%></td>
						<td><%=cdo.getColValue("signoUnit")%></td>
<%
}
if (al.size()%2 != 0) {
%>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
<% } %>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center"><b>Comentario:</b>
			<%=fb.textarea("comment","",true,false,false,100,2,2000)%>
			</td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td colspan="2">
				<%=fb.submit("save","Invalidar",true,(!adm.getColValue("status").equalsIgnoreCase("A")),null,"","")%>
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
	sbSql = new StringBuffer();
	sbSql.append("update tbl_sal_signo_paciente z set status = 'I', inval_comment = ?, inval_by = ?, inval_date = sysdate where pac_id = ? and secuencia = ? and tipo_persona = ? and fecha = to_date(?,'dd/mm/yyyy') and hora = to_date(?,'dd/mm/yyyy hh12:mi:ss am') and status = 'A'");
	param.setSql(sbSql.toString());
	param.addInStringStmtParam(1,IBIZEscapeChars.forSingleQuots(request.getParameter("comment")));
	param.addInStringStmtParam(2,IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));
	param.addInNumberStmtParam(3,pacId);
	param.addInNumberStmtParam(4,admision);
	param.addInStringStmtParam(5,tipoPersona);
	param.addInStringStmtParam(6,fecha);
	param.addInStringStmtParam(7,fecha+" "+hora);

	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"pacId="+pacId+"&admision="+admision+"&tipoPersona="+tipoPersona+"&fecha="+fecha+"&hora="+hora);
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
top.window.location.reload(true);
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>