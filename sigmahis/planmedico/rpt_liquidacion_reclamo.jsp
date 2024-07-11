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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
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
     var empresa = document.querySelector("#empresa").value || 'ALL';
     var tipoLiquidacion = document.querySelector("#tipo_liq").value || 'ALL';
     var categoria = document.querySelector("#categoria").value || 'ALL';
     var tipoAtencion = document.querySelector("#tipo_atencion").value || 'ALL';
     var tipoBeneficio = document.querySelector("#tipo_beneficio").value || 'ALL';
     var cod_precio = document.querySelector("#cod_precio").value || 'ALL';
     var estado = document.querySelector("#estado").value || 'ALL';
     var nombre = document.querySelector("#nombre").value || 'ALL';
     var poliza = document.querySelector("#poliza").value || 'ALL';
     var id_paciente = document.querySelector("#id_paciente").value || 'ALL';
     var fDesde = $("#fDesde").toRptFormat();
     var fHasta = $("#fHasta").toRptFormat();
     var pCtrlHeader = document.querySelector("#pCtrlHeader").checked;
     
     if ( that.data('xtra') ) thatVal = that.data('rpttype');
     
     doPrinting(thatVal, that.data('xtra'));
     
     function doPrinting(option, xtraParam) {
        if (option == '1') {
           if(!xtraParam) abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_liquidacion_reclamo.rptdesign&empresa='+empresa+'&tipo_liq='+tipoLiquidacion+'&categoria='+categoria+'&tipo_atencion='+tipoAtencion+'&tipo_beneficio='+tipoBeneficio+'&estado='+estado+'&fDesde='+fDesde+'&fHasta='+fHasta+'&cod_precio='+cod_precio+'&nombre='+nombre+'&poliza='+poliza+'&id_paciente='+id_paciente+'&pCtrlHeader='+pCtrlHeader);
           else {
							abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_liquidacion_reclamo_res.rptdesign&empresa='+empresa+'&tipo_liq='+tipoLiquidacion+'&categoria='+categoria+'&tipo_atencion='+tipoAtencion+'&tipo_beneficio='+tipoBeneficio+'&estado='+estado+'&fDesde='+fDesde+'&fHasta='+fHasta+'&cod_precio='+cod_precio+'&nombre='+nombre+'&poliza='+poliza+'&id_paciente='+id_paciente+'&pCtrlHeader='+pCtrlHeader);
					 }
        } 
        
        else if (option == '2') {
           if(!xtraParam) abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_liq_recl_cargos_hospitales.rptdesign&empresa='+empresa+'&tipo_liq='+tipoLiquidacion+'&categoria='+categoria+'&tipo_atencion='+tipoAtencion+'&tipo_beneficio='+tipoBeneficio+'&estado='+estado+'&fDesde='+fDesde+'&fHasta='+fHasta+'&cod_precio='+cod_precio+'&pCtrlHeader='+pCtrlHeader);
           else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_liq_recl_cargos_hospitales_res.rptdesign&empresa='+empresa+'&tipo_liq='+tipoLiquidacion+'&categoria='+categoria+'&tipo_atencion='+tipoAtencion+'&tipo_beneficio='+tipoBeneficio+'&estado='+estado+'&fDesde='+fDesde+'&fHasta='+fHasta+'&cod_precio='+cod_precio+'&nombre='+nombre+'&poliza='+poliza+'&id_paciente='+id_paciente+'&pCtrlHeader='+pCtrlHeader);
        }
				else if (option == '3') {
					var anio     = document.search00.anio.value;
					var mes     = document.search00.mes.value;
					var mesDesc = $( "#mes option:selected" ).text();
					 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_atencion_med_reclamo.rptdesign&empresa='+empresa+'&tipo_liq='+tipoLiquidacion+'&categoria='+categoria+'&tipo_atencion='+tipoAtencion+'&tipo_beneficio='+tipoBeneficio+'&estado='+estado+'&anioParam='+anio+'&mesParam='+mes+'&cod_precio='+cod_precio+'&nombre='+nombre+'&poliza='+poliza+'&id_paciente='+id_paciente+'&pCtrlHeader='+pCtrlHeader+'&mes_desc='+mesDesc);
        }
    }

   });
});
//to_char (l.fecha_reclamo, 'mon yyyy', 'nls_date_language=spanish') fecha_reclamo_date_dsp
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
			<td width="25%" align="right">Empresa</td>
			<td width="75%">
              <%=fb.select(ConMgr.getConnection(),"select id, nombre from tbl_pm_centros_atencion","empresa","",false, false,0,"","","","","T")%>
              
              <label class="pointer">Esconder Cabecera? <input type="checkbox" name="pCtrlHeader" id="pCtrlHeader"></label>
            </td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Tipo Liquidac&oacute;n</td>
			<td>
				<%=fb.select("tipo_liq","0=HONORARIO,1=EMPRESA,2=BENEFICIARIO","",false,false,false,0,"",null,null,null,"T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Categor&iacute;a</td>
			<td>
			<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_adm_categoria_admision","categoria","",false, false,0,"","","","","T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Tipo Atenci&oacute;n</td>
			<td>
            <%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_pm_liq_recl_tipo_atencion","tipo_atencion","",false, false,0,"","","","","T")%>
            </td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Tipo Beneficio</td>
			<td><%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_pm_liq_recl_tipo_ben","tipo_beneficio","",false, false,0,"","","","","T")%></td>
		</tr>

		<tr class="TextFilter">
			<td align="right">Estado</td>
			<td><%=fb.select("estado","A=APROBADO,P=PENDIENTE,N=ANULADO,R=RECHAZADO,D=PAGADO","",false,false,false,0,"",null,null,null,"T")%></td>
		</tr>
        <tr class="TextFilter">
 			<td width="25%" align="right">Procedimiento:</td>
			<td width="75%">
              <%=fb.select(ConMgr.getConnection(),"select l.codigo_precio, l.codigo_precio||' - ' ||l.descripcion descripcion from tbl_pm_lista_precios l where l.estado = 'A' order by 2","cod_precio","",false, false,0,"","","","","T")%>
            </td>
		</tr>
       
        <tr class="TextFilter">
			<td align="right">Fecha</td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="fDesde"/>
				<jsp:param name="valueOfTBox1" value="<%=cDate%>"/>
				<jsp:param name="nameOfTBox2" value="fHasta"/>
				<jsp:param name="valueOfTBox2" value="<%=cDate%>"/>
                <jsp:param name="clearOption" value="true"/>
				</jsp:include>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Para reportes Resumidos: &nbsp;A&ntilde;o <%=fb.textBox("anio",anio,false,false,false,5,4,"Text10",null,null)%><cellbytelabel>Mes:</cellbytelabel>
					 <%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes, true, false, false, 0,"","","",null,"S")%>
            </td>
		</tr>
		<tr class="TextFilter">
			<td align="right">P&oacute;liza</td>
			<td><%=fb.textBox("poliza","",false,false,false,10,100,"Text10","","")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Nombre</td>
			<td><%=fb.textBox("nombre","",false,false,false,50,100,"Text10","","")%></td>
		</tr>
		<tr class="TextFilter">
			<td align="right">Id. Paciente</td>
			<td><%=fb.textBox("id_paciente","",false,false,false,10,100,"Text10","","")%></td>
		</tr>
	
		<tr class="TextRow01">
			<td align="right">Tipo Reporte</td>
			<td>
				<authtype type='50'>
                    <label class="pointer"><%=fb.radio("rptType","1",false,false,false,null,null,null)%>Atenciones M&eacute;dicas</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="pointer xtra Link00Bold" data-xtra='1' data-rpttype="1">Resumido</span><br>
                    <label class="pointer"><%=fb.radio("rptType","2",false,false,false,null,null,null)%>Cargos de Hospitales</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="pointer xtra Link00Bold" data-xtra='2' data-rpttype="2"></span>
											<span class="pointer xtra Link00Bold" data-xtra='3' data-rpttype="3">Resumido</span>
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