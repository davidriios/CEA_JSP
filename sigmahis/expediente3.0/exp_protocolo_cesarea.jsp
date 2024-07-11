<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.Interconsulta"%>
<%@ page import="issi.expediente.InterconsultaDiagnostico"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDiagPrePC" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagPrePC" scope="session" class="java.util.Vector" />
<jsp:useBean id="iDiagPostPC" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiagPostPC" scope="session" class="java.util.Vector" />
<jsp:useBean id="iProcPC" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProcPC" scope="session" class="java.util.Vector" />
<jsp:useBean id="iEmpPC" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEmpPC" scope="session" class="java.util.Vector" />
<jsp:useBean id="protocoloMgr" scope="page" class="issi.expediente.ProtocoloCesareaMgr" />
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
protocoloMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String desc = request.getParameter("desc");

String active0 = "", active1 = "", active2 = "", active3 = "", active4 = "", active5 = "";

if (fg == null) fg = "I";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (tab == null) tab = "0";

int rowCount = 0;
String sql2 = "";

String change = request.getParameter("change");
String code = request.getParameter("code");
String filter ="", filter2 ="";
String key = "";
if(code == null)code = "0";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
Properties prop = new Properties();

if (request.getMethod().equalsIgnoreCase("GET"))
{
    sql="select codigo, usuario_creacion, usuario_modificacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fc, to_char(fecha_creacion,'hh12:mi:ss am') hc, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fm, to_char(fecha_modificacion,'hh12:mi:ss am') hm from tbl_sal_protocolo_cesarea where pac_id = "+pacId+" and admision = "+noAdmision+" order by codigo desc";

    al2 = SQLMgr.getDataList(sql);
    
    if(code.trim().equals("0") && request.getParameter("force_add") == null) {
        cdo = SQLMgr.getData("select codigo from tbl_sal_protocolo_cesarea where pac_id = "+pacId+" and admision = "+noAdmision+" and fecha_creacion = (select max(fecha_creacion) from tbl_sal_protocolo_cesarea where pac_id = "+pacId+" and admision = "+noAdmision+" ) ");
        
        if (cdo == null) cdo = new CommonDataObject();
        code = cdo.getColValue("codigo","0");
    }

if(!code.trim().equals("0"))
{
	prop = SQLMgr.getDataProperties("select protocolo from tbl_sal_protocolo_cesarea where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+code);
	if (prop == null){
		if(!viewMode) modeSec="add";
        prop = new Properties();
	}
	else{
		if(!viewMode) modeSec= "view"; 
	}
	
    if(change == null) {

        iDiagPrePC.clear();
        vDiagPrePC.clear();
        iDiagPostPC.clear();
        vDiagPostPC.clear();
        iProcPC.clear();
        vProcPC.clear();
        iEmpPC.clear();
        vEmpPC.clear();
        
        sql = "select a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiagPost,a.observacion from tbl_sal_diag_protocolo_cesarea  a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PO' and a.cod_informe = "+code+" and a.pac_id = "+pacId+" and admision = "+noAdmision+" order by a.codigo desc";
        
        al = SQLMgr.getDataList(sql);
        
        for (int i=0; i<al.size(); i++) {
            cdo1 = (CommonDataObject) al.get(i);
            cdo1.setKey(i);
            cdo1.setAction("U");

            try
            {
              iDiagPostPC.put(cdo1.getKey(),cdo1);
              vDiagPostPC.addElement(cdo1.getColValue("diagnostico"));
            }
            catch(Exception e)
            {
              System.err.println(e.getMessage());
            }
        }

        sql="select  a.codigo,a.diagnostico, coalesce(g.observacion,g.nombre) descDiagPre ,a.observacion from tbl_sal_diag_protocolo_cesarea  a, tbl_cds_diagnostico g where a.diagnostico = g.codigo and a.tipo = 'PR' and a.cod_informe = "+code+" and a.pac_id = "+pacId+" and admision = "+noAdmision+" order by a.codigo desc";
        al = SQLMgr.getDataList(sql);
        
        for (int i=0; i<al.size(); i++) {
            cdo1 = (CommonDataObject) al.get(i);
            cdo1.setKey(i);
            cdo1.setAction("U");

            try
            {
              iDiagPrePC.put(cdo1.getKey(),cdo1);
              vDiagPrePC.addElement(cdo1.getColValue("diagnostico"));
            }
            catch(Exception e)
            {
              System.err.println(e.getMessage());
            }
        }
        
        sql="select  a.codigo,a.procedimiento,decode(h.observacion , null , h.descripcion,h.observacion)descProc from tbl_sal_proc_protocolo_cesarea a,tbl_cds_procedimiento h where  a.procedimiento = h.codigo and a.cod_protocolo = "+code+" and a.pac_id = "+pacId+" and admision = "+noAdmision+" order by a.codigo desc ";
        al = SQLMgr.getDataList(sql);
        
        for (int i=0; i<al.size(); i++) {
            cdo1 = (CommonDataObject) al.get(i);
            cdo1.setKey(i);
            cdo1.setAction("U");

            try{
              iProcPC.put(cdo1.getKey(),cdo1);
              vProcPC.addElement(cdo1.getColValue("procedimiento"));
            }
            catch(Exception e)
            {
              System.err.println(e.getMessage());
            }
        }
        
        sql="select  a.codigo, a.emp_id, nvl(a.nombre_emp, (select h.primer_nombre || ' ' || h.primer_apellido from tbl_pla_empleado h where a.emp_id = h.emp_id and rownum = 1) ) nombre_emp from tbl_sal_asistentes_proto_cesar a where a.cod_protocolo = "+code+" and a.pac_id = "+pacId+" and admision = "+noAdmision+" order by a.codigo desc ";
        al = SQLMgr.getDataList(sql);
        
        for (int i=0; i<al.size(); i++) {
            cdo1 = (CommonDataObject) al.get(i);
            cdo1.setKey(i);
            cdo1.setAction("U");

            try{
              iEmpPC.put(cdo1.getKey(),cdo1);
              vEmpPC.addElement(cdo1.getColValue("empId"));
            }
            catch(Exception e)
            {
              System.err.println(e.getMessage());
            }
        }        
    }
    if(!viewMode) modeSec = "edit";

}
else if(code.trim().equals("0") || prop == null)
{
    prop = new Properties();
    prop.setProperty("fecha",cDateTime);
    prop.setProperty("hora",cDateTime.substring(11));

    if(!viewMode) modeSec = "add";
    if(change == null)
    {
     iDiagPrePC.clear();
     vDiagPrePC.clear();
     iDiagPostPC.clear();
     vDiagPostPC.clear();
     iProcPC.clear();
     vProcPC.clear();
     iEmpPC.clear();
     vEmpPC.clear();
    }
}

if (tab.equals("0")) active0 = "active";
else if (tab.equals("1")) active1 = "active";
else if (tab.equals("2")) active2 = "active";
else if (tab.equals("3")) active3 = "active";
else if (tab.equals("4")) active4 = "active";
else if (tab.equals("5")) active5 = "active";

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
document.title = 'INFORME HISTOPATOLÓGICO - '+document.title;
function add(){window.location = '../expediente3.0/exp_protocolo_cesarea.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=0&desc=<%=desc%>&force_add=Y';}
function showDiagPost(){abrir_ventana1('../common/check_diagnostico.jsp?fp=protocolo_cesarea_pos&mode=<%=mode%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&exp=3');}
function showDiagPre(){abrir_ventana1('../common/check_diagnostico.jsp?fp=protocolo_cesarea_pre&mode=<%=mode%>&modeSec=<%=modeSec%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&exp=3');}
function setProtocolo(code){window.location = '../expediente3.0/exp_protocolo_cesarea.jsp?modeSec=<%=!viewMode?"edit":"view"%>&seccion=<%=seccion%>&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&code='+code;}
function showProcList(){abrir_ventana1('../common/check_procedimiento.jsp?fp=protocolo_cesarea&modeSec=<%=modeSec%>&mode=<%=mode%>&seccion=<%=seccion%>&pac_id=<%=pacId%>&admision=<%=noAdmision%>&id=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&exp=3');}
function doAction(){<%if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("1")){%>showDiagPre();<%}else if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("2")){%>showDiagPost();<%}else if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("3")){%>showProcList();<%}else if(request.getParameter("type")!=null && request.getParameter("type").trim().equals("4")){%>/*showEmpleadosList();*/<%}%>}
function imprimirEspecimen(){var fecha = eval('document.form0.fecha').value;abrir_ventana1('../expediente/print_informe_patologia.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&seccion=<%=seccion%>&fg=IP&desc=<%=desc%>&fechaProt='+fecha);}
function setHeight(){}
function verHistorial() {
  $("#hist_container").toggle();
}

