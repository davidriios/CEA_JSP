<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.expediente.NosocomialBundle"%>
<%@ page import="issi.expediente.NosocomialBundleDet"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="NosoBunbleMgr" scope="page" class="issi.expediente.NosocomialBundleMgr" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
NosoBunbleMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

StringBuffer sbSql = new StringBuffer();
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String tubo = request.getParameter("tubo");
String medida = request.getParameter("medida");
String cds = request.getParameter("cds");
String from = request.getParameter("from");
String fecha = request.getParameter("fecha");
String tipo = request.getParameter("tipo");
String codigoBunble = request.getParameter("codigo_bunble");

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String userName = (String) session.getAttribute("_userName");
boolean viewMode = false;
String compania = (String) session.getAttribute("_companyId");

if (modeSec == null) modeSec = "";
if (mode == null) mode = "";
if (fecha == null) fecha = "";
if (tubo == null) tubo = "0";
if (medida == null) medida = "0";

if (modeSec.trim().equals("")) modeSec = "add";
if (mode.trim().equals("")) mode = "add";
if (fg == null) fg = "";
if (fp == null) fp = "";
if (id == null) id = "0";
if (from == null) from = "";
if (desc == null ) desc = "";
if (tipo == null ) tipo = "";

if (codigoBunble == null ) codigoBunble = "0";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String toDay = cDateTime.substring(0,10);
boolean insertado = false;
boolean mantenido = false;
boolean retirado = false;
boolean canAddMantenimiento = false;
boolean searching = false;

if (fecha.equals("")) fecha = toDay;

ArrayList alP = new ArrayList();
CommonDataObject cdoI = new CommonDataObject();
CommonDataObject cdoM = new CommonDataObject();
CommonDataObject cdoTmp = new CommonDataObject();
CommonDataObject cdoH = new CommonDataObject();

// todo remove
// toDay = "06/04/2017";

