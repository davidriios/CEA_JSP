if (!Array.prototype.includes) {
  Object.defineProperty(Array.prototype, 'includes', {
    value: function(searchElement, fromIndex) {

      if (this == null) {
        throw new TypeError('"this" is null or not defined');
      }

      // 1. Let O be ? ToObject(this value).
      var o = Object(this);

      // 2. Let len be ? ToLength(? Get(O, "length")).
      var len = o.length >>> 0;

      // 3. If len is 0, return false.
      if (len === 0) {
        return false;
      }

      // 4. Let n be ? ToInteger(fromIndex).
      //    (If fromIndex is undefined, this step produces the value 0.)
      var n = fromIndex | 0;

      // 5. If n = 0, then
      //  a. Let k be n.
      // 6. Else n < 0,
      //  a. Let k be len + n.
      //  b. If k < 0, let k be 0.
      var k = Math.max(n >= 0 ? n : len - Math.abs(n), 0);

      function sameValueZero(x, y) {
        return x === y || (typeof x === 'number' && typeof y === 'number' && isNaN(x) && isNaN(y));
      }

      // 7. Repeat, while k < len
      while (k < len) {
        // a. Let elementK be the result of ? Get(O, ! ToString(k)).
        // b. If SameValueZero(searchElement, elementK) is true, return true.
        if (sameValueZero(o[k], searchElement)) {
          return true;
        }
        // c. Increase k by 1. 
        k++;
      }

      // 8. Return false
      return false;
    }
  });
}
function debug(msg){window.console&&console.log(msg);}
function isInteger(n) { return (/^\d+$/.test(n+''));}
function getRootDir(){return window.location.pathname.replace(/^\/([^\/]*).*$/, '$1');}
function exists(obj){
 try{return obj instanceof jQuery && obj.length > 0;}catch(e){debug('ERROR jquery_functions.exists() caused by '+e.message); return false;}
}
function die(msg){debug(msg); throw new Error("[jquery_functions.js] Stop execution...");}
function removeDups(arr){
  tempObj = {};
  c = [];
  try{
	  for (var i = 0; i < arr.length; i++) {
		tempObj[arr[i]] = arr[i];
	  }
	  c = [];
	  for (var key in tempObj) {
		if (tempObj.hasOwnProperty(key)) c.push(key);
	  }
  }catch(e){c = []; debug("ERROR jquery_functions.removeDups() caused by: "+e.message);}
 return c.sort();
}
function YT(id,w,h){
  if (!id) throw new Error("Could not find the id of the vid...");
  var _w = w || 640;
  var _h = h || 390;
  var f = '<iframe width="'+_w+'" height="'+_h+'" src="https://www.youtube.com/embed/'+id+'?autoplay=1" frameborder="0" allowfullscreen></iframe>';
  document.write("");
  document.write(f);
}
function hasDuplicate(arr) {
    var i = arr.length, j, val;
    while (i--) {
    	val = arr[i];
    	j = i;
    	while (j--) {
    		if (arr[j] === val) {
    			return true;
    		}
    	}
    }
    return false;
} 

function getJqObj(str,isObj){
  if (typeof isObj === "undefined")return $("#"+str);
  else return $(str);
}
// format decimal
function fd(val,n){
  var df = 0; 
  try {
    if ( jQuery.isNumeric(val) )
	  if (typeof n !== 'undefined' ) return val.toFixed(n);
	  else return val.toFixed(2);
	else return df.toFixed(2);
  }catch(e){debug("ERROR jquery_functions.fd() (Format Decimal). Caused by: "+e.message);}
}

