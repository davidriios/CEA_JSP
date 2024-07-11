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

<!-- Desarrollado por: Tirza Monteza    .                           -->
<!-- Pantalla: Cartas y Certificaciones de trabajo                  -->
<!-- Reportes: CARTATRAB, CERTIFICACION                             -->

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

	sql = "select  a.nombre_empleado as nombre, c.denominacion cargo, a.emp_id as empId, nvl(a.num_empleado,' ') as numEmpleado,  (select descripcion from tbl_sec_unidad_ejec where codigo=a.unidad_organi and compania=a.compania) as depto,a.cedula1 cedula from vw_pla_empleado a, tbl_pla_cargo c where a.compania="+(String)session.getAttribute("_companyId")+" and a.cargo = c.codigo and a.compania = c.compania  and c.firmar_carta_trabajo = 'S' and a.estado not in (3,13) and a.cargo = '63' ";
	cdo= SQLMgr.getData(sql);
	if(cdo==null)cdo= new CommonDataObject();

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reporte de Familiares de Empleados - '+document.title;
function doAction()
{
}

function showReporte(value)
{
	var empIdCert 		= eval('document.form0.empIdCert').value ;
	var nombreEmpRepr = eval('document.form0.nombreEmpRepr').value ;
	var cargoEmpRepr	= eval('document.form0.cargoEmpRepr').value ;
	var observacion		= eval('document.form0.observacion').value ;
	var nota					= eval('document.form0.nota').value ;
	var dirigidoA			= eval('document.form0.dirigidoA').value ;
	var anio='';
	var noEmpleado='';
	var cedula='';
	var fechaDesde='';
	var fechaHasta='';
	if(document.form0.anio)anio=eval('document.form0.anio').value ;
	if(document.form0.noEmpleado)noEmpleado=eval('document.form0.noEmpleado').value ;
	if(document.form0.cedula)cedula=eval('document.form0.cedula').value ;
	if(document.form0.fechaDesde)fechaDesde=eval('document.form0.fechaDesde').value ;
	if(document.form0.fechaHasta)fechaHasta=eval('document.form0.fechaHasta').value ;

	if(value=="1") 						abrir_ventana2('../rhplanilla/print_carta_trabajo.jsp?fg=carta&empIdCert='+empIdCert+'&nombreEmpRepr='+nombreEmpRepr+'&cargoEmpRepr='+cargoEmpRepr+'&observacion='+observacion+'&dirigidoA='+dirigidoA+'&nota='+nota);
	else if(value=="2")				abrir_ventana2('../rhplanilla/print_certificacion.jsp?fg=carta&empIdCert='+empIdCert+'&nombreEmpRepr='+nombreEmpRepr+'&cargoEmpRepr='+cargoEmpRepr+'&observacion='+observacion+'&dirigidoA='+dirigidoA+'&nota='+nota);
	else if(value=="3")				abrir_ventana2('../rhplanilla/print_carta_licencia_css.jsp?fg=carta&empIdCert='+empIdCert+'&nombreEmpRepr='+nombreEmpRepr+'&cargoEmpRepr='+cargoEmpRepr+'&observacion='+observacion+'&dirigidoA='+dirigidoA+'&nota='+nota+'&fechaDesde='+fechaDesde+'&fechaHasta='+fechaHasta);
	else if(value=="4")				abrir_ventana2('../rhplanilla/print_carta_gravidez_css.jsp?fg=carta&empIdCert='+empIdCert+'&nombreEmpRepr='+nombreEmpRepr+'&cargoEmpRepr='+cargoEmpRepr+'&observacion='+observacion+'&dirigidoA='+dirigidoA+'&nota='+nota);
	else if(value=="5")				abrir_ventana2('../rhplanilla/print_certificacion_deducciones.jsp?fg=carta&empIdCert='+empIdCert+'&nombreEmpRepr='+nombreEmpRepr+'&cargoEmpRepr='+cargoEmpRepr+'&observacion='+observacion+'&dirigidoA='+dirigidoA+'&nota='+nota+'&anio='+anio+'&noEmpleado='+noEmpleado+'&cedula='+cedula);

}

