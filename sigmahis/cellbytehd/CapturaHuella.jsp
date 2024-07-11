<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject cdo = new CommonDataObject();

String desc = (request.getParameter("desc")==null?"Captura de Huellas Digitales":request.getParameter("desc"));
String userId = (request.getParameter("userId")==null?"":request.getParameter("userId"));
String mode = (request.getParameter("mode")==null?"add":request.getParameter("mode"));
String check = (request.getParameter("action")==null?"":request.getParameter("action"));
String fp = (request.getParameter("fp")==null?"":request.getParameter("fp"));
String tipo = (request.getParameter("tipo")==null?"":request.getParameter("tipo"));
String sql = ""; 
int rowCount = 0;

String dbDriver = "";
String dbUrl = "";
String dbUserName = "";
String dbPassword = "";
String redirUrl = "";
String alternativeUrl = "";
String sqlGetAll = "";
String savingUser = UserDet.getUserName();

//tipo = "EMP";
System.out.println(":::::::::::::::::::::::::::::"+tipo);

if (tipo.trim().equals("")) throw new Exception("No podemos encontrar un tipo!");

dbDriver = java.util.ResourceBundle.getBundle("connection").getString("db_driver");
dbUrl = java.util.ResourceBundle.getBundle("connection").getString("db_url");
dbUserName = java.util.ResourceBundle.getBundle("connection").getString("db_username");
dbPassword = java.util.ResourceBundle.getBundle("connection").getString("db_password");

if (!userId.equals("") && !userId.equals("0")){
   rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_adm_hd WHERE user_id = "+userId+" and tipo = '"+tipo+"'");
   if (rowCount > 0 ) mode = "edit";
   
   //para pacientes
   if (tipo.trim().equalsIgnoreCase("ADM")){
	 sql = "SELECT nombre_paciente user_name FROM VW_ADM_PACIENTE WHERE pac_id = "+userId;
   }else
   
   //emp
   if (tipo.trim().equalsIgnoreCase("EMP")){
	 sql = "select nombre_empleado,provincia, sigla, tomo, asiento from vw_pla_empleado where emp_id = "+userId;
   }else
   
   if (tipo.trim().equalsIgnoreCase("USR")){
      sql = "select usr.user_id, hd.huella  from tbl_sec_users usr, tbl_adm_hd hd where usr.user_id = hd.user_id and usr.user_status = 'A' and hd.tipo = 'USR' and hd.user_id ="+userId;
   }
   
   
 cdo = SQLMgr.getData(sql);  
}
if(check.equals("check")){mode = "edit";}
if (cdo == null ) cdo = new CommonDataObject();

if (tipo.trim().equalsIgnoreCase("ADM")){
	//para pacientes
	redirUrl = java.util.ResourceBundle.getBundle("hd").getString(""+tipo);
	
	alternativeUrl = java.util.ResourceBundle.getBundle("hd").getString("PAC");
	//alternativeUrl = alternativeUrl.replaceAll("@@fp",fp);
	sqlGetAll = "select p.pac_id user_id, p.nombre_paciente user_name, h.huella, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fn, p.edad||' A '||p.edad_mes||' M '||p.edad_dias||' D ' edad, p.sexo, decode(p.d_cedula,'D',p.id_paciente_fris,'R',p.id_paciente_fris,p.id_paciente) cedula from vw_adm_paciente p, tbl_adm_hd h where  p.pac_id = h.user_id and h.tipo = 'ADM'";
}else if (tipo.trim().equalsIgnoreCase("EMP")){
	//para empleados
	
	redirUrl = java.util.ResourceBundle.getBundle("hd").getString(""+tipo);
	//redirUrl = redirUrl.replaceAll("@@fp",fp);
	
    alternativeUrl = java.util.ResourceBundle.getBundle("hd").getString("EMPC");
	//alternativeUrl = alternativeUrl.replaceAll("@@fp",fp);

	sqlGetAll = "SELECT e.emp_id user_id, e.nombre_empleado user_name, h.huella FROM vw_pla_empleado e, tbl_adm_hd h WHERE  e.emp_id = h.user_id and h.tipo = 'EMP'";
	
}else if (tipo.trim().equalsIgnoreCase("USR")){
	//para USUARIOS (medicos)
	
	sqlGetAll = "select usr.user_id, hd.huella  from tbl_sec_users usr, tbl_adm_hd hd where usr.user_id = hd.user_id and usr.user_status = 'A' and hd.tipo = 'USR'";
	
}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="javascript">
function doAction(){
   includeHD();
}
 
function getNav(){
   var nav = navigator.appName;
   var res = "";
   if(nav=="Microsoft Internet Explorer"){
     res =  "ie";
   }else if (nav == "Netscape"){
     res = "ns";
   }else{res = "ot";}
   return res;
}

