/*---------------------------------------------------------------------
                                ___       __      __      __
 __                  __       /'___`\   /'__`\  /'__`\  /'_ `\
/\_\    ____    ____/\_\     /\_\ /\ \ /\ \/\ \/\ \/\ \/\ \L\ \
\/\ \  /',__\  /',__\/\ \    \/_/// /__\ \ \ \ \ \ \ \ \/_> _ <_
 \ \ \/\__, `\/\__, `\ \ \      // /_\ \\ \ \_\ \ \ \_\ \/\ \L\ \
  \ \_\/\____/\/\____/\ \_\    /\______/ \ \____/\ \____/\ \____/
   \/_/\/___/  \/___/  \/_/    \/_____/   \/___/  \/___/  \/___/
                                                               By E.B.
-----------------------------------------------------------------------
CREATE DINAMIC DIV OBJECTS AND SET AJAX PROPERTIES TO THEM,
THE FUNCTIONS INSIDE JUST WORK CORRECTLY WITH FILES INTO DOMAIN,
TESTED IN FIREFOX 2.0 AND INTERNET EXPLORER 7.0
                               VERSION 1.0
---------------------------------------------------------------------*/
checkBrowser();

this.findLeftObj = function(obj) {
var curleft = 0;
if (obj.offsetParent) {
   while (obj.offsetParent) {
    curleft += obj.offsetLeft
    obj = obj.offsetParent;
    }
}
else {
 if(obj.x) {
   curleft += obj.x;
  }
}
return(curleft);
}

this.findTopObj = function(obj) {
var curtop = 0;
if (obj.offsetParent) {
    while (obj.offsetParent) {
        curtop += obj.offsetTop
        obj = obj.offsetParent;
    }
}
else {
  if (obj.y) {
    curtop += obj.y;
   }
}
return(curtop);
}

function dFrame(ob,URL){
if(document.getElementById('parentiResultOb')!=null){DeleteElements();}
if(document.getElementById('iResult'+ob.id)==null){
  var body = document.getElementsByTagName('body')[0];
  var iframe = document.createElement('IFRAME');
    iframe.id='iResult'+ob.id;
    iframe.style.width=ob.offsetWidth-2;
    iframe.style.height="100px";
    iframe.allowtransparency=true;
    iframe.frameborder='0';
    iframe.marginheight='0';
    iframe.marginwidth='0';
    iframe.style.left=findLeftObj(ob);
    iframe.style.top =20+findTopObj(ob);
    iframe.style.display='inline';
    iframe.style.position='absolute';
    body.appendChild(iframe);
    iframe.className='iResultExpandRows';
    var ihidden = document.createElement('INPUT');
      ihidden.id='parentiResultOb';
      ihidden.type='hidden';
      ihidden.value=ob.id;
      body.appendChild(ihidden);
}
if(URL!=''){document.getElementById('iResult'+ob.id).src=URL;}
}

