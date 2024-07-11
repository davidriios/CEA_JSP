<html>
<head>
<title>Login Redirection</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="javascript">
function redirect(URLStr) { location = URLStr; }
</script>
</head>
<body onLoad="javascript:redirect('<%=request.getContextPath()%>/index.jsp')">
</body>
</html>
