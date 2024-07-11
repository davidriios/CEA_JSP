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
document.title = 'Reporte Egresos - '+document.title;

function doAction(){
  newHeight();
}  
  
function  printList(opt)
{
   	var opt = opt;
	var mes_ini = document.getElementById("mes_ini").value;
	var anio_ini = document.getElementById("anio_ini").value;
	var mes_fin = document.getElementById("mes_fin").value;
	var anio_fin = document.getElementById("anio_fin").value;
	var maxYr = <%=anio%>;
	
	if ( opt == undefined || opt == "" ) return false;
	 
	if ( anio_ini == "" || anio_fin == "" || (anio_ini.length != 4) || 	(anio_ini.indexOf('.')>0) || isNaN(anio_ini) || (anio_fin.indexOf('.')>0)  && isNaN(anio_fin) || (anio_ini<1900 || anio_ini>maxYr) || (anio_fin<1900 || anio_fin>maxYr) ) {
	    alert("Por favor introduzca un año válido!"); 
	    return false;
	}

	abrir_ventana("../rhplanilla/print_egresos_x_cargo_liquid_x_motivo.jsp?opt="+opt+"&mes_ini="+mes_ini+"&anio_ini="+anio_ini+"&mes_fin="+mes_fin+"&anio_fin="+anio_fin);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="90%" cellpadding="0" cellspacing="0">
	<tr><td colspan="6">&nbsp;</td></tr>
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>	
	<tr class="TextHeader01">
		<td colspan="6"> PARAMETROS PARA IMPRESION DEL LISTADO DE:<br /><br /><ul><li>EGRESOS POR CARGO</li><li>TOTAL PAGADO EN LIQUIDACIONES</li></ul></td>
	</tr>
	     
	<tr class="TextRow01" >
	    <td width="20%">&nbsp;&nbsp;&nbsp;&nbsp;Mes y a&ntilde;o &nbsp;:&nbsp;Inicio&nbsp;&nbsp;&nbsp;&nbsp;</td> 
	   	<td width="15%"><%=fb.select("mes_ini",arrMes,mes)%></td>
		<td width="10%"><%=fb.intBox("anio_ini",""+anio,false,false,false,5,4,"Text10",null,"onfocus=\"this.select()\"")%></td>
		<td colspan="3">&nbsp;</td>
    </tr>
	
	<tr class="TextRow01" >
	    <td>&nbsp;&nbsp;&nbsp;&nbsp;Mes y a&ntilde;o &nbsp;:&nbsp;Final&nbsp;&nbsp;&nbsp;&nbsp;</td> 
	   	<td><%=fb.select("mes_fin",arrMes,mes)%></td>
		<td><%=fb.intBox("anio_fin",""+anio,false,false,false,5,4,"Text10",null,"onfocus=\"this.select()\"")%></td>	 
		<td colspan="3">&nbsp;</td>  
    </tr>
	<tr class="TextRow02">
		<td colspan="6">&nbsp;</td>
	</tr>
	<tr class="TextRow01">
		<td colspan="3"><%=fb.radio("egresos_x_cargo","eXc",false,false,false,null,null,"onClick=\"javascript:printList('eXc')\"","Imprimir Egresos por cargo")%>&nbsp;Egresos por cargo<br/>
		    <%=fb.radio("egresos_x_cargo","tPl",false,false,false,null,null,"onClick=\"javascript:printList('tPl')\"","Total pago en liquidaciones")%>&nbsp;Total pago en liquidaciones
		</td>
		<td colspan="3">&nbsp;</td>
	</tr>
 
	
	<tr class="TextRow02">
			<td align="right" colspan="6"><%//=fb.button("print","Imprimir",true,false,null,null,"onClick=\"javascript:printList()\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>					</td>
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