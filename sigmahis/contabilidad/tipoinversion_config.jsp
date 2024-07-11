<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
900047	AGREGAR TIPO DE INVERSION
900048	MODIFICAR TIPO DE INVERSION
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900047") || SecMgr.checkAccess(session.getId(),"900048"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String filter="and b.codigo_clase='115' and d.codigo=1 and c.codigo_prin='BA' and a.recibe_mov='S'";

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";		
	}
	else
	{
		if (id == null) throw new Exception("El Tipo de Inversion no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.tipo_inv as codigo, a.descripcion, a.compania, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, b.descripcion as catalogo FROM tbl_con_tipo_inversion a, tbl_con_catalogo_gral b WHERE a.cta1=b.cta1 and a.cta2=b.cta2 and a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.compania=b.compania and a.tipo_inv="+id+" and a.compania="+(String) session.getAttribute("_companyId");
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
document.title="Tipo Inversión Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipo Inversión Edición - "+document.title;
<%}%>

function addCatalogo()
{  
   abrir_ventana1('../contabilidad/ctabancaria_catalogo_list.jsp?id=5&filter=<%=IBIZEscapeChars.forURL(filter)%>');
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
		
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>			
			<tr class="TextRow01">
				<td width="17%">C&oacute;digo</td>
				<td width="83%"><%=id%></td>				
			</tr>							
			<tr class="TextRow01">
				<td>Descripci&oacute;n</td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,45)%></td>
			</tr>
			<tr class="TextRow01">
				<td>Cat&aacute;logo General</td>
				<td><%=fb.textBox("cta1",cdo.getColValue("cta1"),true,false,false,3)%><%=fb.textBox("cta2",cdo.getColValue("cta2"),true,false,false,3)%><%=fb.textBox("cta3",cdo.getColValue("cta3"),true,false,false,3)%><%=fb.textBox("cta4",cdo.getColValue("cta4"),true,false,false,3)%><%=fb.textBox("cta5",cdo.getColValue("cta5"),true,false,false,3)%><%=fb.textBox("cta6",cdo.getColValue("cta6"),true,false,false,3)%>
				<%=fb.textBox("catalogo",cdo.getColValue("catalogo"),true,false,false,45)%>
				<%=fb.button("btncat","...",true,false,null,null,"onClick=\"javascript:addCatalogo()\"")%></td>
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
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_con_tipo_inversion");
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
  cdo.addColValue("cta1",request.getParameter("cta1"));
  cdo.addColValue("cta2",request.getParameter("cta2"));
  cdo.addColValue("cta3",request.getParameter("cta3"));
  cdo.addColValue("cta4",request.getParameter("cta4"));
  cdo.addColValue("cta5",request.getParameter("cta5"));
  cdo.addColValue("cta6",request.getParameter("cta6"));
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
	cdo.setAutoIncCol("tipo_inv");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("tipo_inv="+request.getParameter("id")+" and compania="+(String) session.getAttribute("_companyId"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/tipoinversion_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/tipoinversion_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/tipoinversion_list.jsp';
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