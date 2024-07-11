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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500027") || SecMgr.checkAccess(session.getId(),"500028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";
if (mode.equals("")) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		code = "0";
	}
	else
	{
		if (code == null) throw new Exception("El C�digo de Tipo Habitaci�n no es v�lido. Por favor intente nuevamente!");

		sql = "SELECT secuencia, descripcion, estatus FROM tbl_res_tipo_habitacion WHERE secuencia="+code;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Tipos de Habitaci�n Residentes Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Tipos de Habitaci�n Residentes Edici�n - "+document.title;
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLINICO - ADMISION - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">			

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",code)%>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="15%">C&oacute;digo</td>
					<td width="85%"><%=code%></td>				
				</tr>							
				<tr class="TextRow01">
					<td>Descripci&oacute;n</td>
					<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,false,60,20)%></td>
				</tr>
				<tr class="TextRow01">
					<td>Estado</td>
					<td><%=fb.select("estatus","A=Activo,I=Inactivo",cdo.getColValue("estatus"))%></td>
				</tr>
				<tr>
					<td colspan="2">
						<jsp:include page="../common/bitacora.jsp" flush="true">
						<jsp:param name="audTable" value="tbl_res_tipo_habitacion"></jsp:param>
						<jsp:param name="audFilter" value="<%="secuencia="+code%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>									
                <tr class="TextRow02">
					<td align="right" colspan="2">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
  cdo = new CommonDataObject();
  code = request.getParameter("code");

  cdo.setTableName("tbl_res_tipo_habitacion");
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").equals(""))
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("estatus",request.getParameter("estatus"));  
  
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));  
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.setAutoIncCol("secuencia");
	cdo.addPkColValue("secuencia","");
	SQLMgr.insert(cdo);
    code = SQLMgr.getPkColValue("secuencia");
  }
  else
  {
    cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
    cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
    cdo.setWhereClause("secuencia="+code);
	SQLMgr.update(cdo);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/residencial/tipohabit_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/residencial/tipohabit_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/residencial/tipohabit_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>