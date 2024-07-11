<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%

SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String codigo = request.getParameter("id");
String compania = (String) session.getAttribute("_companyId"); 
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		codigo = "0";
	}
	else
	{
		if (codigo == null) throw new Exception("Código no es válido. Por favor intente nuevamente!");

		sql = "select codigo, descripcion, pagar_vacacion, pagar_xiii_mes, pagar_pantig, pagar_indemn, pagar_recargo25, pagar_recargo50 from tbl_pla_li_motivo where codigo = "+codigo+" and compania = "+(String) session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Planilla - '+document.title;

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Motivos de Terminación de Contratos"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("compania",compania)%>
		<tr>
			<td colspan="8">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="8">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="5%" align="center">Código</td>
			<td width="25%" align="center">Descripción</td>
			<td width="10%" align="center">Vac.</td>
			<td width="10%" align="center">XIII.</td>
			<td width="10%" align="center">P.Antig.</td>
			<td width="10%" align="center">Indemn.</td>
      <td width="10%" align="center">Recargo-25</td>
			<td width="10%" align="center">Recargo-50</td>
		</tr>
		<tr class="TextRow02">
			<td align="center"><%=fb.textBox("codigo",cdo.getColValue("codigo"),true,false,false,5,null,null,"")%></td>
			<td align="left"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,40,null,null,"")%></td>
			<td align="center"><%=fb.checkbox("pagar_vacacion","S",(cdo.getColValue("pagar_vacacion") != null && cdo.getColValue("pagar_vacacion").equalsIgnoreCase("S")),false)%></td>
			<td align="center"><%=fb.checkbox("pagar_xiii_mes","S",(cdo.getColValue("pagar_xiii_mes") != null && cdo.getColValue("pagar_xiii_mes").equalsIgnoreCase("S")),false)%></td>
			<td align="center"><%=fb.checkbox("pagar_pantig","S",(cdo.getColValue("pagar_pantig") != null && cdo.getColValue("pagar_pantig").equalsIgnoreCase("S")),false)%></td>
			<td align="center"><%=fb.checkbox("pagar_indemn","S",(cdo.getColValue("pagar_indemn") != null && cdo.getColValue("pagar_indemn").equalsIgnoreCase("S")),false)%></td>
      <td align="center"><%=fb.checkbox("pagar_recargo25","S",(cdo.getColValue("pagar_recargo25") != null && cdo.getColValue("pagar_recargo25").equalsIgnoreCase("S")),false)%></td>
			<td align="center"><%=fb.checkbox("pagar_recargo50","S",(cdo.getColValue("pagar_recargo50") != null && cdo.getColValue("pagar_recargo50").equalsIgnoreCase("S")),false)%></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="8">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="8" align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="8">&nbsp;</td>
		</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	codigo   = request.getParameter("codigo");

	cdo = new CommonDataObject();

	cdo.setTableName("tbl_pla_li_motivo");
	
	cdo.addColValue("descripcion",request.getParameter("descripcion"));

	if(request.getParameter("pagar_xiii_mes")!=null && request.getParameter("pagar_xiii_mes").trim().equals("S"))
		cdo.addColValue("pagar_xiii_mes","S");
		else cdo.addColValue("pagar_xiii_mes","N");
		if(request.getParameter("pagar_pantig")!=null && request.getParameter("pagar_pantig").trim().equals("S"))
		cdo.addColValue("pagar_pantig","S");
		else cdo.addColValue("pagar_pantig","N");
		if(request.getParameter("pagar_vacacion")!=null && request.getParameter("pagar_vacacion").trim().equals("S"))
		cdo.addColValue("pagar_vacacion","S");
		else cdo.addColValue("pagar_vacacion","N");
		if(request.getParameter("pagar_indemn")!=null && request.getParameter("pagar_indemn").trim().equals("S"))
		cdo.addColValue("pagar_indemn","S");
		else cdo.addColValue("pagar_indemn","N");
		if(request.getParameter("pagar_recargo25")!=null && request.getParameter("pagar_recargo25").trim().equals("S"))
		cdo.addColValue("pagar_recargo25","S");
		else cdo.addColValue("pagar_recargo25","N");
		if(request.getParameter("pagar_recargo50")!=null && request.getParameter("pagar_recargo50").trim().equals("S"))
		cdo.addColValue("pagar_recargo50","S");
		else cdo.addColValue("pagar_recargo50","N");
				

	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("compania",request.getParameter("compania"));
	  cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
	  cdo.setAutoIncCol("codigo");
		
		SQLMgr.insert(cdo);
	}
	else
	{
 
   cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and codigo="+request.getParameter("codigo"));
		SQLMgr.update(cdo);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/motivo_liq_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/motivo_liq_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/motivo_liq_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>