/*Function to get application context name*/
function getRootDir(){return window.location.pathname.replace(/^\/([^\/]*).*$/, '$1');}
<!-- if company has been changed then use array from top frame/window, otherwise use array from current frame/window -->
var useTopWinArray=false;
<!-- G E N E R A L -->
var loaded=false;
var winFocusException=new Array('expediente/expediente_list.jsp','inventario/reg_cargo_uso_insumo_cu.jsp','inventario/reg_cargo_uso_insumo_cu_det.jsp','expediente/reg_sol_imag_item.jsp');
var winFocus=true;
for(_i=0;_i<winFocusException.length;_i++){if(document.URL.indexOf(winFocusException[_i])>-1){winFocus=false;break;}}
if(winFocus)window.focus();

/*
Create trim method for a String data type.
How to use:
  var str = 'test ';
  str.trim(); //The output will be 'test'
*/
String.prototype.trim=function(){var str=this.replace(/^\s\s*/,''),ws=/\s/,i=str.length;while(ws.test(str.charAt(--i)));return str.slice(0,i+1);}
/*
Create lpad method for a String data type.
How to use:
  var str = 'test';
  str.lpad(10,'x'); //The output will be 'xxxxxxtest'
*/
String.prototype.lpad=function(len,pad){var str=this;if(typeof(len)=="undefined")len=0;if(typeof(pad)=="undefined")pad=' ';if(len+1>=str.length)str=Array(len+1-str.length).join(pad)+str;return str;}
/*
Create rpad method for a String data type.
How to use:
  var str = 'test';
  str.rpad(10,'x'); //The output will be 'testxxxxxx'
*/
String.prototype.rpad=function(len,pad){var str=this;if(typeof(len)=="undefined")len=0;if(typeof(pad)=="undefined")pad=' ';if(len+1>=str.length)str=str+Array(len+1-str.length).join(pad);return str;}
/*
Create toArray method for a String data type.
How to use:
  var str = 'test1,test2';
  str.toArray(); //The output will be array = ['test1','test2']
*/
String.prototype.toArray=function(separator){if(separator==undefined||separator==null||separator.trim()=='')separator=',';var str=this;var arr=null;if(str.indexOf(separator)>=0)arr=str.split(separator);else if(str.trim()!=''){arr=new Array(1);arr[0]=str;}return arr;}

//disableRightClick();
function disableRightClick(e){var message='El click derecho no está permitido!';if(!document.rightClickDisabled){if(document.layers){document.captureEvents(Event.MOUSEDOWN);document.onmousedown=disableRightClick;}else document.oncontextmenu=disableRightClick;return document.rightClickDisabled=true;}if(document.layers || (document.getElementById && !document.all)){if(e.which==2||e.which==3)return false;}else return false;}

var navig_agt = navigator.userAgent.toLowerCase();
var navig_kqr;
var navig_fox;
var navig_ie5;
var navig_chr;
function checkBrowser(){navig_kqr=(navig_agt.indexOf("konqueror")!=-1);navig_fox=(navig_agt.indexOf("firefox")!=-1);navig_ie5=(navig_agt.indexOf("msie")!=-1);navig_chr=(navig_agt.indexOf("chrome")!=-1);}
checkBrowser();

function showStatusBar(msg){if(msg==undefined||msg==null)msg='';window.status=msg;return true;}
//hide status bar
if(document.layers)document.captureEvents(Event.MOUSEOVER | Event.MOUSEOUT | Event.MOUSEDOWN)
document.onmouseover=showStatusBar;
document.onmouseout=showStatusBar;
document.onmousedown=showStatusBar;

function setoverc(src,overc){src.setAttribute('tempClassName',src.className);src.className=overc;}
function setoutc(src,outc){src.className=src.getAttribute('tempClassName');src.removeAttribute('tempClassName');}

function showHide(id,forced){if(document.getElementById('panel'+id)){if(forced==undefined||forced==null){if(document.getElementById('panel'+id).style.display=='none'){document.getElementById('panel'+id).style.display='';if(document.getElementById('plus'+id))document.getElementById('plus'+id).style.display='none';if(document.getElementById('minus'+id))document.getElementById('minus'+id).style.display='';}else{document.getElementById('panel'+id).style.display='none';if(document.getElementById('plus'+id))document.getElementById('plus'+id).style.display='';if(document.getElementById('minus'+id))document.getElementById('minus'+id).style.display='none';}}else{document.getElementById('panel'+id).style.display=(forced)?'':'none';}}else if(document.getElementById(id)){document.getElementById(id).style.display=(document.getElementById(id).style.display=='none')?'':'none';}}

/*blinkId('htmlId','red','white',1000);*/
function blinkId(htmlId,colorOn,colorOff,delay){if(delay==undefined)delay=800;document.getElementById(htmlId).style.color=colorOn;timerOne=setTimeout('blinkId(\''+htmlId+'\',\''+colorOff+'\',\''+colorOn+'\','+delay+')',delay);}

function checkAll(formName,checkObjPrefixName,listSize,globalCheckObj,startIndex){if(startIndex==undefined)startIndex=0;for(i=startIndex;i<(listSize+startIndex);i++){if(eval('document.'+formName+'.'+checkObjPrefixName+i))eval('document.'+formName+'.'+checkObjPrefixName+i).checked=globalCheckObj.checked;}}
function checkOne(formName,checkObjPrefixName,listSize,currObj,startIndex){var chkd=currObj.checked;if(startIndex==undefined)startIndex=0;for(i=startIndex;i<(listSize+startIndex);i++){if(eval('document.'+formName+'.'+checkObjPrefixName+i))eval('document.'+formName+'.'+checkObjPrefixName+i).checked=false;}currObj.checked=chkd;}
/*jQuery Check All function: also fire click event if has it*/
function jqCheckAll(formId,chkObjPrefixName,gChkObj,trgClick){if(trgClick==undefined||trgClick==null)trgClick=true;var chk=$("input[name!="+gChkObj.name+"][name^="+chkObjPrefixName+"][type='checkbox']");chk.prop('checked',gChkObj.checked);var allChkd=gChkObj.checked;$.each(chk,function(){if(trgClick){$(this).click(function(evt){evt.stopPropagation();evt.preventDefault();});$(this).trigger('click');$(this).unbind('click');}if(!$(this).is(':checked'))allChkd=false;});gChkObj.checked=allChkd;}
function jqCheckOne(formId,chkObjPrefixName,currObj){var chkd=currObj.checked;var chk=$("input[name^="+chkObjPrefixName+"][type='checkbox']");chk.prop('checked',false);currObj.checked=chkd;}

function showSelectBoxes(trueFalse){var tagElements=document.getElementsByTagName('SELECT');for(var i=0;i<tagElements.length;i++)tagElements[i].style.visibility=(trueFalse)?'visible':'hidden';}

function setBAction(formName,actionValue){if(document.forms[formName]&&document.forms[formName].baction)document.forms[formName].baction.value=actionValue;}
function removeItem(fName,k){var rem='';rem = eval('document.'+fName+'.rem'+k).value;eval('document.'+fName+'.remove'+k).value=rem;setBAction(fName,rem);}

//Textarea maxLength attribute
function checkTextLength(obj){var maxLength=obj.getAttribute?parseInt(obj.getAttribute('maxLength')):0;var nLineBreaks=(obj.value.match(/\n/g)||[]).length;if(obj.value.length+nLineBreaks>maxLength)obj.value=obj.value.substring(0,maxLength-nLineBreaks);showTextCounter(obj,maxLength);}
function showTextCounter(obj,maxLength){var objCounter=document.getElementById(obj.name+'Counter');var nLineBreaks=(obj.value.match(/\n/g)||[]).length;var currLength='Actual: '+(obj.value.length+nLineBreaks);objCounter.innerHTML=(obj.value.length+nLineBreaks>=maxLength)?'<font color="red">'+currLength+'</font>':currLength;}
//Set Blank to given field names separated by comma from given form name
function setFormFieldsBlank(formName,fieldNames){var fields=null;if(fieldNames.indexOf(',')>=0)fields=fieldNames.split(',');else if(fieldNames.trim()!=''){fields=new Array(1);fields[0]=fieldNames;}for(i=0;i<fields.length;i++){if(fields[i]!=''&&eval('document.'+formName+'.'+fields[i]))eval('document.'+formName+'.'+fields[i]).value='';}}

