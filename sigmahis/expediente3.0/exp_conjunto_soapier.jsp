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

cdo = SQLMgr.getData("select nvl(get_sec_comp_param("+companyId+",'SAL_CDS_CUI'), '-1') cds_cui ,nvl(get_sec_comp_param("+companyId+",'CDS_NEO'), '-1') cds_neo from vw_adm_paciente p, tbl_adm_admision a where p.pac_id = "+pacId+" and p.pac_id = a.pac_id and a.secuencia = "+noAdmision);

if (cdo == null) {
  cdo = new CommonDataObject();
}

sectionId = "131";

String cdsCui = cdo.getColValue("cds_cui", "-1");
Vector vCdsCui = CmnMgr.str2vector(cdsCui);

String cdsNeo = cdo.getColValue("cds_neo", "-1");
Vector vCdsNeo = CmnMgr.str2vector(cdsNeo);

if (CmnMgr.vectorContains(vCdsCui,cds)) sectionId += ",133";
else if (CmnMgr.vectorContains(vCdsNeo,cds)) sectionId += ",73";
else sectionId += ",132";

/*
if (cds.trim().equals(cdsCui)) sectionId += ",133";
else sectionId += ",132";
*/

sectionId += ",134";

if (UserDet.getUserProfile().contains("0")){
	sbSql.append("select a.codigo, a.descripcion, '");
	if(estado.equalsIgnoreCase("F")) sbSql.append("view");
	else sbSql.append(mode);
	sbSql.append("' as actionMode, ");
	if(mode.equalsIgnoreCase("view")) sbSql.append("0");
	else sbSql.append("1");
	sbSql.append(" as editable, nvl(replace(a.path,'/expediente/','/expediente3.0/')||decode(instr(a.path,'?'),0,'?',null,'','&'),' ') as path from tbl_sal_expediente_secciones a ");
	
	sbSql.append("where 1 = 1");
	if(!sec.equals("")){
		sbSql.append(" and a.descripcion like '%");
		sbSql.append(sec);
		sbSql.append("%'");
	}
    
    sbSql.append(" and a.codigo in(");
    sbSql.append(sectionId);
    sbSql.append(")");
    
    sbSql.append("order by instr (get_filled_value('");
    sbSql.append(sectionId);
    sbSql.append("',',','0',3), lpad(a.codigo,3,'0'))");
    
} else {
	sbSql.append("select a.codigo, a.descripcion, nvl(replace(a.path,'/expediente/','/expediente3.0/')||decode(instr(a.path,'?'),0,'?',null,'','&'),' ') as path , decode(c.editable,1,decode(a.status,'A','");
	if(estado.equalsIgnoreCase("F")) sbSql.append("view");
	sbSql.append(mode);
	sbSql.append("','I','view'),'view') as actionMode, ");
	
	sbSql.append(" decode(a.status,'A',");
	if(mode.equalsIgnoreCase("view")) sbSql.append("0");
	else sbSql.append("c.editable");
	
	sbSql.append(",'I',0) as editable ");
	sbSql.append(", a.descripcion as display_order ");
	
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
    
    sbSql.append("order by instr (get_filled_value('");
    sbSql.append(sectionId);
    sbSql.append("',',','0',3), lpad(a.codigo,3,'0') )");
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
  
  $(".cb-accordion-header").on('click', function(){
    var self = $(this);
    var i = self.data('i');
    var path = self.data('path');
    var codigo = self.data('codigo');
    setIndex(i);
        
    var iframe = $("#sec"+i);
    if(!iframe.attr('src'))iframe.attr('src', path);     
  });
  
  var $accordion = $("#accordion").accordion({
    icons:false,
    heightStyle: "content",
    active: false,
    collapsible: true,
    activate: function(event, ui) {
        try {
            theOffset = ui.newHeader.offset();
            $('body,html').animate({ 
                scrollTop: theOffset.top 
            });
        } catch(err){}
    }
  });
  
  window.openNextAccordionPanel = function (form) {
    var current = $accordion.accordion("option","active"),
        maximum = $accordion.find("h3").length,
        next = current+1 === maximum ? 0 : current+1;
        
        $("#cb-accordion-header"+next).click();
        
        var i = document.getElementById("index").value;
        if (i > 0) i = i-1;
        var $iframe = $("#sec"+i);
        var iframe = $iframe[0];
        var codigo = $("#codigo"+i).val();
        var desc = $("#descripcion"+i).val();
                         
        if ((typeof $iframe[0].contentWindow.form0Validation !== 'undefined' && $iframe[0].contentWindow.form0Validation()) || (typeof $iframe[0].contentWindow.form1Validation !== 'undefined' && $iframe[0].contentWindow.form1Validation())) {
          var $cFrameCont = $iframe.contents();
          var $cForm = $cFrameCont.find('#'+form);
          $cFrameCont.find("#dob").val("<%=fechaNacimiento%>");
          $cFrameCont.find("#codPac").val("<%=codigoPaciente%>");
          
          if ($cForm.length) $cForm[0].submit();

          if (codigo && codigo == '45') {
		    
			parent.CBMSG.confirm("¿Quiere usted imprimir El Resumen Clínico?", {btnTxt:"Si,No", cb: function(r){
				  if (r == 'Si') {
					//abrir_ventana('<%=request.getContextPath()%>/expediente/print_resumen_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
					showPopWin('<%=request.getContextPath()%>/common/email_to_printer.jsp?fg=RESUMEN&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fechaProt=',winWidth*.65,winHeight*.45,null,null,'')
				  }
				  $("#cb-accordion-header"+next).removeClass("ui-state-disabled");
				  $accordion.accordion("option","active",next);
				}});
			
			
		  } else  {
            $("#cb-accordion-header"+next).removeClass("ui-state-disabled");
            $accordion.accordion("option","active",next);
          }
        }
   }
});

