<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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

StringBuffer sbSql = new StringBuffer();
String compania = request.getParameter("compania");
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String paquete = request.getParameter("paquete");
if (compania == null || compania.trim().equals("")) throw new Exception("Compañía no definida!");
if (pacId == null || pacId.trim().equals("") || admision == null || admision.trim().equals("")) throw new Exception("Cuenta de Paciente no válida!");
if (paquete == null || paquete.trim().equals("")) {//throw new Exception("Paquete no definido!");

	sbSql.append("select z.cod_reg as paq_id, (select nombre from tbl_fac_cotizacion where id = z.cod_reg) as paq_name from tbl_adm_clasif_x_plan_conv z where paquete = 'S' and exists (select null from tbl_adm_beneficios_x_admision where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and admision = ");
	sbSql.append(admision);
	sbSql.append(" and prioridad = 1 and estado = 'A' and empresa = z.empresa and convenio = z.convenio and plan = z.plan and categoria_admi = z.categoria_admi and tipo_admi = z.tipo_admi and clasif_admi = z.clasif_admi)");

} else if (!paquete.equals("-1")) {

	sbSql.append("select id as paq_id, nombre as paq_name from tbl_fac_cotizacion z where z.id = ");
	sbSql.append(paquete);

} else {

	sbSql.append("select -1 as paq_id, 'DESVINCULAR PAQUETE' as paq_name from dual");

}
CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
if (cdo == null) cdo = new CommonDataObject();
paquete = cdo.getColValue("paq_id",paquete);
if (paquete == null || paquete.trim().equals("")) throw new Exception("Paquete no definido!");

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'FACTURACION - '+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RELACIONAR CARGOS A PAQUETES"></jsp:param>
</jsp:include>
<table align="center" width="80%" cellpadding="5" cellspacing="1" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("paquete",paquete)%>
		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel><% if (paquete.equals("-1")) { %>Limpiar<% } else { %>Relacionar<% } %> cargos a paquete</cellbytelabel> (<%=cdo.getColValue("paq_id","")%> - <%=cdo.getColValue("paq_name","PAQUETE INVALIDO!")%>)</td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td colspan="2">
				<%=fb.submit("save","Guardar",true,(cdo.getColValue("paq_id","").trim().equals("")),null,"","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
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
	sbSql.append("call sp_fac_paquete(?,?,?,?)");
	param.setSql(sbSql.toString());
	param.addInNumberStmtParam(1,compania);
	param.addInNumberStmtParam(2,pacId);
	param.addInNumberStmtParam(3,admision);
	param.addInNumberStmtParam(4,paquete);

	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"compania="+compania+"&pacId="+pacId+"&admision="+admision+"&paquete="+paquete);
	param = SQLMgr.executeCallable(param);
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