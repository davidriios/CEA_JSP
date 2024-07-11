<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iAntMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="NEEUMgr" scope="page" class="issi.expediente.NotaEvaluacionEnfermeraUrgenciaMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
NEEUMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
Properties prop = new Properties();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String key = "";
String descLabel ="NOTAS DE EVALUACION DE ENFERMERA DE URGENCIA";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String desc = request.getParameter("desc");
String param_sis = "";

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";

if (fg == null) fg = "NEEU";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Secci&oacute;n no es v&aacute;lida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisi&oacute;n no es v&aacute;lida. Por favor intente nuevamente!");

if(fg.trim().equals("NEEU")) descLabel += " - URGENCIA"; 

CommonDataObject pds = SQLMgr.getData("select param_value from tbl_sec_comp_param where param_name = 'HISTO_OBSTE_EMB'");
	if (pds == null) {
        param_sis = "N";

	}
    if (pds != null) {
        param_sis = pds.getColValue("param_value");
	}

if (request.getMethod().equalsIgnoreCase("GET"))
{   
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"'");
	if (prop == null)
	{
	 	prop = new Properties();
		prop.setProperty("fecha",cDateTime.substring(0,10));
		prop.setProperty("hora",cDateTime.substring(11));
		if(!viewMode)modeSec="add";
	}
	else
	{
		   if(!viewMode)modeSec= "edit"; 
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
<%if(fg.trim().equals("NEEU")){%>
document.title = 'Notas de Evaluaci&oacute;n de Enfermera de Urgencia - '+document.title;
<%}%>
function doAction(){newHeight();getHistoriaobs();}
function printExp(){abrir_ventana("../expediente/print_exp_seccion_108.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>");}
function getRadio(obj,opt){var rad_val = obj.value;if(rad_val == 'O'){eval('document.form0.otros'+opt).readOnly=false;eval('document.form0.otros'+opt).className='FormDataObjectEnabled';}else{eval('document.form0.otros'+opt).value = '';eval('document.form0.otros'+opt).readOnly=true;eval('document.form0.otros'+opt).className='FormDataObjectDisabled';}}
/*
*@param obj : Nombre del checkbox sin el �ndice 
*@param qty : Cantidad de checkbox
*@param otros : Nombre del textarea sin el �ndice
*@param check : El checkbox con el nombre Otros
*/
function ctrlOtros(obj,qty,otros,check){
  for ( i = 0; i<qty; i++ ){ 
  
  if ( obj == "alergia" ){
        if ( $('#'+obj+'0').is(":checked") ){

           if ( $('#'+obj+(i+1)).length ){
               $('#'+obj+(i+1)).attr("checked",false);
               $('#'+obj+(i+1)).attr("disabled",true);
               $("#otros"+otros).attr("readonly",true).addClass("FormDataObjectDisabled").val("");
               debug("no way");
            }
            
	    }else{
            $('#'+obj+(i+1)).attr("disabled",false);
            
            if ( $('#'+obj+check).is(":checked") ) {
              $('#otros'+otros).removeClass("FormDataObjectDisabled").attr("readonly",false);
              break;
            }else{
              $('#otros'+otros).addClass("FormDataObjectDisabled").attr("readonly",true).val("");
            }
        } 
	}else{
	    if ( $('#'+obj+check).is(":checked") ) {
		   $('#otros'+otros).removeClass("FormDataObjectDisabled").attr("readonly",false);
		   break;
		}else{
		   $('#otros'+otros).addClass("FormDataObjectDisabled").attr("readonly",true).val("");
		}
	}
   }//for
}
 
function getHistoriaobs(){
var sexo = parent.document.paciente.sexo.value;
var param_sis = ('<%=param_sis%>')

	if( eval('document.form0.historiaobs')[0].checked == true && sexo=='M'){eval('document.form0.historiaobs')[0].checked = false;top.CBMSG.warning('No es posible que un hombre quede embarazado. Revise el sexo Del Paciente.!');}
    if( eval('document.form0.historiaobs')[0].checked == true && sexo=='F' && param_sis=='S'){
		eval('document.form0.fum').readOnly=false;
		eval('document.form0.fum').className='FormDataObjectEnabled';
		eval('document.form0.fup').readOnly=false;
		eval('document.form0.fup').className='FormDataObjectEnabled';
		eval('document.form0.gin').readOnly=false;
		eval('document.form0.gin').className='FormDataObjectEnabled';
		
		eval('document.form0.g').readOnly=false;
		eval('document.form0.g').className='FormDataObjectEnabled';
		eval('document.form0.p').readOnly=false;
		eval('document.form0.p').className='FormDataObjectEnabled';
		eval('document.form0.c').readOnly=false;
		eval('document.form0.c').className='FormDataObjectEnabled';
		eval('document.form0.a').readOnly=false;
		eval('document.form0.a').className='FormDataObjectEnabled';

		eval('document.form0.ctrl')[0].disabled=false;
		eval('document.form0.ctrl')[0].checked=true;
		eval('document.form0.ctrl')[1].disabled=false;
		
	}
	else
	if( eval('document.form0.historiaobs')[1].checked == true && sexo=='F' && param_sis=='S'){
		eval('document.form0.fum').readOnly=false;
		eval('document.form0.fum').className='FormDataObjectEnabled';
		eval('document.form0.fup').readOnly=false;
		eval('document.form0.fup').className='FormDataObjectEnabled';
		eval('document.form0.gin').readOnly=false;
		eval('document.form0.gin').className='FormDataObjectEnabled';
		
		eval('document.form0.g').readOnly=false;
		eval('document.form0.g').className='FormDataObjectEnabled';
		eval('document.form0.p').readOnly=false;
		eval('document.form0.p').className='FormDataObjectEnabled';
		eval('document.form0.c').readOnly=false;
		eval('document.form0.c').className='FormDataObjectEnabled';
		eval('document.form0.a').readOnly=false;
		eval('document.form0.a').className='FormDataObjectEnabled';

		eval('document.form0.ctrl')[0].disabled=false;
		eval('document.form0.ctrl')[0].checked=true;
		eval('document.form0.ctrl')[1].disabled=false;
		
	}
	else
	if( eval('document.form0.historiaobs')[0].checked == true && sexo=='F' && param_sis=='N'){
		eval('document.form0.fum').readOnly=false;
		eval('document.form0.fum').className='FormDataObjectEnabled';
		eval('document.form0.fup').readOnly=false;
		eval('document.form0.fup').className='FormDataObjectEnabled';
		eval('document.form0.gin').readOnly=false;
		eval('document.form0.gin').className='FormDataObjectEnabled';
		
		eval('document.form0.g').readOnly=false;
		eval('document.form0.g').className='FormDataObjectEnabled';
		eval('document.form0.p').readOnly=false;
		eval('document.form0.p').className='FormDataObjectEnabled';
		eval('document.form0.c').readOnly=false;
		eval('document.form0.c').className='FormDataObjectEnabled';
		eval('document.form0.a').readOnly=false;
		eval('document.form0.a').className='FormDataObjectEnabled';

		eval('document.form0.ctrl')[0].disabled=false;
		eval('document.form0.ctrl')[0].checked=true;
		eval('document.form0.ctrl')[1].disabled=false;
		
	}
	else
	if( eval('document.form0.historiaobs')[1].checked == true  ){
		
		document.form0.g.value = '';
		document.form0.p.value = '';
		document.form0.c.value = '';
		document.form0.a.value = '';
		
		eval('document.form0.g').readOnly=true;
		eval('document.form0.p').readOnly=true;
		eval('document.form0.c').readOnly=true;
		eval('document.form0.a').readOnly=true;
		
		eval('document.form0.g').className='FormDataObjectDisabled';
		eval('document.form0.p').className='FormDataObjectDisabled';
		eval('document.form0.c').className='FormDataObjectDisabled';
		eval('document.form0.a').className='FormDataObjectDisabled';
		
		document.form0.fum.value = '';
		document.form0.fup.value = '';
		document.form0.gin.value = '';
		eval('document.form0.fum').readOnly=true;
		eval('document.form0.fum').className='FormDataObjectDisabled';
		eval('document.form0.fup').readOnly=true;
		eval('document.form0.fup').className='FormDataObjectDisabled';
		eval('document.form0.gin').readOnly=true;
		eval('document.form0.gin').className='FormDataObjectDisabled';
		
		eval('document.form0.ctrl')[0].checked=false;
		eval('document.form0.ctrl')[0].disabled=true;
		eval('document.form0.ctrl')[1].checked=false;
		eval('document.form0.ctrl')[1].disabled=true;
		
	}
	
}

$(document).ready(function(){
  $("#alergia0, #alergia7, input:checkbox[name*='alergia']").click(function(c){
    var thisName = $(this).attr("name");
	var thisObj = $(this);
	if (thisName=="alergia0"){ 
	  if (thisObj.is(":checked")) {
	    $("input[name^='alergia'], input:checkbox[name*='alergia']").not(thisObj).attr({
		  checked:false, disabled:true
		});
		$("#otros8").addClass("FormDataObjectDisabled").val("").attr({readonly:true})
	  }else {
	    $("input:hidden[name*='alergia']").val("");
	    $("input[id^='_alergia'], input:checkbox[name*='alergia']").attr('disabled',false);
	  }
	}else if (thisName=="alergia7"||thisName=="_alergia7Dsp"){
	  if (thisObj.is(":checked")) {
	    $("#otros8").removeClass("FormDataObjectDisabled").attr({readonly:false})
	  }else $("#otros8").addClass("FormDataObjectDisabled").val("").attr({readonly:true})
	}
  });  
  
   //
   $(".inc").click(function(e){
        var currentSize = parseFloat($(".det td").css('font-size'));
        var max = 20;
        var min = 12;
        var incr = 1;
        var fSize = currentSize + incr;
        
        if (fSize > max ) fSize = min;
        
        $(".det td").css('font-size', fSize + 'px')
   }); 
  
});
</script>
<style>
.det td {
  font-size: 12px;
}
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
  <tr>
	<td>  
		<table width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("modeSec",modeSec)%>
		<%=fb.hidden("seccion",seccion)%>
		<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
		<%=fb.hidden("dob","")%>
		<%=fb.hidden("codPac","")%>
		<%=fb.hidden("pacId",pacId)%>
		<%=fb.hidden("noAdmision",noAdmision)%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("desc",desc)%>
		<%//=fb.hidden("neurologico1",prop.getProperty("neurologico"))%>
		<tr class="TextRow02">
        <td colspan="2">
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <a href="#" class="Link00 inc">[<cellbytelabel id="1">+ letras</cellbytelabel>]</a>
        </td>
		    <td colspan="3" align="right">
          <a href="javascript:printExp();" class="Link00">[<cellbytelabel id="1">Imprimir</cellbytelabel>]</a>
        </td>
		</tr>
		<tr class="TextRow01">
			<td align="right" width="10%"><cellbytelabel id="2">Fecha</cellbytelabel>&nbsp;</td>
			<td width="15%">
			<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include></td>
			<td align="right" width="10%"><cellbytelabel id="3">Hora</cellbytelabel></td>
			<td width="15%">
			   <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora" />
				<jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora")%>" />
				<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
				</jsp:include>
			</td>
			<td width="50%"></td>
		</tr>

		<%if(fg.trim().equals("NEEU")){%>
		
		<tr>
		  <td colspan="5"> 
		   <table width="100%" cellpadding="0" cellspacing="1" class="det">
			  <tr class="TextRow02">
				<td align="right" rowspan="3"><cellbytelabel id="4">Neurol&oacute;gico</cellbytelabel>:</td>
				<td align="right"><cellbytelabel id="5">Alerta</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("neurologico0","A",(prop.getProperty("neurologico0").equalsIgnoreCase("A")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="6">Let&aacute;rgico</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("neurologico1","L",(prop.getProperty("neurologico1").equalsIgnoreCase("L")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="7">Confuso</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("neurologico2","C",(prop.getProperty("neurologico2").equalsIgnoreCase("C")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="8">Inconsciente</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("neurologico3","I",(prop.getProperty("neurologico3").equalsIgnoreCase("I")),viewMode,null,null,"","")%></td>
			  </tr>
				
			  <tr class="TextRow02">
				<td align="right"><cellbytelabel id="9">Desorientado</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("neurologico4","D",(prop.getProperty("neurologico4").equalsIgnoreCase("D")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="10">Convulsiones</cellbytelabel></td>
				<td  align="center"><%=fb.checkbox("neurologico5","CO",(prop.getProperty("neurologico5").equalsIgnoreCase("CO")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="11">Par&aacute;lisis</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("neurologico6","P",(prop.getProperty("neurologico6").equalsIgnoreCase("P")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="12">Otros</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("neurologico7","O",(prop.getProperty("neurologico7").equalsIgnoreCase("O")),viewMode,"","","onClick=\"ctrlOtros('neurologico',8,1,7)\"","")%></td>
			 </tr>
			 <tr class="TextRow02">
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="7"><%=fb.textarea("otros1",prop.getProperty("otros1"),false,false,(viewMode==false&&prop.getProperty("neurologico7").equalsIgnoreCase("O")?false:true),75,2,2000,(viewMode==false&&prop.getProperty("neurologico7").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
			 </tr>
			 
			 <tr class="TextRow01">
				<td rowspan="2" align="right"><cellbytelabel id="14">Cardiovascular</cellbytelabel>:</td>
				<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("cardiovascular0","N",(prop.getProperty("cardiovascular0").equalsIgnoreCase("N")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="16">Tarquicadia</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("cardiovascular1","T",(prop.getProperty("cardiovascular1").equalsIgnoreCase("T")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="17">Bradicardia</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("cardiovascular2","B",(prop.getProperty("cardiovascular2").equalsIgnoreCase("B")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="18">Palpitaci&oacute;n</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("cardiovascular3","P",(prop.getProperty("cardiovascular3").equalsIgnoreCase("P")),viewMode,null,null,"","")%></td>
		     </tr>
			 
			 <tr class="TextRow01">
				<td align="right"><cellbytelabel id="19">Dolor en el Pecho</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("cardiovascular4","D",(prop.getProperty("cardiovascular4").equalsIgnoreCase("D")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="20">Marcapaso</cellbytelabel></td>
				<td  align="center"><%=fb.checkbox("cardiovascular5","M",(prop.getProperty("cardiovascular5").equalsIgnoreCase("M")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="12">Otros</cellbytelabel></td>
				<td  align="center"><%=fb.checkbox("cardiovascular6","O",(prop.getProperty("cardiovascular6").equalsIgnoreCase("O")),viewMode,null,null,"onClick=\"ctrlOtros('cardiovascular',7,2,6)\"","")%></td>
				<td colspan="2"><%=fb.textarea("otros2",prop.getProperty("otros2"),false,false,(viewMode==false&&prop.getProperty("cardiovascular6").equalsIgnoreCase("O")?false:true),30,2,2000,(viewMode==false&&prop.getProperty("cardiovascular6").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
		     </tr>
			 
			 <tr class="TextRow02">
				<td rowspan="2" align="right"><cellbytelabel id="21">Estado Respiratorio</cellbytelabel>:</td>
				<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("respiracion0","N",(prop.getProperty("respiracion0").equalsIgnoreCase("N")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="22">Tos</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("respiracion1","T",(prop.getProperty("respiracion1").equalsIgnoreCase("T")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="23">Aleteo Nasal</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("respiracion2","A",(prop.getProperty("respiracion2").equalsIgnoreCase("A")),viewMode,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="24">Disnea</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("respiracion3","D",(prop.getProperty("respiracion3").equalsIgnoreCase("D")),false,null,null,"","")%></td>
		     </tr>
			 
			 <tr class="TextRow02">
				<td align="right"><cellbytelabel id="25">Apnea</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("respiracion4","AP",(prop.getProperty("respiracion4").equalsIgnoreCase("AP")),false,null,null,"","")%></td>
				<td align="right"><cellbytelabel id="12">Otros</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("respiracion5","O",(prop.getProperty("respiracion5").equalsIgnoreCase("O")),viewMode,null,null,"onClick=\"ctrlOtros('respiracion',6,3,5)\"")%></td>
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="3"><%=fb.textarea("otros3",prop.getProperty("otros3"),false,false,(viewMode==false&&prop.getProperty("respiracion5").equalsIgnoreCase("O")?false:true),35,2,2000,(viewMode==false&&prop.getProperty("respiracion5").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
		     </tr>
			 
			 <tr class="TextRow01">
			   <td align="right" rowspan="2"><cellbytelabel id="26">G.E.T Gastro-intestinal</cellbytelabel>:</td>
			   <td align="right"><cellbytelabel id="27">N&aacute;usea</cellbytelabel></td>
			   <td align="center"><%=fb.checkbox("get0","N",(prop.getProperty("get0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
			   <td align="right"><cellbytelabel id="28">V&oacute;mito</cellbytelabel></td>
			   <td align="center"><%=fb.checkbox("get1","V",(prop.getProperty("get1").equalsIgnoreCase("V")),viewMode,null,null,"","")%></td>
			   <td align="right"><cellbytelabel id="29">&Uacute;lceras</cellbytelabel></td>
			   <td align="center"><%=fb.checkbox("get2","U",(prop.getProperty("get2").equalsIgnoreCase("U")),viewMode,null,null,"","")%></td>
			   <td align="right"><cellbytelabel id="30">Dolor abdominal</cellbytelabel></td>
			   <td align="center"><%=fb.checkbox("get3","D",(prop.getProperty("get3").equalsIgnoreCase("D")),viewMode,null,null,"","")%></td>
	         </tr>
			 
			 <tr class="TextRow01">
			   <td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
			   <td align="center"><%=fb.checkbox("get4","NO",(prop.getProperty("get4").equalsIgnoreCase("NO")),viewMode,null,null,"","")%></td>
			   <td align="right"><cellbytelabel id="12">Otros</cellbytelabel>:</td>
			   <td align="center"><%=fb.checkbox("get5","O",(prop.getProperty("get5").equalsIgnoreCase("O")),viewMode,null,null,"onClick=\"ctrlOtros('get',6,4,5)\"")%></td>
			   <td  align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="3"><%=fb.textarea("otros4",prop.getProperty("otros4"),false,false,(viewMode==false&&prop.getProperty("get5").equalsIgnoreCase("O")?false:true),35,2,2000,(viewMode==false&&prop.getProperty("get5").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
	         </tr>
			 
			 <tr class="TextRow02">
			   <td rowspan="3" align="right"><cellbytelabel id="31">M&uacute;sculo-Esqueletico</cellbytelabel>:</td>
			   <td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td><td align="center"><%=fb.checkbox("esquel0","N",(prop.getProperty("esquel0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
			   <td  align="right"><cellbytelabel id="32">Golpe</cellbytelabel></td><td align="center"><%=fb.checkbox("esquel1","G",(prop.getProperty("esquel1").equalsIgnoreCase("G")),viewMode,null,null,"")%></td>
			   <td  align="right"><cellbytelabel id="33">Trauma</cellbytelabel></td><td align="center"><%=fb.checkbox("esquel2","T",(prop.getProperty("esquel2").equalsIgnoreCase("T")),viewMode,null,null,"")%></td>
			   <td align="right"><cellbytelabel id="34">Adormecimiento en extremidades</cellbytelabel></td>
			   <td colspan="4"><%=fb.checkbox("esquel3","A",(prop.getProperty("esquel3").equalsIgnoreCase("A")),viewMode,null,null,"")%></td>
			   <tr> 
			   
			  <tr class="TextRow02">
			    <td align="right"><cellbytelabel id="35">Edemas en extremidades</cellbytelabel></td>
				<td  align="center"><%=fb.checkbox("esquel4","E",(prop.getProperty("esquel4").equalsIgnoreCase("E")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="12">Otros</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("esquel5","O",(prop.getProperty("esquel5").equalsIgnoreCase("O")),viewMode,null,null,"onClick=\"ctrlOtros('esquel',6,5,5)\"")%></td>
				<td colspan="5"><%=fb.textarea("otros5",prop.getProperty("otros5"),false,false,(viewMode==false&&prop.getProperty("esquel5").equalsIgnoreCase("O")?false:true),50,2,2000,(viewMode==false&&prop.getProperty("esquel5").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
	         </tr>
			 
			 <tr class="TextRow01">
				<td rowspan="4" align="right"><cellbytelabel id="36">Tegumentos (Piel</cellbytelabel>):</td>
				<td align="right"><cellbytelabel id="37">P&aacute;lido</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel0","P",(prop.getProperty("piel0").equalsIgnoreCase("P")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="38">Moteado</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel1","M",(prop.getProperty("piel1").equalsIgnoreCase("M")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="39">Cianosis</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel2","C",(prop.getProperty("piel2").equalsIgnoreCase("C")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="40">Diaforesis</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel3","D",(prop.getProperty("piel3").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
		     </tr>
			 
			 <tr class="TextRow01">
				<td align="right"><cellbytelabel id="41">Herida</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel4","H",(prop.getProperty("piel4").equalsIgnoreCase("H")),viewMode,null,null,"")%></td>	    
				<td align="right"><cellbytelabel id="42">Hematoma</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel5","HE",(prop.getProperty("piel5").equalsIgnoreCase("HE")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="43">Ictericia</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel6","I",(prop.getProperty("piel6").equalsIgnoreCase("I")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="29">&Uacute;lceras</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel7","U",(prop.getProperty("piel7").equalsIgnoreCase("U")),viewMode,null,null,"")%></td>
		     </tr>
			 
			 <tr class="TextRow01">
				<td align="right"><cellbytelabel id="44">Quemaduras</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel8","Q",(prop.getProperty("piel8").equalsIgnoreCase("Q")),viewMode,null,null,"")%></td>	    
				<td align="right"><cellbytelabel id="45">Eritema</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel9","ER",(prop.getProperty("piel9").equalsIgnoreCase("ER")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="46">Exantema</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel10","EX",(prop.getProperty("piel10").equalsIgnoreCase("EX")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel11","N",(prop.getProperty("piel11").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
			 </tr>
				
			<tr class="TextRow01">
				<td align="right"><cellbytelabel id="12">Otros</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("piel12","O",(prop.getProperty("piel12").equalsIgnoreCase("O")),viewMode,null,null,"onClick=\"ctrlOtros('piel',13,6,12)\"")%></td>
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="5"><%=fb.textarea("otros6",prop.getProperty("otros6"),false,false,(viewMode==false&&prop.getProperty("piel12").equalsIgnoreCase("O")?false:true),55,2,2000,(viewMode==false&&prop.getProperty("piel12").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
		     </tr>
			 
			 <tr class="TextRow02">
				<td align="right" rowspan="2"><cellbytelabel id="47">Psicol&oacute;gico</cellbytelabel>:</td>
				<td align="right"><cellbytelabel id="48">Ansioso</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("psico0","A",(prop.getProperty("psico0").equalsIgnoreCase("A")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="49">Deprimido</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("psico1","D",(prop.getProperty("psico1").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="50">Hostil</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("psico2","H",(prop.getProperty("psico2").equalsIgnoreCase("H")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="51">Agresivo</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("psico3","AG",(prop.getProperty("psico3").equalsIgnoreCase("AG")),viewMode,null,null,"")%></td>
		     </tr>
			 
			 <tr class="TextRow02">
				<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("psico4","N",(prop.getProperty("psico4").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="12">Otros</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("psico5","O",(prop.getProperty("psico5").equalsIgnoreCase("O")),viewMode,null,null,"onClick=\"ctrlOtros('psico',6,7,5)\"")%></td>
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel></td>
				<td colspan="3"><%=fb.textarea("otros7",prop.getProperty("otros7"),false,false,(viewMode==false&&prop.getProperty("psico5").equalsIgnoreCase("O")?false:true),33,2,2000,(viewMode==false&&prop.getProperty("psico5").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
		     </tr>
			 
			 <tr class="TextRow01">
				<td rowspan="3" align="right"><cellbytelabel id="52">Alergias</cellbytelabel>:</td>
				<td align="right"><cellbytelabel id="53">Niega</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("alergia0","N",(prop.getProperty("alergia0").equalsIgnoreCase("N")),viewMode,"","","onClick=\"ctrlOtros('alergia',8,8,7)\"","")%></td>
				<td align="right"><cellbytelabel id="54">Alimentos</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("alergia1","A",(prop.getProperty("alergia1").equalsIgnoreCase("A")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),(viewMode||prop.getProperty("alergia0").equalsIgnoreCase("N")),"","","","")%></td>
				<td align="right"><cellbytelabel id="55">AINES</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("alergia2","AI",(prop.getProperty("alergia2").equalsIgnoreCase("AI")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),(viewMode||prop.getProperty("alergia0").equalsIgnoreCase("N")),"","","","")%></td>
				<td align="right"><cellbytelabel id="56">Antibi&oacute;ticos</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("alergia3","AT",(prop.getProperty("alergia3").equalsIgnoreCase("AT")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),(viewMode||prop.getProperty("alergia0").equalsIgnoreCase("N")),"","","","")%></td>
		     </tr>
			 
			 <tr class="TextRow01">
				<td align="right"><cellbytelabel id="57">Medicamentos</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("alergia4","M",(prop.getProperty("alergia4").equalsIgnoreCase("M")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),(viewMode||prop.getProperty("alergia0").equalsIgnoreCase("N")),"","","","")%></td>	    
				<td align="right"><cellbytelabel id="58">YODO</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("alergia5","Y",(prop.getProperty("alergia5").equalsIgnoreCase("Y")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),(viewMode||prop.getProperty("alergia0").equalsIgnoreCase("N")),"","","","")%></td>
				<td align="right"><cellbytelabel id="59">Sulfa</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("alergia6","S",(prop.getProperty("alergia6").equalsIgnoreCase("S")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),(viewMode||prop.getProperty("alergia0").equalsIgnoreCase("N")),"","","","")%></td>
				<td align="right"><cellbytelabel id="12">Otros</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("alergia7","O",(prop.getProperty("alergia7").equalsIgnoreCase("O")&&!prop.getProperty("alergia0").equalsIgnoreCase("N")),(viewMode||prop.getProperty("alergia0").equalsIgnoreCase("N")),"","","onClick=\"ctrlOtros('alergia',8,8,7)\"","")%></td>
		     </tr>
			 
			 <tr class="TextRow01">
				<td  align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="6"><%=fb.textarea("otros8",prop.getProperty("otros8"),false,false,(viewMode==false&&prop.getProperty("alergia7").equalsIgnoreCase("O")?false:true),53,2,2000,((viewMode==false&&prop.getProperty("alergia7").equalsIgnoreCase("O")&&!prop.getProperty("alergia0").equalsIgnoreCase("N"))?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
		    </tr>
			
			<tr class="TextRow02">
				<td align="right" rowspan="3"><cellbytelabel id="60">Antecedentes Patol&oacute;gicos Personales</cellbytelabel>:</td>
				<td align="right"><cellbytelabel id="61">Sin Antecedentes Patol&oacute;gicos</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("antpat0","N",(prop.getProperty("antpat0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="62">Hipertensi&oacute;n Arterial</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("antpat1","H",(prop.getProperty("antpat1").equalsIgnoreCase("H")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="63">Diabetes</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("antpat2","D",(prop.getProperty("antpat2").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
				<td align="right"><cellbytelabel id="64">Problemas Renales</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("antpat3","PR",(prop.getProperty("antpat3").equalsIgnoreCase("PR")),viewMode,null,null,"")%></td>
			</tr>
			
			<tr class="TextRow02">	
				<td align="center"><cellbytelabel id="12">Otros</cellbytelabel></td>
				<td align="center"><%=fb.checkbox("antpat4","O",(prop.getProperty("antpat4").equalsIgnoreCase("O")),viewMode,null,null,"onClick=\"ctrlOtros('antpat',5,9,4)\"")%></td>
				<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
				<td colspan="5"><%=fb.textarea("otros9",prop.getProperty("otros9"),false,false,(viewMode==false&&prop.getProperty("antpat4").equalsIgnoreCase("O")?false:true),57,2,2000,(viewMode==false&&prop.getProperty("antpat4").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
		   </tr>
		   <tr class="TextRow02">	
		   		<td align="right"><cellbytelabel id="65">Medicamentos Actuales</cellbytelabel></td>
				<td colspan="7"><%=fb.textarea("medUsado",prop.getProperty("medUsado"),false,false,viewMode,78,2,2000,"","'",null)%></td>
		   </tr>
		   
		   <tr class="TextRow01">
			<td align="right" rowspan="2"><cellbytelabel id="66">Nutricional</cellbytelabel>:</td>
			<td align="right">Come bien</td>
			<td align="center"><%=fb.checkbox("nutricional0","C",(prop.getProperty("nutricional0").equalsIgnoreCase("C")),viewMode,null,null,"")%></td>
			<td align="right"><cellbytelabel id="67">Tubo nasog&aacute;strico</cellbytelabel></td>
			<td  align="center"><%=fb.checkbox("nutricional1","T",(prop.getProperty("nutricional1").equalsIgnoreCase("T")),viewMode,null,null,"")%></td>
			<td align="right"><cellbytelabel id="68">Gastrostom&iacute;a</cellbytelabel></td>
			<td  align="center"><%=fb.checkbox("nutricional2","G",(prop.getProperty("nutricional2").equalsIgnoreCase("G")),viewMode,null,null,"")%></td>
			<td align="right"><cellbytelabel id="69">Caquexico</cellbytelabel></td>
			<td  align="center"><%=fb.checkbox("nutricional3","CA",(prop.getProperty("nutricional3").equalsIgnoreCase("CA")),viewMode,null,null,"")%></td>
		</tr>
		<tr class="TextRow01">	
			<td align="center"><cellbytelabel id="12">Otros</cellbytelabel></td>
			<td align="center"><%=fb.checkbox("nutricional4","O",(prop.getProperty("nutricional4").equalsIgnoreCase("O")),viewMode,null,null,"onClick=\"ctrlOtros('nutricional',5,10,4)\"")%></td>
			<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
			<td colspan="5"><%=fb.textarea("otros10",prop.getProperty("otros10"),false,false,(viewMode==false&&prop.getProperty("nutricional4").equalsIgnoreCase("O")?false:true),57,2,2000,(viewMode==false&&prop.getProperty("nutricional4").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
	   </tr>
	   
	   <tr class="TextRow02">
		<td rowspan="3" align="right"><cellbytelabel id="70">Genito-Urinario</cellbytelabel></td>
		<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("genito0","N",(prop.getProperty("genito0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
		<td align="right"><cellbytelabel id="71">Disuria</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("genito1","D",(prop.getProperty("genito1").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
		<td align="right"><cellbytelabel id="72">Oliguria</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("genito2","OL",(prop.getProperty("genito2").equalsIgnoreCase("OL")),viewMode,null,null,"")%></td>
		<td align="right"><cellbytelabel id="73">Poliuria</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("genito3","P",(prop.getProperty("genito3").equalsIgnoreCase("P")),viewMode,null,null,"")%></td>
	</tr>
	<tr class="TextRow02">
		<td align="right"><cellbytelabel id="74">Hematuria</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("genito4","H",(prop.getProperty("genito4").equalsIgnoreCase("H")),viewMode,null,null,"")%></td>
		<td align="right"><cellbytelabel id="75">Incontinencia</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("genito5","I",(prop.getProperty("genito5").equalsIgnoreCase("I")),viewMode,null,null,"")%></td>
		<td align="right"><cellbytelabel id="76">Retenci&oacute;n Urinaria</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("genito6","RU",(prop.getProperty("genito6").equalsIgnoreCase("RU")),viewMode,null,null,"")%></td>
		<td align="right"><cellbytelabel id="77">Dolor</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("genito7","DO",(prop.getProperty("genito7").equalsIgnoreCase("DO")),viewMode,null,null,"")%></td>
	</tr>
	<tr class="TextRow02">
		<td align="right"><cellbytelabel id="78">Ardor</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("genito8","AR",(prop.getProperty("genito8").equalsIgnoreCase("AR")),viewMode,null,null,"")%></td>
		<td align="right">Otros</td>
		<td align="center"><%=fb.checkbox("genito9","O",(prop.getProperty("genito9").equalsIgnoreCase("O")),viewMode,null,null,"onClick=\"ctrlOtros('genito',10,12,9)\"")%></td>
		<td colspan="5"><%=fb.textarea("otros12",prop.getProperty("otros12"),false,false,(viewMode==false&&prop.getProperty("genito9").equalsIgnoreCase("O")?false:true),57,2,2000,(viewMode==false&&prop.getProperty("patron4").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
	</tr>
	
	<tr class="TextRow01" align="right">
		<td rowspan="2"><cellbytelabel id="79">Patr&oacute;n de Eliminaci&oacute;n</cellbytelabel></td>
		<td align="right"><cellbytelabel id="15">Normal</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("patron0","N",(prop.getProperty("patron0").equalsIgnoreCase("N")),viewMode,null,null,"")%></td>
		<td align="right"><cellbytelabel id="80">Constipado</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("patron1","C",(prop.getProperty("patron1").equalsIgnoreCase("C")),viewMode,null,null,"")%></td>
		<td align="right"><cellbytelabel id="81">Diarrea</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("patron2","D",(prop.getProperty("patron2").equalsIgnoreCase("D")),viewMode,null,null,"")%></td>
		<td align="right"><cellbytelabel id="82">Meleno</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("patron3","m",(prop.getProperty("patron3").equalsIgnoreCase("m")),viewMode,null,null,"")%></td>
	</tr>
	<tr class="TextRow01">	
		<td align="right"><cellbytelabel id="12">Otros</cellbytelabel></td>
		<td align="center"><%=fb.checkbox("patron4","O",(prop.getProperty("patron4").equalsIgnoreCase("O")),viewMode,null,null,"onClick=\"ctrlOtros('patron',5,11,4)\"")%></td>
		<td align="center"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel>:</td>
		<td colspan="5"><%=fb.textarea("otros11",prop.getProperty("otros11"),false,false,(viewMode==false&&prop.getProperty("patron4").equalsIgnoreCase("O")?false:true),57,2,2000,(viewMode==false&&prop.getProperty("patron4").equalsIgnoreCase("O")?"FormDataObjectEnabled":"FormDataObjectDisabled"),"'",null)%><td>
	</tr>
	   
	<tr class="TextRow01">
	   <td><cellbytelabel id="83">Inmunizaciones</cellbytelabel></td>
	   <td align="center"><cellbytelabel id="84">Completo</cellbytelabel></td><td align="center"><%=fb.radio("inmuni","C",(prop.getProperty("inmuni").equalsIgnoreCase("C")),viewMode,false,null,null,"")%></td>
	   <td align="center"><cellbytelabel id="85">Incompleto</cellbytelabel></td><td align="center"><%=fb.radio("inmuni","I",(prop.getProperty("inmuni").equalsIgnoreCase("I")),viewMode,false,null,null,"")%></td>
	   <td colspan="4">&nbsp;</td>
	</tr>
	
	<tr><td colspan="9">&nbsp;</td></tr>
	<tr class="TextHeader"><td colspan="9"><cellbytelabel id="86">Historial Transfusional</cellbytelabel></td></tr>
	<tr class="TextRow02">
	   <td colspan="4"><cellbytelabel id="87">Transfusi&oacute;n de Componentes Sanguineos</cellbytelabel>:</td>
	   <td align="right"><cellbytelabel id="88">SI</cellbytelabel></td><td><%=fb.radio("transf","S",(prop.getProperty("transf").equalsIgnoreCase("S")),viewMode,false)%></td>
	   <td align="right"><cellbytelabel id="89">NO</cellbytelabel></td><td><%=fb.radio("transf","N",(prop.getProperty("transf").equalsIgnoreCase("N")),viewMode,false)%></td>
	   <td>&nbsp;</td>
    </tr>
	<tr class="TextRow02">
	   <td colspan="4">Reacci&oacute;n Adversa</td>
	   <td align="right"><cellbytelabel id="88">SI</cellbytelabel></td><td><%=fb.radio("reac","S",(prop.getProperty("reac").equalsIgnoreCase("S")),viewMode,false)%></td>
	   <td align="right"><cellbytelabel id="89">NO</cellbytelabel></td><td><%=fb.radio("reac","N",(prop.getProperty("reac").equalsIgnoreCase("N")),viewMode,false)%></td>
	   <td>&nbsp;</td>
	</tr>
	
<tr class="TextHeader">
  <td colspan="3"><cellbytelabel id="90">Historia Obst&eacute;tric</cellbytelabel>a</td>
  <td colspan="6" align="center"><cellbytelabel id="91">Esta embarazada</cellbytelabel>?</td>
</tr>

<tr class="TextRow01">
  <td rowspan="5">&nbsp;</td>
  <td align="center" colspan="4">
<cellbytelabel id="88">SI</cellbytelabel>&nbsp;&nbsp;<%=fb.radio("historiaobs","S",(prop.getProperty("historiaobs").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"javascript:getHistoriaobs()\"")%></td>
  <td align="center" colspan="4">
<cellbytelabel id="89">NO</cellbytelabel>&nbsp;&nbsp;<%=fb.radio("historiaobs","N",(prop.getProperty("historiaobs").equalsIgnoreCase("N")),viewMode,false,null,null,"onClick=\"javascript:getHistoriaobs()\"")%></td>	
</tr> 

<tr class="TextRow01">
	   <td  align="right"><cellbytelabel id="92">FUM</cellbytelabel>&nbsp;&nbsp;</td>
	   <td colspan="4"><%=fb.textarea("fum",prop.getProperty("fum"),false,false,true,25,2,60,"FormDataObjectDisabled","'",null)%></td> 
	   
		<td colspan="4" align="center" rowspan="4">
		<cellbytelabel id="93">G</cellbytelabel>&nbsp;<%=fb.intBox("g",prop.getProperty("g"),false,false,true,1,1,"","FormDataObjectDisabled","")%>&nbsp;
		<cellbytelabel id="94">P</cellbytelabel>&nbsp;<%=fb.intBox("p",prop.getProperty("p"),false,false,true,1,1,"","FormDataObjectDisabled","")%>&nbsp;
		<cellbytelabel id="95">C</cellbytelabel>&nbsp;<%=fb.intBox("c",prop.getProperty("c"),false,false,true,1,1,"","FormDataObjectDisabled","")%>&nbsp;
		<cellbytelabel id="96">A</cellbytelabel>&nbsp;<%=fb.intBox("a",prop.getProperty("a"),false,false,true,1,1,"","FormDataObjectDisabled","")%>
	   </td>
	</tr>
	
	<tr class="TextRow01">
	   <td  align="right"><cellbytelabel id="97">FUP</cellbytelabel>&nbsp;&nbsp;</td>
	   <td colspan="4"><%=fb.textarea("fup",prop.getProperty("fup"),false,false,true,25,2,60,"FormDataObjectDisabled","'",null)%></td>
	</tr>
	 <tr class="TextRow01">
	   <td  align="right"><cellbytelabel id="98">Control Prenatal</cellbytelabel></td>
	   <td align="right"><cellbytelabel id="88">SI</cellbytelabel>&nbsp;</td>
	   <td><%=fb.radio("ctrl","S",(prop.getProperty("ctrl").equalsIgnoreCase("S")),viewMode,false)%></td>
	   <td align="right"><cellbytelabel id="89">NO</cellbytelabel>&nbsp;</td>
	   <td><%=fb.radio("ctrl","N",(prop.getProperty("ctrl").equalsIgnoreCase("N")),viewMode,false)%></td>
	</tr>
	<tr class="TextRow01">
	   <td  align="right"><cellbytelabel id="99">Ginec&oacute;logo</cellbytelabel>&nbsp;</td>
	   <td colspan="4"><%=fb.textarea("gin",prop.getProperty("gin"),false,false,true,25,2,60,"FormDataObjectDisabled","'",null)%></td>
	</tr>
	
	<tr class="TextRow02">
		<td align="right" rowspan="2"><cellbytelabel id="100">&Aacute;rea Designada</cellbytelabel>:</td>
		<td align="right"><cellbytelabel id="101">Consultorio Adulto</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","CA",(prop.getProperty("area").equalsIgnoreCase("CA")),viewMode,false)%></td>
		<td align="right"><cellbytelabel id="102">Consultorio Pediatria</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","CP",(prop.getProperty("area").equalsIgnoreCase("CP")),viewMode,false)%></td>
		<td align="right"><cellbytelabel id="103">Observaci&oacute;n Adulto</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","OA",(prop.getProperty("area").equalsIgnoreCase("OA")),viewMode,false)%></td>
		<td align="right"><cellbytelabel id="104">Observaci&oacute;n Pediatria</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","OP",(prop.getProperty("area").equalsIgnoreCase("OP")),viewMode,false)%></td>
	</tr>
	
	<tr class="TextRow02">
		<td align="right"><cellbytelabel id="105">Curaciones</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","C",(prop.getProperty("area").equalsIgnoreCase("C")),viewMode,false)%></td>	    
		<td align="right"><cellbytelabel id="106">Ortopedia</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","OR",(prop.getProperty("area").equalsIgnoreCase("OR")),viewMode,false)%></td>
		<td align="right"><cellbytelabel id="107">Ginecolog&iacute;a</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","G",(prop.getProperty("area").equalsIgnoreCase("G")),viewMode,false)%></td>
		<td align="right"><cellbytelabel id="108">Reanimaci&oacute;n</cellbytelabel></td>
		<td align="center"><%=fb.radio("area","R",(prop.getProperty("area").equalsIgnoreCase("R")),viewMode,false)%></td>
	</tr>
	
	<tr class="TextRow01">
	   <td colspan="4"><cellbytelabel id="109">Esta usted lactando actualmente</cellbytelabel></td>
	   <td><cellbytelabel id="88">SI</cellbytelabel></td><td><%=fb.radio("lactancia","S",(prop.getProperty("lactancia").equalsIgnoreCase("S")),viewMode,false)%></td>
	   <td><cellbytelabel id="89">NO</cellbytelabel></td><td><%=fb.radio("lactancia","N",(prop.getProperty("lactancia").equalsIgnoreCase("N")),viewMode,false)%></td>
	   <td>&nbsp;</td>
	</tr>
	<tr class="TextRow01"><td colspan="9">&nbsp;</td>
	</tr>
	
	<tr class="TextRow02">
	   <td colspan="2"><cellbytelabel id="110">Historia Actual</cellbytelabel></td>
	   <td colspan="7">
	     <%=fb.textarea("historiaActual",prop.getProperty("historiaActual"),false,false,viewMode,78,2,2000,"","'",null)%>
	  </td>
	</tr>
	<tr class="TextRow01"><td colspan="9">&nbsp;</td>
	</tr>

	
    <%}%>
<%
//fb.appendJsValidation("\n\tif (!chkMedico()) error++;\n");
fb.appendJsValidation("if(error>0)doAction();");%>
		<tr class="TextRow02">
			<td align="right" colspan="9">
				<cellbytelabel id="111">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="112">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="113">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
 </table>
    </td>
  </tr>	
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
System.out.println("::::::::::::::::::::: TOP "+prop.getProperty("neurologico1"));
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	prop = new Properties();

	prop.setProperty("pac_id",request.getParameter("pacId"));
	prop.setProperty("admision",request.getParameter("noAdmision"));
	prop.setProperty("tipo_nota",request.getParameter("fg"));
	
	for ( int o = 0; o<15; o++ ){
	    if ( request.getParameter("neurologico"+o) != null || request.getParameter("otros"+o) != null || request.getParameter("cardiovascular"+o) != null || request.getParameter("respiracion"+o) != null || request.getParameter("get"+o) != null || request.getParameter("esquel"+o) != null || request.getParameter("piel"+o) != null || request.getParameter("psico"+o) != null || request.getParameter("alergia"+o) != null || request.getParameter("antpat"+o) != null || request.getParameter("nutricional"+o) != null || request.getParameter("genito"+o) != null || request.getParameter("patron"+o) != null){
		
	       prop.setProperty("neurologico"+o,request.getParameter("neurologico"+o));
	       prop.setProperty("cardiovascular"+o,request.getParameter("cardiovascular"+o));
		   prop.setProperty("respiracion"+o,request.getParameter("respiracion"+o));
		   prop.setProperty("get"+o,request.getParameter("get"+o));
		   prop.setProperty("esquel"+o,request.getParameter("esquel"+o));
		   prop.setProperty("piel"+o,request.getParameter("piel"+o));
		   prop.setProperty("psico"+o,request.getParameter("psico"+o));
		   System.out.println("::::::::::::::::::::: ALERGIA "+o+" - "+request.getParameter("alergia"+o));
		   if((request.getParameter("alergia"+o) != null && !request.getParameter("alergia"+o).trim().equals("")))prop.setProperty("alergia"+o,request.getParameter("alergia"+o));
		   else if((request.getParameter("_alergia"+o+"Dsp") != null && !request.getParameter("_alergia"+o+"Dsp").trim().equals("")))prop.setProperty("alergia"+o,request.getParameter("_alergia"+o+"Dsp"));
		   
		   prop.setProperty("antpat"+o,request.getParameter("antpat"+o));
		   prop.setProperty("nutricional"+o,request.getParameter("nutricional"+o));
		   prop.setProperty("genito"+o,request.getParameter("genito"+o));
		   prop.setProperty("patron"+o,request.getParameter("patron"+o));
		   
		   prop.setProperty("otros"+o,request.getParameter("otros"+o));
		}
	}

	prop.setProperty("area",request.getParameter("area"));
	prop.setProperty("historiaobs",request.getParameter("historiaobs"));
	prop.setProperty("fum",request.getParameter("fum"));
	prop.setProperty("fup",request.getParameter("fup"));
	prop.setProperty("ctrl",request.getParameter("ctrl"));
	prop.setProperty("gin",request.getParameter("gin"));
	prop.setProperty("g",request.getParameter("g"));
	prop.setProperty("p",request.getParameter("p"));
	prop.setProperty("c",request.getParameter("c"));
	prop.setProperty("a",request.getParameter("a"));
	prop.setProperty("genito",request.getParameter("genito"));
	prop.setProperty("lactancia",request.getParameter("lactancia"));
	prop.setProperty("inmuni",request.getParameter("inmuni"));
	prop.setProperty("transf",request.getParameter("transf"));
	prop.setProperty("reac",request.getParameter("reac"));
	
	prop.setProperty("fecha",request.getParameter("fecha"));
	prop.setProperty("hora",request.getParameter("hora"));
	prop.setProperty("medUsado",request.getParameter("medUsado"));
	
	prop.setProperty("historiaActual",request.getParameter("historiaActual"));
    
    String errCode = NEEUMgr.getErrCode();
	String errMsg = NEEUMgr.getErrMsg();
	String errException = NEEUMgr.getErrException();
    	
	if (baction.equalsIgnoreCase("Guardar"))
	{
		CommonDataObject param = new CommonDataObject();
		param.setTableName("tbl_sal_nota_eval_enf_urg");
        
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        
        if (modeSec.equalsIgnoreCase("add")) {
            param.setSql("insert into tbl_sal_nota_eval_enf_urg (pac_id, admision, tipo_nota, usuario_creacion, usuario_modificacion, nota, fecha_creacion, fecha_modificacion, id) values (?, ?, ?, ?, ?, ?, sysdate, sysdate,(select nvl(max(id),0)+1 from tbl_sal_nota_eval_enf_urg) )");
            
            param.addInNumberStmtParam(1,request.getParameter("pacId")); 
            param.addInNumberStmtParam(2,request.getParameter("noAdmision")); 
            param.addInStringStmtParam(3,request.getParameter("fg")); 
            param.addInStringStmtParam(4,(String)session.getAttribute("_userName"));
            param.addInStringStmtParam(5,(String)session.getAttribute("_userName"));
            param.addInBinaryStmtParam(6,prop);
        } else {
            param.setSql("update tbl_sal_nota_eval_enf_urg set nota = ?, usuario_modificacion = ?, fecha_modificacion = sysdate where pac_id = ? and admision = ? and tipo_nota = ?");
            param.addInBinaryStmtParam(1, prop);
            param.addInStringStmtParam(2,(String)session.getAttribute("_userName"));
            param.addInNumberStmtParam(3,request.getParameter("pacId")); 
            param.addInNumberStmtParam(4,request.getParameter("noAdmision")); 
            param.addInStringStmtParam(5,request.getParameter("fg")); 
        }
        
        SQLMgr.executePrepared(param);
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();
		errException = SQLMgr.getErrException();
        
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(errException);
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>