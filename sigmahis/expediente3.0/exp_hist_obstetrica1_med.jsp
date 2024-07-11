<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.HistoriaObstetricaIMed"%>
<%@ page import="issi.expediente.DetalleHistoriaMed"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="HistoriaMed" scope="session" class="issi.expediente.HistoriaObstetricaIMed" />
<jsp:useBean id="HOIMedMgr" scope="session" class="issi.expediente.HistoriaObstetricaIMedMgr" />
<jsp:useBean id="iTactos" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iMatDet" scope="session" class="java.util.Hashtable" />

<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
HOIMedMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode == null || mode.trim().equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String tab = request.getParameter("tab");
String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = cDateTime.substring(0,10);
String cod_Historia ="0";
String key = "";
int tactosLastLineNo = 0;
if (tab == null) tab = "0";
if (request.getParameter("tactosLastLineNo") != null) tactosLastLineNo = Integer.parseInt(request.getParameter("tactosLastLineNo"));
if(request.getParameter("cod_Historia") != null) cod_Historia = request.getParameter("cod_Historia");
String active0 = "", active1 = "", active2 = "", active3 = "", active4 = "", active5 = "", active6 = "";

CommonDataObject cdoC = SQLMgr.getData("SELECT codigo FROM TBL_SAL_HISTORIA_OBSTETRICA_M WHERE PAC_ID = "+pacId);
if (cdoC == null) {
	cdoC = new CommonDataObject();
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
 HistoriaMed = new HistoriaObstetricaIMed();
 session.setAttribute("HistoriaMed",HistoriaMed);

 if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

sql="select decode(b.APELLIDO_DE_CASADA,null, b.PRIMER_APELLIDO||' '||b.SEGUNDO_APELLIDO, b.APELLIDO_DE_CASADA)||' '|| b.PRIMER_NOMBRE||' '||b.SEGUNDO_NOMBRE as nombreMedico, a.codigo as codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.fecha_u_r,'dd/mm/yyyy') as fechaUR, a.edad_gesta as edadGesta, a.gesta as gesta, a.para as para, a.cesarea as cesarea, a.aborto as aborto, nvl(a.embarazo,'S') as embarazo, a.numero_hijo as numeroHijo, nvl(a.trabajo_parto,'E') as trabajoParto, to_char(a.fecha_ini,'dd/mm/yyyy') as fechaIni, to_char(a.hora_ini,'hh12:mi:ss am') as horaIni, nvl(a.ruptura_membrana,'E') as rupturaMembrana, to_char(a.fecha_ruptura,'dd/mm/yyyy') as fechaRuptura, to_char(a.hora_ruptura,'hh12:mi:ss am') as horaRuptura, /*tab 1*/nvl(a.cantidad_liquido,' ') as cantidadLiquido, nvl(a.aspecto_liquido,'CS') as aspectoLiquido, to_char(a.fecha_parto,'dd/mm/yyyy') as fechaParto, to_char(a.hora_parto,'hh12:mi:ss am') as horaParto/*tab 2*/, a.dia_tacto as diaTacto, to_char(a.hora_tacto,'hh12:mi:ss am') as horaTacto /*tab 3*/, a.cuello_dil as cuelloDil, a.segmento as segmento, a.planos as planos, a.foco as foco, /*a.presion_arterial as presionArterial*/ a.funcion as funcion, a.membrana as membrana, a.temperatura as temperatura, a.observa_tacto as observaTacto, a.observa_tratamiento as observaTratamiento, a.tratamiento as tratamiento, nvl(a.tipo_anestesia,' ') as tipoAnestesia, nvl(a.presentacion_parto,' ') as presentacionParto, a.observa_presentacion as observaPresentacion, a.tipo_parto as tipoParto, nvl(a.episiotomia,' ') as episiotomia, a.episografia as episografia, a.material_usado as materialUsado, nvl(a.tipo_instrumento,' ') as tipoInstrumento, a.forcep1 as forcep1, a.forcep2 as forcep2, nvl(a.indicacion,' ') as indicacion, a.otras as otras, a.variedad_posicion as variedadPosicion, a.nivel_presenta as nivelPresenta, a.plano as plano, a.maniobras as maniobras, nvl(a.tipo_forcep,' ') as tipoForcep, a.cod_anestesia as codAnestesia, a.medico as medico, a.asp_liq as aspLiq, a.cant_liq as cantLiq, a.paridad_valor as paridadValor, a.paridad as paridad, a.control_prenatal as controlPrenatal,  nvl(a.serologia_lues,' ') as serologiaLues,  nvl(a.sensibilizacion_rh,' ') as sensibilizacionRh, nvl(a.sensibilizacion_abo,' ') as sensibilizacionAbo, nvl(a.patologia_hijos_ant,' ') as patologiaHijosAnt, nvl(a.patologia_hijos_ant_espec,' ') as patologiaHijosAntEspec, nvl(a.electroforesis_hb,' ') as electroforesisHb, nvl(a.toxoplasmosis,' ') as toxoplasmosis, nvl(a.horas_labor,' ') as horasLabor,  nvl(a.signo_sufrimiento_fetal,' ') as signoSufrimientoFetal,  nvl(a.monitoreo,' ') as monitoreo,  nvl(a.causas_intervencion,' ') as causasIntervencion,  nvl(a.ecografia,' ') as ecografia,  nvl(a.drogas,' ') as drogas,  nvl(a.drogas_nombre,' ') as drogasNombre,  nvl(a.drogas_tiempo_anteparto_dosis,' ') as drogasTiempoAntepartoDosis,  nvl(a.anomalia_congenita,' ') as anomaliaCongenita,  nvl(a.anomalia_cong_especificar,' ') as anomaliaCongEspecificar,  nvl(a.patologia,' ') as patologia,  nvl(a.patologia_espec,' ') as patologiaEspec, nvl(a.forma_terminacion,' ') as formaTerminacion, nvl(a.observ,' ') as observ, a.minutos as minutos, a.tipo_sangre as tipoSangre, a.presion_arterial presionArterial from tbl_sal_historia_obstetrica_m a, tbl_adm_medico b where a.pac_id="+pacId+" and a.codigo="+noAdmision+" and a.medico=b.codigo(+)";

//System.out.println("SQL:\n"+sql);

HistoriaMed = (HistoriaObstetricaIMed) sbb.getSingleRowBean(ConMgr.getConnection(),sql,HistoriaObstetricaIMed.class);
if(HistoriaMed== null)
{
			HistoriaMed = new HistoriaObstetricaIMed();
			HistoriaMed.setFecha(cDate);
			HistoriaMed.setEmbarazo("S");
			HistoriaMed.setTrabajoParto("E");
			HistoriaMed.setRupturaMembrana("E");
			HistoriaMed.setCodigo(noAdmision);
			HistoriaMed.setCantidadLiquido("N");
			HistoriaMed.setAspectoLiquido("CS");
			HistoriaMed.setTipoAnestesia("N");
			HistoriaMed.setCodAnestesia("");
			HistoriaMed.setPresentacionParto("V");
			HistoriaMed.setEpisiotomia("");
			HistoriaMed.setTipoInstrumento("E");
			HistoriaMed.setIndicacion("PF");
			HistoriaMed.setTipoForcep("K");
			HistoriaMed.setPacId(pacId);

			if (!viewMode) modeSec = "add";

}else if (!viewMode) modeSec = "edit";
cod_Historia = HistoriaMed.getCodigo();
if(HistoriaMed.getFechaIni()== null) HistoriaMed.setFechaIni("");
if(HistoriaMed.getHoraIni()== null) HistoriaMed.setHoraIni("");
if(HistoriaMed.getFechaUR()== null) HistoriaMed.setFechaUR("");
if(HistoriaMed.getFechaRuptura()== null) HistoriaMed.setFechaRuptura("");
if(HistoriaMed.getHoraRuptura()== null) HistoriaMed.setHoraRuptura("");
if(HistoriaMed.getFechaParto()== null) HistoriaMed.setFechaParto("");
if(HistoriaMed.getHoraParto()== null) HistoriaMed.setHoraParto("");

if (tab.equals("0")) active0 = "active";
else if (tab.equals("1")) active1 = "active";
else if (tab.equals("2")) active2 = "active";
else if (tab.equals("3")) active3 = "active";
else if (tab.equals("4")) active4 = "active";
else if (tab.equals("5")) active5 = "active";
else if (tab.equals("6")) active6 = "active";

if(change == null)
{
    iTactos.clear();
    sql="select to_char(a.fecha_hist,'dd/mm/yyyy') as fechahist, a.cod_hist as codhist, a.secuencia as secuencia, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, a.cuello_dilata as cuellodilata, a.seg_inf as seginf, a.pre_pos_plan as preposplan, a.foco_fetal as focofetal, a.func_contrac as funccontrac, a.membr as membr, a.temp as temp, a.observacion as observacion, a.plano as plano,posicion as posicion, a.presion_arterial presionArterial, a.tipo_parto tipoParto, a.motivo_cesarea motivoCesarea from tbl_sal_hist_obst_tactos_m a, TBL_SAL_HISTORIA_OBSTETRICA_m b where b.pac_id="+pacId+" and a.pac_id="+pacId+" and a.cod_hist=b.codigo and a.pac_id=b.pac_id and a.cod_hist="+cod_Historia;

    al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleHistoriaMed.class);

    for (int i=1; i<=al.size(); i++){
        try{
            DetalleHistoriaMed newDetHist =  (DetalleHistoriaMed) al.get(i-1);
            if(newDetHist.getHora()==null) newDetHist.setHora("");
            if(newDetHist.getFecha()==null) newDetHist.setFecha("");
            tactosLastLineNo++;
            if (tactosLastLineNo < 10) key = "00" + tactosLastLineNo;
            else if (tactosLastLineNo < 100) key = "0" + tactosLastLineNo;
            else key = "" + tactosLastLineNo;
            iTactos.put(key, al.get(i-1));
        }
        catch(Exception e){
            System.err.println(e.getMessage());
        }
    }//for

    if (al.size() == 0) {
        DetalleHistoriaMed newDetHist = new DetalleHistoriaMed();
        newDetHist.setFecha(HistoriaMed.getFecha());
        newDetHist.setSecuencia("1");
        newDetHist.setCodHist(HistoriaMed.getCodigo());
        newDetHist.setFechaHist(HistoriaMed.getFecha());

        tactosLastLineNo++;
        if (tactosLastLineNo < 10) key = "00" + tactosLastLineNo;
        else if (tactosLastLineNo < 100) key = "0" + tactosLastLineNo;
        else key = "" + tactosLastLineNo;
        try{
          iTactos.put(key, newDetHist);
        }
        catch(Exception e){
          System.err.println(e.getMessage());
        }
    }

    iMatDet.clear();
    sql = "select m.codigo valor, h.conteo_inicial conteoInicial, h.conteo_final conteoFinal, m.descripcion descripcionMat from TBL_SAL_HIST_OBST_MATERIALES_M h , tbl_sal_obst_materiales m where h.pac_id(+) = "+pacId+" and h.admision(+) = "+noAdmision+" and h.cod_historial(+)  = "+cod_Historia+" and m.codigo = h.valor(+)";

    al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleHistoriaMed.class);

    for (int m = 1; m<=al.size(); m++) {
        try{
            DetalleHistoriaMed newDetHist =  (DetalleHistoriaMed) al.get(m-1);

            if (m < 10) key = "00" + m;
            else if (m < 100) key = "0" + m;
            else key = "" + m;
            iMatDet.put(key, al.get(m-1));
        }
        catch(Exception e){
            System.err.println(e.getMessage());
        }
    }

    if (al.size() == 0) {
        ArrayList alMat = SQLMgr.getDataList("select codigo, descripcion from tbl_sal_obst_materiales where estado = 'A'");

        for (int m = 1; m<=alMat.size(); m++) {
            DetalleHistoriaMed newDetHist = new DetalleHistoriaMed();
            CommonDataObject cdoMat = (CommonDataObject) alMat.get(m-1);
            newDetHist.setValor(cdoMat.getColValue("codigo"));
            newDetHist.setDescripcionMat(cdoMat.getColValue("descripcion"));

            if (m < 10) key = "00" + m;
            else if (m < 100) key = "0" + m;
            else key = "" + m;

            try{
                iMatDet.put(key, newDetHist);
            }
            catch(Exception e){
                System.err.println(e.getMessage());
            }
        }
    }
}//change
else if (!viewMode) modeSec = "edit";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE-HISTORIA OBSTETRICA PARTE I '+document.title;
function verOcult(k){if(k==1){eval('document.form0.cantidadHijo').readOnly=false;eval('document.form0.cantidadHijo').className = 'FormDataObjectEnabled form-control input-sm';eval('document.form0.cantidadHijo').disabled = false;}else if (k==2){ eval('document.form0.cantidadHijo').disabled = false;eval('document.form0.cantidadHijo').className = 'form-control input-sm  FormDataObjectDisabled';eval('document.form0.cantidadHijo').readOnly=true;}else if (k==3){ eval('document.form6.codAnest').disabled = false;eval('document.form6.codAnest').className = 'form-control input-sm FormDataObjectEnabled';}else if (k==4){ eval('document.form6.codAnest').disabled = true;eval('document.form6.codAnest').className = 'form-control input-sm FormDataObjectDisabled';}}
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=exp_hist_obstetrica');}
function doAction(){
	//if ( document.getElementById("blockTab5") && document.getElementById("blockTab5").value == "S" ){DisableEnableForm(document.form5,true);}else if ( document.getElementById("blockTab4") && document.getElementById("blockTab4").value == "S" ){DisableEnableForm(document.form4,true);}
	
	setPatientInfo("form0")
	<%if(!modeSec.equalsIgnoreCase("add")){%>
	setPatientInfo("form4")
	setPatientInfo("form5")
	setPatientInfo("form6")
	<%}%>
}
function DisableEnableForm(xForm,flag){objElems = xForm.elements;for(i=0;i<objElems.length;i++){objElems[i].disabled = flag;}}
function printRpt(){
    var horasLabor = $("#tactos_horas_labor").val();
    abrir_ventana1('../expediente3.0/print_hist_obstetrica1_med.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cod_Historia=<%=cod_Historia%>&seccion=<%=seccion%>&desc=<%=desc%>&horas_labor='+horasLabor);
}

