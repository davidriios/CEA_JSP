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
String key = "";
int progresoLineNo = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
boolean cancellable = true;

if (fg == null) fg = "";
if (code == null) code = "0";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (request.getMethod().equalsIgnoreCase("GET"))
{
    if (!code.trim().equals("") && !code.trim().equals("0")) {
       cdo = SQLMgr.getData("select to_char(fecha, 'dd/mm/yyyy') fecha, to_char(fecha, 'hh12:mi am') hora, comentario, estado, necesita_resp, respuesta from TBL_SAL_comentarios where pac_id = "+pacId+" and admision = "+noAdmision+" and comentario_id = "+code);
    } else {
        cdo = new CommonDataObject();
        cdo.addColValue("comentario_id", code);
        cdo.addColValue("fecha",cDateTime.substring(0,10));
        cdo.addColValue("hora",cDateTime.substring(11));
    }
    
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
var noNewHeight = true;
function doAction(){$("#loadingmsg").remove()}
$(function(){
 // reloading alerts
  if (typeof parent.reloadAlerts === 'function') parent.reloadAlerts();
  else if (typeof parent.parent.reloadAlerts === 'function') parent.parent.reloadAlerts();
});

$(function() {
    $("#reply").click(function(e){
      __submitForm($("#form0").get(0), 'Responder');
    });
    
    $("#create").click(function(e){
      __submitForm($("#form0").get(0), 'Guardar');
    }); 
});

</script>
<style>
.greenirize{/*background-color:#bcf5a9 !important;*/}

.user_name{
    font-size:14px;
    font-weight: bold;
}
.answer-list .media{
    border-bottom: 1px dotted #ccc;
}
</style>
</head>
<body class="body-form" onLoad="javascript:doAction()" style="padding-top:0">
<div class="row">
<div class="table-responsive">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("detSize",""+al.size())%>
<%=fb.hidden("progresoLineNo",""+progresoLineNo)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("estado",estadoExp)%>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
    <thead>
    <tr class="bg-headtabla" align="center">
        <th width="20%"><cellbytelabel id="3">Fecha</cellbytelabel></th>
        <th width="20%"><cellbytelabel id="4">Hora</cellbytelabel></th>
        <th width="60%"><cellbytelabel id="5">M&eacute;dico</cellbytelabel></th>
    </tr>
    </thead>

    <tbody>
        <tr class="greenirize">
            <td class="controls form-inline">
                Fecha
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="fecha" />
                <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
                <jsp:param name="readonly" value="<%=(viewMode || !code.trim().equals("0"))?"y":"n"%>"/>
                </jsp:include>
            </td>
            <td class="controls form-inline">
            Hora
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="hora" />
                <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora")%>" />
                <jsp:param name="readonly" value="<%=(viewMode || !code.trim().equals("0"))?"y":"n"%>"/>
                <jsp:param name="format" value="hh12:mi am" />
                </jsp:include>
            </td>
            <td class="controls form-inline">
            
              <label>
              <input type="checkbox" name="necesita_resp" id="necesita_resp"<%=cdo.getColValue("necesita_resp", " ").equalsIgnoreCase("S")?" checked":""%>
              <%=(viewMode || !code.trim().equals("0"))?" disabled":""%>
              >
              Necesita respuesta
              </label>
            
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <%if(cdo.getColValue("estado"," ").equalsIgnoreCase("I")){%>
                <b><span class="label label-danger">INV&Aacute;LIDO</span></b>
              <%} else {%>
                <b><span class="label label-success">V&Aacute;LIDO</span></b>
              <%}%> 
            </td>
        </tr>
        
        <%if (code.trim().equals("") || code.trim().equals("0")) {%>
        <tr class="greenirize">
          <td colspan="3">
            <cellbytelabel id="6">Comentario</cellbytelabel>
            <%=fb.textarea("comentario",cdo.getColValue("comentario"),true,false,viewMode,80,6,2000,"form-control input-sm","width:100%","")%>
          </td>
        </tr>
        <%}%>
		
        <%if (!code.trim().equals("") && !code.trim().equals("0")) {%>
          <tr>
              <td colspan="3"><%=cdo.getColValue("comentario")%></td>
          </tr>
          
          <tr class="greenirize">
            <td colspan="3">
              <cellbytelabel id="6">Respuesta</cellbytelabel>
              <%=fb.textarea("respuesta",cdo.getColValue("respuesta"),true,false,cdo.getColValue("necesita_resp", " ").equalsIgnoreCase("S") && !estadoExp.equalsIgnoreCase("F") ? false : true, 80, 4, 2000,"form-control input-sm","width:100%","")%>
            </td>
          </tr>
        <%}%>
<%
fb.appendJsValidation("if(error>0)doAction();");
%>
</tbody>
</table>

<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td>
                <%=fb.hidden("saveOption", "O")%>
                <%if (!code.trim().equals("") && !code.trim().equals("0")) {%>
                    <button type="button" class="btn btn-inverse btn-sm" id="reply" <%=viewMode?" disabled":""%>>
                        <i class="fa fa-reply"></i> <b>Responder</b>
                    </button>
                <%} else {%>
                  <button type="button" class="btn btn-inverse btn-sm" id="create" <%=viewMode?" disabled":""%>>
                      <i class="fa fa-save"></i> <b>Guardar</b>
                  </button>
                <%}%>
             </td>
        </tr>
    </table>   
</div>

<%=fb.formEnd(true)%>
</div>
</div>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	
	if (baction.equalsIgnoreCase("Responder")){
      cdo = new CommonDataObject();
      cdo.setTableName("TBL_SAL_COMENTARIO_REP");
      
      cdo.addColValue("codigo",  "(select  nvl(max(codigo),0)+1 next_id from TBL_SAL_COMENTARIO_REP)");
      
      cdo.addColValue("comentario_id", code);
      cdo.addColValue("respuesta",request.getParameter("respuesta"));
      cdo.addColValue("fecha_creacion", "sysdate");
      cdo.addColValue("usuario_creacion", (String)session.getAttribute("_userName"));

      ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
      SQLMgr.insert(cdo);
      ConMgr.clearAppCtx(null);
      
  } else if (baction.equalsIgnoreCase("Cerrar_Respuesta")){
      Gson gson = new Gson();
      JsonObject json = new JsonObject();
      cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
      
      cdo = new CommonDataObject();
      cdo.setTableName("TBL_SAL_comentarios");
      
      cdo.addColValue("usuario_modificacion", (String)session.getAttribute("_userName"));
      cdo.addColValue("fecha_modificacion", "sysdate");
      cdo.addColValue("no_mas_resp","Y");
      cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and comentario_id = "+request.getParameter("comentario_id"));
      
      SQLMgr.update(cdo);
      
      response.setContentType("application/json");
      json.addProperty("date", System.currentTimeMillis());
      
      if (SQLMgr.getErrCode().equals("1")) {
          json.addProperty("error", false);
      } else {
        response.setStatus(500);
        json.addProperty("error", true);
        json.addProperty("msg", SQLMgr.getErrMsg());
      }

      out.print(gson.toJson(json));
      return;
      
  } else if (baction.equalsIgnoreCase("Invalidar")){
      Gson gson = new Gson();
      JsonObject json = new JsonObject();
      cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
      
      cdo = new CommonDataObject();
      cdo.setTableName("TBL_SAL_comentarios");
      
      cdo.addColValue("usuario_modificacion", (String)session.getAttribute("_userName"));
      cdo.addColValue("fecha_modificacion", "sysdate");
      cdo.addColValue("estado","I");
      cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and comentario_id = "+request.getParameter("comentario_id"));
      
      SQLMgr.update(cdo);
      
      response.setContentType("application/json");
      json.addProperty("date", System.currentTimeMillis());
      
      if (SQLMgr.getErrCode().equals("1")) {
          json.addProperty("error", false);
      } else {
        response.setStatus(500);
        json.addProperty("error", true);
        json.addProperty("msg", SQLMgr.getErrMsg());
      }

      out.print(gson.toJson(json));
      return;
      
  } else if (baction.equalsIgnoreCase("Guardar")){
    
    CommonDataObject cdoH = new CommonDataObject();
    cdoH.setTableName("TBL_SAL_comentarios");
    
    cdoH.addColValue("pac_id", request.getParameter("pacId"));
    cdoH.addColValue("admision", request.getParameter("noAdmision"));
    cdoH.addColValue("fecha",request.getParameter("fecha")+" "+request.getParameter("hora"));
    cdoH.addColValue("comentario",request.getParameter("comentario"));
    if (request.getParameter("necesita_resp") != null) {
      cdoH.addColValue("necesita_resp", "S");
    } else {
      cdoH.addColValue("necesita_resp", "N");  
    }
    cdoH.addColValue("comentario",request.getParameter("comentario"));
    
    if (modeSec.equalsIgnoreCase("add")) {
      cdo = SQLMgr.getData("select  nvl(max(comentario_id),0)+1 next_id from TBL_SAL_comentarios");
      code = cdo.getColValue("next_id","0");
      
      cdoH.addColValue("comentario_id", code);
      cdoH.addColValue("usuario_creacion", (String)session.getAttribute("_userName"));
      cdoH.addColValue("fecha_creacion", "sysdate");
    } 

    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
      if (baction.equalsIgnoreCase("Guardar") || baction.equalsIgnoreCase("Invalidar")){
            if (modeSec.equalsIgnoreCase("add"))  {
               SQLMgr.insert(cdoH);
            }
            else SQLMgr.update(cdoH);
      }
      
    ConMgr.clearAppCtx(null);
}
%>
<html>
<head>
<script>
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
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){
    var $iframe = parent.document.querySelector("#a_tabbar").querySelector("iframe[src*='expediente3.0/comentarios.jsp']")
    $iframe.src = $iframe.src
    parent.hidePopWin()
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>