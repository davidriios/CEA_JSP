<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.StringTokenizer" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500027") || SecMgr.checkAccess(session.getId(),"500028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String code = request.getParameter("pacId");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (mode == null) mode = "imprimir";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (code == null) throw new Exception("El Código de Paciente no es válido. Por favor intente nuevamente!");
		sql.append("select getNoContrato(p.codigo) contratos, p.codigo from tbl_pm_cliente p where p.pac_id = ");
		sql.append(code);
		cdo = SQLMgr.getData(sql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function showForm(contrato, clientId){
	abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_form_liq_reclamo.rptdesign&idParam='+clientId+'&contParam='+contrato+'&pCtrlHeader=true');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACION - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>			
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",code)%>
			
				<tr class="TextHeader" align="center">
					<td colspan="2">Imprimir Contrato</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro de <%=mode%> el Contrato No.: 
					<%
								 StringTokenizer st = new StringTokenizer(cdo.getColValue("contratos"), ",");
			 String cont = "", numero ="";
			 int c=0;
			 while (st.hasMoreTokens()) {
				 cont = st.nextToken();
				 numero = cont.substring(0, cont.indexOf("-"));
				%>
				<a href="javascript:showForm(<%=numero%>, <%=cdo.getColValue("codigo")%>)"><%=(c!=0?", ":"")%><%=cont%></a>
				<%
				c++;
			 }
			%>

					?</font></cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="2">
						<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  code = request.getParameter("code");
	sql.append("call sp_pm_cerrar_contrato(");
	sql.append(code);
	sql.append(", '");
	sql.append((String) session.getAttribute("_userName"));
	sql.append("', '");
	//sql.append(estado);
	sql.append("', '");
	sql.append(fecha);
	sql.append("')");
  
	SQLMgr.execute(sql.toString());
  
%>
<html>
<head>
<script language="javascript" src="../js/global.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.hidePopWin(false);
	parent.window.location.reload(true);
<%
	
} else throw new Exception(SQLMgr.getErrException());
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