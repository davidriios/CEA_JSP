<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.expediente.DatosSalida"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
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
String docId = request.getParameter("docId");
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
if (docId == null) docId = "";
String active0 = "", active1 = "";
String profiles = CmnMgr.vector2numSqlInClause(UserDet.getUserProfile());

if (request.getMethod().equalsIgnoreCase("GET"))
{

    if (tab.equals("0")) active0 = "active";
    else if (tab.equals("1")) active1 = "active";

    if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
	
	sql = "SELECT a.cod_paciente, a.secuencia, to_char(a.fec_nacimiento,'dd/mm/yyyy') as fec_nacimiento, a.pac_id, nvl(a.hospitalizar,' ') as hospitalizar, nvl(a.transf,'N') as transf, nvl(to_char(a.hora_transf,'hh12:mi am'),' ') as hora_transf, nvl(a.cod_diag_sal,' ') as cod_diag_sal, nvl(to_char(a.hora_salida,'hh12:mi am'),' ') as hora_salida, nvl(a.cond,' ') as cond, decode(a.hora_incap,null,' ',''||a.hora_incap) as hora_incap, nvl(to_char(a.horai_incap,'hh12:mi am'),' ') as horai_incap, nvl(to_char(a.horaf_incap,'hh12:mi am'),' ') as horaf_incap, decode(a.dia_incap,null,' ',''||a.dia_incap) as dia_incap, nvl(to_char(a.diai_incap,'dd/mm/yyyy'),' ') as diai_incap, nvl(to_char(a.diaf_incap,'dd/mm/yyyy'),' ') as diaf_incap, nvl(a.instruccion_med,' ') as instruccion_med, nvl(a.cod_medico,' ') as cod_medico, nvl(a.cod_medico_turno,' ') as cod_medico_turno, nvl(a.cod_especialidad_ce,' ') as cod_especialidad_ce, nvl(a.especialista_p,' ') as especialista_p, nvl(a.estado,' ') as estado, nvl(a.observacion,' ') as observacion, decode(a.cod_diag_sal,null,' ',(SELECT coalesce(observacion,nombre) FROM tbl_cds_diagnostico WHERE codigo=a.cod_diag_sal)) as nombre_diagnostico, decode(a.cod_medico,null,' ',(SELECT primer_nombre||decode(segundo_nombre,null,' ','  '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ','  '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',' '||apellido_de_casada)) as nombre FROM tbl_adm_medico WHERE codigo=a.cod_medico)) as medico_ref, decode(a.cod_medico_turno,null,' ',(SELECT primer_nombre||decode(segundo_nombre,null,' ',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',' '||apellido_de_casada)) as nombre FROM tbl_adm_medico WHERE codigo=a.cod_medico_turno)) as medico_turn, decode(a.cod_especialidad_ce,null,' ',(SELECT descripcion FROM tbl_adm_especialidad_medica WHERE codigo=a.cod_especialidad_ce)) AS especialidad_nom, a.nombre_acompaniante, a.cedula_acompaniante, to_char(a.fecha_modificacion,'dd/mm/yyyy') fm, a.transf_sbar hospitalizacion_sbar, a.motivos_sbar, a.sbar_reporte, a.sbar_recibe FROM tbl_sal_adm_salida_datos a WHERE pac_id="+pacId+" and secuencia="+noAdmision;
	cdo = SQLMgr.getData(sql);
	if (cdo == null)
	{
		if (!viewMode) modeSec = "add";
        
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
    
    boolean validarEscalas = false;
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'SAL_VALIDAR_ESCALAS'),'N') validar_escalas from dual ");
    if (paramCdo == null) {
        paramCdo = new CommonDataObject();
        paramCdo.addColValue("validar_escalas","N");
    }
    validarEscalas = paramCdo.getColValue("validar_escalas","N").equalsIgnoreCase("S") || paramCdo.getColValue("validar_escalas","N").equalsIgnoreCase("Y");
	
	if (!viewMode) {
		CommonDataObject _cdo = SQLMgr.getData("select da.diagnostico as cod_diag_sal, coalesce(d.observacion,d.nombre) nombre_diagnostico from tbl_adm_diagnostico_x_admision da, tbl_cds_diagnostico d where da.pac_id = "+pacId+" and da.admision = "+noAdmision+" and da.orden_diag = 1 and d.codigo = da.diagnostico and da.tipo = 'S' ");
		if (_cdo == null) _cdo = new CommonDataObject();
		cdo.addColValue("cod_diag_sal", _cdo.getColValue("cod_diag_sal"));
		cdo.addColValue("nombre_diagnostico", _cdo.getColValue("nombre_diagnostico"));
	}
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - Datos de Salida - '+document.title;
function doAction(){}

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
function printSalida(){abrir_ventana1('../expediente/print_sal10010_cu.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&fg=<%=fg%>&exp=3<%=(!viewMode)?"&cod_diag_sal_tmp="+IBIZEscapeChars.forURL(cdo.getColValue("cod_diag_sal"," "))+"&nombre_diag_sal_tmp="+IBIZEscapeChars.forURL(cdo.getColValue("nombre_diagnostico"," ")) : ""%>');}

