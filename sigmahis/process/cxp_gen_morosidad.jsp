<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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

StringBuffer sbSql = new StringBuffer();
String fecha = request.getParameter("fecha");
String tipo = request.getParameter("tipo");
String proveedor = request.getParameter("proveedor");
String tipoFac = request.getParameter("tipoFac");
String docAn = request.getParameter("docAn");
String factCero = request.getParameter("factCero");
String soloCxp = request.getParameter("soloCxp");

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (fecha == null) throw new Exception("Parametros invalidos para generar morosidad CXP !. Por favor intente nuevamente!");
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
	<jsp:param name="title" value="CXC - PROCESOS"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>			
			<%=fb.formStart(true)%>
			<%=fb.hidden("fecha",fecha)%>
			<%=fb.hidden("tipo",tipo)%>
			<%=fb.hidden("proveedor",proveedor)%>
			<%=fb.hidden("tipoFac",tipoFac)%>
			<%=fb.hidden("docAn",docAn)%>
			<%=fb.hidden("factCero",factCero)%>
			<%=fb.hidden("soloCxp",soloCxp)%>
				<tr class="TextHeader" align="center">
					<td colspan="2">Generar Morosidad CXP</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro de generar la Morosidad hasta el <%=fecha%></font></cellbytelabel></td>
				</tr>
                 
				<tr class="TextRow02">
					<td align="center" colspan="2">
						<%=fb.submit("save","Guardar",true,false)%>
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
  		
  			if(docAn.trim().equals("true"))sbSql.append("call sp_cxp_morosidad3('");
			else sbSql.append("call sp_cxp_morosidad2('");
			sbSql.append(fecha);
			sbSql.append("','");
			sbSql.append(IBIZEscapeChars.forSingleQuots(tipo.trim()));
			sbSql.append("',");
			sbSql.append(proveedor);	
			sbSql.append(",");
			sbSql.append((String) session.getAttribute("_companyId"));		
			sbSql.append(", '");
			sbSql.append(tipoFac);
			sbSql.append("' ");
			if(!docAn.trim().equals("true"))
			{
				sbSql.append(", '");
				sbSql.append(factCero);
				sbSql.append("' ");
			}
			 if(!docAn.trim().equals("true"))
			{
				sbSql.append(", '");
				sbSql.append(soloCxp);
				sbSql.append("' ");
			}
			sbSql.append(")");  
 
	SQLMgr.execute(sbSql.toString());
  
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
	parent.window.location.reload(false);
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