if (request.getMethod().equalsIgnoreCase("GET")) 
{           
    if (!tubo.trim().equals("0") && !medida.trim().equals("0")){
        
        alP = SQLMgr.getDataList(" select p.codigo, p.pregunta, p.activar_obs, p.totalizador, d.puntuacion, d.observacion, p.supervisor, decode(b.tipo,'M',b.usuario_creacion) usuario_creacion_m, b.codigo as codigo_bunble from tbl_sal_tubos_medidas tm, tbl_sal_tubo_medida_preguntas p, tbl_sal_noso_bundle_det d, tbl_sal_noso_bundle b where p.codigo_tub_med = tm.codigo and tm.codigo_tubo = "+tubo+" and tm.codigo_medida = "+medida+" and p.estado = 'A' and p.codigo = d.cod_preguntas(+) and d.cod_bunble = b.codigo(+) and b.codigo_control(+) = "+id+" and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and d.cod_bunble(+) = "+codigoBunble+" and d.pac_id = b.pac_id(+) and d.admision = b.admision(+) and b.codigo_control(+) = d.codigo_control order by p.orden");
        
        sbSql.append("select tm.codigo codigo_tubo_medida, m.codigo as tubo, m.nombre desc_medida, m.codigo as medida, t.nombre desc_tubo, tm.tipo, a.fecha_insercion, a.fecha_retiro, a.usuario_creacion, a.insertador, a.area, a.total, a.codigo as cod_bunble, nvl((select e.primer_nombre||' '||e.primer_apellido from tbl_pla_empleado e where to_char(e.emp_id) = a.insertador),'josue') insertador_desc, nvl(a.area,(select codigo from tbl_cds_centro_servicio where codigo = (select unidad_admin from tbl_sal_habitacion where codigo = ( select habitacion from tbl_adm_cama_admision where pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and admision = ");
        sbSql.append(noAdmision);
        sbSql.append(" and fecha_final is null and rownum = 1 ) and compania = ");
        sbSql.append(compania);
        sbSql.append(" ))) area, nvl((select descripcion from tbl_cds_centro_servicio where codigo = a.area ),(select descripcion from tbl_cds_centro_servicio where codigo = (select unidad_admin from tbl_sal_habitacion where codigo = ( select habitacion from tbl_adm_cama_admision where pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and admision = ");
        sbSql.append(noAdmision);
        sbSql.append(" and fecha_final is null and rownum = 1 ) and compania = ");
        sbSql.append(compania);
        sbSql.append(" ))) area_desc from tbl_sal_tubos_medidas tm, tbl_sal_tubos t, tbl_sal_medidas m,(select a.codigo, a.pac_id, a.admision, b.codigo_tubo_medida, b.tipo, to_char(a.fecha_insercion, 'dd/mm/yyyy hh12:mi:ss am') fecha_insercion, to_char(a.fecha_retiro, 'dd/mm/yyyy hh12:mi:ss am') fecha_retiro, a.usuario_creacion, a.insertador, a.area as a_area, b.total, b.codigo as cod_bunble, nvl((select e.primer_nombre||' '||e.primer_apellido from tbl_pla_empleado e where to_char(e.emp_id) = a.insertador),'"+userName+"') insertador_desc, nvl(a.area,(select codigo from tbl_cds_centro_servicio where codigo = (select unidad_admin from tbl_sal_habitacion where codigo = ( select habitacion from tbl_adm_cama_admision where pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and admision = ");
        sbSql.append(noAdmision);
        sbSql.append(" and fecha_final is null and rownum = 1 ) and compania = ");
        sbSql.append(compania);
        sbSql.append(" ))) area, nvl((select descripcion from tbl_cds_centro_servicio where codigo = a.area ),(select descripcion from tbl_cds_centro_servicio where codigo = (select unidad_admin from tbl_sal_habitacion where codigo = ( select habitacion from tbl_adm_cama_admision where pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and admision = ");
        sbSql.append(noAdmision);
        sbSql.append(" and fecha_final is null and rownum = 1 ) and compania = ");
        sbSql.append(compania);
        sbSql.append(" ))) area_desc from tbl_sal_noso_bundle_ctrl a, tbl_sal_noso_bundle b where a.pac_id = b.pac_id and a.admision = b.admision and a.codigo = b.codigo_control) a where tm.codigo_tubo = ");
        sbSql.append(tubo);
        sbSql.append(" and tm.codigo_medida = ");
        sbSql.append(medida);
        sbSql.append(" and tm.codigo_tubo = t.codigo and tm.codigo_medida = m.codigo and tm.codigo = a.codigo_tubo_medida(+) and a.pac_id(+) = ");
        sbSql.append(pacId);
        sbSql.append(" and a.admision(+) = ");
        sbSql.append(noAdmision);
        sbSql.append(" and a.codigo(+) = ");
        sbSql.append(id);
        
        cdoI = SQLMgr.getData(sbSql.toString());
        
        if (cdoI == null) cdoI = new CommonDataObject();
    }
    
    al = SQLMgr.getDataList(" select b.codigo, b.codigo_control, t.nombre tipo_desc, m.nombre medida_desc, t.codigo tubo, m.codigo medida, b.tipo, (select to_char(a.fecha_insercion,'dd/mm/yyyy hh12:mi:ss am') from tbl_sal_noso_bundle_ctrl a where a.pac_id = b.pac_id and a.admision = b.admision and b.tipo = 'I' and b.codigo_control = a.codigo and a.pac_id = b.pac_id and a.admision = b.admision ) fecha_insercion,  (select to_char(a.fecha_retiro,'dd/mm/yyyy hh12:mi:ss am') from tbl_sal_noso_bundle_ctrl a where a.pac_id = b.pac_id and a.admision = b.admision and b.tipo = 'M' and b.codigo_control = a.codigo and a.pac_id = b.pac_id and a.admision = b.admision ) fecha_retiro, (select c.descripcion from tbl_cds_centro_servicio c, tbl_sal_noso_bundle_ctrl a where c.codigo = a.area and a.pac_id = b.pac_id and a.admision = b.admision and b.tipo = 'I' and b.codigo_control = a.codigo and a.pac_id = b.pac_id and a.admision = b.admision) area from tbl_sal_noso_bundle b, tbl_sal_medidas m, tbl_sal_tubos t where b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.medida = m.codigo and b.tubo = t.codigo order by 3,1 ");
    
    if (request.getParameter("armado") != null) searching = false;
    
    if (!cdoI.getColValue("fecha_retiro"," ").trim().equals("") || !userName.equalsIgnoreCase(cdoI.getColValue("usuario_creacion", userName)) ) {
        viewMode = true;
    }

%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
    var noNewHeight = true;
    document.title = 'Notas de Diarias de Enfermeria - '+document.title;
    <%@ include file="../expediente/exp_checkviewmode.jsp"%>
    
    function doAction() {
       checkViewMode(); 
    }
    function verHistorial() {
      $("#hist_container").toggle();
    }
    
    $(function(){
        $("#tmp_tubo").change(function(){
            $("#tmp_medida").val("");
        });
        
        $("#tmp_medida").change(function(){
            var tipo = $(this).find("option:selected").attr("title");
            var medida = this.value;
            var tubo = $("#tmp_tubo").val();
            
            if (tubo && medida){
                var totI = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_noso_bundle','pac_id = <%=pacId%> and admision = <%=noAdmision%> and tipo = \'I\' /*and codigo_control = (select codigo from tbl_sal_noso_bundle_ctrl where pac_id = <%=pacId%> and admision = <%=noAdmision%> and fecha_retiro is null and fecha_creacion = (select max(fecha_creacion) from tbl_sal_noso_bundle_ctrl  where pac_id = <%=pacId%> and admision = <%=noAdmision%> and fecha_retiro is null) )*/ and tubo = '+tubo,'');
                // and medida = '+medida
                
                var totMWithRetiro = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_noso_bundle_ctrl c, tbl_sal_noso_bundle b',"c.pac_id = <%=pacId%> and c.admision = <%=noAdmision%> and c.fecha_retiro is not null and c.pac_id = b.pac_id and c.admision = b.admision and b.tipo = 'M' and c.codigo = b.codigo_control and b.tubo = "+tubo,'');
                
                if (totMWithRetiro < 1) {                              
                    if (tipo == 'I') {
                        if (totI > 0) {
                            parent.CBMSG.error("No puedes insertar el mismo tubo sin haberlo mantenido y retirado.");
                            return;
                        }
                    } else if (tipo == 'M') {
                        if (totI < 1) {
                            parent.CBMSG.error("No puedes mantener un tubo que no hayas insertado.");
                            return;
                        }
                    }
                }
                
                window.location = '../expediente3.0/exp_control_nosocomial_bundle.jsp?fg=<%=fg%>&fp=<%=fp%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fecha=<%=fecha%>&armado=Y&tubo='+tubo+'&medida='+medida+'&tipo='+tipo;
            }
        });
        
        $("select.supervisor").change(function(){
            $("#save").prop("disabled", false);
            $("#is_supervisor").val("Y");
        });
        
        $(".obs-supervisor").blur(function(){
            if (this.value) {
                $("#save").prop("disabled", false);
                $("#is_supervisor").val("Y");
            }
            else {
                $("#save").prop("disabled", true);
                $("#is_supervisor").val("");
            }
        });
    });
    
    function canSubmit(){
        var proceed = true;
        
        // logic
        
        computeTotal();
        return proceed;
    }
    
    function computeTotal() {
        var total = 0;
        var tot0 = 0;
        var tot1 = 0;
        $("select[name*='puntuacion']").not(".supervisor").each(function(){
            if(this.value == 0) tot0++; 
            if(this.value == 1) tot1++; 
        });
        if (tot0 == 0) total = 1; 
        $("#totalizador").val(total);
    }
    
    function cdsList() {
       abrir_ventana1('../common/search_centro_servicio.jsp?fp=nosocomial_bundle');
    }
    function insertadorList(){
      abrir_ventana1('../common/search_empleado.jsp?fp=nosocomial_bundle&fg=&index=');
    }
    function add(option){
        if(option == 2) window.location = '../expediente3.0/exp_control_nosocomial_bundle.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&cds=<%=cds%>&from=<%=from%>&fp=mantenimiento&fg=<%=fg%>&tipo=M&tubo=<%=tubo%>&id=<%=id%>';
        else window.location = '../expediente3.0/exp_control_nosocomial_bundle.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&cds=<%=cds%>&from=<%=from%>&fp=<%=fp%>&fg=<%=fg%>&tipo=I&id=0';
    }
    
    function setEvaluacion(codigo, codigoControl, tubo, medida, fechaInsercion, fechaRetiro, tipo) {
        var modeSec = (fechaRetiro || tipo == 'I') ? 'view':'edit';
        window.location = '../expediente3.0/exp_control_nosocomial_bundle.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&cds=<%=cds%>&from=<%=from%>&fp=<%=fp%>&fg=<%=fg%>&id='+codigoControl+'&tubo='+tubo+'&medida='+medida+'&mode=<%=mode%>&modeSec='+modeSec+'&codigo_bunble='+codigo+'&tipo='+tipo;
    }
