<%
String wTitle = "", icon = "", windowTitle="";
try { wTitle = (String) session.getAttribute("__wTitle"); } catch (Exception ex) {wTitle = ""; } finally { session.removeAttribute("__wTitle"); }
try { icon = java.util.ResourceBundle.getBundle("issi").getString("icon"); } catch (Exception ex) {icon = "ico.png"; }
try { windowTitle = java.util.ResourceBundle.getBundle("issi").getString("windowTitle"); } catch (Exception ex) {windowTitle = "CellByte - Hospital Management System"; }
if (wTitle == null) wTitle = "";
%>
<meta http-equiv="Content-Type" content="text/html; charset=<%=java.util.ResourceBundle.getBundle("issi").getString("charset")%>">
<title><%=wTitle.trim().equals("")?windowTitle:wTitle%></title>
<link rel="icon" href="<%=request.getContextPath()%>/images/<%=icon%>"/>
<!--
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/styles.css" type="text/css"/>-->
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/issix.css" type="text/css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/new_styles.css" type="text/css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/tooltip.css" type="text/css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/jquery.cleditor.css" type="text/css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/msgBoxLight.css" type="text/css"/>

<!--bootstrap-->
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/bootstrap.css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/font-awesome.min.css" type="text/css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/material-icons.css" type="text/css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/packages/webfont-medical-icons/wfmi-style.css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/jquery.smartmenus.bootstrap.css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/custom.css"/>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/default.css"/>

<!--script src="<%=request.getContextPath()%>/js/jquery.js"></script-->
<script src="<%=request.getContextPath()%>/css/bootstrap/js/jquery.min.js"></script>
<script src="<%=request.getContextPath()%>/js/jqueryui_1.10.3.js"></script>
<script src="<%=request.getContextPath()%>/js/bowser.min.js"></script>
<script src="<%=request.getContextPath()%>/js/global.js"></script>
<script src="<%=request.getContextPath()%>/js/sorttable.js"></script>
<script src="<%=request.getContextPath()%>/js/issix.js"></script>
<script src="<%=request.getContextPath()%>/js/aes.js"></script>
<script src="<%=request.getContextPath()%>/js/capslock.js"></script>
<script src="<%=request.getContextPath()%>/js/nicescroll.js"></script>
<script src="<%=request.getContextPath()%>/js/jquery.msgBox.js"></script>
<script src="<%=request.getContextPath()%>/js/jquery_functions.js"></script>
<script src="<%=request.getContextPath()%>/js/jquery.cleditor.js"></script>
<script src="<%=request.getContextPath()%>/js/jquery.cleditor.advancedtable.js"></script>
<link rel="stylesheet" href="<%=request.getContextPath()%>/js/themes/smotheness.css" type="text/css"/>
<script src="<%=request.getContextPath()%>/js/jquery-ui-timepicker-addon.js"></script>
<script src="<%=request.getContextPath()%>/js/jquery-ui-timepicker-es.js"></script>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/jquery-ui-timepicker-addon.min.css" type="text/css"/>
<!--bootstrap-->
<script src="<%=request.getContextPath()%>/css/bootstrap/js/bootstrap.js"></script>
<script src="<%=request.getContextPath()%>/css/bootstrap/js/jquery.smartmenus.js" type="text/javascript"></script>
<script src="<%=request.getContextPath()%>/css/bootstrap/js/jquery.smartmenus.bootstrap.js" type="text/javascript"></script>