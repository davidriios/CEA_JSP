<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
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

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;

if (fg == null) fg = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	

	sql = "select to_char(fecha,'dd/mm/yyyy') as fecha, observacion, dolencia_principal, motivo_hospitalizacion, alergico_a, to_char(hora,'hh12:mi:ss am') as hora,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,usuario_creacion, fn_sal_ant_history("+pacId+", "+noAdmision+", "+seccion+",'secuencia','alergico_a',null,null) history from tbl_sal_padecimiento_admision where pac_id="+pacId+" and secuencia="+noAdmision;
	cdo = SQLMgr.getData(sql);

	if (cdo == null)
	{
		if (!viewMode) modeSec = "add";
		
		cdo = new CommonDataObject();
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("hora", CmnMgr.getCurrentDate("hh12:mi:ss am"));
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion",cDateTime);
	}
	else if (!viewMode) modeSec = "edit";
	
	String history = cdo.getColValue("history")==null?"":"Historial";
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
document.title = 'EXPEDIENTE - Enfermedad Actual - '+document.title;
var noNewHeight = true;
function doAction(){}
function imprimirExp(){abrir_ventana('../expediente3.0/print_exp_seccion_1.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&exp=3');}

$(function(){
  $(".history").tooltip({
	content: function () {
	  var $i = $(this).data("i");
	  var $title = $($(this).prop('title'));
	  var $content = $("#historyCont"+$i).val();
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	}

  });
});	
</script>
</head>
<body  class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
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
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fecha_creacion",cdo.getColValue("fecha_creacion"))%>
<%=fb.hidden("usuario_creacion",cdo.getColValue("usuario_creacion"))%>

<%=fb.hidden("historyCont0","<label class='historyCont' style='font-size:11px'>"+(cdo.getColValue("history")==null?"":cdo.getColValue("history"))+"</label>")%>
<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-1">
    <tr>
        <td>
            <%=fb.button("imprimir","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:imprimirExp()\"")%>
        </td>
    </tr>
</table>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">  
    <tr>
       <td class="controls form-inline" colspan="4">
            Fecha:&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="format" value="dd/mm/yyyy" />
            <jsp:param name="nameOfTBox1" value="fecha" />
            <jsp:param name="readonly" value="<%=viewMode ? "y" : ""%>" />
            <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha",  cDateTime.substring(0, 11) )%>" />
            </jsp:include>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            Hora:&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="hora" />
            <jsp:param name="format" value="hh12:mi:ss am" />
            <jsp:param name="readonly" value="<%=viewMode ? "y" : ""%>" />
            <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora",  cDateTime.substring(11))%>" />
            </jsp:include>
          </td>
    </tr>
    <tr>
        <td colspan="4">
            <b><cellbytelabel id="4">Dolencia Principal [Motivo de Consulta</cellbytelabel>]</b>
            <br><%=fb.textarea("dolencia",cdo.getColValue("DOLENCIA_PRINCIPAL"),true,false,viewMode,78,2,2000,"form-control input-sm","","")%>
        </td>
    </tr>
    <tr>
        <td colspan="4">
            <b><cellbytelabel id="5">Historia de la Enfermedad Actual
                (Inicio, Sintomas, Asistencia Medica y Otros)</cellbytelabel></b><br>
            <%=fb.textarea("observacion",cdo.getColValue("OBSERVACION"),true,false,viewMode,78,2,2000,"form-control input-sm","","")%>
        </td>
    </tr>
    <!--
    <tr class="TextRow01" >
        <td colspan="2">
           <b><cellbytelabel id="6">Motivo de la Hospitalizaci&oacute;n</cellbytelabel></b>
            <br><%//=fb.textarea("motivo",cdo.getColValue("MOTIVO_HOSPITALIZACION"),true,false,viewMode,40,2,2000,"form-control input-sm","","")%>
        </td>
        <td colspan="4">
            <b><label class="RedTextBold">Al&eacute;rgico a</label>&nbsp;&nbsp;</b>
            <span class="history" title="" data-i="0"><span class="Link00 pointer"><%=history%></span></span>
            <br><%//=fb.textarea("alergico",cdo.getColValue("ALERGICO_A"),true,false,viewMode,40,2,2000,"form-control input-sm","","")%>
        </td>
    </tr>
    -->
    </table>
    
    <%if(!fg.equalsIgnoreCase("plan_salida")){%>
    <div class="footerform">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
                <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"")%>
                <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
            </tr>
        </table>   
    </div>
    <%}%>

	<%=fb.formEnd(true)%>
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

	cdo = new CommonDataObject();

	cdo.setTableName("TBL_SAL_PADECIMIENTO_ADMISION");
	cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
	cdo.addColValue("FECHA",request.getParameter("fecha"));
	cdo.addColValue("HORA",request.getParameter("hora"));
	cdo.addColValue("OBSERVACION",request.getParameter("observacion"));
	cdo.addColValue("DOLENCIA_PRINCIPAL",request.getParameter("dolencia"));
	cdo.addColValue("MOTIVO_HOSPITALIZACION",request.getParameter("motivo"));
	//cdo.addColValue("ALERGICO_A",request.getParameter("alergico"));
	cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"));
	cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"));

	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",cDateTime);
					
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
	{
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("SECUENCIA",request.getParameter("noAdmision"));
		cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		cdo.addColValue("FEC_NACIMIENTO",request.getParameter("dob"));
		SQLMgr.insert(cdo);
	}
	else if (modeSec.equalsIgnoreCase("edit"))
	{
						
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);

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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>