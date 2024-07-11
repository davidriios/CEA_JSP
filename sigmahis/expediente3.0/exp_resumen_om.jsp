<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String appendFilter = "";
String mode = request.getParameter("mode");
String docId = request.getParameter("docId");
String defaultClass = "TextRow02";
String highlightClass = "TextRow03 Text12Bold";
String estado = request.getParameter("estado");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String sec = request.getParameter("sec");
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String cds = request.getParameter("cds");
String fechaNacimiento = request.getParameter("fechaNacimiento");
String codigoPaciente = request.getParameter("codigoPaciente");
String medico = request.getParameter("medico");
String _step = request.getParameter("step");
String companyId = (String) session.getAttribute("_companyId");

String _section = request.getParameter("section")==null?"":request.getParameter("section");
String _sectionDesc = request.getParameter("sectionDesc")==null?"":request.getParameter("sectionDesc");
String _path = request.getParameter("path")==null?"":request.getParameter("path");
String fp = request.getParameter("fp")==null?"":request.getParameter("fp");
String sectionId = request.getParameter("sectionId")==null?"":request.getParameter("sectionId");
if (fechaNacimiento == null) fechaNacimiento = "";
if (codigoPaciente == null) codigoPaciente = "";
if (medico == null) medico = "";
if (_step == null) _step = "N";

if (mode == null) mode = "add";
if (estado == null) estado = "";
if (sec == null) sec = "";
if (fg==null) fg = "";
if (tab == null) tab = "0";
if (cds == null) cds = "";

String profiles = CmnMgr.vector2numSqlInClause(UserDet.getUserProfile());

