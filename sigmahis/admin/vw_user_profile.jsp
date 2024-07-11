<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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

ArrayList al = new ArrayList();
CommonDataObject cdo = null;
StringBuffer sbSql = new StringBuffer();
String id = request.getParameter("id");

if (id == null) throw new Exception("El Perfil no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql = new StringBuffer();
	sbSql.append("select profile_name, profile_desc, profile_status, module_id from tbl_sec_profiles where profile_id = ");
	sbSql.append(id);
	cdo = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select (select user_name from tbl_sec_users where user_id = a.user_id) as user_name, (select name from tbl_sec_users where user_id = a.user_id) as name, (select user_status from tbl_sec_users where user_id = a.user_id) as status from tbl_sec_user_profile a where a.profile_id = ");
	sbSql.append(id);
	sbSql.append(" order by 2,1");
	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Usuarios - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - PERFIL - USUARIOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
<tr class="TextHeader">
	<td colspan="2" align="center">PERFIL: <%=cdo.getColValue("profile_name")%></td>
</tr>
</table>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.GET);%>
<%=fb.formStart(true)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("size",""+al.size())%>
		<tr>
			<td colspan="4" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<%=al.size()%> &nbsp; <cellbytelabel>U S U A R I O S</cellbytelabel> &nbsp; <cellbytelabel>A S I G N A D O S</cellbytelabel> &nbsp; ( <label class="RedText"><cellbytelabel>I N A C T I V O S</cellbytelabel></label> )</td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel1">
			<td colspan="4">
				<table width="100%" cellpadding="1" cellspacing="1">
<% if (al.size() == 0) { %>
				<tr class="TextRow01">
					<td align="center"><cellbytelabel>N O</cellbytelabel> &nbsp; <cellbytelabel>T I E N E</cellbytelabel> &nbsp; <cellbytelabel>U S U A R I O S</cellbytelabel> &nbsp; <cellbytelabel>A S I G N A D O S</cellbytelabel></td>
				</tr>
<% } %>
<%
int iCounter = 0;
int iRow = 3;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject u = (CommonDataObject) al.get(i);
	if (iCounter == 0)
	{
%>
				<tr class="TextRow01">
<%
	}
%>
					<td width="10%" align="right"><label<%=(u.getColValue("status").equalsIgnoreCase("A"))?"":" class=\"RedText\""%>>[ <%=u.getColValue("user_name")%> ]</label></td>
					<td width="23.33%"><label<%=(u.getColValue("status").equalsIgnoreCase("A"))?"":" class=\"RedText\""%>><%=u.getColValue("name")%></label></td>
<%
	iCounter++;
	if (iCounter == iRow)
	{
%>
				</tr>
<%
		iCounter = 0;
	}
}
if (iCounter != 0 && iRow - iCounter > 0)
{
	for (int i=0; i < (iRow - iCounter); i++)
	{
%>
					<td width="10%">&nbsp;</td>
					<td width="23.33%">&nbsp;</td>
<%
	}
%>
				</tr>
<%
}
%>

				</table>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
}//GET
%>