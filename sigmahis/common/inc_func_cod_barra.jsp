<%
String minCarBarCode = java.util.ResourceBundle.getBundle("issi").getString("minCharBarCode");
if(minCarBarCode == null || minCarBarCode.trim().equals("")) minCarBarCode = "8";
String msgMenor8Car = (request.getParameter("msgMenor8Car")==null?"":"El codigo de barra es menor a "+minCarBarCode+" caracteres");
String msgMismoCod = (request.getParameter("msgMismoCod")==null?"":request.getParameter("msgMismoCod"));
String dispBarCode = (request.getParameter("dispBarCode")==null?"n":request.getParameter("dispBarCode"));
String msgCBExiste = (request.getParameter("msgCBExiste")==null?"El codigo de barra ya está registrado para otro articulo!":request.getParameter("msgCBExiste"));
String substrType = (request.getParameter("substrType")==null?"01":request.getParameter("substrType"));
%>
<script type="text/javascript">
	function ctrlBC(){
	  document.getElementById("save").disabled = true;
	}
	function doUpdateBC(index,obj){
		var barCodeExists = document.getElementById("barCodeExists"+index).value;
		var codArticulo = document.getElementById("cod_articulo"+index).value;
		var codClase = document.getElementById("cod_clase"+index).value;
		var codFlia = document.getElementById("cod_flia"+index).value;
		var barCode = obj.value;
		var savingObj = document.getElementById("saving"+index);
		var hasUpdated = false;
		var flag = true;
		var msg = "";
		var barCodOld =document.getElementById("oldBarCode"+index).value;
        //var codBar = replaceAll(barCode,"\'","\'\'");
        var codBar = replaceAll(barCode,"\'","\'\'");
        codBar = getGS1BarcodeData('<%=request.getContextPath()%>',codBar, '<%=substrType%>');

		if (barCode.length < parseInt(<%=minCarBarCode%>)) {
			msg = '<%=msgMenor8Car%>';
			flag = false;
			//obj.value=barCodOld;
		}else
		if (barCode.length >= parseInt(<%=minCarBarCode%>) && (barCode.trim()==barCodOld.trim())){
			//msg = '<%=msgMismoCod%>';
			flag = false;
		}else
		if(BCAlreadySaved(codBar)){
		  flag = false;
		  msg = '<%=msgCBExiste%>';
		  obj.value=barCodOld;
		}
		<%if(dispBarCode.equals("y")){%>
		dispBarCode(barCode);
		<%}%>
		if (flag){
			  savingObj.innerHTML = '<img src = "../images/saving.gif">';

			  hasUpdated = executeDB("<%=request.getContextPath()%>",'update tbl_inv_articulo set cod_barra = \''+codBar+'\',bar_code_refer=\'CBL\',usuario_modif= \'<%=(String) session.getAttribute("_userName")%>\',fecha_modif=sysdate where cod_articulo = '+codArticulo+' and cod_flia = '+codFlia+' and cod_clase = '+codClase+' and compania=<%=(String) session.getAttribute("_companyId")%>');

			  if (hasUpdated){
				 document.getElementById("oldBarCode"+index).value = barCode;
				 document.getElementById("barCodeExists"+index).value = "y";
				 setTimeout(function(){removeSaving(savingObj)}, 1000);
			  }else {debug("Encontramos un problema al tratar de actualizar el código de barra!");}

		}

		if (barCode != "" && msg != ""){
			alert(msg);
		}

	}
	function removeSaving(savingObj){
		savingObj.innerHTML = "&nbsp;";
	}
    <%if(dispBarCode.equals("y")){%>
	function dispBarCode(value){
		var dispBCobj = document.getElementById("dispBC");
		dispBCobj.innerHTML = value;
	}
	<%}%>
	function ctrlUpdate(index,obj){
		var oldValue = document.getElementById("oldBarCode"+index).value;
		var barCodeExists = document.getElementById("barCodeExists"+index).value;
		if ( obj.value.length >= parseInt(<%=minCarBarCode%>) && (obj.value != oldValue) ){
			document.getElementById("barCodeExists"+index).value = "n";
		}
	}
	function BCAlreadySaved(curVal){
	  return hasDBData('<%=request.getContextPath()%>','tbl_inv_articulo','trim(cod_barra)=\''+curVal+'\' and compania=<%=(String) session.getAttribute("_companyId")%> ');
	}
	//window.BCAlreadySaved = BCAlreadySaved;
</script>