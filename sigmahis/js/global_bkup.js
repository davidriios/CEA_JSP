<!-- G E N E R A L -->
window.focus();

/*
Create trim method for a String data type.
How to use:
	var str = 'test ';
	str.trim(); //The output will be 'test'
*/
String.prototype.trim=function(){var str=this.replace(/^\s\s*/,''),ws=/\s/,i=str.length;while(ws.test(str.charAt(--i)));return str.slice(0,i+1);}


//disableRightClick();
function disableRightClick(e){var message='El click derecho no está permitido!';if(!document.rightClickDisabled){if(document.layers){document.captureEvents(Event.MOUSEDOWN);document.onmousedown=disableRightClick;}else document.oncontextmenu=disableRightClick;return document.rightClickDisabled=true;}if(document.layers || (document.getElementById && !document.all)){if(e.which==2||e.which==3)return false;}else return false;}

var navig_agt = navigator.userAgent.toLowerCase();
var navig_kqr;
var navig_fox;
var navig_ie5;
function checkBrowser(){navig_kqr=(navig_agt.indexOf("konqueror")!=-1);navig_fox=(navig_agt.indexOf("firefox")!=-1);navig_ie5=(navig_agt.indexOf("msie")!=-1);}

function showStatusBar(msg){if(msg==undefined||msg==null)msg='';window.status=msg;return true;}
//hide status bar
if(document.layers)document.captureEvents(Event.MOUSEOVER | Event.MOUSEOUT | Event.MOUSEDOWN)
document.onmouseover=showStatusBar;
document.onmouseout=showStatusBar;
document.onmousedown=showStatusBar;

function setoverc(src,overc){src.className=overc;}
function setoutc(src,outc){src.className=outc;}

function showHide(id){if(document.getElementById('panel'+id).style.display=='none'){document.getElementById('panel'+id).style.display='';document.getElementById('plus'+id).style.display='none';document.getElementById('minus'+id).style.display='';}else{document.getElementById('panel'+id).style.display='none';document.getElementById('plus'+id).style.display='';document.getElementById('minus'+id).style.display='none';}}

/*blinkId('htmlId','red','white',1000);*/
function blinkId(htmlId,colorOn,colorOff,delay){if(delay==undefined)delay=800;document.getElementById(htmlId).style.color=colorOn;timerOne=setTimeout('blinkId(\''+htmlId+'\',\''+colorOff+'\',\''+colorOn+'\','+delay+')',delay);}

function checkAll(formName,checkObjPrefixName,listSize,globalCheckObj,startIndex){if(startIndex==undefined)startIndex=0;for(i=startIndex;i<(listSize+startIndex);i++){if(eval('document.'+formName+'.'+checkObjPrefixName+i))eval('document.'+formName+'.'+checkObjPrefixName+i).checked=globalCheckObj.checked;}}
function checkOne(formName,checkObjPrefixName,listSize,currObj,startIndex){if(startIndex==undefined)startIndex=0;for(i=startIndex;i<(listSize+startIndex);i++){if(eval('document.'+formName+'.'+checkObjPrefixName+i))eval('document.'+formName+'.'+checkObjPrefixName+i).checked=false;}currObj.checked=true;}

function showSelectBoxes(trueFalse){for(var i=0;i<document.forms.length;i++)for(var e=0;e<document.forms[i].length;e++)if(document.forms[i].elements[e].tagName=="SELECT")if(trueFalse)document.forms[i].elements[e].style.visibility='visible';else document.forms[i].elements[e].style.visibility='hidden';}

function setBAction(formName,actionValue){document.forms[formName].baction.value=actionValue;}
function removeItem(fName,k){var rem=eval('document.'+fName+'.rem'+k).value;eval('document.'+fName+'.remove'+k).value=rem;setBAction(fName,rem);}

