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
CONSULTA DE SOLICITUDES DE INTERCONSULTA MEDICA
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


if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select AM.primer_nombre||decode(AM.segundo_nombre,'','',' '||AM.segundo_nombre)||' '||AM.primer_apellido|| decode(AM.segundo_apellido, null,'',' '||AM.segundo_apellido)||decode(AM.sexo,'F', decode(AM.apellido_de_casada,'','',' '||AM.apellido_de_casada)) as nombre_medico, esp.descripcion as descripcion, a.medico as medico, a.codigo as codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.observacion as observacion, nvl(a.cod_especialidad,' ') as cod_especialidad, a.comentario as comentario, a.usuario_creacion as usuariocreacion, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am') as fechacreacion, a.usuario_modificacion as usuariomodificacion, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am') as fechamodificacion, (select count(*) from tbl_sal_interconsultor_resp r where r.codigo_preg = a.codigo and r.pac_id = a.pac_id and r.admision = a.secuencia) as tot_resp, a.medico_solicitante from tbl_sal_interconsultor a, tbl_adm_medico AM, tbl_adm_especialidad_medica esp Where a.pac_id(+)="+pacId+" and a.secuencia="+noAdmision+" and a.medico=AM.codigo(+) and esp.codigo(+)=a.cod_especialidad  order by a.codigo asc";
	al = SQLMgr.getDataList(sql);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Solicitudes de Interconsulta - '+document.title;

function doAction(){}
function viewAns(codPreg, med, medSol){
  showPopWin("../expediente/exp_interconsulta_resp.jsp?fg=EXP&fp=RESP&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codigo="+codPreg+"&medSol="+medSol+"&medico="+med+"&mode=view",winWidth*.85,winHeight*.80,null,null,'');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SOLICITUD DE INTERCONSULTA"></jsp:param>
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
	if(!fecha.trim().equals(cdo.getColValue("fecha")+"-"+cdo.getColValue("medico")))
	{
%>
			<tr class="TextHeader">
				<td colspan="3"><cellbytelabel id="1">M&eacute;dico</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("nombre_medico")%></td>
				<td colspan="1"><cellbytelabel id="2">Especialidad</cellbytelabel>:&nbsp;&nbsp;<%=cdo.getColValue("descripcion")%></td>
				<td colspan="1" align="center"><cellbytelabel id="3">Fecha</cellbytelabel>:&nbsp;<%=cdo.getColValue("fecha")%></td>
			</tr>

	<%}%>
			<tr class="TextHeader01">
				<td colspan="4"><cellbytelabel id="4">Observaciones del m&eacute;dico</cellbytelabel>:</td>
				<td align="center"><cellbytelabel>Respuestas</cellbytelabel>:</td>
			</tr>

		<tr class="<%=color%>">
			<td colspan="4"><%=cdo.getColValue("observacion")%></td>
			<td align="center"> <a href="javascript:viewAns('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("medico")%>','<%=cdo.getColValue("medico_solicitante")%>')" class="Link00Bold">Ver</a>&nbsp;(<%=cdo.getColValue("tot_resp")%>)</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="5">&nbsp;</td>
		</tr>
	<%
	fecha = cdo.getColValue("fecha")+"-"+cdo.getColValue("medico");
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
