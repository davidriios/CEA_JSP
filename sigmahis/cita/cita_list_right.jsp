<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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

int iconSize = 18;
StringBuffer sbSql = new StringBuffer();
String cds = request.getParameter("cds");
String hab = request.getParameter("hab");
String fecha = request.getParameter("fecha");
String fg = request.getParameter("fg");
String citasAmb = request.getParameter("citasAmb");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String tipoCita = request.getParameter("tipoCita");
String nombreMedico = request.getParameter("nombreMedico");
String codMedico = request.getParameter("medico"); 
String provincia = request.getParameter("provincia");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
String dCedula = request.getParameter("d_cedula");
String pasaporte = request.getParameter("pasaporte");
String tipoPaciente = request.getParameter("tipo_paciente");
String fechaNacimiento = request.getParameter("fechaNacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");
String sexo = request.getParameter("sexo");

if (cds == null) cds = "";
if (hab == null) hab = "";
if (fecha == null) fecha = SQLMgr.getData("select to_char(sysdate+1,'dd/mm/yyyy') as fecha from dual").getColValue("fecha");
if (fg == null) fg= "";

CommonDataObject cdoP = SQLMgr.getData("select  cita_interval, to_number(to_char(cita_open_at,'hh24mi')) cita_open_at, to_number(to_char(cita_close_at,'hh24mi')) cita_close_at from tbl_cds_centro_servicio where codigo = "+(cds.equals("")?"-100":cds));

if (cdoP==null) cdoP = new CommonDataObject();

int tiempoCupo = cdoP.getColValue("CITA_INTERVAL")==null||cdoP.getColValue("CITA_INTERVAL").equals("")?30:Integer.parseInt(cdoP.getColValue("CITA_INTERVAL")); // in minute
int openAt = cdoP.getColValue("CITA_OPEN_AT")==null||cdoP.getColValue("CITA_OPEN_AT").equals("")?700:Integer.parseInt(cdoP.getColValue("CITA_OPEN_AT"));
int closeAt = (cdoP.getColValue("CITA_CLOSE_AT")==null||cdoP.getColValue("CITA_CLOSE_AT").equals(""))?1400:Integer.parseInt(cdoP.getColValue("CITA_CLOSE_AT"));
String sOpenAt = cdoP.getColValue("s_open_at")==null?"07:00":cdoP.getColValue("s_open_at");

int hourFraction = 2;
int sTime = (7 * hourFraction);//min=0 and max<eTime => 12:00 am
int eTime = (22 * hourFraction);//min>sTime and max=24 => 12:00 am next day
ArrayList al = new ArrayList();
if (hab.trim().equals("")) sbSql.append("select to_char(a.hora,'hh:mi am') as hora, 0 as codigo, to_char(sysdate,'dd/mm/yyyy') as fecha_registro, ' ' as nombre_paciente, ' ' as telefono, ' ' as observacion from ");
else sbSql.append("select to_char(a.hora,'hh:mi am') as hora, nvl(b.codigo,0) as codigo, to_char(nvl(b.fecha_registro,sysdate),'dd/mm/yyyy') as fecha_registro, nvl(b.nombre_paciente,' ') as nombre_paciente, nvl(b.telefono,' ') as telefono, nvl(b.observacion,' ') as observacion from ");

sbSql.append("( select aaa.hora from( select (to_date('");
sbSql.append(fecha);
sbSql.append(" 00:00' , 'dd/mm/yyyy hh24:mi') )+(rownum-1)*(");
sbSql.append(tiempoCupo);
sbSql.append("/24/60) as hora from dual connect by level <= ceil(24 * (60/");
sbSql.append(tiempoCupo);
sbSql.append(")) ) aaa where to_number(to_char(aaa.hora,'hh24mi')) between "); 
sbSql.append(openAt); 
sbSql.append(" and ");
sbSql.append(closeAt+tiempoCupo); 
sbSql.append(" order by 1 )a");

