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
<jsp:useBean id="_companyId" scope="session" class="java.lang.String"/>
<%
/**
==================================================================================
500007	AGREGAR TIPO DE ADMISION
500008	MODIFICAR TIPO DE ADMISION
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500007") || SecMgr.checkAccess(session.getId(),"500008"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String catCode = request.getParameter("catCode");

if (catCode == null) throw new Exception("La Categoría de Admisión no es válida. Por favor intente nuevamente!");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("codigo","0");

		CommonDataObject cdoCat = SQLMgr.getData("select codigo, descripcion from tbl_adm_categoria_admision where codigo="+catCode);
		cdo.addColValue("catCode",cdoCat.getColValue("codigo"));
		cdo.addColValue("catDesc",cdoCat.getColValue("descripcion"));
	}
	else
	{
		if (code == null) throw new Exception("El Tipo de Admisión no es válido. Por favor intente nuevamente!");

		sql = "select a.codigo, a.descripcion, a.categoria as catCode, b.descripcion as catDesc from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b WHERE a.categoria=b.codigo and a.categoria="+catCode+" and a.codigo="+code;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Tipo Admisión Edición - '+document.title;
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
			<%=fb.hidden("catCode",cdo.getColValue("catCode"))%>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td><cellbytelabel id="1">Categor&iacute;a</cellbytelabel></td>
					<td><%=cdo.getColValue("catCode")%> - <%=cdo.getColValue("catDesc")%></td>
				</tr>						
				<tr class="TextRow01">
					<td width="12%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
					<td width="88%"><%=cdo.getColValue("codigo")%></td>				
				</tr>							
				<tr class="TextRow01">
					<td><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></td>
					<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,45)%></td>
				</tr>
                <tr class="TextRow02">
			        <td colspan="2" align="right">
				    <%=fb.submit("save","Guardar",true,false)%>
				    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
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
  catCode = request.getParameter("catCode");
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_adm_tipo_admision_cia");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  
  cdo.setCreateXML(true);
  cdo.setFileName("itemTipo.xml");
  cdo.setOptValueColumn("codigo");
  cdo.setOptLabelColumn("descripcion");
  cdo.setKeyColumn("categoria");
  cdo.setXmlWhereClause("");

  if (mode.equalsIgnoreCase("add"))
  {
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
  	    cdo.addColValue("categoria", catCode);
		cdo.setAutoIncCol("codigo");
		cdo.setAutoIncWhereClause("categoria="+catCode);
	
		SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("categoria="+catCode+" and codigo="+request.getParameter("codigo"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/tipoadmision_list.jsp?catCode="+catCode))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/tipoadmision_list.jsp?catCode="+catCode)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/tipoadmision_list.jsp?catCode=<%=catCode%>';
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