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
CommonDataObject cdo = new CommonDataObject();
StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String pac_id = request.getParameter("pac_id");
String pac_id_desc = "";
String estado = "";
if (mode == null) mode = "app";
if (pac_id == null) pac_id = "";

if(pac_id.equals("ACH")) pac_id_desc = "ACH";
else if(pac_id.equals("TC")) pac_id_desc = "Tarjeta de Credito";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (code == null) throw new Exception("El Código de Cliente no es válido. Por favor intente nuevamente!");
		cdo = SQLMgr.getData("select id_paciente, codigo, nombre_paciente, sexo, primer_nombre, to_char(fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento from vw_pm_cliente where codigo = "+code);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function showPacienteList(){
	var id_paciente = '<%=cdo.getColValue("id_paciente")%>';
	var primer_nombre = '<%=cdo.getColValue("primer_nombre")%>';
	var sexo = '<%=cdo.getColValue("sexo")%>';
	var id_paciente = '<%=cdo.getColValue("id_paciente")%>';
	var fecha_nacimiento = '<%=cdo.getColValue("fecha_nacimiento")%>';
	abrir_ventana('../common/search_paciente.jsp?fp=pm_updt_pac_id&id_paciente='+id_paciente+'&sexo='+sexo+'&primer_nombre='+primer_nombre+'&id_paciente='+id_paciente+'&fecha_nacimiento='+fecha_nacimiento)
}
function doSubmit(){
	var pac_id = document.form1.pac_id.value;
	if(pac_id=='') CBMSG.warning('PAC_ID incorrecto!');
	else if(hasDBData('<%=request.getContextPath()%>','tbl_pm_cliente','pac_id = '+pac_id))CBMSG.warning('Ya existe Cliente con este pac_id '+pac_id);
	else document.form1.submit();
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
			<%=fb.hidden("fecha_nacimiento",cdo.getColValue("fecha_nacimiento"))%>
				<tr class="TextHeader" align="center">
					<td colspan="2">Actualizaci&oacute;n de PAC_ID</td>
				</tr>
				<tr class="TextRow01">
					<td align="center">C&oacute;digo Cliente:</td>
					<td align="left"><%=cdo.getColValue("codigo")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="center">Nombre:</td>
					<td align="left"><%=cdo.getColValue("nombre_paciente")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="center">Identificaci&oacute;n:</td>
					<td align="left"><%=cdo.getColValue("id_paciente")%></td>
				</tr>
				<tr class="TextRow01">
					<td align="center">PAC_ID:</td>
					<td align="left">
					<%=fb.textBox("pac_id","",true,false,true,10,"Text10",null,null)%>
					<%=fb.button("search","...",true,false,null,null,"onClick=\"javascript:showPacienteList();\"")%>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="center" colspan="2">
						<%=fb.button("save","Guardar",true,false, null,null,"onClick=\"javascript:doSubmit();\"")%>
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
	sql.append("call sp_pm_update_pac_id(");
	sql.append(code);
	sql.append(", '");
	sql.append((String) session.getAttribute("_userName"));
	sql.append("', ");
	sql.append(request.getParameter("pac_id"));
	sql.append(")");
  
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