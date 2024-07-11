<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="PAKMgr" scope="page" class="issi.expediente.PlanAtencionKardexMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
PAKMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
Properties prop = new Properties();

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String code = request.getParameter("code");
String key="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (code == null) code = "0";
if (fg == null) fg = "SAD";
if (fp == null) fp = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET")) {
	
	if (!code.trim().equals("0") || !fp.trim().equals("")) {
      String sql = "select kardex from tbl_sal_plan_atencion_kardex where pac_id="+pacId+" and admision="+noAdmision;
      
      if (!fp.trim().equals("")){
        sql += " and codigo = ( select max(codigo) from tbl_sal_plan_atencion_kardex where pac_id = "+pacId+" and admision = "+noAdmision+" )";
      } else {
        sql += " and codigo = "+code;
      }
      
      prop = SQLMgr.getDataProperties(sql);
      
      if (prop == null) {
        prop = new Properties();
      } else {
        if(!viewMode) modeSec = "edit";
        if (fp.trim().equalsIgnoreCase("recuperar")) {
            modeSec = "add";
        }
      }
      
    } else {
        // > 49 riesgo de caida
        // < 16 riesgo de caida
        sbSql = new StringBuffer();
        sbSql.append("select '[ '||d.codigo||' ] '||d.nombre diag, nvl((select total from tbl_sal_escalas where tipo = 'DO' and pac_id = ad.pac_id and admision = ad.admision and id = (select max(id) from tbl_sal_escalas where tipo = 'DO' and pac_id = ad.pac_id and admision = ad.admision)),(select total from tbl_sal_escalas where tipo = 'MAC' and pac_id = ad.pac_id and admision = ad.admision and id = (select max(id) from tbl_sal_escalas where tipo = 'MAC' and pac_id = ad.pac_id and admision = ad.admision))) as caida, (select total from tbl_sal_escala_norton where tipo = 'BR' and pac_id = ad.pac_id and secuencia = ad.admision and id = (select max(id) from tbl_sal_escala_norton where tipo = 'BR' and pac_id = ad.pac_id and secuencia = ad.admision)) ulcera, (select id from tbl_sal_notas_diarias_enf where tipo_nota = 'NDE' and pac_id = ad.pac_id and admision = ad.admision and id = (select max(id) from tbl_sal_notas_diarias_enf where tipo_nota = 'NDE' and pac_id = ad.pac_id and admision = ad.admision )) nota_diaria "); 
        
        sbSql.append(", (select total from tbl_sal_escalas where tipo = 'AN' and pac_id = ad.pac_id and admision = ad.admision and id = (select max(id) from tbl_sal_escalas where tipo = 'AN' and pac_id = ad.pac_id and admision = ad.admision)) as dolor");
        
        sbSql.append(", (select total from tbl_sal_escala_coma where pac_id = ad.pac_id and secuencia = ad.admision and fecha_registro = ( select max(fecha_registro) from tbl_sal_escala_coma where pac_id = ad.pac_id and secuencia = ad.admision ) ) as glasgow");
        
        sbSql.append(", (select codigo from tbl_sal_eval_aprendizaje where pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and admision = ");
        sbSql.append(noAdmision);
        sbSql.append(" and fecha_creacion = ( select max(fecha_creacion) from tbl_sal_eval_aprendizaje where pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and admision = ");
        sbSql.append(noAdmision);
        sbSql.append(" )) cod_aprendizaje ");
        
        sbSql.append(" from tbl_adm_diagnostico_x_admision ad, tbl_cds_diagnostico d where ad.pac_id = ");
        sbSql.append(pacId);
        sbSql.append("and ad.admision = ");
        sbSql.append(noAdmision);
        sbSql.append("and ad.tipo = 'I' and ad.orden_diag = 1 and d.codigo = ad.diagnostico");
        
        cdo = SQLMgr.getData(sbSql.toString());
    }
    
    ArrayList alH = SQLMgr.getDataList("select codigo, to_char(fecha_creacion, 'dd/mm/yyyy') fc, to_char(fecha_creacion, 'hh12:mi am') hc, usuario_creacion from tbl_sal_plan_atencion_kardex where pac_id="+pacId+" and admision="+noAdmision+" order by 1 desc");

// No me gusta esa idea, pero Infovision contrata su administrador de proyecto que es un yes mas al igual que los que aprueban
    
Properties propAlergias = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = 'NEEU'");

CommonDataObject cdo1 = SQLMgr.getData("select (select count(*) from tbl_sal_alergia_paciente where pac_id = "+pacId+" and nvl(admision,"+noAdmision+") = "+noAdmision+") tot_ant_aler, (select formulario from tbl_sal_nota_eval_enf_urg where pac_id = "+pacId+" and admision = "+noAdmision+") formularios from dual");

