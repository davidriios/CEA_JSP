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
==============================================================================
==============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String pacId = request.getParameter("pacId");
String admision = request.getParameter("noAdmision");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (fp.equalsIgnoreCase("expediente"))
{
	if (pacId == null || admision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
	sbFilter.append(" and a.display_area in ('A','X') and b.pac_id=");
	sbFilter.append(pacId);
	sbFilter.append(" and b.admision=");
	sbFilter.append(admision);
}
sbSql.append("select a.id, a.description, decode(a.display_area,'P','PACIENTE','X','EXPEDIENTE','A','ADMISION','H','RECURSOS HUMANOS','C','CONTABILIDAD','O','GERENCIA DE OPERACIONES','G','GERENCIA GENERAL',a.display_area) as display_area, (50 + a.id) as authtype from tbl_sec_doc_type a, tbl_adm_admision_doc b where a.id=b.doc_type and a.status='A'");
sbSql.append(sbFilter);
sbSql.append("order by 3, 2");
al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){newHeight();}
function viewDoc(id){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="DOCUMENTOS"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="y"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="5" cellspacing="0">
<tr class="TextRow01 TextHeader">
	<td>
<%
String groupBy = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	if (!groupBy.equalsIgnoreCase(cdo.getColValue("display_area")))
	{
		if (i != 0)
		{
%>
		</ul>
		</dl>
<%
		}
%>
		<dl>
		<dt><cellbytelabel>DOCUMENTOS DE</cellbytelabel> <%=cdo.getColValue("display_area")%>
		<dd>
		<ul>
<%
	}
%>
			<authtype type='<%=cdo.getColValue("authtype")%>'><li><a href="javascript:viewDoc(<%=cdo.getColValue("id")%>)" class="Link00Bold"><%=cdo.getColValue("description")%></a></li></authtype>
<%
	if (i == al.size() - 1)
	{
%>
		</ul>
		</dl>
<%
	}
	groupBy = cdo.getColValue("display_area");
}
%>
		</ul>
	</td>
</tr>
</table>
</body>
</html>