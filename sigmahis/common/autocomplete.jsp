<%
/*
1. Include html header "../common/autocomplete_header.jsp"
2. Add the following include:
		<jsp:include page="../common/autocomplete.jsp" flush="true">
			<jsp:param name="fieldId" value="inputField"/>
			<jsp:param name="fieldType" value="text"/>
			<jsp:param name="fieldIsRequired" value="y"/>
			<jsp:param name="fieldIsReadOnly" value="n"/>
			<jsp:param name="fieldClass" value="Text10"/>
			<jsp:param name="dObjId" value="document.form0.id"/>
			<jsp:param name="dObjRefer" value="document.form0.refer"/>
			<jsp:param name="containerSize" value="150%"/>
			<jsp:param name="containerFormat" value="@@id - @@description"/>
			<jsp:param name="dsMatchBy" value="id"/>
			<jsp:param name="dsType" value="drug"/>
		</jsp:include>
*/
//The ID string or element reference to the input field (a textbox or textarea) where users will type queries
String fieldId = request.getParameter("fieldId");
//Type of input field: text(default) or textarea
String fieldType = request.getParameter("fieldType");
String fieldValue = request.getParameter("fieldValue");
String fieldSize = request.getParameter("fieldSize");
String fieldRow = request.getParameter("fieldRow");//only for textarea
String fieldIsRequired = request.getParameter("fieldIsRequired");
String fieldIsReadOnly = request.getParameter("fieldIsReadOnly");
String fieldIsDisabled = request.getParameter("fieldIsDisabled");
String fieldClass = request.getParameter("fieldClass");
String fieldStyle = request.getParameter("fieldStyle");

//Return selected value to data objects
String dObjId = request.getParameter("dObjId");
String dObjDescription = request.getParameter("dObjDescription");
String dObjRefer = request.getParameter("dObjRefer");
String dObjXtra1 = request.getParameter("dObjXtra1");
String dObjXtra2 = request.getParameter("dObjXtra2");
String dObjXtra3 = request.getParameter("dObjXtra3");
String dObjXtra4 = request.getParameter("dObjXtra4");
String dObjXtra5 = request.getParameter("dObjXtra5");

//The ID string or element reference to the HTML container in which the query results will be displayed
String containerId = null;//request.getParameter("containerId");
String containerSize = request.getParameter("containerSize");
String containerFormat = request.getParameter("containerFormat");
String containerOnSelect = request.getParameter("containerOnSelect");

//a DataSource
String dataSource = request.getParameter("dataSource");
String dsQueryString = request.getParameter("dsQueryString");
String dsType = request.getParameter("dsType");
//By default, the results will be matched by description
String dsMatchBy = request.getParameter("dsMatchBy");//id|description|refer
//By default, the character(s) that delimits each record is newLine (\n)
String dsRecordDelim = request.getParameter("dsRecordDelim");
//By default, the character(s) that delimits each field within each record is tab (\t)
String dsFieldDelim = request.getParameter("dsFieldDelim");
String dsMaxEntries = request.getParameter("dsMaxEntries");
//By default, display up to 10 results in the container
String maxDisplay = request.getParameter("maxDisplay");
//By default, require user to type at least 3 characters before triggering a query
String minChars = request.getParameter("minChars");
//By default, the key input events will trigger in 0.1 seconds
String delay = request.getParameter("delay");
//By default, the data matching will be on. It is required to use with matchCase or matchContains
String applyFilter = request.getParameter("applyFilter");//y,n|true,false
//By default, the match case sensitivity will be false. Requires applyFilter to work
String matchCase = request.getParameter("matchCase");//y,n|true,false
//By default, the match results that contains the chars typed by the user will be false. Requires applyFilter to work
String matchContains = request.getParameter("matchContains");//y,n|true,false
//By default, the clear option on unmatched item will be false.
String unmatchClear = request.getParameter("unmatchClear");//y,n|true,false

if (fieldId == null) fieldId = "";
if (fieldType == null || fieldType.trim().equals("") || !fieldType.equalsIgnoreCase("textarea")) fieldType = "text";
if (fieldValue == null) fieldValue = "";
if (fieldSize == null) fieldSize = "";
if (fieldRow == null) fieldRow = "2";
if (fieldIsRequired == null) fieldIsRequired = "n";
if (fieldIsReadOnly == null) fieldIsReadOnly = "n";
if (fieldIsDisabled == null) fieldIsDisabled = "n";
if (fieldClass == null) fieldClass = "";
if (fieldStyle == null) fieldStyle = "";
if (dObjId == null) dObjId = "";
if (dObjDescription == null) dObjDescription = "";
if (dObjRefer == null) dObjRefer = "";
if (dObjXtra1 == null) dObjXtra1 = "";
if (dObjXtra2 == null) dObjXtra2 = "";
if (dObjXtra3 == null) dObjXtra3 = "";
if (dObjXtra4 == null) dObjXtra4 = "";
if (dObjXtra5 == null) dObjXtra5 = "";

