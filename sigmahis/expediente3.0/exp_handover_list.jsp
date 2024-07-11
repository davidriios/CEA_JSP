<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
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
Properties prop = new Properties();

StringBuffer sbSql = new StringBuffer();
String cds = request.getParameter("cds");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");

if (cds == null) cds = "";
if (fg == null) fg = "";
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

Hashtable iMotivos = new Hashtable();
iMotivos.put("0","Para Preparación por Cirugía y/o Procedimiento"); 
iMotivos.put("1","Para Cirugía");
iMotivos.put("2","Para Procedimiento"); 
iMotivos.put("3","Para Recuperación de anestesia");
iMotivos.put("4","Traslado a otro servicio");
iMotivos.put("5","Traslado a otra Institución");
iMotivos.put("6","Para examen Radiología"); 
iMotivos.put("7","Otros (Diálisis, Fisioterapia)");

if (request.getMethod().equalsIgnoreCase("GET")) {

    al = SQLMgr.getDataPropertiesList("select params from tbl_sal_traslado_handover where pac_id="+pacId+" and admision="+noAdmision+" order by codigo desc");
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
function consultar() {
  abrir_ventana1('../expediente3.0/exp_handover_list.jsp?seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&cds=<%=cds%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>');
}

$(function(){
  $(".motivo-header").click(function(){
    var self = $(this);
    var i = self.data("i");
    $("#motivo-"+i).toggle();
  });
});
</script>
</head>
<body class="body-form">
<div class="row">

<div class="table-responsive" data-pattern="priority-columns">

    
<table cellspacing="0" class="table table-small-font table-bordered table-striped table-hover">
    <tr class="bg-headtabla2">
        <td colspan="9"><b>HISTORIAL</b></td>
    </tr>
    
    <tr class="bg-headtabla">
        <td>C&oacute;digo</td>
        <td>Fecha</td>
        <td>Persona que reporta</td>
        <td>&Aacute;rea Env&iacute;o</td>	
		<td>Fecha Rec.</td>
        <td>Persona que recibe</td>
        <td>&Aacute;rea Recibe</td>		
		<td>Fecha Reenvio</td>
        <td>Persona que Reporta / recibe</td>
		
    </tr>
    
    <%for (int i = 0; i < al.size(); i++){
        prop = (Properties)al.get(i);
        String motivo = prop.getProperty("motivo");
    %>
        <tr class="motivo-header pointer" data-i="<%=i%>">
            <td><%=prop.getProperty("codigo")%></td>
            <td><%=prop.getProperty("fecha_creacion")%></td>
            <td><%=prop.getProperty("persona_que_reporta")%></td>
            <td><%=prop.getProperty("cds_persona_que_reporta")%></td>
			<td><%=prop.getProperty("fecha_rec")%></td>
            <td><%=prop.getProperty("persona_que_recibe_nombre")%></td>
            <td><%=prop.getProperty("centro_servicio_recibe_desc")%></td>
			
			<td><%=prop.getProperty("fecha_regreso")%></td>
            <td><%=prop.getProperty("persona_que_rep")%> / <%=prop.getProperty("persona_rec")%></td>
             
			
        </tr>
        
        <%if (!"".equals(motivo)) {%>
            <tr id="motivo-<%=i%>" style="display:none">
                <td colspan="6">MOTIVO: <%=iMotivos.get(motivo)%></td>
                <td colspan="3"><%=prop.getProperty("observacion"+motivo)%></td>
            </tr>
        <%}%>
        
    <%}%>
    
    
</table>



</div>
</div>
</body>

</html>

<%
} 
%>
    