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
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
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
String code = request.getParameter("code");

String cDateTime = "";
String userName = (String) session.getAttribute("_userName");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (!viewMode) cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (code == null) code = "0";

if (request.getMethod().equalsIgnoreCase("GET")) {

if (code.equals("0")) {
    cdo = SQLMgr.getData("select codigo from tbl_sal_ctrl_uci_paciente where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = (select max(codigo) from tbl_sal_ctrl_uci_paciente where pac_id = "+pacId+" and admision = "+noAdmision+")");
    if (cdo == null) cdo = new CommonDataObject();
    
    code = cdo.getColValue("codigo","0");
}

ArrayList alH = SQLMgr.getDataList("select codigo, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion, usuario_creacion, usuario_modificacion from tbl_sal_ctrl_uci_paciente where pac_id = "+pacId+" and admision = "+noAdmision+" order by codigo desc ");

al = SQLMgr.getDataList("select a.codigo, a.descripcion, a.orden_tipo, a.orden_det, a.desc_tipo, decode(b.codigo_param,null,'I','U') action, ctrl_7am,  ctrl_8am,  ctrl_9am,  ctrl_10am,  ctrl_11am,  ctrl_12pm,  ctrl_1pm,  ctrl_2pm,  ctrl_3pm,  ctrl_4pm,  ctrl_5pm,  ctrl_6pm,  ctrl_7pm,  ctrl_8pm,  ctrl_9pm,  ctrl_10pm,  ctrl_11pm,  ctrl_12am,  ctrl_1am,  ctrl_2am,  ctrl_3am,  ctrl_4am,  ctrl_5am,  ctrl_6am, b.codigo as codigo_det from tbl_sal_ctrl_pac_params a, tbl_sal_ctrl_uci_paciente_det b where estado = 'A' and b.codigo_param(+) = a.codigo and b.codigo_hdr(+) = "+code+" and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" union all select 0, extra_desc, 9, orden_det, 'BALANCE HIDRICO - INGRESOS', decode(extra_desc,null,'I','U'), ctrl_7am,  ctrl_8am,  ctrl_9am,  ctrl_10am,  ctrl_11am,  ctrl_12pm,  ctrl_1pm,  ctrl_2pm,  ctrl_3pm,  ctrl_4pm,  ctrl_5pm,  ctrl_6pm,  ctrl_7pm,  ctrl_8pm,  ctrl_9pm,  ctrl_10pm,  ctrl_11pm,  ctrl_12am,  ctrl_1am,  ctrl_2am,  ctrl_3am,  ctrl_4am,  ctrl_5am,  ctrl_6am, codigo from tbl_sal_ctrl_uci_paciente_det where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo_hdr = "+code+" and codigo_param is null order by 3, 4");

%>
<!DOCTYPE html>
<html lang="en">   
<head>
<meta charset="utf-8">
<title>Expediente Cellbyte</title>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script src="../js/tableHeadFixer.js"></script>
<script>
var noNewHeight = true;

function imprimirExp(){
    abrir_ventana('../expediente3.0/print_hoja_evolucion_horaria.jsp?pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&code=<%=code%>');
}

function add(){
    window.location = '../expediente3.0/exp_hoja_evolucion_horaria.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0';
}

function setCtrl(code){
    window.location = '../expediente3.0/exp_hoja_evolucion_horaria.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code='+code;
}

function verHistorial() {
  $("#hist_container").toggle();
}

function canSubmit () {
    var proceed = true;
    //
    return proceed;
}

function showChart() {
    parent.loadModal('../expediente3.0/exp_hoja_evolucion_horaria_temp_chart.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>', {title: 'Temperaturas'});
}

$(function(){
    $('[data-toggle="tooltip"]').tooltip(); 
    
    var index = 0;
    $("#btn_extra").click(function(){
        index++;
        var $tplExtra = $("#extra-tpl");
        var tplExtraStr = $tplExtra.html().toString();
        tplExtraStr = tplExtraStr.replace(/@@index/g, (<%=al.size()%>+index));
        $tplExtra.after('<tr>'+tplExtraStr+'</tr>');
        
        $("#orden_det"+(<%=al.size()%>+index)).val(index);
        
        $("#size").val(index+<%=al.size()%>);
    });
    
    $('#freeze-table').tableHeadFixer({head:false, "left" : 1});
});    
</script>
<style>
</style>
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
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("code", code)%>

<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
<tr>
<td class="controls form-inline">
<%if(!mode.trim().equalsIgnoreCase("view")){%>
    <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
        <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
      </button>
 <%}%>
 <%if(!code.trim().equals("0")){%>
    <!--
    <button type="button" class="btn btn-inverse btn-sm" onclick="imprimirExp()"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
    -->
 <%}%>
 <%if(alH.size() > 0){%>
 <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
    <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
  </button>
  <%}%>
  <button type="button" class="btn btn-inverse btn-sm" onclick="showChart()">
    <i class="fa fa-line-chart"></i> <b>Temp</b>
  </button>
</td>
</tr>
</table>

<div class="table-wrapper" id="hist_container" style="display:none">  
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>                   
<tr class="bg-headtabla2">
    <th><cellbytelabel>C&oacute;digo</cellbytelabel></th>
    <th><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></th>
    <th><cellbytelabel>Creado Por</cellbytelabel></th>
    <th><cellbytelabel>Fecha Modificaci&oacute;n</cellbytelabel></th>
    <th><cellbytelabel>Modif. por</cellbytelabel></th>
</tr>
<tbody>
<%
for (int i=0; i<alH.size(); i++){
	cdo = (CommonDataObject) alH.get(i);
%>
    <tr class="pointer" onClick="javascript:setCtrl(<%=cdo.getColValue("codigo")%>,'view')">
        <td><%=cdo.getColValue("codigo")%></td>
        <td><%=cdo.getColValue("fecha_creacion")%></td>
        <td><%=cdo.getColValue("usuario_creacion")%></td>
        <td><%=cdo.getColValue("fecha_modificacion")%></td>
        <td><%=cdo.getColValue("usuario_modificacion")%></td>
    </tr>
<%
}
%>
</tbody>
</table>
</div>           
 </div>
 
<table cellspacing="0" class="table table-small-font table-bordered table-striped table-responsive" id="freeze-table">

    <%
    String group = "";
    double totI7am = 0, totI8am = 0, totI9am = 0, totI10am = 0, totI11am = 0, totI12pm = 0, totI1pm = 0, totI2pm = 0, totI3pm = 0, totI4pm = 0, totI5pm = 0, totI6pm = 0, totI7pm = 0, totI8pm = 0, totI9pm = 0, totI10pm = 0, totI11pm = 0, totI12am = 0, totI1am = 0, totI2am = 0, totI3am = 0, totI4am = 0, totI5am = 0, totI6am = 0;
    double totE7am = 0, totE8am = 0, totE9am = 0, totE10am = 0, totE11am = 0, totE12pm = 0, totE1pm = 0, totE2pm = 0, totE3pm = 0, totE4pm = 0, totE5pm = 0, totE6pm = 0, totE7pm = 0, totE8pm = 0, totE9pm = 0, totE10pm = 0, totE11pm = 0, totE12am = 0, totE1am = 0, totE2am = 0, totE3am = 0, totE4am = 0, totE5am = 0, totE6am = 0;
    for (int i = 1; i <= al.size(); i++){
        cdo = (CommonDataObject)al.get(i-1);
        
        if (!group.equals(cdo.getColValue("orden_tipo"))) {%>
            <tr class="bg-headtabla2">
                <td colspan="25"><%=cdo.getColValue("desc_tipo")%></td>
            </tr>
            
            <tr class="bg-headtabla" style="text-align:center">
                <th>&nbsp;</th>
                <th>7am</th>
                <th>8am</th>
                <th>9am</th>
                <th>10am</th>
                <th>11am</th>
                <th>12pm</th>
                <th>1pm</th>
                <th>2pm</th>
                <th>3pm</th>
                <th>4pm</th>
                <th>5pm</th>
                <th>6pm</th>
                <th>7pm</th>
                <th>8pm</th>
                <th>9pm</th>
                <th>10pm</th>
                <th>11pm</th>
                <th>12am</th>
                <th>1am</th>
                <th>2am</th>
                <th>3am</th>
                <th>4am</th>
                <th>5am</th>
                <th>6am</th>
            </tr>
        <%
        }
        %>
        <%=fb.hidden("codigo_param"+i, cdo.getColValue("codigo"))%>
        <%=fb.hidden("action"+i, cdo.getColValue("action"))%>
        <%=fb.hidden("codigo_det"+i, cdo.getColValue("codigo_det"))%>
        
        <tr>
            <td>
                <%if(cdo.getColValue("codigo"," ").equals("0")){%>
                    <input type="hidden" name="orden_det<%=i%>" id="orden_det<%=i%>" value="<%=cdo.getColValue("orden_det")%>" class="orden_det">
                    <%=fb.textBox("extra_desc"+i,cdo.getColValue("descripcion"),false,false,viewMode,10,"form-control input-sm",null,null)%>
                <%} else {%>
                <%=cdo.getColValue("descripcion")%>
                <%}%>
            </td>
            <td class="controls form-inline t-d" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 7am"><%=fb.decBox("ctrl_7am"+i,cdo.getColValue("ctrl_7am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 8am"><%=fb.decBox("ctrl_8am"+i,cdo.getColValue("ctrl_8am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 9am"><%=fb.decBox("ctrl_9am"+i,cdo.getColValue("ctrl_9am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 10am"><%=fb.decBox("ctrl_10am"+i,cdo.getColValue("ctrl_10am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 11am"><%=fb.decBox("ctrl_11am"+i,cdo.getColValue("ctrl_11am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 12pm"><%=fb.decBox("ctrl_12pm"+i,cdo.getColValue("ctrl_12pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 1pm"><%=fb.decBox("ctrl_1pm"+i,cdo.getColValue("ctrl_1pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 2pm"><%=fb.decBox("ctrl_2pm"+i,cdo.getColValue("ctrl_2pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 3pm"><%=fb.decBox("ctrl_3pm"+i,cdo.getColValue("ctrl_3pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 4pm"><%=fb.decBox("ctrl_4pm"+i,cdo.getColValue("ctrl_4pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 5pm"><%=fb.decBox("ctrl_5pm"+i,cdo.getColValue("ctrl_5pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 6pm"><%=fb.decBox("ctrl_6pm"+i,cdo.getColValue("ctrl_6pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 7pm"><%=fb.decBox("ctrl_7pm"+i,cdo.getColValue("ctrl_7pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 8pm"><%=fb.decBox("ctrl_8pm"+i,cdo.getColValue("ctrl_8pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 9pm"><%=fb.decBox("ctrl_9pm"+i,cdo.getColValue("ctrl_9pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 10pm"><%=fb.decBox("ctrl_10pm"+i,cdo.getColValue("ctrl_10pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 11pm"><%=fb.decBox("ctrl_11pm"+i,cdo.getColValue("ctrl_11pm"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 12am"><%=fb.decBox("ctrl_12am"+i,cdo.getColValue("ctrl_12am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 1am"><%=fb.decBox("ctrl_1am"+i,cdo.getColValue("ctrl_1am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 2am"><%=fb.decBox("ctrl_2am"+i,cdo.getColValue("ctrl_2am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 3am"><%=fb.decBox("ctrl_3am"+i,cdo.getColValue("ctrl_3am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 4am"><%=fb.decBox("ctrl_4am"+i,cdo.getColValue("ctrl_4am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 5am"><%=fb.decBox("ctrl_5am"+i,cdo.getColValue("ctrl_5am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="<%=cdo.getColValue("descripcion")%> :: 6am"><%=fb.decBox("ctrl_6am"+i,cdo.getColValue("ctrl_6am"),false,false,viewMode,1,"form-control input-sm",null,null)%></td>               
        </tr>
        
        <%
        if (cdo.getColValue("orden_tipo","-4").equals("4")) {
            totI7am += Double.parseDouble(cdo.getColValue("ctrl_7am","0"));
            totI8am += Double.parseDouble(cdo.getColValue("ctrl_8am","0"));
            totI9am += Double.parseDouble(cdo.getColValue("ctrl_9am","0"));
            totI10am += Double.parseDouble(cdo.getColValue("ctrl_10am","0"));
            totI11am += Double.parseDouble(cdo.getColValue("ctrl_11am","0"));
            totI12pm += Double.parseDouble(cdo.getColValue("ctrl_12pm","0"));
            totI1pm += Double.parseDouble(cdo.getColValue("ctrl_1pm","0"));
            totI2pm += Double.parseDouble(cdo.getColValue("ctrl_2pm","0"));
            totI3pm += Double.parseDouble(cdo.getColValue("ctrl_3pm","0"));
            totI4pm += Double.parseDouble(cdo.getColValue("ctrl_4pm","0"));
            totI5pm += Double.parseDouble(cdo.getColValue("ctrl_5pm","0"));
            totI6pm += Double.parseDouble(cdo.getColValue("ctrl_6pm","0"));
            totI7pm += Double.parseDouble(cdo.getColValue("ctrl_7pm","0"));
            totI8pm += Double.parseDouble(cdo.getColValue("ctrl_8pm","0"));
            totI9pm += Double.parseDouble(cdo.getColValue("ctrl_9pm","0"));
            totI10pm += Double.parseDouble(cdo.getColValue("ctrl_10pm","0"));
            totI11pm += Double.parseDouble(cdo.getColValue("ctrl_11pm","0"));
            totI12am += Double.parseDouble(cdo.getColValue("ctrl_12am","0"));
            totI1am += Double.parseDouble(cdo.getColValue("ctrl_1am","0"));
            totI2am += Double.parseDouble(cdo.getColValue("ctrl_2am","0"));
            totI3am += Double.parseDouble(cdo.getColValue("ctrl_3am","0"));
            totI4am += Double.parseDouble(cdo.getColValue("ctrl_4am","0"));
            totI5am += Double.parseDouble(cdo.getColValue("ctrl_5am","0"));
            totI6am += Double.parseDouble(cdo.getColValue("ctrl_6am","0"));
        }
        if (cdo.getColValue("orden_tipo","-9").equals("9")) {
            totE7am += Double.parseDouble(cdo.getColValue("ctrl_7am","0"));
            totE8am += Double.parseDouble(cdo.getColValue("ctrl_8am","0"));
            totE9am += Double.parseDouble(cdo.getColValue("ctrl_9am","0"));
            totE10am += Double.parseDouble(cdo.getColValue("ctrl_10am","0"));
            totE11am += Double.parseDouble(cdo.getColValue("ctrl_11am","0"));
            totE12pm += Double.parseDouble(cdo.getColValue("ctrl_12pm","0"));
            totE1pm += Double.parseDouble(cdo.getColValue("ctrl_1pm","0"));
            totE2pm += Double.parseDouble(cdo.getColValue("ctrl_2pm","0"));
            totE3pm += Double.parseDouble(cdo.getColValue("ctrl_3pm","0"));
            totE4pm += Double.parseDouble(cdo.getColValue("ctrl_4pm","0"));
            totE5pm += Double.parseDouble(cdo.getColValue("ctrl_5pm","0"));
            totE6pm += Double.parseDouble(cdo.getColValue("ctrl_6pm","0"));
            totE7pm += Double.parseDouble(cdo.getColValue("ctrl_7pm","0"));
            totE8pm += Double.parseDouble(cdo.getColValue("ctrl_8pm","0"));
            totE9pm += Double.parseDouble(cdo.getColValue("ctrl_9pm","0"));
            totE10pm += Double.parseDouble(cdo.getColValue("ctrl_10pm","0"));
            totE11pm += Double.parseDouble(cdo.getColValue("ctrl_11pm","0"));
            totE12am += Double.parseDouble(cdo.getColValue("ctrl_12am","0"));
            totE1am += Double.parseDouble(cdo.getColValue("ctrl_1am","0"));
            totE2am += Double.parseDouble(cdo.getColValue("ctrl_2am","0"));
            totE3am += Double.parseDouble(cdo.getColValue("ctrl_3am","0"));
            totE4am += Double.parseDouble(cdo.getColValue("ctrl_4am","0"));
            totE5am += Double.parseDouble(cdo.getColValue("ctrl_5am","0"));
            totE6am += Double.parseDouble(cdo.getColValue("ctrl_6am","0"));
        }
        
        %>
        
        <%if (i == al.size()) {%>
        
            <tr>
            <td><b>Total Ingreso</b></td>
            <td class="controls form-inline" data-toggle="tooltip" title="7am"><%=fb.decBox("tot_i_7am",""+totI7am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="8am"><%=fb.decBox("tot_i_8am",""+totI8am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="9am"><%=fb.decBox("tot_i_9am",""+totI9am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="10am"><%=fb.decBox("tot_i_10am",""+totI10am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="11am"><%=fb.decBox("tot_i_11am",""+totI11am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="12pm"><%=fb.decBox("tot_i_12pm",""+totI12pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="1pm"><%=fb.decBox("tot_i_1pm",""+totI1pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="2pm"><%=fb.decBox("tot_i_2pm",""+totI2pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="3pm"><%=fb.decBox("tot_i_3pm",""+totI3pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="4pm"><%=fb.decBox("tot_i_4pm",""+totI4pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="5pm"><%=fb.decBox("tot_i_5pm",""+totI5pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="6pm"><%=fb.decBox("tot_i_6pm",""+totI6pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="7pm"><%=fb.decBox("tot_i_7pm",""+totI7pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="8pm"><%=fb.decBox("tot_i_8pm",""+totI8pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="9pm"><%=fb.decBox("tot_i_9pm",""+totI9pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="10pm"><%=fb.decBox("tot_i_10pm",""+totI10pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="11pm"><%=fb.decBox("tot_i_11pm",""+totI11pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="12am"><%=fb.decBox("tot_i_12am"+i,""+totI12am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="1am"><%=fb.decBox("tot_i_1am",""+totI1am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="2am"><%=fb.decBox("tot_i_2am",""+totI2am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="3am"><%=fb.decBox("tot_i_3am",""+totI3am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="4am"><%=fb.decBox("tot_i_4am",""+totI4am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="5am"><%=fb.decBox("tot_i_5am",""+totI5am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="6am"><%=fb.decBox("tot_i_6am",""+totI6am,false,false,true,1,"form-control input-sm",null,null)%></td>               
        </tr>
        
        <tr>
            <td><b>Total Egreso</b></td>
            <td class="controls form-inline" data-toggle="tooltip" title="7am"><%=fb.decBox("tot_e_7am",""+totE7am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="8am"><%=fb.decBox("tot_e_8am",""+totE8am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="9am"><%=fb.decBox("tot_e_9am",""+totE9am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="10am"><%=fb.decBox("tot_e_10am",""+totE10am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="11am"><%=fb.decBox("tot_e_11am",""+totE11am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="12pm"><%=fb.decBox("tot_e_12pm",""+totE12pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="1pm"><%=fb.decBox("tot_e_1pm",""+totE1pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="2pm"><%=fb.decBox("tot_e_2pm",""+totE2pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="3pm"><%=fb.decBox("tot_e_3pm",""+totE3pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="4pm"><%=fb.decBox("tot_e_4pm",""+totE4pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="5pm"><%=fb.decBox("tot_e_5pm",""+totE5pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="6pm"><%=fb.decBox("tot_e_6pm",""+totE6pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="7pm"><%=fb.decBox("tot_e_7pm",""+totE7pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="8pm"><%=fb.decBox("tot_e_8pm",""+totE8pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="9pm"><%=fb.decBox("tot_e_9pm",""+totE9pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="10pm"><%=fb.decBox("tot_e_10pm",""+totE10pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="11pm"><%=fb.decBox("tot_e_11pm",""+totE11pm,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="12am"><%=fb.decBox("tot_e_12am"+i,""+totE12am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="1am"><%=fb.decBox("tot_e_1am",""+totE1am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="2am"><%=fb.decBox("tot_e_2am",""+totE2am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="3am"><%=fb.decBox("tot_e_3am",""+totE3am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="4am"><%=fb.decBox("tot_e_4am",""+totE4am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="5am"><%=fb.decBox("tot_e_5am",""+totE5am,false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="6am"><%=fb.decBox("tot_e_6am",""+totE6am,false,false,true,1,"form-control input-sm",null,null)%></td>               
        </tr>
        
        <tr>
            <td><b>Balance</b></td>
            <td class="controls form-inline" data-toggle="tooltip" title="7am"><%=fb.decBox("tot_b_7am",""+(totI7am-totE7am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="8am"><%=fb.decBox("tot_b_8am",""+(totI8am-totE8am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="9am"><%=fb.decBox("tot_b_9am",""+(totI9am-totE9am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="10am"><%=fb.decBox("tot_b_10am",""+(totI10am-totE10am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="11am"><%=fb.decBox("tot_b_11am",""+(totI11am-totE11am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="12pm"><%=fb.decBox("tot_b_12pm",""+(totI12pm-totE12pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="1pm"><%=fb.decBox("tot_b_1pm",""+(totI1pm-totE1pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="2pm"><%=fb.decBox("tot_b_2pm",""+(totI2pm-totE2pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="3pm"><%=fb.decBox("tot_b_3pm",""+(totI3pm-totE3pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="4pm"><%=fb.decBox("tot_b_4pm",""+(totI4pm-totE4pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="5pm"><%=fb.decBox("tot_b_5pm",""+(totI5pm-totE5pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="6pm"><%=fb.decBox("tot_b_6pm",""+(totI6pm-totE6pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="7pm"><%=fb.decBox("tot_b_7pm",""+(totI7pm-totE7pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="8pm"><%=fb.decBox("tot_b_8pm",""+(totI8pm-totE8pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="9pm"><%=fb.decBox("tot_b_9pm",""+(totI9pm-totE9pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="10pm"><%=fb.decBox("tot_b_10pm",""+(totI10pm-totE10pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="11pm"><%=fb.decBox("tot_b_11pm",""+(totI11pm-totE11pm),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="12am"><%=fb.decBox("tot_b_12am"+i,""+(totI12am-totE12am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="1am"><%=fb.decBox("tot_b_1am",""+(totI1am-totE1am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="2am"><%=fb.decBox("tot_b_2am",""+(totI2am-totE2am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="3am"><%=fb.decBox("tot_b_3am",""+(totI3am-totE3am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="4am"><%=fb.decBox("tot_b_4am",""+(totI4am-totE4am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="5am"><%=fb.decBox("tot_b_5am",""+(totI5am-totE5am),false,false,true,1,"form-control input-sm",null,null)%></td>
            
            <td class="controls form-inline" data-toggle="tooltip" title="6am"><%=fb.decBox("tot_b_6am",""+(totI6am-totE6am),false,false,true,1,"form-control input-sm",null,null)%></td>               
        </tr>
        
            <tr class="bg-headtabla2">
                <td colspan="25">
                    <button type="button" class="btn btn-inverse btn-sm" id="btn_extra"<%=viewMode?" disabled":""%>>
                        <i class="fa fa-plus"></i>
                    </button>
                    BALANCE HIDRICO - INGRESOS
                </td>
            </tr>
            
            <tr style="display:none" id= "extra-tpl">
            <input type="hidden" name="action@@index" id="action@@index" value="I">
            <input type="hidden" name="orden_det@@index" id="orden_det@@index" value="">
            <td><input type="text" name="extra_desc@@index" id="extra_desc@@index" value="" class="form-control input-sm" size="10" style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_7am@@index" id="ctrl_7am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_8am@@index" id="ctrl_8am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_9am@@index" id="ctrl_9am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_10am@@index" id="ctrl_10am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_11am@@index" id="ctrl_11am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_12pm@@index" id="ctrl_12pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_1pm@@index" id="ctrl_1pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_2pm@@index" id="ctrl_2pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_3pm@@index" id="ctrl_3pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_4pm@@index" id="ctrl_4pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_5pm@@index" id="ctrl_5pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_6pm@@index" id="ctrl_6pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_7pm@@index" id="ctrl_7pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_8pm@@index" id="ctrl_8pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_9pm@@index" id="ctrl_9pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_10pm@@index" id="ctrl_10pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_11pm@@index" id="ctrl_11pm@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_12am@@index" id="ctrl_12am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_1am@@index" id="ctrl_1am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_2am@@index" id="ctrl_2am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_3am@@index" id="ctrl_3am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_4am@@index" id="ctrl_4am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_5am@@index" id="ctrl_5am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>
            <td class="controls form-inline"><input type="number" step=".01" style="width: 58px;" name="ctrl_6am@@index" id="ctrl_6am@@index" value="" class="form-control input-sm" size="1"  style="text-transform:uppercase"></td>               
            </tr>


        <%}%>
    <%
        group = cdo.getColValue("orden_tipo");
    }    
    %>
    
</table>

<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td>
                <input type="hidden" name="saveOption" value="O"> 
                <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
            </td> 
        </tr>
    </table>
</div> 
<%=fb.formEnd(true)%>
</div>
</div>
</body>
</html> 
<%} else {

    String saveOption = request.getParameter("saveOption") == null ? "" : request.getParameter("saveOption");
    String baction = request.getParameter("baction");
    int size = Integer.parseInt(request.getParameter("size"));
    
    CommonDataObject cdoH = new CommonDataObject();
    cdoH.setTableName("tbl_sal_ctrl_uci_paciente");
    if (code.equals("0")) {
        CommonDataObject cdoN = SQLMgr.getData("select nvl(max(codigo),0) + 1 next_cod from tbl_sal_ctrl_uci_paciente where pac_id = "+pacId+" and admision = "+noAdmision);
        if (cdoN == null) cdoN = new CommonDataObject();
        cdoH.addColValue("codigo", cdoN.getColValue("next_cod","0"));
        cdoH.addColValue("pac_id", pacId);
        cdoH.addColValue("admision", noAdmision);
        cdoH.addColValue("fecha_creacion", cDateTime);
        cdoH.addColValue("usuario_creacion", userName);
        cdoH.setAction("I");
        code = cdoN.getColValue("next_cod","0");
    } else {
        cdoH.addColValue("fecha_modificacion", cDateTime);
        cdoH.addColValue("usuario_modificacion", userName);
        cdoH.setAction("U");
        cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+code);
    }
    
    al = new ArrayList();
    for (int i = 1; i <= size; i++) {
        cdo = new CommonDataObject();
        cdo.setTableName("tbl_sal_ctrl_uci_paciente_det");
        
        if (request.getParameter("action"+i) != null && request.getParameter("action"+i).equalsIgnoreCase("I")) {
            cdo.addColValue("pac_id", pacId);
            cdo.addColValue("admision", noAdmision);
            cdo.addColValue("codigo_param", request.getParameter("codigo_param"+i));
            cdo.addColValue("codigo_hdr", cdoH.getColValue("codigo", code));
            cdo.setAction("I");
            cdo.setAutoIncCol("codigo");
            cdo.setAutoIncWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and codigo_hdr = "+code);
        } else {
            cdo.setAction("U");
            cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and codigo_hdr = "+code+" and codigo_param = "+request.getParameter("codigo_param"+i)+" and codigo = "+request.getParameter("codigo_det"+i));
        }
        
        if(request.getParameter("extra_desc"+i)!=null&&!request.getParameter("extra_desc"+i).equals("")) cdo.addColValue("extra_desc", request.getParameter("extra_desc"+i).toUpperCase());
        cdo.addColValue("orden_det", request.getParameter("orden_det"+i));
        
        cdo.addColValue("ctrl_7am", request.getParameter("ctrl_7am"+i));
        cdo.addColValue("ctrl_8am", request.getParameter("ctrl_8am"+i));
        cdo.addColValue("ctrl_9am", request.getParameter("ctrl_9am"+i));
        cdo.addColValue("ctrl_10am", request.getParameter("ctrl_10am"+i));
        cdo.addColValue("ctrl_11am", request.getParameter("ctrl_11am"+i));
        cdo.addColValue("ctrl_12pm", request.getParameter("ctrl_12pm"+i));
        cdo.addColValue("ctrl_1pm", request.getParameter("ctrl_1pm"+i));
        cdo.addColValue("ctrl_2pm", request.getParameter("ctrl_2pm"+i));
        cdo.addColValue("ctrl_3pm", request.getParameter("ctrl_3pm"+i));
        cdo.addColValue("ctrl_4pm", request.getParameter("ctrl_4pm"+i));
        cdo.addColValue("ctrl_5pm", request.getParameter("ctrl_5pm"+i));
        cdo.addColValue("ctrl_6pm", request.getParameter("ctrl_6pm"+i));
        cdo.addColValue("ctrl_7pm", request.getParameter("ctrl_7pm"+i));
        cdo.addColValue("ctrl_8pm", request.getParameter("ctrl_8pm"+i));
        cdo.addColValue("ctrl_9pm", request.getParameter("ctrl_9pm"+i));
        cdo.addColValue("ctrl_10pm", request.getParameter("ctrl_10pm"+i));
        cdo.addColValue("ctrl_11pm", request.getParameter("ctrl_11pm"+i));
        cdo.addColValue("ctrl_12am", request.getParameter("ctrl_12am"+i));
        cdo.addColValue("ctrl_1am", request.getParameter("ctrl_1am"+i));
        cdo.addColValue("ctrl_2am", request.getParameter("ctrl_2am"+i));
        cdo.addColValue("ctrl_3am", request.getParameter("ctrl_3am"+i));
        cdo.addColValue("ctrl_4am", request.getParameter("ctrl_4am"+i));
        cdo.addColValue("ctrl_5am", request.getParameter("ctrl_5am"+i));
        cdo.addColValue("ctrl_6am", request.getParameter("ctrl_6am"+i));
        
        al.add(cdo);
    }
    
    if (al.size() == 0) {
        cdo = new CommonDataObject();
        cdo.setTableName("tbl_sal_ctrl_uci_paciente_det");
        cdo.setAction("I");
    }
    
    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    if(baction.equalsIgnoreCase("Guardar")){
        SQLMgr.save(cdoH, al, true, true, true, true);
    }
    ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow(){
<%if (SQLMgr.getErrCode().equals("1")){%>
	alert('<%=SQLMgr.getErrMsg()%>'); 
<% if (saveOption.equalsIgnoreCase("N")){%>
    setTimeout('addMode()',500);
<%} else if (saveOption.equalsIgnoreCase("O")) {%>
    setTimeout('editMode()',500);
<%} else if (saveOption.equalsIgnoreCase("C")) {%>
    parent.doRedirect(0);
<%}
} else throw new Exception(SQLMgr.getErrMsg());    
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&code=<%=code%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%}%>