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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500027") || SecMgr.checkAccess(session.getId(),"500028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String contrato = request.getParameter("contrato");
String reemplazar = request.getParameter("reemplazar");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String estado = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doSubmit(){
	document.form1.submit();
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
			<%=fb.hidden("contrato",contrato)%>
			<%=fb.hidden("anio",anio)%>
			<%=fb.hidden("mes",mes)%>
			<%=fb.hidden("reemplazar",reemplazar)%>
				<tr class="TextHeader" align="center">
					<td colspan="2">Correr Job Facturas</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro de Inactivar Facturas?</font></cellbytelabel></td>
				</tr>
				<tr class="">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Observaci&oacute;n:</font></cellbytelabel><br><%=fb.textarea("observacion","",true,false,false,60,4)%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="2">
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit();\"")%>
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
	String refer_no = "";
  
  sql.append("call sp_pm_inactiva_factura(?,?,?,?,?,?,?)");
  CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	  param.setSql(sql.toString());
	  param.addInNumberStmtParam(1,request.getParameter("contrato"));
		param.addInNumberStmtParam(2,request.getParameter("anio"));
		param.addInNumberStmtParam(3,request.getParameter("mes"));
		param.addInStringStmtParam(4,(String) session.getAttribute("_userName"));
		param.addInStringStmtParam(5,request.getParameter("observacion"));
		param.addInStringStmtParam(6,request.getParameter("reemplazar"));
		param.addOutStringStmtParam(7);
		
		param = SQLMgr.executeCallable(param);
		for (int i=0; i<param.getStmtParams().size(); i++) {
			CommonDataObject.StatementParam pp = param.getStmtParam(i);		
			if (pp.getType().contains("o")) {		
				if (pp.getIndex() == 7) refer_no = pp.getData().toString();		
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
	<%if(request.getParameter("reemplazar")!=null && request.getParameter("reemplazar").equals("S")){%>
	alert('Guardado Satisfactoriamente!  Se generó la factura <%=refer_no%>!');
	<%} else {%>
	alert('<%=SQLMgr.getErrMsg()%>');
	<%}%>
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