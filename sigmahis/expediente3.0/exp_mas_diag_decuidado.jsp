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
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String armarChecksTemp = request.getParameter("armar_checks_temp"); // diagnosticos
String plansTemp = request.getParameter("plans_temp"); // plans

// search
String diagnosticoDesc = request.getParameter("diagnostico_desc");
String planDesc = request.getParameter("plan_desc");
if (diagnosticoDesc == null) diagnosticoDesc = "";
if (planDesc == null) planDesc = "";

if (plansTemp == null) plansTemp = "0";
if (armarChecksTemp == null) armarChecksTemp = "0";

StringBuffer sbSql = new StringBuffer();

// diagnosticos
sbSql.append("select d.codigo, d.codigo_condicion, d.descripcion, c.descripcion as plann, c.codigo condicion from tbl_sal_soapier_diagnosticos d, tbl_sal_soapier_condicion c where d.estado = 'A' and c.codigo = d.codigo_condicion /*and d.codigo_condicion in(");
sbSql.append(plansTemp);
sbSql.append(")*/ and d.codigo not in(");
sbSql.append(armarChecksTemp);
sbSql.append(")");

if (!diagnosticoDesc.trim().equals("")) {
  sbSql.append(" and d.descripcion like '%");
  sbSql.append(diagnosticoDesc);
  sbSql.append("%'");
}

if (!planDesc.trim().equals("")) {
  sbSql.append(" and c.codigo = ");
  sbSql.append(planDesc);
}

sbSql.append(" order by c.codigo, d.codigo ");

if (!diagnosticoDesc.trim().equals("") || !planDesc.trim().equals("")) {
    al = SQLMgr.getDataList(sbSql.toString());
}

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
    
    $(".toggle-det").click(function(){
        var self = $(this);
        var diag = self.data('diag');
        $("#content-"+diag+"-MOT").toggle();
        $("#content-"+diag+"-MET").toggle();
        $("#content-"+diag+"-INT").toggle();
        $("#content-"+diag+"-NEC").toggle();
    });
});