if (containerId == null) containerId = "_ac_container_"+fieldId;
if (containerSize == null) containerSize = "";
if (containerFormat == null) containerFormat = "@@description [@@id / @@refer]";
if (containerOnSelect == null) containerOnSelect = "";

if (dsQueryString == null) dsQueryString = "";
if (dsType == null) dsType = "";
if (dsMatchBy == null || dsMatchBy.trim().equals("")) dsMatchBy = "description";
if (dsRecordDelim == null || dsRecordDelim.trim().equals("")) dsRecordDelim = "\\n";
if (dsFieldDelim == null || dsFieldDelim.trim().equals("") || dsFieldDelim.equalsIgnoreCase(dsRecordDelim)) dsFieldDelim = "\\t";
if (dataSource == null || dataSource.trim().equals("")) dataSource = "../common/autocomplete_ds.jsp";
StringBuffer dsParam = new StringBuffer();
dsParam.append("?dsType=");
dsParam.append(dsType);
dsParam.append("&dsMatchBy=");
dsParam.append(dsMatchBy);
if (!dsRecordDelim.equalsIgnoreCase("\\n")) {
	dsParam.append("&dsRecordDelim=");
	dsParam.append(issi.admin.IBIZEscapeChars.forURL(dsRecordDelim));
}
if (!dsFieldDelim.equalsIgnoreCase("\\t")) {
	dsParam.append("&dsFieldDelim=");
	dsParam.append(issi.admin.IBIZEscapeChars.forURL(dsFieldDelim));
}
dsParam.append("&");
dsParam.append(dsQueryString);
if (dsMaxEntries == null || dsMaxEntries.trim().equals("")) dsMaxEntries = "50";
if (maxDisplay == null || maxDisplay.trim().equals("")) maxDisplay = "10";
if (minChars == null || minChars.trim().equals("")) minChars = "3";
if (delay == null || delay.trim().equals("")) delay = "0.1";
if (applyFilter == null || applyFilter.trim().equals("")) applyFilter = "y";
if (matchCase == null || matchCase.trim().equals("")) matchCase = "n";
if (matchContains == null || matchContains.trim().equals("")) matchContains = "n";
if (unmatchClear == null || unmatchClear.trim().equals("")) unmatchClear = "n";