function validateStatus(){
    var estado =getDBData('<%=request.getContextPath()%>','decode(estado,\'P\',1,\'F\',-1,0) ','tbl_sal_adm_salida_datos','pac_id=<%=pacId%> and secuencia=<%=noAdmision%>','');
    if(estado == -1 ){
        parent.CBMSG.error('El expediente de este paciente ya fue finalizado!');
        return false;
    } else {
        if(document.form001.estado.value == 'F') {
            if(!confirm('Al finalizar la atención el Expediente ya no estará disponible para modificaciones. ¿Está seguro que desea finalizar?')) return false;
            
            if(document.form001.dx_id.value.trim()==''){
                alert('El diagnóstico de salida está en blanco, debe de registrarlo antes de cerrar el Expediente llenando "Diagnóstico de Salida"!');
                //addDxSalida();
                return false;
            } else {
                var cantidad = getDBData('<%=request.getContextPath()%>','count(*) cantidad','tbl_adm_diagnostico_x_admision','pac_id=<%=pacId%> and admision=<%=noAdmision%> and tipo=\'S\' and orden_diag=1','');
                
                if(cantidad >1){
                    parent.CBMSG.error('Existe mas de un diagnostico con prioridad 1. \n- Solo debe existir un diagnostico con prioridad (1)');
                    return false;
                }
                
                <%if(validarEscalas){%>
                cantidad = getDBData('<%=request.getContextPath()%>','count(*) cantidad','tbl_sal_escalas',"pac_id=<%=pacId%> and admision=<%=noAdmision%> and tipo in ('AN','CA','DO','MAC','MM5')",'');
                
                if (cantidad < 1) {
                    parent.CBMSG.error('Por favor asegúrese de que haya por lo menos una escala de dolor registrada!');
                    return false;
                }
                <%}%>
                
                
            }
        }
        return true;
    }
}
function printCartaTraslado(){
	var to = jQuery.trim("<%=cdo.getColValue("transf")%>");
	if (to=="") alert("Por favor registre la información de traslado antes de imprimir");
	else abrir_ventana("../expediente/print_carta_traslado.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&to="+to);
}
function printDatos(){  
  abrir_ventana("../expediente/print_ex_datos_salida.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%><%=(!viewMode)?"&cod_diag_sal_tmp="+IBIZEscapeChars.forURL(cdo.getColValue("cod_diag_sal"," "))+"&nombre_diag_sal_tmp="+IBIZEscapeChars.forURL(cdo.getColValue("nombre_diagnostico"," ")) : ""%>");
 }
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

     $('iframe').iFrameResize({
        log: false
      });
     $(".disable").click(function(c){
       <%if(cdo.getColValue("transf")!=null && cdo.getColValue("transf").equals("S")){%>
        if (!$("#iTransf").attr("src")) {
          $("#iTransf").attr("src","../expediente3.0/exp_reg_transferencia_det.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tab=1&cds=<%=cds%>&desc=<%=desc%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>");
        }
       <%} else {%>
         c.preventDefault();
         return false;
       <%}%>
     });
     
     $("#hospitalizacion_sbar").click(function(e){
        if(this.checked) $("#motivos_sbar").prop('readOnly', false);
        else $("#motivos_sbar").prop('readOnly', true).val("");
     });
});