function removeOpenElements(dTable){var rows=document.getElementById(dTable).rows;for(var i=0;i<rows.length;i++){rowId=rows[i].getAttribute('id');if(rowId!=null&&rowId!=''&&rowId!=undefined)if(document.getElementById('d'+rowId)!=null)SelectSlide('d'+rowId,dTable);}}
function diFrame(dTable,dcolSpan,dName,dwidth,dheight,dleft,dtop,dposition,dclassName,dscroll,ddisplay,dURL,wmodal){
  removeOpenElements(dTable);
  if(document.getElementById('d'+dName)==null){
    var iframe = document.createElement('IFRAME');
      iframe.id='d'+dName;
      iframe.style.width=dwidth+"px";
      iframe.style.height=dheight+"px";
      iframe.src=dURL;
      if(dscroll==true) iframe.scrolling='yes';
      else iframe.scrolling='no';

      iframe.frameborder='0px';
      iframe.marginheight='0px';
      iframe.marginwidth='0px';
      if(dleft!='0' && dtop!='0'){iframe.style.left=dleft; iframe.style.top=dtop;}
      if(ddisplay=='0')iframe.style.display='none';
      if(ddisplay=='1')iframe.style.display='inline';
        iframe.style.overflow='hidden';
      if(dposition=='0') iframe.style.position='static';
      if(dposition=='1') iframe.style.position='absolute';
      obj=document.getElementById(dTable);
      f=document.getElementById(dName);
      Tr=document.createElement('tr');
      Tr.setAttribute("id","trd"+dName);
      Td=document.createElement('td');
      Td.setAttribute("colSpan",dcolSpan);
      Td.appendChild(iframe);
      Tr.appendChild(Td);
      obj.insertBefore(Tr,f.nextSibling)

    if(dscroll==true) dclassName='DIVExpandRowsScroll';
    iframe.className=dclassName;
  }
  SelectSlide('d'+dName,dTable);

  if(wmodal==true){
    var e=null;e=document.getElementById('d'+dName);
    initPopUpWindow(e.id,dTable, dwidth, dheight);
    showPopWin(e.id,dwidth, dheight, null);
  }

return iframe;
}


var slideInUse = new Array();
function dDiv(dTable,dcolSpan,dName,dwidth,dheight,dleft,dtop,dposition,dclassName,dscroll,ddisplay,dURL){
  if(document.getElementById('d'+dName)==null){
    var div = document.createElement('DIV');
      div.id='d'+dName;
      div.style.width=dwidth;
      div.style.height=dheight;
      if(dleft!='0' && dtop!='0'){div.style.left=dleft; div.style.top=dtop;}
      if(ddisplay=='0')div.style.display='none';
      if(ddisplay=='1')div.style.display='inline';
        div.style.overflow='hidden';
      if(dscroll==true) div.style.overflow='scroll';
      if(dposition=='0') div.style.position='static';
      if(dposition=='1') div.style.position='absolute';

      obj=document.getElementById(dTable);
      f=document.getElementById(dName);
      Tr=document.createElement('tr');
      Tr.setAttribute("id","trd"+dName);
      Td=document.createElement('td');
      Td.setAttribute("colSpan",dcolSpan);
      Td.appendChild(div);
      Tr.appendChild(Td);
      obj.insertBefore(Tr,f.nextSibling)

    //document.getElementById(dName).appendChild(div);

    if(dscroll==true) dclassName='DIVExpandRowsScroll';
    div.className=dclassName;
  if(dURL!='') ajaxpage(dURL, 'd'+dName);
  }
  SelectSlide('d'+dName,dTable);
return div;
}

function SelectSlide(objId,dTable,optional) {
if(optional=='clear'){
  Slide(objId,dTable).up();}
else{
  this.obj = document.getElementById(objId);
  if(this.obj.style.display=='none'){Slide(objId).down();}
  else{Slide(objId,dTable).up();}
}
}

function Slide(objId,dTable, options) {
  this.obj = document.getElementById(objId);
  this.duration = 1;
  this.height = parseInt(this.obj.style.height);

  if(typeof options != 'undefined') { this.options = options; } else { this.options = {}; }
  if(this.options.duration) { this.duration = this.options.duration; }

  this.up = function() {
    this.curHeight = this.height;
    this.newHeight = '1';
    if(slideInUse[objId] != true) {
      var finishTime = this.slide();
      window.setTimeout("Slide('"+objId+"').finishup("+this.height+",'"+dTable+"');",finishTime);
    }
  }

  this.down = function() {
    this.newHeight = this.height;
    this.curHeight = '1';
    if(slideInUse[objId] != true) {
      this.obj.style.height = '1px';
      this.obj.style.display = 'block';
      this.slide();
    }
  }

  this.slide = function() {
    slideInUse[objId] = true;
    var frames = 30 * duration; // Running at 30 fps

    var tIncrement = (duration*1000) / frames;
    tIncrement = Math.round(tIncrement);
    var sIncrement = (this.curHeight-this.newHeight) / frames;

    var frameSizes = new Array();
    for(var i=0; i < frames; i++) {
      if(i < frames/2) {
        frameSizes[i] = (sIncrement * (i/frames))*4;
      } else {
        frameSizes[i] = (sIncrement * (1-(i/frames)))*4;
      }
    }

    for(var i=0; i < frames; i++) {
      this.curHeight = this.curHeight - frameSizes[i];
      window.setTimeout("document.getElementById('"+objId+"').style.height='"+Math.round(this.curHeight)+"px';",tIncrement * i);
    }

    window.setTimeout("delete(slideInUse['"+objId+"']);",tIncrement * i);

    if(this.options.onComplete) {
      window.setTimeout(this.options.onComplete, tIncrement * (i-2));
    }

    return tIncrement * i;
  }

  this.finishup = function(height,dTable) {
    this.obj.style.display = 'none';
    this.obj.style.height = height + 'px';
    var d = document.getElementById(dTable); var olddiv = document.getElementById("tr"+objId); d.removeChild(olddiv);
  }

  return this;
}


