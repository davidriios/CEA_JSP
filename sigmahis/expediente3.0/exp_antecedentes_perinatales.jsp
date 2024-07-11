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
<jsp:useBean id="ANTPERIMgr" scope="page" class="issi.expediente.AntecedentesPerinatalesMgr" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ANTPERIMgr.setConnection(ConMgr);

Properties prop = new Properties();
ArrayList al = new ArrayList();

boolean viewMode = false;
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (fg == null) fg = "NDE";
if (id == null) id = "0";
if (from == null) from = "";

if ( desc == null ) desc = "";
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

CommonDataObject cdo = new CommonDataObject();

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	prop = SQLMgr.getDataProperties("select antecedentes from tbl_sal_ant_perinatales where pac_id="+pacId+" and admision = "+noAdmision);
	if (prop == null){
		prop = new Properties();
		prop.setProperty("fecha",cDateTime);
	}
	else {
      if(!viewMode) {
        modeSec = "view";
        viewMode = true;
      }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
var noNewHeight = true;
document.title = 'Notas de Diarias de Enfermeria - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}

function canSubmit() {
  var proceed = true;
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    if ( $self.is(":checked") && !$("#observacion"+i).prop("readOnly") && !$.trim($("#observacion"+i).val())) {
      parent.parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
      proceed = false;
      $self.focus();
      return false;  
    }else  {proceed = true;}
  });
  
  if ( parseInt($("#observacion7").val() || '0') < 7 && !$.trim($("#observacion8").val())){
    proceed = false;
    parent.parent.CBMSG.error('Por favor indique el valor del APGAR!');
    return false;
  }

  return proceed;
}

