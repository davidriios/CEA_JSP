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
<!-- Pantalla: "Reportes de Neonatología"        -->
<!-- Reportes: ADM70022_C, ADM70022_B, ADM70022, -->
<!--   SAL800176, SAL800172,ADM70022_TOTAL, FAC71020R, FAC71020D  -->
<!--   ADM3083, ADM3083_BOR                      -->
<!-- Clínica Hospital San Fernando               -->
<!-- Fecha: 25/06/2010                           -->

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
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String sala = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes  = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String dia  = CmnMgr.getCurrentDate("dd");
String evento = "", encuesta = "", aseguradora = "";

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
document.title = 'Reportes de Neonatología - '+document.title;
function doAction()
{
}

function showReporte(value,fg)
{
   var fechaini    = eval('document.form0.fechaini').value;
   var fechafin    = eval('document.form0.fechafin').value;
   var evento      = eval('document.form0.evento').value;
   var encuesta    = eval('document.form0.encuesta').value; 
   var aseguradora = eval('document.form0.aseguradora').value;

	if(value=="1")
	{
	  abrir_ventana('../admision/print_neonat_regresan_clinicaPediatria.jsp?evento='+evento+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}
	else if(value=="2")
	{
	 abrir_ventana('../admision/print_neonat_regresan_clinicaMaternidad.jsp?evento='+evento+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}	
	else if(value=="3")
	{
    abrir_ventana2('../admision/print_neonat_encuesta_maternidad.jsp?evento='+evento+'&encuesta='+encuesta+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}	
	else if(value=="4")
	{
	abrir_ventana2('../admision/print_neonat_estadistica_padreMadre.jsp?fechaini='+fechaini+'&fechafin='+fechafin);
	}
	else if(value=="5")
	{
	abrir_ventana2('../admision/print_neonat_tot_maternidad_x_aseg.jsp?aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}
    else if(value=="6")
    {
	 abrir_ventana2('../admision/print_neonat_pact_x_categoriaDetallado.jsp?fechaini='+fechaini+'&fechafin='+fechafin);
	}
	 else if(value=="7")
    {
	 abrir_ventana2('../admision/print_neonat_pact_x_categoriaDetallado.jsp?fechaini='+fechaini+'&fechafin='+fechafin+'&fg='+fg);
	}
	else if(value=="8")
	{
	 abrir_ventana2('../admision/print_monitoreos.jsp?tDate='+fechaini+'&fDate='+fechafin);
	}
	else if(value=="9")
	{
	 abrir_ventana2('../admision/print_neonat_estadistica_neonatoMadre.jsp?fechaini='+fechaini+'&fechafin='+fechafin);
	} 
	else if(value=="10")
	{
	 abrir_ventana2('../admision/print_neonat_estadistica_maternidad.jsp?fechaini='+fechaini+'&fechafin='+fechafin);
	}
	else if(value=="11")
	{
	 abrir_ventana2('../admision/print_neonat_estadistica_maternidad.jsp?fechaini='+fechaini+'&fechafin='+fechafin+'&fg='+fg);
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE NEONATOLOGIA"></jsp:param>
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
   <table align="center" width="95%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
          <tr class="TextHeader">
            <td colspan="2">REPORTES DE NEONATOLOGÍA</td>
          </tr>
          <tr class="TextHeader">
            <td align="center">Nombre del reporte</td>
            <td align="center">Parámetros</td>
          </tr>
      
          <tr class="TextRow01">
            <td><%=fb.radio("reporte1","1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Listado de Personas Que Regresan a Clínica/PEDIATRÍA </td>
            <td rowspan="2">Evento:&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo from  tbl_adm_eventos order by 2","evento",evento,"T")%></td>
          </tr>

				   <tr class="TextRow01">
		            <td><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Listado de Personas Que Regresan a Clínica/MATERNIDAD </td>				   				   
		           </tr>
				   
		 <tr class="TextRow01">
            <td><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Encuesta / MATERNIDAD </td>
          <td>Encuesta:&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo_encuesta, descrip_encuesta||' - '||codigo_encuesta from tbl_adm_tipo_encuesta  order by 2","encuesta",encuesta,"T")%></td>
          </tr>			  
		  
		 <tr class="TextHeader">
			<td colspan="2">Maternidad</td>
		 </tr> 
		  		  
		   <tr class="TextRow01">
            <td><%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Estadística de Neonatología (MATERNIDAD)</td> 
			<td rowspan="5">Desde &nbsp;&nbsp;&nbsp;&nbsp;
									<jsp:include page="../common/calendar.jsp" flush="true">
					        	<jsp:param name="noOfDateTBox" value="1" />
					        	<jsp:param name="clearOption" value="true" />
					        	<jsp:param name="nameOfTBox1" value="fechaini" />
					        	<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
									</jsp:include>
		        &nbsp;&nbsp;&nbsp;&nbsp;Hasta &nbsp;&nbsp;&nbsp;&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="fechafin" />
									<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								</jsp:include></td>        
          </tr>	
		  
		  <tr class="TextRow01">
            <td><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Estadística del Padre y de la Madre</td>          
          </tr>	
		  
		  <tr class="TextRow01">
		    <td><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Estadística de Monitoreo Fetal</td>			
		  </tr>	
		  
		  <tr class="TextHeader"> 
		    <td>&nbsp;Estadísticas de Maternidad</td>			 
		  </tr>
		  
		  <tr class="TextRow01"> 
		    <td><%=fb.radio("reporte1","10",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>&nbsp;&nbsp;&nbsp;&nbsp;PREELIMINAR &nbsp;&nbsp;<%=fb.radio("reporte1","11",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>&nbsp;&nbsp;&nbsp;&nbsp;FINAL</td>			 
		  </tr>
		  	   

        <tr class="TextRow01">
          <td colspan="2">&nbsp;</td>
        </tr>

        <tr class="TextHeader">
          <td colspan="2">REPORTES</td>
        </tr>
          <tr class="TextHeader">
            <td align="center">Nombre del reporte</td>
            <td align="center">Parámetros</td>
          </tr>

        <tr class="TextRow01">
          <td ><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Tot. Pacientes / Maternidad (Por Aseguradora)</td>
          <td>&nbsp;&nbsp;Aseguradora&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa where tipo_empresa = 2 order by 2","aseguradora",aseguradora,"T")%></td>
        </tr>
		
		
	 <tr class="TextRow01">
            <td><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes en Neonatología por Categoría (DETALLADO)</td>
          <td>&nbsp;</td>
          </tr>			   
     
	 	 <tr class="TextRow01">
            <td><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes en Neonatología por Categoría (RESUMEN)</td>          
		<td>&nbsp;</td>	
          </tr>		
        				

          <!--<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%></td>
				</tr>--->
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

