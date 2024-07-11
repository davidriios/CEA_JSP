<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ResourceBundle"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");
String reportName = (request.getParameter("reportName") == null?"":request.getParameter("reportName"));
String compImgPath = ResourceBundle.getBundle("path").getString("companyimages").replace(ResourceBundle.getBundle("path").getString("root"),"");

if (reportName.trim().equals("")) throw new Exception("El Nombre del Reporte no es válido. Por favor consulte con su Administrador!");
StringBuffer sbQS = new StringBuffer();
java.util.Vector vQS = CmnMgr.str2vector(request.getQueryString(),"&");
if (vQS.contains("reportName")) vQS.remove("reportName");
if (vQS.contains("__report")) vQS.remove("__report");
if (vQS.contains("userNameParam")) vQS.remove("userNameParam");
if (vQS.contains("compIdParam")) vQS.remove("compIdParam");
if (vQS.contains("appCtxParam")) vQS.remove("appCtxParam");
if (vQS.contains("compImgPathParam")) vQS.remove("compImgPathParam");
for (int i=0; i<vQS.size(); i++) {
	sbQS.append("&");
	sbQS.append(vQS.get(i));
}
%>
<html>
<head>
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-STORE">
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
<META HTTP-EQUIV="EXPIRES" CONTENT="01 Jan 1970 00:00:00 GMT">
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<%//@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){//resetBodySize();var height=parent._contentHeight;if(window.name=='report_container'){height=top._bodyHeight-25;document.getElementById('footerDiv').style.display='';}setHeight('viewerCtx',height);
setTimeout('iframeSrc()',50);}
function iframeSrc(){document.getElementById('viewerCtx').src='<%=request.getContextPath()+"RptVW/"%>frameset?__report=<%=reportName%>&userNameParam=<%=userName%>&compIdParam=<%=compania%>&compImgPathParam=<%=compImgPath%><%=sbQS%>';}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" cellspacing="0" cellpadding="0">
<tr>
	<td><iframe id="viewerCtx" name="viewerCtx" src="" width="100%" height="500"></iframe></td>
</tr>
</table>
<div id="footerDiv" style="display:none;"><%@ include file="../common/footer.jsp"%></div>
</body>
</html>
