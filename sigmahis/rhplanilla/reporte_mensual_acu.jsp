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
String fg = request.getParameter("fg");

String arrMes ="01=Enero,02=Febrero,03=Marzo,04=Abril,05=Mayo,06=Junio,07=Julio,08=Agosto,09=Septiembre,10=Octubre,11=Noviembre,12=Diciembre";
//04/05/2011

//cdoCheckPla = SQLMgr.getData("SELECT  COUNT(*) tot FROM tbl_pla_planilla_encabezado WHERE TO_NUMBER(TO_CHAR(fecha_pago,'yyyy')) = "+anio+" AND TO_NUMBER(TO_CHAR(fecha_pago,'mm')) = "+mes+" AND cod_compania  = "+compania+" AND estado = 'B'");

if(fg==null)fg="";
if (request.getMethod().equalsIgnoreCase("GET"))
{  
   
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reporte Egresos - '+document.title;

function doAction(){newHeight();}
function addCargo(){abrir_ventana1("../common/search_cargo.jsp?fp=unidad");}
function addSec(){abrir_ventana1("../common/search_depto.jsp?fp=seccion");}
function addDpt(){abrir_ventana1("../common/search_depto.jsp?fp=unidad");}
function  printList()
{
	var mes = document.getElementById("mes").value;
	var anio = document.getElementById("anio").value;
	var cargo = document.getElementById("cargo").value;
	var sec = document.getElementById("sec").value;
	var dept = document.getElementById("depto").value;
	var maxYr = <%=anio%>;	
	var opt = document.getElementById("val").value;
	 
	if ( anio == "" || (anio.length != 4) || 	(anio.indexOf('.')>0) || isNaN(anio) || (anio<1900 || anio>maxYr) ){
	    alert("Por favor introduzca un año válido!"); 
	    return false;
	}

	if ( opt == "" ) return false
	
	switch(opt){
	
	    case 'rpt_res':
		   abrir_ventana("../rhplanilla/print_reporte_resumido.jsp?fg=RES&mes="+mes+"&anio="+anio+"&sec="+sec+"&cargo="+cargo);
		break;	
	    case 'rpt_det':
		   //abrir_ventana("../rhplanilla/print_reporte_detallado.jsp?opt="+opt+"&mes="+mes+"&anio="+anio+"&sec="+sec+"&cargo="+cargo);
		   abrir_ventana("../rhplanilla/print_reporte_resumido.jsp?fg=DET&mes="+mes+"&anio="+anio+"&sec="+sec+"&cargo="+cargo);
		break;	
		case 'rpt_res_x_sec':
		   abrir_ventana("../rhplanilla/print_reporte_resumido.jsp?fg=RES&fp=SEC&mes="+mes+"&anio="+anio+"&sec="+sec+"&cargo="+cargo+"&dept="+dept);
		break;
		case 'rpt_det_x_sec':
		   abrir_ventana("../rhplanilla/print_reporte_resumido.jsp?fg=DET&fp=SEC&mes="+mes+"&anio="+anio+"&sec="+sec+"&cargo="+cargo+"&dept="+dept);
		break;
		case 'sobre_tiempo':
		   abrir_ventana("../rhplanilla/print_salario_sobre_tiempo.jsp?opt="+opt+"&mes="+mes+"&anio="+anio+"&sec="+sec+"&cargo="+cargo);
		break;   
        case 'gasto_rep': 
		   abrir_ventana("../rhplanilla/print_gasto_rep.jsp?opt="+opt+"&mes="+mes+"&anio="+anio);
		break;
		case 'rpt_res_x_pla8x11': 
		   abrir_ventana("../rhplanilla/print_reporte_resumido_8x11.jsp?opt="+opt+"&mes="+mes+"&anio="+anio+"&sec="+sec+"&cargo="+cargo+"&dept="+dept);
		break;
		case 'rpt_res2':
		   abrir_ventana2("../rhplanilla/print_reporte_resumido.jsp?fg=RES2&mes="+mes+"&anio="+anio+"&sec="+sec+"&cargo="+cargo);
		break;
	
  } //switch
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

function cargarDatos(){
	var mes = document.getElementById("mes").value;
	var anio = document.getElementById("anio").value;
	var compania = <%=compania%>;
	var maxYr = <%=anio%>;
 	
	if ( anio == "" || (anio.length != 4) || 	(anio.indexOf('.')>0) || isNaN(anio) || (anio<1900 || anio>maxYr) ){
	    alert("Por favor introduzca un año válido!"); 
	    return false;
	}
	
	var tot = getDBData('<%=request.getContextPath()%>','getPlanillasPendiente('+anio+','+mes+','+compania+') tot','dual');
		  if ( tot > 0 )
		  {
		     document.getElementById("msg").style.display="block";
		     document.getElementById("msg").firstChild.innerHTML = "Hay "+tot+" planilla(s) pendiente(s) por cerrar!!!";
		  }  
	
	showPopWin('../common/run_process.jsp?fp=CAPLA&actType=50&docType=CAPLA&docId='+anio+' - '+mes+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&mes='+mes,winWidth*.75,winHeight*.65,null,null,'');

}
function doReset(){
   document.location = "../rhplanilla/reporte_mensual_acu.jsp";
}
function addPla()
{
var anio = eval('document.formUnidad.anio').value;
abrir_ventana1('../common/search_planilla.jsp?fp=planillaAjusteRep&anio='+anio);
}
function printAjuste(fg)
{
var anio = eval('document.formUnidad.anio').value;
var codPlanilla = eval('document.formUnidad.codPlanilla').value;
var numPlanilla = eval('document.formUnidad.numPlanilla').value;
if(numPlanilla !='')
abrir_ventana1('../rhplanilla/print_comprob_ajustes_det.jsp?fp=planillaAjusteRep&anio='+anio+'&numPlanilla='+numPlanilla+'&codPlanilla='+codPlanilla+'&fg='+fg);
else alert('Seleccione Planilla..');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE AJUSTE"></jsp:param>
	</jsp:include>

<table align="center" width="90%" cellpadding="1" cellspacing="1">
	<tr><td colspan="9">&nbsp;</td></tr>
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%fb = new FormBean("formUnidad",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>	
	<%if(!fg.trim().equals("AJ")){%>
	<tr class="TextHeader01">
		<td colspan="9"> PARAMETROS PARA IMPRESION DEL LISTADO DE:<br /><br /><ul><li>INFORME MENSUAL DE ACUMULADO</li></ul></td>
	</tr>
	     
	<tr class="TextRow01" >
	    <td width="12%">&nbsp;&nbsp;Mes y a&ntilde;o &nbsp;:&nbsp;&nbsp;&nbsp;&nbsp;</td> 
	   	<td width="15%"><%=fb.select("mes",arrMes,mes)%></td>
		<td width="10%"><%=fb.intBox("anio",""+anio,false,false,false,5,4,"Text10",null,"onfocus=\"this.select()\"")%></td>
		<td width="15"><%=fb.button("cargar_datos","Cargar Datos",true,false,null,null,"onClick=\"javascript:cargarDatos()\"")%></td>
		<td width="48%" colspan="5">&nbsp;</td>
		<!--<td width="10%">&nbsp;</td>
		<td width="10%">&nbsp;</td>
		<td width="10%">&nbsp;</td>
		<td width="8%">&nbsp;</td>-->
    </tr>

	<tr id="msg" class="TextRow01 Text14" style="height:28px; color:#f00; font-weight:bold; display:none;">
		<td colspan="9" align="center">&nbsp;</td>
	</tr>
	
	<tr class="TextRow02">
		<td colspan="9">&nbsp;</td>
	</tr>
	
	<tr class="TextRow01" style="display:;" id="param">
	<td colspan="4">
	<fieldset style="border:#ccc 2px solid;" >
		   <legend class="Link01Bold" >Tipo de Impresi&oacute;n</legend>
	<table width="100%">
	   <tr>
			<td><%=fb.radio("rpt_mensual_acu","rpt_res",false,false,false,null,null,"onClick=\"getVal(this.value);\"","Imprimir Reporte Resumido")%>&nbsp;Reporte Resumido
			</td>
		    <td><%=fb.radio("rpt_mensual_acu","rpt_det",false,false,false,null,null,"onClick=\"getVal(this.value);\"","Reporte Detallado")%>&nbsp;Reporte Detallado
		   </td>
		   
		</tr>
	   <tr>
			<td><%=fb.radio("rpt_mensual_acu","rpt_res_x_sec",false,false,false,null,null,"onClick=\"getVal(this.value);\"","Reporte Resumido por Secci&oacute;n")%>&nbsp;Reporte Resumido por Secci&oacute;n
			</td>
		    <td><%=fb.radio("rpt_mensual_acu","rpt_det_x_sec",false,false,false,null,null,"onClick=\"getVal(this.value);\"","Reporte Detallado por Secci&oacute;")%>&nbsp;Reporte Detallado por Secci&oacute;n
		   </td>
		</tr>
		<tr>
			<td><!--<%=fb.radio("rpt_mensual_acu","rpt_res_x_pla8x11",false,false,false,null,null,"onClick=\"getVal(this.value);\"","Reporte Resumido (Planilla 8 1/2 x 11)")%>&nbsp;Reporte Resumido (Planilla 81/2 x)-->
			<authtype type='56'><%=fb.radio("rpt_mensual_acu","rpt_res2",false,false,false,null,null,"onClick=\"getVal(this.value);\"","Reporte Resumido para Gerencia")%>&nbsp;Reporte Resumido para Gerencia Gral</authtype><!---->
			</td>
		    <td>&nbsp;</td>
		</tr>
	
	   <tr><td colspan="2" style="border-bottom:#ccc 2px solid;">&nbsp;</td></tr>
		<tr>
			<td><%=fb.radio("rpt_mensual_acu","sobre_tiempo",false,false,false,null,null,"onClick=\"getVal(this.value);\"","Imprimir Salario y Sobretiempo")%>&nbsp;Inf. Salario y Sobretiempo
			</td>
		    <td><%=fb.radio("rpt_mensual_acu","gasto_rep",false,false,false,null,null,"onClick=\"getVal(this.value);\"","Total pago en liquidaciones")%>&nbsp;Gastos de Rep. Mensual
		   </td>
		</tr>
		
	</table>
	</fieldset>
	</td>
	<td colspan="5">
	
	<table>
	<tr>
		<td width="60%">&nbsp;</td>
		<td><%=fb.button("print","Imprimir",true,false,null,"height:50px; width:80px;","onClick=\"javascript:printList()\"")%></td>
	<tr>
		<td>&nbsp;</td>
		<td><%//=fb.button("cancel","Cancelar",false,false,null,"height:50px; width:80px;","onClick=\"javascript:doReset()\"")%>
		</td>
	</tr>
	
	</table>
	
	
	</td>
	</tr>

 <%=fb.hidden("val","")%>
	
	<tr class="TextRow01" style="display:none;" id="xtra_param">
	    <td colspan="9">
			<fieldset style="border:#ccc 2px solid; margin-top:10px;" >
		     <legend class="Link01Bold" >Par&aacute;metros de la Impresi&oacute;n</legend>
		
			<table width="100%">
			  <tr>
			    <td>Cargos/Ocupaci&oacute;n</td>
			    <td><%=fb.intBox("cargo","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("cargoDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addCargo()\"")%></td></tr>
			 <tr id="param_dept">
				<td>Departamento</td>
			    <td><%=fb.intBox("depto","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("deptoDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addDpt()\"")%>
			    </td>  
	        </tr>
			<tr><td>Secci&oacute;n</td>
			<td><%=fb.intBox("sec","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("secDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addSec()\"")%>
			</td>  
	         </tr>
		</table>
		</fieldset>
		</td>
	</tr>	
	<%}else if(fg.trim().equals("AJ")){%>		 	
	<tr class="TextHeader01">
		<td colspan="9"> PARAMETROS PARA IMPRESION DE PLANILLA DE AJUSTES</td>
	</tr>
	<tr class="TextRow01">
		<td colspan="2">Año<%=fb.intBox("anio",anio,true,false,false,5,4,"Text12",null,null)%></td>
		<td colspan="7">Num. Planilla<%=fb.intBox("numPlanilla","",true,false,false,5,3,"Text12",null,null)%>Tipo Planilla<%=fb.intBox("codPlanilla","",true,false,false,5,3,"Text12",null,null)%>
		<%=fb.textBox("descPlanilla","",false,false,true,30,"Text12",null,null)%>
			<%=fb.button("btnper","...",true,false,null,null,"onClick=\"javascript:addPla()\"","")%></td>
	</tr>
	<tr class="TextRow01">
		<td colspan="4" align="center"><%=fb.button("print","Imprimir",true,false,null,"height:50px; width:80px;","onClick=\"javascript:printAjuste('D')\"")%></td>
		<td colspan="5" align="center"><%=fb.button("print","Reporte Resumido",true,false,null,"height:50px; width:150px;","onClick=\"javascript:printAjuste('R')\"")%></td>
	<tr>
	
	<%}%>			 	
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