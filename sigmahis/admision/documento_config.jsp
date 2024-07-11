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
/******************************
500015	AGREGAR DOCUMENTO
500016	MODIFICAR DOCUMENTO
*******************************/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");	
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500015") || SecMgr.checkAccess(session.getId(),"500016"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String  file837= "N";
try {file837 =java.util.ResourceBundle.getBundle("issi").getString("file837");}catch(Exception e){ file837 = "N";}

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("codigo","0");
	}
	else
	{
		if (code == null) throw new Exception("El Documento no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.codigo, a.nombre as nombre, a.area_revision as area, a.usuario_creacion as userCrea, a.usuario_modificacion as userMod, a.fecha_creacion as fechaCrea, a.fecha_modificacion as fechaMod, categoria_adm FROM tbl_adm_documento a WHERE a.codigo="+code;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Documento Edición - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLÍNCA - ADMISIÓN - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
			
			
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="12%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="88%"><%=cdo.getColValue("codigo")%></td>				
				</tr>							
				<tr class="TextRow01">
					<td><cellbytelabel id="2">Nombre</cellbytelabel></td>
					<td><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,45)%></td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="3">&Aacute;rea</cellbytelabel></td>
					<td><%=fb.select("area","AD=ADMISION,SL=SALAS,AM=AMBAS",cdo.getColValue("area"))%></td>
				</tr>		
<%if(file837.trim().equals("S")){%>				
				<tr class="TextRow01">
					<td><cellbytelabel id="3">Categor&iacute;a Admisi&oacute;n:</cellbytelabel></td>
					<td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_Adm_categoria_admision order by 2 asc","categoria_adm",cdo.getColValue("categoria_adm"),false,false,0,"Text12","width:175px",null,null,"S")%></td>
				</tr>			
<%}%>				
                <tr class="TextRow02">
			        <td colspan="2" align="right">
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

  cdo.setTableName("tbl_adm_documento");
  cdo.addColValue("nombre",request.getParameter("nombre"));
  cdo.addColValue("area_revision",request.getParameter("area"));
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss")); 
  if(request.getParameter("categoria_adm")!=null) cdo.addColValue("categoria_adm",request.getParameter("categoria_adm")); 

  if (mode.equalsIgnoreCase("add"))
  {
  cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
  cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.setAutoIncCol("codigo");

	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("codigo="+request.getParameter("codigo"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/documento_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/documento_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/documento_list.jsp';
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