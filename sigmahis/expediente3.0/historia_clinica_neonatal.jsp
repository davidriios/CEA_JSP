<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String compania = (String) session.getAttribute("_companyId");
String codigo = request.getParameter("codigo");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";

if (from == null) from = "";
if (codigo == null) codigo = "";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

cdo = SQLMgr.getData("select codigo from tbl_sal_hist_cli_neonatal where pac_id = "+pacId+" and admision = "+noAdmision+" and fecha_creacion = (select max(fecha_creacion) from tbl_sal_hist_cli_neonatal where pac_id = "+pacId+" and admision = "+noAdmision+")");
if (cdo == null) cdo = new CommonDataObject();
codigo = cdo.getColValue("codigo","0");

if (!codigo.equals("0")) {
  if (!viewMode) mode = "edit";
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	prop = SQLMgr.getDataProperties("select hist from tbl_sal_hist_cli_neonatal where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+codigo);
	
	if (prop == null){
		if(!viewMode) modeSec="add";
    prop = new Properties();
	}
	else{
		if(!viewMode) modeSec= "edit";
	}
	
	 if (modeSec.equalsIgnoreCase("view")) viewMode = true;
   if (mode.equalsIgnoreCase("view")) viewMode = true;
%>
<!DOCTYPE html>
<html lang="es"> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
var noNewHeight = true;
function doAction(){} 
$(document).ready(function(){
 
  $(".should-type").click(function(){
      var that = $(this);
      var i = that.data('index');
      if (that.is(":checked")) {
        $("#observacion"+i).prop("readOnly", false)
      } else {
        $("#observacion"+i).val("").prop("readOnly", true)
      }
    });

});

function showError(message) {
  <%=from.trim().equalsIgnoreCase("salida_pop")?"parent.":""%>parent.CBMSG.error(message);
}

/**
* el: dom element
*/
function scrollToElem(el) {
    if (el) {
        if (!el.scrollIntoView) {
          $('html, body').animate({
            scrollTop: parseInt($(el).offset().top, 10)
          }, 500);
        }
        else el.scrollIntoView();
    }
}

function canSubmit() {
  var proceed = true;
  
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    if ( $self.is(":checked") && !$.trim($("#observacion"+i).val())) {
      <%=from.trim().equalsIgnoreCase("salida_pop")?"parent.":""%>parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
      proceed = false;
      $self.focus();
      debug($self)
      return false;  
    }else  {proceed = true;}
  });
 
  return proceed;
}

function shouldTypeRadio(check, textareaIndex) {
  if (check == true) $("#observacion"+textareaIndex).prop("readOnly", false)
  else $("#observacion"+textareaIndex).val("").prop("readOnly", true)
}

function printExp(){
    abrir_ventana("../expediente3.0/print_historia_clinica_neonatal.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&codigo=<%=codigo%>");
}
</script>
<style>
  .text-center{text-align:center !important;}
