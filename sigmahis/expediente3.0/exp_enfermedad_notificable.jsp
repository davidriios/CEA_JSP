<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="EvalDiagSalMgr" scope="page" class="issi.expediente.EvaluacionDiagSalidaMgr" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDiag" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDiag" scope="session" class="java.util.Vector" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
EvalDiagSalMgr.setConnection(ConMgr);
Hashtable ht = null;
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();
boolean viewMode = false;
String sql = "";

String mode = "";
String modeSec = "";
String seccion = "";
String pacId = "";
String noAdmision = "";
String desc = "";
String from = "";
String fg = "";
String fp = "";

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = (String) session.getAttribute("_userName");

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart")){

	ht = CmnMgr.getMultipartRequestParametersValue(request, ResourceBundle.getBundle("path").getString("scanned"),20,true);
	mode = (String) ht.get("mode");
    modeSec = (String) ht.get("modeSec");
    seccion = (String) ht.get("seccion");
    pacId = (String) ht.get("pacId");
	noAdmision = (String) ht.get("noAdmision");
    desc = (String) ht.get("desc");
    from = (String) ht.get("from");
    fp = (String) ht.get("fp");
    fg = (String) ht.get("fg");
} else {
    mode = request.getParameter("mode");
    modeSec = request.getParameter("modeSec");
    seccion = request.getParameter("seccion");
    pacId = request.getParameter("pacId");
    noAdmision = request.getParameter("noAdmision");
    desc = request.getParameter("desc");
    from = request.getParameter("from");
    fp = request.getParameter("fp");
    fg = request.getParameter("fg");
}