/********************************************************************************
* Dynamic Ajax Content- © Dynamic Drive DHTML code library (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
********************************************************************************/
var bustcachevar=1 //bust potential caching of external pages after initial request? (1=yes, 0=no)
var loadedobjects=""
var rootdomain="http://"+window.location.hostname
var bustcacheparameter=""

function ajaxpage(url, containerid){
var page_request = false
if (window.XMLHttpRequest) // if Mozilla, Safari etc
page_request = new XMLHttpRequest()
else if (window.ActiveXObject){ // if IE
try {
page_request = new ActiveXObject("Msxml2.XMLHTTP")
}
catch (e){
try{
page_request = new ActiveXObject("Microsoft.XMLHTTP")
}
catch (e){}
}
}
else
return false
page_request.onreadystatechange=function(){
loadpage(page_request, containerid)
}
if (bustcachevar) //if bust caching of external page
bustcacheparameter=(url.indexOf("?")!=-1)? "&"+new Date().getTime() : "?"+new Date().getTime()
page_request.open('GET', url+bustcacheparameter, true)
page_request.send(null)
}

function loadpage(page_request, containerid){
if (page_request.readyState == 4 && (page_request.status==200 || window.location.href.indexOf("http")==-1))
document.getElementById(containerid).innerHTML=page_request.responseText
}

function loadobjs(){
if (!document.getElementById)
return
for (i=0; i<arguments.length; i++){
var file=arguments[i]
var fileref=""
if (loadedobjects.indexOf(file)==-1){ //Check to see if this object has not already been added to page before proceeding
if (file.indexOf(".js")!=-1){ //If object is a js file
fileref=document.createElement('script')
fileref.setAttribute("type","text/javascript");
fileref.setAttribute("src", file);
}
else if (file.indexOf(".css")!=-1){ //If object is a css file
fileref=document.createElement("link")
fileref.setAttribute("rel", "stylesheet");
fileref.setAttribute("type", "text/css");
fileref.setAttribute("href", file);
}
}
if (fileref!=""){
document.getElementsByTagName("head").item(0).appendChild(fileref)
loadedobjects+=file+" " //Remember this object as being already added to page
}
}
}
/********************************************************************************/

/******Begin: source to vbmodal**************************************************/
/**
 * This derivative version of subModal can be downloaded from http://gabrito.com/files/subModal/
 * Original By Seth Banks (webmaster at subimage dot com)  http://www.subimage.com/
 * Contributions by Eric Angel (tab index code), Scott (hiding/showing selects for IE users), Todd Huss (submodal class on hrefs, moving div containers into javascript, phark method for putting close.gif into CSS), Thomas Risberg (safari fixes for scroll amount), Dave Campbell (improved parsing of submodal-width-height class)
 * Set settings to AJAX and dinamic objects, executing, and others fixes by elohim.b@issi-panama.com, E.B. 2008.
 */
