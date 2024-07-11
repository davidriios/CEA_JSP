<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.chart.TimeSeriesChart"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdop = new CommonDataObject();
String sql = "";
String appendFilter = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String horario = request.getParameter("horario");
String from = request.getParameter("from");
String to = request.getParameter("to");

CommonDataObject cdoDateTime = new CommonDataObject();

String compareDate = "";
int s_7am = 07, s_3pm = 15, s_11pm = 23;

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String hoy = fecha.substring(0,10);

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
cdop = SQLMgr.getPacData(pacId, noAdmision);

String getSysDateTime = "select to_char(sysdate, 'hh24') hora_actual, to_char(sysdate, 'dd/mm/yyyy') fecha_actual, to_char(sysdate, 'dd/mm/yyyy hh12:mi:ss am') fecha_hora_actual, to_char(sysdate - 1, 'dd/mm/yyyy hh12:mi:ss am') fecha_hora_menos_24 from dual";

cdoDateTime = SQLMgr.getData(getSysDateTime);

if(horario.trim().equalsIgnoreCase("todos")){

/* Todo */
if(!from.trim().equals("") && !to.trim().equals("")){
     compareDate = "and trunc(a.fecha) between to_date('"+from+"','dd/mm/yyyy') and to_date('"+to+"','dd/mm/yyyy')";
	}
}

/* 24 horas */
if(horario.trim().equalsIgnoreCase("_24h")){
	 compareDate = "and to_date(to_char(a.fecha,'dd/mm/yyyy')|| ' ' ||to_char(a.hora,'hh12:mi:ss am'), 'dd/mm/yyyy hh12:mi:ss am') between to_date('"+cdoDateTime.getColValue("fecha_hora_menos_24")+"','dd/mm/yyyy hh12:mi:ss am') and to_date('"+cdoDateTime.getColValue("fecha_hora_actual")+"','dd/mm/yyyy hh12:mi:ss am')";
}

/* Turno actual */
if(horario.trim().equalsIgnoreCase("turnoActual") && hoy.equals(cdoDateTime.getColValue("fecha_actual")) ){
	  compareDate = "and fecha=to_date('"+cdoDateTime.getColValue("fecha_actual")+"','dd/mm/yyyy') and a.hora between (case when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('07:00 am', 'hh12:mi am') and to_date('03:00 pm', 'hh12:mi am') then to_date('07:00 am', 'hh12:mi am') when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('03:00 pm', 'hh12:mi am') and to_date('11:00 pm', 'hh12:mi am') then to_date('03:00 pm', 'hh12:mi am') else to_date('11:00 pm', 'hh12:mi am') end) and (case when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('07:00 am', 'hh12:mi am') and to_date('03:00 pm', 'hh12:mi am') then to_date('03:00 pm', 'hh12:mi am') when to_date(to_char(sysdate, 'hh12:mi am'), 'hh12:mi am') between to_date('03:00 pm', 'hh12:mi am') and to_date('11:00 pm', 'hh12:mi am') then to_date('11:00 pm', 'hh12:mi am') else to_date('07:00 am', 'hh12:mi am') end)";
}


