<%@ page errorPage="../error.jsp"%>
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
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

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
String numeroBebe = request.getParameter("numero_bebe");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String tab = request.getParameter("tab");
if (tab == null) tab = "0";
if (numeroBebe == null) numeroBebe = "";

String active0 = "", active1 = "", active2 = "";
if (tab.equals("0")) active0 = "active";
else if (tab.equals("1")) active1 = "active";
else if (tab.equals("2")) active2 = "active";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdoBB = new CommonDataObject();
	/* Block used for correction of null admision en labor parto || */
  if(numeroBebe.trim().equals("")){
  cdoBB = SQLMgr.getData("select secuencia,utl_updsal_historia_nacido(pac_id_madre,admsec_madre) as upsec from tbl_adm_neonato where pac_id_madre = "+pacId+" and admsec_madre = "+noAdmision);
   if (cdoBB == null) cdoBB = new CommonDataObject();
  }
  /*End here */

  CommonDataObject cdoH1 = SQLMgr.getData("select embarazo, nvl(numero_hijo,1) numero_hijo, decode(fecha_ruptura,null,to_char(sysdate,'dd/mm/yyyy hh12:mi am'),to_char(fecha_ruptura,'dd/mm/yyyy')||' '||to_char(hora_ruptura,'hh12:mi am')) fecha_hora_ruptura from TBL_SAL_HISTORIA_OBSTETRICA_m where pac_id = "+pacId+" and codigo = "+noAdmision);

if (cdoH1 == null) {
  cdoH1 = new CommonDataObject();
  cdoH1.addColValue("embarazo", "S");
  cdoH1.addColValue("numero_hijo", "1");
}

//cdoH1.addColValue("embarazo", "S");
//cdoH1.addColValue("numero_hijo", "1");

/*if (cdoH1.getColValue("embarazo", "S").equalsIgnoreCase("S")) {
  numeroBebe = "1";
}
*/
sql="select a.cod_paciente, a.fec_nacimiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.sexo, a.peso, a.talla, a.condicion, a.apgar as apgar1, a.apgar5 as apgar2, a.alumbramiento as alumbramiento, a.utero, a.consulta, a.observa_consulta as observConsulta, a.cavidad_uterina as cavidad, a.observa_cavidad as cavidU, a.cicatriz_ant as cicatriz, a.observa_cicatriz as cicatrizAnt, a.ruptura_uterina as ruptura, a.observa_ruptura as observRuptura, a.consulta_ruptura as conductaRuptura, a.observa_rup_uterina as obsvConducta, a.conducta as conductaCica, a.conducta_obsv as observaConducta, a.cuello, a.tratamiento_cuello as observCuello, a.vagina, a.tratamiento_vagina as observVagina, a.perine, tratamiento_perine as observPerine, a.recto, a.tratamiento_recto as observRect, a.medico as codMedico, a.alumbramiento_obsv as observ, a.pac_id,a.alumbramiento_min minutos, a.vigoroso, a.observacion, perimetro_toracico, tiempo_vida, perimetro_cefalico, eval_riesgo, rcp, lugar_permanencia, lugar_transf, to_char(fecha_transf,'dd/mm/yyyy hh12:mi:ss am') fecha_transf, tipo_nacimiento, orden_nac, to_char(hora,'hh12:mi:ss am') hora from tbl_sal_historia_nacido_m a where a.pac_id="+pacId+" and nvl(admision, "+noAdmision+") = "+noAdmision+" and nvl(orden_nac, "+numeroBebe+") = "+numeroBebe;
	if(!numeroBebe.trim().equals("")) cdo = SQLMgr.getData(sql);

		if (cdo == null || numeroBebe.trim().equals(""))
		{
				if (!viewMode) modeSec = "add";
				cdo = new CommonDataObject();
				cdo.addColValue("CODIGO","1");
		}
		else if (!viewMode) modeSec = "edit";
		
		if (numeroBebe.trim().equals("")) {
		  viewMode = true;
		} else {
		  cdoBB = SQLMgr.getData("select to_char(fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, to_char(hora_nacimiento,'hh12:mi am') hora_nacimiento ,sexo, peso_lb|| ' LBS '||decode(peso_onz,null,'', peso_onz||' OZ') peso, talla, apgar1, apgar5, /*round( 24* (to_date(to_char(fecha_nacimiento,'dd/mm/yyyy')||' '||to_char(hora_nacimiento,'hh12:mi am'),'dd/mm/yyyy hh12:mi am') - to_date('"+cdoH1.getColValue("fecha_hora_ruptura")+"','dd/mm/yyyy hh12:mi am')))*/'0' tiempo_ruptura, to_char(fecha_nacimiento,'dd/mm/yyyy')||' '||to_char(hora_nacimiento,'hh12:mi am') fecha_hora_nac from tbl_adm_neonato where pac_id_madre = "+pacId+" and admsec_madre = "+noAdmision+" and secuencia = "+numeroBebe);
		  if (cdoBB == null) cdoBB = new CommonDataObject();
		}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - HISTORIA OBSTETRICA PARTE II '+document.title;
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=exp_hist_obstetrica');}
function doAction(){}
function printExp(){
  var numeroBebe = $("#numero_bebe").val();
var fechaHoraNac = $("#fecha_hora_nac").val();
var tiempoRuptura = $("#tiempo_ruptura").val();
if(numeroBebe) abrir_ventana1('../expediente3.0/print_hist_obstetrica2_med.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fecha_hora_nac='+fechaHoraNac+'&tiempo_ruptura='+tiempoRuptura+'&numero_bebe='+numeroBebe);
}


