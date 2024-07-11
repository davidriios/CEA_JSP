<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.chart.TimeSeriesChart"%>
<%@ page import="java.text.DateFormat"%> 
<%@ page import="java.text.SimpleDateFormat"%> 
<%@ page import="java.util.Date"%> 
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
ArrayList alBal = new ArrayList();
CommonDataObject cdo, cdoDateTime = new CommonDataObject();
CommonDataObject cdop = new CommonDataObject();
String sql = "";
String appendFilter = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fecha = request.getParameter("fecha");
String horario = request.getParameter("horario");
String from = request.getParameter("from");
String to = request.getParameter("to");
String serveToRemote = request.getParameter("remoto") == null?"":request.getParameter("remoto");

String compareDate = "";

int s_7am = 7, s_3pm = 15, s_11pm = 11;

/*SimpleDateFormat df = new SimpleDateFormat("hh:mi:ss");
try{
    Date _7am = df.parse(s_7am);
	System.out.println("Hey!, here? "+_7am);
	String new_7am = _7am.toString(
}catch(Exception e){
	e.printStackTrace();
}
*/


if ( pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{

	if ( ! serveToRemote.trim().equals("Y") ) cdop = SQLMgr.getPacData(pacId, noAdmision);

String getSysDateTime = "select to_char(sysdate, 'hh24') hora_actual, to_char(sysdate, 'dd/mm/yyyy') fecha_actual, to_char(sysdate, 'dd/mm/yyyy hh12:mi:ss am') fecha_hora_actual, to_char(sysdate - 1, 'dd/mm/yyyy hh12:mi:ss am') fecha_hora_menos_24 from dual";

cdoDateTime = SQLMgr.getData(getSysDateTime);

if(horario.trim().equalsIgnoreCase("todos")){

if(!from.trim().equals("") && !to.trim().equals("")){
     compareDate = "and to_date( to_char( a.fecha,'dd/mm/yyyy')) between to_date('"+from+"','dd/mm/yyyy') and to_date('"+to+"','dd/mm/yyyy')";
	}
}

if(horario.trim().equalsIgnoreCase("_24h")){
	 compareDate = "and to_date(to_char(a.fecha,'dd/mm/yyyy')|| ' ' ||to_char(a.hora,'hh12:mi:ss am'), 'dd/mm/yyyy hh12:mi:ss am') between to_date('"+cdoDateTime.getColValue("fecha_hora_menos_24")+"','dd/mm/yyyy hh12:mi:ss am') and to_date('"+cdoDateTime.getColValue("fecha_hora_actual")+"','dd/mm/yyyy hh12:mi:ss am')";
}

if(horario.trim().equalsIgnoreCase("turnoActual")){

	if( Integer.parseInt(cdoDateTime.getColValue("hora_actual")) >= s_7am && Integer.parseInt(cdoDateTime.getColValue("hora_actual")) <= s_3pm){
	
	  compareDate = "and fecha=to_date('"+cdoDateTime.getColValue("fecha_actual")+"','dd/mm/yyyy') and a.hora between to_date('07:00:00 am', 'hh12:mi:ss am') and  to_date('03:00:00 pm', 'hh12:mi:ss am')";
	}
	
	if( Integer.parseInt(cdoDateTime.getColValue("hora_actual")) >= s_3pm && Integer.parseInt(cdoDateTime.getColValue("hora_actual")) <= s_11pm){
		compareDate = "and fecha=(to_date('"+cdoDateTime.getColValue("fecha_actual")+"','dd/mm/yyyy') and a.hora between  to_date('03:00:00 pm','hh12:mi:ss am')  and to_date('11:00:00 pm','hh12:mi:ss am')";
	}
	
	if( Integer.parseInt(cdoDateTime.getColValue("hora_actual")) >= s_11pm && Integer.parseInt(cdoDateTime.getColValue("hora_actual")) <= s_7am){
		compareDate = "and fecha=(to_date('"+cdoDateTime.getColValue("fecha_actual")+"','dd/mm/yyyy') and a.hora between  to_date('11:00:00 pm','hh12:mi:ss am')  and to_date('07:00:00 am','hh12:mi:ss am')";
	}
	
}
if(horario.trim().equals("")){
    compareDate = "and to_char(a.fecha,'dd/mm/yyyy')='"+fecha+"'";
}


System.out.println(compareDate);


//fecha_hora, cantidad
	sql = "select to_char(a.fecha,'dd-mm-yyyy')||to_char(a.hora,' hh12:mi:ss am') as fecha_hora,sum(decode(b.tipo_liquido,'I',a.cantidad,'E',-1*a.cantidad,0)) as cantidad from tbl_sal_detalle_balance a, tbl_sal_via_admin b where a.pac_id="+pacId+" and a.adm_secuencia="+noAdmision+ " "+compareDate+ " and a.via_administracion=b.codigo group by a.fecha, a.hora order by to_date(to_char(a.fecha,'dd-mm-yyyy')||to_char(a.hora,' hh12:mi:ss am'),'dd-mm-yyyy hh12:mi:ss am')";
	al = SQLMgr.getDataList(sql);
	double bal = 0.00;
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		bal += new Double(cdo.getColValue("cantidad")).doubleValue();
		alBal.add(""+bal);
	}

	sql = "select nvl(decode(sign(cantidad),1,'+'||cantidad,''||cantidad),0) as cantidad, nvl(maxIn,0) as maxIn, nvl(minIn,0) as minIn, nvl(maxOut,0) as maxOut, nvl(minOut,0) as minOut from (select sum(decode(b.tipo_liquido,'I',a.cantidad,'E',-1*a.cantidad,0)) as cantidad, max(decode(b.tipo_liquido,'I',a.cantidad,null)) as maxIn, min(decode(b.tipo_liquido,'I',a.cantidad,null)) as minIn, max(decode(b.tipo_liquido,'E',a.cantidad,null)) as maxOut, min(decode(b.tipo_liquido,'E',a.cantidad,null)) as minOut from tbl_sal_detalle_balance a, tbl_sal_via_admin b where a.pac_id="+pacId+" and a.adm_secuencia="+noAdmision+ " "+compareDate+ " and a.via_administracion=b.codigo)";
	cdo = SQLMgr.getData(sql);

	TimeSeriesChart chart = new TimeSeriesChart("dd-MM-yyyy hh:mm:ss a");
	chart.setLabelDateFormat("dd-MM-yy hh:mm a");
	chart.setDomainDateTickUnit("HOUR");
	chart.setVerticalDomainAxisLabel(true);
	chart.setDisplayItemValue(false);
	chart.setDimension(10.0);
	chart.setTitle("Balance Hidrico");
	double maxIn = 10000;
	double maxOut = 10000;
	if (cdo != null)
	{
		chart.setSubtitle("Balance = "+cdo.getColValue("cantidad")+"\n\n"+("Valores en cc ( CENTIMETROS CUBICOS)"));

		if (Double.parseDouble(cdo.getColValue("maxIn")) != 0) maxIn = Double.parseDouble(cdo.getColValue("maxIn"));
		if (Double.parseDouble(cdo.getColValue("maxOut")) != 0) maxOut = Double.parseDouble(cdo.getColValue("maxOut"));
	}

	String domainLabel = "Fecha (dd-mm-aa hh:mi)";
	String[] serieLabel = {"Líquido Administrado", "Líquido Eliminado"};
	double[] lower = {0, 0};
	double[] upper = {maxIn, maxOut};
	Color[] color = {Color.BLUE, Color.RED};
	boolean[] displaySeriesAxis = {true, true};
	boolean created = chart.createChart(ConMgr.getConnection(), "select to_char(a.fecha,'dd-mm-yyyy')||to_char(a.hora,' hh12:mi:ss am') as fecha, decode(b.tipo_liquido,'I',a.cantidad,null) as icantidad, decode(b.tipo_liquido,'E',a.cantidad,null) as ecantidad from tbl_sal_detalle_balance a, tbl_sal_via_admin b where a.pac_id="+pacId+" and a.adm_secuencia="+noAdmision+ " "+compareDate+ " and a.via_administracion=b.codigo order by to_date(to_char(a.fecha,'dd-mm-yyyy')||to_char(a.hora,' hh12:mi:ss am'),'dd-mm-yyyy hh12:mi:ss am')", domainLabel, serieLabel, lower, upper, color, displaySeriesAxis);
  
  if (alBal != null && alBal.size() > 0) chart.addChartSerie("Balance ", alBal, -1 * maxOut, maxIn, Color.BLACK, true);
	chart.generateImage(java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/_"+pacId+chart.toString()+".png",980,600);

	String filename = "../images/image_not_found.jpg";
	if (created) filename = "../pdfdocs/_"+pacId+chart.toString()+".png";
	
	if ( serveToRemote.trim().equals("Y") ){
		out.print(filename);
	}else{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Balance Hídrico - '+document.title;

function doAction()
{
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="GRAFICA DE BALANCE HIDRICO"></jsp:param>
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
}
}//GET
%>