function imprimir() {
    abrir_ventana1('../expediente3.0/print_exp_control_nosocomial_bundle.jsp?seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&id=<%=id%>&codigo_bundle=<%=codigoBunble%>&tubo=<%=tubo%>&medida=<%=medida%>');
} 

function imprimirMantenimiento() {
    var fDesde = $("#f_desde").toRptFormat() || '';
    var fHasta = $("#f_hasta").toRptFormat() || '';
    abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=expediente/rpt_mantenimientos_nosocomial_bundle.rptdesign&pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&pTubo=<%=tubo%>&tubo_desc=<%=cdoI.getColValue("desc_tubo"," ")%>&fecha_retiro=<%=cdoI.getColValue("fecha_retiro"," ").trim()%>&pCtrlHeader=false&fDesde='+fDesde+'&fHasta='+fHasta);
}    
</script>

</head>
<body class="body-form" onLoad="javascript:doAction()">

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
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("fp", fp)%>
<%=fb.hidden("codigo_bunble", codigoBunble)%>
<%=fb.hidden("codigo_tubo_medida", cdoI.getColValue("codigo_tubo_medida","0"))%>
<%=fb.hidden("tubo", tubo)%>
<%=fb.hidden("medida", medida)%>
<%=fb.hidden("tipo", tipo)%>
<%=fb.hidden("is_supervisor", "")%>

