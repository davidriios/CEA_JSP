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
if (!CmnMgr.isValidFpType(type)) throw new Exception("El Tipo de Huella Dactilar no está habilitada. Por favor consulte con su administrador!");
if (type.trim().equals("")) throw new Exception("Tipo de Captura inválida!");

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
function doAction(){doResetFrameHeight();}
function doResetFrameHeight(){if(window.frames["ownerFrame"])window.frames["ownerFrame"].newHeight();if(window.frames["appletFrame"])window.frames["appletFrame"].newHeight();}
function getOwner(){var owner='<%=owner%>';if(owner=='')if(window.frames['ownerFrame'])owner=window.frames['ownerFrame'].document.ownerForm.owner.value;return owner;}
function doRecord(){var owner=getOwner();showPopWin('../common/run_process.jsp?fp=<%=fp%>&actType=3&docType=FP_<%=type%>&docId='+owner+'&docNo='+owner,winWidth*.75,winHeight*.65,null,null,'');}
function doRemove(){var owner=getOwner();showPopWin('../common/run_process.jsp?fp=<%=fp%>&actType=10&docType=FP_<%=type%>&docId='+owner+'&docNo='+owner,winWidth*.75,winHeight*.65,null,null,'');}
function doNext(){<% if (fp.startsWith("admision")) { %>newAdm();<% } %>}
function reloadPage(newOwner){if(newOwner==undefined||newOwner==null)window.location.reload(true); window.location='../biometric/capture_fingerprint.jsp?fp=<%=fp%>&type=<%=type%>&owner='+newOwner+'&ckSample=<%=ckSample%>';}
function reloadOpener(){top.window.opener.location.reload(true);}
function reloadOwner(newOwner){if(window.frames['ownerFrame'])if(newOwner==undefined||newOwner==null)window.frames['ownerFrame'].location.reload(true);else window.frames['ownerFrame'].location='../biometric/capture_fingerprint_owner.jsp?fp=<%=fp%>&type=<%=type%>&owner='+newOwner+'&ckSample=<%=ckSample%>';}
function reloadApplet(newOwner){if(window.frames['appletFrame'])if(newOwner==undefined||newOwner==null)window.frames['appletFrame'].location.reload(true);else window.frames['appletFrame'].location='../biometric/capture_fingerprint_applet.jsp?fp=<%=fp%>&type=<%=type%>&owner='+newOwner+'&ckSample=<%=ckSample%>';}
function newAdm(){
  var owner=getOwner();
  if(owner == '') {
    alert('Por favor coloque el dedo en el Lector de Huellas para verificar si está registrado y proceder con la Admisión!');
    return false;
  } else {
     var $ownerFrame = $("#ownerFrame");
     var $pending = $ownerFrame.contents().find("#pending-saldo");
   
     if ($pending.length) {
        var deuda = parseFloat($pending.data("saldo"));
        var nFactura = $pending.data("tot_fac");
        
        if (confirm('El Paciente tiene '+nFactura+' facturas, con saldo pendientes que ascienden a '+deuda.toFixed(2)+'\n'+'El paciente tiene deuda pendiente con la Clínica, ¿Desea continuar con la admisión bajo su responsabilidad?')) window.location='../admision/admision_config.jsp?fp=<%=fp%>&pacId='+owner;
     }
     else window.location='../admision/admision_config.jsp?fp=<%=fp%>&pacId='+owner; 
  } 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="HUELLA DIGITAL"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="y"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table width="100%" border="0">
<%// if (!owner.trim().equals("")) { %>
<tr align="center">
	<td class="TableBorder"><iframe name="ownerFrame" id="ownerFrame" frameborder="0" align="center" width="100%" height="0" scrolling="no" src="../biometric/capture_fingerprint_owner.jsp?mode=<%=mode%>&fp=<%=fp%>&type=<%=type%>&owner=<%=owner%>&ckSample=<%=ckSample%>"></iframe></td>
</tr>
<%// } %>
<tr>
	<td class="TableBorder"><iframe name="appletFrame" id="appletFrame" frameborder="0" align="center" width="100%" height="0" scrolling="no" src="../biometric/capture_fingerprint_applet.jsp?mode=<%=mode%>&fp=<%=fp%>&type=<%=type%>&owner=<%=owner%>&ckSample=<%=ckSample%>"></iframe></td>
</tr>
</table>
</body>
</html>