<%@ page errorPage="error.jsp"%>
<%@ page import="issi.admin.FormBean2"%>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2"/>
<%
String msg = request.getParameter("msg");
String mrn = request.getParameter("mrn");
String token = request.getParameter("token");
String tstamp = request.getParameter("tstamp");
if (msg == null) msg = "";
if (mrn == null) mrn = "";
if (token == null) token = "";
if (tstamp == tstamp) tstamp = "";

System.out.println("mrn = "+mrn+" token = "+token+" tstamp = "+tstamp);
if (mrn.trim().equals("") || token.trim().equals("")) throw new Exception("Record Médico o Token no válido. Por favor intente nuevamente!");

/*if (session.isNew()) {
	application.log("New Session Created Its OK "+session.getId());
} else {
	application.log("Session Already Created "+session.getId());
	session.invalidate();
	session = request.getSession(true);
}*/
if (SecMgr.checkLogin(session.getId())) {
	issi.admin.UserDetail ud = SecMgr.getUserDetails(session.getId());
	if (!ud.getUserProfile().contains("0") && SecMgr.showPasswordChange(ud)) {
		response.sendRedirect(request.getContextPath()+"/admin/user_preferences.jsp?fp=newpass&tab=1");
		return;
	} else {
		response.sendRedirect(request.getContextPath()+"/main.jsp");
		return;
	}
}

//variable de applicacion para acesso mobile, contexto y browser support}
String logoImage="css/bootstrap/img/_big_color.png";
String cssFile="custom_log.css";
try {cssFile = java.util.ResourceBundle.getBundle("cellbyteFrontEnd").getString("css.file");}catch(Exception ex){cssFile = "custom_log.css";}
try {logoImage = java.util.ResourceBundle.getBundle("cellbyteFrontEnd").getString("login.logo.path");}catch(Exception ex){logoImage = "css/bootstrap/img/_big_color.png";}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Cellbyte Hospital Management Suite - External Login</title>
<link rel="stylesheet" href="css/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" href="css/bootstrap/css/font-awesome.min.css" type="text/css" />
<link rel="stylesheet" href="css/bootstrap/css/<%=cssFile%>">
<link rel="icon" type="image/png" href="img/ico.png">
<script src="<%=request.getContextPath()%>/js/jquery.js"></script>
<script src="<%=request.getContextPath()%>/js/bowser.min.js"></script>
<script src="<%=request.getContextPath()%>/js/jquery_functions.js"></script>
<script src="<%=request.getContextPath()%>/js/global.js"></script>
<script language="javascript">
function doAction(){document.form0.user.focus();maximizeWin();}
</script>
</head>
<body class="custom-body">
<div class="container">
	<div class="col-md-12">
		<div class="col-xs-3"></div>
		<div class="col-md-6 col-sm-6">
			<div class="panel">
				<div class="panel-header"><img src="<%=logoImage%>" alt="Logo of the company" class="logo"> </img></div>
				<div class="divider"></div>
<%fb = new FormBean2("form0",request.getContextPath()+"/login.jsp",FormBean2.POST);%>
<%=fb.formStart()%>
<%=fb.hidden("furl","external")%>
<%=fb.hidden("mrn",mrn)%>
<%=fb.hidden("token",token)%>
<%=fb.hidden("tstamp",tstamp)%>
				<div class="panel-body">
					<div>
						<div class="input-group input-group-md">
							<span class="input-group-addon"><i class="fa fa-user"></i></span>
							<%=fb.textBox("user","",false,false,false,0,0,"form-control",null,null,null,false," autofocus placeholder=\"Usuario\"",null)%>
						</div><br>
						<div class="input-group input-group-md">
							<span class="input-group-addon"><i class="fa fa-lock"></i></span>
							<%=fb.passwordBox("pass","",false,false,false,0,0,"form-control",null,null,null," placeholder=\"Contrase&ntilde;a\"",null)%>
						</div><br>
						<div>
							<%=fb.submit("acceder","Acceder",true,false,"btn btn-primary btn-md pull-right|fa fa-sign-in",null,null)%>
						</div>
					</div>
				</div>
<%=fb.formEnd()%>
			</div>
			<h4>CellByte Hospital Management Suite 2.0</h4><br>Sistema dise&ntilde;ado para una resoluci&oacute;n de 1024x768 o superior.<br><i class="fa fa-copyright"></i> <%=java.util.ResourceBundle.getBundle("issi").getString("copyrights")%>
		</div>
		<div class="col-xs-3"></div>
	</div>
</div>
<%
if (!msg.trim().equals("")) {
%>
<script language="javascript">/*blinkId('msgBlock','red','white');*/alert('<%=msg%>');</script>
<% } %>
</body>
</html>


