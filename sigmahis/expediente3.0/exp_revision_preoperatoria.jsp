<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.expediente.RespuestaRevision" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject rev = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fecha = request.getParameter("fecha");
String hora = request.getParameter("hora");
String desc = request.getParameter("desc");
String tab = request.getParameter("tab");
String fg = request.getParameter("fg");

if (fg == null) fg = "A";

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");

if (fecha == null) fecha = cDate.substring(0,10);
if (hora == null)  hora = cDate.substring(11);

if (tab == null) tab = "0";

String active0 = "", active1 = "", active2 = "", active3 = "", active4 = "";
if (tab.equals("0")) active0 = "active";
else if (tab.equals("1")) active1 = "active";
else if (tab.equals("2")) active2 = "active";
else if (tab.equals("3")) active3 = "active";
else if (tab.equals("4")) active4 = "active";

ArrayList alTO = new ArrayList();
ArrayList alSO = new ArrayList();
ArrayList alVP = new ArrayList();

if (request.getMethod().equalsIgnoreCase("GET"))
{
    sql="select to_char(fecha,'dd/mm/yyyy') as fecha,to_char(fecha,'hh12:mi am') as hora, observacion, cirugia, medico_cirujano as cirujano, get_idoneidad(usuario_creacion,1) usuario_creacion, get_idoneidad(usuario_modif,1) usuario_modif, to_char(fecha_modif,'dd/mm/yyyy hh12:mi:ss am') fecha_modif from tbl_sal_revision_preoperatoria where pac_id="+pacId+" and secuencia="+noAdmision +" and grupo = '"+fg+"' order by fecha desc";

    al2 = SQLMgr.getDataList(sql);

sql="select to_char(fecha,'dd/mm/yyyy hh12:mi am') as fecha, observacion, emp_provincia as empProvincia, emp_sigla as empSigla, emp_tomo as empTomo, emp_asiento as empAsiento, emp_compania as empCompania, get_idoneidad(usuario_creacion,1) as usuarioCreacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, emp_id as empId, cirugia as cirugia, nvl(desc_cirugia,cirugia) desc_cirugia, medico_cirujano as cirujano, nvl(desc_medico_cirujano, medico_cirujano) desc_medico_cirujano from tbl_sal_revision_preoperatoria where pac_id="+pacId+" and secuencia="+noAdmision+" and grupo = '"+fg+"' and to_date(to_char(fecha,'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') = to_date('"+fecha+" "+hora+"','dd/mm/yyyy hh12:mi am')";

rev = (CommonDataObject) SQLMgr.getData(sql);
if(rev == null){
    rev = new CommonDataObject();
	rev.addColValue("fechaCreacion", cDateTime);
	rev.addColValue("usuarioCreacion", (String) session.getAttribute("_userName"));
	rev.addColValue("fecha", cDate);
	rev.addColValue("observacion", " ");
    if (!viewMode) modeSec = "add";
}
else if (!viewMode) modeSec = "edit";

if (!modeSec.equalsIgnoreCase("add")){
    alVP = SQLMgr.getDataList("select a.codigo, a.descripcion, b.verificado, b.observacion, decode(b.codigo_param,null,'I','U') action, a.bloquear from tbl_sal_pausa_seguridad_params a, tbl_sal_pausa_seguridad b where a.tipo = 'VP' and a.grupo = '"+fg+"' and a.estado = 'A' and a.codigo = b.codigo_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and a.tipo = b.tipo(+) and b.fecha(+) = to_date('"+rev.getColValue("fecha")+"','dd/mm/yyyy hh12:mi am') and a.grupo = b.grupo(+) order by a.orden");
    
    alTO = SQLMgr.getDataList("select a.codigo, a.descripcion, b.identificacion_pac, b.proc_correcto, b.sitio_correcto, decode(b.codigo_param,null,'I','U') action from tbl_sal_pausa_seguridad_params a, tbl_sal_pausa_seguridad b where a.tipo = 'TO' and a.grupo = '"+fg+"' and a.estado = 'A' and a.codigo = b.codigo_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and a.tipo = b.tipo(+) and b.fecha(+) = to_date('"+rev.getColValue("fecha")+"','dd/mm/yyyy hh12:mi am') and a.grupo = b.grupo(+)  order by a.orden");
    
    alSO = SQLMgr.getDataList("select a.codigo, a.descripcion, b.verificado, b.observacion, decode(b.codigo_param,null,'I','U') action, a.bloquear from tbl_sal_pausa_seguridad_params a, tbl_sal_pausa_seguridad b where a.tipo = 'SO' and a.grupo = '"+fg+"' and a.estado = 'A' and a.codigo = b.codigo_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and a.tipo = b.tipo(+) and b.fecha(+) = to_date('"+rev.getColValue("fecha")+"','dd/mm/yyyy hh12:mi am') and a.grupo = b.grupo(+) order by a.orden");
}
System.out.println("................................... tab = "+tab);
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
document.title = 'Revisión Preoperatoria - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}
function isChecked(k,trueFalse){}

function setEvaluacion(k, fecha, hora){
    var modeSec = "view";
    if (fecha == "<%=fecha%>") modeSec = "edit";
    window.location= '../expediente3.0/exp_revision_preoperatoria.jsp?modeSec='+modeSec+'&mode=<%=mode%>&seccion=<%=seccion%>&fg=<%=fg%>&desc=<%=desc%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha='+fecha+'&hora='+hora;}
function add(fecha,hora){window.location= '../expediente3.0/exp_revision_preoperatoria.jsp?seccion=<%=seccion%>&desc=<%=desc%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&fecha='+fecha+'&hora='+hora;}
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=exp_verif_cuidad_pre_oper');}

function verHistorial() {$("#hist_container").toggle();}

function listProc(){
	abrir_ventana1('../expediente/listado_procedimiento.jsp?fp=exp_verif_cuidad_pre_oper');
}

$(function(){
    $('iframe').iFrameResize({
        log: false
    });
    
    // printing
    $("#imprimir").click(function(){
        var fecha = '<%=fecha%> <%=hora%>';
        abrir_ventana1('../expediente3.0/print_revision_preoperatoria.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fecha='+fecha+'&mode=<%=modeSec%>&seccion=<%=seccion%>&fg=<%=fg%>');
    });
});
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">

<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform">
        <table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
            <tr>
                <td>
                      <%=fb.button("imprimir","Imprimir",false,false,"btn btn-inverse btn-sm",null,"")%>
                      <%if(!mode.trim().equals("view")){%>
                        <button type="button" class="btn btn-inverse btn-sm" onclick="add('<%=cDate.substring(0,10)%>','<%=cDate.substring(11)%>')">
                          <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
                        </button>
                      <%}%>
					  
					  <%if(al2.size() > 0){%>
                      <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
                        <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
                      </button>
					  <%}%>
                </td>
            </tr>
        </table>
    </div>
    
    <ul class="nav nav-tabs" role="tablist">    
        <li role="presentation" class="<%=active0%>">
            <a href="#datos_generales" aria-controls="datos_generales" role="tab" data-toggle="tab"><b>GENERALES</b></a>
        </li>
    
        <%if (!modeSec.equalsIgnoreCase("add")){%>
            <li role="presentation" class="<%=active4%>">
                <a href="#verificacion_pre_ope" aria-controls="verificacion_pre_ope" role="tab" data-toggle="tab"><b>VERIFICACI&Oacute;N PRE-OPERATORIA</b></a>
            </li>
            <li role="presentation" class="<%=active1%>">
                <a href="#time_out" aria-controls="time_out" role="tab" data-toggle="tab"><b>PAUSA DE SEGURIDAD (TIME OUT)</b></a>
            </li>
            <li role="presentation" class="<%=active3%>">
                <a href="#sign_out" aria-controls="sign_out" role="tab" data-toggle="tab"><b>VERIFICACI&Oacute;N POST OPERATORIA</b></a>
            </li>
            <li role="presentation" class="<%=active2%>">
                <a href="#documentos" aria-controls="documentos" role="tab" data-toggle="tab"><b>MARCA SITIO QUIR&Uacute;RGICO</b></a>
            </li>
        <%}%>
    </ul>

    <div class="table-wrapper" id="hist_container" style="display:none">
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
            <thead>
                <tr class="bg-headtabla2">
                <th style="vertical-align: middle !important;">Fecha</th>
                <th style="vertical-align: middle !important;">Hora</th>
                <th style="vertical-align: middle !important;">Creado por</th>
                <th style="vertical-align: middle !important;">Modificado el</th>
                <th style="vertical-align: middle !important;">Modificado por</th>
            </thead>
            <%
            for (int i=1; i<=al2.size(); i++){
                CommonDataObject cdo1 = (CommonDataObject) al2.get(i-1);
                String color = "TextRow02";
                if (i % 2 == 0) color = "TextRow01";
            %>
                    <tr onClick="javascript:setEvaluacion(<%=i%>,'<%=cdo1.getColValue("fecha")%>','<%=cdo1.getColValue("hora")%>')" style="text-decoration:none; cursor:pointer">
                        <td><%=cdo1.getColValue("fecha")%></td>
                        <td><%=cdo1.getColValue("hora")%></td>
                        <td><%=cdo1.getColValue("usuario_creacion")%></td>
                        <td><%=cdo1.getColValue("fecha_modif")%></td>
                        <td><%=cdo1.getColValue("usuario_modif")%></td>
                    </tr>
            <%}%>
        </table>    
    </div>
    
    <div class="tab-content">
    <div role="tabpanel" class="tab-pane <%=active0%>" id="datos_generales">
    
    <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("usuarioCreacion",rev.getColValue("usuarioCreacion"))%>
<%=fb.hidden("fechaCreacion",rev.getColValue("fechaCreacion"))%>
<%=fb.hidden("empProvincia",rev.getColValue("empProvincia"))%>
<%=fb.hidden("empSigla",rev.getColValue("empSigla"))%>
<%=fb.hidden("empTomo",rev.getColValue("empTomo"))%>
<%=fb.hidden("empAsiento",rev.getColValue("empAsiento"))%>
<%=fb.hidden("empCompania",rev.getColValue("empCompania"))%>
<%=fb.hidden("empId", rev.getColValue("empId"))%>	
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("tab", "0")%>
<%=fb.hidden("fg", fg)%>

    <table cellspacing="0" class="table table-small-font table-bordered table-striped">

    <tr>
        <td class="controls form-inline">
            <b><cellbytelabel id="3">Fecha</cellbytelabel>:</b>&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="fecha" />
                <jsp:param name="valueOfTBox1" value="<%=rev.getColValue("fecha"," ").trim().substring(0,10)%>" />
                <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
            </jsp:include>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <b><cellbytelabel id="4">Hora</cellbytelabel>:</b>&nbsp;&nbsp;&nbsp;&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1"/>
            <jsp:param name="format" value="hh12:mi am"/>
            <jsp:param name="nameOfTBox1" value="hora" />
            <jsp:param name="valueOfTBox1" value="<%=rev.getColValue("fecha", " ").trim().substring(11)%>" />
            <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
            </jsp:include>
            </td>
        </tr>
									
        <tr>
          <td class="controls form-inline">
            <b><cellbytelabel id="7">Cirug&iacute;a</cellbytelabel>:</b>&nbsp;
            <%=fb.hidden("cirugia", rev.getColValue("cirugia"))%>
            <%=fb.textBox("desc_cirugia", rev.getColValue("desc_cirugia"),false,false,viewMode,255,"form-control input-sm","display:inline; width:80%",null)%>
			<%=fb.button("btnProc","...",false,viewMode,"btn btn-primary btn-sm",null,"onClick=\"javascript:listProc()\"")%>
          </td>
        </tr>
        
        <tr>
          <td class="controls form-inline">
            <b><cellbytelabel id="7">M&eacute;dico Cirujano</cellbytelabel>:</b>&nbsp;
            <%=fb.hidden("cirujano", rev.getColValue("cirujano"))%>
            <%=fb.textBox("desc_medico_cirujano", rev.getColValue("desc_medico_cirujano"),false,false,true,0,"form-control input-sm","display:inline; width:80%",null)%>
            &nbsp;&nbsp;&nbsp;
            <%=fb.button("medico","...",true,viewMode,"btn btn-primary btn-sm",null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
          </td>
        </tr>
        
        <tr>
          <td class="controls form-inline">
            <b><cellbytelabel id="7">Observaciones Generales</cellbytelabel></b>
            <%=fb.textarea("observ",rev.getColValue("observacion"),false,false,viewMode,0,1,2000,"form-control input-sm","width:100%",null)%>
          </td>
        </tr>
    </table>
    
    <!--
    <table cellspacing="0" class="table table-small-font table-bordered table-striped">
        <tr align="center" class="bg-headtabla">
            <td width="55%"><cellbytelabel id="10">Factores</cellbytelabel></td>
            <td width="5%"><cellbytelabel id="11">S&iacute;</cellbytelabel></td>
            <td width="5%"><cellbytelabel id="12">No</cellbytelabel></td>
            <td width="35%"><cellbytelabel id="13">Espec&iacute;fique</cellbytelabel></td>
        </tr>
        <% for (int i=0; i<al.size(); i++) {
            RespuestaRevision rresp = (RespuestaRevision) al.get(i);
        %>
        <%=fb.hidden("codigo"+i,rresp.getPregunta())%>
        <tr>
            <td><%=rresp.getDescripcion()%></td>
            <td align="center"><%=fb.radio("respuesta"+i,"S",rresp.getRespuesta().trim().equals("S"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td align="center"><%=fb.radio("respuesta"+i,"N",rresp.getRespuesta().trim().equals("N"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td><%=fb.textarea("observacion"+i,rresp.getObservacion(),false,false,viewMode,22,1,2000,"form-control input-sm","width:100%",null)%></td>
        </tr>
        <%}%>
        </table>
        -->
        
        <div class="footerform">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
               <td>
                    <%=fb.hidden("saveOption","O")%>
                    <%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"")%>
                    <%=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onclick=\"parent.parent.doRedirect(0)\"")%>
                </td>
            </tr>
            </table>   
        </div>
        <%=fb.formEnd(true)%>
        </div> <!-- Generales -->
        
        <div role="tabpanel" class="tab-pane <%=active4%>" id="verificacion_pre_ope">
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
        <%=fb.hidden("size",""+al.size())%>
        <%=fb.hidden("usuarioCreacion",rev.getColValue("usuarioCreacion"))%>
		<%=fb.hidden("fechaCreacion",rev.getColValue("fechaCreacion"))%>
		<%=fb.hidden("empProvincia",rev.getColValue("empProvincia"))%>
		<%=fb.hidden("empSigla",rev.getColValue("empSigla"))%>
		<%=fb.hidden("empTomo",rev.getColValue("empTomo"))%>
		<%=fb.hidden("empAsiento",rev.getColValue("empAsiento"))%>
		<%=fb.hidden("empCompania",rev.getColValue("empCompania"))%>
		<%=fb.hidden("empId", rev.getColValue("empId"))%>
        <%=fb.hidden("desc",desc)%>
        <%=fb.hidden("tab", "4")%>
        <%=fb.hidden("fecha", fecha)%>
        <%=fb.hidden("hora", hora)%>
        <%=fb.hidden("sizeVP", ""+alVP.size())%>
        <%=fb.hidden("fecha_completa", rev.getColValue("fecha"))%>
        <%=fb.hidden("fg", fg)%>

        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
            <tr class="bg-headtabla2">
            <td width="65%"></td>
            <td align="center" width="10%">SI</td>
            <td align="center" width="10%">NO</td>
            <td align="center" width="15%">NO APLICA</td>
        </tr>
        
        <%
        for (int t = 0; t < alVP.size(); t++){
            cdo = (CommonDataObject) alVP.get(t);
        %>
        <%=fb.hidden("action"+t, cdo.getColValue("action"))%>
        <%=fb.hidden("codigo_param"+t, cdo.getColValue("codigo"))%>
        <tr>
            <td><%=cdo.getColValue("descripcion")%></td>
            <td align="center"><%=fb.radio("verificado"+t,"S",cdo.getColValue("verificado"," ").trim().equals("S"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td align="center"><%=fb.radio("verificado"+t,"N",cdo.getColValue("verificado"," ").trim().equals("N"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td align="center"><%=fb.radio("verificado"+t,"X",cdo.getColValue("verificado"," ").trim().equals("X"),cdo.getColValue("bloquear","N").trim().equals("S") || viewMode,false,"form-control input-sm",null,"")%></td>
        </tr>
        <%    
        }
        %>
        </table>
        
        
        <div class="footerform">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
               <td>
                    <%=fb.hidden("saveOption","O")%>
                    <%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"")%>
                    <%=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onclick=\"parent.parent.doRedirect(0)\"")%>
                </td>
            </tr>
            </table>   
        </div>
        <%=fb.formEnd(true)%>
        </div> <!-- VERIFICACIÓN PRE-OPERATORIA -->

        
        
        
        <div role="tabpanel" class="tab-pane <%=active1%>" id="time_out">
    
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
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("usuarioCreacion",rev.getColValue("usuarioCreacion"))%>
<%=fb.hidden("fechaCreacion",rev.getColValue("fechaCreacion"))%>
<%=fb.hidden("empProvincia",rev.getColValue("empProvincia"))%>
<%=fb.hidden("empSigla",rev.getColValue("empSigla"))%>
<%=fb.hidden("empTomo",rev.getColValue("empTomo"))%>
<%=fb.hidden("empAsiento",rev.getColValue("empAsiento"))%>
<%=fb.hidden("empCompania",rev.getColValue("empCompania"))%>
<%=fb.hidden("empId", rev.getColValue("empId"))%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("tab", "1")%>
<%=fb.hidden("fecha", fecha)%>
<%=fb.hidden("hora", hora)%>
<%=fb.hidden("sizeTO", ""+alTO.size())%>
<%=fb.hidden("fecha_completa", rev.getColValue("fecha"))%>
<%=fb.hidden("fg", fg)%>

    <table cellspacing="0" class="table table-small-font table-bordered table-striped">
        <tr class="bg-headtabla2">
            <td></td>
            <td colspan="2">Indentificaci&oacute;n correcta del paciente</td>
            <td colspan="2">Procedimiento Correcto a realizar</td>
            <td colspan="2">Sitio Correcto del procedimiento invasivo o quir&uacute;rgico </td>
        </tr>
        <tr class="bg-headtabla2">
            <td></td>
            <td align="center">SI</td>
            <td align="center">NO</td>
            <td align="center">SI</td>
            <td align="center">NO</td>
            <td align="center">SI</td>
            <td align="center">NO</td>
        </tr>
        
        <%
        for (int t = 0; t < alTO.size(); t++){
            cdo = (CommonDataObject) alTO.get(t);
        %>
        <%=fb.hidden("action"+t, cdo.getColValue("action"))%>
        <%=fb.hidden("codigo_param"+t, cdo.getColValue("codigo"))%>
        <tr>
            <td><%=cdo.getColValue("descripcion")%></td>
            <td align="center"><%=fb.radio("identificacion_pac"+t,"S",cdo.getColValue("identificacion_pac"," ").trim().equals("S"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td align="center"><%=fb.radio("identificacion_pac"+t,"N",cdo.getColValue("identificacion_pac"," ").trim().equals("N"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td align="center"><%=fb.radio("proc_correcto"+t,"S",cdo.getColValue("proc_correcto"," ").trim().equals("S"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td align="center"><%=fb.radio("proc_correcto"+t,"N",cdo.getColValue("proc_correcto"," ").trim().equals("N"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td align="center"><%=fb.radio("sitio_correcto"+t,"S",cdo.getColValue("sitio_correcto"," ").trim().equals("S"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td align="center"><%=fb.radio("sitio_correcto"+t,"N",cdo.getColValue("sitio_correcto"," ").trim().equals("N"),viewMode,false,"form-control input-sm",null,"")%></td>
        </tr>
        <%    
        }
        %>
    
    </table>
    
    <div class="footerform">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
               <td>
                    <%=fb.hidden("saveOption","O")%>
                    <%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"")%>
                    <%=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onclick=\"parent.parent.doRedirect(0)\"")%>
                </td>
            </tr>
            </table>   
        </div>
    
<%=fb.formEnd(true)%>
</div> <!-- Time out -->

<div role="tabpanel" class="tab-pane <%=active3%>" id="sign_out">
    
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
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("usuarioCreacion",rev.getColValue("usuarioCreacion"))%>
<%=fb.hidden("fechaCreacion",rev.getColValue("fechaCreacion"))%>
<%=fb.hidden("empProvincia",rev.getColValue("empProvincia"))%>
<%=fb.hidden("empSigla",rev.getColValue("empSigla"))%>
<%=fb.hidden("empTomo",rev.getColValue("empTomo"))%>
<%=fb.hidden("empAsiento",rev.getColValue("empAsiento"))%>
<%=fb.hidden("empCompania",rev.getColValue("empCompania"))%>
<%=fb.hidden("empId", rev.getColValue("empId"))%>	
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("tab", "3")%>
<%=fb.hidden("fecha", fecha)%>
<%=fb.hidden("hora", hora)%>
<%=fb.hidden("sizeSO", ""+alSO.size())%>
<%=fb.hidden("fecha_completa", rev.getColValue("fecha"))%>
<%=fb.hidden("fg", fg)%>


    <table cellspacing="0" class="table table-small-font table-bordered table-striped">
        <tr class="bg-headtabla2">
            <td width="65%"></td>
            <td align="center" width="10%">SI</td>
            <td align="center" width="10%">NO</td>
            <td align="center" width="15%">NO APLICA</td>
        </tr>
        
        <%
        for (int t = 0; t < alSO.size(); t++){
            cdo = (CommonDataObject) alSO.get(t);
        %>
        <%=fb.hidden("action"+t, cdo.getColValue("action"))%>
        <%=fb.hidden("codigo_param"+t, cdo.getColValue("codigo"))%>
        <tr>
            <td><%=cdo.getColValue("descripcion")%></td>
            <td align="center"><%=fb.radio("verificado"+t,"S",cdo.getColValue("verificado"," ").trim().equals("S"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td align="center"><%=fb.radio("verificado"+t,"N",cdo.getColValue("verificado"," ").trim().equals("N"),viewMode,false,"form-control input-sm",null,"")%></td>
            <td align="center"><%=fb.radio("verificado"+t,"X",cdo.getColValue("verificado"," ").trim().equals("X"),cdo.getColValue("bloquear","N").trim().equals("S") || viewMode,false,"form-control input-sm",null,"")%></td>
        </tr>
        <%    
        }
        %>
    
    </table>
    
    <div class="footerform">
            <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
               <td>
                    <%=fb.hidden("saveOption","O")%>
                    <%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"")%>
                    <%=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onclick=\"parent.parent.doRedirect(0)\"")%>
                </td>
            </tr>
            </table>   
        </div>
    
<%=fb.formEnd(true)%>
</div> <!-- Sign out -->
        
        <div role="tabpanel" class="tab-pane <%=active2%>" id="documentos">
    <table width="100%" cellpadding="1" cellspacing="1" >
            <tr> <!-- hist_pat-->
                <td>
                    <iframe id="doc_esc" name="doc_esc" width="100%" scrolling="yes" frameborder="0" src="../expediente3.0/exp_documentos.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&exp=3&expStatus=<%=request.getParameter("estado")!=null?request.getParameter("estado"):""%>&area_revision=SL&docs_for=revision_preoperatoria&docId=47"></iframe>
                </td>
            </tr>
        </table>
</div> <!-- Documentos -->
        
        
        
        
        
        </div>
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
    String errCode = "", errMsg = "";
    
    System.out.println(".................................................. alVP.size() = "+alVP.size());
	fecha = request.getParameter("fecha");
	hora  = request.getParameter("hora");
    
    if (tab.equals("0")){
    
	int size= 0;
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
		
    CommonDataObject revi = new CommonDataObject();
    revi.setTableName("tbl_sal_revision_preoperatoria");
    
    if (modeSec.equalsIgnoreCase("add")){
        revi.addColValue("cod_paciente", request.getParameter("codPac"));
        revi.addColValue("fec_nacimiento", request.getParameter("dob"));
        revi.addColValue("pac_id", request.getParameter("pacId"));
        revi.addColValue("secuencia", request.getParameter("noAdmision"));
        revi.addColValue("fecha", request.getParameter("fecha")+" "+request.getParameter("hora"));
        revi.addColValue("usuario_creacion", request.getParameter("usuarioCreacion"));
        revi.addColValue("fecha_creacion", request.getParameter("fechaCreacion"));
        revi.addColValue("grupo", fg);
    } else {
        revi.addColValue("usuario_modif", (String) session.getAttribute("_userName"));
        revi.addColValue("fecha_modif", cDateTime);
        revi.setWhereClause("pac_id = "+pacId+" and secuencia = "+noAdmision+" and grupo = '"+fg+"' and fecha = to_date('"+request.getParameter("fecha")+" "+request.getParameter("hora")+"','dd/mm/yyyy hh12:mi am')");
    }  

    revi.addColValue("observacion", request.getParameter("observ"));
    revi.addColValue("cirugia", request.getParameter("cirugia"));
    revi.addColValue("desc_cirugia", request.getParameter("desc_cirugia"));
    revi.addColValue("medico_cirujano", request.getParameter("cirujano"));
    revi.addColValue("desc_medico_cirujano", request.getParameter("desc_medico_cirujano"));

    if (baction.equalsIgnoreCase("Guardar")){
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        if (modeSec.equalsIgnoreCase("add")){
            SQLMgr.insert(revi);
        }
        else if (modeSec.equalsIgnoreCase("edit")){
            SQLMgr.update(revi);
        }
        ConMgr.clearAppCtx(null);
        
    }
    errCode = SQLMgr.getErrCode();
    errMsg = SQLMgr.getErrMsg();
} //tab0
else if (tab.equals("1")) {

al.clear();
    
    int size= 0;
	if (request.getParameter("sizeTO") != null) size = Integer.parseInt(request.getParameter("sizeTO"));
    for (int i=0; i<size; i++) {
        if (request.getParameter("identificacion_pac"+i) != null||request.getParameter("proc_correcto"+i) != null||request.getParameter("sitio_correcto"+i) != null) {
            cdo = new CommonDataObject();
            cdo.addColValue("identificacion_pac", request.getParameter("identificacion_pac"+i));
            cdo.addColValue("proc_correcto", request.getParameter("proc_correcto"+i));
            cdo.addColValue("sitio_correcto", request.getParameter("sitio_correcto"+i));
            cdo.setTableName("tbl_sal_pausa_seguridad");
            if (request.getParameter("action"+i)!=null&&request.getParameter("action"+i).equalsIgnoreCase("I")) {
                cdo.addColValue("codigo_param", request.getParameter("codigo_param"+i));
                cdo.addColValue("pac_id", pacId);
                cdo.addColValue("admision", noAdmision);
                cdo.addColValue("tipo", "TO");
                cdo.addColValue("grupo", fg);
                cdo.addColValue("fecha_creacion", cDateTime);
                cdo.addColValue("fecha", request.getParameter("fecha_completa"));
                cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
                cdo.setAction("I");
            } else {
                cdo.addColValue("fecha_modificacion", cDateTime);
                cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
                cdo.setAction("U");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'TO' and codigo_param = "+request.getParameter("codigo_param"+i)+" and fecha = to_date('"+request.getParameter("fecha_completa")+"','dd/mm/yyyy hh12:mi am') and grupo = '"+fg+"'");
            }
            al.add(cdo);
        }
    }
    
    if (al.size() < 1) {
        cdo  = new CommonDataObject();
        cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'TO' and grupo = '"+fg+"'");
        cdo.setTableName("tbl_sal_pausa_seguridad");
        cdo.setAction("I");
        al.add(cdo);
    }
   
    if (baction.equalsIgnoreCase("Guardar")) {
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        ConMgr.setAppCtx(ConMgr.AUDIT_NOTES, "Tipo = TO, tab = "+tab);
        SQLMgr.saveList(al,true);
        ConMgr.clearAppCtx(null);
    }
    errCode = SQLMgr.getErrCode();
    errMsg = SQLMgr.getErrMsg();

} //tab1
else if (tab.equals("3")) {

al.clear();
    
    int size= 0;
	if (request.getParameter("sizeSO") != null) size = Integer.parseInt(request.getParameter("sizeSO"));
    for (int i=0; i<size; i++) {
        if (request.getParameter("verificado"+i) != null) {
            cdo = new CommonDataObject();
            cdo.addColValue("verificado", request.getParameter("verificado"+i));
            cdo.setTableName("tbl_sal_pausa_seguridad");
            if (request.getParameter("action"+i)!=null&&request.getParameter("action"+i).equalsIgnoreCase("I")) {
                cdo.addColValue("codigo_param", request.getParameter("codigo_param"+i));
                cdo.addColValue("pac_id", pacId);
                cdo.addColValue("admision", noAdmision);
                cdo.addColValue("tipo", "SO");
                cdo.addColValue("grupo", fg);
                cdo.addColValue("fecha_creacion", cDateTime);
                cdo.addColValue("fecha", request.getParameter("fecha_completa"));
                cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
                cdo.setAction("I");
            } else {
                cdo.addColValue("fecha_modificacion", cDateTime);
                cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
                cdo.setAction("U");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'SO' and codigo_param = "+request.getParameter("codigo_param"+i)+" and fecha = to_date('"+request.getParameter("fecha_completa")+"','dd/mm/yyyy hh12:mi am') and grupo = '"+fg+"'");
            }
            al.add(cdo);
        }
    }
    
    if (al.size() < 1) {
        cdo  = new CommonDataObject();
        cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'SO' and grupo = '"+fg+"'");
        cdo.setTableName("tbl_sal_pausa_seguridad");
        cdo.setAction("I");
        al.add(cdo);
    }
   
    if (baction.equalsIgnoreCase("Guardar")) {
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        ConMgr.setAppCtx(ConMgr.AUDIT_NOTES, "Tipo = SO, tab = "+tab);
        SQLMgr.saveList(al,true);
        ConMgr.clearAppCtx(null);
    }
    errCode = SQLMgr.getErrCode();
    errMsg = SQLMgr.getErrMsg();

} //tab3
else if (tab.equals("4")) {
    al.clear();
    
    int size= 0;
	if (request.getParameter("sizeVP") != null) size = Integer.parseInt(request.getParameter("sizeVP"));
    for (int i=0; i<size; i++) {
        if (request.getParameter("verificado"+i) != null) {
            cdo = new CommonDataObject();
            cdo.addColValue("verificado", request.getParameter("verificado"+i));
            cdo.setTableName("tbl_sal_pausa_seguridad");
            if (request.getParameter("action"+i)!=null&&request.getParameter("action"+i).equalsIgnoreCase("I")) {
                cdo.addColValue("codigo_param", request.getParameter("codigo_param"+i));
                cdo.addColValue("pac_id", pacId);
                cdo.addColValue("admision", noAdmision);
                cdo.addColValue("tipo", "VP");
                cdo.addColValue("grupo", fg);
                cdo.addColValue("fecha_creacion", cDateTime);
                cdo.addColValue("fecha", request.getParameter("fecha_completa"));
                cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
                cdo.setAction("I");
            } else {
                cdo.addColValue("fecha_modificacion", cDateTime);
                cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
                cdo.setAction("U");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'VP' and codigo_param = "+request.getParameter("codigo_param"+i)+" and fecha = to_date('"+request.getParameter("fecha_completa")+"','dd/mm/yyyy hh12:mi am') and grupo = '"+fg+"'");
            }
            al.add(cdo);
        }
    }
    
    if (al.size() < 1) {
        cdo  = new CommonDataObject();
        cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'VP' and grupo = '"+fg+"'");
        cdo.setTableName("tbl_sal_pausa_seguridad");
        cdo.setAction("I");
        al.add(cdo);
    }
   
    if (baction.equalsIgnoreCase("Guardar")) {
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        ConMgr.setAppCtx(ConMgr.AUDIT_NOTES, "Tipo = VP, tab = "+tab);
        SQLMgr.saveList(al,true);
        ConMgr.clearAppCtx(null);
    }
    errCode = SQLMgr.getErrCode();
    errMsg = SQLMgr.getErrMsg();
} //tab4


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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha=<%=fecha%>&hora=<%=hora%>&desc=<%=desc%>&tab=<%=tab%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