function showEmpCert()
{
		abrir_ventana('../common/search_empleado.jsp?fp=cartaCert');
}

function showEmpRepr()
{
		abrir_ventana('../common/search_empleado.jsp?fp=cartaRepr');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CARTAS Y CERTIFICACIONES LABORALES"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("empIdRepr",cdo.getColValue("empId"))%>
			<%=fb.hidden("deptoEmpRepr",cdo.getColValue("depto"))%>
			<%=fb.hidden("empIdCert","")%>
			<%=fb.hidden("noEmpleado","")%>
			<%=fb.hidden("cedula",cdo.getColValue("cedula"))%>

<tr>
 <td>
   <table align="center" width="90%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" >
				   <td colspan="3">PARAMETROS</td>
			  </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextFilter" >
				   <td width="40%" rowspan="2">Representante de la Empresa</td>
				   <td colspan="2">
							<%=fb.textBox("nombreEmpRepr",cdo.getColValue("nombre"),false,false,true,50)%>
							<%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showEmpRepr()\"")%>
					 </td>
			  </tr>
			  <tr class="TextFilter">
			  	 <td colspan="2"><%=fb.textBox("cargoEmpRepr",cdo.getColValue("cargo"),false,false,false,60)%></td>
			  </tr>
				<tr class="TextFilter" >
				   <td width="40%" rowspan="3">Empleado a Certificar</td>
				   <td colspan="2">
							<%=fb.textBox("nombreEmpCert","",false,false,true,50)%>
							<%=fb.button("add","...",true,false,null,null,"onClick=\"javascript:showEmpCert()\"")%>
					 </td>
			  </tr>
			  <tr class="TextFilter">
			  	 <td colspan="2"><%=fb.textBox("cargoEmpCert","",false,false,false,60)%></td>
			  </tr>
			  <tr class="TextFilter">
			  	 <td colspan="2"><%=fb.textBox("deptoEmpCert","",false,false,false,60)%></td>
			  </tr>
				<tr class="TextFilter" >
				   <td width="40%">Carta Dirigida a</td>
				   <td colspan="2">
							<%=fb.textBox("dirigidoA","A QUIEN CONCIERNE",false,false,false,50)%>
					 </td>
			  </tr>
				<tr class="TextFilter" >
				   <td width="40%">Observaciones</td>
				   <td colspan="2">
							<%=fb.textarea("observacion","",false,false,false,60,3)%>
					 </td>
			  </tr>
				<tr class="TextFilter" >
				   <td width="40%">Nota</td>
				   <td colspan="2">
							<%=fb.textarea("nota","",false,false,false,60,1)%>
					 </td>
			  </tr>
			  <tr class="TextFilter" >
				   <td width="40%">Año</td>
				   <td colspan="2">
							<%=fb.intBox("anio",""+(Integer.parseInt(anio)-1),false,false,false,10)%>
					 </td>
			  </tr>
			</table>



			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2">REPORTE</td>
				</tr>
			<!--<authtype type='50'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Carta de Trabajo </td>
				</tr>
			</authtype>
			<authtype type='51'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Certificaci&oacute;n de Trabajo</td>
				</tr>
			</authtype>-->
			
			<!--<authtype type='54'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Turnos&nbsp;&nbsp;desde:
							<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								<jsp:param name="jsEvent" value="calculanor()" />
							</jsp:include>
							&nbsp;&nbsp;hasta:
							<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								<jsp:param name="jsEvent" value="calculanor()" />
							</jsp:include>
					</td>
				</tr></authtype>-->
				<authtype type='55'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Certificaci&oacute;n de Retenciones</td>
				</tr></authtype>
				<authtype type='52'>
				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Desglose De Salarios</td>
					<td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="2" />
								<jsp:param name="nameOfTBox1" value="fechaDesde" />
								<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								<jsp:param name="nameOfTBox2" value="fechaHasta" />
								<jsp:param name="valueOfTBox2" value="<%=cDateTime%>" />
						</jsp:include>
					</td>
				</tr>
				
			</authtype><!---->
			<authtype type='53'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Licencia por Gravidez</td>
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