function showEmpleadosList() {
 abrir_ventana1('../common/check_empleado.jsp?fp=protocolo_cesarea&modeSec=<%=modeSec%>&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>&exp=3');
}

$(function(){
    $('iframe').iFrameResize({
        log: false
    });
    
    $("input[name*='membrana']").click(function(){
        if (this.checked && this.value == 'R') {
            $("#tiempo_ruptura").prop("readOnly", false);
        } else {
            $("#tiempo_ruptura").prop("readOnly", true).val("");
        }
    });
    
    $("input[name*='muestras_histopato']").click(function(){
        if (this.checked && this.value == 'S') {
            $("#total_muestras").prop("readOnly", false);
        } else {
            $("#total_muestras").prop("readOnly", true).val("");
        }
    });
});

function showMedicoList(fg){
    var obj = {
        'CI': 'cirujano',
        'AN': 'anestesiologo',
        'PE': 'pediatra',
    };
    $("input[name*='"+obj[fg]+"']").val("");
    abrir_ventana1('../common/search_medico.jsp?fp=protocolo_cesarea&fg='+fg);
}
function showEmpleadoList(fg){
    var obj = {
        'CIR': 'circulador',
        'INS': 'instrumentador',
    };
    $("input[name*='"+obj[fg]+"']").val("");
    abrir_ventana1('../common/search_empleado.jsp?fp=protocolo_cesarea&fg='+fg);
}

function printProtocolo() {
    abrir_ventana1('../expediente3.0/print_protocolo_cesarea.jsp?pacId=<%=pacId%>&code=<%=code%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&cds=&seccion=<%=seccion%>');
}
</script>
</head>
<body class="body-form" topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-2">
        <tr>
            <td class="controls form-inline">
                <button type="button" class="btn btn-inverse btn-sm" onclick="printProtocolo()">
                    <i class="fa fa-print fa-printico"></i> <b>Imprimir</b>
                </button>
                <%if(!mode.trim().equals("view")){%>
                <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
                    <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
                  </button>
                <%}%>  
                <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
                    <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
                </button>
            </td>
        </tr>
    </table>
    
    <div class="table-wrapper" id="hist_container" style="display:none">
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
            <tr class="bg-headtabla2">
                <td><cellbytelabel>C&oacute;digo</cellbytelabel></td>
                <td><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
                <td><cellbytelabel>Creado por</cellbytelabel></td>
                <td><cellbytelabel>Fecha Modificación</cellbytelabel></td>
                <td><cellbytelabel>Modificado por</cellbytelabel></td>
            </tr>
            <% for (int i=1; i<=al2.size(); i++) {
                CommonDataObject cdo2 = (CommonDataObject) al2.get(i-1);
            %>
			<tr class="pointer" onClick="javascript:setProtocolo('<%=cdo2.getColValue("codigo")%>')">
                <td><%=cdo2.getColValue("codigo")%></td>
                <td><%=cdo2.getColValue("fc")%></td>
                <td><%=cdo2.getColValue("usuario_creacion")%></td>
                <td><%=cdo2.getColValue("fm")%></td>
                <td><%=cdo2.getColValue("usuario_modificacion")%></td>
			</tr>
            <%}%>
        </table>
    </div>
</div>

