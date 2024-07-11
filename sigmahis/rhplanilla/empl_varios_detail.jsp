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
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
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
ArrayList emple = new ArrayList();
ArrayList alCar = new ArrayList();
ArrayList alEduc = new ArrayList();
ArrayList alRenta = new ArrayList();
ArrayList alEst = new ArrayList();
ArrayList alTip = new ArrayList();
String change = request.getParameter("change");
String seccion = request.getParameter("seccion");
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
int rowCount = 0;



if (request.getParameter("seccion") != null && !request.getParameter("seccion").equals("")) seccion = request.getParameter("seccion");
if (request.getParameter("area") != null && !request.getParameter("area").equals("")) area = request.getParameter("area");
if (request.getParameter("grupo") != null && !request.getParameter("grupo").equals("")) grupo = request.getParameter("grupo");
if (request.getParameter("perLastLineNo") != null && !request.getParameter("perLastLineNo").equals("")) perLastLineNo = Integer.parseInt(request.getParameter("perLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage = 20;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";

if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

    String nombre = "",emp_id="";

  	if (request.getParameter("numEmpleado") != null && !request.getParameter("numEmpleado").trim().equals(""))
	{
		appendFilter += " and a.num_empleado like '%"+request.getParameter("numEmpleado")+"%'";
		numEmpleado   = request.getParameter("numEmpleado");
	}
	if (request.getParameter("primer_nombre") != null && !request.getParameter("primer_nombre").trim().equals(""))
	{
	 	appendFilter += " and upper(a.nombre_empleado) like '%"+request.getParameter("primer_nombre").toUpperCase()+"%'";
     	nombre    = request.getParameter("primer_nombre");    // utilizada para mantener la Descripción de la Orden Médica
	}
	if (request.getParameter("empId") != null && !request.getParameter("empId").trim().equals(""))
	{
		appendFilter += " and a.emp_id like '%"+request.getParameter("empId")+"%'";
		emp_id   = request.getParameter("empId");
	}
	if (!seccion.equalsIgnoreCase("15")) appendFilter += " and a.estado!='3' ";


sql=" SELECT a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.primer_nombre||' '||a.primer_apellido  as nombre ,a.primer_nombre, a.primer_apellido, a.ubic_fisica as seccion, b.descripcion as descripcion, a.emp_id as empId, a.estado, c.denominacion, d.descripcion as estadodesc, a.num_empleado as numEmpleado from vw_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_cargo c, tbl_pla_estado_emp d where a.compania = b.compania and a.ubic_fisica = b.codigo and a.compania = c.compania and a.cargo = c.codigo and a.estado = d.codigo and a.compania="+(String) session.getAttribute("_companyId")+ appendFilter+" order by a.ubic_fisica asc, a.primer_apellido";


emple = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
rowCount = CmnMgr.getCount("select count(*) count from("+sql+")");

  if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";
  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);
  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;
  if(rowCount==0) pVal=0;
  else pVal=preVal;


        alCar = sbb.getBeanList(ConMgr.getConnection(), "select codigo as optValueColumn, codigo||' - '||denominacion as optLabelColumn from tbl_pla_cargo where compania = "+(String) session.getAttribute("_companyId")+" order by denominacion ", CommonDataObject.class);

     alEduc = sbb.getBeanList(ConMgr.getConnection(), "select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_pla_tipo_educacion order by codigo ", CommonDataObject.class);

	  alRenta = sbb.getBeanList(ConMgr.getConnection(), "select clave as optValueColumn, clave||' - '||descripcion as optLabelColumn from tbl_pla_clave_renta order by clave ", CommonDataObject.class);

	  alEst = sbb.getBeanList(ConMgr.getConnection(), "select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_pla_estado_emp order by codigo ", CommonDataObject.class);

	   alTip = sbb.getBeanList(ConMgr.getConnection(), "select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_pla_tipo_empleado order by codigo ", CommonDataObject.class);

   if (change == null)
   {

	   perHash.clear();
	   perLastLineNo ++;
	   if (perLastLineNo < 10) key = "00" + perLastLineNo;
	   else if (perLastLineNo < 100) key = "0" + perLastLineNo;
	   else key = "" + perLastLineNo;

	   date = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi");

	   CommonDataObject per = new CommonDataObject();
	   per.addColValue("fecha",date.substring(0,10));
	   per.addColValue("fechaFin",date.substring(0,10));
	   per.addColValue("horaEntrada",date.substring(11));
	   per.addColValue("horaSalida",date.substring(11));
	   per.addColValue("horaDesde",date.substring(11));
	   per.addColValue("horaHasta",date.substring(11));
	   per.addColValue("codigo",""+perLastLineNo);
	   perHash.put(key,per);
   }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reportes Varios de Empleados - '+document.title;

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
//	parent.setHeight('secciones',document.body.scrollHeight);
//	sumHoras(0,0,0);
}


