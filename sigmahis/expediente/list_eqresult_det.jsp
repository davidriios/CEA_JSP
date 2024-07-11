<%@ page errorPage="../../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
String id  = request.getParameter("id");
if (id == null) id = "";
if (id.trim().equals("")) throw new Exception("Resultado ID no válido!");

if (request.getMethod().equalsIgnoreCase("GET")) {

	sbSql.append("select z.detail_id, z.observ_code, z.observ_descripcion, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,1),'|','') as obx0, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,2),'|','') as obx1, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,3),'|','') as obx2, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,4),'|','') as obx3, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,5),'|','') as obx4, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,6),'|','') as obx5, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,7),'|','') as obx6, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,8),'|','') as obx7, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,9),'|','') as obx8, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,10),'|','') as obx9, replace(regexp_substr(z.obx_segment,'([^|]*)(\\||$)',1,11),'|','') as obx10 from tbl_int_eqresult_det z where id = ");
	sbSql.append(id);
	sbSql.append(" order by detail_id");

	StringBuffer sbTmp = new StringBuffer();
	sbTmp.append("select * from (select rownum as rn, a.* from (");
	sbTmp.append(sbSql);
	sbTmp.append(") a)");
	al = SQLMgr.getDataList(sbTmp.toString());
%>
<html>
<head>
<%@ include file="../../common/nocache.jsp"%>
<%@ include file="../../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Resultados de Equipos - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../../common/header.jsp"%>
<%@ include file="../../common/menu_base.jsp"%>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr class="TextHeader">
	<td width="5%">&nbsp;</td>
	<td width="30%"><cellbytelabel>Prueba</cellbytelabel></td>
	<td width="30%"><cellbytelabel>Resultado</cellbytelabel></td>
	<td width="15%"><cellbytelabel>Unidad</cellbytelabel></td>
	<td width="15%"><cellbytelabel>Valor de Referencia</cellbytelabel></td>
	<td width="5%">&nbsp;</td>
</tr>
<% if (al.size() == 0) { %>
<tr class="TextHeader RedText SpacingTextBold" align="center">
	<td colspan="6"><br>RESULTADO SIN DETALLES<br><br></td>
</tr>
<% } %>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i == 0) {
%>
<tr class="TextHeader01" >
	<td colspan="6"><%=cdo.getColValue("observ_code")+"-"+cdo.getColValue("observ_descripcion")%></td>
</tr>
<% } %>
<tr>
	<td align="center">&nbsp;</td>
	<td><%=cdo.getColValue("obx3")%></td>
	<td><%=cdo.getColValue("obx5")%></td>
	<td><%=cdo.getColValue("obx6")%></td>
	<td><%=cdo.getColValue("obx7")%></td>
	<td align="center">&nbsp;</td>
</tr>
<% } %>
</table>
<%@ include file="../../common/footer.jsp"%>
</body>
</html>
<% } %>