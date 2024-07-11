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
String code = request.getParameter("code");
String fecha = request.getParameter("fecha");
if(fecha==null) fecha=CmnMgr.getCurrentDate("dd/mm/yyyy");
String estado = "";
if(request.getParameter("estado")!=null) estado = request.getParameter("estado");
if (mode == null) mode = "close";
if(mode.equals("close")){
	estado = "F";
	mode = "Cerrar";
} else if(mode.equals("cancel")){
	estado = "";
	mode = "Cancelar";
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (code == null) throw new Exception("El Código de Contrato no es válido. Por favor intente nuevamente!");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function chkFecha(){
	var fecha = document.form1.fecha.value;
	var x = getDBData('<%=request.getContextPath()%>','\'S\'','tbl_pm_solicitud_contrato','id=<%=code%> and trunc(fecha_ini_plan) <= to_date(\''+fecha+'\', \'dd/mm/yyyy\') and to_date(\''+fecha+'\', \'dd/mm/yyyy\') >= trunc(sysdate)','')||'N';
	if(x=='N'){
		alert('La fecha debe ser mayor a la fecha de inicio de Contrato y mayor o igual a la fecha Actual!');
		document.form1.fecha.value='';
		return false;
	} else return true;
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
			<%=fb.hidden("estado",estado)%>
			<%if(mode.equals("Cerrar")){%>
			<%fb.appendJsValidation("if(!chkFecha())error++;");%>
			<%}%>
				<tr class="TextHeader" align="center">
					<td colspan="2"><%=(mode.equals("Cerrar")?"Cerrar":"Cancelar Cierre de ")%>Contrato</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro de <%=(mode.equals("Cerrar")?"Cerrar":"Cancelar Cierre de ")%> el Contrato No. <%=code%>?</font></cellbytelabel></td>
				</tr>
				<%if(mode.equals("Cerrar")){%>
				<tr class="TextRow01">
					<td colspan="2" align="center">
				<cellbytelabel id="2">Fecha Cierre</cellbytelabel><br>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="jsEvent" value="chkFecha();" />
				</jsp:include>
					</td>
				</tr>
				<%}%>
				<tr>
					<td colspan="2" align="center"><b>Motivo:</b>
					<%=fb.textarea("observacion","",true,false,false,100,2, 1000)%>
					</td>
				</tr>
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
  code = request.getParameter("code");
	if(request.getParameter("mode").equals("Cancelar")) estado = "X";
	sql.append("call sp_pm_cerrar_contrato(");
	sql.append(code);
	sql.append(", '");
	sql.append((String) session.getAttribute("_userName"));
	sql.append("', '");
	sql.append(estado);
	sql.append("', '");
	sql.append(fecha);
	sql.append("', '");
	sql.append(request.getParameter("observacion"));
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