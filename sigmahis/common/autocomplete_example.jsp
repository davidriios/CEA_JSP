<% if (request.getMethod().equalsIgnoreCase("GET")) { %>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/autocomplete_header.jsp"%>
<script type='text/javascript' language="javascript">
function doSubmit(){document.form0.submit();}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">

<table width="100%" cellpadding="1" cellspacing="1" border="1">
<form name="form0" method="post">
<tr>
	<th width="33%">COL1</th>
	<th width="33%">COL2</th>
	<th width="33%">COL3</th>
</tr>
<tr align="center">
	<td>&nbsp;</td>
	<td>
		<jsp:include page="../common/autocomplete.jsp" flush="true">
			<jsp:param name="fieldId" value="inputField"/>
			<jsp:param name="fieldType" value="text"/>
			<jsp:param name="fieldIsRequired" value="y"/>
			<jsp:param name="fieldIsReadOnly" value="n"/>
			<jsp:param name="fieldClass" value="Text10"/>
			<jsp:param name="dObjId" value="document.form0.objId"/>
			<jsp:param name="dObjDescription" value="document.form0.objDescription"/>
			<jsp:param name="dObjRefer" value="document.form0.objRefer"/>
			<jsp:param name="containerSize" value="150%"/>
			<jsp:param name="containerFormat" value="@@description (@@id - @@refer)"/>
			<jsp:param name="containerOnSelect" value="doSubmit();"/>
			<jsp:param name="dsMatchBy" value="refer"/>
			<jsp:param name="dsQueryString" value="cds=127"/>
			<jsp:param name="dsType" value="drug"/>
		</jsp:include>
	</td>
	<td>
		<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1"/>
			<jsp:param name="clearOption" value="true"/>
			<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
			<jsp:param name="nameOfTBox1" value="fecha"/>
			<jsp:param name="valueOfTBox1" value=""/>
			<jsp:param name="fieldClass" value="Text10"/>
			<jsp:param name="buttonClass" value="Text10"/>
			<jsp:param name="resetFrameHeight" value="y"/>
		</jsp:include>
	</td>
</tr>
<tr align="center">
	<th>ID</td>
	<th>DESCRIPTION</td>
	<th>REFERENCE</td>
</tr>
<tr align="center">
	<td><input type="text" id="objId" value=""></td>
	<td><input type="text" id="objDescription" value=""></td>
	<td><input type="text" id="objRefer" value=""></td>
</tr>
</form>
</table>

</body>
</html>
<%
} else {
	System.out.println("inputField = "+request.getParameter("inputField"));
}
%>