//Used to replace % to url standard
function replacePercent(val){var oldValue=val.value;var regExp=/%/gi;val.value=oldValue.replace(regExp,'%25');return true;}

function setUploadFlag(objFlag){objFlag.value='1';}

/**
 * @argument sec - int in seconds
 * @argument displayTimer - boolean to display timer in given IDS
 * @argument displayTimerInIds - string ids of html elements. if more than one, separated by comma
 * @argument displayTimerMsg - string message to display in given IDS, where the word "sss" in the message will be replaced by the remaining time. If not given will show a default message.
 * @argument afterTimeout - string function to fire after the timeout ends
 * @displayTimerInTitle - boolean to display timer in title, if true add this function in the page
 *  function unload(){top.document.title=topTitle;}
 * @argument objName - string name of form object to store the remaining time
 **/
function timer(sec,displayTimer,displayTimerInIds,displayTimerMsg,afterTimeout,displayTimerInTitle,objName){if(displayTimer){if(displayTimerInIds!=undefined&&displayTimerInIds!=null&&displayTimerInIds.trim()!=''){var vIds=displayTimerInIds.split(',');for(i=0;i<vIds.length;i++)showTimer(vIds[i].trim(),sec,displayTimerMsg);}if(displayTimerInTitle!=undefined&&displayTimerInTitle)showTitle(sec,displayTimerMsg);if(objName!=undefined&&objName!=null&&objName!='')setObjTimer(sec,objName);}if(afterTimeout)setTimeout(afterTimeout,sec*1000);}
/**
 * @argument id - string id of html element
 * @argument currSec - int in current seconds
 * @argument msg - string message to display in given IDS, where the word "sss" in the message will be replaced by the remaining time
 **/
function showTimer(id,currSec,msg){if(id!=undefined&&id!=null&&id.trim()!=''){if(msg==undefined||msg==null||msg.trim()=='')msg='sss sec. to refresh';if(document.getElementById(id))document.getElementById(id).innerHTML=msg.replace('sss',seconds2timeFormat(--currSec));if(currSec>0)setTimeout('showTimer(\''+id+'\','+currSec+',\''+msg+'\')',1000);}}
/**
 * Window top frame title. References windowTitle from issi.properties
 **/
var _topWinTitle=(top.document.getElementById("_winTitle"))?top.document.getElementById("_winTitle").value:top.document.title;
/**
 * @argument currSec - int in current seconds
 * @argument msg - string message to display in given IDS, where the word "sss" in the message will be replaced by the remaining time
 **/
function showTitle(currSec,msg){if(msg==undefined||msg==null||msg.trim()=='')msg='sss sec. to refresh';top.document.title=msg.replace('sss',seconds2timeFormat(--currSec))+' | '+_topWinTitle;if(currSec>0)setTimeout('showTitle('+currSec+',\''+msg+'\')',1000);}
/**
 * @argument currSec - int in current seconds
 * @argument objName - string name of form object to store the remaining time
 **/
function setObjTimer(currSec,objName){if(document.getElementById(objName))document.getElementById(objName).value=--currSec;if(currSec>0)setTimeout('setObjTimer('+currSec+',\''+objName+'\')',1000);}
/**
 * @argument currSec - int seconds to format [hours:]minutes:seconds
 * @argument showHours - boolean display hours even if zero. If false and hour is not zero then it's do not apply
 **/
function seconds2timeFormat(currSec,showHours){if(showHours==undefined)showHours=false;var hour=parseInt(currSec/3600,10);var min=parseInt(currSec/60,10);var sec=currSec%60;return ((!showHours&&hour==0)?'':hour.toString().lpad(2,'0')+':')+min.toString().lpad(2,'0')+':'+sec.toString().lpad(2,'0')}
/**
 * @argument objId - string id of the html object to display the given value
 * @argument value - string value to display on the given html object id
 **/
function displayElementValue(objId,value){if(document.getElementById(objId))document.getElementById(objId).innerHTML=value;}

<!-- W I N D O W S -->
var displayScrollBar=true;
var resizable=true;
var displayLocationBar=true;
var displayStatusBar=true;
//Windows Size and Position
var winWidth=screen.availWidth*0.95;
var winHeight=screen.availHeight*0.75;
var winPosX=(screen.availWidth-winWidth)/2;
var winPosY=(screen.availHeight-winHeight)/2;
function getPopUpOptions(showScrollBars,isResizable,showLocation,showStatus,wWidth,wHeight,wPosX,wPosY){var opt='toolbar=no,directories=no,menubar=no';if(!typeof showScrollBars=='boolean')showScrollBars=false;opt+=',scrollbars='+((showScrollBars)?'yes':'no');if(!typeof isResizable=='boolean')isResizable=false;opt+=',resizable='+((isResizable)?'yes':'no');if(!typeof showLocation=='boolean')showLocation=false;opt+=',location='+((showLocation)?'yes':'no');if(!typeof showStatus=='boolean')showStatus=false;opt+=',status='+((showStatus)?'yes':'no');if(wWidth==undefined||wWidth==null||!typeof wWidth=='number')wWidth=winWidth;opt+=',width='+wWidth;if(wHeight==undefined||wHeight==null||!typeof wHeight=='number')wHeight=winHeight;opt+=',height='+wHeight;if(wPosX==undefined||wPosX==null)wPosX=(screen.availWidth-wWidth)/2;else if(!typeof wPosX=='number')wPosX=winPosX;opt+=',left='+wPosX;if(wPosY==undefined||wPosY==null)wPosY=(screen.availHeight-wHeight)/2;else if(!typeof wPosY=='number')wPosY=winPosY;opt+=',top='+wPosY;return opt;}
var scrWidth=screen.availWidth;
var scrHeight=screen.availHeight;
var _bodyWidth=600;
var _bodyHeight=400;
var _contentHeight=400;
if(location.pathname.indexOf('main.jsp')!=-1){setTimeout('resetBodySize()',50);}
function resetBodySize(){/*_bodyWidth=window.innerWidth!=null?window.innerWidth:document.body!=null?document.body.clientWidth:null;_bodyHeight=window.innerHeight!=null?window.innerHeight:document.body!=null?document.body.clientHeight:null;*/if(document.body&&document.body.offsetWidth){_bodyWidth=document.body.offsetWidth;_bodyHeight=document.body.offsetHeight;}if(document.compatMode=='CSS1Compat'&&document.documentElement&&document.documentElement.offsetWidth){_bodyWidth=document.documentElement.offsetWidth;_bodyHeight=document.documentElement.offsetHeight;}if(window.innerWidth&&window.innerHeight){_bodyWidth=window.innerWidth;_bodyHeight=window.innerHeight;}if(_bodyHeight!=null&&_bodyHeight>90)_contentHeight=_bodyHeight-90;/*40->menu,25->userDetail,25->footer*/resetContentHeight();}
function maximizeWin(win){if(win==undefined||win==null)win=window;win.moveTo(0,0);win.resizeTo(scrWidth,scrHeight);}
function resetContentHeight(){top.setHeight('content',top._contentHeight);}
function titleHeight(){return objHeight('_tblCommonTitle');}
function footerHeight(){return objHeight('_tblCommonFooter');}
function objHeight(objId){return (document.getElementById(objId))?document.getElementById(objId).offsetHeight:0;}

