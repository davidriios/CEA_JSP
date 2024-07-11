<%
/*
Ejemplo de uso:

	Para busqueda con rango de fecha:
	<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2" />
		<jsp:param name="nameOfTBox1" value="fromDate" />
	<jsp:param name="nameOfTBox2" value="toDate" />
	</jsp:include>

	Para busqueda de una fecha especifica:
	<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="nameOfTBox1" value="fromDate" />
	</jsp:include>
*/
String noOfDateTBox = request.getParameter("noOfDateTBox");
String nameOfTBox1 = request.getParameter("nameOfTBox1");
String nameOfTBox2 = request.getParameter("nameOfTBox2");
String valueOfTBox1 = request.getParameter("valueOfTBox1");
String valueOfTBox2 = request.getParameter("valueOfTBox2");
String clearOption = request.getParameter("clearOption");
String jsEvent = request.getParameter("jsEvent");  // Valido para cuando noOfDateTBox = 1
String format = request.getParameter("format");
String fieldClass = request.getParameter("fieldClass");
String buttonClass = request.getParameter("buttonClass");
String appendOnClickEvt = request.getParameter("appendOnClickEvt");
String onChange = request.getParameter("onChange");
String disabled = request.getParameter("disabled");
String readonly = request.getParameter("readonly");
String appendOnFocus = request.getParameter("appendOnFocus");
String resetFrameHeight = request.getParameter("resetFrameHeight");
String fromLbl = request.getParameter("fromLbl");
String toLbl = request.getParameter("toLbl");
String hintPos = request.getParameter("hintPos"); //left, top, right, bottom
String hintText = request.getParameter("hintText"); //left, top, right, bottom
String noTabIndex = "";
if (noOfDateTBox == null) noOfDateTBox = "0";
if (nameOfTBox1 == null) nameOfTBox1 = "";
if (nameOfTBox2 == null) nameOfTBox2 = "";
if (valueOfTBox1 == null) valueOfTBox1 = "";
if (valueOfTBox2 == null) valueOfTBox2 = "";
if (clearOption == null) clearOption = "false";
if (jsEvent == null) jsEvent = "";
if (format == null) format = "dd/mm/yyyy";
if (fieldClass == null) fieldClass = "";
if (buttonClass == null) buttonClass = "";
if (appendOnClickEvt == null) appendOnClickEvt = "";
if (onChange == null) onChange = "";
if (disabled == null) disabled = "n";
if (readonly == null) readonly = "n";
if (appendOnFocus == null) appendOnFocus = "";
if (resetFrameHeight == null) resetFrameHeight = "";
if (fromLbl == null) fromLbl = "Desde";
if (toLbl == null) toLbl ="Hasta";
if (hintPos == null) hintPos = "top";
if (hintText == null) hintText = "01/01/2014";

if (disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))
{
	fieldClass = "FormDataObjectDisabled " + fieldClass;
	clearOption = "false";
	noTabIndex = " tabindex=\"-1\" ";
}
if (resetFrameHeight.equalsIgnoreCase("y"))resetFrameHeight=",true";
else resetFrameHeight="";

// refer to calendar.js (function Date.prototype.print)
int objSize = 0;
String jsFormat = format;
String dateFormat = "false";
String timeFormat = "false";
String eventos1 = "";
String eventos2 = "";
String lbFormat = "";
String ejFormat = "";
if (jsFormat.contains("dd") || jsFormat.contains("mm") || jsFormat.contains("yyyy"))
{
	objSize = 10;
	dateFormat = "true";
	jsFormat = jsFormat.replaceAll("dd","%d");
	jsFormat = jsFormat.replaceAll("mm","%m");
	jsFormat = jsFormat.replaceAll("yyyy","%Y");
	lbFormat = "dd/mm/yyyy";
	ejFormat = "31/12/2008";
	if (disabled.trim().equalsIgnoreCase("n") && readonly.trim().equalsIgnoreCase("n"))
	{
		eventos1 = "onfocus=\"javascript:"+appendOnFocus+"showHideDateFormat('labelDateFormat_"+nameOfTBox1+"','','"+lbFormat+"','"+ejFormat+"'"+resetFrameHeight+")\" onblur=\"javascript:if(this.value.trim()==''||isValidateDate(this.value,'"+format+"'))showHideDateFormat('labelDateFormat_"+nameOfTBox1+"','none',null,null"+resetFrameHeight+");else setTimeout('document.getElementById(\\\'"+nameOfTBox1+"\\\').focus();',0);\" onkeyup=\"javascript:checkDateFormat('"+nameOfTBox1+"',event)\"";
		eventos2 = "onfocus=\"javascript:"+appendOnFocus+"showHideDateFormat('labelDateFormat_"+nameOfTBox2+"','','"+lbFormat+"','"+ejFormat+"'"+resetFrameHeight+")\" onblur=\"javascript:if(this.value.trim()==''||isValidateDate(this.value,'"+format+"'))showHideDateFormat('labelDateFormat_"+nameOfTBox2+"','none',null,null"+resetFrameHeight+");else setTimeout('document.getElementById(\\\'"+nameOfTBox2+"\\\').focus();',0);\" onkeyup=\"javascript:checkDateFormat('"+nameOfTBox2+"',event)\"";
	}
}

