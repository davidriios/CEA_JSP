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
String tipo = request.getParameter("tipo");
String f_desde = request.getParameter("f_desde");
String f_hasta = request.getParameter("f_hasta");
String no_lista = request.getParameter("no_lista");
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
			<%=fb.hidden("tipo",tipo)%>
			<%=fb.hidden("f_desde",f_desde)%>
			<%=fb.hidden("f_hasta",f_hasta)%>
			<%=fb.hidden("no_lista",no_lista)%>
				<tr class="TextHeader" align="center">
					<td colspan="2">Liquidaci&oacute;n por Lote</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro de Generar Liquidaci&oacute;n de Reclamo por Lote?</font></cellbytelabel></td>
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
	String v_msg = "";
	if(f_desde==null || f_desde.equals("")) f_desde="";
	if(f_hasta==null || f_hasta.equals("")) f_hasta="";
  sql.append("call sp_pm_liquidacion_reclamo_lote(?,?,?,?,?,?)");
  CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	  param.setSql(sql.toString());
	  param.addInStringStmtParam(1,request.getParameter("tipo"));
		param.addInStringStmtParam(2,f_desde);
		param.addInStringStmtParam(3,f_hasta);
		param.addInNumberStmtParam(4,request.getParameter("no_lista"));
		param.addInStringStmtParam(5,(String) session.getAttribute("_userName"));
		param.addOutStringStmtParam(6);
		
		param = SQLMgr.executeCallable(param);
		for (int i=0; i<param.getStmtParams().size(); i++) {
			CommonDataObject.StatementParam pp = param.getStmtParam(i);		
			if (pp.getType().contains("o")) {		
				if (pp.getIndex() == 6) v_msg = pp.getData().toString();		
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
	alert('Guardado Satisfactoriamente!  Se procesaron <%=v_msg%> facturas!');
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