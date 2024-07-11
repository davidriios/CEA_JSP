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
String index = request.getParameter("index");

if (exp == null) exp = "";
if (index == null) index = "";

if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = " select  c.usuario_creacion usuario_crea, c.usuario_modif,to_char(c.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_crea, to_char(c.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') fecha_modif, a.codigo, to_char(a.fecha_medica,'dd/mm/yyyy') fechaMedica, to_char(a.hora,'hh12:mi am') hora, to_char(a.hora_medica,'hh12:mi am') horaMedica ,medicamento,a.dosis, a.via,d.descripcion descVia ,a.frecuencia,a.observacion, b.descripcion descFrecuencia from tbl_sal_detalle_medicamento a, tbl_sal_frecuencia b,tbl_sal_medicamento_admision c,tbl_sal_via_admin d where a.pac_id = "+pacId+" and a.secuencia =  "+noAdmision+" and a.frecuencia = b.codigo(+) and c.pac_id = a.pac_id and c.secuencia = a.secuencia and c.fecha = a.fecha_medica and c.hora = a.hora_medica and a.via = d.codigo(+) ";

    if (exp.trim().equals("3")) {
     sql += " and a.via not in (select column_value from table( select split((select get_sec_comp_param(1,'SAL_EXCLUIR_BH') from dual),',') from dual )) ";
    }
    
    sql += " order by to_char(a.fecha_medica,'dd/mm/yyyy'), to_char(a.hora_medica,'hh12:mi am'), a.codigo asc ";
	al = SQLMgr.getDataList(sql);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Medicamentos - '+document.title;

function doAction()
{
}

function setValue(via, medicamento) {
debug(window.opener.document.form0)
 <%if(exp.trim().equals("3")){%>
 if (window.opener.document.form0.idAdmin<%=index%>) window.opener.document.form0.idAdmin<%=index%>.value = via;
 if (window.opener.document.form0.descripcion<%=index%>) window.opener.document.form0.descripcion<%=index%>.value = medicamento;
 if (window.opener.document.form0.via_admin_med<%=index%>) window.opener.document.form0.via_admin_med<%=index%>.value = medicamento;
 window.close()
 <%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MEDICAMENTOS"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td colspan="4" align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder">
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
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
		<tr class="TextRow02">
			<td colspan="5">&nbsp;</td>
		</tr>
<%
String fecha = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if(!fecha.trim().equals(cdo.getColValue("fechaMedica")+"-"+cdo.getColValue("horaMedica")))
	{
%>

		<tr class="TextHeader">
			<td>Fecha:&nbsp;<%=cdo.getColValue("fechaMedica")%></td>
			<td colspan="4">Hora:&nbsp;&nbsp;<%=cdo.getColValue("horaMedica")%></td>

		</tr>
		<tr class="TextHeader01">
		<td colspan="3"><cellbytelabel id="1">Creado Por</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("usuario_crea")%>&nbsp;&nbsp;<%=cdo.getColValue("fecha_crea")%></td>
		<td colspan="2"><cellbytelabel id="2">Modificado Por</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("usuario_modif")%>&nbsp;&nbsp;<%=cdo.getColValue("fecha_modif")%></td>
		</tr>
		<%if(exp.trim().equals("3")) {%>
         <tr class="TextHeader pointer" onclick="setValue('<%=cdo.getColValue("via")%>', '<%=cdo.getColValue("medicamento")%>')">
        <%} else {%>
        <tr class="TextHeader">
        <%}%>
			<td width="30%"><cellbytelabel id="3">Medicamento</cellbytelabel></td>
			<!--<td width="7%">Dosis</td>-->
			<td width="12%"><cellbytelabel id="4">V&iacute;a</cellbytelabel></td>
			<td width="20%"><cellbytelabel id="5">Frecuencia</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="6">Observaci&oacute;n</cellbytelabel></td>
		</tr>

		<%}%>
        
        <%if(exp.trim().equals("3")) {%>
         <tr class="<%=color%> pointer" onclick="setValue('<%=cdo.getColValue("via")%>', '<%=cdo.getColValue("medicamento")%>')">
        <%} else {%>
        <tr class="<%=color%>">
        <%}%>
			<td width="30%"><%=cdo.getColValue("medicamento")%></td>
			<!--<td width="7%"><%//=cdo.getColValue("dosis")%></td>-->
			<td width="12%"><%=cdo.getColValue("descVia")%></td>
			<td width="20%"><%=cdo.getColValue("frecuencia")%></td>
			<td width="30%"><%=cdo.getColValue("observacion")%></td>
		</tr>

	<%
	fecha = cdo.getColValue("fechaMedica")+"-"+cdo.getColValue("horaMedica");
	}%>

				</table>
			</td>
		</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("exp", exp)%>
<%=fb.hidden("index", index)%>
<tr>
	<td colspan="4" align="right">
		<%=fb.button("close","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
%>
