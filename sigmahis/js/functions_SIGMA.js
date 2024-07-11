(function(SIGMAMSG, $, undefined){

	var defaults = {
		title: "Sigma HIS",
		btnTxt: "Ok",
		opacity: 0.2,
		inputs: {header: "Observación", type: "textarea", name: "observacion", ml: 200}
	};

	var getBtn = function(btnStr, __stop){
		var bs = btnStr.split(",");
		var __col = new Array();

		for (i=0; i<bs.length; i++){
			__col.push({value:bs[i]});
			
			if (__stop == true) break;
		}

		return __col;
	};

	var genMsg = function(type, msg, options, imgname){
		var msgObj = {};
		var __stop = true;
		var isMultBtn = false;
		var __cType = "";
		options = typeof options === 'undefined' ? {} : options;

		switch(type){
			case "i": type="info"; break;
			case "w": type="alert"; break;
			case "e": type="error"; break;
			case "c":
				__stop = false;
				isMultBtn = true;
				type = "confirm";
				break;
			case "o": type="error"; __cType = "oops"; break;
			case "l": type="prompt"; __cType = "login"; isMultBtn=true; __stop=false; break;
			case "p": type="prompt"; __cType = "prompt";
			case "cimg":
				__stop = false;
				isMultBtn = true;
				type = "confirmimg";
			    break;
			default: type="info";
		}

		if (isMultBtn) defaults.btnTxt = "Si,No,Cancelar";
		if (__cType=="login") defaults.btnTxt = "Entrar,Cancelar";
		if (__cType=="prompt") defaults.btnTxt = "Enviar";

		msgObj.title = options.title || defaults.title;
		msgObj.type = type;
		msgObj.content = msg || "Thebrain cooking this";
		msgObj.buttons = getBtn(options.btnTxt || defaults.btnTxt,__stop);
		msgObj.imgname = imgname;

		if(__cType=="oops"){
			msgObj.showButtons = false;
			msgObj.opacity = typeof options.opacity == "undefined"?defaults.opacity:options.opacity;
		} else {
	    	msgObj.opacity = typeof options.opacity == "undefined"?defaults.opacity:options.opacity;
		}

		if(__cType=="login"){
			msgObj.inputs = [
				{header: "Usuario", type: "text", name: "user", ml: 15},
				{header: "Contraseña", type: "password", name: "pass", ml: 20}
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
			debug("functions_SIGMA.SIGMAMSG.genMsg() Error: >> "+e.message);

			if(type=="confirm") {
				if (confirm(msg)) closeWin();
			} else alert(msgObj.content);
		}
	};

    SIGMAMSG.alert = function(msg, options, imgname){
		genMsg("i", msg, options, imgname);
	};

	SIGMAMSG.warning = function(msg, options, imgname){
		genMsg("w", msg, options, imgname);
	};

	SIGMAMSG.error = function(msg, options, imgname){
		genMsg("e", msg, options, imgname);
	};

	SIGMAMSG.confirm = function(msg, options, imgname){
		genMsg("c", msg, options, imgname);
	};

	SIGMAMSG.confirmimg = function(msg, options, imgname){
		genMsg("cimg", msg, options, imgname);
	};

	SIGMAMSG.login = function(msg, options, imgname){
		genMsg("l", msg, options, imgname);
	};

	SIGMAMSG.prompt = function(msg, options, imgname){
		genMsg("p", msg, options, imgname);
	};

	SIGMAMSG.oops = function(msg, options, imgname){
		genMsg("o", msg, options, imgname);
	};

}(window.SIGMAMSG = window.SIGMAMSG || {}, jQuery));