</style>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">    
    <div class="table-responsive" data-pattern="priority-columns">
		<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
		<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("modeSec",modeSec)%>
		<%=fb.hidden("seccion",seccion)%>
		<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
    <%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
		<%=fb.hidden("dob","")%>
		<%=fb.hidden("codPac","")%>
		<%=fb.hidden("pacId",pacId)%>
		<%=fb.hidden("noAdmision",noAdmision)%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("desc",desc)%>
		<%=fb.hidden("from", from)%>
		<%=fb.hidden("codigo", codigo)%>
        
        <div class="headerform">
        <table cellspacing="0" class="table pull-right table-striped table-custom-1">
            <tr>
                <td>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="printExp()"><i class="material-icons fa-printico">print</i> <b>Imprimir</b></button>
                </td>
            </tr>
        </table>
        </div>

        <table class="table table-small-font table-bordered table-striped">
            <tbody>
            
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                
         
        
          <tr class="bg-headtabla2">
            <th colspan="6">DATOS MATERNOS</th>
          </tr>
          
          <tr>
              <td><b>F.U.M</b></td>
              <td><b>GRAVA</b></td>
              <td><b>PARA</b></td>
              <td><b>ABORTOS</b></td>
              <td><b>No. DE CONTROLES PRENATALES</b></td>
              <td><b>SENSIBILIZACI&Oacute;N</b></td>
          </tr>
           
           <tr>
           
            <td class="controls form-inline">
              <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1"/>
                    <jsp:param name="format" value="dd/mm/yyyy"/>
                    <jsp:param name="nameOfTBox1" value="data1" />
                    <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("data1")!=null?prop.getProperty("data1"):""%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                </jsp:include>
            </td>
            
            <td><%=fb.textBox("data2", prop.getProperty("data2"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline">
              Vaginal:<%=fb.textBox("data3", prop.getProperty("data3"),false,false,viewMode,3,"form-control input-sm",null,null)%>&nbsp;Ces&aacute;rea:<%=fb.textBox("data4", prop.getProperty("data4"),false,false,viewMode,3,"form-control input-sm",null,null)%>
            </td>
            
            <td><%=fb.textBox("data5", prop.getProperty("data5"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
            <td><%=fb.textBox("data6", prop.getProperty("data6"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
            
            <td>
                Rh&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("data7","S",prop.getProperty("data7")!=null&&prop.getProperty("data7").equals("S"),viewMode,false)%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data7","N",prop.getProperty("data7")!=null&&prop.getProperty("data7").equals("N"),viewMode,false)%>&nbsp;NO</label>
                <br>
                
                ABO&nbsp;&nbsp;&nbsp;<label class="pointer"><%=fb.radio("data8","S",prop.getProperty("data8")!=null&&prop.getProperty("data8").equals("S"),viewMode,false)%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data8","N",prop.getProperty("data8")!=null&&prop.getProperty("data8").equals("N"),viewMode,false)%>&nbsp;NO</label>
            
            </td>
           </tr>
           
           
           <tr>
              <td class="controls form-inline">
                <b>SEROLOG&Iacute;A - LUES</b><br>
                <label class="pointer"><%=fb.radio("data9","S",prop.getProperty("data9")!=null&&prop.getProperty("data9").equals("S"),viewMode,false)%>&nbsp;Positivo</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data9","N",prop.getProperty("data9")!=null&&prop.getProperty("data9").equals("N"),viewMode,false)%>&nbsp;Negativo</label>
              </td>
              
              <td class="" colspan="2">
                <b>RUPTURAS DE MEMBRANAS (Horas)</b><br>
                <%=fb.textBox("data10", prop.getProperty("data10"),false,false,viewMode,5,"form-control input-sm",null,null)%>
              </td>
              
              <td class="controls form-inline">
                <b>EDAD GEST. (Sem.)</b><br>
                 <%=fb.textBox("data11", prop.getProperty("data11"),false,false,viewMode,5,"form-control input-sm",null,null)%>
              </td>
              
              <td colspan="2">
                <b>PATOLOG&Iacute;A</b><br>
                <label class="pointer"><%=fb.radio("data12","N",prop.getProperty("data12")!=null&&prop.getProperty("data12").equals("N"),viewMode,false, null, null, "onclick='shouldTypeRadio(false,12)'")%>&nbsp;NO</label>
                
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data12","S",prop.getProperty("data12")!=null&&prop.getProperty("data12").equals("S"),viewMode,false, "observacion", null, "onclick='shouldTypeRadio(true,12)'",""," data-index=12 data-message='Por favor indique las patologías.'")%>&nbsp;SI</label>
                
                <%=fb.textarea("observacion12",prop.getProperty("observacion12"),false,false,(viewMode||prop.getProperty("observacion12").equals("")),0,1,2000,"form-control input-sm","",null)%>
                                
              </td>
              
           </tr>
           
            <tr>
              <td colspan="6">
                <b>PATOLOG&Iacute;A EN HIJOS ANTERIORES</b><br>
                <label class="pointer"><%=fb.radio("data13","N",prop.getProperty("data13")!=null&&prop.getProperty("data13").equals("N"),viewMode,false, null, null, "onclick='shouldTypeRadio(false,13)'")%>&nbsp;NO</label>
                
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data13","S",prop.getProperty("data13")!=null&&prop.getProperty("data13").equals("S"),viewMode,false, "observacion", null, "onclick='shouldTypeRadio(true,13)'",""," data-index=13 data-message='Por favor indique las patologías en hijos anteriores.'")%>&nbsp;SI</label>
                
                <%=fb.textarea("observacion13",prop.getProperty("observacion13"),false,false,(viewMode||prop.getProperty("observacion13").equals("")),0,1,2000,"form-control input-sm","",null)%>
                                
              </td>
              
           </tr>
           
           <tr>
              <td colspan="6">
                <b>ANOMAL&Iacute;AS CONGENITAS EN HIJOS ANTERIORES</b><br>
                <label class="pointer"><%=fb.radio("data72","N",prop.getProperty("data72")!=null&&prop.getProperty("data72").equals("N"),viewMode,false, null, null, "onclick='shouldTypeRadio(false,18)'")%>&nbsp;NO</label>
                
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data72","S",prop.getProperty("data72")!=null&&prop.getProperty("data72").equals("S"),viewMode,false, "observacion", null, "onclick='shouldTypeRadio(true,18)'",""," data-index=18 data-message='Por favor indique las anomalías congenistas en hijos anteriores.'")%>&nbsp;SI</label>
                
                <%=fb.textarea("observacion18",prop.getProperty("observacion18"),false,false,(viewMode||prop.getProperty("observacion18").equals("")),0,1,2000,"form-control input-sm","",null)%>
                                
              </td>
              
           </tr>
           
           <tr class="bg-headtabla2">
            <th colspan="6">DATOS DEL PARTO (Anotar cualquier ampliaci&oacute;n en Observaciones precedida por el N&uacute;mero del ITEM)</th>
          </tr>
          
          <tr>
              <td class="controls form-inline">
                <b>1. COMIENZO DEL PARTO</b><br>
                <label class="pointer"><%=fb.radio("data14","E",prop.getProperty("data14")!=null&&prop.getProperty("data14").equals("E"),viewMode,false)%>&nbsp;Espont&aacute;neo</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data14","I",prop.getProperty("data14")!=null&&prop.getProperty("data14").equals("I"),viewMode,false)%>&nbsp;Inducido</label>
              </td>
              
              <td>
                <b><small>2. FORMA TERMINACI&Oacute;N</small></b><br>
                 <%=fb.textBox("data15", prop.getProperty("data15"),false,false,viewMode,5,"form-control input-sm",null,null)%>
              </td>
              
              <td>
                <b>3. HORAS DE LABOR</b><br>
                 <%=fb.textBox("data16", prop.getProperty("data16"),false,false,viewMode,5,"form-control input-sm",null,null)%>
              </td>
              
              <td>
                <b>4. PRESENTACI&Oacute;N</b><br>
                 <%=fb.textBox("data17", prop.getProperty("data17"),false,false,viewMode,5,"form-control input-sm",null,null)%>
              </td>
              
              <td colspan="2">
                <b>5. TIPO L&Iacute;QUIDO AMNI&Oacute;TICO</b><br>
                <label class="pointer"><%=fb.radio("data18","C",prop.getProperty("data18")!=null&&prop.getProperty("data18").equals("C"),viewMode,false,null,null,"","")%>&nbsp;Claro</label>
                <label class="pointer"><%=fb.radio("data18","S",prop.getProperty("data18")!=null&&prop.getProperty("data19").equals("S"),viewMode,false,null,null,"","")%>&nbsp;Sanguinolento</label>
                <label class="pointer"><%=fb.radio("data18","M",prop.getProperty("data18")!=null&&prop.getProperty("data18").equals("M"),viewMode,false,null,null,"","")%>&nbsp;Mecomial</label>
                <label class="pointer"><%=fb.radio("data18","OT",prop.getProperty("data18")!=null&&prop.getProperty("data18").equals("OT"),viewMode,false,null,null,"","")%>&nbsp;Otro</label>
              </td>
           </tr>
           
           
           <tr>
              <td colspan="4">
                  <b>MOTIVOS DE CESAREA</b><br>
                  <%=fb.textarea("observacion14",prop.getProperty("observacion14"),false,false,(viewMode),0,1,2000,"form-control input-sm","",null)%>
              </td>
              
              <td colspan="2">
                <b>7. SIGNOS DE SUFRIMIENTO FETAL</b><br>
                <label class="pointer"><%=fb.radio("data22","S",prop.getProperty("data22")!=null&&prop.getProperty("data22").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data22","N",prop.getProperty("data22")!=null&&prop.getProperty("data22").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label>
                
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data22","I",prop.getProperty("data22")!=null&&prop.getProperty("data22").equals("I"),viewMode,false, null, null, "")%>&nbsp;Ignorado</label>
                <br>
                <b>MONITOREO:</b>                              
                <label class="pointer"><%=fb.radio("data23","S",prop.getProperty("data23")!=null&&prop.getProperty("data23").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data23","N",prop.getProperty("data23")!=null&&prop.getProperty("data23").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label>                
                                
              </td>
           </tr>
           
           <tr>
              <td rowspan="2">
                  <b>6. DROGAS</b><br>
                  <label class="pointer"><%=fb.radio("data24","S",prop.getProperty("data24")!=null&&prop.getProperty("data24").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data24","N",prop.getProperty("data24")!=null&&prop.getProperty("data24").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label>
              </td>
              
              <td colspan="5">
                <b>NOMBRE</b>
                <%=fb.textBox("data25", prop.getProperty("data25"),false,false,viewMode,5,"form-control input-sm",null,null)%>
              </td>
              
           </tr>
           
           <tr>
              <td colspan="5" style="background-color: #eee">
                <b>TIEMPO ANTEPARTO - DOSIS</b>
                <%=fb.textBox("data26", prop.getProperty("data26"),false,false,viewMode,5,"form-control input-sm",null,null)%>
              </td>
           </tr>
           
           <tr>
              <td colspan="3">
                <b>8. ANALISIS DE LA SANGRE DEL CORDÓN</b><br>
                <label class="pointer"><%=fb.radio("data27","N",prop.getProperty("data27")!=null&&prop.getProperty("data27").equals("N"),viewMode,false, null, null, "onclick='shouldTypeRadio(false,15)'")%>&nbsp;NO</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data27","S",prop.getProperty("data27")!=null&&prop.getProperty("data27").equals("S"),viewMode,false, "observacion", null, "onclick='shouldTypeRadio(true,15)'",""," data-index=15 data-message='Por favor indique los análisis solicitados.'")%>&nbsp;SI</label>
                
                <%=fb.textarea("observacion15",prop.getProperty("observacion15"),false,false,(viewMode||prop.getProperty("observacion15").equals("")),0,1,2000,"form-control input-sm","",null)%>           
              </td>

              <td colspan="3">
                <b>9. ECOGRAFÍA</b><br>
                <label class="pointer"><%=fb.radio("data28","N",prop.getProperty("data28")!=null&&prop.getProperty("data28").equals("N"),viewMode,false, null, null, "")%>&nbsp;Normal</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data28","S",prop.getProperty("data28")!=null&&prop.getProperty("data28").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;Anormal</label>
              </td>
           </tr>
           
           <tr>
              <td colspan="6">
              <%
                CommonDataObject cdoBB = SQLMgr.getData("select to_char(fecha_nacimiento, 'dd | mm | yyyy')||'   '||to_char(hora_nacimiento, 'hh12:mi am') fn from tbl_adm_neonato where pac_id = "+pacId);
                if (cdoBB == null) cdoBB = new CommonDataObject();
                %>
                <b>FECHA DE NACIMIENTO:</b>&nbsp;&nbsp;<%=cdoBB.getColValue("fn", " ")%>
              </td>
           </tr>
           
           <tr>
              <td colspan="2">
                <b>10. RECIEN NACIDO ATENDIDO POR</b><br>
                
                <label class="pointer"><%=fb.checkbox("data29","1",prop.getProperty("data29")!=null&&prop.getProperty("data29").equals("1"),viewMode,"",null,"","","")%>&nbsp;Neonat&oacute;logo</label>
                
                <label class="pointer"><%=fb.checkbox("data30","2",prop.getProperty("data30")!=null&&prop.getProperty("data30").equals("2"),viewMode,"",null,"","","")%>&nbsp;Médico general</label>
                
                <label class="pointer"><%=fb.checkbox("data31","3",prop.getProperty("data31")!=null&&prop.getProperty("data31").equals("3"),viewMode,"",null,"","","")%>&nbsp;Pediatra</label><br>
                
                <label class="pointer"><%=fb.checkbox("data32","4",prop.getProperty("data32")!=null&&prop.getProperty("data32").equals("4"),viewMode,"",null,"","","")%>&nbsp;Enfermera obstetra</label>
                
                <label class="pointer"><%=fb.checkbox("data33","5",prop.getProperty("data33")!=null&&prop.getProperty("data33").equals("5"),viewMode,"",null,"","","")%>&nbsp;Médico obstetra</label>
                
                <br>
                <label class="pointer"><%=fb.checkbox("data34","0",prop.getProperty("data34")!=null&&prop.getProperty("data34").equals("0"),viewMode,"observacion should-type",null,"",""," data-index=16 data-message='Por favor indique el otro personal que ha atendido al recien nacido.'")%>&nbsp;Otros</label>
                
                <%=fb.textarea("observacion16",prop.getProperty("observacion16"),false,false,(viewMode||prop.getProperty("observacion16").equals("")),0,1,2000,"form-control input-sm","",null)%>           
              </td>
              
              <td>
                  <b>11. RECIEN NACIDO ATENDIDO EN</b><br>
                  
                  <label class="pointer"><%=fb.checkbox("data35","1",prop.getProperty("data35")!=null&&prop.getProperty("data35").equals("1"),viewMode,"",null,"","","")%>&nbsp;Cuarto de Labor</label><br>
                  <label class="pointer"><%=fb.checkbox("data36","2",prop.getProperty("data36")!=null&&prop.getProperty("data36").equals("2"),viewMode,"",null,"","","")%>&nbsp;Sala de Parto</label><br>
                  
                  <label class="pointer"><%=fb.checkbox("data37","3",prop.getProperty("data37")!=null&&prop.getProperty("data37").equals("3"),viewMode,"",null,"","","")%>&nbsp;Pabellón Quirúrgico</label><br>
                  <label class="pointer"><%=fb.checkbox("data39","5",prop.getProperty("data39")!=null&&prop.getProperty("data39").equals("5"),viewMode,"",null,"","","")%>&nbsp;Ambiente no Quirúrgico</label><br>
                  <label class="pointer"><%=fb.checkbox("data38","4",prop.getProperty("data38")!=null&&prop.getProperty("data38").equals("4"),viewMode,"",null,"","","")%>&nbsp;Fuera de la Institución</label>
              </td>
              
               <td>
                  <b>12. NACIMIENTO</b><br>
                  
                  <label class="pointer"><%=fb.radio("data40","S",prop.getProperty("data40")!=null&&prop.getProperty("data40").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;Simple</label><br>
                <label class="pointer"><%=fb.radio("data40","M",prop.getProperty("data40")!=null&&prop.getProperty("data40").equals("M"),viewMode,false, null, null, "")%>&nbsp;Múltiple</label><br>
                <b>No. de Orden</b>
                <%=fb.textBox("data41", prop.getProperty("data41"),false,false,viewMode,5,"form-control input-sm",null,null)%>
              </td>
              
              <td colspan="2">
                  <b>13. CORDON</b><br>
                  
                  Anomal&iacute;as: &nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.radio("data42","S",prop.getProperty("data42")!=null&&prop.getProperty("data42").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data42","N",prop.getProperty("data42")!=null&&prop.getProperty("data42").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label><br>
                
                Pinzamiento: &nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.radio("data43","S",prop.getProperty("data43")!=null&&prop.getProperty("data43").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;Menos 1 Min.</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data43","N",prop.getProperty("data43")!=null&&prop.getProperty("data43").equals("N"),viewMode,false, null, null, "")%>&nbsp;</label><br>
                
                Pinzamiento: &nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.radio("data44","S",prop.getProperty("data44")!=null&&prop.getProperty("data44").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;Más 1 Min.</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data44","N",prop.getProperty("data44")!=null&&prop.getProperty("data44").equals("N"),viewMode,false, null, null, "")%>&nbsp;</label><br>
                
                Circular: &nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.radio("data45","S",prop.getProperty("data45")!=null&&prop.getProperty("data45").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data45","N",prop.getProperty("data45")!=null&&prop.getProperty("data45").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label><br>
                
                Prolapso: &nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.radio("data46","S",prop.getProperty("data46")!=null&&prop.getProperty("data46").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data46","N",prop.getProperty("data46")!=null&&prop.getProperty("data46").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label><br>
                
                Nudos: &nbsp;&nbsp;&nbsp;
                  <label class="pointer"><%=fb.radio("data47","S",prop.getProperty("data47")!=null&&prop.getProperty("data47").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("data47","N",prop.getProperty("data47")!=null&&prop.getProperty("data47").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label>
                  
              </td>

           </tr>
           
           <tr>
              <td colspan="5">
                <b></b>
              </td>
              
              <td align="center"><b></b></td>
           </tr>
           
           <tr>
              <td colspan="6">
                  <table class="table table-striped table-bordered">
                      <tr>
                        <th colspan="4" rowspan="2">14. PUNTUACION DEL APGAR</th>
                        <th colspan="2" style="text-align: center">MINUTOS</th>
                      </tr>
                      
                      <tr>
                        <td style="text-align: center">1</td>
                        <td style="text-align: center">2</td>
                      </tr>
                      
                      <tr>
                         <td>Frecuencia cardiaca</td>
                         <td>0 Ausente</td>
                         <td>1 Menor de 100</td>
                         <td>2 Menor de 100</td>
                         <td><%=fb.textBox("data48", prop.getProperty("data48"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                         <td><%=fb.textBox("data49", prop.getProperty("data49"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                      </tr>
                      
                      <tr>
                         <td>Esfuerzo Respiratorio</td>
                         <td>0 Ausente</td>
                         <td>1 Irregular, llanto débil</td>
                         <td>2 Regular, llanto fuerte</td>
                         <td><%=fb.textBox("data50", prop.getProperty("data50"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                         <td><%=fb.textBox("data51", prop.getProperty("data51"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                      </tr>
                      
                      
                      <tr>
                         <td>Tono Muscular</td>
                         <td>0 Flácido</td>
                         <td>1 Ligera Flexión de Extremidades</td>
                         <td>2 Extremidades Flexionadas</td>
                         <td><%=fb.textBox("data52", prop.getProperty("data52"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                         <td><%=fb.textBox("data53", prop.getProperty("data53"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                      </tr>
                      
                      <tr>
                         <td>Reacción a Estímulo</td>
                         <td>0 No Respuesta</td>
                         <td>1 Gesticulaciones</td>
                         <td>2 Buena Respuesta</td>
                         <td><%=fb.textBox("data54", prop.getProperty("data54"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                         <td><%=fb.textBox("data55", prop.getProperty("data55"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                      </tr>
                      
                      <tr>
                         <td>Color</td>
                         <td>0 Azul o Pálido</td>
                         <td>1 Extremidades Cianóticas</td>
                         <td>2 Rosado</td>
                         <td><%=fb.textBox("data56", prop.getProperty("data56"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                         <td><%=fb.textBox("data57", prop.getProperty("data57"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                      </tr>
                      
                      
                      <tr>
                         <td colspan="4" class="control form-inline">
                            si está deprimido al 5to minuto, anotar el tiempo en que se logra Apgar 7
                            <%=fb.textBox("data58", prop.getProperty("data58"),false,false,viewMode,5,"form-control input-sm",null,null)%> Minutos
                         </td>
                         
                         
                         
                         <td><%=fb.textBox("data59", prop.getProperty("data59"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                         <td><%=fb.textBox("data60", prop.getProperty("data60"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                      </tr>
                      
                      <tr>
                        <td colspan="6"><b>15. MANIOBRAS DE RUTINA</b></td>
                      </tr>
                      
                      <tr>
                        
                        <td>
                          <b>CALOR</b><br>
                          <label class="pointer"><%=fb.radio("data61","S",prop.getProperty("data61")!=null&&prop.getProperty("data61").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                          &nbsp;&nbsp;&nbsp;
                          <label class="pointer"><%=fb.radio("data61","N",prop.getProperty("data61")!=null&&prop.getProperty("data61").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label><br>
                        </td>
                        
                        <td>
                          <b>SECADO</b><br>
                          <label class="pointer"><%=fb.radio("data62","S",prop.getProperty("data62")!=null&&prop.getProperty("data62").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                          &nbsp;&nbsp;&nbsp;
                          <label class="pointer"><%=fb.radio("data62","N",prop.getProperty("data62")!=null&&prop.getProperty("data62").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label><br>
                        </td>
                        
                        <td>
                          <b>ASPIRACION NASOFAR&Iacute;NGEA</b><br>
                          <label class="pointer"><%=fb.radio("data63","S",prop.getProperty("data63")!=null&&prop.getProperty("data63").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                          &nbsp;&nbsp;&nbsp;
                          <label class="pointer"><%=fb.radio("data63","N",prop.getProperty("data63")!=null&&prop.getProperty("data63").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label><br>
                        </td>
                        
                        <td colspan="3">
                          <b>ASPIRACION GASTRICA</b><br>
                          <label class="pointer"><%=fb.radio("data64","S",prop.getProperty("data64")!=null&&prop.getProperty("data64").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>
                          &nbsp;&nbsp;&nbsp;
                          <label class="pointer"><%=fb.radio("data64","N",prop.getProperty("data64")!=null&&prop.getProperty("data64").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label><br>
                        </td>
                      
                      </tr>
                      
                      <tr>
                        <td colspan="6"><b>16. MANIOBRAS ESPECIALES DE REANIMACION</b></td>
                      </tr>
                      
                      <tr>
                        <td>
                          <b>REANIMACION</b><br>
                          <label class="pointer"><%=fb.radio("data65","1",prop.getProperty("data65")!=null&&prop.getProperty("data65").equals("1"),viewMode,false, "", null, "","","")%>&nbsp;No se hizo</label>
                          &nbsp;&nbsp;&nbsp;
                          <label class="pointer"><%=fb.radio("data65","2",prop.getProperty("data65")!=null&&prop.getProperty("data65").equals("2"),viewMode,false, null, null, "")%>&nbsp;Máscara Presión Positiva</label><br>
                          
                          <label class="pointer"><%=fb.radio("data65","3",prop.getProperty("data65")!=null&&prop.getProperty("data65").equals("3"),viewMode,false, null, null, "")%>&nbsp;Máscara Simple</label>
                          <label class="pointer"><%=fb.radio("data65","4",prop.getProperty("data65")!=null&&prop.getProperty("data65").equals("4"),viewMode,false, null, null, "")%>&nbsp;Intubación</label>
                        </td>
                        
                        <td>
                          <b>CARDIACA</b><br>
                          <label class="pointer"><%=fb.radio("data66","1",prop.getProperty("data66")!=null&&prop.getProperty("data66").equals("1"),viewMode,false, "", null, "","","")%>&nbsp;No se hizo</label><br>
                          <label class="pointer"><%=fb.radio("data66","2",prop.getProperty("data66")!=null&&prop.getProperty("data66").equals("2"),viewMode,false, null, null, "")%>&nbsp;Masaje externo</label><br>
                          <label class="pointer"><%=fb.radio("data66","3",prop.getProperty("data66")!=null&&prop.getProperty("data66").equals("3"),viewMode,false, null, null, "")%>&nbsp;Drogas</label>
                        </td>
                        
                        <td>
                          <b>METABOLICA</b><br>
                          <label class="pointer"><%=fb.radio("data67","1",prop.getProperty("data67")!=null&&prop.getProperty("data67").equals("1"),viewMode,false, "", null, "","","")%>&nbsp;No se hizo</label><br>
                          <label class="pointer"><%=fb.radio("data67","2",prop.getProperty("data67")!=null&&prop.getProperty("data67").equals("2"),viewMode,false, null, null, "")%>&nbsp;Alcalinizantes</label><br>
                          <label class="pointer"><%=fb.radio("data67","3",prop.getProperty("data67")!=null&&prop.getProperty("data67").equals("3"),viewMode,false, null, null, "")%>&nbsp;Otros</label>
                        </td>
                        
                        <td>
                          <b>ESTIMACION EXTERNA</b><br>
                          <label class="pointer"><%=fb.radio("data68","S",prop.getProperty("data68")!=null&&prop.getProperty("data68").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;
                          <label class="pointer"><%=fb.radio("data68","N",prop.getProperty("data68")!=null&&prop.getProperty("data68").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label>
                        </td>
                        
                        <td colspan="2">
                          <b>OTRAS</b><br>
                          <label class="pointer"><%=fb.radio("data69","S",prop.getProperty("data69")!=null&&prop.getProperty("data69").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;
                          <label class="pointer"><%=fb.radio("data69","N",prop.getProperty("data69")!=null&&prop.getProperty("data69").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label>
                        </td>
                      </tr>
                      
                      <tr>
                          <td>
                            <b>17. PROFILAXIS OFTALMICA</b><br>
                            <label class="pointer"><%=fb.radio("data70","S",prop.getProperty("data70")!=null&&prop.getProperty("data70").equals("S"),viewMode,false, "", null, "","","")%>&nbsp;SI</label>&nbsp;&nbsp;&nbsp;
                            <label class="pointer"><%=fb.radio("data70","N",prop.getProperty("data70")!=null&&prop.getProperty("data70").equals("N"),viewMode,false, null, null, "")%>&nbsp;NO</label>
                          </td>
                          
                          <td colspan="5">
                              <b>18. PLACENTA</b><br>
                              <label class="pointer"><%=fb.radio("data71","N",prop.getProperty("data71")!=null&&prop.getProperty("data71").equals("N"),viewMode,false, "", null, "onclick='shouldTypeRadio(false,17)'","","")%>&nbsp;Normal</label>&nbsp;&nbsp;&nbsp;
                              <label class="pointer"><%=fb.radio("data71","A",prop.getProperty("data71")!=null&&prop.getProperty("data71").equals("A"),viewMode,false, "observacion", null, "onclick='shouldTypeRadio(true,17)'",""," data-index=17 data-message='Por favor indique las anomalías de la placenta.'")%>&nbsp;Anormal</label>
                            
                              <%=fb.textarea("observacion17",prop.getProperty("observacion17"),false,false,(viewMode||prop.getProperty("observacion17").equals("")),0,1,2000,"form-control input-sm","",null)%>
                          </td>
                      </tr>
                      
                      <tr>
                        <td colspan="6">
                        <label for="observacionx" class="form-label"><b>Observaci&oacute;n</b></label>  
                        <%=fb.textarea("observacionx",prop.getProperty("observacionx"),false,false,viewMode,0,2,2000,"form-control input-sm","",null)%>
                        </td>
                      </tr>
                    
                      
                      
                  </table>
              </td>
           </tr>
           
           
           
          
          
           
        </tbody>
        </table>

    <div class="footerform">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
            <%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>
            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
        </tr>
    </table> </div> 
<%=fb.formEnd(true)%>
 
 </div>
 </div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	prop = new Properties();
	
	CommonDataObject param = new CommonDataObject();
	param.setTableName("tbl_sal_hist_cli_neonatal");
  
  String errCode = "1";
	String errMsg = "";
	String errException = "";
    
  for ( int o = 1; o <= 100; o++ ){
      if(request.getParameter("data"+o) != null && !request.getParameter("data"+o).trim().equals("") ) prop.setProperty("data"+o, request.getParameter("data"+o));
      if (request.getParameter("observacion"+o) != null && !request.getParameter("observacion"+o).trim().equals("")) prop.setProperty("observacion"+o, request.getParameter("observacion"+o));
  }
  
  prop.setProperty("observacionx", request.getParameter("observacionx"));
  
  if (modeSec.trim().equalsIgnoreCase("edit")) {
       prop.setProperty("usuario_modificacion", (String) session.getAttribute("_userName"));
       prop.setProperty("fecha_modificacion", cDateTime);
       
        param.setSql("update tbl_sal_hist_cli_neonatal set hist = ?, usuario_modificacion = ?, fecha_modificacion = sysdate where pac_id = ? and admision = ? and codigo = ?");
				param.addInBinaryStmtParam(1,prop);
				param.addInStringStmtParam(2,(String)session.getAttribute("_userName"));
				param.addInNumberStmtParam(3,request.getParameter("pacId")); 
				param.addInNumberStmtParam(4,request.getParameter("noAdmision"));
				param.addInNumberStmtParam(5,request.getParameter("codigo"));
  } else {

        prop.setProperty("pac_id",request.getParameter("pacId"));
        prop.setProperty("admision",request.getParameter("noAdmision"));
        prop.setProperty("usuario_creacion", (String) session.getAttribute("_userName"));
        prop.setProperty("fecha_creacion", cDateTime);
	  
        param.setSql("insert into tbl_sal_hist_cli_neonatal (pac_id, admision, hist, usuario_creacion, fecha_creacion, codigo) values (?, ?, ?, ?, sysdate, (select nvl(max(codigo),0)+1 from tbl_sal_hist_cli_neonatal where pac_id = ? and admision = ? ) )");
				param.addInNumberStmtParam(1,request.getParameter("pacId")); 
				param.addInNumberStmtParam(2,request.getParameter("noAdmision")); 
				param.addInBinaryStmtParam(3,prop);
				param.addInStringStmtParam(4,(String)session.getAttribute("_userName"));
				param.addInNumberStmtParam(5,request.getParameter("pacId")); 
				param.addInNumberStmtParam(6,request.getParameter("noAdmision")); 
  }

	if (baction.equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
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
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&from=<%=from%>&codigo=<%=codigo%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>