window.onresize=function(){resizeFrame()};
function resizeFrame(){/*override function as required*/}
function resetContainerHeight(containerObj,currHeight,minHeight,fixedHeight,xtraHeight){var availHeight=100;/*default minimum height*/if(minHeight!=undefined&&minHeight!=null&&!isNaN(minHeight)&&availHeight<minHeight)availHeight=minHeight;var usedHeight=titleHeight()+footerHeight();if(currHeight!=undefined&&currHeight!=null&&!isNaN(currHeight)&&currHeight>0)usedHeight+=currHeight;resetBodySize();if(_bodyHeight>usedHeight&&(_bodyHeight-usedHeight)>availHeight)availHeight=_bodyHeight-usedHeight;var f=document.getElementById(containerObj.id);if(f==null)f=document.getElementById(containerObj.name);if(fixedHeight==undefined||fixedHeight==null||isNaN(fixedHeight)||fixedHeight<=0)fixedHeight=1;var fHeight=availHeight;if(fixedHeight<=1)fHeight=availHeight*fixedHeight;else if(fixedHeight>availHeight)fHeight=availHeight;else fHeight=fixedHeight;if(xtraHeight==undefined||xtraHeight==null)xtraHeight=15;f.style.height=(fHeight-xtraHeight)+'px';}

var win;
var childArray=new Array();
function getWinName(url){var name=(url.indexOf('?')>0)?url.substring(0,url.indexOf('?')):url;name=name.substring(name.lastIndexOf('/')+1);name=name.substring(0,name.indexOf('.'));return name;}
function closeChildWin(){var winArray=(useTopWinArray)?top.childArray:childArray;for(i=0;i<winArray.length;i++){try{winArray[i].close();}catch(e){/*alert('Window is already closed!');*/}}if(useTopWinArray)top.childArray=new Array();else childArray=new Array();}
var closeChild=true;
window.onunload=function(){if(window.unload)unload();if(closeChild)closeChildWin();}
function abrir_ventana_esc(url,newWinName){if(newWinName==undefined||newWinName==null)newWinName=getWinName(unescape(url));openWin(unescape(url),newWinName);}
function abrir_ventana(url,newWinName){if(newWinName==undefined||newWinName==null)newWinName=getWinName(url);openWin(url,newWinName);}
function abrir_ventana1(url,newWinName){if(newWinName==undefined||newWinName==null)newWinName=getWinName(url);openWin(url,newWinName);}
function abrir_ventana2(url,newWinName){if(newWinName==undefined||newWinName==null)newWinName=getWinName(url);openWin(url,newWinName);}
function abrir_ventana3(url,newWinName){if(newWinName==undefined||newWinName==null)newWinName=getWinName(url);openWin(url,newWinName);}
function abrir_ventana4(url,newWinName){if(newWinName==undefined||newWinName==null)newWinName=getWinName(url);openWin(url,newWinName);}
function abrir_ventana5(url,newWinName){if(newWinName==undefined||newWinName==null)newWinName=getWinName(url);openWin(url,newWinName);}
function openWin(url,winName,opts){if(opts==undefined||opts==null)opts=getPopUpOptions(displayScrollBar,resizable,displayLocationBar,displayStatusBar);win=window.open(url+((url.indexOf('?')==-1)?'?':'&')+'__ct='+(new Date()).getTime(),winName,opts);maximizeWin(win);top.childArray[top.childArray.length]=win;return win;}
//function openWin(url,winName,opts){win=window.open(url,winName,opts);win.moveTo(0,0);win.resizeTo(scrWidth,scrHeight);top.childArray[top.childArray.length]=win;return win;}
function closeWin(){window.close();}
function showImage(imgPath,winTitle,title,description){var min=100;var max=400;if(imgPath==undefined||imgPath==null||imgPath.trim()==''){imgPath='../images/image_not_found.jpg';winTitle='Image Not Found!';}var img=new Image();img.src=imgPath;var p=100;if(img.height>img.width&&img.height>max){p=(max*100)/img.height;}else{p=(max*100)/img.width;}iWidth=(img.width*p)/100;iHeight=(img.height*p)/100;if(iWidth<min)iWidth=min;else if(iWidth>max)iWidth=max;if(iHeight<min)iHeight=min;else if(iHeight>max)iHeight=max;imgWin=window.open('','imgWin',getPopUpOptions(false,false,false,false,iWidth+50,iHeight+75));if(winTitle==undefined||winTitle==null)winTitle='Image';if(description==undefined||description==null||description.trim()=='')description=imgPath.substr(imgPath.lastIndexOf('/')+1);imgWin.document.write('<html><head><title>'+winTitle+'</title></head><body bgcolor="#000000" text="#ffffcc"><center>');if(title!=undefined&&title!=null&&title.trim()!='')imgWin.document.write('<font face="Arial, Helvetica, sans-serif" size="4"><b>'+title+'</b></font>');imgWin.document.write('<p><img src="'+imgPath+'" height="'+iHeight+'" width="'+iWidth+'" alt="Image not found"><p>');imgWin.document.write('<font face="Arial, Helvetica, sans-serif">'+description+' ['+img.width+' X '+img.height+']</font>');imgWin.document.write('</center></body></html>');imgWin.document.close();imgWin.focus();}
function hideImage(){imgWin.close();}//'width=400,height=400,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,screenX=0,screenY=0,left='+(screen.availWidth-400)/2+',top='+(screen.availHeight-400)/2


<!-- I F R A M E S -->
//function adjustIFrameSize(iframeWindow,fixedHeight){if($.browser.mozilla){var f=document.getElementById(iframeWindow.name);if(f)f.style.height=((fixedHeight==undefined||fixedHeight==null)?f.contentWindow.document.body.offsetHeight:fixedHeight)+'px';}else if($.browser.webkit){var f=document.getElementById(iframeWindow.name);if(f){var h=0;if(fixedHeight==undefined||fixedHeight==null){var tList=$('#'+f.name).contents().find('body > table');for(i=0;i<$(tList).size();i++){h+=$(tList[i]).height();}tList=$('#'+f.name).contents().find('body > form > table');for(i=0;i<$(tList).size();i++){h+=$(tList[i]).height();}}else h=fixedHeight;f.style.height=h+'px';}}else if(document.all){var f=document.all[iframeWindow.name];if(f){if(iframeWindow.document.compatMode&&iframeWindow.document.compatMode!='BackCompat')f.style.height=((fixedHeight==undefined||fixedHeight==null)?iframeWindow.document.documentElement.scrollHeight:fixedHeight)+'px';else f.style.height=((fixedHeight==undefined||fixedHeight==null)?iframeWindow.document.body.scrollHeight:fixedHeight)+'px';}}}
function adjustIFrameSize(iframeWindow,fixedHeight){if(iframeWindow!=null&&iframeWindow!=undefined&&iframeWindow.name!=''){var f=document.getElementById(iframeWindow.name);if(f!=null&&f!=undefined){var xtra=29;f.style.height=(f.contentWindow.document.body.offsetHeight+xtra)+'px';}}}
//called from iframe
function newHeight(parentHeight,forceHeight){ if (!("noNewHeight" in window)) {if(forceHeight==null||forceHeight==undefined)forceHeight=false;if(!forceHeight&&parent.xHeight!=null&&parent.xHeight!=undefined)return;var availHeight=null;if(parentHeight!=undefined&&parentHeight!=null){parent.resetBodySize();if(parent._bodyHeight>parentHeight&&(parent._bodyHeight-parentHeight)>=50)availHeight=parent._bodyHeight-parentHeight;}if(parent!=window)if(parent.adjustIFrameSize)parent.adjustIFrameSize(window,availHeight);}}
//called in parent frameborder="0" border="0" height="0" scrolling="yes"
function resetFrameHeight(frame,currHeight,minHeight,fixedHeight,xtraHeight){resetContainerHeight(frame,currHeight,minHeight,fixedHeight,xtraHeight);}
//working with tab, adjust iframe height. used in tab-view.js
function adjustHeight(index){if(window.frames['itemFrame'+index])window.frames['itemFrame'+index].newHeight();}
function setHeight(id,xHeight){var xtraHeight=21;checkBrowser();if(navig_fox)xtraHeight=29;if(document.getElementById(id))document.getElementById(id).style.Height=(xHeight-xtraHeight);}
function setFrameSrc(frameId,src){var frameObj=document.getElementById(frameId);frameObj.src=src;}
function adjustDivWithIFrameHeight(id){newHeight();/*if(parent.document.getElementById(id)){parent.setHeight(id,document.body.scrollHeight);}*/}