var gPopupMask = null;
var gPopupContainer = null;
var gPopFrame = null;
var gReturnFunc;
var gPopupIsShown = false;
var gHideSelects = false;
var gRoot='..';
if(location.pathname.split('/').length==3)gRoot='.';
var gDefaultPage = gRoot+"/common/loading.html";
var gBefCloseEvt = '';
var gShowExecutionTime=false;

var gTabIndexes = new Array();
// Pre-defined list of tags we want to disable/enable tabbing into
var gTabbableTags = new Array("A","BUTTON","TEXTAREA","INPUT","IFRAME");
// If using Mozilla or Firefox, use Tab-key trap.
if (!document.all) {
  document.onkeypress = keyDownHandler;
}

var _popWinInitialized=false;
/**
 * Initializes popup code on load.
 */
function initPopUp() {
  // Add the HTML to the body
  var body = document.getElementsByTagName('BODY')[0];
  var popmask = document.createElement('div');
  popmask.id = 'popupMask';
  var popcont = document.createElement('div');
  popcont.id = 'popupContainer';
  popcont.innerHTML = '' +
    '<div id="popupInner">' +
      '<div id="popupTitleBar">' +
        '<div id="popupTitle"></div>' +//Interamerican Software Solution & Integration
        '<div id="popupControls">' +
          //'<a onclick="'+gBefCloseEvt+'hidePopWin(false);"><span>Close</span></a>' +
          '<img src="'+gRoot+'/images/close_large.gif" onclick="'+gBefCloseEvt+'hidePopWin(false);" id="popCloseBox" />' +
        '</div>' +
      '</div>' +
      '<iframe src="'+gDefaultPage+'" style="width:100%;height:100%;background-color:transparent;" scrolling="auto" frameborder="0" allowtransparency="true" id="popupFrame" name="popupFrame" width="100%" height="100%"></iframe>' +
    '</div>';
  body.appendChild(popmask);
  body.appendChild(popcont);
  gPopupMask = document.getElementById("popupMask");
  gPopupContainer = document.getElementById("popupContainer");
  gPopFrame = document.getElementById("popupFrame");

  // check to see if this is IE version 6 or lower. hide select boxes if so
  // maybe they'll fix this in version 7?
  /* var brsVersion = parseInt(window.navigator.appVersion.charAt(0), 10);
    if ((brsVersion <= 6 && window.navigator.userAgent.indexOf("MSIE") > -1)||$.browser.webkit) {
    gHideSelects = true;
  } */
  
  var brsVersion = bowser.version;
    if ((brsVersion <= 6 && bowser.msie)||bowser.webkit) {
    gHideSelects = true;
  }

  // Add onclick handlers to 'a' elements of class submodal or submodal-width-height
  var elms = document.getElementsByTagName('a');
  for (i = 0; i < elms.length; i++) {
    if (elms[i].className.indexOf("submodal") == 0) {
      // var onclick = 'function (){showPopWin(\''+elms[i].href+'\','+width+', '+height+', null);return false;};';
      // elms[i].onclick = eval(onclick);
      elms[i].onclick = function(){
        // default width and height
        var width = 400;
        var height = 200;
        // Parse out optional width and height from className
        params = this.className.split('-');
        if (params.length == 3) {
          width = parseInt(params[1]);
          height = parseInt(params[2]);
        }
        showPopWin(this.href,width,height,null); return false;
      }
    }
  }
  _popWinInitialized=true;
}
addEvent(window,"load",initPopUp);

 /**
  * @argument width - int in pixels
  * @argument height - int in pixels
  * @argument url - url to display
  * @argument returnFunc - function to call when returning true from the window.
  * @argument showCloseBox - show the close box - default true
  * @argument befCloseEvt - trigger action before closing modal
  */
