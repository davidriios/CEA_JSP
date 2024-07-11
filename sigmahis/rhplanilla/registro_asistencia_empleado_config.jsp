<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String appendFilter = "";
//String id = "1";
String key = "";
//String mode = request.getParameter("mode");
//String change = request.getParameter("change");

String seccion = "";
String area = request.getParameter("area");
String grupo = request.getParameter("grupo");


if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="RRHH - "+document.title;

function doRedirect(seccion,redir,k)
{
	var empId = '';
	var grupo = '<%=grupo%>';
	var anio = '', mes = '';
	///console.log(":::::::::::::::::::::::::::: SECCION = "+seccion);
	if(seccion == '7' || seccion == '8' || seccion == '5' || seccion == '13' || seccion == '4' || seccion == '9' || seccion == '1'){
		var size;
		var count = 0;
		size = window.frames['iEmpleado'].document.formEmpleado.size.value;
		window.frames['iEmpleado'].document.formEmpleado.seccion.value = seccion;
		window.frames['iEmpleado'].document.search01.seccion.value = seccion;

	 // if (seccion=='5' || seccion=='3' || seccion =='7')
		if ( seccion=='3' || seccion =='7'){
				window.frames['iEmpleado'].document.formEmpleado.check.disabled = true;
		} else {
				window.frames['iEmpleado'].document.formEmpleado.check.disabled = false;
		}

		for (i=0;i<size;i++){
			if (eval("window.frames['iEmpleado'].document.formEmpleado.check"+i).checked == true){
				if(seccion=='8' || seccion=='13' || seccion=='4' || seccion=='5'|| seccion=='7'||  seccion=='1'){
					empId = eval("window.frames['iEmpleado'].document.formEmpleado.emp_id"+i).value;
					if(window.frames['iEmpleado'].document.search01.anio) anio = window.frames['iEmpleado'].document.search01.anio.value;
					if(window.frames['iEmpleado'].document.search01.mes) mes = window.frames['iEmpleado'].document.search01.mes.value;
				}
				count++;
			 }
		}

		if (count>1 && (seccion=='7' || seccion=='8')){
			unCheckAll('1');
		} else if (count==0 && redir=='0'){
			alert('Por favor seleccione al menos un empleado !');
			return false;
		}
	} else if(seccion == '2'){
		abrir_ventana1('../rhplanilla/reg_cambio_turno_borrador.jsp?grupo=<%=grupo%>&area=<%=area%>');
	} else if(seccion == '3'){
		document.getElementById("iDetalle").src='../rhplanilla/reg_asist_empleado_redirect.jsp?seccion='+seccion+'&grupo=<%=grupo%>&area=<%=area%>';
		//abrir_ventana1('../rhplanilla/reg_cambio_turno.jsp?grupo=<%=grupo%>&area=<%=area%>');
	} else if(seccion == '6'){
		abrir_ventana1('../rhplanilla/reg_emp_otros_pagos.jsp?fg=&grupo=<%=grupo%>');
	} else if(seccion == '12'){
		abrir_ventana1('../rhplanilla/empl_reporte.jsp?grupo=<%=grupo%>&area=<%=area%>');
	} else if(seccion == '11'){
		abrir_ventana1('../rhplanilla/empl_notificacion.jsp?grupo=<%=grupo%>&area=<%=area%>');
	} else if(seccion == '10'){
		abrir_ventana1('../rhplanilla/generacion_trx_asistencia.jsp?grupo=<%=grupo%>');
	} else if(seccion == '23'){
		abrir_ventana1('../rhplanilla/sobretiempo_list.jsp?fg=ap&grupo=<%=grupo%>&area=<%=area%>');
	}
	if (redir == '1'){
		switch (seccion){
			case '0':
								Ver('2');
								break;
			case '5':
								Ver('1');
								grupo = window.frames['iEmpleado'].document.formEmpleado.grupo.value;
								break;
			case '6':
								Ver('1');
								break;
			case '7':
								Ver('1');
								break;
			case '8':
								Ver('1');
								break;
			case '9':
								Ver('1');
								grupo = window.frames['iEmpleado'].document.formEmpleado.grupo.value;
								break;
			case '13':
								Ver('1');
								break;
			case '4':
								Ver('1');
								break;
			case '15':
								Ver('1');
								empId = eval("window.frames['iEmpleado'].document.formEmpleado.emp_id"+k).value;
								grupo = window.frames['iEmpleado'].document.formEmpleado.grupo.value;
								break;
			case '16':
								Ver('1');
								empId = eval("window.frames['iEmpleado'].document.formEmpleado.emp_id"+k).value;
								grupo = window.frames['iEmpleado'].document.formEmpleado.grupo.value;
								break;
			case '17':
								Ver('1');
								empId = eval("window.frames['iEmpleado'].document.formEmpleado.emp_id"+k).value;
								grupo = window.frames['iEmpleado'].document.formEmpleado.grupo.value;
								break;
			case '18':
								Ver('1');
								empId = eval("window.frames['iEmpleado'].document.formEmpleado.emp_id"+k).value;
								grupo = window.frames['iEmpleado'].document.formEmpleado.grupo.value;
								break;
			case '19':
								Ver('1');
								empId = eval("window.frames['iEmpleado'].document.formEmpleado.emp_id"+k).value;
								grupo = window.frames['iEmpleado'].document.formEmpleado.grupo.value;
								break;
			case '21':
								Ver('1');
								empId = eval("window.frames['iEmpleado'].document.formEmpleado.emp_id"+k).value;
								grupo = window.frames['iEmpleado'].document.formEmpleado.grupo.value;
								break;
			case '23':
								Ver('1');
								break;
		}

		if(seccion=='7' || seccion=='8')
			document.getElementById("iDetalle").src = '../rhplanilla/reg_asist_empleado_redirect.jsp?seccion='+seccion+'&grupo='+grupo+'&empId='+empId+'&anio='+anio+'&mes='+mes;
		else if(seccion=='2' || seccion=='3' || seccion=='6' || seccion=='10' || seccion=='11' || seccion=='12' ||seccion=='23') return false;
		//	document.getElementById("iDetalle").src = '../rhplanilla/reg_asist_empleado_redirect.jsp';
		else if(seccion=='22')
			document.getElementById("iDetalle").src = '../rhplanilla/reg_asist_empleado_redirect.jsp?seccion='+seccion+'&grupo=<%=grupo%>&area=<%=area%>';




		else
			document.getElementById("iDetalle").src = '../rhplanilla/reg_asist_empleado_redirect.jsp?seccion='+seccion+'&grupo='+grupo+'&empId='+empId+'&area=<%=area%>';
	}
	return true;
}

