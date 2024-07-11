<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String index = request.getParameter("index");
String fecha = request.getParameter("fecha");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

if (index==null) index= "";
if (fecha==null) fecha= "trunc(sysdate)"; else fecha="to_date('"+fecha+"','dd/mm/yyyy')";
if (pacId==null) pacId= "";
if (noAdmision==null) noAdmision= "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	StringBuffer sbSql = new StringBuffer();
	sbSql.append("select pac_id, admision, eq_type, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,6),'|','') as resultado, z.obx_segment, to_char(a.message_date,'dd/mm/yyyy hh12:mi:ss AM') as obx_date, to_char(a.message_date,'hh12:mi:ss AM') as obx_time from tbl_int_eqresult a, tbl_int_eqresult_det z where a.id = z.id and z.obx_rec_no = 10 and a.eq_type = 'GLU' and trunc(a.message_date) > sysdate - 60 and a.pac_id = ").append(pacId).append(" and exists (select null from tbl_adm_admision aa where pac_id = a.pac_id and adm_root = (select adm_root from tbl_adm_admision where pac_id = aa.pac_id and secuencia = ").append(noAdmision).append(")) and trunc(a.message_date) = ").append(fecha).append(" order by a.message_date desc");
	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Resultados Glucometros - '+document.title;
function doAction() {}
function setResultado(k)
{
	var $section = $(parent.window.document).find('#contentForm').find("iframe");

	$section.contents().find("input[name='glicemia<%=index%>']").val($('#resultado'+k).val());
	$section.contents().find("input[name='hora<%=index%>']").val($('#obx_time'+k).val());
	$section.contents().find("input[name='from_results']").val('Y');
	$section[0].contentWindow.getInsulinas(<%=index%>);
	window.parent.hidePopWin();
}

function getMain(formx)
{
	formx.especialidad.value = document.search00.especialidad.value;
	formx.status.value = document.search00.status.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RESULTADOS GLUCOMETROS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>

<table width="99%" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td class="TableLeftBorder TableRightBorder">

	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("resultados",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>

<tr class="TextHeader" align="center">
	<td width="20%"><cellbytelabel id="5">Tipo</cellbytelabel></td>
	<td width="50%"><cellbytelabel id="6">Resultado</cellbytelabel></td>
	<td width="30%"><cellbytelabel id="6">Fecha</cellbytelabel></td>
</tr>

<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
	<%=fb.hidden("tipo"+i,cdo.getColValue("eq_type"))%>
	<%=fb.hidden("resultado"+i,cdo.getColValue("resultado"))%>
	<%=fb.hidden("obx_date"+i,cdo.getColValue("obx_date"))%>
	<%=fb.hidden("obx_time"+i,cdo.getColValue("obx_time"))%>

	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setResultado(<%=i%>)" style="text-decoration:none; cursor:pointer">
		<td><%=cdo.getColValue("eq_type")%></td>
		<td><%=cdo.getColValue("resultado")%></td>
		<td align="center"><%=cdo.getColValue("obx_date")%></td>
	</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
</table>

	</td>
</tr>
</table>
</body>
</html>
<%
}//POST
%>