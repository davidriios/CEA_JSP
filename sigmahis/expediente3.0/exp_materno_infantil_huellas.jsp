<%// @ page errorPage="../error.jsp"%>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String docId = "";
if (fg == null) fg = "";
String docsFor = "";

if (fg.trim().equalsIgnoreCase("MI")) {
    docId = "41";
    docsFor = "huellas_materno_infantil";
} else if (fg.trim().equalsIgnoreCase("IO")) {
    docId = "42";
    docsFor = "informe_oficial";
}
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<script>
var noNewHeight = true;
$(function(){
    $('iframe').iFrameResize({
        log: false
    });
});
</script>
</head>
<body class = "body-form">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
    <iframe id="doc_esc" name="doc_esc" width="100%" scrolling="yes" frameborder="0" src="../expediente3.0/exp_documentos.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&exp=3&expStatus=<%=request.getParameter("estado")!=null?request.getParameter("estado"):""%>&area_revision=SL&docs_for=<%=docsFor%>&docId=<%=docId%>&fg=<%=fg%>"></iframe>
</div>
</div>
</body>
</html>