<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();
ArrayList al2 = new ArrayList();

String sql = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String docId = "";
String fp = request.getParameter("fp");
String cds = request.getParameter("cds");
String estado = request.getParameter("estado");
String catId = request.getParameter("catId");
String tab = request.getParameter("tab");
String careDate = request.getParameter("careDate");
if (tab == null) tab = "0";
String imagesFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
String rootFolder = java.util.ResourceBundle.getBundle("path").getString("root");

//usadas para el proceso de Expediente > Consultas > Secciones Guardadas
String section = request.getParameter("section");
String sectionDesc = request.getParameter("sectionDesc");
String path = request.getParameter("path");

if (!UserDet.getUserProfile().contains("0") && CmnMgr.getCount("select count(*) from tbl_sec_profiles a, tbl_sec_module b where a.profile_id in ("+CmnMgr.vector2numSqlInClause(UserDet.getUserProfile())+") and a.module_id=b.id and a.module_id=11")==0) throw new Exception("Usted no tiene el Perfil para accesar al Expediente. Por favor consulte con su administrador!");

if (mode == null) mode = "add";
if (fp == null) fp = "";
if (cds == null) cds = "";
if (estado == null) estado = "";
if (careDate==null) careDate = "";
if (catId==null) catId = "";

String nuevoTabExpediente = "N";
try {
    nuevoTabExpediente = java.util.ResourceBundle
                                  .getBundle("issi")
                                  .getString("expediente.iconificado.nuevo.tab.expediente");
}
catch (Exception e) {
}

if (fp.equalsIgnoreCase("paciente"))
{
	if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
	if (noAdmision == null) noAdmision = "0";
}
else if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (CmnMgr.getCount("select count(*) from tbl_adm_atencion_cu where pac_id="+pacId+((noAdmision != null && !noAdmision.trim().equals("") && !noAdmision.trim().equals("0"))?" and secuencia="+noAdmision:""))==0) throw new Exception("El Paciente no tiene registro de atención. Por favor consulte con su Administrador!");

String profiles = CmnMgr.vector2numSqlInClause(UserDet.getUserProfile());

sql = "select a.id as OptValueColumn, a.name as OptLabelColumn, (select min(display_order) from tbl_sal_exp_docs_profile where doc_id=a.id"+((!UserDet.getUserProfile().contains("0") && !profiles.trim().equals(""))?" and profile_id in ("+profiles+")":"")+") as OptTitleColumn, decode(a.icon_path,null,' ','"+imagesFolder.replaceAll(rootFolder,"..")+"/'||a.icon_path) icon_path from tbl_sal_exp_docs a where a.id in (select doc_id from tbl_sal_exp_docs_cds where cds_code in (select cds from tbl_adm_atencion_cu where pac_id="+pacId+((noAdmision != null && !noAdmision.trim().equals("") && !noAdmision.trim().equals("0"))?" and secuencia="+noAdmision:"")+")) and a.status='A' order by 3, a.name";
al = SQLMgr.getDataList(sql);

if (al.size() == 0) throw new Exception("Los Documentos del Expediente no están definidos. Por favor consulte con su Administrador!");
docId = ((CommonDataObject) al.get(0)).getOptValueColumn();

  sql = "SELECT codigo, descripcion FROM tbl_sal_expediente_secciones ";
  al2 = SQLMgr.getDataList(sql);
  for (int i=0; i<al2.size(); i++)
  {
	cdo = (CommonDataObject) al2.get(i);
     try
    {
      iExpSecciones.put(cdo.getColValue("codigo"),cdo);
    }
    catch(Exception e)
    {
      System.err.println(e.getMessage());
    }
  }
  
String doSimpleBlinking = "1"; // "0" para usar el blinking tradicional  
String reloadAlertBarTimer = "1"; //1 minute, will be converted to milliseconds
try{reloadAlertBarTimer = java.util.ResourceBundle.getBundle("issi").getString("exp.reloadAlertBarTimer");}catch(Exception e){reloadAlertBarTimer = "1";}
try{doSimpleBlinking = java.util.ResourceBundle.getBundle("issi").getString("exp.doSimpleBlinking");}catch(Exception e){doSimpleBlinking = "1";}

CommonDataObject cdoP = (CommonDataObject) SQLMgr.getPacData(pacId, noAdmision,",get_weight_height("+pacId+","+noAdmision+",null) as weight_height, avatar",null,null);

