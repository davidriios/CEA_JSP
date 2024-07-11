<%@ page errorPage="error.jsp"%>
<%@ page import="issi.admin.ConnectionMgr"%>
<%@ page import="issi.admin.FormBean2"%>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2"/>
<jsp:useBean id="CmnMgr" scope="session" class="issi.admin.CommonMgr"/>
<%

//variable de applicacion para acesso mobile, contexto y browser support}
String logoImage="css/bootstrap/img/_big_color.png";
String cssFile="custom_log.css";
String appCompLogoFile="images/lgc.png";
try {cssFile = java.util.ResourceBundle.getBundle("cellbyteFrontEnd").getString("css.file");}catch(Exception ex){cssFile = "custom_log.css";}
try {logoImage = java.util.ResourceBundle.getBundle("cellbyteFrontEnd").getString("login.logo.path");}catch(Exception ex){logoImage = "css/bootstrap/img/_big_color.png";}
try {appCompLogoFile = java.util.ResourceBundle.getBundle("cellbyteFrontEnd").getString("app.company.logo");}catch(Exception ex){appCompLogoFile = "images/lgc.png";}

ConnectionMgr ConMgr = new ConnectionMgr();
boolean isFpEnabled = CmnMgr.isValidFpType("USR");

issi.admin.StringEncrypter se = new issi.admin.StringEncrypter();

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Cellbyte Hospital Management Suite - User Login</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/font-awesome.min.css" type="text/css" />
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/<%=cssFile%>">
<link rel="icon" type="image/png" href="img/ico.png">
<script src="<%=request.getContextPath()%>/js/jquery.js"></script>
<script src="<%=request.getContextPath()%>/js/bowser.min.js"></script>
<script src="<%=request.getContextPath()%>/js/jquery_functions.js"></script>
<script src="<%=request.getContextPath()%>/js/global.js"></script>

<!-- Fingerprint -->
<script>
var fpOptions = {
  fpStatus: "#fpStatus",
  fpFormat: "compressed", //raw, intermediate, compressed, png,
  onCapture: onCapture,
  imgs: {
    connected: "<%=request.getContextPath()%>/images/fingerprint.png",
    disconnected: "<%=request.getContextPath()%>/images/uodisconnected.gif",
    invalid: "<%=request.getContextPath()%>/images/uoinvalid.gif",
    valid: "<%=request.getContextPath()%>/images/uogood.gif",
  }
};

function onCapture(fgdata) {
  var userName =  $.trim($("#user").val());
  //if (!userName) alert('Por favor ingrese su usuario del sistema.');
  //else {
    // ASYNC POST

    $.ajax({
      url: '<%=request.getContextPath()%>/FPComm',
      data: {
      userName: userName,
      jstr: encodeURI(fgdata.rawJson),
      sessionId: "<%=session.getId()%>",
      sip: "<%=se.encrypt(request.getRemoteAddr())%>",
      type: fgdata.type,
      "sampleFormat": fgdata.sampleFormat,
      "sampleData": fgdata.sampleData,
      "base64Data": fgdata.base64Data,
      },
      //processData: false,
      //contentType: false,
      type: 'POST'
    })
    .done(function(response) {
        // status: 200 -> the servlet  is happy, we proceed to log the user in
        console.log("response = ", response);
      })
      .fail(function(a,b,c) {
        // status: 500 -> fatal error, we're screewed.
        console.log("failed = ", a,b,c);
      })
      
  //}
}
</script>

<script src="<%=request.getContextPath()%>/js/fingerprint/sdk/es6-shim.js"></script>
<script src="<%=request.getContextPath()%>/js/fingerprint/sdk/websdk.client.bundle.min.js"></script>
<script src="<%=request.getContextPath()%>/js/fingerprint/sdk/fingerprint.sdk.min.js"></script>
<script src="<%=request.getContextPath()%>/js/fingerprint/fingerprint.js"></script>

</head>
<body class="custom-body">
<div class="container">
	<div class="col-md-12">
		<% if (isFpEnabled) { %><img id="fpStatus" name="fpStatus" src="<%=request.getContextPath()%>/images/fingerprint_10_48.png" border="0" width="48" height="48" align="left" alt="Haga clic para cargar el componente de entrada al sistema por medio de huella dactilar" style="cursor:pointer;"><span id="fpHolder"></span><% } %>
	</div>
</div>
</body>
</html>
<% } else {
// POST test??
  System.out.println("jstr = "+request.getParameter("jstr"));
  System.out.println("userName = "+request.getParameter("userName"));
  System.out.println("sip = "+request.getParameter("sip"));
  System.out.println("sessionId = "+request.getParameter("sessionId"));
  System.out.println("type = "+request.getParameter("type"));
  System.out.println("deviceUid = "+request.getParameter("deviceUid"));
} 
ConMgr = null;
%>