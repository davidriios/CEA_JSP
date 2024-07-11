<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
String fileName=request.getParameter("fileName");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function changeLoc(val)
{
document.location=escape(val);
//replace(/[é]/gi,"%E9");
}
</script>
</head>
<body onLoad="javascript:changeLoc('<%=fileName%>')">
</body>
</html>
<%
//System.err.println("abrir_ventana                          "+fileName);
/*response.setCharacterEncoding("UTF-8"); 
response.setHeader("cache-control", "no-cache");
response.setDateHeader("max-age", 0);
response.setHeader("cache-control", "no-cache");
response.setHeader("Transfer-Encoding", "deflate");
//response.setHeader("Content-Encoding", "en-us");
response.setHeader("Connection", "keep-alive");
response.setHeader("Expires", "0");
response.setHeader("Vary", "Accept-Language,Accept-Encoding,User-Agent");
response.sendRedirect(fileName);*/

%>