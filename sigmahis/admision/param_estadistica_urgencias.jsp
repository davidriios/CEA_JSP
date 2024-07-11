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

<!-- Desarrollado por: Tirza Monteza                                -->
<!-- Pantalla: "Estadisticas de Cto de URgencias"                   -->
<!-- Reportes:                                                      -->
<!-- Forma:       FAC96017                                          -->
<!-- Clínica Hospital San Fernando                                  -->
<!-- Fecha: 03/08/2010                                              -->

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
document.title = 'Estadísticas de Cto de Urgencias- '+document.title;
function doAction()
{
}

function showReporte(value)
{
  var tipoAdmision = eval('document.form0.tipoAdmision').value;
  var fechaini     = eval('document.form0.fechaini').value;
  var fechafin     = eval('document.form0.fechafin').value;

	if(executeDB('<%=request.getContextPath()%>','call sf_estadistica_cu_temporal(to_date(\''+fechaini+'\',\'dd/mm/yyyy\'), to_date(\''+fechafin+'\',\'dd/mm/yyyy\') )',''))
	{
			if(value=="1")
			{
		 abrir_ventana2('../admision/print_estadistica_urgencia_completa.jsp?fechaini='+fechaini+'&fechafin='+fechafin);
			}
			else if(value=="2")
			{
			abrir_ventana2('../admision/print_detalle_admisiones_tipoCons.jsp?fechaini='+fechaini+'&fechafin='+fechafin);
			}
			else if(value=="3")
			{
			abrir_ventana2('../admision/print_detalle_admisiones_empleado.jsp?fechaini='+fechaini+'&fechafin='+fechafin);
			}
			else if(value=="4")
			{
			 abrir_ventana2('../admision/print_detalle_cargos_ambulancia.jsp?fechaini='+fechaini+'&fechafin='+fechafin);
			}
			else if(value=="5")
			{
			 abrir_ventana2('../admision/print_estadistica_urgencia_x_tipo.jsp?tipoAdmision='+tipoAdmision+'&fechaini='+fechaini+'&fechafin='+fechafin);
			}

		}

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ESTADISTICAS DE CUARTO DE URGENCIAS"></jsp:param>
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
   <table align="center" width="90%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

				<tr class="TextFilter" >
				   <td width="20%">Fecha</td>
				   <td width="40%" align="center">
						Desde &nbsp;&nbsp;
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fechaini" />
							<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
							</jsp:include>
						</td>
						<td width="40%"align="center">
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
					<td colspan="2">Reportes </td>
				</tr>

				<authtype type='50'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Estadística de Urgencias - Completa</td>
				</tr>
				</authtype>

				<authtype type='51'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Detalle de Admisiones por Tipo de Consulta</td>
				</tr>
				</authtype>

				<authtype type='52'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Admisiones con Beneficio de Empleado</td>
				</tr>
				</authtype>

				<authtype type='53'>
				<tr class="TextRow01">
				   <td colspan="2"><%=fb.radio("reporte1","4",false,false,false,null,null, "onClick=\"javascript:showReporte(this.value)\"")%>Estadística de Cargos de Ambulancia</td>
				</tr>
				</authtype>

				<authtype type='54'>
				<tr class="TextRow01">
				   <td><%=fb.radio("reporte1","5",false,false,false,null,null, "onClick=\"javascript:showReporte(this.value)\"")%>Estadística de Urgencias por Tipo de Admisión</td>
					 <td>Tipo de Admisión:<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo tipoAdmision from tbl_adm_tipo_admision_cia where categoria = 2 and codigo not in (99) and compania ="+(String) session.getAttribute("_companyId")+" order by 1","tipoAdmision",tipoAdmision,"1")%></td>
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
