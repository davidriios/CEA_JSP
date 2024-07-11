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
String _jqui = request.getParameter("jqui"); //jquery ui with input time
String tformat = request.getParameter("tformat"); //jquery ui with input time
String dformat = request.getParameter("dformat"); //jquery ui with input time
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
if (_jqui == null) _jqui = "";
if (dformat == null) dformat = "";
if (tformat == null) tformat = "";

boolean jqui = _jqui.trim().equals("y");

if (noOfDateTBox.equals("2")) {
    if (fromLbl == null) fromLbl = "Desde";
} else  {
   if (fromLbl == null) fromLbl = "";
}
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
<div class="input-group input-group-sm">
    <%if(!fromLbl.equals("")){%><span class="input-group-addon"><b><%=fromLbl%></b></span><%}%>
    <input type="text" placeholder="Ej: <%=hintText%>" <%=noTabIndex%> name="<%=nameOfTBox1%>" value="<%=valueOfTBox1.trim()%>"<%=(objSize == 0)?"":"  maxLength=\""+objSize+"\""%> id="<%=nameOfTBox1%>"<%=(clearOption.equalsIgnoreCase("true"))?" ondblclick=\"javascript:this.value=''\"":""%><%=(fieldClass.equals(""))?"class='form-control input-sm '":" class=\"form-control input-sm "+fieldClass+"\""%> <%=eventos1%> onchange="<%=onChange%>"<%=(disabled.trim().equalsIgnoreCase("y"))?" disabled":((readonly.trim().equalsIgnoreCase("y"))?" readonly":"")%> autocomplete="off">
    <span class = "input-group-btn">
      <%if(!jqui){%>
        <button tabindex="-1" name="reset<%=nameOfTBox1%>" id="reset<%=nameOfTBox1%>" value="" onclick="javascript:<%=appendOnClickEvt%>return showCalendar('<%=nameOfTBox1%>', '<%=jsFormat%>', <%=dateFormat%>, <%=timeFormat%>, false,'<%=jsEvent%>');"<%=(buttonClass.equals(""))?" class=\"btn btn-sm btn-inverse input-group-addon\"":" class=\""+buttonClass+"\""%><%=(disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))?" disabled":""%>><i class="fa fa-calendar"></i></button>
     <%} else {%>
          <button type="button" tabindex="-1" name="reset<%=nameOfTBox1%>" id="reset<%=nameOfTBox1%>" value="" onclick="javascript:<%=appendOnClickEvt%>;"<%=(buttonClass.equals(""))?" class=\"btn btn-sm btn-inverse input-group-addon\"":" class=\""+buttonClass+"\""%><%=(disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))?" disabled":""%>><i class="fa fa-calendar"></i></button> 
          <script>
              var options = {
                dateFormat: '<%=dformat%>',
                timeFormat: '<%=tformat%>',
                ampm: "hht",
              };
              <%if(!tformat.trim().equals("")){%>
                  options['controlType'] = {
                    create: function(tp_inst, obj, unit, val, min, max, step) {
                        $('<input class="ui-timepicker-input" value="'+val+'" style="width:50%">')
                            .appendTo(obj)
                            .spinner({
                              min: min,
                              max: max,
                              step: step,
                              change: function(e,ui){ // key events
                                  // don't call if api was used and not key press
                                  if(e.originalEvent !== undefined)
                                    tp_inst._onTimeChange();
                                  tp_inst._onSelectHandler();
                                  
                                },
                              spin: function(e,ui){ // spin events
                                  tp_inst.control.value(tp_inst, obj, unit, ui.value);
                                  tp_inst._onTimeChange();
                                  tp_inst._onSelectHandler();
                                }
                            });
                          return obj;
                    },
                    options: function(tp_inst, obj, unit, opts, val){
                        if(typeof(opts) == 'string' && val !== undefined)
                          return obj.find('.ui-timepicker-input').spinner(opts, val);
                        return obj.find('.ui-timepicker-input').spinner(opts);
                    },
                    value: function(tp_inst, obj, unit, val){
                        if(val !== undefined)
                          return obj.find('.ui-timepicker-input').spinner('value', val);
                        return obj.find('.ui-timepicker-input').spinner('value');
                    }
                  }
              <%}%>
              $("#reset<%=nameOfTBox1%>").click(function(){
                  $(<%=nameOfTBox1%>).datetimepicker(options);
                  $(<%=nameOfTBox1%>).datetimepicker("show");
              })
          </script>
     <%}%>
    </span>
