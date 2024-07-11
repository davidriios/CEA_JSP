<% // @ page errorPage="../error.jsp"%>
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
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alEval = new ArrayList();
CommonDataObject cdoEval = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();
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
String sexo = request.getParameter("sexo");
String compania = (String) session.getAttribute("_companyId");

if (code == null) code = "0";
if (modeSec == null || modeSec.equals("")) modeSec = "add";
if (mode == null || mode.equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String change = request.getParameter("change");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

sql="select CODIGO, USUARIO_CREACion, to_char(FECHA_CREACion,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIFicacion, to_char(FECHA_MODIFicacion,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF, diag_desc from tbl_sal_eval_obstetrica_parto where pac_id = "+pacId+" and admision = "+noAdmision+" order by CODIGO DESC";

alEval = SQLMgr.getDataList(sql);

CommonDataObject cdo2 = new CommonDataObject();

if(!code.trim().equals("0")){

    sql = "select observacion, diag, diag_desc, presentacion, dilatacion,borramiento, estacion, variedad_posicion, membranas, liquido, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fecha_creac, tiempo_ruptura from tbl_sal_eval_obstetrica_parto where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+code;

    cdo1 = SQLMgr.getData(sql);
    if (cdo1 == null) cdo1 = new CommonDataObject();
}

if (cdo1 == null || code.trim().equals("0")) {
    if (!viewMode) modeSec = "add";
}
%>
<!DOCTYPE html>
<html lang="en">   
<head>
<meta charset="utf-8">
<title>Expediente Cellbyte</title>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){checkViewMode();}
function imprimir(fp){
    var code = '&code=<%=code%>';
    var url = '../expediente3.0/print_eval_gineco_parto.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>';
    if (fp && fp == 'TD') code = '';
    abrir_ventana(url+code);
}
function setEkg(p){
    var code = eval('document.form0.codigo'+p).value;
    window.location = '../expediente3.0/exp_eval_gineco_parto.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&sexo=<%=sexo%>&code='+code;
}
function add(){
    window.location = '../expediente3.0/exp_eval_gineco_parto.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0&sexo=<%=sexo%>';
}

jQuery(function($){
    doAction();
    $("#fecha_creacion").prop("readOnly", true);
    
    $("input:radio[name*='membranas']").click(function(){
        if (this.value == 'R') $("#tiempo_ruptura").prop("readOnly", false);
        else $("#tiempo_ruptura").prop("readOnly", true).val("");
    });
});

function verHistorial() {
   $("#histotial_container").toggle();
}

