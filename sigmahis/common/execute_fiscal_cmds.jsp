<%@ page import="issi.admin.IFClient"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.service.HTTPClientHandler"%>
<%@ page import="issi.admin.IFRestClient"%>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<%
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
String cmd="";
boolean cmdStatus=false;
String msg="OK";
String service="";
if(request.getParameter("f_command")!=null) cmd = request.getParameter("f_command");
if(request.getParameter("service")!=null) service = request.getParameter("service");
/*IFClient printDGI = new IFClient(request.getRemoteHost(), 3232);
if(printDGI.checkPrinter()){
			String statusCode1 ="",statusCodeFinal ="";
			boolean closeCmdFlag = false;
			if(!cmd.equals("")) cmdStatus=printDGI.sendBatchCmd(cmd.trim());;
			if(!cmdStatus) msg = printDGI.getLastErrMsg();
			else msg="Operacion Fallo!";
	}*/ //old ifserver
//New IfServer
				IFRestClient printDGI = new IFRestClient();
				HTTPClientHandler httpClient=new HTTPClientHandler();
		
				String ip = (SecMgr.getParValue(UserDet,"DGI")!=null? SecMgr.getParValue(UserDet,"DGI"):"");
				String url="http://"+(!ip.equals("")? ip:request.getRemoteHost());
				String urlDgi="";
				if (service != null && !service.trim().equals("")) urlDgi=url+"/ifserver/ifserver.php?service="+service;
				else urlDgi=url+"/ifserver/ifserver.php?service=PRINTFDOC&docType=FAC&sendCommands="+IBIZEscapeChars.forURL(cmd.trim());
				issi.admin.ISSILogger.info("dgi",urlDgi);
				msg = httpClient.getHttpResponse(urlDgi);
				if(request.getParameter("ajax")!=null) {out.println(msg.trim()); return;}
				//msg=responseText;
				
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Ejecutar Proceso - '+document.title;
function closeWindow(){parent.hidePopWin(false);}
setTimeout(closeWindow(),500);
</script>
</head>
<body >
<div>
Command Open CashDrawer<br>
<%=msg%>
</div>
</body>
</html>
<%
printDGI=null;
%>