String company = (String) session.getAttribute("_companyId");
CommonDataObject cdoX = SQLMgr.getData("select nvl(get_sec_comp_param("+company+", 'CHK_ANT_ALERGIA'), 'N') chk_ant_alergia, nvl(get_sec_comp_param("+company+", 'ANT_ALERGIA_ID'), 5) ant_alergia_id , nvl(get_sec_comp_param("+company+", 'CDS_SOP'), 24) cds_sop from dual ");
if (cdoX == null) {
    cdoX = new CommonDataObject();
    cdoX.addColValue("chk_ant_alergia","N");
    cdoX.addColValue("ant_alergia_id","5");
    cdoX.addColValue("cds_sop","24");
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>

<link rel="stylesheet" type="text/css" href="../css/dhtmlxtabbar.css">
<script  src="../js/ChartNew.js"></script>
<script  src="../js/dhtmlxcommon.js"></script>
<script  src="../js/dhtmlxtabbar.js"></script>

<link rel="stylesheet" href="<%=request.getContextPath()%>/css/purecss/pure-min.css">
<!--[if lte IE 8]>
	<link rel="stylesheet" href="css/purecss/grids-responsive-old-ie-min.css">
<![endif]-->
<!--[if gt IE 8]><!-->
	<link rel="stylesheet" href="<%=request.getContextPath()%>/css/purecss/grids-responsive-min.css">
<!--<![endif]-->

<!--[if lte IE 8]>
	<link rel="stylesheet" href="<%=request.getContextPath()%>/css/purecss/layouts/marketing-old-ie.css">
<![endif]-->
<!--[if gt IE 8]><!-->
	<link rel="stylesheet" href="<%=request.getContextPath()%>/css/purecss/layouts/marketing.css">
<!--<![endif]-->
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/purecss/font-awesome.css">

<script>

var tabbar;
var tabArray = new Array();

const nuevoTabExpediente = '<%=nuevoTabExpediente%>';

document.title="Expediente - "+document.title;

function doRedirect(secDesc,seccion,mode,editable,path) {

    var thePopupFrame = document.getElementById( "popupFrame" );
    var thePopupDocument = thePopupFrame.contentDocument || thePopupFrame.contentWindow.document;
    var thePopupTitle = thePopupDocument.getElementById( "popupTitle" );
    if ( thePopupTitle ) {
        reloadSectionBeforeHidingPopWin();
        return;
    }

    /* HPP 1*/ 
    if(checkAntAler(seccion)) {
        /* /HPP 1*/
        pacId=<%=pacId%>;
        noAdmision=<%=noAdmision%>;
        cds='<%=cds%>';
        docId = ( ( typeof document.form1.docId ) != "undefined"
                  ? document.form1.docId.value
                  : "<%=docId%>" );
        var xtraQS = "desc=" + secDesc +
                     "&pacId=" + pacId +
                     "&seccion=" + seccion +
                     "&noAdmision=" + noAdmision +
                     "&mode=" + mode +
                     "&cds=" + cds +
                     "&defaultAction=" + editable +
                     "&docId=" + docId +
                     "&careDate=<%=careDate%>" +
                     "&catId=<%=catId%>" +
                     "&expVer=2" +
                     "&estado=<%=estado%>";
	
        if (seccion != null && seccion!="" && path!=null && path != ""){
            toPage = path+xtraQS;
            try {
                navBar(toPage,secDesc);
            }
            catch(e) {
                debug("ERROR doRedirect :: "+e.message);
            }
        }
        /* HPP 1*/
    }
    /* /HPP 1*/ 
}

let isOpeningPopUp = false;
let newHeightForCurrentState = ( screen.height > 900 )
                               ? screen.height * 0.68
                               : screen.height * 0.52;
function doOpenPopUp(secDesc, seccion, path, firstFoundDocId){
    isOpeningPopUp = true;
    if ( checkAntAler(seccion) ) {
        const pacId = <%=pacId%>;
        const noAdmision = <%=noAdmision%>;
        const cds = '<%=cds%>';
	    const docId = ( document.form1.docId.value )
	                  ? document.form1.docId.value
	                  : firstFoundDocId;

	    const xtraQS = "desc=" + secDesc +
	                   "&pacId=" + pacId +
	                   "&seccion=" + seccion +
	                   "&noAdmision=" + noAdmision +
	                   "&mode=" +
	                   "&cds=" + cds +
	                   "&defaultAction=1" +
	                   "&docId=" + docId +
	                   "&careDate=<%=careDate%>&catId=<%=catId%>&expVer=2&estado=<%=estado%>";

	    if (seccion != null && seccion!="" && path!=null && path != ""){

            showPopWin(path + xtraQS,
                winWidth*.95,
                winHeight*.95,
                null,
                true,
                '');

            setTimeout(attachReloadingEventToPopUpClosingButton(),345);

        }
    }
}

function reloadSectionBeforeHidingPopWin() {
    if ( document.getElementById("tabViewdhtmlgoodies_tabView1_0").style.display != "none" ) {
        //Recargar estado actual
        loadEstadoActual();
    }
    else if ( document.getElementById("tabViewdhtmlgoodies_tabView1_1").style.display != "none" ) {
        //Recargar nueva pestaña Expediente
        $('div.doc-container.selected').click();
    }
    hidePopWin(false);
}

function attachReloadingEventToPopUpClosingButton() {
    var thePopupClosingButton = document.getElementById("popCloseBox");
    if ( thePopupClosingButton ) {
        thePopupClosingButton.onclick = reloadSectionBeforeHidingPopWin;
        document.getElementById("popupContainer").style.overflow = "auto";
        document.getElementById("popupFrame").style.width = ( winWidth * 0.94 ) + "px";
    }
    else{
        console.log("ERROR - thePopupClosingButton in the popup not found");
    }
}

// HPP 2
function checkAntAler(secId){
  var chkAntAlergia = ("<%=cdoX.getColValue("chk_ant_alergia","N")%>" == "Y" || "<%=cdoX.getColValue("chk_ant_alergia","N")%>" == "S");
  var antAlergia = "<%=cdoX.getColValue("ant_alergia_id","5")%>";
  if ("<%=estado%>" !="F" && chkAntAlergia && secId == antAlergia) {
    var c = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_alergia_paciente'," pac_id = <%=pacId%> and admision = <%=noAdmision%>",'');
    if (!parseInt(c,10)) { 
         parent.CBMSG.warning("El paciente no tiene Antecedentes Alérgicos registrados. Por politicas del Hospital es necesario registrar Antecedentes Al�rgicos antes de Solicitar MEDICAMENTOS !!!");
        return false;
    }
  }
  <% if (!estado.equalsIgnoreCase("F")) { %>
  if(secId==75){
    var x= getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b',' a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.codigo=b.orden_med and b.pac_id = <%=pacId%> and b.secuencia = <%=noAdmision%> and b.forma_solicitud=\'T\' and nvl(b.validada,\'N\') =\'N\' and ((b.omitir_orden=\'N\' and b.estado_orden=\'A\') or (b.ejecutado=\'N\' and b.estado_orden=\'S\' )) ',''); 	
	if(parseInt(x,10)){parent.CBMSG.warning("El paciente tiene ordenes medicas telefonicas pendiente por refrendar. Por politicas del Hospital es necesario que refrende las ordenes antes de darle salida!!!");return false;}
  }
<% } %>
  return true;
}

function validateTab(toPage){
    retVal=-1;
    for(var i=0;i<tabArray.length;i++)
    {
        //alert(toPage+"            "+tabArray[i]);
        if(toPage==tabArray[i])
            retVal=i;
    }
    return retVal;
}
function navBar(toPage,secDesc) {

    /* La nueva pestaña para expedientes no maneja múltiples pestañas de secciones a la vez */
    if ( nuevoTabExpediente === 'S' )
        return;

    var tabWidth=secDesc.length * 7;

    adjustDivContent();

    if(toPage=="") {
        tabbar = new dhtmlXTabBar("a_tabbar", "top"); tabbar.setSkin('modern');
        tabbar.setImagePath("../js/imgs/"); tabbar.setHrefMode("iframes");
        tabbar.enableTabCloseButton(true);
        tabbar.enableAutoReSize();
        tabbar.enableScroll(true);
}
else {
    tabExist=validateTab(toPage);

    if(tabExist>=0) {
        if( tabbar.cells("nav"+tabExist) == null
                        || tabbar.cells("nav"+tabExist) == undefined ) {
            tabArray[tabExist]="Closed";
            navBar(toPage,secDesc);
        }
        else
            tabbar.setTabActive("nav"+tabExist);
    }
    else {
        tabbar.addTab("nav"+(tabArray.length), secDesc, tabWidth+"px",0);
        tabbar.setContentHref("nav"+(tabArray.length), toPage+'&_viewMode=<%=mode%>');
        tabbar.setTabActive("nav"+(tabArray.length));
        tabbar.attachEvent("onSelect", function(id) {
                if (tabbar.cells(id)._frame);
                    return true;
        });
        tabbar.attachEvent("onTabClose", function(id) {
                if (tabbar.cells(id)._frame);
                    tabArray[parseInt(id.substring(3))]="Closed";
                    return true;
        });
        tabArray[tabArray.length]=toPage;}
    }
}


function refreshSecciones(docId)
{
	var idFlujo = $("#flujo_id").val();
	setFrameSrc('iSecciones',
	            '../expediente/expediente_secciones_flow.jsp?mode=<%=mode%>&docId='
	                + docId
	                + '&estado=<%=estado%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&careDate=&idFlujo='
	                + idFlujo);
}

function refreshAdmision(noAdmision)
{
	if(noAdmision.trim()!='')
<%
if (fp.equalsIgnoreCase("paciente"))
{
%>
	window.location='../expediente/expediente_config.jsp?mode=view&pacId=<%=pacId%>&noAdmision='
	                    + noAdmision
	                    + '&fp=paciente';
<%
}
else
{
%>
	//abrir_ventana1('../expediente/expediente_config.jsp?mode=view&pacId=<%=pacId%>&noAdmision='+noAdmision+'&fp=history');
	openWin('../expediente/expediente_config.jsp?mode=view&pacId=<%=pacId%>&noAdmision='+noAdmision+'&fp=history','expediente_config_history',getPopUpOptions(true,true,true,true));
<%
}
%>
}

