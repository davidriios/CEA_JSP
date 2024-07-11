<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<%
/**
===============================================================================
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alapgar = new ArrayList();
ArrayList alCordon = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cds = request.getParameter("cds");
float eTotal1 = 0.0f, eTotal5 = 0.0f;
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (cds == null) cds = "";

String tab = request.getParameter("tab");
String cod_apgar= request.getParameter("cod_apgar");
String cDate="";
String cTime="";
String rouspan="";
int eTotal=0;
int aTotal=0;
boolean checkDefault = false;
if (tab == null) tab = "0";

String codigoHdr = request.getParameter("codigo_hdr_cordon");
if (codigoHdr == null) codigoHdr = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select fecha_nacimiento, codigo_paciente, secuencia, rn_apgar7, rn_calor as calor, rn_secado as secado, rn_asp_nasofar as aspNaso, rn_asp_gast as aspGast, rn_man_esp_rean as reAnimacion, rn_rean_card as cardiaca, rn_metabol as metabolica, rn_estim_ext as estimulacion, rn_estim_ext_otras as otras, rn_talla as talla, rn_peso as peso, rn_edad_gest_ex_fis as edad, rn_dif_resp as difResp, rn_cp_ictericia as piel, rn_cp_palidez as palidez, rn_cp_cianosis as cianosis, rn_malforma as malForm, rn_neuro as neuro, rn_abdomen as abdomen, rn_orino as orino, rn_exp_meco as meconio, rn_cardio as cardio, pac_id, nvl(to_char(dn_fecha_nacimiento,'dd/mm/yyyy'),' ') as dnFechaNac, nvl(to_char(dn_hora_nacimiento,'hh12:mi:ss am'),' ') as dnHoraNac, nvl(dn_sexo,' ') as dnSexo, perm_ano, perm_coanas, perm_esofago, lesiones, lesiones_obs, tiempo_de_vida, pc, lugar_permanencia_neo, eval_riesgo from tbl_sal_serv_neonatologia where pac_id="+pacId+" and secuencia="+noAdmision;
	cdo = SQLMgr.getData(sql);
	if (cdo == null)
	{
		if (!viewMode) mode = "add";
		cdo = new CommonDataObject();
		//cdo.addColValue("FUM","");
		cdo.addColValue("PAC_ID","0");
		cdo.addColValue("SECUENCIA","0");
		cdo.addColValue("CODIGO_PACIENTE","0");
		cdo.addColValue("dnFechaNac","");
		cdo.addColValue("dnHoraNac","");
	}
	else if (!viewMode) modeSec = "edit";
    
    String active0 = "", active1 = "";
    
    if (tab.equals("0")) active0 = "active";
    else if (tab.equals("1")) active1 = "active";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<%@ include file="../common/tab.jsp" %>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - EXAMEN FISICO RECIEN NACIDO'+document.title;
function doAction(){calcTotal();}
function focusField(k,x){eval('document.form0.eval'+k).value=x;var cod_apgar=eval('document.form0.cod_apgar'+k).value;var opt=eval('document.form0.valor'+cod_apgar);for(i=0;i<opt.length;i++)opt[i].checked=false;}
function setPto(k,pto){var x=eval('document.form0.eval'+k).value;eval('document.form0.minuto'+x+k).value=pto;calcTotal();}
function calcTotal(){var size=parseInt(document.form0.size.value,10);var total1=0.0;var total5=0.0;for(i=0;i<=size;i++){if(eval('document.form0.minuto1'+i).value.trim()!='')total1+=parseFloat(eval('document.form0.minuto1'+i).value);if(eval('document.form0.minuto5'+i).value.trim()!='')total5+=parseFloat(eval('document.form0.minuto5'+i).value);}document.form0.total1.value=total1;document.form0.total5.value=total5;}
function printExp(){abrir_ventana("../expediente3.0/print_examen_fisico_rn.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&codigo_hdr_cordon=<%=codigoHdr%>");}

$(function(){
    $("input:checkbox[name*='respuesta']").click(function(e){
        var evalCordon = $("input:radio:checked[name='eval_cordon']").val();
        if (evalCordon == 'S'){
            var $self = $(this);
            var i = $self.data('i');
            var action = $("#action"+i).val();
            if (!$self.is(":checked")) {
                if(action == 'U') $("#delete"+i).val("Y");
            } else $("#delete"+i).val("");
        }
        else {
            e.preventDefault();
            return false;
        }
    });
    
    $("input:radio[name='eval_cordon']").click(function(){
        if (this.checked && this.value == 'N') $("input:checkbox[name*='respuesta']").prop("checked", false);
    });
    
    $("input:radio[name='lesiones']").click(function(){
        if (this.checked && this.value == 'S') $("#lesiones_obs").prop("readOnly", false)
        else $("#lesiones_obs").prop("readOnly", true).val("")
    });
});

</script>
</head>

<body class="body-form" topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-2">
        <tr>
            <td class="controls form-inline">
                <!--<button type="button" class="btn btn-inverse btn-sm" onclick="printExp()">
                    <i class="fa fa-print fa-printico"></i> <b>Imprimir</b>
                </button>-->
            </td>
        </tr>
    </table>
</div>

<ul class="nav nav-tabs" role="tablist">
    <li role="presentation" class="<%=active0%>">
        <a href="#examen_fisico_inmediato" aria-controls="examen_fisico_inmediato" role="tab" data-toggle="tab"><b>Examen F&iacute;sico Inmediato</b></a>
    </li>
</ul> 

<!-- Tab panes -->
<div class="tab-content">

    <!-- Examen fisico inmediato -->
    <div role="tabpanel" class="tab-pane <%=active0%>" id="examen_fisico_inmediato">
        <%fb = new FormBean2("form3",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
        <%=fb.hidden("tab","0")%>
        <%=fb.hidden("sizeCordon",""+alCordon.size())%>
        <%=fb.hidden("desc",desc)%>
        <%=fb.hidden("codigo_hdr_cordon",codigoHdr)%>
        
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
            <tr class="TextRow01">
			<td colspan="4">
				<table width="100%" cellpadding="1" cellspacing="1" class="table table-small-font table-bordered table-striped" style="margin-bottom:0px !important">
					<tr class="bg-headtabla" align="center">
					<td><cellbytelabel id="37">Tiempo de Vida</cellbytelabel></td>
					<td><cellbytelabel id="38">Peso (GM)</cellbytelabel></td>
					<td><cellbytelabel id="37">Talla (CM)</cellbytelabel></td>
					<td><cellbytelabel id="37">PC (CM)</cellbytelabel></td>
					<td><cellbytelabel id="39">Edad Gest. por Examen F&iacute;sico</cellbytelabel></td>
					<td><cellbytelabel id="40">Dificultad Respiratoria</cellbytelabel></td>
				</tr>
				<tr class="TextRow01" align="center">
					<td><%=fb.textBox("tiempo_de_vida",cdo.getColValue("tiempo_de_vida"),false,false,viewMode,15,15,"form-control input-sm",null,null)%></td>
					<td><%=fb.textBox("peso",cdo.getColValue("peso"),false,false,viewMode,15,15,"form-control input-sm",null,null)%></td>
					<td><%=fb.textBox("talla",cdo.getColValue("talla"),false,false,viewMode,15,15,"form-control input-sm",null,null)%></td>
					<td><%=fb.textBox("pc",cdo.getColValue("pc"),false,false,viewMode,15,15,"form-control input-sm",null,null)%></td>
					<td class="controls form-inline"><cellbytelabel id="41">Semanas</cellbytelabel>:&nbsp;<%=fb.intBox("edad",cdo.getColValue("edad"),false,false,viewMode,5,2,"form-control input-sm",null,null)%></td>
					<td>
						<label class="pointer">
                        <%=fb.radio("difResp","S",((cdo.getColValue("difResp")!=null && cdo.getColValue("difResp").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel></label>
                        &nbsp;&nbsp;
                        <label class="pointer">
						<%=fb.radio("difResp","N",((cdo.getColValue("difResp")!=null && cdo.getColValue("difResp").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel></label>
					</td>
				</tr>
				</table>
			</td>
		</tr>
        
        
		<tr class="TextRow01">
			<td colspan="4">
				<table width="100%" cellpadding="1" cellspacing="1" class="table table-small-font table-bordered table-striped" style="margin-bottom:0px !important">
				<tr class="bg-headtabla" align="center">
					<td width="25%"><cellbytelabel id="42">Color de la Piel Ictericia</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="43">Palidez</cellbytelabel></td>
					<td width="18%"><cellbytelabel id="44">Cianosis</cellbytelabel></td>
					<td width="20%"><cellbytelabel id="45">Malformaciones</cellbytelabel></td>
					<td width="22%"><cellbytelabel id="46">Neurologico</cellbytelabel></td>
				</tr>
				<tr class="TextRow01" align="center">
					<td>
						<label class="pointer">
                        <%=fb.radio("piel","S",((cdo.getColValue("piel")!=null && cdo.getColValue("piel").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel></label>
						<label class="pointer">
                        <%=fb.radio("piel","N",((cdo.getColValue("piel")!=null && cdo.getColValue("piel").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel></label>
					</td>
					<td>
						<label class="pointer">
                        <%=fb.radio("palidez","S",((cdo.getColValue("palidez")!=null && cdo.getColValue("palidez").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel></label>
						<label class="pointer">
                        <%=fb.radio("palidez","N",((cdo.getColValue("palidez")!=null && cdo.getColValue("palidez").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel></label>
					</td>
					<td>
						<label class="pointer">
                        <%=fb.radio("cianosis","S",((cdo.getColValue("cianosis")!= null && cdo.getColValue("cianosis").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel></label>
						<label class="pointer">
                        <%=fb.radio("cianosis","N",((cdo.getColValue("cianosis")!=null && cdo.getColValue("cianosis").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel></label>
					</td>
					<td>
						<label class="pointer">
                        <%=fb.radio("malform","S",((cdo.getColValue("malform")!=null && cdo.getColValue("malform").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel></label>
						<label class="pointer">
                        <%=fb.radio("malform","N",((cdo.getColValue("malform")!=null && cdo.getColValue("malform").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel></label>
					</td>
					<td align="left">
						<label class="pointer">
                        <%=fb.radio("neuro","N",((cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="47">Normal</cellbytelabel></label><br>
						<label class="pointer">
                        <%=fb.radio("neuro","D",((cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("D"))?true:false),viewMode,false)%><cellbytelabel id="48">Deprimido</cellbytelabel></label><br>
						<label class="pointer">
                        <%=fb.radio("neuro","E",((cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("E"))?true:false),viewMode,false)%><cellbytelabel id="49">Excitado</cellbytelabel></label>
					</td>
				</tr>
				</table>
			</td>
		</tr>
        
        <tr class="TextRow01">
			<td colspan="4">
				<table width="100%" class="table table-small-font table-bordered table-striped" style="margin-bottom:0px !important">
				<tr class="bg-headtabla" align="center">
					<td width="25%"><cellbytelabel id="50">Abdomen</cellbytelabel></td>
					<td width="25%"><cellbytelabel id="51">Orin&oacute;</cellbytelabel></td>
					<td width="25%"><cellbytelabel id="52">Expulso Meconio</cellbytelabel></td>
					<td width="25%"><cellbytelabel id="53">Cardiovascular</cellbytelabel></td>
				</tr>
				<tr class="TextRow01" align="center">
					<td>
						<%=fb.radio("abdomen","N",((cdo.getColValue("abdomen")!=null && cdo.getColValue("abdomen").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="47">Normal</cellbytelabel>
						<%=fb.radio("abdomen","A",((cdo.getColValue("abdomen")!=null && cdo.getColValue("abdomen").equals("A"))?true:false),viewMode,false)%><cellbytelabel id="54">Anormal</cellbytelabel>
					</td>
					<td>
						<%=fb.radio("orino","S",((cdo.getColValue("orino")!=null && cdo.getColValue("orino").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel>
						<%=fb.radio("orino","N",((cdo.getColValue("orino")!=null && cdo.getColValue("orino").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel>
					</td>
					<td>
						<%=fb.radio("meconio","S",((cdo.getColValue("meconio")!=null && cdo.getColValue("meconio").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="31">S&iacute;</cellbytelabel>
						<%=fb.radio("meconio","N",((cdo.getColValue("meconio")!=null && cdo.getColValue("meconio").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="23">No</cellbytelabel>
					</td>
					<td colspan="2">
						<%=fb.radio("cardio","S",((cdo.getColValue("cardio")!=null && cdo.getColValue("cardio").equals("S"))?true:false),viewMode,false)%><cellbytelabel id="47">Normal</cellbytelabel>
						<%=fb.radio("cardio","N",((cdo.getColValue("cardio")!= null && cdo.getColValue("cardio").equals("N"))?true:false),viewMode,false)%><cellbytelabel id="54">Anormal</cellbytelabel>
					</td>
				</tr>
                
        <tr>
            <td colspan="4">
                <b>LESIONES:</b>&nbsp;&nbsp;&nbsp;
                <label class="pointer">
                <%=fb.radio("lesiones","S",((cdo.getColValue("lesiones")!=null && cdo.getColValue("lesiones").equals("S"))?true:false),viewMode,false)%>
                &nbsp;<cellbytelabel id="47">SI</cellbytelabel></label>
                &nbsp;&nbsp;&nbsp;
                <label class="pointer">
                <%=fb.radio("lesiones","N",((cdo.getColValue("lesiones")!= null && cdo.getColValue("lesiones").equals("N"))?true:false),viewMode,false)%>
                &nbsp;<cellbytelabel id="54">NO</cellbytelabel></label>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                Detallar:&nbsp;
                <%=fb.textarea("lesiones_obs",cdo.getColValue("lesiones_obs"),false,false,viewMode||cdo.getColValue("lesiones_obs"," ").trim().equals(""),60,1,0,"form-control input-sm","","")%>
            </td>
        </tr>
        
        <tr>
            <td class="controls form-inline">
                <b>Permeabilidad de las coanas:</b>&nbsp;&nbsp;
            </td>
            <td colspan="3">
                <label class="pointer">
                <%=fb.radio("perm_coanas","S",((cdo.getColValue("perm_coanas")!=null && cdo.getColValue("perm_coanas").equals("S"))?true:false),viewMode,false)%><cellbytelabel>SI</cellbytelabel></label>
                &nbsp;&nbsp;
                <label class="pointer">
                <%=fb.radio("perm_coanas","N",((cdo.getColValue("perm_coanas")!=null && cdo.getColValue("perm_coanas").equals("N"))?true:false),viewMode,false)%><cellbytelabel>NO</cellbytelabel></label>
            </td>
       </tr>
            
        <tr>
          <td class="controls form-inline">
              <b>Permeabilidad del es&oacute;fago :</b>&nbsp;&nbsp;
          </td>
          <td colspan="3">
              <label class="pointer">
              <%=fb.radio("perm_esofago","S",((cdo.getColValue("perm_esofago")!=null && cdo.getColValue("perm_esofago").equals("S"))?true:false),viewMode,false)%><cellbytelabel>SI</cellbytelabel></label>
              &nbsp;&nbsp;
              <label class="pointer">
              <%=fb.radio("perm_esofago","N",((cdo.getColValue("perm_esofago")!=null && cdo.getColValue("perm_esofago").equals("N"))?true:false),viewMode,false)%><cellbytelabel>NO</cellbytelabel></label>
          </td>
        </tr>
            
        <tr>
          <td class="controls form-inline">
              <b>Permeabilidad del ano :</b>&nbsp;&nbsp;
          </td>
          <td colspan="3">
              <label class="pointer">
              <%=fb.radio("perm_ano","S",((cdo.getColValue("perm_ano")!=null && cdo.getColValue("perm_ano").equals("S"))?true:false),viewMode,false)%><cellbytelabel>SI</cellbytelabel></label>
              &nbsp;&nbsp;
              <label class="pointer">
              <%=fb.radio("perm_ano","N",((cdo.getColValue("perm_esofago")!=null && cdo.getColValue("perm_ano").equals("N"))?true:false),viewMode,false)%><cellbytelabel>NO</cellbytelabel></label>
          </td>
        </tr>
        
         <tr>
          <td class="controls form-inline">
              <b>Evaluaci&oacute;n de riesgo :</b>&nbsp;&nbsp;
          </td>
          <td colspan="3">
              <label class="pointer">
              <%=fb.radio("eval_riesgo","S",((cdo.getColValue("eval_riesgo")!=null && cdo.getColValue("eval_riesgo").equals("S"))?true:false),viewMode,false)%><cellbytelabel>Sin riesgo</cellbytelabel></label>
              &nbsp;&nbsp;
              <label class="pointer">
              <%=fb.radio("eval_riesgo","C",((cdo.getColValue("eval_riesgo")!=null && cdo.getColValue("eval_riesgo").equals("C"))?true:false),viewMode,false)%><cellbytelabel>Con riesgo</cellbytelabel></label>
          </td>
        </tr>
        
        <tr>
          <td class="controls form-inline">
              <b>Lugar de Permanencia del Neonato :</b>&nbsp;&nbsp;
          </td>
          <td colspan="3">
              <label class="pointer">
                <%=fb.radio("lugar_permanencia_neo","1",((cdo.getColValue("lugar_permanencia_neo")!=null && cdo.getColValue("lugar_permanencia_neo").equals("1"))?true:false),viewMode,false)%> <cellbytelabel>Junto a la madre</cellbytelabel>
              </label>
              <br>
              <label class="pointer">
                <%=fb.radio("lugar_permanencia_neo","2",((cdo.getColValue("lugar_permanencia_neo")!=null && cdo.getColValue("lugar_permanencia_neo").equals("2"))?true:false),viewMode,false)%> <cellbytelabel>Sala neonatolog&iacute;a</cellbytelabel>
              </label>
              <br>
              <label class="pointer">
                <%=fb.radio("lugar_permanencia_neo","3",((cdo.getColValue("lugar_permanencia_neo")!=null && cdo.getColValue("lugar_permanencia_neo").equals("3"))?true:false),viewMode,false)%> <cellbytelabel>Unidad de observaci&oacute;n</cellbytelabel>
              </label>
              <br>
              <label class="pointer">
                <%=fb.radio("lugar_permanencia_neo","4",((cdo.getColValue("lugar_permanencia_neo")!=null && cdo.getColValue("lugar_permanencia_neo").equals("4"))?true:false),viewMode,false)%> <cellbytelabel>Unidad de cuidado intensivos</cellbytelabel>
              </label>
              <br>
              <label class="pointer">
                <%=fb.radio("lugar_permanencia_neo","5",((cdo.getColValue("lugar_permanencia_neo")!=null && cdo.getColValue("lugar_permanencia_neo").equals("5"))?true:false),viewMode,false)%> <cellbytelabel>Aislamiento</cellbytelabel>
              </label>
              <br>
              <label class="pointer">
                <%=fb.radio("lugar_permanencia_neo","6",((cdo.getColValue("lugar_permanencia_neo")!=null && cdo.getColValue("lugar_permanencia_neo").equals("6"))?true:false),viewMode,false)%> <cellbytelabel>Transferido</cellbytelabel>
              </label>
          </td>
        </tr>
        
				</table>
			</td>
		</tr>
        
        
        
        
        </table>
    
        <div class="footerform" style="bottom:-11px !important">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                <tr>
                    <td>
                        <%=fb.hidden("saveOption","O")%>
                        <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                        <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
                   </td>
                </tr>
            </table>   
        </div>
        <%=fb.formEnd(true)%>
    </div> <!-- Examen fisico inmediato -->
   
</div> <!-- Tab panes -->    

</div>
</div>
</body>
</html>
<%
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int sizeCordon = Integer.parseInt(request.getParameter("sizeCordon"));
	
	if(tab.equals("0"))//Examen fisico de inmediato
	{
		CommonDataObject neo = new CommonDataObject();

		neo.setTableName("TBL_SAL_SERV_NEONATOLOGIA");
		neo.setWhereClause("pac_id="+pacId+" and secuencia="+noAdmision);
		
		neo.addColValue("tiempo_de_vida",request.getParameter("tiempo_de_vida"));
		neo.addColValue("rn_peso",request.getParameter("peso"));
		neo.addColValue("rn_talla",request.getParameter("talla"));
		neo.addColValue("pc",request.getParameter("pc"));
		neo.addColValue("rn_edad_gest_ex_fis",request.getParameter("edad"));
		if(request.getParameter("difResp") != null) neo.addColValue("rn_dif_resp",request.getParameter("difResp"));
		if(request.getParameter("piel") != null) neo.addColValue("rn_cp_ictericia",request.getParameter("piel"));
		if(request.getParameter("palidez") != null) neo.addColValue("rn_cp_palidez",request.getParameter("palidez"));
		if(request.getParameter("cianosis") != null) neo.addColValue("rn_cp_cianosis",request.getParameter("cianosis"));
		if(request.getParameter("malform") != null) neo.addColValue("rn_malforma",request.getParameter("malform"));
		if(request.getParameter("neuro") != null) neo.addColValue("rn_neuro",request.getParameter("neuro"));
		if(request.getParameter("abdomen") != null) neo.addColValue("rn_abdomen",request.getParameter("abdomen"));
		if(request.getParameter("orino") != null) neo.addColValue("rn_orino",request.getParameter("orino"));
		if(request.getParameter("meconio") != null) neo.addColValue("rn_exp_meco",request.getParameter("meconio"));
		if(request.getParameter("cardio") != null) neo.addColValue("rn_cardio",request.getParameter("cardio"));
		if(request.getParameter("lesiones") != null) {
        neo.addColValue("lesiones",request.getParameter("lesiones"));
        neo.addColValue("lesiones_obs",request.getParameter("lesiones_obs"));
    }
    
    neo.addColValue("perm_coanas",request.getParameter("perm_coanas"));
		neo.addColValue("perm_esofago",request.getParameter("perm_esofago"));
		neo.addColValue("perm_ano",request.getParameter("perm_ano"));
		neo.addColValue("eval_riesgo",request.getParameter("eval_riesgo"));
		neo.addColValue("lugar_permanencia_neo",request.getParameter("lugar_permanencia_neo"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add"))
		{
			neo.addColValue("fecha_nacimiento",request.getParameter("dob"));
			neo.addColValue("codigo_paciente",request.getParameter("codPac"));
			neo.addColValue("pac_id",pacId);
			neo.addColValue("secuencia",noAdmision);
			SQLMgr.insert(neo);
		}
		else if (modeSec.equalsIgnoreCase("edit"))
		{
			neo.setWhereClause("pac_id="+pacId+" and secuencia="+noAdmision);
			SQLMgr.update(neo);
		}
		ConMgr.clearAppCtx(null);
	}//Enf Tab

%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?tab=<%=tab%>&seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&codigo_hdr_cordon=<%=codigoHdr%>&cds=<%=cds%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>