function showInterv(url, opts) {
   return parent.showInterv(url, opts);
}

function setCondUrl(seccion, condicion, condTitle) {
  var iObj = $($("iframe[name='sec"+seccion+"']"));
  var baseUrl = iObj.data("base-href");
  var url = baseUrl.replace("@@CONDICION",condicion).replace("@@CONDTITLE", condTitle);
  iObj.attr("src", url);
}
</script>
<style>
.ui-accordion .ui-accordion-content {
    padding-left:10px;
    padding-right:10px;
}
</style>
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

                <table class="table table-small-font table-bordered table-striped">
                    <tr>
                        <td>
                            <div id="accordion">
                            
                              <%for (int i=0; i<al.size(); i++){
                                cdo = (CommonDataObject) al.get(i);
                                
                                String xtraQS = "desc="+cdo.getColValue("descripcion")+"&pacId="+pacId+"&seccion="+cdo.getColValue("codigo")+"&noAdmision="+noAdmision+"&mode="+cdo.getColValue("actionMode")+"&cds="+cds+"&defaultAction="+cdo.getColValue("editable")+"&medico="+medico+"&from=salida_pop";
                              %>
                              <h3 class="cb-accordion-header<%=i!=0&&isStep?" ui-state-disabled":""%>" data-i="<%=i%>" data-path="<%=cdo.getColValue("path")%><%=xtraQS%>" id="cb-accordion-header<%=i%>" data-codigo="<%=cdo.getColValue("codigo")%>">
                               <%if(_step.trim().equalsIgnoreCase("Y")){%>Paso <%=i+1%>&nbsp;-->&nbsp;<%}%>
                               <%=cdo.getColValue("descripcion")%>
                              </h3>
                              <div id="cb-accordion-content<%=i%>">
                                <iframe id="sec<%=i%>" name="sec<%=cdo.getColValue("codigo")%>" width="100%" scrolling="yes" frameborder="0" src="<%//=cdo.getColValue("path")%><%//=xtraQS%>" data-base-href="<%=cdo.getColValue("path")%><%=xtraQS%>&condicion=@@CONDICION&cond_title=@@CONDTITLE"></iframe>
                                <%=fb.hidden("codigo"+i, cdo.getColValue("codigo"))%>
                                <%=fb.hidden("descripcion"+i, cdo.getColValue("descripcion"))%>
                              </div>
                              
                              <%}%>                              
                            </div>
                        </td>
                    </tr>        
                </table>
            </td>
        </tr>

        <%=fb.formEnd(true)%>
		</table>
</div>
</div>
</body>
</html>
<%
}//GET
%>