function setPatientInfo(formName,iframeName)
{
	if(iframeName==undefined||iframeName==null)
	{
		document.forms[formName].dob.value=document.paciente.fechaNacimiento.value;
		document.forms[formName].codPac.value=document.paciente.codigoPaciente.value;
	}
	else
	{
		var thePopupFrame = document.getElementById( "popupFrame" );
        var thePopupDocument = thePopupFrame.contentDocument || thePopupFrame.contentWindow.document;
        var thePopupForm = thePopupDocument.getElementById( formName );
		if ( thePopupForm ){
		    thePopupForm.dob.value = document.paciente.fechaNacimiento.value;
		    thePopupForm.codPac.value = document.paciente.codigoPaciente.value;
		}
		else{
		    tabbar.tabWindow(tabbar.getActiveTab()).document.forms[formName].dob.value=document.paciente.fechaNacimiento.value;
		    tabbar.tabWindow(tabbar.getActiveTab()).document.forms[formName].codPac.value = document.paciente.codigoPaciente.value;
		}
	}
}

var warning = true;

function overrideCloseWin(){
    if ( tabbar != undefined && tabbar.getActiveTab() != null ){
	 var estado = getDBData('<%=request.getContextPath()%>','estado','tbl_adm_atencion_cu','pac_id=<%=pacId%> and secuencia=<%=noAdmision%>','');
		if(estado != 'F')
		{
           if (confirm("Tiene Formularios abiertos y no queremos que pierda sus cambios!,\nQuiere usted continuar con esa acción?")){
			 warning = false;
		     closeWin();
		 	}else{return false;}
		}else return closeWin();
    }else{
	  closeWin();
	}
}

window.onbeforeunload = function() {
  if (warning && tabbar != undefined && tabbar.getActiveTab() != null ) {
  <%if(SecMgr.checkLogin(session.getId())){%>
  	var estado = getDBData('<%=request.getContextPath()%>','estado','tbl_adm_atencion_cu','pac_id=<%=pacId%> and secuencia=<%=noAdmision%>','');
		if(estado != 'F' )
		{
    		return "Tiene Formularios abiertos y no queremos que pierda sus cambios!,\nQuiere usted continuar con esa acción?";
		}
	<%}%>
  }
}

function reloadAlerts(){
  var _timer = parseInt("<%=reloadAlertBarTimer%>",10) * 60 * 1000;
  $.ajax({
	 url: '../common/ialert.jsp?fp=expediente&pacId=<%=pacId%>&displayArea=expediente&facturadoA=&admision=<%=noAdmision%>&doSimpleBlinking=<%=doSimpleBlinking%>',
	 cache: false,
	 dataType: "html"
  }).done(function(data){
		$("#alerContainer").html("");
		$("#alerContainer").html(data);
  }).fail(function(jqXHR, textStatus){
	debug("La request has fallido: " + textStatus);
  });
  setTimeout('reloadAlerts()',_timer);
}

function formatAnnotateLabel(v1,v2,v3){
    var _suffix = "";
	if (v1=="Temp." ) _suffix = "°C";
	return '('+v2+' , '+v3+_suffix+')';
}

let listaSeccionesNuevaPestanhaExpediente;
function recargarNuevaPestanhaExpediente(nuevaLista, theDocId) {

    listaSeccionesNuevaPestanhaExpediente = JSON.parse(nuevaLista);

    $("#main-container").animate({ height: newHeightForCurrentState }, 200);

    if ( listaSeccionesNuevaPestanhaExpediente.length > 0 ) {

        $("#nuevaPestanhaExpedienteContainer").html("" +
        "<input id=\"nvaPestanhaExpSearchInputField\" " +
                "class=\"nuevaPestanhaExpedienteSearchInput top-menu-search-input\" " +
                "type=\"search\"  " +
                "autocomplete=\"off\"  " +
                "placeholder=\"Buscar\"  " +
                "onkeyup=\"mostrarElementosFiltradosNuevaPestanhaExpediente(" + theDocId + ", this.value)\"  " +
                "aria-label=\"Buscar\">" +
        "<div id=\"nvaPestanhaExpSearchResultsContainer\" " +
                      "class=\"top-menu-search-results-container\" " +
                      "style=\"\" > " +
        "    <div class=\"list-group\" " +
                          "style=\"margin-bottom: 0px;\">" +
        "    </div>" +
        "</div>" +
        "<div id=\"nvaPestanhaExpSectionsContainer\" >" +
        "</div>");

        mostrarElementosFiltradosNuevaPestanhaExpediente(theDocId);
    }
}
function mostrarElementosFiltradosNuevaPestanhaExpediente(theDocId, searchedString) {

    listaSeccionesFiltradaPestanhaExpediente = JSON.parse(JSON.stringify(listaSeccionesNuevaPestanhaExpediente));

    if ( searchedString ){
        listaSeccionesFiltradaPestanhaExpediente = listaSeccionesFiltradaPestanhaExpediente.filter(
            (currentValue, index) => {

                let alteredDescripcion = currentValue.descripcion.normalize('NFD').replace(/[\u0300-\u036f]/g, '');

                let response = true;
                let theArray = searchedString.split(" ");
                let i = 0;
                while( response && i < theArray.length ){

                    let valueInTheArray = theArray[i].normalize('NFD').replace(/[\u0300-\u036f]/g, '');

                    response = alteredDescripcion.search(new RegExp(valueInTheArray, "i")) >= 0;

                    i++;
                }

                return response;

            } );
    }

    let newListToPresent = "";
    let functionsToExecute = [];

    listaSeccionesFiltradaPestanhaExpediente.forEach( (item, index) => {

        let innerSummaryCounterText = "";
        let theSectionButtons = "";
        summaryResultsListObj = JSON.parse(item.summaryResults);

        if ( item.summaryResults && summaryResultsListObj ) {
            if ( summaryResultsListObj.length > 0 ) {

                innerSummaryCounterText = "<span class=\"currentStatusSectionsRedCounter\">" +
                                              summaryResultsListObj.length +
                                          "</span>";
                theSectionButtons = getButtonsFromResultSet(summaryResultsListObj);

                functionsToExecute.push({
                    functionType: 'simpleTable',
                    theItemCodigo: item.codigo,
                    theSummaryResultsListObj: summaryResultsListObj,
                    theFunction: function () {
                        let containerID = 'nuevaPestanhaExpedienteSummaryResultsContainer' + this.theItemCodigo;
                        let simpleTableText = getTableFromSummaryResults(this.theSummaryResultsListObj);
                        document.getElementById(containerID).innerHTML = simpleTableText;
                    }
                });

            }
        }

        let editableFilter = "";
        if (item.editable == 1) {
          editableFilter += "  data-tooltip=\"Agregar registro\"    onclick=\"doOpenPopUp(" +
                                 "'" + item.descripcion + "'," +
                                 item.codigo + "," +
                                 "'" + item.path + "'," +
                                 theDocId + ")\" > " +
        "    <img src=\"" + '../images/add-solid.png' + "\" /> </span> ";
        } else {
          editableFilter += " /> </span>";
        }

        newListToPresent += "" +
        "<div class=\"currentStateHeaderDiv\" onClick=\"toggleNvaPestExpSummaryResultsContainer(" +
                                       "'nuevaPestanhaExpedienteSummaryResultsContainer" + item.codigo +"', " + index + ")\"; toggleNvaPestExpSummaryResultsContainerIcon(); >  " +
        "      " +
        
        theSectionButtons +

		"    <span class=\"sectionImageSpan\"  data-flow=\"right\" data-tooltip=\"Ver registros\" " +
        "           > " +
        "     <img id=\"toggleIconImg"+index+"\" src=\"" + '../images/down-solid.png' + "\" />  </span> " +

"    <span class=\"sectionImageSpan\"  data-flow=\"right\" " +
        editableFilter +
												   

        "    <span id=\"nvaPestExpSecImageSpan" + index + "\" " +
        "          class=\"sectionImageSpan\" > " +
        "        <img style=\"cursor:default\" src=\"" + item.icon_path + "\" /> " +
        "    </span> " +
        "    <strong class=\"pointer\" >" + item.descripcion + "</strong> " +
                                                   innerSummaryCounterText +

        "</div>" +
        "<div id=\"nuevaPestanhaExpedienteSummaryResultsContainer" + item.codigo + "\" style=\"display: none;\" >" +
        "</div>";
    } );

    $("#nvaPestanhaExpSectionsContainer").html(newListToPresent);

    functionsToExecute.forEach( item => item.theFunction() );

}

