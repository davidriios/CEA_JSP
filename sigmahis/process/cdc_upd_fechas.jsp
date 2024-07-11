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
String noAdmision = request.getParameter("noAdmision");
String pacId = request.getParameter("pacId");
String codCita = request.getParameter("codCita");
String fechaReg = request.getParameter("fechaReg");
String fp = request.getParameter("fp");
String tipo = request.getParameter("tipo");
String fechaIn = request.getParameter("fechaIn");
String fechaOut = request.getParameter("fechaOut");
String desc ="";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if (tipo.trim().equals("AN"))desc =" AREA DE ANESTESIA "; 
else if (tipo.trim().equals("OR"))desc =" SALON DE OPERACIONES "; 
else if (tipo.trim().equals("REC"))desc =" RECOBROS "; 
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
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("pacId",pacId)%>
			<%=fb.hidden("codCita",codCita)%>
			<%=fb.hidden("fechaReg",fechaReg)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("tipo",tipo)%> 
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".fechaIn.value.trim()==''){alert('Introduzca fecha Inicio');error++;}");%>
				<tr class="TextHeader" align="center">
					<td colspan="2">ACTUALIZAR FECHAS DE ENTRADA / SALIDA: <%=desc%> </td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center">
					Fecha Entrada: 
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fechaIn" />
				<jsp:param name="valueOfTBox1" value="<%=fechaIn%>" />
				<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" /> 
				<jsp:param name="clearOption" value="true" /> 
				</jsp:include>
				<br>
				Fecha Salida : 
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fechaOut" />
				<jsp:param name="valueOfTBox1" value="<%=fechaOut%>" />
				<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" /> 
				<jsp:param name="clearOption" value="true" /> 
				</jsp:include>
				
					
					</td>
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

fechaIn = request.getParameter("fechaIn");
fechaOut = request.getParameter("fechaOut");
 if(fechaIn!=null && !fechaIn.trim().equals(""))
 {
  sql.append("update tbl_cdc_io_log set usuario_modificacion = '");
  sql.append((String) session.getAttribute("_userName"));
  sql.append("',fecha_in =to_date('");
  sql.append(fechaIn);
  sql.append("','dd/mm/yyyy hh12:mi:ss am')");
  sql.append(",fecha_out =to_date('");
  sql.append(fechaOut);
  sql.append("','dd/mm/yyyy hh12:mi:ss am')");
 }else  sql.append(" delete from  tbl_cdc_io_log ");
  
  sql.append(" where pac_id = ");
	sql.append(pacId);
	sql.append(" and admision = ");
	sql.append(noAdmision);
	sql.append(" and cod_cita = ");
	sql.append(codCita);
	sql.append(" and fecha_registro = to_date('");
	sql.append(fechaReg);
	sql.append("','dd/mm/yyyy')");
	sql.append(" and estado = 'OUT_");
	sql.append(tipo);
 	sql.append("'");
	
	SQLMgr.execute(sql.toString());
  
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