<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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

Hashtable ht = null;
CommonDataObject cdo = new CommonDataObject();

String mode = "";
String pacId = "";

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart")){
	ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("avatars"),20,true);
    
    mode = (String) ht.get("mode");
	pacId = (String) ht.get("pacId");
} else {
    mode = request.getParameter("mode");
 	pacId = request.getParameter("pacId");
}

boolean viewMode = false;
if (mode == null) mode = "edit";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")){

    try {
        cdo = SQLMgr.getData("select decode(avatar,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("avatars").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||avatar) as avatar from tbl_adm_paciente where pac_id = "+pacId);
        if (cdo == null) cdo = new CommonDataObject();
    } catch(Exception e) {
        cdo = new CommonDataObject();
        System.out.println("::::::::::::::::::::::::::::::::::::::::::::::: e "+e);
    }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script>
document.title = 'Expediente - '+document.title;

$(function(){
    $("#save").click(function(e){
        if (ValidateFileUpload()) $("#form0").submit()
    });
})

function ValidateFileUpload() {
    var $fileObj = $("#avatar");
    var file = $fileObj.val();
    var validExtensions = ['jpg','png','jpeg']; 
    
    if (!file) {
        alert('Por favor escoger la imagen del paciente.')
        return false
    }
    else {
        var ext = file.substring(file.lastIndexOf('.') + 1).toLowerCase();
        
        if ($.inArray(ext, validExtensions) == -1) {
            $fileObj.attr('src',"");
            alert("Solo imágenes con esas extensiones son aceptadas : "+validExtensions.join(', '));
            return false
        }
        
        return true
    }
    
    return false
}
</script>
</head>
<body style="margin: 0" class="TextRow01">


<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pacId",pacId)%>

<tr  class="TextPanel">
    <td colspan="2">avatar</td>
</tr>
<tr><td colspan="2">&nbsp;</td></tr>

<tr>
    <td>&nbsp;</td>
    <td>
        <%=fb.fileBox("avatar","",false,false,40,"","","")%><br>
        <%if(!cdo.getColValue("avatar"," ").trim().equals("")){%>
        <br>
        <div style="width:100px; height: 100px; background:url(<%=cdo.getColValue("avatar")%>) no-repeat 0 0; background-size:contain;">
        </div>
        <%}%>
    </td>
</tr>

<tr><td colspan="2">&nbsp;</td></tr>

<tr>
    <td>&nbsp;</td>
    <td>
        <%=fb.button("save","Guardar",true,viewMode,null,null,"")%>
    </td>
</tr>

<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%} else {

    String imagePath = (String)ht.get("avatar");
    imagePath = CmnMgr.cleanFile(imagePath);
    
    cdo = new CommonDataObject();
    cdo.setTableName("tbl_adm_paciente");
    cdo.setWhereClause("pac_id = "+pacId);
    cdo.addColValue("avatar",imagePath);
    
    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    SQLMgr.update(cdo);
    ConMgr.clearAppCtx(null);
%> 
<html>
<head>
<script>
function closeWindow(){
<%if (SQLMgr.getErrCode().equals("1")){%>
	alert('<%=SQLMgr.getErrMsg()%>');
    window.location = '<%=request.getContextPath()+request.getServletPath()%>?pacId=<%=pacId%>&mode=<%=mode%>';    
}
<%} else throw new Exception(SQLMgr.getErrMsg());%>    
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%}%>