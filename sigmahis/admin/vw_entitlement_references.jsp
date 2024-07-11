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
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
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
StringBuffer sbSql;
String id = request.getParameter("id");
String refer = request.getParameter("refer");
String referDesc = "";
if (id == null) id = "";
if (refer == null) refer = "";
if (id.trim().equals("")) throw new Exception("El Proceso no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql = new StringBuffer();
	sbSql.append("select process_id, module_id, name from tbl_sec_process where process_id = ");
	sbSql.append(id);
	cdo = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();
	if (refer.equalsIgnoreCase("profile"))
	{
		referDesc = "P E R F I L E S";
		sbSql.append("select z.profile_id as id, (select profile_name from tbl_sec_profiles where profile_id = z.profile_id) as name, (select profile_status from tbl_sec_profiles where profile_id = z.profile_id) as status from tbl_sec_profile_entitlements z where z.entitlement_code = to_number(");
		sbSql.append(cdo.getColValue("module_id"));
		sbSql.append("||lpad(");
		sbSql.append(id);
		sbSql.append(",4,'0')||'00') order by 2");
	}
	else if (refer.equalsIgnoreCase("page"))
	{
		referDesc = "P A G I N A S";
		sbSql.append("select z.page_id as id, (select name||decode(qs,null,\'\',\'?\'||qs) from tbl_sec_pages where id=z.page_id) as name, (select status from tbl_sec_pages where id=z.page_id) as status from tbl_sec_page_entitlement z where z.entitlement_code = to_number(");
		sbSql.append(cdo.getColValue("module_id"));
		sbSql.append("||lpad(");
		sbSql.append(id);
		sbSql.append(",4,'0')||'00') order by 2");
	}
	if (sbSql.length() > 0)	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Mantenimiento de Proceso - '+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - PROCESO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("id",id)%>
		<tr class="TextRow02">
			<td colspan="4" align="center">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="10%" align="right"><cellbytelabel>M&oacute;dulo</cellbytelabel></td>
			<td width="30%"><%=fb.select(ConMgr.getConnection(),"select id, to_char(id,'09')||' - '||name, id from tbl_sec_module order by name","module_id",cdo.getColValue("module_id"),false,true,0,null,null,null,"S","")%></td>
			<td width="10%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="50%"><%=fb.textBox("name",cdo.getColValue("name"),true,false,true,70,49)%></td>
		</tr>
<% if (!refer.trim().equals("")) { %>
		<tr>
			<td colspan="4" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<%=al.size()%> &nbsp; <%=referDesc%> &nbsp; <cellbytelabel>A S I G N A D @ S</cellbytelabel> &nbsp; ( <label class="RedText"><%=referDesc%> &nbsp; <cellbytelabel>I N A C T I V @ S</cellbytelabel></label> )</td>
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
					<td align="center"><cellbytelabel>N O</cellbytelabel> &nbsp; <cellbytelabel>T I E N E</cellbytelabel> &nbsp; <%=referDesc%> &nbsp; <cellbytelabel>A S I G N A D @ S</cellbytelabel></td>
				</tr>
<% } %>
<%
int iCounter = 0;
int iRow = 3;
for (int i=0; i<al.size(); i++)
{
  CommonDataObject p = (CommonDataObject) al.get(i);
  if (iCounter == 0)
  {
%>
				<tr class="TextRow01">
<%
	}
%>
					<td width="33.33%"><label<%=(p.getColValue("status").equalsIgnoreCase("A"))?"":" class=\"RedText\""%>>[<%=p.getColValue("id")%>] <%=p.getColValue("name")%></label></td>
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
					<td width="33.33%">&nbsp;</td>
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
<% } %>
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