CommonDataObject cdoP = SQLMgr.getData("select p.nombre_paciente, p.id_paciente, p.sexo, p.edad, coalesce(d.cama,decode(a.categoria,1,'SIN ASIGNAR',' ')) as cama from tbl_adm_admision a, tbl_adm_atencion_cu d, vw_adm_paciente p where a.pac_id = d.pac_id and a.secuencia = d.secuencia and a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" and a.pac_id = p.pac_id");
if (cdoP == null) cdoP = new CommonDataObject();

/*
51	O/M SOLICITUD DE EKG
75	O/M SALIDA
97	O/M NUTRICION PARENTERAL ADULTO
79	O/M ESQUEMA DE INSULINA
98	O/M NUTRICION PARENTERAL NEONATAL Y PEDIATRICO
23	O/M PROCEDIMIENTOS
25	O/M EXAMENES LABORATORIO
05	O/M MEDICAMENTOS
19	O/M EXAMENES IMAGENOLOGIA
76	O/M VARIAS
30	O/M SOLICITUD DE  INTERCONSULTA
20	O/M TRATAMIENTOS
37	O/M NUTRICION
*/

sectionId = "51,75,97,79,98,23,25,5,19,76,30,20,37";

if (UserDet.getUserProfile().contains("0")){
	sbSql.append("select a.codigo, a.descripcion, '");
	if(estado.equalsIgnoreCase("F")) sbSql.append("view");
	else sbSql.append(mode);
	sbSql.append("' as actionMode, ");
	if(mode.equalsIgnoreCase("view")) sbSql.append("0");
	else sbSql.append("1");
	sbSql.append(" as editable, nvl(replace(a.path,'/expediente/','/expediente3.0/')||decode(instr(a.path,'?'),0,'?',null,'','&'),' ') as path, a.nombre_corto from tbl_sal_expediente_secciones a ");
	
	sbSql.append("where 1 = 1");
	if(!sec.equals("")){
		sbSql.append(" and a.descripcion like '%");
		sbSql.append(sec);
		sbSql.append("%'");
	}
    
    sbSql.append(" and a.codigo in(");
    sbSql.append(sectionId);
    sbSql.append(")");

    /*sbSql.append("order by instr (get_filled_value('");
    sbSql.append(sectionId);
    sbSql.append("',',','0',3), lpad(a.codigo,3,'0') )");*/
    sbSql.append("order by a.descripcion ");
    
} else {
	sbSql.append("select a.codigo, a.descripcion, nvl(replace(a.path,'/expediente/','/expediente3.0/')||decode(instr(a.path,'?'),0,'?',null,'','&'),' ') as path , decode(c.editable,1,decode(a.status,'A','");
	if(estado.equalsIgnoreCase("F")) sbSql.append("view");
	sbSql.append(mode);
	sbSql.append("','I','view'),'view') as actionMode, ");
	
	sbSql.append(" decode(a.status,'A',");
	if(mode.equalsIgnoreCase("view")) sbSql.append("0");
	else sbSql.append("c.editable");
	
	sbSql.append(",'I',0) as editable ");
	sbSql.append(", a.descripcion as display_order, a.nombre_corto ");
	
	sbSql.append(" from tbl_sal_expediente_secciones a ");

	sbSql.append(", (select secc_id, max(editable) as editable from tbl_sal_exp_secc_profile where profile_id in (");
	sbSql.append(profiles);
	sbSql.append(") group by secc_id) c, tbl_sal_exp_secc_centro d where ");
	
	sbSql.append(" 1=1 ");
	
	sbSql.append(" and a.codigo=c.secc_id and a.codigo=d.cod_sec and d.centro_servicio in (select cds from tbl_adm_atencion_cu where pac_id=");
	sbSql.append(pacId);
	if(noAdmision != null && !noAdmision.trim().equals("") && !noAdmision.trim().equals("0")){
		sbSql.append(" and secuencia=");
		sbSql.append(noAdmision);
	}
	sbSql.append(")");
	if(!sec.equals("")){
		sbSql.append(" and a.descripcion like '%");
		sbSql.append(sec);
		sbSql.append("%'");
	}
    
    sbSql.append(" and a.codigo in(");
    sbSql.append(sectionId);
    sbSql.append(")");
    
    /*sbSql.append("order by instr (get_filled_value('");
    sbSql.append(sectionId);
    sbSql.append("',',','0',3), lpad(a.codigo,3,'0') )");*/
    sbSql.append("order by a.descripcion ");
}

al = SQLMgr.getDataList(sbSql.toString());

boolean isStep = false; //

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<script>
document.title="Expediente - "+document.title;
var s = "<%=sbSql.toString()%>";
function doAction(){}

function setPatientInfo(formName,iframeName){ 
    var i = document.getElementById("index").value;
    var $iframe = $("#sec"+i).contents();
    var fn = $("#fechaNacimiento",parent.document).val() || "<%=fechaNacimiento%>"
    var cp = $("#codigoPaciente",parent.document).val() || "<%=fechaNacimiento%>"
    $iframe.find("#dob").val(fn);
    $iframe.find("#codPac").val(cp);
    console.log("setting patient info","FN:",$iframe.find("#dob").val(),"COD", $iframe.find("#codPac").val());
}

function setIndex(i){document.getElementById("index").value = i; console.log("calling i", i);}

$(function(){
  $('iframe').iFrameResize({
    log: false
  });
  
  
  $("#tabTabdhtmlgoodies_tabView1_0").click(function(e) {
       var $iframe = $("#i_ordenes_medicas");
       $iframe.attr('src', '../expediente/expediente_ordenes_medicas.jsp?pacId=<%=pacId%>&secuencia=<%=noAdmision%>&orderset=Y&nombre=<%=IBIZEscapeChars.forURL(cdoP.getColValue("nombre_paciente"))%>&cedula=<%=IBIZEscapeChars.forURL(cdoP.getColValue("id_paciente"))%>&cama=<%=IBIZEscapeChars.forURL(cdoP.getColValue("cama"))%>&edad=<%=cdoP.getColValue("edad")%>&sexo=<%=cdoP.getColValue("sexo")%>');
  });
  
  $("#section_id").change(function(e) {
      var self = $(this);
      var $tab = $("#tabTabdhtmlgoodies_tabView1_1");
      var $iframe = $("#i_nueva_orden");
      var proceed = true;
      
      if (self.val()) {
        if ($iframe.attr('src')) {
          if (confirm("Por favor guardar los cambios antes de cambiar de sección para evitar que los cambios se pierden. Esta seguro de querer seguir con su acción?"))
            proceed = true;
          else {
            this.value = $("#activeSection").val();
            proceed = false;
          }
        } else proceed = true;

        if (!proceed) {
          e.preventDefault();
          return;
        }

        $iframe.attr('src',  '')
        var $option = self.find("option:selected");
        var src = $option.data('base-href');
        var nombreCorto = $option.data('nombrecorto');
                
        $tab.children('span').html(nombreCorto)
        
        $("#info_seleccionar").hide()
        $iframe.attr('src',  src)
        $("#activeSection").val($option.val())
        $tab.click();
      }
  });

});

function setPatientInfo(formName,iframeName){ 
    var $iframe = $("#i_nueva_orden").contents();
    var fn = $("#fechaNacimiento",parent.document).val() || "<%=fechaNacimiento%>"
    var cp = $("#codigoPaciente",parent.document).val() || "<%=fechaNacimiento%>"
    $iframe.find("#dob").val(fn);
    $iframe.find("#codPac").val(cp);
    console.log("setting patient info","FN:",$iframe.find("#dob").val(),"COD", $iframe.find("#codPac").val());
}
</script>

</head>
<body class="body-form" style="padding-top: 0px !important;">
    <div class="row">    
    <div class="table-responsive" data-pattern="priority-columns">
        <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
        <%=fb.hidden("defaultClass",defaultClass)%>
        <%=fb.hidden("highlightClass",highlightClass)%>
        <%=fb.hidden("estado",estado)%>
        <%if (fp.equalsIgnoreCase("secciones_guardadas")){%>
        <%=fb.hidden("section",_section)%>
        <%}else{%>
        <%=fb.hidden("section","")%>
        <%}%>
        <%=fb.hidden("sectionDesc",_sectionDesc)%>
        <%=fb.hidden("path",_path)%>
        <%=fb.hidden("fechaNacimiento",fechaNacimiento)%>
        <%=fb.hidden("codigoPaciente",codigoPaciente)%>
        <%=fb.hidden("medico",medico)%>
        <%=fb.hidden("index","")%>
        <%=fb.hidden("estadoAtencion",estado)%>
        <%=fb.hidden("step",_step)%>
        <%=fb.hidden("activeSection", "")%>

        <table class="table table-small-font table-bordered table-striped">
            <tr>
                <td>
                Secci&oacute;n: 
                <select name="section_id" id="section_id" class="FormDataObjectEnabled">
                  <option value="">- SELECCIONE -</option>
                  <%for (int i=0; i<al.size(); i++){
                        cdo = (CommonDataObject) al.get(i);
                        
                        String xtraQS = "desc="+cdo.getColValue("descripcion")+"&pacId="+pacId+"&seccion="+cdo.getColValue("codigo")+"&noAdmision="+noAdmision+"&mode="+cdo.getColValue("actionMode")+"&cds="+cds+"&defaultAction="+cdo.getColValue("editable")+"&medico="+medico+"&from=salida_pop";
                      %>
                      <option value="<%=cdo.getColValue("codigo")%>" data-i="<%=i%>" data-nombrecorto="<%=cdo.getColValue("nombre_corto")%>" data-base-href="<%=cdo.getColValue("path")%><%=xtraQS%>">
                        <%=cdo.getColValue("descripcion")%>
                      </option>
                      <%}%>
                  </select>    
                </td>
            </tr>

           <tr>
              <td>
                  <!-- MAIN DIV START HERE -->
                  <div id="dhtmlgoodies_tabView1">

                      <!-- TAB0 DIV START HERE-->
                      <div class="dhtmlgoodies_aTab">
                          <table align="center" width="100%" cellpadding="0" cellspacing="1">
                              <tr class="TextRow02">
                                <td>&nbsp;</td>
                              </tr>
                              <tr>
                                  <td>
                                      <iframe id="i_ordenes_medicas" name="i_ordenes_medicas" width="100%" height="0" scrolling="no" frameborder="0" src="../expediente/expediente_ordenes_medicas.jsp?pacId=<%=pacId%>&secuencia=<%=noAdmision%>&orderset=Y&nombre=<%=IBIZEscapeChars.forURL(cdoP.getColValue("nombre_paciente"))%>&cedula=<%=IBIZEscapeChars.forURL(cdoP.getColValue("id_paciente"))%>&cama=<%=IBIZEscapeChars.forURL(cdoP.getColValue("cama"))%>&edad=<%=cdoP.getColValue("edad")%>&sexo=<%=cdoP.getColValue("sexo")%>"></iframe>
                                  </td>
                              </tr>
                          </table>
                       </div>
                      <!-- TAB0 DIV END HERE-->
                      
                      <!-- TAB1 DIV START HERE-->
                      <div class="dhtmlgoodies_aTab">
                          <table align="center" width="100%" cellpadding="0" cellspacing="1">
                              <tr class="TextRow02">
                                <td>&nbsp;</td>
                              </tr>
                              <tr>
                                  <td>
                                      <div id="info_seleccionar">Por favor seleccionar una secci&oacute;n para continuar</div>
                                      <iframe id="i_nueva_orden" name="i_nueva_orden" width="100%" height="0" scrolling="no" frameborder="0" src=""></iframe>
                                  </td>
                              </tr>
                          </table>
                       </div>
                      <!-- TAB1 DIV END HERE-->
            
                  </div>
                  <!-- MAIN DIV END HERE -->
               </td>
             </tr>   
            
          <script>
          <%String tabLabel = "'Revisión OM', 'Nueva OM'";%>
          initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
          </script>
        </table>
  <%=fb.formEnd(true)%>
</div>
</div>
</body>
</html>
<%
}//GET
%>