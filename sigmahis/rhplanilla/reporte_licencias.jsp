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
<!-- Pantalla: "Reportes de Licencias"           -->
<!-- Reportes: RH19003                           -->
<!-- Clínica Hospital San Fernando               -->
<!-- Fecha: 26/03/2011                           -->
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes  = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String dia  = CmnMgr.getCurrentDate("dd");

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
document.title = 'Reportes de Licencias - '+document.title;
function doAction()
{
}

function showReporte(value)
{
   var anio  = eval('document.form0.anio').value;
   var mes  = eval('document.form0.mes').value;
   var empId  = eval('document.form0.empId').value;
	
	if ( value == "LxG" ){ //Por gravidez
	      abrir_ventana("../rhplanilla/print_licencias.jsp?motivoFalta=37&anio="+anio+"&mes="+mes);
	}
    if (value == "RP" ){ // Riesgo profesional
	      abrir_ventana("../rhplanilla/print_licencias.jsp?motivoFalta=39&anio="+anio+"&mes="+mes);
	}
	if (value == "IN" ){ //Incapacidad
	      abrir_ventana("../rhplanilla/print_licencias.jsp?motivoFalta=35&anio="+anio+"&mes="+mes);
	}
	if (value == "EN" ){ //Enfermedad
	      abrir_ventana("../rhplanilla/print_licencias.jsp?motivoFalta=13&anio="+anio+"&mes="+mes);
	}
	if (value == "LSS" ){//Sin Sueldo :(
	      abrir_ventana("../rhplanilla/print_licencias.jsp?motivoFalta=38&anio="+anio+"&mes="+mes);
	}
	if (value == "LCS" ){ //Con Sueldo :)
	      abrir_ventana("../rhplanilla/print_licencias.jsp?motivoFalta=40&anio="+anio+"&mes="+mes);
	}
	if (value == "HAC" ){ //Con Sueldo :)
	      abrir_ventana("../rhplanilla/print_horas_ausencia.jsp?motivoFalta=40&anio="+anio+"&mes="+mes+"&empId="+empId);
	}
}
</script>  
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE LICENCIAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
<tr>
 <td>
   <table align="center" width="95%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
          <tr class="TextHeader">
            <td colspan="3">REPORTES DE LICENCIAS</td>
          </tr>
          <tr class="TextHeader">
            <td align="center">Tipo de Licencias</td>
            <td align="center" colspan="2">Parámetros</td>
          </tr>
	       
				   
		 <tr class="TextRow01">
            <td><authtype type='50'><%=fb.radio("reporte1","LxG",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Licencia Por Gravidez</authtype></td>
          <td rowspan="6"><authtype type='50'>&nbsp;A&ntilde;o:&nbsp;<%=fb.intBox("anio",anio,false,false,false,5,4,"Text10",null,null)%></td>
		  <td rowspan="6">&nbsp;Mes:&nbsp;<%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"Text10",null,null,"","S")%></td>		  
          </tr>	
		  <tr class="TextRow01">
            <td><authtype type='50'><%=fb.radio("reporte1","RP",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Licencia Por Riesgo Profesional</authtype></td>
		  <td colspan="2">&nbsp;</td>		  
          </tr>	
		  <tr class="TextRow01">
            <td><authtype type='50'><%=fb.radio("reporte1","IN",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Incapacidad</authtype></td>
		  <td colspan="2">&nbsp;</td>		  
          </tr>	
		  <tr class="TextRow01">
            <td><authtype type='50'><%=fb.radio("reporte1","EN",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Enfermedad</authtype></td>
		  <td colspan="2">&nbsp;</td>		  
          </tr>	
		  <tr class="TextRow01">
            <td><authtype type='50'><%=fb.radio("reporte1","LSS",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Licencia Sin Sueldo</authtype></td>
		  <td colspan="2">&nbsp;</td>		  
          </tr>	
		   <tr class="TextRow01">
            <td><authtype type='50'><%=fb.radio("reporte1","LCS",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Licencia Con Sueldo</authtype></td>
		  <td colspan="2">&nbsp;</td>		  
          </tr>		
           <tr class="TextRow01">
            <td><authtype type='50'><%=fb.radio("reporte1","HAC",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Horas de Ausencia y Certificadas por Empleados </authtype></td>
		  <td colspan="2">&nbsp;Seleccione Empleado  &nbsp;<%=fb.select(ConMgr.getConnection(),"select emp_id  as optValueColumn, num_empleado||' - '||primer_nombre||' '||primer_apellido||' '||segundo_apellido as optLabelColumn   from tbl_pla_empleado order by primer_nombre, primer_apellido ","empId","","T")%>	</td>		  
          </tr>		  
		  
          <%=fb.formEnd(true)%>
        </table>
		  <!-- ================================   F O R M   E N D   H E R E   ================================ --></td>
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