$(function(){
    $("input:radio[name='tipo_nacimiento']").click(function(){
        return false
        if (this.value == 'M') $("#orden_nac").prop("readOnly", false);
        else $("#orden_nac").prop("readOnly", true).val("");
    });
    
    $("#lugar_permanencia_5").click(function(){
        if (this.checked) {
            $("#lugar_transf, #fecha_transf").prop("readOnly", false);
            $("#resetfecha_transf").prop("disabled", false);
        } else {
            $("#lugar_transf, #fecha_transf").prop("readOnly", true).val("");
            $("#resetfecha_transf").prop("disabled", true);
        }
    });
    
    $("input:checkbox[name*='lugar_permanencia_']").click(function(){
        var values = $(".lugar_permanencia:checked").map(function(){
            return this.value
        }).get();
        
        $("#lugar_permanencia").val(values.join());
    });
    
     $("#numero_bebe").change(function(e) {
      if (this.value) window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tab=<%=tab%>&desc=<%=desc%>&numero_bebe='+this.value;
    });
});
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

    <div class="headerform">
        <table cellspacing="0" class="table pull-right table-striped table-custom-1">
            <tr>
                <td>
                    <%=fb.select(ConMgr.getConnection(),"select secuencia,'Bebe '||secuencia||'-'||trunc(fecha_nacimiento) from tbl_adm_neonato where pac_id_madre="+pacId+" and admsec_madre="+noAdmision+" order by secuencia","numero_bebe",numeroBebe,false,false,0,"Text10",null,null,null,"S")%>
                    <%=fb.button("imprimir","Imprimir",false,false,null,null,"onClick=\"javascript:printExp()\"")%>
                </td>
            </tr>
        </table>
    </div>
    
    <ul class="nav nav-tabs" role="tablist">    
        <li role="presentation" class="<%=active0%>">
            <a href="#datos_recien_nacido" aria-controls="datos_recien_nacido" role="tab" data-toggle="tab"><b>Datos Recien Nacido</b></a>
        </li>
    
        <%if (!modeSec.equalsIgnoreCase("add")){%>
            <li role="presentation" class="<%=active1%>">
                <a href="#revision_post_parto" aria-controls="revision_post_parto" role="tab" data-toggle="tab"><b>Revisi&oacute;n Post-Parto</b></a>
            </li>
            <li role="presentation" class="<%=active2%>">
                <a href="#alumbramiento" aria-controls="alumbramiento" role="tab" data-toggle="tab"><b>Alumbramiento</b></a>
            </li>
        <%}%>
    </ul>
    
    <div class="tab-content">
        <div role="tabpanel" class="tab-pane <%=active0%>" id="datos_recien_nacido">
            <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
            <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
            <%=fb.formStart(true)%>
            <%=fb.hidden("tab","0")%>
            <%=fb.hidden("baction","")%>
            <%=fb.hidden("mode",mode)%>
            <%=fb.hidden("modeSec",modeSec)%>
            <%=fb.hidden("seccion",seccion)%>
            <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
            <%=fb.hidden("dob","")%>
            <%=fb.hidden("codPac","")%>
            <%=fb.hidden("pacId",pacId)%>
            <%=fb.hidden("noAdmision",noAdmision)%>
            <%=fb.hidden("desc",desc)%>
            <%=fb.hidden("lugar_permanencia",cdo.getColValue("lugar_permanencia"," ").trim())%>
            
            <table cellspacing="0" class="table table-small-font table-bordered">
            
            <tbody>
            <tr>
                <td align="right">Nacimiento</td>
                <td>
                    <label class="pointer"><%=fb.radio("tipo_nacimiento","S",cdo.getColValue("tipo_nacimiento", cdoH1.getColValue("embarazo")).trim().equalsIgnoreCase("S"),viewMode,false,null,null,"")%>&nbsp;<cellbytelabel>Simple</cellbytelabel></label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("tipo_nacimiento","M",cdo.getColValue("tipo_nacimiento", cdoH1.getColValue("embarazo")).trim().equalsIgnoreCase("M"),viewMode,false,null,null,"")%>&nbsp;<cellbytelabel>M&uacute;ltiple</cellbytelabel></label>
                </td>
                <td colspan="2" class="controls form-inline">
                    <b>Orden:</b>&nbsp;<%=fb.textBox("orden_nac",cdo.getColValue("orden_nac",  numeroBebe),false,false,true,5,1,"form-control input-sm",null,null)%>
                </td>
            </tr>
            </tbody>
            
            <tr>
                <td align="right"><cellbytelabel id="1">Fecha</cellbytelabel></td>
                <td class="controls form-inline">
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fecha" />
                    <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha", cdoBB.getColValue("fecha_nacimiento", cDateTime.substring(0,10)))%>" />
                    </jsp:include>
                </td>
                <td align="right"><cellbytelabel id="2">Hora</cellbytelabel></td>
                <td class="controls form-inline">
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="hora" />
                    <jsp:param name="format" value="hh12:mi:ss am" />
                    <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora", cdoBB.getColValue("hora_nacimiento", " "))%>" />
                    </jsp:include>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    Sexo:&nbsp;<%=fb.select("sexo","M= Masculino, F = Femenino, I = Indefinido",cdo.getColValue("sexo", cdoBB.getColValue("sexo")))%>
                </td>
            </tr>
            
            <tr class="bg-headtabla">
                <td colspan="4"><cellbytelabel id="3">Datos antropom&eacute;tricos al nacer</cellbytelabel></td>
            </tr>

            <tbody>
            <tr>
                <td width="20%" align="right"><cellbytelabel id="4">Peso</cellbytelabel></td>
                <td width="20%">
                    <%=fb.textBox("peso",cdo.getColValue("peso", cdoBB.getColValue("peso")),false,false,viewMode,15,15,"form-control input-sm",null,null)%>
                </td>
                <td width="15%" align="right"><cellbytelabel id="5">Per&iacute;metro tor&aacute;cito</cellbytelabel></td>
                <td width="45%">
                    <%=fb.textBox("perimetro_toracico",cdo.getColValue("perimetro_toracico"),false,false,viewMode,15,15,"form-control input-sm",null,null)%>
                </td>
            </tr>
            </tbody>
            
            <tbody>
            <tr>
                <td align="right"><cellbytelabel id="6">Talla</cellbytelabel></td>
                <td><%=fb.textBox("talla",cdo.getColValue("talla", cdoBB.getColValue("talla")),false,false,viewMode,5,10,"form-control input-sm",null,null)%></td>
                <td align="right"><cellbytelabel id="7">Per&iacute;metro cef&aacute;lico</cellbytelabel></td>
                <td>
                <%=fb.textBox("perimetro_cefalico",cdo.getColValue("perimetro_cefalico"),false,false,viewMode,5,30,"form-control input-sm",null,null)%>
                </td>
            </tr>
            </tbody>

            <tbody>
            <tr>
                <td align="right">Vigoroso</td>
                <td><%=fb.select("vigoroso","S=Vigoroso,N=No Vigoroso",cdo.getColValue("vigoroso"),false,false,0,"form-control input-sm",null,null)%></td>
                <td align="right"><cellbytelabel id="8">Apgar 1</cellbytelabel></td>
                <td class="controls form-inline">
				    <%=fb.textBox("apgar1",cdo.getColValue("apgar1", cdoBB.getColValue("apgar1")),false,false,viewMode,5,1,"form-control input-sm",null,null)%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    Apgar 2
                     <%=fb.textBox("apgar2",cdo.getColValue("apgar2", cdoBB.getColValue("apgar5")),false,false,viewMode,5,1,"form-control input-sm",null,null)%>
                   
                </td>
            </tr>
            </tbody>
            
            </table>
            
            <div class="footerform" style="bottom:-11px !important">
                <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                    <tr>
                        <td>
                        <%=fb.hidden("fecha_hora_nac", cdoBB.getColValue("fecha_hora_nac"," "))%>
                        <%=fb.hidden("tiempo_ruptura", cdoBB.getColValue("tiempo_ruptura"," "))%>
                        <%=fb.hidden("saveOption","O")%>
                        <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                        <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
                    </tr>
                </table>   
             </div>
             
            <%=fb.formEnd(true)%>
        </div>
        
        <%if (!modeSec.equalsIgnoreCase("add")){%>
            <div role="tabpanel" class="tab-pane <%=active1%>" id="revision_post_parto">
               <%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
                <%=fb.formStart(true)%>
                <%=fb.hidden("tab","1")%>
                <%=fb.hidden("baction","")%>
                <%=fb.hidden("mode",mode)%>
                <%=fb.hidden("modeSec",modeSec)%>
                <%=fb.hidden("seccion",seccion)%>
                <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
                <%=fb.hidden("dob","")%>
                <%=fb.hidden("codPac","")%>
                <%=fb.hidden("pacId",pacId)%>
                <%=fb.hidden("noAdmision",noAdmision)%>
                <%=fb.hidden("desc",desc)%>
                <%=fb.hidden("orden_nac",cdo.getColValue("orden_nac",  numeroBebe))%>
                <table cellspacing="0" class="table table-small-font table-bordered">
                    <tr class="bg-headtabla">
                        <td colspan="3"><cellbytelabel id="13">REVISION POST-PARTO</cellbytelabel></td>
                    </tr>
                    
                    <tbody>
                    <tr>
                        <td width="25%" align="right"><cellbytelabel id="14">&Uacute;tero</cellbytelabel></td>
                        <td width="25%"><%=fb.hidden("CODIGO",cdo.getColValue("CODIGO"))%><%=fb.select("utero","C = Bien Contraido, H = Hipotonico",cdo.getColValue("utero"))%></td>
                        <td width="50%"><cellbytelabel id="15">Describa</cellbytelabel><br>
                        <%=fb.textarea("observConsulta",cdo.getColValue("observConsulta"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                    </tbody>
                
                    <tbody>
                    <tr>
                        <td align="right"><cellbytelabel id="16">Consulta [&Uacute;tero]</cellbytelabel></td>
                        <td colspan="2"><%=fb.select("consulta","M = Médica, Q = Quirúrgica, O = Otras",cdo.getColValue("consulta"))%></td>
                    </tr>
                    </tbody>
                    
                    <tbody>
                    <tr>
                        <td align="right"><cellbytelabel id="17">Cavidad Uterina</cellbytelabel></td>
                        <td><%=fb.select("cavidad","LI= Limpia e Indemne, RP = Con restos Placentaros, RT = Removidos totalmente, MA = Manual, IN = Instrumental",cdo.getColValue("cavidad"))%></td>
                        <td><cellbytelabel id="15">Describa</cellbytelabel><br>
                        <%=fb.textarea("cavidU",cdo.getColValue("cavidU"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                    </tbody>
        
                    <!--<tbody>
                    <tr>
                        <td align="right"><cellbytelabel id="18">Cicatriz Anterior</cellbytelabel></td>
                        <td><%=fb.select("cicatriz","I = Indemne, D = Dehiscencia de cicatriz anterior, P = Parcial (No traspasa Miometrio), A = Amplia (Traspasa Miometrio)",cdo.getColValue("cicatriz"))%></td>
                        <td><cellbytelabel id="15">Describa</cellbytelabel><br>
                        <%=fb.textarea("cicatrizAnt",cdo.getColValue("cicatrizAnt"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                    </tbody>-->
                    
                    <tbody>
                    <tr>
                        <td align="right"><cellbytelabel id="19">Ruptura Uterina</cellbytelabel></td>
                        <td><%=fb.select("ruptura","S = Si, N = No",cdo.getColValue("ruptura"))%></td>
                        <td><cellbytelabel id="20">Observaci&oacute;n</cellbytelabel><br>
                        <%=fb.textarea("observRuptura",cdo.getColValue("observRuptura"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                    </tbody>
                    
                    <tbody>
                    <tr>
                        <td align="right"><cellbytelabel id="21">Conducta</cellbytelabel></td>
                        <td><%=fb.select("conductaRuptura","M = Médica, Q = Quirúrgica, O = Otras",cdo.getColValue("conductaRuptura"))%></td>
                        <td><cellbytelabel id="20">Observaci&oacute;n</cellbytelabel><br>
                        <%=fb.textarea("obsvConducta",cdo.getColValue("obsvConducta"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                    </tbody>
                    
                    <tbody>
                    <tr>
                        <td align="right"><cellbytelabel id="22">Cuello</cellbytelabel></td>
                        <td><%=fb.select("cuello","I = Indemne, L = Lacerado",cdo.getColValue("cuello"))%></td>
                        <td><cellbytelabel id="23">Descripci&oacute;n y Tratamiento</cellbytelabel><br>
                        <%=fb.textarea("observCuello",cdo.getColValue("observCuello"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                    </tbody>
                    
                    <tbody>
                    <tr>
                        <td align="right"><cellbytelabel id="24">Vagina</cellbytelabel></td>
                        <td><%=fb.select("vagina","I = Indemne, L = Lacerado",cdo.getColValue("vagina"))%></td>
                        <td><cellbytelabel id="23">Descripci&oacute;n y Tratamiento</cellbytelabel><br>
                        <%=fb.textarea("observVagina",cdo.getColValue("observVagina"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                    </tbody>
                    
                    <tbody>
                    <tr>
                        <td align="right"><cellbytelabel id="35">Perine</cellbytelabel></td>
                        <td><%=fb.select("perine","I = Indemne, L = Lacerado",cdo.getColValue("perine"))%></td>
                        <td><cellbytelabel id="23">Descripci&oacute;n y Tratamiento</cellbytelabel><br>
                        <%=fb.textarea("observPerine",cdo.getColValue("observPerine"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                    </tbody>
                    
                    <tr>
                        <td align="right"><cellbytelabel id="26">Recto</cellbytelabel></td>
                        <td><%=fb.select("recto","I = Indemne, L = Lacerado",cdo.getColValue("recto"))%></td>
                        <td><cellbytelabel id="23">Descripci&oacute;n y Tratamiento</cellbytelabel><br>
                        <%=fb.textarea("observRect",cdo.getColValue("observRect"),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                </table>
                
                <div class="footerform" style="bottom:-11px !important">
                    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                        <tr>
                            <td>
                            <%=fb.hidden("saveOption","O")%>
                            <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
                        </tr>
                    </table>   
                 </div>
                
                
                <%=fb.formEnd(true)%>
            </div>
            
            
            <div role="tabpanel" class="tab-pane <%=active2%>" id="alumbramiento">
               <%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
                <%=fb.formStart(true)%>
                <%=fb.hidden("tab","2")%>
                <%=fb.hidden("baction","")%>
                <%=fb.hidden("mode",mode)%>
                <%=fb.hidden("modeSec",modeSec)%>
                <%=fb.hidden("seccion",seccion)%>
                <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
                <%=fb.hidden("dob","")%>
                <%=fb.hidden("codPac","")%>
                <%=fb.hidden("pacId",pacId)%>
                <%=fb.hidden("noAdmision",noAdmision)%>
                <%=fb.hidden("desc",desc)%>
                <%=fb.hidden("orden_nac",cdo.getColValue("orden_nac",  numeroBebe))%>
                <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                    <tr>
                        <td>Alumbramiento</td>
                        <td><%=fb.select("alumbramiento","ES = Espontáneo, AR = Artificial, ME = Maniobras Externas, EM = Extracción Manual de Anexos, CO = Completa,DG=Dirigido",cdo.getColValue("alumbramiento"),false,false,0,"form-control",null,null,null,"S")%></td>
                        <td><%=fb.textarea("observ",cdo.getColValue("observ"),false,false,viewMode,60,2,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                    
                    <tr>
                        <td>Minutos para el Alumbramiento</td>
                        <td colspan="2"><%=fb.textBox("minutos",cdo.getColValue("minutos"),false,false,viewMode,5,3,"form-control input-sm",null,null)%></td>
                    </tr>
                    
                </table>
                
                <div class="footerform" style="bottom:-11px !important">
                    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                        <tr>
                            <td>
                            <%=fb.hidden("saveOption","O")%>
                            <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
                        </tr>
                    </table>   
                 </div>
                
                
                <%=fb.formEnd(true)%>
            </div>
            
            
            
            
        <%}%>

    </div>
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

//if(tab.equals("0")) //Datos Reción Nacido
//	{
			cdo = new CommonDataObject();

		cdo.setTableName("tbl_sal_historia_nacido_m");
		if(request.getParameter("peso")!= null)
		cdo.addColValue("PESO",request.getParameter("peso"));
		if(request.getParameter("talla")!=null)
		cdo.addColValue("TALLA",request.getParameter("talla"));
		if(request.getParameter("condicion")!= null)
		cdo.addColValue("CONDICION",request.getParameter("condicion"));
		if(request.getParameter("apgar1")!=null)
		cdo.addColValue("APGAR",request.getParameter("apgar1"));
		if(request.getParameter("apgar2")!=null)
		cdo.addColValue("APGAR5",request.getParameter("apgar2"));
		
		if (request.getParameter("alumbramiento") != null)
            cdo.addColValue("ALUMBRAMIENTO",request.getParameter("alumbramiento"));
		
		if(request.getParameter("minutos")!= null)
            cdo.addColValue("alumbramiento_min",request.getParameter("minutos"));
		
		if(request.getParameter("observ")!=null)
            cdo.addColValue("ALUMBRAMIENTO_OBSV",request.getParameter("observ"));
		
		
		if (request.getParameter("utero") != null)
		 cdo.addColValue("UTERO",request.getParameter("utero"));
		if (request.getParameter("consulta") != null)
			cdo.addColValue("CONSULTA",request.getParameter("consulta"));
		 if (request.getParameter("observConsulta") != null)
	 cdo.addColValue("OBSERVA_CONSULTA",request.getParameter("observConsulta"));
	 if (request.getParameter("cavidad") != null)
	 cdo.addColValue("CAVIDAD_UTERINA",request.getParameter("cavidad"));
	 if (request.getParameter("cavidU") != null)
	 cdo.addColValue("OBSERVA_CAVIDAD",request.getParameter("cavidU"));
	 if (request.getParameter("cicatriz") != null)
	 cdo.addColValue("CICATRIZ_ANT",request.getParameter("cicatriz"));
	 if (request.getParameter("cicatrizAnt") != null)
	 cdo.addColValue("OBSERVA_CICATRIZ",request.getParameter("cicatrizAnt"));
	 if (request.getParameter("ruptura") != null)
	 cdo.addColValue("RUPTURA_UTERINA",request.getParameter("ruptura"));
	 if(request.getParameter("observRuptura")!=null)
	 cdo.addColValue("OBSERVA_RUPTURA",request.getParameter("observRuptura"));
	 if(request.getParameter("conductaRuptura")!= null)
	 cdo.addColValue("CONSULTA_RUPTURA",request.getParameter("conductaRuptura"));
	 if(request.getParameter("obsvConducta")!=null)
	 cdo.addColValue("OBSERVA_RUP_UTERINA",request.getParameter("obsvConducta"));
	 if(request.getParameter("cuello")!=null)
	 cdo.addColValue("CUELLO",request.getParameter("cuello"));
	 if(request.getParameter("observCuello") != null)
	 cdo.addColValue("TRATAMIENTO_CUELLO",request.getParameter("observCuello"));
	 if(request.getParameter("vagina")!=null)
		 cdo.addColValue("VAGINA",request.getParameter("vagina"));
	 if(request.getParameter("observVagina")!= null)
		 cdo.addColValue("TRATAMIENTO_VAGINA",request.getParameter("observVagina"));
	 if(request.getParameter("perine")!= null)
	 cdo.addColValue("PERINE",request.getParameter("perine"));
	 if(request.getParameter("observPerine")!=null)
	 cdo.addColValue("TRATAMIENTO_PERINE",request.getParameter("observPerine"));
	 if(request.getParameter("recto")!=null)
	 cdo.addColValue("RECTO",request.getParameter("recto"));
	 if(request.getParameter("observRect")!=null)
	 cdo.addColValue("TRATAMIENTO_RECTO",request.getParameter("observRect"));
	 if(request.getParameter("codMedico")!=null)
	 cdo.addColValue("MEDICO",request.getParameter("codMedico"));
	 if(request.getParameter("conductaCica")!=null)
	 cdo.addColValue("CONDUCTA",request.getParameter("conductaCica"));
	 if(request.getParameter("observaConducta")!=null)
	 cdo.addColValue("CONDUCTA_OBSV",request.getParameter("observaConducta"));
 	 cdo.addColValue("fecha_modificacion",cDateTime);
	 cdo.addColValue("usuario_modificacion",((String) session.getAttribute("_userName")).trim());
     
     cdo.addColValue("vigoroso",request.getParameter("vigoroso"));
     cdo.addColValue("observacion",request.getParameter("observacion"));
     
     cdo.addColValue("perimetro_toracico", request.getParameter("perimetro_toracico"));
     cdo.addColValue("tiempo_vida", request.getParameter("tiempo_vida"));
     cdo.addColValue("perimetro_cefalico", request.getParameter("perimetro_cefalico"));
     cdo.addColValue("eval_riesgo", request.getParameter("eval_riesgo"));
     cdo.addColValue("rcp", request.getParameter("rcp"));
     cdo.addColValue("lugar_permanencia", request.getParameter("lugar_permanencia"));
     cdo.addColValue("lugar_transf", request.getParameter("lugar_transf"));
     cdo.addColValue("fecha_transf", request.getParameter("fecha_transf"));
     cdo.addColValue("tipo_nacimiento", request.getParameter("tipo_nacimiento"));
     cdo.addColValue("orden_nac", request.getParameter("orden_nac"));
     cdo.addColValue("FECHA",request.getParameter("fecha"));
     cdo.addColValue("hora", request.getParameter("hora"));
     cdo.addColValue("SEXO",request.getParameter("sexo"));
     cdo.addColValue("admision",request.getParameter("noAdmision"));
	 
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add"))
			{
					cdo.addColValue("CODIGO","(SELECT nvl(max(CODIGO),0)+1 FROM tbl_sal_historia_nacido_m)");
					cdo.setAutoIncCol("CODIGO");
					cdo.addColValue("PAC_ID",request.getParameter("pacId"));
					cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
					cdo.addColValue("FEC_NACIMIENTO",request.getParameter("dob"));
					
					cdo.addColValue("fecha_creacion",cDateTime);
					cdo.addColValue("usuario_creacion",((String) session.getAttribute("_userName")).trim());
	 
					SQLMgr.insert(cdo);
			}
			else if (modeSec.equalsIgnoreCase("edit"))
			{
				 cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and nvl(admision, "+noAdmision+") = "+noAdmision+" and orden_nac = " + request.getParameter("orden_nac"));

				 SQLMgr.update(cdo);
			}
			ConMgr.clearAppCtx(null);
	//}
%>
<html>
<head>
<script language="javascript">
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
window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tab=<%=tab%>&desc=<%=desc%>&numero_bebe=<%=request.getParameter("orden_nac")%>';

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
