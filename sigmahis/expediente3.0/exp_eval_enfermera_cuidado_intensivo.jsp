<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.NotasEnfermeriaCuidadoIntensivo"%>
<%@ page import="issi.expediente.NotasEnfermeriaCuidadoIntensivoDet"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="NotaEnfCIMgr" scope="page" class="issi.expediente.NotasEnfermeriaCuidadoIntensivoMgr" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
NotaEnfCIMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alHdr = new ArrayList();
ArrayList alAreas = new ArrayList();
ArrayList alGrupos = new ArrayList();
ArrayList alCaract = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String userName = (String) session.getAttribute("_userName");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
if (from == null) from = "";

if (mode == null) mode = "";
if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (mode.trim().equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String id = request.getParameter("id");

if(id == null) id = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	sql="select a.codigo area, a.descripcion desc_area, presentar_check from tbl_sal_areas_cuid_intensivo a where a.estado = 'A' order by a.codigo";
	alAreas = SQLMgr.getDataList(sql);
    
    alHdr = SQLMgr.getDataList("select codigo, to_char(fecha_creacion,'dd/mm/yyyy') fecha, to_char(fecha_creacion,'hh12:mi:ss am') hora from tbl_sal_notas_cuidado_inten where pac_id = "+pacId+" and admision = "+noAdmision+" order by 1 desc");
%>
<!DOCTYPE html>
<html lang="en"> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
<script>
document.title = 'EXPEDIENTE - Evaluacion Física - '+document.title;
var noNewHeight = true;
function doAction(){}
function setEvaluacion(code){
    window.location = '../expediente3.0/exp_eval_enfermera_cuidado_intensivo.jsp?modeSec=view&mode=<%=mode%>&desc=<%=desc%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&id='+code;
}
function add(){window.location = '../expediente3.0/exp_eval_enfermera_cuidado_intensivo.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0&from=<%=from%>&desc=<%=desc%>';}

function canSubmit() {
  var proceed = true;
  return proceed;
}

function showMessages(message) {
<%if(from.trim().equalsIgnoreCase("salida_pop")){%>
parent.parent.CBMSG.error(message);
<%}else{%>
 parent.CBMSG.error(message);
<%}%>
}

function imprimir(fp){
    var code = '&code=<%=id%>';
    var url = '../expediente3.0/print_eval_enfermera_cuidado_intensivo.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>';
    if (fp && fp == 'TD') code = '';
    abrir_ventana(url+code);
}

function actAsRadio2(obj, codGrupo){
 <%for (int i = 1; i <= alAreas.size(); i++){
    CommonDataObject cdo2 = (CommonDataObject) alAreas.get(i-1);
    if (cdo2.getColValue("presentar_check","N").equalsIgnoreCase("N")){%>
    var classGroup = "act-as-radio-<%=cdo2.getColValue("area")%>"+(codGrupo?"-"+codGrupo:"");
    var $chkObj = $("input:checkbox."+classGroup);
    console.log($chkObj)
    //if($chkObj.hasClass($chkObj))
    $chkObj.click(function(){
        $(this).change(function(){
            $chkObj.not($(this)).prop("checked", false);
            $(this).prop("checked", $(this).prop("checked"));   
        });
    });
 <%}}%>
}

function actAsRadio(obj, codGrupo){
    var self = $(obj);
    var area = self.data('area');
    var grupo = self.data('grupo');
    var i = self.data('index');
    
    self.click(function(){
        self.change(function(){
            $("input:checkbox.act-as-radio-"+area+"-"+grupo).not($(this)).prop("checked", false);
            $(this).prop("checked", $(this).prop("checked"));  
        });
    });
}

$(function(){
    $(".should-type").click(function(){
      var that = $(this);
      var i = that.data('index');
      var area = that.data('area');
      if (that.is(":checked")) {
        $("#observacion_"+area+"_"+i).prop("readOnly", false);
      } else {
        $("#observacion_"+area+"_"+i).val("").prop("readOnly", true);
      }
    });
    
    // toggle details
     $(".areas-header").click(function(c){
        var that = $(this);
        var area = that.data('area');
        $("#area-det-"+area).toggle()
     });
});
</script>
</head>
<body class="body-forminside" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%//fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("id",""+id)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("from",from)%>

<div class="headerform2">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
    <tr>
        <td>
        <%if(!mode.trim().equals("view")){%>
          <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
            <i class="fa fa-plus fa-printico"></i> <b>Agregar Evaluaci&oacute;n</b>
          </button>
        <%}%>
        <%if(!id.trim().equals("") && !id.trim().equals("0")){%>
            &nbsp;
            <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir()"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
        <%}%>
        </td>
    </tr>
    <tr><th class="bg-headtabla">Listado de Evaluaciones</th></tr>
</table>

<div class="table-wrapper">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
    <thead>
        <tr class="bg-headtabla2">
        <th style="vertical-align: middle !important;">C&oacute;digo</th>
        <th style="vertical-align: middle !important;">Fecha</th>
        <th style="vertical-align: middle !important;">Hora</th>
    </thead>
<tbody>
<%
for (int i=1; i<=alHdr.size(); i++){
	CommonDataObject cdo1 = (CommonDataObject) alHdr.get(i-1);
%>
		<tr onClick="javascript:setEvaluacion(<%=cdo1.getColValue("codigo")%>)" class="pointer">
            <td><%=cdo1.getColValue("codigo")%></td>
            <td><%=cdo1.getColValue("fecha")%></td>
            <td><%=cdo1.getColValue("hora")%></td>
		</tr>
<%}%>
</tbody>
</table>
</div>
</div>

<table cellspacing="0" class="table table-small-font table-bordered">
 <tbody>
<%if(mode.trim().equals("add")){%>
<tr>
    <td class="controls form-inline" colspan="2">
        <cellbytelabel id="3">Fecha</cellbytelabel>&nbsp;<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1" />
        <jsp:param name="clearOption" value="true" />
        <jsp:param name="nameOfTBox1" value="fecha" />
        <jsp:param name="format" value="dd/mm/yyyy"/>
        <jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>" />
        <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
        </jsp:include>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <cellbytelabel id="4">Hora</cellbytelabel>  &nbsp;&nbsp;&nbsp;&nbsp;
        <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1"/>
        <jsp:param name="format" value="hh12:mi am"/>
        <jsp:param name="nameOfTBox1" value="hora" />
        <jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(11)%>" />
        <jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
        </jsp:include>
    </td>
</tr>
<%}%>
<tr class="bg-headtabla2">
    <th><cellbytelabel id="5">&Aacute;rea</cellbytelabel></th>
    <th><cellbytelabel id="6">Caracter&iacute;sticas</cellbytelabel></th>
</tr>

<%
 int realSize = 1;
 boolean actAsRadio = false;
 for (int a = 1; a<=alAreas.size(); a++) { 
 CommonDataObject cdoA = (CommonDataObject) alAreas.get(a-1);
 
 actAsRadio = cdoA.getColValue("presentar_check","N").equalsIgnoreCase("N");
 %>
   <tr>
      <td width="30%" class="pointer areas-header" data-area="<%=cdoA.getColValue("area")%>">
      [<%=cdoA.getColValue("area")%>]&nbsp;<%=cdoA.getColValue("desc_area")%> [<%=cdoA.getColValue("presentar_check")%>]</td>
      <td width="70%" style="display:none" id="area-det-<%=cdoA.getColValue("area")%>">
        <table cellspacing="0" class="table table-bordered table-grupos">
          <%
           String sqlGrupos = "select g.codigo cod_grupo, g.descripcion as desc_grupo, g.cod_area from tbl_sal_areas_cuid_inten_grupo g where g.cod_area = "+cdoA.getColValue("area")+" order by g.codigo";
           alGrupos = SQLMgr.getDataList(sqlGrupos);
           
           if (alGrupos.size() == 0) { 
             String sqlCaractNoGrupo = "select c.codigo cod_caract, c.cod_area, c.descripcion desc_caract, c.cod_area_grupo, decode(det.codigo_caract,null,'N','S') marcado, c.mostrar_observ, det.observacion from tbl_sal_caract_areas_cuid_int c,(select cid.cod_nota, cid.codigo_caract, cid.cod_area, ci.condicion, cid.obsercacion as observacion from tbl_sal_notas_cuidado_inten ci, tbl_sal_notas_cuidad_inten_det cid where ci.pac_id = "+pacId+" and ci.admision = "+noAdmision+" and ci.codigo = cid.cod_nota and ci.pac_id = cid.pac_id and ci.admision = cid.admision) det where det.codigo_caract(+) = c.codigo and det.cod_area(+) = c.cod_area and det.cod_nota(+) = "+id+" and c.cod_area_grupo is null and c.cod_area = "+cdoA.getColValue("area")+"  order by c.cod_area, c.codigo";
             alCaract = SQLMgr.getDataList(sqlCaractNoGrupo);
             
           %>
               <tr>
                 <td>
                    <table cellspacing="0" class="table table-bordered table-caracts">
                        <%for (int c = 1; c<=alCaract.size(); c++) {
                        CommonDataObject cdoC = (CommonDataObject) alCaract.get(c-1);%>
                        <tr>
                            <td>
                                <%=fb.hidden("cod_grupo"+realSize, "")%>
                                <%=fb.hidden("cod_area"+realSize,cdoA.getColValue("area")) %>
                                [<%=cdoC.getColValue("cod_caract")%>]
                                <label class="pointer">
                                  <%
                                  String xtraAttr = "";
                                  if(cdoC.getColValue("mostrar_observ")!=null && cdoC.getColValue("mostrar_observ").equalsIgnoreCase("S")){
                                    xtraAttr = " data-index='"+cdoC.getColValue("cod_caract")+"'  data-message='Por favor indicar informaciones para: "+realSize+"' data-grupo='_no_grupo'";
                                  }
                                  %>
                                  <%=fb.checkbox("cod_caract_"+cdoA.getColValue("area")+"_"+realSize, cdoC.getColValue("cod_caract") ,cdoC.getColValue("marcado")!=null && cdoC.getColValue("marcado").equalsIgnoreCase("S"),viewMode,"should-type checker"+(actAsRadio?" act-as-radio-"+cdoA.getColValue("area"):""),null,actAsRadio?"onclick=actAsRadio(this)":"",null, " data-index="+realSize+" data-area="+cdoA.getColValue("area"))%>
                                  <%=cdoC.getColValue("desc_caract")%>
                                </label>
                            </td>
                            <td>
                               <%if(cdoC.getColValue("mostrar_observ")!=null && cdoC.getColValue("mostrar_observ").equalsIgnoreCase("S") ){%>
                                 <%=fb.textarea("observacion_"+cdoA.getColValue("area")+"_"+realSize,cdoC.getColValue("observacion"),false,false,viewMode||cdoC.getColValue("observacion"," ").trim().equals(""),0,1,2000,"form-control input-sm","",null)%>
                               <%}%>
                            </td>
                        </tr>
                        <%
                         realSize++;
                        }%>
                    </table>
                 </td>
               </tr>
          <%}%>
           
           <% 
           for (int g = 1; g<=alGrupos.size(); g++) {
           CommonDataObject cdoG = (CommonDataObject) alGrupos.get(g-1);
          %>
          
          <tr>
            <td align="center">[<%=cdoG.getColValue("cod_grupo")%>]&nbsp;<%=cdoG.getColValue("desc_grupo")%></td>
            <td>
                <table cellspacing="0" class="table table-bordered table-caracts">
                <% 
                sql = "select c.codigo cod_caract, c.cod_area, c.descripcion desc_caract, c.cod_area_grupo, decode(det.codigo_caract,null,'N','S') marcado, c.mostrar_observ, det.observacion from tbl_sal_caract_areas_cuid_int c,(select cid.cod_nota, cid.codigo_caract, cid.cod_area, ci.condicion, cid.obsercacion as observacion from tbl_sal_notas_cuidado_inten ci, tbl_sal_notas_cuidad_inten_det cid where ci.pac_id = "+pacId+" and ci.admision = "+noAdmision+" and ci.codigo = cid.cod_nota and ci.pac_id = cid.pac_id and ci.admision = cid.admision) det where det.codigo_caract(+) = c.codigo and det.cod_area(+) = c.cod_area and det.cod_nota(+) = "+id+" and c.cod_area_grupo = "+cdoG.getColValue("cod_grupo")+" and c.cod_area = "+cdoA.getColValue("area")+"  order by c.cod_area, c.codigo";
                alCaract = SQLMgr.getDataList(sql);
                
                    for (int c = 1; c<=alCaract.size(); c++) {
                    CommonDataObject cdoC = (CommonDataObject) alCaract.get(c-1);
                    String radioDom = "cod_caract_"+cdoA.getColValue("area")+"_"+realSize;
                    
                    String observacion = cdoC.getColValue("observacion") != null && !cdoC.getColValue("observacion").trim().equals("") ? cdoC.getColValue("observacion") : "";
                 %> 
                 
                   
                   <tr>
                     <td>
                        <%=fb.hidden("cod_grupo"+realSize, cdoG.getColValue("cod_grupo"))%>
                        <%=fb.hidden("cod_area"+realSize,cdoA.getColValue("area")) %>
                        [<%=cdoC.getColValue("cod_caract")%>]&nbsp;
                        ::<label class="pointer">
                        <%=fb.checkbox(radioDom, cdoC.getColValue("cod_caract") ,cdoC.getColValue("marcado")!=null && cdoC.getColValue("marcado").equalsIgnoreCase("S"),viewMode,"should-type checker"+(actAsRadio?" act-as-radio-"+cdoA.getColValue("area")+"-"+cdoG.getColValue("cod_grupo"):""),null,actAsRadio?"onclick=actAsRadio(this,'"+cdoG.getColValue("cod_grupo")+"')":"", null, " data-index="+realSize+" data-area="+cdoA.getColValue("area")+" data-grupo="+cdoG.getColValue("cod_grupo"))%>
                        <%=cdoC.getColValue("desc_caract")%>
                        </label>
                     </td>
                     
                     <td class="controls form-inline">
                        <%if(cdoC.getColValue("mostrar_observ")!=null && cdoC.getColValue("mostrar_observ").equalsIgnoreCase("S")){
                        String xtraAttr = " data-index='"+radioDom+"' data-message='Por favor indicar informaciones para: "+cdoG.getColValue("desc_grupo")+"' data-grupo=''";
                        %>
                        
                         <%=fb.textarea("observacion_"+cdoA.getColValue("area")+"_"+realSize, observacion ,false,false,viewMode||observacion.equals(""),0,1,0,"form-control input-sm",null,"")%>
                        <%}%>
                     </td>
                   </tr>
    
                 <%
                 realSize++;
                 }%>   
                </table>
            </td>
          </tr>
          <%}%>
        </table>
      </td>
   </tr>
 
<%}%>

<%
//if (from.trim().equalsIgnoreCase("salida_pop")){
  //cdo = SQLMgr.getData("select condicion from tbl_sal_notas_cuidado_inten where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+id);
  //if (cdo == null) cdo = new CommonDataObject();
%> <!--
  <tr>
    <td colspan="2">
        <b>Seleccionar el Plan de Cuidado</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <%//=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_sal_soapier_condicion where estatus = 'A'","condicion",cdo.getColValue("condicion"),false,viewMode,0,"",null,"",null,"S")%>
    </td>
 </tr>
<%//if(cdo.getColValue("condicion")!=null&&!cdo.getColValue("condicion").equals("")){%>
<script>
  parent.setCondUrl(134, "<%//=cdo.getColValue("condicion")%>", $("#condicion").selText());
</script> 
<%//}}%>
-->
<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
    <td><small>Opciones de Guardar:<label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
        <%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
        <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
    </tr>
    </table> </div>
<%=fb.hidden("realSize", ""+realSize) %>
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
	int size = Integer.parseInt(request.getParameter("realSize")==null?"0":request.getParameter("realSize"));

	Hashtable htHash = new Hashtable();
	al.clear();
    
    NotasEnfermeriaCuidadoIntensivo nota = new NotasEnfermeriaCuidadoIntensivo();
    nota.setPacId(request.getParameter("pacId"));
    nota.setAdmision(request.getParameter("noAdmision"));
    nota.setUsuarioCreacion(userName);
    nota.setUsuarioModificacion(userName);
    nota.setFecha(request.getParameter("fecha"));
    nota.setHora(request.getParameter("hora"));
    
    if (from.trim().equalsIgnoreCase("salida_pop")) {
        //nota.setCondicion(request.getParameter("condicion"));
    }
        
	for (int i= 1; i <= size; i++){
        int addDet = 0;
        String codArea = request.getParameter("cod_area"+i);
        
        if (request.getParameter("cod_caract_"+codArea+"_"+i)!=null) {
        
            NotasEnfermeriaCuidadoIntensivoDet det = new NotasEnfermeriaCuidadoIntensivoDet();
            det.setCodigoCaract(request.getParameter("cod_caract_"+codArea+"_"+i));
            det.setCodArea(codArea);
            det.setObservacion(request.getParameter("observacion_"+codArea+"_"+i));
                
            try {
                nota.addDet(det);
            }
            catch(Exception e){
                System.err.println(e.getMessage());
            } 
        }
	}//for

	if (baction.equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		NotaEnfCIMgr.add(nota);
		if(modeSec.trim().equals("add"))
            id = NotaEnfCIMgr.getPkColValue("codigo");

		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (NotaEnfCIMgr.getErrCode().equals("1"))
{
%>
	alert('<%=NotaEnfCIMgr.getErrMsg()%>');
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
} else throw new Exception(NotaEnfCIMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}
function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&desc=<%=desc%>&from=<%=from%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>