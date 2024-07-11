<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="java.util.Hashtable" %>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

boolean viewMode = false;
String sql = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String exp = request.getParameter("exp");
String fp = request.getParameter("fp");
String medicamento = request.getParameter("medicamento");
if (exp == null ) exp="";
if (fp == null ) fp="";
if (medicamento == null ) medicamento = "";

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = " select  c.usuario_creacion usuario_crea, c.usuario_modif,to_char(c.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_crea, to_char(c.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') fecha_modif, a.codigo, to_char(a.fecha_medica,'dd/mm/yyyy') fechaMedica, to_char(a.hora,'hh12:mi am') hora, to_char(a.hora_medica,'hh12:mi am') horaMedica ,medicamento,a.dosis, a.via,d.descripcion descVia ,a.frecuencia,a.observacion, b.descripcion descFrecuencia,a.dosis_desc from tbl_sal_detalle_medicamento a, tbl_sal_frecuencia b,tbl_sal_medicamento_admision c,tbl_sal_via_admin d where a.pac_id = "+pacId+" and a.secuencia =  "+noAdmision+" and a.frecuencia = b.codigo(+) and c.pac_id = a.pac_id and c.secuencia = a.secuencia and c.fecha = a.fecha_medica and c.hora = a.hora_medica and a.via = d.codigo(+) ";
	
	if (fp.equalsIgnoreCase("med")) sql += " and c.fecha_creacion >= sysdate - 1 ";
	
	if (!medicamento.trim().equals("")) sql += " and upper(medicamento) like '%"+medicamento+"%'";
	
	sql += " order by to_char(a.fecha_medica,'dd/mm/yyyy'), to_char(a.hora_medica,'hh12:mi am'), a.codigo asc ";
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Hoja de Medicamento - '+document.title;
function doAction(){}
function buscar(){
  var medicamento = $("#medicamento").val();
  if (medicamento) window.location = "../expediente/hoja_medicamento_list.jsp?fp=<%=fp%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&exp=<%=exp%>&medicamento="+medicamento;
  else window.location = "../expediente/hoja_medicamento_list.jsp?fp=<%=fp%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&exp=<%=exp%>";
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%if(!fp.equalsIgnoreCase("med")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="HOJA DE MEDICAMENTO"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td colspan="4" align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
    <%if(!fp.equalsIgnoreCase("med")){%>
		<table width="100%" cellpadding="0" cellspacing="0" class="TableBorderLightGray">
		<tr>
			<td colspan="4">
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="fp" value="expediente"></jsp:param>
					<jsp:param name="mode" value="view"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		</table>
		<%}%>
		
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
		<tr class="TextRow02">			
			<%if(!fp.equalsIgnoreCase("med")){%>
          <td colspan="4" align="right">&nbsp;</td>
          <%} else {%>
          <td colspan="6">
            Medicamento: <input type="text" name="medicamento" id="medicamento">
            <input type="button" name="btn_search" id="btn_search" value="Buscar" class="UpperCaseTextBold SpacingText CellbyteBtn" onclick="buscar()">
          </td>
      <%} %>
		</tr>
		
		<%if(fp.equalsIgnoreCase("med")){%>
		<tr class="TextHeader">
			<td width="25%"><cellbytelabel id="5">Medicamento</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="6">Dosis</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="7">V&iacute;a</cellbytelabel></td>
			<%if(fp.equalsIgnoreCase("med")){%>
        <td width="10%"><cellbytelabel id="8">Frecuencia</cellbytelabel></td>
        <td width="10%"><cellbytelabel id="8">Fecha</cellbytelabel></td>
			<%} else {%>
        <td width="20%"><cellbytelabel id="8">Frecuencia</cellbytelabel></td>
			<%}%>
			<td width="30%"><cellbytelabel id="9">Observaci&oacute;n</cellbytelabel></td>
		</tr>
		<%} %>
		
<%
String fecha = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if(!fp.equalsIgnoreCase("med") && !fecha.trim().equals(cdo.getColValue("fechaMedica")+"-"+cdo.getColValue("horaMedica")))
	{
%>
		
		<tr class="TextHeader">
			<td><cellbytelabel id="1">Fecha</cellbytelabel>:&nbsp;<%=cdo.getColValue("fechaMedica")%></td>
			<td colspan="4"><cellbytelabel id="2">Hora</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("horaMedica")%></td>
			
		</tr>
		<tr class="TextHeader01">
		<td colspan="2"><cellbytelabel id="3">Creado Por</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("usuario_crea")%>&nbsp;&nbsp;<%=cdo.getColValue("fecha_crea")%></td>
		<td colspan="3"><cellbytelabel id="4">Modificado Por</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("usuario_modif")%>&nbsp;&nbsp;<%=cdo.getColValue("fecha_modif")%></td>
		</tr>
		<tr class="TextHeader">
			<td width="25%"><cellbytelabel id="5">Medicamento</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="6">Dosis</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="7">V&iacute;a</cellbytelabel></td>
      <td width="20%"><cellbytelabel id="8">Frecuencia</cellbytelabel> ::<%=fp%>:: </td>
			<td width="30%"><cellbytelabel id="9">Observaci&oacute;n</cellbytelabel></td>
		</tr>
		
		<%}%>
		<tr class="<%=color%>">
			<td><%=cdo.getColValue("medicamento")%></td>
			<td><%=exp.equalsIgnoreCase("3")?cdo.getColValue("dosis_desc"):cdo.getColValue("dosis")%></td>
			<td><%=cdo.getColValue("descVia")%></td>
			<%if(fp.equalsIgnoreCase("med")){%>
          <td><%=cdo.getColValue("descFrecuencia")%></td>
          <td><%=cdo.getColValue("fechaMedica")%> <%=cdo.getColValue("horaMedica")%></td>
			<%} else {%>
        <td><%=cdo.getColValue("descFrecuencia")%></td>
			<%}%>
			<td><%=cdo.getColValue("observacion")%></td>
		</tr>
		
	<%
	fecha = cdo.getColValue("fechaMedica")+"-"+cdo.getColValue("horaMedica");
	}%>			
				
				</table>
			</td>
		</tr>
		
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%if(!fp.equalsIgnoreCase("med")){%>
<tr>
	<td colspan="4" align="right">
		<%=fb.button("close","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
	</td>
</tr>
<%}%>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
%>
