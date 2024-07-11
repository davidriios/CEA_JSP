<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.HistoriaObstetricaI"%>
<%@ page import="issi.expediente.DetalleHistoria"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="Historia" scope="session" class="issi.expediente.HistoriaObstetricaI" />
<jsp:useBean id="HOIMgr" scope="session" class="issi.expediente.HistoriaObstetricaIMgr" />
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
HOIMgr.setConnection(ConMgr);

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

if (request.getMethod().equalsIgnoreCase("GET"))
{
 Historia = new HistoriaObstetricaI();
 session.setAttribute("Historia",Historia);

 if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

sql="select decode(b.APELLIDO_DE_CASADA,null, b.PRIMER_APELLIDO||' '||b.SEGUNDO_APELLIDO, b.APELLIDO_DE_CASADA)||' '|| b.PRIMER_NOMBRE||' '||b.SEGUNDO_NOMBRE as nombreMedico, a.codigo as codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.fecha_u_r,'dd/mm/yyyy') as fechaUR, a.edad_gesta as edadGesta, a.gesta as gesta, a.para as para, a.cesarea as cesarea, a.aborto as aborto, nvl(a.embarazo,'S') as embarazo, a.numero_hijo as numeroHijo, nvl(a.trabajo_parto,'E') as trabajoParto, to_char(a.fecha_ini,'dd/mm/yyyy') as fechaIni, to_char(a.hora_ini,'hh12:mi:ss am') as horaIni, nvl(a.ruptura_membrana,'E') as rupturaMembrana, to_char(a.fecha_ruptura,'dd/mm/yyyy') as fechaRuptura, to_char(a.hora_ruptura,'hh12:mi:ss am') as horaRuptura, /*tab 1*/nvl(a.cantidad_liquido,' ') as cantidadLiquido, nvl(a.aspecto_liquido,'CS') as aspectoLiquido, to_char(a.fecha_parto,'dd/mm/yyyy') as fechaParto, to_char(a.hora_parto,'hh12:mi:ss am') as horaParto/*tab 2*/, a.dia_tacto as diaTacto, to_char(a.hora_tacto,'hh12:mi:ss am') as horaTacto /*tab 3*/, a.cuello_dil as cuelloDil, a.segmento as segmento, a.planos as planos, a.foco as foco, /*a.presion_arterial as presionArterial*/ a.funcion as funcion, a.membrana as membrana, a.temperatura as temperatura, a.observa_tacto as observaTacto, a.observa_tratamiento as observaTratamiento, a.tratamiento as tratamiento, nvl(a.tipo_anestesia,' ') as tipoAnestesia, nvl(a.presentacion_parto,' ') as presentacionParto, a.observa_presentacion as observaPresentacion, a.tipo_parto as tipoParto, nvl(a.episiotomia,' ') as episiotomia, a.episografia as episografia, a.material_usado as materialUsado, nvl(a.tipo_instrumento,' ') as tipoInstrumento, a.forcep1 as forcep1, a.forcep2 as forcep2, nvl(a.indicacion,' ') as indicacion, a.otras as otras, a.variedad_posicion as variedadPosicion, a.nivel_presenta as nivelPresenta, a.plano as plano, a.maniobras as maniobras, nvl(a.tipo_forcep,' ') as tipoForcep, a.cod_anestesia as codAnestesia, a.medico as medico, a.asp_liq as aspLiq, a.cant_liq as cantLiq, a.paridad_valor as paridadValor, a.paridad as paridad, a.control_prenatal as controlPrenatal,  nvl(a.serologia_lues,' ') as serologiaLues,  nvl(a.sensibilizacion_rh,' ') as sensibilizacionRh, nvl(a.sensibilizacion_abo,' ') as sensibilizacionAbo, nvl(a.patologia_hijos_ant,' ') as patologiaHijosAnt, nvl(a.patologia_hijos_ant_espec,' ') as patologiaHijosAntEspec, nvl(a.electroforesis_hb,' ') as electroforesisHb, nvl(a.toxoplasmosis,' ') as toxoplasmosis, nvl(a.horas_labor,' ') as horasLabor,  nvl(a.signo_sufrimiento_fetal,' ') as signoSufrimientoFetal,  nvl(a.monitoreo,' ') as monitoreo,  nvl(a.causas_intervencion,' ') as causasIntervencion,  nvl(a.ecografia,' ') as ecografia,  nvl(a.drogas,' ') as drogas,  nvl(a.drogas_nombre,' ') as drogasNombre,  nvl(a.drogas_tiempo_anteparto_dosis,' ') as drogasTiempoAntepartoDosis,  nvl(a.anomalia_congenita,' ') as anomaliaCongenita,  nvl(a.anomalia_cong_especificar,' ') as anomaliaCongEspecificar,  nvl(a.patologia,' ') as patologia,  nvl(a.patologia_espec,' ') as patologiaEspec, nvl(a.forma_terminacion,' ') as formaTerminacion, nvl(a.observ,' ') as observ, a.minutos as minutos, a.tipo_sangre as tipoSangre, a.presion_arterial presionArterial from tbl_sal_historia_obstetrica a, tbl_adm_medico b where a.pac_id="+pacId+" and a.codigo="+noAdmision+" and a.medico=b.codigo(+)";

//System.out.println("SQL:\n"+sql);

Historia = (HistoriaObstetricaI) sbb.getSingleRowBean(ConMgr.getConnection(),sql,HistoriaObstetricaI.class);
if(Historia== null)
{
			Historia = new HistoriaObstetricaI();
			Historia.setFecha(cDate);
			Historia.setEmbarazo("S");
			Historia.setTrabajoParto("E");
			Historia.setRupturaMembrana("E");
			Historia.setCodigo(noAdmision);
			Historia.setCantidadLiquido("N");
			Historia.setAspectoLiquido("CS");
			Historia.setTipoAnestesia("N");
			Historia.setCodAnestesia("");
			Historia.setPresentacionParto("V");
			Historia.setEpisiotomia("");
			Historia.setTipoInstrumento("E");
			Historia.setIndicacion("PF");
			Historia.setTipoForcep("K");
			Historia.setPacId(pacId);

			if (!viewMode) modeSec = "add";

}else if (!viewMode) modeSec = "edit";
cod_Historia = Historia.getCodigo();
if(Historia.getFechaIni()== null) Historia.setFechaIni("");
if(Historia.getHoraIni()== null) Historia.setHoraIni("");
if(Historia.getFechaUR()== null) Historia.setFechaUR("");
if(Historia.getFechaRuptura()== null) Historia.setFechaRuptura("");
if(Historia.getHoraRuptura()== null) Historia.setHoraRuptura("");
if(Historia.getFechaParto()== null) Historia.setFechaParto("");
if(Historia.getHoraParto()== null) Historia.setHoraParto("");

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
    sql="select to_char(a.fecha_hist,'dd/mm/yyyy') as fechahist, a.cod_hist as codhist, a.secuencia as secuencia, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, a.cuello_dilata as cuellodilata, a.seg_inf as seginf, a.pre_pos_plan as preposplan, a.foco_fetal as focofetal, a.func_contrac as funccontrac, a.membr as membr, a.temp as temp, a.observacion as observacion, a.plano as plano,posicion as posicion, a.presion_arterial presionArterial, a.tipo_parto tipoParto, a.motivo_cesarea motivoCesarea from tbl_sal_hist_obst_tactos a, TBL_SAL_HISTORIA_OBSTETRICA b where b.pac_id="+pacId+" and a.pac_id="+pacId+" and a.cod_hist=b.codigo and a.pac_id=b.pac_id and a.cod_hist="+cod_Historia;

    al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleHistoria.class);

    for (int i=1; i<=al.size(); i++){
        try{
            DetalleHistoria newDetHist =  (DetalleHistoria) al.get(i-1);
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
        DetalleHistoria newDetHist = new DetalleHistoria();
        newDetHist.setFecha(Historia.getFecha());
        newDetHist.setSecuencia("1");
        newDetHist.setCodHist(Historia.getCodigo());
        newDetHist.setFechaHist(Historia.getFecha());

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
    sql = "select m.codigo valor, h.conteo_inicial conteoInicial, h.conteo_final conteoFinal, m.descripcion descripcionMat from tbl_sal_hist_obste_materiales h , tbl_sal_obst_materiales m where h.pac_id(+) = "+pacId+" and h.admision(+) = "+noAdmision+" and h.cod_historial(+)  = "+cod_Historia+" and m.codigo = h.valor(+)";

    al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleHistoria.class);

    for (int m = 1; m<=al.size(); m++) {
        try{
            DetalleHistoria newDetHist =  (DetalleHistoria) al.get(m-1);

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
            DetalleHistoria newDetHist = new DetalleHistoria();
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
function doAction(){if ( document.getElementById("blockTab5") && document.getElementById("blockTab5").value == "S" ){DisableEnableForm(document.form5,true);}else if ( document.getElementById("blockTab4") && document.getElementById("blockTab4").value == "S" ){DisableEnableForm(document.form4,true);}}
function DisableEnableForm(xForm,flag){objElems = xForm.elements;for(i=0;i<objElems.length;i++){objElems[i].disabled = flag;}}
function printRpt(){
    var horasLabor = $("#tactos_horas_labor").val();
    abrir_ventana1('../expediente3.0/print_hist_obstetrica1.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cod_Historia=<%=cod_Historia%>&seccion=<%=seccion%>&desc=<%=desc%>&horas_labor='+horasLabor);
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
    getAlarma();

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
            <a href="#datos_adicionales" aria-controls="datos_adicionales" role="tab" data-toggle="tab"><b>Datos Adicionales</b></a>
          </li>
          <li role="presentation" class="<%=active2%>">
            <a href="#liquido_amniotico" aria-controls="liquido_amniotico" role="tab" data-toggle="tab"><b>Liquido Amniotico</b></a>
          </li>
          <li role="presentation" class="<%=active3%>">
            <a href="#tactos" aria-controls="tactos" role="tab" data-toggle="tab"><b>Tactos</b></a>
          </li>
          <li role="presentation" class="<%=active4%>">
            <a href="#parto_normal" aria-controls="parto_normal" role="tab" data-toggle="tab"><b>Parto Normal</b></a>
          </li>
          <li role="presentation" class="<%=active5%>">
            <a href="#parto_instrumental" aria-controls="parto_instrumental" role="tab" data-toggle="tab"><b>Parto Instrumental</b></a>
          </li>
          <li role="presentation" class="<%=active6%>">
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
         <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
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
                    <jsp:param name="valueOfTBox1" value="<%=Historia.getFecha()%>" />
                    </jsp:include>
                </td>

                <td align="right"> <cellbytelabel id="3">M&eacute;dico</cellbytelabel></td>
                <td class="controls form-inline">
                    <%=fb.textBox("codMedico",Historia.getMedico(),true,false,true,5,"form-control input-sm",null,null)%>
                    <%=fb.textBox("nombre_medico",Historia.getNombreMedico(),false,true,true,25,"form-control input-sm",null,null)%>
                    <%=fb.button("medico","...",true,viewMode,null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
                </td>
			</tr>
			</tbody>

            <tr class="bg-headtabla">
                <td colspan="4"><cellbytelabel id="4">DATOS GENERALES</cellbytelabel></td>
			</tr>

            <tbody>
            <tr>
                <td width="20%" align="right"><cellbytelabel id="5">Fecha &Uacute;ltima Menstruaci&oacute;n</cellbytelabel> </td>
                <td width="20%" class="controls form-inline">
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="ultimaRegla" />
                    <jsp:param name="valueOfTBox1" value="<%=Historia.getFechaUR()%>" />
                    </jsp:include>
                </td>
                <td width="20%" align="right"><cellbytelabel id="6">Edad Gestacional</cellbytelabel></td>
                <td width="40%" class="controls form-inline"><%=fb.intBox("edadGestacional",Historia.getEdadGesta(),false,false,viewMode,5,2,"form-control input-sm",null,null)%><cellbytelabel id="7">Semanas</cellbytelabel>  </td>
            </tr>
            </tbody>

            <tbody>
            <tr>
                <td colspan="2" align="right"><cellbytelabel id="8">No. de controles Pre-natales</cellbytelabel></td>
                <td colspan="2"><%=fb.intBox("nControl",Historia.getControlPrenatal(),false,false,viewMode,5,2,"form-control input-sm",null,null)%></td>
            </tr>
            </tbody>

            <tbody>
            <tr>
                <td colspan="2" align="right"><cellbytelabel id="8">Tipo Sangre</cellbytelabel></td>
                <td colspan="2">
                    <%=fb.select(ConMgr.getConnection(),"select ' ', '-SELECCIONE-' from dual union all select tipo_sangre, tipo_sangre from tbl_bds_tipo_sangre order by 1","tipo_sangre", Historia.getTipoSangre(), false, viewMode,0,"form-control input-sm",null,null)%>
                </td>
            </tr>
            </tbody>

            <tbody>
            <tr>
                <td colspan="2" align="right"><cellbytelabel id="8">Presi&oacute;n Arterial</cellbytelabel></td>
                <td colspan="2" class="controls form-inline"><%=fb.textBox("presion_arterial", Historia.getPresionArterial(),false,false,viewMode,5,10,"form-control input-sm",null,null)%></td>
            </tr>
            </tbody>

            <tr class="bg-headtabla" >
                <td colspan="4"><cellbytelabel id="9">PARIDAD</cellbytelabel></td>
            </tr>

            <tbody>
                <tr>
                    <td width="15%" align="right"><cellbytelabel id="10">Gestaci&oacute;n</cellbytelabel>	</td>
                    <td width="15%"><%=fb.intBox("gesta",Historia.getGesta(),false,false,viewMode,5,2,"form-control input-sm",null,null)%>	</td>
                    <td align="right"><cellbytelabel id="11">Para</cellbytelabel></td>
                    <td><%=fb.intBox("para",Historia.getPara(),false,false,viewMode,5,2,"form-control input-sm",null,null)%>	</td>
                 </tr>
            </tbody>

            <tbody>
                <tr>
                    <td align="right"><cellbytelabel id="12">Aborto</cellbytelabel></td>
                    <td><%=fb.intBox("aborto",Historia.getAborto(),false,false,viewMode,5,2,"form-control input-sm",null,null)%>	</td>
                    <td align="right"><cellbytelabel id="13">Ces&aacute;rea</cellbytelabel></td>
                    <td><%=fb.intBox("cesarea",Historia.getCesarea(),false,false,viewMode,5,2,"form-control input-sm",null,null)%>	</td>
                </tr>
            </tbody>

            <tr class="bg-headtabla">
				<td colspan="4"><cellbytelabel id="14">EMBARAZO</cellbytelabel></td>
			</tr>

            <tbody>
            <tr>
                 <td><label class="pointer"><%=fb.radio("embarazo","S",(Historia.getEmbarazo().equals("S")),viewMode,false,null,null,"onClick=\"javascript:verOcult(2)\"")%><cellbytelabel id="15">Simple</cellbytelabel>&nbsp;&nbsp;</label></td>
                 <td><label class="pointer"><%=fb.radio("embarazo","M",(Historia.getEmbarazo().equals("M")),viewMode,false,null,null,"onClick=\"javascript:verOcult(1)\"")%><cellbytelabel id="16">M&uacute;ltiple</cellbytelabel></label></td>
                 <td colspan="2" class="controls form-inline"><cellbytelabel id="17">Cantidad</cellbytelabel>:&nbsp;&nbsp;<%=fb.intBox("cantidadHijo",Historia.getNumeroHijo(),false,(Historia.getEmbarazo().equals("S") || viewMode),(Historia.getEmbarazo().equals("S") || viewMode),5,2)%>
                 </td>
            </tr>
            </tbody>

            <tr class="bg-headtabla" >
                <td colspan="4"><cellbytelabel id="18">TRABAJO DE PARTO</cellbytelabel></td>
            </tr>

            <tbody>
            <tr>
                <td><label class="pointer"><%=fb.radio("tParto","E",(Historia.getTrabajoParto().equals("E")),viewMode,false)%><cellbytelabel id="19">Espont&aacute;neo</cellbytelabel></label></td>
                <td><label class="pointer"><%=fb.radio("tParto","I",(Historia.getTrabajoParto().equals("I")),viewMode,false)%>Inducido</label></td>
                <td colspan="2" class="controls form-inline">
                    <cellbytelabel id="2">Fecha</cellbytelabel>:&nbsp;
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fechaIni" />
                    <jsp:param name="valueOfTBox1" value="<%=Historia.getFechaIni()%>" />
                    </jsp:include>
                    <cellbytelabel id="20">Hora</cellbytelabel>:
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="format" value="hh12:mi:ss am" />
                    <jsp:param name="nameOfTBox1" value="horaIni" />
                    <jsp:param name="valueOfTBox1" value="<%=Historia.getHoraIni()%>" />
                    </jsp:include>
                </td>
            </tr>
            </tbody>

            <tr class="bg-headtabla" >
                <td colspan="4"><cellbytelabel id="21">RUPTURAS DE MEMBRANAS</cellbytelabel></td>
            </tr>

            <tbody>
            <tr>
                <td><label class="pointer"><%=fb.radio("Rupturas","E",(Historia.getRupturaMembrana().equals("E")),viewMode,false)%><cellbytelabel id="19">Espont&aacute;neo</cellbytelabel></label></td>
				<td><label class="pointer"><%=fb.radio("Rupturas","A",(Historia.getRupturaMembrana().equals("A")),viewMode,false)%><cellbytelabel id="22">Artificial</cellbytelabel></label> </td>
				<td colspan="2" class="controls form-inline">
                    <cellbytelabel id="2">Fecha</cellbytelabel>:&nbsp;
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fechaRuptura" />
                    <jsp:param name="valueOfTBox1" value="<%=Historia.getFechaRuptura()%>" />
                    </jsp:include>
                    <cellbytelabel id="23">Hora de Inicio</cellbytelabel>:
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="format" value="hh12:mi:ss am" />
                    <jsp:param name="nameOfTBox1" value="horaRuptura" />
                    <jsp:param name="valueOfTBox1" value="<%=Historia.getHoraRuptura()%>" />
                    </jsp:include>
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

      <!-- Datos Adicionales -->
      <div role="tabpanel" class="tab-pane <%=active1%>" id="datos_adicionales">

         <%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
         <%=fb.hidden("tab","1")%>
         <%=fb.hidden("cod_Historia",cod_Historia)%>
         <%=fb.hidden("tactosLastLineNo",""+tactosLastLineNo)%>
         <%=fb.hidden("size",""+iTactos.size())%>
         <%=fb.hidden("fecHis",Historia.getFecha())%>
         <%=fb.hidden("desc",desc)%>
         <table cellspacing="0" class="table table-small-font table-bordered">
            <tr class="bg-headtabla">
                <td colspan="7"> <cellbytelabel id="29">DATOS ADICIONALES</cellbytelabel></td>
            </tr>
            <tbody>
            <tr class="TextRow01">
                <td width="25%" align="right"><cellbytelabel id="30">Sensibilizaci&oacute;n</cellbytelabel></td>
                <td width="15%" align="center">Rh</td>
                <td width="5%">
                    <label class="pointer"><%=fb.radio("sensibilizacion_rh","S",(Historia.getSensibilizacionRh().equals("S")),viewMode,false)%>&nbsp;<cellbytelabel id="31">S&iacute;</cellbytelabel>&nbsp;</label><br>
                    <label class="pointer"><%=fb.radio("sensibilizacion_rh","N",(Historia.getSensibilizacionRh().equals("N")),viewMode,false)%>&nbsp;<cellbytelabel id="32">No</cellbytelabel>&nbsp;</label>
                </td>
                <td width="15%" align="center"><cellbytelabel id="33">ABO</cellbytelabel></td>
                <td width="5%">
                    <label class="pointer"><%=fb.radio("sensibilizacion_abo","S",(Historia.getSensibilizacionAbo().equals("S")),viewMode,false)%>&nbsp;<cellbytelabel id="31">S&iacute;</cellbytelabel>&nbsp;</label><br>
                    <label class="pointer"><%=fb.radio("sensibilizacion_abo","N",(Historia.getSensibilizacionAbo().equals("N")),viewMode,false)%>&nbsp;<cellbytelabel id="32">No</cellbytelabel>&nbsp;</label>
                </td>
                <td width="20%" align="right"><cellbytelabel id="34">Serolog&iacute;a - LUES</cellbytelabel></td>
                <td width="20%">
                    <label class="pointer"><%=fb.radio("serologia_lues","S",(Historia.getSerologiaLues().equals("S")),viewMode,false)%>&nbsp;<cellbytelabel id="35">Positivo</cellbytelabel>&nbsp;</label>
                    <label class="pointer"><%=fb.radio("serologia_lues","N",(Historia.getSerologiaLues().equals("N")),viewMode,false)%>&nbsp;<cellbytelabel id="36">Negativo</cellbytelabel>&nbsp;</label>
                </td>
            </tr>
            </tbody>

            <tbody>
                 <tr>
                    <td width="15%" align="right" valign=middle><cellbytelabel id="37">Patolog&iacute;a</cellbytelabel></td>
                    <td width="5%"><%=fb.radio("patologia","N",(Historia.getPatologia().equals("N")),viewMode,false)%>&nbsp;<cellbytelabel id="32">No</cellbytelabel>&nbsp;</td>
                    <td width="5%"><%=fb.radio("patologia","S",(Historia.getPatologia().equals("S")),viewMode,false)%>&nbsp;<cellbytelabel id="31">S&iacute;</cellbytelabel>&nbsp;</td>
                    <td width="75%" colspan="4"><cellbytelabel id="38">Especificar</cellbytelabel>:&nbsp;<%=fb.textarea("patologia_espec",Historia.getPatologiaEspec(),false,false,viewMode,60,1,1000,"form-control input-sm","width:100%","")%></td>
                 </tr>
            </tbody>

         <tbody>
             <tr>
                <td width="15%" align="right" valign=middle><cellbytelabel id="39">Electroforesis HB</cellbytelabel></td>
                <td width="55%" colspan="4"><%=fb.textBox("electroforesis_hb",Historia.getElectroforesisHb(),false,false,viewMode,30,50,"form-control input-sm",null,null)%></td>
                <td width="15%" colspan="2" class="controls form-inline"><cellbytelabel id="40">Toxoplasmosis</cellbytelabel>:&nbsp;<%=fb.textBox("toxoplasmosis",Historia.getToxoplasmosis(),false,false,viewMode,30,50,"form-control input-sm",null,null)%></td>
             </tr>
         </tbody>

         <tbody>
             <tr>
                <td width="15%" align="right" valign="middle"><cellbytelabel id="41">Patolog&iacute;a en hijos anteriores</cellbytelabel></td>
                <td width="5%"><%=fb.radio("patologia_hijos_ant","N",(Historia.getPatologiaHijosAnt().equals("N")),viewMode,false)%>&nbsp;<cellbytelabel id="32">No</cellbytelabel>&nbsp;</td>
                <td width="5%"><%=fb.radio("patologia_hijos_ant","S",(Historia.getPatologiaHijosAnt().equals("S")),viewMode,false)%>&nbsp;<cellbytelabel id="31">S&iacute;</cellbytelabel>&nbsp;</td>
                <td width="75%" colspan="4"><cellbytelabel id="38">Especificar</cellbytelabel>:&nbsp;<%=fb.textarea("patologia_hijos_ant_espec",Historia.getPatologiaHijosAntEspec(),false,false,viewMode,60,1,1000,"form-control input-sm","width:100%","")%></td>
             </tr>
         </tbody>

        <tbody>
        <tr>
            <td width="15%" align="right" valign="middle"><cellbytelabel id="42">Anomal&iacute;as cong&eacute;nitas en hijos anteriores</cellbytelabel></td>
            <td width="5%"><%=fb.radio("anomalia_congenita","N",(Historia.getAnomaliaCongenita().equals("N")),viewMode,false)%>&nbsp;<cellbytelabel id="32">No</cellbytelabel>&nbsp;</td>
            <td width="5%"><%=fb.radio("anomalia_congenita","S",(Historia.getAnomaliaCongenita().equals("S")),viewMode,false)%>&nbsp;<cellbytelabel id="31">S&iacute;</cellbytelabel>&nbsp;</td>
            <td width="75%" colspan="4"><cellbytelabel id="38">Especificar</cellbytelabel>:&nbsp;<%=fb.textarea("anomalia_cong_especificar",Historia.getAnomaliaCongEspecificar(),false,false,viewMode,60,1,1000,"form-control input-sm","width:100%","")%></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td width="15%" align="right" valign="middle"><cellbytelabel id="43">Ecograf&iacute;a</cellbytelabel></td>
            <td width="5%" colspan="2"><%=fb.radio("ecografia","N",(Historia.getEcografia().equals("N")),viewMode,false)%>&nbsp;<cellbytelabel id="44">Normal</cellbytelabel>&nbsp;</td>
            <td width="5%" colspan="4"><%=fb.radio("ecografia","A",(Historia.getEcografia().equals("A")),viewMode,false)%>&nbsp;<cellbytelabel id="45">Anormal</cellbytelabel>&nbsp;</td>
            <!--<td width="15%" align="right"><cellbytelabel id="46">Horas Labor</cellbytelabel></td>
            <td width="5%" ><%//=fb.textBox("horas_labor",Historia.getHorasLabor(),false,false,viewMode,10,10,"form-control input-sm",null,null)%></td>-->
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td width="15%" align="right" valign="middle"><cellbytelabel id="47">Monitoreo</cellbytelabel></td>
            <td width="5%"><%=fb.radio("monitoreo","N",(Historia.getMonitoreo().equals("N")),viewMode,false)%>&nbsp;<cellbytelabel id="32">No</cellbytelabel>&nbsp;</td>
            <td width="5%"><%=fb.radio("monitoreo","S",(Historia.getMonitoreo().equals("S")),viewMode,false)%>&nbsp;<cellbytelabel id="31">S&iacute;</cellbytelabel>&nbsp;</td>
            <td width="15%" align="right" colspan="4">&nbsp;</td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td width="15%" align="right" valign="middle"><cellbytelabel id="47">Signos de Sufrimiento Fetal</cellbytelabel></td>
            <td width="5%"><%=fb.radio("signo_sufrimiento_fetal","N",(Historia.getSignoSufrimientoFetal().equals("N")),viewMode,false)%>&nbsp;<cellbytelabel id="32">No</cellbytelabel>&nbsp;</td>
            <td width="5%"><%=fb.radio("signo_sufrimiento_fetal","S",(Historia.getSignoSufrimientoFetal().equals("S")),viewMode,false)%>&nbsp;<cellbytelabel id="31">S&iacute;</cellbytelabel>&nbsp;</td>
            <td width="5%" colspan="2"><%=fb.radio("signo_sufrimiento_fetal","I",(Historia.getSignoSufrimientoFetal().equals("I")),viewMode,false)%>&nbsp;<cellbytelabel id="48">Ignorado</cellbytelabel>&nbsp;</td>
            <td width="10%" align="right" colspan="2">&nbsp;</td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td width="15%" align="right" valign="middle"><cellbytelabel id="49">Causas intervenci&oacute;n</cellbytelabel></td>
            <td width="80%" colspan="6"><%=fb.textarea("causas_intervencion",Historia.getCausasIntervencion(),false,false,viewMode,60,1,1000,"form-control input-sm","width:100%","")%></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td width="15%" align="right" valign="middle"><cellbytelabel id="50">Drogas</cellbytelabel> </td>
            <td width="5%"><%=fb.radio("drogas","N",(Historia.getDrogas().equals("N")),viewMode,false)%>&nbsp;<cellbytelabel id="32">No</cellbytelabel>&nbsp;</td>
            <td width="5%"><%=fb.radio("drogas","S",(Historia.getDrogas().equals("S")),viewMode,false)%>&nbsp;<cellbytelabel id="31">S&iacute;</cellbytelabel>&nbsp;</td>
            <td width="15%" align="right" colspan="2"><cellbytelabel id="51">Drogas Nombre</cellbytelabel></td>
            <td width="5%" colspan="2"><%=fb.textBox("drogas_nombre",Historia.getDrogasNombre(),false,false,viewMode,50,40,"form-control input-sm",null,null)%></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td width="15%" align="right" valign="middle" colspan="5"><cellbytelabel id="52">Tiempo anteparto dosis</cellbytelabel> </td>
            <td colspan="2"><%=fb.textBox("drogas_tiempo_anteparto_dosis",Historia.getDrogasTiempoAntepartoDosis(),false,false,viewMode,50,40,"form-control input-sm",null,null)%></td>
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
      </div> <!-- Datos Adicionales -->

      <!-- Liquido Amniotico -->
      <div role="tabpanel" class="tab-pane <%=active2%>" id="liquido_amniotico">
        <%fb = new FormBean2("form2",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
        <%=fb.hidden("cod_Historia",cod_Historia)%>
        <%=fb.hidden("tactosLastLineNo",""+tactosLastLineNo)%>
        <%=fb.hidden("size",""+iTactos.size())%>
        <%=fb.hidden("fecHis",Historia.getFecha())%>
        <%=fb.hidden("desc",desc)%>

        <table cellspacing="0" class="table table-small-font table-bordered">
            <tr class="bg-headtabla">
                <td colspan="4"><cellbytelabel id="53">LIQUIDO AMNIOTICOS</cellbytelabel></td>
            </tr>

            <tbody>
            <tr>
                <td width="25%" align="right"><cellbytelabel id="17">Cantidad</cellbytelabel></td>
                <td colspan="3">
                <%=fb.radio("cantidad","E",(Historia.getCantidadLiquido().equals("E")),viewMode,false)%>Escaso
                <%=fb.radio("cantidad","N",(Historia.getCantidadLiquido().equals("N")),viewMode,false)%><cellbytelabel id="44">Normal</cellbytelabel>
                <%=fb.radio("cantidad","A",(Historia.getCantidadLiquido().equals("A")),viewMode,false)%>Abundante  </td>
            </tr>
            </tbody>

            <tbody>
            <tr>
                <td valign="middle" width="25%" align="right"><cellbytelabel id="54">Aspecto</cellbytelabel></td>
                <td width="25%">
                <%=fb.radio("aspecto","CS",(Historia.getAspectoLiquido().equals("CS")),viewMode,false)%><cellbytelabel id="55">Claro: Sin grumos</cellbytelabel><br>
                <%=fb.radio("aspecto","CC",(Historia.getAspectoLiquido().equals("CC")),viewMode,false)%><cellbytelabel id="56">Claro: Com grumos</cellbytelabel><br>
                <%=fb.radio("aspecto","HM",(Historia.getAspectoLiquido().equals("HM")),viewMode,false)%><cellbytelabel id="57">Hem&aacute;tico: Leve</cellbytelabel> </td>
                <td  width="25%">
                <%=fb.radio("aspecto","HE",(Historia.getAspectoLiquido().equals("HE")),viewMode,false)%><cellbytelabel id="58">Hemorr&aacute;gico</cellbytelabel><br>
                <%=fb.radio("aspecto","PU",(Historia.getAspectoLiquido().equals("PU")),viewMode,false)%><cellbytelabel id="59">Purulento</cellbytelabel><br>
                <%=fb.radio("aspecto","MF",(Historia.getAspectoLiquido().equals("MF")),viewMode,false)%><cellbytelabel id="60">Meconial Flu&iacute;do</cellbytelabel>  </td>
                <td width="25%">
                <%=fb.radio("aspecto","ME",(Historia.getAspectoLiquido().equals("ME")),viewMode,false)%><cellbytelabel id="61">Meconial Espeso</cellbytelabel><br>
                <%=fb.radio("aspecto","AR",(Historia.getAspectoLiquido().equals("AR")),viewMode,false)%><cellbytelabel id="62">Amarillo</cellbytelabel><br>
                <%=fb.radio("aspecto","OS",(Historia.getAspectoLiquido().equals("OS")),viewMode,false)%><cellbytelabel id="63">Oscuro</cellbytelabel>  </td>
            </tr>
            </tbody>

            <tr class="bg-headtabla">
                <td colspan="4"><cellbytelabel id="64">FECHA Y HORA DE PARTO</cellbytelabel></td>
            </tr>

            <tbody>
            <tr>
                <td colspan="2" align="center" class="controls form-inline"><cellbytelabel id="65">Fecha Parto</cellbytelabel>:
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fechaParto" />
                    <jsp:param name="valueOfTBox1" value="<%=Historia.getFechaParto()%>" />
                    </jsp:include>
                </td>
                <td colspan="2" class="controls form-inline"><cellbytelabel id="66">Hora Parto</cellbytelabel>:
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="format" value="hh12:mi:ss am" />
                    <jsp:param name="nameOfTBox1" value="horaParto" />
                    <jsp:param name="valueOfTBox1" value="<%=Historia.getHoraParto()%>" />
                    </jsp:include>
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
      </div> <!-- Liquido Amniotico -->

      <!-- Tactos -->
      <div role="tabpanel" class="tab-pane <%=active3%>" id="tactos">
         <%fb = new FormBean2("form3",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
         <%=fb.hidden("tab","3")%>
         <%=fb.hidden("size",""+iTactos.size())%>
         <%=fb.hidden("tactosLastLineNo",""+tactosLastLineNo)%>
         <%=fb.hidden("cod_Historia",cod_Historia)%>
         <%=fb.hidden("fecHis",Historia.getFecha())%>
         <%=fb.hidden("desc",desc)%>
        <table cellspacing="0" class="table table-small-font table-bordered">
            <tr>
                <td colspan="11">
                    <table width="100%" cellpadding="1" cellspacing="1" >
                        <tr class="bg-headtabla" align="center">
                            <td width="50%"><cellbytelabel id="69">OBSERVACION</cellbytelabel></td>
                            <td width="50%"><cellbytelabel id="70">TRATAMIENTO</cellbytelabel></td>
                        </tr>
                        <tr>
                            <td><%=fb.textarea("observacion",Historia.getObservaTratamiento(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
                            <td><%=fb.textarea("tratamiento",Historia.getTratamiento(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr class="bg-headtabla2" align="center">
                <td width="12%"><cellbytelabel>DIA</cellbytelabel></td>
                <td width="13%"><cellbytelabel>HORA</cellbytelabel></td>
                <td width="12%"> <cellbytelabel>DILATACION</cellbytelabel></td>
                <td width="12%"><cellbytelabel>BORRAMIENTO</cellbytelabel></td>
                <td width="8%"><cellbytelabel>PRENTAC</cellbytelabel></td>
                <td width="8%"><cellbytelabel>POSICION</cellbytelabel></td>
                <td width="5%"><cellbytelabel>PLANOS</cellbytelabel></td>

                <td width="5%"><cellbytelabel>P/A</cellbytelabel></td>

                <td width="9%"><cellbytelabel>FOCO FETAL</cellbytelabel></td>
                <td width="13%"><cellbytelabel>CONTRACCION</cellbytelabel></td>

                <td width="3%"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value);\"","Agregar Tactos")%></td>
            </tr>
            <%
                String motivoCesarea = "", tipoParto = "";
                al.clear();
                al = CmnMgr.reverseRecords(iTactos);

                for (int i = 1; i <= iTactos.size(); i++){

                    key = al.get(i - 1).toString();
                    DetalleHistoria newTactos =  (DetalleHistoria) iTactos.get(key);

                    tipoParto = newTactos.getTipoParto();
                    motivoCesarea = newTactos.getMotivoCesarea();
            %>
                    <%=fb.hidden("sec"+i,newTactos.getSecuencia())%>
                    <%=fb.hidden("fechaHist"+i,newTactos.getFechaHist())%>
                    <%=fb.hidden("remove"+i,"")%>
                    <%=fb.hidden("key"+i,key)%>
                    <tbody>
					<tr class="controls form-inline" align="center">
                        <td>
                            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1" />
                            <jsp:param name="clearOption" value="true" />
                            <jsp:param name="nameOfTBox1" value="<%="dias"+i%>" />
                            <jsp:param name="valueOfTBox1" value="<%=newTactos.getFecha()%>" />
                            <jsp:param name="fieldClass" value="fechas_tactos" />
                            </jsp:include>
                        </td>
                        <td class="controls form-inline">
                            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="1"/>
                            <jsp:param name="format" value="hh12:mi:ss am"/>
                            <jsp:param name="nameOfTBox1" value="<%="horas"+i%>" />
                            <jsp:param name="valueOfTBox1" value="<%=newTactos.getHora()%>" />
                            <jsp:param name="fieldClass" value="horas_tactos" />
                            </jsp:include>
                        </td>
                        <td><%=fb.textBox("cuello"+i,newTactos.getCuelloDilata(),false,false,viewMode,8,10,"form-control input-sm",null,null)%></td>
                        <td><%=fb.textBox("segmento"+i,newTactos.getSegInf(),false,false,viewMode,8,10,"form-control input-sm",null,null)%></td>
                        <td><%=fb.textBox("prentac"+i,newTactos.getPrePosPlan(),false,false,viewMode,4,10,"form-control input-sm",null,null)%></td>
                        <td><%=fb.textBox("posicion"+i,newTactos.getPosicion(),false,false,viewMode,4,10,"form-control input-sm",null,null)%></td>
                        <td><%=fb.textBox("plano"+i,newTactos.getPlano(),false,false,viewMode,4,10,"form-control input-sm",null,null)%></td>
                        <td><%=fb.textBox("presion_arterial"+i,newTactos.getPresionArterial(),false,false,viewMode,4,10,"form-control input-sm",null,null)%></td>
                        <td><%=fb.textBox("foco"+i,newTactos.getFocoFetal(),false,false,viewMode,4,10,"form-control input-sm",null,null)%></td>
                        <td><%=fb.textBox("funcion"+i,newTactos.getFuncContrac(),false,false,viewMode,8,10,"form-control input-sm",null,null)%></td>
                        <td rowspan="2"><%=fb.submit("rem"+i,"x",false,viewMode,null,null,"onClick=\"removeItem(this.form.name,"+i+"); __submitForm(this.form, this.value)\"","Eliminar")%>
                        </td>
                    </tr>
                    <tr>
                        <td><cellbytelabel id="80">Membrana</cellbytelabel> <%=fb.textBox("membrana"+i,newTactos.getMembr(),false,false,viewMode,8,10,"form-control input-sm",null,null)%></td>
                        <td><cellbytelabel id="81">Temperatura</cellbytelabel><%=fb.textBox("temp"+i,newTactos.getTemp(),false,false,viewMode,8,10,"form-control input-sm",null,null)%></td>
                        <td colspan="8"><cellbytelabel id="82">Observaci&oacute;n</cellbytelabel><%=fb.textarea("observacion_tacto"+i,newTactos.getObservacion(),false,false,viewMode,60,1,2000,"form-control input-sm","width:100%","")%></td>
                    </tr>
                    </tbody>
                <%}%>

                <tr class="bg-headtabla">
                    <td colspan="11">TIPO DE PARTO</td>
                </tr>
                <tr>
                    <td colspan="2">
                     <label class="pointer">
                        <%=fb.radio("tactos_tipo_parto","V",(tipoParto!=null&&tipoParto.equalsIgnoreCase("V")),viewMode,false)%>&nbsp;<b>Vaginal</b>
                     </label>
                    </td>
                    <td colspan="2">
                        <label class="pointer">
                            <%=fb.radio("tactos_tipo_parto","C",(tipoParto!=null&&tipoParto.equalsIgnoreCase("C")),viewMode,false)%>&nbsp;<b>Ces&aacute;rea</b>
                         </label>
                    </td>
                    <td align="center"><b>Motivo</b></td>
                    <td colspan="6">
                    <%=fb.textarea("motivo_cesarea",motivoCesarea,false,false,true,60,1,0,"form-control input-sm","","")%></td>
                </tr>



        </table>
        <div class="footerform" style="bottom:-11px !important">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                <tr>
                    <td class="controls form-inline">

                    <span class="pull-left">
                    Horas de labor:&nbsp;
                    <%=fb.textBox("tactos_horas_labor","",false,false,true,10,10,"form-control input-sm",null,null)%>
                    </span>

                    <%=fb.hidden("saveOption","O")%>
                    <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
                </tr>
            </table>
         </div>
         <%=fb.formEnd(true)%>
      </div> <!-- Tactos -->

      <!-- Parto Normal -->
      <div role="tabpanel" class="tab-pane <%=active4%>" id="parto_normal">
        <%fb = new FormBean2("form4",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
         <%=fb.hidden("tab","4")%>
         <%=fb.hidden("cod_Historia",cod_Historia)%>
         <%=fb.hidden("tactosLastLineNo",""+tactosLastLineNo)%>
         <%=fb.hidden("size",""+iTactos.size())%>
         <%=fb.hidden("sizeMat",""+iMatDet.size())%>
         <%=fb.hidden("fecHis",Historia.getFecha())%>
         <%=fb.hidden("gen_alarma","")%>
         <%=fb.hidden("tot_alarma","")%>
         <% if (!Historia.getPresentacionParto().equals(" ") || !Historia.getEpisiotomia().equals(" ")   ){%>
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
                <td><%=fb.radio("part","V",(Historia.getPresentacionParto().equals("V")),viewMode,false)%>Vertice<br>
                <%=fb.radio("part","P",(Historia.getPresentacionParto().equals("P")),viewMode,false)%><cellbytelabel id="84">Pod&aacute;lica</cellbytelabel>
                </td>
                <td><%=fb.radio("part","C",(Historia.getPresentacionParto().equals("C")),viewMode,false)%>Cara<br>
                <%=fb.radio("part","B",(Historia.getPresentacionParto().equals("B")),viewMode,false)%><cellbytelabel id="85">Bregma</cellbytelabel>
                </td>
                <td><cellbytelabel id="82">Observaci&oacute;n</cellbytelabel><br></td>
                <td colspan="2"><%=fb.textarea("observacion_parto",Historia.getObservaPresentacion(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
            </tr>
            </tbody>

            <tr class="bg-headtabla">
                <td colspan="5"><cellbytelabel id="86">TIPO DE PARTO[Normal]</cellbytelabel></td>
            </tr>

            <tbody>
            <tr>
                <td align="right"><cellbytelabel id="87">Episiotomia</cellbytelabel></td>
                <td><%=fb.radio("episio","NO",(Historia.getEpisiotomia().equals("NO")),viewMode,false)%><cellbytelabel id="88">NO</cellbytelabel></td>
                <td><%=fb.radio("episio","ME",(Historia.getEpisiotomia().equals("ME")),viewMode,false)%><cellbytelabel id="89">Media</cellbytelabel></td>
                <td><%=fb.radio("episio","OD",(Historia.getEpisiotomia().equals("OD")),viewMode,false)%><cellbytelabel id="90">Oblicua Derecha</cellbytelabel></td>
                <td><%=fb.radio("episio","OI",(Historia.getEpisiotomia().equals("OI")),viewMode,false)%><cellbytelabel id="91">Oblicua Izquierda</cellbytelabel></td>
            </tr>
            </tbody>

            <tbody>
            <tr>
                <td align="right"><cellbytelabel id="92">Desgarro</cellbytelabel></td>
                <td colspan="4"><%=fb.select("episiorra","0=0°,1=1°,2=2°,3=3°,4=4°",Historia.getEpisografia())%></td>
            </tr>
            </tbody>

            <tr class="bg-headtabla">
                <td colspan="5"><cellbytelabel id="86">MATERIAL USADO</cellbytelabel></td>
            </tr>

            <%
            al.clear();
            al = CmnMgr.reverseRecords(iMatDet);
            for (int m = 1; m <= iMatDet.size(); m++){
                key = al.get(m - 1).toString();
                DetalleHistoria newMat =  (DetalleHistoria) iMatDet.get(key);
                if (newMat.getConteoInicial() == null) newMat.setConteoInicial("");
                if (newMat.getConteoFinal() == null) newMat.setConteoFinal("");
            %>
            <%=fb.hidden("gen_alarma"+m, "")%>
            <%=fb.hidden("descripcion_mat"+m, newMat.getDescripcionMat())%>
                <tbody>
                    <tr>
                        <td colspan="2" class="controls form-inline">
                            <label class="pointer">
                               <%=fb.checkbox("mat"+m, newMat.getValor(),(newMat.getConteoInicial()!=null && !newMat.getConteoInicial().trim().equals("")),viewMode,"",null,"onchange='manageConteo("+m+")'")%>&nbsp;
                               <%=newMat.getDescripcionMat()%>
                            </label>
                        </td>
                        <td colspan="3" class="controls form-inline">
                            Conteo Inicial:&nbsp;
                            <%=fb.intBox("conteo_inicial"+m, newMat.getConteoInicial(),false,false,(viewMode || newMat.getConteoInicial().equals("") ),8,3,"form-control input-sm",null,"")%>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            Conteo Final:&nbsp;
                            <%=fb.intBox("conteo_final"+m, newMat.getConteoFinal(),false,false,(viewMode || newMat.getConteoFinal().equals("")),8,3,"form-control input-sm",null,"")%>
                        </td>
                    </tr>
                </tbody>
            <%
             }
            %>

            <!--<tbody>
            <tr>
                <td align="right"><cellbytelabel id="93"></cellbytelabel></td>
                <td colspan="4" class="controls form-inline">
                    <%=fb.select("material","Agujas=Agujas,Vendas=Vendas,Vendas=Gazas",Historia.getMaterialUsado(),false,viewMode,0,"form-control input-sm",null,"",null," ")%>
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
      <div role="tabpanel" class="tab-pane <%=active5%>" id="parto_instrumental">
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
        <%=fb.hidden("tab","5")%>
        <%=fb.hidden("cod_Historia",cod_Historia)%>
        <%=fb.hidden("tactosLastLineNo",""+tactosLastLineNo)%>
        <%=fb.hidden("size",""+iTactos.size())%>
        <%=fb.hidden("fecHis",Historia.getFecha())%>

        <% if (!Historia.getTipoInstrumento().equals(" ") || !Historia.getIndicacion().equals(" ")   ){%>
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
            <td width="18%"><%=fb.radio("instruments","E",(Historia.getTipoInstrumento().equals("E")),viewMode,false)%><cellbytelabel id="96">Vacuum Extractor</cellbytelabel></td>
            <td width="20%"><%=fb.radio("instruments","F",(Historia.getTipoInstrumento().equals("F")),viewMode,false)%><cellbytelabel id="97">Forceps</cellbytelabel></td>
            <td width="20%" class="controls form-inline"><cellbytelabel id="98">Forceps I</cellbytelabel> <%=fb.textBox("forceps1",Historia.getForcep1(),false,false,viewMode,8,50,"form-control input-sm", null,null)%></td>
            <td width="20%" class="controls form-inline"><cellbytelabel id="99">Forceps II</cellbytelabel> <%=fb.textBox("forceps2",Historia.getForcep2(),false,false,viewMode,8,50,"form-control input-sm", null,null)%></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td align="right"><cellbytelabel id="100">Indicaci&oacute;n</cellbytelabel></td>
            <td><%=fb.radio("indic","PF",(Historia.getIndicacion().equals("PF")),viewMode,false)%><cellbytelabel id="101">Profil&aacute;ctico</cellbytelabel></td>
            <td><%=fb.radio("indic","DR",(Historia.getIndicacion().equals("DR")),viewMode,false)%><cellbytelabel id="102">Distocia de Rotaci&oacute;n</cellbytelabel></td>
            <td><%=fb.radio("indic","DM",(Historia.getIndicacion().equals("DM")),viewMode,false)%><cellbytelabel id="103">Arresto del Descenso</cellbytelabel></td>
            <td><%=fb.radio("indic","CU",(Historia.getIndicacion().equals("CU")),viewMode,false)%><cellbytelabel id="104">Cabeza Ultima</cellbytelabel></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td align="right"><cellbytelabel id="105">Otros</cellbytelabel></td>
            <td colspan="4"><%=fb.textarea("otros",Historia.getOtras(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td align="right"><cellbytelabel id="106">Variedad de la posici&oacute;n</cellbytelabel></td>
            <td colspan="4"><%=fb.textarea("variedad",Historia.getVariedadPosicion(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
        <td colspan="5">
        <table cellpadding="1" cellspacing="1" width="100%">
            <tr class="TextRow01">
               <td width="50%"><cellbytelabel id="107">Nivel de la Presentaci&oacute;n</cellbytelabel><br>
               <%=fb.textarea("nivel",Historia.getNivelPresenta(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
                <td width="50%"><cellbytelabel id="108">Plano</cellbytelabel><br>
                <%=fb.textarea("plano_present",Historia.getPlano(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
            </tr>
        </table>
        </td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td width="20%" align="right"><cellbytelabel id="109">Otras Maniobras</cellbytelabel></td>
            <td width="20%"><%=fb.radio("maniobras","K",(Historia.getTipoForcep().equals("K")),viewMode,false)%><cellbytelabel id="110">Kristeller</cellbytelabel></td>
            <td width="20%"><%=fb.radio("maniobras","M",(Historia.getTipoForcep().equals("M")),viewMode,false)%><cellbytelabel id="111">Moriceaux</cellbytelabel></td>
            <td width="20%"><%=fb.radio("maniobras","B",(Historia.getTipoForcep().equals("B")),viewMode,false)%><cellbytelabel id="112">Bracht</cellbytelabel></td>
            <td width="20%"><%=fb.radio("maniobras","R",(Historia.getTipoForcep().equals("R")),viewMode,false)%><cellbytelabel id="113">Rojas</cellbytelabel></td>
        </tr>
        </tbody>

        <tbody>
        <tr>
            <td align="right"><cellbytelabel id="114">Expl&iacute;que</cellbytelabel></td>
            <td colspan="4"><%=fb.textarea("explique",Historia.getManiobras(),false,false,viewMode,60,1,2000,"form-control inpit-sm","width:100%","")%></td>
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
      <div role="tabpanel" class="tab-pane <%=active6%>" id="anestesia">
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
         <%=fb.hidden("tab","6")%>
         <%=fb.hidden("cod_Historia",cod_Historia)%>
         <%=fb.hidden("tactosLastLineNo",""+tactosLastLineNo)%>
         <%=fb.hidden("size",""+iTactos.size())%>
         <%=fb.hidden("fecHis",Historia.getFecha())%>
         <table cellspacing="0" class="table table-small-font table-bordered">

             <tr class="bg-headtabla">
                <td colspan="5"><cellbytelabel id="115">ANESTESIA</cellbytelabel></td>
             </tr>

            <tr>
                <td width="10%"><label class="pointer"><%=fb.radio("anestesia","S",(Historia.getTipoAnestesia().equals("S")),viewMode,false,null,null,"onClick=\"javascript:verOcult(3)\"")%><cellbytelabel id="116">SI</cellbytelabel></label></td>
                <td width="10%"><label class="pointer"><%=fb.radio("anestesia","N",(Historia.getTipoAnestesia().equals("N")),viewMode,false,null,null,"onClick=\"javascript:verOcult(4)\"")%><cellbytelabel id="88">NO</cellbytelabel></label></td>
                 <td width="25%" colspan="3" class="controls form-inline">Anestesia&nbsp;&nbsp; <%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo, codigo FROM TBL_SAL_TIPO_ANESTESIA ORDER BY 1","codAnest",Historia.getCodAnestesia(),false,(Historia.getTipoAnestesia().equals("N") || viewMode),0,"form-control",null,null)%></td>
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
				HistoriaObstetricaI hist = new  HistoriaObstetricaI();
				hist.setPacId(request.getParameter("pacId"));
				hist.setFecNacimiento(request.getParameter("dob"));
				hist.setCodPaciente(request.getParameter("codPac"));
				hist.setCodigo(request.getParameter("cod_Historia"));
				hist.setFecha(request.getParameter("fecha"));
				hist.setFechaUR(request.getParameter("ultimaRegla"));
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
				hist.setFechaIni(request.getParameter("fechaIni"));
				hist.setHoraIni(request.getParameter("horaIni"));
				hist.setRupturaMembrana(request.getParameter("Rupturas"));
				hist.setFechaRuptura(request.getParameter("fechaRuptura"));
				hist.setHoraRuptura(request.getParameter("horaRuptura"));
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

								HOIMgr.add(hist,"0");
								//cod_Historia = HOIMgr.getPkColValue("codigo");
						}
						else if (modeSec.equalsIgnoreCase("edit"))
						{
								HOIMgr.update(hist,"0");
						}
								ConMgr.clearAppCtx(null);
				}
	}
	if(tab.equals("1")) //
			{
						HistoriaObstetricaI hist = new  HistoriaObstetricaI();
						hist.setPacId(request.getParameter("pacId"));
						hist.setFecNacimiento(request.getParameter("dob"));
						hist.setCodPaciente(request.getParameter("codPac"));
						hist.setCodigo(request.getParameter("cod_Historia"));
						hist.setFecha(request.getParameter("fecHis"));
						hist.setSerologiaLues(request.getParameter("serologia_lues"));
						hist.setAnomaliaCongenita(request.getParameter("anomalia_congenita"));
						hist.setAnomaliaCongEspecificar(request.getParameter("anomalia_cong_especificar"));
						hist.setSensibilizacionRh(request.getParameter("sensibilizacion_rh"));
						hist.setSensibilizacionAbo(request.getParameter("sensibilizacion_abo"));
						hist.setPatologiaHijosAnt(request.getParameter("patologia_hijos_ant"));
						hist.setPatologiaHijosAntEspec(request.getParameter("patologia_hijos_ant_espec"));
						hist.setElectroforesisHb(request.getParameter("electroforesis_hb"));
						hist.setToxoplasmosis(request.getParameter("toxoplasmosis"));
						hist.setHorasLabor(request.getParameter("horas_labor"));
						hist.setSignoSufrimientoFetal(request.getParameter("signo_sufrimiento_fetal"));
						hist.setMonitoreo(request.getParameter("monitoreo"));
						hist.setCausasIntervencion(request.getParameter("causas_intervencion"));
						hist.setEcografia(request.getParameter("ecografia"));
						hist.setDrogas(request.getParameter("drogas"));
						hist.setDrogasNombre(request.getParameter("drogas_nombre"));
						hist.setDrogasTiempoAntepartoDosis(request.getParameter("drogas_tiempo_anteparto_dosis"));
						hist.setPatologia(request.getParameter("patologia"));
						hist.setPatologiaEspec(request.getParameter("patologia_espec"));


						if (baction.equalsIgnoreCase("Guardar"))
						 {
									ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
									if (modeSec.equalsIgnoreCase("edit"))
									{
											HOIMgr.update(hist,"1");
									}
									ConMgr.clearAppCtx(null);
						 }
			}


			if(tab.equals("2")) //
			{
						 HistoriaObstetricaI hist = new  HistoriaObstetricaI();
						 hist.setPacId(request.getParameter("pacId"));
						 hist.setFecNacimiento(request.getParameter("dob"));
						 hist.setCodPaciente(request.getParameter("codPac"));
						 hist.setCodigo(request.getParameter("cod_Historia"));
						 hist.setFecha(request.getParameter("fecHis"));
						 hist.setCantidadLiquido(request.getParameter("cantidad"));
						 hist.setAspectoLiquido(request.getParameter("aspecto"));
						 hist.setFechaParto(request.getParameter("fechaParto"));
						 hist.setHoraParto(request.getParameter("horaParto"));
						 // hist.setFormaTerminacion(request.getParameter("formaTerminacion"));
						 if (baction.equalsIgnoreCase("Guardar"))
						 {
											ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
									if (modeSec.equalsIgnoreCase("edit"))
									{
											HOIMgr.update(hist,"2");
									}
											ConMgr.clearAppCtx(null);
						 }


			}
			if(tab.equals("3")) //
			{
						int size = 0;
						al.clear();
						if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
						String itemRemoved = "";
						HistoriaObstetricaI hist = new  HistoriaObstetricaI();
						hist.setObservaTratamiento(request.getParameter("observacion"));
						hist.setTratamiento(request.getParameter("tratamiento"));

						hist.setPacId(request.getParameter("pacId"));
						hist.setFecNacimiento(request.getParameter("dob"));
						hist.setCodPaciente(request.getParameter("codPac"));
						hist.setCodigo(request.getParameter("cod_Historia"));
						hist.setFecha(request.getParameter("fecHis"));
						for (int i=1; i<=size; i++)
						{
								DetalleHistoria detHist = new DetalleHistoria();
								detHist.setFecNacimiento(request.getParameter("dob"));
								detHist.setCodPaciente(request.getParameter("codPac"));
								detHist.setPacId(request.getParameter("pacId"));
								detHist.setFechaHist(request.getParameter("fecHis"));
								detHist.setCodHist(request.getParameter("cod_historia"));
								detHist.setSecuencia(request.getParameter("sec"+i));

								detHist.setFecha(request.getParameter("dias"+i));
								detHist.setHora(request.getParameter("horas"+i));
								detHist.setCuelloDilata(request.getParameter("cuello"+i));
								detHist.setSegInf(request.getParameter("segmento"+i));
								detHist.setPrePosPlan(request.getParameter("prentac"+i));
								detHist.setFocoFetal(request.getParameter("foco"+i));
								detHist.setFuncContrac(request.getParameter("funcion"+i));
								detHist.setMembr(request.getParameter("membrana"+i));
								detHist.setTemp(request.getParameter("temp"+i));
								detHist.setObservacion(request.getParameter("observacion_tacto"+i));
								detHist.setPlano(request.getParameter("plano"+i));
								detHist.setPosicion(request.getParameter("posicion"+i));

								detHist.setPresionArterial(request.getParameter("presion_arterial"+i));
								detHist.setTipoParto(request.getParameter("tactos_tipo_parto"));
								detHist.setMotivoCesarea(request.getParameter("motivo_cesarea"));


								key = request.getParameter("key"+i);
								if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
								itemRemoved = key;
								else
								{
								 try
									{
										al.add(detHist);

										iTactos.put(key,detHist);
										hist.addDetalleHistoria(detHist);//addDetalleHistoria
									}
									catch(Exception e)
									{
										System.err.println(e.getMessage());
									}
								}//else
						}//for
		if(!itemRemoved.equals(""))
		{
			iTactos.remove(itemRemoved);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&modeSec="+modeSec+"&mode="+mode+"&tactosLastLineNo="+tactosLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cod_historia="+request.getParameter("cod_historia")+"&desc="+desc);
				return;
		}
		if(baction.equals("+"))//Agregar
		{
				DetalleHistoria newDetHist = new DetalleHistoria();
						newDetHist.setFecha(CmnMgr.getCurrentDate("dd/mm/yyyy"));
						newDetHist.setHora(CmnMgr.getCurrentDate("hh12:mi:ss am"));
						newDetHist.setSecuencia("0");
						newDetHist.setCodHist(request.getParameter("cod_historia"));
						tactosLastLineNo++;
						if (tactosLastLineNo < 10) key = "00" + tactosLastLineNo;
						else if (tactosLastLineNo < 100) key = "0" + tactosLastLineNo;
						else key = "" + tactosLastLineNo;
						try
						{
							iTactos.put(key,newDetHist);
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
						response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&modeSec="+modeSec+"&mode="+mode+"&tactosLastLineNo="+tactosLastLineNo+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cod_historia="+request.getParameter("cod_historia")+"&desc="+desc);
				return;
		}

						if (baction.equalsIgnoreCase("Guardar"))
						 {
									ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
									if (modeSec.equalsIgnoreCase("edit"))
									{
											HOIMgr.update(hist,"3");
									}
									ConMgr.clearAppCtx(null);
						 }
			}
			if(tab.equals("4")) {
                int size = Integer.parseInt(request.getParameter("sizeMat") == null ? "0" : request.getParameter("sizeMat"));
                al.clear();

                HistoriaObstetricaI hist = new  HistoriaObstetricaI();
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

                for (int i=1; i<=size; i++){
                    DetalleHistoria detHist = new DetalleHistoria();
                    if (request.getParameter("mat"+i) != null && !request.getParameter("mat"+i).equals("")) {
                      detHist.setPacIdMat(request.getParameter("pacId"));
                      detHist.setAdmisionMat(request.getParameter("noAdmision"));
                      detHist.setValor(request.getParameter("mat"+i));
                      detHist.setDescripcionMat(request.getParameter("descripcion_mat"+i));
                      detHist.setConteoInicial(request.getParameter("conteo_inicial"+i)!=null && !request.getParameter("conteo_inicial"+i).trim().equals("")?request.getParameter("conteo_inicial"+i):"0");
                      detHist.setConteoFinal(request.getParameter("conteo_final"+i) != null && !request.getParameter("conteo_final"+i).trim().equals("") ? request.getParameter("conteo_final"+i) : "0");
                      detHist.setGenAlertaMat(request.getParameter("gen_alarma"+i));
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
                    if (modeSec.equalsIgnoreCase("edit")){
                        HOIMgr.update(hist,"4");
                    }
                    ConMgr.clearAppCtx(null);
                 }
			}
			if(tab.equals("5")) //
			{
						HistoriaObstetricaI hist = new  HistoriaObstetricaI();
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
											HOIMgr.update(hist,"5");
									}
									ConMgr.clearAppCtx(null);
						 }
			}

			if(tab.equals("6")) //
			{
						HistoriaObstetricaI hist = new  HistoriaObstetricaI();
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
											HOIMgr.update(hist,"6");
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
if (HOIMgr.getErrCode().equals("1"))
{
%>
	alert('<%=HOIMgr.getErrMsg()%>');
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
} else throw new Exception(HOIMgr.getErrMsg());
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
