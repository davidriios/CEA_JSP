<%
/*
	Agregar allowEnter(event) en evento keypress
	del input de codigo barra

	Usage:
	<jsp:include page="../common/inc_barcode_filter.jsp" flush="true">
	<jsp:param name="formEl" value="formName"></jsp:param>
	<jsp:param name="barcodeEl" value="barcodeName"></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="Error0,Error1,Error2,Error3"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value="nombre,test2,apellido"></jsp:param>
</jsp:include>
*/
boolean crypt = false;
try { crypt = "YS".contains((String) session.getAttribute("_crypt")); } catch(Exception e) { }

String formEl = request.getParameter("formEl"); // form donde esta el input cb
String barcodeEl = request.getParameter("barcodeEl"); // input name código barra
String fieldsToBeCleared = request.getParameter("fieldsToBeCleared"); // separados por coma, input que se limpiaran para que se busca solamente por codigo barra
String wrongFrmElMsg = request.getParameter("wrongFrmElMsg"); // mensaje de error. NB. es posible que se cambia el método formExists
String substrType = (request.getParameter("substrType")==null?"01":request.getParameter("substrType"));
String lastBarcode = (request.getParameter("last_barcode")==null?"01":request.getParameter("last_barcode"));
String formQtyToIncCtx = (request.getParameter("form_qty_to_increment_context")==null?"01":request.getParameter("form_qty_to_increment_context"));
String formQtyField = (request.getParameter("form_qty_to_field")==null?"01":request.getParameter("form_qty_to_field"));
String triggerFnOnKeypress = (request.getParameter("triggerFnOnKeypress")==null?"":request.getParameter("triggerFnOnKeypress"));

