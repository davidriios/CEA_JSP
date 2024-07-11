<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DatosSalida"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="DSMgr" scope="page" class="issi.expediente.DatosSalidaMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
DSMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String to = request.getParameter("transf");
String cds = request.getParameter("cds");
String tab = request.getParameter("tab");
String fg = request.getParameter("fg");
String catId = request.getParameter("catId")==null?"":request.getParameter("catId");
String careDate = request.getParameter("careDate")==null?"":request.getParameter("careDate");
String expVer = request.getParameter("expVer")==null?"":request.getParameter("expVer");
String compania = (String)session.getAttribute("_companyId");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (tab == null) tab = "0";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (cds == null) cds = "";
if (fg == null) fg = "TSV_ESI";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	
	sql = "SELECT a.cod_paciente, a.secuencia, to_char(a.fec_nacimiento,'dd/mm/yyyy') as fec_nacimiento, a.pac_id, nvl(a.hospitalizar,' ') as hospitalizar, nvl(a.transf,'N') as transf, nvl(to_char(a.hora_transf,'hh12:mi am'),' ') as hora_transf, nvl(a.cod_diag_sal,' ') as cod_diag_sal, nvl(to_char(a.hora_salida,'hh12:mi am'),' ') as hora_salida, nvl(a.cond,' ') as cond, decode(a.hora_incap,null,' ',''||a.hora_incap) as hora_incap, nvl(to_char(a.horai_incap,'hh12:mi am'),' ') as horai_incap, nvl(to_char(a.horaf_incap,'hh12:mi am'),' ') as horaf_incap, decode(a.dia_incap,null,' ',''||a.dia_incap) as dia_incap, nvl(to_char(a.diai_incap,'dd/mm/yyyy'),' ') as diai_incap, nvl(to_char(a.diaf_incap,'dd/mm/yyyy'),' ') as diaf_incap, nvl(a.instruccion_med,' ') as instruccion_med, nvl(a.cod_medico,' ') as cod_medico, nvl(a.cod_medico_turno,' ') as cod_medico_turno, nvl(a.cod_especialidad_ce,' ') as cod_especialidad_ce, nvl(a.especialista_p,' ') as especialista_p, nvl(a.estado,' ') as estado, nvl(a.observacion,' ') as observacion, decode(a.cod_diag_sal,null,' ',(SELECT coalesce(observacion,nombre) FROM tbl_cds_diagnostico WHERE codigo=a.cod_diag_sal)) as nombre_diagnostico, decode(a.cod_medico,null,' ',(SELECT primer_nombre||decode(segundo_nombre,null,' ','  '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ','  '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',' '||apellido_de_casada)) as nombre FROM tbl_adm_medico WHERE codigo=a.cod_medico)) as medico_ref, decode(a.cod_medico_turno,null,' ',(SELECT primer_nombre||decode(segundo_nombre,null,' ',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',' '||apellido_de_casada)) as nombre FROM tbl_adm_medico WHERE codigo=a.cod_medico_turno)) as medico_turn, decode(a.cod_especialidad_ce,null,' ',(SELECT descripcion FROM tbl_adm_especialidad_medica WHERE codigo=a.cod_especialidad_ce)) AS especialidad_nom, a.nombre_acompaniante, a.cedula_acompaniante, to_char(a.fecha_modificacion,'dd/mm/yyyy') fm,a.version,a.icd10 FROM tbl_sal_adm_salida_datos a WHERE pac_id="+pacId+" and secuencia="+noAdmision;
	cdo = SQLMgr.getData(sql);
	if (cdo == null)
	{
		if (!viewMode) modeSec = "add";
		cdo = SQLMgr.getData("select da.diagnostico as cod_diag_sal, coalesce(d.observacion,d.nombre) nombre_diagnostico from tbl_adm_diagnostico_x_admision da, tbl_cds_diagnostico d where da.pac_id = "+pacId+" and da.admision = "+noAdmision+" and da.orden_diag = 1 and d.codigo = da.diagnostico");
        
        if (cdo==null) cdo = new CommonDataObject();

		cdo.addColValue("hospitalizar","N");
		cdo.addColValue("cond","I");
		cdo.addColValue("hora_transf","");
		cdo.addColValue("horaf_incap","");
		cdo.addColValue("diai_incap","");
		cdo.addColValue("horai_incap","");
		cdo.addColValue("diaf_incap","");
		cdo.addColValue("hora_salida","");
		cdo.addColValue("transf","N");
		cdo.addColValue("fm","");
        
	}
	else if (!viewMode) modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - Datos de Salida - '+document.title;
