<%String bootstrap = request.getParameter("bootstrap") == null ? "" : "-"+request.getParameter("bootstrap");%>
<link rel="stylesheet" type="text/css" media="all" href="<%=request.getContextPath()%>/css/calendar-blue<%=bootstrap%>.css" />
<script src="<%=request.getContextPath()%>/js/calendar.js"></script>
<script src="<%=request.getContextPath()%>/js/calendar-es.js"></script>
<script>
var oldLink = null;
function setActiveStyleSheet(link, title) {
  var i, a, main;
  for(i=0; (a = document.getElementsByTagName("link")[i]); i++) {
    if(a.getAttribute("rel").indexOf("style") != -1 && a.getAttribute("title")) {
      a.disabled = true;
      if(a.getAttribute("title") == title) a.disabled = false;
    }
  }
  if (oldLink) oldLink.style.fontWeight = 'normal';
  oldLink = link;
  link.style.fontWeight = 'bold';
  return false;
}
function selected(cal, date, jsEvent) {
  cal.sel.value = date; // just update the date in the input field.
  if (cal.dateClicked ){
  	eval(jsEvent);
    cal.callCloseHandler();
	}
}
function closeHandler(cal) {
	if(cal.showsTime&&this.onJsEvent!='')eval(cal.onJsEvent);
  cal.hide();                        // hide the calendar
  _dynarch_popupCalendar = null;
}
function showCalendar(id, format, showsDate, showsTime, showsOtherMonths, jsEvent) {
  var el = document.getElementById(id);
  if (_dynarch_popupCalendar != null) {
    _dynarch_popupCalendar.hide();                 // so we hide it first.
  } else {
    var cal = new Calendar(1, null, selected, closeHandler, jsEvent);
		cal.showsDate = showsDate;
    if (typeof showsTime == "string") {
      cal.showsTime = true;
      cal.time24 = (showsTime == "24");
    }
    if (showsOtherMonths) {
      cal.showsOtherMonths = true;
    }
    _dynarch_popupCalendar = cal;                  // remember it in the global var
    cal.setRange(1900, 2070);        // min/max year allowed.
    cal.create();
  }
  _dynarch_popupCalendar.setDateFormat(format);    // set the specified date format
  _dynarch_popupCalendar.parseDate(el.value);      // try to parse the text in field
  _dynarch_popupCalendar.sel = el;                 // inform it what input field we use
//  _dynarch_popupCalendar.showAtElement(el.nextSibling, "Br");        // show the calendar
  _dynarch_popupCalendar.showAtElement(el, "Br");        // show the calendar
  return false;
}

var MINUTE = 60 * 1000;
var HOUR = 60 * MINUTE;
var DAY = 24 * HOUR;
var WEEK = 7 * DAY;

function isDisabled(date) {  var today = new Date(); return (Math.abs(date.getTime() - today.getTime()) / DAY) > 10; }
function flatSelected(cal, date) {  var el = document.getElementById("preview");  el.innerHTML = date; }
function showFlatCalendar() { 
var parent = document.getElementById("display"); 
var cal = new Calendar(0, null, flatSelected); 
  cal.weekNumbers = false;
  cal.setDisabledHandler(isDisabled);
  cal.setDateFormat("%A, %B %e");
  cal.create(parent);
  cal.show();
}
</script>