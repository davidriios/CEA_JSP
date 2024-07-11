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
String tipoPersonal = "", depto = "", estado = "";


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
document.title = 'Reportes de Acreedores - '+document.title;
function doAction()
{
}

function addEmpleado()
{
 abrir_ventana("../common/search_empleado.jsp?fp=listadoAcreedores"); 
}

function addAcreedor()
{
 abrir_ventana('../common/search_acreedor.jsp?fp=listadoAcreedores');
}

function showReporte(value,fg)
{
   var fechaini  = eval('document.form0.fechaini').value;
   var fechafin  = eval('document.form0.fechafin').value;
   var fechaLimite = eval('document.form0.fechaLimite').value;
   var id          = eval('document.form0.id').value;
   var estado       = eval('document.form0.estado').value
   var tipoPersonal = eval('document.form0.tipoPersonal').value;
   var depto        = eval('document.form0.depto').value;
	
	 if(value == "2")
	{
	 abrir_ventana2('../rhplanilla/print_list_emp_incapac_x_depto.jsp?depto='+depto+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}else if(value == "10")
	{
	 abrir_ventana2('../rhplanilla/print_list_emp_acreedores_descto_x_ciaAcrEst.jsp?acr='+acr+'&grupoDesc='+grupoDesc+'&descontar='+descontar+'&eliminar='+eliminar+'&pendiente='+pendiente+'&noDescontar='+noDescontar);
	}
	
}
</script>  
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE INCAPACIDADES"></jsp:param>
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
            <td colspan="2">INFORMES DE INCAPACIDADES</td>
          </tr>
          <tr class="TextHeader">
            <td align="center">Nombre del reporte</td>
            <td align="center">Parámetros</td>
          </tr>
	       
				   
		 <tr class="TextRow01">
            <td><authtype type='50'><%=fb.radio("reporte1","1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Incapacidades de Empleados por Rango de Fecha</authtype></td>
          <td><authtype type='50'>&nbsp;No. Empleado:&nbsp;<%=fb.intBox("id","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("idDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.textBox("num","",false,false,true,5,5,"Text10",null,null)%><%=fb.button("btnmotivo","Ir",true,false,null,null,"onClick=\"javascript:addEmpleado()\"")%></authtype></td>		  
          </tr>			  
		  
		  <tr class="TextRow01">
		       <td><authtype type='51'><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Incapacidades por Departamento</authtype>
			   </td>
			    <td><authtype type='51'>&nbsp;Departamento:&nbsp;<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||'-'||codigo from tbl_sec_unidad_ejec where nivel = 2 order by 2","depto",depto,"T")%></authtype>
				</td>				 
		  </tr>
		  
		  	  
		 <tr class="TextRow01" >
		    <td colspan="2" align="left"><authtype type='50','51'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Desde
			  <jsp:include page="../common/calendar.jsp" flush="true">
              <jsp:param name="noOfDateTBox" value="1" />              
              <jsp:param name="clearOption" value="true" />              
              <jsp:param name="nameOfTBox1" value="fechaini" />              
              <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />              
			  </jsp:include>&nbsp;&nbsp;Hasta
			  <jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="fechafin" />
									<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								</jsp:include> 
								</authtype></td> 
		   </tr>
		  
		  <tr class="TextHeader">
		    <td colspan="2">&nbsp;</td>
		  </tr>
		  
		  
		  		  
		   <tr class="TextRow01">
            <td rowspan="3"><authtype type='52'><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Incapacidades por Tipo de Personal y Disponibilidad</authtype></td> 
			 <td ><authtype type='52'>&nbsp;Tipo de Personal:&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection()," select 'ENF','ENFERMERIA' from dual union select 'ADM','ADMINISTRATIVO' from dual ","tipoPersonal",tipoPersonal,"T")%> </authtype></td>   
          </tr>	
		  
		  <tr class="TextRow01">
		    <td><authtype type='52'>&nbsp;Fecha Límite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  <jsp:include page="../common/calendar.jsp" flush="true">
              <jsp:param name="noOfDateTBox" value="1" />              
              <jsp:param name="clearOption" value="true" />              
              <jsp:param name="nameOfTBox1" value="fechaLimite" />              
              <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />              
			  </jsp:include>	
				</authtype></td> 
		   </tr> 
		   
		    <tr class="TextRow01">            
			 <td ><authtype type='52'>&nbsp;Estado:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection()," select 'E','EXCEDIDOS' from dual union select 'A','AGOTADOS' from dual union select 'D','DISPONIBLES' from dual","estado",estado,"T")%> </authtype></td>			       
          </tr>	
		  
        <tr class="TextRow01"> 
          <td colspan="2">&nbsp;</td>
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



