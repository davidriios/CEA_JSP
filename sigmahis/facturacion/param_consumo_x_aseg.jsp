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

<!-- Desarrollado por: Tirza Monteza.                               -->
<!-- Pantalla: Reportes de Consumo por Aseguradora	                -->
<!-- Reportes: FAC70672_consumo, FAC10010                           -->
<!-- Clínica Hospital San Fernando                                  -->
<!-- Fecha: 23/08/2010                                              -->

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
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
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
document.title = 'Consumo por Aseguradora - '+document.title;
function doAction()
{
}

function showReporte(value)
{
  var categoria    = eval('document.form0.categoria').value;
  var area         = eval('document.form0.area').value;
  var aseguradora  = eval('document.form0.aseguradora').value;
  var fechaini     = eval('document.form0.fechaini').value;
  var fechafin     = eval('document.form0.fechafin').value;

	if(value=="1")
	{
 	abrir_ventana2('../facturacion/print_consumo_x_aseg_centro_anio.jsp?categoria='+categoria+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&fg=ADM');
	}
	else if(value=="2")
	{
 	abrir_ventana2('../facturacion/print_consumo_x_aseg_centro_anio.jsp?categoria='+categoria+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&fg=CAR');
	}
	else if(value=="3")
	{
  var tipoServicio     = eval('document.form0.tipoServicio').value;
 	abrir_ventana2('../facturacion/print_consumo_x_aseg_tipo_servicio.jsp?categoria='+categoria+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&tipoServicio='+tipoServicio);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="POR ASEGURADORA"></jsp:param>
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
				   <td width="8"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
				   <td width="92%">
		<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
				   </td>
			  </tr>

				<tr class="TextFilter">
				    <td width="8%"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A'  order by 2","area",area,"T")%>
					</td>
				</tr>
				<tr class="TextFilter">
					<td width="8%"><cellbytelabel>Aseguradora</cellbytelabel></td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa where tipo_empresa = 2 order by 2","aseguradora",aseguradora,"T")%>
					</td>
				</tr>

				<tr class="TextFilter" >
				   <td width="50%"><cellbytelabel>Fecha</cellbytelabel></td>
				   <td width="50%">
			<cellbytelabel>Desde</cellbytelabel> &nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
        	<jsp:param name="noOfDateTBox" value="1" />
        	<jsp:param name="clearOption" value="true" />
        	<jsp:param name="nameOfTBox1" value="fechaini" />
        	<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			</jsp:include>
			       <cellbytelabel>Hasta</cellbytelabel> &nbsp;&nbsp;
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
					<td colspan="2"><cellbytelabel>REPORTES</cellbytelabel></td>
				</tr>

				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Anual por Centro</cellbytelabel></td>
					<td>  -->> Por fecha de admisión</td>
				</tr>

				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","2",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Anual por Centro</cellbytelabel></td>
					<td>  -->> Por fecha de creación del cargo</td>
				</tr>

				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","3",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Por <cellbytelabel>Tipo de Servicio</cellbytelabel></td>
					<td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion tipoServicio from tbl_cds_tipo_servicio order by 2","tipoServicio",tipoServicio,"T")%></td>
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