function canSubmitOld(){
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
	   else if (usrEndDate){
	   
	   var diasInc = getDBData("<%=request.getContextPath()%>","nvl(get_sec_comp_param(<%=(String) session.getAttribute("_companyId")%>,'EXP_DIAS_INCAP'),-1)","dual","","");
 	   if(diasInc > 0){
	     if( getDBData("<%=request.getContextPath()%>","case when to_date('"+usrEndDate+"','dd/mm/yyyy') - to_date('"+fechaIni+"','dd/mm/yyyy') >  "+diasInc+" then 'INVALID' else 'VALID' end my_date","dual","","") == 'INVALID'){
		  CBMSG.error("No puede registrar Incapacidades mayores a "+diasInc+" Dias!"); 
		  form001BlockButtons(false); return false;
		 }
		}
	   } 
       else if ($("#hospitalizacion_sbar").is(":checked") && !$.trim($("#motivos_sbar").val()) ){
         CBMSG.error("Por favor indique los motivos para la hospitalización SBAR!"); 
		 form001BlockButtons(false); return false;
       } 
	}
	return true;
  }
}

function validateReqSeccion() {
  if (document.form001.estado.value != 'F') return true;
  
  var $indicator = $("#indicator");
  $indicator.html("Validando secciones mandatorias para cerrar el expediente...");
  var w = "codigo in(select secc_code from tbl_sal_exp_docs_secc where req_para_cerrar = 'Y' and doc_id in ( select doc_id from tbl_sal_exp_docs_profile where profile_id IN (<%=profiles%>)) and doc_id = <%=docId%>)";
  var d = getDBData('<%=request.getContextPath()%>','table_name, where_clause, descripcion','tbl_sal_expediente_secciones', w);
  var rows = splitRowsCols(d);
  
  for (var i = 0; i < rows.length; i++) {
    var table = rows[i][0];
    var where = rows[i][1];
    var name = rows[i][2];
    
    where = where.replace(/@@PACID/g, '<%=pacId%>').replace(/@@ADMISION/g, '<%=noAdmision%>');
    
    if (where.includes("@@FCF") && where.includes("@@FCT")) {
       where = where.replace(/@@FCF/g, '(select trunc(fecha_ingreso) from tbl_adm_admision where pac_id = <%=pacId%> and secuencia = <%=noAdmision%>)').replace(/@@FCT/g, 'trunc(sysdate)');
    }
    
    if (table && where) {
      var res = getDBData('<%=request.getContextPath()%>','count(*)', table, where);

      if (!parseInt(res)) {
         $indicator.css("color", "red").html("[ERROR] No se puede cerrar el Expediente sin antes llenar la sección: "+name);
         form001BlockButtons(false);
         return false;
      }
    }
  } // for
  
  $indicator.html("");
  return true;
}

function canSubmit(){
   var usrEndDate = $("#diaf_incap").val();
   var fechaIni   = $("#diai_incap").val();
   var f_ingreso = parent.document.paciente.fechaIngreso.value;
   var valIngreso = getDBData("<%=request.getContextPath()%>","nvl(get_sec_comp_param(<%=(String) session.getAttribute("_companyId")%>,'EXP_TIPO_F_INC'),'N')","dual","","");
   var msg =' que ingresó al Hospital';
   if(valIngreso=='S'){f_ingreso='<%=cDateTime.substring(0,10)%>';msg =' Actual';}
   
   if(fechaIni !=null && fechaIni !='' && f_ingreso!='' && valIngreso!='N') {
        if( getDBData("<%=request.getContextPath()%>","case when to_date('"+fechaIni+"','dd/mm/yyyy') < to_date('"+f_ingreso+"','dd/mm/yyyy') then 'INVALID' else 'VALID' end my_date","dual","","") == 'INVALID'){
            CBMSG.error("No puede registrar incapacidad con fecha  menor a la fecha "+msg+" !"); 
            form001BlockButtons(false); return false;
        }
   }
   else if (usrEndDate){
        var diasInc = getDBData("<%=request.getContextPath()%>","nvl(get_sec_comp_param(<%=(String) session.getAttribute("_companyId")%>,'EXP_DIAS_INCAP'),-1)","dual","","");
        if(diasInc > 0){
            if( getDBData("<%=request.getContextPath()%>","case when to_date('"+usrEndDate+"','dd/mm/yyyy') - to_date('"+fechaIni+"','dd/mm/yyyy') >  "+diasInc+" then 'INVALID' else 'VALID' end my_date","dual","","") == 'INVALID'){
                CBMSG.error("No puede registrar Incapacidades mayores a "+diasInc+" Dias!"); 
                form001BlockButtons(false); return false;
            }
        }
   } 
   else if ($("#hospitalizacion_sbar").is(":checked") && !$.trim($("#motivos_sbar").val()) ){
        CBMSG.error("Por favor indique los motivos para la hospitalización SBAR!"); 
        form001BlockButtons(false); return false;
   } else if(!validateReqSeccion()) {
    form001BlockButtons(false); return false;
   }
   
   return true;
}