function includeHD(){
    
   var appletString = new String();
   
   // Microsoft familly
   if (getNav() == "ie"){

       appletString = '<object classid=clsid:8AD9C840-044E-11D1-B3E9-00805F499D93 ';
       appletString = appletString.concat('height="500" ',
		    'width="500" ',
		    'name="CellbyteHD" ',
		    'id="CellbyteHD" ',
		    'standby="Cargando el Lector..." ',
		    'codetype="application/x-java-applet">',
		    '<param name="code" value="issi.cellbytehd.CapturaHuella"/>',
		    '<param name="scriptable" value="true" />',
		    '<param name="mayscript" value = "true"/>',
		    '<param name="cache_option" value="yes">',
			'<param name="archive" value="CellbyteHD.jar"/>',
			'<param name="dbUrl" value ="<%=dbUrl%>" />',
			'<param name="dbDriver" value ="<%=dbDriver%>" />',
			'<param name="dbUserName" value ="<%=dbUserName%>" />',
			'<param name="dbPassword" value ="<%=dbPassword%>" />',
			"<param name='sqlGetAll' value=\"<%=sqlGetAll%>\"/>",
			"<param name='sessionId' value=\"<%=session.getId()%>\"/>",
			"<param name='tipo' value =\"<%=tipo%>\"/>",
			"<param name='fp' value =\"<%=fp%>\"/>",
			"<param name='userId' value =\"<%=userId%>\"/>",
			"<param name='check' value =\"<%=check%>\"/>",
			"<param name='mode' value =\"<%=mode%>\"/>",
			"<param name='redirUrl' value =\"<%=redirUrl%>\"/>",
			"<param name='alternativeUrl' value =\"<%=alternativeUrl%>\"/>",
			'<param name=\'userName\' value =\'<%=(cdo.getColValue("user_name")==null?"":cdo.getColValue("user_name"))%>\'/>',
			"<param name='savingUser' value =\"<%=savingUser%>\"/>",
			'<param name="debugMode" value="1" />',
			'<param name="killTheWindowScript" value="killTheWindowHandler"/>',
			'<param name="setWindowLocationScript" value="setWindowLocationHandler"/>',
			'<param name="showAlertIfVerified" value="1"/>',
			'<param name="msgToBeShown" value=" Huella Verificada, CCRR Puede ver los Datos del Paciente en la parte superior de esta ventana CCRR o puede crearle una admisíon"/>',
		    '</object>');
			
			//CR = Carriage return, CCRR will be replaced by \n
	   
   } else if (getNav() == "ns"){
      
        // Netscape familly (FF, Google Chrome)
        appletString = '<embed code="issi.cellbytehd.CapturaHuella" ';
        appletString = appletString.concat('name="CellbyteHD" ', 
		    'id="CellbyteHD" ',
		    'width="500" ',
		    'height="500" ',
		    'type="application/x-java-applet" ',
		    'archive="CellbyteHD.jar" ',
		    'priority="normal" ',
			'cache_option="yes"',
		    'scriptable="true" ',
		    'dbUrl="<%=dbUrl%>" ',
		    'dbDriver="<%=dbDriver%>" ',
		    'dbUserName="<%=dbUserName%>" ',
		    'dbPassword="<%=dbPassword%>" ',
		    "sqlGetAll =\"<%=sqlGetAll%>\" ",
		    "sessionId =\"<%=session.getId()%>\" ",
			"fp = \"<%=fp%>\" ",
			"tipo = \"<%=tipo%>\" ",
			"check = \"<%=check%>\" ",
			"userId = \"<%=userId%>\" ",
			"mode = \"<%=mode%>\" ",
			"redirUrl = \"<%=redirUrl%>\" ",
			"alternativeUrl = \"<%=alternativeUrl%>\" ",
			'userName=\"<%=(cdo.getColValue("user_name")==null?"":cdo.getColValue("user_name"))%>\"',
			"savingUser = \"<%=savingUser%>\" ",
			'debugMode="0"',
			'killTheWindowScript="killTheWindowHandler"',
			'setWindowLocationScript="setWindowLocationHandler"',
			'showAlertIfVerified="1"',
			'msgToBeShown="Huella Verificada, CCRR Puede ver los Datos del Paciente en la parte superior de esta ventana CCRR o puede crearle una admisíon"',
		    'mayscript="true"/>');
   }else{
      alert("You are using neither Microsoft nor Netscape browser Familly");
   }
   document.getElementById("HDholder").innerHTML = appletString;
}
function killTheWindowHandler(){
  window.parent.close();
}
function setWindowLocationHandler(){
    var appletObj = (getNav()=="ie"?document.applets["CellbyteHD"]:document.getElementById("CellbyteHD"));	
    var userId = appletObj.getPacId();
	document.getElementById("userId").value = userId;
	if (userId != "" && userId != "0"){
		window.location = "<%=request.getContextPath()+request.getServletPath()%>?action=<%=check%>&fp=<%=fp%>&tipo=<%=tipo%>&userId="+userId;	
	}
	if (userId == "0"){
	   //window.location = "<%=alternativeUrl+fp%>";
	   //abrir_ventana no te servira :D
	   window.open("<%=alternativeUrl+fp%>","Paciente","scrollbars=1");
	}
}
</script>
</head>
<body onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table width="100%" height="100%" border="0" rules="none" frame="box">
<%fb = new FormBean("formCapturaHuella",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("location","")%>
<%=fb.hidden("userId","")%>
<% if (!check.equals("")){%>
  <tr>
	<td>
	 <jsp:include page="../common/paciente_h_hd.jsp" flush="true">
	 <jsp:param name="pacienteId" value="<%=userId%>"></jsp:param>
	 <jsp:param name="action" value="<%=check%>"></jsp:param>
     </jsp:include>
	</td>
  </tr>
<% }%>
<tr>
	<td style="text-align:center;" class="TextRow02">
		<span id="HDholder"></span>
		<%if(check.equals("")){%>
		<br />
		<br />
		   <table width="500px">
		      <tr align="right">
		      	<td>
				   <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
				</td>
		      </tr>
		   </table>
		<%}%>
	</td>
</tr>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>