if (jsFormat.contains("hh"))
{
	objSize += 9;
	timeFormat = "'24'";
	if (!lbFormat.trim().equals(""))
	{
		lbFormat += " ";
		ejFormat += " ";
	}
	if (jsFormat.contains("hh24"))
	{
		jsFormat = jsFormat.replaceAll("hh24","%H");
		lbFormat += "hh";
		ejFormat += "14";
	}
	else if (jsFormat.contains("hh12"))
	{
		lbFormat += "hh";
		ejFormat += "10";
	}
	if (jsFormat.contains("mi"))
	{
		jsFormat = jsFormat.replaceAll("mi","%M");
		lbFormat += ":mm";
		ejFormat+=":05";
	}
	if (jsFormat.contains("ss"))
	{
		jsFormat = jsFormat.replaceAll("ss","%S");
		lbFormat += ":ss";
		ejFormat+=":20";
	}
	if (jsFormat.contains("hh12"))
	{
		objSize += 3;
		timeFormat = "'12'";
		jsFormat = jsFormat.replaceAll("hh12","%I");
		if (jsFormat.contains(".")) jsFormat = jsFormat.replace(".","");
		if (jsFormat.contains("am"))
		{
			jsFormat = jsFormat.replaceAll("am","%P");
			lbFormat += " am";
			ejFormat += " am";
		}
		else if (jsFormat.contains("pm"))
		{
			jsFormat = jsFormat.replaceAll("pm","%P");
			lbFormat += " pm";
			ejFormat += " pm";
		}
		else jsFormat += " %P";
	}
	if (disabled.trim().equalsIgnoreCase("n") && readonly.trim().equalsIgnoreCase("n"))
	{
		eventos1 = "onfocus=\"javascript:"+appendOnFocus+"showHideDateFormat('labelDateFormat_"+nameOfTBox1+"','','"+lbFormat+"','"+ejFormat+"'"+resetFrameHeight+")\" onblur=\"javascript:if(this.value.trim()==''||isValidateDate(this.value,'"+format+"'))showHideDateFormat('labelDateFormat_"+nameOfTBox1+"','none',null,null"+resetFrameHeight+");else setTimeout('document.getElementById(\\\'"+nameOfTBox1+"\\\').focus();',0);\"";
		if (jsFormat.contains("dd") || jsFormat.contains("mm") || jsFormat.contains("yyyy")) eventos1 = " onkeyup=\"javascript:checkDateFormat('"+nameOfTBox1+"',event)\"";
		eventos2 = "onfocus=\"javascript:"+appendOnFocus+"showHideDateFormat('labelDateFormat_"+nameOfTBox2+"','','"+lbFormat+"','"+ejFormat+"'"+resetFrameHeight+")\" onblur=\"javascript:if(this.value.trim()==''||isValidateDate(this.value,'"+format+"'))showHideDateFormat('labelDateFormat_"+nameOfTBox2+"','none',null,null"+resetFrameHeight+");else setTimeout('document.getElementById(\\\'"+nameOfTBox2+"\\\').focus();',0);\"";
		if (jsFormat.contains("dd") || jsFormat.contains("mm") || jsFormat.contains("yyyy")) eventos1 = " onkeyup=\"javascript:checkDateFormat('"+nameOfTBox2+"',event)\"";
	}
}

