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

  $("input[name^='report']" ).click(function(c){
	  var area = $("#area").val() || 'ALL';
	  var ts = $("#ts").val() || 'ALL';
	  var fechaini = $("#fechaini").toRptFormat();
	  var fechafin = $("#fechafin").toRptFormat();
	  var categoria = $("#categoria").val() || 'ALL';
	  var cargosFact = $("#cargosFact").val() || 'ALL';
	  var tipoFecha = $("#tipoFecha").val();
	  var aseguradora = $("#aseguradora").val() || 'ALL';
		var areaDesc = $("#area option:selected").text();
		var asegDesc = $("#aseguradora option:selected").text();
	  var value = "";
	  var ctrlHeader = false;
	  var proc = $("#codProc").val();
      var descProc =' POR PROCEDIMIENTO:  '+$("#descProc").val();
	  if(proc =="")descProc ="";
	  var pacId = $("#pacId").val();
	  
      value = $(this).val();
	  ctrlHeader = $("#ctrlHeader").is(":checked");
	  
	  if(value=="1"){
		abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_ingresos_x_centro_lis_ris.rptdesign&pCat='+categoria+'&pArea='+area+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pTipoFecha='+tipoFecha+'&pTs='+ts+'&pCtrlHeader='+ctrlHeader+'&pRptType=R&pAseg='+aseguradora+'&pCargosFact='+cargosFact+'&pCodProc='+proc+'&pDescProc='+descProc+'&pPacId='+pacId+'&pAreaDesc='+areaDesc+'&pAsegDesc='+asegDesc);
	   }
	   else if (value=="2"){
	     abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_ingresos_x_centro_lis_ris_det_n.rptdesign&pCat='+categoria+'&pArea='+area+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pTipoFecha='+tipoFecha+'&pTs='+ts+'&pCtrlHeader='+ctrlHeader+'&pRptType=D&pAseg='+aseguradora+'&pCargosFact='+cargosFact+'&pCodProc='+proc+'&pDescProc='+descProc+'&pPacId='+pacId+'&pAreaDesc='+areaDesc+'&pAsegDesc='+asegDesc);
	   }
	   else if (value=="3"){
	     abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_ingresos_x_centro_lis_ris_det.rptdesign&pCat='+categoria+'&pArea='+area+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pTipoFecha='+tipoFecha+'&pTs='+ts+'&pCtrlHeader='+ctrlHeader+'&pRptType=D&pAseg='+aseguradora+'&pCargosFact='+cargosFact+'&pCodProc='+proc+'&pDescProc='+descProc+'&pPacId='+pacId+'&pAreaDesc='+areaDesc+'&pAsegDesc='+asegDesc);
	   }
  });
 
});
function showList(type){if(type=='proc'){var cds=document.form0.area.value;if(cds !='')abrir_ventana1('../common/sel_procedimiento.jsp?fp=reporte_ris_lis&cs='+cds);else  CBMSG.warning('Seleccione Centro de Servicio');}else if(type=='pac'){abrir_ventana1('../common/search_paciente.jsp?fp=reporte_ris_lis');}}
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
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A'  and compania_unorg = "+(String)session.getAttribute("_companyId")+" and flag_cds in('LAB','IMA') order by flag_cds","area",area,"")%>
					</td>
				</tr>
				<tr class="TextFilter">
				    <td width="30%"><cellbytelabel>Tipo de Servicio</cellbytelabel></td>
					<td width="70%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_tipo_servicio where compania = "+(String) session.getAttribute("_companyId")+"  and codigo = '07' order by 2","ts","","")%>
					</td>
				</tr>
			    <tr class="TextFilter">
				   <td width="30%">Categor&iacute;a</td>
				   <td width="70%">
						<%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
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
				   <td width="30%"><cellbytelabel>Tipo de Fecha</cellbytelabel></td>
				   <td width="70%"><%=fb.select("tipoFecha","C=CARGO,CC=CREACION","CC",false,false,0,"Text10",null,null,null,"")%>
		           </td>
			  </tr>
			  <tr class="TextFilter" >
				   <td><cellbytelabel>Cargos:</cellbytelabel></td>
				   <td><%=fb.select("cargosFact","S=FACTURADOS,N=NO FACTURADOS","",false,false,0,"Text10",null,null,null,"T")%></td>
			  </tr>
			  <tr class="TextFilter">
				   <td width="30%"><cellbytelabel>Aseguradora:</cellbytelabel></td>
				   <td width="70%"><%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa where tipo_empresa = 2 order by 2","aseguradora",aseguradora,"T")%>
		           </td>
			  </tr>
			   <tr class="TextFilter">
				   <td width="30%"><cellbytelabel>Procedimiento:</cellbytelabel></td>
				   <td width="70%"><%=fb.textBox("codProc","",false,false,true,10,null,null,"onDblClick=\"javascript:setFormFieldsBlank(this.form.name,'codProc,descProc')\"")%>
					<%=fb.textBox("descProc","",false,viewMode,true,60)%>
					<%=fb.button("procedimiento","...",true,false,null,null,"onClick=\"javascript:showList('proc')\"","seleccionar Procedimiento")%>
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
						<authtype type='50'><%=fb.radio("report","1",false,false,false,null,null,"")%>
						<cellbytelabel>Ingresos RIS/LIS Resumido</cellbytelabel></authtype>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<authtype type='51'>
						<%=fb.radio("report","2",false,false,false,null,null,"")%>
						<cellbytelabel>Ingresos RIS/LIS Detallado [ Por ADM]</cellbytelabel></authtype>
						<authtype type='52'>
						<%=fb.radio("report","3",false,false,false,null,null,"")%>
						<cellbytelabel>Ingresos RIS/LIS Detallado </cellbytelabel></authtype>
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