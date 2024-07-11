<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

int iconHeight = 40;
int iconWidth = 40;
CommonDataObject oData = new CommonDataObject();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbField = new StringBuffer();
StringBuffer sbTable = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String type = request.getParameter("type");
String owner = request.getParameter("owner");
String ckSample = request.getParameter("ckSample");
if (fp == null) fp = "";
if (type == null) type = "";
if (owner == null) owner = "";
if (ckSample == null) ckSample = "";
if (fp.trim().equals("")) throw new Exception("Origen inválido!");
if (type.trim().equals("")) throw new Exception("Tipo de Captura inválida!");

StringBuffer sbComm = new StringBuffer();
if (CmnMgr.isValidFpType(type)) {

	CommonDataObject cdo = SQLMgr.getData("select nvl(get_sec_comp_param(0,'SEC_APP_SERV_COMM_HOST'),' ') as appServCommHost from dual");
	if (cdo == null) {

		cdo = new CommonDataObject();
		cdo.addColValue("appServCommHost","");

	}

	if (cdo.getColValue("appServCommHost").trim().equals("") || cdo.getColValue("appServCommHost").equalsIgnoreCase("-")) {

		sbComm.append(request.getRequestURL().toString().replaceAll(request.getRequestURI(),""));
		sbComm.append(request.getContextPath());
		sbComm.append("/appServComm");

	} else sbComm.append(cdo.getColValue("appServCommHost"));
	cdo = null;
	if (sbComm.indexOf("/appServComm") == -1) throw new Exception("El Servicio de Comunicación no está definido!");

}
issi.admin.StringEncrypter se = new issi.admin.StringEncrypter();

String mode = request.getParameter("mode");
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){newHeight();/*ajaxHandler('<%=sbComm%>');*/}
function dataAcquiredHandler(){
	var appObj=document.getElementById("fpApp");
	<% if (fp.equalsIgnoreCase("user_list") || fp.equalsIgnoreCase("user") || fp.equalsIgnoreCase("patient") || fp.equalsIgnoreCase("employee")) { %>if(appObj.isTemplateValid()){if(parent.reloadOwner)parent.reloadOwner();if(parent.reloadOpener)parent.reloadOpener();if(appObj.getAlertMsg().trim()!='')alert(appObj.getAlertMsg());}
	<% } else if (fp.equalsIgnoreCase("admision_list")) { %>if(appObj.getUrlKey()!=null&&appObj.getUrlKey().trim()!=''){if(parent.reloadOwner)parent.reloadOwner(appObj.getUrlKey());}else if(appObj.isTemplateValid()){if(confirm('Para continuar con la admisión del paciente es necesario registrar la huella dactilar capturada. ¿Desea continuar?'))window.location='../common/search_paciente.jsp?fp=admFP';else parent.window.close();}
	<% } %>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td align="center">
		<object name="fpApp" id="fpApp" type="application/x-java-applet" width="100%" height="500">
			<param name="codebase" value="<%=request.getContextPath()%>/applet/"/>
			<param name="archive" value="issibio.jar"/>
			<param name="code" value="issi.applet.Capture"/>
			<param name="scriptable" value="true"/>
			<param name="mayscript" value="true"/>
			<param name="cache_option" value="yes"/>
			<param name="dLvl" value="6"/>
			<param name="onDataAcquired" value="dataAcquiredHandler"/>
			<param name="communicator" value="<%=sbComm%>"/>
			<param name="sessionId" value="<%=session.getId()%>"/>
			<param name="suser" value="<%=se.encrypt(UserDet.getUserName())%>"/>
			<param name="sip" value="<%=se.encrypt(request.getRemoteAddr())%>"/>
			<param name="type" value="<%=type%>"/>
			<param name="owner" value="<%=owner%>"/>
			<param name="ckSample" value="<%=ckSample%>"/>
			<br/><a href="<%=request.getContextPath()%>/applet/jre-6u30-windows-i586.exe">Descargar Java Plug-in</a>
		</object>
	</td>
</tr>
</table>
</body>
</html>