function addDx(){
    abrir_ventana1('../common/search_diagnostico.jsp?fp=eval_gineco_parto&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
}

function doPrintHistory() {
    var sections = "1,3,2,7,4,16,6,27,77,10,163,14,15";
    //sections = "6";
    abrir_ventana('../expediente3.0/print_unified_exp.jsp?modeSec=<%=modeSec%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&is_tmp=Y&sections='+sections+'&custom_first_title=HISTORIA%20CLÍNICA%20OBSTETRICA');
}
</script>
<style>
.pinkarize{}
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
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("index","")%>

<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
<tr>
<td>
    <%if(!mode.trim().equals("view")){%>
      <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
        <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
      </button>
    <%}%>
    <%if(!code.trim().equals("") && !code.trim().equals("0")){%>
    <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir('')"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
    <%}%>
    <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir('TD')"><i class="fa fa-print fa-printico"></i> <b>Imprimir Todo</b></button>
        
    <%if(alEval.size() > 0){%>
        <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
            <i class="fa fa-eye"></i><b>Historial</b>
        </button>
    <%}%>
    
</td>
</tr>
    <tr><th class="bg-headtabla">LISTADO DE RESULTADOS</th></tr>
</table>

<div class="table-wrapper pinkarize" id="histotial_container" style="display:none">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
    <tr class="bg-headtabla2">
    <th style="vertical-align: middle !important;">C&oacute;digo</th>
    <th style="vertical-align: middle !important;">Fecha</th>
    <th style="vertical-align: middle !important;">Registrado Por</th>
    <th style="vertical-align: middle !important;">Diagn&oacute;stico</th>
    </thead>
<tbody>
<%
for (int p = 1; p<=alEval.size(); p++){
    cdoEval = (CommonDataObject)alEval.get(p-1);
    %>

<tr onclick="javascript:setEkg(<%=p%>)" class="pointer pinkarize">
<td><%=cdoEval.getColValue("CODIGO")%></td>
<td><%=cdoEval.getColValue("FECHA_CREAC")%></td>
<td><%=cdoEval.getColValue("USUARIO_CREACion")%></td>
<td><%=cdoEval.getColValue("diag_desc")%></td>
</tr>
<%=fb.hidden("codigo"+p,cdoEval.getColValue("CODIGO"))%>
<% 
  }
%>

</tbody>
</table>
</div>
</div>
    
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
 <tbody>
     <tr>
        <th class="bg-headtabla" colspan="2">Datos Generales</th>
     </tr>
     
     <tr class="pinkarize">
        <td class="controls form-inline">
            <cellbytelabel><strong>Fecha</strong></cellbytelabel>
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1"/>
                <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                <jsp:param name="nameOfTBox1" value="fecha_creacion" />
                <jsp:param name="valueOfTBox1" value="<%=cdo1.getColValue("fecha_creac", cDateTime)%>"/>
                <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
            </jsp:include>
            
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <b>Presentaci&oacute;n: </b>
            <%=fb.textBox("presentacion",cdo1.getColValue("presentacion"),false,false,viewMode,10,15,"form-control input-sm",null,null)%>
            
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <b>Dilataci&oacute;n: </b>
            <%=fb.textBox("dilatacion",cdo1.getColValue("dilatacion"),false,false,viewMode,10,15,"form-control input-sm",null,null)%>
            
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <b>Borramiento: </b>
            <%=fb.textBox("borramiento",cdo1.getColValue("borramiento"),false,false,viewMode,10,15,"form-control input-sm",null,null)%>
            
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <b>Estaci&oacute;n: </b>
            <%=fb.textBox("estacion",cdo1.getColValue("estacion"),false,false,viewMode,10,15,"form-control input-sm",null,null)%>
            
        </td>        
    </tr>
    
    <tr class="pinkarize">
        <td class="controls form-inline">
            <b>Variedad de Posici&oacute;n: </b>
            <%=fb.textBox("variedad_posicion",cdo1.getColValue("variedad_posicion"),false,false,viewMode,150,100,"form-control input-sm",null,null)%>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </td>
    </tr> 
    
    <tr class="pinkarize">
        <td class="controls form-inline">
            <b>Membranas: </b>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">
            <b>&Iacute;ntegras</b>&nbsp;
            <%=fb.radio("membranas", "I" ,cdo1.getColValue("membranas"," ").trim().equalsIgnoreCase("I"),false,viewMode,null,"",null,"")%>
            </label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">
            <b>Rotas</b>&nbsp;
            <%=fb.radio("membranas", "R" ,cdo1.getColValue("membranas"," ").trim().equalsIgnoreCase("R"),false,viewMode,null,"",null,"")%>
            </label>
            
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <b>Tiempo ruptura: </b>
            <%=fb.textBox("tiempo_ruptura",cdo1.getColValue("tiempo_ruptura"),false,false,true,10,"form-control input-sm",null,null)%>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <b>L&iacute;quido: </b>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">
            <b>Claro</b>&nbsp;
            <%=fb.radio("liquido", "C" ,cdo1.getColValue("liquido"," ").trim().equalsIgnoreCase("liquido"),false,viewMode,null,"",null,"")%>
            </label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">
            <b>Meconial</b>&nbsp;
            <%=fb.radio("liquido", "M" ,cdo1.getColValue("liquido"," ").trim().equalsIgnoreCase("M"),false,viewMode,null,"",null,"")%>
            </label>
        </td>
    </tr>
    
    <!--<tr class="pinkarize">
        <td class="controls form-inline">
            <b>Diagn&oacute;stico:</b>
            <%//=fb.textBox("diag",cdo1.getColValue("diag"),false,false,true,7,"form-control input-sm",null,"")%>
            <%//=fb.textBox("diag_desc",cdo1.getColValue("diag_desc"),false,false,true,120,"form-control input-sm",null,"")%>
            <%//=fb.button("btn_dx","...",true,viewMode,null,null,"onClick=\"javascript:addDx()\"")%>
        </td>
    </tr>-->
    
    <tr>
        <td class="controls form-inline">
            <cellbytelabel><strong>Plan de Manejo</strong></cellbytelabel>
            <%=fb.textarea("observacion",cdo1.getColValue("observacion"),false,false,viewMode,30,2,2000,"form-control input-sm","width:100%","")%>
        </td>
    </tr>

</tbody>
</table>
    
<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td>
                <%=fb.hidden("saveOption", "O")%>        
                <%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>
                <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
            </td>
        </tr>
    </table>
</div> 
    
<%=fb.formEnd(true)%>    
</div>    
</div>
</body>
</html>
<%
}//fin GET
else
{
    String saveOption = request.getParameter("saveOption");
    String baction = request.getParameter("baction");

    cdo = new CommonDataObject();
    cdo.setTableName("tbl_sal_eval_obstetrica_parto");
        
    cdo.addColValue("presentacion",request.getParameter("presentacion"));
    cdo.addColValue("dilatacion",request.getParameter("dilatacion"));
    cdo.addColValue("borramiento",request.getParameter("borramiento"));
    cdo.addColValue("estacion",request.getParameter("estacion"));
    cdo.addColValue("variedad_posicion",request.getParameter("variedad_posicion"));
    cdo.addColValue("membranas",request.getParameter("membranas"));
    cdo.addColValue("liquido",request.getParameter("liquido"));
    cdo.addColValue("diag_desc",request.getParameter("diag_desc"));
    cdo.addColValue("diag",request.getParameter("diag"));
    cdo.addColValue("observacion",request.getParameter("observacion"));
    cdo.addColValue("tiempo_ruptura",request.getParameter("tiempo_ruptura"));
                    
    if(modeSec.equalsIgnoreCase("add")){
      cdo.addColValue("USUARIO_CREACion",(String) session.getAttribute("_userName"));
      cdo.addColValue("USUARIO_MODIFicacion",(String) session.getAttribute("_userName"));
      cdo.addColValue("FECHA_CREACion",request.getParameter("fecha_creacion"));
      cdo.addColValue("FECHA_MODIFicacion",cDateTime);
      cdo.addColValue("pac_id", pacId);
      cdo.addColValue("admision", noAdmision);
      
      cdo.setAutoIncWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
      cdo.setAutoIncCol("codigo");
      cdo.addPkColValue("codigo","");
        
      SQLMgr.insert(cdo);
      code = SQLMgr.getPkColValue("codigo");
    }else{
        cdo.addColValue("USUARIO_MODIFicacion",(String) session.getAttribute("_userName"));
        cdo.addColValue("FECHA_modificacion",cDateTime);
        
        cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and codigo = "+code);
        SQLMgr.update(cdo);
    }
    
    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    ConMgr.clearAppCtx(null);
					
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&desc=<%=desc%>&sexo=<%=sexo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>