<!-- A J A X H A N D L E R -->
//Array index starts from 0. These three methods can be used when ajaxHandler function return more than one column (columns separator "|") or row (rows separator "~") .
function splitRows(str){var row=null;if(str.indexOf('~')>=0)row=str.split('~');else if(str.trim()!=''){row=new Array(1);row[0]=str;}return row;}
function splitCols(str){var col=null;if(str.indexOf('|')>=0)col=str.split('|');else if(str.trim()!=''){col=new Array(1);col[0]=str;}return col;}
function splitRowsCols(str){var row=splitRows(str);var rowsCols=null;if(row!=null){rowsCols=new Array(row.length);for(i=0;i<row.length;i++){var col=splitCols(row[i]);if(col!=null)rowsCols[i]=col;}}else{var col=splitCols(str);if(col!=null){rowsCols=new Array();rowsCols[0]=col;}}return rowsCols;}

function httpRequestInstance(mimeType){if(mimeType==undefined||mimeType==null)mimeType='text/html';var httpRequest;if(window.XMLHttpRequest){/*Mozilla,Safari,...*/httpRequest=new XMLHttpRequest();if(httpRequest.overrideMimeType)httpRequest.overrideMimeType(mimeType);}else if(window.ActiveXObject){/*IE*/try{httpRequest=new ActiveXObject('Msxml2.XMLHTTP');}catch(e){try{httpRequest=new ActiveXObject('Microsoft.XMLHTTP');}catch(e){alert('httpRequest instance failed');}}}if(!httpRequest){alert('Giving up :( Cannot create an XMLHTTP instance');httpRequest=null;}return httpRequest;}

/*
This function returns true and it sends an alert message to the user, if the any records match with the given filter, otherwise returns false.
- context:       			(Required) application context name
- mode:          			(Required) creation (add) or edition (edit) mode. if add mode then validate immediatly, otherwise validate only if the values has been changed
- obj:           			(Required) form object to validate
- tables:        			(Required) tables names separated by comma (if more than one table)
- filters:       			(Required) query's where segment, include new value (from form object) filter
- oldValue:      			(Required) form object old value (from database)
- resetTimeout:  			(Optional) reset application inactive time
- notLoggedInAlert: 	(Optional) returns session expired or not logged in message
*/
function duplicatedDBData(context,mode,obj,tables,filters,oldValue,resetTimeout,notLoggedInAlert){if(resetTimeout==undefined||resetTimeout==null)resetTimeout=true;if(notLoggedInAlert==undefined||notLoggedInAlert==null)notLoggedInAlert=false;if(context.trim()!=''&&mode.trim()!=''&&obj&&tables.trim()!=''&&filters.trim()!=''){if(oldValue==undefined)return false;var newValue=obj.value;if(!(mode.toLowerCase()=='edit'&&newValue==oldValue)){var rv=ajaxHandler(context+'/ajax','returnFields='+encodeURIComponent(Aes.Ctr.encrypt('count(*)','returnFields',256))+'&tables='+encodeURIComponent(Aes.Ctr.encrypt(tables,'tables',256))+'&filters='+encodeURIComponent(Aes.Ctr.encrypt(filters,'filters',256))+'&resetTimeout='+encodeURIComponent(resetTimeout)+'&notLoggedInAlert='+encodeURIComponent(notLoggedInAlert));var nRecs=(rv.trim()==''||isNaN(rv))?-1:parseInt(rv,10);if(nRecs<0){CBMSG.warning('El valor introducido no es válido!');obj.focus();return true;}else if(nRecs==0)return false;else{CBMSG.warning('El valor introducido ya existe!');obj.focus();return true;}}}return false;}

/*
This function returns true if data is found, otherwise returns false, given the following parameters:
- context:       			(Required) application context name
- tables:        			(Required) tables names separated by comma (if more than one table)
- filters:       			(Optional) query's where segment
- xtra:          			(Optional) others query's segments (group by, order by)
- resetTimeout:  			(Optional) reset application inactive time
- notLoggedInAlert: 	(Optional) returns session expired or not logged in message
*/
function hasDBData(context,tables,filters,xtra,resetTimeout,notLoggedInAlert){if(resetTimeout==undefined||resetTimeout==null)resetTimeout=true;if(notLoggedInAlert==undefined||notLoggedInAlert==null)notLoggedInAlert=false;if(context.trim()!=''&&tables.trim()!=''){if(filters==undefined)filters='';if(xtra==undefined)xtra='';var rv=ajaxHandler(context+'/ajax','returnFields='+encodeURIComponent(Aes.Ctr.encrypt('count(*)','returnFields',256))+'&tables='+encodeURIComponent(Aes.Ctr.encrypt(tables,'tables',256))+'&filters='+encodeURIComponent(Aes.Ctr.encrypt(filters,'filters',256))+'&xtra='+encodeURIComponent(Aes.Ctr.encrypt(xtra,'xtra',256))+'&resetTimeout='+encodeURIComponent(resetTimeout)+'&notLoggedInAlert='+encodeURIComponent(notLoggedInAlert));var nRecs=(rv.trim()==''||isNaN(rv))?-1:parseInt(rv,10);if(nRecs<0){alert('El valor introducido no es válido!');return null;}else if(nRecs==0)return false;else return true;}return false;}

/*
This function returns a String value, given the following parameters:
- context:       			(Required) application context name
- returnFields:  			(Required) fields values separated by comma (if more than one field)
- tables:        			(Required) tables names separated by comma (if more than one table)
- filters:       			(Optional) query's where segment
- xtra:          			(Optional) others query's segments (group by, order by)
- resetTimeout:  			(Optional) reset application inactive time
- notLoggedInAlert: 	(Optional) returns session expired or not logged in message
*/
function getDBData(context,returnFields,tables,filters,xtra,resetTimeout,notLoggedInAlert){if(resetTimeout==undefined||resetTimeout==null)resetTimeout=true;if(notLoggedInAlert==undefined||notLoggedInAlert==null)notLoggedInAlert=false;var retVal='';if(context.trim()!=''&&returnFields.trim()!=''&&tables.trim()!=''){if(filters==undefined)filters='';if(xtra==undefined)xtra='';retVal=ajaxHandler(context+'/ajax','returnFields='+encodeURIComponent(Aes.Ctr.encrypt(returnFields,'returnFields',256))+'&tables='+encodeURIComponent(Aes.Ctr.encrypt(tables,'tables',256))+'&filters='+encodeURIComponent(Aes.Ctr.encrypt(filters,'filters',256))+'&xtra='+encodeURIComponent(Aes.Ctr.encrypt(xtra,'xtra',256))+'&resetTimeout='+encodeURIComponent(resetTimeout)+'&notLoggedInAlert='+encodeURIComponent(notLoggedInAlert));}return retVal;}

