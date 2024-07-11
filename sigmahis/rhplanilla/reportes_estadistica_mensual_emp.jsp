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
==================================================================================
PLANILLA: PLA0124, PLA0125,PLA0116_CONTA, PLA0116, PLA0116B,PLA0116a
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdoCheckPla = new CommonDataObject();


String seccion = request.getParameter("seccion");
String empId = "";

String currDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String mes = currDateTime.substring(3,5);
String anio = currDateTime.substring(6,10);
String compania = (String)session.getAttribute("_companyId");

String arrMes ="01=Enero,02=Febrero,03=Marzo,04=Abril,05=Mayo,06=Junio,07=Julio,08=Agosto,09=Septiembre,10=Octubre,11=Noviembre,12=Diciembre";
//04/05/2011

cdoCheckPla = SQLMgr.getData("SELECT  COUNT(*) tot FROM  tbl_pla_planilla_encabezado WHERE TO_NUMBER(TO_CHAR(fecha_pago,'yyyy')) = "+anio+" AND TO_NUMBER(TO_CHAR(fecha_pago,'mm')) = "+mes+" AND cod_compania  = "+compania+" AND estado     = 'B'");


if (request.getMethod().equalsIgnoreCase("GET"))
{  
   
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>

<style>
	.cccBorder{
	     border-style:solid;
	}	

</style>

<script language="javascript">
document.title = 'Reporte Egresos - '+document.title;

function doAction(){newHeight();}


function addCargo(){
   abrir_ventana1("../common/search_cargo.jsp?fp=unidad");
}

function addSec(){
   abrir_ventana1("../common/search_depto.jsp?fp=seccion");
}

function addDpt(){
   abrir_ventana1("../common/search_depto.jsp?fp=unidad");
}
function  printList()
{
	var mes_ini = document.getElementById("mes_ini").value;
	var anio_ini = document.getElementById("anio_ini").value;
	var mes_fin = document.getElementById("mes_fin").value;
	var anio_fin = document.getElementById("anio_fin").value;
	var maxYr = <%=anio%>;	
	var tipo_estadis = document.getElementById("tipo_estadis").value;
	var totales = document.getElementById("totales").value;
	
	if ( anio_ini == "" || (anio_ini.length != 4) || anio_fin == "" || (anio_fin.length != 4) || (anio_ini.indexOf('.')>0) || isNaN(anio_ini) || (anio_fin.indexOf('.')>0) || isNaN(anio_fin) || (anio_ini<1900 || anio_ini>maxYr)   || (anio_fin<1900 || anio_fin>maxYr) ){
	    alert("Por favor introduzca un año válido!"); 
	    return false;
	}
	
	if ( totales == "" || totales == null || tipo_estadis == "" || tipo_estadis == null ) return false;
	
	if ( tipo_estadis == 'X_EST' && totales == '2'){ 
	     abrir_ventana("../rhplanilla/print_tot_x_estado.jsp?opt=x_est_dept&mes_i="+mes_ini+"&anio_i="+anio_ini+"&mes_f="+mes_fin+"&anio_f="+anio_fin);
	}
	else
	if ( tipo_estadis == 'X_EST' && totales == '1' ){
		abrir_ventana("../rhplanilla/print_tot_x_estado.jsp?opt=x_est_grl&mes_i="+mes_ini+"&anio_i="+anio_ini+"&mes_f="+mes_fin+"&anio_f="+anio_fin);
	}
	else
	if( tipo_estadis == "TOT_EMP" && totales == '1'){
	    abrir_ventana("../rhplanilla/print_x_total_emp.jsp?opt=x_tot_emp&mes_i="+mes_ini+"&anio_i="+anio_ini+"&mes_f="+mes_fin+"&anio_f="+anio_fin);
	}
	else
	if( tipo_estadis == "TOT_EMP" && totales == '2'){
	    abrir_ventana("../rhplanilla/print_x_total_emp.jsp?opt=x_tot_emp_dept&mes_i="+mes_ini+"&anio_i="+anio_ini+"&mes_f="+mes_fin+"&anio_f="+anio_fin);
	}
	else
	if( tipo_estadis == "GASTO_SAL" && totales == '2'){
	    abrir_ventana("../rhplanilla/print_x_gasto_sal.jsp?opt=x_tot_gasto_sal_dept&mes_i="+mes_ini+"&anio_i="+anio_ini);
	}
	else
	if( tipo_estadis == "GASTO_SAL" && totales == '1'){
	    abrir_ventana("../rhplanilla/print_x_gasto_sal.jsp?opt=x_tot_gasto_sal_gral&mes_i="+mes_ini+"&anio_i="+anio_ini);
	}

	
}

function getVal(val){
     document.getElementById("val").value = val;
	 
	 if ( val == 'rpt_res_x_sec' || val == 'rpt_det_x_sec' || val == 'sobre_tiempo' || val == 'rpt_res_x_pla8x11' ){
	      document.getElementById("xtra_param").style.display = "block";
	 }else{document.getElementById("xtra_param").style.display = "none";}
	 
	 if ( val == 'sobre_tiempo' ){
	     document.getElementById("param_dept").style.display = "none";
	 }else{
	    document.getElementById("param_dept").style.display = "block";
	 }
}

function doReset(){
   //document.location = "../rhplanilla/reporte_mensual_acu.jsp";
}
function ctrl(val){
	if ( val == "GASTO_SAL" ){
	    document.getElementById("anio_fin").disabled = true;
		document.getElementById("mes_fin").disabled = true;
	}else{
	   document.getElementById("anio_fin").disabled = false;
	   document.getElementById("mes_fin").disabled = false;
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<table align="center" width="90%" cellpadding="1" cellspacing="1">
	<tr><td colspan="9">&nbsp;</td></tr>
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

  <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
         <%fb = new FormBean("formUnidad",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>	
	        <tr class="TextHeader01">
		       <td colspan="9"> PARAMETROS PARA IMPRESI&Oacute;N DEL LISTADO DE:<br /><br /><ul><li>ESTAD&Iacute;STICA MENSUAL DE EMPLEADOS</li></ul></td>
	        </tr>            
           <tr class="TextRow02">
			   <td colspan="9">&nbsp;</td>
		   </tr>
           
          <tr style="font-weight:bold;">
		       <td colspan="9" class="TextRow01" align="center">
                    <fieldset style="border:#ccc 2px solid; width:800px; text-align:left; padding:0 10px 0 10px;" >
			            <legend class="Link01Bold" >Estad&iacute;stica</legend>
			            <p style="color:#fff; background-color:#004f9f; border:#ccc solid 1px; padding: 7px;">
			     			 Escoja el Tipo de Estad&iacute;stica y el modo<br />
			     			 Introduzca los par&aacute;metros para generar la estad&iacute;stica<br /><br />
			      			 Tipo de Estad&iacute;stica<br /><br/>
			                 <%=fb.select("tipo_estadis","TOT_EMP=Estadística de Total de Empleados,X_EST=Estadística de Totales por Estado,GASTO_SAL=Estadística de Gastos de Salario","TOT_EMP",false,false,0,null,null,"onchange=\"javascript:ctrl(this.value);\"")%>
			            </p>
               
               
                       <table width="100%">
                         <tr>
                           <td width="60%"></td><td width="10%"></td><td width="30%"></td>
                          </tr>
                           <tr>
                              <td>
                                 <fieldset style="height:126px;">
                                    <legend class="Liynk01Bold" >Par&aacute;metros</legend>
                                    <table>
                                       <tr>
                                          <td>Totales&nbsp;&nbsp;<%=fb.select("totales","1=General,2=Por Departamento","1")%></td>
                                       </tr>
                                       <tr><td>Año&nbsp;&nbsp;<%=fb.intBox("anio_ini",""+anio,false,false,false,5,4,"Text10",null,"onfocus=\"this.select()\"")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			                   Mes&nbsp;&nbsp;<%=fb.select("mes_ini",arrMes,mes)%></td>
			                           </tr>
                                       
                                       <tr><td>Año&nbsp;&nbsp;<%=fb.intBox("anio_fin",""+anio,false,false,false,5,4,"Text10",null,"onfocus=\"this.select()\"")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			             Mes&nbsp;&nbsp;<%=fb.select("mes_fin",arrMes,mes)%></td>
			                          </tr>
                                    
                                    </table>
                                 </fieldset>
                              </td>
                              <td>&nbsp;</td>
                              <td align="right">
                               <fieldset style="height:110px; text-align:center">
                                   <table>
                                       <tr>
                                          <td><%=fb.button("print","Generar Estadística",true,false,null,"height:50px; width:150px;","onClick=\"javascript:printList()\"")%><br/><br/>
				<%//=fb.button("cancel","Cancelar",false,false,null,"height:50px; width:150px;","onClick=\"javascript:doReset()\"")%></td>
                                       </tr>
                                   </table>
                               </fieldset>
                              </td>
                              
                           </tr>
	                   </table>
                       
                      
                    </fieldset>
               </td>
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