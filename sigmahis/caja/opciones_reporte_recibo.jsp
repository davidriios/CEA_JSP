<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String caja = "";

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reporte de Recibos- '+document.title;
function doAction()
{
}
$.extend ({
URLEncode: function (s) {
s = encodeURIComponent (s);
s = s.replace (/\~/g, '%7E').replace (/\!/g, '%21').replace (/\(/g, '%28').replace (/\)/g, '%29').replace (/\'/g, '%27');
s = s.replace (/%20/g, '+');
return s;
},
URLDecode: function (s) {
s = s.replace (/\+/g, '%20');
s = decodeURIComponent (s);
return s;
}
});
function showReporte(value)
{

var msg = '';
var fechaini = eval('document.form0.fechaini').value ;
var fechafin = eval('document.form0.fechafin').value ;
var caja = eval('document.form0.caja').value  ;
var indice = document.form0.caja.selectedIndex ;
var descCja= document.form0.caja.options[indice].text;
var turno= document.form0.turno.value;
var descCaja='';
var pos= descCja.lastIndexOf ('-');
var formaPago = document.form0.formaPago.value;
if(caja=='')descCaja ='TODAS';
else descCaja= descCja.substr(0,pos);
descCaja = $.URLEncode(descCaja);
var com = '<%=(String) session.getAttribute("_companyId")%>';
var estatus= document.form0.estatus.value;
var tipoCliente = '';
if(document.form0.tipoCliente)tipoCliente = document.form0.tipoCliente.value;

//if(value=="1" && caja == "")
//msg = ', Caja';
if(caja=="")caja="";
//msg = ', Caja';
//if(fechaini == "")msg += ', Fecha Inicial';
//if(fechafin == "")msg += ', Fecha Final';
if(value=="1")abrir_ventana2('../caja/print_recibo_fp.jsp?fp=reporte&caja='+caja+'&descCaja='+descCaja+'&fechaini='+fechaini+'&fechafin='+fechafin+'&turno='+turno);
else if(value=="-1")abrir_ventana2('../caja/print_recibos_x_caja_det.jsp?fp=reporte&fechaini='+fechaini+'&fechafin='+fechafin+'&caja='+caja+'&compania='+com+'&turno='+turno);
else if(value=="3")abrir_ventana2('../caja/print_recibos_x_distribuir_det.jsp?fp=reporte&fechaini='+fechaini+'&fechafin='+fechafin+'&caja='+caja+'&compania='+com+'&turno='+turno);
else if(value=="4")abrir_ventana2('../caja/print_recibos_x_distribuir.jsp?fp=reporte&fechaini='+fechaini+'&fechafin='+fechafin+'&caja='+caja+'&compania='+com+'&turno='+turno);
else if(value=="5")abrir_ventana2('../caja/print_recibos_x_aplicar.jsp?fp=reporte&fechaini='+fechaini+'&fechafin='+fechafin+'&caja='+caja+'&compania='+com+'&turno='+turno);
else if(value=="6")abrir_ventana2('../caja/print_recibos_x_caja_resumen.jsp?fp=reporte&fechaini='+fechaini+'&fechafin='+fechafin+'&caja='+caja+'&compania='+com+'&turno='+turno);
else if(value=="2"||value=="9"){var fg='ADM';if(value=="9")fg='SALDO';abrir_ventana2('../caja/print_recibos_sin_adm.jsp?fp=reporte&caja='+caja+'&descCaja='+descCaja+'&fechaini='+fechaini+'&fechafin='+fechafin+'&caja='+caja+'&compania='+com+'&fg='+fg);}
else if(value=="7"){var verFacturas = document.form0.verFacturas.value; abrir_ventana2('../caja/print_recibo_fp.jsp?fp=FP&caja='+caja+'&descCaja='+descCaja+'&fechaini='+fechaini+'&fechafin='+fechafin+'&turno='+turno+'&formaPago='+formaPago+'&verFacturas='+verFacturas);}
else if(value=="8")abrir_ventana2('../caja/print_facturas_aplicadas.jsp?fp=caja='+caja+'&descCaja='+descCaja+'&fechaini='+fechaini+'&fechafin='+fechafin+'&turno='+turno+'&formaPago='+formaPago);
else if(value=="10")  abrir_ventana('../caja/print_caja_preliminar.jsp?fp=reporte&fechaini='+fechaini+'&fechafin='+fechafin+'&caja='+caja+'&compania='+com+'&turno='+turno+'&estatus='+estatus);
else if(value=="11") abrir_ventana('../caja/print_resumen_depositos.jsp?fp=reporte&fechaini='+fechaini+'&fechafin='+fechafin+'&turno='+turno);
else if(value=="12") abrir_ventana('../caja/print_list_turnos.jsp?fg=REP&fechaini='+fechaini+'&fechafin='+fechafin+'&turno='+turno+'&caja='+caja);
else if(value=="13"){if(turno =='')alert('Seleccione Turno');else abrir_ventana('../caja/print_reporte_x.jsp?fp=POS&turno='+turno+'&caja='+caja);
}

}
function showTurno()
{
var fechaini =document.form0.fechaini.value ;
var caja  = document.form0.caja.value ;
var fechaHasta =document.form0.fechafin.value ;
abrir_ventana2('../caja/turnos_list.jsp?caja='+caja+'&fecha_desde='+fechaini+'&fecha_hasta='+fechaHasta+'&fp=reporte_recibo');
}

$(function() {
	$("#excel1").click(function(e) {
		var fechaini = $('#fechaini').toRptFormat() || '1970-01-01';
		var fechafin = $('#fechafin').toRptFormat() || '1970-01-01';
		var caja = $('#caja').val() || 0;
		var turno = $('#turno').val() || 0;
		var pCtrlHeader = $('#pCtrlHeader').get(0).checked;
		var descCaja = $('#caja').selText() || 'TODAS';
		var verFacturas = document.form0.verFacturas.value;
		
		abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=caja/print_recibo_fp.rptdesign&caja='+caja+'&descCaja='+descCaja+'&fDesde='+fechaini+'&fHasta='+fechafin+'&turno='+turno+'&fp=reporte&pCtrlHeader='+pCtrlHeader+'&verFacturas=N&__locale=es_PA');
	});
	
	$("#excel2").click(function(e) {
		var fechaini = $('#fechaini').val();
		var fechafin = $('#fechafin').val()
		var caja = $('#caja').val();
		var turno = $('#turno').val();
		var pCtrlHeader = $('#pCtrlHeader').get(0).checked;
		var descCaja = $('#caja').selText() || 'TODAS';
		var verFacturas = document.form0.verFacturas.value;
	
		abrir_ventana2('../caja/print_recibo_fp_html.jsp?caja='+caja+'&descCaja='+descCaja+'&fDesde='+fechaini+'&fHasta='+fechafin+'&turno='+turno+'&fp=reporte&pCtrlHeader='+pCtrlHeader+'&verFacturas=N');
	});
});

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE RECIBOS"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("estatus","")%>
			
	<tr class="TextFilter">
		<td width="50%"><cellbytelabel>Caja</cellbytelabel>	<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,DESCRIPCION||' - '||codigo FROM   tbl_cja_cajas where estado="+(String) "'A'"+"  AND compania= "+(String) session.getAttribute("_companyId")+" ORDER BY 1","caja",caja,"T")%></td>
		<td width="50%"><cellbytelabel>Desde</cellbytelabel> &nbsp;&nbsp; <jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaini" />
											<jsp:param name="valueOfTBox1" value="" />
											</jsp:include>  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <cellbytelabel>Hasta</cellbytelabel> &nbsp;&nbsp; 
											<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechafin" />
											<jsp:param name="valueOfTBox1" value="" />
											</jsp:include>
											</td>
		</tr>
		<tr class="TextFilter">
			<td width="50%">&nbsp;</td>
			<td width="50%">
      <cellbytelabel>Turno</cellbytelabel>:&nbsp;
  				<%=fb.textBox("turno","",true,false,false,5)%>
					<%=fb.button("addTurno","...",true,false,null,null,"onClick=\"javascript:showTurno()\"","Seleccionar Turno")%></td>
		</tr>
		<tr class="TextFilter">
			<td width="50%"><cellbytelabel>Forma De pago</cellbytelabel> 
			<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion||' - '||codigo, codigo from tbl_cja_forma_pago","formaPago","","S")%>
			<td width="50%">
				<label class="pointer">
					<input type="checkbox" name="pCtrlHeader" id="pCtrlHeader">
					Esconder cabecera (Excel)
				</label>
			</td>
		</tr>
		</table>
</td></tr>
		
		<tr><td>&nbsp;</td></tr>

<tr>
 <td>		
   <table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				
				<tr class="TextHeader">
							<td colspan="2" align="center"><cellbytelabel>Reportes de Recibos</cellbytelabel></td>
				</tr>
				<tr class="TextHeader"> 
					<td><cellbytelabel>Reportes Detallados</cellbytelabel></td>
					<td><cellbytelabel>Reportes Resumidos</cellbytelabel></td>
				</tr>
				<tr class="TextRow01"> 
					<td>
					<authtype type='50'><%=fb.radio("reporte1","-1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Recibos por Cajas Detallado</cellbytelabel> <br></authtype>
					<%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Recibos por Cajas</cellbytelabel>
					&nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; 
					<span style="font-weight:bold; cursor:pointer;" id="excel1">Excel</span>
					<!--<span style="font-weight:bold; cursor:pointer;" id="excel2">Excel</span>-->
					</td>
					<td><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Pendiente por Distribuir</cellbytelabel></td>
				</tr>
				<tr class="TextRow01"> 
					<td><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Pendientes por Aplicar a una Factura o Admisión</cellbytelabel></td>
					<td rowspan="2"><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Pendientes por Aplicar a una Factura o Admisión</cellbytelabel></td>
				</tr>
				<tr class="TextRow01"> 
					<td><%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Con saldo Pendientes por Aplicar</cellbytelabel></td>
				</tr>
				<tr class="TextRow01"> 
					<td><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Pendientes por Distribuir</cellbytelabel></td>
					<td><%=fb.radio("reporte1","6",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Resumido por Cajero</cellbytelabel></td>
				</tr>
				<authtype type='57'> 
				<tr class="TextRow01"> 
					<td><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Recibo por forma de pago</cellbytelabel> &nbsp;&nbsp;&nbsp;&nbsp;<%=fb.select("verFacturas","N=NO,S=SI","",false,false,0,"Text10",null,"")%><cellbytelabel>Mostrar Facturas:</cellbytelabel></td>
					<td>&nbsp;</td>
				</tr></authtype>
				<authtype type='58'> 
				<tr class="TextRow01"> 
					<td><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Facturas Aplicados con monto > al Saldo </cellbytelabel></td>
					<td>&nbsp;</td>
				</tr></authtype>
				<authtype type='59'> 
				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","10",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte Preliminar de Caja</td>
					<td>&nbsp;</td>
				</tr></authtype>
				<authtype type='60'> 
				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","11",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte para Depositos</td>
					<td>&nbsp;</td>
				</tr></authtype>
				<authtype type='61'> 
				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","12",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Turnos sin Depositos</td>
					<td>&nbsp;</td>
				</tr></authtype>
				<authtype type='62'> 
				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","13",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte X Sistema</td>
					<td>&nbsp;</td>
				</tr></authtype>
				
			<!----	
				<tr class="TextRow01"> 
					<td colspan="2" align="center"><%=fb.button("addReporte","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"","Reporte de Cajas")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				</tr>---->
			
	<%fb.appendJsValidation("if(error>0)doAction();");%>		
	<!--<tr class="TextRow02">
					<td colspan="4" align="right">
						Opciones de Guardar: 
						< <%=fb.radio("saveOption","N")%>Crear Otro
						<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
						<%=fb.radio("saveOption","C")%>Cerrar 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
</tr>	--->
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
	</tr>
</table>
</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
