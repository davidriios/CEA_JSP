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
<jsp:useBean id="iDetTemp" scope="session" class="java.util.Hashtable" />

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
String armarChecksTemp = request.getParameter("armar_checks_temp");
String plansTemp = request.getParameter("plans_temp");
String tipo = request.getParameter("tipo");
String codDiag = request.getParameter("cod_diag");
String rearmar = request.getParameter("rearmar");

if (tipo == null) tipo = "TTT";
if (codDiag == null) codDiag = "0";
if (plansTemp == null) plansTemp = "0";
if (armarChecksTemp == null) armarChecksTemp = "0";
if (rearmar == null) rearmar = "";

StringBuffer sbSql = new StringBuffer();
sbSql.append("select codigo, descripcion, status, codigo_condicion, cod_diag, tipo from tbl_sal_soapier_cond_detalle where codigo_condicion in (");
sbSql.append(plansTemp);
sbSql.append(") and tipo = '");
sbSql.append(tipo);
sbSql.append("' and cod_diag = ");
sbSql.append(codDiag);
sbSql.append(" and status = 'A' order by codigo ");

al = SQLMgr.getDataList(sbSql.toString());

CommonDataObject cdo = new CommonDataObject();

sbSql = new StringBuffer();
sbSql.append("select codigo, descripcion, decode('");
sbSql.append(tipo);
sbSql.append("','MET','META MEDIBLE','NEC','NECESIDADES ALTERADAS','INT', 'INTERVENCIONES','MOT','MOTIVOS / CAUSAS') tipo_desc from tbl_sal_soapier_diagnosticos where estado = 'A' and codigo = ");
sbSql.append(codDiag);

cdo = SQLMgr.getData(sbSql.toString());

System.out.println("..................................... iDetTemp.size() = "+iDetTemp.size());

if (request.getMethod().equalsIgnoreCase("GET")) {

%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
$(function(){
    $("#loadingmsg").remove();
    
    $("#save1, #save2").click(function(){
        var checks = $(".check:checked").map(function(){
            return this.value;
        }).get().join();
        $("#tmp_check").val(checks);
        $("#form0").submit();
    });
});
var forceList = true;
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
<%=fb.hidden("cod_diag", codDiag)%>
<%=fb.hidden("tipo", tipo)%>
<%=fb.hidden("rearmar", rearmar)%>
<%=fb.hidden("tmp_check", "")%>
    
    <table cellspacing="0" class="table table-small-font table-bordered table-striped table-hover">
        <tr class="bg-headtabla">
            <td colspan="3">
                <%=cdo.getColValue("descripcion")%>&nbsp;::&nbsp;<%=cdo.getColValue("tipo_desc")%>
            </td>
        </tr>
        <tr class="bg-headtabla2">
            <td>ID</td>
            <td>Descripci&oacute;n</td>
            <td>&nbsp;</td>
        </tr>
        
        <%
        Vector vDetTemp = CmnMgr.str2vector(iDetTemp.get(tipo+"_"+codDiag+"_"+pacId+"_"+noAdmision)!=null ? ""+iDetTemp.get(tipo+"_"+codDiag+"_"+pacId+"_"+noAdmision) : "");
        
        for (int i = 0; i < al.size(); i++){
            cdo = (CommonDataObject) al.get(i);
            boolean chectIt = CmnMgr.vectorContains(vDetTemp, cdo.getColValue("codigo"));
        %>
            <tr class="pointer">
                <td><%=cdo.getColValue("codigo")%></td>
                <td>
                    <label for="check<%=i%>" class="pointer">
                        <%=cdo.getColValue("descripcion")%>
                    </label>    
                </td>
                <td>
                    <%=fb.checkbox("check"+i,cdo.getColValue("codigo"),chectIt,false,"check",null,"","", "")%>
                </td>
            </tr>
        <%}%>
        
        <tr>
            <td colspan="3" align="right">
                <%=fb.button("save2","Guardar",true,false)%>
				<%=fb.button("cancel2","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
            </td>
        </tr>
        
    </table>

<%=fb.formEnd(true)%>
</div>
</div>
</body>
</html>
<%
} else {
    iDetTemp.put(request.getParameter("tipo")+"_"+request.getParameter("cod_diag")+"_"+pacId+"_"+noAdmision,request.getParameter("tmp_check"));
%>
<html>
<head>
<script>
function closeWindow(){
    window.opener.location = '../expediente3.0/exp_plan_decuidado.jsp?modeSec=<%=modeSec%>&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&desc=<%=desc%>&pacId=<%=pacId%>&condicion=&noAdmision=<%=noAdmision%>&id=0&fp=&from=<%=from%>&armar_checks_temp=<%=armarChecksTemp%>&plans_temp=<%=plansTemp%>&armado_final=Y&force_agregar=Y&rearmar=<%=rearmar%>';
    window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%}%>