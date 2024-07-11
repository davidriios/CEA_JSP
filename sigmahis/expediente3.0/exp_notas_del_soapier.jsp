<%@ page errorPage="../error.jsp"%>
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
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

sql="select CODIGO, DESCRIPCION, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIF, to_char(FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF, area_desc, area, decode(estado,'V','VÁLIDA','INVÁLIDA') estado from tbl_sal_notas_del_soapier where pac_id="+pacId+" and secuencia="+noAdmision +" and nvl(tipo, 'S') = '"+fg+"' order by CODIGO DESC";

alEval = SQLMgr.getDataList(sql);

CommonDataObject cdo2 = new CommonDataObject();

if(!code.trim().equals("0")){

    sql = "select CODIGO, DESCRIPCION, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIF, to_char(FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF, estado from tbl_sal_notas_del_soapier where pac_id="+pacId+" and secuencia="+noAdmision+" and nvl(tipo, 'S') = '"+fg+"' and codigo="+code;

    cdo1 = SQLMgr.getData(sql);
}

if (cdo1 == null || code.trim().equals("0"))
{
    if (!viewMode) modeSec = "add";
    cdo1 = new CommonDataObject();

    cdo1.addColValue("CODIGO","1");
    cdo1.addColValue("USUARIO_CREAC",(String) session.getAttribute("_userName"));
    cdo1.addColValue("FECHA_CREAC",cDateTime);
    cdo1.addColValue("USUARIO_MODIF",(String) session.getAttribute("_userName"));
    cdo1.addColValue("FECHA_MODIF",cDateTime);
    
    cdo2 = SQLMgr.getData("select codigo, descripcion from tbl_cds_centro_servicio where codigo = (select unidad_admin from tbl_sal_habitacion where codigo = ( select habitacion from tbl_adm_cama_admision where pac_id = "+pacId+" and admision = "+noAdmision+"  and fecha_final is null and rownum = 1 ) and compania = "+compania+")");
    
    if (cdo2 == null) cdo2 = new CommonDataObject();
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
    var url = '../expediente3.0/print_notas_del_sopier.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&fg=<%=fg%>';
    if (fp && fp == 'TD') code = '';
    abrir_ventana(url+code);
}
function setEkg(p){
    var code = eval('document.form0.codigo'+p).value;
    window.location = '../expediente3.0/exp_notas_del_soapier.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&fg=<%=fg%>&noAdmision=<%=noAdmision%>&code='+code;
}
function add(){window.location = '../expediente3.0/exp_notas_del_soapier.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&fg=<%=fg%>&noAdmision=<%=noAdmision%>&code=0';}

