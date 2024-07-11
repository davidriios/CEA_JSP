<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'REPORTES CLINICOS - '+document.title;

function doAction()
{
	setHeight();
}
function setHeight()
{
	newHeight();
	
}
function showReporte(value)
{
		if(value=="1")     abrir_ventana('../expediente/print_historia_clinica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&seccion=<%=seccion%>');
		else if(value=="2")abrir_ventana('../expediente/print_datos_salida.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="3")abrir_ventana('../expediente/print_hist_obstetrica1.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="4")abrir_ventana('../expediente/print_hist_obstetrica2.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="5")abrir_ventana('../expediente/print_historia_clinica_pediatria.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="6")abrir_ventana('../expediente/print_progreso_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="7")abrir_ventana('../expediente/print_resumen_clinico.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="8")abrir_ventana('../expediente/print_notas_enfermeria.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=NE&fp=TD&fecha=null&seccion=<%=seccion%>');
		else if(value=="9")abrir_ventana('../expediente/print_notas_enfermeria.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=NE&fp=HM&fecha=null&seccion=<%=seccion%>');
		else if(value=="10")abrir_ventana('../expediente/print_hoja_medicamento.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="11")abrir_ventana('../expediente/print_solicitud_interconsulta.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="12")abrir_ventana('../expediente/print_list_ordenmedica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="13")abrir_ventana('../expediente/print_signos_vitales.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="14")abrir_ventana('../expediente/print_escala_norton.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="15")abrir_ventana('../expediente/print_hoja_diabetica.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="16")abrir_ventana('../expediente/print_hoja_defuncion.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="17")abrir_ventana('../expediente/print_nota_terapias.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="18")abrir_ventana('../expediente/print_eval_ulceras.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="19")abrir_ventana('../expediente/print_recuperacion_anestesia.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="20")abrir_ventana('../expediente/print_protocolo_op.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="21")abrir_ventana('../expediente/print_seccion_materno.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="22")abrir_ventana('../expediente/print_control_salida.jsp?cds=<%=cds%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=CONTROL ENTRADA-SALIDA DEL NEONATO');
		else if(value=="23")abrir_ventana('../expediente/print_list_ordenes_nutricion.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="24")abrir_ventana('../expediente/print_evaluacion_paciente.jsp?fg=BR&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="25")abrir_ventana('../expediente/print_evaluacion_paciente.jsp?fg=CR&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="26")abrir_ventana('../expediente/print_evaluacion_paciente.jsp?fg=CI&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="27")abrir_ventana('../expediente/print_evaluacion_paciente.jsp?fg=EG&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		else if(value=="28")abrir_ventana('../expediente/print_escala_norton.jsp?fg=SG&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>');
		
		
		//else if(value=="7")abrir_ventana('../inventario/print_costos_normales.jsp');

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
<tr class="TextRow01">
	<td align="right">&nbsp;</td>
</tr>
	<tr>
		<td>
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("dob","")%>
			<%=fb.hidden("codPac","")%>
			<%=fb.hidden("pacId",pacId)%>
			<%=fb.hidden("noAdmision",noAdmision)%>


			<tr class="TextRow02">
				<td>&nbsp;</td>
			</tr>

			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="1">Historia cl&iacute;nica</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="2">Plan de Salida</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="3">Historia Obstetrica I</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="4">Historia Obstetrica II</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="5">Historia Clinca Pediatria</cellbytelabel></td>
			</tr><!------>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="6">Progreso Cl&iacute;nico</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="7">Resumen Cl&iacute;nico</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="8">Notas de Enfermer&iacute;a</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="9">Notas de Enfermer&iacute;a - Hemodi&aacute;lisis</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","10",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="10">Hoja de Medicamentos</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","11",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="11">Solicitudes de Interconsulta</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","12",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="12">Ordenes M&eacute;dicas</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","13",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="13">Signos Vitales</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","14",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="14">Escala de Norton</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","15",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="15">Hoja Diab&eacute;tica</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","16",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="16">Hoja de Defunci&oacute;n</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","17",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="17">Nota de Terapias</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","18",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="18">Evaluaci&oacute;n de &Uacute;lceras por Presi&oacute;n</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","19",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="19">Recuperaci&oacute;n de Anestesia</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","20",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="20">Protocolo Operatorio</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","21",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="21">Secci&oacute;n Materno Infantil</cellbytelabel></td>
			</tr><!---->
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","22",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="22">Control de Salida/Entrada Neonatos</cellbytelabel></td>
			</tr><!---->
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","23",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><!--Ordenes de Nutrición--> <cellbytelabel id="23">Listado de alimentación - Neonatal</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","24",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><!--Ordenes de Nutrición--> <cellbytelabel id="24">Evaluaci&oacute;n - Broncoscopia</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","25",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="25">Evaluaci&oacute;n - Colonoscopia y Rectoscopia</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","26",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="26">Evaluaci&oacute;n - Cistoscopia</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","27",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="27">Evaluaci&oacute;n - Endoscopia Gastroduodenal</cellbytelabel></td>
			</tr>
			<tr class="TextRow02" align="center">
				<td align="left"><%=fb.radio("reporte1","28",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%> <cellbytelabel id="28">Escala de Dolor Susan Givens</cellbytelabel></td>
			
			
			<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//fin GET
%>

