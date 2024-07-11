<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="com.google.gson.Gson"%>
<%@ page import="com.google.gson.JsonObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al2 = new ArrayList();
String key = "";
String sql = "";
String compania = ((String) session.getAttribute("_companyId"));
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
boolean viewMode = false;

String change = request.getParameter("change");
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String idOsetH1 = request.getParameter("id_oset_h1");
String idOsetH2 = request.getParameter("id_oset_h2");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

if (idOsetH1 == null) idOsetH1 = "0";
if (idOsetH2 == null) idOsetH2 = "0";
if (tab == null) tab = "0";
if (pacId == null) pacId = "0";
if (noAdmision == null) noAdmision = "0";
if (mode == null) mode = "add";

ArrayList alDosis = new ArrayList();
ArrayList alViaAd = new ArrayList();
ArrayList alLIS = new ArrayList();
ArrayList alRIS = new ArrayList();
ArrayList alMotivo = new ArrayList();

if (request.getMethod().equalsIgnoreCase("GET")) {
		
	CommonDataObject cdoHd1 = SQLMgr.getData("select h.oset_desc, estatus, (select count(*) from TBL_EXP_OSET_ACTIVOXMRN where pac_id = "+pacId+" and admision = "+noAdmision+" and oset_id = h.id_oset) as activo from TBL_OSET_HEADER1 h where h.ID_OSET = "+idOsetH1);
	if (cdoHd1 == null) cdoHd1 = new CommonDataObject();
    
	al2 = SQLMgr.getDataList("select  nvl(a.display_text,  a.ref_name) display_text, a.ref_code, a.frecuencia, a.dosis, nvl(a.add_info_text,' ') add_info_text, (select descripcion from TBL_OSET_TIPO_OM_CONFIG where id = om_type) tipo_om, (select subtipo from TBL_OSET_TIPO_OM_CONFIG where id = a.om_type) subtipo, nvl(can_change,'Y') can_change,b.id_oset_h2, nvl(b.display_text, b.desc_header2) desc_header2, b.extra_info, b.tipo, a.prioridad, a.concentracion, a.forma, a.cantidad, a.via, a.generar_om, a.oset_det_id, a.observacion, a.centro_servicio, a.om_type, a.medico_interconsulta, to_char(a.fecha_interconsulta,'dd/mm/yyyy') fecha_interconsulta, nvl(a.especialidad_interconsulta, a.ref_code) especialidad_interconsulta, a.med_int_name, nvl(a.espe_med_int,a.ref_name) espe_med_int, motivo from TBL_OSET_ORDEN_MEDICAS a,(select * from TBL_OSET_HEADER2 where id_oset="+idOsetH1+")b where a.pac_id(+) = "+pacId+" and a.admision(+) = "+noAdmision+" and a.oset_header1(+) = "+idOsetH1+" and a.oset_header1(+) = b.id_oset and a.oset_header2(+) = b.id_oset_h2 order by b.oder_no, a.disp_order");
  
	alDosis = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_grupo_dosis order by descripcion",CommonDataObject.class);
	
	alViaAd = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_via_admin where tipo_liquido='M' order by descripcion",CommonDataObject.class);
	
	alLIS = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cds_centro_servicio where reporta_a in(select codigo from tbl_cds_centro_servicio where interfaz = 'LIS') and compania_unorg = "+compania, CommonDataObject.class);
	alRIS = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cds_centro_servicio where reporta_a in(select codigo from tbl_cds_centro_servicio where interfaz = 'RIS') and compania_unorg = "+compania, CommonDataObject.class);
	
	alMotivo = sbb.getBeanList(ConMgr.getConnection(),"select z.codigo optValueColumn, z.descrip_motivo||'='||z.activa_observ optLabelColumn, z.codigo as optTitleColumn from tbl_sal_motivo_sol_proc z, tbl_cds_motivos_x_proc y where z.codigo = y.cod_motivo and y.cod_procedimiento IN (SELECT REF_code FROM TBL_OSET_ORDEN_MEDICAS where pac_id = "+pacId+" and admision = "+noAdmision+" and oset_header1 = "+idOsetH1+" ) and z.estado_motivo = 'A' and y.estado = 'A'", CommonDataObject.class);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<link rel="stylesheet" href="../css/Font-Awesome-4.7.0/css/font-awesome.min.css" type="text/css"/>
<script>
document.title = 'Vista previa de OrderSet - '+document.title;
function doAction(){}

$(function() {
  $("#btn-print").click(function(){
    abrir_ventana1('../orderset/print_orderset.jsp?id_oset=<%=idOsetH1%>');
  });
  
  $(".can_change").click(function(){
      var self = $(this);
      var i = self.data('d');
      var canChange = self.data('canchange');
      if (canChange !== 'Y') {
        this.checked = true;
        return false;
      }
  });
  
  $(".toggle-extra").click(function(){
      var self = $(this);
      var i = self.data('d');
      var $extradet = $("#extra-data-"+i);
      $extradet.toggle();
  });
  
  //
  
  $(".upd-data").click(function(e) {
    var $self = $(this);
    var medico =parent.document.form0.med_code.value;
    var peso=parent.document.form0.pac_peso.value;
    //var sexo=parent.document.form0.pac_sexo.value;
    document.form0.medico.value=medico;
    document.form0.peso.value=peso;
    //document.form0.sexo.value=sexo;
    if(medico==null || medico==''){ alert('Por Favor indicar medico!'); return false;}
    if(peso==null || peso==''){ alert('Por Favor indicar peso!'); return false;}
    //if(sexo==null || sexo==''){ alert('Por Favor indicar peso!'); return false;}
    
    var totError = 0;
    
    $(".can_change:checked").not(":disabled").each(function(i, cb) {
      var d = cb.dataset['d'];
      var subTipo = cb.dataset['subtipo'];
      if (['MED', 'LIS', 'RIS', 'INT', 'BDS'].includes(subTipo)) {
        $(".extra-field-"+d).each(function(i, el) {
          if ((el.type == 'radio' && !$("#"+el.name+":checked").length) || ((el.type == 'text' || el.type == 'select-one') && !el.value.trim()) ) totError++;
          console.log(el.name,  $("#"+el.name+":checked").length)
        })
      }
    })

    if (totError > 0) {
        alert("Por favor llenar los datos extra para continuar");
        return
    }
    
    if ( $(".can_change:checked").not(":disabled").length ) {
      $self.prop("disabled", true).html("Aprobando...");
      
      $.ajax({
        url: '<%=request.getContextPath()+request.getServletPath()%>',
        method: 'POST',
        data: $("#form0").serialize()
      }).done(function(data) {
        $self.prop("disabled", false).html("Aprobar");
        alert(data.msg);
        window.location.reload(true)
      }).fail(function(error){
        if (error.responseJSON.msg) alert(error.responseJSON.msg)
        console.log("Error -> ",  error)
        $self.prop("disabled", false).html("Aprobar");
      });
    }
  });
  
  // medico interconsulta
  
  $(".btn_search_med").click(function() {
      var self = $(this);
      var i = self.data('i');
      
	  abrir_ventana1('../common/search_medico.jsp?fp=exp_interconsultor&fg=orderset&index='+i)
    });
 
});
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<style>
.label-success {
    background-color: 
    #5cb85c;
}
.label {
    display: inline;
    padding: .2em .6em .3em;
    font-size: 75%;
    font-weight: 700;
    line-height: 1;
    color: #fff;
    text-align: center;
    white-space: nowrap;
    vertical-align: baseline;
    border-radius: .25em;
}
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="1">    
    <tr class="TextPanel02">
      <td>
        <span style="font-size: 15px">
        &nbsp;&nbsp;
          <%=cdoHd1.getColValue("oset_desc")%>
          
          <%if ( !cdoHd1.getColValue("activo","0").equals("0") ) {%>
             &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="color:red">activo</span>
          <%}%>
        </span>
        
        <span style="float:right; margin-right: 10px">
            <button id="btn-print" type="button" class="CellbyteBtn">Imprimir</button>
         </span>
         
      </td>
      
    </tr>
    
    <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
    <%=fb.formStart(true)%>
    <%=fb.hidden("alSize", ""+al2.size())%>
    <%=fb.hidden("pacId", pacId)%>
    <%=fb.hidden("noAdmision", noAdmision)%>
    <%=fb.hidden("id_oset_h1", idOsetH1)%>
	<%=fb.hidden("medico", "")%>
	<%=fb.hidden("peso", "")%>
	<%=fb.hidden("sexo", "")%>
    <%if(al2.size() > 0){%>
    <tr>
      <td>
          <ul style="list-style-type: none;">
            <%
              String group3 = "";
              for (int h2 = 0; h2<al2.size(); h2++) {
                CommonDataObject cdo2 = (CommonDataObject) al2.get(h2);
            %>
              <%if(cdo2.getColValue("tipo"," ").trim().equals("1")){%>
                  <li>
                  <h3><%=cdo2.getColValue("desc_header2")%>
                  <%if(!cdo2.getColValue("extra_info"," ").trim().equals("")){%>
                    <a href="#" class="hint hint--right  hint--large" data-hint="<%=cdo2.getColValue("extra_info"," ")%>">
                      <i class="fa fa-info-circle"></i>
                    </a>
                  <%}%>
                  </h3>
                  </li>
              <%}%>
              
              <%if(cdo2.getColValue("tipo"," ").trim().equals("2")){%>
                  <li style="margin-bottom: 5px; margin-left: 20px;">
                  <%=cdo2.getColValue("desc_header2")%>
                  <%if(!cdo2.getColValue("extra_info"," ").trim().equals("")){%>
                    <a href="#" class="hint hint--right  hint--large" data-hint="<%=cdo2.getColValue("extra_info"," ")%>">
                      <i class="fa fa-info-circle"></i>
                    </a>
                  <%}%>
                  </li>
              <%}%>
              
              <%if(cdo2.getColValue("tipo"," ").trim().equals("3")){%>
              <%if(!group3.equalsIgnoreCase(cdo2.getColValue("desc_header2"))){%>
                  <li style="margin-bottom: 5px; margin-left: 20px;">
                  <b><%=cdo2.getColValue("desc_header2")%></b>
                  <%if(!cdo2.getColValue("extra_info"," ").trim().equals("")){%>
                    <a href="#" class="hint hint--right  hint--large" data-hint="<%=cdo2.getColValue("extra_info"," ")%>">
                      <i class="fa fa-info-circle"></i>
                    </a>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <button class="upd-data" type="button" data-d="<%=h2%>" data-subtipo="<%=cdo2.getColValue("subtipo")%>"<%=!cdoHd1.getColValue("estatus", " ").trim().equalsIgnoreCase("C")?" disabled":""%>>
                      Aprobar
                    </button>
                  <%}%>
                  </li>
              <%}%>
              <%}%>

                  <%if(cdo2.getColValue("tipo"," ").trim().equals("3")){
                  %>
                    <%=fb.hidden("generar_om"+h2, cdo2.getColValue("generar_om"))%>
                    <%=fb.hidden("oset_det_id"+h2, cdo2.getColValue("oset_det_id"))%>
                    <li>
                    <ul style="list-style-type: none;">
                        <li>
                          <%if(!cdo2.getColValue("om_type", "0").equals("0")){%>
                          <input type="checkbox" class="can_change" id="can_change<%=h2%>" name="can_change<%=h2%>" data-d="<%=h2%>" data-subtipo="<%=cdo2.getColValue("subtipo")%>" data-canchange="<%=cdo2.getColValue("can_change")%>" checked<%=!cdo2.getColValue("generar_om", " ").trim().equalsIgnoreCase("P")?" disabled":""%>>
                          
                          <span class="pointer toggle-extra" data-d="<%=h2%>" data-subtipo="<%=cdo2.getColValue("subtipo")%>">
                              <%if(cdo2.getColValue("subtipo"," ").equalsIgnoreCase("LIS") || cdo2.getColValue("subtipo"," ").equalsIgnoreCase("RIS") || cdo2.getColValue("subtipo"," ").equalsIgnoreCase("MED") || cdo2.getColValue("subtipo"," ").equalsIgnoreCase("INT") || cdo2.getColValue("subtipo"," ").equalsIgnoreCase("BDS")){%>
                                <i class="fa fa-hand-o-right" aria-hidden="true"></i>
                              <%}%>
                              <%=cdo2.getColValue("display_text")%>
                          </span>
                          <%} else {%>
                            <strong><%=cdo2.getColValue("display_text")%></strong>
                          <%}%>
                          
                          <%if(!cdo2.getColValue("add_info_text"," ").trim().equals("")){%>
                            <a href="#" class="hint hint--right  hint--large" data-hint="<%=cdo2.getColValue("add_info_text"," ")%>">
                              <i class="fa fa-info-circle"></i>
                            </a>
                          <%}%>
                          
                          <%if(!cdo2.getColValue("om_type", "0").equals("0")){%>
                          <b>(<%=cdo2.getColValue("tipo_om")%>)</b>
                          
                            <%if(!cdo2.getColValue("generar_om", " ").trim().equalsIgnoreCase("P")){%>
                            <span class="label label-success">Generado</span>
                            <%}%>
                          <%}%>
                          
                              <%if(cdo2.getColValue("subtipo"," ").equalsIgnoreCase("LIS") || cdo2.getColValue("subtipo"," ").equalsIgnoreCase("RIS")){%>
                                <p style="display:" id="extra-data-<%=h2%>">
                                  <b>Prioridad</b>:                        
                                  <label><input class="extra-field extra-field-<%=h2%>" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="H"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("H")?" checked":""%>>Hoy</label>
                                  <label><input class="extra-field extra-field-<%=h2%>" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="M"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("M")?" checked":""%>>Mañana</label>
                                  <label><input class="extra-field extra-field-<%=h2%>" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="U"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("U")?" checked":""%>>Urgente</label>
                                  <label><input class="extra-field extra-field-<%=h2%>" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="O"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("O")?" checked":""%>>Otros</label>
                                  
                                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                  <b>CDS:</b>&nbsp;
                                  <%if(cdo2.getColValue("subtipo"," ").equalsIgnoreCase("LIS")){%>    
                                  <%=fb.select("centro_servicio"+h2,alLIS,cdo2.getColValue("centro_servicio"),false,false,viewMode,0,"Text10 extra-field extra-field-"+h2,null,null,"","S","")%>
                                  <%} else {%>
                                  <%=fb.select("centro_servicio"+h2,alRIS,cdo2.getColValue("centro_servicio"),false,false,viewMode,0,"Text10 extra-field extra-field-"+h2,null,null,"","S","")%>
                                  <%}%>

                                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Observ.:</b>
                                  <input class="extra-field extra-field-<%=h2%>" type="textbox" name="observacion<%=h2%>" id="observacion<%=h2%>" style="width:30%" value="<%=cdo2.getColValue("observacion"," ")%>">
                                </p>
                              
                              <%} else if(cdo2.getColValue("subtipo"," ").equalsIgnoreCase("MED")){%>
                                  <div style="display:" id="extra-data-<%=h2%>">
                                      <p></p>  
                                      <b>Concent.:</b>&nbsp;<input class="extra-field extra-field-<%=h2%>" type="textbox" name="concentracion<%=h2%>" id="concentracion<%=h2%>" value="<%=cdo2.getColValue("concentracion"," ")%>">
                                      <b>Frec.:</b>&nbsp;<input class="extra-field extra-field-<%=h2%>" type="textbox" name="frecuencia<%=h2%>" id="frecuencia<%=h2%>" value="<%=cdo2.getColValue("frecuencia"," ")%>">
                                      <b>Dosis.:</b>&nbsp;<input class="extra-field extra-field-<%=h2%>" type="textbox" name="dosis<%=h2%>" id="dosis<%=h2%>" value="<%=cdo2.getColValue("dosis"," ")%>">
                                      <b>Cant.:</b>&nbsp;<input class="extra-field extra-field-<%=h2%>" type="textbox" name="cantidad<%=h2%>" id="cantidad<%=h2%>" value="<%=cdo2.getColValue("cantidad"," ")%>">
                                      
                                      <p>
                                        <b>Forma:</b>&nbsp;<%=fb.select("forma"+h2,alDosis,cdo2.getColValue("forma"),false,false,viewMode,0,"Text10 extra-field  extra-field-"+h2,null,null,"","S","")%>
                                        <b>V&iacute;a:</b>&nbsp;<%=fb.select("via"+h2,alViaAd,cdo2.getColValue("via"),false,false,viewMode,0,"Text10 extra-field  extra-field-"+h2,null,null,"","S","")%>
                                      </p>
                                  </div>
                              <%} else if(cdo2.getColValue("subtipo"," ").equalsIgnoreCase("INT")){%>
									<div style="display:" id="extra-data-<%=h2%>">
										<p></p> 
										<!--med int, espe int,fecha int -->
										
										<b>M&eacute;d. Int.:</b>
										<%=fb.textBox("med_int_name"+h2, cdo2.getColValue("med_int_name") ,false,false,viewMode,20,500,"",null,null,null,false,"")%>
										<button type="button" class="CellbyteBtn btn_search_med" id="btn_search_med<%=h2%>"<%=viewMode? " disabled" : ""%> data-i="<%=h2%>">...</button>
										
										<b>Especialidad:</b>
										<%=fb.textBox("espe_med_int"+h2, cdo2.getColValue("espe_med_int") ,false,false,true,20,500,"",null,null,null,false,"")%>
										
										&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										
										<b>Fecha Int.</b>
										<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="nameOfTBox1" value="<%="fecha_interconsulta"+h2%>" />
											<jsp:param name="valueOfTBox1" value="<%=cdo2.getColValue("fecha_interconsulta")%>" />
											<jsp:param name="fieldClass" value="<%="Text10 extra-field extra-field-"+h2%>" />
											<jsp:param name="buttonClass" value="Text10" />
											<jsp:param name="clearOption" value="true" />
										</jsp:include>
								
										&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Observ.:</b>
										<input class="extra-field extra-field-<%=h2%>" type="textbox" name="observacion<%=h2%>" id="observacion<%=h2%>" style="width:20%" value="<%=cdo2.getColValue("observacion"," ")%>">
										<p></p>
										
										<%=fb.hidden("medico_interconsulta"+h2, cdo2.getColValue("medico_interconsulta"))%>
										<%=fb.hidden("especialidad_interconsulta"+h2, cdo2.getColValue("especialidad_interconsulta"))%>
								  </div>
                              <%} else if(cdo2.getColValue("subtipo"," ").equalsIgnoreCase("BDS")){%>

								<p style="display:" id="extra-data-<%=h2%>">
									<b>Prioridad</b>:                        

									<label><input class="extra-field extra-field-<%=h2%>" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="U"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("U")?" checked":""%>>Transfundir Urgente(1HR - 1:30MIN)</label>
									<label><input class="extra-field extra-field-<%=h2%>" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="H"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("H")?" checked":""%>>Transfundir Hoy(2-3 HR)</label>
									<label><input class="extra-field extra-field-<%=h2%>" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="O"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("O")?" checked":""%>>Procedimiento Programado</label>
									<label><input class="extra-field extra-field-<%=h2%>" type="radio" name="prioridad<%=h2%>" id="prioridad<%=h2%>" value="P"<%=cdo2.getColValue("prioridad"," ").equalsIgnoreCase("P")?" checked":""%>>Cruzar/Reservar PRN</label>
									
									<br>
									<b>Frec.:</b>&nbsp;<input class="extra-field extra-field-<%=h2%>" type="textbox" name="frecuencia<%=h2%>" id="frecuencia<%=h2%>" value="<%=cdo2.getColValue("frecuencia"," ")%>">
									
									<b>Cant.:</b>&nbsp;<input class="extra-field extra-field-<%=h2%>" type="textbox" name="cantidad<%=h2%>" id="cantidad<%=h2%>" value="<%=cdo2.getColValue("cantidad"," ")%>">
									
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<b>Motivo:</b>&nbsp;
									 <%=fb.select("motivo"+h2,alMotivo,cdo2.getColValue("motivo"),false,false,viewMode,0,"Text10 extra-field extra-field-"+h2,null,null,"","S","")%>
                                </p>

                              <%}%>
                        </li>
                      
                    </ul>
                  <%}%>
              </li>
            <%
            
              group3 = cdo2.getColValue("desc_header2");
              }
            %>
          </ul>
      </td>
    </tr>
    <%}%>
    <%=fb.formEnd(true)%>
   
</table>
</body>
</html>
<%} else {
    response.setContentType("application/json");
    
    Gson gson = new Gson();
    JsonObject json = new JsonObject();
    String errCode = "";
    String errMsg = "";
    
    json.addProperty("date", System.currentTimeMillis());
    
    int size = 0;
    al2.clear();
    if (request.getParameter("alSize") != null) size = Integer.parseInt(request.getParameter("alSize"));
    
    for (int i=0; i<size; i++){
    
        CommonDataObject cdo2 = new CommonDataObject();
        cdo2.setTableName("TBL_OSET_ORDEN_MEDICAS");
        cdo2.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and oset_header1 = "+idOsetH1+" and oset_det_id = "+request.getParameter("oset_det_id"+i));
        
      if (request.getParameter("can_change"+i) != null) {
        cdo2.addColValue("generar_om", "Y");
		cdo2.addColValue("om_approve_date", "sysdate");
        cdo2.addColValue("modified_by", (String)session.getAttribute("_userName"));
        cdo2.addColValue("modified_date", "sysdate");
        cdo2.addColValue("frecuencia", request.getParameter("frecuencia"+i));
        cdo2.addColValue("dosis", request.getParameter("dosis"+i));
        cdo2.addColValue("observacion", request.getParameter("observacion"+i));
        cdo2.addColValue("prioridad", request.getParameter("prioridad"+i));
        cdo2.addColValue("concentracion", request.getParameter("concentracion"+i));
        cdo2.addColValue("forma", request.getParameter("forma"+i));
        cdo2.addColValue("cantidad", request.getParameter("cantidad"+i));
        cdo2.addColValue("via", request.getParameter("via"+i));
        cdo2.addColValue("centro_servicio", request.getParameter("centro_servicio"+i));
        cdo2.addColValue("medico", request.getParameter("medico"));
        cdo2.addColValue("pac_peso", request.getParameter("peso"));
        cdo2.addColValue("pac_sexo", request.getParameter("sexo"));
		
		cdo2.addColValue("medico_interconsulta", request.getParameter("medico_interconsulta"+i));
		cdo2.addColValue("especialidad_interconsulta", request.getParameter("especialidad_interconsulta"+i));
		cdo2.addColValue("fecha_interconsulta", request.getParameter("fecha_interconsulta"+i));
		cdo2.addColValue("med_int_name", request.getParameter("med_int_name"+i));
		cdo2.addColValue("espe_med_int", request.getParameter("espe_med_int"+i));

      } else {
         cdo2.addColValue("generar_om", request.getParameter("generar_om"+i));
      }
      
      cdo2.setAction("U");
      al2.add(cdo2);
	   }
		
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al2,true);
		String sqlPl="{ call utl_oset_gen_om (?,?) }";
		CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
		param.setSql(sqlPl);
		param.addInNumberStmtParam(1,request.getParameter("pacId"));
		param.addInNumberStmtParam(2,request.getParameter("noAdmision"));
		param = SQLMgr.executeCallable(param);
		ConMgr.clearAppCtx(null);
		
		errCode = SQLMgr.getErrCode();
        errMsg = SQLMgr.getErrMsg();
    
    if (errCode.equals("1")) {
      json.addProperty("error", false);
      json.addProperty("msg", "Se han generados las ordenes médicas satisfactoriamente.");

    } else {
      response.setStatus(500);
      json.addProperty("error", true);
      json.addProperty("msg", errMsg);
    }
    
    out.print(gson.toJson(json));
}%>