<div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-2">
        <tr>
            <td align="right" class="controls form-inline">
            <%if(!mode.trim().equals("view")){%>
                <%if(retirado||!canAddMantenimiento){%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="add(1)">
                        <i class="fa fa-plus fa-printico"></i> <b>Agregar Control</b>
                    </button>
                <%} else {%>
                    <%if(canAddMantenimiento){%>
                        <button type="button" class="btn btn-inverse btn-sm" onclick="add(2)">
                            <i class="fa fa-plus fa-printico"></i> <b>Agregar Mantenimiento</b>
                        </button>
                    <%}%>
                <%}%>
            <%}%>
        
            <%if(!id.trim().equals("") && !id.trim().equals("0")){%>
                &nbsp;
                <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir()"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
                &nbsp;
                
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="2"/>
                    <jsp:param name="format" value="dd/mm/yyyy"/>
                    <jsp:param name="nameOfTBox1" value="f_desde" />
                    <jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>" />
                    <jsp:param name="nameOfTBox2" value="f_hasta" />
                    <jsp:param name="valueOfTBox2" value="<%=cDateTime.substring(0,10)%>" />
                </jsp:include>    
                
                <button type="button" class="btn btn-inverse btn-sm" onclick="imprimirMantenimiento()"><i class="fa fa-print fa-printico"></i> <b>Mantenimientos</b></button>
            <%}%>
        
                <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
                    <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
                </button>
            </td>
        
        </tr>
    </table>
    
    <div class="table-wrapper" id="hist_container" style="display:none">
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
        <thead>
            <tr class="bg-headtabla2">
            <th style="vertical-align: middle !important;">C&oacute;digo</th>
            <th style="vertical-align: middle !important;">Tubo</th>
            <th style="vertical-align: middle !important;">Medida preventiva</th>
            <th style="vertical-align: middle !important;">F.Ins.</th>
            <th style="vertical-align: middle !important;">F.Retiro</th>
            <th style="vertical-align: middle !important;">&Aacute;rea</th>
        </thead>
        <tbody>
        <%for (int i=1; i<=al.size(); i++){
            CommonDataObject cdo1 = (CommonDataObject) al.get(i-1);
        %>
		<%=fb.hidden("codigo"+i,cdo1.getColValue("codigo"))%>
		<tr onClick="javascript:setEvaluacion(<%=cdo1.getColValue("codigo")%>,<%=cdo1.getColValue("codigo_control")%>,'<%=cdo1.getColValue("tubo")%>','<%=cdo1.getColValue("medida")%>','<%=cdo1.getColValue("fecha_insercion")%>','<%=cdo1.getColValue("fecha_retiro")%>', '<%=cdo1.getColValue("tipo")%>')" class="pointer">
            <td><%=cdo1.getColValue("codigo")%></td>
            <td><%=cdo1.getColValue("tipo_desc")%></td>
            <td><%=cdo1.getColValue("medida_desc")%></td>
            <td><%=cdo1.getColValue("fecha_insercion")%></td>
            <td><%=cdo1.getColValue("fecha_retiro")%></td>
            <td><%=cdo1.getColValue("area")%></td>
		</tr>
        <input type="hidden" name="all_ids<%=i%>" id="all_ids<%=i%>" value="<%=cdo1.getColValue("id")%>">
        <%}%>
        </tbody>
        </table>
    </div>
    