/** /
	sql = "select to_char(fecha,'dd-MON-yyyy')||to_char(hora_r,' hh12:mi:ss') as fecha_nota, temperatura, pulso, respiracion, decode(instr(p_arterial,'/'),0,null,substr(p_arterial,1,instr(p_arterial,'/') - 1)) as sistolic, decode(instr(p_arterial,'/'),0,null,substr(p_arterial,instr(p_arterial,'/') + 1)) as diastolic from tbl_sal_resultado_nota where pac_id="+pacId+" and secuencia="+noAdmision+"";
	al = SQLMgr.getDataList(sql);

	CommonDataObject cdo;
	ArrayList period=new ArrayList();
	ArrayList temp=new ArrayList();
	ArrayList pulso=new ArrayList();
	ArrayList respiracion=new ArrayList();
	ArrayList sistolic=new ArrayList();
	ArrayList diastolic=new ArrayList();
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		period.add(cdo.getColValue("fecha_nota"));
		temp.add(cdo.getColValue("temperatura"));
		pulso.add(cdo.getColValue("pulso"));
		respiracion.add(cdo.getColValue("respiracion"));
		sistolic.add(cdo.getColValue("sistolic"));
		diastolic.add(cdo.getColValue("diastolic"));
	}
/ **/

  //Cambié de mi a mm, debido a que en la clase chart/TimeSeriesChart
 //usan mi eso hace que al cambiarle el al formato oracle, manda  
 //java.lang.IllegalArgumentException: Illegal pattern character 'i'

	TimeSeriesChart chart = new TimeSeriesChart("dd-MM-yyyy hh:mm:ss");
	chart.setLabelDateFormat("dd-MM-yy");// hh:mi:ss a
	chart.setDomainDateTickUnit("DAY");
	chart.setVerticalDomainAxisLabel(true);
	chart.setDisplayItemValue(false);
	chart.setDimension(10.0);
	chart.setTitle("SIGNOS VITALES");

	//chart.createChart(ConMgr.getConnection(),"select to_date(to_char(fecha,'dd-mm-yyyy')||to_char(hora_r,' hh24:mi:ss'),'dd-mm-yyyy hh24:mi:ss') as fecha_nota, to_number(temperatura) as temperatura, to_numer(pulso) as pulso from tbl_sal_resultado_nota where pac_id="+pacId+" and secuencia="+noAdmision+"","Fecha","Temperatura (ºC)");

	String domainLabel = "Fecha (dd-mm-aa)";
	String[] serieLabel = {"Temperatura (ºC)", "Pulso", "Respiración", " ", "Presión Arterial (mmHg)"};
	double[] lower = {30, 0, 0, 0, 0};
	double[] upper = {43, 300, 50, 300, 300};
	Color[] color = {Color.RED, Color.BLUE, Color.GREEN, Color.BLACK, Color.BLACK};
	boolean[] displaySeriesAxis = {true, true, true, false, true};
	boolean created = chart.createChart(ConMgr.getConnection(), "select to_char(a.fecha,'dd-mm-yyyy')||to_char(a.hora_r,' hh24:mi:ss') as fecha_nota, a.temperatura, a.pulso, a.respiracion, decode(instr(a.p_arterial,'/'),0,null,substr(a.p_arterial,1,instr(a.p_arterial,'/') - 1)) as sistolic, decode(instr(a.p_arterial,'/'),0,null,substr(a.p_arterial,instr(a.p_arterial,'/') + 1)) as diastolic from tbl_sal_resultado_nota a where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and a.estado='A' "+compareDate+" order by a.fecha_nota, a.hora, a.fecha, a.hora_r", domainLabel, serieLabel, lower, upper, color, displaySeriesAxis);

	/** /
	chart.createChart("Fecha",period,"Temperatura (ºC)",temp,java.awt.Color.BLACK);
	chart.addChartSerie("Pulso",pulso,30,43,java.awt.Color.RED);
	chart.addChartSerie("Respiración",respiracion,0,20,java.awt.Color.BLUE);
	chart.addChartSerie(" ",sistolic,0,300,java.awt.Color.GREEN,false);
	chart.addChartSerie("Presión Arterial (mmHg)",diastolic,0,300,java.awt.Color.GREEN);
	/ **/

	chart.generateImage(java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/_"+pacId+chart.toString()+".png",980,600);

	String filename = "../images/image_not_found.jpg";
	//if (al.size() > 0) filename = "../pdfdocs/_"+pacId+chart.toString()+".png";
	if (created) filename = "../pdfdocs/_"+pacId+chart.toString()+".png";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Notas de Enfermería - '+document.title;

function doAction()
{
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="GRAFICA DE NOTAS DE ENFERMERIA"></jsp:param>
  <jsp:param name="displayCompany" value="n"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table border="1" width="101%" height="77" align="center" cellpadding="0" cellspacing="0">
<tr> 
	<td ><table width="100%" cellpadding="0" cellspacing="0">
      <tr class="TextResultRowsWhite">
      <tr>
        <td width="8%" align="right"><strong><cellbytelabel id="1">Id</cellbytelabel>:</strong></td>
        <td width="5%" align="center"><%=cdop.getColValue("pac_id")%></td>
        <td width="8%" align="right"><strong><cellbytelabel id="2">Nombre</cellbytelabel>:</strong></td>
        <td width="10%" align="center" ><%=cdop.getColValue("nombre_paciente")%></td>
        <td width="8%" align="right"><strong><cellbytelabel id="3">C&eacute;d/Pasa.</cellbytelabel>: </strong></td>
        <td width="10%" align="center"><%=cdop.getColValue("identificacion")%></td>
        <td width="10%" align="right" ><strong><cellbytelabel id="4">Fecha Nac.</cellbytelabel>:</strong></td>
        <td width="6%" align="center" ><%=cdop.getColValue("f_nac")%></td>
        <td width="4%" align="left" ><strong><cellbytelabel id="5">Edad</cellbytelabel>:</strong></td>
        <td width="8%" align="left" ><%=cdop.getColValue("edad")%></td>
        <td width="1%" align="right"><strong><cellbytelabel id="6">Sexo</cellbytelabel>:</strong></td>
        <td width="25%" align="left" ><%=cdop.getColValue("sexo")%></td>
      </tr>
      <tr class="TextResultRowsWhite">
      <tr>
        <td width="8%" align="right" ><strong><cellbytelabel id="7">No. Adm.</cellbytelabel>:</strong></td>
        <td width="5%" align="center" ><%=cdop.getColValue("admision")%></td>
        <td width="8%" align="right" ><strong><cellbytelabel id="8">Ingreso</cellbytelabel>:</strong></td>
        <td width="10%" align="center" ><%=cdop.getColValue("fecha_ingreso")%></td>
        <td width="8%" align="right"><strong><cellbytelabel id="9">Cama</cellbytelabel>:</strong></td>
        <td width="8%" align="" ><%=cdop.getColValue("cama")%></td>
        <td width="10%" align="right"><strong><cellbytelabel id="10">Area/Centro</cellbytelabel>:</strong></td>
        <td width="6%" align="center" colspan="2" ><%=cdop.getColValue("centro_servicio_desc")%></td>
        <td width="2%" align="" ><strong><cellbytelabel id="11">Categor&iacute;a</cellbytelabel>:</strong></td>
        <td width="2%" align="center"><%=cdop.getColValue("categoria_desc")%></td>
      </tr>
      <tr class="TextResultRowsWhite">
      <tr>
        <td width="12%" align="right"><strong><cellbytelabel id="12">M&eacute;dico Atiende</cellbytelabel>:</strong></td>
        <td width="20%" align="center" colspan="3"><%=cdop.getColValue("nombre_medico")%></td>
        <td width="12%" align="right"><strong><cellbytelabel id="13">M&eacute;dico Cabecera</cellbytelabel>:</strong></td>
        <td width="13%" align="center"><%=cdop.getColValue("nombre_medico_cabecera")%></td>
        <td width="10%" align="right"><strong><cellbytelabel id="14">Religi&oacute;n</cellbytelabel>:</strong></td>
        <td width="12%" align="center"><%=cdop.getColValue("religion_desc")%></td>
      </tr>
    </table>
	&nbsp;
  <tr>
	  <td bordercolor="#000000" bgcolor="#000000" height="4"></td>
  </tr>
		
          <tr>
			<td><img src="<%=filename%>" ></td>
		</tr>
		
	</td>
	</tr>
</tr>
</table>
</body>
</html>
<%
}//GET
%>