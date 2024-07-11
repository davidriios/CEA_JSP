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

if (mode == null) mode = "edit";

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (id == null) throw new Exception("EmpleadoID no es válido. Por favor intente nuevamente!");

		sql = "select primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, to_char(coalesce(f_nac,fecha_nacimiento), 'dd/mm/yyyy') fecha_nacimiento, codigo from tbl_adm_paciente where pac_id="+id;
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
	var fecha = document.form1.fecha_nacimiento.value;	
	if(fecha=='') {
		CBMSG.warning('Introduzca fecha de nacimiento!');
		return false;
	} else{ if((!isValidateDate(fecha))){CBMSG.warning('Formato de fecha inválida!');return false;}else return true; }
}
function getCodigo(){
	/*var fecha = document.form1.fecha_nacimiento.value;	
	if(fecha=='') {
		CBMSG.warning('Introduzca fecha de nacimiento!');
		
	} else {
	if((!isValidateDate(fecha))){CBMSG.warning('Formato de fecha inválida!');return false;}else{
		var codigo =  getDBData('<%=request.getContextPath()%>','nvl(max(codigo), 0)+1','tbl_adm_paciente ',' trunc(fecha_nacimiento) = to_date(\''+fecha+'\', \'dd/mm/yyyy\')','');
		//if(codigo!=document.form1.codigo.value) CBMSG.warning('El código del paciente será cambiado por el '+codigo);
		document.form1.codigo.value = codigo;
		
		}
	}*/
}
function istAnInvalidDob() {
  var dob = document.getElementById("fecha_nacimiento").value;
  var result = getDBData('<%=request.getContextPath()%>',"'y' as res",'dual',"trunc(sysdate) < to_date('"+dob+"','dd/mm/yyyy')",'');
  if (result && result == 'y'){
    CBMSG.error("La fecha de nacimiento ingresada es incorrecta por favor ingresar una fecha menor o igual al día actual!");
    return true;
  }
  return false;
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
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
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
			<td width="15%" align="right"><cellbytelabel id="3">Fecha de Nacimiento Anterior</cellbytelabel>:</td>
			<td width="" colspan="3">
			<%=fb.textBox("fecha_nacimiento_old",cdo.getColValue("fecha_nacimiento"),true,false,true,12,null,null,"")%>
      </td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel id="4">C&oacute;digo de Paciente</cellbytelabel>:</td>
			<td width="" colspan="3"><%=cdo.getColValue("codigo")%>
			<%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
      </td>
		</tr>
		<tr class="TextHeader02">
			<td colspan="4"><cellbytelabel id="5">Ingresar Nueva Fecha de Nacimiento</cellbytelabel>:</td>
		</tr>
    <tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel id="6">Fecha Nacimiento Nueva</cellbytelabel>:</td>
			<td width="" colspan="3">
      <jsp:include page="../common/calendar.jsp" flush="true">
      <jsp:param name="noOfDateTBox" value="1" />
      <jsp:param name="nameOfTBox1" value="fecha_nacimiento" />
      <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_nacimiento")%>" />
      <jsp:param name="onChange" value="javascript:getCodigo();" />
      <jsp:param name="jsEvent" value="getCodigo();" />
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
<%fb.appendJsValidation("if(istAnInvalidDob())error++;");%>
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
	cdo.addColValue("f_nac",request.getParameter("fecha_nacimiento"));
	//cdo.addColValue("codigo",request.getParameter("codigo"));

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
	window.opener.location = '<%=request.getContextPath()%>/admision/paciente_list.jsp';
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