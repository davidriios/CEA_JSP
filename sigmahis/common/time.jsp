<%
/*
Ejemplo de uso:

	Para busqueda con rango de fecha:
	<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfTimeTBox" value="2" />
		<jsp:param name="nameOfTBox1" value="fromDate" />
	<jsp:param name="nameOfTBox2" value="toDate" />
	</jsp:include>

	Para busqueda de una fecha especifica:
	<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfTimeTBox" value="1" />
		<jsp:param name="nameOfTBox1" value="fromDate" />
	</jsp:include>
*/
String noOfTimeTBox = request.getParameter("noOfTimeTBox");
String nameOfTBox1 = request.getParameter("nameOfTBox1");
String nameOfTBox2 = request.getParameter("nameOfTBox2");
String valueOfTBox1 = request.getParameter("valueOfTBox1");
String valueOfTBox2 = request.getParameter("valueOfTBox2");
String clearOption = request.getParameter("clearOption");
String jsEvent = request.getParameter("jsEvent");  // Valido para cuando noOfTimeTBox = 1
if (noOfTimeTBox == null) noOfTimeTBox = "0";
if (nameOfTBox1 == null) nameOfTBox1 = "";
if (nameOfTBox2 == null) nameOfTBox2 = "";
if (valueOfTBox1 == null) valueOfTBox1 = "";
if (valueOfTBox2 == null) valueOfTBox2 = "";
if (clearOption == null) clearOption = "false";
if (jsEvent == null) jsEvent = "";
if (noOfTimeTBox.equals("1"))
{
%>
<input type="text" name="<%=nameOfTBox1%>" value="<%=valueOfTBox1%>" size="3" id="<%=nameOfTBox1%>" class="FieldDate" readonly="True"<%=(clearOption.equalsIgnoreCase("true"))?" ondblclick=\"javascript:this.value=''\"":""%>>
<input type="reset" value=" ... " onclick="return showCalendar('<%=nameOfTBox1%>', '%H:%M', 'true', false,'<%=jsEvent%>');" class="FieldDate">
<%
}
else if (noOfTimeTBox.equals("2"))
{
%>
<cellbytelabel>Desde</cellbytelabel>
<input type="text" name="<%=nameOfTBox1%>" value="<%=valueOfTBox1%>" size="3" class="Field01" id="<%=nameOfTBox1%>" readonly="True"<%=(clearOption.equalsIgnoreCase("true"))?" ondblclick=\"javascript:this.value=''\"":""%>>
<input type="reset" value=" ... " onclick="return showCalendar('<%=nameOfTBox1%>', '%H:%M');">
<cellbytelabel>Hasta</cellbytelabel>
<input type="text" name="<%=nameOfTBox2%>" value="<%=valueOfTBox2%>" size="3" class="Field01" id="<%=nameOfTBox2%>" readonly="True"<%=(clearOption.equalsIgnoreCase("true"))?" ondblclick=\"javascript:this.value=''\"":""%>>
<input type="reset" value=" ... " onclick="return showCalendar('<%=nameOfTBox2%>', '%H:%M');">
<%
}
%>