if (formEl == null) formEl = "";
if (barcodeEl == null) barcodeEl = "";
if (fieldsToBeCleared == null) fieldsToBeCleared = "";
if (wrongFrmElMsg == null) wrongFrmElMsg = "No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto";
%>
<script type="text/javascript">
	/**
	* Limpia los otros campos en formEl,
	* para que se busque solamente por código barra
	*
	* return void
	**/
		var shouldDoSearch = true;
	function clearExtraFields(){
		 var fieldsToBeCleared = "<%=fieldsToBeCleared%>";
		 var wrongFrmElMsg = "<%=wrongFrmElMsg%>";
		 var formEl = "<%=formEl%>";
		 var splitedFields = new Array();
		 var totEl = 0;
		 var ignoredObj = {"hidden":1,"button":1,"submit":1};

		 if (fieldsToBeCleared == ""){
				totEl = document.forms[formEl].elements.length;
			for (var e = 0; e<=totEl; e++){
				if ( document.forms[formEl].elements[e]){
				if (!(document.forms[formEl].elements[e].type in ignoredObj)){
					 fieldsToBeCleared += document.forms[formEl].elements[e].name+",";
				}else{}
			}
			}
		 }

		 splitedFields = fieldsToBeCleared.trim().split(",");

		 if (formExists(formEl,'<%=barcodeEl%>',wrongFrmElMsg)){
			 for(var i=0; i< splitedFields.length; i++){
				if ((document.forms[formEl][splitedFields[i]] != null) && document.forms[formEl][splitedFields[i]].name != "<%=barcodeEl%>" ){
					document.forms[formEl][splitedFields[i]].value = "";
				}
			 }
		 }

	}
	/**
	* Verifica que el formulario existe, que el campo de texto
	* del código de barra existe
	*
	* @param formEl Object (El formulario)
	* @param barcodeEl String (campo código barra)
	* @param msg String (Errores separados por coma)
	*
	*return boolean
	**/
	function formExists(formEl, barcodeEl, msg){
			 if (formEl == "") {
					if(msg.split(",")[0]) alert(msg.split(",")[0]);
					return false;
			 }else if(document.forms[formEl] == undefined){
					 if(msg.split(",")[1]) alert(msg.split(",")[1]+" ["+formEl+"]");
					 return false;
			 }else if(barcodeEl == ""){
					 if(msg.split(",")[2]) alert(msg.split(",")[2]);
					 return false;
			 }else if (document.forms[formEl][barcodeEl] == undefined){
					if(msg.split(",")[3]) alert(msg.split(",")[3]+" ["+barcodeEl+"]");
					return false;
			 }
			 return true;
	}
	/**
	* Llama clearExtraFields() si formExists() y si código de barra
	* tiene algo y hace submit si todo sale bien
	* return void
	**/
	function doSearch(){
			var barCodeToBeSearched = "", lastBarcode = "<%=lastBarcode%>";
			var wrongFrmElMsg = "<%=wrongFrmElMsg%>";
			var formEl = "<%=formEl%>";
			var triggerFnOnKeypress = "<%=triggerFnOnKeypress%>";
			var barcodeEl = '<%=barcodeEl%>';
					var qty = 0;

			if (formExists(formEl,barcodeEl,wrongFrmElMsg)){
				 barCodeToBeSearched = document.forms[formEl][barcodeEl].value;

							if (barCodeToBeSearched!=""){
									//clearExtraFields();
									barCodeToBeSearched = <% if (crypt) { %>doReplace<% } %>(getGS1BarcodeData('<%=request.getContextPath()%>',barCodeToBeSearched, '<%=substrType%>'));

									if (document.forms[formEl][lastBarcode] && document.forms[formEl][lastBarcode].value && barCodeToBeSearched == document.forms[formEl][lastBarcode].value){

												var oldVal = $(".<%=formQtyField%>"+barCodeToBeSearched, <%=formQtyToIncCtx%>).val() || 0;
												oldVal++;
												$(".<%=formQtyField%>"+barCodeToBeSearched, <%=formQtyToIncCtx%>).val(oldVal).change();
												barCodeToBeSearched = "";
												document.forms[formEl][barcodeEl].select();

										/*$(document.forms[formEl]).submit(function(e){
												var oldVal = $(".<%=formQtyField%>"+barCodeToBeSearched, <%=formQtyToIncCtx%>).val() || 0;
												oldVal++;
												$(".<%=formQtyField%>"+barCodeToBeSearched, <%=formQtyToIncCtx%>).val(oldVal).change();
												alert(oldVal)
												barCodeToBeSearched = "";
												document.forms[formEl][barcodeEl].select();
												e.preventDefault();
												return false;
										});*/
									}else {
											<% if (crypt) { %>barCodeToBeSearched = encodeURIComponent(Aes.Ctr.encrypt(barCodeToBeSearched,'_cUrl',256));<% } %>
											document.forms[formEl][barcodeEl].value = barCodeToBeSearched;
											if(document.forms[formEl]['__tp_cod_'])
												document.forms[formEl]['__tp_cod_'].value = 'S';
											if (triggerFnOnKeypress.trim() == '') document.forms[formEl].submit();
											else {
												//if (window[triggerFnOnKeypress.trim()]) window[triggerFnOnKeypress.trim()];
												//console.log('Func name = '+triggerFnOnKeypress);
												var func = window[triggerFnOnKeypress];
												if (typeof func == "function") {
													//console.log('executing...');
													func();
												}
											}
									}
									// 847610009173A 013803099010
							}
			}
		}


	function doReplace(bc){
		 var specialCharsMap = {
			 'Á':'~A~',
			 'Á':'~A~',
			 'É':'~E~',
			 'Í':'~I~',
			 'Ó':'~O~',
			 'Ú':'~U~',
			 'Ñ':'~ENIE~',
				 'á':'~a~',
			 'á':'~a~',
			 'é':'~e~',
			 'í':'~i~',
			 'ó':'~o~',
			 'ú':'~u~',
			 'ñ':'~enie~'
		 };
		 //bc = bc.toUpperCase();
			var weirdify = bc.replace(/[ÁÉÍÓÚÑáéíóúñ]|gw|kw/g, function(s) {
			return specialCharsMap[s];
		});
		 return weirdify;
	}


	/**
	* Sobreescribimos capslock.js, para permitir
	* que el lector de código de barra haga Enter
	*
	* @param: evt (El evento onkeypress)
	* return void
	*/
	function allowEnter(evt){
			if(evt.keyCode == 13) doSearch();
		}
</script>