</div>

<table cellspacing="0" class="table table-small-font table-bordered">

    <%if( tubo.equals("0") ){%>
        <tr>
            <td class="controls form-inline">
                <b>Tipo Cat&eacute;ter/Tubo:</b>
                <%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_sal_tubos where estado = 'A'","tmp_tubo",tubo,false,insertado&&!id.trim().equals("0"),0,"form-control input-sm",null,"",null,"S")%>
            </td>
            <td class="controls form-inline">
                <b>Medida preventiva durante:</b>
                <%=fb.select(ConMgr.getConnection(),"select distinct m.codigo, m.nombre, tm.tipo from tbl_sal_medidas m, tbl_sal_tubos_medidas tm where m.codigo = tm.codigo_medida and m.estado = 'A' order by 1","tmp_medida","",false,false,0,"form-control input-sm",null,"",null,"S")%>
            </td>
        </tr>
    <%} else {%>
    
    <tr>
        <td colspan="3">
            <b>Tipo Cat&eacute;ter/Tubo:</b>&nbsp;<%=cdoI.getColValue("desc_tubo"," ")%>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <b>Medida preventiva durante:</b>&nbsp;<%=cdoI.getColValue("desc_medida"," ")%>
        </td>
    </tr>
    <tr>
        <td colspan="3" class="controls form-inline">
            <b><cellbytelabel>Fecha inserci&oacute;n:</cellbytelabel></b>&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1"/>
            <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
            <jsp:param name="nameOfTBox1" value="fecha_insercion" />
            <jsp:param name="valueOfTBox1" value="<%=cdoI.getColValue("fecha_insercion", cDateTime)%>" />
            <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
            </jsp:include>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <b>Insertado por:</b>&nbsp;
            <%=fb.hidden("insertador",cdoI.getColValue("insertador"))%>
            <%=fb.textBox("insertador_desc",cdoI.getColValue("insertador_desc",userName),false,false,true,0,"form-control input-sm","width:250px",null)%>
            <button class="btn btn-inverse btn-sm" type="button" onClick="insertadorList()"<%=(viewMode||modeSec.trim().equals("edit"))?" disabled":""%>><i class="fa fa-ellipsis-h"></i></button>
            
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <b>&Aacute;rea:</b>&nbsp;
            <%=fb.hidden("area",cdoI.getColValue("area"))%>
            <%=fb.textBox("area_desc",cdoI.getColValue("area_desc"),false,false,true,0,"form-control input-sm","width:250px",null)%>
            <button class="btn btn-inverse btn-sm" type="button" onClick="cdsList()"<%=(viewMode||modeSec.trim().equals("edit"))?" disabled":""%>><i class="fa fa-ellipsis-h"></i></button>
        </td>
    </tr>
    
    <tr class="bg-headtabla">
        <td>Cuestionario a validar</td>
        <td align="center">Puntuaci&oacute;n (1/0)</td>
        <td>Observaci&oacute;n</td>
    </tr>

    <%
    //userName = "lucas_paton";
    boolean isNotSupervisor = false;
    for (int p = 0; p < alP.size(); p++) {
        CommonDataObject cdo = (CommonDataObject)alP.get(p);
        
        if (!cdo.getColValue("usuario_creacion_m"," ").trim().equals("") && !userName.equalsIgnoreCase(cdo.getColValue("usuario_creacion_m"," ")) ) isNotSupervisor = true;
        else isNotSupervisor = false;
        
        if (mode.trim().equalsIgnoreCase("view")) isNotSupervisor = false;
    %>
        <%=fb.hidden("pregunta"+p, cdo.getColValue("codigo"))%>
        <%=fb.hidden("codigo_bunble"+p, cdo.getColValue("codigo_bunble"))%>
        <tr>
            <td>
                [<%=cdo.getColValue("codigo")%>]&nbsp;<%=cdo.getColValue("pregunta")%>
            </td>
            <td align="center">
                <%if(cdo.getColValue("totalizador","N").equalsIgnoreCase("N") || cdo.getColValue("supervisor","N").equalsIgnoreCase("S")){%>
                    <%if(cdo.getColValue("supervisor","N").equalsIgnoreCase("S")){%>
                        <%=fb.select("puntuacion"+p,"0=0,1=1",cdo.getColValue("puntuacion"),false,!isNotSupervisor,0,"supervisor",null,null,null,null)%>
                    <%} else {%>
                        <%=fb.select("puntuacion"+p,"0=0,1=1",cdo.getColValue("puntuacion"),false,viewMode,0,cdo.getColValue("supervisor","N").equalsIgnoreCase("S")?"supervisor":"",null,null,null,null)%>
                    <%}%>
                <%} else {%>
                    <%=fb.textBox("totalizador",cdoI.getColValue("total"),false,false,true,0,"form-control input-sm","width:50px",null)%>
                <%}%>
            </td>
            <td>
                <%if(cdo.getColValue("activar_obs","N").equalsIgnoreCase("S")){%>
                    <%if(cdo.getColValue("supervisor","N").equalsIgnoreCase("S")){%>
                        <%=fb.textarea("observacion"+p,cdo.getColValue("observacion"),false,false,!isNotSupervisor,0,1,2000,"form-control input-sm supervisor obs-supervisor","width:100%",null)%>
                    <%} else {%>
                        <%=fb.textarea("observacion"+p,cdo.getColValue("observacion"),false,false,viewMode,0,1,2000,"form-control input-sm","width:100%",null)%>
                    <%}%>
                <%}%>
                
            </td>
        </tr>
    <%  
    }}
    %>
    
    <%if(!searching && cdoI.getColValue("tipo","I").trim().equalsIgnoreCase("M")){%>
    <tr>
        <td class="controls form-inline" colspan="3">
            <b><cellbytelabel>Fecha Retiro:</cellbytelabel></b>&nbsp;
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1"/>
            <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
            <jsp:param name="nameOfTBox1" value="fecha_retiro" />
            <jsp:param name="valueOfTBox1" value="<%=cdoI.getColValue("fecha_retiro"," ").trim()%>" />
            <jsp:param name="readonly" value="<%=(!cdoI.getColValue("fecha_retiro"," ").trim().equals(""))?"y":"n"%>"/>
            </jsp:include>
        </td>
    </tr>
    <%}%>

