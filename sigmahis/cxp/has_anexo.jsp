<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="iAnexo" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<%
SQLMgr.setConnection(ConMgr);
String fp = request.getParameter("fp");
if (fp == null) fp = "";
StringBuffer sbSql = new StringBuffer();
StringBuffer sbURL = new StringBuffer();
sbSql.append("select lower(nvl(get_sec_comp_param(-1,'CXP_ANEXO_CHECK_FILE'),'/cxp/print_cheque_anexo.jsp')) as chk_file from dual");
CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
if (cdo == null) sbURL.append("/cxp/print_cheque_anexo.jsp");
else sbURL.append(cdo.getColValue("chk_file"));
%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function closeWindow(){<% if (iAnexo.size() > 0) { %>abrir_ventana1('..<%=sbURL.toString()%>?fp=<%=fp%>');<% } %>}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