//Textarea maxLength attribute
function checkTextLength(obj){var maxLength=obj.getAttribute?parseInt(obj.getAttribute('maxLength')):0;if(obj.getAttribute&&obj.value.length>maxLength)obj.value=obj.value.substring(0,maxLength);showTextCounter(obj,maxLength);}
function showTextCounter(obj,maxLength){var objCounter=document.getElementById(obj.name+'Counter');var currLength='Actual: '+obj.value.length;objCounter.innerHTML=(obj.value.length>=maxLength)?'<font color="red">'+currLength+'</font>':currLength;}

//Used to replace % to url standard
function replacePercent(val){var oldValue=val.value;var regExp=/%/gi;val.value=oldValue.replace(regExp,'%25');return true;}

function setUploadFlag(objFlag){objFlag.value='1';}


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

var win;
var keepOpen=false;
function keepChildOpen(trueFalse){keepOpen=trueFalse;}
function closeChildWin(){if(!keepOpen&&win)win.close();}
//window.onunload=function(){closeChildWin();}
function abrir_ventana(val){win=window.open(val,'ventana',getPopUpOptions(displayScrollBar,resizable,displayLocationBar,displayStatusBar));}
function abrir_ventana1(val){win=window.open(val,'ventana1',getPopUpOptions(displayScrollBar,resizable,displayLocationBar,displayStatusBar));}
function abrir_ventana2(val){win=window.open(val,'ventana2',getPopUpOptions(displayScrollBar,resizable,displayLocationBar,displayStatusBar));}
function abrir_ventana3(val){win=window.open(val,'ventana3',getPopUpOptions(displayScrollBar,resizable,displayLocationBar,displayStatusBar));}
function abrir_ventana4(val){win=window.open(val,'ventana4',getPopUpOptions(displayScrollBar,resizable,displayLocationBar,displayStatusBar));}
function abrir_ventana5(val){win=window.open(val,'ventana5',getPopUpOptions(displayScrollBar,resizable,displayLocationBar,displayStatusBar));}
function openWin(url,winName,opts){win=window.open(url,winName,opts);}
function closeWin(){window.close();}
function showImage(imgPath,winTitle,title,description){maxHeight=400;if(imgPath==undefined||imgPath==null||imgPath.trim()==''){imgPath='../images/image_not_found.jpg';winTitle='Image Not Found!';}var img=new Image();img.src=imgPath;iWidth=img.width;iHeight=img.height;imgWin=window.open('','imgWin',getPopUpOptions(false,false,false,false,iWidth+50,iHeight+75));if(winTitle==undefined||winTitle==null)winTitle='Image';if(description==undefined||description==null||description.trim()=='')description=imgPath.substr(imgPath.lastIndexOf('/')+1);imgWin.document.write('<html><head><title>'+winTitle+'</title></head><body bgcolor="#000000" text="#ffffcc"><center>');if(title!=undefined&&title!=null&&title.trim()!='')imgWin.document.write('<font face="Arial, Helvetica, sans-serif" size="4"><b>'+title+'</b></font>');imgWin.document.write('<p><img src="'+imgPath+'" alt="Image not found"><p>');imgWin.document.write('<font face="Arial, Helvetica, sans-serif">'+description+' ['+img.width+' X '+img.height+']</font>');imgWin.document.write('</center></body></html>');imgWin.document.close();imgWin.focus();}
function hideImage(){imgWin.close();}//'width=400,height=400,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=no,screenX=0,screenY=0,left='+(screen.availWidth-400)/2+',top='+(screen.availHeight-400)/2