function showPopWin(url, width, height, returnFunc, showCloseBox, befCloseEvt) {
  var iDate=new Date();
  if(!_popWinInitialized)initPopUp();
  if (befCloseEvt != null) gBefCloseEvt = befCloseEvt;
  // show or hide the window close widget
  if (showCloseBox == null || showCloseBox == true) {
    document.getElementById("popCloseBox").style.display = "block";
  } else {
    document.getElementById("popCloseBox").style.display = "none";
  }
  gPopupIsShown = true;
  disableTabIndexes();
  gPopupMask.style.display = "block";
  gPopupContainer.style.display = "block";
  // calculate where to place the window on screen
  centerPopWin(width, height);

  var titleBarHeight = parseInt(document.getElementById("popupTitleBar").offsetHeight, 10);


  gPopupContainer.style.width = width + "px";
  gPopupContainer.style.height = (height+titleBarHeight) + "px";

  setMaskSize();

  // need to set the width of the iframe to the title bar width because of the dropshadow
  // some oddness was occuring and causing the frame to poke outside the border in IE6
  gPopFrame.style.width = parseInt(document.getElementById("popupTitleBar").offsetWidth, 10) + "px";
  gPopFrame.style.height = (height) + "px";

  // set the url
  gPopFrame.src = url;

  gReturnFunc = returnFunc;
  // for IE
  if (gHideSelects == true) {
    hideSelectBoxes();
  }

  window.setTimeout("setPopTitle();", 600);
  if(gShowExecutionTime)alert('shopPopWin executed in '+(new Date()-iDate)+' miliseconds!');
}


var gi = 0;
function centerPopWin(width, height) {
  if (gPopupIsShown == true) {
    if (width == null || isNaN(width)) {
      width = gPopupContainer.offsetWidth;
    }
    if (height == null) {
      height = gPopupContainer.offsetHeight;
    }

    //var theBody = document.documentElement;
    var theBody = document.getElementsByTagName("BODY")[0];
    //theBody.style.overflow = "hidden";
    var scTop = parseInt(getScrollTop(),10);
    var scLeft = parseInt(theBody.scrollLeft,10);

    setMaskSize();

    //window.status = gPopupMask.style.top + " " + gPopupMask.style.left + " " + gi++;

    var titleBarHeight = parseInt(document.getElementById("popupTitleBar").offsetHeight, 10);

    var fullHeight = getViewportHeight();
    var fullWidth = getViewportWidth();

    gPopupContainer.style.top = (scTop + ((fullHeight - (height+titleBarHeight)) / 2)) + "px";
    gPopupContainer.style.left =  (scLeft + ((fullWidth - width) / 2)) + "px";
    //alert(fullWidth + " " + width + " " + gPopupContainer.style.left);
  }
}
addEvent(window, "resize", centerPopWin);
addEvent(window, "scroll", centerPopWin);
window.onscroll = centerPopWin;


/**
 * Sets the size of the popup mask.
 *
 */
function setMaskSize() {
  var theBody = document.getElementsByTagName("BODY")[0];

  var fullHeight = getViewportHeight();
  var fullWidth = getViewportWidth();

  // Determine what's bigger, scrollHeight or fullHeight / width
  if (fullHeight > theBody.scrollHeight) {
    popHeight = fullHeight;
  } else {
    popHeight = theBody.scrollHeight;
  }

  if (fullWidth > theBody.scrollWidth) {
    popWidth = fullWidth;
  } else {
    popWidth = theBody.scrollWidth;
  }

  gPopupMask.style.height = popHeight + "px";
  gPopupMask.style.width = popWidth + "px";
}

/**
 * @argument callReturnFunc - bool - determines if we call the return function specified
 * @argument returnVal - anything - return value
 */
