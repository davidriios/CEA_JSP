<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.Escalas"%>
<%@ page import="issi.expediente.DetalleEscala"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ECMgr" scope="page" class="issi.expediente.EscalaMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ECMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

Escalas escala = new Escalas();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String desc = request.getParameter("desc");
String tmpTot = request.getParameter("tmpTot")==null?"0":request.getParameter("tmpTot");
String forceSumEval = request.getParameter("forceSumEval")==null?"0":request.getParameter("forceSumEval");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec == null) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (id == null) id = "0";
if (fg == null) fg = "WB";
if (desc == null) desc = "";
if (forceSumEval == null) forceSumEval = "";

boolean checkDefault = false;
int rowCount = 0;
String fecha = request.getParameter("fecha");
String hora_eval = request.getParameter("hora_eval");
int escLastLineNo = 0;
String appendFilter="" , op = "";
String key = "",titulo="";
String eTotal=request.getParameter("eTotal")==null?"0":request.getParameter("eTotal");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = cDateTime.substring(0,10);
if (fecha == null) fecha = cDate;

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

if (request.getMethod().equalsIgnoreCase("GET")) {
    sql="select to_char(se.fecha_recup,'dd/mm/yyyy') as fecha_recup, se.usuario_recup, to_char(se.fecha,'dd/mm/yyyy') as fecha, to_char(se.hora,'hh12:mi:ss am') as hora , se.total ,se.id,se.usuario_mod usuarioMod, to_char(se.fecha_mod,'dd/mm/yyyy')fechaMod, to_char(se.fecha_mod,'hh12:mi:ss am')horaMod,se.usuario from tbl_sal_escalas se  where se.pac_id = "+pacId+" and se.admision = "+noAdmision+" and se.tipo ='"+fg+"' order by to_date(se.fecha||' '||to_char(se.hora,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') desc";
    al2 = SQLMgr.getDataList(sql);
    
    al = SQLMgr.getDataList("select h.codigo, h.descripcion, h.tipo, h.presentar_check from tbl_sal_concepto_norton h where h.tipo = '"+fg+"' and h.estado = 'A' order by h.orden");
    
    if(!id.trim().equalsIgnoreCase("0")){
        sql="select to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora, observacion,total,dolor,intervencion,localizacion from tbl_sal_escalas where pac_id = "+pacId+" and admision = "+noAdmision+" and id = "+id+" and tipo ='"+fg+"'";

		escala = (Escalas) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Escalas.class);
		if (!viewMode) modeSec = "edit";
        
    } else {
        escala = new Escalas();
        escala.setHora(cDateTime.substring(11));
        escala.setFecha(cDateTime.substring(0,10));
        escala.setDolor("");
        escala.setIntervencion("");
        escala.setTotal("0");
        if (!viewMode) modeSec = "add";
	}
    
    CommonDataObject cdoE = new CommonDataObject();

    if(!id.trim().equalsIgnoreCase("0")){
        cdoE = SQLMgr.getData("select i.codigo, i.descripcion, ip.observacion from tbl_sal_intervencion i, tbl_sal_intervencion_paciente ip where i.estado = 'A' and i.tipo = '"+fg+"' and i.codigo = ip.cod_intervencion and ip.pac_id = "+pacId+" and ip.admision = "+noAdmision+" and ip.id_escala = "+id+" order by 1");
        
        if(cdoE == null) cdoE = new CommonDataObject();
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
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
var noNewHeight = true;
document.title = 'ESCALAS - '+document.title;    
<%@ include file="../expediente/exp_checkviewmode.jsp"%>

function verEscala(k,mode){
    var fecha = eval('document.form0.fecha'+k).value;
    var hora = eval('document.form0.hora'+k).value;
    var cTot = eval('document.form0.total_tmp'+k).value;
    var mode ='view';
    var id = eval('document.form0.code'+k).value;
    var tmpTot = $("#temp_total"+k).val();
    window.location = '../expediente3.0/exp_escalas_dolor_tvp.jsp?modeSec='+mode+'&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id='+id+'&fg=<%=fg%>&desc=<%=desc%>&tmpTot='+tmpTot+'&eTotal='+cTot+'&fecha='+fecha;
}

function add(){
    window.location = '../expediente3.0/exp_escalas_dolor_tvp.jsp?mode=<%=mode%>&modeSec=add&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0&fg=<%=fg%>&desc=<%=desc%>';
}
function doAction(){checkViewMode();}
function setEscalaValor(k,codigo,valor){sumaEscala();}
function consultar(){
    abrir_ventana1('../expediente3.0/list_evaluacion_dolor.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>');
}
function imprimir(){ 
    var total = $("#total2").val() || 0;
    var intCode = "<%=cdoE.getColValue("codigo","0")%>";
    var intDesc = "<%=cdoE.getColValue("descripcion","N/A")%>";
    var intObserv = "<%=cdoE.getColValue("observacion","N/A")%>";
    abrir_ventana1('../expediente3.0/print_escalas_dolor_tvp.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=modeSec%>&fg=<%=fg%>&seccion=<%=seccion%>&id=<%=id%>&desc=<%=desc%>&total='+total+'&int_code='+intCode+'&int_desc='+intDesc+'&int_observ='+intObserv);
}
function sumaEscala(val){
	var total = 0;
    return total;
}
function clickInterv(e){
    <%if(request.getParameter("showIntervention")!=null && request.getParameter("showIntervention").equalsIgnoreCase("Y")){%>
        var total = '<%=eTotal%>';
        showIntervention = true;
    <%}else{%>
        var showIntervention = false;
        var total = $("#total2").val() || 0;
    <%}%>
    var url = '../expediente3.0/exp_intervencion_list.jsp?fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id_escala=<%=id%>&total='+total;
    <%if(modeSec.equalsIgnoreCase("view")){%>
        if(showIntervention){
            parent.showInterv(url, {screwTheUser:true});
        }else{
            url += '&mode=<%=modeSec%>';
            parent.showInterv(url, {screwTheUser:false});
        }
    <%} else {%>
        parent.showInterv(url, {screwTheUser:true});
    <%}%>
    return;
 }

$(function(){
  // reloading alerts
  if (typeof parent.reloadAlerts === 'function') parent.reloadAlerts();
  else if (typeof parent.parent.reloadAlerts === 'function') parent.parent.reloadAlerts();
  
  doAction();
  
  //
  $(".header").click(function(){
    var that = $(this);
    var i = that.data('header');
    $("#det-"+i).toggle();
  });
  
  $(".should-type").click(function(){
      var that = $(this);
      var i = that.data('index');
      var codH = that.data('cod_header');
      if (that.is(":checked")) {
        $("#observacion_"+codH+"_"+i).prop("readOnly", false);
      } else {
        $("#observacion_"+codH+"_"+i).val("").prop("readOnly", true);
      }
    });
    
    // total
    $(".checker").not("input[class*='act-as-radio-']").click(function(){
        computeTotalCheck();
    });
    
    $("input[class*='act-as-radio-']").click(function(){
        computeTotalRadio($(this));
    });
    
    <%if(!id.trim().equals("0")){%>
        computeTotalCheck();
    <%}%>
    
    
    $("#save").click(function(){
       var errors = 0;
       computeTotal();
      
       $(".codigos").each(function(){
         var $self = $(this);
         var codigo = $self.val();
         var descripcion = $self.data('descripcion');
         if (!$("input[type='checkbox'][name*='escala_"+codigo+"_']:checked").length) {
            parent.CBMSG.error('Por favor seleccionar por lo menos un parámetro en l grupo: '+descripcion);
            errors++;
            return false;
         }
       });
       
       if (!errors) $("#form0").submit();
    });
    
    
    
});


function computeTotal(){
    var total = 0;
    $(".sub-total").each(function(){
        total += parseInt(this.value) || 0;
    });
    $("#total1, #total2").val(total);
}

function computeTotalRadio(self) {
    var i = self.data('index');
    var codH = self.data('cod_header');
    var total = 0;
    if (self.is(":checked")) {
        total = parseInt($("#valor_"+codH+"_"+i).val() || '0');
    } else {
      if(total > 0) total -= parseInt($("#valor_"+codH+"_"+i).val() || '0');
    }
    $("#total_header_"+codH).val(total>0?total:"");
    computeTotal();
}

function computeTotalCheck() {
    var totH = parseInt("<%=al.size()%>");
    for (var i = 0; i<totH; i++) {
        var codH = $("#cod_escala_"+i).val();
        var totD = parseInt($("#tot_det"+i).val());
        var total = 0;
        for (var p = 0; p<totD; p++) {
            if ( $("input[name='escala_"+codH+"_"+p+"'], input[name='_escala_"+codH+"_"+p+"Dsp']:disabled").is(":checked") ){
                total += parseInt($("#valor_"+codH+"_"+p).val() || '0');
            }
        }
        $("#total_header_"+codH).val(total>0?total:"");
    }
    computeTotal();
}

function printXHora() {
  var fecha = $("#rpt_fecha").val();
  var rpt = "";
  <% if (fg.trim().equalsIgnoreCase("TVP") || fg.trim().equalsIgnoreCase("DO")){%>
    rpt = "rpt_escalas_caidas.rptdesign";
  <%}%>
  if(fecha && rpt)abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=expediente/'+rpt+'&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=<%=fg%>&tipo_desc=<%=desc%>&pCtrlHeader=false&pFecha='+fecha);
}

function verHistorial() {$("#hist_container").toggle();}
function canSubmit() {}

function actAsRadio(obj){
 <%if(fg.equalsIgnoreCase("DO")){ for (int i = 0; i < al.size(); i++){
    CommonDataObject cdo2 = (CommonDataObject) al.get(i);
    if (cdo2.getColValue("presentar_check","N").equalsIgnoreCase("N")){
 %>
    $("input:checkbox.act-as-radio-<%=cdo2.getColValue("codigo")%>").click(function(){
        $(this).change(function(){
            $("input:checkbox.act-as-radio-<%=cdo2.getColValue("codigo")%>").not($(this)).prop("checked", false);
            $(this).prop("checked", $(this).prop("checked"));    
        });
    });
 <%}}}%>
}
</script>
</head>

<body class="body-form">
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
<%//fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("opcion","0")%>
<%=fb.hidden("valIni","0")%>
<%=fb.hidden("fg",""+fg)%>
<%=fb.hidden("id",""+id)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("showing_tipo_dolor", "")%>

<div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-2">
    <tr>
        <td class="controls form-inline">
            <button type="button" class="btn btn-inverse btn-sm" onclick="consultar()">
                <i class="fa fa-search fa-printico"></i> <b>Consultar</b>
            </button>
            <%if(!mode.trim().equalsIgnoreCase("view")){%>
                <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
                    <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
                  </button>
             <%}%>
             <%if(!id.trim().equals("0")){%>
                <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir()"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
             <%}%>
             
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="rpt_fecha" />
            <jsp:param name="valueOfTBox1" value="<%=escala.getFecha()%>" />
            </jsp:include>
 
            <button type="button" class="btn btn-inverse btn-sm" onclick="printXHora()"><i class="fa fa-print fa-printico"></i> <b>Por Hora</b></button>
            
            <%if(al2.size() > 0){%>
                <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
                    <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
                </button>
            <%}%>
        </td>
    </tr>
    </table> 

    <div class="table-wrapper" id="hist_container" style="display:none">  
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
            <thead>                   
                <tr><th colspan="7" class="bg-headtabla"><cellbytelabel>Listado de Evaluaciones [ Escala ]</cellbytelabel></th>                    
                <tr class="bg-headtabla2">
                    <th><cellbytelabel>Fecha</cellbytelabel></th>
                    <th><cellbytelabel>Hora</cellbytelabel></th>
                    <th><cellbytelabel>Total</cellbytelabel></th>
                    <th><cellbytelabel>Creado Por</cellbytelabel></th>
                    <th><cellbytelabel>Modif. por</cellbytelabel></th>
                    <th><cellbytelabel>Fecha/Hora Mod</cellbytelabel>.</th>
                    <th><cellbytelabel>Fecha Recup</cellbytelabel>.</th>
                </tr>
            </thead>
            <tbody>
                <% for (int i=1; i<=al2.size(); i++){
                    cdo = (CommonDataObject) al2.get(i-1);
                %>
                <%=fb.hidden("code"+i,cdo.getColValue("id"))%>
                <%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>
                <%=fb.hidden("hora"+i,cdo.getColValue("hora"))%>
                <%=fb.hidden("temp_total"+i,cdo.getColValue("total"))%>
                <%=fb.hidden("total_tmp"+i,cdo.getColValue("total"))%>
                <tr class="pointer" onClick="javascript:verEscala(<%=i%>,'view')">
                    <td><%=cdo.getColValue("fecha")%></td>
                    <td><%=cdo.getColValue("hora")%></td>
                    <td align="center"><%=cdo.getColValue("total")%></td>
                    <td><%=cdo.getColValue("usuario")%></td>
                    <td><%=cdo.getColValue("usuarioMod")%></td>
                    <td><%=cdo.getColValue("fechaMod")%>/<%=cdo.getColValue("horaMod")%></td>
                    <td><%=cdo.getColValue("fecha_recup")%></td>
                </tr>
                <%}%>
            </tbody>
        </table>
    </div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped"> 
    <tr>
        <td><cellbytelabel>Fecha</cellbytelabel></td>
        <td class="controls form-inline">
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="fecha" />
            <jsp:param name="valueOfTBox1" value="<%=escala.getFecha()%>" />
            <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
            </jsp:include></td>
        <td><cellbytelabel>Hora</cellbytelabel></td>
        <td class="controls form-inline">
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1"/>
            <jsp:param name="format" value="hh12:mi:ss am"/>
            <jsp:param name="nameOfTBox1" value="hora" />
            <jsp:param name="valueOfTBox1" value="<%=escala.getHora()%>" />
            <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
            </jsp:include>
         </td>
    </tr>
</table>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
    <%if(!modeSec.trim().equalsIgnoreCase("add")){%>
    <tr>
        <td align="right" colspan="3">
            <button type="button" class="btn btn-inverse" onclick="javascript:clickInterv(event);" id="__intervencion" data-fg="<%=fg%>">Intervenciones</button>
            
        </td>
    </tr>
    <%}%>
    
    <%if(request.getParameter("showIntervention")!=null && request.getParameter("showIntervention").equalsIgnoreCase("Y")){%><script>$("#__intervencion").click();</script>
    <%}%>
    
    <tr>
        <td align="right">Total:</td>
        <td>
            <%=fb.textBox("total1","",false,false,true,5,0,"form-control input-sm",null,null)%>
        </td>
    </tr>
    
    <tr class="bg-headtabla2" align="center">
        <td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
        <td><cellbytelabel>Escala</cellbytelabel></td>
    </tr>
    
    <%
    int totP = 0;
    int totH = 0;
    boolean actAsRadio = false;
    for (int i = 0; i<al.size(); i++){
        CommonDataObject cdoH = (CommonDataObject) al.get(i);
        sql = "select a.codigo,a.secuencia, a.descripcion, a.valor, b.tipo_escala, b.detalle, b.observacion from tbl_sal_det_concepto_norton a,tbl_sal_concepto_norton c,  ( select nvl(cod_escala,0) as tipo_escala, detalle, observacion  from tbl_sal_detalle_esc a where id = "+id+" and tipo = '"+fg+"' order by 1 ) b where  a.codigo = b.tipo_escala(+) and b.detalle(+) = a.secuencia and a.tipo = '"+cdoH.getColValue("tipo")+"' and a.codigo =  "+cdoH.getColValue("codigo")+" and a.estado='A' and c.codigo = a.codigo(+) and a.estado(+) = c.estado order by c.orden, a.orden ";
  
        ArrayList alP = SQLMgr.getDataList(sql);
        totH++;
        actAsRadio = fg.equalsIgnoreCase("DO") && cdoH.getColValue("presentar_check","N").equalsIgnoreCase("N");
    %>
    
        <%=fb.hidden("cod_escala_"+i, cdoH.getColValue("codigo"))%>
        <%=fb.hidden("tot_det"+i, ""+alP.size())%>
        <input type="hidden" class="codigos" value="<%=cdoH.getColValue("codigo")%>" data-descripcion="<%=cdoH.getColValue("descripcion")%>">
        <tr>
            <td class="pointer header" data-header="<%=cdoH.getColValue("codigo")%>">
              <%=cdoH.getColValue("codigo")%> - <%=cdoH.getColValue("descripcion")%>
             </td>
            <td>
                <table cellspacing="0" class="table table-small-font table-bordered table-striped" id="det-<%=cdoH.getColValue("codigo")%>" style="display:">
                    <% for (int p = 0; p<alP.size(); p++){
                        CommonDataObject cdoP = (CommonDataObject) alP.get(p);
                        totP++;
                    %>
                    <%=fb.hidden("secuencia_"+cdoH.getColValue("codigo")+"_"+p, cdoP.getColValue("secuencia"))%>
                    <tr class="det">
                        <td width="60%">
                        <label class="pointer">
                        <%=fb.checkbox("escala_"+cdoH.getColValue("codigo")+"_"+p, cdoP.getColValue("secuencia") ,(cdoP.getColValue("secuencia").equals(cdoP.getColValue("detalle"))),viewMode,"should-type checker"+(actAsRadio?" act-as-radio-"+cdoH.getColValue("codigo"):""),"",actAsRadio?"onclick=actAsRadio(this)":"",""," data-index="+p+" data-valor="+cdoP.getColValue("valor")+" data-cod_header="+cdoH.getColValue("codigo"))%>&nbsp;&nbsp;
                        <%=cdoP.getColValue("descripcion")%>
                        </label>
                        </td>
                        <td>
                            <%=fb.textBox("valor_"+cdoH.getColValue("codigo")+"_"+p,cdoP.getColValue("valor"),false,false,true,5,0,"form-control input-sm",null,null)%>
                        </td>
                        <td>
                            <%//=sql%>
                            <%=fb.textarea("observacion_"+cdoH.getColValue("codigo")+"_"+p,cdoP.getColValue("observacion"),false,false,viewMode||cdoP.getColValue("observacion"," ").trim().equals(""),50,1,0,"form-control input-sm","width:100%",null)%>
                        </td>
                    </tr>
                    <%if(p+1 == alP.size()){%>
                    <tr>
                        <td align="right">Sub Total:</td>
                        <td><%=fb.textBox("total_header_"+cdoH.getColValue("codigo"),"",false,false,true,5,0,"form-control input-sm sub-total",null,null)%></td>
                        <td></td>
                    </tr>
                    <%}%>
                    <%}%>
                </table>
            </td>
        </tr>
        
    <%}%>
    
    <tr>
        <td align="right">Total:</td>
        <td>
            <%=fb.textBox("total2","",false,false,true,5,0,"form-control input-sm",null,null)%>
        </td>
    </tr>
    
    
    
</table>


<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td>
                <input type="hidden" name="saveOption" value="O"> 
                <%=fb.button("save","Guardar",true,viewMode,"",null,"")%>
            </td>    
        </tr>
    </table>
</div>
<%=fb.hidden("totH",""+totH)%>
<%=fb.hidden("totP",""+totP)%>
<%=fb.formEnd(true)%>
<script>sumaEscala("<%=eTotal%>");</script>
	</div>
</div>
</body>
</html>
<%
} else {
    String saveOption = request.getParameter("saveOption")==null?"":request.getParameter("saveOption");
    String baction = request.getParameter("baction");
    
    int totH = Integer.parseInt(request.getParameter("totH")!=null && !request.getParameter("totH").equals("")?request.getParameter("totH"):"0");
    int totP = Integer.parseInt(request.getParameter("totP")!=null && !request.getParameter("totP").equals("")?request.getParameter("totP"):"0");
    
    Escalas eco = new Escalas();
	eco.setAdmision(request.getParameter("noAdmision"));
	eco.setPacId(request.getParameter("pacId"));
	eco.setFecha(request.getParameter("fecha"));
	eco.setHora(request.getParameter("hora"));
	eco.setTipo(request.getParameter("fg"));
	eco.setId(request.getParameter("id"));
	eco.setTotal(request.getParameter("total2"));
	eco.setLocalizacion(request.getParameter("localizacion"));
	eco.setUsuario((String) session.getAttribute("_userName"));
    
    for (int i=0; i<totH; i++){
        String codEscala = request.getParameter("cod_escala_"+i);
        
        for (int j=0; j<totP; j++){
            String checker = request.getParameter("escala_"+codEscala+"_"+j);
            if (checker != null && !checker.equals("")) {
                DetalleEscala dre = new DetalleEscala();
                
                dre.setCodEscala(codEscala);
                dre.setDetalle(request.getParameter("secuencia_"+codEscala+"_"+j));
				dre.setValor(request.getParameter("valor_"+codEscala+"_"+j));
                dre.setAplicar("S");
                dre.setObservacion(request.getParameter("observacion_"+codEscala+"_"+j));
                
                eco.addDetalleEscala(dre);
            }
            
        } //j
        
    } //i
    
    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+" fg="+fg+" eTotal="+request.getParameter("total2")+" tmpTot"+tmpTot+" forceSumEval="+forceSumEval);
    if(modeSec.trim().equalsIgnoreCase("add")){
        ECMgr.add(eco);
        id=ECMgr.getPkColValue("id");
    } else {
        ECMgr.update(eco);
        id=request.getParameter("id");
    }
    ConMgr.clearAppCtx(null); 
 %>

<html>
<head>
<script>
function closeWindow()
{
<%
if (ECMgr.getErrCode().equalsIgnoreCase("1"))
{
%>
	alert('<%=ECMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?showIntervention=Y&seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&fg=<%=fg%>&desc=<%=desc%>&eTotal=<%=request.getParameter("total2")%>';
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente3.0/exp_escalas_dolor.jsp"))
	{
%>
<%
	}
	else
	{
%>
<%	} %>
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
} else throw new Exception(ECMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?showIntervention=Y&seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&fg=<%=fg%>&desc=<%=desc%>&eTotal=<%=request.getParameter("total2")%>&fecha=<%=fecha%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%> 
