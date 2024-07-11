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

StringBuilder sbSql = new StringBuilder();
CommonDataObject p = new CommonDataObject();

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String caja = request.getParameter("caja");
String turno = request.getParameter("turno");
String com = request.getParameter("com");

String mode = request.getParameter("mode");
boolean viewMode = false;
String displayCob = " style=\"display:none\"";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET")) {
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'MOR_CXP_USA_FACT_0'),'S') as inclFact0 from dual");
	p = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuilder();
	sbSql.append("select 'Ultimo registro de Morosidad generado el día '||fecha||decode(z.n_prov,1,' para el proveedor: '||(select cod_provedor||' - '||nombre_proveedor from tbl_com_proveedor where cod_provedor = z.proveedor),' para TODOS los Proveedores') as msg from ( select fecha, count(distinct cod_prov) as n_prov, min(cod_prov) as proveedor from tbl_cxp_morosidad where cia = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" group by fecha ) z");
	CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reporte de Morosidad- '+document.title;
function doAction()
{
var  factCero = '<%=p.getColValue("inclFact0")%>';
if(factCero=='S')document.getElementById("factCero").checked =true;
else document.getElementById("factCero").checked =false;
}

function showReporte(tipo)
{
var msg= '';


var fecha = eval('document.form0.fecha').value ;
var tipo_proveedor  = (eval('document.form0.tipo_proveedor').value);
var proveedor  = eval('document.form0.proveedor').value ;
var con_morosidad = document.form0.con_morosidad.checked?'S':'N';

if(fecha == "")
msg = 'Fecha';

if(msg == ""){
if(tipo=='D') abrir_ventana2('../cxp/print_morosidad_det.jsp?fecha='+fecha+'&tipo_proveedor='+tipo_proveedor+'&proveedor='+proveedor+'&con_morosidad='+con_morosidad);
else if(tipo=='R') abrir_ventana2('../cxp/print_morosidad_resumida.jsp?fecha='+fecha+'&tipo_proveedor='+tipo_proveedor+'&proveedor='+proveedor+'&con_morosidad='+con_morosidad);
}else alert('Introduzca Valor en el campo Fecha' );
}

function showProveedorList()
{
	abrir_ventana1('../common/search_proveedor.jsp?fp=morosidad');
}
function morosidad(){var fecha = document.form0.fecha.value ;var tipo  = document.form0.tipo_proveedor.value;var proveedor  = document.form0.proveedor.value ;var tipoFac  = document.form0.tipoFac.value;var docAn =  $("#docAn").is(":checked");var factCero =  $("#factCero").is(":checked");
if(factCero==true)factCero='S';else factCero='N';

var soloCxp =  $("#soloCxp").is(":checked");
if(soloCxp==true)soloCxp='S';else soloCxp='N';
if(tipo == '')tipo = null;else tipo = '\''+tipo+'\'';	if(proveedor == '')proveedor =null; else proveedor = '\''+proveedor+'\'';if(fecha == "")CBMSG.warning('Introduzca Valor en el campo Fecha' );
	else{CBMSG.confirm(' \nEsta seguro de generar datos para la Morosidad!!',{'cb':function(r){if(r=='Si'){
	showPopWin('../process/cxp_gen_morosidad.jsp?fp=MOR&docAn='+docAn+'&factCero='+factCero+'&soloCxp='+soloCxp+'&fecha='+fecha+'&tipo='+tipo+'&proveedor='+proveedor+'&tipoFac='+tipoFac,winWidth*.75,winHeight*.65,null,null,'');

	}}});}}