function getAlarma() {
  var tot = 0;
  for (var m = 1; m <= <%=iMatDet.size()%>; m++) {
    var conteoInicial = $("#conteo_inicial"+m).val() || '0';
    var conteoFinal = $("#conteo_final"+m).val() || '0';
    conteoInicial = parseInt(conteoInicial,10);
    conteoFinal = parseInt(conteoFinal, 10);
    if ( conteoInicial - conteoFinal != 0 ) {
      $("#gen_alarma"+m).val("Y");
      tot++;
    } else {
      $("#gen_alarma"+m).val("N");
    }
  }
  $("#tmp_gen_alarma").val(""+tot)
}

function doSubmit(form,objValue){
    setBAction(form.name,objValue);
    // getAlarma();

    var genAlarma = $("#tmp_gen_alarma").val() || '0'
    genAlarma = parseInt(genAlarma, 10)
    if (genAlarma) {
       parent.CBMSG.alert("Material usado inicial es diferente de material final!", {
         cb: function(r) {
           if (r == 'Ok') form.submit();
         }
       });
    } else  {
       form.submit();
    }
}

function manageConteo(i) {
 if ( $("#mat"+i).is(":checked") )  {
    $("#conteo_inicial"+i).prop("readOnly", false)
    $("#conteo_final"+i).prop("readOnly", false)
 } else {
    $("#conteo_inicial"+i).val("").prop("readOnly", true)
    $("#conteo_final"+i).val("").prop("readOnly", true)
 }
}

