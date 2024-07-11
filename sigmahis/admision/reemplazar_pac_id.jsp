<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String fp = request.getParameter("fp");

if (mode == null) mode = "edit";
if (fp == null) fp = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (id == null) throw new Exception("EmpleadoID no es válido. Por favor intente nuevamente!");

		sql = "select pac_id, exp_id, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, to_char(fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, codigo,to_char(f_nac, 'dd/mm/yyyy') as f_nac from vw_adm_paciente where pac_id="+id;
		cdo = SQLMgr.getData(sql);
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Admisión - '+document.title;

function chkPacId(){
	var pac_id = document.form1.new_pac_id.value;
	var saveSN = true;
	if(pac_id=='') {
		CBMSG.warning('Introduzca Código de Paciente!');
		saveSN = false;
	} else {
		if(hasDBData('<%=request.getContextPath()%>','tbl_adm_paciente',' exp_id = '+pac_id,'')){
			document.form1.new_pac_id.value = document.form1.old_pac_id.value;
			saveSN = false;
		}
	}
	return saveSN;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EDITAR FECHA DE NACIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("fp",fp)%>
<%fb.appendJsValidation("if(!chkPacId()){CBMSG.warning('Este código ya existe!');error++;}");%>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="RedTextBold">
			<td colspan="4" align="center">SOLO PARA EXPEDIENTE</td>
		</tr>
		<tr class="TextHeader01" height="20">
			<td align="right">Nombre:&nbsp;</td>
      <td>&nbsp;
			<%=cdo.getColValue("primer_nombre")%>&nbsp;
			<%=cdo.getColValue("segundo_nombre")%>&nbsp;
			<%=cdo.getColValue("primer_apellido")%>&nbsp;
			<%=cdo.getColValue("segundo_apellido")%>
      </td>
      <td align="right">Fecha de Nacimiento:&nbsp;</td>
      <td>&nbsp;
			<%=cdo.getColValue("f_nac")%>
      </td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="20%" align="right">Registro Unico de Paciente Anterior:</td>
			<td width="" colspan="3">
			<%=fb.intBox("old_pac_id",id,true,false,true,12,null,null,"")%>
      </td>
		</tr>
		<tr class="TextHeader02" height="20">
			<td colspan="4">Ingresar Nuevo</td>
		</tr>
		<tr class="TextRow01">
			<td width="20%" align="right">Nuevo Registro Unico de Paciente:</td>
			<td width="" colspan="3">
			<%=fb.intBox("new_pac_id",cdo.getColValue("exp_id"),true,false,false,12,null,null,"")%>
      </td>
		</tr>

		<tr class="TextRow02">
			<td colspan="4" align="center">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
<%=fb.formEnd(true)%>

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

	cdo.setTableName("tbl_adm_paciente");
	cdo.addColValue("exp_id",request.getParameter("new_pac_id"));

	if (mode.equalsIgnoreCase("edit"))
	{
    cdo.setWhereClause("pac_id="+request.getParameter("id"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.update(cdo);
		ConMgr.clearAppCtx(null);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/paciente_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/paciente_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/paciente_list.jsp?fp=<%=fp%>';
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