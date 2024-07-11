<%//@ page errorPage="../error.jsp"%>
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
String mes1  = cDateTime.substring(3,5);
String mes2  = cDateTime.substring(3,5);
String mes3  = cDateTime.substring(3,5);
String mes4  = cDateTime.substring(3,5);
String mes5  = cDateTime.substring(3,5);
String mes6  = cDateTime.substring(3,5);
String mes7  = cDateTime.substring(3,5);
String mes8  = cDateTime.substring(3,5);
String mes9  = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String dia  = CmnMgr.getCurrentDate("dd");

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
document.title = 'Reporte de Admision y Censo de Pacientes - '+document.title;
function doAction()
{
}

function showReporte(value)
{
   var sala = '';//eval('document.form0.sala').value  ;
   var mes  = document.getElementById('mes').value;
   var mes1  = document.getElementById('mes1').value;
   var mes2  = document.getElementById('mes2').value;
   var mes3  = document.getElementById('mes3').value;
   var mes4  = document.getElementById('mes4').value;
   var mes5  = document.getElementById('mes5').value;
   var mes6  = document.getElementById('mes6').value;
   var mes7  = document.getElementById('mes7').value;
   var mes8  = document.getElementById('mes8').value;
   var mes9  = document.getElementById('mes9').value;
   var anio = document.getElementById('anio').value;
   var anio1 = '';//eval('document.form0.anio1').value ;
   var diasT = '';//eval('document.form0.diasT').value ;
   var fechaini   = '';//eval('document.form0.fechaini').value;
   var aseguradora = '';//eval('document.form0.aseguradora').value;
   var habitacion  = '';//eval('document.form0.habitacion').value;
   var aseguradora1 = '';//eval('document.form0.aseguradora1').value;

	if(value=="1")
	{
		abrir_ventana('../admision/print_laboratorio.jsp?anio='+anio);
	}
	if(value=="7")
	{
		var msg='';
			//if(mes1 =='')
					//msg =' Mes1';
			if(anio =='')
			 //if(msg =='')
					msg +='Año';
				else msg +=' , Año'
			//if(msg=='')
			abrir_ventana('../admision/print_cantidad_hsp.jsp?anio='+anio+'&mes1='+mes1);
			//else CBMSG.warning('Seleccione '+msg);
	}
	if(value=="3")
	{
	abrir_ventana2('../admision/print_er.jsp?anio='+anio);
	//print_p_activos_adm3040.jsp
	}
	else if(value=="4")
	{
	abrir_ventana2('../admision/print_admisiones.jsp?anio='+anio);
	}
	else if(value=="5")
	{
	abrir_ventana2('../admision/print_pacientes_categoria.jsp?anio='+anio);
	}
	else if(value =="6")
	{
	abrir_ventana('../admision/print_cirugia.jsp?anio='+anio);
	}
	else if(value == "12")
	{
		var msg='';
			//if(mes1 =='')
					//msg =' Mes1';
			if(anio =='')
			 //if(msg =='')
					msg +='Año';
				else msg +=' , Año'
			//if(msg=='')
			abrir_ventana('../admision/print_cantidad_amb.jsp?anio='+anio+'&mes='+mes);
			//else CBMSG.warning('Seleccione '+msg);
	}
	else if(value == "2")
	{
	abrir_ventana2('../admision/print_ingresos.jsp?anio='+anio+'&mes2='+mes2);
	}
	else if(value == "9")
	{var nh='';
		if(document.form0.nh.checked==true) nh = "S";
	abrir_ventana2('../admision/print_rep_nacimientos.jsp?anio='+anio+'&nh='+nh);
	}
	else if(value == "8")
	{
	abrir_ventana2('../admision/print_cirugia_hsp.jsp?anio='+anio+'&mes3='+mes3);
	}
	else if(value == "11")
	{
	abrir_ventana2('../admision/print_radioalogia.jsp?anio='+anio);
	}
	if(value=="10")
	{
	abrir_ventana('../admision/print_prueba_rx.jsp?anio='+anio);
	}
	if(value=="13")
	{
	abrir_ventana('../admision/print_prueba_lc.jsp?anio='+anio);
	}
	if(value=="14")
	{
	abrir_ventana('../admision/print_cantidad_rx.jsp?anio='+anio+'&mes4='+mes4);
	}
	if(value=="15")
	{
	abrir_ventana('../admision/print_cantidad_lc.jsp?anio='+anio+'&mes5='+mes5);
	}
    if(value=="16")
	{
	abrir_ventana('../admision/print_especialidades.jsp?anio='+anio+'&mes6='+mes6);
	}
	if(value=="17")
	{
	abrir_ventana('../admision/print_admisiones_egresos.jsp?anio='+anio+'&mes8='+mes8);
	}
	if(value=="18")
	{
	abrir_ventana('../admision/print_medico_accionista.jsp?anio='+anio+'&mes7='+mes7);
	}
	if(value=="19")
	{
	abrir_ventana('../admision/print_procedimiento.jsp?anio='+anio);
	}
	if(value=="20")
	{
	abrir_ventana('../admision/print_cargos_especialidad.jsp?anio='+anio+'&mes9='+mes9);
	}



}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE RECIBOS"></jsp:param>
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
            <td colspan="3">REPORTE DE ESTADISTICAS</td>
          </tr>
          <tr class="TextHeader">
            <td align="center" width="50%">Nombre del reporte</td>
            <td align="center" width="10%">Año</td>
			<td align="center" width="40%">Mes</td> 
          </tr>

          <tr class="TextRow01">
            <td><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>ER</td>
			<td rowspan="20" valign="middle"><%=fb.textBox("anio",anio,false,false,false,7)%></td>
			<td>&nbsp;&nbsp;</td>
          </tr>

          <tr class="TextRow01">
            <td><%=fb.radio("reporte1","4",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Admisiones</td>  
			<td>&nbsp;</td>
          </tr>
          <tr class="TextRow01">
            <td ><%=fb.radio("reporte1","5",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Categoria de Pacientes </td>
            <td>&nbsp;</td>
          </tr>
		  <tr class="TextRow01">
			<td width="50%"><%=fb.radio("reporte1","6",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Cirugias</td>
			<td>&nbsp;</td>
		  </tr>
		  <tr class="TextRow01">
				<td width="50%"><%=fb.radio("reporte1","19",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Procedimientos</td>
				<td>&nbsp;&nbsp;&nbsp;</td>
		   </tr>
           <tr class="TextRow01">
            <td width="50%"><%=fb.radio("reporte1","9",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Nacimientos&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.checkbox("nh","false")%><font class="RedText" size="2">Nacidos en Hospital</font></td>
			<td>&nbsp;</td>
          </tr>
 		  <tr class="TextRow01">
			<td><%=fb.radio("reporte1","7",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Top Ten - Cantidad de Pacientes Hospitalizados por Medico</td>
			<td> &nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes1","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes1,false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;</td>
		</tr>
							

   <tr  class="TextRow01">
          <td><%=fb.radio("reporte1","12",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Top Ten - Cantidad de Cirugias Ambulatorias por Medico</td>
		    <td> &nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes,false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;</td>
        </tr>
		

 <tr  class="TextRow01">
          <td><%=fb.radio("reporte1","11",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Radiologia </td>
		  <td>&nbsp;&nbsp;</td>
        </tr>
        <tr  class="TextRow01">
          <td ><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Laboratorio </td>
		  <td>&nbsp;&nbsp;</td>
        </tr>
         <tr class="TextRow01">
          <td><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Ingresados</td>
           <td>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes2","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes2,false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;</td>
        </tr>

       
				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","8",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Top Ten - Cantidad de Cirugia Hospitaliarias por Medico </td>
					 <td>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes3","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes3,false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;</td>
			  </tr>
			  <tr class="TextRow01">
          <td><%=fb.radio("reporte1","10",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Prueba de Radiologia</td>
		<td>&nbsp;&nbsp;</td>
        </tr>
		  

          <tr class="TextRow01">
					<td><%=fb.radio("reporte1","13",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Prueba de Laboratorio</td>
				<td>&nbsp;&nbsp;</td>
				</tr>
				
				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","14",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Top Ten - Cantidad de Pruebas de Radioalogia por Medico </td>
					 <td>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes4","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes4,false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;</td>
					 
					 <tr class="TextRow01">
					<td><%=fb.radio("reporte1","15",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Top Ten - Cantidad de Pruebas de Laboratorio por Medico </td>
					 <td>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes5","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes5,false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;</td>


					  <tr class="TextRow01">					<td><%=fb.radio("reporte1","16",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Ingreso por Especialidad </td>
					 <td>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes6","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes6,false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;</td>

					 <tr class="TextRow01">
                    <td><%=fb.radio("reporte1","17",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Pacientes Egresados</td>  <td>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes8","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes8,false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;</td>
                    </tr>
					
					 <tr class="TextRow01">
                    <td><%=fb.radio("reporte1","18",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte de Pacientes Hospitalizados por Medicos Accionistas</td>  <td>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes7","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes7,false,false,0,"Text10",null,null,"","S")%> &nbsp;&nbsp;</td>
                    </tr>
					 <tr class="TextRow01">
                    <td><%=fb.radio("reporte1","20",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Reporte de Cargos Por Especialidad</td> 
					 <td>&nbsp;&nbsp;Mes:&nbsp;<%=fb.select("mes9","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes7,false,false,0,"Text10",null,null,"","S")%> 
					 </td>
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