<ul class="nav nav-tabs" role="tablist">
    <li role="presentation" class="<%=active0%>">
        <a href="#generales" aria-controls="generales" role="tab" data-toggle="tab"><b>Datos Generales</b></a>
    </li>
    <%if (!modeSec.equalsIgnoreCase("add")){%>
    <li role="presentation" class="<%=active4%>">
        <a href="#asistentes" aria-controls="asistentes" role="tab" data-toggle="tab"><b>Asistentes</b></a>
    </li>
    <li role="presentation" class="<%=active1%>">
        <a href="#diag_pre_operatorio" aria-controls="diag_pre_operatorio" role="tab" data-toggle="tab"><b>Diag. Pre-Operatorio</b></a>
    </li>
    <li role="presentation" class="<%=active2%>">
        <a href="#diag_post_operatorio" aria-controls="diag_post_operatorio" role="tab" data-toggle="tab"><b>Diag. Post-Operatorio</b></a>
    </li>
    <li role="presentation" class="<%=active3%>">
        <a href="#procedimiento" aria-controls="procedimiento" role="tab" data-toggle="tab"><b>Procedimiento/Operaci&oacute;n</b></a>
    </li>
    <li role="presentation" class="<%=active5%>">
        <a href="#documentos" aria-controls="documentos" role="tab" data-toggle="tab"><b>Documentos</b></a>
    </li>
    <%}%>
</ul>

