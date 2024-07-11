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
function addGerencia()
{
   //abrir_ventana1("../common/search_depto.jsp?fp=seccion");
}

/*function addEstado()
{
   abrir_ventana1("../common/search_depto.jsp?fp=estado");
}

function addEmpleado()
{
   abrir_ventana1("../common/search_empleado.jsp?fp=listado");
}*/
  
  
function  printList()
{
	var cargo = eval('document.formUnidad.cargo').value ;
	var depto = eval('document.formUnidad.depto').value ;
	var gerencia = eval('document.formUnidad.gerencia').value;
	var printSal = "S";
	
	if ( document.getElementById("printSal").checked == true ){
	   printSal = "N";
	}
	
	abrir_ventana("../rhplanilla/print_empleados_x_dept.jsp?cargo="+cargo+"&ger="+gerencia+"&dept="+depto+"&printSal="+printSal);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="90%" cellpadding="0" cellspacing="0">
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("formUnidad",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>	
	<tr class="TextRow01">
		<td width="150"> </td>
		<td colspan="2"> PARAMETROS PARA IMPRESION DEL LISTADO DE EMPLEADOS POR DEPARTAMENTO</td>
	</tr>
	           
  <tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
  </tr>
  		
		
	<tr class="TextRow01" >
	    <td align="right">Gerencia&nbsp;&nbsp;&nbsp;&nbsp;</td> 
	   	<td colspan="2"><%=fb.intBox("gerencia","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("secDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addGerencia()\"")%></td>     
	</tr>
	
	 <tr class="TextRow01">
	    <td align="right">Departamento&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td colspan="2"><%=fb.intBox("depto","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("deptoDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addDepto()\"")%></td>     </tr>
					
			  		
	<tr class="TextRow01">
	    <td align="right">Cargos o Funci&oacute;n&nbsp;&nbsp;&nbsp;&nbsp;</td>
	   	<td colspan="2"><%=fb.intBox("cargo","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("cargoDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addCargo()\"")%></td>    
	</tr>	
	
		
  <tr class="TextRow02">
		<td colspan="3">&nbsp;&nbsp;&nbsp;No Imprimir el Salario&nbsp;&nbsp;&nbsp;<%=fb.checkbox("printSal","S")%></td>
  </tr>
 
	
	<tr class="TextRow02">
			<td align="right" colspan="9"><%=fb.button("print","Imprimir",true,false,null,null,"onClick=\"javascript:printList()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>					</td>
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