</table>

<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
        <tr>
            <td>
                <%=fb.hidden("saveOption","O")%>
                <%=fb.submit("save","Guardar",false,viewMode||alP.size()==0,"",null,"")%>
                <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
        </tr>
    </table>
</div>
<%=fb.hidden("det_size", ""+alP.size())%>
<%=fb.formEnd(true)%>
</div>
 </div>
</body>
</html> 


<%
} else {
    String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("det_size"));
	al.clear();
            
    NosocomialBundle nb = new NosocomialBundle();
    nb.setTotal(request.getParameter("totalizador"));
    nb.setTipo(request.getParameter("tipo"));
    nb.setPacId(pacId);
    nb.setAdmision(noAdmision);
    nb.setUsuarioCreacion((String) session.getAttribute("_userName"));
    nb.setCodigoTuboMedida(request.getParameter("codigo_tubo_medida"));
    nb.setTubo(request.getParameter("tubo"));
    nb.setMedida(request.getParameter("medida"));
    
    if (request.getParameter("fecha_retiro") != null && !request.getParameter("fecha_retiro").equals("")) {
        nb.setFechaRetiro(request.getParameter("fecha_retiro"));
    }
    if (request.getParameter("is_supervisor") != null && !request.getParameter("is_supervisor").equals("")) {
        nb.setIsSupervisor(request.getParameter("is_supervisor"));
    }
    
    if (request.getParameter("id") != null && !request.getParameter("id").equals("") && !request.getParameter("id").equals("0")) {
        
        nb.setCodigo(id);
        nb.setUsuarioModificacion((String) session.getAttribute("_userName"));
        
    } else {

        if (request.getParameter("tipo") != null && request.getParameter("tipo").equalsIgnoreCase("I")){
            nb.setFechaInsercion(request.getParameter("fecha_insercion"));
            nb.setArea(request.getParameter("area"));
            nb.setInsertador(request.getParameter("insertador"));
        }
    }
    
    for (int i = 0; i < size; i++) {
        NosocomialBundleDet det = new NosocomialBundleDet();
        String puntuacion = "0";
        
        if (request.getParameter("puntuacion"+i)==null) puntuacion = "0";
        else if (request.getParameter("puntuacion"+i)==null || "".equals(request.getParameter("puntuacion"+i)) ) puntuacion = "0";
        else puntuacion = request.getParameter("puntuacion"+i);
        
        det.setPuntuacion(puntuacion);
        System.out.println(request.getParameter("pregunta"+i)+" :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "+puntuacion);
        det.setObservacion(request.getParameter("observacion"+i));
        det.setCodPreguntas(request.getParameter("pregunta"+i));
        det.setTipo(request.getParameter("tipo"));
        det.setTubo(request.getParameter("tubo"));
        det.setMedida(request.getParameter("medida"));
        det.setCodigoBundle(request.getParameter("codigo_bunble"+i));
        
        if (request.getParameter("id") != null && !request.getParameter("id").equals("") && !request.getParameter("id").equals("0")) {
            
        }
        
        nb.addDetalle(det);
    }
    
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    if (modeSec.equalsIgnoreCase("add")) {
        NosoBunbleMgr.addCtrl(nb);
        id = NosoBunbleMgr.getPkColValue("codigo");
    } else {
        NosoBunbleMgr.updateCtrl(nb);
    }
	ConMgr.clearAppCtx(null);
    
%>    
<html>
<head>
<script>
function closeWindow()
{
<%
if (NosoBunbleMgr.getErrCode().equals("1"))
{
%>
	alert('<%=NosoBunbleMgr.getErrMsg()%>');
<%
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
} else throw new Exception(NosoBunbleMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&id=<%=id%>&fecha=<%=fecha%>&tubo=<%=tubo%>&medida=<%=medida%>&codigo_bunble=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