<!-- I F R A M E S -->
function adjustIFrameSize(iframeWindow){if(iframeWindow.document.height){var iframeElement=document.getElementById(iframeWindow.name);iframeElement.style.height=iframeWindow.document.height+'px';}else if(document.all){var iframeElement=document.all[iframeWindow.name];if(iframeWindow.document.compatMode&&iframeWindow.document.compatMode!='BackCompat')iframeElement.style.height=iframeWindow.document.documentElement.scrollHeight+'px';else iframeElement.style.height=iframeWindow.document.body.scrollHeight+'px';}}
function newHeight(){if(parent.adjustIFrameSize)parent.adjustIFrameSize(window);}
//working with tab, adjust iframe height. used in tab-view.js
function adjustHeight(index){if(window.frames['itemFrame'+index])window.frames['itemFrame'+index].newHeight();}
function setHeight(id,xHeight){var xtraHeight=21;checkBrowser();if(navig_fox)xtraHeight=29;document.getElementById(id).style.height=(xHeight-xtraHeight);}
function setFrameSrc(frameId,src){var frameObj=document.getElementById(frameId);frameObj.src=src;}
function adjustDivWithIFrameHeight(id){if(parent.document.getElementById(id)){newHeight();parent.setHeight(id,document.body.scrollHeight);}}



<!-- A J A X H A N D L E R -->
//Array index starts from 0. These three methods can be used when ajaxHandler function return more than one column or row.
function splitRows(str){var row=null;if(str.indexOf('~')>=0)row=str.split('~');return row;}
function splitCols(str){var col=null;if(str.indexOf('|')>=0)col=str.split('|');return col;}
function splitRowsCols(str){var row=splitRows(str);var rowsCols=null;if(row!=null){rowsCols=new Array(row.length);for(i=0;i<row.length;i++){var col=splitCols(row[i]);if(col!=null)rowsCols[i]=col;}}else{var col=splitCols(str);if(col!=null){rowsCols=new Array();rowsCols[0]=col;}}return rowsCols;}

function httpRequestInstance(mimeType){if(mimeType==undefined||mimeType==null)mimeType='text/html';var httpRequest;if(window.XMLHttpRequest){/*Mozilla,Safari,...*/httpRequest=new XMLHttpRequest();if(httpRequest.overrideMimeType)httpRequest.overrideMimeType(mimeType);}else if(window.ActiveXObject){/*IE*/try{httpRequest=new ActiveXObject('Msxml2.XMLHTTP');}catch(e){try{httpRequest=new ActiveXObject('Microsoft.XMLHTTP');}catch(e){alert('httpRequest instance failed');}}}if(!httpRequest){alert('Giving up :( Cannot create an XMLHTTP instance');httpRequest=null;}return httpRequest;}

/*
This function returns true and it sends an alert message to the user, if the any records match with the given filter, otherwise returns false.
- context:       (Required) application context name
- mode:          (Required) creation (add) or edition (edit) mode. if add mode then validate immediatly, otherwise validate only if the values has been changed
- obj:           (Required) form object to validate
- tables:        (Required) tables names separated by comma (if more than one table)
- filters:       (Required) query's where segment, include new value (from form object) filter
- oldValue:      (Required) form object old value (from database)
*/
function duplicatedDBData(context,mode,obj,tables,filters,oldValue){if(context.trim()!=''&&mode.trim()!=''&&obj&&tables.trim()!=''&&filters.trim()!=''){if(oldValue==undefined)return false;var newValue=obj.value;if(!(mode.toLowerCase()=='edit'&&newValue==oldValue)){if(ajaxHandler(context+'/ajax?returnFields='+encodeURIComponent('count(*)')+'&tables='+encodeURIComponent(tables)+'&filters='+encodeURIComponent(filters)+'&time='+new Date())!='0'){alert('El valor introducido ya existe!');obj.focus();return true;}}}return false;}

/*
This function returns true if data is found, otherwise returns false, given the following parameters:
- context:       (Required) application context name
- tables:        (Required) tables names separated by comma (if more than one table)
- filters:       (Optional) query's where segment
- xtra:          (Optional) others query's segments (group by, order by)
*/
function hasDBData(context,tables,filters,xtra){if(context.trim()!=''&&tables.trim()!=''){if(filters==undefined)filters='';if(xtra==undefined)xtra='';if(ajaxHandler(context+'/ajax?returnFields='+encodeURIComponent('count(*)')+'&tables='+encodeURIComponent(tables)+'&filters='+encodeURIComponent(filters)+'&xtra='+encodeURIComponent(xtra)+'&time='+new Date())!='0')return true;}return false;
}

