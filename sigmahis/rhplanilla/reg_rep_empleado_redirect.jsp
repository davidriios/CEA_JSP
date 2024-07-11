<%
String seccion = request.getParameter("seccion");
String grupo = request.getParameter("grupo");
String empId = request.getParameter("empId");
String toPage = "";

if (seccion != null && !seccion.trim().equals(""))
{
	switch (Integer.parseInt(seccion))
	{
		case 1: toPage = "../rhplanilla/empl_unidad_detail.jsp?seccion="+seccion;  //verified
		case 2: toPage = "../rhplanilla/empl_unidad_detail.jsp?seccion="+seccion; break;
		case 3: toPage = "../rhplanilla/empl_unidad_detail.jsp?seccion="+seccion; break;
		case 4: toPage = "../rhplanilla/empl_unidad_detail.jsp?seccion="+seccion; break;
		case 5: toPage = "../rhplanilla/empl_unidad_detail.jsp?seccion="+seccion; break;
		case 6: toPage = "../rhplanilla/empl_unidad_detail.jsp?seccion="+seccion; break;
		case 7: toPage = "../rhplanilla/empl_general_detail.jsp?seccion="+seccion; break;
		case 8: toPage = "../rhplanilla/empl_general_detail.jsp?seccion="+seccion; break;
		case 9: toPage = "../rhplanilla/empl_general_detail.jsp?seccion="+seccion; break;
		case 10: toPage = "../rhplanilla/empl_unidad_detail.jsp?seccion="+seccion; break;
		case 11: toPage = "../rhplanilla/empl_general_detail.jsp?seccion="+seccion; break;
		case 15: toPage = "../rhplanilla/empl_permiso_list.jsp?grupo="+grupo+"&empId="+empId; break;
		case 16: toPage = "../rhplanilla/empl_otros_pagos_list.jsp"; break;
		case 17: toPage = "../rhplanilla/empl_incapacidad_list.jsp?grupo="+grupo+"&empId="+empId; break;
		case 18: toPage = "../rhplanilla/empl_ausencia_list.jsp?grupo="+grupo+"&empId="+empId; break;
		case 19: toPage = "../rhplanilla/empl_sobretiempo_list.jsp"; break;


		default: toPage = "";
	}
}
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