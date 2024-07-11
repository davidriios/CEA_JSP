<%//@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="java.util.ArrayList" %>
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

CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();

boolean viewMode = false;
String sql = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String estado = request.getParameter("estado");

if (fg == null) fg = "NEEU";
if (estado == null) estado = "";

if (estado.equalsIgnoreCase("F")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
  al = SQLMgr.getDataList("select codigo, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha, to_char(fecha_creacion, 'hh12:mi:ss am') hora, nota from tbl_sal_notas_cambio where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = '"+fg+"' order by 1 desc");
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
$(function(){
  $("#imprimir").click(function(){
    var codigo = $("#codigo").val() || 0;
    abrir_ventana('../expediente3.0/print_notas_de_cambio.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&codigo='+codigo);
  });
});
function verHistorial() {$("#hist_container").toggle();}

function doSubmit() {
  var nota = $("#nota").val() || '';
  var btnSave = $("#save");
  var fData = {
    pacId: "<%=pacId%>",
    noAdmision: "<%=noAdmision%>",
    tipo: "<%=fg%>",
    nota: nota,
  };
  
  if ($.trim(nota)) {
    btnSave.attr("disabled", true);
    $.post('../expediente3.0/exp_notas_de_cambio.jsp', fData)
     .done(function(response){
        response = $.trim(response);
        if (response && response != 'SUCCESS') {
          btnSave.attr("disabled", false);
          CBMSG.error(response);
        } else {
          btnSave.attr("disabled", false);
          CBMSG.alert("Se han guardado satisfactoriamente las notas de cambio!");
          $("#nota").val("");
        }
     })
     .fail(function(xhr, status, statusText){
       CBMSG.error(statusText);
       btnSave.attr("disabled", false);
     });
  }
}

function setNotasCambio(i) {
  $("#nota").val($("#nota"+i).val());
  $("#codigo").val($("#codigo"+i).val());
  $("#save").attr("disabled", true);
}
</script>
<style>
    .table>tbody>tr>td, .table>tbody>tr>th, .table>tfoot>tr>td, .table>tfoot>tr>th, .table>thead>tr>td, .table>thead>tr>th {vertical-align:top !important;}
</style>
</head>
<body class="body-form">
<div class="row">    
    <div class="table-responsive" data-pattern="priority-columns">
        <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
        <%=fb.formStart(true)%>
        <%=fb.hidden("pacId",pacId)%>
        <%=fb.hidden("noAdmision",noAdmision)%>
        <%=fb.hidden("fg",fg)%>
        <%=fb.hidden("codigo","")%>

        <table cellspacing="0" width="100%">
            <tr> 
                <td align="right" class="controls form-inline">
                    <%=fb.button("imprimir","Imprimir",false,false,null,null,"")%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
                      <i class="fa fa-eye"></i> <b>Historial</b>
                    </button>
                </td>
            </tr>
            
            <tr id="hist_container" style="display:none">
                <td>
                    <table cellspacing="0" width="100%" class="table table-bordered table-striped table-hover">
                       <tr class="bg-headtabla2">
                          <td>C&oacute;digo</td>
                          <td>Fecha</td>
                          <td>Hora</td>
                          <td>Usuario</td>
                       </tr>
                       <%for (int i = 0; i<al.size(); i++){
                        cdo = (CommonDataObject) al.get(i);
                       %>
                       <%=fb.hidden("codigo"+i, cdo.getColValue("codigo"))%>
                       <%=fb.hidden("nota"+i,cdo.getColValue("nota"))%>
                       <tbody>
                            <tr class="pointer" onclick="setNotasCambio(<%=i%>)">
                                <td><%=cdo.getColValue("codigo")%></td>
                                <td><%=cdo.getColValue("fecha")%></td>
                                <td><%=cdo.getColValue("Hora")%></td>
                                <td><%=cdo.getColValue("usuario_creacion")%></td>
                            </tr>
                        </tbody>
                       <%}%>
                    </table>
                </td>
            </tr>
            
            <tbody>
            <tr>
                <td>
                    <b><cellbytelabel>Indique modificaci&oacute;n</cellbytelabel>:</b>
                    <%=fb.textarea("nota","",false,false,viewMode,75,0,2000,"form-control input-sm","width:100%",null)%>
                </td>
            </tr>
            </tbody>
            
            <tbody>
            <tr>
                <td align="right">
                    <button type="button" class="btn btn-inverse btn-sm" onclick="doSubmit()" name="save" id="save"<%=viewMode?" disabled":""%>><i class="fa fa-save"></i> Guardar</button>
                </td>
            </tr>
            </tbody>
                
        </table>
        <%=fb.formEnd(true)%>
    </div>
</div>
</body>
</html>
<%
}else {
   
   cdo = new CommonDataObject();
   cdo.setTableName("tbl_sal_notas_cambio");
   cdo.addColValue("nota", request.getParameter("nota"));
   cdo.addColValue("tipo", request.getParameter("tipo"));
   cdo.addColValue("pac_id", request.getParameter("pacId"));
   cdo.addColValue("admision", request.getParameter("noAdmision"));
   cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
   cdo.addColValue("fecha_creacion", "sysdate");
   cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
   cdo.addColValue("fecha_modificacion", "sysdate");
   
   cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
   
   cdo.setAutoIncCol("codigo");
   cdo.addPkColValue("codigo","");
   
   SQLMgr.insert(cdo);
    
    if (SQLMgr.getErrCode().equals("1")) out.print("SUCCESS");
    else out.print(SQLMgr.getErrMsg());
}
%>