/*
This function returns true if the query is executed successfully, otherwise returns false, given the following parameters:
- context:       			(Required) application context name
- executeQuery:  			(Required) query to be executed
- tables:        			(Optional) tables names to lock separated by comma (if more than one table)
- resetTimeout:  			(Optional) reset application inactive time
- notLoggedInAlert: 	(Optional) returns session expired or not logged in message
*/
function executeDB(context,executeQuery,tables,resetTimeout,notLoggedInAlert){if(resetTimeout==undefined||resetTimeout==null)resetTimeout=true;if(notLoggedInAlert==undefined||notLoggedInAlert==null)notLoggedInAlert=false;var retVal='';if(context.trim()!=''&&executeQuery.trim()!=''){if(tables==undefined)tables='';retVal=ajaxHandler(context+'/ajax','executeQuery='+encodeURIComponent(Aes.Ctr.encrypt(executeQuery,'executeQuery',256))+'&tables='+encodeURIComponent(Aes.Ctr.encrypt(tables,'tables',256))+'&resetTimeout='+encodeURIComponent(resetTimeout)+'&notLoggedInAlert='+encodeURIComponent(notLoggedInAlert));}if(retVal.length==0)return false;else return true;}

/*
This generic function returns a String value from AjaxHandler, given the url that contains the parameters to create the query.
If the query returns more that one row, it will be separated by '~'.
If the query returns more that one column, it will be separated by '|'.
*/
function ajaxHandler(url,params,method){
  var xmlDoc='';
  if(method==undefined||method==null)method='GET';
  if(url.trim()!=''){
    var httpRequest=httpRequestInstance();
    if(httpRequest==null)alert('XMLHTTP instance is null!');
    else{
      if(method=='GET')
      {
        if(params==undefined||params==null)params='';
        else if(params.indexOf('?')==0)params='&'+params.substr(1);
        else if(params.indexOf('?')!=0)params='&'+params;
        params='?_cUrl='+encodeURIComponent(Aes.Ctr.encrypt(location.pathname,'_cUrl',256))+'&rt='+encodeURIComponent((new Date()).getTime())+params;
        httpRequest.open('GET',url+params,false);
        httpRequest.setRequestHeader("X-Length",params.length-1);
        httpRequest.send(null);
      }
      else if(method=='POST')
      {
        if(params==undefined||params==null)params='';
        httpRequest.open(method,url,false);
        /*Send the proper header information along with the request*/
        httpRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
        //httpRequest.setRequestHeader("Content-Length",params.length);
        //httpRequest.setRequestHeader("Connection","close");
        httpRequest.setRequestHeader("X-Length",params.length);
        httpRequest.send(params);
      }
//      httpRequest.onreadystatechange=function(){/*Call a function when the state changes.*/
//        if(httpRequest.readyState==4&&httpRequest.status==200){
          xmlDoc=httpRequest.responseText;
//        }
//      }
    }
  }
  return xmlDoc;
}


function ajaxHandlerNoXtra(url,params,method){
  var xmlDoc='';
  if(method==undefined||method==null)method='GET';
  if(url.trim()!=''){
    var httpRequest=httpRequestInstance();
    if(httpRequest==null)alert('XMLHTTP instance is null!');
    else{
      if(method=='GET')
      {
        if(params==undefined||params==null)params='';
        else if(params.indexOf('?')==0)params='&'+params.substr(1);
        else if(params.indexOf('?')!=0)params='&'+params;
        //if(httpRequest.open('GET',url+params,false)){
			httpRequest.open('GET',url+params,false);//}
		//else 
		
        httpRequest.setRequestHeader("X-Length",params.length-1);
        httpRequest.send(null);//getAllResponseHeaders());
      }
      else if(method=='POST')
      {
        if(params==undefined||params==null)params='';
        httpRequest.open(method,url,false);
        httpRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
        httpRequest.setRequestHeader("X-Length",params.length);
        httpRequest.send(params);
      }
	  xmlDoc=httpRequest.responseText;
    }
  }
  return xmlDoc;
}

/*
xmlSource:
  XML location path
idSelect:
  HTML Form Object ID
defaultValue:
  Default selected option. If blank, selected option will be the first one
optTagValue & optTagLabel:
  XML Tag Name for select option value (optTagValue) and option label (optTagLabel)
keyValue & key Tag:
  if any is blank then XML will not be filtered by XML Tag Name (keyTag) and XML Tag Name Value (keyValue)
firstOption:
  -1=Choose, 0=Without First Option, 1=All
*/
function loadXML(xmlSource,idSelect,defaultValue,optTagValue,optTagLabel,keyValue,keyTag,firstOption)
{
  if (keyValue == undefined) keyValue = '';
  if (keyTag == undefined) keyTag = '';
  if (firstOption == undefined) firstOption = '';

  var httpRequest=httpRequestInstance('text/xml');
  if(httpRequest==null){alert('XMLHTTP instance is null!');return false;}

  httpRequest.onreadystatechange = function()
  {
    if (httpRequest.readyState == 4)
    {
      if (httpRequest.status == 200)
      {
        var xmlDoc = httpRequest.responseXML;
        genSelectOptions(xmlDoc, idSelect, defaultValue, optTagValue, optTagLabel, keyValue, keyTag, firstOption);
      }
    }
  }

  httpRequest.open('GET', xmlSource, true);
  httpRequest.send(null);
}

function getRadioButtonValue(object){
  var returnValue='';
  if(object!=undefined&&object!=null){
    if(object.length==undefined)returnValue=object.value;
    else{
      for(i=0;i<object.length;i++){
        if(object[i].checked){
          returnValue=object[i].value;
          break;
        }
      }
    }
  }
  return returnValue;
}

function checkRadioButton(object,i){
  if(object.length==undefined)object.checked=true;
  else object[i].checked=true;
}