function showRptBI(tipo){
		var fecha = $('#fecha').val() ;
	var tipoProveedor  = $('#tipo_proveedor').val() || 'ALL';
	var proveedor  = $('#proveedor').val() || 'ALL';
	var pCtrlHeader = $("#pCtrlHeader").is(":checked");
	var con_morosidad = document.form0.con_morosidad.checked?'S':'N';
	if (fecha){
		 if (tipo == "D") abrir_ventana1("../cellbyteWV/report_container.jsp?reportName=cxp/rpt_morosidad_det.rptdesign&pFecha="+fecha+"&pTipoProv="+tipoProveedor+"&pCodProv="+proveedor+"&pCtrlHeader="+pCtrlHeader+'&con_morosidad='+con_morosidad);
		 else if (tipo == "R") abrir_ventana1("../cellbyteWV/report_container.jsp?reportName=cxp/rpt_morosidad_res.rptdesign&pFecha="+fecha+"&pTipoProv="+tipoProveedor+"&pCodProv="+proveedor+"&pCtrlHeader="+pCtrlHeader+'&con_morosidad='+con_morosidad);
		 else if (tipo == "D2") abrir_ventana1("../cellbyteWV/report_container.jsp?reportName=cxp/rpt_morosidad_det2.rptdesign&pFecha="+fecha+"&pTipoProv="+tipoProveedor+"&pCodProv="+proveedor+"&pCtrlHeader="+pCtrlHeader+'&con_morosidad='+con_morosidad);
		 else if (tipo == "R2") abrir_ventana1("../cellbyteWV/report_container.jsp?reportName=cxp/rpt_morosidad_res2.rptdesign&pFecha="+fecha+"&pTipoProv="+tipoProveedor+"&pCodProv="+proveedor+"&pCtrlHeader="+pCtrlHeader+'&con_morosidad='+con_morosidad);
	}
	else alert("Por favor, Introduzca Valor en el campo Fecha!");
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="REPORTE DE MOROSIDAD"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td><table align="center" width="75%" cellpadding="1" cellspacing="1">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%> <%=fb.hidden("baction","")%>
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>Reporte de Morosidad</cellbytelabel></td>
				</tr>
				<% if (cdo != null) { %><tr class="TextRow02">
					<td colspan="2" class="Link05"><font size="+1"><%=cdo.getColValue("msg")%></font></td>
				</tr><% } %>
				<tr class="TextRow01">
					<td><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
					<td><%=fb.select(ConMgr.getConnection(), "select tipo_proveedor, tipo_proveedor||' - '||descripcion from tbl_com_tipo_proveedor", "tipo_proveedor", "",false,false,0,"T")%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Proveedor</cellbytelabel>:</td>
					<td>
					<%=fb.textBox("proveedor","",false,false,false,10,"Text10",null,null)%>
					<%=fb.textBox("proveedorDesc","",false,false,true,40,"Text10",null,null)%>
					<%=fb.button("btnProv","...",true,false,"Text10",null,"onClick=\"javascript:showProveedorList()\"")%>
					&nbsp;&nbsp;&nbsp;<%=fb.checkbox("con_morosidad","S",false,false,null,null,"")%>Proveedores con Morosidad > 0?
					</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Hasta el d&iacute;a</cellbytelabel></td>
					<td>
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fecha" />
					<jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>" />
					</jsp:include>
					</td>
				</tr>
		<tr class="TextRow01">
					<td><cellbytelabel>Facturas</cellbytelabel></td>
					<td><%=fb.select("tipoFac","FC=SIN FACTURAS CONTADO, TD=TODAS LAS FACTURAS","TD",false,false,0,"",null,null,null,"")%>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label for="pCtrlHeader" class="pointer">Esconder Cabecera (Excel)?</label><input type="checkbox" id="pCtrlHeader" name="pCtrlHeader" />
			</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center">
				<label for="docAn" class="pointer">Incluir Cheques Anulados?</label><input type="checkbox" id="docAn" name="docAn" />
				<label for="factCero" class="pointer">Incluir Facturas cero?</label><input type="checkbox" id="factCero" name="factCero"/>

				<authtype type='50'><label for="soloCxp" class="pointer">Solo Pagos a CXP?</label><input type="checkbox" id="soloCxp" name="soloCxp"/></authtype>

				<%=fb.button("ejecutar","Generar",true,false,"",null,"onClick=\"javascript:morosidad()\"")%>&nbsp;&nbsp;|&nbsp;
				<%=fb.button("addReporte","Reporte Detallado",false,false,null,null,"onClick=\"javascript:showReporte('D')\"","Reporte de Morosidad Detallado")%>
				&nbsp;|&nbsp;
				<%=fb.button("addReporteBI","Detallado BI",false,false,null,null,"onClick=\"javascript:showRptBI('D')\"","Reporte de Morosidad Detallado BI")%>
				&nbsp;|&nbsp;
				<%=fb.button("addReporteR","Reporte Resumido",false,false,null,null,"onClick=\"javascript:showReporte('R')\"","Reporte de Morosidad Resumido")%>
				&nbsp;|&nbsp;
				<%=fb.button("addReporteRBI","Resumido BI",false,false,null,null,"onClick=\"javascript:showRptBI('R')\"","Reporte de Morosidad Resumido BI")%>
					</td>
				</tr>

		<tr class="TextRow01">
					<td colspan="2" align="center">
				<%=fb.button("addReporteBI2","Detallado BI No Agrupado",false,false,null,null,"onClick=\"javascript:showRptBI('D2')\"","Reporte de Morosidad Detallado BI (No Agrupado)")%>
				&nbsp;|&nbsp;
				<%=fb.button("addReporteRBI2","Resumido BI No Agrupado",false,false,null,null,"onClick=\"javascript:showRptBI('R2')\"","Reporte de Morosidad Resumido BI (No Agrupado)")%>
					</td>
				</tr>

				<%=fb.formEnd(true)%>
			</table>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
