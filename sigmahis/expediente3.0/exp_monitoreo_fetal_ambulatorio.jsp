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

ArrayList al = new ArrayList();
ArrayList alMoni = new ArrayList();
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
sql="select codigo, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, usuario_creacion from tbl_sal_monitoreo_fetal where pac_id = "+pacId+" and admision = "+noAdmision+" order by codigo desc";

alMoni = SQLMgr.getDataList(sql);

CommonDataObject cdo2 = new CommonDataObject();

if(!code.trim().equals("0")){

    sql = "select a.codigo, to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.semana_gestacion, a.medico_obstetra, m.primer_nombre||' '||primer_apellido medico_obstetra_nombre, a.p_a, a.fc_fb, a.observacion from tbl_sal_monitoreo_fetal a, tbl_adm_medico m where pac_id = "+pacId+" and admision = "+noAdmision+" and a.medico_obstetra = m.codigo(+) and a.codigo = "+code;

    cdo1 = SQLMgr.getData(sql);
    
    if (cdo1 == null) cdo1 = new CommonDataObject();
}

if (cdo1 == null || code.trim().equals("0"))
{
    if (!viewMode) modeSec = "add";    
}
 al = SQLMgr.getDataList("select a.codigo, a.descripcion, d.valor, d.observacion, decode(d.cod_monitoreo, null, 'I', 'U') action from tbl_sal_monitoreo_params a, tbl_sal_monitoreo_fetal_det d where a.estado = 'A' and a.codigo = d.cod_param(+) and d.pac_id(+) = "+pacId+" and d.admision(+) = "+noAdmision+" and d.cod_monitoreo(+) = "+code+" order by a.orden");
%>
<!--Bienvenido a CELLBYTE Expediente Electronico V3.0 Build 1.4 BETA-->
<!--Bootstrap 3, JQuery UI Based, HTML5 y {LESS}-->
<!--Para mas Informacion leer (info_v3.txt)-->
<!--Done by. eduardo.b@issi-panama.com-->
<!DOCTYPE html>
<html lang="en">   
<!--comienza el head-->    
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
    var url = '../expediente3.0/print_monitoreo_fetal_ambulatorio.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>';
    if (fp && fp == 'TD') code = '';
    abrir_ventana(url+code);
}
function setCurrent(code){
    window.location = '../expediente3.0/exp_monitoreo_fetal_ambulatorio.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code='+code;
}
function add(){window.location = '../expediente3.0/exp_monitoreo_fetal_ambulatorio.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0';}
$(function(){
doAction();
})

function verHistorial() {$("#hist_container").toggle();}

function medicoList(){
	abrir_ventana1('../common/search_medico.jsp?fp=monitoreo_fetal&especialidad=OBG');
}

function canSubmit() {
    var proceed = true;
    if (!$("#fecha_hora").val()) {
        proceed = false;
        parent.CBMSG.error("El campo fecha es obligatorio!");
        return false;
    } else if ($("#semana_gestacion").val() && !isInteger($("#semana_gestacion").val())) {
        proceed = false;
        parent.CBMSG.error("La semana de gestación debe ser numérico!");
        return false;
    }
    return proceed;
}
</script>
<style>
</style>
</head>
<!--termina el head-->  

<!--comienza el cuerpo del sitio-->  
<body class="body-form">

    <!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->    
<!--INICIO de una fila de elementos-->    
<div class="row">
<!--INICIO de una fila de elementos-->

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
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

<div class="headerform2">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
<tr>
<td>
    <%if(!mode.trim().equalsIgnoreCase("view")){%>
      <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
        <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
      </button>
    <%}%>
    <%if(!code.trim().equals("") && !code.trim().equals("0")){%>
    <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir('')"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
    <%}%>
    <!--<button type="button" class="btn btn-inverse btn-sm" onclick="imprimir('TD')"><i class="fa fa-print fa-printico"></i> <b>Imprimir Todo</b></button>-->
    
    <%if(alMoni.size() > 0){%>
        <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
            <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
        </button>
    <%}%>
