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
String fp = request.getParameter("fp");
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
 abrir_ventana("../common/search_empleado.jsp?fp=listadoSalario"); 
}

function addAcreedor()
{
 abrir_ventana('../common/search_acreedor.jsp?fp=listadoSalario');
}

function showReporte(value,fg)
{
   var fechaini  = eval('document.form0.fechaini').value;
   var fechafin  = eval('document.form0.fechafin').value; 
   var id        = eval('document.form0.id').value;
 
  
  	if(value == "1")
	{
	  abrir_ventana('../rhplanilla/print_list_emp_salario.jsp?fechaini='+fechaini+'&fechafin='+fechafin+'&emp_id='+id);
	}
}

function calculo() {
	var desde = document.form0.fechaini.value;
	var hasta = document.form0.fechafin.value;
	if(desde!=''&&hasta!=''){
	var id = getDBData('<%=request.getContextPath()%>','round(round(months_between (to_date(\''+hasta+'\',\'dd/mm/yyyy\') , to_date(\''+desde+'\',\'dd/mm/yyyy\')),2)*2,0) as fecha','dual','','');
	document.form0.periodos.value=(id);
	}
}

function setValues(){
	var inicio = document.form0.fechaini.value;
	var final = document.form0.fechafin.value;
	var periodo = document.form0.periodos.value;
	var anio ='';
	var emp_id = document.form0.id.value;
	if(final!='' ){
		if(periodo==''){calculo(); periodo = document.form0.periodos.value;}
	window.frames['itemFrame'].location = '../rhplanilla/reg_empleado_salario_det.jsp?finicio='+inicio+'&ffinal='+final+'&emp_id='+emp_id+'&periodo='+periodo;
	}
	}
	
</script>  
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE SALARIOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
            <%=fb.hidden("dia","")%>
			<%=fb.hidden("mes","")%>
            <%=fb.hidden("anio","")%>
<tr>
 <td>
   <table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
          <tr class="TextHeader">
            <td colspan="2">CONSULTA DE SALARIOS</td>
          </tr>
          <tr class="TextHeader">
            <td align="center">Parámetros</td>
            <td align="center">Descripción</td>
          </tr>
      
         <tr class="TextRow01">
            <td>No. Empleado:&nbsp;<%=fb.intBox("id","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("idDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.textBox("num","",false,false,true,5,5,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addEmpleado()\"")%></td>
          <td rowspan="3"> Cédula: <%=fb.textBox("cedula","",false,false,true,12)%> No. de Empleado:<%=fb.textBox("num_empleado","",false,false,true,7)%>   Salario: <%=fb.decBox("salario","",false,false,true,5,12.2)%>
          <p>Unidad Admin:<%=fb.textBox("unidad","",false,false,true,7)%> <%=fb.textBox("unidadDesc","",false,false,true,50)%></p></td>
          </tr>			  
		  
		 
		
		  <tr class="TextRow01">
		    <td>&nbsp;Desde &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  <jsp:include page="../common/calendar.jsp" flush="true">
              <jsp:param name="noOfDateTBox" value="1" />              
              <jsp:param name="clearOption" value="true" />              
              <jsp:param name="nameOfTBox1" value="fechaini" />              
              <jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />     
			  <jsp:param name="onChange" value="javascript:calculo();" />
      		  <jsp:param name="jsEvent" value="calculo();" />
			  
              </jsp:include>			  &nbsp;&nbsp;&nbsp;&nbsp;Hasta &nbsp;&nbsp;&nbsp;&nbsp;
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="fechafin" />
									<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
                                    <jsp:param name="onChange" value="javascript:calculo();" />
      		  						<jsp:param name="jsEvent" value="calculo();" />
								</jsp:include> 
								</td> 
		   </tr>
		 		 
			
		 <tr class="TextRow01">
		     <td>&nbsp;Total de Periodos..:&nbsp;&nbsp;<%=fb.textBox("periodos","",false,false,true,7)%></td>			
		   </tr>
		
		  
		  
        <tr class="TextRow01"> 
          <td colspan="2" align="center"><authtype type='52'>&nbsp;<%=fb.button("generar","Consultar Salarios",true,false,"","","onClick=\"javascript:setValues();\"")%></authtype></td>
        </tr>		  
        
          <%=fb.formEnd(true)%>
        </table>
		  <!-- ================================   F O R M   E N D   H E R E   ================================ --></td>
	</tr>
    
      <tr>
                      <td>
					  <!--<div id="salariosMain" width="100%" style="overflow:scroll;position:relative;height:300">
						<div id="salarios" width="98%" style="overflow;position:absolute">-->
					  <iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="300" scrolling="yes" src="../rhplanilla/reg_empleado_salario_det.jsp?fp=rrhh&fg=ap&mode=<%=mode%>"></iframe>
					  	<!--</div>
					  </div>-->
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


