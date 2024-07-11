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
StringBuffer sbFilter = new StringBuffer();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String orderNo  = request.getParameter("orderNo");
	String codProcedimiento = request.getParameter("codProcedimiento");
	String pacId = request.getParameter("pacId");
	String noAdmision = request.getParameter("noAdmision");
	if (orderNo == null) orderNo = "";
	if (codProcedimiento == null) codProcedimiento = "";
	if (pacId == null) pacId = "";
	if (noAdmision == null) noAdmision = "";

	if (!orderNo.trim().equals("")) { sbFilter.append(" and order_no = "); sbFilter.append(orderNo); }
	if (!codProcedimiento.trim().equals("")) { sbFilter.append(" and cpt_code = '"); sbFilter.append(codProcedimiento); sbFilter.append("'"); }
	if (!pacId.trim().equals("")) { sbFilter.append(" and pac_id = "); sbFilter.append(pacId); }
	if (!noAdmision.trim().equals("")) { sbFilter.append(" and admision = "); sbFilter.append(noAdmision); }

	sbSql.append("select detail_no, cpt_code, cpt_descripcion, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,1),'|','') as obx0, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,2),'|','') as obx1, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,3),'|','') as obx2, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,4),'|','') as obx3, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,5),'|','') as obx4, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,6),'|','') as obx5, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,7),'|','') as obx6, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,8),'|','') as obx7, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,9),'|','') as obx8, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,10),'|','') as obx9, replace(regexp_substr(obx_segment,'([^|]*)(\\||$)',1,11),'|','') as obx10 from tbl_int_result_det z");
	//if (sbFilter.length() > 0) { sbSql.append(" where"); sbSql.append(sbFilter.substring(4)); }
	sbSql.append(" where obx_file_type is null");
	sbSql.append(sbFilter);
	sbSql.append(" order by detail_no");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a)");
%>
<html>
<head>
<%@ include file="../../common/nocache.jsp"%>
<%@ include file="../../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Resultados - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../../common/header.jsp"%>
<%@ include file="../../common/menu_base.jsp"%>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<% if (al.size() == 0) { %>
<tr class="TextHeader">
	<td align="left" colspan="6">La Orden a&uacute;n no ha sido procesada, en espera de resultados.</td>
</tr>
<% } else { %>
<tr class="TextHeader">
	<td width="5%">&nbsp;</td>
	<td width="30%"><cellbytelabel>Prueba</cellbytelabel></td>
	<td width="30%"><cellbytelabel>Resultado</cellbytelabel></td>
	<td width="15%"><cellbytelabel>Unidad</cellbytelabel></td>
	<td width="15%"><cellbytelabel>Valor de Referencia</cellbytelabel></td>
	<td width="5%">&nbsp;</td>
</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i == 0) {
%>
<tr class="TextHeader01" >
	<td colspan="6"><%=cdo.getColValue("cpt_code")+"-"+cdo.getColValue("cpt_descripcion")%></td>
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
<%
}
}
%>
</table>
<%@ include file="../../common/footer.jsp"%>
</body>
</html>
<% } %>