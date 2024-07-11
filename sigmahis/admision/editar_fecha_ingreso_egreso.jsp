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
800049	VER LISTA DE IDIOMA
800050	IMPRIMIR LISTA DE IDIOMA
800051	AGREGAR IDIOMA
800052	MODIFICAR IDIOMA
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
String admision = request.getParameter("admision");

if (mode == null) mode = "edit";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (id == null) throw new Exception("Paciente ID no es válido. Por favor intente nuevamente!");

		sql = "select b.primer_nombre, b.segundo_nombre, b.primer_apellido, b.segundo_apellido, to_char(coalesce(b.f_nac, b.fecha_nacimiento), 'dd/mm/yyyy') fecha_nacimiento, to_char(a.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso, to_char(a.fecha_egreso, 'dd/mm/yyyy') fecha_egreso from tbl_adm_paciente b, tbl_adm_admision a where a.pac_id = b.pac_id and a.secuencia = "+admision+" and a.pac_id = "+id;
		cdo = SQLMgr.getData(sql);
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Admisión - '+document.title;
function verFechaNac(){
	var fecha_ingreso = document.form1.fecha_ingreso.value;	
	var fecha_egreso = document.form1.fecha_egreso.value;	
	if(fecha_ingreso == '' && fecha_egreso == ''){
		CBMSG.warning('Introduzca fecha de ingreso o egreso!');
		return false;
	} else return true;
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
<%=fb.hidden("admision",admision)%>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader01">
			<td align="right"><cellbytelabel id="1">Nombre</cellbytelabel>:&nbsp;</td>
      <td>&nbsp;
			<%=cdo.getColValue("primer_nombre")%>&nbsp;
			<%=cdo.getColValue("segundo_nombre")%>&nbsp;
			<%=cdo.getColValue("primer_apellido")%>&nbsp;
			<%=cdo.getColValue("segundo_apellido")%>
      </td>
      <td align="right"><cellbytelabel id="2">Fecha de Nacimiento</cellbytelabel>:&nbsp;</td>
      <td>&nbsp;
			<%=cdo.getColValue("fecha_nacimiento")%>
      </td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel id="3">Fecha de Ingreso Anterior</cellbytelabel>:</td>
			<td width="">
			<%=fb.textBox("fecha_ing_old",cdo.getColValue("fecha_ingreso"),false,false,true,12,null,null,"")%>
      </td>
			<td width="15%" align="right"><cellbytelabel id="4">Fecha de Egreso Anterior</cellbytelabel>:</td>
			<td width="">
			<%=fb.textBox("fecha_eg_old",cdo.getColValue("fecha_egreso"),false,false,true,12,null,null,"")%>
      </td>
		</tr>
		<tr class="TextHeader02">
			<td colspan="4"><cellbytelabel id="5">Ingresar Nueva Fecha de Ingreso</cellbytelabel>:</td>
		</tr>
    <tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel id="6">Fecha Ingreso Nueva</cellbytelabel>:</td>
			<td width="">
			<%=fb.hidden("fecha_ingreso_old",cdo.getColValue("fecha_ingreso"))%>
      <jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="1" />
      <jsp:param name="nameOfTBox1" value="fecha_ingreso" />
      <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_ingreso")%>" />
      </jsp:include>
      </td>
			<td width="15%" align="right"><cellbytelabel id="7">Fecha Egreso Nueva</cellbytelabel>:</td>
			<td width="">
      <%
			String readOnly = "y";
			if(cdo.getColValue("fecha_egreso") != null && !cdo.getColValue("fecha_egreso").equals("")) readOnly = "n";
			%>
			<%=fb.hidden("fecha_egreso_old",cdo.getColValue("fecha_egreso"))%>
      <jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="1" />
      <jsp:param name="nameOfTBox1" value="fecha_egreso" />
      <jsp:param name="readonly" value="<%=readOnly%>" />
      <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_egreso")%>" />
      </jsp:include>
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
<%fb.appendJsValidation("if(!verFechaNac()) error++;");%>
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

	cdo.setTableName("tbl_adm_admision");
	if(request.getParameter("fecha_ingreso")!=null && !request.getParameter("fecha_ingreso").equals("") && !request.getParameter("fecha_ingreso").equals(request.getParameter("fecha_ingreso_old"))) cdo.addColValue("fecha_ingreso",request.getParameter("fecha_ingreso"));
	if(request.getParameter("fecha_egreso")!=null && !request.getParameter("fecha_egreso").equals("") && !request.getParameter("fecha_egreso").equals(request.getParameter("fecha_egreso_old"))) cdo.addColValue("fecha_egreso",request.getParameter("fecha_egreso"));
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("edit"))
	{
    	cdo.setWhereClause("secuencia = "+request.getParameter("admision")+" and pac_id = "+request.getParameter("id"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/admision_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/admision_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/admision_list.jsp';
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