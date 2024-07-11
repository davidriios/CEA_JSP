<%@ page errorPage="error.jsp"%>
<%@ page import="issi.admin.ConnectionMgr"%>
<%@ page import="issi.admin.FormBean2"%>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2"/>
<jsp:useBean id="CmnMgr" scope="session" class="issi.admin.CommonMgr"/>
<%
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
String multiLang = "n", supportedBrowser="",contextType="",showMobile="";
try {multiLang = java.util.ResourceBundle.getBundle("issi").getString("multi.lang");}catch(Exception ex){multiLang = "n";}
try {supportedBrowser = java.util.ResourceBundle.getBundle("issi").getString("browser.support");}catch(Exception ex){supportedBrowser ="'ie':[7,9], 'ff':[20,26], 'gc':[17,27]";}
try {contextType=java.util.ResourceBundle.getBundle("issi").getString("app.access");}catch (Exception ex){contextType="W";}
try {showMobile=java.util.ResourceBundle.getBundle("issi").getString("app.mobileaccess");}catch(Exception ex){showMobile = "y";}

String ua=request.getHeader("User-Agent").toLowerCase();
if(showMobile.equalsIgnoreCase("Y")){
if(ua.matches("(?i).*((android|bb\\d+|meego).+mobile|avantgo|bada\\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino).*")||ua.substring(0,4).matches("(?i)1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\\-(n|u)|c55\\/|capi|ccwa|cdm\\-|cell|chtm|cldc|cmd\\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\\-s|devi|dica|dmob|do(c|p)o|ds(12|\\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\\-|_)|g1 u|g560|gene|gf\\-5|g\\-mo|go(\\.w|od)|gr(ad|un)|haie|hcit|hd\\-(m|p|t)|hei\\-|hi(pt|ta)|hp( i|ip)|hs\\-c|ht(c(\\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\\-(20|go|ma)|i230|iac( |\\-|\\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\\/)|klon|kpt |kwc\\-|kyo(c|k)|le(no|xi)|lg( g|\\/(k|l|u)|50|54|\\-[a-w])|libw|lynx|m1\\-w|m3ga|m50\\/|ma(te|ui|xo)|mc(01|21|ca)|m\\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\\-2|po(ck|rt|se)|prox|psio|pt\\-g|qa\\-a|qc(07|12|21|32|60|\\-[2-7]|i\\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\\-|oo|p\\-)|sdk\\/|se(c(\\-|0|1)|47|mc|nd|ri)|sgh\\-|shar|sie(\\-|m)|sk\\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\\-|v\\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\\-|tdg\\-|tel(i|m)|tim\\-|t\\-mo|to(pl|sh)|ts(70|m\\-|m3|m5)|tx\\-9|up(\\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\\-|your|zeto|zte\\-")) {
	response.sendRedirect("mobile/index.jsp");
	return;
}}
issi.admin.ISSILogger.setSession(session);
String msg = request.getParameter("msg");
if (msg == null) msg = "";
ConnectionMgr ConMgr = new ConnectionMgr();
boolean isFpEnabled = CmnMgr.isValidFpType("USR");
boolean isUserRequired = false;
StringBuffer sbComm = new StringBuffer();
if (isFpEnabled) {

	try { isUserRequired = java.util.ResourceBundle.getBundle("fingerprint").getString("usr.login.refer.required").equalsIgnoreCase("y"); } catch (Exception ex) {}

	issi.admin.SQLMgr sqlMgr = new issi.admin.SQLMgr(ConMgr);
	issi.admin.CommonDataObject cdo = sqlMgr.getData("select nvl(get_sec_comp_param(0,'SEC_APP_SERV_COMM_HOST'),' ') as appServCommHost from dual");
	if (cdo == null) {

		cdo = new issi.admin.CommonDataObject();
		cdo.addColValue("appServCommHost","");

	}

	if (cdo.getColValue("appServCommHost").trim().equals("") || cdo.getColValue("appServCommHost").equalsIgnoreCase("-")) {

		sbComm.append(request.getRequestURL().toString().replaceAll(request.getRequestURI(),""));
		sbComm.append(request.getContextPath());
		sbComm.append("/appServComm");
		if (cdo.getColValue("appServCommHost").equalsIgnoreCase("-")) msg += "\\nPar�metro del Servidor de Comunicaci�n no est� definido!";

	} else sbComm.append(cdo.getColValue("appServCommHost"));
	cdo = null;
	if (sbComm.indexOf("/appServComm") == -1) msg += "\\nEl Servicio de Comunicaci�n no est� definido!";

}
issi.admin.StringEncrypter se = new issi.admin.StringEncrypter();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Sigma HIS - User Login</title>
<link rel="stylesheet" href="css/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" href="css/bootstrap/css/font-awesome.min.css" type="text/css" />
<link rel="stylesheet" href="css/bootstrap/css/<%=cssFile%>">
<link rel="icon" type="image/png" href="images/ico.png">
<script src="<%=request.getContextPath()%>/js/jquery.js"></script>
<script src="<%=request.getContextPath()%>/js/bowser.min.js"></script>
<script src="<%=request.getContextPath()%>/js/jquery_functions.js"></script>
<script src="<%=request.getContextPath()%>/js/global.js"></script>
<script language="javascript">
var supportedBrowser = {<%=supportedBrowser%>}; // global variable used by jquery_functions.isAValidBrowser()
function doAction(){document.form0.user.focus();maximizeWin();}
function triggerAccederOnEnter(theEvent){ if ( theEvent.keyCode === 13 && document.getElementById('acceder') ) document.getElementById('acceder').click(); }
<% if (isFpEnabled) { %>
function dataAcquiredHandler(){var appObj=document.getElementById("fpApp");document.fpStatus.src='<%=request.getContextPath()%>/images/datacaptured.gif';document.fpStatus.alt='';var userName=appObj.getRefer();if(<%=isUserRequired%>&&(userName==null||userName.trim()=='')){alert('Por favor ingrese su usuario antes de colocar el dedo en el lector!');fingerGoneHandler();}else{var token=appObj.getUrlToken();if(token==null||token.trim()==''){document.fpStatus.src='<%=request.getContextPath()%>/images/uoinvalid.gif';document.fpStatus.alt='Huella dactilar desconocida!';alert('La Huella Dactilar no est� registrada. Por favor consulte con su Administrador!');fingerGoneHandler();}else{document.fpStatus.src='<%=request.getContextPath()%>/images/uogood.gif';document.fpStatus.alt='Huella dactilar reconocida!';var formAction=document.form0.action;document.form0.action=formAction+((formAction.indexOf('?')==-1)?'?':'&')+'token='+token;document.form0.submit();}}}
function fingerTouchedHandler(){/*user set AFTER clicking on the button*/var appObj=document.getElementById("fpApp");appObj.setRefer(document.form0.user.value);appObj.setWat(ajaxHandler('./wat.jsp',null,'POST'));document.fpStatus.src="<%=request.getContextPath()%>/images/touched.gif";document.fpStatus.alt='';}
function fingerGoneHandler(){document.fpStatus.src="<%=request.getContextPath()%>/images/waiting.gif";document.fpStatus.alt='Por favor coloque el dedo registrado sobre el lector!';}
function readerConnectedHandler(){/*user set BEFORE clicking on the button*/var appObj=document.getElementById("fpApp");appObj.setRefer(document.form0.user.value);appObj.setWat(ajaxHandler('./wat.jsp',null,'POST'));document.fpStatus.src="<%=request.getContextPath()%>/images/waiting.gif";document.fpStatus.alt='Por favor coloque el dedo registrado sobre el lector!';}
function readerDisconnectedHandler(){document.fpStatus.src="<%=request.getContextPath()%>/images/uodisconnected.gif";document.fpStatus.alt='El lector est� desconectado!';}
function startCapturerHandler(){document.fpStatus.src="<%=request.getContextPath()%>/images/uodisconnected.gif";document.fpStatus.alt='El Lector no est� instalado!';}
function loadFP(){/*ajaxHandler('<%=sbComm%>');*/loadFP=Function('');/*overwrite this function, so it will be executed only once*/
document.fpStatus.src='<%=request.getContextPath()%>/images/fingerprint-wait.png';
document.fpStatus.alt='Cargando componente de entrada por medio de huella dactilar...';
document.fpStatus.style.cursor='';
var aStr=new String();
aStr+='<object name="fpApp" id="fpApp" type="application/x-java-applet" width="0" height="0">';
aStr+='<param name="codebase" value="<%=request.getContextPath()%>/applet/"/>';
aStr+='<param name="archive" value="issibio.jar"/>';
aStr+='<param name="code" value="issi.applet.Login"/>';
aStr+='<param name="scriptable" value="true"/>';
aStr+='<param name="mayscript" value="true"/>';
aStr+='<param name="cache_option" value="yes"/>';
aStr+='<param name="dLvl" value="6"/>';
aStr+='<param name="onDataAcquired" value="dataAcquiredHandler"/>';
aStr+='<param name="onReaderConnected" value="readerConnectedHandler"/>';
aStr+='<param name="onReaderDisconnected" value="readerDisconnectedHandler"/>';
aStr+='<param name="onFingerTouched" value="fingerTouchedHandler"/>';
aStr+='<param name="onFingerGone" value="fingerGoneHandler"/>';
aStr+='<param name="onStartCapturer" value="startCapturerHandler"/>';
aStr+='<param name="communicator" value="<%=sbComm%>"/>';
aStr+='<param name="sessionId" value="<%=session.getId()%>"/>';
aStr+='<param name="sip" value="<%=se.encrypt(request.getRemoteAddr())%>"/>';
aStr+='<param name="method" value="match"/>';
aStr+='<br/><a href="<%=request.getContextPath()%>/applet/jre-6u30-windows-i586.exe">Descargar Java Plug-in</a>';
aStr+='</object>';
displayElementValue('fpHolder',aStr);
}
<% } %>
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
				<div class="panel-body">
					<div>
						<div class="input-group input-group-md">
							<span class="input-group-addon"><i class="fa fa-user"></i></span>
							<%=fb.textBox("user","",false,false,false,0,0,"form-control",null,null,null,false," autofocus placeholder=\"Usuario\"",null)%>
						</div><br>
						<div class="input-group input-group-md">
							<span class="input-group-addon"><i class="fa fa-lock"></i></span>
							<%=fb.passwordBox("pass","",false,false,false,0,0,"form-control",null,"onKeyUp=\"triggerAccederOnEnter(event)\" ",null," placeholder=\"Contrase&ntilde;a\"",null)%>
						</div><br>
						<div>
							<% if (isFpEnabled) { %><img id="fpStatus" name="fpStatus" src="<%=request.getContextPath()%>/images/fingerprint.png" border="0" width="48" height="48" align="left" alt="Haga clic para cargar el componente de entrada al sistema por medio de huella dactilar" style="cursor:pointer;" onClick="javascript:loadFP();"><span id="fpHolder"></span><% } %>
							<%=fb.submit("acceder","Acceder",true,false,"btn btn-primary btn-md pull-right|fa fa-sign-in",null,null)%>
						</div>
					</div>
				</div>
<%=fb.formEnd()%>
			</div>
			<h4>Sigma HIS 2.0</h4><br>Sistema dise&ntilde;ado para una resoluci&oacute;n de 1024x768 o superior.<br><i class="fa fa-copyright"></i> <%=java.util.ResourceBundle.getBundle("issi").getString("copyrights")%>
		</div>
		<div class="col-xs-3"></div>
	</div>
</div>
<%
ConMgr.close();
if (!msg.trim().equals("")) {
%>
<script language="javascript">/*blinkId('msgBlock','red','white');*/alert('<%=msg%>');</script>
<% } %>
</body>
</html>