function genSelectOptions(xmlDoc, idSelect, defaultValue, optTagValue, optTagLabel, keyValue, keyTag, firstOption)
{
  var optTagTitle = 'TITLE_COL';
  var index = 0;
  var selectedIndex = 0;
  if (firstOption == undefined) firstOption = '';

  nodes = xmlDoc.getElementsByTagName('ROW');
  var selLength = deleteSelectMenu(idSelect);
  while(selLength > 0)
  {
    selLength = deleteSelectMenu(idSelect);
  }

  if (selLength > 0 || nodes.length == 0)
  {
    var opt = new Option('* * * * * * * * * *','');
    document.getElementById(idSelect).options[0] = opt;
    document.getElementById(idSelect).options[0].title = 'NO DISPONIBLE / NOT AVAILABLE';
    index = 1;
  }
  else
  {
    if (firstOption == 'A')
    {
      var opt = new Option('- ALL -','');
      document.getElementById(idSelect).options[0] = opt;
      index = 1;
    }
    else if (firstOption == 'C')
    {
      var opt = new Option('- CHOOSE -','');
      document.getElementById(idSelect).options[0] = opt;
      index = 1;
    }
    else if (firstOption == 'T')
    {
      var opt = new Option('- TODOS -','');
      document.getElementById(idSelect).options[0] = opt;
      index = 1;
    }
    else if (firstOption == 'S')
    {
      var opt = new Option('- SELECCIONAR -','');
      document.getElementById(idSelect).options[0] = opt;
      index = 1;
    }
  }

  if (selLength == 0 && nodes.length > 0)
  {
    if (keyTag == '')
    {
      for (i=0; i<nodes.length; i++)
      {
//        var selected = false;
        if (nodes[i].getElementsByTagName(optTagValue)[0].firstChild.nodeValue == defaultValue)
        {
//          selected = true;
          selectedIndex = index + i;
        }

        var opt = new Option(nodes[i].getElementsByTagName(optTagLabel)[0].firstChild.nodeValue, nodes[i].getElementsByTagName(optTagValue)[0].firstChild.nodeValue);
//        opt.selected = selected;
        document.getElementById(idSelect).options[index + i] = opt;
        if (nodes[i].getElementsByTagName(optTagTitle)[0]) document.getElementById(idSelect).options[index + i].title = nodes[i].getElementsByTagName(optTagTitle)[0].firstChild.nodeValue;
        else if (nodes[i].getElementsByTagName(optTagLabel)[0]) document.getElementById(idSelect).options[index + i].title = nodes[i].getElementsByTagName(optTagLabel)[0].firstChild.nodeValue;
      }

      if (selectedIndex != 0)
      {
        document.getElementById(idSelect).options[selectedIndex].selected = true;
      }
    }
    else if (keyValue != '' && keyTag != '')
    {
      var optionIndex = 0;
      for (i=0; i<nodes.length; i++)
      {
        if (nodes[i].getElementsByTagName(keyTag)[0].firstChild.nodeValue == keyValue)
        {
//          var selected = false;
          if (nodes[i].getElementsByTagName(optTagValue)[0].firstChild.nodeValue == defaultValue)
          {
//            selected = true;
            selectedIndex = index + optionIndex;
          }

          var opt = new Option(nodes[i].getElementsByTagName(optTagLabel)[0].firstChild.nodeValue, nodes[i].getElementsByTagName(optTagValue)[0].firstChild.nodeValue);
//          opt.selected = selected;
          document.getElementById(idSelect).options[index + optionIndex] = opt;

          if (nodes[i].getElementsByTagName(optTagTitle)[0]) document.getElementById(idSelect).options[index + optionIndex].title = nodes[i].getElementsByTagName(optTagTitle)[0].firstChild.nodeValue;
          else if (nodes[i].getElementsByTagName(optTagLabel)[0]) document.getElementById(idSelect).options[index + optionIndex].title = nodes[i].getElementsByTagName(optTagLabel)[0].firstChild.nodeValue;
          optionIndex++;
        }
      }

      if (optionIndex == 0)
      {
        if(firstOption=='')
        {
          var opt = new Option('* * * * * * * * * *','');
          document.getElementById(idSelect).options[0] = opt;
          document.getElementById(idSelect).options[0].title = 'NO DISPONIBLE / NOT AVAILABLE';
          index = 1;
        }
      }
      else if (selectedIndex != 0)
      {
        document.getElementById(idSelect).options[selectedIndex].selected = true;
      }
    }
  }

  xmlDoc = null;
}

function deleteSelectMenu(idSelect){var selectMenu=document.getElementById(idSelect);var selLength=selectMenu.length;for(j=0;j<selLength;j++){selectMenu.remove(j);}return selectMenu.length;}

//function showHideDateFormat(divObj,displayFlag,format,msg,resetHeight){if(resetHeight==undefined||resetHeight==null)resetHeight=false;document.getElementById(divObj).style.display=displayFlag;document.getElementById(divObj).innerHTML=' Formato: "'+format+'" Ejemplo: "'+msg+'"';if(resetHeight&&typeof eval('newHeight')=='function'){newHeight();if(resetHeight&&typeof eval('parent.newHeight')=='function')parent.newHeight();}}

function showHideDateFormat(divObj,displayFlag,format,msg,resetHeight){if(resetHeight&&typeof eval('newHeight')=='function'){newHeight();if(resetHeight&&typeof eval('parent.newHeight')=='function')parent.newHeight();}}

function checkDateFormat(obj, event)
{
//  alert(event.keyCode);
  if (event.keyCode==8 || event.keyCode==46) return false; //delete or backspace


  var x = document.getElementById(obj).value;
  var y = '';

  var firstIndex = x.indexOf('/');
  var lastIndex = -1;
  if (firstIndex != x.lastIndexOf('/')) lastIndex = x.lastIndexOf('/');

  if (x.length == 2)
  {
    y = x.substring(0,2);

    if (isNaN(y) || parseInt(y,10) > 31 || parseInt(y,10) < 1)
    {
      alert('Ingrese un valor numerico entre 1 al 31!');
      document.getElementById(obj).value = '';
    }
    else if (firstIndex == -1) document.getElementById(obj).value = x + '/';
  }
  else if (x.length == 5)
  {
    y = x.substring(3,5);

    if (isNaN(y) || parseInt(y,10) > 12 || parseInt(y,10) < 1)
    {
      alert('Ingrese un valor numerico entre 1 al 12!');
      document.getElementById(obj).value = x.substring(0,3);
    }
    else if (lastIndex == -1) document.getElementById(obj).value = x + '/';

  }
  else if (x.length == 10)
  {
    y = x.substring(6,10);
    if (isNaN(y) || parseInt(y,10) < 1000)
    {
      alert('Ingrese un valor numerico de 4 dígitos para el año. Ejemplo: 2008 o 2007');
      document.getElementById(obj).value = x.substring(0,6);
    }
  }
}

function isValidateDate(strValue,format)
{
  var objRegExp=/^\d{2}(\-|\/)\d{2}(\-|\/)\d{4}$/
  if(format==undefined||format==null||format.trim()=='')format='dd/mm/yyyy';
  var dayIndex=0;
  var monthIndex=1;
  var yearIndex=2;
  if(format.trim()!='')
  {
    var pattern='^'+format+'$';
    pattern=replaceAll(pattern,'dd','\\d{2}');
    pattern=replaceAll(pattern,'mm','\\d{2}');
    pattern=replaceAll(pattern,'yyyy','\\d{4}');
    pattern=replaceAll(pattern,'hh12','(0[1-9]|1[0-2])');
    pattern=replaceAll(pattern,'hh24','([0-1]\\d{1}|2[0-3])');
    pattern=replaceAll(pattern,'mi','[0-5]\\d{1}');
    pattern=replaceAll(pattern,'ss','[0-5]\\d{1}');
    if(format.indexOf('am')!=-1)pattern=replaceAll(pattern,'am','([AM|PM|am|pm]{2,2})');
    else if(format.indexOf('pm')!=-1)pattern=replaceAll(pattern,'pm','([AM|PM|am|pm]{2,2})');
    objRegExp=new RegExp(pattern,'');
    //alert(objRegExp);
  }
  if(objRegExp.test(strValue))
  {
    if(format.indexOf('dd')==-1&&format.indexOf('mm')==-1&&format.indexOf('yyyy')==-1)return true;
    var strSeparator=strValue.substring(2,3)
    var arrayDate=strValue.split(strSeparator);
    //create a lookup for months not equal to Feb.
    var arrayLookup={'01':31,'03':31,'04':30,'05':31,'06':30,'07':31,'08':31,'09':30,'10':31,'11':30,'12':31}
    var intDay=parseInt(arrayDate[dayIndex],10);
    var intMonth=parseInt(arrayDate[monthIndex],10);
    if(intMonth==2)
    {
      var intYear=parseInt(arrayDate[yearIndex]);
      if(intDay>0&&intDay<29)return true;
      else if(intDay==29)if((intYear%4==0)&&(intYear%100!=0)||(intYear%400==0))return true;
    }
    //check if month value and day value agree
    else if(arrayLookup[arrayDate[monthIndex]]!=null)if(intDay<=arrayLookup[arrayDate[monthIndex]]&&intDay!=0)return true;//found in lookup table, good date
  }
  return false;//any other values, bad date
}

function formatCurrency(num,dec){
if(dec==null || dec=='') dec = 2;
var zero='';
for(i=0;i<dec;i++){
  zero+='0';
}
var x = parseInt((1+zero));
num = num.toString().replace(/\$|\,/g,'');
if(isNaN(num)) num = "0";
sign = (num == (num = Math.abs(num)));
num = Math.floor(num*x+0.50000000001);
cents = (num%x);
num = Math.floor(num/x).toString();
if(cents<10)
cents = "0" + cents;
for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++){
  num = num.substring(0,num.length-(4*i+3))+','+num.substring(num.length-(4*i+3));
}
return (((sign)?'':'-') + /*'$' +*/ num + '.' + cents);
}

