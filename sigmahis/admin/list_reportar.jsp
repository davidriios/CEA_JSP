<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
	//if (SecMgr.checkLogin(session.getId()) == 1) {
	//	if (SecMgr.checkAccess(session.getId(),"0") == 1) {
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alcentro = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
if (fp == null) fp = "default";

if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";

  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  if (request.getParameter("code") != null)
  {
    appendFilter += " and upper(codigo) like '%"+request.getParameter("code").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("code");
    searchType = "1";
    searchDisp = "Código";
  }
	
  else if (request.getParameter("name") != null)
  {
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";
    searchOn = "descripcion";
    searchVal = request.getParameter("name");
    searchType = "1";
    searchDisp = "Nombre";
  }
	
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
   if (searchType.equals("1"))
   {
     appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
   }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
	sql="select codigo as code, descripcion as name from tbl_cds_centro_servicio where codigo!=0"+appendFilter;
	alcentro = SQLMgr.getDataList(sql);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_cds_centro_servicio WHERE codigo!=0"+appendFilter);
	
if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";
  
  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);
  
  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;
  
  if(rowCount==0) pVal=0;
  else pVal=preVal;

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Lista de Reportes - '+document.title;

function returnValue(code,name)
{
<%
if (fp.equalsIgnoreCase("centroser"))
{
%>
window.opener.document.form1.codigo.value=code; 
window.opener.document.form1.descripcion.value=name; 
<%
}
else
{
%>
window.opener.document.form1.reportar.value=code; 
window.opener.document.form1.otro.value=name; 
<%
}
%>
window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">

<%--<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>--%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACIÓN - CENTRO DE SERVICIO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
   <%-- <td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0"))
//{
%>
			<a href="javascript:add()" class="Link00">[ Registrar Nuevo Centro Educativo ]</a>
<%
//}
%>
		</td>--%>
  </tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">		
				<%fb = new FormBean("search01",request.getContextPath()+request.getServletPath());%>	
				<%=fb.formStart()%>
				<td width="15%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel> </td>
				<td width="35%">&nbsp;
							<%=fb.textBox("code","",false,false,false,30,null,null,null)%>
							<%=fb.submit("go","Ir")%></td>
				<%=fb.formEnd()%>	
				
				<%fb = new FormBean("search02",request.getContextPath()+request.getServletPath());%>
				<%=fb.formStart()%>
				<td width="15%">&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td width="35%">&nbsp;
							<%=fb.textBox("name","",false,false,false,30,null,null,null)%>
							<%=fb.submit("go","Ir")%>	</td>
				<%=fb.formEnd()%>	
			</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <%--<tr>
    <td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0"))
//{
%>
			<a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>
<%
//}
%>
		</td>
  </tr>--%>
</table>
<br/>	
	
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>			
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader">
	  <td width="10%">&nbsp;</td>
		<td width="45%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="45%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>	
	</tr>
	<%
				for (int i=0; i<alcentro.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) alcentro.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td>&nbsp;<%=cdo.getColValue("code")%></td>
					<td>&nbsp;<a href="javascript:returnValue('<%=cdo.getColValue("code")%>','<%=cdo.getColValue("name")%>')" class="Link00"><%=cdo.getColValue("name")%></a></td>
				</tr>
				<%
				}
		%>						
							
</table>		

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+request.getServletPath());
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
				<tr>
					<td colspan="4" align="right"> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>	
			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} 
%>