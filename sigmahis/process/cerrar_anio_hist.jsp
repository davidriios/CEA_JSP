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
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String anio = request.getParameter("anio"); 
String fg = request.getParameter("fg");
String estado_hist = request.getParameter("estado_hist");
String estado="";
String desc = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (anio == null) throw new Exception("Año no existen!. Por favor intente nuevamente!");
		desc=" ACTUALIZAR ESTADO HISTORICO";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MAYOR GENERAL - PROCESOS"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>			
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("anio",anio)%>  
			<%=fb.hidden("fg",fg)%> 
				<tr class="TextHeader" align="center">
					<td colspan="2"> <%=desc%></td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro <%=desc%> para el AÑO: <%=anio%>&nbsp;</font></cellbytelabel></td>
				</tr>
                <tr class="TextRow01"> 
				<% if(estado_hist.trim().equals("ACT")) estado="CER=CERRADO";else estado="ACT=ACTIVO"; %>
					<td colspan="2" align="center">Nuevo Estado Historico: <%=fb.select("estado_hist",estado,"",false,false,0,"Text10","","","","")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="center" colspan="2">
						<%=fb.submit("save","Ejecutar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
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

</body>
</html>
<%
}//GET
else
{
  cdo = new CommonDataObject();

	cdo.setTableName("tbl_con_estado_anos");
	cdo.addColValue("estado_hist",request.getParameter("estado_hist")); 
	cdo.addColValue("usuario_cierre_hist",(String) session.getAttribute("_userName")); 
	cdo.addColValue("fecha_cierre_hist","sysdate");  
    cdo.setWhereClause("ano="+request.getParameter("anio")+" and cod_cia="+(String) session.getAttribute("_companyId"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.update(cdo);
		ConMgr.clearAppCtx(null); 
  
%>
<html>
<head>
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