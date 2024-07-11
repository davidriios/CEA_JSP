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
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String fg = request.getParameter("fg");
if (mode == null) mode = "add";
if (fg == null) fg = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script>
document.title = 'Ingreso por Centro de Servicio - '+document.title;
function doAction(){}

$(document).ready(function(){

  $(".reportRadio").click(function(c){
	  var area = $("#area").val() || 'ALL';
	  //var ts = $("#ts").val() || 'ALL';
	  var fechaini = $("#fechaini").toRptFormat();
	  var fechafin = $("#fechafin").toRptFormat();
	  //ar categoria = $("#categoria").val() || 'ALL';
	  //var cargosFact = $("#cargosFact").val() || 'ALL';
	  //var tipoFecha = $("#tipoFecha").val();
	  var aseguradora = $("#aseguradora").val() || 'ALL';
	  var ctas_facturada = $("#ctas_facturada").val();// || 'ALL';
	  var fecha_cancela = $("#fecha_cancela").val();// || 'ALL';
	  var fecha_rec = $("#fecha_rec").val();// || 'ALL';
	  var value = $(this).val();
	  var pacId = $("#pacId").val();
	  var ctrlHeader = false;
  
	  ctrlHeader = $("#ctrlHeader").is(":checked");
	  
		if(value==1) abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/fact_proced_x_cds.rptdesign&pCds='+area+'&fDesde='+fechaini
+'&fHasta='+fechafin+'&pCtrlHeader='+ctrlHeader+'&pAseg='+aseguradora+'&ctasFactParam='+ctas_facturada+'&fechaCancelaParam='+fecha_cancela+'&pPacId='+pacId+'&pValFechaRec='+fecha_rec);
		else if(value==2) abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/adm_fact_proced_x_cds.rptdesign&pCds='+area+'&fDesde='+fechaini
+'&fHasta='+fechafin+'&pCtrlHeader='+ctrlHeader+'&pAseg='+aseguradora+'&ctasFactParam='+ctas_facturada+'&fechaCancelaParam='+fecha_cancela+'&pPacId='+pacId+'&pValFechaRec='+fecha_rec);
  });
 
});
function showList(type){if(type=='pac'){abrir_ventana1('../common/search_paciente.jsp?fp=reporte_cpt_cds');}}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="POR CENTRO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
<tr>
 <td>
   <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

				<tr class="TextFilter">
				    <td width="30%"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
					<td width="70%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A'  and compania_unorg = "+(String)session.getAttribute("_companyId")+" order by descripcion","area",area,"")%>
					</td>
				</tr>
				<tr class="TextFilter">
				   <td width="30%"><cellbytelabel>Fecha</cellbytelabel></td>
				   <td width="70%">
						<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="2" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fechaini" />
							<jsp:param name="valueOfTBox1" value="<%=(fg.trim().equals("CA"))?"":cDateTime%>" />
							<jsp:param name="nameOfTBox2" value="fechafin" />
							<jsp:param name="valueOfTBox2" value="<%=(fg.trim().equals("CA"))?"":cDateTime%>" />
						</jsp:include>
		           </td>
			  </tr>
				<tr class="TextFilter">
				   <td width="30%"><cellbytelabel>Cuentas con saldo 0?:</cellbytelabel></td>
				   <td width="70%">
					 <%=fb.select("ctas_facturada","S=Si,N=No","", false, false, 0, "", "", "", "", "T")%>
					 Usa Fecha Cancelaci&oacute;n Factura:
					 <%=fb.select("fecha_cancela","N=No,S=Si","", false, false, 0, "", "", "", "", "")%>
					 Vadidar Fecha Recibo:
					 <%=fb.select("fecha_rec","S=Si,N=No","")%>
		           </td>
			  </tr>
			  <tr class="TextFilter">
				   <td width="30%"><cellbytelabel>Aseguradora:</cellbytelabel></td>
				   <td width="70%"><%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa order by 2","aseguradora",aseguradora,"T")%>
		           </td>
			  </tr>
			   <tr class="TextFilter">
				   <td><cellbytelabel>Paciente:</cellbytelabel></td>
				   <td>
						<%=fb.textBox("pacId","",false,false,true,10,null,null,"onDblClick=\"javascript:setFormFieldsBlank(this.form.name,'pacId,nombre')\"")%>
						<%=fb.textBox("nombre","",false,viewMode,true,60)%>
						<%=fb.button("selPac","...",true,false,null,null,"onClick=\"javascript:showList('pac')\"","seleccionar Paciente")%>
		      </td>
			  </tr>
			  <tr class="TextFilter">
				   <td width="30%"><cellbytelabel>Esconder Cabecera (Excel):</cellbytelabel></td>
				   <td width="70%"><%=fb.checkbox("ctrlHeader","")%>
		           </td>
			  </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTES</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2">
						<%=fb.radio("report","1",false,false,false,"reportRadio",null,"")%>
						<cellbytelabel>Procedimientos por CDS</cellbytelabel>
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2">
						<%=fb.radio("report","2",false,false,false,"reportRadio",null,"")%>
						<cellbytelabel>Procedimientos por CDS por Admisi&oacute;n:</cellbytelabel>
					</td>
				</tr>

<%=fb.formEnd(true)%>
</table>
	</td>
	</tr>
</table>
</td>
	</tr>
	</td>
	</tr>

</table>
</body>
</html>
<%
}//GET
%>