</script>
<style>
table {
  width: 100%;
  border-collapse: collapse;
}

td, th {
  padding: .25em;
  border: 1px solid black;
}

tbody:nth-child(odd) {
  background: #CCC;
}
#indicator {
margin-right: 20px;
font-weight: bold;
}
</style>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
    <div class="headerform"></div>
    
    <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="<%=active0%>">
            <a href="#generales" aria-controls="generales" role="tab" data-toggle="tab"><b>Generales</b></a>
        </li>
        <li role="presentation" class="disable <%=active1%>">
            <a href="#datos_de_tranferencia" aria-controls="datos_de_tranferencia" role="tab" data-toggle="tab"><b>Datos de Transferencia</b></a>
        </li>
    </ul>
    
    <div class="tab-content">
    
        <div role="tabpanel" class="tab-pane <%=active0%>" id="generales">
        
           <%fb = new FormBean2("form001",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
            <%=fb.hidden("docId",docId)%>
            <%fb.appendJsValidation("if(!canSubmit()){return false; error++;}");%>
            <table cellspacing="0" class="table table-small-font table-bordered">
              <tr>
                  <td colspan="4" align="right">
                   
                   <%=fb.button("imprimir","Imprimir",false,false,null,null,"onClick=\"javascript:printDatos()\"")%>
                   
                   <button type="button" name="printExpediente" id="printExpediente" class="btn btn-inverse btn-sm" onclick="javascript:printSalida()"><i class="fa fa-print fa-lg"></i> Imprimir Expediente</button>
                   
                   <% if (!viewMode){%>
                    
                    <button type="button" class="btn btn-inverse btn-sm" onclick="javascript:printRecetas()">[ <cellbytelabel>Recetas</cellbytelabel> ]</button>
                    
                    <%if(cdo.getColValue("hora_incap")!=null && !cdo.getColValue("hora_incap").trim().equals("")){%>
                        <button type="button" class="btn btn-inverse btn-sm" onclick="javascript:printConsIncap('C')">[ <cellbytelabel>Constancia</cellbytelabel> ]</button>
                    <%}%>
                    <%if(cdo.getColValue("dia_incap")!=null && !cdo.getColValue("dia_incap").trim().equals("")){%>
                        <button type="button" class="btn btn-inverse btn-sm" onclick="javascript:printConsIncap('I')">[ <cellbytelabel>Incapacidad</cellbytelabel> ]</button>
                    <%}%>
                    <%}%>
                  </td>
                </tr>
                
                <tbody>
                <tr>
                    <td width="15%"><cellbytelabel>Hospitalizaci&oacute;n</cellbytelabel></td>
                    <td width="35%">
                        <label class="pointer"><%=fb.radio("hospitalizar", "S",(cdo.getColValue("hospitalizar").equalsIgnoreCase("S")),viewMode,false)%><cellbytelabel>S&iacute;</cellbytelabel></label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer"><%=fb.radio("hospitalizar", "N",(cdo.getColValue("hospitalizar").equalsIgnoreCase("N")),viewMode,false)%><cellbytelabel>No</cellbytelabel></label>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                         
                        <label class="pointer"><b><cellbytelabel>Transferencia</cellbytelabel></b>
                      <%=fb.checkbox("transf",cdo.getColValue("transf"),(cdo.getColValue("transf")!=null && cdo.getColValue("transf").equals("S")),(viewMode||cdo.getColValue("transf")!=null && cdo.getColValue("transf").equals("S")),"","","","","")%></label>
                    </td>
                    
                    <td width="50%" colspan="2" class="controls form-inline">
                    <label class="pointer"><b><cellbytelabel>SBAR</cellbytelabel></b>
                        <%=fb.checkbox("hospitalizacion_sbar",cdo.getColValue("hospitalizacion_sbar"),(cdo.getColValue("hospitalizacion_sbar")!=null && cdo.getColValue("hospitalizacion_sbar"," ").equals("S")),viewMode,"","","","","")%></label>
                    <%=fb.textBox("motivos_sbar",cdo.getColValue("motivos_sbar"),false,false,viewMode||cdo.getColValue("motivos_sbar"," ").trim().equals(""),50,500,"form-control input-sm",null,"")%>
                    
                        
                      </td>
                </tr>
                </tbody>
                
                <tbody>
                    <tr>
                        <td>¿Qui&eacute;n reporta?</td>
                        <td>
                            <%=fb.textBox("sbar_reporte",cdo.getColValue("sbar_reporte"),false,false,viewMode,0,100,"form-control input-sm",null,"")%>
                        </td>
                        <td>¿Qui&eacute;n recibe?</td>
                        <td>
                            <%=fb.textBox("sbar_recibe",cdo.getColValue("sbar_recibe"),false,false,viewMode,0,100,"form-control input-sm",null,"")%>
                        </td>
                    </tr>
                </tbody>
                
                
                <tbody>
                <tr>
                    <td>Hora</td>
                    <td class="controls form-inline">
                        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                        <jsp:param name="noOfDateTBox" value="1"/>
                        <jsp:param name="format" value="hh12:mi am"/>
                        <jsp:param name="nameOfTBox1" value="hora_transf" />
                        <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_transf")%>" />
                        <jsp:param name="hintText" value="12:30 pm" />
                        </jsp:include>&nbsp;&nbsp;<span class="Link01Bold"><%=cdo.getColValue("fm")%></span>
                    </td>
                    <td><cellbytelabel>Dx. de Salida</cellbytelabel></td>
                    <td class="controls form-inline">
                        <%=fb.textBox("dx_id",cdo.getColValue("cod_diag_sal"),false,false,true,2,"form-control input-sm",null,"")%>
                        <%=fb.textBox("dx_descripcion",cdo.getColValue("nombre_diagnostico"),false,false,true,25,"form-control input-sm",null,"")%>
                        <%//=fb.button("btn_dx_salida","...",true,viewMode,null,null,"onClick=\"javascript:addDxSalida()\"")%>
                    </td>
                </tr>
                </tbody>
                
                <tbody>
                <tr>
                    <td><cellbytelabel>Hora de Salida</cellbytelabel></td>
                    <td class="controls form-inline">
                        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                        <jsp:param name="noOfDateTBox" value="1"/>
                        <jsp:param name="format" value="hh12:mi am"/>
                        <jsp:param name="nameOfTBox1" value="hora_salida" />
                        <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_salida")%>" />
                        <jsp:param name="hintText" value="12:30 pm" />
                        </jsp:include>&nbsp;&nbsp;<span class="Link01Bold"><%=cdo.getColValue("fm")%></span>
                    </td>
                    <td><cellbytelabel>Condici&oacute;n</cellbytelabel></td>
                    <td>
                        <label class="pointer"><%=fb.radio("condicion", "M",(cdo.getColValue("cond").equalsIgnoreCase("M")),viewMode,false)%>
                        <cellbytelabel>Mejor</cellbytelabel></label>
                        
                        &nbsp;&nbsp;
                        <label class="pointer"><%=fb.radio("condicion", "I",(cdo.getColValue("cond").equalsIgnoreCase("I")),viewMode,false)%>
                        <cellbytelabel>Igual</cellbytelabel></label>
                        
                        &nbsp;&nbsp;
                        <label class="pointer"><%=fb.radio("condicion", "S",(cdo.getColValue("cond").equalsIgnoreCase("S")),viewMode,false)%>
                        <cellbytelabel>Peor</cellbytelabel></label>
                        
                        &nbsp;&nbsp;
                        <label class="pointer"><%=fb.radio("condicion", "F",(cdo.getColValue("cond").equalsIgnoreCase("F")),viewMode,false)%>
                        <cellbytelabel>Falleci&oacute;</cellbytelabel></label>
                        
                    </td>
                </tr>
                </tbody>
                
                <tbody>
                <tr>
                    <td><cellbytelabel>Constancia por</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.decBox("hora_incap",cdo.getColValue("hora_incap"),false,false,true,5,4.2,"form-control input-sm",null,"onChange=\"javascript:validaIncap(1,this.value)\"")%> <cellbytelabel>horas</cellbytelabel>
                    &nbsp;&nbsp;
                    </td>
                    <td colspan="2" class="controls form-inline">
                        <cellbytelabel>Desde</cellbytelabel>
                        <%String setValidDate = "javascript:validaIncap(1,this.value);";%>
                        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                        <jsp:param name="noOfDateTBox" value="1"/>
                        <jsp:param name="format" value="hh12:mi am"/>
                        <jsp:param name="nameOfTBox1" value="horai_incap" />
                        <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("horai_incap")%>" />
                        <jsp:param name="jsEvent" value="<%=setValidDate%>" />
                        <jsp:param name="onChange" value="validaIncap(1,this.value)"/>
                        <jsp:param name="readonly" value="n"/>
                        <jsp:param name="hintText" value="12:30 pm" />
                        </jsp:include>
                        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
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
                </tbody>
                
                <tbody>
                <tr>
                    <td><cellbytelabel>Incapacidad por</cellbytelabel></td>
                    <td class="controls form-inline"><%=fb.decBox("dia_incap",cdo.getColValue("dia_incap"),false,false,true,5,4.2,"form-control input-sm",null,"onChange=\"javascript:validaIncap(2,this.value)\"")%> <cellbytelabel>d&iacute;as</cellbytelabel> </td>
                    <td colspan="2" class="controls form-inline">
                        <cellbytelabel>Desde el d&iacute;a</cellbytelabel>
                        <%String setValidDate2 = "javascript:validaIncap(2,this.value);";%>
                        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                        <jsp:param name="noOfDateTBox" value="1"/>
                        <jsp:param name="format" value="dd/mm/yyyy"/>
                        <jsp:param name="nameOfTBox1" value="diai_incap" />
                        <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("diai_incap")%>" />
                        <jsp:param name="onChange" value="validaIncap(2,this.value)"/>
                        <jsp:param name="jsEvent" value="<%=setValidDate2%>" />
                        <jsp:param name="readonly" value="n" />
                        </jsp:include>
                        <cellbytelabel>Hasta el d&iacute;a</cellbytelabel>
                        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
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
                </tbody>
                
                <tbody>
                <tr>
                    <td colspan="4" class="controls form-inline">(Incapacidad) Nombre Acompañante
                    <%=fb.textBox("nombre_acompaniante",cdo.getColValue("nombre_acompaniante"),false,false,viewMode,30,150,"form-control input-sm",null,"")%>&nbsp;
                    C&eacute;dula:<%=fb.textBox("cedula_acompaniante",cdo.getColValue("cedula_acompaniante"),false,false,viewMode,25,30,"form-control input-sm",null,"")%>
                    </td>
                </tr>
                </tbody>
                
                <tbody>
                <tr>
                    <td><cellbytelabel>Referido Consulta Externa al Dr</cellbytelabel>.</td>
                    <td class="controls form-inline">
                        <%=fb.textBox("id_med",cdo.getColValue("cod_medico"),false,false,true,2,"form-control input-sm",null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','id_med,nombre_med,cod_especialidad_ce,especialidad')\"")%>
                        <%=fb.textBox("nombre_med",cdo.getColValue("medico_ref"),false,false,true,25,"form-control input-sm",null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','id_med,nombre_med,cod_especialidad_ce,especialidad')\"")%>
                        <%=fb.button("btn_cons_ext","...",true,viewMode,null,null,"onClick=\"javascript:addDrConsultaExt()\"")%>
                    </td>
                    <td><cellbytelabel>Especialidad</cellbytelabel></td>
                    <td class="controls form-inline">
                        <%=fb.textBox("cod_especialidad_ce",cdo.getColValue("cod_especialidad_ce"),false,false,true,2,"form-control input-sm",null,null)%>
                        <%=fb.textBox("especialidad",cdo.getColValue("especialidad_nom"),false,false,true,25,"form-control input-sm",null,null)%>
                    </td>
                </tr>
                </tbody>
                
                <tbody>
                <tr>
                    <td><cellbytelabel>Instrucciones al paciente</cellbytelabel><br>(<cellbytelabel>Medicamentos</cellbytelabel>)</td>
                    <td><%=fb.textarea("instruccion_med", cdo.getColValue("instruccion_med"), false, false, viewMode, 0, 1,4000, "form-control input-sm", "width:100%", "")%></td>
                    <td><cellbytelabel>Se entrega por cambio de turno al Dr</cellbytelabel>.</td>
                    <td class="controls form-inline">
                        <%=fb.textBox("cambio_turno_id",cdo.getColValue("cod_medico_turno"),false,false,true,2,"form-control input-sm",null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cambio_turno_id,cambio_turno')\"")%>
                        <%=fb.textBox("cambio_turno",cdo.getColValue("medico_turn"),false,false,true,25,"form-control input-sm",null,"onDblClick=\"javascript:setFormFieldsBlank('"+fb.getFormName()+"','cambio_turno_id,cambio_turno')\"")%>
                        <%=fb.button("btn_cambio_turno","...",true,viewMode,null,null,"onClick=\"javascript:addEntregaDr()\"")%>
                    </td>
                </tr>
                </tbody>
                
                <tbody>
                <tr>
                    <td><cellbytelabel>Especialista pedido x Familiar o Pte</cellbytelabel></td>
                    <td><%=fb.textBox("especialista_pedido",cdo.getColValue("especialista_p"),false,false,viewMode,35, "form-control input-sm", null, null)%></td>
                    <td><cellbytelabel>Status</cellbytelabel></td>
                    <td><%=fb.select("estado", "P=PROCESO,F=FINALIZADO", cdo.getColValue("estado"),false,viewMode,0,"",null,null)%></td>
                </tr>
                </tbody>
                
                <tbody>
                <tr>
                    <td><cellbytelabel>Observaciones</cellbytelabel></td>
                    <td colspan="2"><%=fb.textarea("observaciones",cdo.getColValue("observacion"), false, false, viewMode, 0, 2, 2000,"form-control input-sm", "width:100%", "")%></td>
                    <td align="center">                        
                        
                        
                    
                    </td>
                </tr>
                </tbody>
            </table>
            
            <div class="footerform" style="bottom:-11px !important">
                <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                    <tr>
                        <td>
                        <span id="indicator"></span>
                        
                        <%=fb.hidden("saveOption","O")%>
                        <%=fb.submit("save","Guardar",true,viewMode,null,null,"")%>
                        </td>
                    </tr>
                </table>
           </div>     
            
            <%=fb.formEnd(true)%>
        </div>
        
        <div role="tabpanel" class="tab-pane <%=active1%>" id="datos_de_tranferencia">
          <iframe name="iTransf" id="iTransf" src="" style="border:none;" width="100%" height="375" scrolling="auto"></iframe>
        </div>
    
    
    </div>

</div>
</div>
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
    
    if (request.getParameter("hospitalizacion_sbar") != null) {
        ds.setHospSbar("S");
    }
    if (request.getParameter("motivos_sbar")!= null && !request.getParameter("motivos_sbar").trim().equals("") ) {
        ds.setMotivosSbar(request.getParameter("motivos_sbar"));
    }
    
    ds.setSbarReporte(request.getParameter("sbar_reporte"));
    ds.setSbarRecibe(request.getParameter("sbar_recibe"));
   
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
	%>abrir_ventana2('../expediente/print_sal10010_cu.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&fg=<%=fg%>&exp=3');
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
parent.window.location='..'+top.document.location.pathname.replace('<%=request.getContextPath()%>','')+<% if (expVer.equals("2")) { %>'?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&cds=<%=cds%>&estado=F&careDate=<%=careDate%>&catId=<%=catId%>&modeSec=view&docId=<%=docId%>'<% } else { %>'?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&modeSec=view&mode=<%=mode%>&docId=<%=docId%>'<% } %>;
<% } else { %>
window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&cds=<%=cds%>&docId=<%=docId%>';
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