<!-- Tab panes -->
  <div class="tab-content">
  
    <!-- Generales -->
    <div role="tabpanel" class="tab-pane <%=active0%>" id="generales">
    
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
         <%=fb.hidden("code",code)%>
         <%=fb.hidden("tab","0")%>
         <%=fb.hidden("postSize",""+iDiagPostPC.size())%>
         <%=fb.hidden("preSize",""+iDiagPrePC.size())%>
         <%=fb.hidden("procSize",""+iProcPC.size())%>
         <%=fb.hidden("desc",desc)%>
         <%=fb.hidden("fecha_creacion", prop.getProperty("fecha_creacion")!=null&&!prop.getProperty("fecha_creacion").equals("")?prop.getProperty("fecha_creacion"):cDateTime)%>
         <%=fb.hidden("usuario_creacion", prop.getProperty("usuario_creacion")!=null&&!prop.getProperty("usuario_creacion").equals("")?prop.getProperty("usuario_creacion"):( (String) session.getAttribute("_userName")))%>
         
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
            <tr>
                <td class="controls form-inline">
                    <b><cellbytelabel>Cirujano</cellbytelabel>:</b>&nbsp;
                    <%=fb.hidden("cirujano", prop.getProperty("cirujano"))%>
                    <%=fb.textBox("cirujano_nombre",prop.getProperty("cirujano_nombre"),false,false,viewMode,30,0,"form-control input-sm","","")%>
                    <%=fb.button("btn_cirujano","...",true,viewMode,null,null,"onClick=showMedicoList('CI')","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Anestesi&oacute;logo</cellbytelabel>:</b>&nbsp;
                    <%=fb.hidden("anestesiologo", prop.getProperty("anestesiologo"))%>
                    <%=fb.textBox("anestesiologo_nombre", prop.getProperty("anestesiologo_nombre"),false,false,viewMode,30,0,"form-control input-sm","","")%>
                    <%=fb.button("btn_anestesiologo","...",true,viewMode,null,null,"onClick=showMedicoList('AN')","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Pediatra</cellbytelabel>:</b>&nbsp;
                    <%=fb.hidden("pediatra", prop.getProperty("pediatra"))%>
                    <%=fb.textBox("pediatra_nombre",prop.getProperty("pediatra_nombre"),false,false,viewMode,30,0,"form-control input-sm","","")%>
                    <%=fb.button("btn_pediatra","...",true,viewMode,null,null,"onClick=showMedicoList('PE')","")%>
                    
                </td>
            </tr>
            
            <tr>
                <td class="controls form-inline">
                    <b><cellbytelabel>Instrumentador</cellbytelabel>:</b>&nbsp;
                    <%=fb.hidden("instrumentador", prop.getProperty("instrumentador"))%>
                    <%=fb.textBox("instrumentador_nombre",prop.getProperty("instrumentador_nombre"),false,false,viewMode,30,0,"form-control input-sm","","")%>
                    <%=fb.button("btn_instrumentador","...",true,viewMode,null,null,"onClick=showEmpleadoList('INS')","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Circulador</cellbytelabel>:</b>&nbsp;
                    <%=fb.hidden("circulador", prop.getProperty("circulador"))%>
                    <%=fb.textBox("circulador_nombre",prop.getProperty("circulador_nombre"),false,false,viewMode,30,0,"form-control input-sm","","")%>
                    <%=fb.button("btn_circulador","...",true,viewMode,null,null,"onClick=showEmpleadoList('CIR')","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><em><span style="color:red">Los asistentes se guardarán después</span></em></b>
                    
                </td>
            </tr>
            
            <tr>
                <td class="controls form-inline">
                    <b><cellbytelabel>Cirug&iacute;a</cellbytelabel>:</b>&nbsp;
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fecha_cirugia" />
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
                    <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_cirugia", cDateTime)%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    </jsp:include>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Inicia</cellbytelabel>:</b>&nbsp;
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fecha_inicio" />
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
                    <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_inicio", " ").trim()%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    </jsp:include>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Termina</cellbytelabel>:</b>&nbsp;
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="fecha_fin" />
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
                    <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_fin", " ").trim()%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    </jsp:include>
                </td>
            </tr>
            
            <tr class="bg-headtabla2">
                <td>HALLAZGO</td>
            </tr>
            
            <tr>
                <td class="controls form-inline">Producto:<br>
                <b><cellbytelabel>Hora</cellbytelabel>:</b>&nbsp;
                    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1" />
                    <jsp:param name="clearOption" value="true" />
                    <jsp:param name="nameOfTBox1" value="hora_nacimiento" />
                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
                    <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("hora_nacimiento")%>" />
                    <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
                    </jsp:include>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Sexo</cellbytelabel>:</b>&nbsp;<%=fb.select("sexo","F=Femenino,M=Masculino",prop.getProperty("sexo"),false,false,0,"form-control input-sm",null,null,null,"S")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Apgar</cellbytelabel>:</b>&nbsp;<%=fb.textBox("apgar",prop.getProperty("apgar"),false,false,viewMode,4,0,"form-control input-sm","","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Apgar 5 minutos</cellbytelabel>:</b>&nbsp;<%=fb.textBox("apgar_cinco",prop.getProperty("apgar_cinco"),false,false,viewMode,4,0,"form-control input-sm","","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Peso</cellbytelabel>:</b>&nbsp;<%=fb.textBox("peso",prop.getProperty("peso"),false,false,viewMode,4,0,"form-control input-sm","","")%> kilo
                    <br><br>
                    <b><cellbytelabel>Presentaci&oacute;n</cellbytelabel>:</b>&nbsp;<%=fb.textBox("presentacion",prop.getProperty("presentacion"),false,false,viewMode,15,0,"form-control input-sm","","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Edad gestacional</cellbytelabel>:</b>&nbsp;<%=fb.textBox("edad_gestacional",prop.getProperty("edad_gestacional"),false,false,viewMode,4,0,"form-control input-sm","","")%>
                </td>
            </tr>
            
            <tr class="bg-headtabla2">
                <td>PROTOCOLO OPERATORIO</td>
            </tr>
            
            <tr>
                <td class="controls form-inline">
                    <b><cellbytelabel>Tipo de insici&oacute;n en la piel</cellbytelabel>:</b>&nbsp;<%=fb.textBox("tipo_insicion_piel",prop.getProperty("tipo_insicion_piel"),false,false,viewMode,20,0,"form-control input-sm","","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Tipo de insici&oacute;n en &uacute;tero</cellbytelabel>:</b>&nbsp;<%=fb.textBox("tipo_insicion_utero",prop.getProperty("tipo_insicion_utero"),false,false,viewMode,20,0,"form-control input-sm","","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Membranas</cellbytelabel>:</b>
                    &nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("membrana","I",prop.getProperty("membrana")!=null&&prop.getProperty("membrana").equalsIgnoreCase("I"),viewMode,false,null,null,"")%>&nbsp;<b>&Iacute;ntegras</b></label>
                    &nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("membrana","R",prop.getProperty("membrana")!=null&&prop.getProperty("membrana").equalsIgnoreCase("R"),viewMode,false,null,null,"")%>&nbsp;<b>Rotas</b></label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <%=fb.textBox("tiempo_ruptura",prop.getProperty("tiempo_ruptura"),false,false,true,4,0,"form-control input-sm","","")%>&nbsp;(horas)<br><br>
                    
                    <b><cellbytelabel>Liquido amni&oacute;tico</cellbytelabel>:</b>&nbsp;<%=fb.textBox("liquido_amniotico",prop.getProperty("liquido_amniotico"),false,false,viewMode,30,0,"form-control input-sm","","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Placenta</cellbytelabel>:</b>&nbsp;<%=fb.textBox("placenta",prop.getProperty("placenta"),false,false,viewMode,30,0,"form-control input-sm","","")%>
                </td>
            </tr>
            
            <tr class="bg-headtabla2">
                <td>OTRAS INFORMACIONES</td>
            </tr>
            
            <tr>
                <td class="controls form-inline">
                    <b><cellbytelabel>Drenajes</cellbytelabel>:</b>
                    &nbsp;<%=fb.textBox("drenajes",prop.getProperty("drenajes"),false,false,viewMode,40,0,"form-control input-sm","","")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b><cellbytelabel>Complicaciones peri operatorias</cellbytelabel>:</b>&nbsp;<%=fb.textBox("complicaciones_peri_op",prop.getProperty("complicaciones_peri_op"),false,false,viewMode,40,0,"form-control input-sm","","")%>
                    <br><br>
                    <b><cellbytelabel>N&uacute;mero de muestras histopatol&oacute;gicas</cellbytelabel>:</b>
                    &nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("muestras_histopato","S",prop.getProperty("muestras_histopato")!=null&&prop.getProperty("muestras_histopato").equalsIgnoreCase("S"),viewMode,false,null,null,"")%>&nbsp;SI</label>
                    &nbsp;&nbsp;&nbsp;
                    <label class="pointer"><%=fb.radio("muestras_histopato","N",prop.getProperty("muestras_histopato")!=null&&prop.getProperty("muestras_histopato").equalsIgnoreCase("N"),viewMode,false,null,null,"")%>&nbsp;NO</label>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <%=fb.textBox("total_muestras",prop.getProperty("total_muestras"),false,false,true,4,0,"form-control input-sm","","")%>&nbsp;(muestras)<br><br>
                </td>
            </tr>
            
        </table>
         
            <div class="footerform" style="bottom:-11px !important">
                <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                    <tr>
                        <td>
                            <small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                            <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
                       </td>
                    </tr>
                </table>   
            </div>
            <%=fb.formEnd(true)%>
    </div>
    
    <!-- Asistentes -->
    <div role="tabpanel" class="tab-pane <%=active4%>" id="asistentes">
     <%fb = new FormBean2("form4",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
     <%=fb.hidden("code",code)%>
     <%=fb.hidden("tab","4")%>
     <%=fb.hidden("postSize",""+iDiagPostPC.size())%>
     <%=fb.hidden("preSize",""+iDiagPrePC.size())%>
     <%=fb.hidden("procSize",""+iProcPC.size())%>
     <%=fb.hidden("empSize",""+iEmpPC.size())%>
     <%=fb.hidden("desc",desc)%>
     <table cellspacing="0" class="table table-small-font table-bordered">
        <tr class="bg-headtabla2">
            <td width="5%"><cellbytelabel id="12">C&oacute;dico</cellbytelabel></td>
            <td width="90%"><cellbytelabel id="13">Nombre</cellbytelabel></td>
            <td width="5%" align="center"><%=fb.submit("addAsis","+",false,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"","Agregar Asistentes")%></td>
        </tr>
        <%
            al = CmnMgr.reverseRecords(iEmpPC);
            for (int i=0; i<iEmpPC.size(); i++) {
              key = al.get(i).toString();
              cdo1 = (CommonDataObject) iEmpPC.get(key);
        %>
            <%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("action"+i,cdo1.getAction())%>
			<%=fb.hidden("key"+i,cdo1.getKey())%>
			<%=fb.hidden("codigo"+i,cdo1.getColValue("codigo"))%>
			<%if(cdo1.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("emp_id"+i,cdo1.getColValue("emp_id"))%>
			 <%=fb.hidden("nombre_emp"+i,cdo1.getColValue("nombre_emp"))%>
			<%}else{%>
			<tr class="TextRow01">
				<td><%=fb.textBox("emp_id"+i,cdo1.getColValue("emp_id"),false,false,true,6,"form-control input-sm","","")%></td>
				<td><%=fb.textBox("nombre_emp"+i,cdo1.getColValue("nombre_emp"),false,false,viewMode,40,100,"form-control input-sm","","")%></td>
				<td align="center"><%=fb.submit("rem"+i,"x",true,viewMode,null,null,"onClick=\"javascript:removeItem(this.form.name,"+i+");__submitForm(this.form, this.value)\"","Eliminar Diag.")%></td>
			</tr>

 <%	}}
	%>
			</table>
            <div class="footerform" style="bottom:-11px !important">
                <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                    <tr>
                        <td>
                            <small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                            <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
                       </td>
                    </tr>
                </table>   
            </div>
			<%=fb.formEnd(true)%>
    </div>
    
    
    
    <!-- Diag pre operatorio -->
    <div role="tabpanel" class="tab-pane <%=active1%>" id="diag_pre_operatorio">
     <%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
     <%=fb.hidden("code",code)%>
     <%=fb.hidden("tab","1")%>
     <%=fb.hidden("postSize",""+iDiagPostPC.size())%>
     <%=fb.hidden("preSize",""+iDiagPrePC.size())%>
     <%=fb.hidden("tipo","PR")%>
     <%=fb.hidden("procSize",""+iProcPC.size())%>
     <%=fb.hidden("desc",desc)%>
     <table cellspacing="0" class="table table-small-font table-bordered">
        <tr class="bg-headtabla2">
            <td width="10%"><cellbytelabel id="12">Diagn&oacute;stico</cellbytelabel></td>
            <td width="35%"><cellbytelabel id="13">Descripci&oacute;n</cellbytelabel></td>
            <td width="50%"><cellbytelabel id="14">Observaci&oacute;n</cellbytelabel></td>
            <td width="05%" align="center"><%=fb.submit("addDiag","+",false,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"","Agregar Diagnostico Pre.")%></td>
        </tr>
        <%
            al = CmnMgr.reverseRecords(iDiagPrePC);
            for (int i=0; i<iDiagPrePC.size(); i++) {
              key = al.get(i).toString();
              cdo1 = (CommonDataObject) iDiagPrePC.get(key);
        %>
            <%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("action"+i,cdo1.getAction())%>
			<%=fb.hidden("key"+i,cdo1.getKey())%>
			<%=fb.hidden("codigo"+i,cdo1.getColValue("codigo"))%>
			<%if(cdo1.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("diagPre"+i,cdo1.getColValue("diagnostico"))%>
			 <%=fb.hidden("descDiagPre"+i,cdo1.getColValue("descDiagPre"))%>
			 <%=fb.hidden("observacion"+i,cdo1.getColValue("observacion"))%>
			<%}else{%>
			<tr class="TextRow01">
				<td><%=fb.textBox("diagPre"+i,cdo1.getColValue("diagnostico"),true,false,true,6,"form-control input-sm","","")%></td>
				<td><%=fb.textBox("descDiagPre"+i,cdo1.getColValue("descDiagPre"),false,false,true,40,"form-control input-sm","","")%></td>
				<td><%=fb.textarea("observacion"+i,cdo1.getColValue("observacion"),false,false,viewMode,40,1,2000,"form-control input-sm","","")%></td>
				<td align="center"><%=fb.submit("rem"+i,"x",true,viewMode,null,null,"onClick=\"javascript:removeItem(this.form.name,"+i+");__submitForm(this.form, this.value)\"","Eliminar Diag.")%></td>
			</tr>

 <%	}}
	%>
			</table>
            <div class="footerform" style="bottom:-11px !important">
                <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
                    <tr>
                        <td>
                            <small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                            <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                            <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
                       </td>
                    </tr>
                </table>   
            </div>
			<%=fb.formEnd(true)%>
    </div>
    
    <!-- Diag post operatorio -->
    <div role="tabpanel" class="tab-pane <%=active2%>" id="diag_post_operatorio">
        <%fb = new FormBean2("form2",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
         <%=fb.hidden("code",code)%>
         <%=fb.hidden("tab","2")%>
         <%=fb.hidden("postSize",""+iDiagPostPC.size())%>
         <%=fb.hidden("preSize",""+iDiagPrePC.size())%>
         <%=fb.hidden("tipo","PO")%>
         <%=fb.hidden("procSize",""+iProcPC.size())%>
         <%=fb.hidden("desc",desc)%>              
        <table cellspacing="0" class="table table-small-font table-bordered">
            <tr class="bg-headtabla2">
                <td width="10%"><cellbytelabel id="12">Diagn&oacute;stico</cellbytelabel></td>
                <td width="35%"><cellbytelabel id="13">Descripci&oacute;n</cellbytelabel></td>
                <td width="50%"><cellbytelabel id="14">Observaci&oacute;n</cellbytelabel></td>
                <td width="05%" align="center"><%=fb.submit("addDiag","+",false,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"","Agregar Diagnostico Post")%></td>
            </tr>

            <%
            al = CmnMgr.reverseRecords(iDiagPostPC);
            for (int i=0; i<iDiagPostPC.size(); i++)
            {
              key = al.get(i).toString();
              cdo1 = (CommonDataObject) iDiagPostPC.get(key);

            %>
            <%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("action"+i,cdo1.getAction())%>
			<%=fb.hidden("key"+i,cdo1.getKey())%>
			<%=fb.hidden("codigo"+i,""+cdo1.getColValue("codigo"))%>
			<%if(cdo1.getAction().equalsIgnoreCase("D")){%>
			 <%=fb.hidden("diagPost"+i,cdo1.getColValue("diagnostico"))%>
			 <%=fb.hidden("descDiagPost"+i,cdo1.getColValue("descDiagPost"))%>
			 <%=fb.hidden("observacion"+i,cdo1.getColValue("observacion"))%>
			<%}else{%>
            <tr class="TextRow01">
            <td><%=fb.textBox("diagPost"+i,cdo1.getColValue("diagnostico"),true,false,true,6,"form-control input-sm","","")%></td>
            <td><%=fb.textBox("descDiagPost"+i,cdo1.getColValue("descDiagPost"),false,false,true,40,"form-control input-sm","","")%></td>
            <td><%=fb.textarea("observacion"+i,cdo1.getColValue("observacion"),false,false,viewMode,40,1,2000,"form-control input-sm","","")%></td>
            <td align="center"><%=fb.submit("rem"+i,"x",true,viewMode,null,null,"onClick=\"javascript:removeItem(this.form.name,"+i+");__submitForm(this.form, this.value)\"","Eliminar Diag.")%></td>
            </tr>
    <%	}}%>
    
    </table>
    <div class="footerform" style="bottom:-11px !important">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
                <td>
                    <small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                    <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
               </td>
            </tr>
        </table>   
    </div>
    <%=fb.formEnd(true)%>
    
    </div>
    
    <!-- Procedimientos -->
    <div role="tabpanel" class="tab-pane <%=active3%>" id="procedimiento">
    
        <%fb = new FormBean2("form3",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
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
         <%=fb.hidden("code",code)%>
         <%=fb.hidden("tab","3")%>
         <%=fb.hidden("postSize",""+iDiagPostPC.size())%>
         <%=fb.hidden("preSize",""+iDiagPrePC.size())%>
         <%=fb.hidden("procSize",""+iProcPC.size())%>
         <%=fb.hidden("desc",desc)%>
         <table cellspacing="0" class="table table-small-font table-bordered">
        <tr class="bg-headtabla2">
            <td width="05%"><cellbytelabel id="4">C&oacute;digo</cellbytelabel></td>
            <td width="90%"><cellbytelabel id="15">Procedimiento</cellbytelabel></td>
            <td width="05%" align="center"><%=fb.submit("addProc","+",false,viewMode,null,null,"onClick=\"__submitForm(this.form, this.value)\"","Agregar Espécimen")%></td>
        </tr>
        <%
        al = CmnMgr.reverseRecords(iProcPC);
        for (int i=0; i<iProcPC.size(); i++)
        {
          key = al.get(i).toString();
          cdo1 = (CommonDataObject) iProcPC.get(key);
        %>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("codigo"+i,""+cdo1.getColValue("codigo"))%>
			<%=fb.hidden("code"+i,""+cdo1.getColValue("code"))%>
			<%=fb.hidden("action"+i,cdo1.getAction())%>
			<%=fb.hidden("key"+i,cdo1.getKey())%>
			<%if(cdo1.getAction().equalsIgnoreCase("D")){%>
			<%=fb.hidden("procedimiento"+i,cdo1.getColValue("procedimiento"))%>
			<%=fb.hidden("descProc"+i,cdo1.getColValue("descProc"))%>
			<%}else{%>
            <tr class="TextRow01">
            <td><%=fb.textBox("procedimiento"+i,cdo1.getColValue("procedimiento"),true,false,true,10,"form-control input-sm","","")%></td>
            <td><%=fb.textBox("descProc"+i,cdo1.getColValue("descProc"),false,false,true,70,"form-control input-sm","","")%></td>
            <td align="center"><%=fb.submit("rem"+i,"x",true,viewMode,null,null,"onClick=\"javascript:removeItem(this.form.name,"+i+");__submitForm(this.form, this.name)\"","Eliminar.")%></td>
            </tr>
            <%	}}%>
            
            </table>
            
            <div class="footerform" style="bottom:-11px !important">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
                <td>
                    <small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
                    <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button>
               </td>
            </tr>
        </table>   
    </div>
    <%=fb.formEnd(true)%>

    </div>
    
    <!-- Documentos -->
    <div role="tabpanel" class="tab-pane <%=active5%>" id="documentos">
    
       <table width="100%" cellpadding="1" cellspacing="1" >
            <tr>
                <td>
                    <iframe id="doc_esc" name="doc_esc" width="100%" scrolling="yes" frameborder="0" src="../expediente3.0/exp_documentos.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&exp=3&expStatus=<%=request.getParameter("estado")!=null?request.getParameter("estado"):""%>&area_revision=SL&docs_for=protocolo_cesarea&docId=43"></iframe>
                </td>
            </tr>
        </table>

    </div>
    
    
    
</div> <!-- Tabs container-->








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
    String errorCode  = "";
    String errorMsg = "";

    if (tab.equals("0")) {
        prop = new Properties();
        prop.setProperty("pac_id",request.getParameter("pacId"));
        prop.setProperty("admision",request.getParameter("noAdmision"));
        prop.setProperty("usuario_creacion", request.getParameter("usuario_creacion"));
        prop.setProperty("fecha_creacion", request.getParameter("fecha_creacion"));

        prop.setProperty("cirujano", request.getParameter("cirujano"));
        prop.setProperty("cirujano_nombre", request.getParameter("cirujano_nombre"));
        prop.setProperty("anestesiologo", request.getParameter("anestesiologo"));
        prop.setProperty("anestesiologo_nombre", request.getParameter("anestesiologo_nombre"));
        prop.setProperty("pediatra", request.getParameter("pediatra"));
        prop.setProperty("pediatra_nombre", request.getParameter("pediatra_nombre"));
        prop.setProperty("instrumentador", request.getParameter("instrumentador"));
        prop.setProperty("instrumentador_nombre", request.getParameter("instrumentador_nombre"));
        prop.setProperty("circulador", request.getParameter("circulador"));
        prop.setProperty("circulador_nombre", request.getParameter("circulador_nombre"));
        prop.setProperty("fecha_cirugia", request.getParameter("fecha_cirugia"));
        prop.setProperty("fecha_inicio", request.getParameter("fecha_inicio"));
        prop.setProperty("fecha_fin", request.getParameter("fecha_fin"));
        prop.setProperty("hora_nacimiento", request.getParameter("hora_nacimiento"));
        prop.setProperty("sexo", request.getParameter("sexo"));
        prop.setProperty("apgar", request.getParameter("apgar"));
        prop.setProperty("apgar_cinco", request.getParameter("apgar_cinco"));
        prop.setProperty("peso", request.getParameter("peso"));
        prop.setProperty("presentacion", request.getParameter("presentacion"));
        prop.setProperty("edad_gestacional", request.getParameter("edad_gestacional"));
        prop.setProperty("tipo_insicion_piel", request.getParameter("tipo_insicion_piel"));
        prop.setProperty("tipo_insicion_utero", request.getParameter("tipo_insicion_utero"));
        prop.setProperty("membrana", request.getParameter("membrana"));
        prop.setProperty("tiempo_ruptura", request.getParameter("tiempo_ruptura"));
        prop.setProperty("liquido_amniotico", request.getParameter("liquido_amniotico"));
        prop.setProperty("placenta", request.getParameter("placenta"));
        prop.setProperty("drenajes", request.getParameter("drenajes"));
        prop.setProperty("complicaciones_peri_op", request.getParameter("complicaciones_peri_op"));
        prop.setProperty("muestras_histopato", request.getParameter("muestras_histopato"));
        prop.setProperty("total_muestras", request.getParameter("total_muestras"));

        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        if (modeSec.equalsIgnoreCase("add")){
            protocoloMgr.add(prop);
            code = protocoloMgr.getPkColValue("codigo");
        }
        else {
            prop.setProperty("usuario_modificacion", (String) session.getAttribute("_userName"));
            prop.setProperty("fecha_modificacion", cDateTime);
            prop.setProperty("codigo", code);
            
            protocoloMgr.update(prop);
        }
        ConMgr.clearAppCtx(null);
        
        errorCode = protocoloMgr.getErrCode();
        errorMsg = protocoloMgr.getErrMsg();
	}
	else if (tab.equals("1"))
	{
		int size = 0;
		if (request.getParameter("preSize") != null) size = Integer.parseInt(request.getParameter("preSize"));
		String itemRemoved = "",removedItem ="";
		iDiagPrePC.clear();
		vDiagPrePC.clear();
		al.clear();
		for (int i=0; i< size; i++)
		{
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_diag_protocolo_cesarea ");
            cdo.setWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"' and codigo="+request.getParameter("codigo"+i)+" and pac_id = "+pacId+" and admision = "+noAdmision);
            System.out.println(" CODIGO = ====== "+request.getParameter("codigo"+i));
            if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
            {
                cdo.setAutoIncCol("codigo");
                cdo.setAutoIncWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"'");
            }
            cdo.addColValue("codigo",request.getParameter("codigo"+i)); 
            cdo.addColValue("cod_informe",""+code);
            cdo.addColValue("diagnostico",request.getParameter("diagPre"+i));
            cdo.addColValue("descDiagPre",request.getParameter("descDiagPre"+i));
            cdo.addColValue("tipo",request.getParameter("tipo"));
            cdo.addColValue("observacion",request.getParameter("observacion"+i));
            cdo.addColValue("pac_id", pacId);
            cdo.addColValue("admision", noAdmision);
            
            cdo.setAction(request.getParameter("action"+i));
            cdo.setKey(i);
            if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
            {
                itemRemoved = cdo.getKey();
                if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
                else cdo.setAction("D");
            }
            
            if (!cdo.getAction().equalsIgnoreCase("X"))
            {
                try
                {
                    iDiagPrePC.put(cdo.getKey(),cdo);
                    if(!cdo.getAction().trim().equals("D"))vDiagPrePC.add(prop.getProperty("diagnostico"));
                    al.add(cdo);
                }
                catch(Exception e)
                {
                    System.err.println(e.getMessage());
                }
            }
		}
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
			return;
		}
		if(baction.equals("+"))//Agregar
		{
            response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab=1&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
            return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();

				cdo.setTableName("tbl_sal_diag_protocolo_cesarea");
				cdo.setWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"'");
				cdo.setAction("I");
				al.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
            
            errorCode = SQLMgr.getErrCode();
            errorMsg = SQLMgr.getErrMsg();
		}

	}//END TAB 1
	else if (tab.equals("2")) //diagnosticos post operatorio.
    {
		int size = 0;
		if (request.getParameter("postSize") != null) size = Integer.parseInt(request.getParameter("postSize"));
		String itemRemoved = "",removedItem ="";
		al.clear();
		iDiagPostPC.clear();
		vDiagPostPC.clear();
		for (int i=0; i<size; i++)
		{
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_diag_protocolo_cesarea");
            cdo.setWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"' and codigo="+request.getParameter("codigo"+i)+" and pac_id = "+pacId+" and admision = "+noAdmision);
            if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
            {
                cdo.setAutoIncCol("codigo");
                cdo.setAutoIncWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"'");
            }
            cdo.addColValue("codigo",request.getParameter("codigo"+i));
            cdo.addColValue("cod_informe",""+code);
            cdo.addColValue("diagnostico",request.getParameter("diagPost"+i));
            cdo.addColValue("descDiagPost",request.getParameter("descDiagPost"+i));
            cdo.addColValue("tipo",request.getParameter("tipo"));
            cdo.setAction(request.getParameter("action"+i));
            cdo.addColValue("observacion",request.getParameter("observacion"+i));
            cdo.addColValue("pac_id", pacId);
            cdo.addColValue("admision", noAdmision);
            
            
            cdo.setKey(i);
            if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
            {
                itemRemoved = cdo.getKey();
                if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
                else cdo.setAction("D");
            }
            
            if (!cdo.getAction().equalsIgnoreCase("X"))
            {
                try
                {
                    iDiagPostPC.put(cdo.getKey(),cdo);
                    if(!cdo.getAction().trim().equals("D"))vDiagPostPC.add(prop.getProperty("diagnostico"));
                    al.add(cdo);
                }
                catch(Exception e)
                {
                    System.err.println(e.getMessage());
                }
            }
		}
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
            return;
		}
		if(baction.equals("+"))//Agregar
		{
            response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=2&tab=2&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
            return;
		}

		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();

				cdo.setTableName("tbl_sal_diag_protocolo_cesarea");
				cdo.setWhereClause("cod_informe="+code+" and tipo = '"+request.getParameter("tipo")+"'");
				cdo.setAction("I");
				al.add(cdo);

			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
            
            errorCode = SQLMgr.getErrCode();
            errorMsg = SQLMgr.getErrMsg();
		}

	}//END TAB 3
	else if (tab.equals("3")) //Procedimientos.
    {
        int size = 0;
		if (request.getParameter("procSize") != null) size = Integer.parseInt(request.getParameter("procSize"));
		String itemRemoved = "",removedItem ="";
		al.clear();
		vProcPC.clear();
		iProcPC.clear();
        
		for (int i=0; i<size; i++){
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_proc_protocolo_cesarea");
            cdo.setWhereClause("cod_protocolo = "+code+" and codigo = "+request.getParameter("codigo"+i)+" and pac_id = "+pacId+" and admision = "+noAdmision);

            if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
            {
                cdo.setAutoIncCol("codigo");
                cdo.setAutoIncWhereClause("cod_protocolo = "+code);
            }
            cdo.addColValue("codigo",request.getParameter("codigo"+i));
            cdo.addColValue("cod_protocolo",""+code);
            cdo.addColValue("procedimiento",request.getParameter("procedimiento"+i));
            cdo.addColValue("descProc",request.getParameter("descProc"+i));
            cdo.addColValue("pac_id", pacId);
            cdo.addColValue("admision", noAdmision);

            cdo.setAction(request.getParameter("action"+i));
            cdo.setKey(i);
            if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {
                itemRemoved = cdo.getKey();
                if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
                else cdo.setAction("D");
            }
			
            if (!cdo.getAction().equalsIgnoreCase("X"))
            {
                try
                {
                    iProcPC.put(cdo.getKey(),cdo);
                    if(!cdo.getAction().trim().equals("D")) vProcPC.add(cdo.getColValue("procedimiento"));
                    al.add(cdo);
                }
                catch(Exception e)
                {
                    System.err.println(e.getMessage());
                }
            }
		}
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
            return;
		}
		if(baction.equals("+"))//Agregar
		{
            response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=3&tab=3&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
            return;
		}
		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_proc_protocolo_cesarea");
				cdo.setWhereClause("cod_protocolo = "+code);
				cdo.setAction("I");
				al.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
            
            errorCode = SQLMgr.getErrCode();
            errorMsg = SQLMgr.getErrMsg();
		}
        
	}//END TAB
    
    else if (tab.equals("4")) //Asistentes.
    {
        int size = 0;
		if (request.getParameter("empSize") != null) size = Integer.parseInt(request.getParameter("empSize"));
		String itemRemoved = "",removedItem ="";
		al.clear();
		vEmpPC.clear();
		iEmpPC.clear();
        
		for (int i=0; i<size; i++){
            cdo = new CommonDataObject();
            cdo.setTableName("tbl_sal_asistentes_proto_cesar");
            cdo.setWhereClause("cod_protocolo = "+code+" and codigo = "+request.getParameter("codigo"+i)+" and pac_id = "+pacId+" and admision = "+noAdmision);

            if (request.getParameter("codigo"+i).equals("0")||request.getParameter("codigo"+i).trim().equals(""))
            {
                cdo.setAutoIncCol("codigo");
                cdo.setAutoIncWhereClause("cod_protocolo = "+code);
            }
            cdo.addColValue("codigo",request.getParameter("codigo"+i));
            cdo.addColValue("cod_protocolo",""+code);
            cdo.addColValue("emp_id",request.getParameter("emp_id"+i));
            cdo.addColValue("nombre_emp",request.getParameter("nombre_emp"+i));
            cdo.addColValue("pac_id", pacId);
            cdo.addColValue("admision", noAdmision);

            cdo.setAction(request.getParameter("action"+i));
            cdo.setKey(i);
            if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {
                itemRemoved = cdo.getKey();
                if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");
                else cdo.setAction("D");
            }
			
            if (!cdo.getAction().equalsIgnoreCase("X"))
            {
                try
                {
                    iEmpPC.put(cdo.getKey(),cdo);
                    if(!cdo.getAction().trim().equals("D")) vEmpPC.add(cdo.getColValue("emp_id"));
                    al.add(cdo);
                }
                catch(Exception e)
                {
                    System.err.println(e.getMessage());
                }
            }
		}
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
            return;
		}
		if(baction.equals("+"))//Agregar
		{
            cdo = new CommonDataObject();
            cdo.addColValue("emp_id","");
            cdo.addColValue("nombre_emp","");
            cdo.setKey(""+iEmpPC.size()+1);
            cdo.setAction("I");
            try {
                iEmpPC.put(cdo.getKey(),cdo);
                al.add(cdo);
            }
            catch(Exception e) {
                System.err.println(e.getMessage());
            }
            response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=4&tab=4&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&code="+code+"&desc="+desc);
            return;
		}
		if (baction.equalsIgnoreCase("Guardar"))
		{
			if (al.size() == 0)
			{
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_asistentes_proto_cesar");
				cdo.setWhereClause("cod_protocolo = "+code);
				cdo.setAction("I");
				al.add(cdo);
			}
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,true);
			ConMgr.clearAppCtx(null);
            
            errorCode = SQLMgr.getErrCode();
            errorMsg = SQLMgr.getErrMsg();
		}
        
	}//END TAB
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (errorCode.equals("1"))
{
%>
	alert('<%=errorMsg%>');
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
} else throw new Exception(errorMsg);
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&tab=<%=tab%>&desc=<%=desc%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>