function addCargo()
{
   abrir_ventana1("../common/search_cargo.jsp?fp=unidad");
}
function addDepto(fg)
{
   abrir_ventana1("../common/search_depto.jsp?fp=unidad&fg="+fg);
}
function addSec()
{
   abrir_ventana1("../common/search_depto.jsp?fp=seccion");
}

function addEstado()
{
   abrir_ventana1("../common/search_depto.jsp?fp=estado");
}

function addSangre()
{
   abrir_ventana1("../common/search_sangre.jsp?fp=empleado");
}

function  printR(emp_id)
{
abrir_ventana("../rhplanilla/print_carta_rec.jsp?emp_id="+emp_id);
}
function  printT(emp_id)
{
abrir_ventana("../rhplanilla/print_carta_tra.jsp?emp_id="+emp_id);
}
function  printList(seccion)
{
//var car = eval('document.formUnidad.cargo').value ;
//var dep = eval('document.formUnidad.depto').value ;
//var sec = eval('document.formUnidad.sec').value ;
//var section = eval('document.formUnidad.seccion').value ;

if (seccion=="1")
{
var tipo = eval('document.formUnidad.tipoDesc').value ;
tipo=tipo.replace('+','');
tipo=tipo.replace('-','');
var rh = eval('document.formUnidad.rh').value ;
abrir_ventana("../rhplanilla/print_list_emp_sangre.jsp?tipo="+tipo+"&rh="+rh);
}
else if(seccion=="2")
{
var estado = eval('document.formUnidad.estadoc').value ;
abrir_ventana("../rhplanilla/print_list_emp_estado.jsp?estado="+estado);
}
else if(seccion=="3")
{
var cargo = eval('document.formUnidad.cargo').value ;
var sexo = eval('document.formUnidad.sexo').value ;
abrir_ventana("../rhplanilla/print_list_emp_cargosexo.jsp?fp=gral&cargo="+cargo+"&sexo="+sexo);
}
else if(seccion=="4")
{
var cargo = eval('document.formUnidad.cargo').value ;
abrir_ventana("../rhplanilla/print_list_emp_cargos.jsp?cargo="+cargo);
}
else if(seccion=="5")
{
var educ = eval('document.formUnidad.educ').value ;
abrir_ventana("../rhplanilla/print_list_emp_educ.jsp?educ="+educ);
}
else if(seccion=="6")
{
var dep = eval('document.formUnidad.depto').value ;
var sec = eval('document.formUnidad.sec').value ;
abrir_ventana("../rhplanilla/print_list_emp_pariente.jsp?depto="+dep+"&sec="+sec);
}
else if(seccion=="7")
{
var sexo = eval('document.formUnidad.sexo').value ;
abrir_ventana("../rhplanilla/print_list_emp_sexo.jsp?fp=sexo&sexo="+sexo);
}
else if(seccion=="8")
{
var cargo = eval('document.formUnidad.cargo').value ;
abrir_ventana("../rhplanilla/print_list_emp_cargo.jsp?fp=cargo&cargo="+cargo);
}
else if(seccion=="9")
{
var cargo = eval('document.formUnidad.cargo').value ;
var dep = eval('document.formUnidad.depto').value ;
var sec = eval('document.formUnidad.sec').value ;
abrir_ventana("../rhplanilla/print_list_emp_ficha.jsp?fp=cargo&cargo="+cargo+"&depto="+dep+"&seccion="+sec);
}
else if(seccion=="10")
{
var estado = eval('document.formUnidad.est').value ;
var tipo = eval('document.formUnidad.tipo').value ;
var cargo = eval('document.formUnidad.cargo').value ;
abrir_ventana("../rhplanilla/print_list_emp_nombre.jsp?fp=cargo&cargo="+cargo+"&est="+estado+"&tipo="+tipo);
}
else if(seccion=="11")
{
var cargo = eval('document.formUnidad.cargo').value ;
abrir_ventana("../rhplanilla/print_list_emp_horas_trab.jsp?fp=cargo&cargo="+cargo);
}
else if(seccion=="12")
{
var mes = eval('document.formUnidad.mes').value ;
abrir_ventana("../rhplanilla/print_list_emp_cumple.jsp?mes="+mes);
}
else if(seccion=="13")
{
var dep = eval('document.formUnidad.depto').value ;
var sec = eval('document.formUnidad.sec').value ;
var clave = eval('document.formUnidad.clave').value ;
abrir_ventana("../rhplanilla/print_list_emp_renta.jsp?clave="+clave+"&depto="+dep+"&sec="+sec);
}
else if(seccion=="14")
{

var lic = eval('document.formUnidad.lic').value ;
abrir_ventana("../rhplanilla/print_list_emp_licencia.jsp?lic="+lic);
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
		<%fb = new FormBean("formUnidad",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("perLastLineNo",""+perLastLineNo)%>
		<%=fb.hidden("seccion",seccion)%>
		<%=fb.hidden("area",area)%>
		<%=fb.hidden("ue_codigo",grupo)%>
		<%=fb.hidden("grupo",grupo)%>
		<%=fb.hidden("estado",estado)%>
		<%=fb.hidden("keySize",""+perHash.size())%>



		<%
				  String js = "";
					String fecha = "";
					String fechaFin = "";
					String horaEntrada = "";
					String horaSalida = "";
					String horaDesde = "";
					String horaHasta = "";

				    al = CmnMgr.reverseRecords(perHash);
				    for (int i = 0; i < perHash.size(); i++)
				    {
					  key = al.get(i).toString();
					  CommonDataObject per = (CommonDataObject) perHash.get(key);
					  fecha = "fecha"+i;
					  fechaFin = "fechaFin"+i;
					  horaEntrada = "horaEntrada"+i;
					  horaSalida = "horaSalida"+i;
					  horaDesde = "horaDesde"+i;
					  horaHasta = "horaHasta"+i;
		%>

	<tr class="TextRow01">
		<td width="148"> </td>
		<td width="1090" colspan="2"> <cellbytelabel>PARAMETROS PARA REPORTE DE EMPLEADOS</cellbytelabel>  </td>
	</tr>



	               <%
				  if (seccion.equalsIgnoreCase("1"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>POR TIPO DE SANGRE</cellbytelabel> </td>
					</tr>

			<% } else  if (seccion.equalsIgnoreCase("2"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>POR ESTADO CIVIL</cellbytelabel> </td>
					</tr>

			<% } else  if (seccion.equalsIgnoreCase("3"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>POR SEXO / PUESTO</cellbytelabel> </td>
					</tr>

			<%} else  if (seccion.equalsIgnoreCase("4"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>CARGOS</cellbytelabel> </td>
					</tr>
			<% } else  if (seccion.equalsIgnoreCase("5"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>POR ESCOLARIDAD</cellbytelabel> </td>
					</tr>

			<% } else  if (seccion.equalsIgnoreCase("6"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>POR PARIENTES - DEPENDIENTE</cellbytelabel> </td>
					</tr>
				<% } else  if (seccion.equalsIgnoreCase("7"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>POR SEXO</cellbytelabel> </td>
					</tr>

			<% } else  if (seccion.equalsIgnoreCase("8"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>POR CARGO</cellbytelabel> </td>
					</tr>

			<% } else  if (seccion.equalsIgnoreCase("9"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>CARGO</cellbytelabel> </td>
					</tr>

			<% } else  if (seccion.equalsIgnoreCase("10"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>ALFABETICAMENTE / ESTADO / TIPO</cellbytelabel>  </td>
					</tr>
			<% } else  if (seccion.equalsIgnoreCase("11"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>POR CANTIDAD DE HORAS DIARIAS LABORADAS</cellbytelabel> </td>
					</tr>
			<% }	else  if (seccion.equalsIgnoreCase("12"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>CUMPLEA&Ntilde;OS</cellbytelabel> </td>
					</tr>
			<% } else  if (seccion.equalsIgnoreCase("13"))
					 {
					 %>

					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>POR CLAVE DE RENTA</cellbytelabel> </td>
					</tr>
					<% }	 else  if (seccion.equalsIgnoreCase("14"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>CON/SIN LICENCIA DE CONDUCIR</cellbytelabel> </td>
					</tr>
					<% }  else  if (seccion.equalsIgnoreCase("15"))
					 {
					 %>
					 <tr class="TextRow01">
						<td width="148"> </td>
						<td colspan="2"> <cellbytelabel>CARTAS</cellbytelabel> </td>
					</tr>
					<tr>
					<td >&nbsp; </td><% } %>
					 <td> <!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->




  <tr class="TextRow02">
			<td colspan="3">&nbsp;</td>
  </tr>


	<% if (seccion.equalsIgnoreCase("1"))
					 {
					%>

					  <tr class="TextRow01">
	   <td><cellbytelabel>Tipos de Sangre</cellbytelabel></td>
	   <td colspan="2"><%=fb.textBox("tipo",per.getColValue("tipo"),false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("tipoDesc",per.getColValue("tipoDesc"),false,false,true,5,5,"Text10",null,null)%><%=fb.textBox("rh",per.getColValue("rh"),false,false,true,5,5,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addSangre()\"")%></td>
	</tr>


	<% }
	%>

	<%
		  	if (seccion.equalsIgnoreCase("2"))
			 {
	%>

	<tr class="TextRow01">
	    <td><cellbytelabel>Estado Civil</cellbytelabel> </td>
	   	<td colspan="2"><%=fb.select("estadoc","CS=CASADO(A),DV=DIVORCIADO(A),SP=SEPARADO(A),ST=SOLTERO(A),UN=UNIDO(A),VD=VIUDO(A)","",false,false,0,"T")%></td>
	</tr>

 					 <%
					 }
					 %>

			<%
		  	if (seccion.equalsIgnoreCase("3"))
			 {
			%>
		<tr class="TextRow01">
	    	<td><cellbytelabel>Cargos / Ocupaciones</cellbytelabel> </td>
			<td colspan="2"> <%=fb.select("cargo",alCar,"", false, false, 0,"T")%> </td>
    	</tr>

		<tr class="TextRow02">
	    	<td><cellbytelabel>Sexo</cellbytelabel> </td>
	   		<td colspan="2"><%=fb.select("sexo","M=MASCULINO,F=FEMENINO","",false,false,0,"T")%></td>
		</tr>
			 <%
			 }
			 %>


			  <%
		  	if (seccion.equalsIgnoreCase("4"))
			 {
			%>
			<tr class="TextRow01">
	    	<td><cellbytelabel>Cargos</cellbytelabel> </td>
			<td colspan="2"> <%=fb.select("cargo",alCar,"", false, false, 0,"T")%> </td>
    	</tr>
			 <%
			 }
			 %>


			 <%
		  	if (seccion.equalsIgnoreCase("5"))
			 {
			%>

		<tr class="TextRow02">
	    	<td><cellbytelabel>Escolaridad</cellbytelabel> </td>
	   		<td colspan="2"> <%=fb.select("educ",alEduc,"", false, false, 0,"T")%> </td>
		</tr>
			 <%
			 }
			 %>

			 <%
		  	if (seccion.equalsIgnoreCase("6"))
			 {
			%>
		 <tr class="TextRow01">
	    <td><cellbytelabel>Departamento</cellbytelabel></td>
		<td colspan="2"><%=fb.intBox("depto","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("deptoDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addDepto('')\"")%></td>
  </tr>


 	<tr class="TextRow01" >
	    <td><cellbytelabel>Secci&oacute;n</cellbytelabel></td>
	   	<td colspan="2"><%=fb.intBox("sec","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("secDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addSec()\"")%></td>
	</tr>

			 <%
			 }
			 %>

			<%
		  	if (seccion.equalsIgnoreCase("7"))
			 {
			%>

		<tr class="TextRow02">
	    	<td><cellbytelabel>Sexo</cellbytelabel> </td>
	   		<td colspan="2"><%=fb.select("sexo","M=MASCULINO,F=FEMENINO","",false,false,0,"T")%></td>
		</tr>
			 <%
			 }
			 %>

			<%
		  	if (seccion.equalsIgnoreCase("8"))
			 {
			%>
		<tr class="TextRow01">
	    	<td><cellbytelabel>Cargos / Ocupaciones</cellbytelabel> </td>
			<td colspan="2"> <%=fb.select("cargo",alCar,"", false, false, 0,"T")%> </td>
    	</tr>

			 <%
			 }
			 %>


			 <%
		  	if (seccion.equalsIgnoreCase("9"))
			 {
			%>
		<tr class="TextRow01">
	    	<td><cellbytelabel>Cargo</cellbytelabel><br><cellbytelabel>Direccion</cellbytelabel><br><cellbytelabel>Seccion</cellbytelabel> </td>
			<td colspan="2"> <%=fb.select("cargo",alCar,"", false, false, 0,"T")%> <br>
			<%=fb.intBox("depto","",false,false,true,5,3,"Text10",null,null)%>
			<%=fb.textBox("deptoDesc","",false,false,true,50,50,"Text10",null,null)%>
			<%=fb.button("btnDepto","...",true,false,null,null,"onClick=\"javascript:addDepto('DIR')\"")%><br>
			<%=fb.intBox("sec","",false,false,true,5,3,"Text10",null,null)%>
			<%=fb.textBox("secDesc","",false,false,true,50,50,"Text10",null,null)%>
			<%=fb.button("btnSec","...",true,false,null,null,"onClick=\"javascript:addSec()\"")%>
			</td>
    	</tr>

			 <%
			 }
			 %>

			 <%
		  	if (seccion.equalsIgnoreCase("10"))
			 {
			%>
		<tr class="TextRow01">
	    	<td><cellbytelabel>Cargos</cellbytelabel>  </td>
			<td colspan="2"> <%=fb.select("cargo",alCar,"", false, false, 0,"T")%> </td>
    	</tr>
		<tr class="TextRow01">
	    	<td><cellbytelabel>Estado</cellbytelabel>  </td>
			<td colspan="2"> <%=fb.select("est",alEst,"", false, false, 0,"T")%> </td>
    	</tr>

		<tr class="TextRow01">
	    	<td><cellbytelabel>Tipo</cellbytelabel> </td>
			<td colspan="2"> <%=fb.select("tipo",alTip,"", false, false, 0,"T")%> </td>
    	</tr>

			 <%
			 }
			 %>

			  <%
		  	if (seccion.equalsIgnoreCase("11"))
			 {
			%>
		<tr class="TextRow01">
	    	<td><cellbytelabel>Cargos / Horas</cellbytelabel> </td>
			<td colspan="2"> <%=fb.select("cargo",alCar,"", false, false, 0,"T")%> </td>
    	</tr>
		     <%
			 }
			 %>


			<%
		  	if (seccion.equalsIgnoreCase("12"))
			 {
			%>
			<tr class="TextRow01">
	   			 <td><cellbytelabel>Mes</cellbytelabel></td>
	   			<td colspan="2"><%=fb.select("mes","1=ENERO ,2=FEBRERO ,3=MARZO ,4=ABRIL ,5=MAYO ,6=JUNIO ,7=JULIO ,8=AGOSTO ,9=SEPTIEMBRE ,10=OCTUBRE ,11=NOVIEMBRE ,12=DICIEMBRE ","",false,false,0,"T")%></td>
			</tr>
			 <%
			 }
			 %>

			<%
		  	if (seccion.equalsIgnoreCase("13"))
			 {
			%>

			 <tr class="TextRow01">
	    <td><cellbytelabel>Departamento</cellbytelabel></td>
		<td colspan="2"><%=fb.intBox("depto","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("deptoDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addDepto('')\"")%></td>
  </tr>


 	<tr class="TextRow01" >
	    <td><cellbytelabel>Secci&oacute;n</cellbytelabel></td>
	   	<td colspan="2"><%=fb.intBox("sec","",false,false,true,5,3,"Text10",null,null)%><%=fb.textBox("secDesc","",false,false,true,50,50,"Text10",null,null)%><%=fb.button("btnmotivo","...",true,false,null,null,"onClick=\"javascript:addSec()\"")%></td>
	</tr>


		<tr class="TextRow01">
	    	<td><cellbytelabel>Claves de Rentas</cellbytelabel> </td>
			<td colspan="2"> <%=fb.select("clave",alRenta,"", false, false, 0,"T")%> </td>
    	</tr>

			 <%
			 }
			 %>

			<%
		  	if (seccion.equalsIgnoreCase("14"))
			 {
	        %>


	<tr class="TextRow01">
	    <td><cellbytelabel>Reporte de</cellbytelabel>:  </td>
	   	<td colspan="2"><%=fb.select("lic","S=EMPLEADOS CON LICENCIA,N=EMPLEADOS SIN LICENCIA","",false,false,0,"T")%></td>
	</tr>

 					 <%
					 }
					 %>
			 <%


		  	if (!seccion.equalsIgnoreCase("15")){%>
			<%=fb.hidden("numEmpleado",numEmpleado)%>
			<%}
			if (seccion.equalsIgnoreCase("15"))
			 {  %>

		 	<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
				<td width="25%">
					<cellbytelabel>No. de empleado</cellbytelabel>
					<%=fb.textBox("numEmpleado",numEmpleado,false,false,false,10)%>

				</td>
				<td width="25%">
					<cellbytelabel>Id empleado</cellbytelabel>
					<%=fb.intBox("empId","",false,false,false,10)%>
				</td>
				<td width="50%">
					<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("primer_nombre",nombre,false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd(true)%>

			</tr>
			</table><!-- formulario End-->

			<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
				<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("primer_nombre",nombre)%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
			    <%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("primer_nombre",nombre)%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>



			 <tr>
	   	<td colspan="4"><table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">
		<td> C&eacute;dula </td>
		<td> Nombre</td>
		<td> N&uacute;mero de Empleado </td>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
				</tr>

		<%
		CommonDataObject hhh = new CommonDataObject();
		for(int d=0; d<emple.size(); d++){

		String noc = "TextRow01";
		if(d%2==0) noc="TextRow02";
		hhh=(CommonDataObject)emple.get(d);
			%>
			<tr class="<%=noc%>">
			<td> <%=hhh.getColValue("cedula")%></td>
			<td> <%=hhh.getColValue("nombre")%></td>
			<td> <%=hhh.getColValue("numEmpleado")%></td>
			<td><a href="javascript:printR(<%=hhh.getColValue("empId")%>)"><cellbytelabel>Carta de Recomendaci&oacute;n</cellbytelabel></a>
			<td><%if(hhh.getColValue("estado") != null &&  !hhh.getColValue("estado").trim().equals("3")){%><a href="javascript:printT(<%=hhh.getColValue("empId")%>)"><cellbytelabel>Carta de Trabajo</cellbytelabel></a><%}%>
			</tr>
		 <%
		 }
		 %>
</table>
	</td>
	</tr>
 					 <%
					 }
					 %>




           <%
			}
		   %>


	<tr class="TextRow02">
			<td align="right" colspan="9"><%=fb.button("print","Imprimir",true,false,null,null,"onClick=\"javascript:printList("+seccion+")\"")%>
			<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>					</td>
	</tr>
            <%//=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>
</table>
</body>
</html>
<%
}//GET
%>