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

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		code = "0";
	}
	else
	{
		if (code == null) throw new Exception("La Función del Personal no es válida. Por favor intente nuevamente!");

		sql = "SELECT a.codigo, a.descripcion, a.area, (select descripcion from tbl_sec_unidad_ejec where codigo =a.area and compania="+(String) session.getAttribute("_companyId")+")as areaName, a.tipo_personal as tipo, a.status FROM tbl_cds_funcion a WHERE a.codigo="+code;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Función del Personal - '+document.title;

function addArea()
{
  abrir_ventana1('../rhplanilla/list_seccion.jsp?fp=funciones');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLÍNCA - ADMISIÓN - FUNCIONES DEL PERSONAL"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">			

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",code)%>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="25%"><%=code%></td>
					<td width="12%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<td width="53%"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,65)%></td>				
				</tr>							
				<tr class="TextRow01">
					<td><cellbytelabel id="3">Tipo</cellbytelabel></td>
					<td><%=fb.select("tipo","M=Médico,E=Empleado,S=Sociedad Medica",cdo.getColValue("tipo"))%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Estado
                    <%=fb.select("status","A=Activo,I=Inactivo",cdo.getColValue("status"))%></td>
					<td><cellbytelabel id="4">&Aacute;rea</cellbytelabel></td>
					<td><%=fb.textBox("area",cdo.getColValue("area"),true,false,true,5)%><%=fb.textBox("areaName",cdo.getColValue("areaName"),false,false,true,55)%><%=fb.button("btnarea","...",true,false,null,null,"onClick=\"javascript:addArea()\"")%></td>
				</tr>									
                <tr class="TextRow02">
			        <td colspan="4" align="right">
				    <%=fb.submit("save","Guardar",true,false)%>
				    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="4">&nbsp;</td>
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
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_cds_funcion");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("tipo_personal",request.getParameter("tipo")); 
  cdo.addColValue("area",request.getParameter("area")); 
  cdo.addColValue("status",request.getParameter("status")); 

  if (mode.equalsIgnoreCase("add"))
  {
	cdo.setAutoIncCol("codigo");

	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("codigo="+request.getParameter("code"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/funcionespersonal_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/funcionespersonal_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/funcionespersonal_list.jsp';
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