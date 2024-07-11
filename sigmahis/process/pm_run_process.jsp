<%//@ page errorPage="../error.jsp"%>
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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500027") || SecMgr.checkAccess(session.getId(),"500028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sql = new StringBuffer();
String fp = request.getParameter("fp");
String actType = request.getParameter("actType");
String docType = request.getParameter("docType");
String docId = request.getParameter("docId");
String docNo = request.getParameter("docNo");
String compania = request.getParameter("compania");
String fecha = request.getParameter("fecha");
String docDesc = "", actDesc = "";
if (fp.trim().equals("")) throw new Exception("El Origen no es válido. Por favor consulte con su Administrador!");
if (docType.trim().equals("")) throw new Exception("El Documento no es válido. Por favor consulte con su Administrador!");
if (actType.trim().equals("")) throw new Exception("La Acción no es válida. Por favor consulte con su Administrador!");
if(fecha==null) fecha="";
//* * * * * * * * * *   P R O C E S S   A C T I O N   * * * * * * * * * *
boolean requiredComments = false;
if(docType.equals("FECHA_NAC")){
	docDesc = "FECHA DE NACIMIENTO";
	if (actType.equalsIgnoreCase("4")) {
		actDesc = "EDITAR";
	}
}
if (request.getMethod().equalsIgnoreCase("GET"))
{
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
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>			
			<%=fb.formStart(true)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("actType",actType)%>
			<%=fb.hidden("docType",docType)%>
			<%=fb.hidden("docId",docId)%>
			<%=fb.hidden("docNo",docNo)%>
			<%=fb.hidden("compania",compania)%>
				<tr class="TextHeader" align="center">
					<td><%=actDesc%> <%=docDesc%></td>
				</tr>
				<% if (docType.equalsIgnoreCase("FECHA_NAC") && actType.equals("4")) { %>
				<tr class="TextRow01">
					<td colspan="2" align="center">
				<cellbytelabel id="2">Fecha:</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
					</td>
				</tr>
				<%}%>
				<tr class="TextRow02">
					<td align="right" colspan="2">
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

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  if (docType.equalsIgnoreCase("FECHA_NAC")) {
		if (actType.equalsIgnoreCase("4")) {
			sql.append("call sp_pm_upd_fecha_nac(");
			sql.append(docId);
			sql.append(", '");
			sql.append((String) session.getAttribute("_userName"));
			sql.append("', '");
			sql.append(fecha);
			sql.append("')");
			SQLMgr.execute(sql.toString());
		}
	}
  
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