if (from == null) from = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (mode.trim().equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET")) {
StringBuffer sbSql = new StringBuffer();

sbSql.append("select n.documento, n.observacion, n.usuario_creacion, n.usuario_modificacion, to_char(n.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, to_char(n.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion, n.cod_enf, e.codigo as enfermedad, e.nombre as enfermedad_desc");

sbSql.append(", decode(n.documento,null,' ','");
sbSql.append(ResourceBundle.getBundle("path").getString("scanned").replaceAll(ResourceBundle.getBundle("path").getString("root"),".."));
sbSql.append("/'||n.documento) as scanPath, nvl(n.documento,'') title ,decode(n.documento,null,' ','");
sbSql.append(ResourceBundle.getBundle("path").getString("scanned"));
sbSql.append("/'||n.documento) as filePath, decode(n.cod_enf,null,'I','U') action ");

sbSql.append(" from tbl_sal_notif_enfermedades n, tbl_cds_enfermedad_notificable e where tipo_diag = 'A' and n.tipo(+) = '"+fg+"' and n.cod_enf(+) = e.codigo and n.pac_id(+) = ");
sbSql.append(pacId);
sbSql.append(" and n.admision(+) = ");
sbSql.append(noAdmision);

al = SQLMgr.getDataList(sbSql.toString());

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
var noNewHeight = true;
function doAction(){}
function imprimir(){}

function canSubmit() {
  var proceed = true;
  return proceed;
}

$(function(){

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
</script>
<style>
table {
  width: 100%;
  border-collapse: collapse;
}
td, th {
  padding: .25em;
  border: 1px solid black;
}
tbody:nth-child(odd) {
  background: #CCC;
}
</style>
</head>
<body class="body-form"onLoad="javascript:doAction()">
<div class="row">    
<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-1">
    <tr>
        <td>
            <%//=fb.button("imprimir","imprimir",false,false,null,null,"onClick=\"javascript:printExp()\"")%>
        </td>
    </tr>
</table>
</div>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%//fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>

<table cellspacing="0" class="table table-small-font table-bordered">
    <tr class="bg-headtabla" align="center">
      <td><cellbytelabel>C&oacute;digo</cellbytelabel></td>
      <td><cellbytelabel>Enfermedad</cellbytelabel></td>
      <td><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
    </tr>
    
    <%
        String documento = "";
        for (int i = 0; i < al.size(); i++) {
            cdo = (CommonDataObject) al.get(i);
            
            if (!cdo.getColValue("scanPath"," ").trim().equals("")) {
                documento = cdo.getColValue("scanPath");
            }
    %>
            <%=fb.hidden("enfermedad"+i, cdo.getColValue("enfermedad"))%>
            <%=fb.hidden("action"+i, cdo.getColValue("action"))%>
            <tbody>
                <tr>
                    <td>
                        <label class="pointer"><%=fb.checkbox("check"+i,"0",cdo.getColValue("cod_enf").equals(cdo.getColValue("enfermedad")),viewMode,"should-type",null,"",""," data-index="+i)%>&nbsp;
                        <%=cdo.getColValue("enfermedad")%>
                        </label>
                    </td>
                    <td><%=cdo.getColValue("enfermedad_desc")%></td>
                    <td>
                        <%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,(viewMode || cdo.getColValue("observacion"," ").trim().equals("") ),0,1,0,"form-control input-sm","",null)%>
                    </td>
                </tr>
            </tbody>
    <%    
            if ((i+1) == al.size()) {
    %>
              <tbody>  
                <tr>
                    <td>Documento</td>
                    <td colspan="2" class="controls form-inline">
                        <%if (!documento.trim().equals("")) {%>
                            <label class="btn btn-primary" onClick="javascript:abrir_ventana('../common/abrir_ventana.jsp?fileName=<%=documento%>')">
                                <i class="fa fa-eye fa-lg"></i>
                            </label>
                        <%}%>
                        <label class="btn btn-primary btn-file" for="documento"<%=viewMode?" disabled":""%>>
                            <i class="fa fa-upload fa-lg"></i>
                            Buscar
                            <%=fb.fileBox("documento","",false,viewMode,15,"hidden","","")%>
                        </label>
                    </td>
                </tr>
              </tbody>   
    <%
            }
        
        }
    %>
	
    </table>
    
    <div class="footerform" style="bottom:-11px !important">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
              <td>
                <%if(!from.equalsIgnoreCase("salida_pop")){%>
                <cellbytelabel id="6">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="7">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="8">Cerrar</cellbytelabel>

                <button type="button" name="save" id="save" value="Guardar" class="btn btn-inverse btn-sm" onclick="javascript:__submitForm(this.form, 'Guardar');"<%=viewMode?" disabled":""%>><i class="fa fa-floppy-o fa-lg"></i> Guardar</button>
                
				<button type="button" name="cancel" id="cancel" value="Cancelar" class="btn btn-inverse btn-sm" onclick="javascript:parent.doRedirect(0)"<%=viewMode?" disabled":""%>><i class="fa fa-times fa-lg"></i> Cancelar</button>
                
                <%}else{%>
                  <%=fb.submit("save","Siguiente",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value); parent.openNextAccordionPanel('"+fb.getFormName()+"');\"")%>
                  <%=fb.hidden("saveOption","O")%>
                <%}%>
              </td>
            </tr>
        </table>
    </div>
    <%=fb.hidden("size", ""+al.size())%>
    <%=fb.formEnd(true)%>    
    </div>

</div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = (String)ht.get("saveOption");
	String baction = (String)ht.get("baction");
    if(baction == null) baction = "";
    
    int size = 0;
	if ( ((String)ht.get("size")) != null) size = Integer.parseInt(((String)ht.get("size")));
    
    System.out.println("............................... baction = "+baction);
    System.out.println("............................... size = "+size);
    
    al.clear();
    for (int i=0; i<size; i++) {
        cdo = new CommonDataObject();
        cdo.setTableName("tbl_sal_notif_enfermedades");
        
        if ( ((String)ht.get("check"+i)) != null) {
            cdo.addColValue("observacion",(String)ht.get("observacion"+i));
            
            String docPath = (String)ht.get("documento");
            if (docPath != null && !docPath.trim().equals("")) {
                docPath = CmnMgr.cleanFile(docPath);
                cdo.addColValue("documento",docPath);
            }
            
            System.out.println(":thebrain :::::::::::::::::::::::::::"+docPath);
            
            if ((String)ht.get("action"+i) != null) {
                if ( ((String)ht.get("action"+i)).equalsIgnoreCase("I") ){
                    cdo.addColValue("fecha_creacion", cDateTime);
                    cdo.addColValue("usuario_creacion", userName);
                    cdo.addColValue("cod_enf", (String)ht.get("enfermedad"+i));
                    cdo.addColValue("pac_id",(String)ht.get("pacId"));
                    cdo.addColValue("admision",(String)ht.get("noAdmision"));
                    cdo.addColValue("tipo", fg);
                    cdo.setAction("I");
                } else {
                    cdo.addColValue("fecha_modificacion", cDateTime);
                    cdo.addColValue("usuario_modificacion", userName);
                    cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_enf = "+((String)ht.get("enfermedad"+i))+" and tipo = '"+fg+"'");
                    cdo.setAction("U");
                }
            }

            al.add(cdo);
        } else {
            if ((String)ht.get("action"+i) != null && ((String)ht.get("action"+i)).equalsIgnoreCase("U") ) {
                cdo.setAction("D");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_enf = "+((String)ht.get("enfermedad"+i))+" and tipo = '"+fg+"'");
                al.add(cdo);
            }
        }
    }
    
    if (al.size() < 1) {
        cdo = new CommonDataObject();
        cdo.setTableName("tbl_sal_notif_enfermedades");
        cdo.setAction("I");
        al.add(cdo);
    }
      
    if (baction.equalsIgnoreCase("Guardar") || baction.equalsIgnoreCase("Siguiente")){
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        ConMgr.setAppCtx(ConMgr.AUDIT_NOTES, "fg = "+fg);
        SQLMgr.saveList(al,true,false);
        ConMgr.clearAppCtx(null);
    }
%>
<html>
<head>
<script>
function closeWindow()
{
<%
String errCode = SQLMgr.getErrCode();
String errMsg = SQLMgr.getErrMsg();

if (errCode.equals("1"))
{
%>
	<%if(from.equals("")){%>alert('<%=errMsg%>');<%}%>
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&from=<%=from%>&fg=<%=fg%>&fp=<%=fp%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST

SecMgr.setConnection(null);
CmnMgr.setConnection(null);
SQLMgr.setConnection(null);
EvalDiagSalMgr.setConnection(null);
%>