function setChecked(field, chk){
  if(isNaN(field.value)){
    CBMSG.warning('Introduzca valores Numéricos!');
    field.value = 0;
  } else {
    if(field.value!='' && field.value != 0 && chk) chk.checked = true;
    else if(chk) chk.checked = false;
  }
}

function getInvDisponible(context, cia, almacen, flia, clase, codigo){
  var sqlWhere ='';
  var disponible  = 0.00; if(almacen==''||almacen=='null')CBMSG.warning('Codigo de Almacen invalido!!. Seleccione almacen'); else {
    sqlWhere = ' compania = '+cia+' and codigo_almacen = '+almacen;
    //if(flia !='' && flia !=null){sqlWhere +=' and art_familia = '+flia;}
    //if(clase !='' && clase !=null){sqlWhere +=' and art_clase = '+clase;}
    var _disponible = getDBData(context, 'nvl(disponible, 0) disponible', 'tbl_inv_inventario',sqlWhere+ ' and cod_articulo= '+codigo,'') || '0';
    disponible  = parseFloat(_disponible,10);

}
    return disponible;
}

function getMsg(context, clientIdentifier){
  var msg = getDBData(context, 'message', 'tbl_par_messages', 'client_identifier = \''+clientIdentifier+'\'','');
  if(executeDB(context,'call sp_par_del_message(\''+clientIdentifier+'\')',''))
  return msg;
}

function playSoundObjId(id){var sound=document.getElementById(id);try{/**RealPlayer**/sound.DoPlay();}catch(e){try{/**WindowsMedia/Quicktime**/sound.Play();}catch(e){CBMSG.warning('No sound support!');}}}
function stopSoundObjId(id){var sound=document.getElementById(id);try{sound.Stop();}catch(e){CBMSG.warning('Can not stop sound!');}}
function replaySound(id,milis){setTimeout('replaySound(\''+id+'\','+milis+')',milis);playSoundObjId(id);}
function replaceAll(txt, replace, with_this) {  return txt.replace(new RegExp(replace, 'g'),with_this);}

function getFlagCds(context, cds)
{
  var x = '';
  if(cds!=''){
    x = getDBData(context, 'nvl(flag_cds, \'-1\') flag_cds','tbl_cds_centro_servicio','estado = \'A\' and codigo = '+cds,'');
  }
  return x;
}
/**
 * Increase/Decrease day value to given date
 *
 * @argument baseDate - string of base date with format dd/mm/yyyy
 * @argument nDays - int number of days to increase (positive) or decrease (negative)
 * @argument minDate - string of minimum date with format dd/mm/yyyy
 * @argument maxDate - string of maximum date with format dd/mm/yyyy
 **/
function addDays(baseDate,nDays,minDate,maxDate){var newDate=baseDate;if(baseDate.trim()!=''&&isValidateDate(baseDate,'dd/mm/yyyy')){var tempDate=new Date(baseDate.substr(6),parseInt(baseDate.substr(3,2),10)-1,baseDate.substr(0,2));tempDate.setDate(tempDate.getDate()+nDays);var valid=true;if(minDate!=undefined&&minDate!=null&&minDate.trim()!=''&&isValidateDate(minDate,'dd/mm/yyyy')){var tempMinDate=new Date(minDate.substr(6),parseInt(minDate.substr(3,2),10)-1,minDate.substr(0,2));if(tempDate<=tempMinDate){top.CBMSG.warning('La fecha no puede ser menor a '+minDate);valid=false;}}if(maxDate!=undefined&&maxDate!=null&&maxDate.trim()!=''&&isValidateDate(maxDate,'dd/mm/yyyy')){var tempMaxDate=new Date(maxDate.substr(6),parseInt(maxDate.substr(3,2),10)-1,maxDate.substr(0,2));if(tempDate>=tempMaxDate){top.CBMSG.warning('La fecha no puede ser mayor a '+maxDate);valid=false;}}if(valid)newDate=tempDate.getDate().toString().lpad(2,'0')+'/'+(tempDate.getMonth()+1).toString().lpad(2,'0')+'/'+tempDate.getFullYear();}return newDate;}
/**
 * Increase/Decrease month value to given date
 *
 * @argument baseDate - string of base date with format dd/mm/yyyy
 * @argument nMonths - int number of months to increase (positive) or decrease (negative)
 * @argument minDate - string of minimum date with format dd/mm/yyyy
 * @argument maxDate - string of maximum date with format dd/mm/yyyy
 **/
function addMonths(baseDate,nMonths,minDate,maxDate){var newDate=baseDate;if(baseDate.trim()!=''&&isValidateDate(baseDate,'dd/mm/yyyy')){var baseYear=baseDate.substr(6);var baseMonth=parseInt(baseDate.substr(3,2),10)-1;var baseDay=baseDate.substr(0,2);var tempDate=new Date(baseYear,baseMonth,baseDay);tempDate.setMonth(tempDate.getMonth()+nMonths);if(Math.abs(baseMonth-tempDate.getMonth())!=1){tempDate=new Date(baseYear,baseMonth+((nMonths>0)?2:0),1);tempDate.setDate(tempDate.getDate()-1);}var valid=true;if(minDate!=undefined&&minDate!=null&&minDate.trim()!=''&&isValidateDate(minDate,'dd/mm/yyyy')){var tempMinDate=new Date(minDate.substr(6),parseInt(minDate.substr(3,2),10)-1,minDate.substr(0,2));if(tempDate<=tempMinDate){top.CBMSG.warning('La fecha no puede ser menor a '+minDate);valid=false;}}if(maxDate!=undefined&&maxDate!=null&&maxDate.trim()!=''&&isValidateDate(maxDate,'dd/mm/yyyy')){var tempMaxDate=new Date(maxDate.substr(6),parseInt(maxDate.substr(3,2),10)-1,maxDate.substr(0,2));if(tempDate>=tempMaxDate){top.CBMSG.warning('La fecha no puede ser mayor a '+maxDate);valid=false;}}if(valid)newDate=tempDate.getDate().toString().lpad(2,'0')+'/'+(tempDate.getMonth()+1).toString().lpad(2,'0')+'/'+tempDate.getFullYear();}return newDate;}
/**
 * Display date in text instead of date format
 *
 * @argument baseDate - string of base date with format dd/mm/yyyy
 * @argument objId - string of object id where will be placed the locale date
 * @argument removeTime - boolean to remove time from locale date
 **/
function getLocaleDate(baseDate,objId,removeTime){if(removeTime==undefined||removeTime==null)removeTime=true;var tempDate=new Date(baseDate.substr(6),parseInt(baseDate.substr(3,2),10)-1,baseDate.substr(0,2));document.getElementById(objId).innerHTML=(removeTime)?tempDate.toLocaleString().substr(0,tempDate.toLocaleString().indexOf(tempDate.getFullYear())+4):tempDate.toLocaleString();}
/**
 * Retrieve title of selected option from a Select Object
 * @arguments obj - Select Object
 **/
function getSelectedOptionTitle(obj,defaultValue){if(obj!=undefined&&obj!=null)if(obj.nodeName=='SELECT')return obj.options[obj.selectedIndex].title;else return defaultValue;}
/**
 * Retrieve label of selected option from a Select Object
 * @arguments obj - Select Object
 **/