//System.out.println("/ - / - / - / - / - / - / fieldId = "+fieldId+" containerId = "+containerId+" dsType = "+dsType+" dsMatchBy = "+dsMatchBy);
%>
<% if (!fieldId.trim().equals("") && !dataSource.trim().equals("") && !dsType.trim().equals("")) { %>
<div id="_ac_dummy_<%=fieldId%>" class="yui-skin-sam">
	<div id="_ac_<%=fieldId%>">
<%
StringBuffer sbInputAttr = new StringBuffer();
StringBuffer sbInputClass = new StringBuffer();
if (fieldType.equalsIgnoreCase("textarea")) {
	if (!fieldSize.trim().equals("")) {
		sbInputAttr.append(" cols=\"");//"
		sbInputAttr.append(fieldSize);
		sbInputAttr.append("\"");//"
	}
	if (!fieldRow.trim().equals("")) {
		sbInputAttr.append(" rows=\"");//"
		sbInputAttr.append(fieldRow);
		sbInputAttr.append("\"");//"
	}
	if (fieldIsDisabled.equalsIgnoreCase("y") || fieldIsDisabled.equalsIgnoreCase("true")) {
		sbInputAttr.append(" disabled=\"true\"");
	} else if (fieldIsReadOnly.equalsIgnoreCase("y") || fieldIsReadOnly.equalsIgnoreCase("true")) {
		sbInputAttr.append(" readonly=\"true\"");
	}
	if (fieldIsRequired.equalsIgnoreCase("y") || fieldIsRequired.equalsIgnoreCase("true")) {
		sbInputClass.append(" FormDataObjectRequired");
	} else if (fieldIsReadOnly.equalsIgnoreCase("y") || fieldIsReadOnly.equalsIgnoreCase("true") || fieldIsDisabled.equalsIgnoreCase("y") || fieldIsDisabled.equalsIgnoreCase("true")) {
		sbInputClass.append(" FormDataObjectDisabled");
	}
	if (!fieldClass.trim().equals("")) {
		sbInputClass.append(" ");
		sbInputClass.append(fieldClass);
	}
	if (sbInputClass.length() > 0) {
		sbInputAttr.append(" class=\"");//"
		sbInputAttr.append(sbInputClass.substring(1));
		sbInputAttr.append("\"");//"
	}
	if (!fieldStyle.trim().equals("")) {
		sbInputAttr.append(" style=\"");//"
		sbInputAttr.append(fieldStyle);
		sbInputAttr.append("\"");//"
	}
%>
		<textarea id="<%=fieldId%>" name="<%=fieldId%>"<%=sbInputAttr%>><%=fieldValue%></textarea>
<%
} else {
	if (!fieldSize.trim().equals("")) {
		sbInputAttr.append(" size=\"");//"
		sbInputAttr.append(fieldSize);
		sbInputAttr.append("\"");//"
	}
	if (fieldIsDisabled.equalsIgnoreCase("y") || fieldIsDisabled.equalsIgnoreCase("true")) {
		sbInputAttr.append(" disabled=\"true\"");
	} else if (fieldIsReadOnly.equalsIgnoreCase("y") || fieldIsReadOnly.equalsIgnoreCase("true")) {
		sbInputAttr.append(" readonly=\"true\"");
	}
	if (fieldIsRequired.equalsIgnoreCase("y") || fieldIsRequired.equalsIgnoreCase("true")) {
		sbInputClass.append(" FormDataObjectRequired");
	} else if (fieldIsReadOnly.equalsIgnoreCase("y") || fieldIsReadOnly.equalsIgnoreCase("true") || fieldIsDisabled.equalsIgnoreCase("y") || fieldIsDisabled.equalsIgnoreCase("true")) {
		sbInputClass.append(" FormDataObjectDisabled");
	}
	if (!fieldClass.trim().equals("")) {
		sbInputClass.append(" ");
		sbInputClass.append(fieldClass);
	}
	if (sbInputClass.length() > 0) {
		sbInputAttr.append(" class=\"");//"
		sbInputAttr.append(sbInputClass.substring(1));
		sbInputAttr.append("\"");//"
	}
	if (!fieldStyle.trim().equals("")) {
		sbInputAttr.append(" style=\"");//"
		sbInputAttr.append(fieldStyle);
		sbInputAttr.append("\"");//"
	}
%>
		<input type="text" id="<%=fieldId%>" name="<%=fieldId%>" value="<%=fieldValue%>"<%=sbInputAttr%>>
<%
}
StringBuffer sbContainerAttr = new StringBuffer();
if (!containerSize.trim().equals("")) {
	sbContainerAttr.append(" style=\"width:");//"
	sbContainerAttr.append(containerSize);
	sbContainerAttr.append("\"");//"
}
%>
		<div id="<%=containerId%>" align="left"<%=sbContainerAttr%>/>
	</div>
</div>
<script type="text/javascript">
YAHOO.example.BasicRemote=function(){
if (oDS==undefined||oDS==null){
/*** Use an XHRDataSource ***/
var oDS=new YAHOO.util.XHRDataSource('<%=dataSource%><%=dsParam%>');
oDS.responseType=YAHOO.util.XHRDataSource.TYPE_TEXT;
oDS.responseSchema={fields:['matchBy','id','description','refer','xtra1','xtra2','xtra3','xtra4','xtra5'],recordDelim:'<%=dsRecordDelim%>',fieldDelim:'<%=dsFieldDelim%>'};
oDS.maxCacheEntries=<%=dsMaxEntries%>;
}
/*** Instantiate the AutoComplete ***/
var oAC=new YAHOO.widget.AutoComplete('<%=fieldId%>','<%=containerId%>',oDS);
oAC.maxResultsDisplayed=<%=maxDisplay%>;
oAC.minQueryLength=<%=minChars%>;
<% if (!delay.trim().equals("")){ %>oAC.queryDelay=<%=delay%>;<% } %>
oAC.applyLocalFilter=<%=(applyFilter.equalsIgnoreCase("n")||applyFilter.equalsIgnoreCase("false"))?false:true%>;
oAC.queryMatchCase=<%=(matchCase.equalsIgnoreCase("n")||matchCase.equalsIgnoreCase("false"))?false:true%>;
oAC.queryMatchContains=<%=(matchContains.equalsIgnoreCase("n")||matchContains.equalsIgnoreCase("false"))?false:true%>;
oAC.generateRequest=function(sQuery){return "&query="+sQuery;};
//Custom formatter
oAC.resultTypeList=false;
oAC.formatResult=function(oData,sQuery,sMatch){
	//return (sMatch+((oData.id!=null&&oData.id.trim()!='')?' ('+oData.id+')':'')+' '+oData.refer);
	//return sMatch;
	var format='<%=(containerFormat.startsWith("@@"+dsMatchBy))?containerFormat:"@@"+dsMatchBy+" - "+containerFormat%>';
	format=replaceAll(format,'@@description',oData.description);
	format=replaceAll(format,'@@id',oData.id);
	format=replaceAll(format,'@@refer',oData.refer);
	format=replaceAll(format,'@@xtra1',oData.xtra1);
	format=replaceAll(format,'@@xtra2',oData.xtra2);
	format=replaceAll(format,'@@xtra3',oData.xtra3);
	format=replaceAll(format,'@@xtra4',oData.xtra4);
	format=replaceAll(format,'@@xtra5',oData.xtra5);
	return format;
};
var itemSelectHandler=function(sType,aArgs){
	var rAc=aArgs[0];//reference back to the AC instance
	var eLI=aArgs[1];//reference to the selected LI element
	var oData=aArgs[2];//object literal of selected item's result data
	//update hidden form field with the selected item's ID
	//YAHOO.util.Dom.get("<%=fieldId%>ID").value=oData.id;
	<% if (!dObjId.trim().equals("")) { %>if(eval('<%=dObjId%>'))<%=dObjId%>.value=oData.id;<% } %>
	<% if (!dObjDescription.trim().equals("")) { %>if(eval('<%=dObjDescription%>'))<%=dObjDescription%>.value=oData.description;<% } %>
	<% if (!dObjRefer.trim().equals("")) { %>if(eval('<%=dObjRefer%>'))<%=dObjRefer%>.value=oData.refer;<% } %>
	<% if (!dObjXtra1.trim().equals("")) { %>if(eval('<%=dObjXtra1%>'))<%=dObjXtra1%>.value=oData.xtra1;<% } %>
	<% if (!dObjXtra2.trim().equals("")) { %>if(eval('<%=dObjXtra2%>'))<%=dObjXtra2%>.value=oData.xtra2;<% } %>
	<% if (!dObjXtra3.trim().equals("")) { %>if(eval('<%=dObjXtra3%>'))<%=dObjXtra3%>.value=oData.xtra3;<% } %>
	<% if (!dObjXtra4.trim().equals("")) { %>if(eval('<%=dObjXtra4%>'))<%=dObjXtra4%>.value=oData.xtra4;<% } %>
	<% if (!dObjXtra5.trim().equals("")) { %>if(eval('<%=dObjXtra5%>'))<%=dObjXtra5%>.value=oData.xtra5;<% } %>
	oAC.getInputEl().value=oData.description;
	<%=containerOnSelect%>
};
oAC.itemSelectEvent.subscribe(itemSelectHandler);
<% if (unmatchClear.equalsIgnoreCase("y") || unmatchClear.equalsIgnoreCase("true")) { %>
var unmatchedItemSelectHandler=function(sType,aArgs){
	<% if (!dObjId.trim().equals("")) { %>if(eval('<%=dObjId%>'))<%=dObjId%>.value='';<% } %>
	<% if (!dObjDescription.trim().equals("")) { %>if(eval('<%=dObjDescription%>'))<%=dObjDescription%>.value='';<% } %>
	<% if (!dObjRefer.trim().equals("")) { %>if(eval('<%=dObjRefer%>'))<%=dObjRefer%>.value='';<% } %>
	<% if (!dObjXtra1.trim().equals("")) { %>if(eval('<%=dObjXtra1%>'))<%=dObjXtra1%>.value='';<% } %>
	<% if (!dObjXtra2.trim().equals("")) { %>if(eval('<%=dObjXtra2%>'))<%=dObjXtra2%>.value='';<% } %>
	<% if (!dObjXtra3.trim().equals("")) { %>if(eval('<%=dObjXtra3%>'))<%=dObjXtra3%>.value='';<% } %>
	<% if (!dObjXtra4.trim().equals("")) { %>if(eval('<%=dObjXtra4%>'))<%=dObjXtra4%>.value='';<% } %>
	<% if (!dObjXtra5.trim().equals("")) { %>if(eval('<%=dObjXtra5%>'))<%=dObjXtra5%>.value='';<% } %>
};
oAC.unmatchedItemSelectEvent.subscribe(unmatchedItemSelectHandler);//to blank data objects selected from AC if the given value doesn't matches
<% } %>
return{oDS:oDS,oAC:oAC};
}();
</script>
<% } %>