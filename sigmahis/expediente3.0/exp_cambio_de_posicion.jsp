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
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

sql="select CODIGO, observacion, USUARIO_CREACion, to_char(FECHA_CREACion,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREACion, USUARIO_MODIFicacion, to_char(FECHA_MODIFicacion,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIFicacion, to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') as FECHA, decode(posicion,'F','FOWLER','DLI','DECUBITO LATERAL IZQUIERDO','DLDL','DECUBITO LATERAL DERECHO','DS','DECUBITO SUPINO','SF','SEMIFOWLER','S','SUPINO') posicion from tbl_sal_cambio_de_posicion where pac_id="+pacId+" and admision = "+noAdmision +" order by CODIGO DESC";

alEval = SQLMgr.getDataList(sql);

if(!code.trim().equals("0")){

    sql = "select CODIGO, observacion, USUARIO_CREACion, to_char(FECHA_CREACion,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIFicacion, to_char(FECHA_MODIFicacion,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF,  posicion,to_char(FECHA,'dd/mm/yyyy hh12:mi:ss am') as FECHA from tbl_sal_cambio_de_posicion where pac_id="+pacId+" and admision = "+noAdmision+" and codigo="+code;

    cdo1 = SQLMgr.getData(sql);
}

if (cdo1 == null || code.trim().equals("0"))
{
    if (!viewMode) modeSec = "add";
    cdo1 = new CommonDataObject();

    cdo1.addColValue("CODIGO","1");
    cdo1.addColValue("USUARIO_CREACion",(String) session.getAttribute("_userName"));
    cdo1.addColValue("FECHA_CREACion",cDateTime);
    cdo1.addColValue("USUARIO_MODIFicacion",(String) session.getAttribute("_userName"));
    cdo1.addColValue("FECHA_MODIFicacion",cDateTime);
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
    var url = '../expediente3.0/print_cambio_de_posicion.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>';
    if (fp && fp == 'TD') code = '';
    abrir_ventana(url+code);
}
function setCambio(p){
    var code = eval('document.form0.codigo'+p).value;
    window.location = '../expediente3.0/exp_cambio_de_posicion.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code='+code;
}
function add(){window.location = '../expediente3.0/exp_cambio_de_posicion.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0';}
$(function(){
doAction();
});

function printXHora() {
  var fecha = document.getElementById("rpt_fecha").value;
  if (fecha) abrir_ventana('../cellbyteWV/report_container.jsp?reportName=expediente/rpt_cambio_posicion.rptdesign&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&p_desc=<%=desc%>&pCtrlHeader=false&pFecha='+fecha);
}
</script>
</head>
<body class="body-forminside">  
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
<td class="controls form-inline">
    <%if(!mode.trim().equals("view")){%>
      <button type="button" class="btn btn-inverse btn-sm" onclick="add()">
        <i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
      </button>
    <%}%>
    <%if(!code.trim().equals("") && !code.trim().equals("0")){%>
    <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir('')"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b></button>
    <%}%>
    <button type="button" class="btn btn-inverse btn-sm" onclick="imprimir('TD')"><i class="fa fa-print fa-printico"></i> <b>Imprimir Todo</b></button>
    
    <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="1"/>
        <jsp:param name="format" value="dd/mm/yyyy"/>
        <jsp:param name="nameOfTBox1" value="rpt_fecha" />
        <jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>" />
    </jsp:include>
    <button type="button" class="btn btn-inverse btn-sm" onclick="printXHora()"><i class="fa fa-print fa-printico"></i> <b>x Hora</b></button>
            
</td>
</tr>
    <tr><th class="bg-headtabla">LISTADO DE RESULTADOS</th></tr>
</table>
<div class="table-wrapper">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
    <tr class="bg-headtabla2">
    <th style="vertical-align: middle !important;">C&oacute;digo</th>
    <th style="vertical-align: middle !important;">Fecha</th>
    <th style="vertical-align: middle !important;">Usuario</th>
    <th style="vertical-align: middle !important;">Posici&oacute;n</th>
    </thead>
<tbody>
<%
for (int p = 1; p<=alEval.size(); p++){
    cdoEval = (CommonDataObject)alEval.get(p-1);
    %>

<tr onclick="javascript:setCambio(<%=p%>)" class="pointer">
<td><%=cdoEval.getColValue("CODIGO")%></td>
<td><%=cdoEval.getColValue("FECHA")%></td>
<td><%=cdoEval.getColValue("usuario_creacion")%></td>
<td><%=cdoEval.getColValue("posicion")%></td>
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
     <tr>
        <th class="bg-headtabla">Fecha</th>
        <th class="bg-headtabla">Posici&oacute;n</th>
        <th class="bg-headtabla">Observaci&oacute;n</th>
     </tr>
     
     <tr>
        <td class="controls form-inline">
            <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1"/>
                <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                <jsp:param name="nameOfTBox1" value="fecha" />
                <jsp:param name="valueOfTBox1" value="<%=cdo1.getColValue("fecha")!=null?cdo1.getColValue("fecha"):cDateTime%>" />
                <jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
            </jsp:include>
        </td>
        <td>
          <%=fb.select("posicion","F=FOWLER,DLI=DECUBITO LATERAL IZQUIERDO,DLDL=DECUBITO LATERAL DERECHO,DS=DECUBITO SUPINO,SF=SEMIFOWLER,S=SUPINO",cdo1.getColValue("posicion"),false,viewMode,0,"form-control input-sm",null,null)%>
        </td>
        <td class="controls form-inline">
            <%=fb.textarea("observacion",cdo1.getColValue("observacion"),false,false,viewMode,30,1,2000,"form-control input-sm","width:100%","")%>
        </td>
        <%=fb.hidden("remove"+code,code)%>
        <%=fb.hidden("usuario_creac",cdo1.getColValue("usuario_creac"))%>
        <%=fb.hidden("fecha_creac",cdo1.getColValue("fecha_creac"))%>
        <%=fb.hidden("usuario_modific",cdo1.getColValue("usuario_modif"))%>
        <%=fb.hidden("fecha_modific",cdo1.getColValue("fecha_modif")) %>
    </tr>
    
     
    
</tbody>
</table>
    

<div class="footerform"><table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
<tr>
    <td><small>Opciones de Guardar: <label><input type="radio" name="saveOption" value="O" checked="checked"> Mantener Abierto</label> <label><input type="radio" name="saveOption" value="C"> Cerrar</label> </small>
        <%=fb.submit("save","Guardar",viewMode,false,"",null,"")%>
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
else
{
    String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

    cdo = new CommonDataObject();
    cdo.setTableName("tbl_sal_cambio_de_posicion");
    
    cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));

    cdo.addColValue("observacion",request.getParameter("observacion"));
    cdo.addColValue("posicion",request.getParameter("posicion"));
    cdo.addColValue("fecha",request.getParameter("fecha"));

    if(modeSec.equalsIgnoreCase("add")){
      cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
      cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
      cdo.addColValue("fecha_creacion",cDateTime);
      cdo.addColValue("fecha_modificacion",cDateTime);
      cdo.addColValue("admision",request.getParameter("noAdmision"));
      cdo.addColValue("pac_id",request.getParameter("pacId"));
      
      cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
      cdo.setAutoIncCol("codigo");
      cdo.addPkColValue("codigo","");
        
      SQLMgr.insert(cdo);
      code = SQLMgr.getPkColValue("CODIGO");
    }else{
        cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
        cdo.addColValue("fecha_modificacion",cDateTime);
        
        cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and codigo = "+code);
        SQLMgr.update(cdo);
    }

    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>