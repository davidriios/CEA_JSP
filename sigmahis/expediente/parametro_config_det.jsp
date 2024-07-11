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

String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String param_id = request.getParameter("id");
String tipo = request.getParameter("tipo");

if(mode != null && mode.equalsIgnoreCase("edit")){
	param_id = request.getParameter("param_id");
}
   
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(param_id == null) throw new Exception("El Código del Parámetro no es válido. Por favor intente nuevamente!");
	if(tipo == null) throw new Exception("El tipo del Parámetro no es válido. Por favor intente nuevamente!");
	
	if (mode.equalsIgnoreCase("add")) id = "0";
	
	else
	{
		if (id == null) throw new Exception("El Código del Parámetro no es válido. Por favor intente nuevamente!");
		sql = "select id, param_id, descripcion, orden, status, evaluable, comentable, eval_values from tbl_sal_parametro_det where id="+id;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Mantenimiento de Parámetros "+document.title;

//Si esta checkeado el Evaluua Paraametro y no tiene los valores de la evaluacion
//el campo, retorna false y  pasamos el valor de retorno a 
//appendJsValidation (FormBean Method)
function checkEvalValues(){
	if(document.form1.evaluable.checked==true){
		if(document.form1.eval_values.value == ''){
		   return false;
		}else{
		   return true;
	    }
}else{
	return true;
	}
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - PARAMETROS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("param_id",param_id)%>
<%fb.appendJsValidation("if(document.form1.descripcion.value==''){alert('Por favor seleccione el Tipo de Parámetro!!');document.form1.descripcion.focus();error++;}");%>
<%fb.appendJsValidation("if(!checkEvalValues()){alert('Por favor Introduzca los valores de la evaluaciones!!');document.form1.eval_values.focus();error++;}");%>
		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01" >
			<td width="22%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="78%"><%=id%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,50,100)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="3">Estado</cellbytelabel></td>
			<td><%=fb.select("status","A=ACTIVO,I=INACTIVO",cdo.getColValue("status"),false,viewMode,0,"Text10",null,null,"","")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="4">Orden</cellbytelabel></td>
			<td><%=fb.intBox("orden",cdo.getColValue("orden"),false,false,false,10,2)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="5">Eval&uacute;a el Par&aacute;metro</cellbytelabel>?</td>
			<td><%=fb.checkbox("evaluable","S",(cdo.getColValue("evaluable") != null && cdo.getColValue("evaluable").equalsIgnoreCase("S")),viewMode)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="6">Detalla el Par&aacute;metro</cellbytelabel>?</td>
			<td><%=fb.checkbox("comentable","S",(cdo.getColValue("comentable") != null && cdo.getColValue("comentable").equalsIgnoreCase("S")),viewMode)%></td>
		</tr>
   
        <tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
        <tr class="TextRow02">
			<td colspan="2"><cellbytelabel id="7">Por ejemplo si los valores van a ser SI o NO: Introduzca: S=SI,N=NO o un rango de datos: 1,2,3,...</cellbytelabel></td>
		</tr>
        <tr class="TextRow01">
        <td><cellbytelabel id="8">Valores de las evaluaciones</cellbytelabel></td>
        <td><%=fb.textBox("eval_values",cdo.getColValue("eval_values"),false,false,false,50,100)%></td>
        </tr>

        <tr class="TextRow02">
			<td align="right" colspan="2">
				<cellbytelabel id="9">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N")%><cellbytelabel id="10">Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O")%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
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
	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_sal_parametro_det");
	cdo.addColValue("descripcion",request.getParameter("descripcion"));
//	cdo.addColValue("tipo",request.getParameter("tipo"));
	cdo.addColValue("status",request.getParameter("status"));
	
	if (mode.equalsIgnoreCase("edit")){
	    cdo.addColValue("param_id",param_id);
	}else{
		cdo.addColValue("param_id",request.getParameter("param_id"));
	}
	
	cdo.addColValue("orden",request.getParameter("orden"));
	cdo.addColValue("evaluable",(request.getParameter("evaluable") == null)?"N":request.getParameter("evaluable"));
	cdo.addColValue("comentable",(request.getParameter("comentable") == null)?"N":request.getParameter("comentable"));
	cdo.addColValue("eval_values",(request.getParameter("eval_values") == null)?"":request.getParameter("eval_values"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.setAutoIncCol("id");
		cdo.addPkColValue("id","");
		SQLMgr.insert(cdo);
		id = SQLMgr.getPkColValue("id");
	}
	else if (mode.equalsIgnoreCase("edit"))
	{
		cdo.setWhereClause("id="+request.getParameter("id"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/parametro_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/parametro_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/parametro_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>