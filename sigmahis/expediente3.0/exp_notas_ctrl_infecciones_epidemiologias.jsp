<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");

if (code == null) code = "0";
if (modeSec == null || modeSec.equals("")) modeSec = "add";
if (mode == null || mode.equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (fg == null) fg = "S";

String change = request.getParameter("change");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null) desc = "";

sql="select codigo, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi am') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy hh12:mi am') fecha_modificacion, usuario_creacion, usuario_modificacion from tbl_sal_nota_ctrl_infecciones where pac_id = "+pacId+" and admision = "+noAdmision+" order by codigo desc";

alEval = SQLMgr.getDataList(sql);

CommonDataObject cdo2 = new CommonDataObject();

if(!code.trim().equals("0")){

    sql = "select to_char(fecha_inicio, 'dd/mm/yyyy hh12:mi:ss am') fecha_inicio, to_char(fecha_retiro, 'dd/mm/yyyy hh12:mi:ss am') fecha_retiro, tipo_aislamiento, diagnosticos, app_cirugias, cultivos_fuente, antibioticos, motivos_aislamiento, observaciones from tbl_sal_nota_ctrl_infecciones where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo="+code;

    cdo1 = SQLMgr.getData(sql);
}

if (cdo1 == null || code.trim().equals("0"))
{
    if (!viewMode) modeSec = "add";
    cdo1 = new CommonDataObject();
    cdo1.addColValue("fecha_inicio",cDateTime);
    
    Properties prop = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision);
    
    Hashtable iAislamientos = new Hashtable();
    iAislamientos.put("0", "Orientación al paciente y familiar");
    iAislamientos.put("1", "Paciente con Aislamiento de Contacto");
    iAislamientos.put("2", "Coordinación con la enfermera de nosocomial");
    iAislamientos.put("3", "Paciente Con Aislamiento de Gotas");
    iAislamientos.put("4", "Colocación del equipo de protección");
    iAislamientos.put("5", "Paciente con Aislamiento Respiratorio (Gotitas)");
    iAislamientos.put("6", "Otros");
    
    if (prop == null) prop = new Properties();
    
    String tipoAislamientos = "";
    
    for (int a = 0; a < 8; a++) {
        if (prop.getProperty("aislamiento_det"+a) != null && !"".equals(prop.getProperty("aislamiento_det"+a)) ) tipoAislamientos += ( iAislamientos.get(prop.getProperty("aislamiento_det"+a)) + ", ");
    }
    
    if (prop.getProperty("observacion27") != null && !"".equals(prop.getProperty("observacion27"))) tipoAislamientos = tipoAislamientos+", "+prop.getProperty("observacion27");
    
    cdo1.addColValue("tipo_aislamiento", tipoAislamientos);
    cdo1.addColValue("diagnosticos", prop.getProperty("desc_diag"));    
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
    var url = '../expediente3.0/print_notas_ctrl_infecciones_epidemiologias.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&fg=<%=fg%>';
    if (fp && fp == 'TD') code = '';
    abrir_ventana(url+code);
}
function setEkg(p){
    var code = eval('document.form0.codigo'+p).value;
    window.location = '../expediente3.0/exp_notas_ctrl_infecciones_epidemiologias.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&fg=<%=fg%>&noAdmision=<%=noAdmision%>&code='+code;
}
function add(){
    window.location = '../expediente3.0/exp_notas_ctrl_infecciones_epidemiologias.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&fg=<%=fg%>&noAdmision=<%=noAdmision%>&code=0';
}

$(function(){
    doAction();
});
</script>
<%if(fg.equalsIgnoreCase("S")){%>
<style>
.pinkarize{background-color:pink !important;}
</style>
<%}%>
</head>
<!--termina el head-->  

<!--comienza el cuerpo del sitio-->  
<body class="body-forminside">

    <!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->    
<!--INICIO de una fila de elementos-->    
<div class="row">
<!--INICIO de una fila de elementos-->

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
<%=fb.hidden("index","")%>
<%=fb.hidden("fg", fg)%>

<div class="headerform2">
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
</td>
</tr>
    <tr><th class="bg-headtabla">LISTADO DE NOTAS</th></tr>
</table>
<!--fin tabla de boton imprimir-->
<div class="table-wrapper">
<table cellspacing="0" class="table table-small-font table-bordered table-striped table-hover">
<thead>
    <tr class="bg-headtabla2">
    <th style="vertical-align: middle !important;">C&oacute;digo</th>
    <th style="vertical-align: middle !important;">Fecha creaci&oacute;n</th>
    <th style="vertical-align: middle !important;">Registrado Por</th>
    <th style="vertical-align: middle !important;">Fecha modificaci&oacute;n</th>
    <th style="vertical-align: middle !important;">Modificador por</th>
    </thead>
