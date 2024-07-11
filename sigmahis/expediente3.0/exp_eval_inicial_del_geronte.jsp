<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="iHashEval" scope="session" class="java.util.Hashtable" />
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

boolean viewMode = false;
String sql ="";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String fecha_eval = request.getParameter("fecha_eval");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String filter = "",appendFilter ="", op ="";
String key = "";

if (request.getMethod().equalsIgnoreCase("GET")){
    if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
    iHashEval.clear();
    sql="select to_char(fecha,'dd/mm/yyyy') as fecha, to_char(fecha_creacion,'hh12:mi:ss am') as hora, usuario_creacion, observacion from tbl_sal_eval_gerontes where pac_id="+pacId+" and secuencia="+noAdmision+" order by to_date(fecha,'dd/mm/yyyy') desc";
    al2 = SQLMgr.getDataList(sql); 
			
    for (int i=1; i<=al2.size(); i++){
        cdo = (CommonDataObject) al2.get(i-1);
        cdo.setKey(i-1);
        
        if(cdo.getColValue("fecha").equals(cDateTime.substring(0,10))){
            cdo.addColValue("OBSERVACION","Evaluacion actual ");
            op = "0";
        } else{
           cdo.addColValue("OBSERVACION","Evaluacion "+ (1+al2.size() - i));
           appendFilter = "1";
        }
        try{
            iHashEval.put(cdo.getKey(), cdo);
        }
        catch(Exception e){
           System.err.println(e.getMessage());
        }
    }

    if(al2.size() == 0){
        if (!viewMode) modeSec = "add";
        cdo = new CommonDataObject();
        cdo.addColValue("FECHA",cDateTime.substring(0,10));
        cdo.addColValue("OBSERVACION","Evaluacion Actual");
        cdo.setKey(iHashEval.size() +1);

        try{
            iHashEval.put(cdo.getKey(), cdo);
        }
        catch(Exception e){
            System.err.println(e.getMessage());
        }
    }


    if(fecha_eval != null){ 
        filter = fecha_eval;
        if(fecha_eval.trim().equals(cDateTime.substring(0,10))){modeSec="edit";if(!viewMode)viewMode= false;}
    }else {
        filter = cDateTime.substring(0,10);
        fecha_eval = cDateTime.substring(0,10);
    }

    sql="select to_char(fecha,'dd/mm/yyyy') as fecha, observacion, usuario_creacion as usuarioCreacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, usuario_modificacion as usuarioModificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fechaModificacion from tbl_sal_eval_gerontes where pac_id="+pacId+" and secuencia="+noAdmision+" and to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy')= to_date('"+filter+"','dd/mm/yyyy')";
    cdo = SQLMgr.getData(sql);
    
    if(cdo == null){
        cdo = new CommonDataObject();
        cdo.addColValue("fecha", cDateTime.substring(0,10));
        cdo.addColValue("usuarioCreacion", UserDet.getUserName());
        cdo.addColValue("fechaCreacion", cDateTime);
        cdo.addColValue("usuarioModificacion", UserDet.getUserName());
        cdo.addColValue("fechaModificacion", cDateTime);
        if (!viewMode) modeSec = "add";
    }
    else if (!viewMode) modeSec = "edit";

    if(fecha_eval != null) filter = fecha_eval;
    else {
        filter = cDateTime.substring(0,10);
        fecha_eval = cDateTime.substring(0,10);
    }
	
    sql = "select a.codigo as codigo, a.descripcion as descripcion, b.observacion as observacion , b.seleccionar, to_char(b.fecha_up,'dd/mm/yyyy') as fechaUp, b.cod_eval as codEval, decode(b.cod_eval,null,'I','U') action from tbl_sal_eval_geronte a, tbl_sal_eval_gerontes_det b where a.codigo=b.cod_eval(+) and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+" and to_date(to_char(fecha_up(+),'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+filter+"','dd/mm/yyyy') ORDER BY a.codigo";
	al = SQLMgr.getDataList(sql);
    
	if (al.size() == 0)
		if (!viewMode) modeSec = "add";
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
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
document.title = 'Evaluacion de Ulceras por Presión - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
var noNewHeight = true;
function doAction(){checkViewMode();}
function setEvaluacion(k){var fecha_e = eval('document.form0.fecha_evaluacion'+k).value ;window.location= '../expediente3.0/exp_eval_inicial_del_geronte.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval='+fecha_e+'&desc=<%=desc%>';}
function isChecked(k){
    eval('document.form0.observacion2'+k).disabled = !eval('document.form0.aplicar'+k).checked;
    if ( !eval('document.form0.aplicar'+k).checked ){
      eval('document.form0.observacion2'+k).disabled = true;
      eval('document.form0.observacion2'+k).value = '';
    }
}
function printDatos(){var fecha = document.form0.fecha.value;abrir_ventana1('../expediente3.0/print_eval_inicial_del_geronte.jsp?pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&fecha_eval='+fecha);}
function printDatosTodos(){abrir_ventana1('../expediente3.0/print_eval_inicial_del_geronte.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
function add(){window.location = "../expediente3.0/exp_eval_inicial_del_geronte.jsp?desc=<%=desc%>&pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&modeSec=add&mode=<%=mode%>&fecha_eval=<%=fecha_eval%>";}

function getTotal() {
  var tot = 0;
  for (var i = 0; i<<%=al.size()%>; i++) {
    var val = $("input[name='aplicar"+i+"'][value='S']:checked").length || 0;
    tot += parseInt(val,10);
  }
  if (tot >= 1) {
    parent.CBMSG.alert("Comunicarse con el médico!");
  }
  $("#total").val(tot); 
}

$(function(){
  $(".__aplicar").click(function() {
    var $self = $(this);
    var i = $self.data('index');
    $("#observacion2"+i).prop("readOnly", false);
    getTotal();
  });
  getTotal()
});

function verHistorial() {
  $("#hist_container").toggle();
}
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("usuarioCreacion",cdo.getColValue("usuarioCreacion"))%>
<%=fb.hidden("fechaCreacion",cdo.getColValue("fechaCreacion"))%>
<%=fb.hidden("usuarioModificacion",cdo.getColValue("usuarioModificacion"))%>
<%=fb.hidden("fechaModificacion",cdo.getColValue("fechaModificacion"))%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fecha_eval",fecha_eval)%>
<%=fb.hidden("total","")%>
<div class="headerform">

<table class="table table-small-font table-bordered table-striped table-custom-2">
    <tr class="text-right">
        <td>
        <% if (!mode.trim().equals("view")){ %>
        <button onclick="add()" type="button" class="btn btn-inverse btn-sm">
            <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
        </button>
        <%}%>
        
        <button onclick="printDatos()" type="button" class="btn btn-inverse btn-sm"><i class="material-icons fa-printico">print</i> <b>Imprimir</b></button>
        
        <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
        <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
      </button>
        
    </tr>
</table>

<div class="table-wrapper" id="hist_container" style="display:none">
<table cellspacing="0" class="table table-small-font table-bordered table-striped" style="margin-bottom:0px !important;">
<thead>
    <tr class="bg-headtabla2" >
        <th style="vertical-align: middle !important;">Fecha</th>
        <th style="vertical-align: middle !important;">Hora</th>
        <th style="vertical-align: middle !important;"><cellbytelabel>Usuario</cellbytelabel></th>
   </tr>
</thead>

<%

al2 = CmnMgr.reverseRecords(iHashEval);
for (int i=1; i<=iHashEval.size(); i++){
	key = al2.get(i-1).toString();
	cdo = (CommonDataObject) iHashEval.get(key);%>
    <%=fb.hidden("fecha_evaluacion"+i,cdo.getColValue("fecha"))%>
    <%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
    <tr style="cursor:pointer " onClick="javascript:setEvaluacion(<%=i%>)" >
        <td><%=cdo.getColValue("fecha")%></td>
        <td><%=cdo.getColValue("hora")%></td>
        <td><%=cdo.getColValue("usuario_creacion")%></td>
    </tr>
<%}%>
</tbody>
</table>
</div>
</div>

<table cellspacing="0" class="table table-bordered table-striped">
<tr>
    <td class="controls form-inline">
        <cellbytelabel id="1">Fecha</cellbytelabel>
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="fecha" />
            <jsp:param name="valueOfTBox1" value="<%=fecha_eval%>" />
            <jsp:param name="readonly" value="<%=(viewMode?"y":"n")%>" />
        </jsp:include>
    </td>
    <td><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,viewMode,18,0,2000,"form-control input-sm","width:100%",null)%></td>
</tr>
</table>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
    <tr>
        <th width="48%"><cellbytelabel>Caracter&iacute;sticas</cellbytelabel></th>
        <th width="4%">S&iacute;</th>
        <th width="4%">No</th>
        <th width="44%"><cellbytelabel>Observaci&oacute;n</cellbytelabel></th>
    </tr>
<%for (int i=1; i<=al.size(); i++){
	cdo = (CommonDataObject) al.get(i-1);
%>

<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("fechaUp"+i,cdo.getColValue("fechaUp"))%>
<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
<%=fb.hidden("seleccionado"+i,cdo.getColValue("seleccionar"))%>

<tr>
    <td><%=cdo.getColValue("descripcion")%></td>
    <td align="center">
        <%=fb.radio("aplicar"+i,"S",(cdo.getColValue("seleccionar").equalsIgnoreCase("S")),viewMode,false,"form-control input-sm __aplicar",null,null,null," data-index="+i)%>
    </td>
    <td align="center">
        <%=fb.radio("aplicar"+i,"N",(cdo.getColValue("seleccionar").equalsIgnoreCase("N")),viewMode,false,"form-control input-sm __aplicar",null,null,null," data-index="+i)%>
    </td>

    <td><%=fb.textarea("observacion2"+i,cdo.getColValue("observacion"),false,false,viewMode||cdo.getColValue("observacion"," ").trim().equals(""),50,1,2000,"form-control input-sm","width:100%",null)%></td>
</tr>
<%}%>
</table>

<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
    <tr>
    <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
        
    <%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>

    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
    </tr>
    </table> 
</div>
<%=fb.formEnd(true)%>
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
	int size= 0;

	fecha_eval = request.getParameter("fecha");
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));

	al.clear();
    
	cdo = new CommonDataObject();
    cdo.setTableName("tbl_sal_eval_gerontes");
    cdo.addColValue("secuencia", request.getParameter("noAdmision"));
    cdo.addColValue("fecha", request.getParameter("fecha"));
    cdo.addColValue("observacion", request.getParameter("observacion"));
    cdo.addColValue("pac_id", request.getParameter("pacId"));
    
    if (modeSec.equalsIgnoreCase("add")) {
        cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
        cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
        cdo.addColValue("fecha_creacion", cDateTime);
        cdo.addColValue("fecha_modificacion", cDateTime);
        cdo.setAction("I");
    }else  {
        cdo.addColValue("fecha_modificacion", cDateTime);
        cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
        cdo.setAction("U");
        cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and secuencia = "+request.getParameter("noAdmision")+" and fecha = to_date('"+request.getParameter("fecha")+"', 'dd/mm/yyyy')");
    }
    
    int selected = 0;
    for (int i=1; i<=size; i++){
		CommonDataObject cdo2 = new CommonDataObject();

        if (request.getParameter("aplicar"+i)!= null){
            cdo2.setTableName("tbl_sal_eval_gerontes_det");
            
            if (request.getParameter("action"+i) != null && request.getParameter("action"+i).equalsIgnoreCase("U")) {
        
                cdo2.setWhereClause("pac_id = "+request.getParameter("pacId")+" and secuencia = "+request.getParameter("noAdmision")+" and fecha_up = to_date('"+request.getParameter("fecha")+"', 'dd/mm/yyyy') and cod_eval = "+request.getParameter("codigo"+i));
                cdo2.setAction("U");
            
            } else {
               cdo2.setAction("I");
            }
            
            cdo2.addColValue("secuencia", request.getParameter("noAdmision"));
            cdo2.addColValue("pac_id", request.getParameter("pacId"));
            cdo2.addColValue("fecha_up", request.getParameter("fecha"));
            cdo2.addColValue("cod_eval", request.getParameter("codigo"+i));
            cdo2.addColValue("seleccionar", request.getParameter("aplicar"+i));
            cdo2.addColValue("observacion", request.getParameter("observacion2"+i));
            
            al.add(cdo2);
        }
    }
    
    if (al.size() == 0) {
        CommonDataObject cdo2 = new CommonDataObject();
        cdo2.setTableName("tbl_sal_eval_gerontes_det");
        cdo2.setWhereClause("pac_id = "+pacId+" and secuencia = "+noAdmision);
        cdo2.setAction("I");
        al.add(cdo2);
    }
    
    if (baction.equalsIgnoreCase("Guardar")){
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        if (modeSec.equalsIgnoreCase("add")){
           SQLMgr.save(cdo, al, true,true, true, true);
        }
        else if (modeSec.equalsIgnoreCase("edit"))
        {
           SQLMgr.save(cdo, al, true,true, true, true); 
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
<%
	}
	else
	{
%>
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval=<%=fecha_eval%>&desc=<%=desc%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fecha_eval=<%=fecha_eval%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
