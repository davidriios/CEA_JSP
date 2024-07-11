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
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

if (seccion == null) seccion = "20";
if (desc == null) desc = "O/M TRATAMIENTOS";


if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = " select  to_char(a.fecha_creac,'dd/mm/yyyy') fecha, to_char(a.fecha_creac,'hh12:mi:ss am') hora, a.usuario_creac usuario_crea, to_char(a.fecha_creac,'dd/mm/yyyy hh12:mi:ss am') fecha_crea, a.codigo, t.descripcion tipoTratamiento, a.observacion, to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi:ss am') fechaFin from tbl_sal_tratamiento_paciente a, tbl_sal_tratamiento t where a.pac_id = "+pacId+" and a.secuencia ="+noAdmision+" and a.cod_tratamiento = t.codigo order by a.fecha_creac desc, a.codigo asc ";
	al = SQLMgr.getDataList(sql);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Tratamientos - '+document.title;

function doAction()
{
}

function imprimir(){abrir_ventana('../expediente/print_exp_seccion_20.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="TRATAMIENTOS"></jsp:param>
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
			<td colspan="5" align="right">
			<a href="javascript:imprimir()" class="Link00Bold">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a>
			</td>
		</tr>
<%
String fecha = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if(!fecha.trim().equals(cdo.getColValue("fecha")+"-"+cdo.getColValue("hora")))
	{
%>

		<tr class="TextHeader">
			<td><cellbytelabel id="1">Fecha</cellbytelabel>:&nbsp;<%=cdo.getColValue("fecha")%></td>
			<td colspan="4"><cellbytelabel id="2">Hora</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("hora")%></td>

		</tr>
		<tr class="TextHeader01">
		<td colspan="5"><cellbytelabel id="3">Creado Por</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("usuario_crea")%>&nbsp;&nbsp;<%=cdo.getColValue("fecha_crea")%></td>
		</tr>
		<tr class="TextHeader">
			<td width="30%"><cellbytelabel id="4">Tipo Tratamiento</cellbytelabel></td>
			<td width="50%"><cellbytelabel id="5">Observaci&oacute;n</cellbytelabel></td>
			<td width="18%"><cellbytelabel id="6">Fecha Fin</cellbytelabel></td>
		</tr>

		<%}%>
		<tr class="<%=color%>">
			<td width="30%"><%=cdo.getColValue("tipoTratamiento")%></td>
			<td width="50%"><%=cdo.getColValue("observacion")%></td>
			<td width="18%"><%=cdo.getColValue("fechaFin")%></td>
		</tr>

	<%
	fecha = cdo.getColValue("fecha")+"-"+cdo.getColValue("hora");
	}%>

				</table>
			</td>
		</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
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