function hidePopWin(callReturnFunc) {
  var iDate=new Date();
  gPopupIsShown = false;
  var theBody = document.getElementsByTagName("BODY")[0];
  theBody.style.overflow = "";
  restoreTabIndexes();
  if (gPopupMask == null) {
    return;
  }
  gPopupMask.style.display = "none";
  gPopupContainer.style.display = "none";
  if (callReturnFunc == true && gReturnFunc != null) {
    // Set the return code to run in a timeout.
    // Was having issues using with an Ajax.Request();
    gReturnVal = window.frames["popupFrame"].returnVal;
    window.setTimeout('gReturnFunc(gReturnVal);', 1);
  }
  gPopFrame.src = gDefaultPage;
  // display all select boxes
  if (gHideSelects == true) {
    displaySelectBoxes();
  }
  if(gShowExecutionTime)alert('hidePopWin executed in '+(new Date()-iDate)+' miliseconds!');
}

/**
 * Sets the popup title based on the title of the html document it contains.
 * Uses a timeout to keep checking until the title is valid.
 */
function setPopTitle() {
  //return;
  if (window.frames["popupFrame"].document.title == null) {
    window.setTimeout("setPopTitle();", 10);
  } else {
    document.getElementById("popupTitle").innerHTML = window.frames["popupFrame"].document.title;
  }
}

// Tab key trap. iff popup is shown and key was [TAB], suppress it.
// @argument e - event - keyboard event that caused this function to be called.
function keyDownHandler(e) {
    if(typeof keyEvent === "function") keyEvent(e);
    if (gPopupIsShown && e.keyCode == 9)  return false;
}

// For IE.  Go through predefined tags and disable tabbing into them.
function disableTabIndexes() {
  var iDate=new Date();
  if (document.all) {
    var i = 0;
    for (var j = 0; j < gTabbableTags.length; j++) {
      var tagElements = document.getElementsByTagName(gTabbableTags[j]);
      for(var k=0,tag;tag=tagElements[k];k++)
      {
        gTabIndexes[i]=tag.tabIndex;
        tag.tabIndex="-1";
        i++;
      }
    }
  }
  if(gShowExecutionTime)alert('disableTabIndexes executed in '+(new Date()-iDate)+' miliseconds!');
}

// For IE. Restore tab-indexes.
function restoreTabIndexes() {
  var iDate=new Date();
  if (document.all) {
    var i = 0;
    for (var j = 0; j < gTabbableTags.length; j++) {
      var tagElements = document.getElementsByTagName(gTabbableTags[j]);
      for(var k=0,tag;tag=tagElements[k];k++)
      {
        tag.tabIndex=gTabIndexes[i];
        tag.tabEnabled=true;
        i++;
      }
    }
  }
  if(gShowExecutionTime)alert('restoreTabIndexes executed in '+(new Date()-iDate)+' miliseconds!');
}

/**
 * Hides all drop down form select boxes on the screen so they do not appear above the mask layer.
 * IE has a problem with wanted select form tags to always be the topmost z-index or layer
 *
 * Thanks for the code Scott!
 */
function hideSelectBoxes(){var iDate=new Date();for(var f=0;f<top.window.frames.length;f++){var tagElements=top.window.frames[f].document.getElementsByTagName('SELECT');for(var i=0;i<tagElements.length;i++)tagElements[i].style.visibility='hidden';tagElements=top.window.frames[f].document.getElementsByTagName('OBJECT');for(var i=0;i<tagElements.length;i++)tagElements[i].style.visibility='hidden';if(top.window.frames[f].length>0)hideSelectBoxesX(f);}if(gShowExecutionTime)alert('hideSelectBoxes executed in '+(new Date()-iDate)+' miliseconds!');}
//
function hideSelectBoxesX(j){var iDate=new Date();for(var f=0;f<top.window.frames[j].frames.length;f++){var tagElements=top.window.frames[j].frames[f].document.getElementsByTagName('SELECT');for(var i=0;i<tagElements.length;i++)tagElements[i].style.visibility='hidden';tagElements=top.window.frames[j].frames[f].document.getElementsByTagName('OBJECT');for(var i=0;i<tagElements.length;i++)tagElements[i].style.visibility='hidden';}if(gShowExecutionTime)alert('hideSelectBoxes executed in '+(new Date()-iDate)+' miliseconds!');}

