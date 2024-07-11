<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.MailMgr"%>
<%@ page import="issi.admin.XMLReader"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="xmlRdr" scope="page" class="issi.admin.XMLReader"/>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String curUserName = (String)session.getAttribute("_userName");
String curCompany = (String)session.getAttribute("_companyId");
String sel = request.getParameter("sel")==null?"":request.getParameter("sel");
String idRec = request.getParameter("idRec")==null?"":request.getParameter("idRec");
String cTime = request.getParameter("__ct");
String toAddress = request.getParameter("sendTo");
String subject = request.getParameter("subject");
String fileattach = request.getParameter("fileattach");
String message = request.getParameter("message");
String fromAddress = request.getParameter("fromAddress");
String filePathToBeSent = request.getParameter("filePathToBeSent")==null?"":request.getParameter("filePathToBeSent");
long lDateTime = new java.util.Date().getTime();

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (cds == null) cds = "";
if (toAddress == null) toAddress = "";
if (subject == null) subject = "";
if (message == null) message = "";
if (fromAddress == null) fromAddress = "";
if (fg == null) fg = "";
if (pacId == null) pacId = "-100";
if (noAdmision == null) noAdmision = "-100";
if (desc==null) desc = "ENVIAR ARCHIVOS POR CORREO A LA IMPRESORA";
if (fileattach == null) fileattach = "";
String tipo = "";


if (cds.equals("")){
	if (SecMgr.getParValue(UserDet,"cds") != null && !SecMgr.getParValue(UserDet,"cds").trim().equals("")) cds = SecMgr.getParValue(UserDet,"cds");
	else cds = "";
}

if (fg.trim().equals("RECETAS") && idRec.trim().equals("")) throw new Exception("No pudimos encontrar las recetas!");

if (fromAddress.trim().equals("")) {
	try{fromAddress=java.util.ResourceBundle.getBundle("issi_mail").getString("smtpfrom");}catch(Exception e){}
}
if (toAddress.trim().equals("")) {
	try{toAddress=java.util.ResourceBundle.getBundle("issi_mail").getString("printeremail");}catch(Exception e){}
}

if (fromAddress.trim().equals("")) throw new Exception("No podemos enviar el correo a direcciones vacías!");

if ( fg.equals("RECETAS") ){
	filePathToBeSent = "../expediente/exp_print_recetas_x_x_x.jsp?idRec="+idRec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&desc=&seccion=&toBeMailed=Y";
	tipo = "R";
	if (subject.trim().equals("")) subject = "RECETAS";
	if (message.trim().equals("")) message = "RECETAS";
}else
if ( fg.equals("PLAN_SALIDA") ){
	filePathToBeSent = "../expediente/print_datos_salida.jsp?tipoOrden=7&pacId="+pacId+"&noAdmision="+noAdmision+"&desc=&seccion=&toBeMailed=Y";
	tipo = "P";
	if (subject.trim().equals("")) subject = "PLAN DE SALIDA";
	if (message.trim().equals("")) message = "PLAN DE SALIDA";
}