function buscar() {
    var diagnosticoDesc = $("#diagnostico_desc_search").val();
    var planDesc = $("#plan_desc_search").val() || '';
    window.location = '../expediente3.0/exp_mas_diag_decuidado.jsp?seccion=<%=seccion%>&modeSec=<%=modeSec%>&mode=<%=mode%>&fg=<%=fg%>&desc=<%=desc%>&condicion=<%=condicion%>&id=<%=id%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&armar_checks_temp=<%=armarChecksTemp%>&plans_temp=<%=plansTemp%>&from=<%=from%>&diagnostico_desc='+diagnosticoDesc+'&plan_desc='+planDesc;
}
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

    <table cellspacing="0" class="table table-small-font table-bordered table-striped table-hover">
        <tr>
            <td class="controls form-inline" colspan="4">
            
                Diagn&oacute;stico:
                <%=fb.textBox("diagnostico_desc_search","",false,false,false,0,"form-control input-sm",null,null)%>
                <!--&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                Plan:
                <%//=fb.textBox("plan_desc_search","",false,false,false,0,"form-control input-sm",null,null)%>-->
                
                <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_sal_soapier_condicion where estatus = 'A' and codigo not in("+plansTemp+") order by 1","plan_desc_search",planDesc,false,false,0,"form-control input-sm",null,"",null,"S")%>
                
                
                <button type="button" class="btn btn-inverse btn-sm" onclick="buscar()">IR</button>
                
            </td>
        </tr>
        
        <%
        String groupPlan = "";
        int realSize = 0;
        
        for (int i = 0; i < al.size(); i++) {
            CommonDataObject cdo = (CommonDataObject) al.get(i);
            
            ArrayList alH = SQLMgr.getDataList("select distinct orden, decode(tipo,'MET','META MEDIBLE','NEC','NECESIDADES ALTERADAS','INT', 'INTERVENCIONES','MOT','MOTIVOS / CAUSAS') tipo_desc, tipo from tbl_sal_soapier_cond_detalle where codigo_condicion in("+cdo.getColValue("condicion")+") and cod_diag = "+cdo.getColValue("codigo")+" order by  1");
            
            if (!groupPlan.equalsIgnoreCase(cdo.getColValue("plann"))){
            %>    
                <tr class="bg-headtabla">
                    <td colspan="4"><%=cdo.getColValue("plann")%></td>
                </tr>
            <%
            } // grouping
            
            %>
                <tr class="pointer toggle-det" data-diag="<%=cdo.getColValue("codigo")%>">
                    <td colspan="4">[<%=cdo.getColValue("codigo")%>]&nbsp;<%=cdo.getColValue("descripcion")%></td>
                </tr>
                
                
                <%
                for (int h = 0; h<alH.size(); h++) {
                    CommonDataObject cdoH = (CommonDataObject) alH.get(h);
                    
                    sbSql = new StringBuffer();
                    sbSql.append("select codigo, descripcion, status, codigo_condicion, cod_diag, tipo from tbl_sal_soapier_cond_detalle where codigo_condicion = ");
                    sbSql.append(cdo.getColValue("condicion"));
                    sbSql.append(" and tipo = '");
                    sbSql.append(cdoH.getColValue("tipo"));
                    sbSql.append("' and cod_diag = ");
                    sbSql.append(cdo.getColValue("codigo"));
                    sbSql.append(" and status = 'A' order by codigo ");

                    ArrayList alD = SQLMgr.getDataList(sbSql.toString());
                %>
                
                    <td style="vertical-align:top !important; display:none" width="25%" id="content-<%=cdo.getColValue("codigo")%>-<%=cdoH.getColValue("tipo")%>"><!-- detalle header -->
                        <table cellspacing="0" class="table table-bordered">
                            <td>
                                <span class="bg-headtabla2"><%=cdoH.getColValue("tipo_desc")%></span>
                                
                                <table cellspacing="0" class="table table-small-font table-bordered table-hover">
                                    
                                    <%
                                    for(int d = 0; d < alD.size(); d++){
                                        CommonDataObject cdoD = (CommonDataObject) alD.get(d);
                                        String tipo = cdoD.getColValue("tipo");
                                        String cDiag = cdoD.getColValue("cod_diag");
                                        String domName = tipo+"_"+cDiag+"_"+cdoD.getColValue("codigo");
                                    %>
                                    
                                    <%=fb.hidden("codigo"+realSize, cdoD.getColValue("codigo"))%>
                                    <%=fb.hidden("tipo"+realSize, tipo)%>
                                    <%=fb.hidden("cod_diag"+realSize, cDiag)%>
                                    <%=fb.hidden("codigo_condicion"+realSize, cdoD.getColValue("codigo_condicion"))%>
                                
                                
                                    <tr>
                                        <td>
                                            <label class="pointer">
                                            
                                            <%=fb.checkbox(domName,cdoD.getColValue("codigo"),false,false, "cant-change",null,"","")%>
                                            
                                            <%=cdoD.getColValue("descripcion")%>
                                            </label>
                                         </td>
                                    </tr>
                                    
                                    <%
                                    realSize++;
                                    } // for d
                                    %>
                                </table>
                                
                                
                                
                                
                                
                                
                                
                            </td>
                        </table>
                    </td> <!-- detalle header -->
                    
                    <% if( h > 0 && h%alH.size() == 0){ %>
                        </tr><tr>
                    <%}%>
                
                
                <%
                } // for h
                %>

            <%

            groupPlan = cdo.getColValue("plann");
        } // for
        
        %>
        
        <tr>
            <td colspan="4" align="right">
                <%=fb.hidden("saveOption","O")%>
                <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.submit("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
            </td>
        </tr>
        
        
    </table>    
    <%=fb.hidden("realSize", ""+realSize)%>
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
       
       String tipo = request.getParameter("tipo"+i);
       String codigo = request.getParameter("codigo"+i);
       String codDiag = request.getParameter("cod_diag"+i);
       String codCondicion = request.getParameter("codigo_condicion"+i);
       String domName = tipo+"_"+codDiag+"_"+codigo;
       
       if (request.getParameter(domName) != null){
           CommonDataObject cdo = new CommonDataObject();
           cdo.setTableName("tbl_sal_plan_cuidado_det");
           
           cdo.setAction("I");
           cdo.addColValue("cod_plan", id);
           cdo.addColValue("tipo", tipo);
           cdo.addColValue("cod_param", request.getParameter(domName));
           cdo.addColValue("cod_diag", codDiag);
           cdo.addColValue("pac_id", pacId);
           cdo.addColValue("admision", noAdmision);
       
           al.add(cdo);
           
           if (!tmpDiag.equals(codDiag)) {
                armarChecksTemp += ","+codDiag;
           }
           plansTemp += ","+codCondicion;
           
           tmpDiag = codDiag;
       }
       
    } // for
    
    if (al.size() == 0){
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_sal_plan_cuidado_det");
		cdo.setWhereClause("pac_id = "+request.getParameter("pacId"));
		cdo.setAction("I");
		al.add(cdo);
	}
    
    CommonDataObject cdoH = new CommonDataObject();
    cdoH.setTableName("tbl_sal_plan_cuidado");
    cdoH.setAction("U");
    cdoH.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and id = "+id);
    cdoH.addColValue("fecha_modificacion", cDateTime);
    cdoH.addColValue("usuario_modificacion", (String)session.getAttribute("_userName"));
    cdoH.addColValue("cod_diag", armarChecksTemp);
    cdoH.addColValue("cod_condicion", plansTemp);
    
    if (baction != null && baction.equalsIgnoreCase("Guardar")) {
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"Agregando diagnosticos después de haber guardado el plan: "+id);
        SQLMgr.save(cdoH, al, true ,true, true, true);
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