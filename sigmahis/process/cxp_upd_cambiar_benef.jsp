<%@ page errorPage="../error.jsp"%>
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
String anio = request.getParameter("anio");
String op = request.getParameter("op");

if (request.getMethod().equalsIgnoreCase("GET")) {

	sbSql.append("select num_id_beneficiario as codigo,nvl(nom_beneficiario,' ') as beneficiario2,substr(nvl(nom_beneficiario,' '),1,instr(nvl(nom_beneficiario,' '),' ')) as benef from tbl_cxp_orden_de_pago where anio = ");
	sbSql.append(anio);
	sbSql.append(" and num_orden_pago = ");
	sbSql.append(op);
	sbSql.append(" and cod_compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'CXP - '+document.title;
function addProv(nombre)
{
   abrir_ventana1('../common/search_proveedor.jsp?fp=csop&nombre='+nombre);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="Cambiar Beneficiario"></jsp:param>
</jsp:include>
<table align="center" width="80%" cellpadding="5" cellspacing="1" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("op",op)%>
<%=fb.hidden("dv","")%>
<%=fb.hidden("ruc","")%>
<%=fb.hidden("tipoPersona","")%> 
		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel>Beneficiario Actual</cellbytelabel></td>
		</tr>
		<tr class="TextHeader01">
			<td width="15%"><%=fb.textBox("ref_id_old",cdo.getColValue("codigo"),true,true,false,10,10,"Text10",null,null)%></td>
			<td width="85%"><%=fb.textBox("beneficiario2",cdo.getColValue("beneficiario2"),true,false,false,100,100,"Text10",null,null)%></td>
		</tr>
		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel>Nuevo Beneficiario</cellbytelabel></td>
		</tr>
		<tr class="TextHeader01">
			<td><%=fb.textBox("ref_id","",true,false,true,10,10,"Text10",null,null)%></td>
			<td><%=fb.textBox("nombre","",true,false,true,100,100,"Text10",null,null)%>
			<%=fb.button("buscarProv","...",false, false,"Text10","","onClick=\"javascript:addProv('"+cdo.getColValue("benef")+"')\"")%></td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td colspan="2"><%=fb.submit("save","Cambiar",true,false,null,"","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
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

	String baction = request.getParameter("baction");
	
	sbSql.append("call sp_cxp_upd_datos_op(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", ");
	sbSql.append(anio);
	sbSql.append(", ");
	sbSql.append(op);
	sbSql.append(", ");
	sbSql.append(request.getParameter("ref_id"));
	sbSql.append(", '");
	sbSql.append(request.getParameter("ruc"));
	sbSql.append("', '");
	sbSql.append(request.getParameter("dv"));
	sbSql.append("', '");
	sbSql.append(request.getParameter("nombre"));
	sbSql.append("', '");
	sbSql.append(request.getParameter("tipoPersona"));
	sbSql.append("', '");
	sbSql.append((String) session.getAttribute("_userName")); 
	sbSql.append("')"); 
	
	
	if (baction.equalsIgnoreCase("Cambiar")) {

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		SQLMgr.execute(sbSql.toString());
		ConMgr.clearAppCtx(null);

	}
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