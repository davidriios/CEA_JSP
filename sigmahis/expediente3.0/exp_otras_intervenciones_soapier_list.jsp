<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String sql = "";
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
String condicion = request.getParameter("condicion");
String condTitle = request.getParameter("cond_title");
String cds = request.getParameter("cds");
String from = request.getParameter("from");
String diagnostico = request.getParameter("diagnostico");
String diag = request.getParameter("diag");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String armarChecksTemp = request.getParameter("armar_checks_temp"); // diagnosticos
String plansTemp = request.getParameter("plans_temp"); // plans

// search
String diagnosticoDesc = request.getParameter("diagnostico_desc");
String planDesc = request.getParameter("plan_desc");
if (diagnosticoDesc == null) diagnosticoDesc = "";
if (planDesc == null) planDesc = "";
if (diag == null) diag = "";

if (plansTemp == null) plansTemp = "0";
if (armarChecksTemp == null) armarChecksTemp = "0";

StringBuffer sbSql = new StringBuffer();
sbSql.append("select a.codigo, a.descripcion, b.cod_param, b.codigo as cod_det, decode(b.cod_param, null,'I', 'U') action from tbl_sal_otras_interv_params a, tbl_sal_otras_interv b where a.estado = 'A' and a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.cod_plan(+) = "+id+" order by a.orden");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {

%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
var forceList = true;
var forceCapitalize = true;
$(function(){
    $("#loadingmsg").remove();
    
    // control deleting
    $(".apply-del").click(function(){
        var self = $(this);
        var i = self.data('i');
        if (!this.checked) {
            $("#action"+i).val("D");
        } else {
            $("#action"+i).val("U");
        }
    });
    
    filterHTML({tblId:"tbl_content", txtId:"search", ignoreRows:{h:'1'}, blockCheckAllId:"check" });
});
</script>
<body class="body-form" style="padding-top: 0 !important;">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("condicion",condicion)%>
<%=fb.hidden("from",from)%>
<%=fb.hidden("cond_title", condTitle)%>
<%=fb.hidden("fp", fp)%>
<%=fb.hidden("armar_checks_temp", armarChecksTemp)%>
<%=fb.hidden("plans_temp", plansTemp)%>
<%=fb.hidden("diagnostico_desc", diagnosticoDesc)%>
<%=fb.hidden("plan_desc", planDesc)%>
<%=fb.hidden("diag", diag)%>
<%=fb.hidden("tmp_action", "")%>

    <table cellspacing="0" class="table table-small-font table-bordered table-striped table-hover" id="tbl_content">
        <tr>
            <td class="controls form-inline" colspan="4">
            
                <input type="text" id="search" placeholder="Buscar" autocomplete="off" class="form-control input-sm" />&nbsp;&nbsp;&nbsp;
            </td>
        </tr>
        
        <tr>
            <td colspan="4" align="right">
                <%=fb.submit("save1","Guardar",true,false)%>
				<%=fb.submit("cancel1","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
            </td>
        </tr>
        
        <%
            for (int i = 0; i < al.size(); i++) {
                CommonDataObject cdo = (CommonDataObject) al.get(i);
                %>
                <%=fb.hidden("codigo"+i, cdo.getColValue("codigo"))%>
                <%=fb.hidden("cod_det"+i, cdo.getColValue("cod_det"))%>
                <%=fb.hidden("action"+i, cdo.getColValue("action"))%>
                <%=fb.hidden("cod_param"+i, cdo.getColValue("cod_param"))%>
                <tr>
                    <td>
                        <label class="pointer">
                        <%=fb.checkbox("check"+i,cdo.getColValue("codigo"),(cdo.getColValue("action"," ").equalsIgnoreCase("U")),false, cdo.getColValue("action"," ").equalsIgnoreCase("U")?"apply-del":"",null,"",""," data-i="+i)%>
                        
                        <%=cdo.getColValue("descripcion")%>
                        </label>
                     </td>
                </tr>
        <%    
            } // for i
        %>
    </table>   
    
    <table cellspacing="0" class="table table-small-font table-bordered table-striped table-hover">
    <tr>
            <td colspan="4" align="right">
                <%=fb.submit("save2","Guardar",true,false)%>
				<%=fb.submit("cancel2","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
            </td>
        </tr>
    </table>

    
    <%=fb.hidden("realSize", ""+al.size())%>
    <%=fb.hidden("saveOption","O")%>
<%=fb.formEnd(true)%>
</div>
</div>
</body>
</html>
<%
} else {
    String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");

    int realSize = Integer.parseInt(request.getParameter("realSize")==null?"0":request.getParameter("realSize"));
    
    al.clear();

    String tmpDiag = "";
    
    for (int i = 0; i < realSize; i++) {
               
       CommonDataObject cdo = new CommonDataObject();
       cdo.setTableName("tbl_sal_otras_interv");
       
       if (request.getParameter("check"+i) != null){
           
           if (request.getParameter("action"+i).equalsIgnoreCase("I")) {
                cdo.setAutoIncCol("codigo");
                cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision);
                cdo.addColValue("usuario_creacion", (String)session.getAttribute("_userName"));
                cdo.addColValue("fecha_creacion", cDateTime);
                cdo.setAction("I");
                
                cdo.addColValue("cod_plan", id);
                cdo.addColValue("cod_param", request.getParameter("check"+i));
                cdo.addColValue("cod_diag", diag);
                cdo.addColValue("pac_id", pacId);
                cdo.addColValue("admision", noAdmision);
           }
           
           if (request.getParameter("action"+i).equalsIgnoreCase("U")) {
               cdo.setAction(request.getParameter("action"+i));
               cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_plan = "+id+" and cod_param = "+request.getParameter("cod_param"+i)+" and codigo = "+request.getParameter("cod_det"+i)+" and cod_diag = "+diag);
               cdo.addColValue("usuario_modificacion", (String)session.getAttribute("_userName"));
               cdo.addColValue("fecha_modificacion", cDateTime);
           }
           
           al.add(cdo);
       } else {
       
            if (request.getParameter("action"+i).equalsIgnoreCase("D")) {
               cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and cod_plan = "+id+" and cod_param = "+request.getParameter("cod_param"+i)+" and codigo = "+request.getParameter("cod_det"+i)+" and cod_diag = "+diag);
               cdo.setAction("D");
               al.add(cdo);
            }
       }
       
    } // for
    
    if (al.size() == 0){
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_sal_otras_interv");
		cdo.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision);
		cdo.setAction("I");
		al.add(cdo);
	}
    
    if (baction != null && baction.equalsIgnoreCase("Guardar")) {
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"Agregando otras intervenciones el plan: "+id+" y el diagnóstico: "+diag);
        SQLMgr.saveList(al, true );
        ConMgr.clearAppCtx(null);
    }
%>  
<html>
<head>
<script>
function closeWindow(){
    window.opener.location = '../expediente3.0/exp_plan_decuidado.jsp?modeSec=<%=modeSec%>&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&condicion=&noAdmision=<%=noAdmision%>&id=<%=id%>&fp=<%=fp%>&from=<%=from%>&armar_checks_temp=<%=armarChecksTemp%>&plans_temp=<%=plansTemp%>';
    window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>  
<%   
}
%>