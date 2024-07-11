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

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode"); 
String id = request.getParameter("id");
String fecha = request.getParameter("fecha");
String fechaEnvio = request.getParameter("fechaEnvio");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (fechaEnvio == null)fechaEnvio="";
if(fechaEnvio.trim().equals(""))fechaEnvio=cDateTime;
if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (id == null) throw new Exception("ID no existen!. Por favor intente nuevamente!");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function validDateTime(){
var xDate=document.form1.fecha_recibo.value;
var fecha="<%=fecha%>";
var fechaEnvio="<%=fechaEnvio%>";

if(xDate!=''){
if(getDBData('<%=request.getContextPath()%>','case when to_date(\''+xDate+'\',\'dd/mm/yyyy\') >= to_date(\''+fechaEnvio+'\',\'dd/mm/yyyy\') and to_date(\''+xDate+'\',\'dd/mm/yyyy\') <= trunc(sysdate) then 0 else 1 end','dual','','')==1){alert('La fecha es menor a la fecha de envio de la lista o mayor a la fecha actual!');return false;}
}
return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACION - LISTA ENVIO"></jsp:param>
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
			<%=fb.hidden("baction","")%>
 				<tr class="TextRow01">
					<td align="center" colspan="2">Introduzca fecha de Recibo:
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="fecha_recibo" />
						<jsp:param name="valueOfTBox1" value="" /> 
						<jsp:param name="fieldClass" value="Text10 FormDataObjectRequired"/>
						<jsp:param name="buttonClass" value="Text10" />
						<jsp:param name="clearOption" value="true" />
						</jsp:include>
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
				<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'){if(document."+fb.getFormName()+".fecha_recibo.value.trim()==''){alert('Por favor indicar la Fecha de Recibido!');error++;}}");%>
				<%fb.appendJsValidation("if(!validDateTime())error++;");%>


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
  sql.append("update tbl_fac_lista_envio set fecha_modificacion=sysdate,  usuario_modificacion = '");
  sql.append((String) session.getAttribute("_userName"));
  sql.append("' ,fecha_recibido_cxc = to_date('");
  sql.append(request.getParameter("fecha_recibo"));
  sql.append("','dd/mm/yyyy') where id = ");
	sql.append(id); 
	sql.append(" and compania = ");
	sql.append((String) session.getAttribute("_companyId"));

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