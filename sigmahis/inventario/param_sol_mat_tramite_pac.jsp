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
<!-- Desarrollado por: José A. Acevedo C.            -->
<!-- Pantalla: "Reportes de Requisiciones"           -->
<!-- Reportes: INV00115_XP                           -->
<!-- Clínica Hospital San Fernando                   -->
<!-- Fecha: 20/04/2010                               -->

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
String sala = "", usuario = "";
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
document.title = 'Reporte de Inventario- '+document.title;
function doAction()
{
}

function showCPT()  
{
 abrir_ventana2('../common/search_diagnostico.jsp?fp=rDiag');             
}

function showReporte(value)
{
  var usuario    = eval('document.form0.usuario').value;
  var sala         = eval('document.form0.sala').value;
  //alert(cpt);
  var fechaini     = eval('document.form0.fechaini').value;
  var fechafin     = eval('document.form0.fechafin').value;	  
	
	if(value=="1")
	{
 abrir_ventana2('../inventario/print_solicitud_mat_tramite_pac.jsp?sala='+sala+'&usuario='+usuario+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}	
	/*else if(value == "7")  
	{
	abrir_ventana2('../admision/print_censo_det_pacts_x_sala.jsp?aseguradora='+aseguradora+'&fechaini='+fechaini);    
	}	
	*/
}
//print_habitaciones_en_uso.jsp  
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">  
	<jsp:param name="title" value="REPORTES SOLICITUD DE MATERIALES DE PACIENTES RESUMIDO"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param> 
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
    <tr> <td colspan="2">&nbsp;</td> </tr>	 
				<tr> <td colspan="2">&nbsp;</td> </tr>
 <td>		
   <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">  
			
			<table align="center" width="100%" cellpadding="0" cellspacing="1"> 			 
					 
					 
				<tr class="TextFilter">  
				    <td width="21%">Salas</td>
					<td width="79%" >
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where origen = 'S' order by 2","sala",sala,"T")%>
				  </td> 
				</tr>
				
				<tr class="TextFilter"> 
				  <td width="21%">Usuario</td>
				  <td width="79%"><%=fb.textBox("usuario",usuario,false,false,false,30) %>
				  </td>
				</tr>
				
				
				<tr class="TextFilter" >
				   <td width="21%">Fecha</td>				  			   				
				   <td width="79%">
			Desde &nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">  
        	<jsp:param name="noOfDateTBox" value="1" />        
        	<jsp:param name="clearOption" value="true" />        
        	<jsp:param name="nameOfTBox1" value="fechaini" />        
        	<jsp:param name="valueOfTBox1" value="" />
			</jsp:include>		                
			       Hasta &nbsp;&nbsp; 
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechafin" />
			<jsp:param name="valueOfTBox1" value="" />
			</jsp:include>
	              </td>  
			  </tr>					
			</table>					
			
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader"> 
					<td colspan="2">Reportes de Requisición</td>
				</tr>
				
				<tr class="TextRow01"> 
					<td width="50%"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Solicitud de Mat. de Pacientes Resumido</td>
					<td width="50%">&nbsp;</td>
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


