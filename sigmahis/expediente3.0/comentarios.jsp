<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="com.google.gson.Gson"%>
<%@ page import="com.google.gson.JsonObject"%>
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
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String code = request.getParameter("code");
String fg = request.getParameter("fg");
String estadoExp = request.getParameter("estado");
String mostrarTodo  = request.getParameter("mostrar_todo");
String key = "";
int progresoLineNo = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");

if (fg == null) fg = "";
if (code == null) code = "0";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (mostrarTodo  == null) mostrarTodo  = "";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getMethod().equalsIgnoreCase("GET"))
{
    sql = "select comentario_id, to_char(fecha, 'dd/mm/yyyy') fecha, to_char(fecha, 'hh12:mi am') hora, decode(estado,'I', 'INVALIDADO', 'VALIDO') estado_dsp, estado, necesita_resp, respuesta, comentario, no_mas_resp from TBL_SAL_comentarios where pac_id = "+pacId+" and admision = "+noAdmision;
    
    if (mostrarTodo.equalsIgnoreCase("")) sql += " and necesita_resp = 'S' ";
    sql += " order by 1 desc ";
    
    ArrayList alL = SQLMgr.getDataList(sql);

    if (estadoExp.equalsIgnoreCase("F")) {
      viewMode = true;
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
document.title = 'Comentarios - '+document.title;
var noNewHeight = true;
function doAction(){$("#loadingmsg").remove()}
function add(){
parent.showPopWin('../expediente3.0/comentarios_add.jsp?modeSec=add&estado=<%=estadoExp%>&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&fg=<%=fg%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0', winWidth*.75, winHeight*.75, null, null, '');
}

function showAll() {
  window.location = '../expediente3.0/comentarios.jsp?modeSec=&estado=<%=estadoExp%>&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&fg=<%=fg%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0&mostrar_todo=Y';
}

$(function(){
 // reloading alerts
  if (typeof parent.reloadAlerts === 'function') parent.reloadAlerts();
  else if (typeof parent.parent.reloadAlerts === 'function') parent.parent.reloadAlerts();
});

function doSubmit(form, value) {
  __submitForm(form, value);
}

function printExp(option){
    if(!option) abrir_ventana("../expediente3.0/print_comentarios.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code=0");
    else abrir_ventana("../expediente3.0/print_comentarios.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code="+option);
}

function responder(comentarioId) {
  parent.showPopWin('../expediente3.0/comentarios_add.jsp?modeSec=add&estado=<%=estadoExp%>&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&fg=<%=fg%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code='+comentarioId, winWidth*.75, winHeight*.85, null, null, '');
}

$(function() {
  
  $(".btn-close-reply").click(function(e){
      e.preventDefault();
      var that = $(this);
      
      if (!that.hasClass('processing')) {
        
          that.addClass("processing")
     
          var h = that.data('h');
          var comentarioId = that.data('comentario_id');

          $.ajax({
            url: "<%=request.getContextPath()%>/expediente3.0/comentarios_add.jsp",
            method: 'POST', 
            data: {
              pacId: "<%=pacId%>", 
              noAdmision: "<%=noAdmision%>",
              seccion: "<%=seccion%>",
              comentario_id: comentarioId,
              baction: 'Cerrar_Respuesta', 
              saveOption: 'O', 
            }
          }).done(function(response) {
            window.location.reload()
          }).fail(function(error) {
            that.removeClass('processing');
            alert(error.responseJSON.msg);
            console.log("error = ",  error)
          });
      }
    });
    
    $(".btn-inactivate").click(function(e){
      e.preventDefault();
      var that = $(this);
      
      if (!that.hasClass('processing')) {
        
          that.addClass("processing")
     
          var h = that.data('h');
          var comentarioId = that.data('comentario_id');

          $.ajax({
            url: "<%=request.getContextPath()%>/expediente3.0/comentarios_add.jsp",
            method: 'POST', 
            data: {
              pacId: "<%=pacId%>", 
              noAdmision: "<%=noAdmision%>",
              seccion: "<%=seccion%>",
              comentario_id: comentarioId,
              baction: 'Invalidar', 
              saveOption: 'O', 
            }
          }).done(function(response) {
            window.location.reload()
          }).fail(function(error) {
            that.removeClass('processing');
            alert(error.responseJSON.msg);
            console.log("error = ",  error)
          });
      }
    });
});
</script>
<style>
</style>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive">
<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-1">
    <tr>
        <td>
            <button type="button" class="btn btn-inverse btn-sm" onclick="showAll()">
              <i class="fa fa-list"></i> Mostrar Todos
            </button>
            
            <button type="button" class="btn btn-inverse btn-sm" onclick="add()"<%=viewMode?" disabled":""%>>
              <i class="fa fa-plus"></i> <b>Agregar</b>
            </button>

            <button type="button" class="btn btn-inverse btn-sm" onclick="javascript:printExp()"><i class="fa fa-print "></i> Imprimir Todos</button>
        </td>
    </tr>
</table>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-stripe-inactive">
    <thead>
    <tr class="bg-headtabla2">
        <th style="vertical-align: middle !important;" width="7%">C&oacute;digo</th>
        <th style="vertical-align: middle !important;" width="13%">Fecha</th>
        <th style="vertical-align: middle !important;" width="10%">Estado</th>
        <th style="vertical-align: middle !important;" width="50%">Comentario</th>
        <th style="vertical-align: middle !important;" width="20%"></th>
        </tr>
    </thead>
    <tbody>
    <%for (int h = 0; h < alL.size(); h++){
      CommonDataObject cdoH = (CommonDataObject) alL.get(h);
      %>
      <tr>
          <td><%=cdoH.getColValue("comentario_id")%></td>
          <td><%=cdoH.getColValue("fecha")%> <%=cdoH.getColValue("hora")%></td>
          <td><%=cdoH.getColValue("estado_dsp")%></td>
          <td><%=cdoH.getColValue("comentario")%></td>
          <td align="center">
              
              <%if(cdoH.getColValue("estado"," ").equalsIgnoreCase("A") && !viewMode){%>
                  <a href="#" class="hint hint--left btn btn-danger btn-xs btn-inactivate" title="Invalidar" data-hint="Invalidar" data-h="<%=h%>" data-comentario_id="<%=cdoH.getColValue("comentario_id")%>"> 
                    <i class="fa fa-times"></i></button>
                  </a>
                  &nbsp;&nbsp;
              <%}%>
              
               <%if(!viewMode && !cdoH.getColValue("no_mas_resp", " ").trim().equalsIgnoreCase("Y")  && !cdoH.getColValue("estado", " ").trim().equalsIgnoreCase("I") && cdoH.getColValue("necesita_resp", " ").trim().equalsIgnoreCase("S") ){%>
                <a href="javascript:responder('<%=cdoH.getColValue("comentario_id")%>')" class="hint hint--left btn btn-primary btn-xs btn-reply" title="Responder" data-hint="Responder" data-h="<%=h%>" data-comentario_id="<%=cdoH.getColValue("comentario_id")%>"> 
                  <i class="fa fa-reply"></i></button>
                </a>&nbsp;&nbsp;
                
                <a href="#" class="hint hint--left btn btn-warning btn-xs btn-close-reply" title="Cerrar Comentario" data-hint="Cerrar Comentario" data-h="<%=h%>" data-comentario_id="<%=cdoH.getColValue("comentario_id")%>"> 
                  <i class="fa fa-microphone-slash"></i></button>
                </a>
                &nbsp;&nbsp;
               <%}%>
               
               <a href="javascript:printExp('<%=cdoH.getColValue("comentario_id")%>')" class="hint hint--left btn btn-success btn-xs" title="Imprimir" data-hint="Imprimir" > 
                  <i class="fa fa-print"></i></button>
                </a>
              
          </td>
      </tr>
      <%
      ArrayList alR = SQLMgr.getDataList("select codigo, comentario_id, respuesta, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi am') fecha_creacion from TBL_SAL_COMENTARIO_REP where comentario_id = " + cdoH.getColValue("comentario_id")+" order by fecha_creacion desc");
      if (alR.size() > 0) {
      %>
      <tr style="background-color: #fff">
        <td colspan="3">&nbsp;</td>
        <td colspan="5">
        
          <table class="table table-small-font table-bordered">
            <%for (int r = 0; r < alR.size(); r++) {
                CommonDataObject cdoR = (CommonDataObject) alR.get(r);
            %>
            <tr>
              <td width="30%"><%=cdoR.getColValue("usuario_creacion")%>  - <%=cdoR.getColValue("fecha_creacion")%></td>
              <td width="70%"><%=cdoR.getColValue("respuesta")%></td>
            </tr>
            
            <%}%>
          </table>

        </td>
      </tr>
      <%}}%>
      </tbody>
    
</table>

</tbody>
</table>

</div>
</div>
</html>
<%
}
%>