/*
This function returns a String value, given the following parameters:
- context:       (Required) application context name
- returnFields:  (Required) fields values separated by comma (if more than one field)
- tables:        (Required) tables names separated by comma (if more than one table)
- filters:       (Optional) query's where segment
- xtra:          (Optional) others query's segments (group by, order by)
*/
function getDBData(context,returnFields,tables,filters,xtra){var retVal='';if(context.trim()!=''&&returnFields.trim()!=''&&tables.trim()!=''){if(filters==undefined)filters='';if(xtra==undefined)xtra='';retVal=ajaxHandler(context+'/ajax?returnFields='+encodeURIComponent(returnFields)+'&tables='+encodeURIComponent(tables)+'&filters='+encodeURIComponent(filters)+'&xtra='+encodeURIComponent(xtra)+'&time='+new Date());}return retVal;}

/*
This function returns true if the query is executed successfully, otherwise returns false, given the following parameters:
- context:       (Required) application context name
- executeQuery:  (Required) query to be executed
- tables:        (Optional) tables names to lock separated by comma (if more than one table)
*/
function executeDB(context,executeQuery,tables){var retVal='';if(context.trim()!=''&&executeQuery.trim()!=''){if(tables==undefined)tables='';retVal=ajaxHandler(context+'/ajax?executeQuery='+encodeURIComponent(executeQuery)+'&tables='+encodeURIComponent(tables)+'&time='+new Date());}if(retVal.length==0)return false;else return true;}

/*
This generic function returns a String value from AjaxHandler, given the url that contains the parameters to create the query.
If the query returns more that one row, it will be separated by '~'.
If the query returns more that one column, it will be separated by '|'.
*/
function ajaxHandler(url){var xmlDoc='';if(url.trim()!=''){var httpRequest=httpRequestInstance();if(httpRequest==null)alert('XMLHTTP instance is null!');else{httpRequest.open('GET',url,false);httpRequest.onreadystatechange=function(){if(httpRequest.readyState==4)if(httpRequest.status==200)xmlDoc=httpRequest.responseText;};httpRequest.send(null);}}return xmlDoc;}

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
	var size = object.length;
	var returnValue = '';
	for(i=0;i<size;i++){
		if(object[i].checked){
			returnValue = object[i].value;
			break;
		}
	}
	return returnValue;
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
        var opt = new Option('* * * * * * * * * *','');
        document.getElementById(idSelect).options[0] = opt;
        document.getElementById(idSelect).options[0].title = 'NO DISPONIBLE / NOT AVAILABLE';
        index = 1;
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


function showHideDateFormat(divObj,displayFlag){document.getElementById(divObj).style.display=displayFlag;document.getElementById(divObj).innerHTML=' Formato: "dd/mm/yyyy" Ejemplo: "31/12/2008" ';}

function checkDateFormat(obj, event)
{
//	alert(event.keyCode);
	if (event.keyCode==8 || event.keyCode==46) return false; //delete or backspace


	var x =	document.getElementById(obj).value;
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
		alert('Introduzca valores Numéricos!');
		field.value = 0;
	} else {
		if(field.value!='' && field.value != 0 && chk) chk.checked = true;
		else if(chk) chk.checked = false;
	}
}

function getInvDisponible(context, cia, almacen, flia, clase, codigo){
	var disponible	= parseFloat(getDBData(context, 'nvl(disponible, 0) disponible', 'tbl_inv_inventario', 'compania = '+cia+' and codigo_almacen = '+almacen+' and art_familia = ' + flia + ' and art_clase = ' + clase + ' and cod_articulo = ' + codigo,''),10);
	return disponible;
}