</div>
<%
}
else if (noOfDateTBox.equals("2"))
{
	if (nameOfTBox1.equals(nameOfTBox2)) throw new Exception("Nombre del objeto de fecha duplicado!");
	else
	{
%>
<div class="input-group input-group-sm">
<span class="input-group-addon"><%=fromLbl%></span>
<input type="text" placeholder="Ej: <%=hintText%>" <%=noTabIndex%>  name="<%=nameOfTBox1%>" value="<%=valueOfTBox1.trim()%>"<%=(objSize == 0)?"":" maxLength=\""+objSize+"\""%> id="<%=nameOfTBox1%>"<%=(clearOption.equalsIgnoreCase("true"))?" ondblclick=\"javascript:this.value=''\"":""%><%=(fieldClass.equals(""))?"class='form-control input-sm '":" class=\"form-control input-sm "+fieldClass+"\""%> <%=eventos1%> onchange="<%=onChange%>"<%=(disabled.trim().equalsIgnoreCase("y"))?" disabled":((readonly.trim().equalsIgnoreCase("y"))?" readonly":"")%>>

<span class = "input-group-btn">
<button name="reset<%=nameOfTBox1%>" id="reset<%=nameOfTBox1%>" onclick="javascript:<%=appendOnClickEvt%>return showCalendar('<%=nameOfTBox1%>', '<%=jsFormat%>', <%=dateFormat%>, <%=timeFormat%>);"<%=(buttonClass.equals(""))?" class=\"btn btn-sm btn-inverse input-group-addon\"":" class=\""+buttonClass+"\""%><%=(disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))?" disabled":""%>>
  <i class="fa fa-calendar"></i>
</button>
</span>
</div>

<div class="input-group input-group-sm">
<span class="input-group-addon"><%=toLbl%></span>
<input type="text" placeholder="Ej: <%=hintText%>" <%=noTabIndex%> name="<%=nameOfTBox2%>" value="<%=valueOfTBox2.trim()%>"<%=(objSize == 0)?"":" maxLength=\""+objSize+"\""%> id="<%=nameOfTBox2%>"<%=(clearOption.equalsIgnoreCase("true"))?" ondblclick=\"javascript:this.value=''\"":""%><%=(fieldClass.equals(""))?"class='form-control input-sm '":" class=\"form-control input-sm "+fieldClass+"\""%> <%=eventos2%> onchange="<%=onChange%>"<%=(disabled.trim().equalsIgnoreCase("y"))?" disabled":((readonly.trim().equalsIgnoreCase("y"))?" readonly":"")%>>
<span class = "input-group-btn">
<button tabindex="-1" name="reset<%=nameOfTBox2%>" id="reset<%=nameOfTBox2%>" value="..." onclick="javascript:<%=appendOnClickEvt%>return showCalendar('<%=nameOfTBox2%>', '<%=jsFormat%>', <%=dateFormat%>, <%=timeFormat%>);"<%=(buttonClass.equals(""))?" class=\"btn btn-sm btn-inverse\"":" class=\""+buttonClass+"\""%><%=(disabled.trim().equalsIgnoreCase("y") || readonly.trim().equalsIgnoreCase("y"))?" disabled":""%>><i class="fa fa-calendar"></i></button>
</span>
</div>

<%
	}
}
%>