function toggleNvaPestExpSummaryResultsContainer(containerId, idIcon) {
    if ( isOpeningPopUp ) {
        isOpeningPopUp = false;
        return;
    }
    if ( document.getElementById(containerId).style.display == "none" ) {
        $( "#" + containerId ).show(345);
		document.getElementById("toggleIconImg"+idIcon).src = "../images/up-solid.png";
	}
    else {
        $( "#" + containerId ).hide(345);
		document.getElementById("toggleIconImg"+idIcon).src = "../images/down-solid.png";
	}
}

function getButtonsFromResultSet(summaryResultsListObj) {
    let sectionButtons = "";

    let firstItem = summaryResultsListObj[0];
    if ( firstItem ) {
        for (property in firstItem) {
            if ( firstItem[property].name.toUpperCase().startsWith("IPOPUP_") ) {
                sectionButtons += " " +
                "<button type=\"button\" " +
                    "onclick=\"javascript:doOpenPopUpFullPath('" + firstItem[property].value.toLowerCase() + "')\" " +
                    "class=\"CellbyteBtn nuevaPestanhaExpedienteSectionButtons\" >" +
                        firstItem[property].name.substring(7) +
                "</button>";
            }
            else if ( firstItem[property].name.toUpperCase().startsWith("OPOPUP_") ) {
                sectionButtons += " " +
                "<button type=\"button\" " +
                    "onclick=\"javascript:doOpenExtWindowFullPath('" + firstItem[property].value + "')\" " +
                    "class=\"CellbyteBtn nuevaPestanhaExpedienteSectionButtons\" >" +
                        firstItem[property].name.substring(7) +
                "</button>";
            }
        }
    }

    return sectionButtons;
}

function getTableFromSummaryResults(summaryResultsListObj) {

    let tableTextToReturn = "";

    let sortListOfProperties = [];
    let rowProperties = [];
    let headersRow = "";
    let firstItem = summaryResultsListObj[0];
    if ( firstItem ) {
        for (property in firstItem) {
            if ( firstItem[property].name.toUpperCase() == "ROWSTYLE" ) {
                rowProperties.push( { propertyType: firstItem[property].name,
                                      propertyValue: firstItem[property].value
                                     } );
            }
            else if ( firstItem[property].name.toUpperCase().startsWith("IPOPUP_")
                      || firstItem[property].name.toUpperCase().startsWith("OPOPUP_") ) {
                // Ignorar, la columna no se debe imprimir
                // De estas columnas spolo se usa la primera fila para imprimir el botón
            }
            else {
                sortListOfProperties.push( { name: firstItem[property].name,
                                             pos: firstItem[property].pos,
                                             width: firstItem[property].width,
                                             value: firstItem[property].value
                                            } );
            }
        }

        sortListOfProperties.sort((a, b) => a.pos - b.pos);

        headersRow += "<tr>";
        sortListOfProperties.forEach( propItem => headersRow += "<th style=\"width: " + propItem.width + "%;" +
                                                                             ( ( isNaN(propItem.value) )
                                                                               ? ""
                                                                               : "text-align:right;" ) +
                                                                     "\" >" +
                                                                               propItem.name +
                                                                "</th>" );
        headersRow += "</tr>";
    }

    summaryResultsListObj.forEach( (item, index) => {

        if ( index == 0 ){
            tableTextToReturn = "" +
            "<div class=\"nuevaPestanhaExpedienteSummaryResults\" >" +
            "    <table class=\"nuevaPestanhaExpedienteSummaryTable\">" +
                        headersRow;
        }

        let addRowStyles = "";
        rowProperties.forEach( propertyItem => {
            if ( propertyItem.propertyType.toUpperCase() == "ROWSTYLE" ) {
                addRowStyles = " style=\"" + propertyItem.propertyValue + "\" ";
            }
        } );

        let valuesRow = "<tr" +
                            addRowStyles +
                        ">";
        sortListOfProperties.forEach( propItem => valuesRow += "<td" + ( ( isNaN(item[propItem.name].value) )
                                                                         ? ""
                                                                         : " style=\"text-align:right;\" " ) +
                                                               ">" +
                                                                   item[propItem.name].value +
                                                               "</td>" );
        valuesRow += "</tr>";

        tableTextToReturn += valuesRow;
    } );

    if ( tableTextToReturn != "" ) {
        tableTextToReturn += "" +
        "    </table>" +
        "</div>";
    }

    return tableTextToReturn;
}

function doOpenPopUpFullPath(fullPath, firstFoundDocId) {
    isOpeningPopUp = true;

    const pacId = <%=pacId%>;
    const noAdmision = <%=noAdmision%>;
    const cds = '<%=cds%>';
    const docId = ( document.form1.docId.value )
	              ? document.form1.docId.value
	              : firstFoundDocId;

	const xtraQS2 = ( ( fullPath.indexOf("?") == -1 )
                       ? "?"
                       : "&"
                    ) +
                    "pacId=" + pacId +
                    "&noAdmision=" + noAdmision +
                    "&cds=" + cds +
                    "&docId=" + docId +
                    "&__ct=" + (new Date()).getTime() +
                    "&careDate=<%=careDate%>" +
                    "&catId=<%=catId%>" +
                    "&expVer=2" +
                    "&estado=<%=estado%>";

    if ( fullPath != null && fullPath != "" ) {

        showPopWin(fullPath + xtraQS2,
            winWidth*.75,
            winHeight*.65,
            null,
            null,
            '');

        //setTimeout(attachReloadingEventToPopUpClosingButton(),345);
        //consider detaching one if any

    }
}

