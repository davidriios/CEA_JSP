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
==================================================================================
900055	AGREGAR UNIDAD X AREA 
900056	MODIFICAR UNIDAD X AREA
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900055") || SecMgr.checkAccess(session.getId(),"900056"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String areaCode=request.getParameter("areaCode");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";	
		CommonDataObject cdoDet = SQLMgr.getData("select codigo, descripcion from tbl_con_pres_area where codigo="+areaCode+" and compania="+(String) session.getAttribute("_companyId"));
		cdo.addColValue("area",cdoDet.getColValue("codigo"));
		cdo.addColValue("areaDesc",cdoDet.getColValue("descripcion"));	
	}
	else
	{
		if (id == null) throw new Exception("El Aréa no es válido. Por favor intente nuevamente!");
		if (areaCode == null) throw new Exception("El Aréa no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.unidad_adm, a.descripcion, a.area, b.descripcion as areaDesc FROM tbl_con_pres_unidad_x_area a, tbl_sec_unidad_ejec b WHERE a.area="+areaCode+" and a.unidad_adm="+id+" and a.compania="+(String) session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Area Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Area Edición - "+document.title;
<%}%>

function addUnidad()
{
  abrir_ventana2('area_unidadesadm_list.jsp?id=1');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("areaCode",areaCode)%>
		
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td>Area</td>
				<td><%=cdo.getColValue("area")%> - <%=cdo.getColValue("areaDesc")%></td>
			</tr>										
			<tr class="TextRow01">
				<td>Unidad Adm.</td>
				<td><%=fb.intBox("unidad_adm",cdo.getColValue("unidad_adm"),true,false,true,5)%><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,true,49)%>&nbsp;<%=fb.button("btnunid","...",true,false,null,null,"onClick=\"javascript:addUnidad()\"")%></td>
			</tr>					
			<tr class="TextRow02">
				<td colspan="2" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	
			<tr>
				<td colspan="2">&nbsp;</td>
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
  areaCode = request.getParameter("areaCode");
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_con_pres_unidad_x_area");
  cdo.addColValue("descripcion",request.getParameter("descripcion")); 
  cdo.addColValue("unidad_adm",request.getParameter("unidad_adm"));
  cdo.addColValue("area",areaCode);
    
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and area="+areaCode);
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("unidad_adm="+request.getParameter("id")+" and area="+areaCode+" and compania="+(String) session.getAttribute("_companyId"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/unidad_x_area_list.jsp?areaCode="+areaCode))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/unidad_x_area_list.jsp?areaCode="+areaCode)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/unidad_x_area_list.jsp?areaCode=<%=areaCode%>';
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