<tbody>
<%
for (int p = 1; p<=alEval.size(); p++){
    cdoEval = (CommonDataObject)alEval.get(p-1);
    %>

<tr onclick="javascript:setEkg(<%=p%>)" class="pointer">
<td><%=cdoEval.getColValue("CODIGO")%></td>
<td><%=cdoEval.getColValue("fecha_creacion")%></td>
<td><%=cdoEval.getColValue("usuario_creacion")%></td>
<td><%=cdoEval.getColValue("fecha_modificacion")%></td>
<td><%=cdoEval.getColValue("usuario_modificacion")%></td>
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
     <tr class="bg-headtabla">
        <td>Tipo de aislamiento</td>
        <td>Fecha de inicio</td>
        <td>F.Retiro/Alta</td>
        <td>Diagn&oacute;sticos</td>
        <td>APP/Cirugías</td>
        <td>Cultivos/Fuente</td>
        <td>Antibióticos administrados</td>
        <td>Motivo de aislamiento</td>
        <td>Notas/ Observaciones</td>
     </tr>
     
     <tr>
        <td class="controls form-inline">
            <%=fb.textarea("tipo_aislamiento",cdo1.getColValue("tipo_aislamiento"),true,false,viewMode,30,0,0,"form-control input-sm","width:100%","")%>
        </td>
        <td class="controls form-inline">
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1"/>
                <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                <jsp:param name="nameOfTBox1" value="fecha_inicio" />
                <jsp:param name="valueOfTBox1" value="<%=cdo1.getColValue("fecha_inicio")!=null?cdo1.getColValue("fecha_inicio"):""%>" />
                <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
            </jsp:include>
        </td>
        <td class="controls form-inline">
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1"/>
                <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                <jsp:param name="nameOfTBox1" value="fecha_retiro" />
                <jsp:param name="valueOfTBox1" value="<%=cdo1.getColValue("fecha_retiro")!=null?cdo1.getColValue("fecha_retiro"):""%>" />
                <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
            </jsp:include>
        </td>
        <td class="controls form-inline">
            <%=fb.textarea("diagnosticos",cdo1.getColValue("diagnosticos"),true,false,viewMode,30,0,0,"form-control input-sm","width:100%","")%>
        </td>
        <td class="controls form-inline">
            <%=fb.textarea("app_cirugias",cdo1.getColValue("app_cirugias"),true,false,viewMode,30,0,0,"form-control input-sm","width:100%","")%>
        </td>
        <td class="controls form-inline">
            <%=fb.textarea("cultivos_fuente",cdo1.getColValue("cultivos_fuente"),true,false,viewMode,30,0,0,"form-control input-sm","width:100%","")%>
        </td>
        <td class="controls form-inline">
            <%=fb.textarea("antibioticos",cdo1.getColValue("antibioticos"),true,false,viewMode,30,0,0,"form-control input-sm","width:100%","")%>
        </td>
        <td class="controls form-inline">
            <%=fb.textarea("motivos_aislamiento",cdo1.getColValue("motivos_aislamiento"),true,false,viewMode,30,0,0,"form-control input-sm","width:100%","")%>
        </td>
        <td class="controls form-inline">
            <%=fb.textarea("observaciones",cdo1.getColValue("observaciones"),true,false,viewMode,30,0,0,"form-control input-sm","width:100%","")%>
        </td>
    </tr>

</tbody>
</table>
    

<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
    <td>
        <%=fb.hidden("saveOption", "O")%>
        <%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>
        <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
    </tr>
    </table> </div> 

    
<%=fb.formEnd(true)%>    
</div>
    
<!-- FIN contenido del sitio aqui-->
</div>
<!-- FIN contenido del sitio aqui-->

    
<!-- FIN Cuerpo del sitio -->    
</body>
<!-- FIN Cuerpo del sitio -->


</html>
<%
}//fin GET
//------------------------------- -----------------------------------
else
{
    String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");

    cdo = new CommonDataObject();
    cdo.setTableName("tbl_sal_nota_ctrl_infecciones");
    
    cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
    
    cdo.addColValue("fecha_inicio",request.getParameter("fecha_inicio"));
    cdo.addColValue("fecha_retiro",request.getParameter("fecha_retiro"));
    cdo.addColValue("tipo_aislamiento",request.getParameter("tipo_aislamiento"));
    cdo.addColValue("diagnosticos",request.getParameter("diagnosticos"));
    cdo.addColValue("app_cirugias",request.getParameter("app_cirugias"));
    cdo.addColValue("cultivos_fuente",request.getParameter("cultivos_fuente"));
    cdo.addColValue("antibioticos",request.getParameter("antibioticos"));
    cdo.addColValue("motivos_aislamiento",request.getParameter("motivos_aislamiento"));
    cdo.addColValue("observaciones",request.getParameter("observaciones"));
                   
    if(modeSec.equalsIgnoreCase("add")){
      cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
      cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
      cdo.addColValue("fecha_creacion",cDateTime);
      cdo.addColValue("fecha_modificacion",cDateTime);
      cdo.addColValue("pac_id",pacId);
      cdo.addColValue("admision",noAdmision);
      
      cdo.setAutoIncWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
      cdo.setAutoIncCol("codigo");
      cdo.addPkColValue("codigo","");
        
      SQLMgr.insert(cdo);
      code = SQLMgr.getPkColValue("CODIGO");
    }else{
        cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
        cdo.addColValue("fecha_modificacion",cDateTime);
        
        cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and codigo = "+code);
        SQLMgr.update(cdo);
    }

    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    // ConMgr.setAppCtx(ConMgr.AUDIT_NOTES, "fg="+);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&desc=<%=desc%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>