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
===============================================================================
500019	AGREGAR UBICACI�N DEL MEDICO
500020	MODIFICAR UBICACION DEL MEDICO
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500019") || SecMgr.checkAccess(session.getId(),"500020"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("codigo","0");
	}
	else
	{
		if (code == null) throw new Exception("La Ubicaci�n M�dica no es v�lido. Por favor intente nuevamente!");

		sql = "SELECT a.codigo as codigo, a.descripcion as descripcion FROM tbl_adm_ubicacion a WHERE a.codigo="+code;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Ubicaci�n M�dica Edici�n - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CL�NCA - ADMISI�N - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">			

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
			
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="12%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="88%"><%=cdo.getColValue("codigo")%></td>				
				</tr>							
				<tr class="TextRow01">
					<td><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,45)%></td>
				</tr>						
                <tr class="TextRow02">
			        <td colspan="2" align="right">
				    <%=fb.submit("save","Guardar",true,false)%>
				    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>		
			
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
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_adm_ubicacion");
  cdo.addColValue("descripcion",request.getParameter("descripcion")); 

  if (mode.equalsIgnoreCase("add"))
  {
	cdo.setAutoIncCol("codigo");

	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("codigo="+request.getParameter("codigo"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/ubic_medica_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/ubic_medica_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/ubic_medica_list.jsp';
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