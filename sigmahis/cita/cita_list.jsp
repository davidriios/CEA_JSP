<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.File"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.XMLCreator"%>
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

StringBuffer sbSql = new StringBuffer();
if (cds == null) cds = "";
if (hab == null) hab = "";
if (fg == null) fg = "";
if (fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (citasAmb == null) citasAmb = "";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (sexo == null) sexo = "";

XMLCreator xml = new XMLCreator(ConMgr);
xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"hab_cds_x_unidad.xml","select codigo as value_col, codigo||' - '||descripcion as label_col, centro_servicio as title_col, compania||'-'||unidad_admin as key_col from tbl_sal_habitacion where estado_habitacion <> 'I' order by compania, unidad_admin, descripcion");

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function setFrameService(){

var cds=document.search00.cds.value;
var hab=document.search00.hab.value;
var habCds=document.search00.hab.options[document.search00.hab.selectedIndex].title;
var fecha=document.search00.fecha.value;
var fg=document.search00.fg.value;


window.frames.iLeft.document.searchLeft.hab.value=hab;
window.frames.iLeft.document.searchLeft.cds.value=cds;
window.frames.iLeft.document.searchLeft.fecha.value=fecha;
window.frames.iLeft.document.searchLeft.fg.value=fg;


window.frames.iRight.document.searchRight.hab.value=hab;
window.frames.iRight.document.searchRight.cds.value=cds;
window.frames.iRight.document.searchRight.fecha.value=addDays(fecha,1);
window.frames.iRight.document.searchRight.fg.value=fg;


if(cds.trim()!=''&&hab.trim()!=''&&fecha.trim()!=''){window.frames.iLeft.document.searchLeft.submit(true);window.frames.iRight.document.searchRight.submit(true);}}


function impReporteAdmin(){var cds=document.search00.cds.value;var fecha=document.search00.fecha.value;if(cds=='')alert('Por favor seleccione el Centro de Servicio!');else abrir_ventana('../cita/print_citas_x_cuarto_admin.jsp?centro='+cds+'&fechaCita='+fecha);}
function impReporteCuarto(){var cds=document.search00.cds.value;var fecha=document.search00.fecha.value;if(cds=='')alert('Por favor seleccione el Centro de Servicio!');else abrir_ventana('../cita/print_citas_x_cuarto_separado.jsp?centro='+cds+'&fechaCita='+fecha);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(!citasAmb.trim().equals("S")){%>
<jsp:include page="../common/title.jsp" flush="true"><jsp:param name="title" value="CITAS - LISTA"></jsp:param></jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
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

<tr>
	<td colspan="2" align="right">
		&nbsp;
		<authtype type='50'>[<a href="javascript:impReporteAdmin()" class="Link00"><cellbytelabel>Reporte Administ</cellbytelabel>.</a>]</authtype>
		<authtype type='51'>[<a href="javascript:impReporteCuarto()" class="Link00"><cellbytelabel>Por Cuarto</cellbytelabel></a>]</authtype>
	</td>
</tr>
<tr class="TextFilter">
	<td>
	<%sbSql = new StringBuffer();
	if(!UserDet.getUserProfile().contains("0"))
	{
		sbSql.append(" and a.codigo in (");
			if(session.getAttribute("_cds")!=null)
				sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
			else sbSql.append("-1");
		sbSql.append(")");
	}%>
		<cellbytelabel>Centro de Servicio</cellbytelabel>
		<%=fb.select(ConMgr.getConnection(),"select a.codigo, a.codigo||' - '||a.descripcion, a.codigo from tbl_cds_centro_servicio a where a.flag_cds in ('IMA', 'CAR', 'LAB','EJE','CEX')"+sbSql.toString(),"cds",cds,false,false,0,"","","onChange=\"javascript:loadXML('../xml/hab_cds_x_unidad.xml','hab','','VALUE_COL','LABEL_COL','"+session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','S')\"",null,"S")%>
		Area de Cita<!--Habitaci&oacute;n-->
		<%=fb.select("hab","","",false,false,0,null,null,"onChange=\"javascript:setFrameService();\"",null,"S")%>
		<script language="javascript">
		loadXML('../xml/hab_cds_x_unidad.xml','hab','<%=hab%>','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-'+document.search00.cds.value,'KEY_COL','S');
		</script>
		<cellbytelabel>Fecha</cellbytelabel>
		<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="nameOfTBox1" value="fecha" />
			<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
			<jsp:param name="fieldClass" value="Text10" />
			<jsp:param name="buttonClass" value="Text10" />
			<jsp:param name="onChange" value="javascript:setFrameService();" />
			<jsp:param name="jsEvent" value="javascript:setFrameService();" />
		</jsp:include>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<table align="center" width="99%" cellpadding="1" cellspacing="0" border="0">
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="1" cellspacing="0" border="0">
		<tr>
			<td width="55%" valign="top" class="TableBorder"><iframe name="iLeft" id="iLeft" src="../cita/cita_list_left.jsp?citasAmb=<%=citasAmb%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombreMedico=<%=nombreMedico%>&medico=<%=codMedico%>&provincia=<%=provincia%>&sigla=<%=sigla%>&asiento=<%=asiento%>&d_cedula=<%=dCedula%>&pasaporte=<%=pasaporte%>&tipo_paciente=<%=tipoPaciente%>&fechaNacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&tomo=<%=tomo%>&sexo=<%=sexo%>" width="100%" height="400" allowtransparency scrolling="auto"></iframe></td>
			<td width="45%" valign="top" class="TableBorder"><iframe name="iRight" id="iRight" src="../cita/cita_list_right.jsp?citasAmb=<%=citasAmb%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombreMedico=<%=nombreMedico%>&medico=<%=codMedico%>&provincia=<%=provincia%>&sigla=<%=sigla%>&asiento=<%=asiento%>&d_cedula=<%=dCedula%>&pasaporte=<%=pasaporte%>&tipo_paciente=<%=tipoPaciente%>&fechaNacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&tomo=<%=tomo%>&sexo=<%=sexo%>" width="100%" height="400" allowtransparency scrolling="auto"></iframe></td>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>