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

StringBuffer sbSql  = new StringBuffer();
String mode = request.getParameter("mode"); 
String id = request.getParameter("id"); 

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (id == null) throw new Exception("Articulo no es válido. Por favor intente nuevamente!");

		sbSql.append("select a.cod_articulo, a.descripcion, nvl(a.consignacion_sino,'N') as isAppropiation,nvl(a.precio_venta,0.00) as precio from tbl_inv_articulo a where a.cod_articulo = ");
		sbSql.append(id);
		sbSql.append(" ");
		cdo = SQLMgr.getData(sbSql.toString()); 
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
	<jsp:param name="title" value="INVENTARIO - CAMBIO DE PRECIO DE ARTICULO"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>			
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("id",id)%> 
				<tr class="TextHeader" align="center">
					<td colspan="2">SOLICITUD DE CAMBIO DE PRECIO POR REGALIA</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro de Cambiar el precio del articulo - [<%=id%>] - [<%=cdo.getColValue("descripcion")%>] </font></cellbytelabel></td>
				</tr>
				 <tr class="TextRow01">
                    <td colspan="2"  align="center"><cellbytelabel>C O M E N T A R I O S</cellbytelabel> <%=fb.textarea("comments","",true,false,false,80,5,2000,null,"","")%></td>
                </tr>
                 
				<tr class="TextRow02">
					<td align="center" colspan="2">
						<%=fb.submit("save","Cambiar",true,false)%>
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
  
  
   
   sbSql = new StringBuffer();
  sbSql.append("call sp_inv_upd_precio_cero(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", ");
	sbSql.append(id);
	sbSql.append(", '");
	sbSql.append((String) session.getAttribute("_userName"));
	sbSql.append("', '");
	sbSql.append(issi.admin.IBIZEscapeChars.forSingleQuots(request.getParameter("comments")));
	sbSql.append("')"); 
	
	 
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		SQLMgr.execute(sbSql.toString());
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