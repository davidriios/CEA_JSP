<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="perHash" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable" />
<!-- Pantalla: "Reportes de Disribuición de días de vacacciones"           -->
<!-- Reportes: PLA0090                           -->
<!-- Clínica Hospital San Fernando               -->
<!-- Fecha: 15/05/2011                           -->
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
String change = request.getParameter("change");
String seccion = request.getParameter("seccion");
String appendFilter = "";
String empId = "";

String area = "";
String grupo = "";
String key = "";
String sql = "";
String date = "";
String estado = "";
int perLastLineNo = 0;
int count = 0;

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy"); // 13/04/2011
int mes  = Integer.parseInt(cDateTime.substring(3,5));
String anio = cDateTime.substring(6,10);
String dia  = CmnMgr.getCurrentDate("dd");

//System.out.println("******************************"+dia);

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
document.title = 'Reportes Generales para Empleados - '+document.title;

function doSubmit()
{ 
	 document.formUnidad.save.disableOnSubmit = true;
  
}
function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}


function doAction()
{   
	//newHeight();
	//parent.setHeight('secciones',document.body.scrollHeight);

}


function is_int(value){ 
  if((parseFloat(value) == parseInt(value)) && !isNaN(value)){
      return true;
  } else { 
      return false;
  } 
}
  
function  printList(opt)
{
	var anio = eval('document.form0.anio').value;
	var mes  ='';// eval('document.form0.mes').value;
	var periodo  = '';//eval('document.form0.periodo').value;
	var empId  = eval('document.form0.id').value;
	var noEmpleado  = eval('document.form0.num_empleado').value;
	var fechaDesde  = eval('document.form0.fechaDesde').value;
	var fechaHasta  = eval('document.form0.fechaHasta').value;

	if(anio == null || anio == '' ||  (parseFloat(anio) != parseInt(anio)) && isNaN(anio)){
	  alert("Por favor introduzca un año válido!"); return false;}
	else{ 
		if (opt == 0) {
			var pCtrlHeader = $("#ctrlHeader").is(":checked");
			fechaDesde = $("#fechaDesde").toRptFormat() || '1900-01-01';
			fechaHasta = $("#fechaHasta").toRptFormat() || '1900-01-01';
			empId  = empId || 'ALL';
			noEmpleado  = noEmpleado || 'ALL';
			abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_dist_dias_vac.rptdesign&pAnio='+anio+'&pEmpId='+empId+'&pNoEmpleado='+noEmpleado+'&fDesde='+fechaDesde+'&fHasta='+fechaHasta+'&pCtrlHeader='+pCtrlHeader);
		}
		else abrir_ventana("../rhplanilla/print_dist_dias_vac.jsp?anio="+anio+"&mes="+mes+"&periodo="+periodo+'&empId='+empId+'&noEmpleado='+noEmpleado+'&fechaDesde='+fechaDesde+'&fechaHasta='+fechaHasta);
	}
}
function addEmpleado(){abrir_ventana("../common/search_empleado.jsp?fp=distVacaciones");}
function clearEmpleado(){document.form0.idDesc.value = '';document.form0.id.value = ''; document.form0.num_empleado.value = '';}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="DISTRIBUCIÓN DE DÍAS DE VACACIONES"></jsp:param>
</jsp:include>
<table align="center" width="90%" cellpadding="0" cellspacing="0">
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td class="TableBorder TextRow01">
			<table align="center" width="90%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>	
	<tr class="TextRow01">
		<td colspan="3"> PAR&Aacute;METROS PARA LA DISTRIBUCI&Oacute;N DE D&Iacute;AS DE VACACIONES</td>
	</tr>
	
	   <tr class="TextRow01">
			<td colspan="3">&nbsp;</td>
       </tr>
	    <tr class="TextRow01">
			<td colspan="3">&nbsp;</td>
       </tr>
			
			
			   
  <tr class="TextHeader" align="center">
			<td>A&ntilde;o</td><td>Fecha</td><td></td>
  </tr>
  		
		
	<tr class="TextRow01" align="center">
	 	<td><%=fb.intBox("anio",anio,false,false,false,5,4,"Text10",null,"onFocus=\"this.select();\"")%></td>
		<td><%//=fb.select("mes","1=ENERO,2=FEBRERO,3=MARZO,4=ABRIL,5=MAYO,6=JUNIO,7=JULIO,8=AGOSTO,9=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",""+mes,false,false,0,"Text10",null,null,"","")%>
		<jsp:include page="../common/calendar.jsp" flush="true">
                            <jsp:param name="noOfDateTBox" value="2" />      
                            <jsp:param name="clearOption" value="true" />      
                            <jsp:param name="nameOfTBox1" value="fechaDesde" />      
                            <jsp:param name="valueOfTBox1" value="" />    
							<jsp:param name="nameOfTBox2" value="fechaHasta" />      
                            <jsp:param name="valueOfTBox2" value="" />      
                            <jsp:param name="format" value="dd/mm/yyyy" />      
                            <jsp:param name="fieldClass" value="Text10" />      
                            <jsp:param name="buttonClass" value="Text10" /> 
							</jsp:include>   
		
		
		</td>
		<td><%//=fb.select("periodo","1=QUINCENA 1,2=QUINCENA 2,3=AMBAS","3",false,false,0,"Text10",null,null,"","")%>
		Sin cabecera (Excel) ? <%=fb.checkbox("ctrlHeader","")%>
		</td>
	</tr>
    <tr class="TextRow01">
            <td colspan="3">ID. Empleado:&nbsp;<%=fb.intBox("id","",false,false,true,5,20,"Text10",null,"onDblClick=\"javascript:clearEmpleado()\"","Doble click para Limpiar Campos",false)%>
			 No. de Empleado:<%=fb.textBox("num_empleado","",false,false,true,5,"Text10",null,null)%>
			<%=fb.textBox("idDesc","",false,false,true,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addEmpleado()\"")%></td>
          </tr>	
	<tr class="TextRow01">
			<td colspan="3">&nbsp;</td>
       </tr>
	<tr>
			<td align="right" colspan="3"><%=fb.button("print","Imprimir",true,false,null,null,"onClick=\"javascript:printList()\"")%>&nbsp;&nbsp;&nbsp;<%=fb.button("print_det","Imprimir Detallado",false,false,null,null,"onClick=\"javascript:printList(0)\"")%>					</td>
	</tr>			 				 	
            <%=fb.formEnd(true)%>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>
	</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>