function parseMethodTemplate (f) {
   return f.toString().match(/\/\*\s*([\s\S]*?)\s*\*\//m)[1].replace(/(\/\*[\s\S]*?\*) \//g, '$1/');
}

var _setTmpl = parseMethodTemplate(function() {/*
    public void set@@UPROPERTY (String paramVal){
        this.@@PROPERTY = paramVal;
    }
*/});

var _getTmpl = parseMethodTemplate(function() {/*
    public String get@@UPROPERTY (){
        return this.@@PROPERTY;
    }
*/});

/**
 *@properties: comma separated ("pacId,noAdmision...")
 */
function codeGen(properties){
  if (properties){
	  var props = properties.split(",");
	  for (i=0; i<props.length;i++){
		var _set = _setTmpl.toString().replace("@@UPROPERTY",initCap(props[i])).replace("@@PROPERTY",props[i]);
		var _get = _getTmpl.toString().replace("@@UPROPERTY",initCap(props[i])).replace("@@PROPERTY",props[i]);
		debug(_set);
		debug(" ");
		debug(_get);
	  }
	  return;
  }else debug("[ERROR] jquery_functions.codeGen: Please provide some comma separated public string properties.");
}

function initCap(s){
   return s.charAt(0).toUpperCase() + s.slice(1);
}

//format date, default Birt report (yyyy-mm-dd)
jQuery.fn.toRptFormat = function () {
    var _this = $(this);
	var _reverse = result = "";
	try{
	  _reverse = (_this.val().split("/").reverse()).toString();
	  result = _reverse.replace(/,/g,"-");
	  return result;
	}catch(e){debug("ERROR jquery_functions.toRptFormat(). Caused by: "+e.message);}
};

jQuery.fn.selText = function (ctx) {
    var _this = $(this); //_clase_comprobDsp _clase_comprobDsp
    if (_this.prop('type') != "select-one") {
      if (ctx) _this = $("#_"+_this.attr('id')+"Dsp", ctx);
      else _this = $("#_"+_this.attr('id')+"Dsp");
    }
    if(_this.val()) return $("option:selected", _this).text();
    else return "N/A";
};

jQuery.fn.isAValidImg = function (options){
  var options = typeof options=='undefined'?{}:options;
  var _this = $(this);
  var allowedExt = ["gif","jpg","jpeg","png","bmp","tiff"];
  var val = _this.val();
  var cExt = val.split(".").pop();
  var errMsg = options.errMsg || "Solamente los archivos cuya extensión sea: "+allowedExt

  if (val){
    if ( jQuery.inArray(cExt, allowedExt) == -1 ) {alert(errMsg);
	if (options.fail && typeof options.fail === 'function') options.fail();
	return false;}
  }
  if (options.success && typeof options.success === 'function') options.success();
  return true;
};

jQuery.fn.__attr = function() {
    if(arguments.length === 0) {
      if(this.length === 0) {
        return null;
      }

      var obj = {};
      $.each(this[0].attributes, function() {
        if(this.specified) {
          obj[this.name] = this.value;
        }
      });
      return obj;
    }
};

function isMobile(){return typeof window.orientation !== 'undefined';}

$(document).ready(function(){

   /**
    * Bueno, escuchamos el evento click en una tabla
    * Si encontramos un checkbox o radiobutton, escuchamos onclick en la fila actual,
    * y checkeamos de igual manera ejecutamos los inline handlers en onclick
    * 
    **/
    
//trying to exit 
if (isThisPageAList()){

    applyButtonStyleToLink();
    
    $("table tbody tr").on('mouseover',function(eh){
    
       eh.stopImmediatePropagation();
           
       var $Htarget = $(eh.target);
       var $HcTr = $Htarget.closest("tr");
       if( hasMouseOverOut( $HcTr.attr("onmouseover") ) && hasRadioOrCheck($HcTr) ){eh.stopImmediatePropagation(); $HcTr.css("cursor","pointer");$HcTr.attr("title","Clic para seleccionar!"); } 
       
       //eh.preventDefault();
       
    });
    
    $("table tbody tr td:not(:last-child)").on("click", function(e) {
        	 
        var $target = $(e.target);
        var $cTr = $target.closest("tr");
		var $cObj = $(this);
	
        if ( hasMouseOverOut($cTr.attr("onmouseover")) ){

            if (hasRadioOrCheck($cTr,'rb')){

                   e.stopImmediatePropagation(); // Sirve como un exit o stop en un loop
                   var $cRB = $cTr.find('td input[type=radio]');
                   if(tdDoesNotHaveInput($cObj)) doCheckUncheck($cTr,$cRB);
            }
            else
            if (hasRadioOrCheck($cTr,'cb')){
            
                  e.stopImmediatePropagation(); 
                  var $cCB = $cTr.find('td input[type=checkbox]');
                                    
                  $cCB.click(function(e){
                    e.stopImmediatePropagation();
                    $("input:checkbox[name='" + this.name + "']").not(this).removeAttr("checked");
                  });
                  if(tdDoesNotHaveInput($cObj)) doCheckUncheck($cTr,$cCB);
            }
        }
    });
    
    
    //hay checkbox y radio que no son necesariamente en una p?gina de lista
    // hehehehe generalmente, se aplica el efecto de cambiar el color onmouse/over/out
    function hasMouseOverOut(attrInTheCurrentRow){
       if (typeof attrInTheCurrentRow != "undefined" ) return true;
       return false;
    }
    
    function hasOnClick($rowOrCheckOrRadio){
       if ($rowOrCheckOrRadio.attr("onclick") != undefined) return true;
       return false;
    }
    
    function hasRadioOrCheck($row,$type){
        var $cb = $row.find('td input[type=checkbox]').length;
        var $rb = $row.find('td input[type=radio]').length;

        if ($type == "cb" && $cb  > 0 ) return true;
        else if ($type == "rb" && $rb > 0 ) return true;
        else if(typeof $type == "undefined" && ($cb > 0 || $rb > 0)) return true;
        else return false;
    }
     
    function doCheckUncheck($row,$inputType){
       if ( $inputType.is(":disabled") == false ){
         if($inputType.is(":checked") == false){
             //$inputType.attr("checked", true);
             $inputType.prop({checked: true});
             if ( hasOnClick($row)) $row[0].onclick();
             if ( hasOnClick($inputType)) $inputType[0].onclick();
         } else {
             if ($inputType.attr("type") == 'checkbox'){
                //$inputType.attr("checked", false);
                $inputType.prop({checked: false});
             }
         }
      }
    }
	
	function tdDoesNotHaveInput($cObj){
	   __inputsP = ["<select","<input","<button"];
	   __cObjContent = $cObj.closest('td')[0].innerHTML;
	   __cObjContent = __cObjContent.toString().toLowerCase();
	   __totInputsFound = 0;
	   for (t = 0; t<__inputsP.length; t++){
		 if(__cObjContent.indexOf(__inputsP[t]) > 1) __totInputsFound++;
	   }//for t
	   return __totInputsFound == 0;
	}
    
 }
 /**
* Aplica una pinta de botones a los links en p?ginas lista y que tienen 
* La classe Link00, Link00Bold y que tienen textos como $anchorTextPattern
* @return void
*/
function applyButtonStyleToLink(){
    //console.log("thebrain$ Trying to apply btn_link to some links....");
    $('a').each(function (e) {
        var $linkObj = $(this);
        var $anchorText = $linkObj.text().toLowerCase();
        var $linkCSSclass = $linkObj.attr("class");
        var $anchorTextPattern = ["agregar","crear","registrar","imprimir"];
        if ( $linkCSSclass == "Link00" || $linkCSSclass == "Link00Bold"){
            for ($p=0; $p<$anchorTextPattern.length; $p++ ){
               if ( $anchorText.indexOf($anchorTextPattern[$p]) > -1 ){  
                  $linkObj.addClass("btn_link");
               }
            }
        }
     });
}/**/


/**
* Verifica que una p?gina es una lista
* @return boolean
*/
function isThisPageAList(){
     var $_pattern = ["list","search","sel","check","config"];
     var $_cUrl = window.location;
     
     if ("forceList" in window) return true;
	 
	 if ("ignoreSelectAnyWhere" in window) return false;

     for (i=0; i<$_pattern.length; i++){
         if($_cUrl.toString().indexOf($_pattern[i]) > -1)
            return true;
     }
     return false;
} /**/

/**
* Muestra un mensaje de tipo advertencia a la hora de entrar al sistema si el browser
* No cumple con las especificaciones. Si algo sale mal presentado, es porque no escucha.
*
* Esto depende del plugin jquery.mb.browser.min.js ya que jQuery elimin? la propriedad
* $.browser desde la ver 1.9 
*
* return void
*/
function isAValidBrowser(){
   //console.log("We're running jQuery "+jQuery.fn.jquery);
   var $bOjb = bowser;
   var $curBSVer = $bOjb.version;
   var $min, $max, $msg = "Hemos detectado que la versi?n de [";
   var $supportedBrowser =  ( ("supportedBrowser" in window) ?supportedBrowser:{"ie":[7,9], "ff":[20,26], "gc":[17,27]} );
   
   var $warningContainer = $("#warning-container");
      
   if ($warningContainer.length > 0){ // si no encontramos este elemento, no se llamar? doTest
      if ($bOjb.msie==true) doTest("ie");
	  else if ($bOjb.firefox==true)doTest("ff");
	  else if ($bOjb.webkit==true)doTest("gc");
   }
   
   function doTest(b){
      var $showMsg = false;
	  var $nav = $bOjb.name || 'el navegador';
	  var browserSituation = "";
      $min = $supportedBrowser[b][0];
      $max = $supportedBrowser[b][$supportedBrowser[b].length -1];
	  if ($curBSVer < $min)      {browserSituation=" menor ";  $showMsg = true;}
	  else if ($curBSVer > $max) {browserSituation=" mayor "; $showMsg = true;}
	  
	  $msg += $nav + "] es "+browserSituation+" ("+$curBSVer+") a la recomendada ("+$min + " - "+ $max +")";
	  
	  if ($showMsg) {
	    $msg += ". Es posible que se presenten algunos problemas en cuanto a la presentaci?n.";
	    $warningContainer.show(0);
		$("#msg-container").append($msg);
	  }
   }
}

isAValidBrowser();

$('input, select').not('.allow-enter').keypress(function(event) {
    return event.keyCode != 13;
});

$(document).delegate('*[data-toggle="lightbox"]', 'click', function(event) {
    event.preventDefault();
    $(this).ekkoLightbox();
}); 

// prevent stupid firefox from navigating back hitting backspace
$(document).on('keydown',function(e){
  var $target = $(e.target||e.srcElement);
  if(e.keyCode == 8 && !$target.is('input,[contenteditable="true"],textarea')){
    debug('Not navigating back...');
    e.preventDefault();
  }
});

/*$(document).on('keydown',function(e){
  var $target = $(e.target||e.srcElement);
  if(e.keyCode == 123){
    e.preventDefault();
  }
});*/

function blockCCP(e, noCopyPaste, version, profiles) {
	
	if (profiles.includes(0))
		return;
	
	if (noCopyPaste == 'Y') {
		if (version == 3) {
			if(window.location.toString().indexOf('expediente3.0') > -1) {
				alert('Esa acción no está permitido.')
				e.preventDefault();
				return false;
			}
		} else {
			if(window.location.toString().indexOf('expediente') > -1) {
				alert('Esa acción no está permitido.')
				e.preventDefault();
				return false;
			}
		}
	}
}

function ctrlUser() {
  var $parent =  $("#app_user_id", window.top.document);
  var savedUserId = localStorage.getItem("expctrlccpuserid");
  var expCtlCCP = localStorage.getItem("expctrlccp");
  var cUserId = $parent.val();
    
  if (!savedUserId && !expCtlCCP) {
    localStorage.setItem('expctrlccpuserid', cUserId);
  } else 
  if (!savedUserId && expCtlCCP) {
    localStorage.removeItem('expctrlccp');
    localStorage.setItem('expctrlccpuserid', cUserId);
  } else if (savedUserId && cUserId && cUserId != savedUserId) {
    localStorage.removeItem('expctrlccp');
    localStorage.setItem('expctrlccpuserid', cUserId);
  }
}

// No creo que a?n haya un usuario que no sepa como abilitar el dev tools de su navegador :D Bueno ni modo
$(document).on("cut copy paste contextmenu",function(e) {
  var expCtlCCP = localStorage.getItem("expctrlccp");
	var noCopyPaste, version, profiles, userId;
	
	ctrlUser();
		
	if (expCtlCCP) {
		expCtlCCP = expCtlCCP.split("@");
		noCopyPaste = expCtlCCP[0];
		version = expCtlCCP[1];
		profiles = JSON.parse(expCtlCCP[2]);
		
		blockCCP(e, noCopyPaste, version, profiles)
	} else {
		$.get('../common/serve_dyn_content.jsp?serveTo=EXP_NO_COPY_PASTE')
	     .done(function(data) {
			 expCtlCCP = $.trim(data);
			 var _expCtlCCP = expCtlCCP.split("@");
			 
			 noCopyPaste = _expCtlCCP[0];
			 version = _expCtlCCP[1];
			 profiles = JSON.parse(_expCtlCCP[2]);
			 			 
			 blockCCP(e, noCopyPaste, version, profiles);
			 
			 localStorage.setItem('expctrlccp', expCtlCCP);
		 }).fail(function(jqXHR, textStatus, errorThrown){
      console.log("Ctrl Copy Paste Error: >>", jqXHR, textStatus, errorThrown);
		 });	
	}  
});



}); //document.ready


/************
* M?todo que permite mostrar tooltip sobre un elemento con title vac?o
*
* @params options object literal
* @return void 
*
***********/
function serveStaticTooltip(options){
   options = typeof options === 'undefined' ? {} : options;
   var $toolTipContainer = options.toolTipContainer || '#tooltip-container';
   var $content = options.content || 'Colorful content by TheBra!n';
   var $track = options.track || false;
   var $waitAjaxResponse = false;
   var $ajaxContent = options.ajaxContent || '';
   var $curIndex = typeof options.curIndex === 'undefined'?'':options.curIndex;
   var __index = 0;
      
   if ($ajaxContent){
       $.ajax({
			url: '../common/serve_static_tooltip.jsp?contentFor='+$ajaxContent,
			cache: false,
			dataType: "html"
		}).done(function(data){
		  __initToolTip(jQuery.trim(data));
		}).fail(function(jqXHR, textStatus, errorThrown){
		   if(jqXHR.status == 404 || errorThrown == 'Not Found'){ 
			  alert('Hubo un error 404, por favor contacte un administrador!'); 
		   }else{
		      alert('Encontramos este error: '+errorThrown);
		   }
		});	
   }else{__initToolTip($content);}
   
   function __initToolTip(__content){
        
        if ($curIndex !== ""){
		
		   if ($($toolTipContainer).length > 0){
			  $($toolTipContainer).tooltip({
				content: __content,
				track: $track,
				position: { my: "left top+15", at: "left bottom", collision: "flipfit" }
			 });
		    }
		   
		}else{
			try{
				__content = eval("({"+__content+"})");
								
				for (c in __content){
				  if (__content.hasOwnProperty(c)){
					__index++;

					if ($($toolTipContainer+"-"+__index).length > 0){
						  $($toolTipContainer+"-"+__index).tooltip({
							content: __content["content-"+__index],
							track: $track,
							position: { my: "left top+15", at: "left bottom", collision: "flipfit" }
						 });
					}
				  }
				}//for c	 
			}catch(e){debug("jquery_functions.__initToolTip() Error: >> "+e.message);}
		}
   } // __initToolTip
    
}

function filterHTML(options){
  options = typeof options === 'undefined' ? {} : options;
  var $tblId = options.tblId || "";
  var $txtId = options.txtId || "";
  var $rowsToBeIgnored = options.ignoreRows || ""; // object: {h:n,f:n}, h= table header, f= table footer, n=quantity. for example: ignoreRows:{h:2,f:1}, we'll try to ignore the first 2 rows and the very last one
  var $blockCheckAllId = options.blockCheckAllId || ""; //The user will still be able to selec all even after the search cause the DOM is still there!
  
  var $rows	 = $('#'+$tblId+' > tbody > tr');
  
  if ($rowsToBeIgnored){
	if ($rowsToBeIgnored.h) $rows = $rows.slice(parseInt($rowsToBeIgnored.h)+1);
	if ($rowsToBeIgnored.f) {
	  $tblFtr = $rowsToBeIgnored.f;
	  $rows = $rows.slice(0,$rows.length-(parseInt($rowsToBeIgnored.h)-1));
	}
   }
 
  try{
     $tblId = getJqObj($tblId);
     $txtId = getJqObj($txtId);
	 $blockCheckAllId = getJqObj($blockCheckAllId);
	 
	 if (!exists($tblId)) throw new Error("Por favor provee el id de la tabla!");
	 if (!exists($txtId)) throw new Error("Por favor provee el id del campo de texto!");
	 	 
	 $txtId.click(function(){$(this).select();})
	.keyup(function() {
		var val = '^(?=.*\\b' + $.trim($(this).val()).split(/\s+/).join('\\b)(?=.*\\b') + ').*$';
		var reg = RegExp(val, 'i');
		var text;

		$rows.show().filter(function() {
		   if (exists($blockCheckAllId)){
		     if ( $blockCheckAllId.is(':enabled') ){
			   $blockCheckAllId.prop("checked",false);
		       $blockCheckAllId.prop("disabled",true);
			 }
		     if ($.trim($txtId.val()) == "" ) $blockCheckAllId.prop("disabled",false)
		   }
		   text = $(this).text().replace(/\s+/g, ' ');
		   return !reg.test(text);
		}).hide();
	 });
  }catch(e){
     debug("Error jquery_functions.filterHTML() Caused by: "+e.message)
  }
}

//------------------------- CELLBYTE MESSAGE
 
   (function( CBMSG, $, undefined ) {
        var defaults = {
		  title: "Cellbyte Hospital Managment Suite",
		  btnTxt: "Ok",
		  opacity:0.2,
		  inputs: { header: "Observación", type: "textarea", name: "observacion", ml:200 }
		};
		var getBtn = function(btnStr,__stop){
		  var bs = btnStr.split(",");
		  var __col = new Array();
		  for (i=0; i<bs.length; i++){
		    __col.push({value:bs[i]});
			if (__stop == true) break;
		  }
		  return __col;
		};
		//
		var genMsg = function(type,msg,options){
		   var msgObj = {};
		   var __stop = true;
		   var isMultBtn = false;
		   var __cType = "";
		   options = typeof options === 'undefined' ? {} : options;
		   switch(type){
		     case "i":type="info";break;		
		     case "w":type="alert";break;		
		     case "e":type="error";break;		
		     case "c":
			    __stop = false;
				isMultBtn = true;
				type = "confirm";
			 break;	
			 case "o":type="error"; __cType = "oops";break;	
			 case "l":type="prompt"; __cType = "login"; isMultBtn=true; __stop=false; break;	
			 case "p":type="prompt"; __cType = "prompt"; break;	
			 default:type="info";
		   }
		   if (isMultBtn) defaults.btnTxt = "Si,No,Cancelar";
		   if (__cType=="login") defaults.btnTxt = "Entrar,Cancelar";
		   if (__cType=="prompt") defaults.btnTxt = "Enviar";
		   //
		   
		   msgObj.title = options.title || defaults.title;
		   msgObj.type = type;
		   msgObj.content = msg||"Thebrain cooking this";
		   msgObj.buttons = getBtn(options.btnTxt || defaults.btnTxt,__stop);
		   		   
		   if(__cType=="oops"){
		     msgObj.showButtons = false;
		     msgObj.opacity = typeof options.opacity == "undefined"?defaults.opacity:options.opacity;
		   }else {
              msgObj.opacity = typeof options.opacity == "undefined"?defaults.opacity:options.opacity;
           }
		   
		   //CBMSG.prompt("",{cb:function(r,v){ debug(v);  $(v).each( function(i,o) { debug(o.name+" "+o.value)  } )     } })
		   
		   if(__cType=="login"){
		      msgObj.inputs = [
				{ header: "Usuario", type: "text", name: "user", ml: 15 },
				{ header: "Contraseña", type: "password", name: "pass", ml: 20 }
			  ]
  		   }
		   
		   if(__cType=="prompt" ){
		      msgObj.inputs = options.inputs||defaults.inputs
  		   }
		   
		   if (options.cb && typeof(options.cb)==="function" ){
		     if (__cType == "login" || __cType == "prompt") 
			    msgObj.success = function(result,values){options.cb(result,values)}
			 else msgObj.success = function(result){options.cb(result)}
		   }
		   try{
			return $.msgBox(msgObj);
		   }catch(e){
			 debug("jquery_functions.CBMSG.genMsg() Error: >> "+e.message);
		     if(type=="confirm") {
			   if (confirm(msg)) closeWin();
			 }
			 else alert(msgObj.content);
		   }
		};
		//Methods
        CBMSG.alert = function(msg,options){
		   genMsg("i",msg,options);
		};
		CBMSG.warning = function(msg,options){
		   genMsg("w",msg,options);
		};
		CBMSG.error = function(msg,options){
		   genMsg("e",msg,options);
		};
		CBMSG.confirm = function(msg,options){
		   genMsg("c",msg,options);
		};
		CBMSG.login = function(msg,options){
		   genMsg("l",msg,options);
		};
		CBMSG.prompt = function(msg,options){
		   genMsg("p",msg,options);
		};
		CBMSG.oops = function(msg,options){
		   genMsg("o",msg,options);
		};
   }( window.CBMSG = window.CBMSG || {}, jQuery ));
   
   /********************* SOUND ******************************/ 
   function soundAlert(options){
	  options = typeof options === 'undefined' ? {} : options;
      var defaults = {
	    aType:   {mp3:"audio/mpeg", ogg:"audio/ogg"},
		aSource: {mp3:"/"+getRootDir()+"/media/chimes.mp3", ogg:"/"+getRootDir()+"/media/chimes.ogg"},
		nPlay: 0,
		delay: 3000
	  };
	  var audio = document.createElement("audio");
	  var aSource = options.aSource || defaults.aSource;
	  var totPlay = 1, timer;
	  var __delay = typeof options.delay === 'undefined'?defaults.delay:options.delay;
	  
	  try{		  
		  audio.src = canPlay("mp3")?aSource["mp3"]:aSource.ogg;
		  audio.addEventListener('ended',function(){
		     timer = setTimeout(function () { audio.play(); totPlay++;  }, __delay);
			 doStop(totPlay);
		  },false);
		  //window.location.href.split(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/);
		  
		  //first play
		  audio.play();
		  	  
	  }catch(e){
	    debug("jquery_functions.soundAlert() Error: >> :::::::::::: THEBRAIN THE COOKER (: "+e.message);
	  }
	  
	  function doStop(totPlay){
	    var nPlay = typeof options.nPlay === 'undefined'?defaults.nPlay:options.nPlay;
		if (nPlay > 0)
		   if(timer && totPlay == nPlay)clearTimeout(timer);
	  }
	  function canPlay(t){
	     var __type = typeof options.aType === 'undefined'?defaults.aType[t]:options.aType[t];
	     return audio.canPlayType(__type) != "";
	  }
   
   }
   
   /************************ APPLY SOURCE TO TAB IFRAME ****************************/
   function lazyLoadingIF(options){
      options = typeof options === 'undefined' ? {} : options;
	  var defaults = {
		tabContainerLtnr: 'dhtmlgoodies_tabView1',
        tabContent: 'tabViewdhtmlgoodies_tabView1',
		tabPrefix: 'tabTab'
	  };
	  __tabContainerLtnr = typeof options.tabContainerLtnr === 'undefined'?defaults.tabContainerLtnr:options.tabContainerLtnr;
	  __tabPrefix = typeof options.tabPrefix === 'undefined'?defaults.tabPrefix:options.tabPrefix;
	  __clickListener = __tabPrefix+__tabContainerLtnr;
      __tabContent = typeof options.tabContent === 'undefined'?defaults.tabContent : options.tabContent;
      
      var $__clickListener = $("div[id*="+__clickListener+"_]");
      
      $__clickListener.click(function(c){
         c.stopImmediatePropagation();
         __lazyLoadingIF($(this), __tabContent, 'y');
      });
      
      $__clickListener.dblclick(function(c){
         c.stopImmediatePropagation();
         __lazyLoadingIF($(this), __tabContent);
      });
   }//end
   
   function __lazyLoadingIF($cObj, __tabContent, lazyClass){
       var $i = $cObj.index();
       var $tabContentainer = getJqObj(__tabContent + "_"+$i);
       var _frameId = $tabContentainer.data("tabframe");
       var _src = $tabContentainer.data("tabsrc");
       var hasOnClick = $tabContentainer.attr("onclick") != undefined;
       
       if (lazyClass) {            
            if (_frameId && _src && !$tabContentainer.hasClass("_if_loaded")){
               getJqObj(_frameId).attr('src', _src);
               $tabContentainer.addClass("_if_loaded");
            }
       }else{
          if (_frameId && _src){
             getJqObj(_frameId).attr('src', _src);
          }
       }
       hasOnClick && $tabContentainer[0].onclick();
   }

/************************ PERMITE HACER BUSQUEDA EN VEZ DE UTILIZAR EL BOTON [...] ****************************/  
/************************ VER CREACION DE ADMISION PARA UTILIZACION ****************************/  
function allowWriting(opts){
    var _inputs = opts.inputs;
    var _listener = opts.listener;
    var _keyboard = opts.keyboard; 
    var _iframe = opts.iframe;

    var _cusFunctions = opts.cusFunctions || {};
    var _keyCode = opts.keycode || 0;
    var _sp = opts.searchParams  || {};
    var _baseUrl = opts.baseUrls || {};
    var _xtraParams = opts.xtraParams || {};
    var _toBeCleaned = opts.toBeCleaned || {};
    var btnsToDisabled = opts.btnsToDisabled || [];
    var clearAfter = opts.clearAfter || 'y';

    if (_keyboard && (!_inputs || !_listener)) CBMSG.error("[allowWriting] Error tratando de usar esa acción. Contacte su administrador!");
    else if (!_iframe) CBMSG.error("[allowWriting] Error tratando de usar esa acción. Contacte su administrador!");
    else {
    
       $(_inputs).each(function(i, el) {
          $(this).attr('tabindex', '-1');
       });
        
        function __search(that){
            var cVal = $.trim(that.val());
            var _id = that.attr('id');
            var _searchParams = "";
            
            if (that.prop('readonly') == true) return;
            
            if (_cusFunctions[_id]) {
              var funcs = _cusFunctions[_id].fn ? _cusFunctions[_id].fn : [];
              var params = _cusFunctions[_id].params ? _cusFunctions[_id].params : [];
              for (f = 0; f<funcs.length; f++) {
                var func = funcs[f];
                if (typeof func === 'function') {
                  func.apply(null, params[f])
                }
              }
            }
			
            if (_xtraParams[_id]) {
               _searchParams = _xtraParams[_id];
               var qs = "";
               var andPart = _searchParams.split("&");
               for (a=0; a<andPart.length; a++){
                  var eqPart = andPart[a].split("=");
                  qs += "&" + eqPart[0] + "=" + (getJqObj(eqPart[1])).val();
               }
               _searchParams = qs.replace(/&/, "");
            }
            else _searchParams = _sp[_id] + "=" + cVal;
            var appendToUrl = "&context=preventPopupFrame&" + _searchParams;

            if (cVal && _baseUrl){
              
                var oldVal = that.attr("data-old-value");
                that.attr('data-old-value', cVal);
                
                if (oldVal && oldVal == cVal) return;
                
                for (bt = 0; bt<btnsToDisabled.length; bt++) {
                  getJqObj(btnsToDisabled[bt]).prop("disabled", true);
                }
                
                console.log(clearAfter === 'y')
 
                if(clearAfter === 'y') that.val('');
                
                $(_iframe).show(0).attr('src',_baseUrl[_id]+appendToUrl);
                
                var observer = new MutationObserver(function (changes) {
                  const target = changes[0].target
               
                  if(target && target.style.display == 'none') {
                      observer.disconnect();
                     
                      for (bt = 0; bt<btnsToDisabled.length; bt++) {
                        getJqObj(btnsToDisabled[bt]).prop("disabled", false);
                      }
                  }
                });

              observer.observe($(_iframe)[0], { 
                attributes: true, 
                childList: true, 
                attributeFilter: ['style'] 
              });
            }
        }
        

        function __keyboardInput(){
          $(document).on("dblclick", _inputs, function(c){
            var name = this.name;
            if (_toBeCleaned[name]) {
              var toBeCleanedFields = _toBeCleaned[name];
              if(!this.readOnly) this.value = "";
              for (var c = 0; c < toBeCleanedFields.length; c++) {
                var $el = getJqObj(toBeCleanedFields[c]);
                if($el.prop('readonly') === false) $el.val("");
              }
            } else {
              // $(_inputs).val("");
              // console.log("2clearing", _inputs)
            }
          });
          
          $(document).on("blur", _inputs, function(e) {
            console.log(e.type)
            var _continue = true; 

            /*if (!_keyCode) _continue = true;
            else if (e && _keyCode && e.keyCode !== _keyCode ) _continue = false;
            else if (_keyCode) _continue = true;*/
            
            if(_continue) __search($(this));

          });
        }
        
        function __noKeyboardInput(){
          __search($(_inputs)); 
        }
        
        if (_keyboard) __keyboardInput();
        else __noKeyboardInput();
    }
}
/*Workaround to fire onSubmit event for buttons defined as submit on FormBean2*/
function __submitForm(form,objValue){setBAction(form.name,objValue);$('<input>',{type:'submit',style:'display:none'}).appendTo(form).click().remove();}
function enableDisable(tag_name, val){
	$("#"+tag_name).prop('readonly',(val=='N'));
	if(val=='S') $("#"+tag_name).removeClass("FormDataObjectDisabled").addClass("FormDataObjectEnabled");
	else $("#"+tag_name).removeClass("FormDataObjectEnabled").addClass("FormDataObjectDisabled").val("");	
}