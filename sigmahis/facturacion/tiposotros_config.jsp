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
		if (code == null) throw new Exception("El Tipo de Otro Cargo no es válido. Por favor intente nuevamente!");

		sql = "SELECT descripcion, activo_inactivo as estado FROM tbl_fac_tipo_otros WHERE compania="+(String) session.getAttribute("_companyId")+" and codigo="+code;
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
document.title=" Tipo Otros Cargos Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Tipo Otros Cargos Edición - "+document.title;
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACIÓN - MANTENIMIENTO - TIPOS DE OTROS CARGOS "></jsp:param>
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
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="85%"><%=code%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,false,60,100)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel>Estado</cellbytelabel></td>
					<td><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"))%></td>
				</tr>
				<tr>
					<td colspan="2">
						<jsp:include page="../common/bitacora.jsp" flush="true">
							<jsp:param name="audTable" value="tbl_fac_tipo_otros"></jsp:param>
							<jsp:param name="audFilter" value="<%="codigo="+code+" and compania="+(String) session.getAttribute("_companyId")%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
                <tr class="TextRow02">
					<td align="right" colspan="2">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
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
			System.out.println("post-------------");
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  cdo = new CommonDataObject();
  code = request.getParameter("code");

  cdo.setTableName("tbl_fac_tipo_otros");
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").equals(""))
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("activo_inactivo",request.getParameter("estado"));

  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
    cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		cdo.setAutoIncCol("codigo");
		cdo.addPkColValue("codigo","");
		cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId"));

	SQLMgr.insert(cdo);
    code = SQLMgr.getPkColValue("codigo");
			System.out.println("pk-------------"+SQLMgr.getPkColValue("codigo"));
  }
  else
  {
			System.out.println("bef update-------------");
    cdo.addColValue("usuario_modificacion",UserDet.getUserName());
			System.out.println("bef update1-------------");
    cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			System.out.println("bef update2-------------");
    cdo.setWhereClause("codigo="+request.getParameter("code")+" and compania="+(String) session.getAttribute("_companyId"));
			System.out.println("bef update3-------------");

	SQLMgr.update(cdo);
			System.out.println("aft update-------------");
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/tiposotros_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/tiposotros_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/tiposotros_list.jsp';
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