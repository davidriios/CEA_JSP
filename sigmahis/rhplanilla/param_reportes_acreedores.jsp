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
String tipoCuenta = "", grupoDesc = "";
String descontar = "", eliminar = "", pendiente = "", noDescontar = "";

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
   var id        = eval('document.form0.id').value;
   var acr       = eval('document.form0.acrCode').value
   var tipoCuenta = eval('document.form0.tipoCuenta').value;
   var grupoDesc  = eval('document.form0.grupoDesc').value;
   var descMayor  = eval('document.form0.descMayor').value;
   var descMenor  = eval('document.form0.descMenor').value;
   var descontar  = eval('document.form0.descontar').value;
   var eliminar   = eval('document.form0.eliminar').value;
   var pendiente  = eval('document.form0.pendiente').value;
   var noDescontar = eval('document.form0.noDescontar').value;

	if(value == "1")
	{
	  abrir_ventana('../rhplanilla/print_list_emp_acreedores.jsp');
	}
	else if(value == "2")
	{
	 abrir_ventana('../rhplanilla/print_list_emp_info_general_acreedores.jsp');
	}	
	else if(value == "3")
	{
    abrir_ventana2('../rhplanilla/print_list_emp_acreedores_descto_x_emp.jsp?empId='+id);
	}	
	else if(value == "4")  
	{
	abrir_ventana2('../rhplanilla/print_list_emp_acreedores_descto_x_emp.jsp?empId='+id+'&fg='+fg);
	}
	else if(value == "5")
	{
	abrir_ventana2('../rhplanilla/print_list_emp_acreedores_detalle_descto_emp.jsp?empId='+id);
	}
    else if(value == "6") 
    {
	 abrir_ventana2('../rhplanilla/print_list_emp_acreedores_saldos_descto_x_acreedores.jsp?acr='+acr);
	}
	 else if(value == "7")
    {
	 abrir_ventana2('../rhplanilla/print_list_emp_acreedores_descto_x_acreedores.jsp?acr='+acr+'&fechaini='+fechaini+'&fechafin='+fechafin+'&tipoCuenta='+tipoCuenta);
	}	
	else if(value == "8")
	{
	 abrir_ventana2('../rhplanilla/print_list_emp_acreedores_inicio_tot_descto.jsp?acr='+acr+'&fechaini='+fechaini+'&fechafin='+fechafin+'&grupoDesc='+grupoDesc+'&descMayor='+descMayor+'&descMenor='+descMenor);
	}
	else if(value == "9")
	{
	 abrir_ventana2('../rhplanilla/print_list_emp_acreedores_tot_saldo_descto.jsp?acr='+acr+'&fechaini='+fechaini+'&fechafin='+fechafin+'&descMayor='+descMayor);
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
	<jsp:param name="title" value="REPORTES DE ACREEDORES"></jsp:param>
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
            <td colspan="2">LISTADO DE DESCUENTOS</td>
          </tr>
          <tr class="TextHeader">
            <td align="center">Nombre del reporte</td>
            <td align="center">Parámetros</td>
          </tr>
      
          <tr class="TextRow01">  
            <td><authtype type='50'><%=fb.radio("reporte1","1",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Listado de Acreedores </authtype></td>            
			<td>&nbsp;</td>
          </tr>

	       <tr class="TextRow01">  
		       <td><authtype type='51'><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Listado de Inf. General de Acreedores</authtype></td>
			  <td>&nbsp;</td>		
			</tr>
				   
		 <tr class="TextRow01">
            <td><authtype type='52'><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Listado de Descuentos por Empleado</authtype></td>
          <td rowspan="3"><authtype type='52','53','54'>&nbsp;No. Empleado:&nbsp;<%=fb.intBox("id","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("idDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.textBox("num","",false,false,true,5,5,"Text10",null,null)%><%=fb.button("btnmotivo","Ir",true,false,null,null,"onClick=\"javascript:addEmpleado()\"")%></authtype></td>
          </tr>			  
		  
		  <tr class="TextRow01">
		       <td><authtype type='53'><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Listado de Saldos de Descuentos por Empleado</authtype>
			   </td>
		  </tr>
		  
		  <tr class="TextRow01">
		    <td><authtype type='54'><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Detalle de Descuento por Empleados</authtype>
			 </td>
		  </tr>
		  
		  <tr class="TextHeader">
		    <td colspan="2">&nbsp;</td>
		  </tr>
		  
		  <tr class="TextRow01">
		    <td><authtype type='55'><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Listado de Saldos de Descuentos por Acreedor</authtype>
			 </td>			 
	        <td><authtype type='55','56','57','58'>&nbsp;Acreedor:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.intBox("acrCode","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("acrDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnacr","Ir",true,false,null,null,"onClick=\"javascript:addAcreedor()\"")%></authtype></td>
		 </tr> 
		  		  
		   <tr class="TextRow01">
            <td rowspan="2"><authtype type='56'><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Listado de Descuentos por Acreedor</authtype></td> 
			 <td ><authtype type='56'>&nbsp;Tipo de Cuenta:&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection()," select 'A', 'CTA. AHORRO' from dual union select 'C', 'CTA. CORRIENTE' from dual union select 'P', 'DETALLE X DESCTO' from dual ","tipoCuenta",tipoCuenta,"T")%> </authtype></td>			       
          </tr>	
		  
		  <tr class="TextRow01">
		    <td><authtype type='56','57','58'>&nbsp;Desde &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  <jsp:include page="../common/calendar.jsp" flush="true">
              <jsp:param name="noOfDateTBox" value="1" />              
              <jsp:param name="clearOption" value="true" />              
              <jsp:param name="nameOfTBox1" value="fechaini" />              
              <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />              </jsp:include>			  &nbsp;&nbsp;&nbsp;&nbsp;Hasta &nbsp;&nbsp;&nbsp;&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="fechafin" />
									<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
								</jsp:include> 
								</authtype></td> 
		   </tr>
		 		 
		  <tr class="TextRow01">
		     <td rowspan="2"><authtypo type='57'><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Total Descontado por Acreedor (Inicio de Descto.) </authtype></td>
			  <td><authtype type='57'>&nbsp;Grupo Descuento:&nbsp;<%=fb.select(ConMgr.getConnection(),"select cod_grupo, nombre||' - '||cod_grupo from tbl_pla_grupo_descuento order by 2","grupoDesc",grupoDesc," ")%> </authtype></td>
		   </tr>		
		   
		   <tr class="TextRow01">
		     <td><authtype type='57','58'>&nbsp;Total Descontado >= &nbsp;<%=fb.textBox("descMayor","0.00",false,false,false,7)%>
			 &nbsp;Total Descontado <= &nbsp;<%=fb.textBox("descMenor","",false,false,false,7)%>
			 </td>		      
		   </tr>
		   
		   <tr class="TextRow01">
		     <td><authtype type='58'><%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Total por Acreedor (Total-Saldo-Descontado)</authtype></td>
			       <td>&nbsp;</td>    
		   </tr>
		   
		   <tr class="TextRow01">
		     <td rowspan="2"><authtype type='59'><%=fb.radio("reporte1","10",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Descuentos por Cia/Acreedor/Estado</authtype></td>
			 <td><authtype type='59'>&nbsp;Descontar..?:&nbsp;<%=fb.select(ConMgr.getConnection(),"select 'S','SI' from dual union select ' ', 'NO' from dual order by 1","descontar",descontar,"SI")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Eliminado..?:&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection(),"select 'S','SI' from dual union select ' ', 'NO' from dual order by 1","eliminar",eliminar,"SI")%></authtype></td>			
		   </tr>
		   
		   <tr class="TextRow01">
		     <td><authtype type='59'>&nbsp;Pendiente..?:&nbsp;&nbsp;<%=fb.select(ConMgr.getConnection(),"select 'S','SI' from dual union select ' ', 'NO' from dual order by 1","pendiente",pendiente,"SI")%>&nbsp;&nbsp;&nbsp;&nbsp;No Descontar..?:&nbsp;<%=fb.select(ConMgr.getConnection(),"select 'S','SI' from dual union select ' ', 'NO' from dual order by 1","noDescontar",noDescontar,"SI")%></authtype></td>			
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