</td>
</tr>
    <tr><th class="bg-headtabla">LISTADO DE MONITOREOS</th></tr>
</table>
<!--fin tabla de boton imprimit-->
<div class="table-wrapper pinkarize" id="hist_container" style="display:none">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
    <tr class="bg-headtabla2">
    <th style="vertical-align: middle !important;">C&oacute;digo</th>
    <th style="vertical-align: middle !important;">Fecha</th>
    <th style="vertical-align: middle !important;">Registrado Por</th>
    </thead>
<tbody>
<%
for (int p = 1; p<=alMoni.size(); p++){
    cdoEval = (CommonDataObject)alMoni.get(p-1);
    %>

<tr onclick="javascript:setCurrent(<%=cdoEval.getColValue("CODIGO")%>)" class="pointer pinkarize">
<td><%=cdoEval.getColValue("CODIGO")%></td>
<td><%=cdoEval.getColValue("fc")%></td>
<td><%=cdoEval.getColValue("USUARIO_CREACion")%></td>
</tr>
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
                <jsp:param name="nameOfTBox1" value="fecha_hora" />
                <jsp:param name="valueOfTBox1" value="<%=cdo1.getColValue("fecha_creacion", cDateTime)%>" />
                <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
            </jsp:include>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <cellbytelabel><strong>Fecha Nacimiento del producto</strong></cellbytelabel>
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1"/>
                <jsp:param name="format" value="dd/mm/yyyy"/>
                <jsp:param name="nameOfTBox1" value="fecha_nacimiento" />
                <jsp:param name="valueOfTBox1" value="<%=cdo1.getColValue("fecha_nacimiento")!=null?cdo1.getColValue("fecha_nacimiento"):""%>" />
                <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
            </jsp:include>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <cellbytelabel><strong>Semana de gestaci&oacute;n</strong></cellbytelabel>
             <%=fb.textBox("semana_gestacion",cdo1.getColValue("semana_gestacion"),false,false,viewMode,5,0,"form-control input-sm",null,null)%>
        </td>
    </tr>
    <tr>
        <td class="controls form-inline">
            <b>M&eacute;dico Obstetra:</b>
            <%=fb.textBox("medico_obstetra",cdo1.getColValue("medico_obstetra"),false,false,true,30,"form-control input-sm","display:inline; width:80px",null)%>
            <%=fb.textBox("medico_obstetra_nombre",cdo1.getColValue("medico_obstetra_nombre"),false,false,true,30,"form-control input-sm","display:inline; width:250px",null)%>
            <%=fb.button("btn_medico_obstetra","...",true,viewMode,null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
            
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <cellbytelabel><strong>P/A</strong></cellbytelabel>
             <%=fb.textBox("p_a",cdo1.getColValue("p_a"),false,false,viewMode,5,0,"form-control input-sm",null,null)%>
             
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <cellbytelabel><strong>FCF</strong></cellbytelabel>
             <%=fb.textBox("fc_fb",cdo1.getColValue("fc_fb"),false,false,viewMode,5,0,"form-control input-sm",null,null)%>
        </td>
    </tr>
    
    <tr>
        <td>
            <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                <tr class="bg-headtabla">
                    <td>Par&aacute;metro</td>
                    <td align="center">SI</td>
                    <td align="center">NO</td>
                    <td>Observaci&oacute;n</td>
                </tr>
                <% for (int d = 0; d<al.size(); d++){
                    cdo = (CommonDataObject) al.get(d);
                %>
                
                    <%=fb.hidden("cod_param"+d, cdo.getColValue("codigo"))%>
                    <tr>
                        <td><%=cdo.getColValue("descripcion")%></td>
                        <td align="center">
                            <%=fb.radio("valor"+d, "S" ,cdo.getColValue("valor"," ").trim().equalsIgnoreCase("S"),false,viewMode,null,"",null,"")%>
                        </td>
                        <td align="center">
                            <%=fb.radio("valor"+d, "N" ,cdo.getColValue("valor"," ").trim().equalsIgnoreCase("N"),false,viewMode,null,"",null,"")%>
                        </td>
                        <td>
                            <%=fb.textarea("observacion"+d,cdo.getColValue("observacion"),false,false,viewMode,30,1,2000,"form-control input-sm","width:100%","")%>
                        </td>
                    </tr>
                
                
                <%}%>
            </table>
        </td>
    </tr>
    
    <tr>
        <td class="controls form-inline">
            <b>Observaci&oacute;n:</b>
             <%=fb.textarea("observacion",cdo1.getColValue("observacion"),false,false,viewMode,30,1,2000,"form-control input-sm","width:100%","")%>
        </td>
    </tr>           
           
</tbody>
</table>
    

<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
    <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
        <%=fb.submit("save","Guardar",false,viewMode,"",null,"")%>
        <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
    </tr>
    </table> </div> 

<%=fb.hidden("total", ""+al.size())%>   
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
else
{
    String saveOption = request.getParameter("saveOption");
    String baction = request.getParameter("baction");
    int size = Integer.parseInt(request.getParameter("total"));
    
    al.clear();

    cdo = new CommonDataObject();
    cdo.setTableName("tbl_sal_monitoreo_fetal");
    cdo.addColValue("fecha_nacimiento", request.getParameter("fecha_nacimiento"));
    cdo.addColValue("semana_gestacion", request.getParameter("semana_gestacion"));
    cdo.addColValue("medico_obstetra", request.getParameter("medico_obstetra"));
    cdo.addColValue("p_a", request.getParameter("p_a"));
    cdo.addColValue("fc_fb", request.getParameter("fc_fb"));
    cdo.addColValue("observacion", request.getParameter("observacion"));
    
    if (!code.trim().equals("0")) {
        cdo.setAction("U");
        cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and codigo = "+code);
        cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
        cdo.addColValue("fecha_modificacion", cDateTime);
    } else {
        cdo.setAutoIncCol("codigo");
        cdo.addPkColValue("codigo", code);
        cdo.addRefColValue("codigo", "cod_monitoreo");
        
        cdo.addColValue("pac_id", pacId);
        cdo.addColValue("admision", noAdmision);
        cdo.setAction("I");
        cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
        cdo.addColValue("fecha_creacion", request.getParameter("fecha_hora"));
        cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
        cdo.addColValue("fecha_modificacion", cDateTime);
    }
    
    for (int i = 0; i<size; i++) {
        if (request.getParameter("valor"+i) != null) {
            CommonDataObject cdoD = new CommonDataObject();
            cdoD.setTableName("tbl_sal_monitoreo_fetal_det");
            cdoD.addColValue("cod_param", request.getParameter("cod_param"+i));
            cdoD.addColValue("observacion", request.getParameter("observacion"+i));
            cdoD.addColValue("valor", request.getParameter("valor"+i));
            
            if (!code.trim().equals("0")) {
                cdoD.setAction("U");
                cdoD.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and cod_monitoreo = "+code+" and cod_param = "+request.getParameter("cod_param"+i));
                cdoD.addColValue("cod_monitoreo", code);
            } else {
                cdoD.setAction("I");
                cdoD.addColValue("pac_id", pacId);
                cdoD.addColValue("admision", noAdmision);
            }
            
            al.add(cdoD);
        }
    }
    
    if (al.size() == 0) {
        CommonDataObject cdoD = new CommonDataObject();
        cdoD.setTableName("tbl_sal_monitoreo_fetal_det");
        cdoD.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and cod_monitoreo = "+code);
        
        al.add(cdoD);
    }
    
    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    SQLMgr.save(cdo,al,true,false,true,true);
    if (modeSec.equals("add")) {
        code = SQLMgr.getPkColValue("codigo");
    }
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=add&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>