function getSelectedOptionLabel(obj,defaultValue){if(obj!=undefined&&obj!=null)if(obj.nodeName=='SELECT')return obj.options[obj.selectedIndex].label;else return defaultValue;}
function setCheckedValue(radioObj, newValue) {
  if(!radioObj)
    return;
  var radioLength = radioObj.length;
  if(radioLength == undefined) {
    radioObj.checked = (radioObj.value == newValue.toString());
    return;
  }
  for(var i = 0; i < radioLength; i++) {
    radioObj[i].checked = false;
    if(radioObj[i].value == newValue.toString()) {
      radioObj[i].checked = true;
    }
  }
}
//window.history.forward(1);
//document.attachEvent("onkeydown", my_onkeydown_handler);
function my_onkeydown_handler()
{
switch (event.keyCode)
{

case 116 : // 'F5'
event.returnValue = false;
event.keyCode = 0;
window.status = "La tecla F5 ha sido deshabilitada porque esto cierra la sessión!";
break;
}
}

/* Function to round any number*/
function round(value,maxDec){if(value==undefined||value==null||isNaN(value)){CBMSG.warning('Unable to round given value['+value+']: Invalid Number!');return null;}if(maxDec==undefined||maxDec==null||isNaN(maxDec))maxDec=0;var tmp=Math.round(value*Math.pow(10,maxDec));return tmp/Math.pow(10,maxDec);}

/*
jQuery Tooltip
level: target's level: top.document
target: can be tag name, class name(.) or object id(#). If target is not given then tooltip will be appended to body tag.
fixedPosition: if true then message will be static in the defined position if it's given.
posX: if fixed position, set x-axis position
posY: if fixed position, set y-axis position

How to use:
1. call this function onload event or $(document).ready(function(){jqTooltip();});
2. add class name "_jqHint"
3. add attribute hintMsgId="objectId" or hintMsg="Add Message Here!". If both attributes are set then the attribute hintMsgId has the priority and the other will be omitted.
*/
function jqTooltip(level,target,fixedPosition,posX,posY){
if(level==undefined||level==null)level=document;
if(target==undefined||target==null||target.trim()=='')target='body';
if(fixedPosition==undefined||fixedPosition==null)fixedPosition=false;
var changeTooltipPosition=function(event){var tooltipX=event.pageX+10;var tooltipY=event.pageY;if(fixedPosition){if(posX==undefined||posX==null)tooltipX=$('div._jqTooltip',level).position.left;else tooltipX=posX;if(posY==undefined||posY==null)tooltipY=$('div._jqTooltip',level).position.top;else tooltipY=posY;}$('div._jqTooltip',level).css({top:tooltipY,left:tooltipX});};
var showTooltip=function(event){$('div._jqTooltip',level).remove();$('<div class="_jqTooltip"></div>').appendTo($(target,level));if($(this).is('[hintMsgId]'))$('._jqTooltip',level).append($('#'+$(this).attr("hintMsgId")).html());else if($(this).is('[hintMsg]'))$('._jqTooltip',level).append($(this).attr("hintMsg"));changeTooltipPosition(event);};
var hideTooltip=function(){$('div._jqTooltip',level).remove();};
if(!fixedPosition)$("._jqHint").bind({mousemove:changeTooltipPosition});
$("._jqHint").bind({mouseenter:showTooltip});
$("._jqHint").bind({mouseleave:hideTooltip});
$("._jqHint").bind({click:hideTooltip});//to prevent tooltip after click
}
var v_validaFecha ='S';
var usaCierreInv =''
var esInv ='';
function getEstadoAnio(context,cia,anio){
  var sqlWhere ='';
  var estadoAnio  = ''; 
  
   v_validaFecha = getDBData(context,'nvl(get_sec_comp_param('+cia+',\'CONT_VALIDA_FECHA_TRX\'),\'S\')','dual','','');
   
  if(v_validaFecha=='S'){
  if(anio!=''&&anio!='null')
  {
    estadoAnio = getDBData(context,'case when '+anio+' < (select min(ano) from tbl_con_estado_anos where cod_cia='+cia+') then \'CER\' else  \'\' end as estatus','dual',' ','');
	if(estadoAnio=='')estadoAnio = getDBData(context,'nvl(estado,\'INA\')','tbl_con_estado_anos','ano='+anio+' and cod_cia='+cia+' ','');
  }
  if(estadoAnio=='ACT'||estadoAnio=='')return true; else{CBMSG.warning('Estado del año '+anio+' es invalido para realizar transacciones!');return false;}
 }else{return true;}
}
var whInv =null;

function getEstadoMes(context,cia,anio,mes){
  var sqlWhere ='';
  var estadoMes  = ''; 
  var cierre ='N';
  usaCierreInv = getDBData(context,'nvl(get_sec_comp_param('+cia+',\'CONT_VALIDA_CIERRE_INV\'),\'N\')','dual','','');
  if(usaCierreInv=='S'&&esInv=='S')
  {
	  
      cierre = getDBData(context,'distinct \'S\'','tbl_inv_cierre_mes','anio='+anio+' and compania='+cia+' and almacen = nvl('+whInv+',almacen) and mes=\''+mes+'\'','');
	  if(cierre!='S')return true; else{ CBMSG.warning('Ya se realizo cierre mensual de inventario por lo que no es permitido realizar transacciones. Consulte con Contabilidad!');return false;}
  }
  
  if(v_validaFecha=='S'){
  if(anio!=''&&anio!='null' && mes!=''&&mes!='null'  )
  {
    estadoMes = getDBData(context,'nvl(estatus,\'X\')','tbl_con_estado_meses','ano='+anio+' and cod_cia='+cia+' and mes=\''+mes+'\'','');
  }
  if(estadoMes!='CER'&&cierre!='S')return true; else{ CBMSG.warning('Estado del mes '+mes+' del año '+anio+' es invalido para realizar transacciones!');return false;}
  }else{return true;}
}

function getGS1BarcodeData(context, p_t, p_val) {
console.log('ctx='+context+' p_t='+p_t+' p_val='+p_val);
/*
codigo						(01) o )01=
lote							(10) o )10=
fecha produccion	(11) o )11=
fecha expiracion	(17) o )17=

)17=170707)10=60101045
)01=07460691949775
)10=6012615117170201
)01=00690103000436
)01=00616258005638)11=190117)17=240117)10=8409879
*/
var v_return ;
var v_c;
var v_to;
var v_val = p_t.replace('(10)',')10=').replace('(01)',')01=').replace('(17)',')17=').replace('(11)',')11=');
console.log('**v_val='+v_val);
p_t = v_val;
//alert('v_val='+v_val);
if (p_val == '10') v_c = ')10=';
else if (p_val == '17') v_c = ')17=';
else if (p_val = '01') v_c = ')01=';
else if (p_val = '11') v_c = ')11=';
//v_to := nvl(instr(replace(p_t, substr(p_t, 1, instr(p_t, v_c)+length(v_c))), ')'), length(p_t));
if(p_t.indexOf(')01=')==-1){  
	p_t = ')01= '+p_t;
	//v_return = p_t;
}
if(p_t.indexOf(v_c)==-1) v_return = '';
else{
	v_to = (p_t.substr(p_t.indexOf(v_c) +v_c.length)).indexOf(')') || p_t.length;
	if (v_to == -1) v_to = p_t.length;
	//v_return := substr(p_t, instr(p_t, v_c)+length(v_c), v_to);
	v_return = p_t.substr(p_t.indexOf(v_c)+v_c.length, v_to);
	//alert('vc='+v_c+'v_return='+v_return+', indexOf='+v_return.indexOf('00'));
	if (v_c == ')17=' && v_return.indexOf('00')!=-1){
		v_return = getDBData(context,'getFullDate('+v_return+')','dual','','');
	}
}
console.log('* barcode segment='+v_return);

return v_return.trim();

}
function doBCSubmit(ctx,obj,bct){
	console.log('* doBCSubmit');
	obj.value=getGS1BarcodeData(ctx,obj.value,bct);
	obj.form.submit();
	return;
}