function unCheckAll(op)
{
	 var size;
	 size = window.frames['iEmpleado'].document.formEmpleado.size.value;
	 if (op == '1')
	 {
			alert('No es permitido seleccionar más de 1 empleado a la vez !');
	 }
	 else
	 {
			Ver('2');
	 }
	 for (i=0;i<size;i++)
	 {
			eval("window.frames['iEmpleado'].document.formEmpleado.check"+i).checked = false;
	 }
}

function doAction()
{

}
function Ver(op)
{
		var size;
	size = window.frames['iEmpleado'].document.formEmpleado.size.value;
	if (op == '1')
	{
		for (i=0; i<size;i++)
		{
			 eval("window.frames['iEmpleado'].document.formEmpleado.btnVer"+i).disabled = false;
		}
	}
	else
	{
			for (i=0; i<size;i++)
		{
			 eval("window.frames['iEmpleado'].document.formEmpleado.btnVer"+i).disabled = true;
		}
	}
}

function getEmpDet(){
   return window.frames['iEmpleado'].document.formEmpleado.curEmpDet.value;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE ASISTENCIA DE EMPLEADOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("grupo",grupo)%>
		<tr>
			<td colspan="2" class="TextRow01"><iframe id="iEmpleado" name="iEmpleado" width="100%" height="250" scrolling="yes" frameborder="0" src="../rhplanilla/check_empleado.jsp?area=<%=area%>&grupo=<%=grupo%>&seccion=<%=seccion%>"></iframe></td>
		</tr>
		<tr>
			<td colspan="2" align="right"><%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:closeWin()\"")%></td>
		</tr>
		<tr>
			<td width="20%" class="TableBorder">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader">
					<td>Asistencias</td>
				</tr>
				<tr>
					<td>
						<div id="secciones" style="overflow:scroll; position:static; height:400">
						<table width="100%" border="0" cellpadding="1" cellspacing="0">
						<authtype type='50'>
							<tr class="TextRow02" onClick="javascript:doRedirect('1','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">
								<td>Programa de Turno</td>
							</tr>

							<tr class="TextRow01" onClick="javascript:doRedirect('2','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<td>Borrador de Programa de Turno</td>
							</tr>

							<tr class="TextRow02" onClick="javascript:doRedirect('3','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">
								<td>Cambios de Turno</td>
							</tr>
						</authtype>

						<authtype type='51'>
							<tr class="TextRow01" onClick="javascript:doRedirect('4','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<td>Solicitud de Vacaciones</td>
							</tr>
						</authtype>

						<authtype type='52'>
							<tr class="TextRow02" onClick="javascript:doRedirect('5','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">
								<td>Permisos</td>
							</tr>
						</authtype>

						<authtype type='53'>
							<tr class="TextRow01" onClick="javascript:doRedirect('6','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<td>Otros Pagos</td>
							</tr>
						</authtype>

						<authtype type='54'>
							<tr class="TextRow02" onClick="javascript:doRedirect('7','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">
								<td>Incapacidades</td>
							</tr>
						</authtype>

						<authtype type='55'>
							<tr class="TextRow01" onClick="javascript:doRedirect('8','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<td>Ausencias</td>
							</tr>
						</authtype>

						<authtype type='56'>
							<tr class="TextRow02" onClick="javascript:doRedirect('9','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">
								<td>Sobretiempos</td>
							</tr>
						</authtype>

						<authtype type='57'>
							<tr class="TextRow01" onClick="javascript:doRedirect('10','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<td>Generaci&oacute;n de Ausencias, Tardanzas y Sobretiempos</td>
							</tr>
						</authtype>

						<authtype type='58'>
							<tr class="TextRow02" onClick="javascript:doRedirect('11','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow02')">
								<td>Notificación de Ausencias y Tardanzas</td>
							</tr>
							<tr class="TextRow01" onClick="javascript:doRedirect('12','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<td>Reportes de Transacciones de Planilla(Quincenas Pasadas)</td>
							</tr>
						</authtype>

						<authtype type='59'>
							<tr class="TextRow02" onClick="javascript:doRedirect('22','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<td>Aprobaci&oacute;n de Programa de Turno</td>
							</tr>
						</authtype>

						<authtype type='60'>
							<tr class="TextRow01" onClick="javascript:doRedirect('23','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
								<td>Aprobaci&oacute;n de Sobretiempos</td>
							</tr>
						</authtype>
				<!--
						<tr class="TextRow02" onClick="javascript:doRedirect('13','1','7')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
							<td>Fallecimiento y Subsidios</td>
						</tr>
				-->
						</table>
						</div>
					</td>
				</tr>
				</table>
			</td>
			<td valign="top" width="80%" class="TableBorder TextRow01"><iframe id="iDetalle" name="iDetalle" width="100%" height="400" scrolling="yes" frameborder="0" src="../rhplanilla/reg_asist_empleado_redirect.jsp"></iframe></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="2" align="right"><%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:closeWin()\"")%></td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>