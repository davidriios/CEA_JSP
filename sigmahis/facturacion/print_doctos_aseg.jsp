<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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

SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
StringBuffer sbURL = new StringBuffer();
StringBuffer sbQS = new StringBuffer();
String fp = request.getParameter("fp");
String es_axa = request.getParameter("es_axa");
String listId = request.getParameter("listId");  

if (fp != null) { sbQS.append("&fp="); sbQS.append(fp); }
if (listId != null) { sbQS.append("&listId="); sbQS.append(listId); } 

sbURL.append(request.getContextPath());
  

	if (es_axa.equalsIgnoreCase("S")) sbURL.append("/facturacion/print_doctos_axa.jsp");
	else sbURL.append("/facturacion/documentos_aseg.jsp");
 

if (sbQS.length() != 0) { sbURL.append("?"); sbURL.append(sbQS.substring(1)); }

System.out.println("................."+sbURL);
response.sendRedirect(sbURL.toString());
%>