function doAction(){newHeight();}

function validaIncap(tipo,value){
  var f_fin = "";
  if(value !=''){
    if(tipo=='1'){
		eval('document.form001.dia_incap').value='';
		eval('document.form001.diai_incap').value='';
		eval('document.form001.diaf_incap').value='';
		
		horaF = $("#horaf_incap").val();
		horaI = $("#horai_incap").val();
		
		if (horaF && horaI){
		   horaF = " TO_TIMESTAMP('"+horaF+"', 'HH12:MI AM') ";
		   horaI = " TO_TIMESTAMP('"+horaI+"', 'HH12:MI AM') ";
		   qs = " to_number(TO_CHAR(EXTRACT(HOUR   FROM ("+horaF+" - "+horaI+")) ,'fm00')) ";
		   f_fin = getDBData("<%=request.getContextPath()%>",qs,'dual','','');
		   eval('document.form001.hora_incap').value=f_fin;
		}
   }
   else{
      eval('document.form001.hora_incap').value='';
	  eval('document.form001.horai_incap').value='';
	  eval('document.form001.horaf_incap').value='';
	  if(eval('document.form001.diai_incap').value !='' && eval('document.form001.diaf_incap').value !='' ){
	    var f_fin = getDBData('<%=request.getContextPath()%>','to_date(\''+eval('document.form001.diaf_incap').value+'\', \'dd/mm/yyyy\') - to_date(\''+eval('document.form001.diai_incap').value+'\', \'dd/mm/yyyy\')+1','dual','','');
		eval('document.form001.dia_incap').value=f_fin;
	  }
	}
  }
}
function addDxSalida(){abrir_ventana1('../common/search_diagnostico.jsp?fp=addDxSalida&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');}
function addDrConsultaExt(){abrir_ventana1('../common/search_medico.jsp?fp=medico_id');}
function addEntregaDr(){abrir_ventana1('../common/search_medico.jsp?fp=addEntregaDr');}
function printSalida(){abrir_ventana1('../expediente/print_sal10010_cu.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&fg=<%=fg%>');}
function validateStatus(){
var estado =getDBData('<%=request.getContextPath()%>','decode(estado,\'P\',1,\'F\',-1,0) ','tbl_sal_adm_salida_datos','pac_id=<%=pacId%> and secuencia=<%=noAdmision%>','');
if(estado == -1 ){parent.CBMSG.error('El expediente de este paciente ya fue finalizado!');return false;}else{if(document.form001.estado.value=='F'){if(!confirm('Al finalizar la atención el Expediente ya no estará disponible para modificaciones. ¿Está seguro que desea finalizar?')) return false;if(document.form001.dx_id.value.trim()==''){alert('El diagnóstico de salida está en blanco, debe de registrarlo antes de cerrar el Expediente!');			addDxSalida();return false;}else {var cantidad =getDBData('<%=request.getContextPath()%>','count(*) cantidad','tbl_adm_diagnostico_x_admision','pac_id=<%=pacId%> and admision=<%=noAdmision%> and tipo=\'S\' and orden_diag=1','');if(cantidad >1){parent.CBMSG.error('Existe mas de un diagnostico con prioridad 1. \n- Solo debe existir un diagnostico con prioridad (1)');return false;}}}return true;}}
function printCartaTraslado(){
	var to = jQuery.trim("<%=cdo.getColValue("transf")%>");
	if (to=="") alert("Por favor registre la información de traslado antes de imprimir");
	else abrir_ventana("../expediente/print_carta_traslado.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&to="+to);
}
function printDatos(){abrir_ventana("../expediente/print_ex_datos_salida.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}
function printRecetas(){
   abrir_ventana("../expediente/exp_gen_recetas.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>");
}
function printConsIncap(tipo){
  var horaIncap = "<%=cdo.getColValue("hora_incap")==null?"":cdo.getColValue("hora_incap")%>";
  var diaIncap = "<%=cdo.getColValue("dia_incap")==null?"":cdo.getColValue("dia_incap")%>";
  //var __filter = " and status = 'A' and tipo = '"+tipo+"'"
  
  //var d = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_cons_incap_transf','pac_id=<%=pacId%> and admision=<%=noAdmision%>'+__filter,'');
  
  if (horaIncap=="" && diaIncap == ""){
     alert("Por favor registre los datos antes de imprimir");
  }else{
	abrir_ventana("../expediente/exp_print_constancia_incapacidad.jsp?tipo="+tipo+"&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>");
  }
  //debug(d);
}

$(document).ready(function(){
	 $("#tabTabdhtmlgoodies_tabView1_1").on("click",function(){
	 
		$("#iTransf").attr("src","../expediente/exp_reg_transferencia_det.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tab=1&cds=<%=cds%>&desc=<%=desc%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>");
	 });
});


function canSubmit(){
  var horaIncap = $("#hora_incap").val();
  var diaIncap = $("#dia_incap").val();
  if (!horaIncap && !diaIncap) return true;
  else {
    if ( parseInt(horaIncap) < 1){
	  CBMSG.error("Por favor VERIFIQUE la hora de la Incapacidad!");  
	  form001BlockButtons(false);
	  return false;
	}else if (parseInt(diaIncap) < 1 ){
	  CBMSG.error("Por favor VERIFIQUE el día de la Incapacidad!"); 
	  form001BlockButtons(false);
	  return false;
	}else{
	   var usrEndDate = $("#diaf_incap").val();
	   var fechaIni   = $("#diai_incap").val();
	   var f_ingreso = parent.document.paciente.fechaIngreso.value;
	   var valIngreso = getDBData("<%=request.getContextPath()%>","nvl(get_sec_comp_param(<%=(String) session.getAttribute("_companyId")%>,'EXP_TIPO_F_INC'),'N')","dual","","");
 	   var msg =' que ingresó al Hospital';
	   if(valIngreso=='S'){f_ingreso='<%=cDateTime.substring(0,10)%>';msg =' Actual';}
	   
	   if(fechaIni !=null && fechaIni !='' && f_ingreso!='' && valIngreso!='N')
	   {
	   		 if( getDBData("<%=request.getContextPath()%>","case when to_date('"+fechaIni+"','dd/mm/yyyy') < to_date('"+f_ingreso+"','dd/mm/yyyy') then 'INVALID' else 'VALID' end my_date","dual","","") == 'INVALID'){
		  CBMSG.error("No puede registrar incapacidad con fecha  menor a la fecha "+msg+" !"); 
		  form001BlockButtons(false); return false;
		 }
	   }
	   if (usrEndDate){
	   
	   var diasInc = getDBData("<%=request.getContextPath()%>","nvl(get_sec_comp_param(<%=(String) session.getAttribute("_companyId")%>,'EXP_DIAS_INCAP'),-1)","dual","","");
 	   if(diasInc > 0){
	     if( getDBData("<%=request.getContextPath()%>","case when to_date('"+usrEndDate+"','dd/mm/yyyy') - to_date('"+fechaIni+"','dd/mm/yyyy') >  "+diasInc+" then 'INVALID' else 'VALID' end my_date","dual","","") == 'INVALID'){
		  CBMSG.error("No puede registrar Incapacidades mayores a "+diasInc+" Dias!"); 
		  form001BlockButtons(false); return false;
		 }
		}
	   }  
	}
	return true;
  }
  
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<div id="dhtmlgoodies_tabView1">
           <div class="dhtmlgoodies_aTab">
		      <table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form001",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%fb.appendJsValidation("if(!validateStatus())error++;");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("careDate",careDate)%>
<%=fb.hidden("expVer",expVer)%>
<%=fb.hidden("catId",catId)%>
<%fb.appendJsValidation("if(!canSubmit()){return false; error++;}");%>

		<tr class="TextRow02">
		  <td colspan="4" align="right">
		   <a class="Link00Bold" href="javascript:printDatos();">[<cellbytelabel>Imprimir</cellbytelabel>]</a>&nbsp;
		   <% if (!viewMode){%>
			<a class="Link00Bold" href="javascript:printRecetas();">[<cellbytelabel>Recetas</cellbytelabel>]</a>&nbsp;
			<%if(cdo.getColValue("hora_incap")!=null && !cdo.getColValue("hora_incap").trim().equals("")){%><a class="Link00Bold" href="javascript:printConsIncap('C');">[<cellbytelabel>Constancia</cellbytelabel>]</a><%}%>
			<%if(cdo.getColValue("dia_incap")!=null && !cdo.getColValue("dia_incap").trim().equals("")){%><a class="Link00Bold" href="javascript:printConsIncap('I');">[<cellbytelabel>Incapacidad</cellbytelabel>]</a><%}%>
			<%}else{%>
			<!--<span class="Link00Bold">[<cellbytelabel>Imprimir</cellbytelabel>]</span>&nbsp;-->
			<span class="Link00Bold">[<cellbytelabel>Recetas</cellbytelabel>]</span>&nbsp;
			<span class="Link00Bold">[<cellbytelabel>Constancia</cellbytelabel>]</span>
			<span class="Link00Bold">[<cellbytelabel>Incapacidad</cellbytelabel>]</span>
			<%}%>
		  </td>
		</tr>
		<tr class="TextRow01">
			<td width="15%"><cellbytelabel>Hospitalizaci&oacute;n</cellbytelabel></td>
			<td width="35%">
				<%=fb.radio("hospitalizar", "S",(cdo.getColValue("hospitalizar").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel>S&iacute;</cellbytelabel>
				<%=fb.radio("hospitalizar", "N",(cdo.getColValue("hospitalizar").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel>No</cellbytelabel>
			</td>
			<td width="50%" colspan="2">
			  <cellbytelabel>Transferencia</cellbytelabel>
			  <%=fb.checkbox("transf",cdo.getColValue("transf"),(cdo.getColValue("transf")!=null && cdo.getColValue("transf").equals("S")),(viewMode||cdo.getColValue("transf")!=null && cdo.getColValue("transf").equals("S")),"","","","","")%>
			  <%//=fb.textBox("transf",cdo.getColValue("transf"),false,false,viewMode,30,"","","")%>
			  <%//=fb.hidden("transf",cdo.getColValue("transf"))%>
			  </td>
		</tr>
		<tr class="TextRow01">
			<td>Hora Transferencia</td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora_transf" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_transf")%>" />
                <jsp:param name="hintText" value="12:30 pm" />
				</jsp:include>&nbsp;&nbsp;<span class="Link01Bold"><%=cdo.getColValue("fm")%></span>
			</td>
			<td colspan="2"><cellbytelabel>Dx. de Salida</cellbytelabel>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Version:<%=fb.textBox("version",cdo.getColValue("version"),false,false,true,2,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','version,icd10,dx_id,dx_descripcion')\"")%>
				ICD:<%=fb.textBox("dx_id",cdo.getColValue("cod_diag_sal"),false,false,true,2,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','version,icd10,dx_id,dx_descripcion')\"")%>
				ICD10:<%=fb.textBox("icd10",cdo.getColValue("icd10"),false,false,true,2,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','version,icd10,dx_id,dx_descripcion')\"")%>
				<%=fb.textBox("dx_descripcion",cdo.getColValue("nombre_diagnostico"),false,false,true,25,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','version,icd10,dx_id,dx_descripcion')\"")%>
				<%=fb.button("btn_dx_salida","...",true,viewMode,null,null,"onClick=\"javascript:addDxSalida()\"")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Hora de Salida</cellbytelabel></td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="hora_salida" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_salida")%>" />
				<jsp:param name="hintText" value="12:30 pm" />
				</jsp:include>&nbsp;&nbsp;<span class="Link01Bold"><%=cdo.getColValue("fm")%></span>
			</td>
			<td><cellbytelabel>Condici&oacute;n</cellbytelabel></td>
			<td>
				<%=fb.radio("condicion", "M",(cdo.getColValue("cond").equalsIgnoreCase("M")),viewMode,false)%>
				<cellbytelabel>Mejor</cellbytelabel>
				<%=fb.radio("condicion", "I",(cdo.getColValue("cond").equalsIgnoreCase("I")),viewMode,false)%>
				<cellbytelabel>Igual</cellbytelabel>
				<%=fb.radio("condicion", "S",(cdo.getColValue("cond").equalsIgnoreCase("S")),viewMode,false)%>
				<cellbytelabel>Peor</cellbytelabel>
				<%=fb.radio("condicion", "F",(cdo.getColValue("cond").equalsIgnoreCase("F")),viewMode,false)%>
				<cellbytelabel>Falleci&oacute;</cellbytelabel>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Constancia por</cellbytelabel></td>
			<td><%=fb.decBox("hora_incap",cdo.getColValue("hora_incap"),false,false,true,5,4.2,"Text10",null,"onChange=\"javascript:validaIncap(1,this.value)\"")%> <cellbytelabel>horas</cellbytelabel>
			&nbsp;&nbsp;
			</td>
			<td colspan="2">
				<cellbytelabel>Desde</cellbytelabel>
				<%String setValidDate = "javascript:validaIncap(1,this.value);newHeight();";%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="horai_incap" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("horai_incap")%>" />
				<jsp:param name="jsEvent" value="<%=setValidDate%>" />
            	<jsp:param name="onChange" value="validaIncap(1,this.value)"/>
				<jsp:param name="readonly" value="n"/>
                <jsp:param name="hintText" value="12:30 pm" />
				</jsp:include>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="nameOfTBox1" value="horaf_incap" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("horaf_incap")%>" />
            	<jsp:param name="onChange" value="validaIncap(1,this.value)"/>
				<jsp:param name="jsEvent" value="<%=setValidDate%>" />
				<jsp:param name="readonly" value="n"/>
                <jsp:param name="hintText" value="12:30 pm" />
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Incapacidad por</cellbytelabel></td>
			<td><%=fb.decBox("dia_incap",cdo.getColValue("dia_incap"),false,false,true,5,4.2,"Text10",null,"onChange=\"javascript:validaIncap(2,this.value)\"")%> <cellbytelabel>d&iacute;as</cellbytelabel> </td>
			<td colspan="2">
				<cellbytelabel>Desde el d&iacute;a</cellbytelabel>
				<%String setValidDate2 = "javascript:validaIncap(2,this.value);newHeight();";%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="diai_incap" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("diai_incap")%>" />
            	<jsp:param name="onChange" value="validaIncap(2,this.value)"/>
				<jsp:param name="jsEvent" value="<%=setValidDate2%>" />
				<jsp:param name="readonly" value="n" />
				</jsp:include>
				<cellbytelabel>Hasta el d&iacute;a</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy"/>
				<jsp:param name="nameOfTBox1" value="diaf_incap" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("diaf_incap")%>" />
            	<jsp:param name="onChange" value="validaIncap(2,this.value)"/>
				<jsp:param name="jsEvent" value="<%=setValidDate2%>" />
				<jsp:param name="readonly" value="n" />
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="4">(Incapacidad) Nombre Acompañante
			<%=fb.textBox("nombre_acompaniante",cdo.getColValue("nombre_acompaniante"),false,false,viewMode,30,150,null,null,"")%>&nbsp;
			C&eacute;dula:<%=fb.textBox("cedula_acompaniante",cdo.getColValue("cedula_acompaniante"),false,false,viewMode,25,30,null,null,"")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Referido Consulta Externa al Dr</cellbytelabel>.</td>
			<td>
				<%=fb.textBox("id_med",cdo.getColValue("cod_medico"),false,false,true,2,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','id_med,nombre_med,cod_especialidad_ce,especialidad')\"")%>
				<%=fb.textBox("nombre_med",cdo.getColValue("medico_ref"),false,false,true,25,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','id_med,nombre_med,cod_especialidad_ce,especialidad')\"")%>
				<%=fb.button("btn_cons_ext","...",true,viewMode,null,null,"onClick=\"javascript:addDrConsultaExt()\"")%>
			</td>
			<td><cellbytelabel>Especialidad</cellbytelabel></td>
			<td>
				<%=fb.textBox("cod_especialidad_ce",cdo.getColValue("cod_especialidad_ce"),false,false,true,2)%>
				<%=fb.textBox("especialidad",cdo.getColValue("especialidad_nom"),false,false,true,25)%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Instrucciones al paciente</cellbytelabel><br>(<cellbytelabel>Medicamentos</cellbytelabel>)</td>
			<td><%=fb.textarea("instruccion_med", cdo.getColValue("instruccion_med"), false, false, viewMode, 0, 3,4000, "", "width:100%", "")%></td>
			<td><cellbytelabel>Se entrega por cambio de turno al Dr</cellbytelabel>.</td>
			<td>
				<%=fb.textBox("cambio_turno_id",cdo.getColValue("cod_medico_turno"),false,false,true,2,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cambio_turno_id,cambio_turno')\"")%>
				<%=fb.textBox("cambio_turno",cdo.getColValue("medico_turn"),false,false,true,25,null,null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cambio_turno_id,cambio_turno')\"")%>
				<%=fb.button("btn_cambio_turno","...",true,viewMode,null,null,"onClick=\"javascript:addEntregaDr()\"")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Especialista pedido x Familiar o Pte</cellbytelabel></td>
			<td><%=fb.textBox("especialista_pedido",cdo.getColValue("especialista_p"),false,false,viewMode,35)%></td>
			<td><cellbytelabel>Status</cellbytelabel></td>
			<td><%=fb.select("estado", "P=PROCESO,F=FINALIZADO", cdo.getColValue("estado"),false,viewMode,0,"",null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Observaciones</cellbytelabel></td>
			<td colspan="2"><%=fb.textarea("observaciones",cdo.getColValue("observacion"), false, false, viewMode, 0, 4, 2000,"", "width:100%", "")%></td>
			<td align="center">
			<authtype type='50'>
			<%=fb.button("printExpediente","Imprimir Expediente",true,viewMode,null,null,"onClick=\"javascript:printSalida()\"")%>
			</authtype>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
            <%=fb.hidden("saveOption","O")%>
				<!--<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel> -->
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%//=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
		</div> <!-- END TAB0 -->
		
		
		<div class="dhtmlgoodies_aTab">
		  <table width="100%" cellspacing="1" cellpadding="1">
			<tr>
		  		<td colspan="4"><iframe name="iTransf" id="iTransf" src="" width="100%" height="375" scrolling="auto"></iframe></td>
		  	</tr>
		  </table>
		</div> <!-- END TAB1 -->
		
		
		
		
		
		
		
		
		</div>
		
		<script type="text/javascript">
		<%
		String menuTabs = "";
		String dTabs = "1";
		menuTabs += "'Generales','Datos de Transferencia'";
		if (cdo.getColValue("transf")!=null && cdo.getColValue("transf").equals("S")) dTabs = "";
		%>
		initTabs('dhtmlgoodies_tabView1',Array(<%=menuTabs%>),<%=tab%>,'100%','',null,null,null,[<%=dTabs%>]);
		</script>
		
		
		
		
		
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	

	DatosSalida ds = new DatosSalida();
	ds.setFecNacimiento(request.getParameter("dob"));
	ds.setCodPaciente(request.getParameter("codPac"));
	ds.setSecuencia(request.getParameter("noAdmision"));
	ds.setPacId(request.getParameter("pacId"));
	ds.setHospitalizar(request.getParameter("hospitalizar"));
	if(request.getParameter("transf")!=null)ds.setTransf("S");
	ds.setHoraTransf(request.getParameter("hora_transf"));
	ds.setCodDiagSal(request.getParameter("dx_id"));
	ds.setVersion(request.getParameter("version"));
	ds.setIcd10(request.getParameter("icd10"));
	ds.setHoraSalida(request.getParameter("hora_salida"));
	ds.setCond(request.getParameter("condicion"));
	ds.setHoraIncap(request.getParameter("hora_incap"));
	ds.setHoraiIncap(request.getParameter("horai_incap"));
	ds.setHorafIncap(request.getParameter("horaf_incap"));
	ds.setDiaIncap(request.getParameter("dia_incap"));
	ds.setDiaiIncap(request.getParameter("diai_incap"));
	ds.setDiafIncap(request.getParameter("diaf_incap"));
	ds.setCodMedico(request.getParameter("id_med"));
	ds.setInstruccionMed(request.getParameter("instruccion_med"));
	ds.setCodMedicoTurno(request.getParameter("cambio_turno_id"));
	ds.setEspecialistaP(request.getParameter("especialista_pedido"));
	ds.setCodEspecialidadCe(request.getParameter("cod_especialidad_ce"));
	ds.setEstado(request.getParameter("estado"));
	ds.setObservacion(request.getParameter("observaciones"));
	if (ds.getEstado() != null && ds.getEstado().trim().equalsIgnoreCase("F")) ds.setFinalizaUsuario(UserDet.getUserName());
	
	ds.setNombreAcompaniante(request.getParameter("nombre_acompaniante"));
	ds.setCedulaAcompaniante(request.getParameter("cedula_acompaniante"));
	
	ds.setUsuarioModificacion((String)session.getAttribute("_userName"));
	ds.setFechaModificacion(cDateTime);
	
	if (modeSec.equalsIgnoreCase("add")){
	  ds.setUsuarioCreacion((String)session.getAttribute("_userName"));
	  ds.setFechaCreacion(cDateTime);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add")) DSMgr.add(ds);
	else if (modeSec.equalsIgnoreCase("edit")) DSMgr.update(ds);
    
    /*DSMgr.setErrCode("1");
    DSMgr.setErrMsg("Test success!!");*/
    
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow()
{
<%
if (DSMgr.getErrCode().equals("1"))
{
%>
	alert('<%=DSMgr.getErrMsg()%>');
<%
	if (ds.getEstado() != null && ds.getEstado().trim().equalsIgnoreCase("F"))
	{
	%>abrir_ventana2('../expediente/print_sal10010_cu.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&fg=<%=fg%>');
	<%if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
	parent.window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
	parent.window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}
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
} else throw new Exception(DSMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode(){
<% if (ds.getEstado() != null && ds.getEstado().trim().equalsIgnoreCase("F")) { %>
parent.window.location='..'+top.document.location.pathname.replace('<%=request.getContextPath()%>','')+<% if (expVer.equals("2")) { %>'?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&cds=<%=cds%>&estado=F&careDate=<%=careDate%>&catId=<%=catId%>&modeSec=view'<% } else { %>'?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&modeSec=view&mode=<%=mode%>'<% } %>;
<% } else { %>
window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&cds=<%=cds%>';
<% } %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>