function getHorasLabor() {
    var fFecha = $(".fechas_tactos").first().val();
    var fHora = $(".horas_tactos").first().val();
    var lFecha = $(".fechas_tactos").last().val();
    var lHora = $(".horas_tactos").last().val();
    var fDate = fFecha.concat(" ").concat(fHora);
    var lDate = lFecha.concat(" ").concat(lHora);

    if (lDate != fDate) {
        var result = getDBData('<%=request.getContextPath()%>',"round(24*(to_date('"+lDate+"','dd/mm/yyyy hh12:mi:ss am') -  to_date('"+fDate+"','dd/mm/yyyy hh12:mi:ss am'))) ",'dual','','');
        $("#tactos_horas_labor").val(result);
    }
}

$(function(){
    $("input:radio[name='tactos_tipo_parto']").click(function(){
        if (this.value == 'C') $("#motivo_cesarea").prop("readOnly", false);
        else $("#motivo_cesarea").prop("readOnly", true).val("");
    });
    <%if(!modeSec.equalsIgnoreCase("add")){%>
    getHorasLabor();
    <%}%>
});

function setPatientInfo(formName) {
	document.forms[formName].dob.value=  $("#fechaNacimiento",parent.document).val();
	document.forms[formName].codPac.value=$("#codigoPaciente",parent.document).val();
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

    <div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-1">
        <tr>
            <td>
                <%=fb.button("imprimir","imprimir",false,false,null,null,"onClick=\"javascript:printRpt()\"")%>
            </td>
        </tr>
    </table>
    </div>

    <ul class="nav nav-tabs" role="tablist">
	
		<li role="presentation" class="<%=active0%>">
            <a href="#generales" aria-controls="generales" role="tab" data-toggle="tab"><b>Generales Parto</b></a>
        </li>

        <%if (!modeSec.equalsIgnoreCase("add")){%> 
		  <li role="presentation" class="<%=active1%>">
            <a href="#parto_normal" aria-controls="parto_normal" role="tab" data-toggle="tab"><b>Parto Normal</b></a>
          </li>
          <li role="presentation" class="<%=active2%>">
            <a href="#parto_instrumental" aria-controls="parto_instrumental" role="tab" data-toggle="tab"><b>Parto Instrumental</b></a>
          </li>
          <li role="presentation" class="<%=active3%>">
            <a href="#anestesia" aria-controls="anestesia" role="tab" data-toggle="tab"><b>Anestesia</b></a>
          </li>
        <%}%>
    </ul>

    <!-- Tab panes -->
  <div class="tab-content">
  
  <!-- Generales -->
    <div role="tabpanel" class="tab-pane <%=active0%>" id="generales">

         <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
         <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
         <%=fb.formStart(true)%>
         <%=fb.hidden("baction","")%>
         <%=fb.hidden("mode",mode)%>
         <%=fb.hidden("modeSec",modeSec)%>
         <%=fb.hidden("seccion",seccion)%>
         <%=fb.hidden("dob","")%>
         <%=fb.hidden("codPac","")%>
         <%=fb.hidden("pacId",pacId)%>
         <%=fb.hidden("noAdmision",noAdmision)%>
         <%=fb.hidden("tab","0")%>
         <%=fb.hidden("cod_Historia",cod_Historia)%>
         <%=fb.hidden("tactosLastLineNo",""+tactosLastLineNo)%>
         <%=fb.hidden("size",""+iTactos.size())%>
         <%=fb.hidden("desc",desc)%>
         <%=fb.hidden("tmp_gen_alarma","")%>

         <table cellspacing="0" class="table table-small-font table-bordered">
		 
		 <tbody>
            <tr>
                <td align="right"><cellbytelabel id="1">Fecha</cellbytelabel></td>
                <td class="controls form-inline">
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fecha" />
                    <jsp:param name="valueOfTBox1" value="<%=HistoriaMed.getFecha()%>" />
                    </jsp:include>
                </td>

                <td align="right"> <cellbytelabel id="3">M&eacute;dico</cellbytelabel></td>
                <td class="controls form-inline">
                    <%=fb.textBox("codMedico",HistoriaMed.getMedico(),true,false,true,5,"form-control input-sm",null,null)%>
                    <%=fb.textBox("nombre_medico",HistoriaMed.getNombreMedico(),false,true,true,25,"form-control input-sm",null,null)%>
                    <%=fb.button("medico","...",true,viewMode,null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
                </td>
			</tr>
			</tbody>

            
            <tr class="bg-headtabla">
				<td colspan="4"><cellbytelabel id="14">EMBARAZO</cellbytelabel></td>
			</tr>

            <tbody>
            <tr>
                 <td><label class="pointer"><%=fb.radio("embarazo","S",(HistoriaMed.getEmbarazo().equals("S")),viewMode,false,null,null,"onClick=\"javascript:verOcult(2)\"")%><cellbytelabel id="15">Simple</cellbytelabel>&nbsp;&nbsp;</label></td>
                 <td><label class="pointer"><%=fb.radio("embarazo","M",(HistoriaMed.getEmbarazo().equals("M")),viewMode,false,null,null,"onClick=\"javascript:verOcult(1)\"")%><cellbytelabel id="16">M&uacute;ltiple</cellbytelabel></label></td>
                 <td colspan="2" class="controls form-inline"><cellbytelabel id="17">Cantidad</cellbytelabel>:&nbsp;&nbsp;<%=fb.intBox("cantidadHijo",HistoriaMed.getNumeroHijo(),false,(HistoriaMed.getEmbarazo().equals("S") || viewMode),(HistoriaMed.getEmbarazo().equals("S") || viewMode),5,2)%>
                 </td>
            </tr>
            </tbody>

         </table>

         <div class="footerform" style="bottom:-11px !important">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                <tr>
                    <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                    <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
                </tr>
            </table>
            </div>
            <%=fb.formEnd(true)%>
    </div> <!-- Generales -->
	
	<%if (!modeSec.equalsIgnoreCase("add")){%>

      <!-- Parto Normal -->
      <div role="tabpanel" class="tab-pane <%=active1%>" id="parto_normal">
        <%fb = new FormBean2("form4",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
         <%=fb.formStart(true)%>
         <%=fb.hidden("baction","")%>
         <%=fb.hidden("mode",mode)%>
         <%=fb.hidden("modeSec",modeSec)%>
         <%=fb.hidden("seccion",seccion)%>
         <%=fb.hidden("dob","")%>
         <%=fb.hidden("codPac","")%>
         <%=fb.hidden("pacId",pacId)%>
         <%=fb.hidden("noAdmision",noAdmision)%>
         <%=fb.hidden("desc",desc)%>
         <%=fb.hidden("tab","1")%>
         <%=fb.hidden("cod_Historia",cod_Historia)%>
         <%=fb.hidden("tactosLastLineNo",""+tactosLastLineNo)%>
         <%=fb.hidden("size",""+iTactos.size())%>
         <%=fb.hidden("sizeMat",""+iMatDet.size())%>
         <%=fb.hidden("fecHis",HistoriaMed.getFecha())%>
         <%=fb.hidden("gen_alarma","")%>
         <%=fb.hidden("tot_alarma","")%>
         <% if (!HistoriaMed.getPresentacionParto().equals(" ") || !HistoriaMed.getEpisiotomia().equals(" ")   ){%>
             <%=fb.hidden("blockTab5","S")%>
         <%}else{%>
            <%=fb.hidden("blockTab5","N")%>
          <%}%>
        <table cellspacing="0" class="table table-small-font table-bordered">
            <tr class="bg-headtabla">
                <td colspan="5"><cellbytelabel id="83">PARTO[Presentaci&oacute;n]</cellbytelabel></td>
            </tr>

            <tbody>
            <tr>
                <td><%=fb.radio("part","V",(HistoriaMed.getPresentacionParto().equals("V")),viewMode,false)%>&nbsp;Vertice<br>
                <%=fb.radio("part","P",(HistoriaMed.getPresentacionParto().equals("P")),viewMode,false)%>&nbsp;<cellbytelabel id="84">Pod&aacute;lica</cellbytelabel>
                </td>
                <td><%=fb.radio("part","C",(HistoriaMed.getPresentacionParto().equals("C")),viewMode,false)%>&nbsp;Cara Bregma
                </td>
                <td><cellbytelabel id="82">Observaci&oacute;n</cellbytelabel><br></td>
                <td colspan="2"><%=fb.textarea("observacion_parto",HistoriaMed.getObservaPresentacion(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
            </tr>
            </tbody>

            <tr class="bg-headtabla">
                <td colspan="5"><cellbytelabel id="86">TIPO DE PARTO[Normal]</cellbytelabel></td>
            </tr>

            <tbody>
            <tr>
                <td align="right"><cellbytelabel id="87">Episiotom&iacute;a</cellbytelabel></td>
                <td><%=fb.radio("episio","NO",(HistoriaMed.getEpisiotomia().equals("NO")),viewMode,false)%> <cellbytelabel id="88">NO</cellbytelabel></td>
                <td><%=fb.radio("episio","ME",(HistoriaMed.getEpisiotomia().equals("ME")),viewMode,false)%> <cellbytelabel id="89">Media</cellbytelabel></td>
                <td><%=fb.radio("episio","OD",(HistoriaMed.getEpisiotomia().equals("OD")),viewMode,false)%> <cellbytelabel id="90">Medio Lateral</cellbytelabel></td>
                <td><%=fb.radio("episio","OI",(HistoriaMed.getEpisiotomia().equals("OI")),viewMode,false)%> <cellbytelabel id="91">Episiorrafia</cellbytelabel></td>
            </tr>
            </tbody>

            <!--<tr class="bg-headtabla">
                <td colspan="5"><cellbytelabel id="86">MATERIAL USADO</cellbytelabel></td>
            </tr>-->

            <%
            al.clear();
            al = CmnMgr.reverseRecords(iMatDet);
            for (int m = 1; m <= iMatDet.size(); m++){
                key = al.get(m - 1).toString();
                DetalleHistoriaMed newMat =  (DetalleHistoriaMed) iMatDet.get(key);
                if (newMat.getConteoInicial() == null) newMat.setConteoInicial("");
                if (newMat.getConteoFinal() == null) newMat.setConteoFinal("");
            %>
            <%///=fb.hidden("gen_alarma"+m, "")%>
            <%//=fb.hidden("descripcion_mat"+m, newMat.getDescripcionMat())%>
                <!--<tbody>
                    <tr>
                        <td colspan="2" class="controls form-inline">
                            <label class="pointer">
                               <%//=fb.checkbox("mat"+m, newMat.getValor(),(newMat.getConteoInicial()!=null && !newMat.getConteoInicial().trim().equals("")),viewMode,"",null,"onchange='manageConteo("+m+")'")%>&nbsp;
                               <%//=newMat.getDescripcionMat()%>
                            </label>
                        </td>
                        <td colspan="3" class="controls form-inline">
                            Conteo Inicial:&nbsp;
                            <%//=fb.intBox("conteo_inicial"+m, newMat.getConteoInicial(),false,false,(viewMode || newMat.getConteoInicial().equals("") ),8,3,"form-control input-sm",null,"")%>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            Conteo Final:&nbsp;
                            <%//=fb.intBox("conteo_final"+m, newMat.getConteoFinal(),false,false,(viewMode || newMat.getConteoFinal().equals("")),8,3,"form-control input-sm",null,"")%>
                        </td>
                    </tr>
                </tbody>-->
            <%
             }
            %>

            <!--<tbody>
            <tr>
                <td align="right"><cellbytelabel id="93"></cellbytelabel></td>
                <td colspan="4" class="controls form-inline">
                    <%=fb.select("material","Agujas=Agujas,Vendas=Vendas,Vendas=Gazas",HistoriaMed.getMaterialUsado(),false,viewMode,0,"form-control input-sm",null,"",null," ")%>
                </td>
            </tr>
            </tbody>-->


        </table>

        <div class="footerform" style="bottom:-11px !important">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                <tr>
                    <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                    <%=fb.button("save","Guardar",true,viewMode,"",null,"onclick=\"doSubmit(this.form, this.value)\"")%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
                </tr>
            </table>
         </div>
         <%=fb.formEnd(true)%>
      </div> <!-- Parto Normal -->
	  
	   

      <!-- Parto Instrumental -->
      <div role="tabpanel" class="tab-pane <%=active2%>" id="parto_instrumental">
        <%fb = new FormBean2("form5",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
        <%=fb.hidden("desc",desc)%>
        <%=fb.hidden("tab","2")%>
        <%=fb.hidden("cod_Historia",cod_Historia)%>
        <%=fb.hidden("tactosLastLineNo",""+tactosLastLineNo)%>
        <%=fb.hidden("size",""+iTactos.size())%>
        <%=fb.hidden("fecHis",HistoriaMed.getFecha())%>

        <% if (!HistoriaMed.getTipoInstrumento().equals(" ") || !HistoriaMed.getIndicacion().equals(" ")   ){%>
        <%=fb.hidden("blockTab4","S")%>
        <%}else{%>
        <%=fb.hidden("blockTab4","N")%>
        <%}%>

         <table cellspacing="0" class="table table-small-font table-bordered">

         <tr class="bg-headtabla">
			<td colspan="5"><cellbytelabel id="94">TIPO DE PARTO[Instrumental]</cellbytelabel></td>
         </tr>

        <tbody>
        <tr>
            <td width="22%" align="right"><cellbytelabel id="95">Instrumental</cellbytelabel></td>
            <td width="18%"><%=fb.radio("instruments","E",(HistoriaMed.getTipoInstrumento().equals("E")),viewMode,false)%><cellbytelabel id="96">Vacuum Extractor</cellbytelabel></td>
            <td width="20%"><%=fb.radio("instruments","F",(HistoriaMed.getTipoInstrumento().equals("F")),viewMode,false)%><cellbytelabel id="97">Forceps</cellbytelabel></td>
            <td width="20%" class="controls form-inline"><cellbytelabel id="98">Forceps I</cellbytelabel> <%=fb.textBox("forceps1",HistoriaMed.getForcep1(),false,false,viewMode,8,50,"form-control input-sm", null,null)%></td>
            <td width="20%" class="controls form-inline"><cellbytelabel id="99">Forceps II</cellbytelabel> <%=fb.textBox("forceps2",HistoriaMed.getForcep2(),false,false,viewMode,8,50,"form-control input-sm", null,null)%></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td align="right"><cellbytelabel id="100">Indicaci&oacute;n</cellbytelabel></td>
            <td><%=fb.radio("indic","PF",(HistoriaMed.getIndicacion().equals("PF")),viewMode,false)%><cellbytelabel id="101">Profil&aacute;ctico</cellbytelabel></td>
            <td><%=fb.radio("indic","DR",(HistoriaMed.getIndicacion().equals("DR")),viewMode,false)%><cellbytelabel id="102">Distocia de Rotaci&oacute;n</cellbytelabel></td>
            <td><%=fb.radio("indic","DM",(HistoriaMed.getIndicacion().equals("DM")),viewMode,false)%><cellbytelabel id="103">Arresto del Descenso</cellbytelabel></td>
            <td><%=fb.radio("indic","CU",(HistoriaMed.getIndicacion().equals("CU")),viewMode,false)%><cellbytelabel id="104">Cabeza Ultima</cellbytelabel></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td align="right"><cellbytelabel id="105">Otros</cellbytelabel></td>
            <td colspan="4"><%=fb.textarea("otros",HistoriaMed.getOtras(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
        </tr>
        </tbody>

        <!--<tbody>
        <tr>
            <td align="right"><cellbytelabel id="106">Variedad de la posici&oacute;n</cellbytelabel></td>
            <td colspan="4"><%//=fb.textarea("variedad",HistoriaMed.getVariedadPosicion(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
        </tr>
        </tbody>-->

        <!--<tbody>
        <tr>
        <td colspan="5">
        <table cellpadding="1" cellspacing="1" width="100%">
            <tr class="TextRow01">
               <td width="50%"><cellbytelabel id="107">Nivel de la Presentaci&oacute;n</cellbytelabel><br>
               <%//=fb.textarea("nivel",HistoriaMed.getNivelPresenta(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
                <td width="50%"><cellbytelabel id="108">Plano</cellbytelabel><br>
                <%//=fb.textarea("plano_present",HistoriaMed.getPlano(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
            </tr>
        </table>
        </td>
        </tr>
        </tbody>-->

        <tbody>
        <tr>
            <td width="20%" align="right"><cellbytelabel id="109">Otras Maniobras</cellbytelabel></td>
            <td width="20%"><%=fb.radio("maniobras","K",(HistoriaMed.getTipoForcep().equals("K")),viewMode,false)%><cellbytelabel id="110">Kristeller</cellbytelabel></td>
            <td width="20%"><%=fb.radio("maniobras","M",(HistoriaMed.getTipoForcep().equals("M")),viewMode,false)%><cellbytelabel id="111">Moriceaux</cellbytelabel></td>
            <td width="20%"><%=fb.radio("maniobras","B",(HistoriaMed.getTipoForcep().equals("B")),viewMode,false)%><cellbytelabel id="112">Bracht</cellbytelabel></td>
            <td width="20%"><%=fb.radio("maniobras","R",(HistoriaMed.getTipoForcep().equals("R")),viewMode,false)%><cellbytelabel id="113">Rojas</cellbytelabel></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td align="right"><cellbytelabel id="114">Expl&iacute;que</cellbytelabel></td>
            <td colspan="4"><%=fb.textarea("explique",HistoriaMed.getManiobras(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
        </tr>
        </tbody>

         </table>
         <div class="footerform" style="bottom:-11px !important">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                <tr>
                    <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                    <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
                </tr>
            </table>
         </div>
         <%=fb.formEnd(true)%>
      </div> <!-- Parto Instrumental -->

      <!-- Anestesia -->
      <div role="tabpanel" class="tab-pane <%=active3%>" id="anestesia">
        <%fb = new FormBean2("form6",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
         <%=fb.hidden("desc",desc)%>
         <%=fb.hidden("tab","3")%>
         <%=fb.hidden("cod_Historia",cod_Historia)%>
         <%=fb.hidden("tactosLastLineNo",""+tactosLastLineNo)%>
         <%=fb.hidden("size",""+iTactos.size())%>
         <%=fb.hidden("fecHis",HistoriaMed.getFecha())%>
         <table cellspacing="0" class="table table-small-font table-bordered">

             <tr class="bg-headtabla">
                <td colspan="5"><cellbytelabel id="115">ANESTESIA</cellbytelabel></td>
             </tr>

            <tr>
                <td width="10%"><label class="pointer"><%=fb.radio("anestesia","S",(HistoriaMed.getTipoAnestesia().equals("S")),viewMode,false,null,null,"onClick=\"javascript:verOcult(3)\"")%><cellbytelabel id="116">SI</cellbytelabel></label></td>
                <td width="10%"><label class="pointer"><%=fb.radio("anestesia","N",(HistoriaMed.getTipoAnestesia().equals("N")),viewMode,false,null,null,"onClick=\"javascript:verOcult(4)\"")%><cellbytelabel id="88">NO</cellbytelabel></label></td>
                 <td width="25%" colspan="3" class="controls form-inline">Anestesia&nbsp;&nbsp; <%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo, codigo FROM TBL_SAL_TIPO_ANESTESIA ORDER BY 1","codAnest",HistoriaMed.getCodAnestesia(),false,(HistoriaMed.getTipoAnestesia().equals("N") || viewMode),0,"form-control",null,null)%></td>
            </tr>

         </table>
         <div class="footerform" style="bottom:-11px !important">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                <tr>
                    <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                    <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
                </tr>
            </table>
         </div>
         <%=fb.formEnd(true)%>
      </div> <!-- Anestesia -->

    <%}%>


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

    System.out.println("..................................................... tab = "+tab);
    System.out.println("..................................................... baction = "+baction);
	
	if(tab.equals("0")) //
	{
				HistoriaObstetricaIMed hist = new  HistoriaObstetricaIMed();
				hist.setPacId(request.getParameter("pacId"));
				hist.setFecNacimiento(request.getParameter("dob"));
				hist.setCodPaciente(request.getParameter("codPac"));
				hist.setCodigo(request.getParameter("cod_Historia"));
				hist.setFecha(request.getParameter("fecha"));
				//hist.setFechaUR(request.getParameter("ultimaRegla"));
				hist.setEdadGesta(request.getParameter("edadGestacional"));
				hist.setControlPrenatal(request.getParameter("nControl"));
				hist.setGesta(request.getParameter("gesta"));
				hist.setPara(request.getParameter("para"));
				hist.setCesarea(request.getParameter("cesarea"));
				hist.setAborto(request.getParameter("aborto"));
				hist.setMedico(request.getParameter("codMedico"));
				hist.setEmbarazo(request.getParameter("embarazo"));
				hist.setNumeroHijo(request.getParameter("cantidadHijo"));
				hist.setTrabajoParto(request.getParameter("tParto"));
				//hist.setFechaIni(request.getParameter("fechaIni"));
				//hist.setHoraIni(request.getParameter("horaIni"));
				hist.setRupturaMembrana(request.getParameter("Rupturas"));
				//hist.setFechaRuptura(request.getParameter("fechaRuptura"));
				// hist.setHoraRuptura(request.getParameter("horaRuptura"));
				// hist.setAlumbramiento(request.getParameter("alumbramiento"));
				hist.setObserv(request.getParameter("observ"));

                if (request.getParameter("tipo_sangre") != null && !request.getParameter("tipo_sangre").trim().equals(""))  hist.setTipoSangre(request.getParameter("tipo_sangre"));
                if (request.getParameter("presion_arterial") != null && !request.getParameter("presion_arterial").trim().equals("")) hist.setPresionArterial(request.getParameter("presion_arterial"));

			   if (request.getParameter("minutos")== null || request.getParameter("minutos").equals("")){
    		    hist.setMinutos("0");
				}else{
				hist.setMinutos(request.getParameter("minutos"));
				}

				hist.setFechaModificacion(cDateTime);
				hist.setUsuarioModificacion(((String) session.getAttribute("_userName")).trim());
				if (baction.equalsIgnoreCase("Guardar"))
				{
								ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				if (modeSec.equalsIgnoreCase("add"))
						{
								hist.setFechaCreacion(cDateTime);
								hist.setUsuarioCreacion(((String) session.getAttribute("_userName")).trim());

								HOIMedMgr.add(hist,"0");
								//cod_Historia = HOIMedMgr.getPkColValue("codigo");
						}
						else if (modeSec.equalsIgnoreCase("edit"))
						{
								HOIMedMgr.update(hist,"0");
						}
								ConMgr.clearAppCtx(null);
				}
	}

	
			else if(tab.equals("1")) {
                int size = Integer.parseInt(request.getParameter("sizeMat") == null ? "0" : request.getParameter("sizeMat"));
                al.clear();

                HistoriaObstetricaIMed hist = new  HistoriaObstetricaIMed();
                hist.setPacId(request.getParameter("pacId"));
                hist.setFecNacimiento(request.getParameter("dob"));
                hist.setCodPaciente(request.getParameter("codPac"));
                hist.setCodigo(request.getParameter("cod_Historia"));
                hist.setFecha(request.getParameter("fecHis"));
                hist.setPresentacionParto(request.getParameter("part"));
                hist.setObservaPresentacion(request.getParameter("observacion_parto"));
                hist.setEpisiotomia(request.getParameter("episio"));
                hist.setEpisografia(request.getParameter("episiorra"));
                hist.setMaterialUsado(request.getParameter("material"));

                //Materiales
                hist.setPacIdMat(request.getParameter("pacId"));
                hist.setAdmisionMat(request.getParameter("noAdmision"));
                hist.setCodHistorialMat(request.getParameter("cod_Historia"));
				hist.setMinutos("0");

                for (int i=1; i<=size; i++){
                    DetalleHistoriaMed detHist = new DetalleHistoriaMed();
                    if (request.getParameter("mat"+i) != null && !request.getParameter("mat"+i).equals("")) {
                      detHist.setPacIdMat(request.getParameter("pacId"));
                      detHist.setAdmisionMat(request.getParameter("noAdmision"));
                      detHist.setValor(request.getParameter("mat"+i));
                      detHist.setDescripcionMat(request.getParameter("descripcion_mat"+i));
                      detHist.setConteoInicial(request.getParameter("conteo_inicial"+i)!=null && !request.getParameter("conteo_inicial"+i).trim().equals("")?request.getParameter("conteo_inicial"+i):"0");
                      detHist.setConteoFinal(request.getParameter("conteo_final"+i) != null && !request.getParameter("conteo_final"+i).trim().equals("") ? request.getParameter("conteo_final"+i) : "0");
                      // detHist.setGenAlertaMat(request.getParameter("gen_alarma"+i));
                      detHist.setCodHistorialMat(request.getParameter("cod_Historia"));

                      try {
						hist.addMateriales(detHist);
					  } catch(Exception e){
						System.err.println(e.getMessage());
					  }

                    }
                }

                if (baction.equalsIgnoreCase("Guardar")){
                    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
                    if (modeSec.equalsIgnoreCase("add")){
                        HOIMedMgr.add(hist,"4");
                    } else HOIMedMgr.update(hist,"4");
                    ConMgr.clearAppCtx(null);
                 }
			}
			if(tab.equals("2")) //
			{
						HistoriaObstetricaIMed hist = new  HistoriaObstetricaIMed();
						hist.setPacId(request.getParameter("pacId"));
						hist.setFecNacimiento(request.getParameter("dob"));
						hist.setCodPaciente(request.getParameter("codPac"));
						hist.setCodigo(request.getParameter("cod_Historia"));
						hist.setFecha(request.getParameter("fecHis"));
						hist.setTipoInstrumento(request.getParameter("instruments"));
						hist.setForcep1(request.getParameter("forceps1"));
						hist.setForcep2(request.getParameter("forceps2"));
						hist.setIndicacion(request.getParameter("indic"));
						hist.setOtras(request.getParameter("otros"));
						hist.setVariedadPosicion(request.getParameter("variedad"));
						hist.setNivelPresenta(request.getParameter("nivel"));
						hist.setPlano(request.getParameter("plano_present"));
						hist.setManiobras(request.getParameter("explique"));
						hist.setTipoForcep(request.getParameter("maniobras"));
						if (baction.equalsIgnoreCase("Guardar"))
						 {
									ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
									if (modeSec.equalsIgnoreCase("edit"))
									{
											HOIMedMgr.update(hist,"5");
									}
									ConMgr.clearAppCtx(null);
						 }
			}

			if(tab.equals("3")) //
			{
						HistoriaObstetricaIMed hist = new  HistoriaObstetricaIMed();
						hist.setPacId(request.getParameter("pacId"));
						hist.setFecNacimiento(request.getParameter("dob"));
						hist.setCodPaciente(request.getParameter("codPac"));
						hist.setCodigo(request.getParameter("cod_Historia"));
						hist.setFecha(request.getParameter("fecHis"));
						hist.setTipoAnestesia(request.getParameter("anestesia"));
						hist.setCodAnestesia(request.getParameter("codAnest"));
						if (baction.equalsIgnoreCase("Guardar"))
						 {
									ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
									if (modeSec.equalsIgnoreCase("edit"))
									{
											HOIMedMgr.update(hist,"6");
									}
									ConMgr.clearAppCtx(null);
						 }
			}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (HOIMedMgr.getErrCode().equals("1"))
{
%>
	alert('<%=HOIMedMgr.getErrMsg()%>');
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
} else throw new Exception(HOIMedMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cod_Historia=<%=cod_Historia%>&tab=<%=tab%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
