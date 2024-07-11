<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<html>
<head>
<meta http-equiv="refresh" content="3">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/autocomplete_header.jsp"%>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap/css/bootstrap.css" type="text/css"/>
<script src="<%=request.getContextPath()%>/css/bootstrap/js/bootstrap.min.js"></script>
<script language="javascript">
function getData(){
$("#itemDetMonitor").html(window.opener.$("#left").html());
$("#totalMonitor").html(window.opener.$("#footer").html());
$("#subtotal_exe").val(window.opener.$("#subtotal_exe").val());
$("#descuento_exe").val(window.opener.$("#descuento_exe").val());
$("#subtotal_no_exe").val(window.opener.$("#subtotal_no_exe").val());
$("#descuento_no_exe").val(window.opener.$("#descuento_no_exe").val());
$("#itbm").val(window.opener.$("#itbm").val());
$("#total").val(window.opener.$("#total").val());
$("#pagoTotal").val(window.opener.$("#pagoTotal").val());
$("#porAplicar").val(window.opener.$("#porAplicar").val());
$(".btn").hide();
}
$(document).ready(function(){ getData();
});
</script>
</head>
<body>
<%fb = new FormBean("formMonitor",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<div style="width: 100%;" id="itemDetMonitor"></div>
<div style="width: 100%;" id="totalMonitor"></div>
<%=fb.formEnd(true)%>
</body>
</html>
