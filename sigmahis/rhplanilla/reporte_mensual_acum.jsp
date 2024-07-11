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
<%

/**
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String seccion = request.getParameter("seccion");
String empId = "";

String currDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String mes = currDateTime.substring(3,5);
String anio = currDateTime.substring(6,10);

String arrMes ="01=Enero,02=Febrero,03=Marzo,04=Abril,05=Mayo,06=Junio,07=Julio,08=Agosto,09=Septiembre,10=Octubre,11=Noviembre,12=Diciembre";
//04/05/2011

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
document.title = 'Reporte Salarios - '+document.title;

function doAction(){newHeight();}


function addCargo(){
   abrir_ventana1("../common/search_cargo.jsp?fp=unidad");
}

function addSec(){
   abrir_ventana1("../common/search_depto.jsp?fp=seccion");
}

function  printList()
{
	var mes = document.getElementById("mes").value;
	var anio = document.getElementById("anio").value;
	var cargo = document.getElementById("cargo").value;
	var sec = document.getElementById("sec").value;
	var maxYr = <%=anio%>;	
	var opt = document.getElementById("val").value;
	 
	if ( anio == "" || (anio.length != 4) || 	(anio.indexOf('.')>0) || isNaN(anio) || (anio<1900 || anio>maxYr) ){
	    alert("Por favor introduzca un año válido!"); 
	    return false;
	}

	if ( opt == "" ) {
	 alert("Por favor seleccione un Reporte de la Lista!"); 
	    return false;
		}

	if ( opt == "sobre_tiempo" ){
			abrir_ventana("../rhplanilla/print_salario_sobre_tiempo.jsp?opt="+opt+"&mes="+mes+"&anio="+anio+"&sec="+sec+"&cargo="+cargo);
	}
	
	if ( opt == "gasto_rep" ){
		abrir_ventana("../rhplanilla/print_gasto_rep.jsp?opt="+opt+"&mes="+mes+"&anio="+anio+"&sec="+sec+"&cargo="+cargo);
	}
}

function getVal(val){document.getElementById("val").value = val;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE AJUSTE"></jsp:param>
	</jsp:include>

<table align="center" width="90%" cellpadding="0" cellspacing="0">
	<tr><td colspan="6">&nbsp;</td></tr>
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		


<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("formUnidad",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>	
	<tr class="TextHeader01">
		<td colspan="6"> PARAMETROS PARA IMPRESION DEL LISTADO DE:<br /><br /><ul><li>INFORME MENSUAL DE ACUMULADO</li></ul></td>
	</tr>
	     
	<tr class="TextRow01" >
	    <td width="20%">Mes y a&ntilde;o &nbsp;:&nbsp;Inicio&nbsp;&nbsp;&nbsp;&nbsp;</td> 
	   	<td width="15%"><%=fb.select("mes",arrMes,mes)%></td>
		<td width="10%"><%=fb.intBox("anio",""+anio,false,false,false,5,4,"Text10",null,"onfocus=\"this.select()\"")%></td>
		<td colspan="3">&nbsp;</td>
    </tr>

	<tr class="TextRow02">
		<td colspan="6">&nbsp;</td>
	</tr>
	<tr class="TextRow01">
		<td colspan="3"><%=fb.radio("rpt_mensual_acu","sobre_tiempo",false,false,false,null,null,"onClick=\"getVal(this.value);\"","Imprimir Salario y Sobretiempo")%>&nbsp;Inf. Salario y Sobretiempo
		</td>
		<td colspan="3">
		
			<table width="100%">
			  <tr>
			    <td width="34%">Cargos/Ocupaci&oacute;n</td>
		      <td width="66%"><%=fb.intBox("cargo","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("cargoDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addCargo()\"")%></td>
			  </tr>
			
		</table>
		</td>
	</tr>
 
     <tr class="TextRow01">
         <td colspan="3">
		    <%=fb.radio("rpt_mensual_acu","gasto_rep",false,false,false,null,null,"onClick=\"getVal(this.value);\"","Reporte de Gastos de Representación")%>&nbsp;Gastos de Rep. Mensual
		</td>
		<td width="19%">Secci&oacute;n</td>
			<td width="36%"><%=fb.intBox("sec","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("secDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addSec()\"")%>			</td>  
	    </tr>
 <%=fb.hidden("val","")%>
	
	<tr class="TextRow02">
			<td align="right" colspan="6"><%=fb.button("print","Imprimir",true,false,null,null,"onClick=\"javascript:printList()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>					</td>
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