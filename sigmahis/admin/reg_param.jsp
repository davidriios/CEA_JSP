<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
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
String mode = request.getParameter("mode");
String param_name = request.getParameter("param_name");
String compId = request.getParameter("compId");

if (mode == null) mode = "add";
if (param_name == null) param_name = "";

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (!mode.equalsIgnoreCase("add")) {

		if (param_name.trim().equals("")) throw new Exception("El nombre del parámetro no es válido. Por favor intente nuevamente!");

		sbSql.append("select decode(b.compania,-1,'TODAS LAS COMPAÑIAS',(select a.nombre from tbl_sec_compania a where a.codigo = b.compania)) as companiaDesc, b.compania, b.param_name, b.param_value, b.param_desc, b.module from tbl_sec_comp_param b where b.compania = ");
		sbSql.append(compId);
		sbSql.append(" and param_name = '");
		sbSql.append(IBIZEscapeChars.forSingleQuots(param_name).trim());
		sbSql.append("'");
		cdo = SQLMgr.getData(sbSql.toString());

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Parametros - "+document.title;
function checkCode(obj,objOld){var compania=document.form0.compId.value;return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_sec_comp_param','compania in (-1,'+compania+') and param_name = \''+obj.value+'\'',objOld.value);}
function validCompany(obj,objOld){var paramName=document.form0.param_name.value;if(paramName.trim()=='')return false;else{return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_sec_comp_param','compania in ('+obj.value+') and param_name = \''+paramName+'\'',objOld);}}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PARAMETROS INICIALES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("oldCompId",cdo.getColValue("compania"))%>
		<%=fb.hidden("codigoOld",cdo.getColValue("param_name"))%>
		<%fb.appendJsValidation("if(validCompany(document.form0.compId,"+cdo.getColValue("compania")+"))error++;");%>
		<tr class="TextHeader">
			<td colspan="2" align="left"><cellbytelabel>PARAMETROS DE SISTEMA</cellbytelabel></td>
		</tr>
		<tr class="TextRow02">
			<td align="left"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
			<td align="left"><%=fb.select(ConMgr.getConnection(),"select -1 codigo, '-1 - TODAS LAS COMPAÑIAS' from dual union select a.codigo, a.codigo||' - '||a.nombre from tbl_sec_compania a where a.estado = 'A' order by 2","compId",cdo.getColValue("compania"),false,false,0,null,null,"onChange=\"javascript:validCompany(this,"+cdo.getColValue("compania")+")\"",null,null)%></td>
		</tr>
		<tr class="TextRow02">
			<td align="left"><cellbytelabel>M&oacute;dulo</cellbytelabel></td>
			<td align="left"><%=fb.select(ConMgr.getConnection(),"select id, name, id from tbl_sec_module where status='A' order by name","module",cdo.getColValue("module"),false,false,0,null,null,"",null,null)%>			
			</td>
		</tr>
		<tr class="TextRow01" >
			<td width="15%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="85%"><%=fb.textBox("param_name",cdo.getColValue("param_name"),true,false,(mode.trim().equals("add"))?false:true,55,50)%></td>
		</tr>
		<tr class="TextRow02" >
			<td><cellbytelabel>Valor</cellbytelabel></td>
			<td><%=fb.textBox("param_value",cdo.getColValue("param_value"),true,false,false,45,1000)%></td>
		</tr>
		<tr class="TextRow01" >
			<td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td><%=fb.textarea("param_desc",cdo.getColValue("param_desc"),false,false,false,100,4,200)%>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="2" align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_sec_comp_param");
	cdo.addColValue("param_value",request.getParameter("param_value"));
	cdo.addColValue("param_desc",request.getParameter("param_desc"));
	cdo.addColValue("module",request.getParameter("module"));

	if (request.getParameter("compId").trim().equals("")) compId = "-1";
	else compId = request.getParameter("compId");
	cdo.addColValue("compania",compId);

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if (mode.equalsIgnoreCase("add")) {
		SQLMgr.insert(cdo);
	} else {
		cdo.setWhereClause("param_name = '"+IBIZEscapeChars.forSingleQuots(request.getParameter("param_name"))+"' and compania = "+request.getParameter("oldCompId"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.opener.location.reload(true);
	window.close();
<% } else throw new Exception(SQLMgr.getErrMsg()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>