$(function(){
    
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

function shouldTypeRadio(check, textareaIndex) {
  if (check == true) $("#observacion"+textareaIndex).prop("readOnly", false)
  else $("#observacion"+textareaIndex).val("").prop("readOnly", true)
}

function imprimir(){
    var condicionTitle = $("#condicion").selText();
    abrir_ventana('../expediente3.0/print_antecedentes_perinatales.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>');
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
<%=fb.hidden("id",id)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("should_type_radio_tmp", "")%>

<div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-2">
    <tr>
        <td align="right">
        <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir()"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
    </tr>
    </table>
</div>

<table cellspacing="0" class="table table-small-font table-bordered">
     <tbody>
     <tr>
        <th class="bg-headtabla">DATOS MATERNOS DEL PACIENTE PEDIÁTRICO</th>
     </tr>
    </tbody>

    <tr>
        <td class="controls form-inline">
            G-Grava:<%=fb.textBox("observacion11",prop.getProperty("observacion11"),false,false,viewMode,5,"form-control input-sm",null,null)%>&nbsp;&nbsp;
            P-Para:<%=fb.textBox("observacion12",prop.getProperty("observacion12"),false,false,viewMode,5,"form-control input-sm",null,null)%>&nbsp;&nbsp;
            C-Cesarea:<%=fb.textBox("observacion13",prop.getProperty("observacion13"),false,false,viewMode,5,"form-control input-sm",null,null)%>&nbsp;&nbsp;
            A-Aborto:<%=fb.textBox("observacion14",prop.getProperty("observacion14"),false,false,viewMode,5,"form-control input-sm",null,null)%>&nbsp;&nbsp;
         </td>
    </tr>
    
     <tr>
        <th class="bg-headtabla">DATOS DEL NACIMIENTO DEL PACIENTE PEDIATRICO</th>
     </tr>
    
        <tr>
            <td>
                <table cellspacing="0" width="100%" class="table-small-font table-bordered table-hover">
                
                  <tbody>
                    <tr>
                      <td width="25%">
                        <label class="pointer">Parto Vaginal&nbsp;<%=fb.radio("parto","PV",prop.getProperty("parto")!=null&&prop.getProperty("parto").equalsIgnoreCase("PV"),viewMode,false,"",null,"onClick='shouldTypeRadio(true, 0);shouldTypeRadio(false, 1)'",""," data-index=0 data-message='Por favor detallar el parto vaginal'")%></label>
                      </td>
                      <td width="75%">
                        <%=fb.textarea("observacion0",prop.getProperty("observacion0"),false,false,(viewMode||prop.getProperty("observacion0").equals("")),0,1,0,"form-control input-sm","",null)%>
                      </td>
                    </tr>
                  </tbody>
                  
                  <tbody>
                    <tr>
                      <td>
                        <label class="pointer">Cesárea&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.radio("parto","PC",prop.getProperty("parto")!=null&&prop.getProperty("parto").equalsIgnoreCase("PC"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(true, 1);shouldTypeRadio(false, 0)'",""," data-index=1 data-message='Por favor detallar la Cesárea!'")%></label>
                      </td>
                      <td>
                        <%=fb.textarea("observacion1",prop.getProperty("observacion1"),false,false,(viewMode||prop.getProperty("observacion1").equals("")),0,1,0,"form-control input-sm","",null)%>
                      </td>
                    </tr>
                  </tbody>
                  
                  <tbody>
                    <tr>
                      <td>Edad Gestacional al nacer (semanas)</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion21",prop.getProperty("observacion21"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                    </tr>
                  </tbody>
                  
                <tbody>
                    <tr>
                      <td>Peso al nacer</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion2",prop.getProperty("observacion2"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                       </tr>
                  </tbody>
                  
                <tbody>
                    <tr>
                      <td>Talla al nacer</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion3",prop.getProperty("observacion3"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                       </tr>
                  </tbody>
                  
                <tbody>
                    <tr>
                      <td>Perímetro cefálico</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion4",prop.getProperty("observacion4"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>
                       </tr>
                  </tbody>
                  
                <tbody>
                    <tr>
                      <td>Perímetro torácico</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion5",prop.getProperty("observacion5"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>     </tr>
                  </tbody>
                  
                <tbody>
                    <tr>
                      <td>Condición al nacer</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion6",prop.getProperty("observacion6"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>     </tr>
                  </tbody>
                  
                  <tbody>
                    <tr>
                      <td>APGAR</td>
                      <td class="controls form-inline">
                        <%=fb.textBox("observacion7",prop.getProperty("observacion7"),false,false,viewMode,5,"form-control input-sm",null,null)%>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                Detallar:&nbsp;
                <%=fb.textarea("observacion8",prop.getProperty("observacion8"),false,false,(viewMode),0,1,0,"form-control input-sm","width:50%",null)%>
                      </td>     
                     </tr>
                  </tbody>

                </table>
                </td>
        </tr>
        
         <tr>
         <td>

                <b>Reanimado:</b><br><br>
                
                <label class="pointer"><%=fb.radio("reanimado","0",prop.getProperty("reanimado")!=null&&prop.getProperty("reanimado").equalsIgnoreCase("0"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(false, 9)'",""," data-index=9")%>&nbsp;No requiere</label><br>
                <label class="pointer"><%=fb.radio("reanimado","1",prop.getProperty("reanimado")!=null&&prop.getProperty("reanimado").equalsIgnoreCase("1"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(false, 9)'",""," data-index=9")%>&nbsp;Máscara simple</label><br>
                <label class="pointer"><%=fb.radio("reanimado","2",prop.getProperty("reanimado")!=null&&prop.getProperty("reanimado").equalsIgnoreCase("2"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(false, 9)'",""," data-index=9")%>&nbsp;Máscara de Presión Positiva&nbsp;</label><br>
                <label class="pointer"><%=fb.radio("reanimado","3",prop.getProperty("reanimado")!=null&&prop.getProperty("reanimado").equalsIgnoreCase("3"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(false, 9)'",""," data-index=9")%>&nbsp;Intubación endotraqueal&nbsp;</label><br>
                <label class="pointer"><%=fb.radio("reanimado","4",prop.getProperty("reanimado")!=null&&prop.getProperty("reanimado").equalsIgnoreCase("4"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(false, 9)'",""," data-index=9")%>&nbsp;CPAP&nbsp;</label><br>

                 <label class="pointer"><%=fb.radio("reanimado","OT",prop.getProperty("reanimado")!=null&&prop.getProperty("reanimado").equalsIgnoreCase("OT"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(true, 9)'",""," data-index=9 data-message='Por favor indicar las otras reanimaciones!'")%>&nbsp;Otros&nbsp;</label>
                 &nbsp;&nbsp;
                 <%=fb.textarea("observacion9",prop.getProperty("observacion9"),false,false,(viewMode||prop.getProperty("observacion9").equals("")),0,1,0,"form-control input-sm observacion","width:50%",null)%>
                 <br><br>
                  <b>Complicaciones al nacer:</b><br><br>
                  
                  <label class="pointer"><%=fb.radio("complicaion","0",prop.getProperty("complicaion")!=null&&prop.getProperty("complicaion").equalsIgnoreCase("0"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(false, 10)'",""," data-index=10")%>&nbsp;Ninguna&nbsp;</label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <label class="pointer"><%=fb.radio("complicaion","1",prop.getProperty("complicaion")!=null&&prop.getProperty("complicaion").equalsIgnoreCase("1"),viewMode,false,"observacion",null,"onClick='shouldTypeRadio(true, 10)'",""," data-index=10 data-message='Por favor detallar las complicaiones!'")%>&nbsp;SI&nbsp;</label>
                <%=fb.textarea("observacion10",prop.getProperty("observacion10"),false,false,(viewMode||prop.getProperty("observacion10").equals("")),0,1,0,"form-control input-sm","",null)%></td>
        </tr>
  
     <tr>
        <th class="bg-headtabla">DATOS DEL DESARROLLO DEL PACIENTE PEDIATRICO</th>
     </tr>
     
     <%
       if (viewMode) viewMode = false;
     %>
     
     <tr>
         <td>
            <table cellspacing="0" width="100%" class="table-small-font table-bordered table-hover">
            <tbody>
                    <tr>
                      <td width="20%">Sostén Cefálico (meses)</td>
                      <td width="80%" class="controls form-inline"><%=fb.textBox("observacion15",prop.getProperty("observacion15"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>     
                     </tr>
                  </tbody>
            <tbody>
                    <tr>
                      <td>Primer Diente (meses)</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion16",prop.getProperty("observacion16"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>     
                     </tr>
                  </tbody>
            <tbody>
                    <tr>
                      <td>Se sentó (meses)</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion17",prop.getProperty("observacion17"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>     
                     </tr>
                  </tbody>
            <tbody>
                    <tr>
                      <td>Primeras Palabras (meses)</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion18",prop.getProperty("observacion18"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>     
                     </tr>
                  </tbody>
            <tbody>
                    <tr>
                      <td>Caminó (meses)</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion19",prop.getProperty("observacion19"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>     
                     </tr>
                  </tbody>
            <tbody>
                    <tr>
                      <td>Control de esfínteres(meses)</td>
                      <td class="controls form-inline"><%=fb.textBox("observacion20",prop.getProperty("observacion20"),false,false,viewMode,5,"form-control input-sm",null,null)%></td>     
                     </tr>
                  </tbody>
            </table>
        </td>
     </tr>
     
      <tr>
        <th class="bg-headtabla">ALIMENTACI&Oacute;N</th>
     </tr>

     <tr>
         <td>
            <label class="pointer"><%=fb.radio("pecho","0",prop.getProperty("pecho")!=null&&prop.getProperty("pecho").equalsIgnoreCase("0"),viewMode,false,"observacionn",null,"","","")%>&nbsp;Pecho&nbsp;</label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer"><%=fb.radio("pecho","1",prop.getProperty("pecho")!=null&&prop.getProperty("pecho").equalsIgnoreCase("1"),viewMode,false,"observacionn",null,"","","")%>&nbsp;Pecho + F&oacute;rmula&nbsp;</label>
            <br>
            Alimentos suaves:
            <%=fb.textarea("observacion22",prop.getProperty("observacion22"),false,false,(viewMode),0,1,0,"form-control input-sm","",null)%>
            <br>
            Dieta actual:
            <%=fb.textarea("observacion23",prop.getProperty("observacion23"),false,false,(viewMode),0,1,0,"form-control input-sm","",null)%>
         </td>
     </tr>
  
    
    
  </table>  

<%
fb.appendJsValidation("if(error>0)doAction();");
%>
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

	prop.setProperty("pac_id",request.getParameter("pacId"));
	prop.setProperty("admision",request.getParameter("noAdmision"));
	prop.setProperty("parto",request.getParameter("parto"));
	prop.setProperty("reanimado",request.getParameter("reanimado"));
	prop.setProperty("complicaion",request.getParameter("complicaion"));
	prop.setProperty("pecho",request.getParameter("pecho"));

    if (modeSec.equalsIgnoreCase("edit")) {
        prop.setProperty("usuario_modificacion", UserDet.getUserName());
        prop.setProperty("fecha_modificacion",cDateTime);
    } else {
        prop.setProperty("fecha_creacion",cDateTime);
        prop.setProperty("usuario_creacion", UserDet.getUserName());
    }
 
   for (int i = 0; i < 30; i++) {
     if (request.getParameter("observacion"+i) != null) prop.setProperty("observacion"+i,request.getParameter("observacion"+i));
   }
    

	if (baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")){
		 	ANTPERIMgr.add(prop);
		}
		else ANTPERIMgr.update(prop);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ANTPERIMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ANTPERIMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
<%
	}
	else
	{
%>
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
} else throw new Exception(ANTPERIMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&id=<%=id%>&desc=<%=desc%>&from=<%=from%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>