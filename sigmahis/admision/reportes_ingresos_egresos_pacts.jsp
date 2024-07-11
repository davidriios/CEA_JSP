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
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario*** */

UserDet = SecMgr.getUserDetails(session.getId());  /* *** quitar el comentario **** */
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
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", status = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);

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
document.title = 'Reporte de Admision- '+document.title;
function doAction()
{
}

function showReporte(value, xParam)
{
  var categoria    = document.form0.categoria.value;
  var tipoAdmision = document.form0.tipoAdmision.value;
  var area         = document.form0.area.value;
  var status       = document.getElementById('status').value;
  var aseguradora  = document.form0.aseguradora.value;
  var fechaini     = document.form0.fechaini.value;
  var fechafin     = document.form0.fechafin.value;
  var pCtrlHeader  = document.form0.pCtrlHeader.checked;
	var poliza     = document.form0.poliza.value;

	if(value=="1")
	{
        if(!xParam) abrir_ventana2('../admision/print_list_ingresos_pacts.jsp?categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin);
        else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=admision/rpt_list_ingresos_pacts.rptdesign&categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(value=="2")
	{
        if(!xParam) abrir_ventana2('../admision/print_list_egresos_pacts.jsp?categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin);
        else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=admision/rpt_list_egresos_pacts.rptdesign&categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(value=="3")
	{
        if(!xParam) abrir_ventana2('../admision/print_list_ingresos_cu.jsp?fg=ING&categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin);
        else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=admision/rpt_list_ingresos_cu.rptdesign&fg=ING&categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(value=="4")
	{
        if(!xParam) abrir_ventana2('../admision/print_list_ingresos_cu.jsp?fg=EG&categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin);
        else abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=admision/rpt_list_ingresos_cu.rptdesign&fg=EG&categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&pCtrlHeader='+pCtrlHeader);
	}
	else if(value=="5")
	{
	 abrir_ventana2('../admision/print_ingresos_por_centro.jsp?categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}
	else if(value=="6")
	{
	 abrir_ventana2('../admision/print_ingresos_por_aseg_centro.jsp?categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&status='+status);
	}
	else if(value=="7")
	{
	 abrir_ventana2('../admision/print_ingresos_por_aseg.jsp?categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&status='+status+'&poliza='+poliza);
	}
	else if(value=="8")
	{
	 abrir_ventana2('../admision/print_ingresos_por_aseg_categoria.jsp?categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}
	else if(value=="9")
	{
	 abrir_ventana2('../admision/print_estadistica_ingresos.jsp?fechaini='+fechaini+'&fechafin='+fechafin+'&categoria='+categoria);
	}
	else if(value=="10")
	{
	 abrir_ventana2('../admision/print_estadistica_egresos.jsp?fechaEgrini='+fechaini+'&fechaEgrfin='+fechafin);
	}
	else if(value=="11")
	{
	 abrir_ventana2('../admision/print_estadistica_egresos_det.jsp?fechaEgrini='+fechaini+'&fechaEgrfin='+fechafin);
	}
	 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE INGRESOS / EGRESOS DE PACIENTES"></jsp:param>
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

			  <tr class="TextFilter" >
				   <td width="8">Categoría</td>
				   <td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
				   </td>
			  </tr>

				<tr class="TextFilter">
				    <td width="8%">Tipo Admisión</td>
				    <td width="92%"><%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo tipoAdmision from tbl_adm_tipo_admision_cia order by 2","tipoAdmision",tipoAdmision,"T")%>
			        </td>
			     </tr>

				<tr class="TextFilter">
				    <td width="8%">&Aacute;rea de Servicio</td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A' and si_no = 'S' and compania_unorg = "+(String)session.getAttribute("_companyId")+"","area",area,false, false, 0, "", "", "", "", "T")%>
					</td>
						
				<tr class="TextFilter">
					<td width="8%">Aseguradora</td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa /*where tipo_empresa = 2*/ order by 2","aseguradora",aseguradora,"T")%>
					</td>
				</tr>

				<tr class="TextFilter" >
				   <td width="50%">Fecha</td>
				   <td width="50%">
			Desde &nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
        	<jsp:param name="noOfDateTBox" value="1" />
        	<jsp:param name="clearOption" value="true" />
        	<jsp:param name="nameOfTBox1" value="fechaini" />
        	<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			</jsp:include>
			       Hasta &nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechafin" />
			<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			</jsp:include>
		           </td>
			  </tr>
              
              <tr class="TextFilter">
					<td width="8%">Esconder cabecera (Excel)</td>
					<td width="92%"><input type="checkbox" name="pCtrlHeader" id="pCtrlHeader"></td>
				</tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2">REPORTES DE ADMISION</td>
				</tr>

				<tr class="TextHeader">
					<td colspan="2">Generales</td>
				</tr>

				<authtype type='50'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Ingresos de Pacientes
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:showReporte(1,1)" class="Link00Bold">Excel</a>
                    </td>
				</tr>
				</authtype>

				<authtype type='51'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Egresos de Pacientes
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:showReporte(2,2)" class="Link00Bold">Excel</a>
                    </td>
				</tr>
				</authtype>

				<authtype type='52'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Ingresos de Pacientes - Datos
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:showReporte(3,3)" class="Link00Bold">Excel</a>    
                    </td>
				</tr>
				</authtype>

				<authtype type='53'>
				<tr class="TextRow01">
				   <td colspan="2"><%=fb.radio("reporte1","4",false,false,false,null,null, "onClick=\"javascript:showReporte(this.value)\"")%>Egresos de Pacientes - Datos
                   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:showReporte(4,4)" class="Link00Bold">Excel</a>
                   </td>
				</tr>
				</authtype>

				<tr class="TextHeader">
					<td colspan="2">Por Aseguradora</td>
				</tr>

				<authtype type='54'>
				<tr class="TextRow01">
				<td colspan="1"><%=fb.radio("reporte1","7",false,false,false,null,null, "onClick=\"javascript:showReporte(this.value)\"")%>Admisiones por Aseguradora</td><td>Estado<%=fb.select("status","A=ACTIVA,P=PRE ADMISIONES,S=ESPECIAL,E=ESPERA,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"A")%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;P&oacute;liza:<%=fb.textBox("poliza","",false,false,false,20)%>
				</td>
				</tr>
				</authtype>

				<authtype type='55'>
				<tr class="TextRow01">
				   <td colspan="1"><%=fb.radio("reporte1","6",false,false,false,null,null, "onClick=\"javascript:showReporte(this.value)\"")%>Admisiones por Aseguradora / Centro de Admisión</td><td>Estado<%=fb.select("status","A=ACTIVA,P=PRE ADMISIONES,S=ESPECIAL,E=ESPERA,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"A")%></td>
				</tr>
				</authtype>

				<authtype type='56'>
				<tr class="TextRow01">
				   <td colspan="2"><%=fb.radio("reporte1","8",false,false,false,null,null, "onClick=\"javascript:showReporte(this.value)\"")%>Admisiones por Aseguradora / Categoría</td>
				</tr>
				</authtype>

         
				<tr class="TextHeader">
					<td colspan="2">Por Centro de Admisi&oacute;n</td>
				</tr>

				<authtype type='57'>
				<tr class="TextRow01">
				   <td colspan="2"><%=fb.radio("reporte1","5",false,false,false,null,null, "onClick=\"javascript:showReporte(this.value)\"")%>Admisiones por Centro de admisión</td>
				</tr>
				</authtype>

				<tr class="TextHeader">
					<td colspan="2">Estad&iacute;sticas Contralor&iacute;a<br/>*** Estos reportes s&oacute;lo utilizan los par&aacute;metros de Fecha, excepto Rep. Ingresos que utiliza adicionalmente el par&aacute;metro de categor&iacute;a</td>
				</tr>

				<authtype type='58'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Resumen de Ingreso de Pacientes</td>
				</tr>
				</authtype>

				<authtype type='59'>
				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","10",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Resumen de Egreso de Pacientes</td>
					<td>&nbsp;</td>
				</tr>
				</authtype>

				<authtype type='60'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","11",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Resumen de Egreso de Pacientes - Defunciones</td>
				</tr>
				</authtype>



<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
