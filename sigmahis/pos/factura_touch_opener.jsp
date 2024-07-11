<%@ page errorPage="../error.jsp"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);

String cds = request.getParameter("cds")==null?"":request.getParameter("cds");
String almacen = request.getParameter("almacen")==null?"":request.getParameter("almacen");
String familia = request.getParameter("familia")==null?"":request.getParameter("familia");
String tipoPos = request.getParameter("tipo_pos")==null?"":request.getParameter("tipo_pos");
String tipo    = request.getParameter("tipo")==null?"":request.getParameter("tipo");
String artType = request.getParameter("artType")==null?"":request.getParameter("artType");
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_min.jsp"%>
<title>POS Touch</title>
</head>
<body>
<script>
window.open('../pos/facturar_touch_frame.jsp?cds=<%=cds%>&almacen=<%=almacen%>&familia=<%=familia%>&tipo_pos=<%=tipoPos%>&tipo=<%=tipo%>&artType=<%=artType%>');
</script>
<h1>Por favor no cerrar esa p&aacute;gina mientras usa el POS.</h1>
</body>
</html>