function doOpenExtWindowFullPath(fullPath, firstFoundDocId) {
    isOpeningPopUp = true;

    const pacId = <%=pacId%>;
    const noAdmision = <%=noAdmision%>;
    const cds = '<%=cds%>';
    const docId = ( document.form1.docId.value )
	              ? document.form1.docId.value
	              : firstFoundDocId;

	const xtraQS2 = ( ( fullPath.indexOf("?") == -1 )
                       ? "?"
                       : "&"
                    ) +
                    "pacId=" + pacId +
                    "&noAdmision=" + noAdmision +
                    "&cds=" + cds +
                    "&docId=" + docId +
                    "&expVer=2";

    if ( fullPath != null && fullPath != "" ) {

        abrir_ventana(fullPath + xtraQS2);

    }
}

$(document).ready(function(){
	$("#alerContainer").dblclick(function(){reloadAlerts();});
	
	$("#info").click(function(){$("#pac_info").toggle();});
	$("#flow").click(function(){$("#pac_flow").toggle();});
	
	
	$("#tabTabdhtmlgoodies_tabView1_<%=cdoX.getColValue("cds_sop"," ").trim().equals(cds)?"0":"1"%>").click(function (c){
	   adjustDivContent();
	   // $('div#container').toggle('slide', { direction: 'up'}, 800);
	});
	
	$(<%=(!fp.equalsIgnoreCase("history")?"'div.doc-container'":"'div.doc-container'")%>).click(function() { 
	    
      $('div.doc-container').removeClass("selected");
			$(this).addClass("selected");
			
			$("#tabTabdhtmlgoodies_tabView1_<%=cdoX.getColValue("cds_sop"," ").trim().equals(cds)?"0":"1"%>").unbind('click').click();
			
		var docId = $(this).data("doc_id");
		const additionalForURL = '?docId=' + docId +
			                     '&pacId=<%=pacId%>' +
			                     '&estado=<%=estado%>' +
			                     '&mode=<%=mode%>' +
			                     '&noAdmision=<%=noAdmision%>' +
			                     '&fp=<%=fp%>';
		$.ajax({
			 url: ( ( nuevoTabExpediente === 'S' )
			        ? '../expediente/expediente_nuevo_secciones_iconificado.jsp'
			        : '../expediente/expediente_secciones_iconificado.jsp'
			      ) + additionalForURL,
			 cache: false,
			 dataType: "html"
		  }).done(function(data){
				if ( nuevoTabExpediente === 'S' ){
				    recargarNuevaPestanhaExpediente(data, docId);
				}
				else{
				    $("#sections").html("");
				    $("#sections").html($.trim(data));
				}
                $("#docId").val(docId);
		  }).fail(function(jqXHR, textStatus){
			debug("La request has fallido: " + textStatus);
		  });
	});
	
	$("#sections").on( 'click', '.sec-container', function () {
      $('div.sec-container').removeClass("selected");
	    $(this).addClass("selected");	
        //$("#sections").hide('slide', { direction: 'left'}, 1000);
    });
	
	
	<%if (!fp.equalsIgnoreCase("history")){%>
		$("#show-sections").click(function(){

		   // if ($("#tabTabdhtmlgoodies_tabView1_<%=cdoX.getColValue("cds_sop"," ").trim().equals(cds)?"0":"1"%>").hasClass("tabActive")) $('div#sections').toggle('slide', { direction: 'left'}, 800);
		});
        
        $("#tabTabdhtmlgoodies_tabView1_0").click(function(){
          if ($(this).hasClass("tabActive")) loadEstadoActual();
        })
        
	<%}%>
	
	//Lazy loading 
	lazyLoadingIF();
	
	/* Cuando está activa la nueva pestaña Expediente, no se manejan multiples TABs de secciones a la vez */
	if ( nuevoTabExpediente === 'S' || tabbar.getActiveTab() == null){
	
	   <%if (!fp.equalsIgnoreCase("history")){%>
		    loadEstadoActual();
	    <%}%>	

		var tabContainer;
		function setTabContainer(c){tabContainer=c;}
		window.getTabContainer = function(){return tabContainer;}
		
		
		function drawChart(options){
			var ctx = options.gContainer.getContext("2d");
			var _options = {
				//Boolean - If we show the scale above the chart data	  -> Default value Changed
				scaleOverlay : false,
				annotateDisplay : true,
				//Boolean - If we want to override with a hard coded scale
				scaleOverride : true,
				//** Required if scaleOverride is true **
				//Number - The number of steps in a hard coded scale
				scaleSteps : 20,
				//Number - The value jump in the hard coded scale
				scaleStepWidth : 5,
				//Number - The scale starting value
				scaleStartValue : 30,
				//String - Colour of the scale line	
				scaleLineColor : "rgba(0,0,0,.1)",
				//Number - Pixel width of the scale line	
				scaleLineWidth : 1,
				//Boolean - Whether to show labels on the scale	
				scaleShowLabels : true,
				//Interpolated JS string - can access value
				scaleLabel : "<\%=value%>",
				annotateLabel : "<\%=formatAnnotateLabel(v1,v2,v3)%>",
				//String - Scale label font declaration for the scale label
				scaleFontFamily : "'Arial'",
				//Number - Scale label font size in pixels	
				scaleFontSize : 11,
				//String - Scale label font weight style	
				scaleFontStyle : "normal",
				//String - Scale label font colour	
				scaleFontColor : "#000",	
				///Boolean - Whether grid lines are shown across the chart
				scaleShowGridLines : true,
				//String - Colour of the grid lines
				scaleGridLineColor : "rgba(0,0,0,.05)",
				//Number - Width of the grid lines
				scaleGridLineWidth : 1,	
				//Boolean - Whether the line is curved between points -> Default value Changed 
				bezierCurve : false,
				//Boolean - Whether to show a dot for each point -> Default value Changed
				pointDot : true,
				//Number - Radius of each point dot in pixels
				pointDotRadius : 3,
				//Number - Pixel width of point dot stroke
				pointDotStrokeWidth : 1,
				//Boolean - Whether to show a stroke for datasets
				datasetStroke : true,
				//Number - Pixel width of dataset stroke
				datasetStrokeWidth : 2,
				//Boolean - Whether to fill the dataset with a colour
				datasetFill : false,
				//Boolean - Whether to animate the chart             -> Default value changed
				animation : true,
				//Number - Number of animation steps
				animationSteps : 60,
				//String - Animation easing effect
				animationEasing : "easeOutQuart",
				//Function - Fires when the animation is complete
				onAnimationComplete : null,
				canvasBorders : false,
				canvasBordersWidth : 30,
				canvasBordersColor : "black",
				yAxisLeft : true,
				yAxisRight : false,
				yAxisLabel : "Valores",
				yAxisFontFamily : "'Arial'",
				yAxisFontSize : 12,
				yAxisFontStyle : "normal",
				yAxisFontColor : "#000",
				xAxisLabel : "Fecha",
				xAxisFontFamily : "'Arial'",
				xAxisFontSize : 12,
				xAxisFontStyle : "normal",
				xAxisFontColor : "#000",
				yAxisUnit : "UNIT",
				yAxisUnitFontFamily : "'Arial'",
				yAxisUnitFontSize : 12,
				yAxisUnitFontStyle : "normal",
				yAxisUnitFontColor : "#666",
				graphTitle : "Temperatura",
				graphTitleFontFamily : "'Arial'",
				graphTitleFontSize : 24,
				graphTitleFontStyle : "bold",
				graphTitleFontColor : "#666",
				graphSubTitle : "",
				graphSubTitleFontFamily : "'Arial'",
				graphSubTitleFontSize : 18,
				graphSubTitleFontStyle : "normal",
				graphSubTitleFontColor : "#666",
				footNote : "",
				/* footNoteFontFamily : "'Arial'",
				footNoteFontSize : 50,
				footNoteFontStyle : "bold",
				footNoteFontColor : "#666", */
				annotateClassName: 'tooltip',
				legend : true,
				showSingleLegend: true,
				inGraphDataShow : true,
				multiGraph : true,
				legendFontFamily : "'Arial'",
				legendFontSize : 12,
				legendFontStyle : "normal",
				legendFontColor : "#666",
				legendBlockSize : 30,
				legendBorders : true,
				legendBordersWidth : 1,
				legendBordersColor : "#666",
				//  ADDED PARAMETERS 
				graphMin : "0",
				graphMax : "DEFAULT"

			};
			var _data = {
				labels: ["15/07/14 13:46", "28/08/14 17:57", "26/09/14 09:24", "01/10/14 15:51"],
				datasets: [
					{
						fillColor: "rgba(220,220,220,0.2)",
						strokeColor: "rgba(220,220,220,1)",
						pointColor: "rgba(220,220,220,1)",
						pointStrokeColor: "#fff",
						pointHighlightFill: "#fff",
						pointHighlightStroke: "rgba(220,220,220,1)",
						data: [37, 36, 36, 35.2],
						title: "Temp."
					},{
						fillColor: "rgba(150,150,150,0.2)",
						strokeColor: "rgba(150,150,150,1)",
						pointColor: "rgba(150,150,150,1)",
						pointStrokeColor: "#fff",
						pointHighlightFill: "#fff",
						pointHighlightStroke: "rgba(150,150,150,1)",
						data: [100,78, 120, 76],
						title: "Pulso"
					}
				]
			};
			
			var chart = new Chart(ctx).Line(_data, _options);
		}

		$(".dhx_tabcontent_zone").on('click', '.tab-menu', function (c) { 
		
		   var i = $(this).data("i");
		   var tipo = $(this).data("tipo");
		   var docSecId = $(this).data("docsec");
		   var $tContent = $("#lineChart-"+i);
		   var $text = $("#text-"+i);
		   var _docSecId = docSecId.split("-");
		   var data;
		   
		   if (tipo=="P"){
		      data = $.trim(ajaxHandlerNoXtra("../common/serve_dyn_content.jsp?serveTo=ESTADO_ACTUAL_PAC","tipo="+tipo+"&documento="+_docSecId[0]+"&section="+_docSecId[1]+"&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>"));
			  
			  if (data){
				$text.html(data)
			  }
		   }else{
		      drawChart({
				gContainer: $tContent.get(0)
			  });
		   } // chart
		   

		   
		   
		}); // click on $.tabs

		
	} // blank dhtmlXTabBar.tab
});

	
//May be i should implement something reusable
function showHelp(){
  $('div#imageContainer').css("text-align","center").dialog({
	    modal: true,
		height: 'auto',
		width: 'auto',
		maxWidth: 800,
		maxHeight: 500,
		position: ['center', 'center'],
        title: 'Valores Normales de Signos Vitales', 
		resizable: false,
		show: {
          effect: "blind",
          duration: 1000
        },
        hide: {
          effect: "explode",
          duration: 1000
        } 
		,closeText: "" 
	});
}

