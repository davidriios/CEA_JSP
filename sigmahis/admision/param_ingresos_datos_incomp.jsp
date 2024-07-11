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

<!-- Desarrollado por: Tirza Monteza.                                      -->
<!-- Pantalla: Para generar reportes de admisiones con datos incompletos   -->
<!-- Reportes: SAL90035                                             -->
<!-- Clínica Hospital San Fernando                                  -->
<!-- Fecha: 13/07/2009                                              -->

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
String aseguradora = "", area = "", categoria = "", tipoAdmision = "";
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
document.title = 'Reporte de Admision - '+document.title;
function doAction()
{
}

function showReporte(value)
{
  var categoria    = eval('document.form0.categoria').value;
  var tipoAdmision = eval('document.form0.tipoAdmision').value;
  var area         = eval('document.form0.area').value;
  var aseguradora  = eval('document.form0.aseguradora').value;
  var fechaini     = eval('document.form0.fechaini').value;
  var fechafin     = eval('document.form0.fechafin').value;

	if(value=="1")
	{
 	abrir_ventana2('../admision/print_ingresos_x_centro_ubic.jsp?categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}
	else if(value=="2")
	{
	abrir_ventana2('../admision/print_ingresos_x_centro_sexo_null.jsp?categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PACIENTES CON DATOS INCOMPLETOS"></jsp:param>
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
				    <td width="8%">Area de Servicio</td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A' and si_no = 'S' union select 0,'CUARTOS DE URGENCIA'||'-'||0 from dual order by 2","area",area,"T")%>
					</td>
				</tr>
				<tr class="TextFilter">
					<td width="8%">Aseguradora</td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa where tipo_empresa = 2 order by 2","aseguradora",aseguradora,"T")%>
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
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2">REPORTES</td>
				</tr>

				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes por Centro de admisión con Ubic. geográfica incompleta</td>
				</tr>

				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","2",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes por Centro de admisión con Sexo no especificado</td>
				</tr>

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