/**
* Makes all drop down form select boxes on the screen visible so they do not reappear after the dialog is closed.
* IE has a problem with wanted select form tags to always be the topmost z-index or layer
*/
function displaySelectBoxes(){var iDate=new Date();for(var f=0;f<top.window.frames.length;f++){var tagElements=top.window.frames[f].document.getElementsByTagName('SELECT');for(var i=0;i<tagElements.length;i++)tagElements[i].style.visibility='visible';tagElements=top.window.frames[f].document.getElementsByTagName('OBJECT');for(var i=0;i<tagElements.length;i++)tagElements[i].style.visibility='visible';if(top.window.frames[f].length>0)displaySelectBoxesX(f);}if(gShowExecutionTime)alert('displaySelectBoxes executed in '+(new Date()-iDate)+' miliseconds!');}
//
function displaySelectBoxesX(j){var iDate=new Date();for(var f=0;f<top.window.frames[j].frames.length;f++){var tagElements=top.window.frames[j].frames[f].document.getElementsByTagName('SELECT');for(var i=0;i<tagElements.length;i++)tagElements[i].style.visibility='visible';tagElements=top.window.frames[j].frames[f].document.getElementsByTagName('OBJECT');for(var i=0;i<tagElements.length;i++)tagElements[i].style.visibility='visible';}if(gShowExecutionTime)alert('displaySelectBoxes executed in '+(new Date()-iDate)+' miliseconds!');}

/**
 * X-browser event handler attachment and detachment
 * TH: Switched first true to false per http://www.onlinetools.org/articles/unobtrusivejavascript/chapter4.html
 *
 * @argument obj - the object to attach event to
 * @argument evType - name of the event - DONT ADD "on", pass only "mouseover", etc
 * @argument fn - function to call
 */
function addEvent(obj, evType, fn){
 if (obj.addEventListener){
    obj.addEventListener(evType, fn, false);
    return true;
 } else if (obj.attachEvent){
    var r = obj.attachEvent("on"+evType, fn);
    return r;
 } else {
    return false;
 }
}
function removeEvent(obj, evType, fn, useCapture){
  if (obj.removeEventListener){
    obj.removeEventListener(evType, fn, useCapture);
    return true;
  } else if (obj.detachEvent){
    var r = obj.detachEvent("on"+evType, fn);
    return r;
  } else {
    alert("Handler could not be removed");
  }
}

/**
 * Code below taken from - http://www.evolt.org/article/document_body_doctype_switching_and_more/17/30655/
 *
 * Modified 4/22/04 to work with Opera/Moz (by webmaster at subimage dot com)
 *
 * Gets the full width/height because it's different for most browsers.
 */
function getViewportHeight() {
  if (window.innerHeight!=window.undefined) return window.innerHeight;
  if (document.compatMode=='CSS1Compat') return document.documentElement.clientHeight;
  if (document.body) return document.body.clientHeight;

  return window.undefined;
}
function getViewportWidth() {
  if (window.innerWidth!=window.undefined) return window.innerWidth;
  if (document.compatMode=='CSS1Compat') return document.documentElement.clientWidth;
  if (document.body) return document.body.clientWidth;
}

/**
 * Gets the real scroll top
 */
function getScrollTop() {
  if (self.pageYOffset) // all except Explorer
  {
    return self.pageYOffset;
  }
  else if (document.documentElement && document.documentElement.scrollTop)
    // Explorer 6 Strict
  {
    return document.documentElement.scrollTop;
  }
  else if (document.body) // all other Explorers
  {
    return document.body.scrollTop;
  }
}
function getScrollLeft() {
  if (self.pageXOffset) // all except Explorer
  {
    return self.pageXOffset;
  }
  else if (document.documentElement && document.documentElement.scrollLeft)
    // Explorer 6 Strict
  {
    return document.documentElement.scrollLeft;
  }
  else if (document.body) // all other Explorers
  {
    return document.body.scrollLeft;
  }
}
/******End:   source to vbmodal**************************************************/