function refreshFlow(idFlujo){
  document.location = "../expediente/expediente_new_flow.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=&cds=<%=cds%>&estado=<%=pacId%>&catId=<%=catId%>&idFlujo="+idFlujo;
} 

function adjustDivContent(){
  // $("#a_tabbar").css("width","100%");
}

function showExp(p){
  window.location = p;
}

function loadEstadoActual(){
    $.ajax({
        url: '../expediente/condicion_actual_paciente.jsp?pacId=<%=pacId%>&status=&mode=<%=mode%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>',
        cache: false,
        dataType: "html"
    }).done(function(data){
        $('#estado_actual').html(data);
        $("#estado_actual").animate({ height: newHeightForCurrentState }, 200);
    }).fail(function(jqXHR, textStatus){
       $('#pacInfoWrapper').html("La request has fallido: " + textStatus);
    });
}
</script>

<style>


 /* Nuevo tooltip */
[data-tooltip] {
  position: relative;
  cursor: pointer;
}
[data-tooltip]:before,
[data-tooltip]:after {
  line-height: 1;
  font-size: 1.3em;
  pointer-events: none;
  position: absolute;
  box-sizing: border-box;
  display: none;
  opacity: 0;
}
[data-tooltip]:before {
  content: "";
  border: 5px solid transparent;
  z-index: 100;
}
[data-tooltip]:after {
  content: attr(data-tooltip);
  text-align: center;
  min-width: 3em;
  max-width: 21em;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  padding: 7px 7px;
  border-radius: 0px;
  background: #3f3f3f;
  color: #FFFFFF;
  z-index: 99;
}
[data-tooltip]:hover:before,
[data-tooltip]:hover:after {
  display: block;
  opacity: 1;
}
[data-tooltip]:not([data-flow])::before,
[data-tooltip][data-flow="top"]::before {
  bottom: 100%;
  border-bottom-width: 0;
  border-top-color: #333333;
}
[data-tooltip]:not([data-flow])::after,
[data-tooltip][data-flow="top"]::after {
  bottom: calc(100% + 5px);
}
[data-tooltip]:not([data-flow])::before, [tooltip]:not([data-flow])::after,
[data-tooltip][data-flow="top"]::before,
[data-tooltip][data-flow="top"]::after {
  left: 50%;
  -webkit-transform: translate(-50%, -4px);
          transform: translate(-50%, -4px);
}
[data-tooltip][data-flow="bottom"]::before {
  top: 100%;
  border-top-width: 0;
  border-bottom-color: #333333;
}
[data-tooltip][data-flow="bottom"]::after {
  top: calc(100% + 5px);
}
[data-tooltip][data-flow="bottom"]::before, [data-tooltip][data-flow="bottom"]::after {
  left: 50%;
  -webkit-transform: translate(-50%, 8px);
          transform: translate(-50%, 8px);
}
[data-tooltip][data-flow="left"]::before {
  top: 50%;
  border-right-width: 0;
  border-left-color: #333333;
  left: calc(0em - 5px);
  -webkit-transform: translate(-8px, -50%);
          transform: translate(-8px, -50%);
}
[data-tooltip][data-flow="left"]::after {
  top: 50%;
  right: calc(100% + 5px);
  -webkit-transform: translate(-8px, -50%);
          transform: translate(-8px, -50%);
}
[data-tooltip][data-flow="right"]::before {
  top: 50%;
  border-left-width: 0;
  border-right-color: #333333;
  right: calc(0em - 5px);
  -webkit-transform: translate(8px, -50%);
          transform: translate(8px, -50%);
}
[data-tooltip][data-flow="right"]::after {
  top: 50%;
  left: calc(100% + 5px);
  -webkit-transform: translate(8px, -50%);
          transform: translate(8px, -50%);
}
[data-tooltip=""]::after, [data-tooltip=""]::before {
  display: none !important;
}



 /* Viejo tooltip */

   .dhtmlgoodies_tabPane{-webkit-box-sizing: content-box;
    -moz-box-sizing: content-box;
    box-sizing: content-box;color:#000}
	
	.dhx_tablist_zone{color:#000}
   
  .doc-container{
    float: left;
	/*background-color: #fff;*/
	margin: 0.5%;
	width: 8.01%;
	position: relative;
	min-width: 120px;
	height: 77px;
  }
  
  .sec-container{
    /*background-color: #fff;*/
	margin: 0.5%;
	width: 8.01%;
	position: relative;
	min-width: 120px;
	height: 77px;
    display:inline-block;
  }
  
  .doc-img-container, .sec-img-container{
    display: table-cell;
	text-align: center;
	border-radius: 0;
	box-shadow: none;
	color: #626262;
	cursor: pointer;
	width: 100%;
	background-repeat: no-repeat;
	background-position: center center;
	background-size: 40% auto;
	height: 77px;
	position: relative;
	vertical-align: middle;
	margin: auto;
  }
  
  .descrip{
     clear:both; position:absolute; left:0; right:0; bottom:0; height:19px; font-size:10px;overflow:hidden; width:100%;white-space: nowrap;text-overflow: ellipsis; font-weight:bold;display: inline-block;
	 color:#000;
  }
  
  .selected{border-top: solid #FFA500;}
  
  .tooltip{
	position: absolute;
	z-index: 999;
	left: -9999px;
	word-wrap: break-word;
	max-width: 350px;
	padding: 0 0.2em;
	color: #333;
	background: #fff;
	border: 1px solid #aaa;
	border-radius: 4px 4px 4px 4px;
	box-shadow: 1px 2px 4px rgba(0,0,0,0.2), 0 0px 10px rgba(0,0,0,0.05) inset;  
  }
  
  #docs{
	color: #fff;
	line-height: 1.6em;
	font-weight: bold;
	text-align: center;
	padding: 12px;
	text-shadow: 0 1px 1px rgba(0,0,0,.2);
	background-color: #1f8dd6;
	position:fixed;
	right:16px;
	transform:rotate(-270deg);
	margin-top:9px;
	cursor:pointer;
      position: absolute;
  z-index: 9999;
  top: 259px;
  right: 0;
}

#main-container{
  height: 390px;
  background: rgb(240, 248, 255);
  display: flex;
  width:100%;
}

#a_tabbar{
 height:390px;
 flex: 1;
}