Properties propBa = SQLMgr.getDataProperties("select evaluaciones from tbl_sal_eval_aprendizaje where pac_id = "+noAdmision+" and admision = "+noAdmision+" and fecha_creacion = (select max(fecha_creacion) from tbl_sal_eval_aprendizaje where pac_id = "+pacId+" and admision = "+noAdmision+")");
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
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
var noNewHeight = true;
$(function(){

  $("#imprimir").click(function(e){
    e.preventDefault();
    var codeNota = $("#nota_diaria").val() || 0;
    var codBarrea = $("#cod_aprendizaje").val()||0;
    abrir_ventana("../expediente3.0/print_plan_atencion_kardex.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&codigo=<%=code%>&code_nota="+codeNota+"&cod_barrera="+codBarrea);
  });
  
  // ver antecedentes
  $("#btn_ant_alergicos").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente3.0/print_exp_seccion_11.jsp?seccion=11&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=ANTECEDENTES ALERGICOS&fg=exp_kardex");
  });
  $("#btn_eval_1").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente3.0/print_exp_seccion_108.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=NEEU&seccion=108&desc=EVALUACION INICIAL I DE ENFERMERIA&fp=exp_kardex");
  });
  
  // ver aislamiento
  $("#btn_aislamiento").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente3.0/print_cuestionarios.jsp?seccion=123&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=EVALUACION II&fp=exp_kardex&fg=C1");
  });
  
  // ver nutrición
  $("#btn_nutricion").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente/print_exp_seccion_37.jsp?seccion=37&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=O/M NUTRICION&fp=exp_kardex&idOrden=0&tipoOrden=3");
  });
  $("#btn_nutricion_np").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente/print_exp_seccion_98_all.jsp?seccion=98&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=O/M NUTRICION PARENTERAL NEONATAL Y PEDIATRICO&fp=exp_kardex&fg=EN");
  });
   $("#btn_nutricion_pa").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente/print_exp_seccion_97_all.jsp?seccion=98&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=O/M NUTRICION PARENTERAL ADULTO&fp=exp_kardex&fg=EA");
  });
  
  // ver om tratamientos
  $("#btn_inhaloterapia").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente/print_exp_seccion_20.jsp?seccion=20&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=O/M TRAMAMIENTOS&fp=exp_kardex&codigo=0");
  });

  // ver notas enfermeras diarias
  $("#btn_notas_enf_diarias").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente3.0/print_notas_diarias_enf.jsp?seccion=132&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=NDE&desc=NOTAS DIARIAS DE ENFERMERIA&fp=exp_kardex&cond_title=0&code=<%=cdo!=null && cdo.getColValue("nota_diaria")!=null && !cdo.getColValue("nota_diaria").equals("")?cdo.getColValue("nota_diaria"):prop.getProperty("nota_diaria")%>");
  });

  // ver om insulinas
  $("#btn_insulinas").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente/print_exp_seccion_79.jsp?seccion=79&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=exp_kardex&desc=O/M ESQUEMA DE INSULINA&fp=exp_kardex&tipoOrden=8&id=0");
  });
  
  // ver balance hidrico
  $("#btn_balance_hidrico").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente/print_balance_hidrico.jsp?seccion=66&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=exp_kardex&desc=BALANCE HIDRICO&fp=exp_kardex");
  });
  
  // ver om tratamientos
  $("#btn_tratamientos").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente/print_exp_seccion_20.jsp?seccion=20&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=O/M TRAMAMIENTOS&fp=exp_kardex_not&codigo=0");
  });
  
  // ver om varias
  $("#btn_om_varias").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente/print_list_ordenmedica.jsp?seccion=76&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=O/M VARIAS&fg=OV&fp=exp_kardex&id=0&tipoOrden=8");
  });
  
  // ver om imagenologia
  $("#btn_om_imagenologia").click(function(e){
    //abrir_ventana("../expediente/ordenes_medicas_list.jsp?seccion=19&pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&desc=O/M EXAMENES IMAGENOLOGIA&fg=exp_seccion&fp=exp_kardex&tipo_orden=1&interfaz=RIS");
    abrir_ventana('../expediente/exp_examen_pending.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=imagenologia&fg=kardex');
  });

  // ver om interconsulta
  $("#btn_om_interconsulta").click(function(e){
    abrir_ventana("../expediente/print_exp_seccion_30.jsp?seccion=30&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=O/M SOLICITUD DE  INTERCONSULTA&fp=exp_kardex");
  });
  // ver barreras
  $("#btn_barreras").click(function(e){
    var codBarrea = $("#cod_aprendizaje").val()||0;
    abrir_ventana('../expediente3.0/print_eval_aprendizaje.jsp?desc=EVALUACION DEL APRENDIZAJE&pacId=<%=pacId%>&seccion=120&noAdmision=<%=noAdmision%>&fg=kardex&codigo='+codBarrea);
  });
  // ver vulnerabilidad
  $("#btn_vulnerabilidad").click(function(e){
    abrir_ventana('../expediente3.0/exp_nota_eval_enf_urg.jsp?fg=NEEU&desc=CONFIRMACION%20RIESGO%20/%20VULNERABILIDAD&pacId=<%=pacId%>&seccion=108&noAdmision=<%=noAdmision%>&mode=&cds=77&defaultAction=1&medico=&from=salida_pop&only_riesgo=1&fp=kardex');
  });
  // ver laboratorios pendientes
  $("#btn_lab").click(function(e){
    abrir_ventana('../expediente/exp_examen_pending.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=laboratorio&fg=kardex');
  });
  
  // sondas cateter
  $("#btn_sondas").click(function(e){
    abrir_ventana1('../expediente/print_control_invasivos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=43&desc=PROCEDIMIENTOS INVASIVOS&fechaControl=&fp=kardex');
  });
  
  // medicamentos / tratamientos / dosis
  $("#btn_med_trat_dosis").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente/print_list_ordenmedica.jsp?seccion=76&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=&fg=ME&fp=exp_kardex&id=0&tipoOrden=2");
  });
  
  // procedimientos
  $("#btn_proc_cir").click(function(e){
    abrir_ventana('../expediente/print_exp_seccion_23.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=23&desc=O/M PROCEDIMIENTOS&code=0&fg=');
  }); 
  
  // valores criticos
  $("#btn_val_criticos").click(function(){
    abrir_ventana1('../expediente3.0/print_valores_criticos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=113&desc=VALORES CRITICOS');
  });
  
  // laboratorios ejecutados
  $("#btn_lab_ejec").click(function(e){
    e.preventDefault();
    abrir_ventana("../expediente/print_list_ordenmedica.jsp?seccion=76&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=&fg=ME&fp=exp_kardex&id=0&tipoOrden=1");
  });
  
  $(".should-type").click(function(){
      var that = $(this);
      var i = that.data('index');
      if (that.is(":checked")) {
        $("#observacion"+i).prop("readOnly", false)
      } else {
        $("#observacion"+i).val("").prop("readOnly", true)
      }
    });
  
});


function canSubmit() {
  var proceed = true;
  $(".observacion").each(function() {
    var $self = $(this);
    var i = $self.data('index');
    var message = $self.data('message');
    if ( $self.is(":checked") && !$.trim($("#observacion"+i).val())) {
      parent.parent.CBMSG.error(message ? message : "Cuando selecciona 'Otro', el campo de observación es obligatorio!");
      proceed = false;
      $self.focus();
      return false;  
    }else  {proceed = true;}
  });
  return proceed;
}

function shouldTypeRadio(check, textareaIndex) {
  if (check == true) $("#observacion"+textareaIndex).prop("readOnly", false)
  else $("#observacion"+textareaIndex).val("").prop("readOnly", true)
}

function setKardex(code){
    window.location = '../expediente3.0/exp_plan_atencion_kardex.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&code='+code;
}
function add(){
    window.location = '../expediente3.0/exp_plan_atencion_kardex.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>';
}

function verHistorial() {
  $("#hist_container").toggle();
}