if (noOfDateTBox.equals("1"))
{
%>
<span <%=(disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))?"":" title='' class='hint hint--"+hintPos+"' data-hint='Ejemplo: "+hintText+"'"%>>
<input type="text" <%=noTabIndex%> name="<%=nameOfTBox1%>" value="<%=valueOfTBox1.trim()%>"<%=(objSize == 0)?"":" size=\""+objSize+"\" maxLength=\""+objSize+"\""%> id="<%=nameOfTBox1%>"<%=(clearOption.equalsIgnoreCase("true"))?" ondblclick=\"javascript:this.value=''\"":""%><%=(fieldClass.equals(""))?"":" class=\""+fieldClass+"\""%> <%=eventos1%> onchange="<%=onChange%>"<%=(disabled.trim().equalsIgnoreCase("y"))?" disabled":((readonly.trim().equalsIgnoreCase("y"))?" readonly":"")%>>
<input type="reset" tabindex="-1" name="reset<%=nameOfTBox1%>" id="reset<%=nameOfTBox1%>" value="..." onclick="javascript:<%=appendOnClickEvt%>return showCalendar('<%=nameOfTBox1%>', '<%=jsFormat%>', <%=dateFormat%>, <%=timeFormat%>, false,'<%=jsEvent%>');"<%=(buttonClass.equals(""))?" class=\"CellbyteBtn\"":" class=\""+buttonClass+"\""%><%=(disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))?" disabled":""%>>
<label id="labelDateFormat_<%=nameOfTBox1%>" style="display:none; color:#FF0000"></label></span>
<%
}
else if (noOfDateTBox.equals("2"))
{
	if (nameOfTBox1.equals(nameOfTBox2)) throw new Exception("Nombre del objeto de fecha duplicado!");
	else
	{
%>
<cellbytelabel><%=fromLbl%></cellbytelabel>
<span <%=(disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))?"":" title='' class='hint hint--"+hintPos+"' data-hint='Ejemplo: "+hintText+"'"%>>
<input type="text"  <%=noTabIndex%>  name="<%=nameOfTBox1%>" value="<%=valueOfTBox1.trim()%>"<%=(objSize == 0)?"":" size=\""+objSize+"\" maxLength=\""+objSize+"\""%> id="<%=nameOfTBox1%>"<%=(clearOption.equalsIgnoreCase("true"))?" ondblclick=\"javascript:this.value=''\"":""%><%=(fieldClass.equals(""))?"":" class=\""+fieldClass+"\""%> <%=eventos1%> onchange="<%=onChange%>"<%=(disabled.trim().equalsIgnoreCase("y"))?" disabled":((readonly.trim().equalsIgnoreCase("y"))?" readonly":"")%>>
<input type="reset" tabindex="-1" name="reset<%=nameOfTBox1%>" id="reset<%=nameOfTBox1%>" value="..." onclick="javascript:<%=appendOnClickEvt%>return showCalendar('<%=nameOfTBox1%>', '<%=jsFormat%>', <%=dateFormat%>, <%=timeFormat%>);"<%=(buttonClass.equals(""))?" class=\"CellbyteBtn\"":" class=\""+buttonClass+"\""%><%=(disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))?" disabled":""%>></span>
<cellbytelabel><%=toLbl%></cellbytelabel>
<span <%=(disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))?"":" title='' class='hint hint--"+hintPos+"' data-hint='Ejemplo: "+hintText+"'"%>>
<input type="text" <%=noTabIndex%> name="<%=nameOfTBox2%>" value="<%=valueOfTBox2.trim()%>"<%=(objSize == 0)?"":" size=\""+objSize+"\" maxLength=\""+objSize+"\""%> id="<%=nameOfTBox2%>"<%=(clearOption.equalsIgnoreCase("true"))?" ondblclick=\"javascript:this.value=''\"":""%><%=(fieldClass.equals(""))?"":" class=\""+fieldClass+"\""%> <%=eventos2%> onchange="<%=onChange%>"<%=(disabled.trim().equalsIgnoreCase("y"))?" disabled":((readonly.trim().equalsIgnoreCase("y"))?" readonly":"")%>>
<input type="reset" tabindex="-1" name="reset<%=nameOfTBox2%>" id="reset<%=nameOfTBox2%>" value="..." onclick="javascript:<%=appendOnClickEvt%>return showCalendar('<%=nameOfTBox2%>', '<%=jsFormat%>', <%=dateFormat%>, <%=timeFormat%>);"<%=(buttonClass.equals(""))?" class=\"CellbyteBtn\"":" class=\""+buttonClass+"\""%><%=(disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))?" disabled":""%>></span>
<label id="labelDateFormat_<%=nameOfTBox1%>" style="display:none; color:#FF0000"></label>
<label id="labelDateFormat_<%=nameOfTBox2%>" style="display:none; color:#FF0000"></label>
<%
	}
}
%>