if (!hab.trim().equals(""))
{
	sbSql.append(", (select to_char(z.hora_cita,'hh:mi am') as hora_cita, z.fecha_cita, z.codigo, z.fecha_registro, z.estado_cita, z.motivo_cita, z.observacion, z.nombre_paciente, z.telefono, z.hora_cita as hora_inicial, z.hora_cita + (((nvl(z.hora_est,0) * 60) + nvl(z.min_est,0)) / (24 * 60)) as hora_final from tbl_cdc_cita z where z.estado_cita not in ('C','T') and trunc(z.fecha_cita)=to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy') and z.habitacion='");
	sbSql.append(hab);
	sbSql.append("') b");
	sbSql.append(" where a.hora>=b.hora_inicial(+) and a.hora<b.hora_final(+)");
}
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function submitDate(fecha){var oldFecha=document.searchRight.fecha.value;if(fecha.trim()!=''&&isValidateDate(fecha,'dd/mm/yyyy')){document.searchRight.fecha.value=fecha;getLocaleDate(fecha,'_searchRightFecha');if(document.searchRight.cds.value.trim()!=''&&document.searchRight.hab.value.trim()!=''&&oldFecha!=fecha){if(searchRightValidation())document.searchRight.submit();}}}
function submitDay(days){var fecha=addDays(document.searchRight.fecha.value,days,parent.window.frames.iLeft.document.searchLeft.fecha.value);submitDate(fecha);}
function submitMonth(months){var fecha=addMonths(document.searchRight.fecha.value,months,parent.window.frames.iLeft.document.searchLeft.fecha.value);submitDate(fecha);}
function doAction(){getLocaleDate('<%=fecha%>','_searchRightFecha');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="1" cellspacing="1" border="0">
<%fb = new FormBean("searchRight",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("hab",hab)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("nombreMedico",nombreMedico)%>
<%=fb.hidden("medico",codMedico)%> 
<%=fb.hidden("provincia",provincia)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("d_cedula",dCedula)%>
<%=fb.hidden("pasaporte",pasaporte)%>
<%=fb.hidden("tipo_paciente",tipoPaciente)%>
<%=fb.hidden("fechaNacimiento",fechaNacimiento)%>
<%=fb.hidden("codigo_paciente",codigoPaciente)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("citasAmb",citasAmb)%>

<tr align="center" class="TextHeader">
	<td colspan="4">
		<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr class="TextHeader">
			<td width="20%" align="right">
				<%=fb.button("subMonth","<<",true,false,"Text10",null,"onClick=\"javascript:submitMonth(-1)\"")%>
				<%=fb.button("subDay","<",true,false,"Text10",null,"onClick=\"javascript:submitDay(-1)\"")%>
			</td>
			<td width="60%" align="center">
				<%//=fb.textBox("fecha",fecha,false,false,true,10,"Text10",null,null)%>
				<%=fb.hidden("fecha",fecha)%>
				<label id="_searchRightFecha"></label>
			</td>
			<td width="20%">
				<%=fb.button("addDay",">",true,false,"Text10",null,"onClick=\"javascript:submitDay(1)\"")%>
				<%=fb.button("addMonth",">>",true,false,"Text10",null,"onClick=\"javascript:submitMonth(1)\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd(true)%>
<tr align="center" class="TextHeader">
	<td width="15%"><cellbytelabel>Hora</cellbytelabel></td>
	<td width="55%"><cellbytelabel>Paciente</cellbytelabel></td>
	<td width="30%"><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow01";
%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" height="<%=iconSize+6%>">
	<td class="TableBottomBorderLightGray" valign="top" align="center"><%=cdo.getColValue("hora")%></td>
	<td class="TableBottomBorderLightGray"><%=(!cdo.getColValue("codigo").equals("0") && cdo.getColValue("nombre_paciente") != null && !cdo.getColValue("nombre_paciente").trim().equals(""))?cdo.getColValue("nombre_paciente"):"&nbsp;"%></td>
	<td class="TableBottomBorderLightGray"><%=(!cdo.getColValue("codigo").equals("0") && cdo.getColValue("telefono") != null && !cdo.getColValue("telefono").trim().equals(""))?cdo.getColValue("telefono"):"&nbsp;"%></td>
</tr>
<%
}
%>
</table>
</body>
</html>
<%
}
%>