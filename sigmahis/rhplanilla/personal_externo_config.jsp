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
800031	AGREGAR PERSONAL EXTERNO
800032	MODIFICAR PERSONAL EXTERNO
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800031") || SecMgr.checkAccess(session.getId(),"800032"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String sig=request.getParameter("sig");
String tom=request.getParameter("tom");
String asi=request.getParameter("asi");
String prov= request.getParameter("prov");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{

	}
	else
	{	

		sql = "Select compania, provincia , sigla, tomo, asiento, nombre, apellido, institucion, telefono_oficina as telefono1, telefono_casa as telefono2 from tbl_pla_personal_externo where compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi;
		
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
document.title="Personal Externo - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Personal Externo - Edición - "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PERSONAL EXTERNO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("prov",prov)%>
			<%=fb.hidden("sig",sig)%>
			<%=fb.hidden("asi",asi)%>
			<%=fb.hidden("tom",tom)%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>			
			<tr class="TextRow01">
			<%if(mode.equals("add")){%>
				<td width="20%">&nbsp;C&oacute;digo</td>
				<td width="80%"><%=fb.intBox("provin",cdo.getColValue("provincia"),true,false,false,1)%>
				<%=fb.textBox("sigl",cdo.getColValue("sigla"),true,false,false,1)%>
				<%=fb.intBox("tomos",cdo.getColValue("tomo"),true,false,false,5)%>
				<%=fb.intBox("asient",cdo.getColValue("asiento"),true,false,false,5)%>
			<%}else if(mode.equals("edit")){%>
			<td width="20%">&nbsp;C&oacute;digo</td>
				<td width="80%"><%=fb.intBox("provin",cdo.getColValue("provincia"),true,false,true,1)%>
				<%=fb.textBox("sigl",cdo.getColValue("sigla"),true,false,true,1)%>
				<%=fb.intBox("tomos",cdo.getColValue("tomo"),true,false,true,5)%>
				<%=fb.intBox("asient",cdo.getColValue("asiento"),true,false,true,5)%>
			<%}%>
				</td>
			</tr>							
			<tr class="TextRow01">
				<td>&nbsp;Nombre</td>
				<td><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,70)%></td>
			</tr>					
			<tr class="TextRow01">
				<td>&nbsp;Apellido</td>
				<td><%=fb.textBox("apellido",cdo.getColValue("apellido"),true,false,false,70)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Instituci&oacute;n</td>
				<td><%=fb.textBox("institucion",cdo.getColValue("institucion"),true,false,false,70)%></td>
			</tr>
			<tr class="TextRow01">	
				<td>&nbsp;Telefono de Oficina</td>
				<td><%=fb.textBox("telefono1",cdo.getColValue("telefono1"),false,false,false,20)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Telefono de Casa</td>
				<td><%=fb.textBox("telefono2",cdo.getColValue("telefono2"),false,false,false,20)%>
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
  cdo.setTableName("tbl_pla_personal_externo");
  cdo.addColValue("provincia", request.getParameter("provin")); 
  cdo.addColValue("sigla",request.getParameter("sigl"));
  cdo.addColValue("tomo",request.getParameter("tomos"));
  cdo.addColValue("asiento",request.getParameter("asient"));
  cdo.addColValue("nombre",request.getParameter("nombre"));
  cdo.addColValue("apellido",request.getParameter("apellido"));
  cdo.addColValue("institucion",request.getParameter("institucion"));
  cdo.addColValue("telefono_oficina",request.getParameter("telefono1"));
  cdo.addColValue("telefono_casa",request.getParameter("telefono2"));
  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+request.getParameter("prov")+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi);

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/personal_externo_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/personal_externo_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/personal_externo_list.jsp';
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