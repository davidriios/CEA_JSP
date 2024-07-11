<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList list = new ArrayList();
ArrayList alTipo = new ArrayList();
ArrayList alMot = new ArrayList();
String change = request.getParameter("change");
String seccion = request.getParameter("seccion");
String tipo = request.getParameter("tipo");
String appendFilter = "";
String provincia = "";
String sigla = "";
String tomo = "";
String asiento = "";
String numEmpleado = "";
String empId = "";

String area = "";
String grupo = "";
String key = "";
String sql = "";
String date = "";
String estado = "";
int perLastLineNo = 0;
int count = 0;
if (tipo==null) tipo=""; 

if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");
if (request.getParameter("perLastLineNo") != null && !request.getParameter("perLastLineNo").equals("")) perLastLineNo = Integer.parseInt(request.getParameter("perLastLineNo"));
 
if (request.getMethod().equalsIgnoreCase("GET"))
{ 
 
   alTipo = sbb.getBeanList(ConMgr.getConnection(), "select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_pla_motivo_falta order by descripcion ", CommonDataObject.class);
   
      alMot = sbb.getBeanList(ConMgr.getConnection(), "select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_pla_ap_tipo_accion order by codigo ", CommonDataObject.class);
	  
	  
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

function  printList(seccion)
{
if(seccion=="7")
{
var mes = eval('document.formUnidad.mes').value ;
var anio = eval('document.formUnidad.anio').value ;
var accion = eval('document.formUnidad.accion').value ;
abrir_ventana("../rhplanilla/print_list_emp_ing.jsp?mes="+mes+"&anio="+anio+"&accion="+accion);
} else if(seccion=="8")
{
var mes = eval('document.formUnidad.mes').value ;
var anio = eval('document.formUnidad.anio').value ;
var tipo = eval('document.formUnidad.tipo').value ;
abrir_ventana("../rhplanilla/print_list_emp_lic.jsp?mes="+mes+"&anio="+anio+"&tipo="+tipo);
} else if(seccion=="9")
{
var mes = eval('document.formUnidad.mes').value ;
var anio = eval('document.formUnidad.anio').value ;
var pert = eval('document.formUnidad.pert').value ;
var sind = eval('document.formUnidad.sind').value ;
abrir_ventana("../rhplanilla/print_list_emp_sind.jsp?pert="+pert+"&sind="+sind);
}  else if(seccion=="11")
{
var mes = eval('document.formUnidad.mes').value ;
var anio = eval('document.formUnidad.anio').value ;

abrir_ventana("../rhplanilla/print_list_emp_fall.jsp?mes="+mes+"&anio="+anio);
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
				   	if (seccion.equalsIgnoreCase("7"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> ACCIONES DE INGRESOS, MOVILIDAD Y EGRESOS POR MES </td>
					</tr>		
					<%} else  if (seccion.equalsIgnoreCase("8"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> MOTIVOS DE FALTAS POR MES </td>
					</tr>
					<%} else  if (seccion.equalsIgnoreCase("9"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> EMPLEADOS POR SINDICATO </td>
					</tr>
					<% }
					     else  if (seccion.equalsIgnoreCase("11"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="150"> </td>
						<td colspan="2"> FALLECIMIENTO DE PARIENTES DE EMPLEADOS (Mensual / Anual)</td>
					</tr>
					<% }
					%>
					 
	
  <tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
  </tr>
  					
		  		
	<tr class="TextRow01">
	    <td>Mes</td>
	   	<td colspan="2"><%=fb.select("mes","1=ENERO ,2=FEBRERO ,3=MARZO ,4=ABRIL ,5=MAYO ,6=JUNIO ,7=JULIO ,8=AGOSTO ,9=SEPTIEMBRE ,10=OCTUBRE ,11=NOVIEMBRE ,12=DICIEMBRE ","",false,false,0,"T")%></td> 
		    
	</tr>
		
  <tr class="TextRow02">
		<td colspan="3">&nbsp;</td>
  </tr>

  <tr class="TextRow01">
	    <td>Año</td>
		<td colspan="2"><%=fb.intBox("anio","",false,false,false,5,5,"Text10",null,null)%></td>     
  </tr>
				
  <tr class="TextRow02">
		<td colspan="3">&nbsp;</td>
  </tr>
  
  	 <%	 
				   	if (seccion.equalsIgnoreCase("7"))
					 {
					 %>
   <tr class="TextRow01">
	    <td>Tipos de Acciones </td>
		<td colspan="2"> <%=fb.select("accion",alMot,"", false, false, 0,"T")%> </td>     
  </tr>
                    <% } %>
  
  					 <%	 
				   	if (seccion.equalsIgnoreCase("8"))
					 {
					 %>
   <tr class="TextRow01">
	    <td>Motivo de Falta</td>
		<td colspan="2"> <%=fb.select("tipo",alTipo,"", false, false, 0,"T")%> </td>     
  </tr>
                    <% } %>
					
					
					<%	 
				   	if (seccion.equalsIgnoreCase("9"))
					 {
					 %>
   <tr class="TextRow01">
	    <td>Pertenece </td>
		<td colspan="2"> <%=fb.select("pert","S=PERTENCE,N=NO PERTECENE","",false,false,0," ")%></td>
  </tr>
  
   <tr class="TextRow02">
	    <td>Sindicato </td>
		<td colspan="2"><%=fb.select("sind","SITRACHS=SITRACHS,SITRACHLAP=SITRACHLAP,NINGUNO=NINGUNO ","",false,false,0,"T")%> </td>     
  </tr>
   <tr class="TextRow01">
		<td colspan="3">&nbsp;</td>
  </tr>
  
                    <% } %>
					
					
					
  <tr class="TextRow02">
			<td align="right" colspan="9"><%=fb.button("print","Imprimir",true,false,null,null,"onClick=\"javascript:printList("+seccion+")\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>	</td>
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empl_general_detail.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empl_general_detail.jsp")%>';
<%
	}
	else
	{
%>

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