#sections{
  height:390px;
  flex: 0 0 22%;
  box-sizing: border-box;
  overflow-y:scroll;
  text-align:center;
}
</style>

</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="">

    <%
    String avatar = cdoP.getColValue("avatar"," ").trim();
    
    if (!avatar.equals("")) {
        avatar = java.util.ResourceBundle.getBundle("path").getString("avatars").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/"+avatar;
    } else avatar = "../images/icons/_patient.png";
    %>
		
	<div class="header">
		<div class="home-menu pure-menu pure-menu-open pure-menu-horizontal pure-menu-fixed">
			<a class="pure-menu-heading" href="javascript:void(0)" style="background:url(<%=avatar%>) no-repeat 0 0; background-size:contain; padding-left:45px" title="Paciente"><%=cdoP.getColValue("nombre_paciente")%>
			(<%=cdoP.getColValue("identificacion")%>&nbsp;|&nbsp;<%=cdoP.getColValue("f_nac")%>&nbsp;|&nbsp;<%=cdoP.getColValue("edad")%>&nbsp;|&nbsp;Sexo:<%=cdoP.getColValue("sexo")%>&nbsp;<%=cdoP.getColValue("weight_height")%>&nbsp;|&nbsp;PID:<%=pacId%>-<%=noAdmision%>)
			</a>

			<ul>
				<li><a class="pure-button" id="info" href="javascript:void(0)" style="color:#fff">Info</a></li>
				<%if(!fp.equalsIgnoreCase("history")){%>
					<li><a href="javascript:showPopWin('../expediente/expediente_history.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>',winWidth*.75,winHeight*.65,null,null,'');" class="pure-button" style="color:#fff">Historial</a></li>
				<%}else{%>				
				   <li><a href="javascript:showExp('../expediente/expediente_iconificado.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=&cds=<%=cds%>&estado=<%=estado%>&careDate=<%=careDate%>');" class="pure-button" style="color:#fff">Expediente</a></li>
				<%}%>
			</ul>
		</div>
	</div>
	
  <%
  String userTypeCode = UserDet.getUserTypeCode();
  String image = "";
  String m[] = {"MI","MS","MP"};
  String e[] = {"AU","EN","ES"};
  if (userTypeCode!=null && Arrays.asList(m).contains(userTypeCode)) image = "<img src='../images/icons/_md24.png' style='vertical-align: bottom;'/>";
  else if (userTypeCode!=null && Arrays.asList(e).contains(userTypeCode)) image = "<img src='../images/icons/_nurse24.png' style='vertical-align: bottom;'/>";
  else image = "<img src='../images/icons/_nurse24.png' style='vertical-align: bottom;'/>";
  %>
  
  <div style="margin-top:50px;"></div>
	<div id="pac_info" style="display:none; border-bottom:#000 solid 1px; margin-bottom:20px">
		<jsp:include page="../common/paciente.jsp" flush="true">
			<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
			<jsp:param name="fp" value="expediente"></jsp:param>
			<jsp:param name="mode" value="view"></jsp:param>
			<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
		</jsp:include>
	</div>
	
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td align="center">

				<table width="100%" cellpadding="1" cellspacing="0" border="2" align="center">
					<tr class="<%=doSimpleBlinking.trim().equals("0")?"TextRowWhite":""%>">
						<td width="85%" id="alerContainer">
							<jsp:include page="../common/ialert.jsp" flush="true">
								<jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
								<jsp:param name="fp" value="expediente"></jsp:param>
								<jsp:param name="displayArea" value="expediente"></jsp:param>
								<jsp:param name="admision" value="<%=noAdmision%>"></jsp:param>
								<jsp:param name="doSimpleBlinking" value="<%=doSimpleBlinking%>"></jsp:param>
							</jsp:include>
						</td>
						<td width="15%" align="center" style="cursor:pointer">
							<div style="color:black;">
                <%=image%>
                <em><strong><%=UserDet.getUserName()%></strong></em>
              </div>
						</td>
					</tr>
				</table>
				
				
				<!-- VALORES NORMALES SIGNOS VITALES -->
				<div id="imageContainer" style="display:none">
					<img src="../images/signos_vitales_ayuda.png" alt="Valores Normales de Signos Vitales" title="Valores Normales de Signos Vitales" />
				</div>
				
				
				<!-- DOCUMENTOS MEDICOS -->
				<div id="container" style="margin-top:5px; background-color: #e6e6e6; text-align:center;">
		
					<%
					   for (int d = 0; d<al.size(); d++){
					   cdo = (CommonDataObject) al.get(d);
					   System.out.println(" icon =="+cdo.getColValue("icon_path"));
					%> 
	
					   <div class="doc-container hint hint--top" data-hint="<%=cdo.getColValue("OptLabelColumn")%>" data-doc_id="<%=cdo.getColValue("OptValueColumn")%>">
						  <span id="observCont<%=d%>" class="observCont" title="" data-d="<%=d%>" data-cont="<%=cdo.getColValue("OptLabelColumn")%>">	
						  <div id="" style="display:table;width:100%;">
						  
							 <div id="" class="doc-img-container">
								<img src="<%=cdo.getColValue("icon_path")%>" style="height:50px; max-height: 50px;"/>
							 </div>
							 
							 <div class="descrip">
							   <%=cdo.getColValue("OptLabelColumn")%>
							 </div>
						
						  </div>
						  </span>
						  
					   </div>
		   
					<%}%>
					<div style="clear:both"></div>
				</div>
				
				
				<!-- SECCIONES MEDICAS -->
				<div id="sectionsssss" style="margin-top:10px; background-color: #e6e6e6; text-align:center; display:none"></div>
				
				<div id="dhtmlgoodies_tabView1" style="margin-top:10px;">
		
                    <%if(!cdoX.getColValue("cds_sop"," ").trim().equals(cds)){%>
                    <!-- ESTADO ACTUAL -->
                    <div class="dhtmlgoodies_aTab">
                      <div  style="width:100%; height:450px; " id="estado_actual">
                      </div>
                    </div>
                    <%}%>
					
                    <!--GENERALES TAB0-->
					<div class="dhtmlgoodies_aTab">

						<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath());%>
						<%=fb.formStart(true)%>
						<%=fb.hidden("mode",mode)%>
						<%=fb.hidden("estadoAtencion",estado)%>
						<%=fb.hidden("section",section)%>
						<%=fb.hidden("sectionDesc",sectionDesc)%>
						<%=fb.hidden("path",path)%>
						<%=fb.hidden("docId",docId)%>

						<div id="main-container">
						<%if( nuevoTabExpediente.equalsIgnoreCase("S") ){%>
                            <div id="nuevaPestanhaExpedienteContainer"></div>
						<%}else{%>
                            <div id="sections"></div>
                            <div id="a_tabbar" style="height:390px; flex: 1;"></div>
						<%}%>
						</div>

                        
                        <%if(!fp.equalsIgnoreCase("history")){%>
                            <!--<div id="docs" class="docs">Tareas</div>-->
                        <%}%>
		
						<%=fb.formEnd(true)%>
						
					</div>

					<%--URGENCIA Y CONYUGUE--%>
					<div class="dhtmlgoodies_aTab" data-tabsrc="../expediente/urgencia_y_conyugue.jsp?mode=<%=mode%>&pacId=<%=pacId%>&fp=<%=fp%>" data-tabframe="ifUrgencia">
					
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextRow02">
								<td colspan="2"><cellbytelabel id="5">URGENCIA Y CONYUGUE</cellbytelabel></td>
							</tr>
							<tr class="TextRow02">
								<td colspan="2">
								<iframe id="ifUrgencia" name="ifUrgencia" width="100%" height="330" scrolling="yes" frameborder="0" src=""></iframe>
							</td>
							</tr>
						</table>
						
					</div>

					<%--CUSTODIO--%>
					<div class="dhtmlgoodies_aTab" data-tabsrc="../expediente/custodio.jsp?mode=<%=mode%>&pacId=<%=pacId%>&fp=<%=fp%>" data-tabframe="ifCustodio">
					
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextRow02">
								<td colspan="2"><cellbytelabel id="6">Custodio</cellbytelabel></td>
							</tr>
							<tr class="TextRow02">
								<td colspan="2">
								<iframe id="ifCustodio" name="ifCustodio" width="100%" height="330" scrolling="yes" frameborder="0" src=""></iframe>
							</td>
							</tr>
						</table>
						
					</div>
                    
					<%--EDUCACION PACIENTE--%>
					<div class="dhtmlgoodies_aTab" data-tabframe="ifEducPac" data-tabsrc="../expediente/exp_educacion_paciente.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>">
		
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextRow02">
								<td colspan="2"><cellbytelabel id="7">Educaci&oacute;n Paciente (Carenotes)</cellbytelabel></td>
							</tr>
							<tr class="TextRow02">
								<td colspan="2">
								<iframe id="ifEducPac" name="ifEducPac" width="100%" height="330" scrolling="yes" frameborder="0" src=""></iframe>
							</td>
							</tr>
						</table>
						
					</div>
                    
					<%--OBSERVACION ADMINISTRATIVAS--%>
					<div class="dhtmlgoodies_aTab" data-tabsrc="../expediente/exp_obser_admin.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&fg=EXP" data-tabframe="ifObservAdmin">
		
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextRow02">
								<td colspan="2"><cellbytelabel id="8">Observaciones Administrativas</cellbytelabel></td>
							</tr>
							<tr class="TextRow02">
								<td colspan="2">
								<iframe id="ifObservAdmin" name="ifObservAdmin" width="100%" height="330" scrolling="yes" frameborder="0" src=""></iframe>
							</td>
							</tr>
						</table>
						
					</div>
		
					<%--CONSENTIMIENTO--%>
					<div class="dhtmlgoodies_aTab" data-tabframe="ifConcentimiento" data-tabsrc="../common/sel_consentimiento.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>">
					
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextRow02">
								<td colspan="2"><cellbytelabel id="9">Consentimiento</cellbytelabel></td>
							</tr>
							<tr class="TextRow02">
								<td colspan="2">
								<iframe id="ifConcentimiento" name="ifConcentimiento" width="100%" height="330" scrolling="yes" frameborder="0" src=""></iframe>
							</td>
							</tr>
						</table>
						
					</div>
		
					<%--IMAGENES ESCANEADAS--%>
					<div class="dhtmlgoodies_aTab" data-tabsrc="../admision/frame_doc_admision.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&expStatus=<%=estado%>" data-tabframe="ifImagenEscan">
					
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextRow02">
								<td colspan="2"><cellbytelabel id="10">Asociar Imagenes Escaneadas</cellbytelabel></td>
							</tr>
							<tr class="TextRow02">
								<td colspan="2">
								<iframe id="ifImagenEscan" name="ifImagenEscan" width="100%" height="330" scrolling="yes" frameborder="0" src=""></iframe>
							</td>
							</tr>
						</table>
						
					</div>
	
				</div>
				
				<script type="text/javascript">
					<%
                    String estadoActual = cdoX.getColValue("cds_sop"," ").equals(cds) ? "" : "'Estado Actual',";
					String tabLabel = estadoActual+"'Expediente', 'Urgencia y Conyugue','Custodio','Educacion Paciente','Observ. Administrativas','Consentimiento','Asociar Imagenes Escaneadas'";
					String tabFunctions = "''";
					String tabInactivo = "";
					%>
					initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,Array(<%=tabFunctions%>),[<%=tabInactivo%>]);
				</script>

				<script type="text/javascript">
					function doAction(){
						navBar("","");
						<%if(doSimpleBlinking.trim().equals("1")){%>reloadAlerts()<%}%>
					}
					doAction();
				</script>

			</td>
		</tr>
        <tr><td>
           <table width="100%">
                <tr class="TextRow02">
                    <td align="right">
                    <%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:overrideCloseWin()\"")%>&nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
            </table>
        </td></tr>
	</table>
</body>
</html><%}//GET%>