function recuperar() {
    window.location = '../expediente3.0/exp_plan_atencion_kardex.jsp?modeSec=add&mode=add&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>&fp=recuperar';
}
</script>
</head>
<body class="body-form">
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
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("code", code)%>
<%=fb.hidden("nota_diaria", cdo!=null && cdo.getColValue("nota_diaria")!=null && !cdo.getColValue("nota_diaria").equals("")?cdo.getColValue("nota_diaria"):prop.getProperty("nota_diaria"))%>
<%=fb.hidden("cod_aprendizaje", cdo!=null && cdo.getColValue("cod_aprendizaje")!=null && !cdo.getColValue("cod_aprendizaje").equals("")?cdo.getColValue("cod_aprendizaje"):prop.getProperty("cod_aprendizaje"))%>

    <div class="headerform">
        <table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
            <tr>
                <td>
                    <%=fb.button("imprimir","Imprimir",false,false,null,null,"")%>
                    <%if(!mode.trim().equals("view")){%>
                      <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
                        <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
                      </button>
                      <%if(fp.trim().equals("")){%>
                          <button type="button" class="btn btn-inverse btn-sm" onclick="recuperar()">
                            <b>Recuperar</b>
                          </button>
                      <%}%>
                    <%}%>
                      <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
                        <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
                      </button>
                </td>
            </tr>
        </table>
    </div>
    
    <div class="table-wrapper" id="hist_container" style="display:none">
        <table cellspacing="0" class="table table-small-font table-bordered table-striped">
            <thead>
                <tr class="bg-headtabla2">
                <th style="vertical-align: middle !important;">C&oacute;digo</th>
                <th style="vertical-align: middle !important;">Fecha</th>
                <th style="vertical-align: middle !important;">Hora</th>
                <th style="vertical-align: middle !important;">Usuario</th>
            </thead>
            <%
            for (int p = 1; p <= alH.size(); p++){
                CommonDataObject cdoH = (CommonDataObject)alH.get(p-1);
            %>
            <tbody>
                <tr onclick="javascript:setKardex('<%=cdoH.getColValue("codigo")%>')" class="pointer">
                    <td><%=cdoH.getColValue("codigo")%></td>
                    <td><%=cdoH.getColValue("fc")%></td>
                    <td><%=cdoH.getColValue("hc")%></td>
                    <td><%=cdoH.getColValue("usuario_creacion")%></td>
                </tr>
            </tbody>
            <% }%>
        </table>    
    </div>  

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
    <tr>
      <td class="controls form-inline">
        <b>Diagnóstico Actual:</b>&nbsp;
        <%=fb.textBox("diag_actual", cdo!=null&&cdo.getColValue("diag") != null?cdo.getColValue("diag"):prop.getProperty("diag_actual"),true,false,(viewMode||prop.getProperty("diag_actual").equals("")),60,"form-control input-sm",null,null)%>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <b>Fecha de Traslado y Servicio:</b> 
        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />
            <jsp:param name="clearOption" value="true" />
            <jsp:param name="nameOfTBox1" value="fecha_traslado" />
            <jsp:param name="valueOfTBox1" value="<%=prop.getProperty("fecha_traslado")%>" />
            <jsp:param name="readonly" value="<%=viewMode?"y":"n"%>" />
        </jsp:include>
      </td>
    </tr>
    
    <tr>
        <td>
            <%if( (propAlergias!=null && propAlergias.getProperty("alergia0")!=null && !"".equals(propAlergias.getProperty("alergia0")) && !"N".equalsIgnoreCase(propAlergias.getProperty("alergia0"))) || ( cdo1 != null && !cdo1.getColValue("tot_ant_aler","0").equals("0")) ){%>
                <span style="color:red !important"><b>Alergias:</b></span>&nbsp;
            <%} else {%>
                <b>Alergias:</b>&nbsp;
            <%}%>
            <button type="button" id="btn_ant_alergicos" class="btn btn-inverse btn-sm">
               <i class="fa fa-eye fa-lg"></i> 
                Antecendes Al&eacute;gicos
            </button>
            <button type="button" id="btn_eval_1" class="btn btn-inverse btn-sm">
                <i class="fa fa-eye fa-lg"></i> Evaluaci&oacute;n I
            </button>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label for="alergia0" class="pointer">Niega</label>
			<%=fb.checkbox("alergia0","0",(prop.getProperty("alergia0").equalsIgnoreCase("0")),viewMode,"should-type",null,"",""," data-index=0")%>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label for="alergia1" class="pointer">Alimento</label>
            <%=fb.checkbox("alergia1","1",prop.getProperty("alergia1").equalsIgnoreCase("1"),viewMode,"should-type",null,"",""," data-index=0")%>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label for="alergia2" class="pointer">Medicamento</label>
            <%=fb.checkbox("alergia2","2",prop.getProperty("alergia2").equalsIgnoreCase("2"),viewMode,"should-type",null,"",""," data-index=0")%>
            &nbsp;&nbsp;&nbsp;&nbsp;(Especifique): 
            <%=fb.textBox("observacion0", prop.getProperty("observacion0"),false,false,viewMode||prop.getProperty("observacion0").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
        </td>
    </tr>

    <tr> 
      <td class="controls form-inline">
        <%if( (propBa!=null && propBa.getProperty("barreras0")!=null && !"".equals(propBa.getProperty("alergia0")) && !"N".equalsIgnoreCase(propBa.getProperty("alergia0"))) ){%>
            <span style="color:red !important">
                <b>Barreras:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </span>
        <%}else{%>
            <b>Barreras:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%}%>
        <button type="button" id="btn_barreras" class="btn btn-inverse btn-sm">
           <i class="fa fa-eye fa-lg"></i> Ver
        </button>
        
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <label for="barreras0" class="pointer">Emocionales</label>
        <%=fb.checkbox("barreras0","0",(prop.getProperty("barreras0").equalsIgnoreCase("0")),viewMode,"","","","")%>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <label for="barreras1" class="pointer">Culturales</label>
        <%=fb.checkbox("barreras1","1",(prop.getProperty("barreras1").equalsIgnoreCase("1")),viewMode,"","","","")%>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <label for="barreras2" class="pointer">Idioma</label>
        <%=fb.checkbox("barreras2","2",(prop.getProperty("barreras2").equalsIgnoreCase("2")),viewMode,"","","","")%>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <label for="barreras3" class="pointer">Otras</label>
        <%=fb.checkbox("barreras3","OT",(prop.getProperty("barreras3").equalsIgnoreCase("OT")),viewMode,"observacion should-type",null,"",""," data-index=1 data-message='Por favor indique las otras Barreras'")%>
        &nbsp;&nbsp;&nbsp;&nbsp;
        (Especifique): 
        <%=fb.textBox("observacion1", prop.getProperty("observacion1"),false,false,viewMode||prop.getProperty("observacion1").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
      </td>
    </tr>
    <%
        Vector vFormularios = CmnMgr.str2vector(cdo1.getColValue("formularios"));
    %>    
    <tr>
        <td class="controls form-inline">
            <% if (!cdo1.getColValue("formularios"," ").trim().equals("") && !CmnMgr.vectorContains(vFormularios,"15")){%>  
            <span style="color:red !important"><b>Paciente Vulnerable:</b></span>
            <%}else{%>
            <b>Paciente Vulnerable:</b>
            <%}%>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <button type="button" id="btn_vulnerabilidad" class="btn btn-inverse btn-sm">
               <i class="fa fa-eye fa-lg"></i> Vulnerabilidad
            </button>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">SI&nbsp;<%=fb.radio("paciente_vulnerable","0",(prop.getProperty("paciente_vulnerable")!=null && prop.getProperty("paciente_vulnerable").equalsIgnoreCase("0")),viewMode,false,"observacion", null,"onClick='shouldTypeRadio(true, 2)'",""," data-index=2 data-message='Por favor indique la Vulnerabilidad'")%></label>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">NO&nbsp;<%=fb.radio("paciente_vulnerable","1",(prop.getProperty("paciente_vulnerable")!=null && prop.getProperty("paciente_vulnerable").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 2)'")%></label>
            
            (Especifique): 
            <%=fb.textBox("observacion2", prop.getProperty("observacion2"),false,false,viewMode||prop.getProperty("observacion2").equals(""),30,"form-control input-sm","display:inline; width:300px",null)%>
        </td>
    </tr>
    
    <tr>
        <td>
            <b>Aislamiento:</b>&nbsp;
            <button type="button" id="btn_aislamiento" class="btn btn-inverse btn-sm">
                <i class="fa fa-eye fa-lg"></i> Aislamientos
            </button>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label for="aislamiento0" class="pointer">Ninguno</label>
            <%=fb.checkbox("aislamiento0","0",(prop.getProperty("aislamiento0").equalsIgnoreCase("0")),viewMode,"","","","")%>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label for="aislamiento1" class="pointer">Contacto</label>
            <%=fb.checkbox("aislamiento1","1",(prop.getProperty("aislamiento1").equalsIgnoreCase("1")),viewMode,"","","","")%>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label for="aislamiento2" class="pointer">Gotas</label>
            <%=fb.checkbox("aislamiento2","2",(prop.getProperty("aislamiento2").equalsIgnoreCase("2")),viewMode,"","","","")%>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label for="aislamiento3" class="pointer">Respiratorio</label>
            <%=fb.checkbox("aislamiento3","3",(prop.getProperty("aislamiento3").equalsIgnoreCase("3")),viewMode,"","","","")%>
        </td>
    </tr>
    <%if (cdo != null && cdo.getColValue("caida") != null && !cdo.getColValue("caida").equals("")) {
        if (Integer.parseInt(cdo.getColValue("caida","0")) > 49) prop.setProperty("riesgo_caida","1");
        else prop.setProperty("riesgo_caida","0");
      }%>
      <%if (cdo != null && cdo.getColValue("ulcera") != null && !cdo.getColValue("ulcera").equals("")) {
        if (Integer.parseInt(cdo.getColValue("ulcera","0")) < 16) prop.setProperty("riesgo_ulcera","1");
        else prop.setProperty("riesgo_ulcera","0");
      }%>
    <tr>
        <td>
            <b>Riesgo de ca&iacute;da:</b>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">Bajo&nbsp;<%=fb.radio("riesgo_caida","0",(prop.getProperty("riesgo_caida")!=null && prop.getProperty("riesgo_caida").equalsIgnoreCase("0")),viewMode,false,"", null,"")%></label>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">Alto&nbsp;<%=fb.radio("riesgo_caida","1",(prop.getProperty("riesgo_caida")!=null && prop.getProperty("riesgo_caida").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            
            <b>Riesgo de &uacute;lcera:</b>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">Bajo&nbsp;<%=fb.radio("riesgo_ulcera","0",(prop.getProperty("riesgo_ulcera")!=null && prop.getProperty("riesgo_ulcera").equalsIgnoreCase("0")),viewMode,false,"", null,"")%></label>
            &nbsp;&nbsp;&nbsp;&nbsp;
            <label class="pointer">Alto&nbsp;<%=fb.radio("riesgo_ulcera","1",(prop.getProperty("riesgo_ulcera")!=null && prop.getProperty("riesgo_ulcera").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label>
        </td>
    </tr>
    
    <tr>
        <td class="bg-headtabla"><b>PLAN DE ENFERMERÍA</b></td>
    </tr>
    
    <tr>
        <td>
            <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                <tr>
                    <td><b>AUTO CUIDADO (Higiene,alimentación, movilidad)</b></td>
                    <td><b>ESTADO DE PIEL</b></td>
                    <td><b>ESPIRITUAL / CREENCIAS / CULTURA</b></td>
                    <td><b>EDUCACIÓN / APRENDIZAJE</b></td>
                </tr>
                <tr>
                    <td style="vertical-align:top !important">
                        <%=fb.checkbox("auto_cuidado0","0",(prop.getProperty("auto_cuidado0").equalsIgnoreCase("0")),viewMode,"","","","")%>
                        <label for="auto_cuidado0" class="pointer">No requiere ayuda</label>
                        <br>
                        <%=fb.checkbox("auto_cuidado1","1",(prop.getProperty("auto_cuidado1").equalsIgnoreCase("1")),viewMode,"","","","")%>
                        <label for="auto_cuidado1" class="pointer">Ayuda Parcial</label>
                        <br>
                        <%=fb.checkbox("auto_cuidado2","2",(prop.getProperty("auto_cuidado2").equalsIgnoreCase("2")),viewMode,"","","","")%>
                        <label for="auto_cuidado2" class="pointer">Ayuda Total</label>
                        <br>
                        <%=fb.checkbox("auto_cuidado3","3",(prop.getProperty("auto_cuidado3").equalsIgnoreCase("3")),viewMode,"observacion should-type",null,"",""," data-index=3 data-message='Por favor indique los otros auto cuidados'")%>
                        <label for="auto_cuidado3" class="pointer">Otros:</label>
                        <%=fb.textBox("observacion3", prop.getProperty("observacion3"),false,false,viewMode||prop.getProperty("observacion3").equals(""),30,"form-control input-sm","display:inline; width:150px",null)%>
                    </td>
                    <td style="vertical-align:top !important">
                      <%=fb.checkbox("estado_piel0","0",(prop.getProperty("estado_piel0").equalsIgnoreCase("0")),viewMode,"","","","")%>
                      <label for="estado_piel0" class="pointer">Evaluaci&oacute;n diaria</label>
                      <br> 
                      <%=fb.checkbox("estado_piel1","1",(prop.getProperty("estado_piel1").equalsIgnoreCase("1")),viewMode,"","","","")%>
                      <label for="estado_piel1" class="pointer">Valoración de puntos de presión y uso de dispositivos</label>
                      <br>  
                      <%=fb.checkbox("estado_piel2","2",(prop.getProperty("estado_piel2").equalsIgnoreCase("2")),viewMode,"","","","")%>
                      <label for="estado_piel2" class="pointer">Control de humedad</label>
                      <br>  
                      <%=fb.checkbox("estado_piel3","3",(prop.getProperty("estado_piel3").equalsIgnoreCase("3")),viewMode,"observacion should-type",null,"",""," data-index=4 data-message='Por favor indique la frecuencia de cambio de posición'")%>
                      <label for="estado_piel3" class="pointer">Cambio de Posición cada:</label>
                      <%=fb.textBox("observacion4", prop.getProperty("observacion4"),false,false,viewMode||prop.getProperty("observacion4").equals(""),30,"form-control input-sm","display:inline; width:80px",null)%>
                      <br>
                        <%=fb.checkbox("estado_piel4","4",(prop.getProperty("estado_piel4").equalsIgnoreCase("4")),viewMode,"observacion should-type",null,"",""," data-index=5 data-message='Por favor indique los otros estados de piel'")%>
                        <label for="estado_piel4" class="pointer">Otros:</label>
                        <%=fb.textBox("observacion5", prop.getProperty("observacion5"),false,false,viewMode||prop.getProperty("observacion5").equals(""),30,"form-control input-sm","display:inline; width:150px",null)%>  
                    </td>
                    <td style="vertical-align:top !important">
                        <%=fb.checkbox("espiritual0","0",(prop.getProperty("espiritual0").equalsIgnoreCase("0")),viewMode,"","","","")%>
                        <label for="espiritual0" class="pointer">Ayuda espiritual(pastor, sacerdote)</label>
                        <br>
                        <%=fb.checkbox("espiritual1","1",(prop.getProperty("espiritual1").equalsIgnoreCase("1")),viewMode,"","","","")%>
                        <label for="espiritual1" class="pointer">Servicio religioso</label>
                        <br>
                        <%=fb.checkbox("espiritual2","2",(prop.getProperty("espiritual2").equalsIgnoreCase("2")),viewMode,"observacion should-type",null,"",""," data-index=6 data-message='Por favor indique los otros servicios religiosos'")%>
                        <label for="espiritual2" class="pointer">Otros:</label>
                        <%=fb.textBox("observacion6", prop.getProperty("observacion6"),false,false,viewMode||prop.getProperty("observacion6").equals(""),30,"form-control input-sm","display:inline; width:150px",null)%> 
                    </td>
                    <td style="vertical-align:top !important">
                        <%=fb.checkbox("aprendizaje0","0",(prop.getProperty("aprendizaje0").equalsIgnoreCase("0")),viewMode,"","","","")%>
                        <label for="aprendizaje0" class="pointer">Prevenci&oacute;n de ca&iacute;das</label>
                        <br>
                        <%=fb.checkbox("aprendizaje1","1",(prop.getProperty("aprendizaje1").equalsIgnoreCase("1")),viewMode,"","","","")%>
                        <label for="aprendizaje1" class="pointer">Tips de seguridad</label>
                        <br>
                        <%=fb.checkbox("aprendizaje2","2",(prop.getProperty("aprendizaje2").equalsIgnoreCase("2")),viewMode,"","","","")%>
                        <label for="aprendizaje2" class="pointer">Manejo del dolor</label>
                        <br>
                        <%=fb.checkbox("aprendizaje3","3",(prop.getProperty("aprendizaje3").equalsIgnoreCase("3")),viewMode,"","","","")%>
                        <label for="aprendizaje3" class="pointer">Medidas de Aislamiento</label>
                        <br>
                        <%=fb.checkbox("aprendizaje4","4",(prop.getProperty("aprendizaje4").equalsIgnoreCase("4")),viewMode,"observacion should-type",null,"",""," data-index=7 data-message='Por favor indique los otros métodos de aprendizaje'")%>
                        <label for="aprendizaje4" class="pointer">Otros:</label>
                        <%=fb.textBox("observacion7", prop.getProperty("observacion7"),false,false,viewMode||prop.getProperty("observacion7").equals(""),30,"form-control input-sm","display:inline; width:150px",null)%> 
                    </td>
                </tr>
                
                <tr>
                    <td><b>CUIDADOS DE ENFERMERÍA</b></td>
                    <td><b>SOCIAL / ECONOMICA</b></td>
                    <td><b>EVALUACIÓN POR:</b></td>
                    <td><b>PLANIFICACIÓN TEMPRANA DEL EGRESO</b></td>
                </tr>
                
                <tr>
                <td style="vertical-align:top !important">
                    <%=fb.checkbox("cuidados_enf_0","0",(prop.getProperty("cuidados_enf_0").equalsIgnoreCase("0")),viewMode,"","","","")%>
                    <label for="cuidados_enf_0" class="pointer">Gastrostom&iacute;a</label>
                    <br>
                    <%=fb.checkbox("cuidados_enf_1","1",(prop.getProperty("cuidados_enf_1").equalsIgnoreCase("1")),viewMode,"","","","")%>
                    <label for="cuidados_enf_1" class="pointer">Traqueotom&iacute;a</label>
                    <br>
                    <%=fb.checkbox("cuidados_enf_2","2",(prop.getProperty("cuidados_enf_2").equalsIgnoreCase("2")),viewMode,"","","","")%>
                    <label for="cuidados_enf_2" class="pointer">Ileostom&iacute;a</label>
                    <br>
                    <%=fb.checkbox("cuidados_enf_3","3",(prop.getProperty("cuidados_enf_3").equalsIgnoreCase("3")),viewMode,"","","","")%>
                    <label for="cuidados_enf_3" class="pointer">Cat&eacute;ter Venoso Central</label>
                    <br>
                    <%=fb.checkbox("cuidados_enf_4","4",(prop.getProperty("cuidados_enf_4").equalsIgnoreCase("4")),viewMode,"observacion should-type",null,"",""," data-index=8 data-message='Por favor indique los otros cuidados de emfermería'")%>
                    <label for="cuidados_enf_4" class="pointer">Otros:</label>
                    <%=fb.textBox("observacion8", prop.getProperty("observacion8"),false,false,viewMode||prop.getProperty("observacion8").equals(""),30,"form-control input-sm","display:inline; width:150px",null)%>
                </td>
               
                <td style="vertical-align:top !important">
                    <%=fb.checkbox("social_econo_0","0",(prop.getProperty("social_econo_0").equalsIgnoreCase("0")),viewMode,"","","","")%>
                    <label for="social_econo_0" class="pointer">Evaluaci&oacute;n por Personal de Atenci&oacute;n al Cliente</label>
                    <br>
                    <%=fb.checkbox("social_econo_1","1",(prop.getProperty("social_econo_1").equalsIgnoreCase("1")),viewMode,"observacion should-type",null,"",""," data-index=9 data-message='Por favor indique los otros sociales / económicos'")%>
                    <label for="social_econo_1" class="pointer">Otros:</label>
                    <%=fb.textBox("observacion9", prop.getProperty("observacion9"),false,false,viewMode||prop.getProperty("observacion9").equals(""),30,"form-control input-sm","display:inline; width:150px",null)%>
                </td>
                
                <td style="vertical-align:top !important">
                    <%=fb.checkbox("evaluado_por_0","0",(prop.getProperty("evaluado_por_0").equalsIgnoreCase("0")),viewMode,"","","","")%>
                    <label for="evaluado_por_0" class="pointer">Nutricionista</label>
                    <br>
                    <%=fb.checkbox("evaluado_por_1","1",(prop.getProperty("evaluado_por_1").equalsIgnoreCase("1")),viewMode,"","","","")%>
                    <label for="evaluado_por_1" class="pointer">Nosocomial</label>
                    <br>
                    <%=fb.checkbox("evaluado_por_2","2",(prop.getProperty("evaluado_por_2").equalsIgnoreCase("2")),viewMode,"","","","")%>
                    <label for="evaluado_por_2" class="pointer">M&eacute;dico Hospitalista</label>
                    <br>
                    <%=fb.checkbox("evaluado_por_3","3",(prop.getProperty("evaluado_por_3").equalsIgnoreCase("3")),viewMode,"","","","")%>
                    <label for="evaluado_por_3" class="pointer">T. respiratoria</label>
                    <br>
                    <%=fb.checkbox("evaluado_por_4","4",(prop.getProperty("evaluado_por_4").equalsIgnoreCase("4")),viewMode,"observacion should-type",null,"",""," data-index=10 data-message='Por favor indique los otros evaluadores!'")%>
                    <label for="evaluado_por_4" class="pointer">Otros:</label>
                    <%=fb.textBox("observacion10", prop.getProperty("observacion10"),false,false,viewMode||prop.getProperty("observacion10").equals(""),30,"form-control input-sm","display:inline; width:150px",null)%>
                </td>

                <td style="vertical-align:top !important">
                    <%=fb.checkbox("planificacion_0","0",(prop.getProperty("planificacion_0").equalsIgnoreCase("0")),viewMode,"","","","")%>
                    <label for="planificacion_0" class="pointer">Educaci&oacute;n</label>
                    <br>
                    <%=fb.checkbox("planificacion_1","1",(prop.getProperty("planificacion_1").equalsIgnoreCase("1")),viewMode,"","","","")%>
                    <label for="planificacion_1" class="pointer">Transporte</label>
                    <br>
                    <%=fb.checkbox("planificacion_2","2",(prop.getProperty("planificacion_2").equalsIgnoreCase("2")),viewMode,"","","","")%>
                    <label for="planificacion_2" class="pointer">M&eacute;dico Hospitalista</label>
                    <br>
                    <%=fb.checkbox("planificacion_3","3",(prop.getProperty("planificacion_3").equalsIgnoreCase("3")),viewMode,"","","","")%>
                    <label for="planificacion_3" class="pointer">Personas de apoyo en casa</label>
                    <br>
                    <%=fb.checkbox("planificacion_4","4",(prop.getProperty("planificacion_4").equalsIgnoreCase("4")),viewMode,"observacion should-type",null,"",""," data-index=11 data-message='Por favor indique las otras planificaciones tempranas del egreso!'")%>
                    <label for="planificacion_4" class="pointer">Otros:</label>
                    <%=fb.textBox("observacion11", prop.getProperty("observacion11"),false,false,viewMode||prop.getProperty("observacion11").equals(""),30,"form-control input-sm","display:inline; width:150px",null)%>
                </td>
                </tr>
            </table>
        </td>
    </tr>
    
     <tr>
        <td class="bg-headtabla" colspan="4"><b>PLAN M&Eacute;DICO</b></td>
     </tr>
     
     <tr>
         <td>
            <table cellspacing="0" class="table table-small-font table-bordered table-striped">
                <tr>
                    <td><b>DIETA</b></td>
                    <td><b>INHALOTERAPIA</b></td>
                    <td><b>CATETER</b>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <label class="pointer">SI&nbsp;<%=fb.radio("cateter","0",(prop.getProperty("cateter")!=null && prop.getProperty("cateter").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
                        &nbsp;&nbsp;
                        <label class="pointer">NO&nbsp;<%=fb.radio("cateter","1",(prop.getProperty("cateter")!=null && prop.getProperty("cateter").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label>
                    
                    </td>
                </tr>
                <tr>
                    <td style="vertical-align:top !important">
                        <button type="button" id="btn_nutricion" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> Nutrici&oacute;n
                        </button>
                        <button type="button" id="btn_nutricion_pa" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> Nutrici&oacute;n PA
                        </button>
                        <button type="button" id="btn_nutricion_np" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> Nutrici&oacute;n NP
                        </button>
                        <br>
                        
                        <%=fb.checkbox("dietas_0","0",(prop.getProperty("dietas_0").equalsIgnoreCase("0")),viewMode,"","","","")%>
                        <label for="dietas_0" class="pointer">NADA POR BOCA</label>
                        <br>
                        <%=fb.checkbox("dietas_1","1",(prop.getProperty("dietas_1").equalsIgnoreCase("1")),viewMode,"","","","")%>
                        <label for="dietas_1" class="pointer">CORRIENTE</label>
                        <br>
                        <%=fb.checkbox("dietas_2","2",(prop.getProperty("dietas_2").equalsIgnoreCase("2")),viewMode,"","","","")%>
                        <label for="dietas_2" class="pointer">BLANDA</label>
                        <br>
                        <%=fb.checkbox("dietas_3","3",(prop.getProperty("dietas_3").equalsIgnoreCase("3")),viewMode,"","","","")%>
                        <label for="dietas_3" class="pointer">L&Iacute;QUIDA</label>
                        <br>
                        <%=fb.checkbox("dietas_4","4",(prop.getProperty("dietas_4").equalsIgnoreCase("4")),viewMode,"","","","")%>
                        <label for="dietas_4" class="pointer">KOSHER</label>
                        <br>
                        <%=fb.checkbox("dietas_5","5",(prop.getProperty("dietas_5").equalsIgnoreCase("5")),viewMode,"","","","")%>
                        <label for="dietas_5" class="pointer">PARA DIAB&Eacute;TICO</label>
                        <br>
                        <%=fb.checkbox("dietas_6","6",(prop.getProperty("dietas_6").equalsIgnoreCase("6")),viewMode,"","","","")%>
                        <label for="dietas_6" class="pointer">NUTRICION PARENTERAL</label>
                        <br>
                    </td>
                    <td style="vertical-align:top !important">
                        <button type="button" id="btn_inhaloterapia" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> O/M Inhaloterapia
                        </button>
                        <br>
                        <br>
                        <label class="pointer">SI&nbsp;<%=fb.radio("inhaloterapia","0",(prop.getProperty("inhaloterapia")!=null && prop.getProperty("inhaloterapia").equalsIgnoreCase("0")),viewMode,false,"observacion", null,"onClick='shouldTypeRadio(true, 12)'",""," data-index=12 data-message='Por favor indique la frecuencia de inhaloterapia'")%></label>
                        &nbsp;&nbsp;
                        <label class="pointer">NO&nbsp;<%=fb.radio("inhaloterapia","1",(prop.getProperty("inhaloterapia")!=null && prop.getProperty("inhaloterapia").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 12)'")%></label>
                        &nbsp;&nbsp;
                        Cada: 
                        <%=fb.textBox("observacion12", prop.getProperty("observacion12"),false,false,viewMode||prop.getProperty("observacion12").equals(""),30,"form-control input-sm","display:inline; width:100px",null)%>
                    </td>
                    <td style="vertical-align:top !important">
                        <button type="button" id="btn_notas_enf_diarias" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> Notas Diarias
                        </button>
                        <br>
                        <%=fb.checkbox("cateter_0","0",(prop.getProperty("cateter_0").equalsIgnoreCase("0")),viewMode,"","","","")%>
                        <label for="cateter_0" class="pointer">SELLO VENOSO</label>
                        <br>
                        <%=fb.checkbox("cateter_1","1",(prop.getProperty("cateter_1").equalsIgnoreCase("1")),viewMode,"","","","")%>
                        <label for="cateter_1" class="pointer"> CATETER VENOSO CENTRAL CVC</label>
                        <br>
                        <%=fb.checkbox("cateter_2","2",(prop.getProperty("cateter_2").equalsIgnoreCase("2")),viewMode,"","","","")%>
                        <label for="cateter_2" class="pointer">EPIDURAL</label>
                        <br>
                        <%=fb.checkbox("cateter_3","3",(prop.getProperty("cateter_3").equalsIgnoreCase("3")),viewMode,"observacion should-type",null,"",""," data-index=13 data-message='Por favor indique VENOCLISIS!'")%>
                        <label for="cateter_3" class="pointer">VENOCLISIS (Especifique):</label>
                        <%=fb.textBox("observacion13", prop.getProperty("observacion13"),false,false,viewMode||prop.getProperty("observacion13").equals(""),30,"form-control input-sm","display:inline; width:150px",null)%>
                    </td>
                </tr>
                <%
                  if (!prop.getProperty("dolor").equals("0") && !prop.getProperty("dolor").equals("1")){
                    if (cdo != null && !cdo.getColValue("dolor"," ").trim().equals("") && Integer.parseInt(cdo.getColValue("dolor","0")) > 0 ) prop.setProperty("dolor","0");
                    else prop.setProperty("dolor","1");
                  }
                  if (!prop.getProperty("glasgow").equals("0") && !prop.getProperty("glasgow").equals("1")){
                    if (cdo != null && !cdo.getColValue("glasgow"," ").trim().equals("") && Integer.parseInt(cdo.getColValue("glasgow","0")) > 0 ) prop.setProperty("glasgow","0");
                    else prop.setProperty("glasgow","1");
                  }
                %>
                <tr>
                    <td style="vertical-align:top !important">
                        <b>SIGNOS VITALES&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Cada</b>
                        <%=fb.textBox("observacion14", prop.getProperty("observacion14"),false,false,viewMode,30,"form-control input-sm","display:inline; width:100px",null)%>
                        <br>
                        <br>
                        <b>DOLOR</b>:&nbsp;
                        <label class="pointer">SI&nbsp;<%=fb.radio("dolor","0",(prop.getProperty("dolor")!=null && prop.getProperty("dolor").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
                        &nbsp;&nbsp;
                        <label class="pointer">NO&nbsp;<%=fb.radio("dolor","1",(prop.getProperty("dolor")!=null && prop.getProperty("dolor").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label>
                        <br>
                        <b>GLASGOW</b>:&nbsp;
                        <label class="pointer">SI&nbsp;<%=fb.radio("glasgow","0",(prop.getProperty("glasgow")!=null && prop.getProperty("glasgow").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
                        &nbsp;&nbsp;
                        <label class="pointer">NO&nbsp;<%=fb.radio("glasgow","1",(prop.getProperty("glasgow")!=null && prop.getProperty("glasgow").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label>
                    </td>
                    <td style="vertical-align:top !important">
                        <b>CURACIONES</b>
                        <br>
                        &nbsp;
                        <label class="pointer">SI&nbsp;<%=fb.radio("curaciones","0",(prop.getProperty("curaciones")!=null && prop.getProperty("curaciones").equalsIgnoreCase("0")),viewMode,false,"observacion", null,"onClick='shouldTypeRadio(true, 15)'",""," data-index=15 data-message='Por favor indique la frecuencia de las Curaciones'")%></label>
                        &nbsp;&nbsp;
                        <label class="pointer">NO&nbsp;<%=fb.radio("curaciones","1",(prop.getProperty("curaciones")!=null && prop.getProperty("curaciones").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 15)'")%></label>
                        &nbsp;&nbsp;&nbsp;&nbsp;Cada:&nbsp;&nbsp;
                        <%=fb.textBox("observacion15", prop.getProperty("observacion15"),false,false,viewMode||prop.getProperty("observacion15").equals(""),30,"form-control input-sm","display:inline; width:100px",null)%>
                    </td>
                    <td style="vertical-align:top !important">
                        <b>GLICEMIA</b>
                        &nbsp;&nbsp;&nbsp;
                        <button type="button" id="btn_insulinas" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> OM/Insulina
                        </button>
                        &nbsp;&nbsp;&nbsp;
                        <br>
                        &nbsp;
                        <label class="pointer">SI&nbsp;<%=fb.radio("glicemia","0",(prop.getProperty("glicemia")!=null && prop.getProperty("glicemia").equalsIgnoreCase("0")),viewMode,false,"observacion", null,"onClick='shouldTypeRadio(true, 16)'",""," data-index=16 data-message='Por favor indique la frecuencia de insulina'")%></label>
                        &nbsp;&nbsp;
                        <label class="pointer">NO&nbsp;<%=fb.radio("glicemia","1",(prop.getProperty("glicemia")!=null && prop.getProperty("glicemia").equalsIgnoreCase("1")),viewMode,false,"", null,"onClick='shouldTypeRadio(false, 16)'")%></label>
                        &nbsp;&nbsp;&nbsp;&nbsp;Cada:&nbsp;&nbsp;
                        <%=fb.textBox("observacion16", prop.getProperty("observacion16"),false,false,viewMode||prop.getProperty("observacion16").equals(""),30,"form-control input-sm","display:inline; width:100px",null)%>
                    </td>
                </tr>
                
                <tr>
                    <td style="vertical-align:top !important">
                        <b>BALANCE HIDRICO</b>
                        &nbsp;&nbsp;&nbsp;
                        <button type="button" id="btn_balance_hidrico" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> Ver
                        </button>
                        &nbsp;&nbsp;&nbsp;
                        <br>
                        &nbsp;
                        <label class="pointer">SI&nbsp;<%=fb.radio("balance_hidrico","0",(prop.getProperty("balance_hidrico")!=null && prop.getProperty("balance_hidrico").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
                        &nbsp;&nbsp;
                        <label class="pointer">NO&nbsp;<%=fb.radio("balance_hidrico","1",(prop.getProperty("balance_hidrico")!=null && prop.getProperty("balance_hidrico").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label>
                    </td>
                    <td style="vertical-align:top !important" colspan="2">
                        <b>TRATAMIENTOS</b>
                        &nbsp;&nbsp;&nbsp;
                        <button type="button" id="btn_tratamientos" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> Ver
                        </button>
                        &nbsp;&nbsp;&nbsp;
                        <br>
                        &nbsp;
                        <label class="pointer">SI&nbsp;<%=fb.radio("tratamientos","0",(prop.getProperty("tratamientos")!=null && prop.getProperty("tratamientos").equalsIgnoreCase("0")),viewMode,false,"", null,"","","")%></label>
                        &nbsp;&nbsp;
                        <label class="pointer">NO&nbsp;<%=fb.radio("tratamientos","1",(prop.getProperty("tratamientos")!=null && prop.getProperty("tratamientos").equalsIgnoreCase("1")),viewMode,false,"", null,"")%></label>
                    </td>
                </tr>
                
                <tr>
                    <td style="vertical-align:top !important">
                        <b>INDICACIONES GENERALES</b>
                        &nbsp;&nbsp;&nbsp;
                        <button type="button" id="btn_om_varias" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> O/M Varias
                        </button>
                        &nbsp;&nbsp;&nbsp;
                        <br>

                        <%=fb.checkbox("om_varias_0","0",(prop.getProperty("om_varias_0").equalsIgnoreCase("0")),viewMode,"observacion should-type",null,"",""," data-index=17 data-message='Por favor indique las otras &oacute;rdenes varias!'")%>
                        <label for="om_varias_0" class="pointer">Otras:</label>
                        <%=fb.textBox("observacion17", prop.getProperty("observacion17"),false,false,viewMode||prop.getProperty("observacion17").equals(""),30,"form-control input-sm","display:inline; width:200px",null)%>
                        
                    </td>
                    <td style="vertical-align:top !important">
                        
                        <button type="button" id="btn_lab" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> LABORATORIOS
                        </button>
                        <br>
                        
                        <b>EXÁMEN Y/O PRUEBAS</b>
                        &nbsp;&nbsp;&nbsp;
                        <button type="button" id="btn_om_imagenologia" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> O/M Imagenolog&iacute;a
                        </button>
                    </td>
                    <td style="vertical-align:top !important">
                        <b>INTERCONSULTA:</b>
                        &nbsp;&nbsp;&nbsp;
                        <button type="button" id="btn_om_interconsulta" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> O/M Interconsulta
                        </button>
                    </td>
                </tr>
                
                <tr>
                    <td>
                        <button type="button" id="btn_sondas" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> PROCEDIMIENTOS INVASIVOS
                        </button>
                    </td>
                    <td>
                        <button type="button" id="btn_med_trat_dosis" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> MEDICAMENTOS /TRATAMIENTOS DOSIS
                        </button>
                    </td>
                    <td>
                        <button type="button" id="btn_proc_cir" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> PROCEDIMIENTOS/CIRUGÍAS
                        </button>
                    </td>
                </tr>
                
                <tr>
                    <td>
                        <button type="button" id="btn_val_criticos" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> VALORES CRITICOS
                        </button>
                    </td>
                    <td>
                       <button type="button" id="btn_lab_ejec" class="btn btn-inverse btn-sm">
                           <i class="fa fa-eye fa-lg"></i> Laboratorios/Imagenolog&iacute;a Ejec.
                        </button> 
                    </td>
                    <td> 
                    </td>
                </tr>
                
            </table>
         </td>
     </tr>
     
     
     
    
</table>
<div class="footerform">
    <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
    <tr>
       <td>
            Opciones de Guardar:
            <label><%=fb.radio("saveOption","O",true,viewMode,false,null,null,null)%> Mantener Abierto</label>
            <label><%=fb.radio("saveOption","C",false,viewMode,false,null,null,null)%> Cerrar</label>
            <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
            <%=fb.button("cancel","Cancelar",false,false,null,null,"onclick=\"parent.doRedirect(0)\"")%>
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
} else {
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
    
    prop = new Properties();

	prop.setProperty("pac_id",request.getParameter("pacId"));
	prop.setProperty("admision",request.getParameter("noAdmision"));
	prop.setProperty("codigo",request.getParameter("code"));
    prop.setProperty("usuario_creacion", UserDet.getUserName());
    prop.setProperty("fecha_creacion", cDateTime);
    prop.setProperty("usuario_modificacion", UserDet.getUserName());
    prop.setProperty("fecha_modificacion", cDateTime);
    
    prop.setProperty("diag_actual", request.getParameter("diag_actual"));
    prop.setProperty("fecha_traslado", request.getParameter("fecha_traslado"));
    prop.setProperty("paciente_vulnerable", request.getParameter("paciente_vulnerable"));
    prop.setProperty("riesgo_caida", request.getParameter("riesgo_caida"));
    prop.setProperty("riesgo_ulcera", request.getParameter("riesgo_ulcera"));
    prop.setProperty("inhaloterapia", request.getParameter("inhaloterapia"));
    prop.setProperty("cateter", request.getParameter("cateter"));
    prop.setProperty("dolor", request.getParameter("dolor"));
    prop.setProperty("glasgow", request.getParameter("glasgow"));
    prop.setProperty("curaciones", request.getParameter("curaciones"));
    prop.setProperty("glicemia", request.getParameter("glicemia"));
    prop.setProperty("balance_hidrico", request.getParameter("balance_hidrico"));
    prop.setProperty("tratamientos", request.getParameter("tratamientos"));
    prop.setProperty("nota_diaria", request.getParameter("nota_diaria"));
    
    for (int i = 0; i < 30; i++) {
    System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> "+request.getParameter("alergia"+i));
        if(request.getParameter("alergia"+i)!=null) prop.setProperty("alergia"+i, request.getParameter("alergia"+i));
        if(request.getParameter("barreras"+i)!=null) prop.setProperty("barreras"+i, request.getParameter("barreras"+i));
        if(request.getParameter("aislamiento"+i)!=null) prop.setProperty("aislamiento"+i, request.getParameter("aislamiento"+i));
        if(request.getParameter("auto_cuidado"+i)!=null) prop.setProperty("auto_cuidado"+i, request.getParameter("auto_cuidado"+i));
        if(request.getParameter("estado_piel"+i)!=null) prop.setProperty("estado_piel"+i, request.getParameter("estado_piel"+i));
        if(request.getParameter("espiritual"+i)!=null) prop.setProperty("espiritual"+i, request.getParameter("espiritual"+i));
        if(request.getParameter("aprendizaje"+i)!=null) prop.setProperty("aprendizaje"+i, request.getParameter("aprendizaje"+i));
        if(request.getParameter("dietas_"+i)!=null) prop.setProperty("dietas_"+i, request.getParameter("dietas_"+i));
        if(request.getParameter("cateter_"+i)!=null) prop.setProperty("cateter_"+i, request.getParameter("cateter_"+i));
        if(request.getParameter("om_varias_"+i)!=null) prop.setProperty("om_varias_"+i, request.getParameter("om_varias_"+i)); 
        if(request.getParameter("cuidados_enf_"+i)!=null) prop.setProperty("cuidados_enf_"+i, request.getParameter("cuidados_enf_"+i)); 
        if(request.getParameter("social_econo_"+i)!=null) prop.setProperty("social_econo_"+i, request.getParameter("social_econo_"+i)); 
        if(request.getParameter("evaluado_por_"+i)!=null) prop.setProperty("evaluado_por_"+i, request.getParameter("evaluado_por_"+i)); 
        if(request.getParameter("planificacion_"+i)!=null) prop.setProperty("planificacion_"+i, request.getParameter("planificacion_"+i)); 
        if(request.getParameter("dietas_"+i)!=null) prop.setProperty("dietas_"+i, request.getParameter("dietas_"+i)); 

        if(request.getParameter("observacion"+i)!=null) prop.setProperty("observacion"+i, request.getParameter("observacion"+i));
    }
    
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
    {
        PAKMgr.add(prop);
        code = PAKMgr.getPkColValue("codigo");
    }
    else PAKMgr.update(prop);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (PAKMgr.getErrCode().equals("1")) { %>
	alert('<%=PAKMgr.getErrMsg()%>');
<%
	if (saveOption.equalsIgnoreCase("N")) {
%>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(PAKMgr.getErrMsg());
%>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=view&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>';}
</script>
</head>
<body onLoad="closeWindow()"></body>
</html>
<% } %>
