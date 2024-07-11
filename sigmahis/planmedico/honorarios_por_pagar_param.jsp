<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String companyId = (String) session.getAttribute("_companyId");
if(request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario de Artículos  - '+document.title;
$(document).ready(function(){
   $('input:radio[name=rptType], .xtra').click(function(c){
     var that = $(this);
     var thatVal = that.val();
     var medico = document.querySelector("#medico").value || 'ALL';
     var empresa = document.querySelector("#empresa").value || '0';
     var pCtrlHeader = document.querySelector("#pCtrlHeader").checked;
     var fechaDesde = $("#fecha_f").toRptFormat();
     var fechaHasta = $("#fecha_t").toRptFormat();
     
     
     if ( that.data('xtra') ) thatVal = that.data('rpttype');
     
     doPrinting(thatVal, that.data('xtra'));
     function doPrinting(option, xtraParam) {
        if (!fechaDesde || !fechaHasta) {
          CBMSG.error("POr favor escoge un rango de fecha!");
          return;
        } 
        if (option == '1') {
           if(!xtraParam) abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_honorarios_x_pagar.rptdesign&pCtrlHeader='+pCtrlHeader+'&pMedico='+medico+'&pEmpresa='+empresa+'&fDesde='+fechaDesde+'&fHasta='+fechaHasta);
        }        
    }

   });
});

var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();chkRptType();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,350);}
function chkRptType(idx){if(idx==undefined||idx==null||idx=='')idx=0;$('input:radio[name=rptType]').attr('checked',false);$('input:radio[name=rptType]:nth('+idx+')').attr('checked',true);}

</script>
</head>
<body onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value=""></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<tr>
	<td class="TableBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
			<td width="25%" align="right">M&eacute;dico</td>
			<td width="75%">
              <%=fb.select(ConMgr.getConnection(), "select codigo, primer_nombre||' '||primer_apellido nombre from tbl_adm_medico order by 2", "medico", "",false,false,0,"",null,"","","S")%>
              <label class="pointer">Esconder Cabecera? <input type="checkbox" name="pCtrlHeader" id="pCtrlHeader"></label>
            </td>
		</tr>
        <tr class="TextFilter">
			<td width="25%" align="right">Sociedad M&eacute;dica</td>
			<td width="75%">
              <%=fb.select(ConMgr.getConnection(), "select codigo, nombre from tbl_adm_empresa where grupo_empresa = get_sec_comp_param("+companyId+",'LIQ_RECL_TIPO_EMP') order  by 2", "empresa", "",false,false,0,"",null,"","","S")%>
            </td>
		</tr>
        
        <tr class="TextFilter">
			<td width="25%" align="right"><cellbytelabel id="2">Fecha</cellbytelabel></td>
			<td width="75%">
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="nameOfTBox1" value="fecha_f" />
			<jsp:param name="valueOfTBox1" value="<%=cDate%>" />
			<jsp:param name="nameOfTBox2" value="fecha_t" />
			<jsp:param name="valueOfTBox2" value="<%=cDate%>" />
			</jsp:include>
            </td>
		</tr>
		
		<tr class="TextRow01">
			<td align="right">Tipo Reporte</td>
			<td>
				<authtype type='50'>
                    <label class="pointer"><%=fb.radio("rptType","1",false,false,false,null,null,null)%>Honorarios por pagar</label>
                </authtype>
			</td>
		</tr>
		</table>
</div>
</div>

	</td>
</tr>
<%=fb.formEnd()%>
</table>
</body>
</html>
<% } %>