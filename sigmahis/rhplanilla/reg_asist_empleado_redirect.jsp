<%
String seccion = request.getParameter("seccion");
String grupo = request.getParameter("grupo");
String empId = request.getParameter("empId");
String toPage = "";
String area = request.getParameter("area");

System.out.println("*********** >>>>>>>>>>>>>>>>>>>>>>>> GRUPO = "+grupo+" ============================ seccion = "+seccion);
if (seccion != null && !seccion.trim().equals(""))
{
	switch (Integer.parseInt(seccion))
	{
		case 1: toPage = "../rhplanilla/empl_prog_turnos_detail.jsp?emp_id="+empId; break; //verified
		case 2: toPage = "../rhplanilla/empl_borrador_prog.jsp"; break;
		case 3: toPage = "../rhplanilla/list_cambio_turno.jsp?fg=asistencia"; break;
		case 4: toPage = "../rhplanilla/empl_solicitud_detail.jsp?empId="+empId; break;
		//case 5: toPage = "../rhplanilla/empl_permisos_detail.jsp"; break;
		//case 5: toPage = "../rhplanilla/empl_permiso_list.jsp?empId="+empId+"&grupo="+grupo; break;
		case 5: toPage = "../rhplanilla/list_permiso.jsp?fg=asistencia&grupo="+grupo; break;
		case 6: toPage = "../rhplanilla/empl_otros_pagos.jsp"; break;
		//case 7: toPage = "../rhplanilla/empl_incapacidades_detail.jsp"; break;
		//case 7: toPage = "../rhplanilla/list_incapacidad.jsp?fg=asistencia&grupo="+grupo+"&empId="+empId; break;
		case 7: toPage = "../rhplanilla/empl_incapacidad_list.jsp?grupo="+grupo; break;
		//case 8: toPage = "../rhplanilla/empl_ausencias_detail.jsp?empId="+empId+"&grupo="+grupo; break;
		case 8: toPage = "../rhplanilla/empl_ausencia_list.jsp?empId="+empId+"&grupo="+grupo; break;
		//case 9: toPage = "../rhplanilla/empl_sobretiempo_detail.jsp"; break;
		//case 9: toPage = "../rhplanilla/empl_sobretiempo_detail.jsp?empId="+empId; break;
		case 9: toPage = "../rhplanilla/sobretiempo_list.jsp?fp=asistencia&uf_codigo="+area+"&grupo="+grupo+"&empId="+empId; break;

		case 10: toPage = "../rhplanilla/empl_generacion.jsp"; break;
		case 11: toPage = "../rhplanilla/empl_notificacion.jsp"; break;
		case 12: toPage = "../rhplanilla/empl_reporte.jsp"; break;
		case 13: toPage = "../rhplanilla/empl_fallecimiento_detail.jsp?grupo="+grupo+"&empId="+empId; break;
		case 14: toPage = "../rhplanilla/empl_fallecimiento_list.jsp"; break;
		case 15: toPage = "../rhplanilla/empl_permiso_list.jsp?grupo="+grupo+"&empId="+empId; break;
		case 16: toPage = "../rhplanilla/empl_otros_pagos_list.jsp"; break;
		case 17: toPage = "../rhplanilla/empl_incapacidad_list.jsp?grupo="+grupo+"&empId="+empId; break;
		case 18: toPage = "../rhplanilla/empl_ausencia_list.jsp?grupo="+grupo+"&empId="+empId; break;
		//case 19: toPage = "../rhplanilla/empl_sobretiempo_list.jsp?area="+area+"&grupo="+grupo+"&empId="+empId; break;
		case 19: toPage = "../rhplanilla/sobretiempo_list_det.jsp?area="+area+"&grupo="+grupo+"&empId="+empId; break;
		case 20: toPage = "../rhplanilla/empl_generacion_list.jsp"; break;
		case 21: toPage = "../rhplanilla/empl_solicitud_list.jsp?grupo="+grupo+"&empId="+empId; break;
		case 22: toPage = "../rhplanilla/aprobacion_prog_turno.jsp?grupo="+grupo; break;
		case 23: toPage = "../rhplanilla/sobretiempo_list.jsp?area="+area+"&grupo="+grupo+"&empId="+empId; break;

		default: toPage = "";
	}
}
System.out.println("************toPage="+toPage);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" class="TextRow01">
<%
if (!toPage.equals(""))
{
%>
<jsp:forward page="<%=toPage%>"></jsp:forward>
<%
}
%>
</body>
</html>