if (request.getMethod().equalsIgnoreCase("GET")){
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<style type="text/css">
#loading{position:absolute;z-index:200;text-align:center;font-family:"Trebuchet MS", verdana, arial,tahoma;font-size:18pt;background: rgba(0,0,0,0.8);width: 100%;color:#fff;text-align:center;}
#content{z-index:201;display: block;left: 50%;margin-top: 120px;width: 100%;text-align:center;}
</style>
<script language="javascript">
window.history.forward();
document.title = 'ENVIAR ARCHIVOS POR CORREO '+document.title;

function getTdHeight(){
	 return Math.max(document.getElementById("container")["clientHeight"], document.getElementById("container")["scrollHeight"],document.documentElement["offsetHeight"]);
}

function doAction(){
	//emailToPrint();
}


$(document).ready(function(){
	 $("#send").click(function(e){
	 emailToPrint();
	 });

	 $("#cds").change(function(e){
		 window.location = "../common/email_to_printer.jsp?fg=<%=fg%>&idRec=<%=idRec%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds="+$(this).val();
	 });

});

function emailToPrint(){

		 var SUID = new Date().getTime() + 15*60*1000 + Math.floor(Math.random() * (1000000 - 1 + 1)) + 1;
		 var filePathToBeSent = "<%=filePathToBeSent%>&cTime="+SUID;
	 if (!filePathToBeSent){alert("")}
		 else if ( $.trim($("#fromAddress").val()) && $.trim($("#toAddress").val()) ){

			var tdH = getTdHeight() < 390 ? getTdHeight()+390: getTdHeight();
			$("#loading").height(tdH).show(0);

		var jqxhr = $.get(filePathToBeSent)
			.done(function(data) {
				 data = $.trim(data);
				 if (data) {
					 $("#fileattach").val(data);
					 setTimeout(function(){
							$("#form0").submit();
					},5000);
				 }
				 else alert("No podemos enviar un adjunto vacío!");
			})
			.fail(function( jqXHR, textStatus, errorThrown ) {
				alert("Encontramos este error: "+errorThrown);
			})
	 }else {alert("Por favor llenar todos los campos!")}

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td id="container">
				<table width="100%" cellpadding="1" cellspacing="1" >
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%=fb.formStart(true)%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("modeSec",modeSec)%>
				 <%=fb.hidden("seccion",seccion)%>
				 <%=fb.hidden("pacId",pacId)%>
				 <%=fb.hidden("noAdmision",noAdmision)%>
								 <%=fb.hidden("desc",""+desc)%>
								 <%=fb.hidden("size",""+al.size())%>
								 <%=fb.hidden("sel","")%>
								 <%=fb.hidden("cTime",cTime)%>
								 <%=fb.hidden("idRec",idRec)%>
								 <%=fb.hidden("message",message)%>
								 <%=fb.hidden("subject",subject)%>
				 <%=fb.hidden("fromAddress",fromAddress)%>
				 <%=fb.hidden("fileattach",fileattach)%>
				 <%=fb.hidden("fg",fg)%>
				<tr class="TextHeader">
					<td colspan="2">
						 <div id="loading" style="display:none;">
						<div id="content">&nbsp;Preparando la impresi&oacute;n....<br><img src="<%=request.getContextPath()%>/images/loading-bar2.gif"></div>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="2" >
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
							<td width="20%">Centro de Servicio:</td>
							<td width="90">
							<%=fb.select(ConMgr.getConnection(),"select distinct centro_servicio, (select descripcion from tbl_cds_centro_servicio where codigo = centro_servicio), tipo from tbl_email_to_printer where status = 'A' and tipo = '"+tipo+"' order by 2","cds",cds,false,false,0,"Text10",null,null,null,"S")%>
							</td>
							</tr>
							<tr class="TextRow01">
							<td width="20%">Impresora:</td>
							<td width="90">

							<%=fb.select(ConMgr.getConnection(),"select lower(email) email, descripcion from tbl_email_to_printer where status = 'A' and centro_Servicio = "+cds+" and tipo = '"+tipo+"'","toAddress",toAddress,false,false,0,"Text10",null,null,null,"")%>
							</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td colspan="2" align="right">
							<%=fb.button("send","Enviar",true,false,null,null,"")%>
					</td>
				</tr>
					<%=fb.formEnd(true)%>
				</table>


	</td>
</tr>
</table>

</body>
</html>
<%
}//GET
else
{
toAddress = request.getParameter("toAddress");
subject = request.getParameter("subject");
fileattach = request.getParameter("fileattach");
message = request.getParameter("message");
fromAddress = request.getParameter("fromAddress");
fg = request.getParameter("fg");

//Temporary hack due the poor implementation of MailMgr
// :( not working...
String mailHasBeenSent = "";
String failMsg = "";

try{
	MailMgr mm = new MailMgr();
	mm.sendMessageWithAttach(toAddress,subject,fileattach,message,fromAddress);
	mailHasBeenSent = "Y";
}catch(Exception e){
	failMsg = e.toString();
	mailHasBeenSent = "N";
}
%>
<html>
<head>
<script language="javascript">
	function closeWindow(){
		<%if (mailHasBeenSent.equals("Y") ){%>
			alert("El archivo ha sido enviado!");
		//parent.hidePopWin(false);
		<%if(fg.equals("RECETAS")){%>parent.window.close();<%}
		else if(fg.equals("PLAN_SALIDA")){%>parent.hidePopWin(false);<%}%>
		<%}else throw new Exception(failMsg); %>
	}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>