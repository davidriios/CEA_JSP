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


if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");
if (request.getParameter("perLastLineNo") != null && !request.getParameter("perLastLineNo").equals("")) perLastLineNo = Integer.parseInt(request.getParameter("perLastLineNo"));
 
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
	newHeight();
	//parent.setHeight('secciones',document.body.scrollHeight);

}

          
function addCargo()
{
   abrir_ventana1("../common/search_cargo.jsp?fp=unidad");
}
function addDepto()
{
   abrir_ventana1("../common/search_depto.jsp?fp=unidad");
}
function addSec()
{
   abrir_ventana1("../common/search_depto.jsp?fp=seccion");
}

function addEstado()
{
   abrir_ventana1("../common/search_depto.jsp?fp=estado");
}

function addEmpleado()
{
   abrir_ventana1("../common/search_empleado.jsp?fp=listado");
}

function  printList(seccion)
{
var car = eval('document.formUnidad.cargo').value ;
var dep = eval('document.formUnidad.depto').value ;
var sec = eval('document.formUnidad.sec').value ;
var fechaIni ='';
var fechaFin ='';
if(eval('document.formUnidad.fechaIni'))fechaIni=eval('document.formUnidad.fechaIni').value ;
if(eval('document.formUnidad.fechaFin'))fechaFin=eval('document.formUnidad.fechaFin').value ;
//var section = eval('document.formUnidad.seccion').value ;

if (seccion=="1")
{
abrir_ventana("../rhplanilla/print_list_emp_unidad.jsp?cargo="+car+"&depto="+dep+"&sec="+sec);
}
else if(seccion=="2")
{
abrir_ventana("../rhplanilla/print_list_emp_fingreso.jsp?cargo="+car+"&depto="+dep+"&sec="+sec+"&fechaIni="+fechaIni+"&fechaFin="+fechaFin);
}
else if(seccion=="3")
{
var status = eval('document.formUnidad.estados').value ;
abrir_ventana("../rhplanilla/print_list_emp_estatus.jsp?cargo="+car+"&depto="+dep+"&sec="+sec+"&est="+status);
}
else if(seccion=="4")
{

abrir_ventana("../rhplanilla/print_list_emp_cargos.jsp");
}
else if(seccion=="5")
{
var id = eval('document.formUnidad.id').value ;
abrir_ventana("../rhplanilla/print_list_emp_exp.jsp?cargo="+car+"&depto="+dep+"&sec="+sec+"&empId="+id);
}
else if(seccion=="6")
{
abrir_ventana("../rhplanilla/print_list_emp_exp_uni.jsp?cargo="+car+"&depto="+dep+"&sec="+sec);
}
else if(seccion=="10")
{
var id = eval('document.formUnidad.id').value ;
abrir_ventana("../rhplanilla/print_list_emp_bec.jsp?cargo="+car+"&depto="+dep+"&sec="+sec+"&empId="+id);
}


}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("formUnidad",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>	
		<%=fb.hidden("baction","")%>	
		<%=fb.hidden("perLastLineNo",""+perLastLineNo)%>
		<%=fb.hidden("seccion",seccion)%>
		<%=fb.hidden("area",area)%>
		<%=fb.hidden("ue_codigo",grupo)%>
		<%=fb.hidden("grupo",grupo)%>
		<%=fb.hidden("estado",estado)%>
		<%=fb.hidden("keySize",""+perHash.size())%>	
				
	<tr class="TextRow01">
		<td width="150"> </td>
		<td colspan="2"> PARAMETROS PARA REPORTE DE EMPLEADOS  </td>
	</tr>
	              <%	 
				  if (seccion.equalsIgnoreCase("1"))
				 {
				 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> POR UNIDAD ADMINISTRATIVA </td>
					</tr>
			
			<% } else  if (seccion.equalsIgnoreCase("2"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> POR FECHA DE INGRESO </td>
					</tr>
			
			<% } else  if (seccion.equalsIgnoreCase("3"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> POR ESTATUS </td>
					</tr>
			
			<%} else  if (seccion.equalsIgnoreCase("4"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> POR CARGOS / OCUPACIONES </td>
					</tr>
					
				<%} else  if (seccion.equalsIgnoreCase("5"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> POR INFORMACION GENERAL DEL EXPEDIENTE </td>
					</tr>	
					
				<%} else  if (seccion.equalsIgnoreCase("6"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> INFORMACION GENERAL POR SECCION </td>
					</tr>	
				<%} else  if (seccion.equalsIgnoreCase("10"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> BECARIOS </td>
					</tr>	
				<% } 
			%>
					 
	
  <tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
  </tr>
  
  <%if (seccion.equalsIgnoreCase("2")){%>
					<tr class="TextRow01">
						<td width="150">FECHA DE INGRESO</td>
						<td colspan="2"> 
						<jsp:include page="../common/calendar.jsp" flush="true">
        	<jsp:param name="noOfDateTBox" value="2" />
        	<jsp:param name="clearOption" value="true" />
        	<jsp:param name="nameOfTBox1" value="fechaIni" />
        	<jsp:param name="valueOfTBox1" value="" />
          <jsp:param name="nameOfTBox2" value="fechaFin" />
        	<jsp:param name="valueOfTBox2" value="" />
			</jsp:include>
						</td>
					</tr>
			
			<%}%>					
		  		
	<tr class="TextRow01">
	    <td>Cargos/Ocupación</td>
	   	<td colspan="2"><%=fb.intBox("cargo","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("cargoDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addCargo()\"")%></td>     
	</tr>
		
  <tr class="TextRow02">
		<td colspan="3">&nbsp;</td>
  </tr>

  <tr class="TextRow01">
	    <td>Departamento</td>
		<td colspan="2"><%=fb.intBox("depto","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("deptoDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addDepto()\"")%></td>     
  </tr>
				
  <tr class="TextRow02">
		<td colspan="3">&nbsp;</td>
  </tr>
     
 	<tr class="TextRow01" >
	    <td>Sección</td> 
	   	<td colspan="2"><%=fb.intBox("sec","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("secDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addSec()\"")%></td>     
	</tr>
	 <%if (seccion.equalsIgnoreCase("2")){%>
	<tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
  </tr>
  <tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
  </tr>
 
		
					<%	} 
					  if (seccion.equalsIgnoreCase("3"))
					 {
					 %>
					  <tr class="TextRow02">
								<td colspan="3">&nbsp;</td>
  					</tr>

 					 <tr class="TextRow01">
	    				<td>Estado</td>
							<td colspan="2"><%=fb.intBox("estados","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("estadoDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addEstado()\"")%></td>     
	</tr>
 					 <%
					 }
					 %>
					 
					 	<%	 
					  if (seccion.equalsIgnoreCase("5") || (seccion.equalsIgnoreCase("10")))
					 {
					 %>
					  <tr class="TextRow02">
								<td colspan="3">&nbsp;</td>
  					</tr>

 					 <tr class="TextRow01">
	    				<td>Empleado </td>
							<td colspan="2"><%=fb.intBox("id","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("idDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.textBox("num","",false,false,true,5,5,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addEmpleado()\"")%></td>     
	</tr>
 					 <%
					 }
					 %>
   
	
	
	<tr class="TextRow02">
			<td align="right" colspan="9"><%=fb.button("print","Imprimir",true,false,null,null,"onClick=\"javascript:printList("+seccion+")\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>					</td>
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
else
{   
 
     
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empl_unidad_detail.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empl_unidad_detail.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>