function invalidar(self, codigo) { 
    var self = $(self);
    self.prop("disabled", true);
    var exe = executeDB('<%=request.getContextPath()%>',"update tbl_sal_notas_del_soapier set estado = 'I', usuario_modif = '<%=(String) session.getAttribute("_userName")%>', fecha_modif = to_date('<%=cDateTime%>', 'dd/mm/yyyy hh12:mi:ss am') where pac_id = <%=pacId%> and secuencia = <%=noAdmision%> and nvl(tipo, 'S') = '<%=fg%>' and codigo = "+codigo);
    if (!exe) {
        parent.CBMSG.error("La nota no se ha podido ser invalidada!");
        self.prop("disabled", false);
    } else location.reload(true);
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
    <tr><th class="bg-headtabla">LISTADO DE RESULTADOS</th></tr>
</table>
<!--fin tabla de boton imprimit-->
<div class="table-wrapper pinkarize">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
    <tr class="bg-headtabla2">
    <th style="vertical-align: middle !important;">C&oacute;digo</th>
    <th style="vertical-align: middle !important;">Fecha</th>
    <th style="vertical-align: middle !important;">Registrado Por</th>
    <th style="vertical-align: middle !important;">&Aacute;rea de atenci&oacute;n</th>
    <th style="vertical-align: middle !important;">Estado</th>
    </thead>
<tbody>
<%
for (int p = 1; p<=alEval.size(); p++){
    cdoEval = (CommonDataObject)alEval.get(p-1);
    %>

<tr onclick="javascript:setEkg(<%=p%>)" class="pointer pinkarize">
<td><%=cdoEval.getColValue("CODIGO")%></td>
<td><%=cdoEval.getColValue("FECHA_CREAC")%></td>
<td><%=cdoEval.getColValue("USUARIO_CREAC")%>&nbsp;/&nbsp;<%=cdoEval.getColValue("USUARIO_MODIF")%></td>
<td><%=cdoEval.getColValue("area_desc")%></td>
<td><%=cdoEval.getColValue("estado")%></td>
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
        <th colspan="2">Datos Generales</th>
        <th>&nbsp;</th>
     </tr>
     
     <tr class="pinkarize">
        <td class="controls form-inline">
        <cellbytelabel><strong>Hora</strong></cellbytelabel>
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1"/>
                <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                <jsp:param name="nameOfTBox1" value="hora" />
                <jsp:param name="valueOfTBox1" value="<%=cdo1.getColValue("fecha_creac")!=null?cdo1.getColValue("fecha_creac"):""%>" />
                <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
            </jsp:include>
        </td>
        <td class="controls form-inline">
            <cellbytelabel><strong>Nota de <%=(fg.equalsIgnoreCase("N"))?"Nutrici&oacute;n":"Enfermer&iacute;a"%></strong></cellbytelabel>
            <%=fb.textarea("descripcion",cdo1.getColValue("DESCRIPCION"),true,false,viewMode,30,0,2000,"form-control input-sm","width:100%","")%>
        </td>
        <td align="center">
            <button title="Invalidar Nota" type="button" class="btn btn-inverse btn-sm" onclick="invalidar(this, '<%=cdo1.getColValue("codigo")%>');"<%=modeSec.equalsIgnoreCase("add")||cdo1.getColValue("estado"," ").trim().equalsIgnoreCase("I")?" disabled":""%>>
            <i class="material-icons fa-printico">clear</i></button>
        </td>
        <%=fb.hidden("remove"+code,code)%>
        <%=fb.hidden("usuario_creac",cdo1.getColValue("usuario_creac"))%>
        <%=fb.hidden("fecha_creac",cdo1.getColValue("fecha_creac"))%>
        <%=fb.hidden("usuario_modific",cdo1.getColValue("usuario_modif"))%>
        <%=fb.hidden("fecha_modific",cdo1.getColValue("fecha_modif")) %>
        
        <%if(cdo2!=null && !cdo2.getColValue("codigo"," ").trim().equals("")){%>
            <%=fb.hidden("area",cdo2.getColValue("codigo"))%>
            <%=fb.hidden("area_desc",cdo2.getColValue("descripcion"))%>
        <%} else {%>
            <%=fb.hidden("area",cdo1.getColValue("area"))%>
            <%=fb.hidden("area_desc",cdo1.getColValue("area_desc"))%>
        <%}%>
        
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
    String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

    cdo = new CommonDataObject();
    cdo.setTableName("tbl_sal_notas_del_soapier");
    
    cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));

    cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
    cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
    cdo.addColValue("SECUENCIA",request.getParameter("noAdmision"));
    cdo.addColValue("PAC_ID",request.getParameter("pacId"));
    cdo.addColValue("DESCRIPCION",request.getParameter("descripcion"));
    cdo.addColValue("tipo", fg);
                    
    if (request.getParameter("area") != null && !request.getParameter("area").trim().equals("")) {
        cdo.addColValue("area", request.getParameter("area"));
        cdo.addColValue("area_desc", request.getParameter("area_desc"));
    }

    if(modeSec.equalsIgnoreCase("add")){
      cdo.addColValue("USUARIO_CREAC",(String) session.getAttribute("_userName"));
      cdo.addColValue("USUARIO_MODIF",(String) session.getAttribute("_userName"));
      cdo.addColValue("FECHA_CREAC",request.getParameter("hora"));
      cdo.addColValue("FECHA_MODIF",cDateTime);
      
      cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
      cdo.setAutoIncCol("codigo");
      cdo.addPkColValue("codigo","");
        
      SQLMgr.insert(cdo);
      code = SQLMgr.getPkColValue("CODIGO");
    }else{
        cdo.addColValue("USUARIO_MODIF",(String) session.getAttribute("_userName"));
        cdo.addColValue("FECHA_CREAC",cDateTime);
        
        cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision")+" and codigo = "+code);
        SQLMgr.update(cdo);
    }

    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    ConMgr.setAppCtx(ConMgr.AUDIT_NOTES, "fg="+fg);
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