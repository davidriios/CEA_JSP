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
     var tipoCargo = document.querySelector("#tipo_cargo").value || 'ALL';
     var tipoPlan = document.querySelector("#tipo_plan").value || 'ALL';
     var contrato = document.querySelector("#contrato").value;
     var pCtrlHeader = document.querySelector("#pCtrlHeader").checked;
     var noContrato = 'ALL';
     var noSecuencia = 'ALL';
     
     if ( that.data('xtra') ) thatVal = that.data('rpttype');
     if (contrato) {
        contrato = contrato.split("-");
        noContrato = contrato[0] || 'ALL';
        noSecuencia = $.trim(contrato[1]) || 'ALL';
     }
     
     doPrinting(thatVal, that.data('xtra'));
     
     function doPrinting(option, xtraParam) {
        if (option == '1') {
           if(!xtraParam) abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_miembros_dependientes_eligibles.rptdesign&pCtrlHeader='+pCtrlHeader+'&tipo_plan='+tipoPlan+'&tipo_cargo='+tipoCargo+'&no_contrato='+noContrato+'&no_secuencia='+noSecuencia);
        }        
    }

   });
});

var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();chkRptType();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,350);}
function chkRptType(idx){if(idx==undefined||idx==null||idx=='')idx=0;$('input:radio[name=rptType]').attr('checked',false);$('input:radio[name=rptType]:nth('+idx+')').attr('checked',true);}

allowWriting({
    inputs: "#contrato, #nombre_ben",
    listener: "keydown",
    keycode: 9,
    keyboard: true,
    iframe: "#preventPopupFrame",
    searchParams: {
        contrato:"contrato", nombre_ben: "nombre"
    },
    baseUrls: {
        contrato: "../common/search_paciente_pm.jsp?fp=rpt_elegibles",
        nombre_ben: "../common/search_paciente_pm.jsp?fp=rpt_elegibles",
    } 
});
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
			<td width="25%" align="right">Cargos por</td>
			<td width="75%">
              <%=fb.select("tipo_cargo","H=HOSPITALIZACION,C=CONSULTAS","",false,false,false,0,"",null,null,null,"T")%>
              
              <label class="pointer">Esconder Cabecera? <input type="checkbox" name="pCtrlHeader" id="pCtrlHeader"></label>
            </td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Tipo Plan</td>
			<td>
				<%=fb.select("tipo_plan","1=PLAN REGULAR,2=PLAN TERCERA EDAD","",false,false,false,0,"",null,null,null,"T")%>
			</td>
		</tr>
        
        <tr class="TextFilter">
			<td align="right">Beneficiario</td>
			<td>
				<%=fb.textBox("contrato","",false,false,false,10)%>
                <%=fb.textBox("nombre_ben","",false,false,false,30)%>&nbsp;&nbsp;***&nbsp;<span class="BlackTextBold">(Buscar usado TAB)</span>
			</td>
		</tr>
        
        <tr class="TextFilter" >
             <td colspan="2">
                <iframe id="preventPopupFrame" name="preventPopupFrame" frameborder="0" width="99%" height="200" src="" scroll="no" style="display:none;"></iframe>
             </td>
        </tr>
		
		<tr class="TextRow01">
			<td align="right">Tipo Reporte</td>
			<td>
				<authtype type='50'>
                    <label class="pointer"><%=fb.radio("rptType","1",false,false,false,null,null,null)%>Miembros y dependientes elegibles</label>
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